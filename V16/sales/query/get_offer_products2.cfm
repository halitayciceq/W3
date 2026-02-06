<cfquery name="GET_OFFER_PRODUCTS" datasource="#dsn3#">
	SELECT
		QUANTITY,
		UNIT,
		PRODUCT_NAME,
		DESCRIPTION,
		TAX,
		PRICE,
		NET_MALIYET,
		MARJ
	FROM 
		OFFER_ROW
	WHERE
		OFFER_ID = #attributes.OFFER_ID#
</cfquery>
