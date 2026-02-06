<cfquery name="get_related_project" datasource="#dsn#">
	SELECT EVENT_PLAN_ID,EVENT_PLAN_HEAD FROM EVENT_PLAN WHERE EVENT_PLAN_ID IN (SELECT EVENT_PLAN_ID FROM EVENT_PLAN_ROW WHERE EVENT_PLAN_ROW.EVENT_PLAN_ID=EVENT_PLAN.EVENT_PLAN_ID AND PROJECT_ID=#attributes.project_id#)
</cfquery>
<cf_ajax_list>
	<cfif get_related_project.recordcount>
        <cfoutput query="get_related_project">
            <tr>
                <td>#EVENT_PLAN_HEAD#</td>
                <td width="20">
                    <a target="_blank" href="#request.self#?fuseaction=sales.list_visit&event=upd&visit_id=#event_plan_id#"><img src="/images/update_list.gif" alt="<cf_get_lang dictionary_id='57464.Güncelle'>"></a>
                </td>
            </tr>
        </cfoutput>
    <cfelse>
        <cfoutput>
            <tr>
                <td colspan="2"><cf_get_lang dictionary_id='57484.Kayıt Yok'>!</td>
            </tr>
        </cfoutput>		
    </cfif>
</cf_ajax_list>
