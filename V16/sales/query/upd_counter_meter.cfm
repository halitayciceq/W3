<cfset subsCounterPre = createObject("component","V16.sales.cfc.counter_meter")>
<cf_date tarih="attributes.action_date">
<cfset response = subsCounterPre.update(
    subscription_id : attributes.subscription_id,
    counter_id : attributes.counter_id,
    previous_value : attributes.previous_value,
    last_value : attributes.last_value,
    difference : attributes.difference,
    cm_id : attributes.cm_id,
    action_date: attributes.action_date
)>
<cfif response>
    <script type="text/javascript">
        <cfoutput>
            window.location.href = '#request.self#?fuseaction=sales.counter_meter&event=upd&cm_id=#attributes.cm_id#';
        </cfoutput>
    </script>
<cfelse>
    <script>
        alert('<cf_get_lang dictionary_id = "48344">');
    </script>
</cfif>