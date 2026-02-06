<cfquery name="GET_SALES_ZONES_NAMES" datasource="#dsn#">
	SELECT
		SZ_ID,
		SZ_NAME
	FROM
		SALES_ZONES
	ORDER BY
		SZ_NAME
</cfquery>
