<table>
  <tr>
    <td><input type="hidden" name="price" id="price" ><cf_get_lang_main no='68.Başlık'></td>
    <td colspan="3">
	<cfsavecontent variable="message"><cf_get_lang_main no='647.Başlık girmelisiniz'></cfsavecontent>
	<cfinput type="text" name="offer_head" style="width:377px;"  value="#get_offer.offer_head#" required="Yes" message="#message#"></td>
    <td>
	<cfoutput>#get_offer.offer_number#</cfoutput>
	<cfif get_offer.offer_currency neq -2>
	</td>
    <td>
	<input type="checkbox" name="offer_status" id="offer_status" value="1" <cfif get_offer.offer_status eq 1>checked</cfif>>
	<cf_get_lang_main no='81.aktif'> 
	</td></cfif>
	
  </tr>
  <tr>
    <td width="60"><cf_get_lang_main no='246.üye'>*</td>
    <td>
		<input type="hidden" name="consumer_id" id="consumer_id" value="<cfoutput>#get_offer.consumer_id#</cfoutput>">	
		<cfif len(get_offer.consumer_id)>
			<input type="hidden" name="member_type" id="member_type" value="consumer">
			<input type="hidden" name="member_id" id="member_id" value="<cfoutput>#get_offer.consumer_id#</cfoutput>">
			<input type="text" name="consumer" id="consumer" value="<cfoutput>#trim(get_cons_info(get_offer.consumer_id,0,0))#</cfoutput>" style="width:130px;" readonly>
		<cfelseif len(get_offer.OFFER_TO_PARTNER)>
			<input type="hidden" name="member_type" id="member_type" value="partner">
			<input type="hidden" name="member_id" id="member_id" value="<cfoutput>#contact_id#</cfoutput>">
			<input type="text" name="consumer" id="consumer" value="<cfoutput>#trim(get_par_info(contact_id,0,-1,0))#</cfoutput>" style="width:130px;" readonly>
		</cfif>
		<cfset str_linkeait="&field_paymethod_id=form_basket.paymethod_id&field_paymethod=form_basket.paymethod&field_basket_due_value=form_basket.basket_due_value">		
		<a href="javascript://" onClick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_cons&field_id=upd_offer_product.member_id&field_name=upd_offer_product.consumer&field_type=upd_offer_product.member_type&field_consumer=form_basket.consumer_id<cfoutput>#str_linkeait#</cfoutput>&select_list=1,2,3,5,6','list');">
		<img src="/images/plus_thin.gif"  align="absmiddle" border="0"></a>
	</td>
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
	  </cfif> <a href="javascript://" onClick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_paymethods&field_id=upd_offer_product.paymethod_id&field_name=upd_offer_product.paymethod','list');"><img src="/images/plus_thin.gif"  align="absmiddle" border="0"></a>
	</td>
    <td width="60"><cf_get_lang_main no='217.açıklama'></td>
    <td rowspan="4" valign="top"><TEXTAREA style="width:150px;height:70px;" name="offer_detail" id="offer_detail"><cfoutput>#get_offer.offer_detail#</cfoutput></TEXTAREA>
    </td>
  </tr>
  <tr>
    <td><cf_get_lang_main no='233.teslim'></td>
    <td>
	<cfsavecontent variable="message"><cf_get_lang no='185.teslim girmelisiniz'></cfsavecontent>
	<cfinput type="text" name="deliverdate" style="width:130px;"  value="#dateformat(get_offer.deliverdate,dateformat_style)#" validate="#validate_style#" message="#message#">
    <cf_wrk_date_image date_field="deliverdate">
	</td>
    <td><cf_get_lang_main no='1349.Sevk'></td>
    <td width="160">
	<input type="hidden" name="ship_method_id" id="ship_method_id" value="<cfoutput>#get_offer.SHIP_METHOD#</cfoutput>">
      <cfif len(get_offer.SHIP_METHOD)>
        <cfset attributes.ship_method=get_offer.SHIP_METHOD>
        <cfinclude template="../query/get_ship_method.cfm">
      </cfif>
      <input type="text" name="ship_method_name" id="ship_method_name" style="width:130px;" value="<cfif len(get_offer.SHIP_METHOD)><cfoutput>#GET_SHIP_METHOD.SHIP_METHOD#</cfoutput></cfif>" >
	</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td><cf_get_lang_main no='70.Aşama'></td>
    <td>
	<select name="offer_currency" id="offer_currency" style="width:130px;">
    <cfoutput query="get_offer_currencies">
    <option value="#offer_currency_id#" <cfif get_offer.offer_currency eq offer_currency_id>selected</cfif>>#offer_currency# </cfoutput>
    </select>
	</td>
    <td><cf_get_lang_main no='4.proje'></td>
    <td>
	<input type="hidden" name="project_id" id="project_id"  value="<cfoutput>#get_offer.PROJECT_ID#</cfoutput>" >
    <input type="text" name="project_head" id="project_head" style="width:130px;"  value="<cfif len(get_offer.PROJECT_ID)><cfoutput>#GET_PROJECT_NAME(get_offer.PROJECT_ID)#</cfoutput></cfif>" readonly>
    <a href="javascript://" onClick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_projects&project_id=upd_offer_product.project_id&project_head=upd_offer_product.project_head');"><img src="/images/plus_thin.gif"  align="absmiddle" border="0"></a>
	</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <!--- <td><cf_get_lang_main no='88.onay'></td>
    <td>
	<cfif get_offer.is_processed eq 1>
		<cf_get_lang no='139.işlendi'>
	</cfif>
	<cfif len(get_offer.valid_par)>
		<cfif get_offer.valid_par eq 1> <cf_get_lang_main no='88.onay'> -
		<cfelseif get_offer.valid_par eq 0> <cf_get_lang_main no='1740.red'> - 
		</cfif>
	<cfoutput>#get_par_info(get_offer.valid_par_id,0,-1,0)# - #dateformat(date_add('h',session.ep.time_zone,get_offer.valid_par_date),dateformat_style)# (#timeformat(date_add('h',session.ep.time_zone,get_offer.valid_par_date),timeformat_style)#)</cfoutput>
	</cfif>
	</td> --->
    <TD>Sevk Tarihi</TD>
	<TD>
	<cfsavecontent variable="message">Sevk Tarihi Girmelisiniz!</cfsavecontent>
	<cfinput type="text" name="ship_date" style="width:125px;"  value="#dateformat(get_offer.ship_date,dateformat_style)#" validate="#validate_style#" message="#message#" maxlength="10">
	<cf_wrk_date_image date_field="ship_date">
	</TD>	
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td height="20" colspan="6" class="txtbold">
	<cf_get_lang_main no='71.Kayit'> : 
    <cfoutput>#get_par_info(get_offer.record_member,0,-1,0)# - #dateformat(date_add('h',session.ep.time_zone,get_offer.record_date),dateformat_style)#</cfoutput>
	</td>
  </tr>
</table>

