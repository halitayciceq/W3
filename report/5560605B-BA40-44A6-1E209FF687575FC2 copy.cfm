<cfprocessingdirective pageEncoding="utf-8">
<!--- Modern Proje ve Operasyon Raporu --->
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Proje ve Operasyon İzleme Raporu</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <script src="https://cdn.tailwindcss.com"></script>
    <script defer src="https://cdn.jsdelivr.net/npm/alpinejs@3.12.0/dist/cdn.min.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    fontFamily: { sans: ['Inter', 'sans-serif'] },
                    colors: {
                        brand: { 
                            50: '#f0f9ff', 100: '#e0f2fe', 200: '#bae6fd', 300: '#7dd3fc', 
                            400: '#38bdf8', 500: '#0ea5e9', 600: '#0284c7', 700: '#0369a1', 
                            800: '#075985', 900: '#0c4a6e' 
                        }
                    },
                    animation: {
                        'fadeIn': 'fadeIn 0.5s ease-in-out',
                        'slideIn': 'slideIn 0.3s ease-out'
                    }
                }
            }
        }
    </script>
    
    <style>
        @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
        @keyframes slideIn { from { transform: translateY(-10px); opacity: 0; } to { transform: translateY(0); opacity: 1; } }
        
        .progress-ring { transition: stroke-dashoffset 0.5s ease-in-out; }
        .glass-effect { backdrop-filter: blur(10px); background: rgba(255, 255, 255, 0.85); }
        .hover-lift:hover { transform: translateY(-2px); box-shadow: 0 8px 25px rgba(0,0,0,0.15); }
    </style>
    
    <script>
        function salesOrdersApp(projectId) {
            return {
                open: false,
                orders: window['projectOrders_' + projectId] || [],
                get orderCount() { return this.orders.length; },
                openPaymentPlan: function(orderId) {
                    openBoxDraggable('index.cfm?fuseaction=objects.popup_payment_with_voucher&is_purchase_=0&payment_process_id=' + orderId + '&str_table=ORDERS');
                },
                printOffer: function(offerId) {
                    window.open('index.cfm?fuseaction=objects.popup_print_files&action=sales.list_offer&action_id=' + offerId + '&print_type=70', '_blank');
                }
            };
        }

        function updateTaskPercent(workId, percent, inputElement) {
            percent = Math.min(100, Math.max(0, parseInt(percent) || 0));
            if (inputElement) {
                inputElement.value = percent;
                inputElement.style.borderColor = '#f59e0b';
            }
            var xhr = new XMLHttpRequest();
            xhr.open('GET', 'V16/project/form/emptypopup_ajax_update_work_progress.cfm?work_id=' + workId + '&to_complete=' + percent, true);
            xhr.withCredentials = true;
            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4) {
                    if (xhr.status === 200) {
                        if (inputElement) inputElement.style.borderColor = '#22c55e';
                        setTimeout(function() { if (inputElement) inputElement.style.borderColor = ''; }, 1500);
                        try {
                            var resp = JSON.parse(xhr.responseText);
                            var projId = resp.project_id || resp.PROJECT_ID;
                            var projComp = resp.project_completion !== undefined ? resp.project_completion : resp.PROJECT_COMPLETION;
                            if (projId && projComp !== undefined) {
                                updateProjectProgressUI(projId, projComp);
                            }
                        } catch(e) {}
                    } else {
                        if (inputElement) inputElement.style.borderColor = '#ef4444';
                    }
                }
            };
            xhr.send();
        }
        
        function updateProjectProgressUI(projectId, completion) {
            var percentSpan = document.getElementById('project-percent-' + projectId);
            var bar = document.getElementById('project-bar-' + projectId);
            if (percentSpan) percentSpan.textContent = completion + '%';
            if (bar) {
                bar.style.width = completion + '%';
                bar.className = 'h-2 rounded-full ' + (completion >= 100 ? 'bg-green-500' : completion >= 75 ? 'bg-blue-500' : completion >= 50 ? 'bg-yellow-500' : 'bg-red-500');
            }
        }
        
        function updateTaskStage(workId, stageId, selectElement) {
            if (!stageId) return;
            var row = selectElement ? selectElement.closest('tr') : null;
            var percentInput = row ? row.querySelector('input[type="number"]') : null;
            var selectedText = selectElement ? selectElement.options[selectElement.selectedIndex].text : '';
            
            var xhr = new XMLHttpRequest();
            xhr.open('GET', 'V16/project/form/emptypopup_ajax_update_work_progress.cfm?work_id=' + workId + '&stage_id=' + stageId, true);
            xhr.withCredentials = true;
            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4 && xhr.status === 200) {
                    try {
                        var resp = JSON.parse(xhr.responseText);
                        var projId = resp.project_id || resp.PROJECT_ID;
                        var projComp = resp.project_completion !== undefined ? resp.project_completion : resp.PROJECT_COMPLETION;
                        var toComplete = resp.to_complete !== undefined ? resp.to_complete : resp.TO_COMPLETE;
                        if (projId && projComp !== undefined) {
                            updateProjectProgressUI(projId, projComp);
                        }
                        if (toComplete !== undefined && percentInput) {
                            percentInput.value = toComplete;
                        }
                    } catch(e) {}
                }
            };
            xhr.send();
        }
        
        function openTaskDocumentModal(workId) {
            var url = 'index.cfm?fuseaction=asset.list_asset&event=add&module=project&module_id=1&action=WORK_ID&action_id=' + workId + '&asset_cat_id=-21&action_type=0';
            var existing = document.getElementById('taskDocOverlay');
            if (existing) existing.remove();
            var overlay = document.createElement('div');
            overlay.id = 'taskDocOverlay';
            overlay.style.cssText = 'position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,0,0.5);z-index:9999;display:flex;align-items:center;justify-content:center;';
            var modal = document.createElement('div');
            modal.style.cssText = 'background:white;width:90%;max-width:900px;height:80%;max-height:700px;border-radius:8px;overflow:hidden;position:relative;box-shadow:0 25px 50px -12px rgba(0,0,0,0.25);display:flex;flex-direction:column;';
            var header = document.createElement('div');
            header.style.cssText = 'background:#3b82f6;color:white;padding:12px 20px;display:flex;justify-content:space-between;align-items:center;flex-shrink:0;';
            header.innerHTML = '<span style="font-weight:600;font-size:14px;">Belge Yukle</span>';
            var closeBtn = document.createElement('button');
            closeBtn.innerHTML = '&times;';
            closeBtn.style.cssText = 'font-size:22px;background:none;border:none;cursor:pointer;color:white;padding:0 8px;line-height:1;';
            closeBtn.onclick = function() { overlay.remove(); };
            header.appendChild(closeBtn);
            var iframeWrapper = document.createElement('div');
            iframeWrapper.style.cssText = 'flex:1;overflow:hidden;position:relative;';
            var iframe = document.createElement('iframe');
            iframe.src = url;
            iframe.style.cssText = 'width:100%;height:calc(100% + 330px);border:none;position:absolute;top:-330px;left:0;';
            iframeWrapper.appendChild(iframe);
            modal.appendChild(header);
            modal.appendChild(iframeWrapper);
            overlay.appendChild(modal);
            document.body.appendChild(overlay);
            overlay.onclick = function(e) { if(e.target === overlay) overlay.remove(); };
        }
        
        // Matris Modal - 4 Sütun Layout + Buton Grubu
        var matrixData = null;
        var matrixValues = null;
        var currentMatrixWorkId = null;
        var currentMatrixProjectId = null;
        var selectedWorkstations = []; // Seçilen istasyonlar
        
        // Skor haritası (frontend hesaplama için) - Sadece PLUS % etkiler
        var scoreMap = {PLUS: 1.00, STK: 0.00, ZERO: 0.00, YOK: 0.00, MINUS: 0.00};
        var maxScore = 1.00;
        
        function openMatrixModal(projectId, workId) {
            currentMatrixProjectId = projectId;
            currentMatrixWorkId = workId;
            
            var existing = document.getElementById('matrixOverlay');
            if (existing) existing.remove();
            
            var overlay = document.createElement('div');
            overlay.id = 'matrixOverlay';
            overlay.className = 'matrix-overlay';
            
            overlay.innerHTML = `
                <div class="matrix-modal">
                    <div class="matrix-header">
                        <div class="matrix-title">
                            <span>Üretim Matrisi</span>
                            <span id="matrixPercent" class="matrix-pct">%0</span>
                        </div>
                        <div class="matrix-actions">
                            <button onclick="editWorkstations()" class="btn-ws-edit" title="İstasyonları düzenle">İstasyonlar</button>
                            <button onclick="resetMatrix()" class="btn-reset" title="Tüm seçimleri sıfırla">Sıfırla</button>
                            <button onclick="document.getElementById('matrixOverlay').remove()" class="btn-close">Kapat</button>
                            <button onclick="saveMatrix()" class="btn-save">Kaydet</button>
                        </div>
                    </div>
                    <div class="matrix-legend">
                        <span class="legend-item"><span class="leg-box leg-yok">YOK</span> Üretim Yok</span>
                        <span class="legend-item"><span class="leg-box leg-minus">-</span> Üretim Tamamlanmadı</span>
                        <span class="legend-item"><span class="leg-box leg-zero">0</span> Üretim Tamamlandı</span>
                        <span class="legend-item"><span class="leg-box leg-stk">S</span> Hazır Stok Kullanılacak</span>
                        <span class="legend-item"><span class="leg-box leg-plus">STD</span> Stokta Yok Ancak Standart Ürün</span>
                    </div>
                    <div id="matrixContent" class="matrix-content">
                        <div class="matrix-loading"><i class="fas fa-spinner fa-spin"></i> Yükleniyor...</div>
                    </div>
                </div>
            `;
            
            document.body.appendChild(overlay);
            overlay.onclick = function(e) { if(e.target === overlay) overlay.remove(); };
            
            loadMatrixData(projectId, workId);
        }
        
        function loadMatrixData(projectId, workId) {
            var xhr = new XMLHttpRequest();
            xhr.open('GET', 'V16/project/form/ajax_task_matrix.cfm?action=get&project_id=' + projectId + '&work_id=' + workId + '&template_code=URETIM_SURECI', true);
            xhr.withCredentials = true;
            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4) {
                    console.log('GET Response status:', xhr.status);
                    
                    if (xhr.status === 200) {
                        try {
                            var resp = JSON.parse(xhr.responseText);
                            console.log('Parsed response:', resp);
                            
                            if (resp.success || resp.SUCCESS) {
                                var resultType = resp.result_type || resp.RESULT_TYPE || 'MATRIX';
                                
                                if (resultType === 'SELECT_WS') {
                                    // İstasyon seçimi gerekli
                                    renderWorkstationSelect(resp.workstations || resp.WORKSTATIONS || []);
                                } else {
                                    // Matris modunda
                                    matrixData = resp;
                                    matrixValues = resp.values || resp.VALUES || [];
                                    
                                    // Seçili istasyonları yükle (düzenleme için)
                                    var selWS = resp.selected_workstations || resp.SELECTED_WORKSTATIONS || [];
                                    selectedWorkstations = selWS.map(function(ws) {
                                        return {
                                            workstation_id: ws.workstation_id || ws.WORKSTATION_ID,
                                            code: ws.code || ws.CODE,
                                            name: ws.name || ws.NAME
                                        };
                                    });
                                    console.log('Loaded selected workstations:', selectedWorkstations.length);
                                    
                                    // Matris instance varsa input'u kilitle
                                    var template = resp.template || resp.TEMPLATE;
                                    if (template && (template.instance_id || template.INSTANCE_ID)) {
                                        var taskInput = document.getElementById('task-percent-' + workId);
                                        if (taskInput) {
                                            taskInput.setAttribute('readonly', 'readonly');
                                            taskInput.setAttribute('data-from-matrix', 'true');
                                            taskInput.style.backgroundColor = '#f0f0f0';
                                            taskInput.title = 'Bu değer matristen hesaplanmaktadır';
                                        }
                                    }
                                    
                                    renderMatrix(resp);
                                    calcMatrixPercent();
                                }
                            } else {
                                document.getElementById('matrixContent').innerHTML = '<div class="matrix-error">Hata: ' + (resp.message || resp.MESSAGE || 'Bilinmeyen') + '</div>';
                            }
                        } catch(e) {
                            console.error('JSON parse error:', e);
                            document.getElementById('matrixContent').innerHTML = '<div class="matrix-error">JSON parse hatası: ' + e.message + '</div>';
                        }
                    }
                }
            };
            xhr.send();
        }
        
        function renderWorkstationSelect(workstations, isEditMode) {
            // Düzenleme modunda mevcut seçimleri koru, değilse sıfırla
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
                
                // Mevcut seçimde var mı kontrol et
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
            
            // Header'ı güncelle
            document.querySelector('.matrix-title span').textContent = isEditMode ? 'İstasyonları Düzenle' : 'İstasyon Seçimi';
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
            
            console.log('Selected workstations:', selectedWorkstations.length);
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
            
            var xhr = new XMLHttpRequest();
            xhr.open('POST', 'V16/project/form/ajax_task_matrix.cfm', true);
            xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
            xhr.withCredentials = true;
            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4 && xhr.status === 200) {
                    try {
                        var resp = JSON.parse(xhr.responseText);
                        console.log('WS Save response:', resp);
                        
                        if (resp.success || resp.SUCCESS) {
                            // İstasyon seçimi kaydedildi, matrisi yükle
                            loadMatrixData(currentMatrixProjectId, currentMatrixWorkId);
                        } else {
                            alert('Hata: ' + (resp.message || resp.MESSAGE));
                        }
                    } catch(e) {
                        console.error('JSON parse error:', e);
                    }
                }
            };
            xhr.send('action=ws_save&project_id=' + currentMatrixProjectId + '&work_id=' + currentMatrixWorkId + '&json_workstations=' + encodeURIComponent(JSON.stringify(selectedWorkstations)));
        }
        
        function editWorkstations() {
            // İstasyon listesini getir ve seçim ekranını göster
            var xhr = new XMLHttpRequest();
            xhr.open('GET', 'V16/project/form/ajax_task_matrix.cfm?action=ws_list&project_id=' + currentMatrixProjectId + '&work_id=' + currentMatrixWorkId, true);
            xhr.withCredentials = true;
            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4 && xhr.status === 200) {
                    try {
                        var resp = JSON.parse(xhr.responseText);
                        if (resp.success || resp.SUCCESS) {
                            renderWorkstationSelect(resp.workstations || resp.WORKSTATIONS || [], true);
                        } else {
                            console.error('WS List error:', resp.message || resp.MESSAGE);
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
            
            // Header'ı matris moduna geri yükle
            document.querySelector('.matrix-title span').textContent = 'Üretim Matrisi';
            document.getElementById('matrixPercent').style.display = '';
            document.querySelector('.btn-reset').style.display = '';
            document.querySelector('.btn-save').style.display = '';
            document.querySelector('.btn-ws-edit').style.display = '';
            document.querySelector('.matrix-legend').style.display = '';
            
            if (cells.length === 0) {
                document.getElementById('matrixContent').innerHTML = '<div class="matrix-empty">Hücre tanımı yok.</div>';
                return;
            }
            
            // Tek container grid - tüm itemlar aynı seviyede
            var html = '<div class="matrix-grid">';
            
            for (var i = 0; i < cells.length; i++) {
                var cell = cells[i];
                var cellDefId = cell.cell_def_id || cell.CELL_DEF_ID;
                var cellLabel = cell.cell_label || cell.CELL_LABEL || 'Hücre ' + (i+1);
                var currentValue = cell.value_code || cell.VALUE_CODE || '';
                
                html += '<div class="matrix-item" data-cell="' + cellDefId + '">';
                html += '<div class="matrix-label" title="' + cellLabel + '">' + cellLabel + '</div>';
                html += '<div class="matrix-btns" role="radiogroup" aria-label="Durum seçimi">';
                
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
                    html += '<button type="button" role="checkbox" aria-pressed="' + isActive + '" ';
                    html += 'class="mbtn ' + b.cls + (isActive ? ' active' : '') + '" ';
                    html += 'data-code="' + b.code + '" ';
                    html += 'onclick="selectMatrixValue(' + cellDefId + ',\'' + b.code + '\',this)">';
                    html += b.label + '</button>';
                }
                
                html += '</div></div>';
            }
            
            html += '</div>';
            document.getElementById('matrixContent').innerHTML = html;
        }
        
        function selectMatrixValue(cellDefId, valueCode, btn) {
            var row = btn.closest('.matrix-item');
            if (!row) return;
            
            var isAlreadyActive = btn.classList.contains('active');
            var code = valueCode.toUpperCase();
            
            // Toggle: Bu butonu aç/kapat (diğerlerini etkilemez)
            if (isAlreadyActive) {
                btn.classList.remove('active');
                btn.setAttribute('aria-pressed', 'false');
            } else {
                btn.classList.add('active');
                btn.setAttribute('aria-pressed', 'true');
            }
            
            // Data güncelle - virgülle ayrılmış değerler
            var cells = matrixData && (matrixData.cells || matrixData.CELLS);
            if (cells) {
                for (var i = 0; i < cells.length; i++) {
                    var cid = cells[i].cell_def_id || cells[i].CELL_DEF_ID;
                    if (cid == cellDefId) {
                        var currentVal = (cells[i].value_code || cells[i].VALUE_CODE || '');
                        var valArray = currentVal ? currentVal.split(',').filter(function(v) { return v.length > 0; }) : [];
                        
                        if (isAlreadyActive) {
                            // Kaldır
                            valArray = valArray.filter(function(v) { return v !== code; });
                        } else {
                            // Ekle (eğer yoksa)
                            if (valArray.indexOf(code) === -1) {
                                valArray.push(code);
                            }
                        }
                        
                        var newValue = valArray.join(',');
                        cells[i].value_code = newValue;
                        cells[i].VALUE_CODE = newValue;
                        console.log('Cell updated:', cid, '->', newValue);
                        break;
                    }
                }
            }
            
            calcMatrixPercent();
        }
        
        function resetMatrix() {
            var cells = matrixData && (matrixData.cells || matrixData.CELLS);
            if (!cells) return;
            
            // Tüm hücrelerin değerlerini sıfırla
            for (var i = 0; i < cells.length; i++) {
                cells[i].value_code = '';
                cells[i].VALUE_CODE = '';
            }
            
            // UI'daki tüm butonları deaktif et
            document.querySelectorAll('.matrix-item .mbtn.active').forEach(function(btn) {
                btn.classList.remove('active');
                btn.setAttribute('aria-pressed', 'false');
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
                
                // Sadece PLUS değeri yüzdeyi etkiler
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
                console.error('matrixData veya cells yok');
                return;
            }
            
            var jsonValues = [];
            for (var i = 0; i < cells.length; i++) {
                var cell = cells[i];
                var cellDefId = cell.cell_def_id || cell.CELL_DEF_ID;
                var valueCode = (cell.value_code || cell.VALUE_CODE || '').toUpperCase();
                // Tüm hücreleri gönder (boş olanlar dahil - sıfırlama için gerekli)
                jsonValues.push({cell_def_id: cellDefId, value_code: valueCode});
            }
            
            console.log('Kaydedilecek değerler:', jsonValues);
            console.log('Toplam hücre:', cells.length, 'Dolu değer:', jsonValues.filter(function(v) { return v.value_code; }).length);
            
            var xhr = new XMLHttpRequest();
            xhr.open('POST', 'V16/project/form/ajax_task_matrix.cfm', true);
            xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
            xhr.withCredentials = true;
            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4) {
                    console.log('Response status:', xhr.status);
                    console.log('Response text:', xhr.responseText);
                    
                    if (xhr.status === 200) {
                        try {
                            var resp = JSON.parse(xhr.responseText);
                            console.log('Save response:', resp);
                            
                            if (resp.success || resp.SUCCESS) {
                                // Frontend'de hesaplanan %'yi kullan
                                var frontendPct = calcMatrixPercentValue();
                                var calcPct = resp.calc_percent || resp.CALC_PERCENT || frontendPct;
                                var projComp = resp.project_completion || resp.PROJECT_COMPLETION;
                                
                                console.log('Updating task-percent-' + currentMatrixWorkId + ' to ' + calcPct);
                                var taskInput = document.getElementById('task-percent-' + currentMatrixWorkId);
                                if (taskInput) {
                                    taskInput.value = Math.round(calcPct);
                                    // Matris değeri geldiğinde input'u kilitle
                                    taskInput.setAttribute('readonly', 'readonly');
                                    taskInput.setAttribute('data-from-matrix', 'true');
                                    taskInput.style.backgroundColor = '#f0f0f0';
                                    taskInput.title = 'Bu değer matristen hesaplanmaktadır';
                                    // Blur event'i tetikle - görev %'sini kaydet
                                    taskInput.dispatchEvent(new Event('blur'));
                                }
                                
                                // Dropdown'u güncelle: %0=boş, %1-99=Başlandı-Devam(2361), %100=Tamamlandı(2364)
                                var allSelects = document.querySelectorAll('select');
                                for(var i = 0; i < allSelects.length; i++) {
                                    var sel = allSelects[i];
                                    var onChangeAttr = sel.getAttribute('onchange') || '';
                                    if(onChangeAttr.indexOf('TaskStage(' + currentMatrixWorkId + ',') > -1 || onChangeAttr.indexOf('TaskStage(' + currentMatrixWorkId + ' ,') > -1) {
                                        var pct = Math.round(calcPct);
                                        if(pct >= 100) {
                                            sel.value = '2364'; // Tamamlandı
                                        } else if(pct > 0) {
                                            sel.value = '2361'; // Başlandı - Devam
                                        } else {
                                            sel.value = ''; // Boş
                                        }
                                        console.log('Dropdown updated to:', sel.value);
                                        break;
                                    }
                                }
                                
                                if (currentMatrixProjectId && projComp !== undefined) {
                                    updateProjectProgressUI(currentMatrixProjectId, projComp);
                                }
                                
                                document.getElementById('matrixOverlay').remove();
                            } else {
                                console.error('Save failed:', resp.message || resp.MESSAGE);
                                alert('Kayıt hatası: ' + (resp.message || resp.MESSAGE));
                            }
                        } catch(e) {
                            console.error('JSON parse error:', e, xhr.responseText);
                            alert('Sunucu yanıt hatası');
                        }
                    } else {
                        console.error('HTTP error:', xhr.status);
                        alert('Sunucu hatası: ' + xhr.status);
                    }
                }
            };
            xhr.send('action=save&project_id=' + currentMatrixProjectId + '&work_id=' + currentMatrixWorkId + '&template_code=URETIM_SURECI&json_values=' + encodeURIComponent(JSON.stringify(jsonValues)));
        }
    </script>
    
    <style>
        /* Matrix Modal Styles */
        .matrix-overlay {
            position: fixed; top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(0,0,0,0.5); z-index: 9999;
            display: flex; align-items: center; justify-content: center;
        }
        .matrix-modal {
            background: #fff; width: 95%; max-width: 900px; max-height: 85vh;
            border-radius: 6px; box-shadow: 0 4px 24px rgba(0,0,0,0.2);
            display: flex; flex-direction: column; overflow: hidden;
        }
        .matrix-header {
            background: #f8f9fa; border-bottom: 1px solid #e0e0e0;
            padding: 12px 16px; display: flex; justify-content: space-between; align-items: center;
        }
        .matrix-title { font-size: 14px; font-weight: 600; color: #333; display: flex; align-items: center; gap: 10px; }
        .matrix-pct { background: #e8f5e9; color: #2e7d32; padding: 3px 10px; border-radius: 12px; font-size: 12px; font-weight: 600; }
        .matrix-actions { display: flex; gap: 8px; }
        .btn-ws-edit { padding: 6px 14px; border: 1px solid #9c27b0; border-radius: 4px; background: #f3e5f5; cursor: pointer; font-size: 12px; color: #7b1fa2; }
        .btn-ws-edit:hover { background: #e1bee7; }
        .btn-reset { padding: 6px 14px; border: 1px solid #ff9800; border-radius: 4px; background: #fff3e0; cursor: pointer; font-size: 12px; color: #e65100; }
        .btn-reset:hover { background: #ffe0b2; }
        .btn-close { padding: 6px 14px; border: 1px solid #ccc; border-radius: 4px; background: #fff; cursor: pointer; font-size: 12px; color: #555; }
        .btn-close:hover { background: #f5f5f5; }
        .btn-save { padding: 6px 14px; border: none; border-radius: 4px; background: #1976d2; color: #fff; cursor: pointer; font-size: 12px; font-weight: 500; }
        .btn-save:hover { background: #1565c0; }
        
        /* Legend - Buton Tanımlamaları */
        .matrix-legend {
            display: flex; flex-wrap: wrap; gap: 12px; padding: 8px 16px;
            background: #f5f5f5; border-bottom: 1px solid #e0e0e0; font-size: 11px;
        }
        .legend-item { display: flex; align-items: center; gap: 4px; color: #555; }
        .leg-box {
            display: inline-flex; align-items: center; justify-content: center;
            min-width: 28px; height: 20px; padding: 0 4px;
            border-radius: 3px; font-size: 9px; font-weight: 600;
        }
        .leg-yok { background: #f5f5f5; border: 1px solid #bdbdbd; color: #757575; }
        .leg-minus { background: #fff3e0; border: 1px solid #ffcc80; color: #e65100; }
        .leg-zero { background: #f5f5f5; border: 1px solid #bdbdbd; color: #616161; }
        .leg-stk { background: #e3f2fd; border: 1px solid #90caf9; color: #1976d2; }
        .leg-plus { background: #e8f5e9; border: 1px solid #a5d6a7; color: #388e3c; }
        
        .matrix-content { flex: 1; overflow: auto; padding: 12px; }
        .matrix-loading, .matrix-empty, .matrix-error { text-align: center; padding: 40px; color: #888; font-size: 13px; }
        .matrix-error { color: #d32f2f; }
        
        /* 2 Kolon Grid Layout */
        .matrix-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 6px;
        }
        @media (max-width: 768px) {
            .matrix-grid { grid-template-columns: 1fr; }
        }
        
        /* Her item: flex row, sabit yükseklik */
        .matrix-item {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 8px;
            padding: 6px 10px;
            background: #fafafa;
            border: 1px solid #e8e8e8;
            border-radius: 4px;
            min-height: 36px;
        }
        .matrix-item:hover { background: #f0f0f0; }
        
        /* Metin: flex-1, min-w-0, line-clamp-2 */
        .matrix-label {
            flex: 1;
            min-width: 0;
            font-size: 11px;
            color: #333;
            line-height: 1.35;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        
        /* Buton grubu: flex-none, sabit genişlik */
        .matrix-btns {
            display: flex;
            gap: 2px;
            flex: none;
        }
        
        /* Buton stilleri - minimal, kurumsal */
        .mbtn {
            width: 28px; height: 24px; border-radius: 3px; font-size: 10px; font-weight: 600;
            cursor: pointer; transition: all 0.15s; border: 1px solid; background: #fff;
        }
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
        
        /* İstasyon Seçimi Stilleri */
        .ws-select-container { padding: 20px; }
        .ws-select-header { font-size: 16px; font-weight: 600; color: #333; margin-bottom: 8px; }
        .ws-select-info { font-size: 12px; color: #666; margin-bottom: 16px; }
        .ws-select-list {
            display: grid; grid-template-columns: repeat(2, 1fr); gap: 8px;
            max-height: 400px; overflow-y: auto; padding: 4px;
        }
        @media (max-width: 600px) { .ws-select-list { grid-template-columns: 1fr; } }
        .ws-item {
            display: flex; align-items: center; gap: 10px;
            padding: 10px 12px; background: #fafafa; border: 1px solid #e0e0e0;
            border-radius: 4px; cursor: pointer; transition: all 0.15s;
        }
        .ws-item:hover { background: #f0f0f0; border-color: #bdbdbd; }
        .ws-item:has(.ws-checkbox:checked) { background: #e3f2fd; border-color: #1976d2; }
        .ws-checkbox { width: 18px; height: 18px; cursor: pointer; accent-color: #1976d2; }
        .ws-name { font-size: 13px; color: #333; flex: 1; }
        .ws-select-actions { display: flex; gap: 12px; margin-top: 20px; justify-content: flex-end; }
        .btn-ws-all {
            padding: 8px 16px; border: 1px solid #1976d2; border-radius: 4px;
            background: #fff; color: #1976d2; cursor: pointer; font-size: 13px;
        }
        .btn-ws-all:hover { background: #e3f2fd; }
        .btn-ws-save {
            padding: 8px 20px; border: none; border-radius: 4px;
            background: #1976d2; color: #fff; cursor: pointer; font-size: 13px; font-weight: 500;
        }
        .btn-ws-save:hover { background: #1565c0; }
    </style>
</head>

<body class="bg-gradient-to-br from-brand-50 via-white to-blue-50 min-h-screen font-sans">


<cfsavecontent variable="title">Modern Proje ve Operasyon Raporu</cfsavecontent>
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.project_no" default="">
<cfparam name="attributes.project_responsible" default="">
<cfparam name="attributes.project_responsible_id" default="">
<cfparam name="attributes.category_id" default="">
<cfparam name="attributes.priority_id" default="">
<cfparam name="attributes.start_date" default="">
<cfparam name="attributes.finish_date" default="">
<cfparam name="attributes.country" default="">
<cfparam name="attributes.page" default=1>
<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>

<cfif isdefined("attributes.start_date") and len(attributes.start_date)>
    <cf_date tarih = "attributes.start_date">
</cfif>
<cfif isdefined("attributes.finish_date") and len(attributes.finish_date)>
    <cf_date tarih = "attributes.finish_date">
</cfif>

<!--- Ana sorgu - Her zaman veri göster --->
<cfif 1 eq 1>
    <cfquery name="GET_PROJECT_OPERATIONS" datasource="#DSN#">
        SELECT 
            P.PROJECT_ID,
            P.PROJECT_NUMBER,
            P.PROJECT_HEAD,
            P.TARGET_START,
            P.TARGET_FINISH,
            -- P.COMPLETE_RATE, -- Kolon mevcut değil
            P.PROJECT_EMP_ID,
            P.PROCESS_CAT,
            P.PRO_PRIORITY_ID,
            P.PRO_CURRENCY_ID,
            P.COMPANY_ID,
            P.CONSUMER_ID,
            
            -- Personel bilgileri
            EMP.EMPLOYEE_NAME,
            EMP.EMPLOYEE_SURNAME,
            
            -- Kategori bilgileri
            SMPC.MAIN_PROCESS_CAT,
            
            -- Öncelik bilgileri
            SP.PRIORITY,
            
            -- Aşama bilgileri
            PTR.STAGE,
            
            -- Müşteri bilgileri (basitleştirilmiş)
            'Müşteri' AS CUSTOMER_NAME,
            
            -- Ülke bilgisi (geçici olarak sabit)
            'TR' AS COUNTRY,
            
            -- Kalan zaman hesaplama (COMPLETE_RATE olmadan)
            CASE 
                WHEN P.TARGET_FINISH > GETDATE()
                THEN DATEDIFF(day, GETDATE(), P.TARGET_FINISH)
                WHEN P.TARGET_FINISH IS NULL
                THEN 999
                ELSE DATEDIFF(day, P.TARGET_FINISH, GETDATE()) * -1
            END AS REMAINING_DAYS,
            
            -- Görev sayısı
            (SELECT COUNT(*) FROM PRO_WORKS PW WHERE PW.PROJECT_ID = P.PROJECT_ID) AS TASK_COUNT,
            
            -- Tamamlanma yüzdesinin ortalaması (0-100 arasında)
            (SELECT 
                CASE 
                    WHEN COUNT(*) > 0 
                    THEN AVG(ISNULL(PW.TO_COMPLETE, 0))
                    ELSE 0 
                END 
             FROM PRO_WORKS PW 
             WHERE PW.PROJECT_ID = P.PROJECT_ID
            ) AS COMPLETION_RATE
            
        FROM 
            PRO_PROJECTS P
            LEFT JOIN EMPLOYEES EMP ON P.PROJECT_EMP_ID = EMP.EMPLOYEE_ID
            LEFT JOIN SETUP_MAIN_PROCESS_CAT SMPC ON P.PROCESS_CAT = SMPC.MAIN_PROCESS_CAT_ID  
            LEFT JOIN SETUP_PRIORITY SP ON P.PRO_PRIORITY_ID = SP.PRIORITY_ID
            LEFT JOIN PROCESS_TYPE_ROWS PTR ON P.PRO_CURRENCY_ID = PTR.PROCESS_ROW_ID
        WHERE 
            1 = 1
            <cfif len(attributes.keyword)>
                AND (P.PROJECT_NUMBER LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.keyword#%">
                     OR P.PROJECT_HEAD LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.keyword#%">)
            </cfif>
            <cfif len(attributes.project_no)>
                AND P.PROJECT_NUMBER LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.project_no#%">
            </cfif>
            <cfif len(attributes.project_responsible_id)>
                AND P.PROJECT_EMP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.project_responsible_id#">
            </cfif>
            <cfif len(attributes.category_id)>
                AND P.PROCESS_CAT = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.category_id#">
            </cfif>
            <cfif len(attributes.priority_id)>
                AND P.PRO_PRIORITY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.priority_id#">
            </cfif>
            <cfif len(attributes.start_date)>
                AND P.TARGET_START >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.start_date#">
            </cfif>
            <cfif len(attributes.finish_date)>
                AND P.TARGET_FINISH <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.finish_date#">
            </cfif>
        ORDER BY 
            P.PROJECT_NUMBER DESC
    </cfquery>
<cfelse>
    <cfset GET_PROJECT_OPERATIONS.recordcount = 0>
</cfif>

<!--- Dropdown sorguları --->
<cfquery name="GET_CATEGORIES" datasource="#DSN#">
    SELECT MAIN_PROCESS_CAT_ID, MAIN_PROCESS_CAT 
    FROM SETUP_MAIN_PROCESS_CAT 
    ORDER BY MAIN_PROCESS_CAT
</cfquery>

<cfquery name="GET_PRIORITIES" datasource="#DSN#">
    SELECT PRIORITY_ID, PRIORITY 
    FROM SETUP_PRIORITY 
    ORDER BY PRIORITY_ID
</cfquery>

<!--- DETAY BLOKLARI İÇİN QUERY'LER --->

<!--- Proje isleri icin surec listesi --->
<cfquery name="GET_WORK_STAGES" datasource="#DSN#">
    SELECT PTR.PROCESS_ROW_ID, PTR.STAGE, PTR.LINE_NUMBER
    FROM PROCESS_TYPE_ROWS PTR
    INNER JOIN PROCESS_TYPE PT ON PTR.PROCESS_ID = PT.PROCESS_ID
    WHERE PT.FACTION LIKE '%project.works%' OR PT.FACTION LIKE '%project.addwork%'
    ORDER BY PTR.LINE_NUMBER
</cfquery>

<!--- A) GÖREVLER - Tüm Görevler (Görevli adı dahil) --->
<cftry>
    <cfquery name="GET_ALL_PROJECT_TASKS" datasource="#DSN#">
        SELECT 
            PW.PROJECT_ID,
            PW.WORK_ID,
            PW.WORK_HEAD,
            PW.TARGET_FINISH,
            PW.TO_COMPLETE,
            ISNULL(PW.ESTIMATED_TIME, 0) AS ESTIMATED_TIME,
            ISNULL((SELECT SUM((ISNULL(TOTAL_TIME_HOUR,0)*60) + ISNULL(TOTAL_TIME_MINUTE,0)) FROM PRO_WORKS_HISTORY WHERE PRO_WORKS_HISTORY.WORK_ID = PW.WORK_ID), 0) AS HARCANAN_DAKIKA,
            COALESCE(E.EMPLOYEE_NAME + ' ' + E.EMPLOYEE_SURNAME, '') AS EMPLOYEE_NAME,
            PW.WORK_CURRENCY_ID
        FROM PRO_WORKS PW
            LEFT JOIN EMPLOYEES E ON PW.PROJECT_EMP_ID = E.EMPLOYEE_ID
        WHERE PW.PROJECT_ID IN (SELECT PROJECT_ID FROM PRO_PROJECTS)
        AND PW.WORK_STATUS = 1
        ORDER BY 
            PW.PROJECT_ID,
            PW.WORK_ID
    </cfquery>
<cfcatch>
    <cfset GET_ALL_PROJECT_TASKS = queryNew("PROJECT_ID,WORK_ID,WORK_HEAD,TARGET_FINISH,TO_COMPLETE,ESTIMATED_TIME,HARCANAN_DAKIKA,EMPLOYEE_NAME,WORK_STAGE")>
</cfcatch>
</cftry>

<!--- Siparisler - Server-side JSON olarak hazirla (Turkce karakter ve eksik alan sorunu icin) --->
<cfset periodYear = "#session.ep.period_id#;#session.ep.period_year#">

<cftry>
    <cfquery name="GET_PROJECT_ORDERS" datasource="#DSN3#">
        SELECT 
            O.ORDER_ID,
            O.ORDER_NUMBER,
            O.ORDER_HEAD,
            O.ORDER_DATE,
            O.SHIP_DATE,
            O.DELIVERDATE,
            O.NETTOTAL,
            O.OTHER_MONEY,
            O.ORDER_STAGE,
            O.SHIP_METHOD,
            O.COUNTRY_ID,
            O.ZONE_ID,
            O.OFFER_ID,
            O.PROJECT_ID,
            O.COMPANY_ID,
            O.CONSUMER_ID,
            O.RECORD_EMP,
            COALESCE(C.NICKNAME, C.FULLNAME, '') AS COMPANY_NAME,
            COALESCE(CON.CONSUMER_NAME + ' ' + CON.CONSUMER_SURNAME, '') AS CONSUMER_NAME,
            COALESCE(E.EMPLOYEE_NAME + ' ' + E.EMPLOYEE_SURNAME, '') AS EMPLOYEE_NAME,
            COALESCE(SM.SHIP_METHOD, '') AS SHIP_METHOD_NAME,
            COALESCE(CT.COUNTRY_NAME, '') AS COUNTRY_NAME,
            COALESCE(SZ.SZ_NAME, '') AS SALES_ZONE_NAME,
            COALESCE(OFR.OFFER_NUMBER, '') AS OFFER_NUMBER,
            COALESCE(O.OTHER_MONEY, 'TL') AS MONEY_NAME,
            COALESCE(PTR.STAGE, '') AS STAGE_NAME
        FROM ORDERS O
            LEFT JOIN #DSN#.COMPANY C ON O.COMPANY_ID = C.COMPANY_ID
            LEFT JOIN #DSN#.CONSUMER CON ON O.CONSUMER_ID = CON.CONSUMER_ID
            LEFT JOIN #DSN#.EMPLOYEES E ON O.RECORD_EMP = E.EMPLOYEE_ID
            LEFT JOIN #DSN#.SHIP_METHOD SM ON O.SHIP_METHOD = SM.SHIP_METHOD_ID
            LEFT JOIN #DSN#.SETUP_COUNTRY CT ON O.COUNTRY_ID = CT.COUNTRY_ID
            LEFT JOIN #DSN#.SALES_ZONES SZ ON O.ZONE_ID = SZ.SZ_ID
            LEFT JOIN OFFER OFR ON O.OFFER_ID = OFR.OFFER_ID
            LEFT JOIN #DSN#.PROCESS_TYPE_ROWS PTR ON O.ORDER_STAGE = PTR.PROCESS_ROW_ID
        WHERE 
            O.ORDER_STATUS = 1
            AND ((O.PURCHASE_SALES = 1 AND O.ORDER_ZONE = 0) OR (O.PURCHASE_SALES = 0 AND O.ORDER_ZONE = 1))
            AND (
                O.PROJECT_ID IN (SELECT PROJECT_ID FROM #DSN#.PRO_PROJECTS)
                OR EXISTS (
                    SELECT 1 FROM ORDER_ROW ORR 
                    WHERE ORR.ORDER_ID = O.ORDER_ID 
                    AND ORR.ROW_PROJECT_ID IN (SELECT PROJECT_ID FROM #DSN#.PRO_PROJECTS)
                )
            )
        ORDER BY O.PROJECT_ID, O.ORDER_DATE DESC
    </cfquery>
    
    <!--- Siparis-Proje iliskisi icin ORDER_ROW bazli proje ID'leri --->
    <cfset orderProjectMap = {}>
    <cfloop query="GET_PROJECT_ORDERS">
        <cfset ordIdKey = toString(ORDER_ID)>
        <cfif NOT structKeyExists(orderProjectMap, ordIdKey)>
            <cfset orderProjectMap[ordIdKey] = []>
        </cfif>
        <cfif len(PROJECT_ID)>
            <cfset projIdStr = toString(PROJECT_ID)>
            <cfif NOT arrayFind(orderProjectMap[ordIdKey], projIdStr)>
                <cfset arrayAppend(orderProjectMap[ordIdKey], projIdStr)>
            </cfif>
        </cfif>
    </cfloop>
    <!--- ORDER_ROW bazli proje iliskilerini de ekle --->
    <cfquery name="GET_ORDER_ROW_PROJECTS" datasource="#DSN3#">
        SELECT DISTINCT ORDER_ID, ROW_PROJECT_ID 
        FROM ORDER_ROW 
        WHERE ROW_PROJECT_ID IN (SELECT PROJECT_ID FROM #DSN#.PRO_PROJECTS)
        AND ORDER_ID IN (SELECT ORDER_ID FROM ORDERS WHERE ORDER_STATUS = 1)
    </cfquery>
    <cfloop query="GET_ORDER_ROW_PROJECTS">
        <cfset ordIdKey = toString(ORDER_ID)>
        <cfif NOT structKeyExists(orderProjectMap, ordIdKey)>
            <cfset orderProjectMap[ordIdKey] = []>
        </cfif>
        <cfif len(ROW_PROJECT_ID)>
            <cfset projIdStr = toString(ROW_PROJECT_ID)>
            <cfif NOT arrayFind(orderProjectMap[ordIdKey], projIdStr)>
                <cfset arrayAppend(orderProjectMap[ordIdKey], projIdStr)>
            </cfif>
        </cfif>
    </cfloop>
    
    <!--- Surec (ORDER_STAGE) lookup - stageMap bos birak, ORDER_STAGE degerini dogrudan kullan --->
    <cfset stageMap = {}>
    
    <!--- Sipariş Tamamlanma Oranları (task ortalaması) - ÖNCE hesapla --->
    <cfset orderCompletionMap = {}>
    <cftry>
        <cfquery name="GET_ORDER_COMPLETION" datasource="#DSN#">
            SELECT REF_ID AS ORDER_ID, AVG(PERCENT_COMPLETE) AS AVG_PCT
            FROM OPS_TASK
            WHERE REF_TYPE = 'ORDER' AND IS_ACTIVE = 1
            GROUP BY REF_ID
        </cfquery>
        <cfloop query="GET_ORDER_COMPLETION">
            <cfset orderCompletionMap[toString(ORDER_ID)] = int(val(AVG_PCT))>
        </cfloop>
    <cfcatch></cfcatch>
    </cftry>
    
    <!--- Proje bazli siparis map olustur --->
    <cfset projectOrdersMap = {}>
    <cfset processedOrders = {}>
    <cfloop query="GET_PROJECT_ORDERS">
        <cfif NOT structKeyExists(processedOrders, ORDER_ID)>
            <cfset processedOrders[ORDER_ID] = true>
            
            <cfset customerName = "">
            <cfif len(COMPANY_NAME)>
                <cfset customerName = COMPANY_NAME>
            <cfelseif len(CONSUMER_NAME)>
                <cfset customerName = CONSUMER_NAME>
            </cfif>
            
            <cfset stageName = STAGE_NAME>
            
            <cfset orderObj = {
                "orderId": ORDER_ID,
                "orderNumber": ORDER_NUMBER,
                "orderHead": ORDER_HEAD,
                "customerName": customerName,
                "orderDate": len(ORDER_DATE) ? dateFormat(ORDER_DATE, "dd.mm.yyyy") : "",
                "shipDate": len(SHIP_DATE) ? dateFormat(SHIP_DATE, "dd.mm.yyyy") : "",
                "deliveryDate": len(DELIVERDATE) ? dateFormat(DELIVERDATE, "dd.mm.yyyy") : "",
                "totalAmount": numberFormat(NETTOTAL, ",.00"),
                "totalAmountRaw": val(NETTOTAL),
                "currency": MONEY_NAME,
                "stage": stageName,
                "shipmentMethod": SHIP_METHOD_NAME,
                "country": COUNTRY_NAME,
                "salesRegion": SALES_ZONE_NAME,
                "offerId": len(OFFER_ID) ? OFFER_ID : "",
                "offerNumber": OFFER_NUMBER,
                "recordedBy": EMPLOYEE_NAME,
                "completionRate": structKeyExists(orderCompletionMap, toString(ORDER_ID)) ? orderCompletionMap[toString(ORDER_ID)] : 0
            }>
            
            <!--- Bu siparisi ilgili tum projelere ekle --->
            <cfset ordIdKey = toString(ORDER_ID)>
            <cfif structKeyExists(orderProjectMap, ordIdKey)>
                <cfloop array="#orderProjectMap[ordIdKey]#" index="projId">
                    <cfif NOT structKeyExists(projectOrdersMap, projId)>
                        <cfset projectOrdersMap[projId] = []>
                    </cfif>
                    <cfset arrayAppend(projectOrdersMap[projId], orderObj)>
                </cfloop>
            </cfif>
        </cfif>
    </cfloop>
<cfcatch type="any">
    <cfset projectOrdersMap = {}>
    <cfset stageMap = {}>
    <!--- DEBUG: Hata olursa goster --->
    <cfoutput><div style="background:red;color:white;padding:10px;">HATA: #cfcatch.message# - #cfcatch.detail#</div></cfoutput>
</cfcatch>
</cftry>

<!--- Sipariş Task'ları --->
<cftry>
    <cfquery name="GET_ORDER_TASKS" datasource="#DSN#">
        SELECT 
            T.TASK_ID,
            T.TASK_HEAD,
            T.REF_ID AS ORDER_ID,
            T.STATUS_ID,
            T.PERCENT_COMPLETE,
            T.DEADLINE,
            T.ESTIMATED_MINUTES,
            T.ACTUAL_MINUTES,
            T.HAS_MATRIX,
            E.EMPLOYEE_NAME + ' ' + E.EMPLOYEE_SURNAME AS EMPLOYEE_NAME
        FROM OPS_TASK T
        LEFT JOIN EMPLOYEES E ON T.ASSIGNED_EMP_ID = E.EMPLOYEE_ID
        WHERE T.REF_TYPE = 'ORDER'
        AND T.IS_ACTIVE = 1
        AND T.REF_ID IN (SELECT ORDER_ID FROM #DSN3#.ORDERS WHERE PROJECT_ID IN 
            (SELECT PROJECT_ID FROM PRO_PROJECTS WHERE COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#">))
        ORDER BY T.REF_ID, T.TASK_ID
    </cfquery>
<cfcatch>
    <cfset GET_ORDER_TASKS = queryNew("TASK_ID,TASK_HEAD,ORDER_ID,STATUS_ID,PERCENT_COMPLETE,DEADLINE,ESTIMATED_MINUTES,ACTUAL_MINUTES,HAS_MATRIX,EMPLOYEE_NAME")>
</cfcatch>
</cftry>

<!--- Task Aşamaları --->
<cfset GET_TASK_STAGES = queryNew("STATUS_ID,STATUS_HEAD")>
<cfset queryAddRow(GET_TASK_STAGES, {STATUS_ID: 2358, STATUS_HEAD: "Planlama"})>
<cfset queryAddRow(GET_TASK_STAGES, {STATUS_ID: 2359, STATUS_HEAD: "İş Atandı"})>
<cfset queryAddRow(GET_TASK_STAGES, {STATUS_ID: 2361, STATUS_HEAD: "Devam Ediyor"})>
<cfset queryAddRow(GET_TASK_STAGES, {STATUS_ID: 2364, STATUS_HEAD: "Tamamlandı"})>
<cfset queryAddRow(GET_TASK_STAGES, {STATUS_ID: 2365, STATUS_HEAD: "Onaylandı"})>

<!--- DEBUG: Query sonuclarini goster --->
<cfif isDefined("GET_PROJECT_ORDERS")>
    <script>console.log('[DEBUG] GET_PROJECT_ORDERS count:', <cfoutput>#GET_PROJECT_ORDERS.recordcount#</cfoutput>);</script>
    <script>console.log('[DEBUG] orderProjectMap keys:', <cfoutput>#serializeJSON(structKeyList(orderProjectMap))#</cfoutput>);</script>
    <script>console.log('[DEBUG] projectOrdersMap keys:', <cfoutput>#serializeJSON(structKeyList(projectOrdersMap))#</cfoutput>);</script>
<cfelse>
    <script>console.log('[DEBUG] GET_PROJECT_ORDERS is NOT defined - query failed');</script>
</cfif>

<cfparam name="attributes.totalrecords" default="#GET_PROJECT_OPERATIONS.recordcount#">

<!-- Main App Container with Alpine.js -->
<div x-data="projectApp()" x-init="init()" class="w-full pt-10">
    
    <!-- Compact Stats Row -->
    <cfset activeCount = 0>
    <cfset overdueCount = 0>
    <cfset completedCount = 0>
    <cfloop query="GET_PROJECT_OPERATIONS">
        <cfif COMPLETION_RATE LT 100 AND REMAINING_DAYS GT 0><cfset activeCount = activeCount + 1></cfif>
        <cfif REMAINING_DAYS LT 0><cfset overdueCount = overdueCount + 1></cfif>
        <cfif COMPLETION_RATE GTE 100><cfset completedCount = completedCount + 1></cfif>
    </cfloop>
    
    <!--- EUR Kuru al --->
    <cfset eurRate = 1>
    <cftry>
        <cfquery name="GET_EUR_RATE" datasource="#DSN#" maxrows="1">
            SELECT RATE FROM CURRENCY_RATES WHERE CURRENCY_CODE = 'EUR' AND RATE_DATE <= GETDATE() ORDER BY RATE_DATE DESC
        </cfquery>
        <cfif GET_EUR_RATE.recordcount>
            <cfset eurRate = val(GET_EUR_RATE.RATE)>
            <cfif eurRate eq 0><cfset eurRate = 38></cfif>
        <cfelse>
            <cfset eurRate = 38>
        </cfif>
    <cfcatch><cfset eurRate = 38></cfcatch>
    </cftry>
    
    <!--- Siparis toplamlarini hesapla (EUR cinsinden) --->
    <cfset totalOrdersEUR = 0>
    <cfset activeOrdersEUR = 0>
    <cfset overdueOrdersEUR = 0>
    <cfset completedOrdersEUR = 0>
    <cfset processedOrderIds = {}>
    
    <cfloop query="GET_PROJECT_OPERATIONS">
        <cfset projIdStr = toString(PROJECT_ID)>
        <cfif structKeyExists(projectOrdersMap, projIdStr)>
            <cfloop array="#projectOrdersMap[projIdStr]#" index="orderItem">
                <cfset orderId = orderItem.orderId>
                <cfif NOT structKeyExists(processedOrderIds, orderId)>
                    <cfset processedOrderIds[orderId] = true>
                    <cfset orderAmount = val(orderItem.totalAmountRaw)>
                    <cfset orderCurrency = orderItem.currency>
                    <!--- TL ise EUR'a cevir --->
                    <cfif orderCurrency eq "TL" OR orderCurrency eq "TRY" OR orderCurrency eq "">
                        <cfset orderAmountEUR = orderAmount / eurRate>
                    <cfelseif orderCurrency eq "USD">
                        <cfset orderAmountEUR = orderAmount * 0.92>
                    <cfelse>
                        <cfset orderAmountEUR = orderAmount>
                    </cfif>
                    <cfset totalOrdersEUR = totalOrdersEUR + orderAmountEUR>
                    <!--- Proje durumuna gore kategorize et --->
                    <cfif COMPLETION_RATE GTE 100>
                        <cfset completedOrdersEUR = completedOrdersEUR + orderAmountEUR>
                    <cfelseif REMAINING_DAYS LT 0>
                        <cfset overdueOrdersEUR = overdueOrdersEUR + orderAmountEUR>
                    <cfelse>
                        <cfset activeOrdersEUR = activeOrdersEUR + orderAmountEUR>
                    </cfif>
                </cfif>
            </cfloop>
        </cfif>
    </cfloop>
    
    <!--- Turk fiyat formati fonksiyonu --->
    <cfset formatTurkishPrice = function(num) {
        var formatted = numberFormat(num, '999999999.00');
        formatted = replace(formatted, ',', '', 'all');
        var parts = listToArray(formatted, '.');
        var intPart = parts[1];
        var decPart = arrayLen(parts) gt 1 ? parts[2] : '00';
        var result = '';
        var len = len(intPart);
        var counter = 0;
        for (var i = len; i gte 1; i = i - 1) {
            counter = counter + 1;
            result = mid(intPart, i, 1) & result;
            if (counter mod 3 eq 0 and i gt 1) {
                result = '.' & result;
            }
        }
        return result & ',' & left(decPart & '00', 2);
    }>
    
    <div class="flex items-center justify-start gap-4 mb-2 flex-wrap">
        <div class="flex items-center gap-2 bg-white rounded px-3 py-2 shadow-sm">
            <i class="fas fa-folder-open text-blue-500"></i>
            <span class="text-gray-600 text-sm">Toplam:</span>
            <span class="font-bold text-gray-800"><cfoutput>#GET_PROJECT_OPERATIONS.recordcount#</cfoutput></span>
        </div>
        <div class="flex items-center gap-2 bg-white rounded px-3 py-2 shadow-sm">
            <i class="fas fa-play-circle text-green-500"></i>
            <span class="text-gray-600 text-sm">Aktif:</span>
            <span class="font-bold text-gray-800"><cfoutput>#activeCount#</cfoutput></span>
        </div>
        <div class="flex items-center gap-2 bg-white rounded px-3 py-2 shadow-sm">
            <i class="fas fa-exclamation-triangle text-red-500"></i>
            <span class="text-gray-600 text-sm">Geciken:</span>
            <span class="font-bold text-red-600"><cfoutput>#overdueCount#</cfoutput></span>
        </div>
        <div class="flex items-center gap-2 bg-white rounded px-3 py-2 shadow-sm">
            <i class="fas fa-check-circle text-green-500"></i>
            <span class="text-gray-600 text-sm">Tamamlanan:</span>
            <span class="font-bold text-green-600"><cfoutput>#completedCount#</cfoutput></span>
        </div>
    </div>
    
    <!--- Siparis Toplamlari - Ayri satir --->
    <div class="flex items-center justify-start gap-4 mb-3 flex-wrap">
        <div class="flex items-center gap-2 bg-green-50 rounded px-3 py-2 shadow-sm border border-green-200">
            <i class="fas fa-euro-sign text-green-600"></i>
            <span class="text-gray-600 text-sm">Aktif:</span>
            <span class="font-bold text-green-700"><cfoutput>#formatTurkishPrice(activeOrdersEUR)# EUR</cfoutput></span>
        </div>
        <div class="flex items-center gap-2 bg-red-50 rounded px-3 py-2 shadow-sm border border-red-200">
            <i class="fas fa-euro-sign text-red-600"></i>
            <span class="text-gray-600 text-sm">Geciken:</span>
            <span class="font-bold text-red-700"><cfoutput>#formatTurkishPrice(overdueOrdersEUR)# EUR</cfoutput></span>
        </div>
        <div class="flex items-center gap-2 bg-emerald-50 rounded px-3 py-2 shadow-sm border border-emerald-200">
            <i class="fas fa-euro-sign text-emerald-600"></i>
            <span class="text-gray-600 text-sm">Tamamlanan:</span>
            <span class="font-bold text-emerald-700"><cfoutput>#formatTurkishPrice(completedOrdersEUR)# EUR</cfoutput></span>
        </div>
        <div class="flex items-center gap-2 bg-blue-50 rounded px-3 py-2 shadow-sm border border-blue-200">
            <i class="fas fa-euro-sign text-blue-600"></i>
            <span class="text-gray-600 text-sm">Genel Toplam:</span>
            <span class="font-bold text-blue-700"><cfoutput>#formatTurkishPrice(totalOrdersEUR)# EUR</cfoutput></span>
        </div>
    </div>

<div class="col col-12">
    <!-- Mini Filters & Search -->
    <form method="post" action="<cfoutput>#request.self#?fuseaction=report.detail_report&event=det&report_id=9</cfoutput>" class="bg-white rounded-lg shadow-sm p-3 mb-4">
        <input type="hidden" name="is_form_submitted" value="1">
        <div class="flex flex-wrap items-center gap-2">
            <div class="flex-1 min-w-48">
                <div class="relative">
                    <i class="fas fa-search absolute left-2 top-1/2 transform -translate-y-1/2 text-gray-400 text-xs"></i>
                    <input 
                        type="text" 
                        name="keyword"
                        placeholder="Proje No / Adı Ara..."
                        value="<cfoutput>#attributes.keyword#</cfoutput>"
                        class="w-full pl-7 pr-3 py-2 text-sm border border-gray-200 rounded-lg focus:border-blue-500 focus:outline-none">
                </div>
            </div>
            
            <select name="category_id" class="px-3 py-2 text-sm border border-gray-200 rounded-lg focus:border-blue-500 focus:outline-none">
                <option value="">Tüm Kategoriler</option>
                <cfloop query="GET_CATEGORIES">
                <option value="<cfoutput>#MAIN_PROCESS_CAT_ID#</cfoutput>"<cfif attributes.category_id eq MAIN_PROCESS_CAT_ID> selected</cfif>><cfoutput>#MAIN_PROCESS_CAT#</cfoutput></option>
                </cfloop>
            </select>

            <select name="priority_id" class="px-3 py-2 text-sm border border-gray-200 rounded-lg focus:border-blue-500 focus:outline-none">
                <option value="">Tüm Öncelikler</option>
                <cfloop query="GET_PRIORITIES">
                <option value="<cfoutput>#PRIORITY_ID#</cfoutput>"<cfif attributes.priority_id eq PRIORITY_ID> selected</cfif>><cfoutput>#PRIORITY#</cfoutput></option>
                </cfloop>
            </select>

            <button type="submit" class="bg-blue-500 hover:bg-blue-600 text-white px-3 py-2 text-sm rounded-lg font-medium transition-colors">
                <i class="fas fa-search mr-1"></i>Ara
            </button>

            <button type="button" onclick="exportExcel()" class="bg-green-500 hover:bg-green-600 text-white px-3 py-2 text-sm rounded-lg font-medium transition-colors">
                <i class="fas fa-download mr-1"></i>Excel
            </button>
        </div>
    </form>

    <!-- Hidden Legacy Form -->
    <div style="display: none;">
    <cf_box>
        <cfform name="search_form" id="search_form" method="post" action="#request.self#?fuseaction=report.detail_report&event=det&report_id=9">
            <input type="hidden" name="is_form_submitted" id="is_form_submitted" value="1">
            <cf_box_search>
                <div class="form-group" id="item-keyword">
                    <cfinput type="text" placeholder="Proje No / Proje Adı Filtresi" name="keyword" id="keyword" value="#attributes.keyword#">
                </div>
                <div class="form-group" id="item-project_responsible">
                    <div class="input-group">
                        <input type="text" name="project_responsible" id="project_responsible" value="<cfif len(attributes.project_responsible)><cfoutput>#attributes.project_responsible#</cfoutput></cfif>" placeholder="Proje Sorumlusu" onFocus="AutoComplete_Create('project_responsible','EMPLOYEE_NAME,EMPLOYEE_SURNAME','EMPLOYEE_NAME,EMPLOYEE_SURNAME','get_emp_autocomplete','0','EMPLOYEE_ID','project_responsible_id','','3','200');" readonly>
                        <span class="input-group-addon icon-ellipsis btnPointer" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_positions&field_emp_id=search_form.project_responsible_id&field_name=search_form.project_responsible&select_list=1');"></span>
                        <input type="hidden" name="project_responsible_id" id="project_responsible_id" value="<cfoutput>#attributes.project_responsible_id#</cfoutput>">
                    </div>
                </div>
                <div class="form-group small">
                    <cfinput type="text" name="maxrows" id="maxrows" value="#attributes.maxrows#" required="yes" validate="integer" range="1,999" message="Kayıt Sayısı Hatalı!" maxlength="3">
                </div>
                <div class="form-group">
                    <cf_wrk_search_button search_function='' button_type="4">
                </div>
            </cf_box_search>
            <cf_box_search_detail>
                <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
                    <div class="form-group" id="item-category_id">
                        <label>Kategori</label>
                        <select name="category_id" id="category_id">
                            <option value="">Seçiniz</option>
                            <cfoutput query="GET_CATEGORIES">
                                <option value="#MAIN_PROCESS_CAT_ID#" <cfif attributes.category_id eq MAIN_PROCESS_CAT_ID>selected</cfif>>#MAIN_PROCESS_CAT#</option>
                            </cfoutput>
                        </select>
                    </div>
                    <div class="form-group" id="item-priority_id">
                        <label>Öncelik</label>
                        <select name="priority_id" id="priority_id">
                            <option value="">Seçiniz</option>
                            <cfoutput query="GET_PRIORITIES">
                                <option value="#PRIORITY_ID#" <cfif attributes.priority_id eq PRIORITY_ID>selected</cfif>>#PRIORITY#</option>
                            </cfoutput>
                        </select>
                    </div>
                </div>
                <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="2" sort="true">
                    <div class="form-group" id="item-start_date">
                        <label>Başlangıç Tarihi</label>
                        <div class="input-group">
                            <cfinput type="text" name="start_date" id="start_date" value="#dateformat(attributes.start_date,dateformat_style)#" validate="#validate_style#" message="Lütfen Tarih Değerini Kontrol Ediniz!" maxlength="10">
                            <span class="input-group-addon"><cf_wrk_date_image date_field="start_date"></span>
                        </div>
                    </div>
                    <div class="form-group" id="item-finish_date">
                        <label>Bitiş Tarihi</label>
                        <div class="input-group">
                            <cfinput type="text" name="finish_date" id="finish_date" value="#dateformat(attributes.finish_date,dateformat_style)#" validate="#validate_style#" message="Lütfen Tarih Değerini Kontrol Ediniz!" maxlength="10">
                            <span class="input-group-addon"><cf_wrk_date_image date_field="finish_date"></span>
                        </div>
                    </div>
                </div>
            </cf_box_search_detail>
        </cfform>
    </cf_box>
    </div>
    
    <!-- Modern Project Table -->
    <div class="bg-white rounded-lg shadow-lg overflow-hidden">
        <div class="overflow-x-auto">
            <table class="w-full">
                <!-- Table Header -->
                <thead class="bg-gray-50 border-b border-gray-200">
                    <tr>
                        <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">No</th>
                        <th class="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">Detay</th>
                        <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Proje No</th>
                        <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Proje Adı</th>
                        <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Ülke</th>
                        <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Sorumlu</th>
                        <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Kategori</th>
                        <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Öncelik</th>
                        <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Başlangıç</th>
                        <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Bitiş</th>
                        <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Kalan Zaman</th>
                        <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Tamamlanma</th>
                    </tr>
                </thead>
                
                <!-- Table Body -->
                    <cfif GET_PROJECT_OPERATIONS.recordcount gt 0>
                        <cfoutput query="GET_PROJECT_OPERATIONS">
                            <tbody x-data="{ showDetails: false }" class="bg-white divide-y divide-gray-200">
                            <tr class="hover:bg-gray-50 transition-colors duration-200">
                                <!-- No -->
                                <td class="px-4 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                                    #currentrow#
                                </td>
                                
                                <!-- Detay Butonu -->
                                <td class="px-4 py-4 whitespace-nowrap text-center">
                                    <button @click="showDetails = !showDetails" 
                                            class="inline-flex items-center justify-center w-8 h-8 rounded-full transition-colors"
                                            :class="showDetails ? 'bg-blue-500 text-white' : 'bg-gray-100 text-gray-600 hover:bg-blue-100'">
                                        <i class="fas" :class="showDetails ? 'fa-chevron-up' : 'fa-chevron-down'"></i>
                                    </button>
                                </td>
                                
                                <!-- Proje No -->
                                <td class="px-4 py-4 whitespace-nowrap text-sm font-medium">
                                    <a href="#request.self#?fuseaction=project.projects&event=det&id=#PROJECT_ID#" 
                                       class="text-blue-600 hover:text-blue-800 hover:underline transition-colors">
                                        #PROJECT_NUMBER#
                                    </a>
                                </td>
                                
                                <!-- Proje Adı -->
                                <td class="px-4 py-4 text-sm text-gray-900 max-w-xs">
                                    <a href="#request.self#?fuseaction=project.projects&event=det&id=#PROJECT_ID#" class="font-medium text-gray-900 hover:text-blue-600">
                                        #PROJECT_HEAD#
                                    </a>
                                </td>
                                
                                <!-- Ülke -->
                                <td class="px-4 py-4 whitespace-nowrap text-sm text-gray-900">
                                    <div class="flex items-center">
                                        <i class="fas fa-flag text-gray-400 mr-2"></i>
                                        #COUNTRY#
                                    </div>
                                </td>
                                
                                <!-- Sorumlu -->
                                <td class="px-4 py-4 whitespace-nowrap text-sm text-gray-900">
                                    <div class="flex items-center">
                                        <div class="w-8 h-8 bg-gradient-to-r from-blue-500 to-purple-600 rounded-full flex items-center justify-center text-white text-xs font-semibold mr-3">
                                            #left(EMPLOYEE_NAME, 1)##left(EMPLOYEE_SURNAME, 1)#
                                        </div>
                                        <div>
                                            <div class="text-sm font-medium text-gray-900">#trim(EMPLOYEE_NAME & ' ' & EMPLOYEE_SURNAME)#</div>
                                        </div>
                                    </div>
                                </td>
                                
                                <!-- Kategori -->
                                <td class="px-4 py-4 whitespace-nowrap text-sm text-gray-900">
                                    <span class="px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-blue-100 text-blue-800">
                                        #MAIN_PROCESS_CAT#
                                    </span>
                                </td>
                                
                                <!-- Öncelik -->
                                <td class="px-4 py-4 whitespace-nowrap text-sm text-gray-900">
                                    <span class="px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full 
                                        <cfif PRIORITY eq 'Yüksek'>bg-red-100 text-red-800
                                        <cfelseif PRIORITY eq 'Orta'>bg-yellow-100 text-yellow-800
                                        <cfelse>bg-gray-100 text-gray-800</cfif>">
                                        #PRIORITY#
                                    </span>
                                </td>
                                
                                <!-- Başlangıç -->
                                <td class="px-4 py-4 whitespace-nowrap text-sm text-gray-900">
                                    #dateformat(TARGET_START, 'dd/mm/yyyy')#
                                </td>
                                
                                <!-- Bitiş -->
                                <td class="px-4 py-4 whitespace-nowrap text-sm text-gray-900">
                                    #dateformat(TARGET_FINISH, 'dd/mm/yyyy')#
                                </td>
                                
                                <!-- Kalan Zaman -->
                                <td class="px-4 py-4 whitespace-nowrap text-sm">
                                    <span class="<cfif REMAINING_DAYS lt 0>text-red-600 font-semibold<cfelse>text-gray-900</cfif>">
                                        #REMAINING_DAYS# gün
                                    </span>
                                </td>
                                
                                <!-- Tamamlanma -->
                                <td class="px-4 py-4 whitespace-nowrap text-sm text-gray-900">
                                    <div class="flex items-center" id="project-progress-#PROJECT_ID#">
                                        <div class="w-full bg-gray-200 rounded-full h-2 mr-2">
                                            <div id="project-bar-#PROJECT_ID#" class="h-2 rounded-full <cfif int(COMPLETION_RATE) gte 100>bg-green-500<cfelseif int(COMPLETION_RATE) gte 75>bg-blue-500<cfelseif int(COMPLETION_RATE) gte 50>bg-yellow-500<cfelse>bg-red-500</cfif>" 
                                                 style="width: #int(COMPLETION_RATE)#%"></div>
                                        </div>
                                        <span id="project-percent-#PROJECT_ID#" class="text-sm font-medium text-gray-900">#int(COMPLETION_RATE)#%</span>
                                    </div>
                                </td>
                            </tr>
                            
                            <!-- Expandable Details Row - Full Width Accordion Layout -->
                            <tr x-show="showDetails" x-collapse class="bg-gray-50">
                                <td colspan="12" class="p-0">
                                    <div class="w-full" style="display:flex; flex-direction:column; gap:0;">
                                        
                                        <!--- ACCORDION 1: SATIS SIPARISLERI (Server-side JSON - Proje bazli) --->
                                        <cfset currentProjectOrders = []>
                                        <cfset projectIdStr = toString(PROJECT_ID)>
                                        <cfif structKeyExists(projectOrdersMap, projectIdStr)>
                                            <cfset currentProjectOrders = projectOrdersMap[projectIdStr]>
                                        <cfelseif structKeyExists(projectOrdersMap, PROJECT_ID)>
                                            <cfset currentProjectOrders = projectOrdersMap[PROJECT_ID]>
                                        </cfif>
                                        <cfset ordersJson = serializeJSON(currentProjectOrders)>
                                        <cfset ordersJson = replace(ordersJson, "'", "\'", "all")>
                                        <script>window['projectOrders_#PROJECT_ID#'] = #ordersJson#;</script>
                                        <div x-data="salesOrdersApp('#PROJECT_ID#')" class="border-b border-gray-200">
                                            <button @click="open = !open" class="w-full flex items-center justify-between px-4 py-3 bg-gray-100 hover:bg-gray-200 transition-colors">
                                                <span class="text-sm font-bold text-gray-800 uppercase flex items-center">
                                                    <i class="fas fa-shopping-cart mr-2"></i>Satis Siparisleri
                                                    <span class="ml-2 bg-gray-600 text-white text-xs px-2 py-0.5 rounded-full" x-text="orderCount"></span>
                                                </span>
                                                <i :class="open ? 'fa-chevron-up' : 'fa-chevron-down'" class="fas text-gray-600"></i>
                                            </button>
                                            <div x-show="open" x-collapse class="bg-white">
                                                <div class="p-3 overflow-x-auto">
                                                    <!-- Data Table -->
                                                    <table class="w-full text-xs min-w-[1400px]">
                                                        <thead>
                                                            <tr class="text-gray-700 bg-gray-100">
                                                                <th class="py-2 px-2 text-center font-semibold" width="40"></th>
                                                                <th class="py-2 px-2 text-left font-semibold">Belge No</th>
                                                                <th class="py-2 px-2 text-left font-semibold">Cari Hesap</th>
                                                                <th class="py-2 px-2 text-left font-semibold">Tarih</th>
                                                                <th class="py-2 px-2 text-left font-semibold">Sevk</th>
                                                                <th class="py-2 px-2 text-left font-semibold">Teslim</th>
                                                                <th class="py-2 px-2 text-center font-semibold">%</th>
                                                                <th class="py-2 px-2 text-right font-semibold">Tutar</th>
                                                                <th class="py-2 px-2 text-left font-semibold">Surec</th>
                                                                <th class="py-2 px-2 text-left font-semibold">Sevk Y.</th>
                                                                <th class="py-2 px-2 text-left font-semibold">Ulke</th>
                                                                <th class="py-2 px-2 text-left font-semibold">Satis Bolgesi</th>
                                                                <th class="py-2 px-2 text-left font-semibold">Teklif</th>
                                                                <th class="py-2 px-2 text-center font-semibold">Islemler</th>
                                                            </tr>
                                                        </thead>
                                                        <tbody>
                                                            <template x-for="order in orders" :key="order.orderId">
                                                                <tr class="border-t border-gray-200 hover:bg-gray-50">
                                                                    <td class="py-2 px-2 text-center">
                                                                        <button onclick="toggleOrderTasks(this.getAttribute('data-order-id'), this)" 
                                                                                :data-order-id="order.orderId"
                                                                                class="w-6 h-6 rounded-full transition-colors text-xs bg-gray-200 text-gray-600 hover:bg-teal-100"
                                                                                title="Görevleri Göster/Gizle">
                                                                            <i class="fas fa-chevron-down"></i>
                                                                        </button>
                                                                    </td>
                                                                    <td class="py-2 px-2 text-blue-700 font-medium">
                                                                        <a :href="'#request.self#?fuseaction=sales.list_order&event=upd&order_id=' + order.orderId" target="_blank" class="hover:underline" x-text="order.orderNumber"></a>
                                                                    </td>
                                                                    <td class="py-2 px-2 text-gray-600 max-w-[150px] truncate" x-text="order.customerName" :title="order.customerName"></td>
                                                                    <td class="py-2 px-2 text-gray-600 whitespace-nowrap" x-text="order.orderDate"></td>
                                                                    <td class="py-2 px-2 text-gray-600 whitespace-nowrap" x-text="order.shipDate"></td>
                                                                    <td class="py-2 px-2 text-gray-600 whitespace-nowrap" x-text="order.deliveryDate"></td>
                                                                    <td class="py-2 px-2 text-center">
                                                                        <div class="flex items-center justify-center gap-1">
                                                                            <div class="w-12 h-2 bg-gray-200 rounded-full overflow-hidden">
                                                                                <div class="h-full bg-teal-500 rounded-full" :style="'width:' + (order.completionRate || 0) + '%'"></div>
                                                                            </div>
                                                                            <span class="text-xs text-gray-600" x-text="(order.completionRate || 0) + '%'"></span>
                                                                        </div>
                                                                    </td>
                                                                    <td class="py-2 px-2 text-right text-gray-700 whitespace-nowrap">
                                                                        <span x-text="order.totalAmount"></span>
                                                                        <span x-show="order.currency" class="ml-1 text-gray-500" x-text="order.currency"></span>
                                                                    </td>
                                                                    <td class="py-2 px-2 text-gray-600" x-text="order.stage || '-'"></td>
                                                                    <td class="py-2 px-2 text-gray-600" x-text="order.shipmentMethod || '-'"></td>
                                                                    <td class="py-2 px-2 text-gray-600" x-text="order.country || '-'"></td>
                                                                    <td class="py-2 px-2 text-gray-600" x-text="order.salesRegion || '-'"></td>
                                                                    <td class="py-2 px-2 text-gray-600">
                                                                        <template x-if="order.offerId && order.offerNumber">
                                                                            <span>
                                                                                <span class="mr-1" x-text="order.offerNumber"></span>
                                                                                <button @click="printOffer(order.offerId)" class="text-gray-500 hover:text-gray-700" title="Teklif Yazdir">
                                                                                    <i class="fas fa-print"></i>
                                                                                </button>
                                                                            </span>
                                                                        </template>
                                                                        <template x-if="!order.offerId || !order.offerNumber">
                                                                            <span class="text-gray-400">-</span>
                                                                        </template>
                                                                    </td>
                                                                    <td class="py-2 px-2 text-center">
                                                                        <button @click="openPaymentPlan(order.orderId)" 
                                                                                class="text-xs bg-gray-500 hover:bg-gray-600 text-white px-2 py-1 rounded transition-colors" title="Odeme Plani">
                                                                            <i class="fas fa-credit-card mr-1"></i>Odeme
                                                                        </button>
                                                                    </td>
                                                                </tr>
                                                            </template>
                                                            <!--- Sipariş Task Listesi (W3 Stili) --->
                                                            <cfloop query="GET_PROJECT_ORDERS">
                                                                <cfset orderId = GET_PROJECT_ORDERS.ORDER_ID>
                                                                <tr id="order-tasks-#orderId#" style="display:none;" class="bg-gray-50">
                                                                    <td colspan="13" class="p-0">
                                                                        <div class="p-4 overflow-x-auto">
                                                                            <table class="ui-table-list ui-form form_list" border="1" style="width:100%;">
                                                                                <thead>
                                                                                    <tr>
                                                                                        <th width="16" style="text-align:center"><i class="fa fa-bars" style="font-size:10px" title="Sürükle-Bırak"></i></th>
                                                                                        <th width="30" style="text-align:center">A</th>
                                                                                        <th width="220" style="text-align:left">Başlık</th>
                                                                                        <th width="90" style="text-align:center">Aşama</th>
                                                                                        <th width="80" style="text-align:center">Termin</th>
                                                                                        <th width="70" style="text-align:center">Öngörülen</th>
                                                                                        <th width="70" style="text-align:center">Harcanan</th>
                                                                                        <th width="40" style="text-align:center">%</th>
                                                                                        <th width="20"><i class="fa fa-pencil" title="Düzenle"></i></th>
                                                                                        <th width="20"><i class="fa fa-file" title="Dosya"></i></th>
                                                                                        <th width="20"><i class="fa fa-th" title="Matris"></i></th>
                                                                                        <th width="20"><i class="fa fa-plus" title="Ekle"></i></th>
                                                                                    </tr>
                                                                                </thead>
                                                                                <tbody>
                                                                                    <cfset taskIdx = 0>
                                                                                    <cfloop query="GET_ORDER_TASKS">
                                                                                        <cfif GET_ORDER_TASKS.ORDER_ID eq orderId>
                                                                                            <cfset taskIdx = taskIdx + 1>
                                                                                            <cfset isProductionTask = (findNoCase("ÜRETİM", TASK_HEAD) gt 0 AND HAS_MATRIX eq 1) ? true : false>
                                                                                            <tr class="ops-task-row" draggable="true" data-task-id="#TASK_ID#">
                                                                                                <td style="text-align:center;cursor:move;" class="drag-handle"><i class="fa fa-bars" style="font-size:10px;color:##999;"></i></td>
                                                                                                <td style="text-align:center"><img class="img-circle" src="images/male.jpg" style="width:28px;height:28px;border-radius:50%;" title="#EMPLOYEE_NAME#"></td>
                                                                                                <td style="text-align:left"><a href="#request.self#?fuseaction=sales.ops_task&event=det&task_id=#TASK_ID#" target="_blank">#TASK_HEAD#</a></td>
                                                                                                <td style="text-align:center"><cfif isProductionTask><select class="pkg-select-inline" disabled style="background:##f3f4f6;cursor:not-allowed;"><option value="">Seçiniz...</option><cfloop query="GET_TASK_STAGES"><option value="#GET_TASK_STAGES.STATUS_ID#" <cfif val(GET_ORDER_TASKS.STATUS_ID) eq GET_TASK_STAGES.STATUS_ID>selected</cfif>>#GET_TASK_STAGES.STATUS_HEAD#</option></cfloop></select><cfelse><select class="pkg-select-inline" onchange="updateOrderTaskStage(#TASK_ID#, this.value, this, false)"><option value="">Seçiniz...</option><cfloop query="GET_TASK_STAGES"><option value="#GET_TASK_STAGES.STATUS_ID#" <cfif val(GET_ORDER_TASKS.STATUS_ID) eq GET_TASK_STAGES.STATUS_ID>selected</cfif>>#GET_TASK_STAGES.STATUS_HEAD#</option></cfloop></select></cfif></td>
                                                                                                <td style="text-align:center"><cfif isDate(DEADLINE)>#dateformat(DEADLINE, 'dd.mm.yyyy')#</cfif></td>
                                                                                                <td style="text-align:center">#int(val(ESTIMATED_MINUTES)/60)# Saat #val(ESTIMATED_MINUTES) mod 60# Dk</td>
                                                                                                <td style="text-align:center">#int(val(ACTUAL_MINUTES)/60)# Saat #val(ACTUAL_MINUTES) mod 60# Dk</td>
                                                                                                <td style="text-align:center"><cfif isProductionTask><input type="number" min="0" max="100" value="#int(PERCENT_COMPLETE)#" style="width:50px;padding:4px 6px;text-align:center;border:1px solid ##d1d5db;border-radius:4px;background:##f3f4f6;cursor:not-allowed;font-size:12px;" readonly><cfelse><input type="number" min="0" max="100" value="#int(PERCENT_COMPLETE)#" style="width:50px;padding:4px 6px;text-align:center;border:1px solid ##14b8a6;border-radius:4px;background:##fff;font-size:12px;" onblur="updateOrderTaskPercent(#TASK_ID#, this.value, this, false)"></cfif></td>
                                                                                                <td style="text-align:center"><a href="javascript:void(0)" onclick="openOrderTaskEdit(#TASK_ID#)" title="Düzenle"><i class="fa fa-pencil" style="color:grey"></i></a></td>
                                                                                                <td style="text-align:center"><a href="javascript:void(0)" onclick="openOrderTaskDocumentModal(#TASK_ID#)" title="Dosya"><i class="fa fa-file" style="color:grey"></i></a></td>
                                                                                                <td style="text-align:center"><cfif HAS_MATRIX eq 1><a href="javascript:void(0)" onclick="openOrderTaskMatrix(#orderId#, #TASK_ID#)" title="Matris"><i class="fa fa-th" style="color:##16a34a"></i></a><cfelse><i class="fa fa-th" style="color:##ccc"></i></cfif></td>
                                                                                                <td style="text-align:center"><a href="javascript:void(0)" onclick="addOrderTask(#orderId#)" title="Görev Ekle"><i class="fa fa-plus" style="color:grey"></i></a></td>
                                                                                            </tr>
                                                                                        </cfif>
                                                                                    </cfloop>
                                                                                    <cfif taskIdx eq 0>
                                                                                        <tr><td colspan="12" style="text-align:center;padding:20px;">Görev bulunamadı - <a href="javascript:void(0)" onclick="addOrderTask(#orderId#)" style="color:##14b8a6;">Görev Ekle</a></td></tr>
                                                                                    </cfif>
                                                                                </tbody>
                                                                            </table>
                                                                        </div>
                                                                    </td>
                                                                </tr>
                                                            </cfloop>
                                                            <tr x-show="orders.length === 0">
                                                                <td colspan="13" class="py-4 text-center text-gray-400">Kayit bulunamadi</td>
                                                            </tr>
                                                        </tbody>
                                                    </table>
                                                </div>
                                            </div>
                                        </div>
                                        
                                        <!--- ACCORDION 2: GÖREVLER (Mavi Ton) --->
                                        <div x-data="{ open: false }" class="border-b border-gray-200">
                                            <button @click="open = !open" class="w-full flex items-center justify-between px-4 py-3 bg-blue-100 hover:bg-blue-200 transition-colors">
                                                <span class="text-sm font-bold text-blue-800 uppercase flex items-center">
                                                    <i class="fas fa-tasks mr-2"></i>Görevler (Operasyonlar)
                                                    <cfset taskCount = 0><cfloop query="GET_ALL_PROJECT_TASKS"><cfif GET_ALL_PROJECT_TASKS.PROJECT_ID eq GET_PROJECT_OPERATIONS.PROJECT_ID><cfset taskCount = taskCount + 1></cfif></cfloop>
                                                    <span class="ml-2 bg-blue-600 text-white text-xs px-2 py-0.5 rounded-full">#taskCount#</span>
                                                </span>
                                                <i :class="open ? 'fa-chevron-up' : 'fa-chevron-down'" class="fas text-blue-600"></i>
                                            </button>
                                            <div x-show="open" x-collapse class="bg-gray-50">
                                                <div class="p-4 overflow-x-auto">
                                                    <table class="w-full text-sm min-w-[800px]">
                                                        <thead>
                                                            <tr class="text-gray-700 bg-gray-100 border-b-2 border-gray-200">
                                                                <th class="py-2 px-3 text-left font-semibold">A</th>
                                                                <th class="py-2 px-3 text-left font-semibold">Başlık</th>
                                                                <th class="py-2 px-3 text-left font-semibold">Aşama</th>
                                                                <th class="py-2 px-3 text-left font-semibold">Termin</th>
                                                                <th class="py-2 px-3 text-left font-semibold">Öngörülen</th>
                                                                <th class="py-2 px-3 text-left font-semibold">Harcanan</th>
                                                                <th class="py-2 px-3 text-center font-semibold">%</th>
                                                                <th class="py-2 px-3 text-center font-semibold"><i class="fas fa-th"></i></th>
                                                                <th class="py-2 px-3 text-center font-semibold"><i class="fas fa-file-alt"></i></th>
                                                            </tr>
                                                        </thead>
                                                        <tbody>
                                                            <cfset taskIdx = 0>
                                                            <cfloop query="GET_ALL_PROJECT_TASKS">
                                                                <cfif GET_ALL_PROJECT_TASKS.PROJECT_ID eq GET_PROJECT_OPERATIONS.PROJECT_ID>
                                                                    <cfset taskIdx = taskIdx + 1>
                                                                    <cfset rowBg = taskIdx mod 2 eq 0 ? "bg-gray-50" : "bg-white">
                                                                    <tr class="#rowBg# border-b border-gray-200 hover:bg-teal-50 transition-colors">
                                                                        <td class="py-2 px-3"><div class="w-8 h-8 rounded-full bg-gradient-to-br from-teal-400 to-teal-600 flex items-center justify-center text-white text-xs shadow-sm" title="#EMPLOYEE_NAME#"><cfif len(trim(EMPLOYEE_NAME)) gt 0>#uCase(left(listFirst(EMPLOYEE_NAME, ' '), 1))##uCase(left(listLast(EMPLOYEE_NAME, ' '), 1))#<cfelse><i class="fas fa-user"></i></cfif></div></td>
                                                                        <td class="py-2 px-3 text-teal-600 font-semibold"><a href="#request.self#?fuseaction=project.works&event=det&id=#WORK_ID#" target="_blank" class="hover:underline hover:text-teal-800">#WORK_HEAD#</a></td>
                                                                        <td class="py-2 px-3"><select class="text-sm border border-gray-300 rounded-md px-2 py-1 bg-white focus:ring-2 focus:ring-teal-500 focus:border-teal-500" onchange="updateTaskStage(#WORK_ID#, this.value, this)" style="min-width:120px;"><option value="">-</option><cfloop query="GET_WORK_STAGES"><option value="#GET_WORK_STAGES.PROCESS_ROW_ID#" <cfif GET_ALL_PROJECT_TASKS.WORK_CURRENCY_ID eq GET_WORK_STAGES.PROCESS_ROW_ID>selected</cfif>>#GET_WORK_STAGES.STAGE#</option></cfloop></select></td>
                                                                        <td class="py-2 px-3 text-gray-600"><cfif isDate(TARGET_FINISH)>#dateformat(TARGET_FINISH, 'dd/mm/yyyy')#</cfif></td>
                                                                        <td class="py-2 px-3 text-gray-600">#int(val(ESTIMATED_TIME)/60)# Saat #val(ESTIMATED_TIME) mod 60# Dk</td>
                                                                        <td class="py-2 px-3 text-gray-600">#int(val(HARCANAN_DAKIKA)/60)# Saat #val(HARCANAN_DAKIKA) mod 60# Dk</td>
                                                                        <td class="py-2 px-3 text-center"><input type="number" min="0" max="100" value="#int(TO_COMPLETE)#" id="task-percent-#WORK_ID#" class="text-sm border border-gray-300 rounded-md px-2 py-1 w-16 text-center focus:ring-2 focus:ring-teal-500 focus:border-teal-500" onblur="updateTaskPercent(#WORK_ID#, this.value, this)"></td>
                                                                        <td class="py-2 px-3 text-center"><cfif trim(WORK_HEAD) eq "ÜRETİM SÜRECİ"><button onclick="openMatrixModal(#PROJECT_ID#, #WORK_ID#)" class="text-gray-500 hover:text-purple-600 hover:bg-purple-100 rounded-md p-1.5 transition-colors" title="Üretim Matrisi"><i class="fas fa-th"></i></button><cfelse>&nbsp;</cfif></td>
                                                                        <td class="py-2 px-3 text-center"><button onclick="openTaskDocumentModal(#WORK_ID#)" class="text-gray-500 hover:text-teal-600 hover:bg-teal-100 rounded-md p-1.5 transition-colors" title="Belge Ekle"><i class="fas fa-file-alt"></i></button></td>
                                                                    </tr>
                                                                </cfif>
                                                            </cfloop>
                                                            <cfif taskIdx eq 0>
                                                                <tr><td colspan="9" class="py-4 text-center text-gray-400">Gorev bulunamadi</td></tr>
                                                            </cfif>
                                                        </tbody>
                                                    </table>
                                                </div>
                                            </div>
                                        </div>
                                        
                                        <!--- Alt link --->
                                        <div class="px-4 py-3 bg-gray-100 text-right border-t border-gray-200">
                                            <a href="#request.self#?fuseaction=project.projects&event=det&id=#PROJECT_ID#" class="text-sm text-blue-600 hover:underline font-medium">
                                                <i class="fas fa-external-link-alt mr-1"></i>Proje Kartına Git
                                            </a>
                                            <span class="mx-2 text-gray-300">|</span>
                                            <a onclick="openBoxDraggable('#request.self#?fuseaction=project.popup_list_project_actions&id=#PROJECT_ID#')" class="text-sm text-purple-600 hover:underline font-medium cursor-pointer">
                                                <i class="fas fa-cogs mr-1"></i>Operasyonlar Popup
                                            </a>
                                        </div>
                                        
                                    </div>
                                </td>
                            </tr>
                            </tbody>
                        </cfoutput>
                    <cfelse>
                        <tbody class="bg-white">
                        <tr>
                            <td colspan="12" class="px-4 py-8 text-center text-gray-500">
                                <i class="fas fa-info-circle text-gray-400 text-3xl mb-4 block"></i>
                                <p>Kayıt bulunamadı!</p>
                            </td>
                        </tr>
                        </tbody>
                    </cfif>
            </table>
        </div>
    </div>

    <!-- Modern Pagination -->
    <cfif attributes.totalrecords gt attributes.maxrows>
        <div class="flex items-center justify-between mt-8 bg-white rounded-xl p-4 shadow-lg">
            <div class="text-sm text-gray-600">
                <span>Toplam <cfoutput>#attributes.totalrecords#</cfoutput> proje - <cfoutput>#((attributes.page - 1) * attributes.maxrows) + 1#</cfoutput> ile <cfoutput>#min(attributes.page * attributes.maxrows, attributes.totalrecords)#</cfoutput> arası gösteriliyor</span>
            </div>
            <div class="flex space-x-2">
                <cfif attributes.page gt 1>
                    <a href="<cfoutput>#request.self#?fuseaction=report.detail_report&event=det&report_id=9&page=#attributes.page - 1#&keyword=#attributes.keyword#&category_id=#attributes.category_id#&priority_id=#attributes.priority_id#</cfoutput>" 
                       class="px-4 py-2 bg-gray-100 hover:bg-gray-200 rounded-lg transition-colors">
                        <i class="fas fa-chevron-left mr-1"></i>Önceki
                    </a>
                </cfif>
                
                <cfset totalPages = ceiling(attributes.totalrecords / attributes.maxrows)>
                <cfloop from="1" to="#min(totalPages, 5)#" index="pageNum">
                    <a href="<cfoutput>#request.self#?fuseaction=report.detail_report&event=det&report_id=9&page=#pageNum#&keyword=#attributes.keyword#&category_id=#attributes.category_id#&priority_id=#attributes.priority_id#</cfoutput>" 
                       class="px-4 py-2 <cfif pageNum eq attributes.page>bg-brand-500 text-white<cfelse>bg-gray-100 hover:bg-gray-200</cfif> rounded-lg transition-colors">
                        <cfoutput>#pageNum#</cfoutput>
                    </a>
                </cfloop>
                
                <cfif attributes.page lt totalPages>
                    <a href="<cfoutput>#request.self#?fuseaction=report.detail_report&event=det&report_id=9&page=#attributes.page + 1#&keyword=#attributes.keyword#&category_id=#attributes.category_id#&priority_id=#attributes.priority_id#</cfoutput>" 
                       class="px-4 py-2 bg-gray-100 hover:bg-gray-200 rounded-lg transition-colors">
                        Sonraki<i class="fas fa-chevron-right ml-1"></i>
                    </a>
                </cfif>
            </div>
        </div>
    </cfif>

</div> <!-- End Alpine.js Container -->

<!-- Toast Notifications -->
<div x-data="{ 
        toast: { show: false, message: '', type: 'success' },
        showToast(message, type = 'success') {
            this.toast.message = message;
            this.toast.type = type;
            this.toast.show = true;
            setTimeout(() => { this.toast.show = false; }, 3000);
        }
     }"
     x-show="toast.show" 
     x-transition:enter="transition ease-out duration-300"
     x-transition:enter-start="opacity-0 transform translate-y-2"
     x-transition:enter-end="opacity-100 transform translate-y-0"
     x-transition:leave="transition ease-in duration-200"
     x-transition:leave-start="opacity-100 transform translate-y-0"
     x-transition:leave-end="opacity-0 transform translate-y-2"
     class="fixed bottom-4 right-4 z-50">
    <div 
        :class="{
            'bg-green-500': toast.type === 'success',
            'bg-red-500': toast.type === 'error',
            'bg-blue-500': toast.type === 'info'
        }"
        class="text-white px-6 py-3 rounded-lg shadow-lg flex items-center space-x-2">
        <i 
            :class="{
                'fa-check-circle': toast.type === 'success',
                'fa-exclamation-circle': toast.type === 'error',
                'fa-info-circle': toast.type === 'info'
            }"
            class="fas">
        </i>
        <span x-text="toast.message"></span>
        <button @click="toast.show = false" class="ml-4 hover:text-gray-200 transition-colors">
            <i class="fas fa-times"></i>
        </button>
    </div>
</div>


<!-- Alpine.js App Logic -->
<script>
    function projectApp() {
        return {
            // State
            loading: false,
            searchQuery: '<cfoutput>#attributes.keyword#</cfoutput>',
            filterCategory: '<cfoutput>#attributes.category_id#</cfoutput>',
            filterPriority: '<cfoutput>#attributes.priority_id#</cfoutput>',
            filterStatus: '',
            
            // Initialize
            init() {
                console.log('Modern Proje Raporu başlatıldı!');
            }
        }
    }
    
    // ========== SİPARİŞ TASK FONKSİYONLARI ==========
    var STAGE_PLANLAMA = 2358;
    var STAGE_IS_ATANDI = 2359;
    var STAGE_DEVAM = 2361;
    var STAGE_TAMAMLANDI = 2364;
    var STAGE_ONAYLANDI = 2365;
    
    var currentOpenOrderId = null;
    function toggleOrderTasks(orderId, btn) {
        // Önce tüm açık task satırlarını kapat
        var allTaskRows = document.querySelectorAll('[id^="order-tasks-"]');
        allTaskRows.forEach(function(row) {
            row.style.display = 'none';
        });
        
        // Tüm butonları resetle
        var allBtns = document.querySelectorAll('[data-order-id]');
        allBtns.forEach(function(b) {
            var icon = b.querySelector('i');
            if (icon) { icon.classList.remove('fa-chevron-up'); icon.classList.add('fa-chevron-down'); }
            b.classList.remove('bg-teal-500', 'text-white');
            b.classList.add('bg-gray-200', 'text-gray-600');
        });
        
        // Aynı siparişe tekrar tıklandıysa sadece kapat
        if (currentOpenOrderId === orderId) {
            currentOpenOrderId = null;
            return;
        }
        
        // Task satırını bul
        var taskRow = document.getElementById('order-tasks-' + orderId);
        if (!taskRow) return;
        
        // Tıklanan sipariş satırını bul ve task satırını hemen arkasına taşı
        var orderRow = btn.closest('tr');
        if (orderRow) {
            orderRow.parentNode.insertBefore(taskRow, orderRow.nextSibling);
        }
        
        // Task satırını göster ve butonu aktif yap
        taskRow.style.display = 'table-row';
        var icon = btn.querySelector('i');
        if (icon) { icon.classList.remove('fa-chevron-down'); icon.classList.add('fa-chevron-up'); }
        btn.classList.add('bg-teal-500', 'text-white');
        btn.classList.remove('bg-gray-200', 'text-gray-600');
        currentOpenOrderId = orderId;
    }
    
    function updateOrderTaskPercent(taskId, newPercent, inputEl, isProductionTask) {
        if (isProductionTask) {
            alert('Üretim Süreci yüzdesi sadece Üretim Matrisi üzerinden yönetilebilir.');
            return;
        }
        var pct = parseInt(newPercent) || 0;
        if (pct < 0) pct = 0;
        if (pct > 100) pct = 100;
        var newStageId = STAGE_PLANLAMA;
        if (pct === 0) { newStageId = STAGE_IS_ATANDI; }
        else if (pct > 0 && pct < 100) { newStageId = STAGE_DEVAM; }
        else if (pct === 100) { newStageId = STAGE_TAMAMLANDI; }
        var xhr = new XMLHttpRequest();
        xhr.open('POST', 'V16/sales/query/ajax_ops_task.cfm', true);
        xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        xhr.withCredentials = true;
        xhr.onreadystatechange = function() {
            if (xhr.readyState === 4 && xhr.status === 200) {
                try {
                    var resp = JSON.parse(xhr.responseText);
                    if (resp.success || resp.SUCCESS) {
                        var row = inputEl.closest('tr');
                        if (row) {
                            var stageSelect = row.querySelector('select');
                            if (stageSelect) stageSelect.value = newStageId;
                        }
                    }
                } catch(e) { console.error(e); }
            }
        };
        xhr.send('action=update_percent&task_id=' + taskId + '&percent_complete=' + pct + '&status_id=' + newStageId);
    }
    
    function updateOrderTaskStage(taskId, stageId, selectEl, isProductionTask) {
        if (isProductionTask) {
            alert('Üretim Süreci aşaması sadece Üretim Matrisi üzerinden yönetilebilir.');
            return;
        }
        var newPercent = 0;
        if (parseInt(stageId) === STAGE_TAMAMLANDI || parseInt(stageId) === STAGE_ONAYLANDI) { newPercent = 100; }
        else if (parseInt(stageId) === STAGE_DEVAM) { newPercent = -1; }
        var xhr = new XMLHttpRequest();
        xhr.open('POST', 'V16/sales/query/ajax_ops_task.cfm', true);
        xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        xhr.withCredentials = true;
        xhr.onreadystatechange = function() {
            if (xhr.readyState === 4 && xhr.status === 200) {
                try {
                    var resp = JSON.parse(xhr.responseText);
                    if (resp.success || resp.SUCCESS) {
                        if (newPercent >= 0) {
                            var row = selectEl.closest('tr');
                            if (row) {
                                var pctInput = row.querySelector('input[type="number"]');
                                if (pctInput) pctInput.value = newPercent;
                            }
                        }
                    }
                } catch(e) { console.error(e); }
            }
        };
        var sendData = 'action=update_status&task_id=' + taskId + '&status_id=' + stageId;
        if (newPercent >= 0) sendData += '&percent_complete=' + newPercent;
        xhr.send(sendData);
    }
    
    function openOrderTaskEdit(taskId) {
        var url = '/V16/sales/form/dsp_ops_task.cfm?task_id=' + taskId + '&ref_type=ORDER';
        showTaskFormModal(url);
    }
    
    function addOrderTask(orderId) {
        var url = '/V16/sales/form/dsp_ops_task.cfm?task_id=0&ref_type=ORDER&ref_id=' + orderId;
        showTaskFormModal(url);
    }
    
    function openOrderTaskMatrix(orderId, taskId) {
        var url = '/V16/sales/form/dsp_ops_task_matrix.cfm?task_id=' + taskId + '&ref_type=ORDER&ref_id=' + orderId;
        var existing = document.getElementById('taskMatrixOverlay');
        if(existing) existing.remove();
        var overlay = document.createElement('div');
        overlay.id = 'taskMatrixOverlay';
        overlay.style.cssText = 'position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,0,0.5);z-index:2147483647;display:flex;align-items:center;justify-content:center;';
        overlay.onclick = function(e) { if(e.target === overlay) overlay.remove(); };
        var modal = document.createElement('div');
        modal.style.cssText = 'background:white;width:90%;max-width:800px;max-height:90vh;border-radius:8px;overflow:hidden;box-shadow:0 25px 50px -12px rgba(0,0,0,0.25);';
        var body = document.createElement('div');
        body.style.cssText = 'max-height:90vh;overflow:auto;';
        body.innerHTML = '<div style="text-align:center;padding:40px;"><i class="fas fa-spinner fa-spin fa-2x"></i><br><br>Matris yükleniyor...</div>';
        modal.appendChild(body);
        overlay.appendChild(modal);
        document.body.appendChild(overlay);
        fetch(url).then(function(r){ return r.text(); }).then(function(html){
            body.innerHTML = html;
            var scripts = body.querySelectorAll('script');
            scripts.forEach(function(s){ if(s.textContent) try { eval(s.textContent); } catch(e){ console.error(e); } });
        }).catch(function(err){
            body.innerHTML = '<div style="color:red;padding:20px;">Hata: ' + err.message + '</div>';
        });
    }
    
    function openOrderTaskDocumentModal(taskId) {
        var url = 'index.cfm?fuseaction=asset.list_asset&event=add&module=sales&module_id=1&action=OPS_TASK&action_id=' + taskId + '&asset_cat_id=-21&action_type=0';
        openTaskDocumentModal(taskId);
    }
    
    function showTaskFormModal(url) {
        var existing = document.getElementById('taskFormOverlay');
        if(existing) existing.remove();
        var overlay = document.createElement('div');
        overlay.id = 'taskFormOverlay';
        overlay.style.cssText = 'position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,0,0.5);z-index:2147483647;display:flex;align-items:center;justify-content:center;';
        overlay.onclick = function(e) { if(e.target === overlay) overlay.remove(); };
        var modal = document.createElement('div');
        modal.style.cssText = 'background:white;width:577px;max-height:90vh;border-radius:8px;overflow:hidden;box-shadow:0 25px 50px -12px rgba(0,0,0,0.25);';
        var body = document.createElement('div');
        body.style.cssText = 'max-height:90vh;overflow:auto;';
        body.innerHTML = '<div style="text-align:center;padding:40px;"><i class="fa fa-spinner fa-spin fa-2x"></i><br><br>Form yükleniyor...</div>';
        modal.appendChild(body);
        overlay.appendChild(modal);
        document.body.appendChild(overlay);
        fetch(url).then(function(r){ return r.text(); }).then(function(html){
            body.innerHTML = html;
            var scripts = body.querySelectorAll('script');
            scripts.forEach(function(s){ if(s.textContent) try { eval(s.textContent); } catch(e){ console.error(e); } });
            setTimeout(function(){
                var cancelBtns = body.querySelectorAll('button');
                cancelBtns.forEach(function(btn){
                    if(btn.textContent.trim() === 'İptal' || btn.textContent.trim() === 'Kapat' || btn.textContent.trim() === 'Vazgeç') {
                        btn.onclick = function(e){ e.preventDefault(); closeTaskFormModal(); };
                    }
                });
                var closeBtn = body.querySelector('.close, [data-dismiss="modal"], .btn-close, .otm-close');
                if(closeBtn) closeBtn.onclick = function(e){ e.preventDefault(); closeTaskFormModal(); };
            }, 100);
        }).catch(function(err){
            body.innerHTML = '<div style="color:red;padding:20px;">Hata: ' + err.message + '</div>';
        });
    }
    
    function closeTaskFormModal() {
        var overlay = document.getElementById('taskFormOverlay');
        if(overlay) overlay.remove();
    }
    // ========== SİPARİŞ TASK FONKSİYONLARI SON ==========
    
    // Global functions
    function exportExcel() {
        let csvContent = 'Proje No,Proje Adı,Sorumlu,Kategori,Öncelik,Başlangıç,Bitiş,Tamamlanma,Durum\n';
        
        <cfoutput query="GET_PROJECT_OPERATIONS">
        csvContent += '"#PROJECT_NUMBER#","#replace(PROJECT_HEAD, '"', '""', 'all')#","#trim(EMPLOYEE_NAME & ' ' & EMPLOYEE_SURNAME)#","#MAIN_PROCESS_CAT#","#PRIORITY#","#dateformat(TARGET_START, 'dd/mm/yyyy')#","#dateformat(TARGET_FINISH, 'dd/mm/yyyy')#","#int(COMPLETION_RATE)#%","<cfif int(COMPLETION_RATE) gte 100>Tamamlandı<cfelseif REMAINING_DAYS lt 0>Geciken<cfelse>Aktif</cfif>"\n';
        </cfoutput>
        
        const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
        const link = document.createElement('a');
        link.href = URL.createObjectURL(blob);
        link.download = `Proje_Raporu_${new Date().toISOString().split('T')[0]}.csv`;
        link.click();
        
        // Show success message
        console.log('Excel dosyası indirildi!');
    }
</script>

<script type="text/javascript">
// Legacy compatibility
if (document.getElementById('keyword')) {
    document.getElementById('keyword').focus();
}
</script>

</body>
</html>
