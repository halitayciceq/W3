<cfquery name="GET_ORDER_HISTORY" datasource="#DSN3#">
	SELECT
		*
	FROM
		OFFER_HISTORY 
	WHERE
		OFFER_ID = #attributes.offer_id#
	ORDER BY 
		OFFER_HISTORY_ID
</cfquery>
