<cfinclude template="../query/get_opportunity.cfm">
<cfif len(GET_OPPORTUNITY.SERVICE_ID)>
	<cfquery name="GET_SERVICE" datasource="#dsn#">
		SELECT SERVICE_ID,SERVICE_NO FROM G_SERVICE WHERE SERVICE_ID = #get_opportunity.service_id#
	</cfquery>
<cfelse>
	<cfset get_service.recordcount = 0>
</cfif>
<cf_ajax_list>
    <tbody>
		<cfif get_service.recordcount>
			<cfoutput query="get_service">
                <tr>
                    <td><a href="#request.self#?fuseaction=call.list_service&event=upd&service_id=#service_id#" class="tableyazi">#SERVICE_NO#</a></td>
                <tr>
            </cfoutput>
        <cfelse>
            <tr>
           		<td><cf_get_lang_main no="72.Kayıt yok">!</td>
            </tr>
        </cfif>
    </tbody>
</cf_ajax_list>
