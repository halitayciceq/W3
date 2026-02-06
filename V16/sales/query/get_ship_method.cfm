<cfquery name="GET_SHIP_METHOD" datasource="#DSN#">
	SELECT
		SHIP_METHOD
	FROM
		SHIP_METHOD
	WHERE 
		SHIP_METHOD_ID = #attributes.ship_method#	
</cfquery>

