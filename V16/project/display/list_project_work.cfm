<table class="dph">
	<tr>
		<td class="dpht"><cf_get_lang dictionary_id='38253.Aktif Proje ve İşler'></td>
	</tr>
</table>
<table class="dpm">
	<tr>
    <cfoutput>
		<!---Geniş alan---> 
		<td valign="top" class="dpml"><cfinclude template="dsp_works_home.cfm"></td>
		<!--- Yan kısım--->
		<td valign="top" class="dpmr">
            <!---<iframe src="#request.self#?fuseaction=project.popup_projects_graph&iframe=1" frameborder="0" width="300" height="290" scrolling="no"></iframe>--->
            <cfsavecontent variable="title"><cf_get_lang dictionary_id='38151.Durumlarına Göre Aktif Projeler'></cfsavecontent>
            <cf_box 
            	title="#title#"
                id="project_graph_" 
                unload_body="1" 
                style="width:99%"
                closable="0"
                box_page="#request.self#?fuseaction=objects.popup_ajax_survey&type=6">
            </cf_box>
            <!---<iframe src="#request.self#?fuseaction=project.popup_works_graph&iframe=1" frameborder="0" width="300" height="340" scrolling="no"></iframe>--->
            <cfsavecontent variable="title"><cf_get_lang dictionary_id='38147.Durumlarına Göre Aktif İşler'></cfsavecontent>
            <cf_box 
            	title="#title#"
                id="project_graph_id" 
                unload_body="1" 
                style="width:99%"
                closable="0"
                box_page="#request.self#?fuseaction=objects.popup_ajax_survey&type=7">
            </cf_box>
		</td>
	</cfoutput>
	</tr>
</table>
