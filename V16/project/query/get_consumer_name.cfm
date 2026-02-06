<cfquery name="GET_CONSUMER_NAME" datasource="#DSN#">
	SELECT 
		CONSUMER_ID,
		CONSUMER_NAME,
		CONSUMER_SURNAME,
		COMPANY
	FROM 
		CONSUMER
	WHERE 
		CONSUMER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.consumer_id#">
</cfquery>
