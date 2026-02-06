<cfset subsCounterPre = createObject("component","V16.sales.cfc.counter")>
<cfset response = subsCounterPre.update(
    subscription_id: attributes.subscription_id,
    process_stage: attributes.process_stage,
    counter_number: attributes.counter_number,
    counter_type: attributes.counter_type,
    product_id: attributes.product_id,
    stock_id: attributes.stock_id,
    amount: attributes.amount,
    unit_id: attributes.unit_id,
    unit_name: attributes.unit_name,
    price_catid: attributes.price_catid,
    price: attributes.price,
    money: attributes.money,
    start_date: attributes.counter_startdate,
    finish_date: attributes.counter_finishdate,
    document: attributes.document,
    uploaded_file: attributes.uploaded_file,
    counter_detail: attributes.counter_detail,
    counter_id: attributes.counter_id,
    our_company_id: attributes.our_company_id
)>
<cfif not response>
    <script>
        alert('<cf_get_lang dictionary_id = "48344.Yükleme işlemi sırasında bir hata oluştu">');
    </script>
    <cfabort>
</cfif>