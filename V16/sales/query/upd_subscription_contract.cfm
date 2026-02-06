<cfset contract_cmp = createObject("component","V16.sales.cfc.subscription_contract")>
<cfset attributes.subscription_no = Trim(attributes.subscription_no)>
<cfset CHECK_NO = contract_cmp.CHECK_NO_UPD(dsn3:dsn3, subscription_id:attributes.subscription_id, subscription_no:attributes.subscription_no)>
<cfif check_no.recordcount>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id ='41394.Aynı Sistem No ile Kayıt Var'>!");
		window.location.href='<cfoutput>#cgi.referer#</cfoutput>';
	</script>
	<cfabort>
</cfif>
<cfif isdefined("attributes.sales_member_comm_value")>
	<cfset attributes.sales_member_comm_value = filterNum(attributes.sales_member_comm_value)>
</cfif>
<cfif isdefined("attributes.montage_date") and len(attributes.montage_date)><cf_date tarih="attributes.montage_date"></cfif>
<cfif isdefined("attributes.start_date") and len(attributes.start_date)><cf_date tarih="attributes.start_date"></cfif>
<cfif isdefined("attributes.finish_date") and len(attributes.finish_date)><cf_date tarih="attributes.finish_date"></cfif>
<cflock name="#CREATEUUID()#" timeout="60">
	<cftransaction>
		<cfset UPD_SUBSCRIPTION_CONTRACT = contract_cmp.UPD_SUBSCRIPTION_CONTRACT(
			subscription_id:attributes.subscription_id,
			dsn:dsn3,
			invoice_member_name:'#iIf(isDefined("attributes.invoice_member_name") and len(attributes.invoice_member_name),"attributes.invoice_member_name",DE(""))#',
			invoice_company_id:'#iIf(isDefined("attributes.invoice_company_id") and len(attributes.invoice_company_id),"attributes.invoice_company_id",DE(""))#',
			invoice_partner_id:'#iIf(isDefined("attributes.invoice_partner_id") and len(attributes.invoice_partner_id),"attributes.invoice_partner_id",DE(""))#',
			invoice_consumer_id:'#iIf(isDefined("attributes.invoice_consumer_id") and len(attributes.invoice_consumer_id),"attributes.invoice_consumer_id",DE(""))#',
			member_type:'#iIf(isDefined("attributes.member_type") and len(attributes.member_type),"attributes.member_type",DE(""))#',
			company_id:'#iIf(isDefined("attributes.company_id") and len(attributes.company_id),"attributes.company_id",DE(""))#',
			partner_id:'#iIf(isDefined("attributes.partner_id") and len(attributes.partner_id),"attributes.partner_id",DE(""))#',
			consumer_id:'#iIf(isDefined("attributes.consumer_id") and len(attributes.consumer_id),"attributes.consumer_id",DE(""))#',
			subscription_no:trim(attributes.subscription_no),
			is_active:'#iIf(isDefined("attributes.is_active") and len(attributes.is_active),"attributes.is_active",DE(""))#',
			subscription_head:'#iIf(isDefined("attributes.subscription_head") and len(attributes.subscription_head),"attributes.subscription_head",DE(""))#',
			subscription_type:'#iIf(isDefined("attributes.subscription_type") and len(attributes.subscription_type),"attributes.subscription_type",DE(""))#',
			process_stage:'#iIf(isDefined("attributes.process_stage") and len(attributes.process_stage),"attributes.process_stage",DE(""))#',
			sales_emp_id:'#iIf(isDefined("attributes.sales_emp_id") and len(attributes.sales_emp_id) and len(attributes.sales_emp),"attributes.sales_emp_id",DE(""))#',
			sales_member_type:'#iIf(isDefined("attributes.sales_member_type") and len(attributes.sales_member_type),"attributes.sales_member_type",DE(""))#',
			sales_member_id:'#iIf(isdefined("attributes.sales_member") and len(attributes.sales_member) and isDefined("attributes.sales_member_id") and len(attributes.sales_member_id),"attributes.sales_member_id",DE(""))#',
			sales_company_id:'#iIf(isdefined("attributes.sales_member") and len(attributes.sales_member) and isDefined("attributes.sales_company_id") and len(attributes.sales_company_id),"attributes.sales_company_id",DE(""))#',
			sales_member_comm_value:'#iIf(isDefined("attributes.sales_member_comm_value") and len(attributes.sales_member_comm_value),"attributes.sales_member_comm_value",DE(""))#',
			sales_member_comm_money:'#iIf(isDefined("attributes.sales_member_comm_money") and len(attributes.sales_member_comm_money),"attributes.sales_member_comm_money",DE(""))#',
			ref_member_type:'#iIf(isDefined("attributes.ref_member_type") and len(attributes.ref_member_type),"attributes.ref_member_type",DE(""))#',
			ref_member_id:'#iIf(isDefined("attributes.ref_member") and len(attributes.ref_member) and isDefined("attributes.ref_member_id") and len(attributes.ref_member_id),"attributes.ref_member_id",DE(""))#',
			ref_company_id:'#iIf(isDefined("attributes.ref_company") and len(attributes.ref_company) and isDefined("attributes.ref_company_id") and len(attributes.ref_company_id),"attributes.ref_company_id",DE(""))#',
			subscription_product_id:'#iIf(isDefined("attributes.subscription_product_id") and len(attributes.subscription_product_id) and len(attributes.subscription_product_name),"attributes.subscription_product_id",DE(""))#',
			subscription_stock_id:'#iIf(isDefined("attributes.subscription_stock_id") and len(attributes.subscription_stock_id) and len(attributes.subscription_product_name),"attributes.subscription_stock_id",DE(""))#',
			contract_no:'#iIf(isDefined("attributes.contract_no") and len(attributes.contract_no),"trim(attributes.contract_no)",DE(""))#',
			montage_emp_id:'#iIf(isDefined("attributes.montage_emp_id") and len(attributes.montage_emp_id) and len(attributes.montage_emp),"attributes.montage_emp_id",DE(""))#',
			payment_type_id:'#iIf(isDefined("attributes.payment_type_id") and len(attributes.payment_type_id),"attributes.payment_type_id",DE(""))#',
			payment_type_creditcard_id:'#iIf(isDefined("attributes.payment_type_creditcard_id") and len(attributes.payment_type_creditcard_id),"attributes.payment_type_creditcard_id",DE(""))#',
			montage_date:'#iIf(isDefined("attributes.montage_date") and len(attributes.montage_date),"attributes.montage_date",DE(""))#',
			start_date:'#iIf(isDefined("attributes.start_date") and len(attributes.start_date),"attributes.start_date",DE(""))#',
			finish_date:'#iIf(isDefined("attributes.finish_date") and len(attributes.finish_date),"attributes.finish_date",DE(""))#',
			detail:'#iIf(isDefined("attributes.detail") and len(attributes.detail),"attributes.detail",DE(""))#',
			detail_2:'#iIf(isDefined("attributes.detail_2") and len(attributes.detail_2),"left(attributes.detail_2,500)",DE(""))#',
			inv_detail:'#iIf(isDefined("attributes.inv_detail") and len(attributes.inv_detail),"left(attributes.inv_detail,500)",DE(""))#',
			credit_card_id:'#iIf(isDefined("attributes.credit_card_id") and len(attributes.credit_card_id),"attributes.credit_card_id",DE(""))#',
			main_special_code:'#iIf(isDefined("attributes.main_special_code") and len(attributes.main_special_code),"trim(attributes.main_special_code)",DE(""))#',
			ship_address:'#iIf(isDefined("attributes.ship_address") and len(attributes.ship_address),"trim(attributes.ship_address)",DE(""))#',
			ship_postcode:'#iIf(isDefined("attributes.ship_postcode") and len(attributes.ship_postcode),"trim(attributes.ship_postcode)",DE(""))#',
			ship_semt:'#iIf(isDefined("attributes.ship_semt") and len(attributes.ship_semt),"attributes.ship_semt",DE(""))#',
			ship_county_id:'#iIf(isDefined("attributes.ship_county_id") and len(attributes.ship_county_id),"attributes.ship_county_id",DE(""))#',
			ship_city_id:'#iIf(isDefined("attributes.ship_city_id") and len(attributes.ship_city_id),"attributes.ship_city_id",DE(""))#',
			ship_country_id:'#iIf(isDefined("attributes.ship_country_id") and len(attributes.ship_country_id),"attributes.ship_country_id",DE(""))#',
			ship_coordinate_1:'#iIf(isDefined("attributes.ship_coordinate_1") and len(attributes.ship_coordinate_1),"attributes.ship_coordinate_1",DE(""))#',
			ship_coordinate_2:'#iIf(isDefined("attributes.ship_coordinate_2") and len(attributes.ship_coordinate_2),"attributes.ship_coordinate_2",DE(""))#',
			ship_sales_zone_id:'#iIf(isDefined("attributes.ship_sales_zone_id") and len(attributes.ship_sales_zone_id),"attributes.ship_sales_zone_id",DE(""))#',
			invoice_address:'#iIf(isDefined("attributes.invoice_address") and len(attributes.invoice_address),"trim(attributes.invoice_address)",DE(""))#',
			invoice_postcode:'#iIf(isDefined("attributes.invoice_postcode") and len(attributes.invoice_postcode),"trim(attributes.invoice_postcode)",DE(""))#',
			invoice_semt:'#iIf(isDefined("attributes.invoice_semt") and len(attributes.invoice_semt),"trim(attributes.invoice_semt)",DE(""))#',
			invoice_county_id:'#iIf(isDefined("attributes.invoice_county_id") and len(attributes.invoice_county_id),"attributes.invoice_county_id",DE(""))#',
			invoice_city_id:'#iIf(isDefined("attributes.invoice_city_id") and len(attributes.invoice_city_id),"attributes.invoice_city_id",DE(""))#',
			invoice_country_id:'#iIf(isDefined("attributes.invoice_country_id") and len(attributes.invoice_country_id),"attributes.invoice_country_id",DE(""))#',
			invoice_coordinate_1:'#iIf(isDefined("attributes.invoice_coordinate_1") and len(attributes.invoice_coordinate_1),"attributes.invoice_coordinate_1",DE(""))#',
			invoice_coordinate_2:'#iIf(isDefined("attributes.invoice_coordinate_2") and len(attributes.invoice_coordinate_2),"attributes.invoice_coordinate_2",DE(""))#',
			invoice_sales_zone_id:'#iIf(isDefined("attributes.invoice_sales_zone_id") and len(attributes.invoice_sales_zone_id),"attributes.invoice_sales_zone_id",DE(""))#',
			ship_id:'#iIf(isDefined("attributes.ship_id") and len(attributes.ship_id),"attributes.ship_id",DE(""))#',
			contact_address:'#iIf(isDefined("attributes.contact_address") and len(attributes.contact_address),"trim(attributes.contact_address)",DE(""))#',
			contact_postcode:'#iIf(isDefined("attributes.contact_postcode") and len(attributes.contact_postcode),"trim(attributes.contact_postcode)",DE(""))#',
			contact_semt:'#iIf(isDefined("attributes.contact_semt") and len(attributes.contact_semt),"trim(attributes.contact_semt)",DE(""))#',
			contact_county_id:'#iIf(isDefined("attributes.contact_county_id") and len(attributes.contact_county_id),"attributes.contact_county_id",DE(""))#',
			contact_city_id:'#iIf(isDefined("attributes.contact_city_id") and len(attributes.contact_city_id),"attributes.contact_city_id",DE(""))#',
			contact_country_id:'#iIf(isDefined("attributes.contact_country_id") and len(attributes.contact_country_id),"attributes.contact_country_id",DE(""))#',
			contact_coordinate_1:'#iIf(isDefined("attributes.contact_coordinate_1") and len(attributes.contact_coordinate_1),"attributes.contact_coordinate_1",DE(""))#',
			contact_coordinate_2:'#iIf(isDefined("attributes.contact_coordinate_2") and len(attributes.contact_coordinate_2),"attributes.contact_coordinate_2",DE(""))#',
			contact_sales_zone_id:'#iIf(isDefined("attributes.contact_sales_zone_id") and len(attributes.contact_sales_zone_id),"attributes.contact_sales_zone_id",DE(""))#',
			BASKET_DISCOUNT_TOTAL:'#iIf(isDefined("attributes.BASKET_DISCOUNT_TOTAL") and len(attributes.BASKET_DISCOUNT_TOTAL),"attributes.BASKET_DISCOUNT_TOTAL",DE(""))#',
			basket_net_total:'#iIf(isDefined("attributes.basket_net_total") and len(attributes.basket_net_total),"attributes.basket_net_total",DE(""))#',
			basket_gross_total:'#iIf(isDefined("attributes.basket_gross_total") and len(attributes.basket_gross_total),"attributes.basket_gross_total",DE(""))#',
			basket_tax_total:'#iIf(isDefined("attributes.basket_tax_total") and len(attributes.basket_tax_total),"attributes.basket_tax_total",DE(""))#',
			basket_otv_total:'#iIf(isDefined("attributes.basket_otv_total") and len(attributes.basket_otv_total),"attributes.basket_otv_total",DE(""))#',
			basket_money:'#iIf(isDefined("attributes.basket_money") and len(attributes.basket_money),"attributes.basket_money",DE(""))#',
			BASKET_RATE1:'#iIf(isDefined("attributes.BASKET_RATE1") and len(attributes.BASKET_RATE1),"attributes.BASKET_RATE1",DE(""))#',
			BASKET_RATE2:'#iIf(isDefined("attributes.BASKET_RATE2") and len(attributes.BASKET_RATE2),"attributes.BASKET_RATE2",DE(""))#',
			subs_add_option:'#iIf(isDefined("attributes.subs_add_option") and len(attributes.subs_add_option),"attributes.subs_add_option",DE(""))#',
			sales_add_option:'#iIf(isDefined("attributes.sales_add_option") and len(attributes.sales_add_option),"attributes.sales_add_option",DE(""))#',
			project_id:'#iIf(isDefined("attributes.project_id") and len(attributes.project_id) and isdefined("attributes.project_head") and len(attributes.project_head),"attributes.project_id",DE(""))#',
			genel_indirim:'#iIf(isDefined("attributes.genel_indirim") and len(attributes.genel_indirim),"form.genel_indirim",DE(""))#',
			asset_id:'#iIf(isDefined("attributes.asset_id") and len(attributes.asset_id),"attributes.asset_id",DE(""))#',
			valid_days:'#iIf(isDefined("attributes.valid_days") and len(attributes.valid_days),"attributes.valid_days",DE(""))#',
			start_clock_1:'#iIf(isDefined("attributes.start_clock_1") and len(attributes.start_clock_1),"attributes.start_clock_1",DE(""))#',
			start_minute_1:'#iIf(isDefined("attributes.start_minute_1") and len(attributes.start_minute_1),"attributes.start_minute_1",DE(""))#',
			finish_clock_1:'#iIf(isDefined("attributes.finish_clock_1") and len(attributes.finish_clock_1),"attributes.finish_clock_1",DE(""))#',
			finish_minute_1:'#iIf(isDefined("attributes.finish_minute_1") and len(attributes.finish_minute_1),"attributes.finish_minute_1",DE(""))#',
			start_clock_2:'#iIf(isDefined("attributes.start_clock_2") and len(attributes.start_clock_2),"attributes.start_clock_2",DE(""))#',
			start_minute_2:'#iIf(isDefined("attributes.start_minute_2") and len(attributes.start_minute_2),"attributes.start_minute_2",DE(""))#',
			finish_clock_2:'#iIf(isDefined("attributes.finish_clock_2") and len(attributes.finish_clock_2),"attributes.finish_clock_2",DE(""))#',
			finish_minute_2:'#iIf(isDefined("attributes.finish_minute_2") and len(attributes.finish_minute_2),"attributes.finish_minute_2",DE(""))#',
			start_clock_3:'#iIf(isDefined("attributes.start_clock_3") and len(attributes.start_clock_3),"attributes.start_clock_3",DE(""))#',
			start_minute_3:'#iIf(isDefined("attributes.start_minute_3") and len(attributes.start_minute_3),"attributes.start_minute_3",DE(""))#',
			finish_clock_3:'#iIf(isDefined("attributes.finish_clock_3") and len(attributes.finish_clock_3),"attributes.finish_clock_3",DE(""))#',
			finish_minute_3:'#iIf(isDefined("attributes.finish_minute_3") and len(attributes.finish_minute_3),"attributes.finish_minute_3",DE(""))#',
			general_date:'#iIf(isDefined("attributes.general_date") and len(attributes.general_date),"attributes.general_date",DE(""))#',
			hour1:'#iIf(isDefined("attributes.hour1") and len(attributes.hour1),"attributes.hour1",DE(""))#',
			minute1:'#iIf(isDefined("attributes.minute1") and len(attributes.minute1),"attributes.minute1",DE(""))#',
			response_hour1:'#iIf(isDefined("attributes.response_hour1") and len(attributes.response_hour1),"attributes.response_hour1",DE(""))#',
			response_minute1:'#iIf(isDefined("attributes.response_minute1") and len(attributes.response_minute1),"attributes.response_minute1",DE(""))#',
			camp_id:'#iIf(isdefined('attributes.camp_name') and len(attributes.camp_name) and isDefined("attributes.camp_id") and len(attributes.camp_id),"attributes.camp_id",DE(""))#',
			opp_id:'#iIf(isDefined("attributes.opp_id") and len(attributes.opp_id),"attributes.opp_id",DE(""))#',
			ref_state:'#iIf(isDefined("attributes.ref_state") and len(attributes.ref_state),"attributes.ref_state",DE(""))#',
			comp_branch:'#iIf(isDefined("attributes.comp_branch") and len(attributes.comp_branch),"attributes.comp_branch",DE(""))#',
			product_key: '#iIf(isDefined("attributes.product_key") and len(attributes.product_key),"attributes.product_key",DE(""))#',
			userid:session.ep.userid,
			remote_addr:cgi.remote_addr,
			our_company_id: '#iIf(isDefined("attributes.our_company_id") and len(attributes.our_company_id),"attributes.our_company_id",DE(""))#'
		)>
		<cfset DEL_SUBSCRIPTION_ROWS = contract_cmp.DEL_SUBSCRIPTION_ROWS(dsn3:dsn3, subscription_id:attributes.subscription_id)>
		<!--- Satirlarin kaydi --->
		<cfif isdefined("attributes.rows_")>
			<cfif attributes.rows_ gt 1 or (attributes.rows_ eq 1 and isdefined("attributes.product_id1") and len(attributes.stock_id1))>
			<cfloop from="1" to="#attributes.rows_#" index="i">
				<cf_date tarih="attributes.deliver_date#i#">
				<cfinclude template="get_dis_amount.cfm">
				<cfif isdefined("attributes.product_id#i#") and len(evaluate("attributes.product_id#i#"))>
					<cfset ADD_CONTRACT_ROW = contract_cmp.ADD_CONTRACT_ROW(
						dsn3:dsn3,
						subscription_id:attributes.subscription_id,
						product_name:left(evaluate('attributes.product_name#i#'),500),
						product_name_other:'#iIf(isdefined('attributes.product_name_other#i#') and len(evaluate('attributes.product_name_other#i#')),"wrk_eval('attributes.product_name_other#i#')",DE(""))#',
						stock_id:evaluate("attributes.stock_id#i#"),
						product_id:evaluate("attributes.product_id#i#"),
						amount:evaluate("attributes.amount#i#"),
						unit:wrk_eval('attributes.unit#i#'),
						unit_id:evaluate("attributes.unit_id#i#"),
						tax:evaluate("attributes.tax#i#"),
						price:evaluate("attributes.price#i#"),
						indirim1:indirim1,
						indirim2:indirim2,
						indirim3:indirim3,
						indirim4:indirim4,
						indirim5:indirim5,
						indirim6:indirim6,
						indirim7:indirim7,
						indirim8:indirim8,
						indirim9:indirim9,
						indirim10:indirim10,
						DISCOUNT_AMOUNT:DISCOUNT_AMOUNT,
						row_lasttotal:evaluate("attributes.row_lasttotal#i#"),
						row_nettotal:evaluate("attributes.row_nettotal#i#"),
						row_taxtotal:evaluate("attributes.row_taxtotal#i#"),
						spect_id:'#iIf(isdefined('attributes.spect_id#i#') and len(evaluate('attributes.spect_id#i#')),"evaluate('attributes.spect_id#i#')",DE(""))#',
						spect_name:'#iIf(isdefined('attributes.spect_id#i#') and len(evaluate('attributes.spect_id#i#')),"wrk_eval('attributes.spect_name#i#')",DE(""))#',
						paymethod_id:'#iIf(isdefined("attributes.paymethod_id#i#") and len(evaluate("attributes.paymethod_id#i#")),"evaluate('attributes.paymethod_id#i#')",DE(""))#',
						lot_no:'#iIf(isdefined('attributes.lot_no#i#') and len(evaluate('attributes.lot_no#i#')),"evaluate('attributes.lot_no#i#')",DE(""))#',
						other_money:'#iIf(isdefined('attributes.other_money_#i#'),"wrk_eval('attributes.other_money_#i#')",DE(""))#',
						other_money_value:'#iIf(isdefined("attributes.other_money_value_#i#") and len(evaluate("attributes.other_money_value_#i#")),"evaluate('attributes.other_money_value_#i#')",DE(""))#',
						price_other:'#iIf(isdefined('attributes.price_other#i#') and len(evaluate('attributes.price_other#i#')),"evaluate('attributes.price_other#i#')",DE(""))#',
						other_money_gross_total:'#iIf(isdefined("attributes.other_money_gross_total#i#") and len(evaluate("attributes.other_money_gross_total#i#")),"evaluate('attributes.other_money_gross_total#i#')",DE(""))#',
						iskonto_tutar:'#iIf(isdefined('attributes.iskonto_tutar#i#') and len(evaluate('attributes.iskonto_tutar#i#')),"evaluate('attributes.iskonto_tutar#i#')",DE(""))#',
						basket_extra_info:'#iIf(isdefined('attributes.basket_extra_info#i#') and len(evaluate('attributes.basket_extra_info#i#')),"evaluate('attributes.basket_extra_info#i#')",DE(""))#',
						select_info_extra:'#iIf(isdefined('attributes.select_info_extra#i#') and len(evaluate('attributes.select_info_extra#i#')),"evaluate('attributes.select_info_extra#i#')",DE(""))#',
						detail_info_extra:'#iIf(isdefined('attributes.detail_info_extra#i#') and len(evaluate('attributes.detail_info_extra#i#')),"evaluate('attributes.detail_info_extra#i#')",DE(""))#',
						deliver_date:'#iIf(isdefined("attributes.deliver_date#i#") and isdate(evaluate('attributes.deliver_date#i#')),"evaluate('attributes.deliver_date#i#')",DE(""))#',
						otv_oran:'#iIf(isdefined('attributes.otv_oran#i#') and len(evaluate('attributes.otv_oran#i#')),"wrk_eval('attributes.otv_oran#i#')",DE(""))#',
						row_otvtotal:'#iIf(isdefined('attributes.row_otvtotal#i#') and len(evaluate('attributes.row_otvtotal#i#')),"evaluate('attributes.row_otvtotal#i#')",DE(""))#',
						extra_cost:'#iIf(isdefined('attributes.extra_cost#i#') and len(evaluate('attributes.extra_cost#i#')),"evaluate('attributes.extra_cost#i#')",DE(""))#',
						list_price:'#iIf(isdefined('attributes.list_price#i#') and len(evaluate('attributes.list_price#i#')),"evaluate('attributes.list_price#i#')",DE(""))#',
						basket_employee_id:'#iIf(isdefined('attributes.basket_employee_id#i#') and len(evaluate('attributes.basket_employee_id#i#')) and isdefined('attributes.basket_employee#i#') and len(evaluate('attributes.basket_employee#i#')),"evaluate('attributes.basket_employee_id#i#')",DE(""))#',
						row_bsmv_rate:'#iIf(isdefined("attributes.row_bsmv_rate#i#") and len(evaluate("attributes.row_bsmv_rate#i#")),"evaluate('attributes.row_bsmv_rate#i#')",DE(""))#',
						row_bsmv_amount:'#iIf(isdefined("attributes.row_bsmv_amount#i#") and len(evaluate("attributes.row_bsmv_amount#i#")),"evaluate('attributes.row_bsmv_amount#i#')",DE(""))#',
						row_bsmv_currency:'#iIf(isdefined("attributes.row_bsmv_currency#i#") and len(evaluate("attributes.row_bsmv_currency#i#")),"evaluate('attributes.row_bsmv_currency#i#')",DE(""))#',
						row_oiv_rate:'#iIf(isdefined("attributes.row_oiv_rate#i#") and len(evaluate("attributes.row_oiv_rate#i#")),"evaluate('attributes.row_oiv_rate#i#')",DE(""))#',
						row_oiv_amount:'#iIf(isdefined("attributes.row_oiv_amount#i#") and len(evaluate("attributes.row_oiv_amount#i#")),"evaluate('attributes.row_oiv_amount#i#')",DE(""))#',
						row_tevkifat_rate:'#iIf(isdefined("attributes.row_tevkifat_rate#i#") and len(evaluate("attributes.row_tevkifat_rate#i#")),"evaluate('attributes.row_tevkifat_rate#i#')",DE(""))#',
						row_tevkifat_amount:'#iIf(isdefined("attributes.row_tevkifat_amount#i#") and len(evaluate("attributes.row_tevkifat_amount#i#")),"evaluate('attributes.row_tevkifat_amount#i#')",DE(""))#'
					)>
				</cfif>
			</cfloop>
			</cfif>
		<cfscript>basket_kur_ekle(action_id:attributes.subscription_id,table_type_id:13,process_type:1);</cfscript>
		</cfif>
	</cftransaction>
</cflock>
<!---Ek Bilgiler--->
<cfset attributes.info_id =  attributes.subscription_id>
<cfset attributes.is_upd = 1>
<cfset attributes.info_type_id = -11>
<cfinclude template="../../objects/query/add_info_plus2.cfm">
<!---Ek Bilgiler--->
<cf_workcube_process 
	is_upd='1'
	data_source='#dsn3#'
	old_process_line='#attributes.old_process_line#'
	process_stage='#attributes.process_stage#' 
	record_member='#session.ep.userid#' 
	record_date='#now()#' 
	action_table='SUBSCRIPTION_CONTRACT'
	action_column='SUBSCRIPTION_ID'
	action_id='#attributes.subscription_id#'
	action_page='#request.self#?fuseaction=sales.list_subscription_contract&event=upd&subscription_id=#attributes.subscription_id#'
	warning_description = '#getLang("","Abonelik",29754)# : #attributes.invoice_member_name#'>
<script type="text/javascript">
	window.location.href='<cfoutput>#request.self#?fuseaction=sales.list_subscription_contract&event=upd&subscription_id=#attributes.subscription_id#<cfif isdefined('attributes.opp_id')>&opp_id=#attributes.opp_id#</cfif></cfoutput>'
</script>
