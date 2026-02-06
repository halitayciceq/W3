<cfquery name="GET_GROUP_NAME" datasource="#DSN#">
	SELECT
		GROUP_NAME
	FROM
		USERS
	WHERE
		GROUP_ID = #attributes.GROUP_ID#
</cfquery>
