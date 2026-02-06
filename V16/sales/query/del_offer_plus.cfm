<cfquery name="DEL_OFFER_PLUS" datasource="#dsn3#">
	DELETE
		OFFER_PLUS
	WHERE
		<cfif isdefined("attributes.OFFER_PLUS_ID")>
		OFFER_PLUS_ID = #attributes.OFFER_PLUS_ID#
		<cfelse>
		OFFER_PLUS_ID = #OFFER_PLUS_ID#
		</cfif>
		
</cfquery>
<script type="text/javascript">
	<cfif not isdefined("attributes.draggable")>location.href = document.referrer;<cfelse>closeBoxDraggable( '<cfoutput>#attributes.modal_id#</cfoutput>');</cfif>
</script>
