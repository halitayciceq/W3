-- ============================================
-- SIPARIŞ OPERASYON GÖREVLERİ - DDL SCRIPT
-- Tarih: 2026-01-22
-- Versiyon: 1.0
-- Mimari: Genelleştirilmiş Görev Motoru (REF_TYPE/REF_ID)
-- ============================================

-- ============================================
-- 1. ANA TABLO: OPS_TASK
-- ============================================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'OPS_TASK' AND schema_id = SCHEMA_ID('workcube_prod'))
BEGIN
    CREATE TABLE workcube_prod.OPS_TASK (
        TASK_ID             INT IDENTITY(1,1) PRIMARY KEY,
        TASK_NO             NVARCHAR(50),
        TASK_HEAD           NVARCHAR(200) NOT NULL,
        TASK_DETAIL         NVARCHAR(MAX),
        
        -- Referans (Proje veya Sipariş)
        REF_TYPE            VARCHAR(20) NOT NULL,      -- 'PROJECT_WORK' | 'ORDER'
        REF_ID              INT NOT NULL,              -- WORK_ID veya ORDER_ID
        
        -- Üst görev (hiyerarşi)
        PARENT_TASK_ID      INT NULL,
        
        -- Atama
        ASSIGNED_EMP_ID     INT,                       -- Sorumlu çalışan
        ASSIGNED_TEAM_ID    INT,                       -- Sorumlu ekip
        
        -- Tarihler
        PLANNED_START       DATETIME,
        PLANNED_FINISH      DATETIME,
        DEADLINE            DATETIME,
        ACTUAL_START        DATETIME,
        ACTUAL_FINISH       DATETIME,
        
        -- Süreler (dakika cinsinden)
        ESTIMATED_MINUTES   INT DEFAULT 0,
        ACTUAL_MINUTES      INT DEFAULT 0,
        
        -- Durum ve ilerleme
        STATUS_ID           INT,                       -- Aşama (PROCESS_ROW_ID)
        PRIORITY_ID         INT,                       -- Öncelik
        PERCENT_COMPLETE    DECIMAL(5,2) DEFAULT 0,
        IS_ACTIVE           BIT DEFAULT 1,
        
        -- Matris bağlantısı
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

-- Index'ler
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_OPS_TASK_REF' AND object_id = OBJECT_ID('workcube_prod.OPS_TASK'))
    CREATE INDEX IX_OPS_TASK_REF ON workcube_prod.OPS_TASK (REF_TYPE, REF_ID);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_OPS_TASK_ASSIGNED' AND object_id = OBJECT_ID('workcube_prod.OPS_TASK'))
    CREATE INDEX IX_OPS_TASK_ASSIGNED ON workcube_prod.OPS_TASK (ASSIGNED_EMP_ID);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_OPS_TASK_STATUS' AND object_id = OBJECT_ID('workcube_prod.OPS_TASK'))
    CREATE INDEX IX_OPS_TASK_STATUS ON workcube_prod.OPS_TASK (STATUS_ID);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_OPS_TASK_COMPANY' AND object_id = OBJECT_ID('workcube_prod.OPS_TASK'))
    CREATE INDEX IX_OPS_TASK_COMPANY ON workcube_prod.OPS_TASK (COMPANY_ID);
GO

-- ============================================
-- 2. İŞ ADIMLARI: OPS_TASK_STEP
-- ============================================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'OPS_TASK_STEP' AND schema_id = SCHEMA_ID('workcube_prod'))
BEGIN
    CREATE TABLE workcube_prod.OPS_TASK_STEP (
        STEP_ID             INT IDENTITY(1,1) PRIMARY KEY,
        TASK_ID             INT NOT NULL,
        STEP_ORDER          INT DEFAULT 0,
        STEP_DESCRIPTION    NVARCHAR(500),
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
    
    CREATE INDEX IX_OPS_TASK_STEP_TASK ON workcube_prod.OPS_TASK_STEP (TASK_ID);
    PRINT 'OPS_TASK_STEP tablosu oluşturuldu.';
END
ELSE
    PRINT 'OPS_TASK_STEP tablosu zaten mevcut.';
GO

-- ============================================
-- 3. TAKİP NOTLARI: OPS_TASK_NOTE
-- ============================================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'OPS_TASK_NOTE' AND schema_id = SCHEMA_ID('workcube_prod'))
BEGIN
    CREATE TABLE workcube_prod.OPS_TASK_NOTE (
        NOTE_ID             INT IDENTITY(1,1) PRIMARY KEY,
        TASK_ID             INT NOT NULL,
        NOTE_TYPE           VARCHAR(20) DEFAULT 'COMMENT',  -- 'COMMENT', 'SYSTEM', 'STATUS_CHANGE'
        NOTE_CONTENT        NVARCHAR(MAX),
        
        CREATED_BY          INT,
        CREATED_DATE        DATETIME DEFAULT GETDATE(),
        
        CONSTRAINT FK_OPS_TASK_NOTE_TASK FOREIGN KEY (TASK_ID) 
            REFERENCES workcube_prod.OPS_TASK(TASK_ID) ON DELETE CASCADE
    );
    
    CREATE INDEX IX_OPS_TASK_NOTE_TASK ON workcube_prod.OPS_TASK_NOTE (TASK_ID);
    PRINT 'OPS_TASK_NOTE tablosu oluşturuldu.';
END
ELSE
    PRINT 'OPS_TASK_NOTE tablosu zaten mevcut.';
GO

-- ============================================
-- 4. ZAMAN HARCAMASI: OPS_TASK_TIME
-- ============================================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'OPS_TASK_TIME' AND schema_id = SCHEMA_ID('workcube_prod'))
BEGIN
    CREATE TABLE workcube_prod.OPS_TASK_TIME (
        TIME_ID             INT IDENTITY(1,1) PRIMARY KEY,
        TASK_ID             INT NOT NULL,
        EMPLOYEE_ID         INT NOT NULL,
        WORK_DATE           DATE NOT NULL,
        HOURS               INT DEFAULT 0,
        MINUTES             INT DEFAULT 0,
        DESCRIPTION         NVARCHAR(500),
        IS_BILLABLE         BIT DEFAULT 1,
        
        CREATED_BY          INT,
        CREATED_DATE        DATETIME DEFAULT GETDATE(),
        UPDATED_BY          INT,
        UPDATED_DATE        DATETIME,
        
        CONSTRAINT FK_OPS_TASK_TIME_TASK FOREIGN KEY (TASK_ID) 
            REFERENCES workcube_prod.OPS_TASK(TASK_ID) ON DELETE CASCADE
    );
    
    CREATE INDEX IX_OPS_TASK_TIME_TASK ON workcube_prod.OPS_TASK_TIME (TASK_ID);
    CREATE INDEX IX_OPS_TASK_TIME_EMP ON workcube_prod.OPS_TASK_TIME (EMPLOYEE_ID);
    PRINT 'OPS_TASK_TIME tablosu oluşturuldu.';
END
ELSE
    PRINT 'OPS_TASK_TIME tablosu zaten mevcut.';
GO

-- ============================================
-- 5. BELGELER: OPS_TASK_DOC
-- ============================================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'OPS_TASK_DOC' AND schema_id = SCHEMA_ID('workcube_prod'))
BEGIN
    CREATE TABLE workcube_prod.OPS_TASK_DOC (
        DOC_ID              INT IDENTITY(1,1) PRIMARY KEY,
        TASK_ID             INT NOT NULL,
        DOC_NAME            NVARCHAR(200),
        DOC_PATH            NVARCHAR(500),
        DOC_TYPE            VARCHAR(50),
        DOC_SIZE            INT,
        
        CREATED_BY          INT,
        CREATED_DATE        DATETIME DEFAULT GETDATE(),
        
        CONSTRAINT FK_OPS_TASK_DOC_TASK FOREIGN KEY (TASK_ID) 
            REFERENCES workcube_prod.OPS_TASK(TASK_ID) ON DELETE CASCADE
    );
    
    CREATE INDEX IX_OPS_TASK_DOC_TASK ON workcube_prod.OPS_TASK_DOC (TASK_ID);
    PRINT 'OPS_TASK_DOC tablosu oluşturuldu.';
END
ELSE
    PRINT 'OPS_TASK_DOC tablosu zaten mevcut.';
GO

-- ============================================
-- 6. BİLGİ VERİLECEKLER: OPS_TASK_CC
-- ============================================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'OPS_TASK_CC' AND schema_id = SCHEMA_ID('workcube_prod'))
BEGIN
    CREATE TABLE workcube_prod.OPS_TASK_CC (
        CC_ID               INT IDENTITY(1,1) PRIMARY KEY,
        TASK_ID             INT NOT NULL,
        CC_EMP_ID           INT,
        CC_PAR_ID           INT,
        
        CREATED_DATE        DATETIME DEFAULT GETDATE(),
        
        CONSTRAINT FK_OPS_TASK_CC_TASK FOREIGN KEY (TASK_ID) 
            REFERENCES workcube_prod.OPS_TASK(TASK_ID) ON DELETE CASCADE
    );
    
    CREATE INDEX IX_OPS_TASK_CC_TASK ON workcube_prod.OPS_TASK_CC (TASK_ID);
    PRINT 'OPS_TASK_CC tablosu oluşturuldu.';
END
ELSE
    PRINT 'OPS_TASK_CC tablosu zaten mevcut.';
GO

-- ============================================
-- 7. İSTASYON SETLERİ: OPS_TASK_WS_SET
-- ============================================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'OPS_TASK_WS_SET' AND schema_id = SCHEMA_ID('workcube_prod'))
BEGIN
    CREATE TABLE workcube_prod.OPS_TASK_WS_SET (
        WS_SET_ID           INT IDENTITY(1,1) PRIMARY KEY,
        TASK_ID             INT NOT NULL,
        TEMPLATE_ID         INT NOT NULL,
        
        CREATED_DATE        DATETIME DEFAULT GETDATE(),
        UPDATED_DATE        DATETIME,
        
        CONSTRAINT FK_OPS_TASK_WS_SET_TASK FOREIGN KEY (TASK_ID) 
            REFERENCES workcube_prod.OPS_TASK(TASK_ID) ON DELETE CASCADE
    );
    
    CREATE INDEX IX_OPS_TASK_WS_SET_TASK ON workcube_prod.OPS_TASK_WS_SET (TASK_ID);
    PRINT 'OPS_TASK_WS_SET tablosu oluşturuldu.';
END
ELSE
    PRINT 'OPS_TASK_WS_SET tablosu zaten mevcut.';
GO

-- ============================================
-- 8. SEÇİLİ İSTASYONLAR: OPS_TASK_WS_SET_ROW
-- ============================================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'OPS_TASK_WS_SET_ROW' AND schema_id = SCHEMA_ID('workcube_prod'))
BEGIN
    CREATE TABLE workcube_prod.OPS_TASK_WS_SET_ROW (
        WS_SET_ROW_ID       INT IDENTITY(1,1) PRIMARY KEY,
        WS_SET_ID           INT NOT NULL,
        WORKSTATION_ID      INT NOT NULL,
        WORKSTATION_CODE    NVARCHAR(50),
        WORKSTATION_NAME    NVARCHAR(200),
        SORT_ORDER          INT DEFAULT 0,
        
        UPDATED_BY          INT,
        UPDATED_DATE        DATETIME,
        
        CONSTRAINT FK_OPS_TASK_WS_ROW_SET FOREIGN KEY (WS_SET_ID) 
            REFERENCES workcube_prod.OPS_TASK_WS_SET(WS_SET_ID) ON DELETE CASCADE
    );
    
    CREATE INDEX IX_OPS_TASK_WS_ROW_SET ON workcube_prod.OPS_TASK_WS_SET_ROW (WS_SET_ID);
    PRINT 'OPS_TASK_WS_SET_ROW tablosu oluşturuldu.';
END
ELSE
    PRINT 'OPS_TASK_WS_SET_ROW tablosu zaten mevcut.';
GO

-- ============================================
-- 9. MATRİS INSTANCE: OPS_TASK_MATRIX_INSTANCE
-- ============================================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'OPS_TASK_MATRIX_INSTANCE' AND schema_id = SCHEMA_ID('workcube_prod'))
BEGIN
    CREATE TABLE workcube_prod.OPS_TASK_MATRIX_INSTANCE (
        INSTANCE_ID         INT IDENTITY(1,1) PRIMARY KEY,
        TASK_ID             INT NOT NULL,
        TEMPLATE_ID         INT NOT NULL,
        WS_SET_ID           INT,
        CALC_PERCENT        DECIMAL(5,2) DEFAULT 0,
        
        CREATED_DATE        DATETIME DEFAULT GETDATE(),
        UPDATED_DATE        DATETIME,
        
        CONSTRAINT FK_OPS_TASK_MATRIX_TASK FOREIGN KEY (TASK_ID) 
            REFERENCES workcube_prod.OPS_TASK(TASK_ID) ON DELETE CASCADE
    );
    
    CREATE INDEX IX_OPS_TASK_MATRIX_TASK ON workcube_prod.OPS_TASK_MATRIX_INSTANCE (TASK_ID);
    PRINT 'OPS_TASK_MATRIX_INSTANCE tablosu oluşturuldu.';
END
ELSE
    PRINT 'OPS_TASK_MATRIX_INSTANCE tablosu zaten mevcut.';
GO

-- ============================================
-- 10. MATRİS HÜCRE DEĞERLERİ: OPS_TASK_MATRIX_CELL_VALUE
-- ============================================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'OPS_TASK_MATRIX_CELL_VALUE' AND schema_id = SCHEMA_ID('workcube_prod'))
BEGIN
    CREATE TABLE workcube_prod.OPS_TASK_MATRIX_CELL_VALUE (
        CELL_VALUE_ID       INT IDENTITY(1,1) PRIMARY KEY,
        INSTANCE_ID         INT NOT NULL,
        CELL_DEF_ID         INT NOT NULL,
        VALUE_CODE          NVARCHAR(100),      -- Virgülle ayrılmış (PLUS,STK)
        
        UPDATED_BY          INT,
        UPDATED_DATE        DATETIME,
        
        CONSTRAINT FK_OPS_TASK_CELL_INSTANCE FOREIGN KEY (INSTANCE_ID) 
            REFERENCES workcube_prod.OPS_TASK_MATRIX_INSTANCE(INSTANCE_ID) ON DELETE CASCADE
    );
    
    CREATE INDEX IX_OPS_TASK_CELL_INSTANCE ON workcube_prod.OPS_TASK_MATRIX_CELL_VALUE (INSTANCE_ID);
    PRINT 'OPS_TASK_MATRIX_CELL_VALUE tablosu oluşturuldu.';
END
ELSE
    PRINT 'OPS_TASK_MATRIX_CELL_VALUE tablosu zaten mevcut.';
GO

-- ============================================
-- 11. AUDIT LOG: OPS_TASK_AUDIT
-- ============================================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'OPS_TASK_AUDIT' AND schema_id = SCHEMA_ID('workcube_prod'))
BEGIN
    CREATE TABLE workcube_prod.OPS_TASK_AUDIT (
        AUDIT_ID            INT IDENTITY(1,1) PRIMARY KEY,
        TASK_ID             INT NOT NULL,
        ACTION_TYPE         VARCHAR(20),        -- 'CREATE', 'UPDATE', 'DELETE', 'STATUS_CHANGE', 'MATRIX_SAVE'
        OLD_VALUE           NVARCHAR(MAX),
        NEW_VALUE           NVARCHAR(MAX),
        FIELD_NAME          VARCHAR(50),
        
        CREATED_BY          INT,
        CREATED_DATE        DATETIME DEFAULT GETDATE(),
        CREATED_IP          VARCHAR(50)
    );
    
    CREATE INDEX IX_OPS_TASK_AUDIT_TASK ON workcube_prod.OPS_TASK_AUDIT (TASK_ID);
    CREATE INDEX IX_OPS_TASK_AUDIT_DATE ON workcube_prod.OPS_TASK_AUDIT (CREATED_DATE);
    PRINT 'OPS_TASK_AUDIT tablosu oluşturuldu.';
END
ELSE
    PRINT 'OPS_TASK_AUDIT tablosu zaten mevcut.';
GO

-- ============================================
-- ÖZET
-- ============================================
PRINT '';
PRINT '============================================';
PRINT 'OPS_TASK DDL SCRIPT TAMAMLANDI';
PRINT '============================================';
PRINT 'Oluşturulan tablolar:';
PRINT '  1. OPS_TASK                 - Ana görev tablosu';
PRINT '  2. OPS_TASK_STEP            - İş adımları';
PRINT '  3. OPS_TASK_NOTE            - Takip notları';
PRINT '  4. OPS_TASK_TIME            - Zaman harcaması';
PRINT '  5. OPS_TASK_DOC             - Belgeler';
PRINT '  6. OPS_TASK_CC              - Bilgi verilecekler';
PRINT '  7. OPS_TASK_WS_SET          - İstasyon setleri';
PRINT '  8. OPS_TASK_WS_SET_ROW      - Seçili istasyonlar';
PRINT '  9. OPS_TASK_MATRIX_INSTANCE - Matris instance';
PRINT ' 10. OPS_TASK_MATRIX_CELL_VALUE - Matris hücre değerleri';
PRINT ' 11. OPS_TASK_AUDIT           - Audit log';
PRINT '';
PRINT 'NOT: Bu tablolar mevcut PRO_WORKS ve PRJ_* tablolarını ETKİLEMEZ.';
PRINT '============================================';
GO
