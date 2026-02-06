<cfquery name="GET_CATALOG_NAME" datasource="#DSN3#">
	SELECT
		CATALOG_ID,
		CATALOG_HEAD
	FROM
		CATALOG
	WHERE
		CATALOG_ID = #attributes.CATALOG_ID#
</cfquery>
