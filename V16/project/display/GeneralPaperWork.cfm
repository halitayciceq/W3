<!--- 
aut : Melek KOCABEY
name : GeneralPaperWork.cfm
desc : general Papers in Works
date : 22/05/2021
--->
<cfsavecontent variable="title2"><cf_get_lang dictionary_id="58057.Toplu"><cf_get_lang dictionary_id="36841.İş akışı"></cfsavecontent>
<cf_box title="#title2#" closable="0" collapsable="0">
    <cf_box_elements vertical="1">
        <div class="col col-4 col-md-4 col-sm-4 col-xs-12" type="column" index="5" sort="true"> 
            <div class="form-group" id="item-estimated_time">
                <label  class="col col-3 col-xs-3"> <cf_get_lang dictionary_id='38215.Öngörülen Süre'></label>
                <div class="col col-4 col-md-4 col-sm-4 col-xs-4"> 
                    <div class="input-group">
                        <cfinput type="text" name="estimated_time" id="estimated_time" validate="integer" class="text-right" value="0" onKeyUp="isNumber(this);" readonly>
                        <span class="input-group-addon width"><cf_get_lang dictionary_id ='57491.Saat'></span>
                    </div>
                </div>
                <div class="col col-4 col-md-4 col-sm-4 col-xs-4"> 
                    <div class="input-group">
                        <cfinput type="text" name="estimated_time_minute" id="estimated_time_minute" value="0" class="text-right" onKeyUp="isNumber(this);" readonly>
                        <span class="input-group-addon width"><cf_get_lang dictionary_id='58827.Dk'></span>
                    </div>
                </div>
            </div>
            <div class="form-group" id="item-total_time_minute">
                <label class="col col-3 col-xs-3"><cf_get_lang dictionary_id='38148.Harcanan Zaman'></label>
                <div class="col col-4 col-md-4 col-sm-4 col-xs-4"> 
                    <div class="input-group">
                        <input type="text" name="total_time_hour" id="total_time_hour" value="0" class="text-right" onkeyup="isNumber(this);" readonly>
                        <span class="input-group-addon width"><cf_get_lang dictionary_id='57491.Saat'></span>
                    </div>
                </div>
                <div class="col col-4 col-md-4 col-sm-4 col-xs-4"> 
                    <div class="input-group">
                        <cfinput type="text" name="total_time_minute" id="total_time_minute" value="0" class="text-right" onKeyUp="isNumber(this);" readonly>
                        <span class="input-group-addon width"><cf_get_lang dictionary_id='58827.Dk'></span>
                    </div>
                </div>
            </div>
            <div class="form-group" id="item-total_estimated_time">
                <label  class="col col-3 col-xs-3"><cf_get_lang dictionary_id="57492.Toplam"><cf_get_lang dictionary_id='38215.Öngörülen Süre'></label>
                <div class="col col-4 col-md-4 col-sm-4 col-xs-4"> 
                    <div class="input-group">
                        <cfinput type="text" name="total_estimated_time" id="total_estimated_time" validate="integer" value="0" class="text-right" onKeyUp="isNumber(this);" readonly>
                        <span class="input-group-addon width"><cf_get_lang dictionary_id ='57491.Saat'></span>
                    </div>
                </div>
                <div class="col col-4 col-md-4 col-sm-4 col-xs-4"> 
                    <div class="input-group">
                        <cfinput type="text" name="total_estimated_time_minute" id="total_estimated_time_minute" value="0" class="text-right" onKeyUp="isNumber(this);" readonly>
                        <span class="input-group-addon width"><cf_get_lang dictionary_id='58827.Dk'></span>
                    </div>
                </div>
            </div>
        </div>
        <div class="col col-4 col-md-4 col-sm-4 col-xs-12" type="column" index="6" sort="true">
            <div class="form-group" id="item-process">
                <cfset get_process_f = cmp_process.GET_PROCESS_TYPES(
                    faction_list : 'project.works')>
                <cfif isDefined("attributes.gp_id")>
                    <cf_workcube_general_process general_paper_id = "#attributes.gp_id#" print_type="311">
                <cfelse>
                    <cf_workcube_general_process select_value = '#get_process_f.process_row_id#' print_type="311">
                </cfif>
            </div>
        </div>
    </cf_box_elements>
    <cf_box_footer>
        <div class="col col-12 col-xs-12 text-right">
            <cf_workcube_buttons is_upd='0' add_function='setGeneralPaperWork()' submit_info="list">
        </div>
    </cf_box_footer>
</cf_box>