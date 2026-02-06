<cfif len(attributes.workgroup_id)>
	<cfquery name="get_workgroup" datasource="#dsn#">
		SELECT EMPLOYEE_ID FROM WORKGROUP_EMP_PAR WHERE WORKGROUP_ID = #attributes.workgroup_id#
	</cfquery>
</cfif>
<cfquery name="GET_WORKS" datasource="#DSN#">
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
		<!---PRO_WORKS.CC_EMP_ID,---> 
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
        ,ISNULL((SELECT SUM((ISNULL(TOTAL_TIME_HOUR,0)*60) + ISNULL(TOTAL_TIME_MINUTE,0)) FROM PRO_WORKS_HISTORY WHERE PRO_WORKS.WORK_ID = PRO_WORKS_HISTORY.WORK_ID <cfif isdefined('attributes.emp_name') and isdefined('attributes.project_emp_id') and len(attributes.emp_name) and len(attributes.project_emp_id)>AND UPDATE_AUTHOR IN (#attributes.project_emp_id#) </cfif> GROUP BY WORK_ID),0) HARCANAN_DAKIKA
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
	<cfif isDefined('attributes.recorder_name') and len(attributes.recorder_name) and isdefined("attributes.recorder_id") and len(attributes.recorder_id)>
		AND PRO_WORKS.RECORD_AUTHOR = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.recorder_id#">
	</cfif>
	<cfif isDefined('attributes.upd_by_name') and len(attributes.upd_by_name) and isdefined("attributes.upd_by_id") and len(attributes.upd_by_id)>
		AND ISNULL(PRO_WORKS.UPDATE_AUTHOR,PRO_WORKS.RECORD_AUTHOR) = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.upd_by_id#">
	</cfif>
	<cfif len(attributes.keyword) gt 1>
		AND (
            <cfif isNumeric(attributes.keyword)>
				PRO_WORKS.WORK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.keyword#"> OR
			</cfif>
			PRO_WORKS.WORK_NO LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.keyword#%"> COLLATE SQL_Latin1_General_CP1_CI_AI OR
			PRO_WORKS.WORK_HEAD LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.keyword#%"> COLLATE SQL_Latin1_General_CP1_CI_AI OR
			PRO_WORKS.WORK_DETAIL LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.keyword#%"> COLLATE SQL_Latin1_General_CP1_CI_AI
			)
	<cfelseif len(attributes.keyword) eq 1>
		AND (
        	 <cfif isNumeric(attributes.keyword)>
				PRO_WORKS.WORK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.keyword#"> OR
			</cfif>
			PRO_WORKS.WORK_HEAD LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.keyword#%"> COLLATE SQL_Latin1_General_CP1_CI_AI
            )
	</cfif>
	<cfif isDefined("url.action_list_id") and Listlen(url.action_list_id) gt 0>AND PRO_WORKS.WORK_ID IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#url.action_list_id#" list="yes">)</cfif>
	<cfif len(attributes.CURRENCY)>
		AND PRO_WORKS.WORK_CURRENCY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.currency#">
	<cfelse>
		AND PRO_WORKS.WORK_CURRENCY_ID <> -3 <!--- bitti haric tüm kayıtlar --->
	</cfif>
	<cfif attributes.work_status eq -1>
		AND PRO_WORKS.WORK_STATUS = 0 
	<cfelseif attributes.work_status eq 0>
		AND (PRO_WORKS.WORK_STATUS = 0 OR PRO_WORKS.WORK_STATUS = 1)
	<cfelse><!--- default secim work_status eq 1 --->
		AND PRO_WORKS.WORK_STATUS = 1
	</cfif>
	<cfif len(attributes.PRIORITY_CAT)>
		AND PRO_WORKS.WORK_PRIORITY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.priority_cat# ">
	</cfif>
	<cfif len(attributes.work_cat)>
		AND PRO_WORKS.WORK_CAT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.work_cat# ">
	</cfif>
	<cfif isdefined("attributes.startdate") and len(attributes.startdate)>
		AND PRO_WORKS.TARGET_START >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.startdate#">
	</cfif>
	<cfif isdefined("attributes.finishdate") and len(attributes.finishdate)>
		AND PRO_WORKS.TARGET_FINISH <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.finishdate#">
	</cfif>
	<cfif len(attributes.comp_name) and len(attributes.comp_id)>
		AND PRO_WORKS.COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.comp_id#">
	</cfif>
	<cfif isdefined('attributes.emp_name') and isdefined('attributes.project_emp_id') and len(attributes.emp_name) and len(attributes.project_emp_id)>
		AND (
				<cfif isdefined('attributes.work_emp_cc') and attributes.work_emp_cc neq 3>
					PRO_WORKS.PROJECT_EMP_ID IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.project_emp_id#" list="yes">)
				</cfif>
				<cfif isdefined('attributes.work_emp_cc') and attributes.work_emp_cc eq 1>OR</cfif>
				<cfif isdefined('attributes.work_emp_cc') and (attributes.work_emp_cc eq 1 or attributes.work_emp_cc eq 3) and attributes.work_emp_cc neq 2>
					PRO_WORKS.WORK_ID IN (SELECT WORK_ID FROM PRO_WORKS_CC WHERE CC_EMP_ID IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.project_emp_id#" list="yes">))
				</cfif>
			)
	<cfelseif not len(attributes.outsrc_partner_id) and isdefined('attributes.emp_name') and len(attributes.emp_name)>
		AND (
				PRO_WORKS.WORK_ID IN (SELECT PWC.WORK_ID FROM PRO_WORKS_CC PWC, EMPLOYEES EE WHERE PWC.CC_EMP_ID = EE.EMPLOYEE_ID AND  PWC.WORK_ID = PRO_WORKS.WORK_ID AND EE.EMPLOYEE_NAME + ' ' + EE.EMPLOYEE_SURNAME LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.emp_name#%">)
            )
	<cfelseif isdefined("attributes.outsrc_partner_id") and len(attributes.outsrc_partner_id) and len(attributes.emp_name)>
		AND PRO_WORKS.OUTSRC_PARTNER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.outsrc_partner_id#">
	</cfif>
	<cfif len(attributes.project_id)>
    	<cfif attributes.project_id eq -1>
        	AND PRO_WORKS.PROJECT_ID IS NULL
		<cfelse>
        	AND PRO_WORKS.PROJECT_ID IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.project_id#" list="yes">)
        </cfif>  
	</cfif>
	<cfif len(attributes.pro_emp_id) and len(attributes.pro_emp_name)>	
        AND PRO_WORKS.PROJECT_ID IN (SELECT PRO_PROJECTS.PROJECT_ID FROM PRO_PROJECTS WHERE PRO_PROJECTS.PROJECT_EMP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.pro_emp_id#">) 
	</cfif>
	<cfif len(attributes.workgroup_id)>
		AND (PRO_WORKS.WORKGROUP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.workgroup_id#"><cfif get_workgroup.recordCount> OR PRO_WORKS.PROJECT_EMP_ID IN(#valueList(get_workgroup.EMPLOYEE_ID)#)</cfif>)
	</cfif>
	 <cfif len(attributes.cc_name) and len(attributes.cc_emp_id)>
		AND PRO_WORKS.WORK_ID IN (SELECT WORK_ID FROM PRO_WORKS_CC WHERE CC_EMP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.cc_emp_id#">)
	</cfif>
    <cfif len(attributes.cc_name) and len(attributes.cc_par_id)>
		AND PRO_WORKS.WORK_ID IN (SELECT WORK_ID FROM PRO_WORKS_CC WHERE CC_PAR_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.cc_par_id#">)
	</cfif>
	<cfif isdefined("attributes.onfuseaction") and len(attributes.onfuseaction)>
		AND PRO_WORKS.WORK_FUSEACTION = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.onfuseaction#">
		AND PRO_WORKS.WORK_FUSEACTION IS NOT NULL
	</cfif>
	<cfif isdefined("attributes.onmodule") and len(attributes.onmodule)>
		AND PRO_WORKS.WORK_CIRCUIT = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.onmodule#">
		AND PRO_WORKS.WORK_CIRCUIT IS NOT NULL
	</cfif>
	<cfif isdefined("attributes.contract_id") and len(attributes.contract_id) and isdefined("attributes.contract_no") and len(attributes.contract_no)>
		AND (PRO_WORKS.PURCHASE_CONTRACT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.contract_id#"> OR PRO_WORKS.SALE_CONTRACT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.contract_id#">)
	</cfif>
	<cfif isdefined("attributes.pbs_id") and len(attributes.pbs_id) and isdefined("attributes.pbs_code") and len(attributes.pbs_code)>
		AND PRO_WORKS.PBS_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.pbs_id#"> 
	</cfif>
	<cfif isdefined("attributes.expense_code") and len(attributes.expense_code) and len(attributes.expense_code_name)>
		AND PRO_WORKS.PROJECT_ID IN (SELECT PROJECT_ID FROM PRO_PROJECTS WHERE EXPENSE_CODE = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.expense_code#">)
	</cfif>
	<cfif isdefined("attributes.show_milestone") and attributes.show_milestone eq 0>
		AND PRO_WORKS.IS_MILESTONE <> 1
	</cfif>
    <cfif len(attributes.special_definition)>
    	AND PRO_WORKS.SPECIAL_DEFINITION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.special_definition#">
    </cfif>
	<cfif isdefined("attributes.to_complete") and len(attributes.to_complete)>
		AND TO_COMPLETE=#attributes.to_complete#
	</cfif>
	<cfif isdefined("attributes.branch_id") and len(attributes.branch_id)>
		AND PRO_WORKS.PROJECT_EMP_ID IN (	
							SELECT EMPLOYEE_ID 
							FROM EMPLOYEE_POSITIONS,DEPARTMENT
							WHERE EMPLOYEE_POSITIONS.DEPARTMENT_ID = DEPARTMENT.DEPARTMENT_ID AND DEPARTMENT.BRANCH_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.branch_id#">
							)
	</cfif>
	<cfif isdefined("attributes.department") and len(attributes.department)>
        AND PRO_WORKS.PROJECT_EMP_ID IN (	
                            SELECT EMPLOYEE_ID 
                            FROM EMPLOYEE_POSITIONS
                            WHERE 
                            <cfif listlen(attributes.department,',') gt 1>
                            	EMPLOYEE_POSITIONS.DEPARTMENT_ID IN (#attributes.department#)
                            <cfelse>
                            	EMPLOYEE_POSITIONS.DEPARTMENT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.department#">
                            
                            </cfif>
                            )
    </cfif>
    <cfif isdefined("attributes.activity_id") and len(attributes.activity_id)>
    	AND PRO_WORKS.ACTIVITY_ID = #attributes.activity_id#
    </cfif>
    )L1
    WHERE
	    1=1 
        <cfif attributes.show_milestone eq 0>
            AND IS_MILESTONE <> 1
        </cfif>
    ORDER BY	
		<cfif isdefined("attributes.ordertype") and attributes.ordertype eq 2>
			ISNULL(UPDATE_DATE,RECORD_DATE) DESC
		<cfelseif isdefined("attributes.ordertype") and attributes.ordertype eq 3>
			TARGET_START DESC
		<cfelseif isdefined("attributes.ordertype") and attributes.ordertype eq 4>
			TARGET_START
		<cfelseif isdefined("attributes.ordertype") and attributes.ordertype eq 5>
			TARGET_FINISH DESC	
		<cfelseif isdefined("attributes.ordertype") and attributes.ordertype eq 6>
			TARGET_FINISH
		<cfelseif isdefined("attributes.ordertype") and attributes.ordertype eq 7>
			WORK_HEAD	
		<cfelse>
			NEW_WORK_ID, 
			TYPE,
			WORK_ID DESC
		</cfif>
</cfquery>