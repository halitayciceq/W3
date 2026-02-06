<cfif isdefined("attributes.stock_id") and len(attributes.stock_id)>
	<cfquery name='get_stock_reserved_azalan' datasource="#dsn3#">
		SELECT SUM(STOCK_AZALT) AS AZALAN FROM GET_STOCK_RESERVED WHERE STOCK_ID = #attributes.stock_id#
	</cfquery>
	<cfquery name='get_stock_reserved_artan' datasource="#dsn3#">
		SELECT SUM(STOCK_ARTIR) AS ARTAN FROM GET_STOCK_RESERVED WHERE STOCK_ID = #attributes.stock_id#
	</cfquery>
</cfif>
<cfquery name="PRODUCT_TOTAL_STOCK" datasource="#dsn2#">
	SELECT 
		PRODUCT_TOTAL_STOCK 
	FROM 
		GET_PRODUCT_STOCK 
	WHERE 
		<cfif isdefined("attributes.product_id") and len(attributes.product_id)>
		PRODUCT_ID = #attributes.product_id#
		<cfelse>
		PRODUCT_ID IS NULL
		</cfif>
</cfquery>
