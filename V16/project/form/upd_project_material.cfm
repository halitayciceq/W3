<cfscript>session_basket_kur_ekle(action_id=url.upd_id,table_type_id:14,process_type:1);</cfscript> 
<cfparam name="attributes.company_id" default="">
<cfparam name="attributes.comp_name" default="">
<cfparam name="attributes.consumer_id" default="">
<cfparam name="attributes.partner_name" default="">
<cfparam name="attributes.from_work" default="0">
<cfparam name="attributes.modal_id" default="">
<cfquery name="GET_PRO_M" datasource="#dsn#">
	SELECT * FROM PRO_MATERIAL WHERE PRO_MATERIAL_ID=#url.upd_id#
</cfquery>
<cfif not get_pro_m.recordcount>
	<br/><font class="txtbold"><cf_get_lang dictionary_id='58943.Böyle Bir Kayıt Bulunmamaktadır!'></font>
	<cfexit method="exittemplate">
</cfif>

<cfif fuseaction contains 'project.project_material'>
    <cf_catalystHeader>
</cfif>
    <div class="col col-12 col-xs-12">

    <cf_box title="#getLang('','','38284')#"  popup_box="#iif(isdefined("attributes.draggable"),1,0)#">
        <div id="basket_main_div">
        <cfform name="form_basket" method="post" id="form_basket">
            <cf_basket_form id="pro_material">
                <cfoutput>
                    <input type="hidden" name="form_action_address" id="form_action_address" value="#listgetat(attributes.fuseaction,1,'.')#.emptypopup_upd_project_material">
                    <input type="hidden" name="search_process_date" id="search_process_date" value="action_date">
                    <input type="hidden" name="upd_id" id="upd_id" value="#url.upd_id#">
                    <input type="hidden" name="del_pro_material" id="del_pro_material" value="0">
                    <input type="hidden" name="basket_due_value" id="basket_due_value" value="">
                    <input type="hidden" name="from_work" id="from_work" value="#attributes.from_work#" />
                    <cfinput type="hidden" name="modal_id" id="modal_id" value="#attributes.modal_id#">	
                </cfoutput>
                <cf_box_elements>
                    <cfoutput>
                    <div class="col col-4 col-md-4 col-sm-6 col-xs-12" type="column" sort="true" index="1">
                        <div class="form-group" id="item-no">
                            <label class="col col-3 col-xs-12"><cf_get_lang dictionary_id='57487.No'></label>
                            <div class="col col-9 col-xs-12">
                                <cfinput type="text" maxlength="50" name="pro_number" id="pro_number" value="#get_pro_m.pro_material_no#" required="Yes" message="" >
                            </div>
                        </div>
                        <div class="form-group" id="item-action_date">
                            <label class="col col-3 col-xs-12"><cf_get_lang dictionary_id='57742.Tarih'></label>
                            <div class="col col-9 col-xs-12">
                                <div class="input-group">
                                    <cfinput type="text" name="action_date"  required="Yes" message="" value="#dateformat(get_pro_m.action_date,dateformat_style)#" validate="#validate_style#" maxlength="10">
                                    <span class="input-group-addon btnPointer"><cf_wrk_date_image date_field="action_date"></span>
                                       
                                </div>
                            </div>
                        </div>
                        <div class="form-group" id="item-company_id">
                            <label class="col col-3 col-xs-12"><cf_get_lang dictionary_id='57574.Şirket'> *</label>
                            <div class="col col-9 col-xs-12">
                                <div class="input-group">
                                    <input type="hidden" name="company_id" id="company_id" value="#get_pro_m.company_id#">
                                    <input type="text" name="comp_name" id="comp_name" readonly value="<cfif len(get_pro_m.company_id)>#get_par_info(get_pro_m.company_id,1,0,0)#</cfif>" >
                                    <span class="input-group-addon btnPointer icon-ellipsis" onClick="windowopen('#request.self#?fuseaction=objects.popup_list_pars&field_comp_id=form_basket.company_id&field_comp_name=form_basket.comp_name&field_name=form_basket.partner_name&field_partner=form_basket.partner_id&field_consumer=form_basket.consumer_id&select_list=2,3','list')"></span>
                                </div>
                            </div>
                        </div>
                        <div class="form-group" id="item-partner_id">
                            <label class="col col-3 col-xs-12"><cf_get_lang dictionary_id='57578.Yetkili'> *</label>
                            <div class="col col-9 col-xs-12">
                                <input type="hidden" name="partner_id" id="partner_id" value="#get_pro_m.partner_id#">
                                <input type="hidden" name="consumer_id" id="consumer_id" value="#get_pro_m.consumer_id#">
                                <cfif len(get_pro_m.partner_id) and  get_pro_m.partner_id neq 0>
                                    <input type="text" name="partner_name" id="partner_name" value="#get_par_info(get_pro_m.partner_id,0,-1,0)#"  disabled>
                                <cfelse>
                                    <input type="text" name="partner_name" id="partner_name" value="#get_cons_info(get_pro_m.consumer_id,0,0)#"  disabled>
                                </cfif>
                            </div>
                        </div>
                        <div class="form-group" id="item-process">
                            <label class="col col-3 col-xs-12"><cf_get_lang dictionary_id='58859.Süreç'></label>
                            <div class="col col-9 col-xs-12"><cf_workcube_process is_upd='0' select_value='#get_pro_m.material_stage#' process_cat_width='150' is_detail='1'></div>
                        </div>
                    </div>
                    <div class="col col-4 col-md-4 col-sm-6 col-xs-12" type="column" sort="true" index="2">
                        <div class="form-group" id="item-budget_id">
                            <label class="col col-3 col-xs-12"><cf_get_lang dictionary_id='57559.Bütçe'></label>
                            <div class="col col-9 col-xs-12">
                                <div class="input-group">
                                    <cfif len(get_pro_m.budget_id)>
                                        <cfquery name="GET_BUDGET" datasource="#dsn#">
                                            SELECT BUDGET_NAME FROM BUDGET WHERE BUDGET_ID=#get_pro_m.budget_id#
                                        </cfquery>
                                    </cfif>
                                    <input type="hidden" name="budget_id" id="budget_id" value="#get_pro_m.budget_id#">
                                    <input type="text" name="budget_name" id="budget_name" readonly  value="<cfif len(get_pro_m.budget_id)>#GET_BUDGET.BUDGET_NAME#</cfif>">
                                    <span class="input-group-addon btnPointer icon-ellipsis" onclick="windowopen('#request.self#?fuseaction=objects.popup_list_budget&field_id=form_basket.budget_id&field_name=form_basket.budget_name&select_list=2','list');"></span>
                                </div>
                            </div>
                        </div>
                        <div class="form-group" id="item-planner_emp_id">
                            <label class="col col-3 col-xs-12"><cf_get_lang dictionary_id='38281.Planlayan'></label>
                            <div class="col col-9 col-xs-12">
                                <div class="input-group">
                                    <input type="hidden" name="planner_emp_id" id="planner_emp_id"  value="#get_pro_m.planner_emp_id#">
                                    <input type="text" name="planner_emp_name" id="planner_emp_name" value="<cfif len(get_pro_m.planner_emp_id)>#get_emp_info(get_pro_m.planner_emp_id,0,0)#</cfif>" >
                                    <span class="input-group-addon btnPointer icon-ellipsis" onclick="windowopen('#request.self#?fuseaction=objects.popup_list_positions&field_emp_id=form_basket.planner_emp_id&field_name=form_basket.planner_emp_name&select_list=1','list');"></span>
                                </div>
                            </div>
                        </div>
                        <div class="form-group" id="item-work_id">
                            <label class="col col-3 col-xs-12"><cf_get_lang dictionary_id='38213.İş'></label>
                            <div class="col col-9 col-xs-12">
                                <div class="input-group">
                                    <cfif len(get_pro_m.work_id)>
                                        <cfquery name="GET_WORK" datasource="#dsn#">
                                            SELECT WORK_HEAD FROM PRO_WORKS WHERE WORK_ID = #get_pro_m.work_id#
                                        </cfquery>
                                    </cfif>
                                    <input type="hidden" name="work_id" id="work_id" value="#get_pro_m.work_id#">
                                    <input type="text" name="work_head" id="work_head"  value="<cfif len(get_pro_m.work_id)>#GET_WORK.WORK_HEAD#</cfif>">
                                    <span class="input-group-addon btnPointer icon-ellipsis" onclick="windowopen('#request.self#?fuseaction=objects.popup_add_work&field_id=form_basket.work_id&field_name=form_basket.work_head','list');"></span>
                                </div>
                            </div>
                        </div>
                        <div class="form-group" id="item-Proje">
                            <label class="col col-3 col-xs-12"><cf_get_lang dictionary_id='57416.Proje'></label>
                            <div class="col col-9 col-xs-12">
                                <div class="input-group">
                                    <input type="hidden" name="project_id" id="project_id" value="<cfif Len(get_pro_m.project_id)>#get_pro_m.project_id#</cfif>">
                                    <input type="text" name="project_head" id="project_head" value="<cfif Len(get_pro_m.project_id)>#get_project_name(get_pro_m.project_id)#</cfif>"  onFocus="AutoComplete_Create('project_head','PROJECT_HEAD','PROJECT_HEAD','get_project','','PROJECT_ID','project_id','form_basket','3','135')" autocomplete="off">
                                    <span class="input-group-addon btnPointer icon-ellipsis" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_projects&project_id=form_basket.project_id&project_head=form_basket.project_head');"></span>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col col-4 col-md-4 col-sm-6 col-xs-12" type="column" sort="true" index="3">
                        <div class="form-group" id="item-pro_material_detail">
                            <label class="col col-3 col-xs-12"><cf_get_lang dictionary_id='57629.Açıklama'></label>
                            <div class="col col-9 col-xs-12"><textarea name="pro_material_detail" id="pro_material_detail" style="width:150px;height:75px;">#get_pro_m.detail#</textarea></div>
                        </div>
                    </div>
                    </cfoutput>
                </cf_box_elements>
                <cfquery name="GET_PAPER_RELATION" datasource="#DSN#">
                    SELECT PAPER_ID FROM PAPER_RELATION WHERE RELATED_PAPER_TABLE = 'PRO_MATERIAL' AND RELATED_PAPER_TYPE_ID = 2 AND RELATED_PAPER_ID = #url.upd_id#
                </cfquery>
                
                 
                <cf_box_footer>
                    <div class="col col-6"><cf_record_info query_name="get_pro_m"></div>
                    <div class="col col-6">
                        <cfif not get_paper_relation.recordcount>
                            <cf_workcube_buttons is_upd='1' add_function='kontrol()'>
                        <cfelse>
                            <cf_workcube_buttons is_upd='1' is_delete="false" add_function='kontrol()'>
                        </cfif>	
                    </div>
                </cf_box_footer>
                        
            
            <cfset attributes.basket_id = 50>
            <cfinclude template="../../objects/display/basket.cfm">
        </cfform>
    </div>
    </cf_box>

</div>
<script type="text/javascript">
function kontrol()
{	
	if(document.form_basket.company_id.value == "" && document.form_basket.consumer_id.value == "")
	{ 
		alert ("<cf_get_lang dictionary_id='57471.Eksik Veri'> : <cf_get_lang dictionary_id='57519.Cari Hesap'>");
		return false;
	}
    if(form_basket.pro_number != "")
		{
            if(!paper_control(form_basket.pro_number,'PRO_MATERIAL','1',<cfoutput>'#url.upd_id#','#get_pro_m.pro_material_no#'</cfoutput>,'','','','<cfoutput>#dsn#</cfoutput>')) return false;
		}
	return (process_cat_control() && saveForm());
}
function kontrol2()
{	
    location.href = document.referrer;
	return true;
}
</script>
