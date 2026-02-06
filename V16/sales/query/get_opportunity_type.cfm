<cfquery name="GET_OPPORTUNITY_TYPE" datasource="#DSN3#">
	SELECT
		OPPORTUNITY_TYPE_ID,
		CASE
            WHEN LEN(SLI.ITEM) > 0 THEN SLI.ITEM
            ELSE OPPORTUNITY_TYPE
        END AS OPPORTUNITY_TYPE
	FROM
		SETUP_OPPORTUNITY_TYPE
		LEFT JOIN #DSN_ALIAS#.SETUP_LANGUAGE_INFO SLI ON SLI.UNIQUE_COLUMN_ID = SETUP_OPPORTUNITY_TYPE.OPPORTUNITY_TYPE_ID
        AND SLI.COLUMN_NAME = <cfqueryparam cfsqltype="cf_sql_varchar" value="OPPORTUNITY_TYPE">
        AND SLI.TABLE_NAME = <cfqueryparam cfsqltype="cf_sql_varchar" value="SETUP_OPPORTUNITY_TYPE">
        AND SLI.LANGUAGE = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.ep.language#">
	ORDER BY
		OPPORTUNITY_TYPE
</cfquery>
