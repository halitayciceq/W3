<cfquery name="get_relations" datasource="#dsn#">
	SELECT
		PWR.PRE_ID,
		PWR.WORK_ID
	FROM
		PRO_WORK_RELATIONS PWR,
		PRO_WORKS PW
	WHERE
		PWR.WORK_ID = #attributes.pro_work_id# AND
		PWR.PRE_ID > 0 AND
		PWR.WORK_ID = PW.WORK_ID AND
		PW.PROJECT_ID = #attributes.project_id#
</cfquery>
