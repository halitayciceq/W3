<cfquery name="GET_OPPORTUNITY_HEAD" datasource="#dsn3#">
	SELECT
		OPP_HEAD
	FROM
		OPPORTUNITIES
	WHERE
		OPP_ID = #attributes.OPP_ID#
</cfquery>
