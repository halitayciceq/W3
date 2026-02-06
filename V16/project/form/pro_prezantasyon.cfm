<!---

    File :          pro_prezantasyon.cfm
    Author :        Melek KOCABEY<melekkocabey@workcube.com>
    Date :          04.01.2024
    Description :   projeler tab menü de çağrılır.
                    Projenin bilgileri kaydeder.

    Controller :    DspProjectsController.cfm
    cfc  :          projectData.cfc
    method :        AddProjectPre
--->
<cfset ProjectCmp =createObject("component", "V16/project/cfc/projectData")>
<cfset get_project = ProjectCmp.get_projects(id : attributes.id)>
<cf_box title='Prezantasyon' popup_box="1">
    <cfform name='AddDetaProgress' method='post'>
        <cfinput type="hidden" name="project_id" id="project_id" value="#attributes.id#"/>
        <cf_box_elements>
            <cfmodule
                template="/fckeditor/fckeditor.cfm"
                toolbarset="WRKContent"
                basepath="/fckeditor/"
                instancename="pro_preDetail"
                value="#get_project.PROJECT_PRESENTATION#"
                height="500">
        </cf_box_elements>
        <cf_box_footer>
        <cf_workcube_buttons type_format="1" is_upd='0' is_cancel='0' data_action ="/V16/project/cfc/projectData:AddProjectPre">
        </cf_box_footer>
    </cfform>
</cf_box>
<style>
    #item-pro_preDetail {
        width: 2000px;
    }
</style>