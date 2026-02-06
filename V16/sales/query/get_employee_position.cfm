<cfquery name="GET_EMPLOYEE_POSITION" datasource="#dsn#">
	SELECT
		POSITION_CODE
	FROM
		EMPLOYEE_POSITIONS
	WHERE
		EMPLOYEE_ID = #attributes.EMPLOYEE_ID#
		AND
		POSITION_STATUS = 1
</cfquery>
