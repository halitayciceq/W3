<cfquery name="GET_CMP" datasource="#dsn#">
	SELECT
		*
	FROM
		COMPANY
	WHERE
		COMPANY_ID = #COMPANY#
</cfquery>
<cfquery name="GET_PARTNER_CMP" datasource="#dsn#">
	SELECT
		*
	FROM
		COMPANY
	WHERE
		COMPANY_ID = #COMPANY#
</cfquery>
