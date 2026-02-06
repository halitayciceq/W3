<cfquery name="GET_ORDER_SALE" datasource="#DSN3#">
	SELECT 
		* 
	FROM 
		ORDERS 
	WHERE 
		PROJECT_ID=#attributes.ID# 
		AND 
		(
			(ORDERS.PURCHASE_SALES= 1 AND ORDERS.ORDER_ZONE = 0)
			OR 
			(ORDERS.PURCHASE_SALES = 0 AND ORDERS.ORDER_ZONE= 1)
		)
</cfquery>
<table cellSpacing="0" cellpadding="0" width="98%" border="0" align="center">
  <tr class="color-border">
    <td>
      <table cellspacing="1" cellpadding="2" width="100%" border="0">
        <tr class="color-header">
          <td  colspan="6" height="22" class="form-title"><cf_get_lang dictionary_id='58207.Satış Siparişleri'></td>
        </tr>
        <tr class="color-list" height="22">
          <td width="25"  class="txtboldblue"><cf_get_lang dictionary_id='57487.No'></td>
          <td class="txtboldblue" width="70"><cf_get_lang dictionary_id='57880.Belge No'></td>
          <td class="txtboldblue"><cf_get_lang dictionary_id='57519.cari hesap'></td>
          <td width="55" class="txtboldblue"><cf_get_lang dictionary_id='57742.Tarih'></td>
          <td width="100" align="right" class="txtboldblue" style="text-align:right;"><cf_get_lang dictionary_id='57673.Tutar'></td>
        </tr>
        <cfif not GET_ORDER_SALE.RecordCount>
          <tr class="color-row">
            <td colspan="7" height="20"> <cf_get_lang dictionary_id='57484.Kayıt Yok'>!</td>
          </tr>
          <cfelse>
          <cfoutput QUERY="GET_ORDER_SALE">
            <tr class="color-row">
			  <td>#currentrow#</td>
			  <td>#ORDER_NUMBER#</td>
              <td>
                <cfif len(CONSUMER_ID)>
                  #GET_CONS_INFO(CONSUMER_ID,1,1)#
                  <cfelseif len(COMPANY_ID) and len(PARTNER_ID)>
                  #GET_PAR_INFO(PARTNER_ID,0,1,1)#
                </cfif>
              </td>
              <td>#dateformat(DELIVERDATE,dateformat_style)#</td>
              <td align="right" style="text-align:right;">#TLFormat(NETTOTAL)# #SESSION.EP.MONEY#</td>
            </tr>
          </cfoutput>
        </cfif>
      </table>
    </td>
  </tr>
</table>
