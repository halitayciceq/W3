
<cfsetting showdebugoutput="no">
<cf_xml_page_edit fuseact ="sales.list_order" default_value="1">
<cf_get_lang_set module_name="sales">
<cfparam name="attributes.product_name" default="">
<cfparam name="attributes.product_id" default="">
<cfparam name="attributes.short_code_id" default="">
<cfparam name="attributes.short_code_name" default="">
<cfparam name="attributes.prod_cat" default="">
<cfparam name="attributes.start_date" default="">
<cfparam name="attributes.finish_date" default="">
<cfif is_show_sales_emp eq 1>
	<cfparam name="attributes.order_employee" default="#session.ep.name# #session.ep.surname#">
	<cfparam name="attributes.order_employee_id" default="#session.ep.userid#">
<cfelse>
	<cfparam name="attributes.order_employee" default="">
	<cfparam name="attributes.order_employee_id" default="">
</cfif>
<cfparam name="attributes.sales_member_name" default="">
<cfparam name="attributes.sales_member_id" default="">
<cfparam name="attributes.sales_member_type" default="">
<cfparam name="attributes.order_stage" default="">
<cfparam name="attributes.sale_add_option" default="">
<cfparam name="attributes.department_id" default="">
<cfparam name="attributes.location_id" default="">
<cfparam name="attributes.location_name" default="">
<cfif xml_listing_type eq 1>
<cfparam name="attributes.listing_type" default="2">
<cfelse>
<cfparam name="attributes.listing_type" default="">
</cfif>
<cfparam name="attributes.quantity" default="">
<cfparam name="attributes.unit" default="">
<cfparam name="attributes.project_id" default="">
<cfparam name="attributes.project_head" default="">
<cfparam name="attributes.subscription_id" default="">
<cfparam name="attributes.subscription_no" default="">
<cfparam name="attributes.brand_id" default="">
<cfparam name="attributes.brand_name" default="">
<cfparam name="attributes.sort_type" default="4">
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.keyword_orderno" default="">
<cfparam name="attributes.filter_branch_id" default="">
<cfparam name="attributes.zone_id" default="">
<cfparam name="attributes.sales_county" default="">
<cfparam name="attributes.record_emp_id" default="">
<cfparam name="attributes.record_cons_id" default="">
<cfparam name="attributes.record_part_id" default="">
<cfparam name="attributes.record_name" default="">
<cfparam name="attributes.card_paymethod_id" default="">
<cfparam name="attributes.paymethod_id" default="">
<cfparam name="attributes.paymethod" default="">
<cfparam name="attributes.irsaliye_fatura" default="">
<cfparam name="attributes.use_efatura" default="">

<cfif listlen(attributes.fuseaction,'.') eq 2 and listgetat(attributes.fuseaction,2,'.') is 'list_order_instalment'>
	<cfset attributes.is_instalment = 1>
</cfif>
<cfif isdefined("attributes.start_date") and isdate(attributes.start_date)>
	<cf_date tarih="attributes.start_date">
<cfelse>
	<cfif session.ep.our_company_info.unconditional_list>
		<cfset attributes.start_date=''>
	<cfelse>
		<cfset attributes.start_date = wrk_get_today()>
	</cfif>
</cfif>
<cfif isdefined("attributes.finish_date") and isdate(attributes.finish_date)>
	<cf_date tarih="attributes.finish_date">
<cfelse>
	<cfif session.ep.our_company_info.unconditional_list>
		<cfset attributes.finish_date=''>
	<cfelse>
		<cfset attributes.finish_date = date_add('ww',1,attributes.start_date)>
	</cfif>
</cfif>
<cfparam name="attributes.page" default="1">
<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'> 
<cfset attributes.startrow = ((attributes.page-1)*attributes.maxrows) + 1 >
<cfif isdefined("attributes.form_varmi")>

	<cfset arama_yapilmali = 0>
	<cfscript>
	get_order_list_action = createObject("component", "V16.sales.cfc.get_order_list");
	get_order_list_action.dsn3 = dsn3;
	get_order_list_action.dsn_alias = dsn_alias;
	get_order_list = get_order_list_action.get_order_list_fnc
		(
			listing_type : '#IIf(IsDefined("attributes.listing_type"),"attributes.listing_type",DE(""))#',
			sort_type : '#IIf(IsDefined("attributes.sort_type"),"attributes.sort_type",DE("4"))#',
			x_control_ims : '#IIf(IsDefined("x_control_ims"),"x_control_ims",DE("0"))#',
			prod_cat : '#IIf(IsDefined("attributes.prod_cat"),"attributes.prod_cat",DE(""))#',
			product_name : '#IIf(IsDefined("attributes.product_name"),"attributes.product_name",DE(""))#',
			product_id : '#IIf(IsDefined("attributes.product_id"),"attributes.product_id",DE(""))#',
			currency_id : '#IIf(IsDefined("attributes.currency_id"),"attributes.currency_id",DE(""))#',
			employee_id : '#IIf(IsDefined("attributes.employee_id"),"attributes.employee_id",DE(""))#',
			employee : '#IIf(IsDefined("attributes.employee"),"attributes.employee",DE(""))#',
			product_manager : '#IIf(IsDefined("attributes.product_manager"),"attributes.product_manager",DE(""))#',
			product_manager_name : '#IIf(IsDefined("attributes.product_manager_name"),"attributes.product_manager_name",DE(""))#',
			order_employee_id : '#IIf(IsDefined("attributes.order_employee_id"),"attributes.order_employee_id",DE(""))#',
			order_employee : '#IIf(IsDefined("attributes.order_employee"),"attributes.order_employee",DE(""))#',
			brand_name : '#IIf(IsDefined("attributes.brand_name"),"attributes.brand_name",DE(""))#',
			brand_id : '#IIf(IsDefined("attributes.brand_id"),"attributes.brand_id",DE(""))#',
			short_code_name : '#IIf(IsDefined("attributes.short_code_name"),"attributes.short_code_name",DE(""))#',
			short_code_id : '#IIf(IsDefined("attributes.short_code_id"),"attributes.short_code_id",DE(""))#',
			sales_departments : '#IIf(IsDefined("attributes.department_id"),"attributes.department_id",DE(""))##IIf(len(attributes.department_id),DE('-'),DE(""))##IIf(IsDefined("attributes.location_id"),"attributes.location_id",DE(""))#',
			status : '#IIf(IsDefined("attributes.status"),"attributes.status",DE(""))#',
			subscription_no : '#IIf(IsDefined("attributes.subscription_no"),"attributes.subscription_no",DE(""))#',
			subscription_id : '#IIf(IsDefined("attributes.subscription_id"),"attributes.subscription_id",DE(""))#',
			priority : '#IIf(IsDefined("attributes.priority"),"attributes.priority",DE(""))#',
			keyword : '#IIf(IsDefined("attributes.keyword"),"attributes.keyword",DE(""))#',
			keyword_orderno : '#IIf(IsDefined("attributes.keyword_orderno"),"attributes.keyword_orderno",DE(""))#',
			member_type : '#IIf(IsDefined("attributes.member_type"),"attributes.member_type",DE(""))#',
			member_name : '#IIf(IsDefined("attributes.member_name"),"attributes.member_name",DE(""))#',
			company_id : '#IIf(IsDefined("attributes.company_id"),"attributes.company_id",DE(""))#',
			consumer_id : '#IIf(IsDefined("attributes.consumer_id"),"attributes.consumer_id",DE(""))#',
			sales_member_type : '#IIf(IsDefined("attributes.sales_member_type"),"attributes.sales_member_type",DE(""))#',
			sales_member_name : '#IIf(IsDefined("attributes.sales_member_name"),"attributes.sales_member_name",DE(""))#',
			sales_member_id : '#IIf(IsDefined("attributes.sales_member_id"),"attributes.sales_member_id",DE(""))#',
			start_date : '#IIf(IsDefined("attributes.start_date"),"attributes.start_date",DE(""))#',
			finish_date : '#IIf(IsDefined("attributes.finish_date"),"attributes.finish_date",DE(""))#',
			order_stage : '#IIf(IsDefined("attributes.order_stage"),"attributes.order_stage",DE(""))#',
			sales_county : '#IIf(IsDefined("attributes.sales_county"),"attributes.sales_county",DE(""))#',
			sale_add_option : '#IIf(IsDefined("attributes.sale_add_option"),"attributes.sale_add_option",DE(""))#',
			filter_branch_id : '#IIf(IsDefined("attributes.filter_branch_id"),"attributes.filter_branch_id",DE(""))#',
			zone_id : '#IIf(IsDefined("attributes.zone_id"),"attributes.zone_id",DE(""))#',
			record_emp_id : '#IIf(IsDefined("attributes.record_emp_id"),"attributes.record_emp_id",DE(""))#',
			record_cons_id : '#IIf(IsDefined("attributes.record_cons_id"),"attributes.record_cons_id",DE(""))#',
			record_part_id : '#IIf(IsDefined("attributes.record_part_id"),"attributes.record_part_id",DE(""))#',
			record_name : '#IIf(IsDefined("attributes.record_name"),"attributes.record_name",DE(""))#',
			project_head : '#IIf(IsDefined("attributes.project_head"),"attributes.project_head",DE(""))#',
			project_id : '#IIf(IsDefined("attributes.project_id"),"attributes.project_id",DE(""))#',
			module_name : '#fusebox.circuit#',
			is_instalment : '#IIf(IsDefined("attributes.is_instalment"),"attributes.is_instalment",DE("0"))#',
			card_paymethod_id : '#attributes.card_paymethod_id#',
			paymethod_id : '#attributes.paymethod_id#',
			paymethod : '#attributes.paymethod#',
			startrow : '#attributes.startrow#',
			maxrows : '#attributes.maxrows#',
			dsn2_alias : '#dsn2_alias#',
			irsaliye_fatura : '#IIf(IsDefined("attributes.irsaliye_fatura"),"attributes.irsaliye_fatura",DE(""))#',
			related_orders : '#IIf(IsDefined("attributes.related_orders"),"attributes.related_orders",DE(""))#',
			use_efatura : '#IIf(IsDefined("attributes.use_efatura"),"attributes.use_efatura",DE(""))#'
		);
	</cfscript>
<cfelse>
	<cfset arama_yapilmali = 1>
	<cfset get_order_list.recordcount = 0>
</cfif>
<cfscript>
	if (isdefined("attributes.keyword")) url_str = "keyword=#attributes.keyword#"; else attributes.keyword = "";
	if (isdefined("attributes.keyword_orderno")) url_str = "#url_str#&keyword_orderno=#attributes.keyword_orderno#"; else attributes.keyword_orderno = "";
	if (isdefined("attributes.currency_id")) url_str = "#url_str#&currency_id=#attributes.currency_id#"; else attributes.currency_id = "";
	if (isdefined("attributes.status"))	url_str = "#url_str#&status=#attributes.status#"; else attributes.status = 1;
</cfscript>
<cfinclude template="../query/get_priorities.cfm">
<cfif isdefined("get_order_list.query_count")>
	<cfparam name="attributes.totalrecords" default="#get_order_list.query_count#">
<cfelse>
	<cfparam name="attributes.totalrecords" default="#get_order_list.recordcount#">
</cfif>

<cfquery name="get_process_type" datasource="#DSN#">
	SELECT
		PTR.STAGE,
		PTR.PROCESS_ROW_ID,
		PT.PROCESS_NAME,
		PT.PROCESS_ID
	FROM
		PROCESS_TYPE_ROWS PTR,
		PROCESS_TYPE_OUR_COMPANY PTO,
		PROCESS_TYPE PT
	WHERE
		PT.IS_ACTIVE = 1 AND
		PT.PROCESS_ID = PTR.PROCESS_ID AND
		PT.PROCESS_ID = PTO.PROCESS_ID AND
		PTO.OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#"> AND
		<cfif listlen(attributes.fuseaction,'.') eq 2 and listgetat(attributes.fuseaction,2,'.') is 'list_order_instalment'>
			PT.FACTION LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#listfirst(attributes.fuseaction,'.')#.list_order_instalment%">
		<cfelse>
			PT.FACTION LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#listfirst(attributes.fuseaction,'.')#.list_order%">
			AND PT.FACTION NOT LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#listfirst(attributes.fuseaction,'.')#.list_order_instalment%">
		</cfif>
	ORDER BY
		PT.PROCESS_NAME,
		PTR.LINE_NUMBER
</cfquery>
<cfif isdefined("attributes.is_instalment")>
	<cfset head = getlang(796,'Taksitli Satışlar',58208)>
<cfelse>
	<cfset head = getlang(6,'Satış Siparişleri',58207)>
</cfif>

<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	
	<cf_box>
		<cfform name="order_form" action="#request.self#?fuseaction=#url.fuseaction#">
			<cf_box_search>
				<cfif isdefined("attributes.is_instalment") and attributes.is_instalment eq 1>
					<input name="is_instalment" id="is_instalment" value="1" type="hidden">
				</cfif>
				<input name="form_varmi" id="form_varmi" value="1" type="hidden">
				<cfoutput>
				<div class="form-group">
					<div class="input-group">
						<input type="text" name="keyword" id="keyword" placeholder="<cf_get_lang dictionary_id='57460.Filtre'>" value="#attributes.keyword#" maxlength="50">
					</div>
				</div>
				<div class="form-group">
					<div class="input-group">
						<input type="text" name="keyword_orderno" id="keyword_orderno" placeholder="<cf_get_lang dictionary_id='66478.Sertifika No'>" value="#attributes.keyword_orderno#" maxlength="50">
					</div>
				</div>
				<div class="form-group">
					<div class="input-group">
						<select name="currency_id" id="currency_id">
							<option value=""><cf_get_lang dictionary_id='57482.Asama'></option>
							<option value="-7" <cfif attributes.currency_id eq -7>selected</cfif>><cf_get_lang dictionary_id='29748.Eksik Teslimat'></option>
							<option value="-8" <cfif attributes.currency_id eq -8>selected</cfif>><cf_get_lang dictionary_id='29749.Fazla Teslimat'></option>
							<option value="-6" <cfif attributes.currency_id eq -6>selected</cfif>><cf_get_lang dictionary_id='58761.Sevk'></option>
							<option value="-5" <cfif attributes.currency_id eq -5>selected</cfif>><cf_get_lang dictionary_id='57456.retim'></option>
							<option value="-4" <cfif attributes.currency_id eq -4>selected</cfif>><cf_get_lang dictionary_id='29747.Kismi Uretim'></option>
							<option value="-3" <cfif attributes.currency_id eq -3>selected</cfif>><cf_get_lang dictionary_id='29746.Kapatildi'></option>
							<option value="-2" <cfif attributes.currency_id eq -2>selected</cfif>><cf_get_lang dictionary_id='29745.Tedarik'></option>
							<option value="-1" <cfif attributes.currency_id eq -1>selected</cfif>><cf_get_lang dictionary_id='58717.Aik'></option>
							<option value="-9" <cfif attributes.currency_id eq -9>selected</cfif>><cf_get_lang dictionary_id='58506.Iptal'></option>
							<option value="-10" <cfif attributes.currency_id eq -10>selected</cfif>><cf_get_lang dictionary_id='40876.Kapatildi(Manuel)'></option>
						</select>
					</div>
				</div>
				<div class="form-group">
					<div class="input-group">
						<select name="listing_type" id="listing_type">
							<option value=""><cf_get_lang dictionary_id='40170.Listeleme Seçenekleri'></option>
							<option value="1" <cfif attributes.listing_type eq 1>selected</cfif>><cf_get_lang dictionary_id='57660.Belge Bazinda'></option>
							<option value="2" <cfif attributes.listing_type eq 2>selected</cfif>><cf_get_lang dictionary_id='29539.Satir Bazinda'></option>
						</select>    
					</div>
				</div>
				<div class="form-group">
					<div class="input-group">
						<select name="sort_type" id="sort_type">
							<option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
							<option value="1" <cfif attributes.sort_type eq 1>selected</cfif>><cf_get_lang dictionary_id='40843.Teslim Tarihine Gre Artan'></option>
							<option value="2" <cfif attributes.sort_type eq 2>selected</cfif>><cf_get_lang dictionary_id='40844.Teslim Tarihine Gre Azalan'></option>
							<option value="3" <cfif attributes.sort_type eq 3>selected</cfif>><cf_get_lang dictionary_id='40845.Siparis Tarihine Gre Artan'></option>
							<option value="4" <cfif attributes.sort_type eq 4>selected</cfif>><cf_get_lang dictionary_id='40846.Siparis Tarihine Gre Azalan'></option>
							<option value="5" <cfif attributes.sort_type eq 5>selected</cfif>><cf_get_lang dictionary_id='40918.Görevliye Göre Artan'></option>
							<option value="6" <cfif attributes.sort_type eq 6>selected</cfif>><cf_get_lang dictionary_id='40920.Görevliye Göre Azalan'></option>
							<option value="7" <cfif attributes.sort_type eq 7>selected</cfif>><cf_get_lang dictionary_id='40921.Projeye Göre Artan'></option>
							<option value="8" <cfif attributes.sort_type eq 8>selected</cfif>><cf_get_lang dictionary_id='40925.Projeye Göre Azalan'></option>
							<option value="9" <cfif attributes.sort_type eq 9>selected</cfif>><cf_get_lang dictionary_id='40971.Sipariş Noya Göre Artan'></option>
							<option value="10" <cfif attributes.sort_type eq 10>selected</cfif>><cf_get_lang dictionary_id='40975.Sipariş Noya  Göre Azalan'></option>
							<option value="11" <cfif attributes.sort_type eq 11>selected</cfif>><cf_get_lang dictionary_id='40930.Kaydedene Göre Artan'></option>
							<option value="12" <cfif attributes.sort_type eq 12>selected</cfif>><cf_get_lang dictionary_id='40931.Kaydedene Göre Azalan'></option>
							<option value="13" <cfif attributes.sort_type eq 13>selected</cfif>><cf_get_lang dictionary_id='40932.Tutara Göre Artan'></option>
							<option value="14" <cfif attributes.sort_type eq 14>selected</cfif>><cf_get_lang dictionary_id='40934.Tutara Göre Azalan'></option>
						</select>
					</div>
				</div>
				<div class="form-group">
					<div class="input-group">
						<select name="status" id="status">
							<option value=""><cf_get_lang dictionary_id='57708.Tümü'></option>
							<option value="0"<cfif isdefined('attributes.status') and (attributes.status eq 0)> selected</cfif>><cf_get_lang dictionary_id='57494.Pasif'></option>
							<option value="1"<cfif isdefined('attributes.status') and (attributes.status eq 1)> selected</cfif>><cf_get_lang dictionary_id='57493.Aktif'></option>
						</select>
					</div>
				</div>
				<div class="form-group">
					<div class="input-group small">
						<cfsavecontent variable="message"><cf_get_lang dictionary_id='57537.Sayi_Hatasi_Mesaj'></cfsavecontent>
						<cfinput type="text" name="maxrows" value="#attributes.maxrows#" required="yes" onKeyUp="isNumber(this)" validate="integer" range="1,999" message="#message#" maxlength="3">
					</div>
				</div> 
				<div class="form-group">
					<cf_wrk_search_button button_type="4" search_function='input_control()'>
					<cf_workcube_file_action pdf='1' mail='1' doc='1' print='1'>
				</div>
				<div class="form-group">
					<a class="ui-btn ui-btn-gray2" href="javascript://" id="sepet_in_sepet" name="sepet_in_sepet" onclick="openmodal()"><i class="fa fa-shopping-basket"></i></a>
				</div> 
				</cfoutput>    
			</cf_box_search>
			<cf_box_search_detail>
					<div class="col col-3 col-md-8 col-sm-12" type="column" sort="true" index="1">
						<div class="form-group" id="item-order_stage">	
							<label class="col col-12 col-md-12 col-sm-12 col-xs-12"><cf_get_lang dictionary_id='58859.Surec'></label>						
							<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
								<select name="order_stage" id="order_stage">
									<option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
									<cfoutput query="get_process_type" group="process_id">
										<optgroup label="#process_name#"></optgroup>
										<cfoutput>
										<option value="#get_process_type.process_row_id#" <cfif Len(attributes.order_stage) and attributes.order_stage eq get_process_type.process_row_id>selected</cfif>>&nbsp;&nbsp;&nbsp;#get_process_type.stage#</option>
										</cfoutput>
									</cfoutput>
								</select>         
							</div>
						</div>
						<div class="form-group" id="item-company_id">
							<label class="col col-12 col-md-12 col-sm-12 col-xs-12"><cf_get_lang dictionary_id='57519.Cari Hesap'></label>							
							<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
								<div class="input-group">
									<input type="hidden" name="consumer_id" id="consumer_id" value="<cfif isdefined("attributes.consumer_id")><cfoutput>#attributes.consumer_id#</cfoutput></cfif>">
									<input type="hidden" name="company_id" id="company_id" value="<cfif isdefined("attributes.company_id")><cfoutput>#attributes.company_id#</cfoutput></cfif>">
									<input type="hidden" name="member_type" id="member_type" value="<cfif isdefined("attributes.member_type")><cfoutput>#attributes.member_type#</cfoutput></cfif>">
									<input name="member_name" type="text" id="member_name" placeholder="<cfoutput>#getLang('main',107)#</cfoutput>" onfocus="AutoComplete_Create('member_name','MEMBER_NAME,MEMBER_PARTNER_NAME,MEMBER_CODE','MEMBER_NAME,MEMBER_PARTNER_NAME,MEMBER_CODE','get_member_autocomplete','\'1,2\'','CONSUMER_ID,COMPANY_ID,MEMBER_TYPE','consumer_id,company_id,member_type','','3','250');" value="<cfif isdefined("attributes.member_name") and len(attributes.member_name)><cfoutput>#attributes.member_name#</cfoutput></cfif>" autocomplete="off">
									<cfset str_linke_ait="&field_consumer=order_form.consumer_id&field_comp_id=order_form.company_id&field_member_name=order_form.member_name&field_type=order_form.member_type">
									<span class="input-group-addon btnPointer icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_all_pars<cfoutput>#str_linke_ait#<cfif session.ep.isBranchAuthorization>&is_store_module=1</cfif></cfoutput>&select_list=7,8&keyword='+encodeURIComponent(document.order_form.member_name.value));"></span>
								</div>
							</div>
						</div>
						<div class="form-group" id="item-prod_cat">						
							<label class="col col-12 col-md-12 col-sm-12 col-xs-12"><cf_get_lang dictionary_id='29401.Ürün Kategorileri'></label>
							<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
								<cfinclude template="../query/get_product_cats.cfm">
								<select name="prod_cat" id="prod_cat">
									<option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
									<cfoutput query="GET_PRODUCT_CATS">
										<cfif listlen(hierarchy,".") lte 3>
											<option value="#hierarchy#"<cfif (attributes.prod_cat eq hierarchy) and len(attributes.prod_cat) eq len(hierarchy)> selected</cfif>>#hierarchy#-#product_cat#</option>
										</cfif>
									</cfoutput>
								</select>                       
							</div>
						</div>
						<div class="form-group" id="item-product_id">
							<label class="col col-12 col-md-12 col-sm-12 col-xs-12"><cf_get_lang dictionary_id='57657.Ürün'></label>						
							<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
								<div class="input-group">
									<input type="hidden" name="product_id" id="product_id" <cfif len(attributes.product_id) and len(attributes.product_name)>value="<cfoutput>#attributes.product_id#</cfoutput>"</cfif>>
									<input name="product_name" type="text" id="product_name" placeholder="<cfoutput><cf_get_lang dictionary_id='57657.Ürün'></cfoutput>" onfocus="AutoComplete_Create('product_name','PRODUCT_NAME','PRODUCT_NAME','get_product','0','PRODUCT_ID','product_id','','3','100');" value="<cfif len(attributes.product_id) and len(attributes.product_name)><cfoutput>#attributes.product_name#</cfoutput></cfif>" autocomplete="off">
									<span class="input-group-addon btnPointer icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_product_names&product_id=order_form.product_id&field_name=order_form.product_name&keyword='+encodeURIComponent(document.order_form.product_name.value));"></span>
								</div>
							</div>
						</div>
						<div class="form-group" id="item-brand_id">		
							<label class="col col-12 col-md-12 col-sm-12 col-xs-12"><cf_get_lang dictionary_id='58847.marka'></label>				
							<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
								<cf_wrkproductbrand
									compenent_name="getProductBrand"               
									boxwidth="240"
									boxheight="150"
									brand_id="#attributes.brand_id#">
							</div>
						</div>
						<div class="form-group" id="item-short_code_id">	
							<label class="col col-12 col-md-12 col-sm-12 col-xs-12"><cf_get_lang dictionary_id='58225.Model'></label>						
							<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
								<cf_wrkproductmodel
									returninputvalue="short_code_id,short_code_name"
									returnqueryvalue="MODEL_ID,MODEL_NAME"
									fieldname="short_code_name"
									boxwidth="240"
									fieldid="short_code_id"
									compenent_name="getProductModel"            
									model_id="#attributes.short_code_id#">
							</div>
						</div>
					</div>
					<div class="col col-3 col-md-8 col-sm-12" type="column" sort="true" index="2">
						<div class="form-group" id="item-start_date">
							<label class="col col-12 col-md-12 col-sm-12 col-xs-12"><cf_get_lang dictionary_id='58053.Başlangıç Tarihi'></label>
							<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
								<div class="input-group">
									<cfsavecontent variable="message"><cf_get_lang dictionary_id='1354.Baslangi Tarihi Kontrol Ediniz'></cfsavecontent>
									<cfif session.ep.our_company_info.unconditional_list>
										<cfsavecontent variable="place"><cf_get_lang dictionary_id='58053.Başlangıç Tarihi'></cfsavecontent>
										<cfinput type="text" name="start_date" id="start_date" placeholder="#place#" value="#dateformat(attributes.start_date,dateformat_style)#" validate="#validate_style#" maxlength="10" message="#message#">
									<cfelse>
										<cfsavecontent variable="place"><cf_get_lang dictionary_id='58053.Başlangıç Tarihi'></cfsavecontent>
										<cfinput type="text" name="start_date" id="start_date" placeholder="#place#" value="#dateformat(attributes.start_date,dateformat_style)#" validate="#validate_style#" maxlength="10" message="#message#">
									</cfif>
									<span class="input-group-addon"><cf_wrk_date_image date_field="start_date"></span>
									</div>
								</div>
							</div>
							<div class="form-group" id="item-finish_date">
								<label class="col col-12 col-md-12 col-sm-12 col-xs-12"><cf_get_lang dictionary_id='57700.Bitiş Tarihi'></label>
								<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
									<div class="input-group">
									<cfsavecontent variable="message"><cf_get_lang dictionary_id='58767.Bitis Tarihi Kontrol Ediniz'></cfsavecontent>
									<cfif session.ep.our_company_info.unconditional_list>
										<cfsavecontent variable="place2"><cf_get_lang dictionary_id='57700.Bitis Tarihi'></cfsavecontent>
										<cfinput type="text" name="finish_date" id="finish_date"  placeholder="#place2#" value="#dateformat(attributes.finish_date,dateformat_style)#" validate="#validate_style#" maxlength="10" message="#message#">
									<cfelse>
										<cfsavecontent variable="place2"><cf_get_lang dictionary_id='58767.Bitis Tarihi'></cfsavecontent>
										<cfinput type="text" name="finish_date" id="finish_date"  placeholder="#place2#" value="#dateformat(attributes.finish_date,dateformat_style)#" validate="#validate_style#" maxlength="10" message="#message#">
									</cfif>
									<span class="input-group-addon"><cf_wrk_date_image date_field="finish_date"></span>
								</div>
							</div>
						</div> 
						<div class="form-group" id="item-sales_departments">
							<label class="col col-12 col-md-12 col-sm-12 col-xs-12"><cf_get_lang dictionary_id='41184.Depo- Lokasyon'></label>			
							<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
								<cf_wrkdepartmentlocation 
									returninputvalue="location_name,department_id,location_id"
									returnqueryvalue="LOCATION_NAME,DEPARTMENT_ID,LOCATION_ID"
									fieldname="location_name"
									fieldid="location_id"
									department_fldid="department_id"
									department_id="#attributes.department_id#"
									location_name="#attributes.location_name#"
									location_id="#attributes.location_id#"
									user_level_control="#session.ep.OUR_COMPANY_INFO.IS_LOCATION_FOLLOW#"
									width="120">
							</div>
						</div>
						<div class="form-group" id="item-filter_branch_id">
							<label class="col col-12 col-md-12 col-sm-12 col-xs-12"><cf_get_lang dictionary_id='57453.Sube'></label>				
							<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
								<cfsavecontent variable="opt_value"><cf_get_lang dictionary_id='57734.Seçiniz'></cfsavecontent>
								<cf_wrkdepartmentbranch fieldid='filter_branch_id' is_branch='1' width='135' selected_value='#attributes.filter_branch_id#' option_value='#opt_value#'>
							</div>
						</div>
						<div class="form-group" id="item-priority">	
							<label class="col col-12 col-md-12 col-sm-12 col-xs-12"><cf_get_lang dictionary_id='57485.öncelik'></label>		
							<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
								<select name="priority" id="priority">
									<option value=""><cf_get_lang dictionary_id='57734.seçiniz'></option>
									<cfoutput query="get_priorities">
										<option value="#priority_id#" <cfif isDefined("attributes.priority") and attributes.priority eq priority_id>selected</cfif>>#priority#</option>
									</cfoutput>
								</select>          
							</div>
						</div>
						<div class="form-group" id="item-record_emp_id">
							<label class="col col-12 col-md-12 col-sm-12 col-xs-12"><cf_get_lang dictionary_id='57899.Kaydeden'></label>	
							<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
								<div class="input-group">
								<cfoutput>
									<input type="hidden" name="record_emp_id" id="record_emp_id" value="#attributes.record_emp_id#">
									<input type="hidden" name="record_cons_id" id="record_cons_id" value="#attributes.record_cons_id#">
									<input type="hidden" name="record_part_id" id="record_part_id" value="#attributes.record_part_id#">
									<input name="record_name" id="record_name" type="text" placeholder="<cfoutput><cf_get_lang dictionary_id='57899.Kaydeden'></cfoutput>" onfocus="AutoComplete_Create('record_name','MEMBER_NAME,MEMBER_PARTNER_NAME','MEMBER_PARTNER_NAME2,MEMBER_NAME2','get_member_autocomplete','\'1,2,3\',0,0,0','CONSUMER_ID,PARTNER_ID,EMPLOYEE_ID,MEMBER_NAME','record_cons_id,record_part_id,record_emp_id,record_name','','3','250');" value="#attributes.record_name#" autocomplete="off">
									<span class="input-group-addon btnPointer icon-ellipsis" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_pars&field_emp_id=order_form.record_emp_id&field_name=order_form.record_name&field_consumer=order_form.record_cons_id&field_partner=order_form.record_part_id<cfif session.ep.isBranchAuthorization>&is_store_module=1</cfif>&select_list=1,2,3');"></span>
								</cfoutput>
								</div>
							</div>
						</div>
					</div>
					<div class="col col-3 col-md-8 col-sm-12" type="column" sort="true" index="3">
						<div class="form-group" id="item-irsaliye_fatura">	
							<label class="col col-12 col-md-12 col-sm-12 col-xs-12"><cf_get_lang dictionary_id='40949.Sipariş Tipi'></label>								
							<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
								<select name="irsaliye_fatura" id="irsaliye_fatura">
									<option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
									<option value="1" <cfif attributes.irsaliye_fatura eq 1>selected</cfif>><cf_get_lang dictionary_id='45757.İrsaliyeleşen'></option>
									<option value="2" <cfif attributes.irsaliye_fatura eq 2>selected</cfif>><cf_get_lang dictionary_id='38569.Faturalaşan'></option>
									<option value="3" <cfif attributes.irsaliye_fatura eq 3>selected</cfif>><cf_get_lang dictionary_id='62534.İrsaliyeleşmeyen'></option>
								</select>          
							</div>
						</div>
						<cfif session.ep.our_company_info.is_efatura>
							<div class="form-group" id="item-use_efatura">
								<label class="col col-12 col-md-12 col-sm-12 col-xs-12"><cf_get_lang dictionary_id="29872.E-Fatura"></label>
								<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
									<select name="use_efatura" id="use_efatura">
										<option value=""><cf_get_lang dictionary_id="29872.E-Fatura"></option>
										<option value="1" <cfif attributes.use_efatura eq 1>selected="selected"</cfif>><cf_get_lang dictionary_id='29492.Kullanıyor'></option>
										<option value="0" <cfif attributes.use_efatura eq 0>selected="selected"</cfif>><cf_get_lang dictionary_id='29493.Kullanmıyor'></option>
									</select>
								</div>
							</div>
						</cfif>
						<div class="form-group" id="item-sales_member_id">						
							<label class="col col-12 col-md-12 col-sm-12 col-xs-12"><cf_get_lang dictionary_id='40904.Satis Ortagi'></label>			
							<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
								<div class="input-group">
									<input type="hidden" name="sales_member_id" id="sales_member_id" value="<cfoutput>#attributes.sales_member_id#</cfoutput>">
									<input type="hidden" name="sales_member_type" id="sales_member_type" value="<cfif attributes.sales_member_type is 'partner'>partner<cfelseif attributes.sales_member_type is 'consumer'>consumer</cfif>">
									<input name="sales_member_name" type="text" id="sales_member_name" placeholder="<cfoutput><cf_get_lang dictionary_id='40904.Satış Ortağı'></cfoutput>" onfocus="AutoComplete_Create('sales_member_name','MEMBER_NAME,MEMBER_PARTNER_NAME','MEMBER_PARTNER_NAME2,MEMBER_NAME2','get_member_autocomplete','\'1,2\',0,0,0','PARTNER_ID2,MEMBER_TYPE','sales_member_id,sales_member_type','','3','250');" value="<cfoutput>#attributes.sales_member_name#</cfoutput>" autocomplete="off">
									<span class="input-group-addon btnPointer icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_pars&field_id=order_form.sales_member_id&field_name=order_form.sales_member_name&field_type=order_form.sales_member_type<cfif session.ep.isBranchAuthorization>&is_store_module=1</cfif>&select_list=2,3');"></span>
								</div>
							</div>
						</div>
						<div class="form-group" id="item-order_employee_id">						
							<label class="col col-12 col-md-12 col-sm-12 col-xs-12"><cf_get_lang dictionary_id='40903.Satis Yapan'></label>			
							<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
								<div class="input-group">
									<input type="hidden" name="order_employee_id" id="order_employee_id" value="<cfoutput>#attributes.order_employee_id#</cfoutput>">
									<input name="order_employee" type="text" id="order_employee" placeholder="<cfoutput><cf_get_lang dictionary_id='40903.Satış Yapan'></cfoutput>" onfocus="AutoComplete_Create('order_employee','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','3','EMPLOYEE_ID','order_employee_id','','3','125');" value="<cfif isdefined('attributes.order_employee_id') and len(attributes.order_employee_id) and isdefined('attributes.order_employee') and len(attributes.order_employee)><cfoutput>#attributes.order_employee#</cfoutput></cfif>" autocomplete="off">
									<span class="input-group-addon btnPointer icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_positions&field_emp_id=order_form.order_employee_id&field_name=order_form.order_employee&is_form_submitted=1&select_list=1');"></span>
								</div>
							</div>
						</div>
						<div class="form-group" id="item-paymethod_id">	
							<label class="col col-12 col-md-12 col-sm-12 col-xs-12"><cf_get_lang dictionary_id='58516.Ödeme Yöntemi'></label>				
							<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
								<div class="input-group">
									<cfoutput>
									<input type="hidden" name="card_paymethod_id" id="card_paymethod_id" value="<cfif isdefined("attributes.card_paymethod_id") and len(attributes.card_paymethod_id)>#attributes.card_paymethod_id#</cfif>">
									<input type="hidden" name="paymethod_id" id="paymethod_id" value="<cfif isdefined("attributes.paymethod_id") and len(attributes.paymethod_id)>#attributes.paymethod_id#</cfif>">
									<input type="text" name="paymethod" placeholder="<cf_get_lang dictionary_id='58516.Ödeme Yöntemi'>" id="paymethod" value="<cfif isdefined("attributes.paymethod") and len(attributes.paymethod)>#attributes.paymethod#</cfif>">
									<span class="input-group-addon btnPointer icon-ellipsis"onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_paymethods&field_id=order_form.paymethod_id&field_name=order_form.paymethod&field_card_payment_id=order_form.card_paymethod_id&field_card_payment_name=order_form.paymethod</cfoutput>');"></span>
									</cfoutput>
								</div>
							</div>
						</div>
						<cfif session.ep.our_company_info.subscription_contract eq 1>
							<div class="form-group" id="item-sale_add_option">
								<label class="col col-12 col-md-12 col-sm-12 col-xs-12"><cf_get_lang dictionary_id ='41142.Satis zel Tanim'></label>			
								<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
									<cfinclude template="../query/get_sale_add_option.cfm">
									<cfoutput>
									<select name="sale_add_option" id="sale_add_option">
										<option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
										<cfloop query="get_sale_add_option">
											<option value="#sales_add_option_id#" <cfif attributes.sale_add_option eq sales_add_option_id>selected</cfif>>#sales_add_option_name#</option>
										</cfloop>
									</select>      
									</cfoutput>              
								</div>
							</div>
						</cfif>
					</div>
					<div class="col col-3 col-md-8 col-sm-12" type="column" sort="true" index="4">
						<div class="form-group" id="item-project_id">	
							<label class="col col-12 col-md-12 col-sm-12 col-xs-12"><cf_get_lang dictionary_id='57416.Proje'></label>					
							<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
								<div class="input-group">
									<input type="hidden" name="project_id" id="project_id" value="<cfif isdefined("attributes.project_id") and len (attributes.project_head)><cfoutput>#attributes.project_id#</cfoutput></cfif>">
									<input type="text" name="project_head"  id="project_head" placeholder="<cfoutput><cf_get_lang dictionary_id='57416.Proje'></cfoutput>" value="<cfif Len(attributes.project_head)><cfoutput>#get_project_name(attributes.project_id)#</cfoutput></cfif>" onfocus="AutoComplete_Create('project_head','PROJECT_HEAD','PROJECT_HEAD','get_project','','PROJECT_ID','project_id','','3','200');" autocomplete="off">
									<span class="input-group-addon btnPointer icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_projects&project_id=order_form.project_id&project_head=order_form.project_head');"></span>
								</div>
							</div>
						</div>
						<div class="form-group" id="item-sales_county">	
							<label class="col col-12 col-md-12 col-sm-12 col-xs-12"><cf_get_lang dictionary_id='57659.Satış Bölgesi'></label>					
							<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
								<cfsavecontent variable="text"><cf_get_lang dictionary_id='57659.Satış Bölgesi'></cfsavecontent>
								<cf_wrk_saleszone 
									name="sales_county"
									option_text="#text#"
									value="#attributes.sales_county#">         
							</div>
						</div>
						<div class="form-group" id="item-zone_id">						
							<label class="col col-12 col-md-12 col-sm-12 col-xs-12"><cf_get_lang dictionary_id='57992.Satış Bölgesi'></label>
							<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
								<cf_wrk_zones fieldid='zone_id' selected_value='#attributes.zone_id#'>           
							</div>
						</div>
						<div class="form-group" id="item-employee_id">						
							<label class="col col-12 col-md-12 col-sm-12 col-xs-12"><cf_get_lang dictionary_id='58448.Ürün sorumlusu'></label>
							<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
								<div class="input-group">
									<input type="hidden" name="employee_id" id="employee_id" value="<cfif isdefined("attributes.employee_id") and len(attributes.employee_id) and isdefined("attributes.employee") and len(attributes.employee)><cfoutput>#attributes.employee_id#</cfoutput></cfif>">
									<input name="employee" type="text" id="employee" placeholder="<cfoutput><cf_get_lang dictionary_id='58448.Ürün sorumlusu'></cfoutput>" onfocus="AutoComplete_Create('employee','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','3','POSITION_CODE','employee_id','','3','125');" value="<cfif isdefined("attributes.employee_id") and len(attributes.employee_id) and isdefined("attributes.employee") and len(attributes.employee)><cfoutput>#attributes.employee#</cfoutput></cfif>"maxlength="255" autocomplete="off">
									<span class="input-group-addon btnPointer icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_positions&field_code=order_form.employee_id&field_name=order_form.employee&select_list=1&is_form_submitted=1&keyword='+encodeURIComponent(document.order_form.employee.value));"></span>
								</div>
							</div>
						</div>
						<div class="form-group" id="item-subscription_id">	
							<label class="col col-12 col-md-12 col-sm-12 col-xs-12"><cfoutput><cf_get_lang dictionary_id="29502.Abone No"></cfoutput></label>					
							<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
								<cfif not len(attributes.subscription_no)>
									<cfset attributes.subscription_id ="">
								</cfif>
								<cf_wrk_subscriptions subscription_id='#attributes.subscription_id#' subscription_no='#attributes.subscription_no#' width_info='90' fieldid='subscription_id' fieldname='subscription_no' form_name='order_form' img_info='plus_thin'>
							</div>
						</div>
						<div class="form-group" id="item-related_orders">
							<label class="col col-12 col-md-12 col-sm-12 col-xs-12"><cf_get_lang dictionary_id='40830.Satınalma Siparişi'></label>	
							<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
							<select name="related_orders" id="related_orders">
								<option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
								<option value="1"<cfif isdefined('attributes.related_orders') and (attributes.related_orders eq 1)> selected</cfif>><cf_get_lang dictionary_id='30055.Olanlar'></option>
								<option value="2"<cfif isdefined('attributes.related_orders') and (attributes.related_orders eq 2)> selected</cfif>><cf_get_lang dictionary_id='30056.Olmayanlar'></option>
							</select>                  
							</div>
						</div>
					</div>
			</cf_box_search_detail>
		</cfform>
	</cf_box>
	
	<cf_box title="#head#" uidrop="1" hide_table_column="1" woc_setting = "#{ checkbox_name : 'print_order_id'}#">
		<form name="send_print_page">
		<div id="sales_list">
			<cf_grid_list>
				<thead>
					<tr>
						<th><cf_get_lang dictionary_id='58577.Sira'></th>
						<cfif (isdefined('attributes.listing_type') and attributes.listing_type eq 2)><!--- Eger satir bazinda listeleme yapiliyorsa --->
						
							<th width="1%" class="el_hidden"></th>
						
						</cfif>
						<th><cf_get_lang dictionary_id='57487.no'></th>
						<th><cf_get_lang dictionary_id='57742.tarih'></th>
						<th><cf_get_lang dictionary_id='40953.teslim'></th>
						<th><cf_get_lang dictionary_id='57453.Sube'></th>
						<th><cf_get_lang dictionary_id='41184.Depo- Lokasyon'></th>
						<th><cf_get_lang dictionary_id='57480.Baslik'></th>
						<cfif (isdefined('attributes.listing_type') and attributes.listing_type eq 2)><!--- Eger satir bazinda listeleme yapiliyorsa --->
							<th><cf_get_lang dictionary_id='57518.Stok Kodu'></th>
							<th><cf_get_lang dictionary_id='57657.rn'></th>
							<cfif x_show_spec_info>
								<th><cf_get_lang dictionary_id='57647.Spec'></th>
			
							</cfif>
						</cfif>
						<th><cf_get_lang dictionary_id='38554.sirket yetkili'></th>
						<th><cf_get_lang dictionary_id='57899.Kaydeden'></th>
						<th><cf_get_lang dictionary_id='40903.Satis Yapan'></th>   
						<th><cf_get_lang dictionary_id='58859.Siparis Sreci'></th>
						<th><cf_get_lang dictionary_id='57482.Asama'></th>
						<th><cf_get_lang dictionary_id='57416.Proje'></th> 
						<cfif (isdefined('attributes.listing_type') and attributes.listing_type eq 2)><!--- Eger satir bazinda listeleme yapiliyorsa --->
							<th><cf_get_lang dictionary_id='57635.Miktar'></th>
							<th><cf_get_lang dictionary_id='58506.Iptal'></th>
							<th><cf_get_lang dictionary_id='57636.Birim'></th>
						</cfif>
							<th><cf_get_lang dictionary_id='30024.KDVsiz'><cf_get_lang dictionary_id='57673.tutar'></th>
						<th><cf_get_lang dictionary_id='57673.tutar'></th>
						<th><cf_get_lang dictionary_id='58864.Para Br'></th>
						<th><cf_get_lang dictionary_id='30024.KDVsiz'><cf_get_lang dictionary_id ='58056.Dvizli Tutar'></th>
						<th><cf_get_lang dictionary_id ='58056.Dvizli Tutar'></th>
						<th><cf_get_lang dictionary_id='58864.Para Br'></th>
						<th width="15"><cf_get_lang dictionary_id ='34966.Kargo'></th>
						<th><cf_get_lang dictionary_id='41142.Ozel Tanim'></th>
						<th><cf_get_lang dictionary_id='58794.Referans no'></th>
						<th><cf_get_lang dictionary_id='58516.Odeme Yontemi'></th>
						<!-- sil -->
						<cfif isdefined("attributes.is_instalment")>
							<th width="20" class="header_icn_none text-center"><a href="<cfoutput>#request.self#?fuseaction=#listgetat(attributes.fuseaction,1,'.')#.</cfoutput>list_order_instalment&event=add"><i class="fa fa-plus" title="<cf_get_lang dictionary_id='57582.Ekle'>"></i></a></th>
						<cfelse>
							<th width="20" class="header_icn_none text-center"><a href="<cfoutput>#request.self#?fuseaction=#listgetat(attributes.fuseaction,1,'.')#.</cfoutput>list_order&event=add"><i class="fa fa-plus" title="<cf_get_lang dictionary_id='57582.Ekle'>"></i></a></th>
						</cfif>
						<!--- <th width="20" class="text-center"><i class="fa fa-print" title="<cf_get_lang dictionary_id='57474.Yazdir'>"></i></th> --->
							<!--- Boxa woc'a gönder eklendiği için yoruma alındı. F.Z.DERE--->
							<!--- <cfif x_select_row_print eq 1 and attributes.listing_type eq 1 and get_order_list.recordcount>
								<th width="20" align="center" class="header_icn_none text-center" nowrap="nowrap">
									<cfoutput><a href="javascript://" onclick="send_print_();"><i class="fa fa-print" title="<cf_get_lang dictionary_id='58057.Toplu'><cf_get_lang dictionary_id='57474.Yazdir'>"></i></a></cfoutput></br>
									<input type="checkbox" name="allSelectDemand" id="allSelectDemand" onclick="wrk_select_all('allSelectDemand','print_islem_id');">
								</th>
							</cfif>  --->
							<cfif  get_order_list.recordcount>
								<th width="20" class="text-center header_icn_none">
									<cfif  get_order_list.recordcount eq 1><a href="javascript://" onclick="send_print_reset();"><i class="fa fa-print" alt="<cf_get_lang dictionary_id='57389.Print Sayisi Sifirla'>" title="<cf_get_lang dictionary_id='57389.Print Sayisi Sifirla'>"></i></a></cfif>
									<input type="checkbox" name="allSelectDemand" id="allSelectDemand" onclick="wrk_select_all('allSelectDemand','print_order_id');">
								</th>
							</cfif> 
						<!-- sil -->
					</tr>
				</thead>
				<tbody>
					<cfif get_order_list.recordcount>
						<cfscript>
							partner_id_list='';
							order_emp_id_list='';
							consumer_id_list='';
							record_emp_list='';
							order_stage_list='';
							orders_id_list = '';
							order_row_id_list='';
							project_name_list = '';
							sale_add_option_id_list ='';
						</cfscript>
						<cfoutput query="get_order_list">
							<cfif len(order_employee_id) and not listfind(order_emp_id_list,order_employee_id)>
								<cfset order_emp_id_list=listappend(order_emp_id_list,order_employee_id)>
							</cfif>
							<cfif len(record_con) and not listfind(consumer_id_list,record_con)>
								<cfset consumer_id_list=listappend(consumer_id_list,record_con)>
							</cfif>
							<cfif len(record_emp) and (order_zone eq 0) and not listfind(record_emp_list,record_emp)>
								<cfset record_emp_list=listappend(record_emp_list,record_emp)>
							<cfelseif len(record_par) and (order_zone eq 1) and not listfind(partner_id_list,record_par)>
								<cfset partner_id_list=listappend(partner_id_list,record_par)>
							</cfif>
							<cfif len(order_stage) and not listfind(order_stage_list,order_stage)>
								<cfset order_stage_list=listappend(order_stage_list,order_stage)>
							</cfif>
							<cfif len(order_id) and is_processed eq 1>
								<cfif not listfind(orders_id_list,order_id)>
									<cfset orders_id_list=listappend(orders_id_list,order_id)>
								</cfif>
								<cfif (isdefined('attributes.listing_type') and attributes.listing_type eq 2)>
									<cfset order_row_id_list=listappend(order_row_id_list,order_row_id)>				
								</cfif>
							</cfif>
							<cfif len(project_id) and not listfind(project_name_list,project_id)>
								<cfset project_name_list = Listappend(project_name_list,project_id)>
							</cfif>
							<cfset sale_add_option_id_list = listappend(sale_add_option_id_list,sales_add_option_id,',')>
						</cfoutput>
						<cfif len(sale_add_option_id_list) and session.ep.our_company_info.subscription_contract eq 1>
							<cfset sale_add_option_id_list=listsort(sale_add_option_id_list,"numeric","ASC",",")>
							<cfquery name="GET_SALE_ADD_OPTION_NAME" dbtype="query">
								SELECT SALES_ADD_OPTION_NAME FROM GET_SALE_ADD_OPTION WHERE SALES_ADD_OPTION_ID IN (#sale_add_option_id_list#) ORDER BY SALES_ADD_OPTION_ID
							</cfquery>
						</cfif>                                  
						<cfif len(partner_id_list)>
							<cfset partner_id_list = listsort(partner_id_list,"numeric","ASC",",")>
							<cfquery name="get_partner_detail" datasource="#dsn#">
								SELECT PARTNER_ID,COMPANY_PARTNER_NAME,COMPANY_PARTNER_SURNAME FROM COMPANY_PARTNER WHERE PARTNER_ID IN (#partner_id_list#) ORDER BY PARTNER_ID
							</cfquery>
						</cfif>
						<cfif len(consumer_id_list)>
							<cfset consumer_id_list=listsort(consumer_id_list,"numeric","ASC",",")>
							<cfquery name="get_consumer_detail" datasource="#dsn#">
								SELECT CONSUMER_ID, CONSUMER_NAME, CONSUMER_SURNAME FROM CONSUMER WHERE CONSUMER_ID IN (#consumer_id_list#) ORDER BY CONSUMER_ID
							</cfquery>
						</cfif>
						<cfif len(record_emp_list)>
							<cfset record_emp_list=listsort(record_emp_list,"numeric","ASC",",")>
							<cfquery name="get_emp_detail" datasource="#dsn#">
								SELECT EMPLOYEE_NAME, EMPLOYEE_SURNAME, EMPLOYEE_ID FROM EMPLOYEES WHERE EMPLOYEE_ID IN (#record_emp_list#) ORDER BY EMPLOYEE_ID
							</cfquery>
						</cfif>
						<cfif len(order_stage_list)>
							<cfset order_stage_list=listsort(order_stage_list,"numeric","ASC",",")>
							<cfquery name="process_type" datasource="#dsn#">
								SELECT STAGE, PROCESS_ROW_ID FROM PROCESS_TYPE_ROWS WHERE PROCESS_ROW_ID IN (#order_stage_list#) ORDER BY PROCESS_ROW_ID
							</cfquery>
							<cfset order_stage_list=valuelist(process_type.PROCESS_ROW_ID)>
						</cfif>
						<cfif len(project_name_list)>
							<cfquery name="order_project" datasource="#dsn#">
								SELECT PROJECT_HEAD, PROJECT_ID FROM PRO_PROJECTS WHERE PROJECT_ID IN (#project_name_list#) ORDER BY PROJECT_ID
							</cfquery>
							<cfset project_name_list = listsort(listdeleteduplicates(valuelist(order_project.project_id,',')),"numeric","ASC",",")>
						</cfif>
						<cfif len(orders_id_list)>
							<cfif (isdefined('attributes.listing_type') and attributes.listing_type eq 2)><!--- Eger satir bazinda listeleme yapiliyorsa --->
								<cfquery name="get_order_ship_periods" datasource="#dsn3#">
									SELECT DISTINCT PERIOD_ID FROM ORDERS_SHIP WHERE ORDER_ID IN (#orders_id_list#)
									UNION ALL
									SELECT DISTINCT PERIOD_ID FROM ORDERS_INVOICE WHERE ORDER_ID IN (#orders_id_list#)
								</cfquery>
								<cfif get_order_ship_periods.recordcount>
									<cfset orders_ship_period_list =listdeleteduplicates(valuelist(get_order_ship_periods.PERIOD_ID))>
									<cfif listlen(orders_ship_period_list) eq 1 and orders_ship_period_list eq session.ep.period_id>
										<cfquery name="get_ship_info" datasource="#dsn2#">
											SELECT SR.SHIP_ID, ISNULL(SR.WRK_ROW_RELATION_ID,0) AS ORDER_WRK_ROW_ID FROM SHIP_ROW SR WHERE SR.ROW_ORDER_ID IN (#orders_id_list#)
										</cfquery>
										
									<cfelse>
										<!---siparis farkli periyotlardaki irsaliyelerle iliskili --->
										<cfquery name="get_period_dsns" datasource="#dsn2#">
											SELECT PERIOD_YEAR,OUR_COMPANY_ID,PERIOD_ID FROM #dsn_alias#.SETUP_PERIOD WHERE PERIOD_ID IN (#orders_ship_period_list#) AND IS_ACTIVE <> 0
										</cfquery>
										<cfquery name="get_ship_info" datasource="#dsn2#">
											SELECT
												A1.SHIP_ID,
												A1.ORDER_WRK_ROW_ID
											FROM
											(
											<cfloop query="get_period_dsns">
												SELECT
													SR.SHIP_ID,
													ISNULL(SR.WRK_ROW_RELATION_ID,0) AS ORDER_WRK_ROW_ID
												FROM
													#dsn#_#get_period_dsns.PERIOD_YEAR#_#get_period_dsns.OUR_COMPANY_ID#.SHIP_ROW SR
												WHERE
													SR.ROW_ORDER_ID IN (#orders_id_list#)
												<cfif currentrow neq get_period_dsns.recordcount> UNION ALL </cfif>					
											</cfloop> ) AS A1
										</cfquery>
									</cfif>
									<cfif listlen(orders_ship_period_list) eq 1 and orders_ship_period_list eq session.ep.period_id>
										<cfquery name="get_invoice_info" datasource="#dsn3#">
											SELECT 
												IR.INVOICE_ID,
												ORR.WRK_ROW_ID AS ORDER_WRK_ROW_ID
											FROM 
												#dsn2_alias#.INVOICE_ROW IR,
												ORDER_ROW ORR
											WHERE 
												IR.WRK_ROW_RELATION_ID = ORR.WRK_ROW_ID 
												AND ORR.ORDER_ROW_ID IN (#order_row_id_list#)
											UNION ALL
											SELECT 
												IR.INVOICE_ID,
												ORR.WRK_ROW_ID AS ORDER_WRK_ROW_ID
											FROM 
												#dsn2_alias#.INVOICE_ROW IR,
												#dsn2_alias#.SHIP_ROW SR,
												ORDER_ROW ORR
											WHERE 
												SR.WRK_ROW_RELATION_ID = ORR.WRK_ROW_ID 
												AND IR.WRK_ROW_RELATION_ID = SR.WRK_ROW_ID
												AND ORR.ORDER_ROW_ID IN (#order_row_id_list#)
										</cfquery>
									<cfelse>
										<cfquery name="get_period_dsns" datasource="#dsn#">
											SELECT PERIOD_YEAR,OUR_COMPANY_ID,PERIOD_ID FROM SETUP_PERIOD WHERE PERIOD_ID IN (#orders_ship_period_list#) AND IS_ACTIVE <> 0
										</cfquery>
										<cfquery name="get_invoice_info" datasource="#dsn3#">
											SELECT
												A1.INVOICE_ID,
												A1.ORDER_WRK_ROW_ID
											FROM
											(
											<cfloop query="get_period_dsns">
											SELECT *
											FROM 
												(
													SELECT
														IR.INVOICE_ID,
														ORR.WRK_ROW_ID AS ORDER_WRK_ROW_ID
													FROM 
														#dsn#_#get_period_dsns.PERIOD_YEAR#_#get_period_dsns.OUR_COMPANY_ID#.INVOICE_ROW IR,
														ORDER_ROW ORR
													WHERE  IR.WRK_ROW_RELATION_ID=ORR.WRK_ROW_ID AND  
														ORR.ORDER_ROW_ID IN (#order_row_id_list#)
													UNION ALL
													SELECT
														IR.INVOICE_ID, 
														ORR.WRK_ROW_ID AS ORDER_WRK_ROW_ID
													FROM
														ORDER_ROW ORR
													JOIN
														#dsn#_#get_period_dsns.PERIOD_YEAR#_#get_period_dsns.OUR_COMPANY_ID#.SHIP_ROW SR ON SR.WRK_ROW_RELATION_ID=ORR.WRK_ROW_ID
													JOIN
														#dsn#_#get_period_dsns.PERIOD_YEAR#_#get_period_dsns.OUR_COMPANY_ID#.INVOICE_ROW IR  ON SR.WRK_ROW_ID = IR.WRK_ROW_RELATION_ID
													WHERE  
														ORR.ORDER_ROW_ID IN (#order_row_id_list#)
												) as xxxx              
												<cfif currentrow neq get_period_dsns.recordcount> UNION ALL </cfif>					
											</cfloop> ) AS A1
										</cfquery>
									</cfif>
								</cfif>
								<cfscript>
									if(isdefined("get_ship_info"))
										for(ord_ii=1; ord_ii lte get_ship_info.recordcount; ord_ii=ord_ii+1)
										{
											'order_row_ship_info_#get_ship_info.ORDER_WRK_ROW_ID[ord_ii]#' = 1;
										}
									if(isdefined("get_invoice_info"))
										for(ord_ii=1; ord_ii lte get_invoice_info.recordcount; ord_ii=ord_ii+1)
										{
											'order_row_invoice_info_#get_invoice_info.ORDER_WRK_ROW_ID[ord_ii]#' = 1;
										}
								</cfscript>
							<cfelse><!--- belge bazinda --->
								<!--- Siparisten irsaliyeye ve direkt faturaya cekilenleri bulduk. --->
								<cfquery name="get_orders_ship_and_invoice" datasource="#dsn3#">
									SELECT 'irsaliye' TYPE,ORDER_ID,SHIP_ID,PERIOD_ID FROM ORDERS_SHIP WHERE ORDER_ID IN (#orders_id_list#) 
									UNION ALL
									SELECT 'fatura' TYPE,ORDER_ID,0 AS SHIP_ID,PERIOD_ID FROM ORDERS_INVOICE WHERE ORDER_ID IN (#orders_id_list#) 
									<!--- Period Eklerseniz bir onceki donemin siparis bilgileri gelmez eklemeyiniz please..M.ER 20 01 2009 --->
								</cfquery>
								<cfset ship_id_list = listdeleteduplicates(ValueList(get_orders_ship_and_invoice.SHIP_ID,','))>
								<cfset ship_period_list=listdeleteduplicates(valuelist(get_orders_ship_and_invoice.PERIOD_ID))>
								<cfif len(ship_id_list)>
									<cfif listlen(ship_period_list) eq 1 and ship_period_list eq session.ep.period_id>
										<cfquery name="ALL_GET_SHIP_INVOICE" datasource="#dsn2#">
											SELECT SHIP_ID FROM INVOICE_SHIPS WHERE SHIP_ID IN (#ship_id_list#) AND SHIP_PERIOD_ID = #session.ep.period_id#
										</cfquery>
									<cfelse>
										<cfquery name="get_ship_periods_" datasource="#dsn#">
											SELECT * FROM SETUP_PERIOD WHERE PERIOD_ID IN (#ship_period_list#) AND IS_ACTIVE <> 0
										</cfquery>
										<cfoutput query="get_orders_ship_and_invoice">
											<cfif len(get_orders_ship_and_invoice.SHIP_ID)>
												<cfif isdefined('control_ship_list_#period_id#')>
													<cfset 'control_ship_list_#period_id#'=listappend(evaluate('control_ship_list_#period_id#'),get_orders_ship_and_invoice.SHIP_ID)>
												<cfelse>
													<cfset 'control_ship_list_#period_id#'=get_orders_ship_and_invoice.SHIP_ID>
												</cfif>
											</cfif>
										</cfoutput>
										<cfif get_ship_periods_.recordcount>
										<cfquery name="ALL_GET_SHIP_INVOICE" datasource="#dsn2#">
											<cfloop query="get_ship_periods_">
												SELECT 
													SHIP_ID 
												FROM 
													#dsn#_#get_ship_periods_.PERIOD_YEAR#_#get_ship_periods_.OUR_COMPANY_ID#.INVOICE_SHIPS
												WHERE
													SHIP_ID IN (#evaluate('control_ship_list_#get_ship_periods_.period_id#')#) AND SHIP_PERIOD_ID=#get_ship_periods_.period_id#
												<cfif get_ship_periods_.recordcount neq 1 and currentrow neq get_ship_periods_.recordcount>
												UNION ALL
												</cfif>
											</cfloop>
										</cfquery>
										<cfelse>
											<cfset ALL_GET_SHIP_INVOICE.recordcount = 0>
										</cfif>
									</cfif>
								</cfif>
								<cfif get_orders_ship_and_invoice.recordcount>
									<cfscript>
										order_and_ship_list ='';
										for(oi=1;oi lte get_orders_ship_and_invoice.recordcount;oi=oi+1){
											'order_info_#get_orders_ship_and_invoice.ORDER_ID[oi]#_#get_orders_ship_and_invoice.TYPE[oi]#' = 1;
											if(len(get_orders_ship_and_invoice.SHIP_ID[oi]) and len(get_orders_ship_and_invoice.ORDER_ID[oi])){
												order_and_ship_list = ListAppend(order_and_ship_list,get_orders_ship_and_invoice.ORDER_ID[oi],',');
											}	
										}
										order_and_ship_list = ListDeleteDuplicates(order_and_ship_list);
									</cfscript>
									<cfif len(order_and_ship_list) and len(ship_id_list)>
										<cfif ALL_GET_SHIP_INVOICE.recordcount>
										<cfloop list="#order_and_ship_list#" delimiters="," index="sh_or">
											<cfif listlen(ship_id_list) gte ListFind(order_and_ship_list,sh_or)>
												<cfquery name="GET_SHIP_INVOICE" dbtype="query">
													SELECT SHIP_ID FROM ALL_GET_SHIP_INVOICE WHERE SHIP_ID = #ListGetAt(ship_id_list,ListFind(order_and_ship_list,sh_or))#
												</cfquery>
												<cfif GET_SHIP_INVOICE.recordcount><cfset 'order_info_#ListGetAt(sh_or,1,'')#_fatura' = 1></cfif>
											</cfif>
										</cfloop>
										<cfelse>
											<cfset GET_SHIP_INVOICE.recordcount = 0>
										</cfif>
									</cfif> 
								</cfif>
							</cfif>
						</cfif>
						<cfoutput query="get_order_list"> 
						<tr> 
							<td width="35">#((attributes.page-1)*attributes.maxrows)+currentrow#</td>
							<cfif (isdefined('attributes.listing_type') and attributes.listing_type eq 2)><!--- Eger satir bazinda listeleme yapiliyorsa --->
							
							<td align="center" id="order_row#currentrow#" class="color-row el_hidden" onclick="gizle_goster(order_stocks_detail#currentrow#);connectAjax('#currentrow#','#PRODUCT_ID#','#STOCK_ID#','#unit#','#numberformat(quantity)#');gizle_goster(siparis_goster#currentrow#);gizle_goster(siparis_gizle#currentrow#);">
								<img id="siparis_goster#currentrow#" name="siparis_goster#currentrow#" src="/images/listele.gif" title="<cf_get_lang dictionary_id ='58596.Gster'>">
								<img id="siparis_gizle#currentrow#" name="siparis_gizle#currentrow#" src="/images/listele_down.gif" title="<cf_get_lang dictionary_id ='58628.Gizle'>" style="display:none">
							</td>
							
							</cfif>
							<td>
								<cfif is_instalment eq 1>
									<a href="#request.self#?fuseaction=#listgetat(attributes.fuseaction,1,'.')#.list_order_instalment&event=upd&order_id=#ORDER_ID#" class="tableyazi">#ORDER_NUMBER#</a>
								<cfelse>
									<a href="#request.self#?fuseaction=#listgetat(attributes.fuseaction,1,'.')#.list_order&event=upd&order_id=#order_id#" class="tableyazi">#ORDER_NUMBER#</a>
								</cfif>
							</td>
							<td>#dateformat(order_date,dateformat_style)#</td>
							<td>
							<cfif (isdefined('attributes.listing_type') and attributes.listing_type eq 2) and (isdefined('is_show_delivery_date') and is_show_delivery_date eq 1)>
								#dateformat(row_deliver_date,dateformat_style)#
							<cfelse>
								#dateformat(deliverdate,dateformat_style)#
							</cfif>
							</td>
							<td>#branch_name#</td>
							<td>#listfirst(get_location_info(deliver_dept_id,location_id,1,1),',')#</td>
							<td>
								<cfif is_instalment eq 1>
									<a href="#request.self#?fuseaction=#listgetat(attributes.fuseaction,1,'.')#.list_order_instalment&event=upd&order_id=#ORDER_ID#" class="tableyazi">#left(ORDER_HEAD,25)#</a>
								<cfelse>	
									<a href="#request.self#?fuseaction=#listgetat(attributes.fuseaction,1,'.')#.list_order&event=upd&order_id=#order_id#" class="tableyazi">#left(ORDER_HEAD,25)#</a>
								</cfif>
							</td>                       
							<cfif (isdefined('attributes.listing_type') and attributes.listing_type eq 2)><!--- Eger satir bazinda listeleme yapiliyorsa --->
								<td width="50px;"><a href="#request.self#?fuseaction=prod.list_product_tree&event=upd&stock_id=#stock_id#" class="tableyazi">#product_code#</a></td>
								<td><a href="#request.self#?fuseaction=prod.list_product_tree&event=upd&stock_id=#stock_id#" class="tableyazi">#PRODUCT_NAME#</a></td>
								<cfif x_show_spec_info><td>#SPECT_VAR_NAME# - #SPECT_VAR_ID#</td></cfif>
							</cfif>
							<td><cfif len(COMPANY_ID)>
									<a href="javascript://" class="tableyazi" onclick="windowopen('#request.self#?fuseaction=objects.popup_com_det&company_id=#COMPANY_ID#','medium');"><!--- #get_company_detail.nickname[listfind(company_id_list,company_id,',')]# -  --->#COMPANY_NAME#</a>
								</cfif>
								<cfif len(PARTNER_ID)>
									-<a href="javascript://" class="tableyazi" onclick="windowopen('#request.self#?fuseaction=objects.popup_par_det&par_id=#PARTNER_ID#','medium');">
										<!--- #get_partner_detail.company_partner_name[listfind(partner_id_list,partner_id,',')]# #get_partner_detail.company_partner_surname[listfind(partner_id_list,partner_id,',')]#  -  --->#PARTNER_NAME#
									</a> 
								</cfif>
								<cfif len(CONSUMER_ID)>
									<a href="javascript://" class="tableyazi" onclick="windowopen('#request.self#?fuseaction=objects.popup_con_det&con_id=#CONSUMER_ID#','medium');">#CONSUMER_NAME#</a>
								</cfif>
							</td>
							<td><cfif ORDER_ZONE eq 0 and len(RECORD_EMP)>
									<a href="javascript://" class="tableyazi" onclick="windowopen('#request.self#?fuseaction=objects.popup_emp_det&EMP_ID=#RECORD_EMP#','medium');">#get_emp_detail.employee_name[listfind(record_emp_list,record_emp,',')]# #get_emp_detail.employee_surname[listfind(record_emp_list,record_emp,',')]#</a>
								<cfelseif len(RECORD_PAR) and ORDER_ZONE eq 1> 
									<a href="javascript://" class="tableyazi" onclick="windowopen('#request.self#?fuseaction=objects.popup_par_det&par_id=#RECORD_PAR#','medium');">#get_partner_detail.company_partner_name[listfind(partner_id_list,record_par,',')]# #get_partner_detail.company_partner_surname[listfind(partner_id_list,record_par,',')]#</a>
								<cfelseif len(RECORD_CON) and ORDER_ZONE eq 1> 
									<a href="javascript://" class="tableyazi" onclick="windowopen('#request.self#?fuseaction=objects.popup_con_det&con_id=#RECORD_CON#','medium');">#get_consumer_detail.consumer_name[listfind(consumer_id_list,record_con,',')]# #get_consumer_detail.consumer_surname[listfind(consumer_id_list,record_con,',')]#</a>
								</cfif>
							</td>
							<td><cfif len(ORDER_EMPLOYEE_ID)><a href="javascript://" class="tableyazi" onclick="windowopen('#request.self#?fuseaction=objects.popup_emp_det&EMP_ID=#ORDER_EMPLOYEE_ID#','medium');">#ORDER_EMPLOYEE_NAME# #ORDER_EMPLOYEE_SURNAME#</a></cfif></td>
							<td><cfif len(ORDER_STAGE)>#process_type.stage[listfind(order_stage_list,ORDER_STAGE,',')]#</cfif></td>
							<td width="75">
								<cfif (isdefined('attributes.listing_type') and attributes.listing_type eq 2)><!--- Eger satir bazinda listeleme yapiliyorsa --->
									<cfswitch expression = "#ORDER_ROW_CURRENCY#">
										<cfcase value="-7"><cf_get_lang dictionary_id='29748.Eksik Teslimat'></cfcase>
										<cfcase value="-8"><cf_get_lang dictionary_id='29749.Fazla Teslimat'> </cfcase>
										<cfcase value="-6"><cf_get_lang dictionary_id='58761.Sevk'></cfcase>
										<cfcase value="-5"><cf_get_lang dictionary_id='57456.Uretim'></cfcase>
										<cfcase value="-4"><cf_get_lang dictionary_id='29747.Kismi Uretim'></cfcase>
										<cfcase value="-3"><cf_get_lang dictionary_id='29746.Kapatildi'></cfcase>
										<cfcase value="-2"><cf_get_lang dictionary_id='29745.Tedarik'></cfcase>
										<cfcase value="-1"><cf_get_lang dictionary_id='58717.Aik'></cfcase>
									</cfswitch>
								</cfif>
								<cfif is_processed eq 1>
									<font color="FF0000">
									<cfif isdefined('attributes.listing_type') and attributes.listing_type eq 2>
										<cfif isdefined('order_row_ship_info_#WRK_ROW_ID#') and evaluate('order_row_ship_info_#WRK_ROW_ID#') eq 1>
											<cf_get_lang dictionary_id='57893.Irsaliye Kesildi'>
										</cfif>
										<cfif isdefined('order_row_invoice_info_#WRK_ROW_ID#') and evaluate('order_row_invoice_info_#WRK_ROW_ID#') eq 1>
											<cf_get_lang dictionary_id='41115.Faturalandi'>
										</cfif>
									<cfelse>
										<cfif isdefined('order_info_#ORDER_ID#_irsaliye')>
											<cf_get_lang dictionary_id='57893.Irsaliye Kesildi'>		
										</cfif>
										<!----<cfif isdefined('order_info_#ORDER_ID#_fatura')>----->
											<cfquery name="control_order_ship" datasource="#dsn3#"> <!--- aktif donemde siparisle ilgili irsaliye kaydı olup olmadığı kontrol edilir --->
												SELECT SHIP_ID,PERIOD_ID FROM ORDERS_SHIP WHERE ORDER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#ORDER_ID#">
											</cfquery>
											<cfquery name="control_order_invoice" datasource="#dsn3#"> 
												SELECT INVOICE_ID,PERIOD_ID FROM ORDERS_INVOICE WHERE ORDER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#ORDER_ID#">
											</cfquery>  
											<cfif control_order_ship.recordcount><!--- bu irsaliyelerle ilgili sevkiyat ve fatura bilgileri kontrol ediliyor --->
												<cfset faturalandi_ = 0>
												<cfset ship_period_list=listdeleteduplicates(valuelist(control_order_ship.PERIOD_ID))>
												<cfquery name="get_ship_periods_" datasource="#dsn#">
													SELECT
														PERIOD_ID,
														PERIOD,
														PERIOD_YEAR,
														OUR_COMPANY_ID,
														PERIOD_DATE,
														OTHER_MONEY,
														RECORD_DATE,
														RECORD_IP,
														RECORD_EMP,
														UPDATE_DATE,
														UPDATE_IP,
														UPDATE_EMP,
														IS_LOCKED,
														PROCESS_DATE
													FROM
														SETUP_PERIOD
													WHERE
														PERIOD_ID IN (#ship_period_list#) AND IS_ACTIVE <> 0
												</cfquery>
									
												<cfloop query="get_ship_periods_">
													<cfset new_dsn2 = '#dsn#_#get_ship_periods_.PERIOD_YEAR#_#get_ship_periods_.OUR_COMPANY_ID#'>
													<cfif listlen(ship_period_list) eq 1>
														<cfset control_ship_list=valuelist(control_order_ship.SHIP_ID)>
														<!--- bu kontrolle direk siparişten olusturulmus (irsaliyeli) fatura kayıtlarına da ulaşılabiliyor. --->
														<cfquery name="control_invoice_ships" datasource="#new_dsn2#">
															SELECT SHIP_ID, INVOICE_ID FROM INVOICE_SHIPS WHERE SHIP_ID IN (#control_ship_list#) AND SHIP_PERIOD_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_ship_periods_.period_id#">
														</cfquery>
														<cfif control_invoice_ships.recordcount>
															<cfset control_is_iptal_list=valuelist(control_invoice_ships.INVOICE_ID)>
															<cfquery name="control_is_iptal" datasource="#new_dsn2#">
																SELECT IS_IPTAL FROM INVOICE WHERE INVOICE_ID IN (#control_is_iptal_list#)
															</cfquery>
															<cfset is_iptal_count = 0>
															<cfloop query="control_is_iptal">
																<cfif control_is_iptal.is_iptal eq 1>
																	<cfset is_iptal_count = 1>
																</cfif>
															</cfloop>
															<cfif is_iptal_count eq 1>
																
																<cfset faturalandi_ = 1>
															<cfelse>
																<cfset faturalandi_ = 2>
															</cfif>
														</cfif>
													</cfif>
												</cfloop>
												<cfif faturalandi_ eq 1>
													<span class="basketFooterInfo"><font color="red"><cf_get_lang dictionary_id= "58750.Fatura iptal"></font></span>
												<cfelseif control_order_invoice.recordcount >
													<cf_get_lang dictionary_id='41115.Faturalandi'>
												<cfelseif isdefined('faturalandi_') and len(faturalandi_) and faturalandi_ eq 2>
													<cf_get_lang dictionary_id='41115.Faturalandi'>
												</cfif>
											<cfelseif  control_order_invoice.recordcount >
												<cf_get_lang dictionary_id='41115.Faturalandi'>
											</cfif>
										<!----</cfif>---->
									</cfif>
									</font>
								</cfif>
							</td>
						<td>
								<cfif isdefined("get_order_list.project_id") and len(get_order_list.project_id)> 
									<a href="#request.self#?fuseaction=project.projects&event=det&id=#order_project.project_id[listfind(project_name_list,project_id,',')]#" class="tableyazi">#order_project.project_head[listfind(project_name_list,project_id,',')]#</a>
								<cfelse>
									<cf_get_lang dictionary_id='58459.projesiz'>
								</cfif>
							</td>
							<cfif (isdefined('attributes.listing_type') and attributes.listing_type eq 2)><!--- Eger satir bazinda listeleme yapiliyorsa --->
								<td style="text-align:right; mso-number-format:'0\.00'">#quantity#</td>
								<td style="text-align:right;">#cancel_amount#</td>
								<td>#unit#</td>
							</cfif>
							<td style="text-align:right;"><cfif len(Nettotal) and len(Taxtotal)>#TlFormat(Nettotal-Taxtotal)#</cfif></td>
							<td style="text-align:right;"><cfif len(NETTOTAL)>#TLFormat(NETTOTAL)# </cfif></td>
							<td>&nbsp;<cfif len(NETTOTAL)>#session.ep.money#</cfif></td>
							<td style="text-align:right;"><cfif len(OTHER_MONEY_VALUE) and len(Taxtotal)>#TLFormat(OTHER_MONEY_VALUE-(Taxtotal/MONEY_RATE))#</cfif></td>
							<td style="text-align:right;"><cfif len(OTHER_MONEY_VALUE)>#TLFormat(OTHER_MONEY_VALUE)#</cfif></td>
							<td>#OTHER_MONEY#</td>							
							<td align="center">
								<cfif order_status eq 1>
									<a href="javascript://" onclick="mng_kargo('#order_number#');"><img src="/images/MNG.png" title="<cf_get_lang dictionary_id='41341.MNG Kargo Bilgileri'>"></a> 
								</cfif>
							</td>							
							<td align="center">
								<cfif len(sales_add_option_id) and session.ep.our_company_info.subscription_contract eq 1>#get_sale_add_option_name.sales_add_option_name[listfind(sale_add_option_id_list,sales_add_option_id,',')]#</cfif>
							</td>
							<td>#ref_no#</td>
							<td>#ORDER_PAYMETHOD#</td>
							<!-- sil -->
							<td align="center">
								<cfif is_instalment eq 1>
									<a href="#request.self#?fuseaction=#listgetat(attributes.fuseaction,1,'.')#.list_order_instalment&event=upd&order_id=#ORDER_ID#"><i class="fa fa-pencil" title="<cf_get_lang dictionary_id='57464.Güncelle'>" alt="<cf_get_lang dictionary_id='57464.Güncelle'>"></i></a>
								<cfelse>	
									<a href="#request.self#?fuseaction=#listgetat(attributes.fuseaction,1,'.')#.list_order&event=upd&order_id=#ORDER_ID#"><i class="fa fa-pencil" title="<cf_get_lang dictionary_id='57464.Güncelle'>" alt="<cf_get_lang dictionary_id='57464.Güncelle'>"></i></a>
								</cfif>
							</td>
							
							<!--- <td align="center">
								<a href="javascript://" onclick="window.open('#request.self#?fuseaction=objects.popup_print_files&action=sales.list_order&action_id=#order_id#&print_type=73','WOC');"><i class="fa fa-print" title="<cf_get_lang dictionary_id='57474.Yazdir'>"></i></a>
							</td> --->
							<!--- <cfif x_select_row_print eq 1 and attributes.listing_type eq 1> 
								<td class="text-center"><input type="checkbox" name="print_islem_id" id="print_islem_id" value="#order_id#"></td>
							</cfif> --->
							
								<td style="text-align:center"><input type="checkbox" name="print_order_id" id="print_order_id"  value="#order_id#"></td>
							<!-- sil -->
						</tr>
						
						<cfif (isdefined('attributes.listing_type') and attributes.listing_type eq 2)><!--- Eger satir bazinda listeleme yapiliyorsa --->
							<tr id="order_stocks_detail#currentrow#" class="nohover el_hidden" style="display:none"><!--- Uidrop excel exportta görünmemesi gereken alanlar gizlendi(class:el_hidden) --->
								<td colspan="25">
									<div align="left" id="DISPLAY_ORDER_STOCK_INFO#currentrow#"></div>
								</td>
							</tr>
						</cfif>
						
						</cfoutput> 
					<cfelse>
						<cfset colspan = 24>
						<cfif (isdefined('attributes.listing_type') and attributes.listing_type eq 2)>
							<cfset colspan = colspan + 1>
						</cfif>
						<cfif (isdefined('attributes.listing_type') and attributes.listing_type eq 2)>
							<cfset colspan = colspan + 2>
							<cfif x_show_spec_info>
								<cfset colspan = colspan + 1>
							</cfif>
						</cfif>
						<cfif (isdefined('attributes.listing_type') and attributes.listing_type eq 2)>
							<cfset colspan = colspan + 3>
						</cfif>
						<!--- <cfif x_select_row_print eq 1 and attributes.listing_type eq 1 and get_order_list.recordcount>
							<cfset colspan = colspan + 1>
						</cfif> --->
						<tr>
							<td colspan="<cfif arama_yapilmali neq 1><cfoutput>#colspan#</cfoutput><cfelse><cfoutput>#colspan#-1</cfoutput></cfif>"><cfif arama_yapilmali neq 1><cf_get_lang dictionary_id='57484.Kayit Yok'>!<cfelse><cf_get_lang dictionary_id='57701.Filtre Ediniz '>!</cfif></td>
						</tr>
					</cfif>
				</tbody>
		<!---	</table>--->
			</cf_grid_list>
			<!--- TableToExcel fonksiyonunda td içine js scripti bastığı için fonksiyon table dışına taşındı --->
			<script language="javascript">
				function mng_kargo(o_number)
				{
					var get_mng_result = wrk_safe_query('obj2_get_mng_result','SorunTakip',0,o_number);
					if(get_mng_result.recordcount > 0)
					{
						var fatseri = get_mng_result.FATSERI;
						var fatnumara = get_mng_result.FATNO;
						window.open('http://www.mngkargo.com.tr/iactive/takip.asp?fatseri='+fatseri+'&fatnumara='+fatnumara+'&fi=2','_blank');
					}
					else if(get_mng_result.recordcount == 0)
					{
						alert("<cfoutput>#getLang('','Kargo Bilgisi Ulasmamistir',60881)#</cfoutput>!");
						return false;
					}
					else
					{
						alert("<cfoutput>#getLang('','MNG Entegrasyonu Datasi ekildigi Iin Production Ortaminda Hata Verebilir. XML Tanimini Kontrol Ediniz.',60882)#</cfoutput>");
					}
				}
			</script>
		</div>
		</form>
		
		<cfif isdefined("attributes.member_type") and len(attributes.member_type)>
			<cfset url_str = url_str & "&member_type=#attributes.member_type#&member_name=#attributes.member_name#">
		</cfif>
		<cfif isdefined("attributes.company_id") and len(attributes.company_id)>
			<cfset url_str = url_str & "&company_id=#attributes.company_id#">
		</cfif>
		<cfif isdefined("attributes.product_id") and len(attributes.product_id) and isdefined("attributes.product_name") and len(attributes.product_name)>
			<cfset url_str = url_str & "&product_id=#attributes.product_id#&product_name=#attributes.product_name#">
		</cfif>
		<cfif isdefined("attributes.short_code_id") and len(attributes.short_code_id) and isdefined("attributes.short_code_name") and len(attributes.short_code_name)>
			<cfset url_str = url_str & "&short_code_id=#attributes.short_code_id#&short_code_name=#attributes.short_code_name#">
		</cfif>
		<cfif isdefined("attributes.employee_id") and len(attributes.employee_id) and isdefined("attributes.employee") and len(attributes.employee)>
			<cfset url_str = url_str & "&employee_id=#attributes.employee_id#&employee=#attributes.employee#">
		</cfif>
		<cfif isdefined("attributes.prod_cat") and len(attributes.prod_cat)>
			<cfset url_str = url_str & "&prod_cat=#attributes.prod_cat#">
		</cfif>
		<cfif isdefined("attributes.brand_id") and len(attributes.brand_id) and isdefined("attributes.brand_name") and len(attributes.brand_name)>
			<cfset url_str = url_str & "&brand_id=#attributes.brand_id#&brand_name=#attributes.brand_name#">
		</cfif>
		<cfif isdefined("attributes.project_id") and len(attributes.project_id) and isdefined("attributes.project_head") and len(attributes.project_head)>
			<cfset url_str = url_str & "&project_id=#attributes.project_id#&project_head=#URLEncodedFormat(attributes.project_head)#">
		</cfif>
		<cfif isdefined("attributes.subscription_id") and len(attributes.subscription_id) and isdefined("attributes.subscription_no") and len(attributes.subscription_no)>
			<cfset url_str = url_str & "&subscription_id=#attributes.subscription_id#&subscription_no=#attributes.subscription_no#">
		</cfif>
		<cfif isdefined("attributes.product_manager") and len(attributes.product_manager) and isdefined("attributes.product_manager_name") and len(attributes.product_manager_name)>
			<cfset url_str = url_str & "&product_manager=#attributes.product_manager#&product_manager_name=#attributes.product_manager_name#">
		</cfif>
		<cfif isdefined("attributes.consumer_id") and len(attributes.consumer_id)>
			<cfset url_str = url_str & "&consumer_id=#attributes.consumer_id#">
		</cfif>
		<cfif isdefined("attributes.order_employee_id") and len(attributes.order_employee_id)> 
			<cfset url_str = url_str & "&order_employee_id=#attributes.order_employee_id#&order_employee=#attributes.order_employee#">
		</cfif>
		<cfif isdefined("attributes.sales_member_id") and len(attributes.sales_member_id)>
			<cfset url_str = url_str & "&sales_member_id=#attributes.sales_member_id#&sales_member_name=#attributes.sales_member_name#">
		</cfif>
		<cfif isdefined("attributes.order_stage") and len(attributes.order_stage)>
			<cfset url_str = url_str & "&order_stage=#attributes.order_stage#">
		</cfif>
		<cfif isdefined("attributes.sales_county") and len(attributes.sales_county)>
			<cfset url_str = url_str & "&sales_county=#attributes.sales_county#">
		</cfif>
		<cfif isdefined("attributes.sale_add_option") and len(attributes.sale_add_option)>
			<cfset url_str = "#url_str#&sale_add_option=#attributes.sale_add_option#">
		</cfif>	
		<cfif isdefined("attributes.is_instalment") and len(attributes.is_instalment)>
			<cfset url_str = "#url_str#&is_instalment=#attributes.is_instalment#">
		</cfif>
		<cfif isdefined("attributes.location_name") and len(attributes.location_name)>
			<cfset url_str = "#url_str#&location_name=#attributes.location_name#&sales_departments=#attributes.location_name#&department_id=#attributes.department_id#&location_id=#attributes.location_id#">
		</cfif>
		<cfif isdefined("attributes.listing_type") and len(attributes.listing_type)>
			<cfset url_str = "#url_str#&listing_type=#attributes.listing_type#">
		</cfif>
		<cfif isdefined("attributes.filter_branch_id") and len(attributes.filter_branch_id)>
			<cfset url_str = "#url_str#&filter_branch_id=#attributes.filter_branch_id#">
		</cfif>
		<cfif isdefined("attributes.zone_id") and len(attributes.zone_id)>
			<cfset url_str = "#url_str#&zone_id=#attributes.zone_id#">
		</cfif>
		<cfif isdate(attributes.start_date)>
			<cfset url_str = url_str & "&start_date=#dateformat(attributes.start_date,dateformat_style)#">
		</cfif>
		<cfif isdate(attributes.finish_date)>
			<cfset url_str = url_str & "&finish_date=#dateformat(attributes.finish_date,dateformat_style)#">
		</cfif>
		<cfif isdefined("attributes.card_paymethod_id") and len(attributes.card_paymethod_id)>
			<cfset url_str = "#url_str#&card_paymethod_id=#attributes.card_paymethod_id#">
		</cfif>
		<cfif isdefined("attributes.paymethod_id") and len(attributes.paymethod_id)>
			<cfset url_str = "#url_str#&paymethod_id=#attributes.paymethod_id#">
		</cfif>
		<cfif isdefined("attributes.paymethod") and len(attributes.paymethod)>
			<cfset url_str = "#url_str#&paymethod=#attributes.paymethod#">
		</cfif>
		<cfif isdefined("attributes.irsaliye_fatura") and len(attributes.irsaliye_fatura)>
			<cfset url_str = "#url_str#&irsaliye_fatura=#attributes.irsaliye_fatura#">
		</cfif>
		<cfif isdefined("attributes.record_emp_id") and len(attributes.record_emp_id)>
			<cfset url_str = "#url_str#&record_emp_id=#attributes.record_emp_id#">
		</cfif>
		<cfif isdefined("attributes.record_cons_id") and len(attributes.record_cons_id)>
			<cfset url_str = "#url_str#&record_cons_id=#attributes.record_cons_id#">
		</cfif>
		<cfif isdefined("attributes.record_part_id") and len(attributes.record_part_id)>
			<cfset url_str = "#url_str#&record_part_id=#attributes.record_part_id#">
		</cfif>
		<cfif isdefined("attributes.record_name") and len(attributes.record_name)>
			<cfset url_str = "#url_str#&record_name=#attributes.record_name#">
		</cfif>
		<cfif isdefined('attributes.use_efatura') and len(attributes.use_efatura)>
			<cfset url_str = "#url_str#&use_efatura=#attributes.use_efatura#">
		</cfif>
		<cfif isdefined('attributes.related_orders') and len(attributes.related_orders)>
			<cfset url_str = "#url_str#&related_orders=#attributes.related_orders#">
		</cfif>
		<cfset url_str = url_str & "&sort_type=#attributes.sort_type#">
		<cf_paging page="#attributes.page#" maxrows="#attributes.maxrows#" totalrecords="#attributes.totalrecords#" startrow="#attributes.startrow#" adres="#attributes.fuseaction#&#url_str#&form_varmi=1">
	</cf_box>
</div>

<script type="text/javascript">
	$(document).ready(function() {
    $('#keyword').focus();
});
/* 	<cfif x_select_row_print eq 1 and attributes.listing_type eq 1>
		function send_print_()
		{
			<cfif not get_order_list.recordcount>
				alert("<cf_get_lang dictionary_id='40885.Yazdirilacak Belge Bulunamadi! Toplu Print Yapamazsiniz'>!");
				return false;
			<cfelseif get_order_list.recordcount eq 1>
				if(document.send_print_page.print_islem_id.checked == false)
				{
					alert("<cf_get_lang dictionary_id='40885.Yazdirilacak Belge Bulunamadi! Toplu Print Yapamazsiniz'>!");
					return false;
				}
				else
				{
					ship_list_ = document.send_print_page.print_islem_id.value;
				}
			<cfelseif get_order_list.recordcount gt 1>
				ship_list_ = "";
				for (i=0; i < document.send_print_page.print_islem_id.length; i++)
				{
					if(document.send_print_page.print_islem_id[i].checked == true)
						{
						ship_list_ = ship_list_ + document.send_print_page.print_islem_id[i].value + ',';
						}	
				}
				if(ship_list_.length == 0)
					{
					alert("<cf_get_lang dictionary_id='40885.Yazdirilacak Belge Bulunamadi! Toplu Print Yapamazsiniz'>!");
					return false;
					}																							
			window.open('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_print_files&print_type=73&iid='+ship_list_,'page');
			<cfelse>
					alert("<cf_get_lang dictionary_id='40885.Yazdirilacak Belge Bulunamadi! Toplu Print Yapamazsiniz'>!");
					return false;
				</cfif>
		}
	</cfif> */
	function input_control()
	{
		if( !date_check(document.getElementById('start_date'), document.getElementById('finish_date'), "<cfoutput>#getLang('','Baslangi Tarihi Bitis Tarihinden Byk Olamaz',58862)#</cfoutput>!") )
			return false;

		<cfif not session.ep.our_company_info.unconditional_list>
			if(document.getElementById('keyword').value.length == 0 && document.getElementById('keyword_orderno').value.length == 0 && (document.getElementById('employee_id').value.length == 0 || document.getElementById('employee').value.length == 0) &&(document.getElementById('member_name').value.length == 0 || document.getElementById('company_id').value.length == 0) &&( document.getElementById('consumer_id').value.length == 0) && (document.getElementById('sales_member_id').value.length == 0 || document.getElementById('sales_member_name').value.length == 0)&&(document.getElementById('start_date').value.length ==0) && (document.getElementById('finish_date').value.length ==0) )
				{
					alert("<cfoutput>#getLang('','En az bir alanda filtre etmelisiniz',58950)#</cfoutput>!");
					return false;
				}
			else return true;
		<cfelse>
			return true;
		</cfif>
	}
	
	function connectAjax(crtrow,prod_id,stock_id,unit_,order_amount)
	{
		var bb = '<cfoutput>#request.self#?fuseaction=objects.emptypopup_ajax_product_stock_info&sales=1</cfoutput>&pid='+prod_id+'&sid='+ stock_id+'&amount='+ order_amount;
		AjaxPageLoad(bb,'DISPLAY_ORDER_STOCK_INFO'+crtrow,1);
	}
	function remove_product_manager()
	{
		if(document.getElementById('listing_type').value == 1)
			{
				document.getElementById('form_ul_employee').style.display = 'none';
			}
		else
			document.getElementById('form_ul_employee').style.display = '';
	}
	function openmodal(){
		cfmodal('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.basket_in_basket', 'warning_modal');
	}
	
	$("#li_excel" ).click(function() {
		TableToExcel.convert(document.getElementById('sales_list'));
		$("#working_div_main").hide();
	});
</script>
<cf_get_lang_set module_name="#lcase(listgetat(attributes.fuseaction,1,'.'))#"><!--- sayfanin en ustunde acilisi var --->
<cfsetting showdebugoutput="yes"> 