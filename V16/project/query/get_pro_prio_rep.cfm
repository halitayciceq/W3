<cfquery name="get_pro_prio" datasource="#dsn#">
	SELECT
		COUNT(PP.PROJECT_ID) AS PRO_NUMBER,
		SP.PRIORITY
	FROM
		PRO_PROJECTS PP,
		SETUP_PRIORITY SP
	<!--- 	COMPANY C --->
	WHERE
		(
		PP.SPECTATOR_PAR LIKE '%#session.pp.userid#%'
		OR
		PP.COMPANY_ID LIKE '%#session.pp.company_id#%')
		<!--- AND
		C.COMPANY_ID=#session.pp.company_id#) --->
		AND
		PP.PRO_PRIORITY_ID=SP.PRIORITY_ID
	GROUP BY SP.PRIORITY
</cfquery>
			
