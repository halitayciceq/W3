<table width="98%" border="0" align="center" cellpadding="0" cellspacing="0">
  <tr>
    <td class="headbold" height="35"><cf_get_lang dictionary_id='34992.Proje Harcamaları'> / <cf_get_lang dictionary_id ='58089.Gelirler'></td>
  </tr>
</table>
	<cfinclude template="list_expense_item_project.cfm">
	<br/>
<!--- <cfquery name="get_upd_purchase" datasource="#DSN2#">
	SELECT 
		COMPANY_ID, 
		PARTNER_ID, 
		CONSUMER_ID, 
		SHIP_NUMBER, 
		SHIP_DATE, 
		NETTOTAL,
		DELIVER_EMP
	FROM 
		SHIP 
	WHERE
		PROJECT_ID = #attributes.ID# AND
		SHIP_TYPE = 811
</cfquery>
<table cellSpacing="0" cellpadding="0" width="98%" border="0" align="center">
	<tr class="color-border">
		<td>
			<table cellspacing="1" cellpadding="2" width="100%" border="0">
				<tr class="color-header">
					<td class="form-title" colspan="5">İthal Mal Girişleri</td>
				</tr>
				<tr class="color-list" height="20">
					<td class="txtboldblue" width="25">No</td>
					<td class="txtboldblue" width="70">İrsaliye No</td>
					<td class="txtboldblue">Teslim Alan</td>
					<td class="txtboldblue">Tarih</td>
					<td class="txtboldblue" align="right">Tutar</td>
				</tr>
				<cfif get_upd_purchase.recordcount EQ 0>
				<tr class="color-row">
					<td colspan="5" height="20"><cf_get_lang dictionary_id='72.Kayıt Bulunamadı'>!</td>
				</tr>
				<cfelse>
				<cfoutput query="get_upd_purchase">
				<tr onMouseOver="this.className='color-light';" onMouseOut="this.className='color-row';" class="color-row">
					<td>#currentrow#</td>
					<td>#ship_number#</td>
					<td>#deliver_emp#</td>
					<td>#dateformat(SHIP_DATE,dateformat_style)#</td>
					<td align="right">#TLFormat(NETTOTAL)# #SESSION.EP.MONEY#</td>
				</tr>
				</cfoutput>
				</cfif>
			</table>
		</td>
	</tr>
</table>
<br/> --->
    <cfinclude template="../query/get_pro_time_cost.cfm">
	
    <cfscript>
    	alltotal=0;
    	time=0;
    	TOTAL_VALUE=0;
    	new_alltotal=0;
	</cfscript>
          <table cellspacing="1" cellpadding="2" width="98%" align="center" border="0" class="color-border">
            <tr class="color-header">
              <td  colspan="7" height="22" class="form-title"><cf_get_lang dictionary_id='38212.Proje Zaman Harcamaları'></td>
            </tr>
            <tr class="color-list" height="22">
              <td width="25" class="txtboldblue"><cf_get_lang dictionary_id='57487.No'></td>
              <td class="txtboldblue"><cf_get_lang dictionary_id='57629.Açıklama'></td>
              <td class="txtboldblue" width="100"><cf_get_lang dictionary_id='57569.Görevli'></td>
              <td class="txtboldblue" width="55"><cf_get_lang dictionary_id='57742.Tarih'></td>
              <td width="45" align="right" class="txtboldblue" style="text-align:right;"><cf_get_lang dictionary_id='57491.Saat'></td>
              <td width="100" align="right" class="txtboldblue" style="text-align:right;"><cf_get_lang dictionary_id='57673.Tutar'></td>
            </tr>
            <cfif get_pro_time_cost.RecordCount EQ 0>
              <tr class="color-row">
                <td colspan="7" height="20"><cf_get_lang dictionary_id='57484.Kayıt Bulunamadı'>!</td>
              </tr>
              <cfelse>
              <cfoutput query="get_pro_time_cost" >
               <tr onMouseOver="this.className='color-light';" onMouseOut="this.className='color-row';" class="color-row">
                  <td>#get_pro_time_cost.CurrentRow#</td>
                  <td>#WORK_HEAD#</td>
                  <td>
                   <!---   <cfif len(EMP_ID) and EMP_ID gt 0>
						  <cfquery name="GET_EMP" datasource="#dsn#">
							  SELECT 
								  EMPLOYEE_NAME, 
								  EMPLOYEE_SURNAME 
							  FROM 
								  EMPLOYEE_POSITIONS
							  WHERE 
								EMPLOYEE_ID=#EMP_ID#
						  </cfquery>
						 #get_emp.EMPLOYEE_NAME#&nbsp;#get_emp.EMPLOYEE_SURNAME# --->
                    <cfif len(OUTSRC_PARTNER_ID) and OUTSRC_PARTNER_ID gt 0>
                      <cfquery name="GET_PAR" datasource="#dsn#">
						  SELECT 
							  COMPANY_PARTNER_NAME, 
							  COMPANY_PARTNER_SURNAME 
						  FROM
							  COMPANY_PARTNER 
						  WHERE 
							  PARTNER_ID=#OUTSRC_PARTNER_ID#
                      </cfquery>
                      bbb#get_par.COMPANY_PARTNER_NAME#&nbsp;#get_par.COMPANY_PARTNER_SURNAME#
					<cfelseif len(EMPLOYEE_ID)>
						<cfquery name="GET_EMP_NAME" datasource="#dsn#">
							SELECT 
								EMPLOYEE_NAME, 
								EMPLOYEE_SURNAME 
							FROM 
								EMPLOYEE_POSITIONS
							WHERE 
								EMPLOYEE_ID = #EMPLOYEE_ID#
						</cfquery>
						#GET_EMP_NAME.EMPLOYEE_NAME#&nbsp;#GET_EMP_NAME.EMPLOYEE_SURNAME#
                    </cfif>
                  </td>
                  <td>#dateformat(EVENT_DATE,dateformat_style)#</td>
                  <td align="right" style="text-align:right;">
				  	<cfset totalminute = total_time mod 60>
					<cfset totalhour = (total_time-totalminute)/60>
					#totalhour#:#totalminute#
				  </td>
                  <td align="right" style="text-align:right;">
					  <cfset our_budget = TOTAL_VALUE>
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
						#TLFormat(our_budget)# #session.ep.money#
						<cfset new_alltotal=new_alltotal+our_budget>
						<cfset time = time + int(TOTAL_TIME)>
				  </td>
                </tr>
              </cfoutput>
            </cfif>
            <tr class="color-list">
              <td colspan="4"  align="right" style="text-align:right;"><cf_get_lang dictionary_id='57492.Toplam'></td>
              <td  align="right" style="text-align:right;">
			  <cfoutput>
			  	<cfset total_minute = time mod 60>
				<cfset total_hour = (time-total_minute)/60>
				#total_hour#:#total_minute#
			  </cfoutput>
			  </td>
              <td align="right" style="text-align:right;"> <cfoutput>#TLFormat(new_alltotal)# #session.ep.money#</cfoutput></td>
            </tr>
          </table>
<br/>

