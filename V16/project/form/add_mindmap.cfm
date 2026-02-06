  <link rel="stylesheet" href="/JS/drawflow/css/drawflow.min.css">
  <link rel="stylesheet" type="text/css" href="/JS/drawflow/css/beautiful.css" />
  <link rel="stylesheet" href="/JS/drawflow/css/fa.all.min.css" />
  <script src="/JS/drawflow/js/drawflow.min.js"></script>
  <script src="/JS/drawflow/js/fa.all.min.js"></script>
  <script src="/JS/drawflow/js/sweetalert2.js"></script>
  <script src="/JS/drawflow/js/micromodal.min.js"></script>
  
  <cf_catalystHeader>
  <cf_box title="Mindmap Designer">
    <cfform name="add_mindmap_form" method="post">
        <cfif isDefined("attributes.prj_id") and len(attributes.prj_id)>
            <input type="text" name="prj_id" id="prj_id" value="<cfoutput>#attributes.prj_id#</cfoutput>" hidden>
        </cfif>
        <cfif isDefined("attributes.type") and len(attributes.type)>
            <input type="text" name="type" id="type" value="<cfoutput>#attributes.type#</cfoutput>" hidden>
        </cfif>
        
        <textarea id="jsonForm" name="jsonForm" style="display:none;"></textarea>
        <div class="wrapper-mindmap">
        <div class="col-right col-12">
            <div class="menu-mindmap-top col-12">
                
                <div class="bar-zoom">
                    <i class="fas fa-search-minus" onclick="editor.zoom_out()" title="<cf_get_lang dictionary_id='66885.Uzaklaştır'>"></i>
                    <i class="fas fa-search-plus" onclick="editor.zoom_in()" title="<cf_get_lang dictionary_id='66884.Yaklaştır'>"></i>
                    <i id="lock" class="fas fa-lock" onclick="editor.editor_mode='fixed'; changeMode('lock');" title="<cf_get_lang dictionary_id='58860.Kilitle'>"></i>
                    <i id="unlock" class="fas fa-lock-open" onclick="editor.editor_mode='edit'; changeMode('unlock');"
                    style="display:none;" title="<cf_get_lang dictionary_id='66883.Kilidini Aç'>"></i>
                    <i id="sidebar-opener" class="fa fa-text-height" style="position:relative" onclick="toggleColorPalette()" title="Style"></i>
                    <i class="fa fa-reply" onclick="geriAl()" title="<cf_get_lang dictionary_id='66880.Geri Al'>"></i>
                    <i class="fa fa-share" onclick="ileriAl()" title="<cf_get_lang dictionary_id='66881.İleri Al'>"></i>
                    <i class="fa fa-trash" onclick="temizleOnclick()" title="<cf_get_lang dictionary_id='57934.Temizle'>"></i>
                    <i id="guide-opener" class="fa fa-question" onclick="toggleGuide()" title="<cf_get_lang dictionary_id='37964.Kullanım Kılavuzu'>"></i>
                    <div class="bar-sidebar" id="colorPalette" style="display: none;">
                        <div class="bar-sidebar-icons">
                            <i class="fa fa-bold"  onclick="makeBold(selectedID)" title="Bold"></i>
                            <i class="fa fa-italic" onclick="makeItalic(selectedID)" title="Italic"></i>
                        </div>
                        <div class="bar-sidebar-colors">
                            <div class="bar-color-green" onclick="makeColor(selectedID,'green')"></div>
                            <div class="bar-color-red" onclick="makeColor(selectedID,'red')"></div>
                            <div class="bar-color-blue" onclick="makeColor(selectedID,'blue')"></div>
                            <div class="bar-color-orange" onclick="makeColor(selectedID,'orange')"></div>
                            <div class="bar-color-pink" onclick="makeColor(selectedID,'pink')"></div>
                            <div class="bar-color-clear" onclick="makeColor(selectedID,'clear')"></div>
                        </div>
                    </div>
                    <div class="bar-guide" id="guide" style="display: none;">
                        <div class="guide-wrapper">
                            <div class="guide-title">
                                <cf_get_lang dictionary_id="37964.Kullanım Kılavuzu">
                            </div>
                            <div class="guide-text">
                                <p>
                                    - <cf_get_lang dictionary_id="40241.Ana Fikir elementinin altındaki + butonlarıyla dal ekleyiniz."><br><br>
                                    - <cf_get_lang dictionary_id="66870.Dalların altındaki + butonlarıyla alt dallar ekleyiniz."><br><br>
                                    - <cf_get_lang dictionary_id="66871.Sürükle bırak yaparak dalların konumlarını ayarlayabilirsiniz."><br><br>
                                    - <cf_get_lang dictionary_id="66872.Alt menüden dosya adı belirleyin."><br><br>
                                    - <cf_get_lang dictionary_id="66873.Kaydet butonuyla mindmapinizi kaydedin.">
                                </p>
                                <p><b><u><cf_get_lang dictionary_id='62073.Kısayollar'>:</u></b></p>
                                <p>
                                    <b>Delete:</b> <cf_get_lang dictionary_id='66874.Seçileni sil'><br>
                                    <b><cf_get_lang dictionary_id='66877.Mouse Sol Tık'>:</b> <cf_get_lang dictionary_id='61360.Sürükle ve Bırak'><br>
                                    <b><cf_get_lang dictionary_id='66878.Mouse Sağ Tık'>:</b> <cf_get_lang dictionary_id='57463.Sil'><br>
                                    <b>Ctrl + Scroll:</b> <cf_get_lang dictionary_id='66876.Yaklaştır/Uzaklaştır'><br>
                                </p>
                            </div>
                        </div>

                    </div>
                </div>
            </div>
            <div id="drawflow" ondrop="drop(event)" ondragover="allowDrop(event)">
            </div>
            <div class="menu-mindmap col-12">
                <ul>
                    <label class="label-mindmap"><cf_get_lang dictionary_id='66879.Dosya Adı'></label>
                    <input required type="text" name="fileName" id="fileName" placeholder="<cf_get_lang dictionary_id='66904.Mindmap''e bir ad veriniz.'>">
                </ul>
                
                <cf_workcube_buttons 
                    is_upd='0'
                    is_delete="0"
                    data_action ="V16/project/cfc/mindmap:ADD_MINDMAP"
                    add_function="exportToJson()"
                >
            </div>
        </div>
    </cfform>
</cf_box>
  
<script src="/JS/drawflow/js/main.js"></script>

<script>
    giveDictionaryValues("<cf_get_lang dictionary_id="31672.Ana Fikir">","<cf_get_lang dictionary_id='57653.İçerik'>");
    let textareaEle;
    initialImport();

    document.addEventListener('DOMContentLoaded', () => {
        addEventListenersDef();
    document.getElementById("drawflow").addEventListener("mousedown", function() {
        document.body.style.cursor = "grabbing";
    });

    document.getElementById("drawflow").addEventListener("mouseup", function() {
        document.body.style.cursor = "default";
    });
    });

    
    function temizleOnclick(){
        editor.clearModuleSelected();
        afterClearImport();
    }

    function exportToJson() {
        const exportData = JSON.stringify(editor.export(), null, 4);
        const textarea = document.getElementById('jsonForm');
        textarea.innerHTML = exportData;
    }
    

</script>

