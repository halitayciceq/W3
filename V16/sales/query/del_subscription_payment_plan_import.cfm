<cfscript>
	attributes.actionid =0;
	comp = createObject("component","V16.sales.cfc.subscription_payment_plan_import");
	result = false;
	if(isdefined("attributes.del_plan") and len(attributes.del_plan)){
		check = comp.get_billed_row(
			SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID: attributes.import_id
		);
		
		if(check.recordcount eq 0)
		{
			result = comp.delete_payment_plan(
				SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID: attributes.import_id,
				ACTION_EMP : session.ep.userid
			);
			if(result){
				result = comp.delete(
					SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID: attributes.import_id
				);
			}
		}else{
			result = false;//kayıt silinemez faturalanan satırlar var
		}
	}else{

		result = comp.delete(
			SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID: attributes.import_id
		);
	}
</cfscript>
<script type="text/javascript">
	<cfif result>
		window.location.href="<cfoutput>#request.self#?fuseaction=sales.list_subscription_payment_plan_import</cfoutput>";
	<cfelse>
		window.location.href="<cfoutput>#request.self#?fuseaction=sales.list_subscription_payment_plan_import&import_id=#attributes.import_id#</cfoutput>";
	</cfif>
</script>