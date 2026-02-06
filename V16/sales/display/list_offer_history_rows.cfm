<!--- popup_list_sales_offer_rows --->
<cfinclude template="../query/get_his_off_rows.cfm">

<cfset stock_id_list = ''>
<cfset stock_id_count = ''>
<cfoutput query="get_offer_rows">
	<cfif not listfindnocase(stock_id_list,stock_id)>
		<cfset stock_id_list = listappend(stock_id_list,stock_id)>
		<cfset stock_id_count = listappend(stock_id_count,1)>
	<cfelse>
		<cfset sira_ = listfindnocase(stock_id_list,stock_id)>
		<cfset sayi_ = listgetat(stock_id_count,sira_) + 1>
		<cfset stock_id_count = listsetat(stock_id_count,sira_,sayi_)>
	</cfif>
</cfoutput>

<table width="98%" align="center" cellpadding="0" cellspacing="0" border="0">
	<tr class="color-border">
		<td>
		<table width="100%" cellpadding="2" cellspacing="1">
			<tr class="color-header" height="20"> 
				<td class="form-title"><cf_get_lang_main no='245.Ürün'></td>
				<td class="form-title"><cf_get_lang no ='521.İlk Miktar'></td>
				<td class="form-title"><cf_get_lang no ='522.Son Miktar'></td>		  
				<td class="form-title"><cf_get_lang no ='523.İlk Fiyat'> <cfoutput>#session.ep.money#</cfoutput></td>		  
				<td class="form-title"><cf_get_lang no ='524.Son Fiyat '> <cfoutput>#session.ep.money#</cfoutput></td>
				<td class="form-title"><cf_get_lang no ='525.İlk Fiyat Döviz'></td>					  
				<td class="form-title"><cf_get_lang no ='526.Son Fiyat Döviz'></td>
				<td class="form-title">% <cf_get_lang_main no ='604.Değişim'></td>
			</tr>
			<cfif get_offer_rows.recordcount>
				<cfoutput query="get_offer_rows">
					<cfif currentrow eq 1 or stock_id neq get_offer_rows.stock_id[currentrow-1]>
					<cfset stock_count_ = listgetat(stock_id_count,listfindnocase(stock_id_list,stock_id))>
					<tr height="20" onMouseOver="this.className='color-light';" onMouseOut="this.className='color-row';" class="color-row">
						<td>#product_name# #property#</td>
						<td>#quantity# #unit#</td>
						<td><cfif stock_count_ gt 1>#get_offer_rows.quantity[currentrow+stock_count_-1]# #get_offer_rows.unit[currentrow+stock_count_-1]#</cfif></td>
						<td align="right" style="text-align:right;">#TLFormat(price)# #session.ep.money#</td>
						<td align="right" style="text-align:right;"><cfif stock_count_ gt 1>#TLFormat(get_offer_rows.price[currentrow+stock_count_-1])# #session.ep.money#</cfif></td>
						<td align="right" style="text-align:right;">#TLFormat(price_other)# #other_money#</td>
						<td align="right" style="text-align:right;"><cfif stock_count_ gt 1>#TLFormat(get_offer_rows.price_other[currentrow+stock_count_-1])# #get_offer_rows.other_money[currentrow+stock_count_-1]#</cfif></td>
						<td align="right" style="text-align:right;"><cfif stock_count_ gt 1>% #(get_offer_rows.quantity[currentrow+stock_count_-1]*100)/quantity#</cfif></td>
					</tr>
					</cfif>
				</cfoutput> 
			<cfelse>
				<tr class="color-row"> 
					<td colspan="10"><cf_get_lang_main no='72.Kayıt Bulunamadı'>!</td>
				</tr>
			</cfif>
		</table>
		</td>
	</tr>
</table>
<br/>
