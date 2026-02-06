<cfquery name="GET_PURSUIT_TEMPLATES" datasource="#dsn#">
	SELECT 
	     * 
	FROM 
		TEMPLATE_FORMS
	WHERE
		IS_PURSUIT_TEMPLATE = 1	
	<cfif isDefined("attributes.pursuit_template_id")>		
	AND
		TEMPLATE_ID = #attributes.pursuit_template_id#
	</cfif>			
	ORDER BY 
		TEMPLATE_HEAD	
</cfquery>
