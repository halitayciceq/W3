<cfset contract_cmp = createObject("component","V16.sales.cfc.subscription_contract")>
<cfif isdefined('company_id')>
    <cfset get_addres = contract_cmp.get_addres_company(company_id:attributes.company_id)>
<cfelseif isdefined('consumer_id')>
    <cfset get_addres = contract_cmp.get_addres_consumer(consumer_id:attributes.consumer_id)>
</cfif>
<cfif get_addres.recordcount>
<cfoutput query="get_addres">
	<cfif is_invoice_address eq 1>
    	<cfif LEN(COUNTY)>
            <cfset get_county_detail = contract_cmp.get_county_detail(COUNTY:COUNTY)>
            <cfset invoice_county_name = get_county_detail.COUNTY_NAME>
        </cfif>
        <cfif LEN(CITY)>
            <cfset get_city_detail = contract_cmp.get_city_detail(CITY:CITY)>
            <cfset invoice_city_name = get_city_detail.CITY_NAME>
        </cfif>
        <cfif len(COUNTRY)>
            <cfset get_country_detail = contract_cmp.get_country_detail(COUNTRY:COUNTRY)>
            <cfset invoice_country_name = get_country_detail.COUNTRY_NAME>
        </cfif>
    </cfif>
</cfoutput>
    <cfif LEN(get_addres.COUNTY)>
        <cfset get_county_detail = contract_cmp.get_county_detail(COUNTY:get_addres.COUNTY)>
    </cfif>
    <cfif LEN(get_addres.CITY)>
        <cfset get_city_detail = contract_cmp.get_city_detail(CITY:get_addres.CITY)>
    </cfif>
    <cfif len(get_addres.COUNTRY)>
        <cfset get_country_detail = contract_cmp.get_country_detail(COUNTRY:get_addres.COUNTRY)>
    </cfif>
</cfif>