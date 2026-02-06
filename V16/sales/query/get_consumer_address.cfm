<cfquery name="GET_CONSUMER_ADDRESS" datasource="#dsn#">
	SELECT
		WORKADDRESS
	FROM
		CONSUMER
	WHERE
		CONSUMER_ID = #CONSUMER_ID#
</cfquery>
