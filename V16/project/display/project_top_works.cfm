<cfparam name = "attributes.work_id" default="">
<cfset getComponent = createObject('component','V16.project.cfc.get_project_detail')>
<cfquery name="GET_SUB_WORK" datasource="#DSN#">
    SELECT
        1 AS TYPE,
        PW.WORK_HEAD,
        PW.WORK_ID,
        PTR.STAGE,
        PW.WORK_PRIORITY_ID,
        CASE 
            WHEN PW.PROJECT_EMP_ID IS NOT NULL THEN (SELECT E.EMPLOYEE_NAME +' '+ E.EMPLOYEE_SURNAME FROM EMPLOYEES E WHERE E.EMPLOYEE_ID = PW.PROJECT_EMP_ID)
            WHEN PW.OUTSRC_PARTNER_ID IS NOT NULL THEN (SELECT C2.NICKNAME+' - '+ CP2.COMPANY_PARTNER_NAME + ' ' + CP2.COMPANY_PARTNER_SURNAME NAME FROM COMPANY_PARTNER CP2,COMPANY C2 WHERE C2.COMPANY_ID = CP2.COMPANY_ID AND CP2.PARTNER_ID = PW.OUTSRC_PARTNER_ID)
        END AS EMPLOYEE,
        PW.TARGET_FINISH,
        PW.TARGET_START,
        PW.REAL_FINISH,
        PW.REAL_START,
        PW.TO_COMPLETE,
        PW.ESTIMATED_TIME,
        SP.PRIORITY,
        SP.COLOR,
        (SELECT E.EMPLOYEE_ID FROM EMPLOYEES E WHERE E.EMPLOYEE_ID = PW.PROJECT_EMP_ID) EMPLOYEE_ID
    FROM 
        PRO_WORKS AS PW
        LEFT JOIN PROCESS_TYPE_ROWS AS PTR ON PW.WORK_CURRENCY_ID = PTR.PROCESS_ROW_ID
        LEFT JOIN SETUP_PRIORITY SP ON PW.WORK_PRIORITY_ID = SP.PRIORITY_ID
    WHERE 
        PW.WORK_ID = (SELECT MILESTONE_WORK_ID FROM PRO_WORKS WHERE WORK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.work_id#">) AND 
        PW.WORK_STATUS = 1 
    UNION ALL
    SELECT 
        2 AS TYPE,
        PW.WORK_HEAD,
        PW.WORK_ID,
        PTR.STAGE,
        PW.WORK_PRIORITY_ID,
        CASE 
            WHEN PW.PROJECT_EMP_ID IS NOT NULL THEN (SELECT E.EMPLOYEE_NAME +' '+ E.EMPLOYEE_SURNAME FROM EMPLOYEES E WHERE E.EMPLOYEE_ID = PW.PROJECT_EMP_ID)
            WHEN PW.OUTSRC_PARTNER_ID IS NOT NULL THEN (SELECT C2.NICKNAME+' - '+ CP2.COMPANY_PARTNER_NAME + ' ' + CP2.COMPANY_PARTNER_SURNAME NAME FROM COMPANY_PARTNER CP2,COMPANY C2 WHERE C2.COMPANY_ID = CP2.COMPANY_ID AND CP2.PARTNER_ID = PW.OUTSRC_PARTNER_ID)
        END AS EMPLOYEE,
        PW.TARGET_FINISH,
        PW.TARGET_START,
        PW.REAL_FINISH,
        PW.REAL_START,
        PW.TO_COMPLETE,
        PW.ESTIMATED_TIME,
        SP.PRIORITY,
        SP.COLOR,
        (SELECT E.EMPLOYEE_ID FROM EMPLOYEES E WHERE E.EMPLOYEE_ID = PW.PROJECT_EMP_ID) EMPLOYEE_ID
    FROM 
        PRO_WORKS AS PW
        LEFT JOIN PROCESS_TYPE_ROWS AS PTR ON PW.WORK_CURRENCY_ID = PTR.PROCESS_ROW_ID
        LEFT JOIN SETUP_PRIORITY SP ON PW.WORK_PRIORITY_ID = SP.PRIORITY_ID
    WHERE 
        PW.WORK_ID = (SELECT MILESTONE_WORK_ID FROM PRO_WORKS WHERE WORK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.work_id#">) AND 
        PW.WORK_STATUS = 0
    ORDER BY 
        PW.WORK_HEAD
</cfquery>
<cfif GET_SUB_WORK.recordcount>
    <cf_grid_list>
        <thead>
            <tr>
                <th><cf_get_lang dictionary_id='31253.Sıra No'></th>
                <th>M</th>
                <th><cfoutput>#Left(getLang('main',73,'Oncelik',57485),1)#</cfoutput></th>
                <th><cfoutput>#Left(getLang('main',157,'Görevli',57569),1)#</cfoutput></th>
                <th><cf_get_lang dictionary_id='58820.Başlık'></th>
                <th><cf_get_lang dictionary_id='57482.Aşama'></th>
                <th><cf_get_lang dictionary_id='38146.Termin'></th>
                <th><cf_get_lang dictionary_id='38143.Öngörülen'></th>
                <th>%</th>
            </tr>
        </thead>
        <tbody>
            <cfoutput query="GET_SUB_WORK">
                <tr>
                    <cfif isdefined('EMPLOYEE_ID') and len(EMPLOYEE_ID)>
                        <cfset employee_photo = getComponent.EMPLOYEE_PHOTO(employee_id:employee_id)>
                    <cfelse>
                        <cfset employee_photo = ''>
                    </cfif>
                    <cfif isdefined('employee_photo.photo') and len(employee_photo.photo)>
                        <cfset emp_photo ="../../documents/hr/#employee_photo.PHOTO#">
                    <cfelseif isdefined('employee_photo.sex') and employee_photo.sex eq 1>
                        <cfset emp_photo ="images/male.jpg">
                    <cfelse>
                        <cfset emp_photo ="images/female.jpg">
                    </cfif>
                    <td>#currentrow#</td>
                    <td>
                        <cfif type eq 0>
                            <div class='iconBox' style='align: center; background-color:grey'><a href="javascript://" onclick="show_hide_works('#work_id#')" style="color:white">M</a></div>
                            <cfelse>&nbsp;&nbsp;</cfif>
                    </td>
                    <td>#priority#</td>
                    <td title="#get_emp_info(EMPLOYEE_ID,0,0)#">
                        <img class='img-circle' style='width : 30px; height:30px;'src='#emp_photo#' />
                    </td>
                    <td><a onclick="javascript://" href="#request.self#?fuseaction=project.works&event=det&id=#WORK_ID#" target="_blank" class="tableyazi" <cfif type eq 2>style="color:##808080"</cfif>>#WORK_HEAD#</a></td>
                    <td>#STAGE#</td>
                    <td>
                        <cfif isdefined('target_finish') and len(target_finish)>
                            <cfset fdate_plan=date_add("h",session.ep.time_zone,target_finish)>
                        <cfelse>
                            <cfset fdate_plan=''>
                        </cfif>
                        <cfif isdefined('fdate_plan') and len(fdate_plan)>
                            #dateformat(fdate_plan,dateformat_style)#
                        </cfif>
                    </td>
                    <td>
                        <cfif isdefined('estimated_time') and len(estimated_time)>
                            <cfset liste=estimated_time/60>
                            <cfset saat=listfirst(liste,'.')>
                            <cfset dak=estimated_time-saat*60>
                            #saat# <cf_get_lang dictionary_id='57491.Saat'> #dak# <cf_get_lang dictionary_id='58827.Dk'>
                        </cfif>
                    </td>
                    <td>
                        #to_complete#
                    </td>
                </tr>
            </cfoutput>
        </tbody>
    </cf_grid_list>
</cfif>
<cfscript>
    function show_hide_works(id){
        $('[id="'+id+'"]').toggle();
    }
</cfscript>