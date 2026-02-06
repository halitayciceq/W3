<cfquery name="DEL_ASSET_PROJECT" datasource="#dsn#">
	DELETE FROM
		ASSET_P_RESERVE 
	WHERE 
		PROJECT_ID = #URL.ID# AND 
		ASSETP_ID = #ASSETP_ID#
</cfquery>
<script type="text/javascript">
	<cfif attributes.draggable eq 1>
		closeBoxDraggable( '<cfoutput>#attributes.modal_id#</cfoutput>');
		location.reload();
	<cfelse>
		wrk_opener_reload();
		window.close();
	</cfif>
</script>
