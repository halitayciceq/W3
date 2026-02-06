<cfsilent>
<cfparam name="url.task_id" default="0">
<cfparam name="url.ref_type" default="ORDER">
<cfparam name="url.ref_id" default="0">
<cfparam name="url.project_id" default="0">
<cfparam name="url.work_id" default="0">

<!--- DSN tanımı --->
<cfif NOT isDefined("dsn")><cfset dsn = "workcube_prod"></cfif>
<cfif NOT isDefined("dsn3")><cfset dsn3 = "workcube_prod_1"></cfif>

<!--- Sipariş'ten project_id al --->
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

<!--- İstasyonları DB'den çek (DIM_TYPE=STAGE) --->
<cfset dbWorkstations = []>
<cfset dbCells = []>
<cftry>
    <cfquery name="qDimStages" datasource="#dsn#">
        SELECT DIM_ID, DIM_CODE, DIM_NAME, SORT_ORDER
        FROM PRJ_TASK_MATRIX_DIM
        WHERE TEMPLATE_ID = (SELECT TEMPLATE_ID FROM PRJ_TASK_MATRIX_TEMPLATE WHERE TEMPLATE_CODE = 'URETIM_SURECI' AND IS_ACTIVE = 1)
        AND DIM_TYPE = 'STAGE'
        AND IS_ACTIVE = 1
        ORDER BY SORT_ORDER
    </cfquery>
    <cfloop query="qDimStages">
        <cfset arrayAppend(dbWorkstations, {
            "workstation_id": DIM_ID,
            "code": DIM_CODE,
            "name": DIM_NAME
        })>
    </cfloop>
    
    <!--- Hücre tanımlarını DB'den çek --->
    <cfquery name="qCellDefs" datasource="#dsn#">
        SELECT cd.CELL_DEF_ID, cd.CELL_LABEL, cd.WEIGHT, cd.STAGE_DIM_ID
        FROM PRJ_TASK_MATRIX_CELL_DEF cd
        WHERE cd.TEMPLATE_ID = (SELECT TEMPLATE_ID FROM PRJ_TASK_MATRIX_TEMPLATE WHERE TEMPLATE_CODE = 'URETIM_SURECI' AND IS_ACTIVE = 1)
        AND cd.IS_ACTIVE = 1
        ORDER BY cd.CELL_DEF_ID
    </cfquery>
    <cfloop query="qCellDefs">
        <cfset arrayAppend(dbCells, {
            "cell_def_id": CELL_DEF_ID,
            "cell_label": CELL_LABEL,
            "weight": WEIGHT,
            "stage_dim_id": STAGE_DIM_ID
        })>
    </cfloop>
<cfcatch>
    <cfset dbError = cfcatch.message & " | " & cfcatch.detail>
</cfcatch>
</cftry>

<cfset wsJSON = serializeJSON(dbWorkstations)>
<cfset cellJSON = serializeJSON(dbCells)>
</cfsilent>
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
.matrix-actions { display: flex; gap: 6px; flex: 1; justify-content: flex-end; }
.btn-ws-edit { padding: 6px 16px; border: none; border-radius: 4px; background: #0d6efd; cursor: pointer; font-size: 12px; color: #fff; font-weight: 500; }
.btn-ws-edit:hover { background: #0b5ed7; }
.btn-reset { padding: 6px 16px; border: 1px solid #ffc107; border-radius: 4px; background: #ffc107; cursor: pointer; font-size: 12px; color: #000; font-weight: 500; }
.btn-reset:hover { background: #ffca2c; }
.btn-close { padding: 6px 16px; border: 1px solid #6c757d; border-radius: 4px; background: #fff; cursor: pointer; font-size: 12px; color: #333; font-weight: 500; margin-left: auto; }
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
.ws-select-list { display: grid; grid-template-columns: repeat(2, 1fr); gap: 8px; max-height: 400px; overflow-y: auto; padding: 4px; align-items: start; }
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
var currentMatrixProjectId = <cfoutput>#val(url.project_id)#</cfoutput>;
var currentMatrixWorkId = <cfoutput>#val(url.work_id)#</cfoutput> || matrixTaskId;
var matrixData = null;
var selectedWorkstations = [];

console.log('Matrix params:', {taskId: matrixTaskId, projectId: currentMatrixProjectId, workId: currentMatrixWorkId});
<cfif isDefined("dbError")>console.error('DB HATA:', '<cfoutput>#jsStringFormat(dbError)#</cfoutput>');</cfif>

// İstasyon grupları ve hücre tanımları (DB'den dinamik)
var allWorkstationGroups = <cfoutput>#wsJSON#</cfoutput>;
var allDefaultCells = (function() {
    var raw = <cfoutput>#cellJSON#</cfoutput>;
    return raw.map(function(c) {
        return {
            cell_def_id: c.cell_def_id || c.CELL_DEF_ID,
            cell_label: c.cell_label || c.CELL_LABEL,
            value_code: '',
            weight: c.weight || c.WEIGHT || 1,
            stage_dim_id: c.stage_dim_id || c.STAGE_DIM_ID
        };
    });
})();
// İstasyon key normalizasyonu
allWorkstationGroups = allWorkstationGroups.map(function(ws) {
    return {
        workstation_id: ws.workstation_id || ws.WORKSTATION_ID,
        code: ws.code || ws.CODE,
        name: ws.name || ws.NAME
    };
});

console.log('allWorkstationGroups:', JSON.stringify(allWorkstationGroups));
console.log('allDefaultCells count:', allDefaultCells.length, 'sample:', allDefaultCells.length > 0 ? JSON.stringify(allDefaultCells[0]) : 'EMPTY');

function getStorageKey(type) {
    return 'matrix_' + type + '_order_' + matrixRefId + '_task_' + matrixTaskId;
}

function getFilteredCells() {
    var filtered = allDefaultCells.filter(function(cell) {
        return selectedWorkstations.some(function(ws) {
            // stage_dim_id ile eşleştir (güvenli), yoksa label ile fallback
            if (cell.stage_dim_id && ws.workstation_id) {
                return parseInt(cell.stage_dim_id) === parseInt(ws.workstation_id);
            }
            return cell.cell_label.indexOf(ws.name) === 0;
        });
    });
    return filtered.map(function(cell) {
        return {cell_def_id: cell.cell_def_id, cell_label: cell.cell_label, value_code: '', weight: cell.weight || 1};
    });
}

function saveCellValuesToStorage() {
    var cells = matrixData && (matrixData.cells || matrixData.CELLS);
    if (cells) {
        var cellValues = {};
        for (var i = 0; i < cells.length; i++) {
            var cid = cells[i].cell_def_id || cells[i].CELL_DEF_ID;
            cellValues[cid] = cells[i].value_code || cells[i].VALUE_CODE || '';
        }
        localStorage.setItem(getStorageKey('cells'), JSON.stringify(cellValues));
    }
}

function loadSavedCellValues(cells) {
    try {
        var saved = localStorage.getItem(getStorageKey('cells'));
        if (saved) {
            var cellValues = JSON.parse(saved);
            for (var i = 0; i < cells.length; i++) {
                var cid = cells[i].cell_def_id || cells[i].CELL_DEF_ID;
                if (cellValues[cid] !== undefined && cellValues[cid] !== '') {
                    cells[i].value_code = cellValues[cid];
                }
            }
        }
    } catch(e) { console.log('loadSavedCellValues hata:', e); }
    return cells;
}

function renderFilteredMatrix() {
    var filteredCells = getFilteredCells();
    filteredCells = loadSavedCellValues(filteredCells);
    matrixData = {cells: filteredCells};
    renderMatrix(matrixData);
    calcMatrixPercent();
}

function initMatrix() {
    var content = document.getElementById('matrixContent');
    if(!content) {
        setTimeout(initMatrix, 50);
        return;
    }
    
    // localStorage'dan seçili istasyonları al
    try {
        var savedWs = localStorage.getItem(getStorageKey('ws'));
        if (savedWs) {
            var parsed = JSON.parse(savedWs);
            if (parsed && parsed.length > 0) {
                selectedWorkstations = parsed;
                renderFilteredMatrix();
                return;
            }
        }
    } catch(e) { console.log('localStorage okuma hatası:', e); }
    
    // İlk açılış → tüm istasyonları seç ve matrisi göster
    selectedWorkstations = allWorkstationGroups.slice();
    localStorage.setItem(getStorageKey('ws'), JSON.stringify(selectedWorkstations));
    renderFilteredMatrix();
}

setTimeout(initMatrix, 10);

function loadMatrixData() {
    var xhr = new XMLHttpRequest();
    xhr.open('GET', '/V16/project/form/ajax_task_matrix.cfm?action=get&project_id=' + currentMatrixProjectId + '&work_id=' + currentMatrixWorkId + '&template_code=URETIM_SURECI', true);
    xhr.withCredentials = true;
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4) {
            if (xhr.status === 200) {
                try {
                    var resp = JSON.parse(xhr.responseText);
                    console.log('Matrix response:', resp);
                    
                    if (resp.success || resp.SUCCESS) {
                        matrixData = resp;
                        var resultType = resp.result_type || resp.RESULT_TYPE || 'MATRIX';
                        
                        if (resultType === 'SELECT_WS') {
                            selectedWorkstations = resp.selected_workstations || [];
                            renderWorkstationSelect(resp.workstations || resp.WORKSTATIONS || [], false);
                        } else {
                            var cells = resp.cells || resp.CELLS || [];
                            if (cells.length > 0) {
                                selectedWorkstations = resp.selected_workstations || [];
                                renderMatrix(resp);
                                calcMatrixPercent();
                            } else {
                                renderDefaultMatrix();
                            }
                        }
                    } else {
                        renderDefaultMatrix();
                    }
                } catch(e) {
                    console.error('JSON parse error:', e);
                    renderDefaultMatrix();
                }
            } else {
                console.error('Matrix AJAX error:', xhr.status);
                renderDefaultMatrix();
            }
        }
    };
    xhr.send();
}

function renderDefaultMatrix() {
    // localStorage'da seçili istasyon varsa filtrelenmiş göster
    try {
        var savedWs = localStorage.getItem(getStorageKey('ws'));
        if (savedWs) {
            var parsed = JSON.parse(savedWs);
            if (parsed && parsed.length > 0) {
                selectedWorkstations = parsed;
                renderFilteredMatrix();
                return;
            }
        }
    } catch(e) {}
    // İlk açılış → tüm istasyonları seç ve matrisi göster
    selectedWorkstations = allWorkstationGroups.slice();
    localStorage.setItem(getStorageKey('ws'), JSON.stringify(selectedWorkstations));
    renderFilteredMatrix();
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
    
    // localStorage'a kaydet
    localStorage.setItem(getStorageKey('ws'), JSON.stringify(selectedWorkstations));
    
    // Filtrelenmiş matrisi render et
    renderFilteredMatrix();
    
    // Butonları geri göster
    document.querySelector('.matrix-title').textContent = 'Üretim Matrisi';
    document.getElementById('matrixPercent').style.display = '';
    document.querySelector('.btn-reset').style.display = '';
    document.querySelector('.btn-save').style.display = '';
    document.querySelector('.btn-ws-edit').style.display = '';
    document.querySelector('.matrix-legend').style.display = '';
}

function editWorkstations() {
    // Hardcoded istasyon listesini göster (mevcut seçimlerle)
    renderWorkstationSelect(allWorkstationGroups, true);
}

function renderMatrix(data) {
    var cells = data.cells || data.CELLS || [];
    
    document.querySelector('.matrix-title').textContent = 'Üretim Matrisi';
    document.getElementById('matrixPercent').style.display = '';
    document.querySelector('.btn-reset').style.display = '';
    document.querySelector('.btn-save').style.display = '';
    document.querySelector('.btn-ws-edit').style.display = '';
    document.querySelector('.matrix-legend').style.display = '';
    
    if (cells.length === 0) {
        document.getElementById('matrixContent').innerHTML = '<div class="matrix-empty">Hücre tanımı yok.</div>';
        return;
    }
    
    var html = '<div class="matrix-grid">';
    
    for (var i = 0; i < cells.length; i++) {
        var cell = cells[i];
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
    saveCellValuesToStorage();
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
    saveCellValuesToStorage();
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
    // Hücre değerlerini localStorage'a kaydet
    saveCellValuesToStorage();
    
    // Frontend'de % hesapla
    var pct = Math.round(calcMatrixPercentValue());
    
    // Hücre değerlerini backend'e kaydet (PRO_WORKS güncellenir)
    var cells = matrixData && (matrixData.cells || matrixData.CELLS);
    if (cells && cells.length > 0 && currentMatrixProjectId > 0) {
        var jsonValues = [];
        for (var i = 0; i < cells.length; i++) {
            var cell = cells[i];
            var cellDefId = cell.cell_def_id || cell.CELL_DEF_ID;
            var valueCode = (cell.value_code || cell.VALUE_CODE || '').toUpperCase();
            jsonValues.push({cell_def_id: cellDefId, value_code: valueCode});
        }
        
        var xhr = new XMLHttpRequest();
        xhr.open('POST', '/V16/project/form/ajax_task_matrix.cfm', true);
        xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        xhr.withCredentials = true;
        xhr.onreadystatechange = function() {
            if (xhr.readyState === 4) {
                if (xhr.status === 200) {
                    try {
                        var resp = JSON.parse(xhr.responseText);
                        console.log('Matrix save response:', resp);
                    } catch(e) { console.error('Matrix save parse error:', e); }
                }
                // Backend kayıt tamamlandıktan sonra OPS_TASK % güncelle
                updateOpsTaskPercent(pct);
            }
        };
        xhr.send('action=save&project_id=' + currentMatrixProjectId + '&work_id=' + currentMatrixWorkId + '&template_code=URETIM_SURECI&json_values=' + encodeURIComponent(JSON.stringify(jsonValues)));
    } else {
        // Backend kaydı yapılamıyorsa sadece OPS_TASK % güncelle
        updateOpsTaskPercent(pct);
    }
}

function updateOpsTaskPercent(pct) {
    // Yüzdeye göre aşama belirle
    var statusId = 2358; // Planlama
    if (pct >= 100) statusId = 2364; // Tamamlandı
    else if (pct > 0) statusId = 2361; // Devam Ediyor
    
    var fd = new FormData();
    fd.append('action', 'update_percent');
    fd.append('task_id', matrixTaskId);
    fd.append('percent_complete', pct);
    fd.append('status_id', statusId);
    fd.append('order_id', matrixRefId);
    
    fetch('/V16/sales/query/ajax_ops_task.cfm', {method: 'POST', body: fd})
    .then(function(r) { return r.json(); })
    .then(function(resp) {
        // Modal kapat
        var overlay = document.getElementById('taskMatrixOverlay');
        if(overlay) overlay.remove();
        
        // Task satırındaki % ve aşamayı güncelle
        try {
            var taskRow = document.querySelector('tr.ops-task-row[data-task-id="' + matrixTaskId + '"]');
            if (taskRow) {
                var pctInput = taskRow.querySelector('input[type="number"]');
                if (pctInput) pctInput.value = pct;
                
                var stageSelect = taskRow.querySelector('select');
                if (stageSelect) {
                    if (pct >= 100) stageSelect.value = '2364';
                    else if (pct > 0) stageSelect.value = '2361';
                }
            }
            
            // Sipariş % güncelle
            var orderPct = resp.order_pct || resp.ORDER_PCT;
            if (orderPct !== undefined && typeof updateOrderPercentUI === 'function') {
                updateOrderPercentUI(matrixRefId, orderPct);
            }
            
            // Proje % güncelle
            var projectPct = resp.project_pct || resp.PROJECT_PCT;
            var projectId = resp.project_id || resp.PROJECT_ID;
            if (projectPct !== undefined && projectId) {
                var projBar = document.getElementById('project-bar-' + projectId);
                var projText = document.getElementById('project-percent-' + projectId);
                if (projBar) projBar.style.width = Math.round(projectPct) + '%';
                if (projText) projText.textContent = Math.round(projectPct) + '%';
            }
        } catch(e) { console.log('UI güncelleme hatası:', e); }
        
        if(typeof OpsTask !== 'undefined') OpsTask.loadList();
    })
    .catch(function(err) {
        console.error('Kayıt hatası:', err);
        var overlay = document.getElementById('taskMatrixOverlay');
        if(overlay) overlay.remove();
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
