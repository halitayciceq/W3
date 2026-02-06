<cfquery name="GET_EMP_ROLE" datasource="#DSN#">
	SELECT 
		SPR.PROJECT_ROLES 
	FROM 
		WORKGROUP_EMP_PAR WEP,
		SETUP_PROJECT_ROLES SPR 
	WHERE 
		COMPANY_ID IS NOT NULL AND
		COMPANY_ID = #attributes.COMPANY_ID# AND 
		POSITION_CODE = #session.ep.position_code# AND
		SPR.PROJECT_ROLES_ID = WEP.ROLE_ID
</cfquery>
