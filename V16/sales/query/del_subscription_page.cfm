<cfquery name="DEL_OFFER_PAGE" datasource="#dsn3#">
	DELETE FROM
		SUBSCRIPTION_PAGES
	WHERE
		<cfif isdefined(attributes.page_id)>
		PAGE_ID = #attributes.page_id#
		<cfelse>
		PAGE_ID = #page_id#
		</cfif>	
</cfquery>
<script type="text/javascript">
	<cfif not isdefined("attributes.draggable")><cflocation url="#request.self#?fuseaction=sales.popup_add_subscription_page&subs_id=#attributes.subs_id#" addtoken="No"><cfelse>closeBoxDraggable( '<cfoutput>#attributes.modal_id#</cfoutput>');</cfif>
 </script>
