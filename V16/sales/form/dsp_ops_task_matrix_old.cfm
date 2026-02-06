<cfsilent>
<cfparam name="url.task_id" default="0">
<cfparam name="url.ref_type" default="ORDER">
<cfparam name="url.ref_id" default="0">
<cfparam name="url.project_id" default="0">
<cfparam name="url.work_id" default="0">

<!--- Sipariş'ten project_id ve work_id al --->
<cfif url.ref_type EQ "ORDER" AND val(url.ref_id) GT 0>
    <cftry>
        <cfquery name="qOrder" datasource="#dsn3#">
            SELECT PROJECT_ID FROM ORDERS WHERE ORDER_ID = <cfqueryparam value="#url.ref_id#" cfsqltype="cf_sql_integer">
        </cfquery>
        <cfif qOrder.recordCount AND val(qOrder.PROJECT_ID) GT 0>
            <cfset url.project_id = qOrder.PROJECT_ID>
        </cfif>
    <cfcatch></cfcatch>
    </cftry>
</cfif>
</cfsilent>
<!--- Üretim Matrisi - Proje Modülünden Taşındı --->
<div class="matrix-modal">
    <div class="matrix-header">
        <div class="matrix-title"><i class="fa fa-th"></i> Üretim Matrisi <span id="matrixPercent" class="matrix-pct">%100</span></div>
        <div class="matrix-actions">
            <button type="button" class="matrix-btn" onclick="showWorkstations()"><i class="fa fa-cogs"></i> İstasyonlar</button>
            <button type="button" class="matrix-btn" onclick="resetMatrix()"><i class="fa fa-refresh"></i> Sıfırla</button>
            <button type="button" class="matrix-btn" onclick="document.getElementById('taskMatrixOverlay').remove()">Kapat</button>
            <button type="button" class="matrix-btn matrix-btn-success" onclick="saveMatrix()"><i class="fa fa-save"></i> Kaydet</button>
        </div>
    </div>
    
    <div class="matrix-legend">
        <span class="leg-item"><span class="leg-box leg-yok">YOK</span> Üretim Yok</span>
        <span class="leg-item"><span class="leg-box leg-minus">-</span> Üretim Tamamlanmadı</span>
        <span class="leg-item"><span class="leg-box leg-zero">0</span> Üretim Tamamlandı</span>
        <span class="leg-item"><span class="leg-box leg-stk">S</span> Hazır Stok Kullanılacak</span>
        <span class="leg-item"><span class="leg-box leg-plus">STD</span> Stokta Yok Ancak Standart Ürün</span>
    </div>
    
    <div class="matrix-content" id="matrixContent">
        <div class="matrix-loading"><i class="fa fa-spinner fa-spin"></i> Matris yükleniyor...</div>
    </div>
</div>

<style>
.matrix-modal { font-family: Arial, sans-serif; font-size: 13px; background: #fff; }
.matrix-header { background: linear-gradient(180deg, #00b4b4 0%, #009999 100%); color: #fff; padding: 12px 20px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px; }
.matrix-title { font-size: 16px; font-weight: 600; display: flex; align-items: center; gap: 10px; }
.matrix-pct { background: rgba(255,255,255,0.2); padding: 4px 12px; border-radius: 4px; font-size: 14px; }
.matrix-actions { display: flex; gap: 8px; flex-wrap: wrap; }
.matrix-btn { padding: 6px 12px; border-radius: 4px; font-size: 12px; cursor: pointer; border: 1px solid rgba(255,255,255,0.3); background: rgba(255,255,255,0.1); color: #fff; transition: all 0.2s; }
.matrix-btn:hover { background: rgba(255,255,255,0.2); }
.matrix-btn-success { background: #4caf50; border-color: #4caf50; }
.matrix-btn-success:hover { background: #43a047; }

.matrix-legend { display: flex; flex-wrap: wrap; gap: 12px; padding: 10px 20px; background: #f5f5f5; border-bottom: 1px solid #e0e0e0; font-size: 11px; }
.leg-item { display: flex; align-items: center; gap: 4px; }
.leg-box { display: inline-flex; align-items: center; justify-content: center; min-width: 28px; height: 20px; padding: 0 4px; border-radius: 3px; font-size: 9px; font-weight: 600; }
.leg-yok { background: #f5f5f5; border: 1px solid #bdbdbd; color: #757575; }
.leg-minus { background: #fff3e0; border: 1px solid #ffcc80; color: #e65100; }
.leg-zero { background: #f5f5f5; border: 1px solid #bdbdbd; color: #616161; }
.leg-stk { background: #e3f2fd; border: 1px solid #90caf9; color: #1976d2; }
.leg-plus { background: #e8f5e9; border: 1px solid #a5d6a7; color: #388e3c; }

.matrix-content { padding: 15px; max-height: 450px; overflow: auto; }
.matrix-loading, .matrix-empty { text-align: center; padding: 40px; color: #888; }

/* 2 Kolon Grid Layout */
.matrix-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 6px; }
@media (max-width: 600px) { .matrix-grid { grid-template-columns: 1fr; } }

/* Her item */
.matrix-item { display: flex; align-items: center; justify-content: space-between; gap: 8px; padding: 8px 12px; background: #fafafa; border: 1px solid #e8e8e8; border-radius: 4px; min-height: 40px; }
.matrix-item:hover { background: #f0f0f0; }
.matrix-label { flex: 1; min-width: 0; font-size: 11px; color: #333; line-height: 1.35; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.matrix-btns { display: flex; gap: 3px; flex: none; }

/* Buton stilleri */
.mbtn { width: 32px; height: 26px; border-radius: 3px; font-size: 10px; font-weight: 600; cursor: pointer; transition: all 0.15s; border: 1px solid; background: #fff; }
.mbtn:focus { outline: 2px solid #1976d2; outline-offset: 1px; }
.btn-plus { color: #388e3c; border-color: #a5d6a7; }
.btn-plus:hover { background: #e8f5e9; }
.btn-plus.active { background: #388e3c; color: #fff; border-color: #388e3c; }
.btn-stk { color: #1976d2; border-color: #90caf9; }
.btn-stk:hover { background: #e3f2fd; }
.btn-stk.active { background: #1976d2; color: #fff; border-color: #1976d2; }
.btn-zero { color: #616161; border-color: #bdbdbd; }
.btn-zero:hover { background: #f5f5f5; }
.btn-zero.active { background: #616161; color: #fff; border-color: #616161; }
.btn-yok { color: #9e9e9e; border-color: #e0e0e0; }
.btn-yok:hover { background: #fafafa; }
.btn-yok.active { background: #9e9e9e; color: #fff; border-color: #9e9e9e; }
.btn-minus { color: #e65100; border-color: #ffcc80; }
.btn-minus:hover { background: #fff3e0; }
.btn-minus.active { background: #e65100; color: #fff; border-color: #e65100; }

/* İstasyon Seçimi */
.ws-container { padding: 20px; }
.ws-header { font-size: 16px; font-weight: 600; margin-bottom: 15px; color: #333; }
.ws-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 8px; max-height: 350px; overflow: auto; }
.ws-item { display: flex; align-items: center; gap: 10px; padding: 10px 12px; background: #fafafa; border: 1px solid #e0e0e0; border-radius: 4px; cursor: pointer; }
.ws-item:hover { background: #e8f5e9; border-color: #a5d6a7; }
.ws-item.selected { background: #e8f5e9; border-color: #4caf50; }
.ws-item input { margin: 0; }
.ws-footer { margin-top: 15px; text-align: right; }
</style>

<script>
var matrixTaskId = <cfoutput>#val(url.task_id)#</cfoutput>;
var matrixRefType = '<cfoutput>#url.ref_type#</cfoutput>';
var matrixRefId = <cfoutput>#val(url.ref_id)#</cfoutput>;
var matrixProjectId = <cfoutput>#val(url.project_id)#</cfoutput>;
var matrixWorkId = <cfoutput>#val(url.work_id)#</cfoutput>;
var matrixData = null;

// Sayfa yüklendiğinde matrisi yükle
loadMatrixData();

function loadMatrixData() {
    // Proje modülünün ajax endpoint'ini kullan
    var ajaxUrl = '/V16/project/form/ajax_task_matrix.cfm?action=get&project_id=' + matrixProjectId + '&work_id=' + (matrixWorkId || matrixTaskId) + '&template_code=URETIM_SURECI';
    
    fetch(ajaxUrl, {credentials: 'include'})
    .then(function(r) { return r.json(); })
    .then(function(resp) {
        if(resp.success || resp.SUCCESS) {
            matrixData = resp;
            var cells = resp.cells || resp.CELLS || [];
            if(cells.length > 0) {
                renderMatrix(resp);
                calcMatrixPercent();
            } else if(resp.result_type === 'SELECT_WS') {
                // İstasyon seçimi gerekli
                renderWorkstationSelect(resp.workstations || []);
            } else {
                renderDefaultMatrix();
            }
        } else {
            renderDefaultMatrix();
        }
    })
    .catch(function(err) {
        console.log('Matris yüklenemedi, varsayılan kullanılıyor:', err);
        renderDefaultMatrix();
    });
}

function renderDefaultMatrix() {
    var defaultCells = [
        {cell_def_id: 1, cell_label: 'Yanyol İmalat - Profil Kesim', value_code: ''},
        {cell_def_id: 2, cell_label: 'Yanyol İmalat - Yanyol Grubu Kesim', value_code: ''},
        {cell_def_id: 3, cell_label: 'Yanyol İmalat - Kaynak', value_code: ''},
        {cell_def_id: 4, cell_label: 'Yanyol İmalat - Montaj', value_code: ''},
        {cell_def_id: 5, cell_label: 'Yanyol İmalat - Boya', value_code: ''},
        {cell_def_id: 6, cell_label: 'Direk İmalat - Yük Grubu Kesim', value_code: ''},
        {cell_def_id: 7, cell_label: 'Direk İmalat - Ayak Grubu Kesim', value_code: ''},
        {cell_def_id: 8, cell_label: 'Direk İmalat - Kaynak', value_code: ''},
        {cell_def_id: 9, cell_label: 'Direk İmalat - Boya', value_code: ''},
        {cell_def_id: 10, cell_label: 'Kanca Grubu İmalat - Kanca Grubu Kesim', value_code: ''},
        {cell_def_id: 11, cell_label: 'Kanca Grubu İmalat - Torna', value_code: ''},
        {cell_def_id: 12, cell_label: 'Kanca Grubu İmalat - Kaynak', value_code: ''},
        {cell_def_id: 13, cell_label: 'Araba Yürüyüş İmalat - Yürüyüş Kimyasal', value_code: ''},
        {cell_def_id: 14, cell_label: 'Araba Yürüyüş İmalat - A Yürüyüş Boya', value_code: ''},
        {cell_def_id: 15, cell_label: 'Araba Yürüyüş İmalat - Yürüyüş Montaj', value_code: ''}
    ];
    matrixData = {cells: defaultCells};
    renderMatrix(matrixData);
}

function renderMatrix(data) {
    var cells = data.cells || data.CELLS || [];
    if(cells.length === 0) {
        document.getElementById('matrixContent').innerHTML = '<div class="matrix-empty">Matris hücresi tanımlı değil.</div>';
        return;
    }
    
    var html = '<div class="matrix-grid">';
    for(var i = 0; i < cells.length; i++) {
        var cell = cells[i];
        var cellId = cell.cell_def_id || cell.CELL_DEF_ID || i;
        var label = cell.cell_label || cell.CELL_LABEL || 'Hücre ' + (i+1);
        var value = (cell.value_code || cell.VALUE_CODE || '').toUpperCase();
        
        html += '<div class="matrix-item" data-cell="' + cellId + '">';
        html += '<div class="matrix-label" title="' + label + '">' + label + '</div>';
        html += '<div class="matrix-btns">';
        
        var btns = [
            {code: 'PLUS', label: '+', cls: 'btn-plus'},
            {code: 'STK', label: 'STK', cls: 'btn-stk'},
            {code: 'ZERO', label: '0', cls: 'btn-zero'},
            {code: 'YOK', label: 'YOK', cls: 'btn-yok'},
            {code: 'MINUS', label: '-', cls: 'btn-minus'}
        ];
        
        for(var j = 0; j < btns.length; j++) {
            var b = btns[j];
            var isActive = value.indexOf(b.code) !== -1;
            html += '<button type="button" class="mbtn ' + b.cls + (isActive ? ' active' : '') + '" data-code="' + b.code + '" onclick="selectMatrixValue(' + cellId + ',\'' + b.code + '\',this)">' + b.label + '</button>';
        }
        
        html += '</div></div>';
    }
    html += '</div>';
    document.getElementById('matrixContent').innerHTML = html;
}

function selectMatrixValue(cellId, code, btn) {
    var isActive = btn.classList.contains('active');
    
    if(isActive) {
        btn.classList.remove('active');
    } else {
        btn.classList.add('active');
    }
    
    // Data güncelle
    if(matrixData && matrixData.cells) {
        for(var i = 0; i < matrixData.cells.length; i++) {
            var cid = matrixData.cells[i].cell_def_id || matrixData.cells[i].CELL_DEF_ID;
            if(cid == cellId) {
                var currentVal = (matrixData.cells[i].value_code || '');
                var valArray = currentVal ? currentVal.split(',').filter(function(v) { return v.length > 0; }) : [];
                
                if(isActive) {
                    valArray = valArray.filter(function(v) { return v !== code; });
                } else {
                    if(valArray.indexOf(code) === -1) valArray.push(code);
                }
                
                matrixData.cells[i].value_code = valArray.join(',');
                break;
            }
        }
    }
    
    calcMatrixPercent();
}

function calcMatrixPercent() {
    var cells = matrixData && matrixData.cells;
    if(!cells || cells.length === 0) return;
    
    var plusCount = 0;
    for(var i = 0; i < cells.length; i++) {
        var val = (cells[i].value_code || '').toUpperCase();
        if(val.indexOf('PLUS') !== -1) plusCount++;
    }
    
    var pct = Math.round((plusCount / cells.length) * 100);
    document.getElementById('matrixPercent').textContent = '%' + pct;
}

function resetMatrix() {
    if(!matrixData || !matrixData.cells) return;
    
    for(var i = 0; i < matrixData.cells.length; i++) {
        matrixData.cells[i].value_code = '';
    }
    
    document.querySelectorAll('.mbtn.active').forEach(function(btn) {
        btn.classList.remove('active');
    });
    
    calcMatrixPercent();
}

function showWorkstations() {
    // İstasyon listesini yükle
    fetch('/V16/project/form/ajax_task_matrix.cfm?action=ws_list', {credentials: 'include'})
    .then(function(r) { return r.json(); })
    .then(function(resp) {
        if(resp.success && resp.workstations) {
            renderWorkstationSelect(resp.workstations);
        } else {
            alert('İstasyon listesi yüklenemedi');
        }
    });
}

function renderWorkstationSelect(workstations) {
    var html = '<div class="ws-container">';
    html += '<div class="ws-header">İstasyonları Seçin</div>';
    html += '<div class="ws-grid">';
    for(var i = 0; i < workstations.length; i++) {
        var ws = workstations[i];
        html += '<label class="ws-item"><input type="checkbox" value="' + ws.workstation_id + '" data-code="' + (ws.code || '') + '" data-name="' + (ws.name || '') + '"> ' + ws.name + '</label>';
    }
    html += '</div>';
    html += '<div class="ws-footer"><button type="button" class="matrix-btn matrix-btn-success" onclick="saveWorkstations()">Seçimi Kaydet</button></div>';
    html += '</div>';
    document.getElementById('matrixContent').innerHTML = html;
}

function saveWorkstations() {
    var checkboxes = document.querySelectorAll('.ws-item input:checked');
    var selected = [];
    checkboxes.forEach(function(cb) {
        selected.push({
            workstation_id: parseInt(cb.value),
            code: cb.dataset.code,
            name: cb.dataset.name
        });
    });
    
    if(selected.length === 0) {
        alert('En az bir istasyon seçin');
        return;
    }
    
    var fd = new FormData();
    fd.append('action', 'ws_save');
    fd.append('project_id', matrixProjectId);
    fd.append('work_id', matrixWorkId || matrixTaskId);
    fd.append('json_workstations', JSON.stringify(selected));
    
    fetch('/V16/project/form/ajax_task_matrix.cfm', {method: 'POST', body: fd, credentials: 'include'})
    .then(function(r) { return r.json(); })
    .then(function(resp) {
        if(resp.success) {
            loadMatrixData(); // Matrisi yeniden yükle
        } else {
            alert(resp.message || 'Hata');
        }
    });
}

function saveMatrix() {
    var cells = matrixData && matrixData.cells;
    if(!cells || cells.length === 0) {
        // Varsayılan matris için sadece % kaydet
        var pct = parseInt(document.getElementById('matrixPercent').textContent.replace('%', '')) || 0;
        var fd = new FormData();
        fd.append('action', 'update_percent');
        fd.append('task_id', matrixTaskId);
        fd.append('percent_complete', pct);
        
        fetch('/V16/sales/query/ajax_ops_task.cfm', {method: 'POST', body: fd})
        .then(function(r) { return r.json(); })
        .then(function(resp) {
            if(resp.success) {
                document.getElementById('taskMatrixOverlay').remove();
                if(typeof OpsTask !== 'undefined') OpsTask.loadList();
            } else {
                alert(resp.message || 'Hata');
            }
        });
        return;
    }
    
    // Proje matris değerlerini kaydet
    var values = [];
    for(var i = 0; i < cells.length; i++) {
        var cellId = cells[i].cell_def_id || cells[i].CELL_DEF_ID;
        var valCode = (cells[i].value_code || '').toUpperCase();
        values.push({cell_def_id: cellId, value_code: valCode});
    }
    
    var fd = new FormData();
    fd.append('action', 'save');
    fd.append('project_id', matrixProjectId);
    fd.append('work_id', matrixWorkId || matrixTaskId);
    fd.append('template_code', 'URETIM_SURECI');
    fd.append('json_values', JSON.stringify(values));
    
    fetch('/V16/project/form/ajax_task_matrix.cfm', {method: 'POST', body: fd, credentials: 'include'})
    .then(function(r) { return r.json(); })
    .then(function(resp) {
        if(resp.success) {
            // OPS_TASK % güncelle
            var pct = resp.calc_percent || parseInt(document.getElementById('matrixPercent').textContent.replace('%', '')) || 0;
            var fd2 = new FormData();
            fd2.append('action', 'update_percent');
            fd2.append('task_id', matrixTaskId);
            fd2.append('percent_complete', pct);
            
            fetch('/V16/sales/query/ajax_ops_task.cfm', {method: 'POST', body: fd2})
            .then(function() {
                document.getElementById('taskMatrixOverlay').remove();
                if(typeof OpsTask !== 'undefined') OpsTask.loadList();
            });
        } else {
            alert(resp.message || 'Hata');
        }
    });
}
</script>
