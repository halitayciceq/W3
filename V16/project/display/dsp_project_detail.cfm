<cf_xml_page_edit fuseact="project.projects">
	<cfinclude template="../query/get_prodetail.cfm">
	
	<cfif not project_detail.recordcount>
		<cfset hata  = 10>
		<cfinclude template="../../dsp_hata.cfm">
	</cfif>
	<cfquery name="get_project_main" datasource="#DSN#">
		SELECT 
			PROCESS_MAIN_ID,
			PROCESS_MAIN_HEADER
		FROM 
			PROCESS_MAIN 
		WHERE 
			PROJECT_ID = #project_detail.project_id#
	</cfquery>
	<cfquery name="get_process_recordcount" datasource="#dsn#">
		SELECT
			WORK_CURRENCY_ID 
		FROM 
			PRO_WORKS,
			PROCESS_TYPE_ROWS
		WHERE
			PROCESS_TYPE_ROWS.PROCESS_ROW_ID = PRO_WORKS.WORK_CURRENCY_ID AND 
			PRO_WORKS.PROJECT_ID = #project_detail.project_id#
		GROUP BY 
			PRO_WORKS.WORK_CURRENCY_ID
	</cfquery>
	<div style="display:none;" id="1">
		<cf_workcube_main_process_cat main_process_cat='#project_detail.process_cat#'>
	</div>
	<!--- Sayfa başlığı ve ikonlar --->
	<cfset pageHead = "#getlang('main',603)#: #PROJECT_DETAIL.project_number#">
	<cf_catalystHeader>
	<cfset index=1>
	<!--- Sayfa ana kısım --->
	<div class="row"> <!---///ilk row--->
		<div class="col col-9 col-xs-12 uniqueRow"> <!---///content sol--->
			 <!--- Geniş alan: içerik --->
			<cfinclude template="dsp_project_detail_content.cfm">
		</div>
		   <div class="col col-3 col-xs-12 uniqueRow"> <!---///content sağ--->
			<!--- Yan kısım --->
				<cfinclude template="dsp_project_detail_side.cfm">
		</div>
	</div>
				
<script>

	
function openCorrespondenceLink(fieldName)
{
	if(!$("#"+fieldName).length)
	{
		$('<ul>').attr({'id':'CorrespondenceUl','class':'dropdown-menu'}).appendTo($("li a i.icon-fa.fa-envelope").parent('a').parent('li'));

			$("<li>").attr('id','correspondence').appendTo($('#CorrespondenceUl'));
				$('<a>').attr({'id': fieldName,'href': '<cfoutput>#request.self#?fuseaction=correspondence.list_correspondence&form_submit=1&project_id=#project_detail.project_id#</cfoutput>','target': '_blank'} ).append( 'Yazışmalar' ).appendTo($('#correspondence'));
			$("<li>").attr('id','correspondenceprojectmanager').appendTo($('#CorrespondenceUl'));
				$('<a>').attr({'id': fieldName+'_1', 'href': '<cfoutput>#request.self#?fuseaction=correspondence.list_correspondence&event=add&project_id=#project_detail.project_id#&is_manager=1</cfoutput>','target': '_blank'} ).append( 'Proje Yöneticisine Yazışma Ekle' ).css({minWidth:'200px'}).appendTo($('#correspondenceprojectmanager'));
			$("<li>").attr('id','correspondenceprojectteam').appendTo($('#CorrespondenceUl'));
				$('<a>').attr({'id': fieldName+'_2','href': '<cfoutput>#request.self#?fuseaction=correspondence.list_correspondence&event=add&project_id=#project_detail.project_id#&is_manager=0</cfoutput>','target': '_blank'} ).append( 'Tüm Ekibe Yazışma Ekle' ).css({minWidth:'200px'}).appendTo($('#correspondenceprojectteam'));

		$("li.dropdown a i.icon-fa.fa-envelope").parent('a').parent('li').addClass('CorrespondenceField');
		$("li.dropdown a i.icon-fa.fa-envelope").parent('a').parent('li').removeClass('dropdown');
	}
	$(".CorrespondenceField").children("ul").toggle(400);
}

		
	</script>