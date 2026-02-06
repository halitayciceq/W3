<cfparam name="liste" default="">
<cfparam name="saat" default="">
<cfparam name="dak" default="">
<cfinclude template="../query/get_work.cfm">
<cfif upd_work.recordcount eq 0>
	<cfset hata  = 11>
	<cfsavecontent variable="message"><cf_get_lang_main no='1531.Böyle Bir Kayıt Bulunamamaktadır'>!</cfsavecontent>
	<cfset hata_mesaj  = message>
	<cfinclude template="../../dsp_hata.cfm">
<cfelse>
	<cfinclude template="../query/get_workgroups.cfm">
	<cfinclude template="../query/get_pro_work_cat.cfm">
	<cfinclude template="../query/get_priority.cfm">
	<cfscript>
		if(len(upd_work.terminate_date))
		{
			termin_date=date_add('h',session.ep.time_zone,upd_work.terminate_date);
			termin_hour=datepart('h',termin_date);
		}
		else
		{	termin_date='';
			termin_hour=8;
		}
		sdate=date_add('h', session.ep.time_zone, upd_work.target_start);
		fdate=date_add('h', session.ep.time_zone, upd_work.target_finish);
		shour=datepart('h',sdate);
		fhour=datepart('h',fdate);
		
		sdate_plan=date_add('h', session.ep.time_zone, upd_work.startdate_plan);
		fdate_plan=date_add('h', session.ep.time_zone, upd_work.finishdate_plan);
		shour_plan=datepart('h',sdate_plan);
		fhour_plan=datepart('h',fdate_plan);
	</cfscript>
	<cfinclude template="../query/get_work_history.cfm">
	<cfset work_head_ = URLEncodedFormat(upd_work.work_head)> <!--- tırnaklı ifadeleri yok etmek için --->
	<table cellspacing="1" cellpadding="2" border="0" width="100%" class="color-border">
		<tr class="color-list" valign="middle">
			<td height="35" colspan="2">
			<table border="0" cellspacing="0" cellpadding="0" width="99%" align="center">
				<tr>
					<td class="headbold"><cf_get_lang no='132.İş Güncelle'></td>
					<td width="65"><cf_get_lang no='24.Kalan Zaman'></td>
					<td height="30" width="245"><cf_per_cent start_date='#sdate#' finish_date='#fdate#' color1='red' color2='3399FF'></td>
					<td width="50" align="right" style="text-align:right;"><a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=project.popup_project_work_prints&action_id=#upd_work.work_id#&emp_id=#upd_work.project_emp_id#</cfoutput>','list','popup_project_work_prints');"><img src="/images/print.gif" title="<cf_get_lang_main no='62.Yazıcıya Gönder'>" border="0"></a></td>
				</tr>
			</table>
			</td>
		</tr>
		<tr class="color-row" valign="top">
			<td>
			<table border="1">
			<cfform name="upd_work" method="post" action="#request.self#?fuseaction=project.emptypopup_upd_work">
			<input type="hidden" name="work_id" id="work_id" value="<cfoutput>#attributes.id#</cfoutput>">
			<input type="hidden" name="pro_id" id="pro_id" value="<cfoutput>#upd_work.project_id#</cfoutput>">
			<input type="hidden" name="g_service_id" id="g_service_id" value="<cfoutput>#upd_work.g_service_id#</cfoutput>">
			<input type="hidden" name="service_id" id="service_id" value="<cfoutput>#upd_work.service_id#</cfoutput>">
			<input type="hidden" name="our_company_id" id="our_company_id" value="<cfif len(upd_work.our_company_id)><cfoutput>#upd_work.our_company_id#</cfoutput><cfelse><cfoutput>#session.ep.company_id#</cfoutput></cfif>">		
				<tr>
					<td width="70"><cf_get_lang no='57.İş Kategorisi'>*</td>
					<td>
						<select name="pro_work_cat" id="pro_work_cat" style="width:100px;">
                            <option value=""><cf_get_lang_main no='322.Seçiniz'></option>
                            <cfoutput query="get_work_cat">
                                <option value="#work_cat_id#"<cfif len(upd_work.work_cat_id) and (upd_work.work_cat_id eq work_cat_id)>selected</cfif>>#work_cat#</option>
                            </cfoutput>
						</select>
					</td>
					<td width="80"><cf_get_lang_main no='70.Aşama'> *</td>
					<td><cf_workcube_process is_upd='0' select_value = '#upd_work.work_currency_id#' process_cat_width='100' is_detail='1'></td>
					<td width="80"><cf_get_lang_main no='73.Öncelik'></td>
					<td>
						<select name="priority_cat" id="priority_cat" style="width:100px;">
							<option value=""><cf_get_lang_main no='322.Seçiniz'></option>
							<cfoutput query="get_cats">
							<option value="#priority_id#" <cfif upd_work.work_priority_id is priority_id>selected</cfif>>#priority#</option>
							</cfoutput>
						</select>
					</td>
					<td><cf_get_lang_main no='4.Proje'></td>
					<td>
						<input type="hidden" name="project_id" id="project_id" value="<cfoutput>#upd_work.project_id#</cfoutput>">
						<cfif len(upd_work.project_id)>
							<cfquery name="get_pro_name" datasource="#dsn#">
								SELECT 
									PROJECT_HEAD,
									TARGET_START,
									TARGET_FINISH
								FROM 
									PRO_PROJECTS 
								WHERE 
									PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#upd_work.project_id#">
							</cfquery>
						</cfif>
						<input type="hidden" name="p_sdate" id="p_sdate" value="<cfif len(upd_work.project_id)><cfoutput>#dateformat(get_pro_name.target_start,dateformat_style)#</cfoutput></cfif>">
						<input type="hidden" name="p_fdate" id="p_fdate" value="<cfif len(upd_work.project_id)><cfoutput>#dateformat(get_pro_name.target_finish,dateformat_style)#</cfoutput></cfif>">
						<input name="project_head" type="text" id="project_head"  style="width:100px;" onFocus="AutoComplete_Create('project_head','PROJECT_HEAD','PROJECT_HEAD,FULLNAME','get_project','','PROJECT_ID,TARGET_START,TARGET_FINISH,COMPANY_ID,FULLNAME,PARTNER_ID,MEMBER_PARTNER_NAME','project_id,p_sdate,p_fdate,company_id,about_company,company_partner_id,about_par_name','','3','150');" value="<cfif len(upd_work.project_id)><cfoutput>#get_pro_name.project_head#</cfoutput><cfelse>Projesiz</cfif>" autocomplete="off">
						<a href="javascript://" onClick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_list_projects&project_head=upd_work.project_head&project_id=upd_work.project_id&p_sdate=upd_work.p_sdate&p_fdate=upd_work.p_fdate&company_id=upd_work.company_id&company_name=upd_work.about_company&partner_id=upd_work.company_partner_id&partner_name=upd_work.about_par_name</cfoutput>');"><img src="/images/plus_thin.gif" title="<cf_get_lang_main no='1385.Proje Seçiniz'>" align="absmiddle" border="0"></a> 
					</td>
				</tr>
				<tr>
					<td width="70"><cf_get_lang_main no='157.Görevli'> *</td>
					<cfif upd_work.project_emp_id neq 0 and len(upd_work.project_emp_id)>
						<cfset person="#get_emp_info(upd_work.project_emp_id,0,0)#">
					<cfelseif upd_work.outsrc_partner_id neq 0 and len(upd_work.outsrc_partner_id)>
						<cfset person="#get_par_info(upd_work.outsrc_partner_id,0,2,0)#">
					<cfelse>
						<cfset person="">
					</cfif>
					<input type="hidden" name="task_company_id" id="task_company_id" value="<cfoutput>#upd_work.outsrc_cmp_id#</cfoutput>">
						<input type="hidden" name="task_partner_id" id="task_partner_id" value="<cfoutput>#upd_work.outsrc_partner_id#</cfoutput>">
						<input type="hidden" name="project_emp_id" id="project_emp_id" value="<cfoutput>#upd_work.project_emp_id#</cfoutput>">
						<td><cfif isdefined("url.tree_category_id")>
							<cfinput type="text" name="responsable_name" id="responsable_name" value="#person#" style="width:100px;">
						<cfelse>
							<cfinput type="text" name="responsable_name" id="responsable_name" value="#person#" style="width:100px;" onFocus="AutoComplete_Create('responsable_name','FULLNAME','FULLNAME','get_emp_pos','','EMPLOYEE_ID','project_emp_id','upd_work','3','150')">
						</cfif>
						<!--- Not : tree_category_id ve process_date degerleri call_center basvurularindan dolayi gonderiliyor FBS 20081113 --->
						<a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_list_positions&field_partner=upd_work.task_partner_id&field_comp_id=upd_work.task_company_id&field_emp_id=upd_work.project_emp_id&field_name=upd_work.responsable_name<cfif isdefined("url.tree_category_id")>&tree_category_id=#url.tree_category_id#&select_list=1<cfelse>&select_list=1,2</cfif><cfif isdefined("url.process_date")>&process_date=#url.process_date#</cfif></cfoutput>','list');"><img src="/images/plus_thin.gif" title="<cf_get_lang no='81.Görevli Seç'>" align="absmiddle" border="0"></a>
					</td>
					<td>CC</td>
					<td>
						<cfif upd_work.cc_emp_id neq 0 and len(upd_work.cc_emp_id)>
							<cfset person="#get_emp_info(upd_work.cc_emp_id,0,0)#">
						<cfelseif upd_work.outsrc_cc_partner_id neq 0 and len(upd_work.outsrc_cc_partner_id)>
							<cfset person="#get_par_info(upd_work.outsrc_cc_partner_id,0,0,0)#">
						<cfelse>
							<cfset person="">
						</cfif>
						<input type="hidden" name="cc_partner_id" id="cc_partner_id" value="<cfoutput>#upd_work.outsrc_cc_partner_id#</cfoutput>">
						<input type="hidden" name="cc_emp_id" id="cc_emp_id" value="<cfoutput>#upd_work.cc_emp_id#</cfoutput>">
						<cfinput type="text" name="cc_name" id="cc_name" value="#person#" onFocus="AutoComplete_Create('cc_name','FULLNAME','FULLNAME','get_emp_pos','','EMPLOYEE_ID','cc_emp_id','upd_work','3','150')" style="width:100px;">
						<a href="javascript://" onClick="windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_list_positions&field_partner=upd_work.cc_partner_id&field_emp_id=upd_work.cc_emp_id&field_name=upd_work.cc_name&select_list=1,2</cfoutput>','list');"><img src="/images/plus_thin.gif"  align="absmiddle" border="0"></a>
					</td>
					<td><cf_get_lang_main no='728.İş Grubu'></td>
					<td valign="top">
						<select name="workgroup_id" id="workgroup_id" style="width:100px;">				  
                            <option value=""><cf_get_lang_main no='728.İş Grubu'></option>
                            <cfoutput query="get_workgroups">
                                <option value="#workgroup_id#" <cfif upd_work.workgroup_id eq workgroup_id>selected</cfif>>#workgroup_name#</option>
                            </cfoutput>
						</select>
					</td>
					<td><cf_get_lang no='67.İlişkili İş'></td>
					<td><cfset head="İlişki Belirleyin">
						<cfset rel_work_id="0">							
						<cfif (upd_work.related_work_id neq 0) and len(upd_work.related_work_id)>
							<cfinclude template="../query/get_rel_work.cfm">
							<cfif get_rel_work.recordcount>
								<cfset head=get_rel_work.work_head>
								<cfset rel_work_id=get_rel_work.work_id>
							</cfif>
						</cfif>
						<input type="hidden" name="rel_work_id" id="rel_work_id" value="<cfoutput>#rel_work_id#</cfoutput>">
						<input type="text" name="rel_work" id="rel_work" value="<cfoutput>#head#</cfoutput>" style="width:100px;">
						<cfif isDefined("attributes.work_list")>
							<a href="javascript://" onClick="windowopen('<cfoutput>#request.self#?fuseaction=project.popup_add_relation&pro_id=#upd_work.project_id#&work_id=#upd_work.project_id#&#url.id#&w_id=upd_work.rel_work_id&w_name=upd_work.rel_work</cfoutput>','small');"><img src="/images/plus_thin.gif" border="0" align="absmiddle"></a>
						<cfelse>
							<a href="javascript://" onClick="windowopen('<cfoutput>#request.self#?fuseaction=project.popup_add_relation&pro_id=#upd_work.project_id#&work_id=#url.id#&w_id=upd_work.rel_work_id&w_name=upd_work.rel_work</cfoutput>','small');"><img src="/images/plus_thin.gif" border="0" align="absmiddle"></a>
						</cfif>
					</td>
				</tr>
				<tr>
					<td width="70"><cf_get_lang_main no='162.Şirket'>/<cf_get_lang_main no='166.Yetkili'></td>
						<cfif isdefined("get_hist_detail.work_currency_id") and len(get_hist_detail.work_currency_id)>
							<input type="hidden" name="old_currency" id="old_currency" value="<cfoutput>#get_hist_detail.work_currency_id#</cfoutput>">
						<cfelse>
							<input type="hidden" name="old_currency" id="old_currency" value="<cfoutput>#upd_work.work_currency_id#</cfoutput>">
						</cfif>
					<td colspan="7">
						<input type="hidden" name="company_partner_id" id="company_partner_id" value="<cfif len(upd_work.company_partner_id)><cfoutput>#upd_work.company_partner_id#</cfoutput><cfelseif len(upd_work.consumer_id)><cfoutput>#upd_work.consumer_id#</cfoutput></cfif>">
						<input type="hidden" name="company_id" id="company_id" value="<cfif len(upd_work.company_id)><cfoutput>#upd_work.company_id#</cfoutput></cfif>">
						<cfif len(upd_work.company_id) and len(upd_work.company_partner_id)>
							<cfset attributes.partner_id = upd_work.company_partner_id>
							<cfinclude template="../query/get_partner_name.cfm">
							<input type="text" name="about_company" id="about_company" value="<cfoutput>#get_partner_name.nickname#</cfoutput>" onKeyUp="get_company();" style="width:308px;">
							<input type="text" name="about_par_name" id="about_par_name" value="<cfoutput>#get_partner_name.company_partner_name# #get_partner_name.company_partner_surname#</cfoutput>" readonly style="width:308px;">
						<cfelseif not len(upd_work.company_id) and len(upd_work.consumer_id)>
							<cfset attributes.consumer_id = upd_work.consumer_id>
							<cfinclude template="../query/get_consumer_name.cfm">
							<input type="text" name="about_company"  id="about_company" value="<cfoutput>#get_consumer_name.company#</cfoutput>" style="width:308px;">
							<input type="text" name="about_par_name" id="about_par_name" value="<cfoutput>#get_consumer_name.consumer_name# #get_consumer_name.consumer_surname#</cfoutput>" readonly style="width:308px;">
						<cfelse>
							<input type="text" name="about_company" id="about_company" value="" style="width:308px;">
							<input type="text" name="about_par_name" id="about_par_name" value="" readonly style="width:308px;">
						</cfif>
						<a href="javascript://" onClick="windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_list_pars&field_comp_id=upd_work.company_id&field_comp_name=upd_work.about_company&field_id=upd_work.company_partner_id&field_name=upd_work.about_par_name&par_con=1&select_list=2</cfoutput>','list')"><img src="/images/plus_thin.gif" align="absmiddle" border="0"></a> 
					</td>
				</tr>
				<tr>
					<td width="70"><cf_get_lang_main no='68.Başlık'> *</td>
					<td colspan="7">
						<cfsavecontent variable="message"><cf_get_lang_main no="782.Zorunlu Alan"> : <cf_get_lang_main no='1408.Başlık'></cfsavecontent>
						<cfinput value="#URLDecode(work_head_)#" type="Text" name="work_head" id="work_head" required="Yes" message="#message#" style="width:750px;" maxlength="100">
					</td>
				</tr>
				<tr>
					<td colspan="7">
						<cfset tr_topic =''>
						<cfmodule
							template="/fckeditor/fckeditor.cfm"
							toolbarSet="Basic"
							basePath="/fckeditor/"
							instanceName="work_detail"
							valign="top"
							value=""
							width="550"
							height="180">
					</td>
				</tr>
				<tr>
					<td colspan="2" class="txtboldblue">Planlanan</td>
					<td>Termin</td>
					<td><cfinput validate="#validate_style#" maxlength="10" type="text" id="terminate_date" name="terminate_date" value="#dateformat(termin_date,dateformat_style)#" style="width:72px;">
						<cf_wrk_date_image date_field="terminate_date">
						 <cfoutput>
						<select name="terminate_hour" id="terminate_hour">
						  <cfloop from="0" to="23" index="i">
							<option value="#i#" <cfif i eq termin_hour>selected</cfif>>#i#:00</option>
						  </cfloop>
						</select>
					  </cfoutput>
					 </td>
				</tr>
				<tr>
					<td><cf_get_lang_main no='243.Başlama Tarihi'><!--- <cf_get_lang no='55.Tahmini Bütçe'> ---></td>
					<td width="180">
						<cfsavecontent variable="message"><cf_get_lang_main no="59.Eksik Veri"> : <cf_get_lang_main no='243.Başlama Tarihi'></cfsavecontent>
						<cfinput type="text" name="startdate_plan" value="#dateformat(sdate_plan,dateformat_style)#" required="Yes" maxlength="10" validate="#validate_style#" message="#message#" style="width:72px;">
						<cf_wrk_date_image date_field="startdate_plan">
						<select name="start_hour_plan" id="start_hour_plan">
							<cfloop from="0" to="23" index="i">
								<cfoutput><option value="#i#" <cfif i eq shour_plan>selected</cfif>>#i#:00</option></cfoutput>
							</cfloop>
						</select>
						<!--- <cfinput type="text" name="expected_budget" style="width:89px;" value="#TLFormat(upd_work.expected_budget)#" passThrough="onkeyup=""return(FormatCurrency(this,event));""" class="moneybox">
						<select name="expected_budget_money" class="formselect" style="width:58px;">
						<cfinclude template="../query/get_money_currency.cfm">
						<cfoutput query="get_money">
							<option value="#money#"<cfif money is upd_work.expected_budget_money> selected</cfif>>#money#</option>
						</cfoutput>
						</select> --->
					</td>
					<td width="80"><cf_get_lang_main no='243.Başlama Tarihi'></td>
					<td><cfsavecontent variable="message"><cf_get_lang_main no="59.Eksik Veri"> : <cf_get_lang_main no='243.Başlama Tarihi'></cfsavecontent>
						<cfinput type="text" name="work_h_start" value="#dateformat(sdate,dateformat_style)#" required="Yes" maxlength="10" onchange="estimated_finishdate(this.value,'minute')" validate="#validate_style#" message="#message#" style="width:72px;">
						<cf_wrk_date_image date_field="work_h_start">
						<select name="start_hour" id="start_hour"  onchange="estimated_finishdate(this.value,'minute')" >
							<cfloop from="0" to="23" index="i">
								<cfoutput><option value="#i#" <cfif i eq shour>selected</cfif>>#i#:00</option></cfoutput>
							</cfloop>
						</select>
					</td>
				</tr>
				<cfif isdefined('upd_work.estimated_time') and len(upd_work.estimated_time)>
					<cfset liste=upd_work.estimated_time/60>
					<cfset saat=listfirst(liste,'.')>
					<cfset dak=upd_work.estimated_time-saat*60>
				</cfif>
				<tr>
					<td><cf_get_lang_main no='288.Bitiş Tarihi'><!--- <cf_get_lang no='95.Öngörülen Süre'> ---></td>
					<td>
						<cfsavecontent variable="message"><cf_get_lang_main no="59.Eksik Veri"> : <cf_get_lang_main no='288.Bitiş Tarihi'></cfsavecontent>
						<cfinput value="#dateformat(fdate,dateformat_style)#" required="Yes" maxlength="10" validate="#validate_style#" message="#message#" type="text" id="work_h_finish" name="finishdate_plan" style="width:72px;">
						<cf_wrk_date_image date_field="finishdate_plan"><cfoutput>
						<select name="finish_hour_plan" id="finish_hour">
							<cfloop from="0" to="23" index="i">
								<option value="#i#" <cfif i eq fhour_plan>selected</cfif>>#i#:00</option>
							</cfloop>
							</select>
						</cfoutput>
						<!--- <cfsavecontent variable="message"><cf_get_lang no='16.Tahmini Süre girmelisiniz'></cfsavecontent>
						<cfinput type="text" name="estimated_time" validate="integer" message="#message#" value="#saat#" onkeyup="isNumber(this);" style="width:58px;" onblur="estimated_finishdate(this.value,'hour')">&nbsp;Saat&nbsp;&nbsp;
						<cfinput type="text" name="estimated_time_minute" value="#dak#" style="width:58;" onkeyup="isNumber(this);" range="0,59" onblur="estimated_finishdate(this.value,'minute')" message="<cf_get_lang no ='175.Arası Giriniz'>!">&nbsp;Dk.
						<div id="upd_date_div_id" style="display:none"></div> --->
					</td>
					<td><cf_get_lang_main no='288.Bitiş Tarihi'></td>
					<td><cfsavecontent variable="message"><cf_get_lang_main no="59.Eksik Veri"> : <cf_get_lang_main no='288.Bitiş Tarihi'></cfsavecontent>
						<cfinput value="#dateformat(fdate,dateformat_style)#" required="Yes" maxlength="10" validate="#validate_style#" message="#message#" type="text" id="work_h_finish" name="work_h_finish" style="width:72px;">
						<cf_wrk_date_image date_field="work_h_finish"><cfoutput>
						<select name="finish_hour" id="finish_hour">
							<cfloop from="0" to="23" index="i">
								<option value="#i#" <cfif i eq fhour>selected</cfif>>#i#:00</option>
							</cfloop>
							</select>
						</cfoutput>
					</td>
				</tr>
				<tr>
					<td><cf_get_lang no='186.Gerçekleşen Süre'></td>
					<td><input type="text" name="total_time_hour" id="total_time_hour" value="" style="width:58px;"  onkeyup="isNumber(this);">&nbsp;Saat&nbsp;&nbsp;
						<cfinput type="text" name="total_time_minute" value="" style="width:58px;" range="0,59"  onkeyup="isNumber(this);" message="<cf_get_lang no='175.Arası Giriniz'>!">&nbsp;Dk.
					</td>
					<td><cf_get_lang_main no='157.Görevli'> *</td>
					<cfif upd_work.project_emp_id neq 0 and len(upd_work.project_emp_id)>
						<cfset person="#get_emp_info(upd_work.project_emp_id,0,0)#">
					<cfelseif upd_work.outsrc_partner_id neq 0 and len(upd_work.outsrc_partner_id)>
						<cfset person="#get_par_info(upd_work.outsrc_partner_id,0,2,0)#">
					<cfelse>
						<cfset person="">
					</cfif>
					<td><input type="hidden" name="task_company_id" id="task_company_id" value="<cfoutput>#upd_work.outsrc_cmp_id#</cfoutput>">
						<input type="hidden" name="task_partner_id" id="task_partner_id" value="<cfoutput>#upd_work.outsrc_partner_id#</cfoutput>">
						<input type="hidden" name="project_emp_id" id="project_emp_id" value="<cfoutput>#upd_work.project_emp_id#</cfoutput>">
						<cfif isdefined("url.tree_category_id")>
							<cfinput type="text" name="responsable_name" id="responsable_name" value="#person#" style="width:150px;">
						<cfelse>
							<cfinput type="text" name="responsable_name" id="responsable_name" value="#person#" style="width:150px;" onFocus="AutoComplete_Create('responsable_name','FULLNAME','FULLNAME','get_emp_pos','','EMPLOYEE_ID','project_emp_id','upd_work','3','150')">
						</cfif>
						<!--- Not : tree_category_id ve process_date degerleri call_center basvurularindan dolayi gonderiliyor FBS 20081113 --->
						<a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_list_positions&field_partner=upd_work.task_partner_id&field_comp_id=upd_work.task_company_id&field_emp_id=upd_work.project_emp_id&field_name=upd_work.responsable_name<cfif isdefined("url.tree_category_id")>&tree_category_id=#url.tree_category_id#&select_list=1<cfelse>&select_list=1,2</cfif><cfif isdefined("url.process_date")>&process_date=#url.process_date#</cfif></cfoutput>','list');"><img src="/images/plus_thin.gif" title="<cf_get_lang no='81.Görevli Seç'>" align="absmiddle" border="0"></a>
					</td>
				</tr>
				<tr>
					<td><cf_get_lang no='187.Tamamlanma'> %</td>
					<td>
						<cfoutput>
						<select name="to_complate" id="to_complate" style="width:58px">
							<cfloop from="0" to="100" index="i" step="5">
								<option value="#i#" <cfif upd_work.to_complete eq i>selected</cfif>>#i#</option>
							</cfloop>
						</select>
						</cfoutput>
					</td>
					<td>CC</td>
					<td>
						<cfif upd_work.cc_emp_id neq 0 and len(upd_work.cc_emp_id)>
							<cfset person="#get_emp_info(upd_work.cc_emp_id,0,0)#">
						<cfelseif upd_work.outsrc_cc_partner_id neq 0 and len(upd_work.outsrc_cc_partner_id)>
							<cfset person="#get_par_info(upd_work.outsrc_cc_partner_id,0,0,0)#">
						<cfelse>
							<cfset person="">
						</cfif>
						<input type="hidden" name="cc_partner_id" id="cc_partner_id" value="<cfoutput>#upd_work.outsrc_cc_partner_id#</cfoutput>">
						<input type="hidden" name="cc_emp_id" id="cc_emp_id" value="<cfoutput>#upd_work.cc_emp_id#</cfoutput>">
						<cfinput type="text" name="cc_name" id="cc_name" value="#person#" onFocus="AutoComplete_Create('cc_name','FULLNAME','FULLNAME','get_emp_pos','','EMPLOYEE_ID','cc_emp_id','upd_work','3','150')" style="width:150px;">
						<a href="javascript://" onClick="windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_list_positions&field_partner=upd_work.cc_partner_id&field_emp_id=upd_work.cc_emp_id&field_name=upd_work.cc_name&select_list=1,2</cfoutput>','list');"><img src="/images/plus_thin.gif"  align="absmiddle" border="0"></a>								
					</td>
				</tr>
				<tr>
					<td><input type="checkbox" value="1" name="is_milestone" id="is_milestone" <cfif upd_work.is_milestone eq 1>checked</cfif>>Kilometre Taşı</td>
					<td>
						<input type="checkbox" value="1" name="is_mail" id="is_mail" checked="checked"><cf_get_lang_main no="63.Mail Gönder">
						<input type="checkbox" name="work_status" id="work_status" <cfif upd_work.work_status eq 1>checked</cfif>><cf_get_lang_main no='81.Aktif'>
					</td>
					<td><cf_get_lang_main no='728.İş Grubu'></td>
					<td>
						<select name="workgroup_id" id="workgroup_id" style="width:150px;">				  
                            <option value=""><cf_get_lang_main no='728.İş Grubu'></option>
                            <cfoutput query="get_workgroups">
                                <option value="#workgroup_id#" <cfif upd_work.workgroup_id eq workgroup_id>selected</cfif>>#workgroup_name#</option>
                            </cfoutput>
						</select>
					</td>
				</tr>
				<tr>
					<td colspan="2"><cf_record_info query_name="upd_work" record_emp="record_author" update_emp="update_author" is_partner="1"></td>
					<td colspan="2"><cf_workcube_buttons is_upd='1' add_function='chk_work(#upd_work.project_id#)' delete_page_url='#request.self#?fuseaction=project.emptypopup_delwork&id=#upd_work.work_id#&head=#work_head_#'></td>
				</tr>
			</cfform>
			</table>
		<br/>
		<cfoutput>
		<cfif get_work_history.recordcount>
			<table width="540" cellpadding="0" cellspacing="1" border="0" class="color-border">
			
				<cfif len(upd_work.work_circuit)>
					<tr class="color-header" height="25">
						<td>&nbsp;&nbsp;<a href="#user_domain##request.self#?fuseaction=#upd_work.work_circuit#.#upd_work.work_fuseaction#" class="tableyazi" target="_blank">
							#user_domain##request.self#?fuseaction=#upd_work.work_circuit#.#upd_work.work_fuseaction#</a></td>
					</tr>
				</cfif>
				<tr class="color-list">
					<td height="20" class="txtboldblue">
					<cfoutput>
						<a href="javascript://" onclick="gizle_goster_img('id_1','id_2','works_history');"><img src="/images/listele_down.gif" title="<cf_get_lang no='116.Ayrıntıları Gizle'>"  border="0" align="absmiddle" id="id_1" style="display:;cursor:pointer;"></a>
						<a href="javascript://" onclick="gizle_goster_img('id_1','id_2','works_history');"><img src="/images/listele.gif" title="<cf_get_lang no='337.Ayrıntıları Göster'>" border="0" align="absmiddle" id="id_2" style="display:none;cursor:pointer;"></a>
					</cfoutput>
					<cf_get_lang_main no='61.Tarihçe'>
					</td>
				</tr>
				<tr class="color-list" id="works_history">    
					<td><div id="_works_history_"></div></td>
				</tr>		
			</table><br/>
			<script type="text/javascript">
				<cfoutput>
					AjaxPageLoad('#request.self#?fuseaction=project.emptypopup_updwork_ajaxhistory&id=#attributes.id#','_works_history_',1); 
				</cfoutput>
			</script>
		</cfif>
	</cfoutput>
			</td>
			<td width="300">
			<br/>
				<!--- Belgeler --->
				<cf_get_workcube_asset asset_cat_id="-21" module_id='1' action_section='WORK_ID' action_id='#attributes.id#'><br/>
				<cfif len(upd_work.opportunity_id) and len(upd_work.our_company_id)><br/>
					<cfset service_dsn = '#dsn#_#upd_work.our_company_id#'>
					<cfquery name="GET_OPP" datasource="#service_dsn#">
						SELECT OPP_HEAD FROM OPPORTUNITIES WHERE OPP_ID = #upd_work.opportunity_id#
					</cfquery>
					<strong>İlişkili Fırsat :</strong><br/>
					<cfif session.ep.company_id eq upd_work.our_company_id>
						<cfoutput><a href="#request.self#?fuseaction=sales.list_opportunity&event=det&opp_id=#upd_work.opportunity_id#" target="_blank" class="tableyazi">#get_opp.OPP_HEAD#</a></cfoutput>
					<cfelse>
						<cfoutput>#get_opp.opp_head#</cfoutput>
					</cfif>
				</cfif>
				<cfif len(upd_work.project_id)><br/>
					<cfquery name="GET_PROJECT" datasource="#DSN#">
						SELECT PROJECT_HEAD FROM PRO_PROJECTS WHERE PROJECT_ID = #upd_work.project_id#
					</cfquery>
					<strong>İlişkili Proje :</strong><br/> 
					<cfoutput><a href="#request.self#?fuseaction=project.projects&event=det&id=#upd_work.project_id#" target="_blank" class="tableyazi">#get_project.project_head#</a></cfoutput>
				</cfif>
				<cfif len(upd_work.service_id) and len(upd_work.our_company_id)><br/>
					<cfset service_dsn = '#dsn#_#upd_work.our_company_id#'>
					<cfquery name="GET_SERVICE" datasource="#service_dsn#">
						SELECT SERVICE_HEAD FROM SERVICE WHERE SERVICE_ID = #upd_work.service_id#
					</cfquery>
					<strong>İlişkili Servis :</strong><br/> 
					<cfif session.ep.company_id eq upd_work.our_company_id>
						<cfoutput><a href="#request.self#?fuseaction=service.upd_service&service_id=#upd_work.service_id#" target="_blank" class="tableyazi">#get_service.SERVICE_HEAD#</a></cfoutput>
					<cfelse>
						<cfoutput>#get_service.service_head#</cfoutput>
					</cfif>
				</cfif>
				<cfif len(upd_work.g_service_id)><br/>
					<cfquery name="GET_SERVICE" datasource="#DSN#">
						SELECT SERVICE_HEAD FROM G_SERVICE WHERE SERVICE_ID = #upd_work.g_service_id#
					</cfquery>
					<strong>İlişkili Call Center :</strong><br/> 
					<cfoutput><a href="#request.self#?fuseaction=call.list_service&event=upd&service_id=#upd_work.g_service_id#" target="_blank" class="tableyazi">#get_service.SERVICE_HEAD#</a></cfoutput>
				</cfif>
			</td>
			
		</tr>
	</table>
</cfif>
<br/>
<script type="text/javascript">
function chk_work(pro_id)
{
	if((document.upd_work.pro_id.value>0)&&(document.upd_work.project_id.value>0)&&(document.upd_work.rel_work_id.value!=0)&&(document.upd_work.rel_work_id.value!="")&&(document.upd_work.project_id.value!=pro_id))
		if(confirm("<cf_get_lang no ='197.İlişkilendirilmiş iş seçtiğiniz projeye ait değil.İş ilişkisi silinecek'>!"))
		{
			windowopen('<cfoutput>#request.self#?fuseaction=project.emptypopup_arrange_rel&work_id=#url.ID#</cfoutput>&rel_work_id='+document.upd_work.rel_work_id.value,'','small');
			document.upd_work.rel_work_id.value="";
			document.upd_work.rel_work.value="";
		}
		else return false;
		return kontrol();
}
function kontrol()
{
	fix_date(document.upd_work.work_h_start,document.upd_work.work_h_start.name);
	fix_date(document.upd_work.work_h_finish,document.upd_work.work_h_finish.name);
	
	tarih1_ = document.upd_work.work_h_start.value.substr(6,4) + document.upd_work.work_h_start.value.substr(3,2) + document.upd_work.work_h_start.value.substr(0,2);
	tarih2_ = document.upd_work.p_sdate.value.substr(6,4) + document.upd_work.p_sdate.value.substr(3,2) + document.upd_work.p_sdate.value.substr(0,2);
	tarih3_ = document.upd_work.work_h_finish.value.substr(6,4) + document.upd_work.work_h_finish.value.substr(3,2) + document.upd_work.work_h_finish.value.substr(0,2);
	tarih4_ = document.upd_work.p_fdate.value.substr(6,4) + document.upd_work.p_fdate.value.substr(3,2) + document.upd_work.p_fdate.value.substr(0,2);
	
	if ((document.upd_work.project_emp_id.value== ""  || document.upd_work.responsable_name.value== "")  && (document.upd_work.task_partner_id.value== "" || document.upd_work.responsable_name.value== ""))
	{
		alert ("<cf_get_lang_main no='59.Eksik Veri'> : <cf_get_lang_main no='157.Görevli'>");
		return false;
	}	
	
	x = document.upd_work.priority_cat.selectedIndex;
	if (document.upd_work.priority_cat[x].value == "")
	{ 
		alert ("<cf_get_lang_main no='59.Eksik Veri'> : <cf_get_lang_main no='73.Öncelik'>");
		return false;
	}
	x = document.upd_work.pro_work_cat.selectedIndex;
	if (document.upd_work.pro_work_cat[x].value == "")
	{ 
		alert ("<cf_get_lang_main no='59.Eksik Veri'> : <cf_get_lang no='57.İş Kategorisi'>");
		return false;
	}
	if(document.upd_work.project_id.value != "")
	{
		if(tarih1_ < tarih2_)
		{
			alert("<cf_get_lang no ='194.Girdiğiniz İşin Hedef Başlangıç Tarihi Bağlı Olduğu Projenin Hedef Başlangıç Tarihinden Önce Görünüyor Lütfen Düzeltin '>!");
			return false;			
		}
		if(tarih3_ > tarih4_)
		{
			alert("<cf_get_lang no ='195.Girdiğiniz İşin Hedef Bitiş Tarihi Projesinin Hedef Bitiş Tarihinden Sonra Gözüküyor Lütfen Düzeltin'>!");
			return false;			
		} 
	}
	
	if(tarih1_ > tarih3_ || (tarih1_ == tarih3_ && (parseInt(document.upd_work.start_hour.value) >= parseInt(document.upd_work.finish_hour.value))))
	{
		alert("<cf_get_lang no ='196.Girdiğiniz İşin Başlangıç Tarihi ile Bitiş Tarihi Mantıklı Gözükmüyor Lütfen Düzeltin '>!");
		return false;			
	}	
	
	unformat_fields();
	return process_cat_control();
}

function unformat_fields()
{
	fld=document.upd_work.expected_budget;
	fld.value=filterNum(fld.value);
}

function estimated_finishdate(add_time,type)
	{
		var work_h_start = document.upd_work.work_h_start.value;
		var work_start_hour = document.upd_work.start_hour.value;
		var add_hour = document.upd_work.estimated_time.value;
		var add_minute = document.upd_work.estimated_time_minute.value;
		var send_address = '<cfoutput>#request.self#</cfoutput>?fuseaction=project.emptypopup_add_date&type='+ type +'&work_start_hour='+ work_start_hour +'&work_h_start='+ work_h_start +'&add_hour='+add_hour +'&add_minute='+add_minute;
	AjaxPageLoad(send_address,'upd_date_div_id',1);
	}
</script>
