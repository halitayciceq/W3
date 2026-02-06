<cfif isDefined("attributes.uploaded_file") and len(attributes.uploaded_file)>

		<cfset upload_folder = "#upload_folder##dir_seperator#sales#dir_seperator#payment_plan_import#dir_seperator#">
		<cffile action="UPLOAD" filefield="uploaded_file" destination="#upload_folder#" mode="777" nameconflict="MAKEUNIQUE">

		<cfset file_name = createUUID()>
		<cffile action="rename" source="#upload_folder##cffile.serverfile#" destination="#upload_folder##file_name#.#cffile.serverfileext#" mode="777">
		
		<cfset assetTypeName = listlast(cffile.serverfile,'.')>
		<cfset blackList = 'php,php2,php3,php4,php5,phtml,pwml,inc,asp,aspx,ascx,jsp,cfm,cfml,cfc,pl,bat,exe,com,dll,vbs,reg,cgi,htaccess,asis'>
		<cfif listfind(blackList,assetTypeName,',')>
			<cffile action="delete" file="#upload_folder##file_name#.#cffile.serverfileext#" filefield="xlsfile" mode="777">
			<script type="text/javascript">
				alert("<cf_get_lang dictionary_id='32535.\php\,\jsp\,\asp\,\cfm\,\cfml\ Formatlarında Dosya Girmeyiniz'>!!");
				history.back();
			</script>
			<cfabort>
		</cfif>		
			
		<cfset attributes.uploaded_file = '#file_name#.#cffile.serverfileext#'>
		<cftry>
		<cfcatch type="Any">
			<script type="text/javascript">
				alert("<cf_get_lang_main no ='43.Dosyanız upload edilemedi ! Dosyanızı kontrol ediniz'> !");
				history.back();
			</script>
			<cfabort>
		</cfcatch>  
	</cftry>
</cfif>

<cfscript>
	attributes.actionid =0;
	comp = createObject("component","V16.sales.cfc.subscription_payment_plan_import");
	result = comp.main(
		IMPORT_TYPE_ID: attributes.import_type_id,
		IMPORT_NAME: attributes.IMPORT_NAME,
		FILE_PATH:upload_folder,
		FILE: attributes.uploaded_file,
		DESCRIPTION: attributes.description,
		ROW_DESCRIPTION:attributes.row_description,
		CONVERT_SUBSCRIPTION_PAYMENT_PLAN: 0,
		PROCESS_STAGE: attributes.process_stage,
		PAYMENT_DATE:attributes.payment_date,
		START_DATE:attributes.start_date,
		FINISH_DATE: attributes.finish_date,
		ACTION_EMP: session.ep.userid
	);

	if(result.actionResult){
		attributes.actionid = result.actionid;
	}else{
		writeoutput('<script type="text/javascript">alert("Hata Oluştu Lütfen Tekrar Deneyiniz!");history.back();</script>');
	}
</cfscript>

<!--- hata oldu ise post ile hata datasını gönder ekranı bas--->
<cfif result.actionResult>
	<cf_workcube_process 
		is_upd='1'
		data_source='#dsn3#'
		old_process_line='0'
		process_stage='#attributes.process_stage#' 
		record_member='#session.ep.userid#' 
		record_date='#now()#'
		action_table='SUBSCRIPTION_PAYMENT_PLAN_IMPORT'
		action_column='SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID'
		action_id='#result.actionid#'
		action_page='#request.self#?fuseaction=sales.list_subscription_payment_plan_import&event=upd&import_id=#result.actionid#'
		warning_description = '#getLang("","Abonelik Ödeme Planı Aktarım",66818)# : #attributes.IMPORT_NAME#'>
<!--- <script type="text/javascript">
	window.location.href="<cfoutput>#request.self#?fuseaction=sales.list_subscription_payment_plan_import&event=upd&import_id=#attributes.import_id#</cfoutput>";
</script>
 --->
</cfif>
