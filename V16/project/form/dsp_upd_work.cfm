<!---
Author :        Melek Kocabey<melekkocabey@workcube.com>
Date :          02.09.2019
Description :   İş güncelleme sayfası.
--->
<script type="text/javascript">
	$(document).ready(function(e) {
      	$('.area_show .area_head').click(function (e) {
			e.preventDefault();
			$(this).closest('li').find('.area_detail').not(':animated').slideToggle();
		});
		$('.area_show .area_head').click(function (e) {
			e.preventDefault();
			$(this).closest('li').find('area_detail').not(':animated').slideToggle();
		});
    });
</script>
<cfset getComponent = createObject('component','V16.project.cfc.get_work')>
<cfset work_detail_first = getComponent.GET_WORK_FIRST_DETAIL(id : attributes.id)>
<cfset getComponent = createObject('component','V16.project.cfc.get_project_work')>
<cf_xml_page_edit>
<cfparam name="liste" default="">
<cfparam name="saat" default="">
<cfparam name="dak" default="">
<cfinclude template="../query/get_work.cfm">
<cfset control_project_id = upd_work.project_id>

<cfif upd_work.recordcount eq 0>
	<cfset hata  = 11>
	<cfsavecontent variable="message"><cf_get_lang dictionary_id='58943.Böyle Bir Kayit Bulunmamaktadır'>!</cfsavecontent>
	<cfset hata_mesaj  = message>
	<cfinclude template="../../dsp_hata.cfm">
<cfelse>
    <cfif (isdefined("xml_add_fis") and xml_add_fis eq 1 and len(upd_work.project_id))>
        <cfoutput>
            <cfquery name="GET_MATERIAL_LIST" datasource="#DSN#">
                SELECT PRO_MATERIAL_ID FROM PRO_MATERIAL WHERE WORK_ID = #attributes.id# AND PROJECT_ID = #upd_work.project_id#
            </cfquery>
            <cfif GET_MATERIAL_LIST.recordcount>
                <cfquery name="get_pro_material" datasource="#dsn#">
                    SELECT 
                        PR.* 
                    FROM 
                        PRO_MATERIAL P,
                        PRO_MATERIAL_ROW PR
                    WHERE 
                        P.PRO_MATERIAL_ID = PR.PRO_MATERIAL_ID AND
                        PR.PRO_MATERIAL_ID = #GET_MATERIAL_LIST.PRO_MATERIAL_ID#
                </cfquery>
                <cfset s_amount_list = "">
                <cfif get_pro_material.recordcount>                    
                    <cfloop query="get_pro_material">
                        <cfquery name="get_sarf" datasource="#dsn2#">
                            SELECT SUM(SR.AMOUNT) AMOUNT FROM STOCK_FIS S JOIN STOCK_FIS_ROW SR ON S.FIS_ID = SR.FIS_ID WHERE S.WORK_ID = #attributes.id# AND SR.STOCK_ID = #STOCK_ID#
                        </cfquery>
                        <cfif get_sarf.recordcount and len(get_sarf.amount)>
                            <cfset s_amount = amount-get_sarf.amount>
                        <cfelse>
                            <cfset s_amount = amount>
                        </cfif>
                        <cfset s_amount_list = listappend(s_amount_list,s_amount,',')>
                    </cfloop>
                </cfif>               
                <input type="hidden" name="convert_stocks_id" id="convert_stocks_id" value="#valuelist(get_pro_material.stock_id)#">
                <input type="hidden" name="convert_spect_id" id="convert_spect_id" value="#valuelist(get_pro_material.SPECT_VAR_ID)#">
                <input type="hidden" name="convert_amount_stocks_id" id="convert_amount_stocks_id" value="#s_amount_list#">
                <input type="hidden" name="convert_price" id="convert_price" value="#valuelist(get_pro_material.price)#">
                <input type="hidden" name="convert_price_other" id="convert_price_other" value="#valuelist(get_pro_material.price_other)#">
                <input type="hidden" name="convert_money" id="convert_money" value="#valuelist(get_pro_material.OTHER_MONEY)#">
                <input type="hidden" name="convert_cost_price" id="convert_cost_price" value="#valuelist(get_pro_material.COST_PRICE)#" />
                <input type="hidden" name="convert_extra_cost" id="convert_extra_cost" value="#valuelist(get_pro_material.EXTRA_COST)#" />
                <input type="hidden" name="record_num" id="record_num" value="#get_pro_material.recordcount#">
                <input type="hidden" name="form_submitted" id="form_submitted" value="">
            </cfif>
        </cfoutput>
    </cfif>
	<cfinclude template="../query/get_workgroups.cfm">
	<cfinclude template="../query/get_pro_work_cat.cfm">
	<cfinclude template="../query/get_priority.cfm">
	<cfquery name="GET_ACTIVITY" datasource="#DSN#">
		SELECT ACTIVITY_ID, #dsn#.Get_Dynamic_Language(SETUP_ACTIVITY.ACTIVITY_ID,'#session.ep.language#','SETUP_ACTIVITY','ACTIVITY_NAME',NULL,NULL,SETUP_ACTIVITY.ACTIVITY_NAME) AS ACTIVITY_NAME FROM SETUP_ACTIVITY WHERE ACTIVITY_STATUS = 1 ORDER BY ACTIVITY_NAME
	</cfquery>
	<!--- güncelle ve görevli kontrolü için--->
	<cfif len(upd_work.outsrc_cmp_id) and len(upd_work.outsrc_partner_id)>
		<cfquery name="PARTNER_NAME" datasource="#dsn#">
			SELECT COMPANY_PARTNER_NAME+' '+COMPANY_PARTNER_SURNAME AS PRT_NAME FROM COMPANY_PARTNER WHERE PARTNER_ID=#upd_work.outsrc_partner_id#  
		</cfquery>
	<cfelseif len(upd_work.project_emp_id)>
		<cfquery name="EMPLOYEE_NAME" datasource="#dsn#">
			SELECT EMPLOYEE_NAME+' '+EMPLOYEE_SURNAME AS EMP_NAME FROM EMPLOYEES  WHERE EMPLOYEE_ID=#upd_work.project_emp_id#
		</cfquery> 
	</cfif>
	<cfif len(upd_work.update_author)>
		<cfquery name="GET_EMPLOYEE_NAME" datasource="#dsn#">
			SELECT EMPLOYEE_NAME+' '+EMPLOYEE_SURNAME AS UPDATE_NAME FROM EMPLOYEES WHERE EMPLOYEE_ID=#upd_work.update_author#
		</cfquery>
		<cfif get_employee_name.recordcount eq 0>
			<cfquery name="GET_PARTNER_NAME" datasource="#dsn#">
				SELECT COMPANY_PARTNER_NAME+' '+COMPANY_PARTNER_SURNAME AS UPDATE_NAME FROM COMPANY_PARTNER WHERE PARTNER_ID=#upd_work.update_author# 
			</cfquery> 
		</cfif>
	<cfelseif len(upd_work.record_author)>
		<cfquery name="GET_EMPLOYEE_NAME" datasource="#dsn#">
			SELECT EMPLOYEE_NAME+' '+EMPLOYEE_SURNAME AS UPDATE_NAME FROM EMPLOYEES WHERE EMPLOYEE_ID=#upd_work.record_author#
		</cfquery>
		<cfif get_employee_name.recordcount eq 0>
			<cfquery name="GET_PARTNER_NAME" datasource="#dsn#">
				SELECT COMPANY_PARTNER_NAME+' '+COMPANY_PARTNER_SURNAME AS UPDATE_NAME FROM COMPANY_PARTNER WHERE PARTNER_ID=#upd_work.record_author# 
			</cfquery> 
		</cfif>   
	</cfif>
	<cfquery name="GET_SPECIAL_DEFINITION" datasource="#dsn#">
		SELECT 
            SPECIAL_DEFINITION_ID,
            #dsn#.Get_Dynamic_Language(SPECIAL_DEFINITION_ID,'#session.ep.language#','SETUP_SPECIAL_DEFINITION','SPECIAL_DEFINITION',NULL,NULL,SPECIAL_DEFINITION) AS SPECIAL_DEFINITION
        FROM SETUP_SPECIAL_DEFINITION WHERE SPECIAL_DEFINITION_TYPE = 7
	</cfquery>
	<!--- query kontrolü son--->
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
		if(len(upd_work.real_start))
		{
			sdate=date_add('h', session.ep.time_zone, upd_work.real_start);
			shour=datepart('h',sdate);
		}
		if(len(upd_work.real_finish))
		{
			fdate=date_add('h', session.ep.time_zone, upd_work.real_finish);
			fhour=datepart('h',fdate);
		}
		if(len(upd_work.predicted_start))
		{
			psdate=date_add('h', session.ep.time_zone, upd_work.predicted_start);
			pshour=datepart('h',psdate);
		}
		if(len(upd_work.predicted_finish))
		{
			pfdate=date_add('h', session.ep.time_zone, upd_work.predicted_finish);
			pfhour=datepart('h',pfdate);
		}
		if(len(upd_work.TARGET_START))
        {
            sdate_plan=date_add('h', session.ep.time_zone, upd_work.TARGET_START);
        }
        else 
        {
            sdate_plan=date_add('h', session.ep.time_zone, now());
        }
        if(len(upd_work.TARGET_FINISH))
        {
            fdate_plan=date_add('h', session.ep.time_zone, upd_work.TARGET_FINISH);
        }
        else
        {
            fdate_plan=date_add('h', session.ep.time_zone, upd_work.terminate_date);
        }
		shour_plan=datepart('h',sdate_plan);
		fhour_plan=datepart('h',fdate_plan);
	</cfscript>
	<cfinclude template="../query/get_work_history.cfm">
	<cfset work_head_ = URLEncodedFormat(upd_work.work_head)> <!--- tirnakli ifadeleri yok etmek için --->
	
	<cfif len(upd_work.project_id)>
		<cfquery name="GET_PRO_NAME" datasource="#DSN#">
			SELECT PROJECT_HEAD,TARGET_START,TARGET_FINISH FROM PRO_PROJECTS WHERE PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#upd_work.project_id#">
		</cfquery>
    </cfif>
    <cfif not (isdefined("url.is_plani") and len(url.is_plani))>
    <cf_catalystHeader>
    </cfif>
    <div class="col col-12 col-md-12 col-sm-12 col-xs-12">
        <cf_box>
            <cfform name="upd_work" id="upd_work" method="post" action="#request.self#?fuseaction=project.emptypopup_upd_work">
                <cfoutput>
                    <cfif IsDefined("xml_waste_of_time")><input type="hidden" name="xml_waste_of_time" id="xml_waste_of_time" value="#xml_waste_of_time#"></cfif>
                    <input type="hidden" name="today" id="today" value="#DateFormat(now(),dateformat_style)#">
                    <input type="hidden" name="update_name" id="update_name" value="<cfif isdefined("GET_EMPLOYEE_NAME") and GET_EMPLOYEE_NAME.recordcount>#GET_EMPLOYEE_NAME.UPDATE_NAME#<cfelseif isdefined("GET_PARTNER_NAME")>#GET_PARTNER_NAME.UPDATE_NAME#</cfif>">
                    <input type="hidden" name="responsible" id="responsible" value="<cfif isdefined("PARTNER_NAME") and len(upd_work.outsrc_cmp_id) and len(upd_work.outsrc_partner_id)>#PARTNER_NAME.prt_name#<cfelseif isdefined("EMPLOYEE_NAME")>#EMPLOYEE_NAME.emp_name#</cfif>">
                    <input type="hidden" name="work_id" id="work_id" value="#attributes.id#">
                    <input type="hidden" name="id" id="id" value="#attributes.id#">
                    <input type="hidden" name="pro_id" id="pro_id" value="#upd_work.project_id#">
                    <input type="hidden" name="g_service_id" id="g_service_id" value="#upd_work.g_service_id#">
                    <input type="hidden" name="service_id" id="service_id" value="#upd_work.service_id#">
                    <input type="hidden" name="forum_reply_id" id="forum_reply_id" value="#upd_work.forum_reply_id#">
                    <input type="hidden" name="first_work_detail" id="first_work_detail" value="#work_detail_first.history_id#">
                    <input type="hidden" name="purchase_contract_id" id="purchase_contract_id" value="<cfif len(upd_work.purchase_contract_id)>#upd_work.purchase_contract_id#</cfif>">
                    <input type="hidden" name="sale_contract_id" id="sale_contract_id" value="<cfif len(upd_work.sale_contract_id)>#upd_work.sale_contract_id#</cfif>">
                    <input type="hidden" name="our_company_id" id="our_company_id" value="<cfif len(upd_work.our_company_id)>#upd_work.our_company_id#<cfelse>#session.ep.company_id#</cfif>">
                    <cfif isdefined("get_hist_detail.work_currency_id") and len(get_hist_detail.work_currency_id)>
                        <input type="hidden" name="old_currency" id="old_currency" value="#get_hist_detail.work_currency_id#">
                    <cfelse>
                        <input type="hidden" name="old_currency" id="old_currency" value="#upd_work.work_currency_id#">
                    </cfif>
                    <cfif IsDefined("xml_time_duration_stage_update")><input type="hidden" name="xml_time_duration_stage_update" id="xml_time_duration_stage_update" value="#xml_time_duration_stage_update#"></cfif>
                    <cfif IsDefined("xml_link")><input type="hidden" name="is_xml_link" id="is_xml_link" value="#xml_link#"></cfif>
                </cfoutput>         
                
                <cf_box_elements id="genel_bilgiler" vertical="1">
                    <div class="col col-4 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
                        <div class="form-group" id="item-form_ul_pro_work_cat">
                            <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='38177.İş Kategorisi'>*</label>
                            <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                                <select name="pro_work_cat" id="pro_work_cat"  <cfif isdefined("xml_is_stage_cat") and xml_is_stage_cat eq 1>onchange="tmplt();"</cfif>>
                                    <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                    <cfoutput query="get_work_cat">
                                        <option value="#work_cat_id#"<cfif len(upd_work.work_cat_id) and (upd_work.work_cat_id eq work_cat_id)>selected</cfif>>#work_cat#</option>
                                    </cfoutput>
                                </select>
                            </div>
                        </div>
                        <div class="form-group" id="item-form_ul_responsable_name">
                            <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='57569.Görevli'>*</label>
                            <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                                <div class="input-group">
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
                                    <cfif isdefined("url.tree_category_id")>
                                        <cfinput type="text" name="responsable_name" id="responsable_name" value="#person#" >
                                    <cfelse>
                                        <cfif xml_only_employee eq 1>																					
                                            <cfinput type="text" name="responsable_name" id="responsable_name" value="#person#"  onFocus="AutoComplete_Create('responsable_name','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','\'3\',0,0','EMPLOYEE_ID','project_emp_id','','3','200','get_company()');">
                                        <cfelse>
                                            <cfinput type="text" name="responsable_name" id="responsable_name" value="#person#"  onFocus="AutoComplete_Create('responsable_name','MEMBER_NAME,MEMBER_PARTNER_NAME2','MEMBER_PARTNER_NAME2,MEMBER_NAME2','get_member_autocomplete','\'1,3\',0,0','COMPANY_ID,PARTNER_ID,EMPLOYEE_ID','task_company_id,task_partner_id,project_emp_id','','3','200','get_company()');">
                                        </cfif>
                                    </cfif>
                                    <span class="input-group-addon icon-ellipsis btnPointer" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_list_positions&field_partner=upd_work.task_partner_id&field_comp_id=upd_work.task_company_id&field_emp_id=upd_work.project_emp_id&field_name=upd_work.responsable_name<cfif isdefined("url.tree_category_id")>&tree_category_id=#url.tree_category_id#&select_list=1<cfelse>&select_list=1,2</cfif><cfif isdefined("url.process_date")>&process_date=#url.process_date#</cfif></cfoutput>');"></span>
                                </div>
                            </div>
                        </div>
                        <div class="form-group" id="item-form_ul_about_company">
                            <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='57574.Şirket'> - <cf_get_lang dictionary_id='57578.Yetkili'></label>
                            <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                                <div class="input-group">
                                    <input type="hidden" name="company_partner_id" id="company_partner_id" value="<cfif len(upd_work.company_partner_id)><cfoutput>#upd_work.company_partner_id#</cfoutput><cfelseif len(upd_work.consumer_id)><cfoutput>#upd_work.consumer_id#</cfoutput></cfif>">
                                    <input type="hidden" name="company_id" id="company_id" value="<cfif len(upd_work.company_id)><cfoutput>#upd_work.company_id#</cfoutput></cfif>">
                                    <cfif len(upd_work.company_id) and len(upd_work.company_partner_id)>
                                        <cfset attributes.partner_id = upd_work.company_partner_id>
                                        <cfinclude template="../query/get_partner_name.cfm">
                                        <input type="text" name="about_company" id="about_company" value="<cfoutput>#get_par_info(upd_work.company_partner_id,0,0,0)#<!---#get_partner_name.nickname#---></cfoutput>" onkeyup="get_company();"   onfocus="AutoComplete_Create('about_company','MEMBER_PARTNER_NAME3','MEMBER_PARTNER_NAME3','get_member_autocomplete','\'1,2\',0,0','COMPANY_ID,PARTNER_ID','company_id,company_partner_id','','3','150');">
                                    <cfelseif not len(upd_work.company_id) and len(upd_work.consumer_id)>
                                        <cfset attributes.consumer_id = upd_work.consumer_id>
                                        <cfinclude template="../query/get_consumer_name.cfm">
                                        <input type="text" name="about_company"  id="about_company" value="<cfoutput>#get_consumer_name.company#</cfoutput>"  onfocus="AutoComplete_Create('about_company','MEMBER_PARTNER_NAME3','MEMBER_PARTNER_NAME3','get_member_autocomplete','\'1,2\',0,0','COMPANY_ID,PARTNER_ID','company_id,company_partner_id','','3','150');">
                                    <cfelse>
                                        <input type="text" name="about_company" id="about_company" value=""  onfocus="AutoComplete_Create('about_company','MEMBER_PARTNER_NAME3','MEMBER_PARTNER_NAME3','get_member_autocomplete','\'1,2\',0,0','COMPANY_ID,PARTNER_ID','company_id,company_partner_id','','3','150');">
                                    </cfif>
                                    <span class="input-group-addon icon-ellipsis btnPointer" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_list_pars&field_comp_id=upd_work.company_id&field_name=upd_work.about_company&field_id=upd_work.company_partner_id&par_con=1&select_list=2</cfoutput>')"></span>
                                </div>
                            </div>
                        </div>
                        <div class="form-group" id="form_ul_work_no">
                            <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='38472.İş No'></label>
                            <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                                <input type="text" name="work_no" id="work_no" maxlength="20" value="<cfoutput>#upd_work.work_no#</cfoutput>"  />
                            </div>
                        </div>
                    </div>
                    <div class="col col-4 col-md-4 col-sm-6 col-xs-12" id="stage2" type="column" index="2" sort="true">
                        <div class="form-group" id="item-form_ul_process_stage">
                            <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id="58859.Süreç"> *</label>
                            <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                                <cfif isdefined("xml_is_stage_cat") and xml_is_stage_cat eq 1>
                                    <div id="stage1"></div>
                                <cfelse>
                                    <cf_workcube_process is_upd='0' is_detail="1" select_value="#upd_work.work_currency_id#" process_cat_width='130'>
                                </cfif>
                            </div>
                        </div>
                        <div class="form-group" id="item-form_ul_priority_cat">
                            <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='57485.Öncelik'>*</label>
                            <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                                <select name="priority_cat" id="priority_cat" >
                                    <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                    <cfoutput query="get_cats">
                                    <option value="#priority_id#" <cfif upd_work.work_priority_id is priority_id>selected</cfif>>#priority#</option>
                                    </cfoutput>
                                </select>
                            </div>
                        </div>
                        <div class="form-group" id="item-form_ul_activity_type">
                            <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='38378.Aktivite Tipi'></label>
                            <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                                <select name="activity_type" id="activity_type">
                                    <option value=""><cf_get_lang dictionary_id ='57734.Seçiniz'></option>
                                        <cfoutput query="get_activity">
                                            <option value="#ACTIVITY_ID#"  <cfif upd_work.activity_id is activity_id>selected</cfif>>#ACTIVITY_NAME#</option>
                                        </cfoutput>
                                </select>
                            </div>
                        </div>
                        <cfif  (upd_work.WORK_FUSEACTION DOES NOT CONTAIN 'emptypopup')> 
                            <div class="form-group" id="item-work_fuse">
                                <label class="col col-4 col-md-4 col-sm-4 col-xs-12">Workfuse</label>
                                <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                                    <div class="input-group">
                                        <input name="work_fuse" type="text" id="work_fuse" value="<cfoutput>#upd_work.WORK_CIRCUIT#.#upd_work.WORK_FUSEACTION#</cfoutput>">
                                        <span class="input-group-addon btnPointer icon-link" onclick="window.open('<cfoutput>#request.self#?fuseaction=#upd_work.WORK_CIRCUIT#.#upd_work.WORK_FUSEACTION#</cfoutput>','_blank');"></span>
                                    </div>
                                </div>
                            </div>
                        <cfelse>
                            <cfoutput><input type="hidden" name="work_fuse" id="work_fuse" value="#upd_work.work_circuit#.#upd_work.work_fuseaction#" /></cfoutput>
                        </cfif>
                        <cfif session.ep.our_company_info.workcube_sector is 'tersane'>
                            <div class="form-group" id="item-form_ul_pbs_code" >
                                <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='38131.PBS Kodu'></label>
                                <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                                    <div class="input-group">
                                        <cfif len(upd_work.pbs_id)>
                                            <cfquery name="get_pbs_" datasource="#dsn3#">
                                                SELECT PBS_ID,PBS_CODE FROM SETUP_PBS_CODE WHERE PBS_ID = #upd_work.pbs_id#
                                            </cfquery>
                                            <cfset pbs_id_ = get_pbs_.pbs_id>
                                            <cfset pbs_code_ = get_pbs_.pbs_code>
                                        <cfelse>
                                            <cfset pbs_id_ = ''>
                                            <cfset pbs_code_ = ''>
                                        </cfif>
                                            <input type="hidden" name="pbs_id" id="pbs_id" value="<cfoutput>#pbs_id_#</cfoutput>">
                                            <input name="pbs_code" id="pbs_code" type="text"  value="<cfoutput>#pbs_code_#</cfoutput>" autocomplete="off">
                                            <span class="input-group-addon icon-ellipsis btnPointer" onclick="pencere_ac_pbs_code();"></span>
                                    </div>
                                </div>
                            </div>
                        </cfif>
                    </div>
                    <div class="col col-4 col-md-4 col-sm-6 col-xs-12" type="column" index="3" sort="true">
                        <div class="form-group" id="item-form_ul_project_head">
                            <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='57416.Proje'><cfif isdefined("xml_project_required") and xml_project_required eq 1>*</cfif></label>
                            <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                                <div class="input-group">
                                    <input type="hidden" name="project_id" id="project_id" value="<cfoutput>#upd_work.project_id#</cfoutput>">
                                    <input type="hidden" name="p_sdate" id="p_sdate" value="<cfif len(upd_work.project_id)><cfoutput>#dateformat(get_pro_name.target_start,dateformat_style)#</cfoutput></cfif>">
                                    <input type="hidden" name="p_fdate" id="p_fdate" value="<cfif len(upd_work.project_id)><cfoutput>#dateformat(get_pro_name.target_finish,dateformat_style)#</cfoutput></cfif>">
                                    <input name="project_head" type="text" id="project_head"  onfocus="AutoComplete_Create('project_head','PROJECT_HEAD','PROJECT_HEAD,FULLNAME','get_project','','PROJECT_ID,TARGET_START,TARGET_FINISH<cfif isDefined('xml_company_detail_by_project') and xml_company_detail_by_project eq 1>,COMPANY_ID,MEMBER_PARTNER_NAME2,PARTNER_ID</cfif>','project_id,p_sdate,p_fdate<cfif isDefined('xml_company_detail_by_project') and  xml_company_detail_by_project eq 1>,company_id,about_company,company_partner_id</cfif>','','3','150',true,'add_milestone()');" value="<cfif len(upd_work.project_id)><cfoutput>#get_project_name(upd_work.project_id)#</cfoutput><cfelse>Projesiz</cfif>" autocomplete="off">
                                    <span class="input-group-addon icon-ellipsis btnPointer" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_list_projects&project_head=upd_work.project_head&project_id=upd_work.project_id&p_sdate=upd_work.p_sdate&p_fdate=upd_work.p_fdate<cfif isDefined('xml_company_detail_by_project') and xml_company_detail_by_project eq 1>&company_id=upd_work.company_id&company_name2=upd_work.about_company&partner_id=upd_work.company_partner_id</cfif>&function_name=add_milestone</cfoutput>');"></span>
                                </div>
                            </div>
                        </div>
                        <div class="form-group" id="item-form_ul_workgroup_id">
                            <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='58140.İş Grubu'></label>
                            <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                                <select name="workgroup_id" id="workgroup_id" >
                                    <option value=""><cf_get_lang dictionary_id='58140.Is Grubu'></option>
                                    <cfoutput query="get_workgroups">
                                        <option value="#workgroup_id#" <cfif upd_work.workgroup_id eq workgroup_id>selected</cfif>>#workgroup_name#</option>
                                    </cfoutput>
                                </select>
                            </div>
                        </div>
                        <div class="form-group" id="item-form_ul_rel_work">
                            <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='38187.İlişkili İş'></label>
                            <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                                <div class="input-group">
                                    <cfset head="Iliski Belirleyin">
                                    <cfset rel_work_id="0">	
                                    <cfset relstart_date = "">
                                    <cfset relfinish_date = "">					
                                    <input type="hidden" name="relstartdate" id="relstartdate" value="<cfoutput>#relstart_date#</cfoutput>" />
                                    <input type="hidden" name="relfinish_date" id="relfinish_date" value="<cfoutput>#relfinish_date#</cfoutput>" />
                                    <input type="hidden" name="rel_work_id" id="rel_work_id" value="<cfoutput>#rel_work_id#</cfoutput>">
                                    <input type="hidden" name="rel_work" id="rel_work"  value="<cfoutput>#upd_work.related_work_id#</cfoutput>" >
                                    <cfset relatedwrk_ids_ = "#upd_work.related_work_id#"><!---İlişkili işler ID ve İlişki şeklinde tutulduğu için parçalama işlemleri yapılmıştır.---->
                                    <cfset relatedwrk_ids = relatedwrk_ids_.split(';')>
                                    <cfset clr_wrk_id = "">
                                    <cfset rel_work_head = "">
                                    <cfloop from="2" to="#ArrayLen(relatedwrk_ids)#" index="i">
                                        <cfif relatedwrk_ids[i] contains '+'>
                                            <cfset plus_index=Find("+",relatedwrk_ids[i]) >
                                            <cfset clear_array= Left(relatedwrk_ids[i],plus_index-3)> 
                                        <cfelse>
                                            <cfset clear_array = Left(relatedwrk_ids[i],len(relatedwrk_ids[i])-2)> <!---- ilişki şekli arrayden çıkarılmıştır.-----> 
                                        </cfif>
                                        <cfset rel_work_query = getComponent.GET_WORK(wrk_id : clear_array)>
                                        <cfset rel_work_head = rel_work_head&" "&rel_work_query.work_head >
                                        <cfif i neq ArrayLen(relatedwrk_ids)>  
                                            <cfset rel_work_head = rel_work_head&";">
                                        </cfif>
                                    </cfloop>
                                    <input type="text" name="rel_work_name" id="rel_work_name"  value="<cfoutput>#rel_work_head#</cfoutput>" readonly="readonly" >
                                    <span class="input-group-addon icon-ellipsis btnPointer" onclick="open_related_works()"></span>
                                </div>
                            </div>
                        </div>
                        <div class="form-group" id="item-info_type_id">
                            <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='57810.Ek Bilgi'></label>
                            <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                                <cfif len(UPD_WORK.WORK_CAT_ID)>
                                    <cf_wrk_add_info info_type_id="-18" info_id="#attributes.id#" upd_page = "1" work_catid="#UPD_WORK.WORK_CAT_ID#">
                                <cfelse>
                                    <cf_wrk_add_info info_type_id="-18" info_id="#attributes.id#" upd_page = "1">
                                </cfif>
                            </div>
                        </div>
                    </div>
                    <div class="col col-12 col-xs-12" type="column" sort="true" index="4">
                        <div class="form-group" id="item-form_ul_work_head">
                            <label class="col col-12"><cf_get_lang dictionary_id='57480.Konu'> *</label>
                            <div class="col col-12">
                                <cfsavecontent variable="message"><cf_get_lang dictionary_id="58194.Zorunlu Alan"> : <cf_get_lang dictionary_id='58820.Baslik'></cfsavecontent>
                                <cfinput value="#URLDecode(work_head_)#" type="Text" name="work_head" id="work_head" required="Yes" message="#message#"  maxlength="250">
                            </div>
                        </div>
                    </div>
                    <div class="col col-12 col-xs-12 padding-left-10 padding-right-10" type="column" sort="true" index="5">
                        <cfset tr_topic =''>
                        <div class="form-group" id="item-editor">
                            <label style="display:none!important;"><cf_get_lang dictionary_id='57771.Detay'></label>	
                            <cfmodule
                                template="/fckeditor/fckeditor.cfm"
                                toolbarset="Basic"
                                basepath="/fckeditor/"
                                instancename="work_detail"
                                class="col col-12"
                                valign="top"
                                value="#work_detail_first.work_detail#"
                                width="555"
                                height="180">
                        </div>
                    </div>      
                    <div class="col col-6 col-md-6 col-sm-6 col-xs-12" type="column" index="6" sort="true">
                        <div class="form-group" id="item-form_ul_estimated_time">
                            <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='38215.Öngörülen Süre'></label>
                            <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                                <div class="input-group">
                                    <cfoutput>
                                        <cfif isdefined('upd_work.estimated_time') and len(upd_work.estimated_time)>
                                            <cfset liste=upd_work.estimated_time/60>
                                            <cfset saat=listfirst(liste,'.')>
                                            <cfset dak=upd_work.estimated_time-saat*60>
                                        </cfif>
                                        <cfsavecontent variable="message"><cf_get_lang dictionary_id='38136.Tahmini Süre girmelisiniz'></cfsavecontent>
                                        <cfif isdefined('xml_is_work_finishdate') and xml_is_work_finishdate eq 1>
                                            <input type="text" name="estimated_time" id="estimated_time" validate="integer" message="#message#" value="#saat#" onKeyUp="isNumber(this);"  onBlur="estimated_finishdate(this.value,'hour')" <cfif isdefined('xml_time_duration_stage_update') and xml_time_duration_stage_update neq 1 and not ListFind(xml_is_all_estimated,session.ep.position_code,',')>disabled</cfif>>
                                            <span class="input-group-addon no-bg"><cf_get_lang dictionary_id ='57491.Saat'></span>
                                            <cfsavecontent variable="message"><cf_get_lang dictionary_id='60617.Lütfen 60dan Küçük Bir Değer Giriniz'></cfsavecontent>
                                            <input type="text" name="estimated_time_minute" id="estimated_time_minute" value="#dak#"  onKeyUp="isNumber(this);" range="0,59" onBlur="estimated_finishdate(this.value,'minute')" message="#message#" <cfif isdefined('xml_time_duration_stage_update') and xml_time_duration_stage_update neq 1 and not ListFind(xml_is_all_estimated,session.ep.position_code,',')>disabled</cfif>>
                                            <span class="input-group-addon no-bg "><cf_get_lang dictionary_id='58827.Dk'></span>
                                        <cfelse>
                                            <input type="text" name="estimated_time" id="estimated_time" validate="integer" message="#message#" value="#saat#" onKeyUp="isNumber(this);" <cfif isdefined('xml_time_duration_stage_update') and xml_time_duration_stage_update neq 1 and not ListFind(xml_is_all_estimated,session.ep.position_code,',')>disabled</cfif>>
                                            <span class="input-group-addon no-bg"><cf_get_lang dictionary_id ='57491.Saat'></span>
                                            <cfsavecontent variable="message"><cf_get_lang dictionary_id='60617.Lütfen 60dan Küçük Bir Değer Giriniz'></cfsavecontent>
                                            <input type="text" name="estimated_time_minute" id="estimated_time_minute" value="#dak#"  onKeyUp="isNumber(this);" range="0,59" message="#message#" <cfif isdefined('xml_time_duration_stage_update') and xml_time_duration_stage_update neq 1 and not ListFind(xml_is_all_estimated,session.ep.position_code,',')>disabled</cfif>>
                                            <span class="input-group-addon no-bg "><cf_get_lang dictionary_id='58827.Dk'></span>
                                        </cfif>
                                    </cfoutput>
                                    <div id="upd_date_div_id" ></div>
                                </div>
                            </div>
                        </div>
                        <cfif isdefined('upd_work.estimated_time') and len(upd_work.estimated_time)>
                            <cfset liste = upd_work.estimated_time/60>
                            <cfset saat = listfirst(liste,'.')>
                            <cfset dak = upd_work.estimated_time-saat*60>
                        </cfif>
                        <div class="form-group" id="item-form_ul_startdate_plan" >
                            <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='58053.Başlama'> *</label>
                            <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                                <div class="input-group">
                                    <cfsavecontent variable="message"><cf_get_lang dictionary_id="58194.Zorunlu Alan"> : <cf_get_lang dictionary_id='58053.Baslama Tarihi'></cfsavecontent>
                                    <cfif isdefined('xml_is_work_finishdate') and xml_is_work_finishdate eq 1>
                                        <cfinput type="text" name="startdate_plan" id="startdate_plan" value="#dateformat(sdate_plan,dateformat_style)#" onChange="estimated_finishdate(this.value,'minute')" required="Yes" maxlength="10" validate="#validate_style#" message="#message#" >
                                        <span class="input-group-addon"><cf_wrk_date_image date_field="startdate_plan" c_position="Tl"></span>
                                        
                                        <cfif xml_show_planned_hour eq 1>
                                            <cf_wrkTimeFormat name="start_hour_plan" value="#shour_plan#" onchange="estimated_finishdate(this.value,'minute')">                                                  
                                        <cfelse>
                                            <input type="hidden" name="start_hour_plan" id="start_hour_plan" value="<cfoutput>#shour_plan#</cfoutput>">
                                        </cfif>
                                    <cfelse>
                                        <cfinput type="text" name="startdate_plan" id="startdate_plan" value="#dateformat(sdate_plan,dateformat_style)#" required="Yes" maxlength="10" validate="#validate_style#" message="#message#" >
                                        <span class="input-group-addon"><cf_wrk_date_image date_field="startdate_plan" c_position="Tl"></span>
                                        
                                        <cfif xml_show_planned_hour eq 1>
                                            <cf_wrkTimeFormat name="start_hour_plan" value="#shour_plan#">                                                 
                                        <cfelse>
                                            <input type="hidden" name="start_hour_plan" id="start_hour_plan" value="<cfoutput>#shour_plan#</cfoutput>">
                                        </cfif>
                                    </cfif>
                                </div>	                           
                            </div>   
                        </div>
                        <div class="form-group" id="item-form_ul_finishdate_plan" >
                            <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='57700.Bitiş'>*</label>
                            <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                                <div class="input-group">
                                    <cfsavecontent variable="message"><cf_get_lang dictionary_id="58194.Zorunlu Alan"> : <cf_get_lang dictionary_id='57700.Bitis Tarihi'></cfsavecontent>
                                    <cfinput value="#dateformat(fdate_plan,dateformat_style)#" name="finishdate_plan" id="finishdate_plan" required="Yes" maxlength="10" validate="#validate_style#" message="#message#" type="text" >
                                    <span class="input-group-addon"><cf_wrk_date_image date_field="finishdate_plan" c_position="Tl"></span>
                                    <cfif xml_show_planned_hour eq 1>
                                        <cfoutput>
                                            <cf_wrkTimeFormat name="finish_hour_plan" value="#fhour_plan#">
                                        </cfoutput>
                                    <cfelse>
                                        <input type="hidden" name="finish_hour_plan" id="finish_hour_plan" value="<cfoutput>#fhour_plan#</cfoutput>">
                                    </cfif>
                                </div>
                            </div>
                        </div>
                        <div class="form-group" id="item-form_ul_predicted_start" >
                            <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='29685.Tahmini'><cf_get_lang dictionary_id='58053.Başlama Tarihi'></label>
                            <div class="col col-6 col-md-6 col-sm-6 col-xs-12">
                                <div class="input-group">
                                    <cfif isdefined('psdate') and len(psdate)>
                                        <cfinput type="text" name="predicted_start" id="predicted_start" value="#dateformat(psdate,dateformat_style)#"  maxlength="10" validate="#validate_style#" >
                                    <cfelse>
                                        <cfinput type="text" name="predicted_start" id="predicted_start" value=""  maxlength="10" validate="#validate_style#" >
                                    </cfif>
                                    <span class="input-group-addon"><cf_wrk_date_image date_field="predicted_start" c_position="Tl"></span>
                                </div>
                            </div>
                            <div class="col col-2 col-md-2 col-sm-2 col-xs-12">
                                    <cfif isdefined('pshour') >
                                    <cf_wrkTimeFormat name="predicted_start_hour" value="#pshour#">
                                    <cfelse>
                                    <cf_wrkTimeFormat name="predicted_start_hour" value="0">
                                    </cfif>

                                </div>
                        </div>
                        <div class="form-group" id="item-form_ul_predicted_finish" >
                            <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='29685.Tahmini'><cf_get_lang dictionary_id='57700.Bitiş Tarihi'></label>
                            <div class="col col-6 col-md-6 col-sm-6 col-xs-12">
                                <div class="input-group">
                                    <cfif isdefined('pfdate') and len(pfdate)>
                                        <cfinput name="predicted_finish" id="predicted_finish" value="#dateformat(pfdate,dateformat_style)#" maxlength="10" validate="#validate_style#" type="text" >
                                    <cfelse>
                                        <cfinput name="predicted_finish" id="predicted_finish" value="" maxlength="10" validate="#validate_style#" type="text" >
                                    </cfif>
                                    <span class="input-group-addon"><cf_wrk_date_image date_field="predicted_finish" c_position="Tl"></span>
                                </div>
                            </div>
                            <div class="col col-2 col-md-2 col-sm-2 col-xs-12">
                                    <cfoutput>
                                    <cfif isdefined('pfhour')>
                                    <cf_wrkTimeFormat name="predicted_finish_hour" value="#pfhour#">
                                    <cfelse>
                                    <cf_wrkTimeFormat name="predicted_finish_hour" value="0">
                                    </cfif>
                                    </cfoutput>
                                </div>
                        </div>
                        <div class="form-group" id="item-form_ul_average_amount">
                            <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='29685.Tahmini'> <cf_get_lang dictionary_id='57635.Miktar'></label>
                            <div class="col col-6 col-md-6 col-sm-6 col-xs-12">
                                <cfinput type="text" name="average_amount" id="average_amount" value="#TLFormat(upd_work.average_amount)#"  passthrough="onkeyup=""return(formatcurrency(this,event));""" class="moneybox">
                                <cfquery name="getUnit" datasource="#dsn#">
                                    SELECT UNIT_ID, #dsn#.Get_Dynamic_Language(SETUP_UNIT.UNIT_ID,'#session.ep.language#','SETUP_UNIT','UNIT',NULL,NULL,SETUP_UNIT.UNIT) AS UNIT FROM SETUP_UNIT ORDER BY UNIT
                                </cfquery>
                            </div>
                            <div class="col col-2 col-md-2 col-sm-2 col-xs-12">
                                <select name="amount_unit" id="amount_unit" class="formselect" >
                                    <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                    <cfoutput query="getUnit">
                                        <option value="#unit_id#" <cfif upd_work.average_amount_unit eq unit_id>selected</cfif>>#unit#</option>
                                    </cfoutput>
                                </select>
                            </div>    
                        </div>
                        <div class="form-group" id="item-form_ul_purchase_contract_amount">
                            <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='58176.Alış'> <cf_get_lang dictionary_id='57638.Birim Fiyat'></label>
                            <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                                <cfinput type="text" name="purchase_contract_amount" id="purchase_contract_amount" value="#TLFormat(upd_work.purchase_contract_amount)#" passthrough="onkeyup=""return(formatcurrency(this,event));"""  class="moneybox">
                            </div>
                        </div>
                        <div class="form-group" id="item-form_ul_sale_contract_amount">
                            <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='57448.Satış'> <cf_get_lang dictionary_id='57638.Birim Fiyat'></label>
                            <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                                <cfinput type="text" name="sale_contract_amount" id="sale_contract_amount" value="#TLFormat(upd_work.sale_contract_amount)#" passthrough="onkeyup=""return(formatcurrency(this,event));"""  class="moneybox">
                            </div>
                        </div>
                        <div class="form-group" id="item-form_ul_expected_budget">
                            <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='38175.Tahmini Bütçe'></label>
                            <div class="col col-6 col-md-6 col-sm-6 col-xs-12">
                                    <cfinput type="text" name="expected_budget" id="expected_budget" value="#TLFormat(upd_work.expected_budget)#" passthrough="onkeyup=""return(formatcurrency(this,event));""" class="moneybox">
                            </div>
                            <div class="col col-2 col-md-2 col-sm-2 col-xs-12">
                                    <select name="expected_budget_money" id="expected_budget_money" class="formselect" >
                                        <cfinclude template="../query/get_money_currency.cfm">
                                        <cfoutput query="get_money">
                                            <option value="#money#"<cfif money is upd_work.expected_budget_money> selected</cfif>>#money#</option>
                                        </cfoutput>
                                    </select>     	
                            </div>
                        </div>
                        <div class="form-group" id="item-form_ul_duration">
                            <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='29513.Süre'></label>
                            <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                                <input type="text" name="duration" id="duration" value="<cfoutput>#upd_work.duration#</cfoutput>" />
                            </div>
                        </div>
                        <div class="form-group" id="item-form_ul_special_definition">
                            <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='38125.Özel Tanım'></label>
                            <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                                <select name="special_definition" id="special_definition" >
                                    <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                    <cfoutput query="GET_SPECIAL_DEFINITION">
                                        <option value="#special_definition_id#" <cfif upd_work.special_definition_id eq special_definition_id>selected="selected"</cfif>>#special_definition#</option>
                                    </cfoutput>
                                </select>
                            </div>
                        </div>
                        <div class="form-group" id="item-form_ul_milestone_work_id">
                            <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><input type="checkbox" value="1" name="is_milestone"  id="is_milestone" <cfif upd_work.is_milestone eq 1>checked</cfif>>Milestone</label>
                            <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                                <select name="milestone_work_id" id="milestone_work_id" >
                                    <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                    <cfif len(upd_work.project_id)>
                                        <cfquery name="GET_WORK_MILESTONE" datasource="#DSN#">
                                            SELECT 
                                                WORK_ID,
                                                WORK_HEAD 
                                            FROM 
                                                PRO_WORKS 
                                            WHERE 
                                                PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#upd_work.project_id#"> AND
                                                IS_MILESTONE = 1 AND
                                                WORK_ID <> #attributes.id#
                                        </cfquery>
                                        <cfoutput query="get_work_milestone">
                                            <option value="#work_id#"<cfif upd_work.milestone_work_id eq work_id>selected</cfif>>#work_head#</option>
                                        </cfoutput>
                                    </cfif>
                                </select>
                            </div>
                        </div>
                    </div>
                    <div class="col col-6 col-md-6 col-sm-6 col-xs-12" type="column" index="7" sort="true">
                        <div class="form-group" id="item-form_ul_total_time_minute">
                            <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='38306.Gerçekleşen Süre'></label>
                            <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                                <div class="input-group">
                                    <cfsavecontent variable="message">0-59 <cf_get_lang dictionary_id='38295.Arasi Giriniz'>!</cfsavecontent>
                                    <input type="text" name="total_time_hour" id="total_time_hour" value=""   onkeyup="isNumber(this);">
                                    <span class="input-group-addon no-bg"><cf_get_lang dictionary_id='57491.Saat'></span>
                                    <cfinput type="text" name="total_time_minute" id="total_time_minute" value=""  range="0,59" onKeyUp="isNumber(this);" message="#message#">
                                    <span class="input-group-addon no-bg"><cf_get_lang dictionary_id='58827.Dk'></span>
                                </div>
                            </div>
                        </div>
                        <div class="form-group" id="item-form_ul_terminate_date" >
                            <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='38146.Termin'></label>
                            <div class="col col-6 col-md-6 col-sm-6 col-xs-12">
                                <div class="input-group">
                                    <cfinput name="terminate_date" id="terminate_date" validate="#validate_style#" maxlength="10" type="text" value="#dateformat(termin_date,dateformat_style)#" >
                                    <span class="input-group-addon"><cf_wrk_date_image date_field="terminate_date" c_position="Tl"></span>
                                </div>
                            </div>
                            <div class="col col-2 col-md-2 col-sm-2 col-xs-12">
                                <cfoutput>
                                    <cf_wrkTimeFormat name="terminate_hour" value="#termin_hour#">
                                </cfoutput>
                            </div>
                        </div>
                        <div class="form-group" id="item-form_ul_work_h_start">
                            <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='58053.Baslama Tarihi'></label>
                            <div class="col col-6 col-md-6 col-sm-6 col-xs-12">
                                <div class="input-group">
                                    <cfif isdefined('sdate') and len(sdate)>
                                        <cfinput type="text" name="work_h_start" id="work_h_start" value="#dateformat(sdate,dateformat_style)#"  maxlength="10" validate="#validate_style#" >
                                    <cfelse>
                                        <cfinput type="text" name="work_h_start" id="work_h_start" value=""  maxlength="10" validate="#validate_style#" >
                                    </cfif>
                                    <span class="input-group-addon"><cf_wrk_date_image date_field="work_h_start" c_position="Tl"></span>
                                </div>
                            </div>
                            <div class="col col-2 col-md-2 col-sm-2 col-xs-12">
                                <cfif isdefined('shour')>
                                <cf_wrkTimeFormat name="start_hour" value="#shour#">
                                <cfelse>
                                <cf_wrkTimeFormat name="start_hour" value="0">
                                </cfif>    
                            </div>	
                        </div>
                        <div class="form-group" id="item-form_ul_work_h_finish">
                            <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='57700.Bitis Tarihi'></label>
                            <div class="col col-6 col-md-6 col-sm-6 col-xs-12">
                                <div class="input-group">
                                    <cfif isdefined('fdate') and len(fdate)>
                                        <cfinput value="#dateformat(fdate,dateformat_style)#" maxlength="10" validate="#validate_style#" type="text" name="work_h_finish" id="work_h_finish" >
                                    <cfelse>
                                        <cfinput value="" maxlength="10" validate="#validate_style#" type="text"  name="work_h_finish" id="work_h_finish" >
                                    </cfif>
                                    <span class="input-group-addon"><cf_wrk_date_image date_field="work_h_finish" c_position="Tl"></span>
                                </div>	
                            </div>
                            <div class="col col-2 col-md-2 col-sm-2 col-xs-12">
                                <cfoutput>
                                <cfif isdefined('fhour')>
                                <cf_wrkTimeFormat name="finish_hour" value="#fhour#">
                                <cfelse>
                                <cf_wrkTimeFormat name="finish_hour" value="0">
                                </cfif>
                                </cfoutput>
                            </div>
                        </div>
                        <div class="form-group" id="item-form_ul_to_complate">
                            <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='38307.Tamamlanma'> %</label>
                            <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                                <cfinput type="text" name="to_complate" id="to_complate" value="#upd_work.to_complete#"  onkeyup="complate_control(); return(FormatCurrency(this,event,0));"  maxlength="3" placeholder="#getlang('project',155,'0-100 arası tam sayı değeri giriniz!')#" min="0" max="100">         
                            </div>
                        </div>
                        <div class="form-group" id="item-form_ul_completed_amount">
                            <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='38142.Tamamlanan Miktar'></label>
                            <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                                <cfsavecontent variable="alert"><cf_get_lang dictionary_id='38476.Lütfen Bir Tamsayi Degeri Giriniz !'>!</cfsavecontent>
                                <cfinput type="text" name="completed_amount" id="completed_amount" value="#tlformat(upd_work.completed_amount)#" message="#alert#" onKeyUp="isNumber(this,1);" >
                            </div>
                        </div>
                        <div class="form-group" id="item-form_ul_work_status">
                            <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='57493.Aktif'><input type="checkbox" name="work_status" id="work_status" <cfif upd_work.work_status eq 1>checked="checked"</cfif> /></label>
                            <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id="57475.Mail Gönder"><input type="checkbox" name="is_mail" id="is_mail" value="1"<cfif isdefined("xml_is_send_mail") and xml_is_send_mail eq 1>checked="checked"</cfif>></label>
                            <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='38134.Rework'><input type="checkbox" value="1" name="rework" id="rework" <cfif upd_work.rework eq 1>checked="checked"</cfif>></label>
                        </div>
                    </div>
                    <div class="col col-12" sort="true" index="8" type="column">
                        <cfsavecontent variable="info"><label class="bold"><cf_get_lang dictionary_id='58773.Bilgi Verilcekler'></label></cfsavecontent>
                        <!---Bilgi Verilecekler--->
                        <div class="form-group">
                            <label style="display:none!important"><cf_get_lang dictionary_id='58773.Bilgi Verilecekler'></label>
                            <cf_workcube_to_cc 
                                is_update="1" 
                                cc_dsp_name="#info#" 
                                form_name="upd_work" 
                                str_list_param="1,7" 
                                action_dsn="#dsn#"
                                str_action_names="CC_EMP_ID AS CC_EMP, CC_PAR_ID AS CC_PAR"
                                action_table="PRO_WORKS_CC"
                                action_id_name="WORK_ID"
                                action_id="#attributes.id#"
                                data_type="2"
                                str_alias_names="">
                        </div>
                    </div>
                </cf_box_elements>
                <div class="ui-form-list-btn">	<!---/// footer alanı record info ve submit butonu--->
                    <div class="col col-6 col-md-6 col-sm-6 col-xs-12"><cf_record_info query_name="upd_work" record_emp="record_author" update_emp="update_author" is_partner="1"></div> <!---///record info--->
                    <div class="col col-6 col-md-6 col-sm-6 col-xs-12"><cf_workcube_buttons is_upd='1' add_function='chk_work(#upd_work.project_id#)'></div> <!---///butonlar--->
                </div>
            </cfform>
        </cf_box>
    </div>
</cfif>
<script type="text/javascript">
    function calculateBudget() {
        var averageAmount = parseFloat(document.getElementById("average_amount").value.replace(',', '.'));
        var saleContractAmount = parseFloat(document.getElementById("sale_contract_amount").value.replace(',', '.'));

        if (!isNaN(averageAmount) && !isNaN(saleContractAmount)) {
            var budget = (averageAmount * saleContractAmount).toFixed(2);
            document.getElementById("expected_budget").value = budget.toString().replace('.', ',');
        } else {
            document.getElementById("expected_budget").value = "";
        }
    }
    document.getElementById("average_amount").addEventListener("keyup", calculateBudget);
    document.getElementById("sale_contract_amount").addEventListener("keyup", calculateBudget);

 <cfif isdefined('xml_time_duration_stage_update') and  xml_time_duration_stage_update neq 1>
    $(document).click(function (e) {
        if ($("#"+e.target.id).prop('disabled') && e.target.id=="estimated_time"){
            $('.ui-cfmodal__alert .required_list li').remove();
            $('.ui-cfmodal__alert .required_list').append('<li><cf_get_lang dictionary_id='65563.Öngörülen Süre Güncelleyemezsiniz.Yetkili Değilsiniz.'>!</li>');
            $('.ui-cfmodal__alert').fadeIn();       
        }
        }); 
    </cfif>
	<cfif isdefined("xml_is_stage_cat") and xml_is_stage_cat eq 1>
		tmplt(2);
	</cfif>
    var k=0;    
	function tmplt(type)
	{
		if(document.getElementById('pro_work_cat') != undefined)
		{
			var pwc = document.getElementById('pro_work_cat').value;
			if(type == undefined) type = 0;
			if(type == 0 || type == 2)//kategoriye bagli süreç gelecek
			{
				if(pwc!='')
				{
					goster(stage2);
					goster(stage1);
					AjaxPageLoad('<cfoutput>#request.self#</cfoutput>?fuseaction=project.popup_list_stage&value=<cfoutput>#upd_work.work_currency_id#</cfoutput>&type='+type+'&category_id='+pwc,'stage1');
				}
			}
			else//kategori ve sürece bagli template gelecek
			{
				<cfif isdefined("xml_is_stage_cat") and xml_is_stage_cat eq 1>
					var pro_stage = document.getElementById('process_stage').value;
					if(pwc !='' && pro_stage != '')
					{
						//goster(stage2);
						//goster(stage1);
						setTimeout(function(){;AjaxPageLoad('<cfoutput>#request.self#</cfoutput>?fuseaction=project.popup_get_template&pro_stage='+pro_stage+'&pwc='+pwc,'fckedit',1)},500);
					}
				</cfif>
			}
		}
	}
	function chk_work(pro_id)
	{
       
		//safaride olusan hata yüzünden bu ekleme yapilmistir.
		if((document.upd_work.pro_id.value>0)&&(document.upd_work.project_id.value>0)&&(document.upd_work.rel_work_id.value!=0)&&(document.upd_work.rel_work_id.value!="")&&(document.upd_work.project_id.value!=pro_id))
			if(confirm("<cf_get_lang dictionary_id ='38317.Iliskilendirilmis is seçtiginiz projeye ait degil.Is iliskisi silinecek'>!"))
			{
				windowopen('<cfoutput>#request.self#?fuseaction=project.emptypopup_arrange_rel&work_id=#url.ID#</cfoutput>&rel_work_id='+document.upd_work.rel_work_id.value,'','small');
				document.getElementById('rel_work_id').value="";
				document.getElementById('rel_work').value="";
			}
			else 
				return false;
			return kontrol();		
	}
	
	
	function kontrol()
	{
        <cfif isdefined("xml_dead_line_time") and xml_dead_line_time eq 1>
        
            if ((upd_work.today.value.length != 0) && (upd_work.terminate_date.value.length != 0))
            {
            
                if(dateformat_style == 'dd/mm/yyyy'){
                    date1_control = upd_work.terminate_date.value.substr(6,4) + upd_work.terminate_date.value.substr(3,2) + upd_work.terminate_date.value.substr(0,2);
                    date2_control = upd_work.today.value.substr(6,4) + upd_work.today.value.substr(3,2) + upd_work.today.value.substr(0,2);
                }
                else {
                    date1_control = upd_work.terminate_date.value.substr(6,4) + upd_work.terminate_date.value.substr(0,2) +  upd_work.terminate_date.value.substr(3,2)
                    date2_control = upd_work.today.value.substr(6,4) + upd_work.today.value.substr(0,2) + upd_work.today.value.substr(3,2);
                }
                if (date2_control > date1_control) 
                {
                
                    $('.ui-cfmodal__alert .required_list li').remove();
                    $('.ui-cfmodal__alert .required_list').append('<li><cf_get_lang dictionary_id='65924.Termin tarihi geri tarihli olamaz'>!</li>');
                    $('.ui-cfmodal__alert').fadeIn();
                    return false;
                }
            }
        </cfif>

		tarih1_ = '';
		tarih3_ = '';
		fix_date(document.getElementById('startdate_plan'),document.getElementById('startdate_plan').name);
		fix_date(document.getElementById('finishdate_plan'),document.getElementById('finishdate_plan').name);
		
		tarih1_ = document.getElementById('startdate_plan').value.substr(6,4) +document.getElementById('startdate_plan').value.substr(3,2) + document.getElementById('startdate_plan').value.substr(0,2);
		tarih2_ = document.getElementById('p_sdate').value.substr(6,4) + document.getElementById('p_sdate').value.substr(3,2) + document.getElementById('p_sdate').value.substr(0,2);
		tarih3_ = document.getElementById('finishdate_plan').value.substr(6,4) + document.getElementById('finishdate_plan').value.substr(3,2) + document.getElementById('finishdate_plan').value.substr(0,2);
		tarih4_ = document.getElementById('p_fdate').value.substr(6,4) + document.getElementById('p_fdate').value.substr(3,2) + document.getElementById('p_fdate').value.substr(0,2);
		
        gelen = document.getElementById('to_complate').value;    
        if(gelen>100){
            
            $('.ui-cfmodal__alert .required_list li').remove();
            $('.ui-cfmodal__alert .required_list').append('<li><cf_get_lang dictionary_id='38276.Tamamlanma % si 0-100 arasında olmalıdır!'>!</li>');
            $('.ui-cfmodal__alert').fadeIn();
            return false;
           
        }else if (gelen<0) {
            $('.ui-cfmodal__alert .required_list li').remove();
            $('.ui-cfmodal__alert .required_list').append('<li><cf_get_lang dictionary_id='38276.Tamamlanma % si 0-100 arasında olmalıdır!'>!</li>');
            $('.ui-cfmodal__alert').fadeIn();
            return false;        
        }else if (gelen == ''){
            $('.ui-cfmodal__alert .required_list li').remove();
            $('.ui-cfmodal__alert .required_list').append('<li><cf_get_lang dictionary_id='38276.Tamamlanma % si 0-100 arasında olmalıdır!'>!</li>');
            $('.ui-cfmodal__alert').fadeIn();
            return false;
        }
        if ((document.getElementById('project_emp_id').value== ""  || document.getElementById('responsable_name').value== "")  && (document.getElementById('task_partner_id').value== "" || document.getElementById('responsable_name').value == ""))
		{
            $('.ui-cfmodal__alert .required_list li').remove();
            $('.ui-cfmodal__alert .required_list').append('<li>"<cf_get_lang dictionary_id='38201.Görevli Secmelisiniz'>!</li>');
            $('.ui-cfmodal__alert').fadeIn();
            return false;
		}	
        <cfif isdefined("xml_time_required") and xml_time_required eq 1>
            if (document.getElementById('total_time_minute').value== "" || document.getElementById('total_time_hour').value== "" )
            {
                $('.ui-cfmodal__alert .required_list li').remove();
                $('.ui-cfmodal__alert .required_list').append('<li><cf_get_lang dictionary_id='31491.Gerçekleşen'> - <cf_get_lang dictionary_id='38148.Harcanan Zaman'> <cf_get_lang dictionary_id='61824.Giriniz'>!</li>');
                $('.ui-cfmodal__alert').fadeIn();
                return false;
              
            }	
        </cfif>	
		
		if (document.getElementById('priority_cat').value == "")
		{ 
            $('.ui-cfmodal__alert .required_list li').remove();
            $('.ui-cfmodal__alert .required_list').append('<li><cf_get_lang dictionary_id='58194.Zorunlu Alan'> : <cf_get_lang dictionary_id='57485.Öncelik'>!</li>');
            $('.ui-cfmodal__alert').fadeIn();
            return false;
			
		}
		
		if (document.getElementById('pro_work_cat').value == "")
		{ 
            $('.ui-cfmodal__alert .required_list li').remove();
            $('.ui-cfmodal__alert .required_list').append('<li><cf_get_lang dictionary_id='58194.Zorunlu Alan'> : <cf_get_lang dictionary_id='38177.Is Kategorisi'>!</li>');
            $('.ui-cfmodal__alert').fadeIn();
            return false;
			
		}
		
        //Gunluk 24 saat harcama kontrolu yapiliyor
        <cfif isdefined('x_timecost_limited') and x_timecost_limited eq 0>
		if((document.getElementById("total_time_hour") != undefined && document.getElementById("total_time_hour").value != 0) || (document.getElementById("total_time_minute") != undefined && document.getElementById("total_time_minute").value != 0))
		{
			if(document.getElementById("total_time_hour") == undefined || document.getElementById("total_time_hour").value == "") document.getElementById("total_time_hour").value = 0;
			if(document.getElementById("total_time_minute") == undefined || document.getElementById("total_time_minute").value == "") document.getElementById("total_time_minute").value = 0;
			
			var total_minute = (parseInt(document.getElementById("total_time_hour").value)*60)+parseInt(document.getElementById("total_time_minute").value);
			var total_hour = total_minute/60;
			var get_relation_time_cost = wrk_safe_query("get_relation_time_cost","dsn",0,"<cfoutput>#session.ep.userid#*#date_add('d',-1,now())#*#now()#</cfoutput>");
			if(get_relation_time_cost.recordcount && get_relation_time_cost.TOTAL_TIME != "")
				var total_control = (get_relation_time_cost.TOTAL_TIME/60) + total_hour;
			else
				var total_control = total_hour;
			if(total_control > 24)
			{
                $('.ui-cfmodal__alert .required_list li').remove();
                $('.ui-cfmodal__alert .required_list').append('<li><cf_get_lang dictionary_id ='38446.Bir Gün İçinde 24 Saatten Fazla Zaman Harcaması Girilemez'>!</li>');
                $('.ui-cfmodal__alert').fadeIn();
                return false;
				
            }
		}
        </cfif>
       
		<cfif isDefined('xml_pro_work_date') and xml_pro_work_date eq 1>
			if(document.getElementById('project_id').value != "")
			{
				if(tarih1_ != '' && tarih1_ < tarih2_)
				{
                    $('.ui-cfmodal__alert .required_list li').remove();
                    $('.ui-cfmodal__alert .required_list').append('<li><cf_get_lang dictionary_id ='38314.Girdiginiz Isin Hedef Baslangiç Tarihi Bagli Oldugu Projenin Hedef Baslangiç Tarihinden Önce Görünüyor Lütfen Düzeltin '></li>');
                    $('.ui-cfmodal__alert').fadeIn();
                   
					
				}
				if(tarih3_ != '' && tarih3_ > tarih4_)
				{
                    $('.ui-cfmodal__alert .required_list li').remove();
                    $('.ui-cfmodal__alert .required_list').append('<li><cf_get_lang dictionary_id ='38315.Girdiginiz Isin Hedef Bitis Tarihi Projesinin Hedef Bitis Tarihinden Sonra Gözüküyor Lütfen Düzeltin'>!</li>');
                    $('.ui-cfmodal__alert').fadeIn();
				} 
			}
		</cfif>
        <cfif isdefined("xml_project_required") and xml_project_required eq 1>
            if(document.getElementById('project_id').value == "" )
            {
                $('.ui-cfmodal__alert .required_list li').remove();
                $('.ui-cfmodal__alert .required_list').append('<li><cf_get_lang dictionary_id='58194.Zorunlu Alan'> : <cf_get_lang dictionary_id='57416.Proje'>!</li>');
                $('.ui-cfmodal__alert').fadeIn();
                return false;
            }
        </cfif>
		unformat_fields();
		//document.upd_work.appendChild(document.all.old_process_line);
		return process_cat_control();
		
	}
	function unformat_fields()
	{
        
        document.getElementById('expected_budget').value = filterNum(document.getElementById('expected_budget').value);
		document.getElementById('completed_amount').value = filterNum(document.getElementById('completed_amount').value);
		document.getElementById('average_amount').value = filterNum(document.getElementById('average_amount').value);
		if(document.getElementById('sale_contract_amount') != undefined)
			document.getElementById('sale_contract_amount').value = filterNum(document.getElementById('sale_contract_amount').value);
		if(document.getElementById('purchase_contract_amount') != undefined)
			document.getElementById('purchase_contract_amount').value = filterNum(document.getElementById('purchase_contract_amount').value);
	}
	
	function estimated_finishdate(add_time,type)
	{
        if(document.getElementById('estimated_time_minute').value >= 60)
        {
            $('.ui-cfmodal__alert .required_list li').remove();
            $('.ui-cfmodal__alert .required_list').append("<li><cf_get_lang dictionary_id='60617.Lütfen 60 dan Küçük Bir Değer Giriniz'>!</li>");
            $('.ui-cfmodal__alert').fadeIn();
            return false;
        }
		var startdate_plan = document.getElementById('startdate_plan').value;
		var add_hour = document.getElementById('estimated_time').value;
		var add_minute = document.getElementById('estimated_time_minute').value;
		<cfif isdefined("xml_show_planned_hour") and xml_show_planned_hour eq 1>
			var work_start_hour = document.getElementById('start_hour_plan').value;
			if((startdate_plan != '') && (add_hour != '' || add_minute != ''))
			{
				var send_address = '<cfoutput>#request.self#</cfoutput>?fuseaction=project.emptypopup_add_date&type='+ type +'&work_start_hour='+ work_start_hour +'&startdate_plan='+ startdate_plan +'&add_hour='+add_hour +'&add_minute='+add_minute;
				AjaxPageLoad(send_address,'upd_date_div_id',1);
			}
		</cfif>
	}
	//Bilgi Verilecekler
	row_count="<cfif isDefined("get_related_work_cc")><cfoutput>#get_related_work_cc.recordcount#</cfoutput><cfelse>0</cfif>";
	function add_row()
	{
		row_count++;
		var newRow;
		var newCell;
	
		newRow = document.all.table1.insertRow();
		newRow.setAttribute("name","frm_row" + row_count);
		newRow.setAttribute("id","frm_row" + row_count);
		newRow.className = 'color-row';
	
		
		document.all.record_num.value=row_count;
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<a style="cursor:pointer" onClick="sil(' + row_count + ');"><img src="/images/delete_list.gif" align="absbottom" border="0" alt="<cf_get_lang dictionary_id='57463.Sil'>"></a>&nbsp;&nbsp;&nbsp;<input type="hidden" value="1" name="row_kontrol' + row_count +'"><input type="hidden" name="cc_emp_id'+ row_count +'" id="cc_emp_id'+ row_count +'" value=""><input type="hidden" name="cc_par_id'+ row_count +'" id="cc_par_id'+ row_count +'" value=""><input type="text" name="cc_name'+ row_count +'" id="cc_name'+ row_count +'" value="" style="width:125px;" onFocus="auto_member_cc('+ row_count +');" autocomplete="off"><a href="javascript://" onClick="pencere_ac('+ row_count +');" style="cursor:pointer;"> <img src="/images/plus_thin.gif" align="absbottom" border="0" alt="<cf_get_lang dictionary_id='57582.Ekle'>"></a>';	
	}
	function sil(sy)
	{
		var my_element = document.getElementById("row_kontrol"+sy);
		my_element.value=0;
		var my_element = document.getElementById("frm_row"+sy);
		my_element.style.display="none";
	}
	
	function pencere_ac(no)
	{
		openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_positions&field_emp_id=upd_work.cc_emp_id'+ no +'&field_name=upd_work.cc_name'+ no +'&field_partner=upd_work.cc_par_id'+ no +'&select_list=1,2');
	}
	function auto_member_cc(no)
	{
		AutoComplete_Create('cc_name'+no,'MEMBER_PARTNER_NAME3,MEMBER_NAME2','MEMBER_PARTNER_NAME3,MEMBER_NAME2','get_member_autocomplete','\'1,3\',0,0,0','PARTNER_ID,EMPLOYEE_ID','cc_par_id'+no+',cc_emp_id'+no+'','','3','250');
	}
	
	function pencere_ac_pbs_code()
	{
		if(document.getElementById('project_id').value == "" && document.getElementById('project_head').value == "")
		{
            $('.ui-cfmodal__alert .required_list li').remove();
            $('.ui-cfmodal__alert .required_list').append('<li><cf_get_lang dictionary_id='58194.Zorunlu Alan'> : <cf_get_lang dictionary_id='57416.Proje'>!</li>');
            $('.ui-cfmodal__alert').fadeIn();
            return false;
		}
		else
			windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=product.popup_list_pbs_code&is_submitted=1&is_single=1&project_id='+document.getElementById('project_id').value+'&field_id=upd_work.pbs_id&field_name=upd_work.pbs_code','list','popup_list_pbs_code');
	}
	function delete_project()
	{
		if(document.getElementById('project_head').value=='')
		{
			document.getElementById('project_id').value='';
			document.getElementById('p_sdate').value='';
			document.getElementById('p_fdate').value='';
		}
		
	}
	function add_milestone()
	{
		if(document.getElementById('project_id').value)
		{
			var GET_MILESTONE = wrk_safe_query('get_upd_milestone','dsn',0,document.getElementById('project_id').value+'*'+document.getElementById('work_id').value);
			if(GET_MILESTONE.recordcount > 0)
			{
				document.getElementById("milestone_work_id").options.length = 0;
				document.getElementById("milestone_work_id").options.add(new Option('<cf_get_lang dictionary_id="57734.Seçiniz">', ''));
				for(i=0;i<GET_MILESTONE.recordcount;++i)
				{
					document.getElementById("milestone_work_id").options.add(new Option(GET_MILESTONE.WORK_HEAD[i], GET_MILESTONE.WORK_ID[i])); 
				}


			}
		}
		/*<cfif isDefined('xml_company_detail_by_project') and  xml_company_detail_by_project eq 0>
			document.getElementById("company_id").value = '';
			document.getElementById("company_partner_id").value = '';
			document.getElementById("about_company").value = '';
		</cfif>*/
	}
	function open_related_works()
	{
		if(document.getElementById('project_id').value == '')
		{
            $('.ui-cfmodal__alert .required_list li').remove();
            $('.ui-cfmodal__alert .required_list').append('<li><cf_get_lang dictionary_id='60618.Iliskili Is Seçmek Için Proje Seçiniz'>!</li>');
            $('.ui-cfmodal__alert').fadeIn();
			return false;
		}
		else
		{
		openBoxDraggable('<cfoutput>#request.self#?fuseaction=project.popup_related_works&rel_work=</cfoutput>'+document.getElementById('rel_work').value+'&work_id='+document.getElementById('work_id').value+'&project_id='+document.getElementById('project_id').value,'medium');
		}
	}
	
	function get_convert_values()
	{
			
		var convert_stocks_id = document.getElementById('convert_stocks_id').value;
		var convert_spect_id = document.getElementById('convert_spect_id').value;
		var convert_amount = document.getElementById('convert_amount_stocks_id').value;
		var convert_price = document.getElementById('convert_price').value;
		var convert_price_other = document.getElementById('convert_price_other').value;
		var convert_money = document.getElementById('convert_money').value;
		var convert_cost_price = document.getElementById('convert_cost_price').value;
		var convert_extra_cost = document.getElementById('convert_extra_cost').value;
		var record_num = document.getElementById('record_num').value;
		adres = '';
		adres += '&convert_stocks_id='+convert_stocks_id+',';
		adres += '&convert_spect_id='+convert_spect_id+',';
		adres += '&convert_amount_stocks_id='+convert_amount+',';
		adres += '&convert_price='+convert_price+',';
		adres += '&convert_price_other='+convert_price_other+',';
		adres += '&convert_money='+convert_money+',';
		adres += '&convert_cost_price='+convert_cost_price+',';
		adres += '&convert_extra_cost='+convert_extra_cost+',';
		adres += '&record_num='+record_num;
		window.open('<cfoutput>#request.self#?fuseaction=stock.form_add_fis&is_from_work=1&work_id=#upd_work.work_id#&service_id=#upd_work.service_id#&pj_id=#upd_work.project_id#&project_head=<cfif len(upd_work.project_id)>#get_project_name(upd_work.project_id)#</cfif>&type=convert&process_type=111<cfif  isDefined("GET_MATERIAL_LIST") and GET_MATERIAL_LIST.recordcount>&material_id=#GET_MATERIAL_LIST.PRO_MATERIAL_ID#</cfif></cfoutput>'+adres,'wwide');
		return true;
	}
    function complate_control()
    {
        gelen = document.getElementById('to_complate').value;    
        if(gelen>100){
            $('.ui-cfmodal__alert .required_list li').remove();
            $('.ui-cfmodal__alert .required_list').append('<li><cf_get_lang dictionary_id='38276.Tamamlanma % si 0-100 arasında olmalıdır!'></li>');
            $('.ui-cfmodal__alert').fadeIn();
                    
        }else if (gelen<0) {
            $('.ui-cfmodal__alert .required_list li').remove();
            $('.ui-cfmodal__alert .required_list').append('<li><cf_get_lang dictionary_id='38276.Tamamlanma % si 0-100 arasında olmalıdır!'></li>');
            $('.ui-cfmodal__alert').fadeIn();
            return false;
        }
        
        // Dropdown'u otomatik güncelle: %0=boş, %1-99=Başlandı-Devam(2361), %100=Tamamlandı(2364)
        var stageSelect = document.querySelector('select[name="r_slot"]');
        if(stageSelect) {
            var val = parseInt(gelen) || 0;
            if(val >= 100) {
                stageSelect.value = '2364'; // Tamamlandı
            } else if(val > 0) {
                stageSelect.value = '2361'; // Başlandı - Devam
            } else {
                stageSelect.value = ''; // Boş
            }
        }
    }
</script> 
