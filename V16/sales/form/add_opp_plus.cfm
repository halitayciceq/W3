<cfinclude template="../query/get_commethod_cats.cfm">
<cfinclude template="../query/get_pursuit_templates.cfm">
<cf_xml_page_edit fuseact ="sales.popup_form_add_opp_plus">
<cfif isdefined('session.ep.userid')>
    <cfquery name="GET_MAILFROM" datasource="#DSN#">
        SELECT
            EMPLOYEE_ID,EMPLOYEE_EMAIL,EMPLOYEE_NAME NAME_,EMPLOYEE_SURNAME SURNAME_
        FROM		
            EMPLOYEE_POSITIONS	
        WHERE
            EMPLOYEE_ID = #session.ep.USERID#
    </cfquery>
    <cfif GET_MAILFROM.RECORDCOUNT>
        <cfset cc_mails = "#GET_MAILFROM.NAME_# #GET_MAILFROM.SURNAME_#<#GET_MAILFROM.EMPLOYEE_EMAIL#>">
        <cfset cc_mails_name = '#GET_MAILFROM.NAME_# #GET_MAILFROM.SURNAME_#'>
        <cfset cc_mails_id = GET_MAILFROM.employee_id>
    </cfif>
<cfelse>
	<cfset cc_mails = ''>
    <cfset cc_mails_name = ''>
    <cfset cc_mails_id = ''>
</cfif>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box title="#getLang('sales','Takip',40916)#" popup_box="#iif(isdefined("attributes.draggable"),1,0)#">
        <cfform name="add_offer_meet" method="post" action="#request.self#?fuseaction=sales.emptypopup_add_opp_plus">
            <cfinput type="Hidden" id="email" name="email" value="">
            <cfinput type="Hidden" id="modal_id" name="modal_id" value="#attributes.modal_id#">
            <input type="Hidden" name="opp_id" id="opp_id" value="<cfif isdefined("attributes.opp_id")><cfoutput>#attributes.opp_id#</cfoutput></cfif>">
            <input type="Hidden" name="product_sample_id" id="product_sample_id" value="<cfif isdefined("attributes.product_sample_id")><cfoutput>#attributes.product_sample_id#</cfoutput></cfif>">
            <cfoutput>
                <cf_box_elements>
                    <div class="col col-6 col-md-6 col-sm-6 col-xs-12" index="1">
                        <div class="form-group" id="item-employee_emails">
                            <label class="col col-4 col-md-4 col-xs-12"><cf_get_lang dictionary_id='57428.E-posta'>*</label>
                            <div class="col col-8 col-md-12 col-xs-12">
                                <div class="input-group">
                                    <input type="hidden" name="employee_id" id="employee_id" value="<cfif isdefined('attributes.contact_id') and Len(attributes.contact_id)>#attributes.contact_id#</cfif>">
                                    <input type="hidden" name="employee_names" id="employee_names" value="">
                                    <input type="text" name="employee_emails" id="employee_emails"  value="<cfif isdefined('attributes.contact_mail') and Len(attributes.contact_mail)>#attributes.contact_mail#</cfif>">
                                    <span class="input-group-addon icon-ellipsis" onclick="windowopen('#request.self#?fuseaction=objects.popup_check_mail&mail_id=add_offer_meet.employee_emails&names=add_offer_meet.employee_names','list');"></span>
                                </div>
                            </div> 
                        </div>                         
                        <div class="form-group" id="item-employee_emails1">
                            <label class="col col-4 col-md-4 col-xs-12">CC</label>
                            <div class="col col-8 col-md-12 col-xs-12">
                                <div class="input-group">
                                    <input type="hidden" name="employee_id1" id="employee_id1" value="#cc_mails_id#">
                                    <input type="hidden" name="employee_names1" id="employee_names1" value="#cc_mails_name#">
                                    <input type="text" name="employee_emails1" id="employee_emails1"  value="#cc_mails#">
                                    <span class="input-group-addon btnPointer icon-ellipsis" onclick="windowopen('#request.self#?fuseaction=objects.popup_check_mail&mail_id=add_offer_meet.employee_emails1&names=add_offer_meet.employee_names1','list');"></span>
                                </div> 
                            </div>
                        </div> 
                        <div class="form-group">
                            <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='57480.Başlık'>*</label>
                            <div class="col col-8 col-md-8 col-sm-8 col-xs-12" id="item-opp_head">
                                <textarea type="text" name="opp_head" id="opp_head" maxlength="100" value=""></textarea>                             
                            </div>
                        </div>                                              
                    </div>       
                    <div class="col col-6 col-md-6 col-sm-6 col-xs-12" index="2">                        
                        <div class="form-group" id="item-commethod_id">
                            <label class="col col-4 col-md-4 col-xs-12"><cf_get_lang dictionary_id='58090.İletişim Yöntemi'></label>
                            <div class="col col-8 col-md-12 col-xs-12">
                                <select name="commethod_id" id="commethod_id">
                                    <option value="0"><cf_get_lang dictionary_id='58090.İletişim Yöntemi'></option>
                                    <cfloop query="get_commethod_cats">
                                        <option value="#commethod_id#">#commethod#</option>
                                    </cfloop>
                                </select>
                            </div>
                        </div>
                        <div class="form-group" id="item-plus_date">
                            <label class="col col-4 col-md-4 col-xs-12"><cf_get_lang dictionary_id='57742.Tarih'>*</label>
                            <div class="col col-8 col-md-12 col-xs-12">
                                <div class="input-group">
                                    <input type="text" name="plus_date" id="plus_date"  value="<cfif isdefined('attributes.plus_date')>#attributes.plus_date#<cfelse>#dateformat(now(),dateformat_style)#</cfif>">
                                    <span class="input-group-addon"><cf_wrk_date_image date_field="plus_date"></span>
                                </div> 
                            </div>
                        </div>
                        <div class="form-group" id="item-pursuit_templates">
                            <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='41012.Şablon Seçiniz'></label>
                            <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                                <select name="pursuit_templates" id="pursuit_templates" onchange="changePursuit()" >
                                    <option value="-1"><cf_get_lang dictionary_id='41012.Şablon Seçiniz'></option>
                                    <cfloop query="get_pursuit_templates">
                                        <option value="#template_id#"<cfif isDefined("attributes.pursuit_templates") and (attributes.pursuit_templates eq template_id)> selected</cfif>>#template_head#</option>
                                    </cfloop>
                                </select>
                            </div> 
                        </div>
                    </div>
                    <div class="col col-12 col-md-12 col-sm-12 col-xs-12" index="3">                         	
                        <cfif listfindnocase(employee_url,'#cgi.http_host#',';')>
                            <div class="col col-12 col-md-12 col-sm-12 col-xs-12">
                                <cfmodule
                                    template="/fckeditor/fckeditor.cfm"
                                    toolbarset="Basic"
                                    basepath="/fckeditor/"
                                    instancename="plus_content"
                                    valign="top"
                                    value=""
                                    width="750"
                                    height="250">
                            </div>
                        <cfelseif listfindnocase(partner_url,'#cgi.http_host#',';')>
                            <div class="col col-12 col-md-12 col-sm-12 col-xs-12">
                                <cfmodule
                                    template="/fckeditor/fckeditor.cfm"
                                    toolbarset="WRKContent"
                                    basepath="/fckeditor/"
                                    instancename="plus_content"
                                    valign="top"
                                    value=""
                                    width="750"
                                    height="250">
                            </div>
                        </cfif>
                    </div>
                    <div class="col col-12 col-md-12 col-sm-12 col-xs-12" index="4">
                        <cfif xml_is_agenda eq 1> 
                            <div class="form-group col col-3" id="item-is_agenda">    
                                <div class="col col-8 col-md-8 col-xs-12"><cf_get_lang dictionary_id='41424.Ajandada Göster'>
                                    <input type="checkbox" name="is_agenda" id="is_agenda" value="1" />
                                </div> 
                            </div>                         
                            <div class="form-group col col-9" id="item-response_date">
                                <div class="col col-4 col-md-4 col-sm-5 col-xs-12" id="item-response_date"> 
                                    <div class="input-group">
                                        <cfinput type="text" name="response_date" id="response_date" validate="#validate_style#" message="#getLang('','Tarih Alanı Boş Olmamalıdır',45761)#" required="yes" maxlength="10" value="#dateformat(now(), dateformat_style)#">
                                        <span class="input-group-addon"><cf_wrk_date_image date_field="response_date"></span>
                                    </div>
                                </div>
                                <div class="col col-2 col-md-2 col-sm-2 col-xs-12" id="item-response_clock">
                                    <cf_wrkTimeFormat name="response_clock" value="0">
                                </div>
                                <div class="col col-2 col-md-2 col-sm-2 col-xs-12" id="item-response_min">         
                                    <select name="response_min" id="response_min">
                                        <cfloop from="0" to="55" index="a" step="5">
                                        <cfoutput><option value="#Numberformat(a,00)#">#Numberformat(a,00)#</option></cfoutput>
                                        </cfloop>			  
                                    </select>
                                </div> 
                            </div>
                            <cfset attributes.act = 'sales.add_opp_plus'>
                            <input type="hidden" name="url_link" id="url_link" value="#request.self#?fuseaction=#attributes.act#">        
                        </cfif> 
                    </div>
                </cf_box_elements>
            </cfoutput>
            <cf_box_footer >
                <cf_workcube_buttons is_upd='0' insert_info='#getLang('','Kaydet ve Mail Gönder',38496)#' is_cancel='0' add_function="control()" insert_alert=''>
                <cf_workcube_buttons is_upd='0' add_function="control_()">
            </cf_box_footer>
        </cfform>
    </cf_box>
</div>

<script type="text/javascript">
    <cfif isdefined ("attributes.header")>
        document.add_offer_meet.opp_head.value = <cfif isdefined('attributes.draggable')>document<cfelse>window.opener.document</cfif>.<cfoutput>#attributes.header#</cfoutput>.value;
    </cfif>
    function changePursuit(){
        <cfif isdefined('attributes.draggable')>
            document.add_offer_meet.action = '<cfoutput>#request.self#</cfoutput>?fuseaction=sales.popup_form_add_opp_plus';
            loadPopupBox('add_offer_meet','<cfoutput>#attributes.modal_id#</cfoutput>');
        <cfelse>
            document.add_offer_meet.action = ''; document.add_offer_meet.submit();
        </cfif>
    }

    <cfset attributes.pursuit_template_id = -1>
	<cfif isDefined("attributes.pursuit_templates")>
		<cfset attributes.pursuit_template_id = attributes.pursuit_templates>
	</cfif>
	<cfinclude template="../query/get_pursuit_templates.cfm">	
	document.all.plus_content.value = '<cfoutput>#GET_PURSUIT_TEMPLATES.TEMPLATE_CONTENT#</cfoutput>'; 

	function control()
	{
		document.add_offer_meet.email.value='true';
		var mailKontrol = document.add_offer_meet.employee_emails.value;
		if (((mailKontrol == '') || (mailKontrol.indexOf('@') == -1) || (mailKontrol.indexOf('.') == -1) || (mailKontrol.length < 6)) && (document.add_offer_meet.email.value == 'true'))
		{ 
			alert("<cf_get_lang dictionary_id='58484.Lütfen geçerli bir e-mail adresi giriniz'>");
			return false;
		}	
        <cfif isdefined('attributes.draggable')>
            loadPopupBox('add_offer_meet','<cfoutput>#attributes.modal_id#</cfoutput>');
            return false;
        <cfelse>
            document.add_offer_meet.action = "<cfoutput>#request.self#</cfoutput>?fuseaction=sales.emptypopup_add_opp_plus";
            return true;
        </cfif>		  
	}
    function control_()
	{
		fix_date(document.add_offer_meet.plus_date, 'Tarih');		  
		<cfif isdefined('attributes.draggable')>
            loadPopupBox('add_offer_meet','<cfoutput>#attributes.modal_id#</cfoutput>');
            return false;
        <cfelse>
            return true;
        </cfif>	
	}
</script>
