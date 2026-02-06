<cfinclude template="../query/get_commethod_cats.cfm">
<cfinclude template="../query/get_opp_plus.cfm">
<cf_xml_page_edit fuseact ="sales.popup_form_add_opp_plus">
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
<cfform name="upd_offer_meet" method="post" action="#request.self#?fuseaction=sales.emptypopup_upd_opp_plus">
    <cf_box id="upd_offer_meet" title="#getLang('sales',114)#" popup_box="#iif(isdefined("attributes.draggable"),1,0)#"><!---takip--->
        <cfinput type="Hidden" name="clicked" id="clicked" value="">
        <cfinput type="Hidden" id="modal_id" name="modal_id" value="#attributes.modal_id#">
        <input type="Hidden" name="opp_plus_id" id="opp_plus_id" value="<cfoutput>#opp_plus_id#</cfoutput>">
        <cf_box_elements>
            <cfoutput>
                <div class="col col-6 col-md-6 col-sm-6 col-xs-12" index="1">
                    <div class="form-group" id="item-employee_emails">
                        <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='57428.E-posta'>*</label>
                        <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                            <div class="input-group">
                                <input type="hidden" name="employee_id" id="employee_id" value="#get_opp_plus.employee_id#">
                                <input type="text" name="employee_emails" id="employee_emails" value="#get_opp_plus.mail_sender#">
                                <input type="hidden" name="employee_names" id="employee_names" value="">
                                <span class="input-group-addon btnPointer icon-ellipsis"  onclick="windowopen('#request.self#?fuseaction=objects.popup_check_mail&mail_id=upd_offer_meet.employee_emails&names=upd_offer_meet.employee_names','list');"></span>
                            </div>
                        </div>
                    </div>
                    <div class="form-group" id="item-employee_emails1">
                        <label class="col col-4 col-md-4 col-sm-4 col-xs-12">CC</label>
                        <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                            <div class="input-group">
                                <input type="hidden" name="employee_id1" id="employee_id1" value="<cfif isdefined('attributes.contact_id') and Len(attributes.contact_id)>#attributes.contact_id#</cfif>">
                                <input type="text" name="employee_emails1" id="employee_emails1" value="#get_opp_plus.mail_cc#">
                                <input type="hidden" name="employee_names1" id="employee_names1" value="">
                                <span class="input-group-addon btnPointer icon-ellipsis" onclick="windowopen('#request.self#?fuseaction=objects.popup_check_mail&mail_id=upd_offer_meet.employee_emails1&names=upd_offer_meet.employee_names1','list');"></span>
                            </div>
                        </div>
                    </div>
                    <div class="form-group" id="item-opp_head">
                        <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='57480.Konu'></label>
                        <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                            <textarea type="text" name="opp_head" id="opp_head" maxlength="100" ><cfoutput>#get_opp_plus.plus_subject#</cfoutput></textarea>
                        </div>
                    </div>                    
                </div>  
                 <div class="col col-6 col-md-6 col-sm-6 col-xs-12" index="2">                    
                    <div class="form-group" id="item-commethod_id">
                        <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='58090.İletişim Yöntemi'></label>
                        <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                            <select name="commethod_id" id="commethod_id">
                                <option value="0"><cf_get_lang dictionary_id='58090.İletişim Yöntemi'></option>
                                <cfloop query="get_commethod_cats">
                                    <option value="#commethod_id#" <cfif get_opp_plus.commethod_id eq commethod_id>selected</cfif>>#commethod#</option>
                                </cfloop>
                            </select>
                        </div>
                    </div>
                    <div class="form-group" id="item-plus_date">
                        <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='57742.Tarih'>*</label>
                        <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                            <div class="input-group">
                                <cfsavecontent variable="alert"><cf_get_lang_main no ='330.Tarih'></cfsavecontent>
                                <cfinput type="text" name="plus_date" value="#dateformat(get_opp_plus.plus_date,dateformat_style)#" validate="#validate_style#" maxlength="10" message="#alert#">
                                <span class="input-group-addon"><cf_wrk_date_image date_field="plus_date"></span>
                            </div>
                        </div>
                    </div>
                </div> 
                <div class="col col-12 col-md-12 col-sm-12 col-xs-12" index="3">
                    <cfset tr_topic = get_opp_plus.plus_content>
                    <cfif listfindnocase(employee_url,'#cgi.http_host#',';')>
                        <div class="colspan = 2">
                            <cfmodule
                            template="/fckeditor/fckeditor.cfm"
                            toolbarSet="WRKContent"
                            basePath="/fckeditor/"
                            instanceName="plus_content"
                            valign="top"
                            width="400"
                            value="#tr_topic#"
                            height="300">
                        </div>
                    <cfelseif listfindnocase(partner_url,'#cgi.http_host#',';')>  
                        <div class="colspan = 2">
                            <cfmodule
                            template="/fckeditor/fckeditor.cfm"
                            toolbarSet="WRKContent"
                            basePath="/fckeditor/"
                            instanceName="plus_content"
                            valign="top"
                            value="#tr_topic#"
                            width="400"
                            height="300">
                        </div>
                    </cfif>
                </div>    
                
            </cfoutput>
            
        </cf_box_elements>
        <cf_box_footer>
            <cfsavecontent variable="message"><cf_get_lang dictionary_id='35884.Güncelle ve Mail Gönder'></cfsavecontent>
            <cf_workcube_buttons is_upd='0' insert_info='#message#' is_cancel='0' add_function="control()" insert_alert=''>
            <cf_workcube_buttons is_upd='1' delete_page_url='#request.self#?fuseaction=sales.emptypopup_del_opp_plus&opp_plus_id=#opp_plus_id#' add_function="control_()">
        </cf_box_footer>
    </cf_box>
</cfform>
</div>
<script type="text/javascript">
	function control()
	{
		document.upd_offer_meet.clicked.value='&email=true';		 
		document.upd_offer_meet.action = document.upd_offer_meet.action + document.upd_offer_meet.clicked.value;
		var aaa = document.upd_offer_meet.employee_emails.value;		 
		if (((aaa == '') || (aaa.indexOf('@') == -1) || (aaa.indexOf('.') == -1) || (aaa.length < 6)) && (document.upd_offer_meet.clicked.value == '&email=true'))
		{ 
			alert("<cf_get_lang_main no='1072.Lütfen geçerli bir e-mail adresi giriniz'>");
			document.upd_offer_meet.action = "<cfoutput>#request.self#?fuseaction=sales.emptypopup_upd_opp_plus</cfoutput>";
			return false;
		}			  
		<cfif isdefined('attributes.draggable')>
            loadPopupBox('upd_offer_meet','<cfoutput>#attributes.modal_id#</cfoutput>');
            return false;
        <cfelse>
            return true;
        </cfif>	
	}
    function control_()
	{
		fix_date(document.upd_offer_meet.plus_date, 'Tarih');		  
		<cfif isdefined('attributes.draggable')>
            loadPopupBox('upd_offer_meet','<cfoutput>#attributes.modal_id#</cfoutput>');
            return false;
        <cfelse>
            return true;
        </cfif>	
	}
</script>
