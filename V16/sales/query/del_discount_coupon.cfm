<cflock name="#CreateUUID()#" timeout="20">
	<cftransaction>
        <cfquery name="DEL_DISCOUNT_COUPON" datasource="#DSN3#">
            DELETE FROM ORDER_MONEY_CREDITS WHERE ORDER_CREDIT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.order_credit_id#">
        </cfquery>
       <!--- <cf_add_log log_type="-1" action_id="#attributes.order_credit_id# " action_name="#url.action_name#" data_source="#dsn3#">--->
	</cftransaction>
</cflock>	
<script type="text/javascript">
	wrk_opener_reload();
	window.close();
</script>

