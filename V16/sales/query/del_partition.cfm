<cfquery name="DEL_PARTITION" datasource="#DSN#">
	DELETE FROM 
		SUBSCRIPTION_CONTRACT_PARTITION
	WHERE
		PARTITION_ID = #attributes.partition_id#
</cfquery>
<script type="text/javascript">
	wrk_opener_reload();
	window.close();
</script>
