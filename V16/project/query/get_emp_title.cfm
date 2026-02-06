<cfquery name="GET_EMP_TITLE" datasource="#dsn#">
	SELECT
		*
	FROM
		SETUP_TITLE
	WHERE
		TITLE_ID=#ID#
</cfquery>
