<cfquery name="GET_OPP_CURRENCIES" datasource="#dsn3#">
	SELECT 
		OPP_CURRENCY_ID,
		CASE
            WHEN LEN(SLI.ITEM) > 0 THEN SLI.ITEM
            ELSE OPP_CURRENCY
        END AS OPP_CURRENCY
	 FROM 
	OPPORTUNITY_CURRENCY 
	  LEFT JOIN #DSN_ALIAS#.SETUP_LANGUAGE_INFO SLI ON SLI.UNIQUE_COLUMN_ID = OPPORTUNITY_CURRENCY.OPP_CURRENCY_ID
        AND SLI.COLUMN_NAME = <cfqueryparam cfsqltype="cf_sql_varchar" value="OPP_CURRENCY">
        AND SLI.TABLE_NAME = <cfqueryparam cfsqltype="cf_sql_varchar" value="OPPORTUNITY_CURRENCY">
        AND SLI.LANGUAGE = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.ep.language#">
	ORDER BY OPP_CURRENCY
</cfquery>
