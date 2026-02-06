<cfparam name="attributes.modal_id" default="">
<cfparam name="attributes.action_date" default="#now()#">
<cfparam name="attributes.isSubmitted" default="">
    <cfif isDefined('attributes.isSubmitted') and attributes.isSubmitted eq 1>
        <cfset subsCounterPre = createObject("component","V16.sales.cfc.counter_meter")>
        <cfset response = subsCounterPre.insert(
            subscription_id     :   attributes.subscription_id,
            counter_id          :   attributes.counter_id,
            wex_id              :   attributes.wex_id,
            previous_value      :   attributes.previous_value,
            last_value          :   attributes.last_value,
            difference          :   attributes.difference,
            emp_id              :   attributes.emp_id,
            action_date         :   attributes.action_date
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
	<cf_box title="#getLang('sales','Sayaç okuma',41271)#" scroll="1" collapsable="1" resize="1" popup_box="#iif(isdefined("attributes.draggable"),1,0)#">
        <cfform name="form_add_counter_meter" method="post" action="#request.self#?fuseaction=#attributes.fuseaction#">
            <input type="hidden" name="isSubmitted" value="1">
            <cf_box_elements>
                <div class="col col-6 col-md-6 col-sm-6 col-xs-12" type="column" index="1" sort="true">
                    <div class="form-group" id="item-subscription_no">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58832.Abone'> *</label>
                        <div class="col col-8 col-xs-12">  
                            <div class="input-group">                        
                                <input type="hidden" name="subscription_id" id="subscription_id" value="<cfoutput>#subscription.SUBSCRIPTION_ID#</cfoutput>">
                                <input type="text" name="subscription_no" id="subscription_no" value="<cfoutput>#subscription.SUBSCRIPTION_NO#</cfoutput>" readonly>
                                <span class="input-group-addon btn_Pointer icon-ellipsis" href="javascript://" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_subscription&field_id=form_add_counter_meter.subscription_id&field_no=form_add_counter_meter.subscription_no&call_function=getCounterType');"></span>
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
                    <div class="form-group" id="item-wex">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='47849.WEX'> *</label>
                        <div class="col col-8 col-xs-12">  
                            <div class="input-group">
                                <input type="hidden" name="wex_id" id="wex_id" value="">                  
                                <input type="text" name="wex_name" id="wex_name" value="" readonly>
                                <span class="input-group-addon btn_Pointer icon-ellipsis" href="javascript://" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_wex&fieldId=form_add_counter_meter.wex_id&fieldName=form_add_counter_meter.wex_name');"></span>                                                               
                            </div>
                        </div>
                    </div>
                    <div class="form-group" id="item-previous_value">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='56973.Önceki Değer'> *</label>
                        <div class="col col-8 col-xs-12">
                            <input type="text" name="previous_value" id="previous_value" value="" class="moneybox" onkeyup="return(FormatCurrency(this,event));">
                        </div>                         
                    </div>
                </div>
                <div class="col col-6 col-md-6 col-sm-6 col-xs-12" type="column" index="2" sort="true">
                    <div class="form-group" id="item-last_value">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='41295.Son Değer'> *</label>
                        <div class="col col-8 col-xs-12">
                            <input type="text" name="last_value" id="last_value" value="" class="moneybox" onkeyup="return(FormatCurrency(this,event));">
                        </div>                         
                    </div>
                    <div class="form-group" id="item-difference">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58583.Fark'> *</label>
                        <div class="col col-8 col-xs-12">
                            <input type="text" name="difference" id="difference" value="" class="moneybox" readonly onkeyup="return(FormatCurrency(this,event));">
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
                                <cfinput type="text" name="action_date" id="action_date" maxlength="10" value="#dateformat(attributes.action_date,dateformat_style)#" validate="#validate_style#" required="yes" message="#getLang('','İşlem Tarihi Girmelisiniz',57906)#">
                                <span class="input-group-addon"><cf_wrk_date_image date_field="action_date"></span>
                            </div>
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

        function kontrol() {
            if(subscription_id.value == '' || subscription_no.value == ''){
                alertObject({message: "<cf_get_lang dictionary_id='62238.Abone alanı boş gecilemez!'>"});
                return false;
            }
            if(counter_id.value == ''){
                alertObject({message: "<cf_get_lang dictionary_id='48946.Sayaç Tipi - Sayaç No Seçiniz'>"});
                return false;
            }
            if(wex_id.value == '' || wex_name.value == ''){
                alertObject({message: "<cf_get_lang dictionary_id='62237.WEX alanı boş gecilemez!'>"});
                return false;
            }
            if(previous_value.value == ''){
                alertObject({message: "<cf_get_lang dictionary_id='62240.Önceki Değer alanı boş gecilemez'>"});
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
            <cfif isdefined("attributes.draggable")>loadPopupBox('form_add_counter_meter' , <cfoutput>#attributes.modal_id#</cfoutput>);<cfelse>return true;</cfif>
        }

        function unformat_fields()
        {
            document.form_add_counter_meter.previous_value.value = filterNum(document.form_add_counter_meter.previous_value.value,4);
            document.form_add_counter_meter.last_value.value = filterNum(document.form_add_counter_meter.last_value.value);
            document.form_add_counter_meter.difference.value = filterNum(document.form_add_counter_meter.difference.value);
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

        $("#last_value , #previous_value").on("change paste keyup",function(){
            if(document.form_add_counter_meter.previous_value.value != '' || document.form_add_counter_meter.lastVal.value != ''){
                var preVal = filterNum((previous_value.value == '' ? 0 : previous_value.value));
                var lastVal = filterNum((last_value.value == '' ? 0 : last_value.value));

                difVal = lastVal - preVal;
                difference.value = (commaSplit(difVal));
            }
        });

    </script>