<cf_xml_page_edit fuseact="sales.form_add_offer">
<cfscript>session_basket_kur_ekle(process_type:1,table_type_id:4,action_id:attributes.OFFER_ID);</cfscript>
<cfset attributes.purchase_sales = 1>
<cfinclude template="../query/get_offer.cfm">
<cfset head_ = Replace(get_offer.offer_head,'"','','all')>
<cfset head_ = Replace(head_,"'","","all")>
<cfif not get_offer.recordcount or (isdefined("attributes.active_company") and attributes.active_company neq session.ep.company_id)>
	<cfset hata  = 11>
	<cfsavecontent variable="message"><cf_get_lang_main no='585.Şube Yetkiniz Uygun Değil'> <cf_get_lang_main no='586.Veya'> Şirketinizde Böyle Bir Teklif Bulunamadı !</cfsavecontent>
	<cfset hata_mesaj  = message>
	<cfinclude template="../../dsp_hata.cfm">
	<cfexit method="exittemplate">
</cfif>
<cfinclude template="../query/get_moneys.cfm">
<cfinclude template="../query/get_taxes.cfm">
<cfinclude template="../query/get_commethod_cats.cfm">
<cfinclude template="../query/get_offer_currencies.cfm">
<cfif len(get_offer.consumer_id)>
	<cfset contact_type = "c">
	<cfset contact_id = get_offer.consumer_id>
	<cfset dsp_account=1>
<cfelseif len(get_offer.partner_id)>
	<cfset contact_type = "p">
	<cfset contact_id = get_offer.partner_id>
	<cfset dsp_account = 1>
<cfelseif len(get_offer.company_id)>
	<cfset contact_type = "comp">
	<cfset contact_id = get_offer.company_id>
	<cfset dsp_account = 1>
<cfelseif len(get_offer.employee_id)>
	<cfset contact_type = "e">
	<cfset contact_id = get_offer.employee_id>
	<cfset dsp_account=0>
<cfelseif len(listsort(get_offer.offer_to_partner,"numeric"))>
	<cfset contact_type = "p" >
	<cfset contact_id = listfirst(listsort(get_offer.offer_to_partner,"numeric"))>
	<cfset dsp_account=1>
<cfelse>
	<cfset contact_type = "" >
	<cfset contact_id = ''>
	<cfset dsp_account=0>
</cfif>
<cfset attributes.basket_id = 3>
<cfset cmp = createObject("component","V16.settings.cfc.setupCountry") />
<cfset GET_COUNTRY = cmp.getCountry()>
<cfquery name="GET_SALE_ZONES" datasource="#DSN#">
	SELECT SZ_ID,SZ_NAME FROM SALES_ZONES WHERE IS_ACTIVE=1 ORDER BY SZ_NAME
</cfquery>
<cfset pageHead = "#getlang('main',2210)#: #GET_OFFER.offer_number#">
<cf_catalystHeader>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box>
		<div id="basket_main_div">
			<cfform name="form_basket" method="post" action="#request.self#?fuseaction=sales.emptypopup_upd_offer_tv">
				<cf_basket_form id="detail_offer">
					<cfoutput>
						<input type="hidden" name="form_action_address" id="form_action_address" value="sales.emptypopup_upd_offer_tv">
						<input type="hidden" name="xml_offer_revision" id="xml_offer_revision" value="<cfif xml_offer_revision eq 1>1<cfelse>0</cfif>">
						<input type="hidden" name="active_company" id="active_company" value="#session.ep.company_id#">
						<input type="hidden" name="search_process_date" id="search_process_date" value="offer_date">
						<input type="hidden" name="offer_id" id="offer_id" value="#attributes.offer_id#">
						<input type="hidden" name="company_id" id="company_id" value="#get_offer.company_id#">
						<input type="hidden" name="offer_pre_status" id="offer_pre_status" value="#get_offer.offer_currency#">	
						<input type="hidden" name="stage" id="stage" value="#get_offer.offer_stage#">
					</cfoutput>
					<cfinclude template="detail_offer_tv_noeditor.cfm">
				</cf_basket_form>
				<cfinclude template="../../objects/display/basket.cfm">
			</cfform>
		</div>
	</cf_box>
</div>
<script type="text/javascript">
	function kontrol (ship_address,limit)
	{
		StrLen = ship_address.value.length;
		if (StrLen > limit)
		{
			alert("<cfoutput>#getLang('','Teslim Yeri En Fazla 200 Karakter Girilebilir',41320)#</cfoutput>");
			return false;
		}
	}

	function check()
	{

		if(form_basket.deliverdate.value == "")
		{
			alert("<cfoutput>#getLang('','Teslim Tarihi Girmelisiniz',45467)#</cfoutput>!");
			return false;
		}
		else
		{
			if (!date_check(form_basket.offer_date,form_basket.deliverdate,"Teklif Teslim Tarihi Teklif Tarihinden Önce Olamaz !"))
				return false;
		}


		return (process_cat_control() && saveForm());
	}
	function add_adress()
	{
		if(!(form_basket.company_id.value=="") || !(form_basket.member_id.value==""))
		{
			if(form_basket.company_id.value!="")
			{
				str_adrlink = '&field_long_adres=form_basket.ship_address&field_adress_id=form_basket.ship_address_id';
				if(form_basket.city_id!=undefined) str_adrlink = str_adrlink+'&field_city=form_basket.city_id';
				if(form_basket.county_id!=undefined) str_adrlink = str_adrlink+'&field_county=form_basket.county_id';
				member_type_='partner';
				openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_member_address&is_comp=1&company_id='+form_basket.company_id.value+'&member_name='+form_basket.company_name.value+'&member_type='+member_type_+''+ str_adrlink);
				return true;
			}
			else
			{
				str_adrlink = '&field_long_adres=form_basket.ship_address&field_adress_id=form_basket.ship_address_id';
				if(form_basket.city_id!=undefined) str_adrlink = str_adrlink+'&field_city=form_basket.city_id';
				if(form_basket.county_id!=undefined) str_adrlink = str_adrlink+'&field_county=form_basket.county_id';
				member_type_='consumer';
				openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_member_address&is_comp=0&consumer_id='+form_basket.consumer_id.value+'&member_name='+form_basket.consumer.value+'&member_type='+member_type_+''+ str_adrlink);
				return true;
			}
		}
		else
		{
			alert("<cfoutput>#getLang('','Cari Hesap Seçmelisiniz',33557)#</cfoutput>");
			return false;
		}
	}
</script>
