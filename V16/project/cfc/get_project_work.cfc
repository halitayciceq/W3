<cfcomponent>
    <cfset dsn = application.systemParam.systemParam().dsn>
    <cffunction name="GET_PRO_WORK" access="remote" returntype="query">
        <cfargument name="project_id" default="">
        <cfargument name="work_status" default="">
        <cfargument name="work_milestones" default="">
        <cfargument name="ordertype" default="">
        <cfargument name="start_date" type="date" required="no">
        <cfargument name="finish_date" type="date" required="no">
        <cfargument name="keyword" type="string" required="no">

        <cfquery name="GET_PRO_WORK" datasource="#DSN#">
            SELECT
                *
            FROM
            (
                SELECT
                    CASE 
                        WHEN IS_MILESTONE = 1 THEN WORK_ID
                        WHEN IS_MILESTONE <> 1 THEN ISNULL(MILESTONE_WORK_ID,0)
                    END AS NEW_WORK_ID,
                    CASE 
                        WHEN IS_MILESTONE = 1 THEN 0
                        WHEN IS_MILESTONE <> 1 THEN 1
                    END AS TYPE,
                    PW.IS_MILESTONE,
                    PW.MILESTONE_WORK_ID,
                    PW.WORK_ID,
                    PW.WORK_HEAD,
                    PW.ESTIMATED_TIME,
                    (SELECT PTR.STAGE FROM PROCESS_TYPE_ROWS PTR WHERE PTR.PROCESS_ROW_ID= PW.WORK_CURRENCY_ID) STAGE,
                    (SELECT PWC.WORK_CAT FROM PRO_WORK_CAT PWC WHERE PWC.WORK_CAT_ID= PW.WORK_CAT_ID) WORK_CAT,
                    PW.WORK_PRIORITY_ID,
                    CASE 
                        WHEN PW.PROJECT_EMP_ID IS NOT NULL THEN (SELECT E.EMPLOYEE_ID FROM EMPLOYEES E WHERE E.EMPLOYEE_ID = PW.PROJECT_EMP_ID)
                    END AS EMPLOYEE,
                    PW.TARGET_FINISH,
                    PW.TARGET_START,
                    PW.REAL_FINISH,
                    PW.REAL_START,
                    PW.TO_COMPLETE,
                    PW.UPDATE_DATE,
                    PW.RECORD_DATE,
                    SP.PRIORITY,
                    SP.COLOR,
                    SA.ACTIVITY_NAME,
                    PW.RELATED_WORK_ID,
                    (SELECT E.EMPLOYEE_ID FROM EMPLOYEES E WHERE E.EMPLOYEE_ID = PW.PROJECT_EMP_ID) EMPLOYEE_ID
                FROM
                PRO_WORKS PW
                LEFT JOIN SETUP_PRIORITY SP ON PW.WORK_PRIORITY_ID = SP.PRIORITY_ID
                LEFT JOIN SETUP_ACTIVITY SA ON PW.ACTIVITY_ID = SA.ACTIVITY_ID
                WHERE
                    1 = 1
                    <cfif isdefined("arguments.project_id") and len(arguments.project_id)>
                        AND PW.PROJECT_ID =#arguments.project_id#
                    </cfif>
                    <cfif isdefined("arguments.work_status") and arguments.work_status eq -1>
                        AND PW.WORK_STATUS = 0 <!--- (PW.WORK_STATUS = 0 OR PW.IS_MILESTONE = 1) pasif olmayan üst işlerin gelmesine neden oluyordu FA --->
                    <cfelseif isdefined("arguments.work_status") and arguments.work_status eq 1>
                        AND PW.WORK_STATUS = 1 <!--- (PW.WORK_STATUS = 1 OR PW.IS_MILESTONE = 1) aktif olmayan üst işlerin gelmesine neden oluyordu GA --->
                    </cfif>
                    <cfif isdefined("arguments.start_date") and len(arguments.start_date)>AND PW.TARGET_START >= <cfqueryparam value = "#arguments.start_date#" CFSQLType = "cf_sql_timestamp"></cfif>
                    <cfif isdefined("arguments.finish_date") and len(arguments.finish_date)>AND PW.TARGET_FINISH <= <cfqueryparam value = "#arguments.finish_date#" CFSQLType = "cf_sql_timestamp"></cfif>
                    <cfif isdefined("arguments.keyword") and len(arguments.keyword)> AND PW.WORK_HEAD LIKE <cfqueryparam value = "%#arguments.keyword#%" CFSQLType = "cf_sql_nvarchar"></cfif>
            )T1
                WHERE
                    1=1 
                    <cfif isdefined("arguments.work_milestones") and arguments.work_milestones eq 0>
                        AND IS_MILESTONE <> 1
                        ORDER BY NEW_WORK_ID
                    <cfelse>
                        ORDER BY NEW_WORK_ID,TYPE
                    </cfif>       
                        
                <cfif isdefined("arguments.ordertype") and arguments.ordertype eq 1>
                        ,WORK_ID DESC
                <cfelseif isdefined("arguments.ordertype") and arguments.ordertype eq 2>
                        ,ISNULL(UPDATE_DATE,RECORD_DATE) DESC
                    <cfelseif isdefined("arguments.ordertype") and arguments.ordertype eq 3>
                    ,TARGET_START DESC
                    <cfelseif isdefined("arguments.ordertype") and arguments.ordertype eq 4>
                    ,TARGET_START
                    <cfelseif isdefined("arguments.ordertype") and arguments.ordertype eq 5>
                    ,TARGET_FINISH DESC
                    <cfelseif isdefined("arguments.ordertype") and arguments.ordertype eq 6>
                    ,TARGET_FINISH
                    <cfelseif isdefined("arguments.ordertype") and arguments.ordertype eq 7>
                    ,WORK_HEAD
                    </cfif>
        </cfquery>
        <cfreturn GET_PRO_WORK>
    </cffunction>
    <cffunction name="EMPLOYEE_PHOTO" access="remote" returntype="query">
        <cfargument name="employee_id" default="">
        <cfquery name="EMPLOYEE_PHOTO" datasource="#DSN#">
            SELECT 
                E.EMPLOYEE_NAME,
                E.EMPLOYEE_USERNAME,
                E.PHOTO,
                E2.SEX 
            FROM 
                EMPLOYEES AS E 
                LEFT JOIN EMPLOYEES_DETAIL AS E2 ON E2.EMPLOYEE_ID = E.EMPLOYEE_ID   
            WHERE E.EMPLOYEE_ID = #arguments.employee_id#
        </cfquery>
        <cfreturn EMPLOYEE_PHOTO>
    </cffunction>
    <cffunction name="UPD_TARGET"  access="remote"  returntype="any">
        <cfargument name="year">
        <cfargument name="month">
        <cfargument name="day">
        <cfargument name="hour">
        <cfargument name="minute">
        <cfargument name="start_hour">
        <cfargument name="start_year">
        <cfargument name="start_day">
        <cfargument name="start_month">
        <cfargument name="start_minute">
        <cfargument name="work_id">
        <cfargument name="to_complete">
        <cfargument name="daily">
        <cfset start_date_ =CreateDateTime(arguments.start_year, arguments.start_month, arguments.start_day, arguments.start_hour,arguments.start_minute,0) >
        <cfset finish_date_ =CreateDateTime(arguments.year, arguments.month, arguments.day, arguments.hour,arguments.minute,0) >          
        <cfif arguments.daily contains 'week' or arguments.daily contains 'year'>
            <cfset finish_date_ = dateadd('d',-1,finish_date_)><!---Bitiş tarihi bir gün sonrayı aldığı için----->              
        </cfif>
        <cfquery name="board_column" datasource="#dsn#">
            UPDATE  
                PRO_WORKS
            SET
                TARGET_START = #start_date_#,
                TARGET_FINISH = #finish_date_#,
                TO_COMPLETE = #arguments.to_complete#
            WHERE 
                WORK_ID = #work_id#
        </cfquery>
         <cfreturn 1>
    </cffunction>
    <cffunction name="UPD_RELATED"  access="remote"  returntype="any">
        <cfargument name="r_wrkid"> 
        <cfargument name="wrk_id">                
        <cfquery name="UPD_RELATED" datasource="#dsn#">
            UPDATE  
                PRO_WORKS
            SET
                RELATED_WORK_ID = '#r_wrkid#'
            WHERE 
                WORK_ID = #wrk_id#
        </cfquery>
        <cfreturn 1>
    </cffunction>
    <cffunction name="DEL_RELATED"  access="remote"  returntype="any"> 
        <cfargument name="wrk_id">                
        <cfquery name="DEL_RELATED" datasource="#dsn#">
            UPDATE  
                PRO_WORKS
            SET
                RELATED_WORK_ID = NULL
            WHERE 
                WORK_ID = #wrk_id#
        </cfquery>
        <cfreturn 1>
    </cffunction>
    <cffunction name="GET_WORK"  access="remote" returntype="query"> <!--- WRK_ID'ye göre sadece WORK_HEAD column alır. İhtiyaç halinde çekilen columnlar artılabilir..ERU----->
        <cfargument name="wrk_id">  
        <cfquery name="GET_WORK" datasource="#dsn#">
            SELECT WORK_HEAD FROM PRO_WORKS WHERE WORK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.wrk_id#">
        </cfquery>
        <cfreturn GET_WORK>
    </cffunction>
</cfcomponent>
