
<!--- File: V16/sales/form/opportunity_order.cfm
Author:Fatma Zehra DERE 
Date: 23.03.2024
Controller: -
Description: Fırsat detay sipariş al ​ --->
<cfset comp    = createObject("component","V16.sales.cfc.order_opportunity") />
<cfset get_opportunity_orders = comp.get_opportunity_orders(opp_id:attributes.opp_id)>
<cf_flat_list>
    <tbody>
		<cfif get_opportunity_orders.recordcount>
			<cfoutput query="get_opportunity_orders">
                <tr>
                    <td><a href="#request.self#?fuseaction=sales.list_order&event=upd&order_id=#order_id#" class="tableyazi">#ORDER_NUMBER#-#order_head#</a></td>
                    <td width="20"><a href="javascript://" onClick="upd_order('#order_id#')"><i class="fa fa-minus" title="<cf_get_lang dictionary_id='57463.Sil'>" alt="<cf_get_lang dictionary_id='57463.Sil'>"></i></a></td> 
                </tr>
            </cfoutput>
        <cfelse>
            <tr>
            	<td colspan="2"><cf_get_lang dictionary_id="57484.Kayıt yok">!</td>
            </tr>
        </cfif>
    </tbody>
</cf_flat_list>
<script>
    function upd_order(orderId) {

        $.ajax({
            url: "V16/sales/cfc/order_opportunity.cfc?method=upd_orders_opp",
            method: "post",
            data: { ORDER_ID: orderId }
        });
        refresh_box('opp_order','<cfoutput>#request.self#</cfoutput>?fuseaction=sales.ajax_order_opp&opp_id=<cfoutput>#attributes.opp_id#</cfoutput>','0'); 
    }
</script>
