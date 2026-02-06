<cfinclude template="../query/get_info_plus_detail.cfm">
<cfif GET_LABELS.RECORDCOUNT>
        <table border="0" cellspacing="1" cellpadding="2" width="100%" height="100%" class="color-border">
          <tr height="35" class="color-list">
            <td class="headbold">
				<cfswitch expression="#type_id#">
					<cfcase value="-7"><cf_get_lang_main no='199.Sipariş'></cfcase>
					<cfcase value="-9"><cf_get_lang_main no='133.Teklif'></cfcase>
				</cfswitch>
				<cf_get_lang no='256.Ek Bilgiler'>
			</td>
          </tr>
          <tr>
            <td class="color-row" valign="top">
              <cfif GET_VALUES.recordcount>
                <cfset send_par="upd_info_plus_act">
                <cfelse>
                <cfset send_par="add_info_plus_act">
              </cfif>
              <cfform action="#request.self#?fuseaction=sales.#send_par#" method="post">
                <table>
                  <cfif type_id eq -9>
					  <input type="hidden" name="offer_id" id="offer_id" value="<cfoutput>#attributes.offer_id#</cfoutput>">
					  <input type="hidden" name="type_id" id="type_id" value="-9">
				  <cfelseif type_id eq -7>
					  <input type="hidden" name="order_id" id="order_id" value="<cfoutput>#attributes.order_id#</cfoutput>">
					  <input type="hidden" name="type_id" id="type_id" value="-7">
				  </cfif>
                  <cfloop index="i" from="1" to="7">
                    <tr>
                      <td width="100">
                        <cfif len(Evaluate("GET_LABELS.PROPERTY#i#_NAME"))>
                          <cfoutput>#Evaluate("GET_LABELS.PROPERTY#i#_NAME")#</cfoutput>
                        </cfif>
						
                      </td>
                      <td width="175">
                        <cfif len(Evaluate("GET_LABELS.PROPERTY#i#_NAME"))>
                          <input type="text" name="<cfoutput>PROPERTY#i#</cfoutput>" id="<cfoutput>PROPERTY#i#</cfoutput>" <cfif GET_VALUES.recordcount >value="<cfoutput>#Evaluate("GET_VALUES.PROPERTY#i#")#</cfoutput>"</cfif> style="width=150;">
                        </cfif>
                      </td>
                      <td width="100">
                        <cfset j=i+7>
                        <cfif len(Evaluate("GET_LABELS.PROPERTY#j#_NAME"))>
                          <cfoutput>#Evaluate("GET_LABELS.PROPERTY#j#_NAME")#</cfoutput>
                        </cfif>
                      </td>
                      <td>
                        <cfif len(Evaluate("GET_LABELS.PROPERTY#j#_NAME"))>
                          <input type="text" name="<cfoutput>PROPERTY#j#</cfoutput>" id="<cfoutput>PROPERTY#j#</cfoutput>" <cfif GET_VALUES.recordcount >value="<cfoutput>#Evaluate("GET_VALUES.PROPERTY#j#")#</cfoutput>"</cfif>  style="width=150;"  >
                        </cfif>
                      </td>
                    </tr>
                  </cfloop>
                  <cfloop index="i" from="0" to="4" step="2">
                    <tr>
                      <td>
                        <cfset st = i+15>
                        <cfif len(Evaluate("GET_LABELS.PROPERTY#st#_NAME"))>
                          <cfoutput>#Evaluate("GET_LABELS.PROPERTY#st#_NAME")#</cfoutput>
                        </cfif>
                      </td>
                      <td>
                        <cfif len(Evaluate("GET_LABELS.PROPERTY#st#_NAME"))> 
                          <textarea name="<cfoutput>PROPERTY#st#</cfoutput>" id="<cfoutput>PROPERTY#st#</cfoutput>" style="width=150;height=50;"><cfif GET_VALUES.recordcount ><cfoutput>#Evaluate("GET_VALUES.PROPERTY#st#")#</cfoutput></cfif></textarea>
                         </cfif> 
                      </td>
                      <td>
  						<cfset j = i+15+1>
                       <cfset j=st+1>
                        <cfif len(Evaluate("GET_LABELS.PROPERTY#j#_NAME")) >
                          <cfoutput>#Evaluate("GET_LABELS.PROPERTY#j#_NAME")#</cfoutput>
                         </cfif> 
                      </td>
                      <td>
					  
                        <cfif len(Evaluate("GET_LABELS.PROPERTY#j#_NAME")) > 
                          <textarea name="<cfoutput>PROPERTY#j#</cfoutput>" id="<cfoutput>PROPERTY#j#</cfoutput>" style="width=150;height=50;"><cfif GET_VALUES.recordcount ><cfoutput>#Evaluate("GET_VALUES.PROPERTY#j#")#</cfoutput></cfif></textarea>
                         </cfif> 
                      </td>
                    </tr>
                  </cfloop>
                  <tr>
                    <td colspan="4" style="text-align:right;"> <cf_workcube_buttons is_upd='0'> </td>
                  </tr>
                </table>
              </cfform>
            </td>
          </tr>
        </table>
  <cfelse>
        <table border="0" cellspacing="1" cellpadding="2" width="100%" height="100%" class="color-border">
          <tr height="35" class="color-list">
            <td class="headbold">
				<cfswitch expression="#type_id#">
					<cfcase value="-7"><cf_get_lang_main no='199.Sipariş'></cfcase>
					<cfcase value="-9"><cf_get_lang_main no='133.Teklif'></cfcase>
				</cfswitch>
				<cf_get_lang no='256.Ek Bilgiler'>
			</td>
          </tr>
          <tr>
            <td class="color-row" valign="top">
              <table>
                <tr>
                  <td>Ayarlar Modulunden Ek Bilgi Detaylarını Doldurunuz</td>
                </tr>
                <tr>
                  <td>
                    <input type="button" value="<cf_get_lang_main no='141.Kapat'>" onClick="window.close();" style="width:65px;">
                  </td>
                </tr>
              </table>
      </td>
    </tr>
  </table>
</cfif>
