
<cfparam name="attributes.consumer_reference_code" default=""> 
<cfparam name="attributes.partner_reference_code" default="">
<cf_get_lang_set module_name="sales"><!--- sayfanin en altinda kapanisi var --->
<cf_xml_page_edit fuseact ="objects.popup_add_spect_list" default_value="1">
<cf_xml_page_edit fuseact ="sales.form_add_order">
<div style="display:none;z-index:9999;left:325px;" id="phl_div"></div>
<!--- Bu spec'in ayarlarını çekmek için! --->
<cfset modul_ = "sales">
<cfset xfa.add = '#modul_#.emptypopup_add_order'>
<cfscript> 
	if (isdefined("url.company_id") and len(url.company_id)){
		attributes.comp_id = url.company_id;
		session_basket_kur_ekle(process_type:0);
	}
	else if(isdefined("url.consumer_id") and len(url.consumer_id)){
		attributes.cons_id = url.consumer_id;
		session_basket_kur_ekle(process_type:0);
	}
	else if(isdefined("attributes.order_id") and len(attributes.order_id))
		session_basket_kur_ekle(process_type:1,table_type_id:3,action_id:attributes.ORDER_ID);
	else if(isDefined("attributes.offer_id") and len(attributes.offer_id))
		session_basket_kur_ekle(process_type:1,table_type_id:4,to_table_type_id:3,action_id:attributes.offer_id);
	else
		session_basket_kur_ekle(process_type:0);
</cfscript>
<cfset cmp = createObject("component","V16.settings.cfc.setupCountry") />
<cfset GET_COUNTRY_1 = cmp.getCountry()>
<cfquery name="GET_SALE_ZONES" datasource="#DSN#">
	SELECT
		CASE
			WHEN LEN(SLI.ITEM) > 0 THEN SLI.ITEM
			ELSE SZ_NAME
		END AS SZ_NAME,
		SZ_ID
	FROM 
		SALES_ZONES 
		LEFT JOIN SETUP_LANGUAGE_INFO SLI ON SLI.UNIQUE_COLUMN_ID = SALES_ZONES.SZ_ID
		AND SLI.COLUMN_NAME = <cfqueryparam cfsqltype="cf_sql_varchar" value="SZ_NAME">
		AND SLI.TABLE_NAME = <cfqueryparam cfsqltype="cf_sql_varchar" value="SALES_ZONES">
		AND SLI.LANGUAGE = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.ep.language#">
	WHERE 
		IS_ACTIVE=1 
	ORDER BY SZ_NAME
</cfquery>

<cfparam name="attributes.deliver_dept_name" default="">
<cfparam name="attributes.deliver_dept_id" default="">
<cfparam name="attributes.deliver_loc_id" default="">
<cfparam name="attributes.branch_id" default="">
<cfparam name="attributes.country_id1" default="">
<cfparam name="attributes.sales_zone_id" default="">

<cfinclude template="../query/get_priorities.cfm">
<cfinclude template="../query/get_moneys.cfm">
<cfinclude template="../query/get_commethod_cats.cfm">
<cfset attributes.order_head = "#getlang(223,'Siparişiniz',41346)#">
<cfif not isdefined("attributes.order_date")>
	<cfset attributes.order_date = DateFormat(now(),dateformat_style)>
	<cfset attributes.ship_date = DateFormat(now(),dateformat_style)>
	<cfset attributes.deliverdate = DateFormat(now(),dateformat_style)>
<cfelse>
	<cfset attributes.order_date = attributes.order_date>
	<cfset attributes.ship_date = attributes.order_date>
	<cfset attributes.deliverdate = attributes.order_date>
</cfif>
<cfset attributes.ref_company_id = "">
<cfset attributes.ref_member_type = "">
<cfset attributes.ref_member_id = "">
<cfif not (isdefined("attributes.order_employee_id") and Len(attributes.order_employee_id))>
	<cfset attributes.order_employee_id = session.ep.userid>
</cfif>
<cfparam name="attributes.basket_due_value_date_" default= "#DateFormat(now(),dateformat_style)#">
<cfif isDefined("attributes.subscription_id") and len(attributes.subscription_id)><!--- sistemden sipariş ekleme ekranı için --->
	<cfinclude template="../query/get_subsciption_contract.cfm">
	<cfset attributes.order_head = "SİSTEM #get_subscription.subscription_no#&nbsp;#get_subscription.subscription_type#&nbsp;#montage_emp_#">
	<cfif isDefined("xml_is_invoice_member")><!--- sistemden fatura şirketine sipariş oluştursn xml i seçili oldgunda --->
		 <cfset attributes.company_id = get_subscription.invoice_company_id> 
		<cfset attributes.partner_id = get_subscription.invoice_partner_id>
		<cfset attributes.consumer_id = get_subscription.invoice_consumer_id>
	<cfelse>
		 <cfset attributes.company_id = get_subscription.company_id> 
		<cfset attributes.partner_id = get_subscription.partner_id>
		<cfset attributes.consumer_id = get_subscription.consumer_id>
	</cfif>
	<cfset attributes.deliver_comp_id = get_subscription.company_id>
	<cfset attributes.deliver_cons_id = get_subscription.consumer_id>
	<cfif len(get_subscription.ref_partner_id)>
		<cfset attributes.ref_company_id = get_subscription.ref_company_id>
		<cfset attributes.ref_member_type = "partner">
		<cfset attributes.ref_member_id = get_subscription.ref_partner_id>
		<cfset attributes.ref_company = get_par_info(get_subscription.ref_company_id,1,0,0)>
		<cfset attributes.ref_member = get_par_info(get_subscription.ref_partner_id,0,-1,0)>
	<cfelseif len(get_subscription.ref_consumer_id)>
		<cfset attributes.ref_company_id = get_subscription.ref_company_id>
		<cfset attributes.ref_member_type = "consumer">
		<cfset attributes.ref_member_id = get_subscription.ref_consumer_id>
		<cfset attributes.ref_company = get_cons_info(get_subscription.ref_consumer_id,2,0)>
		<cfset attributes.ref_member = get_cons_info(get_subscription.ref_consumer_id,0,0,0)>
	</cfif>
	<cfif len(get_subscription.sales_partner_id)>
		<cfset attributes.sales_member_id = get_subscription.sales_partner_id>
		<cfset attributes.sales_member_type = "partner">
		<cfset attributes.sales_member = get_par_info(get_subscription.sales_partner_id,0,-1,0)>
	<cfelseif len(get_subscription.sales_consumer_id)>
		<cfset attributes.sales_member_id = get_subscription.sales_consumer_id>
		<cfset attributes.sales_member_type = "consumer">
		<cfset attributes.sales_member = get_cons_info(get_subscription.sales_consumer_id,1,0)>	
	</cfif>
	<cfset attributes.ship_city_id = get_subscription.ship_city_id>
	<cfset attributes.ship_address_county_id = get_subscription.ship_county_id>
	<cfset attributes.ship_address = get_subscription.ship_address>
	<cfset attributes.ship_address_id_ = ''>
<cfelseif isdefined('attributes.from_project_material')><!--- Proje Malzeme İhtiyaç Planından ekleme yapmak için. --->
	<cfinclude template="../query/get_project_metarial.cfm">
	<cfif not isdefined('attributes.from_project_material_id')>
		<cfquery name="GET_PRO_MATERIAL_IDS" datasource="#DSN#"><!--- Eğer proje id'si geliyorsa bu projeye ait metarial id'lerini buluyoruz--->
			SELECT PRO_MATERIAL_ID FROM PRO_MATERIAL WHERE PROJECT_ID = #attributes.from_project_material#
		</cfquery>
		<cfif GET_PRO_MATERIAL_IDS.recordcount>
			<cfset attributes.from_project_material_id = ValueList(GET_PRO_MATERIAL_IDS.PRO_MATERIAL_ID,',')>
		</cfif>
	</cfif>
<cfelseif isdefined("attributes.opp_id") and len(attributes.opp_id)>
	<!---Fırsat - teklif ilişkisi --->
	<cfscript>session_basket_kur_ekle(process_type:0);</cfscript>
	<cfset attributes.purchase_sales = 1>
	<cfquery name="get_opportunities" datasource="#DSN3#">
		SELECT * FROM OPPORTUNITIES WHERE OPP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.opp_id#">
	</cfquery>
	<cfset attributes.subject = get_opportunities.opp_head>
	<cfset attributes.company_id = get_opportunities.company_id>
	<cfset attributes.partner_id = get_opportunities.partner_id>
	<cfset attributes.consumer_id = get_opportunities.consumer_id>
	<cfset attributes.sales_partner_id = get_opportunities.sales_partner_id>
	<cfset attributes.sales_consumer_id = get_opportunities.sales_consumer_id>
	<cfset attributes.project_id = get_opportunities.project_id>
	<cfset attributes.sales_add_option_id = get_opportunities.sale_add_option_id>
	<cfset attributes.sales_emp_id = get_opportunities.sales_emp_id>
	<cfset attributes.ref_company_id = get_opportunities.ref_company_id>
	<cfset attributes.ref_partner_id = get_opportunities.ref_partner_id>
	<cfset attributes.ref_consumer_id = get_opportunities.ref_consumer_id>
	<cfset attributes.country_id=get_opportunities.country_id>
	<cfset attributes.ref_no=get_opportunities.opp_no>
<cfelseif isdefined("attributes.opportunity_id") and len(attributes.opportunity_id)>
	<!---Fırsat - sipariş al --->
	<cfquery name="get_opportunities" datasource="#DSN3#">
		SELECT * FROM OPPORTUNITIES WHERE OPP_ID = #attributes.opportunity_id#
	</cfquery>
	<cfset attributes.order_head = get_opportunities.opp_head>
	<cfset attributes.company_id = get_opportunities.company_id>
	<cfset attributes.partner_id = get_opportunities.partner_id>
	<cfset attributes.consumer_id = get_opportunities.consumer_id>
	<cfset attributes.deliver_comp_id = get_opportunities.company_id>
	<cfset attributes.deliver_cons_id = get_opportunities.consumer_id>
	<cfif len(get_opportunities.sales_partner_id)>
		<cfset attributes.sales_member_id = get_opportunities.sales_partner_id>
		<cfset attributes.sales_member_type = "partner">
		<cfset attributes.sales_member = get_par_info(get_opportunities.sales_partner_id,0,-1,0)>
	<cfelseif len(get_opportunities.sales_consumer_id)>
		<cfset attributes.sales_member_id = get_opportunities.sales_consumer_id>
		<cfset attributes.sales_member_type = "consumer">
		<cfset attributes.sales_member = get_cons_info(get_opportunities.sales_consumer_id,1,0)>	
	</cfif>
	<cfset attributes.project_id = get_opportunities.project_id>
	<cfset attributes.sales_add_option_id = get_opportunities.sale_add_option_id>
	<cfset attributes.sales_emp_id = get_opportunities.sales_emp_id>
	<cfif len(get_opportunities.ref_partner_id)>
		<cfset attributes.ref_company_id = get_opportunities.ref_company_id>
		<cfset attributes.ref_member_type = "partner">
		<cfset attributes.ref_member_id = get_opportunities.ref_partner_id>
		<cfset attributes.ref_company = get_par_info(get_opportunities.ref_company_id,1,0,0)>
		<cfset attributes.ref_member = get_par_info(get_opportunities.ref_partner_id,0,-1,0)>
	<cfelseif len(get_opportunities.ref_consumer_id)>
		<cfset attributes.ref_company_id = get_opportunities.ref_company_id>
		<cfset attributes.ref_member_type = "consumer">
		<cfset attributes.ref_member_id = get_opportunities.ref_consumer_id>
		<cfset attributes.ref_company = get_cons_info(get_opportunities.ref_consumer_id,2,0)>
		<cfset attributes.ref_member = get_cons_info(get_opportunities.ref_consumer_id,0,0,0)>
	</cfif>
    <cfset attributes.country_id1=get_opportunities.country_id>
    <cfset attributes.sales_zone_id=get_opportunities.sz_id>
    <cfset attributes.ref_no=get_opportunities.opp_no>
<cfelseif isdefined("attributes.order_id") and len(attributes.order_id) and not isdefined("attributes.upd_order")><!--- Siparis Kopyalama --->
	<cfinclude template="../query/get_order_detail.cfm">
	<cfset attributes.order_head = get_order_detail.order_head>
	<cfset attributes.order_detail = get_order_detail.order_detail>
	 <cfset attributes.company_id = get_order_detail.company_id> 
	<cfset attributes.partner_id = get_order_detail.partner_id>
	<cfset attributes.consumer_id = get_order_detail.consumer_id>
	<cfset attributes.order_date = DateFormat(get_order_detail.order_date,dateformat_style)>
	<cfset attributes.ship_date = DateFormat(get_order_detail.ship_date,dateformat_style)>
	<cfset attributes.deliverdate = DateFormat(get_order_detail.deliverdate,dateformat_style)>
	<cfset attributes.priority_id = get_order_detail.priority_id>
	<cfset attributes.paymethod_id = get_order_detail.paymethod>
	<cfset attributes.card_paymethod_id = get_order_detail.card_paymethod_id>
	<cfif len(get_order_detail.ref_partner_id)>
		<cfset attributes.ref_company_id = get_order_detail.ref_company_id>
		<cfset attributes.ref_member_type = "partner">
		<cfset attributes.ref_member_id = get_order_detail.ref_partner_id>
		<cfset attributes.ref_company = get_par_info(get_order_detail.ref_company_id,1,0,0)>
		<cfset attributes.ref_member = get_par_info(get_order_detail.ref_partner_id,0,-1,0)>
	<cfelseif len(get_order_detail.ref_consumer_id)>
		<cfset attributes.ref_company_id = get_order_detail.ref_company_id>
		<cfset attributes.ref_member_type = "consumer">
		<cfset attributes.ref_member_id = get_order_detail.ref_consumer_id>
		<cfset attributes.ref_company = get_cons_info(get_order_detail.ref_consumer_id,2,0)>
		<cfset attributes.ref_member = get_cons_info(get_order_detail.ref_consumer_id,0,0,0)>
	</cfif>
	<cfset attributes.partner_reference_code = get_order_detail.partner_reference_code>
	<cfset attributes.consumer_reference_code = get_order_detail.consumer_reference_code>
	<cfset attributes.order_employee_id = get_order_detail.order_employee_id>
	<cfif len(get_order_detail.due_date) and len(get_order_detail.order_date)>
		<cfset attributes.basket_due_value = datediff('d',get_order_detail.order_date,get_order_detail.due_date)>
	</cfif>
	<cfif len(get_order_detail.due_date)>
		<cfset attributes.basket_due_value_date_ = DateFormat(get_order_detail.due_date,dateformat_style)>
	</cfif>
	<cfif len(get_order_detail.sales_partner_id)>
		<cfset attributes.sales_member_id = get_order_detail.sales_partner_id>
		<cfset attributes.sales_member_type = "partner">
		<cfset attributes.sales_member = get_par_info(get_order_detail.sales_partner_id,0,-1,0)>
	<cfelseif len(get_order_detail.sales_consumer_id)>
		<cfset attributes.sales_member_id = get_order_detail.sales_consumer_id>
		<cfset attributes.sales_member_type = "consumer">
		<cfset attributes.sales_member = get_cons_info(get_order_detail.sales_consumer_id,1,0)>	
	</cfif>
	<cfset attributes.ship_method_id = get_order_detail.ship_method>
	<cfset attributes.commethod_id = get_order_detail.commethod_id>
	<cfset attributes.project_id = get_order_detail.project_id>
	<cfset attributes.offer_id = get_order_detail.offer_id>
	<cfset attributes.reserved = get_order_detail.reserved>
	<cfset attributes.sales_add_option_id = get_order_detail.sales_add_option_id>
	<cfset attributes.ref_no = get_order_detail.ref_no>
	<cfset attributes.ship_city_id = get_order_detail.city_id>
	<cfset attributes.ship_address_county_id = get_order_detail.county_id>
	<cfset attributes.ship_address = get_order_detail.ship_address>
	<cfset attributes.ship_address_id_ = get_order_detail.ship_address_id>
    <cfset attributes.country_id1=get_order_detail.country_id>
    <cfset attributes.sales_zone_id=get_order_detail.zone_id>
	<cfif len(get_order_detail.deliver_dept_id) and len(get_order_detail.location_id)>
		<cfset location_info_ = get_location_info(get_order_detail.deliver_dept_id,get_order_detail.location_id,1,1)>
		<cfset attributes.branch_id = listlast(location_info_,',')>
		<cfset attributes.deliver_loc_id = get_order_detail.location_id>
		<cfset attributes.deliver_dept_id = get_order_detail.deliver_dept_id>
		<cfset attributes.deliver_dept_name = listfirst(location_info_,',')>
	</cfif>
	<cfset attributes.deliver_comp_id = get_order_detail.deliver_comp_id>
	<cfset attributes.deliver_cons_id = get_order_detail.deliver_cons_id>
	<cfset attributes.related_subs_id = get_order_detail.subscription_id><!--- ayrı bir değişkenle takip edildi çünkü sistemden sipariş oluşturma ile karışıyordu yoksa --->
<cfelseif not isdefined("attributes.order_id") and isdefined("attributes.project_id") and len(attributes.project_id) and not isdefined("attributes.upd_order")>
	<cfquery name="get_project" datasource="#dsn#">
		SELECT COMPANY_ID,PARTNER_ID,CONSUMER_ID,PROJECT_ID FROM PRO_PROJECTS WHERE PROJECT_ID = #attributes.project_id#
	</cfquery>
	<cfset attributes.company_id = get_project.company_id>
	<cfset attributes.partner_id = get_project.partner_id>
	<cfset attributes.consumer_id = get_project.consumer_id>
<cfelseif isDefined("offer_row_check_info") and Len(offer_row_check_info)><!--- Satir Bazinda Teklif - Siparise Donusturme --->
	<cfif isDefined("attributes.company_id") and Len(attributes.company_id)>
		<cfquery name="get_partner" datasource="#dsn#">
			SELECT MANAGER_PARTNER_ID FROM COMPANY WHERE COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.company_id#">
		</cfquery>
		<cfset attributes.partner_id = get_partner.manager_partner_id>
	</cfif>
<cfelseif isDefined("attributes.offer_id") and Len(attributes.offer_id)><!--- Belge Bazinda --->
	<cfinclude template="../query/get_offer.cfm">
	<cfset attributes.order_head = get_offer.offer_head>
    <cfset attributes.work_id = get_offer.work_id>
    <cfset attributes.offer_head = get_offer.offer_head>
	<cfset attributes.order_detail = get_offer.offer_detail>
	<cfif ListLen(ListSort(ListDeleteDuplicates(ValueList(get_offer.partner_id)),"numeric","asc",",")) eq 1>
		<cfscript>  
			attributes.comp_id = get_offer.company_id;
		</cfscript>
		<cfset attributes.company_id = get_offer.company_id> 
		<cfset attributes.partner_id = get_offer.partner_id>
	<cfelse>
		<cfset attributes.company_id = ""> 
		<cfset attributes.partner_id = "">
	</cfif>
	<cfif ListLen(ListSort(ListDeleteDuplicates(ValueList(get_offer.consumer_id)),"numeric","asc",",")) eq 1>
		<cfscript>  
			attributes.cons_id = get_offer.company_id;
		</cfscript>
		<cfset attributes.consumer_id = get_offer.consumer_id>
	<cfelse>
		<cfset attributes.consumer_id = "">
	</cfif>
	<cfset attributes.ship_date = DateFormat(get_offer.ship_date,dateformat_style)>
	<cfset attributes.deliverdate = DateFormat(get_offer.deliverdate,dateformat_style)>
	<cfset attributes.priority_id = get_offer.priority_id>
	<cfset attributes.paymethod_id = get_offer.paymethod>
	<cfset attributes.commethod_id = get_offer.commethod_id>
	<cfset attributes.card_paymethod_id = get_offer.card_paymethod_id>
    <cfset attributes.country_id1=get_offer.country_id>
    <cfset attributes.sales_zone_id=get_offer.sz_id>
	<cfif len(get_offer.ref_partner_id)>
		<cfset attributes.ref_company_id = get_offer.ref_company_id>
		<cfset attributes.ref_member_type = "partner">
		<cfset attributes.ref_member_id = get_offer.ref_partner_id>
		<cfset attributes.ref_company = get_par_info(get_offer.ref_company_id,1,0,0)>
		<cfset attributes.ref_member = get_par_info(get_offer.ref_partner_id,0,-1,0)>
	<cfelseif len(get_offer.ref_consumer_id)>
		<cfset attributes.ref_company_id = get_offer.ref_company_id>
		<cfset attributes.ref_member_type = "consumer">
		<cfset attributes.ref_member_id = get_offer.ref_consumer_id>
		<cfset attributes.ref_company = get_cons_info(get_offer.ref_consumer_id,2,0)>
		<cfset attributes.ref_member = get_cons_info(get_offer.ref_consumer_id,0,0,0)>
	</cfif>
	<cfset attributes.order_employee_id = get_offer.sales_emp_id>
	<cfset attributes.basket_due_value_date_ = attributes.basket_due_value_date_>
	<cfif len(get_offer.sales_partner_id)>
		<cfset attributes.sales_member_id = get_offer.sales_partner_id>
		<cfset attributes.sales_member_type = "partner">
		<cfset attributes.sales_member = get_par_info(get_offer.sales_partner_id,0,-1,0)>
	<cfelseif len(get_offer.sales_consumer_id)>
		<cfset attributes.sales_member_id = get_offer.sales_consumer_id>
		<cfset attributes.sales_member_type = "consumer">
		<cfset attributes.sales_member = get_cons_info(get_offer.sales_consumer_id,1,0)>	
	</cfif>
	<cfset attributes.ship_method_id = get_offer.ship_method>
	<cfset attributes.commethod_id = get_offer.commethod_id>
	<cfset attributes.project_id = get_offer.project_id>
	<cfset attributes.offer_id = get_offer.offer_id>
	<cfset attributes.sales_add_option_id = get_offer.sales_add_option_id>
	<cfset attributes.ref_no = get_offer.ref_no>
	<cfset attributes.ship_city_id = get_offer.city_id>
	<cfset attributes.ship_address_county_id = get_offer.county_id>
	<cfset attributes.ship_address = get_offer.ship_address>
	<cfset attributes.ship_address_id_ = get_offer.ship_address_id>
<cfelseif isdefined("attributes.upd_order")>
	<cfinclude template="add_all_of_product_order.cfm">
	<cfif len(attributes.related_order_id) and len(attributes.related_order_no)>
		<cfset attributes.ref_no = attributes.related_order_no>
		<cfset attributes.order_id = attributes.related_order_id>
		<cfinclude template="../query/get_order_detail.cfm">
	</cfif>
<cfelseif isDefined("attributes.req_id")>
	<cfquery datasource="#dsn3#" name="query_textile_request">
		SELECT SR.*, CMP.NICKNAME FROM TEXTILE_SAMPLE_REQUEST SR
		INNER JOIN #dsn#.COMPANY CMP ON SR.COMPANY_ID = CMP.COMPANY_ID
		 WHERE SR.REQ_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.req_id#">
	</cfquery>
	<cfif query_textile_request.recordCount gt 0>
		<cfset attributes.order_head = query_textile_request.REQ_NO & " - " & query_textile_request.NICKNAME>
	</cfif>
</cfif>
<cf_catalystHeader>

	<cf_box>
		<div id="basket_main_div">
		<cfform name="form_basket">
			<cf_basket_form id="detail_inv_menu">
				<cfoutput>
					<cfif isdefined("attributes.opportunity_id")><input type="hidden" name="opportunity_id" id="opportunity_id" value="#attributes.opportunity_id#"></cfif>
					<input type="hidden" name="form_action_address" id="form_action_address" value="#xfa.add#">
					<input type="hidden" name="is_auto_spec_create" id="is_auto_spec_create" value="#is_auto_spec_create#">
					<input type="hidden" name="is_spect_name_to_property" id="is_spect_name_to_property" value="#is_spect_name_to_property#">    
					<!--- Ziyaret Sonucundan olusturulan siparis iliskilerinin tutulmasi icin gonderiliyor, kaldirmayin FBS 20110422 --->
					<cfif isDefined("url.related_action_table")><input type="hidden" name="related_action_table_main" id="related_action_table_main" value="#url.related_action_table#"></cfif>
					<cfif isDefined("url.related_action_id")><input type="hidden" name="related_action_id_main" id="related_action_id_main" value="#url.related_action_id#"></cfif>
					<!--- //Ziyaret Sonucundan olusturulan siparis iliskilerinin tutulmasi icin gonderiliyor, kaldirmayin FBS 20110422 --->
					<input type="hidden" name="x_required_dep" id="x_required_dep" value="#x_required_dep#" />
					<input type="hidden" name="active_company" id="active_company" value="#session.ep.company_id#"> 
					<input type="hidden" name="search_process_date" id="search_process_date" value="deliverdate">
					<input type="hidden" name="search_process_date_paper" id="search_process_date_paper" value="order_date">
					<input type="hidden" name="pro_material_id_list" id="pro_material_id_list" value="<cfif isdefined('attributes.from_project_material_id') and len(attributes.from_project_material_id)>#attributes.from_project_material_id#</cfif>">
				</cfoutput>
				<cfinclude template="add_order_noeditor.cfm">
			</cf_basket_form>
			<cfset attributes.basket_id = 4>
			<cfif isDefined("attributes.subscription_id") and len(attributes.subscription_id)>
				<cfset attributes.basket_id = 46>
				<cfset attributes.basket_sub_id = 46>
			<cfelseif session.ep.isBranchAuthorization and isdefined("attributes.order_id") and len(attributes.order_id)>
				<cfset attributes.basket_id = 38>
				<cfif isdefined("attributes.order_id") and len(attributes.order_id)>
					<cfset attributes.is_copy = 1>
				</cfif>
			<cfelseif isdefined('attributes.demand_id') and len(attributes.demand_id)>
				<cfset attributes.basket_related_action = 1>
			<cfelseif isdefined("attributes.order_id") and len(attributes.order_id)>
				<cfset attributes.is_copy = 1>
			<cfelseif (isDefined("attributes.offer_id") and Len(attributes.offer_id)) or isDefined("offer_row_check_info")>
				<cfset attributes.offer_to_order=1>
				<cfset attributes.basket_id = 4>
			<cfelseif isDefined("attributes.from_project_material_id") and Len(attributes.from_project_material_id)>
				<cfset attributes.basket_id = 4>
			<cfelseif isDefined("attributes.opp_id") and Len(attributes.opp_id)>
				<cfset attributes.basket_id = 4>
			<cfelse>
				<cfif not isdefined("attributes.file_format") and not isdefined('attributes.from_add_order_report')>
					<cfset attributes.form_add = 1>
				<cfelse>
					<cfset attributes.basket_sub_id = 21>
				</cfif>
			</cfif>
			<cfinclude template="../../objects/display/basket.cfm">
		</cfform>
	</div>
	</cf_box>

<script type="text/javascript">
function open_member_page()
{
	<cfoutput>
		if(document.form_basket.company_id.value != '')
			openBoxDraggable('#request.self#?fuseaction=objects.popup_com_det&company_id='+document.form_basket.company_id.value,'medium');
		
		else if(document.form_basket.consumer_id.value != '')
			openBoxDraggable('#request.self#?fuseaction=objects.popup_con_det&con_id='+document.form_basket.consumer_id.value,'medium');
		else
		{
			alert("<cfoutput>#getLang('','Müşteri Seçiniz',41104)#</cfoutput>!");
			return false;
		}
	</cfoutput>
}
function open_contract_page()
{
	<cfoutput>
		if(document.form_basket.company_id.value != '')
			windowopen('#request.self#?fuseaction=objects.popup_list_basket_contract&company_id='+document.form_basket.company_id.value,'wwide1');
		else if(document.form_basket.consumer_id.value != '')
			windowopen('#request.self#?fuseaction=objects.popup_list_basket_contract&consumer_id='+document.form_basket.consumer_id.value,'wwide1');
		else
		{
			alert("<cfoutput>#getLang('','Müşteri Seçiniz',41104)#</cfoutput> !");
			return false;
		}
	</cfoutput>
}
function show_member_button()
{
	if(document.form_basket.company_id.value != '' || document.form_basket.consumer_id.value != '')
	{
		member_page.style.display = '';
		member_page_1.style.display = '';
	}
	else
	{
		member_page.style.display = 'none';
		member_page_1.style.display = 'none';
	}
}

function kontrol()
{
	
	var listParam = document.getElementById('deliver_dept_id').value + "*" + document.getElementById('deliver_loc_id').value;
		var get_is_no_sale = wrk_safe_query("get_is_no_sale",'dsn',0,listParam);
	if(get_is_no_sale.recordcount)
	{
	    var is_sale_=get_is_no_sale.NO_SALE;
	    if(is_sale_==1)
		{
			alert("<cfoutput>#getlang('stock',223)#</cfoutput>!");
			return false;
		}
	}
	if(form_basket.order_head.value == "")
	{
		alert("<cfoutput>#getLang('','Başlık Girmelisiniz',58059)#</cfoutput>!");	
		return false;
	}
	if(form_basket.company_id.value == "" && form_basket.consumer_id.value == "")
	{
		alert("<cfoutput>#getLang('','Cari Hesap Secmelisiniz',41056)#</cfoutput>!");	
		return false;
	}
	if ((form_basket.order_employee_id.value.length == 0) || (form_basket.order_employee.value.length == 0))
	{
		alert("<cfoutput>#getLang('','Satış Yapan',40903)#</cfoutput>!");
		return false;
	}
	if (form_basket.deliverdate.value.length == 0)
	{
		alert("<cfoutput>#getLang('','Teslim Tarihi Girmelisiniz',40987)#</cfoutput>!");
		return false;
	}
	
	if (!date_check(form_basket.order_date,form_basket.deliverdate,"<cfoutput>#getLang('','Sipariş Teslim Tarihi, Sipariş Tarihinden Önce Olamaz',40922)#</cfoutput>!"))
		return false;
	if(document.form_basket.ship_date.value != '')
		if (!date_check(document.form_basket.order_date,document.form_basket.ship_date,"<cfoutput>#getLang('','Sipariş Sevk Tarihi, Sipariş Tarihinden Önce Olamaz',66134)#</cfoutput> !"))
			return false;
	<cfif xml_reserved_stock_control eq 1>
		if (form_basket.reserved.checked == true)
		{
			//sıfır stok
			var basket_zero_stock_status = wrk_safe_query('sls_bsk_z_stk_stt','dsn3',0,<cfoutput>#attributes.basket_id#</cfoutput>);
			if(basket_zero_stock_status.IS_SELECTED != 1)//<!--- basket sablonlarında sıfır stok ile calıs secilmemisse zero_stock kontrolu yapılıyor --->
			{
				if(!zero_stock_control('','',0,'',1)) return false;
			}
		}
	<cfelse>
		//sıfır stok
		var basket_zero_stock_status = wrk_safe_query('sls_bsk_z_stk_stt','dsn3',0,<cfoutput>#attributes.basket_id#</cfoutput>);
		if(basket_zero_stock_status.IS_SELECTED != 1)//<!--- basket sablonlarında sıfır stok ile calıs secilmemisse zero_stock kontrolu yapılıyor --->
		{
			if(!zero_stock_control('','',0,'',1)) return false;
		}
	</cfif>
	<cfif isdefined("xml_sales_delivery_date_calculated") and xml_sales_delivery_date_calculated eq 1>
			change_paper_duedate('deliverdate');
		<cfelse>
			change_paper_duedate('order_date');
		</cfif>
	<cfif isdefined("xml_upd_row_project") and xml_upd_row_project eq 1>
		project_field_name = 'project_head';
	<cfelse>
		project_field_name = '';
	</cfif>
	<cfif isdefined('x_apply_deliverdate_to_rows') and x_apply_deliverdate_to_rows eq 1>
		date_field_name = 'deliverdate';
	<cfelse>
		date_field_name = '';
	</cfif>
	apply_deliver_date(date_field_name,project_field_name);
	return (process_cat_control() && saveForm());
}
function open_phl() {
		document.getElementById("phl_div").style.display ='';	
		$("#phl_div").css('margin-left',$("#tabMenu").position().left - 700);
		$("#phl_div").css('margin-top',$("#tabMenu").position().top + 50);
		$("#phl_div").css('position','absolute');	
		AjaxPageLoad('<cfoutput>#request.self#?fuseaction=objects.add_order_from_file&from_where=4</cfoutput>','phl_div',1);
		return false;
	}
function openmodal(){
	if(!(form_basket.company_id.value == "" ) || !(form_basket.consumer_id.value == "" )){
		openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.basket_in_basket_choose&company_id='+form_basket.company_id.value+'&consumer_id='+form_basket.consumer_id.value+'&member_type='+form_basket.member_type.value+'&member_name='+form_basket.company.value);
	}
	else{
		alert("<cfoutput>#getLang('','Cari Hesap Secmelisiniz',41056)#</cfoutput>");
		return false;
	}

}
function add_adress()
{
	if(!(form_basket.company_id.value=="") || !(form_basket.consumer_id.value==""))
	{
		if(form_basket.company_id.value!="")
			{
				str_adrlink = '&field_long_adres=form_basket.ship_address&field_adress_id=form_basket.ship_address_id';
				str_adrlink = str_adrlink+'&company_id='+form_basket.company_id.value+'&member_type=partner&member_name='+encodeURIComponent(form_basket.company.value)+'';
//				str_adrlink = str_adrlink+'&company_id='+form_basket.company_id.value+'&member_type='+form_basket.member_type.value+'&member_name='+encodeURIComponent(form_basket.company.value)+'';
				if(form_basket.ship_address_city_id!=undefined) str_adrlink = str_adrlink+'&field_city=form_basket.ship_address_city_id';
				if(form_basket.ship_address_county_id!=undefined) str_adrlink = str_adrlink+'&field_county=form_basket.ship_address_county_id&field_id=form_basket.deliver_comp_id';
				openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_member_address&is_comp=1&select_list=1'+ str_adrlink);
				document.getElementById('deliver_cons_id').value = '';
				return true;
			}
		else
			{
				str_adrlink = '&field_long_adres=form_basket.ship_address&field_adress_id=form_basket.ship_address_id'; 
				str_adrlink = str_adrlink+'&consumer_id='+form_basket.consumer_id.value+'&member_type=consumer&member_name='+encodeURIComponent(form_basket.member_name.value)+'';
//				str_adrlink = str_adrlink+'&consumer_id='+form_basket.consumer_id.value+'&member_type='+form_basket.member_type.value+'&member_name='+encodeURIComponent(form_basket.member_name.value)+'';
				if(form_basket.ship_address_city_id!=undefined) str_adrlink = str_adrlink+'&field_city=form_basket.ship_address_city_id';
				if(form_basket.ship_address_county_id!=undefined) str_adrlink = str_adrlink+'&field_county=form_basket.ship_address_county_id&field_id=form_basket.deliver_cons_id';
				openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_member_address&is_comp=0&select_list=2'+ str_adrlink);
				document.getElementById('deliver_comp_id').value = '';
				return true;
			}
	}
	else
	{
		alert("<cfoutput>#getLang('','Cari Hesap Secmelisiniz',41056)#</cfoutput>");
		return false;
	}
}
$(document).ready(
function(){
	//show_member_button();  tab menü id ler düzelince açalım PY
	<cfif isdefined("xml_sales_delivery_date_calculated") and xml_sales_delivery_date_calculated eq 1>
		if(typeof(change_paper_duedate) !== 'undefined')
			change_paper_duedate('deliverdate');
	<cfelse>
		if(typeof(change_paper_duedate) !== 'undefined')
			change_paper_duedate('order_date');
	</cfif>
	}
);

function find_order_f()
{
	if($("#find_order_number").val().length)
	{
		var get_order = wrk_safe_query('sls_get_order','dsn3',0,$("#find_order_number").val());
		if(get_order.recordcount)
			window.location.href = '<cfoutput>#request.self#?fuseaction=sales.list_order&event=upd&order_id=</cfoutput>'+get_order.ORDER_ID[0];
		else
		{
			alert("<cfoutput>#getLang('','Kayıt Bulunamadı',58486)#</cfoutput>!");
			return false;
		}
	}
	else
	{
		alert("<cfoutput>#getLang('','Sipariş Nosu Eksik',41334)#</cfoutput>!");
		return false;
	}
}

</script>
<cf_get_lang_set module_name="#lcase(listgetat(attributes.fuseaction,1,'.'))#"><!--- sayfanin en ustunde acilisi var --->
<cfsetting showdebugoutput="yes"> 