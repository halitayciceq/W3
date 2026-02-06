<cfscript>
    CounterMeter = createObject("component", "V16.sales.cfc.counter_meter");
    CounterMeter.delete(
        cm_id : attributes.cm_id
    );
</cfscript>
<script>
    location.href = '<cfoutput>#request.self#</cfoutput>?fuseaction=sales.counter_meter';
</script>
