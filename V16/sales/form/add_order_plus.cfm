<cfset xfa.add = "sales.emptypopup_add_order_plus">
<cfinclude template="../query/get_commethod_cats.cfm">
<cf_get_lang_set module_name="sales">
<cf_popup_box title="#getLang('sales',114)#"><!---takip--->
<cfform name="add_order_meet" method="post" action="#request.self#?fuseaction=#xfa.add#">
<input type="Hidden" name="order_id" id="order_id" value="<cfoutput>#order_id#</cfoutput>">
<input type="Hidden" id="clicked" value="">
    <table>
        <tr>
        	<td width="42"><cf_get_lang_main no='1666.Mail'></td>
            <td>
                <input type="hidden" name="employee_id" id="employee_id" value="">
                <input type="hidden" name="employee_emails" id="employee_emails" value="">
                <input type="text" name="employee_names" id="employee_names" style="width:180px;" value="">
                <a href="javascript://" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_check_mail&mail_id=add_order_meet.employee_emails&names=add_order_meet.employee_names','list');"><img src="/images/plus_thin.gif"  align="absmiddle" border="0"></a>
                <cfsavecontent variable="alert"><cf_get_lang_main no ='370.Tarih Değerinizi Kontrol Ediniz'></cfsavecontent>
                <cfinput type="text" name="plus_date" style="width:85px;" value="#dateformat(now(),dateformat_style)#" validate="#validate_style#" message="#alert#">
                <cf_wrk_date_image date_field="plus_date">
                <select name="commethod_id" id="commethod_id">
                    <option value="0"><cf_get_lang_main no='63.İletişim'></option>
                    <cfoutput query="get_commethod_cats">
                    <option value="#commethod_id#">#commethod#</option>
                    </cfoutput>
                </select>
            </td>
        </tr>
    </table>	
    <table>
        <tr>
            <td><cf_get_lang_main no='68.Başlık'></td>
            <td>
                <input type="text" name="opp_head" id="opp_head" style="width:310px;"  value="">
                <cfinclude template="../query/get_pursuit_templates.cfm">
                <select name="pursuit_templates" id="pursuit_templates" onchange="document.add_order_meet.action = '';document.add_order_meet.submit();">
                    <option value="-1"><cf_get_lang no='210.Şablon Seçiniz'></option>
                    <cfoutput query="GET_PURSUIT_TEMPLATES">
                    <option value="#TEMPLATE_ID#"<cfif isDefined("attributes.pursuit_templates") and (attributes.pursuit_templates eq TEMPLATE_ID)> selected</cfif>>#TEMPLATE_HEAD#</option>
                    </cfoutput>
                </select>
            </td>
        </tr>	  
        <tr>
			<cfif listfindnocase(employee_url,'#cgi.http_host#',';')>
                <td colspan="2">
                 <cfmodule
                    template="/fckeditor/fckeditor.cfm"
                    toolbarset="WRKContent"
                    basepath="/fckeditor/"
                    instancename="plus_content"
                    valign="top"
                    value=""
                    width="660"
                    height="225">
                </td>
            <cfelseif listfindnocase(partner_url,'#cgi.http_host#',';')>  
            <td colspan="2">
                <cfmodule
                    template="/fckeditor/fckeditor.cfm"
                    toolbarset="WRKContent"
                    basepath="/fckeditor/"
                    instancename="plus_content"
                    valign="top"
                    value=""
                    width="550"
                    height="300">
        	</td>
            </cfif>	
        </tr>
    </table>
<cf_popup_box_footer>
    <cfsavecontent variable="message"><cf_get_lang no='9.Kaydet ve Mail Gönder'></cfsavecontent>
    <cf_workcube_buttons 
			  is_upd='0'
			  insert_info='#message#'
			  is_cancel='0'
			  add_function="control() && OnFormSubmit()" 
			  insert_alert=''> 
    <cf_workcube_buttons is_upd='0' add_function='OnFormSubmit()'>
</cf_popup_box_footer>
</cfform>
</cf_popup_box>

<script type="text/javascript">

     document.add_order_meet.opp_head.value = window.opener.<cfoutput>#header#</cfoutput>.value;
	 document.add_order_meet.employee_id.value = '<cfoutput>#Session.ep.userid#</cfoutput>';
	 
	 function control(){
	 
		 document.add_order_meet.clicked.value='&email=true';
		 document.add_order_meet.action = "<cfoutput>#request.self#?fuseaction=#xfa.add#</cfoutput>" + document.add_order_meet.clicked.value;	 

		 var aaa = document.add_order_meet.employee_names.value;
		 if (((aaa != '') && ((aaa.indexOf('@') == -1) || (aaa.indexOf('.') == -1) || (aaa.length < 6))) && (document.add_order_meet.clicked.value == '&email=true'))
		 { 
				   alert("<cf_get_lang_main no='1072.Lütfen geçerli bir e-mail adresi giriniz'>");
				   document.add_order_meet.action = "<cfoutput>#request.self#?fuseaction=#xfa.add#</cfoutput>"; 
				   return false;
		 }			  
		 
		 return true;
	 }	 
	 
	<cfset attributes.pursuit_template_id = -1>
	<cfif isDefined("attributes.pursuit_templates")>
		<cfset attributes.pursuit_template_id = attributes.pursuit_templates>
	</cfif>
	<cfinclude template="../query/get_pursuit_templates.cfm">	
	document.add_order_meet.plus_content.value = '<cfoutput>#GET_PURSUIT_TEMPLATES.TEMPLATE_CONTENT#</cfoutput>';	 
</script>
<cf_get_lang_set module_name="#lcase(listgetat(attributes.fuseaction,1,'.'))#">
