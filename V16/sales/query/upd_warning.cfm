<cfif len(attributes.main_start_date)><cf_date tarih='attributes.main_start_date'></cfif>
<cfif len(attributes.main_finish_date)><cf_date tarih='attributes.main_finish_date'></cfif>
<cflock name="#CreateUUID()#" timeout="60">
  <cftransaction>
	<cfquery name="ADD_EVENT_PLAN" datasource="#DSN#">
		UPDATE
			EVENT_PLAN
		SET
			IS_ACTIVE = <cfif isdefined("attributes.is_active")>1<cfelse>0</cfif>,
			EVENT_PLAN_HEAD = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.warning_head#">,
			DETAIL = <cfif len(attributes.event_detail)><cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.event_detail#"><cfelse>NULL</cfif>,
			EVENT_STATUS = #attributes.process_stage#,
			ANALYSE_ID = <cfif len(attributes.analyse_head) and len(attributes.analyse_id)>#attributes.analyse_id#<cfelse>NULL</cfif>,
			ISPOTANTIAL = 1,
			IS_SALES = 1,
			MAIN_START_DATE = <cfif len(attributes.main_start_date)>#attributes.main_start_date#<cfelse>NULL</cfif>,
			MAIN_FINISH_DATE = <cfif len(attributes.main_finish_date)>#attributes.main_finish_date#<cfelse>NULL</cfif>,
			SALES_ZONES = <cfif len(attributes.sales_zones)>#attributes.sales_zones#<cfelse>NULL</cfif>,
		<cfif isdefined('hidden_is_agenda_authority') and (hidden_is_agenda_authority eq 1)>
			 <cfif isDefined("attributes.view_to_all")>
				VIEW_TO_ALL = 1,
				IS_WIEW_BRANCH = NULL,
				IS_WIEW_DEPARTMENT = NULL,
                IS_VIEW_COMPANY = NULL,
			<cfelseif isDefined("attributes.is_wiew_branch")>
				VIEW_TO_ALL=1,
				IS_WIEW_BRANCH = #attributes.is_wiew_branch#,
				IS_WIEW_DEPARTMENT = NULL,
                IS_VIEW_COMPANY = NULL,
			<cfelseif isDefined("attributes.is_wiew_department")>
				VIEW_TO_ALL=1,
				IS_WIEW_BRANCH = #attributes.is_wiew_branch_#,<!--- NULL,--->
				IS_WIEW_DEPARTMENT = #attributes.is_wiew_department#,
                IS_VIEW_COMPANY = NULL,
            <cfelseif isDefined("attributes.is_view_company")>
				VIEW_TO_ALL=1,
				IS_WIEW_BRANCH = NULL,
				IS_WIEW_DEPARTMENT = NULL,
                IS_VIEW_COMPANY = #attributes.is_view_company#,
			<cfelse>
				VIEW_TO_ALL=NULL,
				IS_WIEW_BRANCH = NULL,
				IS_WIEW_DEPARTMENT = NULL,
                IS_VIEW_COMPANY = NULL,
			</cfif>
		</cfif>
			UPDATE_DATE = #now()#,
			UPDATE_EMP = #session.ep.userid#,
			UPDATE_IP = <cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.remote_addr#">
		WHERE
			EVENT_PLAN_ID = #attributes.visit_id#
	</cfquery>
    <cfquery name="del_comp" datasource="#dsn#">
        DELETE FROM EVENT_PLAN_COMPANY WHERE EVENT_PLAN_ID = #attributes.visit_id#
    </cfquery>
    <cfif isdefined("attributes.agenda_company") and isdefined("attributes.is_view_company")>
    	<cfloop list="#attributes.agenda_company#" index="cc">
            <cfquery name="add_comp" datasource="#dsn#">
                INSERT INTO EVENT_PLAN_COMPANY
                (
                    EVENT_PLAN_ID,
                    COMPANY_ID
                )
                VALUES
                (
                    #attributes.visit_id#,
                    #cc#
                )
            </cfquery> 
        </cfloop>
    </cfif>
	<cfif isdefined("attributes.event_plan_row_id")>
	  <cfloop from="1" to="#listlen(attributes.event_plan_row_id)#" index="i">
		<cfquery name="DEL_ROW_ID" datasource="#DSN#">
			DELETE 
			FROM
				EVENT_PLAN_ROW_PARTICIPATION_POS
			WHERE
				EVENT_ROW_ID = #listgetat(attributes.event_plan_row_id, i, ',')#
		</cfquery>
	  </cfloop>
	</cfif>
	<cfif len(attributes.record_num) and attributes.record_num neq "">
		<cfloop from="1" to="#attributes.record_num#" index="i">
		<cfif evaluate("attributes.row_kontrol#i#") neq 0>
		  <cfscript>
		  	if(isdefined('attributes.project_id#i#'))form_project_id=listdeleteduplicates(evaluate("attributes.project_id#i#"),',');else form_project_id="";
		  	if(isdefined('attributes.relation_asset_id#i#'))form_asset_id=listdeleteduplicates(evaluate("attributes.relation_asset_id#i#"),',');else form_asset_id="";
			form_warning_id = listdeleteduplicates(evaluate("attributes.warning_id#i#"),',');
			if(isdefined("attributes.company_id#i#") and len(evaluate("attributes.company_id#i#")))form_company_id = listdeleteduplicates(evaluate("attributes.company_id#i#"),',');else form_company_id = "";
			if(isdefined("attributes.partner_id#i#") and len(evaluate("attributes.partner_id#i#")))form_partner_id = listdeleteduplicates(evaluate("attributes.partner_id#i#"),',');else form_partner_id = "";
			if(isdefined("attributes.consumer_id#i#") and len(evaluate("attributes.consumer_id#i#")))form_consumer_id = listdeleteduplicates(evaluate("attributes.consumer_id#i#"),',');else form_consumer_id = "";
			form_start_date = listdeleteduplicates(evaluate("attributes.start_date#i#"),',');
			form_start_clock = listdeleteduplicates(evaluate("attributes.start_clock#i#"),','); 
			form_start_minute = listdeleteduplicates(evaluate("attributes.start_minute#i#"),',');
			form_finish_date = listdeleteduplicates(evaluate("attributes.start_date#i#"),',');
			form_finish_clock = listdeleteduplicates(evaluate("attributes.finish_clock#i#"),',');
			form_finish_minute = listdeleteduplicates(evaluate("attributes.finish_minute#i#"),',');
			form_pos_emp_id = listdeleteduplicates(evaluate("attributes.pos_emp_id#i#"),',');
			//form_event_row_ids = evaluate("attributes.event_row_ids#i#");
		  </cfscript>
		  <cfif len(form_start_date)>
			<cf_date tarih='form_start_date'>
			<cfscript>
				form_start_date = date_add('h', form_start_clock, form_start_date);
				form_start_date = date_add('n', form_start_minute, form_start_date);
			</cfscript>
		  </cfif>
		  <cfif len(form_finish_date)>
			<cf_date tarih='form_finish_date'>
			<cfscript>
				form_finish_date = date_add('h', form_finish_clock, form_finish_date);
				form_finish_date = date_add('n', form_finish_minute, form_finish_date);
			</cfscript>
		  </cfif>
		  <cfset form_event_row_ids = 'attributes.event_row_ids'&i>
			<cfif isdefined("#form_event_row_ids#")>
			  <cfset form_event_row_ids_value = evaluate(form_event_row_ids)>
				<cfif len(form_company_id) or len(form_consumer_id)>
				  <cfquery name="ADD_EVENT_PLAN_ROW" datasource="#DSN#">
						UPDATE
							EVENT_PLAN_ROW
						SET
							BRANCH_ID = <cfif len(attributes.sales_zones)><cfqueryparam value="#attributes.sales_zones#" cfsqltype="cf_sql_integer"><cfelse>NULL</cfif>,
							IS_ACTIVE = <cfif isdefined("attributes.is_active")>1<cfelse>0</cfif>,
							UPDATE_DATE = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
							UPDATE_EMP = <cfqueryparam value="#session.ep.userid#" cfsqltype="cf_sql_integer">,
							UPDATE_IP = <cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.remote_addr#">,
							IS_SALES = 1,
							PLAN_ROW_STATUS = 0,
							<cfif len(form_company_id) and len(form_partner_id)>
								COMPANY_ID = <cfqueryparam value="#form_company_id#" cfsqltype="cf_sql_integer">,
								PARTNER_ID = <cfqueryparam value="#form_partner_id#" cfsqltype="cf_sql_integer">,
								CONSUMER_ID = NULL,
							<cfelseif len(form_consumer_id)>
								COMPANY_ID = NULL,
								PARTNER_ID = NULL,
								CONSUMER_ID = <cfqueryparam value="#form_consumer_id#" cfsqltype="cf_sql_integer">,
							</cfif>
							START_DATE = <cfif len(form_start_date)> <cfqueryparam value="#form_start_date#" cfsqltype="cf_sql_timestamp"><cfelseif len(attributes.main_start_date)> <cfqueryparam value="#attributes.main_start_date#" cfsqltype="cf_sql_timestamp"><cfelse>NULL</cfif>,
							FINISH_DATE = <cfif len(form_finish_date)> <cfqueryparam value="#form_finish_date#" cfsqltype="cf_sql_timestamp"><cfelseif len(attributes.main_finish_date)> <cfqueryparam value="#attributes.main_finish_date#" cfsqltype="cf_sql_timestamp"><cfelse>NULL</cfif>,
							EVENT_PLAN_ID = #attributes.visit_id#,
							WARNING_ID = <cfif len(form_warning_id)><cfqueryparam value="#form_warning_id#" cfsqltype="cf_sql_integer"><cfelseif len(attributes.main_warning_id)><cfqueryparam value="#attributes.main_warning_id#" cfsqltype="cf_sql_integer"><cfelse>NULL</cfif>,
                            ASSET_ID=<cfif len(form_asset_id)><cfqueryparam value="#form_asset_id#" cfsqltype="cf_sql_integer"><cfelseif  isdefined("attributes.relation_asset_id") and len(attributes.relation_asset_id)><cfqueryparam value="#attributes.relation_asset_id#" cfsqltype="cf_sql_integer"><cfelse>NULL</cfif>,
                            PROJECT_ID=<cfif len(form_project_id)><cfqueryparam value="#form_project_id#" cfsqltype="cf_sql_integer"><cfelseif  isdefined("attributes.project_id")and len(attributes.project_id)><cfqueryparam value="#attributes.project_id#" cfsqltype="cf_sql_integer"><cfelse>NULL</cfif>
						WHERE
							EVENT_PLAN_ROW_ID = <cfqueryparam value="#form_event_row_ids_value#" cfsqltype="cf_sql_integer">
				</cfquery>
				<cfif len(form_pos_emp_id)>
				  <cfloop from="1" to="#listlen(form_pos_emp_id)#" index="i">
					<cfquery name="ADD_ROW_POS" datasource="#DSN#">
						INSERT INTO
							EVENT_PLAN_ROW_PARTICIPATION_POS
						(
							EVENT_ROW_ID,
							EVENT_POS_ID
						)
						VALUES
						(
							#form_event_row_ids_value#,
							#listgetat(form_pos_emp_id, i, ',')#
						)
					</cfquery>
				  </cfloop>
				</cfif>
			  </cfif>
			<cfelse>
				<cfquery name="ADD_EVENT_PLAN_ROW" datasource="#DSN#">
					INSERT INTO
						EVENT_PLAN_ROW
					(
						BRANCH_ID,
						IS_ACTIVE,
						IS_SALES,
						PLAN_ROW_STATUS,
						COMPANY_ID,
						PARTNER_ID,
						CONSUMER_ID,
						START_DATE,
						FINISH_DATE,
						EVENT_PLAN_ID,
						WARNING_ID,
						RECORD_DATE,
						RECORD_EMP,
						RECORD_IP
					)
					VALUES
					(
						<cfif len(attributes.sales_zones)>#attributes.sales_zones#<cfelse>NULL</cfif>,
						1,
						1,
						0,
						<cfif len(form_company_id) and len(form_company_id)>
							#form_company_id#,
							#form_partner_id#,
							NULL,
						<cfelseif len(form_consumer_id)>
							NULL,
							NULL,
							#form_consumer_id#,
						</cfif>
						<cfif len(form_start_date)>#form_start_date#<cfelseif len(attributes.main_start_date)>#attributes.main_start_date#<cfelse>NULL</cfif>,
						<cfif len(form_finish_date)>#form_finish_date#<cfelseif len(attributes.main_finish_date)>#attributes.main_finish_date#<cfelse>NULL</cfif>,
						#attributes.visit_id#,
						<cfif len(form_warning_id)>#form_warning_id#<cfelse>NULL</cfif>,
						#now()#,
						#session.ep.userid#,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.remote_addr#">
					)
			</cfquery>
			<cfquery name="GET_MAX" datasource="#dsn#">
				SELECT MAX(EVENT_PLAN_ROW_ID) AS  MAX_EVENT_PLAN_ROW_ID FROM EVENT_PLAN_ROW
			</cfquery>
			<cfif len(form_pos_emp_id)>
			  <cfloop from="1" to="#listlen(form_pos_emp_id)#" index="i">
				<cfquery name="ADD_ROW_POS" datasource="#DSN#">
					INSERT INTO
						EVENT_PLAN_ROW_PARTICIPATION_POS
						(
							EVENT_ROW_ID,
							EVENT_POS_ID
						)
						VALUES
						(
							#get_max.max_event_plan_row_id#,
							#listgetat(form_pos_emp_id, i, ',')#
						)
				</cfquery>
			  </cfloop>
			</cfif>
		  </cfif>
		<cfelse>
			<cfset form_event_row_ids = 'attributes.event_row_ids'&i>
			<cfif isdefined("#form_event_row_ids#")>
			  <cfset form_event_row_ids_value = evaluate(form_event_row_ids)>
				  <cfquery name="DEL_ROW" datasource="#dsn#">
					  DELETE FROM EVENT_PLAN_ROW WHERE EVENT_PLAN_ROW_ID = #form_event_row_ids_value#
				  </cfquery>
			</cfif>
		</cfif>
	  </cfloop>
	</cfif>
	<cf_workcube_process 
		is_upd='1' 
		process_stage='#attributes.process_stage#' 
		old_process_line='#attributes.old_process_line#'
		record_member='#session.ep.userid#' 
		record_date='#now()#' 
		action_table='EVENT_PLAN'
		action_column='EVENT_PLAN_ID'
		action_id='#attributes.visit_id#' 
		action_page='#request.self#?fuseaction=sales.list_visit&event=upd&visit_id=#attributes.visit_id#' 
		warning_description='#getLang('','Ziyaret',32364)# : #attributes.visit_id#'>
  </cftransaction>
</cflock>
<script type="text/javascript">
	window.location.href = '<cfoutput>#request.self#</cfoutput>?fuseaction=sales.list_visit&event=upd&visit_id=<cfoutput>#attributes.visit_id#</cfoutput>';
</script>
