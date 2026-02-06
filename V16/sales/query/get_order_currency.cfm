<cfquery name="GET_ORDER_CURRENCY" datasource="#dsn3#">
	SELECT 
		* 
	FROM 
		ORDER_CURRENCY
	WHERE
		ORDER_CURRENCY_ID = #attributes.CURRENCY_ID#
</cfquery>
