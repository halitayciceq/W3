<cfquery name="RELATED_PROJECTS" datasource="#dsn#">
	SELECT 
		PROJECT_HEAD,
		PROJECT_ID
	FROM 
		PRO_PROJECTS 
	WHERE 
		RELATED_PROJECT_ID = #URL.ID#
</cfquery>
<table cellspacing="1" cellpadding="2" width="98%" border="0" class="color-border">
	<tr class="color-header" height="22">
		<td colspan="2" class="form-title"><cf_get_lang dictionary_id='38303.ilişkili proje'></td>
	</tr>
	<cfif RELATED_PROJECTS.recordcount>
		<cfoutput query="RELATED_PROJECTS">
			<tr class="color-row" height="20">
				<td class="label" width="230">
					<a href="#request.self#?fuseaction=project.projects&event=det&id=#RELATED_PROJECTS.PROJECT_ID#" class="tableyazi">#PROJECT_HEAD#</a>
					<td width="1"><a href="#request.self#?fuseaction=project.projects&event=upd&id=#RELATED_PROJECTS.PROJECT_ID#"> <img src="images\update_list.gif" border="0"></a></td>
				</td>
			</tr>
		</cfoutput>
	<cfelse>
		<tr class="color-row">
			<td colspan="2" height="22"><cf_get_lang dictionary_id='57484.Kayıt Yok'> !</td>
		</tr>		
	</cfif>
</table>
