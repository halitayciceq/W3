<cfinclude template="../query/get_project.cfm">
<cfinclude template="../query/get_priority.cfm">
<cfscript>
	sdate=date_add("h", session.ep.TIME_ZONE,upd_pro.TARGET_START);
	fdate=date_add("h", session.ep.TIME_ZONE,upd_pro.TARGET_FINISH);
	shour=datepart("h",sdate);
	fhour=datepart("h",fdate);
</cfscript>
<table width="100%" height="100%" border="0" align="center" cellpadding="2" cellspacing="1" class="color-border">
	<tr class="color-list">
		<td height="35" class="headbold"> <cf_get_lang dictionary_id='57416.Proje'> <cf_get_lang dictionary_id='57476.Kopyala'></td>
	</tr>
	<tr class="color-row" valign="top">
		<td>
		<table>
		<cfform method="post" name="upd_pro" ><!--- action="#request.self#?fuseaction=project.emptypopup_upd_pro" --->
		<input type="hidden" name="id" id="id" value="<cfoutput>#attributes.id#</cfoutput>">
			<tr>
				<td colspan="3"></td>
				<td></td>
			</tr>
			<tr>
				<td width="100"><cf_get_lang dictionary_id='57486.Kategori'> *</td>
				<td width="185"><cf_workcube_main_process_cat main_process_cat='#UPD_PRO.process_cat#' slct_width='150'></td>
				<td><cf_get_lang dictionary_id='30044.Sözleşme No'>
				<td><input type="text" name="agreement_no" id="agreement_no" style="width:150px;" value="<cfoutput>#upd_pro.AGREEMENT_NO#</cfoutput>"></td>
			</tr>
			<tr>
				<td><cf_get_lang dictionary_id="58859.Süreç"> *</td><!--- eski aşamaların yerini süreç aldı,unutlan bişey varsa bilgm olsn.. aysenur20071120   attributes.PRO_CURRENCY = attributes.process_stage --->
				<td><cf_workcube_process is_upd='0' select_value = '#upd_pro.PRO_CURRENCY_ID#' process_cat_width='150' is_detail='1'></td>
				<td width="80"><cf_get_lang dictionary_id='57574.Şirket'></td>
				<td>
					<input type="hidden" name="partner_id" id="partner_id" value="<cfif len(upd_pro.partner_id)><cfoutput>#upd_pro.partner_id#</cfoutput><cfelseif len(upd_pro.consumer_id)><cfoutput>#upd_pro.consumer_id#</cfoutput></cfif>">
					<input type="hidden" name="company_id" id="company_id" value="<cfif len(upd_pro.company_id)><cfoutput>#upd_pro.company_id#</cfoutput></cfif>">
					<cfif len(upd_pro.company_id) and len(upd_pro.partner_id)>
						<cfset attributes.partner_id = upd_pro.partner_id>
						<cfinclude template="../query/get_partner_name.cfm">
						<input type="text" name="about_company" id="about_company" style="width:150;"  value="<cfoutput>#get_partner_name.nickname#</cfoutput>" readonly>
					<cfelseif len(upd_pro.consumer_id)>
						<cfset attributes.consumer_id = upd_pro.consumer_id>
						<cfinclude template="../query/get_consumer_name.cfm">
						<input type="text" name="about_company" id="about_company" style="width:150;"  value="<cfoutput>#get_consumer_name.company#</cfoutput>" readonly>
					<cfelse>
						<input type="text" name="about_company" id="about_company" style="width:150;"  value="" readonly>
					</cfif>
					<a href="javascript://" onClick="windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_list_pars&field_comp_id=upd_pro.company_id&field_comp_name=upd_pro.about_company&field_id=upd_pro.partner_id&field_name=upd_pro.about_par_name&par_con=1&select_list=2,3</cfoutput>','list')"><img src="/images/plus_thin.gif" align="absmiddle" border="0"></a>
				</td>
			</tr>
			<tr>
				<td><cf_get_lang dictionary_id='57485.Öncelik'></td>
				<td>
					<select name="PRIORITY_CAT" id="PRIORITY_CAT" style="width:150px;">
					  <cfoutput query="get_cats">
					  <option value="#PRIORITY_ID#" <cfif PRIORITY_ID eq upd_pro.PRO_PRIORITY_ID>selected</cfif>>#priority#</cfoutput>
					</select>
				</td>
				<td><cf_get_lang dictionary_id='57578.Yetkili'></td>
				<td>
					<cfif len(upd_pro.company_id) and len(upd_pro.partner_id)>
						<input type="text" name="about_par_name2" id="about_par_name2" style="width:150px;"  value="<cfoutput>#get_partner_name.company_partner_name# #get_partner_name.COMPANY_PARTNER_SURNAME#</cfoutput>" readonly>
					<cfelseif len(upd_pro.consumer_id)>
						<input type="text" name="about_par_name" id="about_par_name" style="width:150px;"  value="<cfoutput>#get_consumer_name.consumer_name# #get_consumer_name.CONSUMER_SURNAME#</cfoutput>" readonly>
					<cfelse>
						<input type="text" name="about_par_name" id="about_par_name" style="width:150px;"  value="" readonly>
					</cfif>
				</td>
			</tr>
			<tr>
				<td><cf_get_lang dictionary_id='38244.Proje Adı'></td>
				<td colspan="3">
					<cfsavecontent variable="message"><cf_get_lang dictionary_id='38137.Proje Adı girmelisiniz'></cfsavecontent>
					<cfinput value="#upd_pro.PROJECT_HEAD#" type="Text" name="PROJECT_HEAD" required="Yes" message="#message#" style="width:422px;" maxlength="100">
				</td>
			</tr>
			<tr>
				<td valign="top"><cf_get_lang dictionary_id='57629.Açıklama'></td>
				<td colspan="3"><textarea name="PROJECT_DETAIL" id="PROJECT_DETAIL" style="width:422px;;" rows="7"><cfoutput>#upd_pro.PROJECT_DETAIL#</cfoutput></textarea></td>
			</tr>
			<tr>
				<td valign="top"><cf_get_lang dictionary_id='57951.Hedef'></td>
				<td colspan="3">
					<cfsavecontent variable="message"><cf_get_lang dictionary_id='29484.Fazla karakter sayısı'></cfsavecontent>
					<textarea name="PROJECT_TARGET" id="PROJECT_TARGET" style="width:422px; height:40px;" maxlength="250" onkeyup="return ismaxlength(this)" onBlur="return ismaxlength(this);" message="<cfoutput>#message#</cfoutput>"><cfoutput>#upd_pro.PROJECT_TARGET#</cfoutput></textarea>
				</td>
			</tr>
			<tr>
				<td><cf_get_lang dictionary_id='38175.Tahmini Bütçe'></td>
				<td>
					<cfinput type="text" validate="float" class="moneybox" name="EXPECTED_BUDGET" style="width:90px;"  value="#TLFormat(upd_pro.EXPECTED_BUDGET)#" passThrough = "onkeyup=""return(FormatCurrency(this,event));""">
					<select name="BUDGET_CURRENCY" id="BUDGET_CURRENCY" style="width:58px;">
						<cfinclude template="../query/get_money_currency.cfm">
						<cfoutput query="get_money">
							<option value="#MONEY#" <cfif MONEY EQ upd_pro.BUDGET_CURRENCY>selected</cfif>>#MONEY#</option>
						</cfoutput>
					</select>
				</td>
				<td><cf_get_lang dictionary_id='58053.Başlama'> *</td>
				<td>
					<cfsavecontent variable="message"><cf_get_lang dictionary_id='57738.Başlama girmelisiniz'></cfsavecontent>
					<cfinput value="#dateformat(sdate,dateformat_style)#" validate="#validate_style#" required="Yes" message="#message#" type="text" name="PRO_H_START" style="width:72px;">
					<cf_wrk_date_image date_field="PRO_H_START"><cfoutput>
						<select name="START_HOUR" id="START_HOUR">
						<cfloop from="0" to="23" index="i">
							<option value="#i#" <cfif i eq shour>selected</cfif>>#i#:00</option>
						</cfloop>
						</select>
					</cfoutput>
				</td>
			</tr>
			<tr>
				<td><cf_get_lang dictionary_id='38300.Tahmini Maliyet'></td>
				<td>
					<cfinput type="Text" validate="float" class="moneybox" name="EXPECTED_COST" style="width:90px;"  value="#TLFormat(upd_pro.EXPECTED_COST)#" passThrough = "onkeyup=""return(FormatCurrency(this,event));""">
					<select name="COST_CURRENCY" id="COST_CURRENCY" style="width:58px;">
					<cfinclude template="../query/get_money_currency.cfm">
					<cfoutput query="get_money">
						<option value="#money#" <cfif money eq upd_pro.COST_CURRENCY>selected</cfif>>#money#</option>
					</cfoutput>
					</select>
				</td>
				<td><cf_get_lang dictionary_id='57700.Bitiş'> *</td>
				<td>
					<cfsavecontent variable="message"><cf_get_lang dictionary_id='57739.Bitiş girmelisiniz'></cfsavecontent>
					<cfinput value="#dateformat(fdate,dateformat_style)#" validate="#validate_style#" required="Yes" message="#message#" type="text" name="PRO_H_FINISH" style="width:72px;">
					<cf_wrk_date_image date_field="PRO_H_FINISH"><cfoutput>
					<select name="FINISH_HOUR" id="FINISH_HOUR">
					<cfloop from="0" to="23" index="i">
						<option value="#i#" <cfif i eq fhour>selected</cfif>>#i#:00</option>
					</cfloop>
					</select>
					</cfoutput>
				</td>
			</tr>
			<tr>
				<td>
					<cf_get_lang dictionary_id='58235.Masraf Merkezi'>
					<cfquery name="GET_EXPENSE" datasource="#dsn2#">
						SELECT * FROM EXPENSE_CENTER WHERE EXPENSE_CODE='#upd_pro.expense_code#'
					</cfquery>
					<cfoutput>
						<cfif get_expense.recordcount>
							(#upd_pro.expense_code#)
						</cfif>
					</cfoutput>
				</td>
				<td>
					<input type="hidden" name="EXPENSE_CODE" id="EXPENSE_CODE"  value="<cfoutput>#get_expense.EXPENSE_CODE#</cfoutput>">
					<input type="text" name="EXPENSE_CODE_NAME" id="EXPENSE_CODE_NAME" style="width:150px;" value="<cfoutput>#get_expense.EXPENSE#</cfoutput>">
					<a href="javascript://" onClick="windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_expense_center&field_id=upd_pro.EXPENSE_CODE&field_name=upd_pro.EXPENSE_CODE_NAME</cfoutput>','list');"><img src="/images/plus_thin.gif" title="<cf_get_lang dictionary_id='50019.Masraf Merkezi Kodu Seç'>" align="absmiddle" border="0"></a></td>
				<td><cf_get_lang dictionary_id='57569.Görevli'></td>
				<td>
					<cfif upd_pro.project_emp_id neq 0 and len(upd_pro.project_emp_id)>
						<cfset person="#get_emp_info(upd_pro.project_emp_id,0,0)#">
					<cfelseif upd_pro.outsrc_partner_id neq 0 and len(upd_pro.outsrc_partner_id)>
						<cfset person="#get_par_info(upd_pro.outsrc_partner_id,0,0,0)#">
					<cfelse>
						<cfset person="Görevli Seçiniz">
					</cfif>
					<cfsavecontent variable="message1"><cf_get_lang dictionary_id='38195.Lider Seç'></cfsavecontent>
					<cfinput type="text" name="responsable_name" required="yes" message="#message1#" value="#person#" style="width:150px;" passThrough="readonly"> 
					<a href="javascript://" onClick="windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_list_positions&field_partner=upd_pro.TASK_PARTNER_ID&field_emp_id=upd_pro.PROJECT_EMP_ID&field_comp_id=upd_pro.TASK_COMPANY_ID&field_name=upd_pro.responsable_name&select_list=1,2</cfoutput>','list');"><img src="/images/plus_thin.gif" title="<cf_get_lang dictionary_id='38195.Lider Seç'>" align="absmiddle" border="0"></a>
					<input type="hidden" name="PROJECT_EMP_ID" id="PROJECT_EMP_ID" value="<cfoutput>#upd_pro.PROJECT_EMP_ID#</cfoutput>">
					<input type="hidden" name="TASK_COMPANY_ID" id="TASK_COMPANY_ID" value="<cfoutput>#upd_pro.OUTSRC_CMP_ID#</cfoutput>">
					<input type="hidden" name="TASK_PARTNER_ID" id="TASK_PARTNER_ID" value="<cfoutput>#upd_pro.OUTSRC_PARTNER_ID#</cfoutput>">
				</td>
			</tr>
			<tr>
				<td><cf_get_lang dictionary_id='38262.ilişkili proje'></td>
				<td>
					<input type="hidden" name="related_project_id" id="related_project_id" value="<cfoutput>#upd_pro.related_project_id#</cfoutput>">
					<cfif len(upd_pro.related_project_id)>
						<cfquery name="get_pro_name" datasource="#DSN#">
							SELECT PROJECT_HEAD FROM PRO_PROJECTS WHERE PROJECT_ID = #upd_pro.related_project_id#
						</cfquery>
					</cfif>
					<input type="text" name="related_project_head" id="related_project_head" value="<cfif len(upd_pro.related_project_id)><cfoutput>#get_pro_name.project_head#</cfoutput><cfelse>Projesiz</cfif>" style="width:150px;" readonly>
					<a href="javascript://" onClick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_list_projects&project_head=upd_pro.related_project_head&project_id=upd_pro.related_project_id</cfoutput>');"><img src="/images/plus_thin.gif" title="<cf_get_lang dictionary_id='58797.Proje Seçiniz'>" align="absmiddle" border="0"></a>
				</td>
				<td></td>
				<td><input type="checkbox" name="PROJECT_STATUS" id="PROJECT_STATUS" <cfif upd_pro.PROJECT_STATUS eq 1>checked</cfif>><cf_get_lang dictionary_id='38257.Gündemde'></td>
			</tr>
			<tr>
				<td colspan="3"></td>
				<td><cf_workcube_buttons is_upd='0'>
				</td>
			</tr>
		</cfform>
		</table>
		</td>
	</tr>
</table>

<script type="text/javascript">
function unformat_fields()
{
	if (!chk_process_cat('upd_pro',1)) return false;
	upd_pro.EXPECTED_BUDGET.value = filterNum(upd_pro.EXPECTED_BUDGET.value);
	upd_pro.EXPECTED_COST.value = filterNum(upd_pro.EXPECTED_COST.value);
	return process_cat_control();
	return true;
}
</script>
