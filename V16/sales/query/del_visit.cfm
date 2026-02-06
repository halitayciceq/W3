<cfquery name="get_event_head" datasource="#dsn#">
	SELECT EVENT_PLAN_HEAD,EVENT_PLAN_ID,RECORD_EMP,EVENT_STATUS FROM EVENT_PLAN WHERE EVENT_PLAN_ID = #attributes.id#	
</cfquery>
<cflock name="#CREATEUUID()#" timeout="60">
	<cftransaction>
		<cfquery name="DEL_VISIT" datasource="#dsn#">
			DELETE
				EVENT_PLAN
			WHERE
				EVENT_PLAN_ID = #attributes.id#
		</cfquery>
		<cfquery name="DEL_VISIT_ROW" datasource="#dsn#">
			DELETE
				EVENT_PLAN_ROW
			WHERE
				EVENT_PLAN_ID = #attributes.id#
		</cfquery>
		<cf_add_log  log_type="-1" action_id="#attributes.id#" paper_no="#attributes.id#" action_name="#get_event_head.event_plan_head#" process_stage="#get_event_head.event_status#">
	</cftransaction>
</cflock>
<cflocation url="#request.self#?fuseaction=sales.list_visit" addtoken="no">

