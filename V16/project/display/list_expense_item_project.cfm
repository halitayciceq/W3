<!---  http://testep.workcube/index.cfm?fuseaction=project.popup_pro_time_cost&ID=2 
Bu Sayfanin include i olacak...
Fatura tablosundan expense alani cikarildi...arzu bt bu sayfaya gerek yok simdilik hata verir cunku.
 --->
<cfquery name="GET_RELATIONAL_INVOICE" datasource="#dsn2#">
	SELECT 
		EXPENSE_ITEM_PLANS.PAPER_NO,
		EXPENSE_ITEM_PLANS.EXPENSE_DATE,
		SUM(EXPENSE_ITEMS_ROWS.TOTAL_AMOUNT) AS TOTAL,
		EXPENSE_ITEM_PLANS.CH_CONSUMER_ID,
		EXPENSE_ITEM_PLANS.CH_PARTNER_ID,
		EXPENSE_ITEM_PLANS.CH_COMPANY_ID
	FROM 
		EXPENSE_ITEM_PLANS,
		EXPENSE_ITEMS_ROWS
	WHERE
		EXPENSE_ITEM_PLANS.EXPENSE_ID = EXPENSE_ITEMS_ROWS.EXPENSE_ID AND
		EXPENSE_ITEMS_ROWS.PROJECT_ID = #attributes.ID#
	GROUP BY
		EXPENSE_ITEM_PLANS.PAPER_NO,
		EXPENSE_ITEM_PLANS.EXPENSE_DATE,
		EXPENSE_ITEM_PLANS.CH_CONSUMER_ID,
		EXPENSE_ITEM_PLANS.CH_PARTNER_ID,
		EXPENSE_ITEM_PLANS.CH_COMPANY_ID
</cfquery>
<table cellspacing="1" cellpadding="2" width="98%" align="center" border="0" class="color-border">
	<tr class="color-header">
	  <td  colspan="7" height="22" class="form-title"><cf_get_lang dictionary_id ='38351.Masraflar'></td>
	</tr>
	<tr class="color-list" height="20">
	  <td width="25" class="txtboldblue"><cf_get_lang dictionary_id='57487.No'></td>
	  <td width="70" class="txtboldblue" ><cf_get_lang dictionary_id='57880.Belge No'></td>
	  <td class="txtboldblue"><cf_get_lang dictionary_id='57519.Cari Hesap'></td>
	  <td width="55" class="txtboldblue"><cf_get_lang dictionary_id='57742.Tarih'></td>
	  <td width="100" align="right" class="txtboldblue" style="text-align:right;"><cf_get_lang dictionary_id='57673.Tutar'></td>
	</tr>
	<cfif get_relational_invoice.recordcount>
	  <cfoutput query="get_relational_invoice">
		<tr height="20" onMouseOver="this.className='color-light';" onMouseOut="this.className='color-row';" class="color-row">
		  <td>#currentrow#</td>
		  <td>#paper_no#</td>
		  <td>
			<cfif len(CH_CONSUMER_ID)>
			  #GET_CONS_INFO(CH_CONSUMER_ID,1,1)#
			  <cfelseif len(CH_COMPANY_ID)>
			  #GET_PAR_INFO(CH_PARTNER_ID,0,1,1)#
			</cfif>
		  </td>
		  <td>#dateformat(expense_date,dateformat_style)#</td>
		  <td align="right" style="text-align:right;">#TLFormat(TOTAL)# #SESSION.EP.MONEY#</td>
		</tr>
	  </cfoutput>
	  <cfelse>
	  <tr class="color-row">
		<td colspan="5" height="20"><cf_get_lang dictionary_id='57484.Kayıtlı Bulunamadı'> !</td>
	  </tr>
	</cfif>
</table>

