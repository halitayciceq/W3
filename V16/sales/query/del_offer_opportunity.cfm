
<cfif isdefined("attributes.opportunity_id") and len(attributes.opportunity_id)>
	<cfquery name="upd_offer" datasource="#DSN3#">
		UPDATE
			OFFER
		SET
			OPPORTUNITY_ID=NULL
		WHERE
			OFFER_ID=#attributes.OFFER_ID#
	</cfquery>
<cfelse>
	<cfquery name="upd_offer" datasource="#DSN3#">
		UPDATE
			OFFER
		SET
			OPP_ID=NULL
		WHERE
			OFFER_ID=#attributes.OFFER_ID#
	</cfquery>
</cfif>

<script type="text/javascript">
	<cfif isdefined("attributes.draggable")>closeBoxDraggable( '<cfoutput>#attributes.modal_id#</cfoutput>');refresh_box('opportunity_purchase','<cfoutput>#request.self#</cfoutput>?fuseaction=purchase.opportunity_offer&opp_id=<cfoutput>#attributes.opportunity_id#</cfoutput>','0'); <cfelse>	wrk_opener_reload();window.close();</cfif>
</script>

