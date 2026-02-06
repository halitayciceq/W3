<cfsetting showdebugoutput="no">
<cfsilent>
	<cfif isdefined("FORM.firstname_parameter")>
		<cfset name_parameter = FORM.firstname_parameter>
	<cfelse>
		<cfset name_parameter = "">
	</cfif>

	<cfquery name="getNames" datasource="workcube_cf_product">
		SELECT 
			EMPLOYEE_ID,
			<cfif caller.database_type is 'MSSQL'>
			EMPLOYEE_NAME + ' ' + EMPLOYEE_SURNAME AS FULLNAME,
			<cfelseif caller.database_type is 'DB2'>
			EMPLOYEE_NAME || ' ' || EMPLOYEE_SURNAME AS FULLNAME,
			</cfif>
			POSITION_CODE,
			IS_MASTER
		FROM 
			EMPLOYEE_POSITIONS 
		WHERE 
			<cfif caller.database_type is 'MSSQL'>
			EMPLOYEE_NAME + ' ' + EMPLOYEE_SURNAME LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#name_parameter#%">
			<cfelseif caller.database_type is 'DB2'>
			EMPLOYEE_NAME || ' ' || EMPLOYEE_SURNAME LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#name_parameter#%">
			</cfif>
		ORDER BY 
			EMPLOYEE_NAME,
			EMPLOYEE_SURNAME,
			IS_MASTER DESC
	</cfquery>
</cfsilent><ul><cfoutput query="getNames"><li>#getNames.PRODUCT_NAME#<cfif is_master neq 1>(<cf_get_lang dictionary_id='32589.EK'>)</cfif></li></cfoutput></ul>
