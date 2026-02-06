<cfquery name="get_opp_contrs" datasource="#dsn3#">
	SELECT
		CONTRACT_ID,
		CONTRACT_HEAD,
		STATUS
	FROM
		CONTRACT
	WHERE
		COMPANY LIKE '%,#attributes.COMPANY_ID#,%'
</cfquery>
