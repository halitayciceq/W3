<cfquery name="DEL_ORDER_PLUS" datasource="#dsn3#">
	DELETE
		ORDER_PLUS
	WHERE
		<cfif isdefined("attributes.ORDER_PLUS_ID")>
		ORDER_PLUS_ID = #attributes.ORDER_PLUS_ID#	
		<cfelse>
		ORDER_PLUS_ID = #ORDER_PLUS_ID#
		</cfif>
		
</cfquery>
<script type="text/javascript">
	wrk_opener_reload();
	window.close();
</script>
