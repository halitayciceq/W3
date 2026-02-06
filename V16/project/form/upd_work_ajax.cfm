<cfinclude template="../query/get_work.cfm">
<cfif len(upd_work.project_id)>
    <cfquery name="GET_PRO_NAME" datasource="#DSN#">
        SELECT PROJECT_HEAD,TARGET_START,TARGET_FINISH FROM PRO_PROJECTS WHERE PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#upd_work.project_id#">
    </cfquery>
</cfif>
<cfinclude template="../query/get_workgroups.cfm">
<cfinclude template="../query/get_pro_work_cat.cfm">
<cfinclude template="../query/get_priority.cfm">
<cfquery name="GET_ACTIVITY" datasource="#DSN#">
    SELECT ACTIVITY_ID, ACTIVITY_NAME FROM SETUP_ACTIVITY WHERE ACTIVITY_STATUS = 1 ORDER BY ACTIVITY_NAME
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
    SELECT SPECIAL_DEFINITION_ID,SPECIAL_DEFINITION FROM SETUP_SPECIAL_DEFINITION WHERE SPECIAL_DEFINITION_TYPE = 7
</cfquery>
<cfset work_head_ = URLEncodedFormat(upd_work.work_head)> <!--- tirnakli ifadeleri yok etmek için --->
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
<cfparam name="liste" default="">
<cfparam name="saat" default="">
<cfparam name="dak" default="">
<cfset workcube_license = createObject("V16.settings.cfc.workcube_license").get_license_information() />
<cfform name="upd_work" id="upd_work" method="post" action="#request.self#?fuseaction=project.emptypopup_upd_work">
    <cfoutput>
        <input type="hidden" name="update_name" id="update_name" value="<cfif isdefined("GET_EMPLOYEE_NAME") and GET_EMPLOYEE_NAME.recordcount>#GET_EMPLOYEE_NAME.UPDATE_NAME#<cfelseif isdefined("GET_PARTNER_NAME")>#GET_PARTNER_NAME.UPDATE_NAME#</cfif>">
        <input type="hidden" name="responsible" id="responsible" value="<cfif isdefined("PARTNER_NAME") and len(upd_work.outsrc_cmp_id) and len(upd_work.outsrc_partner_id)>#PARTNER_NAME.prt_name#<cfelseif isdefined("EMPLOYEE_NAME")>#EMPLOYEE_NAME.emp_name#</cfif>">
        <input type="hidden" name="work_id" id="work_id" value="#attributes.id#">
        <input type="hidden" name="work_no" id="work_no" value="#upd_work.work_no#">
        <input type="hidden" name="today" id="today" value="#DateFormat(now(),dateformat_style)#">
        <input type="hidden" name="id" id="id" value="#attributes.id#">
        <input type="hidden" name="is_det" id="is_det" value="1">
        <input type="hidden" name="pro_id" id="pro_id" value="#upd_work.project_id#">
        <input type="hidden" name="g_service_id" id="g_service_id" value="#upd_work.g_service_id#">
        <input type="hidden" name="service_id" id="service_id" value="#upd_work.service_id#">
        <input type="hidden" name="forum_reply_id" id="forum_reply_id" value="#upd_work.forum_reply_id#">
        <input type="hidden" name="purchase_contract_id" id="purchase_contract_id" value="<cfif len(upd_work.purchase_contract_id)>#upd_work.purchase_contract_id#</cfif>">
        <input type="hidden" name="sale_contract_id" id="sale_contract_id" value="<cfif len(upd_work.sale_contract_id)>#upd_work.sale_contract_id#</cfif>">
        <input type="hidden" name="our_company_id" id="our_company_id" value="<cfif len(upd_work.our_company_id)>#upd_work.our_company_id#<cfelse>#session.ep.company_id#</cfif>">
        <cfif isdefined("get_hist_detail.work_currency_id") and len(get_hist_detail.work_currency_id)>
            <input type="hidden" name="old_currency" id="old_currency" value="#get_hist_detail.work_currency_id#">
        <cfelse>
            <input type="hidden" name="old_currency" id="old_currency" value="#upd_work.work_currency_id#">
        </cfif>     
            <input type="hidden" name="pro_work_cat" id="pro_work_cat" value="#upd_work.work_cat_id#">
            <input type="hidden" name="completed_amount" id="completed_amount" value="#upd_work.completed_amount#">
            <input type="hidden" name="average_amount" id="average_amount" value="#upd_work.average_amount#">
            <input type="hidden" name="purchase_contract_amount" id="purchase_contract_amount" value="#upd_work.purchase_contract_amount#">
            <input type="hidden" name="sale_contract_amount" id="sale_contract_amount" value="#upd_work.sale_contract_amount#">
            <input type="hidden" name="amount_unit" id="amount_unit" value="#upd_work.average_amount_unit#">
            <input type="hidden" name="expected_budget_money" id="expected_budget_money" value="#upd_work.expected_budget_money#">
            <input type="hidden" name="expected_budget" id="expected_budget" value="#upd_work.expected_budget#">
            <input type="hidden" name="work_head" id="work_head" value="#URLDecode(work_head_)#">
            <input type="hidden" name="project_id" id="project_id" value="#upd_work.project_id#">
            <input type="hidden" name="company_id" id="company_id" value="<cfif len(upd_work.company_id)>#upd_work.company_id#</cfif>">
            <input type="hidden" name="about_company" id="about_company" value="<cfif len(upd_work.company_id)>#get_par_info(upd_work.company_id,1,1,0)#</cfif>">
            <input type="hidden" name="priority_cat" id="priority_cat" value="#upd_work.work_priority_id#">
            <input type="hidden" name="startdate_plan" id="startdate_plan" value="#dateformat(sdate_plan,dateformat_style)#">
            <input type="hidden" value="#dateformat(fdate_plan,dateformat_style)#" name="finishdate_plan" id="finishdate_plan">
            <input type="hidden" value="" name="activity_type" id="activity_type">
            <input type="hidden" name="workgroup_id" id="workgroup_id" value="#upd_work.workgroup_id#">
            <input type="hidden" name="start_hour_plan" id="start_hour_plan" value="#shour_plan#">
            <cfif isdefined('shour')><input type="hidden" name="start_hour" id="start_hour" value="#shour#"><cfelse><input type="hidden" name="start_hour" id="start_hour" value="0"></cfif>
            <cfif isdefined('fhour')><input type="hidden" name="finish_hour" id="finish_hour" value="#fhour#"><cfelse><input type="hidden" name="finish_hour" id="finish_hour" value="0"></cfif>
            <input type="hidden" name="finish_hour_plan" id="finish_hour_plan" value="#fhour_plan#">
            <input type="hidden" name="project_head" id="project_head" value="<cfif len(upd_work.project_id)>#get_project_name(upd_work.project_id)#</cfif>">
            <input type="hidden" name="p_sdate" id="p_sdate" value="<cfif len(upd_work.project_id)>#dateformat(get_pro_name.target_start,dateformat_style)#</cfif>">
            <input type="hidden" name="p_fdate" id="p_fdate" value="<cfif len(upd_work.project_id)>#dateformat(get_pro_name.target_finish,dateformat_style)#</cfif>">                                                
            <cfset rel_work_id="0">	
            <cfset relstart_date = "">
            <cfset relfinish_date = "">	
            <input type="hidden" name="relstartdate" id="relstartdate" value="#relstart_date#"/>
            <input type="hidden" name="relfinish_date" id="relfinish_date" value="#relfinish_date#"/>
            <input type="hidden" name="rel_work_id" id="rel_work_id" value="#rel_work_id#">
            <input type="hidden" name="rel_work" id="rel_work"  value="#upd_work.related_work_id#"/>
            <cfif IsDefined("xml_is_all_estimated")><input type="hidden" name="xml_is_all_estimated" id="xml_is_all_estimated" value="#xml_is_all_estimated#"></cfif>
            <cfif IsDefined("xml_time_duration_stage_update")><input type="hidden" name="xml_time_duration_stage_update" id="xml_time_duration_stage_update" value="#xml_time_duration_stage_update#"></cfif>
            <cfif IsDefined("xml_waste_of_time")><input type="hidden" name="xml_waste_of_time" id="xml_waste_of_time" value="#xml_waste_of_time#"></cfif>
            <cfif isdefined('sdate') and len(sdate)>
                <input type="hidden" name="work_h_start" id="work_h_start"  value="#dateformat(sdate,dateformat_style)#">
            <cfelse>
                <input type="hidden" name="work_h_start" id="work_h_start"  value="">
            </cfif>
            <cfif isdefined('fdate') and len(fdate)>
                <input type="hidden" name="work_h_finish" id="work_h_finish"  value="#dateformat(fdate,dateformat_style)#">
            <cfelse>
                <input type="hidden" name="work_h_finish" id="work_h_finish"  value="">
            </cfif>
            <cfif upd_work.is_milestone eq 1>
                <input type="hidden" name="is_milestone" id="is_milestone"  value="1">
            <cfelse>
                <input type="hidden" name="is_milestone" id="is_milestone"  value="">
            </cfif>
            <input type="hidden" name="company_partner_id" id="company_partner_id" value="<cfif len(upd_work.company_partner_id)>#upd_work.company_partner_id#<cfelseif len(upd_work.consumer_id)>#upd_work.consumer_id#</cfif>">
            <cfif IsDefined("xml_link")><input type="hidden" name="is_xml_link" id="is_xml_link" value="#xml_link#"></cfif>
        </cfoutput> 
        <cf_box_elements vertical="1">
            <div class="col col-12 col-md-12 col-sm-12 col-xs-12" type="column" index="1" sort="true">
                <cfset tr_topic =''>
                <div class="form-group" id="item-editor">
                    <label style="display:none!important;"><cf_get_lang dictionary_id='57653.İçerik'></label>
                    <cfmodule
                    template="/fckeditor/fckeditor.cfm"
                    toolbarset="Basic"
                    basepath="/fckeditor/"
                    instancename="work_detail"
                    class="col col-12"
                    valign="top"
                    value=""
                    width="555"
                    height="180">
                    <input type="hidden" name="work_detail" id="work_detail" value="">
                </div>
            </div>
            <div class="col col-6 col-md-6 col-sm-6 col-xs-12" type="column" index="2" sort="true">
                <div class="form-group" id="item-responsable_name">
                    <label> <cf_get_lang dictionary_id='57569.Görevli'>*</label>
                    <div class="input-group">
                        <cfif upd_work.project_emp_id neq 0 and len(upd_work.project_emp_id)>
                            <cfset person="#get_emp_info(upd_work.project_emp_id,0,0)#">
                        <cfelseif upd_work.outsrc_partner_id neq 0 and len(upd_work.outsrc_partner_id)>
                            <cfset person="#get_par_info(upd_work.outsrc_partner_id,0,2,0)#">
                        <cfelse>
                            <cfset person="">
                        </cfif>
                        <cfif len(upd_work.company_id) and len(upd_work.company_partner_id)>
                            <input type="hidden" name="about_company" id="about_company" value="<cfoutput>#get_par_info(upd_work.company_partner_id,0,0,0)#</cfoutput>">
                        <cfelseif not len(upd_work.company_id) and len(upd_work.consumer_id)>
                            <input type="hidden" name="about_company" id="about_company" value="<cfoutput>#get_cons_info(upd_work.company_id,0,0,0)#</cfoutput>">
                        <cfelse>
                            <input type="hidden" name="about_company" id="about_company" value="">
                        </cfif>
                        
                        <input type="hidden" name="task_company_id" id="task_company_id" value="<cfoutput>#upd_work.outsrc_cmp_id#</cfoutput>">
                        <input type="hidden" name="task_partner_id" id="task_partner_id" value="<cfoutput>#upd_work.outsrc_partner_id#</cfoutput>">
                        <input type="hidden" name="project_emp_id" id="project_emp_id" value="<cfoutput>#upd_work.project_emp_id#</cfoutput>">
                        <cfif isdefined("url.tree_category_id")>
                            <cfinput type="text" name="responsable_name" id="responsable_name" value="#person#" >
                        <cfelse>
                            <cfif isdefined("xml_only_employee") and xml_only_employee eq 1>																					
                                <cfinput type="text" name="responsable_name" id="responsable_name" value="#person#"  onFocus="AutoComplete_Create('responsable_name','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','\'3\',0,0','EMPLOYEE_ID','project_emp_id','','3','200','get_company()');" autocomplete="off">
                            <cfelse>
                                <cfinput type="text" name="responsable_name" id="responsable_name" value="#person#"  onFocus="AutoComplete_Create('responsable_name','MEMBER_NAME,MEMBER_PARTNER_NAME2','MEMBER_PARTNER_NAME2,MEMBER_NAME2','get_member_autocomplete','\'1,3\',0,0','COMPANY_ID,PARTNER_ID,EMPLOYEE_ID','task_company_id,task_partner_id,project_emp_id','','3','200','get_company()');" autocomplete="off">
                            </cfif>
                        </cfif>
                        <span class="input-group-addon icon-ellipsis btnPointer" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_list_positions&field_partner=upd_work.task_partner_id&field_comp_id=upd_work.task_company_id&field_emp_id=upd_work.project_emp_id&field_name=upd_work.responsable_name<cfif isdefined("url.tree_category_id")>&tree_category_id=#url.tree_category_id#&select_list=1<cfelse>&select_list=1,2</cfif><cfif isdefined("url.process_date")>&process_date=#url.process_date#</cfif></cfoutput>');"></span>
                    </div>
                </div>
                <div class="form-group" id="item-process_stage">
                    <label> <cf_get_lang dictionary_id="58859.Süreç"> *</label>
                    <cfif isdefined("xml_is_stage_cat") and xml_is_stage_cat eq 1>
                        <div id="stage1" ></div>
                    <cfelse>
                        <cf_workcube_process is_upd='0' is_detail="1" select_value="#upd_work.work_currency_id#" process_cat_width='130'>
                    </cfif>
                </div>
                <div class="form-group" id="item-milestone_work_id">
                    <label>Milestone</label>
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
                <cfif len("upd_work.WORK_FUSEACTION")>
                    <cfquery name="get_woid" datasource="#dsn#">
                        SELECT WRK_OBJECTS_ID FROM WRK_OBJECTS WHERE FULL_FUSEACTION LIKE  <cfqueryparam cfsqltype="cf_sql_varchar" value="#upd_work.WORK_CIRCUIT#.#upd_work.WORK_FUSEACTION#">
                    </cfquery>         
                </cfif>     
                <cfif  (upd_work.WORK_FUSEACTION DOES NOT CONTAIN 'emptypopup')> 
                    <div class="form-group" id="item-work_fuse">
                        <label>Workfuse</label>  
                        <div class="input-group">
                            <input name="work_fuse" type="text" id="work_fuse" value="<cfoutput>#upd_work.WORK_CIRCUIT#.#upd_work.WORK_FUSEACTION#</cfoutput>">
                            <span class="input-group-addon btnPointer icon-link" onclick="<cfif len(workcube_license.implementation_project_domain)>window.open('<cfoutput>#workcube_license.implementation_project_domain#/index.cfm?fuseaction=#upd_work.WORK_CIRCUIT#.#upd_work.WORK_FUSEACTION#</cfoutput>','_blank');<cfelse>window.open('<cfoutput>#request.self#?fuseaction=#upd_work.WORK_CIRCUIT#.#upd_work.WORK_FUSEACTION#</cfoutput>','_blank');</cfif>"></span>
                            <span class="input-group-addon btnPointer catalyst-info" onclick="<cfif len(workcube_license.implementation_project_domain)>window.open('<cfoutput>#workcube_license.implementation_project_domain#/index.cfm?fuseaction=dev.wo&event=upd&fuseact=#upd_work.WORK_CIRCUIT#.#upd_work.WORK_FUSEACTION#&woid=#get_woid.WRK_OBJECTS_ID#&Works</cfoutput>','_blank');<cfelse>window.open('<cfoutput>#request.self#?fuseaction=#upd_work.WORK_CIRCUIT#.#upd_work.WORK_FUSEACTION#</cfoutput>','_blank');</cfif>"></span>
                        </div>
                    </div>
                <cfelse>
                    <div class="form-group" id="item-work_fuse">
                        <label>Workfuse</label>  
                        <div class="input-group">
                            <input name="work_fuse" type="text" id="work_fuse" value="<cfoutput>#upd_work.WORK_CIRCUIT#.#upd_work.WORK_FUSEACTION#</cfoutput>">
                            <span class="input-group-addon btnPointer catalyst-info" onclick="<cfif len(workcube_license.implementation_project_domain)>window.open('<cfoutput>#workcube_license.implementation_project_domain#/index.cfm?fuseaction=dev.wo&event=upd&fuseact=#upd_work.WORK_CIRCUIT#.#upd_work.WORK_FUSEACTION#&woid=#get_woid.WRK_OBJECTS_ID#&Works</cfoutput>','_blank');<cfelse>window.open('<cfoutput>#request.self#?fuseaction=#upd_work.WORK_CIRCUIT#.#upd_work.WORK_FUSEACTION#</cfoutput>','_blank');</cfif>"></span>
                        </div>
                    </div>
                </cfif>
                <div class="form-group" id="item-bilgi_verilecekler">
                    <cfsavecontent variable="info"><label class="bold"><cf_get_lang dictionary_id='58773.Bilgi Verilecekler'></label></cfsavecontent>
                    <!---Bilgi Verilecekler--->
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
            <div class="col col-6 col-md-6 col-sm-6 col-xs-12" type="column" index="3" sort="true">
                <div class="form-group" id="item-estimated_time">
                    <label> <cf_get_lang dictionary_id='38215.Öngörülen Süre'></label>
                    
                        <cfif isdefined('upd_work.estimated_time') and len(upd_work.estimated_time)>
                            <cfset liste=upd_work.estimated_time/60>
                            <cfset saat=listfirst(liste,'.')>
                            <cfset dak=upd_work.estimated_time-saat*60>
                        </cfif>
                        <cfsavecontent variable="message"><cf_get_lang dictionary_id='38136.Tahmini Süre girmelisiniz'>*</cfsavecontent>
                        <cfoutput>                                                   
                            <cfif isdefined('xml_is_work_finishdate') and xml_is_work_finishdate eq 1>
                                <div class="col col-6 col-md-6 col-sm-6 col-xs-12 pl-0"> 
                                    <div class="input-group">
                                        <input type="text" name="estimated_time" id="estimated_time" validate="integer" message="#message#" <cfif isdefined('xml_time_duration_stage_update') and xml_time_duration_stage_update neq 1>value="#saat#"<cfif not ListFind(xml_is_all_estimated,session.ep.position_code,',')>disabled</cfif></cfif> onKeyUp="isNumber(this);"  onBlur="estimated_finishdate(this.value,'hour')" >
                                        <span class="input-group-addon"><cf_get_lang dictionary_id ='57491.Saat'></span>
                                    </div>
                                </div>
                                <div class="col col-6 col-md-6 col-sm-6 col-xs-12 pl-0"> 
                                    <div class="input-group">
                                        <cfsavecontent variable="message"><cf_get_lang dictionary_id='60617.Lütfen 60dan Küçük Bir Değer Giriniz'></cfsavecontent>
                                        <input type="text" name="estimated_time_minute" id="estimated_time_minute" <cfif isdefined('xml_time_duration_stage_update') and xml_time_duration_stage_update neq 1>value="#dak#"<cfif not ListFind(xml_is_all_estimated,session.ep.position_code,',')>disabled</cfif></cfif>  onKeyUp="isNumber(this);" range="0,59" onBlur="estimated_finishdate(this.value,'minute')" message="#message#" >
                                        <span class="input-group-addon"><cf_get_lang dictionary_id='58827.Dk'></span>
                                    </div>
                                </div>
                            <cfelse>
                                <div class="col col-6 col-md-6 col-sm-6 col-xs-12 pl-0"> 
                                    <div class="input-group">
                                        <input type="text" name="estimated_time" id="estimated_time" validate="integer" message="#message#" <cfif isdefined('xml_time_duration_stage_update') and xml_time_duration_stage_update neq 1>value="#saat#"<cfif not ListFind(xml_is_all_estimated,session.ep.position_code,',')>disabled</cfif></cfif> onKeyUp="isNumber(this);" >
                                        <span class="input-group-addon"><cf_get_lang dictionary_id ='57491.Saat'></span>
                                    </div>
                                </div>
                                <div class="col col-6 col-md-6 col-sm-6 col-xs-12 pl-0"> 
                                    <div class="input-group">
                                        <cfsavecontent variable="message"><cf_get_lang dictionary_id='60617.Lütfen 60dan Küçük Bir Değer Giriniz'></cfsavecontent>
                                        <input type="text" name="estimated_time_minute" id="estimated_time_minute" <cfif isdefined('xml_time_duration_stage_update') and xml_time_duration_stage_update neq 1>value="#dak#"<cfif not ListFind(xml_is_all_estimated,session.ep.position_code,',')>disabled</cfif></cfif>  onKeyUp="isNumber(this);" range="0,59" message="#message#">
                                        <span class="input-group-addon"><cf_get_lang dictionary_id='58827.Dk'></span>
                                    </div>
                                </div>
                            </cfif>
                        </cfoutput>
                        <div id="upd_date_div_id" ></div>
                </div>
                <cfif isdefined('upd_work.estimated_time') and len(upd_work.estimated_time)>
                    <cfset liste = upd_work.estimated_time/60>
                    <cfset saat = listfirst(liste,'.')>
                    <cfset dak = upd_work.estimated_time-saat*60>
                </cfif>                
                <div class="form-group" id="item-total_time_hour">
                    <label><cf_get_lang dictionary_id='31491.Gerçekleşen'> - <cf_get_lang dictionary_id='38148.Harcanan Zaman'></label>
                    <div class="col col-6 col-md-6 col-sm-6 col-xs-12 pl-0"> 
                        <div class="input-group">
                            <cfsavecontent variable="message">0-59 <cf_get_lang dictionary_id='38295.Arasi Giriniz'>!</cfsavecontent>
                            <input type="text" name="total_time_hour" id="total_time_hour" value="" onkeyup="isNumber(this);">
                            <span class="input-group-addon"><cf_get_lang dictionary_id='57491.Saat'></span>
                        </div>
                    </div>
                    <div class="col col-6 col-md-6 col-sm-6 col-xs-12 pl-0"> 
                        <div class="input-group">
                            <cfinput type="text" name="total_time_minute" id="total_time_minute" value="" range="0,59" onKeyUp="isNumber(this);" message="#message#">
                            <span class="input-group-addon"><cf_get_lang dictionary_id='58827.Dk'></span>
                        </div>
                    </div>
                </div>                
                <div class="form-group" id="item-terminate_date">
                    <label><cf_get_lang dictionary_id='38146.Termin'></label>
                    <div class="col col-6 col-md-6 col-sm-6 col-xs-12 pl-0">        
                        <div class="input-group">
                            <cfinput name="terminate_date" id="terminate_date" validate="#validate_style#" maxlength="10" type="text" value="#dateformat(termin_date,dateformat_style)#" >
                            <span class="input-group-addon"><cf_wrk_date_image date_field="terminate_date" c_position="Tl"></span>                           
                        </div> 
                    </div>
                        <div class="col col-6 col-md-6 col-sm-6 col-xs-12 pl-0"> 
                        <cfoutput>
                            <cf_wrkTimeFormat name="terminate_hour" value="#termin_hour#">                                          
                        </cfoutput>
                    </div>
                </div>                
                <div class="form-group" id="item-work_status">
                    <div class="col col-6 col-md-6 col-sm-6 col-xs-12 pl-0" id="item-to_complate">
                        <label><cf_get_lang dictionary_id='38307.Tamamlanma'> %</label>
                        <cfsavecontent variable="message"><cf_get_lang dictionary_id='38275.0-100 arası tam sayı değeri giriniz'></cfsavecontent>
                        <cfinput type="text" name="to_complate" id="to_complate" value="#upd_work.to_complete#"  onkeyup="complate_control(); return(FormatCurrency(this,event,0));"  maxlength="3" placeholder="#message#" min="0" max="100">
                    </div>
                    <div class="col col-3 col-md-3 col-sm-3 col-xs-12">
                        <label><cf_get_lang dictionary_id='57493.Aktif'></label>
                        <input type="checkbox" name="work_status" id="work_status" <cfif upd_work.work_status eq 1>checked="checked"</cfif> />
                    </div>
                    <div class="col col-3 col-md-3 col-sm-3 col-xs-12">
                        <label><cf_get_lang dictionary_id="57475.Mail Gönder"></label>
                        <input type="checkbox" name="is_mail" id="is_mail" value="1"<cfif isdefined("xml_is_send_mail") and xml_is_send_mail eq 1>checked="checked"</cfif>>
                    </div>
                </div> 
            </div>
        </cf_box_elements>
        <div class="ui-form-list-btn">            
            <div class="col col-6">
                <cf_record_info 
                    query_name="upd_work" 
                    record_emp="record_author" 
                    update_emp="update_author" 
                    is_partner="1">
            </div>
            <div class="col col-6">
                <div class="form-group">
                    <label id="work_upd" style="display:none!important;"></label>
                    <cfset is_only_show_page = 0>
                    <cf_workcube_buttons update_status="0" extraButton="1" extraButtonText="#getLang("","Kaydet",57461)#" extraAlert="#getLang("","Kaydetmek İstediğinizden Emin Misiniz?",57535)#" extraFunction='kontrol()'>
                </div>
            </div>
        </div>
</cfform>

<script>
    <cfif isdefined("xml_is_stage_cat") and xml_is_stage_cat eq 1>
		tmplt(2);
	</cfif>
    function tmplt(type)
	{
		if(document.getElementById('pro_work_cat') != undefined)
		{
			var pwc = document.getElementById('pro_work_cat').value;
			if(type == 2)//kategoriye bagli süreç gelecek
			{
               
				if(pwc!='')
				{
					goster(stage1);
					AjaxPageLoad('<cfoutput>#request.self#</cfoutput>?fuseaction=project.popup_list_stage&value=<cfoutput>#upd_work.work_currency_id#</cfoutput>&type='+type+'&category_id='+pwc,'stage1');
				}
			}
			
		}
	}
    <cfif isdefined('xml_time_duration_stage_update') and  xml_time_duration_stage_update neq 1>
    $(document).click(function (e) {
        if ($("#"+e.target.id).prop('disabled') && e.target.id=="estimated_time"){
            $('.ui-cfmodal__alert .required_list li').remove();
            $('.ui-cfmodal__alert .required_list').append('<li><cfoutput>#getLang("","Öngörülen Süre Güncelleyemezsiniz.Yetkili Değilsiniz.",65563)#</cfoutput>!</li>');
            $('.ui-cfmodal__alert').fadeIn();
        }
        }); 
    </cfif>
   
    var k=0;
    function complate_control()
    {
        gelen = document.getElementById('to_complate').value;    
        if(gelen>100){
            $('.ui-cfmodal__alert .required_list li').remove();
            $('.ui-cfmodal__alert .required_list').append('<li><cfoutput>#getLang("","Tamamlanma % si 0-100 arasında olmalıdır!",38276)#</cfoutput></li>');
            $('.ui-cfmodal__alert').fadeIn();            
        }else if (gelen<0) {
            $('.ui-cfmodal__alert .required_list li').remove();
            $('.ui-cfmodal__alert .required_list').append('<li><cfoutput>#getLang("","Tamamlanma % si 0-100 arasında olmalıdır!",38276)#</cfoutput></li>');
            $('.ui-cfmodal__alert').fadeIn();            
            return false;
        }
    }   
   
    function kontrol()

    {
        if ((upd_work.estimated_time.value == '') || (upd_work.estimated_time_minute.value == '')){
            $('.ui-cfmodal__alert .required_list li').remove();
                $('.ui-cfmodal__alert .required_list').append('<li><cfoutput>#getLang("","Tahmini Süre girmelisiniz",38136)#</cfoutput>!</li>');
                $('.ui-cfmodal__alert').fadeIn();
                return false;
            }
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
                    $('.ui-cfmodal__alert .required_list').append('<li><cfoutput>#getLang("","Termin tarihi geri tarihli olamaz",65924)#</cfoutput>!</li>');
                    $('.ui-cfmodal__alert').fadeIn();
                    return false;
                    
                
                }
            }
        </cfif>
        // data.append('CKEDITOR_'+CKEDITOR.instances['work_detail'].name,CKEDITOR.instances[CKEDITOR.instances['work_detail'].name].getData());
        document.getElementById('work_detail').value = CKEDITOR.instances.work_detail.getData();		
        gelen = document.getElementById('to_complate').value;    
        if(gelen>100){
            $('.ui-cfmodal__alert .required_list li').remove();
            $('.ui-cfmodal__alert .required_list').append('<li><cfoutput>#getLang("","Tamamlanma % si 0-100 arasında olmalıdır!",38276)#</cfoutput></li>');
            $('.ui-cfmodal__alert').fadeIn();
            return false;
        }else if (gelen<0) {
            $('.ui-cfmodal__alert .required_list li').remove();
            $('.ui-cfmodal__alert .required_list').append('<li><cfoutput>#getLang("","Tamamlanma % si 0-100 arasında olmalıdır!",38276)#</cfoutput></li>');
            $('.ui-cfmodal__alert').fadeIn();           
        }else if (gelen == ''){
             $('.ui-cfmodal__alert .required_list li').remove();
             $('.ui-cfmodal__alert .required_list').append('<li><cfoutput>#getLang("","Tamamlanma % si 0-100 arasında olmalıdır!",38276)#</cfoutput></li>');
             $('.ui-cfmodal__alert').fadeIn();           
            return false;
        }
        if ((document.getElementById('project_emp_id').value== ""  || document.getElementById('responsable_name').value== "")  && (document.getElementById('task_partner_id').value== "" || document.getElementById('responsable_name').value == ""))
        {
            alert ("<cfoutput>#getLang('','Görevli Secmelisiniz',38201)#</cfoutput>!");
            return false;
        }		
        <cfif isdefined("xml_time_required") and xml_time_required eq 1>
            if (document.getElementById('total_time_minute').value== "" || document.getElementById('total_time_hour').value== "" )
            {
                $('.ui-cfmodal__alert .required_list li').remove();
                $('.ui-cfmodal__alert .required_list').append('<li><cfoutput>#getLang("","Gerçekleşen",31491)#</cfoutput> - <cfoutput>#getLang("","Harcanan Zaman",38148)#</cfoutput><cfoutput>#getLang("","Giriniz",61824)#</cfoutput>!</li>');
                $('.ui-cfmodal__alert').fadeIn();
                return false;
               
               
            }	
        </cfif>	
       
  
        //Gunluk 24 saat harcama kontrolu yapiliyor
        <cfif isdefined('x_timecost_limited') and x_timecost_limited eq 0>
        if((document.getElementById("total_time_hour") != undefined && document.getElementById("total_time_hour").value != 0) || (document.getElementById("total_time_minute") != undefined && document.getElementById("total_time_minute").value != 0))
        {
            if(document.getElementById("total_time_hour") == undefined || document.getElementById("total_time_hour").value == "") document.getElementById("total_time_hour").value = 0;
            if(document.getElementById("total_time_minute") == undefined || document.getElementById("total_time_minute").value == "") document.getElementById("total_time_minute").value = 0;
            
            var total_minute = (parseInt(document.getElementById("total_time_hour").value)*60)+parseInt(document.getElementById("total_time_minute").value);
            var total_hour = total_minute/60;
            var listParam = <cfoutput>#session.ep.userid# + "*" + #dateFormat(date_add('d',-1,now()),dateformat_style)# + "*" + #dateFormat(now(),dateformat_style)#</cfoutput>;
            var get_relation_time_cost = wrk_safe_query("get_relation_time_cost","dsn",0,listParam);
            if(get_relation_time_cost.recordcount && get_relation_time_cost.TOTAL_TIME != "")
                var total_control = (get_relation_time_cost.TOTAL_TIME/60) + total_hour;
            else
                var total_control = total_hour;
            if(total_control > 24)
            {
                $('.ui-cfmodal__alert .required_list li').remove();
                $('.ui-cfmodal__alert .required_list').append('<li><cfoutput>#getLang("","Bir Gün İçinde 24 Saatten Fazla Zaman Harcaması Girilemez",38446)#</cfoutput>!</li>');
                $('.ui-cfmodal__alert').fadeIn();
                return false;
              
            }
        }
        </cfif>
        <cfif isdefined("xml_project_required") and xml_project_required eq 1>
            if(document.getElementById('project_id').value == "" )
            {
                $('.ui-cfmodal__alert .required_list li').remove();
                $('.ui-cfmodal__alert .required_list').append('<li><cfoutput>#getLang("","Zorunlu Alan",58194)#</cfoutput> : <cfoutput>#getLang("","Proje",57416)#</cfoutput>!</li>');
                $('.ui-cfmodal__alert').fadeIn();
                return false;
            }
        </cfif>
            AjaxFormSubmit('upd_work','work_upd',1,'','','','','true');
    }
    function estimated_finishdate(add_time,type)
    {
        if(document.getElementById('estimated_time_minute').value >= 60)
        {
            $('.ui-cfmodal__alert .required_list li').remove();
            $('.ui-cfmodal__alert .required_list').append("<li><cfoutput>#getLang("","Lütfen 60 dan Küçük Bir Değer Giriniz",60617)#</cfoutput>!</li>");
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
</script>