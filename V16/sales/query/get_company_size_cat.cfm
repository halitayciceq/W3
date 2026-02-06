<cfquery name="GET_COMPANY_SIZE_CAT" datasource="#dsn#">
	SELECT
		*
	FROM
		SETUP_COMPANY_SIZE_CATS
	WHERE
		COMPANY_SIZE_CAT_ID = #COMPANY_SIZE_CAT_ID#
</cfquery>
