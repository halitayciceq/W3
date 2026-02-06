<cfquery name="GET_PRO_WORKS" datasource="#dsn#">
	SELECT
		WORK_HEAD,
		OUTSRC_PARTNER_ID
	FROM
		PRO_WORKS
	WHERE
		PROJECT_ID=#attributes.ID#
</cfquery>
