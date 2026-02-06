<cf_date tarih="attributes.valid_date">
<cfquery name="UPD_MONEY" datasource="#DSN3#">
	UPDATE 
		ORDER_MONEY_CREDITS
	SET
		MONEY_CREDIT_STATUS = <cfif isdefined('attributes.money_credit_status') and len(attributes.money_credit_status)>1<cfelse>0</cfif>,
		VALID_DATE = #attributes.valid_date#,
        UPDATE_EMP = #session.ep.userid#,
        UPDATE_IP = '#cgi.remote_addr#',
        UPDATE_DATE = #Now()#
	WHERE
		ORDER_CREDIT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.order_credit_id#">
</cfquery>
<script type="text/javascript">
    wrk_opener_reload();
	window.close();
</script>
