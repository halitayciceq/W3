<cfparam name="attributes.action_date" default="#now()#">
<cfinclude template="../../sales/query/get_money.cfm">
<cf_catalystHeader>

<cfif IsDefined("attributes.scp_id")>
    <cfset subsCounterPre = createObject("component","V16.sales.cfc.subscription_counter_prepaid")>
    <cfset subsCounterPrepaids = subsCounterPre.select(
        scp_id  :   attributes.scp_id
    )>
</cfif>

<cfif subsCounterPrepaids.SCP_ID eq "">
    <cfset hata  = 10>
	<cfinclude template="../../dsp_hata.cfm">
    <cfabort>
</cfif>

<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box>
        <cfform name="add_subs_counter_pre" method="post" action="">
            <cfinput type="hidden" name="scp_id" value="#attributes.scp_id#">
            <cf_box_elements>
                <div class="col col-4 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
                    <div class="form-group" id="item-process_stage">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58859.Süreç'>*</label>
                        <div class="col col-8 col-xs-12">
                            <cf_workcube_process is_upd='0' process_cat_width='150' is_detail='1' select_value="#subsCounterPrepaids.PROCESS_ROW_ID#">
                        </div>
                    </div>
                    <div class="form-group" id="item-subscription_no">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='29502.Abone No'>*</label>
                        <div class="col col-8 col-xs-12">
                            <div class="input-group">
                                <cfinput type="hidden" name="subscription_id" id="subscription_id" value="#subsCounterPrepaids.SUBSCRIPTION_ID#">
                                <cfinput type="text" name="subscription_no" id="subscription_no" value="#subsCounterPrepaids.SUBSCRIPTION_NO#" readonly>
                                <span class="input-group-addon btn_Pointer icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_subscription&field_id=add_subs_counter_pre.subscription_id&field_no=add_subs_counter_pre.subscription_no&call_function=getCounterType');"></span>
                            </div>
                        </div>
                    </div>
                    <div class="form-group" id="item-counter_type">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='41282.Sayaç Tipi'> -<cf_get_lang dictionary_id='57487.No'>*</label>
                        <div class="col col-8 col-xs-12">
                            <select id="counter_id" name="counter_id" onchange="getCounterProduct(this.value)">
                                <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                            </select>
                        </div>
                    </div>
                    <div class="form-group" id="item-product">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id ='57657.Ürün'>*</label>
                        <div class="col col-8 col-xs-12">
                            <div class="input-group">
                                <cfinput type="hidden" name="stock_id" id="stock_id" value="#subsCounterPrepaids.STOCK_ID#">
                                <cfinput type="hidden" name="product_id" id="product_id" value="#subsCounterPrepaids.PRODUCT_ID#">
                                <cfinput type="text" name="product" id="product" value="#subsCounterPrepaids.PRODUCT_NAME#" readonly="readonly">
                                <span class="input-group-addon btn_Pointer icon-ellipsis" href="javascript://" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_product_price_unit&field_stock_id=add_subs_counter_pre.stock_id&field_id=add_subs_counter_pre.product_id&field_name=add_subs_counter_pre.product&field_unit_id=add_subs_counter_pre.unit_id&field_unit=add_subs_counter_pre.unit_name&field_price=add_subs_counter_pre.unit_price&field_amount=add_subs_counter_pre.amount&field_select_money_type=add_subs_counter_pre.UNIT_CURRENCY_ID&fnk=1');"></span>
                            </div>
                        </div>
                    </div>
                    <div class="form-group" id="item-unit_name">
                        <label class="col col-4 col-md-2 col-xs-12"><cf_get_lang dictionary_id='48888.Paket Miktar'></label>
                        <div class="col col-4 col-xs-6">
                            <input type="text" name="amount" id="amount" class="moneybox" required readonly value="<cfoutput>#TLFormat(subsCounterPrepaids.AMOUNT)#</cfoutput>">
                        </div>
                        <div class="col col-4 col-xs-6">
                            <cfinput type="hidden" name="unit_id" id="unit_id" value="#subsCounterPrepaids.UNIT_ID#">
                            <cfinput type="text" name="unit_name" id="unit_name" value="#subsCounterPrepaids.MAIN_UNIT#" readonly="readonly">
                        </div>
                    </div>
                    <div class="form-group" id="item-unit_price">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57638.Birim Fiyat'>*</label>
                        <div class="col col-6 col-xs-12">
                            <cfinput type="text" name="unit_price" id="unit_price" class="moneybox" required="yes" message="#getLang('','Geçerli Tutar Girmelisiniz',29535)#" readonly value="#TLFORMAT(subsCounterPrepaids.PRICE)#">
                        </div>
                        <div class="col col-2 col-xs-12">
                            <select name="UNIT_CURRENCY_ID" id="UNIT_CURRENCY_ID"  <!--- onChange="kur_ekle_f_hesapla('UNIT_CURRENCY_ID',false,1);" --->>
                                <cfoutput query="GET_MONEY">
                                <option value="#money_id#;#money#" <cfif "#money_id#;#money#" eq subsCounterPrepaids.OTHER_MONEY>selected</cfif>>#money#</option>
                                </cfoutput>
                            </select> 
                        </div>
                    </div>
                </div>
                <div class="col col-4 col-md-4 col-sm-6 col-xs-12" type="column" index="2" sort="true">
                    <div class="form-group" id="item-loading_price">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='48879.Yükleme Miktarı'>*</label>
                        <div class="col col-8 col-xs-12">
                            <cfinput type="text" name="loading_price" id="loading_price" class="moneybox" value="#TLFORMAT(subsCounterPrepaids.COUNTER_LOADING_PRICE)#" required="yes" message="#getLang('','Geçerli Tutar Girmelisiniz',29535)#" onkeyup="return(FormatCurrency(this,event));">
                        </div>
                    </div>
                    <div class="form-group" id="item-total_price">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='29534.Toplam Tutar'>*</label>
                        <div class="col col-8 col-xs-12">
                            <cfinput type="text" name="total_price" id="total_price" class="moneybox" value="#TLFORMAT(subsCounterPrepaids.COUNTER_TOTAL_PRICE)#" required="yes" message="#getLang('','Geçerli Tutar Girmelisiniz',29535)#" readonly>
                        </div>
                    </div>
                    <div class="form-group" id="item-loading_price">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='48882.Yükleme Tarihi'>*</label>
                        <div class="col col-8 col-xs-12">
                            <div class="input-group">
                                <cfinput type="text" name="action_date" id="action_date" maxlength="10" value="#dateformat(subsCounterPrepaids.COUNTER_LOADING_DATE,dateformat_style)#" validate="#validate_style#" required="yes" message="#getLang('','İşlem Tarihi Girmelisiniz',57906)#">
                                <span class="input-group-addon"><cf_wrk_date_image date_field="action_date"></span>
                            </div>
                        </div>
                    </div>
                    <div class="form-group" id="item-emp_id">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='48887.Yükleyen'>*</label>
                        <div class="col col-8 col-xs-12">
                            <div class="input-group">
                                <cfinput type="hidden" name="emp_id" id="emp_id" value="#subsCounterPrepaids.LOADING_EMPLOYEE_ID#">
                                <cfinput type="text" name="emp_name" id="emp_name" value="#subsCounterPrepaids.EMPLOYEE_NAME# #subsCounterPrepaids.EMPLOYEE_SURNAME#" onfocus="AutoComplete_Create('emp_name','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','3','EMPLOYEE_ID','emp_id','','3','200');" autocomplete="off">
                                <span class="input-group-addon btn_Pointer icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_positions&field_emp_id=add_subs_counter_pre.emp_id&field_name=add_subs_counter_pre.emp_name');"></span>
                            </div>
                        </div>
                    </div>
                    <!--- <div class="form-group" id="item-islem_tur">
                        <label class="col col-4 bold"><cf_get_lang dictionary_id='50973.İşlem Para Birimi'></label>
                        <div class="col col-8">
                            <cfscript>f_kur_ekle(is_disable:1,process_type:0,base_value:'priceBeforeTotal',other_money_value:'total_price',form_name:'add_subs_counter_pre',select_input:'UNIT_CURRENCY_ID');</cfscript>
                        </div>
                    </div> --->
                </div>
            </cf_box_elements>
            <cf_box_footer>
                <div class="col col-6">
                    <cf_record_info query_name="subsCounterPrepaids">
                </div>
                <div class="col col-6">
                    <cf_workcube_buttons is_upd="1" add_function='kontrol()'>
                </div>
            </cf_box_footer>
        </cfform>
    </cf_box>
</div>


<script>
    getCounterType(<cfoutput>#subsCounterPrepaids.COUNTER_ID#</cfoutput>);

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
            alertObject({message: "<cf_get_lang dictionary_id='62242.Yükleyen alanı boş geçilemez!'>!"});
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

    function getCounterType(counter_id = 0){
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
                    var option = $("<option>");
                    if(counter_id == item.COUNTER_ID) option.attr({"selected":"selected"});
                    option.attr({"value":""+item.COUNTER_ID+""}).text(item.COUNTER_TYPE + " - " + item.COUNTER_NO).appendTo("select#counter_id");
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