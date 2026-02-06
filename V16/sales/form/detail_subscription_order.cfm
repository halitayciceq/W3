<cfsetting showdebugoutput="no"><!--- ajax sayfa oldg. için --->
<cfset order_currency_list="Açık,Tedarik,Kapatıldı,-,Üretim,Sevk,Eksik Teslimat,Fazla Teslimat,İptal,Kapatıldı(Manuel)"><!--- siparis asamaları 4. eleman bos --->
<cfquery name="GET_ORDER_ROW" datasource="#DSN3#">
	SELECT
		ORDERS.ORDER_ID,
		ORDERS.ORDER_NUMBER,
		ORDER_ROW.PRODUCT_NAME,
		ORDER_ROW.QUANTITY,
		ORDER_ROW.ORDER_ROW_CURRENCY,
		ORDER_ROW.UNIT,
		ORDERS.ORDER_DATE
	FROM
		ORDERS,
		ORDER_ROW
	WHERE
		ORDERS.SUBSCRIPTION_ID = #attributes.subscription_id# AND
		ORDERS.ORDER_ID = ORDER_ROW.ORDER_ID
	ORDER BY
		ORDERS.ORDER_ID ASC,
		ORDER_ROW.ORDER_ROW_ID ASC 
</cfquery>
<cf_flat_list>
	<thead>
		<tr>
			<th width="70"><cf_get_lang dictionary_id='58211.Siparis No'></th>
			<th width="65"><cf_get_lang dictionary_id='57742.Tarih'></th>
			<th><cf_get_lang dictionary_id='57657.Ürün'></th>
			<th width="70"><cf_get_lang dictionary_id='57635.Miktar'></th>
			<th width="50"><cf_get_lang dictionary_id='57636.Birim'></th>
			<th width="100"><cf_get_lang dictionary_id='57482.Asama'></th>
		</tr>
    </thead>
    <tbody>
		<cfif get_order_row.recordcount>
			<cfoutput query="get_order_row">
				<tr>
					<td><a href="#request.self#?fuseaction=sales.list_order&event=upd&order_id=#order_id#">#order_number#</a></td>
					<td>#dateformat(order_date,dateformat_style)#</td>
					<td>#product_name#</td>
					<td>#TLFormat(quantity)#</td>
					<td>#unit#</td>
					<td><cfif len(order_row_currency)>#ListGetAt(order_currency_list,(order_row_currency*-1),",")#</cfif></td>
				</tr>
			</cfoutput>	
		<cfelse>
		<tr>
			<td colspan="6"><cf_get_lang dictionary_id='57484.Kayıt Yok'></td>
		</tr>
		</cfif>
		<div style="width:570px;">
			<div style="width:300px;" id="show_user_message"></div>
		</div>
   </tbody>
</cf_flat_list>
