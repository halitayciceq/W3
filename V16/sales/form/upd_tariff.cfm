<!----15042019 Tarife ve Ürün Güncelleme İlker Altındal ----->
<cfinclude template="../../sales/query/get_money.cfm">
<cfinclude template="../../sales/query/get_counter_type.cfm">
<cfinclude template="../../product/query/get_price_cat.cfm">
<cfquery name="get_tariff" datasource="#DSN3#">
    SELECT 
        P.PRODUCT_ID, P.PRODUCT_NAME, ST.TARIFF_ID, ST.TARIFF_NAME, ST.STOCK_ID, ST.PRODUCT_ID, ST.PRODUCT_UNIT_ID, ST.PRODUCT_UNIT, ST.PRICE_LIST, ST.TARIFF_PRICE, ST.MONEY_TYPE, ST.IS_ACTIVE, ST.RECORD_DATE, ST.RECORD_EMP, ST.RECORD_IP, ST.UPDATE_DATE, ST.UPDATE_EMP, ST.UPDATE_IP
    FROM 
        SUBSCRIPTION_TARIFF AS ST 
    LEFT JOIN
        PRODUCT AS P ON P.PRODUCT_ID = ST.PRODUCT_ID
    WHERE TARIFF_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.tariff_id#">
</cfquery>
<cfquery name="products_services" datasource="#DSN3#">
    SELECT 
       ST.TARIFF_ID, SAP.ADDITIONAL_ID, SAP.STOCK_ID, SAP.PRODUCT_ID, SAP.CAL_METHOD, SAP.NUMBER, SAP.PRICE_LIST, SAP.SPECIAL_PRICE, SAP.MONEY_TYPE, P.PRODUCT_ID, P.PRODUCT_NAME
    FROM 
        SUBSCRIPTION_ADDITIONAL_PRODUCT AS SAP 
    LEFT JOIN 
        SUBSCRIPTION_TARIFF AS ST ON ST.TARIFF_ID = SAP.TARIFF_ID
    LEFT JOIN
        PRODUCT AS P ON P.PRODUCT_ID = SAP.PRODUCT_ID
    WHERE SAP.TARIFF_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.tariff_id#">
</cfquery>
<cfquery name="taxes_and_funds" datasource="#DSN3#">
    SELECT
        ST.TARIFF_ID, STF.TAX_FUNDS_ID, STF.ACCOUNT_CODE, STF.CAL_METHOD, STF.NUMBER, STF.PRICE, STF.MONEY_TYPE
    FROM 
        SUBSCRIPTION_TAX_FUNDS AS STF
    LEFT JOIN
        SUBSCRIPTION_TARIFF AS ST ON ST.TARIFF_ID = STF.TARIFF_ID
    WHERE
        STF.TARIFF_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.tariff_id#"> 
</cfquery>
<cf_catalystHeader>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box>
        <cfform name="form_upd_tariff" method="post" action="V16/sales/query/upd_tariff.cfm">
            <input type="hidden" name="tariff_id" id="tariff_id" value="<cfoutput>#get_tariff.TARIFF_ID#</cfoutput>">
            <input type="hidden" name="tax_funds_id" value="<cfoutput>#taxes_and_funds.TAX_FUNDS_ID#</cfoutput>">
            <input type="hidden" name="tariff_additional_product" id="tariff_additional_product" value="<cfoutput>#products_services.recordcount#</cfoutput>">
            <input type="hidden" name="tariff_tax_funds" id="tariff_tax_funds" value="<cfoutput>#taxes_and_funds.recordcount#</cfoutput>">
            <cf_box_elements>
                <div class="col col-4 col-md-6 col-xs-12" type="column" index="1" sort="true">
                    <div class="form-group" id="item-tariff_name">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='40977.Tarife Adı'> *</label>
                        <div class="col col-8 col-xs-12">                          
                            <input type="text" name="tariff_name" id="tariff_name" value="<cfif len(get_tariff.TARIFF_NAME)><cfoutput>#get_tariff.TARIFF_NAME#</cfoutput></cfif>">
                        </div>
                    </div>
                    <div class="form-group" id="item-main_product">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='37164.Ana Ürün'> *</label>
                        <div class="col col-8 col-xs-12">  
                            <div class="input-group">
                                <input type="hidden" name="stock_id" id="stock_id" value="<cfif len(get_tariff.STOCK_ID)><cfoutput>#get_tariff.STOCK_ID#</cfoutput></cfif>">
                                <input type="hidden" name="product_id" id="product_id" value="<cfif len(get_tariff.PRODUCT_ID)><cfoutput>#get_tariff.PRODUCT_ID#</cfoutput></cfif>">                        
                                <input type="text" name="main_product" id="main_product" value="<cfif len(get_tariff.PRODUCT_NAME)><cfoutput>#get_tariff.PRODUCT_NAME#</cfoutput></cfif>" readonly>
                                <span class="input-group-addon btn_Pointer icon-ellipsis" href="javascript://" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_product_price_unit&field_stock_id=form_upd_tariff.stock_id&field_id=form_upd_tariff.product_id&field_unit_id=form_upd_tariff.unit_id&field_unit=form_upd_tariff.product_unit&field_name=form_upd_tariff.main_product');"></span>
                            </div>
                        </div>
                    </div>
                    <div class="form-group" id="item-product_unit">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='37307.Ürün Birim'> *</label>
                        <div class="col col-8 col-md-1 col-sm-1 col-xs-6">
                            <input type="hidden" name="unit_id" id="unit_id" value="<cfif len(get_tariff.PRODUCT_UNIT_ID)><cfoutput>#get_tariff.PRODUCT_UNIT_ID#</cfoutput></cfif>">
                            <input type="text" name="product_unit" id="product_unit" value="<cfif len(get_tariff.PRODUCT_UNIT)><cfoutput>#get_tariff.PRODUCT_UNIT#</cfoutput></cfif>" readonly="readonly">
                        </div> 
                    </div>
                </div>   
                <div class="col col-4 col-md-6 col-sm-6 col-xs-12" type="column" index="2" sort="true">
                    <div class="form-group" id="item-active">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58515.Aktif/Pasif'></label>
                        <div class="col col-8 col-xs-12">                          
                            <input type="checkbox" name="active" id="active" <cfif get_tariff.IS_ACTIVE eq 1>checked</cfif>>
                        </div>
                    </div>
                    <div class="form-group" id="item-price_list">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58964.Fiyat Listesi'> *</label>
                        <div class="col col-8 col-xs-12">                          
                            <select name="price_list" id="price_list">
                                <option value="-1" <cfif get_tariff.PRICE_LIST eq -1>selected</cfif>><cf_get_lang dictionary_id='58722.Standart Alış'></option>
                                <option value="-2" <cfif get_tariff.PRICE_LIST eq -2>selected</cfif>><cf_get_lang dictionary_id='58721.Standart Satış'></option>
                                <cfoutput query="get_price_cat">
                                    <option value="#PRICE_CATID#" <cfif get_tariff.PRICE_LIST eq #PRICE_CATID#>selected</cfif>>#PRICE_CAT#</option>
                                </cfoutput>
                            </select>
                        </div>
                    </div>
                    <div class="form-group" id="item-tariff_price">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='40978.Tarife Fiyatı'> *</label>
                        <div class="col col-6 col-xs-8">                          
                            <input type="text" name="tariff_price" id="tariff_price" value="<cfif len(get_tariff.TARIFF_PRICE)><cfoutput>#tlFormat(get_tariff.TARIFF_PRICE)#</cfoutput></cfif>" onkeyup='return(FormatCurrency(this,event,4));' class='moneybox'>
                        </div>
                        <div class="col col-2 col-xs-4">                          
                            <select name="money" id="money">
                                <cfoutput query="get_money"> 
                                    <option value="#money#" <cfif get_tariff.MONEY_TYPE eq #money#>selected</cfif>>#money#</option>
                                </cfoutput>
                            </select> 
                        </div>
                    </div>
                </div>
                <div class="col col-12 col-md-12 col-sm-12 col-xs-12">
                    <div class="col col-6">
                        <cf_seperator id="products_services" header="#getLang('','Ek Ürün ve Hizmetler',40979)#">
                        <cf_grid_list id="products_services">
                            <thead>
                                <th width="20" class='text-center'><a href="javascript://" onClick="addRow()"><i class="fa fa-plus" title="<cf_get_lang dictionary_id='57582.Ekle'>" alt="<cf_get_lang dictionary_id='57582.Ekle'>"></i></a></th>
                                <th width="150"><cf_get_lang dictionary_id='57657.Ürün'> / <cf_get_lang dictionary_id='51488.Hizmet'></th>
                                <th><cf_get_lang dictionary_id='50010.Hesaplama Yöntemi'></th>
                                <th><cf_get_lang dictionary_id='55486.Rakam'></th>
                                <th width="100"><cf_get_lang dictionary_id='58964.Fiyat Listesi'></th>
                                <th width="150"><cf_get_lang dictionary_id='33086.Özel Fiyat'></th>
                            </thead>
                            <tbody id="products_services">
                                <cfoutput query="products_services">
                                    <tr id="#currentrow#">
                                        <input type="hidden" name="additional_id#currentrow#" value="#ADDITIONAL_ID#">
                                        <input type='hidden' name='satir#currentrow#' id='satir#currentrow#' value='1'>
                                        <td class="text-center"><a style='cursor:pointer;' onclick='sil(#currentrow#);'><i class='fa fa-minus'></i></a><input name='productRow' value='#currentrow#' type='hidden'></td>
                                        <td><div class="form-group"><div class="input-group"><input type='hidden' name='stock_id#currentrow#' id='stock_id#currentrow#' value="#STOCK_ID#"><input type='hidden' name='product_id#currentrow#' value="#PRODUCT_ID#"><input type='text' name='product_name#currentrow#' value="#PRODUCT_NAME#"><span class="input-group-addon icon-ellipsis" onclick='pencere_ac_product(#currentrow#);'></span></div></div></td>
                                        <td><div class="form-group"><select name='hesaplama#currentrow#'><option value='1' <cfif CAL_METHOD eq 1> selected</cfif>><cf_get_lang dictionary_id='58544.Sabit'></option><option value='2' <cfif CAL_METHOD eq 2> selected</cfif>><cf_get_lang dictionary_id='58865.Çarpan'> (%)</option><option value='3' <cfif CAL_METHOD eq 3> selected</cfif>><cf_get_lang dictionary_id='62234.Çarpan Miktar'></option></select></div></td>
                                        <td><div class="form-group"><input type='text' name='urun_rakam#currentrow#' class='moneybox' value="#NUMBER#"></div></td>
                                        <td><div class="form-group"><select name='fiyatListesi#currentrow#'><option value='-1' <cfif PRICE_LIST eq -1> selected</cfif>><cf_get_lang dictionary_id='58722.Standart Alış'></option><option value='-2' <cfif PRICE_LIST eq -2> selected</cfif>><cf_get_lang dictionary_id='58721.Standart Satış'></option><cfloop query="get_price_cat"><option value="#PRICE_CATID#" <cfif products_services.PRICE_LIST eq PRICE_CATID> selected</cfif>>#PRICE_CAT#</option></cfloop></select></div></td>
                                        <td>
                                            <div class="form-group col col-8">
                                                <input type='text' name='ozel_fiyat#currentrow#' value="#tlFormat(SPECIAL_PRICE)#" onkeyup='return(FormatCurrency(this,event,4));' class='moneybox'>
                                            </div>
                                            <div class="form-group col col-4">
                                                <select name='money#currentrow#'><cfloop query="get_money"><option value='#money#' <cfif products_services.MONEY_TYPE eq money> selected</cfif>>#money#</option></cfloop></select>
                                            </div>
                                        </td>
                                    </tr>
                                </cfoutput>
                            </tbody>
                        </cf_grid_list>
                    </div>
                    <div class="col col-6">
                        <cf_seperator id="taxes_and_funds" header="#getLang('','Vergi ve Fonlar',62228)#">
                        <cf_grid_list id="taxes_and_funds">
                            <thead>
                                <th width="20" class='text-center'><a href="javascript://" onClick="addrowTax()"><i class="fa fa-plus"></i></th>
                                <th><cf_get_lang dictionary_id='40982.vergi/fon türü'></th>
                                <th><cf_get_lang dictionary_id='50010.Hesaplama Yöntemi'></th>
                                <th><cf_get_lang dictionary_id='55486.Rakam'></th>
                                <th><cf_get_lang dictionary_id='57673.Tutar'> / <cf_get_lang dictionary_id='57489.Para Birimi'></th>
                            </thead>
                            <tbody id="taxes_and_funds">
                                <cfoutput query="taxes_and_funds">
                                    <tr id="#currentrow#">
                                        <input type="hidden" name="tax_funds_id#currentrow#" value="#TAX_FUNDS_ID#">
                                        <input type='hidden' name='satirTax#currentrow#' id='satirTax#currentrow#' value='1'>
                                        <td class="text-center"><a style='cursor:pointer;' onclick='silTax(#currentrow#);'><i class='fa fa-minus'></i></a><input name='taxRow' value='#currentrow#' type='hidden'></td>
                                        <td><div class="form-group"><div class="input-group"><input type='text' name='account_code#currentrow#' value="#ACCOUNT_CODE#"> <span class='input-group-addon icon-ellipsis' onclick='pencere_ac_acc(#currentrow#);'></span></div></td>
                                        <td><div class="form-group"><select id='hesaplamaTax' name='hesaplamaTax#currentrow#' onchange='hesaplamaYontemi(this.value,#currentrow#);'><option value='1' <cfif CAL_METHOD eq 1> selected</cfif>><cf_get_lang dictionary_id='58544.Sabit'></option><option value='2' <cfif CAL_METHOD eq 2> selected</cfif>><cf_get_lang dictionary_id='58865.Çarpan'> (%)</option><option value='3' <cfif CAL_METHOD eq 3> selected</cfif>><cf_get_lang dictionary_id='62234.Çarpan Miktar'></option></select></div></td>
                                        <td><div class="form-group"><input type='text' name='rakamTax#currentrow#' value="#NUMBER#" class='moneybox'></div></td>
                                        <td>
                                            <div class="form-group col col-8">
                                                <input type='text' name='tutar#currentrow#' id='tutar' value="#tlFormat(PRICE)#" onkeyup='return(FormatCurrency(this,event,4));' class='moneybox'>
                                            </div> 
                                            <div class="form-group col col-4">
                                                <select name='moneyTax#currentrow#'><cfloop query='get_money'><option value='#money#' <cfif taxes_and_funds.MONEY_TYPE eq money> selected</cfif>>#money#</option></cfloop></select>
                                            </div>
                                        </td>
                                    </tr>
                                </cfoutput>
                            </tbody>
                        </cf_grid_list>
                    </div>
                </div>
            </cf_box_elements>
            <cf_box_footer>
                <div class="col col-6">
                    <cf_record_info query_name="get_tariff">
                </div>
                <div class="col col-6">
                    <cf_workcube_buttons is_upd='1' add_function='kontrol()'>
                </div>
            </cf_box_footer>
        </cfform>
    </cf_box>
</div>

<script>
     /* ek ürün ve hizmet satırları oluşturulması */
    var jsonArray = [
        {
        "sil" : "<a style='cursor:pointer;' onclick='sil(###id###);'><i class='fa fa-minus'></i></a><input name='productRow' value='###id###' type='hidden'>",
        "urun" : "<div class='form-group'><div class='input-group'><input type='hidden' name='stock_id###id###' id='stock_id###id###'><input type='hidden' name='product_id###id###'><input type='text' name='product_name###id###'> <span class='input-group-addon icon-ellipsis' onclick='pencere_ac_product(###id###);'></span></div></div>",
        "hesaplamaYontemi": "<div class='form-group'><select name='hesaplama###id###'><option value='1'><cf_get_lang dictionary_id='58544.Sabit'></option><option value='2'><cf_get_lang dictionary_id='58865.Çarpan'> (%)</option><option value='3'><cf_get_lang dictionary_id='62234.Çarpan Miktar'></option></select></div>",
        "rakam": "<div class='form-group'><input type='text' name='urun_rakam###id###' onkeyup='return(FormatCurrency(this,event,4));' class='moneybox'></div>",
        "fiyatListesi": "<div class='form-group'><select name='fiyatListesi###id###'><option value='-1'><cf_get_lang dictionary_id='58722.Standart Alış'></option><option value='-2'><cf_get_lang dictionary_id='58721.Standart Satış'></option><cfoutput query='get_price_cat'><option value='#PRICE_CATID#'>#PRICE_CAT#</option></cfoutput></select></div>",
        "ozelFiyat":"<div class='form-group col col-8'><input type='text' name='ozel_fiyat###id###' onkeyup='return(FormatCurrency(this,event,4));' class='moneybox'></div>",
        "paraBirimi":"<div class='form-group col col-4'><select name='money###id###'><cfoutput query='get_money'><option value='#money#'>#money#</option></cfoutput></select></div>"
        }
  ];
     /* vergi ve fon satırları oluşturulması */
    var jsonTaxArray = [
        {
            "sil" : "<a style='cursor:pointer;' onclick='silTax(###id###);'><i class='fa fa-minus'></i></a><input name='taxRow' value='###id###' type='hidden'>",
            "muhasebe_kodu" : "<div class='form-group'><div class='input-group'><input type='text' name='account_code###id###'> <span class='input-group-addon icon-ellipsis' onclick='pencere_ac_acc(###id###);'></span></div></div>",
            "hesaplamaYontemi": "<div class='form-group'><select name='hesaplamaTax###id###' onchange='hesaplamaYontemi(this.value,###id###);'><option value='1'><cf_get_lang dictionary_id='58544.Sabit'></option><option value='2'><cf_get_lang dictionary_id='58865.Çarpan'> (%)</option><option value='3'><cf_get_lang dictionary_id='62234.Çarpan Miktar'></option></select></div>",
            "rakam": "<div class='form-group'><input type='text' name='rakamTax###id###' class='moneybox'></div>",
            "tutar":"<div class='form-group col col-8'><input type='text' name='tutar###id###' id='tutar' onkeyup='return(FormatCurrency(this,event,4));' class='moneybox'></div>",
            "paraBirimi":"<div class='form-group col col-4'><select name='moneyTax###id###'><cfoutput query='get_money'><option value='#money#'>#money#</option></cfoutput></select></div>"
        }
    ];

    /* ek ürün ve hizmet yeni satıra dönüştürülmesi */
    var row_count_service = parseInt($("input[name=tariff_additional_product]").val());
    function addRow(){
            row_count_service +=1;
            jsonArray.filter((a) => {
                var template="<tr id='"+row_count_service+"'><input type='hidden' name='satir###id###' id='satir###id###' value='1'><td class='text-center'>{sil}</td><td>{urun}</td><td>{hesaplamaYontemi}</td><td>{rakam}</td><td>{fiyatListesi}</td><td>{ozelFiyat} {paraBirimi}</td></tr>";
                $('#products_services').append(nano( template, a ).replace(/###id###/g,row_count_service));
            });
        }

    /* vergi ve fon yeni satıra dönüştürülmesi */
    var row_count_tax = parseInt($("input[name=tariff_tax_funds]").val());
    
    function addrowTax(){
            row_count_tax += 1;
            jsonTaxArray.filter((a) => {
                var template = "<tr id='"+row_count_tax+"'><input type='hidden' name='satirTax###id###' id='satirTax###id###' value='1'><td class='text-center'>{sil}</td><td>{muhasebe_kodu}</td><td>{hesaplamaYontemi}</td><td>{rakam}</td><td>{tutar} {paraBirimi}</td></tr>";
                $('#taxes_and_funds').append(nano( template, a ).replace(/###id###/g,row_count_tax));
            });
    }

    function hesaplamaYontemi(val,id){
    if(val == 1) $("input[name=tutar"+id).show();
    else $("input[name=tutar"+id).hide().html("");
    }

    function pencere_ac_product(no) /* satıra ürün düşürme için */
    {	
        openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_product_names&product_id=form_upd_tariff.product_id' + no + '&field_id=form_upd_tariff.stock_id' + no + '&field_name=form_upd_tariff.product_name'+no);
    }

    function pencere_ac_acc(no) /* satıra muhasebe kodu düşürme için */
    {
        windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_account_plan&field_id=form_upd_tariff.account_code' + no +'','list');
    }

    function sil(no)
    {
        $("#products_services tr#"+no).hide();
        $("#satir"+no).val("0");
    }
    function silTax(no)
    {
        $("#taxes_and_funds tr#"+no).hide();
        $("#satirTax"+no).val("0");
    }
    function kontrol(){
        if( $("#tariff_name").val() == "" || $("#product_id").val() == "" || $("#product_unit").val() == "" || $("#price_list").val() == "" || $("#tariff_price").val() == "")
        {
            alert("<cf_get_lang dictionary_id='29722.Zorunlu Alanları Doldurunuz'>"); return false;
        }
        unformat_fields();
    }
    
    function unformat_fields()
    {
        document.form_upd_tariff.tariff_price.value = filterNum(document.form_upd_tariff.tariff_price.value,4);

        for(var j=1; j <= row_count_service; j++)
        {
            $("input[name=ozel_fiyat"+j).val(filterNum($("input[name=ozel_fiyat"+j).val()));
        }

        for(var k=1; k <= row_count_tax ; k++)
        {
            $("input[name=tutar"+k).val(filterNum($("input[name=tutar"+k).val()));
        }
        

    }
        $(document).ready(function(){
            for(var m=1; m<=row_count_tax; m++){
                if($("select[name=hesaplamaTax"+m)[0].selectedIndex == 1)
                {
                    $("input[name=tutar"+m+"]").hide();
                }
            }
        });

</script>