<cf_date tarih='attributes.valid_date'>
<cflock name="#CREATEUUID()#" timeout="20">
  <cftransaction>
	<cfquery name="ADD_COUNTER_RESULT" datasource="#DSN3#" result="MAX_ID">
		INSERT INTO
			SUBSCRIPTION_COUNTER_RESULT
		(
			SUBSCRIPTION_ID,
			VALID_EMP,
			VALID_DATE,
			<!--- OTHER_MONEY,
			OTHER_MONEY_VALUE,
			OTHER_MONEY_2,
			OTHER_MONEY_VALUE_2, --->
			IS_INVOICE,
			RECORD_EMP,
			RECORD_DATE,
			RECORD_IP
		)
		VALUES
		(
			#attributes.subscription_id#,
			#attributes.valid_id#,
			#attributes.valid_date#,
			<!--- '#attributes.other_money_cost#',
			#attributes.total_result_cost#,
			'#attributes.other_money_cost2#',
			#attributes.total_result_cost2#, --->
			0,	
			#session.ep.userid#,
			#now()#,
			'#cgi.remote_addr#'
	   )
	</cfquery>
	<cfloop from="1" to="#attributes.record_num#" index="i">
		<cfif len(evaluate("attributes.finish_value#i#"))>
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
			<cfquery name="ADD_COUNTER_RESULT_ROW" datasource="#DSN3#">
				INSERT INTO
					SUBSCRIPTION_COUNTER_RESULT_ROW
				(
					COUNTER_RESULT_ID,
					COUNTER_ID,
					PRODUCT_ID,
					STOCK_ID,
					NAME_PRODUCT,					
					START_VALUE,
					FINISH_VALUE,
					COUNTER_DIFFERENCE,
					PRICE,
					TOTAL,
					OTHER_MONEY
				)
				VALUES
				(
					<cfqueryparam cfsqltype="cf_sql_integer" value="#MAX_ID.IDENTITYCOL#">,
					<cfqueryparam cfsqltype="cf_sql_integer" value="#form_counter_id#">,
					<cfqueryparam cfsqltype="cf_sql_integer" value="#form_product_id#">,
					<cfqueryparam cfsqltype="cf_sql_integer" value="#form_stock_id#">,
					<cfqueryparam cfsqltype="cf_sql_nvarchar" value="#form_name_product#">,
					<cfqueryparam cfsqltype="cf_sql_float" value="#form_start_value#">,
					<cfqueryparam cfsqltype="cf_sql_float" value="#form_finish_value#">,
					<cfqueryparam cfsqltype="cf_sql_float" value="#form_difference#">,					
					<cfqueryparam cfsqltype="cf_sql_float" value="#form_price#">,
					<cfqueryparam cfsqltype="cf_sql_float" value="#form_total#">,
					<cfqueryparam cfsqltype="cf_sql_nvarchar" value="#form_other_money#">
			   )
			</cfquery>
		</cfif>
	</cfloop>
  </cftransaction>
</cflock>
<script type="text/javascript">
	<cfif not isdefined("attributes.draggable")>
		wrk_opener_reload();
		window.location.href='<cfoutput>#request.self#?fuseaction=sales.popup_upd_subscription_read_counter&subscription_id=#attributes.subscription_id#&result_id=#MAX_ID.IDENTITYCOL#</cfoutput>','horizantal','popup_upd_subscription_read_counter';
	<cfelse>
		closeBoxDraggable( '<cfoutput>#attributes.modal_id#</cfoutput>' );
		location.reload();
	</cfif>
</script>
