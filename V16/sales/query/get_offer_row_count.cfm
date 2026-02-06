<cfquery name="GET_OFFER_ROW_COUNT" datasource="#dsn3#">
	SELECT
		COUNT(OFFER_ROW_ID) AS TOTAL_ROWS
	FROM
		OFFER_ROW
	WHERE
		OFFER_ID = #attributes.OFFER_ID#
</cfquery>
