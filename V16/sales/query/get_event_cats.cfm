<cfquery name="GET_EVENT_CATS" datasource="#dsn#">
	SELECT 
		* 
	FROM 
		EVENT_CAT
	ORDER BY
		EVENTCAT
</cfquery>
