<div style="display:none;z-index:999;" id="phl_div"></div>
<cfinclude template="../query/get_commethod_cats.cfm">
<cfinclude template="../query/get_moneys.cfm">
<cfinclude template="../query/get_taxes.cfm">
<cf_xml_page_edit fuseact="sales.form_add_offer">
<cfif isdefined("attributes.offer_id") and len(attributes.offer_id)>
	<!--- Ayni belge donusumlerinde buna gerek yok <cfscript>session_basket_kur_ekle(process_type:1,table_type_id:4,action_id:attributes.offer_id);</cfscript> --->
	<cfinclude template="../query/get_offer.cfm">
	<cfinclude template="../query/get_offer_currencies.cfm">
	<cfset attributes.subject = get_offer.offer_head>
	<cfif Len(get_offer.company_id)>
		<cfset attributes.company_id = get_offer.company_id>
		<cfset attributes.partner_id = get_offer.partner_id>
	<cfelseif ListLen(get_offer.offer_to_partner) eq 1>
		<cfset attributes.company_id = ListDeleteDuplicates(get_offer.offer_to)>
		<cfset attributes.partner_id = ListDeleteDuplicates(get_offer.offer_to_partner)>
	<cfelseif Len(get_offer.consumer_id)>
		<cfset attributes.consumer_id = get_offer.consumer_id>
	<cfelse>
		<cfset attributes.company_id = "">
		<cfset attributes.partner_id = "">
		<cfset attributes.consumer_id = "">
	</cfif>
	<cfset attributes.paymethod_id = get_offer.paymethod>
	<cfset attributes.card_paymethod_id = get_offer.card_paymethod_id>
	<cfset attributes.commission_rate = get_offer.card_paymethod_rate>
	<cfset attributes.ship_method = get_offer.ship_method>
	<cfset attributes.ship_address = get_offer.ship_address>
	<cfset attributes.ship_address_id_ = get_offer.ship_address_id>
	<cfset attributes.ship_date = get_offer.ship_date>
	<cfset attributes.deliverdate = get_offer.deliverdate>
	<cfset attributes.finishdate = get_offer.finishdate>
	<cfset attributes.city_id = get_offer.city_id>
	<cfset attributes.county_id = get_offer.county_id>
	<cfset attributes.sales_partner_id = get_offer.sales_partner_id>
	<cfset attributes.sales_consumer_id = get_offer.sales_consumer_id>
	<cfset attributes.is_public_zone = get_offer.is_public_zone>
	<cfset attributes.is_partner_zone = get_offer.is_partner_zone>
	<cfset attributes.project_id = get_offer.project_id>
	<cfset attributes.ref_no = get_offer.ref_no>
	<cfset attributes.sales_add_option_id = get_offer.sales_add_option_id>
	<cfset attributes.ref_company_id = get_offer.ref_company_id>
	<cfset attributes.ref_partner_id = get_offer.ref_partner_id>
	<cfset attributes.ref_consumer_id = get_offer.ref_consumer_id>
	<cfset attributes.rel_opp_id = get_offer.opp_id>
	<cfif xml_offer_revision eq 1>
		<cfif len(get_offer.relation_offer_id)>
			<cfset attributes.rel_offer_id = get_offer.relation_offer_id>
		<cfelse>
			<cfset attributes.rel_offer_id = attributes.offer_id>
		</cfif>
	</cfif>
	<cfset attributes.country_id = get_offer.country_id>
<cfelseif isdefined("attributes.opp_id") and len(attributes.opp_id)>
	<!---Fırsat - teklif ilişkisi --->
	<cfscript>session_basket_kur_ekle(process_type:0);</cfscript>
	<cfset attributes.purchase_sales = 1>
	<cfquery name="get_opportunities" datasource="#DSN3#">
		SELECT * FROM OPPORTUNITIES WHERE OPP_ID = #attributes.opp_id#
	</cfquery>
	<cfset attributes.subject = get_opportunities.opp_head>
	<cfset attributes.company_id = get_opportunities.company_id>
	<cfset attributes.partner_id = get_opportunities.partner_id>
	<cfset attributes.consumer_id = get_opportunities.consumer_id>
	<cfset attributes.sales_partner_id = get_opportunities.sales_partner_id>
	<cfset attributes.sales_consumer_id = get_opportunities.sales_consumer_id>
	<cfset attributes.ship_date = "">
	<cfset attributes.deliverdate = "">
	<cfset attributes.finishdate = "">
	<cfset attributes.project_id = get_opportunities.project_id>
	<cfset attributes.sales_add_option_id = get_opportunities.sale_add_option_id>
	<cfset attributes.sales_emp_id = get_opportunities.sales_emp_id>
	<cfset attributes.ref_company_id = get_opportunities.ref_company_id>
	<cfset attributes.ref_partner_id = get_opportunities.ref_partner_id>
	<cfset attributes.ref_consumer_id = get_opportunities.ref_consumer_id>
    <cfset attributes.country_id=get_opportunities.country_id>
    <cfset attributes.sz_id=get_opportunities.sz_id>
    <cfset attributes.ref_no=get_opportunities.opp_no>
<cfelse>
	<cfset attributes.subject = "Teklifimiz">
	<cfset attributes.ship_date = "">
	<cfset attributes.deliverdate = "">
	<cfset attributes.finishdate = "">
</cfif>
<cfif isdefined("url.company_id") and len(url.company_id)>
	<cfset attributes.comp_id = url.company_id>
	<cfscript>session_basket_kur_ekle(process_type:0);</cfscript>
<cfelseif isdefined("url.consumer_id") and len(url.consumer_id)>
	<cfset attributes.cons_id = url.consumer_id>
	<cfscript>session_basket_kur_ekle(process_type:0);</cfscript>
<cfelse>
	<cfif isdefined("attributes.COMPANY_ID")>
		<cfset attributes.comp_id = attributes.COMPANY_ID>
	</cfif>
	<cfscript>session_basket_kur_ekle(process_type:0);</cfscript>
</cfif>
<cfset cmp = createObject("component","V16.settings.cfc.setupCountry") />
<cfset GET_COUNTRY = cmp.getCountry()>
<cfquery name="GET_SALE_ZONES" datasource="#DSN#">
	SELECT SZ_ID,SZ_NAME FROM SALES_ZONES
</cfquery>
<cf_catalystHeader>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box>
		<div id="basket_main_div">
			<cfform name="form_basket" method="post" enctype="multipart/form-data" action="#request.self#?fuseaction=sales.emptypopup_add_offer">
				<cf_basket_form id="add_offer">
					<cfoutput>
						<input type="hidden" name="form_action_address" id="form_action_address" value="sales.emptypopup_add_offer">
						<input type="hidden" name="xml_offer_revision" id="xml_offer_revision" value="<cfif xml_offer_revision eq 1>1<cfelse>0</cfif>">
						<input type="hidden" name="active_company" id="active_company" value="#session.ep.company_id#">
						<input type="hidden" name="search_process_date" id="search_process_date" value="offer_date">
						<cfif isdefined("attributes.opp_id")>
							<input type="hidden" name="opp_id" id="opp_id" value="#attributes.opp_id#">
						<cfelseif isdefined('attributes.rel_opp_id') and len(attributes.rel_opp_id)>
							<input type="hidden" name="opp_id" id="opp_id" value="#attributes.rel_opp_id#">
						</cfif>
						<cfif isdefined("attributes.event_plan_row_id") and len(attributes.event_plan_row_id)>
							<input type="hidden" name="event_plan_row_id" id="event_plan_row_id" value="#attributes.event_plan_row_id#"/>
						</cfif>
						<cfif isdefined("attributes.offer_id") and Len(attributes.offer_id)>
							<!--- Kopyalamada action tarafinda ihtiyacimiz oldugu icin offer_id yi aldik Fbs 20110530 --->
							<input type="hidden" name="offer_id" id="offer_id" value="#attributes.offer_id#">
							<!--- kopyalama icin degil!!! iliski icin yazildi silmeyin yo20072009 --->
							<cfif isdefined("attributes.ref") and attributes.ref is 'offer'><input type="hidden" name="ref" id="ref" value="#attributes.ref#"></cfif>
							<!--- kopyalama icin degil!!! iliski icin yazildi silmeyin yo20072009 --->
						</cfif>
					</cfoutput>
					<cfinclude template="add_offer_noeditor.cfm">
				</cf_basket_form>
				<cfset attributes.basket_id = 3>
				<cfif isdefined("attributes.offer_id") and len(attributes.offer_id)>
					<cfset attributes.is_copy = 1>
				<cfelseif isdefined("attributes.opp_id") and len(attributes.opp_id) and isdefined("attributes.product_id")>
				
					<cfset attributes.basket_id = 3>
				<cfelseif not isdefined("attributes.file_format") and not isdefined('attributes.from_add_order_report')>
					<cfset attributes.form_add = 1>
			
				<cfelse>
					<cfset attributes.basket_sub_id = 21>
				</cfif>
				<cfinclude template="../../objects/display/basket.cfm">
			</cfform>
		</div>
	</cf_box>
</div>
<script type="text/javascript">
	function kontrol(ship_address,limit)
	{
		Strlen = ship_address.value.length;
		if (Strlen > limit)
		{
			alert("<cfoutput>#getLang('','Teslim Yeri En Fazla 200 Karakter Girilebilir','41320')#</cfoutput>!");
			return false;
		}
	}
	function check()
	{
		if (form_basket.member_name.value == "" && form_basket.partner_name.value == "")
		{
			alert("<cfoutput>#getLang('','Cari Hesap Seçmelisiniz','51429')#</cfoutput>!");
			return false;
		}

		if(form_basket.deliverdate.value == "")
		{
			alert("<cfoutput>#getLang('','Teslim Tarihi Girmelisiniz','45467')#</cfoutput>!");
			
			return false;
		}
		else
		{
			if (!date_check(form_basket.offer_date,form_basket.deliverdate,"<cfoutput>#getLang('','Teklif Teslim Tarihi Teklif Tarihinden Önce Olamaz','65983')#</cfoutput>!"))
				return false;
		}

		return (process_cat_control() && saveForm());
	}
	function add_adress()
	{
		if(!(form_basket.company_id.value=="") || !(form_basket.consumer_id.value==""))
		{
			if(form_basket.company_id.value!="")
			{
				str_adrlink = '&field_long_adres=form_basket.ship_address&field_adress_id=form_basket.ship_address_id';
				if(form_basket.city_id!=undefined) str_adrlink = str_adrlink+'&field_city=form_basket.city_id';
				if(form_basket.county_id!=undefined) str_adrlink = str_adrlink+'&field_county=form_basket.county_id';
				member_type_='partner';
				openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_member_address&is_comp=1&company_id='+form_basket.company_id.value+'&member_name='+form_basket.member_name.value+'&member_type='+member_type_+''+ str_adrlink);
				return true;
			}
			else
			{
				str_adrlink = '&field_long_adres=form_basket.ship_address&field_adress_id=form_basket.ship_address_id';
				if(form_basket.city_id!=undefined) str_adrlink = str_adrlink+'&field_city=form_basket.city_id';
				if(form_basket.county_id!=undefined) str_adrlink = str_adrlink+'&field_county=form_basket.county_id';
				member_type_='consumer';
				openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_member_address&is_comp=0&consumer_id='+form_basket.consumer_id.value+'&member_name='+form_basket.partner_name.value+'&member_type='+member_type_+''+ str_adrlink);
				return true;
			}
		}
		else
		{
			alert("<cfoutput>#getLang('','Cari Hesap Seçmelisiniz','51429')#</cfoutput>!");
			return false;
		}
	}
	function open_phl() {
		document.getElementById("phl_div").style.display ='';	
		$("#phl_div").css('margin-left',$("#tabMenu").position().left - 700);
		$("#phl_div").css('margin-top',$("#tabMenu").position().top + 50);
		$("#phl_div").css('position','absolute');	
		
		AjaxPageLoad('<cfoutput>#request.self#?fuseaction=objects.add_order_from_file&from_where=5</cfoutput>','phl_div',1);
		return false;
	}
</script>
