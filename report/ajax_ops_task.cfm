<cfsilent>
<!--- ============================================
    SIPARIŞ OPERASYON GÖREVLERİ - AJAX ENDPOINT
    Tarih: 2026-01-22
    Versiyon: 2.0
    
    Actions:
    - list         : Görev listesi
    - get          : Görev detayı
    - save         : Görev kaydet
    - delete       : Görev sil
    - step_save    : İş adımları kaydet
    - notes_get    : Notları getir
    - note_save    : Not kaydet
    - stage_list   : Stage listesi
    - stage_save   : Stage seçimi kaydet
    - matrix_get   : Matris getir
    - matrix_save  : Matris kaydet
============================================ --->

<cfparam name="url.action" default="">
<cfparam name="form.action" default="#url.action#">

<cfset response = {
    "success": false,
    "data": {},
    "message": ""
}>

<cftry>
    
    <cfswitch expression="#form.action#">
        
        <!--- ========== LIST ========== --->
        <cfcase value="list">
            <cfparam name="form.ref_type" default="ORDER">
            <cfparam name="form.ref_id" default="0">
            <cfparam name="form.company_id" default="#session.company_id#">
            <cfparam name="form.status_id" default="">
            <cfparam name="form.assigned_emp_id" default="">
            
            <cfstoredproc procedure="sp_ops_task_list" datasource="#application.dsn#">
                <cfprocparam cfsqltype="cf_sql_varchar" value="#form.ref_type#">
                <cfprocparam cfsqltype="cf_sql_integer" value="#form.ref_id#">
                <cfprocparam cfsqltype="cf_sql_integer" value="#form.company_id#">
                <cfprocparam cfsqltype="cf_sql_integer" value="#form.status_id#" null="#NOT len(form.status_id)#">
                <cfprocparam cfsqltype="cf_sql_integer" value="#form.assigned_emp_id#" null="#NOT len(form.assigned_emp_id)#">
                <cfprocresult name="qTasks">
            </cfstoredproc>
            
            <cfset tasks = []>
            <cfloop query="qTasks">
                <cfset arrayAppend(tasks, {
                    "task_id": TASK_ID,
                    "task_no": TASK_NO,
                    "task_head": TASK_HEAD,
                    "ref_type": REF_TYPE,
                    "ref_id": REF_ID,
                    "assigned_emp_id": ASSIGNED_EMP_ID,
                    "assigned_name": ASSIGNED_NAME,
                    "planned_start": isDate(PLANNED_START) ? dateFormat(PLANNED_START, "yyyy-mm-dd") : "",
                    "planned_finish": isDate(PLANNED_FINISH) ? dateFormat(PLANNED_FINISH, "yyyy-mm-dd") : "",
                    "deadline": isDate(DEADLINE) ? dateFormat(DEADLINE, "yyyy-mm-dd") : "",
                    "estimated_minutes": ESTIMATED_MINUTES,
                    "actual_minutes": ACTUAL_MINUTES,
                    "status_id": STATUS_ID,
                    "status_name": STATUS_NAME,
                    "priority_id": PRIORITY_ID,
                    "percent_complete": PERCENT_COMPLETE,
                    "has_matrix": HAS_MATRIX,
                    "matrix_template_id": MATRIX_TEMPLATE_ID,
                    "matrix_instance_id": MATRIX_INSTANCE_ID,
                    "is_active": IS_ACTIVE
                })>
            </cfloop>
            
            <cfset response.success = true>
            <cfset response.data = tasks>
        </cfcase>
        
        <!--- ========== GET ========== --->
        <cfcase value="get">
            <cfparam name="form.task_id" default="0">
            
            <cfstoredproc procedure="sp_ops_task_get" datasource="#application.dsn#">
                <cfprocparam cfsqltype="cf_sql_integer" value="#form.task_id#">
                <cfprocresult name="qTask" resultset="1">
                <cfprocresult name="qSteps" resultset="2">
            </cfstoredproc>
            
            <cfif qTask.recordCount>
                <cfset task = {
                    "task_id": qTask.TASK_ID,
                    "task_no": qTask.TASK_NO,
                    "task_head": qTask.TASK_HEAD,
                    "task_detail": qTask.TASK_DETAIL,
                    "ref_type": qTask.REF_TYPE,
                    "ref_id": qTask.REF_ID,
                    "parent_task_id": qTask.PARENT_TASK_ID,
                    "assigned_emp_id": qTask.ASSIGNED_EMP_ID,
                    "assigned_name": qTask.ASSIGNED_NAME,
                    "planned_start": isDate(qTask.PLANNED_START) ? dateFormat(qTask.PLANNED_START, "yyyy-mm-dd") : "",
                    "planned_finish": isDate(qTask.PLANNED_FINISH) ? dateFormat(qTask.PLANNED_FINISH, "yyyy-mm-dd") : "",
                    "deadline": isDate(qTask.DEADLINE) ? dateFormat(qTask.DEADLINE, "yyyy-mm-dd") : "",
                    "estimated_minutes": qTask.ESTIMATED_MINUTES,
                    "actual_minutes": qTask.ACTUAL_MINUTES,
                    "status_id": qTask.STATUS_ID,
                    "status_name": qTask.STATUS_NAME,
                    "priority_id": qTask.PRIORITY_ID,
                    "priority_name": qTask.PRIORITY_NAME,
                    "percent_complete": qTask.PERCENT_COMPLETE,
                    "has_matrix": qTask.HAS_MATRIX,
                    "matrix_template_id": qTask.MATRIX_TEMPLATE_ID,
                    "matrix_instance_id": qTask.MATRIX_INSTANCE_ID,
                    "matrix_calc_percent": qTask.MATRIX_CALC_PERCENT,
                    "is_active": qTask.IS_ACTIVE
                }>
                
                <cfset steps = []>
                <cfloop query="qSteps">
                    <cfset arrayAppend(steps, {
                        "step_id": STEP_ID,
                        "step_order": STEP_ORDER,
                        "step_description": STEP_DESCRIPTION,
                        "estimated_hour": ESTIMATED_HOUR,
                        "estimated_minute": ESTIMATED_MINUTE,
                        "actual_hour": ACTUAL_HOUR,
                        "actual_minute": ACTUAL_MINUTE,
                        "is_complete": IS_COMPLETE
                    })>
                </cfloop>
                
                <cfset response.success = true>
                <cfset response.data = {
                    "task": task,
                    "steps": steps
                }>
            <cfelse>
                <cfset response.message = "Görev bulunamadı">
            </cfif>
        </cfcase>
        
        <!--- ========== SAVE ========== --->
        <cfcase value="save">
            <cfparam name="form.task_id" default="">
            <cfparam name="form.task_no" default="">
            <cfparam name="form.task_head" default="">
            <cfparam name="form.task_detail" default="">
            <cfparam name="form.ref_type" default="ORDER">
            <cfparam name="form.ref_id" default="0">
            <cfparam name="form.parent_task_id" default="">
            <cfparam name="form.assigned_emp_id" default="">
            <cfparam name="form.planned_start" default="">
            <cfparam name="form.planned_finish" default="">
            <cfparam name="form.deadline" default="">
            <cfparam name="form.estimated_minutes" default="0">
            <cfparam name="form.status_id" default="">
            <cfparam name="form.priority_id" default="">
            <cfparam name="form.percent_complete" default="0">
            <cfparam name="form.has_matrix" default="0">
            <cfparam name="form.matrix_template_id" default="">
            <cfparam name="form.company_id" default="#session.company_id#">
            <cfparam name="form.branch_id" default="#session.branch_id#">
            
            <cfstoredproc procedure="sp_ops_task_save" datasource="#application.dsn#">
                <cfprocparam cfsqltype="cf_sql_integer" value="#form.task_id#" null="#NOT len(form.task_id)#">
                <cfprocparam cfsqltype="cf_sql_varchar" value="#form.task_no#" null="#NOT len(form.task_no)#">
                <cfprocparam cfsqltype="cf_sql_varchar" value="#form.task_head#">
                <cfprocparam cfsqltype="cf_sql_varchar" value="#form.task_detail#" null="#NOT len(form.task_detail)#">
                <cfprocparam cfsqltype="cf_sql_varchar" value="#form.ref_type#">
                <cfprocparam cfsqltype="cf_sql_integer" value="#form.ref_id#">
                <cfprocparam cfsqltype="cf_sql_integer" value="#form.parent_task_id#" null="#NOT len(form.parent_task_id)#">
                <cfprocparam cfsqltype="cf_sql_integer" value="#form.assigned_emp_id#" null="#NOT len(form.assigned_emp_id)#">
                <cfprocparam cfsqltype="cf_sql_timestamp" value="#form.planned_start#" null="#NOT isDate(form.planned_start)#">
                <cfprocparam cfsqltype="cf_sql_timestamp" value="#form.planned_finish#" null="#NOT isDate(form.planned_finish)#">
                <cfprocparam cfsqltype="cf_sql_timestamp" value="#form.deadline#" null="#NOT isDate(form.deadline)#">
                <cfprocparam cfsqltype="cf_sql_integer" value="#form.estimated_minutes#">
                <cfprocparam cfsqltype="cf_sql_integer" value="#form.status_id#" null="#NOT len(form.status_id)#">
                <cfprocparam cfsqltype="cf_sql_integer" value="#form.priority_id#" null="#NOT len(form.priority_id)#">
                <cfprocparam cfsqltype="cf_sql_decimal" value="#form.percent_complete#">
                <cfprocparam cfsqltype="cf_sql_bit" value="#form.has_matrix#">
                <cfprocparam cfsqltype="cf_sql_integer" value="#form.matrix_template_id#" null="#NOT len(form.matrix_template_id)#">
                <cfprocparam cfsqltype="cf_sql_integer" value="#form.company_id#">
                <cfprocparam cfsqltype="cf_sql_integer" value="#form.branch_id#" null="#NOT len(form.branch_id)#">
                <cfprocparam cfsqltype="cf_sql_integer" value="#session.employee_id#">
                <cfprocparam cfsqltype="cf_sql_varchar" value="#cgi.remote_addr#">
                <cfprocresult name="qResult">
            </cfstoredproc>
            
            <cfset response.success = true>
            <cfset response.data = {
                "task_id": qResult.TASK_ID,
                "action_type": qResult.ACTION_TYPE
            }>
            <cfset response.message = qResult.ACTION_TYPE eq "CREATE" ? "Görev oluşturuldu" : "Görev güncellendi">
        </cfcase>
        
        <!--- ========== DELETE ========== --->
        <cfcase value="delete">
            <cfparam name="form.task_id" default="0">
            
            <cfstoredproc procedure="sp_ops_task_delete" datasource="#application.dsn#">
                <cfprocparam cfsqltype="cf_sql_integer" value="#form.task_id#">
                <cfprocparam cfsqltype="cf_sql_integer" value="#session.employee_id#">
                <cfprocparam cfsqltype="cf_sql_varchar" value="#cgi.remote_addr#">
                <cfprocresult name="qResult">
            </cfstoredproc>
            
            <cfset response.success = qResult.DELETED_COUNT gt 0>
            <cfset response.message = response.success ? "Görev silindi" : "Görev bulunamadı">
        </cfcase>
        
        <!--- ========== STEP SAVE ========== --->
        <cfcase value="step_save">
            <cfparam name="form.task_id" default="0">
            <cfparam name="form.steps_json" default="[]">
            
            <cfstoredproc procedure="sp_ops_task_step_save" datasource="#application.dsn#">
                <cfprocparam cfsqltype="cf_sql_integer" value="#form.task_id#">
                <cfprocparam cfsqltype="cf_sql_varchar" value="#form.steps_json#">
                <cfprocparam cfsqltype="cf_sql_integer" value="#session.employee_id#">
                <cfprocresult name="qResult">
            </cfstoredproc>
            
            <cfset response.success = true>
            <cfset response.data = {"inserted_count": qResult.INSERTED_COUNT}>
            <cfset response.message = "İş adımları kaydedildi">
        </cfcase>
        
        <!--- ========== NOTES GET ========== --->
        <cfcase value="notes_get">
            <cfparam name="form.task_id" default="0">
            
            <cfstoredproc procedure="sp_ops_task_notes_get" datasource="#application.dsn#">
                <cfprocparam cfsqltype="cf_sql_integer" value="#form.task_id#">
                <cfprocresult name="qNotes">
            </cfstoredproc>
            
            <cfset notes = []>
            <cfloop query="qNotes">
                <cfset arrayAppend(notes, {
                    "note_id": NOTE_ID,
                    "task_id": TASK_ID,
                    "note_head": NOTE_HEAD,
                    "note_body": NOTE_BODY,
                    "created_by": RECORD_EMP,
                    "created_by_name": CREATED_BY_NAME,
                    "created_date": dateTimeFormat(RECORD_DATE, "yyyy-mm-dd HH:nn")
                })>
            </cfloop>
            
            <cfset response.success = true>
            <cfset response.data = notes>
        </cfcase>
        
        <!--- ========== NOTE SAVE ========== --->
        <cfcase value="note_save">
            <cfparam name="form.task_id" default="0">
            <cfparam name="form.note_body" default="">
            <cfparam name="form.note_head" default="">
            <cfparam name="form.company_id" default="#session.company_id#">
            <cfparam name="form.period_id" default="#session.period_id#">
            
            <cfstoredproc procedure="sp_ops_task_note_save" datasource="#application.dsn#">
                <cfprocparam cfsqltype="cf_sql_integer" value="#form.task_id#">
                <cfprocparam cfsqltype="cf_sql_varchar" value="#form.note_body#">
                <cfprocparam cfsqltype="cf_sql_varchar" value="#form.note_head#" null="#NOT len(form.note_head)#">
                <cfprocparam cfsqltype="cf_sql_integer" value="#form.company_id#" null="#NOT len(form.company_id)#">
                <cfprocparam cfsqltype="cf_sql_integer" value="#form.period_id#" null="#NOT len(form.period_id)#">
                <cfprocparam cfsqltype="cf_sql_integer" value="#session.employee_id#">
                <cfprocresult name="qResult">
            </cfstoredproc>
            
            <cfset response.success = true>
            <cfset response.data = {"note_id": qResult.NOTE_ID}>
            <cfset response.message = "Not kaydedildi">
        </cfcase>
        
        <!--- ========== STAGE LIST ========== --->
        <cfcase value="stage_list">
            <cfparam name="form.template_id" default="1">
            
            <cfstoredproc procedure="sp_ops_task_stage_list" datasource="#application.dsn#">
                <cfprocparam cfsqltype="cf_sql_integer" value="#form.template_id#">
                <cfprocresult name="qStages">
            </cfstoredproc>
            
            <cfset stages = []>
            <cfloop query="qStages">
                <cfset arrayAppend(stages, {
                    "stage_dim_id": STAGE_DIM_ID,
                    "stage_code": STAGE_CODE,
                    "stage_name": STAGE_NAME,
                    "sort_order": SORT_ORDER
                })>
            </cfloop>
            
            <cfset response.success = true>
            <cfset response.data = stages>
        </cfcase>
        
        <!--- ========== STAGE SAVE ========== --->
        <cfcase value="stage_save">
            <cfparam name="form.task_id" default="0">
            <cfparam name="form.template_id" default="1">
            <cfparam name="form.stages_json" default="[]">
            
            <cfstoredproc procedure="sp_ops_task_stage_save" datasource="#application.dsn#">
                <cfprocparam cfsqltype="cf_sql_integer" value="#form.task_id#">
                <cfprocparam cfsqltype="cf_sql_integer" value="#form.template_id#">
                <cfprocparam cfsqltype="cf_sql_varchar" value="#form.stages_json#">
                <cfprocparam cfsqltype="cf_sql_integer" value="#session.employee_id#">
                <cfprocresult name="qResult">
            </cfstoredproc>
            
            <cfset response.success = true>
            <cfset response.data = {"stage_set_id": qResult.STAGE_SET_ID}>
            <cfset response.message = "Stage seçimi kaydedildi">
        </cfcase>
        
        <!--- ========== MATRIX GET ========== --->
        <cfcase value="matrix_get">
            <cfparam name="form.task_id" default="0">
            
            <cfstoredproc procedure="sp_ops_task_matrix_get" datasource="#application.dsn#">
                <cfprocparam cfsqltype="cf_sql_integer" value="#form.task_id#">
                <cfprocresult name="qResultType" resultset="1">
                <cfprocresult name="qTemplate" resultset="2">
                <cfprocresult name="qStages" resultset="3">
                <cfprocresult name="qCells" resultset="4">
                <cfprocresult name="qValues" resultset="5">
            </cfstoredproc>
            
            <cfset resultType = qResultType.result_type>
            
            <cfif resultType eq "NO_TEMPLATE">
                <cfset response.success = true>
                <cfset response.data = {"result_type": "NO_TEMPLATE"}>
            <cfelseif resultType eq "SELECT_STAGE">
                <!--- Stage seçimi gerekiyor, ikinci resultset stage listesi --->
                <cfset stages = []>
                <cfloop query="qTemplate">
                    <cfset arrayAppend(stages, {
                        "stage_dim_id": STAGE_DIM_ID,
                        "stage_code": STAGE_CODE,
                        "stage_name": STAGE_NAME,
                        "sort_order": SORT_ORDER
                    })>
                </cfloop>
                
                <cfset response.success = true>
                <cfset response.data = {
                    "result_type": "SELECT_STAGE",
                    "stages": stages
                }>
            <cfelse>
                <!--- Matris verileri --->
                <cfset template = {}>
                <cfif qTemplate.recordCount>
                    <cfset template = {
                        "template_id": qTemplate.TEMPLATE_ID,
                        "template_code": qTemplate.TEMPLATE_CODE,
                        "template_name": qTemplate.TEMPLATE_NAME
                    }>
                </cfif>
                
                <cfset stages = []>
                <cfloop query="qStages">
                    <cfset arrayAppend(stages, {
                        "stage_set_row_id": STAGE_SET_ROW_ID,
                        "stage_dim_id": STAGE_DIM_ID,
                        "stage_code": STAGE_CODE,
                        "stage_name": STAGE_NAME,
                        "sort_order": SORT_ORDER
                    })>
                </cfloop>
                
                <cfset cells = []>
                <cfloop query="qCells">
                    <cfset arrayAppend(cells, {
                        "cell_def_id": CELL_DEF_ID,
                        "stage_dim_id": STAGE_DIM_ID,
                        "sub_stage_dim_id": SUB_STAGE_DIM_ID,
                        "cell_label": CELL_LABEL,
                        "weight": WEIGHT,
                        "value_code": VALUE_CODE,
                        "stage_code": STAGE_CODE,
                        "sub_stage_code": SUB_STAGE_CODE
                    })>
                </cfloop>
                
                <cfset values = []>
                <cfloop query="qValues">
                    <cfset arrayAppend(values, {
                        "value_id": VALUE_ID,
                        "value_code": VALUE_CODE,
                        "value_label": VALUE_LABEL,
                        "score": SCORE,
                        "color_code": COLOR_CODE,
                        "sort_order": SORT_ORDER
                    })>
                </cfloop>
                
                <cfset response.success = true>
                <cfset response.data = {
                    "result_type": "MATRIX",
                    "instance_id": qResultType.instance_id,
                    "stage_set_id": qResultType.stage_set_id,
                    "template": template,
                    "stages": stages,
                    "cells": cells,
                    "values": values
                }>
            </cfif>
        </cfcase>
        
        <!--- ========== MATRIX SAVE ========== --->
        <cfcase value="matrix_save">
            <cfparam name="form.task_id" default="0">
            <cfparam name="form.cells_json" default="[]">
            
            <cfstoredproc procedure="sp_ops_task_matrix_save" datasource="#application.dsn#">
                <cfprocparam cfsqltype="cf_sql_integer" value="#form.task_id#">
                <cfprocparam cfsqltype="cf_sql_varchar" value="#form.cells_json#">
                <cfprocparam cfsqltype="cf_sql_integer" value="#session.employee_id#">
                <cfprocparam cfsqltype="cf_sql_varchar" value="#cgi.remote_addr#">
                <cfprocresult name="qResult">
            </cfstoredproc>
            
            <cfset response.success = true>
            <cfset response.data = {
                "instance_id": qResult.instance_id,
                "calc_percent": qResult.calc_percent,
                "status_id": qResult.status_id
            }>
            <cfset response.message = "Matris kaydedildi (%" & qResult.calc_percent & ")">
        </cfcase>
        
        <!--- ========== DEFAULT ========== --->
        <cfdefaultcase>
            <cfset response.message = "Geçersiz action: #form.action#">
        </cfdefaultcase>
        
    </cfswitch>
    
    <cfcatch type="any">
        <cfset response.success = false>
        <cfset response.message = cfcatch.message>
        <cfset response.detail = cfcatch.detail>
    </cfcatch>
    
</cftry>

</cfsilent>
<cfcontent type="application/json" reset="true">
<cfoutput>#serializeJSON(response)#</cfoutput>
