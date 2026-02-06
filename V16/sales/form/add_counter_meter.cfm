<cf_catalystHeader>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box>
        <cfform name="form_add_counter_meter" method="post" action="">
            <cf_box_elements>
                <div class="col col-4 col-md-6 col-xs-12" type="column" index="1" sort="true">
                    <div class="form-group" id="item-subscription_no">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58832.Abone'> *</label>
                        <div class="col col-8 col-xs-12">  
                            <cf_wrk_subscriptions width_info='140' fieldid='subscription_id' fieldname='subscription_no' form_name='form_add_counter_meter' img_info='plus_thin' call_function='getCounterType' isGetCounter='1'>
                        </div>
                    </div>
                    <div class="form-group" id="item-counter_type">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='41282.Sayaç Tipi'> - <cf_get_lang dictionary_id='57487.No'>*</label>
                        <div class="col col-8 col-xs-12">
                            <select id="counter_id" name="counter_id" onchange="getLastValue()">
                                <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                            </select>
                        </div>
                    </div>
                    <div class="form-group" id="item-emp_id">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57899.Kaydeden'>*</label>
                        <div class="col col-8 col-xs-12">
                            <div class="input-group">
                                <cfinput type="hidden" name="emp_id" id="emp_id" value="#session.ep.userid#">
                                <cfinput type="text" name="emp_name" id="emp_name" value="#session.ep.name# #session.ep.surname#" onfocus="AutoComplete_Create('emp_name','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','3','EMPLOYEE_ID','emp_id','','3','200');" autocomplete="off">
                                <span class="input-group-addon btn_Pointer icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_positions&field_emp_id=form_add_counter_meter.emp_id&field_name=form_add_counter_meter.emp_name');"></span>
                            </div>
                        </div>
                    </div>
                    <div class="form-group" id="item-action_date">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57627.Kayıt Tarihi'>*</label>
                        <div class="col col-8 col-xs-12">
                            <div class="input-group">
                                <cfinput type="text" name="action_date" id="action_date" maxlength="10" value="#dateformat(now(),dateformat_style)#" validate="#validate_style#" required="yes" message="#getLang('','İşlem tarihi girmelisiniz',57906)#" onchange="getLastValue()">
                                <span class="input-group-addon"><cf_wrk_date_image date_field="action_date"></span>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col col-4 col-md-6 col-xs-12" type="column" index="2" sort="true">
                    <div class="form-group" id="item-previous_value">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='56973.Önceki Değer'> *</label>
                        <div class="col col-8 col-xs-12">
                            <input type="text" name="previous_value" id="previous_value" value="" class="moneybox" onkeyup="return(FormatCurrency(this,event));">
                        </div>                         
                    </div>
                    <div class="form-group" id="item-last_value">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='41295.Son Değer'> *</label>
                        <div class="col col-8 col-xs-12">
                            <input type="text" name="last_value" id="last_value" value="" class="moneybox" onkeyup="return(FormatCurrency(this,event));">
                        </div>                         
                    </div>
                    <div class="form-group" id="item-difference">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='66077.Tüketim'> *</label>
                        <div class="col col-8 col-xs-12">
                            <input type="text" name="difference" id="difference" value="" class="moneybox" readonly onkeyup="return(FormatCurrency(this,event));">
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

        function kontrol() {
            if(subscription_id.value == '' || subscription_no.value == ''){
                alertObject({message: "<cf_get_lang dictionary_id='50995.Abone Seçiniz'>!"});
                return false;
            }
            if(counter_id.value == ''){
                alertObject({message: "<cf_get_lang dictionary_id='48946.Sayaç Tipi - Sayaç No Seçiniz'>!"});
                return false;
            }
            if(previous_value.value == ''){
                alertObject({message: "<cf_get_lang dictionary_id='62240.Önceki Değer alanı boş gecilemez'>!"});
                return false;
            }
            if(last_value.value == ''){
                alertObject({message: "<cf_get_lang dictionary_id='62241.Son Değer alanı boş gecilemez!'>"});
                return false;
            }
            if(emp_id.value == '' || emp_name.value == ''){
                alertObject({message: "<cf_get_lang dictionary_id='62242.Yükleyen alanı boş geçilemez!'>"});
                return false;
            }
            unformat_fields();
            return true;
        }

        function unformat_fields()
        {
            document.form_add_counter_meter.previous_value.value = filterNum(document.form_add_counter_meter.previous_value.value,4);
            document.form_add_counter_meter.last_value.value = filterNum(document.form_add_counter_meter.last_value.value);
            document.form_add_counter_meter.difference.value = filterNum(document.form_add_counter_meter.difference.value);
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
                        $("<option>").attr({"value":""+item.COUNTER_ID+""}).text(item.COUNTER_TYPE + " - " + item.COUNTER_NO + " / " + item.FULLNAME).appendTo("select#counter_id");
                    });
                }
            });
        }

        function getLastValue() {
            var data = new FormData();
            var first_date = "";
            var last_date = "";

            data.append("subscription_id", document.getElementById("subscription_id").value);
            data.append("counter_id", document.getElementById("counter_id").value);
            AjaxControlPostDataJson('V16/sales/cfc/counter_meter.cfc?method=get_difference', data, function ( response ) {
                if( response.DATA.length > 0 ){
                    document.getElementById("previous_value").value =  response.DATA[0][0];
                    first_date = response.DATA[0][1];
                    eventval();
                }
                else
                    document.getElementById("previous_value").value =  0;
            });
            

            var data2 = new FormData();
            data2.append("subscription_id", document.getElementById("subscription_id").value);
            data2.append("subscription_no", document.getElementById("subscription_no").value);
            data2.append("counter_id", document.getElementById("counter_id").value);
            data2.append("first_date", last_date);
            data2.append("last_date", document.getElementById("action_date").value);
            AjaxControlPostDataJson('V16/sales/cfc/counter_meter.cfc?method=get_detail_meter', data2, function ( response ) {
                if( response.length > 0 ){
                    document.getElementById("last_value").value = response[0]["ROW_COUNT"];
                    eventval();
                }
            });


        }

        function eventval(){
            if(document.form_add_counter_meter.previous_value.value != '' || document.form_add_counter_meter.lastVal.value != ''){
                var preVal = filterNum((previous_value.value == '' ? 0 : previous_value.value));
                var lastVal = filterNum((last_value.value == '' ? 0 : last_value.value));

                difVal = lastVal - preVal;
                difference.value = (commaSplit(difVal));
            }
        }

        $("#last_value , #previous_value").on("change paste keyup",function(){
            if(document.form_add_counter_meter.previous_value.value != '' || document.form_add_counter_meter.lastVal.value != ''){
                var preVal = filterNum((previous_value.value == '' ? 0 : previous_value.value));
                var lastVal = filterNum((last_value.value == '' ? 0 : last_value.value));

                difVal = lastVal - preVal;
                difference.value = (commaSplit(difVal));
            }
        });
    </script>