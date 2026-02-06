<cfquery name="GET_CONSUMER_NAME" datasource="#dsn#">
	SELECT
		CONSUMER_NAME,
		CONSUMER_SURNAME,
		CONSUMER_ID,
		CONSUMER_EMAIL,
		COMPANY
	FROM
		CONSUMER
	WHERE
	<cfif isDefined("attributes.CONSUMER_ID")>
		CONSUMER_ID = #attributes.CONSUMER_ID#
	<cfelseif isDefined("CONSUMER_ID")>
		CONSUMER_ID = #CONSUMER_ID#
	</cfif>
</cfquery>
