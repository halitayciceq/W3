<cfsetting showdebugoutput="no"><!--- ajax sayfa oldg. için --->
<cfquery name="GET_COMPARISON" datasource="#DSN3#">
	SELECT
		SCR.PRODUCT_ID AS PRODUCT_ID,
		SCR.PRODUCT_NAME AS PRODUCT_NAME,
		SCR.UNIT AS UNIT,
		0 S_MONTAJ,
		SCR.AMOUNT AS S_PLAN,
		0 S_SIPARIS
	FROM 
		SUBSCRIPTION_CONTRACT_ROW SCR,
		STOCKS S
	WHERE 
		SCR.SUBSCRIPTION_ID = #attributes.subscription_id# AND
		SCR.STOCK_ID = S.STOCK_ID
UNION
	SELECT	
		ORDER_ROW.PRODUCT_ID AS PRODUCT_ID,
		ORDER_ROW.PRODUCT_NAME AS PRODUCT_NAME,
		ORDER_ROW.UNIT AS UNIT,
		0 S_MONTAJ,
		0 S_PLAN,
		ORDER_ROW.QUANTITY AS S_SIPARIS
	FROM
		SUBSCRIPTION_CONTRACT_ORDER,
		ORDERS,
		ORDER_ROW	
	WHERE
		SUBSCRIPTION_CONTRACT_ORDER.SUBSCRIPTION_ID = #attributes.subscription_id# AND
		SUBSCRIPTION_CONTRACT_ORDER.ORDER_ID = ORDERS.ORDER_ID AND
		ORDERS.ORDER_ID = ORDER_ROW.ORDER_ID
UNION
	SELECT 
		DISTINCT 
		SERVICE_OPERATION.PRODUCT_ID AS PRODUCT_ID,
		SERVICE_OPERATION.PRODUCT_NAME AS PRODUCT_NAME,
		SERVICE_OPERATION.UNIT AS UNIT,
		SERVICE_OPERATION.AMOUNT AS S_MONTAJ,
		0 S_PLAN,
		0 S_SIPARIS	
	FROM 
		SERVICE_OPERATION,
		SUBSCRIPTION_CONTRACT_ROW SCR,
		SERVICE
	WHERE 
		SERVICE.SERVICE_ID = SERVICE_OPERATION.SERVICE_ID AND
		SERVICE.SUBSCRIPTION_ID = SCR.SUBSCRIPTION_ID AND
		SCR.SUBSCRIPTION_ID = #attributes.subscription_id#
	ORDER BY
		PRODUCT_NAME
</cfquery>
<cf_flat_list>
	<thead>
          <tr>
            <th><cf_get_lang dictionary_id='57657.Ürün'></th>
            <th width="50"><cf_get_lang dictionary_id='57636.Birim'></th>
            <th width="80" class="text-center"><cf_get_lang dictionary_id='57545.Teklif'></th>
            <th width="80" class="text-center"><cf_get_lang dictionary_id='33340.Kurulum'></th>
            <th width="80" class="text-center"><cf_get_lang dictionary_id='58761.Sevk'></th>
          </tr>
    </thead>
    <tbody>
		<cfif GET_COMPARISON.recordcount>
        <cfoutput query="GET_COMPARISON">
          <tr>
            <td>#product_name#</td>
            <td>#unit#</td>
            <td class="text-center">#S_PLAN#</td>
            <td class="text-center">#S_MONTAJ#</td>
            <td class="text-center">#S_SIPARIS#</td>
          </tr>
        </cfoutput>
        <cfelse>
          <tr>
            <td colspan="6"><cf_get_lang dictionary_id='57484.Kayıt Yok'></td>
          </tr>
        </cfif>
	</tbody>
</cf_flat_list>    
		
