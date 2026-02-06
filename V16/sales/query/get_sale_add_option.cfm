<cfquery name="GET_SALE_ADD_OPTION" datasource="#DSN3#">
	SELECT
		CASE
			WHEN LEN(SLI.ITEM) > 0 THEN SLI.ITEM
			ELSE SALES_ADD_OPTION_NAME
		END AS SALES_ADD_OPTION_NAME,
		SALES_ADD_OPTION_ID
	FROM
		SETUP_SALES_ADD_OPTIONS
		LEFT JOIN #DSN#.SETUP_LANGUAGE_INFO SLI ON SLI.UNIQUE_COLUMN_ID = SETUP_SALES_ADD_OPTIONS.SALES_ADD_OPTION_ID
		AND SLI.COLUMN_NAME = <cfqueryparam cfsqltype="cf_sql_varchar" value="SALES_ADD_OPTION_NAME">
		AND SLI.TABLE_NAME = <cfqueryparam cfsqltype="cf_sql_varchar" value="SETUP_SALES_ADD_OPTIONS">
		AND SLI.LANGUAGE = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.ep.language#">
	ORDER BY
		SALES_ADD_OPTION_NAME
</cfquery>
