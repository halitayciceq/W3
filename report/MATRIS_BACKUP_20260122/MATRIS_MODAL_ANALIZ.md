# Matris Modal Geliştirme Analizi
**Tarih:** 2026-01-21
**Proje:** Workcube ERP - Üretim Matrisi

---

## 1. Özet

Görev matris modalı için kapsamlı geliştirmeler yapıldı:
- Toggle özelliği (buton tekrar tıklanınca deaktif)
- Sıfırla butonu
- Legend (buton tanımlamaları)
- Veritabanı kayıt/yükleme düzeltmeleri
- Sadece `+` işaretinin yüzdeyi etkilemesi

---

## 2. Değiştirilen Dosyalar

### 2.1 Frontend
**Dosya:** `/Volumes/prod/documents/report/5560605B-BA40-44A6-1E209FF687575FC2.cfm`

**Değişiklikler:**
- `selectMatrixValue()` - Toggle özelliği eklendi
- `resetMatrix()` - Tüm seçimleri sıfırlama fonksiyonu
- `calcMatrixPercentValue()` - Yüzde hesaplama (sadece PLUS)
- `saveMatrix()` - Tüm hücreleri gönderme (boş dahil)
- Legend HTML ve CSS eklendi
- Sıfırla butonu eklendi
- Debug logları eklendi

**scoreMap (Sadece PLUS etkiler):**
```javascript
var scoreMap = {PLUS: 1.00, STK: 0.00, ZERO: 0.00, YOK: 0.00, MINUS: 0.00};
```

### 2.2 Backend - AJAX Endpoint
**Dosya:** `/Volumes/prod/V16/project/form/ajax_task_matrix.cfm`

**Değişiklikler:**
- Debug için `debug_json_values` ve `debug_json_length` eklendi

### 2.3 Stored Procedures
**Dosya:** `/Volumes/prod/documents/report/PRJ_TASK_MATRIX_SP_FIX.sql`

**sp_prj_task_matrix_save değişiklikleri:**
- `workcube_prod.` şeması eklendi (tüm tablo referanslarına)
- `COLLATE Turkish_CI_AS` - Collation uyumsuzluğu düzeltildi
- Temp table ile JSON parse
- Sadece PLUS değerler yüzdeyi etkiler:
```sql
@sum_weighted_score = ISNULL(SUM(CASE WHEN VD.VALUE_CODE = 'PLUS' THEN CD.WEIGHT ELSE 0 END), 0)
```

---

## 3. Karşılaşılan Sorunlar ve Çözümler

### 3.1 Tablo Bulunamadı Hatası
**Sorun:** `Invalid object name 'PRJ_TASK_MATRIX_CELL_VALUE'`
**Çözüm:** DDL scriptleri veritabanında çalıştırıldı

### 3.2 Collation Conflict
**Sorun:** `cannot resolve the collation conflict between SQL_Latin1_General_CP1_CI_AS and Turkish_CI_AS`
**Çözüm:** Temp table'a `COLLATE Turkish_CI_AS` eklendi

### 3.3 Şema Sorunu
**Sorun:** Stored procedure'ler `dbo.` şeması kullanıyordu, Workcube `workcube_prod.` kullanıyor
**Çözüm:** Tüm tablo referanslarına `workcube_prod.` prefix eklendi

### 3.4 Seçimler Kaydedilmiyordu
**Sorun:** Frontend'den gelen JSON'da sadece dolu değerler gönderiliyordu
**Çözüm:** `saveMatrix()` tüm hücreleri göndermek üzere güncellendi (boş olanlar dahil)

### 3.5 VALUE_ID NULL Kalıyordu
**Sorun:** UPDATE sorgusu çalışmıyordu
**Çözüm:** `workcube_prod.` şeması ve `INNER JOIN` → `LEFT JOIN` düzeltmeleri

---

## 4. Veritabanı Yapısı

### Tablolar (workcube_prod şeması)
- `PRJ_TASK_MATRIX_TEMPLATE` - Matris şablonları
- `PRJ_TASK_MATRIX_DIM` - Boyutlar (Stage/SubStage)
- `PRJ_TASK_MATRIX_CELL_DEF` - Hücre tanımları
- `PRJ_TASK_MATRIX_VALUE_DICT` - Değer sözlüğü
- `PRJ_TASK_MATRIX_INSTANCE` - Proje+Görev instance
- `PRJ_TASK_MATRIX_CELL_VALUE` - Hücre değerleri
- `PRJ_TASK_MATRIX_AUDIT` - Audit log

### Stored Procedures
- `workcube_prod.sp_prj_task_matrix_get` - Matris verilerini getir
- `workcube_prod.sp_prj_task_matrix_save` - Matris değerlerini kaydet

---

## 5. Yedek Dosyalar

| Dosya | Yedek |
|-------|-------|
| 5560605B-BA40-44A6-1E209FF687575FC2.cfm | .backup_20260121_1105, .backup_20260121_1444 |
| PRJ_TASK_MATRIX_SP_FIX.sql | .backup_20260121_1444 |
| ajax_task_matrix.cfm | .backup_20260121_1444 |

---

## 6. Test Kontrol Listesi

- [x] Modal açılıyor
- [x] Butonlar tıklanabiliyor
- [x] Toggle çalışıyor (tekrar tıklayınca deaktif)
- [x] Sıfırla butonu çalışıyor
- [x] Legend görünüyor
- [x] Kaydet çalışıyor
- [x] Seçimler veritabanına kaydediliyor
- [x] Modal tekrar açıldığında seçimler yükleniyor
- [x] Sadece + işareti yüzdeyi etkiliyor
- [x] Input alanı matris yüzdesiyle güncelleniyor

---

## 7. Kullanım

### Matris Açma
```javascript
openMatrixModal(projectId, workId);
```

### Buton Değerleri
| Kod | Label | Açıklama | % Etkisi |
|-----|-------|----------|----------|
| PLUS | + | Üretim Tamamlandı | ✓ Etkiler |
| STK | STK | Hazır Stok Kullanılacak | ✗ |
| ZERO | 0 | Üretim Tamamlandı | ✗ |
| YOK | YOK | Üretim Yok | ✗ |
| MINUS | - | Üretim Tamamlanmadı | ✗ |

---

## 8. Notlar

- DSN: `workcube_prod` (Main veritabanı)
- Şema: `workcube_prod` (dbo değil)
- Collation: `Turkish_CI_AS`
- Template: `URETIM_SURECI`

---

## 9. Yeni Geliştirme: Dinamik İstasyon Seçimi (2026-01-21 14:58)

### 9.1 Yeni Akış

1. **İstasyon Seçimi Adımı**
   - Modal açılınca önce istasyon listesi gösterilir
   - Kullanıcı çoklu seçim yapar
   - "Matrisi Oluştur" butonuna tıklar

2. **Matris Adımı**
   - Sadece seçilen istasyonların işlem satırları görünür
   - Butonlar (+/STK/0/YOK/-) aynı
   - Anlık % hesap + Kaydet

### 9.2 Yeni Tablolar

**PRJ_TASK_WS_SET** (Görev için istasyon seti)
| Alan | Tip | Açıklama |
|------|-----|----------|
| WS_SET_ID | INT PK | Identity |
| PROJECT_ID | INT FK | PRO_PROJECTS.PROJECT_ID |
| WORK_ID | INT FK | PRO_WORKS.WORK_ID |
| CREATED_BY | INT | Oluşturan kullanıcı |
| CREATED_DATE | DATETIME | Oluşturma tarihi |
| UPDATED_BY | INT | Güncelleyen kullanıcı |
| UPDATED_DATE | DATETIME | Güncelleme tarihi |

**PRJ_TASK_WS_SET_ROW** (Seçilen istasyon satırları)
| Alan | Tip | Açıklama |
|------|-----|----------|
| WS_SET_ROW_ID | INT PK | Identity |
| WS_SET_ID | INT FK | PRJ_TASK_WS_SET.WS_SET_ID |
| WORKSTATION_ID | INT | ERP workstation master PK |
| WORKSTATION_CODE | NVARCHAR(50) | Snapshot |
| WORKSTATION_NAME | NVARCHAR(200) | Snapshot |
| SORT_ORDER | INT | Sıralama |

**PRJ_TASK_MATRIX_INSTANCE** (Güncelleme)
- WS_SET_ID alanı eklendi (FK → PRJ_TASK_WS_SET)

### 9.3 Yeni/Güncellenen SP'ler

| SP | Açıklama |
|----|----------|
| `sp_prj_task_ws_set_save` | İstasyon seçimini kaydet |
| `sp_prj_task_ws_list` | ERP workstation listesi |
| `sp_prj_task_matrix_get` | WS_SET kontrolü eklendi |
| `sp_prj_task_matrix_save` | Seçili istasyonlar desteği |

### 9.4 sp_prj_task_matrix_get Mantığı

```
IF WS_SET yok:
    result_type = 'SELECT_WS'
    → İstasyon seçimi UI göster
ELSE:
    result_type = 'MATRIX'
    → Sadece seçilen istasyonlara göre matris döndür
```

### 9.5 DDL Dosyası

`/Volumes/prod/documents/report/PRJ_TASK_WS_SET_DDL.sql`

### 9.6 Frontend Güncellemeleri

**Yeni Fonksiyonlar:**
- `renderWorkstationSelect(workstations)` - İstasyon seçim UI'ı render
- `toggleWorkstation(checkbox)` - Checkbox toggle
- `selectAllWorkstations()` - Tümünü seç
- `saveWorkstationSelection()` - Seçimi kaydet ve matrisi yükle

**loadMatrixData Güncellemesi:**
- `result_type` kontrolü eklendi
- `SELECT_WS` → İstasyon seçim ekranı
- `MATRIX` → Matris ekranı

**AJAX Endpoint Güncellemeleri:**
- `action=ws_save` - İstasyon seçimini kaydet
- `action=ws_list` - İstasyon listesi getir
- `action=get` - result_type kontrolü eklendi

### 9.7 Yeni CSS Stilleri

- `.ws-select-container` - İstasyon seçim container
- `.ws-select-list` - 2 kolonlu grid liste
- `.ws-item` - Checkbox + label
- `.btn-ws-all` - Tümünü seç butonu
- `.btn-ws-save` - Matrisi oluştur butonu

---

## 10. Veritabanı İlişki Diagramı

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              ERP CORE TABLES (dbo)                               │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  ┌──────────────────┐         ┌──────────────────┐         ┌──────────────────┐ │
│  │  PRO_PROJECTS    │         │   PRO_WORKS      │         │  WORKSTATIONS    │ │
│  │  (Projeler)      │         │   (Görevler)     │         │  (İstasyonlar)   │ │
│  ├──────────────────┤         ├──────────────────┤         ├──────────────────┤ │
│  │ PROJECT_ID (PK)  │◄────────│ PROJECT_ID (FK)  │         │ STATION_ID (PK)  │ │
│  │ PROJECT_NAME     │         │ WORK_ID (PK)     │         │ STATION_NAME     │ │
│  │ ...              │         │ TO_COMPLETE (%)  │◄──┐     │ ACTIVE           │ │
│  └──────────────────┘         └──────────────────┘   │     └────────┬─────────┘ │
│                                       │              │              │           │
└───────────────────────────────────────┼──────────────┼──────────────┼───────────┘
                                        │              │              │
                                        │              │              │ (snapshot)
                                        ▼              │              ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                         MATRIX TABLES (workcube_prod)                            │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  ┌──────────────────┐                                                           │
│  │ PRJ_TASK_WS_SET  │◄─────────────────────────────────────────────────────┐    │
│  │ (Görev İstasyon  │                                                      │    │
│  │  Seti)           │                                                      │    │
│  ├──────────────────┤                                                      │    │
│  │ WS_SET_ID (PK)   │◄──────────────────────────────┐                      │    │
│  │ PROJECT_ID (FK)──┼──► PRO_PROJECTS.PROJECT_ID    │                      │    │
│  │ WORK_ID (FK)─────┼──► PRO_WORKS.WORK_ID          │                      │    │
│  └──────────────────┘                               │                      │    │
│          │                                          │                      │    │
│          │ 1:N                                      │                      │    │
│          ▼                                          │                      │    │
│  ┌──────────────────┐                               │                      │    │
│  │PRJ_TASK_WS_SET_ROW│                              │                      │    │
│  │ (Seçilen         │                               │                      │    │
│  │  İstasyonlar)    │                               │                      │    │
│  ├──────────────────┤                               │                      │    │
│  │ WS_SET_ROW_ID(PK)│                               │                      │    │
│  │ WS_SET_ID (FK)───┼──► PRJ_TASK_WS_SET            │                      │    │
│  │ WORKSTATION_ID   │──► WORKSTATIONS.STATION_ID    │                      │    │
│  │ WORKSTATION_CODE │    (snapshot)                 │                      │    │
│  │ WORKSTATION_NAME │    (snapshot)                 │                      │    │
│  └──────────────────┘                               │                      │    │
│                                                     │                      │    │
│  ┌──────────────────┐         ┌──────────────────┐  │                      │    │
│  │PRJ_TASK_MATRIX_  │         │PRJ_TASK_MATRIX_  │  │                      │    │
│  │TEMPLATE          │         │INSTANCE          │  │                      │    │
│  │ (Şablonlar)      │         │ (Görev Instance) │  │                      │    │
│  ├──────────────────┤         ├──────────────────┤  │                      │    │
│  │ TEMPLATE_ID (PK) │◄────────│ TEMPLATE_ID (FK) │  │                      │    │
│  │ TEMPLATE_CODE    │         │ INSTANCE_ID (PK) │  │                      │    │
│  │ TEMPLATE_NAME    │         │ PROJECT_ID (FK)──┼──┼──► PRO_PROJECTS      │    │
│  └────────┬─────────┘         │ WORK_ID (FK)─────┼──┼──► PRO_WORKS         │    │
│           │                   │ WS_SET_ID (FK)───┼──┘                      │    │
│           │ 1:N               │ CALC_PERCENT ────┼──────► TO_COMPLETE      │    │
│           ▼                   └────────┬─────────┘                         │    │
│  ┌──────────────────┐                  │                                   │    │
│  │PRJ_TASK_MATRIX_  │                  │ 1:N                               │    │
│  │DIM               │                  ▼                                   │    │
│  │ (Boyutlar)       │         ┌──────────────────┐                         │    │
│  ├──────────────────┤         │PRJ_TASK_MATRIX_  │                         │    │
│  │ DIM_ID (PK)      │         │CELL_VALUE        │                         │    │
│  │ TEMPLATE_ID (FK) │         │ (Hücre Değerleri)│                         │    │
│  │ DIM_TYPE (STAGE/ │         ├──────────────────┤                         │    │
│  │  SUB_STAGE)      │         │ CELL_VALUE_ID(PK)│                         │    │
│  │ DIM_CODE ────────┼─────────│ INSTANCE_ID (FK) │                         │    │
│  │ DIM_NAME         │   ▲     │ CELL_DEF_ID (FK) │                         │    │
│  └────────┬─────────┘   │     │ VALUE_ID (FK)────┼──┐                      │    │
│           │             │     └──────────────────┘  │                      │    │
│           │ 1:N         │                           │                      │    │
│           ▼             │                           ▼                      │    │
│  ┌──────────────────┐   │     ┌──────────────────┐                         │    │
│  │PRJ_TASK_MATRIX_  │   │     │PRJ_TASK_MATRIX_  │                         │    │
│  │CELL_DEF          │   │     │VALUE_DICT        │                         │    │
│  │ (Hücre Tanımları)│   │     │ (Değer Sözlüğü)  │                         │    │
│  ├──────────────────┤   │     ├──────────────────┤                         │    │
│  │ CELL_DEF_ID (PK) │   │     │ VALUE_ID (PK)    │                         │    │
│  │ TEMPLATE_ID (FK) │   │     │ TEMPLATE_ID (FK) │                         │    │
│  │ STAGE_DIM_ID(FK)─┼───┘     │ VALUE_CODE       │                         │    │
│  │ CELL_LABEL       │         │ (PLUS/STK/ZERO/  │                         │    │
│  │ WEIGHT           │         │  YOK/MINUS)      │                         │    │
│  └──────────────────┘         │ SCORE            │                         │    │
│                               └──────────────────┘                         │    │
│                                                                            │    │
│  ┌──────────────────┐                                                      │    │
│  │PRJ_TASK_MATRIX_  │                                                      │    │
│  │AUDIT             │                                                      │    │
│  │ (Audit Log)      │                                                      │    │
│  ├──────────────────┤                                                      │    │
│  │ AUDIT_ID (PK)    │                                                      │    │
│  │ INSTANCE_ID (FK)─┼──────────────────────────────────────────────────────┘    │
│  │ ACTION_TYPE      │                                                           │
│  │ NEW_PERCENT      │                                                           │
│  └──────────────────┘                                                           │
│                                                                                  │
└──────────────────────────────────────────────────────────────────────────────────┘
```

---

## 11. Kullanıcı Akış Diagramı

```
     ┌──────────────┐
     │ Modal Aç     │
     │ (PROJECT_ID, │
     │  WORK_ID)    │
     └──────┬───────┘
            │
            ▼
     ┌──────────────┐     Hayır    ┌──────────────────┐
     │ WS_SET var   │─────────────►│ İstasyon Seçim   │
     │ mı?          │              │ Ekranı           │
     └──────┬───────┘              │ (WORKSTATIONS    │
            │ Evet                 │  tablosundan)    │
            │                      └────────┬─────────┘
            │                               │
            │                               ▼
            │                      ┌──────────────────┐
            │                      │ Seçim Kaydet     │
            │                      │ (PRJ_TASK_WS_SET │
            │                      │  + _ROW)         │
            │                      └────────┬─────────┘
            │                               │
            │◄──────────────────────────────┘
            │
            ▼
     ┌──────────────┐
     │ Matris Ekranı│
     │ (Sadece      │
     │  seçilen     │
     │  istasyonlar)│
     └──────┬───────┘
            │
            ├─────────────────────────────────────────┐
            │                                         │
            ▼                                         ▼
     ┌──────────────┐                         ┌──────────────┐
     │ Buton Seç    │                         │ İstasyonlar  │
     │ (+/STK/0/    │                         │ Düzenle      │
     │  YOK/-)      │                         └──────┬───────┘
     └──────┬───────┘                                │
            │                                        │
            ▼                                        ▼
     ┌──────────────┐                         ┌──────────────┐
     │ Kaydet       │                         │ İstasyon     │
     └──────┬───────┘                         │ Seçim Ekranı │
            │                                 │ (mevcut      │
            ▼                                 │  seçimler    │
     ┌──────────────┐                         │  işaretli)   │
     │ % Hesapla    │                         └──────────────┘
     │ (Sadece PLUS)│
     └──────┬───────┘
            │
            ▼
     ┌──────────────┐
     │ PRO_WORKS.   │
     │ TO_COMPLETE  │
     │ güncelle     │
     └──────────────┘
```

---

## 12. Tablo İlişkileri Özet

| Kaynak Tablo | İlişki | Hedef Tablo |
|--------------|--------|-------------|
| `PRO_PROJECTS` | 1:N | `PRO_WORKS` |
| `PRO_PROJECTS` | 1:N | `PRJ_TASK_WS_SET` |
| `PRO_WORKS` | 1:1 | `PRJ_TASK_WS_SET` |
| `PRJ_TASK_WS_SET` | 1:N | `PRJ_TASK_WS_SET_ROW` |
| `WORKSTATIONS` | snapshot | `PRJ_TASK_WS_SET_ROW` |
| `PRJ_TASK_MATRIX_TEMPLATE` | 1:N | `PRJ_TASK_MATRIX_INSTANCE` |
| `PRJ_TASK_MATRIX_INSTANCE` | N:1 | `PRJ_TASK_WS_SET` |
| `PRJ_TASK_MATRIX_INSTANCE` | 1:N | `PRJ_TASK_MATRIX_CELL_VALUE` |
| `PRJ_TASK_MATRIX_INSTANCE.CALC_PERCENT` | → | `PRO_WORKS.TO_COMPLETE` |

---

## 13. ERP Entegrasyonu

### Workstation Tablosu
- **Tablo:** `dbo.WORKSTATIONS`
- **PK:** `STATION_ID`
- **Ad:** `STATION_NAME`
- **Aktif:** `ACTIVE` (1/0)

### Görev Tablosu
- **Tablo:** `dbo.PRO_WORKS`
- **PK:** `WORK_ID`
- **Proje FK:** `PROJECT_ID`
- **Tamamlanma %:** `TO_COMPLETE`

---

*Son güncelleme: 2026-01-21 19:55*

---

## 14. Aşama Otomasyonu (2026-01-21 17:30)

### 14.1 Kural
Matris tamamlanma yüzdesine göre görev aşaması otomatik güncellenir:

| Yüzde | Aşama | WORK_CURRENCY_ID |
|-------|-------|------------------|
| %0 | Boş (-) | NULL |
| %1-99 | Başlandı - Devam | 2361 |
| %100 | Tamamlandı | 2364 |

### 14.2 Güncellenen Dosyalar

**Backend:**
- `sp_prj_task_matrix_save` (PRJ_TASK_MATRIX_SAVE_V2.sql) - PRO_WORKS.WORK_CURRENCY_ID güncelleme
- `ajax_work_ratio.cfm` - Input değişince WORK_CURRENCY_ID güncelleme

**Frontend:**
- `5560605B-BA40-44A6-1E209FF687575FC2.cfm` - Matris kaydetme sonrası dropdown güncelleme

### 14.3 Akış

```
Matris Kaydet → sp_prj_task_matrix_save
    │
    ├── %100 → WORK_CURRENCY_ID = 2364 (Tamamlandı)
    ├── %1-99 → WORK_CURRENCY_ID = 2361 (Başlandı - Devam)
    └── %0 → WORK_CURRENCY_ID = NULL (Boş)
    │
    └── Frontend dropdown anında güncellenir
```

---

## 15. Proje Dosyaları (Güncel)

### 15.1 Aktif Dosyalar

| Dosya | Açıklama |
|-------|----------|
| `5560605B-BA40-44A6-1E209FF687575FC2.cfm` | Ana matris modal |
| `MATRIS_MODAL_ANALIZ.md` | Bu dokümantasyon |
| `PRJ_TASK_MATRIX_SAVE_V2.sql` | sp_prj_task_matrix_save SP |
| `PRJ_TASK_MATRIX_GET_V3.sql` | sp_prj_task_matrix_get SP |
| `PRJ_TASK_WS_SET_SAVE_V2.sql` | sp_prj_task_ws_set_save SP |
| `PRJ_TASK_MATRIX_DDL.sql` | Tablo DDL (referans) |
| `PRJ_TASK_WS_SET_DDL.sql` | WS_SET tablo DDL (referans) |
| `PRJ_TASK_MATRIX_SEED_DATA.sql` | Seed data (referans) |

### 15.2 ERP Core Dosyaları (Değiştirildi)

| Dosya | Değişiklik |
|-------|------------|
| `/V16/project/form/ajax_task_matrix.cfm` | Matris AJAX endpoint |
| `/V16/project/display/ajax_work_ratio.cfm` | Input değişince WORK_CURRENCY_ID güncelleme |
| `/V16/project/form/dsp_upd_work.cfm` | complate_control() dropdown güncelleme |

### 15.3 Silinen Dosyalar (2026-01-21)

- 7 adet backup dosyası (.backup_*)
- 6 adet eski SP versiyonu (*_FIX.sql, *_COMPAT.sql, *_V2.sql)
- 3 adet debug/duplicate dosyası
- 1 adet boşluklu md dosyası

**Toplam: 18 dosya silindi**

---

## 16. Test Kontrol Listesi (Güncel)

- [x] Modal açılıyor
- [x] İstasyon seçimi çalışıyor
- [x] Matris butonları çalışıyor (toggle)
- [x] Sıfırla butonu çalışıyor
- [x] Kaydet çalışıyor
- [x] Seçimler veritabanına kaydediliyor
- [x] Modal tekrar açıldığında seçimler yükleniyor
- [x] Sadece + işareti yüzdeyi etkiliyor
- [x] Input alanı matris yüzdesiyle güncelleniyor
- [x] %100 → Tamamlandı aşaması
- [x] %1-99 → Başlandı - Devam aşaması
- [x] %0 → Boş aşama
- [x] Dropdown anında güncelleniyor (matris kaydetme sonrası)
