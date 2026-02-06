<!--- get_cmp_partner.cfm --->
<cfquery name="GET_CMP_PARTNER" datasource="#dsn#">
	SELECT 
		* 
	FROM 
		COMPANY_PARTNER
</cfquery>
