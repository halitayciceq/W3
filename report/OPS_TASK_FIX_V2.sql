-- ============================================
-- OPS_TASK_MATRIX_INSTANCE - STAGE_SET_ID kolonu ekleme
-- V1'den V2'ye geçiş düzeltmesi
-- ============================================

-- 1. STAGE_SET_ID kolonu yoksa ekle
IF NOT EXISTS (
    SELECT * FROM sys.columns 
    WHERE object_id = OBJECT_ID('workcube_prod.OPS_TASK_MATRIX_INSTANCE') 
    AND name = 'STAGE_SET_ID'
)
BEGIN
    ALTER TABLE workcube_prod.OPS_TASK_MATRIX_INSTANCE 
    ADD STAGE_SET_ID INT NULL;
    
    PRINT 'STAGE_SET_ID kolonu eklendi.';
END
ELSE
    PRINT 'STAGE_SET_ID kolonu zaten mevcut.';
GO

-- 2. sp_ops_task_matrix_save'i yeniden oluştur
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_ops_task_matrix_save')
    DROP PROCEDURE workcube_prod.sp_ops_task_matrix_save;
GO

CREATE PROCEDURE workcube_prod.sp_ops_task_matrix_save
    @task_id INT,
    @cells_json NVARCHAR(MAX),
    @user_id INT,
    @user_ip VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @template_id INT;
    DECLARE @instance_id INT;
    DECLARE @stage_set_id INT;
    DECLARE @calc_percent DECIMAL(5,2);
    DECLARE @status_id INT;
    
    -- Template ID al
    SELECT @template_id = MATRIX_TEMPLATE_ID 
    FROM workcube_prod.OPS_TASK 
    WHERE TASK_ID = @task_id;
    
    -- STAGE_SET ID al
    SELECT @stage_set_id = STAGE_SET_ID 
    FROM workcube_prod.OPS_TASK_STAGE_SET 
    WHERE TASK_ID = @task_id AND TEMPLATE_ID = @template_id;
    
    -- Instance var mı kontrol et, yoksa oluştur
    SELECT @instance_id = INSTANCE_ID 
    FROM workcube_prod.OPS_TASK_MATRIX_INSTANCE 
    WHERE TASK_ID = @task_id AND TEMPLATE_ID = @template_id;
    
    IF @instance_id IS NULL
    BEGIN
        INSERT INTO workcube_prod.OPS_TASK_MATRIX_INSTANCE (TASK_ID, TEMPLATE_ID, STAGE_SET_ID, CREATED_DATE)
        VALUES (@task_id, @template_id, @stage_set_id, GETDATE());
        SET @instance_id = SCOPE_IDENTITY();
    END
    
    -- Temp table oluştur
    CREATE TABLE #TempCells (
        cell_def_id INT,
        value_code NVARCHAR(100) COLLATE Turkish_CI_AS
    );
    
    -- JSON'dan parse et
    INSERT INTO #TempCells (cell_def_id, value_code)
    SELECT 
        CAST(JSON_VALUE(value, '$.cell_def_id') AS INT),
        JSON_VALUE(value, '$.value_code')
    FROM OPENJSON(@cells_json);
    
    -- Mevcut hücreleri güncelle veya ekle
    MERGE workcube_prod.OPS_TASK_MATRIX_CELL_VALUE AS target
    USING #TempCells AS source
    ON target.INSTANCE_ID = @instance_id AND target.CELL_DEF_ID = source.cell_def_id
    WHEN MATCHED THEN
        UPDATE SET VALUE_CODE = source.value_code, UPDATED_BY = @user_id, UPDATED_DATE = GETDATE()
    WHEN NOT MATCHED THEN
        INSERT (INSTANCE_ID, CELL_DEF_ID, VALUE_CODE, UPDATED_BY, UPDATED_DATE)
        VALUES (@instance_id, source.cell_def_id, source.value_code, @user_id, GETDATE());
    
    DROP TABLE #TempCells;
    
    -- Yüzde hesapla (sadece PLUS değeri etkiler)
    DECLARE @sum_weight DECIMAL(10,2);
    DECLARE @plus_weight DECIMAL(10,2);
    
    SELECT 
        @sum_weight = ISNULL(SUM(CD.WEIGHT), 0),
        @plus_weight = ISNULL(SUM(CASE WHEN CV.VALUE_CODE LIKE '%PLUS%' THEN CD.WEIGHT ELSE 0 END), 0)
    FROM workcube_prod.PRJ_TASK_MATRIX_CELL_DEF CD
    INNER JOIN workcube_prod.OPS_TASK_STAGE_SET_ROW SSR ON CD.STAGE_DIM_ID = SSR.STAGE_DIM_ID
    INNER JOIN workcube_prod.OPS_TASK_STAGE_SET SS ON SSR.STAGE_SET_ID = SS.STAGE_SET_ID AND SS.TASK_ID = @task_id
    LEFT JOIN workcube_prod.OPS_TASK_MATRIX_CELL_VALUE CV ON CD.CELL_DEF_ID = CV.CELL_DEF_ID AND CV.INSTANCE_ID = @instance_id
    WHERE CD.TEMPLATE_ID = @template_id AND CD.IS_ACTIVE = 1;
    
    IF @sum_weight > 0
        SET @calc_percent = ROUND((@plus_weight / @sum_weight) * 100, 0);
    ELSE
        SET @calc_percent = 0;
    
    -- Instance güncelle
    UPDATE workcube_prod.OPS_TASK_MATRIX_INSTANCE 
    SET CALC_PERCENT = @calc_percent, UPDATED_DATE = GETDATE()
    WHERE INSTANCE_ID = @instance_id;
    
    -- Aşama otomasyonu
    IF @calc_percent = 0
        SET @status_id = NULL;
    ELSE IF @calc_percent > 0 AND @calc_percent < 100
        SET @status_id = 2361;  -- Devam Ediyor
    ELSE
        SET @status_id = 2364;  -- Tamamlandı
    
    -- Ana görev güncelle
    UPDATE workcube_prod.OPS_TASK 
    SET 
        PERCENT_COMPLETE = @calc_percent,
        STATUS_ID = @status_id,
        UPDATED_BY = @user_id,
        UPDATED_DATE = GETDATE()
    WHERE TASK_ID = @task_id;
    
    -- Audit log
    INSERT INTO workcube_prod.OPS_TASK_AUDIT (TASK_ID, ACTION_TYPE, NEW_VALUE, CREATED_BY, CREATED_DATE, CREATED_IP)
    VALUES (@task_id, 'MATRIX_SAVE', CAST(@calc_percent AS NVARCHAR) + '%', @user_id, GETDATE(), @user_ip);
    
    SELECT @instance_id AS instance_id, @calc_percent AS calc_percent, @status_id AS status_id;
END
GO

PRINT 'sp_ops_task_matrix_save düzeltildi.';
GO
