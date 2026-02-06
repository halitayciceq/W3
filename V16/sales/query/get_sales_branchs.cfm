<cfquery name="get_sales_branchs" datasource="#DSN#">
	SELECT
		BRANCH_NAME,
		BRANCH_ID
	FROM
		BRANCH
	WHERE		
		BRANCH_ID IN 
		(
		SELECT
			BRANCH_ID
		FROM
			EMPLOYEE_POSITION_BRANCHES
		WHERE
			POSITION_CODE = #session.ep.position_code#
		)
	ORDER BY
		BRANCH_NAME
</cfquery>

