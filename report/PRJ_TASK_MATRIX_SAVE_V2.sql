/*
================================================================================
FIX: sp_prj_task_matrix_save - WS_SET varsa sadece seçilen istasyonlar için hesapla
Tarih: 2026-01-21

Sorun: Yüzde hesaplaması tüm CELL_VALUE kayıtlarını kullanıyor
Çözüm: WS_SET varsa sadece seçilen istasyonların hücrelerini hesapla
================================================================================
*/

USE workcube_prod;
GO

IF OBJECT_ID('workcube_prod.sp_prj_task_matrix_save', 'P') IS NOT NULL
    DROP PROCEDURE workcube_prod.sp_prj_task_matrix_save;
GO

CREATE PROCEDURE workcube_prod.sp_prj_task_matrix_save
    @project_id     INT,
    @work_id        INT,
    @template_code  NVARCHAR(50),
    @updated_by     INT,
    @json_values    NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    
    DECLARE @template_id INT, @instance_id INT, @ws_set_id INT;
    DECLARE @calc_percent DECIMAL(5,2);
    DECLARE @sum_weighted_score DECIMAL(10,2);
    DECLARE @sum_weighted_max DECIMAL(10,2);
    DECLARE @has_ws_set BIT = 0;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Template ID al
        SELECT @template_id = TEMPLATE_ID 
        FROM workcube_prod.PRJ_TASK_MATRIX_TEMPLATE 
        WHERE TEMPLATE_CODE = @template_code AND IS_ACTIVE = 1;
        
        IF @template_id IS NULL
        BEGIN
            RAISERROR('Template bulunamadı', 16, 1);
            RETURN;
        END
        
        -- WS_SET ID al (bu WORK_ID için)
        SELECT @ws_set_id = WS_SET_ID 
        FROM workcube_prod.PRJ_TASK_WS_SET 
        WHERE PROJECT_ID = @project_id AND WORK_ID = @work_id;
        
        IF @ws_set_id IS NOT NULL
            SET @has_ws_set = 1;
        
        -- Instance var mı kontrol et
        SELECT @instance_id = INSTANCE_ID 
        FROM workcube_prod.PRJ_TASK_MATRIX_INSTANCE 
        WHERE PROJECT_ID = @project_id AND WORK_ID = @work_id AND TEMPLATE_ID = @template_id;
        
        -- Yoksa oluştur
        IF @instance_id IS NULL
        BEGIN
            INSERT INTO workcube_prod.PRJ_TASK_MATRIX_INSTANCE 
                (TEMPLATE_ID, PROJECT_ID, WORK_ID, WS_SET_ID, CREATED_BY, STATUS)
            VALUES (@template_id, @project_id, @work_id, @ws_set_id, @updated_by, 'ACTIVE');
            
            SET @instance_id = SCOPE_IDENTITY();
            
            -- Hücre değerleri oluştur - TÜM HÜCRELER
            INSERT INTO workcube_prod.PRJ_TASK_MATRIX_CELL_VALUE (INSTANCE_ID, CELL_DEF_ID, VALUE_ID)
            SELECT @instance_id, CELL_DEF_ID, NULL
            FROM workcube_prod.PRJ_TASK_MATRIX_CELL_DEF
            WHERE TEMPLATE_ID = @template_id AND IS_ACTIVE = 1;
        END
        ELSE
        BEGIN
            -- Instance var, WS_SET_ID bağla (eğer NULL ise)
            IF @has_ws_set = 1
            BEGIN
                UPDATE workcube_prod.PRJ_TASK_MATRIX_INSTANCE
                SET WS_SET_ID = @ws_set_id
                WHERE INSTANCE_ID = @instance_id AND WS_SET_ID IS NULL;
            END
        END
        
        -- JSON parse ve güncelle (TEMP TABLE ile - Turkish collation)
        CREATE TABLE #JsonValues (
            cell_def_id INT,
            value_code NVARCHAR(20) COLLATE Turkish_CI_AS
        );
        
        INSERT INTO #JsonValues (cell_def_id, value_code)
        SELECT 
            CAST(JSON_VALUE(j.value, '$.cell_def_id') AS INT),
            ISNULL(JSON_VALUE(j.value, '$.value_code'), '')
        FROM OPENJSON(@json_values) j
        WHERE JSON_VALUE(j.value, '$.cell_def_id') IS NOT NULL;
        
        -- Hücre değerlerini güncelle
        UPDATE CV
        SET CV.VALUE_ID = CASE WHEN JV.value_code = '' THEN NULL ELSE VD.VALUE_ID END,
            CV.UPDATED_DATE = GETDATE(),
            CV.UPDATED_BY = @updated_by
        FROM workcube_prod.PRJ_TASK_MATRIX_CELL_VALUE CV
        INNER JOIN #JsonValues JV ON CV.CELL_DEF_ID = JV.cell_def_id
        LEFT JOIN workcube_prod.PRJ_TASK_MATRIX_VALUE_DICT VD ON VD.VALUE_CODE = JV.value_code AND VD.TEMPLATE_ID = @template_id AND JV.value_code <> ''
        WHERE CV.INSTANCE_ID = @instance_id;
        
        DROP TABLE #JsonValues;
        
        -- Yüzde hesapla (Sadece PLUS değerler sayılır)
        -- WS_SET varsa sadece seçilen istasyonların hücreleri hesaplanır
        IF @has_ws_set = 1
        BEGIN
            SELECT 
                @sum_weighted_score = ISNULL(SUM(CASE WHEN VD.VALUE_CODE = 'PLUS' THEN CD.WEIGHT ELSE 0 END), 0),
                @sum_weighted_max = ISNULL(SUM(CD.WEIGHT), 0)
            FROM workcube_prod.PRJ_TASK_MATRIX_CELL_VALUE CV
            INNER JOIN workcube_prod.PRJ_TASK_MATRIX_CELL_DEF CD ON CV.CELL_DEF_ID = CD.CELL_DEF_ID
            INNER JOIN workcube_prod.PRJ_TASK_MATRIX_DIM D ON CD.STAGE_DIM_ID = D.DIM_ID
            INNER JOIN workcube_prod.PRJ_TASK_WS_SET_ROW WSR ON D.DIM_CODE = WSR.WORKSTATION_CODE AND WSR.WS_SET_ID = @ws_set_id
            LEFT JOIN workcube_prod.PRJ_TASK_MATRIX_VALUE_DICT VD ON CV.VALUE_ID = VD.VALUE_ID
            WHERE CV.INSTANCE_ID = @instance_id AND CD.IS_ACTIVE = 1;
        END
        ELSE
        BEGIN
            SELECT 
                @sum_weighted_score = ISNULL(SUM(CASE WHEN VD.VALUE_CODE = 'PLUS' THEN CD.WEIGHT ELSE 0 END), 0),
                @sum_weighted_max = ISNULL(SUM(CD.WEIGHT), 0)
            FROM workcube_prod.PRJ_TASK_MATRIX_CELL_VALUE CV
            INNER JOIN workcube_prod.PRJ_TASK_MATRIX_CELL_DEF CD ON CV.CELL_DEF_ID = CD.CELL_DEF_ID
            LEFT JOIN workcube_prod.PRJ_TASK_MATRIX_VALUE_DICT VD ON CV.VALUE_ID = VD.VALUE_ID
            WHERE CV.INSTANCE_ID = @instance_id AND CD.IS_ACTIVE = 1;
        END
        
        IF @sum_weighted_max > 0
            SET @calc_percent = (@sum_weighted_score / @sum_weighted_max) * 100;
        ELSE
            SET @calc_percent = 0;
        
        IF @calc_percent < 0 SET @calc_percent = 0;
        IF @calc_percent > 100 SET @calc_percent = 100;
        
        -- Instance güncelle
        UPDATE workcube_prod.PRJ_TASK_MATRIX_INSTANCE
        SET CALC_PERCENT = @calc_percent,
            UPDATED_DATE = GETDATE(),
            UPDATED_BY = @updated_by
        WHERE INSTANCE_ID = @instance_id;
        
        -- PRO_WORKS.TO_COMPLETE güncelle
        -- %0 = boş (NULL), %1-99 = Başlandı-Devam (2361), %100 = Tamamlandı (2364)
        IF @calc_percent >= 100
        BEGIN
            UPDATE workcube_prod.PRO_WORKS
            SET TO_COMPLETE = @calc_percent,
                WORK_CURRENCY_ID = 2364  -- Tamamlandı aşaması
            WHERE WORK_ID = @work_id;
        END
        ELSE IF @calc_percent > 0
        BEGIN
            UPDATE workcube_prod.PRO_WORKS
            SET TO_COMPLETE = @calc_percent,
                WORK_CURRENCY_ID = 2361  -- Başlandı - Devam aşaması
            WHERE WORK_ID = @work_id;
        END
        ELSE
        BEGIN
            UPDATE workcube_prod.PRO_WORKS
            SET TO_COMPLETE = 0,
                WORK_CURRENCY_ID = NULL  -- Boş (-)
            WHERE WORK_ID = @work_id;
        END
        
        -- Audit log
        INSERT INTO workcube_prod.PRJ_TASK_MATRIX_AUDIT 
            (INSTANCE_ID, ACTION_TYPE, ACTION_BY, ACTION_DATE, NEW_PERCENT)
        VALUES 
            (@instance_id, 'SAVE', @updated_by, GETDATE(), @calc_percent);
        
        COMMIT TRANSACTION;
        
        -- Sonuç döndür
        SELECT 
            1 AS success,
            @calc_percent AS calc_percent,
            @instance_id AS instance_id,
            @ws_set_id AS ws_set_id;
            
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        
        SELECT 
            0 AS success,
            0 AS calc_percent,
            ERROR_MESSAGE() AS error_message;
    END CATCH
END
GO

PRINT 'sp_prj_task_matrix_save güncellendi (WS_SET varsa sadece seçilen istasyonlar için hesapla).';
GO
