<cfcomponent>
    <cfset dsn = application.systemParam.systemParam().dsn>
    <cfset dsn_alias = application.systemParam.systemParam().dsn>
    <cfset dsn2 = '#dsn#_#session.ep.period_year#_#session.ep.company_id#'>
    <cfset dsn2_alias = '#dsn#_#session.ep.period_year#_#session.ep.company_id#'>
    <cfset dsn3 = '#dsn#_#session.ep.company_id#'> 
    <cfset dsn3_alias = '#dsn#_#session.ep.company_id#'> 
    <cfset request.self = application.systemParam.systemParam().request.self />
    <cfset fusebox.process_tree_control = application.systemParam.systemParam().fusebox.process_tree_control>

    <cfset WFunctions = createObject("component","WMO.functions") />
    <cfset filterNum = WFunctions.filterNum>
    <cfset wrk_round = WFunctions.wrk_round>
    <cfset date_add = WFunctions.date_add>
    <cfset getlang = WFunctions.getlang>
    <cffunction name="GET_PRIORITY" returntype="any">
        <cfargument  name="priority_id" default="">
        <cfquery name="GET_PRIORITY" datasource="#dsn#">
            SELECT
                *
            FROM
                SETUP_PRIORITY
                <cfif isdefined('arguments.priority_id') and len(arguments.priority_id)>
            WHERE
                PRIORITY_ID=#arguments.priority_id#
                </cfif>
            ORDER BY
                PRIORITY_ID
        </cfquery> 
        <cfreturn GET_PRIORITY>
    </cffunction>
    <cffunction name="DET_PROJECT" access="remote">
      <cfargument name="id" default="">
      <cfargument name="PROJECT_NUMBER" default="">
      <cfargument name="PROJECT_STATUS" default=""> 
      <cfargument name="PROJECT_EMP_ID" default=""> 
      <cfargument name="PROJECT_HEAD" default=""> 
      <cfargument name="AGREEMENT_NO" default="">
      <cfargument name="PROJECT_DETAIL" default=""> 
      <cfargument name="TARGET_START" default="">
      <cfargument name="TARGET_FINISH" default=""> 
      <cfargument name="PRO_CURRENCY_ID" default=""> 
      <cfargument name="PRO_PRIORITY_ID" default="">
      <cfargument name="OUTSRC_CMP_ID" default=""> 
      <cfargument name="OUTSRC_PARTNER_ID" default=""> 
      <cfargument name="PROJECT_TARGET" default=""> 
      <cfargument name="EXPENSE_CODE" default="">
      <cfargument name="EXPECTED_BUDGET" default=""> 
      <cfargument name="EXPECTED_COST" default="">
      <cfargument name="BUDGET_CURRENCY" default=""> 
      <cfargument name="COST_CURRENCY" default=""> 
      <cfargument name="RECORD_DATE" default="">
      <cfargument name="RECORD_EMP" default=""> 
      <cfargument name="RECORD_PAR" default=""> 
      <cfargument name="RECORD_IP" default="">
      <cfargument name="UPDATE_DATE" default="">
      <cfargument name="UPDATE_EMP" default="">
      <cfargument name="UPDATE_PAR" default="">
      <cfargument name="UPDATE_IP" default=""> 
      <cfargument name="CAMPAIGN_ID" default=""> 
      <cfargument name="COMPANY_ID" default=""> 
      <cfargument name="CONSUMER_ID" default="">
      <cfargument name="PARTNER_ID" default="">
      <cfargument name="RELATED_PROJECT_ID" default=""> 
      <cfargument name="PROCESS_CAT" default=""> 
      <cfargument name="PROJECT_FOLDER" default="">
      <cfargument name="WORKGROUP_ID" default=""> 
      <cfargument name="PRODUCT_ID" default=""> 
      <cfargument name="DEPARTMENT_ID" default=""> 
      <cfargument name="COUNTRY_ID" default="">
      <cfargument name="SALES_ZONE_ID" default=""> 
      <cfargument name="LOCATION_ID" default=""> 
      <cfargument name="SPECIAL_DEFINITION_ID" default=""> 
      <cfargument name="CARGO_COMPANY_ID" default=""> 
      <cfargument name="DUTY_COMPANY_ID" default="">
      <cfargument name="INSURANCE_COMPANY_ID" default="">
      <cfargument name="TERM_DATE" default=""> 
      <cfargument name="ESTIMATED_OUT_DATE" default=""> 
      <cfargument name="ESTIMATED_ARRIVE_DATE" default=""> 
      <cfargument name="PROJECT_POS_CODE" default=""> 
      <cfargument name="COUNTY_ID" default=""> 
      <cfargument name="CITY_ID" default=""> 
      <cfargument name="COORDINATE_1" default=""> >
      <cfargument name="COORDINATE_2" default=""> 
        <cfargument name="PRO_H_START" default=""> 
       <cfargument name="PRO_H_FINISH" default="">
      <cfargument name="IS_SEND_WEBSERVICE" default="">
      <cfargument name="BRANCH_ID" default="">
      <cfdump  var="#arguments#">
      <cflock name="#CREATEUUID()#" timeout="20">
        <cftransaction>
        <cfquery name="UPDS_PROJECT"  datasource="#dsn#" result="result">
            UPDATE 
                PRO_PROJECTS
            SET 
                CONSUMER_ID = NULL,
                COMPANY_ID = NULL,
                PARTNER_ID = NULL,
                PROJECT_STATUS = <cfif isDefined("arguments.PROJECT_STATUS")>1<cfelse>0</cfif>,
            <cfif len(arguments.PROJECT_EMP_ID)>
                PROJECT_EMP_ID=#arguments.PROJECT_EMP_ID#,
                PROJECT_POS_CODE=<cfif len(arguments.PROJECT_POS_CODE)>#arguments.PROJECT_POS_CODE#<cfelse>NULL</cfif>,
                OUTSRC_CMP_ID=NULL,
                OUTSRC_PARTNER_ID=NULL,
            <cfelseif len(arguments.TASK_COMPANY_ID)>
                PROJECT_EMP_ID=NULL,
                PROJECT_POS_CODE=NULL,
                OUTSRC_CMP_ID=#arguments.TASK_COMPANY_ID#,
                OUTSRC_PARTNER_ID=<cfif len(arguments.TASK_PARTNER_ID)>#arguments.TASK_PARTNER_ID#,<cfelse>NULL,</cfif>
            </cfif>
                PROJECT_FOLDER= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.PROJECT_FOLDER#">,
                PROJECT_TARGET= <cfif len(arguments.PROJECT_TARGET)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.PROJECT_TARGET#">,<cfelse>NULL,</cfif>
                PROJECT_NUMBER=<cfif len(arguments.project_number)><cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.project_number)#"><cfelse>#arguments.id#</cfif>,
                RELATED_PROJECT_ID = <cfif len(arguments.RELATED_PROJECT_ID) and len(arguments.RELATED_PROJECT_HEAD)>#arguments.RELATED_PROJECT_ID#,<cfelse>NULL,</cfif>
                PROJECT_HEAD=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.PROJECT_HEAD#">,
                PROJECT_DETAIL=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.PROJECT_DETAIL#">,
                TARGET_START=#arguments.PRO_H_START#,
                TARGET_FINISH=#arguments.PRO_H_FINISH#,
                PRO_CURRENCY_ID=#arguments.process_stage#,
                PRO_PRIORITY_ID=#arguments.PRIORITY_CAT#,
                UPDATE_EMP=#SESSION.EP.USERID#,
                UPDATE_DATE = #now()#,
                UPDATE_IP = <cfqueryparam cfsqltype="cf_sql_varchar" value="#CGI.REMOTE_ADDR#">,
                PROCESS_CAT = <cfif isdefined("arguments.main_process_cat") and len(arguments.main_process_cat)>#arguments.main_process_cat#<cfelse>NULL</cfif>,
                EXPENSE_CODE =<cfif isdefined("arguments.EXPENSE_CODE") and len(arguments.EXPENSE_CODE) and len(arguments.EXPENSE_CODE_NAME)>#arguments.EXPENSE_CODE#<cfelse>NULL</cfif>,
                EXPECTED_BUDGET = <cfif isdefined("arguments.EXPECTED_BUDGET") and len(arguments.EXPECTED_BUDGET)>#arguments.EXPECTED_BUDGET#<cfelse>NULL</cfif>,
                EXPECTED_COST = <cfif isdefined("arguments.EXPECTED_COST") and len(arguments.EXPECTED_COST)>#arguments.EXPECTED_COST#<cfelse>NULL</cfif>,
                BUDGET_CURRENCY = <cfif isdefined("arguments.BUDGET_CURRENCY") and len(arguments.BUDGET_CURRENCY)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.BUDGET_CURRENCY#"><cfelse>NULL</cfif>,
                COST_CURRENCY = <cfif isdefined("arguments.COST_CURRENCY") and len(arguments.COST_CURRENCY)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.COST_CURRENCY#"><cfelse>NULL</cfif>,
                AGREEMENT_NO = <cfif isdefined("arguments.agreement_no") and len(arguments.agreement_no)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.agreement_no#"><cfelse>NULL</cfif>,
                WORKGROUP_ID = <cfif len(arguments.workgroup_id)>#arguments.workgroup_id#<cfelse>NULL</cfif>,
                PRODUCT_ID = <cfif isdefined('arguments.product_id') and len(arguments.product_id) and isdefined('arguments.product_name') and len(arguments.product_name)>#arguments.product_id#<cfelse>NULL</cfif>,
                BRANCH_ID = <cfif isdefined("arguments.branch_id") and len(arguments.branch_id)>#arguments.branch_id#<cfelse>NULL</cfif>,
                DEPARTMENT_ID = <cfif isdefined('arguments.department') and len(arguments.department)>#listfirst(arguments.department,'-')#<cfelse>NULL</cfif>,
                LOCATION_ID = <cfif isdefined('arguments.department') and len(arguments.department)>#listlast(arguments.department,'-')#<cfelse>NULL</cfif>,
                COUNTRY_ID = <cfif isdefined("arguments.country_id") and len(arguments.country_id)>#arguments.country_id#<cfelse>NULL</cfif>,
                SALES_ZONE_ID = <cfif isdefined("arguments.sales_zone_id") and len(arguments.sales_zone_id)>#arguments.sales_zone_id#<cfelse>NULL</cfif>,
                SPECIAL_DEFINITION_ID = <cfif isdefined("arguments.special_definition") and len(arguments.special_definition)>#arguments.special_definition#<cfelse>NULL</cfif>,
                CARGO_COMPANY_ID = <cfif isdefined("arguments.CARGO_COMPANY_ID") and len(arguments.CARGO_COMPANY)>#arguments.CARGO_COMPANY_ID#<cfelse>NULL</cfif>,
                DUTY_COMPANY_ID = <cfif isdefined("arguments.DUTY_COMPANY_ID") and len(arguments.DUTY_COMPANY)>#arguments.DUTY_COMPANY_ID#<cfelse>NULL</cfif>,
                INSURANCE_COMPANY_ID = <cfif isdefined("arguments.INSURANCE_COMPANY_ID") and len(arguments.INSURANCE_COMPANY)>#arguments.INSURANCE_COMPANY_ID#<cfelse>NULL</cfif>,
                TERM_DATE = <cfif isdefined("arguments.TERM_DATE") and len(arguments.TERM_DATE)>#arguments.TERM_DATE#<cfelse>NULL</cfif>,
                ESTIMATED_OUT_DATE = <cfif isdefined("arguments.ESTIMATED_OUT_DATE") and len(arguments.ESTIMATED_OUT_DATE)>#arguments.ESTIMATED_OUT_DATE#<cfelse>NULL</cfif>,
                ESTIMATED_ARRIVE_DATE = <cfif isdefined("arguments.ESTIMATED_ARRIVE_DATE") and len(arguments.ESTIMATED_ARRIVE_DATE)>#arguments.ESTIMATED_ARRIVE_DATE#<cfelse>NULL</cfif>,
                CITY_ID = <cfif isdefined("arguments.city_id") and len(arguments.city_id)>#arguments.city_id#<cfelse>NULL</cfif>,
                COUNTY_ID = <cfif isdefined("arguments.county_id") and len(arguments.county_id)>#arguments.county_id#<cfelse>NULL</cfif>,
                COORDINATE_1 = <cfif isdefined("arguments.coordinate_1") and len(arguments.coordinate_1)>#arguments.coordinate_1#<cfelse>NULL</cfif>,
                COORDINATE_2 = <cfif isdefined("arguments.coordinate_2") and len(arguments.coordinate_2)>#arguments.coordinate_2#<cfelse>NULL</cfif>
            WHERE 
                PROJECT_ID = #arguments.id# AND
                PRO_PRIORITY_ID=#arguments.priority_id#
            </cfquery>
            </cftransaction>
        </cflock> 
    </cffunction>
    <cffunction name="select" access="public">
        <cfargument name="id" default="">
        <cfquery name="get_project"  datasource="#DSN#">
            SELECT 
               PR.PROJECT_ID,
               PP2.PROJECT_ID AS RELATED_PROJECT_ID,
               PP2.PROJECT_HEAD AS RELATED_PROJECT_HEAD, 
               PR.PROJECT_NUMBER,
               PR.PROJECT_STATUS,
               PR.PROJECT_EMP_ID,
               PR.PROJECT_POS_CODE,
               PR.PROJECT_HEAD,
               PR.AGREEMENT_NO,
               PRO.PRODUCT_ID,
               PRO.PRODUCT_NAME,
               PR.PROJECT_DETAIL,
               PR.TARGET_START,
               PR.TARGET_FINISH,
               PR.PRO_CURRENCY_ID,
               CMP.FULLNAME,
               CMP.COMPANY_ID as cmp_company_id,
               PR.PRO_PRIORITY_ID,
               PR.OUTSRC_CMP_ID,
               PR.OUTSRC_PARTNER_ID,
               PR.PROJECT_TARGET,
               PR.EXPENSE_CODE,
               PR.EXPECTED_BUDGET,
               PR.EXPECTED_COST,
               PR.BUDGET_CURRENCY,
               PR.COST_CURRENCY,
               PR.RECORD_DATE,
               PR.RECORD_EMP,
               CMPRT.COMPANY_PARTNER_NAME,
               CMPRT.COMPANY_PARTNER_SURNAME,
               CMPRT.COMPANY_ID AS COMPANY_PARTNER_ID ,
               PR.RECORD_PAR,
               PR.RECORD_IP,
               STP.PRIORITY_ID,
               STP.PRIORITY,
               EMP.EMPLOYEE_ID,
               EMP.EMPLOYEE_NAME,
               EMP.EMPLOYEE_SURNAME,
               PR.UPDATE_DATE,
               PR.UPDATE_EMP,
               PR.UPDATE_PAR,
               PR.UPDATE_IP,
               PR.CAMPAIGN_ID,
               PR.COMPANY_ID,
               PR.CONSUMER_ID,
               CS.CONSUMER_ID,
               CS.CONSUMER_NAME,
               CS.CONSUMER_SURNAME,
               PR.PARTNER_ID,
               PR.RELATED_PROJECT_ID,
               PR.PROCESS_CAT,
               PR.PROJECT_FOLDER,
               PR.WORKGROUP_ID,
               PR.PRODUCT_ID,
               PR.BRANCH_ID,
               WG.WORKGROUP_ID,
               WG.WORKGROUP_NAME,
               PR.DEPARTMENT_ID,
               PR.COUNTRY_ID,
               PR.SALES_ZONE_ID,
               PR.LOCATION_ID,
               BR.BRANCH_ID,
               EXP.EXPENSE_CODE,
               EXP.EXPENSE ,
               BR.BRANCH_NAME,
               PR.SPECIAL_DEFINITION_ID,
               PR.CARGO_COMPANY_ID,
               PR.DUTY_COMPANY_ID,
               PR.INSURANCE_COMPANY_ID,
               PR.TERM_DATE,
               PR.ESTIMATED_OUT_DATE,
               PR.ESTIMATED_ARRIVE_DATE,
               PR.CITY_ID,
               PR.COUNTY_ID,
               PR.COORDINATE_1,
               PR.COORDINATE_2,
               PR.LANGUAGE_ID,
               PR.IS_STEPBYSTEP_IMP,
               PR.IMPLEMENTATION_STEP_IMPORTED
            FROM 
            PRO_PROJECTS AS PR
            LEFT JOIN COMPANY AS CMP ON CMP.COMPANY_ID = PR.COMPANY_ID
            LEFT JOIN BRANCH AS BR ON BR.BRANCH_ID = PR.BRANCH_ID
            LEFT JOIN EMPLOYEES AS EMP ON EMP.EMPLOYEE_ID = PR.PROJECT_EMP_ID
            LEFT JOIN COMPANY_PARTNER AS CMPRT ON CMPRT.PARTNER_ID = PR.PARTNER_ID
            LEFT JOIN #DSN2#.EXPENSE_CENTER AS EXP ON EXP.EXPENSE_CODE = PR.EXPENSE_CODE
            LEFT JOIN #DSN3#.PRODUCT AS PRO ON PRO.PRODUCT_ID = PR.PRODUCT_ID
            LEFT JOIN WORK_GROUP AS WG ON WG.WORKGROUP_ID = PR.WORKGROUP_ID
            LEFT JOIN CONSUMER AS CS ON CS.CONSUMER_ID = PR.CONSUMER_ID
            LEFT JOIN PRO_PROJECTS AS PP2 ON PP2.PROJECT_ID = PR.RELATED_PROJECT_ID
            LEFT JOIN SETUP_PRIORITY AS STP ON STP.PRIORITY_ID = PR.PRO_PRIORITY_ID
        WHERE 
                PR.PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
        </cfquery>
      
        <cfreturn get_project>
    </cffunction>
    <cffunction name="get" access="public">
        <cfargument  name="id" default="">
         <cfreturn select(id=arguments.id)> 
    </cffunction> 
    <cffunction name="GET_CITY" returntype="any">
        <cfquery name="GET_CITY" datasource="#DSN#">
            SELECT CITY_ID,CITY_NAME FROM SETUP_CITY 
        </cfquery>
        <cfreturn GET_CITY>
    </cffunction>
    <cffunction name="GET_SPECIAL_DEF" returntype="any">
        <cfquery name="GET_SPECIAL_DEF" datasource="#DSN#">
            SELECT SPECIAL_DEFINITION_ID,ISNULL(SPECIAL_DEFINITION,SPECIAL_DEFINITION_HEAD) AS SPECIAL_DEFINITION FROM SETUP_SPECIAL_DEFINITION WHERE SPECIAL_DEFINITION_TYPE = 6
        </cfquery>
     <cfreturn GET_SPECIAL_DEF>
    </cffunction>
    <cffunction name="GET_WORKGROUPS" returntype="any">
        <cfquery name="GET_WORKGROUPS" datasource="#DSN#">
            SELECT 
                WG.WORKGROUP_ID,
                WG.HIERARCHY,
                WG.WORKGROUP_NAME,
                WG.SUB_WORKGROUP,
                WG.OUR_COMPANY_ID,
                WG.MANAGER_EMP_ID,
                WG.DEPARTMENT_ID,
                WG.BRANCH_ID,
                WG.HEADQUARTERS_ID
            FROM
                WORK_GROUP WG
                where
                STATUS = 1 AND
                HIERARCHY IS NOT NULL
            ORDER BY 
                WORKGROUP_NAME
        </cfquery>
        <cfreturn GET_WORKGROUPS>
    </cffunction>
    <cffunction name="GET_ZONES" returntype="any">
        <cfquery name="GET_ZONES" datasource="#DSN#">
            SELECT SZ_ID,SZ_NAME FROM SALES_ZONES WHERE IS_ACTIVE = 1
        </cfquery>
        <cfreturn GET_ZONES>
    </cffunction>
    <cffunction name="GET_COUNTRY" returntype="any">
        <cfquery name="GET_COUNTRY" datasource="#DSN#">
            SELECT COUNTRY_ID,COUNTRY_NAME FROM SETUP_COUNTRY
        </cfquery>
     <cfreturn GET_COUNTRY>
    </cffunction>
    <cffunction name="PROJECT_DETAIL" access="public">
        <cfargument  name="id" default="">
        <cfquery name="PROJECT_DETAIL" datasource="#DSN#">
            SELECT 
                PRO_PROJECTS.*,
                SETUP_PRIORITY.PRIORITY,
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
                ) COMPLETE_RATE
            FROM 
                PRO_PROJECTS,		
                SETUP_PRIORITY
            WHERE
                <cfif isdefined("arguments.id")>
                PRO_PROJECTS.PROJECT_ID = #arguments.id# AND
                </cfif> 		
                PRO_PROJECTS.PRO_PRIORITY_ID = SETUP_PRIORITY.PRIORITY_ID 
        </cfquery>
    </cffunction>
    <cffunction name="GET_DEPARTMAN" access="public">
        <cfquery name="GET_DEPARTMAN" datasource="#DSN#">
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
            AND D.BRANCH_ID IN (SELECT BRANCH_ID FROM BRANCH WHERE COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#">)
        ORDER BY
            D.DEPARTMENT_HEAD,
            SL.COMMENT
        </cfquery>
        <cfreturn GET_DEPARTMAN>
    </cffunction>
    <cffunction name="get_branches_fnc" access="public" returnType="query">
		<cfargument name="is_comp_branch" required="no" type="numeric" default="1"> <!--- işlem yapılan şirkete bakılsın mı? --->
		<cfargument name="is_pos_branch" required="no" type="numeric" default="1"> <!--- kullanıcının şube yetkilerine bakılsın mı? --->
		<cfargument name="is_branch_status" required="no" type="numeric" default="1">
		<cfargument name="modul" required="no" type="string" default="">
		<cfif len(arguments.modul) and arguments.modul eq 'hr' and not get_module_power_user(67)>
			<cfset arguments.is_pos_branch = 1>
		</cfif>
		<cfquery name="get_branches_" datasource="#DSN#">
			SELECT
				BRANCH.BRANCH_STATUS,
				BRANCH.HIERARCHY,
				BRANCH.HIERARCHY2,
				BRANCH.BRANCH_ID,
				BRANCH.BRANCH_NAME,
				BRANCH.COMPANY_ID,
				BRANCH.SSK_OFFICE,
				BRANCH.SSK_NO,
				OUR_COMPANY.COMP_ID,
				OUR_COMPANY.COMPANY_NAME,
				OUR_COMPANY.NICK_NAME
			FROM
				BRANCH
				INNER JOIN OUR_COMPANY ON BRANCH.COMPANY_ID = OUR_COMPANY.COMP_ID
			WHERE
				BRANCH.BRANCH_ID IS NOT NULL
				<cfif len(arguments.is_branch_status) and arguments.is_branch_status eq 1>
					AND BRANCH.BRANCH_STATUS = 1 
				</cfif>
				<cfif isDefined('session.ep.userid') and arguments.is_comp_branch eq 1>
					AND BRANCH.COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#"> 
				<cfelseif isDefined('session.pda.our_company_id') and arguments.is_comp_branch eq 1>
					AND BRANCH.COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.pda.our_company_id#">                 
				</cfif>
				<cfif isDefined('session.ep.position_code') and arguments.is_pos_branch eq 1>
					AND BRANCH.BRANCH_ID IN (SELECT BRANCH_ID FROM EMPLOYEE_POSITION_BRANCHES WHERE POSITION_CODE = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.position_code#">)
				</cfif>
				<cfif isDefined('session.ep.isBranchAuthorization') and session.ep.isBranchAuthorization>
					AND BRANCH.BRANCH_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#listgetat(session.ep.user_location,2,'-')#">
				</cfif>
			ORDER BY
				OUR_COMPANY.NICK_NAME,
				BRANCH.BRANCH_NAME 
		</cfquery>
		<cfreturn get_branches_>
	</cffunction>
    <cffunction name="GET_CATS" returntype="any">
        <cfquery name="GET_CATS" datasource="#DSN#"><!--- project\cfc\get_work.cfc dosyasına taşındı--->
            SELECT
            #dsn#.Get_Dynamic_Language(SETUP_PRIORITY.PRIORITY_ID,'#session.ep.language#','SETUP_PRIORITY','PRIORITY',NULL,NULL,SETUP_PRIORITY.PRIORITY) AS priority,
            PRIORITY_ID
            FROM 
                SETUP_PRIORITY 
            ORDER BY
                PRIORITY
        </cfquery>
        
    </cffunction>
    <cffunction name="upd" access="public" returntype="any" hint="Project Upd Function">
        <cfset responseStruct = structNew()>
        <cfset attributes = arguments />
        <cf_date tarih="arguments.start">
        <cf_date tarih="arguments.finish">
        <cf_date tarih="arguments.term_date">
        <cf_date tarih="arguments.estimated_out_date">
        <cf_date tarih="arguments.estimated_arrive_date">
        <cfset arguments.pro_h_start = createdatetime(year(arguments.start),month(arguments.start),day(arguments.start),arguments.start_hour,arguments.start_minute,0)>
        <cfset arguments.pro_h_finish = createdatetime(year(arguments.finish),month(arguments.finish),day(arguments.finish),arguments.finish_hour,arguments.finish_minute,0)>

        <cfif isDefined("arguments.project_number") and len(arguments.project_number)>
            <cfquery name="GET_PROJECT_NUMBER" datasource="#dsn#">
                SELECT PROJECT_ID FROM PRO_PROJECTS WHERE PROJECT_ID <><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#"> AND PROJECT_NUMBER = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.project_number)#">
            </cfquery>
            <cfif get_project_number.recordcount gte 1>
                <cfsavecontent variable="message_"><cf_get_lang_main no='13.uyarı'>: Proje No <cf_get_lang_main no='781.tekrarı'>!</cfsavecontent>
                <cfset responseStruct.message = "#message_#">
                <cfset responseStruct.status = 0>
                <cfreturn responseStruct>
            </cfif>
        </cfif>
        
        <cfif isDefined('arguments.xml_pro_work_date') and arguments.xml_pro_work_date eq 1>
            <cfquery name="GET_PRO_WORKS" datasource="#DSN#">
                SELECT
                    WORK_ID
                FROM
                    PRO_WORKS
                WHERE
                    PROJECT_ID = #form.id# AND
                    (TARGET_START < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.pro_h_start#"> OR TARGET_FINISH >  <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.pro_h_finish#">)
            </cfquery>
            <cfif get_pro_works.recordcount>
                <cfsavecontent variable="message_2"><cf_get_lang no ='320.Proje Başlangıç Tarihi ile Bitiş Tarihi Dışında Kalan İş Kayıtları Var ! Ancak Güncelleme İşlemi Gerçekleştirilecektir'></cfsavecontent>
                <cfset responseStruct.message = "#message_2#">
                <cfset responseStruct.status = 0>
                <cfreturn responseStruct>
            </cfif>
        </cfif>
        
        <!--- durum, oncelik, lider ,bas. tarihi, bit. tarihi degisim oldumu history e yazılacak--->
        <cfquery name="GET_PRO_DETAIL" datasource="#DSN#">
            SELECT * FROM PRO_PROJECTS WHERE PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
        </cfquery>
        <cflock name="#CREATEUUID()#" timeout="20">
            <cftransaction>
                <cftry>
                    <cfquery name="UPDS_PROJECT" datasource="#dsn#">
                        UPDATE 
                            PRO_PROJECTS
                        SET 
                            COMPANY_ID = <cfif isdefined("arguments.COMPANY_ID") and len(arguments.COMPANY_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.COMPANY_ID#"><cfelse>NULL</cfif>,
                            PARTNER_ID = <cfif isdefined("arguments.PARTNER_ID") and len(arguments.PARTNER_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.PARTNER_ID#"><cfelse>NULL</cfif>,
                            PROJECT_NUMBER= <cfif isdefined("arguments.PROJECT_NUMBER") and len(arguments.PROJECT_NUMBER)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.PROJECT_NUMBER#"><cfelse>NULL</cfif>,
                            CONSUMER_ID = <cfif isdefined("arguments.CONSUMER_ID") and len(arguments.CONSUMER_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.CONSUMER_ID#"><cfelse>NULL</cfif>,
                            PROJECT_FOLDER= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.PROJECT_FOLDER#">,
                            PROJECT_STATUS = <cfif isDefined("arguments.PROJECT_STATUS")>1<cfelse>0</cfif>,
                            PROJECT_EMP_ID=<cfif isdefined("arguments.PROJECT_EMP_ID") and len(arguments.PROJECT_EMP_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.PROJECT_EMP_ID#"><cfelse>NULL</cfif>,
                            PROJECT_POS_CODE=<cfif isdefined("arguments.PROJECT_POS_CODE") and len(arguments.PROJECT_POS_CODE)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.PROJECT_POS_CODE#"><cfelse>NULL</cfif>,
                            OUTSRC_CMP_ID=<cfif isdefined("arguments.OUTSRC_CMP_ID") and len(arguments.OUTSRC_CMP_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.OUTSRC_CMP_ID#"><cfelse>NULL</cfif>,
                            OUTSRC_PARTNER_ID=<cfif isdefined("arguments.OUTSRC_PARTNER_ID") and len(arguments.OUTSRC_PARTNER_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.OUTSRC_PARTNER_ID#"><cfelse>NULL</cfif>,
                            PROJECT_TARGET= <cfif len(arguments.PROJECT_TARGET)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.PROJECT_TARGET#"><cfelse>NULL</cfif>,
                            RELATED_PROJECT_ID =<cfif len(arguments.RELATED_PROJECT_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.RELATED_PROJECT_ID#"><cfelse>NULL</cfif>,
                            PROJECT_HEAD=<cfif len(arguments.PROJECT_HEAD)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.PROJECT_HEAD#"><cfelse>NULL</cfif>,
                            PROJECT_DETAIL=<cfif len(arguments.PROJECT_DETAIL)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.PROJECT_DETAIL#"><cfelse>NULL</cfif>,
                            TARGET_START=<cfif len(arguments.PRO_H_START)><cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.pro_h_start#"><cfelse>NULL</cfif>,
                            TARGET_FINISH=<cfif len(arguments.PRO_H_FINISH)><cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.pro_h_finish#"><cfelse>NULL</cfif>,
                            PRO_CURRENCY_ID=<cfif len(arguments.process_stage)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.process_stage#"><cfelse>NULL</cfif>,
                            PRO_PRIORITY_ID=<cfif len(arguments.priority_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.priority_id#"><cfelse>NULL</cfif>,
                            UPDATE_DATE= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,    
                            UPDATE_EMP= <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#">,
                            UPDATE_IP=<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.remote_addr#">,
                            PROCESS_CAT = <cfif isdefined("arguments.main_process_cat") and len(arguments.main_process_cat)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.main_process_cat#"><cfelse>NULL</cfif>,
                            EXPENSE_CODE =<cfif isdefined("arguments.EXPENSE_CODE") and len(arguments.EXPENSE_CODE) ><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.EXPENSE_CODE#"><cfelse>NULL</cfif>,
                            EXPECTED_BUDGET = <cfif isdefined("arguments.EXPECTED_BUDGET") and len(arguments.EXPECTED_BUDGET)><cfqueryparam cfsqltype="cf_sql_float"  value ="#filterNum(arguments.EXPECTED_BUDGET,4)#"><cfelse>NULL</cfif>,
                            EXPECTED_COST = <cfif isdefined("arguments.EXPECTED_COST") and len(arguments.EXPECTED_COST)><cfqueryparam cfsqltype="cf_sql_float"  value ="#filterNum(arguments.EXPECTED_COST,4)#"><cfelse>NULL</cfif>,
                            BUDGET_CURRENCY = <cfif isdefined("arguments.BUDGET_CURRENCY") and len(arguments.BUDGET_CURRENCY)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.BUDGET_CURRENCY#"><cfelse>NULL</cfif>,
                            COST_CURRENCY = <cfif isdefined("arguments.COST_CURRENCY") and len(arguments.COST_CURRENCY)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.COST_CURRENCY#"><cfelse>NULL</cfif>,
                            AGREEMENT_NO = <cfif isdefined("arguments.agreement_no") and len(arguments.agreement_no)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.agreement_no#"><cfelse>NULL</cfif>,
                            WORKGROUP_ID = <cfif isdefined("arguments.workgroup_id") and len(arguments.workgroup_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.workgroup_id#"><cfelse>NULL</cfif>,
                            PRODUCT_ID = <cfif isdefined('arguments.product_id') and len(arguments.product_id) and isdefined('arguments.product_name') and len(arguments.product_name)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.product_id#"><cfelse>NULL</cfif>,
                            BRANCH_ID = <cfif isdefined("arguments.branch_id") and len(arguments.branch_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.branch_id#"><cfelse>NULL</cfif>,
                            DEPARTMENT_ID = <cfif len(arguments.location_id) and  len(arguments.department_id)>#listfirst(arguments.department_id,'-')#<cfelse>NULL</cfif>,
                            LOCATION_ID = <cfif len(arguments.department_id) and len(arguments.location_id)>#listlast(arguments.location_id,'-')#<cfelse>NULL</cfif>,
                            COUNTRY_ID = <cfif isdefined("arguments.country_id") and len(arguments.country_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.country_id#"><cfelse>NULL</cfif>,
                            SALES_ZONE_ID = <cfif isdefined("arguments.sales_zone_id") and len(arguments.sales_zone_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.sales_zone_id#"><cfelse>NULL</cfif>,
                            SPECIAL_DEFINITION_ID = <cfif isdefined("arguments.special_definition") and len(arguments.special_definition)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.special_definition#"><cfelse>NULL</cfif>,
                            CARGO_COMPANY_ID = <cfif isdefined("arguments.CARGO_COMPANY_ID") and len(arguments.CARGO_COMPANY)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.CARGO_COMPANY_id#"><cfelse>NULL</cfif>,
                            DUTY_COMPANY_ID = <cfif isdefined("arguments.DUTY_COMPANY_ID") and len(arguments.DUTY_COMPANY)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.DUTY_COMPANY_id#"><cfelse>NULL</cfif>,
                            INSURANCE_COMPANY_ID = <cfif isdefined("arguments.INSURANCE_COMPANY_ID") and len(arguments.INSURANCE_COMPANY)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.INSURANCE_COMPANY_id#"><cfelse>NULL</cfif>,
                            TERM_DATE = <cfif isdefined("arguments.TERM_DATE") and len(arguments.TERM_DATE)><cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.TERM_DATE#"><cfelse>NULL</cfif>,
                            ESTIMATED_OUT_DATE = <cfif isdefined("arguments.ESTIMATED_OUT_DATE") and len(arguments.ESTIMATED_OUT_DATE)><cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.ESTIMATED_OUT_DATE#"><cfelse>NULL</cfif>,
                            ESTIMATED_ARRIVE_DATE = <cfif isdefined("arguments.ESTIMATED_ARRIVE_DATE") and len(arguments.ESTIMATED_ARRIVE_DATE)><cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.ESTIMATED_ARRIVE_DATE#"><cfelse>NULL</cfif>,
                            CITY_ID = <cfif isdefined("arguments.city_id") and len(arguments.city_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.city_id#"><cfelse>NULL</cfif>,
                            COUNTY_ID = <cfif isdefined("arguments.county_id") and len(arguments.county_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.county_id#"><cfelse>NULL</cfif>,
                            COORDINATE_1 = <cfif isdefined("arguments.coordinate_1") and len(arguments.coordinate_1)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.coordinate_1#"><cfelse>NULL</cfif>,
                            COORDINATE_2 = <cfif isdefined("arguments.coordinate_2") and len(arguments.coordinate_2)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.coordinate_2#"><cfelse>NULL</cfif>,
                            LANGUAGE_ID = <cfif isdefined("arguments.dictionary_id") and len(arguments.dictionary_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.dictionary_id#"><cfelse>NULL</cfif>,
                            GOOGLE_PROJECT_FOLDER_ID = <cfif isdefined("arguments.projectFolderId") and len(arguments.projectFolderId)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.projectFolderId#"><cfelse>NULL</cfif>,
                            IS_STEPBYSTEP_IMP = <cfif isDefined("arguments.is_stepbystep_imp")>1<cfelse>0</cfif>
                        WHERE 
                            PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
                    </cfquery>
                
                    <cf_wrk_get_history  datasource='#DSN#' source_table= 'PRO_PROJECTS' target_table= 'PRO_HISTORY' record_id= '#arguments.id#' record_name='PROJECT_ID'>
                    <!--- Projeye ait cari degistigi an onceki cari ile iliskiyi kesmek gerekli. Analiz sonucu ve sonuc detayları direkt silinir. BK 20090112 --->
            
                    <cfquery name="DEL_ANALYSIS_RESULTS_DETAILS" datasource="#DSN#">
                        DELETE FROM MEMBER_ANALYSIS_RESULTS_DETAILS WHERE RESULT_ID IN (SELECT RESULT_ID FROM MEMBER_ANALYSIS_RESULTS WHERE PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">)
                    </cfquery>
                    <cfquery name="DEL_ANALYSIS_RESULTS_DETAILS" datasource="#DSN#">
                        DELETE FROM MEMBER_ANALYSIS_RESULTS WHERE PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
                    </cfquery>

                    <!---Ek Bilgiler--->
                    <cfset arguments.info_id =  arguments.id>
                    <cfset arguments.is_upd = 1>
                    <cfset arguments.info_type_id = -10>
                    <cfinclude template="../../objects/query/add_info_plus2.cfm">
                    <cfset arguments.project_id = arguments.id>
                    <!---Ek Bilgiler--->

                    <cf_workcube_process 
                        is_upd='1' 
                        old_process_line='#arguments.old_process_line#'
                        process_stage='#arguments.process_stage#' 
                        record_member='#session.ep.userid#' 
                        record_date='#now()#' 
                        action_table='PRO_PROJECTS'
                        action_column='PROJECT_ID'
                        action_id='#arguments.id#'
                        action_page='#request.self#?fuseaction=project.projects&event=upd&id=#arguments.id#'
                        warning_description = '#getLang('','Proje No',30886)# : #arguments.project_number#'>

                    <cfset responseStruct.message = "İşlem Başarılı">
                    <cfset responseStruct.status = true>
                    <cfset responseStruct.error = {}>
                    <cfset responseStruct.identity = arguments.id>
                <cfcatch type="database">
                    <cftransaction action="rollback">
                    <cfset responseStruct.message = "İşlem Hatalı">
                    <cfset responseStruct.status = false>
                    <cfset responseStruct.error = cfcatch>
                </cfcatch>
                </cftry>
             </cftransaction>
        </cflock>  
        <cfreturn responseStruct>
    </cffunction>
    <cffunction name="add" access="public" returntype="any" hint="Project Add Function">
        <cfset responseStruct = structNew()>
        <cfset attributes = arguments />

        <cfif isDefined("arguments.project_number") and len(arguments.project_number)>
            <cfquery name="GET_PROJECT_NUMBER" datasource="#dsn#">
                SELECT PROJECT_ID FROM PRO_PROJECTS WHERE  PROJECT_NUMBER = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.project_number)#">
            </cfquery>
            <cfif get_project_number.recordcount gte 1>
                <cfsavecontent variable="message_"><cf_get_lang_main no='13.uyarı'>: Proje No <cf_get_lang_main no='781.tekrarı'>!</cfsavecontent>
                <cfset responseStruct.message = "#message_#">
                <cfset responseStruct.status = 0>
                <cfreturn responseStruct>
            </cfif>
        </cfif>
        <cf_date tarih="arguments.pro_h_start">
        <cf_date tarih="arguments.pro_h_finish">
        
        <cfset arguments.expected_budget=filterNum(arguments.expected_budget)>
        <cfset arguments.expected_cost=filterNum(arguments.expected_cost)>
        <cfset arguments.pro_h_start = date_add("n",start_minute,date_add('h',arguments.START_HOUR, arguments.pro_h_start))>
        <cfset arguments.pro_h_finish = date_add("n",FINISH_minute,date_add('h',arguments.FINISH_HOUR, arguments.pro_h_finish))>
        
        <cflock name="#CREATEUUID()#" timeout="20">
            <cftransaction>
                <cftry>
                    <cfquery name="ADD_PROJECT" datasource="#dsn#" result="PRO_ID">
                        INSERT INTO 
                            PRO_PROJECTS
                        (
                        <cfif len(arguments.company_id) and len(arguments.partner_id)>
                            COMPANY_ID,
                            PARTNER_ID,
                        <cfelseif not len(arguments.company_id) and len(arguments.consumer_id)>
                            CONSUMER_ID,
                        </cfif>
                        <cfif len(arguments.project_emp_id)>
                            PROJECT_EMP_ID,		
                            PROJECT_POS_CODE,
                        <cfelseif len(arguments.TASK_COMPANY_ID)>
                            OUTSRC_CMP_ID,
                            OUTSRC_PARTNER_ID,
                        </cfif>
                            PROJECT_HEAD,
                            PROJECT_DETAIL,
                            TARGET_START,
                            TARGET_FINISH,
                            PRO_CURRENCY_ID,
                            PRO_PRIORITY_ID,
                            RECORD_DATE,
                            RECORD_EMP,
                            RECORD_IP,
                            EXPENSE_CODE,
                        <cfif len(arguments.EXPECTED_BUDGET)>
                            EXPECTED_BUDGET,
                        </cfif>
                        <cfif len(arguments.EXPECTED_COST)>
                            EXPECTED_COST,
                        </cfif>
                        <cfif len(arguments.BUDGET_CURRENCY)>BUDGET_CURRENCY,</cfif>
                        <cfif len(arguments.COST_CURRENCY)>COST_CURRENCY,</cfif>	
                            PROJECT_TARGET,
                            RELATED_PROJECT_ID,
                            PROJECT_STATUS,
                            PROCESS_CAT,
                            PROJECT_FOLDER,
                            AGREEMENT_NO,
                            WORKGROUP_ID,
                            PRODUCT_ID,
                            BRANCH_ID,
                            DEPARTMENT_ID,
                            LOCATION_ID,
                            COUNTRY_ID,
                            SALES_ZONE_ID,
                            SPECIAL_DEFINITION_ID,
                            CITY_ID,
                            COUNTY_ID,
                            COORDINATE_1,
                            COORDINATE_2,
                            LANGUAGE_ID,
                            GOOGLE_PROJECT_FOLDER_ID
                        )
                        VALUES
                        (
                            <cfif len(arguments.company_id) and len(arguments.partner_id)>
                                <cfif isdefined("arguments.COMPANY_ID")><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.COMPANY_ID#">,<cfelse>NULL,</cfif>
                                <cfif isdefined("arguments.PARTNER_ID")><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.PARTNER_ID#">,<cfelse>NULL,</cfif>
                            <cfelseif not len(arguments.company_id) and len(arguments.consumer_id)>
                                <cfif isdefined("arguments.CONSUMER_ID")><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CONSUMER_ID#">,<cfelse>NULL,</cfif>
                            </cfif>
                            <cfif isdefined('arguments.project_emp_id') and len(arguments.project_emp_id)>
                                <cfif isdefined("arguments.PROJECT_EMP_ID")><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.PROJECT_EMP_ID#">,<cfelse>NULL,</cfif>
                                <cfif isdefined("arguments.PROJECT_POS_CODE")><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.PROJECT_POS_CODE#">,<cfelse>NULL,</cfif>
                            <cfelseif len(arguments.TASK_COMPANY_ID)>
                                <cfif isdefined("arguments.TASK_COMPANY_ID")><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.TASK_COMPANY_ID#">,<cfelse>NULL,</cfif>
                                <cfif isdefined("arguments.TASK_PARTNER_ID")><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.TASK_PARTNER_ID#">,<cfelse>NULL,</cfif>
                            </cfif>
                                <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.PROJECT_HEAD#">,
                                <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.PROJECT_DETAIL#">,
                                <cfif len(arguments.PRO_H_START)>#arguments.PRO_H_START#<cfelse>NULL</cfif>,
                                <cfif len(arguments.PRO_H_FINISH)>#arguments.PRO_H_FINISH#<cfelse>NULL</cfif>,
                                #arguments.process_stage#,
                                #arguments.PRIORITY_CAT#,
                                #NOW()#,
                                #SESSION.EP.USERID#,
                                <cfqueryparam cfsqltype="cf_sql_varchar" value="#CGI.REMOTE_ADDR#">,
                                <cfqueryparam cfsqltype="cf_sql_varchar" value="#EXPENSE_CODE#">,
                            <cfif len(arguments.expected_budget)>
                                #arguments.expected_budget#,
                            </cfif>
                            <cfif len(arguments.expected_cost)>
                                #arguments.expected_cost#,
                            </cfif>
                            <cfif len(arguments.BUDGET_CURRENCY)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.BUDGET_CURRENCY#">,</cfif>
                            <cfif len(arguments.COST_CURRENCY)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.COST_CURRENCY#">,</cfif>
                                <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.PROJECT_TARGET#">,
                            <cfif len(arguments.RELATED_PROJECT_ID)>#arguments.RELATED_PROJECT_ID#,<CFELSE>NULL,</cfif>
                                1,
                                #arguments.main_process_cat#,
                                <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.project_folder#">,
                                <cfif isdefined("arguments.agreement_no")><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.agreement_no#">,<cfelse>NULL,</cfif>
                                <cfif isdefined("arguments.workgroup_id") and len(arguments.workgroup_id)>#arguments.workgroup_id#<cfelse>NULL</cfif>,
                                <cfif isdefined("arguments.product_id") and len(arguments.product_id)>#arguments.product_id#<cfelse>NULL</cfif>,
                                <cfif isdefined("arguments.branch_id") and len(arguments.branch_id)>#arguments.branch_id#<cfelse>NULL</cfif>,
                                <cfif len(arguments.location_id) and  len(arguments.department_id)>#listfirst(arguments.department_id,'-')#<cfelse>NULL</cfif>,
                                <cfif len(arguments.department_id) and len(arguments.location_id)>#listlast(arguments.location_id,'-')#<cfelse>NULL</cfif>,
                                <cfif isdefined("arguments.country_id") and len(arguments.country_id)>#arguments.country_id#<cfelse>NULL</cfif>,
                                <cfif isdefined("arguments.sales_zone_id") and len(arguments.sales_zone_id)>#arguments.sales_zone_id#<cfelse>NULL</cfif>,
                                <cfif isdefined("arguments.special_definition") and len(arguments.special_definition)>#arguments.special_definition#<cfelse>NULL</cfif>,
                                <cfif isdefined("arguments.city_id") and len(arguments.city_id)>#arguments.city_id#<cfelse>NULL</cfif>,
                                <cfif isdefined("arguments.county_id") and len(arguments.county_id)>#arguments.county_id#<cfelse>NULL</cfif>,
                                <cfif isdefined("arguments.coordinate_1") and len(arguments.coordinate_1)>'#arguments.coordinate_1#'<cfelse>NULL</cfif>,
                                <cfif isdefined("arguments.coordinate_2") and len(arguments.coordinate_2)>'#arguments.coordinate_2#'<cfelse>NULL</cfif>,
                                <cfif isdefined("arguments.dictionary_id") and len(arguments.dictionary_id)>'#arguments.dictionary_id#'<cfelse>NULL</cfif>,
                                <cfif isdefined("arguments.projectFolderId") and len(arguments.projectFolderId)>'#arguments.projectFolderId#'<cfelse>NULL</cfif>
                                
                            )
                    </cfquery>
                    <cfquery name="GET_LAST_PRO" datasource="#dsn#">
                        SELECT MAX(PROJECT_ID) AS PRO_ID FROM PRO_PROJECTS
                    </cfquery>
                    <cfquery name="ADD_PROJECT_TO_HISTORY" datasource="#dsn#">
                        INSERT INTO 
                            PRO_HISTORY
                            (
                            <cfif len(arguments.company_id) and len(arguments.partner_id)>
                                COMPANY_ID,
                                PARTNER_ID,
                            <cfelseif not len(arguments.company_id) and len(arguments.consumer_id)>
                                CONSUMER_ID,
                            </cfif>	
                                PROJECT_ID,
                                UPDATE_DATE,
                            <cfif len(arguments.project_emp_id)>
                                PROJECT_EMP_ID,	
                                PROJECT_POS_CODE,
                            <cfelseif len(arguments.TASK_COMPANY_ID)>
                                OUTSRC_CMP_ID,
                                OUTSRC_PARTNER_ID,
                            </cfif>
                                TARGET_START,
                                TARGET_FINISH,
                                PRO_CURRENCY_ID,
                                PRO_PRIORITY_ID,
                                UPDATE_AUTHOR,
                                AGREEMENT_NO,
                                BRANCH_ID,
                                DEPARTMENT_ID,
                                LOCATION_ID,
                                COUNTRY_ID,
                                SALES_ZONE_ID,
                                SPECIAL_DEFINITION_ID,
                                PROJECT_STATUS              
                            )
                        VALUES
                            (
                            <cfif len(arguments.company_id) and len(arguments.partner_id)>
                                <cfif isdefined("arguments.COMPANY_ID")><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.COMPANY_ID#">,<cfelse>NULL,</cfif>
                                <cfif isdefined("arguments.PARTNER_ID")><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.PARTNER_ID#">,<cfelse>NULL,</cfif>
                            <cfelseif not len(arguments.company_id) and len(arguments.consumer_id)>
                                <cfif isdefined("arguments.CONSUMER_ID")><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CONSUMER_ID#">,<cfelse>NULL,</cfif>
                            </cfif>
                                #get_last_pro.pro_id#,
                                #now()#,
                            <cfif isdefined('arguments.project_emp_id') and len(arguments.project_emp_id)>
                                <cfif isdefined("arguments.PROJECT_EMP_ID")><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.PROJECT_EMP_ID#">,<cfelse>NULL,</cfif>					
                                <cfif isdefined("arguments.PROJECT_POS_CODE")><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.PROJECT_POS_CODE#">,<cfelse>NULL,</cfif>
                            <cfelseif len(arguments.TASK_COMPANY_ID)>
                                <cfif isdefined("arguments.TASK_COMPANY_ID")><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.TASK_COMPANY_ID#">,<cfelse>NULL,</cfif>
                                <cfif isdefined("arguments.TASK_PARTNER_ID")><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.TASK_PARTNER_ID#">,<cfelse>NULL,</cfif>
                            </cfif>
                                #arguments.PRO_H_START#,
                                #arguments.PRO_H_FINISH#,
                                #arguments.process_stage#,
                                #arguments.PRIORITY_CAT#,
                                #SESSION.EP.USERID#,
                                <cfif isdefined("arguments.agreement_no")><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.agreement_no#"><cfelse>NULL</cfif>,
                                <cfif isdefined("arguments.branch_id") and len(arguments.branch_id)>#arguments.branch_id#<cfelse>NULL</cfif>,
                                <cfif len(arguments.location_id) and  len(arguments.department_id)>#listfirst(arguments.department_id,'-')#<cfelse>NULL</cfif>,
                                <cfif len(arguments.department_id) and len(arguments.location_id)>#listlast(arguments.location_id,'-')#<cfelse>NULL</cfif>,
                                <cfif isdefined("arguments.country_id") and len(arguments.country_id)>#arguments.country_id#<cfelse>NULL</cfif>,
                                <cfif isdefined("arguments.sales_zone_id") and len(arguments.sales_zone_id)>#arguments.sales_zone_id#<cfelse>NULL</cfif>,
                                <cfif isdefined("arguments.special_definition") and len(arguments.special_definition)>#arguments.special_definition#<cfelse>NULL</cfif>,
                                1
                            )
                    </cfquery>
                    <cfif isdefined("arguments.opp_id") and len(arguments.opp_id)><!--- firsattan geliyor ise firsatla baglanacak --->
                        <cfquery name="add_opp" datasource="#dsn#">
                            UPDATE
                                #dsn3_alias#.OPPORTUNITIES
                            SET
                                PROJECT_ID = #get_last_pro.pro_id#
                            WHERE
                                OPP_ID = #arguments.opp_id#
                        </cfquery>
                    </cfif>

                    <!---Ek Bilgiler--->
                    <cfset attributes.info_id = PRO_ID.IDENTITYCOL>
                    <cfset attributes.is_upd = 0>
                    <cfset attributes.info_type_id = -10>
                    <cfinclude template="../../objects/query/add_info_plus2.cfm">
                    <!---Ek Bilgiler--->
                    <cfquery name="UPD_PROJECT_NUMBER" datasource="#DSN#">
                        UPDATE 
                            PRO_PROJECTS 
                        SET		
                        <cfif isdefined("arguments.project_number") and len(arguments.project_number)>
                            PROJECT_NUMBER=<cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.project_number)#">
                        <cfelse>
                            PROJECT_NUMBER = <cfqueryparam cfsqltype="cf_sql_varchar" value="#get_last_pro.pro_id#">
                        </cfif>
                        WHERE 
                            PROJECT_ID = #get_last_pro.pro_id#
                    </cfquery>
                    <cfset arguments.project_id = get_last_pro.pro_id>
                    <cf_workcube_process 
                            is_upd='1' 
                            old_process_line='0'
                            process_stage='#arguments.process_stage#' 
                            record_member='#session.ep.userid#' 
                            record_date='#now()#'
                            action_table='PRO_PROJECTS'
                            action_column='PROJECT_ID'
                            action_id='#get_last_pro.pro_id#'
                            action_page='#request.self#?fuseaction=project.projects&event=det&id=#get_last_pro.pro_id#'
                            warning_description = '#getLang('','Proje No',30886)# : #arguments.project_number#'>

                    <cfset responseStruct.message = "İşlem Başarılı">
                    <cfset responseStruct.status = true>
                    <cfset responseStruct.error = {}>
                    <cfset responseStruct.identity = get_last_pro.pro_id>
                <cfcatch type="database">
                    <cftransaction action="rollback">
                    <cfset responseStruct.message = "İşlem Hatalı">
                    <cfset responseStruct.status = false>
                    <cfset responseStruct.error = cfcatch>
                </cfcatch>
                </cftry>
            </cftransaction>
        </cflock>
        <cfreturn responseStruct>
    </cffunction>
    <cffunction name="del" access="public" returntype="any" hint="Project Del Function">
        <cfargument name="id" required="true">
        <cfset fusebox.circuit = listFirst(arguments.fuseaction,'.')>
        <cfset fusebox.fuseaction = listLast(arguments.fuseaction,'.')>
        <cfset responseStruct = structNew()>
        <cflock name="#CreateUUID()#" timeout="60">
            <cftransaction>
                <cftry>
                    <cfquery name="GET_PROJECT" datasource="#DSN#">
                        SELECT PROJECT_HEAD,PRO_CURRENCY_ID,PROJECT_NUMBER FROM PRO_PROJECTS WHERE PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
                    </cfquery>
                    <cfquery name="DEL_WORK_HISTORY" datasource="#DSN#">
                        DELETE FROM PRO_WORKS_HISTORY WHERE WORK_ID IN (SELECT WORK_ID FROM PRO_WORKS WHERE PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">)
                    </cfquery>
                    <cfquery name="DEL_WORK_CC" datasource="#dsn#">
                        DELETE FROM PRO_WORKS_CC WHERE WORK_ID IN (SELECT WORK_ID FROM PRO_WORKS WHERE PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">)
                    </cfquery>
                    <cfquery name="DEL_PRO_WORKS" datasource="#DSN#">
                        DELETE FROM PRO_WORKS WHERE PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
                    </cfquery>
                    <cfquery name="DEL_WORKGROUP_EMP_PAR" datasource="#DSN#">
                        DELETE FROM WORKGROUP_EMP_PAR WHERE PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
                    </cfquery>
                    <cfquery name="DEL_WORK_GROUP" datasource="#DSN#">
                        DELETE FROM WORK_GROUP WHERE PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
                    </cfquery>
                    <cfquery name="DEL_PRO_HISTORY" datasource="#DSN#">
                        DELETE FROM PRO_HISTORY WHERE PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
                    </cfquery>
                    <!--- İliskili Butceler Tablosundan İlgili Projeye Ait Kayitlar Siliniyor --->
                    <cfquery name="DEL_RELATED_BUDGET" datasource="#DSN#">
                        DELETE FROM PRO_RELATED_BUDGET WHERE PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
                    </cfquery>
                    <!--- Firsata bagli proje silindiginde fırsat kaydındaki proje_id alani guncelleniyor --->
                    <cfif isdefined("arguments.opp_id") and len(arguments.opp_id)>
                        <cfquery name="upd_opportunities" datasource="#dsn#">
                            UPDATE #dsn3_alias#.OPPORTUNITIES SET PROJECT_ID = NULL WHERE OPP_ID = #arguments.opp_id#
                        </cfquery> 
                    </cfif>
                    <!--- Projenin Muhasebe Tanimlari siliniyor --->
                    <cfquery name="get_our_comp" datasource="#dsn#">
                        SELECT COMP_ID FROM OUR_COMPANY
                    </cfquery>
                    <cfloop query="get_our_comp">
                        <cfquery name="Del_Project_Period" datasource="#dsn#">
                            DELETE FROM #dsn#_#get_our_comp.comp_id#.PROJECT_PERIOD WHERE PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
                        </cfquery>
                    </cfloop>
                    <!--- //Projenin Muhasebe Tanimlari siliniyor --->
                    <!--- Proje ile iliskili Analiz sonuclarini sil  --->
                    <cfquery name="DEL_ANALYSIS_RESULTS_DETAILS" datasource="#DSN#">
                        DELETE FROM MEMBER_ANALYSIS_RESULTS_DETAILS WHERE RESULT_ID IN (SELECT RESULT_ID FROM MEMBER_ANALYSIS_RESULTS WHERE PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">)
                    </cfquery>
                    <cfquery name="DEL_ANALYSIS_RESULTS_DETAILS" datasource="#DSN#">
                        DELETE FROM MEMBER_ANALYSIS_RESULTS WHERE PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
                    </cfquery>
                    <cfquery name="DEL_PRO_PROJECTS" datasource="#DSN#">
                        DELETE FROM PRO_PROJECTS WHERE PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
                    </cfquery>
                    <cfset attributes.action_section = "PROJECT_ID">
                    <cfset attributes.action_id = arguments.id>
                    <cfinclude template="../../objects/query/del_assets.cfm">
                    <cf_add_log log_type="-1" action_id="#arguments.id#" action_name="#get_project.project_head#" paper_no="#get_project.project_number#" process_stage="#get_project.pro_currency_id#">
                    <cfset responseStruct.message = "İşlem Başarılı">
                    <cfset responseStruct.status = true>
                    <cfset responseStruct.error = {}>
                    <cfset responseStruct.identity = ''>
                    <cfcatch type="database">
                        <cftransaction action="rollback">
                        <cfset responseStruct.message = "İşlem Hatalı">
                        <cfset responseStruct.status = false>
                        <cfset responseStruct.error = cfcatch>
                    </cfcatch>
                </cftry>
            </cftransaction>
        </cflock>
        <cfreturn responseStruct>
    </cffunction>
 </cfcomponent>