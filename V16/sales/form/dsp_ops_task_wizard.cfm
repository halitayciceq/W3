<cfsilent>
<!--- ═══════════════════════════════════════════════════════════════════════════════
    OPS_TASK WIZARD - GÖREV MATRİSİ SIHIRBAZI
    Tarih: 2026-02-05
    Versiyon: 1.0
    
    3 Tab:
    1. Tek Görev - Mevcut dsp_ops_task.cfm davranışı
    2. Şablondan Oluştur - Template seçimi ve görev listesi
    3. Önizleme - Seçilen görevlerin düzenlemesi ve onayı
═══════════════════════════════════════════════════════════════════════════════ --->

<cfparam name="ref_type" default="ORDER">
<cfparam name="ref_id" default="0">
<cfparam name="company_id" default="#session.ep.company_id#">
<cfparam name="order_number" default="">

<cfif NOT isDefined("dsn")>
    <cfset dsn = "workcube_prod">
</cfif>

<cfset currentEmployeeId = isDefined("session.ep.employee_id") ? session.ep.employee_id : 0>
<cfset currentEmployeeName = isDefined("session.ep.employee_name") ? session.ep.employee_name : "">

</cfsilent>
<style>
.pkg-wizard-overlay {
    display: block;
}
.pkg-wizard {
    background: #fff;
    border-radius: 8px;
    width: 90%;
    max-width: 900px;
    max-height: 85vh;
    display: flex;
    flex-direction: column;
    box-shadow: 0 8px 32px rgba(0,0,0,0.2);
    transform: translateY(-20px);
    transition: transform 0.2s;
}
.pkg-wizard-overlay.active .pkg-wizard {
    transform: translateY(0);
}
.pkg-wizard-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 16px 20px;
    border-bottom: 1px solid #e5e7eb;
    background: #f8fafc;
    border-radius: 8px 8px 0 0;
}
.pkg-wizard-header h3 {
    margin: 0;
    font-size: 16px;
    font-weight: 600;
    color: #1e293b;
}
.pkg-wizard-close {
    background: none;
    border: none;
    font-size: 20px;
    color: #64748b;
    cursor: pointer;
    padding: 4px 8px;
    border-radius: 4px;
}
.pkg-wizard-close:hover {
    background: #e2e8f0;
    color: #1e293b;
}
.pkg-wizard-tabs {
    display: flex;
    border-bottom: 1px solid #e5e7eb;
    background: #f8fafc;
}
.pkg-wizard-tab {
    flex: 1;
    padding: 12px 16px;
    background: none;
    border: none;
    border-bottom: 2px solid transparent;
    font-size: 13px;
    font-weight: 500;
    color: #64748b;
    cursor: pointer;
    transition: all 0.15s;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
}
.pkg-wizard-tab:hover {
    background: #e2e8f0;
    color: #1e293b;
}
.pkg-wizard-tab.active {
    color: #2563eb;
    border-bottom-color: #2563eb;
    background: #fff;
}
.pkg-wizard-tab-icon {
    font-size: 16px;
}
.pkg-wizard-body {
    flex: 1;
    overflow-y: auto;
    padding: 20px;
}
.pkg-wizard-panel {
    display: none;
}
.pkg-wizard-panel.active {
    display: block;
}
.pkg-wizard-footer {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 16px 20px;
    border-top: 1px solid #e5e7eb;
    background: #f8fafc;
    border-radius: 0 0 8px 8px;
}
.pkg-wizard-btn {
    padding: 8px 16px;
    border-radius: 6px;
    font-size: 13px;
    font-weight: 500;
    cursor: pointer;
    border: 1px solid #d1d5db;
    background: #fff;
    color: #374151;
    transition: all 0.15s;
}
.pkg-wizard-btn:hover {
    background: #f3f4f6;
}
.pkg-wizard-btn-primary {
    background: #2563eb;
    border-color: #2563eb;
    color: #fff;
}
.pkg-wizard-btn-primary:hover {
    background: #1d4ed8;
}
.pkg-wizard-btn-success {
    background: #16a34a;
    border-color: #16a34a;
    color: #fff;
}
.pkg-wizard-btn-success:hover {
    background: #15803d;
}
.pkg-wizard-btn:disabled {
    opacity: 0.5;
    cursor: not-allowed;
}

/* Template Selection */
.pkg-template-list {
    display: grid;
    gap: 12px;
}
.pkg-template-card {
    border: 2px solid #e5e7eb;
    border-radius: 8px;
    padding: 16px;
    cursor: pointer;
    transition: all 0.15s;
    display: flex;
    align-items: center;
    gap: 12px;
}
.pkg-template-card:hover {
    border-color: #93c5fd;
    background: #f0f9ff;
}
.pkg-template-card.selected {
    border-color: #2563eb;
    background: #eff6ff;
}
.pkg-template-radio {
    width: 18px;
    height: 18px;
    border: 2px solid #d1d5db;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
}
.pkg-template-card.selected .pkg-template-radio {
    border-color: #2563eb;
}
.pkg-template-card.selected .pkg-template-radio::after {
    content: '';
    width: 10px;
    height: 10px;
    background: #2563eb;
    border-radius: 50%;
}
.pkg-template-info {
    flex: 1;
}
.pkg-template-name {
    font-weight: 600;
    color: #1e293b;
    margin-bottom: 4px;
}
.pkg-template-desc {
    font-size: 12px;
    color: #64748b;
}
.pkg-template-count {
    background: #e0e7ff;
    color: #3730a3;
    padding: 4px 10px;
    border-radius: 12px;
    font-size: 12px;
    font-weight: 500;
}

/* Preview Table */
.pkg-preview-table {
    width: 100%;
    border-collapse: collapse;
    font-size: 13px;
}
.pkg-preview-table th {
    background: #f1f5f9;
    padding: 10px 12px;
    text-align: left;
    font-weight: 600;
    color: #475569;
    border-bottom: 1px solid #e2e8f0;
    position: sticky;
    top: 0;
}
.pkg-preview-table td {
    padding: 10px 12px;
    border-bottom: 1px solid #e2e8f0;
    vertical-align: middle;
}
.pkg-preview-table tr:hover {
    background: #f8fafc;
}
.pkg-preview-table tr.exists {
    background: #fef3c7;
}
.pkg-preview-table tr.exists:hover {
    background: #fde68a;
}
.pkg-preview-check {
    width: 18px;
    height: 18px;
    cursor: pointer;
}
.pkg-preview-input {
    width: 100%;
    padding: 6px 8px;
    border: 1px solid #d1d5db;
    border-radius: 4px;
    font-size: 12px;
}
.pkg-preview-input:focus {
    outline: none;
    border-color: #2563eb;
    box-shadow: 0 0 0 2px rgba(37,99,235,0.1);
}
.pkg-preview-select {
    padding: 6px 8px;
    border: 1px solid #d1d5db;
    border-radius: 4px;
    font-size: 12px;
    background: #fff;
}
.pkg-exists-badge {
    display: inline-block;
    padding: 2px 8px;
    background: #fbbf24;
    color: #78350f;
    border-radius: 4px;
    font-size: 11px;
    font-weight: 500;
}
.pkg-matrix-badge {
    display: inline-block;
    padding: 2px 8px;
    background: #a78bfa;
    color: #fff;
    border-radius: 4px;
    font-size: 11px;
}

/* Summary */
.pkg-summary {
    display: flex;
    gap: 16px;
    padding: 12px 16px;
    background: #f0fdf4;
    border-radius: 6px;
    margin-bottom: 16px;
}
.pkg-summary-item {
    display: flex;
    align-items: center;
    gap: 6px;
    font-size: 13px;
}
.pkg-summary-count {
    font-weight: 700;
    color: #16a34a;
}

/* Loading */
.pkg-loading {
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 40px;
    color: #64748b;
}
.pkg-loading::before {
    content: '';
    width: 24px;
    height: 24px;
    border: 3px solid #e2e8f0;
    border-top-color: #2563eb;
    border-radius: 50%;
    animation: spin 0.8s linear infinite;
    margin-right: 12px;
}
@keyframes spin {
    to { transform: rotate(360deg); }
}

/* Strategy Options */
.pkg-strategy {
    display: flex;
    gap: 12px;
    margin-bottom: 16px;
}
.pkg-strategy-option {
    flex: 1;
    padding: 12px;
    border: 2px solid #e5e7eb;
    border-radius: 6px;
    cursor: pointer;
    transition: all 0.15s;
}
.pkg-strategy-option:hover {
    border-color: #93c5fd;
}
.pkg-strategy-option.selected {
    border-color: #2563eb;
    background: #eff6ff;
}
.pkg-strategy-option input {
    margin-right: 8px;
}
.pkg-strategy-label {
    font-weight: 500;
    color: #1e293b;
}
.pkg-strategy-desc {
    font-size: 12px;
    color: #64748b;
    margin-top: 4px;
    padding-left: 24px;
}
</style>

<div id="pkgWizardOverlay" class="pkg-wizard-overlay" role="dialog" aria-modal="true" aria-labelledby="pkgWizardTitle">
    <div class="pkg-wizard">
        <div class="pkg-wizard-header">
            <h3 id="pkgWizardTitle">
                <cfoutput>Görev Oluştur - #encodeForHTML(order_number)#</cfoutput>
            </h3>
            <button type="button" class="pkg-wizard-close" onclick="pkgWizard.close()" aria-label="Kapat">&times;</button>
        </div>
        
        <div class="pkg-wizard-tabs" role="tablist">
            <button type="button" class="pkg-wizard-tab active" data-tab="single" role="tab" aria-selected="true">
                <span class="pkg-wizard-tab-icon">📝</span>
                Tek Görev
            </button>
            <button type="button" class="pkg-wizard-tab" data-tab="template" role="tab" aria-selected="false">
                <span class="pkg-wizard-tab-icon">📋</span>
                Şablondan Oluştur
            </button>
            <button type="button" class="pkg-wizard-tab" data-tab="preview" role="tab" aria-selected="false">
                <span class="pkg-wizard-tab-icon">👁️</span>
                Önizleme
            </button>
        </div>
        
        <div class="pkg-wizard-body">
            <!-- TAB 1: Tek Görev -->
            <div id="pkgPanelSingle" class="pkg-wizard-panel active" role="tabpanel">
                <div id="pkgSingleFormContainer">
                    <div class="pkg-loading">Yükleniyor...</div>
                </div>
            </div>
            
            <!-- TAB 2: Şablondan Oluştur -->
            <div id="pkgPanelTemplate" class="pkg-wizard-panel" role="tabpanel">
                <div id="pkgTemplateList" class="pkg-template-list">
                    <div class="pkg-loading">Şablonlar yükleniyor...</div>
                </div>
            </div>
            
            <!-- TAB 3: Önizleme -->
            <div id="pkgPanelPreview" class="pkg-wizard-panel" role="tabpanel">
                <div id="pkgPreviewContent">
                    <p style="color:#64748b;text-align:center;padding:40px;">
                        Önce bir şablon seçin
                    </p>
                </div>
            </div>
        </div>
        
        <div class="pkg-wizard-footer">
            <div>
                <button type="button" class="pkg-wizard-btn" onclick="pkgWizard.close()">İptal</button>
            </div>
            <div id="pkgWizardActions">
                <!-- Tab 1 -->
                <button type="button" id="btnSaveSingle" class="pkg-wizard-btn pkg-wizard-btn-primary" onclick="pkgWizard.saveSingle()">
                    Kaydet
                </button>
                <!-- Tab 2 -->
                <button type="button" id="btnLoadPreview" class="pkg-wizard-btn pkg-wizard-btn-primary" onclick="pkgWizard.loadPreview()" style="display:none;">
                    Önizle →
                </button>
                <!-- Tab 3 -->
                <button type="button" id="btnCreateBatch" class="pkg-wizard-btn pkg-wizard-btn-success" onclick="pkgWizard.createBatch()" style="display:none;">
                    Görevleri Oluştur
                </button>
            </div>
        </div>
    </div>
</div>

<script>
const pkgWizard = {
    refType: '<cfoutput>#encodeForJavaScript(ref_type)#</cfoutput>',
    refId: <cfoutput>#val(ref_id)#</cfoutput>,
    companyId: <cfoutput>#val(company_id)#</cfoutput>,
    selectedTemplateId: null,
    previewData: null,
    strategy: 'skip_existing',
    
    init() {
        this.bindTabs();
        this.loadTemplates();
        this.loadSingleForm();
    },
    
    bindTabs() {
        document.querySelectorAll('.pkg-wizard-tab').forEach(tab => {
            tab.addEventListener('click', () => this.switchTab(tab.dataset.tab));
        });
    },
    
    switchTab(tabName) {
        document.querySelectorAll('.pkg-wizard-tab').forEach(t => {
            t.classList.toggle('active', t.dataset.tab === tabName);
            t.setAttribute('aria-selected', t.dataset.tab === tabName);
        });
        document.querySelectorAll('.pkg-wizard-panel').forEach(p => {
            p.classList.remove('active');
        });
        document.getElementById('pkgPanel' + tabName.charAt(0).toUpperCase() + tabName.slice(1)).classList.add('active');
        
        document.getElementById('btnSaveSingle').style.display = tabName === 'single' ? '' : 'none';
        document.getElementById('btnLoadPreview').style.display = tabName === 'template' ? '' : 'none';
        document.getElementById('btnCreateBatch').style.display = tabName === 'preview' ? '' : 'none';
    },
    
    onClose: null,
    
    close() {
        if (typeof this.onClose === 'function') {
            this.onClose();
        } else {
            const modal = document.getElementById('ops_task_wizard_modal');
            if (modal) modal.remove();
        }
        document.body.style.overflow = '';
    },
    
    async loadSingleForm() {
        const container = document.getElementById('pkgSingleFormContainer');
        try {
            const resp = await fetch(`/V16/sales/form/dsp_ops_task.cfm?ref_type=${this.refType}&ref_id=${this.refId}&company_id=${this.companyId}`);
            container.innerHTML = await resp.text();
        } catch (e) {
            container.innerHTML = '<p style="color:red;">Form yüklenemedi</p>';
        }
    },
    
    async loadTemplates() {
        const container = document.getElementById('pkgTemplateList');
        try {
            const resp = await fetch('/V16/sales/query/ajax_ops_task.cfm', {
                method: 'POST',
                headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                body: `action=get_templates&company_id=${this.companyId}`
            });
            const json = await resp.json();
            
            if (json.success && json.data.length > 0) {
                container.innerHTML = json.data.map(t => `
                    <div class="pkg-template-card ${t.is_default ? 'selected' : ''}" 
                         data-id="${t.template_id}" onclick="pkgWizard.selectTemplate(${t.template_id}, this)">
                        <div class="pkg-template-radio"></div>
                        <div class="pkg-template-info">
                            <div class="pkg-template-name">${this.escapeHtml(t.template_name)}</div>
                            <div class="pkg-template-desc">${this.escapeHtml(t.description || '')}</div>
                        </div>
                        <div class="pkg-template-count">${t.item_count} görev</div>
                    </div>
                `).join('');
                
                const defaultTpl = json.data.find(t => t.is_default);
                if (defaultTpl) this.selectedTemplateId = defaultTpl.template_id;
            } else {
                container.innerHTML = '<p style="color:#64748b;text-align:center;">Şablon bulunamadı</p>';
            }
        } catch (e) {
            container.innerHTML = '<p style="color:red;">Şablonlar yüklenemedi</p>';
        }
    },
    
    selectTemplate(id, el) {
        this.selectedTemplateId = id;
        document.querySelectorAll('.pkg-template-card').forEach(c => c.classList.remove('selected'));
        el.classList.add('selected');
    },
    
    async loadPreview() {
        if (!this.selectedTemplateId) {
            alert('Lütfen bir şablon seçin');
            return;
        }
        
        this.switchTab('preview');
        const container = document.getElementById('pkgPreviewContent');
        container.innerHTML = '<div class="pkg-loading">Önizleme hazırlanıyor...</div>';
        
        try {
            const resp = await fetch('/V16/sales/query/ajax_ops_task.cfm', {
                method: 'POST',
                headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                body: `action=batch_preview&ref_type=${this.refType}&ref_id=${this.refId}&template_id=${this.selectedTemplateId}&company_id=${this.companyId}`
            });
            const json = await resp.json();
            
            if (json.success) {
                this.previewData = json.data;
                this.renderPreview();
            } else {
                container.innerHTML = `<p style="color:red;">${this.escapeHtml(json.message)}</p>`;
            }
        } catch (e) {
            container.innerHTML = '<p style="color:red;">Önizleme yüklenemedi</p>';
        }
    },
    
    renderPreview() {
        const data = this.previewData;
        const container = document.getElementById('pkgPreviewContent');
        
        const existingCount = data.items.filter(i => i.exists).length;
        const newCount = data.items.length - existingCount;
        
        let html = `
            <div class="pkg-summary">
                <div class="pkg-summary-item">
                    <span>Toplam:</span>
                    <span class="pkg-summary-count">${data.items.length}</span>
                </div>
                <div class="pkg-summary-item">
                    <span>Yeni:</span>
                    <span class="pkg-summary-count" style="color:#16a34a;">${newCount}</span>
                </div>
                <div class="pkg-summary-item">
                    <span>Mevcut:</span>
                    <span class="pkg-summary-count" style="color:#d97706;">${existingCount}</span>
                </div>
            </div>
            
            ${existingCount > 0 ? `
            <div class="pkg-strategy">
                <label class="pkg-strategy-option ${this.strategy === 'skip_existing' ? 'selected' : ''}" onclick="pkgWizard.setStrategy('skip_existing', this)">
                    <input type="radio" name="strategy" value="skip_existing" ${this.strategy === 'skip_existing' ? 'checked' : ''}>
                    <span class="pkg-strategy-label">Mevcut olanları atla</span>
                    <div class="pkg-strategy-desc">Zaten var olan görevler değiştirilmez</div>
                </label>
                <label class="pkg-strategy-option ${this.strategy === 'update_existing' ? 'selected' : ''}" onclick="pkgWizard.setStrategy('update_existing', this)">
                    <input type="radio" name="strategy" value="update_existing" ${this.strategy === 'update_existing' ? 'checked' : ''}>
                    <span class="pkg-strategy-label">Mevcut olanları güncelle</span>
                    <div class="pkg-strategy-desc">Var olan görevler yeni değerlerle güncellenir</div>
                </label>
            </div>
            ` : ''}
            
            <table class="pkg-preview-table">
                <thead>
                    <tr>
                        <th style="width:40px;"><input type="checkbox" id="chkSelectAll" onchange="pkgWizard.toggleAll(this.checked)" checked></th>
                        <th>Görev</th>
                        <th style="width:150px;">Sorumlu</th>
                        <th style="width:100px;">Termin</th>
                        <th style="width:80px;">Öncelik</th>
                        <th style="width:70px;">Durum</th>
                    </tr>
                </thead>
                <tbody>
        `;
        
        data.items.forEach((item, idx) => {
            html += `
                <tr class="${item.exists ? 'exists' : ''}" data-idx="${idx}">
                    <td>
                        <input type="checkbox" class="pkg-preview-check" data-idx="${idx}" 
                               ${item.selected ? 'checked' : ''} ${item.is_mandatory ? 'disabled' : ''}>
                    </td>
                    <td>
                        <strong>${this.escapeHtml(item.task_head)}</strong>
                        ${item.has_production_matrix ? '<span class="pkg-matrix-badge">Matris</span>' : ''}
                    </td>
                    <td>
                        <input type="text" class="pkg-preview-input" data-field="assigned_emp_name" data-idx="${idx}"
                               value="${this.escapeHtml(item.assigned_emp_name || '')}" 
                               placeholder="Sorumlu seç...">
                        <input type="hidden" data-field="assigned_emp_id" data-idx="${idx}" 
                               value="${item.assigned_emp_id || ''}">
                    </td>
                    <td>
                        <input type="date" class="pkg-preview-input" data-field="deadline" data-idx="${idx}"
                               value="${item.deadline || ''}">
                    </td>
                    <td>
                        <select class="pkg-preview-select" data-field="priority_id" data-idx="${idx}">
                            <option value="1" ${item.priority_id == 1 ? 'selected' : ''}>Düşük</option>
                            <option value="2" ${item.priority_id == 2 ? 'selected' : ''}>Normal</option>
                            <option value="3" ${item.priority_id == 3 ? 'selected' : ''}>Yüksek</option>
                            <option value="4" ${item.priority_id == 4 ? 'selected' : ''}>Acil</option>
                        </select>
                    </td>
                    <td>
                        ${item.exists ? '<span class="pkg-exists-badge">Mevcut</span>' : '<span style="color:#16a34a;">Yeni</span>'}
                    </td>
                </tr>
            `;
        });
        
        html += `</tbody></table>`;
        container.innerHTML = html;
        
        this.bindPreviewInputs();
    },
    
    setStrategy(value, el) {
        this.strategy = value;
        document.querySelectorAll('.pkg-strategy-option').forEach(o => o.classList.remove('selected'));
        el.classList.add('selected');
    },
    
    toggleAll(checked) {
        document.querySelectorAll('.pkg-preview-check:not(:disabled)').forEach(cb => {
            cb.checked = checked;
        });
    },
    
    bindPreviewInputs() {
        document.querySelectorAll('[data-field]').forEach(input => {
            input.addEventListener('change', (e) => {
                const idx = parseInt(e.target.dataset.idx);
                const field = e.target.dataset.field;
                this.previewData.items[idx][field] = e.target.value;
            });
        });
    },
    
    async saveSingle() {
        const form = document.querySelector('#pkgSingleFormContainer form');
        if (!form) {
            alert('Form bulunamadı');
            return;
        }
        
        const formData = new FormData(form);
        formData.append('action', 'save');
        formData.append('ref_type', this.refType);
        formData.append('ref_id', this.refId);
        
        try {
            const resp = await fetch('/V16/sales/query/ajax_ops_task.cfm', {
                method: 'POST',
                body: formData
            });
            const json = await resp.json();
            
            if (json.success) {
                alert(json.message || 'Görev kaydedildi');
                this.close();
                if (typeof refreshTaskList === 'function') refreshTaskList();
            } else {
                alert(json.message || 'Hata oluştu');
            }
        } catch (e) {
            alert('Kayıt sırasında hata oluştu');
        }
    },
    
    async createBatch() {
        const selectedCodes = [];
        document.querySelectorAll('.pkg-preview-check:checked').forEach(cb => {
            const idx = parseInt(cb.dataset.idx);
            const item = this.previewData.items[idx];
            selectedCodes.push(item.task_code);
        });
        
        if (selectedCodes.length === 0) {
            alert('Lütfen en az bir görev seçin');
            return;
        }
        
        const btn = document.getElementById('btnCreateBatch');
        btn.disabled = true;
        btn.textContent = 'Oluşturuluyor...';
        
        try {
            const formData = new FormData();
            formData.append('action', 'batch_create');
            formData.append('ref_type', this.refType);
            formData.append('ref_id', this.refId);
            formData.append('template_id', this.selectedTemplateId);
            formData.append('company_id', this.companyId);
            formData.append('strategy', this.strategy);
            formData.append('selected_codes', selectedCodes.join(','));
            
            const resp = await fetch('/V16/sales/query/ajax_ops_task.cfm', {
                method: 'POST',
                body: formData
            });
            const json = await resp.json();
            
            if (json.success) {
                const s = json.data.summary;
                alert(`İşlem tamamlandı!\n\nOluşturulan: ${s.created}\nGüncellenen: ${s.updated}\nAtlanan: ${s.skipped}`);
                this.close();
                if (typeof refreshTaskList === 'function') refreshTaskList();
            } else {
                alert(json.message || 'Hata oluştu');
            }
        } catch (e) {
            alert('İşlem sırasında hata oluştu');
        } finally {
            btn.disabled = false;
            btn.textContent = 'Görevleri Oluştur';
        }
    },
    
    escapeHtml(str) {
        if (!str) return '';
        const div = document.createElement('div');
        div.textContent = str;
        return div.innerHTML;
    }
};

document.addEventListener('DOMContentLoaded', () => pkgWizard.init());
</script>
