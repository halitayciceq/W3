<cflock name="#CreateUUID()#" timeout="20">
	<cftransaction>
	<cfquery name="del_order_demands" datasource="#DSN3#">
		DELETE FROM ORDER_DEMANDS WHERE DEMAND_ID = #attributes.demand_id#
	</cfquery>
	<cfquery name="del_order_demands_history" datasource="#DSN3#">
		DELETE FROM ORDER_DEMANDS_HISTORY WHERE DEMAND_ID = #attributes.demand_id#
	</cfquery>
	<cf_add_log  log_type="-1" action_id="#attributes.demand_id# " action_name="#url.action_name#" data_source="#dsn3#">
	</cftransaction>
</cflock>	
<script type="text/javascript">
	wrk_opener_reload();
	window.close();
</script>

