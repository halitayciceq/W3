<cfinclude template="../query/get_upd_subscription_contact.cfm">
<cf_box_elements>
    <div class="col col-6 col-md-6 col-sm-6 col-xs-12" type="column" index="1" sort="true">
        <div class="form-group" id="item-form_ul_valid_days">
            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='41410.Geçerli Günler'></label>
            <div class="col col-8 col-xs-12">
                <select name="valid_days" id="valid_days">
                    <option value="0" <cfif get_subscription.valid_days eq 0>selected</cfif>><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                    <option value="1" <cfif get_subscription.valid_days eq 1>selected</cfif>><cf_get_lang dictionary_id='40828.Hafta İçi'></option>
                    <option value="2" <cfif get_subscription.valid_days eq 2>selected</cfif>><cf_get_lang dictionary_id='40829.Hafta içi + Cmt'></option>
                    <option value="3" <cfif get_subscription.valid_days eq 3>selected</cfif>><cf_get_lang dictionary_id='40832.7 Gün'></option>
                </select>
            </div>
        </div>
        <div class="form-group" id="item-form_ul_start_clock_1">
            <label class="col col-4 col-xs-4"><cf_get_lang dictionary_id='41411.Hafta İçi Destek Saatleri'> <cf_get_lang dictionary_id='57501.Baslangic'></label>
            <cfoutput>
                <div class="col col-4 col-xs-4">
                    <cf_wrkTimeFormat name="start_clock_1" value="#get_subscription.start_clock_1#" >
                </div>
                <div class="col col-4 col-xs-4">
                    <select name="start_minute_1" id="start_minute_1">
                        <option value="0" selected><cf_get_lang dictionary_id='58827.dk'></option>
                        <cfloop from="0" to="55" index="a" step="5">
                            <option value="#Numberformat(a,00)#" <cfif get_subscription.start_minute_1 eq a>selected</cfif>>#Numberformat(a,00)#</option>
                        </cfloop>
                    </select>
                </div>
            </cfoutput>
        </div>
        <div class="form-group" id="item-form_ul_start_clock_1_2">
            <label class="col col-4 col-xs-4"><cf_get_lang dictionary_id='41411.Hafta İçi Destek Saatleri'> <cf_get_lang dictionary_id='57502.Bitiş'></label>
            <cfoutput>
                <div class="col col-4 col-xs-4"> 
                    <cf_wrkTimeFormat name="finish_clock_1" value="#get_subscription.finish_clock_1#" >
                </div>
                <div class="col col-4 col-xs-4">
                    <select name="finish_minute_1" id="finish_minute_1">
                        <option value="0" selected><cf_get_lang dictionary_id='58827.dk'></option>
                        <cfloop from="0" to="55" index="a" step="5">
                            <option value="#Numberformat(a,00)#" <cfif get_subscription.finish_minute_1 eq a>selected</cfif>>#Numberformat(a,00)#</option>
                        </cfloop>
                    </select>
                </div>
            </cfoutput>
        </div>
        <div class="form-group" id="item-form_ul_start_clock_2">
            <label class="col col-4 col-xs-4"><cf_get_lang dictionary_id='41412.Cumartesi Destek Saatleri'> <cf_get_lang dictionary_id='57501.Baslangic'></label>
            <cfoutput>
                <div class="col col-4 col-xs-4">
                    <cf_wrkTimeFormat name="start_clock_2" value="#get_subscription.start_clock_2#" >
                </div>
                <div class="col col-4 col-xs-4">
                    <select name="start_minute_2" id="start_minute_2">
                        <option value="0" selected><cf_get_lang dictionary_id='58827.dk'></option>
                        <cfloop from="0" to="55" index="a" step="5">
                            <option value="#Numberformat(a,00)#" <cfif get_subscription.start_minute_2 eq a>selected</cfif>>#Numberformat(a,00)#</option>
                        </cfloop>
                    </select>
                </div>
            </cfoutput>
        </div>
        <div class="form-group" id="item-form_ul_start_clock_2_2">
            <label class="col col-4 col-xs-4"><cf_get_lang dictionary_id='41412.Cumartesi Destek Saatleri'> <cf_get_lang dictionary_id='57502.Bitiş'></label>
            <cfoutput>
                <div class="col col-4 col-xs-4">
                        <cf_wrkTimeFormat name="finish_clock_2" value="#get_subscription.finish_clock_2#">
                </div>
                <div class="col col-4 col-xs-4">
                    <select name="finish_minute_2" id="finish_minute_2">
                        <option value="0" selected><cf_get_lang dictionary_id='58827.dk'></option>
                        <cfloop from="0" to="55" index="a" step="5">
                            <option value="#Numberformat(a,00)#"<cfif get_subscription.finish_minute_2 eq a>selected</cfif>>#Numberformat(a,00)#</option>
                        </cfloop>
                    </select>
                </div>
            </cfoutput>
        </div>
    </div>
    <div class="col col-6 col-md-6 col-sm-6 col-xs-12" type="column" index="2" sort="true">
        <div class="form-group" id="item-form_ul_start_clock_3">
            <label class="col col-4 col-xs-4"><cf_get_lang dictionary_id='40852.Pazar Destek Saatleri'> <cf_get_lang dictionary_id='57501.Baslangic'></label>
            <cfoutput>
                <div class="col col-4 col-xs-4">
                    <cf_wrkTimeFormat name="start_clock_3" value="#get_subscription.start_clock_3#">
                </div>
                <div class="col col-4 col-xs-4">
                    <select name="start_minute_3" id="start_minute_3">
                        <option value="0" selected><cf_get_lang dictionary_id='58827.dk'></option>
                        <cfloop from="0" to="55" index="a" step="5">
                            <option value="#Numberformat(a,00)#"<cfif get_subscription.start_minute_3 eq a>selected</cfif>>#Numberformat(a,00)#</option>
                        </cfloop>
                    </select>
                </div>
            </cfoutput>
        </div>
        <div class="form-group" id="item-form_ul_start_clock_3_2">
            <label class="col col-4 col-xs-4"><cf_get_lang dictionary_id='40852.Pazar Destek Saatleri'> <cf_get_lang dictionary_id='57502.Bitiş'></label>
            <cfoutput>
                <div class="col col-4 col-xs-4">
                    <cf_wrkTimeFormat name="finish_clock_3" value="#get_subscription.finish_clock_3#">
                </div>
                <div class="col col-4 col-xs-4">
                    <select name="finish_minute_3" id="finish_minute_3">
                        <option value="0" selected><cf_get_lang dictionary_id='58827.dk'></option>
                        <cfloop from="0" to="55" index="a" step="5">
                            <option value="#Numberformat(a,00)#"<cfif get_subscription.finish_minute_3 eq a>selected</cfif>>#Numberformat(a,00)#</option>
                        </cfloop>
                    </select>
                </div>
            </cfoutput>
        </div>
        <div class="form-group" id="item-form_ul_general_date">
            <div class="col col-4"></div>
            <label class="col col-8 col-xs-8"><input type="checkbox" id="general_date" name="general_date" value="1" <cfif len(get_subscription.is_general_date) and get_subscription.is_general_date>checked</cfif>><cf_get_lang dictionary_id='40853.Genel Tatil Zamanlarında Geçerli'></label>
        </div>
        <div class="form-group" id="item-form_response_hour">
            <label class="col col-4 col-xs-4"><cf_get_lang dictionary_id='41716.Müdahale süresi'></label>
            <cfoutput>
                <div class="col col-4 col-xs-4">
                    <cf_wrkTimeFormat name="response_hour1" value="#get_subscription.RESPONSE_HOUR1#">
                </div>
                <div class="col col-4 col-xs-4">
                    <select name="response_minute1" id="response_minute1">
                        <option value="0" selected><cf_get_lang dictionary_id='58827.dk'></option>
                        <cfloop from="0" to="55" index="a" step="5">
                            <option value="#Numberformat(a,00)#"<cfif get_subscription.RESPONSE_MINUTE1 eq a>selected</cfif>>#Numberformat(a,00)#</option>
                        </cfloop>
                    </select>
                </div>
            </cfoutput>
        </div>
        <div class="form-group" id="item-form_ul_hour1">
            <label class="col col-4 col-xs-4"><cf_get_lang dictionary_id='41721.Çözüm süresi'></label>
            <cfoutput>
                <div class="col col-4 col-xs-4">
                    <cf_wrkTimeFormat name="hour1" value="#get_subscription.hour1#">
                </div>
                <div class="col col-4 col-xs-4">
                    <select name="minute1" id="minute1">
                        <option value="0" selected><cf_get_lang dictionary_id='58827.dk'></option>
                        <cfloop from="0" to="55" index="a" step="5">
                            <option value="#Numberformat(a,00)#"<cfif get_subscription.minute1 eq a>selected</cfif>>#Numberformat(a,00)#</option>
                        </cfloop>
                    </select>
                </div>
            </cfoutput>
        </div>
    </div>
</cf_box_elements>
