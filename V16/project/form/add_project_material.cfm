<cfscript>session_basket_kur_ekle(process_type:0);</cfscript>
<cfparam name="attributes.company_id" default="">
<cfparam name="attributes.comp_name" default="">
<cfparam name="attributes.consumer_id" default="">
<cfparam name="attributes.partner_name" default="">
<cfparam name="attributes.project_id" default="">
<cfparam name="attributes.work_id" default="">
<cfparam name="attributes.material_stage" default="">
<cfparam name="attributes.from_work" default="0">
<cf_papers paper_type="pro_material">
<cfif isdefined("paper_full") and isdefined("paper_number")>
	<cfset system_paper_no = paper_full>
<cfelse>
	<cfset system_paper_no = "">
</cfif>
<cfquery name="GET_PRO_PROJECTS" datasource="#DSN#">
	SELECT COMPANY_ID, CONSUMER_ID, PARTNER_ID FROM PRO_PROJECTS <cfif isdefined("attributes.project_id") and len(attributes.project_id)>WHERE PROJECT_ID = #attributes.project_id#</cfif>
</cfquery>
<cfquery name="get_process_type" datasource="#DSN#">
	SELECT
		PTR.STAGE,
		PTR.PROCESS_ROW_ID 
	FROM
		PROCESS_TYPE_ROWS PTR,
		PROCESS_TYPE_OUR_COMPANY PTO,
		PROCESS_TYPE PT
	WHERE
		PT.IS_ACTIVE = 1 AND
		PT.PROCESS_ID = PTR.PROCESS_ID AND
		PT.PROCESS_ID = PTO.PROCESS_ID AND
		PTO.OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#"> AND
		PT.FACTION LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#listfirst(attributes.fuseaction,'.')#.popup_add_project_material%">
	ORDER BY
		PTR.LINE_NUMBER
</cfquery>
<cfif fuseaction contains 'project.project_material'>
<cf_catalystHeader>
</cfif>
<cf_box title="#getLang('','Proje Malzeme Planı','38284')#" popup_box="#iif(isdefined("attributes.draggable"),1,0)#">
    <div id="basket_main_div">
        <cfform name="form_basket" id="form_basket" method="post">
            <cf_basket_form id="pro_material">
                <cfoutput>
                    <input type="hidden" name="form_action_address" id="form_action_address" value="#listgetat(attributes.fuseaction,1,'.')#.emptypopup_add_project_material">
                    <input type="hidden" name="search_process_date" id="search_process_date" value="action_date">
                    <input type="hidden" name="basket_due_value" id="basket_due_value" value="">
                    <input type="hidden" name="from_work" id="from_work" value="#attributes.from_work#" />
                </cfoutput>
                <cf_box_elements id="pro_material">
                    <cfoutput>
                        <div class="col col-4 col-md-4 col-sm-6 col-xs-12" type="column" sort="true" index="1">
                            <div class="form-group" id="item-no">
                                <label class="col col-3 col-xs-2"><cf_get_lang dictionary_id='57487.No'></label>
                                <div class="col col-9 col-xs-10">
                                    <cfif isDefined('system_paper_no')>
                                        <cfinput type="text" maxlength="50" name="pro_number" id="pro_number" value="#system_paper_no#" required="Yes" message="">
                                    <cfelse>
                                        <cfinput type="text" maxlength="50" name="pro_number" id="pro_number" value="" required="Yes" message="">
                                    </cfif>
                                </div>
                            </div>
                            <div class="form-group" id="item-action_date">
                                <label class="col col-3 col-xs-2"><cf_get_lang dictionary_id='57742.Tarih'></label>
                                <div class="col col-9 col-xs-10">
                                    <div class="input-group">
                                        <cfinput type="text" name="action_date" required="Yes" message="" value="#dateformat(now(),dateformat_style)#" validate="#validate_style#" maxlength="10" passThrough="onblur=""change_money_info('form_basket','action_date');""">
                                        <span class="input-group-addon btnPointer"><cf_wrk_date_image date_field="action_date" call_function="change_money_info"></span>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group" id="item-company_id">
                                <label class="col col-3 col-xs-2"><cf_get_lang dictionary_id='57574.Şirket'> *</label>
                                <div class="col col-9 col-xs-10">
                                    <div class="input-group">
                                        <input type="hidden" name="company_id" id="company_id" value="<cfif len(GET_PRO_PROJECTS.COMPANY_ID)>#GET_PRO_PROJECTS.COMPANY_ID#</cfif>">
                                        <input type="text" name="comp_name" id="comp_name"readonly value="<cfif len(GET_PRO_PROJECTS.COMPANY_ID)>#GET_PAR_INFO(GET_PRO_PROJECTS.PARTNER_ID,0,1,0)#</cfif>">
                                        <span class="input-group-addon btnPointer icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_pars&field_comp_id=form_basket.company_id&field_comp_name=form_basket.comp_name&field_name=form_basket.partner_name&field_partner=form_basket.partner_id&field_consumer=form_basket.consumer_id&select_list=2,3')"></span>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group" id="item-partner_id">
                                <label class="col col-3 col-xs-2"><cf_get_lang dictionary_id='57578.Yetkili'> *</label>
                                <div class="col col-9 col-xs-10">
                                    <input type="hidden" name="partner_id" id="partner_id" value="<cfif len(GET_PRO_PROJECTS.PARTNER_ID)>#GET_PRO_PROJECTS.PARTNER_ID#</cfif>">
                                    <input type="hidden" name="consumer_id" id="consumer_id" value="<cfif len(GET_PRO_PROJECTS.CONSUMER_ID)>#GET_PRO_PROJECTS.CONSUMER_ID#</cfif>">
                                    <input type="text" name="partner_name" id="partner_name" value="<cfif len(GET_PRO_PROJECTS.PARTNER_ID)>#GET_PAR_INFO(GET_PRO_PROJECTS.PARTNER_ID,0,-1,0)#<cfelseif len(GET_PRO_PROJECTS.CONSUMER_ID)>#GET_CONS_INFO(GET_PRO_PROJECTS.CONSUMER_ID,0,0)#</cfif>" readonly>
                                </div>
                            </div>
                            <div class="form-group" id="item-process">
                                <label class="col col-3 col-xs-2"><cf_get_lang dictionary_id='58859.Süreç'></label>
                                <div class="col col-9 col-xs-10"><cf_workcube_process is_upd='0' process_cat_width='150' is_detail='0'></div>
                            </div>
                        </div>
                        <div class="col col-4 col-md-4 col-sm-6 col-xs-12" type="column" sort="true" index="2">
                            <div class="form-group" id="item-budget_id">
                                <label class="col col-3 col-xs-2"><cf_get_lang dictionary_id='57559.Bütçe'></label>
                                <div class="col col-9 col-xs-10">
                                    <div class="input-group">
                                        <cfif isdefined("attributes.public_id")>
                                            <input type="hidden" name="public_id" id="public_id" value="<cfoutput>#attributes.public_id#</cfoutput>">
                                        </cfif>
                                        <input type="hidden" name="budget_id" id="budget_id" value="">
                                        <input type="text" name="budget_name" id="budget_name" readonly="" value="">
                                        <span class="input-group-addon btnPointer icon-ellipsis" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_budget&field_id=form_basket.budget_id&field_name=form_basket.budget_name&select_list=2');"></span>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group" id="item-planner_emp_id">
                                <label class="col col-3 col-xs-2"><cf_get_lang dictionary_id='38281.Planlayan'></label>
                                <div class="col col-9 col-xs-10">
                                    <div class="input-group">
                                        <input type="hidden" name="planner_emp_id" id="planner_emp_id" value="#session.ep.userid#">
                                        <cfinput type="text" name="planner_emp_name" value="#session.ep.name# #session.ep.surname#" passThrough="readonly=yes">
                                        <span class="input-group-addon btnPointer icon-ellipsis" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_positions&field_emp_id=form_basket.planner_emp_id&field_name=form_basket.planner_emp_name&select_list=1');"></span>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group" id="item-work_id">
                                <label class="col col-3 col-xs-2"><cf_get_lang dictionary_id='38213.İş'></label>
                                <div class="col col-9 col-xs-10">
                                    <div class="input-group">
                                        <cfif len(attributes.work_id)>
                                            <cfquery name="GET_WORK" datasource="#dsn#">
                                                SELECT WORK_HEAD FROM PRO_WORKS WHERE WORK_ID = #attributes.work_id#
                                            </cfquery>
                                        </cfif>
                                        <input type="hidden" name="work_id" id="work_id" value="#attributes.work_id#">
                                        <input type="text" name="work_head" id="work_head" value="<cfif len(attributes.work_id)>#GET_WORK.WORK_HEAD#</cfif>">
                                        <span class="input-group-addon btnPointer icon-ellipsis" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_add_work&field_id=form_basket.work_id&field_name=form_basket.work_head');"></span>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group" id="item-Proje">
                                <label class="col col-3 col-xs-2"><cf_get_lang dictionary_id='57416.Proje'></label>
                                <div class="col col-9 col-xs-10">
                                    <div class="input-group">
                                        <input type="hidden" name="project_id" id="project_id" value="<cfif Len(attributes.project_id)>#attributes.project_id#</cfif>">
                                        <input type="text" name="project_head" id="project_head" value="<cfif Len(attributes.project_id)>#get_project_name(attributes.project_id)#</cfif>" onFocus="AutoComplete_Create('project_head','PROJECT_HEAD','PROJECT_HEAD','get_project','','PROJECT_ID','project_id','form_basket','3','135')" autocomplete="off">
                                        <span class="input-group-addon btnPointer icon-ellipsis" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_projects&project_id=form_basket.project_id&project_head=form_basket.project_head');"></span>
                                        <span class="input-group-addon btnPointer bold" onclick="if(document.getElementById('project_id').value!='')windowopen('#request.self#?fuseaction=project.popup_list_project_actions&from_paper=ORDERS&id='+document.getElementById('project_id').value+'','horizantal');else alert('Proje Seçiniz');">?</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="col col-4 col-md-4 col-sm-6 col-xs-12" type="column" sort="true" index="3">
                            <div class="form-group" id="item-pro_material_detail">
                                <label class="col col-3 col-xs-2"><cf_get_lang dictionary_id='57629.Açıklama'></label>
                                <div class="col col-9 col-xs-10"><textarea name="pro_material_detail" id="pro_material_detail" style="width:150px;height:75px;"></textarea></div>
                            </div>
                        </div>
                    </cfoutput>
                </cf_box_elements>
                <cf_box_footer>
                   <cf_workcube_buttons is_upd='0' 
                  
                    add_function='kontrol()'> 
                   
                </cf_box_footer>
            <cf_basket_form>
            <cfset attributes.basket_id = 50>
            <cfif  not isdefined('url.is_copy')><!--- Eğer güncelleme sayfasından kopyalama yapılıyorsa basketteki işleri alması için --->
                <cfset attributes.form_add = 1>
            </cfif>
            <cfinclude template="../../objects/display/basket.cfm">
        </cfform>
    </div>
</cf_box>

<script type="text/javascript">
function kontrol()
{
	if(form_basket.company_id.value == "" )
	{ 
		alert ("<cf_get_lang dictionary_id='38282.Cari Hesabı Seçmelisiniz !'>");
		return false;
	}
    var dsn = '<cfoutput>#dsn#</cfoutput>';
   if(!paper_control(form_basket.pro_number,'PRO_MATERIAL',1,'','','','','',dsn)) return false;
	return (process_cat_control() && saveForm());
   
}	
</script>
