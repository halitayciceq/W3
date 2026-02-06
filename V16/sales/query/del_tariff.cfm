<cfscript>
    Tariff = createObject("component", "V16.sales.cfc.tariff");
        Tariff.delTariffProduct(
        tariff_id : '#iif(isdefined("attributes.tariff_id"),"attributes.tariff_id",DE(""))#'
    );
    </cfscript>
<script type="text/javascript">
    window.location.href="/<cfoutput>#request.self#?fuseaction=sales.tariff</cfoutput>";
</script>