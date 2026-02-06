<cf_xml_page_edit fuseact="sales.form_add_opportunity">
<cfinclude template="../query/get_opportunity.cfm">
<cfif not get_opportunity.recordcount>
	<br />
	<cfset hata  = 11>
	<cfsavecontent variable="message"><cf_get_lang dictionary_id='57997.Şube Yetkiniz Uygun Değil'> <cf_get_lang dictionary_id='57998.Veya'> <cf_get_lang dictionary_id='62039.Şirketinizde Böyle Bir Fırsat Bulunamadı!'></cfsavecontent>
	<cfset hata_mesaj  = message>
	<cfinclude template="../../dsp_hata.cfm">
	<cfexit method="exittemplate">
</cfif>
<cfset cmp = createObject("component","V16.settings.cfc.setupCountry") />
<cfset GET_COUNTRY_1 = cmp.getCountry()>
<cfinclude template="../query/get_opp_currencies.cfm">
<cfinclude template="../query/get_probability_rate.cfm">
<cfinclude template="../query/get_moneys.cfm">
<cfinclude template="../query/get_opportunity_type.cfm">
<cfinclude template="../query/get_opportunity_offers.cfm">
<cfinclude template="../query/get_opp_pluses.cfm">
<cfinclude template="../query/get_rival_preference_reasons.cfm">
<cfquery name="GET_SALE_ADD_OPTION" datasource="#DSN3#">
	SELECT SALES_ADD_OPTION_ID,SALES_ADD_OPTION_NAME FROM SETUP_SALES_ADD_OPTIONS
</cfquery>
<cfset contact_flag = 0>
<cfif len(get_opportunity.partner_id)>
	<cfscript>
		member_id = '#get_opportunity.partner_id#';
		contact_type = "p" ;
		contact_id = '#get_opportunity.partner_id#';
		dsp_account =0;
		contact_flag = 1;
	</cfscript>
<cfelseif len(get_opportunity.consumer_id)>
	<cfscript>
		member_id = '#get_opportunity.consumer_id#';
		contact_id = '#get_opportunity.consumer_id#';
  		contact_type = "c";
  		dsp_account = 0;
		contact_flag = 1;
	</cfscript>	
</cfif>
<cfif contact_flag>
	<cfinclude template="../../objects/query/get_contact_simple.cfm">
	<cfset sector_cat_id = get_contact_simple.sector_cat_id>
	<cfset company_size_cat_id = get_contact_simple.company_size_cat_id>
<cfelse>
	<cfset sector_cat_id = "">
	<cfset company_size_cat_id = "">
</cfif>
<form name="add_subscription_contract" id="add_subscription_contract" method="post" target="blank" action="<cfoutput>#request.self#?fuseaction=sales.list_subscription_contract&event=add&opp_id=#attributes.opp_id#</cfoutput>">
	<cfoutput>
    <cfif Len(get_opportunity.sales_emp_id)>
        <cfquery name="GET_EMP" datasource="#DSN#">
            SELECT EMPLOYEE_NAME, EMPLOYEE_SURNAME, EMPLOYEE_ID FROM EMPLOYEE_POSITIONS WHERE IS_MASTER = 1 AND EMPLOYEE_ID = #get_opportunity.sales_emp_id#
        </cfquery>
        <input type="hidden" name="sales_emp_id" id="sales_emp_id" value="#get_opportunity.sales_emp_id#">
        <input type="hidden" name="sales_emp" id="sales_emp" value="#get_emp.employee_name# #get_emp.employee_surname#">
    </cfif>
    <cfif len(get_opportunity.company_id)>
        <input type="hidden" name="member_type" id="member_type" value="partner">
        <input type="hidden" name="company_id" id="company_id" value="#get_opportunity.company_id#">
        <input type="hidden" name="company_name" id="company_name" value="#get_par_info(get_opportunity.company_id,1,0,0)#">
        <cfquery name="GET_PARTNER" datasource="#DSN#" maxrows="1">
            SELECT COMPANY_PARTNER_NAME, COMPANY_PARTNER_SURNAME, PARTNER_ID FROM COMPANY_PARTNER WHERE COMPANY_ID = #get_opportunity.company_id# ORDER BY PARTNER_ID
        </cfquery>
        <input type="hidden" name="partner_id" id="partner_id" value="#get_partner.partner_id#">
        <input type="hidden" name="member_name" id="member_name" value="#get_partner.company_partner_name# #get_partner.company_partner_surname#">
        <cfquery name="GET_COMP_ADDRESS" datasource="#DSN#">
            SELECT COMPANY_ADDRESS,COMPANY_POSTCODE,SEMT,COUNTY,CITY,COUNTRY FROM COMPANY WHERE COMPANY_ID = #get_opportunity.company_id#
        </cfquery>
        <input type="hidden" name="address" id="address" value="#get_comp_address.company_address#">
        <input type="hidden" name="postcode" id="postcode" value="#get_comp_address.company_postcode#">
        <input type="hidden" name="semt" id="semt" value="#get_comp_address.semt#">
        <input type="hidden" name="county_id" id="county_id" value="#get_comp_address.county#">
        <input type="hidden" name="city_id" id="city_id" value="#get_comp_address.city#">
        <input type="hidden" name="country_id" id="country_id" value="#get_comp_address.country#">
        <cfif len(get_comp_address.county)>
            <cfquery name="GET_COUNTY" datasource="#DSN#">
                SELECT COUNTY_NAME FROM SETUP_COUNTY WHERE COUNTY_ID = #get_comp_address.county#
            </cfquery>
            <input type="hidden" name="county" id="county" value="#get_county.county_name#">
        </cfif>
        <cfif len(get_comp_address.city)>
            <cfquery name="GET_CITY" datasource="#DSN#">
                SELECT CITY_NAME FROM SETUP_CITY WHERE CITY_ID = #get_comp_address.city#		
            </cfquery>
            <input type="hidden" name="city" id="city" value="#get_city.city_name#">
        </cfif>
        <cfif len(get_comp_address.country)>
            <cfquery name="GET_COUNTRY" datasource="#DSN#">
                SELECT COUNTRY_NAME FROM SETUP_COUNTRY WHERE COUNTRY_ID = #get_comp_address.country#
            </cfquery>
            <input type="hidden" name="country" id="country" value="#get_country.country_name#">
        </cfif>
    <cfelseif len(get_opportunity.consumer_id)>
        <input type="hidden" name="member_type" id="member_type" value="consumer">
        <input type="hidden" name="consumer_id" id="consumer_id" value="#get_opportunity.consumer_id#">
        <input type="hidden" name="member_name" id="member_name" value="#get_cons_info(get_opportunity.consumer_id,0,0,0)#">
      
        <cfquery name="GET_CON_ADDRESS" datasource="#DSN#">
            SELECT WORKADDRESS, WORKPOSTCODE,WORKSEMT,WORK_COUNTY_ID,WORK_CITY_ID,WORK_COUNTRY_ID FROM CONSUMER WHERE CONSUMER_ID = #get_opportunity.consumer_id#
        </cfquery>
        <input type="hidden" name="address" id="address" value="#get_con_address.workaddress#">
        <input type="hidden" name="postcode" id="postcode" value="#get_con_address.workpostcode#">
        <input type="hidden" name="semt" id="semt" value="#get_con_address.worksemt#">
        <input type="hidden" name="county_id" id="county_id" value="#get_con_address.work_county_id#">
        <input type="hidden" name="city_id" id="city_id" value="#get_con_address.work_city_id#">
        <input type="hidden" name="country_id" id="country_id" value="#get_con_address.work_country_id#">
        
        <cfif len(get_con_address.work_county_id)>
            <cfquery name="GET_COUNTY" datasource="#DSN#">
                SELECT COUNTY_NAME FROM SETUP_COUNTY WHERE COUNTY_ID = #get_con_address.work_county_id#
            </cfquery>
            <input type="hidden" name="county" id="county" value="<cfoutput>#get_county.county_name#</cfoutput>">
        </cfif>
        <cfif len(get_con_address.work_city_id)>
            <cfquery name="GET_CITY" datasource="#DSN#">
                SELECT CITY_NAME FROM SETUP_CITY WHERE CITY_ID = #get_con_address.work_city_id#		
            </cfquery>
            <input type="hidden" name="city" id="city" value="#get_city.city_name#">
        </cfif>
        <cfif len(get_con_address.work_country_id)>
            <cfquery name="GET_COUNTRY" datasource="#DSN#">
                SELECT COUNTRY_NAME FROM SETUP_COUNTRY WHERE COUNTRY_ID = #get_con_address.work_country_id#	
            </cfquery>
            <input type="hidden" name="country" id="country" value="#get_country.country_name#">
        </cfif>
    </cfif>
    </cfoutput> 
</form>

<cfset pageHead = "#getlang('main',200)#: #get_opportunity.opp_no#">
<cf_catalystHeader>
<cfinclude template="../display/detail_opportunity.cfm">
<script type="text/javascript">
	function kontrol()
	{
        if(!chk_process_cat('upd_opp')) return false;
		if (document.upd_opp.member_id.value == '')
		{
			alert ("<cf_get_lang dictionary_id ='41056.Cari Hesap Seçmelisiniz'> !");
			return false;
		}
		if (document.upd_opp.opportunity_type_id[upd_opp.opportunity_type_id.selectedIndex].value == '')
		{
			alert ("<cf_get_lang dictionary_id='58947.Kategori Seçmelisiniz'>!");
			return false;
		}
		if(document.upd_opp.action_date != undefined && document.upd_opp.action_date.value != "")
		{
			if (!date_check(document.upd_opp.opp_date,document.getElementById('action_date'),"Kazanılma Tarihi, Başvuru Tarihinden Önce Olamaz !"))
			return false;
		}
		if(document.getElementById('opp_invoice_date') != undefined && document.getElementById('opp_invoice_date').value != "")
		{
			if (!date_check(document.upd_opp.opp_date,document.upd_opp.opp_invoice_date,"Fatura Tarihi, Başvuru Tarihinden Önce Olamaz !"))
			return false;
		}
		
		return (process_cat_control() && unformat_fields());
	}
	
	function unformat_fields()
	{
		upd_opp.income.value = filterNum(upd_opp.income.value);
		upd_opp.cost.value = filterNum(upd_opp.cost.value);
		return true;
	}
	function addSubscription()
	{
		document.getElementById('add_subscription_contract').submit();	
	}
</script>
