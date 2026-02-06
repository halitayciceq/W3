<cfset xfa.upd = "#listgetat(attributes.fuseaction,1,'.')#.popup_upd_order_plus">
<cfinclude template="../query/get_commethod_cats.cfm">
<cfinclude template="../query/get_order_plus.cfm">
<cf_get_lang_set module_name="sales">
<cf_popup_box title="#getLang('sales',114)#"><!---takip--->
<cfform name="upd_order_meet" method="post" action="#request.self#?fuseaction=#xfa.upd#">
<input type="Hidden" name="order_plus_id" id="order_plus_id" value="<cfoutput>#order_plus_id#</cfoutput>">
<input type="hidden" name="employee_id" id="employee_id" value="<cfoutput>#get_order_plus.employee_id#</cfoutput>">
<table>
    <tr>
    	<td width="35"><cf_get_lang_main no='1666.Mail'></td>
        <td>
			<cfif len(get_order_plus.employee_id)>
                <cfset attributes.employee_id = get_order_plus.employee_id>
                <cfinclude template="../query/get_employee_name.cfm">
                <input type="text" name="employee" id="employee" style="width:150px;" value="<cfoutput>#get_employee_name.EMPLOYEE_EMAIL#</cfoutput>">
            <cfelse>
                <input type="text" name="employee" id="employee" style="width:150px;" value="">
            </cfif>
        </td>
        <td>        
            <a href="javascript://" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_positions&field_emp_id=upd_order_meet.employee_id&field_emp_mail=upd_order_meet.employee','list');"><img src="/images/plus_thin.gif"  align="absmiddle" border="0"></a> 
            <cfsavecontent variable="alert"><cf_get_lang_main no ='327.Lütfen Bitiş Tarihini Giriniz'></cfsavecontent>
            <cfinput type="text" name="plus_date" style="width:85px;" value="#dateformat(get_order_plus.plus_date,dateformat_style)#" validate="#validate_style#" message="#alert#">
            <cf_wrk_date_image date_field="plus_date">
            <select name="commethod_id" id="commethod_id">
                <option value="0"><cf_get_lang_main no='731.İletişim'></option>
                <cfoutput query="get_commethod_cats">
                <option value="#commethod_id#" <cfif get_order_plus.commethod_id eq commethod_id>selected</cfif>>#commethod#</option>
                </cfoutput>
            </select>
        </td>
    </tr>
</table>
<table>
    <tr>
        <td><cf_get_lang_main no='68.Başlık'></td>
        <td><input type="text" name="opp_head" id="opp_head" style="width:455px;"  value="<cfoutput>#get_order_plus.PLUS_SUBJECT#</cfoutput>"></td>
    </tr>	  
    <tr> 
        <cfif listfindnocase(employee_url,'#cgi.http_host#',';')>
            <td colspan="2">
            <cfmodule
            template="/fckeditor/fckeditor.cfm"
            toolbarset="WRKContent"
            basepath="/fckeditor/"
            instancename="plus_content"
            value="#get_order_plus.plus_content#"
            width="660"
            height="300">
            </td>
        <cfelseif listfindnocase(partner_url,'#cgi.http_host#',';')>  
            <td colspan="2">
            <cfmodule
            template="/fckeditor/fckeditor.cfm"
            toolbarset="WRKContent"
            basepath="/fckeditor/"
            instancename="plus_content"
            value="#get_order_plus.plus_content#"
            width="580"
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
        add_function="(upd_order_meet.action.value+='&email=true')" 
        insert_alert=''>
    <cf_workcube_buttons 
        is_upd='1' 
        delete_page_url='#request.self#?fuseaction=sales.popup_del_order_plus&ORDER_PLUS_ID=#order_plus_id#'>
</cf_popup_box_footer>
</cfform>
</cf_popup_box> 
<script type="text/javascript">
	 
	 function control(){
		 
		 var aaa = document.upd_order_meet.employee.value;		 
		 if (((aaa == '') || (aaa.indexOf('@') == -1) || (aaa.indexOf('.') == -1) || (aaa.length < 6)) && (document.upd_order_meet.action.value += '&email=true'))
		 { 
				   alert("<cf_get_lang_main no='1072.Lütfen geçerli bir e-mail adresi giriniz'>");
				   document.upd_order_meet.action = "<cfoutput>#request.self#?fuseaction=#xfa.upd#</cfoutput>";
				   return false;
		 }			  
		 return true;
	 }	 

</script>
<cf_get_lang_set module_name="#lcase(listgetat(attributes.fuseaction,1,'.'))#">
