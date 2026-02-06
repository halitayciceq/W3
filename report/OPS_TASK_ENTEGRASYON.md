# Sipariş Operasyon Görevleri - Entegrasyon Rehberi

**Tarih:** 2026-01-22  
**Hedef:** Sipariş detay ekranı "Diğer" dropdown menüsüne "Görevler" ekleme

---

## 1. Entegrasyon Noktası

**Dosya:** `/V16/sales/form/detail_order_sa_noeditor.cfm` (veya ilgili form dosyası)  
**URL:** `fuseaction=sales.list_order&event=upd&order_id=XXX`  
**Konum:** "Diğer" dropdown menüsü

---

## 2. Dropdown'a Menü Öğesi Ekleme

"Diğer" dropdown içinde mevcut öğelerin yanına eklenecek:

```html
<!-- Görevler (Operasyonlar) - Diğer dropdown içine ekle -->
<a class="dropdown-item" href="javascript:void(0);" onclick="openOpsTasksModal()">
    <i class="fa fa-tasks"></i> Görevler (Operasyonlar)
</a>
```

---

## 3. Modal HTML (Sayfa sonuna ekle)

```html
<!-- Sipariş Operasyon Görevleri Modal -->
<div class="modal fade" id="modal_ops_tasks_main" tabindex="-1" role="dialog" data-backdrop="static">
    <div class="modal-dialog modal-xl" role="document">
        <div class="modal-content">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title">
                    <i class="fa fa-tasks"></i> Görevler (Operasyonlar)
                    <small class="ml-2" id="ops_tasks_order_info"></small>
                </h5>
                <button type="button" class="close text-white" data-dismiss="modal">
                    <span>&times;</span>
                </button>
            </div>
            <div class="modal-body p-0" id="modal_ops_tasks_body" style="min-height: 400px;">
                <div class="text-center py-5">
                    <i class="fa fa-spinner fa-spin fa-2x"></i>
                    <p class="mt-2">Yükleniyor...</p>
                </div>
            </div>
        </div>
    </div>
</div>
```

---

## 4. JavaScript (Sayfa sonuna veya ayrı JS dosyasına ekle)

```html
<script>
// Sipariş bilgileri (CFM'den alınacak)
var OPS_TASK_ORDER = {
    order_id: <cfoutput>#get_order_detail.order_id#</cfoutput>,
    order_number: '<cfoutput>#get_order_detail.order_number#</cfoutput>',
    company_id: <cfoutput>#session.ep.company_id#</cfoutput>,
    branch_id: <cfoutput>#session.ep.branch_id#</cfoutput>
};

// Ana görevler modalını aç
function openOpsTasksModal() {
    var modal = $('#modal_ops_tasks_main');
    
    // Sipariş bilgisini başlığa yaz
    $('#ops_tasks_order_info').text('(' + OPS_TASK_ORDER.order_number + ')');
    
    // Modal içeriğini AJAX ile yükle
    $.ajax({
        url: '/V16/sales/display/ops_task_list.cfm',
        data: {
            ref_type: 'ORDER',
            ref_id: OPS_TASK_ORDER.order_id,
            company_id: OPS_TASK_ORDER.company_id
        },
        success: function(html) {
            $('#modal_ops_tasks_body').html(html);
            
            // OpsTask config'ini ayarla
            window.OPS_TASK_CONFIG = {
                ref_type: 'ORDER',
                ref_id: OPS_TASK_ORDER.order_id,
                company_id: OPS_TASK_ORDER.company_id,
                branch_id: OPS_TASK_ORDER.branch_id,
                ajax_url: '/V16/sales/query/ajax_ops_task.cfm'
            };
            
            // OpsTask modülünü başlat
            if (typeof OpsTask !== 'undefined') {
                OpsTask.init();
            }
        },
        error: function() {
            $('#modal_ops_tasks_body').html(
                '<div class="alert alert-danger m-3">Görevler yüklenemedi.</div>'
            );
        }
    });
    
    modal.modal('show');
}
</script>

<!-- OpsTask JS dosyası -->
<script src="/V16/sales/js/ops_task.js"></script>
```

---

## 5. Dosya Konumları

| Dosya | Hedef Konum | Açıklama |
|-------|-------------|----------|
| `ajax_ops_task.cfm` | `/V16/sales/query/` | AJAX endpoint |
| `ops_task_list.cfm` | `/V16/sales/display/` | Görev listesi grid |
| `dsp_ops_task.cfm` | `/V16/sales/form/` | Görev modal formu |
| `ops_task.js` | `/V16/sales/js/` | Client-side JS |

---

## 6. Adım Adım Uygulama

### Adım 1: Dosyaları Kopyala
```bash
# report/ dizininden V16/sales/ dizinine kopyala
cp /Volumes/prod/documents/report/ajax_ops_task.cfm /Volumes/prod/V16/sales/query/
cp /Volumes/prod/documents/report/ops_task_list.cfm /Volumes/prod/V16/sales/display/
cp /Volumes/prod/documents/report/dsp_ops_task.cfm /Volumes/prod/V16/sales/form/

# js dizini yoksa oluştur
mkdir -p /Volumes/prod/V16/sales/js/
cp /Volumes/prod/documents/report/ops_task.js /Volumes/prod/V16/sales/js/
```

### Adım 2: Dropdown'a Ekle
`detail_order_sa_noeditor.cfm` dosyasında "Diğer" dropdown'unu bul ve içine ekle:
```html
<a class="dropdown-item" href="javascript:void(0);" onclick="openOpsTasksModal()">
    <i class="fa fa-tasks"></i> Görevler (Operasyonlar)
</a>
```

### Adım 3: Modal + JS Ekle
Aynı dosyanın sonuna (</body> öncesine) modal HTML ve JavaScript kodunu ekle.

### Adım 4: Test
1. Sipariş listesinden bir siparişe tıkla
2. "Diğer" dropdown'ına tıkla
3. "Görevler (Operasyonlar)" seçeneğine tıkla
4. Modal açılmalı ve görev listesi görünmeli
5. "+ Yeni Görev" butonu çalışmalı

---

## 7. Hızlı Test (İlk Aşama)

Dropdown'a sadece şu kodu ekleyerek test edebilirsiniz:

```html
<a class="dropdown-item" href="javascript:void(0);" onclick="alert('Görevler modülü hazır! ORDER_ID: ' + <cfoutput>#get_order_detail.order_id#</cfoutput>)">
    <i class="fa fa-tasks"></i> Görevler (Test)
</a>
```

Bu çalışıyorsa, tam entegrasyona geçebilirsiniz.

---

## 8. Alternatif: Ayrı Sekme Olarak

Eğer dropdown yerine ayrı bir buton/sekme tercih edilirse:

```html
<!-- Toolbar'a buton ekle (Diğer'in yanına) -->
<button type="button" class="btn btn-outline-primary btn-sm" onclick="openOpsTasksModal()">
    <i class="fa fa-tasks"></i> Görevler
</button>
```

---

**Hazırlayan:** Cascade AI  
**Versiyon:** 1.0
