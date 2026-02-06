<cf_xml_page_edit fuseact ="sales.form_add_order" default_value="1">
<cfquery name="GET_MONEY" datasource="#DSN#">
	SELECT
		MONEY,
		MONEY_ID
	FROM
		SETUP_MONEY
	WHERE	
		PERIOD_ID = #SESSION.EP.PERIOD_ID#
        AND MONEY_STATUS = 1 ORDER BY MONEY_ID
</cfquery>
<cfquery name="GET_ORDER_DEMANDS" datasource="#DSN3#">
	SELECT 
    	DEMAND_ID, 
        DEMAND_STATUS, 
        STOCK_ID, 
        PRICE, 
        PRICE_KDV,
        PRICE_MONEY, 
        DEMAND_TYPE, 
        DEMAND_NOTE, 
        DEMAND_AMOUNT, 
        STOCK_ACTION_TYPE, 
        GIVEN_AMOUNT, 
        ORDER_ID, 
        INVOICE_ID, 
        PROMOTION_ID, 
        RECORD_PAR, 
        RECORD_CON, 
        RECORD_EMP, 
        RECORD_DATE, 
        RECORD_IP, 
        UPDATE_EMP, 
        UPDATE_DATE, 
        UPDATE_IP,
        DEMAND_DATE
    FROM 
    	ORDER_DEMANDS 
    WHERE 
	    DEMAND_ID = #attributes.demand_id#
</cfquery>
<cfsavecontent variable="right_images">
	<cf_wrk_history act_type='1' act_id='#attributes.demand_id#'>
</cfsavecontent>
<cf_popup_box title="#getLang('sales',11)#" right_images="#right_images#">
	<cfform name="upd_demand" action="#request.self#?fuseaction=sales.emptypopup_upd_order_demand" method="post">
		<input name="demand_id" id="demand_id" value="<cfoutput>#attributes.demand_id#</cfoutput>" type="hidden">
		<table>
			<tr>
				<td width="75"><cf_get_lang_main no ='1103.Aktif/Pasif'></td>
				<td><input type="checkbox" name="demand_status" id="demand_status" value="1" <cfif len(get_order_demands.demand_status) and get_order_demands.demand_status eq 1>checked</cfif>></td>
			</tr>
			<tr>
				<td><cf_get_lang no='351.Takip Türü'></td>
				<td>
					<select name="demand_type" id="demand_type" style="width:170px;">
						<option value="3" <cfif get_order_demands.demand_type eq 3>selected</cfif>><cf_get_lang no='350.Ön Sipariş'></option>
						<option value="1" <cfif get_order_demands.demand_type eq 1>selected</cfif>><cf_get_lang no ='348.Fiyat Habercisi'></option>
						<option value="2" <cfif get_order_demands.demand_type eq 2>selected</cfif>><cf_get_lang no='349.Stok Habercisi'></option>
					</select>
				</td>
			</tr>
			<tr>
				<cfif len(get_order_demands.record_con)>
					<cfset sale_member_id = get_order_demands.record_con>
					<cfset sale_member_type = 'consumer'>
					<cfset sale_member_name = get_cons_info(get_order_demands.record_con,0,0)>
				<cfelseif len(get_order_demands.record_par)>
					<cfset sale_member_id = get_order_demands.record_par>
					<cfset sale_member_type = 'partner'>
					<cfset sale_member_name = get_par_info(get_order_demands.record_par,0,-1,0)>
				<cfelse>
					<cfset sale_member_id = ''>
					<cfset sale_member_type = ''>
					<cfset sale_member_name = ''>
				</cfif>
				<cfparam name="attributes.sales_member_name" default="#sale_member_name#">
				<td><cf_get_lang_main no='107.Cari Hesap'></td>
				<td>
					<input type="hidden" name="sales_member_id" id="sales_member_id" value="<cfoutput>#sale_member_id#</cfoutput>">
					<input type="hidden" name="sales_member_type" id="sales_member_type" value="<cfoutput>#sale_member_type#</cfoutput>">
					<input type="text" name="sales_member_name" id="sales_member_name" style="width:170px;" onfocus="AutoComplete_Create('sales_member_name','MEMBER_NAME,MEMBER_PARTNER_NAME','MEMBER_PARTNER_NAME2,MEMBER_NAME2','get_member_autocomplete','\'1,2\',0,0,0','PARTNER_CODE,MEMBER_TYPE','sales_member_id,sales_member_type','','3','250');" value="<cfoutput>#sale_member_name#</cfoutput>" autocomplete="off">
					<a href="javascript://" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_pars&field_id=upd_demand.sales_member_id&field_name=upd_demand.sales_member_name&field_type=upd_demand.sales_member_type<cfif session.ep.isBranchAuthorization>&is_store_module=1</cfif>&select_list=2,3','list','popup_list_pars');"><img src="/images/plus_thin.gif" align="absmiddle" border="0"></a>
				</td>
			</tr>
            <cfif is_date_request eq 1>
            <tr>
            	<td><cf_get_lang_main no='330.Tarih'> *</td>
                <td><cfsavecontent variable="message"><cf_get_lang_main no='370.Tarih Değerini Kontrol Ediniz'></cfsavecontent>
                    <cfinput type="text" name="demand_date" id="demand_date" value="#dateformat(get_order_demands.DEMAND_DATE,dateformat_style)#"  validate="#validate_style#" maxlength="10" message="#message#" style="width:65px;">
                    <cf_wrk_date_image date_field="demand_date">
                </td>
            </tr>
            </cfif>
			<tr>
				<td width="75"><cf_get_lang_main no ='245.Ürün'></td>
				<td>
					<cfif len(get_order_demands.stock_id)>
						<cfquery name="GET_PRO_NAME" datasource="#DSN3#">
							SELECT PRODUCT_NAME FROM STOCKS WHERE STOCK_ID = #get_order_demands.stock_id#
						</cfquery>							
					</cfif>
					<cfparam name="attributes.product_name" default="#get_pro_name.product_name#">
					<input type="hidden" name="stock_id" id="stock_id" value="<cfoutput>#get_order_demands.stock_id#</cfoutput>">
					<input type="text" name="product_name" value="<cfif len(get_order_demands.stock_id)><cfoutput>#get_pro_name.product_name#</cfoutput></cfif>" style="width:170px;" id="product_name" onfocus="AutoComplete_Create('product_name','PRODUCT_NAME,STOCK_CODE_2','PRODUCT_NAME,STOCK_CODE_2','get_product_autocomplete','\'1,2\',0,0,0','STOCK_ID','stock_id','','3','250');">
					<a href="javascript://" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_product_names&field_id=upd_demand.stock_id&field_name=upd_demand.product_name','list');"><img border="0" src="/images/plus_thin.gif" align="absmiddle" title="<cf_get_lang_main no='313.Ürün Seç'>"></a>
				</td>
			</tr>
			<tr>
				<td><cf_get_lang_main no ='261.Tutar'></td>
				<td>
                <input type="hidden" name="kdvlimi" id="kdvlimi"   <cfif xml_kdvli eq 1> value="1" <cfelse>value="0"</cfif>>
						<input type="text" class="moneybox" name="price_kdv" id="price_kdv" value="<cfif len(get_order_demands.price_kdv) and xml_kdvli eq 1><cfoutput>#tlformat(get_order_demands.price_kdv)#</cfoutput><cfelseif len(get_order_demands.price_kdv) and xml_kdvli eq 0><cfoutput>#tlformat(get_order_demands.price)#</cfoutput><cfelse><cfoutput>#tlformat(0)#</cfoutput></cfif>" style="width:120px;" onkeyup="return(FormatCurrency(this,event,2));">
               	<select name="money_type" id="money_type" style="width:50px;">
					 <cfoutput>
                        <cfloop from="1" to="#get_money.recordcount#" index="k">
                            <option value="#get_money.money[k]#" <cfif get_money.money[k] eq GET_ORDER_DEMANDS.PRICE_MONEY>selected</cfif>>#get_money.money[k]#</option>
                        </cfloop>
                    </cfoutput>
				</select>
				</td>
			</tr>
			<tr>
				<td><cf_get_lang_main no ='223.Miktar'></td>
				<td>
					<input type="text" class="moneybox" name="demand_amount" id="demand_amount" value="<cfoutput>#get_order_demands.demand_amount#</cfoutput>" style="width:170px;" onkeyup="isNumber(this);">
				</td>
			</tr>
			<tr>
				<td valign="top"><cf_get_lang_main no ='217.Açıklama'></td>
				<td><textarea name="demand_note" id="demand_note" style="width:170px;height:60px;"><cfoutput>#get_order_demands.demand_note#</cfoutput></textarea></td>
			</tr>
		</table>
		<cf_popup_box_footer>
			<cf_record_info query_name="get_order_demands">
			<cfif get_order_demands.given_amount neq 0>				
				<cf_workcube_buttons is_upd='1' is_delete='0' add_function='kontrol()'>
			<cfelse>
				<cf_workcube_buttons is_upd='1' is_delete='1' delete_page_url='#request.self#?fuseaction=sales.emptypopup_del_order_demand&demand_id=#attributes.demand_id#&action_name=#attributes.sales_member_name#-#attributes.product_name#' add_function='kontrol()'>
			</cfif>
		</cf_popup_box_footer>
	</cfform>
</cf_popup_box>
<script type="text/javascript">
	function kontrol()
	{
		if(document.upd_demand.sales_member_name.value == '' || document.upd_demand.sales_member_id.value =='')
		{
			alert("<cf_get_lang no='254.Cari Hesap Seçmelisiniz '>!");
			return false;
		}
		if(document.upd_demand.product_name.value == '' || document.upd_demand.stock_id.value == '')
		{
			alert("<cf_get_lang_main no='815.Ürün Seçmelisiniz'> !");
			return false;
		}
		<cfif is_date_request eq 1>
			if(document.upd_demand.demand_date.value=='' || document.upd_demand.demand_date.value==0)
			{
				alert("<cf_get_lang_main no='1091.Lütfen Tarih Giriniz '>!");
				document.upd_demand.demand_date.focus();
				return false;
			}
		</cfif>
		if(document.upd_demand.price_kdv.value == '')
		{
			alert("<cf_get_lang_main no='1738.Tutar Girmelisiniz'> !");
			return false;
		}
		if(document.upd_demand.demand_amount.value == '' || document.upd_demand.demand_amount.value == 0)
		{
			alert("<cf_get_lang no ='501.Miktar Girmelisiniz'> !");
			return false;
		}
		document.getElementById('price_kdv').value = filterNum(document.getElementById('price_kdv').value);
		return true;
	}
</script>
