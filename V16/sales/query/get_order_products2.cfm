<cfquery name="GET_ORDER_PRODUCTS" datasource="#dsn3#">
	SELECT
		QUANTITY,
		UNIT,
		PRODUCT_NAME,
		DESCRIPTION,
		TAX,
		PRICE
	FROM 
		ORDER_ROW
	WHERE
		ORDER_ID = #attributes.ORDER_ID#
</cfquery>
