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

*Son güncelleme: 2026-01-22 16:55*

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
- [x] Butonlar bağımsız seçilebilir (checkbox gibi)
- [x] Matris değeri varsa input readonly
- [x] Matris butonu sadece "ÜRETİM SÜRECİ" görevlerinde görünüyor

---

## 17. Güncellemeler (2026-01-22)

### 17.1 İstasyon Seçimi Düzeltmesi

**Sorun:** Kullanıcı X istasyon seçiyor ama matriste tüm istasyonlar görünüyordu.

**Çözüm:**
1. `sp_prj_task_matrix_get` güncellendi - WS_SET yoksa `SELECT_WS` modu döndürüyor
2. `sp_prj_task_ws_list` güncellendi - `PRJ_TASK_MATRIX_DIM` tablosundan STAGE'leri getiriyor
3. `sp_prj_task_ws_set_save` güncellendi - Eski kayıtları siliyor, yeni kayıtları ekliyor

**Akış:**
```
Modal Aç → WS_SET var mı?
    │
    ├── Hayır → result_type = 'SELECT_WS' → İstasyon Seçim Ekranı
    │
    └── Evet → result_type = 'MATRIX' → Sadece seçili istasyonların hücreleri
```

### 17.2 Bağımsız Buton Seçimi

**Önceki davranış:** Bir hücrede sadece 1 buton aktif olabiliyordu (radio button)

**Yeni davranış:** Tüm butonlar bağımsız seçilebilir (checkbox gibi)
- Aynı hücrede birden fazla buton aktif olabilir (örn: + ve STK aynı anda)
- Değerler virgülle ayrılmış olarak saklanır (örn: "PLUS,STK")

**Değiştirilen fonksiyonlar:**
- `selectMatrixValue()` - Toggle mantığı, diğer butonları etkilemez
- `calcMatrixPercentValue()` - Sadece PLUS değerini kontrol eder
- `renderMatrix()` - Birden fazla aktif buton desteği

**Yüzde hesaplama:**
```javascript
// Sadece PLUS değeri yüzdeyi etkiler
if (valArray.indexOf('PLUS') !== -1) {
    plusCount += weight;
}
```

### 17.3 Input Kilitleme

**Özellik:** Matris değeri olan görevlerin % input'u otomatik kilitlenir.

**Görsel:**
- Gri arkaplan (`#f0f0f0`)
- `readonly` attribute
- Tooltip: "Bu değer matristen hesaplanmaktadır"

**Uygulama noktaları:**
1. `loadMatrixData()` - Matris yüklendiğinde (instance varsa)
2. `saveMatrix()` - Matris kaydedildiğinde

### 17.4 Koşullu Matris Butonu

**Kural:** Matris butonu sadece görev adı **"ÜRETİM SÜRECİ"** olan satırlarda görünür.

**Kod:**
```cfm
<cfif trim(WORK_HEAD) eq "ÜRETİM SÜRECİ">
    <button onclick="openMatrixModal(...)">...</button>
<cfelse>
    &nbsp;
</cfif>
```

---

## 18. Yedekleme (2026-01-22)

**Konum:** `/Volumes/prod/documents/report/MATRIS_BACKUP_20260122/`

### Yedeklenen Dosyalar

| Dosya | Açıklama |
|-------|----------|
| `5560605B-BA40-44A6-1E209FF687575FC2.cfm` | Ana rapor sayfası |
| `ajax_task_matrix.cfm` | AJAX endpoint |
| `PRJ_TASK_MATRIX_GET_V3.sql` | sp_prj_task_matrix_get SP |
| `PRJ_TASK_WS_SET_SAVE_V2.sql` | sp_prj_task_ws_set_save SP |
| `MATRIS_MODAL_ANALIZ.md` | Dokümantasyon |
| `DB_BACKUP_SCRIPT.sql` | Veritabanı yapısı + notlar |

---

## 19. Mevcut Özellikler Özeti

| Özellik | Durum | Açıklama |
|---------|-------|----------|
| İstasyon Seçimi | ✅ | Görev bazında dinamik istasyon seçimi |
| Matris Görüntüleme | ✅ | Sadece seçili istasyonların hücreleri |
| Bağımsız Butonlar | ✅ | +, STK, 0, YOK, - birbirinden bağımsız |
| Yüzde Hesaplama | ✅ | Sadece + (PLUS) yüzdeyi etkiler |
| Input Kilitleme | ✅ | Matris değeri varsa readonly |
| Aşama Otomasyonu | ✅ | %0/1-99/100 → Boş/Devam/Tamamlandı |
| Koşullu Görünüm | ✅ | Sadece "ÜRETİM SÜRECİ" görevlerinde matris |
| İstasyon Düzenleme | ✅ | "İstasyonlar" butonu ile düzenleme |

---

## 20. Teknik Detaylar

### 20.1 Veritabanı Tabloları

```
workcube_prod.PRJ_TASK_MATRIX_TEMPLATE     - Matris şablonları
workcube_prod.PRJ_TASK_MATRIX_DIM          - Boyutlar (STAGE/SUB_STAGE)
workcube_prod.PRJ_TASK_MATRIX_CELL_DEF     - Hücre tanımları
workcube_prod.PRJ_TASK_MATRIX_VALUE        - Değer sözlüğü (+, STK, 0, YOK, -)
workcube_prod.PRJ_TASK_WS_SET              - İstasyon setleri
workcube_prod.PRJ_TASK_WS_SET_ROW          - Seçili istasyonlar
workcube_prod.PRJ_TASK_MATRIX_INSTANCE     - Matris instance'ları
workcube_prod.PRJ_TASK_MATRIX_CELL_VALUE   - Hücre değerleri
```

### 20.2 Stored Procedures

| SP | Açıklama |
|----|----------|
| `sp_prj_task_matrix_get` | Matris verilerini getir (SELECT_WS veya MATRIX modu) |
| `sp_prj_task_matrix_save` | Matris değerlerini kaydet, yüzde hesapla |
| `sp_prj_task_ws_set_save` | İstasyon seçimini kaydet |
| `sp_prj_task_ws_list` | İstasyon listesi getir |

### 20.3 AJAX Endpoint Actions

| Action | Açıklama |
|--------|----------|
| `get` | Matris verilerini getir |
| `save` | Matris değerlerini kaydet |
| `ws_list` | İstasyon listesi getir |
| `ws_save` | İstasyon seçimini kaydet |

### 20.4 Frontend Fonksiyonları

| Fonksiyon | Açıklama |
|-----------|----------|
| `openMatrixModal(projectId, workId)` | Modal aç |
| `loadMatrixData(projectId, workId)` | Matris verilerini yükle |
| `renderWorkstationSelect(workstations, isEditMode)` | İstasyon seçim UI |
| `renderMatrix(data)` | Matris UI |
| `selectMatrixValue(cellDefId, valueCode, btn)` | Buton seçimi (bağımsız) |
| `calcMatrixPercent()` | Yüzde hesapla (sadece PLUS) |
| `saveMatrix()` | Kaydet |
| `resetMatrix()` | Sıfırla |
| `editWorkstations()` | İstasyonları düzenle |

---

## 21. Sipariş Operasyon Görevleri Modülü (2026-01-22)

### 21.1 Mimari Karar

**Seçenek B** tercih edildi: **Genelleştirilmiş Görev Motoru**

- ✅ Yeni tablolar: `OPS_TASK` + yan tablolar (11 tablo)
- ✅ Mevcut `PRO_WORKS` ve `PRJ_*` tablolarına **dokunulmaz**
- ✅ `REF_TYPE/REF_ID` ile hem proje hem sipariş desteklenir
- ✅ Mevcut matris şablon tabloları ortak kullanılır

### 21.2 Yeni Tablolar

| Tablo | Açıklama |
|-------|----------|
| `OPS_TASK` | Ana görev tablosu (REF_TYPE, REF_ID ile) |
| `OPS_TASK_STEP` | İş adımları |
| `OPS_TASK_NOTE` | Takip notları |
| `OPS_TASK_TIME` | Zaman harcaması |
| `OPS_TASK_DOC` | Belgeler |
| `OPS_TASK_CC` | Bilgi verilecekler |
| `OPS_TASK_WS_SET` | İstasyon setleri |
| `OPS_TASK_WS_SET_ROW` | Seçili istasyonlar |
| `OPS_TASK_MATRIX_INSTANCE` | Matris instance |
| `OPS_TASK_MATRIX_CELL_VALUE` | Matris hücre değerleri |
| `OPS_TASK_AUDIT` | Audit log |

### 21.3 Stored Procedures

| SP | Açıklama |
|----|----------|
| `sp_ops_task_list` | Görev listesi |
| `sp_ops_task_get` | Görev detayı |
| `sp_ops_task_save` | Görev kaydet |
| `sp_ops_task_delete` | Görev sil |
| `sp_ops_task_step_save` | İş adımları kaydet |
| `sp_ops_task_note_save` | Not kaydet |
| `sp_ops_task_time_save` | Zaman kaydet |
| `sp_ops_task_matrix_get` | Matris getir |
| `sp_ops_task_matrix_save` | Matris kaydet |
| `sp_ops_task_ws_list` | İstasyon listesi |
| `sp_ops_task_ws_save` | İstasyon seçimi kaydet |

### 21.4 Dosyalar

| Dosya | Açıklama |
|-------|----------|
| `SIPARIS_OPERASYON_GOREVLERI_ANALIZ.md` | Kapsamlı analiz dokümanı |
| `OPS_TASK_DDL.sql` | Tablo DDL'leri |
| `OPS_TASK_SP.sql` | Stored Procedure'ler |

### 21.5 Fazlandırma

| Faz | Süre | Kapsam |
|-----|------|--------|
| **Faz-1 MVP** | 2 hafta | Temel görev yönetimi + matris |
| **Faz-2 Widget** | 2 hafta | Zaman/belge/ajanda entegrasyonu |
| **Faz-3 AI** | 3 hafta | Otomatik görev üretimi |

### 21.6 Detaylı Dokümantasyon

Tam analiz için: `SIPARIS_OPERASYON_GOREVLERI_ANALIZ.md`

---

*Dokümantasyon sonu - 2026-01-22 17:30*
