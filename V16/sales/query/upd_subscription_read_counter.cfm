<cf_date tarih='attributes.valid_date'>
<cflock name="#CREATEUUID()#" timeout="20">
  <cftransaction>
	<cfquery name="UPD_COUNTER_RESULT" datasource="#DSN3#">
	UPDATE
		SUBSCRIPTION_COUNTER_RESULT
	SET
		SUBSCRIPTION_ID = #attributes.subscription_id#,
		VALID_EMP = #attributes.valid_id#,
		VALID_DATE = #attributes.valid_date_upd#,
		UPDATE_EMP = #session.ep.userid#,
		UPDATE_DATE = #now()#,
		UPDATE_IP = '#cgi.remote_addr#'	
	WHERE
		COUNTER_RESULT_ID = #attributes.result_id#	
	</cfquery>
	<cfloop from="1" to="#attributes.record_num#" index="i">
		<cfif len(evaluate("attributes.finish_value#i#"))>
			<cfset form_result_row_id = evaluate("attributes.result_row_id#i#")>
			<cfset form_counter_id = evaluate("attributes.counter_id#i#")>
			<cfset form_product_id = evaluate("attributes.product_id#i#")>		
			<cfset form_stock_id = evaluate("attributes.stock_id#i#")>		
			<cfset form_name_product = evaluate("attributes.name_product#i#")>		
			<cfset form_start_value = evaluate("attributes.start_value#i#")>
			<cfset form_finish_value = evaluate("attributes.finish_value#i#")>
			<cfset form_difference = evaluate("attributes.difference#i#")>
			<cfset form_price = evaluate("attributes.price#i#")>
			<cfset form_total = evaluate("attributes.total#i#")>			
			<cfset form_other_money = evaluate("attributes.other_money#i#")>
			<cfquery name="UPD_COUNTER_RESULT_ROW" datasource="#DSN3#">
				UPDATE
					SUBSCRIPTION_COUNTER_RESULT_ROW
				SET
					COUNTER_RESULT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.result_id#">, 
					COUNTER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#form_counter_id#">,
					PRODUCT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#form_product_id#">,
					STOCK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#form_stock_id#">,
					NAME_PRODUCT = <cfqueryparam cfsqltype="cf_sql_nvarchar" value="#form_name_product#">,
					START_VALUE = <cfqueryparam cfsqltype="cf_sql_float" value="#form_start_value#">,
					FINISH_VALUE = <cfqueryparam cfsqltype="cf_sql_float" value="#form_finish_value#">,
					COUNTER_DIFFERENCE = <cfqueryparam cfsqltype="cf_sql_float" value="#form_difference#">,
					PRICE = <cfqueryparam cfsqltype="cf_sql_float" value="#form_price#">,
					TOTAL = <cfqueryparam cfsqltype="cf_sql_float" value="#form_total#">,
					OTHER_MONEY = <cfqueryparam cfsqltype="cf_sql_nvarchar" value="#form_other_money#">
				WHERE
					COUNTER_RESULT_ROW_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#form_result_row_id#">	
			</cfquery>
		</cfif>
	</cfloop>
  </cftransaction>
</cflock>

<script type="text/javascript">
	<cfif not isdefined("attributes.draggable")>
		wrk_opener_reload();
		window.close();
	<cfelseif isdefined("attributes.draggable")>
		closeBoxDraggable( '<cfoutput>#attributes.modal_id#</cfoutput>' );
		location.reload();
	</cfif>
</script>
