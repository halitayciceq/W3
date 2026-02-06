<cf_xml_page_edit fuseact="sales.form_add_opportunity">
<cfif form.active_company neq session.ep.company_id>
	<script type="text/javascript">
		alert("İşlemin Muhasebe Dönemi İle Aktif Muhasebe Döneminiz Farklı. Muhasebe Döneminizi Kontrol Ediniz !");
		window.location.href='<cfoutput>#request.self#?fuseaction=sales.list_order</cfoutput>';
	</script>
	<cfabort>
</cfif>
<cfif len(attributes.opp_date)><cf_date tarih="attributes.opp_date"></cfif>
<cfif isdefined("attributes.opp_invoice_date") and  len(attributes.opp_invoice_date)><cf_date tarih="attributes.opp_invoice_date"></cfif>
<cfif isdefined("attributes.action_date") and  len(attributes.action_date)><cf_date tarih="attributes.action_date"></cfif>
<cfset attributes.sales_team_id = ''>
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
            CONSUMER_ID = #attributes.member_id#
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
<cfscript>
	if(isdefined("to_par_ids")) CC_PARS = ListSort(to_par_ids,"Numeric", "Desc"); else CC_PARS = "";
	if(isdefined("to_pos_ids")) CC_POS = ListSort(to_pos_ids,"Numeric", "Desc"); else CC_POS = "";
	if(isdefined("to_cons_ids")) CC_CONS = ListSort(to_cons_ids,"Numeric", "Desc"); else CC_CONS ='';
	if(isdefined("to_grp_ids")) CC_GRPS = ListSort(to_grp_ids,"Numeric", "Desc") ; else CC_GRPS ='';
</cfscript>

<cflock name="#CREATEUUID()#" timeout="60">
	<cftransaction>
		<cfquery name="UPD_OPPORTUNITY" datasource="#DSN3#">
			UPDATE
				OPPORTUNITIES
			SET
				OPPORTUNITY_TYPE_ID = <cfif len(attributes.opportunity_type_id)>#attributes.opportunity_type_id#<cfelse>NULL</cfif>,
			<cfif attributes.member_type is 'partner'>
				PARTNER_ID = #attributes.member_id#,
				COMPANY_ID = #attributes.company_id#,
				CONSUMER_ID = NULL,
			<cfelseif attributes.member_type is 'consumer'>
				PARTNER_ID = NULL,
				COMPANY_ID = NULL,
				CONSUMER_ID = #attributes.member_id#,
			</cfif>
			<cfif isdefined("attributes.ref_member_type") and attributes.ref_member_type is 'partner' and len(attributes.ref_member)>
				REF_PARTNER_ID = #attributes.ref_partner_id#,
				REF_COMPANY_ID = #attributes.ref_company_id#,
				REF_CONSUMER_ID = NULL,
				REF_EMPLOYEE_ID = NULL,
			<cfelseif isdefined("attributes.ref_member_type") and attributes.ref_member_type is 'consumer' and len(attributes.ref_member)>
				REF_PARTNER_ID = NULL,
				REF_COMPANY_ID = NULL,
				REF_CONSUMER_ID = #attributes.ref_consumer_id#,
				REF_EMPLOYEE_ID = NULL,
			<cfelseif isdefined("attributes.ref_member_type") and attributes.ref_member_type is 'employee' and len(attributes.ref_member)>
				REF_PARTNER_ID = NULL,
				REF_COMPANY_ID = NULL,
				REF_CONSUMER_ID = NULL,
				REF_EMPLOYEE_ID = #attributes.ref_employee_id#,
			<cfelse>
				REF_PARTNER_ID = NULL,
				REF_COMPANY_ID = NULL,
				REF_CONSUMER_ID = NULL,
				REF_EMPLOYEE_ID = NULL,
			</cfif>
				OPP_STAGE = <cfif isdefined("attributes.process_stage")>#attributes.process_stage#,<cfelse>NULL,</cfif>		
				COMMETHOD_ID = <cfif len(attributes.commethod_id)>#attributes.commethod_id#<cfelse>NULL</cfif>,
				PRODUCT_CAT_ID = <cfif isdefined("attributes.product_cat_id") and  len(attributes.product_cat_id)>#attributes.product_cat_id#<cfelse>NULL</cfif>,
				OPP_DETAIL = <cfif len(attributes.opp_detail)><cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.opp_detail#"><cfelse>NULL</cfif>,
				INCOME = <cfif len(attributes.income)>#attributes.income#<cfelse>NULL</cfif>,
				MONEY = <cfif len(attributes.money) and len(attributes.income)><cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.money#"><cfelse>NULL</cfif>,
				COST = <cfif len(attributes.cost)>#attributes.cost#<cfelse>NULL</cfif>,
				MONEY2 = <cfif len(attributes.money2) and len(attributes.cost)><cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.money2#"><cfelse>NULL</cfif>,
				STOCK_ID = <cfif isdefined("attributes.stock_id") and len(attributes.stock_id) and len(attributes.stock_name)>#attributes.stock_id#<cfelse>NULL</cfif>,
				SALES_TEAM_ID = <cfif len(attributes.sales_team_id)>#attributes.sales_team_id#<cfelse>NULL</cfif>,
				SALES_EMP_ID = <cfif len(attributes.sales_emp_id) and len(attributes.sales_emp)>#attributes.sales_emp_id#<cfelse>NULL</cfif>,
				SALES_PARTNER_ID = <cfif isdefined("attributes.sales_member") and len(attributes.sales_member) and len(attributes.sales_member_id) and len(attributes.sales_member_type) and attributes.sales_member_type eq 'partner'>#attributes.sales_member_id#<cfelse>NULL</cfif>,
				SALES_CONSUMER_ID = <cfif isdefined("attributes.sales_member") and len(attributes.sales_member) and len(attributes.sales_member_id) and len(attributes.sales_member_type) and attributes.sales_member_type eq 'consumer'>#attributes.sales_member_id#<cfelse>NULL</cfif>,
				OPP_DATE = <cfif len(attributes.opp_date)>#attributes.opp_date#<cfelse>NULL</cfif>,
				INVOICE_DATE = <cfif isdefined("attributes.opp_invoice_date") and  len(attributes.opp_invoice_date)>#attributes.opp_invoice_date#<cfelse>NULL</cfif>,
				ACTION_DATE = <cfif isdefined("attributes.action_date") and len(attributes.action_date)>#attributes.action_date#<cfelse>NULL</cfif>,
				OPP_CURRENCY_ID = <cfif len(attributes.opp_currency_id)>#attributes.opp_currency_id#<cfelse>NULL</cfif>,
				OPP_STATUS = <cfif isDefined("attributes.opp_status")>1<cfelse>0</cfif>,
				ACTIVITY_TIME = <cfif isdefined("attributes.activity_time") and len(attributes.activity_time)>#attributes.activity_time#<cfelse>NULL</cfif>,
				PROBABILITY = <cfif len(attributes.probability)>#attributes.probability#<cfelse>NULL</cfif>,
				OPP_HEAD = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.opp_head#">,
				OPP_ZONE = 0,
				PROJECT_ID = <cfif len(attributes.project_id) and len(attributes.project_head)>#attributes.project_id#<cfelse>NULL</cfif>,
				OPP_NO = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.opportunity_no#">,
				CC_GRP_IDS = <cfif len(CC_GRPS)><cfqueryparam cfsqltype="cf_sql_varchar" value="#CC_GRPS#"><cfelse>NULL</cfif>,
				CC_CON_IDS = <cfif len(CC_CONS)><cfqueryparam cfsqltype="cf_sql_varchar" value="#CC_CONS#"><cfelse>NULL</cfif>,
				CC_PAR_IDS = <cfif len(CC_PARS)><cfqueryparam cfsqltype="cf_sql_varchar" value="#CC_PARS#"><cfelse>NULL</cfif>,
				CC_POSITIONS = <cfif len(CC_POS)><cfqueryparam cfsqltype="cf_sql_varchar" value="#CC_POS#"><cfelse>NULL</cfif>,
				SALE_ADD_OPTION_ID = <cfif len(attributes.sales_add_option)>#attributes.sales_add_option#<cfelse>NULL</cfif>,
				PREFERENCE_REASON_ID = <cfif isdefined("attributes.rival_preference_reason") and len(attributes.rival_preference_reason)><cfqueryparam cfsqltype="cf_sql_varchar" value=",#attributes.rival_preference_reason#,"><cfelse>NULL</cfif>,
				RIVAL_PARTNER_ID = <cfif len(attributes.rival_partner_id) and len(attributes.rival_company)>#attributes.rival_partner_id#<cfelse>NULL</cfif>,
				RIVAL_COMPANY_ID = <cfif len(attributes.rival_company_id) and len(attributes.rival_company)>#attributes.rival_company_id#<cfelse>NULL</cfif>,
				CAMPAIGN_ID = <cfif isdefined('attributes.camp_name') and len(attributes.camp_name) and isdefined('attributes.camp_id') and Len(attributes.camp_id)>#attributes.camp_id#<cfelse>NULL</cfif>,
				COUNTRY_ID=<cfif isdefined("attributes.country_id1") and len(attributes.country_id1)>#attributes.country_id1#<cfelseif isdefined("get_country") and len(get_country.country_id)>#get_country.country_id#<cfelse>NULL</cfif>,
                SZ_ID=<cfif isdefined("attributes.sales_zone_id") and len(attributes.sales_zone_id)>#attributes.sales_zone_id#<cfelseif isdefined("get_country") and len(get_country.sales_id)>#get_country.sales_id#<cfelse>NULL</cfif>,
                UPDATE_EMP = #session.ep.userid#,
				UPDATE_IP = <cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.remote_addr#">,
				UPDATE_DATE = #now()#,
				ADD_RSS = <cfif isdefined('form.add_rss') and len(form.add_rss)>1<cfelse>0</cfif>,
				PROCESS_CAT = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.process_cat#">
			WHERE
				OPP_ID = #attributes.opp_id#
		</cfquery>
		<!--- History --->
		<cfinclude template="add_opportunity_history.cfm">
		<!--- // History --->

		<!--- Fırsata ait cari degistigi an onceki cari ile iliskiyi kesmek gerekli. Analiz sonucu ve sonuc detayları direkt silinir. BK 20090112 --->
		<cfif (attributes.old_company_id neq attributes.company_id) and (attributes.old_member_id neq attributes.member_id)>
			<cfquery name="DEL_ANALYSIS_RESULTS_DETAILS" datasource="#DSN3#">
				DELETE FROM #dsn_alias#.MEMBER_ANALYSIS_RESULTS_DETAILS WHERE RESULT_ID IN (SELECT RESULT_ID FROM #dsn_alias#.MEMBER_ANALYSIS_RESULTS WHERE OPPORTUNITY_ID = #attributes.opp_id# AND OUR_COMPANY_ID = #session.ep.company_id#)
			</cfquery>
			<cfquery name="DEL_ANALYSIS_RESULTS_DETAILS" datasource="#DSN3#">
				DELETE FROM #dsn_alias#.MEMBER_ANALYSIS_RESULTS WHERE OPPORTUNITY_ID = #attributes.opp_id# AND OUR_COMPANY_ID = #session.ep.company_id#
			</cfquery>
		</cfif>
		<cfif xml_is_opportunity_actions_update eq 1 and len(attributes.project_id) and len(attributes.project_head)>
			<cfquery name="upd_works" datasource="#dsn3#">
				UPDATE
					#dsn_alias#.PRO_WORKS
				SET
					PROJECT_ID = #attributes.project_id#
				WHERE
					OPPORTUNITY_ID = #attributes.opp_id#
			</cfquery>
			<cfquery name="upd_events" datasource="#dsn3#">
				UPDATE
					#dsn_alias#.EVENT
				SET
					PROJECT_ID = #attributes.project_id#
				WHERE
					EVENT_ID IN 
						(
						SELECT
							EVENT_ID
						FROM
							#dsn_alias#.EVENTS_RELATED ER
						WHERE
							ER.ACTION_ID = #attributes.opp_id# AND
							ER.ACTION_SECTION = <cfqueryparam cfsqltype="cf_sql_varchar" value="OPPORTUNITY_ID"> AND
							ER.COMPANY_ID = #session.ep.company_id#
						)
			</cfquery>
			<cfquery name="upd_offers" datasource="#dsn3#">
				UPDATE
					OFFER
				SET
					PROJECT_ID = #attributes.project_id#
				WHERE
					OPP_ID = #attributes.opp_id#
			</cfquery>
		</cfif>
	</cftransaction>
</cflock>
<!---Ek Bilgiler--->
<cfset attributes.info_id =  attributes.opp_id>
<cfset attributes.is_upd = 1>
<cfset attributes.info_type_id = -16>
<cfinclude template="../../objects/query/add_info_plus2.cfm">
<!---Ek Bilgiler--->

<cf_workcube_process 
	is_upd='1' 
	data_source='#dsn3#' 
	process_stage='#attributes.process_stage#' 
	old_process_line='#attributes.old_process_line#'
	record_member='#session.ep.userid#'
	record_date='#now()#'
	action_table='OPPORTUNITIES'
	action_column='OPP_ID'
	action_id='#form.opp_id#' 
	action_page='#request.self#?fuseaction=sales.list_opportunity&event=det&opp_id=#form.opp_id#' 
	warning_description='#getLang('','Fırsat',57612)# : #GET_OPPORTUNITY.OPP_NO#'>
    <cfset attributes.actionId =attributes.opp_id>
<!--- <cfinclude template="../display/rss_opportunities.cfm"> kim kullanıyor neden kullanılıyor dönüş yapan olursa bakılabilir sm 20121120--->
<script type="text/javascript">
	window.location.href = '<cfoutput>#request.self#?fuseaction=sales.list_opportunity&event=det&opp_id=#opp_id#</Cfoutput>';
</script>