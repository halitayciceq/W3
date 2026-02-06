/**
 * SIPARIŞ OPERASYON GÖREVLERİ - CLIENT-SIDE LOGIC
 * Tarih: 2026-01-22
 * Konum: /V16/order/js/ops_task.js
 * 
 * Bağımlılıklar: jQuery, Bootstrap 4, FontAwesome
 * 
 * Kullanım:
 * window.OPS_TASK_CONFIG = {
 *     ref_type: 'ORDER',
 *     ref_id: 123,
 *     company_id: 1,
 *     branch_id: 1,
 *     ajax_url: '/ajax/ajax_ops_task.cfm'
 * };
 */

var OpsTask = (function() {
    'use strict';
    
    // Config
    var config = {
        ref_type: 'ORDER',
        ref_id: 0,
        company_id: 0,
        branch_id: 0,
        ajax_url: '/V16/sales/query/ajax_ops_task.cfm'
    };
    
    // State
    var state = {
        currentTaskId: 0,
        matrixInstanceId: 0,
        tasks: [],
        isDirty: false
    };
    
    /**
     * Modülü başlat
     */
    function init() {
        // Config'i al
        if (window.OPS_TASK_CONFIG) {
            $.extend(config, window.OPS_TASK_CONFIG);
        }
        
        // Event listener'ları bağla
        bindEvents();
        
        // Listeyi yükle
        loadList();
        
        console.log('[OpsTask] Initialized', config);
    }
    
    /**
     * Event listener'ları bağla
     */
    function bindEvents() {
        // Filtre değişiklikleri
        $('#ops_task_filter_status, #ops_task_filter_employee').on('change', function() {
            loadList();
        });
        
        // Form submit
        $(document).on('submit', '#form_ops_task', function(e) {
            e.preventDefault();
            saveTask();
        });
        
        // Satır çift tıklama
        $(document).on('dblclick', '#ops_task_tbody tr[data-task-id]', function() {
            var taskId = $(this).data('task-id');
            openModal(taskId);
        });
        
        // Modal kapanırken
        $('#modal_ops_task').on('hidden.bs.modal', function() {
            state.currentTaskId = 0;
            state.isDirty = false;
        });
    }
    
    /**
     * Görev listesini yükle
     */
    function loadList() {
        var statusFilter = $('#ops_task_filter_status').val();
        var employeeFilter = $('#ops_task_filter_employee').val();
        
        $('#ops_task_tbody').html(
            '<tr class="ops-task-loading"><td colspan="9" class="text-center py-4">' +
            '<i class="fa fa-spinner fa-spin"></i> Yükleniyor...</td></tr>'
        );
        $('#ops_task_empty').hide();
        
        $.post(config.ajax_url, {
            action: 'list',
            ref_type: config.ref_type,
            ref_id: config.ref_id,
            company_id: config.company_id,
            status_id: statusFilter === 'open' ? '' : statusFilter,
            assigned_emp_id: employeeFilter
        })
        .done(function(response) {
            if (response.success) {
                state.tasks = response.data;
                renderList(response.data);
            } else {
                showError('Liste yüklenemedi: ' + response.message);
            }
        })
        .fail(function(xhr) {
            showError('Bağlantı hatası');
        });
    }
    
    /**
     * Listeyi render et
     */
    function renderList(tasks) {
        var tbody = $('#ops_task_tbody');
        tbody.empty();
        
        if (!tasks || tasks.length === 0) {
            $('#ops_task_grid').hide();
            $('#ops_task_empty').show();
            return;
        }
        
        $('#ops_task_grid').show();
        $('#ops_task_empty').hide();
        
        $.each(tasks, function(index, task) {
            var row = $('<tr>').attr('data-task-id', task.task_id);
            
            // Sıra
            row.append($('<td>').addClass('text-center').text(index + 1));
            
            // Sorumlu
            row.append($('<td>').text(task.assigned_name || '-'));
            
            // Başlık
            row.append($('<td>').html(
                '<span class="font-weight-bold">' + escapeHtml(task.task_head) + '</span>'
            ));
            
            // Aşama
            var statusBadge = getStatusBadge(task.status_id, task.status_name);
            row.append($('<td>').addClass('text-center').html(statusBadge));
            
            // Termin
            row.append($('<td>').addClass('text-center').text(formatDate(task.deadline)));
            
            // Öngörülen
            row.append($('<td>').addClass('text-right').text(formatMinutes(task.estimated_minutes)));
            
            // Harcanan
            row.append($('<td>').addClass('text-right').text(formatMinutes(task.actual_minutes)));
            
            // Yüzde
            var percentBar = renderPercentBar(task.percent_complete);
            row.append($('<td>').addClass('text-center').html(percentBar));
            
            // İşlemler
            var actions = renderActions(task);
            row.append($('<td>').addClass('text-center').html(actions));
            
            tbody.append(row);
        });
    }
    
    /**
     * Durum badge'i
     */
    function getStatusBadge(statusId, statusName) {
        var badgeClass = 'badge-secondary';
        if (statusId == 2361) badgeClass = 'badge-status-progress';
        else if (statusId == 2364) badgeClass = 'badge-status-done';
        else if (!statusId) badgeClass = 'badge-status-open';
        
        return '<span class="badge badge-status ' + badgeClass + '">' + 
               (statusName || 'Bekliyor') + '</span>';
    }
    
    /**
     * Yüzde bar
     */
    function renderPercentBar(percent) {
        percent = parseInt(percent) || 0;
        var color = percent >= 100 ? '#28a745' : (percent > 0 ? '#17a2b8' : '#e9ecef');
        return '<div class="percent-bar">' +
               '<div class="percent-bar-fill" style="width: ' + percent + '%; background-color: ' + color + ';">' +
               (percent > 0 ? percent + '%' : '') +
               '</div></div>';
    }
    
    /**
     * İşlem ikonları
     */
    function renderActions(task) {
        var html = '';
        
        // Belge ikonu (her zaman)
        html += '<span class="ops-task-icon" onclick="OpsTask.openDocument(' + task.task_id + ')" title="Belgeler">' +
                '<i class="fa fa-paperclip"></i></span>';
        
        // Ajanda ikonu (her zaman)
        html += '<span class="ops-task-icon" onclick="OpsTask.openCalendar(' + task.task_id + ')" title="Ajanda">' +
                '<i class="fa fa-calendar"></i></span>';
        
        // Matris ikonu (koşullu: HAS_MATRIX=1 && MATRIX_TEMPLATE_ID not null)
        if (task.has_matrix == 1 && task.matrix_template_id) {
            html += '<span class="ops-task-icon" onclick="OpsTask.openMatrix(' + task.task_id + ')" title="Matris">' +
                    '<i class="fa fa-th"></i></span>';
        }
        
        // Düzenle
        html += '<span class="ops-task-icon" onclick="OpsTask.openModal(' + task.task_id + ')" title="Düzenle">' +
                '<i class="fa fa-pencil"></i></span>';
        
        // Sil
        html += '<span class="ops-task-icon text-danger" onclick="OpsTask.deleteTask(' + task.task_id + ', \'' + 
                escapeHtml(task.task_head) + '\')" title="Sil">' +
                '<i class="fa fa-trash"></i></span>';
        
        return html;
    }
    
    /**
     * Görev modalını aç
     */
    function openModal(taskId) {
        state.currentTaskId = taskId || 0;
        
        var modal = $('#modal_ops_task');
        var title = taskId ? 'Görev Düzenle' : 'Yeni Görev';
        modal.find('.modal-title').text(title);
        
        // Form'u temizle
        var form = $('#form_ops_task');
        form[0].reset();
        
        // Hidden field'ları set et
        $('#ops_task_id').val(taskId || '');
        $('#ops_ref_type').val(config.ref_type);
        $('#ops_ref_id').val(config.ref_id);
        
        // Adımlar bölümünü gizle (yeni görevde)
        $('#ops_task_steps_section').toggle(taskId > 0);
        
        if (taskId) {
            // Mevcut görevi yükle
            loadTask(taskId);
        } else {
            modal.modal('show');
        }
    }
    
    /**
     * Görev detayını yükle
     */
    function loadTask(taskId) {
        $.post(config.ajax_url, {
            action: 'get',
            task_id: taskId
        })
        .done(function(response) {
            if (response.success) {
                populateForm(response.data.task);
                renderSteps(response.data.steps);
                
                // Matris varsa percent readonly yap
                if (response.data.task.matrix_instance_id) {
                    $('#ops_percent_complete').prop('readonly', true);
                    $('#ops_percent_readonly_hint').show();
                } else {
                    $('#ops_percent_complete').prop('readonly', false);
                    $('#ops_percent_readonly_hint').hide();
                }
                
                $('#modal_ops_task').modal('show');
            } else {
                showError('Görev yüklenemedi: ' + response.message);
            }
        })
        .fail(function() {
            showError('Bağlantı hatası');
        });
    }
    
    /**
     * Formu doldur
     */
    function populateForm(task) {
        $('#ops_task_head').val(task.task_head);
        $('#ops_task_detail').val(task.task_detail);
        $('#ops_assigned_emp_id').val(task.assigned_emp_id);
        $('#ops_priority_id').val(task.priority_id);
        $('#ops_planned_start').val(task.planned_start);
        $('#ops_planned_finish').val(task.planned_finish);
        $('#ops_deadline').val(task.deadline);
        $('#ops_percent_complete').val(task.percent_complete);
        
        // Öngörülen süre (dakikadan saat:dakika'ya)
        var hours = Math.floor(task.estimated_minutes / 60);
        var minutes = task.estimated_minutes % 60;
        $('#ops_estimated_hour').val(hours);
        $('#ops_estimated_minute').val(minutes);
        
        // Matris
        $('#ops_has_matrix').prop('checked', task.has_matrix == 1);
        toggleMatrixTemplate();
        $('#ops_matrix_template_id').val(task.matrix_template_id);
    }
    
    /**
     * Matris template dropdown toggle
     */
    function toggleMatrixTemplate() {
        var isChecked = $('#ops_has_matrix').is(':checked');
        $('#ops_matrix_template_id').toggle(isChecked);
        if (!isChecked) {
            $('#ops_matrix_template_id').val('');
        }
    }
    
    /**
     * Adımları render et
     */
    function renderSteps(steps) {
        var container = $('#ops_task_steps_container');
        container.empty();
        
        if (steps && steps.length > 0) {
            $.each(steps, function(i, step) {
                addStep(step);
            });
        }
    }
    
    /**
     * Adım ekle
     */
    function addStep(stepData) {
        var template = $('#ops_step_template').html();
        var row = $(template);
        
        if (stepData) {
            row.find('input[type="text"]').val(stepData.step_description);
            row.find('input[type="number"]:first').val(stepData.estimated_hour || 0);
            row.find('input[type="number"]:last').val(stepData.estimated_minute || 0);
            row.find('input[type="checkbox"]').prop('checked', stepData.is_complete == 1);
            row.data('step-id', stepData.step_id);
        }
        
        $('#ops_task_steps_container').append(row);
    }
    
    /**
     * Adım sil
     */
    function removeStep(btn) {
        $(btn).closest('.ops-step-row').remove();
    }
    
    /**
     * Görevi kaydet
     */
    function saveTask() {
        var form = $('#form_ops_task');
        
        // Validation
        if (!form[0].checkValidity()) {
            form.addClass('was-validated');
            return;
        }
        
        // Öngörülen süreyi dakikaya çevir
        var estimatedMinutes = (parseInt($('#ops_estimated_hour').val()) || 0) * 60 +
                               (parseInt($('#ops_estimated_minute').val()) || 0);
        
        var formData = {
            action: 'save',
            task_id: $('#ops_task_id').val(),
            ref_type: $('#ops_ref_type').val(),
            ref_id: $('#ops_ref_id').val(),
            task_head: $('#ops_task_head').val(),
            task_detail: $('#ops_task_detail').val(),
            assigned_emp_id: $('#ops_assigned_emp_id').val(),
            priority_id: $('#ops_priority_id').val(),
            planned_start: $('#ops_planned_start').val(),
            planned_finish: $('#ops_planned_finish').val(),
            deadline: $('#ops_deadline').val(),
            estimated_minutes: estimatedMinutes,
            percent_complete: $('#ops_percent_complete').val(),
            has_matrix: $('#ops_has_matrix').is(':checked') ? 1 : 0,
            matrix_template_id: $('#ops_matrix_template_id').val(),
            company_id: config.company_id,
            branch_id: config.branch_id
        };
        
        $.post(config.ajax_url, formData)
        .done(function(response) {
            if (response.success) {
                $('#modal_ops_task').modal('hide');
                loadList();
                showSuccess(response.message);
                
                // Adımları kaydet (varsa)
                if (response.data.task_id && state.currentTaskId > 0) {
                    saveSteps(response.data.task_id);
                }
            } else {
                showError('Kayıt hatası: ' + response.message);
            }
        })
        .fail(function() {
            showError('Bağlantı hatası');
        });
    }
    
    /**
     * Adımları kaydet
     */
    function saveSteps(taskId) {
        var steps = [];
        $('#ops_task_steps_container .ops-step-row').each(function(index) {
            var row = $(this);
            steps.push({
                step_order: index + 1,
                step_description: row.find('input[type="text"]').val(),
                estimated_hour: parseInt(row.find('input[type="number"]:first').val()) || 0,
                estimated_minute: parseInt(row.find('input[type="number"]:last').val()) || 0,
                is_complete: row.find('input[type="checkbox"]').is(':checked') ? 1 : 0
            });
        });
        
        if (steps.length > 0) {
            $.post(config.ajax_url, {
                action: 'step_save',
                task_id: taskId,
                steps_json: JSON.stringify(steps)
            });
        }
    }
    
    /**
     * Görev sil (onay iste)
     */
    function deleteTask(taskId, taskName) {
        state.currentTaskId = taskId;
        $('#delete_task_name').text(taskName);
        $('#modal_ops_task_delete').modal('show');
    }
    
    /**
     * Silmeyi onayla
     */
    function confirmDelete() {
        $.post(config.ajax_url, {
            action: 'delete',
            task_id: state.currentTaskId
        })
        .done(function(response) {
            $('#modal_ops_task_delete').modal('hide');
            if (response.success) {
                loadList();
                showSuccess('Görev silindi');
            } else {
                showError('Silme hatası: ' + response.message);
            }
        })
        .fail(function() {
            showError('Bağlantı hatası');
        });
    }
    
    /**
     * Matris modalını aç
     */
    function openMatrix(taskId) {
        state.currentTaskId = taskId;
        
        $.post(config.ajax_url, {
            action: 'matrix_get',
            task_id: taskId
        })
        .done(function(response) {
            if (response.success) {
                var data = response.data;
                
                if (data.result_type === 'NO_TEMPLATE') {
                    showError('Bu görev için matris şablonu tanımlı değil.');
                    return;
                }
                
                if (data.result_type === 'SELECT_STAGE') {
                    renderStageSelection(data.stages);
                } else {
                    renderMatrix(data);
                }
                
                $('#modal_ops_task_matrix').modal('show');
            } else {
                showError('Matris yüklenemedi: ' + response.message);
            }
        })
        .fail(function() {
            showError('Bağlantı hatası');
        });
    }
    
    /**
     * Stage seçim ekranını render et
     */
    function renderStageSelection(stages) {
        var html = '<div class="stage-selection">';
        html += '<p class="mb-3">Bu görev için kullanılacak aşamaları seçiniz:</p>';
        html += '<div class="row">';
        
        $.each(stages, function(i, stage) {
            html += '<div class="col-md-4 mb-2">';
            html += '<div class="form-check">';
            html += '<input type="checkbox" class="form-check-input stage-checkbox" ' +
                    'value="' + stage.stage_dim_id + '" ' +
                    'data-code="' + stage.stage_code + '" ' +
                    'data-name="' + escapeHtml(stage.stage_name) + '">';
            html += '<label class="form-check-label">' + escapeHtml(stage.stage_name) + '</label>';
            html += '</div></div>';
        });
        
        html += '</div>';
        html += '<button type="button" class="btn btn-primary mt-3" onclick="OpsTask.saveStageSelection()">';
        html += '<i class="fa fa-check"></i> Seçimi Kaydet</button>';
        html += '</div>';
        
        $('#modal_ops_task_matrix_body').html(html);
    }
    
    /**
     * Stage seçimini kaydet
     */
    function saveStageSelection() {
        var stages = [];
        $('.stage-checkbox:checked').each(function() {
            stages.push({
                stage_dim_id: $(this).val(),
                stage_code: $(this).data('code'),
                stage_name: $(this).data('name')
            });
        });
        
        if (stages.length === 0) {
            showError('En az bir aşama seçiniz.');
            return;
        }
        
        $.post(config.ajax_url, {
            action: 'stage_save',
            task_id: state.currentTaskId,
            template_id: 1, // TODO: dinamik template
            stages_json: JSON.stringify(stages)
        })
        .done(function(response) {
            if (response.success) {
                // Matrisi yeniden yükle
                openMatrix(state.currentTaskId);
            } else {
                showError('Stage kaydetme hatası: ' + response.message);
            }
        });
    }
    
    /**
     * Matris grid'ini render et
     */
    function renderMatrix(data) {
        state.matrixInstanceId = data.instance_id;
        
        var html = '<div class="matrix-container">';
        
        // Başlık
        html += '<h6 class="mb-3">' + escapeHtml(data.template.template_name) + '</h6>';
        
        // Matris tablosu
        html += '<table class="table table-bordered table-sm matrix-table">';
        html += '<thead><tr><th>Aşama</th><th>Durum</th></tr></thead>';
        html += '<tbody>';
        
        $.each(data.cells, function(i, cell) {
            html += '<tr data-cell-id="' + cell.cell_def_id + '">';
            html += '<td>' + escapeHtml(cell.cell_label || cell.stage_code) + '</td>';
            html += '<td class="matrix-cell-buttons">';
            
            // Butonları render et
            $.each(data.values, function(j, val) {
                var isActive = cell.value_code && cell.value_code.indexOf(val.value_code) >= 0;
                var btnClass = isActive ? 'btn-' + getButtonColor(val.value_code) : 'btn-outline-secondary';
                html += '<button type="button" class="btn btn-sm ' + btnClass + ' matrix-btn" ' +
                        'data-value="' + val.value_code + '" ' +
                        'onclick="OpsTask.toggleMatrixButton(this)">' +
                        val.value_label + '</button> ';
            });
            
            html += '</td></tr>';
        });
        
        html += '</tbody></table>';
        html += '</div>';
        
        $('#modal_ops_task_matrix_body').html(html);
    }
    
    /**
     * Matris butonu toggle
     */
    function toggleMatrixButton(btn) {
        var $btn = $(btn);
        var valueCode = $btn.data('value');
        var $cell = $btn.closest('tr');
        
        // Buton durumunu toggle et
        $btn.toggleClass('btn-outline-secondary');
        $btn.toggleClass('btn-' + getButtonColor(valueCode));
    }
    
    /**
     * Buton rengi
     */
    function getButtonColor(valueCode) {
        switch(valueCode) {
            case 'PLUS': return 'success';
            case 'MINUS': return 'danger';
            case 'STK': return 'warning';
            case 'NA': return 'secondary';
            default: return 'primary';
        }
    }
    
    /**
     * Matrisi kaydet
     */
    function saveMatrix() {
        var cells = [];
        
        $('#modal_ops_task_matrix_body .matrix-table tbody tr').each(function() {
            var cellDefId = $(this).data('cell-id');
            var valueCodes = [];
            
            $(this).find('.matrix-btn:not(.btn-outline-secondary)').each(function() {
                valueCodes.push($(this).data('value'));
            });
            
            cells.push({
                cell_def_id: cellDefId,
                value_code: valueCodes.join(',')
            });
        });
        
        $.post(config.ajax_url, {
            action: 'matrix_save',
            task_id: state.currentTaskId,
            cells_json: JSON.stringify(cells)
        })
        .done(function(response) {
            if (response.success) {
                $('#modal_ops_task_matrix').modal('hide');
                loadList();
                showSuccess('Matris kaydedildi (%' + response.data.calc_percent + ')');
            } else {
                showError('Matris kaydetme hatası: ' + response.message);
            }
        })
        .fail(function() {
            showError('Bağlantı hatası');
        });
    }
    
    /**
     * Belge modalını aç
     */
    function openDocument(taskId) {
        // Mevcut generic belge altyapısını kullan
        if (typeof openDocumentModal === 'function') {
            openDocumentModal('OPS_TASK', taskId);
        } else {
            showInfo('Belge modülü yükleniyor...');
            // Fallback: yeni pencere aç
            window.open('/documents/list.cfm?action_section=OPS_TASK&action_id=' + taskId, '_blank');
        }
    }
    
    /**
     * Takvim modalını aç
     */
    function openCalendar(taskId) {
        if (typeof openCalendarModal === 'function') {
            openCalendarModal('OPS_TASK', taskId);
        } else {
            showInfo('Takvim modülü Faz-2\'de aktif olacak.');
        }
    }
    
    // ==================== HELPERS ====================
    
    function formatDate(dateStr) {
        if (!dateStr) return '-';
        var d = new Date(dateStr);
        return ('0' + d.getDate()).slice(-2) + '.' + 
               ('0' + (d.getMonth() + 1)).slice(-2) + '.' + 
               d.getFullYear();
    }
    
    function formatMinutes(minutes) {
        if (!minutes) return '-';
        var h = Math.floor(minutes / 60);
        var m = minutes % 60;
        return h + ':' + ('0' + m).slice(-2);
    }
    
    function escapeHtml(str) {
        if (!str) return '';
        return str.replace(/&/g, '&amp;')
                  .replace(/</g, '&lt;')
                  .replace(/>/g, '&gt;')
                  .replace(/"/g, '&quot;');
    }
    
    function showSuccess(msg) {
        if (typeof toastr !== 'undefined') {
            toastr.success(msg);
        } else {
            alert(msg);
        }
    }
    
    function showError(msg) {
        if (typeof toastr !== 'undefined') {
            toastr.error(msg);
        } else {
            alert('Hata: ' + msg);
        }
    }
    
    function showInfo(msg) {
        if (typeof toastr !== 'undefined') {
            toastr.info(msg);
        } else {
            alert(msg);
        }
    }
    
    // ==================== PUBLIC API ====================
    
    return {
        init: init,
        loadList: loadList,
        openModal: openModal,
        saveTask: saveTask,
        deleteTask: deleteTask,
        confirmDelete: confirmDelete,
        openMatrix: openMatrix,
        saveMatrix: saveMatrix,
        saveStageSelection: saveStageSelection,
        toggleMatrixButton: toggleMatrixButton,
        toggleMatrixTemplate: toggleMatrixTemplate,
        addStep: addStep,
        removeStep: removeStep,
        openDocument: openDocument,
        openCalendar: openCalendar
    };
    
})();

// DOM hazır olduğunda başlat
$(document).ready(function() {
    if ($('#ops-task-container').length) {
        OpsTask.init();
    }
});
