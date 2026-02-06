<cfquery name="GET_PROJECT"	datasource="#DSN#">
	SELECT
		PROJECT_EMP_ID,
		PROJECT_HEAD,
		ISNULL(COMPANY_ID,0) AS COMPANY_ID,
		ISNULL(PARTNER_ID,0) AS PARTNER_ID,
		ISNULL(CONSUMER_ID,0) AS CONSUMER_ID
	FROM 
		PRO_PROJECTS 
	WHERE 
		PRO_PROJECTS.PROJECT_ID = #attributes.from_project_material#
</cfquery>
<cfset attributes.project_head = GET_PROJECT.PROJECT_HEAD>
<cfset attributes.company_id = GET_PROJECT.company_id>
<cfset attributes.consumer_id = GET_PROJECT.consumer_id>
<cfset attributes.partner_id = GET_PROJECT.partner_id>
<cfset attributes.project_id = attributes.from_project_material>


