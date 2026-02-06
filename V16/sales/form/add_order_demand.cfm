<cf_xml_page_edit fuseact ="sales.form_add_order" default_value="1">
<cfquery name="GET_MONEY" datasource="#DSN#">
	SELECT
		MONEY,
		MONEY_ID
	FROM
		SETUP_MONEY
	WHERE	
		PERIOD_ID = #SESSION.EP.PERIOD_ID#
        AND MONEY_STATUS = 1 ORDER BY MONEY
</cfquery>
<cfquery name="GET_MONEY" datasource="#DSN#">
	SELECT RATE1, RATE2, MONEY FROM SETUP_MONEY WHERE PERIOD_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.period_id#"> AND MONEY_STATUS = 1 ORDER BY MONEY_ID
</cfquery>
<cfparam name="attributes.date" default="">
<cf_popup_box title="#getLang('sales',1)#">
	<cfform name="add_demand" action="#request.self#?fuseaction=sales.emptypopup_add_order_demand" method="post">
		<table>
			<tr>
				<td width="75"><cf_get_lang_main no ='1103.Aktif/Pasif'></td>
				<td><input type="checkbox" name="demand_status" id="demand_status" value="1" checked></td>
			</tr>
			<tr>
				<td><cf_get_lang no='351.Takip Türü'></td>
				<td><select name="demand_type" id="demand_type" style="width:170px;">
						<option value="3"><cf_get_lang no='350.Ön Sipariş'></option>
						<option value="1"><cf_get_lang no ='348.Fiyat Habercisi'></option>
						<option value="2"><cf_get_lang no='349.Stok Habercisi'></option>
					</select>
				</td>
			</tr>
			<tr>
				<td><cf_get_lang_main no='107.Cari Hesap'> *</td>
				<td>
					<input type="hidden" name="sales_member_id" id="sales_member_id" value="">
					<input type="hidden" name="sales_member_type" id="sales_member_type" value="">
					<input type="text" name="sales_member_name" id="sales_member_name" style="width:170px;" onFocus="AutoComplete_Create('sales_member_name','MEMBER_NAME,MEMBER_PARTNER_NAME,MEMBER_CODE','MEMBER_PARTNER_NAME2,MEMBER_NAME2,MEMBER_CODE','get_member_autocomplete','\'1,2\',0,0,0','PARTNER_CODE,MEMBER_TYPE','sales_member_id,sales_member_type','','3','250');" value="" autocomplete="off">
					<a href="javascript://" onClick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_pars&field_id=add_demand.sales_member_id&field_name=add_demand.sales_member_name&field_type=add_demand.sales_member_type<cfif session.ep.isBranchAuthorization>&is_store_module=1</cfif>&select_list=2,3','list','popup_list_pars');"><img src="/images/plus_thin.gif" align="absmiddle" border="0"></a>
				</td>
			</tr>
           <cfif is_date_request eq 1>
            <tr>
                <td><cf_get_lang_main no='330.Tarih'><cfif is_date_request eq 1>*</cfif></td>
                <td><cfsavecontent variable="message"><cf_get_lang_main no='370.Tarih Değerini Kontrol Ediniz'></cfsavecontent>
                        <cfinput type="text" name="demand_date" id="demand_date" value="#dateformat(now(),dateformat_style)#" validate="#validate_style#" maxlength="10" message="#message#" style="width:65px;">
                    <cf_wrk_date_image date_field="demand_date">
                </td>
            </tr>
           </cfif>
			<tr>
				<td width="75"><cf_get_lang_main no ='245.Ürün'> *</td>
				<td>
					<input type="hidden" name="stock_id" id="stock_id" value="">
					<input type="text" name="product_name" value="" style="width:170px;" id="product_name" onFocus="AutoComplete_Create('product_name','PRODUCT_NAME,STOCK_CODE_2','PRODUCT_NAME,STOCK_CODE_2','get_product_autocomplete','\'1,2\',0,0,0','STOCK_ID','stock_id','','3','250');">
					<a href="javascript://" onClick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_product_names&field_id=add_demand.stock_id&field_name=add_demand.product_name','list');"><img border="0" src="/images/plus_thin.gif" align="absmiddle" title="<cf_get_lang_main no='313.Ürün Seç'>"></a>
				</td>
			</tr>
			<tr>
				<td><cf_get_lang_main no ='261.Tutar'></td>
				<td>
                	<input type="hidden" name="kdvlimi" id="kdvlimi"   <cfif xml_kdvli eq 1> value="1" <cfelse>value="0"</cfif>>
					<input type="text" name="price_kdv" id="price_kdv" class="moneybox" value="0" style="width:120px;" onKeyUp="return(FormatCurrency(this,event,2));">
                    <select name="money_type" id="money_type" style="width:50px;">
					 <cfoutput>
                        <cfloop from="1" to="#get_money.recordcount#" index="k">
                            <option value="#get_money.money[k]#" <cfif get_money.money[k] eq session.ep.money>selected</cfif>>#get_money.money[k]#</option>
                        </cfloop>
                    </cfoutput>
					</select>
                         
				</td>
                <td>
              
                </td>
			</tr>
			<tr>
				<td><cf_get_lang_main no ='223.Miktar'> *</td>
				<td>
					<input type="text" class="moneybox" name="demand_amount" id="demand_amount" value="0" style="width:170px;" onKeyUp="isNumber(this);">
				</td>
			</tr>
			<tr>
				<td valign="top"><cf_get_lang_main no ='217.Açıklama'></td>
				<td><textarea name="demand_note" id="demand_note" style="width:170px;height:60px;"></textarea></td>
			</tr>
		</table>
    <cf_popup_box_footer><cf_workcube_buttons add_function='kontrol()'></cf_popup_box_footer>
	</cfform>
</cf_popup_box>
<script type="text/javascript">
	function kontrol()
	{
		if(document.add_demand.sales_member_name.value == '' || document.add_demand.sales_member_id.value =='')
		{
			alert("<cf_get_lang no='254.Cari Hesap Seçmelisiniz '>!");
			return false;
		}
		<cfif is_date_request eq 1>
			if(document.add_demand.demand_date.value=='' || document.add_demand.demand_date.value=='')
			{
				alert("<cf_get_lang_main no='1091.Lütfen Tarih Giriniz '>!");
				document.add_demand.demand_date.focus();
				return false;
			}
		</cfif>
		if(document.add_demand.product_name.value == '' || document.add_demand.stock_id.value == '')
		{
			alert("<cf_get_lang_main no='815.Ürün Seçmelisiniz'> !");
			return false;
		}
		if(document.add_demand.price_kdv.value == '')
		{
			alert("<cf_get_lang_main no='1738.Tutar Girmelisiniz'> !");
			return false;
		}
		if(document.add_demand.demand_amount.value == '' || document.add_demand.demand_amount.value == 0)
		{
			alert("<cf_get_lang no ='501.Miktar Girmelisiniz'> !");
			return false;
		}
		document.add_demand.price_kdv.value = filterNum(document.add_demand.price_kdv.value);
	}
</script>
