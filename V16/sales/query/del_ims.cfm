<cfquery name="DEL_FILES" datasource="#DSN#">
	DELETE 
		SALES_ZONES_IMS_RELATION
	WHERE 
		SZ_ID = #attributes.sz_id# AND
		IMS_ID = #attributes.ims_id#
</cfquery>
<script type="text/javascript">
	wrk_opener_reload();
	window.close();
</script>
