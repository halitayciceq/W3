<cf_xml_page_edit>
<cfparam name="attributes.modal_id" default="">
<cfset attributes.pcat_id = x_pcat_id>
<cfinclude template="../query/get_money.cfm">
<cfinclude template="../query/get_counter_type.cfm">
<cfinclude template="../../settings/query/get_our_companies.cfm">
<cfif len(attributes.pcat_id)>
	<cfinclude template="../../product/query/get_price_cat.cfm">
<cfelse>
	<cfset GET_PRICE_CAT = { recordcount : 0 } >
</cfif>

<cfset listCt = createObject("component","V16.sales.cfc.counter")>
<cfset GET_COUNTER_TYPE_ROW2 = listCt.select(
    counter_id  :   attributes.counter_id
)>

<cfset GET_COUNTER_NUMBER = listCt.sel_GetCN(
    counter_id  :   attributes.counter_id
)>

<cfset GET_COUNTER_INVOICE_ROW = listCt.sel_GetCI(
    counter_id  :   attributes.counter_id
)>

<cfset GET_COUNTER_COUNTER_METER = listCt.sel_GetCM(
    counter_id  :   attributes.counter_id
)>

<cfset is_delete = GET_COUNTER_COUNTER_METER.recordcount gt 0 ? 0 : 1>

<!---<cfquery name="GET_COUNTER_TYPE_ROW" datasource="#DSN3#">
	SELECT 
		SCNTR.*, SCNT.SUBSCRIPTION_ID, SCNT.SUBSCRIPTION_NO, TARIFF.TARIFF_NAME, P.PRODUCT_NAME, P.PRODUCT_ID, WEX.HEAD
	FROM 
		SUBSCRIPTION_COUNTER AS SCNTR
	LEFT JOIN SUBSCRIPTION_CONTRACT AS SCNT
		ON SCNTR.SUBSCRIPTION_ID = SCNT.SUBSCRIPTION_ID
	LEFT JOIN SUBSCRIPTION_TARIFF AS TARIFF 
		ON SCNTR.TARIFF = TARIFF.TARIFF_ID
	LEFT JOIN PRODUCT AS P
		ON SCNTR.PRODUCT_ID = P.PRODUCT_ID
	LEFT JOIN #dsn#.WRK_WEX AS WEX
		ON SCNTR.WEX_CODE = WEX.WEX_ID
	WHERE 
		COUNTER_ID = #attributes.counter_id#
</cfquery>--->

<!--- sayacı okuma girilmis mi --->
<!---<cfquery name="GET_COUNTER_NUMBER" datasource="#DSN3#">
	SELECT COUNT(COUNTER_ID) AS COUNTER_COUNT FROM SUBSCRIPTION_COUNTER_RESULT_ROW WHERE COUNTER_ID = #attributes.counter_id# 
</cfquery>--->

<!--- Sayaca ait faturalama işlemi varmi? --->
<!---<cfquery name="GET_COUNTER_INVOICE_ROW" datasource="#DSN3#">
	SELECT
		SCI.RESULT_ROW_ID,
		SUM(SCI.INVOICE_VALUE) AS TOTAL_INVOICE_VALUE
	FROM
		SUBSCRIPTION_CONTRACT_INVOICE SCI,
		SUBSCRIPTION_COUNTER_RESULT_ROW SCRR,
		SUBSCRIPTION_COUNTER SC
	WHERE
		SCI.RESULT_ROW_ID IS NOT NULL AND
		SCI.RESULT_ROW_ID = SCRR.COUNTER_RESULT_ID AND
		SCRR.COUNTER_ID = SC.COUNTER_ID AND
		SC.COUNTER_ID = #attributes.counter_id# 
	GROUP BY
		SCI.RESULT_ROW_ID
</cfquery>--->

<!--- 
<cfsavecontent variable="right_">
	<a href="javascript://" onClick="windowopen('<cfoutput>#request.self#?fuseaction=sales.popup_add_subscription_counter&subscription_id=#GET_COUNTER_TYPE_ROW2.SUBSCRIPTION_ID#&subscription_no=#GET_COUNTER_TYPE_ROW2.SUBSCRIPTION_NO#</cfoutput>','page');"><img src="/images/plus1.gif" title="<cf_get_lang dictionary_id='170.Ekle'>"></a>
</cfsavecontent> --->

<cfif not isDefined("attributes.draggable")><cf_catalystHeader></cfif>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	
	<cf_box title="#iif(isDefined("attributes.draggable"),"getLang('sales','Sayaç Güncelle',41293)",DE(''))#" scroll="1" collapsable="1" resize="1" popup_box="#iif(isdefined("attributes.draggable"),1,0)#">
		<cfform name="upd_counter" method="post" action="#iif(isDefined("attributes.draggable"),DE('#request.self#?fuseaction=sales.emptypopup_upd_subscription_counter'),DE(''))#">
			<cfoutput>
				<input type="hidden" name="counter_id" id="counter_id" value="#attributes.counter_id#">
				<input type="hidden" name="subscription_id" id="subscription_id" value="<cfif len(get_counter_type_row2.subscription_id)>#get_counter_type_row2.subscription_id#</cfif>">
			</cfoutput>
			<cf_box_elements>
				<div class="<cfoutput>#iif(isDefined("attributes.draggable"),DE('col col-6 col-md-6 col-sm-6 col-xs-12'),DE('col col-4 col-md-4 col-sm-4 col-xs-12'))#</cfoutput>" type="column" index="1" sort="true">
					<div class="form-group" id="item-process_stage">
						<label class="col col-4"><cf_get_lang dictionary_id="58859.Süreç"></label>
						<div class="col col-8">
							<cf_workcube_process is_upd='0' is_detail='0' select_value="#len(GET_COUNTER_TYPE_ROW2.COUNTER_STAGE_ID) ? GET_COUNTER_TYPE_ROW2.COUNTER_STAGE_ID : ''#">
						</div>
					</div>
					<div class="form-group" id="item-counter_number">
						<label class="col col-4"><cf_get_lang dictionary_id='48871.Sayaç No'></label>
						<div class="col col-8">
							<input type="text" name="counter_number" id="counter_number" value="<cfif len(GET_COUNTER_TYPE_ROW2.COUNTER_NO)><cfoutput>#GET_COUNTER_TYPE_ROW2.COUNTER_NO#</cfoutput></cfif>" required>
						</div>
					</div>	
					<div class="form-group" id="item-subscriber_number">
						<label class="col col-4"><cf_get_lang dictionary_id='29502.Abone No'></label>
						<div class="col col-8">
							<input type="text" name="subscription_no" id="subscription_no" value="<cfif len(GET_COUNTER_TYPE_ROW2.SUBSCRIPTION_NO)><cfoutput>#GET_COUNTER_TYPE_ROW2.SUBSCRIPTION_NO#</cfoutput></cfif>" required>
						</div>
					</div>
					<cfif x_group_company>
						<div class="form-group" id="item-our_company_id">
							<label class="col col-4"><cf_get_lang dictionary_id='57574.Şirket'></label>
							<div class="col col-8">
								<select name="our_company_id" id="our_company_id" required>
									<cfoutput query="our_company">
										<option value="#COMP_ID#" <cfif GET_COUNTER_TYPE_ROW2.our_company_id eq COMP_ID> selected</cfif>>#COMPANY_NAME#</option>
									</cfoutput>
								</select>
							</div>
						</div>
					</cfif>
					<cfif x_invoice_company>
						<div class="form-group" id="item-comp_id">
							<label class="col col-4"><cf_get_lang dictionary_id='65313.Müşteri / Yetkili'></label>
							<div class="col col-4 col-md-4 col-sm-4 col-xs-12">
								<div class="input-group">
									<cfset links="field_partner=upd_counter.partner_id&field_consumer=upd_counter.consumer_id&field_comp_id=upd_counter.company_id&field_comp_name=upd_counter.company_name&field_name=upd_counter.member_name&field_type=upd_counter.member_type">
									<input type="text" name="company_name" id="company_name" value="<cfoutput>#len(GET_COUNTER_TYPE_ROW2.PARTNER_ID)?get_par_info(GET_COUNTER_TYPE_ROW2.partner_id, 0, 1, 0):''#</cfoutput>">
                                    <span class="input-group-addon btn_Pointer icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_all_pars&<cfoutput>#links#</cfoutput>&select_list=2,3');"></span>
                                </div>
							</div>
							<div class="col col-4 col-md-4 col-sm-4 col-xs-12">
								<cfinput type="hidden" name="consumer_id" id="consumer_id" value="#GET_COUNTER_TYPE_ROW2.consumer_id#">
                                <cfinput type="hidden" name="partner_id" id="partner_id" value="#GET_COUNTER_TYPE_ROW2.partner_id#">
                                <cfinput type="hidden" name="company_id" id="company_id" value="#GET_COUNTER_TYPE_ROW2.company_id#" >
                                <cfinput type="hidden" name="member_type" id="member_type" value="#len(GET_COUNTER_TYPE_ROW2.PARTNER_ID)?'partner':'consumer'#">
                                <input type="text" name="member_name" id="member_name" value="<cfoutput>#len(GET_COUNTER_TYPE_ROW2.PARTNER_ID)?get_par_info(GET_COUNTER_TYPE_ROW2.partner_id, 0, - 1, 0):get_cons_info(GET_COUNTER_TYPE_ROW2.consumer_id, 0, 0)#</cfoutput>"  readonly>
							</div>
						</div>
					</cfif>
					<div class="form-group" id="item-counter_type">
						<label class="col col-4"><cf_get_lang dictionary_id='41282.Sayaç Tipi'> *</label>
						<div class="col col-8">
							<select name="counter_type" id="counter_type" required>
								<cfoutput query="get_counter_type">
									<option value="#counter_type_id#" <cfif GET_COUNTER_TYPE_ROW2.COUNTER_TYPE_ID eq counter_type_id> selected</cfif>>#counter_type#</option>
								</cfoutput>
							</select>
						</div>
					</div>	
					<div class="form-group" id="item-product">
						<label class="col col-4"><cf_get_lang dictionary_id ='57657.Ürün'> *</label>
						<div class="col col-8">
							<div class="input-group">
								<input type="hidden" name="stock_id" id="stock_id" value="<cfif len(GET_COUNTER_TYPE_ROW2.STOCK_ID)><cfoutput>#GET_COUNTER_TYPE_ROW2.STOCK_ID#</cfoutput></cfif>">
								<input type="hidden" name="product_id" id="product_id" value="<cfif len(GET_COUNTER_TYPE_ROW2.PRODUCT_ID)><cfoutput>#GET_COUNTER_TYPE_ROW2.PRODUCT_ID#</cfoutput></cfif>">
								<input type="text" name="product" id="product" value="<cfif len(GET_COUNTER_TYPE_ROW2.PRODUCT_NAME)><cfoutput>#GET_COUNTER_TYPE_ROW2.PRODUCT_NAME#</cfoutput></cfif>" readonly="readonly" required>
								<span class="input-group-addon btn_Pointer icon-ellipsis" href="javascript://" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_product_price_unit&field_amount=upd_counter.amount&field_stock_id=upd_counter.stock_id&field_id=upd_counter.product_id&field_name=upd_counter.product&field_unit_id=upd_counter.unit_id&field_unit=upd_counter.unit_name&field_price=upd_counter.price&is_submitted=1&is_counter=1&counter_type_id='+document.upd_counter.counter_type.value+'&price_cat_id='+document.upd_counter.price_catid.value+' ');"></span>
							</div>
						</div>
					</div>
					<div class="form-group" id="item-unit_name">
						<label class="col col-4"><cf_get_lang dictionary_id='48888.Paket Miktar'></label>
						<div class="col col-4 col-xs-12">
							<input type="text" name="amount" id="amount" value="<cfif len(GET_COUNTER_TYPE_ROW2.AMOUNT)><cfoutput>#GET_COUNTER_TYPE_ROW2.AMOUNT#</cfoutput></cfif>" class="moneybox" required>
						</div>
						<div class="col col-4 col-xs-12">
							<input type="hidden" name="unit_id" id="unit_id" value="<cfif len(GET_COUNTER_TYPE_ROW2.UNIT_ID)><cfoutput>#GET_COUNTER_TYPE_ROW2.UNIT_ID#</cfoutput></cfif>">
							<input type="text" name="unit_name" id="unit_name" value="<cfif len(GET_COUNTER_TYPE_ROW2.UNIT)><cfoutput>#GET_COUNTER_TYPE_ROW2.UNIT#</cfoutput></cfif>" readonly="readonly" required>
						</div>
					</div>
					
				</div>
				<div class="<cfoutput>#iif(isDefined("attributes.draggable"),DE('col col-6 col-md-6 col-sm-6 col-xs-12'),DE('col col-4 col-md-4 col-sm-4 col-xs-12'))#</cfoutput>" type="column" index="2" sort="true">
					<div class="form-group" id="item-price_catid">
						<label class="col col-4"><cf_get_lang dictionary_id='58964.Fiyat Listesi'></label>
						<div class="col col-8">
							<select name="price_catid" id="price_catid" onchange="get_empty_option(this.value);">
								<option value="-2" <cfif GET_COUNTER_TYPE_ROW2.PRICE_CATID eq -2> selected</cfif>><cf_get_lang dictionary_id='58721.Standart Satış'></option>
								<cfif GET_PRICE_CAT.recordcount gt 0>
									<cfoutput query="get_price_cat">
										<option value="#PRICE_CATID#" <cfif GET_COUNTER_TYPE_ROW2.PRICE_CATID eq PRICE_CATID> selected</cfif>>#PRICE_CAT#</option>
									</cfoutput>
								</cfif>
							</select>	
						</div>
					</div>
					<div class="form-group" id="item-price">
						<label class="col col-4"><cf_get_lang dictionary_id='33086.Özel Fiyat'></label>
						<div class="col col-6 col-md-2 col-sm-2 col-xs-6">
							<input type="text" name="price" id="price" value="<cfif len(GET_COUNTER_TYPE_ROW2.PRICE)><cfoutput>#GET_COUNTER_TYPE_ROW2.PRICE#</cfoutput></cfif>" onkeyup="return(FormatCurrency(this,event,4));" class="moneybox">
						</div>	
						<div class="col col-2 col-md-1 col-sm-1 col-xs-6">
							<select name="money" id="money">
								<cfoutput query="get_money"> 
									<option value="#money#" <cfif GET_COUNTER_TYPE_ROW2.OTHER_MONEY eq money> selected</cfif>>#money#</option>
								</cfoutput>
							</select> 
						</div>
					</div>
					<div class="form-group" id="item-counter_startdate">
						<label  class="col col-4 col-xs-12"><cf_get_lang dictionary_id='40986.İlk Okuma Tarihi'> *</label>
						<div class="col col-8">
							<div class="input-group">  
								<cfinput type="text" name="counter_startdate" id="counter_startdate" maxlength="10" validate="#validate_style#"  value="#len(GET_COUNTER_TYPE_ROW2.START_DATE) ? dateformat(GET_COUNTER_TYPE_ROW2.START_DATE,dateformat_style) : ''#" required="yes">
								<span class="input-group-addon"><cf_wrk_date_image date_field="counter_startdate"></span>
							</div>
						</div>
					</div>
					<div class="form-group" id="item-counter_finishdate">
						<label  class="col col-4 col-xs-12"><cf_get_lang dictionary_id='40992.Son Hesaplama Tarihi'> *</label>
						<div class="col col-8">
							<div class="input-group">  
								<cfinput type="text" name="counter_finishdate" id="counter_finishdate" maxlength="10" validate="#validate_style#"  value="#len(GET_COUNTER_TYPE_ROW2.FINISH_DATE) ? dateformat(GET_COUNTER_TYPE_ROW2.FINISH_DATE,dateformat_style) : ''#" required="yes">
								<span class="input-group-addon"><cf_wrk_date_image date_field="counter_finishdate"></span>
							</div>
						</div>
					</div>
					<div class="form-group" id="item-document">
						<label class="col col-4"><cf_get_lang dictionary_id='29522.Sözleşme'>/ <cf_get_lang dictionary_id='57468.Belge'></label>
						<div class="col col-4 col-md-3 col-sm-3 col-xs-12">
							<input type="text" name="document" id="document" value="<cfif len(GET_COUNTER_TYPE_ROW2.DOCUMENTS)><cfoutput>#GET_COUNTER_TYPE_ROW2.DOCUMENTS#</cfoutput></cfif>">
						</div>
						<div class="col col-4 col-md-3 col-sm-3 col-xs-12">
							<input type="file" name="uploaded_file" id="uploaded_file"></span>
						</div>
					</div>
					<div class="form-group" id="item-counter_detail">
						<label class="col col-4"><cf_get_lang dictionary_id='57629.Açıklama'></label>
						<div class="col col-8">
							<textarea name="counter_detail" id="counter_detail" style="width:150px;height:60px;"><cfif len(GET_COUNTER_TYPE_ROW2.COUNTER_DETAIL)><cfoutput>#GET_COUNTER_TYPE_ROW2.COUNTER_DETAIL#</cfoutput></cfif></textarea>
						</div>
					</div>
				</div>
			</cf_box_elements>
			<cf_box_footer>
				<div class="col col-6">
					<cf_record_info query_name="get_counter_type_row2">
				</div>
				<div class="col col-6">
					<cfif is_delete eq 0><b>Sayaç okuma işlemi yapıldığından silinemez.</b></cfif>
					<cf_workcube_buttons is_upd='1' is_delete='#is_delete#' add_function='kontrol()' del_function="#isDefined('attributes.draggable') ? 'deleteFunc()' : ''#">
				</div>
			</cf_box_footer>
		</cfform>
	</cf_box>
</div>
<script type="text/javascript">
function kontrol()
{
	unformat_fields();
	<cfif isdefined("attributes.draggable")>
		loadPopupBox('upd_counter' , <cfoutput>#attributes.modal_id#</cfoutput>);
		return false;
	<cfelse>
		return true;
	</cfif>
}

<cfif isDefined('attributes.draggable')>
	function deleteFunc() {
		openBoxDraggable('<cfoutput>#request.self#?fuseaction=sales.counter&event=del&counter_id=#attributes.counter_id#</cfoutput>',<cfoutput>#attributes.modal_id#</cfoutput>);
	}
</cfif>

function unformat_fields()
{
	document.upd_counter.price.value = filterNum(document.upd_counter.price.value);
}
</script>
