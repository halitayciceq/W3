# Proje ve Sipariş Task Sistemi Analiz Dokümanı

**Tarih:** 2026-02-05  
**Yedek Dosya:** `5560605B-BA40-44A6-1E209FF687575FC2.cfm.bak_20260205`

---

## 1. Referans Dosya Analizi

### Dosya: `5560605B-BA40-44A6-1E209FF687575FC2.cfm`
**Konum:** `/Volumes/prod/documents/report/`  
**Amaç:** Proje ve Operasyon İzleme Raporu - Projeler üzerinden task/görev yönetimi

---

## 2. Mimari Yapı

### 2.1 Veri Kaynakları

| Kaynak | DSN | Tablolar |
|--------|-----|----------|
| Projeler | `#DSN#` | `PRO_PROJECTS`, `PRO_WORKS`, `PRO_WORKS_HISTORY` |
| Personel | `#DSN#` | `EMPLOYEES` |
| Siparişler | `#DSN3#` | `ORDERS`, `COMPANY`, `CONSUMERS` |
| Matris | `#DSN#` | `PRJ_TASK_MATRIX_*` tabloları |

### 2.2 Ana Sorgular

```sql
-- Proje Listesi
SELECT P.PROJECT_ID, P.PROJECT_NUMBER, P.PROJECT_HEAD, ...
FROM PRO_PROJECTS P
LEFT JOIN EMPLOYEES EMP ON P.PROJECT_EMP_ID = EMP.EMPLOYEE_ID
...

-- Görevler (Tasks)
SELECT PW.PROJECT_ID, PW.WORK_ID, PW.WORK_HEAD, PW.TO_COMPLETE, ...
FROM PRO_WORKS PW
LEFT JOIN EMPLOYEES E ON PW.PROJECT_EMP_ID = E.EMPLOYEE_ID
WHERE PW.WORK_STATUS = 1

-- Siparişler (Proje bazlı)
SELECT O.ORDER_ID, O.ORDER_NUMBER, O.PROJECT_ID, ...
FROM ORDERS O
WHERE O.PROJECT_ID = ?
```

---

## 3. JavaScript Fonksiyonları

### 3.1 Task Yönetimi

| Fonksiyon | Açıklama | AJAX Endpoint |
|-----------|----------|---------------|
| `updateTaskPercent(workId, percent)` | Görev % güncelle | `V16/project/form/emptypopup_ajax_update_work_progress.cfm` |
| `updateTaskStage(workId, stageId)` | Görev aşama güncelle | `V16/project/form/emptypopup_ajax_update_work_progress.cfm` |
| `openTaskDocumentModal(workId)` | Belge yükle modal | `index.cfm?fuseaction=asset.list_asset` |

### 3.2 Matris Yönetimi

| Fonksiyon | Açıklama | AJAX Endpoint |
|-----------|----------|---------------|
| `openMatrixModal(projectId, workId)` | Matris modal aç | - |
| `loadMatrixData(projectId, workId)` | Matris verilerini yükle | `V16/project/form/ajax_task_matrix.cfm?action=get` |
| `renderMatrix(resp)` | Matris HTML render | - |
| `renderWorkstationSelect(workstations)` | İstasyon seçimi render | - |
| `selectMatrixValue(cellDefId, valueCode, btn)` | Matris hücre değer seç | - |
| `resetMatrix()` | Matris sıfırla | - |
| `calcMatrixPercent()` | Matris % hesapla | - |
| `saveMatrix()` | Matris kaydet | `V16/project/form/ajax_task_matrix.cfm?action=save` |
| `editWorkstations()` | İstasyon düzenle | `V16/project/form/ajax_task_matrix.cfm?action=ws_list` |
| `saveWorkstationSelection()` | İstasyon kaydet | `V16/project/form/ajax_task_matrix.cfm?action=ws_save` |

### 3.3 Matris Değer Kodları

| Kod | Label | Skor | Açıklama |
|-----|-------|------|----------|
| `PLUS` | + | 1.00 | Tamamlandı (% etkiler) |
| `STK` | STK | 0.00 | Hazır Stok |
| `ZERO` | 0 | 0.00 | Bekliyor |
| `YOK` | YOK | 0.00 | Üretim Yok |
| `MINUS` | - | 0.00 | İptal |

**Not:** Sadece `PLUS` değeri yüzdeyi etkiler!

---

## 4. Proje vs Sipariş Karşılaştırması

### 4.1 Mevcut Durum (Projeler)

```
PRO_PROJECTS (Proje)
    └── PRO_WORKS (Görev/Task)
            ├── PROJECT_ID (FK)
            ├── WORK_ID (PK)
            ├── WORK_HEAD (Başlık)
            ├── TO_COMPLETE (%)
            └── PRJ_TASK_MATRIX_* (Matris)
```

### 4.2 Hedef Durum (Siparişler)

```
ORDERS (Sipariş)
    └── OPS_TASK (Görev/Task)
            ├── REF_TYPE = 'ORDER'
            ├── REF_ID = ORDER_ID (FK)
            ├── TASK_ID (PK)
            ├── TASK_HEAD (Başlık)
            ├── PERCENT_COMPLETE (%)
            └── PRJ_TASK_MATRIX_* (Matris - aynı yapı)
```

---

## 5. Değişiklik Gereksinimleri

### 5.1 Tablo Eşleştirmesi

| Proje Sistemi | Sipariş Sistemi | Açıklama |
|---------------|-----------------|----------|
| `PRO_PROJECTS.PROJECT_ID` | `ORDERS.ORDER_ID` | Ana kayıt ID |
| `PRO_WORKS.WORK_ID` | `OPS_TASK.TASK_ID` | Görev ID |
| `PRO_WORKS.WORK_HEAD` | `OPS_TASK.TASK_HEAD` | Görev başlığı |
| `PRO_WORKS.TO_COMPLETE` | `OPS_TASK.PERCENT_COMPLETE` | Tamamlanma % |
| `PRO_WORKS.PROJECT_EMP_ID` | `OPS_TASK.ASSIGNED_EMP_ID` | Sorumlu |
| `PRO_WORKS.TARGET_FINISH` | `OPS_TASK.DEADLINE` | Termin |

### 5.2 AJAX Endpoint Değişiklikleri

| Eski Endpoint | Yeni Endpoint |
|---------------|---------------|
| `V16/project/form/emptypopup_ajax_update_work_progress.cfm` | `V16/sales/query/ajax_ops_task.cfm` |
| `V16/project/form/ajax_task_matrix.cfm` | (Aynı - ortak kullanılabilir) |

### 5.3 Parametre Değişiklikleri

| Eski Parametre | Yeni Parametre |
|----------------|----------------|
| `project_id` | `ref_id` (ORDER_ID) |
| `work_id` | `task_id` |
| `to_complete` | `percent_complete` |

---

## 6. Mevcut Sipariş Task Dosyaları

### 6.1 Ana Dosyalar

| Dosya | Konum | Açıklama |
|-------|-------|----------|
| `ops_task_list.cfm` | `/V16/sales/display/` | Görev listesi UI |
| `dsp_ops_task.cfm` | `/V16/sales/form/` | Görev formu modal |
| `dsp_ops_task_matrix.cfm` | `/V16/sales/form/` | Matris modal |
| `ajax_ops_task.cfm` | `/V16/sales/query/` | AJAX endpoint |
| `ajax_task_matrix.cfm` | `/V16/project/form/` | Matris AJAX (ortak) |

### 6.2 Yedek Dosyalar

| Yedek | Tarih |
|-------|-------|
| `dsp_ops_task_matrix.cfm.bak_20260205` | 2026-02-05 |
| `ops_task_list.cfm.bak_20260205` | 2026-02-05 |

---

## 7. Entegrasyon Planı

### Adım 1: Referans Dosyayı Kopyala
- `5560605B-BA40-44A6-1E209FF687575FC2.cfm` → Yeni sipariş raporu

### Adım 2: Sorguları Değiştir
- `PRO_PROJECTS` → `ORDERS`
- `PRO_WORKS` → `OPS_TASK`
- `PROJECT_ID` → `ORDER_ID` / `REF_ID`

### Adım 3: JavaScript Fonksiyonlarını Güncelle
- `updateTaskPercent` → `OpsTask.updatePercent`
- `updateTaskStage` → `OpsTask.updateStatus`
- AJAX endpoint'lerini güncelle

### Adım 4: Matris Entegrasyonu
- `ajax_task_matrix.cfm` ortak kullanılacak
- `project_id` yerine `ref_id` (ORDER_ID) gönderilecek
- `work_id` yerine `task_id` gönderilecek

---

## 8. Dikkat Edilecek Noktalar

1. **DSN Farkları:** Siparişler `#DSN3#`, Projeler `#DSN#`
2. **Kolon Farkları:** `TO_COMPLETE` vs `PERCENT_COMPLETE`
3. **ID Farkları:** `WORK_ID` vs `TASK_ID`
4. **Matris Tabloları:** Ortak kullanılabilir (PRJ_TASK_MATRIX_*)
5. **Session Değişkenleri:** `session.ep.*` kontrol et

---

## 9. Sonuç

Referans dosya Proje modülü üzerinden çalışıyor. Sipariş modülüne adapte etmek için:
- Sorguları OPS_TASK tablosuna yönlendir
- AJAX endpoint'lerini güncelle
- Parametre isimlerini eşleştir
- Matris sistemi ortak kullanılabilir

**Durum:** Analiz tamamlandı, entegrasyon hazır.

---

## 10. Yedek Dosyalar ve Kurtarma

### 10.1 Alınan Yedekler

| Dosya | Yedek Adı | Tarih |
|-------|-----------|-------|
| `5560605B-BA40-44A6-1E209FF687575FC2.cfm` | `.bak_20260205` | 2026-02-05 |
| `ajax_task_matrix.cfm` | `.bak_20260205` | 2026-02-05 |

### 10.2 Kurtarma Adımları

Eğer sorun çıkarsa:

```bash
# Referans rapor dosyasını geri yükle
cp /Volumes/prod/documents/report/5560605B-BA40-44A6-1E209FF687575FC2.cfm.bak_20260205 /Volumes/prod/documents/report/5560605B-BA40-44A6-1E209FF687575FC2.cfm

# Matris AJAX dosyasını geri yükle
cp /Volumes/prod/V16/project/form/ajax_task_matrix.cfm.bak_20260205 /Volumes/prod/V16/project/form/ajax_task_matrix.cfm
```

### 10.3 Değişiklik Özeti

**Hedef:** Sipariş satırına toggle ekle, tıklanınca OPS_TASK listesi göster

**Yüzde Hesaplama:**
- Sipariş % = OPS_TASK'ların PERCENT_COMPLETE ortalaması
- Proje % = Siparişlerin % ortalaması

**Veri Bağlantısı:**
- `OPS_TASK.REF_TYPE = 'ORDER'`
- `OPS_TASK.REF_ID = ORDER_ID`
