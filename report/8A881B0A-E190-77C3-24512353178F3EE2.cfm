<!---
    File: 
    Folder: 
	Controller: 
    Author: 
    Date: 
    Description:
        Bu rapor ile mükellefler sistemde güncellenir.
    History:
        
    To Do:

--->
<cfscript>
	get_einv_comp_tmp= createObject("component","V16.e_government.cfc.einvoice");
	get_einv_comp_tmp.dsn = dsn;
	get_einv_comp = get_einv_comp_tmp.get_our_company_fnc(einvoice_type:3, first_company:1);
</cfscript>
<cfobject name="helper" type="component" component="V16.e_government.cfc.helper">
<cfobject name="mapper" type="component" component="V16.e_government.cfc.super.einvoice.mapper">
<cfobject name="javaziphelper" type="component" component="cfc.javaziphelper">
<cfquery name="UPD_COMPANY" datasource="#DSN#">
	UPDATE COMPANY SET TAXNO = NULL WHERE TAXNO = ''
</cfquery>

<cfset temp_earchive = 0>

<cfquery name="GET_EARCHIVE_COLUMN" datasource="#DSN#">
	SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'OUR_COMPANY_INFO' AND COLUMN_NAME = 'IS_EARCHIVE'
</cfquery>
<cfif get_earchive_column.recordcount>
	<cfquery name="GET_EARCHIVE" datasource="#DSN#">
		SELECT IS_EARCHIVE FROM OUR_COMPANY_INFO WHERE IS_EARCHIVE = 1
	</cfquery>
    <cfif get_earchive.recordcount>
    	<cfset temp_earchive = 1>
    </cfif>
</cfif>

<!--- Ticket almak icin gerekli XML formati hazirlaniyor --->
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

<cfhttp url="#dp_url#AuthService.svc" method="post" result="httpResponse">
    <cfhttpparam type="header" name="content-type" value="text/xml">
    <cfhttpparam type="header" name="SOAPAction" value="Login">
    <cfhttpparam type="header" name="charset" value="utf-8">
    <cfhttpparam type="header" name="content-length" value="#len(ticket_data)#">
    <cfhttpparam type="xml" name="message" value="#trim(ticket_data)#">
</cfhttp>

<cfxml variable="xmlresult"><cfoutput>#httpResponse.Filecontent#</cfoutput></cfxml>
<cfif structKeyExists(xmlresult.Envelope.Body,'Fault')>
    <cfset Ticket = xmlresult.Envelope.Body.Fault.faultstring.XmlText>
<cfelse>
    <cfset Ticket = xmlresult.Envelope.Body.LoginResponse.accessToken.XmlText>
</cfif>

<cfif get_einv_comp.EINVOICE_TEST_SYSTEM eq 1>
    <cfset this.urlPrefix = 'https://gibuserlistsoapapitest.superentegrator.com/'>
<cfelse>
    <cfset this.urlPrefix = 'https://gibuserlistsoapapi.superentegrator.com/'>
</cfif>

<cfif not isdefined("attributes.all")>
    <cfxml variable="invoicecustomerlist_data">
        <cfoutput>
            <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:gib="http://wsdl.superentegrator.com/gibuserlist">
            <soapenv:Header>
                <gib:Authorization>#ticket#</gib:Authorization>
            </soapenv:Header>
            <soapenv:Body>
                <gib:AuthToken>#ticket#</gib:AuthToken>
                <gib:LastChangedUserListRequest>
                    <FilterStartDate>#dateFormat(dateAdd('d', -1, now()),'yyyy-mm-dd')#</FilterStartDate>
                    <UserListType>EInvoice</UserListType>
                    <AliasType>Pk</AliasType>
                </gib:LastChangedUserListRequest>
            </soapenv:Body>
            </soapenv:Envelope>
        </cfoutput>
    </cfxml>
    <cfhttp url="#this.urlPrefix#GibUserList.svc" method="post" result="requestResult">
        <cfhttpparam type="header" name="content-type" value="text/xml">
        <cfhttpparam type="header" name="SOAPAction" value="LastChangedUserList">
        <cfhttpparam type="header" name="charset" value="utf-8">
        <cfhttpparam type="header" name="content-length" value="#len(invoicecustomerlist_data)#">
        <cfhttpparam type="xml" name="message" value="#trim(invoicecustomerlist_data)#">
    </cfhttp>
    <cfxml variable="xmlresult"><cfoutput>#requestResult.Filecontent#</cfoutput></cfxml>

    <cfloop array="#xmlresult.Envelope.Body.LastChangedUserListResponse.Aliases#" index="child">
        <cfquery name = "add_einvoice_alias" datasource = "#dsn#">
            INSERT INTO 
                EINVOICE_COMPANY_IMPORT(
                    TAX_NO, 
                    ALIAS, 
                    COMPANY_FULLNAME, 
                    TYPE, 
                    REGISTER_DATE, 
                    ALIAS_CREATION_DATE
                ) 
            VALUES(
                '#child.Identifier.XmlText#',
                '#child.ALIAS.XmlText#',
                '#mid(child.Title.XmlText, 1, 250)#',
                '#child.TYPE.XmlText#',
                '#helper.webtime2date( child.FirstCreateDate.XmlText )#',
                '#helper.webtime2date( child.AliasCreateDate.XmlText )#'
            );
        </cfquery>
    </cfloop>
<cfelse>

    <cfxml variable="invoicecustomerlist_data">
        <cfoutput>
            <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:gib="http://wsdl.superentegrator.com/gibuserlist">
                <soapenv:Header>
                    <gib:Authorization>#ticket#</gib:Authorization>
                </soapenv:Header>
                <soapenv:Body>
                    <gib:UserListRequest>
                        <UserType>EInvoice</UserType>
                        <AliasType>Pk</AliasType>
                    </gib:UserListRequest>
                </soapenv:Body>
            </soapenv:Envelope>
        </cfoutput>
    </cfxml>
    <cfhttp url="#this.urlPrefix#GibUserList.svc" method="post" result="requestResult">
        <cfhttpparam type="header" name="content-type" value="text/xml">
        <cfhttpparam type="header" name="SOAPAction" value="UserList">
        <cfhttpparam type="header" name="charset" value="utf-8">
        <cfhttpparam type="header" name="content-length" value="#len(invoicecustomerlist_data)#">
        <cfhttpparam type="xml" name="message" value="#trim(invoicecustomerlist_data)#">
    </cfhttp>
    <cfxml variable="xmlresult"><cfoutput>#requestResult.Filecontent#</cfoutput></cfxml>
    <cfset resultdata.serviceresult = xmlresult.Envelope.Body.UserListResponse.UserListData.XmlText>
    
    <cffile action="write" file="/mukellef.xml" output="#toString(javaziphelper.DecompressFirstEntry(toBinary(xmlresult.Envelope.Body.UserListResponse.UserListData.XmlText)))#" charset="utf-8" />
    <cffile action="read" file = "/mukellef.xml" variable = "res" charset = "utf-8">

    <cfxml variable="xmlx"><cfoutput>#res#</cfoutput></cfxml>
    <!--- <cfquery name = "truncate_einvoice_alias_new" datasource = "#dsn#">
        TRUNCATE TABLE EINVOICE_COMPANY_IMPORT
    </cfquery> --->
    
    <cfloop array="#xmlx.UserList.XmlChildren#" index="child">
        <cfset return_map = mapper.map_einvoice_alias( child )>
       <!---  <cftry>
            <cfquery name="add_einvoice_alias" datasource="#dsn#">
                INSERT INTO 
                    EINVOICE_COMPANY_IMPORT(
                        TAX_NO, 
                        ALIAS, 
                        COMPANY_FULLNAME, 
                        TYPE, 
                        REGISTER_DATE, 
                        ALIAS_CREATION_DATE
                    ) 
                VALUES(
                    '#return_map.VKNTCKN#',
                    '#return_map.ALIAS#',
                    '#return_map.NAME#',
                    '#return_map.TYPE#',
                    '#return_map.FIRSTCREATIONTIME#',
                    '#return_map.ALIASCREATIONTIME#'
                );
            </cfquery>
    
            <cfcatch>
                <cfsavecontent variable="catch_alias">
                    <cfdump var="#cfcatch#">
                </cfsavecontent>
            </cfcatch>
        </cftry> --->
    </cfloop>
</cfif>

<!---Kurumsal uye guncelleme--->    
<cfquery name="UPD_COMP" datasource="#DSN#" result="xxx2">
    UPDATE COMPANY SET USE_EFATURA = 0,<cfif temp_earchive eq 1>USE_EARCHIVE = 1,</cfif>EFATURA_DATE = NULL
</cfquery>

<cfquery name="UPD_COMP" datasource="#DSN#" result="xxx">
    UPDATE 
        C
    SET 
        USE_EFATURA = 1,<cfif temp_earchive eq 1>USE_EARCHIVE = 0,EARCHIVE_SENDING_TYPE = NULL,</cfif> EFATURA_DATE = ECI.REGISTER_DATE
    FROM 
        COMPANY C, EINVOICE_COMPANY_IMPORT ECI
    WHERE 
        ECI.TAX_NO = C.TAXNO AND
        LEN(ECI.TAX_NO) = 10
</cfquery>

<cfquery name="UPD_COP_WITH_TC" datasource="#DSN#"><!---#77353 Vergi Numarası Olmayıp TC Numarası olan kurumsal üyeler içinde güncelleme yapılması sağlandı (Add by: MCP) --->
    IF NOT EXISTS( SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'COMPANY' AND COLUMN_NAME = 'IS_PERSON')
        BEGIN
            UPDATE 
                COMPANY
            SET 
                USE_EFATURA=1,
                <cfif temp_earchive eq 1>USE_EARCHIVE = 0,EARCHIVE_SENDING_TYPE = NULL,</cfif>
                EFATURA_DATE=ECI.REGISTER_DATE
            FROM 
                COMPANY C
                INNER JOIN COMPANY_PARTNER CP ON CP.PARTNER_ID = C.MANAGER_PARTNER_ID
                INNER JOIN EINVOICE_COMPANY_IMPORT ECI ON ECI.TAX_NO = CP.TC_IDENTITY
            WHERE
                C.TAXNO IS NULL AND
                CP.TC_IDENTITY IS NOT NULL
        END
    ELSE
        BEGIN
            UPDATE 
                COMPANY
            SET 
                USE_EFATURA=1,
                <cfif temp_earchive eq 1>USE_EARCHIVE = 0,EARCHIVE_SENDING_TYPE = NULL,</cfif>
                EFATURA_DATE=ECI.REGISTER_DATE
            FROM 
                COMPANY C
                INNER JOIN COMPANY_PARTNER CP ON CP.PARTNER_ID = C.MANAGER_PARTNER_ID
                INNER JOIN EINVOICE_COMPANY_IMPORT ECI ON ECI.TAX_NO = CP.TC_IDENTITY
            WHERE
                C.IS_PERSON = 1 AND
                CP.TC_IDENTITY IS NOT NULL
        END
</cfquery>

<!---Bireysel uye guncelleme--->    
<cfquery name="UPD_COMP" datasource="#DSN#" result="yyy2">
    UPDATE CONSUMER SET USE_EFATURA = 0,<cfif temp_earchive eq 1>USE_EARCHIVE = 1,</cfif>EFATURA_DATE = NULL
</cfquery>
        
<cfquery name="UPD_COMP" datasource="#DSN#" result="yyy">
    UPDATE 
        C
    SET 
        USE_EFATURA = 1,<cfif temp_earchive eq 1>USE_EARCHIVE = 0,</cfif> EFATURA_DATE = ECI.REGISTER_DATE
    FROM 
        CONSUMER C, EINVOICE_COMPANY_IMPORT ECI
    WHERE 
        ECI.TAX_NO = C.TC_IDENTY_NO AND
        LEN(ECI.TAX_NO) = 11
</cfquery>

<cfquery name = "del_multi_alias" datasource = "#dsn#">
    WITH CTE1 AS (
        SELECT
            EINVOICE_COMP_ID,
            TAX_NO,
            ALIAS,
            COMPANY_FULLNAME,
            TYPE,
            REGISTER_DATE,
            EINVOICE_TYPE,
            ROW_NUMBER() OVER (PARTITION BY TAX_NO, ALIAS, COMPANY_FULLNAME, TYPE, REGISTER_DATE ORDER BY EINVOICE_COMP_ID) AS ROWNUM
        FROM
            #dsn#.EINVOICE_COMPANY_IMPORT ECI
    )
    DELETE FROM #dsn#.EINVOICE_COMPANY_IMPORT WHERE EINVOICE_COMP_ID IN (
        SELECT
            EINVOICE_COMP_ID
        FROM
            CTE1
        WHERE
            ROWNUM > 1
    )
</cfquery>


<!--- dtp tarafı kapatılıyor --->

<!---
<!--- Ticket almak icin gerekli XML formati hazirlaniyor --->
<cfxml variable="ticket_data"><cfoutput>
    <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/">
    <soapenv:Header/>
    <soapenv:Body>
        <tem:GetFormsAuthenticationTicket>
            <tem:CorporateCode>#get_einv_comp.EINVOICE_COMPANY_CODE#</tem:CorporateCode>
            <tem:LoginName>#get_einv_comp.EINVOICE_USER_NAME#</tem:LoginName>
            <tem:Password><![CDATA[#get_einv_comp.EINVOICE_PASSWORD#]]></tem:Password>
        </tem:GetFormsAuthenticationTicket>
    </soapenv:Body>
    </soapenv:Envelope></cfoutput>
    </cfxml>
<cfif get_einv_comp.einvoice_test_system eq 1>
	<cfset dp_url = 'https://IntegrationServiceWithoutMtomtest.eveelektronik.com.tr/integrationservice.asmx'>
<cfelse>
	<cfset dp_url = 'https://integrationservicewithoutmtom.digitalplanet.com.tr/IntegrationService.asmx'>
</cfif>
<!--- Mükellef listesi icin gerekli tek seferlik ticket alınıyor ---> 
<cfhttp url="#dp_url#" method="post" result="httpResponse">
    <cfhttpparam type="header" name="content-type" value="text/xml">
    <cfhttpparam type="header" name="SOAPAction" value="http://tempuri.org/GetFormsAuthenticationTicket">
    <cfhttpparam type="header" name="content-length" value="#len(ticket_data)#">
    <cfhttpparam type="header" name="charset" value="utf-8">
    <cfhttpparam type="xml" name="message" value="#trim(ticket_data)#">
</cfhttp>

<cfset Ticket = xmlParse(httpResponse.filecontent)>
<cfset Ticket = Ticket.Envelope.Body.GetFormsAuthenticationTicketResponse.GetFormsAuthenticationTicketResult.XmlText>

<cfif not isdefined("attributes.all")>
	<cfset startdate = "#dateformat(dateadd('d',-1,now()),'yyyy-mm-dd')#">
<cfelse>
	<cfset startdate = "2010-01-01">
</cfif>

<cfsavecontent variable="invoice_data"><cfoutput>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/">
   <soapenv:Header/>
   <soapenv:Body>
      <tem:GetTaxIdListbyDate>
         <tem:Ticket>#Ticket#</tem:Ticket>
         <tem:StartDate>#startdate#</tem:StartDate>
      </tem:GetTaxIdListbyDate>
   </soapenv:Body>
</soapenv:Envelope>
</cfoutput>
</cfsavecontent>

<!--- Mukellef listesi alınıyor --->
<cfhttp url="#dp_url#" method="post" result="httpResponse">
    <cfhttpparam type="header" name="content-type" value="text/xml">
    <cfhttpparam type="header" name="SOAPAction" value="http://tempuri.org/GetTaxIdListbyDate">
    <cfhttpparam type="header" name="content-length" value="#len(invoice_data)#">
    <cfhttpparam type="header" name="charset" value="utf-8">
    <cfhttpparam type="xml" name="message" value="#trim(invoice_data)#">
</cfhttp>

<cftry>
	<cfset item =  xmlParse(httpResponse.Filecontent).Envelope.Body.GetTaxIdListbyDateResponse.GetTaxIdListbyDateResult.CustomerInfoList.EInvoiceCustomerResult>
    <cfset line_count = arraylen(item)>
    <cfcatch>
        <cfset line_count = 0>
    </cfcatch>
</cftry>
<cfset bugArray = arrayNew(1) />
<cfif line_count gt 0>
	<cfset upd_einvoice_company_import_array = ArrayNew(1)> 
	<cfset row_count = 500>
    
	<!---Tum Mukelleflerin Aktarımı--->	
	<cfif isdefined("attributes.all")>
        <cfquery name="TRUN_EFAT_COMP" datasource="#DSN#">
            TRUNCATE TABLE EINVOICE_COMPANY_IMPORT
        </cfquery>
    </cfif>   
    <cfloop from="1" to="#line_count#" index="xml_ind">
        <!--- <cfset upd_einvoice_company_import_array[xml_ind mod row_count+1] = "INSERT INTO EINVOICE_COMPANY_IMPORT (TAX_NO,ALIAS,COMPANY_FULLNAME,TYPE,REGISTER_DATE,ALIAS_CREATION_DATE,EINVOICE_TYPE) VALUES ('#item[xml_ind].TaxIdOrPersonalId.xmlText#','#item[xml_ind].Alias.xmlText#','#left(replace(item[xml_ind].Name.xmlText,'#chr(39)#',' ','all'),250)#','#item[xml_ind].Type.xmlText#',#CreateODBCDateTime(replace(item[xml_ind].RegisterTime.xmlText,"T"," "))#,#CreateODBCDateTime(replace(item[xml_ind].AliasCreateDate.xmlText,"T"," "))#,3)"> --->
        <cftry>
            <cfset upd_einvoice_company_import_array[xml_ind mod row_count+1] = "INSERT INTO EINVOICE_COMPANY_IMPORT (TAX_NO,ALIAS,COMPANY_FULLNAME,TYPE,REGISTER_DATE,ALIAS_CREATION_DATE) VALUES ('#item[xml_ind].TaxIdOrPersonalId.xmlText#','#item[xml_ind].Alias.xmlText#','#left(replace(item[xml_ind].Name.xmlText,'#chr(39)#',' ','all'),250)#','#item[xml_ind].Type.xmlText#',#len(item[xml_ind].RegisterTime.xmlText) ? CreateODBCDateTime(replace(item[xml_ind].RegisterTime.xmlText,"T"," ")) : now()#,#len(item[xml_ind].AliasCreateDate.xmlText) ? CreateODBCDateTime(replace(item[xml_ind].AliasCreateDate.xmlText,"T"," ")) : now()#)">
            <cfif xml_ind mod row_count eq 0>
                <cfset upd_einvoice_company_import_array = ArrayToList(upd_einvoice_company_import_array,"#chr(13)&chr(10)#")>
                <cfquery name="upd_einvoice_relation" datasource="#dsn#">
                    #PreserveSingleQuotes(upd_einvoice_company_import_array)#
                </cfquery>
                <cfset upd_einvoice_company_import_array = ArrayNew(1)> 
            </cfif> 
        <cfcatch type="any">
            <cfset ArrayPush(bugArray, '#replace(item[xml_ind].Name.xmlText,'#chr(39)#',' ','all')#')   />
        </cfcatch>
        </cftry>
    </cfloop>
    
	<cfif ArrayLen(upd_einvoice_company_import_array)>
        <cfset upd_einvoice_company_import_array = ArrayToList(upd_einvoice_company_import_array,"#chr(13)&chr(10)#")><!---  SQL cumlesi liste olarak olustu --->
        <cfquery name="upd_einvoice_company" datasource="#dsn#">
            #PreserveSingleQuotes(upd_einvoice_company_import_array)#
        </cfquery>
     </cfif>         
   
   <!---Kurumsal uye guncelleme--->    
	<cfquery name="UPD_COMP" datasource="#DSN#" result="xxx2">
        UPDATE COMPANY SET USE_EFATURA = 0,<cfif temp_earchive eq 1>USE_EARCHIVE = 1,</cfif>EFATURA_DATE = NULL
    </cfquery>
    
    <cfquery name="UPD_COMP" datasource="#DSN#" result="xxx">
        UPDATE 
            C
        SET 
            USE_EFATURA = 1,<cfif temp_earchive eq 1>USE_EARCHIVE = 0,EARCHIVE_SENDING_TYPE = NULL,</cfif> EFATURA_DATE = ECI.REGISTER_DATE
        FROM 
            COMPANY C, EINVOICE_COMPANY_IMPORT ECI
        WHERE 
            ECI.TAX_NO = C.TAXNO AND
            LEN(ECI.TAX_NO) = 10
    </cfquery>
    
    <cfquery name="UPD_COP_WITH_TC" datasource="#DSN#"><!---#77353 Vergi Numarası Olmayıp TC Numarası olan kurumsal üyeler içinde güncelleme yapılması sağlandı (Add by: MCP) --->
        IF NOT EXISTS( SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'COMPANY' AND COLUMN_NAME = 'IS_PERSON')
			BEGIN
                UPDATE 
                    COMPANY
                SET 
                    USE_EFATURA=1,
                    <cfif temp_earchive eq 1>USE_EARCHIVE = 0,EARCHIVE_SENDING_TYPE = NULL,</cfif>
                    EFATURA_DATE=ECI.REGISTER_DATE
                FROM 
                    COMPANY C
                    INNER JOIN COMPANY_PARTNER CP ON CP.PARTNER_ID = C.MANAGER_PARTNER_ID
                    INNER JOIN EINVOICE_COMPANY_IMPORT ECI ON ECI.TAX_NO = CP.TC_IDENTITY
                WHERE
                    C.TAXNO IS NULL AND
                    CP.TC_IDENTITY IS NOT NULL
            END
       ELSE
       		BEGIN
                UPDATE 
                    COMPANY
                SET 
                    USE_EFATURA=1,
                    <cfif temp_earchive eq 1>USE_EARCHIVE = 0,EARCHIVE_SENDING_TYPE = NULL,</cfif>
                    EFATURA_DATE=ECI.REGISTER_DATE
                FROM 
                    COMPANY C
                    INNER JOIN COMPANY_PARTNER CP ON CP.PARTNER_ID = C.MANAGER_PARTNER_ID
                    INNER JOIN EINVOICE_COMPANY_IMPORT ECI ON ECI.TAX_NO = CP.TC_IDENTITY
                WHERE
                    C.IS_PERSON = 1 AND
                    CP.TC_IDENTITY IS NOT NULL
            END
	</cfquery>
    
    <!---Bireysel uye guncelleme--->    
        
	<cfquery name="UPD_COMP" datasource="#DSN#" result="yyy2">
        UPDATE CONSUMER SET USE_EFATURA = 0,<cfif temp_earchive eq 1>USE_EARCHIVE = 1,</cfif>EFATURA_DATE = NULL
    </cfquery>
            
    <cfquery name="UPD_COMP" datasource="#DSN#" result="yyy">
        UPDATE 
            C
        SET 
            USE_EFATURA = 1,<cfif temp_earchive eq 1>USE_EARCHIVE = 0,</cfif> EFATURA_DATE = ECI.REGISTER_DATE
        FROM 
            CONSUMER C, EINVOICE_COMPANY_IMPORT ECI
        WHERE 

            ECI.TAX_NO = C.TC_IDENTY_NO AND
            LEN(ECI.TAX_NO) = 11
	</cfquery>
	Rapor <cfif isdefined("attributes.all")>Tüm Mükellef <cfelse>Günlük Yeni Mükellef </cfif> listesini alacak şekilde çalıştırıldı. Toplam Kayıt Sayısı :  <cfoutput>#line_count#</cfoutput>
<cfelse>
	<cfoutput>#startdate#</cfoutput> tarihinden sonra e-Fatura sistemine kayıt olan üye bulunamadı.
</cfif>

<cfif isDefined("bugArray") and arrayLen(bugArray)>
    <cfdump var = "#bugArray#">
</cfif>

--->