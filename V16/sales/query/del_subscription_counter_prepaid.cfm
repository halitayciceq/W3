<cfset subsCounterPre = createObject("component","V16.sales.cfc.subscription_counter_prepaid")>
<cfset response = subsCounterPre.delete(
    scp_id  :   attributes.scp_id
)>
<cfif response.status>
    <script type="text/javascript">
        <cfoutput>
            window.location.href = '#request.self#?fuseaction=sales.subscription_counter_prepaid';
        </cfoutput>
    </script>
<cfelse>
    <script>
        alert('<cf_get_lang dictionary_id = "48344">');
    </script>
</cfif>