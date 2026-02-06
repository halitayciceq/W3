<cfsilent>
<cfparam name="url.task_id" default="0">
<cfparam name="url.ref_type" default="ORDER">
<cfparam name="url.ref_id" default="0">
<!--- Matris artık ORDER-TASK yapısına bağlı, proje ID'sine gerek yok --->
</cfsilent>
<!--- DEBUG: Parametreleri göster --->
<script>
console.log('Matrix DEBUG - task_id: <cfoutput>#val(url.task_id)#</cfoutput>, ref_type: <cfoutput>#url.ref_type#</cfoutput>, ref_id (order_id): <cfoutput>#val(url.ref_id)#</cfoutput>');
</script>
<!--- Üretim Matrisi - Proje Modülünden Bire Bir Alındı --->
<div class="matrix-modal">
    <div class="matrix-header">
        <div class="matrix-title-section">
            <i class="fa fa-th" style="font-size:18px;color:#1976d2;"></i>
            <span class="matrix-title">Üretim Matrisi</span>
            <span id="matrixPercent" class="matrix-pct">%0</span>
        </div>
        <div class="matrix-actions">
            <button type="button" class="btn-ws-edit" onclick="editWorkstations()">İstasyonlar</button>
            <button type="button" class="btn-reset" onclick="resetMatrix()">Sıfırla</button>
            <button type="button" class="btn-close" onclick="document.getElementById('taskMatrixOverlay').remove()">Kapat</button>
            <button type="button" class="btn-save" onclick="saveMatrix()">Kaydet</button>
        </div>
    </div>
    
    <div class="matrix-legend">
        <span class="legend-item"><span class="leg-box leg-plus">+</span> Tamamlandı</span>
        <span class="legend-item"><span class="leg-box leg-stk">STK</span> Stok</span>
        <span class="legend-item"><span class="leg-box leg-zero">0</span> Bekliyor</span>
        <span class="legend-item"><span class="leg-box leg-yok">YOK</span> Yok</span>
        <span class="legend-item"><span class="leg-box leg-minus">-</span> İptal</span>
    </div>
    
    <div class="matrix-content" id="matrixContent">
        <div class="matrix-loading"><i class="fa fa-spinner fa-spin"></i> Matris yükleniyor...</div>
    </div>
</div>

<style>
.matrix-modal { background: #fff; width: 100%; max-height: 85vh; display: flex; flex-direction: column; overflow: hidden; font-family: Arial, sans-serif; font-size: 13px; }
.matrix-header { background: #fff; border-bottom: 1px solid #e0e0e0; padding: 10px 16px; display: flex; justify-content: space-between; align-items: center; }
.matrix-title-section { display: flex; align-items: center; gap: 10px; }
.matrix-title { font-size: 15px; font-weight: 600; color: #333; }
.matrix-pct { background: #e8f5e9; color: #2e7d32; padding: 3px 10px; border-radius: 12px; font-size: 12px; font-weight: 600; }
.matrix-actions { display: flex; gap: 6px; }
.btn-ws-edit { padding: 6px 16px; border: none; border-radius: 4px; background: #0d6efd; cursor: pointer; font-size: 12px; color: #fff; font-weight: 500; }
.btn-ws-edit:hover { background: #0b5ed7; }
.btn-reset { padding: 6px 16px; border: 1px solid #ffc107; border-radius: 4px; background: #ffc107; cursor: pointer; font-size: 12px; color: #000; font-weight: 500; }
.btn-reset:hover { background: #ffca2c; }
.btn-close { padding: 6px 16px; border: 1px solid #6c757d; border-radius: 4px; background: #fff; cursor: pointer; font-size: 12px; color: #333; font-weight: 500; }
.btn-close:hover { background: #f8f9fa; }
.btn-save { padding: 6px 16px; border: none; border-radius: 4px; background: #198754; color: #fff; cursor: pointer; font-size: 12px; font-weight: 500; }
.btn-save:hover { background: #157347; }

.matrix-legend { display: flex; flex-wrap: nowrap; gap: 12px; padding: 6px 12px; background: #fafafa; border-bottom: 1px solid #e0e0e0; font-size: 10px; white-space: nowrap; }
.legend-item { display: flex; align-items: center; gap: 3px; color: #666; }
.leg-box { display: inline-flex; align-items: center; justify-content: center; min-width: 24px; height: 18px; padding: 0 3px; border-radius: 3px; font-size: 9px; font-weight: 600; }
.leg-yok { background: #f5f5f5; border: 1px solid #bdbdbd; color: #757575; }
.leg-minus { background: #fff3e0; border: 1px solid #ffcc80; color: #e65100; }
.leg-zero { background: #f5f5f5; border: 1px solid #bdbdbd; color: #616161; }
.leg-stk { background: #e3f2fd; border: 1px solid #90caf9; color: #1976d2; }
.leg-plus { background: #e8f5e9; border: 1px solid #a5d6a7; color: #388e3c; }

.matrix-content { flex: 1; overflow: auto; padding: 12px; }
.matrix-loading, .matrix-empty, .matrix-error { text-align: center; padding: 40px; color: #888; font-size: 13px; }
.matrix-error { color: #d32f2f; }

.matrix-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 6px; }
@media (max-width: 768px) { .matrix-grid { grid-template-columns: 1fr; } }

.matrix-item { display: flex; align-items: center; justify-content: space-between; gap: 8px; padding: 6px 10px; background: #fafafa; border: 1px solid #e8e8e8; border-radius: 4px; min-height: 36px; }
.matrix-item:hover { background: #f0f0f0; }
.matrix-label { flex: 1; min-width: 0; font-size: 11px; color: #333; line-height: 1.35; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; text-overflow: ellipsis; }
.matrix-btns { display: flex; gap: 1px; flex: none; }

.mbtn { width: 32px; height: 24px; border-radius: 3px; font-size: 10px; font-weight: 600; cursor: pointer; transition: all 0.15s; border: 1px solid; background: #fff; text-align: center; }
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

.ws-select-container { padding: 20px; }
.ws-select-header { font-size: 16px; font-weight: 600; color: #333; margin-bottom: 8px; }
.ws-select-info { font-size: 12px; color: #666; margin-bottom: 16px; }
.ws-select-list { display: grid; grid-template-columns: repeat(2, 1fr); gap: 8px; max-height: 400px; overflow-y: auto; padding: 4px; }
@media (max-width: 600px) { .ws-select-list { grid-template-columns: 1fr; } }
.ws-item { display: flex; align-items: center; gap: 10px; padding: 10px 12px; background: #fafafa; border: 1px solid #e0e0e0; border-radius: 4px; cursor: pointer; transition: all 0.15s; }
.ws-item:hover { background: #f0f0f0; border-color: #bdbdbd; }
.ws-item:has(.ws-checkbox:checked) { background: #e3f2fd; border-color: #1976d2; }
.ws-checkbox { width: 18px; height: 18px; cursor: pointer; accent-color: #1976d2; }
.ws-name { font-size: 13px; color: #333; flex: 1; }
.ws-select-actions { display: flex; gap: 12px; margin-top: 20px; justify-content: flex-end; }
.btn-ws-all { padding: 8px 16px; border: 1px solid #1976d2; border-radius: 4px; background: #fff; color: #1976d2; cursor: pointer; font-size: 13px; }
.btn-ws-all:hover { background: #e3f2fd; }
.btn-ws-save { padding: 8px 20px; border: none; border-radius: 4px; background: #1976d2; color: #fff; cursor: pointer; font-size: 13px; font-weight: 500; }
.btn-ws-save:hover { background: #1565c0; }
</style>

<script>
var matrixTaskId = <cfoutput>#val(url.task_id)#</cfoutput>;
var matrixRefType = '<cfoutput>#url.ref_type#</cfoutput>';
var matrixRefId = <cfoutput>#val(url.ref_id)#</cfoutput>;
var matrixData = null;
var selectedWorkstations = [];

console.log('Matrix params:', {taskId: matrixTaskId, refType: matrixRefType, refId: matrixRefId});

function initMatrix() {
    var content = document.getElementById('matrixContent');
    if(!content) {
        console.log('matrixContent not found, retrying...');
        setTimeout(initMatrix, 50);
        return;
    }
    
    // localStorage'dan kaydedilmiş istasyonları yükle
    var wsKey = 'matrix_ws_order_' + matrixRefId + '_task_' + matrixTaskId;
    var savedWS = localStorage.getItem(wsKey);
    if (savedWS) {
        try {
            selectedWorkstations = JSON.parse(savedWS);
            console.log('İstasyonlar localStorage\'dan yüklendi:', selectedWorkstations);
        } catch(e) {
            selectedWorkstations = [];
        }
    }
    
    // localStorage'dan kaydedilmiş matris değerlerini yükle
    var valuesKey = 'matrix_values_order_' + matrixRefId + '_task_' + matrixTaskId;
    var savedValues = localStorage.getItem(valuesKey);
    var loadedValues = null;
    if (savedValues) {
        try {
            loadedValues = JSON.parse(savedValues);
            console.log('Matris değerleri localStorage\'dan yüklendi:', loadedValues);
        } catch(e) {}
    }
    
    // Kaydedilmiş istasyon varsa matrisi göster, yoksa istasyon seçimi
    if (selectedWorkstations.length > 0) {
        renderDefaultMatrixWithValues(loadedValues);
    } else {
        // İstasyon seçimi ekranını göster
        editWorkstations();
    }
}

setTimeout(initMatrix, 10);

function loadMatrixData() {
    // Sipariş-Task bazlı matris - localStorage'dan yükle
    console.log('loadMatrixData - using localStorage for order-task matrix');
    renderDefaultMatrix();
}

function renderDefaultMatrix() {
    renderDefaultMatrixWithValues(null);
}

function renderDefaultMatrixWithValues(savedValues) {
    // Seçilen istasyonlar varsa onlara göre hücre oluştur, yoksa boş göster
    if (selectedWorkstations && selectedWorkstations.length > 0) {
        var defaultCells = [];
        var cellId = 1;
        for (var i = 0; i < selectedWorkstations.length; i++) {
            var ws = selectedWorkstations[i];
            var wsName = ws.name || ws.NAME || '';
            // Her istasyon için örnek alt süreçler
            var subProcesses = ['Kesim', 'Kaynak', 'Montaj', 'Boya'];
            for (var j = 0; j < subProcesses.length; j++) {
                var cellLabel = wsName + ' - ' + subProcesses[j];
                var valueCode = '';
                // Kaydedilmiş değer varsa kullan (cell_label ile eşleştir)
                if (savedValues) {
                    for (var k = 0; k < savedValues.length; k++) {
                        if (savedValues[k].cell_label === cellLabel) {
                            valueCode = savedValues[k].value_code || '';
                            break;
                        }
                    }
                }
                defaultCells.push({
                    cell_def_id: cellId++,
                    cell_label: cellLabel,
                    value_code: valueCode
                });
            }
        }
        matrixData = {cells: defaultCells};
        renderMatrix(matrixData);
        calcMatrixPercent();
    } else {
        // Hiç istasyon seçilmemişse istasyon seçimi ekranını göster
        document.getElementById('matrixContent').innerHTML = '<div class="matrix-empty">Önce istasyon seçimi yapmalısınız. Üstteki "İstasyonlar" butonuna tıklayın.</div>';
    }
}

function renderWorkstationSelect(workstations, isEditMode) {
    var existingSelection = isEditMode ? selectedWorkstations.slice() : [];
    selectedWorkstations = [];
    
    var html = '<div class="ws-select-container">';
    html += '<div class="ws-select-header">' + (isEditMode ? 'İstasyonları Düzenle' : 'İstasyon Seçimi') + '</div>';
    html += '<div class="ws-select-info">Matris için kullanılacak istasyonları seçin:</div>';
    html += '<div class="ws-select-list">';
    
    for (var i = 0; i < workstations.length; i++) {
        var ws = workstations[i];
        var wsId = ws.workstation_id || ws.WORKSTATION_ID;
        var wsCode = ws.code || ws.CODE || '';
        var wsName = ws.name || ws.NAME || 'İstasyon ' + (i+1);
        
        var isSelected = existingSelection.some(function(s) { return s.workstation_id === wsId; });
        if (isSelected) {
            selectedWorkstations.push({workstation_id: wsId, code: wsCode, name: wsName});
        }
        
        html += '<label class="ws-item">';
        html += '<input type="checkbox" class="ws-checkbox" data-id="' + wsId + '" data-code="' + wsCode + '" data-name="' + wsName + '" onchange="toggleWorkstation(this)"' + (isSelected ? ' checked' : '') + '>';
        html += '<span class="ws-name">' + wsName + '</span>';
        html += '</label>';
    }
    
    html += '</div>';
    html += '<div class="ws-select-actions">';
    html += '<button onclick="selectAllWorkstations()" class="btn-ws-all">Tümünü Seç</button>';
    html += '<button onclick="saveWorkstationSelection()" class="btn-ws-save">' + (isEditMode ? 'Güncelle' : 'Matrisi Oluştur') + '</button>';
    html += '</div>';
    html += '</div>';
    
    document.getElementById('matrixContent').innerHTML = html;
    document.querySelector('.matrix-title').textContent = isEditMode ? 'İstasyonları Düzenle' : 'İstasyon Seçimi';
    document.getElementById('matrixPercent').style.display = 'none';
    document.querySelector('.btn-reset').style.display = 'none';
    document.querySelector('.btn-save').style.display = 'none';
    document.querySelector('.btn-ws-edit').style.display = 'none';
    document.querySelector('.matrix-legend').style.display = 'none';
}

function toggleWorkstation(checkbox) {
    var wsId = parseInt(checkbox.dataset.id);
    var wsCode = checkbox.dataset.code;
    var wsName = checkbox.dataset.name;
    
    if (checkbox.checked) {
        selectedWorkstations.push({workstation_id: wsId, code: wsCode, name: wsName});
    } else {
        selectedWorkstations = selectedWorkstations.filter(function(ws) { return ws.workstation_id !== wsId; });
    }
}

function selectAllWorkstations() {
    var checkboxes = document.querySelectorAll('.ws-checkbox');
    checkboxes.forEach(function(cb) {
        if (!cb.checked) {
            cb.checked = true;
            toggleWorkstation(cb);
        }
    });
}

function saveWorkstationSelection() {
    if (selectedWorkstations.length === 0) {
        alert('En az bir istasyon seçmelisiniz.');
        return;
    }
    
    // Sipariş bazlı matris için localStorage'da sakla
    var storageKey = 'matrix_ws_order_' + matrixRefId + '_task_' + matrixTaskId;
    localStorage.setItem(storageKey, JSON.stringify(selectedWorkstations));
    console.log('İstasyonlar kaydedildi:', storageKey, selectedWorkstations);
    
    // Matris'i seçilen istasyonlarla göster
    renderDefaultMatrix();
}

function editWorkstations() {
    // İstasyon listesini DB'den dinamik çek
    var xhr = new XMLHttpRequest();
    xhr.open('GET', '/V16/project/form/ajax_task_matrix.cfm?action=ws_list', true);
    xhr.withCredentials = true;
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4 && xhr.status === 200) {
            try {
                var resp = JSON.parse(xhr.responseText);
                if (resp.success || resp.SUCCESS) {
                    renderWorkstationSelect(resp.workstations || resp.WORKSTATIONS || [], true);
                }
            } catch(e) {
                console.error('JSON parse error:', e);
            }
        }
    };
    xhr.send();
}

function renderMatrix(data) {
    var cells = data.cells || data.CELLS || [];
    
    document.querySelector('.matrix-title').textContent = 'Üretim Matrisi';
    document.getElementById('matrixPercent').style.display = '';
    document.querySelector('.btn-reset').style.display = '';
    document.querySelector('.btn-save').style.display = '';
    document.querySelector('.btn-ws-edit').style.display = '';
    document.querySelector('.matrix-legend').style.display = '';
    
    // Seçilen istasyonlara göre filtrele
    var filteredCells = cells;
    if (selectedWorkstations && selectedWorkstations.length > 0) {
        var selectedNames = selectedWorkstations.map(function(ws) { 
            return (ws.name || ws.NAME || '').toLowerCase(); 
        });
        filteredCells = cells.filter(function(cell) {
            var label = (cell.cell_label || cell.CELL_LABEL || '').toLowerCase();
            // Hücre etiketinin seçilen istasyonlardan biriyle başlayıp başlamadığını kontrol et
            for (var k = 0; k < selectedNames.length; k++) {
                if (label.indexOf(selectedNames[k]) === 0 || label.indexOf(selectedNames[k] + ' -') !== -1) {
                    return true;
                }
            }
            return false;
        });
    }
    
    if (filteredCells.length === 0) {
        document.getElementById('matrixContent').innerHTML = '<div class="matrix-empty">Seçilen istasyonlar için hücre tanımı yok.</div>';
        return;
    }
    
    var html = '<div class="matrix-grid">';
    
    for (var i = 0; i < filteredCells.length; i++) {
        var cell = filteredCells[i];
        var cellDefId = cell.cell_def_id || cell.CELL_DEF_ID;
        var cellLabel = cell.cell_label || cell.CELL_LABEL || 'Hücre ' + (i+1);
        var currentValue = cell.value_code || cell.VALUE_CODE || '';
        
        html += '<div class="matrix-item" data-cell="' + cellDefId + '">';
        html += '<div class="matrix-label" title="' + cellLabel + '">' + cellLabel + '</div>';
        html += '<div class="matrix-btns">';
        
        var btns = [
            {code: 'PLUS', label: '+', cls: 'btn-plus'},
            {code: 'STK', label: 'STK', cls: 'btn-stk'},
            {code: 'ZERO', label: '0', cls: 'btn-zero'},
            {code: 'YOK', label: 'YOK', cls: 'btn-yok'},
            {code: 'MINUS', label: '-', cls: 'btn-minus'}
        ];
        
        var valArray = currentValue ? currentValue.split(',') : [];
        for (var j = 0; j < btns.length; j++) {
            var b = btns[j];
            var isActive = (valArray.indexOf(b.code) !== -1);
            html += '<button type="button" class="mbtn ' + b.cls + (isActive ? ' active' : '') + '" data-code="' + b.code + '" onclick="selectMatrixValue(' + cellDefId + ',\'' + b.code + '\',this)">' + b.label + '</button>';
        }
        
        html += '</div></div>';
    }
    
    html += '</div>';
    document.getElementById('matrixContent').innerHTML = html;
}

function selectMatrixValue(cellDefId, valueCode, btn) {
    var isAlreadyActive = btn.classList.contains('active');
    var code = valueCode.toUpperCase();
    
    if (isAlreadyActive) {
        btn.classList.remove('active');
    } else {
        btn.classList.add('active');
    }
    
    var cells = matrixData && (matrixData.cells || matrixData.CELLS);
    if (cells) {
        for (var i = 0; i < cells.length; i++) {
            var cid = cells[i].cell_def_id || cells[i].CELL_DEF_ID;
            if (cid == cellDefId) {
                var currentVal = (cells[i].value_code || cells[i].VALUE_CODE || '');
                var valArray = currentVal ? currentVal.split(',').filter(function(v) { return v.length > 0; }) : [];
                
                if (isAlreadyActive) {
                    valArray = valArray.filter(function(v) { return v !== code; });
                } else {
                    if (valArray.indexOf(code) === -1) {
                        valArray.push(code);
                    }
                }
                
                var newValue = valArray.join(',');
                cells[i].value_code = newValue;
                cells[i].VALUE_CODE = newValue;
                break;
            }
        }
    }
    
    calcMatrixPercent();
}

function resetMatrix() {
    var cells = matrixData && (matrixData.cells || matrixData.CELLS);
    if (!cells) return;
    
    for (var i = 0; i < cells.length; i++) {
        cells[i].value_code = '';
        cells[i].VALUE_CODE = '';
    }
    
    document.querySelectorAll('.matrix-item .mbtn.active').forEach(function(btn) {
        btn.classList.remove('active');
    });
    
    calcMatrixPercent();
}

function calcMatrixPercentValue() {
    var cells = matrixData && (matrixData.cells || matrixData.CELLS);
    if (!cells || cells.length === 0) return 0;
    
    var plusCount = 0;
    var totalWeight = 0;
    
    for (var i = 0; i < cells.length; i++) {
        var cell = cells[i];
        var weight = parseFloat(cell.weight || cell.WEIGHT || 1);
        var vCode = (cell.value_code || cell.VALUE_CODE || '');
        var valArray = vCode ? vCode.split(',') : [];
        
        if (valArray.indexOf('PLUS') !== -1) {
            plusCount += weight;
        }
        totalWeight += weight;
    }
    
    var pct = 0;
    if (totalWeight > 0) {
        pct = (plusCount / totalWeight) * 100;
    }
    return Math.max(0, Math.min(100, pct));
}

function calcMatrixPercent() {
    var pct = calcMatrixPercentValue();
    var percentEl = document.getElementById('matrixPercent');
    if (percentEl) percentEl.textContent = '%' + Math.round(pct);
}

function saveMatrix() {
    var cells = matrixData && (matrixData.cells || matrixData.CELLS);
    if (!cells || cells.length === 0) {
        var pct = parseInt(document.getElementById('matrixPercent').textContent.replace('%', '')) || 0;
        updateOpsTaskPercent(pct);
        return;
    }
    
    // Hücre değerlerini topla (label ile kaydet - daha güvenilir)
    var jsonValues = [];
    for (var i = 0; i < cells.length; i++) {
        var cell = cells[i];
        var cellLabel = cell.cell_label || cell.CELL_LABEL || '';
        var valueCode = (cell.value_code || cell.VALUE_CODE || '').toUpperCase();
        jsonValues.push({cell_label: cellLabel, value_code: valueCode});
    }
    
    // localStorage'a kaydet (sipariş bazlı)
    var valuesKey = 'matrix_values_order_' + matrixRefId + '_task_' + matrixTaskId;
    localStorage.setItem(valuesKey, JSON.stringify(jsonValues));
    console.log('Matris değerleri kaydedildi:', valuesKey, jsonValues);
    
    // Yüzdeyi hesapla ve OPS_TASK'a kaydet
    var pct = calcMatrixPercentValue();
    updateOpsTaskPercent(Math.round(pct));
}

function updateOpsTaskPercent(pct) {
    console.log('Updating OPS_TASK percent:', matrixTaskId, pct);
    
    var fd = new FormData();
    fd.append('action', 'update_percent');
    fd.append('task_id', matrixTaskId);
    fd.append('percent_complete', pct);
    
    // Aşama da hesapla
    var statusId = 2358; // Planlama
    if (pct === 0) statusId = 2359; // İş Atandı
    else if (pct > 0 && pct < 100) statusId = 2361; // Devam Ediyor
    else if (pct >= 100) statusId = 2364; // Tamamlandı
    fd.append('status_id', statusId);
    
    fetch('/V16/sales/query/ajax_ops_task.cfm', {method: 'POST', body: fd})
    .then(function(r) { return r.json(); })
    .then(function(resp) {
        console.log('OPS_TASK update response:', resp);
        
        // Task satırındaki % ve aşamayı güncelle (postback olmadan)
        var pctInput = document.getElementById('order-task-pct-' + matrixTaskId);
        if (pctInput) pctInput.value = pct;
        
        // Aşama dropdown'ını güncelle
        var taskRow = pctInput ? pctInput.closest('tr') : null;
        if (taskRow) {
            var stageSelect = taskRow.querySelector('select');
            if (stageSelect) stageSelect.value = statusId;
        }
        
        // Overlay'i kapat
        var overlay = document.getElementById('taskMatrixOverlay');
        if (overlay) overlay.remove();
    })
    .catch(function(err) {
        console.error('OPS_TASK update error:', err);
        alert('Kaydetme hatası: ' + err.message);
    });
}

// Global scope'a ata (iframe içinde çalışması için)
window.toggleWorkstation = toggleWorkstation;
window.selectAllWorkstations = selectAllWorkstations;
window.saveWorkstationSelection = saveWorkstationSelection;
window.editWorkstations = editWorkstations;
window.resetMatrix = resetMatrix;
window.saveMatrix = saveMatrix;
window.selectMatrixValue = selectMatrixValue;
window.loadMatrixData = loadMatrixData;
</script>
