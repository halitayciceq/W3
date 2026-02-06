<cfquery name="GET_ORDER" datasource="#DSN3#">
	SELECT * FROM ORDERS WHERE ORDER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.order_id#">
</cfquery>
<cfquery name="GET_ORDER_ROW" datasource="#DSN3#">
	SELECT * FROM ORDER_ROW WHERE ORDER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.order_id#">
</cfquery>
<cflock name="#CREATEUUID()#" timeout="20">
	<cftransaction>
    <cf_wrk_get_history datasource="#dsn3#" source_table="ORDERS" target_table="ORDERS_HISTORY" record_id= "#attributes.order_id#" record_name="ORDER_ID">
    <cfquery name="get_max_hist_id" datasource="#dsn3#">
    	SELECT MAX(ORDER_HISTORY_ID) MAX_ID FROM ORDERS_HISTORY
    </cfquery>
    <cf_wrk_get_history datasource="#dsn3#" source_table="ORDER_ROW" target_table="ORDER_ROW_HISTORY" insert_column_name="ORDER_HISTORY_ID" insert_column_value="#get_max_hist_id.MAX_ID#" record_id= "#valuelist(GET_ORDER_ROW.order_ROW_id)#" record_name="ORDER_ROW_ID">
	</cftransaction>
</cflock>

