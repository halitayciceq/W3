<cfquery name="GET_PRO_DETAIL" datasource="#dsn#">
	SELECT
		*
	FROM
		PRO_PROJECTS
	WHERE
		PROJECT_ID=#URL.ID#
</cfquery>
<cfoutput query="get_pro_detail">
	<cfset cmp=COMPANY_ID>
	<cfset partner=PARTICIPATOR_PAR>
</cfoutput>
<cfoutput>
<cfloop from="1" to="#URL.row#" index="i">
	<cfif isdefined("chk#i#")>
		<cfset wid=evaluate("work_id#i#")>
		<cfquery name="ADD_WORK_GROUP" datasource="#dsn#">
			UPDATE
				PRO_WORKS
			SET
				PROJECT_ID = #URL.ID#,
				COMPANY_ID = #CMP#,
				COMPANY_PARTNER_ID = #PARTNER#
			WHERE
				WORK_ID = #WID# 
		</cfquery>
	</cfif>
</cfloop>
</cfoutput>
<script type="text/javascript">
	window.opener.opener.location.href="<cfoutput>#request.self#?fuseaction=project.projects&event=det&ID=#URL.ID#</cfoutput>";
	window.close();
	window.opener.close();
</script>




