<cfquery name="get_work_prio" datasource="#dsn#">
	SELECT
		COUNT(PW.WORK_ID) AS WORK_NUMBER,
		SP.PRIORITY
	FROM
		PRO_WORKS PW,
		SETUP_PRIORITY SP,
		COMPANY C
	WHERE
		PW.OUTSRC_CMP_ID=C.COMPANY_ID
		AND
		C.COMPANY_ID=#session.pp.company_id#
		AND
		PW.WORK_PRIORITY_ID=SP.PRIORITY_ID
	GROUP BY SP.PRIORITY
</cfquery>
