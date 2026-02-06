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

<!--- DSN SABİTLERİ (DEĞİŞMEZ) --->
<!--- dsn  (Main)   : workcube_prod       → OPS_TASK, EMPLOYEES --->
<!--- dsn3 (Şirket) : workcube_prod_1     → OPS_TASK_TEMPLATE, ORDERS --->
<cfif NOT isDefined("dsn")>
    <cfset dsn = "workcube_prod">
</cfif>
<cfset dsn3 = "workcube_prod_1">

<!--- Session fallback değerleri --->
<cfset currentEmployeeId = isDefined("session.ep.employee_id") ? session.ep.employee_id : 0>
<cfset currentBranchId = isDefined("session.ep.branch_id") ? session.ep.branch_id : 0>
<cfset currentCompanyId = isDefined("session.ep.company_id") ? session.ep.company_id : 1>
<cfset isAdmin = (isDefined("session.ep.admin") AND session.ep.admin eq 1) ? true : false>

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
            <cfparam name="form.company_id" default="#session.ep.company_id#">
            <cfparam name="form.status_id" default="">
            <cfparam name="form.assigned_emp_id" default="">
            
            <!--- Aşama listesi (Proje modülü ile aynı - hardcoded) --->
            <cfset stages = [
                {"stage_id":2358, "stage_name":"Planlama", "sort_order":1},
                {"stage_id":2359, "stage_name":"İş Atandı", "sort_order":2},
                {"stage_id":2361, "stage_name":"Başlandı - Devam", "sort_order":3},
                {"stage_id":2362, "stage_name":"Onay Bekleniyor", "sort_order":4},
                {"stage_id":2364, "stage_name":"Tamamlandı", "sort_order":5},
                {"stage_id":6, "stage_name":"Onaylandı", "sort_order":6},
                {"stage_id":2365, "stage_name":"İptal Edildi", "sort_order":7}
            ]>
            
            <!--- Doğrudan SQL sorgusu --->
            <cfquery name="qTasks" datasource="#dsn#">
                SELECT 
                    t.TASK_ID,
                    t.TASK_NO,
                    t.TASK_HEAD,
                    t.REF_TYPE,
                    t.REF_ID,
                    t.ASSIGNED_EMP_ID,
                    ISNULL(e.EMPLOYEE_NAME, '') AS EMP_NAME,
                    ISNULL(e.EMPLOYEE_SURNAME, '') AS EMP_SURNAME,
                    ISNULL(e.EMPLOYEE_NAME + ' ' + e.EMPLOYEE_SURNAME, '') AS ASSIGNED_NAME,
                    ISNULL(e.PHOTO, '') AS EMP_PHOTO,
                    t.PLANNED_START,
                    t.PLANNED_FINISH,
                    t.DEADLINE,
                    t.ESTIMATED_MINUTES,
                    ISNULL(t.ACTUAL_MINUTES, 0) AS ACTUAL_MINUTES,
                    t.STATUS_ID,
                    CASE 
                        WHEN t.STATUS_ID = 2361 THEN 'Devam Ediyor'
                        WHEN t.STATUS_ID = 2364 THEN 'Tamamlandı'
                        ELSE 'Bekliyor'
                    END AS STATUS_NAME,
                    t.PRIORITY_ID,
                    t.PERCENT_COMPLETE,
                    t.HAS_MATRIX,
                    t.MATRIX_TEMPLATE_ID,
                    t.IS_ACTIVE
                FROM OPS_TASK t
                LEFT JOIN EMPLOYEES e ON e.EMPLOYEE_ID = t.ASSIGNED_EMP_ID
                WHERE t.REF_TYPE = <cfqueryparam value="#form.ref_type#" cfsqltype="cf_sql_varchar">
                  AND t.REF_ID = <cfqueryparam value="#form.ref_id#" cfsqltype="cf_sql_integer">
                  AND t.COMPANY_ID = <cfqueryparam value="#form.company_id#" cfsqltype="cf_sql_integer">
                  AND t.IS_ACTIVE = 1
                <cfif len(form.status_id)>
                  AND t.STATUS_ID = <cfqueryparam value="#form.status_id#" cfsqltype="cf_sql_integer">
                </cfif>
                <cfif len(form.assigned_emp_id)>
                  AND t.ASSIGNED_EMP_ID = <cfqueryparam value="#form.assigned_emp_id#" cfsqltype="cf_sql_integer">
                </cfif>
                ORDER BY t.DEADLINE ASC, t.TASK_ID ASC
            </cfquery>
            
            <cfset tasks = []>
            <cfloop query="qTasks">
                <cfset arrayAppend(tasks, {
                    "task_id": TASK_ID,
                    "task_no": TASK_NO,
                    "task_head": TASK_HEAD,
                    "ref_type": REF_TYPE,
                    "ref_id": REF_ID,
                    "assigned_emp_id": ASSIGNED_EMP_ID,
                    "emp_name": EMP_NAME,
                    "emp_surname": EMP_SURNAME,
                    "assigned_name": ASSIGNED_NAME,
                    "emp_photo": EMP_PHOTO,
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
                    "is_active": IS_ACTIVE
                })>
            </cfloop>
            
            <cfset response.success = true>
            <cfset response.data = tasks>
            <cfset response.stages = stages>
        </cfcase>
        
        <!--- ========== GET ========== --->
        <cfcase value="get">
            <cfparam name="form.task_id" default="0">
            
            <cfstoredproc procedure="sp_ops_task_get" datasource="#dsn#">
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
            <cfparam name="form.company_id" default="#currentCompanyId#">
            <cfparam name="form.branch_id" default="#currentBranchId#">
            
            <!--- Yüzdeye göre status belirle --->
            <cfset pct = val(form.percent_complete)>
            <cfset autoStatus = "">
            <cfif pct EQ 0>
                <cfset autoStatus = ""><!--- NULL --->
            <cfelseif pct GTE 100>
                <cfset autoStatus = 2364><!--- Tamamlandı --->
            <cfelse>
                <cfset autoStatus = 2361><!--- Devam Ediyor --->
            </cfif>
            <cfif NOT len(form.status_id) AND len(autoStatus)>
                <cfset form.status_id = autoStatus>
            </cfif>
            
            <cfif len(form.task_id) AND val(form.task_id) GT 0>
                <!--- UPDATE --->
                <cfquery datasource="#dsn#">
                    UPDATE OPS_TASK SET
                        TASK_HEAD = <cfqueryparam value="#form.task_head#" cfsqltype="cf_sql_varchar">,
                        TASK_DETAIL = <cfqueryparam value="#form.task_detail#" cfsqltype="cf_sql_varchar" null="#NOT len(form.task_detail)#">,
                        ASSIGNED_EMP_ID = <cfqueryparam value="#form.assigned_emp_id#" cfsqltype="cf_sql_integer" null="#NOT len(form.assigned_emp_id)#">,
                        PLANNED_START = <cfqueryparam value="#form.planned_start#" cfsqltype="cf_sql_timestamp" null="#NOT isDate(form.planned_start)#">,
                        PLANNED_FINISH = <cfqueryparam value="#form.planned_finish#" cfsqltype="cf_sql_timestamp" null="#NOT isDate(form.planned_finish)#">,
                        DEADLINE = <cfqueryparam value="#form.deadline#" cfsqltype="cf_sql_timestamp" null="#NOT isDate(form.deadline)#">,
                        ESTIMATED_MINUTES = <cfqueryparam value="#val(form.estimated_minutes)#" cfsqltype="cf_sql_integer">,
                        STATUS_ID = <cfqueryparam value="#form.status_id#" cfsqltype="cf_sql_integer" null="#NOT len(form.status_id)#">,
                        PRIORITY_ID = <cfqueryparam value="#form.priority_id#" cfsqltype="cf_sql_integer" null="#NOT len(form.priority_id)#">,
                        PERCENT_COMPLETE = <cfqueryparam value="#val(form.percent_complete)#" cfsqltype="cf_sql_decimal">,
                        HAS_MATRIX = <cfqueryparam value="#val(form.has_matrix)#" cfsqltype="cf_sql_bit">,
                        MATRIX_TEMPLATE_ID = <cfqueryparam value="#form.matrix_template_id#" cfsqltype="cf_sql_integer" null="#NOT len(form.matrix_template_id)#">,
                        UPDATED_DATE = GETDATE(),
                        UPDATED_BY = <cfqueryparam value="#currentEmployeeId#" cfsqltype="cf_sql_integer">
                    WHERE TASK_ID = <cfqueryparam value="#form.task_id#" cfsqltype="cf_sql_integer">
                </cfquery>
                <cfset newTaskId = form.task_id>
                <cfset actionType = "UPDATE">
            <cfelse>
                <!--- INSERT --->
                <cfquery name="qInsert" datasource="#dsn#">
                    INSERT INTO OPS_TASK (
                        TASK_NO, TASK_HEAD, TASK_DETAIL, REF_TYPE, REF_ID, PARENT_TASK_ID,
                        ASSIGNED_EMP_ID, PLANNED_START, PLANNED_FINISH, DEADLINE,
                        ESTIMATED_MINUTES, STATUS_ID, PRIORITY_ID, PERCENT_COMPLETE,
                        HAS_MATRIX, MATRIX_TEMPLATE_ID, COMPANY_ID, BRANCH_ID,
                        IS_ACTIVE, CREATED_DATE, CREATED_BY
                    )
                    OUTPUT INSERTED.TASK_ID
                    VALUES (
                        <cfqueryparam value="#form.task_no#" cfsqltype="cf_sql_varchar" null="#NOT len(form.task_no)#">,
                        <cfqueryparam value="#form.task_head#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#form.task_detail#" cfsqltype="cf_sql_varchar" null="#NOT len(form.task_detail)#">,
                        <cfqueryparam value="#form.ref_type#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#form.ref_id#" cfsqltype="cf_sql_integer">,
                        <cfqueryparam value="#form.parent_task_id#" cfsqltype="cf_sql_integer" null="#NOT len(form.parent_task_id)#">,
                        <cfqueryparam value="#form.assigned_emp_id#" cfsqltype="cf_sql_integer" null="#NOT len(form.assigned_emp_id)#">,
                        <cfqueryparam value="#form.planned_start#" cfsqltype="cf_sql_timestamp" null="#NOT isDate(form.planned_start)#">,
                        <cfqueryparam value="#form.planned_finish#" cfsqltype="cf_sql_timestamp" null="#NOT isDate(form.planned_finish)#">,
                        <cfqueryparam value="#form.deadline#" cfsqltype="cf_sql_timestamp" null="#NOT isDate(form.deadline)#">,
                        <cfqueryparam value="#val(form.estimated_minutes)#" cfsqltype="cf_sql_integer">,
                        <cfqueryparam value="#form.status_id#" cfsqltype="cf_sql_integer" null="#NOT len(form.status_id)#">,
                        <cfqueryparam value="#form.priority_id#" cfsqltype="cf_sql_integer" null="#NOT len(form.priority_id)#">,
                        <cfqueryparam value="#val(form.percent_complete)#" cfsqltype="cf_sql_decimal">,
                        <cfqueryparam value="#val(form.has_matrix)#" cfsqltype="cf_sql_bit">,
                        <cfqueryparam value="#form.matrix_template_id#" cfsqltype="cf_sql_integer" null="#NOT len(form.matrix_template_id)#">,
                        <cfqueryparam value="#form.company_id#" cfsqltype="cf_sql_integer">,
                        <cfqueryparam value="#form.branch_id#" cfsqltype="cf_sql_integer" null="#NOT len(form.branch_id)#">,
                        1,
                        GETDATE(),
                        <cfqueryparam value="#currentEmployeeId#" cfsqltype="cf_sql_integer">
                    )
                </cfquery>
                <cfset newTaskId = qInsert.TASK_ID>
                <cfset actionType = "CREATE">
            </cfif>
            
            <cfset response.success = true>
            <cfset response.data = {
                "task_id": newTaskId,
                "action_type": actionType
            }>
            <cfset response.message = actionType eq "CREATE" ? "Görev oluşturuldu" : "Görev güncellendi">
        </cfcase>
        
        <!--- ========== DELETE ========== --->
        <cfcase value="delete">
            <cfparam name="form.task_id" default="0">
            
            <!--- Soft delete --->
            <cfquery name="qDelete" datasource="#dsn#">
                UPDATE OPS_TASK 
                SET IS_ACTIVE = 0, 
                    UPDATED_DATE = GETDATE(),
                    UPDATED_BY = <cfqueryparam value="#currentEmployeeId#" cfsqltype="cf_sql_integer">
                WHERE TASK_ID = <cfqueryparam value="#form.task_id#" cfsqltype="cf_sql_integer">
            </cfquery>
            
            <cfset response.success = true>
            <cfset response.message = "Görev silindi">
        </cfcase>
        
        <!--- ========== UPDATE DEADLINE (Inline) ========== --->
        <cfcase value="update_deadline">
            <cfparam name="form.task_id" default="0">
            <cfparam name="form.deadline" default="">
            
            <cfquery datasource="#dsn#">
                UPDATE OPS_TASK 
                SET DEADLINE = <cfqueryparam value="#form.deadline#" cfsqltype="cf_sql_timestamp" null="#NOT isDate(form.deadline)#">,
                    UPDATED_DATE = GETDATE(),
                    UPDATED_BY = <cfqueryparam value="#currentEmployeeId#" cfsqltype="cf_sql_integer">
                WHERE TASK_ID = <cfqueryparam value="#form.task_id#" cfsqltype="cf_sql_integer">
            </cfquery>
            
            <cfset response.success = true>
        </cfcase>
        
        <!--- ========== UPDATE STATUS (Inline) ========== --->
        <cfcase value="update_status">
            <cfparam name="form.task_id" default="0">
            <cfparam name="form.status_id" default="">
            <cfparam name="form.percent_complete" default="">
            
            <cfquery datasource="#dsn#">
                UPDATE OPS_TASK 
                SET STATUS_ID = <cfqueryparam value="#form.status_id#" cfsqltype="cf_sql_integer" null="#NOT len(form.status_id)#">,
                    <cfif len(form.percent_complete)>
                    PERCENT_COMPLETE = <cfqueryparam value="#form.percent_complete#" cfsqltype="cf_sql_decimal">,
                    </cfif>
                    UPDATED_DATE = GETDATE(),
                    UPDATED_BY = <cfqueryparam value="#currentEmployeeId#" cfsqltype="cf_sql_integer">
                WHERE TASK_ID = <cfqueryparam value="#form.task_id#" cfsqltype="cf_sql_integer">
            </cfquery>
            
            <cfset response.success = true>
        </cfcase>
        
        <!--- ========== UPDATE PERCENT (Inline) ========== --->
        <cfcase value="update_percent">
            <cfparam name="form.task_id" default="0">
            <cfparam name="form.percent_complete" default="0">
            
            <cfset pct = val(form.percent_complete)>
            <cfset autoStatus = "">
            <cfif pct EQ 0>
                <cfset autoStatus = "">
            <cfelseif pct GTE 100>
                <cfset autoStatus = 2364>
            <cfelse>
                <cfset autoStatus = 2361>
            </cfif>
            
            <cfquery datasource="#dsn#">
                UPDATE OPS_TASK 
                SET PERCENT_COMPLETE = <cfqueryparam value="#pct#" cfsqltype="cf_sql_decimal">,
                    STATUS_ID = <cfqueryparam value="#autoStatus#" cfsqltype="cf_sql_integer" null="#NOT len(autoStatus)#">,
                    UPDATED_DATE = GETDATE(),
                    UPDATED_BY = <cfqueryparam value="#currentEmployeeId#" cfsqltype="cf_sql_integer">
                WHERE TASK_ID = <cfqueryparam value="#form.task_id#" cfsqltype="cf_sql_integer">
            </cfquery>
            
            <!--- Sipariş ve Proje % hesapla (zincirleme) --->
            <cftry>
                <!--- Task'ın bağlı olduğu siparişi bul --->
                <cfquery name="qTaskOrder" datasource="#dsn#">
                    SELECT REF_ID AS ORDER_ID FROM OPS_TASK WHERE TASK_ID = <cfqueryparam value="#form.task_id#" cfsqltype="cf_sql_integer">
                </cfquery>
                
                <cfif qTaskOrder.recordCount AND val(qTaskOrder.ORDER_ID) GT 0>
                    <!--- Sipariş % = Tüm task'ların ortalaması --->
                    <cfquery name="qOrderPct" datasource="#dsn#">
                        SELECT AVG(PERCENT_COMPLETE) AS AVG_PCT 
                        FROM OPS_TASK 
                        WHERE REF_TYPE = 'ORDER' AND REF_ID = <cfqueryparam value="#qTaskOrder.ORDER_ID#" cfsqltype="cf_sql_integer"> AND IS_ACTIVE = 1
                    </cfquery>
                    <cfset orderPct = val(qOrderPct.AVG_PCT)>
                    <cfset response.order_pct = orderPct>
                    
                    <!--- Siparişin bağlı olduğu projeyi bul --->
                    <cfquery name="qOrderProject" datasource="#dsn3#">
                        SELECT PROJECT_ID FROM ORDERS WHERE ORDER_ID = <cfqueryparam value="#qTaskOrder.ORDER_ID#" cfsqltype="cf_sql_integer">
                    </cfquery>
                    
                    <cfif qOrderProject.recordCount AND val(qOrderProject.PROJECT_ID) GT 0>
                        <!--- Proje % = Tüm siparişlerin task ortalamalarının ortalaması --->
                        <cfquery name="qProjectPct" datasource="#dsn#">
                            SELECT AVG(t.PERCENT_COMPLETE) AS AVG_PCT
                            FROM OPS_TASK t
                            INNER JOIN #dsn3#..ORDERS o ON t.REF_ID = o.ORDER_ID
                            WHERE t.REF_TYPE = 'ORDER' AND o.PROJECT_ID = <cfqueryparam value="#qOrderProject.PROJECT_ID#" cfsqltype="cf_sql_integer"> AND t.IS_ACTIVE = 1
                        </cfquery>
                        <cfset projectPct = val(qProjectPct.AVG_PCT)>
                        
                        <!--- Proje COMPLETION_RATE güncelle --->
                        <cfquery datasource="#dsn#">
                            UPDATE PRO_PROJECTS 
                            SET COMPLETION_RATE = <cfqueryparam value="#projectPct#" cfsqltype="cf_sql_decimal">
                            WHERE PROJECT_ID = <cfqueryparam value="#qOrderProject.PROJECT_ID#" cfsqltype="cf_sql_integer">
                        </cfquery>
                        <cfset response.project_pct = projectPct>
                        <cfset response.project_id = qOrderProject.PROJECT_ID>
                    </cfif>
                </cfif>
            <cfcatch>
                <cfset response.calc_error = cfcatch.message>
            </cfcatch>
            </cftry>
            
            <cfset response.success = true>
        </cfcase>
        
        <!--- ========== UPDATE STAGE (Dropdown değişince) ========== --->
        <cfcase value="update_stage">
            <cfparam name="form.task_id" default="0">
            <cfparam name="form.status_id" default="0">
            <cfparam name="form.percent_complete" default="0">
            
            <cfset stId = val(form.status_id)>
            <cfset pct = val(form.percent_complete)>
            
            <!--- Tamamlandı/Onaylandı → %100, diğer → gelen değer (elle yazılan) --->
            <cfif stId EQ 2364 OR stId EQ 2365>
                <cfset pct = 100>
            <cfelseif pct LT 0>
                <!--- -1 = mevcut yüzdeyi koru --->
                <cfquery name="qCurPct" datasource="#dsn#">
                    SELECT PERCENT_COMPLETE FROM OPS_TASK WHERE TASK_ID = <cfqueryparam value="#form.task_id#" cfsqltype="cf_sql_integer">
                </cfquery>
                <cfset pct = val(qCurPct.PERCENT_COMPLETE)>
            </cfif>
            
            <cfquery datasource="#dsn#">
                UPDATE OPS_TASK 
                SET STATUS_ID = <cfqueryparam value="#stId#" cfsqltype="cf_sql_integer">,
                    PERCENT_COMPLETE = <cfqueryparam value="#pct#" cfsqltype="cf_sql_decimal">,
                    UPDATED_DATE = GETDATE(),
                    UPDATED_BY = <cfqueryparam value="#currentEmployeeId#" cfsqltype="cf_sql_integer">
                WHERE TASK_ID = <cfqueryparam value="#form.task_id#" cfsqltype="cf_sql_integer">
            </cfquery>
            
            <!--- Sipariş ve Proje % hesapla --->
            <cftry>
                <cfquery name="qTaskOrder" datasource="#dsn#">
                    SELECT REF_ID AS ORDER_ID FROM OPS_TASK WHERE TASK_ID = <cfqueryparam value="#form.task_id#" cfsqltype="cf_sql_integer">
                </cfquery>
                <cfif qTaskOrder.recordCount AND val(qTaskOrder.ORDER_ID) GT 0>
                    <cfquery name="qOrderPct" datasource="#dsn#">
                        SELECT AVG(PERCENT_COMPLETE) AS AVG_PCT FROM OPS_TASK WHERE REF_TYPE = 'ORDER' AND REF_ID = <cfqueryparam value="#qTaskOrder.ORDER_ID#" cfsqltype="cf_sql_integer"> AND IS_ACTIVE = 1
                    </cfquery>
                    <cfset response.order_pct = val(qOrderPct.AVG_PCT)>
                    
                    <cfquery name="qOrderProject" datasource="#dsn3#">
                        SELECT PROJECT_ID FROM ORDERS WHERE ORDER_ID = <cfqueryparam value="#qTaskOrder.ORDER_ID#" cfsqltype="cf_sql_integer">
                    </cfquery>
                    <cfif qOrderProject.recordCount AND val(qOrderProject.PROJECT_ID) GT 0>
                        <cfquery name="qProjectPct" datasource="#dsn#">
                            SELECT AVG(t.PERCENT_COMPLETE) AS AVG_PCT FROM OPS_TASK t INNER JOIN #dsn3#..ORDERS o ON t.REF_ID = o.ORDER_ID WHERE t.REF_TYPE = 'ORDER' AND o.PROJECT_ID = <cfqueryparam value="#qOrderProject.PROJECT_ID#" cfsqltype="cf_sql_integer"> AND t.IS_ACTIVE = 1
                        </cfquery>
                        <cfset response.project_pct = val(qProjectPct.AVG_PCT)>
                        <cfset response.project_id = qOrderProject.PROJECT_ID>
                    </cfif>
                </cfif>
            <cfcatch>
                <cfset response.calc_error = cfcatch.message>
            </cfcatch>
            </cftry>
            
            <cfset response.success = true>
            <cfset response.percent_complete = pct>
        </cfcase>
        
        <!--- ========== STEP SAVE - Devre dışı ========== --->
        <cfcase value="step_save">
            <cfset response.success = true>
            <cfset response.message = "İş adımları şu an desteklenmiyor">
        </cfcase>
        
        <!--- ========== NOTES GET ========== --->
        <cfcase value="notes_get">
            <cfparam name="form.task_id" default="0">
            
            <cfstoredproc procedure="sp_ops_task_notes_get" datasource="#dsn#">
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
            <cfparam name="form.company_id" default="#session.ep.company_id#">
            <cfparam name="form.period_id" default="#session.ep.period_id#">
            
            <cfstoredproc procedure="sp_ops_task_note_save" datasource="#dsn#">
                <cfprocparam cfsqltype="cf_sql_integer" value="#form.task_id#">
                <cfprocparam cfsqltype="cf_sql_varchar" value="#form.note_body#">
                <cfprocparam cfsqltype="cf_sql_varchar" value="#form.note_head#" null="#NOT len(form.note_head)#">
                <cfprocparam cfsqltype="cf_sql_integer" value="#form.company_id#" null="#NOT len(form.company_id)#">
                <cfprocparam cfsqltype="cf_sql_integer" value="#form.period_id#" null="#NOT len(form.period_id)#">
                <cfprocparam cfsqltype="cf_sql_integer" value="#session.ep.employee_id#">
                <cfprocresult name="qResult">
            </cfstoredproc>
            
            <cfset response.success = true>
            <cfset response.data = {"note_id": qResult.NOTE_ID}>
            <cfset response.message = "Not kaydedildi">
        </cfcase>
        
        <!--- ========== STAGE LIST ========== --->
        <cfcase value="stage_list">
            <cfparam name="form.template_id" default="1">
            
            <cfstoredproc procedure="sp_ops_task_stage_list" datasource="#dsn#">
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
            
            <cfstoredproc procedure="sp_ops_task_stage_save" datasource="#dsn#">
                <cfprocparam cfsqltype="cf_sql_integer" value="#form.task_id#">
                <cfprocparam cfsqltype="cf_sql_integer" value="#form.template_id#">
                <cfprocparam cfsqltype="cf_sql_varchar" value="#form.stages_json#">
                <cfprocparam cfsqltype="cf_sql_integer" value="#session.ep.employee_id#">
                <cfprocresult name="qResult">
            </cfstoredproc>
            
            <cfset response.success = true>
            <cfset response.data = {"stage_set_id": qResult.STAGE_SET_ID}>
            <cfset response.message = "Stage seçimi kaydedildi">
        </cfcase>
        
        <!--- ========== MATRIX GET ========== --->
        <cfcase value="matrix_get">
            <cfparam name="form.task_id" default="0">
            
            <cfstoredproc procedure="sp_ops_task_matrix_get" datasource="#dsn#">
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
            
            <cfstoredproc procedure="sp_ops_task_matrix_save" datasource="#dsn#">
                <cfprocparam cfsqltype="cf_sql_integer" value="#form.task_id#">
                <cfprocparam cfsqltype="cf_sql_varchar" value="#form.cells_json#">
                <cfprocparam cfsqltype="cf_sql_integer" value="#session.ep.employee_id#">
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
        
        <!--- ========== GET TEMPLATES ========== --->
        <cfcase value="get_templates">
            <cfparam name="form.company_id" default="#currentCompanyId#">
            
            <cfset taskService = createObject("component", "V16.sales.cfc.ops_task_service")>
            <cfset qTemplates = taskService.getTemplates(form.company_id)>
            
            <cfset templates = []>
            <cfloop query="qTemplates">
                <cfset arrayAppend(templates, {
                    "template_id": TEMPLATE_ID,
                    "template_code": TEMPLATE_CODE,
                    "template_name": TEMPLATE_NAME,
                    "description": DESCRIPTION,
                    "is_default": IS_DEFAULT,
                    "item_count": ITEM_COUNT
                })>
            </cfloop>
            
            <cfset response.success = true>
            <cfset response.data = templates>
        </cfcase>
        
        <!--- ========== GET TEMPLATE ITEMS ========== --->
        <cfcase value="get_template_items">
            <cfparam name="form.template_id" default="0">
            
            <cfset taskService = createObject("component", "V16.sales.cfc.ops_task_service")>
            <cfset qItems = taskService.getTemplateItems(form.template_id)>
            
            <cfset items = []>
            <cfloop query="qItems">
                <cfset arrayAppend(items, {
                    "item_id": ITEM_ID,
                    "task_code": TASK_CODE,
                    "task_head": TASK_HEAD,
                    "task_detail": TASK_DETAIL,
                    "sort_order": SORT_ORDER,
                    "default_emp_id": DEFAULT_EMP_ID,
                    "default_emp_name": DEFAULT_EMP_NAME,
                    "default_priority_id": DEFAULT_PRIORITY_ID,
                    "default_days_offset": DEFAULT_DAYS_OFFSET,
                    "default_estimated_minutes": DEFAULT_ESTIMATED_MINUTES,
                    "has_production_matrix": HAS_PRODUCTION_MATRIX,
                    "is_mandatory": IS_MANDATORY
                })>
            </cfloop>
            
            <cfset response.success = true>
            <cfset response.data = items>
        </cfcase>
        
        <!--- ========== BATCH PREVIEW ========== --->
        <cfcase value="batch_preview">
            <cfparam name="form.ref_type" default="ORDER">
            <cfparam name="form.ref_id" default="0">
            <cfparam name="form.template_id" default="0">
            <cfparam name="form.selected_codes" default="">
            <cfparam name="form.strategy" default="skip_existing">
            <cfparam name="form.company_id" default="#currentCompanyId#">
            
            <cfset taskService = createObject("component", "V16.sales.cfc.ops_task_service")>
            <cfset previewResult = taskService.batchPreview(form.ref_type, form.ref_id, form.template_id, form.selected_codes, form.strategy, currentEmployeeId, form.company_id)>
            
            <cfset response.success = previewResult.success>
            <cfset response.message = previewResult.message>
            <cfif previewResult.success>
                <cfset response.data = {
                    "items": previewResult.items,
                    "base_date": previewResult.base_date,
                    "summary": previewResult.summary
                }>
            </cfif>
        </cfcase>
        
        <!--- ========== BATCH CREATE ========== --->
        <cfcase value="batch_create">
            <cfparam name="form.ref_type" default="ORDER">
            <cfparam name="form.ref_id" default="0">
            <cfparam name="form.template_id" default="0">
            <cfparam name="form.selected_codes" default="">
            <cfparam name="form.strategy" default="skip_existing">
            <cfparam name="form.company_id" default="#currentCompanyId#">
            <cfparam name="form.branch_id" default="#currentBranchId#">
            
            <cfset taskService = createObject("component", "V16.sales.cfc.ops_task_service")>
            <cfset createResult = taskService.batchCreate(form.ref_type, form.ref_id, form.template_id, form.selected_codes, form.strategy, currentEmployeeId, form.company_id, form.branch_id)>
            
            <cfset response.success = createResult.success>
            <cfset response.message = createResult.message>
            <cfif createResult.success>
                <cfset response.data = {
                    "batch_id": createResult.batch_id,
                    "summary": createResult.summary,
                    "items": createResult.items
                }>
            </cfif>
        </cfcase>
        
        <!--- ========== CREATE FROM TEMPLATE (Rapor kısayolu) ========== --->
        <cfcase value="create_from_template">
            <cfparam name="form.ref_type" default="ORDER">
            <cfparam name="form.ref_id" default="0">
            <cfparam name="form.template_id" default="-1">
            <cfparam name="form.strategy" default="skip_existing">
            <cfparam name="form.company_id" default="#currentCompanyId#">
            <cfparam name="form.branch_id" default="#currentBranchId#">
            
            <cfset taskService = createObject("component", "V16.sales.cfc.ops_task_service")>
            <cfset createResult = taskService.batchCreate(form.ref_type, form.ref_id, form.template_id, "", form.strategy, currentEmployeeId, form.company_id, form.branch_id)>
            
            <cfset response.success = createResult.success>
            <cfset response.message = createResult.message>
            <cfif createResult.success>
                <cfset response.data = {
                    "batch_id": createResult.batch_id,
                    "summary": createResult.summary,
                    "items": createResult.items
                }>
            </cfif>
        </cfcase>
        
        <!--- ========== EMPLOYEE SEARCH ========== --->
        <cfcase value="employee_search">
            <cfparam name="form.q" default="">
            
            <cfif len(form.q) GTE 3>
                <cfquery name="qEmp" datasource="#dsn#" maxrows="15">
                    SELECT EMPLOYEE_ID, EMPLOYEE_NAME, EMPLOYEE_SURNAME
                    FROM EMPLOYEES
                    WHERE (EMPLOYEE_NAME LIKE <cfqueryparam value="%#form.q#%" cfsqltype="cf_sql_varchar">
                           OR EMPLOYEE_SURNAME LIKE <cfqueryparam value="%#form.q#%" cfsqltype="cf_sql_varchar">)
                    ORDER BY EMPLOYEE_NAME, EMPLOYEE_SURNAME
                </cfquery>
                
                <cfset employees = []>
                <cfloop query="qEmp">
                    <cfset arrayAppend(employees, {
                        "employee_id": EMPLOYEE_ID,
                        "name": EMPLOYEE_NAME & " " & EMPLOYEE_SURNAME
                    })>
                </cfloop>
                
                <cfset response.success = true>
                <cfset response.data = employees>
            <cfelse>
                <cfset response.success = false>
                <cfset response.message = "En az 3 karakter gerekli">
            </cfif>
        </cfcase>
        
        <!--- ========== UPDATE SORT ORDER (Sürükle-Bırak) ========== --->
        <!--- NOT: SORT_ORDER alanı tabloda yok, sürükle-bırak sadece UI'da çalışır --->
        <cfcase value="update_sort_order">
            <cfset response.success = true>
            <cfset response.message = "Sıralama güncellendi (UI only)">
        </cfcase>
        
        <!--- ========== GET PROJECT ID (Siparişten) ========== --->
        <cfcase value="get_project_id">
            <cfparam name="form.order_id" default="0">
            
            <cfquery name="qOrderProject" datasource="#dsn3#">
                SELECT PROJECT_ID FROM ORDERS WHERE ORDER_ID = <cfqueryparam value="#form.order_id#" cfsqltype="cf_sql_integer">
            </cfquery>
            
            <cfif qOrderProject.recordCount AND val(qOrderProject.PROJECT_ID) GT 0>
                <cfset response.success = true>
                <cfset response.project_id = qOrderProject.PROJECT_ID>
            <cfelse>
                <cfset response.success = false>
                <cfset response.message = "Proje bulunamadı">
            </cfif>
        </cfcase>
        
        <!--- ========== UPDATE PROJECT (Inline Edit) ========== --->
        <cfcase value="update_project">
            <cfparam name="form.project_id" default="0">
            <cfparam name="form.field" default="">
            <cfparam name="form.value" default="">
            
            <cfswitch expression="#form.field#">
                <cfcase value="project_head">
                    <cfquery datasource="#dsn#">
                        UPDATE PRO_PROJECTS SET PROJECT_HEAD = <cfqueryparam value="#form.value#" cfsqltype="cf_sql_varchar"> WHERE PROJECT_ID = <cfqueryparam value="#form.project_id#" cfsqltype="cf_sql_integer">
                    </cfquery>
                </cfcase>
                <cfcase value="process_cat">
                    <cfquery datasource="#dsn#">
                        UPDATE PRO_PROJECTS SET PROCESS_CAT = <cfqueryparam value="#form.value#" cfsqltype="cf_sql_integer"> WHERE PROJECT_ID = <cfqueryparam value="#form.project_id#" cfsqltype="cf_sql_integer">
                    </cfquery>
                </cfcase>
                <cfcase value="priority">
                    <cfquery datasource="#dsn#">
                        UPDATE PRO_PROJECTS SET PRO_PRIORITY_ID = <cfqueryparam value="#form.value#" cfsqltype="cf_sql_integer"> WHERE PROJECT_ID = <cfqueryparam value="#form.project_id#" cfsqltype="cf_sql_integer">
                    </cfquery>
                </cfcase>
                <cfcase value="target_start">
                    <cfquery datasource="#dsn#">
                        UPDATE PRO_PROJECTS SET TARGET_START = <cfqueryparam value="#form.value#" cfsqltype="cf_sql_timestamp" null="#NOT isDate(form.value)#"> WHERE PROJECT_ID = <cfqueryparam value="#form.project_id#" cfsqltype="cf_sql_integer">
                    </cfquery>
                </cfcase>
                <cfcase value="target_finish">
                    <cfquery datasource="#dsn#">
                        UPDATE PRO_PROJECTS SET TARGET_FINISH = <cfqueryparam value="#form.value#" cfsqltype="cf_sql_timestamp" null="#NOT isDate(form.value)#"> WHERE PROJECT_ID = <cfqueryparam value="#form.project_id#" cfsqltype="cf_sql_integer">
                    </cfquery>
                </cfcase>
            </cfswitch>
            
            <cfset response.success = true>
            <cfset response.message = "Proje güncellendi">
        </cfcase>
        
        <!--- ========== UPDATE TIME (Inline Süre) ========== --->
        <cfcase value="update_time">
            <cfparam name="form.task_id" default="0">
            <cfparam name="form.field" default="">
            <cfparam name="form.value" default="0">
            
            <cfif form.field EQ "estimated_minutes">
                <cfquery datasource="#dsn#">
                    UPDATE OPS_TASK SET ESTIMATED_MINUTES = <cfqueryparam value="#val(form.value)#" cfsqltype="cf_sql_integer">,
                    UPDATED_DATE = GETDATE(), UPDATED_BY = <cfqueryparam value="#currentEmployeeId#" cfsqltype="cf_sql_integer">
                    WHERE TASK_ID = <cfqueryparam value="#form.task_id#" cfsqltype="cf_sql_integer">
                </cfquery>
            <cfelseif form.field EQ "actual_minutes">
                <cfquery datasource="#dsn#">
                    UPDATE OPS_TASK SET ACTUAL_MINUTES = <cfqueryparam value="#val(form.value)#" cfsqltype="cf_sql_integer">,
                    UPDATED_DATE = GETDATE(), UPDATED_BY = <cfqueryparam value="#currentEmployeeId#" cfsqltype="cf_sql_integer">
                    WHERE TASK_ID = <cfqueryparam value="#form.task_id#" cfsqltype="cf_sql_integer">
                </cfquery>
            </cfif>
            
            <cfset response.success = true>
        </cfcase>
        
        <!--- ========== DEFAULT ========== --->
        <cfdefaultcase>
            <cfset response.message = "Geçersiz action: #form.action#">
        </cfdefaultcase>
        
    </cfswitch>
    
    <cfcatch type="any">
        <cflog file="ops_task_errors" text="Action:#form.action# | Error:#cfcatch.message# | Detail:#cfcatch.detail#">
        <cfset response.success = false>
        <cfset response.message = cfcatch.message>
        <cfset response.detail = cfcatch.detail>
    </cfcatch>
    
</cftry>

</cfsilent>
<cfcontent type="application/json" reset="true">
<cfoutput>#serializeJSON(response)#</cfoutput>
