-- ============================================
-- SIPARIŞ OPERASYON GÖREVLERİ - STORED PROCEDURES
-- Tarih: 2026-01-22
-- Versiyon: 1.0
-- ============================================

-- ============================================
-- 1. sp_ops_task_list - Görev Listesi
-- ============================================

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_ops_task_list')
    DROP PROCEDURE workcube_prod.sp_ops_task_list;
GO

CREATE PROCEDURE workcube_prod.sp_ops_task_list
    @ref_type VARCHAR(20),
    @ref_id INT,
    @company_id INT,
    @status_id INT = NULL,
    @assigned_emp_id INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        T.TASK_ID,
        T.TASK_NO,
        T.TASK_HEAD,
        T.REF_TYPE,
        T.REF_ID,
        T.ASSIGNED_EMP_ID,
        E.EMPLOYEE_NAME + ' ' + E.EMPLOYEE_SURNAME AS ASSIGNED_NAME,
        E.EMPLOYEE_NAME,
        E.EMPLOYEE_SURNAME,
        T.PLANNED_START,
        T.PLANNED_FINISH,
        T.DEADLINE,
        T.ESTIMATED_MINUTES,
        T.ACTUAL_MINUTES,
        T.STATUS_ID,
        PS.STAGE AS STATUS_NAME,
        T.PRIORITY_ID,
        T.PERCENT_COMPLETE,
        T.HAS_MATRIX,
        T.MATRIX_TEMPLATE_ID,
        T.IS_ACTIVE,
        T.CREATED_DATE,
        T.CREATED_BY
    FROM 
        workcube_prod.OPS_TASK T
        LEFT JOIN workcube_prod.EMPLOYEES E ON T.ASSIGNED_EMP_ID = E.EMPLOYEE_ID
        LEFT JOIN workcube_prod.PROCESS_STAGE PS ON T.STATUS_ID = PS.PROCESS_ROW_ID
    WHERE 
        T.REF_TYPE = @ref_type
        AND T.REF_ID = @ref_id
        AND T.COMPANY_ID = @company_id
        AND (@status_id IS NULL OR T.STATUS_ID = @status_id)
        AND (@assigned_emp_id IS NULL OR T.ASSIGNED_EMP_ID = @assigned_emp_id)
    ORDER BY 
        T.CREATED_DATE DESC;
END
GO

PRINT 'sp_ops_task_list oluşturuldu.';
GO

-- ============================================
-- 2. sp_ops_task_get - Görev Detayı
-- ============================================

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_ops_task_get')
    DROP PROCEDURE workcube_prod.sp_ops_task_get;
GO

CREATE PROCEDURE workcube_prod.sp_ops_task_get
    @task_id INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Ana görev bilgisi
    SELECT 
        T.*,
        E.EMPLOYEE_NAME + ' ' + E.EMPLOYEE_SURNAME AS ASSIGNED_NAME,
        PS.STAGE AS STATUS_NAME,
        PP.PRIORITY_HEAD AS PRIORITY_NAME
    FROM 
        workcube_prod.OPS_TASK T
        LEFT JOIN workcube_prod.EMPLOYEES E ON T.ASSIGNED_EMP_ID = E.EMPLOYEE_ID
        LEFT JOIN workcube_prod.PROCESS_STAGE PS ON T.STATUS_ID = PS.PROCESS_ROW_ID
        LEFT JOIN workcube_prod.PROCESS_PRIORITY PP ON T.PRIORITY_ID = PP.PRIORITY_ID
    WHERE 
        T.TASK_ID = @task_id;
    
    -- İş adımları
    SELECT 
        STEP_ID,
        TASK_ID,
        STEP_ORDER,
        STEP_DESCRIPTION,
        ESTIMATED_HOUR,
        ESTIMATED_MINUTE,
        ACTUAL_HOUR,
        ACTUAL_MINUTE,
        IS_COMPLETE
    FROM 
        workcube_prod.OPS_TASK_STEP
    WHERE 
        TASK_ID = @task_id
    ORDER BY 
        STEP_ORDER;
    
    -- Takip notları
    SELECT 
        N.NOTE_ID,
        N.TASK_ID,
        N.NOTE_TYPE,
        N.NOTE_CONTENT,
        N.CREATED_BY,
        N.CREATED_DATE,
        E.EMPLOYEE_NAME + ' ' + E.EMPLOYEE_SURNAME AS CREATED_BY_NAME
    FROM 
        workcube_prod.OPS_TASK_NOTE N
        LEFT JOIN workcube_prod.EMPLOYEES E ON N.CREATED_BY = E.EMPLOYEE_ID
    WHERE 
        N.TASK_ID = @task_id
    ORDER BY 
        N.CREATED_DATE DESC;
    
    -- Zaman harcaması toplamı
    SELECT 
        ISNULL(SUM((HOURS * 60) + MINUTES), 0) AS TOTAL_MINUTES
    FROM 
        workcube_prod.OPS_TASK_TIME
    WHERE 
        TASK_ID = @task_id;
END
GO

PRINT 'sp_ops_task_get oluşturuldu.';
GO

-- ============================================
-- 3. sp_ops_task_save - Görev Kaydet
-- ============================================

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_ops_task_save')
    DROP PROCEDURE workcube_prod.sp_ops_task_save;
GO

CREATE PROCEDURE workcube_prod.sp_ops_task_save
    @task_id INT = NULL,
    @task_no NVARCHAR(50) = NULL,
    @task_head NVARCHAR(200),
    @task_detail NVARCHAR(MAX) = NULL,
    @ref_type VARCHAR(20),
    @ref_id INT,
    @parent_task_id INT = NULL,
    @assigned_emp_id INT = NULL,
    @planned_start DATETIME = NULL,
    @planned_finish DATETIME = NULL,
    @deadline DATETIME = NULL,
    @estimated_minutes INT = 0,
    @status_id INT = NULL,
    @priority_id INT = NULL,
    @percent_complete DECIMAL(5,2) = 0,
    @has_matrix BIT = 0,
    @matrix_template_id INT = NULL,
    @company_id INT,
    @branch_id INT = NULL,
    @user_id INT,
    @user_ip VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @new_task_id INT;
    DECLARE @action_type VARCHAR(20);
    DECLARE @old_status INT;
    DECLARE @old_percent DECIMAL(5,2);
    
    -- Aşama otomasyonu: % değerine göre status belirle
    IF @status_id IS NULL
    BEGIN
        IF @percent_complete = 0
            SET @status_id = NULL;  -- Boş
        ELSE IF @percent_complete > 0 AND @percent_complete < 100
            SET @status_id = 2361;  -- Devam Ediyor
        ELSE IF @percent_complete >= 100
            SET @status_id = 2364;  -- Tamamlandı
    END
    
    IF @task_id IS NULL OR @task_id = 0
    BEGIN
        -- INSERT
        SET @action_type = 'CREATE';
        
        INSERT INTO workcube_prod.OPS_TASK (
            TASK_NO, TASK_HEAD, TASK_DETAIL,
            REF_TYPE, REF_ID, PARENT_TASK_ID,
            ASSIGNED_EMP_ID, PLANNED_START, PLANNED_FINISH, DEADLINE,
            ESTIMATED_MINUTES, STATUS_ID, PRIORITY_ID, PERCENT_COMPLETE,
            HAS_MATRIX, MATRIX_TEMPLATE_ID,
            COMPANY_ID, BRANCH_ID,
            CREATED_BY, CREATED_DATE, CREATED_IP
        )
        VALUES (
            @task_no, @task_head, @task_detail,
            @ref_type, @ref_id, @parent_task_id,
            @assigned_emp_id, @planned_start, @planned_finish, @deadline,
            @estimated_minutes, @status_id, @priority_id, @percent_complete,
            @has_matrix, @matrix_template_id,
            @company_id, @branch_id,
            @user_id, GETDATE(), @user_ip
        );
        
        SET @new_task_id = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        -- UPDATE
        SET @action_type = 'UPDATE';
        SET @new_task_id = @task_id;
        
        -- Eski değerleri al (audit için)
        SELECT @old_status = STATUS_ID, @old_percent = PERCENT_COMPLETE
        FROM workcube_prod.OPS_TASK WHERE TASK_ID = @task_id;
        
        UPDATE workcube_prod.OPS_TASK
        SET 
            TASK_NO = @task_no,
            TASK_HEAD = @task_head,
            TASK_DETAIL = @task_detail,
            PARENT_TASK_ID = @parent_task_id,
            ASSIGNED_EMP_ID = @assigned_emp_id,
            PLANNED_START = @planned_start,
            PLANNED_FINISH = @planned_finish,
            DEADLINE = @deadline,
            ESTIMATED_MINUTES = @estimated_minutes,
            STATUS_ID = @status_id,
            PRIORITY_ID = @priority_id,
            PERCENT_COMPLETE = @percent_complete,
            HAS_MATRIX = @has_matrix,
            MATRIX_TEMPLATE_ID = @matrix_template_id,
            UPDATED_BY = @user_id,
            UPDATED_DATE = GETDATE(),
            UPDATED_IP = @user_ip
        WHERE 
            TASK_ID = @task_id;
        
        -- Durum değişikliği varsa audit'e yaz
        IF @old_status <> @status_id OR @old_percent <> @percent_complete
        BEGIN
            INSERT INTO workcube_prod.OPS_TASK_AUDIT 
                (TASK_ID, ACTION_TYPE, FIELD_NAME, OLD_VALUE, NEW_VALUE, CREATED_BY, CREATED_DATE, CREATED_IP)
            VALUES 
                (@task_id, 'STATUS_CHANGE', 'STATUS_ID', CAST(@old_status AS NVARCHAR), CAST(@status_id AS NVARCHAR), @user_id, GETDATE(), @user_ip);
        END
    END
    
    -- Audit log
    INSERT INTO workcube_prod.OPS_TASK_AUDIT (TASK_ID, ACTION_TYPE, CREATED_BY, CREATED_DATE, CREATED_IP)
    VALUES (@new_task_id, @action_type, @user_id, GETDATE(), @user_ip);
    
    SELECT @new_task_id AS TASK_ID, @action_type AS ACTION_TYPE;
END
GO

PRINT 'sp_ops_task_save oluşturuldu.';
GO

-- ============================================
-- 4. sp_ops_task_delete - Görev Sil
-- ============================================

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_ops_task_delete')
    DROP PROCEDURE workcube_prod.sp_ops_task_delete;
GO

CREATE PROCEDURE workcube_prod.sp_ops_task_delete
    @task_id INT,
    @user_id INT,
    @user_ip VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Audit log (silmeden önce)
    INSERT INTO workcube_prod.OPS_TASK_AUDIT (TASK_ID, ACTION_TYPE, CREATED_BY, CREATED_DATE, CREATED_IP)
    VALUES (@task_id, 'DELETE', @user_id, GETDATE(), @user_ip);
    
    -- Cascade delete (FK ile otomatik silinir: step, note, time, doc, cc, ws_set, matrix)
    DELETE FROM workcube_prod.OPS_TASK WHERE TASK_ID = @task_id;
    
    SELECT @@ROWCOUNT AS DELETED_COUNT;
END
GO

PRINT 'sp_ops_task_delete oluşturuldu.';
GO

-- ============================================
-- 5. sp_ops_task_step_save - İş Adımları Kaydet
-- ============================================

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_ops_task_step_save')
    DROP PROCEDURE workcube_prod.sp_ops_task_step_save;
GO

CREATE PROCEDURE workcube_prod.sp_ops_task_step_save
    @task_id INT,
    @steps_json NVARCHAR(MAX),  -- JSON array: [{step_order, step_description, estimated_hour, estimated_minute, is_complete}]
    @user_id INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Mevcut adımları sil
    DELETE FROM workcube_prod.OPS_TASK_STEP WHERE TASK_ID = @task_id;
    
    -- JSON'dan yeni adımları ekle
    INSERT INTO workcube_prod.OPS_TASK_STEP (
        TASK_ID, STEP_ORDER, STEP_DESCRIPTION, 
        ESTIMATED_HOUR, ESTIMATED_MINUTE, IS_COMPLETE,
        CREATED_BY, CREATED_DATE
    )
    SELECT 
        @task_id,
        ISNULL(JSON_VALUE(value, '$.step_order'), ROW_NUMBER() OVER (ORDER BY (SELECT NULL))),
        JSON_VALUE(value, '$.step_description'),
        ISNULL(JSON_VALUE(value, '$.estimated_hour'), 0),
        ISNULL(JSON_VALUE(value, '$.estimated_minute'), 0),
        ISNULL(JSON_VALUE(value, '$.is_complete'), 0),
        @user_id,
        GETDATE()
    FROM OPENJSON(@steps_json);
    
    SELECT @@ROWCOUNT AS INSERTED_COUNT;
END
GO

PRINT 'sp_ops_task_step_save oluşturuldu.';
GO

-- ============================================
-- 6. sp_ops_task_note_save - Not Kaydet
-- ============================================

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_ops_task_note_save')
    DROP PROCEDURE workcube_prod.sp_ops_task_note_save;
GO

CREATE PROCEDURE workcube_prod.sp_ops_task_note_save
    @task_id INT,
    @note_content NVARCHAR(MAX),
    @note_type VARCHAR(20) = 'COMMENT',
    @user_id INT
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO workcube_prod.OPS_TASK_NOTE (
        TASK_ID, NOTE_TYPE, NOTE_CONTENT, CREATED_BY, CREATED_DATE
    )
    VALUES (
        @task_id, @note_type, @note_content, @user_id, GETDATE()
    );
    
    SELECT SCOPE_IDENTITY() AS NOTE_ID;
END
GO

PRINT 'sp_ops_task_note_save oluşturuldu.';
GO

-- ============================================
-- 7. sp_ops_task_time_save - Zaman Harcaması Kaydet
-- ============================================

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_ops_task_time_save')
    DROP PROCEDURE workcube_prod.sp_ops_task_time_save;
GO

CREATE PROCEDURE workcube_prod.sp_ops_task_time_save
    @task_id INT,
    @employee_id INT,
    @work_date DATE,
    @hours INT,
    @minutes INT,
    @description NVARCHAR(500) = NULL,
    @is_billable BIT = 1,
    @user_id INT
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO workcube_prod.OPS_TASK_TIME (
        TASK_ID, EMPLOYEE_ID, WORK_DATE, HOURS, MINUTES, 
        DESCRIPTION, IS_BILLABLE, CREATED_BY, CREATED_DATE
    )
    VALUES (
        @task_id, @employee_id, @work_date, @hours, @minutes,
        @description, @is_billable, @user_id, GETDATE()
    );
    
    -- Toplam harcanan süreyi güncelle
    DECLARE @total_minutes INT;
    SELECT @total_minutes = ISNULL(SUM((HOURS * 60) + MINUTES), 0)
    FROM workcube_prod.OPS_TASK_TIME WHERE TASK_ID = @task_id;
    
    UPDATE workcube_prod.OPS_TASK 
    SET ACTUAL_MINUTES = @total_minutes, UPDATED_DATE = GETDATE()
    WHERE TASK_ID = @task_id;
    
    SELECT SCOPE_IDENTITY() AS TIME_ID, @total_minutes AS TOTAL_MINUTES;
END
GO

PRINT 'sp_ops_task_time_save oluşturuldu.';
GO

-- ============================================
-- 8. sp_ops_task_matrix_get - Matris Getir
-- ============================================

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_ops_task_matrix_get')
    DROP PROCEDURE workcube_prod.sp_ops_task_matrix_get;
GO

CREATE PROCEDURE workcube_prod.sp_ops_task_matrix_get
    @task_id INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @template_id INT;
    DECLARE @ws_set_id INT;
    DECLARE @instance_id INT;
    
    -- Task'ın matris şablonunu al
    SELECT @template_id = MATRIX_TEMPLATE_ID 
    FROM workcube_prod.OPS_TASK 
    WHERE TASK_ID = @task_id;
    
    IF @template_id IS NULL
    BEGIN
        SELECT 'NO_TEMPLATE' AS result_type;
        RETURN;
    END
    
    -- WS_SET var mı kontrol et
    SELECT @ws_set_id = WS_SET_ID 
    FROM workcube_prod.OPS_TASK_WS_SET 
    WHERE TASK_ID = @task_id AND TEMPLATE_ID = @template_id;
    
    IF @ws_set_id IS NULL
    BEGIN
        -- İstasyon seçimi gerekiyor
        SELECT 'SELECT_WS' AS result_type;
        
        -- Tüm istasyonları döndür
        SELECT 
            DIM_ID AS workstation_id,
            DIM_CODE AS code,
            DIM_NAME AS name
        FROM workcube_prod.PRJ_TASK_MATRIX_DIM
        WHERE TEMPLATE_ID = @template_id AND DIM_TYPE = 'STAGE' AND IS_ACTIVE = 1
        ORDER BY SORT_ORDER;
        
        RETURN;
    END
    
    -- Matris instance var mı?
    SELECT @instance_id = INSTANCE_ID 
    FROM workcube_prod.OPS_TASK_MATRIX_INSTANCE 
    WHERE TASK_ID = @task_id AND TEMPLATE_ID = @template_id;
    
    -- result_type = MATRIX
    SELECT 'MATRIX' AS result_type, @instance_id AS instance_id, @ws_set_id AS ws_set_id;
    
    -- Template bilgisi
    SELECT TEMPLATE_ID, TEMPLATE_CODE, TEMPLATE_NAME 
    FROM workcube_prod.PRJ_TASK_MATRIX_TEMPLATE 
    WHERE TEMPLATE_ID = @template_id;
    
    -- Seçili istasyonlar (stages)
    SELECT 
        R.WS_SET_ROW_ID,
        R.WORKSTATION_ID,
        R.WORKSTATION_CODE AS code,
        R.WORKSTATION_NAME AS name,
        R.SORT_ORDER
    FROM workcube_prod.OPS_TASK_WS_SET_ROW R
    WHERE R.WS_SET_ID = @ws_set_id
    ORDER BY R.SORT_ORDER;
    
    -- Hücreler
    SELECT 
        CD.CELL_DEF_ID,
        CD.STAGE_DIM_ID,
        CD.SUB_STAGE_DIM_ID,
        CD.CELL_LABEL,
        CD.WEIGHT,
        CV.VALUE_CODE,
        SD.DIM_CODE AS stage_code,
        SSD.DIM_CODE AS sub_stage_code
    FROM workcube_prod.PRJ_TASK_MATRIX_CELL_DEF CD
    INNER JOIN workcube_prod.OPS_TASK_WS_SET_ROW WSR ON CD.STAGE_DIM_ID = WSR.WORKSTATION_ID
    INNER JOIN workcube_prod.OPS_TASK_WS_SET WS ON WSR.WS_SET_ID = WS.WS_SET_ID AND WS.TASK_ID = @task_id
    LEFT JOIN workcube_prod.PRJ_TASK_MATRIX_DIM SD ON CD.STAGE_DIM_ID = SD.DIM_ID
    LEFT JOIN workcube_prod.PRJ_TASK_MATRIX_DIM SSD ON CD.SUB_STAGE_DIM_ID = SSD.DIM_ID
    LEFT JOIN workcube_prod.OPS_TASK_MATRIX_CELL_VALUE CV ON CD.CELL_DEF_ID = CV.CELL_DEF_ID 
        AND CV.INSTANCE_ID = @instance_id
    WHERE CD.TEMPLATE_ID = @template_id AND CD.IS_ACTIVE = 1
    ORDER BY WSR.SORT_ORDER, CD.COL_INDEX;
    
    -- Değerler (buttons)
    SELECT VALUE_ID, VALUE_CODE, VALUE_LABEL, SCORE, COLOR_CODE, SORT_ORDER
    FROM workcube_prod.PRJ_TASK_MATRIX_VALUE
    WHERE TEMPLATE_ID = @template_id
    ORDER BY SORT_ORDER;
END
GO

PRINT 'sp_ops_task_matrix_get oluşturuldu.';
GO

-- ============================================
-- 9. sp_ops_task_matrix_save - Matris Kaydet
-- ============================================

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_ops_task_matrix_save')
    DROP PROCEDURE workcube_prod.sp_ops_task_matrix_save;
GO

CREATE PROCEDURE workcube_prod.sp_ops_task_matrix_save
    @task_id INT,
    @cells_json NVARCHAR(MAX),  -- JSON array: [{cell_def_id, value_code}]
    @user_id INT,
    @user_ip VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @template_id INT;
    DECLARE @instance_id INT;
    DECLARE @ws_set_id INT;
    DECLARE @calc_percent DECIMAL(5,2);
    DECLARE @status_id INT;
    
    -- Template ID al
    SELECT @template_id = MATRIX_TEMPLATE_ID 
    FROM workcube_prod.OPS_TASK 
    WHERE TASK_ID = @task_id;
    
    -- WS_SET ID al
    SELECT @ws_set_id = WS_SET_ID 
    FROM workcube_prod.OPS_TASK_WS_SET 
    WHERE TASK_ID = @task_id AND TEMPLATE_ID = @template_id;
    
    -- Instance var mı kontrol et, yoksa oluştur
    SELECT @instance_id = INSTANCE_ID 
    FROM workcube_prod.OPS_TASK_MATRIX_INSTANCE 
    WHERE TASK_ID = @task_id AND TEMPLATE_ID = @template_id;
    
    IF @instance_id IS NULL
    BEGIN
        INSERT INTO workcube_prod.OPS_TASK_MATRIX_INSTANCE (TASK_ID, TEMPLATE_ID, WS_SET_ID, CREATED_DATE)
        VALUES (@task_id, @template_id, @ws_set_id, GETDATE());
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
    INNER JOIN workcube_prod.OPS_TASK_WS_SET_ROW WSR ON CD.STAGE_DIM_ID = WSR.WORKSTATION_ID
    INNER JOIN workcube_prod.OPS_TASK_WS_SET WS ON WSR.WS_SET_ID = WS.WS_SET_ID AND WS.TASK_ID = @task_id
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

PRINT 'sp_ops_task_matrix_save oluşturuldu.';
GO

-- ============================================
-- 10. sp_ops_task_ws_list - İstasyon Listesi
-- ============================================

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_ops_task_ws_list')
    DROP PROCEDURE workcube_prod.sp_ops_task_ws_list;
GO

CREATE PROCEDURE workcube_prod.sp_ops_task_ws_list
    @template_id INT = 1
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        DIM_ID AS workstation_id,
        DIM_CODE AS code,
        DIM_NAME AS name
    FROM workcube_prod.PRJ_TASK_MATRIX_DIM
    WHERE TEMPLATE_ID = @template_id 
      AND DIM_TYPE = 'STAGE' 
      AND IS_ACTIVE = 1
    ORDER BY SORT_ORDER;
END
GO

PRINT 'sp_ops_task_ws_list oluşturuldu.';
GO

-- ============================================
-- 11. sp_ops_task_ws_save - İstasyon Seçimi Kaydet
-- ============================================

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_ops_task_ws_save')
    DROP PROCEDURE workcube_prod.sp_ops_task_ws_save;
GO

CREATE PROCEDURE workcube_prod.sp_ops_task_ws_save
    @task_id INT,
    @template_id INT,
    @workstations_json NVARCHAR(MAX),  -- JSON array: [{workstation_id, code, name}]
    @user_id INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ws_set_id INT;
    
    -- Mevcut WS_SET var mı?
    SELECT @ws_set_id = WS_SET_ID 
    FROM workcube_prod.OPS_TASK_WS_SET 
    WHERE TASK_ID = @task_id AND TEMPLATE_ID = @template_id;
    
    IF @ws_set_id IS NULL
    BEGIN
        -- Yeni WS_SET oluştur
        INSERT INTO workcube_prod.OPS_TASK_WS_SET (TASK_ID, TEMPLATE_ID, CREATED_DATE)
        VALUES (@task_id, @template_id, GETDATE());
        SET @ws_set_id = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        -- Mevcut satırları sil
        DELETE FROM workcube_prod.OPS_TASK_WS_SET_ROW WHERE WS_SET_ID = @ws_set_id;
        
        UPDATE workcube_prod.OPS_TASK_WS_SET SET UPDATED_DATE = GETDATE() WHERE WS_SET_ID = @ws_set_id;
    END
    
    -- JSON'dan istasyonları ekle
    INSERT INTO workcube_prod.OPS_TASK_WS_SET_ROW (
        WS_SET_ID, WORKSTATION_ID, WORKSTATION_CODE, WORKSTATION_NAME, SORT_ORDER, UPDATED_BY, UPDATED_DATE
    )
    SELECT 
        @ws_set_id,
        CAST(JSON_VALUE(value, '$.workstation_id') AS INT),
        JSON_VALUE(value, '$.code'),
        JSON_VALUE(value, '$.name'),
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)),
        @user_id,
        GETDATE()
    FROM OPENJSON(@workstations_json);
    
    -- Task'ı güncelle
    UPDATE workcube_prod.OPS_TASK 
    SET HAS_MATRIX = 1, MATRIX_TEMPLATE_ID = @template_id, UPDATED_DATE = GETDATE()
    WHERE TASK_ID = @task_id;
    
    SELECT @ws_set_id AS ws_set_id;
END
GO

PRINT 'sp_ops_task_ws_save oluşturuldu.';
GO

-- ============================================
-- ÖZET
-- ============================================
PRINT '';
PRINT '============================================';
PRINT 'OPS_TASK STORED PROCEDURES TAMAMLANDI';
PRINT '============================================';
PRINT 'Oluşturulan SP''ler:';
PRINT '  1.  sp_ops_task_list        - Görev listesi';
PRINT '  2.  sp_ops_task_get         - Görev detayı';
PRINT '  3.  sp_ops_task_save        - Görev kaydet';
PRINT '  4.  sp_ops_task_delete      - Görev sil';
PRINT '  5.  sp_ops_task_step_save   - İş adımları kaydet';
PRINT '  6.  sp_ops_task_note_save   - Not kaydet';
PRINT '  7.  sp_ops_task_time_save   - Zaman kaydet';
PRINT '  8.  sp_ops_task_matrix_get  - Matris getir';
PRINT '  9.  sp_ops_task_matrix_save - Matris kaydet';
PRINT ' 10.  sp_ops_task_ws_list     - İstasyon listesi';
PRINT ' 11.  sp_ops_task_ws_save     - İstasyon seçimi kaydet';
PRINT '';
PRINT 'NOT: Bu SP''ler mevcut proje görev SP''lerini ETKİLEMEZ.';
PRINT '============================================';
GO
