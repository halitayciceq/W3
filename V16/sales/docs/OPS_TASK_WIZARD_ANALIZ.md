# OPS_TASK Görev Matrisi Wizard - Teknik Analiz Belgesi

**Versiyon:** 1.0  
**Tarih:** 2026-02-05  
**Modül:** Workcube ERP - Sipariş Operasyon Görevleri

---

## 1. YÖNETİCİ ÖZETİ

### 1.1 Amaç
Sipariş detay ekranında "+ Yeni Görev" butonuna tıklandığında açılan **Wizard Modal** ile:
- Tek görev ekleme (mevcut davranış korunacak)
- Şablondan toplu görev oluşturma
- Varsayılan sorumlular ile hızlı atama
- Üretim matrisi entegrasyonu

### 1.2 Hibrit Mimari Kararı

| Bileşen | Kapsam | Kullanıcı Profili |
|---------|--------|-------------------|
| **Modal Wizard** | Hızlı, 1-25 görev, temel düzenleme | %80 kullanıcı |
| **Gelişmiş Sayfa** | 30+ görev, toplu düzenleme, taslak | Power-user |

**Neden Hibrit?**
- Modal şişmez, ERP'de scroll-lock/focus-trap sorunları olmaz
- Kullanıcı sipariş ekranından kopmadan işini bitirir
- Karmaşık senaryolar ayrı sayfada çözülür

---

## 2. VERİTABANI ŞEMASI

### 2.1 Yeni Tablolar

```sql
-- ═══════════════════════════════════════════════════════════════
-- TABLO: OPS_TASK_TEMPLATE (Görev Şablonu Ana Tablo)
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE OPS_TASK_TEMPLATE (
    TEMPLATE_ID         INT IDENTITY(1,1) PRIMARY KEY,
    TEMPLATE_CODE       VARCHAR(50) NOT NULL,           -- 'STD_ORDER', 'CUSTOM_METAL'
    TEMPLATE_NAME       NVARCHAR(200) NOT NULL,         -- 'Standart Sipariş Görevleri'
    DESCRIPTION         NVARCHAR(500),
    COMPANY_ID          INT NOT NULL,
    ORDER_TYPE_ID       INT NULL,                       -- Sipariş tipine göre filtre
    PRODUCT_GROUP_ID    INT NULL,                       -- Ürün grubuna göre filtre
    IS_DEFAULT          BIT DEFAULT 0,                  -- Varsayılan şablon mu?
    IS_ACTIVE           BIT DEFAULT 1,
    CREATED_BY          INT,
    CREATED_DATE        DATETIME DEFAULT GETDATE(),
    UPDATED_BY          INT,
    UPDATED_DATE        DATETIME,
    
    CONSTRAINT UQ_OPS_TASK_TEMPLATE_CODE 
        UNIQUE (TEMPLATE_CODE, COMPANY_ID)
);

-- ═══════════════════════════════════════════════════════════════
-- TABLO: OPS_TASK_TEMPLATE_ITEM (Şablon Görev Satırları)
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE OPS_TASK_TEMPLATE_ITEM (
    ITEM_ID             INT IDENTITY(1,1) PRIMARY KEY,
    TEMPLATE_ID         INT NOT NULL,
    TASK_CODE           VARCHAR(50) NOT NULL,           -- 'ORDER_APPROVAL', 'DESIGN_DETAIL'
    TASK_HEAD           NVARCHAR(200) NOT NULL,         -- 'SİPARİŞ ONAYI'
    TASK_DETAIL         NVARCHAR(MAX),
    SORT_ORDER          INT DEFAULT 0,
    DEFAULT_EMP_ID      INT NULL,                       -- Varsayılan sorumlu
    DEFAULT_PRIORITY_ID INT DEFAULT 2,                  -- 1:Düşük, 2:Normal, 3:Yüksek, 4:Acil
    DEFAULT_DAYS_OFFSET INT DEFAULT 0,                  -- Sipariş tarihinden +N gün
    DEFAULT_ESTIMATED_MINUTES INT DEFAULT 0,
    HAS_PRODUCTION_MATRIX BIT DEFAULT 0,                -- Üretim matrisi gerekli mi?
    IS_MANDATORY        BIT DEFAULT 0,                  -- Zorunlu görev mi?
    IS_ACTIVE           BIT DEFAULT 1,
    
    CONSTRAINT FK_TEMPLATE_ITEM_TEMPLATE 
        FOREIGN KEY (TEMPLATE_ID) REFERENCES OPS_TASK_TEMPLATE(TEMPLATE_ID),
    CONSTRAINT UQ_TEMPLATE_ITEM_CODE 
        UNIQUE (TEMPLATE_ID, TASK_CODE)
);

-- ═══════════════════════════════════════════════════════════════
-- TABLO: OPS_TASK Güncelleme (Mevcut tabloya ekleme)
-- ═══════════════════════════════════════════════════════════════
-- Mevcut OPS_TASK tablosuna eklenecek kolonlar:
ALTER TABLE OPS_TASK ADD 
    TASK_CODE           VARCHAR(50) NULL,               -- Şablondan gelen kod
    TEMPLATE_ID         INT NULL,                       -- Hangi şablondan oluştu?
    TEMPLATE_ITEM_ID    INT NULL,                       -- Hangi satırdan oluştu?
    BATCH_ID            UNIQUEIDENTIFIER NULL;          -- Toplu oluşturma batch ID

-- Duplicate engeli için unique index
CREATE UNIQUE INDEX IX_OPS_TASK_UNIQUE_PER_ORDER 
    ON OPS_TASK (REF_TYPE, REF_ID, TASK_CODE) 
    WHERE TASK_CODE IS NOT NULL AND IS_ACTIVE = 1;

-- ═══════════════════════════════════════════════════════════════
-- TABLO: OPS_TASK_BATCH_LOG (Toplu İşlem Audit Log)
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE OPS_TASK_BATCH_LOG (
    LOG_ID              INT IDENTITY(1,1) PRIMARY KEY,
    BATCH_ID            UNIQUEIDENTIFIER NOT NULL,
    REF_TYPE            VARCHAR(20) NOT NULL,
    REF_ID              INT NOT NULL,
    TEMPLATE_ID         INT,
    ACTION_TYPE         VARCHAR(20) NOT NULL,           -- 'CREATE', 'UPDATE', 'SKIP', 'DELETE'
    TOTAL_ITEMS         INT DEFAULT 0,
    CREATED_COUNT       INT DEFAULT 0,
    UPDATED_COUNT       INT DEFAULT 0,
    SKIPPED_COUNT       INT DEFAULT 0,
    ERROR_COUNT         INT DEFAULT 0,
    ERROR_DETAILS       NVARCHAR(MAX),
    CREATED_BY          INT,
    CREATED_DATE        DATETIME DEFAULT GETDATE(),
    DURATION_MS         INT                             -- İşlem süresi
);
```

### 2.2 Varsayılan Şablon Verisi

```sql
-- Standart Sipariş Görevleri Şablonu
INSERT INTO OPS_TASK_TEMPLATE (TEMPLATE_CODE, TEMPLATE_NAME, COMPANY_ID, IS_DEFAULT)
VALUES ('STD_ORDER', 'Standart Sipariş Görevleri', 1, 1);

DECLARE @tid INT = SCOPE_IDENTITY();

INSERT INTO OPS_TASK_TEMPLATE_ITEM 
(TEMPLATE_ID, TASK_CODE, TASK_HEAD, SORT_ORDER, DEFAULT_PRIORITY_ID, IS_MANDATORY) VALUES
(@tid, 'ORDER_APPROVAL',    'SİPARİŞ ONAYI',              1,  3, 1),
(@tid, 'PAYMENT_APPROVAL',  'AVANS / ÖDEME ONAY',         2,  3, 1),
(@tid, 'SURVEY_STATUS',     'KEŞİF DURUMU',               3,  2, 0),
(@tid, 'PRE_DESIGN',        'ÖN TASARIM',                 4,  2, 0),
(@tid, 'CUSTOMER_APPROVAL', 'ÖN TASARIM MÜŞTERİ ONAYI',   5,  3, 0),
(@tid, 'DETAIL_DESIGN',     'DETAY TASARIM',              6,  2, 0),
(@tid, 'MANUFACTURING_DWG', 'İMALAT RESİMLERİ',           7,  2, 0),
(@tid, 'CUT_BEND_LIST',     'KESİM BÜKÜM LİSTELERİ',      8,  2, 0),
(@tid, 'PRODUCT_TREE',      'ÜRÜN AĞACI',                 9,  2, 0),
(@tid, 'SHIPMENT_CHECKLIST','SEVKİYAT CHECKLİST',         10, 2, 0),
(@tid, 'ELECTRICAL_TREE',   'ELEKTRİK ÜRÜN AĞACI',        11, 2, 0),
(@tid, 'MECHANICAL_TREE',   'MEKANİK ÜRÜN AĞACI',         12, 2, 0),
(@tid, 'PROCUREMENT',       'TEDARİK SÜRECİ',             13, 2, 0),
(@tid, 'PRODUCTION',        'ÜRETİM SÜRECİ',              14, 2, 1),
(@tid, 'ASSEMBLY',          'MONTAJ SÜRECİ',              15, 2, 0),
(@tid, 'SHIPMENT',          'SEVKİYAT',                   16, 2, 1),
(@tid, 'SITE_ASSEMBLY',     'SAHA MONTAJ',                17, 2, 0);
```

---

## 3. WIZARD UI AKIŞI

### 3.1 Modal Yapısı (W3C + ARIA Uyumlu)

```
┌─────────────────────────────────────────────────────────────────┐
│ ≡ Görev Oluştur                                            ✕   │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐               │
│  │ ① TEK      │ │ ② ŞABLON   │ │ ③ ÖNİZLEME  │               │
│  │   GÖREV    │ │   SEÇ      │ │   + DÜZENLE │               │
│  └─────────────┘ └─────────────┘ └─────────────┘               │
│                                                                 │
│ ─────────────────────────────────────────────────────────────── │
│                                                                 │
│  [TAB İÇERİĞİ - Seçilen moda göre değişir]                     │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│                        [İptal]  [Oluştur]                       │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ 🔗 Gelişmiş Görev Oluşturucu (30+ görev için)            │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

### 3.2 Tab 1: Tek Görev (Mevcut Davranış)

```
┌─────────────────────────────────────────────────────────────────┐
│ Başlık *          [________________________________]            │
│ Açıklama          [________________________________]            │
│                                                                 │
│ Sorumlu           [____________▼]    Öncelik  [Normal    ▼]    │
│ Aşama             [____________▼]    Termin   [2026-02-15 📅]  │
│ Öng. Süre         [__] sa [__] dk    Tamamlanma [0  ] ████░░   │
│                                                                 │
│ ☐ Matris Kullan                                                │
└─────────────────────────────────────────────────────────────────┘
```

### 3.3 Tab 2: Şablondan Seç

```
┌─────────────────────────────────────────────────────────────────┐
│ Şablon: [Standart Sipariş Görevleri              ▼]            │
│                                                                 │
│ ┌───────────────────────────────────────────────────────────┐  │
│ │ ☑ │ Görev                      │ Öncelik │ Zorunlu │ Ü.M │  │
│ ├───┼────────────────────────────┼─────────┼─────────┼─────┤  │
│ │ ☑ │ SİPARİŞ ONAYI              │ Yüksek  │   ✓     │  ☐  │  │
│ │ ☑ │ AVANS / ÖDEME ONAY         │ Yüksek  │   ✓     │  ☐  │  │
│ │ ☑ │ KEŞİF DURUMU               │ Normal  │         │  ☐  │  │
│ │ ☑ │ ÖN TASARIM                 │ Normal  │         │  ☐  │  │
│ │ ☐ │ ÖN TASARIM MÜŞTERİ ONAYI   │ Yüksek  │         │  ☐  │  │
│ │ ☑ │ DETAY TASARIM              │ Normal  │         │  ☐  │  │
│ │ ☐ │ İMALAT RESİMLERİ           │ Normal  │         │  ☐  │  │
│ │ ☐ │ KESİM BÜKÜM LİSTELERİ      │ Normal  │         │  ☐  │  │
│ │ ☑ │ ÜRETİM SÜRECİ              │ Normal  │   ✓     │  ☑  │  │
│ │ ☑ │ SEVKİYAT                   │ Normal  │   ✓     │  ☐  │  │
│ └───┴────────────────────────────┴─────────┴─────────┴─────┘  │
│                                                                 │
│ [Tümünü Seç] [Zorunluları Seç] [Temizle]                       │
│                                                                 │
│ Seçili: 8 görev | Mevcut: 3 (atlanacak) | Yeni: 5              │
└─────────────────────────────────────────────────────────────────┘
```

### 3.4 Tab 3: Önizleme + Düzenleme

```
┌─────────────────────────────────────────────────────────────────┐
│ Seçili Görevler (5)                              [← Geri]      │
│                                                                 │
│ ┌───────────────────────────────────────────────────────────┐  │
│ │ Görev              │ Sorumlu        │ Termin   │ Öncelik  │  │
│ ├────────────────────┼────────────────┼──────────┼──────────┤  │
│ │ SİPARİŞ ONAYI      │ [Ahmet K.   ▼] │ [15.02 📅]│ [Yük.▼] │  │
│ │ AVANS ONAY         │ [Muhasebe   ▼] │ [16.02 📅]│ [Yük.▼] │  │
│ │ ÖN TASARIM         │ [Mehmet T.  ▼] │ [20.02 📅]│ [Nor.▼] │  │
│ │ ÜRETİM SÜRECİ ☑Ü.M │ [Üretim Md. ▼] │ [01.03 📅]│ [Nor.▼] │  │
│ │ SEVKİYAT           │ [Lojistik   ▼] │ [15.03 📅]│ [Nor.▼] │  │
│ └───────────────────────────────────────────────────────────┘  │
│                                                                 │
│ ⚠ Ü.M = Üretim Matrisi (işaretli görevlere matris oluşturulur)│
└─────────────────────────────────────────────────────────────────┘
```

---

## 4. AJAX ENDPOINT TASARIMI

### 4.1 Endpoint: `ajax_ops_task.cfm?action=create_from_template`

#### Input JSON

```json
{
  "action": "create_from_template",
  "ref_type": "ORDER",
  "ref_id": 12345,
  "template_id": 1,
  "strategy": "skip_existing",
  "items": [
    {
      "task_code": "ORDER_APPROVAL",
      "task_head": "SİPARİŞ ONAYI",
      "assigned_emp_id": 101,
      "priority_id": 3,
      "deadline": "2026-02-15",
      "estimated_minutes": 60,
      "has_production_matrix": false
    },
    {
      "task_code": "PRODUCTION",
      "task_head": "ÜRETİM SÜRECİ",
      "assigned_emp_id": 205,
      "priority_id": 2,
      "deadline": "2026-03-01",
      "estimated_minutes": 480,
      "has_production_matrix": true,
      "matrix_template_id": 5
    }
  ]
}
```

#### Output JSON (Başarılı)

```json
{
  "success": true,
  "message": "5 görev oluşturuldu, 3 görev atlandı (mevcut)",
  "batch_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "summary": {
    "total": 8,
    "created": 5,
    "updated": 0,
    "skipped": 3,
    "errors": 0
  },
  "created_tasks": [
    {"task_id": 1001, "task_code": "ORDER_APPROVAL"},
    {"task_id": 1002, "task_code": "PRODUCTION", "matrix_instance_id": 501}
  ],
  "skipped_tasks": [
    {"task_code": "PAYMENT_APPROVAL", "reason": "Mevcut görev var", "existing_task_id": 998}
  ]
}
```

#### Output JSON (Hata)

```json
{
  "success": false,
  "message": "İşlem başarısız, değişiklikler geri alındı",
  "error_code": "TRANSACTION_FAILED",
  "error_details": "Üretim matrisi oluşturulamadı: TASK_CODE=PRODUCTION",
  "batch_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```

### 4.2 Server-Side İş Mantığı (ColdFusion)

```coldfusion
<!--- ajax_ops_task.cfm - action=create_from_template --->
<cfcase value="create_from_template">
    <cftry>
        <cfset batchId = createUUID()>
        <cfset startTime = getTickCount()>
        <cfset result = {
            success: true,
            batch_id: batchId,
            summary: {total: 0, created: 0, updated: 0, skipped: 0, errors: 0},
            created_tasks: [],
            skipped_tasks: []
        }>
        
        <!--- 1. Yetki Kontrolü --->
        <cfif NOT hasPermission("OPS_TASK_CREATE")>
            <cfthrow type="AUTH" message="Görev oluşturma yetkiniz yok">
        </cfif>
        
        <!--- 2. Sipariş Statü Kontrolü --->
        <cfquery name="qOrder" datasource="#dsn3#">
            SELECT ORDER_ID, STATUS_ID, IS_LOCKED 
            FROM ORDERS 
            WHERE ORDER_ID = <cfqueryparam value="#form.ref_id#" cfsqltype="cf_sql_integer">
        </cfquery>
        
        <cfif qOrder.STATUS_ID IN (90,95,99)><!--- Sevk/Teslim/Kapandı --->
            <cfthrow type="LOCKED" message="Bu sipariş için görev oluşturulamaz (Statü: #qOrder.STATUS_ID#)">
        </cfif>
        
        <!--- 3. JSON Parse --->
        <cfset items = deserializeJSON(form.items)>
        <cfset strategy = form.strategy ?: "skip_existing">
        <cfset result.summary.total = arrayLen(items)>
        
        <!--- 4. Transaction Başlat --->
        <cftransaction>
            <cfloop array="#items#" index="item">
                <!--- 4.1 Mevcut Görev Kontrolü (Idempotency) --->
                <cfquery name="qExisting" datasource="#dsn#">
                    SELECT TASK_ID FROM OPS_TASK 
                    WHERE REF_TYPE = <cfqueryparam value="#form.ref_type#" cfsqltype="cf_sql_varchar">
                    AND REF_ID = <cfqueryparam value="#form.ref_id#" cfsqltype="cf_sql_integer">
                    AND TASK_CODE = <cfqueryparam value="#item.task_code#" cfsqltype="cf_sql_varchar">
                    AND IS_ACTIVE = 1
                </cfquery>
                
                <cfif qExisting.recordCount GT 0>
                    <cfif strategy EQ "skip_existing">
                        <cfset result.summary.skipped++>
                        <cfset arrayAppend(result.skipped_tasks, {
                            task_code: item.task_code,
                            reason: "Mevcut görev var",
                            existing_task_id: qExisting.TASK_ID
                        })>
                        <cfcontinue>
                    <cfelseif strategy EQ "update_existing">
                        <!--- UPDATE logic here --->
                        <cfset result.summary.updated++>
                        <cfcontinue>
                    </cfif>
                </cfif>
                
                <!--- 4.2 Görev Oluştur --->
                <cfquery name="qInsert" datasource="#dsn#" result="insertResult">
                    INSERT INTO OPS_TASK (
                        TASK_CODE, TASK_HEAD, TASK_DETAIL,
                        REF_TYPE, REF_ID, TEMPLATE_ID, BATCH_ID,
                        ASSIGNED_EMP_ID, PRIORITY_ID, DEADLINE,
                        ESTIMATED_MINUTES, STATUS_ID, HAS_MATRIX,
                        COMPANY_ID, BRANCH_ID, CREATED_BY, CREATED_DATE
                    ) VALUES (
                        <cfqueryparam value="#item.task_code#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#item.task_head#" cfsqltype="cf_sql_nvarchar">,
                        <cfqueryparam value="#item.task_detail ?: ''#" cfsqltype="cf_sql_nvarchar" null="#NOT len(item.task_detail ?: '')#">,
                        <cfqueryparam value="#form.ref_type#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#form.ref_id#" cfsqltype="cf_sql_integer">,
                        <cfqueryparam value="#form.template_id#" cfsqltype="cf_sql_integer" null="#NOT val(form.template_id)#">,
                        <cfqueryparam value="#batchId#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#item.assigned_emp_id#" cfsqltype="cf_sql_integer" null="#NOT val(item.assigned_emp_id)#">,
                        <cfqueryparam value="#item.priority_id ?: 2#" cfsqltype="cf_sql_integer">,
                        <cfqueryparam value="#item.deadline#" cfsqltype="cf_sql_date" null="#NOT len(item.deadline ?: '')#">,
                        <cfqueryparam value="#item.estimated_minutes ?: 0#" cfsqltype="cf_sql_integer">,
                        1,<!--- Planlama --->
                        <cfqueryparam value="#item.has_production_matrix ?: 0#" cfsqltype="cf_sql_bit">,
                        <cfqueryparam value="#session.ep.company_id#" cfsqltype="cf_sql_integer">,
                        <cfqueryparam value="#session.ep.branch_id#" cfsqltype="cf_sql_integer">,
                        <cfqueryparam value="#session.ep.employee_id#" cfsqltype="cf_sql_integer">,
                        GETDATE()
                    )
                </cfquery>
                
                <cfset newTaskId = insertResult.generatedKey>
                <cfset taskResult = {task_id: newTaskId, task_code: item.task_code}>
                
                <!--- 4.3 Üretim Matrisi Oluştur (varsa) --->
                <cfif item.has_production_matrix ?: false>
                    <cfset matrixResult = createProductionMatrix(
                        taskId = newTaskId,
                        templateId = item.matrix_template_id ?: 0,
                        refType = form.ref_type,
                        refId = form.ref_id
                    )>
                    <cfset taskResult.matrix_instance_id = matrixResult.instanceId>
                </cfif>
                
                <cfset arrayAppend(result.created_tasks, taskResult)>
                <cfset result.summary.created++>
            </cfloop>
        </cftransaction>
        
        <!--- 5. Audit Log --->
        <cfset duration = getTickCount() - startTime>
        <cfquery datasource="#dsn#">
            INSERT INTO OPS_TASK_BATCH_LOG (
                BATCH_ID, REF_TYPE, REF_ID, TEMPLATE_ID, ACTION_TYPE,
                TOTAL_ITEMS, CREATED_COUNT, UPDATED_COUNT, SKIPPED_COUNT,
                CREATED_BY, DURATION_MS
            ) VALUES (
                <cfqueryparam value="#batchId#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#form.ref_type#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#form.ref_id#" cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#form.template_id#" cfsqltype="cf_sql_integer" null="#NOT val(form.template_id)#">,
                'CREATE',
                <cfqueryparam value="#result.summary.total#" cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#result.summary.created#" cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#result.summary.updated#" cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#result.summary.skipped#" cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#session.ep.employee_id#" cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#duration#" cfsqltype="cf_sql_integer">
            )
        </cfquery>
        
        <cfset result.message = "#result.summary.created# görev oluşturuldu">
        <cfif result.summary.skipped GT 0>
            <cfset result.message &= ", #result.summary.skipped# görev atlandı (mevcut)">
        </cfif>
        
    <cfcatch type="any">
        <cflog file="ops_task_error" type="error" 
               text="create_from_template FAILED: #cfcatch.message# | Batch: #batchId# | User: #session.ep.employee_id#">
        
        <cfset result = {
            success: false,
            message: "İşlem başarısız, değişiklikler geri alındı",
            error_code: cfcatch.type,
            error_details: cfcatch.message,
            batch_id: batchId
        }>
    </cfcatch>
    </cftry>
    
    <cfcontent type="application/json" reset="true">
    <cfoutput>#serializeJSON(result)#</cfoutput>
</cfcase>
```

---

## 5. EDGE-CASE LİSTESİ

### 5.1 Yetki ve Güvenlik

| Senaryo | Çözüm |
|---------|-------|
| Kullanıcının görev oluşturma yetkisi yok | 403 + "Yetkiniz yok" mesajı |
| Farklı şirkete ait siparişe görev ekleme | company_id kontrolü, 403 |
| Session timeout sırasında işlem | Graceful error, login redirect |

### 5.2 Sipariş Durumu

| Senaryo | Çözüm |
|---------|-------|
| Sipariş sevk edilmiş (STATUS=90) | Wizard kilitli, sadece görüntüleme |
| Sipariş iptal (STATUS=99) | Görev oluşturma engellenir |
| Sipariş kilitli (IS_LOCKED=1) | Admin override seçeneği |

### 5.3 Idempotency (Tekrar Çalıştırma)

| Senaryo | Çözüm |
|---------|-------|
| Aynı TASK_CODE ile ikinci oluşturma | strategy="skip_existing" → atla |
| Kullanıcı güncelleme istiyor | strategy="update_existing" → güncelle |
| Network hatası sonrası retry | batch_id ile önceki işlem kontrolü |

### 5.4 Performans

| Senaryo | Çözüm |
|---------|-------|
| 250+ görev seçimi | Modalda uyarı, sayfaya yönlendir |
| Yavaş veritabanı | Timeout 30sn, progress indicator |
| Büyük şablon listesi | Lazy load, pagination |

### 5.5 Yarım Kalan İşlem

| Senaryo | Çözüm |
|---------|-------|
| Transaction ortasında hata | Rollback, cflog, kullanıcıya bilgi |
| Üretim matrisi oluşturma hatası | Görev oluşur, matris atlanır, uyarı |
| Browser kapandı | Audit log'dan kurtarma |

---

## 6. GELİŞTİRME PLANI

### Faz 1: MVP (1-2 hafta)

| Görev | Süre | Öncelik |
|-------|------|---------|
| DB tabloları oluştur | 1 gün | P0 |
| Varsayılan şablon verisi | 0.5 gün | P0 |
| `action=create_from_template` endpoint | 2 gün | P0 |
| Modal Wizard Tab 1 (Tek görev) | - | Mevcut |
| Modal Wizard Tab 2 (Şablon seç) | 2 gün | P0 |
| Temel idempotency kontrolü | 1 gün | P0 |
| Audit log | 0.5 gün | P1 |

**MVP Çıktısı:** Şablondan toplu görev oluşturma çalışır

### Faz 2: Düzenleme + UX (1 hafta)

| Görev | Süre | Öncelik |
|-------|------|---------|
| Modal Wizard Tab 3 (Önizleme) | 2 gün | P1 |
| Sorumlu autocomplete (satır bazlı) | 1 gün | P1 |
| Termin otomatik hesaplama | 0.5 gün | P2 |
| Mevcut görev gösterimi (skipped) | 0.5 gün | P1 |
| Loading/progress indicator | 0.5 gün | P1 |

### Faz 3: Üretim Matrisi Entegrasyonu (1 hafta)

| Görev | Süre | Öncelik |
|-------|------|---------|
| Görev bazlı matris checkbox | 1 gün | P1 |
| Matris instance oluşturma | 2 gün | P1 |
| TASK_ID ↔ MATRIX_INSTANCE ilişkisi | 1 gün | P1 |
| Matris önizleme (modal içi) | 1 gün | P2 |

### Faz 4: Gelişmiş Sayfa (2 hafta)

| Görev | Süre | Öncelik |
|-------|------|---------|
| Ayrı sayfa UI tasarımı | 2 gün | P2 |
| Toplu düzenleme (multi-select) | 2 gün | P2 |
| Taslak kaydetme | 1 gün | P3 |
| Import/Export | 2 gün | P3 |
| Gelişmiş filtreleme | 1 gün | P2 |

### Faz 5: Admin & Raporlama (1 hafta)

| Görev | Süre | Öncelik |
|-------|------|---------|
| Şablon yönetim ekranı | 2 gün | P2 |
| Default sorumlu atama UI | 1 gün | P2 |
| Batch log görüntüleme | 1 gün | P3 |
| Performans optimizasyonu | 1 gün | P2 |

---

## 7. DOSYA YAPISI

```
/V16/sales/
├── form/
│   ├── dsp_ops_task.cfm              # Tek görev formu (mevcut)
│   ├── dsp_ops_task_wizard.cfm       # Wizard modal (YENİ)
│   └── ops_task_builder.cfm          # Gelişmiş sayfa (FAZ 4)
├── display/
│   └── ops_task_list.cfm             # Görev listesi (mevcut)
├── query/
│   └── ajax_ops_task.cfm             # AJAX endpoint (güncelleme)
├── docs/
│   ├── OPS_TASK_PROJE_DURUMU.md
│   └── OPS_TASK_WIZARD_ANALIZ.md     # Bu belge
└── admin/
    └── ops_task_template_admin.cfm   # Şablon yönetimi (FAZ 5)
```

---

## 8. ZORUNLU KURALLAR (KIRMIZI ÇİZGİ)

> ⚠️ **Bu kurallar değiştirilemez. Tüm tasarım ve geliştirme bu kurallara uyacaktır.**

### 8.1 Merkezi Kilit ve İş Kuralı

Görev oluşturma/güncelleme kararı **tek noktadan** verilecek.

```coldfusion
<!--- /V16/sales/cfc/ops_task_service.cfc --->
<cffunction name="canEditTasks" returntype="struct" access="public">
    <cfargument name="ref_type" type="string" required="true">
    <cfargument name="ref_id" type="numeric" required="true">
    <cfargument name="employee_id" type="numeric" required="true">
    <cfargument name="action" type="string" default="create"> <!--- create|update|delete --->
    
    <cfset var result = {allowed: false, reason: "", override_available: false}>
    
    <!--- 1. Sipariş/Proje Statüsü --->
    <!--- 2. Kilitlenmiş Kayıt (IS_LOCKED) --->
    <!--- 3. Sevk/Teslim Sonrası Yasağı --->
    <!--- 4. Yetkili Rol veya Admin Override --->
    
    <cfreturn result>
</cffunction>
```

**Kontrol Noktaları:**

| Kontrol | Koşul | Sonuç |
|---------|-------|-------|
| Statü | STATUS_ID IN (90,95,99) | Engelle |
| Kilit | IS_LOCKED = 1 | Engelle (override ile açılabilir) |
| Sevk/Teslim | Sevk tarihi geçmiş | Engelle |
| Yetki | Rol kontrolü | Engelle veya İzin Ver |

**UI ve Backend aynı `canEditTasks()` fonksiyonunu kullanacak.**

---

### 8.2 Yetki Ayrımı (Role-Based)

Tek yetki yeterli değil. Aşağıdaki yetkiler **ayrı ayrı** kontrol edilecek:

| Yetki Kodu | Açıklama | Varsayılan |
|------------|----------|------------|
| `OPS_TASK_CREATE` | Tek görev oluşturma | Tüm kullanıcılar |
| `OPS_TASK_CREATE_BATCH` | Toplu görev oluşturma | Proje yöneticisi |
| `OPS_TASK_UPDATE_EXISTING` | Mevcut görevi güncelleme | Sorumlu + Yönetici |
| `OPS_TASK_DELETE` | Görev silme | Sadece yönetici |
| `OPS_TASK_ADMIN_OVERRIDE` | Kilitli kayıtlarda işlem | Sadece admin |

```coldfusion
<!--- Yetki kontrolü örneği --->
<cfif strategy EQ "update_existing" AND NOT hasPermission("OPS_TASK_UPDATE_EXISTING")>
    <cfthrow type="AUTH" message="Mevcut görevleri güncelleme yetkiniz yok">
</cfif>
```

---

### 8.3 Idempotency + Concurrency

| Kural | Uygulama |
|-------|----------|
| Unique Index | `TASK_CODE + REF_TYPE + REF_ID` (IS_ACTIVE=1) |
| Dry-Run | Batch öncesi `action=preview` ile önizleme |
| Skip Reporting | Unique'e takılan kayıtlar SKIP olarak raporlanır |
| Batch Cache | Aynı BATCH_ID tekrar gelirse önceki sonuç döner |

```sql
-- Batch sonuç cache kontrolü
SELECT * FROM OPS_TASK_BATCH_LOG 
WHERE BATCH_ID = @batch_id AND ACTION_TYPE = 'CREATE'
```

**Concurrency Stratejisi:**
- Aynı REF_ID için eşzamanlı batch → İlk gelen kazanır
- Row-level locking kullanılmayacak (performans)
- Unique index hatası → Skip + Log

---

### 8.4 Veri Bütünlüğü – Template Yaşam Döngüsü

| Kural | Açıklama |
|-------|----------|
| Silme Yasağı | Template **silinmez**, `IS_ACTIVE=0` yapılır |
| Referans Korunur | OPS_TASK.TEMPLATE_ID ve TEMPLATE_ITEM_ID değişmez |
| Bağımsızlık | Template güncellemesi mevcut görevleri **etkilemez** |

```sql
-- Template soft delete
UPDATE OPS_TASK_TEMPLATE 
SET IS_ACTIVE = 0, UPDATED_DATE = GETDATE(), UPDATED_BY = @emp_id
WHERE TEMPLATE_ID = @template_id

-- Mevcut görevler etkilenmez, TEMPLATE_ID referansı kalır
```

---

### 8.5 Termin Hesaplama Standardı

| Parametre | Değer |
|-----------|-------|
| Saat Dilimi | **Europe/Istanbul** (UTC+3) |
| Gün Tipi | **Takvim günü** (iş günü DEĞİL) |
| Başlangıç Noktası | Sipariş CREATED_DATE veya PLANNED_START |

```coldfusion
<!--- Termin hesaplama --->
<cfset baseDate = isDate(order.PLANNED_START) ? order.PLANNED_START : order.CREATED_DATE>
<cfset deadline = dateAdd("d", item.DEFAULT_DAYS_OFFSET, baseDate)>

<!--- Saat dilimi: Europe/Istanbul --->
<cfset deadline = dateConvert("local2utc", deadline)>
```

> **NOT:** İş günü hesabı gerekirse Faz 5'te `getWorkingDays()` fonksiyonu eklenebilir.

---

### 8.6 Performans – N+1 YASAĞI

**Loop içinde DB çağrısı YASAKTIR.**

```coldfusion
<!--- ❌ YANLIŞ - N+1 Sorgu --->
<cfloop array="#items#" index="item">
    <cfquery name="qCheck">
        SELECT TASK_ID FROM OPS_TASK WHERE TASK_CODE = '#item.task_code#'...
    </cfquery>
</cfloop>

<!--- ✅ DOĞRU - Tek Sorgu --->
<cfset taskCodes = items.map(i => i.task_code)>
<cfquery name="qExisting">
    SELECT TASK_ID, TASK_CODE FROM OPS_TASK 
    WHERE REF_TYPE = <cfqueryparam value="#ref_type#">
    AND REF_ID = <cfqueryparam value="#ref_id#">
    AND TASK_CODE IN (<cfqueryparam value="#arrayToList(taskCodes)#" list="true">)
    AND IS_ACTIVE = 1
</cfquery>

<!--- Map'e çevir --->
<cfset existingMap = {}>
<cfloop query="qExisting">
    <cfset existingMap[qExisting.TASK_CODE] = qExisting.TASK_ID>
</cfloop>
```

---

### 8.7 Audit ve İzlenebilirlik

**Mevcut:** `OPS_TASK_BATCH_LOG` (batch özet)

**Eklenen:** `OPS_TASK_BATCH_LOG_ITEM` (satır bazlı detay)

```sql
CREATE TABLE OPS_TASK_BATCH_LOG_ITEM (
    LOG_ITEM_ID     INT IDENTITY(1,1) PRIMARY KEY,
    BATCH_ID        UNIQUEIDENTIFIER NOT NULL,
    TASK_CODE       VARCHAR(50) NOT NULL,
    ACTION          VARCHAR(20) NOT NULL,       -- 'CREATED', 'UPDATED', 'SKIPPED', 'ERROR'
    EXISTING_TASK_ID INT NULL,                  -- Mevcut görev varsa
    NEW_TASK_ID     INT NULL,                   -- Yeni oluşturulan
    REASON          NVARCHAR(500),              -- "Mevcut görev var", "Yetki yok" vb.
    ERROR_DETAIL    NVARCHAR(MAX),
    CREATED_DATE    DATETIME DEFAULT GETDATE(),
    
    INDEX IX_BATCH_LOG_ITEM_BATCH (BATCH_ID)
);
```

**İzlenebilirlik Soruları:**

| Soru | Cevap Kaynağı |
|------|---------------|
| Bu görev neden oluşmadı? | `OPS_TASK_BATCH_LOG_ITEM.REASON` |
| Kim, ne zaman toplu oluşturma yaptı? | `OPS_TASK_BATCH_LOG.CREATED_BY/DATE` |
| Hangi görevler atlandı? | `ACTION = 'SKIPPED'` filtresi |

---

### 8.8 Matris Entegrasyonu – Mod Seçimi

**İki Çalışma Modu:**

| Mod | Davranış | Kullanım |
|-----|----------|----------|
| `strict` | Matris fail → **Tüm işlem rollback** | Kritik siparişler |
| `lenient` | Matris fail → Görev oluşur, `HAS_MATRIX=0`, uyarı loglanır | **Varsayılan** |

```coldfusion
<!--- Matris modu --->
<cfparam name="form.matrix_mode" default="lenient">

<cfif item.has_production_matrix>
    <cftry>
        <cfset matrixResult = createProductionMatrix(...)>
        <cfset taskResult.matrix_instance_id = matrixResult.instanceId>
    <cfcatch>
        <cfif form.matrix_mode EQ "strict">
            <cfthrow type="MATRIX_FAIL" message="Üretim matrisi oluşturulamadı: #item.task_code#">
        <cfelse>
            <!--- Lenient: Görev oluşur, matris atlanır --->
            <cfset item.has_production_matrix = false>
            <cflog file="ops_task_warning" text="Matrix creation failed for #item.task_code#: #cfcatch.message#">
            <cfset taskResult.matrix_warning = cfcatch.message>
        </cfif>
    </cfcatch>
    </cftry>
</cfif>
```

> **VARSAYILAN MOD: `lenient`**

---

### 8.9 Hata Yönetimi (Canlı / Dev Ayrımı)

| Ortam | Kullanıcıya Gösterilen | Log'a Yazılan |
|-------|------------------------|---------------|
| **Production** | Kısa + Kodlu mesaj | Tam detay |
| **Development** | Tam detay (yetkili ise) | Tam detay |

```coldfusion
<cfcatch type="any">
    <cfset errorCode = "ERR_" & uCase(left(createUUID(), 8))>
    
    <!--- Detaylı log --->
    <cflog file="ops_task_error" type="error" 
           text="#errorCode# | #cfcatch.type# | #cfcatch.message# | #cfcatch.detail# | User: #session.ep.employee_id#">
    
    <!--- Kullanıcıya kısa mesaj --->
    <cfset userMessage = "İşlem başarısız. Hata kodu: #errorCode#">
    
    <!--- Dev kullanıcı için detay --->
    <cfif session.ep.is_dev_user ?: false>
        <cfset userMessage &= " | #cfcatch.message#">
    </cfif>
    
    <cfset result = {success: false, message: userMessage, error_code: errorCode}>
</cfcatch>
```

---

### 8.10 UAT / Test Checklist

| # | Senaryo | Beklenen Sonuç | Durum |
|---|---------|----------------|-------|
| 1 | Aynı şablon 2 kez çalıştırma (skip) | İlk: Oluştur, İkinci: Tümü atla | ⬜ |
| 2 | Aynı şablon 2 kez çalıştırma (update) | İlk: Oluştur, İkinci: Güncelle | ⬜ |
| 3 | Paralel batch çalıştırma (2 kullanıcı) | İlk kazanır, ikinci skip | ⬜ |
| 4 | Kilitli siparişte işlem | 403 + "Sipariş kilitli" | ⬜ |
| 5 | Yetkisiz kullanıcı (batch) | 403 + "Yetkiniz yok" | ⬜ |
| 6 | 25+ görev performans testi | < 3 saniye | ⬜ |
| 7 | 100+ görev performans testi | < 10 saniye | ⬜ |
| 8 | Matris strict mode fail | Tüm işlem rollback | ⬜ |
| 9 | Matris lenient mode fail | Görev oluşur, matris atlanır | ⬜ |
| 10 | Network hatası sonrası retry | Aynı BATCH_ID ile devam | ⬜ |
| 11 | Template silinmiş (IS_ACTIVE=0) | Mevcut görevler etkilenmez | ⬜ |
| 12 | Dry-run preview | Sadece özet döner, DB değişmez | ⬜ |

---

## 9. ZORUNLU UYGULAMA SIRASI

> ⚠️ **Bu sıralama DEĞİŞTİRİLEMEZ. Her adım önceki adıma bağlıdır.**

```
┌─────────────────────────────────────────────────────────────────┐
│  ADIM 1: DB Şeması + Index + Audit Tabloları                   │
│  ───────────────────────────────────────────────────────────── │
│  • OPS_TASK_TEMPLATE                                           │
│  • OPS_TASK_TEMPLATE_ITEM                                      │
│  • OPS_TASK_BATCH_LOG                                          │
│  • OPS_TASK_BATCH_LOG_ITEM (yeni)                              │
│  • OPS_TASK tablosuna TASK_CODE, TEMPLATE_ID, BATCH_ID         │
│  • Unique index: REF_TYPE + REF_ID + TASK_CODE                 │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  ADIM 2: Merkezi Kilit & Yetki Fonksiyonu                      │
│  ───────────────────────────────────────────────────────────── │
│  • ops_task_service.cfc                                        │
│  • canEditTasks(ref_type, ref_id, employee_id, action)         │
│  • hasPermission(permission_code)                              │
│  • Yetki tanımları: OPS_TASK_CREATE, _BATCH, _UPDATE, _ADMIN   │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  ADIM 3: Idempotent Batch Backend                              │
│  ───────────────────────────────────────────────────────────── │
│  • ajax_ops_task.cfm → action=create_from_template             │
│  • action=preview (dry-run)                                    │
│  • N+1 yasağı uygulanmış tek sorgu                             │
│  • Batch cache kontrolü                                        │
│  • Audit log (batch + item)                                    │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  ADIM 4: Matris Entegrasyonu                                   │
│  ───────────────────────────────────────────────────────────── │
│  • strict / lenient mod desteği                                │
│  • Mevcut üretim matrisi altyapısı ile entegrasyon             │
│  • TASK_ID ↔ MATRIX_INSTANCE_ID ilişkisi                       │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  ADIM 5: Wizard UI                                             │
│  ───────────────────────────────────────────────────────────── │
│  • dsp_ops_task_wizard.cfm                                     │
│  • Tab 1: Tek görev (mevcut)                                   │
│  • Tab 2: Şablondan seç                                        │
│  • Tab 3: Önizleme + düzenleme                                 │
│  • pkg-* isim uzayı + ARIA uyumlu                              │
└─────────────────────────────────────────────────────────────────┘
```

---

## 10. W3 STANDART UYUMLULUK (KIRMIZI ÇİZGİ)

| Standart | Uygulama | Zorunlu |
|----------|----------|---------|
| **pkg-* UI İsim Uzayı** | Tüm CSS class'ları `pkg-ops-task-*` ile başlar | ✅ |
| **ARIA Modal/Tab** | `role="dialog"`, `aria-modal="true"`, `aria-labelledby` | ✅ |
| **encodeFor* Output** | `encodeForHTML()`, `encodeForJavaScript()` | ✅ |
| **cftry/cfcatch + cflog** | Tüm AJAX action'ları try/catch içinde | ✅ |
| **fetch + JSON Endpoint** | `Content-Type: application/json`, `serializeJSON()` | ✅ |
| **W3C HTML/CSS/JS** | Valid HTML5, CSS3, ES6+ | ✅ |

```html
<!-- ARIA Uyumlu Modal Örneği -->
<div id="pkg-ops-task-wizard" 
     role="dialog" 
     aria-modal="true" 
     aria-labelledby="pkg-ops-task-wizard-title"
     class="pkg-ops-task-modal">
    <h2 id="pkg-ops-task-wizard-title">Görev Oluştur</h2>
    ...
</div>
```

---

## 11. ONAY SONRASI ADIMLAR

1. ✅ Bu analiz belgesi onaylandı (v1.1)
2. ✅ **ADIM 1:** DB tabloları + index oluşturuldu → `sql/OPS_TASK_WIZARD_SCHEMA.sql`
3. ✅ **ADIM 2:** Merkezi kilit & yetki fonksiyonu → `cfc/ops_task_service.cfc`
4. ✅ **ADIM 3:** Idempotent batch backend → `query/ajax_ops_task.cfm` (get_templates, batch_preview, batch_create)
5. ✅ **ADIM 4:** Matris entegrasyonu (TODO placeholder) → Lenient mode hazır
6. ✅ **ADIM 5:** Wizard UI → `form/dsp_ops_task_wizard.cfm`
7. ⏳ UAT test checklist uygulanacak

---

## 12. OLUŞTURULAN DOSYALAR

| Dosya | Açıklama |
|-------|----------|
| `sql/OPS_TASK_WIZARD_SCHEMA.sql` | DB şeması, indexler, audit tabloları, varsayılan şablon |
| `cfc/ops_task_service.cfc` | Merkezi kilit, yetki, şablon sorguları, audit log |
| `query/ajax_ops_task.cfm` | Yeni action'lar: get_templates, get_template_items, batch_preview, batch_create |
| `form/dsp_ops_task_wizard.cfm` | 3 tab'lı wizard modal: Tek Görev, Şablondan Oluştur, Önizleme |

---

## 13. DSN MATRİSİ VE CFQUERY ÖRNEKLERİ

### 13.1 Tablo → DSN Matrisi

| Tablo | DSN | Datasource | Tam İsim |
|-------|-----|------------|----------|
| **OPS_TASK** | Main | `workcube_prod` | `workcube_prod.OPS_TASK` |
| **EMPLOYEES** | Main | `workcube_prod` | `workcube_prod.EMPLOYEES` |
| **OPS_TASK_TEMPLATE** | Şirket | `workcube_prod_1` | `workcube_prod_1.OPS_TASK_TEMPLATE` |
| **OPS_TASK_TEMPLATE_ITEM** | Şirket | `workcube_prod_1` | `workcube_prod_1.OPS_TASK_TEMPLATE_ITEM` |
| **OPS_TASK_BATCH_LOG** | Şirket | `workcube_prod_1` | `workcube_prod_1.OPS_TASK_BATCH_LOG` |
| **OPS_TASK_BATCH_LOG_ITEM** | Şirket | `workcube_prod_1` | `workcube_prod_1.OPS_TASK_BATCH_LOG_ITEM` |
| **ORDERS** | Şirket | `workcube_prod_1` | `workcube_prod_1.ORDERS` |

### 13.2 Örnek CFQUERY'ler

```cfml
<!--- DSN SABİTLERİ --->
<cfset dsn = "workcube_prod">
<cfset dsn3 = "workcube_prod_1">

<!--- OPS_TASK SELECT (DSN: workcube_prod) --->
<cfquery name="qTasks" datasource="#dsn#">
    SELECT TASK_ID, TASK_HEAD, TASK_CODE, STATUS_ID
    FROM OPS_TASK
    WHERE REF_TYPE = <cfqueryparam value="ORDER" cfsqltype="cf_sql_varchar">
    AND REF_ID = <cfqueryparam value="#ref_id#" cfsqltype="cf_sql_integer">
    AND IS_ACTIVE = 1
</cfquery>

<!--- OPS_TASK INSERT (DSN: workcube_prod) --->
<cfquery datasource="#dsn#">
    INSERT INTO OPS_TASK (TASK_CODE, TASK_HEAD, REF_TYPE, REF_ID, COMPANY_ID, IS_ACTIVE, CREATED_DATE)
    VALUES (
        <cfqueryparam value="#task_code#" cfsqltype="cf_sql_varchar">,
        <cfqueryparam value="#task_head#" cfsqltype="cf_sql_nvarchar">,
        <cfqueryparam value="ORDER" cfsqltype="cf_sql_varchar">,
        <cfqueryparam value="#ref_id#" cfsqltype="cf_sql_integer">,
        <cfqueryparam value="#company_id#" cfsqltype="cf_sql_integer">,
        1, GETDATE()
    )
</cfquery>

<!--- TEMPLATE SELECT (DSN3: workcube_prod_1) --->
<cfquery name="qTemplates" datasource="#dsn3#">
    SELECT TEMPLATE_ID, TEMPLATE_CODE, TEMPLATE_NAME
    FROM OPS_TASK_TEMPLATE
    WHERE COMPANY_ID = <cfqueryparam value="#company_id#" cfsqltype="cf_sql_integer">
    AND IS_ACTIVE = 1
</cfquery>

<!--- CROSS-DB JOIN (Template Items + Employees) --->
<cfquery name="qItems" datasource="#dsn3#">
    SELECT i.*, ISNULL(e.EMPLOYEE_NAME + ' ' + e.EMPLOYEE_SURNAME, '') AS EMP_NAME
    FROM OPS_TASK_TEMPLATE_ITEM i
    LEFT JOIN workcube_prod.EMPLOYEES e ON e.EMPLOYEE_ID = i.DEFAULT_EMP_ID
    WHERE i.TEMPLATE_ID = <cfqueryparam value="#template_id#" cfsqltype="cf_sql_integer">
</cfquery>

<!--- BATCH LOG INSERT (DSN3: workcube_prod_1) --->
<cfquery datasource="#dsn3#">
    INSERT INTO OPS_TASK_BATCH_LOG (BATCH_ID, REF_TYPE, REF_ID, ACTION_TYPE, CREATED_DATE)
    VALUES (
        <cfqueryparam value="#batch_id#" cfsqltype="cf_sql_varchar">,
        <cfqueryparam value="ORDER" cfsqltype="cf_sql_varchar">,
        <cfqueryparam value="#ref_id#" cfsqltype="cf_sql_integer">,
        <cfqueryparam value="CREATE" cfsqltype="cf_sql_varchar">,
        GETDATE()
    )
</cfquery>
```

### 13.3 W3 Checklist

| Standart | Durum | Açıklama |
|----------|-------|----------|
| **pkg-* UI İsim Uzayı** | ✅ | `pkg-wizard-*`, `pkg-template-*`, `pkg-preview-*` |
| **ARIA Modal/Tab** | ✅ | `role="dialog"`, `aria-modal="true"`, `aria-labelledby`, `role="tabpanel"` |
| **encodeFor* Output** | ✅ | `encodeForHTML()`, `encodeForJavaScript()` kullanımı |
| **cftry/cfcatch + cflog** | ✅ | Tüm action'larda hata yakalama ve loglama |
| **fetch + JSON Endpoint** | ✅ | `Content-Type: application/json`, `serializeJSON()` |
| **Datasource Açık Yazım** | ✅ | Her cfquery'de `datasource="#dsn#"` veya `datasource="#dsn3#"` |
| **dbo. Kullanılmaz** | ✅ | Format: `workcube_prod_1.TABLE_NAME` |

---

**Belge Durumu:** FAZ-1 MVP Tamamlandı (v2.0) - DSN Kuralları Uygulandı  
**Sonraki Adım:** SQL script çalıştırılacak + UAT test  
**Güncelleme Tarihi:** 2026-02-05
