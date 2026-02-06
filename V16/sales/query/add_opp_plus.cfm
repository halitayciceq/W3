<cfif len(plus_date)><cf_date tarih="plus_date"></cfif>
    <cftransaction>
    <cfquery name="ADD_OFFER_PLUS" datasource="#DSN3#">
        INSERT INTO
            OPPORTUNITIES_PLUS
        (
            OPP_ID,
            COMMETHOD_ID,
            PLUS_CONTENT,
            PLUS_DATE,
            EMPLOYEE_ID,
            RECORD_DATE,
            RECORD_EMP,
            OPP_ZONE,
            RECORD_IP,
            MAIL_SENDER,
            PLUS_SUBJECT,
            IS_EMAIL,
            MAIL_CC,
            PRODUCT_SAMPLE_ID
        )
        VALUES
        (
            <cfif isdefined("attributes.opp_id") and Len(attributes.opp_id)>#attributes.opp_id#<cfelse>NULL</cfif>,
            <cfif Len(commethod_id)>#commethod_id#<cfelse>NULL</cfif>,
            '#attributes.plus_content#',
            <cfif len(plus_date)>#plus_date#<cfelse>NULL</cfif>,
            <cfif len(employee_id)>#employee_id#<cfelse>NULL</cfif>,
            #now()#,
            #session.ep.userid#,
            0,
            '#cgi.remote_addr#',
            <cfif Len(attributes.employee_emails)>'#attributes.employee_emails#'<cfelse>NULL</cfif>,			
            '#attributes.opp_head#',
            <cfif isDefined("email") and (email eq "true") and Len(attributes.employee_emails)>1<cfelse>0</cfif>,
            <cfif Len(attributes.employee_emails1)>'#attributes.employee_emails1#'<cfelse>NULL</cfif>,
            <cfif isdefined("attributes.product_sample_id") and Len(attributes.product_sample_id)>#attributes.product_sample_id#<cfelse>NULL</cfif>
        )
    </cfquery>
    </cftransaction>
    <cfquery name="GET_OPP_PLUS_ID" datasource="#DSN3#">
        SELECT MAX(OPP_PLUS_ID) AS MAX_OPP_PLUS_ID FROM OPPORTUNITIES_PLUS 
    </cfquery>
    <!--- Ajandada Goster secili ise --->
    <cfif isDefined("attributes.is_agenda") and attributes.is_agenda eq 1>
        <cfif isDefined("attributes.response_date") and len(evaluate("attributes.response_date"))>
            <cf_date tarih="attributes.response_date">
            <cfset response_date = date_add('h',evaluate("attributes.response_clock")-session.ep.time_zone,evaluate("attributes.response_date"))>
            <cfset response_date = date_add('n',evaluate("attributes.response_min"),response_date)>
        <cfelse>
            <cfset response_date = "NULL">
        </cfif>
        
        <cfquery name="GET_POSITION_CODE" datasource="#DSN#">
            SELECT POSITION_CODE FROM EMPLOYEE_POSITIONS WHERE EMPLOYEE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#">
        </cfquery>
      
        <cfset url_link="">
        <cfquery name="ADD_WARNING" datasource="#DSN#" result="GET_WARNINGS">
            INSERT INTO
                PAGE_WARNINGS
            (
                WARNING_HEAD,
                WARNING_DESCRIPTION,
                LAST_RESPONSE_DATE,
                OUR_COMPANY_ID,
                PERIOD_ID,
                POSITION_CODE,
                URL_LINK, 
                IS_AGENDA,
                RECORD_IP,
                RECORD_EMP,
                RECORD_DATE,
                IS_ACTIVE
            )
            VALUES
            (
                '#attributes.opp_head#',
                '#attributes.opp_head#',
                #response_date#,
                #session.ep.company_id#,
                #session.ep.period_id#,
                #get_position_code.position_code#,
                'index.cfm?fuseaction=sales.popup_form_upd_opp_plus&opp_plus_id=#get_opp_plus_id.MAX_OPP_PLUS_ID#', 
                <cfif isdefined('attributes.is_agenda') and attributes.is_agenda eq 1>1<cfelse>0</cfif>,
                '#CGI.REMOTE_ADDR#',
                #session.ep.userid#,
                #now()#,
                1
            )
        </cfquery>
        <cfquery name="UPD_WARNINGS" datasource="#dsn#">
            UPDATE PAGE_WARNINGS SET PARENT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_warnings.IDENTITYCOL#"> WHERE W_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_warnings.IDENTITYCOL#">
        </cfquery>
    </cfif>
    <!--- Ajandada Goster secili ise --->
    
    <cfif isDefined("email") and (email eq "true") and Len(attributes.employee_emails)>
        <cfquery name="GET_OPP_INFO" datasource="#DSN3#">
            SELECT 
                O.OPP_NO,
                O.OPP_HEAD 
            FROM
                OPPORTUNITIES_PLUS OP LEFT JOIN OPPORTUNITIES O ON OP.OPP_ID = O.OPP_ID 
            WHERE
                 OP.OPP_PLUS_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_opp_plus_id.max_opp_plus_id#">
        </cfquery>
        <cfsavecontent variable="ust">
            <cfinclude template="../../objects/display/view_company_logo.cfm">
        </cfsavecontent>
        <cfsavecontent variable="alt">
            <cfinclude template="../../objects/display/view_company_info.cfm">
        </cfsavecontent>
        <cfquery name="GET_MAILFROM" datasource="#DSN#">
            SELECT
                <cfif listfindnocase(employee_url,'#cgi.http_host#',';')>EMPLOYEE_ID,EMPLOYEE_EMAIL,EMPLOYEE_NAME NAME_,EMPLOYEE_SURNAME SURNAME_<cfelseif listfindnocase(partner_url,'#cgi.http_host#',';')>PARTNER_ID,COMPANY_PARTNER_EMAIL,COMPANY_PARTNER_NAME NAME_,COMPANY_PARTNER_SURNAME SURNAME_</cfif>
            FROM		
                <cfif listfindnocase(employee_url,'#cgi.http_host#',';')>EMPLOYEE_POSITIONS<cfelseif listfindnocase(partner_url,'#cgi.http_host#',';')>COMPANY_PARTNER</cfif>		
            WHERE
                <cfif listfindnocase(employee_url,'#cgi.http_host#',';')>EMPLOYEE_ID = #session.ep.USERID#
                <cfelseif listfindnocase(partner_url,'#cgi.http_host#',';')>PARTNER_ID = #session.pp.USERID#</cfif>
        </cfquery>
        <cfif GET_MAILFROM.RECORDCOUNT>
            <cfset from_ = "#GET_MAILFROM.NAME_# #GET_MAILFROM.SURNAME_#<#GET_MAILFROM.EMPLOYEE_EMAIL#>">
        </cfif>
        <!---#from_#--->
        <div style="display:none" class="ui-cfmodal ui-cfmodal__alert">
            <cf_box>
                <div class="ui-cfmodal-close">×</div>
                <ul class="required_list"></ul>
            </cf_box>
        </div>
        <cftry>
            <cfmail to = "#attributes.employee_emails#" cc="#attributes.employee_emails1#" from = "#session.ep.company_email#" subject = "#get_opp_info.OPP_NO# #get_opp_info.OPP_HEAD#" type="HTML">
                <style type="text/css">
                    .color-header{background-color: ##a7caed;}
                    .color-border	{background-color:##6699cc;}
                    .color-row{	background-color: ##f1f0ff;}
                    .label {font-size:11px;font-family:Geneva, tahoma, arial,  Helvetica, sans-serif;color : ##333333;padding-left: 4px;}
                    .css1 {font-size:12px;font-family:arial,verdana;color:000000; background-color:white;}
                </style>
                    <div align="right">#ust#</div><br/>
                    <table class="css1">
                        <tr>
                            <td valign="top"><strong><cf_get_lang_main no="68.Konu"></strong>&nbsp;</td>
                            <td valign="top">#attributes.opp_head#</td>
                        </tr>
                        <tr>
                            <td valign="top"><strong><cf_get_lang_main no="217.Açıklama"></strong>&nbsp;</td>
                            <td valign="top">#attributes.plus_content#</td>
                        </tr>
                    </table>
                    <div align="right">#alt#</div><br/> 
            </cfmail>
            <cfsavecontent variable="css">
                <style type="text/css">
                    .color-header{background-color: ##a7caed;}
                    .color-border	{background-color:##6699cc;}
                    .color-row{	background-color: ##f1f0ff;}
                    .label {font-size:11px;font-family:Geneva, tahoma, arial,  Helvetica, sans-serif;color : ##333333;padding-left: 4px;}
                </style>
            </cfsavecontent>	  
            <cfset attributes.body="#css##attributes.plus_content#">
            <cfset attributes.to_list="#attributes.employee_emails#">
            <cfset attributes.cc_list="#attributes.employee_emails1#">
            <cfset attributes.from = from_>
            <cfset attributes.type=0>
            <cfset attributes.module="sales">
            <cfset attributes.subject="#attributes.opp_head#">
            <cfinclude template="../../objects/query/add_mail.cfm">	     
            <script>
                $('.ui-cfmodal-close').click(function(){
                        $('.ui-cfmodal__alert').fadeOut();
                        $('.ui-cfmodal__alert .required_list').empty();
                    });
                    $('.ui-cfmodal__alert .required_list').append('<li class="required"><i class="fa fa-terminal"></i><cf_get_lang dictionary_id='51080.Mail Başarıyla Gönderildi'></li>');
                    $('.ui-cfmodal__alert').fadeIn();                    
            </script>
            <cfcatch type="any">
                <script>
                    $('.ui-cfmodal-close').click(function(){
                            $('.ui-cfmodal__alert').fadeOut();
                            $('.ui-cfmodal__alert .required_list').empty();
                        });
                        $('.ui-cfmodal__alert .required_list').append('<li class="required"><i class="fa fa-terminal"></i><cf_get_lang dictionary_id='38508.Fırsat Kaydedildi Fakat Mail Göndermede Bir Hata Oldu Lütfen Verileri Kontrol Edip Sonra Tekrar Deneyiniz'></li>');
                        $('.ui-cfmodal__alert').fadeIn();                    
                </script>
            </cfcatch>
        </cftry>
        <script type="text/javascript">
		closeBoxDraggable( '<cfoutput>#attributes.modal_id#</cfoutput>','box_followup_b');			
        </script>
        <cfabort>
    </cfif>
    <script type="text/javascript">
        closeBoxDraggable( '<cfoutput>#attributes.modal_id#</cfoutput>','box_followup_b');
    </script>
    