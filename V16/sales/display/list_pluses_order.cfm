<cf_get_lang_set module_name="sales">
<cfset ORDER_ID = attributes.ORDER_ID>
<cfquery name="get_order_detail" datasource="#DSN3#">
	SELECT CONSUMER_ID,PARTNER_ID,ORDER_HEAD,COMPANY_ID FROM ORDERS WHERE ORDER_ID = #ORDER_ID#
</cfquery>
<cfif len(get_order_detail.partner_id)>
  <cfset contact_id = get_order_detail.partner_id>
  <cfset contact_type = "p">
<cfelseif len(get_order_detail.COMPANY_ID)>
  <cfset contact_id = get_order_detail.COMPANY_ID>
  <cfset contact_type = "comp">
<cfelseif len(get_order_detail.consumer_id)>
  <cfset contact_id = get_order_detail.consumer_id>
  <cfset contact_type = "c">
</cfif>
<cfinclude template="../../objects/query/get_account_simple.cfm">
<cf_box title="#getLang('sales',62)#"  add_href="windowopen('#request.self#?fuseaction=#listgetat(attributes.fuseaction,1,'.')#.popup_form_add_order_plus&order_ID=#order_ID#&header=detail_order.order_head&contact_mail=#get_account_simple.email#&contact_person=#get_account_simple.name# #get_account_simple.surname#','list');" >
    <form name="detail_order"><input type="hidden" value="<cfoutput>#get_order_detail.order_head#</cfoutput>" name="order_head" id="order_head"></form>
    <cfinclude template="../query/get_order_pluses.cfm">
    <cf_flat_list>
        <cfif get_order_pluses.recordcount>
            <thead>
                <th><cf_get_lang dictionary_id='58820.Başlık'></th>
                <th width="30"><a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=#listgetat(attributes.fuseaction,1,'.')#.popup_form_add_order_plus&order_ID=#order_ID#&header=detail_order.order_head&contact_mail=#get_account_simple.email#&contact_person=#get_account_simple.name# #get_account_simple.surname#</cfoutput>','list');"><i class="fa fa-plus"></i></a></th>
            </thead>
            <cfoutput query="get_order_pluses">  
            <tbody>
                <tr>
                    <td width="100%"><cfif len(plus_subject)><a href="javascript://" onclick="windowopen('#request.self#?fuseaction=#listgetat(attributes.fuseaction,1,'.')#.popup_form_upd_order_plus&order_plus_ID=#order_plus_ID#','list');">#plus_subject#<cfelse><cf_get_lang dictionary_id='58820.Başlık'></cfif></td>
                    <td width="15"><a href="javascript://" onclick="windowopen('#request.self#?fuseaction=#listgetat(attributes.fuseaction,1,'.')#.popup_form_upd_order_plus&order_plus_ID=#order_plus_ID#','list');"><i class="fa fa-pencil"></i></a></td>
                </tr>
            <!---  <tr class="nohover"> 
                    <td height="50" colspan="2">
                        <b><cf_get_lang_main no='330.tarih'>:</b> #dateformat(plus_date,dateformat_style)#
                        <cfif len(employee_id)>
                            <b>&nbsp;&nbsp;<cf_get_lang_main no='157.görevli'>:</b> 
                            #get_emp_info(employee_id,0,0)#
                        </cfif>
                        <cfif len(commethod_id)>
                            &nbsp;&nbsp; <b><cf_get_lang_main no='731.iletişim'>:</b> 
                            <cfset attributes.commethod_id = commethod_id>
                            <cfinclude template="../query/get_commethod.cfm">
                            #get_commethod.commethod#<br/>
                        </cfif>
                        <br/><br/>
                        #plus_content#
                    </td>
                </tr> --->
            </tbody>
            </cfoutput>
        <cfelse>
            <tbody>
                <tr> 
                    <td><cf_get_lang dictionary_id='58486.Kayıt Bulunamadı'>!</td>
                </tr>	
            </tbody>
        </cfif>
    </cf_flat_list>
</cf_box>
    <table width="100%" align="center">
        <tr>
            <td><cf_get_workcube_asset company_id="#session.ep.company_id#" asset_cat_id="-12" module_id='11' action_section='ORDER_ID' action_id='#attributes.ORDER_ID#'></td>
        </tr>
    </table>
<cf_get_lang_set module_name="#lcase(listgetat(attributes.fuseaction,1,'.'))#">
