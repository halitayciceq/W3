
<cfscript>
	get_einv_comp_tmp= createObject("component","V16.e_government.cfc.einvoice");
	get_einv_comp_tmp.dsn = dsn;
	get_einv_comp = get_einv_comp_tmp.get_our_company_fnc(einvoice_type:5);
</cfscript>
<cfloop query="GET_EINV_COMP">
	<cfquery name="GET_ADMIN" datasource="#DSN#">
        SELECT ADMIN_MAIL,COMPANY_NAME FROM OUR_COMPANY WHERE ADMIN_MAIL IS NOT NULL AND COMP_ID = #get_einv_comp.comp_id#
    </cfquery>
    <cfquery name="get_process_row" datasource="#dsn#">
        SELECT 
            PTR.PROCESS_ROW_ID 
        FROM 
            PROCESS_TYPE PT, 
            PROCESS_TYPE_ROWS PTR,
            PROCESS_TYPE_OUR_COMPANY PTO
        WHERE 
            PT.PROCESS_ID = PTO.PROCESS_ID AND
            PT.PROCESS_ID = PTR.PROCESS_ID AND
            PTO.OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_einv_comp.comp_id#">  AND
            PT.FACTION LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%objects.popup_dsp_efatura_detail%"> AND 
            PTR.LINE_NUMBER = 1
    </cfquery>   
    
    <cfif get_process_row.recordcount eq 0>
		<br /><cfoutput>(#get_admin.company_name#)</cfoutput> Şirketinde Gelen E-Fatura Süreçlerini Kontrol Ediniz. <cfabort>
    </cfif>

	<cfxml variable="ticket_data">
		<cfoutput>
			<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:auth="http://wsdl.superentegrator.com/auth">
				<soapenv:Header/>
				<soapenv:Body>
					<auth:loginRequest>
						<CustomerIdentity>#get_einv_comp.tax_no#</CustomerIdentity>
						<EMail>#get_einv_comp.EINVOICE_USER_NAME#</EMail>
						<Password>#HTMLEditFormat(get_einv_comp.EINVOICE_PASSWORD)#</Password>
					</auth:loginRequest>
				</soapenv:Body>
			</soapenv:Envelope>
		</cfoutput>
	</cfxml>
	<cfif get_einv_comp.einvoice_test_system eq 1>
        <cfset dp_url = 'https://authsoapapitest.superentegrator.com/'>
    <cfelse>
        <cfset dp_url = 'https://authsoapapi.superentegrator.com/'>
    </cfif>

	<cfhttp url="#dp_url#AuthService.svc" method="post" result="httpResponse" charset="utf-8">
		<cfhttpparam type="header" name="SOAPAction" value="Login">
		<cfhttpparam type="header" name="content-length" value="#len(ticket_data)#">
		<cfhttpparam type="xml" name="message" value="#trim(ticket_data)#">
	</cfhttp>
	<cfxml variable="xmlresult"><cfoutput>#httpResponse.Filecontent#</cfoutput></cfxml>
	<cfif structKeyExists(xmlresult.Envelope.Body,'Fault')>
		<cfset Ticket = xmlresult.Envelope.Body.Fault.faultstring.XmlText>
	<cfelse>
		<cfset Ticket = xmlresult.Envelope.Body.LoginResponse.accessToken.XmlText>
	</cfif>

	<cfxml variable="availableinvoices_data">
		<cfoutput>
			<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ein="http://wsdl.superentegrator.com/einvoice">
				<soapenv:Header>
					<ein:Authorization>#ticket#</ein:Authorization>
				</soapenv:Header>
				<soapenv:Body>
					<ein:GetInvoiceListRequest>
						<FilterDateType>DocumentDate</FilterDateType>
						<StartDate>#dateFormat(dateAdd('d',-30,now()),'yyyy-mm-dd')#</StartDate>
						<EndDate>#dateFormat(dateAdd('d',1,now()),'yyyy-mm-dd')#</EndDate>
						<DocumentDirection>Incoming</DocumentDirection>
					</ein:GetInvoiceListRequest>
				</soapenv:Body>
			</soapenv:Envelope>
		</cfoutput>
	</cfxml>

	<cfif get_einv_comp.EINVOICE_TEST_SYSTEM eq 1>
		<cfset dp_url = 'https://einvoicesoapapitest.superentegrator.com/'>
	<cfelse>
		<cfset dp_url = 'https://einvoicesoapapi.superentegrator.com/'>
	</cfif>

	<cfhttp url="#dp_url#EInvoice.svc" method="post" result="httpResponse" charset="utf-8">
		<cfhttpparam type="header" name="SOAPAction" value="GetInvoiceList">
		<cfhttpparam type="header" name="content-length" value="#len(availableinvoices_data)#">
		<cfhttpparam type="xml" name="message" value="#trim(availableinvoices_data)#">
	</cfhttp>

	<cfxml variable="xmlresult"><cfoutput>#httpResponse.Filecontent#</cfoutput></cfxml>
	<cfset directory_name = "#upload_folder#einvoice_received/#get_einv_comp.comp_id#/#year(now())#/#numberformat(month(now()),00)#">
	<cfif structKeyExists(xmlresult.Envelope.Body.GetInvoiceListResponse,'InvoiceList')>
		<cfloop array="#xmlresult.Envelope.Body.GetInvoiceListResponse.InvoiceList#" index="invoice">
			<cftry>
				<cfif len(invoice.DocumentId.xmlText)>
					<cfif not DirectoryExists(directory_name)>
						<cfdirectory action="create" directory="#directory_name#">
					</cfif>
					<cfquery name = "getPeriod" datasource = "#dsn#">
						SELECT * FROM SETUP_PERIOD WHERE OUR_COMPANY_ID = #get_einv_comp.comp_id# AND '#listFirst(invoice.issuetime.xmltext,'T')#' BETWEEN START_DATE AND FINISH_DATE
					</cfquery>
					<cfset dsn2 = '#dsn#_#getPeriod.period_year#_#get_einv_comp.comp_id#'>
					<!--- <cfset ubl_format = soap.getInvoicePDF(uuid: invoice.uuid, outputType: 'Ubl', direction: 'Incoming', ticket_req : 0)> --->

					<cfxml variable="check_data">
						<cfoutput>
							<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ein="http://wsdl.superentegrator.com/einvoice">
								<soapenv:Header>
									<ein:Authorization>#ticket#</ein:Authorization>
								</soapenv:Header>
								<soapenv:Body>          
									<ein:GetInvoiceRequest>
										<OutputType>Ubl</OutputType>
										<UUIDType>DocumentUUID</UUIDType>
										<UUID>#invoice.InvoiceUUID.xmltext#</UUID>
										<DocumentDirection>Incoming</DocumentDirection>
										<IncludeInvoiceBinaryData>true</IncludeInvoiceBinaryData>
										<CompressedBinaryData>false</CompressedBinaryData>
										<SetErpStatus>New</SetErpStatus>
									</ein:GetInvoiceRequest>
								</soapenv:Body>
							</soapenv:Envelope>
						</cfoutput>
					</cfxml>

					<cfquery name="INVOICE_CONTROL" datasource="#DSN2#">
						SELECT 1 FROM EINVOICE_RECEIVING_DETAIL WHERE UUID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#invoice.InvoiceUUID.xmltext#">
					</cfquery>

					<!--- IS_APPROVE alanı fatura Kaydet butonunun gelmesi icin düzenlendi--->
					<cfif not invoice_control.recordcount>

						<cfhttp url="#dp_url#EInvoice.svc" method="post" result="httpResponse" charset="utf-8">
							<cfhttpparam type="header" name="SOAPAction" value="GetInvoice">
							<cfhttpparam type="header" name="content-length" value="#len(check_data)#">
							<cfhttpparam type="xml" name="message" value="#trim(check_data)#">
						</cfhttp>
						<cfxml variable="xmlresult"><cfoutput>#httpResponse.Filecontent#</cfoutput></cfxml>
	
						<cffile action="write" file="#directory_name#/#invoice.InvoiceUUID.xmltext#.xml" output="#toString(tobinary(xmlresult.Envelope.Body.GetInvoiceResponse.OutputDatas.XmlText))#" charset="utf-8" />


						<cfscript>
							add_invoice_receive_temp = CreateObject("component","V16.e_government.cfc.einvoice");
							add_invoice_receive_temp.dsn2 = dsn2;
							if(get_einv_comp.is_receiving_process eq 1) is_approve = 0; else is_approve = 1;
							add_invoice_receive_temp.add_received_invoices(service_result:'Successful',
																			uuid:invoice.InvoiceUUID.xmltext,
																			einvoice_id:invoice.DocumentId.xmltext,
																			status_description:invoice.Status.xmltext,
																			status_code:invoice.StatusEnumValue.xmltext,
																			error_code:0,
																			invoice_type_code:invoice.DocumentType.xmltext,
																			sender_tax_id:invoice.SupplierId.xmltext,
																			receiver_tax_id:invoice.CustomerId.xmltext,
																			profile_id:invoice.profileid.xmltext,
																			payable_amount:invoice.PayableAmount.xmltext,
																			payable_amount_currency:invoice.DocumentCurrencyCode.xmltext,
																			issue_date:listFirst(invoice.IssueDate.xmltext,'T'),
																			party_name:invoice.SupplierTitle.xmltext,
																			process_stage:get_process_row.process_row_id,
																			einvoice_type:5,
																			is_approve:is_approve,
																			company_id:get_einv_comp.comp_id);
							</cfscript>
					</cfif>
				</cfif>
				<cfcatch>
					<cfdump var="#cfcatch#">
					<cfdump var="#invoice#">
					<cfabort>
				</cfcatch>
			</cftry>
		</cfloop>
		<cfoutput>(#get_admin.company_name#)</cfoutput> gelen e-fatura raporu başarılı bir şekilde çalıştırıldı.<br />
	<cfelse>
		<cfoutput>(#get_admin.company_name#)</cfoutput> Şirketinde Fatura bulunamadı.<br />
	</cfif>
</cfloop>