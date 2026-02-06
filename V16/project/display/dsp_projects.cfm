<cf_xml_page_edit fuseact="project.projects">
    <cfparam name="attributes.keyword" default="">
    <cfparam name="attributes.currency" default="">
    <cfparam name="attributes.priority_cat" default="">
    <cfparam name="attributes.special_definition" default="">
    <cfif xml_all_project eq 1>
        <cfparam name="attributes.project_status" default="0">
    <cfelse>
        <cfparam name="attributes.project_status" default="1">
    </cfif>
    <cfparam name="attributes.project_status" default="1">
    <cfparam name="attributes.process_catid" default="">
    <cfparam name="attributes.pro_employee" default="">
    <cfparam name="attributes.project_id" default="">
    <cfparam name="attributes.pro_employee_id" default="">
    <cfparam name="attributes.start_date" default="">
    <cfparam name="attributes.finish_date" default="">
    <cfparam name="attributes.company" default="">
    <cfparam name="attributes.company_id" default="">
    <cfparam name="attributes.consumer_id" default="">
    <cfparam name="attributes.pro_partner_id" default="">
    <cfparam name="attributes.pro_company_id" default="">
    <cfparam name="attributes.expense_code" default="">
    <cfparam name="attributes.expense_code_name" default="">
    <cfparam name="attributes.page" default=1>
    <cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>
    <cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
    <cfif isDefined('xml_show_responsible') and xml_show_responsible eq 1>
        <cfif not len(attributes.pro_employee_id)>
            <cfset attributes.pro_employee_id = session.ep.userid>
            <cfset attributes.pro_employee = get_emp_info(session.ep.userid,0,0)>
        </cfif>
    </cfif>
    
    <cfif isdefined("attributes.start_date") and len(attributes.start_date)>
        <cf_date tarih = "attributes.start_date">
    </cfif>
    <cfif isdefined("attributes.finish_date") and len(attributes.finish_date)>
        <cf_date tarih = "attributes.finish_date">
    </cfif>
    
    <cfif isdefined("attributes.is_form_submitted")>
        <cfscript>
                get_project_list_action = CreateObject("component","V16.project.cfc.get_project");
                get_project_list_action.dsn = dsn;
                    get_projects = get_project_list_action.get_projects_list_fnc(
                    keyword: '#iif(isdefined("attributes.keyword"),"attributes.keyword",DE(""))#' ,
                    currency : '#iif(isdefined("attributes.currency"),"attributes.currency",DE(""))#' ,
                    priority_cat :'#iif(isdefined("attributes.priority_cat"),"attributes.priority_cat",DE(""))#' ,
                    special_definition : '#iif(isdefined("attributes.special_definition"),"attributes.special_definition",DE(""))#' ,
                    project_status: '#iif(isdefined("attributes.project_status"),"attributes.project_status",DE(""))#' ,
                    process_catid: '#iif(isdefined("attributes.process_catid"),"attributes.process_catid",DE(""))#' ,
                    pro_employee_id: '#iif(isdefined("attributes.pro_employee_id"),"attributes.pro_employee_id",DE(""))#',
                    pro_company_id: '#iif(isdefined("attributes.pro_company_id"),"attributes.pro_company_id",DE(""))#' ,
                    pro_partner_id: '#iif(isdefined("attributes.pro_partner_id"),"attributes.pro_partner_id",DE(""))#' ,
                    start_date: '#iif(isdefined("attributes.start_date"),"attributes.start_date",DE(""))#' ,
                    finish_date: '#iif(isdefined("attributes.finish_date"),"attributes.finish_date",DE(""))#' ,
                    company: '#iif(isdefined("attributes.company"),"attributes.company",DE(""))#' ,
                    company_id: '#iif(isdefined("attributes.company_id"),"attributes.company_id",DE(""))#' ,
                    consumer_id: '#iif(isdefined("attributes.consumer_id"),"attributes.consumer_id",DE(""))#' ,
                    expense_code: '#iif(isdefined("attributes.expense_code"),"attributes.expense_code",DE(""))#' ,
                    expense_code_name: '#iif(isdefined("attributes.expense_code_name"),"attributes.expense_code_name",DE(""))#' ,
                    ordertype: '#iif(isdefined("attributes.ordertype"),"attributes.ordertype",DE(""))#' ,
                    workgroup_id:'#iif(isdefined("attributes.workgroup_id"),"attributes.workgroup_id",DE(""))#',
                    ismyhome:'#iif(isdefined("ismyhome"),"ismyhome",DE(""))#',
                    startrow:'#iif(isdefined("attributes.startrow"),"attributes.startrow",DE(""))#',
                    maxrows:'#iif(isdefined("attributes.maxrows"),"attributes.maxrows",DE(""))#',
                    pro_employee: '#iif(isdefined("attributes.pro_employee"),"attributes.pro_employee",DE(""))#',
                    project_id: '#iif(isdefined("attributes.project_id"),"attributes.project_id",DE(""))#'
                );
        </cfscript>
    <cfelse>
        <cfset get_projects.query_count=0>
    </cfif>
    <cfquery name="GET_SPECIAL_DEF" datasource="#DSN#">
        SELECT SPECIAL_DEFINITION_ID,SPECIAL_DEFINITION FROM SETUP_SPECIAL_DEFINITION WHERE SPECIAL_DEFINITION_TYPE = 6
    </cfquery>
    <cfquery name="GET_PROCESS_CAT" datasource="#DSN#">
        SELECT
           DISTINCT 
           SMC.MAIN_PROCESS_CAT_ID,
           SMC.MAIN_PROCESS_CAT
        FROM 
           SETUP_MAIN_PROCESS_CAT SMC,
           SETUP_MAIN_PROCESS_CAT_ROWS SMR,
           EMPLOYEE_POSITIONS
        WHERE
           SMC.MAIN_PROCESS_CAT_ID = SMR.MAIN_PROCESS_CAT_ID AND
           EMPLOYEE_POSITIONS.POSITION_CODE =<cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.position_code#"> AND 
           (EMPLOYEE_POSITIONS.POSITION_CAT_ID = SMR.MAIN_POSITION_CAT_ID OR EMPLOYEE_POSITIONS.POSITION_CODE = SMR.MAIN_POSITION_CODE)
    </cfquery>
    <cfquery name="GET_PROCURRENCY" datasource="#DSN#">
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
            PT.FACTION LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%project.projects%">
        ORDER BY
            PTR.LINE_NUMBER
    </cfquery>
    <cfquery name="GET_WORKGROUPS" datasource="#DSN#">
        SELECT 
            WORKGROUP_ID,
            WORKGROUP_NAME
        FROM 
            WORK_GROUP
        WHERE
            STATUS = 1
            AND HIERARCHY IS NOT NULL
        ORDER BY 
            HIERARCHY
    </cfquery>
    <cfinclude template="../query/get_priority.cfm">
    <cfparam name="attributes.totalrecords" default="#get_projects.query_count#">
    
    <cfsavecontent variable="title"><cf_get_lang dictionary_id='58015.Projeler'></cfsavecontent>
    <div class="col col-12 col-md-12 col-sm-12 col-xs-12">
        <cf_box>
            <cfform name="search_1" id="search_1" method="post" action="#request.self#?fuseaction=project.projects">
                <input type="hidden" name="is_form_submitted" id="is_form_submitted" value="1">
                <cf_box_search>
                    <div class="form-group" id="item-keyword">
                        <cfsavecontent variable="message"><cf_get_lang dictionary_id='57460.Filtre'></cfsavecontent>
                        <cfinput type="text" placeholder="#message#" name="keyword" id="keyword" value="#attributes.keyword#" >
                    </div>
                    <div class="form-group" id="item-ordertype">
                        <select name="ordertype" id="ordertype">
                            <option value="1" <cfif isdefined("attributes.ordertype") and attributes.ordertype eq 1>selected</cfif>><cf_get_lang dictionary_id ='38477.is No ya göre Azalan'></option>                     
                            <option value="2" <cfif isdefined("attributes.ordertype") and attributes.ordertype eq 2>selected</cfif>><cf_get_lang dictionary_id ='38478.No ya göre Artan'></option>
                            <option value="3" <cfif isdefined("attributes.ordertype") and attributes.ordertype eq 3>selected</cfif>><cf_get_lang dictionary_id ='38479.Ad a Gore Azalan'></option>
                            <option value="4" <cfif isdefined("attributes.ordertype") and attributes.ordertype eq 4>selected</cfif>><cf_get_lang dictionary_id ='38480.Ad a Gore Artan'></option>
                            <option value="5" <cfif isdefined("attributes.ordertype") and attributes.ordertype eq 5>selected</cfif>><cf_get_lang dictionary_id ='38330.Baslangic Tarihine Gre Azalan'></option>
                            <option value="6" <cfif isdefined("attributes.ordertype") and attributes.ordertype eq 6>selected</cfif>><cf_get_lang dictionary_id ='38331.Baslangic Tarihine Gre  Artan'></option>
                            <option value="7" <cfif isdefined("attributes.ordertype") and attributes.ordertype eq 7>selected</cfif>><cf_get_lang dictionary_id ='38332.Bitis Tarihine Gre Azalan'></option>
                            <option value="8" <cfif isdefined("attributes.ordertype") and attributes.ordertype eq 8>selected</cfif>><cf_get_lang dictionary_id ='38333.Bitis Tarihine Gre  Artan'></option>
                        </select>
                    </div>
                    <div class="form-group" id="item-project_status">
                        <select name="project_status" id="project_status">
                            <option value="0" <cfif attributes.project_status eq 0>selected</cfif>><cf_get_lang dictionary_id='30111.Durumu'></option>
                            <option value="1" <cfif attributes.project_status eq 1>selected</cfif>><cf_get_lang dictionary_id='57493.Aktif'></option>
                            <option value="-1" <cfif attributes.project_status eq -1>selected</cfif>><cf_get_lang dictionary_id='57494.Pasif'></option>
                        </select>
                    </div>
                    <div class="form-group small">
                        <cfsavecontent variable="message"><cf_get_lang dictionary_id='57537.Kayıt Sayısı Hatalı!'></cfsavecontent>
                        <cfinput type="text" name="maxrows" id="maxrows" value="#attributes.maxrows#" required="yes" validate="integer" range="1,999" message="#message#" maxlength="3" >
                    </div>
                    <div class="form-group">
                        <cf_wrk_search_button search_function='' button_type="4">
                        <cf_workcube_file_action pdf='1' mail='1' doc='1' print='1'>
                    </div>
                </cf_box_search>
                <cf_box_search_detail>
                    <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
                        <div class="form-group" id="item-currency">
                            <label><cf_get_lang dictionary_id='57482.Aşama'></label>
                            <select name="currency" id="currency" >
                                <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                <cfoutput query="get_procurrency">
                                    <option value="#process_row_id#"<cfif attributes.currency eq process_row_id>selected</cfif>>#stage#</option>
                                </cfoutput>
                            </select>
                        </div>
                        <div class="form-group" id="item-process_catid">
                            <label><cf_get_lang dictionary_id='57486.Kategori'></label>
                            <select name="process_catid" id="process_catid">
                                <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                <cfoutput query="get_process_cat"> 
                                    <option value="#main_process_cat_id#" <cfif attributes.process_catid is main_process_cat_id>selected</cfif>>#main_process_cat#</option>
                                </cfoutput> 
                            </select>
                        </div>
                        <div class="form-group" id="item-pro_employee_id">
                            <label><cf_get_lang dictionary_id='57569.Görevli'></label>
                            <div class="input-group">
                                <cfoutput>
                                <input type="text" name="pro_employee" id="pro_employee" value="<cfif isdefined('attributes.pro_employee') and len(attributes.pro_employee)>#attributes.pro_employee#</cfif>" onFocus="AutoComplete_Create('pro_employee','MEMBER_NAME,MEMBER_PARTNER_NAME2','MEMBER_PARTNER_NAME2,MEMBER_NAME2','get_member_autocomplete','\'1,3\',0,0','COMPANY_ID,PARTNER_ID,EMPLOYEE_ID','pro_company_id,pro_partner_id,pro_employee_id','','3','200','get_company()');" passthrough="readonly">
                                <span class="input-group-addon icon-ellipsis btnPointer" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_positions&field_partner=search_1.pro_partner_id&field_emp_id=search_1.pro_employee_id&field_code=search_1.project_pos_code&field_comp_id=search_1.pro_company_id&field_name=search_1.pro_employee&select_list=1,2');"></span>
                                <input type="hidden" name="project_pos_code" id="project_pos_code" value="">
                                <input type="hidden" name="pro_employee_id" id="pro_employee_id" value="#attributes.pro_employee_id#">
                                <input type="hidden" name="pro_company_id" id="pro_company_id" value="#attributes.pro_company_id#">
                                <input type="hidden" name="pro_partner_id" id="pro_partner_id" value="#attributes.pro_partner_id#">
                                </cfoutput>
                            </div>
                        </div>
                    </div>
                    <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="2" sort="true">
                        <div class="form-group" id="item-start_date">
                            <label><cf_get_lang dictionary_id='57655.Başlama Tarihi'></label>
                            <div class="input-group">
                                <cfsavecontent variable="message"><cf_get_lang dictionary_id='57782.Lütfen Tarih Değerini Kontrol Ediniz'> !</cfsavecontent>
                                <cfinput type="text" name="start_date" id="start_date" value="#dateformat(attributes.start_date,dateformat_style)#" validate="#validate_style#" message="#message#" maxlength="10"  >
                                <span class="input-group-addon"><cf_wrk_date_image date_field="start_date"></span>    
                            </div>  
                        </div>
                        <div class="form-group" id="item-finish_date">
                            <label><cf_get_lang dictionary_id='57700.Bitiş Tarihi'></label>
                            <div class="input-group">   
                                <cfsavecontent variable="message"><cf_get_lang dictionary_id='57782.Lütfen Tarih Değerini Kontrol Ediniz'> !</cfsavecontent>
                                <cfinput type="text" name="finish_date" id="finish_date" value="#dateformat(attributes.finish_date,dateformat_style)#" validate="#validate_style#"  message="#message#" maxlength="10">
                                <span class="input-group-addon"><cf_wrk_date_image date_field="finish_date"></span>            
                            </div>
                        </div>
                        <div class="form-group" id="item-priority_cat">
                            <label><cf_get_lang dictionary_id='57485.Oncelik'></label>
                            <select name="priority_cat" id="priority_cat" >
                                <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                <cfoutput query="get_cats">
                                    <option value="#priority_id#"<cfif attributes.priority_cat is priority_id>selected</cfif>>#priority#</option>
                                </cfoutput>
                            </select>
                        </div>
                    </div>
                    <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="3" sort="true">
                        <div class="form-group" id="item-workgroup_id">
                            <label><cf_get_lang dictionary_id='58140.İş Grubu'></label>
                            <select name="workgroup_id" id="workgroup_id">				  
                                <option value=""><cf_get_lang dictionary_id='58140.İş Grubu'></option>
                                <cfoutput query="get_workgroups">
                                <option value="#workgroup_id#" <cfif isdefined("attributes.workgroup_id") and workgroup_id eq attributes.workgroup_id>selected</cfif>>#workgroup_name#</option>
                                </cfoutput>
                            </select>                 	
                        </div>
                        <div class="form-group" id="item-consumer_id">
                            <label><cf_get_lang dictionary_id='57658.Üye'></label>
                            <div class="input-group">
                                <input type="hidden" name="consumer_id" id="consumer_id" <cfif len(attributes.company)> value="<cfoutput>#attributes.consumer_id#</cfoutput>"</cfif>>			
                                <input type="hidden" name="company_id" id="company_id" <cfif len(attributes.company)> value="<cfoutput>#attributes.company_id#</cfoutput>"</cfif>>
                                <input type="text" name="company" id="company" value="<cfif len(attributes.company) ><cfoutput>#attributes.company#</cfoutput></cfif>" onfocus="AutoComplete_Create('company','MEMBER_NAME,MEMBER_PARTNER_NAME','MEMBER_NAME,MEMBER_PARTNER_NAME','get_member_autocomplete','\'1,2\',0,0,0','CONSUMER_ID,COMPANY_ID','consumer_id,company_id','','3','250');" autocomplete="off">
                                <span class="input-group-addon icon-ellipsis btnPointer" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_list_pars&select_list=2,3&field_comp_name=search_1.company&field_comp_id=search_1.company_id&field_consumer=search_1.consumer_id&field_member_name=search_1.company</cfoutput>')"></span>
                            </div>
                        </div>
                    </div>
                    <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="4s" sort="true">
                        <div class="form-group" id="item-expense_code">
                            <label><cf_get_lang dictionary_id='58235.Masraf Merkezi'></label>
                            <div class="input-group">
                                <input type="hidden" name="expense_code" id="expense_code"  value="<cfif len(attributes.expense_code_name)><cfoutput>#attributes.expense_code#</cfoutput></cfif>">
                                <input type="text" name="expense_code_name" id="expense_code_name" value="<cfif len(attributes.expense_code_name)><cfoutput>#attributes.expense_code_name#</cfoutput></cfif>" onfocus="AutoComplete_Create('expense_code_name','EXPENSE,EXPENSE_CODE','EXPENSE,EXPENSE_CODE','get_expense_center','<cfif session.ep.isBranchAuthorization>1<cfelse>0</cfif>','EXPENSE_code','expense_code','','3','150');" autocomplete="off">
                                <span class="input-group-addon icon-ellipsis btnPointer" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_expense_center&field_code=search_1.expense_code&field_name=search_1.expense_code_name</cfoutput>');"></span>
                            </div>
                        </div>
                        <div class="form-group" id="item-special_definition">
                            <label><cf_get_lang dictionary_id='38125.Özel Tanım'></label>
                            <select name="special_definition" id="special_definition" >
                                <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                <cfoutput query="get_special_def">
                                    <option value="#special_definition_id#" <cfif attributes.special_definition eq special_definition_id >selected="selected"</cfif>>#special_definition#</option>
                                </cfoutput>
                            </select>
                        </div>
                    </div>
                </cf_box_search_detail>
            </cfform>
        </cf_box>
        <cf_box title="#title#" uidrop="1" hide_table_column="1" woc_setting = "#{ checkbox_name : 'print_project_id',  print_type : 310 }#">
            <cf_grid_list>
                <thead>
                    <tr>
                        <th style="text-align:center; width:20px" ><cf_get_lang dictionary_id='57487.no'></th>
                        <th nowrap="nowrap">P.<cf_get_lang dictionary_id='57487.No'></th>
                        <th class="form-title" nowrap="nowrap">S.<cf_get_lang dictionary_id='57487.No'></th>
                        <th><cf_get_lang dictionary_id='58015.projeler'></th>
                        <th><cf_get_lang dictionary_id='57486.Kategori'></th>
                        <th><cf_get_lang dictionary_id='57574.şirket'></th>
                        <th><cf_get_lang dictionary_id='57569.görevli'></th>
                        <th><cf_get_lang dictionary_id='57485.Öncelik'></th>
                        <th><cf_get_lang dictionary_id='58053.Başlangıç tarihi'></th>
                        <th><cf_get_lang dictionary_id='57700.bitiş tarihi'></th>
                        <th><cf_get_lang dictionary_id='57482.Aşama'></th>
                        <th width="20" style="text-align:right" >%</th>
                        <!-- sil -->
                        <!---<th class="header_icn_none"><a href="<cfoutput>#request.self#</cfoutput>?fuseaction=project.addpro"><img src="/images/plus_list.gif" title="<cf_get_lang dictionary_id ='170.Ekle'>" border="0"></a></th>--->
                        <th class="header_icn_none text-center" width="20"><a href="<cfoutput>#request.self#</cfoutput>?fuseaction=project.projects&event=add"><i class="fa fa-plus" title="<cf_get_lang dictionary_id ='57582.Ekle'>" alt="<cf_get_lang dictionary_id ='57582.Ekle'>"></i></a></th>
                        <th width="20" class="text-center header_icn_none">
                            <input type="checkbox" name="allSelectDemand" id="allSelectDemand" onclick="wrk_select_all('allSelectDemand','print_project_id');">
                        </th>
                        <!-- sil -->	
                    </tr>
                </thead>
                <tbody>
                    <cfif get_projects.query_count gt 0>
                        <cfoutput query="get_projects">
                            <tr>
                                <td style="text-align:center">#rownum#</td>
                                <td nowrap="nowrap"><a href="#request.self#?fuseaction=project.projects&event=det&id=#project_id#" class="tableyazi">#project_number#</a></td>
                                <td>#agreement_no#</td>
                                <td><a href="#request.self#?fuseaction=project.projects&event=det&id=#project_id#" class="tableyazi">#get_project_name(project_id,0)#</a></td>
                                <td>#main_process_cat#</td>
                                <td><cfif len(company_id)>
                                        <a href="javascript://"  onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_com_det&company_id=#company_id#');">#fullname#</a>-
                                        <a href="javascript://" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_par_det&par_id=#PARTNER_ID#');">#company_partner_name# #company_partner_surname#</a>
                                    <cfelseif len(consumer_id)>
                                        <a href="javascript://"  onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_con_det&con_id=#consumer_id#');">#consumer_name# #consumer_surname#</a>
                                    </cfif>
                                </td>
                                <td><cfif len(project_emp_id)>
                                        <a href="javascript://"  onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_emp_det&emp_id=#project_emp_id#');">#employee_name# #employee_surname#</a>
                                    </cfif>
                                    <cfif len(outsrc_partner_id)>
                                        <a href="javascript://" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_com_det&company_id=#outsrc_cmp_id#');">#nickname_outsrc#</a>-
                                        <a href="javascript://" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_par_det&par_id=#outsrc_partner_id#');">#company_partner_name_outsrc# #company_partner_surname_outsrc#</a>
                                    </cfif>
                                </td>
                                <td><font color="#get_projects.color#">#priority#</font></td>
                                <td>#dateformat(get_projects.target_start,dateformat_style)#</td>
                                <td>#dateformat(get_projects.target_finish,dateformat_style)#</td>
                                <td><font color="#get_projects.color#"><cfif len(stage)>#stage#<cfelse><cf_get_lang dictionary_id="29815.Aşamasız"></cfif></font></td>
                                <td style="text-align:right">#tlformat(complete_rate,0)#</td>
                                <!-- sil -->
                                <!---<td style="text-align:center;"><a href="#request.self#?fuseaction=project.prodetail&id=#project_id#" class="tableyazi"><img src="/images/update_list.gif" title="<cf_get_lang dictionary_id ='52.Güncelle'>" border="0"></a></td>--->
                                <td><a href="#request.self#?fuseaction=project.projects&event=upd&id=#PROJECT_ID#"><i class="fa fa-pencil" title="<cf_get_lang dictionary_id ='57464.Güncelle'>"></i></a></td>
                                <td><input type="checkbox" name="print_project_id" id="print_project_id"  value="#PROJECT_ID#"></td>
                                <!-- sil -->
                            </tr>
                        </cfoutput>
                    <cfelse>
                        <tr>
                            <td colspan="13"><cfif isdefined("attributes.is_form_submitted")><cf_get_lang dictionary_id='57484.Kayıt Bulunamadı'> !<cfelse><cf_get_lang dictionary_id='57701.Filtre Ediniz '>!</cfif></td>
                        </tr>
                    </cfif>
                </tbody>
            </cf_grid_list>
            <cfif attributes.totalrecords gt attributes.maxrows>
                <cfset url_str = "is_form_submitted=1">
                <cfif Len(attributes.keyword)><cfset url_str = "#url_str#&keyword=#attributes.keyword#"></cfif>
                <cfif Len(attributes.project_id)><cfset url_str = "#url_str#&project_id=#attributes.project_id#"></cfif>
                <cfif Len(attributes.currency)><cfset url_str = "#url_str#&currency=#attributes.currency#"></cfif>
                <cfif Len(attributes.priority_cat)><cfset url_str = "#url_str#&priority_cat=#attributes.priority_cat#"></cfif>
                <cfif Len(attributes.project_status)><cfset url_str = "#url_str#&project_status=#attributes.project_status#"></cfif>
                <cfif Len(attributes.process_catid)><cfset url_str = "#url_str#&process_catid=#attributes.process_catid#"></cfif>
                <cfif Len(attributes.start_date)><cfset url_str = "#url_str#&start_date=#attributes.start_date#"></cfif>
                <cfif Len(attributes.finish_date)><cfset url_str = "#url_str#&finish_date=#attributes.finish_date#"></cfif>
                <cfif Len(attributes.ordertype)><cfset url_str = "#url_str#&ordertype=#attributes.ordertype#"></cfif>
                <cfif Len(attributes.special_definition)><cfset url_str = "#url_str#&special_definition=#attributes.special_definition#"></cfif>
                <cfif Len(attributes.expense_code) and Len(attributes.expense_code_name)>
                    <cfset url_str = "#url_str#&expense_code=#attributes.expense_code#&expense_code_name=#attributes.expense_code_name#">
                </cfif>
                <cfif Len(attributes.pro_employee_id) and Len(attributes.pro_employee)>
                    <cfset url_str = "#url_str#&pro_employee_id=#attributes.pro_employee_id#&pro_employee=#attributes.pro_employee#">
                </cfif>
                <cfif Len(attributes.pro_partner_id) and Len(attributes.pro_partner_id)>
                    <cfset url_str = "#url_str#&pro_partner_id=#attributes.pro_partner_id#&pro_employee=#attributes.pro_partner_id#">
                </cfif>
                <cfif Len(attributes.pro_company_id) and Len(attributes.pro_company_id)>
                    <cfset url_str = "#url_str#&pro_company_id=#attributes.pro_company_id#&pro_employee=#attributes.pro_company_id#">
                </cfif>
                <cfif Len(attributes.company_id) and Len(attributes.company)>
                    <cfset url_str = "#url_str#&company_id=#attributes.company_id#&company=#attributes.company#">
                </cfif>
                <cfif Len(attributes.consumer_id) and Len(attributes.company)>
                    <cfset url_str = "#url_str#&consumer_id=#attributes.consumer_id#&company=#attributes.company#">
                </cfif>
                <cfif isdefined("attributes.workgroup_id") and len(attributes.workgroup_id)>
                    <cfset url_str="#url_str#&workgroup_id=#attributes.workgroup_id#">
                </cfif>
                <cf_paging page="#attributes.page#"
                maxrows="#attributes.maxrows#"
                totalrecords="#attributes.totalrecords#"
                startrow="#attributes.startrow#"
                adres="project.projects&#url_str#">
        
            </cfif>
        </cf_box>
    </div>
    <script type="text/javascript">
       document.getElementById('keyword').focus();
    </script>
    <br/>
    
    <cfsetting showdebugoutput="yes">