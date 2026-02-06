<cfcomponent displayname="Board"  hint="Proje component">
    <cfset dsn = dsn_alias = application.systemParam.systemParam().dsn/>
    <cfset WFunctions = createObject("component","WMO.functions") />
    <cfset getlang = WFunctions.getlang>

    <cfif isDefined('session.pp.userid')>
        <cfset userid = "#session.pp.userid#">
        <cfset our_company_id = "#session.pp.our_company_id#">
        <cfset period_id = session.pp.period_id>
     <cfelseif isDefined('session.ep.userid') and isdefined("session.ep.company_id")> 
        <cfset userid = "#session.ep.userid#">
        <cfset period_id = session.ep.period_id>
        <cfset our_company_id = "#session.ep.company_id#">
     <cfelseif isDefined('session.ww.userid')>    
        <cfset userid = "#session.ep.userid#">
        <cfset period_id = session.ww.period_id>
        <cfset our_company_id = "#session.ww.our_company_id#"> 
     </cfif>
    <cffunction name="GET_CAT" access="remote" returntype="query">
        <cfargument name="keyword" default="process_cat">
        <cfquery name="GET_CAT" datasource="#dsn#">
            SELECT MAIN_PROCESS_CAT FROM SETUP_MAIN_PROCESS_CAT WHERE MAIN_PROCESS_CAT_ID = #arguments.process_cat#
        </cfquery>
        <cfreturn GET_CAT>
    </cffunction> 
    <cffunction name="GET_PROCESS" access="remote" returntype="query">
        <cfquery name="GET_PROCESS" datasource="#DSN#">
            SELECT STAGE FROM PROCESS_TYPE,PROCESS_TYPE_ROWS WHERE PROCESS_TYPE_ROWS.PROCESS_ID = PROCESS_TYPE.PROCESS_ID AND PROCESS_TYPE_ROWS.PROCESS_ROW_ID = <cf_workcube_queryparam cfsqltype="cf_sql_varchar" value="#arguments.pro_currency_id#"> 
        </cfquery>
        <cfreturn GET_PROCESS>
    </cffunction> 
    <cffunction name="EMPLOYEE_PHOTO" access="remote" returntype="query"><!----sonradan email ve telefon numarası eklendiği için numara ve email bu queryden çekildi.----->
        <cfargument name="employee_id" default="">
        <cfquery name="EMPLOYEE_PHOTO" datasource="#DSN#">
            SELECT 
                E.PHOTO,
                E2.SEX,
                EP.POSITION_NAME AS POSITION,
                E.EMPLOYEE_EMAIL,
                E.MOBILCODE,
                E.MOBILTEL,
                E2.MOBILCODE_SPC,
                E2.MOBILTEL_SPC,
                EI.TC_IDENTY_NO
            FROM 
                EMPLOYEES AS E 
                LEFT JOIN EMPLOYEES_DETAIL AS E2 ON E2.EMPLOYEE_ID = E.EMPLOYEE_ID
                LEFT JOIN EMPLOYEE_POSITIONS AS EP ON E.EMPLOYEE_ID = EP.EMPLOYEE_ID
                LEFT JOIN EMPLOYEES_IDENTY EI ON EI.EMPLOYEE_ID = E.EMPLOYEE_ID
            WHERE E.EMPLOYEE_ID = #arguments.employee_id#
        </cfquery>
        <cfreturn EMPLOYEE_PHOTO>
    </cffunction>
    <cffunction name="PARTNER_PHOTO" access="remote" returntype="query">
        <cfargument name="partner_id" default="">
        <cfquery name="PARTNER_PHOTO" datasource="#DSN#">
            SELECT 
                CP.PHOTO,
                CP.SEX,
                CP.MOBIL_CODE,
                CP.MOBILTEL,
                CP.COMPANY_PARTNER_EMAIL,
                CP.COMPANY_PARTNER_TELCODE,
                CP.COMPANY_PARTNER_TEL,
                CP.TC_IDENTITY
            FROM 
                COMPANY_PARTNER CP
            WHERE CP.PARTNER_ID = #arguments.partner_id#
        </cfquery>
        <cfreturn PARTNER_PHOTO>
    </cffunction>
    <cffunction name="EMPAPP_PHOTO" access="remote" returntype="query">
        <cfargument name="emppap_id" default="">
        <cfquery name="EMPAPP_PHOTO" datasource="#DSN#">
            SELECT 
                EP.PHOTO,
                EP.SEX
            FROM 
            EMPLOYEES_APP EP
            WHERE EP.EMPAPP_ID = #arguments.emppap_id#
        </cfquery>
        <cfreturn EMPAPP_PHOTO>
    </cffunction>
    <cffunction name="CONSUMER_PHOTO" access="remote" returntype="query">
        <cfargument name="consumer_id" default="">
        <cfquery name="CONSUMER_PHOTO" datasource="#DSN#">
            SELECT 
                C.PICTURE,
                C.SEX,
                C.CONSUMER_EMAIL,
                C.CONSUMER_WORKTELCODE,
                C.CONSUMER_WORKTEL,
                C.MOBIL_CODE,
                C.MOBILTEL,
                C.TC_IDENTY_NO
            FROM 
                CONSUMER C
            WHERE C.CONSUMER_ID = #arguments.consumer_id#
        </cfquery>
        <cfreturn CONSUMER_PHOTO>
    </cffunction>
    <cffunction name="GET_CONSUMER" access="remote" returntype="query">
        <cfargument name="consumer_id" default="">
        <cfquery name="GET_CONSUMER" datasource="#DSN#">
            SELECT 
                C.CONSUMER_ID,
                C.CONSUMER_NAME,
                C.CONSUMER_SURNAME
            FROM 
                CONSUMER C
            WHERE C.CONSUMER_ID = <cf_workcube_queryparam cfsqltype="cf_sql_integer" value="#arguments.consumer_id#">
        </cfquery>
        <cfreturn GET_CONSUMER>
    </cffunction>
    <cffunction name="GET_EMP_NAME" access="remote" returntype="query">
        <cfargument name="employee_id" default="">
        <cfquery NAME="GET_EMP_NAME" DATASOURCE="#DSN#">
            SELECT
                EMPLOYEE_NAME,
                EMPLOYEE_SURNAME
            FROM
                EMPLOYEES
            WHERE
                EMPLOYEE_ID = <cf_workcube_queryparam cfsqltype="cf_sql_integer" value="#arguments.EMPLOYEE_ID#">
        </cfquery>
        <cfreturn GET_EMP_NAME>
    </cffunction>
    <cffunction name="GET_PROJECT_WORKGROUP" access="remote" returntype="query">
        <cfargument name="project_id" default="">        
        <cfquery name="GET_PROJECT_WORKGROUP" datasource="#dsn#" maxrows="1">
            SELECT * FROM WORK_GROUP WHERE PROJECT_ID = #arguments.project_id#
        </cfquery>
        <cfreturn GET_PROJECT_WORKGROUP>        
    </cffunction>
    <cffunction name="GET_MONEY" access="remote" returntype="query">
        <cfquery name="GET_MONEY" datasource="#DSN#">
            SELECT
                MONEY
            FROM
                SETUP_MONEY
            WHERE
                PERIOD_ID = <cf_workcube_queryparam cfsqltype="cf_sql_integer" value="#period_id#"> AND
                MONEY_STATUS = 1
            ORDER BY
                MONEY DESC
        </cfquery>
        <cfreturn GET_MONEY>        
    </cffunction>
    <cffunction name="GET_ACTION_WORKGROUP" access="remote" returntype="query">
        <cfargument name="action_field" default="">
        <cfargument name="action_id" default="">
        <cfquery name="GET_ACTION_WORKGROUP" datasource="#dsn#" maxrows="1">
            SELECT * FROM WORK_GROUP WHERE ACTION_FIELD = <cf_workcube_queryparam cfsqltype="cf_sql_nvarchar" value="#arguments.action_field#"> AND ACTION_ID = <cf_workcube_queryparam cfsqltype="cf_sql_integer" value="#arguments.action_id#">
        </cfquery>
        <cfreturn GET_ACTION_WORKGROUP>
    </cffunction>
    <cffunction name="GET_PROJECT_HEAD" access="remote" returntype="query">
        <cfargument name="project_id" default="">   
        <cfquery name="GET_PROJECT_HEAD" datasource="#dsn#" maxrows="1">
            SELECT PROJECT_HEAD FROM PRO_PROJECTS WHERE PROJECT_ID = <cf_workcube_queryparam cfsqltype="cf_sql_integer" value="#arguments.project_id#">
        </cfquery>
        <cfreturn GET_PROJECT_HEAD>                
    </cffunction>
    <cffunction name="GET_PROJECT_FOLDER" access="remote" returntype="query">
        <cfargument name="project_id" default="">   
        <cfquery name="GET_PROJECT_FOLDER" datasource="#dsn#" maxrows="1">
            SELECT PROJECT_FOLDER FROM PRO_PROJECTS WHERE PROJECT_ID = <cf_workcube_queryparam cfsqltype="cf_sql_integer" value="#arguments.project_id#">
        </cfquery>
        <cfreturn GET_PROJECT_FOLDER>                
    </cffunction>
    <cffunction name="GET_GOOGLE_PROJECT_FOLDER_ID" access="remote" returntype="query">
        <cfargument name="project_id" default="">   
        <cfquery name="GET_GOOGLE_PROJECT_FOLDER_ID" datasource="#dsn#" maxrows="1">
            SELECT GOOGLE_PROJECT_FOLDER_ID FROM PRO_PROJECTS WHERE PROJECT_ID = <cf_workcube_queryparam cfsqltype="cf_sql_integer" value="#arguments.project_id#">
        </cfquery>
        <cfreturn GET_GOOGLE_PROJECT_FOLDER_ID>                
    </cffunction>
    <cffunction name="GET_EMPS" access="remote" returntype="query">   
        <cfargument name="WORKGROUP_ID" default="">    
        <cfquery name="GET_EMPS" datasource="#dsn#">
            SELECT * FROM WORKGROUP_EMP_PAR WHERE WORKGROUP_ID = <cf_workcube_queryparam cfsqltype="cf_sql_integer" value="#arguments.WORKGROUP_ID#"> AND OUR_COMPANY_ID = <cf_workcube_queryparam cfsqltype="cf_sql_integer" value="#our_company_id#"> ORDER BY HIERARCHY
        </cfquery>
        <cfreturn GET_EMPS>                
    </cffunction>
    <cffunction name="GET_COMPANY_PARTNER" access="remote" returntype="query">    
        <cfargument name="PARTNER_ID" default="">           
        <cfquery name="GET_COMPANY_PARTNER" datasource="#dsn#">
            SELECT 
                COMPANY_PARTNER.PARTNER_ID,
                COMPANY_PARTNER_NAME,
                COMPANY_PARTNER_SURNAME,
                NICKNAME,
                COMPANY.COMPANY_ID
            FROM
                COMPANY,
                COMPANY_PARTNER
            WHERE
                COMPANY.COMPANY_ID = COMPANY_PARTNER.COMPANY_ID AND
                COMPANY_PARTNER.PARTNER_ID = #arguments.PARTNER_ID#
        </cfquery>
        <cfreturn GET_COMPANY_PARTNER>                        
    </cffunction>  
    <cffunction name="GET_ROLES" access="remote" returntype="query">
        <cfargument name="PROJECT_ROLES_ID" default="">                         
        <cfquery name="GET_ROLES" datasource="#dsn#">
            SELECT * FROM SETUP_PROJECT_ROLES 
                <cfif len(arguments.PROJECT_ROLES_ID)>
                    WHERE PROJECT_ROLES_ID = #arguments.PROJECT_ROLES_ID#
                </cfif>
        </cfquery>
        <cfreturn GET_ROLES>                                
    </cffunction>       
    <cffunction name= "GET_EMP_DEL_BUTTONS" access="remote" returntype="any">
        <cfargument name="module_name" default="">                                               
        <cfargument name="position_id" default="">                         
        <cfargument name="user_id" default="">    
        <cfargument name="object_name" default="">                          
        <cfquery name="GET_EMP_DEL_BUTTONS" datasource="#DSN#">
            SELECT
                ED.DENIED_PAGE,
                ED.IS_DELETE
            FROM
                EMPLOYEE_POSITIONS_DENIED ED,
                EMPLOYEE_POSITIONS E
            WHERE
                (ED.IS_DELETE = 1) AND
                ED.DENIED_TYPE = 1 AND
                ED.MODULE_ID = <cf_workcube_queryparam cfsqltype="cf_sql_integer" value="#arguments.module_name#"> AND
                ED.DENIED_PAGE = 'project.works' AND
                ED.DENIED_PAGE NOT IN
                (
                    SELECT
                        DENIED_PAGE
                    FROM
                        EMPLOYEE_POSITIONS_DENIED EPD,
                        EMPLOYEE_POSITIONS EP
                    WHERE
                        (EPD.IS_DELETE = 1) AND
                        EPD.DENIED_TYPE = 1 AND
                        EPD.MODULE_ID = <cf_workcube_queryparam cfsqltype="cf_sql_integer" value="#arguments.module_name#"> AND
                        EPD.DENIED_PAGE =<cf_workcube_queryparam cfsqltype="cf_sql_varchar" value='project.works'> AND
                        EP.POSITION_CODE = <cf_workcube_queryparam cfsqltype="cf_sql_integer" value="#arguments.position_id#"> AND
                        (
                            EPD.POSITION_CODE = EP.POSITION_CODE OR
                            EPD.POSITION_CAT_ID = EP.POSITION_CAT_ID OR
                            EPD.USER_GROUP_ID = EP.USER_GROUP_ID
                        )
                )
                    UNION 
                    SELECT
                        U.OBJECT_NAME AS DENIED_PAGE,
                        DELETE_OBJECT AS IS_DELETE
                    FROM
                        EMPLOYEE_POSITIONS AS E
                        LEFT JOIN USER_GROUP_OBJECT AS U ON E.USER_GROUP_ID = U.USER_GROUP_ID
                    WHERE
                        E.EMPLOYEE_ID = <cf_workcube_queryparam cfsqltype="cf_sql_integer" value="#arguments.user_id#">
                        AND U.OBJECT_NAME = <cf_workcube_queryparam cfsqltype="cf_sql_varchar" value='#arguments.object_name#'>
        </cfquery>
        <cfreturn GET_EMP_DEL_BUTTONS>
    </cffunction>   
    <cffunction name= "EMPLOYEE_DENIED" access="remote" returntype="any">
        <cfargument name="position_id" default="">  
        <cfargument name="fuseaction" default="">                                  
        <cfquery name="EMPLOYEE_DENIED" datasource="#DSN#">         
            SELECT
                EPD.IS_DELETE,
                EPD.IS_INSERT,
                EPD.DENIED_PAGE
            FROM
                EMPLOYEE_POSITIONS_DENIED AS EPD,
                EMPLOYEE_POSITIONS AS EP
            WHERE
                EPD.DENIED_TYPE <> 1 AND
                EP.POSITION_CODE = <cf_workcube_queryparam cfsqltype="cf_sql_integer" value="#arguments.position_id#"> AND
                EPD.DENIED_PAGE = <cf_workcube_queryparam cfsqltype="cf_sql_varchar" value="#arguments.fuseaction#"> AND
                (
                    EPD.POSITION_CODE = EP.POSITION_CODE OR
                    EPD.POSITION_CAT_ID = EP.POSITION_CAT_ID OR
                    EPD.USER_GROUP_ID = EP.USER_GROUP_ID
                )
        </cfquery>
        <cfreturn EMPLOYEE_DENIED>
    </cffunction>
    <cffunction name="GET_EMP_APP" access="remote" returntype="any">
        <cfargument name="empapp_id" default="">
        <cfquery name="GET_EMP_APP" datasource="#DSN#">
            SELECT
                EP.*,
                'empapp' AS MEMBER_TYPE,
                EP.EMPAPP_ID AS MEMBER_ID
            FROM
                EMPLOYEES_APP EP
            WHERE
                1 = 1
                <cfif isdefined("arguments.empapp_id") and len(arguments.empapp_id)>
                    AND EP.EMPAPP_ID = <cf_workcube_queryparam cfsqltype="cf_sql_integer" value="#arguments.empapp_id#">
                </cfif>
        </cfquery>
        <cfreturn GET_EMP_APP>
    </cffunction>
    <cffunction name="GET_MAILLIST_APP" access="remote" returntype="any">
        <cfargument name="maillist_id" default="">
        <cfquery name="Q_GET_MAILLIST_APP" datasource="#DSN#">
            SELECT
                ML.*,
                'maillist' AS MEMBER_TYPE,
                ML.MAILLIST_ID AS MEMBER_ID
            FROM
                MAILLIST ML
            WHERE
                1 = 1
                <cfif isdefined("arguments.maillist_id") and len(arguments.maillist_id)>
                    AND ML.MAILLIST_ID = <cf_workcube_queryparam cfsqltype="cf_sql_integer" value="#arguments.maillist_id#">
                </cfif>
        </cfquery>
        <cfreturn Q_GET_MAILLIST_APP>
    </cffunction>
    <cffunction name="send_mail_to_attenders" access="remote" returntype="any" returnFormat="JSON">
        <cfargument name="attenderMailList" />
        <cfargument name="attenderNameList" />
        <cfargument name="attenderTCNOList" />
        <cfargument name="org_id" />
        <cfif cgi.server_port eq 443>
            <cfset user_domain = "https://#cgi.server_name#">
        <cfelse>
            <cfset user_domain = "http://#cgi.server_name#">
        </cfif>
        <cfset response = structNew()>
        <cfset response.status = 0>
        <cfquery name="GET_COMP_ADDR" datasource="#dsn#">
            SELECT 
                COMPANY_NAME,
                ADDRESS,
                TEL_CODE,
                TEL,
                FAX,
                WEB,
                ASSET_FILE_NAME2,
                ADMIN_MAIL
            FROM 
                #dsn_alias#.OUR_COMPANY 
            WHERE
                <cfif isDefined("session.qq.company_id") and len(session.qq.company_id)>
                    COMP_ID = <cf_workcube_queryparam cfsqltype="cf_sql_integer" value="#session.qq.company_id#">
                <cfelse>
                    COMP_ID = <cf_workcube_queryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#">
                </cfif>
        </cfquery>
        <cfif len(get_comp_addr.ASSET_FILE_NAME2)>
            <cfset mail_logo = "/documents/settings/"&get_comp_addr.asset_file_name2>
        <cfelse>
            <cfset mail_logo = "/documents/templates/info_mail/logobig.gif">
        </cfif>
        <cfset response = structNew()>
        <cfset response.status = 0>
        <cftry>
            <cfif isDefined("arguments.attenderMailList") and len(arguments.attenderMailList)>
                <cfloop list="#arguments.attenderMailList#" item="item" index="index">
                    <cfif len(item)>
                        <cfset attender_name = listToArray(attenderNameList)[index] />
                        <cfset vkn_tckn = left(createUUID(), 11) />
                        <cfset tel = left(createUUID(), 11) />
                        <cfset organization_attender_id = listToArray(arguments.attenderList)[index] />
                        <cfset qr_value = "#organization_attender_id#_#vkn_tckn#_#item#_#tel#_#arguments.org_id#">
                        <cfset BarcodeFormat = createObject("java", "com.google.zxing.BarcodeFormat")>
                        <cfset writer = createObject("java", "com.google.zxing.qrcode.QRCodeWriter")>
                        <cfset bitMatrix = writer.encode(qr_value, BarcodeFormat["QR_CODE"], 170, 170)>
                        <cfif not directoryExists("#application.systemParam.upload_folder#/barcode/")>
                            <cfdirectory action="create" directory="#application.systemParam.upload_folder#/barcode/" mode="777"/>
                        </cfif>
                        <cfset filePath = "#application.systemParam.upload_folder#/barcode/#vkn_tckn#_#tel#_#arguments.org_id#.png">
                        <cfset fileOutputStream = createObject("java", "java.io.FileOutputStream").init(filePath)>
                        <cfset matrixToImageWriter = createObject("java", "com.google.zxing.client.j2se.MatrixToImageWriter")>
                        <cfset matrixToImageWriter.writeToStream(bitMatrix, "PNG", fileOutputStream)>
                        <cfset fileOutputStream.close()>
                        <cfif isDefined("arguments.organization_head") and len(arguments.organization_head)>
                            <cfset org_head = decodeFromURL(arguments.organization_head) />
                        <cfelse>
                            <cfset org_head = get_comp_addr.company_name />
                        </cfif>
                        <cfset FileSetAccessMode(filePath, '777') />
                        <cfset cfc = createObject('component', 'V16.campaign.cfc.organizationManagement') />
                        <cfset get_organization = cfc.get_organization(org_id: arguments.org_id)>
                        <cfmail from="#get_comp_addr.company_name#<#get_comp_addr.ADMIN_MAIL#>" to="#item#" subject="#get_organization.organization_head# - Davetiye" type="html">
                            <div class="container">
                                <div id="payment_success">
                                    <p style="margin:0"><img src="https://<cfoutput>#cgi.server_name#</cfoutput>/documents/barcode/#vkn_tckn#_#tel#_#arguments.org_id#.png"></p>
                                    <p style="padding-left:1.5% !important;font-size:25px !important;margin-top:-20px !important;color:black;font-weight:600;margin:0;"><cfoutput>#get_organization.organization_head#</cfoutput></p>
                                    <p style="padding-left:1.5% !important;font-size:25px !important;margin-top:-20px !important;color:black;font-weight:600;margin:0;">DAVETİYE</p>
                                    <p style="padding-left:1.5%; font-size:19px;color:black;margin:0;"><b>#attender_name#</b></p>
                                    <p style="padding-left:1.5%; font-size:17px;color:black;margin:0;"><b>Davetiye tek kişiliktir. Bekleriz.</b></p>
                                    <table style="padding-left:0.8%;color:black;font-size:16px;margin-top:20px;background-color:##f1f1f1;padding:1%;border-radius:4px;">
                                        <cfoutput>
                                            <tr>
                                                <td width="25%"><b>Etkinlik</b></td>
                                                <td width="75%">: #get_organization.organization_head#</td>
                                            </tr>
                                            <tr>
                                                <cfset start_date_ = dateAdd('h', 3, get_organization.start_date) />
                                                <cfset finish_date_ = dateAdd('h', 3, get_organization.finish_date) />
                                                <td width="25%"><b>Tarih</b></td>
                                                <td width="75%">: #datePart("d", get_organization.start_date)# #monthAsString(datePart('m', get_organization.start_date),'tr')# #datePart("yyyy", get_organization.start_date)# - #TimeFormat(start_date_, 'HH:mm')# / 
                                                    #datePart("d", get_organization.finish_date)# #monthAsString(datePart('m', get_organization.finish_date),'tr')# #datePart("yyyy", get_organization.finish_date)# - #TimeFormat(finish_date_, 'HH:mm')#</td>
                                            </tr>
                                            <tr>
                                                <td width="25%"><b>Etkinlik Yeri</b></td>
                                                <td width="75%">: #get_organization.organization_place#</td>
                                            </tr>
                                            <tr>
                                                <td width="25%"><b>Etkinlik Adresi</b></td>
                                                <td width="75%">: #get_organization.organization_place_address#</td>
                                            </tr>
                                            <tr>
                                                <td width="25%"><b>Etkinlik Sorumlusu</b></td>
                                                <td width="75%">: #get_organization.organization_place_manager#</td>
                                            </tr>
                                            <tr>
                                                <td width="25%"><b>Etkinlik Yeri Telefonu</b></td>
                                                <td width="75%">: #get_organization.organization_place_tel#</td>
                                            </tr>
                                            <tr>
                                                <td width="25%"><b>Düzenleyen<b></td>
                                                <td width="75%">: #get_comp_addr.company_name#</td>
                                            </tr>
                                        </cfoutput>
                                    </table>
                                </div>
                            </div>
                            <br /><br />
                            <b style="color:black;"><cf_get_lang dictionary_id='40130.© This email was sent by Workcube System - Digitalization for your success'></b>
                        </cfmail>
                        <!--- Katılımcıya mail gönderildiği tabloya işleniyor --->
                        <cfquery name="get_mail_sent_count" datasource="#dsn#">
                            SELECT COALESCE(IS_MAIL_SENT, 0) AS MAIL_SENT_COUNT FROM ORGANIZATION_ATTENDER WHERE ORGANIZATION_ID = <cf_workcube_queryparam cfsqltype="cf_sql_integer" value="#arguments.org_id#"> AND ORGANIZATION_ATTENDER_ID = <cf_workcube_queryparam cfsqltype="cf_sql_integer" value="#organization_attender_id#">
                        </cfquery>
                        <cfquery name="mail_sent_to_attender" datasource="#dsn#" result="asd">
                            UPDATE ORGANIZATION_ATTENDER SET IS_MAIL_SENT = #get_mail_sent_count.mail_sent_count#+1 WHERE ORGANIZATION_ATTENDER_ID = <cf_workcube_queryparam cfsqltype="cf_sql_integer" value="#organization_attender_id#"> AND ORGANIZATION_ID = <cf_workcube_queryparam cfsqltype="cf_sql_integer" value="#arguments.org_id#">
                        </cfquery>
                    </cfif>
                </cfloop>
            </cfif>
            <cfset response.status = "1" />
            <cfset response.message = '#getLang('','Mail Başarıyla Gönderildi',57513)#'>
        <cfcatch>
            <cfset response.status = "0" />
            <cfset response.message = '#getLang('','Mail gönderimi sırasında hata oluştu',60852)#'>
            <cfdump  var="#cfcatch#">
        </cfcatch>
        </cftry>
        <cfreturn serializeJSON(response) />    
    </cffunction>

    <cffunction name="addNewAttender" access="remote" returntype="any" returnformat="JSON">
        <cfargument name="name" default="" />
        <cfargument name="surname" default="" />
        <cfargument name="email" default="" />
        <cfargument name="telcode" default="" />
        <cfargument name="tel" default="" />
        <cfargument name="org_id" default="" />
        <cfargument name="company" default="" />
        <cfargument name="title" default="" />
        <cfset responseStruct = structNew() />
        <cftry>
            <cfquery name="get_mail" datasource="#dsn#">
                SELECT MAILLIST_ID FROM MAILLIST WHERE MAILLIST_EMAIL = <cf_workcube_queryparam cfsqltype="cf_sql_varchar" value="#arguments.email#">
            </cfquery>
            <cfif get_mail.recordCount gt 0>
                <cfset maillist_id = get_mail.maillist_id>
            <cfelse>
                <cfquery name="addAttenderToMaillist" datasource="#dsn#" result="maillistResult">
                    INSERT INTO
                        MAILLIST (MAILLIST_NAME, MAILLIST_SURNAME, MAILLIST_EMAIL, MAILLIST_MOBILCODE, MAILLIST_MOBIL, MAILLIST_COMPANY, MAILLIST_TITLE)
                    VALUES (
                        <cf_workcube_queryparam cfsqltype="cf_sql_varchar" value="#arguments.name#">,
                        <cf_workcube_queryparam cfsqltype="cf_sql_varchar" value="#arguments.surname#">,
                        <cf_workcube_queryparam cfsqltype="cf_sql_varchar" value="#arguments.email#">,
                        <cf_workcube_queryparam cfsqltype="cf_sql_varchar" value="#arguments.telcode#">,
                        <cf_workcube_queryparam cfsqltype="cf_sql_varchar" value="#arguments.tel#">,
                        <cf_workcube_queryparam cfsqltype="cf_sql_varchar" value="#arguments.company#">,
                        <cf_workcube_queryparam cfsqltype="cf_sql_varchar" value="#arguments.title#">
                    )
                </cfquery>
                <cfset maillist_id = maillistResult.IDENTITYCOL>
            </cfif>
            <cfquery name="get_org_mail" datasource="#dsn#">
                SELECT ORGANIZATION_ATTENDER_ID FROM ORGANIZATION_ATTENDER WHERE ORGANIZATION_ID = <cf_workcube_queryparam cfsqltype="cf_sql_integer" value="#arguments.org_id#"> AND MAILLIST_ID = <cf_workcube_queryparam cfsqltype="cf_sql_integer" value="#maillist_id#">
            </cfquery>
            <cfif get_org_mail.recordCount gt 0>
                <cfset responseStruct.message = "#getLang('','Bu katılımcı daha önce eklenmiş.',56815)#" />
                <cfset responseStruct.status = false />
                <cfset responseStruct.attender_id = get_org_mail.organization_attender_id />
                <cfset responseStruct.error = {} />
                <cfset responseStruct.identity = '' />
            <cfelse>
                <cfquery name="addNewAttenderToOrganization" datasource="#dsn#" result="new_org">
                    INSERT INTO ORGANIZATION_ATTENDER (ORGANIZATION_ID, MAILLIST_ID, STATUS) VALUES (
                        <cf_workcube_queryparam cfsqltype="cf_sql_integer" value="#arguments.org_id#">,
                        <cf_workcube_queryparam cfsqltype="cf_sql_integer" value="#maillist_id#">,
                        <cf_workcube_queryparam cfsqltype="cf_sql_integer" value="4">
                    )
                </cfquery>
                <cfset responseStruct.message = "#getLang('','İşlem Başarılı',61210)#">
                <cfset responseStruct.status = true />
                <cfset responseStruct.attender_id = new_org.IDENTITYCOL />
                <cfset responseStruct.error = {} />
                <cfset responseStruct.identity = '' />
            </cfif>
        <cfcatch type="database">
            <cftransaction action="rollback" />
            <cfset responseStruct.message = "#getLang('','İşlem Hatalı',65894)#" />
            <cfset responseStruct.status = false />
            <cfset responseStruct.error = cfcatch />
        </cfcatch>
        </cftry>
        <cfreturn serializeJSON(responseStruct) />
    </cffunction>

    <cffunction name="setAttenderAsCome" access="remote" returntype="any" returnformat="JSON">
        <cfargument name="organization_attender_id" default="" />
        <cfset responseStruct = structNew() />
        <cftry>
            <cfquery name="markAttenderAsCome" datasource="#dsn#">
                UPDATE ORGANIZATION_ATTENDER SET IS_COME = 1 WHERE ORGANIZATION_ATTENDER_ID = <cf_workcube_queryparam cfsqltype="cf_sql_integer" value="#arguments.organization_attender_id#">
            </cfquery>
            <cfset responseStruct.message = "İşlem Başarılı">
            <cfset responseStruct.status = true />
            <cfset responseStruct.error = {} />
            <cfset responseStruct.identity = '' />
        <cfcatch type="database">
            <cftransaction action="rollback" />
            <cfset responseStruct.message = "İşlem Hatalı" />
            <cfset responseStruct.status = false />
            <cfset responseStruct.error = cfcatch />
        </cfcatch>
        </cftry>
        <cfreturn serializeJSON(responseStruct) />
    </cffunction>

    <cffunction name="checkQRCodeAttenders" access="remote" returntype="any" returnformat="json">
        <cfargument name="organization_attender_id" />
        <cfargument name="attender_mail" />
        <cfargument name="org_id" />
        <cfargument name="org_id_validation" />
        <cfset response = structNew() />
        <cftry>
            <cfif (isDefined("arguments.organization_attender_id") and isNumeric(arguments.organization_attender_id)) or (isDefined("arguments.attender_mail") and len(arguments.attender_mail))>

                <cfquery name="get_par_attender" datasource="#dsn#">
                    SELECT * FROM
                        COMPANY_PARTNER
                            INNER JOIN ORGANIZATION_ATTENDER ON COMPANY_PARTNER.PARTNER_ID = ORGANIZATION_ATTENDER.PAR_ID
                            INNER JOIN COMPANY ON COMPANY_PARTNER.COMPANY_ID = COMPANY.COMPANY_ID
                    WHERE
                        COMPANY_PARTNER.COMPANY_PARTNER_EMAIL LIKE <cf_workcube_queryparam cfsqltype="cf_sql_varchar" value="%#arguments.attender_mail#%">
                        AND ORGANIZATION_ATTENDER.ORGANIZATION_ID = <cf_workcube_queryparam cfsqltype="cf_sql_integer" value="#arguments.org_id#">
                </cfquery>
                <cfquery name="get_emp_attender" datasource="#dsn#">
                    SELECT * FROM
                        EMPLOYEES
                            INNER JOIN ORGANIZATION_ATTENDER ON EMPLOYEES.EMPLOYEE_ID = ORGANIZATION_ATTENDER.EMP_ID
                    WHERE
                        EMPLOYEE_EMAIL LIKE <cf_workcube_queryparam cfsqltype="cf_sql_varchar" value="%#arguments.attender_mail#%">
                        AND ORGANIZATION_ATTENDER.ORGANIZATION_ID = <cf_workcube_queryparam cfsqltype="cf_sql_integer" value="#arguments.org_id#">
                </cfquery>
                <cfquery name="get_con_attender" datasource="#dsn#">
                    SELECT * FROM
                        CONSUMER
                            INNER JOIN ORGANIZATION_ATTENDER ON CONSUMER.CONSUMER_ID = ORGANIZATION_ATTENDER.CON_ID
                    WHERE
                        CONSUMER_EMAIL LIKE <cf_workcube_queryparam cfsqltype="cf_sql_varchar" value="%#arguments.attender_mail#%">
                        AND ORGANIZATION_ATTENDER.ORGANIZATION_ID = <cf_workcube_queryparam cfsqltype="cf_sql_integer" value="#arguments.org_id#">
                </cfquery>
                <cfquery name="get_empapp_attender" datasource="#dsn#">
                    SELECT * FROM
                        EMPLOYEES_APP
                            INNER JOIN ORGANIZATION_ATTENDER ON EMPLOYEES_APP.EMPAPP_ID = ORGANIZATION_ATTENDER.EMPAPP_ID
                    WHERE
                        EMAIL LIKE <cf_workcube_queryparam cfsqltype="cf_sql_varchar" value="%#arguments.attender_mail#%">
                        AND ORGANIZATION_ATTENDER.ORGANIZATION_ID = <cf_workcube_queryparam cfsqltype="cf_sql_integer" value="#arguments.org_id#">
                </cfquery>
                <cfquery name="get_maillist_attender" datasource="#dsn#">
                    SELECT * FROM
                        MAILLIST
                            INNER JOIN ORGANIZATION_ATTENDER ON MAILLIST.MAILLIST_ID = ORGANIZATION_ATTENDER.MAILLIST_ID
                    WHERE
                        MAILLIST_EMAIL LIKE <cf_workcube_queryparam cfsqltype="cf_sql_varchar" value="%#arguments.attender_mail#%">
                        AND ORGANIZATION_ATTENDER.ORGANIZATION_ID = <cf_workcube_queryparam cfsqltype="cf_sql_integer" value="#arguments.org_id#">
                </cfquery>

                <cfif get_par_attender.recordCount>
                    <cfset attender_id = get_par_attender.organization_attender_id>
                    <cfset att_type = 'par' />
                    <cfset att_name_surname = get_par_attender.company_partner_name & ' ' & get_par_attender.company_partner_surname />
                    <cfset att_comp = get_par_attender.fullname />
                <cfelseif get_emp_attender.recordCount>
                    <cfset attender_id = get_emp_attender.organization_attender_id>
                    <cfset att_type = 'emp' />
                    <cfset att_name_surname = get_emp_attender.employee_name & ' ' & get_emp_attender.employee_surname />
                    <cfquery name="emp_title" datasource="#dsn#">
                        SELECT
                            EMPLOYEE_POSITIONS.POSITION_NAME, EMPLOYEE_POSITIONS.DEPARTMENT_ID, BRANCH.RELATED_COMPANY
                        FROM
                            EMPLOYEE_POSITIONS,
                            BRANCH,
                            DEPARTMENT
                        WHERE
                            EMPLOYEE_ID = #get_emp_attender.employee_id#
                            AND BRANCH.BRANCH_ID=DEPARTMENT.BRANCH_ID
                            AND DEPARTMENT.DEPARTMENT_ID = EMPLOYEE_POSITIONS.DEPARTMENT_ID
                    </cfquery>
                    <cfset att_comp = len(emp_title.RELATED_COMPANY) ? emp_title.RELATED_COMPANY : 'Çalışan' />
                <cfelseif get_con_attender.recordCount>
                    <cfset attender_id = get_con_attender.organization_attender_id>
                    <cfset att_type = 'con' />
                    <cfset att_name_surname = get_con_attender.employee_name & ' ' & get_con_attender.employee_surname />
                    <cfset att_comp = "Bireysel Üye" />
                <cfelseif get_empapp_attender.recordCount>
                    <cfset attender_id = get_empapp_attender.organization_attender_id>
                    <cfset att_type = 'empapp' />
                    <cfset att_name_surname = get_empapp_attender.employee_name & ' ' & get_empapp_attender.employee_surname />
                    <cfset att_comp = "Özgeçmiş" />
                <cfelseif get_maillist_attender.recordCount>
                    <cfset attender_id = get_maillist_attender.organization_attender_id>
                    <cfset att_type = 'maillist' />
                    <cfset att_name_surname = get_maillist_attender.maillist_name & ' ' & get_maillist_attender.maillist_surname />
                    <cfset att_comp = get_maillist_attender.MAILLIST_COMPANY />
                </cfif>
                
                <cfif isDefined("attender_id") and len(attender_id)>
                    <cfquery name="q_checkQRCodeAttenders" datasource="#dsn#">
                        SELECT
                            ORGANIZATION_ATTENDER.ORGANIZATION_ATTENDER_ID,
                            ORGANIZATION.ORGANIZATION_HEAD,
                            ORGANIZATION.ORGANIZATION_ID,
                            ORGANIZATION.START_DATE,
                            ORGANIZATION.FINISH_DATE
                        FROM
                            ORGANIZATION_ATTENDER
                                INNER JOIN ORGANIZATION ON ORGANIZATION_ATTENDER.ORGANIZATION_ID = ORGANIZATION.ORGANIZATION_ID
                        WHERE
                            ORGANIZATION_ATTENDER.ORGANIZATION_ATTENDER_ID = <cf_workcube_queryparam cfsqltype="cf_sql_integer" value="#attender_id#">
                    </cfquery>
                    <cfset response.ATTENDER_MAIL = arguments.attender_mail>
                    <cfset response.ORGANIZATION_HEAD = q_checkQRCodeAttenders.ORGANIZATION_HEAD>
                    <cfset response.ORGANIZATION_ID = q_checkQRCodeAttenders.ORGANIZATION_ID>
                    <cfset response.START_DATE = q_checkQRCodeAttenders.START_DATE>
                    <cfset response.FINISH_DATE = q_checkQRCodeAttenders.FINISH_DATE>
                    <cfset response.status = 1>
                    <cfset response.attender_id = attender_id>
                    <cfset response.att_comp = att_comp>
                    <cfset response.att_name_surname = att_name_surname>
                    <cfif isDefined("response.status") and response.status eq 1 and q_checkQRCodeAttenders.recordCount and arguments.org_id eq arguments.org_id_validation>
                        <cfquery name="markAttenderAsCome" datasource="#dsn#">
                            UPDATE ORGANIZATION_ATTENDER SET IS_COME = 1 WHERE ORGANIZATION_ATTENDER_ID = <cf_workcube_queryparam cfsqltype="cf_sql_integer" value="#q_checkQRCodeAttenders.organization_attender_id#">
                        </cfquery>
                    </cfif>
                <cfelse>
                    <cfset response.status = 0>
                </cfif>
            <cfelse>
                <cfset response.status = 0>
            </cfif>
        <cfcatch>
            <cfset response.status = 0>
            <!--- <cfdump  var="#cfcatch#"> --->
        </cfcatch>
        </cftry>
        <cfreturn serializeJSON(response) />
    </cffunction>

    <cffunction name="getAttenderMailListId" access="remote" returntype="any">
        <cfargument name="organization_attender_id" />
        <cfquery name="q_getAttenderMailListId" datasource="#dsn#">
            SELECT MAILLIST_ID, PAR_ID, EMPAPP_ID, EMP_ID, CON_ID FROM ORGANIZATION_ATTENDER WHERE ORGANIZATION_ATTENDER_ID = <cf_workcube_queryparam cfsqltype="cf_sql_integer" value="#arguments.organization_attender_id#">
        </cfquery>
        <cfreturn q_getAttenderMailListId />
    </cffunction>

    <cffunction name="sendMailToAttender" access="remote" returntype="any" returnformat="JSON">
        <cfargument name="attender_type" default="" required="true" />
        <cfargument name="organization_attender_id" default="" required="true" />
        <cfargument name="userid" default="" required="true" />
        <cfargument name="mail_prefix" default="" />
        <cfargument name="mail_suffix" default="" />
        <cfset responseStruct = structNew() />

        <cfif not isDefined("arguments.attender_type") or not isDefined("arguments.organization_attender_id") or not isDefined("arguments.userid")>
            <cfset responseStruct.message = "Eksik parametre girildi!" />
            <cfset responseStruct.status = false />
        <cfelse>
            <cftry>
                <cfif arguments.attender_type eq 'maillist'>
                    <cfquery name="getAttenderInfo" datasource="#dsn#">
                        SELECT
                            MAILLIST_NAME AS NAME,
                            MAILLIST_SURNAME AS SURNAME,
                            MAILLIST_EMAIL AS EMAIL,
                            MAILLIST_TEL AS TEL,
                            MAILLIST_TELCOD AS TELCODE
                        FROM
                            MAILLIST
                        WHERE
                            MAILLIST_ID = <cf_workcube_queryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">
                    </cfquery>
                <cfelseif arguments.attender_type eq 'empapp'>
                    <cfquery name="getAttenderInfo" datasource="#dsn#">
                        SELECT
                            NAME,
                            SURNAME,
                            EMAIL,
                            HOMETEL AS TEL,
                            MOBILCODE AS TELCODE
                        FROM
                            EMPLOYEES_APP
                        WHERE
                            EMPAPP_ID = <cf_workcube_queryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">
                    </cfquery>
                <cfelseif arguments.attender_type eq 'consumer'>
                    <cfquery name="getAttenderInfo" datasource="#dsn#">
                        SELECT
                            CONSUMER_NAMEAS NAME,
                            CONSUMER_SURNAMEAS SURNAME,
                            CONSUMER_EMAILAS EMAIL,
                            MOBILTEL AS TEL,
                            MOBIL_CODE AS TELCODE
                        FROM
                            CONSUMER
                        WHERE
                            CONSUMER_ID = <cf_workcube_queryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">
                    </cfquery>
                <cfelseif arguments.attender_type eq 'partner'>
                    <cfquery name="getAttenderInfo" datasource="#dsn#">
                        SELECT
                            COMPANY_PARTNER_NAME AS NAME,
                            COMPANY_PARTNER_SURNAME AS SURNAME,
                            COMPANY_PARTNER_EMAIL AS EMAIL,
                            MOBILTEL AS TEL,
                            MOBIL_CODE AS TELCODE
                        FROM
                            COMPANY_PARTNER
                        WHERE
                            PARTNER_ID = <cf_workcube_queryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">
                    </cfquery>
                <cfelse>
                    <cfquery name="getAttenderInfo" datasource="#dsn#">
                        SELECT
                            EMPLOYEE_NAME AS NAME,
                            EMPLOYEE_SURNAME AS SURNAME,
                            EMPLOYEE_EMAIL AS EMAIL,
                            MOBILTEL AS TEL,
                            MOBILCODE AS TELCODE
                        FROM
                            EMPLOYEES
                        WHERE
                            EMPLOYEE_ID = <cf_workcube_queryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">
                    </cfquery>
                </cfif>

                <cfquery name="getOrgInfo" datasource="#dsn#">
                    SELECT
                        ORGANIZATION_ID
                    FROM
                        ORGANIZATION_ATTENDER
                    WHERE
                        ORGANIZATION_ATTENDER_ID = <cf_workcube_queryparam cfsqltype="cf_sql_integer" value="#arguments.organization_attender_id#">
                </cfquery>
                
                
                <cfif cgi.server_port eq 443>
                    <cfset user_domain = "https://#cgi.server_name#">
                <cfelse>
                    <cfset user_domain = "http://#cgi.server_name#">
                </cfif>
                <cfset response = structNew()>
                <cfset response.status = 0>
                <cfquery name="GET_COMP_ADDR" datasource="#dsn#">
                    SELECT 
                        COMPANY_NAME,
                        ADDRESS,
                        TEL_CODE,
                        TEL,
                        FAX,
                        WEB,
                        ASSET_FILE_NAME2,
                        ADMIN_MAIL
                    FROM 
                        #dsn_alias#.OUR_COMPANY 
                    WHERE
                        <cfif isDefined("session.qq.company_id") and len(session.qq.company_id)>
                            COMP_ID = <cf_workcube_queryparam cfsqltype="cf_sql_integer" value="#session.qq.company_id#">
                        <cfelse>
                            COMP_ID = <cf_workcube_queryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#">
                        </cfif>
                </cfquery>
                <cfif len(get_comp_addr.ASSET_FILE_NAME2)>
                    <cfset mail_logo = "/documents/settings/"&get_comp_addr.asset_file_name2>
                <cfelse>
                    <cfset mail_logo = "/documents/templates/info_mail/logobig.gif">
                </cfif>
                <cfset response = structNew()>
                <cfset response.status = 0>
                <cftry>
                    <cfif isDefined("getAttenderInfo.email") and len(getAttenderInfo.email)>
                        <cfset attender_name = getAttenderInfo.name &' '&getAttenderInfo.surname />
                        <cfset vkn_tckn = left(createUUID(), 11) />
                        <cfif isDefined("getAttenderInfo.tel") and len(getAttenderInfo.tel)>
                            <cfset tel = getAttenderInfo.tel&''&getAttenderInfo.telcode />
                        <cfelse>
                            <cfset tel = left(createUUID(), 11) />
                        </cfif>
                        <cfset arguments.org_id = getOrgInfo.organization_id />
                        <cfset organization_attender_id = arguments.organization_attender_id />
                        <cfset qr_value = "#organization_attender_id#_#vkn_tckn#_#getAttenderInfo.email#_#tel#_#arguments.org_id#">
                        <cfset BarcodeFormat = createObject("java", "com.google.zxing.BarcodeFormat")>
                        <cfset writer = createObject("java", "com.google.zxing.qrcode.QRCodeWriter")>
                        <cfset bitMatrix = writer.encode(qr_value, BarcodeFormat["QR_CODE"], 170, 170)>
                        <cfif not directoryExists("#application.systemParam.upload_folder#/barcode/")>
                            <cfdirectory action="create" directory="#application.systemParam.upload_folder#/barcode/" mode="777"/>
                        </cfif>
                        <cfset filePath = "#application.systemParam.upload_folder#/barcode/#qr_value#.png">
                        <cfset fileOutputStream = createObject("java", "java.io.FileOutputStream").init(filePath)>
                        <cfset matrixToImageWriter = createObject("java", "com.google.zxing.client.j2se.MatrixToImageWriter")>
                        <cfset matrixToImageWriter.writeToStream(bitMatrix, "PNG", fileOutputStream)>
                        <cfset fileOutputStream.close()>
                        <cfset FileSetAccessMode(filePath, '777') />
                        
                        <cfset cfc = createObject('component', 'V16.campaign.cfc.organizationManagement') />
                        <cfset get_organization = cfc.get_organization(org_id: arguments.org_id)>
                        <cfmail from="#get_comp_addr.company_name#<#get_comp_addr.ADMIN_MAIL#>" to="#getAttenderInfo.email#" subject="#get_organization.organization_head# - #iIf(isDefined("arguments.mail_prefix") and len(arguments.mail_prefix), 'arguments.mail_prefix', DE(''))#" type="html">
                            <div class="container">
                                <div id="payment_success">
                                    <p style="margin:0"><img src="https://<cfoutput>#cgi.server_name#</cfoutput>/documents/barcode/#qr_value#.png"></p>
                                    <p style="padding-left:1.5% !important;font-size:25px !important;margin-top:-20px !important;color:black;font-weight:600;margin:0;"><cfoutput>#get_organization.organization_head#</cfoutput></p>
                                    <p style="padding-left:1.5% !important;font-size:25px !important;margin-top:-20px !important;color:black;font-weight:600;margin:0;">DAVETİYE</p>
                                    <p style="padding-left:1.5%; font-size:19px;color:black;margin:0;"><b>#attender_name#</b></p>
                                    <p style="padding-left:1.5%; font-size:17px;color:black;margin:0;"><b>Davetiye tek kişiliktir. Bekleriz.</b></p>
                                    <table style="padding-left:0.8%;color:black;font-size:16px;margin-top:20px;padding:1%;border-radius:4px;">
                                        <cfoutput>
                                            <tr>
                                                <td width="25%"><b>Etkinlik</b></td>
                                                <td width="75%">: #get_organization.organization_head#</td>
                                            </tr>
                                            <tr>
                                                <td width="25%"><b>Tarih</b></td>
                                                <cfif isDefined("get_organization.start_date") and len(get_organization.start_date) and isDefined("get_organization.finish_date") and len(get_organization.finish_date)>
                                                    <cfset start_date_ = dateAdd('h', 3, get_organization.start_date) />
                                                    <cfset finish_date_ = dateAdd('h', 3, get_organization.finish_date) />
                                                    <td width="75%">: #datePart("d", get_organization.start_date)# #monthAsString(datePart('m', get_organization.start_date),'tr')# #datePart("yyyy", get_organization.start_date)# - #TimeFormat(start_date_, 'HH:mm')# / 
                                                    #datePart("d", get_organization.finish_date)# #monthAsString(datePart('m', get_organization.finish_date),'tr')# #datePart("yyyy", get_organization.finish_date)# - #TimeFormat(finish_date_, 'HH:mm')#</td>
                                                <cfelse>
                                                    <cfset start_date_ = now() />
                                                    <cfset finish_date_ = now() />
                                                    <td></td>
                                                </cfif>
                                            </tr>
                                            <tr>
                                                <td width="25%"><b>Etkinlik Yeri</b></td>
                                                <td width="75%">: #get_organization.organization_place#</td>
                                            </tr>
                                            <tr>
                                                <td width="25%"><b>Etkinlik Adresi</b></td>
                                                <td width="75%">: #get_organization.organization_place_address#</td>
                                            </tr>
                                            <tr>
                                                <td width="25%"><b>Etkinlik Sorumlusu</b></td>
                                                <td width="75%">: #get_organization.organization_place_manager#</td>
                                            </tr>
                                            <tr>
                                                <td width="25%"><b>Etkinlik Yeri Telefonu</b></td>
                                                <td width="75%">: #get_organization.organization_place_tel#</td>
                                            </tr>
                                            <tr>
                                                <td width="25%"><b>Düzenleyen<b></td>
                                                <td width="75%">: #get_comp_addr.company_name#</td>
                                            </tr>
                                            <cfif isDefined("get_organization.USER_FRIENDLY_URL") and len(get_organization.USER_FRIENDLY_URL) gt 1>
                                                <tr>
                                                    <td width="25%"></td>
                                                    <td width="75%">>> <a href="https://holistic-coop.org/tr/#get_organization.USER_FRIENDLY_URL#" target="_blank" style="color: black;text-decoration: none;">Etkinlik Hakkında Detaylar için tıklayın</a></td>
                                                </tr>
                                            </cfif>
                                        </cfoutput>
                                    </table>
                                </div>
                            </div>
                            <br /><br />
                            <cfif isDefined("arguments.mail_suffix") and len(arguments.mail_suffix)>
                               <b style="color:black;font-size:14px;">#arguments.mail_suffix#</b>
                            </cfif>
                            <br><br><b style="color:black;"><cf_get_lang dictionary_id='40130.© This email was sent by Workcube System - Digitalization for your success'></b>
                        </cfmail>
                        <!--- Katılımcıya mail gönderildiği tabloya işleniyor --->
                        <cfquery name="get_mail_sent_count" datasource="#dsn#">
                            SELECT COALESCE(IS_MAIL_SENT, 0) AS MAIL_SENT_COUNT FROM ORGANIZATION_ATTENDER WHERE ORGANIZATION_ID = <cf_workcube_queryparam cfsqltype="cf_sql_integer" value="#arguments.org_id#"> AND ORGANIZATION_ATTENDER_ID = <cf_workcube_queryparam cfsqltype="cf_sql_integer" value="#organization_attender_id#">
                        </cfquery>
                        <cfquery name="mail_sent_to_attender" datasource="#dsn#" result="asd">
                            UPDATE ORGANIZATION_ATTENDER SET IS_MAIL_SENT = #get_mail_sent_count.mail_sent_count#+1 WHERE ORGANIZATION_ATTENDER_ID = <cf_workcube_queryparam cfsqltype="cf_sql_integer" value="#organization_attender_id#"> AND ORGANIZATION_ID = <cf_workcube_queryparam cfsqltype="cf_sql_integer" value="#arguments.org_id#">
                        </cfquery>
                    </cfif>
                    
                    <cfset response.status = true />
                    <cfset response.message = '#getLang('','Mail Başarıyla Gönderildi',57513)#'>
                <cfcatch>
                    <cfset response.status = false />
                    <cfset response.message = '#getLang('','Mail gönderimi sırasında hata oluştu',60852)#'>
                    <cfdump  var="#cfcatch#">
                </cfcatch>
                </cftry>
                <cfreturn serializeJSON(response) />

                <cfset responseStruct.message = "İşlem Başarılı">
                <cfset responseStruct.status = true />
                <cfset responseStruct.error = {} />
                <cfset responseStruct.identity = '' />
            <cfcatch type="database">
                <cftransaction action="rollback" />
                <cfset responseStruct.message = "İşlem Hatalı" />
                <cfset responseStruct.status = false />
                <cfset responseStruct.error = cfcatch />
            </cfcatch>
            </cftry>
        </cfif>
        
        <cfreturn responseStruct />
    </cffunction>
</cfcomponent>