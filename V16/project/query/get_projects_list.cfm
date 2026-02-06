<cfquery name="get_projects" datasource="#dsn#">
	SELECT * FROM
	(
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
		SETUP_PRIORITY.COLOR,
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
		<cfif len(attributes.KEYWORD)>
			,PRO_HISTORY
		</cfif>
	WHERE 
		<cfif isDefined("attributes.company_id") and isDefined("ismyhome")>
			(
			PRO_PROJECTS.OUTSRC_CMP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.company_id#"> OR
			PRO_PROJECTS.COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.company_id#">
			)
			AND
		</cfif>
		<cfif isDefined("attributes.consumer_id") and isDefined("ismyhome")>
			PRO_PROJECTS.CONSUMER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.consumer_id#"> AND
		</cfif>
		PRO_PROJECTS.PRO_PRIORITY_ID=SETUP_PRIORITY.PRIORITY_ID
		<cfif len(attributes.KEYWORD) gte 1>
			AND PRO_PROJECTS.PROJECT_ID = PRO_HISTORY.PROJECT_ID
			AND (
				PRO_PROJECTS.PROJECT_HEAD LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.keyword#%"> OR
				PRO_PROJECTS.PROJECT_DETAIL LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.keyword#%"> OR
				PRO_PROJECTS.AGREEMENT_NO = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.keyword#"> OR
				PRO_PROJECTS.PROJECT_NUMBER LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.keyword#%">
				)
		<cfelseif len(attributes.keyword) eq 1>
			AND PRO_PROJECTS.PROJECT_ID = PRO_HISTORY.PROJECT_ID
			AND PRO_PROJECTS.PROJECT_HEAD LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.keyword#%">
		</cfif>
		<cfif len(attributes.currency)>
			AND PRO_PROJECTS.PRO_CURRENCY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.currency#">
		</cfif>
		<cfif len(attributes.priority_cat)>
			AND PRO_PROJECTS.PRO_PRIORITY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.priority_cat#">
		</cfif>
		<cfif attributes.project_status EQ "1">
			AND PRO_PROJECTS.PROJECT_STATUS = 1
		<cfelseif attributes.project_status EQ "-1">
			AND PRO_PROJECTS.PROJECT_STATUS = 0 
		<cfelseif attributes.project_status EQ "0">
			AND (PRO_PROJECTS.PROJECT_STATUS  =0 OR PRO_PROJECTS.PROJECT_STATUS = 1)
		<cfelse><!--- default secim --->
			AND PRO_PROJECTS.PROJECT_STATUS = 1
		</cfif>
		<cfif isdefined("attributes.workgroup_id") and len(attributes.workgroup_id)>
			AND PRO_PROJECTS.WORKGROUP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.workgroup_id#">
		</cfif>
		<cfif isdefined("attributes.pro_employee_id") and len(attributes.pro_employee_id) and len(attributes.pro_employee)>
			AND PRO_PROJECTS.PROJECT_EMP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.pro_employee_id#">
		<cfelseif isDefined("attributes.pro_employee") and Len(attributes.pro_employee)>
			AND PRO_PROJECTS.PROJECT_EMP_ID IN (SELECT EMPLOYEE_ID FROM EMPLOYEES EE WHERE EE.EMPLOYEE_ID = PRO_PROJECTS.PROJECT_EMP_ID AND EE.EMPLOYEE_NAME + ' ' + EE.EMPLOYEE_SURNAME LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.pro_employee#%">)
		</cfif>
		<cfif isdefined("attributes.company_id") and  isdefined("attributes.company") and len(attributes.company) and len(attributes.company_id) and attributes.company_id neq 0>
			AND PRO_PROJECTS.COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.company_id#">
		</cfif>
		<cfif isdefined("attributes.consumer_id")and  isdefined("attributes.company") and len(attributes.company) and len(attributes.consumer_id) and attributes.consumer_id neq 0>
			AND PRO_PROJECTS.CONSUMER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.consumer_id#">
		</cfif>
		<cfif isdefined("attributes.start_date") and len(attributes.start_date)>
			AND PRO_PROJECTS.TARGET_START >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.start_date#">
		</cfif>
		<cfif isdefined("attributes.finish_date") and len(attributes.finish_date)>
			AND PRO_PROJECTS.TARGET_FINISH < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#DATEADD('d',1,attributes.finish_date)#">
		</cfif>
		<cfif len(attributes.expense_code) and len(attributes.expense_code_name)>
			AND PRO_PROJECTS.EXPENSE_CODE LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.expense_code#%">
		</cfif>
		<cfif isDefined("attributes.process_catid") and len(attributes.process_catid)>
			AND PRO_PROJECTS.PROCESS_CAT = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.process_catid#">
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
        <cfif len(attributes.special_definition)>
        	AND SPECIAL_DEFINITION_ID = #attributes.special_definition#
        </cfif>
		)T1
		ORDER BY
		<cfif isdefined("attributes.ordertype") and attributes.ordertype eq 2>
			CASE WHEN ISNUMERIC(T1.PROJECT_NUMBER) = 1 THEN 0 ELSE 1 END,
			CASE WHEN ISNUMERIC(T1.PROJECT_NUMBER) = 1 THEN CAST(T1.PROJECT_NUMBER AS float) ELSE 0 END,
			T1.PROJECT_NUMBER
		<cfelseif isdefined("attributes.ordertype") and attributes.ordertype eq 3>
			T1.PROJECT_HEAD DESC
		<cfelseif isdefined("attributes.ordertype") and attributes.ordertype eq 4>
			T1.PROJECT_HEAD
		<cfelseif isdefined("attributes.ordertype") and attributes.ordertype eq 5>
			T1.TARGET_START DESC
		<cfelseif isdefined("attributes.ordertype") and attributes.ordertype eq 6>
			T1.TARGET_START
		<cfelseif isdefined("attributes.ordertype") and attributes.ordertype eq 7>
			T1.TARGET_FINISH	DESC
		<cfelseif isdefined("attributes.ordertype") and attributes.ordertype eq 8>
			T1.TARGET_FINISH	
		<cfelse>
			CASE WHEN ISNUMERIC(T1.PROJECT_NUMBER) = 1 THEN 0 ELSE 1 END,
			CASE WHEN ISNUMERIC(T1.PROJECT_NUMBER) = 1 THEN CAST(T1.PROJECT_NUMBER AS float) ELSE 0 END DESC,
			T1.PROJECT_NUMBER
		</cfif>
</cfquery>
