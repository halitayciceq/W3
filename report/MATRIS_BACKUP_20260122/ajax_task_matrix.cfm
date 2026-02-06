<cfsetting showdebugoutput="no" enablecfoutputonly="yes">
<cfcontent type="application/json; charset=utf-8">
<!--- 
    AJAX Endpoint: Görev Matris İşlemleri
    Tarih: 2026-01-21
    
    Parametreler:
    - action: get | save
    - project_id: Proje ID
    - work_id: Görev ID
    - template_code: Matris şablon kodu (default: URETIM_SURECI)
    - json_values: Hücre değerleri JSON (save için)
--->

<cfparam name="attributes.action" default="get">
<cfparam name="attributes.project_id" default="">
<cfparam name="attributes.work_id" default="">
<cfparam name="attributes.template_code" default="URETIM_SURECI">
<cfparam name="attributes.json_values" default="[]">
<cfparam name="attributes.json_workstations" default="[]">

<cfset response = {success: false, message: ""}>

<cftry>
    <cfif NOT len(attributes.project_id) OR NOT isNumeric(attributes.project_id)>
        <cfset response.message = "Geçersiz project_id">
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>
    
    <cfif NOT len(attributes.work_id) OR NOT isNumeric(attributes.work_id)>
        <cfset response.message = "Geçersiz work_id">
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>
    
    <cfswitch expression="#attributes.action#">
        
        <!--- GET: Matris verilerini getir --->
        <cfcase value="get">
            <cfstoredproc procedure="sp_prj_task_matrix_get" datasource="#DSN#">
                <cfprocparam type="in" cfsqltype="cf_sql_integer" value="#attributes.project_id#">
                <cfprocparam type="in" cfsqltype="cf_sql_integer" value="#attributes.work_id#">
                <cfprocparam type="in" cfsqltype="cf_sql_varchar" value="#attributes.template_code#">
                <cfprocresult name="qResultType" resultset="1">
                <cfprocresult name="qTemplate" resultset="2">
                <cfprocresult name="qStages" resultset="3">
                <cfprocresult name="qSubStages" resultset="4">
                <cfprocresult name="qCells" resultset="5">
                <cfprocresult name="qValues" resultset="6">
            </cfstoredproc>
            
            <!--- Result type kontrolü --->
            <cfset response.result_type = qResultType.result_type>
            <cfset response.result_message = qResultType.message>
            
            <!--- SELECT_WS modunda istasyon listesi getir --->
            <cfif response.result_type EQ "SELECT_WS">
                <cfstoredproc procedure="sp_prj_task_ws_list" datasource="#DSN#">
                    <cfprocresult name="qWorkstations" resultset="1">
                </cfstoredproc>
                
                <cfset response.workstations = []>
                <cfloop query="qWorkstations">
                    <cfset arrayAppend(response.workstations, {
                        workstation_id: qWorkstations.workstation_id,
                        code: qWorkstations.code,
                        name: qWorkstations.name
                    })>
                </cfloop>
                
                <cfset response.success = true>
                <cfset response.message = "İstasyon seçimi gerekli">
            <cfelse>
            <!--- MATRIX modunda normal devam --->
            
            <!--- Template bilgisi --->
            <cfset response.template = {}>
            <cfif qTemplate.recordcount>
                <cfset response.template = {
                    template_id: qTemplate.TEMPLATE_ID,
                    template_code: qTemplate.TEMPLATE_CODE,
                    template_name: qTemplate.TEMPLATE_NAME,
                    instance_id: qTemplate.INSTANCE_ID,
                    calc_percent: qTemplate.CALC_PERCENT,
                    ws_set_id: qTemplate.WS_SET_ID
                }>
            </cfif>
            
            <!--- Stages --->
            <cfset response.stages = []>
            <cfloop query="qStages">
                <cfset arrayAppend(response.stages, {
                    dim_id: qStages.DIM_ID,
                    dim_code: qStages.DIM_CODE,
                    dim_name: qStages.DIM_NAME,
                    sort_order: qStages.SORT_ORDER
                })>
            </cfloop>
            
            <!--- Sub-stages --->
            <cfset response.sub_stages = []>
            <cfloop query="qSubStages">
                <cfset arrayAppend(response.sub_stages, {
                    dim_id: qSubStages.DIM_ID,
                    dim_code: qSubStages.DIM_CODE,
                    dim_name: qSubStages.DIM_NAME,
                    parent_dim_id: qSubStages.PARENT_DIM_ID,
                    sort_order: qSubStages.SORT_ORDER
                })>
            </cfloop>
            
            <!--- Cells --->
            <cfset response.cells = []>
            <cfloop query="qCells">
                <cfset arrayAppend(response.cells, {
                    cell_def_id: qCells.CELL_DEF_ID,
                    stage_dim_id: qCells.STAGE_DIM_ID,
                    sub_stage_dim_id: qCells.SUB_STAGE_DIM_ID,
                    row_index: qCells.ROW_INDEX,
                    col_index: qCells.COL_INDEX,
                    cell_label: qCells.CELL_LABEL,
                    weight: qCells.WEIGHT,
                    cell_value_id: qCells.CELL_VALUE_ID,
                    value_id: qCells.VALUE_ID,
                    value_code: qCells.VALUE_CODE,
                    value_label: qCells.VALUE_LABEL,
                    score: qCells.SCORE,
                    color_code: qCells.COLOR_CODE
                })>
            </cfloop>
            
            <!--- Value dictionary --->
            <cfset response.values = []>
            <cfloop query="qValues">
                <cfset arrayAppend(response.values, {
                    value_id: qValues.VALUE_ID,
                    value_code: qValues.VALUE_CODE,
                    value_label: qValues.VALUE_LABEL,
                    score: qValues.SCORE,
                    color_code: qValues.COLOR_CODE,
                    sort_order: qValues.SORT_ORDER
                })>
            </cfloop>
            
            <!--- Seçili istasyonları getir (düzenleme için) --->
            <cfset response.selected_workstations = []>
            <cfif isDefined("response.template.ws_set_id") AND len(response.template.ws_set_id)>
                <cfquery name="qSelectedWS" datasource="#DSN#">
                    SELECT WORKSTATION_ID, WORKSTATION_CODE, WORKSTATION_NAME, SORT_ORDER
                    FROM PRJ_TASK_WS_SET_ROW
                    WHERE WS_SET_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#response.template.ws_set_id#">
                    ORDER BY SORT_ORDER
                </cfquery>
                <cfloop query="qSelectedWS">
                    <cfset arrayAppend(response.selected_workstations, {
                        workstation_id: qSelectedWS.WORKSTATION_ID,
                        code: qSelectedWS.WORKSTATION_CODE,
                        name: qSelectedWS.WORKSTATION_NAME
                    })>
                </cfloop>
            </cfif>
            
            <cfset response.success = true>
            <cfset response.message = "Matris verileri alındı">
            </cfif><!--- END MATRIX mode --->
        </cfcase>
        
        <!--- WS_SAVE: İstasyon seçimini kaydet --->
        <cfcase value="ws_save">
            <cfset userId = isDefined("session.ep.userid") ? session.ep.userid : 0>
            
            <cfstoredproc procedure="sp_prj_task_ws_set_save" datasource="#DSN#">
                <cfprocparam type="in" cfsqltype="cf_sql_integer" value="#attributes.project_id#">
                <cfprocparam type="in" cfsqltype="cf_sql_integer" value="#attributes.work_id#">
                <cfprocparam type="in" cfsqltype="cf_sql_integer" value="#userId#">
                <cfprocparam type="in" cfsqltype="cf_sql_varchar" value="#attributes.json_workstations#">
                <cfprocresult name="qResult" resultset="1">
            </cfstoredproc>
            
            <cfif qResult.recordcount AND qResult.success>
                <cfset response.ws_set_id = qResult.ws_set_id>
                <cfset response.row_count = qResult.row_count>
                <cfset response.success = true>
                <cfset response.message = "İstasyon seçimi kaydedildi">
            <cfelse>
                <cfset response.success = false>
                <cfset response.message = qResult.error_message>
            </cfif>
        </cfcase>
        
        <!--- WS_LIST: İstasyon listesi (Matris DIM tablosundan STAGE'ler) --->
        <cfcase value="ws_list">
            <cfquery name="qWorkstations" datasource="#DSN#">
                SELECT 
                    DIM_ID AS workstation_id,
                    DIM_CODE AS code,
                    DIM_NAME AS name
                FROM PRJ_TASK_MATRIX_DIM
                WHERE TEMPLATE_ID = (SELECT TEMPLATE_ID FROM PRJ_TASK_MATRIX_TEMPLATE WHERE TEMPLATE_CODE = 'URETIM_SURECI' AND IS_ACTIVE = 1)
                AND DIM_TYPE = 'STAGE'
                AND IS_ACTIVE = 1
                ORDER BY SORT_ORDER
            </cfquery>
            
            <cfset response.workstations = []>
            <cfloop query="qWorkstations">
                <cfset arrayAppend(response.workstations, {
                    workstation_id: qWorkstations.workstation_id,
                    code: qWorkstations.code,
                    name: qWorkstations.name
                })>
            </cfloop>
            
            <cfset response.success = true>
            <cfset response.message = "İstasyon listesi alındı">
        </cfcase>
        
        <!--- SAVE: Matris değerlerini kaydet --->
        <cfcase value="save">
            <cfset userId = isDefined("session.ep.userid") ? session.ep.userid : 0>
            
            <!--- DEBUG: Gelen JSON'u response'a ekle --->
            <cfset response.debug_json_values = attributes.json_values>
            <cfset response.debug_json_length = len(attributes.json_values)>
            
            <cfstoredproc procedure="sp_prj_task_matrix_save" datasource="#DSN#">
                <cfprocparam type="in" cfsqltype="cf_sql_integer" value="#attributes.project_id#">
                <cfprocparam type="in" cfsqltype="cf_sql_integer" value="#attributes.work_id#">
                <cfprocparam type="in" cfsqltype="cf_sql_varchar" value="#attributes.template_code#">
                <cfprocparam type="in" cfsqltype="cf_sql_integer" value="#userId#">
                <cfprocparam type="in" cfsqltype="cf_sql_varchar" value="#attributes.json_values#">
                <cfprocresult name="qResult" resultset="1">
            </cfstoredproc>
            
            <cfif qResult.recordcount>
                <cfset response.instance_id = qResult.instance_id>
                <cfset response.calc_percent = qResult.calc_percent>
                <cfset response.work_id = attributes.work_id>
                <cfset response.project_id = attributes.project_id>
            </cfif>
            
            <!--- Proje tamamlanma yüzdesini hesapla --->
            <cfquery name="qProjectProgress" datasource="#DSN#">
                SELECT 
                    CASE 
                        WHEN COUNT(*) > 0 
                        THEN CAST(AVG(CAST(ISNULL(TO_COMPLETE, 0) AS FLOAT)) AS INT)
                        ELSE 0 
                    END AS PROJECT_COMPLETION
                FROM PRO_WORKS
                WHERE PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.project_id#">
                AND WORK_STATUS = 1
            </cfquery>
            
            <cfset response.project_completion = qProjectProgress.PROJECT_COMPLETION>
            <cfset response.success = true>
            <cfset response.message = "Matris kaydedildi">
        </cfcase>
        
        <cfdefaultcase>
            <cfset response.message = "Geçersiz action: #attributes.action#">
        </cfdefaultcase>
        
    </cfswitch>
    
<cfcatch>
    <cfset response.success = false>
    <cfset response.message = cfcatch.message>
    <cfset response.detail = cfcatch.detail>
</cfcatch>
</cftry>

<cfoutput>#serializeJSON(response)#</cfoutput>
