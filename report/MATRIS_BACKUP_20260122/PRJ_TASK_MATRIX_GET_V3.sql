/*
================================================================================
FIX: sp_prj_task_matrix_get - Geriye uyumluluk (WS_SET olmadan da çalışmalı)
Tarih: 2026-01-21

Sorun: WS_SET olmadan eski instance'lar için değerler kaydediliyor ama yüklenmiyor
Çözüm: WS_SET yoksa tüm CELL_VALUE kayıtlarını döndür
================================================================================
*/

USE workcube_prod;
GO

IF OBJECT_ID('workcube_prod.sp_prj_task_matrix_get', 'P') IS NOT NULL
    DROP PROCEDURE workcube_prod.sp_prj_task_matrix_get;
GO

CREATE PROCEDURE workcube_prod.sp_prj_task_matrix_get
    @project_id     INT,
    @work_id        INT,
    @template_code  NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @template_id INT, @instance_id INT, @ws_set_id INT;
    DECLARE @has_ws_set BIT = 0;
    
    -- Template ID al
    SELECT @template_id = TEMPLATE_ID 
    FROM workcube_prod.PRJ_TASK_MATRIX_TEMPLATE 
    WHERE TEMPLATE_CODE = @template_code AND IS_ACTIVE = 1;
    
    IF @template_id IS NULL
    BEGIN
        SELECT 'ERROR' AS result_type, 'Template bulunamadı' AS message;
        RETURN;
    END
    
    -- WS_SET var mı kontrol et (bu WORK_ID için)
    SELECT @ws_set_id = WS_SET_ID 
    FROM workcube_prod.PRJ_TASK_WS_SET 
    WHERE PROJECT_ID = @project_id AND WORK_ID = @work_id;
    
    IF @ws_set_id IS NOT NULL
        SET @has_ws_set = 1;
    
    -- WS_SET yoksa SELECT_WS modu döndür (istasyon seçimi gerekli)
    IF @has_ws_set = 0
    BEGIN
        -- Resultset 1: Mod bilgisi
        SELECT 'SELECT_WS' AS result_type, 'İstasyon seçimi gerekli' AS message;
        
        -- Resultset 2-6: Boş resultset'ler (ColdFusion uyumluluğu için)
        SELECT NULL AS TEMPLATE_ID, NULL AS TEMPLATE_CODE, NULL AS TEMPLATE_NAME, NULL AS INSTANCE_ID, NULL AS CALC_PERCENT, NULL AS WS_SET_ID WHERE 1=0;
        SELECT NULL AS DIM_ID, NULL AS DIM_CODE, NULL AS DIM_NAME, NULL AS SORT_ORDER, NULL AS WORKSTATION_ID WHERE 1=0;
        SELECT NULL AS DIM_ID, NULL AS DIM_CODE, NULL AS DIM_NAME, NULL AS PARENT_DIM_ID, NULL AS SORT_ORDER WHERE 1=0;
        SELECT NULL AS CELL_DEF_ID, NULL AS STAGE_DIM_ID, NULL AS SUB_STAGE_DIM_ID, NULL AS ROW_INDEX, NULL AS COL_INDEX, NULL AS CELL_LABEL, NULL AS WEIGHT, NULL AS CELL_VALUE_ID, NULL AS VALUE_ID, NULL AS VALUE_CODE, NULL AS VALUE_LABEL, NULL AS SCORE, NULL AS COLOR_CODE WHERE 1=0;
        SELECT NULL AS VALUE_ID, NULL AS VALUE_CODE, NULL AS VALUE_LABEL, NULL AS SCORE, NULL AS COLOR_CODE, NULL AS SORT_ORDER WHERE 1=0;
        
        RETURN;
    END
    
    -- Instance var mı kontrol et
    SELECT @instance_id = INSTANCE_ID 
    FROM workcube_prod.PRJ_TASK_MATRIX_INSTANCE 
    WHERE PROJECT_ID = @project_id AND WORK_ID = @work_id AND TEMPLATE_ID = @template_id;
    
    -- Instance yoksa oluştur
    IF @instance_id IS NULL
    BEGIN
        INSERT INTO workcube_prod.PRJ_TASK_MATRIX_INSTANCE 
            (TEMPLATE_ID, PROJECT_ID, WORK_ID, WS_SET_ID, STATUS)
        VALUES (@template_id, @project_id, @work_id, @ws_set_id, 'ACTIVE');
        
        SET @instance_id = SCOPE_IDENTITY();
        
        -- Sadece seçili istasyonların hücrelerini oluştur
        INSERT INTO workcube_prod.PRJ_TASK_MATRIX_CELL_VALUE (INSTANCE_ID, CELL_DEF_ID, VALUE_ID)
        SELECT @instance_id, CD.CELL_DEF_ID, NULL
        FROM workcube_prod.PRJ_TASK_MATRIX_CELL_DEF CD
        INNER JOIN workcube_prod.PRJ_TASK_MATRIX_DIM D ON CD.STAGE_DIM_ID = D.DIM_ID
        INNER JOIN workcube_prod.PRJ_TASK_WS_SET_ROW WSR ON D.DIM_CODE = WSR.WORKSTATION_CODE AND WSR.WS_SET_ID = @ws_set_id
        WHERE CD.TEMPLATE_ID = @template_id AND CD.IS_ACTIVE = 1;
    END
    ELSE
    BEGIN
        -- Instance var, WS_SET_ID bağla (eğer NULL ise ve WS_SET varsa)
        UPDATE workcube_prod.PRJ_TASK_MATRIX_INSTANCE
        SET WS_SET_ID = @ws_set_id
        WHERE INSTANCE_ID = @instance_id AND (WS_SET_ID IS NULL OR WS_SET_ID <> @ws_set_id);
    END
    
    -- Resultset 1: Mod bilgisi
    SELECT 'MATRIX' AS result_type, 'Matris verileri alındı' AS message;
    
    -- Resultset 2: Template bilgisi
    SELECT 
        T.TEMPLATE_ID,
        T.TEMPLATE_CODE,
        T.TEMPLATE_NAME,
        I.INSTANCE_ID,
        I.CALC_PERCENT,
        I.WS_SET_ID
    FROM workcube_prod.PRJ_TASK_MATRIX_TEMPLATE T
    INNER JOIN workcube_prod.PRJ_TASK_MATRIX_INSTANCE I ON T.TEMPLATE_ID = I.TEMPLATE_ID
    WHERE I.INSTANCE_ID = @instance_id;
    
    -- Resultset 3: Stages
    IF @has_ws_set = 1
    BEGIN
        -- Sadece seçilen istasyonlar
        SELECT 
            D.DIM_ID,
            D.DIM_CODE,
            D.DIM_NAME,
            D.SORT_ORDER,
            WSR.WORKSTATION_ID
        FROM workcube_prod.PRJ_TASK_MATRIX_DIM D
        INNER JOIN workcube_prod.PRJ_TASK_WS_SET_ROW WSR ON D.DIM_CODE = WSR.WORKSTATION_CODE AND WSR.WS_SET_ID = @ws_set_id
        WHERE D.TEMPLATE_ID = @template_id 
          AND D.DIM_TYPE = 'STAGE' 
          AND D.IS_ACTIVE = 1
        ORDER BY WSR.SORT_ORDER, D.SORT_ORDER;
    END
    ELSE
    BEGIN
        -- Tüm stages
        SELECT 
            D.DIM_ID,
            D.DIM_CODE,
            D.DIM_NAME,
            D.SORT_ORDER,
            NULL AS WORKSTATION_ID
        FROM workcube_prod.PRJ_TASK_MATRIX_DIM D
        WHERE D.TEMPLATE_ID = @template_id 
          AND D.DIM_TYPE = 'STAGE' 
          AND D.IS_ACTIVE = 1
        ORDER BY D.SORT_ORDER;
    END
    
    -- Resultset 4: Sub-stages
    IF @has_ws_set = 1
    BEGIN
        SELECT 
            D.DIM_ID,
            D.DIM_CODE,
            D.DIM_NAME,
            D.PARENT_DIM_ID,
            D.SORT_ORDER
        FROM workcube_prod.PRJ_TASK_MATRIX_DIM D
        INNER JOIN workcube_prod.PRJ_TASK_MATRIX_DIM PD ON D.PARENT_DIM_ID = PD.DIM_ID
        INNER JOIN workcube_prod.PRJ_TASK_WS_SET_ROW WSR ON PD.DIM_CODE = WSR.WORKSTATION_CODE AND WSR.WS_SET_ID = @ws_set_id
        WHERE D.TEMPLATE_ID = @template_id 
          AND D.DIM_TYPE = 'SUB_STAGE' 
          AND D.IS_ACTIVE = 1
        ORDER BY D.PARENT_DIM_ID, D.SORT_ORDER;
    END
    ELSE
    BEGIN
        SELECT 
            D.DIM_ID,
            D.DIM_CODE,
            D.DIM_NAME,
            D.PARENT_DIM_ID,
            D.SORT_ORDER
        FROM workcube_prod.PRJ_TASK_MATRIX_DIM D
        WHERE D.TEMPLATE_ID = @template_id 
          AND D.DIM_TYPE = 'SUB_STAGE' 
          AND D.IS_ACTIVE = 1
        ORDER BY D.PARENT_DIM_ID, D.SORT_ORDER;
    END
    
    -- Resultset 5: Cells with values
    IF @has_ws_set = 1
    BEGIN
        -- Sadece seçilen istasyonların hücreleri
        SELECT 
            CD.CELL_DEF_ID,
            CD.STAGE_DIM_ID,
            CD.SUB_STAGE_DIM_ID,
            CD.ROW_INDEX,
            CD.COL_INDEX,
            CD.CELL_LABEL,
            CD.WEIGHT,
            CV.CELL_VALUE_ID,
            CV.VALUE_ID,
            VD.VALUE_CODE,
            VD.VALUE_LABEL,
            VD.SCORE,
            VD.COLOR_CODE
        FROM workcube_prod.PRJ_TASK_MATRIX_CELL_DEF CD
        INNER JOIN workcube_prod.PRJ_TASK_MATRIX_DIM D ON CD.STAGE_DIM_ID = D.DIM_ID
        INNER JOIN workcube_prod.PRJ_TASK_WS_SET_ROW WSR ON D.DIM_CODE = WSR.WORKSTATION_CODE AND WSR.WS_SET_ID = @ws_set_id
        LEFT JOIN workcube_prod.PRJ_TASK_MATRIX_CELL_VALUE CV ON CD.CELL_DEF_ID = CV.CELL_DEF_ID AND CV.INSTANCE_ID = @instance_id
        LEFT JOIN workcube_prod.PRJ_TASK_MATRIX_VALUE_DICT VD ON CV.VALUE_ID = VD.VALUE_ID
        WHERE CD.TEMPLATE_ID = @template_id AND CD.IS_ACTIVE = 1
        ORDER BY WSR.SORT_ORDER, CD.ROW_INDEX, CD.COL_INDEX;
    END
    ELSE
    BEGIN
        -- Tüm hücreler - CELL_VALUE ile JOIN
        SELECT 
            CD.CELL_DEF_ID,
            CD.STAGE_DIM_ID,
            CD.SUB_STAGE_DIM_ID,
            CD.ROW_INDEX,
            CD.COL_INDEX,
            CD.CELL_LABEL,
            CD.WEIGHT,
            CV.CELL_VALUE_ID,
            CV.VALUE_ID,
            VD.VALUE_CODE,
            VD.VALUE_LABEL,
            VD.SCORE,
            VD.COLOR_CODE
        FROM workcube_prod.PRJ_TASK_MATRIX_CELL_DEF CD
        LEFT JOIN workcube_prod.PRJ_TASK_MATRIX_CELL_VALUE CV ON CD.CELL_DEF_ID = CV.CELL_DEF_ID AND CV.INSTANCE_ID = @instance_id
        LEFT JOIN workcube_prod.PRJ_TASK_MATRIX_VALUE_DICT VD ON CV.VALUE_ID = VD.VALUE_ID
        WHERE CD.TEMPLATE_ID = @template_id AND CD.IS_ACTIVE = 1
        ORDER BY CD.STAGE_DIM_ID, CD.ROW_INDEX, CD.COL_INDEX;
    END
    
    -- Resultset 6: Value dictionary
    SELECT 
        VALUE_ID,
        VALUE_CODE,
        VALUE_LABEL,
        SCORE,
        COLOR_CODE,
        SORT_ORDER
    FROM workcube_prod.PRJ_TASK_MATRIX_VALUE_DICT
    WHERE TEMPLATE_ID = @template_id AND IS_ACTIVE = 1
    ORDER BY SORT_ORDER;
END
GO

PRINT 'sp_prj_task_matrix_get güncellendi (geriye uyumluluk - WS_SET olmadan da çalışır).';
GO
