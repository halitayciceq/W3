<cfsilent>
<cfparam name="url.ref_type" default="ORDER">
<cfparam name="url.ref_id" default="0">
<cfparam name="url.company_id" default="#session.ep.company_id#">
</cfsilent>
<div style="padding:20px;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;">
    
    <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:20px;padding-bottom:15px;border-bottom:2px solid ##e5e7eb;">
        <h3 style="margin:0;font-size:18px;color:##1e293b;">
            <i class="fa fa-magic" style="color:##16a34a;margin-right:8px;"></i>Şablondan Görev Oluştur
        </h3>
        <button onclick="document.getElementById('ops_task_wizard_modal').remove();if(typeof OpsTask!=='undefined')OpsTask.loadList();" style="background:none;border:none;font-size:24px;color:##64748b;cursor:pointer;">&times;</button>
    </div>
    
    <!-- Step 1 -->
    <div id="wiz_step1">
        <h4 style="margin:0 0 15px 0;font-size:14px;color:##475569;">1. Şablon Seçin</h4>
        <div style="border:2px solid ##2563eb;border-radius:8px;padding:15px;cursor:pointer;display:flex;align-items:center;gap:12px;background:##eff6ff;">
            <div style="width:20px;height:20px;border:2px solid ##2563eb;border-radius:50%;display:flex;align-items:center;justify-content:center;">
                <div style="width:12px;height:12px;background:##2563eb;border-radius:50%;"></div>
            </div>
            <div style="flex:1;">
                <div style="font-weight:600;color:##1e293b;">Standart Sipariş Görevleri</div>
                <div style="font-size:12px;color:##64748b;">Varsayılan görev şablonu</div>
            </div>
            <div style="background:##e0e7ff;color:##3730a3;padding:4px 12px;border-radius:12px;font-size:12px;font-weight:500;">6 görev</div>
        </div>
        <div style="margin-top:20px;text-align:right;">
            <button onclick="document.getElementById('ops_task_wizard_modal').remove();" style="padding:10px 20px;background:##f1f5f9;border:1px solid ##d1d5db;border-radius:6px;cursor:pointer;margin-right:10px;">İptal</button>
            <button onclick="wizShowPreview()" style="padding:10px 20px;background:##2563eb;color:##fff;border:none;border-radius:6px;cursor:pointer;">
                Önizle <i class="fa fa-arrow-right"></i>
            </button>
        </div>
    </div>
    
    <!-- Step 2 -->
    <div id="wiz_step2" style="display:none;">
        <h4 style="margin:0 0 15px 0;font-size:14px;color:##475569;">2. Görevleri Onaylayın</h4>
        <div style="background:##f0fdf4;padding:12px 16px;border-radius:6px;margin-bottom:15px;">
            Toplam: <strong>6</strong> | Oluşturulacak: <strong style="color:##16a34a;">6</strong>
        </div>
        <div id="wiz_preview" style="max-height:300px;overflow:auto;border:1px solid ##e5e7eb;border-radius:6px;"></div>
        <div style="margin-top:20px;display:flex;justify-content:space-between;">
            <button onclick="wizShowStep(1)" style="padding:10px 20px;background:##f1f5f9;border:1px solid ##d1d5db;border-radius:6px;cursor:pointer;">
                <i class="fa fa-arrow-left"></i> Geri
            </button>
            <button id="wiz_btn_create" onclick="wizCreateTasks()" style="padding:10px 24px;background:##16a34a;color:##fff;border:none;border-radius:6px;cursor:pointer;font-weight:600;">
                <i class="fa fa-check"></i> Görevleri Oluştur
            </button>
        </div>
    </div>
    
    <!-- Step 3 -->
    <div id="wiz_step3" style="display:none;">
        <div id="wiz_result" style="text-align:center;padding:40px;"></div>
        <div style="text-align:center;margin-top:20px;">
            <button onclick="document.getElementById('ops_task_wizard_modal').remove();if(typeof OpsTask!=='undefined')OpsTask.loadList();" style="padding:10px 30px;background:##2563eb;color:##fff;border:none;border-radius:6px;cursor:pointer;">Tamam</button>
        </div>
    </div>
</div>

<script>
var WIZ = {
    refType: '<cfoutput>#url.ref_type#</cfoutput>',
    refId: <cfoutput>#val(url.ref_id)#</cfoutput>,
    companyId: <cfoutput>#val(url.company_id)#</cfoutput>,
    tasks: [
        {code:'ORDER_APPROVAL', head:'SİPARİŞ ONAYI', days:0},
        {code:'PAYMENT_CHECK', head:'ÖDEME KONTROLÜ', days:1},
        {code:'DESIGN', head:'TASARIM', days:5},
        {code:'PRODUCTION', head:'ÜRETİM', days:14},
        {code:'QUALITY', head:'KALİTE KONTROL', days:21},
        {code:'SHIPMENT', head:'SEVKİYAT', days:30}
    ]
};

window.wizShowStep = function(n){
    document.getElementById('wiz_step1').style.display = n==1 ? 'block' : 'none';
    document.getElementById('wiz_step2').style.display = n==2 ? 'block' : 'none';
    document.getElementById('wiz_step3').style.display = n==3 ? 'block' : 'none';
};

window.wizShowPreview = function(){
    wizShowStep(2);
    var html = '<table style="width:100%;border-collapse:collapse;font-size:13px;">';
    html += '<thead style="background:#f8fafc;"><tr>';
    html += '<th style="padding:8px;border-bottom:1px solid #e5e7eb;width:30px;"><input type="checkbox" checked onchange="wizToggleAll(this)"></th>';
    html += '<th style="padding:8px;border-bottom:1px solid #e5e7eb;">Görev</th>';
    html += '<th style="padding:8px;border-bottom:1px solid #e5e7eb;width:180px;">Sorumlu</th>';
    html += '<th style="padding:8px;border-bottom:1px solid #e5e7eb;width:120px;">Termin</th>';
    html += '</tr></thead><tbody>';
    
    var today = new Date();
    WIZ.tasks.forEach(function(t, i){
        var d = new Date(today);
        d.setDate(d.getDate() + t.days);
        var deadline = d.toISOString().split('T')[0];
        html += '<tr>';
        html += '<td style="padding:8px;border-bottom:1px solid #e5e7eb;text-align:center;"><input type="checkbox" class="wiz-chk" data-idx="'+i+'" checked></td>';
        html += '<td style="padding:8px;border-bottom:1px solid #e5e7eb;"><strong>'+t.head+'</strong></td>';
        html += '<td style="padding:8px;border-bottom:1px solid #e5e7eb;"><input type="text" class="wiz-emp" data-idx="'+i+'" placeholder="Sorumlu ara..." style="width:100%;padding:6px;border:1px solid #d1d5db;border-radius:4px;font-size:12px;" onfocus="wizEmpSearch(this)" data-emp-id=""></td>';
        html += '<td style="padding:8px;border-bottom:1px solid #e5e7eb;"><input type="date" class="wiz-date" data-idx="'+i+'" value="'+deadline+'" style="width:100%;padding:6px;border:1px solid #d1d5db;border-radius:4px;font-size:12px;"></td>';
        html += '</tr>';
    });
    html += '</tbody></table>';
    document.getElementById('wiz_preview').innerHTML = html;
};

window.wizToggleAll = function(el){
    document.querySelectorAll('.wiz-chk').forEach(function(c){ c.checked = el.checked; });
};

window.wizEmpSearch = function(input){
    // Basit autocomplete - input'a yazınca arama yapar
    input.addEventListener('input', function(){
        var q = this.value;
        if(q.length < 2) return;
        
        var fd = new FormData();
        fd.append('action', 'employee_search');
        fd.append('q', q);
        
        fetch('/V16/sales/query/ajax_ops_task.cfm', {method:'POST', body:fd})
        .then(function(r){ return r.json(); })
        .then(function(json){
            if(json.success && json.data.length > 0){
                var first = json.data[0];
                input.value = first.name;
                input.dataset.empId = first.id;
            }
        });
    });
};

window.wizCreateTasks = async function(){
    var btn = document.getElementById('wiz_btn_create');
    btn.disabled = true;
    btn.innerHTML = '<i class="fa fa-spinner fa-spin"></i> Oluşturuluyor...';
    
    var created = 0, errors = 0;
    var checks = document.querySelectorAll('.wiz-chk:checked');
    
    for(var i=0; i<checks.length; i++){
        var idx = parseInt(checks[i].dataset.idx);
        var t = WIZ.tasks[idx];
        
        // Satırdaki değerleri al
        var empInput = document.querySelector('.wiz-emp[data-idx="'+idx+'"]');
        var dateInput = document.querySelector('.wiz-date[data-idx="'+idx+'"]');
        var empId = empInput ? empInput.dataset.empId : '';
        var deadline = dateInput ? dateInput.value : '';
        
        var fd = new FormData();
        fd.append('action', 'save');
        fd.append('task_head', t.head);
        fd.append('ref_type', WIZ.refType);
        fd.append('ref_id', WIZ.refId);
        fd.append('deadline', deadline);
        fd.append('priority_id', '2');
        fd.append('company_id', WIZ.companyId);
        if(empId) fd.append('assigned_emp_id', empId);
        
        try {
            var resp = await fetch('/V16/sales/query/ajax_ops_task.cfm', {method:'POST', body:fd});
            var json = await resp.json();
            if(json.success) created++; else errors++;
        } catch(e){ errors++; }
    }
    
    wizShowStep(3);
    document.getElementById('wiz_result').innerHTML = 
        '<div style="font-size:48px;color:#16a34a;margin-bottom:20px;">✓</div>' +
        '<h3 style="margin:0 0 20px 0;color:#1e293b;">İşlem Tamamlandı</h3>' +
        '<div style="background:#f8fafc;padding:20px 40px;border-radius:8px;display:inline-block;">' +
        '<span style="font-size:24px;font-weight:700;color:#16a34a;">'+created+'</span> görev oluşturuldu' +
        '</div>';
}
</script>
