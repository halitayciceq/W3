<cfparam name="attributes.opp_status" default="1">
<cfinclude template="../query/get_opportunities.cfm">
<cfinclude template="../query/get_offer_list.cfm">
<cfinclude template="../query/get_order_list.cfm">
<cfparam name="attributes.maxrows" default='10'>
<table width="98%" border="0" cellspacing="0" cellpadding="0" align="center">
  <tr>
    <td class="headbold" height="35"><cf_get_lang_main no='36.Satış'></td>
  </tr>
</table>
<table width="98%" border="0" cellspacing="0" cellpadding="0" align="center">
  <tr>
    <td valign="top">
      <table border="0" width="100%" cellpadding="0" cellspacing="0" class="color-border">
        <tr>
          <td>
            <table border="0" width="100%" cellpadding="2" cellspacing="1">
              <tr class="color-header">
                <td class="form-title" height="22" colspan="7"><cf_get_lang_main no='1282.Firsatlar'></td>
              </tr>
              <tr class="color-list">
                <td class="txtboldblue" height="22" width="60" ><cf_get_lang_main no='75.no'></td>
                <td class="txtboldblue"><cf_get_lang_main no='68.Başlık'></td>
                <td class="txtboldblue" width="200"><cf_get_lang_main no='246.üye'></td>
				<td class="txtboldblue" width="150"><cf_get_lang no='101.satış çalışan'></td>
                <td class="txtboldblue" width="65"><cf_get_lang_main no='330.tarih'></td>
                <td class="txtboldblue" width="70"><cf_get_lang_main no='1240.olasılık'></td>
				<td width="15"><a href="<cfoutput>#request.self#</cfoutput>?fuseaction=sales.list_opportunity&event=add"><img src="/images/plus_list.gif" border="0"></a></td>
              </tr>
              <cfif get_opportunities.recordcount>
                <cfparam name="attributes.page" default=1>
                <cfset attributes.totalrecords = get_opportunities.recordcount>
                <cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
                <cfoutput query="get_opportunities" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
                 <tr height="20" onMouseOver="this.className='color-light';" onMouseOut="this.className='color-row';" class="color-row">
                    <td><a href="#request.self#?fuseaction=sales.form_opportunity&opp_id=#opp_id#" class="tableyazi">#OPP_NO#</a></td>
                    <td><a href="#request.self#?fuseaction=sales.form_opportunity&opp_id=#opp_id#" class="tableyazi">#opp_head#</a></td>
                    <td><cfif len(get_opportunities.partner_id)>
						#get_par_info(get_opportunities.partner_id,0,0,1)#
                      <cfelseif len(get_opportunities.company_id)>
                        #get_par_info(get_opportunities.company_id,1,1,1)#
                      <cfelseif len(get_opportunities.consumer_id)>
                        #get_cons_info(get_opportunities.consumer_id,0,1)#
                      </cfif></td>
                    <td>
				<cfif len(get_opportunities.sales_emp_id)>
                  #get_emp_info(get_opportunities.sales_emp_id,0,1)#
                </cfif>
					</td>
					<td><cfif len(opp_date)>
                        #dateformat(opp_date,dateformat_style)#
                        <cfelse>
                        #dateformat(date_add('h',session.ep.time_zone,record_date),dateformat_style)#
                      </cfif></td>
                    <td>&nbsp;% #probability#</td>
					<td><a href="#request.self#?fuseaction=sales.form_opportunity&opp_id=#opp_id#"><img src="/images/update_list.gif" border="0"></a></td>
                  </tr>
                </cfoutput>
                <cfelse>
                <tr class="color-row">
                  <td colspan="7" height="20"><cf_get_lang_main no='72.Kayıt Yok'> !</td>
                </tr>
              </cfif>
            </table>
          </td>
        </tr>
      </table>
      <br/>
      <table border="0" width="100%" cellpadding="0" cellspacing="0" class="color-border">
        <tr>
          <td>
            <table border="0" width="100%" cellpadding="2" cellspacing="1">
              <tr class="color-header">
                <td class="form-title" height="22" colspan="7"><cf_get_lang no='4.teklifler'></td>
              </tr>
              <tr class="color-list">
                <td class="txtboldblue"  width="60"><cf_get_lang_main no='75.no'></td>
                <td class="txtboldblue"><cf_get_lang_main no='68.Başlık'></td>
                <td class="txtboldblue" width="200"><cf_get_lang_main no='246.üye'></td>
				<td class="txtboldblue" width="150"><cf_get_lang no='101.satış çalışan'></td>
                <td class="txtboldblue" width="65" ><cf_get_lang_main no='330.tarih'></td>
                <td class="txtboldblue" width="70" ><cf_get_lang_main no='70.Aşama'></td>
				<td width="15"><a href="<cfoutput>#request.self#</cfoutput>?fuseaction=sales.form_add_offer"><img src="/images/plus_list.gif" border="0"></a></td>
              </tr>
              <cfif get_offer_list.recordcount>
                <cfparam name="attributes.page" default=1>
                <cfset attributes.totalrecords = get_offer_list.recordcount>
                <cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
                <cfoutput query="get_offer_list" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
                 <tr height="20" onMouseOver="this.className='color-light';" onMouseOut="this.className='color-row';" class="color-row">
                    <td height="20" width="50"><a href="#request.self#?fuseaction=sales.detail_offer<cfif offer_zone eq 1>_pta<cfelseif offer_zone eq 0>_tv</cfif>&offer_id=#offer_id#" class="tableyazi">#offer_number#</a></td>
                    <td><a href="#request.self#?fuseaction=sales.detail_offer<cfif offer_zone eq 1>_pta<cfelseif offer_zone eq 0>_tv</cfif>&offer_id=#OFFER_ID#" class="tableyazi">#offer_head#</a></td>
                    <td>
					  <cfif len(get_offer_list.consumer_id)>
						#get_cons_info(get_offer_list.consumer_id,0,1)#
                      <cfelseif len(get_offer_list.partner_id)>
						#get_par_info(get_offer_list.partner_id,0,0,1)#
                      <cfelseif len(get_offer_list.company_id)>
						#get_par_info(get_offer_list.company_id,1,1,1)#
                      </cfif>
					</td>
                    <td>
							<cfif len(get_offer_list.SALES_EMP_ID)>
							  #get_emp_info(get_offer_list.SALES_EMP_ID,0,1)#
							</cfif>
					</td>
				    <td>#dateformat(date_add('h',session.ep.time_zone,record_date),dateformat_style)#</td>
                    <td><cfif len(OFFER_CURRENCY) and (offer_currency gt 0)>
                        <cfset attributes.CURRENCY_ID = OFFER_CURRENCY>
                        <cfinclude template="../query/get_offer_currency.cfm">
                        #GET_OFFER_CURRENCY.OFFER_CURRENCY#
                        <cfelseif offer_currency lt 0>
                        <cfif offer_currency eq -1><cf_get_lang_main no='1305.açık'>
                          <cfelseif offer_currency eq -2><cf_get_lang no='34.tamam'>
                          <cfelseif offer_currency eq -3><cf_get_lang_main no='1740.red'>
                          <cfelseif offer_currency eq -4><cf_get_lang_main no='203.onay bekliyor'>
                        </cfif>
                      </cfif></td>
					  <td><a href="#request.self#?fuseaction=sales.detail_offer<cfif offer_zone eq 1>_pta<cfelseif offer_zone eq 0>_tv</cfif>&offer_id=#offer_id#"><img src="/images/update_list.gif" border="0"></a></td>
                  </tr>
                </cfoutput>
                <cfelse>
                <tr class="color-row">
                  <td colspan="7"><cf_get_lang_main no='72.Kayıt Yok'> !</td>
                </tr>
              </cfif>
            </table>
          </td>
        </tr>
      </table>
      <br/>
      <cfinclude template="../../product/query/high_sales_products.cfm">
	  <!---  _sil üstteki include da fazla sanırım <cfdump var="#HIGH_SALES_PRODUCTS#"> --->
      <table border="0" width="100%" cellpadding="0" cellspacing="0" class="color-border">
        <tr>
          <td>
            <table border="0" width="100%" cellpadding="2" cellspacing="1">
              <tr class="color-header">
                <td class="form-title" height="22" colspan="7" ><cf_get_lang no='6.siparişler'></td>
              </tr>
              <tr class="color-list">
                <td class="txtboldblue" height="22" width="60"><cf_get_lang_main no='75.no'></td>
                <td class="txtboldblue"><cf_get_lang_main no='68.Başlık'></td>
                <td class="txtboldblue" width="200"><cf_get_lang_main no='246.üye'></td>
				<td class="txtboldblue" width="150"><cf_get_lang no='101.satış çalışan'></td>
				<td class="txtboldblue" width="65"><cf_get_lang_main no='330.tarih'></td>
				<td width="15"><a href="<cfoutput>#request.self#</cfoutput>?fuseaction=sales.list_order&event=add"><img src="/images/plus_list.gif" border="0"></a></td>
              </tr>
              <cfif get_order_list.recordcount>
                <cfparam name="attributes.page" default=1>
                <cfset attributes.totalrecords = get_order_list.recordcount>
                <cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
                <cfoutput query="get_order_list" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
                <tr height="20" onMouseOver="this.className='color-light';" onMouseOut="this.className='color-row';" class="color-row">
                    <td  height="22">#ORDER_NUMBER#</td>
                    <td><a href="#request.self#?fuseaction=sales.list_order&event=upd&order_id=#ORDER_ID#" class="tableyazi">#order_head# </a></td>
                    <td>
						 <cfif len(get_order_list.partner_id)>
							  #get_par_info(get_order_list.partner_id,0,0,1)#
						<cfelseif len(get_order_list.company_id)>
							 #get_par_info(get_order_list.company_id,1,1,1)#							  
						  <cfelseif len(get_order_list.consumer_id)>
							 #get_cons_info(get_order_list.consumer_id,0,1)#
						 </cfif>
                     </td>                   
                     <td>
				<cfif len(get_order_list.order_employee_id)>
                  #get_emp_info(get_offer_list.order_employee_id,0,1)#
                </cfif>
					</td>
					<td>#dateformat(date_add('h',session.ep.time_zone,record_date),dateformat_style)#</td>
					  <td><a href="#request.self#?fuseaction=sales.list_order&event=upd&order_id=#order_id#"><img src="/images/update_list.gif" border="0"></a></td>
                  </tr>
                </cfoutput>
                <cfelse>
                <tr>
                  <td colspan="6" class="color-row"><cf_get_lang_main no='72.Kayıt Yok'> !</td>
                </tr>
              </cfif>
            </table>
          </td>
        </tr>
      </table>
    </td>
  </tr>
</table>
<br/>
