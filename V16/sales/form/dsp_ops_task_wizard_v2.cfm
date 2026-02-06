<cfsilent>
<cfparam name="url.ref_type" default="ORDER">
<cfparam name="url.ref_id" default="0">
<cfparam name="url.company_id" default="#session.ep.company_id#">
<cfif NOT isDefined("dsn")><cfset dsn = "workcube_prod"></cfif>
<cfset dsn3 = "workcube_prod_1">
</cfsilent>
<div id="wizardContainer" style="padding:20px;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;">
    
    <!-- Header -->
    <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:20px;padding-bottom:15px;border-bottom:2px solid #e5e7eb;">
        <h3 style="margin:0;font-size:18px;color:#1e293b;">
            <i class="fa fa-magic" style="color:#16a34a;margin-right:8px;"></i>Şablondan Görev Oluştur
        </h3>
        <button onclick="closeWizardModal()" style="background:none;border:none;font-size:24px;color:#64748b;cursor:pointer;">&times;</button>
    </div>
    
    <!-- Step 1: Template Selection -->
    <div id="step1" style="display:block;">
        <h4 style="margin:0 0 15px 0;font-size:14px;color:#475569;">1. Şablon Seçin</h4>
        <div id="templateList" style="display:grid;gap:10px;">
            <div style="text-align:center;padding:30px;color:#64748b;">
                <i class="fa fa-spinner fa-spin"></i> Şablonlar yükleniyor...
            </div>
        </div>
        <div style="margin-top:20px;text-align:right;">
            <button onclick="closeWizardModal()" style="padding:10px 20px;background:#f1f5f9;border:1px solid #d1d5db;border-radius:6px;cursor:pointer;margin-right:10px;">İptal</button>
            <button id="btnNext" onclick="loadPreview()" disabled style="padding:10px 20px;background:#2563eb;color:#fff;border:none;border-radius:6px;cursor:pointer;">
                Önizle <i class="fa fa-arrow-right"></i>
            </button>
        </div>
    </div>
    
    <!-- Step 2: Preview -->
    <div id="step2" style="display:none;">
        <h4 style="margin:0 0 15px 0;font-size:14px;color:#475569;">2. Görevleri Önizleyin ve Onaylayın</h4>
        
        <div id="previewSummary" style="background:#f0fdf4;padding:12px 16px;border-radius:6px;margin-bottom:15px;display:none;">
            <span style="margin-right:20px;">Toplam: <strong id="sumTotal">0</strong></span>
            <span style="margin-right:20px;color:#16a34a;">Oluşturulacak: <strong id="sumCreate">0</strong></span>
            <span style="color:#f59e0b;">Mevcut: <strong id="sumExist">0</strong></span>
        </div>
        
        <div id="previewTable" style="max-height:350px;overflow:auto;border:1px solid #e5e7eb;border-radius:6px;">
            <div style="text-align:center;padding:30px;color:#64748b;">
                <i class="fa fa-spinner fa-spin"></i> Yükleniyor...
            </div>
        </div>
        
        <div style="margin-top:20px;display:flex;justify-content:space-between;">
            <button onclick="showStep(1)" style="padding:10px 20px;background:#f1f5f9;border:1px solid #d1d5db;border-radius:6px;cursor:pointer;">
                <i class="fa fa-arrow-left"></i> Geri
            </button>
            <button id="btnCreate" onclick="createTasks()" style="padding:10px 24px;background:#16a34a;color:#fff;border:none;border-radius:6px;cursor:pointer;font-weight:600;">
                <i class="fa fa-check"></i> Görevleri Oluştur
            </button>
        </div>
    </div>
    
    <!-- Step 3: Result -->
    <div id="step3" style="display:none;">
        <div id="resultContent" style="text-align:center;padding:40px;">
        </div>
        <div style="text-align:center;margin-top:20px;">
            <button onclick="closeWizardModal()" style="padding:10px 30px;background:#2563eb;color:#fff;border:none;border-radius:6px;cursor:pointer;">Tamam</button>
        </div>
    </div>
</div>

<script>
// Global scope - no IIFE
window.WIZ_CONFIG = {
    refType: '<cfoutput>#url.ref_type#</cfoutput>',
    refId: <cfoutput>#val(url.ref_id)#</cfoutput>,
    companyId: <cfoutput>#val(url.company_id)#</cfoutput>,
    ajaxUrl: '/V16/sales/query/ajax_ops_task.cfm'
};

window.WIZ_selectedTemplateId = null;
window.WIZ_previewItems = [];

(function(){
    const CONFIG = WIZ_CONFIG;
    
    let selectedTemplateId = null;
    let previewItems = [];
    
    // Close modal
    window.closeWizardModal = function(){
        const modal = document.getElementById('ops_task_wizard_modal');
        if(modal) modal.remove();
        if(typeof OpsTask !== 'undefined') OpsTask.loadList();
    };
    
    // Show step
    window.showStep = function(n){
        document.getElementById('step1').style.display = n===1 ? 'block' : 'none';
        document.getElementById('step2').style.display = n===2 ? 'block' : 'none';
        document.getElementById('step3').style.display = n===3 ? 'block' : 'none';
    };
    
    // Hardcoded templates (bypass AJAX)
    const TEMPLATES = [{
        template_id: -1,
        template_name: 'Standart Sipariş Görevleri',
        description: 'Varsayılan görev şablonu',
        item_count: 6,
        is_default: true
    }];
    
    const TEMPLATE_ITEMS = [
        {task_code:'ORDER_APPROVAL', task_head:'SİPARİŞ ONAYI', days_offset:0, priority_id:3, is_mandatory:1},
        {task_code:'PAYMENT_CHECK', task_head:'ÖDEME KONTROLÜ', days_offset:1, priority_id:3, is_mandatory:1},
        {task_code:'DESIGN', task_head:'TASARIM', days_offset:5, priority_id:2, is_mandatory:0},
        {task_code:'PRODUCTION', task_head:'ÜRETİM', days_offset:14, priority_id:2, is_mandatory:1},
        {task_code:'QUALITY', task_head:'KALİTE KONTROL', days_offset:21, priority_id:2, is_mandatory:0},
        {task_code:'SHIPMENT', task_head:'SEVKİYAT', days_offset:30, priority_id:2, is_mandatory:1}
    ];
    
    // Load templates
    function loadTemplates(){
        const container = document.getElementById('templateList');
        container.innerHTML = TEMPLATES.map(t => `
            <div class="tpl-card" data-id="${t.template_id}" onclick="selectTemplate(${t.template_id}, this)" 
                 style="border:2px solid ${t.is_default ? '#2563eb' : '#e5e7eb'};border-radius:8px;padding:15px;cursor:pointer;display:flex;align-items:center;gap:12px;transition:all 0.15s;">
                <div style="width:20px;height:20px;border:2px solid ${t.is_default ? '#2563eb' : '#d1d5db'};border-radius:50%;display:flex;align-items:center;justify-content:center;">
                    ${t.is_default ? '<div style="width:12px;height:12px;background:#2563eb;border-radius:50%;"></div>' : ''}
                </div>
                <div style="flex:1;">
                    <div style="font-weight:600;color:#1e293b;">${escapeHtml(t.template_name)}</div>
                    <div style="font-size:12px;color:#64748b;">${escapeHtml(t.description || '')}</div>
                </div>
                <div style="background:#e0e7ff;color:#3730a3;padding:4px 12px;border-radius:12px;font-size:12px;font-weight:500;">
                    ${t.item_count} görev
                </div>
            </div>
        `).join('');
        
        selectedTemplateId = -1;
        document.getElementById('btnNext').disabled = false;
    }
    
    // Select template
    window.selectTemplate = function(id, el){
        selectedTemplateId = id;
        document.querySelectorAll('.tpl-card').forEach(c => {
            c.style.borderColor = '#e5e7eb';
            c.querySelector('div > div').innerHTML = '';
        });
        el.style.borderColor = '#2563eb';
        el.querySelector('div > div').innerHTML = '<div style="width:12px;height:12px;background:#2563eb;border-radius:50%;"></div>';
        document.getElementById('btnNext').disabled = false;
    };
    
    // Load preview (hardcoded for template_id = -1)
    window.loadPreview = function(){
        if(!selectedTemplateId) return;
        
        showStep(2);
        
        // Use hardcoded items
        const baseDate = new Date();
        previewItems = TEMPLATE_ITEMS.map((item, idx) => {
            const deadline = new Date(baseDate);
            deadline.setDate(deadline.getDate() + item.days_offset);
            return {
                task_code: item.task_code,
                task_head: item.task_head,
                task_detail: '',
                deadline: deadline.toISOString().split('T')[0],
                priority_id: item.priority_id,
                is_mandatory: item.is_mandatory,
                exists: false,
                selected: true
            };
        });
        
        renderPreview({
            items: previewItems,
            summary: {total: previewItems.length, will_create: previewItems.length, existing: 0}
        });
    };
    
    // Render preview
    function renderPreview(data){
        const items = data.items;
        const summary = data.summary;
        
        document.getElementById('sumTotal').textContent = summary.total;
        document.getElementById('sumCreate').textContent = summary.will_create;
        document.getElementById('sumExist').textContent = summary.existing;
        document.getElementById('previewSummary').style.display = 'block';
        
        let html = '<table style="width:100%;border-collapse:collapse;font-size:13px;">';
        html += '<thead style="background:#f8fafc;position:sticky;top:0;"><tr>';
        html += '<th style="padding:10px;text-align:left;border-bottom:1px solid #e5e7eb;width:30px;"><input type="checkbox" id="checkAll" onchange="toggleAll(this)" checked></th>';
        html += '<th style="padding:10px;text-align:left;border-bottom:1px solid #e5e7eb;">Görev</th>';
        html += '<th style="padding:10px;text-align:center;border-bottom:1px solid #e5e7eb;width:100px;">Termin</th>';
        html += '<th style="padding:10px;text-align:center;border-bottom:1px solid #e5e7eb;width:80px;">Durum</th>';
        html += '</tr></thead><tbody>';
        
        items.forEach((item, idx) => {
            const isExist = item.exists;
            const rowBg = isExist ? '#fef3c7' : '#fff';
            html += `<tr style="background:${rowBg};">`;
            html += `<td style="padding:10px;border-bottom:1px solid #e5e7eb;"><input type="checkbox" class="task-check" data-idx="${idx}" ${item.selected ? 'checked' : ''} ${isExist ? 'disabled' : ''}></td>`;
            html += `<td style="padding:10px;border-bottom:1px solid #e5e7eb;"><strong>${escapeHtml(item.task_head)}</strong></td>`;
            html += `<td style="padding:10px;border-bottom:1px solid #e5e7eb;text-align:center;">${item.deadline || '-'}</td>`;
            html += `<td style="padding:10px;border-bottom:1px solid #e5e7eb;text-align:center;">`;
            if(isExist){
                html += '<span style="background:#fbbf24;color:#78350f;padding:2px 8px;border-radius:4px;font-size:11px;">Mevcut</span>';
            } else {
                html += '<span style="background:#86efac;color:#166534;padding:2px 8px;border-radius:4px;font-size:11px;">Yeni</span>';
            }
            html += '</td></tr>';
        });
        
        html += '</tbody></table>';
        document.getElementById('previewTable').innerHTML = html;
    }
    
    // Toggle all
    window.toggleAll = function(el){
        document.querySelectorAll('.task-check:not(:disabled)').forEach(cb => cb.checked = el.checked);
    };
    
    // Create tasks (direct save - bypass batch)
    window.createTasks = async function(){
        const tasksToCreate = [];
        document.querySelectorAll('.task-check:checked').forEach(cb => {
            const idx = parseInt(cb.dataset.idx);
            if(previewItems[idx] && !previewItems[idx].exists){
                tasksToCreate.push(previewItems[idx]);
            }
        });
        
        if(tasksToCreate.length === 0){
            alert('Oluşturulacak görev seçilmedi');
            return;
        }
        
        document.getElementById('btnCreate').disabled = true;
        document.getElementById('btnCreate').innerHTML = '<i class="fa fa-spinner fa-spin"></i> Oluşturuluyor...';
        
        let created = 0, errors = 0;
        
        for(const task of tasksToCreate){
            try {
                const formData = new FormData();
                formData.append('action', 'save');
                formData.append('task_head', task.task_head);
                formData.append('task_detail', task.task_detail || '');
                formData.append('ref_type', CONFIG.refType);
                formData.append('ref_id', CONFIG.refId);
                formData.append('deadline', task.deadline);
                formData.append('priority_id', task.priority_id);
                formData.append('company_id', CONFIG.companyId);
                
                const resp = await fetch(CONFIG.ajaxUrl, {method:'POST', body:formData});
                const json = await resp.json();
                if(json.success) created++; else errors++;
            } catch(e){
                errors++;
            }
        }
        
        showStep(3);
        document.getElementById('resultContent').innerHTML = `
            <div style="font-size:48px;color:#16a34a;margin-bottom:20px;">✓</div>
            <h3 style="margin:0 0 20px 0;color:#1e293b;">İşlem Tamamlandı</h3>
            <div style="display:inline-flex;gap:30px;background:#f8fafc;padding:20px 40px;border-radius:8px;">
                <div><div style="font-size:24px;font-weight:700;color:#16a34a;">${created}</div><div style="font-size:12px;color:#64748b;">Oluşturuldu</div></div>
                <div><div style="font-size:24px;font-weight:700;color:#ef4444;">${errors}</div><div style="font-size:12px;color:#64748b;">Hata</div></div>
            </div>
        `;
    };
    
    function escapeHtml(str){
        if(!str) return '';
        const div = document.createElement('div');
        div.textContent = str;
        return div.innerHTML;
    }
    
    // Init
    loadTemplates();
})();
</script>
