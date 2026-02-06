<!---
Author :        Melek Kocabey<melekkocabey@workcube.com>
Date :          02.09.2019
Description :  Görevler sayfası componenti...
--->
<cfcomponent extends="cfc.queryJSONConverter" displayname = "WORKS" hint = "GET WORKS">
    <cfset dsn=application.systemParam.systemParam().dsn>
    <cfset upload_folder=application.systemParam.systemParam().upload_folder>
    <cffunction name="DET_WORK" access="remote" returntype="any" hint="iş detaylarını getir">
        <cfargument name="id" default="">
        <cfargument name="keyword" default="">
        <cfargument name="company_control" default="0"><!--- şirkette göre kontrol edilsin ise 1 verilir --->
        <cfquery name="DET_WORK" datasource="#DSN#">
            SELECT 
                ISNULL(TO_COMPLETE,0) TO_COMPLETE,
                TERMINATE_DATE,
                REAL_START,
                REAL_FINISH,
                TARGET_START,
                TARGET_FINISH,
                WORK_NO,
                WORK_HEAD,
                WORK_DETAIL,
                WORK_ID,
                PROJECT_EMP_ID,
                PROJECT_ID,
                G_SERVICE_ID,
                SERVICE_ID,
                OUR_COMPANY_ID,
                WORK_CAT_ID,
                WORK_CURRENCY_ID,
                WORK_PRIORITY_ID,
                COMPANY_ID,
                COMPANY_PARTNER_ID,
                OUTSRC_PARTNER_ID,
                WORKGROUP_ID,
                RELATED_WORK_ID,
                CONSUMER_ID,
                ESTIMATED_TIME,
                RELATION_TYPE,
                IS_MILESTONE,
                MILESTONE_WORK_ID,
                EXPECTED_BUDGET,
                EXPECTED_BUDGET_MONEY,
                WORK_STATUS,
                WORK_CIRCUIT,
                OPPORTUNITY_ID,
                SERVICE_ID,
                OUTSRC_CMP_ID,
                RECORD_AUTHOR,
                UPDATE_AUTHOR,
                PRO_WORKS.RECORD_DATE,
                PRO_WORKS.UPDATE_DATE,
                RECORD_PAR,
                UPDATE_PAR,
                WORK_FUSEACTION,
                CUS_HELP_ID,
                FORUM_REPLY_ID,
                COMPLETED_AMOUNT,
                AVERAGE_AMOUNT,
                PBS_ID,
                SALE_CONTRACT_ID,
                SALE_CONTRACT_AMOUNT,
                PURCHASE_CONTRACT_ID,
                PURCHASE_CONTRACT_AMOUNT,
                REWORK,
                PREDICTED_START,
                PREDICTED_FINISH,
                DURATION,
                SPECIAL_DEFINITION_ID,
                AVERAGE_AMOUNT_UNIT,
                ACTIVITY_ID,
                SU.UNIT,
                (SELECT SUM((ISNULL(TOTAL_TIME_HOUR,0)*60) + ISNULL(TOTAL_TIME_MINUTE,0)) FROM PRO_WORKS_HISTORY WHERE PRO_WORKS.WORK_ID = PRO_WORKS_HISTORY.WORK_ID GROUP BY WORK_ID)  HARCANAN_DAKIKA
            FROM 
                PRO_WORKS
                LEFT JOIN SETUP_UNIT SU ON PRO_WORKS.AVERAGE_AMOUNT_UNIT = SU.UNIT_ID
            WHERE
                1=1
                <cfif isDefined("arguments.id") and len(arguments.id)>
                   AND WORK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
                </cfif>
                <cfif isDefined("arguments.work_status") and len(arguments.work_status)>
                   AND WORK_STATUS = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.work_status#">
                </cfif>
                <cfif isDefined("arguments.project_id") and len(arguments.project_id)>
                    AND PRO_WORKS.PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.project_id#"> 
                </cfif>
                <cfif isDefined("arguments.pro_work_cat") and len(arguments.pro_work_cat)>
                    AND PRO_WORKS.WORK_CAT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pro_work_cat# ">
                </cfif>
                 <cfif isDefined("arguments.process_stage") and len(arguments.process_stage)>
                    AND PRO_WORKS.WORK_CURRENCY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.process_stage#">
                 </cfif>
                <cfif isdefined('xml_is_detail_filtre') and xml_is_detail_filtre eq 1>
                    <cfif (not isdefined('xml_is_all_authorization') or not len(xml_is_all_authorization))  or (len('xml_is_all_authorization') and not listfind(xml_is_all_authorization,session.ep.position_code,','))>
                        AND  
                        (
                            PRO_WORKS.PROJECT_EMP_ID = #session.ep.userid#
                            OR PRO_WORKS.WORK_ID IN(SELECT WORK_ID FROM PRO_WORKS_CC WHERE CC_EMP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#"> AND WORK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">)
                            OR PRO_WORKS.RECORD_AUTHOR = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#">
                        )
                    </cfif>
                </cfif>
                <cfif isdefined('xml_is_project_authority') and xml_is_project_authority eq 1>
                    AND 
                    (
                        PRO_WORKS.PROJECT_ID IN 
                        (
                            SELECT 
                                PRO_PROJECTS.PROJECT_ID
                            FROM
                                PRO_PROJECTS
                            WHERE
                                PRO_PROJECTS.PROCESS_CAT IN
                                (
                                    SELECT  
                                        SMC.MAIN_PROCESS_CAT_ID
                                    FROM 
                                        SETUP_MAIN_PROCESS_CAT SMC,
                                        SETUP_MAIN_PROCESS_CAT_ROWS SMR,
                                        EMPLOYEE_POSITIONS
                                    WHERE
                                        SMC.MAIN_PROCESS_CAT_ID = SMR.MAIN_PROCESS_CAT_ID AND
                                        EMPLOYEE_POSITIONS.POSITION_CODE = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.position_code#"> AND 
                                        (EMPLOYEE_POSITIONS.POSITION_CAT_ID=SMR.MAIN_POSITION_CAT_ID OR EMPLOYEE_POSITIONS.POSITION_CODE = SMR.MAIN_POSITION_CODE)
                                )
                        )
                        OR PRO_WORKS.PROJECT_EMP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#">
                        OR PRO_WORKS.PROJECT_ID IS NULL
                    )
                </cfif>
                <cfif isdefined('session.pp.company_id') and arguments.company_control eq 1>
                   AND PRO_WORKS.COMPANY_ID= <cfqueryparam cfsqltype="cf_sql_integer" value="#session.pp.company_id#">
                <cfelseif isdefined('session.ww.userid')>
                   AND PRO_WORKS.CONSUMER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ww.company_id#">
                </cfif>
                <cfif len(arguments.keyword) gte 1>
                    AND (
                        PRO_WORKS.WORK_HEAD LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.keyword#%"> COLLATE SQL_Latin1_General_CP1_CI_AI OR
                        PRO_WORKS.WORK_DETAIL LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.keyword#%"> COLLATE SQL_Latin1_General_CP1_CI_AI OR
                        PRO_WORKS.WORK_NO LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.keyword#%"> COLLATE SQL_Latin1_General_CP1_CI_AI 
                        )
                <cfelseif len(arguments.keyword) eq 1>
                    AND PRO_WORKS.WORK_HEAD LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.keyword#%"> COLLATE SQL_Latin1_General_CP1_CI_AI
                </cfif>
                <cfif isDefined("arguments.emp_id") and len(arguments.emp_id)>
                    AND PRO_WORKS.PROJECT_EMP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.emp_id#">
                </cfif>
                <cfif isDefined("arguments.work_my") and len(arguments.work_my) and arguments.work_my eq 1>
                    <cfif isDefined('session.ep.userid')>
                        AND PRO_WORKS.PROJECT_EMP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#">
                    <cfelseif isDefined('session.pp.userid')>
                        AND PRO_WORKS.OUTSRC_PARTNER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.pp.userid#">
                    </cfif>                   
                </cfif>
                <cfif isDefined("arguments.proIdList") and len(arguments.proIdList)>
                    AND PRO_WORKS.PROJECT_ID IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.proIdList#" list="yes">)
                </cfif>
            ORDER BY TERMINATE_DATE
        </cfquery>
        <cfreturn DET_WORK>
    </cffunction>
    <cffunction name="GET_WORK_CAT" access="remote" returntype="any" hint="iş kategorisini getir">
        <cfargument name="query_id" default="">
        <cfargument name="query_return" default="">
        <cfargument name="control_project_id" default="">
        <cfargument name="work_cat_id" default="">
        <cfargument name="process_cat" default="">
        <cfif isDefined("arguments.control_project_id") and len(arguments.control_project_id)>
            <cfquery name="GET_PRO_CAT" datasource="#DSN#">
                SELECT PROCESS_CAT FROM PRO_PROJECTS WHERE PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.control_project_id#">
            </cfquery>
            <cfset query_return = GET_PRO_CAT>
        <cfelse>
            <cfquery name="GET_WORK_CAT" datasource="#DSN#">
                SELECT 
                    #dsn#.Get_Dynamic_Language(PRO_WORK_CAT.WORK_CAT_ID,'<cfif isDefined('session.ep.userid')>#session.ep.language#<cfelseif isDefined('session.pp.userid')>#session.pp.language# <cfelseif isDefined('session.pda.userid')>#session.pda.language#</cfif>','PRO_WORK_CAT','WORK_CAT',NULL,NULL,PRO_WORK_CAT.WORK_CAT) AS work_cat,
                    WORK_CAT_ID,
                    TEMPLATE_ID 
                FROM 
                    PRO_WORK_CAT
                WHERE
                    <cfif isDefined('session.ep.userid')>
                        ','+OUR_COMPANY_ID+',' LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%,#session.ep.company_id#,%">
                    <cfelseif isDefined('session.pp.userid')>
                        ','+OUR_COMPANY_ID+',' LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%,#session.pp.our_company_id#,%">
                    <cfelseif isDefined('session.pda.userid')>
                        ','+OUR_COMPANY_ID+',' LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%,#session.pda.our_company_id#,%">
                    </cfif>	
                    <cfif isDefined("arguments.work_cat_id") and len(arguments.work_cat_id)>
                        AND WORK_CAT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.work_cat_id#">
                    </cfif>
                    <cfif isdefined("xml_is_project_cat") and xml_is_project_cat eq 1 and isDefined("control_project_id") and len(control_project_id)>
                        AND MAIN_PROCESS_ID IS NOT NULL AND ','+MAIN_PROCESS_ID+',' LIKE '%,#arguments.process_cat#,%'
                    <cfelseif isdefined("xml_is_project_cat") and xml_is_project_cat eq 1>
                        AND MAIN_PROCESS_ID IS NULL
                    </cfif>
                ORDER BY 
                    WORK_CAT
            </cfquery>
            <cfset query_return = GET_WORK_CAT>
        </cfif>
        <cfreturn query_return>
    </cffunction>
   <cffunction name="GET_ACTIVITY" access="remote" returntype="any" hint="Aktivite tipi getir">
    <cfargument name="activity_id" default="">
        <cfquery name="GET_ACTIVITY" datasource="#DSN#">
            SELECT #dsn#.Get_Dynamic_Language(ACTIVITY_ID,'#session.ep.language#','SETUP_ACTIVITY','ACTIVITY_NAME',NULL,NULL,ACTIVITY_NAME) AS ACTIVITY_NAME, ACTIVITY_ID FROM SETUP_ACTIVITY WHERE ACTIVITY_STATUS = <cfqueryparam cfsqltype="cf_sql_integer" value="1">
            <cfif isDefined("arguments.activity_id") and len(arguments.activity_id)>
                        AND ACTIVITY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.activity_id#">
            </cfif>
             ORDER BY ACTIVITY_NAME
        </cfquery>
        <cfreturn GET_ACTIVITY>
   </cffunction>
   <cffunction name="get_cats" access="remote" returntype="any" hint="Öncelik getir">
    <cfargument name="session_base" default="#session.ep.language#">
        <cfquery name="get_cats" datasource="#DSN#">
            SELECT
                #dsn#.Get_Dynamic_Language(SETUP_PRIORITY.PRIORITY_ID,'#session_base#','SETUP_PRIORITY','PRIORITY',NULL,NULL,SETUP_PRIORITY.PRIORITY) AS priority,
                PRIORITY_ID
            FROM 
                SETUP_PRIORITY
            <cfif isDefined("arguments.work_priority_id") and len(arguments.work_priority_id)>
                WHERE
                    PRIORITY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.work_priority_id#">
            </cfif>
            ORDER BY
                PRIORITY
        </cfquery>
        <cfreturn get_cats>
   </cffunction>
   <cffunction name="GET_PROCESS" access="remote" returntype="any" hint="Süreç getir">
        <cfquery name="GET_PROCESS" datasource="#dsn#">
            SELECT 
                STAGE,
                LINE_NUMBER
            FROM 
                PROCESS_TYPE,
                PROCESS_TYPE_ROWS 
            WHERE 
                PROCESS_TYPE_ROWS.PROCESS_ID = PROCESS_TYPE.PROCESS_ID
                <cfif isDefined("arguments.work_currency_id") and len(arguments.work_currency_id)>
                    AND PROCESS_TYPE_ROWS.PROCESS_ROW_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.work_currency_id#">
                </cfif>
        </cfquery>
        <cfreturn GET_PROCESS>
   </cffunction>
   <cffunction name="GET_WORKGROUPS" access="remote" returntype="any" hint="İş Grubunu getir">
        <cfargument  name="workgroup_id" default="">
        <cfquery name="GET_WORKGROUPS" datasource="#DSN#">
            SELECT
                #dsn#.Get_Dynamic_Language(WORK_GROUP.WORKGROUP_ID,'#session.ep.language#','WORK_GROUP','WORKGROUP_NAME',NULL,NULL,WORK_GROUP.WORKGROUP_NAME) AS WORKGROUP_NAME,
                WORKGROUP_ID
            FROM
                WORK_GROUP
            WHERE
                <cfif isdefined("arguments.workgroup_id") and len(arguments.workgroup_id)>
                    WORKGROUP_ID =<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.workgroup_id#"> AND
                </cfif>
                STATUS = 1 AND
                HIERARCHY IS NOT NULL
            ORDER BY 
                WORKGROUP_NAME
        </cfquery>
        <cfreturn GET_WORKGROUPS>
   </cffunction>
   <cffunction name="GET_PROJECT" access="remote" returntype="any" hint="işin bağlı olduğu projeyi getir">
    <cfif isDefined("arguments.project_id") and len(arguments.project_id)>
        <cfquery name="GET_PROJECT" datasource="#DSN#">
            SELECT PROJECT_HEAD FROM PRO_PROJECTS WHERE PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.project_id#">
        </cfquery>
        <cfreturn GET_PROJECT>
    </cfif>
   </cffunction>
    <cffunction name="get_time_history" access="remote" returntype="any" hint="Planlanan ve Gercekleşen saat-dk getir">
        <cfquery name="get_time_history" datasource="#dsn#">
            SELECT 
                SUM(TOTAL_TIME_HOUR) TOTAL_TIME_HOUR,
                SUM(TOTAL_TIME_MINUTE) TOTAL_TIME_MINUTE,
                SUM(TOTAL_TIME_HOUR1) AS TOTAL_TIME_HOUR1,
                SUM(TOTAL_TIME_MINUTE1)  AS TOTAL_TIME_MINUTE1,
                EMPLOYEE_ID,
                TYPE
            FROM 
                ( 
                    SELECT
                            SUM(TOTAL_TIME_HOUR) AS TOTAL_TIME_HOUR, 
                            SUM(TOTAL_TIME_MINUTE) AS TOTAL_TIME_MINUTE, 
                            '' AS TOTAL_TIME_HOUR1,
                            ''  AS TOTAL_TIME_MINUTE1, 
                            UPDATE_AUTHOR AS EMPLOYEE_ID,
                            'EMPLOYEE' AS TYPE
                                                                        
                    FROM 
                            PRO_WORKS_HISTORY 
                                                                
                    WHERE 
                            UPDATE_AUTHOR IS NOT NULL AND
                            WORK_ID =  <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
                    GROUP BY
                        UPDATE_AUTHOR
                UNION 
                    SELECT 
                            '' AS TOTAL_TIME_HOUR,
                            ''  AS TOTAL_TIME_MINUTE, 
                            SUM(TOTAL_TIME_HOUR1) AS TOTAL_TIME_HOUR1, 
                            SUM(TOTAL_TIME_MINUTE1) AS TOTAL_TIME_MINUTE1, 
                            EMPLOYEE_ID AS EMPLOYEE_ID,
                            'EMPLOYEE' AS TYPE
                    FROM 
                            TIME_COST_PLANNED 
                    WHERE 
                            WORK_ID =  <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
                    GROUP BY 
                            EMPLOYEE_ID

                UNION 
                     SELECT
                            SUM(TOTAL_TIME_HOUR) AS TOTAL_TIME_HOUR, 
                            SUM(TOTAL_TIME_MINUTE) AS TOTAL_TIME_MINUTE, 
                            '' AS TOTAL_TIME_HOUR1,
                            ''  AS TOTAL_TIME_MINUTE1, 
                            UPDATE_PAR AS EMPLOYEE_ID,
                            'PARTNER' AS TYPE
                    FROM 
                        PRO_WORKS_HISTORY
                    WHERE 
                        UPDATE_PAR IS NOT NULL AND
                        WORK_ID =  <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
                    GROUP BY 
                            UPDATE_PAR                           
                ) AS T1 
            GROUP BY 
                EMPLOYEE_ID,
                TYPE
        </cfquery>
        <cfreturn get_time_history>
   </cffunction>
    <cffunction name="EMPLOYEE_PHOTO" access="remote" returntype="query">
        <cfargument name="employee_id" default="">
        <cfquery name="EMPLOYEE_PHOTO" datasource="#DSN#">
            SELECT 
                E.PHOTO,
                E.EMPLOYEE_NAME,
                E.EMPLOYEE_SURNAME,
                E2.SEX,
                EP.POSITION_NAME AS POSITION
            FROM 
                EMPLOYEES AS E 
                LEFT JOIN EMPLOYEES_DETAIL AS E2 ON E2.EMPLOYEE_ID = E.EMPLOYEE_ID                
                LEFT JOIN EMPLOYEE_POSITIONS AS EP ON E.EMPLOYEE_ID = EP.EMPLOYEE_ID   
            WHERE E.EMPLOYEE_ID = #arguments.employee_id#
        </cfquery>
        <cfreturn EMPLOYEE_PHOTO>
    </cffunction>
    <cffunction name="CONSUMER_PHOTO" access="remote" returntype="query">
        <cfargument name="consumer_id" default="">
        <cfquery name="CONSUMER_PHOTO" datasource="#DSN#">
            SELECT 
                C.PICTURE,
                C.SEX,
                C.CONSUMER_EMAIL,
                C.CONSUMER_WORKTELCODE,
                C.CONSUMER_WORKTEL,
                C.MOBIL_CODE,
                C.MOBILTEL
            FROM 
                CONSUMER C
            WHERE C.CONSUMER_ID = #arguments.consumer_id#
        </cfquery>
        <cfreturn CONSUMER_PHOTO>
    </cffunction>
    <cffunction name="GET_WORK_DETAIL" access="remote" returntype="any" hint="History control">
        <cfargument name="id" default="">
       <cfquery name="GET_WORK_DETAIL" datasource="#DSN#">
            SELECT
                PWH.HISTORY_ID,
                PWH.WORK_ID,
                TMP.HISTORY_ID 
            FROM
                PRO_WORKS_HISTORY PWH
                LEFT JOIN TIME_COST_PLANNED TMP ON PWH.HISTORY_ID = TMP.HISTORY_ID
            WHERE 
                PWH.WORK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
        </cfquery>
        <cfreturn GET_WORK_DETAIL>
    </cffunction>
    <cffunction name="GET_WORK_HISTORY" access="remote" returntype="any">
        <cfargument name="employee_id" default="">
        <cfargument name="is_notPrority" default="">
        <cfquery name="GET_WORK_HISTORY" datasource="#DSN#">
            SELECT
                PWH.OUTSRC_PARTNER_ID,
                PW.COMPANY_PARTNER_ID,
                PWH.HISTORY_ID,
                PWH.WORK_DETAIL,
                PWH.TARGET_START,
                PWH.TARGET_FINISH,
                PWH.REAL_START,
		        PWH.REAL_FINISH,
                PWH.PROJECT_EMP_ID,
                PWH.UPDATE_AUTHOR,
                PWH.UPDATE_PAR,
                PWH.UPDATE_DATE,
                PWC.WORK_CAT,
                <cfif not isDefined("arguments.is_notPrority") and arguments.is_notPrority neq 1>SP.PRIORITY,</cfif>
                PWH.WORK_HEAD,
                PWH.WORK_CURRENCY_ID,
                PWH.TOTAL_TIME_HOUR,
                PWH.TOTAL_TIME_MINUTE,
                PWH.TO_COMPLETE,
                PWH.ESTIMATED_TIME,
                PWH.ACTIVITY_ID,
                PW.TARGET_START,
                PW.TARGET_FINISH
                <cfif isdefined("arguments.employee_id") and len(arguments.employee_id)>
                ,PWH.UPDATE_AUTHOR AS EMPLOYEE_ID
                </cfif>
            FROM
                PRO_WORKS_HISTORY PWH,
                PRO_WORK_CAT PWC
                <cfif not isDefined("arguments.is_notPrority") and arguments.is_notPrority neq 1>,
                PRO_WORKS PW LEFT JOIN SETUP_PRIORITY SP ON PW.WORK_PRIORITY_ID = SP.PRIORITY_ID
                <cfelse>
                    ,PRO_WORKS PW 
                </cfif>
            WHERE
                PWC.WORK_CAT_ID = PWH.WORK_CAT_ID AND
                <cfif isdefined("arguments.employee_id") and len(arguments.employee_id)>
                    PWH.UPDATE_AUTHOR=<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.EMPLOYEE_ID#"> AND
                </cfif>
                <cfif isdefined('session.pp.company_id')>
                    PW.COMPANY_ID= <cfqueryparam cfsqltype="cf_sql_integer" value="#session.pp.company_id#"> AND
                    PWH.COMPANY_ID= <cfqueryparam cfsqltype="cf_sql_integer" value="#session.pp.company_id#"> AND
                <cfelseif isdefined('session.ww.userid')>
                    PW.CONSUMER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ww.company_id#"> AND
                    PWH.CONSUMER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ww.company_id#"> AND
                </cfif>
                <cfif isdefined("arguments.wid") and len(arguments.wid)>
                    PWH.WORK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.wid#"> AND		
                    PW.WORK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.wid#">
                <cfelse>
                    PWH.WORK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#url.id#"> AND		
                    PW.WORK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#url.id#">
                </cfif>
                
            ORDER BY
                PWH.HISTORY_ID DESC
        </cfquery>
        <cfreturn GET_WORK_HISTORY>
    </cffunction>
    <cffunction name = "GET_VALUES" access="remote" returnType = "any">
        <cfargument name="id" default="">
        <cfquery name="GET_VALUES" datasource="#dsn#">
            SELECT 
                CC_EMP_ID AS CC_EMP, CC_PAR_ID AS CC_PAR
            FROM 
                PRO_WORKS_CC
            WHERE 
                WORK_ID= <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
	    </cfquery>
        <cfreturn GET_VALUES>
    </cffunction>
    <cffunction name = "GET_EMP_LIST" access="remote" returnType = "any">
        <cfargument name="int_emp_list" default="#int_emp_list#">
        <cfquery name="GET_EMP_LIST" datasource="#DSN#">
            SELECT
                EMPLOYEES.EMPLOYEE_NAME NAME,
                EMPLOYEES.EMPLOYEE_SURNAME SURNAME,
                EMPLOYEE_POSITIONS.POSITION_NAME TITLE,
                EMPLOYEES.PHOTO,
                E2.SEX
            FROM                
                EMPLOYEES 
                LEFT JOIN EMPLOYEE_POSITIONS ON EMPLOYEES.EMPLOYEE_ID = EMPLOYEE_POSITIONS.EMPLOYEE_ID AND EMPLOYEE_POSITIONS.IS_MASTER = 1
                LEFT JOIN EMPLOYEES_DETAIL AS E2 ON E2.EMPLOYEE_ID = EMPLOYEES.EMPLOYEE_ID  
            WHERE
                EMPLOYEES.EMPLOYEE_ID IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#int_emp_list#" list="yes">)
        </cfquery> 
        <cfreturn GET_EMP_LIST>
    </cffunction>
    <cffunction name="PARTNER_PHOTO" access="remote" returntype="query">
        <cfargument name="partner_id" default="">
        <cfquery name="PARTNER_PHOTO" datasource="#DSN#">
            SELECT 
                CP.PHOTO,
                CP.COMPANY_PARTNER_SURNAME AS NAME,
                CP.COMPANY_PARTNER_NAME AS SURNAME,
                CP.SEX
            FROM 
                COMPANY_PARTNER CP
            WHERE CP.PARTNER_ID IN  (<cfqueryparam cfsqltype="cf_sql_integer" value="#partner_id#" list="yes">)
        </cfquery>
        <cfreturn PARTNER_PHOTO>
    </cffunction>
    <cffunction name="GETNOTES" access="remote" returntype="any">
        <cfquery name="GETNOTES" datasource="#DSN#">
            SELECT
                N.ACTION_ID,
                N.NOTE_ID,
                'comment' AS HEAD,
                N.NOTE_BODY AS BODY,
                N.RECORD_DATE,
                N.RECORD_EMP,
                E.EMPLOYEE_NAME + ' ' + E.EMPLOYEE_SURNAME AS EMPLOYEE,
                E.EMPLOYEE_NAME,
                E.EMPLOYEE_SURNAME,
                E.EMPLOYEE_ID AS EMPLOYEE_ID,
                E.PHOTO,
                ED.SEX,
                CP.COMPANY_PARTNER_NAME + ' ' + CP.COMPANY_PARTNER_SURNAME AS COMPANY_PARTNER
            FROM
                NOTES AS N
                LEFT JOIN EMPLOYEES AS E ON E.EMPLOYEE_ID = N.RECORD_EMP
                LEFT JOIN COMPANY_PARTNER AS CP ON CP.PARTNER_ID = N.RECORD_PAR
                LEFT JOIN EMPLOYEES_DETAIL AS ED ON E.EMPLOYEE_ID = ED.EMPLOYEE_ID
            WHERE
                N.ACTION_SECTION = <cfqueryparam cfsqltype="cf_sql_varchar" value="#ucase(arguments.action_section)#">
                AND N.ACTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.action_id#">
				<cfif isdefined("arguments.company_id") and len(arguments.company_id)>
                    AND N.COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.company_id#">
                </cfif>
				<cfif isDefined('arguments.period_id') and len(arguments.period_id)>
                    AND N.PERIOD_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.period_id#">
                 </cfif>
            ORDER BY
                N.RECORD_DATE
        </cfquery>
        <cfreturn GETNOTES>
    </cffunction>
    <cffunction name="SAVENOTES" returntype="any" returnformat="json" access="remote">
        <cfset result = StructNew()>
        <cftry>
            <cfquery name="SAVENOTES" datasource="#DSN#" result="MAXID">
                INSERT INTO
                    NOTES
                (
                    ACTION_SECTION,
                    ACTION_ID,
                    NOTE_HEAD,
                    NOTE_BODY,
                    RECORD_DATE,
                    <cfif isdefined("session.pp.our_company_id")>
                        COMPANY_ID,
                        RECORD_PAR
                    <cfelse>
                        COMPANY_ID,
                        RECORD_EMP
                    </cfif>
                )
                VALUES
                (
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.actionSection#">,
                    <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.actionId#">,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.noteHead#">,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.noteBody#">,
                    #now()#,
                    <cfif isdefined("session.pp.our_company_id")>
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#session.pp.company_id#">,
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#session.pp.userid#">
                    <cfelse>
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#">,
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#">
                    </cfif>
                )
            </cfquery>
            <cfquery name="GET_DATA" datasource="#DSN#">
                SELECT
                    N.ACTION_ID,
                    N.NOTE_ID,
                    'comment' AS HEAD,
                    N.NOTE_BODY AS BODY,
                    CONVERT(VARCHAR(5),DATEADD(hh,#session.ep.time_zone#,N.RECORD_DATE),108) + ' - ' + CONVERT(VARCHAR(10),N.RECORD_DATE,105) AS RECORD_DATE,
                    E.EMPLOYEE_ID AS EMPLOYEE_ID,
                    E.PHOTO,
                    ED.SEX,
                    N.RECORD_EMP,
                    N.COMPANY_ID,
                    N.PERIOD_ID,
                    CP.COMPANY_PARTNER_NAME + ' ' + CP.COMPANY_PARTNER_SURNAME AS COMPANY_PARTNER
                FROM
                    NOTES AS N
                    LEFT JOIN COMPANY_PARTNER AS CP ON CP.PARTNER_ID = N.RECORD_PAR
                    LEFT JOIN EMPLOYEES AS E ON E.EMPLOYEE_ID = N.RECORD_EMP
                    LEFT JOIN EMPLOYEES_DETAIL AS ED ON E.EMPLOYEE_ID = ED.EMPLOYEE_ID
                WHERE
                    N.NOTE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#MAXID.identityCol#">
            </cfquery>
            <cfset result.STATUS = true>
            <cfset result.data.BODY = GET_DATA.BODY>
            <cfset result.data.RECORD_DATE = GET_DATA.RECORD_DATE>
            <cfif len(GET_DATA.PHOTO)>
                <cfset result.data.PHOTO = "/documents/hr/#GET_DATA.PHOTO#">
            </cfif>
            <cfset result.data.NOTE_ID = GET_DATA.NOTE_ID>
            <cfcatch type = "any">
                <cfset result.STATUS = false>
            </cfcatch>
        </cftry>
        <cfreturn Replace(SerializeJSON(result),'//','')>
    </cffunction>
    <cffunction name="time_add_new" returntype="any" returnformat="json" access="remote">
        <cfargument name="WORK_HEAD" default="">
        <cfargument name="project_emp_id" default="">
        <cfargument name="TOTAL_TIME_HOUR" default="">
        <cfargument name="TOTAL_TIME_MINUTE" default="">
        <cfargument name="employee_id" default="">
        <cfargument name="work_detail" default="">
        <cfargument name="id" default="">
        <cfset result = StructNew()>
        <cftry>
        	<cfquery name="time_add_new" datasource="#dsn#"  result="query">	
               INSERT INTO
			   PRO_WORKS_HISTORY
                (
                    WORK_ID,
                    WORK_HEAD,
                    WORK_DETAIL,
                    UPDATE_AUTHOR,
                    TOTAL_TIME_HOUR,
                    TOTAL_TIME_MINUTE,
                    UPDATE_DATE
                )
                VALUES
                (
                    <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.WORK_HEAD#">,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.work_detail#">,
                    <cfif isdefined('session.ep.userid') and len(session.ep.userid)>#arguments.employee_id#</cfif>,
                    <cfif isDefined("arguments.total_time_hour") and len(arguments.total_time_hour)>#arguments.total_time_hour#<cfelse>NULL</cfif>,
                    <cfif isDefined("arguments.total_time_minute") and len(arguments.total_time_minute)>#arguments.total_time_minute#<cfelse>NULL</cfif>,
                    <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
                )
            </cfquery>
        	<cfset result.status = true>
            <cfcatch type = "any">
                <cfset result.status = false>
            </cfcatch>
        </cftry>
        <cfreturn Replace(SerializeJSON(result),'//','')>
    </cffunction>
    <cffunction name="delWorkSteps" access="public" returntype="any" hint= "İş adımları del">
        <cfquery name="del" datasource="#dsn#">
            DELETE FROM PRO_WORKS_STEP WHERE WORK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.WORK_ID#">
        </cfquery>
    </cffunction>
    <cffunction name="addWorkSteps" access="public" returntype="any" hint = "İş Adımları Ekle">
        <cfargument type="string" name="WORK_STEP_DETAIL" default="">
        <cfargument name="work_step_hour" default="">
        <cfargument name="work_step_minute" default="">
        <cfargument name="completion" default="">
        <cfquery name="add" datasource="#dsn#">
            INSERT INTO
                PRO_WORKS_STEP
            (
                WORK_ID,
                WORK_STEP_DETAIL,
                WORK_STEP_COMPLETE_PERCENT,
                COMPLETED_HOUR,
                COMPLETED_MINUTE,
                RECORD_DATE,
                RECORD_IP,
                RECORD_EMP,
                UPDATE_DATE,
                UPDATE_EMP,
                RANK_ORDER
                
            )
                VALUES
            (
                <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.work_id#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.WORK_STEP_DETAIL#">,
                <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.completion#">,
                <cfqueryparam cfsqltype="cf_sql_integer" value="#work_step_hour#">,
                <cfqueryparam cfsqltype="cf_sql_integer" value="#work_step_minute#">,
                <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.remote_addr#">,
                <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#">,
                <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
                <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#">,
                <cfqueryparam cfsqltype="cf_sql_integer" value="#rank_order#">
            )
        </cfquery>
    </cffunction>
    <cffunction name = "getWorkSteps" returnType = "query" hint = "[iş adımlarını getir]">
        <cfargument  name="WORK_ID" default="">
        <cfquery name = "get_work_steps" datasource = "#dsn#">
            SELECT
                WORK_STEP_ID,
                WORK_ID,
                WORK_STEP_DETAIL,
                COMPLETED_HOUR,
                COMPLETED_MINUTE,
                WORK_STEP_COMPLETE_PERCENT,
                RANK_ORDER
            FROM
                PRO_WORKS_STEP
            WHERE
                WORK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.WORK_ID#">
            ORDER BY RANK_ORDER ASC
        </cfquery>
         <cfreturn get_work_steps>
    </cffunction>
    <cffunction name = "upd_work_step_order" returnType = "any" access="public">
        <cfargument name="work_step_id" default="">
        <cfargument name="work_id" default="">
        <cfargument name="content_rank" default="">
        <cfquery name = "upd_work_step_order" datasource = "#dsn#">
            UPDATE
                PRO_WORKS_STEP
            SET
                RANK_ORDER = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.content_rank#">
            WHERE
                WORK_STEP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.work_step_id#">
        </cfquery>
    </cffunction>
    <cffunction name="GET_WORK_FIRST_DETAIL" access="remote" returntype="any">
        <cfargument name="id" default="">
        <cfquery name="GET_WORK_FIRST_DETAIL" datasource="#DSN#">
            SELECT TOP 1 WORK_DETAIL,HISTORY_ID,UPDATE_AUTHOR,UPDATE_PAR
            FROM PRO_WORKS_HISTORY
            WHERE
                WORK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
            ORDER BY UPDATE_DATE ASC
        </cfquery>
        <cfreturn GET_WORK_FIRST_DETAIL>
    </cffunction>
    <cffunction name="GET_MONEY" access="remote" returntype="any">
        <cfquery name="GET_MONEY" datasource="#DSN#">
            SELECT
                MONEY
            FROM
                SETUP_MONEY
            WHERE
                PERIOD_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.period_id#">
        </cfquery>
        <cfreturn GET_MONEY>
    </cffunction>
    <cffunction name="GET_SPECIAL_DEFINITION" access="remote" returntype="any">
       <cfquery name="GET_SPECIAL_DEFINITION" datasource="#dsn#">
            SELECT SPECIAL_DEFINITION_ID,#dsn#.Get_Dynamic_Language(SPECIAL_DEFINITION_ID,'#session.ep.language#','SETUP_SPECIAL_DEFINITION','SPECIAL_DEFINITION',NULL,NULL,SPECIAL_DEFINITION) AS SPECIAL_DEFINITION FROM SETUP_SPECIAL_DEFINITION WHERE SPECIAL_DEFINITION_TYPE = <cfqueryparam cfsqltype="cf_sql_integer" value="7">
        </cfquery>
        <cfreturn GET_SPECIAL_DEFINITION>
    </cffunction>
    <cffunction  name="GET_POSITIONS" access="remote" returntype="any">
        <cfquery name="GET_POSITIONS" datasource="#dsn#">
            SELECT
                EMPLOYEE_POSITIONS.EMPLOYEE_ID,
                EMPLOYEE_POSITIONS.EMPLOYEE_NAME,
                EMPLOYEE_POSITIONS.EMPLOYEE_SURNAME,
                EMPLOYEE_POSITIONS.EMPLOYEE_EMAIL,
                EMPLOYEE_POSITIONS.POSITION_CODE,
                EMPLOYEE_POSITIONS.POSITION_NAME,
                EMPLOYEE_POSITIONS.POSITION_ID,
                BRANCH.BRANCH_NAME,
                BRANCH.BRANCH_ID,
                DEPARTMENT.DEPARTMENT_HEAD,
                DEPARTMENT.DEPARTMENT_ID,
                EMPLOYEES.GROUP_STARTDATE
            FROM
                EMPLOYEE_POSITIONS,
                DEPARTMENT,
                BRANCH,
                EMPLOYEES
            WHERE
                EMPLOYEE_POSITIONS.POSITION_STATUS=1 AND
                EMPLOYEE_POSITIONS.VALID=2 AND
                EMPLOYEES.EMPLOYEE_STATUS=1 AND
                EMPLOYEE_POSITIONS.EMPLOYEE_ID>0 AND
                EMPLOYEES.EMPLOYEE_ID=EMPLOYEE_POSITIONS.EMPLOYEE_ID AND
                EMPLOYEE_POSITIONS.DEPARTMENT_ID=DEPARTMENT.DEPARTMENT_ID AND
                DEPARTMENT.BRANCH_ID=BRANCH.BRANCH_ID 
            <cfif not isDefined("arguments.show_empty_pos")>
                AND EMPLOYEES.EMPLOYEE_ID=EMPLOYEE_POSITIONS.EMPLOYEE_ID 
                AND EMPLOYEE_POSITIONS.DEPARTMENT_ID=DEPARTMENT.DEPARTMENT_ID
            </cfif>
            <cfif isDefined("arguments.keyword") and len(arguments.keyword)>
                <cfif len(arguments.keyword) eq 1>
                    AND EMPLOYEE_POSITIONS.EMPLOYEE_NAME LIKE '#arguments.keyword#%'
                <cfelse>
                    <cfif database_type is 'MSSQL'>
                    AND EMPLOYEE_POSITIONS.EMPLOYEE_NAME + ' ' + EMPLOYEE_POSITIONS.EMPLOYEE_SURNAME LIKE '%#arguments.keyword#%'
                    <cfelseif database_type is 'DB2'>
                    AND EMPLOYEE_POSITIONS.EMPLOYEE_NAME || ' ' || EMPLOYEE_POSITIONS.EMPLOYEE_SURNAME LIKE '%#arguments.keyword#%'
                    </cfif>
                </cfif>
            </cfif>
            <cfif isDefined("arguments.branch_id") and len(arguments.branch_id)>
                AND BRANCH.BRANCH_ID = #arguments.branch_id#
            </cfif>
            <cfif isDefined("arguments.our_cid")>
                AND BRANCH.COMPANY_ID = #arguments.our_cid# 
            </cfif>
            <cfif isdefined("arguments.branch_related")>
                AND BRANCH.BRANCH_ID IN (SELECT BRANCH_ID FROM EMPLOYEE_POSITION_BRANCHES WHERE POSITION_CODE = #session.pda.position_code#)
            </cfif>
            <cfif isdefined("arguments.employee_list") and arguments.employee_list neq "">
                AND EMPLOYEES.EMPLOYEE_ID IN (
                    SELECT
                        EMPLOYEE_POSITIONS.EMPLOYEE_ID
                    FROM 
                        BRANCH,
                        EMPLOYEE_POSITIONS,
                        DEPARTMENT
                    WHERE
                        BRANCH.BRANCH_ID IN ( SELECT EMPLOYEE_POSITION_BRANCHES.BRANCH_ID FROM EMPLOYEE_POSITION_BRANCHES WHERE EMPLOYEE_POSITION_BRANCHES.POSITION_CODE = #session.pda.position_code# )
                        AND EMPLOYEE_POSITIONS.DEPARTMENT_ID = DEPARTMENT.DEPARTMENT_ID AND
                        DEPARTMENT.BRANCH_ID = BRANCH.BRANCH_ID
                )
            </cfif>
            ORDER BY
                EMPLOYEE_POSITIONS.EMPLOYEE_NAME
        </cfquery>
        <cfreturn GET_POSITIONS>
    </cffunction>
    <cffunction name="add_work" access="remote" returntype="string" returnargumentsat="json">
        <cfargument name="estimated_time" default="0">
        <cfargument name="estimated_time_minute" default="0">
        <cfset result = StructNew()>
        <cfset total_estimated_time = (arguments.estimated_time*60)+arguments.estimated_time_minute>
        <cftry>      
            <cfquery name="ADD_WORK" datasource="#DSN#">

                INSERT INTO PRO_WORKS 
                (
                    OUR_COMPANY_ID,
                    COMPANY_ID,
                    COMPANY_PARTNER_ID,
                    CONSUMER_ID,
                    WORK_CAT_ID,
                    PROJECT_ID,
                    PROJECT_EMP_ID,                    
                    OUTSRC_PARTNER_ID,
                    WORK_HEAD,
                    WORK_DETAIL,
                    TOTAL_TIME_HOUR,
                    TOTAL_TIME_MINUTE,
                    ESTIMATED_TIME,
                    TERMINATE_DATE,
                    TARGET_START,
                    WORK_CURRENCY_ID,
                    WORK_STATUS,
                    TO_COMPLETE,
                    G_SERVICE_ID,
                    WORK_PRIORITY_ID,
                    RECORD_AUTHOR,
                    RECORD_PAR,
                    RECORD_DATE,
                    RECORD_IP                    
                )
                VALUES
                (
                    <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.session_base#">,
                    <cfif isdefined('session.pp.company_id')>
                       <cfqueryparam cfsqltype="cf_sql_integer" value="#session.pp.company_id#">,
                       <cfqueryparam cfsqltype="cf_sql_integer" value="#session.pp.userid#">,
                       <cfqueryparam null="yes" value="" cfsqltype="cf_sql_nvarchar">,
                    <cfelseif isdefined('session.ww.company_id')>                        
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ww.company_id#">,
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ww.userid#">,
                        <cfqueryparam null="yes" value="" cfsqltype="cf_sql_nvarchar">,
                    </cfif>
                    <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pro_work_cat#">,
                    <cfif isdefined("arguments.project_id") and len(arguments.project_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.project_id#"><cfelse><cfqueryparam null="yes" value="" cfsqltype="cf_sql_nvarchar"></cfif>,
                    <cfif isdefined("arguments.work_emp_id") and len(arguments.work_emp_id) and listLast(arguments.work_emp_id,'_') eq 2><cfqueryparam cfsqltype="cf_sql_integer" value="#listFirst(arguments.work_emp_id,'_')#"><cfelse>NULL</cfif>,
                    <cfif isdefined("arguments.work_emp_id") and len(arguments.work_emp_id) and listLast(arguments.work_emp_id,'_') eq 1><cfqueryparam cfsqltype="cf_sql_integer" value="#listFirst(arguments.work_emp_id,'_')#"><cfelse>NULL</cfif>,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.work_head#">,
                    <cfif isDefined("arguments.work_detail") and len(arguments.work_detail)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.work_detail#"><cfelse><cfqueryparam null="yes" value="" cfsqltype="cf_sql_nvarchar"></cfif>,
                    <cfif isDefined("arguments.total_time_hour") and len(arguments.total_time_hour)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.total_time_hour#"><cfelse><cfqueryparam null="yes" value="" cfsqltype="cf_sql_nvarchar"></cfif>,
                    <cfif isDefined("arguments.total_time_minute") and len(arguments.total_time_minute)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.total_time_minute#"><cfelse><cfqueryparam null="yes" value="" cfsqltype="cf_sql_nvarchar"></cfif>,
                    <cfqueryparam cfsqltype="cf_sql_integer" value="#total_estimated_time#">,
                    <cfif isdefined('arguments.terminate_date') and len(arguments.terminate_date)><cfqueryparam cfsqltype="cf_sql_date" value="#arguments.terminate_date#"><cfelse><cfqueryparam null="yes" value="" cfsqltype="cf_sql_nvarchar"></cfif>,
                    <cfqueryparam cfsqltype="cf_sql_date" value="#now()#">,
                    <cfif isdefined("arguments.process_stage")><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.process_stage#"><cfelse><cfqueryparam null="yes" value="" cfsqltype="cf_sql_nvarchar"></cfif>,
                    <cfif isdefined("arguments.work_status") and len(arguments.work_status)><cfqueryparam cfsqltype="cf_sql_integer" value="1"><cfelse><cfqueryparam cfsqltype="cf_sql_integer" value="0"></cfif>,
                    <cfif isdefined("arguments.to_complate") and len(arguments.to_complate)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.to_complate#"><cfelse><cfqueryparam cfsqltype="cf_sql_integer" value="0"></cfif>,
                    <cfif isDefined("arguments.g_service_id") and len(arguments.g_service_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.g_service_id#"><cfelse>NULL</cfif>,
                    <cfif isDefined("arguments.priority_cat") and len(arguments.priority_cat)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.priority_cat#"><cfelse><cfqueryparam null="yes" value="" cfsqltype="cf_sql_integer"></cfif>,
                    <cfif isdefined('session.ep.userid')><cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#"><cfelse><cfqueryparam null="yes" value="" cfsqltype="cf_sql_nvarchar"></cfif>,
                    <cfif isdefined('session.pp.userid')>
                       <cfqueryparam cfsqltype="cf_sql_integer" value="#session.pp.userid#">,
                    <cfelseif isdefined('session.ww.userid')>
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ww.userid#">,
                    </cfif>
                    <cfqueryparam cfsqltype="cf_sql_date" value="#now()#">,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.remote_addr#">
                )

                SELECT SCOPE_IDENTITY() AS MAX_WORK_ID
            </cfquery>  
            <cfquery name="ADD_WORK_HISTORY" datasource="#DSN#">
                INSERT INTO PRO_WORKS_HISTORY 
                (
                    WORK_ID,
                    OUR_COMPANY_ID,
                    COMPANY_ID,
                    COMPANY_PARTNER_ID,
                    CONSUMER_ID,
                    WORK_CAT_ID,
                    PROJECT_ID,
                    PROJECT_EMP_ID,                    
                    OUTSRC_PARTNER_ID,
                    WORK_HEAD,
                    WORK_DETAIL,
                    TOTAL_TIME_HOUR,
                    TOTAL_TIME_MINUTE,
                    TERMINATE_DATE,
                    TARGET_START,
                    WORK_CURRENCY_ID,
                    WORK_STATUS,
                    TO_COMPLETE,
                    G_SERVICE_ID,
                    WORK_PRIORITY_ID,
                    UPDATE_AUTHOR,
                    UPDATE_DATE               
                )
                VALUES
                (
                    <cfqueryparam cfsqltype="cf_sql_integer" value="#ADD_WORK.MAX_WORK_ID#">,
                    <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.session_base#">,
                    <cfif isdefined('session.pp.company_id')>
                       <cfqueryparam cfsqltype="cf_sql_integer" value="#session.pp.company_id#">,
                       <cfqueryparam cfsqltype="cf_sql_integer" value="#session.pp.userid#">,
                       <cfqueryparam null="yes" value="" cfsqltype="cf_sql_nvarchar">,
                    <cfelseif isdefined('session.ww.company_id')>                        
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ww.company_id#">,
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ww.userid#">,
                        <cfqueryparam null="yes" value="" cfsqltype="cf_sql_nvarchar">,
                    </cfif>
                    <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pro_work_cat#">,
                    <cfif isdefined("arguments.project_id") and len(arguments.project_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.project_id#"><cfelse><cfqueryparam null="yes" value="" cfsqltype="cf_sql_nvarchar"></cfif>,
                    <cfif isdefined("arguments.work_emp_id") and len(arguments.work_emp_id) and listLast(arguments.work_emp_id,'_') eq 2><cfqueryparam cfsqltype="cf_sql_integer" value="#listFirst(arguments.work_emp_id,'_')#"><cfelse>NULL</cfif>,
                    <cfif isdefined("arguments.work_emp_id") and len(arguments.work_emp_id) and listLast(arguments.work_emp_id,'_') eq 1><cfqueryparam cfsqltype="cf_sql_integer" value="#listFirst(arguments.work_emp_id,'_')#"><cfelse>NULL</cfif>,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.work_head#">,
                    <cfif isDefined("arguments.work_detail") and len(arguments.work_detail)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.work_detail#"><cfelse><cfqueryparam null="yes" value="" cfsqltype="cf_sql_nvarchar"></cfif>,
                    <cfif isDefined("arguments.total_time_hour") and len(arguments.total_time_hour)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.total_time_hour#"><cfelse><cfqueryparam null="yes" value="" cfsqltype="cf_sql_nvarchar"></cfif>,
                    <cfif isDefined("arguments.total_time_minute") and len(arguments.total_time_minute)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.total_time_minute#"><cfelse><cfqueryparam null="yes" value="" cfsqltype="cf_sql_nvarchar"></cfif>,
                    <cfif isdefined('arguments.terminate_date') and len(arguments.terminate_date)><cfqueryparam cfsqltype="cf_sql_date" value="#arguments.terminate_date#"><cfelse><cfqueryparam null="yes" value="" cfsqltype="cf_sql_nvarchar"></cfif>,
                    <cfqueryparam cfsqltype="cf_sql_date" value="#now()#">,
                    <cfif isdefined("arguments.process_stage")><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.process_stage#"><cfelse><cfqueryparam null="yes" value="" cfsqltype="cf_sql_nvarchar"></cfif>,
                    <cfif isdefined("arguments.work_status") and len(arguments.work_status)><cfqueryparam cfsqltype="cf_sql_integer" value="1"><cfelse><cfqueryparam cfsqltype="cf_sql_integer" value="0"></cfif>,
                    <cfif isdefined("arguments.to_complate") and len(arguments.to_complate)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.to_complate#"><cfelse><cfqueryparam cfsqltype="cf_sql_integer" value="0"></cfif>,
                    <cfif isDefined("arguments.g_service_id") and len(arguments.g_service_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.g_service_id#"><cfelse>NULL</cfif>,
                    <cfif isDefined("arguments.priority_cat") and len(arguments.priority_cat)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.priority_cat#"><cfelse><cfqueryparam null="yes" value="" cfsqltype="cf_sql_integer"></cfif>,
                    <cfif isDefined("arguments.update_author") and len(arguments.update_author)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.update_author#"><cfelse><cfqueryparam null="yes" value="" cfsqltype="cf_sql_integer"></cfif>,
                    <cfqueryparam cfsqltype="cf_sql_date" value="#now()#">
                )
            </cfquery>
            <cfset result.status = true>
            <cfset result.success_message = "Kaydı Yapıldı, Yönlendiriliyor">
            <cfset result.identity = CreateObject("component", "WMO.functions").contentEncryptingandDecodingAES(isEncode:1,content:ADD_WORK.MAX_WORK_ID,accountKey:"wrk")>
            <cfcatch type="any">
                <cfset result.status = false>
                <cfset result.danger_message = "Şuanda işlem yapılamıyor...">
                <cfset result.error = cfcatch >
                <cfdump var ="#cfcatch#">
            </cfcatch>  
        </cftry>
        <cfreturn Replace(SerializeJSON(result),'//','')>
    </cffunction>

    <cffunction name="upd_work" access="remote" returntype="string" returnargumentsat="json">
        <cfargument name="estimated_time" default="0">
        <cfargument name="estimated_time_minute" default="0">
        <cfset total_estimated_time = (arguments.estimated_time*60)+arguments.estimated_time_minute>
        <cfset result = StructNew()>
        <cftry>      
            <cfquery name="UPD_WORK" datasource="#DSN#">

                UPDATE 
                    PRO_WORKS 
                SET
                    OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.session_base#">,
                    COMPANY_ID = <cfif isdefined('session.pp.company_id')><cfqueryparam cfsqltype="cf_sql_integer" value="#session.pp.company_id#"><cfelse><cfqueryparam null="yes" value="" cfsqltype="cf_sql_nvarchar"></cfif>,
                    CONSUMER_ID = <cfif isdefined('session.ww.company_id')><cfqueryparam cfsqltype="cf_sql_integer" value="#session.ww.company_id#"><cfelse><cfqueryparam null="yes" value="" cfsqltype="cf_sql_nvarchar"></cfif>,
                    WORK_CAT_ID = <cfif isdefined('arguments.pro_work_cat')><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pro_work_cat#"><cfelse><cfqueryparam null="yes" value="" cfsqltype="cf_sql_nvarchar"></cfif>,
                    PROJECT_ID = <cfif isdefined("arguments.project_id") and len(arguments.project_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.project_id#"><cfelse><cfqueryparam null="yes" value="" cfsqltype="cf_sql_nvarchar"></cfif>,
                    <cfif isdefined("total_estimated_time") and len(total_estimated_time)>ESTIMATED_TIME =  <cfqueryparam cfsqltype="cf_sql_integer" value="#total_estimated_time#">,</cfif>
                    OUTSRC_PARTNER_ID = <cfif isdefined("arguments.work_emp_id") and len(arguments.work_emp_id) and  listLast(arguments.work_emp_id,'_') eq 1><cfqueryparam cfsqltype="cf_sql_integer" value="#listFirst(arguments.work_emp_id,'_')#"><cfelse><cfqueryparam null="yes" value="" cfsqltype="cf_sql_nvarchar"></cfif>,
                    PROJECT_EMP_ID = <cfif isdefined("arguments.work_emp_id") and len(arguments.work_emp_id) and  listLast(arguments.work_emp_id,'_') eq 2><cfqueryparam cfsqltype="cf_sql_integer" value="#listFirst(arguments.work_emp_id,'_')#"><cfelse><cfqueryparam null="yes" value="" cfsqltype="cf_sql_nvarchar"></cfif>,
                    WORK_HEAD =  <cfif isdefined("arguments.work_head") and len(arguments.work_head)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.work_head#"><cfelse><cfqueryparam null="yes" value="" cfsqltype="cf_sql_nvarchar"></cfif>,
                    WORK_DETAIL =  <cfif isDefined("arguments.work_detail") and len(arguments.work_detail)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.work_detail#"><cfelse><cfqueryparam null="yes" value="" cfsqltype="cf_sql_nvarchar"></cfif>,
                    TOTAL_TIME_HOUR = <cfif isDefined("arguments.total_time_hour") and len(arguments.total_time_hour)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.total_time_hour#"><cfelse><cfqueryparam null="yes" value="" cfsqltype="cf_sql_nvarchar"></cfif>,
                    TOTAL_TIME_MINUTE = <cfif isDefined("arguments.total_time_minute") and len(arguments.total_time_minute)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.total_time_minute#"><cfelse><cfqueryparam null="yes" value="" cfsqltype="cf_sql_nvarchar"></cfif>,
                    TERMINATE_DATE = <cfif isdefined('arguments.terminate_date') and len(arguments.terminate_date)><cfqueryparam cfsqltype="cf_sql_date" value="#arguments.terminate_date#"><cfelse><cfqueryparam null="yes" value="" cfsqltype="cf_sql_nvarchar"></cfif>,
                    <cfif isDefined("arguments.target_start") and len(arguments.target_start)>TARGET_START =<cfqueryparam cfsqltype="cf_sql_date" value="#target_start#">,</cfif>
                    WORK_CURRENCY_ID = <cfif isdefined("arguments.process_stage")><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.process_stage#"><cfelse><cfqueryparam null="yes" value="" cfsqltype="cf_sql_nvarchar"></cfif>,
                    <cfif isDefined("arguments.work_status")>WORK_STATUS = <cfif arguments.work_status eq 'on'><cfqueryparam cfsqltype="cf_sql_integer" value="1"><cfelse><cfqueryparam cfsqltype="cf_sql_integer" value="0"></cfif>,</cfif>
                    TO_COMPLETE = <cfif isdefined("arguments.to_complate") and len(arguments.to_complate)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.to_complate#"><cfelse><cfqueryparam cfsqltype="cf_sql_integer" value="0"></cfif>,
                    UPDATE_AUTHOR = <cfif isdefined('session.ep.userid')><cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#"><cfelse><cfqueryparam null="yes" value="" cfsqltype="cf_sql_nvarchar"></cfif>,
                    UPDATE_PAR = <cfif isdefined('session.pp.userid')><cfqueryparam cfsqltype="cf_sql_integer" value="#session.pp.userid#"><cfelseif isdefined('session.ww.userid')><cfqueryparam cfsqltype="cf_sql_integer" value="#session.ww.userid#"></cfif>,
                    UPDATE_DATE = <cfqueryparam cfsqltype="cf_sql_date" value="#now()#">,
                    UPDATE_IP = <cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.remote_addr#">
                
                WHERE
                    WORK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.work_id#">
                        
            </cfquery>
            <cfif isdefined("arguments.first_work_detail") and len(arguments.first_work_detail)>
                <cfquery name="UPD_PRO_WORKS_DETAİL" datasource="#DSN#">
                    UPDATE 
                        PRO_WORKS_HISTORY 
                    SET
                        WORK_DETAIL = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.work_detail#">
                    WHERE 
                        HISTORY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.first_work_detail#">
                </cfquery>
            <cfelse>
                <cf_wrk_get_history  datasource='#dsn#' source_table='PRO_WORKS' target_table='PRO_WORKS_HISTORY' record_id='#arguments.work_id#' record_name='WORK_ID' insert_column_name="UPDATE_PAR,UPDATE_DATE,UPDATE_IP" insert_column_value="#session.pp.userid#,#now()#,#cgi.remote_addr#">  
            </cfif>
                        
            <cfset result.status = true>
            <cfset result.success_message = "Kaydı Yapıldı, Yönlendiriliyor">
            <cfset result.identity =  CreateObject("component", "WMO.functions").contentEncryptingandDecodingAES(isEncode:1,content:arguments.work_id,accountKey:"wrk")>
            <cfcatch type="any">
                <cfset result.status = false>
                <cfset result.danger_message = "Şuanda işlem yapılamıyor...">
                <cfset result.error = cfcatch >
                <cfdump var ="#cfcatch#">
            </cfcatch>  
        </cftry>
        <cfreturn Replace(SerializeJSON(result),'//','')>
    </cffunction>

    <cffunction name="get_projects" access="remote" returntype="any" hint="işlem kategorisine yetkili olunan projeler listelenir">
        <cfquery name="get_projects" datasource="#dsn#">
            SELECT 
                PROJECT_ID, 
                PROJECT_HEAD 
            FROM 
                PRO_PROJECTS 
            WHERE 
                PRO_PROJECTS.PROCESS_CAT IN
                (
                    SELECT  
                        SMC.MAIN_PROCESS_CAT_ID
                    FROM 
                        SETUP_MAIN_PROCESS_CAT SMC,
                        SETUP_MAIN_PROCESS_CAT_ROWS SMR,
                        EMPLOYEE_POSITIONS
                    WHERE
                        SMC.MAIN_PROCESS_CAT_ID = SMR.MAIN_PROCESS_CAT_ID AND
                        EMPLOYEE_POSITIONS.POSITION_CODE = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.position_code#"> AND 
                        (EMPLOYEE_POSITIONS.POSITION_CAT_ID = SMR.MAIN_POSITION_CAT_ID OR EMPLOYEE_POSITIONS.POSITION_CODE = SMR.MAIN_POSITION_CODE)
                ) 
                AND PROJECT_STATUS = 1 ORDER BY PROJECT_HEAD
        </cfquery>
        <cfreturn get_projects>
    </cffunction>

    <cffunction name="add_work_team" access="remote" returntype="string" returnargumentsat="json">
        <cfset result = StructNew()>
        <cftry>      
            <cfif not len(arguments.WORKGROUP_ID)>
                <CFLOCK name="#createUUID()#" timeout="20">
                    <CFTRANSACTION>
                    <cfquery name="INSGROUP" datasource="#dsn#" result="MAX_ID">
                        INSERT INTO 
                            WORK_GROUP 
                                (
                                    <cfif isDefined("arguments.project_id")>
                                        PROJECT_ID,
                                        WORKGROUP_NAME,
                                    <cfelseif isDefined("arguments.action_id")>
                                        ACTION_FIELD,
                                        ACTION_ID,
                                    </cfif>
                                    STATUS,
                                    RECORD_EMP,
                                    RECORD_DATE,
                                    RECORD_IP
                                ) 
                            VALUES 
                                (
                                    <cfif isDefined("arguments.project_id")>
                                        #arguments.project_id#,
                                        '#arguments.project_head#',
                                    <cfelseif isDefined("arguments.action_id")>
                                        '#arguments.action_field#',
                                        #arguments.action_id#,
                                    </cfif>
                                    1,
                                    #session.ep.userid#,
                                    #NOW()#,
                                    '#cgi.REMOTE_ADDR#'
                                )
                        </cfquery>
                    </CFTRANSACTION>
                    </CFLOCK>
                <cfset this_workgroup_id = MAX_ID.IDENTITYCOL>
            <cfelse>
                <cfset this_workgroup_id = arguments.WORKGROUP_ID>
                <cfquery name="del_work_emp_par" datasource="#dsn#">
                    DELETE FROM 
                        WORKGROUP_EMP_PAR WHERE WORKGROUP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#this_workgroup_id#"> 
                    AND OUR_COMPANY_ID = 
                    <cfif isDefined('session.ep.userid')>
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#">
                    <cfelseif isDefined('session.pp.userid')>
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#session.pp.our_company_id#">
                    <cfelseif isDefined('session.pda.userid')>
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#session.pda.our_company_id#">
                    </cfif>	
                </cfquery>
            </cfif>
            <cfquery name="GET_ROLES" datasource="#dsn#">
                SELECT * FROM SETUP_PROJECT_ROLES ORDER BY PROJECT_ROLES_ID
            </cfquery>
            <cfset role_list = listsort(ListRemoveDuplicates(valuelist(GET_ROLES.PROJECT_ROLES_ID,',')),'numeric','ASC',',')>

            <cfloop from="1" to="#arguments.record#" index="i">
                <cfif evaluate("arguments.row_kontrol#i#")>
                    <cfset this_role_id_ = evaluate("arguments.role_id#i#")>
                    <cfset this_role_name_ = GET_ROLES.PROJECT_ROLES[listfind(role_list,this_role_id_,',')]>
                    
                    <cfquery name="add_workgroup_emp_par" datasource="#DSN#" result="result_">
                        INSERT INTO 
                        WORKGROUP_EMP_PAR
                        (
                            WORKGROUP_ID,
                            EMPLOYEE_ID,
                            IS_REAL,
                            IS_CRITICAL,
                            HIERARCHY,
                            ROLE_HEAD,
                            ROLE_ID,
                            IS_ORG_VIEW,
                            CONSUMER_ID,
                            COMPANY_ID,
                            PARTNER_ID,
                            PRODUCT_ID,
                            PRODUCT_UNIT_PRICE,
                            PRODUCT_MONEY,
                            PRODUCT_UNIT,
                            RECORD_EMP,
                            RECORD_IP,
                            RECORD_DATE
                            <cfif isDefined("arguments.project_id")>,PROJECT_ID</cfif>
                            ,PER_HOUR_SALARY
                            ,OUR_COMPANY_ID
                        )
                        VALUES
                        (
                            #this_workgroup_id#,
                            <cfif isdefined("arguments.employee_id#i#") and len(evaluate("arguments.employee_id#i#"))>#evaluate("arguments.employee_id#i#")#<cfelse>NULL</cfif>,
                            1,
                            0,
                            <cfif isdefined("arguments.code#i#") and len(evaluate("arguments.code#i#"))>'#Evaluate("arguments.code#i#")#'<cfelse>NULL</cfif>,
                            '#this_role_name_#',
                            <cfif len(this_role_id_)>#this_role_id_#<cfelse>NULL</cfif>,
                            1,
                            <cfif isdefined('arguments.consumer_id#i#') and len(evaluate("arguments.consumer_id#i#"))>#evaluate("arguments.consumer_id#i#")#<cfelse>NULL</cfif>,
                            <cfif isdefined('arguments.company_id#i#') and len(evaluate("arguments.company_id#i#"))>#evaluate("arguments.company_id#i#")#<cfelse>NULL</cfif>,
                            <cfif isdefined('arguments.partner_id#i#') and len(evaluate("arguments.partner_id#i#"))>#evaluate("arguments.partner_id#i#")#<cfelse>NULL</cfif>,
                            <cfif isdefined('arguments.product_id#i#') and isdefined('arguments.product#i#') and len(evaluate("arguments.product#i#")) and len(evaluate("arguments.product_id#i#"))>#evaluate("arguments.product_id#i#")#<cfelse>NULL</cfif>,
                            <cfif isdefined('arguments.price#i#') and len(evaluate("arguments.price#i#"))>#evaluate("arguments.price#i#")#<cfelse>NULL</cfif>,
                            <cfif isdefined('arguments.money_type#i#') and len(evaluate("arguments.money_type#i#"))>'#Evaluate("arguments.money_type#i#")#'<cfelse>NULL</cfif>,
                            <cfif isdefined('arguments.unit_name#i#') and len(evaluate("arguments.unit_name#i#"))>'#Evaluate("arguments.unit_name#i#")#'<cfelse>NULL</cfif>
                            <cfif isDefined('session.ep.userid')>
                                ,<cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#">
                            <cfelseif isDefined('session.pp.userid')>
                                ,<cfqueryparam cfsqltype="cf_sql_integer" value="#session.pp.userid#">
                            <cfelseif isDefined('session.cp.userid')>
                                ,<cfqueryparam cfsqltype="cf_sql_integer" value="#session.cp.userid#">
                            </cfif>	,
                            '#cgi.remote_addr#',
                            #now()#
                            <cfif isDefined("arguments.project_id")>,#arguments.project_id#</cfif>
                            ,<cfif isDefined("arguments.per_hour_salary#i#") and len(evaluate("arguments.per_hour_salary#i#"))>#evaluate("arguments.per_hour_salary#i#")#<cfelse>NULL</cfif>
                            <cfif isDefined('session.ep.userid')>
                                ,<cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#">
                            <cfelseif isDefined('session.pp.userid')>
                                ,<cfqueryparam cfsqltype="cf_sql_integer" value="#session.pp.our_company_id#">
                            <cfelseif isDefined('session.cp.userid')>
                                ,<cfqueryparam cfsqltype="cf_sql_integer" value="#session.cp.our_company_id#">
                            </cfif>	
                        )
                    </cfquery>
                </cfif>
            </cfloop>
                <cfset result.status = true>
                <cfset result.success_message = "Kaydı Yapıldı, Yönlendiriliyor">
                <cfset result.identity = CreateObject("component", "WMO.functions").contentEncryptingandDecodingAES(isEncode:1,content:arguments.project_id,accountKey:"wrk")>
            <cfcatch type="any">
                <cfset result.status = false>
                <cfset result.danger_message = "Şuanda işlem yapılamıyor...">
                <cfset result.error = cfcatch >
                <cfdump var ="#cfcatch#">
            </cfcatch>
        </cftry>
        <cfreturn Replace(SerializeJSON(result),'//','')>
    </cffunction>

    <cffunction name="getWorks" access="remote" returntype="any" hint="iş listesi">
        <cfargument name="workgroup_id" default="">
        <cfargument name="xml_is_project_authority" default="">
        <cfargument name="recorder_name" default="">
        <cfargument name="keyword" default="">
        <cfargument name="work_cat" default="">
        <cfargument name="work_status" default="1">
        <cfargument name="pro_emp_id" default="">
        <cfargument name="PRIORITY_CAT" default="">
        <cfargument name="comp_id" default="">
        <cfargument name="comp_name" default="">
        <cfargument name="outsrc_partner_id" default="">
        <cfargument name="cc_name" default="">
        <cfargument name="cc_par_id" default="">
        <cfargument name="cc_emp_id" default="">
        <cfargument name="activity_id" default="">
        <cfargument name="show_milestone" default="">
        <cfargument name="special_definition" default="">
        <cfargument name="pro_emp_name" default="">
        <cfif len(arguments.workgroup_id)>
            <cfquery name="get_workgroup" datasource="#dsn#">
                SELECT EMPLOYEE_ID FROM WORKGROUP_EMP_PAR WHERE WORKGROUP_ID = #arguments.workgroup_id#
            </cfquery>
        </cfif>
        <cfquery name="get_works" datasource="#DSN#">
            SELECT * FROM 
            (SELECT
                CASE 
                    WHEN ISNULL(IS_MILESTONE,0) = 1 THEN WORK_ID
                    WHEN ISNULL(IS_MILESTONE,0) <> 1 THEN ISNULL(MILESTONE_WORK_ID,0)
                END AS NEW_WORK_ID,
                CASE 
                    WHEN ISNULL(IS_MILESTONE,1) = 1 THEN 0
                    WHEN ISNULL(IS_MILESTONE,1) <> 1 THEN 1
                END AS TYPE,
                PRO_WORKS.TARGET_START,
                PRO_WORKS.WORK_ID,
                PRO_WORKS.UPDATE_DATE,
                PRO_WORKS.RECORD_DATE,
                PRO_WORKS.IS_MILESTONE,
                PRO_WORKS.WORK_HEAD,
                PRO_WORKS.ESTIMATED_TIME,
                PRO_WORKS.PROJECT_ID,
                PRO_WORKS.CONSUMER_ID, 
                PRO_WORKS.COMPANY_ID,
                PRO_WORKS.COMPANY_PARTNER_ID,
                PRO_WORKS.TARGET_FINISH,
                PRO_WORKS.REAL_FINISH,
                PRO_WORKS.TERMINATE_DATE,
                PRO_WORKS.WORK_CURRENCY_ID,
                PRO_WORKS.WORK_PRIORITY_ID,
                PRO_WORKS.PROJECT_EMP_ID,
                PRO_WORK_CAT.WORK_CAT,
                PRO_WORKS.OUTSRC_PARTNER_ID,
                PRO_WORKS.TO_COMPLETE,
                PRO_WORKS.WORK_NO,
                SETUP_PRIORITY.PRIORITY,
                SETUP_PRIORITY.COLOR,
                PP.PROJECT_HEAD,
                CASE 
                    WHEN 
                        PRO_WORKS.PROJECT_EMP_ID IS NOT NULL 
                    THEN
                        (SELECT E.EMPLOYEE_NAME+' '+E.EMPLOYEE_SURNAME FROM EMPLOYEES E WHERE E.EMPLOYEE_ID = PRO_WORKS.PROJECT_EMP_ID) 
                    WHEN
                        PRO_WORKS.OUTSRC_PARTNER_ID IS NOT NULL
                    THEN 
                        (SELECT C.NICKNAME +' - '+CP.COMPANY_PARTNER_NAME+' '+CP.COMPANY_PARTNER_SURNAME FROM COMPANY_PARTNER CP,COMPANY C WHERE CP.PARTNER_ID = PRO_WORKS.OUTSRC_PARTNER_ID AND CP.COMPANY_ID=C.COMPANY_ID)
                END AS PROJECT_EMP,
                CASE 
                    WHEN 
                        PRO_WORKS.CONSUMER_ID IS NOT NULL 
                    THEN
                        (SELECT C.CONSUMER_NAME+' '+C.CONSUMER_SURNAME FROM CONSUMER C WHERE C.CONSUMER_ID = PRO_WORKS.CONSUMER_ID) 
                    WHEN
                        PRO_WORKS.COMPANY_PARTNER_ID IS NOT NULL
                    THEN 
                        (SELECT C.NICKNAME +' - '+CP.COMPANY_PARTNER_NAME+' '+CP.COMPANY_PARTNER_SURNAME FROM COMPANY_PARTNER CP,COMPANY C WHERE CP.PARTNER_ID = PRO_WORKS.COMPANY_PARTNER_ID AND CP.COMPANY_ID=C.COMPANY_ID)
                END AS COMPANY_PARTNER,
                (SELECT E.EMPLOYEE_NAME+' '+E.EMPLOYEE_SURNAME FROM EMPLOYEES E WHERE E.EMPLOYEE_ID = PRO_WORKS.RECORD_AUTHOR) RECORD_AUTHOR_NAME,
                (SELECT PTR.STAGE FROM PROCESS_TYPE_ROWS PTR WHERE PTR.PROCESS_ROW_ID = PRO_WORKS.WORK_CURRENCY_ID) STAGE
                ,ISNULL((SELECT SUM((ISNULL(TOTAL_TIME_HOUR,0)*60) + ISNULL(TOTAL_TIME_MINUTE,0)) FROM PRO_WORKS_HISTORY WHERE PRO_WORKS.WORK_ID = PRO_WORKS_HISTORY.WORK_ID <cfif isdefined('arguments.emp_name') and isdefined('arguments.project_emp_id') and len(arguments.emp_name) and len(arguments.project_emp_id)>AND UPDATE_AUTHOR IN (#arguments.project_emp_id#) </cfif> GROUP BY WORK_ID),0) HARCANAN_DAKIKA
                    ,(SELECT WG.WORKGROUP_NAME FROM WORK_GROUP WG WHERE WG.WORKGROUP_ID = PRO_WORKS.WORKGROUP_ID) WORKGROUP_NAME
                <cfif session.ep.our_company_info.workcube_sector is 'tersane'>
                    ,CASE WHEN PBS_ID IS NOT NULL THEN (SELECT PBS_CODE FROM #dsn3_alias#.SETUP_PBS_CODE WHERE PBS_ID = PRO_WORKS.PBS_ID) ELSE NULL END AS PBS_CODE
                </cfif>
            FROM 
                PRO_WORKS 
                    LEFT JOIN PRO_PROJECTS PP ON PP.PROJECT_ID = PRO_WORKS.PROJECT_ID
                    LEFT JOIN SETUP_PRIORITY ON PRO_WORKS.WORK_PRIORITY_ID = SETUP_PRIORITY.PRIORITY_ID,
                PRO_WORK_CAT
            WHERE 
                PRO_WORK_CAT.WORK_CAT_ID = PRO_WORKS.WORK_CAT_ID
                <cfif isdefined('xml_is_project_authority') and xml_is_project_authority eq 1>
                    AND 
                    (
                        PRO_WORKS.PROJECT_ID IN 
                        (
                            SELECT 
                                PRO_PROJECTS.PROJECT_ID
                            FROM
                                PRO_PROJECTS
                            WHERE
                                PRO_PROJECTS.PROCESS_CAT IN
                                (
                                    SELECT  
                                        SMC.MAIN_PROCESS_CAT_ID
                                    FROM 
                                        SETUP_MAIN_PROCESS_CAT SMC,
                                        SETUP_MAIN_PROCESS_CAT_ROWS SMR,
                                        EMPLOYEE_POSITIONS
                                    WHERE
                                        SMC.MAIN_PROCESS_CAT_ID = SMR.MAIN_PROCESS_CAT_ID AND
                                        EMPLOYEE_POSITIONS.POSITION_CODE = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.position_code#"> AND 
                                        (EMPLOYEE_POSITIONS.POSITION_CAT_ID = SMR.MAIN_POSITION_CAT_ID OR EMPLOYEE_POSITIONS.POSITION_CODE = SMR.MAIN_POSITION_CODE)
                                )
                        ) OR
                        PRO_WORKS.PROJECT_EMP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#"> OR
                        PRO_WORKS.PROJECT_ID IS NULL
                    )
                </cfif>
            <cfif isDefined('arguments.recorder_name') and len(arguments.recorder_name) and isdefined("arguments.recorder_id") and len(arguments.recorder_id)>
                AND PRO_WORKS.RECORD_AUTHOR = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.recorder_id#">
            </cfif>
            <cfif isDefined('arguments.upd_by_name') and len(arguments.upd_by_name) and isdefined("arguments.upd_by_id") and len(arguments.upd_by_id)>
                AND ISNULL(PRO_WORKS.UPDATE_AUTHOR,PRO_WORKS.RECORD_AUTHOR) = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.upd_by_id#">
            </cfif>
            <cfif len(arguments.keyword) gt 1>
                AND (
                    <cfif isNumeric(arguments.keyword)>
                        PRO_WORKS.WORK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.keyword#"> OR
                    </cfif>
                    PRO_WORKS.WORK_NO LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.keyword#%"> COLLATE SQL_Latin1_General_CP1_CI_AI OR
                    PRO_WORKS.WORK_HEAD LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.keyword#%"> COLLATE SQL_Latin1_General_CP1_CI_AI OR
                    PRO_WORKS.WORK_DETAIL LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.keyword#%"> COLLATE SQL_Latin1_General_CP1_CI_AI
                    )
            <cfelseif len(arguments.keyword) eq 1>
                AND (
                    <cfif isNumeric(arguments.keyword)>
                        PRO_WORKS.WORK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.keyword#"> OR
                    </cfif>
                    PRO_WORKS.WORK_HEAD LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.keyword#%"> COLLATE SQL_Latin1_General_CP1_CI_AI
                    )
            </cfif>
            <cfif isDefined("url.action_list_id") and Listlen(url.action_list_id) gt 0>AND PRO_WORKS.WORK_ID IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#url.action_list_id#" list="yes">)</cfif>
            <cfif len(arguments.CURRENCY)>
                AND PRO_WORKS.WORK_CURRENCY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.currency#">
            <cfelse>
                AND PRO_WORKS.WORK_CURRENCY_ID <> -3 <!--- bitti haric tüm kayıtlar --->
            </cfif>
            <cfif arguments.work_status eq -1>
                AND PRO_WORKS.WORK_STATUS = 0 
            <cfelseif arguments.work_status eq 0>
                AND (PRO_WORKS.WORK_STATUS = 0 OR PRO_WORKS.WORK_STATUS = 1)
            <cfelse><!--- default secim work_status eq 1 --->
                AND PRO_WORKS.WORK_STATUS = 1
            </cfif>
            <cfif len(arguments.PRIORITY_CAT)>
                AND PRO_WORKS.WORK_PRIORITY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.priority_cat# ">
            </cfif>
            <cfif len(arguments.work_cat)>
                AND PRO_WORKS.WORK_CAT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.work_cat# ">
            </cfif>
            <cfif isdefined("arguments.startdate") and len(arguments.startdate)>
                AND PRO_WORKS.TARGET_START >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.startdate#">
            </cfif>
            <cfif isdefined("arguments.finishdate") and len(arguments.finishdate)>
                AND PRO_WORKS.TARGET_FINISH <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.finishdate#">
            </cfif>
            <cfif len(arguments.comp_name) and len(arguments.comp_id)>
                AND PRO_WORKS.COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.comp_id#">
            </cfif>
            <cfif isdefined('arguments.emp_name') and isdefined('arguments.project_emp_id') and len(arguments.emp_name) and len(arguments.project_emp_id)>
                AND (
                        <cfif isdefined('arguments.work_emp_cc') and arguments.work_emp_cc neq 3>
                            PRO_WORKS.PROJECT_EMP_ID IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.project_emp_id#" list="yes">)
                        </cfif>
                        <cfif isdefined('arguments.work_emp_cc') and arguments.work_emp_cc eq 1>OR</cfif>
                        <cfif isdefined('arguments.work_emp_cc') and (arguments.work_emp_cc eq 1 or arguments.work_emp_cc eq 3) and arguments.work_emp_cc neq 2>
                            PRO_WORKS.WORK_ID IN (SELECT WORK_ID FROM PRO_WORKS_CC WHERE CC_EMP_ID IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.project_emp_id#" list="yes">))
                        </cfif>
                    )
            <cfelseif not len(arguments.outsrc_partner_id) and isdefined('arguments.emp_name') and len(arguments.emp_name)>
                AND (
                        PRO_WORKS.WORK_ID IN (SELECT PWC.WORK_ID FROM PRO_WORKS_CC PWC, EMPLOYEES EE WHERE PWC.CC_EMP_ID = EE.EMPLOYEE_ID AND  PWC.WORK_ID = PRO_WORKS.WORK_ID AND EE.EMPLOYEE_NAME + ' ' + EE.EMPLOYEE_SURNAME LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.emp_name#%">)
                    )
            <cfelseif isdefined("arguments.outsrc_partner_id") and len(arguments.outsrc_partner_id) and len(arguments.emp_name)>
                AND PRO_WORKS.OUTSRC_PARTNER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.outsrc_partner_id#">
            </cfif>
            <cfif len(arguments.project_id)>
                <cfif arguments.project_id eq -1>
                    AND PRO_WORKS.PROJECT_ID IS NULL
                <cfelse>
                    AND PRO_WORKS.PROJECT_ID IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.project_id#" list="yes">)
                </cfif>  
            </cfif>
            <cfif len(arguments.pro_emp_id) and len(arguments.pro_emp_name)>	
                AND PRO_WORKS.PROJECT_ID IN (SELECT PRO_PROJECTS.PROJECT_ID FROM PRO_PROJECTS WHERE PRO_PROJECTS.PROJECT_EMP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pro_emp_id#">) 
            </cfif>
            <cfif len(arguments.workgroup_id)>
                AND (PRO_WORKS.WORKGROUP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.workgroup_id#"><cfif get_workgroup.recordCount> OR PRO_WORKS.PROJECT_EMP_ID IN(#valueList(get_workgroup.EMPLOYEE_ID)#)</cfif>)
            </cfif>
            <cfif len(arguments.cc_name) and len(arguments.cc_emp_id)>
                AND PRO_WORKS.WORK_ID IN (SELECT WORK_ID FROM PRO_WORKS_CC WHERE CC_EMP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.cc_emp_id#">)
            </cfif>
            <cfif len(arguments.cc_name) and len(arguments.cc_par_id)>
                AND PRO_WORKS.WORK_ID IN (SELECT WORK_ID FROM PRO_WORKS_CC WHERE CC_PAR_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.cc_par_id#">)
            </cfif>
            <cfif isdefined("arguments.onfuseaction") and len(arguments.onfuseaction)>
                AND PRO_WORKS.WORK_FUSEACTION = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.onfuseaction#">
                AND PRO_WORKS.WORK_FUSEACTION IS NOT NULL
            </cfif>
            <cfif isdefined("arguments.onmodule") and len(arguments.onmodule)>
                AND PRO_WORKS.WORK_CIRCUIT = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.onmodule#">
                AND PRO_WORKS.WORK_CIRCUIT IS NOT NULL
            </cfif>
            <cfif isdefined("arguments.contract_id") and len(arguments.contract_id) and isdefined("arguments.contract_no") and len(arguments.contract_no)>
                AND (PRO_WORKS.PURCHASE_CONTRACT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.contract_id#"> OR PRO_WORKS.SALE_CONTRACT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.contract_id#">)
            </cfif>
            <cfif isdefined("arguments.pbs_id") and len(arguments.pbs_id) and isdefined("arguments.pbs_code") and len(arguments.pbs_code)>
                AND PRO_WORKS.PBS_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pbs_id#"> 
            </cfif>
            <cfif isdefined("arguments.expense_code") and len(arguments.expense_code) and len(arguments.expense_code_name)>
                AND PRO_WORKS.PROJECT_ID IN (SELECT PROJECT_ID FROM PRO_PROJECTS WHERE EXPENSE_CODE = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.expense_code#">)
            </cfif>
            <cfif isdefined("arguments.show_milestone") and arguments.show_milestone eq 0>
                AND PRO_WORKS.IS_MILESTONE <> 1
            </cfif>
            <cfif len(arguments.special_definition)>
                AND PRO_WORKS.SPECIAL_DEFINITION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.special_definition#">
            </cfif>
            <cfif isdefined("arguments.to_complete") and len(arguments.to_complete)>
                AND TO_COMPLETE=#arguments.to_complete#
            </cfif>
            <cfif isdefined("arguments.branch_id") and len(arguments.branch_id)>
                AND PRO_WORKS.PROJECT_EMP_ID IN (	
                                    SELECT EMPLOYEE_ID 
                                    FROM EMPLOYEE_POSITIONS,DEPARTMENT
                                    WHERE EMPLOYEE_POSITIONS.DEPARTMENT_ID = DEPARTMENT.DEPARTMENT_ID AND DEPARTMENT.BRANCH_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.branch_id#">
                                    )
            </cfif>
            <cfif isdefined("arguments.department") and len(arguments.department)>
                AND PRO_WORKS.PROJECT_EMP_ID IN (	
                                    SELECT EMPLOYEE_ID 
                                    FROM EMPLOYEE_POSITIONS
                                    WHERE 
                                    <cfif listlen(arguments.department,',') gt 1>
                                        EMPLOYEE_POSITIONS.DEPARTMENT_ID IN (#arguments.department#)
                                    <cfelse>
                                        EMPLOYEE_POSITIONS.DEPARTMENT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.department#">
                                    
                                    </cfif>
                                    )
            </cfif>
            <cfif isdefined("arguments.activity_id") and len(arguments.activity_id)>
                AND PRO_WORKS.ACTIVITY_ID = #arguments.activity_id#
            </cfif>
            )L1
            WHERE
                1=1 
                <cfif arguments.show_milestone eq 0>
                    AND IS_MILESTONE <> 1
                </cfif>
            ORDER BY	
                <cfif isdefined("arguments.ordertype") and arguments.ordertype eq 2>
                    ISNULL(UPDATE_DATE,RECORD_DATE) DESC
                <cfelseif isdefined("arguments.ordertype") and arguments.ordertype eq 3>
                    TARGET_START DESC
                <cfelseif isdefined("arguments.ordertype") and arguments.ordertype eq 4>
                    TARGET_START
                <cfelseif isdefined("arguments.ordertype") and arguments.ordertype eq 5>
                    TARGET_FINISH DESC	
                <cfelseif isdefined("arguments.ordertype") and arguments.ordertype eq 6>
                    TARGET_FINISH
                <cfelseif isdefined("arguments.ordertype") and arguments.ordertype eq 7>
                    WORK_HEAD	
                <cfelse>
                    NEW_WORK_ID, 
                    TYPE,
                    WORK_ID DESC
                </cfif>
        </cfquery>
        <cfreturn get_works>
    </cffunction>
    <cffunction name="getBranches" access="remote" returntype="any" hint="Şubeleri Getir">
        <cfquery name="GET_BRANCHES" datasource="#DSN#">
            SELECT
                BRANCH.BRANCH_STATUS,
                BRANCH.HIERARCHY,
                BRANCH.HIERARCHY2,
                BRANCH.BRANCH_ID,
                #dsn#.Get_Dynamic_Language(BRANCH.BRANCH_ID,'#session.ep.language#','BRANCH','BRANCH_NAME',NULL,NULL,BRANCH.BRANCH_NAME) AS BRANCH_NAME,
                OUR_COMPANY.COMP_ID,
                OUR_COMPANY.COMPANY_NAME,
                OUR_COMPANY.NICK_NAME
            FROM
                BRANCH
                LEFT JOIN OUR_COMPANY ON BRANCH.COMPANY_ID = OUR_COMPANY.COMP_ID
            WHERE
                BRANCH.BRANCH_ID IS NOT NULL
                AND BRANCH.BRANCH_STATUS = <cfqueryparam cfsqltype="cf_sql_integer" value="1">
            ORDER BY
                OUR_COMPANY.NICK_NAME,
                BRANCH.BRANCH_NAME
        </cfquery>
        <cfreturn GET_BRANCHES>
    </cffunction>
</cfcomponent>