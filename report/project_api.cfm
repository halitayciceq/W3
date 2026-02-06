<!--- Modern Project API Endpoint --->
<cfcontent type="application/json">
<cfheader name="Access-Control-Allow-Origin" value="*">
<cfheader name="Access-Control-Allow-Methods" value="GET,POST,OPTIONS">
<cfheader name="Access-Control-Allow-Headers" value="Content-Type">

<cfparam name="url.action" default="getProjects">
<cfparam name="attributes.search" default="">
<cfparam name="attributes.category" default="">
<cfparam name="attributes.status" default="">
<cfparam name="attributes.page" default="1">
<cfparam name="attributes.pageSize" default="10">

<!--- JSON Body Parameters --->
<cfif structKeyExists(form, "body") or len(trim(getHTTPRequestData().content)) gt 0>
    <cftry>
        <cfset requestBody = deserializeJSON(getHTTPRequestData().content)>
        <cfloop collection="#requestBody#" item="key">
            <cfset attributes[key] = requestBody[key]>
        </cfloop>
    <cfcatch>
        <!--- Fallback to form/url parameters --->
    </cfcatch>
    </cftry>
</cfif>

<cftry>
    <cfswitch expression="#attributes.action#">
        
        <!--- Get Projects List --->
        <cfcase value="getProjects">
            <cfquery name="GET_PROJECT_COUNT" datasource="#DSN#">
                SELECT COUNT(*) as TOTAL_COUNT
                FROM PRO_PROJECTS P
                    LEFT JOIN EMPLOYEES EMP ON P.PROJECT_EMP_ID = EMP.EMPLOYEE_ID
                    LEFT JOIN SETUP_MAIN_PROCESS_CAT SMPC ON P.PROCESS_CAT = SMPC.MAIN_PROCESS_CAT_ID  
                    LEFT JOIN SETUP_PRIORITY SP ON P.PRO_PRIORITY_ID = SP.PRIORITY_ID
                WHERE 1 = 1
                    <cfif len(attributes.search)>
                        AND (P.PROJECT_NUMBER LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.search#%">
                             OR P.PROJECT_HEAD LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.search#%">
                             OR EMP.EMPLOYEE_NAME LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.search#%">)
                    </cfif>
                    <cfif len(attributes.category)>
                        AND SMPC.MAIN_PROCESS_CAT LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.category#%">
                    </cfif>
            </cfquery>

            <cfset startRow = ((attributes.page - 1) * attributes.pageSize) + 1>
            
            <cfquery name="GET_PROJECTS" datasource="#DSN#">
                SELECT TOP #attributes.pageSize#
                    P.PROJECT_ID,
                    P.PROJECT_NUMBER,
                    P.PROJECT_HEAD,
                    P.TARGET_START,
                    P.TARGET_FINISH,
                    P.PROJECT_EMP_ID,
                    P.PROCESS_CAT,
                    P.PRO_PRIORITY_ID,
                    
                    -- Personel bilgileri
                    EMP.EMPLOYEE_NAME,
                    EMP.EMPLOYEE_SURNAME,
                    
                    -- Kategori bilgileri
                    SMPC.MAIN_PROCESS_CAT,
                    
                    -- Öncelik bilgileri
                    SP.PRIORITY,
                    
                    -- Ülke bilgisi (sabit)
                    'TR' AS COUNTRY,
                    
                    -- Kalan zaman hesaplama
                    CASE 
                        WHEN P.TARGET_FINISH > GETDATE()
                        THEN DATEDIFF(day, GETDATE(), P.TARGET_FINISH)
                        WHEN P.TARGET_FINISH IS NULL
                        THEN 999
                        ELSE DATEDIFF(day, P.TARGET_FINISH, GETDATE()) * -1
                    END AS REMAINING_DAYS,
                    
                    -- Görev sayısı
                    (SELECT COUNT(*) FROM PRO_WORKS PW WHERE PW.PROJECT_ID = P.PROJECT_ID) AS TASK_COUNT,
                    
                    -- Tamamlanma yüzdesinin ortalaması
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
                WHERE 
                    P.PROJECT_ID NOT IN (
                        SELECT TOP #startRow - 1# P2.PROJECT_ID 
                        FROM PRO_PROJECTS P2
                        LEFT JOIN EMPLOYEES EMP2 ON P2.PROJECT_EMP_ID = EMP2.EMPLOYEE_ID
                        LEFT JOIN SETUP_MAIN_PROCESS_CAT SMPC2 ON P2.PROCESS_CAT = SMPC2.MAIN_PROCESS_CAT_ID
                        WHERE 1 = 1
                        <cfif len(attributes.search)>
                            AND (P2.PROJECT_NUMBER LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.search#%">
                                 OR P2.PROJECT_HEAD LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.search#%">
                                 OR EMP2.EMPLOYEE_NAME LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.search#%">)
                        </cfif>
                        <cfif len(attributes.category)>
                            AND SMPC2.MAIN_PROCESS_CAT LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.category#%">
                        </cfif>
                        ORDER BY P2.PROJECT_ID DESC
                    )
                    <cfif len(attributes.search)>
                        AND (P.PROJECT_NUMBER LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.search#%">
                             OR P.PROJECT_HEAD LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.search#%">
                             OR EMP.EMPLOYEE_NAME LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.search#%">)
                    </cfif>
                    <cfif len(attributes.category)>
                        AND SMPC.MAIN_PROCESS_CAT LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.category#%">
                    </cfif>
                ORDER BY P.PROJECT_ID DESC
            </cfquery>

            <!--- Transform data to JSON format --->
            <cfset projectsArray = []>
            
            <cfloop query="GET_PROJECTS">
                <!--- Determine status based on completion and dates --->
                <cfset projectStatus = "active">
                <cfif COMPLETION_RATE gte 100>
                    <cfset projectStatus = "completed">
                <cfelseif REMAINING_DAYS lt 0>
                    <cfset projectStatus = "delayed">
                </cfif>

                <!--- Get project tasks --->
                <cfquery name="GET_TASKS" datasource="#DSN#">
                    SELECT 
                        PW.WORK_ID,
                        PW.WORK_HEAD,
                        PW.TARGET_FINISH,
                        PW.TO_COMPLETE
                    FROM PRO_WORKS PW
                    WHERE PW.PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#PROJECT_ID#">
                    ORDER BY PW.WORK_ID
                </cfquery>

                <cfset tasksArray = []>
                <cfloop query="GET_TASKS">
                    <cfset arrayAppend(tasksArray, {
                        "id" = WORK_ID,
                        "name" = WORK_HEAD,
                        "completed" = (TO_COMPLETE gte 100),
                        "dueDate" = isDate(TARGET_FINISH) ? dateFormat(TARGET_FINISH, "dd/mm/yyyy") : ""
                    })>
                </cfloop>

                <cfset arrayAppend(projectsArray, {
                    "id" = PROJECT_ID,
                    "number" = PROJECT_NUMBER,
                    "name" = PROJECT_HEAD,
                    "responsible" = trim(EMPLOYEE_NAME & " " & EMPLOYEE_SURNAME),
                    "country" = COUNTRY,
                    "category" = MAIN_PROCESS_CAT ?: "Genel",
                    "status" = projectStatus,
                    "completion" = int(COMPLETION_RATE),
                    "startDate" = isDate(TARGET_START) ? dateFormat(TARGET_START, "dd/mm/yyyy") : "",
                    "endDate" = isDate(TARGET_FINISH) ? dateFormat(TARGET_FINISH, "dd/mm/yyyy") : "",
                    "remainingDays" = REMAINING_DAYS,
                    "priority" = PRIORITY ?: "Orta",
                    "tasks" = tasksArray
                })>
            </cfloop>

            <cfset response = {
                "success" = true,
                "projects" = projectsArray,
                "total" = GET_PROJECT_COUNT.TOTAL_COUNT,
                "page" = attributes.page,
                "pageSize" = attributes.pageSize,
                "totalPages" = ceiling(GET_PROJECT_COUNT.TOTAL_COUNT / attributes.pageSize)
            }>
        </cfcase>

        <!--- Get Project Statistics --->
        <cfcase value="getStats">
            <cfquery name="GET_STATS" datasource="#DSN#">
                SELECT 
                    COUNT(*) as TOTAL_PROJECTS,
                    SUM(CASE WHEN 
                        (SELECT AVG(ISNULL(PW.TO_COMPLETE, 0)) FROM PRO_WORKS PW WHERE PW.PROJECT_ID = P.PROJECT_ID) >= 100 
                        THEN 1 ELSE 0 END) as COMPLETED_PROJECTS,
                    SUM(CASE WHEN 
                        (SELECT AVG(ISNULL(PW.TO_COMPLETE, 0)) FROM PRO_WORKS PW WHERE PW.PROJECT_ID = P.PROJECT_ID) < 100 
                        AND P.TARGET_FINISH > GETDATE() 
                        THEN 1 ELSE 0 END) as ACTIVE_PROJECTS,
                    SUM(CASE WHEN 
                        P.TARGET_FINISH < GETDATE() 
                        AND (SELECT AVG(ISNULL(PW.TO_COMPLETE, 0)) FROM PRO_WORKS PW WHERE PW.PROJECT_ID = P.PROJECT_ID) < 100 
                        THEN 1 ELSE 0 END) as DELAYED_PROJECTS
                FROM PRO_PROJECTS P
            </cfquery>

            <cfset response = {
                "success" = true,
                "total" = GET_STATS.TOTAL_PROJECTS,
                "active" = GET_STATS.ACTIVE_PROJECTS,
                "completed" = GET_STATS.COMPLETED_PROJECTS,  
                "delayed" = GET_STATS.DELAYED_PROJECTS
            }>
        </cfcase>

        <cfdefaultcase>
            <cfset response = {
                "success" = false,
                "error" = "Invalid action: #attributes.action#"
            }>
        </cfdefaultcase>

    </cfswitch>

<cfcatch type="any">
    <cfset response = {
        "success" = false,
        "error" = "Database error: " & cfcatch.message,
        "detail" = cfcatch.detail
    }>
</cfcatch>
</cftry>

<cfoutput>#serializeJSON(response)#</cfoutput>
