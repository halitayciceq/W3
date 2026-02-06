<cfquery name="GET_CONTRACTS" datasource="#dsn3#">
	SELECT 
		CONTRACT_ID,
		CONTRACT_HEAD 
	FROM 
		CONTRACT
	WHERE 
		(
		STATUS = 0
		OR
		STATUS = 1
		OR
		STATUS = 2
		)
	<cfif isDefined("attributes.COMPANY_ID")>
		AND
		COMPANY LIKE '%,#attributes.COMPANY_ID#,%'
	</cfif>
</cfquery>

