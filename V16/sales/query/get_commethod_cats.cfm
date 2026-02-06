<cfquery name="GET_COMMETHOD_CATS" datasource="#dsn#">
	SELECT
	CASE
        WHEN LEN(SLI.ITEM) > 0 THEN SLI.ITEM
            ELSE COMMETHOD
        END AS COMMETHOD
		,
		COMMETHOD_ID
	FROM
		SETUP_COMMETHOD
		LEFT JOIN #DSN_ALIAS#.SETUP_LANGUAGE_INFO SLI ON SLI.UNIQUE_COLUMN_ID = SETUP_COMMETHOD.COMMETHOD_ID
        AND SLI.COLUMN_NAME = <cfqueryparam cfsqltype="cf_sql_varchar" value="COMMETHOD">
        AND SLI.TABLE_NAME = <cfqueryparam cfsqltype="cf_sql_varchar" value="SETUP_COMMETHOD">
        AND SLI.LANGUAGE = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.ep.language#">
	ORDER BY
		COMMETHOD
</cfquery>
