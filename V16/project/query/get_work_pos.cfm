<cfquery name="GET_POS" datasource="#DSN#">
	<cfif isdefined('attributes.project_emp_id') and len(attributes.project_emp_id)>
        SELECT
            EMPLOYEE_ID,
            EMPLOYEE_EMAIL
        FROM
            #dsn_alias#.EMPLOYEES
        WHERE
            EMPLOYEE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.project_emp_id#">
   	<cfelseif isdefined('attributes.task_partner_id') and len(attributes.task_partner_id)>
        SELECT
            PARTNER_ID,
            COMPANY_PARTNER_EMAIL AS EMPLOYEE_EMAIL
        FROM
            #dsn_alias#.COMPANY_PARTNER
        WHERE
            PARTNER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.task_partner_id#">
    </cfif>
</cfquery>

