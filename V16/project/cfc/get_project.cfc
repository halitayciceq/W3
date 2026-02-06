<cfcomponent>
<cffunction name="get_projects_list_fnc" returntype="query">
	<cfargument name="keyword" default="">
    <cfargument name="consumer_id" default="">
    <cfargument name="currency" default="">
    <cfargument name="priority_cat" default="">
    <cfargument name="workgroup_id" default="">
	<cfargument name="pro_employee_id" default="">
	<cfargument name="company_id" default="">
    <cfargument name="company" default="">
	<cfargument name="start_date" default="">
	<cfargument name="finish_date" default="">
	<cfargument name="expense_code_name" default="">
    <cfargument name="expense_code" default="">
	<cfargument name="process_catid" default="">
	<cfargument name="ordertype" default="">
	<cfargument name="special_definition" default="">
    <cfargument name="pro_employee" default="">
    <cfargument name="ismyhome" default="">
	<cfargument name="my_projects" default="">
    <cfargument name="project_status" default="">
    <cfargument name="startrow" default="">
	<cfargument name="maxrows" default="">
	<cfargument  name="pro_partner_id" default="">
	<cfargument  name="pro_company_id" default="">
	<cfargument  name="project_id" default="">
    
	<cfquery name="get_projects" datasource="#this.dsn#">
		WITH CTE1 AS (
		SELECT 
			DISTINCT(PRO_PROJECTS.PROJECT_ID),
			PRO_PROJECTS.PROJECT_HEAD,
			PRO_PROJECTS.CONSUMER_ID,
			PRO_PROJECTS.COMPANY_ID,
			PRO_PROJECTS.PARTNER_ID,
			PRO_PROJECTS.PROJECT_EMP_ID,
			PRO_PROJECTS.OUTSRC_CMP_ID,
			PRO_PROJECTS.OUTSRC_PARTNER_ID,
			PRO_PROJECTS.TARGET_FINISH,
			PRO_PROJECTS.TARGET_START,
			PRO_PROJECTS.AGREEMENT_NO,
			PRO_PROJECTS.PRO_CURRENCY_ID,
			PRO_PROJECTS.EXPENSE_CODE,
			PRO_PROJECTS.PROCESS_CAT,
			PRO_PROJECTS.PROJECT_NUMBER,
			PRO_PROJECTS.PRODUCT_ID,
			PRO_PROJECTS.RELATED_PROJECT_ID,
            PRO_PROJECTS.PROJECT_STATUS,
			SETUP_PRIORITY.COLOR,
			SETUP_PRIORITY.PRIORITY,
            PRO_PROJECTS.COORDINATE_1,
            PRO_PROJECTS.COORDINATE_2,
			ISNULL((
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
			),0) COMPLETE_RATE,
                C.NICKNAME,
                CP.COMPANY_PARTNER_NAME,
                CP.COMPANY_PARTNER_SURNAME,
                C1.NICKNAME AS NICKNAME_OUTSRC,
                CP1.COMPANY_PARTNER_NAME AS COMPANY_PARTNER_NAME_OUTSRC ,
                CP1.COMPANY_PARTNER_SURNAME AS COMPANY_PARTNER_SURNAME_OUTSRC,
                CR.CONSUMER_NAME,
                CR.CONSUMER_SURNAME,
                E.EMPLOYEE_NAME,
                E.EMPLOYEE_SURNAME,
                PTR.STAGE,
                SMPC.MAIN_PROCESS_CAT,
				C.FULLNAME
		FROM 
			PRO_PROJECTS
        LEFT JOIN    
            COMPANY_PARTNER CP
        ON
        	CP.PARTNER_ID = PRO_PROJECTS.PARTNER_ID
        LEFT JOIN    
           	COMPANY C
        ON
        	C.COMPANY_ID = PRO_PROJECTS.COMPANY_ID     
        LEFT JOIN    
            COMPANY_PARTNER CP1
        ON
        	CP1.PARTNER_ID = PRO_PROJECTS.OUTSRC_PARTNER_ID
        LEFT JOIN
        	COMPANY C1
        ON
        	C1.COMPANY_ID = CP1.COMPANY_ID    
        LEFT JOIN
        	CONSUMER CR
        ON
        	CR.CONSUMER_ID = PRO_PROJECTS.CONSUMER_ID            		    
        LEFT JOIN
        	EMPLOYEES E
        ON    	   
          	E.EMPLOYEE_ID = PRO_PROJECTS.PROJECT_EMP_ID  
        LEFT JOIN
        	PROCESS_TYPE_ROWS PTR
        ON    
          	PTR.PROCESS_ROW_ID =  PRO_PROJECTS.PRO_CURRENCY_ID     
        LEFT JOIN
        	SETUP_MAIN_PROCESS_CAT SMPC
        ON
        	SMPC.MAIN_PROCESS_CAT_ID = PRO_PROJECTS.PROCESS_CAT
            ,SETUP_PRIORITY 
			<cfif len(KEYWORD)>
				,PRO_HISTORY
			</cfif>
		WHERE 
			<cfif len(company_id) and len(ismyhome)>
				(
				PRO_PROJECTS.OUTSRC_CMP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#company_id#"> OR
				PRO_PROJECTS.COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#company_id#">
				)
				AND
			</cfif>
			<!--- modified: MA 20120723   kişinin proje grubuna dahil olduğu YA DA gorevli oldugu projeleri listeler --->
			<cfif isdefined("my_projects") and my_projects eq 1>
				((SELECT TOP 1 WEP.EMPLOYEE_ID FROM WORKGROUP_EMP_PAR WEP WHERE WEP.EMPLOYEE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#"> AND PRO_PROJECTS.PROJECT_ID = WEP.PROJECT_ID) IS NOT NULL OR PRO_PROJECTS.PROJECT_EMP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#">)AND
			</cfif>
			<cfif len(consumer_id) and len(ismyhome)>
				PRO_PROJECTS.CONSUMER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#consumer_id#"> AND
			</cfif>
			PRO_PROJECTS.PRO_PRIORITY_ID=SETUP_PRIORITY.PRIORITY_ID
			<cfif len(keyword) gte 1>
				AND PRO_PROJECTS.PROJECT_ID = PRO_HISTORY.PROJECT_ID
				AND (
					PRO_PROJECTS.PROJECT_HEAD LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#keyword#%"> COLLATE SQL_Latin1_General_CP1_CI_AI OR
					PRO_PROJECTS.PROJECT_DETAIL LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#keyword#%"> COLLATE SQL_Latin1_General_CP1_CI_AI OR
					PRO_PROJECTS.AGREEMENT_NO LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#keyword#%"> COLLATE SQL_Latin1_General_CP1_CI_AI OR
					PRO_PROJECTS.PROJECT_NUMBER LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#keyword#%"> COLLATE SQL_Latin1_General_CP1_CI_AI
					)
			<cfelseif len(keyword) eq 1>
				AND PRO_PROJECTS.PROJECT_ID = PRO_HISTORY.PROJECT_ID
				AND PRO_PROJECTS.PROJECT_HEAD LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#keyword#%"> COLLATE SQL_Latin1_General_CP1_CI_AI
			</cfif>
			<cfif isdefined("arguments.project_id") and len(arguments.project_id)>
				AND PRO_PROJECTS.PROJECT_ID IN(<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.project_id#" list="yes">)
			</cfif>
			<cfif len(currency)>
				AND PRO_PROJECTS.PRO_CURRENCY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#currency#">
			</cfif>
			<cfif len(priority_cat)>
				AND PRO_PROJECTS.PRO_PRIORITY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#priority_cat#">
			</cfif>
			<cfif project_status EQ "1">
				AND PRO_PROJECTS.PROJECT_STATUS = 1
			<cfelseif project_status EQ "-1">
				AND PRO_PROJECTS.PROJECT_STATUS = 0 
			<cfelseif project_status EQ "0">
				AND (PRO_PROJECTS.PROJECT_STATUS  =0 OR PRO_PROJECTS.PROJECT_STATUS = 1)
			<cfelse><!--- default secim --->
				AND PRO_PROJECTS.PROJECT_STATUS = 1
			</cfif>
			<cfif isdefined("workgroup_id") and len(workgroup_id)>
				AND PRO_PROJECTS.WORKGROUP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#workgroup_id#">
			</cfif>
			<cfif isdefined("pro_employee_id") and len(pro_employee_id) and len(pro_employee) and not len(arguments.project_id)>
				AND PRO_PROJECTS.PROJECT_EMP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#pro_employee_id#">
			<cfelseif isDefined("pro_employee") and Len(pro_employee) and not len(arguments.project_id)>
				AND PRO_PROJECTS.PROJECT_EMP_ID IN (SELECT EMPLOYEE_ID FROM EMPLOYEES EE WHERE EE.EMPLOYEE_ID = PRO_PROJECTS.PROJECT_EMP_ID AND EE.EMPLOYEE_NAME + ' ' + EE.EMPLOYEE_SURNAME LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#pro_employee#%">)
			</cfif>
			<cfif isdefined("company_id") and  isdefined("company") and len(company) and len(company_id) and company_id neq 0>
				AND PRO_PROJECTS.COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#company_id#">
			</cfif>
			<cfif isdefined("arguments.pro_company_id") and len(arguments.pro_company_id)>
				AND OUTSRC_CMP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pro_company_id#">
			</cfif>
			<cfif isdefined("arguments.pro_partner_id") and len(arguments.pro_partner_id)>
				AND OUTSRC_PARTNER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pro_partner_id#">
			</cfif>
			<cfif isdefined("consumer_id")and  isdefined("company") and len(company) and len(consumer_id) and consumer_id neq 0>
				AND PRO_PROJECTS.CONSUMER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#consumer_id#">
			</cfif>
			<cfif isdefined("start_date") and len(start_date)>
				AND PRO_PROJECTS.TARGET_START >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#start_date#">
			</cfif>
			<cfif isdefined("finish_date") and len(finish_date)>
				AND PRO_PROJECTS.TARGET_FINISH < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#DATEADD('d',1,finish_date)#">
			</cfif>
			<cfif len(expense_code) and len(expense_code_name)>
				AND PRO_PROJECTS.EXPENSE_CODE LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#expense_code#">
			</cfif>
			<cfif isDefined("process_catid") and len(process_catid)>
				AND PRO_PROJECTS.PROCESS_CAT = <cfqueryparam cfsqltype="cf_sql_integer" value="#process_catid#">
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
						SMC.MAIN_PROCESS_CAT_ID = SMR.MAIN_PROCESS_CAT_ID AND
						EMPLOYEE_POSITIONS.POSITION_CODE = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.position_code#"> AND 
						(EMPLOYEE_POSITIONS.POSITION_CAT_ID=SMR.MAIN_POSITION_CAT_ID OR EMPLOYEE_POSITIONS.POSITION_CODE = SMR.MAIN_POSITION_CODE)
				)
			</cfif>
			<cfif len(special_definition)>
				AND PRO_PROJECTS.SPECIAL_DEFINITION_ID = #special_definition#
			</cfif>
			),
             CTE2 AS (
                    SELECT
                        CTE1.*,
                        ROW_NUMBER() OVER (	ORDER BY <cfif isdefined("ordertype") and ordertype eq 2>
				CASE WHEN ISNUMERIC(PROJECT_NUMBER) = 1 THEN 0 ELSE 1 END,
				CASE WHEN ISNUMERIC(PROJECT_NUMBER) = 1 THEN CAST(REPLACE(PROJECT_NUMBER,',','.') AS float) ELSE 0 END,
				PROJECT_NUMBER
			<cfelseif isdefined("ordertype") and ordertype eq 3>
				PROJECT_HEAD DESC
			<cfelseif isdefined("ordertype") and ordertype eq 4>
				PROJECT_HEAD
			<cfelseif isdefined("ordertype") and ordertype eq 5>
				TARGET_START DESC
			<cfelseif isdefined("ordertype") and ordertype eq 6>
				TARGET_START
			<cfelseif isdefined("ordertype") and ordertype eq 7>
				TARGET_FINISH DESC
			<cfelseif isdefined("ordertype") and ordertype eq 8>
				TARGET_FINISH	
			<cfelse>
				CASE WHEN ISNUMERIC(PROJECT_NUMBER) = 1 THEN 0 ELSE 1 END DESC,
				CASE WHEN ISNUMERIC(PROJECT_NUMBER) = 1 THEN CAST(REPLACE(PROJECT_NUMBER,',','.') AS float) ELSE 0 END DESC,
				PROJECT_NUMBER DESC
			</cfif> ) AS RowNum,(SELECT COUNT(*) FROM CTE1) AS QUERY_COUNT
                    FROM
                        CTE1
                )
                SELECT
                    CTE2.*
                FROM
                    CTE2
                WHERE
                    RowNum BETWEEN #startrow# and #startrow#+(#maxrows#-1)
	</cfquery>
	<cfreturn get_projects>
</cffunction>
</cfcomponent>

