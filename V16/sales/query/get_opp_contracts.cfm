<cfquery name="GET_OPP_CONTRACTS" datasource="#dsn3#">
	SELECT
		CONTRACT_ID,
		CONTRACT_HEAD,
		STATUS
	FROM
		CONTRACT
	WHERE
		<cfif CONTACT_TYPE IS "P">
			COMPANY_PARTNER LIKE '%#CONTACT_ID#%'
		<cfelseif CONTACT_TYPE IS "C">
			CONSUMERS LIKE '%#CONTACT_ID#%'
		<cfelseif CONTACT_TYPE IS "comp">
			COMPANY LIKE '%#CONTACT_ID#%'
		</cfif>
</cfquery>
