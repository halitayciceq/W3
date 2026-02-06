<cfquery name="GET_WORK_CON" datasource="#dsn#">
	SELECT
		*
	FROM
		CONSUMER
	WHERE
		CONSUMER_ID=#CONSUMER_ID#
</cfquery>
