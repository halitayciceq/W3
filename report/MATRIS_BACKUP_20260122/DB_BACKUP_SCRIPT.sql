-- ============================================
-- MATRIS SISTEMI VERITABANI YEDEK SCRIPTI
-- Tarih: 2026-01-22
-- ============================================

-- Bu script veritabanı yapısını yeniden oluşturmak için kullanılabilir.
-- Önce tabloları, sonra stored procedure'leri çalıştırın.

-- ============================================
-- 1. TABLOLAR
-- ============================================

-- PRJ_TASK_MATRIX_TEMPLATE - Matris şablonları
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'PRJ_TASK_MATRIX_TEMPLATE')
CREATE TABLE workcube_prod.PRJ_TASK_MATRIX_TEMPLATE (
    TEMPLATE_ID INT IDENTITY(1,1) PRIMARY KEY,
    TEMPLATE_CODE NVARCHAR(50) NOT NULL,
    TEMPLATE_NAME NVARCHAR(200),
    DESCRIPTION NVARCHAR(500),
    IS_ACTIVE BIT DEFAULT 1,
    CREATED_DATE DATETIME DEFAULT GETDATE()
);

-- PRJ_TASK_MATRIX_DIM - Matris boyutları (STAGE ve SUB_STAGE)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'PRJ_TASK_MATRIX_DIM')
CREATE TABLE workcube_prod.PRJ_TASK_MATRIX_DIM (
    DIM_ID INT IDENTITY(1,1) PRIMARY KEY,
    TEMPLATE_ID INT NOT NULL,
    DIM_TYPE NVARCHAR(20) NOT NULL, -- 'STAGE' veya 'SUB_STAGE'
    DIM_CODE NVARCHAR(50) NOT NULL,
    DIM_NAME NVARCHAR(200),
    PARENT_DIM_ID INT NULL,
    WORKSTATION_ID INT NULL,
    SORT_ORDER INT DEFAULT 0,
    IS_ACTIVE BIT DEFAULT 1
);

-- PRJ_TASK_MATRIX_CELL_DEF - Hücre tanımları
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'PRJ_TASK_MATRIX_CELL_DEF')
CREATE TABLE workcube_prod.PRJ_TASK_MATRIX_CELL_DEF (
    CELL_DEF_ID INT IDENTITY(1,1) PRIMARY KEY,
    TEMPLATE_ID INT NOT NULL,
    STAGE_DIM_ID INT NOT NULL,
    SUB_STAGE_DIM_ID INT NULL,
    ROW_INDEX INT DEFAULT 0,
    COL_INDEX INT DEFAULT 0,
    CELL_LABEL NVARCHAR(200),
    WEIGHT DECIMAL(5,2) DEFAULT 1.00,
    IS_ACTIVE BIT DEFAULT 1
);

-- PRJ_TASK_MATRIX_VALUE - Olası değerler (+, STK, 0, YOK, -)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'PRJ_TASK_MATRIX_VALUE')
CREATE TABLE workcube_prod.PRJ_TASK_MATRIX_VALUE (
    VALUE_ID INT IDENTITY(1,1) PRIMARY KEY,
    TEMPLATE_ID INT NOT NULL,
    VALUE_CODE NVARCHAR(20) NOT NULL,
    VALUE_LABEL NVARCHAR(50),
    SCORE DECIMAL(5,2) DEFAULT 0,
    COLOR_CODE NVARCHAR(20),
    SORT_ORDER INT DEFAULT 0
);

-- PRJ_TASK_WS_SET - İstasyon setleri (proje + görev bazında)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'PRJ_TASK_WS_SET')
CREATE TABLE workcube_prod.PRJ_TASK_WS_SET (
    WS_SET_ID INT IDENTITY(1,1) PRIMARY KEY,
    PROJECT_ID INT NOT NULL,
    WORK_ID INT NOT NULL,
    TEMPLATE_ID INT NOT NULL,
    CREATED_DATE DATETIME DEFAULT GETDATE(),
    UPDATED_DATE DATETIME NULL
);

-- PRJ_TASK_WS_SET_ROW - Seçili istasyonlar
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'PRJ_TASK_WS_SET_ROW')
CREATE TABLE workcube_prod.PRJ_TASK_WS_SET_ROW (
    WS_SET_ROW_ID INT IDENTITY(1,1) PRIMARY KEY,
    WS_SET_ID INT NOT NULL,
    WORKSTATION_ID INT NOT NULL,
    WORKSTATION_CODE NVARCHAR(50),
    WORKSTATION_NAME NVARCHAR(200),
    SORT_ORDER INT DEFAULT 0,
    UPDATED_BY INT NULL,
    UPDATED_DATE DATETIME NULL
);

-- PRJ_TASK_MATRIX_INSTANCE - Matris instance'ları
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'PRJ_TASK_MATRIX_INSTANCE')
CREATE TABLE workcube_prod.PRJ_TASK_MATRIX_INSTANCE (
    INSTANCE_ID INT IDENTITY(1,1) PRIMARY KEY,
    PROJECT_ID INT NOT NULL,
    WORK_ID INT NOT NULL,
    TEMPLATE_ID INT NOT NULL,
    WS_SET_ID INT NULL,
    CALC_PERCENT DECIMAL(5,2) DEFAULT 0,
    CREATED_DATE DATETIME DEFAULT GETDATE(),
    UPDATED_DATE DATETIME NULL
);

-- PRJ_TASK_MATRIX_CELL_VALUE - Hücre değerleri
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'PRJ_TASK_MATRIX_CELL_VALUE')
CREATE TABLE workcube_prod.PRJ_TASK_MATRIX_CELL_VALUE (
    CELL_VALUE_ID INT IDENTITY(1,1) PRIMARY KEY,
    INSTANCE_ID INT NOT NULL,
    CELL_DEF_ID INT NOT NULL,
    VALUE_ID INT NULL,
    VALUE_CODE NVARCHAR(100) NULL, -- Virgülle ayrılmış değerler (PLUS,STK gibi)
    UPDATED_BY INT NULL,
    UPDATED_DATE DATETIME NULL
);

-- ============================================
-- 2. ÖRNEK VERİLER
-- ============================================

-- Template
INSERT INTO workcube_prod.PRJ_TASK_MATRIX_TEMPLATE (TEMPLATE_CODE, TEMPLATE_NAME)
VALUES ('URETIM_SURECI', 'Üretim Süreci Takip Matrisi');

-- Değerler
INSERT INTO workcube_prod.PRJ_TASK_MATRIX_VALUE (TEMPLATE_ID, VALUE_CODE, VALUE_LABEL, SCORE, COLOR_CODE, SORT_ORDER)
VALUES 
(1, 'PLUS', '+', 1.00, '#22c55e', 1),
(1, 'STK', 'STK', 0.75, '#3b82f6', 2),
(1, 'ZERO', '0', 0.50, '#f59e0b', 3),
(1, 'YOK', 'YOK', 0.00, '#ef4444', 4),
(1, 'MINUS', '-', -0.25, '#dc2626', 5);

-- ============================================
-- 3. STORED PROCEDURES
-- ============================================

-- sp_prj_task_matrix_get için PRJ_TASK_MATRIX_GET_V3.sql dosyasını çalıştırın
-- sp_prj_task_ws_set_save için PRJ_TASK_WS_SET_SAVE_V2.sql dosyasını çalıştırın
-- sp_prj_task_ws_list için aşağıdaki scripti çalıştırın:

/*
CREATE PROCEDURE workcube_prod.sp_prj_task_ws_list
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        DIM_ID AS workstation_id,
        DIM_CODE AS code,
        DIM_NAME AS name
    FROM workcube_prod.PRJ_TASK_MATRIX_DIM
    WHERE DIM_TYPE = 'STAGE' 
      AND IS_ACTIVE = 1
      AND TEMPLATE_ID = 1
    ORDER BY SORT_ORDER;
END
*/

-- ============================================
-- 4. YEDEK NOTLARI
-- ============================================

/*
DOSYALAR:
- 5560605B-BA40-44A6-1E209FF687575FC2.cfm : Ana rapor sayfası (matris modal dahil)
- ajax_task_matrix.cfm : AJAX endpoint (get, save, ws_list, ws_save)
- PRJ_TASK_MATRIX_GET_V3.sql : Matris veri getirme SP
- PRJ_TASK_WS_SET_SAVE_V2.sql : İstasyon kaydetme SP
- MATRIS_MODAL_ANALIZ.md : Dokümantasyon

ÖZELLİKLER:
1. İstasyon seçimi - görev bazında istasyon seçilebilir
2. Matris görüntüleme - seçili istasyonların hücreleri görünür
3. Bağımsız butonlar - +, STK, 0, YOK, - birbirinden bağımsız seçilebilir
4. Yüzde hesaplama - sadece + (PLUS) değeri yüzdeyi etkiler
5. Input kilitleme - matris değeri varsa input readonly olur
6. Koşullu görünüm - matris butonu sadece "ÜRETİM SÜRECİ" görevlerinde görünür
*/
