<cfset listCM = createObject("component","V16.sales.cfc.counter_meter")>
<cfset selCM = listCM.select(
    scm_id  :   attributes.cm_id
)>
<cfif selCM.scm_id eq "">
    <cfset hata  = 10>
	<cfinclude template="../../dsp_hata.cfm">
    <cfabort>
</cfif>
<cf_catalystHeader>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box>
        <cfform name="form_upd_counter_meter" method="post" action="">
            <input type="hidden" name="cm_id" id="cm_id" value="<cfoutput>#selCM.SCM_ID#</cfoutput>">
            <input type="hidden" name="form_submitted" value="1">
            <cf_box_elements>
                <div class="col col-4 col-md-6 col-xs-12" type="column" index="1" sort="true">
                    <div class="form-group" id="item-subscription_name">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58832.Abone'> *</label>
                        <div class="col col-8 col-xs-12">  
                            <cf_wrk_subscriptions width_info='140' fieldid='subscription_id' fieldname='subscription_no' subscription_id="#selCM.SUBSCRIPTION_ID#" subscription_no="#selCM.SUBSCRIPTION_NO#" form_name='form_upd_counter_meter' img_info='plus_thin' call_function='getCounterType' isGetCounter='1'>                     
                            <!--- <div class="input-group">     
                                <input type="hidden" name="subscription_id" id="subscription_id" value="<cfoutput>#selCM.SUBSCRIPTION_ID#</cfoutput>">
                                <input type="text" name="subscription_no" id="subscription_no" value="<cfoutput>#selCM.SUBSCRIPTION_NO#</cfoutput>" readonly>
                                <span class="input-group-addon btn_Pointer icon-ellipsis" href="javascript://" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_subscription&field_id=form_upd_counter_meter.subscription_id&field_no=form_upd_counter_meter.subscription_no&call_function=getCounterType','list','popup_list_subscription');"></span>
                            </div> --->
                        </div>
                    </div>
                    <div class="form-group" id="item-counter_type">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='41282.Sayaç Tipi'> -<cf_get_lang dictionary_id='57487.No'>*</label>
                        <div class="col col-8 col-xs-12">
                            <select id="counter_id" name="counter_id">
                                <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                            </select>
                        </div>
                    </div>
                    <div class="form-group" id="item-emp_id">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57891.Güncelleyen'>*</label>
                        <div class="col col-8 col-xs-12">
                            <div class="input-group">
                                <input type="hidden" name="emp_id" id="emp_id" value="<cfoutput>#session.ep.userid#</cfoutput>">
                                <input type="text" name="emp_name" id="emp_name" value="<cfoutput>#session.ep.name# #session.ep.surname#</cfoutput>" onfocus="AutoComplete_Create('emp_name','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','3','EMPLOYEE_ID','emp_id','','3','200');" autocomplete="off">
                                <span class="input-group-addon btn_Pointer icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_positions&field_emp_id=form_upd_counter_meter.emp_id&field_name=form_upd_counter_meter.emp_name');"></span>
                            </div>
                        </div>
                    </div>
                    <div class="form-group" id="item-action_date">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='48672.Güncelleme Tarihi'>*</label>
                        <div class="col col-8 col-xs-12">
                            <div class="input-group">
                                <input type="text" name="action_date" id="action_date" maxlength="10" value="<cfoutput>#dateformat(selCM.loading_date,dateformat_style)#</cfoutput>" validate="<cfoutput>#validate_style#</cfoutput>" required="yes" message="<cfoutput>#getLang('','İşlem Tarihi Girmelisiniz',57906)#</cfoutput>">
                                <span class="input-group-addon"><cf_wrk_date_image date_field="action_date"></span>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col col-4 col-md-6 col-xs-12" type="column" index="2" sort="true">
                    <div class="form-group" id="item-previous_value">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='56973.Önceki Değer'> *</label>
                        <div class="col col-8 col-xs-12">
                            <input type="text" name="previous_value" id="previous_value" class="moneybox" value="<cfoutput>#tlFormat(selCM.PREVIOUS_VALUE)#</cfoutput>" onkeyup="return(FormatCurrency(this,event));">
                        </div>                         
                    </div>
                    <div class="form-group" id="item-last_value">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='41295.Son Değer'> *</label>
                        <div class="col col-8 col-xs-12">
                            <input type="text" name="last_value" id="last_value" class="moneybox" value="<cfoutput>#tlFormat(selCM.LAST_VALUE)#</cfoutput>" onkeyup="return(FormatCurrency(this,event));">
                        </div>                         
                    </div>
                    <div class="form-group" id="item-difference">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='66077.Tüketim'> *</label>
                        <div class="col col-8 col-xs-12">
                            <input type="text" name="difference" id="difference" class="moneybox" value="<cfoutput>#tlFormat(selCM.DIFFERENCE)#</cfoutput>" onkeyup="return(FormatCurrency(this,event));" readonly>
                        </div>                         
                    </div>
                </div>
            </cf_box_elements>
            <cf_box_footer>
                <div class="col col-6">
                    <cf_record_info query_name="selCM">
                </div>
                <div class="col col-6">
                    <cf_workcube_buttons is_upd='1' add_function='kontrol()'>
                </div>
            </cf_box_footer> 
        </cfform>
    </cf_box>
</div>
<script>
    getCounterType(<cfoutput>#selCM.COUNTER_ID#</cfoutput>);

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
            document.form_upd_counter_meter.previous_value.value = filterNum(document.form_upd_counter_meter.previous_value.value);
            document.form_upd_counter_meter.last_value.value = filterNum(document.form_upd_counter_meter.last_value.value);
            document.form_upd_counter_meter.difference.value = filterNum(document.form_upd_counter_meter.difference.value);
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
                         option.attr({"value":""+item.COUNTER_ID+""}).text(item.COUNTER_TYPE + " - " + item.COUNTER_NO + " / " + item.FULLNAME).appendTo("select#counter_id");
                    });
                }
            });
        }

        $("#last_value , #previous_value").on("change paste keyup",function(){
            if(document.form_upd_counter_meter.previous_value.value != '' || document.form_upd_counter_meter.lastVal.value != ''){
                var preVal = filterNum((previous_value.value == '' ? 0 : previous_value.value));
                var lastVal = filterNum((last_value.value == '' ? 0 : last_value.value));

                difVal = lastVal - preVal;
                difference.value = (commaSplit(difVal));
            }
        });

</script>