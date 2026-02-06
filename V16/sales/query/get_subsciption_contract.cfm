<cfset contract_cmp = createObject("component","V16.sales.cfc.subscription_contract")>
<cfset GET_SUBSCRIPTION = contract_cmp.GET_SUBSCRIPTION_F(dsn3:dsn3, dsn_alias:dsn_alias, subscription_id:attributes.subscription_id)>
<cfif len(get_subscription.montage_emp_id)>
	<cfscript>
		montage_emp_ = get_emp_info(get_subscription.montage_emp_id,0,0);
	</cfscript>
<cfelse>
	<cfscript>
		montage_emp_ = '';
	</cfscript>
</cfif>