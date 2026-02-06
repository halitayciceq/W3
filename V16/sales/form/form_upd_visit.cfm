<cf_xml_page_edit fuseact="sales.form_add_visit">
<cfquery name="GET_VISIT_TYPES" datasource="#DSN#">
	SELECT VISIT_TYPE_ID,VISIT_TYPE FROM SETUP_VISIT_TYPES ORDER BY VISIT_TYPE
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
<cfquery name="FIND_DEPARTMENT_BRANCH" datasource="#DSN#">
	SELECT
		EMPLOYEE_POSITIONS.EMPLOYEE_ID,
		EMPLOYEE_POSITIONS.POSITION_ID,
		EMPLOYEE_POSITIONS.POSITION_CODE,
		BRANCH.BRANCH_ID,
		BRANCH.BRANCH_NAME,
		DEPARTMENT.DEPARTMENT_ID,
		DEPARTMENT.DEPARTMENT_HEAD,
        BRANCH.COMPANY_ID
	FROM
		EMPLOYEE_POSITIONS,
		DEPARTMENT,
		BRANCH
	WHERE
		EMPLOYEE_POSITIONS.DEPARTMENT_ID = DEPARTMENT.DEPARTMENT_ID
		AND DEPARTMENT.BRANCH_ID = BRANCH.BRANCH_ID
		AND EMPLOYEE_POSITIONS.POSITION_CODE = #session.ep.position_code#
</cfquery>
<cfquery name="GET_COMPANIES" datasource="#DSN#">
    SELECT COMP_ID,NICK_NAME FROM OUR_COMPANY WHERE COMP_STATUS = 1  ORDER BY COMPANY_NAME
</cfquery>
<cfquery name="GET_AGENDA_COMPANY" datasource="#DSN#">
    SELECT  DISTINCT
        SETUP_PERIOD.OUR_COMPANY_ID
    FROM
        EMPLOYEE_POSITION_PERIODS,
        EMPLOYEE_POSITIONS,
        SETUP_PERIOD
    WHERE
        EMPLOYEE_POSITIONS.POSITION_ID = EMPLOYEE_POSITION_PERIODS.POSITION_ID
        AND EMPLOYEE_POSITIONS.POSITION_CODE = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.position_code#">
        AND SETUP_PERIOD.PERIOD_ID = EMPLOYEE_POSITION_PERIODS.PERIOD_ID
</cfquery>
<cfset my_comp_list = VALUELIST(GET_AGENDA_COMPANY.OUR_COMPANY_ID)>
<cfquery name="GET_EVENT_PLAN" datasource="#DSN#">
	SELECT 
		* 
	FROM 
		EVENT_PLAN LEFT JOIN
        EVENT_PLAN_COMPANY ON
        EVENT_PLAN.EVENT_PLAN_ID =  EVENT_PLAN_COMPANY.EVENT_PLAN_ID
	WHERE 
		EVENT_PLAN.EVENT_PLAN_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.visit_id#">
		AND	
		(
			(
				(	
					EVENT_PLAN.IS_WIEW_BRANCH IS NOT NULL AND
					EVENT_PLAN.IS_WIEW_DEPARTMENT IS NOT NULL AND
					EVENT_PLAN.VIEW_TO_ALL IS NOT NULL AND
                    EVENT_PLAN.IS_VIEW_COMPANY IS NULL AND
					EVENT_PLAN.IS_WIEW_DEPARTMENT = #find_department_branch.department_id#
				)
				OR
				(
					EVENT_PLAN.IS_WIEW_BRANCH IS NOT NULL AND
					EVENT_PLAN.IS_WIEW_DEPARTMENT IS NULL AND
					EVENT_PLAN.VIEW_TO_ALL IS NOT NULL AND
                    EVENT_PLAN.IS_VIEW_COMPANY IS NULL AND
					EVENT_PLAN.IS_WIEW_BRANCH = #find_department_branch.branch_id#
				)
				OR
				(
					EVENT_PLAN.IS_WIEW_BRANCH IS NULL AND
					EVENT_PLAN.IS_WIEW_DEPARTMENT IS NULL AND
                    EVENT_PLAN.IS_VIEW_COMPANY IS NULL AND
					EVENT_PLAN.VIEW_TO_ALL IS NOT NULL
				)
                OR
				(
					EVENT_PLAN.IS_WIEW_BRANCH IS NULL AND
					EVENT_PLAN.IS_WIEW_DEPARTMENT IS NULL AND
					EVENT_PLAN.VIEW_TO_ALL IS NOT NULL
                    AND 
					<cfif xml_multiple_comp>
                    	(EVENT_PLAN.IS_VIEW_COMPANY IN (#my_comp_list#) 
                        AND EVENT_PLAN_COMPANY.COMPANY_ID IN (#my_comp_list#)) 
                    <cfelse>
                    	EVENT_PLAN.IS_VIEW_COMPANY IN (#my_comp_list#)
                    </cfif>
                    
				)
			)
			<cfif Get_Branch.RecordCount>
			OR
			(
				EVENT_PLAN.IS_WIEW_BRANCH IS NULL AND
				EVENT_PLAN.IS_WIEW_DEPARTMENT IS NULL AND
				EVENT_PLAN.VIEW_TO_ALL IS NULL AND
                EVENT_PLAN.IS_VIEW_COMPANY IS NULL AND
				EVENT_PLAN.SALES_ZONES  IN (#ListDeleteDuplicates(ValueList(Get_Branch.Branch_Id,','))#)
			)
			</cfif>
		)
</cfquery>
<cfquery name="get_event_plan_company" datasource="#dsn#">
	SELECT COMPANY_ID FROM EVENT_PLAN_COMPANY WHERE EVENT_PLAN_ID = #attributes.visit_id#
</cfquery>
<cfset comp_list = valuelist(get_event_plan_company.COMPANY_ID)>
<!--- lotis Özel rapor için eklendi. silmeyin [h.gul]--->
<cfparam name="attributes.convert_row_count" default="">
<cfparam name="attributes.convert_company_id" default="">
<cfparam name="attributes.convert_partner_id" default="">
<cfparam name="attributes.totalrecord" default="0">
<!--- Özel rapor için eklendi. silmeyin --->
<cfif get_event_plan.recordcount eq 0>
	<br />
	<cfset hata  = 11>
	<cfsavecontent variable="message"><cf_get_lang dictionary_id='57997.Şube Yetkiniz Uygun Değil'> <cf_get_lang dictionary_id='57998.Veya'> <cf_get_lang dictionary_id='58486.Kayıt Bulunamadı'> !</cfsavecontent>
	<cfset hata_mesaj  = message>
	<cfinclude template="../../dsp_hata.cfm">
<cfelse>
<cf_catalystHeader>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box>
		<cfform name="add_event" id="add_event" method="post" action="#request.self#?fuseaction=sales.emptypopup_upd_warning">
			<cf_basket_form id="form_upd_visit">
				<cfoutput>
					<cf_box_elements>
						<input type="hidden" name="visit_id" id="visit_id" value="#attributes.visit_id#">
						<div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
							<div class="form-group" id="item-event_detail">
								<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57493.Aktif'></label>
								<div class="col col-8 col-xs-12"> 
									<input type="checkbox" name="is_active" id="is_active" <cfif get_event_plan.is_active eq 1>checked</cfif>>
								</div>
							</div>
							<div class="form-group" id="item-warning_head">
								<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='41027.Plan Adı'>*</label>
								<div class="col col-8 col-xs-12"> 
									<cfinput type="text" name="warning_head" id="warning_head" style="width:175px;" required="Yes"  maxlength="100" value="#get_event_plan.event_plan_head#">
								</div>
							</div>
							<div class="form-group" id="item-process">
								<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id="58859.Süreç"></label>
								<div class="col col-8 col-xs-12"> 
									<cf_workcube_process is_upd='0' select_value='#get_event_plan.event_status#' process_cat_width='176' is_detail='1'>
								</div>
							</div>
							<div class="form-group" id="item-analyse_head">
								<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='40943.Analiz Formu'><cfif x_form_visit eq 1>*</cfif></label>
								<div class="col col-8 col-xs-12"> 
									<div class="input-group">
										<cfif len(get_event_plan.analyse_id)>
											<cfquery name="GET_ANALYSIS" datasource="#DSN#">
												SELECT ANALYSIS_HEAD FROM MEMBER_ANALYSIS WHERE ANALYSIS_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_event_plan.analyse_id#">
											</cfquery>
											<input type="hidden" name="analyse_id" id="analyse_id" value="#get_event_plan.analyse_id#">
											<input type="text" name="analyse_head" id="analyse_head" value="#get_analysis.analysis_head#" style="width:176px;">
										<cfelse>
											<input type="hidden" name="analyse_id" id="analyse_id">
											<input type="text" name="analyse_head" id="analyse_head" style="width:176px;">
										</cfif>
										<span class="input-group-addon icon-ellipsis btnPointer" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_analyse&field_id=add_event.analyse_id&field_name=add_event.analyse_head');"></span>
									</div>
								</div>
							</div>
						</div>
						<div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="2" sort="true">
							<div class="form-group" id="item-sales_zones">
								<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='51554.Yetkili Şubeler'>*</label>
								<div class="col col-8 col-xs-12"> 
									<select name="sales_zones" id="sales_zones" style="width:175px;">
										<option value=""><cf_get_lang dictionary_id='57453.Şube'></option>
										<cfloop query="get_branch">
											<option value="#branch_id#" <cfif get_event_plan.sales_zones eq branch_id>selected</cfif>>#branch_name#</option>
										</cfloop>
									</select>
								</div>
							</div>
							<div class="form-group" id="item-main_dates">
								<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57742.Tarih'>*</label>
								<div class="col col-4 col-xs-12"> 
									<div class="input-group">
										<cfinput type="text"  name="main_start_date" id="main_start_date" style="width:65px" validate="#validate_style#" value="#dateformat(get_event_plan.main_start_date,dateformat_style)#" required="yes">
										<span class="input-group-addon"><cf_wrk_date_image date_field="main_start_date"></span>
									</div>
								</div>
								<div class="col col-4 col-xs-12"> 
									<div class="input-group">
										<cfinput type="text"  name="main_finish_date" id="main_finish_date" style="width:65px" validate="#validate_style#" value="#dateformat(get_event_plan.main_finish_date,dateformat_style)#" required="yes">
										<span class="input-group-addon"><cf_wrk_date_image date_field="main_finish_date"></span>
									</div>
								</div>
							</div>
							<div class="form-group" id="item-event_detail">
								<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57629.Açıklama'></label>
								<div class="col col-8 col-xs-12"> 
									<textarea name="event_detail" id="event_detail" style="width:180px;height:65px;">#get_event_plan.detail#</textarea>
								</div>
							</div>
						</div>
						<input type="hidden" name="hidden_is_agenda_authority" id="hidden_is_agenda_authority" value="<cfif isdefined('is_agenda_authority')>#is_agenda_authority#</cfif>"><!--- xml için --->
						<cfif isdefined('is_agenda_authority') and (is_agenda_authority eq 1)>
							<cfif len(get_event_plan.record_emp)>
								<cfquery name="get_record_positions_code" datasource="#dsn#">
									SELECT POSITION_CODE FROM EMPLOYEE_POSITIONS WHERE EMPLOYEE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_event_plan.record_emp#">  AND IS_MASTER = 1
								</cfquery>
							</cfif>
							<cfif len(get_event_plan.record_emp) and isdefined('get_record_positions_code') and get_record_positions_code.recordcount>
								<cfquery name="FIND_DEPARTMENT_BRANCH" datasource="#DSN#">
									SELECT
										EMPLOYEE_POSITIONS.EMPLOYEE_ID,
										EMPLOYEE_POSITIONS.POSITION_ID,
										EMPLOYEE_POSITIONS.POSITION_CODE,
										BRANCH.BRANCH_ID,
										BRANCH.BRANCH_NAME,
										DEPARTMENT.DEPARTMENT_ID,
										DEPARTMENT.DEPARTMENT_HEAD,
										BRANCH.COMPANY_ID
									FROM
										EMPLOYEE_POSITIONS,
										DEPARTMENT,
										BRANCH
									WHERE
										EMPLOYEE_POSITIONS.DEPARTMENT_ID = DEPARTMENT.DEPARTMENT_ID AND
										DEPARTMENT.BRANCH_ID = BRANCH.BRANCH_ID AND 
										EMPLOYEE_POSITIONS.POSITION_CODE = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_record_positions_code.position_code#">
								</cfquery>
							</cfif>
							<div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="3" sort="true">
								<div class="form-group" id="item-view_to_all">
									<label class="col col-12"><input type="checkbox" name="view_to_all" id="view_to_all" value="1" <cfif get_event_plan.view_to_all eq 1 and not len(get_event_plan.is_wiew_branch) and not len(get_event_plan.is_wiew_department) and not len(get_event_plan.is_view_company)>checked</cfif> onClick="wiew_control(1);"> <cf_get_lang dictionary_id ='40970.Bu olayı herkes Görsün'></label>
								</div>
								<div class="form-group" id="item-is_wiew_branch">
									<label class="col col-12"><input type="checkbox" name="is_wiew_branch" id="is_wiew_branch" value="<cfif isDefined("find_department_branch") and find_department_branch.recordcount>#find_department_branch.branch_id#</cfif>" <cfif len(get_event_plan.is_wiew_branch) and not len(get_event_plan.is_wiew_department)>checked</cfif> onClick="wiew_control(2);"> <cf_get_lang dictionary_id ='57914.Şubemdeki Herkes Görsün'></label>
								</div>
								<div class="form-group" id="item-is_wiew_department">
									<label class="col col-12"><input type="checkbox" name="is_wiew_department" id="is_wiew_department" value="<cfif isDefined("find_department_branch") and find_department_branch.recordcount>#find_department_branch.department_id#</cfif>" <cfif len(get_event_plan.is_wiew_department)>checked</cfif> onClick="wiew_control(3);"> <cf_get_lang dictionary_id ='57915.Departmanımdaki Herkes Görsün'></label>
								</div>
								<div class="form-group" id="item-is_view_company">
									<label class="col col-12"><input type="checkbox" name="is_view_company" id="is_view_company" value="<cfif isDefined("find_department_branch") and find_department_branch.recordcount>#find_department_branch.company_id#</cfif>" <cfif len(get_event_plan.is_view_company)>checked</cfif> onClick="wiew_control(4);"> <cf_get_lang dictionary_id='33481.Sadece Şirket Çalışanları Görsün'></label>
								</div>
							</div>
							<input type="hidden" name="is_wiew_branch_" id="is_wiew_branch_" value="<cfif isDefined("find_department_branch") and find_department_branch.recordcount>#find_department_branch.branch_id#</cfif>">
						</cfif>
						<cfif xml_multiple_comp>
							<div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="4" sort="true">
								<div class="form-group" id="item-agenda_companies">
									<label class="col col-4 col-xs-12"><span class="hide">Şirketler</span></label>
									<div class="col col-8 col-xs-12"> 
										<span id="agenda_companies" style="vertical-align:top; padding-left:5px; <cfif not len(get_event_plan.is_view_company)> display:none;</cfif>">
											<select name="agenda_company" id="agenda_company" multiple="multiple" style="width:150px;">
												<cfloop query="get_companies">
													<option value="#comp_id#" <cfif listfind(comp_list,get_companies.comp_id)>selected</cfif>>#NICK_NAME#</option>
												</cfloop>
											</select>
										</span>	
									</div>
								</div>
							</div>
						</cfif>
					</cf_box_elements>
					<cf_box_footer>
						<div class="col col-6"><cf_record_info query_name="get_event_plan"></div>
						<div class="col col-6"><cf_workcube_buttons is_upd='1' add_function='check()' is_reset='0' delete_page_url='#request.self#?fuseaction=sales.emptypopup_del_visit&id=#get_event_plan.event_plan_id#'></div> 
					</cf_box_footer>
				</cfoutput>
			</cf_basket_form>
			<cf_basket id="form_upd_visit_bask">
					<cfinclude template="../display/list_visit_rows_detail.cfm">
			</cf_basket>
		</cfform>
	</cf_box>
</div>
<script type="text/javascript">
function check()
{
	if(document.getElementById('warning_head').value=='')
	{
		alert("<cfoutput>#getLang('','Olay Ziyaret Başlığını Giriniz',41218)#</cfoutput>!");
		return false;	
	}
	if(document.all.process_stage.value == "")
	{
		alert("<cfoutput>#getLang('','Lütfen Süreçlerinizi Tanımlayınız ve veya Tanımlanan Süreçler Üzerinde Yetkiniz Yok',57976)#</cfoutput>!");
		return false;
	}
	x = document.add_event.sales_zones.selectedIndex;
	if(document.add_event.sales_zones[x].value == "")
	{ 
		alert("<cfoutput>#getLang('','Şube Seçiniz',58579)#</cfoutput>!");
		return false;
	}
	if(document.getElementById('main_start_date').value=='')
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
	if (document.getElementById('record_num').value == 0)//|| kontrol_row_count == 0
	{
		alert("<cfoutput>#getLang('','Lütfen Ziyaret Edilecek Seçiniz',41219)#</cfoutput>!");
		return false;
	}
	<cfif x_form_visit eq 1>
		if(document.getElementById('analyse_id').value == '' || document.getElementById('analyse_head').value == '')
		{
			alert("<cfoutput>#getLang('','Analiz Formu Giriniz',41429)#</cfoutput>!");
			return false;	
		}
	</cfif>
	row_kontrol=0;
	for(r=1;r<=document.getElementById('record_num').value;r++)
	{
		deger_row_kontrol=document.getElementById('row_kontrol'+r).value;
		deger_start_date = document.getElementById('start_date'+r).value;
		deger_start_clock = document.getElementById('start_clock'+r).value;
		deger_start_minute = document.getElementById('start_minute'+r).value;
		var deger = document.getElementById('finish_date'+r);
		if (isDefined("deger") || deger != null)
		{
			deger_finish_date = document.getElementById('finish_date'+r).value;
		}
		else
			deger_finish_date="undefined";//
		deger_finish_clock = document.getElementById('finish_clock'+r).value;
		deger_finish_minute = document.getElementById('finish_minute'+r).value;
		deger_pos_emp_name = document.getElementById('pos_emp_name'+r).value;
		deger_warning_id = document.getElementById('warning_id'+r).value;
	
		if(deger_row_kontrol == 1)
		{
			row_kontrol++;
			if(deger_start_date == "")
			{
				alert("<cfoutput>#getLang('','Lütfen Başlangıç Tarihi Giriniz',41039)#</cfoutput>!");
				return false;
			}
			if(deger_finish_date == "")
			{
				alert("<cfoutput>#getLang('','Lütfen Bitiş Tarihi Giriniz',41040)#</cfoutput>!");
				return false;
			}
			if(deger_finish_date!="undefined")
			{
				if ((deger_start_date != "") && (deger_finish_date != ""))
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
		}
	}
	/*var ver = navigator.appVersion;
	if(ver.indexOf("MSIE")==-1)
	{
		document.add_event.appendChild(document.getElementById("table1")); 
	} */
	return true;
}

function temizlerim(no)
{
	var my_element=eval("add_event.pos_emp_id"+no);
	var my_element2=eval("add_event.pos_emp_name"+no);
	my_element.value='';
	my_element2.value='';
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

function sil(sy)
{
	var my_element=eval("add_event.row_kontrol"+sy);
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
<cfoutput>
function pencere_ac(no)
{
	openBoxDraggable('#request.self#?fuseaction=objects.popup_list_pars&is_buyer_seller=0&field_id=add_event.partner_id' + no +'&field_comp_name=add_event.company_name' + no +'&field_name=add_event.partner_name' + no +'&field_comp_id=add_event.company_id'+ no +'&field_consumer=add_event.consumer_id' + no + '&select_list=7,8');
}
function pencere_ac_pos(no)
{
	windowopen('#request.self#?fuseaction=objects.popup_list_multi_pars&field_id=add_event.pos_emp_id' + no +'&field_name=add_event.pos_emp_name' + no +'&select_list=1&is_upd=1','list');

}
function pencere_ac_inf(no)
{
	windowopen('#request.self#?fuseaction=objects.popup_list_multi_pars&field_id=add_event.inf_emp_id' + no +'&field_name=add_event.inf_emp_name' + no +'&select_list=1&is_upd=1','list');
}
function pencere_ac_asset(no)
{
	windowopen('#request.self#?fuseaction=assetcare.popup_list_assetps&field_id=add_event.relation_asset_id'+ no +'&field_name=add_event.relation_asset' + no +'&event_id=0','list');
}
function pencere_ac_project(no)
{

	openBoxDraggable('#request.self#?fuseaction=objects.popup_list_projects&project_id=add_event.project_id'+ no +'&project_head=add_event.project_head' + no);
}
function pencere_ac_date(no)
{
	if((document.add_event.main_start_date.value == "") && (document.add_event.main_finish_date.value == ""))
	{
		alert("<cfoutput>#getLang('','Lütfen İlk Önce Olay Başlangıç ve Bitiş Tarihlerini Seçiniz',35064)#</cfoutput>!");
	}
	else
	{
		windowopen('#request.self#?fuseaction=objects.popup_calender&alan=add_event.start_date' + no +'&is_check=' + no,'date');
	}
}
function pencere_ac_date_finish(no)
{
	windowopen('#request.self#?fuseaction=objects.popup_calender&alan=add_event.finish_date' + no ,'date');
}
function pencere_ac_company(no)
{
	if((add_event.main_start_date.value == '') || (add_event.main_finish_date.value == ''))
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
		openBoxDraggable('#request.self#?fuseaction=objects.popup_list_multiuser_company&kontrol_startdate='+add_event.main_start_date.value+'&record_num_=' + add_event.record_num.value +'&is_choose_project=#is_choose_project#&is_first=1&startdate=' + add_event.main_start_date.value +'&is_sales=1&is_close=0');
}
</cfoutput>
function manage_date(gelen_alan)
{
	wrk_date_image(gelen_alan);
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
</cfif>
