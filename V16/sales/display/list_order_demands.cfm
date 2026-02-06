<cf_xml_page_edit fuseact ="sales.list_order_demands" default_value="1">
<cfparam name="attributes.product_id" default="">
<cfparam name="attributes.stock_id" default="">
<cfparam name="attributes.product_name" default="">
<cfparam name="attributes.product_pos_id" default="">
<cfparam name="attributes.product_position" default="">
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.start_date" default="">
<cfparam name="attributes.finish_date" default="">
<cfparam name="attributes.demand_type" default="">
<cfparam name="attributes.sales_member_name" default="">
<cfparam name="attributes.company_id" default="">
<cfparam name="attributes.consumer_id" default="">
<cfparam name="attributes.sales_member_type" default="">
<cfparam name="attributes.member_type" default="">
<cfparam name="attributes.status" default="1">
<cfif isdefined("attributes.start_date") and isdate(attributes.start_date)>
	<cf_date tarih="attributes.start_date">
<cfelse>
	<cfparam name="attributes.start_date" default="">
</cfif>
<cfif isdefined("attributes.finish_date") and isdate(attributes.finish_date)>
	<cf_date tarih="attributes.finish_date">
<cfelse>
	<cfparam name="attributes.finish_date" default="">
</cfif>
<cfset adres = url.fuseaction>
<cfset adres = "#adres#&is_submit=1">
<cfset adres = "#adres#&demand_type=#attributes.demand_type#">
<cfif isdefined("attributes.is_submit")>
	<cfquery name="GET_DEMANDS" datasource="#DSN3#">
		SELECT 
			OD.RECORD_PAR,
			OD.RECORD_CON,
			OD.RECORD_DATE,
			OD.DEMAND_ID,
			OD.DEMAND_TYPE,
			OD.DEMAND_STATUS,
			OD.DEMAND_AMOUNT,
			OD.PRICE,
            OD.PRICE_KDV,	
			OD.STOCK_ID,
			OD.ORDER_ID,
            OD.DEMAND_DATE,
            OD.RECORD_DATE,
            OD.PRICE_MONEY,
            COM_PART.NICKNAME,
            COM_PART.MEMBER_CODE,
            COM_PART.COMPANY_PARTNER_NAME,
            COM_PART.COMPANY_PARTNER_SURNAME
		FROM 
			ORDER_DEMANDS OD LEFT JOIN (
                                        SELECT 
                                            C.NICKNAME,
                                            C.MEMBER_CODE,
                                            C.COMPANY_ID,
                                            CP.COMPANY_PARTNER_NAME,
                                            CP.COMPANY_PARTNER_SURNAME,
                                            CP.PARTNER_ID 
                                        FROM 
                                            #DSN_ALIAS#.COMPANY_PARTNER CP,
                                            #DSN_ALIAS#.COMPANY C
                                        WHERE 
                                            C.COMPANY_ID = CP.COMPANY_ID
                                        )
			COM_PART ON OD.RECORD_PAR = COM_PART.PARTNER_ID
		WHERE
			1=1
		<cfif len(attributes.demand_type)>
            AND OD.DEMAND_TYPE = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.demand_type#">
        </cfif>
        <cfif len(attributes.keyword)>
            AND OD.ORDER_ID	IN (SELECT ORDER_ID FROM ORDERS WHERE ORDER_NUMBER LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.keyword#%">)
        </cfif>
        <cfif len(attributes.product_id) and len(attributes.product_name)>
            AND OD.STOCK_ID =<cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.product_id#">
        </cfif>
        <cfif len(attributes.product_pos_id) and len(attributes.product_position)>
            AND OD.STOCK_ID IN (SELECT STOCK_ID FROM STOCKS WHERE PRODUCT_MANAGER = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.product_pos_id#">)
        </cfif>
        <cfif isDefined("attributes.status") and len(attributes.status)>
            AND OD.DEMAND_STATUS = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.status#">
        </cfif>
        <cfif len(attributes.member_type) and (attributes.member_type is 'partner') and len(attributes.company_id) and len(attributes.member_name)>
            AND COM_PART.COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.company_id#">
        </cfif>
        <cfif len(attributes.member_type) and (attributes.member_type is 'consumer') and len(attributes.consumer_id) and len(attributes.member_name)>
            AND OD.RECORD_CON = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.consumer_id#">
        </cfif>
        <cfif isdefined('attributes.start_date') and len(attributes.start_date)>
			AND OD.DEMAND_DATE >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.start_date#">
		</cfif>
		<cfif isdefined('attributes.finish_date') and len(attributes.finish_date)>
			AND OD.DEMAND_DATE <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.finish_date#">
		</cfif>
		ORDER BY 
			OD.RECORD_DATE DESC
	</cfquery>
<cfelse>
	<cfset get_demands.recordcount = 0>
</cfif>

<cfparam name="attributes.page" default=1>
<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>
<cfparam name="attributes.totalrecords" default='#get_demands.recordcount#'>
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
<cfform name="search" action="#request.self#?fuseaction=sales.list_order_demands" method="post">
<input type="hidden" name="is_submit" id="is_submit" value="1">
	<cf_big_list_search title="#getLang('sales',62)#">
		<cf_big_list_search_area>
			<table>
				<tr>
					<input type="hidden" name="product_pos_id" id="product_pos_id" value="<cfif len(attributes.product_pos_id)><cfoutput>#attributes.product_pos_id#</cfoutput></cfif>">
					<td><cf_get_lang_main no='48.Filtre'></td>
					<td><cfinput type="text" name="keyword" style="width:100px;" value="#attributes.keyword#" maxlength="255"></td>
                  
					<td><select name="demand_type" id="demand_type">
							<option value=""><cf_get_lang no='351.Takip Türü'></option>
							<option value="1" <cfif attributes.demand_type eq 1>selected</cfif>><cf_get_lang no ='348.Fiyat Habercisi'></option>
							<option value="2" <cfif attributes.demand_type eq 2>selected</cfif>><cf_get_lang no='349.Stok Habercisi'></option>
							<option value="3" <cfif attributes.demand_type eq 3>selected</cfif>><cf_get_lang no='350.Ön Sipariş'></option>
						</select>
					</td>
					<td><select name="status" id="status">
							<option value=""><cf_get_lang_main no='296.Tümü'></option>
							<option value="0"<cfif isdefined('attributes.status') and (attributes.status eq 0)> selected</cfif>><cf_get_lang_main no='82.Pasif'></option>
							<option value="1"<cfif isdefined('attributes.status') and (attributes.status eq 1)> selected</cfif>><cf_get_lang_main no='81.Aktif'></option>
						</select>
					</td>
					<td><cfsavecontent variable="message"><cf_get_lang_main no='125.Sayi_Hatasi_Mesaj'></cfsavecontent>
						<cfinput type="text" name="maxrows" value="#attributes.maxrows#" required="yes" validate="integer" range="1,999" message="#message#" maxlength="3" style="width:25px;">
					</td>
					<td><cf_wrk_search_button><cf_workcube_file_action pdf='1' mail='1' doc='1' print='1'></td>
				</tr>
			</table> 
		</cf_big_list_search_area>
		<cf_big_list_search_detail_area> 
			<table>	
				<tr>
                   	<td><cf_get_lang_main no='107.Cari Hesap'></td>
					<td style="width:120px;">
						<input type="hidden" name="consumer_id" id="consumer_id" value="<cfif isdefined("attributes.consumer_id")><cfoutput>#attributes.consumer_id#</cfoutput></cfif>">
						<input type="hidden" name="company_id" id="company_id" value="<cfif isdefined("attributes.company_id")><cfoutput>#attributes.company_id#</cfoutput></cfif>">
						<input type="hidden" name="member_type" id="member_type" value="<cfif isdefined("attributes.member_type")><cfoutput>#attributes.member_type#</cfoutput></cfif>">
						<input name="member_name" type="text" id="member_name" style="width:90px;" onfocus="AutoComplete_Create('member_name','MEMBER_NAME,MEMBER_PARTNER_NAME,MEMBER_CODE','MEMBER_NAME,MEMBER_PARTNER_NAME,MEMBER_CODE','get_member_autocomplete','\'1,2\'','CONSUMER_ID,COMPANY_ID,MEMBER_TYPE','consumer_id,company_id,member_type','','3','250');" value="<cfif isdefined("attributes.member_name") and len(attributes.member_name)><cfoutput>#attributes.member_name#</cfoutput></cfif>" autocomplete="off">
						<cfset str_linke_ait="&field_consumer=search.consumer_id&field_comp_id=search.company_id&field_member_name=search.member_name&field_type=search.member_type">
						<a href="javascript://" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_all_pars<cfoutput>#str_linke_ait#<cfif session.ep.isBranchAuthorization>&is_store_module=1</cfif></cfoutput>&select_list=7,8&keyword='+encodeURIComponent(document.search.member_name.value),'list');">
							<img src="/images/plus_thin.gif" align="top">
						</a>
					</td>
					<td><cf_get_lang_main no='245.Urun'></td>
					<td>
						<input type="hidden" name="product_id" id="product_id" <cfif len(attributes.product_id) and len(attributes.product_name)>value="<cfoutput>#attributes.product_id#</cfoutput>"</cfif>>
                        <input type="hidden" name="stock_id" id="stock_id" <cfif len(attributes.stock_id) and len(attributes.product_name)>value="<cfoutput>#attributes.stock_id#</cfoutput>"</cfif>>
						<input name="product_name" type="text" id="product_name" style="width:90px;" onfocus="AutoComplete_Create('product_name','PRODUCT_NAME','PRODUCT_NAME','get_product','0','PRODUCT_ID,STOCK_ID','product_id,stock_id','','3','100');" value="<cfif len(attributes.product_id) and len(attributes.product_name)><cfoutput>#attributes.product_name#</cfoutput></cfif>" autocomplete="off">
						<a href="javascript://" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_product_names&field_id=search.stock_id&product_id=search.product_id&field_name=search.product_name&keyword='+encodeURIComponent(document.search.product_name.value),'list');"><img src="/images/plus_thin.gif" align="top"></a>
					</td>
					<td><cf_get_lang_main no='132.Sorumlu'>
						<cfinput type="text" name="product_position" value="#attributes.product_position#" style="width:120px;" onChange="get_pos();">
						<a href="javascript://" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_positions&field_code=search.product_pos_id&field_name=search.product_position<cfif session.ep.isBranchAuthorization>&is_store_module=1</cfif>&select_list=1&is_form_submitted=1&keyword='+encodeURIComponent(document.search.product_position.value),'list','popup_list_positions');"><img src="/images/plus_thin.gif" align="top"></a>
					</td>
                    <td><cf_get_lang_main no='2246.Takip Tarih'></td>
                    <td>
                        <cfsavecontent variable="message"><cf_get_lang_main no='370.Tarih Değerini Kontrol Ediniz'></cfsavecontent>
                        <cfinput type="text" name="start_date" value="#dateformat(attributes.start_date,dateformat_style)#" validate="#validate_style#" maxlength="10" message="#message#" style="width:65px;">
                        <cf_wrk_date_image date_field="start_date">
                        <cfsavecontent variable="message"><cf_get_lang_main no='370.Tarih Değerini Kontrol Ediniz'></cfsavecontent>
                        <cfinput type="text" name="finish_date" value="#dateformat(attributes.finish_date,dateformat_style)#" validate="#validate_style#" maxlength="10" message="#message#" style="width:65px;">
                        <cf_wrk_date_image date_field="finish_date">
                    </td>
				</tr>
			</table>
		</cf_big_list_search_detail_area>
	</cf_big_list_search>
</cfform>
<cf_big_list>
	<thead>
		<tr>
			<th width="25"><cf_get_lang_main no='75.No'></th>
			<th width="50"><cf_get_lang_main no='146.Üye No'></th>
			<th width="150"><cf_get_lang_main no='45.Müşteri'></th>
			<th><cf_get_lang_main no='245.Ürün'></th>
			<th><cf_get_lang_main no ='1388.Urun Kodu'></th>
			<th style="text-align:right"><cf_get_lang_main no ='670.Adet'></th>
			<th style="text-align:right"><cfif x_show_order_price eq 1><cf_get_lang_main no ='1304.Kdv li'><cfelse><cf_get_lang_main no ='2227.Kdvsiz'></cfif></th>
            <th><cf_get_lang_main no='77.Para Birimi'></th>
			<th><cf_get_lang_main no='799.Sipariş No'></th>
			<th width="70"><cf_get_lang no='351.Takip Türü'></th>
			<th width="65"><cf_get_lang_main no='330.Tarih'></th>
            <th>Kayıt Tarihi</th>
			<th width="40"><cf_get_lang_main no='344.Durum'></th>
			<th class="header_icn_none"><a href="javascript://" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=sales.popup_add_order_demand','page');"><img src="/images/plus_list.gif"></a></th>
		</tr>	
	</thead>
	<tbody>		 
		<cfif get_demands.recordcount>
			<cfset partner_list = ''>
			<cfset consumer_list = ''>
			<cfset stock_list = ''>
			<cfset order_list = ''>
			<cfset product_code=''>
			<cfoutput query="get_demands" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
				<cfif len(record_con) and not listfind(consumer_list,record_con,',')>
					<cfset consumer_list = listappend(consumer_list,record_con)>
				</cfif>
				<cfif len(stock_id) and not listfind(stock_list,stock_id,',')>
					<cfset stock_list = listappend(stock_list,stock_id)>
				</cfif>
				<cfif len(order_id) and not listfind(order_list,order_id,',')>
					<cfset order_list = listappend(order_list,order_id)>
				</cfif>						
			</cfoutput>
			<cfif listlen(consumer_list)>
				<cfset consumer_list=listsort(consumer_list,"numeric","ASC",",")>
				<cfquery name="GET_CONSUMERS" datasource="#DSN#">
					SELECT CONSUMER_NAME,CONSUMER_SURNAME,CONSUMER_ID,MEMBER_CODE FROM CONSUMER WHERE CONSUMER_ID IN (#consumer_list#) ORDER BY CONSUMER_ID
				</cfquery>
				<cfset consumer_list = listsort(listdeleteduplicates(valuelist(get_consumers.consumer_id,',')),'numeric','ASC',',')>
			</cfif>
			<cfif listlen(stock_list)>
				<cfset stock_list=listsort(stock_list,"numeric","ASC",",")>
				<cfquery name="GET_STOCKS" datasource="#DSN3#">
					SELECT S.PRODUCT_NAME,S.PROPERTY,S.STOCK_ID,S.PRODUCT_ID,S.STOCK_CODE,S.PRODUCT_CODE_2,P.TAX FROM STOCKS S INNER JOIN PRODUCT P on P.PRODUCT_ID=S.PRODUCT_ID where STOCK_ID IN (#stock_list#) ORDER BY STOCK_ID
				</cfquery>
				<cfset stock_list = listsort(listdeleteduplicates(valuelist(get_stocks.stock_id,',')),'numeric','ASC',',')>
			</cfif>
			<cfif listlen(order_list)>
				<cfset order_list=listsort(order_list,"numeric","ASC",",")>
				<cfquery name="GET_ORDERS" datasource="#DSN3#">
					SELECT ORDER_NUMBER,ORDER_ID FROM ORDERS WHERE ORDER_ID IN (#order_list#) ORDER BY ORDER_ID
				</cfquery>
				<cfset order_list = listsort(listdeleteduplicates(valuelist(get_orders.order_id,',')),'numeric','ASC',',')>
			</cfif>
			<cfoutput query="get_demands" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#"> 
				<tr>
					<td>#currentrow#</td>
					<td>#member_code#
						<cfif len(record_con)>
							#get_consumers.member_code[listfind(consumer_list,record_con,',')]#
						</cfif>
					</td>
					<td>
						<cfif len(record_par)>
							<a href="javascript://" onclick="windowopen('#request.self#?fuseaction=objects.popup_par_det&par_id=#record_par#','medium');" class="tableyazi">#NICKNAME# - #COMPANY_PARTNER_NAME# #COMPANY_PARTNER_SURNAME#<!--- #get_partners.NICKNAME[listfind(partner_list,record_par,',')]# - #get_partners.COMPANY_PARTNER_NAME[listfind(partner_list,record_par,',')]# #get_partners.COMPANY_PARTNER_SURNAME[listfind(partner_list,record_par,',')]# ---></a>
						</cfif>
						<cfif len(record_con)>
							<a href="javascript://" onclick="windowopen('#request.self#?fuseaction=objects.popup_con_det&con_id=#record_con#','medium');" class="tableyazi">#get_consumers.CONSUMER_NAME[listfind(consumer_list,record_con,',')]# #get_consumers.CONSUMER_SURNAME[listfind(consumer_list,record_con,',')]#</a>
						</cfif>
					</td>
					<td><a href="#request.self#?fuseaction=product.list_product&event=det&pid=#get_stocks.product_id[listfind(stock_list,get_demands.stock_id,',')]#" class="tableyazi">#get_stocks.product_name[listfind(stock_list,get_demands.stock_id,',')]# #get_stocks.property[listfind(stock_list,get_demands.stock_id,',')]#</a></td>
					<td>#get_stocks.STOCK_CODE[listfind(stock_list,get_demands.stock_id,',')]#</td>
					<td align="right" style="text-align:right;">#demand_amount#</td>
					<cfif x_show_order_price eq 1><!-- XML e bağlı olarak Birim Fiyat Üzerindeki KDV li Tutar Hesaplanacak--> 
                        <td align="right" style="text-align:right;">#tlformat(price_kdv)#</td>
                    <cfelse>
                    	<td align="right" style="text-align:right;">#tlformat(price)#</td>
                    </cfif>
                   <td align="left" style="text-align:left;">#price_money#</td>
					<td><cfif len(order_id)>#get_orders.order_number[listfind(order_list,get_demands.order_id,',')]#</cfif></td>
					<td><cfif demand_type eq 1><cf_get_lang no ='348.Fiyat Habercisi'><cfelseif demand_type eq 2><cf_get_lang no='349.Stok Habercisi'><cfelseif demand_type eq 3><cf_get_lang no='350.Ön Sipariş'></cfif></td>
					<td>#dateformat(demand_date,dateformat_style)#</td>
                    <td>#dateformat(record_date,dateformat_style)#</td>
					<td>
						<cfif demand_status eq 1>
							<cf_get_lang_main no='81.Aktif'>
						<cfelse>
							<cf_get_lang_main no='82.Pasif'>
						</cfif>
					</td>
					<!-- sil -->
					<td width="15"><a href="javascript://" onclick="windowopen('#request.self#?fuseaction=sales.popup_upd_order_demand&demand_id=#demand_id#','page');" class="tableyazi"><img src="/images/update_list.gif" title="<cf_get_lang_main no ='52.Güncelle'>"></a></td>
					<!-- sil -->
				</tr>
			</cfoutput> 
			<cfelse>
				<tr class="color-row">
					<td colspan="14" height="20"><cfif isdefined("attributes.is_submit")><cf_get_lang_main no='72.Kayıt Bulunamadı'>!<cfelse><cf_get_lang_main no='289.Filtre Ediniz'>!</cfif></td>
				</tr>
		</cfif>
	</tbody>
</cf_big_list>

<cfif attributes.totalrecords gt attributes.maxrows>
	<table cellpadding="0" cellspacing="0" border="0" width="98%" height="30" align="center">
		<tr> 
			<td>
				<cfif len(attributes.keyword)>
					<cfset adres = '#adres#&keyword=#attributes.keyword#'>
				</cfif>
               <cfif isdate(attributes.start_date)>
					<cfset adres = "#adres#&start_date=#dateformat(attributes.start_date,dateformat_style)#" >
				</cfif>
				<cfif isdate(attributes.finish_date)>
					<cfset adres = "#adres#&finish_date=#dateformat(attributes.finish_date,dateformat_style)#" >
				</cfif>
				<cfif len(attributes.status)>
					<cfset adres = '#adres#&status=#attributes.status#'>
				</cfif>
				<cfif len(attributes.company_id)>
					<cfset adres = '#adres#"&compnay_id=#attributes.company_id#&member_name=#attributes.member_name#&member_type=#attributes.member_type#'>
				</cfif>
             	<cfif len(attributes.consumer_id)>
					<cfset adres = '#adres#"&consumer_id=#attributes.consumer_id#&member_name=#attributes.member_name#&member_type=#attributes.member_type#'>
				</cfif>
				<cfif len(attributes.product_position) and len(attributes.product_pos_id)>
					<cfset adres = '#adres#"&product_position=#attributes.product_position#&product_pos_id=#attributes.product_pos_id#'>
				</cfif>
					<cf_pages page="#attributes.page#" 
					maxrows="#attributes.maxrows#"
					totalrecords="#attributes.totalrecords#"
					startrow="#attributes.startrow#"
					adres="#adres#"> 
			</td>
			<!-- sil --><td align="right" style="text-align:right;"><cfoutput><cf_get_lang_main no='128.Toplam Kayıt'>:#attributes.totalrecords#&nbsp;-&nbsp;<cf_get_lang_main no='169.Sayfa'>:#attributes.page#/#lastpage#</cfoutput></td><!-- sil -->
		</tr>
	</table>
</cfif>
<script type="text/javascript">
document.getElementById('keyword').focus();
function get_prod()
{
	if(document.search.product_name.value == "")
	document.search.stock_id.value = "";
}
function get_pos()
{
	if(document.search.product_position.value == "")
	document.search.product_pos_id.value = "";
}
</script>
