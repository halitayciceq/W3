<cfsilent>
<!--- ============================================
    SIPARIŞ OPERASYON GÖREVLERİ - GÖREV MODAL FORMU
    Tarih: 2026-01-22
    Konum: /V16/order/form/dsp_ops_task.cfm
    
    Bu dosya AJAX ile modal body içine yüklenir.
    Parametreler JS tarafından data attribute olarak taşınır.
============================================ --->
</cfsilent>

<form id="form_ops_task" class="needs-validation" novalidate>
    <input type="hidden" id="ops_task_id" name="task_id" value="">
    <input type="hidden" id="ops_ref_type" name="ref_type" value="">
    <input type="hidden" id="ops_ref_id" name="ref_id" value="">
    
    <div class="row">
        <!--- Konu (Zorunlu) --->
        <div class="col-12 mb-3">
            <label for="ops_task_head" class="form-label">Konu <span class="text-danger">*</span></label>
            <input type="text" class="form-control" id="ops_task_head" name="task_head" required maxlength="200">
            <div class="invalid-feedback">Konu zorunludur.</div>
        </div>
        
        <!--- Açıklama --->
        <div class="col-12 mb-3">
            <label for="ops_task_detail" class="form-label">Açıklama</label>
            <textarea class="form-control" id="ops_task_detail" name="task_detail" rows="3" maxlength="4000"></textarea>
        </div>
        
        <!--- Sorumlu (Zorunlu) --->
        <div class="col-md-6 mb-3">
            <label for="ops_assigned_emp_id" class="form-label">Sorumlu <span class="text-danger">*</span></label>
            <select class="form-control" id="ops_assigned_emp_id" name="assigned_emp_id" required>
                <option value="">Seçiniz...</option>
                <cfoutput query="qEmployees">
                    <option value="#EMPLOYEE_ID#">#EMPLOYEE_NAME# #EMPLOYEE_SURNAME#</option>
                </cfoutput>
            </select>
            <div class="invalid-feedback">Sorumlu seçiniz.</div>
        </div>
        
        <!--- Öncelik --->
        <div class="col-md-6 mb-3">
            <label for="ops_priority_id" class="form-label">Öncelik</label>
            <select class="form-control" id="ops_priority_id" name="priority_id">
                <option value="">Normal</option>
                <cfoutput query="qPriorities">
                    <option value="#PRIORITY_ID#">#PRIORITY_HEAD#</option>
                </cfoutput>
            </select>
        </div>
        
        <!--- Planlanan Başlangıç --->
        <div class="col-md-6 mb-3">
            <label for="ops_planned_start" class="form-label">Planlanan Başlangıç</label>
            <input type="date" class="form-control" id="ops_planned_start" name="planned_start">
        </div>
        
        <!--- Planlanan Bitiş --->
        <div class="col-md-6 mb-3">
            <label for="ops_planned_finish" class="form-label">Planlanan Bitiş</label>
            <input type="date" class="form-control" id="ops_planned_finish" name="planned_finish">
        </div>
        
        <!--- Termin (Zorunlu) --->
        <div class="col-md-6 mb-3">
            <label for="ops_deadline" class="form-label">Termin <span class="text-danger">*</span></label>
            <input type="date" class="form-control" id="ops_deadline" name="deadline" required>
            <div class="invalid-feedback">Termin tarihi zorunludur.</div>
        </div>
        
        <!--- Öngörülen Süre --->
        <div class="col-md-6 mb-3">
            <label class="form-label">Öngörülen Süre</label>
            <div class="d-flex align-items-center">
                <input type="number" class="form-control" id="ops_estimated_hour" name="estimated_hour" 
                       min="0" max="999" value="0" style="width: 80px;">
                <span class="mx-2">saat</span>
                <input type="number" class="form-control" id="ops_estimated_minute" name="estimated_minute" 
                       min="0" max="59" value="0" style="width: 80px;">
                <span class="mx-2">dk</span>
            </div>
        </div>
        
        <!--- Tamamlanma % --->
        <div class="col-md-6 mb-3">
            <label for="ops_percent_complete" class="form-label">
                Tamamlanma %
                <span id="ops_percent_readonly_hint" class="text-muted small" style="display: none;">
                    (Matris ile hesaplanıyor)
                </span>
            </label>
            <div class="input-group">
                <input type="number" class="form-control" id="ops_percent_complete" name="percent_complete" 
                       min="0" max="100" value="0" step="1">
                <div class="input-group-append">
                    <span class="input-group-text">%</span>
                </div>
            </div>
        </div>
        
        <!--- Matris Kullanımı --->
        <div class="col-md-6 mb-3">
            <label class="form-label">Matris</label>
            <div class="form-check mt-2">
                <input type="checkbox" class="form-check-input" id="ops_has_matrix" name="has_matrix" 
                       onchange="OpsTask.toggleMatrixTemplate()">
                <label class="form-check-label" for="ops_has_matrix">Matris kullan</label>
            </div>
            <select class="form-control mt-2" id="ops_matrix_template_id" name="matrix_template_id" 
                    style="display: none;">
                <option value="">Şablon Seçiniz...</option>
                <cfoutput query="qMatrixTemplates">
                    <option value="#TEMPLATE_ID#">#TEMPLATE_NAME#</option>
                </cfoutput>
            </select>
        </div>
    </div>
    
    <!--- İş Adımları Bölümü (Düzenleme modunda görünür) --->
    <div id="ops_task_steps_section" class="border-top pt-3 mt-3" style="display: none;">
        <h6 class="mb-3">
            <i class="fa fa-list-ol"></i> İş Adımları
            <button type="button" class="btn btn-sm btn-outline-primary float-right" onclick="OpsTask.addStep()">
                <i class="fa fa-plus"></i> Adım Ekle
            </button>
        </h6>
        <div id="ops_task_steps_container">
            <!--- Adımlar dinamik olarak eklenir --->
        </div>
    </div>
    
    <!--- Modal Footer --->
    <div class="modal-footer px-0 pb-0 mt-3">
        <button type="button" class="btn btn-secondary" data-dismiss="modal">İptal</button>
        <button type="submit" class="btn btn-primary">
            <i class="fa fa-save"></i> Kaydet
        </button>
    </div>
</form>

<!--- İş Adımı Template (Clone için) --->
<template id="ops_step_template">
    <div class="ops-step-row d-flex align-items-center mb-2 p-2 bg-light rounded">
        <span class="ops-step-handle mr-2" style="cursor: move;">
            <i class="fa fa-bars text-muted"></i>
        </span>
        <input type="text" class="form-control form-control-sm flex-grow-1" 
               placeholder="Adım açıklaması..." maxlength="500">
        <div class="d-flex align-items-center mx-2">
            <input type="number" class="form-control form-control-sm" min="0" max="99" value="0" 
                   style="width: 50px;" title="Saat">
            <span class="mx-1">:</span>
            <input type="number" class="form-control form-control-sm" min="0" max="59" value="0" 
                   style="width: 50px;" title="Dakika">
        </div>
        <div class="form-check mx-2">
            <input type="checkbox" class="form-check-input" title="Tamamlandı">
        </div>
        <button type="button" class="btn btn-sm btn-outline-danger" onclick="OpsTask.removeStep(this)">
            <i class="fa fa-times"></i>
        </button>
    </div>
</template>

<style>
.ops-step-row {
    transition: background-color 0.2s;
}
.ops-step-row:hover {
    background-color: #e9ecef !important;
}
.ops-step-row.ui-sortable-helper {
    background-color: #fff;
    box-shadow: 0 2px 10px rgba(0,0,0,0.15);
}
</style>
