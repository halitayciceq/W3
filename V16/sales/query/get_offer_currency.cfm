<cfquery name="GET_OFFER_CURRENCY" datasource="#dsn3#">
	SELECT 
		OFFER_CURRENCY_ID, 
		OFFER_CURRENCY 
	FROM 
		OFFER_CURRENCY
	WHERE
		OFFER_CURRENCY_ID = #attributes.CURRENCY_ID#
</cfquery>
