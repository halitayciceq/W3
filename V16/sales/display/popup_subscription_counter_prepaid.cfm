<cfparam name="attributes.modal_id" default="">
<cfparam name="attributes.action_date" default="#now()#">
<cfparam name="attributes.isSubmitted" default="">
<cfinclude template="../../sales/query/get_money.cfm">

<cfif isDefined('attributes.isSubmitted') and attributes.isSubmitted eq 1>
    <cfset subsCounterPre = createObject("component","V16.sales.cfc.subscription_counter_prepaid")>
    <cfset response = subsCounterPre.insert(
        company_id                  :   attributes.company_id,
        process_row_id              :   attributes.process_stage,
        subscription_id             :   attributes.subscription_id,
        counter_id                  :   attributes.counter_id,
        stock_id                    :   attributes.stock_id,
        product_id                  :   attributes.product_id,
        product_amount              :   attributes.amount,
        product_unit_id             :   attributes.unit_id,
        product_unit_price          :   attributes.unit_price,
        product_unit_currency_id    :   attributes.UNIT_CURRENCY_ID,
        counter_loading_price       :   attributes.loading_price,
        counter_total_price         :   attributes.total_price,
        counter_loading_date        :   attributes.action_date,
        loading_employee_id         :   attributes.emp_id
    )>
    <cfif response.status>
        <script type="text/javascript">
            <cfif isdefined("attributes.draggable")>
                closeBoxDraggable( '<cfoutput>#attributes.modal_id#</cfoutput>', 'unique_get_counter' );
            <cfelse>
                window.close();
            </cfif>
        </script>
    <cfelse>
        <script>
            alert("<cf_get_lang dictionary_id='48344.Yükleme işlemi sırasında bir hata oluştu'>");
            <cfif isdefined("attributes.draggable")>
                openBoxDraggable('<cfoutput>#request.self#?fuseaction=sales.popup_subscription_counter_prepaid&subscription_id=#attributes.subscription_id#&counter_id=#attributes.counter_id#</cfoutput>');
            <cfelse>
                location.reload();
            </cfif>
        </script>
    </cfif>
    <cfabort>
</cfif>

<cfquery name = "subscription" datasource = "#dsn3#">
    SELECT 
        SUBSCRIPTION_ID,
        SUBSCRIPTION_NO
    FROM SUBSCRIPTION_CONTRACT
    WHERE
        SUBSCRIPTION_ID = <cfqueryparam value = "#attributes.subscription_id#" CFSQLType = "cf_sql_integer">
</cfquery>

<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box title="#getLang('bank','Sayaç Yükleme İşlemleri',48878)#" scroll="1" collapsable="1" resize="1" popup_box="#iif(isdefined("attributes.draggable"),1,0)#">
        <cfform name="add_subs_counter_pre" method="post" action="#request.self#?fuseaction=#attributes.fuseaction#">
            <input type="hidden" name="isSubmitted" value="1">
            <cf_box_elements>
                <div class="col col-6 col-md-6 col-sm-6 col-xs-12" type="column" index="1" sort="true">
                    <div class="form-group" id="item-company_id">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57519.Cari Hesap'>*</label>
                        <div class="col col-8 col-xs-12">
                            <div class="input-group">
                                <input type="hidden" name="employee_id" id="employee_id">
                                <input type="hidden" name="company_id" id="company_id">
                                <input type="hidden" name="consumer_id" id="consumer_id">
                                <cfinput name="member_name" id="member_name" type="text" onFocus="AutoComplete_Create('member_name','MEMBER_NAME,MEMBER_CODE','MEMBER_NAME,MEMBER_CODE,MEMBER_PARTNER_NAME','get_member_autocomplete','\'1,2,3\',\'\',\'\',\'\',\'2\',\'\',\'\',\'1\'','COMPANY_ID,CONSUMER_ID,EMPLOYEE_ID','company_id,consumer_id,employee_id','','3','180','get_money_info(\'cari\',\'action_date\')');">
                                <span class="input-group-addon icon-ellipsis" onclick="javascript:openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_pars&is_cari_action=1&select_list=1,2,3,9&field_comp_id=add_subs_counter_pre.company_id&field_member_name=add_subs_counter_pre.member_name&field_name=add_subs_counter_pre.member_name&field_consumer=add_subs_counter_pre.consumer_id&field_emp_id=add_subs_counter_pre.employee_id')"></span>
                            </div>
                        </div>
                    </div>
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
                                <cfinput type="hidden" name="subscription_id" id="subscription_id" value="#subscription.SUBSCRIPTION_ID#">
                                <cfinput type="text" name="subscription_no" id="subscription_no" readonly value="#subscription.SUBSCRIPTION_NO#">
                                <span class="input-group-addon btn_Pointer icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_subscription&field_id=add_subs_counter_pre.subscription_id&field_no=add_subs_counter_pre.subscription_no&call_function=getCounterType');"></span>
                            </div>
                        </div>
                    </div>
                    <div class="form-group" id="item-counter_type">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='41282.Sayaç Tipi'> - <cf_get_lang dictionary_id='57487.No'>*</label>
                        <div class="col col-8 col-xs-12">
                            <select id="counter_id" name="counter_id">
                                <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                            </select>
                        </div>
                    </div>
                    <div class="form-group" id="item-product">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id ='57657.Ürün'>*</label>
                        <div class="col col-8 col-xs-12">
                            <div class="input-group">
                                <input type="hidden" name="stock_id" id="stock_id" value="">
                                <input type="hidden" name="product_id" id="product_id" value="">
                                <input type="text" name="product" id="product" value="" readonly="readonly">
                                <span class="input-group-addon btn_Pointer icon-ellipsis" href="javascript://" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_product_price_unit&field_stock_id=add_subs_counter_pre.stock_id&field_id=add_subs_counter_pre.product_id&field_name=add_subs_counter_pre.product&field_unit_id=add_subs_counter_pre.unit_id&field_unit=add_subs_counter_pre.unit_name&field_price=add_subs_counter_pre.unit_price&field_amount=add_subs_counter_pre.amount&field_select_money_type=add_subs_counter_pre.UNIT_CURRENCY_ID&fnk=1');"></span>
                            </div>
                        </div>
                    </div>
                    <div class="form-group" id="item-unit_name">
                        <label class="col col-4"><cf_get_lang dictionary_id='48888.Paket Miktar'></label>
                        <div class="col col-4">
                            <input type="text" name="amount" id="amount" class="moneybox" required readonly>
                        </div>
                        <div class="col col-4">
                            <input type="hidden" name="unit_id" id="unit_id" value="">
                            <input type="text" name="unit_name" id="unit_name" value="" readonly="readonly">
                        </div>
                    </div>
                    <div class="form-group" id="item-unit_price">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57638.Birim Fiyat'>*</label>
                        <div class="col col-6 col-xs-12">
                            <cfinput type="text" name="unit_price" id="unit_price" class="moneybox" value="" required="yes" message="#getLang('','Geçerli Tutar Girmelisiniz!',29535)#" readonly>
                        </div>
                        <div class="col col-2 col-xs-12">
                            <select name="UNIT_CURRENCY_ID" id="UNIT_CURRENCY_ID" onChange="kur_ekle_f_hesapla('UNIT_CURRENCY_ID',false,1);">
                                <cfoutput query="GET_MONEY">
                                    <option value="#money_id#;#money#">#money#</option>
                                </cfoutput>
                            </select> 
                        </div>
                    </div>
                    <div class="form-group" id="item-loading_price">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='48879.Yükleme Miktarı'>*</label>
                        <div class="col col-8 col-xs-12">
                            <cfinput type="text" name="loading_price" id="loading_price" class="moneybox" value="" required="yes" message="#getLang('','Geçerli Tutar Girmelisiniz',29535)#" onkeyup="return(FormatCurrency(this,event));">
                        </div>
                    </div>
                </div>
                <div class="col col-6 col-md-6 col-sm-6 col-xs-12" type="column" index="2" sort="true">
                    <div class="form-group" id="item-total_price">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='29534.Toplam Tutar'>*</label>
                        <div class="col col-8 col-xs-12">
                            <cfinput type="text" name="total_price" id="total_price" class="moneybox" value="" required="yes" message="#getLang('','Geçerli Tutar Girmelisiniz!',29535)#" readonly>
                        </div>
                    </div>
                    <div class="form-group" id="item-loading_price">
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
                                <cfinput type="text" name="emp_name" id="emp_name" value="#session.ep.name# #session.ep.surname#" onfocus="AutoComplete_Create('emp_name','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','3','EMPLOYEE_ID','emp_id','','3','200');" autocomplete="off">
                                <span class="input-group-addon btn_Pointer icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_positions&field_emp_id=add_subs_counter_pre.emp_id&field_name=add_subs_counter_pre.emp_name');"></span>
                            </div>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col col-4 bold"><cf_get_lang dictionary_id='50973.İşlem Para Birimi'></label>
                        <div class="col col-8">
                            <cfscript>f_kur_ekle(is_disable:1,process_type:0,base_value:'priceBeforeTotal',other_money_value:'total_price',form_name:'add_subs_counter_pre',select_input:'UNIT_CURRENCY_ID');</cfscript>
                        </div>
                    </div>
                </div>
            </cf_box_elements>
            <cf_box_footer>
                <cf_workcube_buttons add_function='kontrol()'>
            </cf_box_footer>
        </cfform>
    </cf_box>
</div>
<script>
    getCounterType(<cfoutput>#attributes.counter_id#</cfoutput>);
    function kontrol(){
        if((document.add_subs_counter_pre.employee_id.value == '' && document.add_subs_counter_pre.company_id.value == '' && document.add_subs_counter_pre.consumer_id.value == '') || document.add_subs_counter_pre.member_name.value == ''){
            alertObject({message: "<cf_get_lang dictionary_id='50081.Lütfen Cari Hesap Seçiniz'>!"});
            return false;
        }
        if(document.add_subs_counter_pre.process_stage.value == ''){
            alertObject({message: "<cf_get_lang dictionary_id='58842.Please Select Process'>"});
            return false;
        }
        if(document.add_subs_counter_pre.subscription_no.value == '' || document.add_subs_counter_pre.subscription_id.value == ''){
            alertObject({message: "<cf_get_lang dictionary_id='50995.Abone Seçiniz'>"});
            return false;
        }
        if(document.add_subs_counter_pre.counter_id.value == ''){
            alertObject({message: "<cf_get_lang dictionary_id='48946.Sayaç Tipi - Sayaç No Seçiniz'>!"});
            return false;
        }
        if((document.add_subs_counter_pre.stock_id.value == '' && document.add_subs_counter_pre.product_id.value == '') || document.add_subs_counter_pre.product.value == ''){
            alertObject({message: "<cf_get_lang dictionary_id='36774.Lütfen Ürün Seçiniz'>!"});
            return false;
        }
        if(document.add_subs_counter_pre.emp_id.value == '' || document.add_subs_counter_pre.emp_name.value == ''){
            alertObject({message: "<cf_get_lang dictionary_id='62242.Yükleyen alanı boş geçilemez!'>"});
            return false;
        }
        unformat_fields();
        <cfif isdefined("attributes.draggable")>loadPopupBox('add_subs_counter_pre' , <cfoutput>#attributes.modal_id#</cfoutput>);<cfelse>return true;</cfif>
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

    var amount = $("input[name=amount]");
    var loadingPrice = $("input[name=loading_price]");
    var unitPrice = $("input[name=unit_price]");
    var totalPrice = $("input[name=total_price]");

    function toplam_kontrol(){
        amount.val(commaSplit(amount.val()));
        loadingPrice.val(commaSplit(loadingPrice.val()));
        unitPrice.val(filterNum(unitPrice.val()));
        unitPrice.val(commaSplit(unitPrice.val()));
        totalPrice.val(commaSplit(totalPrice.val()));

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