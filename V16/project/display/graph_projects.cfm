<cfquery name="GET_PROJECTS" datasource="#dsn#">
	SELECT 
		COUNT(PROJECT_ID) AS DURUM_SAYI,
		PROCESS_TYPE_ROWS.STAGE,
		PROCESS_TYPE_ROWS.PROCESS_ROW_ID
	FROM 
		PRO_PROJECTS,
		PROCESS_TYPE_ROWS
	WHERE
		PRO_PROJECTS.PROJECT_STATUS=1 AND
		PROCESS_TYPE_ROWS.PROCESS_ROW_ID = PRO_PROJECTS.PRO_CURRENCY_ID
	GROUP BY 
		PROCESS_TYPE_ROWS.STAGE,
		PROCESS_TYPE_ROWS.PROCESS_ROW_ID
</cfquery>
<cfsetting showdebugoutput="no">
<cfsavecontent variable="title"><cf_get_lang dictionary_id='38151.Durumlarına Göre Aktif Projeler'></cfsavecontent>
<cf_box closable="0"  title="#title#">
<cfform action="#request.self#?fuseaction=project.popup_projects_graph&iframe=1" method="post" name="form_work">
    <cf_ajax_list_search>
        <cf_ajax_list_search_area>
                <table>
                    <tr>
                        <td> 
                            <select name="graph_type" id="graph_type" style="width:100px;">
                                <option value="" selected><cf_get_lang dictionary_id='57950.Grafik Format'></option>
                                <option value="pie"><cf_get_lang dictionary_id='58728.Pasta'></option>
                                <option value="bar"><cf_get_lang dictionary_id='57663.Bar'></option>
                            </select>
                        </td>
						<td><cf_wrk_search_button></td>
                    </tr>
                </table>
        </cf_ajax_list_search_area>
    </cf_ajax_list_search>
    <cf_ajax_list>
        <tbody>
            <cfsavecontent variable="message"><cf_get_lang dictionary_id ='38311.Proje Sayısı'></cfsavecontent>
            <cfsavecontent variable="message2"><cf_get_lang dictionary_id ='38312.Proje Durumuna Göre Toplamlar'></cfsavecontent>
            <cfsavecontent variable="durum"><cf_get_lang dictionary_id ='57756.Durum'></cfsavecontent>
                <cfif isDefined("form.graph_type") and len(form.graph_type)>
                    <cfset graph_type = form.graph_type>
                <cfelse>
                    <cfset graph_type = "pie">
                </cfif>
                <cfif not get_projects.recordcount>
                    <cf_get_lang dictionary_id='60611.Proje Kaydı Bulunamadı'>
                    <cfexit method="exittemplate">
                </cfif>    
            <cfoutput query="get_projects">
			<cfset value = #durum_sayi#>
			<cfset item = #stage#>
			<cfset 'item_#currentrow#'="#value#">
			<cfset 'value_#currentrow#'="#item#"> 
			</cfoutput>
			
				<canvas id="myChart" style="float:left;max-height:450px;max-width:450px;"></canvas>
				<script>
					var ctx = document.getElementById('myChart');
						var myChart = new Chart(ctx, {
							type: '<cfoutput>#graph_type#</cfoutput>',
							data: {
								labels: [<cfloop from="1" to="#get_projects.recordcount#" index="jj">
												 <cfoutput>#evaluate("value_#jj#")#</cfoutput>,</cfloop>],
								datasets: [{
									label: " ",
									backgroundColor: [<cfloop from="1" to="#get_projects.recordcount#" index="jj">'rgba('+Math.floor((Math.random()*255) + 1) + ',' +Math.floor((Math.random()*255) + 1) + ','+ Math.floor((Math.random()*255) + 1)+',0.60)',</cfloop>],
									data: [<cfloop from="1" to="#get_projects.recordcount#" index="jj"><cfoutput>"#evaluate("item_#jj#")#"</cfoutput>,</cfloop>],
								}]
							},
							options: {}
					});
				</script>		                
        </tbody>
    </cf_ajax_list>
</cfform>
</cf_box>
