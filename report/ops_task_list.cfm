<cfsilent>
<!--- ============================================
    SIPARIŞ OPERASYON GÖREVLERİ - GÖREV LİSTESİ
    Tarih: 2026-01-22
    Konum: /V16/order/display/ops_task_list.cfm
    
    Parametreler (window.OPS_TASK_CONFIG üzerinden):
    - ref_type: 'ORDER'
    - ref_id: ORDER_ID
    - company_id: session.company_id
============================================ --->
</cfsilent>

<div id="ops-task-container" class="ops-task-module">
    
    <!--- Toolbar --->
    <div class="ops-task-toolbar d-flex justify-content-between align-items-center mb-3 p-2 bg-light rounded">
        <div class="d-flex align-items-center gap-2">
            <!--- Durum Filtresi --->
            <select id="ops_task_filter_status" class="form-control form-control-sm" style="width: 140px;">
                <option value="">Tümü</option>
                <option value="open">Açık Görevler</option>
                <option value="2364">Tamamlanan</option>
            </select>
            
            <!--- Sorumlu Filtresi --->
            <select id="ops_task_filter_employee" class="form-control form-control-sm" style="width: 160px;">
                <option value="">Tüm Sorumlular</option>
            </select>
        </div>
        
        <div class="d-flex align-items-center gap-2">
            <!--- Yenile --->
            <button type="button" class="btn btn-sm btn-outline-secondary" onclick="OpsTask.loadList()" title="Yenile">
                <i class="fa fa-refresh"></i>
            </button>
            
            <!--- Yeni Görev --->
            <button type="button" class="btn btn-sm btn-primary" onclick="OpsTask.openModal(0)" title="Yeni Görev">
                <i class="fa fa-plus"></i> Yeni Görev
            </button>
        </div>
    </div>
    
    <!--- Grid --->
    <div class="table-responsive">
        <table id="ops_task_grid" class="table table-sm table-hover table-bordered">
            <thead class="thead-light">
                <tr>
                    <th style="width: 40px;" class="text-center">#</th>
                    <th style="width: 120px;">Sorumlu</th>
                    <th>Başlık</th>
                    <th style="width: 100px;" class="text-center">Aşama</th>
                    <th style="width: 90px;" class="text-center">Termin</th>
                    <th style="width: 80px;" class="text-right">Öngörülen</th>
                    <th style="width: 80px;" class="text-right">Harcanan</th>
                    <th style="width: 60px;" class="text-center">%</th>
                    <th style="width: 120px;" class="text-center">İşlemler</th>
                </tr>
            </thead>
            <tbody id="ops_task_tbody">
                <tr class="ops-task-loading">
                    <td colspan="9" class="text-center py-4">
                        <i class="fa fa-spinner fa-spin"></i> Yükleniyor...
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
    
    <!--- Boş Durum --->
    <div id="ops_task_empty" class="text-center py-5" style="display: none;">
        <i class="fa fa-tasks fa-3x text-muted mb-3"></i>
        <p class="text-muted">Bu siparişe ait görev bulunmuyor.</p>
        <button type="button" class="btn btn-primary" onclick="OpsTask.openModal(0)">
            <i class="fa fa-plus"></i> İlk Görevi Oluştur
        </button>
    </div>
    
</div>

<!--- Görev Modal --->
<div class="modal fade" id="modal_ops_task" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title" id="modal_ops_task_title">Yeni Görev</h5>
                <button type="button" class="close text-white" data-dismiss="modal">
                    <span>&times;</span>
                </button>
            </div>
            <div class="modal-body" id="modal_ops_task_body">
                <form id="form_ops_task" class="needs-validation" novalidate>
                    <input type="hidden" id="ops_task_id" name="task_id" value="">
                    <input type="hidden" id="ops_ref_type" name="ref_type" value="">
                    <input type="hidden" id="ops_ref_id" name="ref_id" value="">
                    
                    <div class="row">
                        <!--- Konu (Zorunlu) --->
                        <div class="col-12 mb-3">
                            <label for="ops_task_head" class="form-label">Konu <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" id="ops_task_head" name="task_head" required maxlength="200" placeholder="Görev konusunu giriniz...">
                            <div class="invalid-feedback">Konu zorunludur.</div>
                        </div>
                        
                        <!--- Açıklama --->
                        <div class="col-12 mb-3">
                            <label for="ops_task_detail" class="form-label">Açıklama</label>
                            <textarea class="form-control" id="ops_task_detail" name="task_detail" rows="3" maxlength="4000" placeholder="Detaylı açıklama..."></textarea>
                        </div>
                        
                        <!--- Sorumlu --->
                        <div class="col-md-6 mb-3">
                            <label for="ops_assigned_emp_id" class="form-label">Sorumlu</label>
                            <select class="form-control" id="ops_assigned_emp_id" name="assigned_emp_id">
                                <option value="">Seçiniz...</option>
                                <!--- Çalışanlar AJAX ile veya config'den yüklenebilir --->
                            </select>
                        </div>
                        
                        <!--- Öncelik --->
                        <div class="col-md-6 mb-3">
                            <label for="ops_priority_id" class="form-label">Öncelik</label>
                            <select class="form-control" id="ops_priority_id" name="priority_id">
                                <option value="">Normal</option>
                                <option value="1">Düşük</option>
                                <option value="2">Orta</option>
                                <option value="3">Yüksek</option>
                                <option value="4">Acil</option>
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
                        
                        <!--- Termin --->
                        <div class="col-md-6 mb-3">
                            <label for="ops_deadline" class="form-label">Termin</label>
                            <input type="date" class="form-control" id="ops_deadline" name="deadline">
                        </div>
                        
                        <!--- Öngörülen Süre --->
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Öngörülen Süre</label>
                            <div class="d-flex align-items-center">
                                <input type="number" class="form-control" id="ops_estimated_hour" name="estimated_hour" 
                                       min="0" max="999" value="0" style="width: 70px;">
                                <span class="mx-2">sa</span>
                                <input type="number" class="form-control" id="ops_estimated_minute" name="estimated_minute" 
                                       min="0" max="59" value="0" style="width: 70px;">
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
                            <label class="form-label">Üretim Matrisi</label>
                            <div class="form-check mt-2">
                                <input type="checkbox" class="form-check-input" id="ops_has_matrix" name="has_matrix" 
                                       onchange="OpsTask.toggleMatrixTemplate()">
                                <label class="form-check-label" for="ops_has_matrix">Matris kullan</label>
                            </div>
                            <select class="form-control mt-2" id="ops_matrix_template_id" name="matrix_template_id" 
                                    style="display: none;">
                                <option value="">Şablon Seçiniz...</option>
                                <option value="1">Üretim Süreci</option>
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
            </div>
        </div>
    </div>
</div>

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

<!--- Matris Modal --->
<div class="modal fade" id="modal_ops_task_matrix" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-xl" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Görev Matrisi</h5>
                <button type="button" class="close" data-dismiss="modal">
                    <span>&times;</span>
                </button>
            </div>
            <div class="modal-body" id="modal_ops_task_matrix_body">
                <!--- Matris içeriği AJAX ile yüklenir --->
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Kapat</button>
                <button type="button" class="btn btn-primary" onclick="OpsTask.saveMatrix()">
                    <i class="fa fa-save"></i> Kaydet
                </button>
            </div>
        </div>
    </div>
</div>

<!--- Silme Onay Modal --->
<div class="modal fade" id="modal_ops_task_delete" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-sm" role="document">
        <div class="modal-content">
            <div class="modal-header bg-danger text-white">
                <h5 class="modal-title">Görev Sil</h5>
                <button type="button" class="close text-white" data-dismiss="modal">
                    <span>&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <p>Bu görevi silmek istediğinize emin misiniz?</p>
                <p class="font-weight-bold" id="delete_task_name"></p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">İptal</button>
                <button type="button" class="btn btn-danger" onclick="OpsTask.confirmDelete()">
                    <i class="fa fa-trash"></i> Sil
                </button>
            </div>
        </div>
    </div>
</div>

<!--- CSS --->
<style>
.ops-task-module {
    padding: 10px;
}
.ops-task-toolbar .gap-2 {
    gap: 0.5rem;
}
#ops_task_grid tbody tr {
    cursor: pointer;
}
#ops_task_grid tbody tr:hover {
    background-color: #f8f9fa;
}
.ops-task-icon {
    cursor: pointer;
    padding: 2px 5px;
    border-radius: 3px;
    margin: 0 1px;
}
.ops-task-icon:hover {
    background-color: #e9ecef;
}
.ops-task-icon.disabled {
    opacity: 0.3;
    cursor: not-allowed;
}
.badge-status {
    font-size: 11px;
    padding: 4px 8px;
}
.badge-status-open { background-color: #ffc107; color: #000; }
.badge-status-progress { background-color: #17a2b8; color: #fff; }
.badge-status-done { background-color: #28a745; color: #fff; }
.percent-bar {
    height: 20px;
    background-color: #e9ecef;
    border-radius: 3px;
    overflow: hidden;
}
.percent-bar-fill {
    height: 100%;
    background-color: #28a745;
    text-align: center;
    color: #fff;
    font-size: 11px;
    line-height: 20px;
}
</style>
