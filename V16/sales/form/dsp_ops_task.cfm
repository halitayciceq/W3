<cfsilent>
<!---
    OPS_TASK - Görev Tanımlama Modalı
    Tarih: 2026-02-05
--->
<cfparam name="url.task_id" default="0">
<cfparam name="url.ref_type" default="ORDER">
<cfparam name="url.ref_id" default="0">
<cfparam name="url.company_id" default="#session.ep.company_id#">

<cfif NOT isDefined("dsn")><cfset dsn = "workcube_prod"></cfif>

<!--- Öncelikler --->
<cfset priorities = [
    {id: 1, name: "Düşük"},
    {id: 2, name: "Normal"},
    {id: 3, name: "Yüksek"},
    {id: 4, name: "Acil"}
]>

<!--- Aşamalar --->
<cfset stages = [
    {id: 0, name: "Seçiniz..."},
    {id: 1, name: "Planlama"},
    {id: 2, name: "İş Atandı"},
    {id: 3, name: "Devam Ediyor"},
    {id: 4, name: "Onay Bekliyor"},
    {id: 5, name: "Tamamlandı"},
    {id: 6, name: "Onaylandı"},
    {id: 7, name: "İptal"}
]>

<!--- Görev Verisi (Edit Mode) --->
<cfset task = {}>
<cfif val(url.task_id) GT 0>
    <cfquery name="qTask" datasource="#dsn#">
        SELECT t.*, ISNULL(e.EMPLOYEE_NAME + ' ' + e.EMPLOYEE_SURNAME, '') AS ASSIGNED_NAME
        FROM OPS_TASK t 
        LEFT JOIN EMPLOYEES e ON e.EMPLOYEE_ID = t.ASSIGNED_EMP_ID
        WHERE t.TASK_ID = <cfqueryparam value="#url.task_id#" cfsqltype="cf_sql_integer">
    </cfquery>
    <cfif qTask.recordCount>
        <cfset task = {
            task_id: qTask.TASK_ID,
            task_head: qTask.TASK_HEAD,
            task_detail: qTask.TASK_DETAIL,
            assigned_emp_id: qTask.ASSIGNED_EMP_ID,
            assigned_name: qTask.ASSIGNED_NAME,
            priority_id: qTask.PRIORITY_ID,
            status_id: qTask.STATUS_ID,
            deadline: isDate(qTask.DEADLINE) ? dateFormat(qTask.DEADLINE, "yyyy-mm-dd") : "",
            estimated_minutes: qTask.ESTIMATED_MINUTES,
            percent_complete: qTask.PERCENT_COMPLETE,
            has_matrix: qTask.HAS_MATRIX,
            matrix_template_id: qTask.MATRIX_TEMPLATE_ID
        }>
    </cfif>
</cfif>

<cfset isEdit = structKeyExists(task, "task_id") AND task.task_id GT 0>
<cfset estHour = isEdit ? int(task.estimated_minutes / 60) : 0>
<cfset estMin = isEdit ? task.estimated_minutes MOD 60 : 0>
</cfsilent>

<cfoutput>
<style>
.otm {
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Arial, sans-serif;
    font-size: 13px;
    color: ##333;
    background: ##fff;
    width: 100%;
    max-width: 100%;
    border-radius: 8px;
    box-shadow: 0 10px 40px rgba(0,0,0,0.2);
    overflow: hidden;
}

.otm-header {
    background: ##374151;
    color: ##fff;
    padding: 14px 20px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    position: relative;
}

.otm-title {
    margin: 0;
    font-size: 14px;
    font-weight: 600;
    letter-spacing: 0.3px;
}

.otm-close {
    position: absolute;
    right: 12px;
    top: 50%;
    transform: translateY(-50%);
    background: none;
    border: none;
    color: ##fff;
    font-size: 20px;
    cursor: pointer;
    opacity: 0.7;
    line-height: 1;
    padding: 4px 8px;
    border-radius: 4px;
    transition: all 0.2s;
}

.otm-close:hover {
    opacity: 1;
    background: rgba(255,255,255,0.1);
}

.otm-body {
    padding: 20px;
}

.otm-row {
    display: flex;
    gap: 12px;
    margin-bottom: 12px;
}

.otm-field {
    flex: 1;
    min-width: 0;
}

.otm-field.full {
    flex: 0 0 100%;
}

.otm-label {
    display: block;
    font-size: 12px;
    font-weight: 600;
    color: ##555;
    margin-bottom: 4px;
}

.otm-label .req {
    color: ##e53935;
}

.otm-input {
    width: 100%;
    min-width: 0;
    height: 34px;
    padding: 0 10px;
    font-size: 13px;
    color: ##333;
    background: ##fff;
    border: 1px solid ##d1d5db;
    border-radius: 4px;
    box-sizing: border-box;
}

.otm-input:focus {
    outline: none;
    border-color: ##4b5563;
    box-shadow: 0 0 0 2px rgba(75,85,99,0.1);
}

.otm-input::placeholder {
    color: ##999;
}

textarea.otm-input {
    height: 70px;
    padding: 10px 12px;
    resize: vertical;
    line-height: 1.5;
}

select.otm-input {
    cursor: pointer;
}

.otm-time-wrap {
    display: flex;
    gap: 6px;
}

.otm-time-item {
    flex: 1;
    position: relative;
}

.otm-time-item input {
    text-align: center;
    padding-right: 24px;
}

.otm-time-item span {
    position: absolute;
    right: 8px;
    top: 50%;
    transform: translateY(-50%);
    font-size: 11px;
    color: ##888;
    font-weight: 500;
}

.otm-pct-wrap {
    display: flex;
    align-items: center;
    gap: 0;
}

.otm-pct-input {
    width: 60px;
    text-align: center;
    border-radius: 3px 0 0 3px !important;
    border-right: none !important;
}

.otm-pct-bar {
    flex: 1;
    height: 34px;
    background: ##e5e7eb;
    border-radius: 0 3px 3px 0;
    overflow: hidden;
    border: 1px solid ##d1d5db;
    border-left: none;
}

.otm-pct-fill {
    height: 100%;
    background: ##374151;
    transition: width 0.3s;
}

.otm-autocomplete {
    position: relative;
}

.otm-ac-list {
    position: absolute;
    top: 100%;
    left: 0;
    right: 0;
    background: ##fff;
    border: 1px solid ##ccc;
    border-top: none;
    border-radius: 0 0 3px 3px;
    max-height: 140px;
    overflow-y: auto;
    z-index: 100;
    display: none;
    box-shadow: 0 4px 8px rgba(0,0,0,0.1);
}

.otm-ac-list.show {
    display: block;
}

.otm-ac-item {
    padding: 7px 10px;
    cursor: pointer;
    border-bottom: 1px solid ##f0f0f0;
}

.otm-ac-item:last-child {
    border-bottom: none;
}

.otm-ac-item:hover {
    background: ##f5f5f5;
}

.otm-check {
    display: flex;
    align-items: center;
    gap: 8px;
    margin-top: 4px;
}

.otm-check input {
    width: 16px;
    height: 16px;
    cursor: pointer;
    accent-color: ##1a7a8a;
}

.otm-check label {
    font-size: 13px;
    cursor: pointer;
    color: ##444;
}

.otm-footer {
    padding: 12px 16px;
    background: ##f5f5f5;
    border-top: 1px solid ##e0e0e0;
    display: flex;
    justify-content: flex-end;
    gap: 8px;
}

.otm-btn {
    height: 34px;
    padding: 0 16px;
    font-size: 13px;
    font-weight: 500;
    border-radius: 3px;
    cursor: pointer;
    display: inline-flex;
    align-items: center;
    gap: 5px;
}

.otm-btn-cancel {
    background: ##fff;
    color: ##666;
    border: 1px solid ##ccc;
}

.otm-btn-cancel:hover {
    background: ##f5f5f5;
}

.otm-btn-save {
    background: ##374151;
    color: ##fff;
    border: none;
}

.otm-btn-save:hover {
    background: ##1f2937;
}

.otm-btn-save:disabled {
    opacity: 0.6;
    cursor: not-allowed;
}

.otm-spinner {
    width: 14px;
    height: 14px;
    border: 2px solid rgba(255,255,255,0.3);
    border-top-color: ##fff;
    border-radius: 50%;
    animation: otmSpin 0.7s linear infinite;
}

@keyframes otmSpin {
    to { transform: rotate(360deg); }
}
</style>

<div class="otm">
    <div class="otm-header">
        <div class="otm-title">#isEdit ? 'Görev Düzenle' : 'Yeni Görev'#</div>
        <button type="button" class="otm-close" onclick="closeOpsTaskModal()">&times;</button>
    </div>

    <form id="opsTaskForm">
        <input type="hidden" name="task_id" value="#isEdit ? task.task_id : ''#">
        <input type="hidden" name="ref_type" value="#url.ref_type#">
        <input type="hidden" name="ref_id" value="#url.ref_id#">
        <input type="hidden" name="company_id" value="#url.company_id#">

        <div class="otm-body">
            <div class="otm-row">
                <div class="otm-field full">
                    <label class="otm-label">Başlık <span class="req">*</span></label>
                    <input type="text" class="otm-input" name="task_head" required
                           value="#isEdit ? htmlEditFormat(task.task_head) : ''#"
                           placeholder="Görev başlığı...">
                </div>
            </div>

            <div class="otm-row">
                <div class="otm-field full">
                    <label class="otm-label">Açıklama</label>
                    <textarea class="otm-input" name="task_detail" placeholder="Açıklama...">#isEdit ? htmlEditFormat(task.task_detail) : ''#</textarea>
                </div>
            </div>

            <div class="otm-row">
                <div class="otm-field">
                    <label class="otm-label">Sorumlu</label>
                    <div class="otm-autocomplete">
                        <input type="hidden" id="otmEmpId" name="assigned_emp_id" value="#isEdit ? task.assigned_emp_id : ''#">
                        <input type="text" class="otm-input" id="otmEmpText" autocomplete="off"
                               value="#isEdit ? task.assigned_name : ''#" placeholder="İsim yazın...">
                        <div id="otmEmpList" class="otm-ac-list"></div>
                    </div>
                </div>
                <div class="otm-field">
                    <label class="otm-label">Öncelik</label>
                    <select class="otm-input" name="priority_id">
                        <cfloop array="#priorities#" index="p">
                            <option value="#p.id#" #isEdit AND task.priority_id EQ p.id ? 'selected' : (NOT isEdit AND p.id EQ 2 ? 'selected' : '')#>#p.name#</option>
                        </cfloop>
                    </select>
                </div>
            </div>

            <div class="otm-row">
                <div class="otm-field">
                    <label class="otm-label">Aşama</label>
                    <select class="otm-input" name="status_id">
                        <cfloop array="#stages#" index="s">
                            <option value="#s.id#" #isEdit AND task.status_id EQ s.id ? 'selected' : ''#>#s.name#</option>
                        </cfloop>
                    </select>
                </div>
                <div class="otm-field">
                    <label class="otm-label">Termin</label>
                    <input type="date" class="otm-input" name="deadline" value="#isEdit ? task.deadline : ''#">
                </div>
            </div>

            <div class="otm-row">
                <div class="otm-field">
                    <label class="otm-label">Öngörülen Süre</label>
                    <div class="otm-time-wrap">
                        <div class="otm-time-item">
                            <input type="number" class="otm-input" name="estimated_hour" value="#estHour#" min="0" placeholder="0">
                            <span>sa</span>
                        </div>
                        <div class="otm-time-item">
                            <input type="number" class="otm-input" name="estimated_minute" value="#estMin#" min="0" max="59" placeholder="0">
                            <span>dk</span>
                        </div>
                    </div>
                </div>
                <div class="otm-field">
                    <label class="otm-label">Tamamlanma %</label>
                    <div class="otm-pct-wrap">
                        <input type="number" class="otm-input otm-pct-input" id="otmPct" name="percent_complete" 
                               min="0" max="100" value="#isEdit ? task.percent_complete : 0#">
                        <div class="otm-pct-bar">
                            <div class="otm-pct-fill" id="otmPctBar" style="width:#isEdit ? task.percent_complete : 0#%"></div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="otm-row">
                <div class="otm-field full">
                    <div class="otm-check">
                        <input type="checkbox" id="otmHasMatrix" name="has_matrix" value="1" #isEdit AND task.has_matrix EQ 1 ? 'checked' : ''#>
                        <label for="otmHasMatrix">Matris Kullan</label>
                    </div>
                </div>
            </div>
        </div>

        <div class="otm-footer">
            <button type="button" class="otm-btn otm-btn-cancel" onclick="closeOpsTaskModal()">İptal</button>
            <button type="submit" class="otm-btn otm-btn-save" id="otmBtnSave">+ Kaydet</button>
        </div>
    </form>
</div>

<script>
(function(){
    window.closeOpsTaskModal = function(){
        var m = document.getElementById('ops_task_form_modal');
        if(m) m.remove();
    };

    var pctInput = document.getElementById('otmPct');
    var pctBar = document.getElementById('otmPctBar');
    pctInput.addEventListener('input', function(){
        var v = parseInt(this.value) || 0;
        if(v < 0) v = 0;
        if(v > 100) v = 100;
        pctBar.style.width = v + '%';
    });

    var empInput = document.getElementById('otmEmpText');
    var empHidden = document.getElementById('otmEmpId');
    var empList = document.getElementById('otmEmpList');
    var timer;

    empInput.addEventListener('input', function(){
        clearTimeout(timer);
        var q = this.value.trim();
        if(q.length < 3){
            empList.classList.remove('show');
            return;
        }
        timer = setTimeout(function(){
            fetch('/V16/sales/query/ajax_ops_task.cfm', {
                method: 'POST',
                headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                body: 'action=employee_search&q=' + encodeURIComponent(q)
            })
            .then(function(r){ return r.json(); })
            .then(function(d){
                if(d.success && d.data.length){
                    empList.innerHTML = d.data.map(function(e){
                        return '<div class="otm-ac-item" data-id="'+e.employee_id+'">'+e.name+'</div>';
                    }).join('');
                    empList.classList.add('show');
                    empList.querySelectorAll('.otm-ac-item').forEach(function(item){
                        item.addEventListener('click', function(){
                            empHidden.value = this.dataset.id;
                            empInput.value = this.textContent;
                            empList.classList.remove('show');
                        });
                    });
                } else {
                    empList.classList.remove('show');
                }
            });
        }, 300);
    });

    document.addEventListener('click', function(e){
        if(!empInput.contains(e.target) && !empList.contains(e.target)){
            empList.classList.remove('show');
        }
    });

    document.getElementById('opsTaskForm').addEventListener('submit', function(e){
        e.preventDefault();
        var btn = document.getElementById('otmBtnSave');
        var origText = btn.textContent;
        btn.disabled = true;
        btn.innerHTML = '<div class="otm-spinner"></div> Kaydediliyor...';

        var fd = new FormData(this);
        fd.append('action', 'save');
        var h = parseInt(this.querySelector('[name="estimated_hour"]').value) || 0;
        var m = parseInt(this.querySelector('[name="estimated_minute"]').value) || 0;
        fd.append('estimated_minutes', (h*60)+m);
        fd.set('has_matrix', document.getElementById('otmHasMatrix').checked ? 1 : 0);

        fetch('/V16/sales/query/ajax_ops_task.cfm', {
            method: 'POST',
            body: fd
        })
        .then(function(r){ return r.json(); })
        .then(function(d){
            if(d.success){
                if(typeof toastr !== 'undefined') toastr.success(d.message || 'Görev kaydedildi');
                closeOpsTaskModal();
                if(window.OpsTask && typeof window.OpsTask.loadList === 'function') window.OpsTask.loadList();
            } else {
                alert('Hata: ' + (d.message || 'Bilinmeyen hata'));
                btn.disabled = false;
                btn.textContent = origText;
            }
        })
        .catch(function(){
            alert('Bağlantı hatası!');
            btn.disabled = false;
            btn.textContent = origText;
        });
    });
})();
</script>
</cfoutput>
