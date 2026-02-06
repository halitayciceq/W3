<cfquery name="GET_SUBSCRIPTION_PRICE" datasource="#DSN3#">
	SELECT
		NETTOTAL,
		OTHER_MONEY,
		OTHER_MONEY_VALUE
	FROM
		SUBSCRIPTION_CONTRACT
	WHERE
		SUBSCRIPTION_ID = #attributes.subscription_id#
</cfquery>
<cfquery name="GET_ORDER_PRICE" datasource="#DSN3#">
	SELECT
		ORDERS.ORDER_ID,
		ORDERS.ORDER_NUMBER,
		ORDERS.NETTOTAL,
		ORDERS.OTHER_MONEY,
		ORDERS.OTHER_MONEY_VALUE
	FROM
		SUBSCRIPTION_CONTRACT_ORDER,
		ORDERS
	WHERE
		SUBSCRIPTION_CONTRACT_ORDER.SUBSCRIPTION_ID = #attributes.subscription_id# AND
		SUBSCRIPTION_CONTRACT_ORDER.ORDER_ID = ORDERS.ORDER_ID
	ORDER BY
		ORDERS.ORDER_ID ASC
</cfquery>
<table>
	<tr height="20" class="txtbold">
		<cfoutput>
		<td width="300"><cf_get_lang no='293. Teklif Fiyatı'>: 
		#tlformat(get_subscription_price.other_money_value)# #get_subscription_price.other_money# - #tlformat(get_subscription_price.nettotal)# #session.ep.money#</td>
		</cfoutput>
		<cfset total_nettol=0>
		<cfif get_order_price.recordcount>
			<cfoutput query="get_order_price">
		  	<!--- <tr height="20" onMouseOver="this.className='color-light';" onMouseOut="this.className='color-row';" class="color-row">
			<td>#currentrow# - Siparis No: #order_number#</td>
			<td align="right">#tlformat(get_order_price.other_money_value)# #get_order_price.other_money#</td>
			<td align="right"><cfif len(get_order_price.nettotal)>#tlformat(get_order_price.nettotal)# #session.ep.money#</cfif></td>
			</tr> --->
	  	<cfif len(get_order_price.nettotal)>
			<cfset total_nettol = total_nettol+get_order_price.nettotal>
	  	</cfif>
		</cfoutput>
		<td width="250" class="txtboldblue"><cf_get_lang dictionary_id='60566.Kurulum Sonrası Fiyat'>:
		<cfoutput>#tlformat(total_nettol)# #session.ep.money#</cfoutput></td>
		</cfif>
		<td width="150"><font color="##FF0000"><cf_get_lang_main no='1171.Fark'>: <cfoutput>#tlformat(total_nettol-get_subscription_price.nettotal)# #session.ep.money#</cfoutput></font></td>
	  </tr>	
	</table>

