# Sipariş Operasyon Görevleri - Teknik Analiz ve Tasarım Dokümanı

**Tarih:** 2026-01-22  
**Versiyon:** 1.0  
**Proje:** Workcube ERP - Sipariş Operasyon Görevleri Modülü  
**Mimari Karar:** Seçenek B - Genelleştirilmiş Görev Motoru (REF_TYPE/REF_ID)

---

## 1. AS-IS: Mevcut Proje Görev Motoru İncelemesi

### 1.1 Ana Tablolar (workcube_prod şeması)

| Tablo | Açıklama | PK | Önemli FK'lar |
|-------|----------|-----|---------------|
| `PRO_PROJECTS` | Proje master | PROJECT_ID | OUR_COMPANY_ID |
| `PRO_WORKS` | Görev master | WORK_ID | PROJECT_ID, PROJECT_EMP_ID |
| `PRO_WORKS_STEP` | İş adımları | WORK_STEP_ID | WORK_ID |
| `PRO_WORKS_HISTORY` | Zaman harcaması + geçmiş | HISTORY_ID | WORK_ID |
| `PRO_WORKS_CC` | Bilgi verilecekler | - | WORK_ID, CC_EMP_ID, CC_PAR_ID |
| `PRO_WORK_RELATIONS` | İlişkili işler | - | WORK_ID, PRE_ID |
| `NOTES` | Takip notları (generic) | NOTE_ID | ACTION_ID (WORK_ID), ACTION_SECTION='WORK' |

### 1.2 PRO_WORKS Tablo Yapısı (Keşfedilen Alanlar)

```sql
-- Ana bilgiler
WORK_ID             INT PK IDENTITY
WORK_NO             NVARCHAR(50)      -- İş numarası
WORK_HEAD           NVARCHAR(200)     -- Başlık
WORK_DETAIL         NVARCHAR(MAX)     -- Açıklama
PROJECT_ID          INT FK            -- Proje bağlantısı

-- Atama
PROJECT_EMP_ID      INT FK            -- Sorumlu çalışan
OUTSRC_CMP_ID       INT FK            -- Dış kaynak firma
OUTSRC_PARTNER_ID   INT FK            -- Dış kaynak kişi

-- Tarihler
TARGET_START        DATETIME          -- Planlanan başlangıç
TARGET_FINISH       DATETIME          -- Planlanan bitiş
TERMINATE_DATE      DATETIME          -- Termin
REAL_START          DATETIME          -- Gerçek başlangıç
REAL_FINISH         DATETIME          -- Gerçek bitiş
PREDICTED_START     DATETIME          -- Tahmin başlangıç
PREDICTED_FINISH    DATETIME          -- Tahmin bitiş

-- Süreler
ESTIMATED_TIME      INT               -- Öngörülen süre (dakika)
TOTAL_TIME_HOUR     INT               -- Harcanan saat
TOTAL_TIME_MINUTE   INT               -- Harcanan dakika
DURATION            INT               -- Süre

-- Durum ve ilerleme
WORK_STATUS         BIT               -- Aktif/Pasif
WORK_CURRENCY_ID    INT FK            -- Aşama (2361=Devam, 2364=Tamamlandı)
WORK_PRIORITY_ID    INT FK            -- Öncelik
TO_COMPLETE         DECIMAL(5,2)      -- Tamamlanma %

-- Kategoriler
WORK_CAT_ID         INT FK            -- Görev kategorisi
WORKGROUP_ID        INT FK            -- Çalışma grubu
IS_MILESTONE        BIT               -- Milestone mı?
MILESTONE_WORK_ID   INT FK            -- Bağlı milestone

-- Şirket/Müşteri
OUR_COMPANY_ID      INT FK            -- Bizim şirket
COMPANY_ID          INT FK            -- Müşteri firma
COMPANY_PARTNER_ID  INT FK            -- Müşteri kişi
CONSUMER_ID         INT FK            -- Tüketici

-- İlişkiler
RELATED_WORK_ID     VARCHAR(MAX)      -- İlişkili işler (liste)
RELATION_TYPE       INT               -- İlişki tipi
OPPORTUNITY_ID      INT FK            -- Fırsat
ACTIVITY_ID         INT FK            -- Aktivite

-- Bütçe
EXPECTED_BUDGET     DECIMAL           -- Beklenen bütçe
EXPECTED_BUDGET_MONEY VARCHAR(10)     -- Para birimi
COMPLETED_AMOUNT    DECIMAL           -- Tamamlanan miktar
AVERAGE_AMOUNT      DECIMAL           -- Ortalama miktar
AVERAGE_AMOUNT_UNIT INT FK            -- Birim

-- Sözleşmeler
SALE_CONTRACT_ID    INT FK
SALE_CONTRACT_AMOUNT DECIMAL
PURCHASE_CONTRACT_ID INT FK
PURCHASE_CONTRACT_AMOUNT DECIMAL

-- Audit
RECORD_AUTHOR       INT FK
RECORD_DATE         DATETIME
RECORD_IP           VARCHAR(50)
UPDATE_AUTHOR       INT FK
UPDATE_DATE         DATETIME
UPDATE_IP           VARCHAR(50)

-- Diğer
WORK_CIRCUIT        VARCHAR(50)       -- Modül
WORK_FUSEACTION     VARCHAR(100)      -- Sayfa
REWORK              BIT               -- Yeniden iş
PBS_ID              INT FK
SPECIAL_DEFINITION_ID INT FK
```

### 1.3 PRO_WORKS_STEP Tablo Yapısı

```sql
WORK_STEP_ID            INT PK IDENTITY
WORK_ID                 INT FK
WORK_STEP_DETAIL        NVARCHAR(500)     -- Adım açıklaması
COMPLETED_HOUR          INT               -- Tamamlanan saat
COMPLETED_MINUTE        INT               -- Tamamlanan dakika
WORK_STEP_COMPLETE_PERCENT INT            -- Tamamlanma %
RANK_ORDER              INT               -- Sıralama
RECORD_DATE             DATETIME
RECORD_IP               VARCHAR(50)
RECORD_EMP              INT FK
UPDATE_DATE             DATETIME
UPDATE_EMP              INT FK
```

### 1.4 PRO_WORKS_HISTORY Tablo Yapısı

```sql
HISTORY_ID              INT PK IDENTITY
WORK_ID                 INT FK
WORK_DETAIL             NVARCHAR(MAX)     -- İş detayı snapshot
TOTAL_TIME_HOUR         INT               -- Harcanan saat
TOTAL_TIME_MINUTE       INT               -- Harcanan dakika
UPDATE_PAR              INT FK
UPDATE_DATE             DATETIME
UPDATE_IP               VARCHAR(50)
```

### 1.5 NOTES Tablosu (Generic Notlar)

```sql
NOTE_ID                 INT PK IDENTITY
ACTION_SECTION          VARCHAR(50)       -- 'WORK', 'PROJECT', 'ORDER' vb.
ACTION_ID               INT               -- İlgili kayıt ID
NOTE_HEAD               NVARCHAR(200)
NOTE_BODY               NVARCHAR(MAX)
COMPANY_ID              INT FK
PERIOD_ID               INT FK
RECORD_EMP              INT FK
RECORD_PAR              INT FK
RECORD_DATE             DATETIME
```

### 1.6 Mevcut Matris Tabloları (workcube_prod şeması)

```
PRJ_TASK_MATRIX_TEMPLATE     - Matris şablonları
PRJ_TASK_MATRIX_DIM          - Boyutlar (STAGE/SUB_STAGE)
PRJ_TASK_MATRIX_CELL_DEF     - Hücre tanımları
PRJ_TASK_MATRIX_VALUE        - Değer sözlüğü (+, STK, 0, YOK, -)
PRJ_TASK_WS_SET              - İstasyon setleri (PROJECT_ID, WORK_ID bazlı)
PRJ_TASK_WS_SET_ROW          - Seçili istasyonlar
PRJ_TASK_MATRIX_INSTANCE     - Matris instance'ları
PRJ_TASK_MATRIX_CELL_VALUE   - Hücre değerleri
```

### 1.7 CFC Fonksiyonları (get_work.cfc)

| Fonksiyon | Açıklama |
|-----------|----------|
| `DET_WORK(id)` | Görev detayı getir |
| `GETNOTES(action_section, action_id)` | Notları getir |
| `SAVENOTES(...)` | Not kaydet |
| `time_add_new(...)` | Zaman harcaması ekle |
| `delWorkSteps(WORK_ID)` | İş adımlarını sil |
| `addWorkSteps(...)` | İş adımı ekle |
| `getWorkSteps(WORK_ID)` | İş adımlarını getir |
| `upd_work_step_order(...)` | Adım sıralaması güncelle |

### 1.8 CFC Fonksiyonları (TaskManager.cfc)

| Fonksiyon | Açıklama |
|-----------|----------|
| `add(...)` | Yeni görev ekle |
| `upd(...)` | Görev güncelle |
| `del(id)` | Görev sil |
| `addWorkRelations(...)` | İlişkili iş ekle |
| `sendEmail(...)` | Mail gönder |

---

## 2. TO-BE: Sipariş Operasyon Görevleri Tasarımı

### 2.1 Mimari Karar: Genelleştirilmiş Görev Motoru

**Seçenek B** tercih edildi:
- Tek motor, tek kod tabanı
- REF_TYPE/REF_ID ile hem proje hem sipariş görevlerini destekler
- Matris, istasyon, % hesabı tek yerden yürür
- Gelecekte farklı modüller (üretim emri, servis talebi vb.) eklenebilir

### 2.2 Yeni Tablolar (workcube_prod şeması)

#### 2.2.1 OPS_TASK - Operasyon Görev Master

```sql
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
    UPDATED_IP          VARCHAR(50),
    
    -- Index için
    INDEX IX_OPS_TASK_REF (REF_TYPE, REF_ID),
    INDEX IX_OPS_TASK_ASSIGNED (ASSIGNED_EMP_ID),
    INDEX IX_OPS_TASK_STATUS (STATUS_ID),
    INDEX IX_OPS_TASK_COMPANY (COMPANY_ID)
);
```

#### 2.2.2 OPS_TASK_STEP - İş Adımları

```sql
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
        REFERENCES workcube_prod.OPS_TASK(TASK_ID) ON DELETE CASCADE,
    INDEX IX_OPS_TASK_STEP_TASK (TASK_ID)
);
```

#### 2.2.3 OPS_TASK_NOTE - Takip Notları

```sql
CREATE TABLE workcube_prod.OPS_TASK_NOTE (
    NOTE_ID             INT IDENTITY(1,1) PRIMARY KEY,
    TASK_ID             INT NOT NULL,
    NOTE_TYPE           VARCHAR(20) DEFAULT 'COMMENT',  -- 'COMMENT', 'SYSTEM', 'STATUS_CHANGE'
    NOTE_CONTENT        NVARCHAR(MAX),
    
    CREATED_BY          INT,
    CREATED_DATE        DATETIME DEFAULT GETDATE(),
    
    CONSTRAINT FK_OPS_TASK_NOTE_TASK FOREIGN KEY (TASK_ID) 
        REFERENCES workcube_prod.OPS_TASK(TASK_ID) ON DELETE CASCADE,
    INDEX IX_OPS_TASK_NOTE_TASK (TASK_ID)
);
```

#### 2.2.4 OPS_TASK_TIME - Zaman Harcaması

```sql
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
        REFERENCES workcube_prod.OPS_TASK(TASK_ID) ON DELETE CASCADE,
    INDEX IX_OPS_TASK_TIME_TASK (TASK_ID),
    INDEX IX_OPS_TASK_TIME_EMP (EMPLOYEE_ID)
);
```

#### 2.2.5 OPS_TASK_DOC - Belgeler

```sql
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
        REFERENCES workcube_prod.OPS_TASK(TASK_ID) ON DELETE CASCADE,
    INDEX IX_OPS_TASK_DOC_TASK (TASK_ID)
);
```

#### 2.2.6 OPS_TASK_CC - Bilgi Verilecekler

```sql
CREATE TABLE workcube_prod.OPS_TASK_CC (
    CC_ID               INT IDENTITY(1,1) PRIMARY KEY,
    TASK_ID             INT NOT NULL,
    CC_EMP_ID           INT,
    CC_PAR_ID           INT,
    
    CREATED_DATE        DATETIME DEFAULT GETDATE(),
    
    CONSTRAINT FK_OPS_TASK_CC_TASK FOREIGN KEY (TASK_ID) 
        REFERENCES workcube_prod.OPS_TASK(TASK_ID) ON DELETE CASCADE,
    INDEX IX_OPS_TASK_CC_TASK (TASK_ID)
);
```

#### 2.2.7 OPS_TASK_MATRIX_INSTANCE - Matris Instance

```sql
CREATE TABLE workcube_prod.OPS_TASK_MATRIX_INSTANCE (
    INSTANCE_ID         INT IDENTITY(1,1) PRIMARY KEY,
    TASK_ID             INT NOT NULL,
    TEMPLATE_ID         INT NOT NULL,
    WS_SET_ID           INT,
    CALC_PERCENT        DECIMAL(5,2) DEFAULT 0,
    
    CREATED_DATE        DATETIME DEFAULT GETDATE(),
    UPDATED_DATE        DATETIME,
    
    CONSTRAINT FK_OPS_TASK_MATRIX_TASK FOREIGN KEY (TASK_ID) 
        REFERENCES workcube_prod.OPS_TASK(TASK_ID) ON DELETE CASCADE,
    INDEX IX_OPS_TASK_MATRIX_TASK (TASK_ID)
);
```

#### 2.2.8 OPS_TASK_WS_SET - İstasyon Setleri

```sql
CREATE TABLE workcube_prod.OPS_TASK_WS_SET (
    WS_SET_ID           INT IDENTITY(1,1) PRIMARY KEY,
    TASK_ID             INT NOT NULL,
    TEMPLATE_ID         INT NOT NULL,
    
    CREATED_DATE        DATETIME DEFAULT GETDATE(),
    UPDATED_DATE        DATETIME,
    
    CONSTRAINT FK_OPS_TASK_WS_SET_TASK FOREIGN KEY (TASK_ID) 
        REFERENCES workcube_prod.OPS_TASK(TASK_ID) ON DELETE CASCADE,
    INDEX IX_OPS_TASK_WS_SET_TASK (TASK_ID)
);
```

#### 2.2.9 OPS_TASK_WS_SET_ROW - Seçili İstasyonlar

```sql
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
        REFERENCES workcube_prod.OPS_TASK_WS_SET(WS_SET_ID) ON DELETE CASCADE,
    INDEX IX_OPS_TASK_WS_ROW_SET (WS_SET_ID)
);
```

#### 2.2.10 OPS_TASK_MATRIX_CELL_VALUE - Matris Hücre Değerleri

```sql
CREATE TABLE workcube_prod.OPS_TASK_MATRIX_CELL_VALUE (
    CELL_VALUE_ID       INT IDENTITY(1,1) PRIMARY KEY,
    INSTANCE_ID         INT NOT NULL,
    CELL_DEF_ID         INT NOT NULL,
    VALUE_CODE          NVARCHAR(100),      -- Virgülle ayrılmış (PLUS,STK)
    
    UPDATED_BY          INT,
    UPDATED_DATE        DATETIME,
    
    CONSTRAINT FK_OPS_TASK_CELL_INSTANCE FOREIGN KEY (INSTANCE_ID) 
        REFERENCES workcube_prod.OPS_TASK_MATRIX_INSTANCE(INSTANCE_ID) ON DELETE CASCADE,
    INDEX IX_OPS_TASK_CELL_INSTANCE (INSTANCE_ID)
);
```

#### 2.2.11 OPS_TASK_AUDIT - Audit Log

```sql
CREATE TABLE workcube_prod.OPS_TASK_AUDIT (
    AUDIT_ID            INT IDENTITY(1,1) PRIMARY KEY,
    TASK_ID             INT NOT NULL,
    ACTION_TYPE         VARCHAR(20),        -- 'CREATE', 'UPDATE', 'DELETE', 'STATUS_CHANGE', 'MATRIX_SAVE'
    OLD_VALUE           NVARCHAR(MAX),
    NEW_VALUE           NVARCHAR(MAX),
    FIELD_NAME          VARCHAR(50),
    
    CREATED_BY          INT,
    CREATED_DATE        DATETIME DEFAULT GETDATE(),
    CREATED_IP          VARCHAR(50),
    
    INDEX IX_OPS_TASK_AUDIT_TASK (TASK_ID),
    INDEX IX_OPS_TASK_AUDIT_DATE (CREATED_DATE)
);
```

### 2.3 İlişki Diyagramı

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              ERP CORE TABLES                                     │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  ┌──────────────────┐         ┌──────────────────┐         ┌──────────────────┐ │
│  │  PRO_PROJECTS    │         │   PRO_WORKS      │         │   ORDERS         │ │
│  │  (Projeler)      │         │   (Proje Görevi) │         │   (Siparişler)   │ │
│  ├──────────────────┤         ├──────────────────┤         ├──────────────────┤ │
│  │ PROJECT_ID (PK)  │◄────────│ PROJECT_ID (FK)  │         │ ORDER_ID (PK)    │ │
│  └──────────────────┘         │ WORK_ID (PK)     │         └────────┬─────────┘ │
│                               └────────┬─────────┘                  │           │
│                                        │                            │           │
└────────────────────────────────────────┼────────────────────────────┼───────────┘
                                         │                            │
                                         │   REF_TYPE='PROJECT_WORK'  │ REF_TYPE='ORDER'
                                         │   REF_ID=WORK_ID           │ REF_ID=ORDER_ID
                                         │                            │
                                         ▼                            ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                    OPS_TASK (Genelleştirilmiş Görev Motoru)                       │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  ┌──────────────────────────────────────────────────────────────────────────┐   │
│  │                           OPS_TASK                                        │   │
│  │  TASK_ID (PK) | REF_TYPE | REF_ID | TASK_HEAD | STATUS_ID | PERCENT...   │   │
│  └────────────────────────────────┬──────────────────────────────────────────┘   │
│                                   │                                              │
│         ┌─────────────┬───────────┼───────────┬─────────────┬─────────────┐     │
│         │             │           │           │             │             │     │
│         ▼             ▼           ▼           ▼             ▼             ▼     │
│  ┌───────────┐ ┌───────────┐ ┌─────────┐ ┌─────────┐ ┌───────────┐ ┌─────────┐ │
│  │ OPS_TASK_ │ │ OPS_TASK_ │ │OPS_TASK_│ │OPS_TASK_│ │ OPS_TASK_ │ │OPS_TASK_│ │
│  │ STEP      │ │ NOTE      │ │ TIME    │ │ DOC     │ │ CC        │ │ AUDIT   │ │
│  └───────────┘ └───────────┘ └─────────┘ └─────────┘ └───────────┘ └─────────┘ │
│                                                                                  │
│                            MATRIS MODÜLÜ                                         │
│  ┌──────────────────────────────────────────────────────────────────────────┐   │
│  │                                                                          │   │
│  │  OPS_TASK_WS_SET ──► OPS_TASK_WS_SET_ROW                                │   │
│  │        │                                                                 │   │
│  │        ▼                                                                 │   │
│  │  OPS_TASK_MATRIX_INSTANCE ──► OPS_TASK_MATRIX_CELL_VALUE                │   │
│  │        │                              │                                  │   │
│  │        └──────────────────────────────┴──► PRJ_TASK_MATRIX_CELL_DEF     │   │
│  │                                            PRJ_TASK_MATRIX_VALUE        │   │
│  │                                            (Mevcut şablon tabloları)    │   │
│  └──────────────────────────────────────────────────────────────────────────┘   │
│                                                                                  │
└──────────────────────────────────────────────────────────────────────────────────┘
```

---

## 3. SP/API Tasarımı

### 3.1 Stored Procedures

| SP | Açıklama | Parametreler |
|----|----------|--------------|
| `sp_ops_task_list` | Görev listesi | @ref_type, @ref_id, @company_id, @status_id |
| `sp_ops_task_get` | Görev detayı | @task_id |
| `sp_ops_task_save` | Görev kaydet (insert/update) | @task_id, @task_head, @ref_type, @ref_id, ... |
| `sp_ops_task_delete` | Görev sil | @task_id |
| `sp_ops_task_step_save` | İş adımları kaydet | @task_id, @steps_json |
| `sp_ops_task_note_save` | Not kaydet | @task_id, @note_content |
| `sp_ops_task_time_save` | Zaman kaydet | @task_id, @employee_id, @hours, @minutes |
| `sp_ops_task_matrix_get` | Matris getir | @task_id |
| `sp_ops_task_matrix_save` | Matris kaydet | @task_id, @cells_json |
| `sp_ops_task_ws_list` | İstasyon listesi | @template_id |
| `sp_ops_task_ws_save` | İstasyon seçimi kaydet | @task_id, @workstations_json |

### 3.2 sp_ops_task_list

```sql
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
        T.IS_ACTIVE,
        T.CREATED_DATE
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
```

### 3.3 sp_ops_task_save

```sql
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
    
    IF @task_id IS NULL OR @task_id = 0
    BEGIN
        -- INSERT
        SET @action_type = 'CREATE';
        
        INSERT INTO workcube_prod.OPS_TASK (
            TASK_NO, TASK_HEAD, TASK_DETAIL,
            REF_TYPE, REF_ID, PARENT_TASK_ID,
            ASSIGNED_EMP_ID, PLANNED_START, PLANNED_FINISH, DEADLINE,
            ESTIMATED_MINUTES, STATUS_ID, PRIORITY_ID,
            HAS_MATRIX, MATRIX_TEMPLATE_ID,
            COMPANY_ID, BRANCH_ID,
            CREATED_BY, CREATED_DATE, CREATED_IP
        )
        VALUES (
            @task_no, @task_head, @task_detail,
            @ref_type, @ref_id, @parent_task_id,
            @assigned_emp_id, @planned_start, @planned_finish, @deadline,
            @estimated_minutes, @status_id, @priority_id,
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
            HAS_MATRIX = @has_matrix,
            MATRIX_TEMPLATE_ID = @matrix_template_id,
            UPDATED_BY = @user_id,
            UPDATED_DATE = GETDATE(),
            UPDATED_IP = @user_ip
        WHERE 
            TASK_ID = @task_id;
    END
    
    -- Audit log
    INSERT INTO workcube_prod.OPS_TASK_AUDIT (TASK_ID, ACTION_TYPE, CREATED_BY, CREATED_DATE, CREATED_IP)
    VALUES (@new_task_id, @action_type, @user_id, GETDATE(), @user_ip);
    
    SELECT @new_task_id AS TASK_ID, @action_type AS ACTION_TYPE;
END
```

### 3.4 sp_ops_task_matrix_get

```sql
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
```

### 3.5 AJAX Endpoint

**Dosya:** `/V16/order/form/ajax_ops_task.cfm`

```
action=list        → sp_ops_task_list
action=get         → sp_ops_task_get
action=save        → sp_ops_task_save
action=delete      → sp_ops_task_delete
action=step_save   → sp_ops_task_step_save
action=note_save   → sp_ops_task_note_save
action=time_save   → sp_ops_task_time_save
action=matrix_get  → sp_ops_task_matrix_get
action=matrix_save → sp_ops_task_matrix_save
action=ws_list     → sp_ops_task_ws_list
action=ws_save     → sp_ops_task_ws_save
```

---

## 4. UI/Flow Tasarımı

### 4.1 Sipariş Ekranı Görev Sekmesi

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ SİPARİŞ: ORD-2026-00123                                           [Detay]  │
├─────────────────────────────────────────────────────────────────────────────┤
│ [Genel] [Kalemler] [Görevler (Operasyonlar)] [Belgeler] [Notlar]            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│ ┌─────────────────────────────────────────────────────────────────────────┐ │
│ │ [+ Yeni Görev]                                     [Filtre] [Dışa Aktar]│ │
│ ├─────────────────────────────────────────────────────────────────────────┤ │
│ │ Sorumlu │ Başlık      │ Aşama    │ Termin   │ Öng.   │ Harc. │ %  │ ⊞  │ │
│ ├─────────────────────────────────────────────────────────────────────────┤ │
│ │ [AK]    │ Tasarım     │ [Devam▼] │ 25/01/26 │ 4:30   │ 2:15  │ 50 │    │ │
│ │ [MB]    │ ÜRETİM SÜR..│ [Devam▼] │ 28/01/26 │ 8:00   │ 3:00  │ 35 │ ⊞  │ │
│ │ [CK]    │ Kalite Kont.│ [Bekl.▼] │ 30/01/26 │ 2:00   │ 0:00  │ 0  │    │ │
│ └─────────────────────────────────────────────────────────────────────────┘ │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 4.2 Görev Detay Modal

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ Görev Detayı                                                         [X]   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│ Başlık: [ÜRETİM SÜRECİ                                               ]     │
│                                                                             │
│ ┌─────────────────────────────┐ ┌─────────────────────────────┐            │
│ │ Sorumlu: [Mehmet Bey    ▼]  │ │ Aşama: [Devam Ediyor     ▼] │            │
│ └─────────────────────────────┘ └─────────────────────────────┘            │
│                                                                             │
│ ┌─────────────────────────────┐ ┌─────────────────────────────┐            │
│ │ Termin: [28/01/2026      📅]│ │ Öncelik: [Yüksek         ▼] │            │
│ └─────────────────────────────┘ └─────────────────────────────┘            │
│                                                                             │
│ ┌─────────────────────────────┐ ┌─────────────────────────────┐            │
│ │ Öngörülen: [8] s [0] dk     │ │ Tamamlanma: [35        ] %  │            │
│ └─────────────────────────────┘ └─────────────────────────────┘            │
│                                                                             │
│ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │
│ İş Adımları                                                   [+ Ekle]     │
│ ┌───┬────────────────────────────────────┬──────────┬───┐                  │
│ │ # │ Açıklama                           │ Süre     │ ✓ │                  │
│ ├───┼────────────────────────────────────┼──────────┼───┤                  │
│ │ 1 │ Malzeme hazırlık                   │ 2s 0dk   │ ✓ │                  │
│ │ 2 │ Kesim işlemi                       │ 3s 0dk   │ ☐ │                  │
│ │ 3 │ Montaj                             │ 2s 30dk  │ ☐ │                  │
│ └───┴────────────────────────────────────┴──────────┴───┘                  │
│                                                                             │
│ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │
│ Takip Notları                                                              │
│ ┌─────────────────────────────────────────────────────────────────────────┐│
│ │ [Rich Text Editor - Notları buraya yazın...]                            ││
│ └─────────────────────────────────────────────────────────────────────────┘│
│                                                                             │
│                                              [İptal]  [Kaydet]              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 4.3 Matris Butonu Kuralı

```javascript
// Matris butonu sadece HAS_MATRIX=1 ve TASK_HEAD içinde "ÜRETİM SÜRECİ" varsa görünür
function shouldShowMatrixButton(task) {
    return task.HAS_MATRIX == 1 || 
           task.TASK_HEAD.toUpperCase().indexOf('ÜRETİM SÜRECİ') !== -1;
}
```

### 4.4 Akış Diyagramı

```
┌──────────────────┐
│ Sipariş Ekranı   │
│ Görevler Sekmesi │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐     ┌──────────────────┐
│ Görev Listesi    │────►│ + Yeni Görev     │
│ (sp_ops_task_list)     │ (Modal açılır)   │
└────────┬─────────┘     └────────┬─────────┘
         │                        │
         │ Satıra tıkla           │ Kaydet
         ▼                        ▼
┌──────────────────┐     ┌──────────────────┐
│ Görev Detay Modal│     │ sp_ops_task_save │
│ - İş Adımları    │     └────────┬─────────┘
│ - Takip Notları  │              │
│ - Zaman Harcama  │              │
└────────┬─────────┘              │
         │                        │
         │ ⊞ Matris butonu        │
         ▼                        │
┌──────────────────┐              │
│ Matris Modal     │◄─────────────┘
│ (Mevcut mantık)  │
└────────┬─────────┘
         │
         │ WS_SET var mı?
         ▼
    ┌────┴────┐
    │         │
Hayır        Evet
    │         │
    ▼         ▼
┌─────────┐ ┌─────────┐
│İstasyon │ │ Matris  │
│Seçimi   │ │ Ekranı  │
└────┬────┘ └────┬────┘
     │           │
     │ Kaydet    │ Kaydet
     ▼           ▼
┌─────────────────────┐
│ % güncelle          │
│ Aşama otomasyonu    │
│ (0/1-99/100 kuralı) │
└─────────────────────┘
```

---

## 5. Fazlandırma

### 5.1 Faz-1: MVP (Kritik Operasyon) - 2 Hafta

**Kapsam:**
- OPS_TASK, OPS_TASK_STEP, OPS_TASK_NOTE tabloları
- sp_ops_task_list, sp_ops_task_get, sp_ops_task_save, sp_ops_task_delete
- sp_ops_task_step_save, sp_ops_task_note_save
- Sipariş ekranında "Görevler" sekmesi
- Görev listesi (aynı kolonlar: Sorumlu, Başlık, Aşama, Termin, Öngörülen, Harcanan, %)
- Görev detay modal (İş Özeti + İş Adımları + Takip Notları)
- % ve aşama otomasyonu (0 / 1-99 / 100 kuralı)
- "ÜRETİM SÜRECİ" için matris butonu
- Matris/İstasyon seçimi (mevcut mantık)

**Çıktılar:**
- DDL script (OPS_TASK + STEP + NOTE)
- SP'ler (list, get, save, delete, step_save, note_save)
- AJAX endpoint (ajax_ops_task.cfm)
- UI bileşenleri (liste + modal)

### 5.2 Faz-2: Widget Entegrasyonları - 2 Hafta

**Kapsam:**
- OPS_TASK_TIME tablosu + sp_ops_task_time_save
- OPS_TASK_DOC tablosu + belge yükleme
- OPS_TASK_CC tablosu + bilgi verilecekler
- Ajanda entegrasyonu (takvim widget)
- İlişkili işlemler (link widget)
- Zaman harcaması raporu

**Çıktılar:**
- DDL script (TIME + DOC + CC)
- SP'ler (time_save, doc_save, cc_save)
- UI widget'ları

### 5.3 Faz-3: AI Otomasyonu - 3 Hafta

**Kapsam:**
- Sipariş tipine göre şablon seçimi
- Ürün ağacı/rota/istasyonlara göre görev seti üretimi
- Rollere otomatik atama
- Terminleri sipariş terminine göre dağıtma
- Üretim süreçleri için istasyon önerisi
- Akıllı tamamlanma tahmini

**Çıktılar:**
- AI görev üretici SP/CFC
- Şablon yönetimi ekranı
- Öneri motoru

---

## 6. Risk ve Test Senaryoları

### 6.1 Riskler

| Risk | Olasılık | Etki | Azaltma |
|------|----------|------|---------|
| Proje görevleri etkilenir | Düşük | Yüksek | Tamamen ayrı tablolar, FK yok |
| Performans sorunu | Orta | Orta | Index stratejisi, sayfalama |
| Matris uyumsuzluğu | Düşük | Orta | Aynı şablon tabloları kullanılıyor |
| Veri tutarsızlığı | Düşük | Yüksek | Transaction + audit log |
| UI karmaşıklığı | Orta | Düşük | Mevcut proje UI'ı referans |

### 6.2 Test Senaryoları (20+)

#### A. Temel CRUD (5 test)

| # | Senaryo | Beklenen Sonuç |
|---|---------|----------------|
| A1 | Siparişe yeni görev ekle | OPS_TASK'a kayıt eklenir, TASK_ID döner |
| A2 | Görev güncelle | UPDATE başarılı, UPDATED_DATE güncellenir |
| A3 | Görev sil | DELETE başarılı, ilişkili step/note/time silinir |
| A4 | Görev listele (ORDER ref) | Sadece ilgili siparişin görevleri gelir |
| A5 | Görev detay getir | Tüm alanlar doğru gelir |

#### B. İş Adımları (3 test)

| # | Senaryo | Beklenen Sonuç |
|---|---------|----------------|
| B1 | İş adımı ekle | OPS_TASK_STEP'e kayıt eklenir |
| B2 | İş adımı sırala | STEP_ORDER güncellenir |
| B3 | İş adımı tamamla | IS_COMPLETE=1 olur |

#### C. Notlar (2 test)

| # | Senaryo | Beklenen Sonuç |
|---|---------|----------------|
| C1 | Not ekle | OPS_TASK_NOTE'a kayıt eklenir |
| C2 | Not listele | Tarih sıralı notlar gelir |

#### D. Matris (5 test)

| # | Senaryo | Beklenen Sonuç |
|---|---------|----------------|
| D1 | WS_SET yok - istasyon seçimi göster | result_type='SELECT_WS' |
| D2 | İstasyon seçimi kaydet | OPS_TASK_WS_SET + ROW oluşur |
| D3 | Matris yükle | Sadece seçili istasyonların hücreleri gelir |
| D4 | Matris kaydet (multi-select) | VALUE_CODE='PLUS,STK' olabilir |
| D5 | % hesaplama | Sadece PLUS değeri % etkiler |

#### E. Aşama Otomasyonu (3 test)

| # | Senaryo | Beklenen Sonuç |
|---|---------|----------------|
| E1 | %0 kaydet | STATUS_ID=NULL (Boş) |
| E2 | %50 kaydet | STATUS_ID=2361 (Devam) |
| E3 | %100 kaydet | STATUS_ID=2364 (Tamamlandı) |

#### F. Proje Görevleri Etkilenmez (3 test)

| # | Senaryo | Beklenen Sonuç |
|---|---------|----------------|
| F1 | Sipariş görevi ekle | PRO_WORKS tablosu değişmez |
| F2 | Sipariş matris kaydet | PRJ_TASK_MATRIX_INSTANCE değişmez |
| F3 | Proje görevi aç | Mevcut davranış korunur |

#### G. Güvenlik (2 test)

| # | Senaryo | Beklenen Sonuç |
|---|---------|----------------|
| G1 | Farklı şirket görevi | Erişim engellenir (COMPANY_ID filtresi) |
| G2 | Yetkisiz silme | Hata döner |

### 6.3 Regresyon Test Listesi

```
□ Proje görev listesi çalışıyor
□ Proje görev detayı açılıyor
□ Proje iş adımları kaydediliyor
□ Proje takip notları çalışıyor
□ Proje zaman harcaması çalışıyor
□ Proje matris modal açılıyor
□ Proje istasyon seçimi çalışıyor
□ Proje matris kaydediliyor
□ Proje % hesaplama doğru
□ Proje aşama otomasyonu çalışıyor
```

---

## 7. Dosya Yapısı (Önerilen)

```
/V16/order/
├── cfc/
│   ├── OpsTaskManager.cfc          -- Görev CRUD işlemleri
│   └── OpsTaskMatrix.cfc           -- Matris işlemleri
├── form/
│   ├── ajax_ops_task.cfm           -- AJAX endpoint
│   └── dsp_ops_task.cfm            -- Görev modal
├── display/
│   ├── ops_task_list.cfm           -- Görev listesi
│   └── ops_task_detail.cfm         -- Görev detay
└── query/
    └── ops_task_queries.cfm        -- Sorgu include'ları

/documents/report/
├── OPS_TASK_DDL.sql                -- Tablo DDL'leri
├── OPS_TASK_SP.sql                 -- Stored Procedure'ler
└── SIPARIS_OPERASYON_GOREVLERI_ANALIZ.md  -- Bu doküman
```

---

## 8. Sonuç ve Öneriler

### 8.1 Mimari Karar Özeti

- ✅ **Seçenek B** tercih edildi: Genelleştirilmiş Görev Motoru
- ✅ Yeni tablolar açılacak: OPS_TASK + yan tablolar
- ✅ Mevcut PRO_WORKS ve PRJ_* tablolarına **dokunulmayacak**
- ✅ REF_TYPE/REF_ID ile hem proje hem sipariş desteklenecek
- ✅ Mevcut matris şablon tabloları (PRJ_TASK_MATRIX_*) ortak kullanılacak

### 8.2 Öncelikli Aksiyon

1. **DDL scriptlerini hazırla** (OPS_TASK + yan tablolar)
2. **SP'leri oluştur** (list, get, save, delete, matrix_get, matrix_save)
3. **AJAX endpoint** (ajax_ops_task.cfm)
4. **UI bileşenleri** (mevcut proje UI'ından kopyala, REF_TYPE='ORDER' için uyarla)

### 8.3 Tahmini Süre

| Faz | Süre | Çıktı |
|-----|------|-------|
| Faz-1 MVP | 2 hafta | Temel görev yönetimi + matris |
| Faz-2 Widget | 2 hafta | Zaman/belge/ajanda/ilişkili |
| Faz-3 AI | 3 hafta | Otomatik görev üretimi |
| **Toplam** | **7 hafta** | Tam modül |

---

*Doküman sonu - 2026-01-22*
