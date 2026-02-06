<cfquery name="GET_CATALOGS" datasource="#DSN3#">
	SELECT
		CATALOG_ID,
		CATALOG_HEAD
	FROM
		CATALOG
	WHERE
		CATALOG_STATUS = 1
	ORDER BY
		CATALOG_HEAD
</cfquery>
