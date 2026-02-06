<!--- 
    Author: Uğur Hamurpet
    Date:   06/10/2020
    Desc:   Kaynak kullanımı gantt chart dhtmlx kütüphanesi kullanılarak yeniden tasarlanmıştır.
--->

<cf_xml_page_edit>

<cfparam name="attributes.is_form_submitted" default="0">
<cfparam name="attributes.view_period" default="0">
<cfparam name="attributes.partner_id" default="">
<cfparam name="attributes.employee_id" default="">
<cfparam name="attributes.employee" default="">
<cfparam name="attributes.start_date" default="#dateadd('m',-1,now())#">
<cfparam name="attributes.finish_date" default="#now()#">
<cfparam name="attributes.option_list" default="">
<cfparam name="attributes.status" default="">
<cfparam name="attributes.view_type" default="">
<cfparam name="attributes.employee_type" default="">
<cfparam name="attributes.branch_id" default="">
<cfparam name="attributes.department_id" default="">
<cfparam name="attributes.project_id" default="">
<cfparam name="attributes.project_head" default="">
<cfparam name="attributes.company_cat_id" default="">

<cfparam name="attributes.page" default="1">
<cfparam name="attributes.maxrows" default="#session.ep.maxrows#">
<cfparam name="attributes.recordcount" default="0">
<cfparam name="attributes.totalrecords" default="0">
<cfparam name="attributes.startrow"  default="#((attributes.page-1)*attributes.maxrows)+1#">

<cfif attributes.is_form_submitted eq 0 and len(attributes.project_id)>
    <cfquery name="get_project" datasource="#dsn#">
        SELECT PROJECT_HEAD,PROJECT_ID,TARGET_START,TARGET_FINISH, PROJECT_DETAIL FROM PRO_PROJECTS WHERE PROJECT_ID = #url.project_id#
    </cfquery>
    <cfif get_project.recordcount>
        <cfparam name="attributes.start_date" default="#dateformat(get_project.target_start,dateformat_style)#">
        <cfparam name="attributes.finish_date" default="#dateformat(get_project.target_finish,dateformat_style)#">
        <cfparam name="attributes.project_id" default="#get_project.project_id#">
        <cfparam name="attributes.project_head" default="#get_project.project_head#">
        <cfparam name="attributes.project_detail" default="#get_project.project_detail#">
    </cfif>
</cfif>

<cfset employee_work_graph = createObject("component", "V16.project.cfc.employee_work_graph") />
<cfset getCompanyCat = employee_work_graph.getCompanyCat( company_id: session.ep.company_id ) />

<cfset get_department = CreateObject("component","cfc/get_department") />
<cfset departments = get_department.getComponentFunction( len( attributes.branch_id ) ? attributes.branch_id : '' ) />
<cfset branches = get_department.getComponentFunction1() />

<cfif attributes.is_form_submitted>

    <cf_date tarih = "attributes.start_date">
    <cf_date tarih = "attributes.finish_date">

    <cfset getTaskList = employee_work_graph.getList(
        company_id: session.ep.company_id,
        project_id: attributes.project_id,
        employee_id: attributes.employee_id,
        partner_id: attributes.partner_id,
        department_id: attributes.department_id,
        branch_id: attributes.branch_id,
        startdate: attributes.start_date,
        finishdate: attributes.finish_date,
        get_with_agenda: attributes.option_list eq 1 ? 1 : 0,
        type: attributes.employee_type,
        company_cat_id: attributes.company_cat_id,
        limitation_emp_id: "",
        status: attributes.status,
        startrow: attributes.startrow,
        maxrows: attributes.maxrows
    ) />
    <cfset attributes.totalrecords = arrayLen(getTaskList) ? getTaskList[1]["queryCount"] : 0 />
    
    <cfset attributes.recordcount = arrayLen(getTaskList) ? arrayLen(getTaskList) + getTaskList[1]["recordCount"]  : 0 />

</cfif>

<script src="JS/gantt_chart/dhtmlxgantt.js" type="text/javascript" charset="utf-8"></script>
<script src="JS/gantt_chart/ext/dhtmlxgantt_marker.js" type="text/javascript" charset="utf-8"></script>
<link rel="stylesheet" href="JS/gantt_chart/skins/dhtmlxgantt_terrace.css" type="text/css" media="screen" title="no title" charset="utf-8">
<cfif session.ep.language neq 'eng'><script src="JS/gantt_chart/locale/locale_<cfoutput>#session.ep.language#</cfoutput>.js" type="text/javascript" charset="utf-8"></script></cfif>

<style>

    .gantt_task_link.start_to_start .gantt_line_wrapper div {
        background-color: #dd5640;
    }

    .gantt_task_link.start_to_start:hover .gantt_line_wrapper div {
        box-shadow: 0 0 5px 0px #dd5640;
    }

    .gantt_task_link.start_to_start .gantt_link_arrow_right {
        border-left-color: #dd5640;
    }

    .gantt_task_link.finish_to_start .gantt_line_wrapper div {
        background-color: #7576ba;
    }

    .gantt_task_link.finish_to_start:hover .gantt_line_wrapper div {
        box-shadow: 0 0 5px 0px #7576ba;
    }

    .gantt_task_link.finish_to_start .gantt_link_arrow_right {
        border-left-color: #7576ba;
    }

    .gantt_task_link.finish_to_finish .gantt_line_wrapper div {
        background-color: #55d822;
    }

    .gantt_task_link.finish_to_finish:hover .gantt_line_wrapper div {
        box-shadow: 0 0 5px 0px #55d822;
    }

    .gantt_task_link.finish_to_finish .gantt_link_arrow_left {
        border-right-color: #55d822;
    }
    .gantt_layout.gantt_layout_x { height: calc(100% - 16px)!important;}
    .gantt_tree_content a:link{color:#4cc0c1 !important;}
</style>

<!--- Düzenleme kısıtıyla ilgili kod --->
<cfif isDefined("xml_control_change_graph") and xml_control_change_graph eq 0><cfset display_mode = 1></cfif>
<!--- Proje görevlisiyle ilgili kısıta dait kod --->
<cfif not isDefined("display_mode") and isDefined("attributes.project_id") and len(attributes.project_id) and xml_control_project_emp is 1>
	<cfquery name="get_project_emp" datasource="#DSN#">
		SELECT PROJECT_EMP_ID FROM PRO_PROJECTS WHERE PROJECT_ID = #attributes.project_id#
	</cfquery>
	<cfif get_project_emp.PROJECT_EMP_ID neq session.ep.userid><cfset display_mode = 1></cfif>
</cfif>
<!--- Şube / Departman kısıtına ilişkin kod --->
<cfif isDefined("xml_control_employee_branch") and xml_control_employee_branch eq 1>
	<cfquery name="get_authorized_branch" datasource="#dsn#">
        SELECT DISTINCT 
            B.BRANCH_ID, 
            B.BRANCH_NAME 
        FROM 
            EMPLOYEE_POSITION_BRANCHES EPB, 
            BRANCH B 
        WHERE 
            EPB.BRANCH_ID = B.BRANCH_ID AND
            B.COMPANY_ID = #session.ep.company_id# AND B.BRANCH_STATUS = 1 AND
            EPB.POSITION_CODE = #session.ep.position_code#
            <cfif isDefined("attributes.branch_id") and len(attributes.branch_id) and attributes.branch_id neq 0>AND B.BRANCH_ID = #attributes.branch_id#</cfif>
    </cfquery>
    <cfif get_authorized_branch.recordCount eq 0>
    	<cf_get_lang dictionary_id='57997.şube yetkiniz uygun değil'>
    	<cfabort>
    </cfif>
    <cfif isDefined("attributes.branch_id") and len(attributes.branch_id) and attributes.branch_id neq 0 and isDefined("attributes.department") and len(attributes.department) and session.ep.our_company_info.is_location_follow eq 1>
        <cfquery name="get_authorized_departments" datasource="#dsn#">
            SELECT DISTINCT
                D.DEPARTMENT_ID,
                D.DEPARTMENT_HEAD
            FROM
                EMPLOYEE_POSITION_BRANCHES EPB,
                DEPARTMENT D
            WHERE 
                EPB.DEPARTMENT_ID = D.DEPARTMENT_ID AND
                EPB.POSITION_CODE = #session.ep.position_code# AND
                D.BRANCH_ID = #attributes.branch_id# AND 
                D.DEPARTMENT_STATUS = 1 AND
                D.DEPARTMENT_ID = #attributes.department#
        </cfquery>
        <cfif get_authorized_departments.recordCount eq 0>
            <cf_get_lang dictionary_id='57532.Yetkiniz yok'>
            <cfabort>
        </cfif>
    </cfif>
	<cfset limitation_emp_id = session.ep.userid>
</cfif>
<!--- Sayfa kısıtına ilişkin kod --->
<cfset page_name = "#url.fuseaction#">
<cfif not isDefined("display_mode") or display_mode neq 1>
    <cfquery name="GET_DEFINED_PAGE" datasource="#DSN#">
        SELECT DISTINCT DENIED_PAGE, DENIED_TYPE FROM EMPLOYEE_POSITIONS_DENIED WHERE DENIED_PAGE = <cfqueryparam cfsqltype="cf_sql_varchar" value="#page_name#">
    </cfquery>
    <cfif get_defined_page.recordcount gt 0>
        <cfif isdefined("session.ep") and isdefined("session.ep.userid")>
            <cfquery name="get_page_access_and_denied" datasource="#dsn#">
                SELECT DISTINCT
                    EP.EMPLOYEE_ID,
                    EPD.DENIED_TYPE,
                    EPD.IS_VIEW,
                    EPD.IS_INSERT,
                    EPD.IS_DELETE
                FROM
                    EMPLOYEE_POSITIONS_DENIED EPD,
                    EMPLOYEE_POSITIONS EP
                WHERE
                    EPD.DENIED_PAGE = '#page_name#' AND
                    EPD.DENIED_TYPE = #get_defined_page.DENIED_TYPE# AND
                    EP.EMPLOYEE_ID = #session.ep.userid# AND
                    (
                        EP.POSITION_CAT_ID = EPD.POSITION_CAT_ID OR
                        EP.POSITION_CODE = EPD.POSITION_CODE OR
                        EP.USER_GROUP_ID = EPD.USER_GROUP_ID
                    )
                    <cfif get_defined_page.DENIED_TYPE eq 1>
                        AND (EPD.IS_VIEW = 1 AND EPD.IS_INSERT = 1)
                    <cfelse>
                        AND (EPD.IS_VIEW = 1 OR EPD.IS_INSERT = 1)
                    </cfif>
            </cfquery>
        </cfif>
        <cfif isdefined("get_defined_page") and get_defined_page.denied_type eq 1 and get_page_access_and_denied.recordcount gt 0 or get_defined_page.denied_type eq 0 and get_page_access_and_denied.recordcount eq 0>
            <cfset display_mode = 0>
        <cfelse>
            <cfset display_mode = 1>
        </cfif>
    <cfelse>
        <cfset display_mode = 0>
    </cfif>
</cfif>

<div class="col col-12 col-xs-12">
    <cf_box>
        <cfform name="form" action="" method="post">
            <cfinput type="hidden" name="is_form_submitted" value="1">
            <cf_box_search>
                <div class="form-group">
                    <select name="view_period" id="view_period">
                        <option value="0"<cfif attributes.view_period eq 0> selected</cfif>><cf_get_lang dictionary_id ='58457.Günlük'></option>
                        <option value="1"<cfif attributes.view_period eq 1> selected</cfif>><cf_get_lang dictionary_id ='58458.Haftalık'></option>
                        <option value="2"<cfif attributes.view_period eq 2> selected</cfif>><cf_get_lang dictionary_id ='58932.Aylık'></option>
                    </select>
                </div>
                <div class="form-group">
                    <div class="input-group">
                        <cfinput type="hidden" name="partner_id" id="partner_id" value="#(len(attributes.employee) and len(attributes.partner_id)) ? attributes.partner_id : ''#">
                        <cfinput type="hidden" name="employee_id" id="employee_id" value="#(len(attributes.employee) and len(attributes.employee_id)) ? attributes.employee_id : ''#">
                        <cfinput type="text" name="employee" id="employee" value="#len(attributes.employee) ? attributes.employee : ''#" placeholder = "#getLang('','','57569')#" style="width:100px;" onFocus="AutoComplete_Create('employee','MEMBER_NAME,MEMBER_PARTNER_NAME','MEMBER_PARTNER_NAME2,MEMBER_NAME2','get_member_autocomplete','\'1,3\',0,0,0','PARTNER_ID,EMPLOYEE_ID','partner_id,employee_id','','3','135');" autocomplete="off">	
                        <span class="input-group-addon icon-ellipsis" onClick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_positions&field_emp_id=form.employee_id&field_partner=form.partner_id&field_name=form.employee&select_list=1,2','list');"></span>
                    </div>
                </div>
                <div class="form-group">
                    <div class="input-group">
                        <cfsavecontent variable="message"><cf_get_lang dictionary_id='58503.Lütfen Tarih giriniz'></cfsavecontent>
                        <cfinput type="text" name="start_date" value="#dateformat(attributes.start_date,dateformat_style)#" required="yes" validate="#validate_style#" message="#message#">
                        <span class="input-group-addon"><cf_wrk_date_image date_field="start_date"></span>
                    </div>
                </div>
                <div class="form-group">
                    <div class="input-group">
                        <cfsavecontent variable="message"><cf_get_lang dictionary_id='58503.Lütfen Tarih giriniz'></cfsavecontent>
                        <cfinput type="text" name="finish_date" value="#dateformat(attributes.finish_date,dateformat_style)#" required="yes" validate="#validate_style#" message="#message#">
                        <span class="input-group-addon"><cf_wrk_date_image date_field="finish_date"></span>
                    </div>
                </div>
                <div class="form-group">
                    <select name="option_list" id="option_list" style="width:100px;">
                        <option value="0" <cfif attributes.option_list eq 0>selected</cfif>><cf_get_lang dictionary_id='58020.Tüm İşler'></option>
                        <option value="1" <cfif attributes.option_list eq 1>selected</cfif>><cf_get_lang dictionary_id='38457.Gündem'></option>
                    </select>
                </div>
                <div class="form-group">
                    <select name="status" id="status">
                        <option value=""><cf_get_lang dictionary_id='57708.Tümü'></option>
                        <option value="1"<cfif attributes.status eq 1> selected</cfif>><cf_get_lang dictionary_id ='57493.Aktif'></option>
                        <option value="0"<cfif attributes.status eq 0> selected</cfif>><cf_get_lang dictionary_id ='57494.Pasif'></option>
                    </select>
                </div>
                <div class="form-group">
                    <select name="view_type" id="view_type">
                        <option value=""><cf_get_lang dictionary_id='57708.Tümü'></option>
                        <option value="0"<cfif attributes.view_type eq 0> selected</cfif>><cf_get_lang dictionary_id ='58869.Planlanan'></option>
                        <option value="1"<cfif attributes.view_type eq 1> selected</cfif>><cf_get_lang dictionary_id ='40550.Tamamlanan'></option>
                    </select>
                </div>
                <div class="form-group">
                    <select name="employee_type" id="employee_type">
                        <option value=""><cf_get_lang dictionary_id='57708.Tümü'></option>
                        <option value="0"<cfif attributes.employee_type eq 0> selected</cfif>><cf_get_lang dictionary_id ='30370.Çalışanlar'></option>
                        <option value="1"<cfif attributes.employee_type eq 1> selected</cfif>><cf_get_lang dictionary_id ='29408.Kurumsal Üyeler'></option>
                    </select>
                </div>
                <div class="form-group small">
                    <cfsavecontent variable="message"><cf_get_lang dictionary_id='57537.Kayıt Sayısı Hatalı!'></cfsavecontent>
                    <cfinput type="text" name="maxrows" value="#attributes.maxrows#" validate="integer" range="1,1250" required="yes" message="#message#">
                </div>
                <div class="form-group">
                    <cf_wrk_search_button button_type="4" search_function="control()">
                </div>
            </cf_box_search>
            <cf_box_search_detail>
                <div class="col col-3 col-md-4 col-sm-6 col xs-12" type="column" index="1" sort="true">
                    <div class="form-group" id="item-branch_id">
                        <label class="col col-12"><cf_get_lang dictionary_id='57453.Şube'></label>
                        <div class="col col-12">
                            <select name="branch_id" id="branch_id" onChange="showDepartment(this)">
                                <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                <cfoutput query="branches">
                                    <option value="#BRANCH_ID#" <cfif attributes.branch_id eq branch_id>selected</cfif>>#BRANCH_NAME#</option>
                                </cfoutput>
                            </select>
                        </div>
                    </div>
                    <div class="form-group" id="item-dept_id">
                        <label class="col col-12"><cf_get_lang dictionary_id='57572.Departman'></label>
                        <div class="col col-12">
                            <div class="col col-12 col-xs-12" id="department_div">
                                <select name="DEPARTMENT_ID" id="DEPARTMENT_ID"> 
                                    <option value=""><cf_get_lang dictionary_id='53200.Departman Seçiniz'></option>
                                    <cfif len(attributes.branch_id)>
                                        <cfoutput query="departments">
                                            <option value="#department_id#" <cfif attributes.department_id eq department_id>selected</cfif>>#department_head#</option>
                                        </cfoutput>
                                    </cfif>
                                </select>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col col-3 col-md-4 col-sm-6 col xs-12" type="column" index="2" sort="true">
                    <div class="form-group" id="item-project_id">
                        <label class="col col-12"><cf_get_lang dictionary_id='57416.Proje'></label>
                        <div class="col col-12">
                            <div class="input-group">
                                <cfinput type="hidden" name="project_id" id="project_id" value="#(len(attributes.project_head) and len(attributes.project_id)) ? attributes.project_id : ''#">
                                <cfinput type="text" name="project_head" id="project_head" value="#len(attributes.project_head) ? attributes.project_head : ''#" style="width:110;" onFocus="AutoComplete_Create('project_head','PROJECT_HEAD','PROJECT_HEAD','get_project','','PROJECT_ID','project_id','form','3','250');" autocomplete="off">
                                <span class="input-group-addon icon-ellipsis" onClick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_list_projects&project_head=form.project_head&project_id=form.project_id</cfoutput>');"></span>
                            </div>
                        </div>
                    </div>
                    <div class="form-group" id="item-company_cat_id">
                        <label class="col col-12"><cf_get_lang dictionary_id='57486.Kategori'></label>
                        <div class="col col-12">
                            <select name="company_cat_id" id="company_cat_id">
                                <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                <cfoutput query="getCompanyCat">
                                    <option value="#id#" <cfif attributes.company_cat_id eq id>selected</cfif>>#name#</option>
                                </cfoutput>
                            </select>
                        </div>
                    </div>
                </div>
            </cf_box_search_detail>
        </cfform>
    </cf_box>
    <cf_box id="chart" title="GANTT">
        <cfif not attributes.is_form_submitted>
            <cf_get_lang dictionary_id = "57701.Filtre Ediniz">
        <cfelseif attributes.is_form_submitted and not attributes.totalrecords>
            <cf_get_lang dictionary_id = "57484.Kayıt Yok">
        </cfif>
    </cf_box>
    <cfif attributes.is_form_submitted and attributes.totalrecords gt attributes.maxrows>
        <cf_box id="chart_paging">
            <cfset adres = "project.employee_work_graph">
            <cfif len(attributes.is_form_submitted)>
                <cfset adres = "#adres#&is_form_submitted=#attributes.is_form_submitted#">
            </cfif>
            <cfif len(attributes.view_period)>
                <cfset adres = "#adres#&view_period=#attributes.view_period#">
            </cfif>
            <cfif len(attributes.partner_id)>
                <cfset adres = "#adres#&partner_id=#attributes.partner_id#">
            </cfif>
            <cfif len(attributes.employee_id)>
                <cfset adres = "#adres#&employee_id=#attributes.employee_id#">
            </cfif>
            <cfif len(attributes.employee)>
                <cfset adres = "#adres#&employee=#attributes.employee#">
            </cfif>
            <cfif len(attributes.start_date)>
                <cfset adres = "#adres#&start_date=#dateformat(attributes.start_date,dateformat_style)#">
            </cfif>
            <cfif len(attributes.finish_date)>
                <cfset adres = "#adres#&finish_date=#dateformat(attributes.finish_date,dateformat_style)#">
            </cfif>
            <cfif len(attributes.option_list)>
                <cfset adres = "#adres#&option_list=#attributes.option_list#">
            </cfif>
            <cfif len(attributes.status)>
                <cfset adres = "#adres#&status=#attributes.status#">
            </cfif>
            <cfif len(attributes.view_type)>
                <cfset adres = "#adres#&view_type=#attributes.view_type#">
            </cfif>
            <cfif len(attributes.employee_type)>
                <cfset adres = "#adres#&employee_type=#attributes.employee_type#">
            </cfif>
            <cfif len(attributes.branch_id)>
                <cfset adres = "#adres#&branch_id=#attributes.branch_id#">
            </cfif>
            <cfif len(attributes.department_id)>
                <cfset adres = "#adres#&department_id=#attributes.department_id#">
            </cfif>
            <cfif len(attributes.project_id)>
                <cfset adres = "#adres#&project_id=#attributes.project_id#">
            </cfif>
            <cfif len(attributes.project_head)>
                <cfset adres = "#adres#&project_head=#attributes.project_head#">
            </cfif>
            <cfif len(attributes.company_cat_id)>
                <cfset adres = "#adres#&company_cat_id=#attributes.company_cat_id#">
            </cfif>

            <cf_paging 
                page="#attributes.page#" 
                maxrows="#attributes.maxrows#" 
                totalrecords="#attributes.totalrecords#" 
                startrow="#attributes.startrow#" 
                adres="#adres#">
        </cf_box>
    </cfif>
    <div id = "source_info" style="display:none;">
        <cf_box id="box_source_info" title = "#getLang('','','31901')#" closable = "1" collapsable = "0" resize = "0">
            <cf_grid_list id = "table_source_info"></cf_grid_list>
        </cf_box>
    </div>
</div>

<cfset ghantChartHeight = (attributes.is_form_submitted) ? ((attributes.recordcount * 30) + 100) : 0 />

<script type="text/javascript">
    
    <cfif attributes.is_form_submitted and attributes.totalrecords>

        let zoom = <cfoutput>#attributes.view_period#</cfoutput>;

        $("#body_chart").height("<cfoutput>#ghantChartHeight#</cfoutput>px"); // Set Gantt Chart Height

        $("#chart .portBoxBodyStandart").css({"padding":"0"}); //Set Gantt Chart box padding

        gantt.config.columns = [
            {name:"description",    label:"Çalışan",  tree:true, align: "left", width:'*',},
            {name:"text",           label:"Görev Adı", hide:true },
            {name:"start_date",     label:"Başlangıç Tarihi", align: "center" },
            {name:"duration",       label:"Süre",   align: "center" },
            {name:"add",            label:"", hide:true }
        ];

        gantt.init("body_chart");
        gantt.parse({
            data: [
                <cfoutput>
                    <cfloop array="#getTaskList#" item="item">
                        { id:#item.id#, description:"<a href = '#request.self#?fuseaction=hr.list_hr&event=upd&employee_id=#item.id#' class='text-info' target='_blank'>#item.name# #item.surname#</a>", text:"#item.name# #item.surname#", progress:0, open:true },
                        <cfif ArrayLen(item.list)>
                            <cfset currentRow = 1>
                            <cfloop array="#item.list#" item="item_list">
                                <cfset date_diff = wrk_round((datediff('n',item_list.targetStartDate,item_list.targetFinishDate) + 1) / 1440)>
                                { id:#item_list.taskID#, item_type:"#item_list.type#", description:"#item_list.title#", text:"#item_list.title#", start_date:"#dateFormat(item_list.targetStartDate, dateformat_style)#", duration:#date_diff#, progress:0, parent:#item.id# },
                                <cfset currentRow++ >
                            </cfloop>
                        </cfif>
                    </cfloop>
                </cfoutput>
            ]
        });

        gantt.attachEvent("onTaskClick", function(id, e){

            var selection = this.getTask(id);

            if( selection.item_type != undefined ){

                var formData = new FormData();
                formData.append("item_id", selection.id);
                formData.append("item_type", selection.item_type);
                AjaxControlPostData('V16/project/cfc/employee_work_graph.cfc?method=getTaskListById', formData, function ( response ) {
                    
                    if( JSON.parse(response).length > 0 ){

                        var data = JSON.parse(response)[0];

                        let sourceUrl = "";

                        switch ( selection.item_type ) {
                            case 'task': sourceUrl = '<cfoutput>#request.self#</cfoutput>?fuseaction=project.works&event=det&id='+data.id+'';
                            break;
                            case 'event': sourceUrl = '<cfoutput>#request.self#</cfoutput>?fuseaction=agenda.view_daily&event=upd&event_id='+data.id+'';
                            break;
                            case 'offtime': sourceUrl = '<cfoutput>#request.self#</cfoutput>?fuseaction=ehesap.offtimes&event=upd&offtime_id='+data.id+'';
                            break;
                            case 'ssk_fee': sourceUrl = '<cfoutput>#request.self#</cfoutput>?fuseaction=ehesap.popup_ssk_fee_self_report_print_form&fee_id='+data.id+'';
                            break;
                            default:
                                break;
                        }

                        $("#source_info #table_source_info").html("");
                        $("<tbody>").append(
                            $("<tr>").append($("<td>").text("<cf_get_lang dictionary_id = "58820.Başlık">"), $("<td>").append( $("<a>").attr({"href":sourceUrl, "target" : "_blank"}).text(data.head))),
                            $("<tr>").append($("<td>").text("<cf_get_lang dictionary_id = "57771.Detay">"), $("<td>").text(data.detail)),
                            $("<tr>").append($("<td>").text("<cf_get_lang dictionary_id = "57416.Proje">"), $("<td>").append( $("<a>").attr({"href":"<cfoutput>#request.self#</cfoutput>?fuseaction=project.projects&event=det&id=" + data.project_id + "", "target" : "_blank"}).text(data.project_title))),
                            $("<tr>").append($("<td>").text("<cf_get_lang dictionary_id = "58053.Başlangıç Tarihi">"), $("<td>").text(data.start_date)),
                            $("<tr>").append($("<td>").text("<cf_get_lang dictionary_id = "57700.Bitiş Tarihi">"), $("<td>").text(data.finish_date)),
                            $("<tr>").append($("<td>").text("<cf_get_lang dictionary_id = "39663.Tamamlanma Oranı">"), $("<td>").text(selection.progress))
                        ).appendTo($("#source_info #table_source_info"));
                        
                        cfmodal('', 'warning_modal', { element_id : 'source_info' });

                    }

                });

            }

        });

        gantt.attachEvent("onAfterTaskDrag", function(id, mode, e,task,target){
            
            <cfif isDefined("display_mode") and display_mode eq 0>

                var selection = this.getTask(id);

                var formData = new FormData();
                formData.append("item_id", selection.id);
                formData.append("item_type", selection.item_type);
                formData.append("target_start_date", selection.start_date);
                formData.append("target_finish_date", selection.end_date);
                AjaxControlPostData('V16/project/cfc/employee_work_graph.cfc?method=updateAgendaItems', formData, function ( response ) {});

            <cfelse>
                alert("<cf_get_lang dictionary_id = "57532.Yetkiniz Yok">");
            </cfif>

        });

        setScaleConfig(zoom);

        /* Set View Mode - day, week, year */

        function setScaleConfig(level) {
            switch (level) {
                case 0:
                    gantt.config.scale_unit = "day";
                    gantt.config.date_scale = "%F %d";
                    gantt.config.min_column_width = 50;
                    gantt.config.scale_height = 54;
                    gantt.config.subscales = [
                        {unit: "hour", step: 3, date: "%H:%i"}
                    ];
                    break;
                case 1:
                    var weekScaleTemplate = function (date) {
                        var dateToStr = gantt.date.date_to_str("%d %M");
                        var endDate = gantt.date.add(gantt.date.add(date, 1, "week"), -1, "day");
                        return dateToStr(date) + " - " + dateToStr(endDate);
                    };
                    gantt.config.scale_unit = "week";
                    gantt.config.step = 1;
                    gantt.templates.date_scale = weekScaleTemplate;
                    gantt.config.scale_height = 50;
                    gantt.config.subscales = [
                        {unit: "day", step: 1, date: "%D"}
                    ];
                    break;
                case 2:
                    gantt.config.scale_unit = "year";
                    gantt.config.step = 1;
                    gantt.config.date_scale = "%Y";
                    gantt.templates.date_scale = null;
                    gantt.config.min_column_width = 50;
                    gantt.config.scale_height = 50;
                    gantt.config.subscales = [
                        {unit: "month", step: 1, date: "%M"}
                    ];
                    break;
            }

            gantt.render();

        }

        /* Set View Mode - day, week, year */

        /* Zoom In - Out */

        function zoomIn(){
            zoom += ( zoom != 2 ) ? 1 : 0;
            setScaleConfig(zoom);
        }
        function zoomOut(){
            zoom -= ( zoom != 0 ) ? 1 : 0;
            setScaleConfig(zoom);
        }

        /* Zoom In - Out */

    </cfif>
    
    function control(){
		if (document.getElementById("form").employee.value == "" && document.getElementById("form").option_list.selectedIndex == 1)
		{
			alert("<cf_get_lang dictionary_id='60610.Tüm Gündemi görüntülemek için bir görevli seçmelisiniz'> !");
			return false;
		}else return true;
    }
    
	function showDepartment(element){
		if (element.value != "") AjaxPageLoad("<cfoutput>#request.self#</cfoutput>?fuseaction=hr.popup_ajax_list_hr&show_div=0&branch_id="+element.value,'department_div',1,'İlişkili Departmanlar');
        $("#work_station").html("<option value = ''><cf_get_lang dictionary_id='57734.Seçiniz'></option>");
        $("#work_sub_station").html("<option value = ''><cf_get_lang dictionary_id='57734.Seçiniz'></option>");
    }

    $("#header_chart > .portHeadLightMenu > ul").prepend(
        $("<li>").append($("<a>").attr({"href":"javascript://", "title" : "Zoom In", "onclick" : "zoomIn()"}).append($("<i>").addClass("catalyst-magnifier-add"))),
        $("<li>").append($("<a>").attr({"href":"javascript://", "title" : "Zoom Out", "onclick" : "zoomOut()"}).append($("<i>").addClass("catalyst-magnifier-remove")))
    )
</script>
