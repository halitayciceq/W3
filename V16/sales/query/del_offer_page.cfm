<cfquery name="DEL_OFFER_PAGE" datasource="#dsn3#">
	DELETE FROM
		OFFER_PAGES
	WHERE
		<cfif isdefined(attributes.page_id)>
		PAGE_ID = #attributes.PAGE_ID#
		<cfelse>
		PAGE_ID = #PAGE_ID#
		</cfif>	
</cfquery>
<script>
	<cfif not isdefined("attributes.draggable")>
		<cflocation url="#request.self#?fuseaction=sales.popup_form_add_page&offer_id=#attributes.offer_id#" addtoken="No">
	<cfelse>
		closeBoxDraggable( '<cfoutput>#attributes.modal_id#</cfoutput>' );
		location.reload();
	</cfif>
</script>

