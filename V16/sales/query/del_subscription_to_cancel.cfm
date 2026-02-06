<cfquery name="UPD_SUBSCRIPTION_TO_CANCEL" datasource="#DSN3#">
	UPDATE 
		SUBSCRIPTION_CONTRACT		
	SET
		CANCEL_TYPE_ID = NULL,
		CANCEL_DATE = NULL,
		CANCEL_DETAIL =	NULL,
		FINISH_DATE = NULL,
		CANCEL_RECORD_DATE = NULL,
		CANCEL_RECORD_IP = NULL,
		CANCEL_RECORD_EMP = NULL,
		CANCEL_UPDATE_DATE = NULL,
		CANCEL_UPDATE_IP = NULL,
		CANCEL_UPDATE_EMP = NULL		
	WHERE
		SUBSCRIPTION_ID = #attributes.subscription_id#
</cfquery>
<script type="text/javascript">
	<cfif not isdefined("attributes.draggable")>
		wrk_opener_reload(); 
		self.close();
	<cfelse>
		closeBoxDraggable( '<cfoutput>#attributes.modal_id#</cfoutput>' );
		location.reload();
	</cfif>
</script>
