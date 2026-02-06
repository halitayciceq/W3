-- ═══════════════════════════════════════════════════════════════════════════════
-- OPS_TASK WIZARD - VERİTABANI ŞEMASI
-- Tarih: 2026-02-05
-- Versiyon: 2.0
-- 
-- DSN SABİTLERİ (DEĞİŞMEZ):
--   DSN  (Main)   : workcube_prod
--   DSN1 (Product): workcube_prod_product
--   DSN3 (Şirket) : workcube_prod_1       ← YENİ TABLOLAR BURADA
--   DSN2 (Dönem)  : workcube_prod_2026_1
--
-- ÖNEMLİ: dbo. KULLANILMAZ! Format: DATABASE.TABLE
-- ═══════════════════════════════════════════════════════════════════════════════

-- ╔═══════════════════════════════════════════════════════════════════════════════╗
-- ║  TABLO → DSN MATRİSİ                                                          ║
-- ╠═══════════════════════════════════════════════════════════════════════════════╣
-- ║  Tablo                      │ DSN                  │ Tam İsim                 ║
-- ╠═════════════════════════════╪══════════════════════╪══════════════════════════╣
-- ║  OPS_TASK                   │ workcube_prod        │ workcube_prod.OPS_TASK   ║
-- ║  OPS_TASK_TEMPLATE          │ workcube_prod_1      │ workcube_prod_1.OPS_...  ║
-- ║  OPS_TASK_TEMPLATE_ITEM     │ workcube_prod_1      │ workcube_prod_1.OPS_...  ║
-- ║  OPS_TASK_BATCH_LOG         │ workcube_prod_1      │ workcube_prod_1.OPS_...  ║
-- ║  OPS_TASK_BATCH_LOG_ITEM    │ workcube_prod_1      │ workcube_prod_1.OPS_...  ║
-- ║  EMPLOYEES                  │ workcube_prod        │ workcube_prod.EMPLOYEES  ║
-- ║  ORDERS                     │ workcube_prod_1      │ workcube_prod_1.ORDERS   ║
-- ╚═══════════════════════════════════════════════════════════════════════════════╝

-- ═══════════════════════════════════════════════════════════════════════════════
-- BÖLÜM 1: ŞABLON TABLOLARI (DSN3: workcube_prod_1)
-- ═══════════════════════════════════════════════════════════════════════════════

-- 1.1 Görev Şablonu Ana Tablo
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'OPS_TASK_TEMPLATE')
BEGIN
    CREATE TABLE workcube_prod_1.OPS_TASK_TEMPLATE (
        TEMPLATE_ID         INT IDENTITY(1,1) PRIMARY KEY,
        TEMPLATE_CODE       VARCHAR(50) NOT NULL,
        TEMPLATE_NAME       NVARCHAR(200) NOT NULL,
        DESCRIPTION         NVARCHAR(500) NULL,
        COMPANY_ID          INT NOT NULL,
        ORDER_TYPE_ID       INT NULL,
        PRODUCT_GROUP_ID    INT NULL,
        IS_DEFAULT          BIT DEFAULT 0,
        IS_ACTIVE           BIT DEFAULT 1,
        CREATED_BY          INT NULL,
        CREATED_DATE        DATETIME DEFAULT GETDATE(),
        UPDATED_BY          INT NULL,
        UPDATED_DATE        DATETIME NULL
    );
    PRINT 'workcube_prod_1.OPS_TASK_TEMPLATE tablosu oluşturuldu.';
END
GO

-- Unique Index (ayrı statement)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'UQ_OPS_TASK_TEMPLATE_CODE')
BEGIN
    CREATE UNIQUE INDEX UQ_OPS_TASK_TEMPLATE_CODE 
        ON workcube_prod_1.OPS_TASK_TEMPLATE (TEMPLATE_CODE, COMPANY_ID) 
        WHERE IS_ACTIVE = 1;
    PRINT 'UQ_OPS_TASK_TEMPLATE_CODE index oluşturuldu.';
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_OPS_TASK_TEMPLATE_COMPANY')
BEGIN
    CREATE INDEX IX_OPS_TASK_TEMPLATE_COMPANY 
        ON workcube_prod_1.OPS_TASK_TEMPLATE (COMPANY_ID, IS_ACTIVE);
    PRINT 'IX_OPS_TASK_TEMPLATE_COMPANY index oluşturuldu.';
END
GO

-- 1.2 Şablon Görev Satırları
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'OPS_TASK_TEMPLATE_ITEM')
BEGIN
    CREATE TABLE workcube_prod_1.OPS_TASK_TEMPLATE_ITEM (
        ITEM_ID                 INT IDENTITY(1,1) PRIMARY KEY,
        TEMPLATE_ID             INT NOT NULL,
        TASK_CODE               VARCHAR(50) NOT NULL,
        TASK_HEAD               NVARCHAR(200) NOT NULL,
        TASK_DETAIL             NVARCHAR(MAX) NULL,
        SORT_ORDER              INT DEFAULT 0,
        DEFAULT_EMP_ID          INT NULL,
        DEFAULT_PRIORITY_ID     INT DEFAULT 2,
        DEFAULT_DAYS_OFFSET     INT DEFAULT 0,
        DEFAULT_ESTIMATED_MINUTES INT DEFAULT 0,
        HAS_PRODUCTION_MATRIX   BIT DEFAULT 0,
        IS_MANDATORY            BIT DEFAULT 0,
        IS_ACTIVE               BIT DEFAULT 1,
        CREATED_DATE            DATETIME DEFAULT GETDATE(),
        
        CONSTRAINT FK_TEMPLATE_ITEM_TEMPLATE 
            FOREIGN KEY (TEMPLATE_ID) 
            REFERENCES workcube_prod_1.OPS_TASK_TEMPLATE(TEMPLATE_ID)
    );
    PRINT 'workcube_prod_1.OPS_TASK_TEMPLATE_ITEM tablosu oluşturuldu.';
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'UQ_TEMPLATE_ITEM_CODE')
BEGIN
    CREATE UNIQUE INDEX UQ_TEMPLATE_ITEM_CODE 
        ON workcube_prod_1.OPS_TASK_TEMPLATE_ITEM (TEMPLATE_ID, TASK_CODE) 
        WHERE IS_ACTIVE = 1;
    PRINT 'UQ_TEMPLATE_ITEM_CODE index oluşturuldu.';
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_TEMPLATE_ITEM_TEMPLATE')
BEGIN
    CREATE INDEX IX_TEMPLATE_ITEM_TEMPLATE 
        ON workcube_prod_1.OPS_TASK_TEMPLATE_ITEM (TEMPLATE_ID, SORT_ORDER);
    PRINT 'IX_TEMPLATE_ITEM_TEMPLATE index oluşturuldu.';
END
GO


-- ═══════════════════════════════════════════════════════════════════════════════
-- BÖLÜM 2: OPS_TASK TABLOSU GÜNCELLEMELERİ (DSN: workcube_prod)
-- ═══════════════════════════════════════════════════════════════════════════════

-- 2.1 TASK_CODE kolonu ekle
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('workcube_prod.OPS_TASK') AND name = 'TASK_CODE')
BEGIN
    ALTER TABLE workcube_prod.OPS_TASK ADD TASK_CODE VARCHAR(50) NULL;
    PRINT 'workcube_prod.OPS_TASK.TASK_CODE kolonu eklendi.';
END
GO

-- 2.2 TEMPLATE_ID kolonu ekle
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('workcube_prod.OPS_TASK') AND name = 'TEMPLATE_ID')
BEGIN
    ALTER TABLE workcube_prod.OPS_TASK ADD TEMPLATE_ID INT NULL;
    PRINT 'workcube_prod.OPS_TASK.TEMPLATE_ID kolonu eklendi.';
END
GO

-- 2.3 TEMPLATE_ITEM_ID kolonu ekle
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('workcube_prod.OPS_TASK') AND name = 'TEMPLATE_ITEM_ID')
BEGIN
    ALTER TABLE workcube_prod.OPS_TASK ADD TEMPLATE_ITEM_ID INT NULL;
    PRINT 'workcube_prod.OPS_TASK.TEMPLATE_ITEM_ID kolonu eklendi.';
END
GO

-- 2.4 BATCH_ID kolonu ekle
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('workcube_prod.OPS_TASK') AND name = 'BATCH_ID')
BEGIN
    ALTER TABLE workcube_prod.OPS_TASK ADD BATCH_ID UNIQUEIDENTIFIER NULL;
    PRINT 'workcube_prod.OPS_TASK.BATCH_ID kolonu eklendi.';
END
GO

-- 2.5 MATRIX_INSTANCE_ID kolonu ekle
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('workcube_prod.OPS_TASK') AND name = 'MATRIX_INSTANCE_ID')
BEGIN
    ALTER TABLE workcube_prod.OPS_TASK ADD MATRIX_INSTANCE_ID INT NULL;
    PRINT 'workcube_prod.OPS_TASK.MATRIX_INSTANCE_ID kolonu eklendi.';
END
GO

-- 2.6 Idempotency için Unique Index (KRITIK!)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_OPS_TASK_UNIQUE_PER_ORDER')
BEGIN
    CREATE UNIQUE INDEX IX_OPS_TASK_UNIQUE_PER_ORDER 
        ON workcube_prod.OPS_TASK (REF_TYPE, REF_ID, TASK_CODE) 
        WHERE TASK_CODE IS NOT NULL AND IS_ACTIVE = 1;
    PRINT 'IX_OPS_TASK_UNIQUE_PER_ORDER unique index oluşturuldu.';
END
GO

-- 2.7 Batch sorguları için index
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_OPS_TASK_BATCH')
BEGIN
    CREATE INDEX IX_OPS_TASK_BATCH 
        ON workcube_prod.OPS_TASK (BATCH_ID) 
        WHERE BATCH_ID IS NOT NULL;
    PRINT 'IX_OPS_TASK_BATCH index oluşturuldu.';
END
GO

-- 2.8 Template sorguları için index
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_OPS_TASK_TEMPLATE')
BEGIN
    CREATE INDEX IX_OPS_TASK_TEMPLATE 
        ON workcube_prod.OPS_TASK (TEMPLATE_ID) 
        WHERE TEMPLATE_ID IS NOT NULL;
    PRINT 'IX_OPS_TASK_TEMPLATE index oluşturuldu.';
END
GO


-- ═══════════════════════════════════════════════════════════════════════════════
-- BÖLÜM 3: AUDİT TABLOLARI (DSN3: workcube_prod_1)
-- ═══════════════════════════════════════════════════════════════════════════════

-- 3.1 Batch İşlem Log (Özet)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'OPS_TASK_BATCH_LOG')
BEGIN
    CREATE TABLE workcube_prod_1.OPS_TASK_BATCH_LOG (
        LOG_ID              INT IDENTITY(1,1) PRIMARY KEY,
        BATCH_ID            UNIQUEIDENTIFIER NOT NULL,
        REF_TYPE            VARCHAR(20) NOT NULL,
        REF_ID              INT NOT NULL,
        TEMPLATE_ID         INT NULL,
        ACTION_TYPE         VARCHAR(20) NOT NULL,
        STRATEGY            VARCHAR(20) DEFAULT 'skip_existing',
        MATRIX_MODE         VARCHAR(20) DEFAULT 'lenient',
        TOTAL_ITEMS         INT DEFAULT 0,
        CREATED_COUNT       INT DEFAULT 0,
        UPDATED_COUNT       INT DEFAULT 0,
        SKIPPED_COUNT       INT DEFAULT 0,
        ERROR_COUNT         INT DEFAULT 0,
        ERROR_DETAILS       NVARCHAR(MAX) NULL,
        CREATED_BY          INT NULL,
        CREATED_DATE        DATETIME DEFAULT GETDATE(),
        DURATION_MS         INT NULL
    );
    PRINT 'workcube_prod_1.OPS_TASK_BATCH_LOG tablosu oluşturuldu.';
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_BATCH_LOG_BATCH')
BEGIN
    CREATE INDEX IX_BATCH_LOG_BATCH ON workcube_prod_1.OPS_TASK_BATCH_LOG (BATCH_ID);
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_BATCH_LOG_REF')
BEGIN
    CREATE INDEX IX_BATCH_LOG_REF ON workcube_prod_1.OPS_TASK_BATCH_LOG (REF_TYPE, REF_ID);
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_BATCH_LOG_DATE')
BEGIN
    CREATE INDEX IX_BATCH_LOG_DATE ON workcube_prod_1.OPS_TASK_BATCH_LOG (CREATED_DATE);
END
GO

-- 3.2 Batch İşlem Log Detay (Satır Bazlı)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'OPS_TASK_BATCH_LOG_ITEM')
BEGIN
    CREATE TABLE workcube_prod_1.OPS_TASK_BATCH_LOG_ITEM (
        LOG_ITEM_ID         INT IDENTITY(1,1) PRIMARY KEY,
        BATCH_ID            UNIQUEIDENTIFIER NOT NULL,
        TASK_CODE           VARCHAR(50) NOT NULL,
        ACTION              VARCHAR(20) NOT NULL,
        EXISTING_TASK_ID    INT NULL,
        NEW_TASK_ID         INT NULL,
        REASON              NVARCHAR(500) NULL,
        ERROR_DETAIL        NVARCHAR(MAX) NULL,
        CREATED_DATE        DATETIME DEFAULT GETDATE()
    );
    PRINT 'workcube_prod_1.OPS_TASK_BATCH_LOG_ITEM tablosu oluşturuldu.';
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_BATCH_LOG_ITEM_BATCH')
BEGIN
    CREATE INDEX IX_BATCH_LOG_ITEM_BATCH ON workcube_prod_1.OPS_TASK_BATCH_LOG_ITEM (BATCH_ID);
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_BATCH_LOG_ITEM_TASK')
BEGIN
    CREATE INDEX IX_BATCH_LOG_ITEM_TASK ON workcube_prod_1.OPS_TASK_BATCH_LOG_ITEM (TASK_CODE);
END
GO


-- ═══════════════════════════════════════════════════════════════════════════════
-- BÖLÜM 4: VARSAYILAN ŞABLON VERİSİ (DSN3: workcube_prod_1)
-- ═══════════════════════════════════════════════════════════════════════════════

DECLARE @template_exists INT;
SELECT @template_exists = COUNT(*) FROM workcube_prod_1.OPS_TASK_TEMPLATE WHERE TEMPLATE_CODE = 'STD_ORDER';

IF @template_exists = 0
BEGIN
    DECLARE @tid INT;
    
    INSERT INTO workcube_prod_1.OPS_TASK_TEMPLATE (TEMPLATE_CODE, TEMPLATE_NAME, DESCRIPTION, COMPANY_ID, IS_DEFAULT)
    VALUES ('STD_ORDER', N'Standart Sipariş Görevleri', N'Tüm siparişler için varsayılan görev şablonu', 1, 1);
    
    SET @tid = SCOPE_IDENTITY();
    
    INSERT INTO workcube_prod_1.OPS_TASK_TEMPLATE_ITEM 
    (TEMPLATE_ID, TASK_CODE, TASK_HEAD, SORT_ORDER, DEFAULT_PRIORITY_ID, DEFAULT_DAYS_OFFSET, IS_MANDATORY, HAS_PRODUCTION_MATRIX) 
    VALUES
    (@tid, 'ORDER_APPROVAL',     N'SİPARİŞ ONAYI',               1,  3, 0,  1, 0),
    (@tid, 'PAYMENT_APPROVAL',   N'AVANS / ÖDEME ONAY',          2,  3, 1,  1, 0),
    (@tid, 'SURVEY_STATUS',      N'KEŞİF DURUMU',                3,  2, 3,  0, 0),
    (@tid, 'PRE_DESIGN',         N'ÖN TASARIM',                  4,  2, 5,  0, 0),
    (@tid, 'CUSTOMER_APPROVAL',  N'ÖN TASARIM MÜŞTERİ ONAYI',    5,  3, 7,  0, 0),
    (@tid, 'DETAIL_DESIGN',      N'DETAY TASARIM',               6,  2, 10, 0, 0),
    (@tid, 'MANUFACTURING_DWG',  N'İMALAT RESİMLERİ',            7,  2, 14, 0, 0),
    (@tid, 'CUT_BEND_LIST',      N'KESİM BÜKÜM LİSTELERİ',       8,  2, 14, 0, 0),
    (@tid, 'PRODUCT_TREE',       N'ÜRÜN AĞACI',                  9,  2, 14, 0, 0),
    (@tid, 'SHIPMENT_CHECKLIST', N'SEVKİYAT CHECKLİST',          10, 2, 21, 0, 0),
    (@tid, 'ELECTRICAL_TREE',    N'ELEKTRİK ÜRÜN AĞACI',         11, 2, 14, 0, 0),
    (@tid, 'MECHANICAL_TREE',    N'MEKANİK ÜRÜN AĞACI',          12, 2, 14, 0, 0),
    (@tid, 'PROCUREMENT',        N'TEDARİK SÜRECİ',              13, 2, 21, 0, 0),
    (@tid, 'PRODUCTION',         N'ÜRETİM SÜRECİ',               14, 2, 30, 1, 1),
    (@tid, 'ASSEMBLY',           N'MONTAJ SÜRECİ',               15, 2, 45, 0, 0),
    (@tid, 'SHIPMENT',           N'SEVKİYAT',                    16, 2, 60, 1, 0),
    (@tid, 'SITE_ASSEMBLY',      N'SAHA MONTAJ',                 17, 2, 75, 0, 0);
    
    PRINT 'STD_ORDER şablonu ve görevleri oluşturuldu.';
END
ELSE
    PRINT 'STD_ORDER şablonu zaten mevcut.';
GO


-- ═══════════════════════════════════════════════════════════════════════════════
-- BÖLÜM 5: DOĞRULAMA SORGULARI
-- ═══════════════════════════════════════════════════════════════════════════════

PRINT '═══════════════════════════════════════════════════════════════════════════════';
PRINT '--- DSN3 (workcube_prod_1) TABLO KONTROLÜ ---';
SELECT 'OPS_TASK_TEMPLATE' AS Tablo, COUNT(*) AS Kayit FROM workcube_prod_1.OPS_TASK_TEMPLATE
UNION ALL
SELECT 'OPS_TASK_TEMPLATE_ITEM', COUNT(*) FROM workcube_prod_1.OPS_TASK_TEMPLATE_ITEM
UNION ALL
SELECT 'OPS_TASK_BATCH_LOG', COUNT(*) FROM workcube_prod_1.OPS_TASK_BATCH_LOG
UNION ALL
SELECT 'OPS_TASK_BATCH_LOG_ITEM', COUNT(*) FROM workcube_prod_1.OPS_TASK_BATCH_LOG_ITEM;

PRINT '--- DSN (workcube_prod) OPS_TASK YENİ KOLONLAR ---';
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM workcube_prod.INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'OPS_TASK' 
AND COLUMN_NAME IN ('TASK_CODE', 'TEMPLATE_ID', 'TEMPLATE_ITEM_ID', 'BATCH_ID', 'MATRIX_INSTANCE_ID');

PRINT '--- ŞABLON VERİSİ ---';
SELECT t.TEMPLATE_CODE, t.TEMPLATE_NAME, COUNT(i.ITEM_ID) AS GorevSayisi
FROM workcube_prod_1.OPS_TASK_TEMPLATE t
LEFT JOIN workcube_prod_1.OPS_TASK_TEMPLATE_ITEM i ON i.TEMPLATE_ID = t.TEMPLATE_ID AND i.IS_ACTIVE = 1
WHERE t.IS_ACTIVE = 1
GROUP BY t.TEMPLATE_CODE, t.TEMPLATE_NAME;

PRINT '═══════════════════════════════════════════════════════════════════════════════';
PRINT 'TAMAMLANDI: workcube_prod_1 (DSN3) + workcube_prod (DSN) tabloları hazır';
PRINT '═══════════════════════════════════════════════════════════════════════════════';
GO
