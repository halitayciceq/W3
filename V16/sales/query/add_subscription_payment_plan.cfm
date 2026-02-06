<cfset contract_cmp = createObject("component","V16.sales.cfc.subscription_contract")>
<cf_date tarih='attributes.start_date'>
<cflock name="#CreateUUID()#" timeout="20">
	<cftransaction>
		<cfset attributes.amount=filterNum(attributes.amount,#session.ep.our_company_info.rate_round_num#)>
		<!--- ödeme planı history kayıtları --->
		<cfset GET_PAYM_PLAN = contract_cmp.GET_PAYM_PLAN(subscription_id : attributes.subscription_id)>
		<cfset history_record = get_paym_plan.recordcount>
		<cfset INSERT_PAYM_PLAN_HISTORY = contract_cmp.INSERT_PAYM_PLAN_HISTORY(subscription_id : attributes.subscription_id)>
	
		<!--- //ödeme planı history kayıtları --->
		<cfset get_subscription_payment_plan = contract_cmp.GET_PAYMENT(subscription_id : attributes.subscription_id)> 
		
		<cfif get_subscription_payment_plan.recordcount gt 0>
			<cfset UPD_PAYMENT_PLAN = contract_cmp.UPD_PAYMENT_PLAN(
									product_id : attributes.product_id,
									stock_id : attributes.stock_id,
									unit : attributes.unit,
									unit_id : attributes.unit_id,
									quantity : attributes.quantity,
									amount : attributes.amount,
									money_type : attributes.money_type,
									period : attributes.period,
									start_date : attributes.start_date,
									process_stage : attributes.process_stage,
									paymethod_id : attributes.paymethod_id,
									card_paymethod_id : attributes.card_paymethod_id,
									subscription_id : attributes.subscription_id)> 
			
		<cfelse>
	 	 	<cfset ADD_PAYMENT_PLAN = contract_cmp.ADD_PAYMENT_PLAN(
									subscription_id : attributes.subscription_id,
									product_id : attributes.product_id,
									stock_id : attributes.stock_id,
									unit : attributes.unit,
									unit_id : attributes.unit_id,
									quantity : attributes.quantity,
									amount : attributes.amount,
									money_type : attributes.money_type,
									period : attributes.period,
									start_date : attributes.start_date,
									paymethod_id : attributes.paymethod_id,
									card_paymethod_id : attributes.card_paymethod_id,
									process_stage : attributes.process_stage)>  
		
			<!--- ilk sistem oluşurken sistemin pirim tarihini günceller --->
			
			<cfset UPD_PREMIUM_DATE = contract_cmp.UPD_PREMIUM_DATE(
										start_date = attributes.start_date,
										subscription_id = attributes.subscription_id)>
		</cfif>
		<cfif attributes.record_num gt 0>
			<cfloop from="#attributes.startrow#" to="#endrow#" index="i">   
				<cf_date tarih='attributes.payment_date#i#'>
				<cfif isdefined("attributes.payment_finish_date#i#")>
					<cf_date tarih='attributes.payment_finish_date#i#'>
				</cfif>
				<cfif (evaluate("attributes.is_disabled_#i#") eq 0 or session.ep.admin eq 1) and ((attributes.xml_change_row eq 1 and isdefined("attributes.is_change#i#")) or attributes.xml_change_row eq 0)><!--- faturalanmışsa o satırlar disable ediliyor --->
					<cfset "attributes.amount#i#" = filterNum(evaluate("attributes.amount#i#"),#session.ep.our_company_info.rate_round_num#)>
					<cfset "attributes.quantity#i#" = filterNum(evaluate("attributes.quantity#i#"))>
					<cfset "attributes.row_total#i#" = filterNum(evaluate("attributes.row_total#i#"),#session.ep.our_company_info.rate_round_num#)>
					<cfset "attributes.discount#i#" = filterNum(evaluate("attributes.discount#i#"))>
					<cfset "attributes.row_bsmv_amount#i#" = filterNum(evaluate("attributes.row_bsmv_amount#i#"),#session.ep.our_company_info.rate_round_num#)>
					<cfset "attributes.row_bsmv_rate#i#" = filterNum(evaluate("attributes.row_bsmv_rate#i#"),#session.ep.our_company_info.rate_round_num#)>
					<cfset "attributes.row_oiv_amount#i#" = filterNum(evaluate("attributes.row_oiv_amount#i#"),#session.ep.our_company_info.rate_round_num#)>
					<cfset "attributes.row_oiv_rate#i#" = filterNum(evaluate("attributes.row_oiv_rate#i#"),#session.ep.our_company_info.rate_round_num#)>
					<cfif isdefined("attributes.row_tevkifat_rate#i#")>
						<cfset "attributes.row_tevkifat_rate#i#" = filterNum(evaluate("attributes.row_tevkifat_rate#i#"),#session.ep.our_company_info.rate_round_num#)>
					<cfelse>
						<cfset "attributes.row_tevkifat_rate#i#" = 0>
					</cfif>
					<cfif isdefined("attributes.row_tevkifat_amount#i#")>
						<cfset "attributes.row_tevkifat_amount#i#" = filterNum(evaluate("attributes.row_tevkifat_amount#i#"),#session.ep.our_company_info.rate_round_num#)>
					<cfelse>
						<cfset "attributes.row_tevkifat_amount#i#" = 0>
					</cfif>
					<cfif isdefined("attributes.discount_amount#i#")>
						<cfset "attributes.discount_amount#i#" = filterNum(evaluate("attributes.discount_amount#i#"))>
					<cfelse>
						<cfset "attributes.discount_amount#i#" = 0>
					</cfif>
					<cfif isdefined("attributes.row_net_total#i#")>
						<cfset "attributes.row_net_total#i#" = filterNum(evaluate("attributes.row_net_total#i#"),#session.ep.our_company_info.rate_round_num#)>
					<cfelse>
						<cfset "attributes.row_net_total#i#" = 0>
					</cfif>
					<cfif isdefined("attributes.row_rate#i#")>
						<cfset "attributes.row_rate#i#" = filterNum(evaluate("attributes.row_rate#i#"))>
					</cfif>           
					<cfset UPD_PAYMENT_PLAN_ROW= contract_cmp.UPD_PAYMENT_PLAN_ROW(
												product_id = evaluate("attributes.product_id#i#"),
												stock_id = evaluate("attributes.stock_id#i#"),
												payment_date = evaluate("attributes.payment_date#i#"),
												payment_finish_date = "#isdefined("attributes.payment_finish_date#i#") ? "#evaluate("attributes.payment_finish_date#i#")#" : "" #",
												detail = left(wrk_eval("attributes.detail#i#"),50),
												unit = "#wrk_eval("attributes.unit#i#")#",
												unit_id = "#evaluate("attributes.unit_id#i#")#",
												subscription_id = attributes.subscription_id,
												quantity = "#evaluate("attributes.quantity#i#")#",
												amount = "#len(evaluate("attributes.amount#i#")) ? "#evaluate("attributes.amount#i#")#" : 0 #",
												money_type_row =  "#wrk_eval("attributes.money_type_row#i#")#",
												row_total = "#len(evaluate("attributes.row_total#i#")) ? "#evaluate("attributes.row_total#i#")#" : 0 #",
												discount = "#len(evaluate("attributes.discount#i#")) ? "#evaluate("attributes.discount#i#")#" : 0 #",
												discount_amount = "#len(evaluate("attributes.discount_amount#i#")) ? "#evaluate("attributes.discount_amount#i#")#" : 0 #",
												row_net_total = "#len(evaluate("attributes.row_net_total#i#")) ? "#evaluate("attributes.row_net_total#i#")#" : 0 #",
												is_collected_inv =  "#isDefined("attributes.is_collected_inv#i#") ?  1 : 0 #",
												is_group_inv =  "#isDefined("attributes.is_group_inv#i#") ? 1 : 0 #",
												is_billed = "#isDefined("attributes.is_billed#i#") ? 1 : 0 #" ,
												is_collected_prov = "#isDefined("attributes.is_collected_prov#i#") ? 1 : 0 #",
												is_paid = "#isDefined("attributes.is_paid#i#") ? 1 : 0 #",
												invoice_id = "#isdefined("attributes.invoice_id#i#") and len(evaluate("attributes.invoice_id#i#")) ? "#evaluate("attributes.invoice_id#i#")#" : "" #",
												bill_info =  len(evaluate("attributes.bill_info#i#")),
												period_id = "#isdefined("attributes.period_id#i#") and len(evaluate("attributes.period_id#i#")) ? "#evaluate("attributes.period_id#i#")#" : "" #",
												paymethod_id = "#isDefined("attributes.paymethod_id#i#") and len(evaluate("attributes.paymethod_id#i#")) ? "#evaluate("attributes.paymethod_id#i#")#" : "" #",
												card_paymethod_id = evaluate("attributes.card_paymethod_id#i#"),
												subs_ref_id = "#isdefined('attributes.subs_ref_id#i#') and len(evaluate("attributes.subs_ref_id#i#")) ? "#evaluate("attributes.subs_ref_id#i#")#" : "" #",
												service_id = "#isdefined('attributes.service_id#i#') and len(evaluate("attributes.service_id#i#")) ? "#evaluate("attributes.service_id#i#")#" : "" #",
												call_id ="#isdefined("attributes.call_id#i#") and len(evaluate("attributes.call_id#i#")) and isdefined("attributes.call_no#i#") and len(evaluate("attributes.call_no#i#")) ? "#evaluate("attributes.call_id#i#")#" : ""#",
												camp_id = "#isdefined('attributes.camp_id#i#') and len(evaluate("attributes.camp_id#i#")) and isdefined('attributes.camp_name#i#') and len(evaluate("attributes.camp_name#i#")) ? "#evaluate("attributes.camp_id#i#")#" : ""#",
												cari_action_id = "#isDefined("attributes.is_paid#i#") and isdefined('attributes.cari_action_id#i#') and len(evaluate("attributes.cari_action_id#i#")) ? "#evaluate("attributes.cari_action_id#i#")#" : ""#",
												cari_period_id = "#isDefined("attributes.is_paid#i#") and isdefined('attributes.cari_period_id#i#') and len(evaluate("attributes.cari_period_id#i#")) ? "#evaluate("attributes.cari_period_id#i#")#" : ""#",
												cari_act_type = "#isDefined("attributes.is_paid#i#") and isdefined('attributes.cari_act_type#i#') and len(evaluate("attributes.cari_act_type#i#")) ? "#evaluate("attributes.cari_act_type#i#")#" : ""#",
												cari_act_id = "#isDefined("attributes.is_paid#i#") and isdefined('attributes.cari_act_id#i#') and len(evaluate("attributes.cari_act_id#i#")) ? "#evaluate("attributes.cari_act_id#i#")#" : ""#",
												cari_act_table = "#isDefined("attributes.is_paid#i#") and isdefined('attributes.cari_act_table#i#') and len(evaluate("attributes.cari_act_table#i#")) ? "#evaluate("attributes.cari_act_table#i#")#" : ""#",
												is_active = "#isdefined("attributes.is_active#i#") ? 1 : 0 #",
												row_rate = "#isDefined("attributes.row_rate#i#") and len(evaluate("attributes.row_rate#i#")) ?  "#evaluate("attributes.row_rate#i#")#" : ""#",
												row_reason_code = "#isDefined("attributes.row_reason_code#i#") and len(evaluate("attributes.row_reason_code#i#")) ? "#evaluate("attributes.row_reason_code#i#")#" : "" #",
												row_bsmv_rate = "#evaluate('attributes.row_bsmv_rate#i#')#",
												row_bsmv_amount = "#evaluate('attributes.row_bsmv_amount#i#')#",
												row_oiv_rate = "#evaluate('attributes.row_oiv_rate#i#')#",
												row_oiv_amount = "#evaluate('attributes.row_oiv_amount#i#')#",
												row_tevkifat_rate = "#evaluate('attributes.row_tevkifat_rate#i#')#",
												row_tevkifat_amount = "#evaluate('attributes.row_tevkifat_amount#i#')#",
												payment_row_id = evaluate("attributes.payment_row_id#i#")						
					)> 
					<cfelseif evaluate("attributes.is_disabled_#i#") eq 1>
						<cfset IS_PAID= contract_cmp.IS_PAID( 
										is_collected_prov : "#isDefined("attributes.is_collected_prov#i#") ? 1 : 0 #",
										is_paid : "#isDefined("attributes.is_paid#i#") ? 1 : 0 #",
										payment_row_id : evaluate("attributes.payment_row_id#i#") )>
					</cfif>
			</cfloop>
		</cfif>
	
		<cfloop from="#attributes.record_num+1#" to="#attributes.count_camp + attributes.count + attributes.record_num#" index="i">
			<cfif isdefined("attributes.row_control#i#") and evaluate("attributes.row_control#i#") eq 1>
				<cfset "attributes.amount#i#" = filterNum(evaluate("attributes.amount#i#"),#session.ep.our_company_info.rate_round_num#)>
				<cfset "attributes.row_total#i#" = filterNum(evaluate("attributes.row_total#i#"),#session.ep.our_company_info.rate_round_num#)>
				<cfset "attributes.discount#i#" = filterNum(evaluate("attributes.discount#i#"))>
				<cfset "attributes.row_bsmv_amount#i#" = filterNum(evaluate("attributes.row_bsmv_amount#i#"),#session.ep.our_company_info.rate_round_num#)>
				<cfset "attributes.row_bsmv_rate#i#" = filterNum(evaluate("attributes.row_bsmv_rate#i#"),#session.ep.our_company_info.rate_round_num#)>
				<cfset "attributes.row_oiv_amount#i#" = filterNum(evaluate("attributes.row_oiv_amount#i#"),#session.ep.our_company_info.rate_round_num#)>
				<cfset "attributes.row_oiv_rate#i#" = filterNum(evaluate("attributes.row_oiv_rate#i#"),#session.ep.our_company_info.rate_round_num#)>
				<cfif isdefined("attributes.row_tevkifat_rate#i#")>
					<cfset "attributes.row_tevkifat_rate#i#" = filterNum(evaluate("attributes.row_tevkifat_rate#i#"),#session.ep.our_company_info.rate_round_num#)>
				<cfelse>
					<cfset "attributes.row_tevkifat_rate#i#" = 0>
				</cfif>
				<cfif isdefined("attributes.row_tevkifat_amount#i#")>
					<cfset "attributes.row_tevkifat_amount#i#" = filterNum(evaluate("attributes.row_tevkifat_amount#i#"),#session.ep.our_company_info.rate_round_num#)>
				<cfelse>
					<cfset "attributes.row_tevkifat_amount#i#" = 0>
				</cfif>
				<cfif isdefined("attributes.discount_amount#i#")>
					<cfset "attributes.discount_amount#i#" = filterNum(evaluate("attributes.discount_amount#i#"))>
				<cfelse>
					<cfset "attributes.discount_amount#i#" = 0>
				</cfif>
				<cfif isdefined("attributes.row_net_total#i#")>
					<cfset "attributes.row_net_total#i#" = filterNum(evaluate("attributes.row_net_total#i#"),#session.ep.our_company_info.rate_round_num#)>
				<cfelse>
					<cfset "attributes.row_net_total#i#" = 0>
				</cfif>
				<cfif isdefined("attributes.row_rate#i#")>
					<cfset "attributes.row_rate#i#" = filterNum(evaluate("attributes.row_rate#i#"))>
				</cfif>
				<cf_date tarih='attributes.payment_date#i#'>
				<cfif isdefined("attributes.payment_finish_date#i#")>
					<cf_date tarih='attributes.payment_finish_date#i#'>
				</cfif>
				<cfset  ADD_PAYMENT_PLAN_ROW = contract_cmp.ADD_PAYMENT_PLAN_ROW(
											subscription_id : attributes.subscription_id,
											product_id : "#isdefined("attributes.product_id#i#") and len(evaluate("attributes.product_id#i#")) ? "#evaluate("attributes.product_id#i#")#" : "" #",  
											stock_id : "#isdefined("attributes.stock_id#i#") and len(evaluate("attributes.stock_id#i#")) ? "#evaluate("attributes.stock_id#i#")#" : "" #",
											payment_date : "#isdefined("attributes.payment_date#i#") and len(evaluate("attributes.payment_date#i#")) ? "#evaluate("attributes.payment_date#i#")#" : "" #", 
											payment_finish_date : "#isdefined("attributes.payment_finish_date#i#") and len(evaluate("attributes.payment_finish_date#i#")) ? "#evaluate("attributes.payment_finish_date#i#")#" : "" #",
											detail :"#isdefined("attributes.detail#i#") and len("attributes.detail#i#") ? "#left(wrk_eval("attributes.detail#i#"),50)#" : "" #", 
											unit : "#wrk_eval("attributes.unit#i#")#",  
											unit_id : "#isdefined(evaluate("attributes.unit_id#i#")) and len(evaluate("attributes.unit_id#i#")) ? "#evaluate("attributes.unit_id#i#")#" : 0 #", 
											quantity : "#evaluate("attributes.quantity#i#")#", 
											amount : "#isDefined("attributes.amount#i#") ? "#evaluate("attributes.amount#i#")#" : "" #",
											money_type_row :"#evaluate("attributes.money_type_row#i#")#", 
											row_total : "#len(evaluate("attributes.row_total#i#")) ? "#evaluate("attributes.row_total#i#")#" : 0 #",
											discount : "#len(evaluate("attributes.discount#i#")) ? "#evaluate("attributes.discount#i#")#" : 0 #",
											discount_amount : "#len(evaluate("attributes.discount_amount#i#")) ? "#evaluate("attributes.discount_amount#i#")#" : 0 #",
											row_net_total : "#len(evaluate("attributes.row_net_total#i#")) ? "#evaluate("attributes.row_net_total#i#")#" : 0 #",
											is_collected_inv : "#isDefined("attributes.is_collected_inv#i#") ? 1 : 0 #",
											is_group_inv : "#isDefined("attributes.is_group_inv#i#") ? 1 : 0 #",
											is_billed : "#isDefined("attributes.is_billed#i#")  or isdefined("arguments.invoice_id#i#") ? 1 : 0 #",
											is_collected_prov : "#isDefined("attributes.is_collected_prov#i#") ? 1 : 0 #",
											is_paid : "#isDefined("attributes.is_paid#i#") ? 1 : 0 #",
											invoice_id : "#isdefined("attributes.invoice_id#i#") and len(evaluate("attributes.invoice_id#i#")) ? "#evaluate("attributes.invoice_id#i#")#" : "" #",
											bill_info : "#isdefined("attributes.bill_info#i#") and len(evaluate("attributes.bill_info#i#")) ? "" : "" #",  
											period_id : "#isdefined("attributes.period_id#i#") and len(evaluate("attributes.period_id#i#")) ? "#evaluate("attributes.period_id#i#")#" : "" #",
											paymethod_id :"#isdefined("attributes.paymethod_id#i#") and len(evaluate("attributes.paymethod_id#i#")) ? "#evaluate("attributes.paymethod_id#i#")#" : "" #", 
											card_paymethod_id :"#isdefined("attributes.card_paymethod_id#i#") and len(evaluate("attributes.card_paymethod_id#i#")) ? "#evaluate("attributes.card_paymethod_id#i#")#" : "" #",  
											subs_ref_id : "#isdefined('attributes.subs_ref_id#i#') and len(evaluate("attributes.subs_ref_id#i#")) and isdefined('attributes.subs_ref_name#i#') and len(evaluate("attributes.subs_ref_name#i#")) ? "#evaluate("attributes.subs_ref_id#i#")#" : "" #",
											service_id : "#isdefined('attributes.service_id#i#') and len(evaluate("attributes.service_id#i#")) and isdefined('attributes.service_no#i#') and len(evaluate("attributes.service_no#i#")) ? "#evaluate("attributes.service_id#i#")#" : "" #",
											camp_id : "#isdefined('attributes.camp_id#i#') and len(evaluate("attributes.camp_id#i#")) and isdefined('attributes.camp_name#i#') and len(evaluate("attributes.camp_name#i#")) ? "#evaluate("attributes.camp_id#i#")#" : "" #",
											call_id :  "#isdefined('attributes.call_id#i#') and len(evaluate("attributes.call_id#i#")) and isdefined('attributes.call_no#i#') and len(evaluate("attributes.call_no#i#")) ? "#evaluate("attributes.call_id#i#")#" : "" #",
											cari_action_id : "#isdefined('attributes.cari_action_id#i#') and len(evaluate("attributes.cari_action_id#i#")) ? "#evaluate("attributes.cari_action_id#i#")#" : "" #",
											cari_period_id : "#isdefined('attributes.cari_period_id#i#') and len(evaluate("attributes.cari_period_id#i#")) ? "#evaluate("attributes.cari_period_id#i#")#" : "" #",
											cari_act_type :	"#isdefined('attributes.cari_act_type#i#') and len(evaluate("attributes.cari_act_type#i#")) ? "#evaluate("attributes.cari_act_type#i#")#" : "" #",
											cari_act_id : "#isdefined('attributes.cari_act_id#i#') and len(evaluate("attributes.cari_act_id#i#")) ? "#evaluate("attributes.cari_act_id#i#")#" : "" #",
											cari_act_table : "#isdefined('attributes.cari_act_table#i#') and len(evaluate("attributes.cari_act_table#i#")) ? "#evaluate("attributes.cari_act_table#i#")#" : "" #",
											is_active : "#isDefined("attributes.is_active#i#") ? 1 : 0 #",
											row_rate : "#isDefined("attributes.row_rate#i#") and len(evaluate("attributes.row_rate#i#")) ? "#evaluate("attributes.row_rate#i#")#" : "" #",
											row_reason_code : "#isDefined("attributes.row_reason_code#i#") and len(evaluate("attributes.row_reason_code#i#")) ? "#evaluate("attributes.row_reason_code#i#")#" : "" #",			
											row_bsmv_rate : "#isdefined('attributes.row_bsmv_rate#i#') and len(evaluate("attributes.row_bsmv_rate#i#")) ? "#evaluate('attributes.row_bsmv_rate#i#')#" : "" #", 
											row_bsmv_amount : "#isdefined('attributes.row_bsmv_amount#i#') and len(evaluate("attributes.row_bsmv_amount#i#")) ? "#evaluate('attributes.row_bsmv_amount#i#')#" : "" #",
											row_oiv_rate : "#isdefined('attributes.row_oiv_rate#i#') and len(evaluate("attributes.row_oiv_rate#i#")) ? "#evaluate('attributes.row_oiv_rate#i#')#" : "" #",	
											row_oiv_amount : "#isdefined('attributes.row_oiv_amount#i#') and len(evaluate("attributes.row_oiv_amount#i#")) ? "#evaluate('attributes.row_oiv_amount#i#')#" : "" #",
											row_tevkifat_rate : "#isdefined('attributes.row_tevkifat_rate#i#') and len(evaluate("attributes.row_tevkifat_rate#i#")) ? "#evaluate('attributes.row_tevkifat_rate#i#')#" : "" #",
											row_tevkifat_amount : "#isdefined('attributes.row_tevkifat_amount#i#') and len(evaluate("attributes.row_tevkifat_amount#i#")) ? "#evaluate('attributes.row_tevkifat_amount#i#')#" : "" #" 

									)> 
 		
			</cfif>
		</cfloop>
		<!--- //ödeme planı history kayıtları = yeni durum güncellemesi ve yeni eklenen case lerin tutulması bölümü--->
		<cfif get_paym_plan.recordcount>
			<cfset  GET_PAYM_PLAN_HISTORY = contract_cmp.GET_PAYM_PLAN_HISTORY(subscription_id : attributes.subscription_id,
																				history_record : history_record)>
			<cfoutput query="GET_PAYM_PLAN_HISTORY">
				<cfset  GET_LAST_PAYPLAN = contract_cmp.GET_LAST_PAYPLAN(subscription_id : attributes.subscription_id,
																		PAYM_PLAN_YEAR : GET_PAYM_PLAN_HISTORY.PAYM_PLAN_YEAR,
																		PAYM_PLAN_MONEY_TYPE : GET_PAYM_PLAN_HISTORY.PAYM_PLAN_MONEY_TYPE)>
			
				<cfif get_last_payplan.recordcount>
					<cfset  UPD_PAYM_PLAN = contract_cmp.UPD_PAYM_PLAN(LAST_TOTAL : GET_LAST_PAYPLAN.LAST_TOTAL,
																	SUBS_PAYMPLAN_ROW_HISTORY_ID : GET_PAYM_PLAN_HISTORY.SUBS_PAYMPLAN_ROW_HISTORY_ID)>
				</cfif> 
			</cfoutput>
		</cfif>
		<cfset  INSERT_PAYM_PLAN_HISTORY = contract_cmp.INSERT_PAYM_PLAN_HISTORY2(subscription_id :attributes.subscription_id)>
	</cftransaction>
</cflock>
<cf_workcube_process 
	is_upd='1' 
	old_process_line='0'
	data_source='#dsn3#'
	process_stage='#attributes.process_stage#' 
	record_member='#session.ep.userid#' 
	record_date='#now()#'
	action_table='SUBSCRIPTION_PAYMENT_PLAN'
	action_column='SUBSCRIPTION_ID'
	action_id='#attributes.subscription_id#'
	action_page='#request.self#?fuseaction=sales.subscription_payment_plan&subscription_id=#attributes.subscription_id#'
	warning_description = '#getLang("","",32499)# : #attributes.subscription_id#'>
<script type="text/javascript">
	<cfoutput>
		window.location.href='#request.self#?fuseaction=sales.subscription_payment_plan&event=add&subscription_id=#attributes.subscription_id#';
	</cfoutput>
</script>

