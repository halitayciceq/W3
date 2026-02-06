<cfsilent>
<cfparam name="url.ref_type" default="ORDER">
<cfparam name="url.ref_id" default="0">
<cfparam name="url.company_id" default="#session.ep.company_id#">
</cfsilent>
<!--- W3 Standart Wizard Tasarımı --->
<style>
.wiz-container { font-family: Arial, sans-serif; }
.wiz-header { background: linear-gradient(180deg, ##00b4b4 0%, ##009999 100%); color: ##fff; padding: 12px 20px; display: flex; justify-content: space-between; align-items: center; }
.wiz-header h3 { margin: 0; font-size: 16px; font-weight: 600; }
.wiz-header .close-btn { background: none; border: none; color: ##fff; font-size: 24px; cursor: pointer; opacity: 0.8; }
.wiz-header .close-btn:hover { opacity: 1; }
.wiz-body { padding: 20px; }
.wiz-steps { display: flex; gap: 8px; margin-bottom: 20px; padding-bottom: 15px; border-bottom: 1px solid ##e0e0e0; }
.wiz-step { display: flex; align-items: center; gap: 8px; padding: 8px 16px; border-radius: 20px; font-size: 13px; background: ##f5f5f5; color: ##666; }
.wiz-step.active { background: ##00b4b4; color: ##fff; }
.wiz-step.done { background: ##4caf50; color: ##fff; }
.wiz-step-num { width: 22px; height: 22px; border-radius: 50%; background: rgba(255,255,255,0.3); display: flex; align-items: center; justify-content: center; font-weight: bold; font-size: 12px; }
.wiz-section-title { font-size: 14px; font-weight: 600; color: ##333; margin-bottom: 15px; padding-left: 10px; border-left: 3px solid ##00b4b4; }
.wiz-template-card { border: 2px solid ##e0e0e0; border-radius: 8px; padding: 16px; cursor: pointer; transition: all 0.2s; display: flex; align-items: center; gap: 15px; margin-bottom: 10px; }
.wiz-template-card:hover { border-color: ##00b4b4; background: ##f0fafa; }
.wiz-template-card.selected { border-color: ##00b4b4; background: ##e0f7f7; }
.wiz-template-radio { width: 20px; height: 20px; border: 2px solid ##ccc; border-radius: 50%; display: flex; align-items: center; justify-content: center; }
.wiz-template-card.selected .wiz-template-radio { border-color: ##00b4b4; }
.wiz-template-card.selected .wiz-template-radio::after { content: ''; width: 10px; height: 10px; background: ##00b4b4; border-radius: 50%; }
.wiz-template-info { flex: 1; }
.wiz-template-name { font-weight: 600; color: ##333; margin-bottom: 4px; }
.wiz-template-desc { font-size: 12px; color: ##888; }
.wiz-template-badge { background: ##00b4b4; color: ##fff; padding: 6px 14px; border-radius: 15px; font-size: 12px; font-weight: 600; }
.wiz-footer { display: flex; justify-content: space-between; padding: 15px 20px; background: ##f8f9fa; border-top: 1px solid ##e0e0e0; }
.wiz-btn { padding: 10px 24px; border-radius: 5px; font-size: 13px; font-weight: 600; cursor: pointer; border: none; transition: all 0.2s; }
.wiz-btn-secondary { background: ##fff; border: 1px solid ##ccc; color: ##666; }
.wiz-btn-secondary:hover { background: ##f5f5f5; }
.wiz-btn-primary { background: ##00b4b4; color: ##fff; }
.wiz-btn-primary:hover { background: ##009999; }
.wiz-btn-success { background: ##4caf50; color: ##fff; }
.wiz-btn-success:hover { background: ##43a047; }
.wiz-preview-table { width: 100%; border-collapse: collapse; }
.wiz-preview-table th { background: ##00b4b4; color: ##fff; padding: 10px 8px; font-size: 12px; text-align: left; }
.wiz-preview-table td { padding: 10px 8px; border-bottom: 1px solid ##e0e0e0; font-size: 13px; }
.wiz-preview-table tr:hover { background: ##f5f5f5; }
.wiz-preview-table input[type="text"], .wiz-preview-table input[type="date"] { width: 100%; padding: 6px 8px; border: 1px solid ##ddd; border-radius: 4px; font-size: 12px; }
.wiz-preview-table input:focus { border-color: ##00b4b4; outline: none; }
.wiz-summary { display: flex; gap: 20px; padding: 12px 16px; background: ##e8f5e9; border-radius: 6px; margin-bottom: 15px; }
.wiz-summary-item { font-size: 13px; }
.wiz-summary-item strong { color: ##2e7d32; }
.wiz-result { text-align: center; padding: 40px 20px; }
.wiz-result-icon { font-size: 60px; margin-bottom: 20px; }
.wiz-result-icon.success { color: ##4caf50; }
.wiz-result-title { font-size: 20px; font-weight: 600; color: ##333; margin-bottom: 10px; }
.wiz-result-stats { display: inline-flex; gap: 30px; background: ##f5f5f5; padding: 20px 40px; border-radius: 8px; margin-top: 20px; }
.wiz-result-stat { text-align: center; }
.wiz-result-stat-num { font-size: 28px; font-weight: 700; color: ##00b4b4; }
.wiz-result-stat-label { font-size: 12px; color: ##888; }
</style>

<div class="wiz-container">
    <div class="wiz-header">
        <h3><i class="fa fa-magic"></i> Şablondan Görev Oluştur</h3>
        <button class="close-btn" onclick="document.getElementById('ops_task_wizard_modal').remove();if(typeof OpsTask!=='undefined')OpsTask.loadList();">&times;</button>
    </div>
    
    <div class="wiz-body">
        <!--- Progress Steps --->
        <div class="wiz-steps">
            <div class="wiz-step active" id="wiz_step_ind_1"><span class="wiz-step-num">1</span> Şablon Seç</div>
            <div class="wiz-step" id="wiz_step_ind_2"><span class="wiz-step-num">2</span> Önizle</div>
            <div class="wiz-step" id="wiz_step_ind_3"><span class="wiz-step-num">3</span> Tamamla</div>
        </div>
        
        <!--- Step 1: Template Selection --->
        <div id="wiz_step1">
            <div class="wiz-section-title">Görev Şablonu Seçin</div>
            <div class="wiz-template-card selected">
                <div class="wiz-template-radio"></div>
                <div class="wiz-template-info">
                    <div class="wiz-template-name"><i class="fa fa-list-alt"></i> Standart Sipariş Görevleri</div>
                    <div class="wiz-template-desc">Sipariş süreçleri için varsayılan görev şablonu</div>
                </div>
                <div class="wiz-template-badge">6 Görev</div>
            </div>
        </div>
        
        <!--- Step 2: Preview --->
        <div id="wiz_step2" style="display:none;">
            <div class="wiz-section-title">Oluşturulacak Görevler</div>
            <div class="wiz-summary">
                <div class="wiz-summary-item">Toplam: <strong>6</strong></div>
                <div class="wiz-summary-item">Oluşturulacak: <strong>6</strong></div>
            </div>
            <div style="max-height:280px;overflow:auto;">
                <table class="wiz-preview-table">
                    <thead>
                        <tr>
                            <th width="30"><input type="checkbox" checked onchange="wizToggleAll(this)"></th>
                            <th>Görev Adı</th>
                            <th width="180">Sorumlu</th>
                            <th width="130">Termin</th>
                        </tr>
                    </thead>
                    <tbody id="wiz_preview_body"></tbody>
                </table>
            </div>
        </div>
        
        <!--- Step 3: Result --->
        <div id="wiz_step3" style="display:none;">
            <div class="wiz-result">
                <div class="wiz-result-icon success"><i class="fa fa-check-circle"></i></div>
                <div class="wiz-result-title">Görevler Başarıyla Oluşturuldu!</div>
                <div class="wiz-result-stats">
                    <div class="wiz-result-stat">
                        <div class="wiz-result-stat-num" id="wiz_created_count">0</div>
                        <div class="wiz-result-stat-label">Oluşturuldu</div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <div class="wiz-footer">
        <button class="wiz-btn wiz-btn-secondary" id="wiz_btn_cancel" onclick="document.getElementById('ops_task_wizard_modal').remove();">İptal</button>
        <div>
            <button class="wiz-btn wiz-btn-secondary" id="wiz_btn_back" onclick="wizBack()" style="display:none;margin-right:10px;"><i class="fa fa-arrow-left"></i> Geri</button>
            <button class="wiz-btn wiz-btn-primary" id="wiz_btn_next" onclick="wizNext()">Önizle <i class="fa fa-arrow-right"></i></button>
        </div>
    </div>
</div>

<script>
var WIZ = {
    step: 1,
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

window.wizNext = function(){
    if(WIZ.step === 1){
        WIZ.step = 2;
        wizRenderPreview();
        wizUpdateUI();
    } else if(WIZ.step === 2){
        wizCreateTasks();
    }
};

window.wizBack = function(){
    if(WIZ.step === 2){
        WIZ.step = 1;
        wizUpdateUI();
    }
};

window.wizUpdateUI = function(){
    document.getElementById('wiz_step1').style.display = WIZ.step === 1 ? 'block' : 'none';
    document.getElementById('wiz_step2').style.display = WIZ.step === 2 ? 'block' : 'none';
    document.getElementById('wiz_step3').style.display = WIZ.step === 3 ? 'block' : 'none';
    
    document.getElementById('wiz_step_ind_1').className = 'wiz-step ' + (WIZ.step === 1 ? 'active' : (WIZ.step > 1 ? 'done' : ''));
    document.getElementById('wiz_step_ind_2').className = 'wiz-step ' + (WIZ.step === 2 ? 'active' : (WIZ.step > 2 ? 'done' : ''));
    document.getElementById('wiz_step_ind_3').className = 'wiz-step ' + (WIZ.step === 3 ? 'active' : '');
    
    document.getElementById('wiz_btn_back').style.display = WIZ.step === 2 ? 'inline-block' : 'none';
    document.getElementById('wiz_btn_next').style.display = WIZ.step < 3 ? 'inline-block' : 'none';
    document.getElementById('wiz_btn_cancel').style.display = WIZ.step < 3 ? 'inline-block' : 'none';
    
    if(WIZ.step === 2){
        document.getElementById('wiz_btn_next').innerHTML = '<i class="fa fa-check"></i> Görevleri Oluştur';
        document.getElementById('wiz_btn_next').className = 'wiz-btn wiz-btn-success';
    } else if(WIZ.step === 1){
        document.getElementById('wiz_btn_next').innerHTML = 'Önizle <i class="fa fa-arrow-right"></i>';
        document.getElementById('wiz_btn_next').className = 'wiz-btn wiz-btn-primary';
    }
};

window.wizRenderPreview = function(){
    var html = '';
    var today = new Date();
    WIZ.tasks.forEach(function(t, i){
        var d = new Date(today);
        d.setDate(d.getDate() + t.days);
        var deadline = d.toISOString().split('T')[0];
        html += '<tr>';
        html += '<td><input type="checkbox" class="wiz-chk" data-idx="'+i+'" checked></td>';
        html += '<td><strong>'+t.head+'</strong></td>';
        html += '<td><input type="text" class="wiz-emp" data-idx="'+i+'" placeholder="Sorumlu seçin..."></td>';
        html += '<td><input type="date" class="wiz-date" data-idx="'+i+'" value="'+deadline+'"></td>';
        html += '</tr>';
    });
    document.getElementById('wiz_preview_body').innerHTML = html;
};

window.wizToggleAll = function(el){
    document.querySelectorAll('.wiz-chk').forEach(function(c){ c.checked = el.checked; });
};

window.wizCreateTasks = async function(){
    var btn = document.getElementById('wiz_btn_next');
    btn.disabled = true;
    btn.innerHTML = '<i class="fa fa-spinner fa-spin"></i> Oluşturuluyor...';
    
    var created = 0;
    var checks = document.querySelectorAll('.wiz-chk:checked');
    
    for(var i=0; i<checks.length; i++){
        var idx = parseInt(checks[i].dataset.idx);
        var t = WIZ.tasks[idx];
        var dateInput = document.querySelector('.wiz-date[data-idx="'+idx+'"]');
        var deadline = dateInput ? dateInput.value : '';
        
        var fd = new FormData();
        fd.append('action', 'save');
        fd.append('task_head', t.head);
        fd.append('ref_type', WIZ.refType);
        fd.append('ref_id', WIZ.refId);
        fd.append('deadline', deadline);
        fd.append('priority_id', '2');
        fd.append('company_id', WIZ.companyId);
        
        try {
            var resp = await fetch('/V16/sales/query/ajax_ops_task.cfm', {method:'POST', body:fd});
            var json = await resp.json();
            if(json.success) created++;
        } catch(e){}
    }
    
    document.getElementById('wiz_created_count').textContent = created;
    WIZ.step = 3;
    wizUpdateUI();
    
    // Add close button
    document.querySelector('.wiz-footer').innerHTML = '<div></div><button class="wiz-btn wiz-btn-primary" onclick="document.getElementById(\'ops_task_wizard_modal\').remove();if(typeof OpsTask!==\'undefined\')OpsTask.loadList();">Tamam</button>';
};
</script>
