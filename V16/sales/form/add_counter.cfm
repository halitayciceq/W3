
<cfparam name="attributes.modal_id" default="">
<cf_xml_page_edit>
<cfset attributes.pcat_id = x_pcat_id>
<cfinclude template="../../sales/query/get_money.cfm">
<cfinclude template="../../sales/query/get_counter_type.cfm">
<cfinclude template="../../settings/query/get_our_companies.cfm">
<cfif len(attributes.pcat_id)>
	<cfinclude template="../../product/query/get_price_cat.cfm">
<cfelse>
	<cfset GET_PRICE_CAT = { recordcount : 0 } >
</cfif>

<cfquery name="GET_CREDIT_LIMIT" datasource="#DSN#">
	SELECT 
		PRICE_CAT
	FROM 
		COMPANY_CREDIT
	WHERE 
		COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.company_id#"> AND
		OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#">
</cfquery>
<cfif get_credit_limit.recordcount and len(get_credit_limit.price_cat)>
	<cfset attributes.price_cat_id = get_credit_limit.price_cat>
<cfelse>		
	<cfquery name="GET_COMP_CAT" datasource="#DSN#">
		SELECT COMPANYCAT_ID FROM COMPANY WHERE COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.company_id#">
	</cfquery>
	<cfquery name="GET_PRICE_CATS" datasource="#DSN3#">
		SELECT PRICE_CATID FROM PRICE_CAT WHERE COMPANY_CAT LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%,#get_comp_cat.companycat_id#,%">
	</cfquery>
	<cfif get_price_catS.recordcount>
		<cfset attributes.price_cat_id = get_price_catS.price_catid>
	<cfelse>
		<cfset attributes.price_cat_id = -2>
	</cfif>		
</cfif>
<cfif not isDefined("attributes.draggable")><cf_catalystHeader></cfif>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box id="box_counter" title="#iif(isDefined("attributes.draggable"),"getLang('sales','Sayaç Ekle',41277)",DE(''))#" scroll="1" collapsable="1" resize="1" popup_box="#iif(isdefined("attributes.draggable"),DE(1),DE(0))#">
		<cfform name="add_counter" id="add_counter" method="post" action="#iif(isDefined("attributes.draggable"),DE('#request.self#?fuseaction=sales.emptypopup_add_subscription_counter'),DE(''))#"  enctype="multipart/form-data">
			<cf_box_elements>
				<div class="<cfoutput>#iif(isDefined("attributes.draggable"),DE('col col-6 col-md-6 col-sm-6 col-xs-12'),DE('col col-4 col-md-4 col-sm-4 col-xs-12'))#</cfoutput>" type="column" index="1" sort="true">
					<div class="form-group" id="item-process_stage">
						<label class="col col-4"><cf_get_lang dictionary_id="58859.Süreç"></label>
						<div class="col col-8">
							<cf_workcube_process is_upd='0' is_detail='0'>
						</div>
					</div>
					<div class="form-group" id="item-counter_number">
						<label class="col col-4"><cf_get_lang dictionary_id='48871.Sayaç No'> *</label>
						<div class="col col-8">
							<div class="input-group">
								<input type="text" name="counter_number" id="counter_number" readonly="readonly" required>
								<span class="input-group-addon btn_Pointer" style="cursor:pointer;" onclick="createCode();"><cf_get_lang dictionary_id='61695.Üret'></span>
							</div>
						</div>
					</div>
					<cfif isDefined("attributes.subscription_id") and len(attributes.subscription_id) and isDefined("attributes.subscription_no") and len(attributes.subscription_no)>
						<div class="form-group" id="item-subscription_no">
							<label class="col col-4"><cf_get_lang dictionary_id='29502.Abone No'> *</label>
							<div class="col col-8">
								<cfinput type="hidden" name="subscription_id" id="subscription_id" value="#attributes.subscription_id#">
								<cfinput type="text" name="subscription_no" id="subscription_no" value="#attributes.subscription_no#" readonly="readonly" required="yes">
							</div>
						</div>
					<cfelse>
						<div class="form-group" id="item-subscription_no">
							<label class="col col-4"><cf_get_lang dictionary_id='29502.Abone No'> *</label>
							<div class="col col-8">
								<div class="input-group">
									<cfinput type="hidden" name="subscription_id" id="subscription_id">
									<cfinput type="text" name="subscription_no" id="subscription_no" readonly="readonly" required="yes">
									<span class="input-group-addon btn_Pointer icon-ellipsis" href="javascript://" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_subscription&field_id=add_counter.subscription_id&field_no=add_counter.subscription_no');"></span>
								</div>
							</div>
						</div>
					</cfif>
					<cfif x_group_company>
						<div class="form-group" id="item-our_company_id">
							<label class="col col-4"><cf_get_lang dictionary_id='57574.Şirket'></label>
							<div class="col col-8">
								<select name="our_company_id" id="our_company_id" required>
									<cfoutput query="our_company">
										<option value="#COMP_ID#">#COMPANY_NAME#</option>
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
									<cfset links="field_partner=add_counter.partner_id&field_consumer=add_counter.consumer_id&field_comp_id=add_counter.company_id&field_comp_name=add_counter.company_name&field_name=add_counter.member_name&field_type=add_counter.member_type">
									<input type="text" name="company_name" id="company_name" <cfif isDefined("attributes.partner_id") and len(attributes.partner_id)> value="<cfoutput>#get_par_info(attributes.partner_id, 0, 1, 0)#</cfoutput>" </cfif> >
                                    <span class="input-group-addon btn_Pointer icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_all_pars&<cfoutput>#links#</cfoutput>&select_list=2,3');"></span>
                                </div>
							</div>
							<div class="col col-4 col-md-4 col-sm-4 col-xs-12">
								<input type="hidden" name="consumer_id" id="consumer_id">
                                <input type="hidden" name="partner_id" id="partner_id" <cfif isDefined("attributes.partner_id") and len(attributes.partner_id)>value="<cfoutput>#attributes.partner_id#</cfoutput>" </cfif>>
                                <input type="hidden" name="company_id" id="company_id" <cfif isDefined("attributes.company_id") and len(attributes.company_id)>value="<cfoutput>#attributes.company_id#</cfoutput>" </cfif>>
                                <input type="hidden" name="member_type" id="member_type" <cfif isDefined("attributes.member_type") and len(attributes.member_type)>value="<cfoutput>#attributes.member_type#</cfoutput>" </cfif>>
                                <input type="text" name="member_name" id="member_name" <cfif isDefined("attributes.partner_id") and len(attributes.partner_id)> value="<cfoutput>#get_par_info(attributes.partner_id, 0, - 1, 0)#</cfoutput>"</cfif> readonly>
							</div>
						</div>
					</cfif>
					<div class="form-group" id="item-counter_type">
						<label class="col col-4"><cf_get_lang dictionary_id='41282.Sayaç Tipi'> *</label>
						<div class="col col-8">
							<select name="counter_type" id="counter_type" required>
								<cfoutput query="get_counter_type">
									<option value="#counter_type_id#">#counter_type#</option>
								</cfoutput>
							</select>
						</div>
					</div>
					<div class="form-group" id="item-product">
						<label class="col col-4"><cf_get_lang dictionary_id ='57657.Ürün'>*</label>
						<div class="col col-8">
							<div class="input-group">
								<input type="hidden" name="stock_id" id="stock_id" value="">
								<input type="hidden" name="product_id" id="product_id" value="">
								<input type="text" name="product" id="product" value="" readonly="readonly" required>
								<span class="input-group-addon btn_Pointer icon-ellipsis" href="javascript://" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_product_price_unit&field_amount=add_counter.amount&field_stock_id=add_counter.stock_id&field_id=add_counter.product_id&field_name=add_counter.product&field_unit_id=add_counter.unit_id&field_unit=add_counter.unit_name&field_price=add_counter.price&is_submitted=1&is_counter=1&counter_type_id='+document.add_counter.counter_type.value+'&price_cat_id='+document.add_counter.price_catid.value+'');"></span>
							</div>

					</div>						</div>
					<div class="form-group" id="item-unit_name">
						<label class="col col-4"><cf_get_lang dictionary_id='48888.Paket Miktar'> *</label>
						<div class="col col-4 col-md-4 col-sm-4 col-xs-12">
							<input type="text" name="amount" id="amount" value="" class="moneybox" required>
						</div>
						<div class="col col-4">
							<input type="hidden" name="unit_id" id="unit_id" value="">
							<input type="text" name="unit_name" id="unit_name" value="" readonly="readonly" required>
						</div>
					</div>
				</div>
				<div class="<cfoutput>#iif(isDefined("attributes.draggable"),DE('col col-6 col-md-6 col-sm-6 col-xs-12'),DE('col col-4 col-md-4 col-sm-4 col-xs-12'))#</cfoutput>" type="column" index="2" sort="true">
					<div class="form-group" id="item-price_catid">
						<label class="col col-4"><cf_get_lang dictionary_id='58964.Fiyat Listesi'></label>
						<div class="col col-8">
							<select name="price_catid" id="price_catid" onchange="get_empty_option(this.value);">
								<option value="-2" selected><cf_get_lang dictionary_id='58721.Standart Satış'></option>
								<cfif GET_PRICE_CAT.recordcount gt 0>
									<cfoutput query="get_price_cat">
										<option value="#PRICE_CATID#" <cfif price_catid eq attributes.price_cat_id> selected </cfif>>#PRICE_CAT#</option>
									</cfoutput>
								</cfif>
							</select>	
						</div>
					</div>
					<div class="form-group" id="item-price">
						<label class="col col-4"><cf_get_lang dictionary_id='33086.Özel Fiyat'></label>
						<div class="col col-6">
							<input type="text" name="price" id="price" value="" onkeyup="return(FormatCurrency(this,event,4));" class="moneybox">
						</div>	
						<div class="col col-2">
							<select name="money" id="money">
								<cfoutput query="get_money"> 
									<option value="#money#">#money#</option>
								</cfoutput>
							</select> 
						</div>
					</div>
					<div class="form-group" id="item-counter_start_date">
						<label  class="col col-4"><cf_get_lang dictionary_id='40986.İlk Okuma Tarihi'> *</label>
						<div class="col col-8">
							<div class="input-group">  
								<cfinput type="text" name="counter_start_date" id="counter_start_date" maxlength="10" validate="#validate_style#" value="" required="yes">
								<span class="input-group-addon"><cf_wrk_date_image date_field="counter_start_date"></span>
							</div>
						</div>
					</div>
					<div class="form-group" id="item-counter_finish_date">
						<label  class="col col-4"><cf_get_lang dictionary_id='40992.Son Hesaplama Tarihi'> *</label>
						<div class="col col-8">
							<div class="input-group">  
								<cfinput type="text" name="counter_finish_date" id="counter_finish_date" maxlength="10" validate="#validate_style#" value="" required="yes">
								<span class="input-group-addon"><cf_wrk_date_image date_field="counter_finish_date"></span>
							</div>
						</div>
					</div>
					<div class="form-group" id="item-document">
						<label class="col col-4"><cf_get_lang dictionary_id='29522.Sözleşme'>/ <cf_get_lang dictionary_id='57468.Belge'></label>
						<div class="col col-4">
							<cfinput type="text" name="document" id="document">
						</div>
						<div class="col col-4">
							<input type="file" name="uploaded_file" id="uploaded_file"></span>
						</div>
					</div>
					<div class="form-group" id="item-counter_detail">
						<label class="col col-4"><cf_get_lang dictionary_id='57629.Açıklama'></label>
						<div class="col col-8">
							<textarea name="counter_detail" id="counter_detail" style="width:150px;height:60px;"></textarea>
						</div>
					</div>
				</div>
			</cf_box_elements>	
			<cf_box_footer>
				<cf_workcube_buttons type_format='1' is_upd='0' is_delete='0' add_function='kontrol()'>
			</cf_box_footer>
		</cfform>
	</cf_box>
</div>
<script type="text/javascript">

function kontrol()
{
	unformat_fields();
	<cfif isdefined("attributes.draggable")>
		loadPopupBox('add_counter' , <cfoutput>#attributes.modal_id#</cfoutput>);
		return false;
	<cfelse>
		return true;
	</cfif>
}

function unformat_fields()
{
	document.add_counter.price.value = (document.add_counter.price.value != '' ? filterNum(document.add_counter.price.value,4) : '');
}

function createCode(){
	var rnd1 = Math.floor((Math.random() * 8999) + 1000);
	var rnd2 = Math.floor((Math.random() * 8999) + 1000);
	var rnd3 = Math.floor((Math.random() * 8999) + 1000);
	$("#counter_number").val(rnd1 + "_" + rnd2 + "_" + rnd3);
}
</script>
