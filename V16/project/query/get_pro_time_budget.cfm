<cfquery name="get_works_budget" datasource="#DSN#">
	SELECT 
		PW.*
	FROM 
		PRO_PROJECTS AS PP, 
		PRO_WORKS AS PW
	WHERE 
		PW.PROJECT_ID = #attributes.ID#
		AND 
		PP.PROJECT_ID = PW.PROJECT_ID 
</cfquery>

