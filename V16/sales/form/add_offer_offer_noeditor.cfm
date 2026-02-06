<table>
  <tr>
  <!--- <input type="hidden" name="price"> ---><!--- ayarlanacak sepet çakışması --->
    <td width="60"><cf_get_lang_main no='68.Başlık'>*</td>
    <td colspan="3">
	<cfsavecontent variable="message"><cf_get_lang_main no='647.Başlık girmelisiniz'></cfsavecontent>
	<cfinput type="text" name="offer_head" style="width:358px;" maxlength="100" value="#get_offer.offer_head#" required="Yes" message="#message#"></td>
    <td><cf_get_lang_main no='70.Aşama'></td>
    <td><select name="offer_currency" id="offer_currency" style="width:150px;">
      <cfoutput query="get_offer_currencies">
      <option value="#offer_currency_id#" <cfif get_offer.offer_currency eq offer_currency_id>selected</cfif>>#offer_currency# </cfoutput>
        </select></td>
  </tr>
  <tr>
    <td><cf_get_lang_main no='45.üye'></td>
    <td width="160">
		<cfif len(get_offer.consumer_id)>
			<cfset contact_type = "c">
			<input type="hidden" name="consumer_id" id="consumer_id" value="<cfoutput>#get_offer.consumer_id#</cfoutput>">
			<input type="hidden" name="member_type" id="member_type" value="consumer">
			<input type="hidden" name="member_id" id="member_id" value="<cfoutput>#get_offer.consumer_id#</cfoutput>">
			<input type="Text" name="consumer" id="consumer" value="<cfoutput>#trim(get_cons_info(get_offer.consumer_id,0,0))#</cfoutput>" style="width:125px;" readonly>
		<cfelseif len(get_offer.OFFER_TO_PARTNER)>
			<cfset contact_type = "p">
			<cfset contact_id = listsort(get_offer.OFFER_TO_PARTNER,'Numeric')>
			  <input type="hidden" name="consumer_id" id="consumer_id" value="">
			<input type="hidden" name="member_type" id="member_type" value="partner">
			<input type="hidden" name="member_id" id="member_id" value="<cfoutput>#contact_id#</cfoutput>">
			<input type="text" name="consumer" id="consumer" value="<cfoutput>#trim(get_par_info(contact_id,0,-1,0))#</cfoutput>" style="width:125px;" readonly>
	    </cfif>
		<cfset str_linkeait = "&field_paymethod_id=form_basket.paymethod_id&field_paymethod=form_basket.paymethod&field_basket_due_value=form_basket.basket_due_value">
		<a href="javascript://" onClick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_cons&field_id=form_basket.member_id&field_name=form_basket.consumer&field_type=form_basket.member_type&field_consumer=form_basket.consumer_id<cfoutput>#str_linkeait#</cfoutput>','list');">
		<img src="/images/plus_thin.gif"  align="absmiddle" border="0"></a>
	</td>
    <td width="60"><cf_get_lang no='111.gonderi t'></td>
    <td width="160">
	<cfsavecontent variable="message"><cf_get_lang no='187.gonderi tarihi girmelisiniz'></cfsavecontent>
	<cfinput type="text" name="deliverdate" style="width:130px;"  value="#dateformat(get_offer.deliverdate,dateformat_style)#" validate="#validate_style#" message="#message#">
    <cf_wrk_date_image date_field="deliverdate"></td>
    <td width="60"><cf_get_lang_main no='217.açıklam'></td>
    <td rowspan="4">
		<textarea name="offer_detail" id="offer_detail" style="width:150px;height:90px;"><cfoutput>#get_offer.offer_detail#</cfoutput></textarea>
	</td>
  </tr>
  <tr>
    <td><cf_get_lang no='101.satış çalışan'></td>
    <td><input type="hidden" name="SALES_EMP_ID" id="SALES_EMP_ID" value="<cfoutput>#get_offer.SALES_EMP_ID#</cfoutput>">
      <cfif len(get_offer.SALES_EMP_ID)>
        <input type="text" name="sales_emp" id="sales_emp" style="width:125px;" value="<cfoutput>#get_emp_info(get_offer.SALES_EMP_ID,0,0)#</cfoutput>">
        <cfelse>
        <input type="text" name="sales_emp" id="sales_emp" style="width:125px;" value="">
      </cfif>
    <a href="javascript://" onClick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_positions&field_code=form_basket.SALES_EMP_ID&field_name=form_basket.sales_emp','list');"><img src="/images/plus_thin.gif" align="absmiddle" border="0"></a> </td>
    <td><cf_get_lang no='104.geçerlilik'></td>
    <td>
	<cfsavecontent variable="message"><cf_get_lang no='186.geçerlilik girmelisiniz'></cfsavecontent>
	<cfinput type="text" name="finishdate" style="width:130px;"  value="#dateformat(get_offer.finishdate,dateformat_style)#" validate="#validate_style#" message="#message#">
    <cf_wrk_date_image date_field="finishdate"> </td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td><cf_get_lang no='102.satış ortağı'></td>
    <td><input type="hidden" name="sales_partner_id" id="sales_partner_id" value="<cfoutput>#get_offer.sales_partner_id#</cfoutput>">
      <cfif len(get_offer.sales_partner_id)>
        <input type="text" name="sales_partner" id="sales_partner" style="width:125px;" value="<cfoutput>#get_par_info(get_offer.sales_partner_id,0,-1,0)#</cfoutput>">
        <cfelse>
        <input type="text" name="sales_partner" id="sales_partner" style="width:125px;" value="">
      </cfif>
    <a href="javascript://" onClick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_pars&field_id=form_basket.sales_partner_id&field_name=form_basket.sales_partner','list');"><img src="/images/plus_thin.gif"  align="absmiddle" border="0"></a> </td>
    <td><cf_get_lang_main no='435.ödeme'></td>
    <td>
		<cfif len(get_offer.paymethod)>
			<cfset attributes.paymethod_id = get_offer.paymethod>
			<cfinclude template="../query/get_paymethod.cfm">
			<input name="basket_due_value" id="basket_due_value" type="hidden" value="<cfoutput>#get_paymethod.DUE_DAY#</cfoutput>">
			<input type="hidden" name="paymethod_id" id="paymethod_id" value="<cfoutput>#get_offer.paymethod#</cfoutput>">
			<input type="text" name="paymethod" id="paymethod" style="width:130px;"  value="<cfoutput>#get_paymethod.paymethod#</cfoutput>" readonly>
		<cfelse>
			<input name="basket_due_value" id="basket_due_value" type="hidden" value="">
			<input type="hidden" name="paymethod_id" id="paymethod_id" value="">
			<input type="text" name="paymethod" id="paymethod" style="width:130px;"  value="" readonly>
		</cfif>
		<a href="javascript://" onClick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_paymethods&field_id=form_basket.paymethod_id&field_name=form_basket.paymethod','list');"><img src="/images/plus_thin.gif"  align="absmiddle" border="0"></a>
	</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td><cf_get_lang_main no='4.proje'></td>
    <td><input type="hidden" name="project_id" id="project_id" value="<cfoutput>#get_offer.PROJECT_ID#</cfoutput>" >
      <input type="text" name="project_head" id="project_head" style="width:130px;"  value="<cfif len(get_offer.PROJECT_ID)><cfoutput>#GET_PROJECT_NAME(get_offer.PROJECT_ID)#</cfoutput></cfif>" readonly>
      <a href="javascript://" onClick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_projects&project_id=form_basket.project_id&project_head=form_basket.project_head');"><img src="/images/plus_thin.gif"  align="absmiddle" border="0"></a></td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td><cf_get_lang_main no='1682.yayin'></td>
    <td><input type="checkbox" name="is_public_zone" id="is_public_zone" value="checkbox"><cf_get_lang no='45.public'>
  	<input type="checkbox" name="is_partner_zone" id="is_partner_zone" value="checkbox"><cf_get_lang_main no='1473.Partner'></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td height="35" colspan="6" align="right" style="text-align:right;"><cf_workcube_buttons is_upd='0' add_function='check()'></td>
  </tr>
</table>
