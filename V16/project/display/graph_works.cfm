<cfsetting showdebugoutput="no">
<cfinclude template="../query/get_work_graph.cfm">
<cfform action="#request.self#?fuseaction=project.popup_works_graph&iframe=1" method="post" name="form_work">
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
            <cfsavecontent variable="message"><cf_get_lang dictionary_id ='38309.İş Sayısı'></cfsavecontent>
            <cfsavecontent variable="massage2"><cf_get_lang dictionary_id ='38310.İş Durumuna Göre Toplamlar'></cfsavecontent>
            <cfsavecontent variable="durum"><cf_get_lang dictionary_id='57756.Durum'></cfsavecontent>
            <cfif isDefined("form.graph_type") and len(form.graph_type)>
            <cfset graph_type = form.graph_type>
            <cfelse>
            <cfset graph_type = "bar">
            </cfif>
            <cfif not GET_WORK.recordcount>
                <cf_get_lang dictionary_id='57484.İş Kaydı Bulunamadı'>
                <cfexit method="exittemplate">
            </cfif>
           
            <cfoutput query="get_work">
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
								labels: [<cfloop from="1" to="#get_work.recordcount#" index="jj">
												 <cfoutput>#evaluate("value_#jj#")#</cfoutput>,</cfloop>],
								datasets: [{
									label: " ",
									backgroundColor: [<cfloop from="1" to="#get_work.recordcount#" index="jj">'rgba('+Math.floor((Math.random()*255) + 1) + ',' +Math.floor((Math.random()*255) + 1) + ','+ Math.floor((Math.random()*255) + 1)+',0.60)',</cfloop>],
									data: [<cfloop from="1" to="#get_work.recordcount#" index="jj"><cfoutput>"#evaluate("item_#jj#")#"</cfoutput>,</cfloop>],
								}]
							},
							options: {}
					});
				</script>		                 
        </tbody>
    </cf_ajax_list>
</cfform>
