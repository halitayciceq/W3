<cf_papers paper_type="OPPORTUNITY">
<cfset system_paper_no = paper_code & '-' & paper_number>
<cfset system_paper_no_add = paper_number>
<cfif len(attributes.opp_date)><cf_date tarih="attributes.opp_date"></cfif>
<cfif isdefined("attributes.opp_invoice_date") and  len(attributes.opp_invoice_date)><cf_date tarih="attributes.opp_invoice_date"></cfif>
<cfif isdefined("attributes.action_date") and  len(attributes.action_date)><cf_date tarih="attributes.action_date"></cfif>
<cfset attributes.sales_team_id = ''>
<cf_xml_page_edit fuseact="sales.form_add_opportunity">
<cfquery name="get_country" datasource="#dsn#">
    <cfif isdefined("attributes.member_type") and attributes.member_type is 'partner'>
        SELECT 
            COUNTRY COUNTRY_ID,
            SALES_COUNTY SALES_ID
        FROM 
            COMPANY 
        WHERE 
            COMPANY_ID = #attributes.company_id#
    <cfelseif isdefined("attributes.member_type") and attributes.member_type is 'consumer'>
        SELECT 
            SALES_COUNTY SALES_ID,
            TAX_COUNTRY_ID COUNTRY_ID
        FROM 
            CONSUMER 
        WHERE 
            CONSUMER_ID=#attributes.member_id#
    </cfif>
</cfquery>
<cfif len(attributes.sales_emp_id) and len(attributes.company_id)>
	<cfquery name="get_sales_team" datasource="#dsn#">
		SELECT
			SZT.TEAM_ID
		FROM
			COMPANY C,
			SALES_ZONES_TEAM SZT,
			SALES_ZONES_TEAM_ROLES SZTR
		WHERE
			C.SALES_COUNTY = SZT.SALES_ZONES AND
			SZT.TEAM_ID = SZTR.TEAM_ID AND
			C.COMPANY_ID = #attributes.company_id# AND
			SZTR.POSITION_CODE IN (SELECT POSITION_CODE FROM EMPLOYEE_POSITIONS WHERE EMPLOYEE_ID = #attributes.sales_emp_id#)
	</cfquery>
	<cfset attributes.sales_team_id = get_sales_team.team_id>
</cfif>
<cflock name="#CREATEUUID()#" timeout="20">
	<cftransaction>
		<cfquery name="ADD_OPPORTUNITY" datasource="#DSN3#" result="MAX_ID">
			INSERT INTO
				OPPORTUNITIES
				(
				OPPORTUNITY_TYPE_ID,
				<cfif attributes.member_type is 'partner'>
					PARTNER_ID,
					COMPANY_ID,	
				<cfelseif attributes.member_type is 'consumer'>
					CONSUMER_ID,
				</cfif>
				<cfif isdefined("attributes.ref_member_type") and attributes.ref_member_type is 'partner'>
					REF_PARTNER_ID,
					REF_COMPANY_ID,				
				<cfelseif isdefined("attributes.ref_member_type") and attributes.ref_member_type is 'consumer'>
					REF_CONSUMER_ID,
				<cfelseif isdefined("attributes.ref_member_type") and attributes.ref_member_type is 'employee'>
					REF_EMPLOYEE_ID,
				<cfelse>
					REF_PARTNER_ID,
					REF_COMPANY_ID,
					REF_CONSUMER_ID,
					REF_EMPLOYEE_ID,
				</cfif>
				OPP_STAGE,
				COMMETHOD_ID,
				PRODUCT_CAT_ID,
				OPP_DETAIL,
				INCOME,
				MONEY,
				COST,
				MONEY2,
				STOCK_ID,
				SALES_TEAM_ID,
				SALES_EMP_ID,
				SALES_PARTNER_ID,
				SALES_CONSUMER_ID,
				OPP_DATE,
				INVOICE_DATE,
				ACTION_DATE,
				OPP_CURRENCY_ID,
				OPP_STATUS,
				ACTIVITY_TIME,
				PROBABILITY,
				OPP_HEAD,
				OPP_ZONE,
				PROJECT_ID,
				OPP_NO,
				SALE_ADD_OPTION_ID,
				SERVICE_ID,
				CUS_HELP_ID,
				CAMPAIGN_ID,
				RECORD_EMP,
				RECORD_IP,
				RECORD_DATE,
				ADD_RSS,
                COUNTRY_ID,
                SZ_ID,
                EVENT_PLAN_ROW_ID,
                PROCESS_CAT
				)
			VALUES
				(
				<cfif len(attributes.opportunity_type_id)>#attributes.opportunity_type_id#<cfelse>NULL</cfif>,
				<cfif attributes.member_type is 'partner'>
					#attributes.member_id#,
					#attributes.company_id#,					
				<cfelseif attributes.member_type is 'consumer'>
					#attributes.member_id#,
				</cfif>
				<cfif isdefined("attributes.ref_member_type") and attributes.ref_member_type is 'partner'>
					#attributes.ref_partner_id#,
					#attributes.ref_company_id#,					
				<cfelseif isdefined("attributes.ref_member_type") and attributes.ref_member_type is 'consumer'>
					#attributes.ref_consumer_id#,
				<cfelseif isdefined("attributes.ref_member_type") and attributes.ref_member_type is 'employee'>
					#attributes.ref_employee_id#,
				<cfelse>
					NULL,
					NULL,
					NULL,
					NULL,				
				</cfif>
				#attributes.process_stage#,
				<cfif len(attributes.commethod_id)>#attributes.commethod_id#<cfelse>NULL</cfif>,
				<cfif isdefined("attributes.product_cat_id") and  len(attributes.product_cat_id)>#attributes.product_cat_id#<cfelse>NULL</cfif>,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.opp_detail#">,
				<cfif len(attributes.income)>#attributes.income#<cfelse>NULL</cfif>,
				<cfif len(attributes.money) and len(attributes.income)><cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.money#"><cfelse>NULL</cfif>,
				<cfif len(attributes.cost)>#attributes.cost#<cfelse>NULL</cfif>,
				<cfif len(attributes.money2) and len(attributes.cost)><cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.money2#"><cfelse>NULL</cfif>,
				<cfif isdefined("attributes.stock_id") and len(attributes.stock_id)>#attributes.stock_id#<cfelse>NULL</cfif>,
				<cfif len(attributes.sales_team_id)>#attributes.sales_team_id#<cfelse>NULL</cfif>,
				<cfif len(attributes.sales_emp_id)>#attributes.sales_emp_id#<cfelse>NULL</cfif>,
				<cfif isdefined("attributes.sales_member_id") and  len(attributes.sales_member_id) and len(attributes.sales_member) and attributes.sales_member_type is 'partner'>
					#attributes.sales_member_id#,
					NULL,
				<cfelseif isdefined("attributes.sales_member_id") and len(attributes.sales_member_id) and len(attributes.sales_member) and attributes.sales_member_type is 'consumer'>
					NULL,
					#attributes.sales_consumer_id#,
				<cfelse>
					NULL,
					NULL,
				</cfif>
				<cfif len(attributes.opp_date)>#attributes.opp_date#<cfelse>NULL</cfif>,
				<cfif isdefined("attributes.opp_invoice_date") and  len(attributes.opp_invoice_date)>#attributes.opp_invoice_date#<cfelse>NULL</cfif>,
				<cfif isdefined("attributes.action_date") and len(attributes.action_date)>#attributes.action_date#<cfelse>NULL</cfif>,
				<cfif len(attributes.opp_currency_id)>#attributes.opp_currency_id#<cfelse>NULL</cfif>,
				1,
				<cfif isdefined("attributes.activity_time") and len(attributes.activity_time)>#attributes.activity_time#<cfelse>NULL</cfif>,
				<cfif len(attributes.probability)>#attributes.probability#<cfelse>NULL</cfif>,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.opp_head#">,
				0,
				<cfif len(attributes.project_id)>#attributes.project_id#<cfelse>NULL</cfif>,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#system_paper_no#">,
				<cfif len(attributes.sales_add_option)>#attributes.sales_add_option#<cfelse>NULL</cfif>,
				<cfif len(attributes.service_id)>#attributes.service_id#<cfelse>NULL</cfif>,
				<cfif isdefined('attributes.cus_help_id') and len(attributes.cus_help_id)>#attributes.cus_help_id#<cfelse>NULL</cfif>,
				<cfif isdefined('attributes.camp_name') and len(attributes.camp_name) and isdefined('attributes.camp_id') and Len(attributes.camp_id)>#attributes.camp_id#<cfelse>NULL</cfif>,
				#session.ep.userid#,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.remote_addr#">,
				#now()#,
				<cfif isdefined('form.add_rss') and len(form.add_rss)>1<cfelse>0</cfif>,
                <cfif isdefined('attributes.country_id') and len(attributes.country_id)>#attributes.country_id#<cfelseif isdefined("get_country") and len(get_country.country_id)>#get_country.country_id#<cfelse>NULL</cfif>,
                <cfif isdefined('attributes.sales_zone_id') and len(attributes.sales_zone_id)>#attributes.sales_zone_id#<cfelseif isdefined("get_country") and len(get_country.sales_id)>#get_country.sales_id#<cfelse>NULL</cfif>,
                <cfif isdefined('attributes.event_plan_row_id') and len(attributes.event_plan_row_id)>#event_plan_row_id#<cfelse>NULL</cfif>,
                <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.process_cat#">
               )
       </cfquery>
       <cfquery name="UPD_GEN_PAP" datasource="#DSN3#">
			UPDATE
				GENERAL_PAPERS
			SET
				OPPORTUNITY_NUMBER = #system_paper_no_add#
			WHERE
				OPPORTUNITY_NUMBER IS NOT NULL
		</cfquery>		
	</cftransaction>
</cflock>
<cf_workcube_process 
        is_upd='1' 
        data_source='#dsn3#' 
        old_process_line='0'
        process_stage='#attributes.process_stage#' 
        record_member='#session.ep.userid#'
        record_date='#now()#' 
        action_table='OPPORTUNITIES'
        action_column='OPP_ID'
        action_id='#MAX_ID.IDENTITYCOL#'
        action_page='#request.self#?fuseaction=sales.list_opportunity&event=det&opp_id=#MAX_ID.IDENTITYCOL#' 
        warning_description='#getLang('','Fırsat',57612)# : #system_paper_no#'>
        <!--- 
        company_id='#attributes.company_id#'
        warning_head=' #attributes.opp_head#'
        warning_member=' #attributes.company#'
         --->
<!--- ziyaret planından fırsat ekleme işlemi yapılacaksa.--->
<cfif isdefined('attributes.event_id') and len(attributes.event_id)>
	<cfquery name="get_events" datasource="#dsn#">
    	SELECT EVENT_PLAN_HEAD,DETAIL,EVENT_STATUS,VIEW_TO_ALL,IS_WIEW_BRANCH,IS_WIEW_DEPARTMENT FROM EVENT_PLAN WHERE EVENT_PLAN_ID=#attributes.event_id#
    </cfquery>
    <cfquery name="get_row_events" datasource="#dsn#">
    	SELECT START_DATE,FINISH_DATE,ASSET_ID,CONSUMER_ID,PARTNER_ID,PROJECT_ID FROM EVENT_PLAN_ROW  WHERE  EVENT_PLAN_ROW_ID=#attributes.plan_rowid#
    </cfquery>
    <cfquery name="get_row_pos" datasource="#dsn#">
        SELECT
            EPP.EVENT_POS_ID AS POS_ID
         FROM
            EVENT_PLAN_ROW_PARTICIPATION_POS EPP
        WHERE
          	EPP.EVENT_ROW_ID = #attributes.plan_rowid#
    </cfquery>
	<cfquery name="relation_events" datasource="#dsn#">
        INSERT INTO
            EVENT
            (
            	EVENT_STAGE,
                EVENTCAT_ID,
                STARTDATE,
                FINISHDATE, 
                EVENT_HEAD,
                EVENT_DETAIL,
             	EVENT_PLACE_ID,
               	OPP_ID,
                EVENT_TO_POS,
                EVENT_TO_PAR,
                EVENT_TO_CON,
                VIEW_TO_ALL,
                IS_WIEW_BRANCH,
                IS_WIEW_DEPARTMENT,
                PROJECT_ID,
                <cfif isDefined("session.agenda_userid")>
					<cfif session.agenda_user_type is "p">
                     RECORD_PAR,
                    <cfelseif session.agenda_user_type is "e">
                    RECORD_EMP,
                    </cfif>
                <cfelse> 
					<cfif isdefined("session.ep.userid")>
                    RECORD_EMP,
                    <cfelseif isdefined("session.pp.userid")>
                    RECORD_PAR,
                    </cfif>
                </cfif>
                <cfif isdefined("validator") and len(VALIDATOR)>
					<cfif isdefined("validator_type") and len(validator_type)>
                        <cfif validator_type eq "employee" or validator_type eq "e">
                            VALIDATOR_POSITION_CODE,
                        <cfelseif validator_type eq "partner" or validator_type eq "p">
                            VALIDATOR_PAR,
                        </cfif>
                    </cfif>
                <cfelse>
					<cfif isDefined("session.agenda_userid")> <!--- Baskasinda --->
						<cfif session.agenda_user_type is "e"> 
                            VALID_EMP,
                            VALID,
                            VALID_DATE,
                        <cfelseif session.agenda_user_type is "p"> 
                            VALID_PAR_ID,
                            VALID_PAR,
                            VALID_PAR_DATE,
                        </cfif>
                	<cfelse>
						<cfif isdefined("session.ep.userid")>
                            VALID_EMP,
                            VALID,
                            VALID_DATE,
                        <cfelseif isdefined("session.pp.userid")>
                            VALID_PAR_ID,
                            VALID_PAR,
                            VALID_PAR_DATE,
                        </cfif>
                	</cfif>
                </cfif>
            	 RECORD_IP,
                 RECORD_DATE
            )
            VALUES
            (
            	<cfif len(get_events.event_status)>#get_events.event_status#<cfelse>NULL</cfif>,
				9,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#get_row_events.start_date#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#get_row_events.finish_date#">,
                <cfif len(get_events.event_plan_head)><cfqueryparam cfsqltype="cf_sql_varchar" value="#get_events.event_plan_head#"><cfelse>NULL</cfif>,
                <cfif len(get_events.detail)><cfqueryparam cfsqltype="cf_sql_varchar" value="#get_events.detail#"><cfelse>NULL</cfif>,
                2,
                #MAX_ID.IDENTITYCOL#,
                <cfif len(get_row_pos.pos_id)><cfqueryparam cfsqltype="cf_sql_varchar" value="#get_row_pos.pos_id#"><cfelse>NULL</cfif>,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#get_row_events.partner_id#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#get_row_events.consumer_id#">,
               	<cfif len(get_events.view_to_all)>#get_events.view_to_all#<cfelse>NULL</cfif>,
                <cfif len(get_events.is_wiew_branch)>#get_events.is_wiew_branch#<cfelse>NULL</cfif>,
                <cfif len(get_events.is_wiew_department)>#get_events.is_wiew_department#<cfelse>NULL</cfif>,
                <cfif len(get_row_events.project_id)>#get_row_events.project_id#<cfelse>NULL</cfif>,
				<cfif isDefined("session.agenda_userid")><!--- Baskasinda --->
                    #session.agenda_userid#,
                <cfelse><!--- Kendinde --->
                    <cfif isdefined("session.ep.userid")>
                        #session.ep.userid#,
                    <cfelseif isdefined("session.pp.userid")>
                        #session.pp.userid#,
                    </cfif>
                </cfif>
                <cfif isdefined("VALIDATOR") and len(VALIDATOR)>
                    <cfif isdefined("validator_type") and len(validator_type)>
                        #VALIDATOR_ID#,
                    </cfif>
                <cfelse>
                    <cfif isDefined("session.agenda_userid")><!--- Baskasinda --->
                        #session.agenda_userid#,
                        1,
                        #now()#,
                    <cfelse><!--- Kendinde --->
						<cfif isdefined("session.EP.userid")>
                       		#session.ep.userid#,
                        <cfelseif isdefined("session.pp.userid")>
                       		#session.pp.userid#,
                        </cfif>
                        1,
                        #now()#,
                    </cfif>
                </cfif>
                <cfif isDefined("LINK_ID")>
                    #LINK_ID#,
                </cfif>
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.remote_addr#">,
                 #now()#
            )
            SELECT @@IDENTITY AS MAX_EVENT_ID
        </cfquery>
        <cfquery name="INS_OFFER_PLUS" datasource="#dsn#">
            INSERT INTO
                EVENTS_RELATED
            (
                ACTION_ID,
                ACTION_SECTION,
                EVENT_ID,
                COMPANY_ID		
            )
            VALUES
            (
                #MAX_ID.IDENTITYCOL#,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="OPPORTUNITY_ID">,
                #relation_events.max_event_id#,
              <cfif isdefined("session.ep.company_id")>
                #session.ep.company_id#
              <cfelse>
                #session.pp.our_company_id#
              </cfif>
            )	
        </cfquery>
</cfif>
<!---Ek Bilgiler--->
<cfset attributes.info_id = max_id.IDENTITYCOL>
<cfset attributes.is_upd = 0>
<cfset attributes.info_type_id = -16>
<cfinclude template="../../objects/query/add_info_plus2.cfm">
<!---Ek Bilgiler--->

<cfif attributes.is_popup eq 0 >
<script type="text/javascript">
	window.location.href = '<cfoutput>#request.self#?fuseaction=sales.list_opportunity&event=det&opp_id=#MAX_ID.IDENTITYCOL#</Cfoutput>';
</script>
<cfelseif attributes.is_popup eq 1 >
	<script type="text/javascript">
		window.close();
	</script>
</cfif>
