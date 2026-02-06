<!--- 
    Author: Melek KOCABEY
    Date:   24/02/2021
    Desc:   proje modülü altında bulunan tüm query ler tek cfc ye alındı ve session da ki kullanıcı ya göre kontrol...
--->
<cfcomponent extends="cfc.queryJSONConverter">
    <cfset dsn = application.systemParam.systemParam().dsn />
     <cfif isdefined("session.pp")>
        <cfset session_base = evaluate('session.pp')>
        <cfset company_id = session.pp.our_company_id>
        <cfset period_year = session.pp.period_year>
    <cfelseif isdefined("session.qq")>
        <cfset session_base = evaluate('session.qq')>
        <cfset company_id = session.qq.our_company_id>
        <cfset period_year = session.qq.period_year>
    <cfelseif isdefined("session.ep")>
        <cfset session_base = evaluate('session.ep')>
        <cfset company_id = session.ep.company_id>
        <cfset period_year = session.ep.period_year>
    <cfelseif isdefined("session.cp")>
        <cfset session_base = evaluate('session.cp')>
    <cfelseif isdefined("session.ww")>
        <cfset session_base = evaluate('session.ww')>
        <cfset company_id = session.ww.our_company_id>
        <cfset period_year = session.ww.period_year>
    </cfif>
    <cfset dsn3_alias = '#dsn#_#company_id#'>
    <cfset dsn2_alias = '#dsn#_#period_year#_#company_id#'>
    <cfscript>
		functions = CreateObject("component","WMO.functions");
		contentEncryptingandDecodingAES = functions.contentEncryptingandDecodingAES;
        getLang = functions.getLang;
	</cfscript>
    <cffunction name="GET_PROCURRENCY" access="remote" returntype="query" output="no">
        <cfargument name="my_our_comp_" type="string" required="yes" default="">
        <cfargument name="fuseaction" type="string" required="no" default="">
        <cfquery name="GET_PROCURRENCY" datasource="#dsn#">
            SELECT
                PTR.STAGE,
                PTR.PROCESS_ROW_ID 
            FROM
                PROCESS_TYPE_ROWS PTR,
                PROCESS_TYPE_OUR_COMPANY PTO,
                PROCESS_TYPE PT
            WHERE
                PT.IS_ACTIVE = 1 AND
                PT.PROCESS_ID = PTR.PROCESS_ID AND
                PT.PROCESS_ID = PTO.PROCESS_ID AND
                PTO.OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.my_our_comp_#"> AND
                PT.FACTION LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.fuseaction#%">
            ORDER BY
                PTR.LINE_NUMBER
        </cfquery>
        <cfreturn GET_PROCURRENCY>
    </cffunction>
    <cffunction name="get_projects" access="remote" returntype="query" output="no">
        <cfargument name="keyword" type="string" required="no" default="">
        <cfargument name="priority_cat" type="string" required="no" default="">
        <cfargument name="currency" type="string" required="no" default="">
        <cfargument name="project_status" type="string" required="no" default="">
        <cfargument name="fuseaction" type="string" required="no" default="">
        <cfargument name="id" type="string" required="no" default="">
        <cfargument name="is_path" type="string" required="no" default="">
        <cfargument name="UpperProject_Id" type="string" required="no" default="">
        <cfquery name="get_projects" datasource="#dsn#">
            SELECT 
                DISTINCT(PRO_PROJECTS.PROJECT_ID),
                PRO_PROJECTS.PROJECT_HEAD,
                PRO_PROJECTS.PROJECT_DETAIL,
                PRO_PROJECTS.COMPANY_ID,
                PRO_PROJECTS.CONSUMER_ID,
                PRO_PROJECTS.PARTNER_ID,
                PRO_PROJECTS.PROJECT_EMP_ID,
                (SELECT EMPLOYEE_NAME +' '+ EMPLOYEE_SURNAME FROM EMPLOYEES WHERE EMPLOYEE_ID = PRO_PROJECTS.PROJECT_EMP_ID) PRO_EMPLOYEE,
                PRO_PROJECTS.OUTSRC_PARTNER_ID,
                PRO_PROJECTS.TARGET_FINISH,
                PRO_PROJECTS.TARGET_START,
                PRO_PROJECTS.PRO_PRIORITY_ID,
                PRO_PROJECTS.PRO_CURRENCY_ID,
                PRO_PROJECTS.PROCESS_CAT,
                PRO_PROJECTS.WORKGROUP_ID,
                PRO_PROJECTS.PROJECT_NUMBER,
                PRO_PROJECTS.PROJECT_STATUS,
                SETUP_PRIORITY.COLOR,
                EX.EXPENSE_ID, 
                EX.EXPENSE,
                CAT.*,
                PTR.STAGE,
                PTR.LINE_NUMBER,
                PRO_PROJECTS.IMG_PATH AS PATH,
                PRO_PROJECTS.PROJECT_PRESENTATION,
                PRO_PROJECTS.RELATED_PROJECT_ID,
                PRO_PROJECTS.SPECIAL_DEFINITION_ID,
                PRO_PROJECTS.EXPECTED_BUDGET,
                PRO_PROJECTS.BUDGET_CURRENCY,
                PRO_PROJECTS.EXPECTED_COST,
                PRO_PROJECTS.COST_CURRENCY,
                SSD.SPECIAL_DEFINITION_HEAD,
                (
                    (
                        SELECT
                            SUM(ISNULL(TO_COMPLETE,0))
                        FROM
                            PRO_WORKS PW
                        WHERE
                            PW.PROJECT_ID = PRO_PROJECTS.PROJECT_ID
                    )/
                    (
                        SELECT
                            COUNT(WORK_ID)
                        FROM
                            PRO_WORKS PW2
                        WHERE
                            PW2.PROJECT_ID = PRO_PROJECTS.PROJECT_ID
                    )
                ) COMPLETE_RATE,
                <!---baglanti kullanildiginda baglanti ile iliskili odeme yontemi var ise bilgilerini atıyor FA31012013 --->
                PROJECT_DISCOUNTS.PAYMETHOD_ID,
                PROJECT_DISCOUNTS.CARD_PAYMETHOD_ID,
                (CASE WHEN PROJECT_DISCOUNTS.PAYMETHOD_ID IS NOT NULL THEN 
                    (SELECT PAYMETHOD FROM SETUP_PAYMETHOD SP WHERE SP.PAYMETHOD_ID = PROJECT_DISCOUNTS.PAYMETHOD_ID)
                WHEN PROJECT_DISCOUNTS.CARD_PAYMETHOD_ID IS NOT NULL THEN
                    (SELECT CARD_NO FROM #dsn3_alias#.CREDITCARD_PAYMENT_TYPE CPT WHERE CPT.PAYMENT_TYPE_ID = PROJECT_DISCOUNTS.CARD_PAYMETHOD_ID)
                ELSE NULL END) AS PAYMETHOD_NAME,
                (CASE WHEN PROJECT_DISCOUNTS.PAYMETHOD_ID IS NOT NULL THEN 
                    (SELECT DUE_DAY FROM SETUP_PAYMETHOD SP WHERE SP.PAYMETHOD_ID = PROJECT_DISCOUNTS.PAYMETHOD_ID)
                ELSE NULL END) AS PAYMENT_DUEDAY,
                (CASE WHEN PROJECT_DISCOUNTS.PAYMETHOD_ID IS NOT NULL THEN 
                    (SELECT PAYMENT_VEHICLE FROM SETUP_PAYMETHOD SP WHERE SP.PAYMETHOD_ID = PROJECT_DISCOUNTS.PAYMETHOD_ID)
                ELSE NULL END) AS PAYMENT_VEHICLE,
                (CASE WHEN PROJECT_DISCOUNTS.CARD_PAYMETHOD_ID IS NOT NULL THEN
                    (SELECT COMMISSION_MULTIPLIER FROM #dsn3_alias#.CREDITCARD_PAYMENT_TYPE CPT WHERE CPT.PAYMENT_TYPE_ID = PROJECT_DISCOUNTS.CARD_PAYMETHOD_ID)
                ELSE NULL END) AS COMMISSION_RATE
                <!---baglanti kullanildiginda baglanti ile iliskili odeme yontemi var ise bilgilerini atıyor FA31012013 --->
            FROM
                PRO_PROJECTS
                LEFT JOIN SETUP_PRIORITY ON PRO_PROJECTS.PRO_PRIORITY_ID = SETUP_PRIORITY.PRIORITY_ID
                INNER JOIN SETUP_MAIN_PROCESS_CAT AS CAT ON CAT.MAIN_PROCESS_CAT_ID = PRO_PROJECTS.PROCESS_CAT
                LEFT JOIN PROCESS_TYPE_ROWS PTR ON PTR.PROCESS_ROW_ID =  PRO_PROJECTS.PRO_CURRENCY_ID  
                LEFT JOIN #dsn3_alias#.PROJECT_DISCOUNTS ON PROJECT_DISCOUNTS.PROJECT_ID = PRO_PROJECTS.PROJECT_ID
                LEFT JOIN #dsn2_alias#.EXPENSE_CENTER EX ON EX.EXPENSE_CODE = PRO_PROJECTS.EXPENSE_CODE 
                LEFT JOIN WORKGROUP_EMP_PAR AS WEP ON WEP.PROJECT_ID = PRO_PROJECTS.PROJECT_ID
                LEFT JOIN PRO_PROJECTS AS P2 ON P2.PROJECT_ID = PRO_PROJECTS.RELATED_PROJECT_ID
                LEFT JOIN SETUP_SPECIAL_DEFINITION SSD ON SSD.SPECIAL_DEFINITION_ID = PRO_PROJECTS.SPECIAL_DEFINITION_ID
            WHERE 
                1 = 1
                <cfif isDefined('session.pp.userid') and (not len(arguments.is_path))>
                    AND
                    (
                        PRO_PROJECTS.OUTSRC_PARTNER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.pp.userid#"> OR
                        WEP.PARTNER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.pp.userid#"> OR
                        PRO_PROJECTS.OUTSRC_CMP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.pp.company_id#"> OR
                        PRO_PROJECTS.COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.pp.company_id#"> OR
                        PRO_PROJECTS.UPDATE_PAR = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.pp.userid#"> OR
                        PRO_PROJECTS.RECORD_PAR = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.pp.userid#">
                    )
                </cfif>
                <cfif len(arguments.is_path) and arguments.is_path eq 1>
                    AND PRO_PROJECTS.IMG_PATH IS NOT NULL             
                </cfif>
                <cfif len(arguments.UpperProject_Id)>
                    AND PRO_PROJECTS.PROJECT_ID IN (SELECT PROJECT_ID FROM PRO_PROJECTS AS P WHERE P.RELATED_PROJECT_ID IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.UpperProject_Id#" list="yes">) )
                <cfelseif len(arguments.is_path) and arguments.is_path eq 1>
                    AND PRO_PROJECTS.RELATED_PROJECT_ID IS NOT NULL 
                </cfif>
                <cfif isdefined("arguments.id") and len(arguments.id)>
                    AND PRO_PROJECTS.PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
                </cfif>
                <cfif isDefined("arguments.project_cat") and len(arguments.project_cat)>
                    AND PRO_PROJECTS.PROCESS_CAT IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.project_cat#" list="yes">)
                <cfelse>
                    AND PRO_PROJECTS.PROCESS_CAT IN
                    (
                        SELECT  
                            SMC.MAIN_PROCESS_CAT_ID
                        FROM 
                            SETUP_MAIN_PROCESS_CAT SMC,
                            SETUP_MAIN_PROCESS_CAT_ROWS SMR,
                            EMPLOYEE_POSITIONS
                        WHERE
                            SMC.MAIN_PROCESS_CAT_ID=SMR.MAIN_PROCESS_CAT_ID AND
                            <cfif isDefined('session.ep.userid')>
                                EMPLOYEE_POSITIONS.POSITION_CODE = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.position_code#"> AND 
                            </cfif>
                            ( EMPLOYEE_POSITIONS.POSITION_CAT_ID = SMR.MAIN_POSITION_CAT_ID OR EMPLOYEE_POSITIONS.POSITION_CODE=SMR.MAIN_POSITION_CODE )
                    )
                </cfif>
                <cfif len(arguments.keyword) gt 1>
                    AND (
                            PRO_PROJECTS.PROJECT_NUMBER LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.keyword#%"> OR
                            PRO_PROJECTS.AGREEMENT_NO = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.keyword#"> OR
                            PRO_PROJECTS.PROJECT_HEAD LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.keyword#%"> OR
                            PRO_PROJECTS.PROJECT_DETAIL LIKE <cfqueryparam cfsqltype="cf_sql_longvarchar" value="%#arguments.keyword#%">
                        )
                <cfelseif len(arguments.keyword) eq 1>
                    AND (
                            PRO_PROJECTS.PROJECT_NUMBER = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.keyword#"> OR
                            PRO_PROJECTS.PROJECT_HEAD LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.keyword#%">
                        )
                </cfif>
                <cfif len(arguments.currency)>
                    AND PRO_PROJECTS.PRO_CURRENCY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.currency#">
                </cfif>
                <cfif len(arguments.priority_cat)>
                    AND PRO_PROJECTS.PRO_PRIORITY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.priority_cat#">
                </cfif>
                <cfif isdefined("arguments.project_status") and arguments.project_status is "1">
                    AND PRO_PROJECTS.PROJECT_STATUS = 1
                <cfelseif isdefined("arguments.project_status") and arguments.project_status is "-1">
                    AND PRO_PROJECTS.PROJECT_STATUS = 0 
                <cfelseif isdefined("arguments.project_status") and arguments.project_status is "0">
                    AND (PRO_PROJECTS.PROJECT_STATUS = 0 OR PRO_PROJECTS.PROJECT_STATUS = 1)
                <cfelse><!--- default secim --->
                    AND PRO_PROJECTS.PROJECT_STATUS = 1
                </cfif>
                <cfif isdefined("arguments.member_type_") and (arguments.member_type_ is 'PARTNER') and len(arguments.member_name_) and len(arguments.company_id_)>
                    AND PRO_PROJECTS.COMPANY_ID = #arguments.company_id_#
                </cfif>
                <cfif isdefined("arguments.member_type_") and (arguments.member_type_ is 'CONSUMER') and len(arguments.member_name_) and len(arguments.consumer_id_)>
                    AND PRO_PROJECTS.CONSUMER_ID = #arguments.consumer_id_#
                </cfif>
                <cfif isDefined("is_control_branch_project") and is_control_branch_project eq 1>
                    <cfif isDefined('session.ep.position_code')>
                        AND PRO_PROJECTS.BRANCH_ID IN (SELECT BRANCH_ID FROM EMPLOYEE_POSITION_BRANCHES WHERE POSITION_CODE = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.position_code#">)
                    </cfif>
                </cfif>
                <cfif isDefined("arguments.emp_id") and len(arguments.emp_id)>
                    AND PRO_PROJECTS.PROJECT_EMP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.emp_id#">
                </cfif>
            ORDER BY
                PROJECT_HEAD
        </cfquery>
        <cfreturn get_projects >
    </cffunction>
    <cffunction name="GET_CAT" access="remote" returntype="query">
        <cfargument name="keyword" default="process_cat">
        <cfquery name="GET_CAT" datasource="#dsn#">
            SELECT MAIN_PROCESS_CAT FROM SETUP_MAIN_PROCESS_CAT WHERE MAIN_PROCESS_CAT_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.process_cat#">
        </cfquery>
        <cfreturn GET_CAT>
    </cffunction>
    <cffunction name="PROJECT_DETAIL" access="remote" returntype="query">
        <cfquery name="PROJECT_DETAIL" datasource="#DSN#">
            SELECT 
                p.*,
                (
                    (
                        SELECT
                            SUM(ISNULL(TO_COMPLETE,0))
                        FROM
                            PRO_WORKS PW
                        WHERE
                            PW.PROJECT_ID = P.PROJECT_ID
                    )/
                    (
                        SELECT
                            COUNT(WORK_ID)
                        FROM
                            PRO_WORKS PW2
                        WHERE
                            PW2.PROJECT_ID = P.PROJECT_ID
                    )
                ) COMPLETE_RATE,
                CP.COMPANY_PARTNER_NAME + ' ' + CP.COMPANY_PARTNER_SURNAME AS COMPANY_PARTNER,
                C.CONSUMER_NAME + ' ' + CONSUMER_SURNAME AS CONSUMER,
                C2.FULLNAME,
                E.EMPLOYEE_NAME + ' ' + E.EMPLOYEE_SURNAME AS EMPLOYEE,
                CP2.COMPANY_PARTNER_NAME + ' ' + CP2.COMPANY_PARTNER_SURNAME AS COMPANY_PARTNER2,
                PTR.STAGE,
                SP.PRIORITY,
                P2.PROJECT_HEAD AS PROJECT_HEAD2,
                E2.EMPLOYEE_NAME + ' ' + E2.EMPLOYEE_SURNAME AS RECORD_EMPLOYEE,
                E3.EMPLOYEE_NAME + ' ' + E3.EMPLOYEE_SURNAME AS UPDATE_EMPLOYEE,
                '' AS CONTRACT_ID,
                '' AS CONTRACT_TYPE
            FROM
                PRO_PROJECTS AS P
                LEFT JOIN SETUP_MONEY AS SM ON P.BUDGET_CURRENCY = SM.MONEY
                LEFT JOIN COMPANY_PARTNER AS CP ON CP.PARTNER_ID = P.PARTNER_ID
                LEFT JOIN CONSUMER AS C ON C.CONSUMER_ID = P.CONSUMER_ID
                LEFT JOIN COMPANY AS C2 ON C2.COMPANY_ID = P.COMPANY_ID
                LEFT JOIN EMPLOYEES AS E ON E.EMPLOYEE_ID = P.PROJECT_EMP_ID
                LEFT JOIN COMPANY_PARTNER AS CP2 ON P.OUTSRC_PARTNER_ID = CP2.PARTNER_ID
                LEFT JOIN PROCESS_TYPE_ROWS AS PTR ON PTR.PROCESS_ROW_ID = P.PRO_CURRENCY_ID 
                LEFT JOIN SETUP_PRIORITY AS SP ON SP.PRIORITY_ID = P.PRO_PRIORITY_ID     
                LEFT JOIN PRO_PROJECTS AS P2 ON P2.PROJECT_ID = P.RELATED_PROJECT_ID
                LEFT JOIN EMPLOYEES AS E2 ON E2.EMPLOYEE_ID = P.RECORD_EMP
                LEFT JOIN EMPLOYEES AS E3 ON E3.EMPLOYEE_ID = P.UPDATE_EMP                                       
            WHERE
                <cfif isDefined('session.pp.userid')>
                    SM.PERIOD_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.pp.period_id#"> AND  
                <cfelseif isDefined('session.ep.userid')> 
                    SM.PERIOD_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.period_id#"> AND 
                <cfelseif isDefined('session.ww.userid')> 
                    SM.PERIOD_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ww.period_id#"> AND  
                </cfif>
                <cfif isDefined('arguments.project_id')>
                    P.PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.project_id#">
                <cfelseif isDefined('arguments.id')>
                    P.PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">        
                </cfif>
            ORDER BY 
                P.RECORD_DATE
        </cfquery>
        <cfreturn PROJECT_DETAIL>
    </cffunction>
    <cffunction name="GET_PRO_WORK" access="remote" returntype="query">
        <cfargument name="keyword" type="string" required="no" default="">
        <cfargument name="priority_cat" type="string" required="no" default="">
        <cfargument name="currency" type="string" required="no" default="">
        <cfargument name="work_status" type="string" required="no" default="">
        <cfargument name="work_milestones" type="string" required="no" default="">
        <cfquery name="GET_PRO_WORK" datasource="#DSN#">
            SELECT
                WORK_ID,
                TYPE,
                MILESTONE_WORK_ID,
                COLOR,
                WORK_HEAD,
                PROJECT_ID,
                EMPLOYEE,
                WORK_PRIORITY_ID,
                PRIORITY,
                STAGE,
                TO_COMPLETE,
                TERMINATE_DATE,
                TARGET_FINISH,
                TARGET_START
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
                    PW.PROJECT_ID,
                    PW.ESTIMATED_TIME,
                    (SELECT PTR.STAGE FROM PROCESS_TYPE_ROWS PTR WHERE PTR.PROCESS_ROW_ID= PW.WORK_CURRENCY_ID) STAGE,
                    PW.WORK_PRIORITY_ID,
                    CASE 
                        WHEN PW.PROJECT_EMP_ID IS NOT NULL THEN (SELECT E.EMPLOYEE_NAME +' '+ E.EMPLOYEE_SURNAME FROM EMPLOYEES E WHERE E.EMPLOYEE_ID = PW.PROJECT_EMP_ID)
                        WHEN PW.OUTSRC_PARTNER_ID IS NOT NULL THEN (SELECT C2.NICKNAME+' - '+ CP2.COMPANY_PARTNER_NAME + ' ' + CP2.COMPANY_PARTNER_SURNAME NAME FROM COMPANY_PARTNER CP2,COMPANY C2 WHERE C2.COMPANY_ID = CP2.COMPANY_ID AND CP2.PARTNER_ID = PW.OUTSRC_PARTNER_ID)
                    END AS EMPLOYEE,
                    PW.TARGET_FINISH,
                    PW.TERMINATE_DATE,
                    PW.TARGET_START,
                    PW.REAL_FINISH,
                    PW.REAL_START,
                    PW.TO_COMPLETE,
                    PW.UPDATE_DATE,
                    PW.RECORD_DATE,
                    SP.PRIORITY,
                    SP.COLOR,
                    (SELECT PRO_MATERIAL.PRO_MATERIAL_ID FROM PRO_MATERIAL WHERE PRO_MATERIAL.WORK_ID = PW.WORK_ID) PRO_MATERIAL_ID
                FROM
                    PRO_WORKS AS PW
                    LEFT JOIN SETUP_PRIORITY AS SP ON PW.WORK_PRIORITY_ID = SP.PRIORITY_ID
                WHERE
                    1=1
                    <cfif isDefined('arguments.project_id') and len(arguments.project_id)>
                        AND PW.PROJECT_ID IN (#arguments.project_id#)
                    </cfif>                    
                    <cfif len(arguments.keyword)>
                        AND 
                        (
                            <cfif isNumeric(arguments.keyword)>
                                PW.WORK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.keyword#"> OR 
                            </cfif>
                            PW.WORK_HEAD LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.keyword#%">
                        )
                    </cfif>
                    <cfif len(arguments.priority_cat)>
                        AND PW.WORK_PRIORITY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.priority_cat#">
                    </cfif>
                    <cfif len(arguments.currency)>
                        AND PW.WORK_CURRENCY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.currency#">
                    </cfif>
                    <cfif isDefined('arguments.g_service_id') and len(arguments.g_service_id)>
                        AND PW.G_SERVICE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.g_service_id#">
                    </cfif>
                    <cfif isDefined('arguments.service_id') and len(arguments.service_id)>
                        AND PW.G_SERVICE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.service_id#">
                    </cfif>
                    <cfif isDefined('arguments.subscription_id') and len(arguments.subscription_id)>
                        AND PW.SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_id#">
                    </cfif>
                    <cfif arguments.work_status eq -1>
                        AND PW.WORK_STATUS = 0<!---  OR PW.IS_MILESTONE = 1 --->
                    <cfelseif arguments.work_status eq 1>
                        AND PW.WORK_STATUS = 1 <!--- OR PW.IS_MILESTONE = 1 --->
                    </cfif>
                    <cfif isdefined('session.pp.company_id')>
                        AND PW.COMPANY_ID= <cfqueryparam cfsqltype="cf_sql_integer" value="#session.pp.company_id#">
                    <cfelseif isdefined('session.ww.userid')>
                        AND PW.CONSUMER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ww.company_id#">
                    </cfif> 
            )T1
            WHERE
                1=1 
                <cfif arguments.work_milestones eq 0>
                    AND IS_MILESTONE <> 1
                </cfif>
            ORDER BY
                    NEW_WORK_ID
                <cfif isdefined("arguments.ordertype") and arguments.ordertype eq 2>
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
     <cffunction name="GET_DEPARTMENT_NAME" access="remote" returntype="query" output="no">
        <cfargument name="fuseaction" type="string" required="no" default="">
            <cfquery name="GET_DEPARTMENT_NAME" datasource="#DSN#">
            SELECT 
                SL.LOCATION_ID,
                SL.COMMENT,
                D.DEPARTMENT_ID,
                D.DEPARTMENT_HEAD,
                D.BRANCH_ID
            FROM
                STOCKS_LOCATION SL,
                DEPARTMENT D
            WHERE 
                SL.DEPARTMENT_ID = D.DEPARTMENT_ID
                AND D.BRANCH_ID IN (SELECT BRANCH_ID FROM BRANCH WHERE COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session_base.company_id#">)
            ORDER BY
                D.DEPARTMENT_HEAD,
                SL.COMMENT
        </cfquery>
        <cfreturn GET_DEPARTMENT_NAME>
    </cffunction>
    <cffunction name="GET_SPECIAL_DEF" access="remote" returntype="query" output="no">
        <cfquery name="GET_SPECIAL_DEF" datasource="#dsn#">
            SELECT SPECIAL_DEFINITION_ID,SPECIAL_DEFINITION FROM SETUP_SPECIAL_DEFINITION WHERE SPECIAL_DEFINITION_TYPE = <cfqueryparam cfsqltype="cf_sql_integer" value="6">
        </cfquery>
        <cfreturn GET_SPECIAL_DEF>
    </cffunction>   
    <cffunction name="add_project" access="remote" returntype="string" returnargumentsat="json">
        <cfset result = StructNew()>
        <cfscript>
            arguments.pro_h_start = DateAdd('h',arguments.START_HOUR, arguments.pro_h_start);
            arguments.pro_h_finish = DateAdd('h',arguments.FINISH_HOUR, arguments.pro_h_finish);
        </cfscript>
        <cftry>       
            <cfquery name="ADD_PROJECT" datasource="#DSN#" result="MAX_ID">
    
                INSERT INTO 
                    PRO_PROJECTS
                (
                        OUTSRC_CMP_ID,
                        COMPANY_ID,
                        CONSUMER_ID,
                        PROJECT_EMP_ID,
                        PROJECT_HEAD,
                        PROJECT_DETAIL,
                        TARGET_START,
                        TARGET_FINISH,
                        PRO_CURRENCY_ID,
                        RECORD_DATE,
                        RECORD_EMP,
                        RECORD_IP,	
                        PROJECT_STATUS,
                        PROCESS_CAT,
                        AGREEMENT_NO,
                        WORKGROUP_ID,
                        BRANCH_ID,
                        DEPARTMENT_ID,
                        LOCATION_ID,
                        COUNTRY_ID,
                        SALES_ZONE_ID,
                        SPECIAL_DEFINITION_ID,
                        CITY_ID,
                        COUNTY_ID,
                        BUDGET_CURRENCY,
                        PROJECT_NUMBER,
                        PRO_PRIORITY_ID,
                        UPDATE_EMP,
                        UPDATE_DATE,
                        UPDATE_IP
                )
                VALUES
                (
                    <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.session_base#">,
                    <cfif isdefined('session.pp.company_id')>
                       <cfqueryparam cfsqltype="cf_sql_integer" value="#session.pp.company_id#">,
                       <cfqueryparam null="yes" value="" cfsqltype="cf_sql_nvarchar">,
                    <cfelseif isdefined('session.ww.company_id')>
                        <cfqueryparam null="yes" value="" cfsqltype="cf_sql_nvarchar">,
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ww.company_id#">,
                    </cfif>
                    <cfif isdefined('arguments.project_emp_id') and len(arguments.project_emp_id)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.PROJECT_EMP_ID#">,<cfelse>NULL,</cfif>
                    <cfif isdefined('arguments.PROJECT_HEAD') and len(arguments.PROJECT_HEAD)><cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.PROJECT_HEAD#"><cfelse>NULL</cfif>,
                    <cfif isDefined("arguments.project_detail") and len(arguments.project_detail)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.PROJECT_DETAIL#"></cfif>,
                    <cfif isdefined('arguments.PRO_H_START') and len(arguments.PRO_H_START)>#arguments.PRO_H_START#<cfelse>NULL</cfif>,
                    <cfif isdefined('arguments.PRO_H_FINISH') and len(arguments.PRO_H_FINISH)>#arguments.PRO_H_FINISH#<cfelse>NULL</cfif>,
                    <cfif isdefined('arguments.process_stage') and len(arguments.process_stage)>#arguments.process_stage#<cfelse>NULL</cfif>,
                    #NOW()#,
                    <cfif isdefined('session.pp.userid')>
                       <cfqueryparam cfsqltype="cf_sql_integer" value="#session.pp.userid#">,
                    <cfelseif isdefined('session.ww.userid')>
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ww.userid#">,
                    </cfif>
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#CGI.REMOTE_ADDR#">,
                    <cfqueryparam cfsqltype="cf_sql_integer" value="1">,
                    <cfif isdefined('arguments.main_process_cat') and len(arguments.main_process_cat)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.main_process_cat#"><cfelse>NULL</cfif>,
                    <cfif isdefined("arguments.agreement_no") and len(arguments.agreement_no)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.agreement_no#">,<cfelse>NULL,</cfif>
                    <cfif isdefined("arguments.workgroup_id") and len(arguments.workgroup_id)>#arguments.workgroup_id#<cfelse>NULL</cfif>,
                    <cfif isdefined("arguments.branch_id") and len(arguments.branch_id)>#arguments.branch_id#<cfelse>NULL</cfif>,
                    <cfif isdefined("arguments.department") and len(arguments.department)>#listfirst(arguments.department,'-')#<cfelse>NULL</cfif>,
                    <cfif isdefined("arguments.department") and len(arguments.department)>#listlast(arguments.department,'-')#<cfelse>NULL</cfif>,
                    <cfif isdefined("arguments.country_id") and len(arguments.country_id)>#arguments.country_id#<cfelse>NULL</cfif>,
                    <cfif isdefined("arguments.sales_zone_id") and len(arguments.sales_zone_id)>#arguments.sales_zone_id#<cfelse>NULL</cfif>,
                    <cfif isdefined("arguments.special_definition") and len(arguments.special_definition)>#arguments.special_definition#<cfelse>NULL</cfif>,
                    <cfif isdefined("arguments.city_id") and len(arguments.city_id)>#arguments.city_id#<cfelse>NULL</cfif>,
                    <cfif isdefined("arguments.county_id") and len(arguments.county_id)>#arguments.county_id#<cfelse>NULL</cfif>,
                    <cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.money_base#">,
                    <cfif isdefined("arguments.project_number") and len(arguments.project_number)><cfqueryparam cfsqltype="cf_sql_nvarchar" value="#trim(arguments.project_number)#"><cfelse>NULL</cfif>,
                    <cfif isdefined('arguments.priority_cat') and len(arguments.priority_cat)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.priority_cat#"><cfelse>NULL</cfif>,
                    <cfif isdefined('session.pp.userid')><cfqueryparam cfsqltype="cf_sql_integer" value="#session.pp.userid#">,<cfelseif isdefined('session.ww.userid')><cfqueryparam cfsqltype="cf_sql_integer" value="#session.ww.userid#">,</cfif>
                    <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.remote_addr#">
                )
                SELECT SCOPE_IDENTITY() AS MAX_PROJECT_ID                
            </cfquery>  
            <cf_wrk_get_history  datasource='#dsn#' source_table='PRO_PROJECTS' target_table='PRO_HISTORY' record_id='#ADD_PROJECT.MAX_PROJECT_ID#' record_name='PROJECT_ID' insert_column_name="UPDATE_EMP,UPDATE_DATE,UPDATE_IP" insert_column_value="#session.pp.userid#,#now()#,#cgi.remote_addr#">          
            <cfset result.status = true>
            <cfset result.success_message = "Kaydı Yapıldı, Yönlendiriliyor">
            <cfset iid = contentEncryptingandDecodingAES(isEncode:1,content:ADD_PROJECT.MAX_PROJECT_ID,accountKey:"wrk")>
            <cfset result.identity = iid>
            <cfcatch type="any">
                <cfset result.status = false>
                <cfset result.danger_message = "Şuanda işlem yapılamıyor...">
                <cfset result.error = cfcatch >
                <cfdump var ="#result.error#">
            </cfcatch>  
        </cftry>
        <cfreturn Replace(SerializeJSON(result),'//','')>
    </cffunction>
    <cffunction name="upd_project" access="remote" returntype="string" returnargumentsat="json">
        <cfset result = StructNew()>
        <cfscript>
            arguments.target_start = DateAdd('h',arguments.START_HOUR, arguments.target_start);
            arguments.target_finish = DateAdd('h',arguments.FINISH_HOUR, arguments.target_finish);

            arguments.target_start = DateAdd('m',arguments.START_MIN, arguments.target_start);
            arguments.target_finish = DateAdd('m',arguments.FINISH_MIN, arguments.target_finish);
        </cfscript>
        <cftry>       
            <cfquery name="UPD_PROJECT" datasource="#DSN#">
                UPDATE 
                    PRO_PROJECTS
                SET
                    PROJECT_EMP_ID = <cfif isdefined('arguments.project_emp_id') and len(arguments.project_emp_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.PROJECT_EMP_ID#"><cfelse>NULL</cfif>,
                    PROJECT_HEAD = <cfif isdefined('arguments.PROJECT_HEAD') and len(arguments.PROJECT_HEAD)><cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.PROJECT_HEAD#"><cfelse>NULL</cfif>,
                    PROJECT_DETAIL = <cfif isDefined("arguments.project_detail") and len(arguments.project_detail)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.PROJECT_DETAIL#"><cfelse>NULL</cfif>,
                    TARGET_START = <cfif isdefined('arguments.target_start') and len(arguments.target_start)><cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.target_start#"><cfelse>NULL</cfif>,
                    TARGET_FINISH = <cfif isdefined('arguments.target_finish') and len(arguments.target_finish)><cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.target_finish#"><cfelse>NULL</cfif>,
                    PROJECT_STATUS = <cfif isdefined('arguments.project_status') and len(arguments.project_status)><cfqueryparam cfsqltype="cf_sql_bit" value="1"><cfelse><cfqueryparam cfsqltype="cf_sql_bit" value="0"></cfif>,
                    PROCESS_CAT = <cfif isdefined('arguments.main_process_cat') and len(arguments.main_process_cat)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.main_process_cat#"><cfelse>NULL</cfif>,
                    PRO_CURRENCY_ID = <cfif isdefined('arguments.process_stage') and len(arguments.process_stage)>#arguments.process_stage#<cfelse>NULL</cfif>,
                    PROJECT_NUMBER = <cfif isdefined("arguments.project_number") and len(arguments.project_number)><cfqueryparam cfsqltype="cf_sql_nvarchar" value="#trim(arguments.project_number)#"><cfelse>NULL</cfif>,
                    UPDATE_DATE= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,    
                    UPDATE_EMP= <cfif isdefined('session.pp.userid')><cfqueryparam cfsqltype="cf_sql_integer" value="#session.pp.userid#">,<cfelseif isdefined('session.ww.userid')><cfqueryparam cfsqltype="cf_sql_integer" value="#session.ww.userid#">,</cfif>
                    UPDATE_IP=<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.remote_addr#">,
                    PRO_PRIORITY_ID = <cfif isdefined('arguments.priority_cat') and len(arguments.priority_cat)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.priority_cat#"><cfelse>NULL</cfif>
                WHERE  
                    PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.project_id#">
            </cfquery> 
            <cf_wrk_get_history  datasource='#dsn#' source_table='PRO_PROJECTS' target_table='PRO_HISTORY' record_id='#arguments.project_id#' record_name='PROJECT_ID' insert_column_name="UPDATE_PAR,UPDATE_DATE,UPDATE_IP" insert_column_value="#session.pp.userid#,#now()#,#cgi.remote_addr#">
            
            <cfset result.status = true>
            <cfset result.success_message = "Kaydı Yapıldı, Yönlendiriliyor">
            <cfset iid = contentEncryptingandDecodingAES(isEncode:1,content:arguments.project_id,accountKey:"wrk")>
            <cfset result.identity = iid>
            <cfcatch type="any">
                <cfset result.status = false>
                <cfset result.danger_message = "Şuanda işlem yapılamıyor...">
                <cfset result.error = cfcatch >
                <cfdump var ="#result.error#">
            </cfcatch>  
        </cftry>
        <cfreturn Replace(SerializeJSON(result),'//','')>
    </cffunction>
    <cffunction name="get_work" access="remote" returntype="query" output="no">
        <cfargument name="id" type="integer" required="yes" default="">
        <cfquery name="get_work" datasource="#dsn#">
            SELECT
                PROCESS_TYPE_ROWS.STAGE STAGE,
                COUNT(WORK_ID) AS DURUM_SAYI		
            FROM 
                PRO_WORKS,
                PROCESS_TYPE_ROWS
            WHERE
                PROCESS_TYPE_ROWS.PROCESS_ROW_ID = PRO_WORKS.WORK_CURRENCY_ID
                <cfif isdefined('arguments.id') and len(arguments.id)>
                    AND PRO_WORKS.PROJECT_ID = #arguments.id#
                </cfif>
            GROUP BY 
                PROCESS_TYPE_ROWS.STAGE
        </cfquery>
        <cfreturn get_work>
    </cffunction>
    <cffunction name="get_work_cat" access="remote" returntype="query" output="no">
        <cfargument name="id" type="integer" required="yes" default="">
        <cfquery name="get_work_cat" datasource="#dsn#">
            SELECT
                PWC.WORK_CAT WORK_CAT,
                COUNT(WORK_ID) AS COUNT_WORK		
            FROM 
                PRO_WORKS PW
                LEFT JOIN PRO_WORK_CAT PWC ON  PW.WORK_CAT_ID = PWC.WORK_CAT_ID
            WHERE
                PWC.WORK_CAT_ID = PW.WORK_CAT_ID
                <cfif isdefined('arguments.id') and len(arguments.id)>
                    AND PW.PROJECT_ID = #arguments.id#
                </cfif>
            GROUP BY 
                PWC.WORK_CAT
        </cfquery>
        <cfreturn get_work_cat>
    </cffunction>
    <cffunction name="project_time_cost" access="remote" returntype="query">
        <cfargument name="is_emp" default="1">
        <cfquery name="project_time_cost" datasource="#dsn#">
                SELECT 
                    SUM(TC.EXPENSED_MINUTE) EXPENSED_MINUTE
                    ,SUM(ISNULL(TC.EXPENSED_MONEY, 0)) EXPENSED_MONEY
                    <cfif arguments.is_emp eq 1>
                        ,TC.EMPLOYEE_ID
                        ,PP.EXPECTED_BUDGET AS PRO_EXPECTED_BUDGET
                    <cfelse>
                        ,TC.EMPLOYEE_ID
                        ,TC.COMMENT
                        ,TC.TIME_COST_STAGE
                    </cfif>
                    ,SUM(PW.ESTIMATED_TIME) AS ESTIMATED_TIME
                    ,SUM(ISNULL(PW.EXPECTED_BUDGET,0)) AS EXPECTED_BUDGET
                FROM 
                    TIME_COST TC
                    JOIN WORKGROUP_EMP_PAR WEP ON WEP.EMPLOYEE_ID = TC.EMPLOYEE_ID AND WEP.PROJECT_ID = TC.PROJECT_ID
                    JOIN PRO_WORKS PW ON PW.WORK_ID = TC.WORK_ID AND PW.PROJECT_ID = TC.PROJECT_ID
                    JOIN PRO_PROJECTS PP ON PP.PROJECT_ID = TC.PROJECT_ID AND PP.PROJECT_ID = PW.PROJECT_ID
                WHERE 1 = 1
                    
                    AND TC.PROJECT_ID = <cfqueryparam value = "#arguments.project_id#" CFSQLType = "cf_sql_integer">
                    AND TC.EVENT_DATE BETWEEN <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.start_date#">
                    AND <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.finish_date#">
                    AND TC.OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#">
                GROUP BY 
                <cfif arguments.is_emp eq 1> 
                    TC.EMPLOYEE_ID
                    ,PP.EXPECTED_BUDGET
                <cfelse>
                    TC.EMPLOYEE_ID
                    ,TC.COMMENT
                    ,TC.TIME_COST_STAGE
                </cfif>
                ORDER BY 
                <cfif arguments.is_emp eq 1>  EXPENSED_MONEY DESC <cfelse> 	TC.EMPLOYEE_ID </cfif>	
        </cfquery>
        <cfreturn project_time_cost>
    </cffunction>

    <cffunction name="AddProjectPre" access="public" returntype="struct" output="false">
        <cflock timeout="60" name="#CreateUUID()#">
             <cftransaction>
                 <cftry>
                     <cfquery name="UpdProjectPre" datasource="#dsn#">
                         UPDATE PRO_PROJECTS
                         SET PROJECT_PRESENTATION = <cfqueryparam cfsqltype="cf_sql_longnvarchar" value="#arguments.pro_preDetail#">
                         WHERE PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.project_id#">
                     </cfquery>
                     <cfset responseStruct.message = "#getLang('','İşlem Başarılı',61210)#">
                     <cfset responseStruct.status = true>
                     <cfset responseStruct.error = {}>
                     <cfset responseStruct.identity = arguments.project_id>
                     <cfcatch type="database">
                         <cftransaction action="rollback">
                         <cfset responseStruct.message = "#getLang('','İşlem Hatalı',65894)#">
                         <cfset responseStruct.status = false>
                         <cfset responseStruct.error = cfcatch>
                         <cfdump var="#cfcatch#" abort>
                     </cfcatch>
                 </cftry>
             </cftransaction>
         </cflock>
        <cfreturn responseStruct>
    </cffunction>
    <cffunction name="get_random_project_image" access="public" returntype="query">
        <cfquery name="randomImage" datasource="#dsn#">
            SELECT TOP 1 PRO_PROJECTS.IMG_PATH AS PATH, PROJECT_ID,project_head
            FROM PRO_PROJECTS
            WHERE 
                PRO_PROJECTS.IMG_PATH IS NOT NULL                    
                <cfif isDefined("arguments.UpperProject_Id") and len(arguments.UpperProject_Id)>
                    AND PRO_PROJECTS.PROJECT_ID IN (SELECT PROJECT_ID FROM PRO_PROJECTS AS P WHERE P.RELATED_PROJECT_ID IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.UpperProject_Id#" list="yes">) )
                <cfelse>
                    AND PRO_PROJECTS.RELATED_PROJECT_ID IS NOT NULL 
                </cfif>
                AND PROJECT_ID != <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pro_id#">
            ORDER BY NEWID()
        </cfquery>
        <cfreturn randomImage>
    </cffunction>
    <cffunction name="BudgetProject" access="public" returntype="any">
        <cfargument name="zero_data" default="1">
        <cfquery name="CHECK_TABLE" datasource="#dsn2_alias#">
            IF EXISTS (SELECT * FROM tempdb.sys.tables where name='####GET_EXPENSE_PROJECT_#session_base.userid#')
            DROP TABLE ####GET_EXPENSE_PROJECT_#session_base.userid#
        </cfquery>
        <cfquery name="GET_EXPENSE_ITEM" datasource="#dsn2_alias#">
            SELECT 
                PROJECT.PROJECT_ID,
                PROJECT.PROJECT_HEAD,
                EXPENSE_ITEM.EXPENSE_ITEM_ID,
                EXPENSE_ITEM.EXPENSE_ITEM_NAME,
                EXPENSE_ITEM.ACCOUNT_CODE,
                EXPENSE_ITEM.EXPENSE_CAT_NAME,
                EXPENSE_ITEM.EXPENSE_CAT_ID
            INTO ####GET_EXPENSE_PROJECT_#session_base.userid#
            FROM
            (
            SELECT 
                    PROJECT_ID,
                    PROJECT_HEAD
                FROM 
                    #dsn#.PRO_PROJECTS
                WHERE
                    PROJECT_STATUS = 1
                    <cfif len(arguments.project_id)>
                        AND PROJECT_ID IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.project_id#" list="yes">)
                    </cfif>
            ) AS PROJECT,
            (
                SELECT 
                    EXPENSE_ITEM_ID, 
                    EXPENSE_ITEM_NAME,
                    ACCOUNT_CODE,
                    EXPENSE_CATEGORY.EXPENSE_CAT_NAME,
                    EXPENSE_CATEGORY.EXPENSE_CAT_ID
                FROM 
                    EXPENSE_ITEMS,
                    EXPENSE_CATEGORY
                WHERE
                    EXPENSE_ITEMS.EXPENSE_CATEGORY_ID = EXPENSE_CATEGORY.EXPENSE_CAT_ID AND
                    EXPENSE_ITEM_ID IS NOT NULL
            ) AS EXPENSE_ITEM
        </cfquery>
        <cfquery name="GET_EXPENSE_BUDGET" datasource="#dsn2_alias#">
            WITH CTE1 AS(
            SELECT 
                    GEC.PROJECT_ID,
                    GEC.PROJECT_HEAD,
                    GEC.EXPENSE_ITEM_ID,
                    GEC.EXPENSE_ITEM_NAME,
                    GEC.ACCOUNT_CODE,
                    GEC.EXPENSE_CAT_NAME,
                    GEC.EXPENSE_CAT_ID,
                    GERCEKLESEN.MONEY_CURRENCY_ID,
                    ISNULL(ROW_TOTAL_INCOME,0) ROW_TOTAL_INCOME,
                   ISNULL( ROW_TOTAL_EXPENSE,0) ROW_TOTAL_EXPENSE,
                    ISNULL(ROW_TOTAL_INCOME_2,0) ROW_TOTAL_INCOME_2,
                   ISNULL( ROW_TOTAL_EXPENSE_2,0) ROW_TOTAL_EXPENSE_2,
                    ISNULL(TOTAL_AMOUNT_BORC,0) AS TOTAL_AMOUNT_BORC,
                       ISNULL(TOTAL_AMOUNT_ALACAK,0)  AS TOTAL_AMOUNT_ALACAK,
                    ISNULL(TOTAL_AMOUNT_2_BORC,0) AS TOTAL_AMOUNT_BORC_2,
                    ISNULL(TOTAL_AMOUNT_2_ALACAK,0) AS TOTAL_AMOUNT_ALACAK_2                    
            FROM
                ####GET_EXPENSE_PROJECT_#session_base.userid# AS GEC
            LEFT JOIN    
                (
                    SELECT 
                        ISNULL(SUM(BUDGET_PLAN_ROW.ROW_TOTAL_INCOME),0) ROW_TOTAL_INCOME,
                        ISNULL(SUM(BUDGET_PLAN_ROW.ROW_TOTAL_EXPENSE),0) ROW_TOTAL_EXPENSE,
                        ISNULL(SUM(BUDGET_PLAN_ROW.ROW_TOTAL_INCOME_2),0) ROW_TOTAL_INCOME_2,
                        ISNULL(SUM(BUDGET_PLAN_ROW.ROW_TOTAL_EXPENSE_2),0) ROW_TOTAL_EXPENSE_2,
                        BUDGET_PLAN_ROW.PROJECT_ID,
                        BUDGET_PLAN_ROW.BUDGET_ITEM_ID,
                        'TL' AS MONEY_CURRENCY_ID
                    FROM
                        #dsn#.BUDGET_PLAN,
                        #dsn#.BUDGET_PLAN_ROW 
                    WHERE 
                        BUDGET_PLAN.PROCESS_TYPE <> 161 AND 
                        BUDGET_PLAN.BUDGET_PLAN_ID = BUDGET_PLAN_ROW.BUDGET_PLAN_ID 
                        <cfif len(arguments.project_id)>
                            AND BUDGET_PLAN.PROJECT_ID IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.project_id#" list="yes">)
                        </cfif>
                    GROUP BY
                        BUDGET_PLAN_ROW.PROJECT_ID,
                        BUDGET_PLAN_ROW.BUDGET_ITEM_ID
                ) AS PLANLANAN
             ON
                 PLANLANAN.PROJECT_ID = GEC.PROJECT_ID AND PLANLANAN.BUDGET_ITEM_ID = GEC.EXPENSE_ITEM_ID
             LEFT JOIN
                 (
                    SELECT
                        SUM(CASE WHEN IS_INCOME = 0 THEN TOTAL_AMOUNT ELSE 0 END) AS  TOTAL_AMOUNT_BORC,
                        SUM(CASE WHEN IS_INCOME = 1 THEN TOTAL_AMOUNT ELSE 0 END) AS  TOTAL_AMOUNT_ALACAK,
                        SUM( CASE WHEN IS_INCOME = 0 THEN TOTAL_AMOUNT_2 ELSE 0 END) TOTAL_AMOUNT_2_BORC,
                        SUM( CASE WHEN IS_INCOME = 1 THEN TOTAL_AMOUNT_2 ELSE 0 END) TOTAL_AMOUNT_2_ALACAK,
                        PROJECT_ID,
                        EXPENSE_ITEM_ID,
                        MONEY_CURRENCY_ID
                    FROM
                    (
                        SELECT 
                            
                            (EXPENSE_ITEMS_ROWS.AMOUNT*ISNULL(QUANTITY,1)) TOTAL_AMOUNT,
                            CASE WHEN(OTHER_MONEY_VALUE_2 = 0) THEN 0 ELSE (EXPENSE_ITEMS_ROWS.AMOUNT/(TOTAL_AMOUNT/OTHER_MONEY_VALUE_2)*ISNULL(QUANTITY,1)) END AS TOTAL_AMOUNT_2,
                            EXPENSE_ITEMS_ROWS.PROJECT_ID,
                            EXPENSE_ITEMS_ROWS.IS_INCOME,
                            EXPENSE_ITEMS_ROWS.EXPENSE_ITEM_ID,
                            EXPENSE_ITEMS_ROWS.MONEY_CURRENCY_ID 
                        FROM
                            EXPENSE_ITEMS_ROWS
                        WHERE
                            TOTAL_AMOUNT > 0
                            <cfif len(arguments.project_id)>
                                AND EXPENSE_ITEMS_ROWS.PROJECT_ID IN(<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.project_id#" list="yes">)
                            </cfif>
                    )T1
                    GROUP BY
                        PROJECT_ID,
                        EXPENSE_ITEM_ID,
                        MONEY_CURRENCY_ID
                ) AS GERCEKLESEN  
             ON
                    GERCEKLESEN.PROJECT_ID =  GEC.PROJECT_ID AND GEC.EXPENSE_ITEM_ID = GERCEKLESEN.EXPENSE_ITEM_ID 
            WHERE 
                <cfif isDefined("arguments.zero_data")>
                    <cfif  isdefined("arguments.is_expense")>
                        TOTAL_AMOUNT_BORC > 0 AND
                    <cfelseif isdefined("arguments.is_income")>
                        TOTAL_AMOUNT_ALACAK > 0 AND
                    <cfelse>
                        (TOTAL_AMOUNT_BORC > 0 OR TOTAL_AMOUNT_ALACAK > 0) AND
                    </cfif>
                </cfif>
                (PLANLANAN.PROJECT_ID IS NOT NULL  OR GERCEKLESEN.PROJECT_ID IS NOT NULL)
                  
             ),
                 CTE2 AS (
                        SELECT
                            CTE1.*,
                                ROW_NUMBER() OVER (ORDER BY PROJECT_ID DESC)
                                AS RowNum,(SELECT COUNT(*) FROM CTE1) AS QUERY_COUNT
                        FROM
                            CTE1
                    )
                    SELECT
                        ( SELECT SUM(ROW_TOTAL_INCOME) FROM CTE2 ) ALL_ROW_TOTAL_INCOME,
                        ( SELECT SUM(ROW_TOTAL_EXPENSE) FROM CTE2 ) ALL_ROW_TOTAL_EXPENSE,
                        ( SELECT SUM(ROW_TOTAL_INCOME_2) FROM CTE2 ) ALL_ROW_TOTAL_INCOME_2,
                        ( SELECT SUM(ROW_TOTAL_EXPENSE_2) FROM CTE2 ) ALL_ROW_TOTAL_EXPENSE_2,
                        ( SELECT SUM(TOTAL_AMOUNT_BORC) FROM CTE2 ) ALL_TOTAL_AMOUNT_BORC,
                        ( SELECT SUM(TOTAL_AMOUNT_ALACAK) FROM CTE2 ) ALL_TOTAL_AMOUNT_ALACAK,
                        ( SELECT SUM(TOTAL_AMOUNT_BORC_2) FROM CTE2 ) ALL_TOTAL_AMOUNT_BORC_2,
                        ( SELECT SUM(TOTAL_AMOUNT_ALACAK_2) FROM CTE2 ) ALL_TOTAL_AMOUNT_ALACAK_2,
                        CTE2.*
                    FROM
                        CTE2  
        </cfquery>
        <cfreturn GET_EXPENSE_BUDGET>
    </cffunction>
</cfcomponent>