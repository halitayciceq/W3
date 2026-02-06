<cf_date tarih="attributes.action_date">
<cf_papers paper_type="pro_material">
<cfset system_paper_no = paper_code & '-' & paper_number>
<cfset system_paper_no_add = paper_number>
<cfset attributes.FIS_NO= system_paper_no>
<cfif not isdefined("is_transaction")>
	<cflock name="#CREATEUUID()#" timeout="20">
		<cftransaction>
			 <cfinclude template="add_project_material_ic.cfm">
		</cftransaction>
	</cflock>
	<script type="text/javascript">
		<cfif not isdefined("attributes.draggable")>location.href = document.referrer;<cfelse>closeBoxDraggable( '<cfoutput>#attributes.modal_id#</cfoutput>');</cfif>
	</script>
<cfelse>
	<cfinclude template="add_project_material_ic.cfm">
</cfif>

