<!---
    Fatma Zehra Dere
    Create : 08102023
    Desc : Datagate.cfc üzerinden fırsat işlemleri fonksiyonları yer alır
--->

<cfcomponent extends="cfc.sdFunctions">
    <cfset dsn = dsn_alias = application.systemParam.systemParam().dsn />
    <cfset dsn1 = dsn_product = dsn1_alias = '#dsn#_product' />
    <cfset dsn2 = dsn2_alias = '#dsn#_#session.ep.period_year#_#session.ep.company_id#' />
	<cfset dsn3 = dsn3_alias = '#dsn#_#session.ep.company_id#' />
    <cfset index_folder = application.systemParam.systemParam().index_folder >
    <cfset dir_seperator = application.systemParam.systemParam().dir_seperator>
    <cfset request.self = application.systemParam.systemParam().request.self />
    <cfset fusebox.process_tree_control = application.systemParam.systemParam().fusebox.process_tree_control>
    <cfset WFunctions = createObject("component","WMO.functions") />
    <cfset filterNum = WFunctions.filterNum>
    <cfif (isdefined("session.ep") and isDefined("session.ep.userid"))>
		<cfset session_base.money = session.ep.money>
		<cfset session_base.money2 = session.ep.money2>
		<cfset session_base.userid = session.ep.userid>
		<cfset session_base.company_id = session.ep.company_id>
		<cfset session_base.period_id = session.ep.period_id>
	</cfif>
    <cfset MMFunctions = createObject("component","cfc.mmFunctions") />
    <cfset wrk_eval = WFunctions.wrk_eval>
    <cfset workcube_query = WFunctions.workcube_query >
    <cfset get_emp_info = WFunctions.get_emp_info>
    <cfset specer = MMFunctions.specer>
    <cfset GetProductConf = MMFunctions.GetProductConf>
    <cfset _get_subs_ = MMFunctions._get_subs_>
    <cfset wrk_round = WFunctions.wrk_round>
    <cfset getlang = WFunctions.getlang>
    <cffunction name="add" access="public" output="false"  hint="Fırsat Ekleme">
        <cfset attributes = arguments>
        <cfset form = arguments>
        <cfset responseStruct = structNew()>
        <cf_papers paper_type="OPPORTUNITY">
        <cf_get_lang_set module_name="sales">
        <cfset system_paper_no = paper_code & '-' & paper_number>
        <cfset system_paper_no_add = paper_number>
        <cfif len(arguments.opp_date)><cf_date tarih="arguments.opp_date"></cfif>
        <cfif isdefined("arguments.opp_invoice_date") and  len(arguments.opp_invoice_date)><cf_date tarih="arguments.opp_invoice_date"></cfif>
        <cfif isdefined("arguments.action_date") and  len(arguments.action_date)><cf_date tarih="arguments.action_date"></cfif>
        <cfset arguments.sales_team_id = ''>
        <cf_xml_page_edit fuseact="sales.form_add_opportunity">
        <cfquery name="get_country" datasource="#dsn#">
            <cfif isdefined("arguments.member_type") and arguments.member_type is 'partner'>
                SELECT 
                    COUNTRY COUNTRY_ID,
                    SALES_COUNTY SALES_ID
                FROM 
                    COMPANY 
                WHERE 
                    COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.company_id#">
            <cfelseif isdefined("arguments.member_type") and arguments.member_type is 'consumer'>
                SELECT 
                    SALES_COUNTY SALES_ID,
                    TAX_COUNTRY_ID COUNTRY_ID
                FROM 
                    CONSUMER 
                WHERE 
                    CONSUMER_ID=<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.member_id#">
            </cfif>
        </cfquery>
            <cfif len(arguments.sales_emp_id) and len(arguments.company_id)>
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
                    C.COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.company_id#"> AND
                    SZTR.POSITION_CODE IN (SELECT POSITION_CODE FROM EMPLOYEE_POSITIONS WHERE EMPLOYEE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.sales_emp_id#">)
            </cfquery>
            <cfset arguments.sales_team_id = get_sales_team.team_id>
        </cfif>
    
        <cftransaction>
            <cftry>
                <cfquery name="ADD_OPPORTUNITY" datasource="#dsn3#" result="MAX_ID">
                    INSERT INTO
                    OPPORTUNITIES
                        (
                            OPPORTUNITY_TYPE_ID,
                            <cfif arguments.member_type is 'partner'>
                                PARTNER_ID,
                                COMPANY_ID,	
                            <cfelseif arguments.member_type is 'consumer'>
                                CONSUMER_ID,
                            </cfif>
                            <cfif isdefined("arguments.ref_member_type") and arguments.ref_member_type is 'partner'>
                                REF_PARTNER_ID,
                                REF_COMPANY_ID,				
                            <cfelseif isdefined("arguments.ref_member_type") and arguments.ref_member_type is 'consumer'>
                                REF_CONSUMER_ID,
                            <cfelseif isdefined("arguments.ref_member_type") and arguments.ref_member_type is 'employee'>
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
                            <cfif len(arguments.opportunity_type_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.opportunity_type_id#"><cfelse>NULL</cfif>,
                            <cfif arguments.member_type is 'partner'>
                                <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.member_id#">,
                                <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.company_id#">,					
                            <cfelseif arguments.member_type is 'consumer'>
                                <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.member_id#">,
                            </cfif>
                            <cfif isdefined("arguments.ref_member_type") and arguments.ref_member_type is 'partner'>
                                <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ref_partner_id#">,
                                <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ref_company_id#">,					
                            <cfelseif isdefined("arguments.ref_member_type") and arguments.ref_member_type is 'consumer'>
                                <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ref_consumer_id#">,
                            <cfelseif isdefined("arguments.ref_member_type") and arguments.ref_member_type is 'employee'>
                                <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ref_employee_id#">,
                            <cfelse>
                                NULL,
                                NULL,
                                NULL,
                                NULL,				
                            </cfif>
                            <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.process_stage#">,
                            <cfif len(arguments.commethod_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.commethod_id#"><cfelse>NULL</cfif>,
                            <cfif isdefined("arguments.product_cat_id") and  len(arguments.product_cat_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.product_cat_id#"><cfelse>NULL</cfif>,
                            <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.opp_detail#">,
                            <cfif len(arguments.income)><cfqueryparam cfsqltype="cf_sql_float" value = "#arguments.INCOME#"><cfelse>NULL</cfif>,
                            <cfif len(arguments.money) and len(arguments.income)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.money#"><cfelse>NULL</cfif>,
                            <cfif len(arguments.cost)><cfqueryparam cfsqltype="cf_sql_float" value = "#arguments.cost#"><cfelse>NULL</cfif>,
                            <cfif len(arguments.money2) and len(arguments.cost)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.money2#"><cfelse>NULL</cfif>,
                            <cfif isdefined("arguments.stock_id") and len(arguments.stock_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.stock_id#"><cfelse>NULL</cfif>,
                            <cfif len(arguments.sales_team_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.sales_team_id#"><cfelse>NULL</cfif>,
                            <cfif len(arguments.sales_emp_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.sales_emp_id#"><cfelse>NULL</cfif>,
                            <cfif isdefined("arguments.sales_member_id") and  len(arguments.sales_member_id) and len(arguments.sales_member) and arguments.sales_member_type is 'partner'>
                                <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.sales_member_id#">,
                                NULL,
                            <cfelseif isdefined("arguments.sales_member_id") and len(arguments.sales_member_id) and len(arguments.sales_member) and arguments.sales_member_type is 'consumer'>
                                NULL,
                                <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.sales_consumer_id#">,
                            <cfelse>
                                NULL,
                                NULL,
                            </cfif>
                            <cfif len(arguments.opp_date)><cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.opp_date#"><cfelse>NULL</cfif>,
                            <cfif isdefined("arguments.opp_invoice_date") and  len(arguments.opp_invoice_date)><cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.opp_invoice_date#"><cfelse>NULL</cfif>,
                            <cfif isdefined("arguments.action_date") and len(arguments.action_date)><cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.action_date#"><cfelse>NULL</cfif>,
                            <cfif len(arguments.opp_currency_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.opp_currency_id#"><cfelse>NULL</cfif>,
                            1,
                            <cfif isdefined("arguments.activity_time") and len(arguments.activity_time)>#arguments.activity_time#<cfelse>NULL</cfif>,
                            <cfif len(arguments.probability)>#arguments.probability#<cfelse>NULL</cfif>,
                            <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.opp_head#">,
                            0,
                            <cfif len(arguments.project_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.project_id#"><cfelse>NULL</cfif>,
                            <cfqueryparam cfsqltype="cf_sql_varchar" value="#system_paper_no#">,
                            <cfif len(arguments.sales_add_option)>#arguments.sales_add_option#<cfelse>NULL</cfif>,
                            <cfif len(arguments.service_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.service_id#"><cfelse>NULL</cfif>,
                            <cfif isdefined('arguments.cus_help_id') and len(arguments.cus_help_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.cus_help_id#"><cfelse>NULL</cfif>,
                            <cfif isdefined('arguments.camp_name') and len(arguments.camp_name) and isdefined('arguments.camp_id') and Len(arguments.camp_id)>#arguments.camp_id#<cfelse>NULL</cfif>,
                            <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#">,
                            <cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.remote_addr#">,
                            <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
                            <cfif isdefined('arguments.add_rss') and len(arguments.add_rss)>1<cfelse>0</cfif>,
                            <cfif isdefined('arguments.country_id') and len(arguments.country_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.country_id#"><cfelseif isdefined("get_country") and len(get_country.country_id)>#get_country.country_id#<cfelse>NULL</cfif>,
                            <cfif isdefined('arguments.sales_zone_id') and len(arguments.sales_zone_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.sales_zone_id#"><cfelseif isdefined("get_country") and len(get_country.sales_id)>#get_country.sales_id#<cfelse>NULL</cfif>,
                            <cfif isdefined('arguments.event_plan_row_id') and len(arguments.event_plan_row_id)>#event_plan_row_id#<cfelse>NULL</cfif>,
                            <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.process_cat#">
                        )
                </cfquery>
                <cfquery name="UPD_GEN_PAP" datasource="#dsn3#">
                    UPDATE
                        GENERAL_PAPERS
                    SET
                        OPPORTUNITY_NUMBER = #system_paper_no_add#
                    WHERE
                        OPPORTUNITY_NUMBER IS NOT NULL
                </cfquery>		
                
                <cf_workcube_process 
                        is_upd='1' 
                        data_source='#dsn3#' 
                        old_process_line='0'
                        process_stage='#arguments.process_stage#' 
                        record_member='#session.ep.userid#'
                        record_date='#now()#' 
                        action_table='OPPORTUNITIES'
                        action_column='OPP_ID'
                        action_id='#MAX_ID.IDENTITYCOL#'
                        action_page='#request.self#?fuseaction=sales.list_opportunity&event=det&opp_id=#MAX_ID.IDENTITYCOL#' 
                        warning_description='#getLang('','Fırsat',57612)# : #system_paper_no#'>
                    
                <!--- ziyaret planından fırsat ekleme işlemi yapılacaksa.--->
                <cfif isdefined('arguments.event_id') and len(arguments.event_id)>
                    <cfquery name="get_events" datasource="#dsn#">
                        SELECT EVENT_PLAN_HEAD,DETAIL,EVENT_STATUS,VIEW_TO_ALL,IS_WIEW_BRANCH,IS_WIEW_DEPARTMENT FROM EVENT_PLAN WHERE EVENT_PLAN_ID=<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.event_id#">
                    </cfquery>
                    <cfquery name="get_row_events" datasource="#dsn#">
                        SELECT START_DATE,FINISH_DATE,ASSET_ID,CONSUMER_ID,PARTNER_ID,PROJECT_ID FROM EVENT_PLAN_ROW  WHERE  EVENT_PLAN_ROW_ID=<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.plan_rowid#">
                    </cfquery>
                    <cfquery name="get_row_pos" datasource="#dsn#">
                        SELECT
                            EPP.EVENT_POS_ID AS POS_ID
                        FROM
                            EVENT_PLAN_ROW_PARTICIPATION_POS EPP
                        WHERE
                            EPP.EVENT_ROW_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.plan_rowid#">
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
                                        <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#">,
                                    <cfelseif isdefined("session.pp.userid")>
                                        <cfqueryparam cfsqltype="cf_sql_integer" value="#session.pp.userid#">,
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
                                        <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
                                    <cfelse><!--- Kendinde --->
                                        <cfif isdefined("session.EP.userid")>
                                            <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#">,
                                        <cfelseif isdefined("session.pp.userid")>
                                            <cfqueryparam cfsqltype="cf_sql_integer" value="#session.pp.userid#">,
                                        </cfif>
                                        1,
                                        <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
                                    </cfif>
                                </cfif>
                                <cfif isDefined("LINK_ID")>
                                    #LINK_ID#,
                                </cfif>
                                <cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.remote_addr#">,
                                <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
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
                                <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#">
                            <cfelse>
                                #session.pp.our_company_id#
                            </cfif>
                            )	
                    </cfquery>
                </cfif>
                <!---Ek Bilgiler--->
                <cfset arguments.info_id = max_id.IDENTITYCOL>
                <cfset arguments.is_upd = 0>
                <cfset arguments.info_type_id = -16>
                <cfinclude template="../../objects/query/add_info_plus2.cfm">
                <!---Ek Bilgiler--->
                <cfquery name="GET_MAX_OPPORTUNITY" datasource="#dsn3#" maxrows="1">
                    SELECT * FROM OPPORTUNITIES  ORDER BY OPP_ID DESC
                </cfquery>
                <cfset responseStruct.message = "#getlang('','İşlem Başarılı',61210)#">
                <cfset responseStruct.status = true>
                <cfset responseStruct.error = {}>
                <cfset responseStruct.identity = GET_MAX_OPPORTUNITY.OPP_ID>
                <cfcatch>
                    <cfset responseStruct.message = "#getlang('','işlem hatalı',65894)#">
                    <cfset responseStruct.status = false>
                    <cfset responseStruct.error = cfcatch>
                </cfcatch>
            </cftry>
            <cfreturn responseStruct>
        </cftransaction>
    </cffunction>
    <cffunction name="upd" access="public" output="false"  hint="Fırsat Günceleme">
        <cfset attributes = arguments>
        <cfset responseStruct = structNew()>
        <cf_papers paper_type="OPPORTUNITY">
        <cf_get_lang_set module_name="sales">
        <cf_xml_page_edit fuseact="sales.form_add_opportunity">
        
        <cfif arguments.active_company neq session.ep.company_id>
            <cfset responseStruct.message = getLang('main','İşlemin Şirketi İle Aktif Şirketiniz Farklı Çalıştığınız Şirketi Kontrol Ediniz',38700)>
            <cfset responseStruct.status = false>
            <cfset responseStruct.error = {}>
            <cfreturn responseStruct>
            <cfabort>
        </cfif>
        <cfif len(arguments.opp_date)><cf_date tarih="arguments.opp_date"></cfif>
        <cfif isdefined("arguments.opp_invoice_date") and  len(arguments.opp_invoice_date)><cf_date tarih="arguments.opp_invoice_date"></cfif>
        <cfif isdefined("arguments.action_date") and  len(arguments.action_date)><cf_date tarih="arguments.action_date"></cfif>
        <cfset arguments.sales_team_id = ''>
        <cfquery name="get_country" datasource="#dsn#">
            <cfif isdefined("arguments.member_type") and arguments.member_type is 'partner'>
                SELECT 
                    COUNTRY COUNTRY_ID,
                    SALES_COUNTY SALES_ID
                FROM 
                    COMPANY 
                WHERE 
                    COMPANY_ID = #arguments.company_id#
            <cfelseif isdefined("arguments.member_type") and arguments.member_type is 'consumer'>
                SELECT 
                    SALES_COUNTY SALES_ID,
                    TAX_COUNTRY_ID COUNTRY_ID
                FROM 
                    CONSUMER 
                WHERE 
                    CONSUMER_ID = #arguments.member_id#
            </cfif>
        </cfquery>
        <cfif len(arguments.sales_emp_id) and len(arguments.company_id)>
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
                    C.COMPANY_ID = #arguments.company_id# AND
                    SZTR.POSITION_CODE IN (SELECT POSITION_CODE FROM EMPLOYEE_POSITIONS WHERE EMPLOYEE_ID = #arguments.sales_emp_id#)
            </cfquery>
            <cfset arguments.sales_team_id = get_sales_team.team_id>
        </cfif>
        <cfscript>
            if(isdefined("to_par_ids")) CC_PARS = ListSort(to_par_ids,"Numeric", "Desc"); else CC_PARS = "";
            if(isdefined("to_pos_ids")) CC_POS = ListSort(to_pos_ids,"Numeric", "Desc"); else CC_POS = "";
            if(isdefined("to_cons_ids")) CC_CONS = ListSort(to_cons_ids,"Numeric", "Desc"); else CC_CONS ='';
            if(isdefined("to_grp_ids")) CC_GRPS = ListSort(to_grp_ids,"Numeric", "Desc") ; else CC_GRPS ='';
        </cfscript>
        
        <cftransaction>
            <cftry>
                <cfquery name="UPD_OPPORTUNITY" datasource="#dsn3#">
                    UPDATE
                        OPPORTUNITIES
                    SET
                        OPPORTUNITY_TYPE_ID = <cfif len(arguments.opportunity_type_id)>#arguments.opportunity_type_id#<cfelse>NULL</cfif>,
                    <cfif arguments.member_type is 'partner'>
                        PARTNER_ID = #arguments.member_id#,
                        COMPANY_ID = #arguments.company_id#,
                        CONSUMER_ID = NULL,
                    <cfelseif arguments.member_type is 'consumer'>
                        PARTNER_ID = NULL,
                        COMPANY_ID = NULL,
                        CONSUMER_ID = #arguments.member_id#,
                    </cfif>
                    <cfif isdefined("arguments.ref_member_type") and arguments.ref_member_type is 'partner' and len(arguments.ref_member)>
                        REF_PARTNER_ID = #arguments.ref_partner_id#,
                        REF_COMPANY_ID = #arguments.ref_company_id#,
                        REF_CONSUMER_ID = NULL,
                        REF_EMPLOYEE_ID = NULL,
                    <cfelseif isdefined("arguments.ref_member_type") and arguments.ref_member_type is 'consumer' and len(arguments.ref_member)>
                        REF_PARTNER_ID = NULL,
                        REF_COMPANY_ID = NULL,
                        REF_CONSUMER_ID = #arguments.ref_consumer_id#,
                        REF_EMPLOYEE_ID = NULL,
                    <cfelseif isdefined("arguments.ref_member_type") and arguments.ref_member_type is 'employee' and len(arguments.ref_member)>
                        REF_PARTNER_ID = NULL,
                        REF_COMPANY_ID = NULL,
                        REF_CONSUMER_ID = NULL,
                        REF_EMPLOYEE_ID = #arguments.ref_employee_id#,
                    <cfelse>
                        REF_PARTNER_ID = NULL,
                        REF_COMPANY_ID = NULL,
                        REF_CONSUMER_ID = NULL,
                        REF_EMPLOYEE_ID = NULL,
                    </cfif>
                        OPP_STAGE = <cfif isdefined("arguments.process_stage")>#arguments.process_stage#,<cfelse>NULL,</cfif>		
                        COMMETHOD_ID = <cfif len(arguments.commethod_id)>#arguments.commethod_id#<cfelse>NULL</cfif>,
                        PRODUCT_CAT_ID = <cfif isdefined("arguments.product_cat_id") and  len(arguments.product_cat_id)>#arguments.product_cat_id#<cfelse>NULL</cfif>,
                        OPP_DETAIL = <cfif len(arguments.opp_detail)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.opp_detail#"><cfelse>NULL</cfif>,
                        INCOME = <cfif len(arguments.income)><cfqueryparam cfsqltype="cf_sql_float" value = "#arguments.INCOME#"><cfelse>NULL</cfif>,
                        MONEY = <cfif len(arguments.money) and len(arguments.income)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.money#"><cfelse>NULL</cfif>,
                        COST = <cfif len(arguments.cost)><cfqueryparam cfsqltype="cf_sql_float" value = "#arguments.cost#"><cfelse>NULL</cfif>,
                        MONEY2 = <cfif len(arguments.money2) and len(arguments.cost)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.money2#"><cfelse>NULL</cfif>,
                        STOCK_ID = <cfif isdefined("arguments.stock_id") and len(arguments.stock_id) and len(arguments.stock_name)>#arguments.stock_id#<cfelse>NULL</cfif>,
                        SALES_TEAM_ID = <cfif len(arguments.sales_team_id)>#arguments.sales_team_id#<cfelse>NULL</cfif>,
                        SALES_EMP_ID = <cfif len(arguments.sales_emp_id) and len(arguments.sales_emp)>#arguments.sales_emp_id#<cfelse>NULL</cfif>,
                        SALES_PARTNER_ID = <cfif isdefined("arguments.sales_member") and len(arguments.sales_member) and len(arguments.sales_member_id) and len(arguments.sales_member_type) and arguments.sales_member_type eq 'partner'>#arguments.sales_member_id#<cfelse>NULL</cfif>,
                        SALES_CONSUMER_ID = <cfif isdefined("arguments.sales_member") and len(arguments.sales_member) and len(arguments.sales_member_id) and len(arguments.sales_member_type) and arguments.sales_member_type eq 'consumer'>#arguments.sales_member_id#<cfelse>NULL</cfif>,
                        OPP_DATE = <cfif len(arguments.opp_date)><cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.opp_date#"><cfelse>NULL</cfif>,
                        INVOICE_DATE = <cfif isdefined("arguments.opp_invoice_date") and  len(arguments.opp_invoice_date)>#arguments.opp_invoice_date#<cfelse>NULL</cfif>,
                        ACTION_DATE = <cfif isdefined("arguments.action_date") and len(arguments.action_date)><cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.action_date#"><cfelse>NULL</cfif>,
                        OPP_CURRENCY_ID = <cfif len(arguments.opp_currency_id)>#arguments.opp_currency_id#<cfelse>NULL</cfif>,
                        OPP_STATUS = <cfif isDefined("arguments.opp_status")>1<cfelse>0</cfif>,
                        ACTIVITY_TIME = <cfif isdefined("arguments.activity_time") and len(arguments.activity_time)>#arguments.activity_time#<cfelse>NULL</cfif>,
                        PROBABILITY = <cfif len(arguments.probability)>#arguments.probability#<cfelse>NULL</cfif>,
                        OPP_HEAD = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.opp_head#">,
                        OPP_ZONE = 0,
                        PROJECT_ID = <cfif len(arguments.project_id) and len(arguments.project_head)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.project_id#"><cfelse>NULL</cfif>,
                        OPP_NO = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.opportunity_no#">,
                        CC_GRP_IDS = <cfif len(CC_GRPS)><cfqueryparam cfsqltype="cf_sql_varchar" value="#CC_GRPS#"><cfelse>NULL</cfif>,
                        CC_CON_IDS = <cfif len(CC_CONS)><cfqueryparam cfsqltype="cf_sql_varchar" value="#CC_CONS#"><cfelse>NULL</cfif>,
                        CC_PAR_IDS = <cfif len(CC_PARS)><cfqueryparam cfsqltype="cf_sql_varchar" value="#CC_PARS#"><cfelse>NULL</cfif>,
                        CC_POSITIONS = <cfif len(CC_POS)><cfqueryparam cfsqltype="cf_sql_varchar" value="#CC_POS#"><cfelse>NULL</cfif>,
                        SALE_ADD_OPTION_ID = <cfif len(arguments.sales_add_option)>#arguments.sales_add_option#<cfelse>NULL</cfif>,
                        PREFERENCE_REASON_ID = <cfif isdefined("arguments.rival_preference_reason") and len(arguments.rival_preference_reason)><cfqueryparam cfsqltype="cf_sql_varchar" value=",#arguments.rival_preference_reason#,"><cfelse>NULL</cfif>,
                        RIVAL_PARTNER_ID = <cfif len(arguments.rival_partner_id) and len(arguments.rival_company)>#arguments.rival_partner_id#<cfelse>NULL</cfif>,
                        RIVAL_COMPANY_ID = <cfif len(arguments.rival_company_id) and len(arguments.rival_company)>#arguments.rival_company_id#<cfelse>NULL</cfif>,
                        CAMPAIGN_ID = <cfif isdefined('arguments.camp_name') and len(arguments.camp_name) and isdefined('arguments.camp_id') and Len(arguments.camp_id)>#arguments.camp_id#<cfelse>NULL</cfif>,
                        COUNTRY_ID=<cfif isdefined("arguments.country_id1") and len(arguments.country_id1)>#arguments.country_id1#<cfelseif isdefined("get_country") and len(get_country.country_id)>#get_country.country_id#<cfelse>NULL</cfif>,
                        SZ_ID=<cfif isdefined("arguments.sales_zone_id") and len(arguments.sales_zone_id)>#arguments.sales_zone_id#<cfelseif isdefined("get_country") and len(get_country.sales_id)>#get_country.sales_id#<cfelse>NULL</cfif>,
                        UPDATE_EMP = #session.ep.userid#,
                        UPDATE_IP = <cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.remote_addr#">,
                        UPDATE_DATE = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
                        ADD_RSS = <cfif isdefined('arguments.add_rss') and len(arguments.add_rss)>1<cfelse>0</cfif>,
                        PROCESS_CAT = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.process_cat#">
                    WHERE
                        OPP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.opp_id#">
                </cfquery>
                <!--- History --->
                <cfquery name="GET_OPPORTUNITY" datasource="#dsn3#">
                    SELECT 
                        OPP_ID,
                        OPP_STATUS, 
                        OPP_CURRENCY_ID, 
                        OPP_STAGE, 
                        COMPANY_ID, 
                        PARTNER_ID, 
                        CONSUMER_ID, 
                        OPP_HEAD, 
                        OPP_DETAIL, 
                        COMMETHOD_ID, 
                        STOCK_ID,
                        PRODUCT_CAT_ID, 
                        ACTIVITY_TIME, 
                        INCOME, 
                        MONEY, 
                        PROBABILITY, 
                        OPP_DATE, 
                        ACTION_DATE, 
                        INVOICE_DATE, 
                        APPLICATION_LEVEL, 
                        SALES_PARTNER_ID, 
                        SALES_CONSUMER_ID, 
                        CC_POSITIONS, 
                        CC_PAR_IDS, 
                        CC_CON_IDS, 
                        CC_GRP_IDS, 
                        CC_WRKGRP_IDS, 
                        OPP_ZONE, 
                        PROJECT_ID, 
                        IS_PROCESSED, 
                        OPP_NO, 
                        OPPORTUNITY_TYPE_ID, 
                        REF_COMPANY_ID, 
                        REF_PARTNER_ID, 
                        REF_CONSUMER_ID, 
                        REF_EMPLOYEE_ID, 
                        COST, 
                        MONEY2, 
                        SALE_ADD_OPTION_ID, 
                        SALES_EMP_ID, 
                        SALES_TEAM_ID, 
                        PREFERENCE_REASON_ID, 
                        RIVAL_COMPANY_ID, 
                        RIVAL_PARTNER_ID, 
                        CAMPAIGN_ID, 
                        ADD_RSS, 
                        RECORD_EMP, 
                        RECORD_PAR, 
                        RECORD_DATE, 
                        RECORD_IP, 
                        UPDATE_EMP, 
                        UPDATE_PAR, 
                        UPDATE_DATE, 
                        UPDATE_IP, 
                        COUNTRY_ID, 
                        SZ_ID 
                    FROM 
                        OPPORTUNITIES 
                    WHERE 
                        OPP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.opp_id#">
                </cfquery>
                <cfquery name="ADD_OPPORTUNITY_HISTORY" datasource="#dsn3#">
                    INSERT INTO
                        OPPORTUNITY_HISTORY
                        (
                        OPP_ID,
                        OPP_HEAD,
                        OPP_STATUS,
                        OPP_CURRENCY_ID,
                        COMPANY_ID,
                        PARTNER_ID,
                        CONSUMER_ID,
                        OPP_DETAIL,
                        COMMETHOD_ID,
                        STOCK_ID,
                        PRODUCT_CAT_ID,
                        ACTIVITY_TIME,
                        INCOME,
                        MONEY,
                        PROBABILITY,
                        OPP_DATE,
                        APPLICATION_LEVEL,
                        SALES_EMP_ID,
                        SALES_PARTNER_ID,
                        CC_POSITIONS,
                        CC_PAR_IDS,
                        CC_CON_IDS,
                        CC_GRP_IDS,
                        CC_WRKGRP_IDS,
                        RECORD_EMP,
                        RECORD_DATE,
                        RECORD_IP,
                        OPP_ZONE,
                        PROJECT_ID,
                        IS_PROCESSED,
                        OPP_NO,
                        OPP_STAGE
                        )
                    VALUES
                        (
                        #get_opportunity.opp_id#,
                        <cfqueryparam cfsqltype="cf_sql_varchar" value="#get_opportunity.opp_head#">,
                        <cfif len(get_opportunity.opp_status)>
                            #get_opportunity.opp_status#,
                        <cfelse>
                            NULL,
                        </cfif>	
                        <cfif len(get_opportunity.opp_currency_id)>
                            #get_opportunity.opp_currency_id#,
                        <cfelse>
                            NULL,
                        </cfif>	
                        <cfif len(get_opportunity.company_id)>
                            #get_opportunity.company_id#,
                        <cfelse>
                            NULL,
                        </cfif>	
                        <cfif len(get_opportunity.partner_id)>
                            #get_opportunity.partner_id#,
                        <cfelse>
                            NULL,
                        </cfif>	
                        <cfif len(get_opportunity.consumer_id)>
                            #get_opportunity.consumer_id#,
                        <cfelse>
                            NULL,
                        </cfif>	
                        <cfif len(get_opportunity.opp_detail)>
                            <cfqueryparam cfsqltype="cf_sql_varchar" value="#get_opportunity.opp_detail#">,
                        <cfelse>
                            NULL,
                        </cfif>	
                        <cfif len(get_opportunity.commethod_id)>
                            #get_opportunity.commethod_id#,
                        <cfelse>
                            NULL,
                        </cfif>	
                        <cfif len(get_opportunity.stock_id)>
                            #get_opportunity.stock_id#,
                        <cfelse>
                            NULL,
                        </cfif>	
                        <cfif len(get_opportunity.product_cat_id)>
                            #get_opportunity.product_cat_id#,
                        <cfelse>
                            NULL,
                        </cfif>	
                        <cfif len(get_opportunity.activity_time)>
                            #get_opportunity.activity_time#,
                        <cfelse>
                            NULL,
                        </cfif>	
                        <cfif len(get_opportunity.income)>
                            #get_opportunity.income#,
                        <cfelse>
                            NULL,
                        </cfif>	
                        <cfif len(get_opportunity.money)>
                            <cfqueryparam cfsqltype="cf_sql_varchar" value="#get_opportunity.money#">,
                        <cfelse>
                            NULL,
                        </cfif>	
                        <cfif len(get_opportunity.probability)>
                            #get_opportunity.probability#,
                        <cfelse>
                            NULL,
                        </cfif>	
                        <cfif len(get_opportunity.opp_date)>
                            <cfset arguments.opp_date_history = dateformat(get_opportunity.opp_date,dateformat_style)>
                            <cf_date tarih="arguments.opp_date_history">
                            #arguments.opp_date_history#,
                        <cfelse>
                            NULL,
                        </cfif>	
                        <cfif len(get_opportunity.application_level)>
                            <cfqueryparam cfsqltype="cf_sql_varchar" value="#get_opportunity.application_level#">,
                        <cfelse>
                            NULL,
                        </cfif>	
                        <cfif len(get_opportunity.sales_emp_id)>
                            #get_opportunity.sales_emp_id#,
                        <cfelse>
                            NULL,
                        </cfif>	
                        <cfif len(get_opportunity.sales_partner_id)>
                            #get_opportunity.sales_partner_id#,
                        <cfelse>
                            NULL,
                        </cfif>	
                        <cfif len(listsort(get_opportunity.cc_positions,"NUMERIC"))>
                            <cfqueryparam cfsqltype="cf_sql_varchar" value="#get_opportunity.cc_positions#">,
                        <cfelse>
                            NULL,
                        </cfif>	
                        <cfif len(listsort(get_opportunity.cc_par_ids,"NUMERIC"))>
                            <cfqueryparam cfsqltype="cf_sql_varchar" value="#get_opportunity.cc_par_ids#">,
                        <cfelse>
                            NULL,
                        </cfif>	
                        <cfif len(listsort(get_opportunity.cc_con_ids,"NUMERIC"))>
                            <cfqueryparam cfsqltype="cf_sql_varchar" value="#get_opportunity.cc_con_ids#">,
                        <cfelse>
                            NULL,
                        </cfif>	
                        <cfif len(listsort(get_opportunity.cc_grp_ids,"NUMERIC"))>
                            <cfqueryparam cfsqltype="cf_sql_varchar" value="#get_opportunity.cc_grp_ids#">,
                        <cfelse>
                            NULL,
                        </cfif>	
                        <cfif len(listsort(get_opportunity.cc_wrkgrp_ids,"NUMERIC"))>
                            <cfqueryparam cfsqltype="cf_sql_varchar" value="#get_opportunity.cc_wrkgrp_ids#">,
                        <cfelse>
                            NULL,
                        </cfif>	
                        #session.ep.userid#,
                        <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
                        <cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.remote_addr#">,
                        <cfif len(get_opportunity.opp_zone)>
                            #get_opportunity.opp_zone#,
                        <cfelse>
                            NULL,
                        </cfif>	
                        <cfif len(get_opportunity.project_id)>
                            #get_opportunity.project_id#,
                        <cfelse>
                            NULL,
                        </cfif>	
                        <cfif len(get_opportunity.is_processed)>
                            #get_opportunity.is_processed#,
                        <cfelse>
                            NULL,
                        </cfif>	
                        <cfif len(get_opportunity.opp_no)>
                            <cfqueryparam cfsqltype="cf_sql_varchar" value="#get_opportunity.opp_no#">,
                        <cfelse>
                            NULL,
                        </cfif>
                        <cfif len (get_opportunity.opp_stage)>
                        #get_opportunity.opp_stage#
                        <cfelse>
                            NULL
                        </cfif>	
                        )
                </cfquery>
                
                <!--- // History --->
        
                <!--- Fırsata ait cari degistigi an onceki cari ile iliskiyi kesmek gerekli. Analiz sonucu ve sonuc detayları direkt silinir. --->
                <cfif (arguments.old_company_id neq arguments.company_id) and (arguments.old_member_id neq arguments.member_id)>
                    <cfquery name="DEL_ANALYSIS_RESULTS_DETAILS" datasource="#dsn3#">
                        DELETE FROM #dsn#.MEMBER_ANALYSIS_RESULTS_DETAILS WHERE RESULT_ID IN (SELECT RESULT_ID FROM #dsn#.MEMBER_ANALYSIS_RESULTS WHERE OPPORTUNITY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.opp_id#"> AND OUR_COMPANY_ID = #session.ep.company_id#)
                    </cfquery>
                    <cfquery name="DEL_ANALYSIS_RESULTS_DETAILS" datasource="#dsn3#">
                        DELETE FROM #dsn#.MEMBER_ANALYSIS_RESULTS WHERE OPPORTUNITY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.opp_id#"> AND OUR_COMPANY_ID = #session.ep.company_id#
                    </cfquery>
                </cfif>
                <cfif xml_is_opportunity_actions_update eq 1 and len(arguments.project_id) and len(arguments.project_head)>
                    <cfquery name="upd_works" datasource="#dsn3#">
                        UPDATE
                            #dsn#.PRO_WORKS
                        SET
                            PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.project_id#">
                        WHERE
                            OPPORTUNITY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.opp_id#">
                    </cfquery>
                    <cfquery name="upd_events" datasource="#dsn3#">
                        UPDATE
                            #dsn#.EVENT
                        SET
                            PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.project_id#">
                        WHERE
                            EVENT_ID IN 
                                (
                                SELECT
                                    EVENT_ID
                                FROM
                                    #dsn#.EVENTS_RELATED ER
                                WHERE
                                    ER.ACTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.opp_id#"> AND
                                    ER.ACTION_SECTION = <cfqueryparam cfsqltype="cf_sql_varchar" value="OPPORTUNITY_ID"> AND
                                    ER.COMPANY_ID = #session.ep.company_id#
                                )
                    </cfquery>
                    <cfquery name="upd_offers" datasource="#dsn3#">
                        UPDATE
                            OFFER
                        SET
                            PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.project_id#">
                        WHERE
                            OPP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.opp_id#">
                    </cfquery>
                </cfif>
                <!---Ek Bilgiler--->
                <cfset arguments.info_id =  arguments.opp_id>
                <cfset arguments.is_upd = 1>
                <cfset arguments.info_type_id = -16>
                <cfinclude template="../../objects/query/add_info_plus2.cfm">
                <!---Ek Bilgiler--->
            
                <cf_workcube_process 
                is_upd='1' 
                data_source='#dsn3#' 
                process_stage='#arguments.process_stage#' 
                old_process_line='#arguments.old_process_line#'
                record_member='#session.ep.userid#'
                record_date='#now()#'
                action_table='OPPORTUNITIES'
                action_column='OPP_ID'
                action_id='#arguments.opp_id#' 
                action_page='#request.self#?fuseaction=sales.list_opportunity&event=det&opp_id=#arguments.opp_id#' 
                warning_description='#getLang('','Fırsat',57612)# : #GET_OPPORTUNITY.OPP_NO#'>
                <cfset arguments.actionId =arguments.opp_id>
                <cfset responseStruct.message = "#getlang('','İşlem Başarılı',61210)#">
                <cfset responseStruct.status = true>
                <cfset responseStruct.error = {}>
                <cfset responseStruct.identity = ''>
                <cfcatch>
                    <cftransaction action="rollback"/>
                    <cfset responseStruct.message = "#getlang('','işlem hatalı',65894)#">
                    <cfset responseStruct.status = false>
                    <cfset responseStruct.error = cfcatch>
                </cfcatch>
            </cftry>
            <cfreturn responseStruct>
        </cftransaction>
    </cffunction>
    <cffunction name="del" access="public" returntype="any" hint="Fırsat Silme" output="false">
        <!--- ilgili varlıklar db ve hdd den silinir --->
        <cfset attributes = arguments />
        <cfset form = arguments />
        <cfset responseStruct = structNew() />
		<cfset responseStruct.status = true>
        <cfset arguments.action_id=arguments.opp_id>
        <cfset arguments.action_section="OPP_ID">
            <cftransaction>
                <cftry>
                    <cfquery name="getOpp" datasource="#dsn3#">
                        SELECT OPP_NO,OPP_HEAD,OPPORTUNITY_TYPE_ID FROM OPPORTUNITIES WHERE OPP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.opp_id#">
                    </cfquery>
                    <cfquery name="DEL_ANALYSIS_RESULTS_DETAILS" datasource="#dsn3#">
                        DELETE FROM #dsn#.MEMBER_ANALYSIS_RESULTS_DETAILS WHERE RESULT_ID IN (SELECT RESULT_ID FROM #dsn#.MEMBER_ANALYSIS_RESULTS WHERE OPPORTUNITY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.opp_id#"> AND OUR_COMPANY_ID = #session.ep.company_id#)
                    </cfquery>
                    <cfquery name="DEL_ANALYSIS_RESULTS_DETAILS" datasource="#dsn3#">
                        DELETE FROM #dsn#.MEMBER_ANALYSIS_RESULTS WHERE OPPORTUNITY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.opp_id#"> AND OUR_COMPANY_ID = #session.ep.company_id#
                    </cfquery>
                    
                    <cfquery name="DEL_WORKGROUP_EMP_PAR" datasource="#dsn3#">
                        DELETE FROM #dsn#.WORKGROUP_EMP_PAR WHERE OPP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.opp_id#">
                    </cfquery>
                    <cfquery name="DEL_WORK_GROUP" datasource="#dsn3#">
                        DELETE FROM #dsn#.WORK_GROUP WHERE OPP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.opp_id#">
                    </cfquery>
                    <!--- Takipler silinir --->
                    <cfquery name="DEL_OPPORTUNITIES_PLUS" datasource="#dsn3#">
                        DELETE FROM OPPORTUNITIES_PLUS WHERE OPP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.opp_id#">
                    </cfquery>
                    <!--- İlişkili teklif ile fırsat arasındaki ilişkiyi siliyor --->
                    <cfquery name="UPD_OFFER" datasource="#dsn3#">
                        UPDATE OFFER SET OPP_ID = NULL WHERE OPP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.opp_id#">
                    </cfquery>
                    
                    <cfquery name="UPD_EVENTS_RELATED" datasource="#dsn3#">
                        UPDATE
                            #dsn#.EVENTS_RELATED
                        SET
                            ACTION_ID = NULL
                        WHERE
                        ACTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.opp_id#"> AND
                        COMPANY_ID =#session.ep.company_id#   
                    </cfquery>
                    <cfquery name="DEL_OPPORTUNITIES" datasource="#dsn3#">
                        DELETE FROM OPPORTUNITIES WHERE OPP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.opp_id#">
                    </cfquery>
                    <cf_add_log employee_id="#session.ep.userid#" log_type="-1" data_source="#dsn3#" action_id="#arguments.opp_id#" action_name="#getOpp.opp_head# " period_id="#session.ep.period_id#" process_cat="#getOpp.opportunity_type_id#" paper_no="#getOpp.opp_no#">
                    <cfset responseStruct.message = "#getlang('','İşlem Başarılı',61210)#">
                    <cfset responseStruct.status = true>
                    <cfset responseStruct.error = {}>
                    <cfset responseStruct.identity = ''>
                <cfcatch type="database">
                    <cftransaction action="rollback"/>
                    <cfset responseStruct.message = "#getlang('','işlem hatalı',65894)#">
                    <cfset responseStruct.status = false>
                    <cfset responseStruct.error = cfcatch>
                </cfcatch>
                </cftry>
                <cfreturn responseStruct>
            </cftransaction>
    </cffunction>
</cfcomponent>