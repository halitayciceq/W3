<cffunction name="GET_PROJECT_NAME" returntype="string" output="false">
    <cfargument name="PROJECT_ID" type="numeric" required="true">
	<cfquery name="GET_PROJECT" datasource="#DSN#">
		SELECT 
			PROJECT_HEAD
		FROM 
			PRO_PROJECTS
		WHERE
			PROJECT_ID = #PROJECT_ID#
	</cfquery>
	<cfif GET_PROJECT.RECORDCOUNT>
		<cfset DEGER=GET_PROJECT.PROJECT_HEAD>
	<cfelse>
		<cfset DEGER="">
	</cfif> 
 	<cfreturn #DEGER#>
</cffunction>
