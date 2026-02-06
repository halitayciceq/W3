<cfquery name="GET_COUNTRY" datasource="#DSN#">
	SELECT
		COUNTRY_ID,
		COUNTRY_NAME
	FROM
		SETUP_COUNTRY
	ORDER BY
		COUNTRY_NAME
</cfquery>
