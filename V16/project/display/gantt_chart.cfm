<!--- 
    Author: Uğur Hamurpet
    Date:   29/09/2020
    Desc:   Projeler Gantt Chart tasarım ve kaynak kodları düzenlendi, filtre eklendi.
--->

<cfparam name="attributes.is_form_submitted" default="0">
<cfparam name="attributes.project_id" default="#attributes.id?:''#">
<cfparam name="attributes.project_head" default="">
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.start_date" default="#dateadd('m',-1,now())#">
<cfparam name="attributes.finish_date" default="#now()#">
<cfparam name="attributes.view_period" default="0">
<cfparam name="attributes.work_status" default="">
<cfparam name="attributes.page" default="1">
<cfparam name="attributes.maxrows" default="#session.ep.maxrows#">
<cfparam name="attributes.totalrecords" default="0">
<cfparam name="attributes.startrow"  default="#((attributes.page-1)*attributes.maxrows)+1#">

<cfinclude template="../query/get_prodetail.cfm">

<cfif not project_detail.recordcount>
	<cfset hata  = 10>
    <cfinclude template="../../dsp_hata.cfm">
<cfelse>
    <cfset attributes.project_head = project_detail.PROJECT_HEAD />
</cfif>

<cfif attributes.is_form_submitted>

    <cfif len(attributes.start_date)><cf_date tarih = "attributes.start_date"></cfif>
    <cfif len(attributes.finish_date)><cf_date tarih = "attributes.finish_date"></cfif>

    <cfset getComponent = createObject('component','V16.project.cfc.get_project_work')>
    <cfset get_project = getComponent.GET_PRO_WORK(
        project_id: attributes.project_id,
        work_status: attributes.work_status,
        start_date: attributes.start_date,
        finish_date: attributes.finish_date,
        keyword: attributes.keyword,
        startrow: attributes.startrow,
        maxrows: attributes.maxrows
    )>

    <cfset attributes.totalrecords = get_project.recordcount?:0 />

</cfif>
<script src="JS/gantt_chart/dhtmlxgantt.js" type="text/javascript" charset="utf-8"></script>
<script src="JS/gantt_chart/ext/dhtmlxgantt_marker.js" type="text/javascript" charset="utf-8"></script>
<link rel="stylesheet" href="JS/gantt_chart/skins/dhtmlxgantt_terrace.css" type="text/css" media="screen" title="no title" charset="utf-8">
<cfif session.ep.language neq 'eng'><script src="JS/gantt_chart/locale/locale_<cfoutput>#session.ep.language#</cfoutput>.js" type="text/javascript" charset="utf-8"></script></cfif>
<head>	
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
</head>

<body>
    <div class="col col-12 col-xs-12">
        <cf_box>
            <cfform name="form" action="" method="post">
                <cfinput type="hidden" name="is_form_submitted" value="1">
                <cf_box_search>
                    <div class="form-group">
                        <cfinput type="text" name="keyword" id="keyword" value="#attributes.keyword#" maxlength="50" style="width:100px;" placeholder="#getLang(48,'Filtre',57460)#">
                    </div>
                    <div class="form-group">
                        <select name="view_period" id="view_period">
                            <option value="0"<cfif attributes.view_period eq 0> selected</cfif>><cf_get_lang dictionary_id ='58457.Günlük'></option>
                            <option value="1"<cfif attributes.view_period eq 1> selected</cfif>><cf_get_lang dictionary_id ='58458.Haftalık'></option>
                            <option value="2"<cfif attributes.view_period eq 2> selected</cfif>><cf_get_lang dictionary_id ='58932.Aylık'></option>
                        </select>
                    </div>
                    <div class="form-group">
                        <div class="input-group">
                            <input type="hidden" name="project_id" id="project_id" value="<cfoutput>#attributes.project_id#</cfoutput>">
                            <input name="project_head" type="text" id="project_head" value="<cfif Len(attributes.project_id) and len(attributes.project_head)><cfoutput>#get_project_name(attributes.project_id)#</cfoutput></cfif>"  onfocus="AutoComplete_Create('project_head','PROJECT_HEAD','PROJECT_HEAD','get_project','','PROJECT_ID','project_id','list_works','3','250');" autocomplete="off">
                            <span class="input-group-addon icon-ellipsis btnPointer" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_list_projects&project_head=list_works.project_head&project_id=list_works.project_id</cfoutput>');"></span>
                        </div>
                    </div>
                    <div class="form-group">
                        <div class="input-group">
                            <cfsavecontent variable="message"><cf_get_lang dictionary_id='58503.Lütfen Tarih giriniz'></cfsavecontent>
                            <cfinput type="text" name="start_date" value="#len( attributes.start_date ) ? dateformat(attributes.start_date,dateformat_style) : ''#" required="yes" validate="#validate_style#" message="#message#">
                            <span class="input-group-addon"><cf_wrk_date_image date_field="start_date"></span>
                        </div>
                    </div>
                    <div class="form-group">
                        <div class="input-group">
                            <cfsavecontent variable="message"><cf_get_lang dictionary_id='58503.Lütfen Tarih giriniz'></cfsavecontent>
                            <cfinput type="text" name="finish_date" value="#len( attributes.finish_date ) ? dateformat(attributes.finish_date,dateformat_style) : ''#" required="yes" validate="#validate_style#" message="#message#">
                            <span class="input-group-addon"><cf_wrk_date_image date_field="finish_date"></span>
                        </div>
                    </div>
                    <div class="form-group">
                        <select name="work_status" id="work_status">
                            <option value=""><cf_get_lang dictionary_id='57708.Tümü'></option>
                            <option value="1"<cfif attributes.work_status eq 1> selected</cfif>><cf_get_lang dictionary_id ='57493.Aktif'></option>
                            <option value="-1"<cfif attributes.work_status eq -1> selected</cfif>><cf_get_lang dictionary_id ='57494.Pasif'></option>
                        </select>
                    </div>
                    <!--- <div class="form-group small">
                        <cfsavecontent variable="message"><cf_get_lang dictionary_id='57537.Kayıt Sayısı Hatalı!'></cfsavecontent>
                        <cfinput type="text" name="maxrows" value="#attributes.maxrows#" validate="integer" range="1,1250" required="yes" message="#message#">
                    </div> --->
                    <div class="form-group">
                        <cf_wrk_search_button button_type="4">
                    </div>
                </cf_box_search>
            </cfform>
        </cf_box>
        <cf_box id="chart" title="GANTT CHART #getLang('main',4,'Proje')# ID : #attributes.project_id#">
            <cfif not attributes.is_form_submitted>
                <cf_get_lang dictionary_id = "57701.Filtre Ediniz">
            <cfelseif attributes.is_form_submitted and not attributes.totalrecords>
                <cf_get_lang dictionary_id = "57484.Kayıt Yok">
            </cfif>
        </cf_box>
        <!--- <cfif attributes.is_form_submitted and attributes.totalrecords gt attributes.maxrows>
            <cf_box id="chart_paging">
                <cfset adres = "project.gantt_chart">
                <cfif len(attributes.is_form_submitted)>
                    <cfset adres = "#adres#&is_form_submitted=#attributes.is_form_submitted#">
                </cfif>
                <cfif len(attributes.keyword)>
                    <cfset adres = "#adres#&keyword=#attributes.keyword#">
                </cfif>
                <cfif len(attributes.view_period)>
                    <cfset adres = "#adres#&view_period=#attributes.view_period#">
                </cfif>
                <cfif len(attributes.project_id)>
                    <cfset adres = "#adres#&project_id=#attributes.project_id#">
                </cfif>
                <cfif len(attributes.project_head)>
                    <cfset adres = "#adres#&project_head=#attributes.project_head#">
                </cfif>
                <cfif len(attributes.start_date)>
                    <cfset adres = "#adres#&start_date=#attributes.start_date#">
                </cfif>
                <cfif len(attributes.finish_date)>
                    <cfset adres = "#adres#&finish_date=#attributes.finish_date#">
                </cfif>
                <cfif len(attributes.work_status)>
                    <cfset adres = "#adres#&work_status=#attributes.work_status#">
                </cfif>
                
                <cf_paging 
                    page="#attributes.page#" 
                    maxrows="#attributes.maxrows#" 
                    totalrecords="#attributes.totalrecords#" 
                    startrow="#attributes.startrow#" 
                    adres="#adres#">
            </cf_box>
        </cfif> --->
    </div>
    
    <cfset ghantChartHeight = attributes.is_form_submitted ? ((get_project.recordcount * 30) + 100) : 0 />
    
    <script type="text/javascript">
    
        <cfif attributes.is_form_submitted and attributes.totalrecords>

            let zoom = <cfoutput>#attributes.view_period#</cfoutput>;
            
            $("#body_chart").height("<cfoutput>#ghantChartHeight#</cfoutput>px"); // Set Gantt Chart Height

            $("#chart .portBoxBodyStandart").css({"padding":"0"}); //Set Gantt Chart box padding

            /* Gantt Config */

            gantt.config.columns = [
                {name:"miles", label:"M", width:20,  tree:true},
                {name:"preference", label:"Ö",width:20},
                {name:"employee",label:"G",width:20},
                {name:"project_name",label:"Görev",width:65},
                {name:"iconplus",label:"<cfoutput><a href='#request.self#?fuseaction=project.works&event=add&id=#attributes.project_id#&work_fuse=project.emptypopup_ajax_project_works' target='_blank'><div class='gantt_grid_head_cell gantt_grid_head_add gantt_last_cell' style='width:43px;' role='button' aria-label='new task' column_id='add'></div></a></cfoutput>",width:30}
            ];

            gantt.config.lightbox.sections = [
                {name: "description", height: 70, map_to: "text", type: "textarea", focus: true},
                {name: "type", type: "typeselect", map_to: "type"},
                {name: "time", type: "duration", map_to: "auto"}
            ];

            gantt.config.type_renderers[gantt.config.types.project] = function (task) {
                var main_el = document.createElement("div");
            
                main_el.setAttribute(gantt.config.task_attribute, task.id);
                var size = gantt.getTaskPosition(task);
                main_el.innerHTML = [
                    "<div class='project-left'></div>",
                    "<div class='project-right'></div>"
                ].join('');
                main_el.className = "custom-project";

                main_el.style.left = size.left + "px";
                main_el.style.top = size.top + 7 + "px";
                main_el.style.width = size.width + "px";
                return main_el;
            };

            gantt.config.fit_tasks = true;
            gantt.config.drag_project = true;
            gantt.config.scale_unit = "month";
            gantt.config.date_scale = "%F, %Y";
            gantt.config.scale_unit = "day"; 
            gantt.config.date_scale = "%d %M, %D";
            
            /* Gantt Config */

            /* Gantt Template */

            gantt.templates.rightside_text = function (start, end, task) {
                if (task.type == gantt.config.types.milestone) {
                    return task.text;        
                }
                return "";
            };

            gantt.templates.progress_text = function (start, end, task) {
                task.text =  Math.round(task.progress * 100) + "%";
                return "<span> </span>";
            };

            gantt.templates.link_class = function (link) {
                var types = gantt.config.links;
                switch (link.type) {
                    case types.finish_to_start:
                        return "finish_to_start";
                        break;
                    case types.start_to_start:
                        return "start_to_start";
                        break;
                    case types.finish_to_finish:
                        return "finish_to_finish";
                        break;
                }
            };

            gantt.templates.scale_cell_class = function(date){
                if(date.getDay()==0||date.getDay()==6){
                    return "weekend";
                }
            };

            /* Gantt Template */

            gantt.init("body_chart");

            gantt.parse({
                data:[
                    <cfoutput query="get_project">   
                        <cfif len(target_start) and len(target_finish)>
                            <cfset date_diff = wrk_round((datediff('n',target_start,target_finish) + 1) / 1440)>
                        <cfelse>
                            <cfset date_diff = 0>
                        </cfif>
                        <cfif len(employee_id)>
                            <cfset employee_photo = getComponent.EMPLOYEE_PHOTO(employee_id:get_project.employee_id)>
                        <cfelse>
                            <cfset employee_photo = ''>
                        </cfif>
                        <cfif isdefined("employee_photo.photo") and len(employee_photo.photo)>
                            <cfset emp_photo="<img class='img-circle' style='width : 30px; height:30px;margin: auto;' src='../../documents/hr/#employee_photo.PHOTO#' />">
                       <cfelseif isdefined("employee_photo.EMPLOYEE_NAME") and  len(employee_photo.EMPLOYEE_NAME)>
                            <cfset emp_photo="<div class='iconBox ' style='align: center; background-color:###color#' title='#employee_photo.EMPLOYEE_NAME# #employee_photo.EMPLOYEE_USERNAME#'>#Left(employee_photo.EMPLOYEE_NAME, 1)##Left(employee_photo.EMPLOYEE_USERNAME, 1)#</div>">
                        </cfif>
                        <cfif len(to_complete)>
                            <cfset complete_task = "#wrk_round(to_complete/100)#">
                        <cfelse>
                            <cfset complete_task = 0>
                        </cfif>
                        <cfset work_head_ = work_head>
                        <cfset work_head_ = replace('#work_head_#',Chr(34)," ", "ALL")>
                        <cfset work_head_ = replace('#work_head_#',Chr(39)," ", "ALL")>
                        <cfset work_head_ = replace('#work_head_#',Chr(44)," ", "ALL")>
                        <cfif type eq 0>
                            {
                                "id":#work_id#, 
                                "text":"#wrk_round(to_complete)#%  Tamamlandı",
                                "miles":"",
                                "preference":"<div class='iconBox ' style='align: center; background-color:###color#'>#left(priority,1)# </div>",
                                "employee":"#emp_photo#",
                                "project_name":"<a href='#request.self#?fuseaction=project.works&event=det&id=#work_id#' class='text-info' target='_blank'>#work_head_#</a>",
                                "start_date":"#dateformat(target_start,'dd-mm-yyyy')# #TimeFormat(target_start,"HH:MM")#",
                                "start_hour":"#TimeFormat(target_start,"HH:mm:ss")#",
                                "finish_hour":"#TimeFormat(target_start,"HH:mm:ss")#",
                                "duration":"#date_diff#", 
                                progress:#complete_task#, 
                                open: true,
                                "type":gantt.config.types.project,
                                priority:1,
                                color:"###color#",
                                "iconplus":"<a href='#request.self#?fuseaction=project.works&event=add&id=#attributes.project_id#&work_id=#work_id#&work_fuse=project.emptypopup_ajax_project_works' target='_blank'><div class='gantt_grid_head_cell gantt_grid_head_add gantt_last_cell' style='width:43px;' role='button' aria-label='Yeni görev' column_id='add'></div></a>"
                            },
                            {"id":#work_id+500#, "text":"Start Milestone", "start_date":"#dateformat(target_start,'dd-mm-yyyy')#", type:gantt.config.types.milestone, "parent":"#work_id#", "progress": 0, "open": false,style:"display:none"},
                            {"id":#work_id+800#, "text":"Finish Milestone", "start_date":"#dateformat(target_finish,'dd-mm-yyyy')#", type:gantt.config.types.milestone, "parent":"#work_id#", "progress": 0, "open": false},

                        <cfelse>
                            {
                                "id":#work_id#, 
                                "text":"#wrk_round(to_complete)#% Tamamlandı",
                                "miles":"",
                                "preference":"<div class='iconBox' style='align: center;background-color:###color#'>#left(priority,1)#</div>",
                                "employee":"#emp_photo#",
                                "project_name":"<a href='#request.self#?fuseaction=project.works&event=det&id=#work_id#' class='text-info' target='_blank'>#work_head_#</a>",
                                "start_date":"#dateformat(target_start,'dd-mm-yyyy')# #TimeFormat(target_start,"HH:MM")#",
                                "start_hour":"#TimeFormat(target_start,"HH:mm:ss")#",
                                "finish_hour":"#TimeFormat(target_finish,"HH:mm:ss")#",
                                "duration":"#date_diff#",
                                "progress": #complete_task#, 
                                open: true,
                                priority:1,
                                color:"###color#",
                                "parent":"#milestone_work_id#",
                                "iconplus":"<a href='#request.self#?fuseaction=project.works&event=add&id=#attributes.project_id#&work_id=#work_id#&work_fuse=project.emptypopup_ajax_project_works' target='_blank'><div class='gantt_grid_head_cell gantt_grid_head_add gantt_last_cell' style='width:43px;' role='button' aria-label='new task' column_id='add'></div></a>"
                            },
                        </cfif>   
                    </cfoutput>
                ],
                links:[
                    <cfset i="0">
                    <cfset w ="0">
                    <cfset x = 0>
                    <cfoutput query="get_project">   
                        <cfif isdefined("RELATED_WORK_ID") and len(RELATED_WORK_ID)>
                            <cfset str = RELATED_WORK_ID>
                            <cfset str_split = str.Split(";")>
                            <cfset r_str = right(str_split[2], 2)> <!---Sağdan son iki harf fs,ss,sf,ff----->
                            <cfif len(r_str) and r_str  contains  'FS'><!----type 0 : finish to start, type 1 : start to start, type 2 : finish to finish, type 3 : start to finish  ----->
                                <cfset fs=str_split[2].Split("FS")>
                                {id: #x#, source:  #work_id#, target: #fs[1]#, type: "0"},
                                <cfset x = "#x#+1"> 
                            <cfelseif len(r_str) and r_str contains 'SS'>
                                <cfset fs=str_split[2].Split("SS")>
                                {id: #x#, source:  #work_id#, target: #fs[1]#, type: "1"},
                                <cfset x = "#x#+1">  
                            <cfelseif len(r_str) and r_str contains 'FF'>
                                <cfset fs=str_split[2].Split("FF")>
                                {id: #x#, source:  #work_id#, target: #fs[1]#, type: "2"},
                                <cfset x = "#x#+1">  
                            <cfelseif len(r_str) and r_str contains 'SF'>
                                <cfset fs=str_split[2].Split("SF")>
                                {id: #x#, source:  #work_id#, target: #fs[1]#, type: "3"},
                                <cfset x = "#x#+1">  
                            </cfif>                        
                        </cfif>
                    </cfoutput>
                ]
            });

            gantt.attachEvent("onTaskCreated", function(obj){
                obj.duration = 4;
                obj.progress = 0.25;
            });

            gantt.attachEvent("onAfterTaskDrag", function(id, mode, e,task,target){//Drop edildiği anda DB ye kayıt etmek için gelen değerler parçalanıyor.
            //console.log(id+"--"+mode+"---"+gantt.getTask(id).start_date+"---"+gantt.getTask(id).duration+"++++"+gantt.getTask(id).end_date);
                startDate=gantt.getTask(id).start_date;//proje başlangıç tarihi 
                month = new Array();
                month[0] = "1"; month[1] = "2"; month[2] = "3"; month[3] = "4"; month[4] = "5"; month[5] = "6"; month[6] = "7"; month[7] = "8"; month[8] = "9"; month[9] = "10"; month[10] = "11"; month[11] = "12";
                start_month= month[startDate.getMonth()];
                start_minute = startDate.getMinutes();
                start_day  = startDate.getDate();
                start_year = startDate.getFullYear();

                finishDate = gantt.getTask(id).end_date;//proje bitiş tarihi 
                hour = finishDate.getHours();
                minute = finishDate.getMinutes();
                day  = finishDate.getDate();
                fin_month= month[finishDate.getMonth()];
                year = finishDate.getFullYear();
                start_hour_all = gantt.getTask(id).start_hour;                
                start_hour = start_hour_all.split(':');
                finish_hour_all = gantt.getTask(id).finish_hour;
                finish_hour =finish_hour_all.split(':');
                daily = gantt.config.scale_unit;
                start_hour_ = startDate.getHours() != '00' ? startDate.getHours() : start_hour[0];
                finish_hour_ = startDate.getHours() != '00' ? finishDate.getHours() : finish_hour[0];
                to_complete = gantt.getTask(id).progress;//progress
                to_complete = Math.round(to_complete*100);

                $.ajax({ 
                    type:'POST',  
                    url:'V16/project/cfc/get_project_work.cfc?method=UPD_TARGET',
                    data: {
                        work_id : id,
                        start_year :start_year,
                        start_month : start_month,
                        start_day : start_day,
                        start_hour : start_hour_,
                        start_minute : start_hour[1],
                        year :  year,
                        month : fin_month,
                        day : day,
                        hour : finish_hour[0],
                        minute : finish_hour_,
                        to_complete : to_complete,
                        daily : daily
                    },
                    success: function (returnData) {  
                        console.log('success');  
                    },
                    error: function () 
                    {
                        console.log('CODE:8 please, try again..');
                        return false; 
                    }
                });
            });
            
            gantt.attachEvent("onAfterLinkAdd", function(id,item){
                if(item.type == 0){
                    r_wrkid = ';'+item.target+'FS;';
                }
                else if(item.type == 1){
                    r_wrkid = ';'+item.target+'SS;';
                }
                else if(item.type == 2){
                    r_wrkid = ';'+item.target+'FF;';
                }
                else if(item.type == 3){
                    r_wrkid = ';'+item.target+'SF;';
                }
                $.ajax({ 
                    type:'POST',  
                    url:'V16/project/cfc/get_project_work.cfc?method=UPD_RELATED',
                    data: {
                    r_wrkid : r_wrkid,
                    wrk_id : item.source
                    },
                    success: function (returnData) {  
                        console.log('success');  
                    },
                    error: function () 
                    {
                        console.log('CODE:8 please, try again..');
                        return false; 
                    }
                });
            });

            gantt.attachEvent("onAfterLinkDelete", function(id,item){
                $.ajax({ 
                    type:'POST',  
                    url:'V16/project/cfc/get_project_work.cfc?method=DEL_RELATED',
                    data: {
                    wrk_id : item.source
                    },
                    success: function (returnData) {  
                        console.log('success');  
                    },
                    error: function () 
                    {
                        console.log('CODE:8 please, try again..');
                        return false; 
                    }
                });
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

        $("#header_chart > .portHeadLightMenu > ul").prepend(
            $("<li>").append($("<a>").attr({"href":"javascript://", "title" : "Zoom In", "onclick" : "zoomIn()"}).append($("<i>").addClass("catalyst-magnifier-add"))),
            $("<li>").append($("<a>").attr({"href":"javascript://", "title" : "Zoom Out", "onclick" : "zoomOut()"}).append($("<i>").addClass("catalyst-magnifier-remove")))
        )

	</script>
</body>