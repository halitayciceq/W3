<cf_get_lang_set module_name="sales">
<cfif isDefined("attributes.company_id") and len(attributes.company_id)>
	<cfset acc = GET_COMPANY_PERIOD(attributes.company_id)>
	<cfif not len(acc)>
		<script type="text/javascript">
			alert("<cf_get_lang dictionary_id='41388.Seçilen Şirketin Muhasebe Kodu Belirtilmemiş'>!");
			window.location.href='<cfoutput>#cgi.referer#</cfoutput>';
		</script>
		<cfabort>
	</cfif>
<cfelseif isDefined("attributes.consumer_id") and len(attributes.consumer_id)>
	<cfset acc = GET_CONSUMER_PERIOD(attributes.consumer_id)>
	<cfif not len(acc)>
		<script type="text/javascript">
			alert("<<cf_get_lang dictionary_id='41389.Seçilen Müşterinin Muhasebe Kodu Belirtilmemiş'>!");
			window.location.href='<cfoutput>#cgi.referer#</cfoutput>';
		</script>
		<cfabort>
	</cfif>
</cfif>
<cfquery name="get_order_detail" datasource="#dsn3#">
	SELECT ORDER_STATUS FROM ORDERS WHERE ORDER_ID = #attributes.order_id#
</cfquery>
<cfif get_order_detail.order_status eq 0>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='41391.Satış İptal Edildiği İçin İşlem Yapamazsınız'> !");
		window.location.href='<cfoutput>#cgi.referer#</cfoutput>';
	</script>
	<cfabort>
</cfif>
<cfset wrk_id = dateformat(now(),'YYYYMMDD')&timeformat(now(),'HHmmss')&'_#session.ep.userid#_'&round(rand()*100)>
<cf_date tarih='attributes.cancel_date'>
<cflock name="#CREATEUUID()#" timeout="60">
	<cftransaction>
		<!--- Sipariş iptal ediliyor --->
		<cfquery name="upd_order" datasource="#dsn2#">
			UPDATE
				#dsn3_alias#.ORDERS
			SET
				CANCEL_TYPE_ID = #attributes.cancel_type#,
				CANCEL_DATE = #attributes.cancel_date#,
				CANCEL_DETAIL =	<cfif len(attributes.cancel_detail)>'#attributes.cancel_detail#'<cfelse>NULL</cfif>,
				ORDER_STATUS = 0,
				UPDATE_DATE = #now()#,
				UPDATE_IP = '#cgi.remote_addr#',
				UPDATE_EMP = #session.ep.userid#	 
			WHERE
				ORDER_ID = #attributes.order_id#
		</cfquery>
		<!--- Senetler İade Ediliyor --->
		<cfinclude template="add_order_cancel_voucher.cfm">
		<!--- çekler İade Ediliyor --->
		<cfinclude template="add_order_cancel_cheque.cfm">
		<!--- Kasa tahsilatları varsa karşılığında ödeme kaydediliyor --->
		<cfinclude template="add_order_cancel_cash.cfm">
		<!--- Pos tahsilatları varsa karşılığında iptal işlemi kaydediliyor --->
		<cfinclude template="add_order_cancel_pos.cfm">
	</cftransaction>
</cflock>
<script type="text/javascript">
	location.href = document.referrer;
</script>
<cf_get_lang_set module_name="#lcase(listgetat(attributes.fuseaction,1,'.'))#">
