<cfquery name="GET_REL_WORK" datasource="#DSN#">
	SELECT
		WORK_ID,
        WORK_HEAD,
        STARTDATE_PLAN,
        FINISHDATE_PLAN
	FROM
		PRO_WORKS
	WHERE
		WORK_ID IN (#upd_work.related_work_id#)
</cfquery>
