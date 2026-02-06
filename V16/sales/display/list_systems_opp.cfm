<cfquery name="get_systems_opp" datasource="#dsn3#">
    SELECT SUBSCRIPTION_ID,SUBSCRIPTION_NO FROM SUBSCRIPTION_CONTRACT WHERE OPP_ID=#attributes.opp_id#
</cfquery>
<cf_ajax_list>
    <tbody>
		<cfif get_systems_opp.recordcount>
				<cfoutput query="get_systems_opp">
                <tr>
                    <td><a href="#request.self#?fuseaction=sales.list_subscription_contract&event=upd&subscription_id=#subscription_id#&opp_id=#attributes.opp_id#" class="tableyazi">#SUBSCRIPTION_NO#</a></td>
                </tr>
            </cfoutput>
        <cfelse>
            <tr>
                <td><cf_get_lang_main no="72.Kayıt yok">!</td>
            </tr>
        </cfif>
    </tbody>
</cf_ajax_list>
