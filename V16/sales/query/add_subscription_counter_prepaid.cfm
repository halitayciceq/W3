<cfset subsCounterPre = createObject("component","V16.sales.cfc.subscription_counter_prepaid")>
<cfset response = subsCounterPre.insert(
    process_row_id              :   attributes.process_stage,
    counter_id                  :   attributes.counter_id,
    counter_loading_price       :   attributes.loading_price,
    counter_total_price         :   attributes.total_price,
    counter_loading_date        :   attributes.action_date,
    loading_employee_id         :   attributes.emp_id
)>
<cfif response.status>
    <script type="text/javascript">
        <cfoutput>
            window.location.href = '#request.self#?fuseaction=sales.subscription_counter_prepaid&event=upd&scp_id=#response.result.identitycol#';
        </cfoutput>
    </script>
<cfelse>
    <script>
        alert('<cf_get_lang dictionary_id = "48344">');
    </script>
</cfif>