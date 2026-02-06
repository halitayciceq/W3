<cf_date tarih="attributes.today">
<cfif len(attributes.record_num) and attributes.record_num neq "">
<cfquery name="del_" datasource="#dsn#">
	DELETE FROM TIME_COST_PLANNED WHERE WORK_ID = #attributes.work_id#
</cfquery>
<cfloop from="1" to="#attributes.record_num#" index="i">
	<cfif isdefined("attributes.row_kontrol_#i#") and evaluate("attributes.row_kontrol_#i#") neq 0>
	<cfscript>
		attributes.TOTAL_TIME_MINUTE1 = evaluate("attributes.TOTAL_TIME_MINUTE#i#");
		attributes.TOTAL_TIME_HOUR1 = evaluate("attributes.TOTAL_TIME_HOUR#i#");
		form_employee_id = evaluate("attributes.employee_id#i#");
		form_employee = evaluate("attributes.employee#i#");
		if(isdefined('attributes.comment#i#'))
			form_comment = evaluate("attributes.comment#i#");
		else
			form_comment = '';
		form_total_time_hour = evaluate("attributes.total_time_hour#i#");
		form_total_time_minute = evaluate("attributes.total_time_minute#i#");
		
		
		if(isdefined('attributes.partner_id#i#'))
		{
			form_partner_id = evaluate("attributes.partner_id#i#");
		}
		else
		{
			form_consumer_id = '';
			form_partner_id = '';
			form_company_id = '';
			form_member_name = '';
		}

		form_today = evaluate("attributes.today#i#");
		if(isdefined('attributes.work_id#i#') || isdefined('attributes.work_head#i#'))
		{
			form_work_id = evaluate("attributes.work_id#i#");
			form_work_head = evaluate("attributes.work_head#i#");
		}
		else
		{
			form_work_id = '';
			form_work_head = '';
		}
		form_today = evaluate("attributes.today#i#");
		if(isdefined('attributes.product_id#i#'))
			form_product_id = evaluate("attributes.product_id#i#");
		else
			form_product_id = '';
			
		if(isdefined('attributes.overtime_type#i#'))
			form_overtime_type = evaluate("attributes.overtime_type#i#");
		else
			form_overtime_type = '';
	</cfscript>
    <cfset attributes.today = evaluate("attributes.today#i#")>
    <cfquery name="ADD_TIME_COST" datasource="#dsn#">
        INSERT INTO
            TIME_COST_PLANNED
        (
            OUR_COMPANY_ID,
            TOTAL_TIME_MINUTE1,
            TOTAL_TIME_HOUR1,
            EMPLOYEE_ID,
            EMPLOYEE_NAME, 
            WORK_ID,
            HISTORY_ID,
            PARTNER_ID,
            COMMENT,
            PRODUCT_ID,	
            OVERTIME_TYPE,
            FINISH_DATE,
            RECORD_DATE,
            RECORD_EMP,
            RECORD_IP
        )
        VALUES
        (
            <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#">,
            <cfif len(attributes.TOTAL_TIME_MINUTE1)><cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.TOTAL_TIME_MINUTE1#"><cfelse>0</cfif>,
            <cfif len(attributes.TOTAL_TIME_HOUR1)><cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.TOTAL_TIME_HOUR1#"><cfelse>0</cfif>,
            <cfif len(form_employee_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#form_employee_id#"><cfelse>NULL</cfif>,
            <cfqueryparam cfsqltype="cf_sql_varchar" value="#form_employee#">,
            <cfif len(attributes.work_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.work_id#">,<cfelse>NULL,</cfif>
            <cfif len(attributes.history_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.history_id#">,<cfelse>NULL,</cfif>
            <cfif len(form_partner_id) and len(form_member_name)><cfqueryparam cfsqltype="cf_sql_integer" value="#form_partner_id#">,<cfelse>NULL,</cfif>
            <cfif len(form_comment)><cfqueryparam cfsqltype="cf_sql_varchar" value="#form_comment#">,<cfelse>NULL,</cfif>
            <cfif len(form_product_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#form_product_id#">,<cfelse>NULL,</cfif>
            <cfif len(form_overtime_type)><cfqueryparam cfsqltype="cf_sql_integer" value="#form_overtime_type#"><cfelse>NULL</cfif>,
            <cfif len(attributes.today)><cfqueryparam cfsqltype="cf_sql_timestamp" value="#dateformat(attributes.today,dateformat_style)#"><cfelse>NULL</cfif>,
            <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
            <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#">,
            <cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.remote_addr#">
        )
    </cfquery>
  </cfif>
</cfloop>
</cfif>
<script type="text/javascript">
	<cfif isdefined("attributes.draggable") and len(attributes.draggable)>
		closeBoxDraggable( '<cfoutput>#attributes.modal_id#</cfoutput>','unique_box_followup2');
		refreshBox('unique_box_followup2');
	</cfif>
</script>
