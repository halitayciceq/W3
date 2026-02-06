<cfsetting showdebugoutput="no">
<cfif isDefined("attributes.id")>
	<cfquery name="get_work" datasource="#dsn#">
		SELECT WORK_HEAD,WORK_NO,WORK_CURRENCY_ID FROM PRO_WORKS WHERE WORK_ID = #attributes.id# 
	</cfquery>
	<cflock name="#CREATEUUID()#" timeout="20">
		<cftransaction>
			<cfquery name="WORK_SIL" datasource="#dsn#">
				DELETE FROM PRO_WORKS WHERE WORK_ID = #attributes.id# 
			</cfquery>
			<cfquery name="WORK_CC_SIL" datasource="#dsn#">
				DELETE FROM PRO_WORKS_CC WHERE WORK_ID = #attributes.id# 
			</cfquery>
			<cfquery name="WORK_HIST_SIL" datasource="#dsn#">
				DELETE FROM PRO_WORKS_HISTORY WHERE WORK_ID = #attributes.id# 
			</cfquery>
			<cfquery name="REL_WORK_SIL" datasource="#dsn#">
				UPDATE PRO_WORKS SET RELATED_WORK_ID = 0 WHERE RELATED_WORK_ID = '#attributes.id#'
			</cfquery>
			<cfquery name="delete_relations" datasource="#dsn#">
				DELETE FROM PRO_WORK_RELATIONS WHERE WORK_ID = #attributes.id# OR PRE_ID = #attributes.id#
			</cfquery>
            <cfquery name="GET_MATERIAL" datasource="#DSN#">
            	SELECT PRO_MATERIAL_ID FROM PRO_MATERIAL WHERE WORK_ID = #attributes.id#
            </cfquery>
            <cfif GET_MATERIAL.recordcount>
                <cfquery name="del_material" datasource="#dsn#">
                    DELETE PRO_MATERIAL WHERE PRO_MATERIAL_ID = #GET_MATERIAL.PRO_MATERIAL_ID#
                </cfquery>
                <cfquery name="DEL_MATERIAL_ROW" datasource="#DSN#">
                    DELETE FROM PRO_MATERIAL_ROW WHERE PRO_MATERIAL_ID = #GET_MATERIAL.PRO_MATERIAL_ID#
                </cfquery>
            </cfif>
			<cf_add_log  log_type="-1" action_id="#attributes.id#" action_name="#get_work.WORK_HEAD#" paper_no="#get_work.WORK_NO#" process_stage="#get_work.WORK_CURRENCY_ID#">
		</cftransaction>
	</cflock>
</cfif>
<cfif not isdefined("attributes.ajax")>
	<script type="text/javascript">
		<cfif attributes.fuseaction contains 'popup'>
			function isDefined(variable)
			{
				return (!(!(variable)));
			}
			<cfif attributes.fuseaction contains 'project.emptypopup_delwork'>
				window.location.href = '<cfoutput>#request.self#?fuseaction=project.works</cfoutput>';
			</cfif>
			if(isDefined(window.opener))
				wrk_opener_reload();
			window.close();
		<cfelseif not isDefined("no_location")>
			window.location.href = '<cfoutput>#request.self#?fuseaction=project.works</cfoutput>';
		</cfif>
	</script>
<cfelseif not isDefined("no_location")>
	<script src="<cfoutput>#request.self#?fuseaction=home.emptypopup_js_functions</cfoutput>"></script>
	<script type="text/javascript">
		<cfoutput>AjaxPageLoad('#request.self#?fuseaction=project.emptypopup_ajax_project_works<cfif isDefined("attributes.related_project_info")>&related_project_info=1</cfif><cfif isdefined("attributes.project_id")>&project_id=#attributes.project_id#</cfif><cfif isdefined("attributes.opp_id")>&opp_id=#attributes.opp_id#</cfif><cfif isdefined("attributes.service_id")>&service_id=#attributes.service_id#</cfif><cfif isdefined("attributes.g_service_id")>&g_service_id=#attributes.g_service_id#</cfif><cfif isdefined("attributes.assetp_id")>&assetp_id=#attributes.assetp_id#</cfif>','div_main_news_menu',1);</cfoutput>
	</script>
</cfif>
