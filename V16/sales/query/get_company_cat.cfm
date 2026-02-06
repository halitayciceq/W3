<!--- get_company_cat.cfm --->
<cfif fuseaction is "member.welcome">
	<cfquery name="GET_COMPANYCAT" datasource="#dsn#">
	SELECT COMPANYCAT_ID, COMPANYCAT FROM COMPANY_CAT 
	</cfquery>
<cfelse>
	<cfquery name="GET_COMPANYCAT" datasource="#dsn#">
	SELECT COMPANYCAT_ID, COMPANYCAT FROM COMPANY_CAT
	</cfquery>
</cfif>
