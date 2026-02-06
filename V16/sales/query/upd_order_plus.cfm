<cf_get_lang_set module_name="sales">
<cfif len(PLUS_DATE)>
	<CF_DATE TARIH="PLUS_DATE">
</cfif>
<cfquery name="UPD_ORDER_PLUS" datasource="#dsn3#">
	UPDATE
		ORDER_PLUS
	SET
	<cfif isDefined("opp_head")>
	PLUS_SUBJECT = '#opp_head#',
	</cfif>
	<cfif isDefined("attributes.email") and (attributes.email EQ "true")>
	MAIL_SENDER = '#attributes.employee#',
	</cfif>	
	<cfif COMMETHOD_ID neq 0>
		COMMETHOD_ID = #COMMETHOD_ID#,
	<cfelse>
		COMMETHOD_ID = NULL,
	</cfif>
	<cfif len(PLUS_DATE)>
		PLUS_DATE = #PLUS_DATE#,
	<cfelse>
		PLUS_DATE = NULL,
	</cfif>
		PLUS_CONTENT = '#PLUS_CONTENT#',
	<cfif len(EMPLOYEE_ID) and len(EMPLOYEE)>
		EMPLOYEE_ID = #EMPLOYEE_ID#,
	<cfelse>
		EMPLOYEE_ID = NULL,
	</cfif>
		UPDATE_DATE = #now()#,
		UPDATE_EMP = #SESSION.EP.USERID#,
		UPDATE_IP = '#CGI.REMOTE_ADDR#'
	WHERE
		ORDER_PLUS_ID = #ORDER_PLUS_ID#
</cfquery>

<cfif isDefined("attributes.email") and (attributes.email EQ "true")>

	<cfquery name="GET_MAILFROM" datasource="#dsn#">
		select
            <cfif listfindnocase(employee_url,'#cgi.http_host#',';')>EMPLOYEE_NAME NAME_,EMPLOYEE_SURNAME SURNAME_,EMPLOYEE_EMAIL EMAIL_<cfelseif listfindnocase(partner_url,'#cgi.http_host#',';')>COMPANY_PARTNER_NAME NAME_,COMPANY_PARTNER_SURNAME NAME_,COMPANY_PARTNER_EMAIL EMAIL_</cfif>
		from		
			<cfif listfindnocase(employee_url,'#cgi.http_host#',';')>EMPLOYEE_POSITIONS<cfelseif listfindnocase(partner_url,'#cgi.http_host#',';')>COMPANY_PARTNER</cfif>		
		where
			<cfif listfindnocase(employee_url,'#cgi.http_host#',';')>EMPLOYEE_ID=#session.ep.USERID#
			<cfelseif listfindnocase(partner_url,'#cgi.http_host#',';')>PARTNER_ID=#session.pp.USERID#</cfif>
	</cfquery>
	<cfif GET_MAILFROM.RECORDCOUNT>
		<cfset sender = "#GET_MAILFROM.NAME_# #GET_MAILFROM.SURNAME_#<#GET_MAILFROM.EMAIL_#>">
	</cfif>

	<cftry>
	
	  <cfmail  
		  to = "#attributes.employee#"
		  from = "#sender#"
		  subject = "#attributes.opp_head#" type="HTML">
			  
			<style type="text/css">
				.color-header{background-color: ##a7caed;}
				.color-border	{background-color:##6699cc;}
				.color-row{	background-color: ##f1f0ff;}
				.label {font-size:11px;font-family:Geneva, tahoma, arial,  Helvetica, sans-serif;color : ##333333;padding-left: 4px;}
			</style>		  
			  
			#attributes.plus_content#
		 
	  </cfmail>
	  
	  <cfsavecontent variable="css">
		<style type="text/css">
			.color-header{background-color: ##a7caed;}
			.color-border	{background-color:##6699cc;}
			.color-row{	background-color: ##f1f0ff;}
			.label {font-size:11px;font-family:Geneva, tahoma, arial,  Helvetica, sans-serif;color : ##333333;padding-left: 4px;}
		</style>
	  </cfsavecontent>	
      <cfset attributes.from = sender>  
	  <cfset attributes.body="#css##attributes.plus_content#">
	  <cfset attributes.to_list="#attributes.employee#">
	  <cfset attributes.type=0>
	  <cfset attributes.module="sales">
	  <cfset attributes.subject="#attributes.opp_head#">
	  <cfinclude template="../../objects/query/add_mail.cfm">

		<style type="text/css">
			.color-header{background-color: ##a7caed;}
			.color-border	{background-color:##6699cc;}
			.color-row{	background-color: ##f1f0ff;}
			.headbold {  font-family:  Geneva, Verdana, Arial, sans-serif; font-size: 14px; font-weight: bold; padding-right: 2px; padding-left: 2px}
		</style>	  	  	   
		<table height="100%" width="100%" cellspacing="0" cellpadding="0">
			<tr class="color-border">
				<td valign="top"> 
					<table height="100%" width="100%" cellspacing="1" cellpadding="2">
						<tr class="color-list">
							<td height="35" class="headbold">&nbsp;&nbsp;<cf_get_lang_main no='100.Workcube E-Mail'></td>
						</tr>
						<tr class="color-row">
							<td align="center" class="headbold"><cf_get_lang_main no='101.Mail Başarıyla Gönderildi'></td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
	
	<cfcatch type="any">
	<style type="text/css">
		.color-header{background-color: ##a7caed;}
		.color-border	{background-color:##6699cc;}
		.color-row{	background-color: ##f1f0ff;}
		.headbold {  font-family:  Geneva, Verdana, Arial, sans-serif; font-size: 14px; font-weight: bold; padding-right: 2px; padding-left: 2px}
	</style>	
	<table height="100%" width="100%" cellspacing="0" cellpadding="0">
		<tr class="color-border">
			<td valign="top"> 
				<table height="100%" width="100%" cellspacing="1" cellpadding="2">
					<tr class="color-list">
						<td height="35" class="headbold">&nbsp;&nbsp;<cf_get_lang_main no='100.Workcube E-Mail'></td>
					</tr>
					<tr class="color-row">
						<td align="center" class="headbold">
					<cf_get_lang no='31.Sipariş Kaydedildi Fakat Mail Göndermede Bir Hata Oldu Lütfen Verileri Kontrol Edip Sonra Tekrar Deneyiniz'></td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
	</cfcatch>
	</cftry>
	<script type="text/javascript">
		wrk_opener_reload();
		function waitfor(){
		  window.close();
		}
		setTimeout("waitfor()",5000); 		
	</script>
	<cfabort>
</cfif>

<script type="text/javascript">
	wrk_opener_reload();
	window.close();
</script>
<cf_get_lang_set module_name="#lcase(listgetat(attributes.fuseaction,1,'.'))#">
