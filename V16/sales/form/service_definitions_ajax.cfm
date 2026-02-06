<cf_ajax_list>
    <div class="row">
        <div class="col col-12 uniqueRow">
            <div class="row">
                <div class="row" type="row">
                    <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
                        <div class="form-group" id="item-form_ul_valid_days">
                            <label class="col col-4 col-xs-12"><cf_get_lang no='608.Geçerli Günler'></label>
                            <div class="col col-8 col-xs-12">
                                <select name="valid_days" id="valid_days">
                                    <option value="0"><cf_get_lang_main no='322.Seçiniz'></option>
                                    <option value="1"><cf_get_lang no='26.Hafta İçi'></option>
                                    <option value="2"><cf_get_lang no='27.Hafta içi + Cmt'></option>
                                    <option value="3"><cf_get_lang no='30.7 Gün'></option>
                                </select>
                            </div>
                        </div>
                        <div class="form-group" id="item-form_ul_start_clock_1">
                            <label class="col col-4 col-xs-4"><cf_get_lang no='609.Hafta İçi Destek Saatleri'> <cf_get_lang_main no='89.Baslangic'></label>
                            <cfoutput>
                                <div class="col col-4 col-xs-4">
                                   <cf_wrkTimeFormat name="start_clock_1" value="0">
                                </div>
                                <div class="col col-4 col-xs-4">
                                    <select name="start_minute_1" id="start_minute_1">
                                        <option value="0" selected><cf_get_lang_main no='1415.dk'></option>
                                        <cfloop from="0" to="55" index="a" step="5">
                                            <option value="#Numberformat(a,00)#">#Numberformat(a,00)#</option>
                                        </cfloop>
                                    </select>
                                </div>
                            </cfoutput>
                        </div>
                        <div class="form-group" id="item-form_ul_start_clock_1_2">
                            <label class="col col-4 col-xs-4"><cf_get_lang no='609.Hafta İçi Destek Saatleri'> <cf_get_lang_main no='90.Bitiş'></label>
                            <cfoutput>
                                <div class="col col-4 col-xs-4">
                                   <cf_wrkTimeFormat name="finish_clock_1" value="0">
                                </div>
                                <div class="col col-4 col-xs-4">
                                    <select name="finish_minute_1" id="finish_minute_1">
                                        <option value="0" selected><cf_get_lang_main no='1415.dk'></option>
                                        <cfloop from="0" to="55" index="a" step="5">
                                            <option value="#Numberformat(a,00)#">#Numberformat(a,00)#</option>
                                        </cfloop>
                                    </select>
                                </div>
                            </cfoutput>
                        </div>
                        <div class="form-group" id="item-form_ul_start_clock_2">
                            <label class="col col-4 col-xs-4"><cf_get_lang no='610.Cumartesi Destek Saatleri'> <cf_get_lang_main no='89.Baslangic'></label>
                            <cfoutput>
                                <div class="col col-4 col-xs-4">
                                   <cf_wrkTimeFormat name="start_clock_2" value="0">
                                </div>
                                <div class="col col-4 col-xs-4">
                                    <select name="start_minute_2" id="start_minute_2_2">
                                        <option value="0" selected><cf_get_lang_main no='1415.dk'></option>
                                        <cfloop from="0" to="55" index="a" step="5">
                                            <option value="#Numberformat(a,00)#">#Numberformat(a,00)#</option>
                                        </cfloop>
                                    </select>
                                </div>
                            </cfoutput>
                        </div>
                        <div class="form-group" id="item-form_ul_start_clock_2_2">
                            <label class="col col-4 col-xs-4"><cf_get_lang no='610.Cumartesi Destek Saatleri'> <cf_get_lang_main no='90.Bitiş'></label>
                            <cfoutput>
                                <div class="col col-4 col-xs-4">
                                   <cf_wrkTimeFormat name="finish_clock_2" value="0">
                                </div>
                                <div class="col col-4 col-xs-4">
                                    <select name="finish_minute_2" id="finish_minute_2">
                                        <option value="0" selected><cf_get_lang_main no='1415.dk'></option>
                                        <cfloop from="0" to="55" index="a" step="5">
                                            <option value="#Numberformat(a,00)#">#Numberformat(a,00)#</option>
                                        </cfloop>
                                    </select>
                                </div>
                            </cfoutput>
                        </div>
                        <div class="form-group" id="item-form_ul_start_clock_3">
                            <label class="col col-4 col-xs-4"><cf_get_lang no='50.Pazar Destek Saatleri'> <cf_get_lang_main no='89.Baslangic'></label>
                                <cfoutput>
                                    <div class="col col-4 col-xs-4">
                                        <cf_wrkTimeFormat name="start_clock_3" value="0">
                                    </div>
                                    <div class="col col-4 col-xs-4">
                                        <select name="start_minute_3" id="start_minute_3">
                                            <option value="0" selected><cf_get_lang_main no='1415.dk'></option>
                                            <cfloop from="0" to="55" index="a" step="5">
                                                <option value="#Numberformat(a,00)#">#Numberformat(a,00)#</option>
                                            </cfloop>
                                        </select>
                                    </div>
                                </cfoutput>
                        </div>
                        <div class="form-group" id="item-form_ul_start_clock_3_2">
                            <label class="col col-4 col-xs-4"><cf_get_lang no='50.Pazar Destek Saatleri'> <cf_get_lang_main no='90.Bitiş'></label>
                                <cfoutput>
                                    <div class="col col-4 col-xs-4">
                                        <cf_wrkTimeFormat name="finish_clock_3" value="0">
                                    </div>
                                    <div class="col col-4 col-xs-4">
                                        <select name="finish_minute_3" id="finish_minute_3">
                                            <option value="0" selected><cf_get_lang_main no='1415.dk'></option>
                                            <cfloop from="0" to="55" index="a" step="5">
                                                <option value="#Numberformat(a,00)#">#Numberformat(a,00)#</option>
                                            </cfloop>
                                        </select>
                                    </div>
                                </cfoutput>
                        </div>
                        <div class="form-group" id="item-form_ul_general_date">
                            <div class="col col-4"></div>
                            <label class="col col-8 col-xs-8"><input type="checkbox" name="general_date" id="general_date" value="1" checked><cf_get_lang no='51.Genel Tatil Zamanlarında Geçerli'></label>
                        </div>
                        <div class="form-group" id="item-form_response_hour">
                            <label class="col col-4 col-xs-4"><cf_get_lang no='73.Müdahale süresi'></label>
                            <cfoutput>
                                <div class="col col-4 col-xs-4">
                                <cf_wrkTimeFormat name="response_hour1" value="0">                                  
                                </div>
                                <div class="col col-4 col-xs-4">
                                <select name="response_minute1" id="response_minute1">
                                    <option value="0" selected><cf_get_lang_main no='1415.dk'></option>
                                    <cfloop from="0" to="55" index="a" step="5">
                                        <option value="#Numberformat(a,00)#">#Numberformat(a,00)#</option>
                                    </cfloop>
                                </select>
                                </div>
                            </cfoutput>
                        </div>
                        <div class="form-group" id="item-form_ul_hour1">
                            <label class="col col-4 col-xs-4"><cf_get_lang no='52.Çözüm süresi'></label>
                            <cfoutput>
                                <div class="col col-4 col-xs-4">
                                   <cf_wrkTimeFormat name="hour1" value="0">
                                </div>
                                <div class="col col-4 col-xs-4">
                                    <select name="minute1" id="minute1">
                                        <option value="0" selected><cf_get_lang_main no='1415.dk'></option>
                                        <cfloop from="0" to="55" index="a" step="5">
                                            <option value="#Numberformat(a,00)#">#Numberformat(a,00)#</option>
                                        </cfloop>
                                    </select>
                                </div>
                            </cfoutput>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</cf_ajax_list>
