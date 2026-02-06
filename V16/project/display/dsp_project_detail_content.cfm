
<cfset getComponent = createObject('component','V16.project.cfc.get_project_detail')>
<cfset GET_CAT = getComponent.GET_CAT(process_cat : project_detail.process_cat)>
<cfset get_process = getComponent.GET_PROCESS(pro_currency_id : project_detail.pro_currency_id)>
<cfset attributes.project_id=url.id>
<cfif isDefined ('session.ep.time_zone')>
    <cfset simdi = dateadd ('h',session.ep.time_zone,now())>
<cfelseif isDefined ('session.pp.time_zone')>
    <cfset simdi = dateadd ('h',session.pp.time_zone,now())>
<cfelse>
    <cfset simdi = now()>
</cfif>
<cfset fark3 = datediff('n',project_detail.target_start,project_detail.target_finish)>
<cfset toplam = fark3>

<cfset fark6 = datediff('n',project_detail.target_start,simdi)>
<cfset fark = fark6>

<cfset per_cent = Round (evaluate( (fark / toplam) * 100))>
<cfif per_cent gt 100>
    <cfset per_cent = 100>
</cfif>

<cfsavecontent variable="title"><cf_get_lang dictionary_id='57416.Proje'> <cf_get_lang dictionary_id='58052.Özet'></cfsavecontent>
<cf_box id="project_summary" closable="0"  title="#title#" box_page="V16/project/display/project_summary.cfm?id=#attributes.id#&form_action=#request.self#?fuseaction=#listgetat(attributes.fuseaction,1,'.')#.emptypopup_add_project"></cf_box>
<cfsavecontent variable="title"><cf_get_lang dictionary_id='31030.Görevler'></cfsavecontent>
<cf_box 
    id="main_mission_id"
    closable="0"
    title="#title#" 
    box_page="#request.self#?fuseaction=project.emptypopup_ajax_project_works&xml_is_stage_cat=#xml_is_stage_cat#&work_fuse=#attributes.fuseaction#&xml_is_stage_work_cat=#xml_is_stage_work_cat#&xml_work_sort_type=#xml_work_sort_type#&project_id=#attributes.id#&related_project_info=1&xml_change_complate_ratio=#xml_change_complate_ratio#&xml_show_work_category=#xml_show_work_category#&xml_show_actual_date=#xml_show_actual_date#&project_detail_id=#attributes.id#&xml_milestone_transfer=#xml_milestone_transfer#"
    add_href="javascript:openBoxDraggable('#request.self#?fuseaction=project.works&event=add&id=#project_detail.project_id#&work_fuse=#attributes.fuseaction#','','ui-draggable-box-large');">
</cf_box>

<!---<cf_tab slider="1" defaultOpen="main_relation_pro" divId="main_relation_pro,main_project_id,content,main_organization_id,evaluation_form,analyse,asset,notes" divLang="#getLang('project',183)#;#getLang('project',149)#;#getLang('main',633)#;#getLang('main',1669)#;#getLang('main',1947)#;#getLang('main',1387)#;#getLang('main',156)#;#getLang('main',10)#">--->
            <!--- iliskili projeler --->
            <cfsavecontent variable="message2"><cf_get_lang dictionary_id='38303.ilişkili proje'></cfsavecontent>
            <cfif xml_dsp_pro_relation_pro eq 1>
                <cf_box title="#message2#" style="box-shadow:none;" closable="0" id="main_relation_pro" box_page="#request.self#?fuseaction=project.emptypopup_ajax_project_relation_projects&project_id=#attributes.id#&related_pro_id=#project_detail.related_project_id#&xml_show_actual_date=#xml_show_actual_date#"></cf_box>
            </cfif>
            <!--- Icerikler --->
            <cf_get_workcube_content action_type ='PROJECT_ID' style="box-shadow:none;" action_type_id ='#attributes.id#'design='1' come_project='1'>
            <!--- Mindmap --->
            <cfset action_section = "PROJECT">
            <cf_box id="mindmap_id" closable="0" title="Mindmap Designer" style="box-shadow:none;" widget_load="mindmap&project_id=#attributes.id#&type=#attributes.fuseaction#" add_href="#request.self#?fuseaction=project.mindmap&event=add&prj_id=#attributes.id#&type=#attributes.fuseaction#"></cf_box>
            <!--- İş Akış Tasarımcısı --->
            <cfset relative_id = attributes.project_id>
            <cfinclude template="../../process/display/list_designer.cfm"> 
            <!--- İlişkili Organizasyonlar --->
            <cfsavecontent variable="message4"><cf_get_lang dictionary_id='29466.İlişkili Etkinlikler'></cfsavecontent>
            <cf_box id="main_organization_id" closable="0" title="#message4#" style="box-shadow:none;" add_href="#request.self#?fuseaction=campaign.list_organization&event=add&prj_id=#attributes.id#" box_page="#request.self#?fuseaction=objects.emptypopup_get_organization_detail&project_id=#project_detail.project_id#"></cf_box>
            <!--- Değerlendirme formları----->
            <cf_get_workcube_form_generator action_type='5' related_type='5' action_type_id='#attributes.project_id#' design='3' project_cat_id='#project_detail.process_cat#'>
            <!---- Analizler ----->
            <cf_get_member_analysis action_type='PROJECT' action_type_id='#attributes.project_id#' company_id='#project_detail.company_id#' partner_id='#project_detail.partner_id#' consumer_id='#project_detail.consumer_id#' is_analysis_link='#xml_is_analysis_link#'>
<!---</cf_tab>--->