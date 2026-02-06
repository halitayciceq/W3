<cfparam name="liste" default="">
<cfparam name="saat" default="">
<cfparam name="dak" default="">
<cfquery name="GET_WORKGROUPS" datasource="#DSN#">
	SELECT
		WORKGROUP_ID,
		WORKGROUP_NAME
	FROM 
		WORK_GROUP
	WHERE
		STATUS = 1
	ORDER BY 
		WORKGROUP_NAME
</cfquery>
<cfinclude template="../query/get_work.cfm">
<cfinclude template="../query/get_pro_work_cat.cfm">
<cfinclude template="../query/get_priority.cfm">
<cfscript>
	sdate=date_add('h', session.ep.time_zone, upd_work.target_start);
	fdate=date_add('h', session.ep.time_zone, upd_work.target_finish);
	shour=datepart('h',sdate);
	fhour=datepart('h',fdate);
</cfscript>
<cfinclude template="../query/get_work_history.cfm">

<cfset work_head_ = URLEncodedFormat(upd_work.work_head)> <!--- tırnaklı ifadeleri yok etmek için --->
<table cellspacing="1" cellpadding="2" border="0" width="100%" height="100%" class="color-border">
	<tr class="color-list" valign="middle">
  		<td height="35" colspan="2">
		<table border="0" cellspacing="0" cellpadding="0" width="99%" align="center">
			<tr>
				<td class="headbold"><cf_get_lang dictionary_id='38252.İş Güncelle'></td>
				<td width="65"><cf_get_lang dictionary_id='38144.Kalan Zaman'></td>
				<td height="30" width="245"><cf_per_cent start_date = '#sdate#' finish_date = '#fdate#' color1='66CC33' color2='3399FF'></td>
				<td width="50" align="right" style="text-align:right;"><a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=project.popup_project_work_prints&action_id=#upd_work.work_id#&emp_id=#upd_work.project_emp_id#</cfoutput>','list','popup_project_work_prints');"><img src="/images/print.gif" title="<cf_get_lang dictionary_id='57474.Yazıcıya Gönder'>" border="0"></a></td>
			</tr>
		</table>
		</td>
	</tr>
	<tr class="color-row" valign="top">
  		<td>
		<table>
		<cfform method="post" name="upd_work" action="#request.self#?fuseaction=project.emptypopup_upd_work">
		<input type="hidden" name="work_id" id="work_id" value="<cfoutput>#attributes.id#</cfoutput>">
		<input type="hidden" name="pro_id" id="pro_id" value="<cfoutput>#upd_work.project_id#</cfoutput>">		
			<tr>
		  		<td><cf_get_lang dictionary_id="58859.Süreç">*</td>
		  		<td><cf_workcube_process is_upd='0' select_value = '#upd_work.work_currency_id#' process_cat_width='155' is_detail='1'></td>
				<td><cf_get_lang dictionary_id='57485.Öncelik'></td>
				<td><select name="priority_cat" id="priority_cat" style="width:177px;">
						<option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
						<cfoutput query="get_cats">
							<option value="#priority_id#" <cfif upd_work.work_priority_id is priority_id>selected</cfif>>#priority#</option>
						</cfoutput>
					</select>
				</td>
			</tr>
			<tr>
		  		<td><cf_get_lang dictionary_id='57416.Proje'></td>
				<td valign="top">
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
					<cf_wrk_projects form_name='upd_work' project_id='project_id' project_name='project_head'>
					<input type="text" name="project_head" id="project_head" value="<cfif len(upd_work.project_id)><cfoutput>#get_pro_name.project_head#</cfoutput><cfelse>Projesiz</cfif>" onkeyup="get_project_1();" style="width:155px;">
					<a href="javascript://" onClick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_list_projects&project_head=upd_work.project_head&project_id=upd_work.project_id&p_sdate=upd_work.p_sdate&p_fdate=upd_work.p_fdate&company_id=upd_work.company_id&company_name=upd_work.about_company&partner_id=upd_work.company_partner_id&partner_name=upd_work.about_par_name</cfoutput>');"><img src="/images/plus_thin.gif" title="<cf_get_lang dictionary_id='58797.Proje Seçiniz'>" align="absmiddle" border="0"></a> 
				</td>
				<td><cf_get_lang dictionary_id='38187.İlişkili İş'></td>
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
					<!--- <input type="hidden" name="work_list"> --->
					<input type="text" name="rel_work" id="rel_work" value="<cfoutput>#head#</cfoutput>" style="width:177px;">
					<cfif isDefined("attributes.work_list")>
						<a href="javascript://" onClick="windowopen('<cfoutput>#request.self#?fuseaction=project.popup_add_relation&pro_id=#upd_work.project_id#&work_id=#upd_work.project_id#&#url.id#&w_id=upd_work.rel_work_id&w_name=upd_work.rel_work</cfoutput>','small');"><img src="/images/plus_thin.gif" border="0" align="absmiddle"></a>
					<cfelse>
						<a href="javascript://" onClick="windowopen('<cfoutput>#request.self#?fuseaction=project.popup_add_relation&pro_id=#upd_work.project_id#&work_id=#url.id#&w_id=upd_work.rel_work_id&w_name=upd_work.rel_work</cfoutput>','small');"><img src="/images/plus_thin.gif" border="0" align="absmiddle"></a>
					</cfif>
				</td>
			</tr>
			<tr>
				<td><cf_get_lang dictionary_id='57574.Şirket'>/<cf_get_lang dictionary_id='57578.Yetkili'></td>
					<cfif isdefined("get_hist_detail.work_currency_id") and len(get_hist_detail.work_currency_id)>
						<input type="hidden" name="old_currency" id="old_currency" value="<cfoutput>#get_hist_detail.work_currency_id#</cfoutput>">
					<cfelse>
						<input type="hidden" name="old_currency" id="old_currency" value="<cfoutput>#upd_work.work_currency_id#</cfoutput>">
					</cfif>
				<td colspan="3">
				 	<input type="hidden" name="company_partner_id" id="company_partner_id" value="<cfif len(upd_work.company_partner_id)><cfoutput>#upd_work.company_partner_id#</cfoutput><cfelseif len(upd_work.consumer_id)><cfoutput>#upd_work.consumer_id#</cfoutput></cfif>">
					<input type="hidden" name="company_id" id="company_id" value="<cfif len(upd_work.company_id)><cfoutput>#upd_work.company_id#</cfoutput></cfif>">
					<cfif len(upd_work.company_id) and len(upd_work.company_partner_id)>
						<cfset attributes.partner_id = upd_work.company_partner_id>
					 	<cfinclude template="../query/get_partner_name.cfm">
					  	<input onKeyUp="get_company();" type="text" name="about_company" id="about_company" style="width:221;" value="<cfoutput>#get_partner_name.nickname#</cfoutput>">
					  	<input type="text" name="about_par_name" id="about_par_name" style="width:221px;" value="<cfoutput>#get_partner_name.company_partner_name# #get_partner_name.company_partner_surname#</cfoutput>" readonly>
					<cfelseif not len(upd_work.company_id) and len(upd_work.consumer_id)>
						<cfset attributes.consumer_id = upd_work.consumer_id>
					 	<cfinclude template="../query/get_consumer_name.cfm">
					  	<input type="text" name="about_company" id="about_company" style="width:221;" value="<cfoutput>#get_consumer_name.company#</cfoutput>">
					  	<input type="text" name="about_par_name" id="about_par_name" style="width:221px;" value="<cfoutput>#get_consumer_name.consumer_name# #get_consumer_name.consumer_surname#</cfoutput>" readonly>
					<cfelse>
					  	<input type="text" name="about_company" id="about_company" style="width:221;" value="">
					  	<input type="text" name="about_par_name" id="about_par_name" style="width:221px;"  value="" readonly>
					</cfif>
					<a href="javascript://" onClick="windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_list_pars&field_comp_id=upd_work.company_id&field_comp_name=upd_work.about_company&field_id=upd_work.company_partner_id&field_name=upd_work.about_par_name&par_con=1&select_list=2</cfoutput>','list')"><img src="/images/plus_thin.gif" align="absmiddle" border="0"></a> 
				</td>
			</tr>
			<tr>
				<td><cf_get_lang dictionary_id='57480.Başlık'> *</td>
				<td colspan="3">
					<cfsavecontent variable="message"><cf_get_lang dictionary_id="58194.Zorunlu Alan"> : <cf_get_lang dictionary_id='58820.Başlık'></cfsavecontent>
					<cfinput value="#URLDecode(work_head_)#" type="Text" name="work_head" required="Yes" message="#message#" style="width:445px;" maxlength="100">
				</td>
			</tr>
			<tr>
				<td colspan="4">
					<!--- BK kapatti 20070529 Acıklama bos gelsin <cfset tr_topic = htmleditformat(upd_work.WORK_DETAIL)> --->
					<cfset tr_topic =''>
					 <cfmodule
						template="/fckeditor/fckeditor.cfm"
						toolbarSet="WRKContent"
						basePath="/fckeditor/"
						instanceName="work_detail"
						valign="top"
						value="#tr_topic#"
						width="535"
						height="180">
				</td>
			</tr>
			<tr>
				<td><cf_get_lang dictionary_id='38177.İş Kategorisi'> *</td>
				<td><select name="pro_work_cat" id="pro_work_cat" style="width:160px;">
						<option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
						<cfoutput query="get_work_cat">
							<option value="#work_cat_id#"<cfif len(upd_work.work_cat_id) and (upd_work.work_cat_id eq work_cat_id)>selected</cfif>>#work_cat#</option>
						</cfoutput>
					</select>
				</td>
				<td width="80"><cf_get_lang dictionary_id='58053.Başlama Tarihi'></td>
				<td><cfsavecontent variable="message"><cf_get_lang dictionary_id="57471.Eksik Veri"> : <cf_get_lang dictionary_id='58053.Başlama Tarihi'></cfsavecontent>
					<cfinput value="#dateformat(sdate,dateformat_style)#" required="Yes" maxlength="10" validate="#validate_style#" message="#message#" type="text" name="work_h_start" style="width:100px;">
		  			<cf_wrk_date_image date_field="work_h_start">
		  			<cfoutput>
					<select name="start_hour" id="start_hour">
						<cfloop from="0" to="23" index="i">
							<option value="#i#" <cfif i eq shour>selected</cfif>>#i#:00</option>
						</cfloop>
					</select>
		  			</cfoutput>
				</td>
			</tr>
			<tr>
				<td width="90"><cf_get_lang dictionary_id='38175.Tahmini Bütçe'></td>
				<td width="180">
				  	<cfinput type="text" name="expected_budget" style="width:100px;"  value="#TLFormat(upd_work.expected_budget)#" passThrough="onkeyup=""return(FormatCurrency(this,event));""" class="moneybox">
				  	<select name="expected_budget_money" id="expected_budget_money" class="formselect" style="width:58px;">
					<cfinclude template="../query/get_money_currency.cfm">
					<cfoutput query="get_money">
						<option value="#money#"<cfif money is upd_work.expected_budget_money> selected</cfif>>#money#</option>
					</cfoutput>
		  			</select>
				</td>
				<td><cf_get_lang dictionary_id='57700.Bitiş Tarihi'></td>
				<td><cfsavecontent variable="message"><cf_get_lang dictionary_id="57471.Eksik Veri"> : <cf_get_lang dictionary_id='57700.Bitiş Tarihi'></cfsavecontent>
					<cfinput value="#dateformat(fdate,dateformat_style)#" required="Yes" maxlength="10" validate="#validate_style#" message="#message#" type="text" name="work_h_finish" style="width:100px;">
					<cf_wrk_date_image date_field="work_h_finish"><cfoutput>
					<select name="finish_hour" id="finish_hour">
						<cfloop from="0" to="23" index="i">
							<option value="#i#" <cfif i eq fhour>selected</cfif>>#i#:00</option>
						</cfloop>
						</select>
					</cfoutput>
				</td>
			</tr>
			<cfif isdefined('upd_work.estimated_time') and len(upd_work.estimated_time)>
				<cfset liste=#upd_work.estimated_time#/60>
				<cfset saat=#listfirst(liste,'.')#>
				<cfset dak=#upd_work.estimated_time#-saat*60>
			</cfif>
			<tr>
				<td><cf_get_lang dictionary_id='38215.Öngörülen Süre'></td>
				<td>
					<cfsavecontent variable="message"><cf_get_lang dictionary_id='38136.Tahmini Süre girmelisiniz'></cfsavecontent>
					<cfinput type="text" name="estimated_time" validate="integer" message="#message#" value="#saat#" style="width:63px;">&nbsp;<cf_get_lang dictionary_id='57491.Saat'>&nbsp;
					<cfsavecontent variable="message"><cf_get_lang dictionary_id='31894.0-59 Arası Giriniz'></cfsavecontent>
					<cfinput type="text" name="estimated_time_minute" value="#dak#" style="width:63;" range="0,59" message="#message#">&nbsp; <cf_get_lang dictionary_id='58827.Dk'>.
				</td>
				<td><cf_get_lang dictionary_id='57569.Görevli'> *</td>
				  	<cfif upd_work.project_emp_id neq 0 and len(upd_work.project_emp_id)>
						<cfset person="#get_emp_info(upd_work.project_emp_id,0,0)#">
				  	<cfelseif upd_work.outsrc_partner_id neq 0 and len(upd_work.outsrc_partner_id)>
						<cfset person="#get_par_info(upd_work.outsrc_partner_id,0,0,0)#">
				  	<cfelse>
						<cfset person="">
				  	</cfif>
				<td>
					<input type="hidden" name="task_company_id" id="task_company_id" value="<cfoutput>#upd_work.outsrc_cmp_id#</cfoutput>">
					<input type="hidden" name="task_partner_id" id="task_partner_id" value="<cfoutput>#upd_work.outsrc_partner_id#</cfoutput>">
					<input type="hidden" name="project_emp_id" id="project_emp_id" value="<cfoutput>#upd_work.project_emp_id#</cfoutput>">
					<cfsavecontent variable="message1"><cf_get_lang dictionary_id='57569.Görevli'></cfsavecontent>
					<cf_wrk_employee_positions form_name='upd_work' emp_id='project_emp_id' emp_name='responsable_name'>
					<cfinput type="text" name="responsable_name" onKeyUp="get_emp_pos_1();" required="yes" message="#message1#" value="#person#" style="width:178px;">
					<a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_list_positions&field_partner=upd_work.task_partner_id&field_comp_id=upd_work.task_company_id&field_emp_id=upd_work.project_emp_id&field_name=upd_work.responsable_name&field_comp_name=upd_work.responsable_name&select_list=1,7</cfoutput>','list');"><img src="/images/plus_thin.gif" title="<cf_get_lang dictionary_id='38201.Görevli Seç'>" align="absmiddle" border="0"></a>
				</td>
			</tr>
			<tr>
				<td><cf_get_lang dictionary_id='38306.Gerçekleşen Süre'></td>
				<td>
					<input type="text" name="total_time_hour" id="total_time_hour" value="" style="width:63;">&nbsp;<cf_get_lang dictionary_id='57491.Saat'>&nbsp;
					<cfsavecontent variable="message"><cf_get_lang dictionary_id='31894.0-59 Arası Giriniz'></cfsavecontent>
					<cfinput type="text" name="total_time_minute" value="" style="width:63;" range="0,59" message="#message#">&nbsp;<cf_get_lang dictionary_id='58827.Dk'>.
				</td>
				<td>CC</td>
				<td>
					<cfif upd_work.cc_emp_id neq 0 and len(upd_work.cc_emp_id)>
						<cfset person="#get_emp_info(upd_work.cc_emp_id,0,0)#">
				  	<cfelseif upd_work.cc_emp_id neq 0 and len(upd_work.cc_emp_id)>
						<cfset person="#get_par_info(upd_work.cc_emp_id,0,0,0)#">
				  	<cfelse>
						<cfset person="">
				  	</cfif>
					<input type="hidden" name="cc_emp_id" id="cc_emp_id" value="<cfoutput>#upd_work.cc_emp_id#</cfoutput>">
					<cf_wrk_employee_positions form_name='upd_work' emp_id='cc_emp_id' emp_name='cc_name' is_multi_no='2'>
					<cfinput type="text" name="cc_name" value="#person#" onKeyUp="get_emp_pos_2();" style="width:178px;">
					<a href="javascript://" onClick="windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_list_positions&field_emp_id=upd_work.cc_emp_id&field_name=upd_work.cc_name&select_list=1,2</cfoutput>','list');"><img src="/images/plus_thin.gif"  align="absmiddle" border="0"></a>								
				</td>
			</tr>
			<tr>
				<td><cf_get_lang dictionary_id='38307.Tamamlanma'> %</td>
				<td><cfoutput>
					<select name="to_complate" id="to_complate" style="width:60">
						<cfloop from="0" to="100" index="i" step="5">
							<option value="#i#" <cfif upd_work.TO_COMPLETE eq i>selected</cfif>>#i#</option>
						</cfloop>
					</select>
					</cfoutput>
				</td>
				<td><cf_get_lang dictionary_id='58140.İş Grubu'></td>
				<td>
					<select name="workgroup_id" id="workgroup_id" style="width:180px;">				  
					<option value=""><cf_get_lang dictionary_id='58140.İş Grubu'></option>
					<cfoutput query="get_workgroups">
						<option value="#workgroup_id#" <cfif upd_work.workgroup_id eq workgroup_id>selected</cfif>>#workgroup_name#</option>
					</cfoutput>
					</select>
				</td>
			</tr>
			<tr>
				<td><cfif upd_work.work_status eq 1>
						<cfinput type="checkbox" name="work_status" checked="yes"><cf_get_lang dictionary_id='38257.Gündemde'>
					<cfelse>
						<cfinput type="checkbox" name="work_status"><cf_get_lang dictionary_id='38233.Gündemde Değil'>
					</cfif>
				</td>
				<td><input type="checkbox" value="1" name="is_mail" id="is_mail" checked="checked"><cf_get_lang dictionary_id="57475.Mail Gönder"></td>
			</tr>
			<tr>
				<td colspan="2">
				<cfoutput>
					<cf_get_lang dictionary_id='57483.Kayıt'> :
						<cfif len(upd_work.record_author)>#get_emp_info(upd_work.record_author,0,1)#
						<cfelseif len(upd_work.record_par)>#get_par_info(upd_work.record_par,0,-1,1)#
						</cfif>
						<cfset rec_date = date_add('h', session.ep.time_zone, upd_work.record_date)>
						#dateformat(rec_date,dateformat_style)# #Timeformat(rec_date,timeformat_style)# <br/>
						<cfif len(upd_work.update_author) or len(upd_work.update_par)><cf_get_lang dictionary_id='57891.Güncelleyen'> :</cfif> 
						<cfif len(upd_work.update_author)>#get_emp_info(upd_work.update_author,0,1)#<cfelseif len(upd_work.update_par)>#get_par_info(upd_work.update_par,0,-1,1)#</cfif>
						<cfif len(upd_work.update_date)><cfset rec_date = date_add('h', session.ep.time_zone, upd_work.update_date)><cfelse><cfset rec_date = date_add('h', session.ep.time_zone, Now())></cfif>
						<cfif len(upd_work.update_author) or len(upd_work.update_par)>#Dateformat(rec_date,dateformat_style)# #Timeformat(rec_date,timeformat_style)#</cfif>
				</cfoutput>
 				</td>
				<td></td>
				<td><cf_workcube_buttons is_upd='1' add_function='chk_work(#upd_work.project_id#)' delete_page_url='#request.self#?fuseaction=project.emptypopup_delwork&id=#upd_work.work_id#&head=#work_head_#'></td><!--- && OnFormSubmit() --->
			</tr>
		</cfform>
		</table>
	<br/>
	<cfoutput>
	<cfif get_work_history.recordcount>
		<table width="540" cellpadding="0" cellspacing="1" border="0" class="color-border">
		
		<cfif len(upd_work.work_circuit)>
			<tr class="color-header" height="25">
				<td>&nbsp;&nbsp;<a href="http://ep.workcube/#request.self#?fuseaction=#upd_work.work_circuit#.#upd_work.work_fuseaction#" class="tableyazi" target="_blank">http://ep.workcube/#request.self#?fuseaction=#upd_work.work_circuit#.#upd_work.work_fuseaction#</a></td>
			</tr>
		</cfif>
			<tr class="color-list">
				<td height="20" class="txtboldblue">
				<cfoutput>
					<a href="javascript://" onclick="gizle_goster_img('id_1','id_2','works_history');"><img src="/images/listele_down.gif" title="<cf_get_lang dictionary_id='30873.Ayrıntıları Gizle'>"  border="0" align="absmiddle" id="id_1" style="display:;cursor:pointer;"></a>
					<a href="javascript://" onclick="gizle_goster_img('id_1','id_2','works_history');"><img src="/images/listele.gif" title="<cf_get_lang dictionary_id='31094.Ayrıntıları Göster'>" border="0" align="absmiddle" id="id_2" style="display:none;cursor:pointer;"></a>
				</cfoutput>
				<cf_get_lang dictionary_id='57473.Tarihçe'>
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
	<td width="150">&nbsp;</td>
	</tr>
</table>
<br/>
<script type="text/javascript">
function chk_work(pro_id)
{
	if((document.upd_work.pro_id.value>0)&&(document.upd_work.project_id.value>0)&&(document.upd_work.rel_work_id.value!=0)&&(document.upd_work.rel_work_id.value!="")&&(document.upd_work.project_id.value!=pro_id))
		if(confirm("<cf_get_lang dictionary_id ='38317.İlişkilendirilmiş iş seçtiğiniz projeye ait değil.İş ilişkisi silinecek'>!"))
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
	
	x = document.upd_work.priority_cat.selectedIndex;
	if (document.upd_work.priority_cat[x].value == "")
	{ 
		alert ("<cf_get_lang dictionary_id='38299.Öncelik Seçmelisiniz'> !");
		return false;
	}
	x = document.upd_work.pro_work_cat.selectedIndex;
	if (document.upd_work.pro_work_cat[x].value == "")
	{ 
		alert ("<cf_get_lang dictionary_id='38271.İş Kategorisi Seçmelisiniz'>!");
		return false;
	}
	if(document.upd_work.project_id.value != "")
	{
		if(tarih1_ < tarih2_)
		{
			alert("<cf_get_lang dictionary_id ='38314.Girdiğiniz İşin Hedef Başlangıç Tarihi Bağlı Olduğu Projenin Hedef Başlangıç Tarihinden Önce Görünüyor Lütfen Düzeltin'> !");
			return false;			
		}
		if(tarih3_ > tarih4_)
		{
			alert("<cf_get_lang dictionary_id ='38315.Girdiğiniz İşin Hedef Bitiş Tarihi Projesinin Hedef Bitiş Tarihinden Sonra Gözüküyor Lütfen Düzeltin'> !");
			return false;			
		} 
	}
	
	if(tarih1_ > tarih3_ || (tarih1_ == tarih3_ && (parseInt(document.upd_work.start_hour.value) >= parseInt(document.upd_work.finish_hour.value))))
	{
		alert("<cf_get_lang dictionary_id ='38316.Girdiğiniz İşin Başlangıç Tarihi ile Bitiş Tarihi Mantıklı Gözükmüyor Lütfen Düzeltin '>!");
		return false;			
	}	
	
	unformat_fields();
	return process_cat_control();
	return true;
}

function unformat_fields()
{
	fld=document.upd_work.expected_budget;
	fld.value=filterNum(fld.value);
}
</script>
