<!---
    File: contract_orders.cfm
    Folder: sales\form
    Author: Gramoni-Mahmut Çifçi mahmut.cifci@gramoni.com
    Date: 2019-11-15 18:37:54 
    Description:
        Sözleşmeler sayfasından ilişkili siparişleri ajax ile listelemek için kullanılır.
    History:
        
    To Do:

--->
<cfif Len(attributes.order_list)>
    <cfquery name="get_orders" datasource="#dsn3#">
        SELECT ORDER_ID, ORDER_NUMBER, PURCHASE_SALES, ORDER_STATUS FROM ORDERS WHERE ORDER_ID IN(#attributes.order_list#)
    </cfquery>
<cfelse>
    <cfset get_orders.recordcount   = 0 />
</cfif>
<cf_ajax_list>
    <tbody>
		<cfif get_orders.recordcount>
			<cfoutput query="get_orders">
                <tr>
                    <td><a href="#request.self#?fuseaction=<cfif PURCHASE_SALES eq 1>sales.list_order&event=upd<cfelseif PURCHASE_SALES eq 0>purchase.list_order&event=upd</cfif>&order_id=#ORDER_ID#" target="_blank" class="tableyazi"><cfif ORDER_STATUS eq 0><font color="FF0000">#ORDER_NUMBER#</font><cfelse>#ORDER_NUMBER#</cfif></a></td>
                </tr>
            </cfoutput>
        <cfelse>
            <tr>
            	<td colspan="2"><cf_get_lang_main no="72.Kayıt yok">!</td>
            </tr>
        </cfif>
    </tbody>
</cf_ajax_list>