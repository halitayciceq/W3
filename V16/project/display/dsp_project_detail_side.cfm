<cfif get_process_recordcount.recordcount>
    <cf_box id="graphs" title="#getLang('process',39)#" box_page="#request.self#?fuseaction=project.popup_pro_works_graph&id=#attributes.id#">
        <cfset pro_works_height = get_process_recordcount.recordcount*15+130>
            <cfif pro_works_height lt 280>
                <cfset pro_works_height = 300>
            </cfif>
    </cf_box>
</cfif>
<cfif isdefined("xml_is_image") and xml_is_image eq 1>
    <cf_wrk_images pro_id="#attributes.project_id#" type="project">
</cfif>
<cfquery name="GET_PROCESS" datasource="#DSN#">
    SELECT STAGE FROM PROCESS_TYPE,PROCESS_TYPE_ROWS WHERE PROCESS_TYPE_ROWS.PROCESS_ID = PROCESS_TYPE.PROCESS_ID AND PROCESS_TYPE_ROWS.PROCESS_ROW_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#project_detail.pro_currency_id#"> 
</cfquery>
<cfset getComponent = createObject('component','V16.project.cfc.get_project_detail')>
<cfset GET_PROJECT_WORKGROUP = getComponent.GET_PROJECT_WORKGROUP(project_id : attributes.project_id)>
<cfset GET_GOOGLE_PROJECT_FOLDER_ID = getComponent.GET_GOOGLE_PROJECT_FOLDER_ID(project_id : attributes.project_id)>
<cfset GET_PROJECT_FOLDER = getComponent.GET_PROJECT_FOLDER(project_id : attributes.project_id)>
<div style="display:none;z-index:999;" id="subs_team"></div>
<cf_box 
    id="workgroup" 
    title="#getLang('campaign',44)#"
    chatroom_settings = "#{ action_wo: 'project.projects', action_wo_event: 'det', action_parameter: 'id', action_id: attributes.id }#"
    widget_load="subscriberTeam&project_id=#attributes.project_id#"
    lock_href="openBoxDraggable('#request.self#?fuseaction=objects.popup_denied_pages_lock&pages_id=#GET_PROJECT_WORKGROUP.WORKGROUP_ID#&act=#attributes.fuseaction#')"
    lock_href_title="#getLang('','Sayfa Kilidi',58041)#"
    add_href="openBoxDraggable('#request.self#?fuseaction=project.popup_add_workgroup&project_id=#attributes.project_id#')"
    >
</cf_box>
<!----Belgeler----->
<cf_get_workcube_asset asset_cat_id="-1" module_id='1' action_section='PROJECT_ID' action_id='#attributes.id#'>
<!--- Google Drive --->
<cfif len(GET_GOOGLE_PROJECT_FOLDER_ID.GOOGLE_PROJECT_FOLDER_ID) and not GET_PROJECT_FOLDER.PROJECT_FOLDER contains 'drive.google'>
    <cf_box title="#getLang('','Google Drive',64435)# #getLang('','Belgeler',57568)#" id="google_drive_box">
        <div id="item-drive_box" style="cursor:pointer;" onClick="window.open('https://drive.google.com/drive/u/0/folders/<cfoutput>#GET_GOOGLE_PROJECT_FOLDER_ID.GOOGLE_PROJECT_FOLDER_ID#</cfoutput>')" data-toggle="tooltip" title="<cf_get_lang dictionary_id='61793.Projenin Google Drive klasörüne erişmek için tıklayınız.'>">
            <img height="30px" src="css/assets/icons/catalyst-icon-svg/google-drive.svg" alt="">
            <span>
                <cf_get_lang dictionary_id='64435.Google Drive'>
            </span>
        </div>
    </cf_box>
<cfelseif len(GET_PROJECT_FOLDER.PROJECT_FOLDER) and GET_PROJECT_FOLDER.PROJECT_FOLDER contains 'drive.google'>
    <cf_box title="#getLang('','Google Drive',64435)# #getLang('','Belgeler',57568)#" id="google_drive_box">
        <div id="item-drive_box" style="cursor:pointer;" onClick="window.open('<cfoutput>#GET_PROJECT_FOLDER.PROJECT_FOLDER#</cfoutput>')" data-toggle="tooltip" title="<cf_get_lang dictionary_id='61793.Projenin Google Drive klasörüne erişmek için tıklayınız.'>">
            <img height="30px" src="css/assets/icons/catalyst-icon-svg/google-drive.svg" alt="">
            <span>
                <cf_get_lang dictionary_id='64435.Google Drive'>
            </span>
        </div>
    </cf_box>
</cfif>

<!----Notlar------->
<cf_get_workcube_note action_section='PROJECT_ID' closable="0" module_id='1' action_id='#attributes.id#' style='1'>
<!---- İlişkili Olaylar ----->
<cf_get_related_events action_section='PROJECT_ID' action_id='#attributes.id#'>

<cfif xml_is_stepbystep_imp eq 1>
    <cf_box 
        id="stepbystep_imp"
        title="#getLang('','Adım Adım Implemantasyon',44149)#"
        widget_load="stepByStepImp&project_id=#attributes.project_id#">
</cfif>

<script>$('[data-toggle="tooltip"]').tooltip();</script>