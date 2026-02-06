<cfquery name="GET_ORDER_PLUSES" datasource="#dsn3#">
	SELECT
		*
	FROM
		ORDER_PLUS
	WHERE
		ORDER_ID = #ORDER_ID#
</cfquery>
