<cf_get_lang_set module_name="project"><!--- sayfanin en altinda kapanisi var --->
<cfset task_user_email=''>
<cfset task_cc_email = ''>
<cfif not isdefined("attributes.estimated_time") or not len(attributes.estimated_time)><cfset attributes.estimated_time=0></cfif>
<cfif not isdefined("attributes.estimated_time_minute") or not len(attributes.estimated_time_minute)><cfset attributes.estimated_time_minute=0></cfif>
<cfset total_time = (attributes.estimated_time*60)+attributes.estimated_time_minute>
<cfif not isdefined('attributes.total_time_hour') or not attributes.total_time_hour gt 0><cfset attributes.total_time_hour=0></cfif>
<cfif not isdefined('attributes.total_time_minute') or not attributes.total_time_minute gt 0><cfset attributes.total_time_minute=0></cfif>

<cf_date tarih="attributes.startdate_plan">
<cfif isDefined("attributes.start_hour") and len(attributes.start_hour)>
	<cfset attributes.startdate_plan = date_add("h",attributes.start_hour - session.ep.time_zone, attributes.startdate_plan)>
</cfif>

<cf_date tarih="attributes.finishdate_plan">
<cfif isDefined("attributes.finish_hour_plan") and len(attributes.finish_hour_plan)>
	<cfset attributes.finishdate_plan = date_add("h",attributes.finish_hour_plan - session.ep.time_zone, attributes.finishdate_plan)>
</cfif>

<cfif isdefined('attributes.terminate_date') and len(attributes.terminate_date)>
    <cf_date tarih="attributes.terminate_date">
    <cfset attributes.terminate_date=date_add("h",attributes.terminate_hour - session.ep.time_zone, attributes.terminate_date)>
<cfelseif isdefined('attributes.finishdate_plan') and len(attributes.finishdate_plan)>
    <cfset attributes.terminate_date=date_add("h",attributes.finish_hour_plan - session.ep.time_zone, attributes.finishdate_plan)>
</cfif>

<cfif isDefined("attributes.predicted_start") and len(attributes.predicted_start)>
	<cf_date tarih="attributes.predicted_start">
    <cfset attributes.predicted_start = date_add('h',attributes.predicted_start_hour - session.ep.time_zone, attributes.predicted_start)>
</cfif>

<cfif isDefined("attributes.predicted_finish") and len(attributes.predicted_finish)>
	<cf_date tarih="attributes.predicted_finish">
	<cfset attributes.predicted_finish = date_add('h',attributes.predicted_finish_hour - session.ep.time_zone, attributes.predicted_finish)>
</cfif> 

<cfif isdefined("attributes.rel_work_id") and len(attributes.rel_work_id)>
	<cfquery name="GET_REL_WORK_PRO" datasource="#DSN#">
		SELECT TARGET_START FROM #dsn_alias#.PRO_WORKS WHERE WORK_ID = #rel_work_id#
	</cfquery>
	<cfif attributes.startdate_plan lt get_rel_work_pro.target_start>
		<script type="text/javascript">
			alert("<cf_get_lang no='39.İlişkilendirdiğiniz işin başlangıç tarihi işin başlangıç tarihinden küçük gözüküyor'>!");
			history.back();
		</script>
		<cfabort>
	</cfif>
</cfif>
<!--- Action file larda sorun oluyordu bloklara ayrildi --->
<cfif isdefined("attributes.xml_is_work_no") and attributes.xml_is_work_no eq 1>
<cf_papers paper_type="WORK">
</cfif>
<cfif not isdefined("is_transaction")>
	<cflock name="#CREATEUUID()#" timeout="20">
		<cftransaction>
			<cfinclude template="add_work_ic.cfm">
		</cftransaction>
	</cflock>
<cfelse>
	<cfinclude template="add_work_ic.cfm">
</cfif>
<!---Ek Bilgiler--->
<cfset attributes.info_id =  get_last_work.work_id>
<cfset attributes.is_upd = 0>
<cfset attributes.info_type_id = -18>
<cfinclude template="../../objects/query/add_info_plus2.cfm">
<!---Ek Bilgiler--->
<cfif not isDefined("is_process_control")>
	<cfif isdefined("attributes.work_process_stage")>
		<cfset process_stage_ = attributes.work_process_stage>
	<cfelse>
		<cfset process_stage_ = attributes.process_stage>
	</cfif>
	<cf_workcube_process
		is_upd='1' 
		old_process_line='0'
		process_stage='#process_stage_#' 
		record_member='#session.ep.userid#' 
		record_date='#now()#' 
		action_table='PRO_WORKS'
		action_column='WORK_ID'
		action_id='#get_last_work.work_id#'
		action_page='#request.self#?fuseaction=project.works&event=det&id=#get_last_work.work_id#' 
		warning_description = '#getLang("","İlgili İş",66816)# : #attributes.work_head#'>
</cfif>
<cfif isDefined('warning') and warning neq 1>
	<cfif cgi.referer contains "popup">
		<script type="text/javascript">
			<cfif isdefined("attributes.work_detail_id")>
				window.location.href = '<cfoutput>#request.self#?fuseaction=project.works&event=det&id=#add_work.max_work_id#</cfoutput>';
			<cfelse>
				<cfif not cgi.referer contains "is_closed"><!--- BK 20080918 quickmenu den is ekleme yapilirsa popup sadece kapanmali --->
					wrk_opener_reload();
				</cfif>
				window.close();
			</cfif>
		</script>
	<cfelse>
		<cfif isdefined("attributes.opp_id")>
			<script type="text/javascript">
				closeBoxDraggable( '<cfoutput>#attributes.modal_id#</cfoutput>','box_works_b');
			</script>
		<cfelseif isdefined("attributes.product_sample_id")>
				<script type="text/javascript">
					window.location.href = '<cfoutput>#request.self#?fuseaction=product.product_sample&event=upd&product_sample_id=#attributes.product_sample_id#</cfoutput>';
				</script>
			<cfelse>
			<cfif isdefined("attributes.g_service_id") and len(attributes.g_service_id)>
				<script type="text/javascript">
					window.location.href = '<cfoutput>#request.self#?fuseaction=call.list_service&event=upd&service_id=#attributes.g_service_id#</cfoutput>';
				</script>
			<cfelse>
				<cfset attributes.actionId = add_work.max_work_id>
				<script type="text/javascript">
					window.location.href = '<cfoutput>#request.self#?fuseaction=project.works&event=det&id=#add_work.max_work_id#</cfoutput>';
				</script>
			</cfif>
		</cfif>
	</cfif> 
</cfif>
<cf_get_lang_set module_name="#lcase(listgetat(attributes.fuseaction,1,'.'))#"><!--- sayfanin en ustunde acilisi var --->
