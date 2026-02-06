<cfquery name="GET_MOBILCAT" datasource="#dsn#">
	SELECT
		MOBILCAT
	FROM
		SETUP_MOBILCAT
	WHERE
		MOBILCAT_ID = #attributes.MOBILCAT_ID#
</cfquery>
