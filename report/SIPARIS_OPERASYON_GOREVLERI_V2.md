# Sipariş Operasyon Görevleri - Teknik Tasarım Dokümanı V2

**Tarih:** 2026-01-22  
**Versiyon:** 2.0  
**Proje:** Workcube ERP - Sipariş Operasyon Görevleri Modülü  
**Mimari:** Seçenek B - Genelleştirilmiş Görev Motoru (REF_TYPE/REF_ID)

---

## A) Executive Summary

1. **Faz-1 Scope**: OPS_TASK sadece `REF_TYPE='ORDER'` için kullanılacak. PROJECT_WORK kapsamı Faz-2 refactor konusu.
2. **PRO_WORKS korunur**: Mevcut proje görev motoru Faz-1'de değiştirilmez.
3. **Widget Uyumu**: Notes/Docs/Time için yeni tablo açılmaz; mevcut generic altyapılar `ACTION_SECTION='OPS_TASK'` ile kullanılır.
4. **Matris Stage**: PRJ_TASK_MATRIX_DIM (DIM_TYPE='STAGE') kullanılır; alan adları `STAGE_DIM_ID`, `STAGE_CODE`, `STAGE_NAME` olacak.
5. **REF_TYPE Constraint**: CHECK constraint ile sınırlandırılır (`'ORDER'`).
6. **Belge Entegrasyonu**: Sipariş belge altyapısı kullanılır; yeni DOC tablosu açılmaz.
7. **Matris Butonu**: Data-driven (`HAS_MATRIX=1` ve `MATRIX_TEMPLATE_ID IS NOT NULL`).
8. **Percent Kuralı**: Matris instance varsa `PERCENT_COMPLETE` readonly, tek kaynak matris.
9. **Aşama Otomasyonu**: %0→NULL, %1-99→2361, %100→2364.
10. **Deploy**: DDL → Index → SP → Endpoint → UI sırasıyla.

---

## B) Faz-1 MVP Scope

### Kapsam İçi
- Sipariş ekranında "Görevler (Operasyonlar)" sekmesi
- OPS_TASK CRUD (REF_TYPE='ORDER')
- OPS_TASK_STEP (iş adımları)
- OPS_TASK_AUDIT (audit log)
- Matris: OPS_TASK_MATRIX_INSTANCE, OPS_TASK_STAGE_SET, OPS_TASK_STAGE_SET_ROW, OPS_TASK_MATRIX_CELL_VALUE
- Notes entegrasyonu (mevcut NOTES tablosu)
- Belge entegrasyonu (mevcut sipariş belge altyapısı)
- Aşama otomasyonu (%→status)
- SP'ler: list/get/save/delete/step_save/matrix_get/matrix_save/stage_list/stage_save

### Kapsam Dışı (Faz-2+)
- PROJECT_WORK için OPS_TASK kullanımı (proje refactor)
- PRO_WORKS → OPS_TASK migrasyon/senkronizasyon
- AI otomatik görev üretimi
- Zaman harcaması modülü entegrasyonu (Faz-2)
- Ajanda entegrasyonu (Faz-2)

---

## C) Data Model (DDL)

### C.1 OPS_TASK - Ana Görev Tablosu

```sql
-- ============================================
-- OPS_TASK - Ana Görev Tablosu
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
        
        -- CHECK constraint: Faz-1'de sadece ORDER
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
        STATUS_ID           INT,                       -- NULL/2361/2364
        PRIORITY_ID         INT,
        PERCENT_COMPLETE    DECIMAL(5,2) DEFAULT 0,
        IS_ACTIVE           BIT DEFAULT 1,
        
        -- Matris
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
GO
```

### C.2 OPS_TASK_STEP - İş Adımları

```sql
-- ============================================
-- OPS_TASK_STEP - İş Adımları
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
GO
```

### C.3 OPS_TASK_AUDIT - Audit Log

```sql
-- ============================================
-- OPS_TASK_AUDIT - Audit Log
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
GO
```

### C.4 Matris Tabloları (Stage-based)

```sql
-- ============================================
-- OPS_TASK_STAGE_SET - Stage Seçim Seti
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
GO

-- ============================================
-- OPS_TASK_STAGE_SET_ROW - Seçili Stage'ler
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
GO

-- ============================================
-- OPS_TASK_MATRIX_INSTANCE - Matris Instance
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
GO

-- ============================================
-- OPS_TASK_MATRIX_CELL_VALUE - Hücre Değerleri
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
GO
```

### C.5 Index'ler (Ayrı CREATE INDEX)

```sql
-- ============================================
-- INDEX'LER
-- ============================================

-- OPS_TASK
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_OPS_TASK_REF' AND object_id = OBJECT_ID('workcube_prod.OPS_TASK'))
    CREATE INDEX IX_OPS_TASK_REF ON workcube_prod.OPS_TASK (REF_TYPE, REF_ID);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_OPS_TASK_ASSIGNED' AND object_id = OBJECT_ID('workcube_prod.OPS_TASK'))
    CREATE INDEX IX_OPS_TASK_ASSIGNED ON workcube_prod.OPS_TASK (ASSIGNED_EMP_ID);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_OPS_TASK_STATUS' AND object_id = OBJECT_ID('workcube_prod.OPS_TASK'))
    CREATE INDEX IX_OPS_TASK_STATUS ON workcube_prod.OPS_TASK (STATUS_ID);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_OPS_TASK_COMPANY' AND object_id = OBJECT_ID('workcube_prod.OPS_TASK'))
    CREATE INDEX IX_OPS_TASK_COMPANY ON workcube_prod.OPS_TASK (COMPANY_ID);

-- OPS_TASK_STEP
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_OPS_TASK_STEP_TASK' AND object_id = OBJECT_ID('workcube_prod.OPS_TASK_STEP'))
    CREATE INDEX IX_OPS_TASK_STEP_TASK ON workcube_prod.OPS_TASK_STEP (TASK_ID);

-- OPS_TASK_AUDIT
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_OPS_TASK_AUDIT_TASK' AND object_id = OBJECT_ID('workcube_prod.OPS_TASK_AUDIT'))
    CREATE INDEX IX_OPS_TASK_AUDIT_TASK ON workcube_prod.OPS_TASK_AUDIT (TASK_ID);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_OPS_TASK_AUDIT_DATE' AND object_id = OBJECT_ID('workcube_prod.OPS_TASK_AUDIT'))
    CREATE INDEX IX_OPS_TASK_AUDIT_DATE ON workcube_prod.OPS_TASK_AUDIT (CREATED_DATE);

-- OPS_TASK_STAGE_SET
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_OPS_TASK_STAGE_SET_TASK' AND object_id = OBJECT_ID('workcube_prod.OPS_TASK_STAGE_SET'))
    CREATE INDEX IX_OPS_TASK_STAGE_SET_TASK ON workcube_prod.OPS_TASK_STAGE_SET (TASK_ID);

-- OPS_TASK_STAGE_SET_ROW
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_OPS_TASK_STAGE_ROW_SET' AND object_id = OBJECT_ID('workcube_prod.OPS_TASK_STAGE_SET_ROW'))
    CREATE INDEX IX_OPS_TASK_STAGE_ROW_SET ON workcube_prod.OPS_TASK_STAGE_SET_ROW (STAGE_SET_ID);

-- OPS_TASK_MATRIX_INSTANCE
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_OPS_TASK_MATRIX_TASK' AND object_id = OBJECT_ID('workcube_prod.OPS_TASK_MATRIX_INSTANCE'))
    CREATE INDEX IX_OPS_TASK_MATRIX_TASK ON workcube_prod.OPS_TASK_MATRIX_INSTANCE (TASK_ID);

-- OPS_TASK_MATRIX_CELL_VALUE
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_OPS_TASK_CELL_INSTANCE' AND object_id = OBJECT_ID('workcube_prod.OPS_TASK_MATRIX_CELL_VALUE'))
    CREATE INDEX IX_OPS_TASK_CELL_INSTANCE ON workcube_prod.OPS_TASK_MATRIX_CELL_VALUE (INSTANCE_ID);

PRINT 'Index''ler oluşturuldu.';
GO
```

### C.6 Notes Entegrasyonu

**Yeni tablo açılmaz.** Mevcut `NOTES` tablosu kullanılır:

```sql
-- NOTES tablosu zaten mevcut (generic yapı)
-- Kullanım:
--   ACTION_SECTION = 'OPS_TASK'
--   ACTION_ID      = TASK_ID

-- Örnek sorgu:
SELECT * FROM workcube_prod.NOTES 
WHERE ACTION_SECTION = 'OPS_TASK' AND ACTION_ID = @task_id
ORDER BY RECORD_DATE DESC;
```

### C.7 Belge Entegrasyonu - Keşif Planı

**Yeni DOC tablosu açılmaz.** Sipariş belge altyapısı kullanılır.

**Keşif edilmesi gerekenler:**

1. Sipariş belgeleri hangi tabloda tutuluyor?
   - Muhtemel: `DOCUMENTS`, `DOC_RELATIONS`, `FILE_ATTACHMENTS` vb.
   
2. Belge ilişkilendirme nasıl yapılıyor?
   - `ACTION_SECTION` + `ACTION_ID` var mı?
   - Yoksa `ORDER_ID` zorunlu mu?

3. Entegrasyon stratejisi:
   - **Seçenek A** (tercih): `ACTION_SECTION='OPS_TASK'`, `ACTION_ID=TASK_ID`
   - **Seçenek B**: Belge sipariş kaydına yazılır + `RELATED_TASK_ID` alanı eklenir (minimal değişiklik)

**Not:** Belge altyapısı keşfedilmeden UI'da "Belgeler" paneli aktif edilmeyecek.

---

## D) Matrix Design

### D.1 Kavram Netleştirme

| Kavram | Kaynak | Açıklama |
|--------|--------|----------|
| **Stage** | PRJ_TASK_MATRIX_DIM (DIM_TYPE='STAGE') | Matris satırları (örn: Kesim, Montaj, Boyama) |
| **Sub-Stage** | PRJ_TASK_MATRIX_DIM (DIM_TYPE='SUB_STAGE') | Matris sütunları (örn: Başladı, Tamamlandı) |
| **Cell** | PRJ_TASK_MATRIX_CELL_DEF | Stage × Sub-Stage kesişimi |
| **Value** | PRJ_TASK_MATRIX_VALUE | Hücre değerleri (PLUS, STK, 0, YOK, -) |

**Karar:** Gerçek WORKSTATIONS tablosu **kullanılmıyor**. Matris stage'leri PRJ_TASK_MATRIX_DIM'den geliyor.

### D.2 Alan İsimlendirme Standardı

| Eski (v1) | Yeni (v2) | Açıklama |
|-----------|-----------|----------|
| WS_SET_ID | STAGE_SET_ID | Stage seçim seti |
| WS_SET_ROW_ID | STAGE_SET_ROW_ID | Stage seçim satırı |
| WORKSTATION_ID | STAGE_DIM_ID | PRJ_TASK_MATRIX_DIM.DIM_ID |
| WORKSTATION_CODE | STAGE_CODE | DIM_CODE |
| WORKSTATION_NAME | STAGE_NAME | DIM_NAME |

### D.3 sp_ops_task_matrix_get (Pseudo-code)

```
INPUT: @task_id

1. Task'ın MATRIX_TEMPLATE_ID'sini al
   - NULL ise → result_type='NO_TEMPLATE', return

2. STAGE_SET var mı kontrol et (OPS_TASK_STAGE_SET WHERE TASK_ID=@task_id)
   - Yoksa → result_type='SELECT_STAGE'
   - Tüm stage'leri döndür (PRJ_TASK_MATRIX_DIM WHERE TEMPLATE_ID=? AND DIM_TYPE='STAGE')
   - return

3. MATRIX_INSTANCE var mı kontrol et
   - result_type='MATRIX'

4. Döndür:
   - Template bilgisi
   - Seçili stage'ler (STAGE_SET_ROW)
   - Hücreler (CELL_DEF + mevcut VALUE'lar)
   - Value sözlüğü (PLUS, STK, 0, YOK, -)
```

### D.4 sp_ops_task_matrix_save (Pseudo-code)

```
INPUT: @task_id, @cells_json, @user_id

1. Template ID al (OPS_TASK.MATRIX_TEMPLATE_ID)

2. Instance yoksa oluştur (OPS_TASK_MATRIX_INSTANCE)

3. Cells JSON parse et, MERGE ile güncelle/ekle

4. Yüzde hesapla:
   - Sadece PLUS değerli hücrelerin weight toplamı / toplam weight × 100
   - CALC_PERCENT güncelle

5. Aşama otomasyonu:
   - %0 → STATUS_ID = NULL
   - %1-99 → STATUS_ID = 2361
   - %100 → STATUS_ID = 2364

6. OPS_TASK güncelle:
   - PERCENT_COMPLETE = CALC_PERCENT
   - STATUS_ID = hesaplanan değer

7. Audit log yaz
```

---

## E) Stored Procedures Listesi

| SP | Açıklama | Parametreler |
|----|----------|--------------|
| `sp_ops_task_list` | Görev listesi | @ref_type, @ref_id, @company_id |
| `sp_ops_task_get` | Görev detayı + steps | @task_id |
| `sp_ops_task_save` | Görev kaydet | @task_id, @task_head, @ref_type, @ref_id, ... |
| `sp_ops_task_delete` | Görev sil | @task_id, @user_id |
| `sp_ops_task_step_save` | İş adımları kaydet | @task_id, @steps_json |
| `sp_ops_task_notes_get` | Notları getir | @task_id (NOTES tablosundan) |
| `sp_ops_task_note_save` | Not kaydet | @task_id, @note_content (NOTES tablosuna) |
| `sp_ops_task_matrix_get` | Matris getir | @task_id |
| `sp_ops_task_matrix_save` | Matris kaydet | @task_id, @cells_json |
| `sp_ops_task_stage_list` | Stage listesi | @template_id |
| `sp_ops_task_stage_save` | Stage seçimi kaydet | @task_id, @stages_json |

---

## F) AJAX Endpoint Tasarımı

**Dosya:** `/V16/order/form/ajax_ops_task.cfm`

| Action | SP | HTTP Method |
|--------|-----|-------------|
| `list` | sp_ops_task_list | GET |
| `get` | sp_ops_task_get | GET |
| `save` | sp_ops_task_save | POST |
| `delete` | sp_ops_task_delete | POST |
| `step_save` | sp_ops_task_step_save | POST |
| `notes_get` | sp_ops_task_notes_get | GET |
| `note_save` | sp_ops_task_note_save | POST |
| `matrix_get` | sp_ops_task_matrix_get | GET |
| `matrix_save` | sp_ops_task_matrix_save | POST |
| `stage_list` | sp_ops_task_stage_list | GET |
| `stage_save` | sp_ops_task_stage_save | POST |

**Response format:** JSON

```json
{
  "success": true,
  "data": { ... },
  "message": ""
}
```

---

## G) UI/Flow

### G.1 Sipariş Ekranı - Görevler Sekmesi

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ SİPARİŞ: ORD-2026-00123                                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│ [Genel] [Kalemler] [Görevler (Operasyonlar)] [Belgeler] [Notlar]            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│ [+ Yeni Görev]                                          [Filtre] [Dışa Aktar]│
│ ┌───────────────────────────────────────────────────────────────────────────┐
│ │Sorumlu│Başlık        │Aşama     │Termin   │Öng.  │Harc. │ %   │⊞        │
│ ├───────┼──────────────┼──────────┼─────────┼──────┼──────┼─────┼─────────┤
│ │ [AK]  │Tasarım       │[Devam  ▼]│25/01/26 │ 4:30 │ 2:15 │ 50  │         │
│ │ [MB]  │Üretim Süreci │[Devam  ▼]│28/01/26 │ 8:00 │ 3:00 │ 35  │ ⊞       │
│ │ [CK]  │Kalite Kontrol│[Bekle  ▼]│30/01/26 │ 2:00 │ 0:00 │ 0   │         │
│ └───────────────────────────────────────────────────────────────────────────┘
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### G.2 Liste Kolonları

| Kolon | Alan | Açıklama |
|-------|------|----------|
| Sorumlu | ASSIGNED_EMP_ID → avatar | Çalışan avatarı/baş harfleri |
| Başlık | TASK_HEAD | Görev adı |
| Aşama | STATUS_ID → dropdown | NULL/2361/2364 |
| Termin | DEADLINE | Tarih |
| Öngörülen | ESTIMATED_MINUTES | saat:dakika formatı |
| Harcanan | ACTUAL_MINUTES | saat:dakika formatı |
| % | PERCENT_COMPLETE | Sayısal input |
| Matris | Buton | HAS_MATRIX=1 && MATRIX_TEMPLATE_ID != NULL ise göster |

### G.3 Matris Butonu Koşulu (Data-Driven)

```javascript
// String araması YAPMA
// if (task.TASK_HEAD.indexOf('ÜRETİM') !== -1) ❌

// Data-driven kontrol YAP
function shouldShowMatrixButton(task) {
    return task.HAS_MATRIX == 1 && task.MATRIX_TEMPLATE_ID != null;
}
```

### G.4 Percent Input Kuralı

```javascript
function renderPercentInput(task) {
    const hasMatrixInstance = task.MATRIX_INSTANCE_ID != null;
    const readonly = hasMatrixInstance ? 'readonly' : '';
    const title = hasMatrixInstance ? 'Matris tarafından hesaplanıyor' : 'Manuel giriş';
    
    return `<input type="number" value="${task.PERCENT_COMPLETE}" 
            ${readonly} title="${title}" 
            class="${hasMatrixInstance ? 'bg-gray-100' : ''}" />`;
}
```

### G.5 Görev Detay Modal

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ Görev Detayı                                                         [X]   │
├─────────────────────────────────────────────────────────────────────────────┤
│ Başlık: [Üretim Süreci                                               ]     │
│                                                                             │
│ Sorumlu: [Mehmet Bey    ▼]     Aşama: [Devam Ediyor     ▼]                 │
│ Termin:  [28/01/2026    📅]    Öncelik: [Yüksek         ▼]                 │
│ Öngörülen: [8] s [0] dk        Tamamlanma: [35        ] % (readonly*)      │
│                                                                             │
│ * Matris instance varsa readonly, kaynak matris                            │
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
│ Takip Notları (NOTES tablosundan)                                          │
│ ┌─────────────────────────────────────────────────────────────────────────┐│
│ │ [Rich Text Editor...]                                                   ││
│ └─────────────────────────────────────────────────────────────────────────┘│
│                                                                             │
│                                              [İptal]  [Kaydet]              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### G.6 Belge Paneli (Faz-1 Sonrası)

Belge altyapısı keşfedildikten sonra:
- Sipariş belge widget'ı `ACTION_SECTION='OPS_TASK'` ile çağrılacak
- Veya sipariş belge paneline `TASK_ID` filtresi eklenecek

---

## H) Test & Regression (25+ Test)

### H.1 Sipariş Görev CRUD (5 test)

| # | Test | Beklenen |
|---|------|----------|
| T01 | Siparişe yeni görev ekle (REF_TYPE='ORDER') | OPS_TASK'a kayıt eklenir |
| T02 | Görev güncelle (TASK_HEAD, DEADLINE) | UPDATE başarılı |
| T03 | Görev sil | Cascade delete (step, audit silinir) |
| T04 | Görev listele (ORDER_ID ile) | Sadece ilgili siparişin görevleri |
| T05 | Görev detay getir | Task + Steps + Notes gelir |

### H.2 İş Adımları (4 test)

| # | Test | Beklenen |
|---|------|----------|
| T06 | İş adımı ekle | OPS_TASK_STEP'e kayıt |
| T07 | İş adımı sırala | STEP_ORDER güncellenir |
| T08 | İş adımı tamamla | IS_COMPLETE=1 |
| T09 | Tüm adımları kaydet (JSON) | Batch insert/update |

### H.3 Notes Entegrasyonu (3 test)

| # | Test | Beklenen |
|---|------|----------|
| T10 | Not ekle (OPS_TASK üzerinden) | NOTES'a ACTION_SECTION='OPS_TASK' ile kayıt |
| T11 | Notları listele | ACTION_SECTION='OPS_TASK' AND ACTION_ID=TASK_ID |
| T12 | Proje notları etkilenmez | ACTION_SECTION='WORK' kayıtları değişmez |

### H.4 Matris - Stage Seçimi (4 test)

| # | Test | Beklenen |
|---|------|----------|
| T13 | STAGE_SET yok - stage seçimi göster | result_type='SELECT_STAGE' |
| T14 | Stage listesi getir | PRJ_TASK_MATRIX_DIM (DIM_TYPE='STAGE') |
| T15 | Stage seçimi kaydet | STAGE_SET + STAGE_SET_ROW oluşur |
| T16 | Stage seçimi düzenle | Mevcut satırlar güncellenir |

### H.5 Matris - Hücre Değerleri (4 test)

| # | Test | Beklenen |
|---|------|----------|
| T17 | Matris yükle (STAGE_SET var) | result_type='MATRIX', hücreler gelir |
| T18 | Matris kaydet (tek değer) | CELL_VALUE oluşur |
| T19 | Matris kaydet (multi-select PLUS,STK) | VALUE_CODE='PLUS,STK' |
| T20 | Matris sıfırla | CELL_VALUE'lar temizlenir |

### H.6 Yüzde + Aşama Otomasyonu (4 test)

| # | Test | Beklenen |
|---|------|----------|
| T21 | Matris kaydet → %0 | STATUS_ID=NULL |
| T22 | Matris kaydet → %50 | STATUS_ID=2361 (Devam) |
| T23 | Matris kaydet → %100 | STATUS_ID=2364 (Tamamlandı) |
| T24 | Percent input readonly (matris varsa) | Manuel giriş engelli |

### H.7 Regresyon - Proje Görevleri (3 test)

| # | Test | Beklenen |
|---|------|----------|
| T25 | Proje görev listesi çalışıyor | PRO_WORKS sorgusu değişmez |
| T26 | Proje matris çalışıyor | PRJ_TASK_MATRIX_INSTANCE değişmez |
| T27 | Proje notları çalışıyor | NOTES (ACTION_SECTION='WORK') değişmez |

### H.8 Audit (2 test)

| # | Test | Beklenen |
|---|------|----------|
| T28 | Görev oluştur → audit | ACTION_TYPE='CREATE' |
| T29 | Matris kaydet → audit | ACTION_TYPE='MATRIX_SAVE' |

---

## I) Deploy Sırası

| Sıra | Dosya | Açıklama |
|------|-------|----------|
| 01 | `OPS_TASK_DDL_V2.sql` | Tablolar (OPS_TASK, STEP, AUDIT, STAGE_SET, ROW, MATRIX_INSTANCE, CELL_VALUE) |
| 02 | `OPS_TASK_INDEX_V2.sql` | Index'ler |
| 03 | `OPS_TASK_SP_V2.sql` | Stored Procedure'ler |
| 04 | `ajax_ops_task.cfm` | AJAX endpoint |
| 05 | UI bileşenleri | Liste + Modal + Matris |

---

## J) Tablo Özeti

| Tablo | Açıklama | Yeni/Mevcut |
|-------|----------|-------------|
| `OPS_TASK` | Ana görev | YENİ |
| `OPS_TASK_STEP` | İş adımları | YENİ |
| `OPS_TASK_AUDIT` | Audit log | YENİ |
| `OPS_TASK_STAGE_SET` | Stage seçim seti | YENİ |
| `OPS_TASK_STAGE_SET_ROW` | Seçili stage'ler | YENİ |
| `OPS_TASK_MATRIX_INSTANCE` | Matris instance | YENİ |
| `OPS_TASK_MATRIX_CELL_VALUE` | Hücre değerleri | YENİ |
| `NOTES` | Takip notları | MEVCUT (ACTION_SECTION='OPS_TASK') |
| `[Sipariş Belge Tablosu]` | Belgeler | MEVCUT (keşif gerekli) |

**Toplam yeni tablo:** 7  
**Widget entegrasyonu:** NOTES mevcut, Belge keşif gerekli

---

*Doküman sonu - 2026-01-22 V2*
