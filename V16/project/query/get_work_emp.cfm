<cfquery name="GET_WORK_EMP" datasource="#dsn#">
	SELECT
		*
	FROM
		EMPLOYEES
	WHERE
		EMPLOYEE_ID=#EMPLOYEE_ID#
</cfquery>
