<cfquery name="upd_order_status" datasource="#dsn3#">
	UPDATE
		ORDERS
	SET
		ORDER_CURRENCY = #attributes.ORDER_CURRENCY#
	WHERE
		ORDER_ID = #attributes.ORDER_ID#
</cfquery>

<cfquery name="upd_order_rows_status" datasource="#dsn3#">
	UPDATE
		ORDER_ROW
	SET
		ORDER_ROW_CURRENCY = #attributes.ORDER_CURRENCY#
	WHERE
		ORDER_ID = #attributes.ORDER_ID#
</cfquery>
<cflocation url="#request.self#?fuseaction=sales.list_order" addtoken="No"> 
