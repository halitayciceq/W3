<cf_get_lang_set module_name="sales">
<cfquery name="GET_NO_" datasource="#dsn3#">
	SELECT HIZLI_F FROM SETUP_INVOICE
</cfquery>
<cfif isDefined("attributes.company_id") and len(attributes.company_id)>
	<cfset acc = GET_COMPANY_PERIOD(attributes.company_id)>
	<cfif not len(acc)>
		<cfset acc=GET_NO_.HIZLI_F>
	</cfif>
	<cfif not len(acc)>
		<script type="text/javascript">
			alert("<cf_get_lang no ='586.Seçilen Sirketin Muhasebe Kodu Belirtilmemiş'>!");
			window.location.href='<cfoutput>#cgi.referer#</cfoutput>';
		</script>
		<cfabort>
	</cfif>
<cfelseif isDefined("attributes.consumer_id") and len(attributes.consumer_id)>
	<cfset acc = GET_CONSUMER_PERIOD(attributes.consumer_id)>
	<cfif not len(acc)>
		<cfset acc=GET_NO_.HIZLI_F>
	</cfif>
	<cfif not len(acc)>
		<script type="text/javascript">
			alert("<cf_get_lang no ='587.Seçilen Müşterinin Muhasebe Kodu Belirtilmemiş '>!");
			window.location.href='<cfoutput>#cgi.referer#</cfoutput>';
		</script>
		<cfabort>
	</cfif>
</cfif>
<cfset attributes.currency_multiplier = ''>
<cfif isDefined('attributes.kur_say') and len(attributes.kur_say)>
	<cfloop from="1" to="#attributes.kur_say#" index="mon">
		<cfif evaluate("attributes.hidden_rd_money_#mon#") is session.ep.money2>
        	<cfset rate2 = filternum(evaluate('attributes.txt_rate2_#mon#'),session.ep.our_company_info.rate_round_num)>
			<cfset rate1 = filternum(evaluate('attributes.txt_rate1_#mon#'),session.ep.our_company_info.rate_round_num)>
			<cfset attributes.currency_multiplier = (rate2/rate1)>
		</cfif>
	</cfloop>	
</cfif>
<cfset wrk_id = dateformat(now(),'YYYYMMDD')&timeformat(now(),'HHmmss')&'_#session.ep.userid#_'&round(rand()*100)>
<cfset attributes.order_status = 1>
<cfset is_from_instalment = 1>
<CFQUERY name="GET_PROCESS" datasource="#DSN3#">
	SELECT ORDER_STAGE FROM ORDERS WHERE ORDER_ID=#attributes.order_id#
</CFQUERY> 
<cfif form.del_order_id eq 0><!--- Güncelleme --->
	<cfscript>
		attributes.total_voucher_value = filterNum(attributes.total_voucher_value);
		attributes.total_cheque_value = filterNum(attributes.total_cheque_value);
		attributes.total_cash_amount = filterNum(attributes.total_cash_amount);
		attributes.member_use_limit = filterNum(attributes.member_use_limit);
		attributes.total_guarantor_limit = filterNum(attributes.total_guarantor_limit);
		attributes.member_order_value = filterNum(attributes.member_order_value);
	</cfscript>
	<cf_date tarih="attributes.order_date">
	<cfif isdefined("attributes.basket_due_value") and len(attributes.basket_due_value)>
		<cfset attributes.basket_due_value_date_ = date_add("d",attributes.basket_due_value,attributes.order_date)>
	<cfelse>
		<cfset attributes.basket_due_value_date_ = "">
	</cfif> 
	<cfif isdefined("attributes.total_due_value") and len(attributes.total_due_value)>
		<cfset attributes.payroll_due_value_date_ = date_add("d",attributes.total_due_value,attributes.order_date)>
	<cfelse>
		<cfset attributes.payroll_due_value_date_ = "">
	</cfif>
	<cfif isdefined("attributes.total_cheque_due_value") and len(attributes.total_cheque_due_value)>
		<cfset attributes.cheque_payroll_due_value_date_ = date_add("d",attributes.total_cheque_due_value,attributes.order_date)>
	<cfelse>
		<cfset attributes.cheque_payroll_due_value_date_ = "">
	</cfif>
	<cflock name="#CREATEUUID()#" timeout="60">
		<cftransaction>
			<!--- Sipariş Kaydediliyor --->
			<cfinclude template="upd_fast_sale_order.cfm">
			<!--- Değişen Üye Bİlgileri Güncelleniyor --->
			<cfif isdefined("attributes.company_id") and len(attributes.company_id)>
				<cfinclude template="../../invoice/query/upd_company.cfm">
			<cfelseif isdefined("attributes.consumer_id") and len(attributes.consumer_id)>
				<cfinclude template="../../invoice/query/upd_consumer.cfm">
			</cfif>
			<cfif not isdefined("attributes.update_order_only")><!--- Sadece sipariş güncelleme parametresi gelmemişse --->
				<!--- Kasa Hareketleri Yapılıyor --->
				<cfinclude template="upd_fast_sale_1.cfm">
				<!--- Pos hareketleri yapılıyor --->
				<cfif not isdefined("attributes.record_num2")><cfset attributes.record_num2 = 0></cfif>
				<cfinclude template="upd_fast_sale_2.cfm">
				<!--- Senet eski hareketler siliniyor --->
				<cfquery name="del_voucher_rel" datasource="#dsn2#">
					DELETE FROM #dsn3_alias#.ORDER_VOUCHER_RELATION WHERE ORDER_ID = #attributes.order_id# 
				</cfquery>
				<cfset old_voucher_list = attributes.voucher_id_list>
				<cfloop from="1" to="#listlen(old_voucher_list)#" index="nn">
					<cfquery name="del_voucher" datasource="#dsn2#">
						DELETE FROM VOUCHER WHERE VOUCHER_ID = #listgetat(old_voucher_list,nn,',')#
					</cfquery>
					<cfquery name="del_voucher_money" datasource="#dsn2#">
						DELETE FROM VOUCHER_MONEY WHERE ACTION_ID = #listgetat(old_voucher_list,nn,',')#
					</cfquery>
					<cfquery name="del_voucher_histry" datasource="#dsn2#">
						DELETE FROM VOUCHER_HISTORY WHERE VOUCHER_ID = #listgetat(old_voucher_list,nn,',')#
					</cfquery>
					<cfscript>
						cari_sil(action_id:listgetat(old_voucher_list,nn,','), process_type:97,action_table='VOUCHER',payroll_id : attributes.payroll_id);
					</cfscript>
				</cfloop>
				<cfif len(old_voucher_list)>
					<cfquery name="del_voucher_guearantor" datasource="#dsn2#">
						DELETE FROM VOUCHER_GUARANTORS WHERE VOUCHER_ID IN(#old_voucher_list#)
					</cfquery>
				</cfif>
				<cfset row_count_voucher = 0>
				<cfloop from="1" to="#attributes.record_num_3#" index="nnn">
					<cfscript>
						'attributes.voucher_value#nnn#' = filterNum(evaluate('attributes.voucher_value#nnn#'),4);
					</cfscript>
					<cfif len(evaluate("attributes.voucher_value#nnn#")) and evaluate("attributes.voucher_value#nnn#") gt 0 and evaluate("attributes.row_kontrol_3#nnn#") eq 1>
						<cfset row_count_voucher = row_count_voucher + 1>
					</cfif>
				</cfloop>
				<cfif row_count_voucher gt 0>
					<!--- Senetler kaydediliyor--->
					<cfinclude template="upd_fast_sale_3.cfm">	
					<!--- Kefiller Kaydediliyor --->
					<cfinclude template="upd_fast_sale_4.cfm">
					<!--- Senetlerin cari ve muhasebe hareketleri yapılıyor --->
                    <cfscript>
						muhasebe_sil(action_id:attributes.payroll_id, process_type:97);
						cari_sil(action_id:attributes.payroll_id, process_type:97,action_table='VOUCHER_PAYROLL');
					</cfscript>
					<cfinclude template="upd_fast_sale_5.cfm">
				<cfelseif len(attributes.payroll_id)>
					<cfquery name="del_payroll" datasource="#dsn2#">
						DELETE FROM VOUCHER_PAYROLL WHERE ACTION_ID = #attributes.payroll_id#
					</cfquery>
					<cfquery name="del_payroll" datasource="#dsn2#">
						DELETE FROM VOUCHER_PAYROLL_MONEY WHERE ACTION_ID = #attributes.payroll_id#
					</cfquery>
					<cfscript>
						muhasebe_sil(action_id:attributes.payroll_id, process_type:97);
						cari_sil(action_id:attributes.payroll_id, process_type:97,action_table='VOUCHER_PAYROLL');
					</cfscript>
				</cfif>
				<!--- Çek eski hareketler siliniyor --->
				<cfset old_cheque_list = attributes.cheque_id_list>
				<cfloop from="1" to="#listlen(old_cheque_list)#" index="nn">
					<cfquery name="del_cheque" datasource="#dsn2#">
						DELETE FROM CHEQUE WHERE CHEQUE_ID = #listgetat(old_cheque_list,nn,',')#
					</cfquery>
					<cfquery name="del_cheque_money" datasource="#dsn2#">
						DELETE FROM CHEQUE_MONEY WHERE ACTION_ID = #listgetat(old_cheque_list,nn,',')#
					</cfquery>
					<cfquery name="del_cheque_histry" datasource="#dsn2#">
						DELETE FROM CHEQUE_HISTORY WHERE CHEQUE_ID = #listgetat(old_cheque_list,nn,',')#
					</cfquery>
					<cfscript>
						cari_sil(action_id:listgetat(old_cheque_list,nn,','), process_type:90,action_table='CHEQUE',payroll_id : attributes.cheque_payroll_id);
					</cfscript>
				</cfloop>
				<cfset row_count_cheque = 0>
				<cfloop from="1" to="#attributes.record_num_4#" index="nnn">
					<cfscript>
						'attributes.cheque_value#nnn#' = filterNum(evaluate('attributes.cheque_value#nnn#'),4);
					</cfscript>
					<cfif len(evaluate("attributes.cheque_value#nnn#")) and evaluate("attributes.cheque_value#nnn#") gt 0 and evaluate("attributes.row_kontrol_4#nnn#") eq 1>
						<cfset row_count_cheque = row_count_cheque + 1>
					</cfif>
				</cfloop>
				<cfif row_count_cheque gt 0>
					<!--- çekler kaydediliyor--->
					<cfinclude template="upd_fast_sale_6.cfm">	
					<!--- çeklerin cari ve muhasebe hareketleri yapılıyor --->
                    <cfscript>
						muhasebe_sil(action_id:attributes.cheque_payroll_id, process_type:90);
						cari_sil(action_id:attributes.cheque_payroll_id, process_type:90,action_table='PAYROLL');
					</cfscript>
					<cfinclude template="upd_fast_sale_7.cfm">
				<cfelseif len(attributes.cheque_payroll_id)>
					<cfquery name="del_payroll" datasource="#dsn2#">
						DELETE FROM PAYROLL WHERE ACTION_ID = #attributes.cheque_payroll_id#
					</cfquery>
					<cfquery name="del_payroll" datasource="#dsn2#">
						DELETE FROM PAYROLL_MONEY WHERE ACTION_ID = #attributes.cheque_payroll_id#
					</cfquery>
					<cfscript>
						muhasebe_sil(action_id:attributes.cheque_payroll_id, process_type:90);
						cari_sil(action_id:attributes.cheque_payroll_id, process_type:90,action_table='PAYROLL');
					</cfscript>
				</cfif>
			</cfif>
			<cf_add_log  log_type="-1" action_id="#attributes.order_id#" action_name="#attributes.order_number#" process_stage="#GET_PROCESS.order_stage#" data_source="#dsn2#">
			<cf_workcube_process
				is_upd='1' 
				data_source='#dsn2#' 
				old_process_line='#attributes.old_process_line#'
				process_stage='#attributes.process_stage#' 
				record_member='#session.ep.userid#'
				record_date='#now()#'
				action_table='ORDERS'
				action_column='ORDER_ID'
				action_id='#form.order_id#'
				action_page='#request.self#?fuseaction=#listgetat(attributes.fuseaction,1,'.')#.list_order_instalment&event=upd&order_id=#form.order_id#' 
				warning_description='#getLang('','Taksitli Satış',43571)# : #get_order.ORDER_NUMBER#'>	
		</cftransaction>
	</cflock>
	<script type="text/javascript">
		window.location.href="<cfoutput>#request.self#?fuseaction=#listgetat(attributes.fuseaction,1,'.')#.list_order_instalment&event=upd&order_id=#attributes.order_id#</cfoutput>";
	</script>
<cfelse><!--- Silme --->
	<cfset attributes.action_id=attributes.ORDER_ID>
	<cfset attributes.action_section="ORDER_ID">
	<cfinclude template="../../objects/query/del_assets.cfm">
	<cflock name="#CreateUUID()#" timeout="60">
		<cftransaction>
		<!--- Sipariş ,satırlar vs  siliniyor --->
		<cfquery name="DEL_ORDER_PLUS" datasource="#dsn2#">
			DELETE FROM #dsn3_alias#.ORDER_PLUS WHERE ORDER_ID = #attributes.order_id#
		</cfquery>
		<cfquery name="DEL_OFFER_ASSORT_ROWS" datasource="#dsn2#">
			DELETE FROM
				#dsn3_alias#.PRODUCTION_ASSORTMENT
			WHERE
				ACTION_TYPE = 2 AND 
				ASSORTMENT_ID IN (
									SELECT
										ORDER_ROW_ID 
									FROM
										#dsn3_alias#.ORDER_ROW
									WHERE
										ORDER_ID = #attributes.order_id#			
								 )
		</cfquery>
		<cfquery name="DEL_ORDER_ROW_HISTORY" datasource="#dsn2#">
			DELETE FROM 
				#dsn3_alias#.ORDER_ROW_HISTORY
			WHERE 
				ORDER_HISTORY_ID IN (
										SELECT
											ORDER_HISTORY_ID 
										FROM
											#dsn3_alias#.ORDERS_HISTORY ORDERS_HISTORY
										WHERE	
											ORDERS_HISTORY.ORDER_ID = #attributes.order_id#
									)
		</cfquery>
		<cfquery name="DEL_CONTRACT_ORDER" datasource="#dsn2#">
			DELETE FROM	#dsn3_alias#.SUBSCRIPTION_CONTRACT_ORDER WHERE ORDER_ID = #attributes.order_id#
		</cfquery>
		<cfquery name="DEL_ORDERS_HISTORY" datasource="#dsn2#">
			DELETE FROM #dsn3_alias#.ORDERS_HISTORY WHERE ORDER_ID = #attributes.order_id#
		</cfquery>
		<cfquery name="DEL_ORDER_MONEY" datasource="#dsn2#">
			DELETE FROM #dsn3_alias#.ORDER_MONEY WHERE ACTION_ID = #attributes.order_id#
		</cfquery>
		<cfquery name="DEL_ORDER_RESERVE" datasource="#dsn2#">
			DELETE FROM #dsn3_alias#.ORDER_ROW_RESERVED WHERE ORDER_ID = #attributes.order_id# AND SHIP_ID IS NULL
		</cfquery>
		<cfquery name="DEL_ORDER_PRODUCTS" datasource="#dsn2#">
			DELETE FROM #dsn3_alias#.ORDER_ROW WHERE ORDER_ID = #attributes.order_id#
		</cfquery>
		<cfquery name="DEL_ORDER" datasource="#dsn2#">
			DELETE FROM	#dsn3_alias#.ORDERS WHERE ORDER_ID = #attributes.order_id#
		</cfquery>
		<!--- Senetler siliniyor --->
		<cfset old_voucher_list = attributes.voucher_id_list>
		<cfloop from="1" to="#listlen(old_voucher_list)#" index="nn">
			<cfquery name="del_voucher" datasource="#dsn2#">
				DELETE FROM VOUCHER WHERE VOUCHER_ID = #listgetat(old_voucher_list,nn,',')#
			</cfquery>
			<cfquery name="del_voucher_money" datasource="#dsn2#">
				DELETE FROM VOUCHER_MONEY WHERE ACTION_ID = #listgetat(old_voucher_list,nn,',')#
			</cfquery>
			<cfquery name="del_voucher_histry" datasource="#dsn2#">
				DELETE FROM VOUCHER_HISTORY WHERE VOUCHER_ID = #listgetat(old_voucher_list,nn,',')#
			</cfquery>
			<cfscript>
				cari_sil(action_id:listgetat(old_voucher_list,nn,','), process_type:97,action_table='VOUCHER',payroll_id : attributes.payroll_id);
			</cfscript>
		</cfloop>
		<!--- Çekler siliniyor --->
		<cfset old_cheque_list = attributes.cheque_id_list>
		<cfloop from="1" to="#listlen(old_cheque_list)#" index="nn">
			<cfquery name="del_cheque" datasource="#dsn2#">
				DELETE FROM CHEQUE WHERE CHEQUE_ID = #listgetat(old_cheque_list,nn,',')#
			</cfquery>
			<cfquery name="del_cheque_money" datasource="#dsn2#">
				DELETE FROM CHEQUE_MONEY WHERE ACTION_ID = #listgetat(old_cheque_list,nn,',')#
			</cfquery>
			<cfquery name="del_cheque_histry" datasource="#dsn2#">
				DELETE FROM CHEQUE_HISTORY WHERE CHEQUE_ID = #listgetat(old_cheque_list,nn,',')#
			</cfquery>
			<cfscript>
				cari_sil(action_id:listgetat(old_cheque_list,nn,','), process_type:90,action_table='CHEQUE',payroll_id : attributes.cheque_payroll_id);
			</cfscript>
		</cfloop>
		<cfquery name="del_voucher_rel" datasource="#dsn2#">
			DELETE FROM #dsn3_alias#.ORDER_VOUCHER_RELATION WHERE ORDER_ID = #attributes.order_id# 
		</cfquery>
		<cfif len(old_voucher_list)>
			<cfquery name="del_voucher_guearantor" datasource="#dsn2#">
				DELETE FROM VOUCHER_GUARANTORS WHERE VOUCHER_ID IN(#old_voucher_list#)
			</cfquery>
		</cfif>
		<cfif len(attributes.payroll_id)>
			<cfquery name="del_payroll" datasource="#dsn2#">
				DELETE FROM VOUCHER_PAYROLL WHERE ACTION_ID = #attributes.payroll_id#
			</cfquery>
			<cfquery name="del_payroll" datasource="#dsn2#">
				DELETE FROM VOUCHER_PAYROLL_MONEY WHERE ACTION_ID = #attributes.payroll_id#
			</cfquery>
			<cfscript>
				muhasebe_sil(action_id:attributes.payroll_id, process_type:97);
				cari_sil(action_id:attributes.payroll_id, process_type:97,action_table='VOUCHER_PAYROLL');
			</cfscript>
		</cfif>
		<cfif len(attributes.cheque_payroll_id)>
			<cfquery name="del_payroll" datasource="#dsn2#">
				DELETE FROM PAYROLL WHERE ACTION_ID = #attributes.cheque_payroll_id#
			</cfquery>
			<cfquery name="del_payroll" datasource="#dsn2#">
				DELETE FROM PAYROLL_MONEY WHERE ACTION_ID = #attributes.cheque_payroll_id#
			</cfquery>
			<cfscript>
				muhasebe_sil(action_id:attributes.cheque_payroll_id, process_type:90);
				cari_sil(action_id:attributes.cheque_payroll_id, process_type:90,action_table='PAYROLL');
			</cfscript>
		</cfif>
		<!--- Kasa hareketleri silinyor --->
		<cfquery name="control_order_cash" datasource="#dsn2#">
			SELECT CASH_ID,KASA_ID,ORDER_CASH_ID FROM #dsn3_alias#.ORDER_CASH_POS WHERE ORDER_ID=#attributes.order_id# AND CASH_ID IS NOT NULL
		</cfquery>
		<cfif control_order_cash.recordcount>
			<cfscript>
				for(i=1; i lte control_order_cash.recordcount; i=i+1)
					{
						cari_sil(action_id:control_order_cash.cash_id[#i#], process_type:31);
						muhasebe_sil(action_id:control_order_cash.cash_id[#i#], process_type:31);
					}
			</cfscript>
			<cfquery name="del_cash_actions" datasource="#dsn2#">
				DELETE FROM CASH_ACTIONS WHERE ACTION_ID IN (#valuelist(control_order_cash.cash_id)#)
			</cfquery>
			<cfquery name="del_cash_pos" datasource="#dsn2#">
				DELETE FROM #dsn3_alias#.ORDER_CASH_POS WHERE ORDER_ID=#attributes.order_id# AND CASH_ID IN (#valuelist(control_order_cash.cash_id)#)
			</cfquery>
		</cfif>	
		<!--- Pos hareketleri siliniyor --->
		<cfquery name="order_pos_detail" datasource="#dsn2#">
			SELECT POS_ID,POS_ACTION_ID,ORDER_CASH_ID FROM #dsn3_alias#.ORDER_CASH_POS WHERE ORDER_ID=#attributes.order_id# AND POS_ID IS NOT NULL
		</cfquery>
		<cfif order_pos_detail.recordcount>
			<cfscript>
				for(i=1; i lte order_pos_detail.recordcount; i=i+1)
					{
						cari_sil(action_id:order_pos_detail.pos_action_id[#i#], process_type:241);
						muhasebe_sil(action_id:order_pos_detail.pos_action_id[#i#], process_type:241);
					}
			</cfscript>
			<cfquery name="DEL_CARD" datasource="#dsn2#">
				DELETE FROM #dsn3_alias#.CREDIT_CARD_BANK_PAYMENTS WHERE CREDITCARD_PAYMENT_ID IN (#valuelist(order_pos_detail.POS_ACTION_ID)#)
			</cfquery>
			<cfquery name="DEL_CARD_ROWS" datasource="#dsn2#">
				DELETE FROM #dsn3_alias#.CREDIT_CARD_BANK_PAYMENTS_ROWS WHERE CREDITCARD_PAYMENT_ID IN (#valuelist(order_pos_detail.POS_ACTION_ID)#)
			</cfquery>
			<cfquery name="DEL_CASH_ACTIONS" datasource="#dsn2#">
				DELETE FROM #dsn3_alias#.ORDER_CASH_POS WHERE ORDER_ID=#attributes.order_id# AND POS_ACTION_ID IN (#valuelist(order_pos_detail.POS_ACTION_ID)#)
			</cfquery>
		</cfif>
		<cf_add_log  log_type="-1" action_id="#attributes.order_id#" action_name="#attributes.order_number#" process_stage="#get_process.order_stage#" data_source="#dsn2#">
		</cftransaction>
	</cflock>
	<script type="text/javascript">
		window.location.href="<cfoutput>#request.self#?fuseaction=#listgetat(attributes.fuseaction,1,'.')#.list_order_instalment</cfoutput>";
	</script>
</cfif>	
<cf_get_lang_set module_name="#lcase(listgetat(attributes.fuseaction,1,'.'))#">
