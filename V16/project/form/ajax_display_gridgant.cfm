<cfset gant_sayac = 0>
<cfquery name="GET_PRO_WORK_ALL" datasource="#dsn#">
	SELECT
		SETUP_PRIORITY.COLOR,
		PRO_WORKS.*
	FROM
		PRO_WORKS,
		SETUP_PRIORITY
	WHERE
		PRO_WORKS.PROJECT_ID = #attributes.id# and
		SETUP_PRIORITY.PRIORITY_ID = PRO_WORKS.WORK_PRIORITY_ID
	ORDER BY
		TARGET_START ASC
</cfquery>
<cfquery name="get_pro_work_cat" datasource="#dsn#">
	SELECT 
		WORK_CAT,
		WORK_CAT_ID
	FROM
		PRO_WORK_CAT
	WHERE
		','+OUR_COMPANY_ID+',' LIKE '%,#session.ep.company_id#,%'
	ORDER BY
		WORK_CAT
</cfquery>
<cf_workcube_process_info>
<cfif len(process_rowid_list)>
	<cfquery name="GET_STAGE" datasource="#dsn#">
	SELECT 
		STAGE,
		PROCESS_ROW_ID
	FROM
		PROCESS_TYPE_ROWS
	WHERE
		PROCESS_ROW_ID IN (#process_rowid_list#)
	</cfquery>
</cfif>
<cfinclude template="../query/get_priority.cfm">
<table cellpadding="0" cellspacing="0" width="98%">
	<tr>
		<td height="25" class="txtboldblue"><cf_get_lang dictionary_id='58020.İşler'></td>
	</tr>
</table>
<table cellspacing="1" cellpadding="2" width="100%" border="0" class="color-border" id="work_table" >
<cfform name="add_fast_work" method="post" action="#request.self#?fuseaction=project.emptypopup_add_fast_work&id=#id#">
	<tr class="color-header" height="50">
		<td class="form-title"><cf_get_lang dictionary_id='57487.No'></td>
		<td class="form-title"><cf_get_lang dictionary_id='38213.İş'></td>
		<td class="form-title"><cf_get_lang dictionary_id='57569.Görevli'></td>
		<td class="form-title"><cf_get_lang dictionary_id='58053.Başlangıç Tarihi'></td>
		<td class="form-title" nowrap="nowrap"><cf_get_lang dictionary_id='57700.Bitiş Tarihi'></td>
		<td class="form-title"><cf_get_lang dictionary_id='57485.Öncelik'></td>
		<td class="form-title"><cf_get_lang dictionary_id='57486.Kategori'></td>
		<td class="form-title"><cf_get_lang dictionary_id='57482.Aşama'></td>
		<td align="right" class="form-title" style="text-align:right;">%</td>
		<td></td>
		<td class="form-title"></td>
		<td></td>
		<td width="420" nowrap><div id="gant_header_id"></div></td>
	</tr>
<cfif GET_PRO_WORK_ALL.RECORDCOUNT>
	<cfquery name="GET_PRO_WORK" dbtype="query"><!--- ANA İŞLER --->
		SELECT
			*
		FROM
			GET_PRO_WORK_ALL
		WHERE
			RELATED_WORK_ID = 0 OR RELATED_WORK_ID IS NULL
	</cfquery>
	<cfset rec_line=0>
	<cfoutput query="GET_PRO_WORK">
		<cfset rec_line = rec_line+1>	
		<cfset _PROJECT_EMP_ID_ = PROJECT_EMP_ID>
		<cfif len(_PROJECT_EMP_ID_)>
			<cfquery name="get_pro_work_emp" datasource="#dsn#">
				SELECT
					EMPLOYEE_NAME,
					EMPLOYEE_SURNAME
				FROM
					EMPLOYEES
				WHERE
					EMPLOYEES.EMPLOYEE_ID = #_PROJECT_EMP_ID_#
			</cfquery>
		</cfif>
		<cfscript>
			s_date=date_add('h', session.ep.time_zone, target_start);
			f_date=date_add('h', session.ep.time_zone, target_finish);
			s_hour=datepart('h',s_date);
			f_hour=datepart('h',f_date);
		</cfscript>
		<tr height="20" class="color-row" id="frm_row#rec_line#">				
			<cfset gant_sayac = gant_sayac + 1> <!--- gant şeması sayacı için --->
			<td nowrap>#rec_line#</td>
			<td nowrap><input type="text" name="work_head#rec_line#" id="work_head#rec_line#" value="#WORK_HEAD#" style="width:100px;color:#COLOR#" class="boxtext"></td>
			<td nowrap>
				<input type="hidden" name="study_emp_id#rec_line#" value="#PROJECT_EMP_ID#" id="study_emp_id#rec_line#">
				<input name="study_name#rec_line#" type="text" class="boxtext" id="study_name#rec_line#" style="width:100px;" onFocus="AutoComplete_Create('study_name#rec_line#','FULLNAME','FULLNAME','get_emp_pos','','EMPLOYEE_ID','study_emp_id#rec_line#','','3','200')" value="<cfif len(get_pro_work_emp.EMPLOYEE_NAME)>#get_pro_work_emp.EMPLOYEE_NAME#</cfif><cfif len(get_pro_work_emp.EMPLOYEE_SURNAME)>#get_pro_work_emp.EMPLOYEE_SURNAME#</cfif>" required="yes" autocomplete="off">
				<input type="hidden" name="hidden_work_head#rec_line#" id="hidden_work_head#rec_line#" value="<cfif isdefined('GET_PRO_WORK.work_id') and len(GET_PRO_WORK.work_id)>#GET_PRO_WORK.work_id#</cfif>">
			</td>
			<td nowrap>
				<input type="text" name="work_start#rec_line#" id="work_start#rec_line#" onblur="gant_work_row_(#rec_line#);" required="Yes" validate="#validate_style#"  maxlength="10" class="boxtext" value="#Dateformat(TARGET_START,dateformat_style)#" style="width:70px;color:#COLOR#">
					<cf_wrk_date_image date_field="work_start#rec_line#" date_form="add_fast_work">
				<select name="start_hour#rec_line#" id="start_hour#rec_line#" class="boxtext" style="width:55px;color:#COLOR#">
					<cfloop from="0" to="23" index="i">
						<option value="#i#" <cfif i eq s_hour>selected</cfif>>#i#:00</option>
					</cfloop>
				</select>
			</td>
			<td nowrap>
				<input type="text" name="work_finish#rec_line#" id="work_finish#rec_line#" onblur="gant_work_row_(#rec_line#);" value="#DateFormat(TARGET_FINISH,dateformat_style)#" validate="#validate_style#" class="boxtext" maxlength="10" style="width:70px;color:#COLOR#">
				<cf_wrk_date_image date_field="work_finish#rec_line#" date_form="add_fast_work">
				<select name="finish_hour#rec_line#" id="finish_hour#rec_line#" class="boxtext" style="width:55px;color:#COLOR#">
					<cfloop from="0" to="23" index="i">
						<option value="#i#" <cfif i eq f_hour>selected</cfif>>#i#:00</option>
					</cfloop>
				</select>
			</td>
			<td nowrap class="boxtext">
				<select name="priority_cat#rec_line#" id="priority_cat#rec_line#" style="width:50px;color:#COLOR#">
					<option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
					<cfloop query="get_cats">
						<option value="#priority_id#" <cfif GET_PRO_WORK.work_priority_id eq priority_id>selected</cfif>>#priority#</option>
					</cfloop>
				</select>
			</td>
			<td nowrap class="boxtext">
				<select name="work_cat#rec_line#" id="work_cat#rec_line#" style="width:80px;color:#COLOR#">
					<option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
					<cfloop query="get_pro_work_cat">
						<option value="#work_cat_id#" <cfif GET_PRO_WORK.work_cat_id eq work_cat_id>selected</cfif>>#work_cat#</option>
					</cfloop>
				</select>
			</td>
			<td nowrap class="boxtext">
				<select name="stage#rec_line#" id="stage#rec_line#" style="width:70px;color:#COLOR#">
					<option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
					<cfloop query="GET_STAGE">
						<option value="#PROCESS_ROW_ID#"<cfif GET_PRO_WORK.WORK_CURRENCY_ID eq PROCESS_ROW_ID>selected</cfif>>#STAGE#</option>
					</cfloop>
				</select>
			</td>
			<td nowrap>
				<input type="text" name="is_complate#rec_line#" onkeyup="isNumber(this);" onblur="GraphSwaping(this.value,#work_id#)" id="complate_ratio#work_id#" class="boxtext" style="width:25;color:#COLOR#" maxlength="3" value="<cfif len(to_complete)>#to_complete#<cfelse>0</cfif>">
			</td>
			<td nowrap>
			<div id="graph#work_id#" style="display:none"></div>
				<table width="100" border="0" cellpadding="0" cellspacing="0" id="table#work_id#" name="table#work_id#">
					<tr height="20">
					<cfif isdefined('to_complete') and len(to_complete)>
						<td bgcolor="66CC33" width="#to_complete#"><div style="position:absolute;z-index:9998;width:50px;height:18px;"><table cellpadding="0" cellspacing="0" width="100"><tr><td><cfif to_complete gt 0>%#to_complete#</cfif></td><td align="right" style="text-align:right;"><cfif (100-to_complete) gt 0>%#evaluate(100-to_complete)#</cfif></td></tr></table></div></td>
						<td width="#evaluate(100-to_complete)#" align="right" bgcolor="3399FF" style="text-align:right;">&nbsp;</td>
					</cfif>
					</tr>
			   </table>
			</td>
			<td nowrap><input type="checkbox" name="active#rec_line#" id="active#rec_line#" <cfif GET_PRO_WORK.work_status eq 1>checked</cfif>></td>
			<td nowrap><a href="JavaScript://" onClick="related_work_tr_#rec_line#.style.display='';AjaxPageLoad('#request.self#?fuseaction=project.emptypopup_upd_work_ajax_gant&new_line='+document.getElementById('last_record').value+'&related_work=#GET_PRO_WORK.WORK_ID#&process_rowid_list=#process_rowid_list#','related_work#rec_line#','1','Lütfen Bekleyin');"><img src="images/plus_list.gif" border="0" title="<cf_get_lang dictionary_id ='57707.Satır Ekle'>"></a></td>
			<td nowrap><div id="gant_work_row#rec_line#"></div></td>
		</tr>
		<tr class="color-header" id="related_work_tr_#rec_line#" style="display:none;">
			<td colspan="12">
				<div id="related_work#rec_line#"></div>
			</td>
			<td></td>
		</tr>
		<cfset level = 1>
		<cffunction name="func_related_work" output="yes" returntype="void">
		<cfargument name="fn_work_id" type="numeric">
			<cfquery name="GET_SUB_PRO_WORK_#arguments.fn_work_id#" dbtype="query"><!--- ilişkili alt işler --->
				SELECT
					*
				FROM
					GET_PRO_WORK_ALL
				WHERE
					RELATED_WORK_ID = #arguments.fn_work_id#
			</cfquery>
			<cfset sub_count = evaluate('GET_SUB_PRO_WORK_#arguments.fn_work_id#.RECORDCOUNT')>
			<cfif evaluate('GET_SUB_PRO_WORK_#arguments.fn_work_id#.RECORDCOUNT')>
				<cfloop query="GET_SUB_PRO_WORK_#arguments.fn_work_id#">
					<cfscript>
						s_date=date_add('h', session.ep.time_zone, target_start);
						f_date=date_add('h', session.ep.time_zone, target_finish);
						s_hour=datepart('h',s_date);
						f_hour=datepart('h',f_date);
					</cfscript>
					<cfset rec_line=rec_line + 1>
					<tr class="color-list"><!--- İlişkili İşler --->
						<cfset emp_id =#evaluate('GET_SUB_PRO_WORK_#arguments.fn_work_id#.PROJECT_EMP_ID')#>
						<cfif len(emp_id)>
							<cfquery name="get_sub_pro_work_emp" datasource="#dsn#">
								SELECT EMPLOYEE_NAME,EMPLOYEE_SURNAME FROM  EMPLOYEES WHERE	EMPLOYEES.EMPLOYEE_ID = #emp_id#
							</cfquery>
						</cfif>
						<cfset gant_sayac = gant_sayac + 1><!--- gant şeması sayacı için --->
						<td>#rec_line#</td>
						<td>#RepeatString('&nbsp;&nbsp;&nbsp;',level)#<input type="text" name="work_head#rec_line#" id="work_head#rec_line#" value="#evaluate('GET_SUB_PRO_WORK_#arguments.fn_work_id#.WORK_HEAD')#" style="width:100px;color:#COLOR#" class="boxtext"></td>
						<td>
							<input type="hidden" name="study_emp_id#rec_line#"  value="#evaluate('GET_SUB_PRO_WORK_#arguments.fn_work_id#.PROJECT_EMP_ID')#" id="study_emp_id#rec_line#">
							<input name="study_name#rec_line#" type="text" class="boxtext" id="study_name#rec_line#" style="width:100px;" onFocus="AutoComplete_Create('study_name#rec_line#','FULLNAME','FULLNAME','get_emp_pos','','EMPLOYEE_ID','study_emp_id#rec_line#','','3','200')" value="<cfif len(evaluate('GET_SUB_PRO_WORK_#arguments.fn_work_id#.PROJECT_EMP_ID'))>#get_sub_pro_work_emp.EMPLOYEE_NAME# #get_sub_pro_work_emp.EMPLOYEE_SURNAME#</cfif>" required="yes" autocomplete="off">
							<input type="hidden" name="hidden_work_head#rec_line#" id="hidden_work_head#rec_line#" value="#evaluate('GET_SUB_PRO_WORK_#arguments.fn_work_id#.work_id')#">
						</font></td>
						<td nowrap="nowrap">
							<input type="text" name="work_start#rec_line#" id="work_start#rec_line#" onblur="gant_work_row_(#rec_line#);" required="Yes" validate="#validate_style#"  maxlength="10" class="boxtext" value="#Dateformat(evaluate('GET_SUB_PRO_WORK_#arguments.fn_work_id#.TARGET_START'),dateformat_style)#" style="width:70px;color:#COLOR#">
							<cf_wrk_date_image date_field="work_start#rec_line#" date_form="add_fast_work">
							<select name="start_hour#rec_line#" id="start_hour#rec_line#" class="boxtext" style="width:55px;color:#COLOR#">
								<cfloop from="0" to="23" index="i">
									<option value="#i#" <cfif i eq s_hour>selected</cfif>>#i#:00</option>
								</cfloop>
							</select>
						</td>
						<td nowrap="nowrap">
							<input type="text" name="work_finish#rec_line#" id="work_finish#rec_line#" onblur="gant_work_row_(#rec_line#);" value="#DateFormat(evaluate('GET_SUB_PRO_WORK_#arguments.fn_work_id#.TARGET_FINISH'),dateformat_style)#" validate="#validate_style#" class="boxtext" maxlength="10" style="width:70px;color:#COLOR#">
							<cf_wrk_date_image date_field="work_finish#rec_line#" date_form="add_fast_work">
							<select name="finish_hour#rec_line#" id="finish_hour#rec_line#" class="boxtext" style="width:55px;color:#COLOR#">
								<cfloop from="0" to="23" index="i">
									<option value="#i#" <cfif i eq f_hour>selected</cfif>>#i#:00</option>
								</cfloop>
							</select>
						</td>
						<td class="boxtext">
							<select name="priority_cat#rec_line#" id="priority_cat#rec_line#" style="width:50px;color:#COLOR#">
								<option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
								<cfloop query="get_cats">
									<option value="#priority_id#" <cfif evaluate('GET_SUB_PRO_WORK_#arguments.fn_work_id#.work_priority_id') eq priority_id>selected</cfif>>#priority#</option>
								</cfloop>
							</select>
						</td>
						<td class="boxtext">
							<select name="work_cat#rec_line#" id="work_cat#rec_line#" style="width:80px;color:#COLOR#">
								<option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
								<cfloop query="get_pro_work_cat">
									<option value="#work_cat_id#" <cfif evaluate('GET_SUB_PRO_WORK_#arguments.fn_work_id#.work_cat_id') eq work_cat_id>selected</cfif>>#work_cat#</option>
								</cfloop>
							</select>
						</td>
						<td class="boxtext">
							<select name="stage#rec_line#" id="stage#rec_line#" style="width:70px;color:#COLOR#">
								<option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
								<cfloop query="GET_STAGE">
									<option value="#PROCESS_ROW_ID#"<cfif evaluate('GET_SUB_PRO_WORK_#arguments.fn_work_id#.WORK_CURRENCY_ID') eq PROCESS_ROW_ID>selected</cfif>>#STAGE#</option>
								</cfloop>
							</select>
						</td>
						<td><input type="text" name="is_complate#rec_line#" onkeyup="isNumber(this);" id="complate_ratio#work_id#" onblur="GraphSwaping(this.value,#work_id#)" class="boxtext" style="width:25;color:#COLOR#" maxlength="3" value="<cfif len(evaluate('GET_SUB_PRO_WORK_#arguments.fn_work_id#.to_complete'))>#evaluate('GET_SUB_PRO_WORK_#arguments.fn_work_id#.to_complete')#<cfelse>0</cfif>"></td>
						<td>
							<div id="graph#work_id#" style="display:none"></div>
							<table width="100" border="0" cellpadding="0" cellspacing="0" id="table#work_id#" name="table#work_id#">
								<tr height="20">
								<cfif isdefined('to_complete') and len(to_complete)>
									<td bgcolor="66CC33" width="#to_complete#"><div style="position:absolute;z-index:9998;width:50px;height:18px;"><table cellpadding="0" cellspacing="0" width="100"><tr><td><cfif to_complete gt 0>%#to_complete#</cfif></td><td align="right" style="text-align:right;"><cfif (100-to_complete) gt 0>%#evaluate(100-to_complete)#</cfif></td></tr></table></div></td>
									<td width="#evaluate(100-to_complete)#" align="right" bgcolor="3399FF" style="text-align:right;">&nbsp;</td>
								</cfif>
								</tr>
							</table>
						</td>
						<td><input type="checkbox" name="active#rec_line#" id="active#rec_line#" <cfif evaluate('GET_SUB_PRO_WORK_#arguments.fn_work_id#.work_status') eq 1>checked</cfif>></td>
						<td nowrap="nowrap"><a href="JavaScript://" onClick="related_work_tr_#rec_line#.style.display='';AjaxPageLoad('#request.self#?fuseaction=project.emptypopup_upd_work_ajax_gant&new_line='+document.getElementById('last_record').value+'&related_work=#evaluate('GET_SUB_PRO_WORK_#arguments.fn_work_id#.WORK_ID')#&process_rowid_list=#process_rowid_list#','related_work#rec_line#','1','Lütfen Bekleyin');"><img src="images/plus_list.gif" border="0" title="<cf_get_lang dictionary_id ='57707.Satır Ekle'>"></a></td>
						<td><div id="gant_work_row#rec_line#"></div></td>
					</tr>
					<tr class="color-header" id="related_work_tr_#rec_line#" style="display:none;">
						<td colspan="12"><div id="related_work#rec_line#"></div></td>
						<td></td>
					</tr>
					<cfscript>
						if(len(evaluate('GET_SUB_PRO_WORK_#arguments.fn_work_id#.work_status')))
							{
								level =  level+1;
								func_related_work(fn_work_id:evaluate('GET_SUB_PRO_WORK_#arguments.fn_work_id#.WORK_ID'));
							}
					</cfscript>
				</cfloop>
			</cfif>
		<cfset level =  level-1>	
		</cffunction>
		<cfscript>
			func_related_work(fn_work_id:WORK_ID);
        </cfscript>
	</cfoutput>
	<tr class="color-row">
		<td colspan="13" align="right" style="text-align:right;">
			<input type="hidden" name="last_record" id="last_record" value="<cfoutput>#GET_PRO_WORK_ALL.RECORDCOUNT#</cfoutput>">
			<cf_workcube_buttons is_upd='0' add_function='control()'>
		</td>
	</tr>
<cfelse>
	<tr class="color-row">
		<td colspan="13"><cf_get_lang dictionary_id ='57484.Kayıt Yok'> !</td>
	</tr>
</cfif>
</cfform>
</table>
<script type="text/javascript">
function control()
{
	var line_unit = document.add_fast_work.last_record.value;
	for(var x=1;x<=line_unit;x++)
	{
		deger_study_name = eval("document.add_fast_work.study_name"+x);
		deger_work_start = eval("document.add_fast_work.work_start"+x);
		deger_finish_start = eval("document.add_fast_work.work_finish"+x);
		deger_head = eval("document.add_fast_work.work_head"+x);
		deger_priority = eval("document.add_fast_work.priority_cat"+x);
		deger_work_cat = eval("document.add_fast_work.work_cat"+x);
		deger_stage = eval("document.add_fast_work.stage"+x);
	
		if (deger_study_name.value == "")
			{
				alert(''+x+'.<cf_get_lang dictionary_id="57471.Eksik Veri"> : <cf_get_lang dictionary_id ="57569.Görevli">');
				return false;
			}
		if(deger_work_start.value == "")
			{
				alert(''+x+'.<cf_get_lang dictionary_id="57471.Eksik Veri"> : <cf_get_lang dictionary_id ="58053.Başlangıç Tarihi">');
				return false;
			}
		if (deger_finish_start.value == "")
			{
				alert(''+x+'.<cf_get_lang dictionary_id="57471.Eksik Veri"> : <cf_get_lang dictionary_id ="57700.Bitiş Tarihi">');
				return false;
			}
		if (deger_head.value == "")
			{
				alert(''+x+'.<cf_get_lang dictionary_id="57471.Eksik Veri"> : <cf_get_lang dictionary_id ="58445.İş"> <cf_get_lang dictionary_id ="57897.Adı">');
				return false;
			}
		if (deger_priority.value == "")
			{
				alert(''+x+'.<cf_get_lang dictionary_id ="38428.satır için iş önceliği giriniz">!');
				return false;
			}
		if (deger_work_cat.value == "")
			{
				alert(''+x+'.<cf_get_lang dictionary_id="57471.Eksik Veri"> : <cf_get_lang dictionary_id ="38177.İş Kategorisi">');
				return false;
			}
		if (deger_stage.value == "")
			{
				alert(''+x+'.<cf_get_lang dictionary_id="38430.satır için iş aşaması giriniz">!');
				return false;
			}
		}
}
function GraphSwaping(deger,work_id)
{
	if(deger <= 100)
	{
		div_id = 'graph'+work_id;
		if(document.getElementById('complate_ratio'+work_id) != undefined && document.getElementById('complate_ratio'+work_id).value!= '')
		{
			goster(eval('graph'+work_id));
			gizle(eval('table'+work_id));
			var send_address = '<cfoutput>#request.self#</cfoutput>?fuseaction=project.emptypopup_ajax_graph_ratio&work_id='+ work_id +'&deger='+deger;
			AjaxPageLoad(send_address,div_id,1,'Yükleniyor');
		}
	}
	else if (deger > 100)
	{
		alert("<cf_get_lang dictionary_id ='38338.Tamamlanma Orani 100 den kucük bir rakam olmalidir'>!");
		return false;
	}
}
function ajax_gant_load(type,gelen_tarih_)
{
	if(type=='' && gelen_tarih_=='')
		AjaxPageLoad('<cfoutput>#request.self#?fuseaction=project.emptypopup_transition_gant_calender&gant_sayac_=#gant_sayac#&project_id=#attributes.id#'</cfoutput>,'gant_header_id','1','Lutfen Bekleyin');
	else
		AjaxPageLoad('<cfoutput>#request.self#?fuseaction=project.emptypopup_transition_gant_calender&gant_sayac_=#gant_sayac#&project_id=#attributes.id#</cfoutput>&type='+ type +'&gelen_date=' + gelen_tarih_,'gant_header_id','1','Lutfen Bekleyin');
}
	ajax_gant_load('','');

function gant_work_row_(as)
	{
		var page_target_start = document.getElementById('work_start'+as).value;
		var page_target_finish = document.getElementById('work_finish'+as).value;
		AjaxPageLoad('<cfoutput>#request.self#?fuseaction=project.emptypopup_gant_work_row&page_target_finish='+page_target_finish+'&type1='+1+'&page_target_start='+page_target_start+'&project_id=#attributes.id#','gant_work_row'+as+'</cfoutput>','1','Lütfen Bekleyin');
	}
</script>
