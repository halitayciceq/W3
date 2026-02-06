<cfsilent>
<cfparam name="url.ref_type" default="ORDER">
<cfparam name="url.ref_id" default="0">
<cfparam name="url.company_id" default="#session.ep.company_id#">
<cfset refNo = "">
<cftry>
    <cfif url.ref_type EQ "ORDER" AND val(url.ref_id) GT 0>
        <cfquery name="qRef" datasource="#dsn#" maxrows="1">
            SELECT ORDER_NO FROM ORDERS WHERE ORDER_ID = <cfqueryparam value="#url.ref_id#" cfsqltype="cf_sql_integer">
        </cfquery>
        <cfif qRef.recordCount><cfset refNo = qRef.ORDER_NO></cfif>
    </cfif>
    <cfcatch><cflog file="ops_task_wizard" text="Ref query error: #cfcatch.message#"></cfcatch>
</cftry>
</cfsilent>
<!--- W3 Standart Wizard - Görevler Modal Eşleşmesi --->
<div class="pkg-modal" role="dialog" aria-modal="true" aria-labelledby="wizardTitle" id="pkgWizardModal">
    <!--- Header - Görevler Modal ile aynı --->
    <div class="pkg-modal-header">
        <div class="pkg-modal-title" id="wizardTitle">
            <i class="fa fa-magic"></i> Şablondan Oluştur<cfif len(refNo)> <span class="pkg-ref-no"><cfoutput>#encodeForHtml(refNo)#</cfoutput></span></cfif>
        </div>
        <button type="button" class="pkg-modal-close" onclick="pkgWizard.close()" aria-label="Kapat">&times;</button>
    </div>
    
    <!--- Stepper - Kompakt --->
    <div class="pkg-stepper">
        <div class="pkg-step active" data-step="1"><span class="pkg-step-num">1</span> Şablon Seç</div>
        <div class="pkg-step" data-step="2"><span class="pkg-step-num">2</span> Önizle</div>
        <div class="pkg-step" data-step="3"><span class="pkg-step-num">3</span> Tamamla</div>
    </div>
    
    <!--- Body --->
    <div class="pkg-modal-body">
        <!--- Step 1: Şablon Seç --->
        <div class="pkg-wizard-step" id="wizStep1">
            <table class="pkg-grid pkg-grid-selectable">
                <thead>
                    <tr>
                        <th width="30"></th>
                        <th>Şablon Adı</th>
                        <th width="100">Görev Sayısı</th>
                    </tr>
                </thead>
                <tbody>
                    <tr class="selected" data-template-id="-1" onclick="pkgWizard.selectTemplate(this, -1)">
                        <td><input type="radio" name="template" checked></td>
                        <td><i class="fa fa-list-alt"></i> Standart Sipariş Görevleri</td>
                        <td><span class="pkg-badge pkg-badge-info">6</span></td>
                    </tr>
                </tbody>
            </table>
        </div>
        
        <!--- Step 2: Önizle --->
        <div class="pkg-wizard-step" id="wizStep2" style="display:none;">
            <div class="pkg-toolbar-mini">
                <div class="pkg-toolbar-left">
                    <input type="checkbox" id="wizCheckAll" checked onchange="pkgWizard.toggleAll(this)">
                    <label for="wizCheckAll">Tümünü Seç</label>
                </div>
                <div class="pkg-toolbar-right">
                    <span class="pkg-summary">Toplam: <strong id="wizTotal">6</strong></span>
                    <span class="pkg-summary">Oluşturulacak: <strong id="wizCreate" class="pkg-text-success">6</strong></span>
                </div>
            </div>
            <div class="pkg-grid-scroll">
                <table class="pkg-grid" id="wizPreviewGrid">
                    <thead>
                        <tr>
                            <th width="30"><i class="fa fa-check"></i></th>
                            <th>Görev Adı</th>
                            <th width="100">Aşama</th>
                            <th width="150">Sorumlu</th>
                            <th width="110">Termin</th>
                        </tr>
                    </thead>
                    <tbody id="wizPreviewBody"></tbody>
                </table>
            </div>
        </div>
        
        <!--- Step 3: Tamamla --->
        <div class="pkg-wizard-step" id="wizStep3" style="display:none;">
            <div class="pkg-result">
                <div class="pkg-result-icon"><i class="fa fa-check-circle"></i></div>
                <div class="pkg-result-title">İşlem Tamamlandı</div>
                <div class="pkg-result-stats">
                    <div class="pkg-stat">
                        <span class="pkg-stat-num pkg-text-success" id="wizStatCreated">0</span>
                        <span class="pkg-stat-label">Oluşturuldu</span>
                    </div>
                    <div class="pkg-stat">
                        <span class="pkg-stat-num pkg-text-warning" id="wizStatSkipped">0</span>
                        <span class="pkg-stat-label">Atlandı</span>
                    </div>
                    <div class="pkg-stat">
                        <span class="pkg-stat-num pkg-text-danger" id="wizStatError">0</span>
                        <span class="pkg-stat-label">Hatalı</span>
                    </div>
                </div>
                <div class="pkg-result-errors" id="wizErrors" style="display:none;">
                    <div class="pkg-collapsible" onclick="this.classList.toggle('open')">
                        <i class="fa fa-exclamation-triangle"></i> Hatalar <i class="fa fa-chevron-down"></i>
                    </div>
                    <div class="pkg-collapsible-body" id="wizErrorList"></div>
                </div>
            </div>
        </div>
    </div>
    
    <!--- Footer - Görevler Modal ile aynı --->
    <div class="pkg-modal-footer">
        <button type="button" class="pkg-btn pkg-btn-default" id="wizBtnCancel" onclick="pkgWizard.close()">İptal</button>
        <div class="pkg-btn-group">
            <button type="button" class="pkg-btn pkg-btn-default" id="wizBtnBack" onclick="pkgWizard.back()" style="display:none;"><i class="fa fa-arrow-left"></i> Geri</button>
            <button type="button" class="pkg-btn pkg-btn-primary" id="wizBtnNext" onclick="pkgWizard.next()">Önizle <i class="fa fa-arrow-right"></i></button>
        </div>
    </div>
</div>

<style>
/* W3 pkg-* Standard Classes - Görevler Modal Eşleşmesi */
.pkg-modal { background: #fff; border-radius: 6px; box-shadow: 0 4px 20px rgba(0,0,0,0.15); max-width: 800px; width: 100%; font-family: Arial, sans-serif; font-size: 13px; }
.pkg-modal-header { background: linear-gradient(180deg, #00b4b4 0%, #009999 100%); color: #fff; padding: 10px 15px; display: flex; justify-content: space-between; align-items: center; border-radius: 6px 6px 0 0; }
.pkg-modal-title { font-size: 14px; font-weight: 600; display: flex; align-items: center; gap: 8px; }
.pkg-modal-title i { font-size: 14px; }
.pkg-ref-no { opacity: 0.9; font-weight: 400; margin-left: 5px; }
.pkg-modal-close { background: none; border: none; color: #fff; font-size: 22px; cursor: pointer; opacity: 0.8; line-height: 1; padding: 0 5px; }
.pkg-modal-close:hover { opacity: 1; }
.pkg-modal-body { padding: 0; min-height: 200px; max-height: 350px; overflow: auto; }
.pkg-modal-footer { padding: 10px 15px; background: #f8f9fa; border-top: 1px solid #e0e0e0; display: flex; justify-content: space-between; align-items: center; border-radius: 0 0 6px 6px; }

/* Stepper */
.pkg-stepper { display: flex; gap: 0; background: #f0f0f0; border-bottom: 1px solid #ddd; }
.pkg-step { flex: 1; padding: 8px 12px; font-size: 12px; color: #888; display: flex; align-items: center; gap: 6px; border-bottom: 2px solid transparent; }
.pkg-step.active { color: #009999; border-bottom-color: #009999; background: #fff; font-weight: 600; }
.pkg-step.done { color: #4caf50; }
.pkg-step-num { width: 18px; height: 18px; border-radius: 50%; background: #ddd; color: #666; display: inline-flex; align-items: center; justify-content: center; font-size: 11px; font-weight: bold; }
.pkg-step.active .pkg-step-num { background: #009999; color: #fff; }
.pkg-step.done .pkg-step-num { background: #4caf50; color: #fff; }

/* Grid - Görevler Modal ile aynı */
.pkg-grid { width: 100%; border-collapse: collapse; }
.pkg-grid thead th { background: linear-gradient(180deg, #00b4b4 0%, #009999 100%); color: #fff; padding: 8px 10px; font-size: 12px; font-weight: 600; text-align: left; border: none; }
.pkg-grid tbody td { padding: 6px 10px; border-bottom: 1px solid #e8e8e8; vertical-align: middle; }
.pkg-grid tbody tr:nth-child(even) { background: #fafafa; }
.pkg-grid tbody tr:hover { background: #e8f5f5; }
.pkg-grid-selectable tbody tr { cursor: pointer; }
.pkg-grid-selectable tbody tr.selected { background: #e0f2f2; }
.pkg-grid-selectable tbody tr.selected td { border-bottom-color: #b2dfdf; }
.pkg-grid-scroll { max-height: 280px; overflow-y: auto; }

/* Mini Toolbar */
.pkg-toolbar-mini { display: flex; justify-content: space-between; align-items: center; padding: 8px 12px; background: #f8f9fa; border-bottom: 1px solid #e0e0e0; font-size: 12px; }
.pkg-toolbar-left { display: flex; align-items: center; gap: 6px; }
.pkg-toolbar-right { display: flex; gap: 15px; }
.pkg-summary strong { margin-left: 3px; }

/* Buttons - Görevler Modal ile aynı */
.pkg-btn { padding: 8px 16px; border-radius: 4px; font-size: 13px; font-weight: 500; cursor: pointer; border: 1px solid transparent; transition: all 0.15s; }
.pkg-btn-default { background: #fff; border-color: #ccc; color: #333; }
.pkg-btn-default:hover { background: #f5f5f5; }
.pkg-btn-primary { background: #00b4b4; border-color: #009999; color: #fff; }
.pkg-btn-primary:hover { background: #009999; }
.pkg-btn-success { background: #4caf50; border-color: #43a047; color: #fff; }
.pkg-btn-success:hover { background: #43a047; }
.pkg-btn:disabled { opacity: 0.6; cursor: not-allowed; }
.pkg-btn-group { display: flex; gap: 8px; }

/* Badges */
.pkg-badge { padding: 3px 8px; border-radius: 10px; font-size: 11px; font-weight: 600; }
.pkg-badge-info { background: #e0f2f2; color: #00796b; }
.pkg-badge-success { background: #e8f5e9; color: #2e7d32; }
.pkg-badge-warning { background: #fff8e1; color: #f57c00; }
.pkg-badge-danger { background: #ffebee; color: #c62828; }

/* Inputs - Kompakt */
.pkg-input { padding: 4px 8px; border: 1px solid #ddd; border-radius: 3px; font-size: 12px; width: 100%; box-sizing: border-box; }
.pkg-input:focus { border-color: #00b4b4; outline: none; }
.pkg-select { padding: 4px 6px; border: 1px solid #ddd; border-radius: 3px; font-size: 12px; background: #fff; }

/* Result */
.pkg-result { text-align: center; padding: 30px 20px; }
.pkg-result-icon { font-size: 50px; color: #4caf50; margin-bottom: 15px; }
.pkg-result-title { font-size: 16px; font-weight: 600; color: #333; margin-bottom: 20px; }
.pkg-result-stats { display: inline-flex; gap: 30px; }
.pkg-stat { text-align: center; }
.pkg-stat-num { display: block; font-size: 24px; font-weight: 700; }
.pkg-stat-label { font-size: 11px; color: #888; }
.pkg-text-success { color: #4caf50; }
.pkg-text-warning { color: #ff9800; }
.pkg-text-danger { color: #f44336; }
.pkg-result-errors { margin-top: 20px; text-align: left; }
.pkg-collapsible { padding: 8px 12px; background: #fff3e0; border-radius: 4px; cursor: pointer; font-size: 12px; color: #e65100; }
.pkg-collapsible i.fa-chevron-down { float: right; transition: transform 0.2s; }
.pkg-collapsible.open i.fa-chevron-down { transform: rotate(180deg); }
.pkg-collapsible-body { display: none; padding: 10px; background: #fff; border: 1px solid #ffe0b2; border-top: none; font-size: 12px; max-height: 100px; overflow: auto; }
.pkg-collapsible.open + .pkg-collapsible-body { display: block; }

/* Wizard Step */
.pkg-wizard-step { padding: 0; }
#wizStep1 .pkg-grid { margin: 0; }
#wizStep1 .pkg-grid tbody td { padding: 8px 10px; }
</style>

<script>
window.pkgWizard = {
    step: 1,
    templateId: -1,
    config: {
        refType: '<cfoutput>#encodeForJavaScript(url.ref_type)#</cfoutput>',
        refId: <cfoutput>#val(url.ref_id)#</cfoutput>,
        companyId: <cfoutput>#val(url.company_id)#</cfoutput>,
        ajaxUrl: '/V16/sales/query/ajax_ops_task.cfm'
    },
    tasks: [
        {code:'ORDER_APPROVAL', head:'SİPARİŞ ONAYI', days:0},
        {code:'PAYMENT_CHECK', head:'ÖDEME KONTROLÜ', days:1},
        {code:'DESIGN', head:'TASARIM', days:5},
        {code:'PRODUCTION', head:'ÜRETİM', days:14},
        {code:'QUALITY', head:'KALİTE KONTROL', days:21},
        {code:'SHIPMENT', head:'SEVKİYAT', days:30}
    ],
    errors: [],
    
    init: function(){
        document.addEventListener('keydown', function(e){
            if(e.key === 'Escape') pkgWizard.close();
        });
    },
    
    close: function(){
        var modal = document.getElementById('ops_task_wizard_modal');
        if(modal) modal.remove();
        if(typeof OpsTask !== 'undefined') OpsTask.loadList();
    },
    
    selectTemplate: function(row, id){
        document.querySelectorAll('.pkg-grid-selectable tbody tr').forEach(function(r){
            r.classList.remove('selected');
            r.querySelector('input[type="radio"]').checked = false;
        });
        row.classList.add('selected');
        row.querySelector('input[type="radio"]').checked = true;
        this.templateId = id;
    },
    
    next: function(){
        if(this.step === 1){
            this.step = 2;
            this.renderPreview();
            this.updateUI();
        } else if(this.step === 2){
            this.createTasks();
        }
    },
    
    back: function(){
        if(this.step === 2){
            this.step = 1;
            this.updateUI();
        }
    },
    
    updateUI: function(){
        var self = this;
        document.getElementById('wizStep1').style.display = this.step === 1 ? 'block' : 'none';
        document.getElementById('wizStep2').style.display = this.step === 2 ? 'block' : 'none';
        document.getElementById('wizStep3').style.display = this.step === 3 ? 'block' : 'none';
        
        document.querySelectorAll('.pkg-step').forEach(function(s){
            var stepNum = parseInt(s.dataset.step);
            s.classList.remove('active', 'done');
            if(stepNum === self.step) s.classList.add('active');
            else if(stepNum < self.step) s.classList.add('done');
        });
        
        document.getElementById('wizBtnBack').style.display = this.step === 2 ? 'inline-block' : 'none';
        document.getElementById('wizBtnNext').style.display = this.step < 3 ? 'inline-block' : 'none';
        document.getElementById('wizBtnCancel').textContent = this.step === 3 ? 'Kapat' : 'İptal';
        
        if(this.step === 2){
            document.getElementById('wizBtnNext').innerHTML = '<i class="fa fa-check"></i> Görevleri Oluştur';
            document.getElementById('wizBtnNext').className = 'pkg-btn pkg-btn-success';
        } else if(this.step === 1){
            document.getElementById('wizBtnNext').innerHTML = 'Önizle <i class="fa fa-arrow-right"></i>';
            document.getElementById('wizBtnNext').className = 'pkg-btn pkg-btn-primary';
        }
    },
    
    renderPreview: function(){
        var html = '';
        var today = new Date();
        this.tasks.forEach(function(t, i){
            var d = new Date(today);
            d.setDate(d.getDate() + t.days);
            var deadline = d.toISOString().split('T')[0];
            html += '<tr data-idx="'+i+'">';
            html += '<td><input type="checkbox" class="wiz-chk" data-idx="'+i+'" checked onchange="pkgWizard.updateCount()"></td>';
            html += '<td><strong>'+t.head+'</strong></td>';
            html += '<td><select class="pkg-select wiz-status" data-idx="'+i+'"><option value="planning" selected>Planlama</option><option value="progress">Devam Ediyor</option></select></td>';
            html += '<td><input type="text" class="pkg-input wiz-emp" data-idx="'+i+'" placeholder="Sorumlu seçin..."></td>';
            html += '<td><input type="date" class="pkg-input wiz-date" data-idx="'+i+'" value="'+deadline+'"></td>';
            html += '</tr>';
        });
        document.getElementById('wizPreviewBody').innerHTML = html;
        this.updateCount();
    },
    
    toggleAll: function(el){
        document.querySelectorAll('.wiz-chk').forEach(function(c){ c.checked = el.checked; });
        this.updateCount();
    },
    
    updateCount: function(){
        var total = this.tasks.length;
        var checked = document.querySelectorAll('.wiz-chk:checked').length;
        document.getElementById('wizTotal').textContent = total;
        document.getElementById('wizCreate').textContent = checked;
    },
    
    createTasks: async function(){
        var btn = document.getElementById('wizBtnNext');
        btn.disabled = true;
        btn.innerHTML = '<i class="fa fa-spinner fa-spin"></i> Oluşturuluyor...';
        
        var created = 0, skipped = 0, errored = 0;
        this.errors = [];
        var checks = document.querySelectorAll('.wiz-chk:checked');
        
        for(var i=0; i<checks.length; i++){
            var idx = parseInt(checks[i].dataset.idx);
            var t = this.tasks[idx];
            var dateInput = document.querySelector('.wiz-date[data-idx="'+idx+'"]');
            var deadline = dateInput ? dateInput.value : '';
            
            var fd = new FormData();
            fd.append('action', 'save');
            fd.append('task_head', t.head);
            fd.append('ref_type', this.config.refType);
            fd.append('ref_id', this.config.refId);
            fd.append('deadline', deadline);
            fd.append('priority_id', '2');
            fd.append('company_id', this.config.companyId);
            
            try {
                var resp = await fetch(this.config.ajaxUrl, {method:'POST', body:fd});
                var json = await resp.json();
                if(json.success) created++;
                else { errored++; this.errors.push(t.head + ': ' + (json.message || 'Bilinmeyen hata')); }
            } catch(e){ errored++; this.errors.push(t.head + ': Bağlantı hatası'); }
        }
        
        document.getElementById('wizStatCreated').textContent = created;
        document.getElementById('wizStatSkipped').textContent = skipped;
        document.getElementById('wizStatError').textContent = errored;
        
        if(this.errors.length > 0){
            document.getElementById('wizErrors').style.display = 'block';
            document.getElementById('wizErrorList').innerHTML = this.errors.map(function(e){ return '<div>• '+e+'</div>'; }).join('');
        }
        
        this.step = 3;
        this.updateUI();
    }
};

pkgWizard.init();
</script>
