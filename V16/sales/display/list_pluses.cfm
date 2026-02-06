<cfset OFFER_ID = attributes.OFFER_ID>
<cfquery name="get_offer" datasource="#DSN3#">
	SELECT CONSUMER_ID,PARTNER_ID,EMPLOYEE_ID,COMPANY_ID,OFFER_TO_PARTNER,OFFER_HEAD, PROJECT_ID  FROM OFFER WHERE OFFER_ID = #OFFER_ID#
</cfquery>
<cfparam name="attributes.modal_id" default="">
<cfif len(get_offer.consumer_id)>
  <cfset contact_type = "c">
  <cfset contact_id = get_offer.consumer_id>
<cfelseif len(get_offer.partner_id)>
  <cfset contact_type = "p">
  <cfset contact_id = get_offer.partner_id>
<cfelseif len(get_offer.COMPANY_ID)>
  <cfset contact_type = "comp">
  <cfset contact_id = get_offer.COMPANY_ID>
<cfelseif len(get_offer.EMPLOYEE_ID)>
  <cfset contact_type = "e">
  <cfset contact_id = get_offer.EMPLOYEE_ID>
<cfelseif len(listsort(get_offer.OFFER_TO_PARTNER,"numeric"))>
  <cfset contact_type = "p">
  <cfset contact_id = listfirst(listsort(get_offer.OFFER_TO_PARTNER,"numeric"))>
</cfif>
<cfinclude template="../../objects/query/get_account_simple.cfm">
<cf_box title="#getLang('','Takipler',57325)#"popup_box="#iif(isdefined("attributes.draggable"),1,0)#">
    <form name="upd_offer_product">
        <input type="hidden" value="<cfoutput>#get_offer.offer_head#</cfoutput>" name="offer_head" id="offer_head">
    </form>
    <cf_flat_list>
        <cfinclude template="../query/get_offer_pluses.cfm">
        <thead>
            <tr>
                <th><cf_get_lang dictionary_id='49309.Takip'></th>
                <th style="text-align:center" width="15"><a href="javascript://" onClick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=sales.popup_form_add_offer_plus&offer_id=#offer_id#&header=upd_offer_product.offer_head&contact_mail=#get_account_simple.email#&contact_person=#get_account_simple.name# #get_account_simple.surname#</cfoutput>');"><i class="fa fa-plus"></i></a></th>
            </tr>
        </thead>
        <cfif get_offer_pluses.recordcount> 
            <tbody>
                <cfoutput query="get_offer_pluses">
                <tr>
                    <td><cfif len(subject)>#subject#<cfelse><cf_get_lang dictionary_id='58820.Başlık'></cfif></td>
                    <td style="text-align:center" width="15"><a href="javascript://" onclick="openBoxDraggable('#request.self#?fuseaction=sales.popup_form_upd_offer_plus&Offer_plus_ID=#Offer_plus_ID#');"><i class="fa fa-pencil"></i></a></td>
                </tr>
                <tr class="nohover"> 
                    <td colspan="2">
                        <b><cf_get_lang dictionary_id='57742.Tarih'>:</b> #dateformat(plus_date,dateformat_style)#
                        <cfif len(employee_id)>
                        <b>&nbsp;&nbsp;<cf_get_lang dictionary_id='57569.Görevli'>:</b> 
                        #get_emp_info(employee_id,0,0)#</cfif>
                        <cfif len(commethod_id)>
                        &nbsp;&nbsp; <b><cf_get_lang dictionary_id='58143.İletişim'>:</b> 
                        <cfset attributes.commethod_id = commethod_id>
                        <cfinclude template="../query/get_commethod.cfm">
                        #get_commethod.commethod#<br/>
                        </cfif>
                        <br/><br/>
                        #plus_content#
                    </td>
                </tr>
            </tbody>
            </cfoutput>
        <cfelse>
            <tbody>
                <tr> 
                    <td colspan="2"><cf_get_lang dictionary_id='58486.Kayıt Bulunamadı'>!</td>
                </tr>
            </tbody>
        </cfif>
	</cf_flat_list>
   
</cf_box>

