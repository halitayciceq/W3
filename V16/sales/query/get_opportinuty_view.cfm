<cfquery name="GET_OPPORTUNITY_VIEW" datasource="#DSN3#">
	SELECT
		*
	FROM
		OPPORTUNITY_VIEW
	WHERE
		OPP_ID = #attributes.opp_id# AND
		EMPLOYEE_ID = #session.ep.userid#
</cfquery>
