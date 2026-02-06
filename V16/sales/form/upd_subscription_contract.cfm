<cfset contract_cmp = createObject("component","V16.sales.cfc.subscription_contract")>
<cfsetting showdebugoutput="no">
<cf_xml_page_edit fuseact ="sales.upd_subscription_contract">
<cfset GET_MONEY_INFO = contract_cmp.GET_MONEY_INFO(dsn2:dsn2)>
<cfinclude template="../query/get_upd_subscription_contact.cfm">
<cfif not get_subscription.recordcount>
	<cfset hata  = 10>
	<cfinclude template="../../dsp_hata.cfm">
    <cfabort>
</cfif>
<!--- Sistem silmek icin yapilan kontrol --->
<cfset CONTROL_PAYMENT_PLAN = contract_cmp.CONTROL_PAYMENT_PLAN(dsn3:dsn3, subscription_id:attributes.subscription_id)>
<cfset CONTROL_SERVICE = contract_cmp.CONTROL_SERVICE(dsn3:dsn3, subscription_id:attributes.subscription_id)>
<cfset CONTROL_ORDER = contract_cmp.CONTROL_ORDER(dsn3:dsn3, subscription_id:attributes.subscription_id)>
<cfset CONTROL_COUNTER_RESULT = contract_cmp.CONTROL_COUNTER_RESULT(dsn3:dsn3, subscription_id:attributes.subscription_id)>
<cfset GET_SALES_ZONES = contract_cmp.GET_SALES_ZONES()>
<cfset GET_OUR_COMPANIES = contract_cmp.GET_OUR_COMPANIES()>
<cfif xml_control_payment_rows eq 1><!--- xml den ödeme planı satırları kontrol edilsin mi seçeneği seçilmişse --->
	<cfquery name="control_prov_rows" dbtype="query">
		SELECT SUBSCRIPTION_ID FROM CONTROL_PAYMENT_PLAN WHERE IS_COLLECTED_PROVISION = <cfqueryparam cfsqltype="cf_sql_smallint" value="1"> AND IS_PAID = <cfqueryparam cfsqltype="cf_sql_smallint" value="0">
	</cfquery>
</cfif>
<cfset get_ref_state = contract_cmp.get_ref_state(dsn3:dsn3, REFERANCE_STATUS_ID:'#Iif(isdefined("get_subscription.REFERANCE_STATUS_ID") and len(get_subscription.REFERANCE_STATUS_ID),"get_subscription.REFERANCE_STATUS_ID",DE(""))#')>
<cfset county_list = ''>
<cfset city_list = ''>
<cfset country_list = ''>

<cfset county_list = Listappend(county_list,'#get_subscription.ship_county_id#,#get_subscription.invoice_county_id#,#get_subscription.contact_county_id#',',')>
<cfset city_list = ListAppend(city_list,'#get_subscription.ship_city_id#,#get_subscription.invoice_city_id#,#get_subscription.contact_city_id#',',')>
<cfset country_list = ListAppend(country_list,'#get_subscription.ship_country_id#,#get_subscription.invoice_country_id#,#get_subscription.contact_country_id#',',')>

<cfset county_list = ListSort(ListDeleteDuplicates(county_list),'Numeric','ASC',',')>
<cfset city_list = ListSort(ListDeleteDuplicates(city_list),'Numeric','ASC',',')>
<cfset country_list = ListSort(ListDeleteDuplicates(country_list),'Numeric','ASC',',')>
<cfif len(county_list)>
    <cfset GET_COUNTY = contract_cmp.GET_COUNTY(county_list:county_list)>
	<cfset main_county_list = listsort(listdeleteduplicates(valuelist(get_county.county_id,',')),'numeric','ASC',',')>
</cfif>
<cfif len(city_list)>
    <cfset GET_CITY = contract_cmp.GET_CITY(city_list:city_list)>
	<cfset main_city_list = listsort(listdeleteduplicates(valuelist(get_city.city_id,',')),'numeric','ASC',',')>
</cfif>
<cfif len(country_list)>
    <cfset GET_COUNTRY = contract_cmp.GET_COUNTRY(country_list:country_list)>
	<cfset main_country_list = listsort(listdeleteduplicates(valuelist(get_country.country_id,',')),'numeric','ASC',',')>
</cfif>

<cfscript>session_basket_kur_ekle(action_id=attributes.subscription_id,table_type_id:13,process_type:1);</cfscript>
<cfset GET_SUBSCRIPTION_TYPE = contract_cmp.GET_SUBSCRIPTION_TYPE(dsn3:dsn3)>
<cfset GET_SUBS_ADD_OPTION = contract_cmp.GET_SUBS_ADD_OPTION(dsn3:dsn3)>
<cfset GET_SALE_ADD_OPTION = contract_cmp.GET_SALE_ADD_OPTION_F(dsn3:dsn3)>
<!---  --->
<cfquery name="GET_MEMBER_CC" datasource="#DSN#">
	SELECT
	<cfif len(get_subscription.partner_id)>
		CC.COMPANY_CC_ID MEMBER_CC_ID,
		CC.COMPANY_ID MEMBER_ID,
		CC.COMPANY_CC_TYPE MEMBER_CC_TYPE,
		CC.COMPANY_CC_NUMBER MEMBER_CC_NUMBER,
		CC.COMPANY_EX_MONTH MEMBER_EX_MONTH,
		CC.COMPANY_EX_YEAR MEMBER_EX_YEAR
	<cfelse>
		CC.CONSUMER_CC_ID MEMBER_CC_ID,
		CC.CONSUMER_ID MEMBER_ID,
		CC.CONSUMER_CC_TYPE MEMBER_CC_TYPE,
		CC.CONSUMER_CC_NUMBER MEMBER_CC_NUMBER,
		CC.CONSUMER_EX_MONTH MEMBER_EX_MONTH,
		CC.CONSUMER_EX_YEAR MEMBER_EX_YEAR
	</cfif>
	,IS_DEFAULT
	FROM
	<cfif len(get_subscription.partner_id)>
		COMPANY_CC CC
	<cfelse>
		CONSUMER_CC CC
	</cfif>
	WHERE
	<cfif len(get_subscription.partner_id)>
		CC.COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_subscription.company_id#">
	<cfelse>
		CC.CONSUMER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_subscription.consumer_id#">
	</cfif>
		AND IS_DEFAULT = 1
</cfquery>
<!--- 
	FA-09102013
	kredi kartı Gelişmiş şifreleme standartları ile şifrelenmesi. 
	Bu sistemin çalışması için sistem/güvenlik altında kredi kartı şifreleme anahtarlırının tanımlanması gerekmektedir 
--->
<cfscript>
	getCCNOKey = createObject("component", "V16.settings.cfc.setupCcnoKey");
	getCCNOKey.dsn = dsn;
	getCCNOKey1 = getCCNOKey.getCCNOKey1();
	getCCNOKey2 = getCCNOKey.getCCNOKey2();
</cfscript>

<cfif len(get_subscription.partner_id)>
	<cfscript>
		contact_type = "p";
		contact_id = get_subscription.partner_id;
		par_id = get_subscription.partner_id;
	</cfscript>
<cfelseif len(get_subscription.consumer_id)>
	<cfscript>
		contact_type = "c";
		contact_id = get_subscription.consumer_id;
		con_id = get_subscription.consumer_id;
	</cfscript>
<cfelse>
	<cfscript>
		contact_type = '';
		contact_id = '';
	</cfscript>
</cfif>
<cfset GET_COUNTRY = contract_cmp.GET_COUNTRY()>
<!--- basvuru ekle icin eklenen form--->
<form name="add_service" method="post" action="<cfoutput>#request.self#?fuseaction=service.list_service&event=add<cfif isdefined("get_subscription.subscription_id")>&subscrt_id=#get_subscription.subscription_id#</cfif></cfoutput>">
	<input type="hidden" name="subscription_id" id="subscription_id" value="<cfoutput>#get_subscription.subscription_id#</cfoutput>">
	<input type="hidden" name="subscription_no" id="subscription_no" value="<cfoutput>#get_subscription.subscription_no#</cfoutput>">
	<cfset other_shipp_address = ''>
	<cfif len(get_subscription.ship_county_id)>
		<cfset other_shipp_address = get_county.county_name[listfind(main_county_list,get_subscription.ship_county_id,',')]>
	</cfif>
	<cfif len(get_subscription.ship_city_id)>
		<cfset other_shipp_address = other_shipp_address&' '&get_city.city_name[listfind(main_city_list,get_subscription.ship_city_id,',')]>
	</cfif>
	<cfif len(get_subscription.ship_country_id)>
		<cfset other_shipp_address = other_shipp_address&' '&get_country.country_name[listfind(main_country_list,get_subscription.ship_country_id,',')]>
	</cfif>
	<input type="hidden" name="service_address" id="service_address" value="<cfoutput>#get_subscription.ship_address# #get_subscription.ship_postcode# #get_subscription.ship_semt# #other_shipp_address#</cfoutput>">
	<cfoutput>
        <input type="hidden" name="service_county_id" id="service_county_id" value="#get_subscription.ship_county_id#" />
        <input type="hidden" name="service_city_id" id="service_city_id" value="#get_subscription.ship_city_id#" />
        <input type="hidden" name="service_country_id" id="service_country_id" value="#get_subscription.ship_country_id#" />
    </cfoutput>
	<cfif len(get_subscription.partner_id)>
		<input type="hidden" name="member_type" id="member_type" value="partner">
		<input type="hidden" name="member_id" id="member_id" value="<cfoutput>#get_subscription.partner_id#</cfoutput>">
		<input type="hidden" name="company_id" id="company_id" value="<cfoutput>#get_subscription.company_id#</cfoutput>">
	<cfelse>
		<input type="hidden" name="member_type" id="member_type" value="consumer">
		<input type="hidden" name="member_id" id="member_id" value="<cfoutput>#get_subscription.consumer_id#</cfoutput>">
		<input type="hidden" name="company_id" id="company_id" value="">
	</cfif>
</form>
<!--- basvuru listesi icin eklenen form--->
<!--- callcenter basvuru ekle icin eklenen form--->
<form name="add_call_center" method="post" action="<cfoutput>#request.self#</cfoutput>?fuseaction=call.list_service&event=add">
	<input type="hidden" name="subscription_id" id="subscription_id" value="<cfoutput>#get_subscription.subscription_id#</cfoutput>">
	<input type="hidden" name="subscription_no" id="subscription_no" value="<cfoutput>#get_subscription.subscription_no#</cfoutput>">
	<cfif len(get_subscription.partner_id)>
		<input type="hidden" name="consumer_id" id="consumer_id" value="">
		<input type="hidden" name="partner_id" id="partner_id" value="<cfoutput>#get_subscription.partner_id#</cfoutput>">
		<input type="hidden" name="company_id" id="company_id" value="<cfoutput>#get_subscription.company_id#</cfoutput>">
	<cfelse>
		<input type="hidden" name="consumer_id" id="consumer_id" value="<cfoutput>#get_subscription.consumer_id#</cfoutput>">
		<input type="hidden" name="partner_id" id="partner_id" value="">
		<input type="hidden" name="company_id" id="company_id" value="">
	</cfif>
</form>
<!--- basvuru listesi icin eklenen form--->
<form name="list_service" method="post" action="<cfoutput>#request.self#</cfoutput>?fuseaction=service.list_service">
  <input type="hidden" name="subscription_id" id="subscription_id" value="<cfoutput>#get_subscription.subscription_id#</cfoutput>">
  <input type="hidden" name="subscription_no" id="subscription_no" value="<cfoutput>#get_subscription.subscription_no#</cfoutput>">
  <input type="hidden" name="form_submitted" id="form_submitted" value="1">
</form>
<!--- callcenter basvuru listesi icin eklenen form--->
<form name="list_call_center" method="post" action="<cfoutput>#request.self#</cfoutput>?fuseaction=call.list_service">
  <input type="hidden" name="subscription_id" id="subscription_id" value="<cfoutput>#get_subscription.subscription_id#</cfoutput>">
  <input type="hidden" name="subscription_no" id="subscription_no" value="<cfoutput>#get_subscription.subscription_no#</cfoutput>">
  <input type="hidden" name="form_submitted" id="form_submitted" value="1">
</form>
<!--- Fatura Ekleme icin eklenen form (Sayac ve Odeme Planından)--->
<form name="add_invoice" method="post" action="<cfoutput>#request.self#</cfoutput>?fuseaction=invoice.form_add_bill">
	<cfif len(get_subscription.invoice_company_id)>
		<input type="hidden" name="company_id" id="company_id" value="<cfoutput>#get_subscription.invoice_company_id#</cfoutput>">
		<input type="hidden" name="partner_id" id="partner_id" value="<cfoutput>#get_subscription.invoice_partner_id#</cfoutput>">
		<input type="hidden" name="comp_name" id="comp_name" value="<cfoutput>#get_par_info(get_subscription.invoice_company_id,1,1,0)#</cfoutput>">
		<input type="hidden" name="consumer_id" id="consumer_id" value="">
		<input type="hidden" name="partner_name" id="partner_name" value="<cfoutput>#get_par_info(get_subscription.invoice_partner_id,0,-1,0)#</cfoutput>">
		<input type="hidden" name="member_account_code" id="member_account_code" value="<cfoutput>#get_company_period(get_subscription.invoice_company_id)#</cfoutput>">
	<cfelse>
		<input type="hidden" name="company_id" id="company_id" value="">
		<input type="hidden" name="partner_id" id="partner_id" value="">
		<input type="hidden" name="comp_name" id="comp_name" value="">
		<input type="hidden" name="consumer_id" id="consumer_id" value="<cfoutput>#get_subscription.invoice_consumer_id#</cfoutput>">
		<input type="hidden" name="partner_name" id="partner_name" value="<cfoutput>#get_cons_info(get_subscription.invoice_consumer_id,0,0)#</cfoutput>">
		<input type="hidden" name="member_account_code" id="member_account_code" value="<cfoutput>#get_consumer_period(get_subscription.invoice_consumer_id)#</cfoutput>">
	</cfif>
	<input type="hidden" name="city_id" id="city_id" value="">
	<input type="hidden" name="county_id" id="county_id" value="">
	<input type="hidden" name="adres" id="adres" value="">
	<input type="hidden" name="subscription_id" id="subscription_id" value="<cfoutput>#get_subscription.subscription_id#</cfoutput>">
	<input type="hidden" name="list_payment_row_id" id="list_payment_row_id" value="">
	<!--- Ödeme Planındaki faturalanmamis satirlarin tek tek faturalanması icin --->
</form>
<form name="add_iam_user" method="post" action="<cfoutput>#request.self#</cfoutput>?fuseaction=plevne.iam&event=add" target="_blank">
	<input type="hidden" name="subscription_id" id="subscription_id" value="<cfoutput>#get_subscription.subscription_id#</cfoutput>">
	<input type="hidden" name="subscription_no" id="subscription_no" value="<cfoutput>#get_subscription.subscription_no#</cfoutput>">
	<input type="hidden" name="company_id" id="company_id" value="<cfoutput>#get_subscription.company_id#</cfoutput>">
	<input type="hidden" name="company_fullname" id="company_fullname" value="<cfoutput>#get_subscription.FULLNAME#</cfoutput>">
	<input type="hidden" name="company_nickname" id="company_nickname" value="<cfoutput>#get_subscription.NICKNAME#</cfoutput>">
	<input type="hidden" name="domain" id="domain" value="<cfoutput>#get_subscription.PROPERTY16#</cfoutput>">
</form>
<cfif len(get_subscription.cancel_type_id)>
    <cfsavecontent variable="is_cancel"><font color="red"> - <cf_get_lang dictionary_id='35966.İptal Edildi'></font></cfsavecontent>
<cfelse>
    <cfset is_cancel = ""/>
</cfif>
<cfset pageHead = '#pageHead##is_cancel#'/>
<cf_catalystHeader>
<!--- Sayfa ana kısım  --->
<cfif isdefined('attributes.opp_id')>
	<cfset href = '#request.self#?fuseaction=sales.emptypopup_upd_subscription_contract&opp_id=#attributes.opp_id#'>
<cfelse>
	<cfset href = '#request.self#?fuseaction=sales.emptypopup_upd_subscription_contract'>
</cfif>
<cfset kontrol_form_update = 0>
<div id="basket_main_div">
    <div class="col col-9 col-xs-12 uniqueRow">
        <cfform name="form_basket" method="post" action="#href#">
            <cf_basket_form id="upd_subscription">
                <input type="hidden" name="form_action_address" id="form_action_address" value="<cfoutput>sales.emptypopup_upd_subscription_contract</cfoutput>">

                <cfsavecontent variable="text"><cf_get_lang dictionary_id='30003.Aboneler'><cf_get_lang dictionary_id='57771.Detay'></cfsavecontent>
                <cf_box title="#text#" closable="0" collapsed="0"><!--- Aboneler Detay --->
                    <cf_box_elements>
                        <div class="col col-12 col-md-12 col-sm-12 col-xs-12" type="column" index="1" sort="true">
                            <div class="form-group col col-1 col-md-1 col-sm-6 col-xs-12" id="item-form_ul_is_active">
                                <label class="col col-12 col-xs-12"><cf_get_lang dictionary_id='57493.Aktif'>
                                    <input type="checkbox" name="is_active" id="is_active" value="1" <cfif get_subscription.is_active>checked</cfif>>
                                </label>
                            </div>
                        </div>
                        <div class="col col-4 col-md-4 col-sm-6 col-xs-12" type="column" index="2" sort="true">
                            <div class="form-group" id="item-subscription_head">
                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58233.Tanım'>*</label>
                                <div class="col col-8 col-xs-12">
                                    <input type="hidden" name="subscription_id" id="subscription_id" value="<cfoutput>#get_subscription.subscription_id#</cfoutput>">
                                    <cfinput type="text" name="subscription_head" id="subscription_head" value="#get_subscription.subscription_head#" required="yes" maxlength="100" message="#getLang('','Başlık Girmelisiniz',58059)#">
                                </div>
                            </div>
                            <div class="form-group" id="item-form_ul_subscription_no">
                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='29502.Abone No'></label>
                                <div class="col col-8 col-xs-12">
                                    <input type="text" name="subscription_no" id="subscription_no" value="<cfoutput>#get_subscription.subscription_no#</cfoutput>" maxlength="50">
                                </div>
                            </div>
                            <div class="form-group" id="item-form_ul_company_name">
                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57457.Müşteri'>*</label>
                                <div class="col col-8 col-xs-12">
                                    <div class="input-group">
                                        <cfif len(get_subscription.partner_id)>
                                            <input type="hidden" name="old_company_name" id="old_company_name" value="<cfoutput>#get_par_info(get_subscription.partner_id, 0, 1, 0)#</cfoutput>">
                                            <cfinput type="text" id="company_name" name="company_name" value="#get_par_info(get_subscription.partner_id, 0, 1, 0)#" readonly="readonly" >
                                        <cfelse>
                                            <input type="hidden" name="old_company_name" id="old_company_name" value="<cfoutput>#get_cons_info(get_subscription.consumer_id, 2, 0)#</cfoutput>">
                                            <cfinput type="text" id="company_name" name="company_name" value="" readonly>
                                        </cfif>
                                        <cfset str_linke_ait = "field_partner=form_basket.partner_id&field_consumer=form_basket.consumer_id&field_comp_id=form_basket.company_id&field_comp_name=form_basket.company_name&field_name=form_basket.member_name&field_type=form_basket.member_type">
                                        <cfset str_linke_ait = "#str_linke_ait#&is_select=2&field_address=form_basket.ship_address&field_postcode=form_basket.ship_postcode&field_semt=form_basket.ship_semt&field_county=form_basket.ship_county_id&field_county_id=form_basket.ship_county_id&field_city=form_basket.ship_city_id&field_city_id=form_basket.ship_city_id&field_country=form_basket.ship_country_id&field_country_id=form_basket.ship_country_id">
                                        <cfset str_linke_ait = "#str_linke_ait#&field_address2=form_basket.invoice_address&field_postcode2=form_basket.invoice_postcode&field_semt2=form_basket.invoice_semt&field_county2=form_basket.invoice_county_id&field_county_id2=form_basket.invoice_county_id&field_city2=form_basket.invoice_city_id&field_city_id2=form_basket.invoice_city_id&field_country2=form_basket.invoice_country_id&field_country_id2=form_basket.invoice_country_id">
                                        <cfset str_linke_ait = "#str_linke_ait#&field_address3=form_basket.contact_address&field_postcode3=form_basket.contact_postcode&field_semt3=form_basket.contact_semt&field_county3=form_basket.contact_county_id&field_county_id3=form_basket.contact_county_id&field_city3=form_basket.contact_city_id&field_city_id3=form_basket.contact_city_id&field_country3=form_basket.contact_country_id&field_country_id3=form_basket.contact_country_id">
                                        <cfset str_linke_ait = "#str_linke_ait#&ship_coordinate_1=form_basket.ship_coordinate_1&ship_coordinate_2=form_basket.ship_coordinate_2&invoice_coordinate_1=form_basket.invoice_coordinate_1&invoice_coordinate_2=form_basket.invoice_coordinate_2&contact_coordinate_1=form_basket.contact_coordinate_1&contact_coordinate_2=form_basket.contact_coordinate_2">
                                        <cfset str_linke_ait = "#str_linke_ait#&ship_sales_zone_id=form_basket.ship_sales_zone_id&invoice_sales_zone_id=form_basket.invoice_sales_zone_id&contact_sales_zone_id=form_basket.contact_sales_zone_id">
                                        <span class="input-group-addon btn_Pointer icon-ellipsis" onclick="del_alias(1);"></span>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group" id="item-form_ul_member_name">
                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57578.Yetkili'></label>
                                <div class="col col-8 col-xs-12">
                                    <cfoutput>
                                        <cfif len(get_subscription.partner_id)>
                                            <input type="hidden" name="old_consumer_id" id="old_consumer_id" value="">
                                            <input type="hidden" name="old_partner_id" id="old_partner_id" value="#get_subscription.partner_id#">
                                            <input type="hidden" name="old_company_id" id="old_company_id" value="#get_subscription.company_id#">
                                            <input type="hidden" name="old_member_name" id="old_member_name" value="#get_par_info(get_subscription.partner_id, 0, - 1, 0)#">
                                            <input type="hidden" name="consumer_id" id="consumer_id" value="">
                                            <input type="hidden" name="partner_id" id="partner_id" value="#get_subscription.partner_id#">
                                            <input type="hidden" name="company_id" id="company_id" value="#get_subscription.company_id#">
                                            <input type="hidden" name="member_type" id="member_type" value="partner">
                                            <input type="text" name="member_name" id="member_name" value="#get_par_info(get_subscription.partner_id, 0, - 1, 0)#" readonly>
                                        <cfelse>
                                            <input type="hidden" name="old_consumer_id" id="old_consumer_id" value="#get_subscription.consumer_id#">
                                            <input type="hidden" name="old_partner_id" id="old_partner_id" value="">
                                            <input type="hidden" name="old_company_id" id="old_company_id" value="">
                                            <input type="hidden" name="old_member_name" id="old_member_name" value="#get_cons_info(get_subscription.consumer_id, 0, 0)#">
                                            <input type="hidden" name="consumer_id" id="consumer_id" value="#get_subscription.consumer_id#">
                                            <input type="hidden" name="partner_id" id="partner_id" value="">
                                            <input type="hidden" name="company_id" id="company_id" value="">
                                            <input type="hidden" name="member_type" id="member_type" value="consumer">
                                            <input type="text" name="member_name" id="member_name" value="#get_cons_info(get_subscription.consumer_id, 0, 0)#" readonly>
                                        </cfif>
                                    </cfoutput>
                                </div>
                            </div>
                            <div class="form-group" id="item-form_ul_invoice_member_name">
                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='41103.Fatura Şirketi'></label>
                                <div class="col col-8 col-xs-12">
                                <div class="input-group">
                                    <cfif len(get_subscription.invoice_company_id)>
                                        <input type="hidden" name="old_invoice_consumer_id" id="old_invoice_consumer_id" value="">
                                        <input type="hidden" name="old_invoice_company_id" id="old_invoice_company_id" value="<cfoutput>#get_subscription.invoice_company_id#</cfoutput>">
                                        <input type="hidden" name="old_invoice_partner_id" id="old_invoice_partner_id" value="<cfoutput>#get_subscription.invoice_partner_id#</cfoutput>">
                                        <input type="hidden" name="old_invoice_member_name" id="old_invoice_member_name" value="<cfoutput>#get_par_info(get_subscription.invoice_company_id, 1, 1, 0)#</cfoutput>">
                                        <input type="hidden" name="invoice_consumer_id" id="invoice_consumer_id" value="">
                                        <input type="hidden" name="invoice_company_id" id="invoice_company_id" value="<cfoutput>#get_subscription.invoice_company_id#</cfoutput>">
                                        <input type="hidden" name="invoice_partner_id" id="invoice_partner_id" value="<cfoutput>#get_subscription.invoice_partner_id#</cfoutput>">
                                        <input type="text" id="invoice_member_name" name="invoice_member_name" value="<cfoutput>#get_par_info(get_subscription.invoice_company_id, 1, 1, 0)#</cfoutput>" readonly>
                                    <cfelseif len(get_subscription.invoice_consumer_id)>
                                        <input type="hidden" name="old_invoice_consumer_id" id="old_invoice_consumer_id" value="<cfoutput>#get_subscription.invoice_consumer_id#</cfoutput>">
                                        <input type="hidden" name="old_invoice_company_id" id="old_invoice_company_id" value="">
                                        <input type="hidden" name="old_invoice_partner_id" id="old_invoice_partner_id" value="">
                                        <input type="hidden" name="old_invoice_member_name" id="old_invoice_member_name" value="<cfoutput>#get_cons_info(get_subscription.invoice_consumer_id, 0, 0)#</cfoutput>">
                                        <input type="hidden" name="invoice_consumer_id" id="invoice_consumer_id" value="<cfoutput>#get_subscription.invoice_consumer_id#</cfoutput>">
                                        <input type="hidden" name="invoice_company_id" id="invoice_company_id" value="">
                                        <input type="hidden" name="invoice_partner_id" id="invoice_partner_id" value="">
                                        <input type="text" id="invoice_member_name" name="invoice_member_name" value="<cfoutput>#get_cons_info(get_subscription.invoice_consumer_id, 0, 0)#</cfoutput>" readonly>
                                    </cfif>
                                        <cfset str_linke_ait2 = "field_member_name=form_basket.invoice_member_name&field_consumer=form_basket.invoice_consumer_id&field_comp_id=form_basket.invoice_company_id&field_name=form_basket.invoice_member_name&field_partner=form_basket.invoice_partner_id">
                                    <cfset str_linke_ait2 = "#str_linke_ait2#&is_select=2&field_address=form_basket.invoice_address&field_postcode=form_basket.invoice_postcode&field_semt=form_basket.invoice_semt&field_county=form_basket.invoice_county&field_county_id=form_basket.invoice_county_id&field_city=form_basket.invoice_city&field_city_id=form_basket.invoice_city_id&field_country=form_basket.invoice_country&field_country_id=form_basket.invoice_country_id">
                                    <cfif not (xml_control_payment_rows eq 1 and control_prov_rows.recordcount gt 0)>
                                        <span class="input-group-addon icon-ellipsis" name="billing_company" id="billing_company" onclick="del_alias(2);"></span>
                                    </cfif>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group" id="item-form_ul_process_stage">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id="58859.Süreç"></label>
                                <div class="col col-8 col-xs-12">
                                    <input type="hidden" name="old_invoice_process_value" id="old_invoice_process_value" value="<cfoutput>#get_subscription.subscription_stage#</cfoutput>">
                                    <cf_workcube_process is_upd='0' select_value='#get_subscription.subscription_stage#' is_detail='1'>
                                </div>
                            </div>
                            <div class="form-group" id="item-form_ul_subscription_type">
                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57486.Kategori'>*</label>
                                <div class="col col-8 col-xs-12">
                                    <input type="hidden" name="old_subscription_type" id="old_subscription_type" value="<cfoutput>#get_subscription.subscription_type_id#</cfoutput>">
                                    <select id="subscription_type" name="subscription_type">
                                        <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                        <cfoutput query="get_subscription_type">
                                            <option value="#subscription_type_id#" <cfif get_subscription.subscription_type_id eq subscription_type_id>selected</cfif>>#subscription_type#</option>
                                        </cfoutput>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group" id="item-form_ul_main_special_code">
                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57789.Ozel Kod'></label>
                                <div class="col col-8 col-xs-12">
                                    <input type="hidden" name="old_special_code" id="old_special_code" value="<cfoutput>#get_subscription.special_code#</cfoutput>">
                                    <input type="text" id="main_special_code" name="main_special_code" value="<cfoutput>#get_subscription.special_code#</cfoutput>" maxlength="50">
                                </div>
                            </div>
                            <div class="form-group" id="item-form_ul_project_head">
                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57416.Proje'></label>
                                <div class="col col-8 col-xs-12">
                                    <div class="input-group">
                                        <input type="hidden" name="project_id" id="project_id" value="<cfoutput>#get_subscription.project_id#</cfoutput>">
                                        <input type="text" name="project_head" id="project_head" value="<cfif len(get_subscription.project_id)><cfoutput>#GET_PROJECT_NAME(get_subscription.project_id)#</cfoutput></cfif>" onfocus="AutoComplete_Create('project_head','PROJECT_ID,PROJECT_HEAD','PROJECT_HEAD','get_project','','PROJECT_ID','project_id','form_basket','3','135')" autocomplete="off">
                                        <span class="input-group-addon btn_Pointer icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_list_projects&project_id=form_basket.project_id&project_head=form_basket.project_head</cfoutput>');"></span>
                                        <cfif len(get_subscription.project_id)>
                                            <span class="input-group-addon"><a href="<cfoutput>#request.self#?fuseaction=project.projects&event=det&id=#get_subscription.project_id#</cfoutput>" target="_blank"><i class="fa fa-question"></i></a></span>
                                        </cfif>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group" id="item-form_ul_asset_name">
                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58833.Fiziki Varlık'></label>
                                <div class="col col-8 col-xs-12">
                                    <cf_wrkassetp asset_id="#get_subscription.assetp_id#" fieldid='asset_id' fieldname='asset_name' form_name='form_basket' is_upd="1">
                                </div>
                            </div>
                        </div>
                        <div class="col col-4 col-md-4 col-sm-6 col-xs-12" type="column" index="3" sort="true">
                                <div class="form-group" id="item-form_ul_sales_emp">
                                    <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='41076.Satış Temsilcisi'></label>
                                    <div class="col col-8 col-xs-12">
                                        <div class="input-group">
                                            <cfif len(get_subscription.sales_emp_id)>
                                                <input type="hidden" name="old_sales_emp_id" id="old_sales_emp_id" value="<cfoutput>#get_subscription.sales_emp_id#</cfoutput>">
                                                <input type="hidden" name="old_sales_emp" id="old_sales_emp" value="<cfoutput>#get_emp_info(get_subscription.sales_emp_id, 0, 0)#</cfoutput>">
                                                <input type="hidden" name="sales_emp_id" id="sales_emp_id" value="<cfoutput>#get_subscription.sales_emp_id#</cfoutput>">
                                                <input type="text" name="sales_emp" id="sales_emp" value="<cfif len(get_subscription.sales_emp_id)><cfoutput>#get_emp_info(get_subscription.sales_emp_id, 0, 0)#</cfoutput></cfif>" onfocus="AutoComplete_Create('sales_emp','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','3','EMPLOYEE_ID','sales_emp_id','','3','200');" autocomplete="off">
                                            <cfelse>
                                                <input type="hidden" name="old_sales_emp_id" id="old_sales_emp_id" value="">
                                                <input type="hidden" name="old_sales_emp" id="old_sales_emp" value="">
                                                <input type="hidden" name="sales_emp_id" id="sales_emp_id" value="">
                                                <input type="text" name="sales_emp" id="sales_emp" value="" onfocus="AutoComplete_Create('sales_emp','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','3','EMPLOYEE_ID','sales_emp_id','','3','200');" autocomplete="off">
                                            </cfif>
                                            <span class="input-group-addon btn_Pointer icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_positions&field_emp_id=form_basket.sales_emp_id&field_name=form_basket.sales_emp&select_list=1&keyword='+encodeURIComponent(form_basket.sales_emp.value));"></span>
                                        </div>
                                    </div>
                                </div>
                                <div class="form-group" id="item-form_ul_sales_member">
                                    <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='40904.Satış Ortağı'></label>
                                    <div class="col col-8 col-xs-12">
                                        <div class="input-group">
                                            <cfif len(get_subscription.sales_partner_id)>
                                                <input type="hidden" name="sales_member_id" id="sales_member_id" value="<cfoutput>#get_subscription.sales_partner_id#</cfoutput>">
                                                <input type="hidden" name="sales_member_type" id="sales_member_type" value="partner">
                                                <input type="hidden" name="sales_company_id" id="sales_company_id" value="<cfoutput>#get_subscription.sales_company_id#</cfoutput>">
                                                <input name="sales_member" type="text" id="sales_member" onfocus="AutoComplete_Create('sales_member','MEMBER_NAME,MEMBER_PARTNER_NAME','MEMBER_PARTNER_NAME2,MEMBER_NAME2','get_member_autocomplete','\'1,2\'','PARTNER_ID2,MEMBER_TYPE,COMPANY_ID','sales_member_id,sales_member_type,sales_company_id','','3','250');" value="<cfoutput>#get_par_info(get_subscription.sales_partner_id, 0, 0, 0)#</cfoutput>" autocomplete="off">
                                            <cfelseif len(get_subscription.sales_consumer_id)>
                                                <input type="hidden" name="sales_member_id" id="sales_member_id"  value="<cfoutput>#get_subscription.sales_consumer_id#</cfoutput>">
                                                <input type="hidden" name="sales_member_type" id="sales_member_type" value="consumer">
                                                <input type="hidden" name="sales_company_id" id="sales_company_id" value="">
                                                <input name="sales_member" type="text" id="sales_member" onfocus="AutoComplete_Create('sales_member','MEMBER_NAME,MEMBER_PARTNER_NAME','MEMBER_PARTNER_NAME2,MEMBER_NAME2','get_member_autocomplete','\'1,2\'','PARTNER_ID2,MEMBER_TYPE,COMPANY_ID','sales_member_id,sales_member_type,sales_company_id','','3','250');" value="<cfoutput>#get_cons_info(get_subscription.sales_consumer_id, 1, 0)#</cfoutput>" autocomplete="off">
                                            <cfelse>
                                                <input type="hidden" name="sales_member_id" id="sales_member_id" value="">
                                                <input type="hidden" name="sales_member_type" id="sales_member_type" value="">
                                                <input type="hidden" name="sales_company_id" id="sales_company_id" value="">
                                                <input name="sales_member" type="text" id="sales_member" onfocus="AutoComplete_Create('sales_member','MEMBER_NAME,MEMBER_PARTNER_NAME','MEMBER_PARTNER_NAME2,MEMBER_NAME2','get_member_autocomplete','\'1,2\'','PARTNER_ID2,MEMBER_TYPE,COMPANY_ID','sales_member_id,sales_member_type,sales_company_id','','3','250');" value="" autocomplete="off">
                                            </cfif>
                                            <span class="input-group-addon btn_Pointer icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_pars&field_partner=form_basket.sales_member_id&field_consumer=form_basket.sales_member_id&field_comp_id=form_basket.sales_company_id&field_name=form_basket.sales_member&field_type=form_basket.sales_member_type&select_list=7,8');"></span>
                                        </div>
                                    </div>
                                </div>
                                <div class="form-group" id="item-form_ul_sales_member_comm_value">
                                    <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='41349.Satış Ortagi Komisyonu'></label>
                                    <div class="col col-5 col-xs-12">
                                        <input name="sales_member_comm_value" id="sales_member_comm_value" type="text" value="<cfoutput>#TLFormat(get_subscription.sales_member_comm_value)#</cfoutput>" class="moneybox" onkeyup="return(FormatCurrency(this,event));">
                                    </div>
                                    <div class="col col-3 col-xs-12">
                                        <select name="sales_member_comm_money" id="sales_member_comm_money">
                                            <cfoutput query="get_money_info">
                                                <option value="#MONEY#" <cfif get_subscription.sales_member_comm_money eq money>selected</cfif>>#MONEY#</option>
                                            </cfoutput>
                                        </select>
                                    </div>
                                </div>
                                <div class="form-group" id="item-form_ul_ref_company">
                                    <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58784.Referans'> <cf_get_lang dictionary_id='57457.Müşteri'></label>
                                    <div class="col col-8 col-xs-12">
                                        <div class="input-group">
                                            <cfif len(get_subscription.ref_partner_id)>
                                                <input type="hidden" name="old_ref_company_id" id="old_ref_company_id" value="<cfoutput>#get_subscription.ref_company_id#</cfoutput>">
                                                <input type="hidden" name="old_ref_company" id="old_ref_company" value="<cfoutput>#get_par_info(get_subscription.ref_partner_id, 0, 1, 0)#</cfoutput>">
                                                <input type="hidden" name="ref_company_id" id="ref_company_id" value="<cfoutput>#get_subscription.ref_company_id#</cfoutput>">
                                                <input name="ref_company" type="text" id="ref_company" onfocus="AutoComplete_Create('ref_company','MEMBER_NAME,MEMBER_PARTNER_NAME','MEMBER_NAME2,MEMBER_PARTNER_NAME2','get_member_autocomplete','\'1,2,3\'','COMPANY_ID,PARTNER_ID2,MEMBER_TYPE,MEMBER_PARTNER_NAME2','ref_company_id,ref_member_id,ref_member_type,ref_member','','3','250','return_company()');" value="<cfoutput>#get_par_info(get_subscription.ref_partner_id, 0, 1, 0)#</cfoutput>" autocomplete="off">
                                            <cfelse>
                                                <input type="hidden" name="old_ref_company_id" id="old_ref_company_id" value="">
                                                <input type="hidden" name="old_ref_company" id="old_ref_company" value="">
                                                <input type="hidden" name="ref_company_id" id="ref_company_id" value="">
                                                <input name="ref_company" type="text" id="ref_company" onfocus="AutoComplete_Create('ref_company','MEMBER_NAME,MEMBER_PARTNER_NAME','MEMBER_NAME2,MEMBER_PARTNER_NAME2','get_member_autocomplete','\'1,2,3\'','COMPANY_ID,PARTNER_ID2,MEMBER_TYPE,MEMBER_PARTNER_NAME2','ref_company_id,ref_member_id,ref_member_type,ref_member','','3','250');" value="" autocomplete="off">
                                                </cfif>
                                                <cfset str_linke_ait1 = "field_name=form_basket.ref_member&field_emp_id=form_basket.ref_member_id&field_partner=form_basket.ref_member_id&field_consumer=form_basket.ref_member_id&field_comp_id=form_basket.ref_company_id&field_comp_name=form_basket.ref_company&field_type=form_basket.ref_member_type">
                                            <span class="input-group-addon btn_Pointer icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_all_pars&<cfoutput>#str_linke_ait1#</cfoutput>&select_list=1,7,8');"></span>
                                        </div>
                                    </div>
                                </div>
                                <div class="form-group" id="item-form_ul_ref_member">
                                    <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58784.Referans'><cf_get_lang dictionary_id='57578.Yetkili'></label>
                                    <div class="col col-8 col-xs-12">
                                        <cfif len(get_subscription.ref_partner_id)>
                                            <input type="hidden" name="old_ref_member_id" id="old_ref_member_id" value="<cfoutput>#get_subscription.ref_partner_id#</cfoutput>">
                                            <input type="hidden" name="old_ref_member" id="old_ref_member" value="<cfoutput>#get_par_info(get_subscription.ref_partner_id, 0, - 1, 0)#</cfoutput>">
                                            <input type="hidden" name="ref_member_id" id="ref_member_id" value="<cfoutput>#get_subscription.ref_partner_id#</cfoutput>">
                                            <input type="hidden" name="ref_member_type" id="ref_member_type" value="partner">
                                            <input type="text" name="ref_member" id="ref_member" readonly value="<cfoutput>#get_par_info(get_subscription.ref_partner_id, 0, - 1, 0)#</cfoutput>">
                                        <cfelseif len(get_subscription.ref_consumer_id)>
                                            <input type="hidden" name="old_ref_member_id" id="old_ref_member_id"  value="<cfoutput>#get_subscription.ref_consumer_id#</cfoutput>">
                                            <input type="hidden" name="old_ref_member" id="old_ref_member" value="<cfoutput>#get_cons_info(get_subscription.ref_consumer_id, 0, 0)#</cfoutput>">
                                            <input type="hidden" name="ref_member_id" id="ref_member_id" value="<cfoutput>#get_subscription.ref_consumer_id#</cfoutput>">
                                            <input type="hidden" name="ref_member_type" id="ref_member_type" value="consumer">
                                            <input type="text" name="ref_member" id="ref_member" value="<cfoutput>#get_cons_info(get_subscription.ref_consumer_id, 0, 0)#</cfoutput>">
                                        <cfelseif len(get_subscription.ref_employee_id)>
                                            <input type="hidden" name="old_ref_member_id" id="old_ref_member_id" value="<cfoutput>#get_subscription.ref_employee_id#</cfoutput>">
                                            <input type="hidden" name="old_ref_member" id="old_ref_member" value="<cfoutput>#get_emp_info(get_subscription.ref_employee_id, 0, 0)#</cfoutput>">
                                            <input type="hidden" name="ref_member_id" id="ref_member_id" value="<cfoutput>#get_subscription.ref_employee_id#</cfoutput>">
                                            <input type="hidden" name="ref_member_type" id="ref_member_type" value="employee">
                                            <input type="text" name="ref_member" id="ref_member" value="<cfoutput>#get_emp_info(get_subscription.ref_employee_id, 0, 0)#</cfoutput>">
                                        <cfelse>
                                            <input type="hidden" name="old_ref_member_id" id="old_ref_member_id" value="">
                                            <input type="hidden" name="old_ref_member" id="old_ref_member" value="">
                                            <input type="hidden" name="ref_member_id" id="ref_member_id" value="">
                                            <input type="hidden" name="ref_member_type" id="ref_member_type" value="">
                                            <input type="text" name="ref_member" id="ref_member" value="">
                                        </cfif>
                                    </div>
                                </div>
                                <div class="form-group" id="item-form_ul_ref_state">
                                    <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id="59660.Referans Durumu"></label>
                                    <div class="col col-8 col-xs-12">
                                        <select name="ref_state">
                                            <option value=""><cf_get_lang dictionary_id="57734.Seçiniz"></option>
                                            <cfoutput query="get_ref_state">
                                                <option value="#referance_status_id#" <cfif referance_status_id eq get_subscription.referance_status_id>selected</cfif>>#referance_status#</option>
                                            </cfoutput>
                                        </select>
                                    </div>
                                </div>
                                <div class="form-group" id="item-our_company_id">
                                    <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='66381.Abone Sağlayıcısı'></label>
                                    <div class="col col-8 col-xs-12">
                                        <select name="our_company_id" id="our_company_id">
                                            <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                            <cfoutput query="get_our_companies">
                                                <option value="#COMP_ID#" <cfif get_subscription.our_company_id eq COMP_ID> selected </cfif> >#company_name#</option>
                                            </cfoutput>
                                        </select>
                                    </div>
                                </div>
                                <div class="form-group" id="item-form_ul_subscription_product_name">
                                    <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57657.Ürün'></label>
                                    <div class="col col-8 col-xs-12">
                                        <div class="input-group">
                                            <input type="hidden" name="subscription_product_id" id="subscription_product_id" value="<cfoutput>#get_subscription.product_id#</cfoutput>">
                                            <input type="hidden" name="subscription_stock_id" id="subscription_stock_id" value="<cfoutput>#get_subscription.stock_id#</cfoutput>">
                                            <cfif len(get_subscription.product_id)>
                                                <input type="text" name="subscription_product_name" id="subscription_product_name" onfocus="AutoComplete_Create('subscription_product_name','PRODUCT_NAME','PRODUCT_NAME','get_product','0','STOCK_ID,PRODUCT_ID','subscription_stock_id,subscription_product_id','','3','130');" value="<cfoutput>#get_product_name(product_id:get_subscription.PRODUCT_ID)#</cfoutput>">
                                            <cfelse>
                                                <input type="text" name="subscription_product_name" id="subscription_product_name" onfocus="AutoComplete_Create('subscription_product_name','PRODUCT_NAME','PRODUCT_NAME','get_product','0','STOCK_ID,PRODUCT_ID','subscription_stock_id,subscription_product_id','','3','130');" value="">
                                            </cfif>
                                            <span class="input-group-addon btn_Pointer icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_product_names&product_id=form_basket.subscription_product_id&field_name=form_basket.subscription_product_name&field_id=form_basket.subscription_stock_id');"></span>
                                        </div>
                                    </div>
                                </div>
                                <div class="form-group" id="item-form_ul_credit_card_id">
                                    <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58199.Kredi Kartı'></label>
                                    <div class="col col-8 col-xs-12">
                                        <input type="hidden" name="old_credit_card_id" id="old_credit_card_id" value="<cfoutput>#get_subscription.member_cc_id#</cfoutput>">
                                        <cfif len(get_subscription.partner_id)>
                                            <cfset key_type = get_subscription.company_id>
                                        <cfelse>
                                            <cfset key_type = get_subscription.consumer_id>
                                        </cfif>
                                        <select name="credit_card_id" id="credit_card_id" <cfif xml_control_payment_rows eq 1 and control_prov_rows.recordcount gt 0>disabled</cfif>>
                                            <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                            <cfoutput query="get_member_cc">
                                                <cfif getCCNOKey1.recordcount and getCCNOKey2.recordcount>
                                                    <!--- anahtarlar decode ediliyor --->
                                                    <cfset ccno_key1 = contentEncryptingandDecodingAES(isEncode:0, accountKey:getCCNOKey1.record_emp, content:getCCNOKey1.ccnokey)/>
                                                    <cfset ccno_key2 = contentEncryptingandDecodingAES(isEncode:0, accountKey:getCCNOKey2.record_emp, content:getCCNOKey2.ccnokey)/>
                                                    <!--- kart no decode ediliyor --->
                                                    <cfset content = contentEncryptingandDecodingAES(isEncode:0, content:member_cc_number, accountKey:key_type, key1:ccno_key1, key2:ccno_key2)/>
                                                    <cfset content = '#mid(content, 1, 4)#********#mid(content, Len(content) - 3, Len(content))#'>
                                                <cfelse>
                                                    <cfset content = '#mid(Decrypt(member_cc_number, key_type, "CFMX_COMPAT", "Hex"), 1, 4)#********#mid(Decrypt(member_cc_number, key_type, "CFMX_COMPAT", "Hex"), Len(Decrypt(member_cc_number, key_type, "CFMX_COMPAT", "Hex")) - 3, Len(Decrypt(member_cc_number, key_type, "CFMX_COMPAT", "Hex")))#'>
                                                </cfif>
                                                <cfif is_default eq 1 or (is_default eq 0 and get_subscription.member_cc_id eq member_cc_id)>
                                                    <option value="#member_cc_id#" <cfif get_subscription.member_cc_id eq member_cc_id>selected</cfif>>#content#/<b>#member_ex_month#-#member_ex_year#</b></option>
                                                </cfif>
                                            </cfoutput>
                                        </select>
                                    </div>
                                </div>
                                <div class="form-group" id="item-form_ul_payment_type">
                                    <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58516.Ödeme Yöntemi'></label>
                                    <div class="col col-8 col-xs-12">
                                        <cfset window = 0>
                                        <cfif not (xml_control_payment_rows eq 1 and control_prov_rows.recordcount gt 0)>
                                            <cfset window = 1>
                                        </cfif>
                                        <cfif len(get_subscription.payment_type_id)>
                                            <cf_wrk_paymethod paymethodtip="2,1" subscription_id=#attributes.subscription_id# window="1">
                                        <cfelse>
                                            <cf_wrk_paymethod paymethodtip="2,1" subscription_id=#attributes.subscription_id# window="1">
                                        </cfif>
                                    </div>
                                </div>
                                <div class="form-group" id="item-form_ul_inv_detail">
                                    <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57441.Fatura'> <cf_get_lang dictionary_id='57629.Açıklama'></label>
                                    <div class="col col-8 col-xs-12">
                                        <textarea name="inv_detail" id="inv_detail"><cfoutput>#get_subscription.subscription_invoice_detail#</cfoutput></textarea>
                                    </div>
                                </div>
                        </div>
                        <div class="col col-4 col-md-4 col-sm-6 col-xs-12" type="column" index="4" sort="true">
                            <div class="form-group" id="item-form_ul_contract_no">
                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='30044.Sözleşme No'></label>
                                <div class="col col-8 col-xs-12">
                                    <input type="text" name="contract_no" id="contract_no" value="<cfoutput>#get_subscription.contract_no#</cfoutput>" maxlength="20">
                                </div>
                            </div>
                            <div class="form-group" id="item-form_ul_start_date">
                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57747.Sözleşme Tarihi'></label>
                                <div class="col col-8 col-xs-12">
                                    <div class="input-group">
                                        <cfsavecontent variable="message1">Sözleşme Tarihini Kontrol Ediniz!</cfsavecontent>
                                        <cfinput type="text" name="start_date" id="start_date" value="#dateformat(get_subscription.start_date, dateformat_style)#" required="yes" validate="#validate_style#" message="#message1#" maxlength="10">
                                        <span class="input-group-addon btn_Pointer"><cf_wrk_date_image date_field="start_date"></span>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group" id="item-form_ul_finish_date">
                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58506.İptal'> - <cf_get_lang dictionary_id='57700.Bitiş Tarihi'></label>
                                <cfif len(get_subscription.CANCEL_TYPE_ID)><div class="col col-4 col-xs-12"><cfelse><div class="col col-8 col-xs-12"></cfif>
                                    <div class="input-group">
                                        <cfsavecontent variable="message2"><cf_get_lang dictionary_id='30123.Bitiş Tarihini Kontrol Ediniz'> !</cfsavecontent>
                                        <cfinput type="text" id="finish_date" name="finish_date" value="#dateformat(get_subscription.finish_date, dateformat_style)#" validate="#validate_style#" message="#message2#" maxlength="10" readonly="yes">
                                        <span class="input-group-addon btn_Pointer"><cf_wrk_date_image date_field="finish_date"></span>
                                    </div>
                                </div>
                                <cfif len(get_subscription.CANCEL_TYPE_ID)>
                                    <div class="col col-4 col-xs-12">
                                    <cfset GET_SUBSCRIPTION_CANCEL_TYPE = contract_cmp.GET_SUBSCRIPTION_CANCEL_TYPE(dsn3:dsn3, CANCEL_TYPE_ID:get_subscription.CANCEL_TYPE_ID)>
                                    <input type="text" readonly="yes" value="<cfoutput>#GET_SUBSCRIPTION_CANCEL_TYPE.SUBSCRIPTION_CANCEL_TYPE#</cfoutput>">
                                    </div>
                                </cfif>
                            </div>
                            <div class="form-group" id="item-form_ul_montage_date">
                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='60559.Kurulum Tarihi'></label>
                                <div class="col col-8 col-xs-12">
                                    <div class="input-group">
                                        <cfsavecontent variable="message"><cf_get_lang dictionary_id='60562.Kurulum Sevk Tarihini Kontrol Ediniz'> !</cfsavecontent>
                                        <cfinput type="text" name="montage_date" id="montage_date" value="#dateformat(get_subscription.montage_date, dateformat_style)#" validate="#validate_style#" message="#message#" maxlength="10">
                                        <span class="input-group-addon btn_Pointer"><cf_wrk_date_image date_field="montage_date"></span>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group" id="item-form_ul_montage_emp">
                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='60560.Kurulum Çalışanı'></label>
                                <div class="col col-8 col-xs-12">
                                    <div class="input-group">
                                        <input type="hidden" name="montage_emp_id" id="montage_emp_id" value="<cfoutput>#get_subscription.montage_emp_id#</cfoutput>">
                                        <cfif len(get_subscription.montage_emp_id)>
                                            <input type="text" name="montage_emp" id="montage_emp" onfocus="AutoComplete_Create('montage_emp','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','3','EMPLOYEE_ID','montage_emp_id','','3','200');" autocomplete="off" value="<cfoutput>#get_emp_info(get_subscription.montage_emp_id, 0, 0)#</cfoutput>">
                                        <cfelse>
                                            <input type="text" name="montage_emp" id="montage_emp" onfocus="AutoComplete_Create('montage_emp','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','3','EMPLOYEE_ID','montage_emp_id','','3','200');" autocomplete="off" value="">
                                        </cfif>
                                        <span class="input-group-addon btn_Pointer icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_positions&field_emp_id=form_basket.montage_emp_id&field_name=form_basket.montage_emp&select_list=1');"></span>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group" id="item-form_ul_subs_add_option">
                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='40946.Abone Özel Tanım'></label>
                                <div class="col col-8 col-xs-12">
                                    <select name="subs_add_option" id="subs_add_option">
                                        <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                        <cfoutput query="get_subs_add_option">
                                            <option value="#subscription_add_option_id#" <cfif subscription_add_option_id eq get_subscription.subscription_add_option_id>selected</cfif>>#subscription_add_option_name#</option>
                                        </cfoutput>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group" id="item-form_ul_sales_add_option">
                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='59029.Servis Özel Tanım'></label>
                                <div class="col col-8 col-xs-12">
                                    <select name="sales_add_option" id="sales_add_option">
                                        <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                        <cfoutput query="get_sale_add_option">
                                            <option value="#SERVICE_ADD_OPTION_ID#" <cfif SERVICE_ADD_OPTION_ID eq get_subscription.sales_add_option_id>selected</cfif>>#SERVICE_ADD_OPTION_NAME#</option>
                                        </cfoutput>
                                    </select>
                                </div>
                            </div>
                            <cfset GET_BRANCH_ALL = contract_cmp.GET_BRANCH_ALL()>
                            <div class="form-group" id="item-form_ul_comp_branch">
                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57895.Şube İlişkisi'></label>
                                <div class="col col-8 col-xs-12">
                                    <select name="comp_branch" id="comp_branch">
                                        <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                        <cfoutput query="get_branch_all">
                                            <option value="#branch_id#" <cfif branch_id eq get_subscription.branch_id>selected</cfif>>#branch_name#</option>
                                        </cfoutput>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group" id="item-form_ul_product_key">
                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='62733.Ürün Anahtarı'></label>
                                <div class="col col-8 col-xs-12">
                                    <div class="input-group">
                                        <input type="text" name="product_key" id="product_key" value="<cfoutput>#get_subscription.PRODUCT_KEY#</cfoutput>">
                                        <span class="input-group-addon"><i class="fa fa-key" onclick="document.getElementById('product_key').value = Math.floor(Math.random() * 999999999999) + 1;"></i></span>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group" id="item-form_ul_camp_name">
                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57446.Kampanya'></label>
                                <div class="col col-8 col-xs-12">
                                    <div class="input-group">
                                        <cfif len(get_subscription.campaign_id)>
                                            <cfset get_camp_info = contract_cmp.get_camp_info(dsn3:dsn3, campaign_id:get_subscription.campaign_id)>
                                        <cfelse>
                                            <cfset get_camp_info.camp_head = ''>
                                        </cfif>
                                        <cfoutput>
                                            <input type="hidden" name="camp_id" id="camp_id" value="#get_subscription.campaign_id#">
                                            <input type="text" name="camp_name" id="camp_name" value="#get_camp_info.camp_head#">
                                            <span class="input-group-addon btn_Pointer icon-ellipsis" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_campaigns&field_id=form_basket.camp_id&field_name=form_basket.camp_name');"></span>
                                        </cfoutput>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="seperator_right"></div>
                        <div class="col col-4 col-md-4 col-sm-6 col-xs-12" type="column" index="5" sort="true">
                            <div class="form-group" id="item-form_ul_detail">
                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57629.Açıklama'></label>
                                <div class="col col-8 col-xs-12">
                                    <textarea name="detail" id="detail"><cfoutput>#get_subscription.subscription_detail#</cfoutput></textarea>
                                </div>
                            </div>
                            <div class="form-group" id="item-form_ek_bilgi">
                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57810.Ek Bilgi'></label>
                                <div class="col col-8 col-xs-12">
                                    <cfsavecontent variable="txt"><cfoutput>#get_subscription.subscription_type_id#</cfoutput></cfsavecontent>
                                    <cf_wrk_add_info info_type_id="-11" info_id="#attributes.subscription_id#" upd_page="1" colspan="9" sub_catid=#txt#>
                                </div>
                            </div>
                            <div class="form-group" id="item-form_ul_detail2">
                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='41155.Ek Açıklama'></label>
                                <div class="col col-8 col-xs-12">
                                    <textarea name="detail_2" id="detail_2"><cfoutput>#get_subscription.subscription_detail_2#</cfoutput></textarea>
                                </div>
                            </div>
                        </div>
                    </cf_box_elements>
                    <cf_box_footer>
                        <div class="col col-6">
                            <cf_record_info query_name="get_subscription">
                        </div>
                        <div class="col col-6">
                            <cfif not control_payment_plan.recordcount and not control_service.recordcount and not control_order.recordcount and not control_counter_result.recordcount>
                                <cf_workcube_buttons is_upd='1' delete_page_url='#request.self#?fuseaction=sales.emptypopup_del_subscription_contract&subscription_id=#attributes.subscription_id#&subscription_no=#get_subscription.subscription_no#' add_function='kontrol()'>
                            <cfelse>
                                <cf_workcube_buttons is_upd='1' is_delete='0' add_function='kontrol()'>
                            </cfif>
                        </div>
                    </cf_box_footer>
                </cf_box>

                <cfsavecontent variable="text"><cf_get_lang dictionary_id='41081.Adresler'></cfsavecontent>
                <cf_box title="#text#" closable="0" collapsed="0">
                    <cf_box_elements>
                        <div class="col col-4 col-md-4 col-sm-6 col-xs-12" type="column" index="8" sort="true">
                            <div class="form-group" id="item-form_ul_ship_address">
                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='60563.Kurulum Adresi'></label>
                                <div class="col col-8 col-xs-12">
                                    <div class="input-group">
                                        <textarea name="ship_address" id="ship_address"><cfoutput>#get_subscription.ship_address#</cfoutput></textarea>
                                        <span class="input-group-addon btn_Pointer icon-ellipsis" onclick="add_adress(1);"></span>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group" id="item-form_ul_ship_postcode">
                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='33340.Kurulum'> <cf_get_lang dictionary_id='57472.Posta Kodu'></label>
                                <div class="col col-8 col-xs-12">
                                    <input type="text" id="ship_postcode" name="ship_postcode" value="<cfoutput>#get_subscription.ship_postcode#</cfoutput>" maxlength="5">
                                </div>
                            </div>
                            <div class="form-group" id="item-form_ul_ship_country_id">
                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='33340.Kurulum'> <cf_get_lang dictionary_id='58219.Ülke'></label>
                                <div class="col col-8 col-xs-12">
                                    <cf_wrk_selectlang
                                        name="ship_country_id"
                                        option_name="country_name"
                                        option_value="country_id"
                                        table_name="SETUP_COUNTRY"
                                        value="#get_subscription.ship_country_id#"
                                        sort_type="COUNTRY_NAME"
                                        width="250"
                                        selectTwoMod="true"
                                        onchange="LoadCity(this.value,'ship_city_id','ship_county_id',0);">
                                </div>
                            </div>
                            <div class="form-group" id="item-form_ul_ship_city_id">
                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='33340.Kurulum'> <cf_get_lang dictionary_id='57971.Şehir'></label>
                                <div class="col col-8 col-xs-12">
                                    <cfif len(get_subscription.ship_city_id) or len(get_subscription.ship_country_id)>
                                        <cf_wrk_selectlang
                                            name="ship_city_id"
                                            option_name="city_name"
                                            option_value="city_id"
                                            table_name="SETUP_CITY"
                                            value="#get_subscription.ship_city_id#"
                                            sort_type="city_name"
                                            width="250"
                                            selectTwoMod="true"
                                            onchange="LoadCounty(this.value,'ship_county_id')"
                                            condition="country_id=#get_subscription.ship_country_id#">
                                    <cfelse>
                                        <cf_wrk_selectlang
                                            name="ship_city_id"
                                            width="250"
                                            selectTwoMod="true"
                                            onchange="LoadCounty(this.value,'ship_county_id')">
                                    </cfif>
                                </div>
                            </div>
                            <div class="form-group" id="item-form_ul_ship_county_id">
                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='33340.Kurulum'> <cf_get_lang dictionary_id='58638.Ilçe'></label>
                                <div class="col col-8 col-xs-12">
                                    <cfif len(get_subscription.ship_county_id) or len(get_subscription.ship_city_id)>
                                        <cf_wrk_selectlang
                                            name="ship_county_id"
                                            option_name="county_name"
                                            option_value="county_id"
                                            table_name="SETUP_COUNTY"
                                            value="#get_subscription.ship_county_id#"
                                            sort_type="county_name"
                                            width="250"
                                            selectTwoMod="true"
                                            condition="city=#get_subscription.ship_city_id#"> 
                                    <cfelse>
                                        <cf_wrk_selectlang
                                            name="ship_county_id"
                                            selectTwoMod="true"
                                            width="250"> 
                                    </cfif>
                                </div>
                            </div>
                            <div class="form-group" id="item-form_ul_ship_semt">
                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='33340.Kurulum'> <cf_get_lang dictionary_id='58132.Semt'></label>
                                <div class="col col-8 col-xs-12">
                                    <input type="text" id="ship_semt" name="ship_semt" value="<cfoutput>#get_subscription.ship_semt#</cfoutput>" maxlength="30">
                                </div>
                            </div>
                            <div class="form-group" id="item-form_ul_ship_sales_zones">
                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57659.Satış Bölgesi'></label>
                                <div class="col col-8 col-xs-12">
                                    <select name="ship_sales_zone_id" id="ship_sales_zone_id">
                                        <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                        <cfoutput query="GET_SALES_ZONES">
                                            <option value="#SZ_ID#" <cfif get_subscription.ship_sz_id eq sz_id>selected</cfif>>#SZ_NAME# <cfif is_active eq 0>(<cf_get_lang dictionary_id='57494.Pasif'>)</cfif></option>
                                        </cfoutput>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group" id="item-form_ul_ship_coordinate_1">
                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='33340.Kurulum'> <cf_get_lang dictionary_id='58549.Koordinatlar'></label>
                                <div class="col col-1 col-xs-12">
                                    <cf_get_lang dictionary_id='58553.E'>
                                </div>
                                <div class="col col-3 col-xs-12">
                                    <input type="text" name="ship_coordinate_1" id="ship_coordinate_1" value="<cfoutput>#get_subscription.ship_coordinate_1#</cfoutput>" maxlength="10">
                                </div>
                                <div class="col col-1 col-xs-12">
                                    <cf_get_lang dictionary_id='58591.B'>
                                </div>
                                <div class="col col-3 col-xs-12">
                                    <div class="input-group">
                                        <input type="text" name="ship_coordinate_2" id="ship_coordinate_2" value="<cfoutput>#get_subscription.ship_coordinate_2#</cfoutput>" maxlength="10">
                                        <cfif len(get_subscription.ship_coordinate_1) and len(get_subscription.ship_coordinate_2)>
                                            <span class="input-group-addon btn_Pointer icon-ellipsis" title="Haritada Göster" onclick="windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_view_map&coordinate_1=#get_subscription.ship_coordinate_1#&coordinate_2=#get_subscription.ship_coordinate_2#&title=#get_subscription.ship_address#</cfoutput>','list','popup_view_map')"></span>
                                        </cfif>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="col col-4 col-md-4 col-sm-6 col-xs-12" type="column" index="9" sort="true">
                            <div class="form-group" id="item-form_ul_invoice_address">
                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='41085.Fatura Adresi'></label>
                                <div class="col col-8 col-xs-12">
                                    <div class="input-group">
                                        <textarea name="invoice_address" id="invoice_address"><cfoutput>#get_subscription.invoice_address#</cfoutput></textarea>
                                        <span class="input-group-addon btn_Pointer icon-ellipsis" onclick="add_adress(2);"></span>
                                        <input type="hidden" name="ship_id" id="ship_id"/>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group" id="item-form_ul_invoice_postcode">
                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57441.Fatura'> <cf_get_lang dictionary_id='57472.Posta Kodu'></label>
                                <div class="col col-8 col-xs-12">
                                    <input type="text" id="invoice_postcode" name="invoice_postcode" value="<cfoutput>#get_subscription.invoice_postcode#</cfoutput>" maxlength="5">
                                </div>
                            </div>
                            <div class="form-group" id="item-form_ul_invoice_country">
                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57441.Fatura'> <cf_get_lang dictionary_id='58219.Ülke'></label>
                                <div class="col col-8 col-xs-12">
                                    <cf_wrk_selectlang
                                        name="invoice_country_id"
                                        option_name="country_name"
                                        option_value="country_id"
                                        table_name="SETUP_COUNTRY"
                                        value="#get_subscription.invoice_country_id#"
                                        sort_type="COUNTRY_NAME"
                                        width="250"
                                        selectTwoMod="true"
                                        onchange="LoadCity(this.value,'invoice_city_id','invoice_county_id',0);">
                                </div>
                            </div>
                            <div class="form-group" id="item-form_ul_invoice_city_id">
                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57441.Fatura'> <cf_get_lang dictionary_id='57971.Şehir'></label>
                                <div class="col col-8 col-xs-12">
                                    <cfif len(get_subscription.invoice_city_id) or len(get_subscription.invoice_country_id)>
                                        <cf_wrk_selectlang
                                            name="invoice_city_id"
                                            option_name="city_name"
                                            option_value="city_id"
                                            table_name="SETUP_CITY"
                                            value="#get_subscription.invoice_city_id#"
                                            sort_type="city_name"
                                            width="250"
                                            selectTwoMod="true"
                                            onchange="LoadCounty(this.value,'invoice_county_id')"
                                            condition="country_id=#get_subscription.invoice_country_id#">
                                    <cfelse>
                                        <cf_wrk_selectlang
                                            name="invoice_city_id"
                                            width="250"
                                            selectTwoMod="true"
                                            onchange="LoadCounty(this.value,'invoice_county_id')">
                                    </cfif>
                                </div>
                            </div>
                            <div class="form-group" id="item-form_ul_invoice_county_id">
                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57441.Fatura'> <cf_get_lang dictionary_id='58638.Ilçe'></label>
                                <div class="col col-8 col-xs-12">
                                    <cfif len(get_subscription.invoice_county_id) or len(get_subscription.invoice_city_id)>
                                        <cf_wrk_selectlang
                                        name="invoice_county_id"
                                        option_name="county_name"
                                        option_value="county_id"
                                        table_name="SETUP_COUNTY"
                                        value="#get_subscription.invoice_county_id#"
                                        sort_type="county_name"
                                        width="250"
                                        selectTwoMod="true"
                                        condition="city=#get_subscription.invoice_city_id#">
                                    <cfelse>
                                        <cf_wrk_selectlang
                                        name="invoice_county_id"
                                        sort_type="county_name"
                                        selectTwoMod="true"
                                        width="250">
                                    </cfif>
                                </div>
                            </div>
                            <div class="form-group" id="item-form_ul_invoice_semt">
                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57441.Fatura'> <cf_get_lang dictionary_id='58132.Semt'></label>
                                <div class="col col-8 col-xs-12">
                                    <input type="text" id="invoice_semt" name="invoice_semt" value="<cfoutput>#get_subscription.invoice_semt#</cfoutput>" maxlength="30">
                                </div>
                            </div>
                            <div class="form-group" id="item-form_ul_invoice_sales_zones">
                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57659.Satış Bölgesi'></label>
                                <div class="col col-8 col-xs-12">
                                    <select name="invoice_sales_zone_id" id="invoice_sales_zone_id">
                                        <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                        <cfoutput query="GET_SALES_ZONES">
                                            <option value="#SZ_ID#" <cfif get_subscription.invoice_sz_id eq sz_id>selected</cfif>>#SZ_NAME# <cfif is_active eq 0>(<cf_get_lang dictionary_id='57494.Pasif'>)</cfif></option>
                                        </cfoutput>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group" id="item-form_ul_invoice_coordinate_2">
                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57441.Fatura'> <cf_get_lang dictionary_id='58549.Koordinatlar'></label>
                                <div class="col col-1 col-xs-12">
                                    <cf_get_lang dictionary_id='58553.E'>
                                </div>
                                <div class="col col-3 col-xs-12">
                                    <input type="text" name="invoice_coordinate_1" id="invoice_coordinate_1" value="<cfoutput>#get_subscription.invoice_coordinate_1#</cfoutput>" maxlength="10">
                                </div>
                                <div class="col col-1 col-xs-12">
                                    <cf_get_lang dictionary_id='58591.B'>
                                </div>
                                <div class="col col-3 col-xs-12">
                                    <div class="input-group">
                                        <input type="text" name="invoice_coordinate_2" id="invoice_coordinate_2" value="<cfoutput>#get_subscription.invoice_coordinate_2#</cfoutput>" maxlength="10">
                                        <span class="input-group-addon btn_Pointer icon-ellipsis" title="Haritada Göster" onclick="windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_view_map&coordinate_1=#get_subscription.invoice_coordinate_1#&coordinate_2=#get_subscription.invoice_coordinate_2#&title=#get_subscription.invoice_address#</cfoutput>','list','popup_view_map')"></span>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group" id="item-alias">
                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='60078.Alias'></label>
                                <div class="col col-8 col-xs-12">
                                <cfif session.ep.our_company_info.IS_EFATURA eq 1 >
                                    <input type="text" id="alias" name="alias" value="<cfoutput>#get_subscription.alias#</cfoutput>" readonly="readonly"/>
                                <cfelse>
                                    <input type="hidden" id="alias" name="alias" value="<cfoutput>#get_subscription.alias#</cfoutput>" readonly="readonly"/>
                                </cfif>
                                </div>
                            </div>
                        </div>
                        <div class="col col-4 col-md-4 col-sm-6 col-xs-12" type="column" index="10" sort="true">
                            <div class="form-group" id="item-form_ul_contact_address">
                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='41086.Irtibat Adresi'></label>
                                <div class="col col-8 col-xs-12">
                                    <div class="input-group">
                                        <textarea name="contact_address" id="contact_address"><cfoutput>#get_subscription.contact_address#</cfoutput></textarea>
                                        <span class="input-group-addon btn_Pointer icon-ellipsis" onclick="add_adress(3);"></span>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group" id="item-form_ul_contact_postcode">
                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='29756.Irtibat'> <cf_get_lang dictionary_id='57472.Posta Kodu'></label>
                                <div class="col col-8 col-xs-12">
                                    <input type="text" id="contact_postcode" name="contact_postcode" value="<cfoutput>#get_subscription.contact_postcode#</cfoutput>" maxlength="5">
                                </div>
                            </div>
                            <div class="form-group" id="item-form_ul_contact_country_id">
                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='29756.Irtibat'> <cf_get_lang dictionary_id='58219.Ülke'></label>
                                <div class="col col-8 col-xs-12">
                                    <cf_wrk_selectlang
                                        name="contact_country_id"
                                        option_name="country_name"
                                        option_value="country_id"
                                        table_name="SETUP_COUNTRY"
                                        value="#get_subscription.contact_country_id#"
                                        sort_type="COUNTRY_NAME"
                                        width="250"
                                        selectTwoMod="true"
                                        onchange="LoadCity(this.value,'contact_city_id','contact_county_id',0);">
                                </div>
                            </div>
                            <div class="form-group" id="item-form_ul_contact_city_id-">
                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='29756.Irtibat'> <cf_get_lang dictionary_id='57971.Şehir'></label>
                                <div class="col col-8 col-xs-12">
                                    <cfif len(get_subscription.contact_city_id) or len(get_subscription.contact_country_id)>
                                        <cf_wrk_selectlang
                                            name="contact_city_id"
                                            option_name="city_name"
                                            option_value="city_id"
                                            table_name="SETUP_CITY"
                                            value="#get_subscription.contact_city_id#"
                                            sort_type="city_name"
                                            width="250"
                                            selectTwoMod="true"
                                            onchange="LoadCounty(this.value,'contact_county_id')"
                                            condition="country_id=#get_subscription.contact_country_id#">
                                    <cfelse>
                                        <cf_wrk_selectlang
                                            name="contact_city_id"
                                            width="250"
                                            selectTwoMod="true"
                                            onchange="LoadCounty(this.value,'contact_county_id')">
                                    </cfif>
                                </div>
                            </div>
                            <div class="form-group" id="item-contact_county_id">
                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='29756.Irtibat'> <cf_get_lang dictionary_id='58638.Ilçe'></label>
                                <div class="col col-8 col-xs-12">
                                    <cfif len(get_subscription.contact_county_id) or len(get_subscription.contact_city_id)>
                                        <cf_wrk_selectlang
                                            name="contact_county_id"
                                            option_name="county_name"
                                            option_value="county_id"
                                            table_name="SETUP_COUNTY"
                                            value="#get_subscription.contact_county_id#"
                                            sort_type="county_name"
                                            width="250"
                                            selectTwoMod="true"
                                            condition="city=#get_subscription.contact_city_id#">
                                    <cfelse>
                                        <cf_wrk_selectlang
                                            name="contact_county_id"
                                            selectTwoMod="true"
                                            width="250">
                                    </cfif>
                                </div>
                            </div>
                            <div class="form-group" id="item-form_ul_contact_semt">
                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='29756.Irtibat'> <cf_get_lang dictionary_id='58132.Semt'></label>
                                <div class="col col-8 col-xs-12">
                                    <input type="text" name="contact_semt" id="contact_semt" value="<cfoutput>#get_subscription.contact_semt#</cfoutput>" maxlength="30">
                                </div>
                            </div>
                            <div class="form-group" id="item-form_ul_contact_sales_zones">
                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57659.Satış Bölgesi'></label>
                                <div class="col col-8 col-xs-12">
                                    <select name="contact_sales_zone_id" id="contact_sales_zone_id">
                                        <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                        <cfoutput query="GET_SALES_ZONES">
                                            <option value="#SZ_ID#" <cfif get_subscription.contact_sz_id eq sz_id>selected</cfif>>#SZ_NAME# <cfif is_active eq 0>(<cf_get_lang dictionary_id='57494.Pasif'>)</cfif></option>
                                        </cfoutput>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group" id="item-form_ul_contact_coordinate_1">
                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='29756.Irtibat'> <cf_get_lang dictionary_id='58549.Koordinatlar'></label>
                                <div class="col col-1 col-xs-12">
                                    <cf_get_lang dictionary_id='58553.E'>
                                </div>
                                <div class="col col-3 col-xs-12">
                                    <input type="text" name="contact_coordinate_1" id="contact_coordinate_1" value="<cfoutput>#get_subscription.contact_coordinate_1#</cfoutput>" maxlength="10">
                                </div>
                                <div class="col col-1 col-xs-12">
                                    <cf_get_lang dictionary_id='58591.B'>
                                </div>
                                <div class="col col-3 col-xs-12">
                                    <div class="input-group">
                                        <input type="text" name="contact_coordinate_2" id="contact_coordinate_2" value="<cfoutput>#get_subscription.contact_coordinate_2#</cfoutput>" maxlength="10">
                                        <span class="input-group-addon btn_Pointer icon-ellipsis" title="Haritada Göster" onclick="windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_view_map&coordinate_1=#get_subscription.contact_coordinate_1#&coordinate_2=#get_subscription.contact_coordinate_2#&title=#get_subscription.contact_address#</cfoutput>','list','popup_view_map')" align="absmiddle"/>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </cf_box_elements>
                </cf_box>
                <cfif xml_service_definition eq 1 and get_module_user(75)>
                    <cf_box
                        title="#getLang('','Hizmet Tanımları',58872)#"
                        closable="0"
                        collapsed="0"
                        box_page="#request.self#?fuseaction=sales.service_upd_definitions_ajax&subscription_id=#attributes.subscription_id#">
                    </cf_box>
                </cfif>
                <div class="uniqueBox">
                    <cfsavecontent variable="text"><cf_get_lang dictionary_id='40944.Abone Ürün Planı'></cfsavecontent>
                    <!---<style type="text/css">.sepetim_td div {height:400px !important;}</style>--->
                    <cfif xml_system_product_plan_closed eq 1>
                        <cf_box title="#text#" closable="0" collapsed="0" is_basket="1">
                            <cfset basket_height = 300>
                            <cfset attributes.basket_id = 46>
                            <cfinclude template="../../objects/display/basket.cfm">
                        </cf_box>
                    </cfif>
                </div>
            </cf_basket_form>
        </cfform>
        <cfif xml_show_related_info eq 1>
            <cf_box
                title="#getLang('','Ek tanımlar',40948)#"
                id="add_info"
                closable="0"
                unload_body="1"
                box_page="#request.self#?fuseaction=objects.emptypopup_ajax_subscription_add_info&subscription_id=#attributes.subscription_id#">
            </cf_box>
        </cfif>
        <!--- formun yerini değiştirmeyiniz, bu bölüm böyle kalmak zorunda!!!! formun dışında kalmalı --->
        <cfif xml_detail_subs_cmpr eq 1>
            <cfsavecontent variable="message"><cf_get_lang dictionary_id='57545.Teklif'>- <cf_get_lang dictionary_id='33340.Kurulum'> - <cf_get_lang dictionary_id='41100.Sevk Durumu'> </cfsavecontent>
            <cf_box
                id="detail_subs_cmpr"
                box_page="#request.self#?fuseaction=sales.emptypopup_ajax_detail_subscription_comparison&subscription_id=#attributes.subscription_id#"
                title="#message#"
                unload_body="1"
                closable="0">
            </cf_box>
        </cfif>
        <cfif xml_show_orders>
            <cf_box
                title="#getLang('','Siparişler',40808)#"
                id="detail_subs_ordr"
                closable="0"
                unload_body="1"
                box_page="#request.self#?fuseaction=sales.emptypopup_ajax_detail_subscription_order&subscription_id=#attributes.subscription_id#"
                default_body="1">
            </cf_box>
        </cfif>
        <cfif xml_show_delivery_note>
            <cf_box
                title="#getLang('','İrsaliyeler',40825)#"
                id="detail_subs_delivery"
                closable="0"
                unload_body="1"
                box_page="#request.self#?fuseaction=sales.emptypopup_ajax_detail_subscription_delivery&subscription_id=#attributes.subscription_id#" default_body="1">
            </cf_box>
        </cfif>
        <cfif xml_detail_stock_fis eq 1>
            <cf_box
                title="#getLang('','Stok Fişleri',43214)#"
                id="detail_stock_fis"
                closable="0"
                unload_body="1"
                box_page="#request.self#?fuseaction=sales.emptypopup_ajax_detail_subscription_stock_fis&subscription_id=#attributes.subscription_id#"
                default_body="1">
            </cf_box>
        </cfif>
        <cfif xml_show_fixed_asset>
            <cf_box
                title="#getLang('','Sabit Kıymetler',57531)#"
                id="detail_subs_assets"
                box_page="#request.self#?fuseaction=sales.emptypopup_ajax_detail_subscription_fixed_assets&subscription_id=#attributes.subscription_id#"
                closable="0"
                unload_body="1"
                default_body="1">
            </cf_box>
        </cfif>
        <cfif xml_show_system_relation>
            <cf_box
                title="#getLang('','Abone İlişkisi',40945)#"
                id="list_member_rel"
                closable="0"
                unload_body="1"
                box_page="#request.self#?fuseaction=objects.emptypopup_ajax_member_relations&relation_info_id=#attributes.subscription_id#&action_type_info=3">
            </cf_box>
        </cfif>
        <cfif xml_list_camp_rel eq 1>
            <cf_box
                title="#getLang('','Kampanya İlişkisi',41423)#"
                id="list_camp_rel"
                closable="0"
                unload_body="1"
                box_page="#request.self#?fuseaction=objects.emptypopup_ajax_camp_relations&relation_info_id=#attributes.subscription_id#&xml_camp_relation_date=#xml_camp_relation_date#">
            </cf_box>
        </cfif>
        <cfif xml_subscription eq 1>
            <cf_box
                title="#getLang('','İşler',58020)#"
                id="main_news_menu"
                closable="0"
                unload_body="1"
                box_page="#request.self#?fuseaction=objects.emptypopup_ajax_project_works&subscription_id=#attributes.subscription_id#">
            </cf_box>
        </cfif>
    </div>   
    <div class="col col-3 col-xs-12 uniqueRow" >
        <!--- Yan kısım--->
        <cfinclude template="upd_subscription_right.cfm">
    </div>
</div>
<script type="text/javascript">
	function add_adress(adress_type)
	{
		if(!(form_basket.partner_id.value=="") || !(form_basket.consumer_id.value==""))
		{
			if(form_basket.partner_id.value!="")
			{
				if(adress_type==1)
				{
					str_adrlink = '&field_adres=form_basket.ship_address&field_city=form_basket.ship_city_id&field_county=form_basket.ship_county_id&field_country=form_basket.ship_country_id&field_postcode=form_basket.ship_postcode&field_semt=form_basket.ship_semt&coordinate_1=form_basket.ship_coordinate_1&coordinate_2=form_basket.ship_coordinate_2&sales_zone=form_basket.ship_sales_zone_id';
					openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_member_address&is_comp=1&is_select=2&keyword='+encodeURIComponent(form_basket.company_name.value)+''+ str_adrlink);
					return true;
				}
				else if(adress_type==2)
				{
					str_adrlink = '&field_adres=form_basket.invoice_address&field_city=form_basket.invoice_city_id&field_county=form_basket.invoice_county_id&field_country=form_basket.invoice_country_id&field_postcode=form_basket.invoice_postcode&field_semt=form_basket.invoice_semt&coordinate_1=form_basket.invoice_coordinate_1&coordinate_2=form_basket.invoice_coordinate_2&sales_zone=form_basket.invoice_sales_zone_id&field_adress_id=form_basket.ship_id&field_long_address=form_basket.ship_address&alias=form_basket.alias';
					openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_member_address&is_comp=1&is_select=2&keyword='+encodeURIComponent(form_basket.company_name.value)+''+ str_adrlink);
					return true;
				}
				else if(adress_type==3)
				{
					str_adrlink = '&field_adres=form_basket.contact_address&field_city=form_basket.contact_city_id&field_county=form_basket.contact_county_id&field_country=form_basket.contact_country_id&field_postcode=form_basket.contact_postcode&field_semt=form_basket.contact_semt&coordinate_1=form_basket.contact_coordinate_1&coordinate_2=form_basket.contact_coordinate_2&sales_zone=form_basket.contact_sales_zone_id';
					openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_member_address&is_comp=1&is_select=2&keyword='+encodeURIComponent(form_basket.company_name.value)+''+ str_adrlink);
					return true;
				}
			}
			else
			{
				if(adress_type==1)
				{
					str_adrlink = '&field_adres=form_basket.ship_address&field_city=form_basket.ship_city_id&field_county=form_basket.ship_county_id&field_country=form_basket.ship_country_id&field_postcode=form_basket.ship_postcode&field_semt=form_basket.ship_semt&coordinate_1=form_basket.ship_coordinate_1&coordinate_2=form_basket.ship_coordinate_2&sales_zone=form_basket.ship_sales_zone_id';
					openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_member_address&is_comp=0&is_select=2&keyword='+encodeURIComponent(form_basket.member_name.value)+''+ str_adrlink );
					return true;
				}
				else if(adress_type==2)
				{
					str_adrlink = '&field_adres=form_basket.invoice_address&field_city=form_basket.invoice_city_id&field_county=form_basket.invoice_county_id&field_country=form_basket.invoice_country_id&field_postcode=form_basket.invoice_postcode&field_semt=form_basket.invoice_semt&coordinate_1=form_basket.invoice_coordinate_1&coordinate_2=form_basket.invoice_coordinate_2&sales_zone=form_basket.invoice_sales_zone_id';
					openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_member_address&is_comp=0&is_select=2&keyword='+encodeURIComponent(form_basket.member_name.value)+''+ str_adrlink);
					return true;
				}
				else if(adress_type==3)
				{
					str_adrlink = '&field_adres=form_basket.contact_address&field_city=form_basket.contact_city_id&field_county=form_basket.contact_county_id&field_country=form_basket.contact_country_id&field_postcode=form_basket.contact_postcode&field_semt=form_basket.contact_semt&coordinate_1=form_basket.contact_coordinate_1&coordinate_2=form_basket.contact_coordinate_2&sales_zone=form_basket.contact_sales_zone_id';
					openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_member_address&is_comp=0&is_select=2&keyword='+encodeURIComponent(form_basket.member_name.value)+''+ str_adrlink);
					return true;
				}
			}
		}
		else
		{
			alert("<cf_get_lang dictionary_id='41092.Sistem Seçiniz'> !");
			return false;
		}
	}
	function del_alias(alias_adres_type)
	{
		if(alias_adres_type == 1)
		{
		document.getElementById('alias').value='';
		document.getElementById('ship_id').value='';
		openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_all_pars&<cfoutput>#str_linke_ait#</cfoutput>&select_list=2,3');
		}
		if(alias_adres_type == 2)
		{
		document.getElementById('alias').value='';
		document.getElementById('ship_id').value='';
		openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_all_pars&<cfoutput>#str_linke_ait2#</cfoutput>&select_list=2,3');


		}
	}
	function unformat_fields()
	{
			<!---<cfoutput query="get_money_bskt">
				form_basket.txt_rate1_#currentrow#.value = filterNumBasket(form_basket.txt_rate1_#currentrow#.value,basket_rate_round_number);
				form_basket.txt_rate2_#currentrow#.value = filterNumBasket(form_basket.txt_rate2_#currentrow#.value,basket_rate_round_number);
			</cfoutput>--->
	}
	function kontrol()
    {
        if(document.getElementById('ship_coordinate_1') != undefined)		document.getElementById('ship_coordinate_1').disabled = false;
        if(document.getElementById('ship_coordinate_2') != undefined)		document.getElementById('ship_coordinate_2').disabled = false;
        if(document.getElementById('invoice_coordinate_1') != undefined)	document.getElementById('invoice_coordinate_1').disabled = false;
        if(document.getElementById('invoice_coordinate_2') != undefined)	document.getElementById('invoice_coordinate_2').disabled = false;
        if(document.getElementById('contact_coordinate_1') != undefined)	document.getElementById('contact_coordinate_1').disabled = false;
        if(document.getElementById('contact_coordinate_2') != undefined)	document.getElementById('contact_coordinate_2').disabled = false;

    if((document.form_basket.partner_id.value=="") && (document.form_basket.consumer_id.value==""))
    {
        alert("<cf_get_lang dictionary_id='41092.Sistem Seçiniz'> !");
        return false;
    }

    if(document.getElementById('subscription_type') != undefined)
    {
        if ($("#subscription_type").val()=='')
        {
            alert("<cf_get_lang dictionary_id='41094.Sistem Kategorisi Seçiniz'> ! ");
            return false;
        }
    }
    if(document.getElementById('ship_address') != undefined)
    {
        x = (300 - document.form_basket.ship_address.value.length);
    if ( x < 0)
    {
    alert ("<cf_get_lang dictionary_id='40804.Sevk Adresi'><cf_get_lang dictionary_id ='41312.Alanina 300 Karakterden Fazla Girmeyiniz Fazla Karakter Sayısı'>"+ ((-1) * x));
        return false;
    }
    }
    if(document.getElementById('invoice_address') != undefined)
    {
        y = (300 - document.form_basket.invoice_address.value.length);
    if ( y < 0)
    {
    alert ("<cf_get_lang dictionary_id='41085.Fatura Adresi'><cf_get_lang dictionary_id ='41312.Alanina 300 Karakterden Fazla Girmeyiniz Fazla Karakter Sayısı'>"+ ((-1) * x));
        return false;
    }
    }
    if(document.getElementById('contact_address') != undefined)
    {
        z = (300 - document.form_basket.contact_address.value.length);
    if ( z < 0)
    {
    alert ("<cf_get_lang dictionary_id='41086.Irtibat Adresi'><cf_get_lang dictionary_id ='41312.Alanina 300 Karakterden Fazla Girmeyiniz Fazla Karakter Sayısı'>"+ ((-1) * x));
        return false;
    }
    }
    if(document.getElementById('detail') != undefined)
    {
        t = (500 - document.form_basket.detail.value.length);
    if ( t < 0 )
    {
    alert ("<cf_get_lang dictionary_id='57629.Aciklama'><cf_get_lang dictionary_id ='41315.Alanina 500 Karakterden Fazla Girmeyiniz Fazla Karakter Sayısı'>"+ ((-1) * x));
        return false;
    }
    }

    if(!(document.form_basket.start_date.value == "") && !(document.form_basket.finish_date.value == ""))
    {
    if(!date_check(document.form_basket.start_date,document.form_basket.finish_date,"<cf_get_lang dictionary_id ='41316.Başlangıç - Bitiş Tarihlerini Kontrol Ediniz'>!"))
    {
        return false;
    }
    }

    <cfif xml_service_definition eq 1>
    if((document.form_basket.valid_days.value == 1) && (document.form_basket.start_clock_1.value == 0) && (document.form_basket.finish_clock_1.value == 0) && (document.form_basket.start_minute_1.value == 0) && (document.form_basket.finish_minute_1.value == 0) )
    {
            alert("<cf_get_lang dictionary_id='40861.Hafta İçi Destek Saatlerini Seçiniz'> !");
            return false;
        }

        if((document.form_basket.valid_days.value == 2) && (document.form_basket.start_clock_1.value == 0) && (document.form_basket.finish_clock_1.value == 0) && (document.form_basket.start_minute_1.value == 0) && (document.form_basket.finish_minute_1.value == 0) )
        {
        alert("<cf_get_lang dictionary_id='40863.Hafta İçi Ve Cumartesi Destek Saatlerini Seçiniz'> !");
            return false;
        }

        if((document.form_basket.valid_days.value == 2) && (document.form_basket.start_clock_2.value == 0) && (document.form_basket.finish_clock_2.value == 0) && (document.form_basket.start_minute_2.value == 0) && (document.form_basket.finish_minute_2.value == 0))
        {
        alert("<cf_get_lang dictionary_id='40868.Cumartesi Destek Saatlerini Seçiniz'> !");
            return false;
        }

        if((document.form_basket.valid_days.value == 3) && (document.form_basket.start_clock_1.value == 0) && (document.form_basket.finish_clock_1.value == 0) && (document.form_basket.start_minute_1.value == 0) && (document.form_basket.finish_minute_1.value == 0) )
        {
        alert("<cf_get_lang dictionary_id='40869.Hafta İçi, Cumartesi Ve Pazar Destek Saatlerini Seçiniz'> !");
            return false;
        }

        if((document.form_basket.valid_days.value == 3) && (document.form_basket.start_clock_2.value == 0) && (document.form_basket.finish_clock_2.value == 0) && (document.form_basket.start_minute_2.value == 0) && (document.form_basket.finish_minute_2.value == 0))
        {
        alert("<cf_get_lang dictionary_id='40870.Cumartesi ve Pazar Destek Saatlerini Seçiniz'> !");
            return false;
        }

        if((document.form_basket.valid_days.value == 3) && (document.form_basket.start_clock_3.value == 0) && (document.form_basket.finish_clock_3.value == 0) && (document.form_basket.start_minute_3.value == 0) && (document.form_basket.finish_minute_3.value == 0))
        {
        alert("<cf_get_lang dictionary_id='40871.Pazar Destek Saatlerini Seçiniz'> !");
            return false;
        }

            start_1 = parseInt(document.form_basket.start_clock_1.value) * 60 ;
            sonuc_1 = start_1 +  parseInt(document.form_basket.start_minute_1.value);
            finish_1 = parseInt(document.form_basket.finish_clock_1.value) * 60 ;
            sonuc_2 = finish_1 +  parseInt(document.form_basket.finish_minute_1.value);
        if( sonuc_1 > sonuc_2)
        {
        alert("<cf_get_lang dictionary_id='40872.Hafta İçi İçin Uygun Saat Değeri Giriniz'> !");
            return false;
        }

            start_2 = parseInt(document.form_basket.start_clock_2.value) * 60 ;
            sonuc_3 = start_2 +  parseInt(document.form_basket.start_minute_2.value);
            finish_2 = parseInt(document.form_basket.finish_clock_2.value) * 60 ;
            sonuc_4 = finish_2 +  parseInt(document.form_basket.finish_minute_2.value);
        if( sonuc_3 > sonuc_4)
        {
        alert("<cf_get_lang dictionary_id='40873.Cumartesi Günü İçin Uygun Saat Değeri Giriniz'> !");
            return false;
        }

            start_3 = parseInt(document.form_basket.start_clock_3.value) * 60 ;
            sonuc_5 = start_3 +  parseInt(document.form_basket.start_minute_3.value);
            finish_3 = parseInt(document.form_basket.finish_clock_3.value) * 60 ;
            sonuc_6 = finish_3 +  parseInt(document.form_basket.finish_minute_3.value);
        if( sonuc_5 > sonuc_6)
        {
        alert("<cf_get_lang dictionary_id='40874.Pazar Günü İçin Uygun Saat Değeri Giriniz'> !");
            return false;
        }
    </cfif>
        document.form_basket.credit_card_id.disabled = false;
        //return true;
        <cfif  isdefined("xml_system_product_plan_closed") and xml_system_product_plan_closed eq 1>
             return (process_cat_control() && saveForm());
        <cfelse>
            return process_cat_control();
        </cfif>
        return false;
    }
	function del_alias(alias_adres_type)
	{
		if(alias_adres_type == 1)
		{
		document.getElementById('alias').value='';
		document.getElementById('ship_id').value='';
		openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_all_pars&<cfoutput>#str_linke_ait#</cfoutput>&select_list=2,3');
		}
		if(alias_adres_type == 2)
		{
			document.getElementById('alias').value='';
		document.getElementById('ship_id').value='';
		openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_all_pars&<cfoutput>#str_linke_ait2#</cfoutput>&select_list=2,3');
		}
	}
	function return_company()
	{
		if(document.getElementById('ref_member_type').value=='employee')
		{
			var emp_id=document.getElementById('ref_member_id').value;
			var GET_COMPANY=wrk_safe_query('sls_get_cmpny_2','dsn',0,emp_id);
			document.getElementById('ref_company_id').value=GET_COMPANY.COMP_ID;
		}
		else
			return false;
	}
	<cfif isDefined("attributes.subscription_id") AND isdefined("xml_system_product_plan_closed") and xml_system_product_plan_closed eq 1>
	$(function(){
        if( typeof window.basket != 'undefined' ){
            for( var satir_index = 0 ; satir_index < window.basket.items.length ; satir_index++){
                if(satir_index < window.basket.items.length)
                    hesapla('price_other',satir_index,0);
                if(satir_index == window.basket.items.length-1)
                    hesapla('price_other',satir_index,1);
            }
            toplam_hesapla(0);
        }
    });
	</cfif>
    function addiam()
	{
		document.add_iam_user.submit();
        return true;	
	}
</script>
