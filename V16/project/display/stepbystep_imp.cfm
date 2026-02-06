<cfset getComponent = createObject('component','V16.project.cfc.project')>
<cfset get_project_details = getComponent.select(id: attributes.project_id)>

<div class="ui-dashboard col col-12">
    <div class="ui-dashboard-item imp_steps_item">
        <a class="ui-dashboard-item-title" href="<cfoutput>#request.self#?fuseaction=settings.imp_scope&project_id=#attributes.project_id#</cfoutput>" target="_blank"><img src="css/assets/icons/catalyst-icon-svg/ctl-packing-3.svg" width="80px" height="70px"></a>
        <label class="ui-dashboard-item-text imp_text" style="color:#4A4A4A"><b><cf_get_lang dictionary_id='41602.Kapsam'></b></label>
    </div>
    <div class="ui-dashboard-item imp_steps_item">
        <a class="ui-dashboard-item-title" href="<cfoutput>#request.self#?fuseaction=settings.imp_dashboard&project_id=#attributes.project_id#</cfoutput>" target="_blank"><img src="css/assets/icons/catalyst-icon-svg/ctl-music-player.svg" width="80px" height="70px"></a>
        <label class="ui-dashboard-item-text imp_text" style="color:#4A4A4A"><b><cf_get_lang dictionary_id='63588.Dashboard'></b></label>
    </div>
    <div class="ui-dashboard-item imp_steps_item">
        <a class="ui-dashboard-item-title" href="<cfoutput>#request.self#?fuseaction=settings.imp_steps&project_id=#attributes.project_id#</cfoutput>" target="_blank"><img src="css/assets/icons/catalyst-icon-svg/ctl-molecule.svg" width="80px" height="70px"></a>
        <label class="ui-dashboard-item-text imp_text" style="color:#4A4A4A"><b><cf_get_lang dictionary_id='45823.Adımlar'></b></label>
    </div>
    <cfif get_project_details.IMPLEMENTATION_STEP_IMPORTED neq 1>
        <div class="col col-12">
            <a href="javascript://" onClick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=project.popup_import_steps&project_id=#attributes.project_id#</cfoutput>')">
                <label style="cursor: pointer"> <b>>> <cf_get_lang dictionary_id='66888.Data Service ile adımları import et.'></b> </label>
            </a>
        </div>
    </cfif>
</div>