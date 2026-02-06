<cfsetting showdebugoutput="no">
<cfquery name="get_pro_detail" datasource="#dsn#">
	SELECT COMPANY_ID,CONSUMER_ID,PARTNER_ID FROM PRO_PROJECTS WHERE PROJECT_ID=#attributes.project_id#
</cfquery>
<cfquery name="get_project_discounts" datasource="#dsn3#">
	SELECT
		*
	FROM
		PROJECT_DISCOUNTS PD,
		PROJECT_DISCOUNT_CONDITIONS PDC
	WHERE
		PD.PRO_DISCOUNT_ID=PDC.PRO_DISCOUNT_ID
		AND PD.PROJECT_ID = #attributes.project_id#
</cfquery>
<cfset product_name_list=''>
<cfset brand_id_list=listsort(valuelist(get_project_discounts.brand_id),'numeric','asc')>
<cfset product_cat_list=listsort(valuelist(get_project_discounts.product_catid),'numeric','asc')>
<cfset product_id_list=listsort(valuelist(get_project_discounts.product_id),'numeric','asc')>
<cfif len(product_id_list)>
	<cfquery name="GET_PROD_NAMES" datasource="#dsn3#">
		SELECT PRODUCT_ID,PRODUCT_NAME FROM PRODUCT WHERE PRODUCT_ID IN (#product_id_list#) ORDER BY PRODUCT_ID
	</cfquery>
	<cfset product_name_list=valuelist(GET_PROD_NAMES.PRODUCT_NAME)>
</cfif>
<cfquery name="GET_PRICE_CATS" datasource="#dsn3#">
	SELECT * FROM PRICE_CAT ORDER BY PRICE_CAT
</cfquery>
<cfquery name="GET_COMP_CATS" datasource="#dsn#">
	SELECT DISTINCT COMPANYCAT_ID,COMPANYCAT FROM COMPANY_CAT
</cfquery>
<cfquery name="GET_PRO_BRANDS" datasource="#dsn3#"><!--- Markalar --->
	SELECT BRAND_NAME,BRAND_ID FROM PRODUCT_BRANDS ORDER BY BRAND_NAME
</cfquery>

<cfquery name="GET_PRODUCT_CAT" datasource="#DSN1#">
	SELECT 
		PRODUCT_CAT.PRODUCT_CATID, 
		PRODUCT_CAT.HIERARCHY, 
		PRODUCT_CAT.PRODUCT_CAT
	FROM 
		PRODUCT_CAT,
		PRODUCT_CAT_OUR_COMPANY PCO
	WHERE 
		PRODUCT_CAT.PRODUCT_CATID = PCO.PRODUCT_CATID AND
		PCO.OUR_COMPANY_ID = #session.ep.company_id# 
	ORDER BY 
		HIERARCHY
</cfquery>	
<cfsavecontent variable="right">
	<cfif get_project_discounts.recordcount>
		<li><a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_list_project_discount_history&id=#attributes.project_id#</cfoutput>','wide');"><i class="fa fa-history"  title="<cf_get_lang dictionary_id='57473.Tarihçe'>"></i></a></li>
	</cfif>
</cfsavecontent>
<cfparam name="attributes.modal_id" default="">
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cfsavecontent variable="title"><cf_get_lang dictionary_id='38465.Proje Bağlantıları'></cfsavecontent>
		<cf_box title="#title# : #get_project_name(attributes.project_id)#" right_images="#right#" resize="0" collapsable="0" popup_box="#iif(isdefined("attributes.draggable"),1,0)#">
		<cfform name="project_discounts_" method="post" action="#request.self#?fuseaction=project.emptypopup_add_project_prod_discounts">
			<cfoutput>
				<input type="hidden" name="project_id" id="project_id" value="#attributes.project_id#">
				<input type="hidden" name="prj_company_id" id="prj_company_id" value="<cfif len(get_pro_detail.company_id)>#get_pro_detail.company_id#</cfif>">
				<input type="hidden" name="prj_consumer_id" id="prj_consumer_id" value="<cfif len(get_pro_detail.consumer_id)>#get_pro_detail.consumer_id#</cfif>">
			</cfoutput>
			<cf_box_elements>
				<div class="col col-4 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">	
					<cfsavecontent variable="header_"><cf_get_lang dictionary_id='57519.Cari Hesap'></cfsavecontent>
					<div class="form-group" id="item-check_prj_price_cat_">
						<label class="col col-5 col-md-5 col-sm-5 col-xs-12"><cf_get_lang dictionary_id='57519.Cari Hesap'></label>
						<label class="col col-7 col-md-7 col-sm-7 col-xs-12"><cfoutput><cfif len(get_pro_detail.company_id)>#get_par_info(get_pro_detail.company_id,1,0,1)#<cfelseif len(get_pro_detail.consumer_id)>#get_par_info(get_pro_detail.consumer_id,1,0,1)#</cfif></cfoutput></label>
					</div> 
					<cfsavecontent variable="header_"><cf_get_lang dictionary_id='58964.Fiyat Listesi'></cfsavecontent>
					<div class="form-group" id="item-price_cat">
						<label class="col col-3 col-md-3 col-sm-3 col-xs-12"><cf_get_lang dictionary_id='58964.Fiyat Listesi'></label>
						<div class="col col-9 col-md-9 col-sm-9 col-xs-12">
							<select name="price_cat" id="price_cat">
								<option value="-1" <cfif len(get_project_discounts.PRICE_CATID) and get_project_discounts.PRICE_CATID eq -1>selected</cfif>><cf_get_lang dictionary_id='58722.Standart Alış'></option>
								<option value="-2" <cfif len(get_project_discounts.PRICE_CATID) and get_project_discounts.PRICE_CATID eq -2>selected</cfif>><cf_get_lang dictionary_id='58722.Standart Satış'></option>
								<cfoutput query="GET_PRICE_CATS">
									<option value="#GET_PRICE_CATS.PRICE_CATID#" <cfif len(get_project_discounts.PRICE_CATID) and get_project_discounts.PRICE_CATID IS GET_PRICE_CATS.PRICE_CATID>selected</cfif>>#GET_PRICE_CATS.PRICE_CAT#
								</cfoutput>
							</select>
						</div>
					</div>
					<cfsavecontent variable="header_"><cf_get_lang dictionary_id='57486.Kategori'></cfsavecontent>
					<div class="form-group" id="item-product_cat">
						<label class="col col-3 col-md-3 col-sm-3 col-xs-12"><cf_get_lang dictionary_id='57486.Kategori'></label>
						<div class="col col-9 col-md-9 col-sm-9 col-xs-12">
							<select name="product_cat" id="product_cat" multiple="multiple">
								<cfoutput query="get_product_cat">
									<option value="#PRODUCT_CATID#" <cfif len(product_cat_list) and listfind(product_cat_list,PRODUCT_CATID)>selected</cfif>>#HIERARCHY#-#product_cat#</option>
								</cfoutput>
							</select>
						</div>
					</div>
					<cfsavecontent variable="header_"><cf_get_lang dictionary_id='58847.marka'></cfsavecontent>
					<div class="form-group" id="item-product_brands">
						<label class="col col-3 col-md-3 col-sm-3 col-xs-12"><cf_get_lang dictionary_id='58847.marka'></label>
						<div class="col col-9 col-md-9 col-sm-9 col-xs-12">
							<select name="product_brands" id="product_brands" multiple="multiple">
								<cfoutput query="GET_PRO_BRANDS">
									<option value="#BRAND_ID#" <cfif len(brand_id_list) and listfind(brand_id_list,BRAND_ID)>selected</cfif>>#BRAND_NAME#</option>
								</cfoutput>
							</select>
						</div>
					</div>
					<cfif len(get_project_discounts.paymethod_id)>
						<cfquery name="GET_PAY_METHOD" datasource="#DSN#">
							SELECT PAYMETHOD FROM SETUP_PAYMETHOD WHERE PAYMETHOD_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_project_discounts.paymethod_id#">
						</cfquery>
						<cfset paymethod_name_ = get_pay_method.paymethod>
					<cfelseif len(get_project_discounts.card_paymethod_id)>
						<cfquery name="GET_PAY_METHOD" datasource="#DSN3#">
							SELECT CARD_NO FROM CREDITCARD_PAYMENT_TYPE WHERE PAYMENT_TYPE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_project_discounts.card_paymethod_id#">
					</cfquery>
						<cfset paymethod_name_ = get_pay_method.card_no>
					<cfelse>
						<cfset paymethod_name_= ''>
					</cfif>
					
				</div>
				<div class="col col-4 col-md-4 col-sm-6 col-xs-12" type="column" index="2" sort="true">	
					<cfsavecontent variable="header_"><cf_get_lang dictionary_id='58516.Ödeme YÖntemi'></cfsavecontent>
					<div class="form-group" id="item-paymethod_name">
						<label class="col col-5 col-md-5 col-sm-5 col-xs-12"><cf_get_lang dictionary_id='58516.Ödeme YÖntemi'></label>
						<div class="col col-7 col-md-7 col-sm-7 col-xs-12">
							<div class="input-group">
								<input type="hidden" name="paymethod_id" id="paymethod_id" value="<cfoutput>#get_project_discounts.paymethod_id#</cfoutput>">
								<input type="hidden" name="card_paymethod_id" id="card_paymethod_id" value="<cfoutput>#get_project_discounts.card_paymethod_id#</cfoutput>">
								<input type="text" name="paymethod_name" id="paymethod_name" value="<cfoutput>#paymethod_name_#</cfoutput>">
								<span class="input-group-addon icon-ellipsis btnPoniter" href="javascript://" onClick="windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_paymethods&field_id=project_discounts_.paymethod_id&field_name=project_discounts_.paymethod_name&field_card_payment_id=project_discounts_.card_paymethod_id&field_card_payment_name=project_discounts_.paymethod_name</cfoutput>','list');"></span>
							</div>
						</div>
					</div>
					<cfsavecontent variable="header_"><cf_get_lang dictionary_id='58053.Baslangic Tarihi'></cfsavecontent>
					<div class="form-group" id="item-start_date">
						<label class="col col-5 col-md-5 col-sm-5 col-xs-12"><cf_get_lang dictionary_id='58053.Baslangic Tarihi'>*</label>
						<div class="col col-7 col-md-7 col-sm-7 col-xs-12">
							<div class="input-group">
								<cfsavecontent variable="message"><cf_get_lang dictionary_id='57738.Baslangic Tarihi girmelisiniz'></cfsavecontent>
								<cfif len(get_project_discounts.finish_date)>
									<cfset temp_start_date=dateformat(get_project_discounts.start_date,dateformat_style)>
								<cfelse>
									<cfset temp_start_date=''>
								</cfif>
								<cfinput type="text" name="start_date" value="#temp_start_date#" maxlength="10" validate="#validate_style#" message="#message#" required="yes" >
								<span class="input-group-addon"><cf_wrk_date_image date_field="start_date"></span>
							</div>
						</div>
					</div>
					<cfsavecontent variable="header_"><cf_get_lang dictionary_id='57700.Bitiş Tarihi'></cfsavecontent>
					<div class="form-group" id="item-finish_date">
						<label class="col col-5 col-md-5 col-sm-5 col-xs-12"><cf_get_lang dictionary_id='57700.Bitiş Tarihi'>*</label>
						<div class="col col-7 col-md-7 col-sm-7 col-xs-12">
							<div class="input-group">
								<cfsavecontent variable="message"><cf_get_lang dictionary_id='58491.Bitiş Tarihi girmelisiniz'>!</cfsavecontent>
								<cfif len(get_project_discounts.finish_date)>
									<cfset temp_finish_date=dateformat(get_project_discounts.finish_date,dateformat_style)>
								<cfelse>
									<cfset temp_finish_date=''>
								</cfif>
								<cfinput type="text" name="finish_date" value="#temp_finish_date#" maxlength="10" validate="#validate_style#" message="#message#" >
								<span class="input-group-addon"><cf_wrk_date_image date_field="finish_date"></span>
							</div>
						</div>
					</div>	
					<cfsavecontent variable="header_"><cf_get_lang dictionary_id='57641.İndirim'>1 %</cfsavecontent>
					<div class="form-group" id="item-discount1">
						<label class="col col-5 col-md-5 col-sm-5 col-xs-12"><cf_get_lang dictionary_id='57641.İndirim'>1 %</label>
						<div class="col col-7 col-md-7 col-sm-7 col-xs-12">
							<input type="text" name="discount1" id="discount1"class="moneybox" value="<cfif len(get_project_discounts.discount_1)><cfoutput>#TLFormat(get_project_discounts.discount_1)#</cfoutput></cfif>" maxlength="5" onKeyUp="return(FormatCurrency(this,event));">
						</div>
					</div>	
					<cfsavecontent variable="header_"><cf_get_lang dictionary_id='57641.İndirim'>2 %</cfsavecontent>
					<div class="form-group" id="item-discount2">
						<label class="col col-5 col-md-5 col-sm-5 col-xs-12"><cf_get_lang dictionary_id='57641.İndirim'>2 %</label>
						<div class="col col-7 col-md-7 col-sm-7 col-xs-12">
							<input type="text" name="discount2" id="discount2"class="moneybox" value="<cfif len(get_project_discounts.discount_2)><cfoutput>#TLFormat(get_project_discounts.discount_2)#</cfoutput></cfif>" maxlength="5" onKeyUp="return(FormatCurrency(this,event));">
						</div>
					</div>	
					<cfsavecontent variable="header_"><cf_get_lang dictionary_id='57641.İndirim'>3 %</cfsavecontent>
					<div class="form-group" id="item-discount3">
						<label class="col col-5 col-md-5 col-sm-5 col-xs-12"><cf_get_lang dictionary_id='57641.İndirim'>3 %</label>
						<div class="col col-7 col-md-7 col-sm-7 col-xs-12">
								<input type="text" name="discount3" id="discount3"class="moneybox" value="<cfif len(get_project_discounts.discount_3)><cfoutput>#TLFormat(get_project_discounts.discount_3)#</cfoutput></cfif>" maxlength="5" onKeyUp="return(FormatCurrency(this,event));">
						</div>
					</div>	
						<cfsavecontent variable="header_"><cf_get_lang dictionary_id='57641.İndirim'>4 %</cfsavecontent>
						<div class="form-group" id="item-discount4">
							<label class="col col-5 col-md-5 col-sm-5 col-xs-12"><cf_get_lang dictionary_id='57641.İndirim'>4 %</label>
							<div class="col col-7 col-md-7 col-sm-7 col-xs-12"><input type="text" name="discount4" id="discount4"class="moneybox" value="<cfif len(get_project_discounts.discount_4)><cfoutput>#TLFormat(get_project_discounts.discount_4)#</cfoutput></cfif>" maxlength="5" onKeyUp="return(FormatCurrency(this,event));">
						</div>
					</div>	
					<cfsavecontent variable="header_"><cf_get_lang dictionary_id='57641.İndirim'>5 %</cfsavecontent>
					<div class="form-group" id="item-discount5">
						<label class="col col-5 col-md-5 col-sm-5 col-xs-12"><cf_get_lang dictionary_id='57641.İndirim'>5 %</label>
						<div class="col col-7 col-md-7 col-sm-7 col-xs-12">
							<input type="text" name="discount5" id="discount5"class="moneybox" value="<cfif len(get_project_discounts.discount_5)><cfoutput>#TLFormat(get_project_discounts.discount_5)#</cfoutput></cfif>" maxlength="5" onKeyUp="return(FormatCurrency(this,event));">
						</div>
					</div>
				</div>		            
				<div class="col col-4 col-md-4 col-sm-6 col-xs-12" type="column" index="3" sort="true">
					<cfsavecontent variable="header_"><cf_get_lang dictionary_id='38466.Risk Kontrolu'></cfsavecontent>
					<div class="form-group" id="item-check_risk_limit">
						<label class="col col-12 col-md-12 col-sm-12 col-xs-12"><input type="checkbox" value="1" name="check_risk_limit" id="check_risk_limit" <cfif not (len(get_project_discounts.IS_CHECK_RISK) and get_project_discounts.IS_CHECK_RISK eq 0)>checked</cfif>><cf_get_lang dictionary_id='38466.Risk Kontrolu'></label>
					</div>
					<cfsavecontent variable="header_"><cf_get_lang dictionary_id='38467.Bağlantı Bakiye Kontrolü'></cfsavecontent>
					<div class="form-group" id="item-check_prj_risk_limit">   
						<label class="col col-12 col-md-12 col-sm-12 col-xs-12"><input type="checkbox" value="1" name="check_prj_risk_limit" id="check_prj_risk_limit" <cfif not (len(get_project_discounts.IS_CHECK_PRJ_LIMIT) and get_project_discounts.IS_CHECK_PRJ_LIMIT eq 0)>checked</cfif>><cf_get_lang dictionary_id='38467.Bağlantı Bakiye Kontrolü'></label>
					</div>
					<cfsavecontent variable="header_"><cf_get_lang dictionary_id='38468.Ürün Kontrolü'></cfsavecontent>
					<div class="form-group" id="item-check_prj_proudcts">  
						<label class="col col-12 col-md-12 col-sm-12 col-xs-12"><input type="checkbox" value="1" name="check_prj_proudcts" id="check_prj_proudcts" <cfif not (len(get_project_discounts.IS_CHECK_PRJ_PRODUCT) and get_project_discounts.IS_CHECK_PRJ_PRODUCT eq 0)>checked</cfif>><cf_get_lang dictionary_id='38468.Ürün Kontrolü'></label>
					</div>
					<cfsavecontent variable="header_"><cf_get_lang dictionary_id='38469.Bağlantı Üye Kontrolü'></cfsavecontent>
					<div class="form-group" id="item-check_prj_member">   
						<label class="col col-12 col-md-12 col-sm-12 col-xs-12"><input type="checkbox" value="1" name="check_prj_member" id="check_prj_member" <cfif not (len(get_project_discounts.IS_CHECK_PRJ_MEMBER) and get_project_discounts.IS_CHECK_PRJ_MEMBER eq 0)>checked</cfif>><cf_get_lang dictionary_id='38469.Bağlantı Üye Kontrolü'></label>
					</div>
					<cfsavecontent variable="header_"><cf_get_lang dictionary_id='38470.Fiyat Listesi Kontrolu'></cfsavecontent>
					<div class="form-group" id="item-check_prj_price_cat_">   
						<label class="col col-12 col-md-12 col-sm-12 col-xs-12"><input type="checkbox" value="1" name="check_prj_price_cat_" id="check_prj_price_cat_" <cfif not (len(get_project_discounts.IS_CHECK_PRJ_PRICE_CAT) and get_project_discounts.IS_CHECK_PRJ_PRICE_CAT eq 0)>checked</cfif>><cf_get_lang dictionary_id='38470.Fiyat Listesi Kontrolu'></label>
					</div>
					
				</div>	
				<div class="col col-4 col-md-4 col-sm-6 col-xs-12" type="column" index="4" sort="true" id="ccddee">	
					<cf_grid_list sort="0">
						<thead>
							<input name="record_num" id="record_num" type="hidden" value="<cfif len(product_id_list)><cfoutput>#listlen(product_id_list)#</cfoutput><cfelse>0</cfif>">
							<tr>
								<th width="20"><a href="javascript://" title="<cf_get_lang dictionary_id='57582.Ekle'>" onClick="add_row();"><i class="fa fa-plus"></i></a></th>
								<th width="50"><cf_get_lang dictionary_id='58942.Ürün Listesi'></th>
							</tr>
						</thead>
						<tbody name="table1" id="table1">
							<cfoutput>
								<cfloop list="#product_id_list#" index="pro_ii">
									<cfset list_currentrow=listfind(product_id_list,pro_ii)>
									<input  type="hidden" name="row_kontrol#list_currentrow#" id="row_kontrol#list_currentrow#" value="1">
									<tr id="frm_row#list_currentrow#">
										<td style="cursor:pointer"><a style="cursor:pointer" onclick="sil(#list_currentrow#);"><i class="fa fa-minus"></i></a></td>
										<td>
											<div class="form_group"> 
												<div class="input-group">
													<input type="hidden" name="product_id#list_currentrow#" id="product_id#list_currentrow#" value="#pro_ii#" >
													<input type="text" name="product_name#list_currentrow#"  id="product_name#list_currentrow#" value="#listgetat(product_name_list,listfind(product_id_list,pro_ii))#">
													<span class="input-group-addon icon-ellipsis btnPoniter" href="javascript://" onclick="windowopen('#request.self#?fuseaction=objects.popup_products_only&product_id=project_discounts_.product_id#list_currentrow#&field_name=project_discounts_.product_name#list_currentrow#','list');"></span>
												</div>
											</div>	
										</td>    
									</tr>
								</cfloop>
							</cfoutput>
						</tbody>
					</cf_grid_list>
				</div>
				
			</cf_box_elements>
			<div class="ui-form-list-btn">
				<div class="col col-6 col-md-6 col-sm-6 col-xs-12">
					<cfif get_project_discounts.recordcount>
						<cfif len(get_project_discounts.record_emp)>
							<cf_record_info query_name="get_project_discounts">
						<!--- <cf_get_lang dictionary_id='57891.Güncelleyen'> : <cfoutput>#get_emp_info(get_project_discounts.record_emp,0,0)# - #dateformat(date_add('h',session.ep.time_zone,get_project_discounts.record_date),dateformat_style)# #timeformat(date_add('h',session.ep.time_zone,get_project_discounts.record_date),timeformat_style)#</cfoutput> --->
						</cfif>
					</cfif>
				</div>
				<div class="col col-6 col-md-6 col-sm-6 col-xs-12">
					<cfif get_project_discounts.recordcount>
						<cf_workcube_buttons type_format="1" is_upd='1' is_delete='0' add_function='kontrol()'>
						<!--- 
						history_table_list='PROJECT_DISCOUNTS,PROJECT_DISCOUNT_CONDITIONS' history_datasource_list='dsn3,dsn3' history_identy='PRO_DISCOUNT_ID' history_action_id='#get_project_discounts.PRO_DISCOUNT_ID#' 
						Bu alan history kayıtlarının atılmasında problem yarattığı için kaldırıldı. Direkt query sayfasından HISTORY kaydı atılacaktır MT:26112014 6 aya silinebilir 
						--->
					<cfelse>
						<cf_workcube_buttons type_format="1" is_upd='0' add_function='kontrol()'>
					</cfif>
				</div>
			</div>
		</cfform>
	</cf_box>
</div>
<script type="text/javascript">
<cfif listlen(product_id_list)>
	row_count='<cfoutput>#listlen(product_id_list)#</cfoutput>'; //urun satır sayısı
<cfelse>
	row_count=0; //urun satır sayısı
</cfif>
function kontrol()
{
	if(document.project_discounts_.discount1.value=='' && document.project_discounts_.discount2.value=='' && document.project_discounts_.discount3.value=='' && document.project_discounts_.discount4.value=='' && document.project_discounts_.discount5.value=='')
	{
		alert("<cf_get_lang dictionary_id='57471.Eksik Veri'> : <cf_get_lang dictionary_id='38190.İskonto Oranı'>");
		return false;
	}
	var is_prod_cat_selected=0;
	var is_prod_brand_selected=0;
	var is_prod_selected=0;
	for(kk=0;kk<document.project_discounts_.product_cat.length; kk++)
	{
		if(document.project_discounts_.product_cat[kk].selected && document.project_discounts_.product_cat.options[kk].value.length!='')
		{
			is_prod_cat_selected=1;
			break;
		}
	}
	for(tt=0;tt<document.project_discounts_.product_brands.length; tt++)
	{
		if(document.project_discounts_.product_brands[tt].selected && document.project_discounts_.product_brands.options[tt].value.length!='')
		{
			is_prod_brand_selected=1;
			break;
		}
	}
	for(ii=0;ii<=document.project_discounts_.record_num.value;ii++)
	{
		if(eval('document.project_discounts_.row_kontrol'+ii)!=undefined && eval('document.project_discounts_.row_kontrol'+ii).value==1 && eval('document.project_discounts_.product_id'+ii).value !='' && eval('document.project_discounts_.product_name'+ii).value !='')
		{
			is_prod_selected=1;
			break;
		}
	}
	if(is_prod_brand_selected==0 && is_prod_cat_selected==0 && is_prod_selected==0)
	{
		alert("<cf_get_lang dictionary_id='58194.Zorunlu Alan'> : <cf_get_lang dictionary_id='57657.Ürün'>-<cf_get_lang dictionary_id='58847.Marka'>-<cf_get_lang dictionary_id='57486.Kategori'>");
		return false;
	}
	if(document.project_discounts_.start_date.value.length > 0 && document.project_discounts_.finish_date.value.length > 0)
	{
		if(date_check(document.project_discounts_.start_date,document.project_discounts_.finish_date,"<cf_get_lang dictionary_id ='36063.Bitis Tarihi Baslangic Tarihinden Kucuk'> !"))
			return unformat_fields();
		else
			return false;
	}
	else
		return unformat_fields();
}

function unformat_fields()
{
	discount1 = filterNum(project_discounts_.discount1.value);
	discount2 = filterNum(project_discounts_.discount2.value);
	discount3 = filterNum(project_discounts_.discount3.value);
	discount4 = filterNum(project_discounts_.discount4.value);
	discount5 = filterNum(project_discounts_.discount5.value);

	if(discount1 > 100 || discount1 < 0){alert("<cf_get_lang dictionary_id ='37744.İskonto 0 ile 100 arasında olmalıdır'>!");return false;}
	if(discount2 > 100 || discount2 < 0){alert("<cf_get_lang dictionary_id ='37744.İskonto 0 ile 100 arasında olmalıdır'>!");return false;}
	if(discount3 > 100 || discount3 < 0){alert("<cf_get_lang dictionary_id ='37744.İskonto 0 ile 100 arasında olmalıdır'>!");return false;}
	if(discount4 > 100 || discount4 < 0){alert("<cf_get_lang dictionary_id ='37744.İskonto 0 ile 100 arasında olmalıdır'>!");return false;}
	if(discount5 > 100 || discount5 < 0){alert("<cf_get_lang dictionary_id ='37744.İskonto 0 ile 100 arasında olmalıdır'>!");return false;}
	return true;
}
function sil(sy)
{
	var my_element=eval("project_discounts_.row_kontrol"+sy);
	my_element.value=0;

	var my_element=eval("frm_row"+sy);
	my_element.style.display="none";
}
function add_row()
{
	row_count++;
	var newRow;
	var newCell;
	newRow = document.getElementById("table1").insertRow(document.getElementById("table1").rows.length);
	newRow.setAttribute("name","frm_row" + row_count);
	newRow.setAttribute("id","frm_row" + row_count);		
	newRow.setAttribute("NAME","frm_row" + row_count);
	newRow.setAttribute("ID","frm_row" + row_count);	
	document.project_discounts_.record_num.value=row_count;
	newCell = newRow.insertCell(newRow.cells.length);
	newCell.innerHTML = '<a style=" cursor:pointer" onclick="sil(' + row_count + ');"  ><i class="fa fa-minus"></i></a>';				
	newCell = newRow.insertCell(newRow.cells.length);
	newCell.innerHTML = '<div class="form-group"><div class="input-group"><input  type="hidden"  value="1"  name="row_kontrol' + row_count +'" ><input  type="hidden"  name="product_id' + row_count +'" ><input type="text" name="product_name' + row_count + '"><span class="input-group-addon icon-ellipsis" href="javascript://" onClick="pencere_pos(' + row_count + ');"></span></div></div>';//class="boxtext"
}
function pencere_pos(no)
{
	windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_products_only&product_id=project_discounts_.product_id' + no + '&field_name=project_discounts_.product_name' + no,'list'); /*&process=purchase_contract  var_=purchase_contr_cat_premium&*/
}
</script>
