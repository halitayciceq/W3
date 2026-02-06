<cfquery name="get_cashes" datasource="#dsn2#">
	SELECT 
		CASH_ID,
		CASH_NAME,
		CASH_ACC_CODE,
		CASH_CODE,
		BRANCH_ID,		
		CASH_CURRENCY_ID,		
		CASH_EMP_ID
	FROM
		CASH
	WHERE
		CASH_ACC_CODE IS NOT NULL 
		<cfif isdefined("cash_status")>
			AND CASH_STATUS = 1
		</cfif>
		<cfif session.ep.isBranchAuthorization>
			AND CASH.BRANCH_ID IN(SELECT EMPLOYEE_POSITION_BRANCHES.BRANCH_ID FROM #dsn_alias#.EMPLOYEE_POSITION_BRANCHES EMPLOYEE_POSITION_BRANCHES WHERE EMPLOYEE_POSITION_BRANCHES.POSITION_CODE = #session.ep.position_code#)
		</cfif>
		<cfif isdefined("system_money_info")>
			AND CASH.CASH_CURRENCY_ID = '#session.ep.money#'
		</cfif>
	ORDER BY 
		CASH_NAME
</cfquery>

