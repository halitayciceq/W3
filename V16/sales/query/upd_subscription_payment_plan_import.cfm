<cfif isdefined("attributes.convert_submit") and attributes.convert_submit eq 1>
	<!--- ödeme planına dönüştür olarka gelmiş mi --->
	<cfset convert = true>
<cfelse>
	<cfset convert = false>
</cfif>
<!--- güncelleme sadece SUBSCRIPTION_PAYMENT_PLAN_IMPORT tablosundaki veriler ve süreç değiştirilir --->
<cfscript>
	attributes.actionid =0;
	comp = createObject("component","V16.sales.cfc.subscription_payment_plan_import");
	result = comp.main(
		IMPORT_ID: attributes.import_id,
		IMPORT_TYPE_ID: attributes.import_type_id,
		IMPORT_NAME: attributes.IMPORT_NAME,
		DESCRIPTION: attributes.description,
		PROCESS_STAGE: attributes.process_stage,
		START_DATE:attributes.start_date,
		FINISH_DATE: attributes.finish_date,
		ACTION_EMP: session.ep.userid,
		CONVERT:convert
	);

	if(result.actionResult){
		attributes.actionid = result.actionid;
	}else{
		writeoutput('<script type="text/javascript">alert("Hata Oluştu Lütfen Tekrar Deneyiniz!");history.back();</script>');
	}
</cfscript>

<!--- hata oldu ise post ile hata datasını gönder ekranı bas--->
<cfif result.actionResult>
	<cf_workcube_process 
		is_upd='1'
		data_source='#dsn3#'
		old_process_line='0'
		process_stage='#attributes.process_stage#' 
		record_member='#session.ep.userid#' 
		record_date='#now()#'
		action_table='SUBSCRIPTION_PAYMENT_PLAN_IMPORT'
		action_column='SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID'
		action_id='#attributes.import_id#'
		action_page='#request.self#?fuseaction=sales.list_subscription_payment_plan_import&event=upd&import_id=#result.actionid#'
		warning_description = '#getLang("","Abonelik Ödeme Planı Aktarım",66818)# : #attributes.IMPORT_NAME#'>
</cfif>
