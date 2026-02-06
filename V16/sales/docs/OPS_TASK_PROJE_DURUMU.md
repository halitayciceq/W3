# OPS_TASK - Sipariş Operasyon Görevleri Modülü

## Projenin Amacı
Sipariş detay sayfasında (detail_order.cfm) **görev yönetimi** özelliği eklemek.

## Mevcut Durum (2026-02-05 11:25)

### ✅ Tamamlanan
1. **OPS_TASK tablosu** - Veritabanında oluşturuldu ve çalışıyor
2. **detail_order.cfm** - Modal yapısı ve menü entegrasyonu çalışıyor
3. **ops_task_list.cfm** - Görev listesi çalışıyor (mavi header tasarım)
4. **dsp_ops_task.cfm** - Modern form tasarımı tamamlandı:
   - Koyu header (#3a3f47) + turkuaz accent (#00a8a8)
   - İkonlu labellar (SVG)
   - 2 sütunlu grid düzeni
   - Alanlar: Konu, Açıklama, Sorumlu, Öncelik, **Aşama**, Termin, Öngörülen Süre, Tamamlanma %, Matris
   - Autocomplete çalışan arama (3+ karakter)
   - Turkuaz KAYDET butonu
5. **ajax_ops_task.cfm** - AJAX endpoint hazır:
   - `list` - Görev listesi
   - `get` - Tek görev detayı
   - `save` - Kaydetme (INSERT/UPDATE)
   - `delete` - Silme
   - `employee_search` - Çalışan arama
6. **Session fallback'leri** - `session.ep.employee_id`, `branch_id`, `company_id` için fallback değerler eklendi
7. **Aşama alanı (status_id)** - Form'a eklendi (2026-02-05)

### ⏳ Eksik/Test Edilecek
1. **Kaydetme testi** - Form submit çalışıyor mu son kontrol

### 📝 Notlar
- `sp_ops_task_get` stored procedure PROCESS_STAGE tablosuna erişmeye çalışıyor (hata veriyor)
- Düzenleme modunda stored procedure yerine düz SQL sorgusu kullanıldı

## Dosya Yapısı
```
/V16/sales/
├── form/
│   ├── detail_order.cfm          # Ana sipariş sayfası (modal entegrasyonu)
│   └── dsp_ops_task.cfm          # Görev ekleme/düzenleme formu (Modern UI)
├── display/
│   └── ops_task_list.cfm         # Görev listesi + JavaScript (OpsTask objesi)
└── query/
    └── ajax_ops_task.cfm         # AJAX endpoint (list, get, save, delete, employee_search)
```

## Form Alanları (dsp_ops_task.cfm)
- **Konu** (task_head) - Zorunlu
- **Açıklama** (task_detail)
- **Sorumlu** (assigned_emp_id) - Autocomplete, 3+ karakter
- **Öncelik** (priority_id) - Düşük/Normal/Yüksek/Acil
- **Termin** (deadline) - Tarih
- **Öngörülen Süre** (estimated_hour, estimated_minute) - SA/DK
- **Tamamlanma %** (percent_complete) - Progress bar
- **Matris Kullan** (has_matrix) - Checkbox
- **Matris Şablonu** (matrix_template_id) - Conditional

## Aşama Değerleri (status_id)
| ID | Aşama |
|----|-------|
| 0 | - |
| 1 | Planlama |
| 2 | İş Atandı |
| 3 | Başlandı - Devam |
| 4 | Onay Bekleniyor |
| 5 | Tamamlandı |
| 6 | Onaylandı |
| 7 | İptal Edildi |

## W3 Standart Kuralları
- `datasource="#dsn#"` kullan
- Şema adı KULLANMA: `FROM OPS_TASK` (workcube_prod.OPS_TASK DEĞİL)
- `session.ep.company_id`, `session.ep.employee_id`, `session.ep.branch_id`

## Son Güncelleme
**Tarih:** 2026-02-04 17:25
**Durum:** Form tasarımı tamamlandı, kaydetme testi yapılacak
