<cfset contract_cmp = createObject("component","V16.sales.cfc.subscription_contract")>
<cfset get_process = contract_cmp.get_process(dsn3:dsn3, subscription_id:attributes.subscription_id)>
<cflock name="#CREATEUUID()#" timeout="60">
	<cftransaction>
		<!--- Odeme Plani--->
		<cfset DEL_COUNTER = contract_cmp.DEL_COUNTER(dsn3:dsn3, subscription_id:attributes.subscription_id)>
		<!--- Sayac Tipi --->
		<cfset DEL_COUNTER = contract_cmp.DEL_COUNTER_SUBS(dsn3:dsn3, subscription_id:attributes.subscription_id)>
		<!--- Partition --->
		<cfset DEL_CONTRACT_PARTITION = contract_cmp.DEL_CONTRACT_PARTITION(dsn3:dsn3, subscription_id:attributes.subscription_id)>
		<!--- Urun Plani Money--->
		<cfset DEL_CONTRACT_MONEY = contract_cmp.DEL_CONTRACT_MONEY(dsn3:dsn3, subscription_id:attributes.subscription_id)>
	  	<!--- Urun Plani --->
		<cfset DEL_CONTRACT_ROW = contract_cmp.DEL_CONTRACT_ROW(dsn3:dsn3, subscription_id:attributes.subscription_id)>
		<!--- Sistem ilişkileri --->
		<cfset DEL_CONTRACT_RELATIONS = contract_cmp.DEL_CONTRACT_RELATIONS(dsn3:dsn3, subscription_id:attributes.subscription_id)>
		<!--- Sistem kampanya ilişkileri --->
		<cfset DEL_CONTRACT_RELATIONS = contract_cmp.DEL_CONTRACT_CAMPAIGN_RELATIONS(dsn3:dsn3, subscription_id:attributes.subscription_id)>
		<!--- Sistem --->
		<cfset DEL_SUBSCRIPTION_CONTRACT = contract_cmp.DEL_SUBSCRIPTION_CONTRACT(dsn3:dsn3, subscription_id:attributes.subscription_id)>  
	  <cf_add_log  log_type="-1"  action_id="#attributes.subscription_id#" action_name="#attributes.subscription_no#" process_stage="#get_process.subscription_stage#" PAPER_NO="#get_process.subscription_no#" data_source="#dsn3#">	  
	</cftransaction>
</cflock>
<cflocation url="#request.self#?fuseaction=sales.list_subscription_contract" addtoken="no">
