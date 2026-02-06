<cfquery name="PROJECT_DETAIL" datasource="#DSN#">
	SELECT 
		PRO_PROJECTS.*,
		SETUP_PRIORITY.PRIORITY,
		(
			(
				SELECT
					SUM(ISNULL(TO_COMPLETE,0))
				FROM
					PRO_WORKS PW
				WHERE
					PW.PROJECT_ID = PRO_PROJECTS.PROJECT_ID
			)/
			(
				SELECT
					COUNT(WORK_ID)
				FROM
					PRO_WORKS PW2
				WHERE
					PW2.PROJECT_ID = PRO_PROJECTS.PROJECT_ID
			)
		) COMPLETE_RATE
	FROM 
		PRO_PROJECTS,		
		SETUP_PRIORITY
	WHERE
		<cfif isdefined("attributes.id")>
		PRO_PROJECTS.PROJECT_ID = #attributes.id# AND
		</cfif> 		
		PRO_PROJECTS.PRO_PRIORITY_ID = SETUP_PRIORITY.PRIORITY_ID 
</cfquery>
