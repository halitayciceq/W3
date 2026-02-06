<cfquery name="GET_OPPORTUNITY_OFFERS" datasource="#DSN3#">
	SELECT
		OFFER_ID,
		OFFER_HEAD,
		OFFER_ZONE,
		OFFER_NUMBER,
		OFFER_STATUS
	FROM
		OFFER
	WHERE
		OPP_ID = #attributes.opp_id#
</cfquery>
