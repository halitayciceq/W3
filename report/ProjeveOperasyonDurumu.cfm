<cf_xml_page_edit fuseact="project.project_operation_report">
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.project_no" default="">
<cfparam name="attributes.project_responsible" default="">
<cfparam name="attributes.project_responsible_id" default="">
<cfparam name="attributes.category_id" default="">
<cfparam name="attributes.priority_id" default="">
<cfparam name="attributes.start_date" default="">
<cfparam name="attributes.finish_date" default="">
<cfparam name="attributes.country" default="">
<cfparam name="attributes.page" default=1>
<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>

<cfif isdefined("attributes.start_date") and len(attributes.start_date)>
    <cf_date tarih = "attributes.start_date">
</cfif>
<cfif isdefined("attributes.finish_date") and len(attributes.finish_date)>
    <cf_date tarih = "attributes.finish_date">
</cfif>

<!--- Ana sorgu --->
<cfif isdefined("attributes.is_form_submitted")>
    <cfquery name="GET_PROJECT_OPERATIONS" datasource="#DSN#">
        SELECT 
            P.PROJECT_ID,
            P.PROJECT_NUMBER,
            P.PROJECT_HEAD,
            P.TARGET_START,
            P.TARGET_FINISH,
            P.COMPLETE_RATE,
            P.PROJECT_EMP_ID,
            P.PROCESS_CAT,
            P.PRO_PRIORITY_ID,
            P.PRO_CURRENCY_ID,
            P.COMPANY_ID,
            P.CONSUMER_ID,
            
            -- Personel bilgileri
            EMP.EMPLOYEE_NAME,
            EMP.EMPLOYEE_SURNAME,
            
            -- Kategori bilgileri
            SMPC.MAIN_PROCESS_CAT,
            
            -- Öncelik bilgileri
            SP.PRIORITY,
            
            -- Aşama bilgileri
            PTR.STAGE,
            
            -- Müşteri bilgileri (şirket veya tüketici olabilir)
            CASE 
                WHEN P.COMPANY_ID IS NOT NULL THEN CP.NICKNAME
                WHEN P.CONSUMER_ID IS NOT NULL THEN CON.CONSUMER_NAME + ' ' + CON.CONSUMER_SURNAME
                ELSE 'Belirtilmemiş'
            END AS CUSTOMER_NAME,
            
            -- Ülke bilgisi
            CASE 
                WHEN P.COMPANY_ID IS NOT NULL THEN ADDR_C.COUNTRY
                WHEN P.CONSUMER_ID IS NOT NULL THEN ADDR_CON.COUNTRY  
                ELSE 'TR'
            END AS COUNTRY,
            
            -- Kalan zaman hesaplama
            CASE 
                WHEN P.TARGET_FINISH > GETDATE() AND P.COMPLETE_RATE < 100
                THEN DATEDIFF(day, GETDATE(), P.TARGET_FINISH)
                WHEN P.COMPLETE_RATE >= 100 
                THEN 0
                ELSE DATEDIFF(day, P.TARGET_FINISH, GETDATE()) * -1
            END AS REMAINING_DAYS,
            
            -- Görev sayısı
            (SELECT COUNT(*) FROM PRO_WORKS PW WHERE PW.PROJECT_ID = P.PROJECT_ID) AS TASK_COUNT,
            
            -- Tamamlanan görev sayısı  
            (SELECT COUNT(*) FROM PRO_WORKS PW WHERE PW.PROJECT_ID = P.PROJECT_ID AND PW.TO_COMPLETE = 1) AS COMPLETED_TASKS
            
        FROM 
            PRO_PROJECTS P
            LEFT JOIN EMPLOYEES EMP ON P.PROJECT_EMP_ID = EMP.EMPLOYEE_ID
            LEFT JOIN SETUP_MAIN_PROCESS_CAT SMPC ON P.PROCESS_CAT = SMPC.MAIN_PROCESS_CAT_ID  
            LEFT JOIN SETUP_PRIORITY SP ON P.PRO_PRIORITY_ID = SP.PRIORITY_ID
            LEFT JOIN PROCESS_TYPE_ROWS PTR ON P.PRO_CURRENCY_ID = PTR.PROCESS_ROW_ID
            LEFT JOIN COMPANY_PARTNER CP ON P.COMPANY_ID = CP.COMPANY_ID
            LEFT JOIN CONSUMERS CON ON P.CONSUMER_ID = CON.CONSUMER_ID
            LEFT JOIN COMPANY_PARTNER_ADDRESS ADDR_C ON P.COMPANY_ID = ADDR_C.COMPANY_ID AND ADDR_C.IS_DEFAULT = 1
            LEFT JOIN CONSUMER_ADDRESS ADDR_CON ON P.CONSUMER_ID = ADDR_CON.CONSUMER_ID AND ADDR_CON.IS_DEFAULT = 1
        WHERE 
            1 = 1
            <cfif len(attributes.keyword)>
                AND (P.PROJECT_NUMBER LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.keyword#%">
                     OR P.PROJECT_HEAD LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.keyword#%">)
            </cfif>
            <cfif len(attributes.project_no)>
                AND P.PROJECT_NUMBER LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.project_no#%">
            </cfif>
            <cfif len(attributes.project_responsible_id)>
                AND P.PROJECT_EMP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.project_responsible_id#">
            </cfif>
            <cfif len(attributes.category_id)>
                AND P.PROCESS_CAT = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.category_id#">
            </cfif>
            <cfif len(attributes.priority_id)>
                AND P.PRO_PRIORITY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.priority_id#">
            </cfif>
            <cfif len(attributes.start_date)>
                AND P.TARGET_START >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.start_date#">
            </cfif>
            <cfif len(attributes.finish_date)>
                AND P.TARGET_FINISH <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.finish_date#">
            </cfif>
        ORDER BY 
            P.PROJECT_NUMBER DESC
    </cfquery>
<cfelse>
    <cfset GET_PROJECT_OPERATIONS.recordcount = 0>
</cfif>

<!--- Dropdown sorguları --->
<cfquery name="GET_CATEGORIES" datasource="#DSN#">
    SELECT MAIN_PROCESS_CAT_ID, MAIN_PROCESS_CAT 
    FROM SETUP_MAIN_PROCESS_CAT 
    ORDER BY MAIN_PROCESS_CAT
</cfquery>

<cfquery name="GET_PRIORITIES" datasource="#DSN#">
    SELECT PRIORITY_ID, PRIORITY 
    FROM SETUP_PRIORITY 
    ORDER BY PRIORITY_ID
</cfquery>

<cfparam name="attributes.totalrecords" default="#GET_PROJECT_OPERATIONS.recordcount#">

<cfsavecontent variable="title">Proje ve Operasyon Durumu</cfsavecontent>

<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box>
        <cfform name="search_form" id="search_form" method="post" action="#request.self#?fuseaction=project.project_operation_report">
            <input type="hidden" name="is_form_submitted" id="is_form_submitted" value="1">
            <cf_box_search>
                <div class="form-group" id="item-keyword">
                    <cfinput type="text" placeholder="Proje No / Proje Adı Filtresi" name="keyword" id="keyword" value="#attributes.keyword#">
                </div>
                <div class="form-group" id="item-project_responsible">
                    <div class="input-group">
                        <input type="text" name="project_responsible" id="project_responsible" value="<cfif len(attributes.project_responsible)><cfoutput>#attributes.project_responsible#</cfoutput></cfif>" placeholder="Proje Sorumlusu" onFocus="AutoComplete_Create('project_responsible','EMPLOYEE_NAME,EMPLOYEE_SURNAME','EMPLOYEE_NAME,EMPLOYEE_SURNAME','get_emp_autocomplete','0','EMPLOYEE_ID','project_responsible_id','','3','200');" readonly>
                        <span class="input-group-addon icon-ellipsis btnPointer" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_positions&field_emp_id=search_form.project_responsible_id&field_name=search_form.project_responsible&select_list=1');"></span>
                        <input type="hidden" name="project_responsible_id" id="project_responsible_id" value="<cfoutput>#attributes.project_responsible_id#</cfoutput>">
                    </div>
                </div>
                <div class="form-group small">
                    <cfinput type="text" name="maxrows" id="maxrows" value="#attributes.maxrows#" required="yes" validate="integer" range="1,999" message="Kayıt Sayısı Hatalı!" maxlength="3">
                </div>
                <div class="form-group">
                    <cf_wrk_search_button search_function='' button_type="4">
                </div>
            </cf_box_search>
            <cf_box_search_detail>
                <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
                    <div class="form-group" id="item-category_id">
                        <label>Kategori</label>
                        <select name="category_id" id="category_id">
                            <option value="">Seçiniz</option>
                            <cfoutput query="GET_CATEGORIES">
                                <option value="#MAIN_PROCESS_CAT_ID#" <cfif attributes.category_id eq MAIN_PROCESS_CAT_ID>selected</cfif>>#MAIN_PROCESS_CAT#</option>
                            </cfoutput>
                        </select>
                    </div>
                    <div class="form-group" id="item-priority_id">
                        <label>Öncelik</label>
                        <select name="priority_id" id="priority_id">
                            <option value="">Seçiniz</option>
                            <cfoutput query="GET_PRIORITIES">
                                <option value="#PRIORITY_ID#" <cfif attributes.priority_id eq PRIORITY_ID>selected</cfif>>#PRIORITY#</option>
                            </cfoutput>
                        </select>
                    </div>
                </div>
                <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="2" sort="true">
                    <div class="form-group" id="item-start_date">
                        <label>Başlangıç Tarihi</label>
                        <div class="input-group">
                            <cfinput type="text" name="start_date" id="start_date" value="#dateformat(attributes.start_date,dateformat_style)#" validate="#validate_style#" message="Lütfen Tarih Değerini Kontrol Ediniz!" maxlength="10">
                            <span class="input-group-addon"><cf_wrk_date_image date_field="start_date"></span>
                        </div>
                    </div>
                    <div class="form-group" id="item-finish_date">
                        <label>Bitiş Tarihi</label>
                        <div class="input-group">
                            <cfinput type="text" name="finish_date" id="finish_date" value="#dateformat(attributes.finish_date,dateformat_style)#" validate="#validate_style#" message="Lütfen Tarih Değerini Kontrol Ediniz!" maxlength="10">
                            <span class="input-group-addon"><cf_wrk_date_image date_field="finish_date"></span>
                        </div>
                    </div>
                </div>
            </cf_box_search_detail>
        </cfform>
    </cf_box>
    
    <cf_box title="#title#" uidrop="1" hide_table_column="1">
        <cf_grid_list>
            <thead>
                <tr>
                    <th style="text-align:center; width:20px">No</th>
                    <th nowrap="nowrap">Proje No</th>
                    <th>Proje Adı</th>
                    <th style="text-align:center; width:50px">Ülke</th>
                    <th>Arnikon Görevli</th>
                    <th>Kategori</th>
                    <th>Aşama</th>
                    <th>Öncelik</th>
                    <th style="text-align:center; width:90px">Başlangıç</th>
                    <th style="text-align:center; width:90px">Bitiş</th>
                    <th style="text-align:center; width:70px">Kalan Zaman</th>
                    <th style="text-align:center; width:60px">Tamamlanma</th>
                    <th>Görevler</th>
                </tr>
            </thead>
            <tbody>
                <cfif GET_PROJECT_OPERATIONS.recordcount gt 0>
                    <cfoutput query="GET_PROJECT_OPERATIONS">
                        <tr>
                            <td style="text-align:center">#currentrow#</td>
                            <td nowrap="nowrap">
                                <a href="#request.self#?fuseaction=project.projects&event=det&id=#PROJECT_ID#" class="tableyazi" target="_blank">
                                    #PROJECT_NUMBER#
                                </a>
                            </td>
                            <td>
                                <a href="#request.self#?fuseaction=project.projects&event=det&id=#PROJECT_ID#" class="tableyazi" target="_blank">
                                    #PROJECT_HEAD#
                                </a>
                            </td>
                            <td style="text-align:center">
                                <cfif len(COUNTRY)>
                                    <span class="label label-info" title="#CUSTOMER_NAME#">#COUNTRY#</span>
                                <cfelse>
                                    <span class="label label-default">TR</span>
                                </cfif>
                            </td>
                            <td>
                                <cfif len(EMPLOYEE_NAME)>
                                    #EMPLOYEE_NAME# #EMPLOYEE_SURNAME#
                                <cfelse>
                                    <span class="text-muted">Atanmamış</span>
                                </cfif>
                            </td>
                            <td>
                                <cfif len(MAIN_PROCESS_CAT)>
                                    #MAIN_PROCESS_CAT#
                                <cfelse>
                                    <span class="text-muted">-</span>
                                </cfif>
                            </td>
                            <td>
                                <cfif len(STAGE)>
                                    <span class="label label-primary">#STAGE#</span>
                                <cfelse>
                                    <span class="label label-default">Aşamasız</span>
                                </cfif>
                            </td>
                            <td style="text-align:center">
                                <cfif len(PRIORITY)>
                                    <cfset priority_class = "label-default">
                                    <cfif findNoCase("yüksek", PRIORITY)><cfset priority_class = "label-danger"></cfif>
                                    <cfif findNoCase("orta", PRIORITY)><cfset priority_class = "label-warning"></cfif>
                                    <cfif findNoCase("düşük", PRIORITY)><cfset priority_class = "label-success"></cfif>
                                    <span class="label #priority_class#">#PRIORITY#</span>
                                <cfelse>
                                    <span class="text-muted">-</span>
                                </cfif>
                            </td>
                            <td style="text-align:center">
                                <cfif isDate(TARGET_START)>
                                    #dateformat(TARGET_START, dateformat_style)#
                                <cfelse>
                                    <span class="text-muted">-</span>
                                </cfif>
                            </td>
                            <td style="text-align:center">
                                <cfif isDate(TARGET_FINISH)>
                                    #dateformat(TARGET_FINISH, dateformat_style)#
                                <cfelse>
                                    <span class="text-muted">-</span>
                                </cfif>
                            </td>
                            <td style="text-align:center">
                                <cfif COMPLETE_RATE ge 100>
                                    <span class="label label-success">Tamamlandı</span>
                                <cfelseif REMAINING_DAYS gt 0>
                                    <span class="label label-info">#REMAINING_DAYS# gün</span>
                                <cfelseif REMAINING_DAYS eq 0>
                                    <span class="label label-warning">Bugün</span>
                                <cfelse>
                                    <span class="label label-danger">#abs(REMAINING_DAYS)# gün gecikti</span>
                                </cfif>
                            </td>
                            <td style="text-align:center">
                                <div class="progress" style="margin-bottom:0; height:18px;">
                                    <div class="progress-bar 
                                        <cfif COMPLETE_RATE ge 100>progress-bar-success
                                        <cfelseif COMPLETE_RATE ge 75>progress-bar-info  
                                        <cfelseif COMPLETE_RATE ge 50>progress-bar-warning
                                        <cfelse>progress-bar-danger</cfif>" 
                                        style="width: #COMPLETE_RATE#%;">
                                        <small>%#COMPLETE_RATE#</small>
                                    </div>
                                </div>
                            </td>
                            <td>
                                <cfquery name="GET_PROJECT_TASKS" datasource="#DSN#">
                                    SELECT TOP 5
                                        PW.WORK_HEAD,
                                        PW.TARGET_FINISH,
                                        PW.TO_COMPLETE,
                                        PTR.STAGE AS WORK_STAGE
                                    FROM 
                                        PRO_WORKS PW
                                        LEFT JOIN PROCESS_TYPE_ROWS PTR ON PW.WORK_CURRENCY_ID = PTR.PROCESS_ROW_ID
                                    WHERE 
                                        PW.PROJECT_ID = #PROJECT_ID#
                                    ORDER BY 
                                        CASE WHEN PW.TO_COMPLETE = 1 THEN 1 ELSE 0 END,
                                        PW.TARGET_FINISH ASC,
                                        PW.WORK_ID ASC
                                </cfquery>
                                
                                <cfif GET_PROJECT_TASKS.recordcount gt 0>
                                    <div class="task-list" style="font-size:11px; line-height:1.3;">
                                        <cfloop query="GET_PROJECT_TASKS">
                                            <div class="task-item" style="margin-bottom:2px;">
                                                <cfif TO_COMPLETE eq 1>
                                                    <i class="fa fa-check-circle text-success" title="Tamamlandı"></i>
                                                <cfelse>
                                                    <i class="fa fa-circle-o text-muted" title="Devam Ediyor"></i>
                                                </cfif>
                                                <strong>#WORK_HEAD#</strong>
                                                <cfif len(WORK_STAGE)>
                                                    <span class="text-muted">(#WORK_STAGE#)</span>
                                                </cfif>
                                                <cfif isDate(TARGET_FINISH)>
                                                    <br><small class="text-muted">📅 #dateformat(TARGET_FINISH, "dd/mm/yyyy")#</small>
                                                </cfif>
                                            </div>
                                        </cfloop>
                                        <cfif TASK_COUNT gt 5>
                                            <small class="text-muted">... +#TASK_COUNT - 5# görev daha</small>
                                        </cfif>
                                    </div>
                                <cfelse>
                                    <span class="text-muted">Görev bulunmamaktadır</span>
                                </cfif>
                            </td>
                        </tr>
                    </cfoutput>
                <cfelse>
                    <tr>
                        <td colspan="13" style="text-align:center; padding:20px;">
                            <cfif isdefined("attributes.is_form_submitted")>
                                <i class="fa fa-info-circle"></i> Kayıt bulunamadı!
                            <cfelse>
                                <i class="fa fa-search"></i> Filtre ediniz!
                            </cfif>
                        </td>
                    </tr>
                </cfif>
            </tbody>
        </cf_grid_list>
        
        <!--- Sayfalama --->
        <cfif attributes.totalrecords gt attributes.maxrows>
            <cfset url_str = "is_form_submitted=1">
            <cfif len(attributes.keyword)><cfset url_str = "#url_str#&keyword=#attributes.keyword#"></cfif>
            <cfif len(attributes.project_responsible_id)><cfset url_str = "#url_str#&project_responsible_id=#attributes.project_responsible_id#&project_responsible=#attributes.project_responsible#"></cfif>
            <cfif len(attributes.category_id)><cfset url_str = "#url_str#&category_id=#attributes.category_id#"></cfif>
            <cfif len(attributes.priority_id)><cfset url_str = "#url_str#&priority_id=#attributes.priority_id#"></cfif>
            <cfif len(attributes.start_date)><cfset url_str = "#url_str#&start_date=#attributes.start_date#"></cfif>
            <cfif len(attributes.finish_date)><cfset url_str = "#url_str#&finish_date=#attributes.finish_date#"></cfif>
            
            <cf_paging 
                page="#attributes.page#"
                maxrows="#attributes.maxrows#"
                totalrecords="#attributes.totalrecords#"
                startrow="#attributes.startrow#"
                adres="project.project_operation_report&#url_str#">
        </cfif>
    </cf_box>
</div>

<style>
/* Excel tarzı tablo çizgileri */
.cf_grid_list, .table {
    border-collapse: collapse !important;
    border: 2px solid #4472C4 !important;
}
.cf_grid_list thead th, .table thead th {
    border: 1px solid #8EA9DB !important;
    background-color: #4472C4 !important;
    color: #fff !important;
    font-weight: 600 !important;
    padding: 8px 6px !important;
}
.cf_grid_list tbody td, .table tbody td {
    border: 1px solid #B4C6E7 !important;
    padding: 6px 8px !important;
}
.cf_grid_list tbody tr:nth-child(even), .table tbody tr:nth-child(even) {
    background-color: #D6DCE5 !important;
}
.cf_grid_list tbody tr:nth-child(odd), .table tbody tr:nth-child(odd) {
    background-color: #fff !important;
}
.cf_grid_list tbody tr:hover, .table tbody tr:hover {
    background-color: #BDD7EE !important;
}

.task-list {
    max-height: 120px;
    overflow-y: auto;
}
.task-item {
    border-left: 2px solid #e0e0e0;
    padding-left: 8px;
    margin-left: 10px;
}
.progress {
    min-width: 60px;
}
.label {
    font-size: 85%;
}
</style>

<script type="text/javascript">
document.getElementById('keyword').focus();
</script>