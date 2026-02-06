<!--- get_priority.cfm --->

<cfquery name="GET_PRIORITY" datasource="#dsn#">
	SELECT 
		* 
	FROM 
		SETUP_PRIORITY
</cfquery>
