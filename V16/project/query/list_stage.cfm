<cfsetting showdebugoutput="no">
<cfif not isdefined("attributes.type")><cfset attributes.type = 0></cfif>
<cfif len(attributes.category_id)>
	<cfquery name="process" datasource="#DSN#">
		SELECT PROCESS_ID FROM PRO_WORK_CAT WHERE WORK_CAT_ID=#attributes.category_id#
	</cfquery>
	<cfset process_id_list = valuelist(process.PROCESS_ID,',')>
<cfelse>
	<cfset process_id_list = 0>
</cfif>
<cfif isdefined("attributes.value") and len(attributes.value) and listfind(process_id_list,attributes.value,',')>
	<cf_workcube_process is_upd='0' is_detail="1" fusepath="project.addwork" extra_process_row_id="#process_id_list#" select_value="#attributes.value#" process_cat_width='130' onclick_function='tmplt(1)'>
<cfelse>
	<cf_workcube_process is_upd='0' is_detail="0" fusepath="project.addwork" extra_process_row_id="#process_id_list#" process_cat_width='120' onclick_function='tmplt(1)'>
</cfif>
<cfif attributes.type neq 2>
	<script language="javascript">
		tmplt(1);
	</script>
</cfif>


