<!----09042019 Tarife ve Ürün Ekle İlker Altındal ----->
<cfinclude template="../../sales/query/get_money.cfm">
<cfinclude template="../../sales/query/get_counter_type.cfm">
<cfinclude template="../../product/query/get_price_cat.cfm">
<cf_catalystHeader>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box>
        <cfform name="form_add_tariff" method="post" action="V16/sales/query/add_tariff.cfm">
            <cf_box_elements>
                <div class="col col-4 col-md-6 col-xs-12" type="column" index="1" sort="true">
                    <div class="form-group" id="item-tariff_name">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='40977.Tarife Adı'> *</label>
                        <div class="col col-8 col-xs-12">                          
                            <input type="text" name="tariff_name" id="tariff_name" value="">
                        </div>
                    </div>
                    <div class="form-group" id="item-main_product">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='37164.Ana Ürün'> *</label>
                        <div class="col col-8 col-xs-12">  
                            <div class="input-group">
                                <input type="hidden" name="stock_id" id="stock_id" value="">
                                <input type="hidden" name="product_id" id="product_id" value="">                        
                                <input type="text" name="main_product" id="main_product" value="" readonly>                                                                        
                                <span class="input-group-addon btn_Pointer icon-ellipsis" href="javascript://" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_product_price_unit&field_stock_id=form_add_tariff.stock_id&field_id=form_add_tariff.product_id&field_unit_id=form_add_tariff.unit_id&field_unit=form_add_tariff.product_unit&field_name=form_add_tariff.main_product');"></span>
                            </div>
                        </div>
                    </div>
                    <div class="form-group" id="item-product_unit">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='37307.Ürün Birim'> *</label>
                        <div class="col col-8 col-xs-12">
                            <input type="hidden" name="unit_id" id="unit_id" value="">
                            <input type="text" name="product_unit" id="product_unit" value="" readonly="readonly">
                        </div>                         
                    </div>
                </div>   
                <div class="col col-4 col-md-6 col-sm-6 col-xs-12" type="column" index="2" sort="true">
                    <div class="form-group" id="item-active">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58515.Aktif/Pasif'></label>
                        <div class="col col-8 col-xs-12">                          
                            <input type="checkbox" name="active" id="active" value="1">
                        </div>
                    </div>
                    <div class="form-group" id="item-price_list">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58964.Fiyat Listesi'> *</label>
                        <div class="col col-8 col-xs-12">                          
                            <select name="price_list" id="price_list">
                                <option value="-1"><cf_get_lang dictionary_id='58722.Standart Alış'></option>
                                <option value="-2"><cf_get_lang dictionary_id='58721.Standart Satış'></option>
                                <cfoutput query="get_price_cat">
                                    <option value="#PRICE_CATID#">#PRICE_CAT#</option>
                                </cfoutput>
                            </select>
                        </div>
                    </div>
                    <div class="form-group" id="item-tariff_price">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='40978.Tarife Fiyatı'> *</label>
                        <div class="col col-6 col-xs-8">                          
                            <input type="text" name="tariff_price" id="tariff_price" onkeyup='return(FormatCurrency(this,event,4));' class='moneybox'>
                        </div>
                        <div class="col col-2 col-xs-4">                          
                            <select name="money" id="money">
                                <cfoutput query="get_money"> 
                                    <option value="#money#">#money#</option>
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
                            <tbody id="products_services"></tbody>
                        </cf_grid_list>
                    </div>
                    <div class="col col-6">
                        <cf_seperator id="taxes_and_funds" header="#getLang('','Vergi ve Fonlar',62228)#">
                        <cf_grid_list id="taxes_and_funds">
                            <thead>
                                <th width="20" class='text-center'><a href="javascript://" onClick="addrowTax()"><i class="fa fa-plus" title="<cf_get_lang dictionary_id='57582.Ekle'>" alt="<cf_get_lang dictionary_id='57582.Ekle'>"></i></th>
                                <th><cf_get_lang dictionary_id='40982.ve'></th>
                                <th><cf_get_lang dictionary_id='50010.Hesaplama Yöntemi'></th>
                                <th><cf_get_lang dictionary_id='55486.Rakam'></th>
                                <th><cf_get_lang dictionary_id='57673.Tutar'> / <cf_get_lang dictionary_id='57489.Para Birimi'></th>
                            </thead>
                            <tbody id="taxes_and_funds"></tbody>
                        </cf_grid_list>
                    </div>
                </div>
            </cf_box_elements>
            <cf_box_footer>
                <cf_workcube_buttons is_upd='0' add_function='kontrol()'>
            </cf_box_footer>
        </cfform>
    </cf_box>
</div>
<script>

    $(document).ready(function(){
        $("#tutar").hide();
    });

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
            "rakam": "<div class='form-group'><input type='text' name='rakamTax###id###' onkeyup='return(FormatCurrency(this,event,4));' class='moneybox'></div>",
            "tutar":"<div class='form-group col col-8'><input type='text' name='tutar###id###' id='tutar' onkeyup='return(FormatCurrency(this,event,4));' class='moneybox'></div>",
            "paraBirimi":"<div class='form-group col col-4'><select name='moneyTax###id###'><cfoutput query='get_money'><option value='#money#'>#money#</option></cfoutput></select></div>"
        }
    ];
    /* ek ürün ve hizmet yeni satıra dönüştürülmesi */
    var row_count_service = 0;
    function addRow(){
            row_count_service +=1;
            jsonArray.filter((a) => {
                var template="<tr id='"+row_count_service+"'><input type='hidden' name='satir###id###' id='satir###id###' value='1'><td width='20' class='text-center'>{sil}</td><td>{urun}</td><td>{hesaplamaYontemi}</td><td>{rakam}</td><td>{fiyatListesi}</td><td>{ozelFiyat} {paraBirimi}</td></tr>";
                $('#products_services').append(nano( template, a ).replace(/###id###/g,row_count_service));
            });
        }
    /* vergi ve fon yeni satıra dönüştürülmesi */
    var row_count_tax = 0;
    function addrowTax(){
            row_count_tax += 1;
            jsonTaxArray.filter((a) => {
                var template = "<tr id='"+row_count_tax+"'><input type='hidden' name='satirTax###id###' id='satirTax###id###' value='1'><td width='20' class='text-center'>{sil}</td><td>{muhasebe_kodu}</td><td>{hesaplamaYontemi}</td><td>{rakam}</td><td>{tutar} {paraBirimi}</td></tr>";
                $('#taxes_and_funds').append(nano( template, a ).replace(/###id###/g,row_count_tax));
            });
    }
    function hesaplamaYontemi(val,id){
        if(val == 1) $("input[name=tutar"+id).show();
        else $("input[name=tutar"+id).hide().html("");
    }

    function pencere_ac_product(no) /* satıra ürün düşürme için */
	{	
		openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_product_names&product_id=form_add_tariff.product_id' + no + '&field_id=form_add_tariff.stock_id' + no + '&field_name=form_add_tariff.product_name'+no);
	}

    function pencere_ac_acc(no) /* satıra muhasebe kodu düşürme için */
	{
		windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_account_plan&field_id=form_add_tariff.account_code' + no +'','list');
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
    }
</script>