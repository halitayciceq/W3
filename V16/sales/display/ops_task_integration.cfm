<!--- SİPARİŞ OPERASYON GÖREVLERİ ENTEGRASYONU --->
<cfoutput>
<!--- Görevler Modal --->
<div class="modal fade" id="modal_ops_tasks_main" tabindex="-1" role="dialog" data-backdrop="static">
    <div class="modal-dialog modal-xl" role="document">
        <div class="modal-content">
            <div class="modal-header" style="background:##3498db;color:##fff;padding:10px 15px;">
                <h5 class="modal-title" style="margin:0;">
                    <i class="fa fa-tasks"></i> Görevler (Operasyonlar)
                    <small class="ml-2" id="ops_tasks_order_info"></small>
                </h5>
                <button type="button" class="close" data-dismiss="modal" style="color:##fff;opacity:1;">
                    <span>&times;</span>
                </button>
            </div>
            <div class="modal-body p-0" id="modal_ops_tasks_body" style="min-height:400px;"></div>
        </div>
    </div>
</div>

<script type="text/javascript">
var OPS_TASK_CONFIG = {
    ref_type: 'ORDER',
    ref_id: #attributes.order_id#,
    order_number: '#JSStringFormat(get_order_detail.order_number)#',
    company_id: #session.ep.company_id#,
    branch_id: #session.ep.branch_id#,
    ajax_url: '/V16/sales/query/ajax_ops_task.cfm',
    taskFormUrl: '/V16/sales/form/dsp_ops_task.cfm'
};

// OpsTask objesi - sayfa yüklendiğinde hazır
window.OpsTask = {
    config: OPS_TASK_CONFIG,
    tasks: [],
    
    init: function(){
        console.log('[OpsTask] init', this.config);
        this.loadList();
    },
    
    loadList: function(){
        var self = this;
        var tbody = document.getElementById('ops_task_tbody');
        var emptyDiv = document.getElementById('ops_task_empty');
        if(!tbody) { console.error('[OpsTask] tbody not found'); return; }
        
        tbody.innerHTML = '<tr><td colspan="9" class="text-center py-4"><i class="fa fa-spinner fa-spin"></i> Yükleniyor...</td></tr>';
        if(emptyDiv) emptyDiv.style.display = 'none';
        
        var formData = new FormData();
        formData.append('action', 'list');
        formData.append('ref_type', this.config.ref_type);
        formData.append('ref_id', this.config.ref_id);
        formData.append('company_id', this.config.company_id);
        
        fetch(this.config.ajax_url, { method: 'POST', body: formData })
        .then(function(r){ return r.json(); })
        .then(function(resp){
            console.log('[OpsTask] list response:', resp);
            if(resp.success){
                self.tasks = resp.data;
                self.renderList();
            } else {
                tbody.innerHTML = '<tr><td colspan="9" class="text-center py-4 text-danger">' + (resp.message || 'Hata') + '</td></tr>';
            }
        })
        .catch(function(err){
            console.error('[OpsTask] loadList error:', err);
            tbody.innerHTML = '<tr><td colspan="9" class="text-center py-4 text-danger">Bağlantı hatası</td></tr>';
        });
    },
    
    renderList: function(){
        var tbody = document.getElementById('ops_task_tbody');
        var emptyDiv = document.getElementById('ops_task_empty');
        var table = document.getElementById('ops_task_grid');
        
        if(!this.tasks || this.tasks.length === 0){
            tbody.innerHTML = '';
            if(table) table.style.display = 'none';
            if(emptyDiv) emptyDiv.style.display = 'block';
            return;
        }
        
        if(table) table.style.display = 'table';
        if(emptyDiv) emptyDiv.style.display = 'none';
        
        var html = '';
        for(var i = 0; i < this.tasks.length; i++){
            var t = this.tasks[i];
            html += '<tr data-task-id="' + t.task_id + '" ondblclick="OpsTask.openModal(' + t.task_id + ')">';
            html += '<td class="text-center">' + (i+1) + '</td>';
            html += '<td>' + (t.assigned_name || '-') + '</td>';
            html += '<td><strong>' + (t.task_head || '') + '</strong></td>';
            html += '<td class="text-center"><span class="badge badge-secondary">' + (t.status_name || 'Bekliyor') + '</span></td>';
            html += '<td class="text-center">' + (t.deadline || '-') + '</td>';
            html += '<td class="text-right">' + (t.estimated_minutes || '-') + '</td>';
            html += '<td class="text-right">' + (t.actual_minutes || '-') + '</td>';
            html += '<td class="text-center">' + (t.percent_complete || 0) + '%</td>';
            html += '<td class="text-center"><i class="fa fa-edit text-primary" style="cursor:pointer" onclick="OpsTask.openModal(' + t.task_id + ')"></i></td>';
            html += '</tr>';
        }
        tbody.innerHTML = html;
    },
    
    openModal: function(taskId){
        taskId = taskId || 0;
        var url = this.config.taskFormUrl + '?task_id=' + taskId + '&ref_type=' + this.config.ref_type + '&ref_id=' + this.config.ref_id + '&company_id=' + this.config.company_id;
        if(typeof openBoxDraggable === 'function'){
            openBoxDraggable(url, taskId > 0 ? 'Görevi Düzenle' : 'Yeni Görev', 700, 600);
        } else {
            window.open(url, '_blank', 'width=700,height=600');
        }
    },
    
    deleteTask: function(taskId){
        if(!confirm('Bu görevi silmek istediğinize emin misiniz?')) return;
        var self = this;
        var formData = new FormData();
        formData.append('action', 'delete');
        formData.append('task_id', taskId);
        fetch(this.config.ajax_url, { method: 'POST', body: formData })
        .then(function(r){ return r.json(); })
        .then(function(resp){ if(resp.success) self.loadList(); else alert(resp.message); });
    }
};

function openOpsTasksModal() {
    console.log('[OpsTask] Modal açılıyor...');
    var modal = $('##modal_ops_tasks_main');
    $('##ops_tasks_order_info').text('(' + OPS_TASK_CONFIG.order_number + ')');
    $('##modal_ops_tasks_body').html('<div class="text-center py-5"><i class="fa fa-spinner fa-spin fa-2x"></i></div>');
    modal.modal('show');
    
    $.ajax({
        url: '/V16/sales/display/ops_task_list.cfm',
        data: { ref_type: OPS_TASK_CONFIG.ref_type, ref_id: OPS_TASK_CONFIG.ref_id, company_id: OPS_TASK_CONFIG.company_id },
        success: function(html) {
            $('##modal_ops_tasks_body').html(html);
            setTimeout(function(){ window.OpsTask.init(); }, 50);
        },
        error: function(xhr, status, error) {
            $('##modal_ops_tasks_body').html('<div class="alert alert-danger m-3">Hata: ' + error + '</div>');
        }
    });
}

$(document).ready(function() {
    console.log('[OpsTask] Document ready...');
    setTimeout(function() {
        var $menu = $('a[onclick*="openVoucher"]').closest('ul');
        if ($menu.length && $menu.find('a:contains("Görevler")').length === 0) {
            $menu.append('<li><a onclick="openOpsTasksModal();" href="javascript:;"><i class="fa fa-tasks"></i> Görevler (Operasyonlar)</a></li>');
            console.log('[OpsTask] Menü eklendi!');
        } else {
            console.log('[OpsTask] Menü bulunamadı veya zaten var');
        }
    }, 1000);
});
</script>
</cfoutput>
<script src="/V16/sales/js/ops_task.js"></script>
