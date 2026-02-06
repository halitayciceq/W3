# Sipariş Operasyon Görevleri - UI Tasarım Dokümanı

**Tarih:** 2026-01-22  
**Versiyon:** 1.0  
**Referans:** Proje Görev Yönetimi UI (PRO_WORKS)

---

## A) UI Yerleşim Kararı

### Sekme Konumu
- **Sipariş detay ekranında** mevcut sekmelere ek olarak yeni sekme eklenir
- **Sekme adı:** `Görevler (Operasyonlar)`
- **Sekme sırası:** Kalemler sekmesinden sonra

### Sekme İçeriği
```
┌─────────────────────────────────────────────────────────────────┐
│ [Toolbar]                                                       │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │ 🔍 Filtre ▼ │ Sorumlu ▼ │ Aşama ▼ │        │ 🔄 │ ➕ Yeni │ │
│ └─────────────────────────────────────────────────────────────┘ │
│                                                                 │
│ [Grid]                                                          │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │ # │Sorumlu│ Başlık │Aşama│Termin│Öngörülen│Harcanan│ % │🔧│ │
│ ├───┼───────┼────────┼─────┼──────┼─────────┼────────┼───┼──┤ │
│ │ 1 │ Ali   │ Kesim  │ Dev │01.02 │  4:00   │  2:30  │50 │📎│ │
│ │ 2 │ Veli  │ Üretim │ Bek │05.02 │  8:00   │  0:00  │ 0 │📎🔢│
│ └─────────────────────────────────────────────────────────────┘ │
│                                                                 │
│ [Pagination]                                                    │
│ ◀ 1 2 3 ▶                                                       │
└─────────────────────────────────────────────────────────────────┘
```

### Toolbar Bileşenleri
| Bileşen | Konum | İşlev |
|---------|-------|-------|
| Filtre dropdown | Sol | Tümü / Açık / Tamamlanan |
| Sorumlu dropdown | Sol | Personel filtresi |
| Aşama dropdown | Sol | Durum filtresi |
| Yenile butonu | Sağ | Grid'i yenile |
| **+ Yeni butonu** | Sağ (en son) | Görev oluşturma modalı aç |

---

## B) Görevler Grid Tasarımı

### Kolon Listesi (Proje ile Birebir)

| # | Kolon | Alan | Genişlik | Hizalama |
|---|-------|------|----------|----------|
| 1 | Sıra | - | 40px | Orta |
| 2 | Sorumlu | ASSIGNED_NAME | 120px | Sol |
| 3 | Başlık | TASK_HEAD | Esnek | Sol |
| 4 | Aşama | STATUS_NAME | 100px | Orta |
| 5 | Termin | DEADLINE | 90px | Orta |
| 6 | Öngörülen | ESTIMATED_MINUTES | 80px | Sağ |
| 7 | Harcanan | ACTUAL_MINUTES | 80px | Sağ |
| 8 | % | PERCENT_COMPLETE | 60px | Orta |
| 9 | İşlemler | - | 100px | Orta |

### Satır İkonları ve İşlevleri

| İkon | Koşul | İşlev |
|------|-------|-------|
| 📎 Belge | Her zaman | Belge ekle/listele modalı |
| 📅 Ajanda | Her zaman | Takvim etkinliği oluştur |
| ⏱️ Zaman | Her zaman | Zaman kaydı ekle |
| 🔢 Matris | `HAS_MATRIX=1 AND MATRIX_TEMPLATE_ID IS NOT NULL` | Matris modalı aç |
| ✏️ Düzenle | Her zaman | Görev düzenleme modalı |
| 🗑️ Sil | Her zaman | Silme onayı |

### Matris İkonu Görünme Koşulu (Kod)
```javascript
// DOĞRU: Data-driven
if (row.HAS_MATRIX == 1 && row.MATRIX_TEMPLATE_ID != null) {
    showMatrixIcon(row.TASK_ID);
}

// YANLIŞ: String kontrolü YAPILMAYACAK
// if (row.TASK_HEAD.indexOf('ÜRETİM') >= 0) { ... }
```

### Satır Tıklama Davranışı
- Satıra çift tıklama → Görev detay/düzenleme modalı açılır
- İkona tek tıklama → İlgili modal/işlem tetiklenir

---

## C) "Yeni Görev" Modal Tasarımı

### Açılış Tetikleyicisi
- Toolbar'daki **+ Yeni** butonu
- `openOpsTaskModal(0, 'ORDER', ORDER_ID)` fonksiyonu çağrılır

### Modal Yapısı
```
┌─────────────────────────────────────────────────────────────┐
│ Yeni Görev                                              [X] │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Konu *                                                     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                                                     │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Açıklama                                                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                                                     │   │
│  │                                                     │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Sorumlu *              │  Öncelik                          │
│  ┌──────────────────┐   │  ┌──────────────────┐            │
│  │ Seçiniz...    ▼  │   │  │ Normal        ▼  │            │
│  └──────────────────┘   │  └──────────────────┘            │
│                                                             │
│  Planlanan Başlangıç    │  Planlanan Bitiş                  │
│  ┌──────────────────┐   │  ┌──────────────────┐            │
│  │ 📅              │   │  │ 📅              │            │
│  └──────────────────┘   │  └──────────────────┘            │
│                                                             │
│  Termin *               │  Öngörülen Süre                   │
│  ┌──────────────────┐   │  ┌────┐ saat ┌────┐ dk           │
│  │ 📅              │   │  │    │      │    │              │
│  └──────────────────┘   │  └────┘      └────┘              │
│                                                             │
│  Tamamlanma %           │  Matris                           │
│  ┌──────────────────┐   │  ☑ Matris kullan                 │
│  │ 0            [R] │   │  Şablon: [Üretim Matrisi ▼]      │
│  └──────────────────┘   │                                   │
│  [R] = Matris varsa readonly                                │
│                                                             │
├─────────────────────────────────────────────────────────────┤
│                              │ İptal │     │ Kaydet │       │
└─────────────────────────────────────────────────────────────┘
```

### Zorunlu Alanlar (MVP)
| Alan | Zorunlu | Varsayılan |
|------|---------|------------|
| Konu (TASK_HEAD) | ✅ | - |
| Sorumlu (ASSIGNED_EMP_ID) | ✅ | - |
| Termin (DEADLINE) | ✅ | - |
| Açıklama | ❌ | - |
| Öncelik | ❌ | Normal |
| Planlanan Başlangıç | ❌ | - |
| Planlanan Bitiş | ❌ | - |
| Öngörülen Süre | ❌ | 0 |
| Tamamlanma % | ❌ | 0 |
| Matris kullan | ❌ | false |

### Kaydet / İptal Akışı
```
[Kaydet] tıklandığında:
1. Client-side validation
2. AJAX POST → ajax_ops_task.cfm?action=save
3. Başarılı → Modal kapat + Grid yenile + Toast mesaj
4. Hata → Modal'da hata göster

[İptal] tıklandığında:
1. Değişiklik varsa → "Değişiklikleri kaydetmeden çıkmak istiyor musunuz?" onayı
2. Modal kapat
```

### Sipariş Bağlamının Taşınması
```javascript
// Modal açılırken
function openOpsTaskModal(taskId, refType, refId) {
    $('#modal_ops_task').data('task_id', taskId);
    $('#modal_ops_task').data('ref_type', refType);   // 'ORDER'
    $('#modal_ops_task').data('ref_id', refId);       // ORDER_ID
    $('#modal_ops_task').modal('show');
}

// Form submit sırasında
var formData = {
    task_id: $('#modal_ops_task').data('task_id'),
    ref_type: $('#modal_ops_task').data('ref_type'),
    ref_id: $('#modal_ops_task').data('ref_id'),
    // ... diğer alanlar
};
```

---

## D) UI Akış Diyagramı

```
┌─────────────────┐
│ Sipariş Ekranı  │
└────────┬────────┘
         │
         ▼
┌─────────────────────────────────┐
│ Görevler (Operasyonlar) Sekmesi │
└────────┬────────────────────────┘
         │
    ┌────┴────┬─────────────┬──────────────┐
    ▼         ▼             ▼              ▼
┌───────┐ ┌───────┐   ┌──────────┐   ┌──────────┐
│+ Yeni │ │ Satır │   │ 📎 Belge │   │ 🔢 Matris│
└───┬───┘ └───┬───┘   └────┬─────┘   └────┬─────┘
    │         │            │              │
    ▼         ▼            ▼              ▼
┌───────────────┐   ┌───────────────┐ ┌───────────────┐
│ Görev Modalı  │   │ Belge Modalı  │ │ Matris Modalı │
│ (Yeni/Düzenle)│   │ (Generic)     │ │ (Stage Seçim +│
└───────────────┘   │ACTION_SECTION │ │ Hücre Grid)   │
                    │='OPS_TASK'    │ └───────────────┘
                    └───────────────┘
```

### Matris İkonuna Basınca Akış
```
[Matris İkonu Tıkla]
         │
         ▼
┌────────────────────┐
│ AJAX: matrix_get   │
│ task_id=X          │
└────────┬───────────┘
         │
    ┌────┴────────────────┐
    │                     │
    ▼                     ▼
result_type=          result_type=
'SELECT_STAGE'        'MATRIX'
    │                     │
    ▼                     ▼
┌──────────────┐    ┌──────────────┐
│ Stage Seçim  │    │ Matris Grid  │
│ Checkbox'ları│    │ (Hücreler +  │
│              │    │  Butonlar)   │
└──────┬───────┘    └──────────────┘
       │
       ▼
   [Kaydet]
       │
       ▼
   AJAX: stage_save
       │
       ▼
   Matris Grid göster
```

---

## E) Teknik Entegrasyon

### CFM Dosyaları

| Dosya | Konum | İşlev |
|-------|-------|-------|
| `ops_task_list.cfm` | /V16/order/display/ | Grid + Toolbar |
| `dsp_ops_task.cfm` | /V16/order/form/ | Görev modal formu |
| `ops_task_matrix.cfm` | /V16/order/form/ | Matris modal |
| `ops_task.js` | /V16/order/js/ | Client-side logic |

### AJAX Endpoint Çağrıları

```javascript
// Görev listesi
$.post('/ajax/ajax_ops_task.cfm', {
    action: 'list',
    ref_type: 'ORDER',
    ref_id: ORDER_ID,
    company_id: COMPANY_ID
});

// Görev kaydet
$.post('/ajax/ajax_ops_task.cfm', {
    action: 'save',
    task_id: taskId || '',
    ref_type: 'ORDER',
    ref_id: ORDER_ID,
    task_head: $('#task_head').val(),
    // ...
});

// Matris getir
$.post('/ajax/ajax_ops_task.cfm', {
    action: 'matrix_get',
    task_id: taskId
});

// Matris kaydet
$.post('/ajax/ajax_ops_task.cfm', {
    action: 'matrix_save',
    task_id: taskId,
    cells_json: JSON.stringify(cellsArray)
});
```

### Parametre Akışı (UI → Backend)

```
┌─────────────────────────────────────────────────────────────────┐
│ Sipariş Ekranı                                                  │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │ CFM: order_detail.cfm                                       │ │
│ │ Değişkenler: ORDER_ID, COMPANY_ID, BRANCH_ID                │ │
│ └───────────────────────────┬─────────────────────────────────┘ │
│                             │                                   │
│                             ▼                                   │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │ Include: ops_task_list.cfm                                  │ │
│ │ Parametreler: ref_type='ORDER', ref_id=#ORDER_ID#           │ │
│ └───────────────────────────┬─────────────────────────────────┘ │
│                             │                                   │
│                             ▼                                   │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │ JavaScript: window.OPS_TASK_CONFIG                          │ │
│ │ { ref_type: 'ORDER', ref_id: 123, company_id: 1 }           │ │
│ └───────────────────────────┬─────────────────────────────────┘ │
│                             │                                   │
│                             ▼                                   │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │ AJAX Request                                                │ │
│ │ POST /ajax/ajax_ops_task.cfm                                │ │
│ │ Body: action=list&ref_type=ORDER&ref_id=123&company_id=1    │ │
│ └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

---

## F) Dosya Yapısı

```
/V16/order/
├── display/
│   ├── order_detail.cfm          (mevcut - sekme eklenir)
│   └── ops_task_list.cfm         (YENİ - grid + toolbar)
├── form/
│   ├── dsp_ops_task.cfm          (YENİ - görev modal)
│   └── ops_task_matrix.cfm       (YENİ - matris modal)
├── js/
│   └── ops_task.js               (YENİ - client-side)
└── query/
    └── (SP çağrıları ajax üzerinden)

/ajax/
└── ajax_ops_task.cfm             (MEVCUT - endpoint)
```

---

## G) Faz-1 MVP UI Scope

### ✅ Yapılacaklar
1. Sipariş ekranına "Görevler (Operasyonlar)" sekmesi
2. Görev listesi grid (8 kolon + işlem ikonları)
3. + Yeni butonu ile görev oluşturma modalı
4. Görev düzenleme modalı
5. Görev silme (onaylı)
6. Matris ikonu (koşullu görünüm)
7. Matris modalı (stage seçim + hücre grid)
8. Belge ikonu (mevcut generic altyapıya yönlendirme)
9. Filtre: Tümü / Açık / Tamamlanan
10. % readonly kuralı (matris varsa)

### ❌ Bilinçli Olarak Yapılmayacaklar (Kapsam Dışı)
1. Ajanda/Takvim entegrasyonu → Faz-2
2. Zaman kaydı entegrasyonu → Faz-2
3. Alt görev (hiyerarşi) → Faz-2
4. Gantt görünümü → Faz-3
5. Toplu görev atama → Faz-3
6. Mobil responsive → Faz-3
7. Görev şablonları → Faz-3
8. Bildirim/mail → Faz-2

---

## H) Sipariş Ekranına Sekme Ekleme (Entegrasyon Kodu)

```html
<!-- order_detail.cfm içine eklenecek sekme başlığı -->
<li class="nav-item">
    <a class="nav-link" id="tab-ops-tasks" data-toggle="tab" href="#pane-ops-tasks">
        <i class="fa fa-tasks"></i> Görevler (Operasyonlar)
    </a>
</li>

<!-- Sekme içeriği -->
<div class="tab-pane fade" id="pane-ops-tasks">
    <cfinclude template="/V16/order/display/ops_task_list.cfm">
</div>

<!-- JavaScript config -->
<script>
window.OPS_TASK_CONFIG = {
    ref_type: 'ORDER',
    ref_id: <cfoutput>#ORDER_ID#</cfoutput>,
    company_id: <cfoutput>#session.company_id#</cfoutput>,
    branch_id: <cfoutput>#session.branch_id#</cfoutput>,
    ajax_url: '/ajax/ajax_ops_task.cfm'
};
</script>
<script src="/V16/order/js/ops_task.js"></script>
```

---

**Sonraki Adım:** CFM dosyalarını oluştur (ops_task_list.cfm, dsp_ops_task.cfm, ops_task.js)
