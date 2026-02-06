<cfquery name="GET_OFFER_ROWS" datasource="#dsn3#">
	SELECT 
		* 
	FROM 
		OFFER_PRODUCT OP, 
		PRODUCT P, 
		STOCKS S
	WHERE 
		OP.OFFER_ID =  #URL.OFFER_ID# 
	AND 
		P.PRODUCT_ID = S.PRODUCT_ID 
	AND
		S.STOCK_ID = OP.STOCK_ID
</cfquery>
