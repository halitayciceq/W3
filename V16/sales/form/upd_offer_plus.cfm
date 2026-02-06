<cfinclude template="../query/get_commethod_cats.cfm">
<cfinclude template="../query/get_offer_plus.cfm">
<cfparam name="attributes.offer_id" default="">
<cf_box title="#getLang('sales',114)#" add_href="#request.self#?fuseaction=sales.popup_form_add_offer_plus&offer_id=#attributes.offer_id#"><!---takip--->
    <cfform name="upd_offer_meet" method="post" action="#request.self#?fuseaction=sales.popup_upd_offer_plus">
        <input type="Hidden" ID="clicked" name="clicked" value="">
        <input type="Hidden" name="offer_plus_id" id="offer_plus_id" value="<cfoutput>#offer_plus_id#</cfoutput>">
        <cf_box_elements>
            <div class="col col-6 col-md-6 col-sm-6 col-xs-12" type="column" index="1" sort="true">
                <div class="form-group" id="item-employee_names">
                    <div class="col col-12 col-md-12 col-sm-12 col-xs-12">
                        <div class="input-group">
                            <input type="hidden" name="employee_id" id="employee_id" value="<cfoutput>#get_offer_plus.employee_id#</cfoutput>">
                            <cfinput type="hidden" name="employee_emails" id="employee_emails" value="#get_offer_plus.mail_sender#">
                            <cfif Len(get_offer_plus.employee_id)>
                                <cfset attributes.employee_id = get_offer_plus.employee_id>
                                <cfinclude template="../query/get_employee_name.cfm">
                                <input type="text" name="employee" id="employee"  value="<cfoutput>#get_offer_plus.mail_sender#</cfoutput>">
                            <cfelse>
                                <input type="text" name="employee" id="employee"  value="">
                            </cfif>
                            <span class="input-group-addon btnPointer icon-ellipsis" href="javascript://"onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_check_mail&mail_id=upd_offer_meet.employee_emails&names=upd_offer_meet.employee','list');"></span>
                        </div>
                    </div>
                </div>     
                <div class="form-group" id="item-employee_names">
                    <div class="col col-12 col-md-12 col-sm-12 col-xs-12">        
                        <div class="input-group">  
                            <cfsavecontent variable="alert"><cf_get_lang dictionary_id='541.Tarih Değerini Kontrol Ediniz.'></cfsavecontent>  
                            <cfinput type="text" name="plus_date" value="#dateformat(get_offer_plus.plus_date,dateformat_style)#" validate="#validate_style#" message="#alert#">
                            <span class="input-group-addon"><cf_wrk_date_image date_field="plus_date"></span>
                        </div>
                    </div>
                </div>      
            </div>
            <div class="col col-6 col-md-6 col-sm-6 col-xs-12" type="column" index="2" sort="true">
                <div class="form-group" id="item-commethod_id">
                    <select name="commethod_id" id="commethod_id">
                        <option value="0"><cf_get_lang dictionary_id='58143.İletişim'></option>
                        <cfoutput query="get_commethod_cats">
                        <option value="#commethod_id#" <cfif get_offer_plus.commethod_id eq commethod_id>selected</cfif>>#commethod#</option>
                        </cfoutput>
                    </select>
                </div>
                <div class="form-group" id="item-opp_head">
                    <input type="text" name="opp_head" id="opp_head" style="width:455px;" placeholder="<cfoutput>#getLang('main',68)#</cfoutput>" value="<cfif isdefined("get_offer_plus.subject")><cfoutput>#get_offer_plus.subject#</cfoutput></cfif>">
                </div>
            </div>
            <div class="col col-12 col-md-12 col-sm-12 col-xs-12" type="column" index="3" sort="true">        <cfset tr_topic = get_offer_plus.plus_content>
                <cfif listfindnocase(employee_url,'#cgi.http_host#',';')>
                    <div class="form-group" id="item-plus_content">
                        <cfmodule
                        template="/fckeditor/fckeditor.cfm"
                        toolbarSet="WRKContent"
                        basePath="/fckeditor/"
                        instanceName="plus_content"
                        valign="top"
                        value="#tr_topic#"
                        width="575"
                        height="300">
                    </div>
                <cfelseif listfindnocase(partner_url,'#cgi.http_host#',';')>  
                    <div class="form-group" id="item-plus_content">
                        <cfmodule
                        template="/fckeditor/fckeditor.cfm"
                        toolbarSet="WRKContent"
                        basePath="/fckeditor/"
                        instanceName="plus_content"
                        valign="top"
                        value="#tr_topic#"
                        width="575"
                        height="300">
                    </div>
                </cfif>					
            </div>
        </cf_box_elements>
        <cf_box_footer>
            <cfsavecontent variable="message"><cf_get_lang dictionary_id='49265.Güncelle ve Mail Gönder'></cfsavecontent>
            <cf_workcube_buttons 
                is_upd='0'
                insert_info='#message#'
                is_cancel='0'
                add_function="control()"
                insert_alert=''>                
            <cf_workcube_buttons 
                is_upd='1' 
                delete_page_url='#request.self#?fuseaction=sales.emptypopup_del_offer_plus&OFFER_PLUS_ID=#offer_plus_id#'>
        </cf_box_footer>
    </cfform>
</cf_box>
<script type="text/javascript">
	 
	 function control(){
		 
		 document.upd_offer_meet.clicked.value='&email=true';
		 document.upd_offer_meet.action = document.upd_offer_meet.action + document.upd_offer_meet.clicked.value;
		 
		 var aaa = document.upd_offer_meet.employee.value;		 
		 if (((aaa == '') || (aaa.indexOf('@') == -1) || (aaa.indexOf('.') == -1) || (aaa.length < 6)) && (document.upd_offer_meet.clicked.value == '&email=true'))
		 { 
				   alert('Lütfen mail alanına geçerli bir mail giriniz!!');
				   document.upd_offer_meet.action = "<cfoutput>#request.self#?fuseaction=sales.popup_upd_offer_plus</cfoutput>";
				   return false;
		 }			  
		 return true;
	 }	 

</script>          
