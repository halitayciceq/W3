<cfquery name="GET_WORKGROUPS" datasource="#DSN#"><!---get_work.cfc dosyasına alındı --->
	SELECT 
		WORKGROUP_ID,
		WORKGROUP_NAME
	FROM 
		WORK_GROUP
	WHERE
		<cfif isdefined("attributes.workgroup_id") and len(attributes.workgroup_id)>
			WORKGROUP_ID =<cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.workgroup_id#"> AND
		</cfif>
		STATUS = 1 AND
		HIERARCHY IS NOT NULL
	ORDER BY 
		WORKGROUP_NAME
</cfquery>
