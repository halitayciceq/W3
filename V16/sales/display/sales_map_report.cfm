<cfparam name="attributes.start_date" default="">
<cfparam name="attributes.finish_date" default="">
<cfscript>
    getComponent = createObject('component','V16.sales.cfc.sales_map_report');
    country_id = listFirst(attributes.city_code,"-");
    city_id = listLast(attributes.city_code,"-");
    get_sales_by_city = getComponent.get_sales_by_city(city_code:city_id,date1:attributes.start_date,date2:attributes.finish_date);
    get_sales_by_product = getComponent.get_sales_by_product(city_code:city_id,date1:attributes.start_date,date2:attributes.finish_date);
    get_sales_by_product_cat = getComponent.get_sales_by_product_cat(city_code:city_id,date1:attributes.start_date,date2:attributes.finish_date);
</cfscript>
<cf_box title="#getLang('','Satış Haritası Raporu',65843)#" popup_box="1">
    <div class="col col-4 col-md-6 col-sm-6 col-xs-12">
        <cf_seperator id="by_customer" header="#getLang('','Müşteriye Göre',39300)#">
        <cf_grid_list  id="by_customer">
            <thead>
                <tr>
                    <th><cf_get_lang dictionary_id='57457.Müşteri'></th>
                    <th class="text-right"><cf_get_lang dictionary_id='57673.Tutar'></th>
                    <th></th>
                </tr>
            </thead>
            <tbody>
                <cfif get_sales_by_city.recordcount>
                    <cfoutput query="get_sales_by_city">
                        <tr>
                            <td>#FULLNAME#</td>
                            <td class="text-right">#TLFormat(TOPLAM)#</td>
                            <td>#session.ep.money#</td>
                        </tr>
                    </cfoutput>
                </cfif>
            </tbody>
        </cf_grid_list>
        <cfif get_sales_by_city.recordcount eq 0>
            <div class="ui-info-bottom">
                <p><cf_get_lang dictionary_id='57484.Kayıt Bulunamadı'>!</p>
            </div>
        </cfif>
    </div>
    <div class="col col-4 col-md-6 col-sm-6 col-xs-12">
        <cf_seperator id="by_customer" header="#getLang('','Ürüne Göre',35986)#">
        <cf_grid_list  id="by_customer">
            <thead>
                <tr>
                    <th><cf_get_lang dictionary_id='57657.Ürün'></th>
                    <th class="text-right"><cf_get_lang dictionary_id='57673.Tutar'></th>
                    <th></th>
                </tr>
            </thead>
            <tbody>
                <cfif get_sales_by_product.recordcount>
                    <cfoutput query="get_sales_by_product">
                        <tr>
                            <td>#NAME_PRODUCT#</td>
                            <td class="text-right">#TLFormat(TOPLAM)#</td>
                            <td>#session.ep.money#</td>
                        </tr>
                    </cfoutput>
                </cfif>
            </tbody>
        </cf_grid_list>
        <cfif get_sales_by_product.recordcount eq 0>
            <div class="ui-info-bottom">
                <p><cf_get_lang dictionary_id='57484.Kayıt Bulunamadı'>!</p>
            </div>
        </cfif>
    </div>
    <div class="col col-4 col-md-6 col-sm-6 col-xs-12">
        <cf_seperator id="by_customer" header="#getLang('','Ürün Kategorisine Göre',37970)#">
        <cf_grid_list  id="by_customer">
            <thead>
                <tr>
                    <th><cf_get_lang dictionary_id='29401.Ürün Kategorisi'></th>
                    <th class="text-right"><cf_get_lang dictionary_id='57673.Tutar'></th>
                    <th></th>
                </tr>
            </thead>
            <tbody>
                <cfif get_sales_by_product_cat.recordcount>
                    <cfoutput query="get_sales_by_product_cat">
                        <tr>
                            <td>#PRODUCT_CAT#</td>
                            <td class="text-right">#TLFormat(TOPLAM)#</td>
                            <td>#session.ep.money#</td>
                        </tr>
                    </cfoutput>
                </cfif>
            </tbody>
        </cf_grid_list>
        <cfif get_sales_by_product_cat.recordcount eq 0>
            <div class="ui-info-bottom">
                <p><cf_get_lang dictionary_id='57484.Kayıt Bulunamadı'>!</p>
            </div>
        </cfif>  
     </div>
</cf_box>