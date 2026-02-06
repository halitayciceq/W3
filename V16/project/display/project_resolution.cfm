<!---
   
    Controller:WBO\controller\ProjectResController.cfm
    Author: Fatma Zehra Dere
    Date: 2022-11-23
    Description:
    Proje yoğunluğu raporu
    History:
    To Do:
--->
<cf_catalystHeader>
    <cfscript>
        get_project = createObject("component","V16.project.cfc.project_resolution");
        PROJECT_REPORT = get_project.PROJECT_REPORT();
        GET_PROJECT_STATUS = get_project.GET_PROJECT_STATUS();
        GET_PROJECT_WORKS = get_project.GET_PROJECT_WORKS();
        GET_PROJECT_BY_PARTNER = get_project.GET_PROJECT_BY_PARTNER();
        GET_PROJECT_CATEGORI = get_project.GET_PROJECT_CATEGORI();
        GET_PROJECT_STAGE = get_project.GET_PROJECT_STAGE ();
    </cfscript>
    
    <style>
        .red{
            color: #E08283;
            font-weight:600;
        }
    </style>
    <div class="col col-12 col-md-12 col-sm-12 col-xs-12">
        <cf_box>
            <cfoutput>
                <div class="ui-info-bottom">
                    <div class="col col-3 col-md-3 col-sm-3 col-xs-12">
                        <div class="form-group">
                            <label><cf_get_lang dictionary_id='65991.Toplam Aktif Proje'>:</label> 
                            <label class="red">&nbsp#GET_PROJECT_STATUS.TOTAL_STATUS#</label> 
                        </div>
                    </div>
                 <div class="col col-3 col-md-3 col-sm-3 col-xs-12">
                        <div class="form-group">
                            <label><cf_get_lang dictionary_id='66050.Toplam Aktif Görev'>:</label>
                            <label class="red">&nbsp#GET_PROJECT_WORKS.TOTAL_WROKS#</label>
                        </div>
                    </div>
                </div>
            </cfoutput>
        </cf_box>
    </div>
    <div class="col col-9 col-md-9 col-sm-9 col-xs-12">
        <cf_box title="#getLang('','Proje Liderlerine Göre Aktif Projeler',65992)#">
            <div class="scrollContent scroll-x5">
                <cf_grid_list>
                    <thead>
                        <tr>
                            <th width="30" class="text-center"><cf_get_lang dictionary_id='58577.Sıra'></th>
                            <th><cf_get_lang dictionary_id='49256.İş Ortağı'></th>
                            <th class="text-center"><cf_get_lang dictionary_id='57493.Aktif'><cf_get_lang dictionary_id='57416.Proje'></th>
                            <th class="text-center"><cf_get_lang dictionary_id='57493.Aktif'><cf_get_lang dictionary_id='55773.Görev'></th>
                            <th class="text-center"><cf_get_lang dictionary_id='65993.Planlanan Ekip üyesi'></th>
                            <th class="text-center"><cf_get_lang dictionary_id='65994.Görev verilen ekip üyesi'></th>
                            <th class="text-center"><cf_get_lang dictionary_id='65995.Aktif Görevler Öngörülen Süre'></th>
                            <th class="text-center"><cf_get_lang dictionary_id='65996.Aktif Görev Lider Öngörülen Süre'></th>
                            <th class="text-center"><cf_get_lang dictionary_id='65997.Planlanmış Toplantı'></th>
                        </tr>
                    </thead>
                    <tbody>
                        <cfoutput query="GET_PROJECT_BY_PARTNER" GROUP="PROJECT_EMP_ID">
                        
                            <cfset GET_PARTNER_WORK = get_project.GET_PARTNER_WORK(PROJECT_EMP_ID:#PROJECT_EMP_ID#)>
                            <cfset GET_PROJECT_WORKGROUP = get_project.GET_PROJECT_WORKGROUP(PROJECT_EMP_ID:#PROJECT_EMP_ID#)>
                            <cfset GET_PROJECT_WORKGROUP_ = get_project.GET_PROJECT_WORKGROUP_(PROJECT_EMP_ID:#PROJECT_EMP_ID#)>
                            <cfset GET_PROJECT_WORKGROUP_TIME = get_project.GET_PROJECT_WORKGROUP_TIME(PROJECT_EMP_ID:#PROJECT_EMP_ID#)>
                            <cfset GET_PROJECT_WORKGROUP_LEADER = get_project.GET_PROJECT_WORKGROUP_LEADER(PROJECT_EMP_ID:#PROJECT_EMP_ID#)>
                            <cfset GET_PROJECT_WORKGROUP_AGENDA = get_project.GET_PROJECT_WORKGROUP_AGENDA(PROJECT_EMP_ID:#PROJECT_EMP_ID#)>
                            <cfset GET_PROJECT_COUNT_AGENDA = get_project.GET_PROJECT_COUNT_AGENDA()>
                            <tr>
                                <td class="text-center">#currentrow#</td>
                                <td>
                                    <cfif len(PROJECT_EMP_ID)>
                                        <cfset  pro_employee = get_emp_info(PROJECT_EMP_ID,0,0)>
                                        <a href="#request.self#?fuseaction=project.projects&pro_employee_id=#PROJECT_EMP_ID#&is_form_submitted=1&ordertype=1&pro_employee=#pro_employee#" target="_blank"> #get_emp_info(PROJECT_EMP_ID,0,0)#</a>
                                    </cfif>
                                </td>
                                <td class="text-center">#PROJECT_COUNT#</td>
                                <td class="text-center">#GET_PARTNER_WORK.work_id#</td>
                                <td class="text-center">#GET_PROJECT_WORKGROUP.WORKGROUP_COUNT#</td>
                                <td class="text-center">#GET_PROJECT_WORKGROUP_.WORKGROUP_emp#</td>
                                <td class="text-center">
                                    <cfif isdefined('GET_PROJECT_WORKGROUP_TIME.estimated_time') and len(GET_PROJECT_WORKGROUP_TIME.estimated_time)>
                                        <cfset liste=GET_PROJECT_WORKGROUP_TIME.estimated_time/60>
                                        <cfset saat=listfirst(liste,'.')>
                                        <cfset dak=GET_PROJECT_WORKGROUP_TIME.estimated_time-saat*60>
                                        #saat# <cf_get_lang dictionary_id='57491.Saat'> #dak# <cf_get_lang dictionary_id='58827.Dk'>
                                    </cfif>
                                </td>
                                <td class="text-center">
                                    <cfif isdefined('GET_PROJECT_WORKGROUP_LEADER.estimated_time') and len(GET_PROJECT_WORKGROUP_LEADER.estimated_time)>
                                        <cfset liste=GET_PROJECT_WORKGROUP_LEADER.estimated_time/60>
                                        <cfset saat=listfirst(liste,'.')>
                                        <cfset dak=GET_PROJECT_WORKGROUP_LEADER.estimated_time-saat*60>
                                        #saat# <cf_get_lang dictionary_id='57491.Saat'> #dak# <cf_get_lang dictionary_id='58827.Dk'>
                                    </cfif>
                                </td>
                                <td class="text-center">#GET_PROJECT_COUNT_AGENDA.EVENT_COUNT#
                                    <cfif isdefined('GET_PROJECT_COUNT_AGENDA.DIFFDATE') and len(GET_PROJECT_COUNT_AGENDA.DIFFDATE)>
                                        <cfset liste=GET_PROJECT_COUNT_AGENDA.DIFFDATE/60>
                                        <cfset saat=listfirst(liste,'.')>
                                        <cfset dak=GET_PROJECT_COUNT_AGENDA.DIFFDATE-saat*60>
                                        -#saat# <cf_get_lang dictionary_id='57491.Saat'> #dak# <cf_get_lang dictionary_id='58827.Dk'>
                                    </cfif>
                                   </td>
                        </cfoutput>
                    </tbody>
                </cf_grid_list>
            </div>
        </cf_box>
    </div>
    <div class="col col-3 col-md-3 col-sm-3 col-xs-12">
        <cf_box title="#getLang('','Kategorilere Göre Aktif Projeler',66048)#">
            <div class="scrollContent scroll-x5">
                <cf_grid_list>
                    <thead>
                        <tr>
                            <th width="30" class="text-center"><cf_get_lang dictionary_id='58577.Sıra'></th>
                            <th><cf_get_lang dictionary_id='57486.Kategori'></th>
                            <th class="text-center"><cf_get_lang dictionary_id='58082.Adet'></th>
                        </tr>
                    </thead>
                    <tbody>
                        <cfoutput query="GET_PROJECT_CATEGORI" GROUP="PROCESS_CAT">
                            <tr>
                                <td class="text-center">#currentrow#</td>
                                <td> <a href="#request.self#?fuseaction=project.projects&process_catid=#PROCESS_CAT#&is_form_submitted=1&ordertype=1" target="_blank">#MAIN_PROCESS_CAT# </a></td>
                                <td class="text-center">#TOTAL_CATEGORI#</td>
                            </tr>
                        </cfoutput>
                    </tbody>
                </cf_grid_list>
            </div>
        </cf_box>
    </div>
    <div class="col col-3 col-md-3 col-sm-3 col-xs-12">
        <cf_box title="#getLang('','Aşamalara Göre Aktif Projeler',66049)#">
            <div class="scrollContent scroll-x5">
                <cf_grid_list>
                    <thead>
                        <tr>
                            <th width="30" class="text-center"><cf_get_lang dictionary_id='58577.Sıra'></th>
                            <th><cf_get_lang dictionary_id='57482.Aşama'></th>
                            <th class="text-center"><cf_get_lang dictionary_id='58082.Adet'></th>
                        </tr>
                    </thead>
                    <tbody>
                        <cfoutput query="GET_PROJECT_STAGE"  GROUP="PRO_CURRENCY_ID">
                            <tr>
                                <td class="text-center">#currentrow#</td>
                                <td><a href="#request.self#?fuseaction=project.projects&currency=#PRO_CURRENCY_ID#&is_form_submitted=1&ordertype=1" target="_blank">#STAGE# </a></td>
                                <td class="text-center">#TOTAL_STAGE#</td>
                            </tr>
                        </cfoutput>
                    </tbody>
                </cf_grid_list>
            </div>
        </cf_box>
    </div>