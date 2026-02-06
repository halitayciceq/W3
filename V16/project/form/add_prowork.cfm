<cfif not isDefined("URL.ID")>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='58797.Proje Seçiniz'>");
		window.close();
	</script>
	<cfabort>
<cfelse>
<cfquery name="GET_PROJECT" datasource="#dsn#">
	SELECT 
		PROJECT_ID,
		PROJECT_HEAD,
		COMPANY_ID,
		PARTNER_ID,
		TARGET_START,TARGET_FINISH 
	FROM 
		PRO_PROJECTS 
	WHERE 
		PRO_PROJECTS.PROJECT_ID=#URL.ID#
</cfquery>
	<cfinclude template="../query/get_pro_work_cat.cfm">
	<cfinclude template="../query/get_priority.cfm">
	<table cellspacing="0" cellpadding="0" border="0" height="100%" width="100%">
	<cfform name="add_work" method="post" action="#request.self#?fuseaction=project.emptypopup_add_pro_work&id=#url.id#">
    <tr class="color-border">
      <td valign="middle">
        <table cellspacing="1" cellpadding="2" border="0" width="100%" height="100%">
          <tr class="color-list" valign="middle">
            <td height="35">
              <table width="98%" align="center">
                <tr>
                  <td valign="bottom" class="headbold"><cf_get_lang dictionary_id='57933.İş Ekle'>: <cfoutput>#get_project.PROJECT_HEAD#</cfoutput> </td>
                </tr>
              </table>
            </td>
          </tr>
          <tr class="color-row" valign="top">
            <td>
              <table align="center" width="98%" cellpadding="0" cellspacing="0" border="0">
                <tr>
                  <td colspan="2"> <br/>
                    <input type="hidden" name="PROJECT_ID" id="PROJECT_ID" value="<cfoutput>#get_project.project_id#</cfoutput>">
                    <input type="hidden" name="PRO_H_START" id="PRO_H_START" value="<cfoutput>#get_project.TARGET_START#</cfoutput>">
                    <input type="hidden" name="PRO_H_FINISH" id="PRO_H_FINISH" value="<cfoutput>#get_project.TARGET_FINISH#</cfoutput>">
                    <input type="hidden" name="COMPANY_ID" id="COMPANY_ID" value="<cfoutput>#get_project.COMPANY_ID#</cfoutput>">
                    <input type="hidden" name="PARTNER_ID" id="PARTNER_ID" value="<cfoutput>#get_project.PARTNER_ID#</cfoutput>">
                    <table border="0" cellspacing="2" cellpadding="2" width="100%">
                      <tr>
                        <td width="130"><cf_get_lang dictionary_id="58859.Süreç"></td>
                        <td width="130"><cf_get_lang dictionary_id='57485.Öncelik'></td>
                        <td valign="top"><cf_get_lang dictionary_id='38187.İlişkili İş'></td>
                        <td valign="top">&nbsp;</td>
                      </tr>
                      <tr>
                        <td>
						  <cf_workcube_process is_upd='0' process_cat_width='130' is_detail='0'>
                        </td>
                        <td>
                          <select name="PRIORITY_CAT" id="PRIORITY_CAT" style="width:130px;">
                            <cfoutput query="get_cats">
                              <option value="#PRIORITY_ID#">#priority#</option>
                            </cfoutput>
                          </select>
                        </td>
                        <td>
							<input type="hidden" name="rel_work_id" id="rel_work_id" value="">
							<input type="text" name="rel_work" id="rel_work" style="width:255px;" value="<cf_get_lang dictionary_id='38187.İlişkili İş'>">
							<a href="javascript://" onClick="windowopen('<cfoutput>#request.self#?fuseaction=project.popup_add_relation&pro_id=#get_project.project_id#&w_id=add_work.rel_work_id&w_name=add_work.rel_work</cfoutput>','small');"><img src="/images/plus_list.gif" border="0" align="absmiddle"></a>
						</td>
                      </tr>
                    </table>
                  </td>
                </tr>
                <tr>
                  <td>
                    <table border="0" cellspacing="2" cellpadding="2">
                      <tr>
                        <td><cf_get_lang dictionary_id='57480.Başlık'>*</td>
                      </tr>
                      <tr>
                        <td><cfsavecontent variable="message"><cf_get_lang dictionary_id='58059.Başlık girmelisiniz'></cfsavecontent>
							<cfinput type="Text" name="WORK_HEAD" required="Yes" message="#message#" style="width:525px;" maxlength="100">
                        </td>
                      </tr>
                      <tr>
                        <td><cf_get_lang dictionary_id='57629.açıklama'></td>
                      </tr>
                      <tr>
                        <td><textarea name="WORK_DETAIL" id="WORK_DETAIL" style="width:525px;" rows="8"></textarea></td>
                      </tr>
                    </table>
                  </td>
                </tr>
                <tr>
                  <td>
                    <table border="0">
                      <tr>
                        <td width="85"><cf_get_lang dictionary_id='38175.Tahmini Bütçe'></td>
                        <td width="200">
                          <cfsavecontent variable="message"><cf_get_lang dictionary_id='38138.Tahmini Bütçe girmelisiniz'></cfsavecontent>
						  <cfinput type="text" validate="float" message="#message#" name="EXPECTED_BUDGET"  value="" style="width:125px;" passThrough="onkeyup=""return(FormatCurrency(this,event));""">
                          <select name="EXPECTED_BUDGET_MONEY" id="EXPECTED_BUDGET_MONEY" class="formselect" style="width:60px;">
                            <cfinclude template="../query/get_money_currency.cfm">
                            <cfoutput query="get_money">
                              <option value="#MONEY#">#MONEY#</option>
                            </cfoutput>
                          </select>
                        </td>
                        <td width="85"><cf_get_lang dictionary_id='58053.Başlangıç Tarihi'>*</td>
                        <td>
						<cfscript>
							sdate=date_add("h", session.ep.TIME_ZONE,get_project.TARGET_START);
							fdate=date_add("h", session.ep.TIME_ZONE,get_project.TARGET_FINISH);
							shour=datepart("h",sdate);
							fhour=datepart("h",fdate);
						</cfscript>
						<cfsavecontent variable="message"><cf_get_lang dictionary_id='57738.Başlangıç Tarihi girmelisiniz'></cfsavecontent>
						<cfinput required="Yes" validate="#validate_style#" message="#message#" type="text" name="WORK_H_START" value="#dateformat(sdate,dateformat_style)#" style="width:65px;">
                          <cf_wrk_date_image date_field="WORK_H_START"><cfoutput>
                            <select name="START_HOUR" id="START_HOUR">
                              <cfloop from="0" to="23" index="i">
                                <option value="#i#" <cfif i eq shour>selected</cfif>>#i#:00</option>
                              </cfloop>
                            </select>
                          </cfoutput>
						</td>
                      </tr>
                      <tr>
                        <td height="20"><cf_get_lang dictionary_id='38176.Tahmini Süre'></td>
                        <td>
						<cfsavecontent variable="message"><cf_get_lang dictionary_id='38136.Tahmini Süre girmelisiniz'></cfsavecontent>
						<cfinput type="text" name="ESTIMATED_TIME" validate="integer" message="#message#" style="width:125px;"><cf_get_lang dictionary_id='57491.Saat'></td>
                        <td><cf_get_lang dictionary_id='57700.Bitiş Tarihi'>*</td>
                        <td>
						<cfsavecontent variable="message"><cf_get_lang dictionary_id='57739.Bitiş Tarihi girmelisiniz'></cfsavecontent>
						<cfinput required="Yes" validate="#validate_style#" message="#message#" type="text" name="WORK_H_FINISH" value="#dateformat(fdate,dateformat_style)#" style="width:65px;">
                           <cf_wrk_date_image date_field="WORK_H_FINISH">
						  <cfoutput>
                            <select name="FINISH_HOUR" id="FINISH_HOUR">
                              <cfloop from="0" to="23" index="i">
                                <option value="#i#" <cfif i eq fhour>selected</cfif>>#i#:00</option>
                              </cfloop>
                            </select>
                          </cfoutput>
						</td>
                      </tr>
                      <tr>
                        <td><cf_get_lang dictionary_id='38177.İş Kategorisi'>*</td>
                        <td>
						  <select name="PRO_WORK_CAT" id="PRO_WORK_CAT" style="width:125px;">
                            <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'>
							<cfoutput query="get_work_cat">
                              <option value="#WORK_CAT_ID#">#work_cat#</option>
                            </cfoutput>
                          </select>
						</td>
                        <td><cf_get_lang dictionary_id='57569.Görevli'>*</td>
                        <td>
						<input type="hidden" name="PROJECT_EMP_ID" id="PROJECT_EMP_ID" value="">
						<input type="hidden" name="TASK_COMPANY_ID" id="TASK_COMPANY_ID" value="">
						<input type="hidden" name="TASK_PARTNER_ID" id="TASK_PARTNER_ID" value="">
						<cfsavecontent variable="message1"><cf_get_lang dictionary_id='38201.Görevli seçmelisiniz'></cfsavecontent>
						<cfinput type="text" name="responsable_name" required="yes" message="#message1#" value="" style="width:143px;" passThrough="readonly"> 
						<a href="javascript://" onClick="windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_list_positions&field_partner=add_work.TASK_PARTNER_ID&field_comp_id=add_work.TASK_COMPANY_ID&field_emp_id=add_work.PROJECT_EMP_ID&field_name=add_work.responsable_name&select_list=1,7</cfoutput>','list');"><img src="/images/plus_list.gif" title="<cf_get_lang dictionary_id='38201.Görevli Seç'>" border="0" align="absmiddle"></a>
						</td>
                      </tr>
                      <tr>
                        <td colspan="3" height="35"></td>
						<td><cf_workcube_buttons is_upd='0' add_function='kontrol()'>
                          <input type="hidden" name="hepsi" id="hepsi" value="">
                        </td>
                      </tr>
                    </table>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
        </table>
      </td>
    </tr>
	</cfform>
	</table>
	<script type="text/javascript">
	function kontrol()
	{
		x = document.add_work.PRO_WORK_CAT.selectedIndex;
		if (document.add_work.PRO_WORK_CAT[x].value == "")
		{ 
			alert ("<cf_get_lang dictionary_id='38271.İş Kategorisi Seçmelisiniz'> !");
			return false;
		}
		
		if (process_cat_control())
		{
			unformat_fields();
			return true;
		}
		else
			return false;
	}
	function unformat_fields()
	{
		add_work.EXPECTED_BUDGET.value = filterNum(add_work.EXPECTED_BUDGET.value);
	}
	</script>
	<cfif isDefined("attributes.work_id")>
		<cfquery name="GET_PRO_WORK_INFO" datasource="#dsn#">
			SELECT 
				WORK_HEAD,
				WORK_ID,
				TARGET_START,
				TARGET_FINISH
			FROM 
				PRO_WORKS 
			WHERE 
				WORK_ID = #attributes.work_id#
		</cfquery>
		<cfscript>
			sdate=date_add("h", session.ep.TIME_ZONE,GET_PRO_WORK_INFO.TARGET_START);
			fdate=date_add("h", session.ep.TIME_ZONE,GET_PRO_WORK_INFO.TARGET_FINISH);
			shour=datepart("h",sdate);
			fhour=datepart("h",fdate);
		</cfscript>	
		<cfoutput>
		<script type="text/javascript">
			window.add_work.rel_work.value      = '#GET_PRO_WORK_INFO.WORK_HEAD#';
			window.add_work.rel_work_id.value   = '#GET_PRO_WORK_INFO.WORK_ID#';
			window.add_work.WORK_H_START.value  = "#dateformat(sdate,dateformat_style)#";
			window.add_work.START_HOUR.value    = "#shour#";
			window.add_work.WORK_H_FINISH.value = "#dateformat(fdate,dateformat_style)#";
			window.add_work.FINISH_HOUR.value   = "#fhour#";
		</script>
		</cfoutput>
	</cfif>
</cfif> 
