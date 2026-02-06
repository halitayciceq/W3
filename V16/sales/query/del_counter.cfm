<cfscript>
    Counter = createObject("component", "V16.sales.cfc.counter");
    Counter.delete(
        counter_id : attributes.counter_id
    );
</cfscript>

<script>
    <cfif not isdefined("attributes.draggable")>
        window.location.href = "<cfoutput>#request.self#</cfoutput>?fuseaction=sales.counter";
    <cfelse>
        closeBoxDraggable( '<cfoutput>#attributes.modal_id#</cfoutput>', 'unique_get_counter' );
    </cfif>
</script>