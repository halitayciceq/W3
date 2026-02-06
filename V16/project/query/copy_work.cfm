<cfsetting showdebugoutput="no">
<!--- <script src="<cfoutput>#request.self#?fuseaction=home.emptypopup_js_functions</cfoutput>"></script> --->
<cfquery name="get_work" datasource="#dsn#">
	SELECT WORK_CURRENCY_ID FROM PRO_WORKS WHERE WORK_ID IN (#attributes.work_id#)
</cfquery>
<cfset work_ids = attributes.work_id>
	<cflock name="#CREATEUUID()#" timeout="20">
		<cftransaction>
			<cfloop index="ind" from="1" to="#get_work.recordcount#">
				<cfset attributes.work_id = ListGetAt(work_ids,ind,',')>
				<cfquery name="copy_work" datasource="#dsn#">
					INSERT INTO
						PRO_WORKS
						(
							WORK_STATUS,
							RELATED_WORK_ID,
							PROJECT_ID,
							COMPANY_ID,
							COMPANY_PARTNER_ID,
							WORK_HEAD,
							WORK_DETAIL,
							WORK_CAT_ID,
							TARGET_START,
							TARGET_FINISH,
							REAL_START,
							REAL_FINISH,
							WORK_CURRENCY_ID,
							WORK_PRIORITY_ID,
							RECORD_DATE,
							RECORD_AUTHOR,
							RECORD_IP,
							OUTSRC_CMP_ID,
							OUTSRC_PARTNER_ID,
							ESTIMATED_TIME,
							EXPECTED_BUDGET,
							EXPECTED_BUDGET_MONEY,
							PERIODIC_WORK_ID,
							OPPORTUNITY_ID,
							PROJECT_EMP_ID,
							WORKGROUP_ID,
							TOTAL_TIME_HOUR,
							TOTAL_TIME_MINUTE,
							WORK_CIRCUIT,
							WORK_FUSEACTION,
							OPP_OUR_COMPANY_ID,
							<!---CC_EMP_ID,--->
							TO_COMPLETE,
							CONSUMER_ID,
							SERVICE_ID,
							SUBSCRIPTION_ID,
							OUR_COMPANY_ID,
							G_SERVICE_ID,
							<!---OUTSRC_CC_PARTNER_ID,--->
							ASSETP_ID,
							WORK_NO,
							MILESTONE_WORK_ID,
							IS_MILESTONE
						)
						SELECT
							WORK_STATUS,
							RELATED_WORK_ID,
							PROJECT_ID,
							COMPANY_ID,
							COMPANY_PARTNER_ID,
							WORK_HEAD,
							WORK_DETAIL,
							WORK_CAT_ID,
							TARGET_START,
							TARGET_FINISH,
							REAL_START,
							REAL_FINISH,
							WORK_CURRENCY_ID,
							WORK_PRIORITY_ID,
							#createodbcdatetime(now())#,
							#session.ep.userid#,					
							'#cgi.remote_addr#',					
							OUTSRC_CMP_ID,
							OUTSRC_PARTNER_ID,
							ESTIMATED_TIME,
							EXPECTED_BUDGET,
							EXPECTED_BUDGET_MONEY,
							PERIODIC_WORK_ID,
							OPPORTUNITY_ID,
							PROJECT_EMP_ID,
							WORKGROUP_ID,
							TOTAL_TIME_HOUR,
							TOTAL_TIME_MINUTE,
							WORK_CIRCUIT,
							WORK_FUSEACTION,
							OPP_OUR_COMPANY_ID,
							<!---CC_EMP_ID,--->
							TO_COMPLETE,
							CONSUMER_ID,
							SERVICE_ID,
							SUBSCRIPTION_ID,
							OUR_COMPANY_ID,
							G_SERVICE_ID,
						<!---	OUTSRC_CC_PARTNER_ID,--->
							ASSETP_ID,
							WORK_NO,
							<cfif isdefined("attributes.newMilestone") and len(attributes.newMilestone)>#attributes.newMilestone#<cfelse>NULL</cfif>,
							0
						FROM
							PRO_WORKS
						WHERE
							WORK_ID = #attributes.work_id#
				</cfquery>
		
				<cfquery name="GET_LAST_WORK" datasource="#DSN#">
					SELECT MAX(WORK_ID) AS WORK_ID FROM PRO_WORKS
				</cfquery>
				<cfquery name="GET_WORK_RELATIONS" datasource="#DSN#">
					SELECT * FROM PRO_WORK_RELATIONS WHERE WORK_ID= <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.work_id#">
				</cfquery>
				
				<cfif GET_WORK_RELATIONS.recordcount>
					<cfquery name="ADD_PRO_WORK_RELATIONS" datasource="#DSN#">
						INSERT INTO
							PRO_WORK_RELATIONS
							(
								WORK_ID,
								PRE_ID,
								RELATION_TYPE,
								LAG
							)
							VALUES
							(
								<cfqueryparam cfsqltype="cf_sql_integer" value="#GET_LAST_WORK.WORK_ID#">,
								<cfqueryparam cfsqltype="cf_sql_integer" value="#GET_WORK_RELATIONS.PRE_ID#">,
								<cfif len(GET_WORK_RELATIONS.RELATION_TYPE)>
									<cfqueryparam cfsqltype="cf_sql_varchar" value="#GET_WORK_RELATIONS.RELATION_TYPE#">
								<cfelse>
									NULL
								</cfif>,
								<cfif  len(GET_WORK_RELATIONS.lag)>
									<cfqueryparam cfsqltype="cf_sql_integer" value="#GET_WORK_RELATIONS.lag#">
								<cfelse>
									NULL
								</cfif>
							)
					</cfquery>
				</cfif>
				<cfset work_id_=get_last_work.work_id>
				
				<cfquery name="add_history" datasource="#dsn#">
					INSERT INTO
						PRO_WORKS_HISTORY
						(
						WORK_ID,
						UPDATE_DATE,
						RELATED_WORK_ID,
						PROJECT_ID,
						TARGET_START,
						TARGET_FINISH,
						WORK_CURRENCY_ID,
						WORK_PRIORITY_ID,
						OUTSRC_CMP_ID,
						OUTSRC_PARTNER_ID,
						UPDATE_AUTHOR,
						UPDATE_PAR,
						WORK_CAT_ID,
						COMPANY_ID,
						COMPANY_PARTNER_ID,
						PERIODIC_WORK_ID,
						PROJECT_EMP_ID,
						WORK_HEAD,
						WORK_DETAIL,
						TOTAL_TIME_HOUR,
						TOTAL_TIME_MINUTE,
						TO_COMPLETE,
						CONSUMER_ID,
						SERVICE_ID,
						SUBSCRIPTION_ID,
						OUR_COMPANY_ID,
						G_SERVICE_ID,
						ESTIMATED_TIME
						<!--- OUTSRC_CC_PARTNER_ID --->
						)
						SELECT
							#work_id_#,
							#createodbcdatetime(now())#,
							RELATED_WORK_ID,
							PROJECT_ID,
							TARGET_START,
							TARGET_FINISH,
							WORK_CURRENCY_ID,
							WORK_PRIORITY_ID,
							OUTSRC_CMP_ID,
							OUTSRC_PARTNER_ID,
							UPDATE_AUTHOR,
							UPDATE_PAR,
							WORK_CAT_ID,
							COMPANY_ID,
							COMPANY_PARTNER_ID,
							PERIODIC_WORK_ID,
							PROJECT_EMP_ID,
							WORK_HEAD,
							WORK_DETAIL,
							TOTAL_TIME_HOUR,
							TOTAL_TIME_MINUTE,
							TO_COMPLETE,
							CONSUMER_ID,
							SERVICE_ID,
							SUBSCRIPTION_ID,
							OUR_COMPANY_ID,
							G_SERVICE_ID,
							ESTIMATED_TIME
							<!--- OUTSRC_CC_PARTNER_ID --->
						FROM
							PRO_WORKS
						WHERE
							WORK_ID = #work_id_#
				</cfquery>
				<cfif isdefined("attributes.from_milestone") and attributes.from_milestone eq 1>
					<cfquery name="UPDATA_WORKS" datasource="#dsn#">
						UPDATE PRO_WORKS SET WORK_STATUS = 0 WHERE WORK_ID = #ListGetAt(work_ids,ind,',')#
					</cfquery>
				</cfif>
			</cfloop>
		</cftransaction>
	</cflock>
   	<script type="text/javascript">
		<cfoutput>
			refresh_box('<cfif isdefined('attributes.main_mission_id') and len(attributes.main_mission_id)>main_mission_id<cfelse> main_news_menu</cfif>','#request.self#?fuseaction=project.emptypopup_ajax_project_works<cfif isDefined("xml_milestone_transfer")>&xml_milestone_transfer=#attributes.xml_milestone_transfer#</cfif><cfif isDefined("attributes.related_project_info")>&related_project_info=1</cfif><cfif isdefined("attributes.project_id")>&project_id=#attributes.project_id#</cfif><cfif isdefined("attributes.opp_id")>&opp_id=#attributes.opp_id#</cfif><cfif isdefined("attributes.service_id")>&service_id=#attributes.service_id#</cfif><cfif isdefined("attributes.g_service_id")>&g_service_id=#attributes.g_service_id#</cfif><cfif isdefined("attributes.assetp_id")>&assetp_id=#attributes.assetp_id#</cfif><cfif isdefined("attributes.subscription_id")>&subscription_id=#attributes.subscription_id#</cfif><cfif isdefined('attributes.project_detail_id') and len(attributes.project_detail_id)>&project_detail_id=#attributes.project_detail_id#</cfif><cfif isdefined('attributes.ordertype') and len(attributes.ordertype)>&attributes.ordertype=#attributes.ordertype#</cfif><cfif isdefined('attributes.work_milestones') and len(attributes.work_milestones)>work_milestones=#work_milestones#</cfif>','0');
		</cfoutput>
	</script>
