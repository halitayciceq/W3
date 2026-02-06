<cfquery name="GET_MONEYS" datasource="#DSN#">
	SELECT
		MONEY_ID,
		MONEY
	FROM
		SETUP_MONEY
	WHERE
		PERIOD_ID = #SESSION.EP.PERIOD_ID#
</cfquery>
