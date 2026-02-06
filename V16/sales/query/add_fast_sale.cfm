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
			alert("<cf_get_lang no ='586.Seçilen Sirketin Muhasebe Kodu Belirtilmemiş'> !");
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
<cfset is_from_instalment = 1>
<cfscript>
	attributes.total_voucher_value = filterNum(attributes.total_voucher_value);
	attributes.total_cheque_value = filterNum(attributes.total_cheque_value);
	attributes.total_cash_amount = filterNum(attributes.total_cash_amount);
	attributes.member_use_limit = filterNum(attributes.member_use_limit);
	attributes.total_guarantor_limit = filterNum(attributes.total_guarantor_limit);
	attributes.member_order_value = filterNum(attributes.member_order_value);
</cfscript>

<cf_date tarih="attributes.order_date">
<cfif isdefined("attributes.basket_due_value") and attributes.basket_due_value gt 0>
	<cfset attributes.basket_due_value_date_ = date_add("d",attributes.basket_due_value,attributes.order_date)>
	<cf_date tarih="attributes.basket_due_value_date_">
<cfelse>
	<cfset attributes.basket_due_value_date_ = "">
</cfif> 
<cfif isdefined("attributes.total_due_value") and attributes.total_due_value gt 0>
	<cfset attributes.payroll_due_value_date_ = date_add("d",attributes.total_due_value,attributes.order_date)>
	<cf_date tarih="attributes.payroll_due_value_date_">
<cfelse>
	<cfset attributes.payroll_due_value_date_ = "">
</cfif>
<cfif isdefined("attributes.total_cheque_due_value") and attributes.total_cheque_due_value gt 0>
	<cfset attributes.cheque_payroll_due_value_date_ = date_add("d",attributes.total_cheque_due_value,attributes.order_date)>
	<cf_date tarih="attributes.cheque_payroll_due_value_date_">
<cfelse>
	<cfset attributes.cheque_payroll_due_value_date_ = "">
</cfif>

<cflock name="#CREATEUUID()#" timeout="60">
	<cftransaction>
		<!--- Sipariş Kaydediliyor --->
		<cfinclude template="add_fast_sale_order.cfm">
		<cfquery name="get_last_order" datasource="#dsn2#">
			SELECT ORDER_NUMBER FROM #dsn3_alias#.ORDERS WHERE ORDER_ID = #get_max_order.max_id#
		</cfquery>
		<!--- Değişen Üye Bİlgileri Güncelleniyor --->
		<cfif isdefined("attributes.company_id") and len(attributes.company_id)>
			<cfinclude template="../../invoice/query/upd_company.cfm">
		<cfelseif isdefined("attributes.consumer_id") and len(attributes.consumer_id)>
			<cfinclude template="../../invoice/query/upd_consumer.cfm">
		</cfif>
		<!--- Kasa Hareketleri Yapılıyor --->
		<cfif isdefined("attributes.cash") and (attributes.cash eq 1)>
			<cfinclude template="add_fast_sale_1.cfm">
		</cfif>
		<!--- Pos hareketleri yapılıyor --->
		<cfif isdefined("attributes.is_pos") and len(attributes.is_pos)>
			<cfif not isdefined("attributes.record_num2")><cfset attributes.record_num2 = 0></cfif>
			<cfinclude template="add_fast_sale_2.cfm">
		</cfif>
		<cfset row_count_voucher = 0>
		<cfloop from="1" to="#attributes.record_num_3#" index="nn">
			<cfif len(evaluate("attributes.voucher_value#nn#")) and evaluate("attributes.voucher_value#nn#") gt 0 and evaluate("attributes.row_kontrol_3#nn#") eq 1>
				<cfset row_count_voucher = row_count_voucher + 1>
			</cfif>
		</cfloop>
		<cfif row_count_voucher gt 0>
			<!--- Senetler kaydediliyor--->
			<cfinclude template="add_fast_sale_3.cfm">		
			<!--- Kefiller Kaydediliyor --->
			<cfinclude template="add_fast_sale_4.cfm">
			<!--- Senetlerin cari ve muhasebe hareketleri yapılıyor --->
			<cfinclude template="add_fast_sale_5.cfm">
		</cfif>
		<cfset row_count_cheque = 0>
		<cfloop from="1" to="#attributes.record_num_4#" index="nn">
			<cfif len(evaluate("attributes.cheque_value#nn#")) and evaluate("attributes.cheque_value#nn#") gt 0 and evaluate("attributes.row_kontrol_4#nn#") eq 1>
				<cfset row_count_cheque = row_count_cheque + 1>
			</cfif>
		</cfloop>
		<cfif row_count_cheque gt 0>
			<!--- Çekler kaydediliyor--->
			<cfinclude template="add_fast_sale_6.cfm">		
			<!--- Çeklerin cari ve muhasebe hareketleri yapılıyor --->
			<cfinclude template="add_fast_sale_7.cfm">
		</cfif>
		<cf_workcube_process
			is_upd='1' 
			data_source='#dsn2#' 
			old_process_line='0'
			process_stage='#attributes.process_stage#' 
			record_member='#session.ep.userid#' 
			record_date='#now()#' 
			action_table='ORDERS'
			action_column='ORDER_ID'
			action_id='#get_max_order.max_id#'
			action_page='#request.self#?fuseaction=#listgetat(attributes.fuseaction,1,'.')#.list_order_instalment&event=upd&order_id=#get_max_order.max_id#' 
			warning_description='#getLang('','Taksitli Satış',43571)# : #paper_full#'>
			<!--- action_id2='#form.old_stage#' --->
	</cftransaction>
</cflock>
<cf_get_lang_set module_name="#lcase(listgetat(attributes.fuseaction,1,'.'))#">
<script type="text/javascript">
	window.location.href="<cfoutput>#request.self#?fuseaction=#listgetat(attributes.fuseaction,1,'.')#.list_order_instalment&event=upd&order_id=#get_max_order.max_id#</cfoutput>";
</script>
