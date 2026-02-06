<cfif len(attributes.premium_date)><cf_date tarih="attributes.premium_date"></cfif>
<cfquery name="upd_premium" datasource="#dsn3#">
	UPDATE 
		SUBSCRIPTION_CONTRACT		
	SET
		PREMIUM_VALUE = <cfif len(attributes.premium_value)>#attributes.premium_value#<cfelse>NULL</cfif>,
		PREMIUM_DATE = <cfif isDefined("attributes.premium_date") and len(attributes.premium_date)>#attributes.premium_date#<cfelse>NULL</cfif>
	WHERE
		SUBSCRIPTION_ID = #attributes.subscription_id#
</cfquery>
<script type="text/javascript">
	<cfif not isdefined("attributes.draggable")>
		window.close();
	<cfelse>
		closeBoxDraggable( '<cfoutput>#attributes.modal_id#</cfoutput>' );
	</cfif>
</script>
