<cfinclude template="../query/get_pro_time_budget.cfm">
<cfset alltotal=0>
<cfset time=0>

      <table cellspacing="1" cellpadding="2" width="98%" border="0" class="color-border" align="center">
        <tr class="color-header">
          <td  colspan="7" height="22" class="form-title"><cf_get_lang dictionary_id='38221.Öngörülen İş Maliyetleri'></td>
        </tr>
        <tr class="color-list">
          <td width="25" height="22" class="txtboldblue"><cf_get_lang dictionary_id='57487.No'></td>
          <td class="txtboldblue">&nbsp;<cf_get_lang dictionary_id='38213.İş'></td>
          <td class="txtboldblue">&nbsp;<cf_get_lang dictionary_id='38188.Öngörülen Tutar'></td>
        </tr>
        <cfif get_works_budget.RecordCount EQ 0>
			  <tr class="color-row">
				<td colspan="8" height="20"><cf_get_lang dictionary_id='57484.Kayıt Bulunamadı'>!</td>
			  </tr>
        <cfelse>
          <cfoutput QUERY="get_works_budget" >
          <tr height="20" onMouseOver="this.className='color-light';" onMouseOut="this.className='color-row';" class="color-row">
              <td width="20" height="20" class="label">&nbsp;#get_works_budget.CurrentRow#</td>
              <td height="20">&nbsp;#WORK_HEAD#</td>
              <td height="20" align="right" style="text-align:right;"> 
			  <cfset our_budget=EXPECTED_BUDGET>
                <cfif LEN(EXPECTED_BUDGET)>
					<cfif LEN(EXPECTED_BUDGET_MONEY)>
						<cfquery name="get_money" datasource="#DSN#">
							SELECT
								*
							FROM
								SETUP_MONEY
							WHERE
								PERIOD_ID = #SESSION.EP.PERIOD_ID# AND
								MONEY='#EXPECTED_BUDGET_MONEY#'
						</cfquery>
						<cfif get_money.recordcount>
							<cfset our_budget=our_budget*get_money.RATE2/get_money.RATE1>
						<cfelse>
							<cfset our_budget=0>
						</cfif>
						
					</cfif>
                  <cfset alltotal=alltotal+our_budget>
                </cfif>
				&nbsp;#TLFormat(our_budget)# #SESSION.EP.MONEY# </td>
            </tr>
          </cfoutput>
        </cfif>
        <tr class="color-row">
          <td colspan="2" align="right" class="label" style="text-align:right;" >&nbsp;<cf_get_lang dictionary_id='57492.Toplam'>:</td>
          <td align="right" class="label" style="text-align:right;"> <cfoutput>#TLFormat(alltotal)# #SESSION.EP.MONEY#</cfoutput></td>
        </tr>
      </table>


