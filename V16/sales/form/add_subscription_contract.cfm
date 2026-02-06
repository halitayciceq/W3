<cfset contract_cmp = createObject("component","V16.sales.cfc.subscription_contract")>
<cfset GET_SALE_ADD_OPTION = contract_cmp.GET_SALE_ADD_OPTION_F(DSN3:DSN3)>
<cfset GET_SALES_ZONES = contract_cmp.GET_SALES_ZONES()>
<cfset GET_SUBS_ADD_OPTION = contract_cmp.GET_SUBS_ADD_OPTION(DSN3:DSN3)>
<cfinclude template="../query/get_subscription_type.cfm">
<cfif isdefined('attributes.company_id') or isdefined('attributes.partner_id') or isdefined('attributes.consumer_id')>
	<cfinclude template="../query/get_address.cfm">
</cfif>
<cfset get_ref_state = contract_cmp.get_ref_state(dsn3:dsn3)>
<cf_xml_page_edit fuseact="sales.add_subscription_contract">
<cfset GET_MONEY_INFO = contract_cmp.GET_MONEY_INFO(dsn2:dsn2)>
<cfset GET_BRANCH_ALL = contract_cmp.GET_BRANCH_ALL()>
<cfset GET_OUR_COMPANIES = contract_cmp.GET_OUR_COMPANIES()>
<cfif isDefined("attributes.subscription_id")><!--- sistem kopyalama için --->
	<cfinclude template="../query/get_subsciption_contract.cfm">
	<cfset attributes.company_id = get_subscription.company_id>
	<cfset attributes.consumer_id = get_subscription.consumer_id>
	<cfset attributes.partner_id = get_subscription.partner_id>
	<cfset attributes.invoice_consumer_id = get_subscription.invoice_consumer_id>
	<cfset attributes.invoice_company_id = get_subscription.invoice_company_id>
	<cfset attributes.invoice_partner_id = get_subscription.invoice_partner_id>
	<cfif len(get_subscription.company_id)>
		<cfset attributes.member_type = 'partner'>
		<cfset attributes.member_name = get_par_info(get_subscription.company_id,1,1,0)>
	<cfelse>
		<cfset attributes.member_type = 'consumer'>
		<cfset attributes.member_name = get_cons_info(get_subscription.consumer_id,2,0)>
	</cfif>
	<cfif len(get_subscription.invoice_company_id)>
		<cfset attributes.invoice_member_name = get_par_info(get_subscription.invoice_company_id,1,1,0)>
	<cfelseif len(get_subscription.invoice_consumer_id)>
		<cfset attributes.invoice_member_name = get_cons_info(get_subscription.invoice_consumer_id,1,0)>
	</cfif>
	<cfset attributes.subs_type = get_subscription.subscription_type_id>
	<cfset attributes.special_code = get_subscription.special_code>
	<cfset attributes.sales_emp_id = get_subscription.sales_emp_id>
	<cfset attributes.sales_emp = get_emp_info(get_subscription.sales_emp_id,0,0)>
	<cfif len(get_subscription.sales_partner_id)>
		<cfset attributes.sales_member_id = get_subscription.sales_partner_id>
		<cfset attributes.sales_member_type = "partner">
		<cfset attributes.sales_company_id = get_subscription.sales_company_id>
		<cfset attributes.sales_member = get_par_info(get_subscription.sales_partner_id,0,0,0)>
	<cfelseif len(get_subscription.sales_consumer_id)>
		<cfset attributes.sales_member_id = get_subscription.sales_consumer_id>
		<cfset attributes.sales_member_type = "consumer">
		<cfset attributes.sales_company_id = "">
		<cfset attributes.sales_member = get_cons_info(get_subscription.sales_consumer_id,1,0)>
	</cfif>
	<cfif len(get_subscription.ref_partner_id)>
		<cfset attributes.ref_company_id = get_subscription.ref_company_id>
		<cfset attributes.ref_company = get_par_info(get_subscription.ref_partner_id,0,1,0)>
		<cfset attributes.ref_member_id = get_subscription.ref_partner_id>
		<cfset attributes.ref_member_type = "partner">
		<cfset attributes.ref_member = get_par_info(get_subscription.ref_partner_id,0,-1,0)>
	<cfelseif len(get_subscription.ref_consumer_id)>
		<cfset attributes.ref_member_id = get_subscription.ref_consumer_id>
		<cfset attributes.ref_member_type = "consumer">
		<cfset attributes.ref_member = get_cons_info(get_subscription.ref_consumer_id,0,0)>
	<cfelseif len(get_subscription.ref_employee_id)>
		<cfset attributes.ref_member_id = get_subscription.ref_employee_id>
		<cfset attributes.ref_member_type = "employee">
		<cfset attributes.ref_member = get_emp_info(get_subscription.ref_employee_id,0,0)>
	</cfif>
	<cfset attributes.subscription_product_id = get_subscription.product_id>
	<cfset attributes.subscription_stock_id = get_subscription.stock_id>
	<cfif len(get_subscription.product_id)>
		<cfset attributes.subscription_product_name = get_product_name(product_id:get_subscription.PRODUCT_ID)>
	</cfif>
	<cfset attributes.subs_add_opt = get_subscription.subscription_add_option_id>
	<cfset attributes.sales_add_opt = get_subscription.sales_add_option_id>
	<cfset attributes.detail = get_subscription.subscription_detail>
	<cfset attributes.project_id = get_subscription.project_id>
	<cfset attributes.montage_emp_id = get_subscription.montage_emp_id>
	<cfset attributes.montage_emp = get_emp_info(get_subscription.montage_emp_id,0,0)>
    <cfset attributes.ship_sales_zone_id = get_subscription.ship_sz_id>
    <cfset attributes.invoice_sales_zone_id = get_subscription.invoice_sz_id>
    <cfset attributes.contact_sales_zone_id = get_subscription.contact_sz_id>
    <cfset attributes.ship_address = get_subscription.ship_address>
    <cfset attributes.ship_postcode = get_subscription.ship_postcode>
    <cfset attributes.ship_semt = get_subscription.ship_semt>
    <cfset attributes.ship_id = get_subscription.INVOICE_ADDRESS_ID>
    <cfset attributes.alias = get_subscription.ALIAS>
    <cfset attributes.ship_coordinate_1 = get_subscription.ship_coordinate_1>
    <cfset attributes.ship_coordinate_2 = get_subscription.ship_coordinate_2>
    <cfset attributes.invoice_coordinate_1 = get_subscription.invoice_coordinate_1>
    <cfset attributes.invoice_coordinate_2 = get_subscription.invoice_coordinate_2>
    <cfset attributes.contact_coordinate_1 = get_subscription.contact_coordinate_1>
    <cfset attributes.contact_coordinate_2 = get_subscription.contact_coordinate_2>
    <cfset attributes.invoice_address = get_subscription.invoice_address>
    <cfset attributes.contact_address = get_subscription.contact_address>
    <cfset attributes.invoice_postcode = get_subscription.invoice_postcode>
    <cfset attributes.contact_postcode = get_subscription.contact_postcode>
    <cfset attributes.invoice_semt = get_subscription.invoice_semt>
    <cfset attributes.contact_semt = get_subscription.contact_semt>
    <cfset attributes.ship_county_id = get_subscription.ship_county_id>
    <cfset attributes.ship_city_id = get_subscription.ship_city_id>
    <cfset attributes.ship_country_id = get_subscription.ship_country_id>
    <cfset attributes.invoice_county_id = get_subscription.invoice_county_id>
    <cfset attributes.invoice_city_id = get_subscription.invoice_city_id>
	<cfset attributes.invoice_country_id = get_subscription.invoice_country_id>
    <cfset attributes.contact_county_id = get_subscription.contact_county_id>
    <cfset attributes.contact_city_id = get_subscription.contact_city_id>
    <cfset attributes.contact_country_id = get_subscription.contact_country_id>
    <cfset attributes.our_company_id = get_subscription.our_company_id>
<cfelse>
    <cfset attributes.ship_county_id = "">
    <cfset attributes.ship_city_id = "">
    <cfset attributes.ship_country_id = "">
    <cfset attributes.invoice_county_id = "">
    <cfset attributes.invoice_city_id = "">
	<cfset attributes.invoice_country_id = "">
    <cfset attributes.contact_county_id = "">
    <cfset attributes.contact_city_id = "">
    <cfset attributes.contact_country_id = "">
    <cfset attributes.our_company_id = "">
</cfif>

<cfscript>session_basket_kur_ekle(process_type:0);</cfscript>
<cf_catalystHeader>
<div id="basket_main_div" class="col col-12 col-md-12 col-sm-12 col-xs-12" style="padding:0;background:none;">
    
    <cfform name="form_basket" id="form_basket" method="post" action="#request.self#?fuseaction=sales.emptypopup_add_subscription_contract">
        <div basket_header>
            <cf_box>
                <input type="hidden" name="form_action_address" id="form_action_address" value="<cfoutput>sales.emptypopup_add_subscription_contract</cfoutput>">
                <cfif isdefined('attributes.opp_id')>
                    <input type="hidden" name="opp_id" id="opp_id" value="<cfoutput>#attributes.opp_id#</cfoutput>" />
                </cfif>
                <cf_box_elements>
                    <div class="col col-12 col-md-12 col-sm-12 col-xs-12" type="column" index="1" sort="true">
                        <div class="form-group col col-1 col-md-1 col-sm-6 col-xs-12" id="item-form_ul_is_active">
                            <label class="col col-12 col-xs-12"><cf_get_lang dictionary_id='57493.Aktif'>
                                <input type="checkbox" name="is_active" id="is_active" value="1" checked>
                            </label>
                        </div>
                    </div>
                    <div class="col col-4 col-md-4 col-sm-6 col-xs-12" type="column" index="2" sort="true">
                        <div class="form-group" id="item-subscription_head">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58233.Tanım'>*</label>
                            <div class="col col-8 col-xs-12">
                                <cfsavecontent variable="member"><cf_get_lang dictionary_id='112.Üyemiz'></cfsavecontent>
                                <cfsavecontent variable="message"><cf_get_lang dictionary_id='58059.Başlık Girmelisiniz'> !</cfsavecontent>
                                <cfinput type="text" name="subscription_head" id="subscription_head" value="#member#" required="yes" message="#message#" maxlength="100">
                            </div>
                        </div>
                        <div class="form-group" id="item-form_ul_company_name">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57457.Müşteri'>*</label>
                            <div class="col col-8 col-xs-12">
                                <div class="input-group">
                                    <input type="text" name="company_name" id="company_name" value="<cfif isdefined("attributes.company_id")><cfoutput>#get_par_info(attributes.company_id,1,1,0)#</cfoutput></cfif>" readonly>
                                    <cfset str_linke_ait="field_partner=form_basket.partner_id&field_consumer=form_basket.consumer_id&field_comp_id=form_basket.company_id&field_comp_name=form_basket.company_name&field_name=form_basket.member_name&field_type=form_basket.member_type&call_function=kontrol_prerecord()">
                                    <cfset str_linke_ait="#str_linke_ait#&is_select=2&field_address=form_basket.ship_address&field_postcode=form_basket.ship_postcode&field_semt=form_basket.ship_semt&field_county=form_basket.ship_county_id&field_county_id=form_basket.ship_county_id&field_city=form_basket.ship_city_id&field_city_id=form_basket.ship_city_id&field_country=form_basket.ship_country_id&field_country_id=form_basket.ship_country_id">
                                    <cfset str_linke_ait="#str_linke_ait#&field_address2=form_basket.invoice_address&field_postcode2=form_basket.invoice_postcode&field_semt2=form_basket.invoice_semt&field_county2=form_basket.invoice_county_id&field_county_id2=form_basket.invoice_county_id&field_city2=form_basket.invoice_city_id&field_city_id2=form_basket.invoice_city_id&field_country2=form_basket.invoice_country_id&field_country_id2=form_basket.invoice_country_id">
                                    <cfset str_linke_ait="#str_linke_ait#&field_address3=form_basket.contact_address&field_postcode3=form_basket.contact_postcode&field_semt3=form_basket.contact_semt&field_county3=form_basket.contact_county_id&field_county_id3=form_basket.contact_county_id&field_city3=form_basket.contact_city_id&field_city_id3=form_basket.contact_city_id&field_country3=form_basket.contact_country_id&field_country_id3=form_basket.contact_country_id">
                                    <cfset str_linke_ait="#str_linke_ait#&ship_coordinate_1=form_basket.ship_coordinate_1&ship_coordinate_2=form_basket.ship_coordinate_2&invoice_coordinate_1=form_basket.invoice_coordinate_1&invoice_coordinate_2=form_basket.invoice_coordinate_2&contact_coordinate_1=form_basket.contact_coordinate_1&contact_coordinate_2=form_basket.contact_coordinate_2">
                                    <cfset str_linke_ait="#str_linke_ait#&ship_sales_zone_id=form_basket.ship_sales_zone_id&invoice_sales_zone_id=form_basket.invoice_sales_zone_id&contact_sales_zone_id=form_basket.contact_sales_zone_id">
                                    <span class="input-group-addon btn_Pointer icon-ellipsis" onclick="del_alias(1);"></span>
                                </div>
                            </div>
                        </div>
                        <div class="form-group" id="item-form_ul_member_name">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57578.Yetkili'></label>
                            <div class="col col-8 col-xs-12">
                                <input type="hidden" name="consumer_id" id="consumer_id" value="<cfif isdefined("attributes.consumer_id")><cfoutput>#attributes.consumer_id#</cfoutput></cfif>">
                                <input type="hidden" name="partner_id" id="partner_id" value="<cfif isdefined("attributes.partner_id")><cfoutput>#attributes.partner_id#</cfoutput></cfif>">
                                <input type="hidden" name="company_id" id="company_id" value="<cfif isdefined("attributes.company_id")><cfoutput>#attributes.company_id#</cfoutput></cfif>">
                                <input type="hidden" name="member_type" id="member_type" value="<cfif isdefined("attributes.member_type")><cfoutput>#attributes.member_type#</cfoutput></cfif>">
                                <input type="text" name="member_name" id="member_name" value="<cfif isdefined("attributes.member_type") and (attributes.member_type is 'partner')><cfoutput>#get_par_info(attributes.partner_id,0,-1,0)#</cfoutput><cfelseif isdefined("attributes.member_type") and (attributes.member_type is 'consumer')><cfoutput>#get_cons_info(attributes.consumer_id,0,0)#</cfoutput></cfif>"  readonly>
                            </div>
                        </div>
                        <div class="form-group" id="item-form_ul_invoice_member_name">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='41103.Fatura Şirketi'></label>
                            <div class="col col-8 col-xs-12">
                                <div class="input-group">
                                    <input type="hidden" name="invoice_consumer_id" id="invoice_consumer_id" value="<cfif isDefined("attributes.invoice_consumer_id")><cfoutput>#attributes.invoice_consumer_id#</cfoutput><cfelseif isdefined("attributes.consumer_id")><cfoutput>#attributes.consumer_id#</cfoutput></cfif>">
                                    <input type="hidden" name="invoice_company_id" id="invoice_company_id" value="<cfif isDefined("attributes.invoice_company_id")><cfoutput>#attributes.invoice_company_id#</cfoutput><cfelseif isdefined("attributes.company_id")><cfoutput>#attributes.company_id#</cfoutput></cfif>">
                                    <input type="hidden" name="invoice_partner_id" id="invoice_partner_id" value="<cfif isDefined("attributes.invoice_partner_id")><cfoutput>#attributes.invoice_partner_id#</cfoutput><cfelseif isdefined("attributes.partner_id")><cfoutput>#attributes.partner_id#</cfoutput></cfif>">
                                    <input type="text" name="invoice_member_name" id="invoice_member_name" value="<cfif isDefined("attributes.invoice_member_name")><cfoutput>#attributes.invoice_member_name#</cfoutput><cfelseif isdefined("attributes.member_name") and isdefined("attributes.company_id")><cfoutput>#get_par_info(attributes.company_id,1,1,0)#</cfoutput></cfif>" readonly>
                                    <cfset str_linke_ait2="field_member_name=form_basket.invoice_member_name&field_consumer=form_basket.invoice_consumer_id&field_comp_id=form_basket.invoice_company_id&field_name=form_basket.invoice_member_name&field_partner=form_basket.invoice_partner_id">
                                    <cfset str_linke_ait2="#str_linke_ait2#&is_select=2&field_address=form_basket.invoice_address&field_postcode=form_basket.invoice_postcode&field_semt=form_basket.invoice_semt&field_county=form_basket.invoice_county&field_county_id=form_basket.invoice_county_id&field_city=form_basket.invoice_city&field_city_id=form_basket.invoice_city_id&field_country=form_basket.invoice_country&field_country_id=form_basket.invoice_country_id">
                                    <span class="input-group-addon btn_Pointer icon-ellipsis" onclick="del_alias(2);"></span>
                                </div>
                            </div>
                        </div>
                        <div class="form-group" id="item-form_ul_process_stage">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id="58859.Süreç"></label>
                            <div class="col col-8 col-xs-12">
                                <cf_workcube_process is_upd='0' process_cat_width='120' is_detail='0'>
                            </div>
                        </div>
                        <div class="form-group" id="item-form_ul_subscription_type">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57486.Kategori'>*</label>
                            <div class="col col-8 col-xs-12">
                                <select id="subscription_type" name="subscription_type">
                                    <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                    <cfoutput query="get_subscription_type">
                                        <option value="#subscription_type_id#" <cfif isdefined("attributes.subs_type") and len(attributes.subs_type)>selected="selected"</cfif>>#subscription_type#</option>
                                    </cfoutput>
                                </select>
                            </div>
                        </div>
                        <div class="form-group" id="item-main_special_code">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57789.Ozel Kod'></label>
                            <div class="col col-8 col-xs-12">
                                <input type="text" name="main_special_code" id="main_special_code" value="<cfif isDefined("attributes.special_code")><cfoutput>#attributes.special_code#</cfoutput></cfif>" maxlength="50">
                            </div>
                        </div>
                        <div class="form-group" id="item-form_ul_project_head">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57416.Proje'></label>
                            <div class="col col-8 col-xs-12">
                                <div class="input-group">
                                    <cfoutput>
                                        <input type="hidden" name="project_id" id="project_id" value="<cfif isdefined('attributes.project_id')>#attributes.project_id#</cfif>">
                                        <input type="text" name="project_head" id="project_head" value="<cfif isdefined('attributes.project_id') and len(attributes.project_id)>#GET_PROJECT_NAME(attributes.project_id)#</cfif>" onfocus="AutoComplete_Create('project_head','PROJECT_ID,PROJECT_HEAD','PROJECT_HEAD','get_project','','PROJECT_ID','project_id','form_basket','3','135')" autocomplete="off">
                                        <span class="input-group-addon btn_Pointer icon-ellipsis" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_projects&project_id=form_basket.project_id&project_head=form_basket.project_head');"></span>
                                    </cfoutput>
                                </div>
                            </div>
                        </div>
                        <div class="form-group" id="item-form_ul_asset_name">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id ='58833.Fiziki Varlık'></label>
                            <div class="col col-8 col-xs-12">
                                <cf_wrkassetp fieldid='asset_id' fieldname='asset_name' form_name='form_basket' width='120' button_type='plus_thin'>
                            </div>
                        </div>
                        <div class="form-group" id="item-form_ul_payment_type">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58516.Ödeme Yöntemi'></label>
                            <div class="col col-8 col-xs-12">
                                <div class="input-group">
                                    <input type="hidden" name="payment_type_id" id="payment_type_id" value="">
                                    <input type="hidden" name="payment_type_creditcard_id" id="payment_type_creditcard_id" value="">
                                    <input type="text" name="payment_type" id="payment_type" value="" readonly>
                                    <span class="input-group-addon btn_Pointer icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_paymethods&field_id=form_basket.payment_type_id&field_name=form_basket.payment_type&field_card_payment_id=form_basket.payment_type_creditcard_id&field_card_payment_name=form_basket.payment_type');"></span>
                                </div>
                            </div>
                        </div>
                        <div class="form-group" id="item-form_ul_camp_name">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57446.Kampanya'></label>
                            <div class="col col-8 col-xs-12">
                                <div class="input-group">
                                    <cfoutput>
                                            <input type="hidden" name="camp_id" id="camp_id" value="">
                                            <input type="text" id="camp_name" name="camp_name" value="">
                                            <span class="input-group-addon btn_Pointer icon-ellipsis" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_campaigns&field_id=form_basket.camp_id&field_name=form_basket.camp_name');"></span>
                                    </cfoutput>
                                </div>
                            </div>
                        </div>
                        <div class="form-group" id="item-subscription_product_name">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57657.Ürün'></label>
                            <div class="col col-8  col-xs-12">
                                <div class="input-group">
                                    <cfoutput>
                                        <input type="hidden" name="subscription_product_id" id="subscription_product_id" value="<cfif isDefined("attributes.subscription_product_id")>#attributes.subscription_product_id#</cfif>">
                                        <input type="hidden" name="subscription_stock_id" id="subscription_stock_id" value="<cfif isDefined("attributes.subscription_stock_id")>#attributes.subscription_stock_id#</cfif>">
                                        <input name="subscription_product_name" type="text" id="subscription_product_name" onfocus="AutoComplete_Create('subscription_product_name','PRODUCT_NAME','PRODUCT_NAME','get_product','0','PRODUCT_ID,STOCK_ID','subscription_product_id,subscription_stock_id','','2','200');" value="<cfif isDefined("attributes.subscription_product_name")>#attributes.subscription_product_name#</cfif>" autocomplete="off">
                                        <span class="input-group-addon btn_Pointer icon-ellipsis" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_product_names&product_id=form_basket.subscription_product_id&field_name=form_basket.subscription_product_name&field_id=form_basket.subscription_stock_id&keyword='+encodeURIComponent(document.form_basket.subscription_product_name.value));"></span>
                                    </cfoutput>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col col-4 col-md-4 col-sm-6 col-xs-12" type="column" index="3" sort="true">
                        <div class="form-group" id="item-sales_emp_id">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='41076.Satış Temsilcisi'></label>
                            <div class="col col-8 col-xs-12">
                                <div class="input-group">
                                    <input type="hidden" name="sales_emp_id" id="sales_emp_id" value="<cfif isdefined("attributes.sales_emp_id")><cfoutput>#attributes.sales_emp_id#</cfoutput></cfif>">
                                    <input type="text" name="sales_emp" id="sales_emp" value="<cfif isdefined("attributes.sales_emp")><cfoutput>#attributes.sales_emp#</cfoutput></cfif>" onfocus="AutoComplete_Create('sales_emp','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','3','EMPLOYEE_ID','sales_emp_id','','3','200');" autocomplete="off">
                                    <span class="input-group-addon btn_Pointer icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_positions&field_emp_id=form_basket.sales_emp_id&field_name=form_basket.sales_emp&select_list=1&keyword='+encodeURIComponent(form_basket.sales_emp.value));"></span>
                                </div>
                            </div>
                        </div>
                        <div class="form-group" id="item-form_ul_sales_member">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='40904.Satış Ortağı'></label>
                            <div class="col col-8 col-xs-12">
                                <div class="input-group">
                                    <input type="hidden" name="sales_member_id" id="sales_member_id" value="<cfif isdefined("attributes.sales_member_id")><cfoutput>#attributes.sales_member_id#</cfoutput></cfif>">
                                    <input type="hidden" name="sales_member_type" id="sales_member_type" value="<cfif isdefined("attributes.sales_member_type")><cfoutput>#attributes.sales_member_type#</cfoutput></cfif>">
                                    <input type="hidden" name="sales_company_id" id="sales_company_id" value="<cfif isdefined("attributes.sales_company_id")><cfoutput>#attributes.sales_company_id#</cfoutput></cfif>">
                                    <input name="sales_member" type="text" id="sales_member" onfocus="AutoComplete_Create('sales_member','MEMBER_PARTNER_NAME,MEMBER_NAME','MEMBER_PARTNER_NAME2,MEMBER_NAME2','get_member_autocomplete','\'1,2\'','PARTNER_ID2,MEMBER_TYPE,COMPANY_ID','sales_member_id,sales_member_type,sales_company_id','','3','250');" value="<cfif isdefined("attributes.sales_member")><cfoutput>#attributes.sales_member#</cfoutput></cfif>" autocomplete="off">
                                    <span class="input-group-addon btn_Pointer icon-ellipsis"  onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_pars&field_partner=form_basket.sales_member_id&field_consumer=form_basket.sales_member_id&field_comp_id=form_basket.sales_company_id&field_name=form_basket.sales_member&field_type=form_basket.sales_member_type&select_list=7,8');"></span>
                                </div>
                            </div>
                        </div>
                        <div class="form-group" id="item-form_ul_sales_member_comm_value">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='41349.Satış Ortagi Komisyonu'></label>
                            <div class="col col-5 col-xs-12">
                                <input type="text" name="sales_member_comm_value" id="sales_member_comm_value" value="" class="moneybox" onkeyup="return(FormatCurrency(this,event));">
                            </div>
                            <div class="col col-3 col-xs-12">
                                <select name="sales_member_comm_money" id="sales_member_comm_money">
                                    <cfoutput query="get_money_info">
                                        <option value="#MONEY#">#MONEY#</option>
                                    </cfoutput>
                                </select>
                            </div>
                        </div>
                        <div class="form-group" id="item-premium_value">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='41074.Prim Değeri'></label>
                            <div class="col col-8 col-xs-12">
                                <input type="text" name="premium_value" id="premium_value" class="moneybox" onkeyup="return(FormatCurrency(this,event));">
                            </div>
                        </div>
                        <div class="form-group" id="item-ref_company">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58784.Referans'><cf_get_lang dictionary_id='57457.Müşteri'></label>
                            <div class="col col-8 col-xs-12">
                                <div class="input-group">
                                    <input type="text" name="ref_company" id="ref_company" onfocus="AutoComplete_Create('ref_company','MEMBER_NAME,MEMBER_PARTNER_NAME','MEMBER_NAME2,MEMBER_PARTNER_NAME2','get_member_autocomplete','\'1,2,3\'','PARTNER_ID2,COMPANY_ID,MEMBER_TYPE,MEMBER_PARTNER_NAME2','ref_member_id,ref_company_id,ref_member_type,ref_member','','3','250','return_company()');" value="<cfif isdefined("attributes.ref_company")><cfoutput>#attributes.ref_company#</cfoutput></cfif>" autocomplete="off">
                                    <cfset str_linke_ait1 = "field_name=form_basket.ref_member&field_emp_id=form_basket.ref_member_id&field_partner=form_basket.ref_member_id&field_consumer=form_basket.ref_member_id&field_comp_id=form_basket.ref_company_id&field_comp_name=form_basket.ref_company&field_type=form_basket.ref_member_type">
                                    <span class="input-group-addon btn_Pointer icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_all_pars&<cfoutput>#str_linke_ait1#</cfoutput>&select_list=1,7,8');"></span>
                                </div>
                            </div>
                        </div>
                        <div class="form-group" id="item-ref_member">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58784.Referans'><cf_get_lang dictionary_id='57578.Yetkili'></label>
                            <div class="col col-8 col-xs-12">
                                <cfoutput>
                                    <input type="hidden" name="ref_member_id" id="ref_member_id" value="<cfif isdefined("attributes.ref_member_id")>#attributes.ref_member_id#</cfif>">
                                    <input type="hidden" name="ref_company_id" id="ref_company_id" value="<cfif isdefined("attributes.ref_company_id")>#attributes.ref_company_id#</cfif>">
                                    <input type="hidden" name="ref_member_type" id="ref_member_type" value="<cfif isdefined("attributes.ref_member_type")>#attributes.ref_member_type#</cfif>">
                                    <input type="text" name="ref_member" id="ref_member" value="<cfif isdefined("attributes.ref_member")>#attributes.ref_member#</cfif>">
                                </cfoutput>
                            </div>
                        </div>
                        <div class="form-group" id="form_ul_ref_state">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58784.Referans'><cf_get_lang dictionary_id='30111.Durumu'></label>  <!--- Referans Durumu Çevirisi Yapılmamış EKLENMELİ!!! --->
                            <div class="col col-8 col-xs-12">
                                <select name="ref_state" style="width:120px">
                                    <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                    <cfoutput query="get_ref_state">
                                        <option value="#referance_status_id#">#referance_status#</option>
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
                                        <option value="#COMP_ID#" <cfif attributes.our_company_id eq COMP_ID> selected </cfif> >#company_name#</option>
                                    </cfoutput>
                                </select>
                            </div>
                        </div>
                        <div class="form-group" id="item-form_ul_detail">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57629.Açıklama'></label>
                            <div class="col col-8 col-xs-12">
                                <textarea name="detail" id="detail"><cfif isDefined("attributes.detail")><cfoutput>#attributes.detail#</cfoutput></cfif></textarea>
                            </div>
                        </div>
                        <div class="form-group" id="item-form_ul_inv_detail">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57441.Fatura'> <cf_get_lang dictionary_id='57629.Açıklama'></label>
                            <div class="col col-8 col-xs-12">
                                <textarea name="inv_detail" id="inv_detail"></textarea>
                            </div>
                        </div>
                    </div>
                    <div class="col col-4 col-md-4 col-sm-6 col-xs-12" type="column" index="4" sort="true">
                        <div class="form-group" id="item-form_ul_contract_no">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='30044.Sözleşme No'></label>
                            <div class="col col-8 col-xs-12">
                                <input type="text" name="contract_no" id="contract_no" value="" maxlength="20">
                            </div>
                        </div>
                        <div class="form-group" id="item-form_ul_start_date">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57747.Sözleşme Tarihi'>*</label>
                            <div class="col col-8 col-xs-12">
                                <div class="input-group">
                                    <cfsavecontent variable="message1"><cf_get_lang dictionary_id='55145.Sözleşme Tarihini Kontrol Ediniz'>!</cfsavecontent>
                                    <cfinput type="text" name="start_date" id="start_date" value="#dateformat(now(),dateformat_style)#" validate="#validate_style#" required="yes" message="#message1#" maxlength="10">
                                    <span class="input-group-addon btn_Pointer"><cf_wrk_date_image date_field="start_date"></span>
                                </div>
                            </div>
                        </div>
                        <div class="form-group" id="item-form_ul_finish_date">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57748.İptal Tarihi'></label>
                            <div class="col col-8 col-xs-12">
                                <div class="input-group">
                                    <cfsavecontent variable="message1"><cf_get_lang dictionary_id='47361.Bitiş Tarihini Kontrol Ediniz'></cfsavecontent>
                                    <cfinput type="text" name="finish_date" id="finish_date" value="" validate="#validate_style#" message="#message1#" maxlength="10">
                                    <span class="input-group-addon btn_Pointer"><cf_wrk_date_image date_field="finish_date"></span>
                                </div>
                            </div>
                        </div>
                        <div class="form-group" id="item-form_ul_montage_date">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='60559.Kurulum Tarihi'></label>
                            <div class="col col-8 col-xs-12">
                                <div class="input-group">
                                    <cfsavecontent variable="message"><cf_get_lang dictionary_id='60562.Kurulum Sevk Tarihini Kontrol Ediniz'>!</cfsavecontent>
                                    <cfinput type="text" name="montage_date" id="montage_date" validate="#validate_style#" message="#message#" maxlength="10">
                                    <span class="input-group-addon btn_Pointer"><cf_wrk_date_image date_field="montage_date"></span>
                                </div>
                            </div>
                        </div>
                        <div class="form-group" id="item-form_ul_montage_emp">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='60560.Kurulum Çalışanı'></label>
                            <div class="col col-8 col-xs-12">
                                <div class="input-group">
                                    <input type="hidden" name="montage_emp_id" id="montage_emp_id" value="<cfif isDefined("attributes.montage_emp_id")><cfoutput>#attributes.montage_emp_id#</cfoutput></cfif>">
                                    <input type="text" name="montage_emp" id="montage_emp" onfocus="AutoComplete_Create('montage_emp','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','3','EMPLOYEE_ID','montage_emp_id','','3','200');" autocomplete="off" value="<cfif isDefined("attributes.montage_emp")><cfoutput>#attributes.montage_emp#</cfoutput></cfif>">
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
                                        <option value="#SUBSCRIPTION_ADD_OPTION_ID#" <cfif isDefined("attributes.subs_add_opt") and attributes.subs_add_opt eq SUBSCRIPTION_ADD_OPTION_ID>selected</cfif>>#SUBSCRIPTION_ADD_OPTION_NAME#</option>
                                    </cfoutput>
                                </select>
                            </div>
                        </div>
                        <div class="form-group" id="item-sales_add_option">
                            <label class="col col-4 col-xs-12">Servis <cf_get_lang dictionary_id='41142.Özel Tanım'></label>
                            <div class="col col-8 col-xs-12">
                                <select name="sales_add_option" id="sales_add_option">
                                    <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                    <cfoutput query="get_sale_add_option">
                                        <option value="#SERVICE_ADD_OPTION_ID#" <cfif isDefined("attributes.sales_add_opt") and attributes.sales_add_opt eq SERVICE_ADD_OPTION_ID>selected</cfif>>#SERVICE_ADD_OPTION_NAME#</option>
                                    </cfoutput>
                                </select>
                            </div>
                        </div>
                        <div class="form-group" id="item-form_ul_comp_branch">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57895.Şube İlişkisi'></label>
                            <div class="col col-8 col-xs-12">
                                <select name="comp_branch" id="comp_branch">
                                    <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                    <cfoutput query="get_branch_all">
                                        <option value="#branch_id#">#branch_name#</option>
                                    </cfoutput>
                                </select>
                            </div>
                        </div>
                        <div class="form-group" id="item-form_ul_product_key">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='62733.Ürün Anahtarı'></label>
                            <div class="col col-8 col-xs-12">
                                <div class="input-group">
                                    <input type="text" name="product_key" id="product_key">
                                    <span class="input-group-addon"><i class="fa fa-key" onclick="document.getElementById('product_key').value = Math.floor(Math.random() * 999999999999) + 1;"></i></span>
                                </div>
                            </div>
                        </div>
                    </div>
                </cf_box_elements>
                <cf_box_footer>
                    <cf_workcube_buttons is_upd='0' add_function='kontrol()'>
                </cf_box_footer>
            </cf_box>

            <cfsavecontent variable="title"><cf_get_lang dictionary_id='41081.Adresler'></cfsavecontent>
            <cf_box title="#title#" closable="0" collapsed="0">
                <cf_box_elements>
                    <div class="col col-4 col-md-4 col-sm-6 col-xs-12" type="column" index="5" sort="true">
                        <div class="form-group" id="item-form_ul_ship_address">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='60563.Kurulum Adresi'></label>
                            <div class="col col-8 col-xs-12">
                                <div class="input-group">
                                    <textarea name="ship_address" id="ship_address"><cfoutput><cfif isdefined("attributes.ship_address")>#attributes.ship_address#<cfelseif isdefined("get_addres")>#get_addres.address#</cfif></cfoutput></textarea>
                                    <span class="input-group-addon btn_Pointer icon-ellipsis" onclick="add_adress(1);"></span>
                                </div>
                            </div>
                        </div>
                        <div class="form-group" id="item-form_ul_ship_postcode">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57472.Posta Kodu'></label>
                            <div class="col col-8 col-xs-12">
                                <input type="text" name="ship_postcode" id="ship_postcode" value="<cfoutput><cfif isdefined("attributes.ship_postcode")>#attributes.ship_postcode#<cfelseif isdefined("get_addres")>#get_addres.POSTCODE#</cfif></cfoutput>" maxlength="5">
                            </div>
                        </div>
                        <div class="form-group" id="item-form_ul_ship_country_id">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58219.Ülke'></label>
                            <div class="col col-8 col-xs-12">
                                <cf_wrk_selectlang
                                    name="ship_country_id"
                                    option_name="country_name"
                                    option_value="country_id"
                                    table_name="SETUP_COUNTRY"
                                    value="#attributes.ship_country_id#"
                                    sort_type="COUNTRY_NAME"
                                    width="250"
                                    selectTwoMod="true"
                                    onchange="LoadCity(this.value,'ship_city_id','ship_county_id',0);">
                            </div>
                        </div>
                        <div class="form-group" id="item-form_ul_ship_city_id">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57971.Şehir'></label>
                            <div class="col col-8 col-xs-12">
                                <cfif len(attributes.ship_city_id)>
                                    <cf_wrk_selectlang
                                        name="ship_city_id"
                                        option_name="city_name"
                                        option_value="city_id"
                                        table_name="SETUP_CITY"
                                        value="#attributes.ship_city_id#"
                                        sort_type="city_name"
                                        width="250"
                                        selectTwoMod="true"
                                        onchange="LoadCounty(this.value,'ship_county_id')"
                                        condition="country_id=#attributes.ship_country_id#">
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
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58638.Ilçe'></label>
                            <div class="col col-8 col-xs-12">
                                <cfif len(attributes.ship_county_id)>
                                    <cf_wrk_selectlang
                                        name="ship_county_id"
                                        option_name="county_name"
                                        option_value="county_id"
                                        table_name="SETUP_COUNTY"
                                        value="#attributes.ship_county_id#"
                                        sort_type="county_name"
                                        width="250"
                                        selectTwoMod="true"
                                        condition="city=#attributes.ship_city_id#">
                                <cfelse>
                                    <cf_wrk_selectlang
                                        name="ship_county_id"
                                        width="250"
                                        selectTwoMod="true">
                                </cfif>
                            </div>
                        </div>
                        <div class="form-group" id="item-form_ul_ship_semt">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58132.Semt'></label>
                            <div class="col col-8 col-xs-12">
                                <input type="text" name="ship_semt" id="ship_semt" value="<cfoutput><cfif isdefined("attributes.ship_semt")>#attributes.ship_semt#<cfelseif isdefined("get_addres")>#get_addres.SEMT#</cfif></cfoutput>" maxlength="30">
                            </div>
                        </div>
                        <div class="form-group" id="item-form_ul_ship_sales_zones">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57659.Satış Bölgesi'></label>
                            <div class="col col-8 col-xs-12">
                                <select name="ship_sales_zone_id" id="ship_sales_zone_id">
                                    <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                    <cfoutput query="GET_SALES_ZONES">
                                        <option value="#SZ_ID#" <cfif isdefined("get_addres") and len(get_addres.SZ_ID) and get_addres.SZ_ID eq sz_id>selected<cfelseif isdefined("attributes.ship_sales_zone_id") and attributes.ship_sales_zone_id eq sz_id>selected<cfelseif isdefined("attributes.sz_id") and attributes.sz_id eq sz_id>selected</cfif>>#SZ_NAME# <cfif is_active eq 0>(<cf_get_lang dictionary_id='57494.Pasif'>)</cfif></option>
                                    </cfoutput>
                                </select>
                            </div>
                        </div>
                        <div class="form-group" id="item-form_ul_ship_coordinate_1">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58549.Koordinatlar'></label>
                            <div class="col col-1 col-xs-12">
                                <cf_get_lang dictionary_id='58553.E'>
                            </div>
                            <div class="col col-3 col-xs-12">
                                <input type="text" name="ship_coordinate_1" id="ship_coordinate_1" value="<cfoutput><cfif isdefined("attributes.ship_coordinate_1")>#attributes.ship_coordinate_1#<cfelseif isdefined("get_addres") and len(get_addres.coordinate_1)>#get_addres.coordinate_1#</cfif></cfoutput>" maxlength="10">
                            </div>
                            <div class="col col-1 col-xs-12">
                                <cf_get_lang dictionary_id='58591.B'>
                            </div>
                            <div class="col col-3 col-xs-12">
                                <input type="text" name="ship_coordinate_2" id="ship_coordinate_2" value="<cfoutput><cfif isdefined("attributes.ship_coordinate_2")>#attributes.ship_coordinate_2#<cfelseif isdefined("get_addres") and len(get_addres.coordinate_2)>#get_addres.coordinate_2#</cfif></cfoutput>" maxlength="10">
                            </div>
                        </div>
                    </div>
                    <div class="col col-4 col-md-4 col-sm-6 col-xs-12" type="column" index="6" sort="true">
                        <div class="form-group" id="item-form_ul_invoice_address">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='41085.Fatura Adresi'></label>
                            <div class="col col-8 col-xs-12">
                                <div class="input-group">
                                    <textarea name="invoice_address" id="invoice_address"><cfoutput><cfif isdefined("attributes.invoice_address")>#attributes.invoice_address#<cfelseif isdefined("attributes.address")>#attributes.address#</cfif></cfoutput></textarea>
                                    <span class="input-group-addon btn_Pointer icon-ellipsis" onclick="add_adress(2);"></span>
                                    <input type="hidden" name="ship_id" id ="ship_id" value="<cfoutput><cfif isdefined("attributes.ship_id")>#attributes.ship_id#</cfif></cfoutput>"/>
                                </div>
                            </div>
                        </div>
                        <div class="form-group" id="item-form_ul_invoice_postcode">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57472.Posta Kodu'></label>
                            <div class="col col-8 col-xs-12">
                                <input type="text" name="invoice_postcode" id="invoice_postcode" value="<cfoutput><cfif isdefined("attributes.invoice_postcode")>#attributes.invoice_postcode#<cfelseif isdefined("attributes.postcode")>#attributes.postcode#</cfif></cfoutput>" maxlength="5">
                            </div>
                        </div>
                        <div class="form-group" id="item-form_ul_invoice_country">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58219.Ülke'></label>
                            <div class="col col-8 col-xs-12">
                                <cf_wrk_selectlang
                                    name="invoice_country_id"
                                    option_name="country_name"
                                    option_value="country_id"
                                    table_name="SETUP_COUNTRY"
                                    value="#attributes.invoice_country_id#"
                                    sort_type="COUNTRY_NAME"
                                    width="250"
                                    selectTwoMod="true"
                                    onchange="LoadCity(this.value,'invoice_city_id','invoice_county_id',0);">
                            </div>
                        </div>
                        <div class="form-group" id="item-form_ul_invoice_city_id">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57971.Şehir'></label>
                            <div class="col col-8 col-xs-12">
                                <cfif len(attributes.invoice_city_id)>
                                    <cf_wrk_selectlang
                                        name="invoice_city_id"
                                        option_name="city_name"
                                        option_value="city_id"
                                        table_name="SETUP_CITY"
                                        value="#attributes.invoice_city_id#"
                                        sort_type="city_name"
                                        width="250"
                                        selectTwoMod="true"
                                        onchange="LoadCounty(this.value,'invoice_county_id')"
                                        condition="country_id=#attributes.invoice_country_id#">
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
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58638.Ilçe'></label>
                            <div class="col col-8 col-xs-12">
                                <cfif len(attributes.invoice_county_id)>
                                    <cf_wrk_selectlang
                                        name="invoice_county_id"
                                        option_name="county_name"
                                        option_value="county_id"
                                        table_name="SETUP_COUNTY"
                                        value="#attributes.invoice_county_id#"
                                        sort_type="county_name"
                                        width="250"
                                        selectTwoMod="true"
                                        condition="city=#attributes.invoice_city_id#">
                                <cfelse>
                                    <cf_wrk_selectlang
                                        name="invoice_county_id"
                                        width="250"
                                        selectTwoMod="true"
                                        >
                                </cfif>
                            </div>
                        </div>
                        <div class="form-group" id="item-form_ul_invoice_semt">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58132.Semt'></label>
                            <div class="col col-8 col-xs-12">
                                <input type="text" name="invoice_semt" id="invoice_semt" value="<cfoutput><cfif isdefined("attributes.invoice_semt")>#attributes.invoice_semt#<cfelseif isdefined("attributes.semt")>#attributes.semt#</cfif></cfoutput>" maxlength="30">
                            </div>
                        </div>
                        <div class="form-group" id="item-form_ul_invoice_sales_zones">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57659.Satış Bölgesi'></label>
                            <div class="col col-8 col-xs-12">
                                <select name="invoice_sales_zone_id" id="invoice_sales_zone_id">
                                    <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                    <cfoutput query="GET_SALES_ZONES">
                                        <option value="#SZ_ID#" <cfif isdefined("invoice_sz_id") and len(invoice_sz_id) and invoice_sz_id eq sz_id>selected<cfelseif isdefined("attributes.invoice_sales_zone_id") and attributes.invoice_sales_zone_id eq sz_id>selected<cfelseif isdefined("attributes.sz_id") and attributes.sz_id eq sz_id>selected</cfif>>#SZ_NAME# <cfif is_active eq 0>(<cf_get_lang dictionary_id='57494.Pasif'>)</cfif></option>
                                    </cfoutput>
                                </select>
                            </div>
                        </div>
                        <div class="form-group" id="item-form_ul_invoice_coordinate_1">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58549.Koordinatlar'></label>
                            <div class="col col-1 col-xs-12">
                                <cf_get_lang dictionary_id='58553.E'>
                            </div>
                            <div class="col col-3 col-xs-12">
                                <input type="text" name="invoice_coordinate_1" id="invoice_coordinate_1" value="<cfoutput><cfif isdefined("attributes.invoice_coordinate_1")>#attributes.invoice_coordinate_1#<cfelseif isdefined("attributes.coordinate_1")>#attributes.coordinate_1#</cfif></cfoutput>" maxlength="10">
                            </div>
                            <div class="col col-1 col-xs-12">
                                <cf_get_lang dictionary_id='58591.B'>
                            </div>
                            <div class="col col-3 col-xs-12">
                                <input type="text" name="invoice_coordinate_2" id="invoice_coordinate_2" value="<cfoutput><cfif isdefined("attributes.invoice_coordinate_2")>#attributes.invoice_coordinate_2#<cfelseif isdefined("attributes.coordinate_2")>#attributes.coordinate_2#</cfif></cfoutput>" maxlength="10">
                            </div>
                        </div>
                        <div class="form-group" id="item-form_ul_invoice_coordinate_1">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='60078.Alias'></label>
                            <div class="col col-8 col-xs-12">
                                    <input type="text" id="alias" name="alias" value="<cfoutput><cfif isdefined("attributes.alias")>#attributes.alias#</cfif></cfoutput>" readonly="readonly"/>
                            </div>
                        </div>
                    </div>
                    <div class="col col-4 col-md-4 col-sm-6 col-xs-12" type="column" index="7" sort="true">
                        <div class="form-group" id="item-form_ul_contact_address">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='41086.Irtibat Adresi'></label>
                            <div class="col col-8 col-xs-12">
                                <div class="input-group">
                                    <textarea name="contact_address" id="contact_address"  style="width:120px;height:40px;"><cfoutput><cfif isdefined("attributes.contact_address")>#attributes.contact_address#<cfelseif isdefined("get_addres")>#get_addres.address#</cfif></cfoutput></textarea>
                                    <span class="input-group-addon btn_Pointer icon-ellipsis" onclick="add_adress(3);"></span>
                                </div>
                            </div>
                        </div>
                        <div class="form-group" id="item-form_ul_contact_postcode">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57472.Posta Kodu'></label>
                            <div class="col col-8 col-xs-12">
                                <input type="text" name="contact_postcode" id="contact_postcode" value="<cfoutput><cfif isdefined("attributes.contact_postcode")>#attributes.contact_postcode#<cfelseif isdefined("get_addres")>#get_addres.POSTCODE#</cfif></cfoutput>" maxlength="5">
                            </div>
                        </div>
                        <div class="form-group" id="item-form_ul_contact_country_id">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58219.Ülke'></label>
                            <div class="col col-8 col-xs-12">
                                <cf_wrk_selectlang
                                    name="contact_country_id"
                                    option_name="country_name"
                                    option_value="country_id"
                                    table_name="SETUP_COUNTRY"
                                    value="#attributes.contact_country_id#"
                                    sort_type="COUNTRY_NAME"
                                    width="250"
                                    selectTwoMod="true"
                                    onchange="LoadCity(this.value,'contact_city_id','contact_county_id',0);">
                            </div>
                        </div>
                        <div class="form-group" id="item-form_ul_contact_city_id-">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57971.Şehir'></label>
                            <div class="col col-8 col-xs-12">
                                <cfif len(attributes.contact_city_id)>
                                    <cf_wrk_selectlang
                                        name="contact_city_id"
                                        option_name="city_name"
                                        option_value="city_id"
                                        table_name="SETUP_CITY"
                                        value="#attributes.contact_city_id#"
                                        sort_type="city_name"
                                        width="250"
                                        selectTwoMod="true"
                                        onchange="LoadCounty(this.value,'contact_county_id')"
                                        condition="country_id=#attributes.contact_country_id#">
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
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58638.Ilçe'></label>
                            <div class="col col-8 col-xs-12">
                                <cfif len(attributes.contact_county_id)>
                                    <cf_wrk_selectlang
                                        name="contact_county_id"
                                        option_name="county_name"
                                        option_value="county_id"
                                        table_name="SETUP_COUNTY"
                                        value="#attributes.contact_county_id#"
                                        sort_type="county_name"
                                        width="250"
                                        selectTwoMod="true"
                                        condition="city=#attributes.contact_city_id#">
                                <cfelse>
                                    <cf_wrk_selectlang
                                        name="contact_county_id"
                                        width="250"
                                        selectTwoMod="true"
                                        >
                                </cfif>
                            </div>
                        </div>
                        <div class="form-group" id="item-form_ul_contact_semt">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58132.Semt'></label>
                            <div class="col col-8 col-xs-12">
                                <input type="text" name="contact_semt" id="contact_semt" value="<cfoutput><cfif isdefined("attributes.contact_semt")>#attributes.contact_semt#<cfelseif isdefined("get_addres")>#get_addres.SEMT#</cfif></cfoutput>" maxlength="30">
                            </div>
                        </div>
                        <div class="form-group" id="item-form_ul_contact_sales_zones">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57659.Satış Bölgesi'></label>
                            <div class="col col-8 col-xs-12">
                                <select name="contact_sales_zone_id" id="contact_sales_zone_id">
                                    <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                    <cfoutput query="GET_SALES_ZONES">
                                        <option value="#SZ_ID#" <cfif isdefined("get_addres") and len(get_addres.SZ_ID) and get_addres.SZ_ID eq sz_id>selected<cfelseif isdefined("attributes.contact_sales_zone_id") and attributes.contact_sales_zone_id eq sz_id>selected<cfelseif isdefined("attributes.sz_id") and attributes.sz_id eq sz_id>selected</cfif>>#SZ_NAME# <cfif is_active eq 0>(<cf_get_lang dictionary_id='57494.Pasif'>)</cfif></option>
                                    </cfoutput>
                                </select>
                            </div>
                        </div>
                        <div class="form-group" id="item-form_ul_contact_coordinate_1">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58549.Koordinatlar'></label>
                            <div class="col col-1 col-xs-12">
                                <cf_get_lang dictionary_id='58553.E'>
                            </div>
                            <div class="col col-3 col-xs-12">
                                <input type="text" name="contact_coordinate_1" id="contact_coordinate_1" value="<cfoutput><cfif isdefined("attributes.contact_coordinate_1")>#attributes.contact_coordinate_1#<cfelseif isdefined("get_addres") and len(get_addres.coordinate_1)>#get_addres.coordinate_1#</cfif></cfoutput>" maxlength="10">
                            </div>
                            <div class="col col-1 col-xs-12">
                                <cf_get_lang dictionary_id='58591.B'>
                            </div>
                            <div class="col col-3 col-xs-12">
                                <input type="text" name="contact_coordinate_2" id="contact_coordinate_2" value="<cfoutput><cfif isdefined("attributes.contact_coordinate_2")>#attributes.contact_coordinate_2#<cfelseif isdefined("get_addres") and len(get_addres.coordinate_2)>#get_addres.coordinate_2#</cfif></cfoutput>" maxlength="10">
                            </div>
                        </div>
                    </div>
                </cf_box_elements>
            </cf_box>
            <cfif xml_service_definition eq 1>
                <cf_box
                    title="#getLang('main',1460)#"
                    closable="0"
                    collapsed="0"
                    box_page="#request.self#?fuseaction=sales.service_definitions_ajax">
                </cf_box>
            </cfif>           
            <cfset attributes.basket_id = 46>
            <cfif not isDefined("attributes.subscription_id")>
            <cfset attributes.form_add = 1>
            </cfif>
            <cfif xml_system_product_plan_closed eq 1>
                <cf_box title="#getLang('sales',142)#" closable="0" collapsed="0" is_basket="1">
                    <cfinclude template="../../objects/display/basket.cfm">
                </cf_box><br />
            </cfif>
        </div>
    </cfform>
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
					str_adrlink = '&field_adres=form_basket.invoice_address&field_city=form_basket.invoice_city_id&field_county=form_basket.invoice_county_id&field_country=form_basket.invoice_country_id&field_postcode=form_basket.invoice_postcode&field_semt=form_basket.invoice_semt&coordinate_1=form_basket.invoice_coordinate_1&coordinate_2=form_basket.invoice_coordinate_2&sales_zone=form_basket.invoice_sales_zone_id&alias=form_basket.alias&field_adress_id=form_basket.ship_id';
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
					openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_member_address&is_comp=0&is_select=2&keyword='+encodeURIComponent(form_basket.member_name.value)+''+ str_adrlink);
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
					str_adrlink = '&field_adres=form_basket.contact_address&field_city=form_basket.contact_city_id&field_county=form_basket.contact_county_idfield_country=form_basket.contact_country_id&field_postcode=form_basket.contact_postcode&field_semt=form_basket.contact_semt&coordinate_1=form_basket.contact_coordinate_1&coordinate_2=form_basket.contact_coordinate_2&sales_zone=form_basket.contact_sales_zone_id';
					openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_member_address&is_comp=0&is_select=2&keyword='+encodeURIComponent(form_basket.member_name.value)+''+ str_adrlink);
					return true;
				}
			}
		}
		else
		{
			alert("<cf_get_lang dictionary_id='41104.Müşteri Seçiniz'> !");
            document.getElementById('company_name').focus();
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
function kontrol()
{
if((document.form_basket.partner_id.value == "") && (document.form_basket.consumer_id.value == ""))
{
alert("<cf_get_lang dictionary_id='41104.Müşteri Seçiniz'> !");
document.getElementById('company_name').focus();
    return false;
}

    a = document.form_basket.subscription_type.selectedIndex;
if (document.form_basket.subscription_type[a].value == "")
{
alert ("<cf_get_lang dictionary_id='41094.Sistem Kategorisi Seçiniz'> ");
    document.getElementById('subscription_type').focus();
    return false;
}

    x = (300 - document.form_basket.ship_address.value.length);
if ( x < 0)
{
alert ("<cf_get_lang dictionary_id='40804.Sevk Adresi'><cf_get_lang dictionary_id ='41312.Alanina 300 Karakterden Fazla Girmeyiniz Fazla Karakter Sayısı'>"+ ((-1) * x));
    return false;
}

    y = (300 - document.form_basket.invoice_address.value.length);
if ( y < 0)
{
alert ("<cf_get_lang dictionary_id='41085.Fatura Adresi'><cf_get_lang dictionary_id ='41312.Alanina 300 Karakterden Fazla Girmeyiniz Fazla Karakter Sayısı'>"+ ((-1) * x));
    return false;
}

    z = (300 - document.form_basket.contact_address.value.length);
if ( z < 0)
{
alert ("<cf_get_lang dictionary_id='41086.Irtibat Adresi'><cf_get_lang dictionary_id ='41312.Alanina 300 Karakterden Fazla Girmeyiniz Fazla Karakter Sayısı'>"+ ((-1) * x));
    return false;
}

    t = (500 - document.form_basket.detail.value.length);
if ( t < 0 )
{
alert ("<cf_get_lang dictionary_id='57629.Aciklama'><cf_get_lang dictionary_id ='41315.Alanina 500 Karakterden Fazla Girmeyiniz Fazla Karakter Sayısı'>"+ ((-1) * x));
    return false;
}

if(!(document.form_basket.start_date.value == "") && !(document.form_basket.finish_date.value == ""))
{
if(!date_check(document.form_basket.start_date,document.form_basket.finish_date,"<cf_get_lang dictionary_id ='41316.Başlangıç Bitiş Tarihlerini Kontrol Ediniz'>!"))
{
    return false;
}
}

<cfif isdefined("xml_service_definition") and xml_service_definition eq 1>
if((document.form_basket.valid_days.value == 1) && (document.form_basket.start_clock_1.value == 0) && (document.form_basket.finish_clock_1.value == 0) && (document.form_basket.start_minute_1.value == 0) && (document.form_basket.finish_minute_1.value == 0) )
{
alert("<cf_get_lang dictionary_id='40861.Hafta İçi Destek Saatlerini Seçiniz'> ! ");
        return false;
    }

    if((document.form_basket.valid_days.value == 2) && (document.form_basket.start_clock_1.value == 0) && (document.form_basket.finish_clock_1.value == 0) && (document.form_basket.start_minute_1.value == 0) && (document.form_basket.finish_minute_1.value == 0) )
    {
    alert("<cf_get_lang dictionary_id='40863.Hafta İçi Ve Cumartesi Destek Saatlerini Seçiniz'> ! ");
        return false;
    }

    if((document.form_basket.valid_days.value == 2) && (document.form_basket.start_clock_2.value == 0) && (document.form_basket.finish_clock_2.value == 0) && (document.form_basket.start_minute_2.value == 0) && (document.form_basket.finish_minute_2.value == 0))
    {
    alert("<cf_get_lang dictionary_id='40868.Cumartesi Destek Saatlerini Seçiniz'> ! ");
        return false;
    }

    if((document.form_basket.valid_days.value == 3) && (document.form_basket.start_clock_1.value == 0) && (document.form_basket.finish_clock_1.value == 0) && (document.form_basket.start_minute_1.value == 0) && (document.form_basket.finish_minute_1.value == 0) )
    {
    alert("<cf_get_lang dictionary_id='40869.Hafta İçi, Cumartesi Ve Pazar Destek Saatlerini Seçiniz'> ! ");
        return false;
    }

    if((document.form_basket.valid_days.value == 3) && (document.form_basket.start_clock_2.value == 0) && (document.form_basket.finish_clock_2.value == 0) && (document.form_basket.start_minute_2.value == 0) && (document.form_basket.finish_minute_2.value == 0))
    {
    alert("<cf_get_lang dictionary_id='40870.Cumartesi ve Pazar Destek Saatlerini Seçiniz'> ! ");
        return false;
    }

    if((document.form_basket.valid_days.value == 3) && (document.form_basket.start_clock_3.value == 0) && (document.form_basket.finish_clock_3.value == 0) && (document.form_basket.start_minute_3.value == 0) && (document.form_basket.finish_minute_3.value == 0))
    {
    alert("<cf_get_lang dictionary_id='40871.Pazar Destek Saatlerini Seçiniz'> ! ");
        return false;
    }

        start_1 = parseInt(document.form_basket.start_clock_1.value) * 60 ;
        sonuc_1 = start_1 +  parseInt(document.form_basket.start_minute_1.value);
        finish_1 = parseInt(document.form_basket.finish_clock_1.value) * 60 ;
        sonuc_2 = finish_1 +  parseInt(document.form_basket.finish_minute_1.value);
    if( sonuc_1 > sonuc_2)
    {
    alert("<cf_get_lang dictionary_id='40872.Hafta İçi İçin Uygun Saat Değeri Giriniz'> ! ");
        return false;
    }

        start_2 = parseInt(document.form_basket.start_clock_2.value) * 60 ;
        sonuc_3 = start_2 +  parseInt(document.form_basket.start_minute_2.value);
        finish_2 = parseInt(document.form_basket.finish_clock_2.value) * 60 ;
        sonuc_4 = finish_2 +  parseInt(document.form_basket.finish_minute_2.value);
    if( sonuc_3 > sonuc_4)
    {
    alert("<cf_get_lang dictionary_id='40873.Cumartesi Günü İçin Uygun Saat Değeri Giriniz'> ! ");
        return false;
    }

        start_3 = parseInt(document.form_basket.start_clock_3.value) * 60 ;
        sonuc_5 = start_3 +  parseInt(document.form_basket.start_minute_3.value);
        finish_3 = parseInt(document.form_basket.finish_clock_3.value) * 60 ;
        sonuc_6 = finish_3 +  parseInt(document.form_basket.finish_minute_3.value);
    if( sonuc_5 > sonuc_6)
    {
    alert("<cf_get_lang dictionary_id='40874.Pazar Günü İçin Uygun Saat Değeri Giriniz'> ! ");
        return false;
    }
</cfif>

    return (process_cat_control() && saveForm());
    return false;
}
     
		function kontrol_prerecord()
	{
		if(form_basket.member_name.value!=""){
			if(form_basket.member_type.value=='partner')
                openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_check_contract_prerecords&member_type=partner&company_name='+ encodeURIComponent(form_basket.company_name.value) +'&member_name=' + encodeURIComponent(form_basket.member_name.value) +'&partner_id='+ form_basket.partner_id.value +'&company_id='+ form_basket.company_id.value);
			else
                openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_check_contract_prerecords&member_type=consumer&member_name=' + encodeURIComponent(form_basket.member_name.value) +'&consumer_id='+ form_basket.consumer_id.value);
		}
	}

	function return_company()
	{
		if(document.getElementById('ref_member_type').value=='employee')
		{
			var emp_id = document.getElementById('ref_member_id').value;
			var GET_COMPANY=wrk_safe_query('sls_get_cmpny_2','dsn',0,emp_id);
			document.getElementById('ref_company_id').value=GET_COMPANY.COMP_ID;
		}
		else
			return false;
	}
	<cfif isDefined("attributes.subscription_id")>
        var rowCount = <cfoutput>#GET_SUBSCRIPTION.recordcount#</cfoutput>;
		for( var satir_index = 1 ; satir_index <= rowCount ; satir_index++)
		{
			if(satir_index < rowCount)
				hesapla('price_other',satir_index,0);
			else <!--- sadece son satirda toplam hesaplansin  --->
				hesapla('price_other',satir_index,1);
		}
		toplam_hesapla(0);
	</cfif>
</script>
