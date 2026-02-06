<cfsetting showdebugoutput="no">

<cfquery name="get_work" datasource="#dsn#">
	SELECT
        PROCESS_TYPE_ROWS.STAGE STAGE,
		COUNT(WORK_ID) AS DURUM_SAYI		
	FROM 
		PRO_WORKS,
		PROCESS_TYPE_ROWS
	WHERE
		PROCESS_TYPE_ROWS.PROCESS_ROW_ID = PRO_WORKS.WORK_CURRENCY_ID
		<cfif isdefined('attributes.id') and len(attributes.id)>
			AND PRO_WORKS.PROJECT_ID = #attributes.id#
		</cfif>
	GROUP BY 
		PROCESS_TYPE_ROWS.STAGE
</cfquery>
<div class="col col-12 col-xs-12">
	<cfoutput query="get_work">
		<cfset 'item_#currentrow#' = "#get_work.STAGE#">
		<cfset 'value_#currentrow#' = "#get_work.DURUM_SAYI#">
	</cfoutput>
	<!--- <script src="JS/Chart.min.js"></script> --->
	<canvas id="myChart" height="250"></canvas>
	<script>
		var ctx = document.getElementById('myChart');
		var myChart = new Chart(ctx, {
			type: 'doughnut',
			data: {
					labels: [<cfloop from="1" to="#get_work.recordcount#" index="jj">
							<cfoutput>"#evaluate("item_#jj#")#"</cfoutput>,</cfloop>],
					datasets: [{
					label: "<cfoutput>#getLang('call',87)#</cfoutput>",
					backgroundColor: [<cfloop from="1" to="#get_work.recordcount#" index="jj">'rgba('+Math.floor((Math.random()*255) + 1) + ',' +Math.floor((Math.random()*255) + 1) + ','+ Math.floor((Math.random()*255) + 1)+',0.60)',</cfloop>],
					data: [<cfloop from="1" to="#get_work.recordcount#" index="jj"><cfoutput>"#evaluate("value_#jj#")#"</cfoutput>,</cfloop>],
						}]
					},
			options: {
				legend: {
					display: false
				}
			  }
			
		});
	</script>
</div>