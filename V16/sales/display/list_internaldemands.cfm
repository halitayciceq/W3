<cfquery name="GET_INTERNALS" datasource="#DSN3#">
	SELECT INTERNAL_ID,SUBJECT FROM INTERNALDEMAND WHERE OFFER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.offer_id#">
</cfquery>
<cfsavecontent variable="text">İç Talepler</cfsavecontent>
<cf_box closable="0" id="get_internaldemands" title="#text#" add_href="#request.self#?fuseaction=purchase.list_internaldemand&event=add&offer_id=#attributes.offer_id#">
<cf_ajax_list>
	<tbody>
		<cfif get_internals.recordcount>
            <tr>
                <td>
                    <cfoutput query="get_internals">
                        <a href="#request.self#?fuseaction=purchase.list_internaldemand&event=upd&id=#internal_id#" class="tableyazi">#subject#</a> <br/>
                    </cfoutput>
                </td>
            </tr>
        <cfelse>
            <tr>
                <td><cf_get_lang_main no="72.Kayıt Bulunamadı!"></td>
            </tr>
        </cfif>
    </tbody>
</cf_ajax_list>
</cf_box>
