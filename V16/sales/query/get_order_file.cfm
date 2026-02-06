<cfquery name="GET_ORDER_FILE" datasource="#dsn3#">
	SELECT 
		* 
	FROM 
		ORDER_FILE
	WHERE 
		ORDER_ID = #URL.order_id#
</cfquery>
