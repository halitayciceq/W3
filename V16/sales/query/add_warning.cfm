<cfif len(attributes.main_start_date)><cf_date tarih='attributes.main_start_date'></cfif>
<cfif len(attributes.main_finish_date)><cf_date tarih='attributes.main_finish_date'></cfif>
<cflock name="#CreateUUID()#" timeout="60">
  	<cftransaction>
		<cfquery name="ADD_EVENT_PLAN" datasource="#DSN#" result="MAXID">
			INSERT INTO
				EVENT_PLAN
			(
				EVENT_PLAN_HEAD,
				DETAIL,
				EVENT_STATUS,
				ANALYSE_ID,
				ISPOTANTIAL,
				MAIN_START_DATE,
				MAIN_FINISH_DATE,
				SALES_ZONES,
				IS_ACTIVE,
				IS_SALES,
            <cfif isdefined('attributes.hidden_is_agenda_authorize') and (attributes.hidden_is_agenda_authorize eq 1)>
				VIEW_TO_ALL,
				IS_WIEW_BRANCH,
				IS_WIEW_DEPARTMENT,
                IS_VIEW_COMPANY,
			</cfif>
				RECORD_DATE,
				RECORD_EMP,
				RECORD_IP			
			)
			VALUES
			(
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.warning_head#">,
				<cfif len(attributes.event_detail)><cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.event_detail#"><cfelse>NULL</cfif>,
				#attributes.process_stage#,
				<cfif len(attributes.analyse_head) and len(attributes.analyse_id)>#attributes.analyse_id#<cfelse>NULL</cfif>,
				1,
				<cfif len(attributes.main_start_date)>#attributes.main_start_date#<cfelse>NULL</cfif>,
				<cfif len(attributes.main_finish_date)>#attributes.main_finish_date#<cfelse>NULL</cfif>,
				<cfif len(attributes.sales_zones)>#attributes.sales_zones#<cfelse>NULL</cfif>,
				1,
				1,
           		<cfif isdefined('attributes.hidden_is_agenda_authorize') and (attributes.hidden_is_agenda_authorize eq 1)>
					 <cfif isDefined("attributes.VIEW_TO_ALL")>
						1,
						NULL,
						NULL,
                        NULL,
					  <cfelseif isDefined("attributes.is_wiew_branch")>
						1,
						#attributes.is_wiew_branch#,
						NULL,
                        NULL,
					  <cfelseif isDefined("attributes.is_wiew_department")>
						1,
						#attributes.is_wiew_branch_#,<!--- NULL, --->
						#attributes.is_wiew_department#,
						NULL,
                      <cfelseif isDefined("attributes.is_view_company")>
						1,
						NULL,
						NULL,
                        #attributes.is_view_company#,
					  <cfelse>
						NULL,
						NULL,
						NULL,
                        NULL,
					  </cfif>
			</cfif>
				#now()#,
				#session.ep.userid#,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.remote_addr#">
			)
		</cfquery>
        <cfquery name="GET_MAXID" datasource="#DSN#">
			SELECT MAX(EVENT_PLAN_ID) AS MAX_ID FROM EVENT_PLAN
		</cfquery>
        <cfif isdefined("attributes.agenda_company") and len(attributes.agenda_company)>
        	<cfloop list="#attributes.agenda_company#" index="cc">
                <cfquery name="add_comp" datasource="#dsn#">
                    INSERT INTO EVENT_PLAN_COMPANY
                    (
                        EVENT_PLAN_ID,
                        COMPANY_ID
                    )
                    VALUES
                    (
                        #get_maxid.max_id#,
                        #cc#
                    )
                </cfquery> 
            </cfloop>
        </cfif>
        <cfif len(attributes.record_num) and attributes.record_num neq "">
			<cfloop from="1" to="#attributes.record_num#" index="i">
           		<cfif evaluate("attributes.row_kontrol#i#")>
					<cfscript>
						form_row_kontrol_ = evaluate("attributes.row_kontrol#i#");
		  				if(isdefined('attributes.project_id#i#') and len(evaluate("attributes.project_id#i#")))form_project_id=evaluate("attributes.project_id#i#");else form_project_id="";
		  				if(isdefined('attributes.relation_asset_id#i#') and len(evaluate("attributes.relation_asset_id#i#")))form_asset_id=evaluate("attributes.relation_asset_id#i#");else form_asset_id="";
						form_warning_id = evaluate("attributes.warning_id#i#");
						if(isdefined("attributes.company_id#i#") and len(evaluate("attributes.company_id#i#")))form_company_id = evaluate("attributes.company_id#i#");else form_company_id = "";
						if(isdefined("attributes.partner_id#i#") and len(evaluate("attributes.partner_id#i#")))form_partner_id = evaluate("attributes.partner_id#i#");else form_partner_id = "";
						if(isdefined("attributes.consumer_id#i#") and len(evaluate("attributes.consumer_id#i#")))form_consumer_id = evaluate("attributes.consumer_id#i#");else form_consumer_id = "";
						form_start_date = evaluate("attributes.start_date#i#");
						form_start_clock = evaluate("attributes.start_clock#i#");
						form_start_minute = evaluate("attributes.start_minute#i#");
						form_finish_date = evaluate("attributes.start_date#i#");
						form_finish_clock = evaluate("attributes.finish_clock#i#");
						form_finish_minute = evaluate("attributes.finish_minute#i#");
						form_pos_emp_id = evaluate("attributes.pos_emp_id#i#");
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
					<cfif form_row_kontrol_ eq 1 and (len(form_company_id) or len(form_consumer_id))>
						<cfquery name="ADD_EVENT_PLAN_ROW" datasource="#DSN#">
							INSERT INTO
								EVENT_PLAN_ROW
							(
								BRANCH_ID,
								RECORD_DATE,
								RECORD_EMP,
								RECORD_IP,
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
                                ASSET_ID,
                                PROJECT_ID
							)
							VALUES
							(
								<cfif len(attributes.sales_zones)>#attributes.sales_zones#<cfelse>NULL</cfif>,
								#now()#,
								#session.ep.userid#,
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.remote_addr#">,
								1,
								1,
								0,
								<cfif len(form_company_id) and len(form_partner_id)>
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
								#get_maxid.max_id#,
								<cfif len(form_warning_id)>#form_warning_id#<cfelseif len(attributes.main_warning_id)>#attributes.main_warning_id#<cfelse>NULL</cfif>,
                                <cfif len(form_asset_id)>#form_asset_id#<cfelseif  isdefined("attributes.relation_asset_id") and len(attributes.relation_asset_id)>#attributes.relation_asset_id#<cfelse>NULL</cfif>,
                                <cfif len(form_project_id)>#form_project_id#<cfelseif  isdefined("attributes.project_id") and len(attributes.project_id)>#attributes.project_id#<cfelse>NULL</cfif>
							)
						</cfquery>
						<cfquery name="GET_MAXROW_ID" datasource="#DSN#">
							SELECT MAX(EVENT_PLAN_ROW_ID) AS MAX_ID FROM EVENT_PLAN_ROW
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
										#get_maxrow_id.max_id#,
										#listgetat(form_pos_emp_id, i, ',')#
									)
								</cfquery>
							</cfloop>
						</cfif>
					</cfif>
				</cfif>
			</cfloop>
		</cfif>
		<cfset visit_id = get_maxid.max_id>
		<cf_workcube_process 
			is_upd='1'
			data_source='#dsn#'
			old_process_line='0'
			process_stage='#attributes.process_stage#' 
			record_member='#session.ep.userid#' 
			record_date='#now()#'
			action_table='EVENT_PLAN'
			action_column='EVENT_PLAN_ID'
			action_id='#get_maxid.max_id#'
			action_page='#request.self#?fuseaction=sales.list_visit&event=upd&visit_id=#get_maxid.max_id#' 
			warning_description='#getLang('','Ziyaret Planı',58422)# : #get_maxid.max_id#'>
  	</cftransaction>
</cflock>
<cfset attributes.actionId = MAXID.IdentityCol>
<script type="text/javascript">
	window.location.href = '<cfoutput>#request.self#</cfoutput>?fuseaction=sales.list_visit&event=upd&visit_id=<cfoutput>#MAXID.IdentityCol#</cfoutput>';
</script>
