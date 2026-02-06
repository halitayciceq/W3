<cfparam name="attributes.branch" default="">
<cfparam name="attributes.COUNTRY_CODE" default="">
<cfparam name="attributes.date1" default="">
<cfparam name="attributes.date2" default="">

<!-- Styles -->
<style>
  #chartdiv {
    width: 100%;
    height: 500px;
  }
</style>
    
<!-- Resources -->
<script src="https://cdn.amcharts.com/lib/4/core.js"></script>
<script src="https://cdn.amcharts.com/lib/4/maps.js"></script>
<script src="https://cdn.amcharts.com/lib/4/geodata/worldLow.js"></script>
<script src="https://cdn.amcharts.com/lib/4/geodata/data/countries2.js"></script>
<script src="https://cdn.amcharts.com/lib/4/themes/animated.js"></script>
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

<cfif isdefined('attributes.date1') and len(attributes.date1)>
	<cf_date tarih='attributes.date1'>
<cfelse>
	<cfif session.ep.our_company_info.UNCONDITIONAL_LIST eq 1>
		<cfset attributes.date1=''>
	<cfelse>
        <cfset attributes.date1 = date_add('d',-7,wrk_get_today())>
	</cfif>
</cfif>
<cfif  isdefined('attributes.date2') and len(attributes.date2)>
	<cf_date tarih='attributes.date2'>
<cfelse>
	<cfif session.ep.our_company_info.UNCONDITIONAL_LIST>
		<cfset attributes.date2=''>
	<cfelse>
        <cfset attributes.date2 = wrk_get_today()>
	</cfif>
</cfif>  

<cfquery name="get_satis" datasource="#dsn2#">
    SELECT
        SC.COUNTRY_CODE,
        SUM(NETTOTAL) TOPLAM
    FROM
        INVOICE I
    LEFT JOIN #dsn#.COMPANY C ON I.COMPANY_ID = C.COMPANY_ID
    LEFT JOIN #dsn#.SETUP_COUNTRY SC ON C.COUNTRY = SC.COUNTRY_ID
    WHERE
        C.COUNTRY IS NOT NULL AND
        SC.COUNTRY_CODE IS NOT NULL AND
        C.CITY IS NOT NULL AND
        PURCHASE_SALES = 1 AND
        IS_IPTAL = 0
        <cfif len(attributes.date1)>AND I.INVOICE_DATE >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.date1#"></cfif>
        <cfif len(attributes.date2)>AND I.INVOICE_DATE < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateAdd('d',1,attributes.date2)#"></cfif> 
    GROUP BY SC.COUNTRY_CODE
    ORDER BY SC.COUNTRY_CODE
</cfquery>  
<cfset  c_list = "#replace(serializeJSON(get_satis,"struct"),"/","","all")#">
<cfquery name="get_satis_sehir" datasource="#dsn2#">
    SELECT
        SC.PLATE_CODE,
        SCO.COUNTRY_CODE,
        SUM(NETTOTAL) TOPLAM
    FROM
        INVOICE I
    LEFT JOIN #dsn#.COMPANY C ON I.COMPANY_ID = C.COMPANY_ID
    LEFT JOIN #dsn#.SETUP_CITY SC ON C.CITY = SC.CITY_ID
    LEFT JOIN #dsn#.SETUP_COUNTRY SCO ON SC.COUNTRY_ID = SCO.COUNTRY_ID

    WHERE
        C.CITY IS NOT NULL AND
        PURCHASE_SALES = 1 AND
        IS_IPTAL = 0
        <cfif len(attributes.date1)>AND I.INVOICE_DATE >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.date1#"></cfif>
        <cfif len(attributes.date2)>AND I.INVOICE_DATE < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateAdd('d',1,attributes.date2)#"></cfif> 
    GROUP BY SC.PLATE_CODE,SCO.COUNTRY_CODE
</cfquery>



<!-- HTML -->
<cf_box>
    <cfform name="order_form" method="post" action="">
        <cf_box_search more="0"> 
            <!--- <div class="form-group">
                <select name="map_type" id="map_type" tabindex="12">
                    <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                    <option value="1" <cfif isDefined('attributes.map_type') and attributes.map_type eq 1> selected</cfif> selected="selected "><cf_get_lang dictionary_id='63000.Ülke Bazlı'></option>
                    <option value="2" <cfif isDefined('attributes.map_type') and attributes.map_type eq 2> selected</cfif>><cf_get_lang dictionary_id='63001.İl Bazlı'></option>
                </select>
            </div> --->
            <div class="form-group">
                <div class="col col-6 col-md-6 col-sm-6 col-xs-12">
                    <div class="input-group">
                        <cfinput type="text" name="date1" id="date1" value="#dateformat(attributes.date1,dateformat_style)#" maxlength="10" validate="#validate_style#">
                        <span class="input-group-addon"><cf_wrk_date_image date_field="date1"></span>
                    </div>
                </div>
                <div class="col col-6 col-md-6 col-sm-6 col-xs-12">
                    <div class="input-group">
                        <cfinput type="text" name="date2" id="date2" value="#dateformat(attributes.date2,dateformat_style)#" maxlength="10" validate="#validate_style#">
                        <span class="input-group-addon"><cf_wrk_date_image date_field="date2"></span>
                    </div>
                </div>
            </div>
            <div class="form-group">
                <cf_wrk_search_button button_type='1'> 
            </div>
        </cf_box_search>
    </cfform>
</cf_box>
<cf_box title="#getLang('','Satış Haritası','62755')#">
    <div id="chartdiv"></div>
</cf_box>


<script>
    am4core.ready(function() {
    
        // Themes begin
        am4core.useTheme(am4themes_animated);
        // Themes end
    
        var continents = {
        "AF": 0,
        "AN": 1,
        "AS": 2,
        "EU": 3,
        "NA": 4,
        "OC": 5,
        "SA": 6
        }
    
        // Create map instance
        var chart = am4core.create("chartdiv", am4maps.MapChart);
        chart.projection = new am4maps.projections.Miller();
    
        // Create map polygon series for world map
        var worldSeries = chart.series.push(new am4maps.MapPolygonSeries());
        worldSeries.useGeodata = true;
        worldSeries.geodata = am4geodata_worldLow;
        worldSeries.exclude = ["AQ"];
        worldSeries.heatRules.push({
            property: "fill",
            target: worldSeries.mapPolygons.template,
            min: chart.colors.getIndex(1).brighten(1.8), //Bar rengi Az olan Kısım
            max: chart.colors.getIndex(5).brighten(-0.6) // Bar rengi Çok olan Kısım
        });

        var worldPolygon = worldSeries.mapPolygons.template;
        worldPolygon.tooltipText = "{name}";
        worldPolygon.nonScalingStroke = true;
        worldPolygon.strokeOpacity = 0.5;
        
        var hs = worldPolygon.states.create("hover");
        hs.properties.fill = chart.colors.getIndex(8);
    
    
        // Create country specific series (but hide it for now)
        var countrySeries = chart.series.push(new am4maps.MapPolygonSeries());
        countrySeries.heatRules.push({
            property: "fill",
            target: countrySeries.mapPolygons.template,
            min: chart.colors.getIndex(1).brighten(1.8), //Bar rengi Az olan Kısım
            max: chart.colors.getIndex(5).brighten(-0.6) // Bar rengi Çok olan Kısım
        });
        countrySeries.tooltip.label.interactionsEnabled = true;
        countrySeries.tooltip.keepTargetHover = true;
        countrySeries.calculateVisualCenter = true;
        countrySeries.mapPolygons.template.tooltipPosition = "fixed";
        countrySeries.useGeodata = true;
        countrySeries.hide();
        countrySeries.geodataSource.events.on("done", function(ev) {
        worldSeries.hide();
        countrySeries.show();
        });
    
        var countryPolygon = countrySeries.mapPolygons.template;
        countryPolygon.tooltipText = "{name}";
        countryPolygon.nonScalingStroke = true;
        countryPolygon.strokeOpacity = 0.5;
        countryPolygon.fill = am4core.color("#C0C0C0");
        
        var hs = countryPolygon.states.create("hover");
        hs.properties.fill = chart.colors.getIndex(8);
    
        // Set up click events
        worldPolygon.events.on("hit", function(ev) {
        ev.target.series.chart.zoomToMapObject(ev.target);
        var map = ev.target.dataItem.dataContext.map;
        if (map) {
            ev.target.isHover = false;
            countrySeries.geodataSource.url = "https://www.amcharts.com/lib/4/geodata/json/" + map + ".json";
            countrySeries.geodataSource.load();
        }
        });
    
        // Set up data for countries
        var data = [];
        country_codes = "<cfoutput>#valuelist(get_satis.COUNTRY_CODE)#</cfoutput>"; 
        c_array = country_codes.split(",");
        c_list = <cfoutput>#c_list#</cfoutput>;
        for(var id in am4geodata_data_countries2) {
            if (am4geodata_data_countries2.hasOwnProperty(id)) {
                var country = am4geodata_data_countries2[id];
                if (country.maps.length) {
                    if(c_array.includes(id)){
                        c_list.forEach(function (item, index) {
                            if(item.COUNTRY_CODE == id){
                                data.push(
                                    <cfoutput>
                                        {
                                            id: id,
                                            color: chart.colors.getIndex(continents[country.continent_code]),
                                            map: country.maps[0],
                                            value: item.TOPLAM,
                                            money: '#session.ep.MONEY#'
                                        }<cfif get_satis.currentrow neq get_satis.RecordCount>, </cfif>
                                    </cfoutput>
                                );
                            }
                        })
                    }
                }
            }
        }
        worldSeries.data = data;
        worldPolygon.tooltipText = "{name}: {value} {money}";

        // Set up data for cities
        var data_city = [];
        data_city.push(
            <cfoutput query="get_satis_sehir">
                {
                    id: "#COUNTRY_CODE#-#PLATE_CODE#",
                    value: #TOPLAM#,
                    money: '#session.ep.MONEY#'
                }<cfif get_satis_sehir.currentrow neq get_satis_sehir.RecordCount>, </cfif>
            </cfoutput>
        );

        countrySeries.data = data_city;
        countryPolygon.tooltipHTML = '<a id="{id}" href="javascript://" onclick="get_sales_detail(this.id)"> <font color="white">{name}: {value} {money}</font></a>';
    
        // Zoom control
        chart.zoomControl = new am4maps.ZoomControl();
    
        var homeButton = new am4core.Button();
        homeButton.events.on("hit", function() {
        worldSeries.show();
        countrySeries.hide();
        chart.goHome();
        });
    
        homeButton.icon = new am4core.Sprite();
        homeButton.padding(7, 5, 7, 5);
        homeButton.width = 30;
        homeButton.icon.path = "M16,8 L14,8 L14,16 L10,16 L10,10 L6,10 L6,16 L2,16 L2,8 L0,8 L8,0 L16,8 Z M16,8";
        homeButton.marginBottom = 10;
        homeButton.parent = chart.zoomControl;
        homeButton.insertBefore(chart.zoomControl.plusButton);
    
        // heat legend
        let heatLegend = chart.createChild(am4maps.HeatLegend);
        heatLegend.series = worldSeries;
        heatLegend.padding(20, 20, 20, 20);
        heatLegend.valign = "bottom";
        heatLegend.width = am4core.percent(20); //Az-Çok barın uzuluğu
        heatLegend.marginRight = am4core.percent(400); //Az-Çok barın konumu
        homeButton.marginBottom = 1;
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

    }); // end am4core.ready()

    function get_sales_detail(city_id) {
        openBoxDraggable("<cfoutput>#request.self#</cfoutput>?fuseaction=sales.map_sales_report&city_code="+ city_id +"&<cfoutput>start_date=#attributes.date1#&finish_date=#attributes.date2#</cfoutput>","","ui-draggable-box-large");  
    }
</script>