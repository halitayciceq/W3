<cfparam name="attributes.action_date" default="#now()#">
<cfinclude template="../../sales/query/get_money.cfm">
<cf_catalystHeader>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box>
        <cfform name="add_subs_counter_pre" method="post" action="">
            <cf_box_elements>
                <div class="col col-4 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
                    <div class="form-group" id="item-process_stage">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58859.Süreç'>*</label>
                        <div class="col col-8 col-xs-12">
                            <cf_workcube_process is_upd='0' process_cat_width='150' is_detail='0'>
                        </div>
                    </div>
                    <div class="form-group" id="item-subscription_no">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='29502.Abone No'>*</label>
                        <div class="col col-8 col-xs-12">
                            <div class="input-group">
                                <cfinput type="hidden" name="subscription_id" id="subscription_id">
                                <cfinput type="text" name="subscription_no" id="subscription_no" readonly required>
                                <span class="input-group-addon btn_Pointer icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_subscription&field_id=add_subs_counter_pre.subscription_id&field_no=add_subs_counter_pre.subscription_no&call_function=getCounterType');"></span>
                            </div>
                        </div>
                    </div>
                    <div class="form-group" id="item-counter_type">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='41282.Sayaç Tipi'> -<cf_get_lang dictionary_id='57487.No'>*</label>
                        <div class="col col-8 col-xs-12">
                            <select id="counter_id" name="counter_id" onchange="getCounterProduct(this.value)" required>
                                <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                            </select>
                        </div>
                    </div>
                    <div class="form-group" id="item-product">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id ='57657.Ürün'>*</label>
                        <div class="col col-8 col-xs-12">
                            <input type="hidden" name="stock_id" id="stock_id" value="">
                            <input type="hidden" name="product_id" id="product_id" value="">
                            <input type="text" name="product" id="product" value="" readonly="readonly" required>
                        </div>
                    </div>
                    <div class="form-group" id="item-unit_name">
                        <label class="col col-4 col-md-2 col-xs-12"><cf_get_lang dictionary_id='48888.Paket Miktar'></label>
                        <div class="col col-4 col-xs-6">
                            <input type="text" name="amount" id="amount" class="moneybox" required readonly>
                        </div>
                        <div class="col col-4 col-xs-6">
                            <input type="hidden" name="unit_id" id="unit_id" value="">
                            <input type="text" name="unit_name" id="unit_name" value="" required readonly="readonly">
                        </div>
                    </div>
                    <div class="form-group" id="item-unit_price">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57638.Birim Fiyat'>*</label>
                        <div class="col col-6 col-xs-12">
                            <cfinput type="text" name="unit_price" id="unit_price" class="moneybox" value="" required="yes" message="#getLang('main','Lütfen Tutar Giriniz',29535)#" readonly>
                        </div>
                        <div class="col col-2 col-xs-12">
                            <select name="UNIT_CURRENCY_ID" id="UNIT_CURRENCY_ID" <!--- onChange="kur_ekle_f_hesapla('UNIT_CURRENCY_ID',false,1);" --->>
                                <cfoutput query="GET_MONEY">
                                <option value="#money_id#;#money#">#money#</option>
                                </cfoutput>
                            </select> 
                        </div>
                    </div>
                </div>
                <div class="col col-4 col-md-4 col-sm-6 col-xs-12" type="column" index="2" sort="true">
                    <div class="form-group" id="item-loading_price">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='48879.Yükleme Miktarı'>*</label>
                        <div class="col col-8 col-xs-12">
                            <cfinput type="text" name="loading_price" id="loading_price" class="moneybox" value="" required="yes" message="#getLang('','Lütfen Tutar Giriniz',29535)#" onkeyup="return(FormatCurrency(this,event));">
                        </div>
                    </div>
                    <div class="form-group" id="item-total_price">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='29534.Toplam Tutar'>*</label>
                        <div class="col col-8 col-xs-12">
                            <cfinput type="text" name="total_price" id="total_price" class="moneybox" value="" required="yes" message="#getLang('','Lütfen Tutar Giriniz',29535)#" readonly>
                        </div>
                    </div>
                    <div class="form-group" id="item-loading_date">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='48882.Yükleme Tarihi'>*</label>
                        <div class="col col-8 col-xs-12">
                            <div class="input-group">
                                <cfinput type="text" name="action_date" id="action_date" maxlength="10" value="#dateformat(attributes.action_date,dateformat_style)#" validate="#validate_style#" required="yes" message="#getLang('','İşlem Tarihi Girmelisiniz',57906)#">
                                <span class="input-group-addon"><cf_wrk_date_image date_field="action_date"></span>
                            </div>
                        </div>
                    </div>
                    <div class="form-group" id="item-emp_id">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='48887.Yükleyen'>*</label>
                        <div class="col col-8 col-xs-12">
                            <div class="input-group">
                                <cfinput type="hidden" name="emp_id" id="emp_id" value="#session.ep.userid#">
                                <cfinput type="text" name="emp_name" id="emp_name" value="#session.ep.name# #session.ep.surname#" required onfocus="AutoComplete_Create('emp_name','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','3','EMPLOYEE_ID','emp_id','','3','200');" autocomplete="off">
                                <span class="input-group-addon btn_Pointer icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_positions&field_emp_id=add_subs_counter_pre.emp_id&field_name=add_subs_counter_pre.emp_name');"></span>
                            </div>
                        </div>
                    </div>
                    <!--- <div class="form-group" id="item-islem_tur">
                        <label class="col col-4 bold"><cfoutput>#getLang('contract',273)#</cfoutput></label>
                        <div class="col col-8 col-xs-12">
                            <cfscript>f_kur_ekle(is_disable:1,process_type:0,base_value:'priceBeforeTotal',other_money_value:'total_price',form_name:'add_subs_counter_pre',select_input:'UNIT_CURRENCY_ID');</cfscript>
                        </div>
                    </div> --->
                </div>
            </cf_box_elements>
            <cf_box_footer>
                <cf_workcube_buttons add_function='kontrol()'>
            </cf_box_footer>
        </cfform>
    </cf_box>
</div>

<script>
    function kontrol(){
        if(document.add_subs_counter_pre.process_stage.value == ''){
            alertObject({message: "<cf_get_lang dictionary_id='58842.Lütfen Süreç Seçiniz'>!"});
            return false;
        }
        if(document.add_subs_counter_pre.subscription_no.value == '' || document.add_subs_counter_pre.subscription_id.value == ''){
            alertObject({message: "<cf_get_lang dictionary_id='50995.Abone Seçiniz'>!"});
            return false;
        }
        if(document.add_subs_counter_pre.counter_id.value == ''){
            alertObject({message: "<cf_get_lang dictionary_id='48946.Sayaç Tipi - Sayaç No Seçiniz'>!"});
            return false;
        }
        if(document.add_subs_counter_pre.emp_id.value == '' || document.add_subs_counter_pre.emp_name.value == ''){
            alertObject({message: "<cf_get_lang dictionary_id='62242.Yükleyen alanı boş geçilemez!'>"});
            return false;
        }
        unformat_fields();
        return true;
    }

    function unformat_fields()
    {
        document.add_subs_counter_pre.amount.value = filterNum(document.add_subs_counter_pre.amount.value);
        document.add_subs_counter_pre.unit_price.value = filterNum(document.add_subs_counter_pre.unit_price.value);
        document.add_subs_counter_pre.loading_price.value = filterNum(document.add_subs_counter_pre.loading_price.value);
        document.add_subs_counter_pre.total_price.value = filterNum(document.add_subs_counter_pre.total_price.value);
    }

    function getCounterType(){
        Array.prototype.map.call($("select#counter_id option"), function(obj) {
            if(obj.value != "" || obj.value != 0) obj.remove();
        });
        var ajaxConn = GetAjaxConnector();
        var subscription_id = document.getElementById("subscription_id").value;
        var url = "<cfoutput>#request.self#</cfoutput>?fuseaction=sales.emptypopup_list_subscription_counter&type=1&isajax=1&subscription_id=" + subscription_id;
		AjaxRequest(ajaxConn, url, 'GET', '', function(){
            if (ajaxConn.readyState == 4 && ajaxConn.status == 200){
                var response = JSON.parse(ajaxConn.responseText);
                response.forEach(item => {
                    $("<option>").attr({"value":""+item.COUNTER_ID+""}).text(item.COUNTER_TYPE + " - " + item.COUNTER_NO).appendTo("select#counter_id");
                });
            }
        });
    }

    function getCounterProduct( counter_id ){
        if( counter_id != '' ){
            var ajaxConn = GetAjaxConnector();
            var url = "<cfoutput>#request.self#</cfoutput>?fuseaction=sales.emptypopup_list_subscription_counter&type=2&isajax=1&counter_id=" + counter_id;
            AjaxRequest(ajaxConn, url, 'GET', '', function(){
                if (ajaxConn.readyState == 4 && ajaxConn.status == 200){
                    var response = JSON.parse(ajaxConn.responseText);
                    document.add_subs_counter_pre.product.value = response[0].PRODUCT_NAME;
                    document.add_subs_counter_pre.stock_id.value = response[0].STOCK_ID;
                    document.add_subs_counter_pre.product_id.value = response[0].PRODUCT_ID;
                    document.add_subs_counter_pre.amount.value = response[0].AMOUNT;
                    document.add_subs_counter_pre.unit_id.value = response[0].UNIT_ID;
                    document.add_subs_counter_pre.unit_name.value = response[0].UNIT;
                    document.add_subs_counter_pre.unit_price.value = response[0].PRICE;
                    document.add_subs_counter_pre.UNIT_CURRENCY_ID.value = response[0].MONEY_ID + ';' + response[0].OTHER_MONEY;
                }
            });
        }
    }

    function toplam_kontrol(){
        var amount = $("input[name=amount]");
        var loadingPrice = $("input[name=loading_price]");
        var unitPrice = $("input[name=unit_price]");
        var totalPrice = $("input[name=total_price]");
        
        var loadingPriceVal = filterNum((loadingPrice.val() == '' ? 0 : loadingPrice.val()));
        var unitPriceVal = filterNum((unitPrice.val() == '' ? 0 : unitPrice.val()));
        var totalPriceVal = filterNum((totalPrice.val() == '' ? 0 : totalPrice.val()));

        totalPriceVal = loadingPriceVal * unitPriceVal;
        totalPrice.val(commaSplit(totalPriceVal));
    }

    $("input[name=loading_price]").on("blur",function(){
        toplam_kontrol();
    });
</script>