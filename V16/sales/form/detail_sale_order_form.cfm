<cfif isnumeric(attributes.order_id)>
    <cfinclude template="../query/get_order_detail.cfm">
<cfelse>
    <cfset get_order_detail.recordcount = 0>
</cfif>
<cfset pageHead = "#getlang('main','Satış Siparişleri',58207)#: #get_order_detail.order_number#">
<cf_catalystHeader>
<cfparam name="attributes.company_id" default="#get_order_detail.company_id#">
<div class="row">
    <div class="col col-9">
        <!---Siparis Karşılama Raporu --->
        <div id="siparis_karsilama_raporu"></div>
        <script>
            AjaxPageLoad("<cfoutput>#request.self#?fuseaction=objects.popup_list_order_receive_rate&order_id=#attributes.order_id#&is_sale=1</cfoutput>",'siparis_karsilama_raporu');
        </script>
        <!---Siparis Stok Raporu --->
        <cfinclude template="../../objects/display/popup_list_order_stock.cfm">
       <!---Siparis Alış Satış Koşulları --->
        <div id="alis_satis_kosullari"></div>
        <script>
            AjaxPageLoad("<cfoutput>#request.self#?fuseaction=objects.popup_list_basket_contract&order_id=#attributes.order_id#&company_id=#get_order_detail.company_id#&consumer_id=#get_order_detail.consumer_id#</cfoutput>",'alis_satis_kosullari');
        </script>
    </div>
    <div class="col col-3">
        <div id="takip"></div>
        <script>
             AjaxPageLoad("<cfoutput>#request.self#?fuseaction=objects.popup_list_pursuits_documents_plus&action_id=#attributes.order_id#&pursuit_type=is_sale_order</cfoutput>",'takip');
        </script>
    </div>
</div>
 