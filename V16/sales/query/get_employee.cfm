
<cfquery name="GET_EMPLOYEE" datasource="#DSN#">
 SELECT 
      * 
 FROM 
     EMPLOYEES
 WHERE 
     EMPLOYEE_STATUS = 1
<cfif isDefined("attributes.EMPLOYEE_ID")>
	AND
	EMPLOYEE_ID = #attributes.EMPLOYEE_ID#
</cfif>
</cfquery>
