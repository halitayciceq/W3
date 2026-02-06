<style>
    #chartdiv2 {
        width: 100%;
        height: 700px;
    }
</style>
<cfquery name="get_satis" datasource="#dsn2#">
    SELECT
        SC.COUNTRY_CODE,
        SUM(NETTOTAL) TOPLAM
    FROM
        INVOICE I
    LEFT JOIN #DSN#.COMPANY C ON I.COMPANY_ID = C.COMPANY_ID
    LEFT JOIN #DSN#.DEPARTMENT D ON I.DEPARTMENT_ID = D.DEPARTMENT_ID
    LEFT JOIN #DSN#.SETUP_COUNTRY SC ON C.COUNTRY = SC.COUNTRY_ID
    WHERE   C.COUNTRY IS NOT NULL AND
            PURCHASE_SALES = 1 AND
            IS_IPTAL = 0
            <cfif len(attributes.branch)>
                AND D.BRANCH_ID = #attributes.branch#
            </cfif>
             <cfif len(attributes.date1)>AND I.INVOICE_DATE >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.date1#"></cfif>
           <cfif len(attributes.date2)>AND I.INVOICE_DATE < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateAdd('d',1,attributes.date2)#"></cfif> 
    GROUP BY SC.COUNTRY_CODE
</cfquery>
<script src="JS/Chart.min.js"></script>
<script src="JS/holisticJs/core.js"></script>
<script src="JS/holisticJs/charts.js"></script>
<script src="JS/holisticJs/maps.js"></script>
<script src="JS/holisticJs/themes/animated.js"></script>
<script src="JS/holisticJs/themes/spiritedaway.js"></script>
<script src="JS/holisticJs/themes/kelly.js"></script>
<script src="JS/holisticJs/themes/dark.js"></script>
<script src="JS/holisticJs/plugins/forceDirected.js"></script>
<script src="JS/holisticJs/plugins/timeline.js"></script>
<script src="JS/holisticJs/geodata/worldLow.js"></script>
<script src="JS/holisticJs/geodata/worldHigh.js"></script>
<script src="JS/holisticJs/lang/TR.js"></script>


        <div id="chartdiv2"></div>
   

<script>
    am4core.ready(function() {       
        am4core.useTheme(am4themes_animated);
        
        var chart = am4core.create("chartdiv2", am4maps.MapChart);
        
        chart.geodata = am4geodata_worldHigh;
        chart.geodataNames = am4geodata_lang_TR; //Türkçe dil seti.
       
        var polygonSeries = chart.series.push(new am4maps.MapPolygonSeries());
        
        polygonSeries.heatRules.push({
            property: "fill",
            target: polygonSeries.mapPolygons.template,
            min: chart.colors.getIndex(1).brighten(1.8), //Bar rengi Az olan Kısım
            max: chart.colors.getIndex(5).brighten(-0.6) // Bar rengi Çok olan Kısım
        });
        
        polygonSeries.useGeodata = true;
        
        polygonSeries.data = [
           
            <cfoutput query="get_satis">
                {
                    <cfset sehirBakiye = 0>
                    id: "#COUNTRY_CODE#",
                    value: #TOPLAM#
                   
                }<cfif get_satis.currentrow neq get_satis.RecordCount>, </cfif>
            </cfoutput>
        ];
        
        let heatLegend = chart.createChild(am4maps.HeatLegend);
        heatLegend.series = polygonSeries;
        heatLegend.align = "right";
        heatLegend.valign = "bottom";
        heatLegend.width = am4core.percent(20); //Az-Çok barın uzuluğu
        heatLegend.marginRight = am4core.percent(4); //Az-Çok barın konumu
        heatLegend.minValue = 0;
        heatLegend.maxValue = 40000000;
        
        var minRange = heatLegend.valueAxis.axisRanges.create();
        minRange.value = heatLegend.minValue;
        minRange.label.text = "<cf_get_lang dictionary_id='65335.Az'>";
        
        var maxRange = heatLegend.valueAxis.axisRanges.create();
        maxRange.value = heatLegend.maxValue;
        maxRange.label.text = "<cf_get_lang dictionary_id='65334.Çok'>";
        
        heatLegend.valueAxis.renderer.labels.template.adapter.add("text", function(labelText) {
            return "";
        });
        
        var polygonTemplate = polygonSeries.mapPolygons.template;
        polygonTemplate.tooltipText = "{name}: {value}";
        polygonTemplate.nonScalingStroke = true;
        polygonTemplate.strokeWidth = 0.7; //Ülkelerin sınırlarının kalınlığı
        
        var hs = polygonTemplate.states.create("hover");
        hs.properties.fill = am4core.color("#3c5bdc");
    }); //Dünya Haritası
</script>