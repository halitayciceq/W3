<cfquery name="DEL_SALES_TEAM" datasource="#DSN#">
	DELETE 
	FROM 
		SALES_ZONE_GROUP
	WHERE 
		PARTNER_ID = #attributes.emp_id#
</cfquery>
<script type="text/javascript">
wrk_opener_reload();
self.close();
</script>
