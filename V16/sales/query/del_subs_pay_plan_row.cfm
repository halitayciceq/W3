<cfset contract_cmp = createObject("component","V16.sales.cfc.subscription_contract")>
<cflock name="#CreateUUID()#" timeout="20">
	<cftransaction>
		<cfset GET_PAYM_PLAN = contract_cmp.GET_PAYM_PLAN(subscription_id : attributes.subscription_id )>
		<cfset history_record = GET_PAYM_PLAN.recordcount>
		<cfset INSERT_PAYM_PLAN_HISTORY = contract_cmp.INSERT_PAYM_PLAN_HISTORY(subscription_id : attributes.subscription_id)>
		<!---temizle butonuyla silincek faturalanmamıs,ödenmemiş,provzyon oluşmamış,referans seçilmemiş satırların toplu silinmesi içindir--->
		<cfif isDefined("attributes.del_all") and isDefined("attributes.subscription_id")>
			<cfif not isDefined("cancel_subs_info")><cf_date tarih='attributes.start_date'></cfif><!--- sistem iptal sayfasndan yapulan silmeler için --->
			<cfset DEL_PAY_PLAN_ROW = contract_cmp.DEL_PAY_PLAN_ROW(start_date : attributes.start_date,
																	xml_del_ref_rows :  (isDefined("xml_del_ref_rows") and len(xml_del_ref_rows)) ? xml_del_ref_rows : 0,
																	xml_del_camp_rows : (isDefined("xml_del_camp_rows") and len(xml_del_camp_rows)) ? xml_del_camp_rows : 0,
																	subscription_id : attributes.subscription_id)>
	
		</cfif>
		<!---sadece silme ikonu gelen tek satir silmelerde çalışır--->
		<cfif isDefined("attributes.payment_row_id")>
			<cfset control_row = contract_cmp.control_row(payment_row_id :  attributes.payment_row_id)>
            <cfif control_row.IS_PAID eq 1 or control_row.IS_COLLECTED_PROVISION eq 1 or control_row.IS_BILLED eq 1>
				<script language="javascript">
					alert("Satır İşlem Gördüğü İçin Silemezsiniz !");
					opener.location.reload();
					window.close();
				</script>
			<cfelse>
				<cfset DEL_PAY_PLAN_ROW = contract_cmp.DEL_PAY_PLAN_ROW2(payment_row_id: attributes.payment_row_id,
																		subscription_id : attributes.subscription_id)>
            </cfif>
		</cfif>
		<cfif GET_PAYM_PLAN.recordcount>
			<cfset  GET_PAYM_PLAN_HISTORY = contract_cmp.GET_PAYM_PLAN_HISTORY(subscription_id : attributes.subscription_id,
																				history_record : history_record)>			
			<cfoutput query="GET_PAYM_PLAN_HISTORY">
				<cfset  GET_LAST_PAYPLAN = contract_cmp.GET_LAST_PAYPLAN(subscription_id : attributes.subscription_id,
																		PAYM_PLAN_YEAR : GET_PAYM_PLAN_HISTORY.PAYM_PLAN_YEAR,
																		PAYM_PLAN_MONEY_TYPE : GET_PAYM_PLAN_HISTORY.PAYM_PLAN_MONEY_TYPE)>
				<cfif GET_LAST_PAYPLAN.recordcount>
					<cfset  UPD_PAYM_PLAN = contract_cmp.UPD_PAYM_PLAN(LAST_TOTAL : GET_LAST_PAYPLAN.LAST_TOTAL,
																		SUBS_PAYMPLAN_ROW_HISTORY_ID : GET_PAYM_PLAN_HISTORY.SUBS_PAYMPLAN_ROW_HISTORY_ID)>
			
				</cfif>
			</cfoutput>

			<cfif len(GET_PAYM_PLAN.CM_ID)>
				<cfquery name="del_counter_meter" datasource="#dsn3#">
					UPDATE SUBSCRIPTION_COUNTER_METER SET IS_PAYMENT_PLAN = 0 WHERE SCM_ID = #GET_PAYM_PLAN.CM_ID#
				</cfquery>
			</cfif>
		</cfif>
	</cftransaction>
</cflock>
<cfif not isDefined("cancel_subs_info")><!--- sistem iptal sayfasndan yapulan silmeler için --->
	<script type="text/javascript">
		<cfif isdefined("attributes.modal_id") and len(attributes.modal_id)>
			location.href = document.referrer;
		<cfelse>
			wrk_opener_reload();
			window.close();
		</cfif>
	</script>
</cfif>
