<cfcomponent extends="cfc.sdFunctions">
    <cfscript>
        functions = CreateObject("component","WMO.functions");
        getlang = functions.getlang;
    </cfscript>
<cfset dsn = dsn_alias = application.systemParam.systemParam().dsn />
<cfset dsn1 = dsn_product = dsn1_alias = '#dsn#_product' />
<cfset dsn2 = dsn2_alias = '#dsn#_#session.ep.period_year#_#session.ep.company_id#' />
<cfset dsn3 = dsn3_alias = '#dsn#_#session.ep.company_id#' />
<cfset file_web_path = application.systemParam.systemParam().file_web_path >
<cfset index_folder = application.systemParam.systemParam().index_folder >
<cfset dir_seperator = application.systemParam.systemParam().dir_seperator>
<cfset request.self = application.systemParam.systemParam().request.self />
<cfset fusebox.process_tree_control = application.systemParam.systemParam().fusebox.process_tree_control>
<cfset WFunctions = createObject("component","WMO.functions") />
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
<cfif not isdefined('basket_kur_ekle')>
    <cfinclude template="../../objects/functions/get_basket_money_js.cfm">
</cfif>
<cf_papers paper_type="pro_material">
<cffunction  name="add"  access="public" returntype="any"> 
    <cfset attributes = arguments>
    <cfset responseStruct = structNew()>
    <cf_get_lang_set module_name="project">
    
    <cftry>
        <cfquery name="UPD_GEN_PAP" datasource="#dsn#">
            UPDATE 
                #dsn3_alias#.GENERAL_PAPERS
            SET
                PRO_MATERIAL_NUMBER = <cfif isdefined("system_paper_no_add")><cfqueryparam cfsqltype="cf_sql_integer" value="#system_paper_no_add#"><cfelse>1</cfif><!--- action file icin 1 atandi --->
            WHERE
                PRO_MATERIAL_NUMBER IS NOT NULL
        </cfquery>	 				
        <cfquery name="ADD_PRO_MATERIAL" datasource="#dsn#" result="MAX_ID">
            INSERT INTO
                #dsn_alias#.PRO_MATERIAL 
            (
                PRO_MATERIAL_NO,
                COMPANY_ID,
                PARTNER_ID,
                CONSUMER_ID,
                ACTION_DATE,
                PROJECT_ID,
                BUDGET_ID,
                WORK_ID,
                DETAIL,
                PLANNER_EMP_ID,
                DISCOUNTTOTAL,
                GROSSTOTAL,
                NETTOTAL,
                TAXTOTAL,
            <cfif isdefined('arguments.basket_money') and len(arguments.basket_money)>
                OTHER_MONEY,
                OTHER_MONEY_VALUE,
            </cfif>
                MATERIAL_STAGE,
                RECORD_DATE,
                RECORD_IP,
                RECORD_EMP
            )
            VALUES 
            (
            <cfqueryparam cfsqltype="cf_sql_varchar" value="#paper_full#">,
            <cfif isDefined("arguments.company_id") and len(arguments.company_id)>
                <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.company_id#">,
                <cfif isDefined("arguments.partner_id") and len(arguments.partner_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.partner_id#"><cfelse>NULL</cfif>,
                NULL,
            <cfelse>
                NULL,
                NULL,
                <cfif isDefined("arguments.consumer_id") and len(arguments.consumer_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.consumer_id#"><cfelse>NULL</cfif>,
            </cfif>
            <cfif len(arguments.action_date)><cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.action_date#"><cfelse>NULL</cfif>,
            <cfif len(arguments.project_id) and Len(arguments.project_head)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.project_id#"><cfelse>-1</cfif>,
            <cfif len(arguments.budget_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.budget_id#"><cfelse>NULL</cfif>,
            <cfif len(arguments.work_id) and Len(arguments.work_head)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.work_id#"><cfelse>NULL</cfif>,
            <cfif len(arguments.pro_material_detail)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pro_material_detail#"><cfelse>NULL</cfif>,
            <cfif len(arguments.planner_emp_id) and len(arguments.planner_emp_name)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.planner_emp_id#"><cfelse>NULL</cfif>,
            <cfif isdefined("arguments.BASKET_DISCOUNT_TOTAL")><cfqueryparam cfsqltype="cf_sql_float" value = "#arguments.BASKET_DISCOUNT_TOTAL#">,<cfelse>0,</cfif>
            <cfif isdefined("arguments.basket_net_total")><cfqueryparam cfsqltype="cf_sql_float" value = "#arguments.basket_net_total#">,<cfelse>0,</cfif>
            <cfif isdefined("arguments.basket_gross_total")><cfqueryparam cfsqltype="cf_sql_float" value = "#arguments.basket_gross_total#">,<cfelse>0,</cfif>
            <cfif isdefined("arguments.basket_tax_total")><cfqueryparam cfsqltype="cf_sql_float" value = "#arguments.basket_tax_total#">,<cfelse>0,</cfif>
            <cfif isdefined('arguments.basket_money') and len(arguments.basket_money)>
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.basket_money#">,
                #((arguments.basket_net_total*arguments.basket_rate1)/arguments.basket_rate2)#,
            </cfif>
                <cfqueryparam value = "#arguments.process_stage#" cfsqltype = "cf_sql_integer">,
                <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.remote_addr#">,
                <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#">
            )
        </cfquery>
        <cfif isdefined("arguments.public_id")>
            <cfquery name="upd_poz_detail" datasource="#dsn#">
                UPDATE POZ_PROJECT SET MATERIAL_ID= <cfqueryparam cfsqltype="cf_sql_integer" value="#MAX_ID.IDENTITYCOL#"> WHERE PUBLIC_ID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.public_id#">
            </cfquery>
        </cfif>
        <cfif isdefined('arguments.rows_')>
            <cfloop from="1" to="#arguments.rows_#" index="I">
                <cf_date tarih="arguments.deliver_date#i#">
                <cfif session.ep.our_company_info.spect_type and isdefined('arguments.is_production#i#') and evaluate('arguments.is_production#i#') eq 1 and not isdefined('arguments.spect_id#i#') or not len(evaluate('arguments.spect_id#i#'))>
                    <cfset dsn_type=dsn>
                    <cfinclude template="../../objects/query/add_basket_spec.cfm">
                </cfif>
                <cfif isdefined('arguments.row_total#i#') and len(evaluate("arguments.row_total#i#"))>
                    <cfset discount_amount = evaluate("arguments.row_total#i#")-evaluate("arguments.row_nettotal#i#") >
                <cfelse>
                    <cfset discount_amount = 0>
                </cfif>
                <cfquery name="ADD_PRO_MATERIAL_ROW" datasource="#dsn#">
                    INSERT INTO
                        #dsn_alias#.PRO_MATERIAL_ROW
                    (
                        PRO_MATERIAL_ID,
                        PRODUCT_ID,
                        STOCK_ID,
                        AMOUNT,
                        UNIT,
                        UNIT_ID,
                    <cfif len(evaluate('arguments.price#i#'))>				
                        PRICE,
                    </cfif>	
                        TAX,
                        DUEDATE,
                        PRODUCT_NAME,
                        DELIVER_DATE,
                        DELIVER_DEPT,
                        DELIVER_LOCATION,
                        DISCOUNT1,
                        DISCOUNT2,
                        DISCOUNT3,
                        DISCOUNT4,
                        DISCOUNT5,
                        OTHER_MONEY,
                        OTHER_MONEY_VALUE,
                    <cfif isdefined('arguments.spect_id#i#') and len(evaluate('arguments.spect_id#i#'))>
                        SPECT_VAR_ID,
                        SPECT_VAR_NAME,
                    </cfif>
                        PRICE_OTHER,
                        COST_PRICE,
                        COST_ID,
                        EXTRA_COST,
                        MARGIN,
                        PROM_COMISSION,
                        PROM_COST,
                        DISCOUNT_COST,
                        PROM_ID,
                        IS_PROMOTION,
                        PROM_STOCK_ID,
                        UNIQUE_RELATION_ID,
                        PRODUCT_NAME2,
                        AMOUNT2,
                        UNIT2,
                        EXTRA_PRICE,
                        EK_TUTAR_PRICE,
                        EXTRA_PRICE_TOTAL,
                        SHELF_NUMBER,
                        PRODUCT_MANUFACT_CODE,
                        OTV_ORAN,
                        OTVTOTAL,
                        BASKET_EXTRA_INFO_ID,
                        SELECT_INFO_EXTRA,
                        DETAIL_INFO_EXTRA,
                        DISCOUNTTOTAL,
                        GROSSTOTAL,
                        NETTOTAL,
                        LIST_PRICE,
                        PRICE_CAT,
                        CATALOG_ID,
                        KARMA_PRODUCT_ID,
                        TAXTOTAL,
                        WRK_ROW_ID,
                        WRK_ROW_RELATION_ID,
                        WIDTH_VALUE,
                        DEPTH_VALUE,
                        HEIGHT_VALUE,
                        ROW_PROJECT_ID
                    )
                    VALUES
                    (
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#MAX_ID.IDENTITYCOL#">,
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('arguments.product_id#i#')#">,
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('arguments.stock_id#i#')#">,
                        <cfqueryparam cfsqltype="cf_sql_float" value = "#evaluate('arguments.amount#i#')#">,
                        <cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('arguments.unit#i#')#">,
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('arguments.unit_id#i#')#">,
                        <cfif len(evaluate('arguments.price#i#'))><cfqueryparam cfsqltype="cf_sql_float" value = "#evaluate('arguments.price#i#')#">,</cfif>
                        <cfqueryparam cfsqltype="cf_sql_float" value = "#evaluate('arguments.tax#i#')#">,
                    <cfif isdefined("arguments.duedate#i#") and len(evaluate('arguments.duedate#i#'))><cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('arguments.duedate#i#')#"><cfelse>NULL</cfif>,
                        <cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('arguments.product_name#i#')#">,
                    <cfif isdefined("arguments.deliver_date#i#") and isdate(evaluate('arguments.deliver_date#i#'))><cfqueryparam cfsqltype="cf_sql_timestamp" value="#evaluate('arguments.deliver_date#i#')#"><cfelse>NULL</cfif>,
                    <cfif isdefined("arguments.deliver_dept#i#") and len(trim(evaluate("arguments.deliver_dept#i#"))) and len(listfirst(evaluate("arguments.deliver_dept#i#"),"-"))>
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#listfirst(evaluate("arguments.deliver_dept#i#"),"-")#">,
                    <cfelse>
                        NULL,
                    </cfif>
                    <cfif isdefined("arguments.deliver_dept#i#") and listlen(trim(evaluate("arguments.deliver_dept#i#")),"-") eq 2 and len(listlast(evaluate("arguments.deliver_dept#i#"),"-"))>
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#listlast(evaluate("arguments.deliver_dept#i#"),"-")#">,
                    <cfelse>
                        NULL,
                    </cfif>
                    <cfif isdefined('arguments.indirim1#i#')><cfqueryparam cfsqltype="cf_sql_float" value = "#evaluate('arguments.indirim1#i#')#"><cfelse>0</cfif>,
                    <cfif isdefined('arguments.indirim2#i#')><cfqueryparam cfsqltype="cf_sql_float" value = "#evaluate('arguments.indirim2#i#')#"><cfelse>0</cfif>,
                    <cfif isdefined('arguments.indirim3#i#')><cfqueryparam cfsqltype="cf_sql_float" value = "#evaluate('arguments.indirim3#i#')#"><cfelse>0</cfif>,
                    <cfif isdefined('arguments.indirim4#i#')><cfqueryparam cfsqltype="cf_sql_float" value = "#evaluate('arguments.indirim4#i#')#"><cfelse>0</cfif>,
                    <cfif isdefined('arguments.indirim5#i#')><cfqueryparam cfsqltype="cf_sql_float" value = "#evaluate('arguments.indirim5#i#')#"><cfelse>0</cfif>,
                    <cfif isdefined('arguments.other_money_#i#')><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('arguments.other_money_#i#')#"><cfelse>NULL</cfif>,
                    <cfif isdefined('arguments.other_money_value_#i#') and len(evaluate("arguments.other_money_value_#i#"))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('arguments.other_money_value_#i#')#"><cfelse>NULL</cfif>,
                    <cfif isdefined('arguments.spect_id#i#') and len(evaluate('arguments.spect_id#i#'))>
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('arguments.spect_id#i#')#">,
                        <cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('arguments.spect_name#i#')#">,
                    </cfif>
                    <cfif isdefined('arguments.price_other#i#') and len(evaluate('arguments.price_other#i#'))><cfqueryparam cfsqltype="cf_sql_float" value = "#evaluate('arguments.price_other#i#')#"><cfelse>NULL</cfif>,
                    <cfif isdefined('arguments.net_maliyet#i#') and len(evaluate('arguments.net_maliyet#i#'))><cfqueryparam cfsqltype="cf_sql_float" value = "#evaluate('arguments.net_maliyet#i#')#"><cfelse>0</cfif>,
                    <cfif isdefined('arguments.cost_id#i#') and len(evaluate('arguments.cost_id#i#'))><cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('arguments.cost_id#i#')#"><cfelse>NULL</cfif>,
                    <cfif isdefined('arguments.extra_cost#i#') and len(evaluate('arguments.extra_cost#i#'))><cfqueryparam cfsqltype="cf_sql_float" value="#evaluate('arguments.extra_cost#i#')#"><cfelse>0</cfif>,
                    <cfif isdefined('arguments.marj#i#') and len(evaluate('arguments.marj#i#'))><cfqueryparam cfsqltype="cf_sql_float" value="#evaluate('arguments.marj#i#')#">,<cfelse>0,</cfif>			
                    <cfif isdefined('arguments.promosyon_yuzde#i#') and len(evaluate('arguments.promosyon_yuzde#i#'))><cfqueryparam cfsqltype="cf_sql_float" value="#evaluate('arguments.promosyon_yuzde#i#')#">,<cfelse>NULL,</cfif>
                    <cfif isdefined('arguments.promosyon_maliyet#i#') and len(evaluate('arguments.promosyon_maliyet#i#'))><cfqueryparam cfsqltype="cf_sql_float" value="#evaluate('arguments.promosyon_maliyet#i#')#">,<cfelse>0,</cfif>
                    <cfif isdefined('arguments.iskonto_tutar#i#') and len(evaluate('arguments.iskonto_tutar#i#'))><cfqueryparam cfsqltype="cf_sql_float" value="#evaluate('arguments.iskonto_tutar#i#')#">,<cfelse>NULL,</cfif>
                    <cfif isdefined('arguments.row_promotion_id#i#') and len(evaluate('arguments.row_promotion_id#i#'))><cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('arguments.row_promotion_id#i#')#">,<cfelse>NULL,</cfif>
                    <cfif isdefined('arguments.is_promotion#i#') and len(evaluate('arguments.is_promotion#i#'))><cfqueryparam cfsqltype="cf_sql_bit" value="#evaluate('arguments.is_promotion#i#')#">,<cfelse>NULL,</cfif>
                    <cfif isdefined('arguments.prom_stock_id#i#') and len(evaluate('arguments.prom_stock_id#i#'))><cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('arguments.prom_stock_id#i#')#">,<cfelse>NULL,</cfif>
                    <cfif isdefined('arguments.row_unique_relation_id#i#') and len(evaluate('arguments.row_unique_relation_id#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('arguments.row_unique_relation_id#i#')#"><cfelse>NULL</cfif>,
                    <cfif isdefined('arguments.product_name_other#i#') and len(evaluate('arguments.product_name_other#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('arguments.product_name_other#i#')#"><cfelse>NULL</cfif>,
                    <cfif isdefined('arguments.amount_other#i#') and len(evaluate('arguments.amount_other#i#'))><cfqueryparam cfsqltype="cf_sql_float" value="#evaluate('arguments.amount_other#i#')#"><cfelse>NULL</cfif>,
                    <cfif isdefined('arguments.unit_other#i#') and len(evaluate('arguments.unit_other#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('arguments.unit_other#i#')#"><cfelse>NULL</cfif>,
                    <cfif isdefined('arguments.ek_tutar#i#') and len(evaluate('arguments.ek_tutar#i#'))><cfqueryparam cfsqltype="cf_sql_float" value ="#evaluate('arguments.ek_tutar#i#')#"><cfelse>NULL</cfif>,
                    <cfif isdefined('arguments.ek_tutar_price#i#') and len(evaluate('arguments.ek_tutar_price#i#'))><cfqueryparam cfsqltype="cf_sql_float" value ="#evaluate('arguments.ek_tutar_price#i#')#"><cfelse>NULL</cfif>,
                    <cfif isdefined('arguments.ek_tutar_total#i#') and len(evaluate('arguments.ek_tutar_total#i#'))><cfqueryparam cfsqltype="cf_sql_float" value ="#evaluate('arguments.ek_tutar_total#i#')#"><cfelse>NULL</cfif>,
                    <cfif isdefined('arguments.shelf_number#i#') and len(evaluate('arguments.shelf_number#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value ="#evaluate('arguments.shelf_number#i#')#"><cfelse>NULL</cfif>,
                    <cfif isdefined('arguments.manufact_code#i#') and len(evaluate('arguments.manufact_code#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('arguments.manufact_code#i#')#"><cfelse>NULL</cfif>,
                    <cfif isdefined('arguments.otv_oran#i#') and len(evaluate('arguments.otv_oran#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('arguments.otv_oran#i#')#"><cfelse>NULL</cfif>,
                    <cfif isdefined('arguments.row_otvtotal#i#') and len(evaluate('arguments.row_otvtotal#i#'))><cfqueryparam cfsqltype="cf_sql_float" value ="#evaluate('arguments.row_otvtotal#i#')#"><cfelse>NULL</cfif>,
                    <cfif isdefined('arguments.basket_extra_info#i#') and len(evaluate('arguments.basket_extra_info#i#'))><cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('arguments.basket_extra_info#i#')#"><cfelse>NULL</cfif>,
                    <cfif isdefined('arguments.select_info_extra#i#') and len(evaluate('arguments.select_info_extra#i#'))><cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('arguments.select_info_extra#i#')#"><cfelse>NULL</cfif>,
                    <cfif isdefined('arguments.detail_info_extra#i#') and len(evaluate('arguments.detail_info_extra#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('arguments.detail_info_extra#i#')#"><cfelse>NULL</cfif>,
                    <cfqueryparam cfsqltype="cf_sql_float" value = "#DISCOUNT_AMOUNT#">,
                    <cfqueryparam cfsqltype="cf_sql_float" value ="#evaluate("arguments.row_lasttotal#i#")#">,
                    <cfqueryparam cfsqltype="cf_sql_float" value ="#evaluate("arguments.row_nettotal#i#")#">,
                    <cfif isdefined('arguments.list_price#i#') and len(evaluate('arguments.list_price#i#'))><cfqueryparam cfsqltype="cf_sql_float" value ="#evaluate('arguments.list_price#i#')#"><cfelse>NULL</cfif>,
                    <cfif isdefined('arguments.price_cat#i#') and len(evaluate('arguments.price_cat#i#'))><cfqueryparam cfsqltype="cf_sql_integer" value ="#evaluate('arguments.price_cat#i#')#"><cfelse>NULL</cfif>,
                    <cfif isdefined('arguments.row_catalog_id#i#') and len(evaluate('arguments.row_catalog_id#i#'))><cfqueryparam cfsqltype="cf_sql_integer" value ="#evaluate('arguments.row_catalog_id#i#')#"><cfelse>NULL</cfif>,
                    <cfif isdefined('arguments.karma_product_id#i#') and len(evaluate('arguments.karma_product_id#i#'))><cfqueryparam cfsqltype="cf_sql_integer" value ="#evaluate('arguments.karma_product_id#i#')#"><cfelse>NULL</cfif>,
                    <cfqueryparam cfsqltype="cf_sql_float" value =" #evaluate("arguments.row_taxtotal#i#")#">,
                    <cfif isdefined('arguments.wrk_row_id#i#') and len(evaluate('arguments.wrk_row_id#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('arguments.wrk_row_id#i#')#"><cfelse>NULL</cfif>,
                    <cfif isdefined('arguments.wrk_row_relation_id#i#') and len(evaluate('arguments.wrk_row_relation_id#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('arguments.wrk_row_relation_id#i#')#"><cfelse>NULL</cfif>,
                    <cfif isdefined('arguments.row_width#i#') and len(evaluate('arguments.row_width#i#'))><cfqueryparam cfsqltype="cf_sql_float" value =" #evaluate('arguments.row_width#i#')#"><cfelse>NULL</cfif>,
                    <cfif isdefined('arguments.row_depth#i#') and len(evaluate('arguments.row_depth#i#'))><cfqueryparam cfsqltype="cf_sql_float" value =" #evaluate('arguments.row_depth#i#')#"><cfelse>NULL</cfif>,
                    <cfif isdefined('arguments.row_height#i#') and len(evaluate('arguments.row_height#i#'))><cfqueryparam cfsqltype="cf_sql_float" value =" #evaluate('arguments.row_height#i#')#"><cfelse>NULL</cfif>,
                    <cfif isdefined('arguments.row_project_id#i#') and len(evaluate('arguments.row_project_id#i#')) and isdefined('arguments.row_project_name#i#') and len(evaluate('arguments.row_project_name#i#'))><cfqueryparam cfsqltype="cf_sql_integer" value =" #evaluate('arguments.row_project_id#i#')#"><cfelse>NULL</cfif>
                    )
                </cfquery>
            </cfloop>
        </cfif>
        <cfscript>
            if (not isdefined("new_dsn")) new_dsn = dsn; //action file vb dosyalardan tanim farkli gelebiliyor, bunun icin boyle bir duzenleme yapildi fbs 20110906
            this.basket_kur_ekle(action_id:MAX_ID.IDENTITYCOL,table_type_id:14,process_type:0,transaction_dsn:dsn,basket_money_db:new_dsn);
        </cfscript>
      <cfset arguments.is_upd = 0>
      <cfset responseStruct.message = "#getlang('','İşlem Başarılı',61210)#">
      <cfset responseStruct.status = true>
      <cfset responseStruct.error = {}>
      <cfset responseStruct.identity = MAX_ID.IDENTITYCOL>
      <cfcatch>
        <cfset responseStruct.message = "#getlang('','işlem hatalı',65894)#">
        <cfset responseStruct.status = false>
        <cfset responseStruct.error = cfcatch>
    </cfcatch>
</cftry>
    
  <cfreturn responseStruct>
</cffunction>

<cffunction  name="upd"  access="public" returntype="any">
    <cfset attributes = arguments>
    <cfset responseStruct = structNew()>
    <cf_get_lang_set module_name="project">
    
    <cfquery name="CONTROL_PRO_MATERIAL" datasource="#dsn#">
        SELECT PRO_MATERIAL_ID,PRO_MATERIAL_NO FROM PRO_MATERIAL WHERE PRO_MATERIAL_ID=<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.upd_id#">
    </cfquery>
    <cfif not CONTROL_PRO_MATERIAL.recordcount>
        <script type="text/javascript">
            alert("<cf_get_lang dictionary_id='38444.Böyle Bir Malzeme Planı Bulunamadı'>!");
            window.location.href='<cfoutput>#request.self#?fuseaction=project.list_project_work</cfoutput>';
        </script>
        <cfabort>
    </cfif>
    <cftry>
        <cf_date tarih="arguments.action_date">
        <cflock name="#CREATEUUID()#" timeout="20">
            <cftransaction>
                <cfquery name="UPD_PRO_MATERIAL" datasource="#dsn#">
                    UPDATE 
                    #dsn_alias#.PRO_MATERIAL 
                    SET
                        PRO_MATERIAL_NO=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pro_number#">,
                    <cfif isDefined("arguments.company_id") and len(arguments.company_id)>
                        COMPANY_ID= <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.company_id#">,
                        PARTNER_ID=<cfif isDefined("arguments.partner_id") and len(arguments.partner_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.partner_id#"><cfelse>NULL</cfif>,
                        CONSUMER_ID=NULL,
                    <cfelse>
                        COMPANY_ID=NULL,
                        PARTNER_ID=NULL,
                        CONSUMER_ID=<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.consumer_id#">,
                    </cfif>
                        ACTION_DATE=<cfif len(arguments.action_date)><cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.action_date#"><cfelse>NULL</cfif>,
                        PROJECT_ID=<cfif len(arguments.project_id) and Len(arguments.project_head)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.project_id#"><cfelse>-1</cfif>,
                        BUDGET_ID=<cfif len(arguments.budget_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.budget_id#"><cfelse>NULL</cfif>,
                        WORK_ID=<cfif len(arguments.work_id) and len(arguments.work_head)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.work_id#"><cfelse>NULL</cfif>,
                        DETAIL=<cfif len(arguments.pro_material_detail)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pro_material_detail#"><cfelse>NULL</cfif>,
                        PLANNER_EMP_ID=<cfif len(arguments.planner_emp_id) and len(arguments.planner_emp_name)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.planner_emp_id#"><cfelse>NULL</cfif>,
                        DISCOUNTTOTAL=<cfif isdefined("arguments.BASKET_DISCOUNT_TOTAL")><cfqueryparam cfsqltype="cf_sql_float" value = "#arguments.BASKET_DISCOUNT_TOTAL#"><cfelse>0</cfif>,
                        GROSSTOTAL=<cfif isdefined("arguments.basket_net_total")><cfqueryparam cfsqltype="cf_sql_float" value = "#arguments.basket_net_total#"><cfelse>0</cfif>,
                        NETTOTAL=<cfif isdefined("arguments.basket_gross_total")><cfqueryparam cfsqltype="cf_sql_float" value = "#arguments.basket_gross_total#"><cfelse>0</cfif>,
                        TAXTOTAL=<cfif isdefined("arguments.basket_tax_total")><cfqueryparam cfsqltype="cf_sql_float" value = "#arguments.basket_tax_total#"><cfelse>0</cfif>,
                    <cfif isdefined('arguments.basket_money') and len(arguments.basket_money)>
                        OTHER_MONEY=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.basket_money#">,
                        OTHER_MONEY_VALUE=#((arguments.basket_net_total*arguments.basket_rate1)/arguments.basket_rate2)#,
                    <cfelse>
                        OTHER_MONEY=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.basket_money#">,
                        OTHER_MONEY_VALUE=#((arguments.basket_net_total*arguments.basket_rate1)/arguments.basket_rate2)#,
                    </cfif>
                        MATERIAL_STAGE=<cfqueryparam value = "#arguments.process_stage#" cfsqltype = "cf_sql_integer">,
                        UPDATE_DATE= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
                        UPDATE_IP=<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.remote_addr#">,
                        UPDATE_EMP=<cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#">
                        
                    WHERE
                        PRO_MATERIAL_ID=<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.upd_id#">
                </cfquery>
                <cfquery name="DEL_PRO_MATERIAL_ROW" datasource="#dsn#">
                    DELETE FROM #dsn_alias#.PRO_MATERIAL_ROW WHERE PRO_MATERIAL_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.upd_id#">
                </cfquery>
                <cfloop from="1" to="#arguments.rows_#" index="I">
                    <cf_date tarih="arguments.deliver_date#i#">
                    <cfif session.ep.our_company_info.spect_type and isdefined('arguments.is_production#i#') and evaluate('arguments.is_production#i#') eq 1>
                        <cfset specer_spec_id=''>
                        <cfset dsn_type=dsn>
                        <cfif not isdefined('arguments.spect_id#i#') or not len(evaluate('arguments.spect_id#i#'))>
                            <cfinclude template="../../objects/query/add_basket_spec.cfm">
                        <cfelseif arguments.basket_spect_type eq 7 ><!--- satırdada guncellenebilmeli bu spec tipinde--->
                            <cfset specer_spec_id=evaluate('arguments.spect_id#i#')>
                            <cfinclude template="../../objects/query/add_basket_spec.cfm">
                        </cfif>
                    </cfif>
                    <cfif isdefined('arguments.row_total#i#') and len(evaluate("arguments.row_total#i#"))>
                        <cfset discount_amount = evaluate("arguments.row_total#i#")-evaluate("arguments.row_nettotal#i#") >
                    <cfelse>
                        <cfset discount_amount = 0>
                    </cfif>
                    <cfquery name="ADD_PRO_MATERIAL_ROW" datasource="#dsn#">
                        INSERT INTO
                        #dsn_alias#.PRO_MATERIAL_ROW
                        (
                            PRO_MATERIAL_ID,
                            PRODUCT_ID,
                            STOCK_ID,
                            AMOUNT,
                            UNIT,
                            UNIT_ID,
                        <cfif len(evaluate('arguments.price#i#'))>				
                            PRICE,
                        </cfif>	
                            TAX,
                            DUEDATE,
                            PRODUCT_NAME,
                            DELIVER_DATE,
                            DELIVER_DEPT,
                            DELIVER_LOCATION,
                            DISCOUNT1,
                            DISCOUNT2,
                            DISCOUNT3,
                            DISCOUNT4,
                            DISCOUNT5,
                            OTHER_MONEY,
                            OTHER_MONEY_VALUE,
                        <cfif isdefined('arguments.spect_id#i#') and len(evaluate('arguments.spect_id#i#'))>
                            SPECT_VAR_ID,
                            SPECT_VAR_NAME,
                        </cfif>
                            PRICE_OTHER,
                            COST_PRICE,
                            COST_ID,
                            EXTRA_COST,
                            MARGIN,
                            PROM_COMISSION,
                            PROM_COST,
                            DISCOUNT_COST,
                            PROM_ID,
                            IS_PROMOTION,
                            PROM_STOCK_ID,
                            UNIQUE_RELATION_ID,
                            PRODUCT_NAME2,
                            AMOUNT2,
                            UNIT2,
                            EXTRA_PRICE,
                            EK_TUTAR_PRICE,
                            EXTRA_PRICE_TOTAL,
                            SHELF_NUMBER,
                            PRODUCT_MANUFACT_CODE,
                            OTV_ORAN,
                            OTVTOTAL,
                            BASKET_EXTRA_INFO_ID,
                            SELECT_INFO_EXTRA,
                            DETAIL_INFO_EXTRA,
                            DISCOUNTTOTAL,
                            GROSSTOTAL,
                            NETTOTAL,
                            LIST_PRICE,
                            PRICE_CAT,
                            CATALOG_ID,
                            KARMA_PRODUCT_ID,
                            TAXTOTAL,
                            WRK_ROW_ID,
                            WRK_ROW_RELATION_ID,
                            WIDTH_VALUE,
                            DEPTH_VALUE,
                            HEIGHT_VALUE,
                            ROW_PROJECT_ID
                        )
                        VALUES
                        (
                            <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.upd_id#">,
                            <cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('arguments.product_id#i#')#">,
                            <cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('arguments.stock_id#i#')#">,
                            <cfqueryparam cfsqltype="cf_sql_float" value = "#evaluate('arguments.amount#i#')#">,
                            <cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('arguments.unit#i#')#">,
                            <cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('arguments.unit_id#i#')#">,
                            <cfif len(evaluate('arguments.price#i#'))><cfqueryparam cfsqltype="cf_sql_float" value = "#evaluate('arguments.price#i#')#">,</cfif>
                            <cfqueryparam cfsqltype="cf_sql_float" value = "#evaluate('arguments.tax#i#')#">,
                        <cfif isdefined("arguments.duedate#i#") and len(evaluate('arguments.duedate#i#'))><cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('arguments.duedate#i#')#"><cfelse>NULL</cfif>,
                            <cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('arguments.product_name#i#')#">,
                        <cfif isdefined("arguments.deliver_date#i#") and isdate(evaluate('arguments.deliver_date#i#'))><cfqueryparam cfsqltype="cf_sql_timestamp" value="#evaluate('arguments.deliver_date#i#')#"><cfelse>NULL</cfif>,
                        <cfif isdefined("arguments.deliver_dept#i#") and len(trim(evaluate("arguments.deliver_dept#i#"))) and len(listfirst(evaluate("arguments.deliver_dept#i#"),"-"))>
                            <cfqueryparam cfsqltype="cf_sql_integer" value="#listfirst(evaluate("arguments.deliver_dept#i#"),"-")#">,
                        <cfelse>
                            NULL,
                        </cfif>
                        <cfif isdefined("arguments.deliver_dept#i#") and listlen(trim(evaluate("arguments.deliver_dept#i#")),"-") eq 2 and len(listlast(evaluate("arguments.deliver_dept#i#"),"-"))>
                            <cfqueryparam cfsqltype="cf_sql_integer" value="#listlast(evaluate("arguments.deliver_dept#i#"),"-")#">,
                        <cfelse>
                            NULL,
                        </cfif>
                        <cfif isdefined('arguments.indirim1#i#')><cfqueryparam cfsqltype="cf_sql_float" value = "#evaluate('arguments.indirim1#i#')#"><cfelse>0</cfif>,
                        <cfif isdefined('arguments.indirim2#i#')><cfqueryparam cfsqltype="cf_sql_float" value = "#evaluate('arguments.indirim2#i#')#"><cfelse>0</cfif>,
                        <cfif isdefined('arguments.indirim3#i#')><cfqueryparam cfsqltype="cf_sql_float" value = "#evaluate('arguments.indirim3#i#')#"><cfelse>0</cfif>,
                        <cfif isdefined('arguments.indirim4#i#')><cfqueryparam cfsqltype="cf_sql_float" value = "#evaluate('arguments.indirim4#i#')#"><cfelse>0</cfif>,
                        <cfif isdefined('arguments.indirim5#i#')><cfqueryparam cfsqltype="cf_sql_float" value = "#evaluate('arguments.indirim5#i#')#"><cfelse>0</cfif>,
                        <cfif isdefined('arguments.other_money_#i#')><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('arguments.other_money_#i#')#"><cfelse>NULL</cfif>,
                        <cfif isdefined('arguments.other_money_value_#i#') and len(evaluate("arguments.other_money_value_#i#"))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('arguments.other_money_value_#i#')#"><cfelse>NULL</cfif>,
                        <cfif isdefined('arguments.spect_id#i#') and len(evaluate('arguments.spect_id#i#'))>
                            <cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('arguments.spect_id#i#')#">,
                            <cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('arguments.spect_name#i#')#">,
                        </cfif>
                        <cfif isdefined('arguments.price_other#i#') and len(evaluate('arguments.price_other#i#'))><cfqueryparam cfsqltype="cf_sql_float" value = "#evaluate('arguments.price_other#i#')#"><cfelse>NULL</cfif>,
                        <cfif isdefined('arguments.net_maliyet#i#') and len(evaluate('arguments.net_maliyet#i#'))><cfqueryparam cfsqltype="cf_sql_float" value = "#evaluate('arguments.net_maliyet#i#')#"><cfelse>0</cfif>,
                        <cfif isdefined('arguments.cost_id#i#') and len(evaluate('arguments.cost_id#i#'))><cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('arguments.cost_id#i#')#"><cfelse>NULL</cfif>,
                        <cfif isdefined('arguments.extra_cost#i#') and len(evaluate('arguments.extra_cost#i#'))><cfqueryparam cfsqltype="cf_sql_float" value="#evaluate('arguments.extra_cost#i#')#"><cfelse>0</cfif>,
                        <cfif isdefined('arguments.marj#i#') and len(evaluate('arguments.marj#i#'))><cfqueryparam cfsqltype="cf_sql_float" value="#evaluate('arguments.marj#i#')#">,<cfelse>0,</cfif>			
                        <cfif isdefined('arguments.promosyon_yuzde#i#') and len(evaluate('arguments.promosyon_yuzde#i#'))><cfqueryparam cfsqltype="cf_sql_float" value="#evaluate('arguments.promosyon_yuzde#i#')#">,<cfelse>NULL,</cfif>
                        <cfif isdefined('arguments.promosyon_maliyet#i#') and len(evaluate('arguments.promosyon_maliyet#i#'))><cfqueryparam cfsqltype="cf_sql_float" value="#evaluate('arguments.promosyon_maliyet#i#')#">,<cfelse>0,</cfif>
                        <cfif isdefined('arguments.iskonto_tutar#i#') and len(evaluate('arguments.iskonto_tutar#i#'))><cfqueryparam cfsqltype="cf_sql_float" value="#evaluate('arguments.iskonto_tutar#i#')#">,<cfelse>NULL,</cfif>
                        <cfif isdefined('arguments.row_promotion_id#i#') and len(evaluate('arguments.row_promotion_id#i#'))><cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('arguments.row_promotion_id#i#')#">,<cfelse>NULL,</cfif>
                        <cfif isdefined('arguments.is_promotion#i#') and len(evaluate('arguments.is_promotion#i#'))><cfqueryparam cfsqltype="cf_sql_bit" value="#evaluate('arguments.is_promotion#i#')#">,<cfelse>NULL,</cfif>
                        <cfif isdefined('arguments.prom_stock_id#i#') and len(evaluate('arguments.prom_stock_id#i#'))><cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('arguments.prom_stock_id#i#')#">,<cfelse>NULL,</cfif>
                        <cfif isdefined('arguments.row_unique_relation_id#i#') and len(evaluate('arguments.row_unique_relation_id#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('arguments.row_unique_relation_id#i#')#"><cfelse>NULL</cfif>,
                        <cfif isdefined('arguments.product_name_other#i#') and len(evaluate('arguments.product_name_other#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('arguments.product_name_other#i#')#"><cfelse>NULL</cfif>,
                        <cfif isdefined('arguments.amount_other#i#') and len(evaluate('arguments.amount_other#i#'))><cfqueryparam cfsqltype="cf_sql_float" value="#evaluate('arguments.amount_other#i#')#"><cfelse>NULL</cfif>,
                        <cfif isdefined('arguments.unit_other#i#') and len(evaluate('arguments.unit_other#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('arguments.unit_other#i#')#"><cfelse>NULL</cfif>,
                        <cfif isdefined('arguments.ek_tutar#i#') and len(evaluate('arguments.ek_tutar#i#'))><cfqueryparam cfsqltype="cf_sql_float" value = "#evaluate('arguments.ek_tutar#i#')#"><cfelse>NULL</cfif>,
                        <cfif isdefined('arguments.ek_tutar_price#i#') and len(evaluate('arguments.ek_tutar_price#i#'))><cfqueryparam cfsqltype="cf_sql_float" value = "#evaluate('arguments.ek_tutar_price#i#')#"><cfelse>NULL</cfif>,
                        <cfif isdefined('arguments.ek_tutar_total#i#') and len(evaluate('arguments.ek_tutar_total#i#'))><cfqueryparam cfsqltype="cf_sql_float" value = "#evaluate('arguments.ek_tutar_total#i#')#"><cfelse>NULL</cfif>,
                        <cfif isdefined('arguments.shelf_number#i#') and len(evaluate('arguments.shelf_number#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value ="#evaluate('arguments.shelf_number#i#')#"><cfelse>NULL</cfif>,
                        <cfif isdefined('arguments.manufact_code#i#') and len(evaluate('arguments.manufact_code#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('arguments.manufact_code#i#')#"><cfelse>NULL</cfif>,
                        <cfif isdefined('arguments.otv_oran#i#') and len(evaluate('arguments.otv_oran#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('arguments.otv_oran#i#')#"><cfelse>NULL</cfif>,
                        <cfif isdefined('arguments.row_otvtotal#i#') and len(evaluate('arguments.row_otvtotal#i#'))><cfqueryparam cfsqltype="cf_sql_float" value ="#evaluate('arguments.row_otvtotal#i#')#"><cfelse>NULL</cfif>,
                        <cfif isdefined('arguments.basket_extra_info#i#') and len(evaluate('arguments.basket_extra_info#i#'))><cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('arguments.basket_extra_info#i#')#"><cfelse>NULL</cfif>,
                        <cfif isdefined('arguments.select_info_extra#i#') and len(evaluate('arguments.select_info_extra#i#'))><cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('arguments.select_info_extra#i#')#"><cfelse>NULL</cfif>,
                        <cfif isdefined('arguments.detail_info_extra#i#') and len(evaluate('arguments.detail_info_extra#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('arguments.detail_info_extra#i#')#"><cfelse>NULL</cfif>,
                       <cfqueryparam cfsqltype="cf_sql_float" value = "#DISCOUNT_AMOUNT#">,
                        <cfqueryparam cfsqltype="cf_sql_float" value ="#evaluate("arguments.row_lasttotal#i#")#">,
                        <cfqueryparam cfsqltype="cf_sql_float" value ="#evaluate("arguments.row_nettotal#i#")#">,
                        <cfif isdefined('arguments.list_price#i#') and len(evaluate('arguments.list_price#i#'))><cfqueryparam cfsqltype="cf_sql_float" value ="#evaluate('arguments.list_price#i#')#"><cfelse>NULL</cfif>,
                        <cfif isdefined('arguments.price_cat#i#') and len(evaluate('arguments.price_cat#i#'))><cfqueryparam cfsqltype="cf_sql_integer" value ="#evaluate('arguments.price_cat#i#')#"><cfelse>NULL</cfif>,
                        <cfif isdefined('arguments.row_catalog_id#i#') and len(evaluate('arguments.row_catalog_id#i#'))><cfqueryparam cfsqltype="cf_sql_integer" value ="#evaluate('arguments.row_catalog_id#i#')#"><cfelse>NULL</cfif>,
                        <cfif isdefined('arguments.karma_product_id#i#') and len(evaluate('arguments.karma_product_id#i#'))><cfqueryparam cfsqltype="cf_sql_integer" value ="#evaluate('arguments.karma_product_id#i#')#"><cfelse>NULL</cfif>,
                       <cfqueryparam cfsqltype="cf_sql_float" value =" #evaluate("arguments.row_taxtotal#i#")#">,
                        <cfif isdefined('arguments.wrk_row_id#i#') and len(evaluate('arguments.wrk_row_id#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('arguments.wrk_row_id#i#')#"><cfelse>NULL</cfif>,
                        <cfif isdefined('arguments.wrk_row_relation_id#i#') and len(evaluate('arguments.wrk_row_relation_id#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('arguments.wrk_row_relation_id#i#')#"><cfelse>NULL</cfif>,
                        <cfif isdefined('arguments.row_width#i#') and len(evaluate('arguments.row_width#i#'))><cfqueryparam cfsqltype="cf_sql_float" value =" #evaluate('arguments.row_width#i#')#"><cfelse>NULL</cfif>,
                        <cfif isdefined('arguments.row_depth#i#') and len(evaluate('arguments.row_depth#i#'))><cfqueryparam cfsqltype="cf_sql_float" value =" #evaluate('arguments.row_depth#i#')#"><cfelse>NULL</cfif>,
                        <cfif isdefined('arguments.row_height#i#') and len(evaluate('arguments.row_height#i#'))><cfqueryparam cfsqltype="cf_sql_float" value =" #evaluate('arguments.row_height#i#')#"><cfelse>NULL</cfif>,
                        <cfif isdefined('arguments.row_project_id#i#') and len(evaluate('arguments.row_project_id#i#')) and isdefined('arguments.row_project_name#i#') and len(evaluate('arguments.row_project_name#i#'))><cfqueryparam cfsqltype="cf_sql_integer" value =" #evaluate('arguments.row_project_id#i#')#"><cfelse>NULL</cfif>
                        )
                    </cfquery>
                </cfloop>
                <cfscript>
                    if (not isdefined("new_dsn")) new_dsn = dsn; //action file vb dosyalardan tanim farkli gelebiliyor, bunun icin boyle bir duzenleme yapildi fbs 20110906
                    basket_kur_ekle(action_id:arguments.upd_id,table_type_id:14,process_type:1,transaction_dsn:dsn,basket_money_db:new_dsn);
                </cfscript>
            </cftransaction>
        </cflock>
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
</cffunction>
<cffunction name="del"  access="remote" returntype="any">
    <cfargument  name="upd_id" default="">
    <cfset attributes = arguments>
    <cfset responseStruct = structNew()>
    <cf_get_lang_set module_name="project">
    <cftry>
        <cflock name="#CreateUUID()#" timeout="20">
            <cftransaction>
                <cfquery name="DEL_PRO_MONEY" datasource="#dsn#">
                    DELETE FROM PRO_MATERIAL_MONEY WHERE ACTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.upd_id#">
                </cfquery>
                <cfquery name="DEL_PRO_MAT_ROW" datasource="#dsn#">
                    DELETE FROM	PRO_MATERIAL_ROW WHERE PRO_MATERIAL_ID=<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.upd_id#">
                </cfquery>
                <cfquery name="DEL_PRO_MATERIAL" datasource="#dsn#">
                    DELETE FROM	PRO_MATERIAL WHERE PRO_MATERIAL_ID=<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.upd_id#">
                </cfquery>
            </cftransaction>
        </cflock>
        <cfset responseStruct.message = "#getlang('','İşlem Başarılı',61210)#">
        <cfset responseStruct.status = true>
        <cfset responseStruct.error = {}>
        <cfset responseStruct.identity =  ''>
       <cfcatch>
           <cfset responseStruct.message = "#getlang('','işlem hatalı',65894)#">
           <cfset responseStruct.status = false>
           <cfset responseStruct.error = cfcatch>
       </cfcatch>
   </cftry>
  
   <cfreturn responseStruct>
</cffunction>


</cfcomponent>
