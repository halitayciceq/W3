<cfinclude template="../query/get_commethod_cats.cfm">
<cf_box title="#getLang('sales',114)#"popup_box="#iif(isdefined("attributes.draggable"),1,0)#">
    <cfform name="add_offer_meet" method="post" action="#request.self#?fuseaction=sales.popup_add_offer_plus">
        <input type="Hidden" name="offer_id" id="offer_id" value="<cfoutput>#offer_id#</cfoutput>">
        <input type="Hidden" ID="clicked" name="clicked" value="">
        <cf_box_elements>
            <div class="col col-6 col-md-6 col-sm-6 col-xs-12" type="column" index="1" sort="true">
                <div class="form-group" id="item-employee_names">
                    <div class="col col-12 col-md-12 col-sm-12 col-xs-12">
                        <div class="input-group">
                            <input type="hidden" name="employee_id" id="employee_id" value="">
                            <input type="hidden" name="employee_emails" id="employee_emails" value="">
                            <input type="text" name="employee_names" id="employee_names"  value="" placeholder="<cfoutput>#getLang('main',1361)#</cfoutput>">
                            <span class="input-group-addon btnPointer icon-ellipsis" href="javascript://" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_check_mail&mail_id=add_offer_meet.employee_emails&names=add_offer_meet.employee_names','list');"></span>
                        </div>
                    </div>
                </div>     
                <div class="form-group" id="item-employee_names">
                    <div class="col col-12 col-md-12 col-sm-12 col-xs-12">        
                        <div class="input-group">    
                            <cfsavecontent variable="alert"><cf_get_lang dictionary_id='541.Tarih Değerini Kontrol Ediniz.'></cfsavecontent>
                            <cfinput type="text" name="plus_date" style="width:95px;" value="#dateformat(now(),dateformat_style)#" validate="#validate_style#" message="#alert#">
                            <span class="input-group-addon"><cf_wrk_date_image date_field="plus_date"></span>
                        </div>
                    </div>
                </div>      
            </div>
            <div class="col col-6 col-md-6 col-sm-6 col-xs-12" type="column" index="1" sort="true">
                <div class="form-group" id="item-commethod_id">
                    <select name="commethod_id" id="commethod_id" >
                        <option value="0"><cf_get_lang dictionary_id='58143.İletişim'></option>
                        <cfoutput query="get_commethod_cats">
                        <option value="#commethod_id#">#commethod#</option>
                        </cfoutput>
                    </select>
                </div>
            
                <div class="form-group" id="item-opp_head">
                    <input type="text" name="opp_head" id="opp_head" style="width:325px;"  value="" placeholder="<cfoutput>#getLang('main',68)#</cfoutput>">
                </div>
                <div class="form-group" id="item-pursuit_templates">
                    <cfinclude template="../query/get_pursuit_templates.cfm">
                    <select name="pursuit_templates" id="pursuit_templates" onChange="document.add_offer_meet.action = '';document.add_offer_meet.submit();">
                        <cfoutput query="GET_PURSUIT_TEMPLATES">
                        <option value="#TEMPLATE_ID#"<cfif isDefined("attributes.pursuit_templates") and (attributes.pursuit_templates eq TEMPLATE_ID)> selected</cfif>>#TEMPLATE_HEAD#</option>
                        </cfoutput>
                    </select>
                </div>
            </div>
            <div class="col col-12 col-md-12 col-sm-12 col-xs-12" type="column" index="3" sort="true">
                <div class="form-group" id="item-plus_content">
                    <cfif listfindnocase(employee_url,'#cgi.http_host#',';')>
                            <cfmodule
                            template="/fckeditor/fckeditor.cfm"
                            toolbarSet="WRKContent"
                            basePath="/fckeditor/"
                            instanceName="plus_content"
                            valign="top"
                            value=""
                            width="550"
                            height="300">
                        </div>
                        <div class="form-group" id="item-plus_content">        
                    <cfelseif listfindnocase(partner_url,'#cgi.http_host#',';')>  
                            <cfmodule
                            template="/fckeditor/fckeditor.cfm"
                            toolbarSet="WRKContent"
                            basePath="/fckeditor/"
                            instanceName="plus_content"
                            valign="top"
                            value=""
                            width="550"
                            height="300">
                        </div>
                    </cfif>	
                </div>
            </div>
        </cf_box_elements>
        <cf_box_footer>
            <cfsavecontent variable="message"><cf_get_lang dictionary_id='55410.Kaydet ve Mail gönder'></cfsavecontent>
            <cf_workcube_buttons is_upd='0' insert_info='#message#' is_cancel='0' add_function="control()" insert_alert=''>
            <cf_workcube_buttons is_upd='0'>
        </cf_box_footer>
    </cfform>
</cf_box>                   
<cfif isdefined("header")>
    <script type="text/javascript">
       
       document.add_offer_meet.opp_head.value = window.opener.<cfoutput>#attributes.header#</cfoutput>.value;
       document.add_offer_meet.employee_id.value = '<cfoutput>#Session.ep.userid#</cfoutput>';
       
       function control(){
       
           document.add_offer_meet.clicked.value='&email=true';
           document.add_offer_meet.action = "<cfoutput>#request.self#?fuseaction=sales.popup_add_offer_plus</cfoutput>" + document.add_offer_meet.clicked.value;	 
           
           var aaa = document.add_offer_meet.employee_names.value;
           if (((aaa == '') || (aaa.indexOf('@') == -1) || (aaa.indexOf('.') == -1) || (aaa.length < 6)) && (document.add_offer_meet.clicked.value == '&email=true'))
           { 
                     alert("<cf_get_lang dictionary_id='64270.Lütfen geçerli bir e-mail adresi giriniz'>");
                     document.add_offer_meet.action = "<cfoutput>#request.self#?fuseaction=sales.popup_add_offer_plus</cfoutput>";  
                     return false;
           }				  
           
           return true;
       }	 
       
      <cfset attributes.pursuit_template_id = -1>
      <cfif isDefined("attributes.pursuit_templates")>
          <cfset attributes.pursuit_template_id = attributes.pursuit_templates>
      </cfif>
      <cfinclude template="../query/get_pursuit_templates.cfm">	
      document.all.plus_content.value = '<cfoutput>#GET_PURSUIT_TEMPLATES.TEMPLATE_CONTENT#</cfoutput>';	 
      </script>
  </cfif>
