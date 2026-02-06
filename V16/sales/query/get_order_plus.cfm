<cfquery name="GET_ORDER_PLUS" datasource="#dsn3#">
	SELECT
		*
	FROM
		ORDER_PLUS
	WHERE
		ORDER_PLUS_ID = #ORDER_PLUS_ID#
</cfquery>
