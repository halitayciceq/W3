<cfquery name="GET_OFFER_PLUSES" datasource="#dsn3#">
	SELECT
		*
	FROM
		OFFER_PLUS
	WHERE
		OFFER_ID = #OFFER_ID#
</cfquery>
