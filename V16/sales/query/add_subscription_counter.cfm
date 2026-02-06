<cfif isDefined("uploaded_file") and len(form.uploaded_file)>
	<cfset upload_folder = "#upload_folder##dir_seperator#sales#dir_seperator#">
	<cftry>
		<cffile action="UPLOAD" filefield="uploaded_file" destination="#upload_folder#" mode="777" nameconflict="MAKEUNIQUE" accept="image/*" mode="777">

		<cfset file_name = createUUID()>
		<cffile action="rename" source="#upload_folder##cffile.serverfile#" destination="#upload_folder##file_name#.#cffile.serverfileext#" mode="777">
		
		<!---Script dosyalarını engelle  02092010 FA,ND --->
		<cfset assetTypeName = listlast(cffile.serverfile,'.')>
		<cfset blackList = 'php,php2,php3,php4,php5,phtml,pwml,inc,asp,aspx,ascx,jsp,cfm,cfml,cfc,pl,bat,exe,com,dll,vbs,reg,cgi,htaccess,asis'>
		<cfif listfind(blackList,assetTypeName,',')>
			<cffile action="delete" file="#upload_folder##file_name#.#cffile.serverfileext#" mode="777">
			<script type="text/javascript">
				alert("<cf_get_lang dictionary_id='32535.php,jsp,asp,cfm,cfml Formatlarında Dosya Girmeyiniz!!'>");
				history.back();
			</script>
			<cfabort>
		</cfif>		
			
		<cfset form.uploaded_file = '#file_name#.#cffile.serverfileext#'>
		<cfcatch type="Any">
			<script type="text/javascript">
				alert("<cf_get_lang dictionary_id ='57455.Dosyanız upload edilemedi ! Dosyanızı kontrol ediniz'> !");
				history.back();
			</script>
			<cfabort>
		</cfcatch>  
	</cftry>
</cfif>

<cfset subsCounterPre = createObject("component","V16.sales.cfc.counter")>
<cfset response = subsCounterPre.insert(
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
    start_date: attributes.counter_start_date,
    finish_date: attributes.counter_finish_date,
    document: attributes.document,
    uploaded_file: attributes.uploaded_file,
    counter_detail: attributes.counter_detail,
	our_comp_id: isDefined("attributes.our_company_id") and len(attributes.our_company_id) ? attributes.our_company_id : '',
    partner_id: isDefined("attributes.partner_id") and len(attributes.partner_id) and isDefined("attributes.company_name") and len(attributes.company_name) ? attributes.partner_id : '',
    company_id: isDefined("attributes.company_id") and len(attributes.company_id) and isDefined("attributes.company_name") and len(attributes.company_name) ? attributes.company_id : '',
    consumer_id: isDefined("attributes.consumer_id") and len(attributes.consumer_id) and isDefined("attributes.company_name") and len(attributes.company_name) ? attributes.consumer_id : '',
    member_type: isDefined("attributes.member_type") and len(attributes.member_type) and isDefined("attributes.company_name") and len(attributes.company_name) ? attributes.member_type : '',
	company_name: isDefined("attributes.company_name") and len(attributes.company_name) ? attributes.company_name : ''
)>

<script type="text/javascript">
	<cfif isdefined("attributes.draggable")>
		closeBoxDraggable( '<cfoutput>#attributes.modal_id#</cfoutput>', 'unique_get_counter' );
	<cfelse>
		wrk_opener_reload();
		window.close();
	</cfif>
</script>
