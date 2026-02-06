-- ============================================
-- SIPARIŞ OPERASYON GÖREVLERİ - DDL V2
-- Tarih: 2026-01-22
-- Değişiklikler:
--   - WORKSTATION → STAGE isimlendirme
--   - REF_TYPE CHECK constraint
--   - Index'ler ayrı dosyada
--   - Notes/Docs/Time için yeni tablo YOK
-- ============================================

-- ============================================
-- 1. OPS_TASK - Ana Görev Tablosu
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'OPS_TASK' AND schema_id = SCHEMA_ID('workcube_prod'))
BEGIN
    CREATE TABLE workcube_prod.OPS_TASK (
        TASK_ID             INT IDENTITY(1,1) PRIMARY KEY,
        TASK_NO             NVARCHAR(50) COLLATE Turkish_CI_AS,
        TASK_HEAD           NVARCHAR(200) COLLATE Turkish_CI_AS NOT NULL,
        TASK_DETAIL         NVARCHAR(MAX) COLLATE Turkish_CI_AS,
        
        -- Referans: Faz-1'de sadece ORDER
        REF_TYPE            VARCHAR(20) NOT NULL,
        REF_ID              INT NOT NULL,
        
        -- CHECK constraint: Faz-1'de sadece ORDER kabul
        CONSTRAINT CK_OPS_TASK_REF_TYPE CHECK (REF_TYPE IN ('ORDER')),
        
        -- Üst görev (hiyerarşi)
        PARENT_TASK_ID      INT NULL,
        
        -- Atama
        ASSIGNED_EMP_ID     INT,
        ASSIGNED_TEAM_ID    INT,
        
        -- Tarihler
        PLANNED_START       DATETIME,
        PLANNED_FINISH      DATETIME,
        DEADLINE            DATETIME,
        ACTUAL_START        DATETIME,
        ACTUAL_FINISH       DATETIME,
        
        -- Süreler (dakika)
        ESTIMATED_MINUTES   INT DEFAULT 0,
        ACTUAL_MINUTES      INT DEFAULT 0,
        
        -- Durum ve ilerleme
        STATUS_ID           INT,                       -- NULL=Boş, 2361=Devam, 2364=Tamamlandı
        PRIORITY_ID         INT,
        PERCENT_COMPLETE    DECIMAL(5,2) DEFAULT 0,
        IS_ACTIVE           BIT DEFAULT 1,
        
        -- Matris (data-driven)
        HAS_MATRIX          BIT DEFAULT 0,
        MATRIX_TEMPLATE_ID  INT,
        
        -- Şirket
        COMPANY_ID          INT NOT NULL,
        BRANCH_ID           INT,
        
        -- Audit
        CREATED_BY          INT NOT NULL,
        CREATED_DATE        DATETIME DEFAULT GETDATE(),
        CREATED_IP          VARCHAR(50),
        UPDATED_BY          INT,
        UPDATED_DATE        DATETIME,
        UPDATED_IP          VARCHAR(50)
    );
    
    PRINT 'OPS_TASK tablosu oluşturuldu.';
END
ELSE
    PRINT 'OPS_TASK tablosu zaten mevcut.';
GO

-- ============================================
-- 2. OPS_TASK_STEP - İş Adımları
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'OPS_TASK_STEP' AND schema_id = SCHEMA_ID('workcube_prod'))
BEGIN
    CREATE TABLE workcube_prod.OPS_TASK_STEP (
        STEP_ID             INT IDENTITY(1,1) PRIMARY KEY,
        TASK_ID             INT NOT NULL,
        STEP_ORDER          INT DEFAULT 0,
        STEP_DESCRIPTION    NVARCHAR(500) COLLATE Turkish_CI_AS,
        ESTIMATED_HOUR      INT DEFAULT 0,
        ESTIMATED_MINUTE    INT DEFAULT 0,
        ACTUAL_HOUR         INT DEFAULT 0,
        ACTUAL_MINUTE       INT DEFAULT 0,
        IS_COMPLETE         BIT DEFAULT 0,
        
        CREATED_BY          INT,
        CREATED_DATE        DATETIME DEFAULT GETDATE(),
        UPDATED_BY          INT,
        UPDATED_DATE        DATETIME,
        
        CONSTRAINT FK_OPS_TASK_STEP_TASK FOREIGN KEY (TASK_ID) 
            REFERENCES workcube_prod.OPS_TASK(TASK_ID) ON DELETE CASCADE
    );
    
    PRINT 'OPS_TASK_STEP tablosu oluşturuldu.';
END
ELSE
    PRINT 'OPS_TASK_STEP tablosu zaten mevcut.';
GO

-- ============================================
-- 3. OPS_TASK_AUDIT - Audit Log
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'OPS_TASK_AUDIT' AND schema_id = SCHEMA_ID('workcube_prod'))
BEGIN
    CREATE TABLE workcube_prod.OPS_TASK_AUDIT (
        AUDIT_ID            INT IDENTITY(1,1) PRIMARY KEY,
        TASK_ID             INT NOT NULL,
        ACTION_TYPE         VARCHAR(20),        -- CREATE, UPDATE, DELETE, STATUS_CHANGE, MATRIX_SAVE
        OLD_VALUE           NVARCHAR(MAX) COLLATE Turkish_CI_AS,
        NEW_VALUE           NVARCHAR(MAX) COLLATE Turkish_CI_AS,
        FIELD_NAME          VARCHAR(50),
        
        CREATED_BY          INT,
        CREATED_DATE        DATETIME DEFAULT GETDATE(),
        CREATED_IP          VARCHAR(50)
    );
    
    PRINT 'OPS_TASK_AUDIT tablosu oluşturuldu.';
END
ELSE
    PRINT 'OPS_TASK_AUDIT tablosu zaten mevcut.';
GO

-- ============================================
-- 4. OPS_TASK_STAGE_SET - Stage Seçim Seti
-- NOT: "WORKSTATION" değil "STAGE" kullanılıyor
-- Kaynak: PRJ_TASK_MATRIX_DIM (DIM_TYPE='STAGE')
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'OPS_TASK_STAGE_SET' AND schema_id = SCHEMA_ID('workcube_prod'))
BEGIN
    CREATE TABLE workcube_prod.OPS_TASK_STAGE_SET (
        STAGE_SET_ID        INT IDENTITY(1,1) PRIMARY KEY,
        TASK_ID             INT NOT NULL,
        TEMPLATE_ID         INT NOT NULL,
        
        CREATED_DATE        DATETIME DEFAULT GETDATE(),
        UPDATED_DATE        DATETIME,
        
        CONSTRAINT FK_OPS_TASK_STAGE_SET_TASK FOREIGN KEY (TASK_ID) 
            REFERENCES workcube_prod.OPS_TASK(TASK_ID) ON DELETE CASCADE
    );
    
    PRINT 'OPS_TASK_STAGE_SET tablosu oluşturuldu.';
END
ELSE
    PRINT 'OPS_TASK_STAGE_SET tablosu zaten mevcut.';
GO

-- ============================================
-- 5. OPS_TASK_STAGE_SET_ROW - Seçili Stage'ler
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'OPS_TASK_STAGE_SET_ROW' AND schema_id = SCHEMA_ID('workcube_prod'))
BEGIN
    CREATE TABLE workcube_prod.OPS_TASK_STAGE_SET_ROW (
        STAGE_SET_ROW_ID    INT IDENTITY(1,1) PRIMARY KEY,
        STAGE_SET_ID        INT NOT NULL,
        STAGE_DIM_ID        INT NOT NULL,           -- PRJ_TASK_MATRIX_DIM.DIM_ID
        STAGE_CODE          NVARCHAR(50) COLLATE Turkish_CI_AS,
        STAGE_NAME          NVARCHAR(200) COLLATE Turkish_CI_AS,
        SORT_ORDER          INT DEFAULT 0,
        
        UPDATED_BY          INT,
        UPDATED_DATE        DATETIME,
        
        CONSTRAINT FK_OPS_TASK_STAGE_ROW_SET FOREIGN KEY (STAGE_SET_ID) 
            REFERENCES workcube_prod.OPS_TASK_STAGE_SET(STAGE_SET_ID) ON DELETE CASCADE
    );
    
    PRINT 'OPS_TASK_STAGE_SET_ROW tablosu oluşturuldu.';
END
ELSE
    PRINT 'OPS_TASK_STAGE_SET_ROW tablosu zaten mevcut.';
GO

-- ============================================
-- 6. OPS_TASK_MATRIX_INSTANCE - Matris Instance
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'OPS_TASK_MATRIX_INSTANCE' AND schema_id = SCHEMA_ID('workcube_prod'))
BEGIN
    CREATE TABLE workcube_prod.OPS_TASK_MATRIX_INSTANCE (
        INSTANCE_ID         INT IDENTITY(1,1) PRIMARY KEY,
        TASK_ID             INT NOT NULL,
        TEMPLATE_ID         INT NOT NULL,
        STAGE_SET_ID        INT,
        CALC_PERCENT        DECIMAL(5,2) DEFAULT 0,
        
        CREATED_DATE        DATETIME DEFAULT GETDATE(),
        UPDATED_DATE        DATETIME,
        
        CONSTRAINT FK_OPS_TASK_MATRIX_TASK FOREIGN KEY (TASK_ID) 
            REFERENCES workcube_prod.OPS_TASK(TASK_ID) ON DELETE CASCADE
    );
    
    PRINT 'OPS_TASK_MATRIX_INSTANCE tablosu oluşturuldu.';
END
ELSE
    PRINT 'OPS_TASK_MATRIX_INSTANCE tablosu zaten mevcut.';
GO

-- ============================================
-- 7. OPS_TASK_MATRIX_CELL_VALUE - Hücre Değerleri
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'OPS_TASK_MATRIX_CELL_VALUE' AND schema_id = SCHEMA_ID('workcube_prod'))
BEGIN
    CREATE TABLE workcube_prod.OPS_TASK_MATRIX_CELL_VALUE (
        CELL_VALUE_ID       INT IDENTITY(1,1) PRIMARY KEY,
        INSTANCE_ID         INT NOT NULL,
        CELL_DEF_ID         INT NOT NULL,           -- PRJ_TASK_MATRIX_CELL_DEF.CELL_DEF_ID
        VALUE_CODE          NVARCHAR(100) COLLATE Turkish_CI_AS,  -- Virgüllü: PLUS,STK
        
        UPDATED_BY          INT,
        UPDATED_DATE        DATETIME,
        
        CONSTRAINT FK_OPS_TASK_CELL_INSTANCE FOREIGN KEY (INSTANCE_ID) 
            REFERENCES workcube_prod.OPS_TASK_MATRIX_INSTANCE(INSTANCE_ID) ON DELETE CASCADE
    );
    
    PRINT 'OPS_TASK_MATRIX_CELL_VALUE tablosu oluşturuldu.';
END
ELSE
    PRINT 'OPS_TASK_MATRIX_CELL_VALUE tablosu zaten mevcut.';
GO

-- ============================================
-- ÖZET
-- ============================================
PRINT '';
PRINT '============================================';
PRINT 'OPS_TASK DDL V2 TAMAMLANDI';
PRINT '============================================';
PRINT 'Tablolar:';
PRINT '  1. OPS_TASK                   - Ana görev (REF_TYPE CHECK ile)';
PRINT '  2. OPS_TASK_STEP              - İş adımları';
PRINT '  3. OPS_TASK_AUDIT             - Audit log';
PRINT '  4. OPS_TASK_STAGE_SET         - Stage seçim seti';
PRINT '  5. OPS_TASK_STAGE_SET_ROW     - Seçili stage''ler (STAGE_DIM_ID)';
PRINT '  6. OPS_TASK_MATRIX_INSTANCE   - Matris instance';
PRINT '  7. OPS_TASK_MATRIX_CELL_VALUE - Hücre değerleri';
PRINT '';
PRINT 'Widget entegrasyonu:';
PRINT '  - Notes: Mevcut NOTES tablosu (ACTION_SECTION=''OPS_TASK'')';
PRINT '  - Docs: Mevcut sipariş belge altyapısı';
PRINT '  - Time: Faz-2 (mevcut zaman modülüne entegre)';
PRINT '';
PRINT 'Sonraki adım: OPS_TASK_INDEX_V2.sql çalıştır';
PRINT '============================================';
GO
