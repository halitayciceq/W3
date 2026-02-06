/*
================================================================================
FIX: sp_prj_task_ws_set_save - İstasyon ekleme/güncelleme desteği
Tarih: 2026-01-21

Özellikler:
- Mevcut WS_SET varsa günceller
- Yeni istasyonlar için CELL_VALUE kayıtları oluşturur
- Kaldırılan istasyonların CELL_VALUE kayıtlarını siler
================================================================================
*/

USE workcube_prod;
GO

IF OBJECT_ID('workcube_prod.sp_prj_task_ws_set_save', 'P') IS NOT NULL
    DROP PROCEDURE workcube_prod.sp_prj_task_ws_set_save;
GO

CREATE PROCEDURE workcube_prod.sp_prj_task_ws_set_save
    @project_id         INT,
    @work_id            INT,
    @updated_by         INT,
    @json_workstations  NVARCHAR(MAX)  -- [{"workstation_id": 1, "code": "ABC", "name": "İstasyon 1"}, ...]
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    
    DECLARE @ws_set_id INT;
    DECLARE @instance_id INT;
    DECLARE @template_id INT;
    DECLARE @row_count INT = 0;
    DECLARE @is_new BIT = 0;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Template ID al (varsayılan URETIM_SURECI)
        SELECT @template_id = TEMPLATE_ID 
        FROM workcube_prod.PRJ_TASK_MATRIX_TEMPLATE 
        WHERE TEMPLATE_CODE = 'URETIM_SURECI' AND IS_ACTIVE = 1;
        
        -- Mevcut WS_SET var mı kontrol et
        SELECT @ws_set_id = WS_SET_ID 
        FROM workcube_prod.PRJ_TASK_WS_SET 
        WHERE PROJECT_ID = @project_id AND WORK_ID = @work_id;
        
        -- Instance var mı kontrol et
        SELECT @instance_id = INSTANCE_ID 
        FROM workcube_prod.PRJ_TASK_MATRIX_INSTANCE 
        WHERE PROJECT_ID = @project_id AND WORK_ID = @work_id AND TEMPLATE_ID = @template_id;
        
        -- JSON parse - temp table
        CREATE TABLE #NewWorkstations (
            workstation_id INT,
            code NVARCHAR(50) COLLATE Turkish_CI_AS,
            name NVARCHAR(200) COLLATE Turkish_CI_AS,
            sort_order INT IDENTITY(1,1)
        );
        
        INSERT INTO #NewWorkstations (workstation_id, code, name)
        SELECT 
            CAST(JSON_VALUE(j.value, '$.workstation_id') AS INT),
            ISNULL(JSON_VALUE(j.value, '$.code'), ''),
            ISNULL(JSON_VALUE(j.value, '$.name'), '')
        FROM OPENJSON(@json_workstations) j
        WHERE JSON_VALUE(j.value, '$.workstation_id') IS NOT NULL;
        
        SET @row_count = @@ROWCOUNT;
        
        IF @row_count = 0
        BEGIN
            RAISERROR('En az bir istasyon seçilmelidir', 16, 1);
            RETURN;
        END
        
        -- WS_SET yoksa oluştur
        IF @ws_set_id IS NULL
        BEGIN
            SET @is_new = 1;
            
            INSERT INTO workcube_prod.PRJ_TASK_WS_SET 
                (PROJECT_ID, WORK_ID, CREATED_BY, CREATED_DATE)
            VALUES 
                (@project_id, @work_id, @updated_by, GETDATE());
            
            SET @ws_set_id = SCOPE_IDENTITY();
        END
        ELSE
        BEGIN
            -- Güncelleme tarihi
            UPDATE workcube_prod.PRJ_TASK_WS_SET
            SET UPDATED_BY = @updated_by, UPDATED_DATE = GETDATE()
            WHERE WS_SET_ID = @ws_set_id;
        END
        
        -- Kaldırılan istasyonları bul
        CREATE TABLE #RemovedWorkstations (
            workstation_code NVARCHAR(50) COLLATE Turkish_CI_AS
        );
        
        INSERT INTO #RemovedWorkstations (workstation_code)
        SELECT WSR.WORKSTATION_CODE
        FROM workcube_prod.PRJ_TASK_WS_SET_ROW WSR
        WHERE WSR.WS_SET_ID = @ws_set_id
          AND WSR.WORKSTATION_CODE NOT IN (SELECT code FROM #NewWorkstations);
        
        -- Yeni eklenen istasyonları bul
        CREATE TABLE #AddedWorkstations (
            workstation_code NVARCHAR(50) COLLATE Turkish_CI_AS
        );
        
        INSERT INTO #AddedWorkstations (workstation_code)
        SELECT NW.code
        FROM #NewWorkstations NW
        WHERE NW.code NOT IN (
            SELECT WSR.WORKSTATION_CODE 
            FROM workcube_prod.PRJ_TASK_WS_SET_ROW WSR 
            WHERE WSR.WS_SET_ID = @ws_set_id
        );
        
        -- Instance varsa, kaldırılan istasyonların hücrelerini sil
        IF @instance_id IS NOT NULL AND EXISTS (SELECT 1 FROM #RemovedWorkstations)
        BEGIN
            DELETE CV
            FROM workcube_prod.PRJ_TASK_MATRIX_CELL_VALUE CV
            INNER JOIN workcube_prod.PRJ_TASK_MATRIX_CELL_DEF CD ON CV.CELL_DEF_ID = CD.CELL_DEF_ID
            INNER JOIN workcube_prod.PRJ_TASK_MATRIX_DIM D ON CD.STAGE_DIM_ID = D.DIM_ID
            INNER JOIN #RemovedWorkstations RW ON D.DIM_CODE = RW.workstation_code
            WHERE CV.INSTANCE_ID = @instance_id;
        END
        
        -- Mevcut satırları sil
        DELETE FROM workcube_prod.PRJ_TASK_WS_SET_ROW WHERE WS_SET_ID = @ws_set_id;
        
        -- Yeni satırları ekle
        INSERT INTO workcube_prod.PRJ_TASK_WS_SET_ROW 
            (WS_SET_ID, WORKSTATION_ID, WORKSTATION_CODE, WORKSTATION_NAME, SORT_ORDER)
        SELECT 
            @ws_set_id,
            workstation_id,
            code,
            name,
            sort_order
        FROM #NewWorkstations;
        
        -- Instance varsa, yeni eklenen istasyonların hücrelerini oluştur (MERGE ile)
        IF @instance_id IS NOT NULL AND EXISTS (SELECT 1 FROM #AddedWorkstations)
        BEGIN
            MERGE INTO workcube_prod.PRJ_TASK_MATRIX_CELL_VALUE AS target
            USING (
                SELECT DISTINCT @instance_id AS INSTANCE_ID, CD.CELL_DEF_ID
                FROM workcube_prod.PRJ_TASK_MATRIX_CELL_DEF CD
                INNER JOIN workcube_prod.PRJ_TASK_MATRIX_DIM D ON CD.STAGE_DIM_ID = D.DIM_ID
                INNER JOIN #AddedWorkstations AW ON D.DIM_CODE = AW.workstation_code COLLATE Turkish_CI_AS
                WHERE CD.TEMPLATE_ID = @template_id AND CD.IS_ACTIVE = 1
            ) AS source (INSTANCE_ID, CELL_DEF_ID)
            ON target.INSTANCE_ID = source.INSTANCE_ID AND target.CELL_DEF_ID = source.CELL_DEF_ID
            WHEN NOT MATCHED THEN
                INSERT (INSTANCE_ID, CELL_DEF_ID, VALUE_ID)
                VALUES (source.INSTANCE_ID, source.CELL_DEF_ID, NULL);
        END
        
        -- Instance varsa WS_SET_ID bağla
        IF @instance_id IS NOT NULL
        BEGIN
            UPDATE workcube_prod.PRJ_TASK_MATRIX_INSTANCE
            SET WS_SET_ID = @ws_set_id
            WHERE INSTANCE_ID = @instance_id AND (WS_SET_ID IS NULL OR WS_SET_ID <> @ws_set_id);
        END
        
        DROP TABLE #NewWorkstations;
        DROP TABLE #RemovedWorkstations;
        DROP TABLE #AddedWorkstations;
        
        COMMIT TRANSACTION;
        
        -- Sonuç döndür
        SELECT 
            1 AS success,
            @ws_set_id AS ws_set_id,
            @row_count AS row_count,
            @is_new AS is_new;
            
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        
        SELECT 
            0 AS success,
            0 AS ws_set_id,
            0 AS row_count,
            ERROR_MESSAGE() AS error_message;
    END CATCH
END
GO

PRINT 'sp_prj_task_ws_set_save güncellendi (istasyon ekleme/güncelleme desteği).';
GO
