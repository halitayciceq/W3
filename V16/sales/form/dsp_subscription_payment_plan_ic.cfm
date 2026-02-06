<cfsetting showdebugoutput="no">
<cfquery name="GET_SUBSCRIPTION" datasource="#dsn3#">
	SELECT COMPANY_ID,CONSUMER_ID,INVOICE_COMPANY_ID,INVOICE_CONSUMER_ID,MEMBER_CC_ID FROM SUBSCRIPTION_CONTRACT WHERE SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.subscription_id#">
</cfquery>
<cfif len(GET_SUBSCRIPTION.COMPANY_ID)>
	<cfset member_type = 0>
	<cfset member_id = GET_SUBSCRIPTION.INVOICE_COMPANY_ID>
	<cfset member_cc_id = GET_SUBSCRIPTION.MEMBER_CC_ID>
<cfelse>
	<cfset member_type = 1>
	<cfset member_id = GET_SUBSCRIPTION.INVOICE_CONSUMER_ID>
	<cfset member_cc_id = GET_SUBSCRIPTION.MEMBER_CC_ID>
</cfif>
<cfquery name="GET_PAYMENT_ROWS" datasource="#dsn3#">
	SELECT 
		SUBSCRIPTION_PAYMENT_ROW_ID,
		SUBSCRIPTION_ID,
		STOCK_ID,
		PRODUCT_ID,
		(SELECT ISNULL(TAX,0) FROM PRODUCT WHERE PRODUCT_ID = SUBSCRIPTION_PAYMENT_PLAN_ROW.PRODUCT_ID) TAX,
		(SELECT ISNULL(OTV,0) FROM PRODUCT WHERE PRODUCT_ID = SUBSCRIPTION_PAYMENT_PLAN_ROW.PRODUCT_ID) OTV,
		PAYMENT_DATE,
		DETAIL,
		UNIT,
		QUANTITY,
		AMOUNT,
		MONEY_TYPE,
		ROW_TOTAL,
		DISCOUNT,
		ROW_NET_TOTAL,
		IS_COLLECTED_INVOICE,
		IS_BILLED,
		IS_PAID,
		IS_COLLECTED_PROVISION,
		INVOICE_ID,
		PERIOD_ID,
		(SELECT PERIOD_YEAR FROM #dsn_alias#.SETUP_PERIOD WHERE PERIOD_ID = SUBSCRIPTION_PAYMENT_PLAN_ROW.PERIOD_ID) AS PERIOD_YEAR,
		<cfif x_payment_plan_record_info>
			(SELECT EMPLOYEES.EMPLOYEE_NAME + ' ' + EMPLOYEES.EMPLOYEE_SURNAME FROM #dsn_alias#.EMPLOYEES WHERE EMPLOYEES.EMPLOYEE_ID = SUBSCRIPTION_PAYMENT_PLAN_ROW.RECORD_EMP) RECORD_EMP_NAME,
			(SELECT EMPLOYEES.EMPLOYEE_NAME + ' ' + EMPLOYEES.EMPLOYEE_SURNAME FROM #dsn_alias#.EMPLOYEES WHERE EMPLOYEES.EMPLOYEE_ID = SUBSCRIPTION_PAYMENT_PLAN_ROW.UPDATE_EMP) UPDATE_EMP_NAME,
		</cfif>
		RECORD_IP,
		RECORD_DATE,
		UPDATE_IP,
		UPDATE_DATE,
		UNIT_ID,
		PAYMETHOD_ID,
		(SELECT SETUP_PAYMETHOD.PAYMETHOD FROM #dsn_alias#.SETUP_PAYMETHOD WHERE SETUP_PAYMETHOD.PAYMETHOD_ID = SUBSCRIPTION_PAYMENT_PLAN_ROW.PAYMETHOD_ID) PAYMETHOD,
		CARD_PAYMETHOD_ID,
		(SELECT CREDITCARD_PAYMENT_TYPE.CARD_NO FROM CREDITCARD_PAYMENT_TYPE WHERE CREDITCARD_PAYMENT_TYPE.PAYMENT_TYPE_ID = SUBSCRIPTION_PAYMENT_PLAN_ROW.CARD_PAYMETHOD_ID) CARD_NO,
		<cfif x_payment_plan_reference>
			SUBS_REFERENCE_ID,
			(SELECT SUBSCRIPTION_CONTRACT.SUBSCRIPTION_NO FROM SUBSCRIPTION_CONTRACT WHERE SUBSCRIPTION_CONTRACT.SUBSCRIPTION_ID = SUBSCRIPTION_PAYMENT_PLAN_ROW.SUBS_REFERENCE_ID) SUBSCRIPTION_NO,
		</cfif>
		IS_GROUP_INVOICE,
		IS_INVOICE_IPTAL,
		DUE_DIFF_ID,
		<cfif x_payment_plan_service>
			SERVICE_ID,
			(SELECT SERVICE.SERVICE_NO FROM SERVICE WHERE SERVICE.SERVICE_ID = SUBSCRIPTION_PAYMENT_PLAN_ROW.SERVICE_ID) SERVICE_NO,
		</cfif>
		<cfif x_payment_plan_call>
			CALL_ID,
			(SELECT G_SERVICE.SERVICE_NO FROM #dsn_alias#.G_SERVICE WHERE G_SERVICE.SERVICE_ID = SUBSCRIPTION_PAYMENT_PLAN_ROW.CALL_ID) G_SERVICE_NO,
		</cfif>
		IS_ACTIVE,
		<cfif x_payment_plan_campaign>
			CAMPAIGN_ID,
			(SELECT CAMPAIGNS.CAMP_HEAD FROM CAMPAIGNS WHERE CAMPAIGNS.CAMP_ID = SUBSCRIPTION_PAYMENT_PLAN_ROW.CAMPAIGN_ID) CAMP_HEAD,
		</cfif>
		CARI_ACTION_ID,
		CARI_PERIOD_ID,
		CAMP_ID,
		CARI_ACT_TYPE,
		CARI_ACT_TABLE,
		CARI_ACT_ID,
		DISCOUNT_AMOUNT,
		YEAR(PAYMENT_DATE) PAYMENT_YEAR
	FROM 
		SUBSCRIPTION_PAYMENT_PLAN_ROW 
	WHERE 
		SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.subscription_id#">
		<cfif isdefined('attributes.payment_year') and len(attributes.payment_year)>
			AND YEAR(PAYMENT_DATE) = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.payment_year#">
		</cfif>
	ORDER BY 
		PAYMENT_DATE
</cfquery>
	<cf_medium_list>
    	<thead>
				<tr>
					<th></th>
					<th><cf_get_lang_main no='81.Aktif'></th>
					<th width="92"><cf_get_lang_main no='330.Tarih'></th>
					<th width="120"><cf_get_lang_main no='217.Açıklama'></th>
					<th width="123"><cf_get_lang_main no='1104.Ödeme Yöntemi'></th>
					<th width="70"><cf_get_lang_main no='224.Birim'></th>
					<cfif x_payment_plan_kdv>
						<cfset colspan_info = colspan_info + 1>
						<th width="40"><cf_get_lang_main no='227.KDV'></th>
					</cfif>
					<cfif x_payment_plan_otv>
						<cfset colspan_info = colspan_info + 1>
						<th width="40"><cf_get_lang_main no='609.ÖTV'></th>
					</cfif>
					<th width="50" align="right"><cf_get_lang_main no='223.Miktar'></th>
					<th width="80" align="right"><cf_get_lang_main no='261.Tutar'></th>
					<th nowrap="nowrap"><cf_get_lang_main no='77.Para Br'></th>
					<th nowrap align="right"><cf_get_lang no='311.Satır Toplamı'></th>
					<th nowrap align="right"><cf_get_lang_main no='229.İSK'>(%)</th>
					<cfif x_payment_plan_isk_amount>
						<cfset colspan_info = colspan_info + 1>
						<th nowrap align="right"><cf_get_lang_main no='229.İSK'> Tutar</th>
					</cfif>
					<th nowrap align="right"><cf_get_lang no='312.Net Satır Top'></th>
					<cfif x_payment_plan_kdv_amount>
						<cfset colspan_info = colspan_info + 1>
						<th nowrap align="right">KDV'li <cf_get_lang no='312.Net Satır Top'></th>
					</cfif>
					<th nowrap>Fatura Tipi</th>
					<th><cf_get_lang no='313.Faturalandı'></th>
					<th nowrap title="Toplu Provizyon">TP</th>
					<th><cf_get_lang no='315.Ödendi'></th>
					<cfif x_payment_plan_campaign>
						<cfset colspan_info = colspan_info + 1>
						<th width="125"><cf_get_lang_main no='34.Kampanya'></th>
					</cfif>
					<cfif x_payment_plan_reference>
						<cfset colspan_info = colspan_info + 1>
						<th><cf_get_lang_main no='1372.Referans'></th>
					</cfif>
					<cfif x_payment_plan_service>
						<cfset colspan_info = colspan_info + 1>
						<th><cf_get_lang_main no='244.Servis'></th>
					</cfif>
					<cfif x_payment_plan_call>
						<cfset colspan_info = colspan_info + 1>
						<th nowrap><cf_get_lang_main no='26.Callcenter'></th>
					</cfif>
					<cfif x_payment_plan_record_info>
						<cfset colspan_info = colspan_info +2>
						<th><cf_get_lang_main no='71.Kayıt'></th>
						<th><cf_get_lang_main no='479.Güncelleyen'></th>
					</cfif>
				</tr>
           </thead>
           <tbody>
				<cfoutput query="get_payment_rows">
					<tr>
						<td>
							<cfif len(GET_PAYMENT_ROWS.INVOICE_ID) and GET_PAYMENT_ROWS.IS_PAID eq 0 and GET_PAYMENT_ROWS.IS_COLLECTED_PROVISION eq 0 and len(CARD_PAYMETHOD_ID)><!---action_value=#ROW_NET_TOTAL#--->
								<cfset donem_db = "#dsn#_#GET_PAYMENT_ROWS.period_year#_#session.ep.company_id#">
								<cfquery name="getInvoiceNettotal" datasource="#donem_db#">
									SELECT NETTOTAL FROM INVOICE WHERE INVOICE_ID = #GET_PAYMENT_ROWS.INVOICE_ID#
								</cfquery>
								<a href="javascript://" onclick="windowopen('#request.self#?fuseaction=bank.popup_add_online_pos&member_type=#MEMBER_TYPE#&member_id=#MEMBER_ID#&card_id_info=#MEMBER_CC_ID#&action_value=#getInvoiceNettotal.NETTOTAL#&invoice_id=#INVOICE_ID#&period_id=#PERIOD_ID#&paym_id=#CARD_PAYMETHOD_ID#','medium');"><img src="/images/pos_credit_sanal.gif" title="Sanal POS" border="0"></a>
							</cfif>
						</td>
						<td nowrap align="center" title="<cf_get_lang_main no='81.Aktif'>"><cfif GET_PAYMENT_ROWS.IS_ACTIVE eq 1><img src="/images/c_ok.gif" title="<cf_get_lang_main no='81.Aktif'>" border="0"></cfif></td>
						<td nowrap width="92" title="<cf_get_lang_main no='330.Tarih'>">#DateFormat(GET_PAYMENT_ROWS.PAYMENT_DATE,dateformat_style)#</td>
						<td nowrap width="120" title="<cf_get_lang_main no='217.Açıklama'>">#GET_PAYMENT_ROWS.DETAIL#</td>
						<td nowrap width="123" title="<cf_get_lang_main no='1104.Ödeme Yöntemi'>"><cfif len(GET_PAYMENT_ROWS.PAYMETHOD)>#GET_PAYMENT_ROWS.PAYMETHOD#<cfelseif len(GET_PAYMENT_ROWS.CARD_PAYMETHOD_ID)>#GET_PAYMENT_ROWS.CARD_NO#</cfif></td>
						<td nowrap width="40" title="<cf_get_lang_main no='224.Birim'>">#GET_PAYMENT_ROWS.UNIT#</td>
						<cfif x_payment_plan_kdv>
							<td nowrap style="text-align:right" width="40" title="<cf_get_lang_main no='227.KDV'>">#get_payment_rows.tax#</td>
						</cfif>
						<cfif x_payment_plan_otv>
							<td nowrap style="text-align:right" width="40" title="<cf_get_lang_main no='609.ÖTV'>">#get_payment_rows.otv#</td>
						</cfif>
						<td nowrap style="text-align:right" width="50" title="<cf_get_lang_main no='223.Miktar'>">#GET_PAYMENT_ROWS.QUANTITY#</td>
						<td nowrap style="text-align:right" width="80" title="<cf_get_lang_main no='261.Tutar'>">#TLFormat(GET_PAYMENT_ROWS.AMOUNT)#</td>
						<td nowrap width="55" title="<cf_get_lang_main no='77.Para Br'>">#GET_PAYMENT_ROWS.MONEY_TYPE#</td>
						<td nowrap style="text-align:right" width="80" title="<cf_get_lang no='311.Satır Toplamı'>">#TLFormat(GET_PAYMENT_ROWS.ROW_TOTAL)#</td>
						<td nowrap style="text-align:right" width="50" title="<cf_get_lang_main no='229.İSK'>(%)">#TLFormat(GET_PAYMENT_ROWS.DISCOUNT)#</td>
						<cfif x_payment_plan_isk_amount>
							<td nowrap style="text-align:right" width="50" title="<cf_get_lang_main no='229.İSK'> Tutar">#TLFormat(GET_PAYMENT_ROWS.DISCOUNT_AMOUNT)#</td>
						</cfif>
						<td nowrap style="text-align:right" title="<cf_get_lang no='312.Net Satır Top'>">#TLFormat(GET_PAYMENT_ROWS.ROW_NET_TOTAL)#</td>
						<cfif x_payment_plan_kdv_amount>
							<cfset nettotal_kdv = GET_PAYMENT_ROWS.ROW_NET_TOTAL*GET_PAYMENT_ROWS.TAX/100>
							<cfset nettotal_otv = GET_PAYMENT_ROWS.ROW_NET_TOTAL*GET_PAYMENT_ROWS.OTV/100>
							<td style="text-align:right" title="KDV'li <cf_get_lang no='312.Net Satır Top'>">#TLFormat(GET_PAYMENT_ROWS.ROW_NET_TOTAL+nettotal_kdv+nettotal_otv)#</td>
						</cfif>
						<td nowrap align="center" title="Fatura Tipi"><cfif GET_PAYMENT_ROWS.IS_COLLECTED_INVOICE eq 1><font color="006600"><b>T</b></font><cfelse><font color="FF0000"><b>G</b></font></cfif></td>
						<td nowrap align="center" title="<cf_get_lang no='313.Faturalandı'>">
							<cfif len(GET_PAYMENT_ROWS.INVOICE_ID)>
								<a href="javascript://" onClick="windowopen('#request.self#?fuseaction=objects.popup_detail_invoice&id=#GET_PAYMENT_ROWS.INVOICE_ID#&period_id=#GET_PAYMENT_ROWS.PERIOD_ID#','page');" class="tableyazi"><img src="/images/ship_list.gif" border="0" align="absmiddle"></a><cfif len(GET_PAYMENT_ROWS.IS_INVOICE_IPTAL)><font color="red" size="+1"><b>*</b></font></cfif>
							</cfif>
						</td>
						<td nowrap align="center" title="<cf_get_lang no='316.Toplu Prov Oluşturuldu'>">
							<cfif GET_PAYMENT_ROWS.IS_COLLECTED_PROVISION eq 1><img src="/images/c_ok.gif" title="<cf_get_lang no='316.Toplu Prov Oluşturuldu'>" border="0"></cfif>
						</td>
						<td nowrap align="center" title="<cf_get_lang no='315.Ödendi'>">
							<cfif x_payment_plan_revenue_info and len(GET_PAYMENT_ROWS.CARI_ACT_TYPE) and GET_PAYMENT_ROWS.IS_PAID eq 1>
								<cfswitch expression = "#GET_PAYMENT_ROWS.CARI_ACT_TYPE#">
									<cfcase value="24"><cfset type="ch.popup_dsp_gelenh&period_id=#GET_PAYMENT_ROWS.CARI_PERIOD_ID#"></cfcase>
									<cfcase value="31"><cfset type="ch.popup_dsp_cash_revenue&period_id=#GET_PAYMENT_ROWS.CARI_PERIOD_ID#"></cfcase>
									<cfcase value="42"><cfset type="ch.popup_print_upd_debit_claim_note&period_id=#GET_PAYMENT_ROWS.CARI_PERIOD_ID#"></cfcase>
									<cfcase value="43"><cfset type="objects.popup_cari_action&period_id=#GET_PAYMENT_ROWS.CARI_PERIOD_ID#"></cfcase>
									<cfcase value="90"><cfset type="ch.popup_dsp_payroll_entry&period_id=#GET_PAYMENT_ROWS.CARI_PERIOD_ID#"></cfcase>
									<cfcase value="97"><cfset type="ch.popup_dsp_voucher_payroll_action&period_id=#GET_PAYMENT_ROWS.CARI_PERIOD_ID#"></cfcase>
									<cfcase value="241"><cfset type="ch.popup_dsp_credit_card_payment_type"></cfcase>
									<cfcase value="251"><cfset type="bank.popup_dsp_assign_order&period_id=#GET_PAYMENT_ROWS.CARI_PERIOD_ID#"></cfcase>
								</cfswitch>
								<cfif listfind('24,31,32,241,242,251,43',GET_PAYMENT_ROWS.CARI_ACT_TYPE,',')>
									<cfset page_type = 'small'>
								<cfelse>
									<cfset page_type = 'page'>
								</cfif>
								<cfif GET_PAYMENT_ROWS.CARI_ACT_TABLE is 'CHEQUE'> 
									<a class="tableyazi" href="javascript://" onClick="windowopen('#request.self#?fuseaction=objects.popup_cheque_det&ID=#GET_PAYMENT_ROWS.CARI_ACT_ID#&period_id=#GET_PAYMENT_ROWS.CARI_PERIOD_ID#','small')">
										<img src="/images/ship_list.gif" border="0" align="absmiddle">
									</a>
								<cfelseif GET_PAYMENT_ROWS.CARI_ACT_TABLE is 'VOUCHER'> 
									<a class="tableyazi" href="javascript://" onClick="windowopen('#request.self#?fuseaction=objects.popup_voucher_det&ID=#GET_PAYMENT_ROWS.CARI_ACT_ID#&period_id=#GET_PAYMENT_ROWS.CARI_PERIOD_ID#','small')">
										<img src="/images/ship_list.gif" border="0" align="absmiddle">
									</a>
								<cfelse>													
									<a class="tableyazi" href="javascript://" onClick="windowopen('#request.self#?fuseaction=#type#&id=#GET_PAYMENT_ROWS.CARI_ACT_ID#','#page_type#');" title="İşlem Detayı">
										<img src="/images/ship_list.gif" border="0" align="absmiddle">
									</a>
								</cfif>
							<cfelse>
								<cfif GET_PAYMENT_ROWS.IS_PAID eq 1><img src="/images/c_ok.gif" title="<cf_get_lang no='315.Ödendi'>" border="0"><cfelse>&nbsp;</cfif>
							</cfif>
						</td>
						<cfif x_payment_plan_campaign>
							<td nowrap="nowrap" title="<cf_get_lang_main no='34.Kampanya'>"><cfif len(GET_PAYMENT_ROWS.CAMPAIGN_ID)>#GET_PAYMENT_ROWS.camp_head#</cfif></td>
						</cfif>
						<cfif x_payment_plan_reference>
							<td nowrap="nowrap" title="<cf_get_lang_main no='1372.Referans'>"><cfif len(get_payment_rows.subscription_no)>#get_payment_rows.subscription_no#</cfif></td>
						</cfif>
						<cfif x_payment_plan_service>
							<td nowrap="nowrap" title="<cf_get_lang_main no='244.Servis'>"><cfif len(get_payment_rows.service_no)>#get_payment_rows.service_no#</cfif></td>
						</cfif>
						<cfif x_payment_plan_call>
							<td nowrap="nowrap" title="<cf_get_lang_main no='26.Callcenter'>"><cfif len(GET_PAYMENT_ROWS.CALL_ID)>#GET_PAYMENT_ROWS.G_SERVICE_NO#</cfif></td>
						</cfif>
						<cfif x_payment_plan_record_info>
							<td nowrap="nowrap" title="<cf_get_lang_main no='71.Kayıt'>">
								<cfif len(GET_PAYMENT_ROWS.RECORD_EMP_NAME)>
									#GET_PAYMENT_ROWS.RECORD_EMP_NAME# - #dateformat(GET_PAYMENT_ROWS.RECORD_DATE,dateformat_style)# (#timeformat(GET_PAYMENT_ROWS.RECORD_DATE,timeformat_style)#)
								</cfif>
							</td>
							<td nowrap="nowrap" title="<cf_get_lang_main no='479.Güncelleyen'>">
								<cfif len(GET_PAYMENT_ROWS.UPDATE_EMP_NAME)>
									#GET_PAYMENT_ROWS.UPDATE_EMP_NAME# - #dateformat(GET_PAYMENT_ROWS.UPDATE_DATE,dateformat_style)# (#timeformat(GET_PAYMENT_ROWS.UPDATE_DATE,timeformat_style)#)
								</cfif>
							</td>
						</cfif>
					</tr>
				</cfoutput>
			</tbody>
	</cf_medium_list>
