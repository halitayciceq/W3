<cfquery name="GET_CONSUMER" datasource="#dsn#">
	SELECT
		*
	FROM
		CONSUMER
	WHERE
		CONSUMER_ID = #CONSUMER_ID#
</cfquery>
