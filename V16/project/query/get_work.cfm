<cfquery name="UPD_WORK" datasource="#DSN#">
	SELECT 
		ISNULL(TO_COMPLETE,0) TO_COMPLETE,
		TERMINATE_DATE,
		REAL_START,
		REAL_FINISH,
		TARGET_START,
		TARGET_FINISH,
		WORK_NO,
		WORK_HEAD,
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
		RECORD_DATE,
		UPDATE_DATE,
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
        TO_COMPLETE
	FROM 
		PRO_WORKS
	WHERE 
		WORK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.id#">
		<cfif isdefined('xml_is_detail_filtre') and xml_is_detail_filtre eq 1>
        	<cfif (not isdefined('xml_is_all_authorization') or not len(xml_is_all_authorization))  or (len('xml_is_all_authorization') and not listfind(xml_is_all_authorization,session.ep.position_code,','))>
        	 	AND  
                (
					PRO_WORKS.PROJECT_EMP_ID = #session.ep.userid#
                    OR PRO_WORKS.WORK_ID IN(SELECT WORK_ID FROM PRO_WORKS_CC WHERE CC_EMP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#"> AND WORK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.id#">)
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
</cfquery>
<cfquery name="GET_LAST_REC" datasource="#DSN#">
	SELECT
		HISTORY_ID
	FROM
		PRO_WORKS_HISTORY
	WHERE
		WORK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.id#">		
</cfquery>

<cfif get_last_rec.recordcount>
	<cfquery name="GET_HIST_DETAIL" datasource="#DSN#">
		SELECT
			PWH.HISTORY_ID,
			SP.PRIORITY_ID
		FROM
			PRO_WORKS_HISTORY PWH,
			SETUP_PRIORITY SP
		WHERE
			PWH.WORK_PRIORITY_ID = SP.PRIORITY_ID AND
			PWH.HISTORY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_last_rec.history_id#">
	</cfquery>
</cfif>
