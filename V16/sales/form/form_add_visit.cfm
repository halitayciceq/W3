<cfsetting showdebugoutput="no">
<cfset xml_page_control_list = 'is_agenda_authority,select_popup_type,xml_multiple_comp'>
<cf_xml_page_edit fuseact="sales.form_add_visit" page_control_list="#xml_page_control_list#" default_value="0">
<!--- <cfquery name="GET_EVENT_CATS" datasource="#DSN#">
	SELECT EVENTCAT_ID,EVENTCAT FROM EVENT_CAT ORDER BY EVENTCAT
</cfquery> --->

<cfquery name="GET_VISIT_TYPES" datasource="#DSN#">
	SELECT VISIT_TYPE_ID,VISIT_TYPE FROM SETUP_VISIT_TYPES ORDER BY VISIT_TYPE
</cfquery>
<cfquery name="GET_COMPANIES" datasource="#DSN#">
    SELECT COMP_ID,NICK_NAME FROM OUR_COMPANY WHERE COMP_STATUS = 1 ORDER BY COMPANY_NAME
</cfquery>
<cfquery name="GET_BRANCH" datasource="#dsn#">
	SELECT
		DISTINCT B.BRANCH_ID,
		B.BRANCH_NAME
	FROM
		BRANCH B,
		EMPLOYEE_POSITION_BRANCHES EPB
	WHERE
		B.BRANCH_ID = EPB.BRANCH_ID AND
		EPB.POSITION_CODE = #session.ep.position_code#
	ORDER BY
		B.BRANCH_NAME
</cfquery>
<cfif isdefined('attributes.visit_id') and len(attributes.visit_id)>
    <cfquery name="GET_EVENT_PLAN" datasource="#DSN#">
        SELECT * FROM EVENT_PLAN WHERE EVENT_PLAN_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.visit_id#">
    </cfquery>
</cfif>
<cfif isdefined('attributes.project_id')>
    <cfquery name="get_project_head" datasource="#dsn#">
        SELECT  PROJECT_HEAD,PROJECT_ID FROM PRO_PROJECTS WHERE PROJECT_ID=#attributes.project_id#
    </cfquery>
</cfif>
<!--- Özel rapor için eklendi. silmeyin [h.gul]--->
<cfparam name="attributes.convert_row_count" default="">
<cfparam name="attributes.convert_company_id" default="">
<cfparam name="attributes.convert_partner_id" default="">
<cfparam name="attributes.totalrecord" default="0">
<!--- Özel rapor için eklendi. silmeyin --->
<cf_catalystHeader>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box>
		<cfform name="add_event" id="add_event" method="post" action="#request.self#?fuseaction=sales.emptypopup_add_warning">
			<cf_basket_form id="add_visit">
				<cf_box_elements>
					<div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
						<div class="form-group" id="item-warning_head">
							<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='41027.Plan Adı'>*</label>
							<div class="col col-8 col-xs-12"> 
								<cfif isdefined("get_event_plan.event_plan_head") and len(get_event_plan.event_plan_head)>
									<cfinput type="text" name="warning_head" id="warning_head" style="width:182px;" required="Yes" maxlength="100" value="#get_event_plan.event_plan_head#">
								<cfelse>
									<cfinput type="text" name="warning_head" id="warning_head" style="width:182px;" required="Yes"  maxlength="100" value="">
								</cfif>
							</div>
						</div>
						<div class="form-group" id="item-process">
							<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id="58859.Süreç"></label>
							<div class="col col-8 col-xs-12"> 
								<cfif isdefined('get_event_plan')>
									<cf_workcube_process is_upd='0' select_value='#get_event_plan.event_status#'  process_cat_width='183' is_detail='0'>
								<cfelse>
									<cf_workcube_process is_upd='0' process_cat_width='182' is_detail='0'>
								</cfif>
							</div>
						</div>
						
						<div class="form-group" id="item-analyse_head">
							<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='40943.Analiz Formu'><cfif x_form_visit eq 1>*</cfif></label>
							<div class="col col-8 col-xs-12"> 
								<div class="input-group">
									<cfif isdefined('get_event_plan')  and len(get_event_plan.analyse_id)>
										<cfquery name="GET_ANALYSIS" datasource="#DSN#">
											SELECT ANALYSIS_HEAD FROM MEMBER_ANALYSIS WHERE ANALYSIS_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_event_plan.analyse_id#">
										</cfquery>
									</cfif>
									<cfoutput> 
										<input type="hidden" name="prjct_id" id="prjct_id" value="<cfif isdefined("attributes.project_id") and len(attributes.project_id)>#get_project_head.project_id#</cfif>"> 
										<input type="hidden" name="project_head" id="project_head" value="<cfif isdefined("attributes.project_id") and len(attributes.project_id)>#get_project_head.project_head#</cfif>"> 
										<input type="hidden" name="analyse_id" id="analyse_id" value="<cfif isdefined('get_event_plan')>#get_event_plan.analyse_id#</cfif>">
										<input type="text" name="analyse_head" id="analyse_head" style="width:182px;" value="<cfif isdefined('get_event_plan') and isdefined('GET_ANALYSIS')>#get_analysis.analysis_head#</cfif>">
									</cfoutput>
									<span class="input-group-addon icon-ellipsis btnPointer" onClick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_analyse&field_id=add_event.analyse_id&field_name=add_event.analyse_head');"></span>
								</div>
							</div>
						</div>
						<div class="form-group" id="item-sales_zones">
							<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='51554.Yetkili Şubeler'>*</label>
							<div class="col col-8 col-xs-12"> 
								<select name="sales_zones" id="sales_zones" style="width:180px;">
									<option value=""><cf_get_lang dictionary_id='57453.Şube'></option>
									<cfoutput query="get_branch">
										<option value="#branch_id#" <cfif isdefined('get_event_plan')><cfif get_event_plan.sales_zones eq branch_id>selected</cfif></cfif>>#branch_name#</option>
									</cfoutput>
								</select>
							</div>
						</div>
					</div>
					<div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="2" sort="true">
						<div class="form-group" id="item-main_dates">
							<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57742.Tarih'>*</label>
							<div class="col col-4 col-xs-12"> 
								<div class="input-group">
									<cfif isdefined('get_event_plan')>
										<cfinput  type="text"  name="main_start_date" id="main_start_date" style="width:65px" validate="#validate_style#"  value="#dateformat(get_event_plan.main_start_date,dateformat_style)#" required="yes">
									<cfelseif isdefined('attributes.is_detail_search')>
										<cfinput type="text"  name="main_start_date" id="main_start_date" style="width:65" validate="#validate_style#" value="#dateformat(now(),dateformat_style)#" required="yes">
									<cfelse>
										<cfinput type="text"  name="main_start_date" id="main_start_date" style="width:65px" validate="#validate_style#"  value="" required="yes">
									</cfif>
									<span class="input-group-addon"><cf_wrk_date_image date_field="main_start_date"></span>
								</div>
							</div>
							<div class="col col-4 col-xs-12">
								<div class="input-group">
									<cfif isdefined('get_event_plan')>
										<cfinput  type="text"  name="main_finish_date" id="main_finish_date" style="width:65px" validate="#validate_style#"  value="#dateformat(get_event_plan.main_finish_date,dateformat_style)#" required="yes">
									<cfelseif isdefined('attributes.is_detail_search')>
										<cfinput type="text"  name="main_finish_date"  id="main_finish_date"style="width:65px" validate="#validate_style#"  value="#dateformat(now(),dateformat_style)#" required="yes">
									<cfelse>
										<cfinput type="text"  name="main_finish_date" id="main_finish_date" style="width:65px" validate="#validate_style#" value="" required="yes">
									</cfif>
									<span class="input-group-addon"><cf_wrk_date_image date_field="main_finish_date"></span>
								</div>
							</div>
						</div>
						<div class="form-group" id="item-event_detail">
							<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57629.Açıklama'></label>
							<div class="col col-8 col-xs-12"> 
								<textarea name="event_detail" id="event_detail" style="width:180px;height:65px;"><cfif isdefined('get_event_plan')><cfoutput>#get_event_plan.detail#</cfoutput></cfif></textarea>
								<input type="hidden" name="hidden_is_agenda_authorize" id="hidden_is_agenda_authorize"value="<cfif isdefined('is_agenda_authority')><cfoutput>#is_agenda_authority#</cfoutput></cfif>"><!--- xml için --->
							</div>
						</div>
					</div>
					<cfif isdefined('is_agenda_authority') and (is_agenda_authority eq 1)>
						<cfquery name="FIND_DEPARTMENT_BRANCH" datasource="#DSN#">
							SELECT
								EMPLOYEE_POSITIONS.EMPLOYEE_ID,
								EMPLOYEE_POSITIONS.POSITION_ID,
								EMPLOYEE_POSITIONS.POSITION_CODE,
								BRANCH.BRANCH_ID,
								BRANCH.BRANCH_NAME,
								DEPARTMENT.DEPARTMENT_ID,
								DEPARTMENT.DEPARTMENT_HEAD
							FROM
								EMPLOYEE_POSITIONS,
								DEPARTMENT,
								BRANCH
							WHERE
								EMPLOYEE_POSITIONS.DEPARTMENT_ID = DEPARTMENT.DEPARTMENT_ID AND
								DEPARTMENT.BRANCH_ID = BRANCH.BRANCH_ID AND
								EMPLOYEE_POSITIONS.POSITION_CODE = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.position_code#">
						</cfquery>
						<div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="3" sort="true">
							<div class="form-group" id="item-view_to_all">
								<label class="col col-12"><input type="checkbox" name="view_to_all" id="view_to_all" <cfif not isdefined('get_event_plan')><cfif is_choose_ajenda is "3">checked</cfif></cfif>  value="1" <cfif isdefined('get_event_plan')><cfif get_event_plan.view_to_all eq 1 and not len(get_event_plan.is_wiew_branch) and not len(get_event_plan.is_wiew_department)>checked</cfif></cfif> onClick="wiew_control(1);"> <cf_get_lang dictionary_id ='40970.Bu olayı herkes Görsün'></label>
							</div>
							<div class="form-group" id="item-is_wiew_branch">
								<label class="col col-12"><input type="checkbox" name="is_wiew_branch" id="is_wiew_branch" <cfif not isdefined('get_event_plan')><cfif is_choose_ajenda is "2">checked</cfif></cfif>  value="<cfoutput>#find_department_branch.branch_id#</cfoutput>" <cfif isdefined('get_event_plan')><cfif len(get_event_plan.is_wiew_branch) and not len(get_event_plan.is_wiew_department)>checked</cfif></cfif> onClick="wiew_control(2);"> <cf_get_lang dictionary_id ='57914.Şubemdeki Herkes Görsün'></label>
							</div>
							<div class="form-group" id="item-is_wiew_department">
								<label class="col col-12"><input type="checkbox" name="is_wiew_department" id="is_wiew_department" <cfif not isdefined('get_event_plan')><cfif is_choose_ajenda is "1">checked</cfif></cfif>  value="<cfoutput>#find_department_branch.department_id#</cfoutput>" <cfif isdefined('get_event_plan')><cfif len(get_event_plan.is_wiew_department)>checked</cfif></cfif> onClick="wiew_control(3);"> <cf_get_lang dictionary_id ='57915.Departmanımdaki Herkes Görsün'></label>
							</div>
							<div class="form-group" id="item-is_view_company">
								<label class="col col-12"><input type="checkbox" name="is_view_company" id="is_view_company" <cfif not isdefined('get_event_plan')><cfif is_choose_ajenda is "4">checked</cfif></cfif>  value="<cfoutput>#session.ep.company_id#</cfoutput>" <cfif isdefined('get_event_plan')><cfif len(get_event_plan.is_view_company)>checked</cfif></cfif> onClick="wiew_control(4);"><cfoutput>#getLang('','Sadece Şirket Çalışanları Görsün',33481)#</cfoutput></label>
							</div>
						</div>
					</cfif>
					<input type="hidden" name="is_wiew_branch_" id="is_wiew_branch_"  <cfif not isdefined('get_event_plan')><cfif is_choose_ajenda is "0">checked</cfif></cfif> value="<cfif isdefined('find_department_branch.branch_id')><cfoutput>#find_department_branch.branch_id#</cfoutput></cfif>">
					<cfif isDefined('xml_multiple_comp') And Len(xml_multiple_comp) And xml_multiple_comp>
						<div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="4" sort="true">
							<div class="form-group" id="item-agenda_companies">
								<label class="col col-4 col-xs-12"><span class="hide"><cf_get_lang dictionary_id='29531.Şirketler'></span></label>
								<div class="col col-8 col-xs-12"> 
									<span id="agenda_companies" style="vertical-align:top; padding-left:5px; display:none;">
										<select name="agenda_company" multiple="multiple" style="width:150px;">
											<cfoutput query="get_companies">
												<option value="#COMP_ID#" <cfif session.ep.company_id eq comp_id>selected</cfif>>#NICK_NAME#</option>
											</cfoutput>
										</select>
									</span>	
								</div>
							</div>
						</div>
					</cfif>
				</cf_box_elements>
				<cf_box_footer>
					<div class="col col-12"><cf_workcube_buttons is_upd='0' add_function='check_visit()'></div> 
				</cf_box_footer>
			</cf_basket_form>
			<cf_basket id="add_visit_bask">
				<cfinclude template="../display/list_visit_rows.cfm">
			</cf_basket>
		</cfform>
	</cf_box>
</div>
<script type="text/javascript">
function check_visit()
{
	if(document.getElementById('warning_head').value=='')
	{
		alert("<cfoutput>#getLang('','Olay Ziyaret Başlığını Giriniz',41218)#</cfoutput>!");
		return false;
	}
	if(document.all.process_stage.value== "")
	{
		alert("<cfoutput>#getLang('','Lütfen Süreçlerinizi Tanımlayınız ve veya Tanımlanan Süreçler Üzerinde Yetkiniz Yok',57976)#</cfoutput>!");
		return false;
	}
	<cfif x_form_visit eq 1>
		if(document.getElementById('analyse_id').value == '' || document.getElementById('analyse_head').value == '')
		{
			alert("<cfoutput>#getLang('','Analiz Formu Giriniz',41429)#</cfoutput>!");
			return false;	
		}
	</cfif>
	x = document.add_event.sales_zones.selectedIndex;
	if (document.add_event.sales_zones[x].value == "")
	{ 
		alert("<cfoutput>#getLang('','Şube Seçiniz',58579)#</cfoutput>!");
		return false;
	}
	if(document.getElementById('main_start_date').value=="")
	{
		alert("<cfoutput>#getLang('','Başlama Tarihini Doğru Giriniz',41032)#</cfoutput>!");
		return false;
	}
	if(document.getElementById('main_finish_date').value=='')
	{
		alert("<cfoutput>#getLang('','Bitiş Tarihini Doğru Giriniz',30123)#</cfoutput>!");
		return false;
	}
	if(datediff(document.getElementById('main_start_date').value,document.getElementById('main_finish_date').value ,0)<0)
	{
		alert("<cfoutput>#getLang('','Başlangıç Tarihi Bitiş Tarihinden Önce Olamaz',58862)#</cfoutput>!");
		return false;
	}
	if (document.getElementById('record_num').value == 0)
	{
		alert("<cfoutput>#getLang('','Lütfen Ziyaret Edilecek Seçiniz',41219)#</cfoutput>!");
		return false;
	}
	row_kontrol=0;
	for(r=1;r<=document.getElementById('record_num').value;r++)
	{	 
		deger_row_kontrol=document.getElementById('row_kontrol'+r).value;
		deger_start_date = document.getElementById('start_date'+r).value;
		deger_start_clock = document.getElementById('start_clock'+r).value;
		deger_start_minute = document.getElementById('start_minute'+r).value;
		deger_finish_clock = document.getElementById('finish_clock'+r).value;
		deger_finish_minute = document.getElementById('finish_minute'+r).value;
		deger_pos_emp_name = document.getElementById('pos_emp_name'+r).value;
		deger_warning_id = document.getElementById('warning_id'+r).value;
		if (deger_warning_id == "")
		{ 
			alert("<cfoutput>#getLang('','Lütfen Ziyaret Nedeni Giriniz',41042)#</cfoutput>!");
			return false;
		}	
		if(deger_pos_emp_name == "")
		{
			alert("<cfoutput>#getLang('','Lütfen Ziyaret Edecekler Satırına En Az Bir Kişi Ekleyiniz',41043)#</cfoutput>!");
			return false;
		}
		var deger = document.getElementById('finish_date'+r);
		if (isDefined("deger") || deger != null)
		{
			deger_finish_date = document.getElementById('finish_date'+r).value;
		}
		else
			deger_finish_date="undefined";//
			
		if(deger_row_kontrol == 1)
		{
			row_kontrol++;
			if(deger_start_date== "")
			{
				alert("<cfoutput>#getLang('','Lütfen Başlangıç Tarihi Giriniz',41039)#</cfoutput>!");
				return false;
			}
			if(deger_finish_date== "")
			{
				alert("<cfoutput>#getLang('','Lütfen Bitiş Tarihi Giriniz',41040)#</cfoutput>!");
				return false;
			}
			if(deger_finish_date!="undefined")
			{
				if (deger_start_date != "" && deger_finish_date!="")
				{
					tarih1_ = deger_start_date.substr(6,4) + deger_start_date.substr(3,2) + deger_start_date.substr(0,2);
					tarih2_ = deger_finish_date.substr(6,4) + deger_finish_date.substr(3,2) + deger_finish_date.substr(0,2);
				
					if (deger_start_clock.length < 2) saat1_ = '0' + deger_start_clock; else saat1_ = deger_start_clock;
					if (deger_start_minute.length < 2) dakika1_ = '0' + deger_start_minute; else dakika1_ = deger_start_minute;
					if (deger_finish_clock.length < 2) saat2_ = '0' + deger_finish_clock; else saat2_ = deger_finish_clock;
					if (deger_finish_minute.length < 2) dakika2_ = '0' + deger_finish_minute; else dakika2_ = deger_finish_minute;
				
					tarih1_ = tarih1_ + saat1_ + dakika1_;
					tarih2_ = tarih2_ + saat2_ + dakika2_;	
					
					if (tarih1_ >= tarih2_) 
					{
						alert("<cfoutput>#getLang('','Ziyaret Başlama Tarihi Bitiş Tarihinden Önce Olmalıdır',41041)#</cfoutput>!");
						return false;
					}
				}
			}
		}
	}
	/*var ver = navigator.appVersion;
	if(ver.indexOf("MSIE")==-1)
	{
		document.add_event.appendChild(document.getElementById("table1")); 
	}*/
	return true;
	
}
function sil(sy)
{
    var my_element=document.getElementById('row_kontrol'+sy);
	my_element.value=0;
	var my_element=eval("frm_row"+sy);
	my_element.style.display="none";
}
function kontrol_et()
{
	if(row_count ==0)
		return false;
	else
		return true;
}

function pencere_ac(no)
{
	openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_pars&is_buyer_seller=0&field_id=add_event.partner_id' + no +'&field_comp_name=add_event.company_name' + no +'&field_name=add_event.partner_name' + no +'&field_comp_id=add_event.company_id' + no + '&select_list=7,8');
}

function temizlerim(no)
{
	var my_element=eval("add_event.pos_emp_id"+no);
	var my_element2=eval("add_event.pos_emp_name"+no);
	my_element.value='';
	my_element2.value='';
}
function clear(no)
{
	var my_asset=eval("add_event.relation_asset_id"+no);
	var my_asset2=eval("add_event.relation_asset"+no);
	my_asset.value='';
	my_asset2.value='';
}
function pencere_ac_pos(no)
{
	windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_multi_pars&field_id=add_event.pos_emp_id' + no +'&field_name=add_event.pos_emp_name' + no +'&select_list=1&is_upd=1','list');
}
function pencere_ac_asset(no)
{
	windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=assetcare.popup_list_assetps&field_id=add_event.relation_asset_id'+ no +'&field_name=add_event.relation_asset' + no +'&event_id=0','list');
}
function pencere_ac_project(no)
{
	openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_projects&project_id=add_event.project_id'+ no +'&project_head=add_event.project_head' + no);
}
function pencere_ac_date(no)
{
	if((document.add_event.main_start_date.value == "") && (document.add_event.main_finish_date.value == ""))
		alert("<cfoutput>#getLang('','Lütfen İlk Önce Olay Başlangıç ve Bitiş Tarihlerini Seçiniz',35064)#</cfoutput>!");
	else
		windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_calender&alan=add_event.start_date' + no +'&is_check=' + no,'date');
}

function pencere_ac_date_finish(no)
{
	windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_calender&alan=add_event.finish_date' + no ,'date');
}

function pencere_ac_company(no)
{
	if((document.getElementById('main_start_date').value=='') || (document.getElementById('main_finish_date').value == ''))
	{
	
		alert("<cfoutput>#getLang('','Önce Ziyaret Tarihlerini Giriniz',41220)#</cfoutput>!");
		return false;	
	}
	else if(datediff(document.getElementById('main_start_date').value,document.getElementById('main_finish_date').value ,0)<0)
	{
		alert("<cfoutput>#getLang('','Başlangıç Tarihi Bitiş Tarihinden Önce Olamaz',58862)#</cfoutput>!");
		return false;
	}
	else	
		openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_list_multiuser_company&kontrol_startdate='+document.getElementById('main_start_date').value+'&record_num_=' + document.getElementById('record_num').value +'&is_first=1&startdate=' + document.getElementById('main_start_date').value +'&is_sales=1&is_close=0&prjct_id='+document.getElementById('prjct_id').value+'&project_head='+document.getElementById('project_head').value+'&is_choose_project=#is_choose_project#</cfoutput>');
}

function time_check(satir_deger)
{
	check_start_date = eval("document.add_event.start_date"+satir_deger);
	tarih_main_start_date = add_event.main_start_date.value.substr(6,4) + add_event.main_start_date.value.substr(3,2) + add_event.main_start_date.value.substr(0,2);
	tarih_main_finish_date = add_event.main_finish_date.value.substr(6,4) + add_event.main_finish_date.value.substr(3,2) + add_event.main_finish_date.value.substr(0,2);
	check_start = check_start_date.value.substr(6,4) + check_start_date.value.substr(3,2) + check_start_date.value.substr(0,2);
	if((check_start < tarih_main_start_date) || (check_start > tarih_main_finish_date))
	{
		alert("<cfoutput>#getLang('','Tarih Başlangıç ve Bitiş Tarihleri Arasında Olmalıdır',41044)#</cfoutput>!");
		check_start_date.value = "";
	}
}

function wiew_control(type)
{

	if(type == 1)
	{
		document.add_event.is_wiew_branch.checked = false;
		document.add_event.is_wiew_department.checked = false;
		document.add_event.is_view_company.checked = false;
		<cfif xml_multiple_comp eq 1>
			document.getElementById('agenda_companies').style.display = 'none';
		</cfif>	
	}	
	if(type == 2)
	{
		document.add_event.view_to_all.checked = false;
		document.add_event.is_wiew_department.checked = false;
		document.add_event.is_view_company.checked = false;
		<cfif xml_multiple_comp eq 1>
			document.getElementById('agenda_companies').style.display = 'none';
		</cfif>	
	}	
	if(type == 3)
	{
		document.add_event.view_to_all.checked = false;
		document.add_event.is_wiew_branch.checked = false;
		document.add_event.is_view_company.checked = false;
		<cfif xml_multiple_comp eq 1>
			document.getElementById('agenda_companies').style.display = 'none';
		</cfif>	
	}	
	if(type == 4)
	{
		document.add_event.view_to_all.checked = false;
		document.add_event.is_wiew_branch.checked = false;
		document.add_event.is_wiew_department.checked = false;
		<cfif xml_multiple_comp eq 1>
			if(document.getElementById('is_view_company').checked ==false)
				document.getElementById('agenda_companies').style.display = 'none';
			else
				document.getElementById('agenda_companies').style.display = '';
		</cfif>

	}	
}
</script>
