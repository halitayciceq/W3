<cfquery name="GET_CREDIT_limit" datasource="#dsn#">
	SELECT 	
		COMPANY_CREDIT.TOTAL_RISK_LIMIT
	FROM 
		COMPANY_CREDIT
	WHERE 
		COMPANY_CREDIT.COMPANY_ID=#attributes.company_id#
</cfquery>
