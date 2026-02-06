<cfquery name="GET_SECTOR_CAT" datasource="#dsn#">
	SELECT
		*
	FROM
		SETUP_SECTOR_CATS
	WHERE
		SECTOR_CAT_ID = #SECTOR_CAT_ID#
</cfquery>
