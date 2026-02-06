<cfquery name="GET_OFFER_PLUS" datasource="#dsn3#">
	SELECT
		*
	FROM
		OFFER_PLUS
	WHERE
		OFFER_PLUS_ID = #OFFER_PLUS_ID#
</cfquery>
