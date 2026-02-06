<cfquery name="get_temp" datasource="#dsn#">
	SELECT 
		TF.TEMPLATE_CONTENT
	FROM
		TEMPLATE_FORMS TF,
		<cfif isdefined("attributes.pro_stage") and len(attributes.pro_stage)>
			PRO_WORK_CAT_TEMPLATE PWC
		<cfelse>
			PRO_WORK_CAT PWC
		</cfif>
	WHERE
		TF.TEMPLATE_ID = PWC.TEMPLATE_ID AND
		<cfif isdefined("attributes.pro_stage") and len(attributes.pro_stage)>
			PWC.PRO_WORK_CAT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.pwc#">
			AND PWC.PROCESS_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.pro_stage#">
		<cfelse>
			PWC.WORK_CAT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.pwc#">
		</cfif>
</cfquery>
<cfif len(get_temp.template_content)>
	<cfmodule
		template="/fckeditor/fckeditor.cfm"
		toolbarSet="Basic"
		basePath="/fckeditor/"
		instanceName="work_detail"
		valign="top"
		value="#get_temp.template_content#"
		width="580"
		height="180">
<cfelse>
	<cfmodule
		template="/fckeditor/fckeditor.cfm"
		toolbarSet="Basic"
		basePath="/fckeditor/"
		instanceName="work_detail"
		valign="top"
		value=""
		width="580"
		height="180">
</cfif>
