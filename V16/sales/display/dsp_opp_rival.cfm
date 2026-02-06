<cfsetting showdebugoutput="no">
<div id="div_list_rival">
    <cfscript>
        CreateCompenent = CreateObject("component","V16.workdata.get_opp_supplier_rival");
        if(isdefined("attributes.opp_id"))
        {
            getRival = CreateCompenent.getOppRival(opp_id:attributes.opp_id);
        }
        else if (isdefined("attributes.offer_id"))
        {
            getRival = CreateCompenent.getOffRival(offer_id:attributes.offer_id);
        }
        get_money = CreateCompenent.getMoney();
        get_rival_preference_reasons = CreateCompenent.getRivalPreferenceReasons();
    </cfscript>
    <cfform name="add_opp_rival" id="add_opp_rival" method="post" action="#request.self#?fuseaction=sales.emptypopup_add_opp_rival_act">
        <cf_grid_list>
            <thead>
                <cfoutput>
                    <cfif isdefined("attributes.opp_id")>
                        <input type="hidden" name="opp_id" id="opp_id" value="#attributes.opp_id#">
                    <cfelse>
                        <input type="hidden" name="offer_id" id="offer_id" value="#attributes.offer_id#">
                    </cfif>
                    <input type="hidden" name="record_num_rival" id="record_num_rival" value="#getRival.recordcount#">
                </cfoutput>
                <tr>
                    <th width="20" class="text-center"><a href="javascript://" onClick="add_row_rival();"><i class="fa fa-plus" title="<cf_get_lang dictionary_id='57582.Ekle'>" alt="<cf_get_lang dictionary_id='57582.Ekle'>"></i></th>
                    <th><cf_get_lang dictionary_id='58779.Rakip'></th>
                    <th><cf_get_lang dictionary_id='41387.Rakip Tercih Nedenleri'></th>
                    <th><cf_get_lang dictionary_id='40837.Rakibe Kaptırma Nedenleri'></th>
                    <th class="text-right"><cf_get_lang dictionary_id='40815.Rakip Fiyati'></th>
                    <th width="20" nowrap="nowrap"><cf_get_lang dictionary_id='57489.Para Birimi'></th>
                </tr>
            </thead>
            <tbody id="table2">
                <cfoutput query="getRival">
                    <tr name="frm_row1#currentrow#" id="frm_row1#currentrow#">
                        <td>
                            <input type="hidden" name="row_kontrol_#currentrow#" id="row_kontrol_#currentrow#" value="1">
                            <a style="cursor:pointer" onclick="sil(#currentrow#);"><i class="fa fa-minus" title="<cf_get_lang dictionary_id='57463.Sil'>" alt="<cf_get_lang dictionary_id='57463.Sil'>"></i></a>
                        </td>
                        <td>
                            <div class="form-group">
                                <div class="input-group">
                                    <input type="hidden" name="rival_id#currentrow#" id="rival_id#currentrow#" value="#company_id#">
                                    <input type="text" name="rival_name#currentrow#" id="rival_name#currentrow#" value="#get_par_info(company_id,1,1,0)#" readonly>
                                    <span class="input-group-addon icon-ellipsis" onClick="pencere_ac_company('#currentrow#');"></span>
                                </div>
                            </div>
                        </td>
                        <td>
                            <div class="form-group">
                                <select name="rival_preference_reason#currentrow#" id="rival_preference_reason#currentrow#">
                                    <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                    <cfloop query="get_rival_preference_reasons">
                                        <option value="#preference_reason_id#" <cfif getRival.preference_reason_id eq get_rival_preference_reasons.preference_reason_id>selected</cfif>>#preference_reason#</option>
                                    </cfloop>
                                </select>
                            </div>
                        </td>
                        <td><div class="form-group"><input type="text" name="rival_cause#currentrow#" id="rival_cause#currentrow#" value="#rival_cause#"/></div></td>
                        <td><div class="form-group"><input type="text" name="rival_price#currentrow#" id="rival_price#currentrow#" class="moneybox" value="#TLFormat(RIVAL_PRICE)#" onkeyup="return(FormatCurrency(this,event));"></div></td>
                        <td>
                            <div class="form-group">
                                <select name="money#currentrow#" id="money#currentrow#">
                                    <cfloop query="get_money">
                                        <option value="#get_money.money#" <cfif get_money.money is getRival.money_type>selected</cfif>>#get_money.money#</option>
                                    </cfloop>
                                </select>
                            </div>
                        </td>
                    </tr> 	
                </cfoutput>
                </tbody>
                <tfoot>
                    <tr>
                        <td colspan="6">
                            <div style="float:left;"><cf_workcube_buttons is_upd='0' add_function='rival_kontrol()' type_format='1'></div>
                            <div style="float:left;"><div id="show_user_message"></div></div>
                        </td>
                    </tr>
                </tfoot>
        </cf_grid_list>
    </cfform>
    <script type="text/javascript">
        row_count_=<cfoutput>#getRival.recordcount#</cfoutput>;
        function sil(sy)
        {
            var my_element=eval("add_opp_rival.row_kontrol_"+sy);
            my_element.value=0;
            var my_element=eval("frm_row1"+sy);
            my_element.style.display="none";
        }
        function add_row_rival()
        {
            row_count_++;
            var newRow;
            var newCell;
            newRow = document.getElementById("table2").insertRow(document.getElementById("table2").rows.length);
            newRow.setAttribute("name","frm_row1" + row_count_);
            newRow.setAttribute("id","frm_row1" + row_count_);	
            newRow.setAttribute("NAME","frm_row1" + row_count_);
            newRow.setAttribute("ID","frm_row1" + row_count_);				
            document.add_opp_rival.record_num_rival.value=row_count_;
            newCell = newRow.insertCell(newRow.cells.length);
            newCell.innerHTML = '<input type="hidden" name="row_kontrol_'+row_count_+'" value="1"><a style="cursor:pointer" onclick="sil(' + row_count_ + ');"><i class="fa fa-minus" title="<cf_get_lang dictionary_id='57463.Sil'>" alt="<cf_get_lang dictionary_id='57463.Sil'>"></i></a>';
            newCell = newRow.insertCell(newRow.cells.length);
            newCell.innerHTML = '<div class="form-group"><div class="input-group"><input type="text" name="rival_name'+row_count_+'" value="" style="width:95%" readonly><input type="hidden" name="rival_id'+row_count_+'" value=""><span class="input-group-addon icon-ellipsis" onClick="pencere_ac_company('+row_count_+');"></span></div></div>';
            newCell = newRow.insertCell(newRow.cells.length);
            newCell.innerHTML = '<div class="form-group"><select name="rival_preference_reason' + row_count_ +'"  style="width:100%;text-align:right;" ><option value=""><cf_get_lang dictionary_id="57734.Seçiniz"></option><cfoutput query="get_rival_preference_reasons"><option value="#preference_reason_id#">#preference_reason#</option></cfoutput></select></div>';
            newCell = newRow.insertCell(newRow.cells.length);
            newCell.innerHTML = '<div class="form-group"><input type="text" name="rival_cause' + row_count_ +'" id="rival_cause' + row_count_ +'" value=""></div>';
            newCell = newRow.insertCell(newRow.cells.length);
            newCell.innerHTML = '<div class="form-group"><input type="text" name="rival_price' + row_count_ +'" value="0" class="moneybox" onkeyup="return(FormatCurrency(this,event));" ></div>';
            newCell = newRow.insertCell(newRow.cells.length);
            newCell.innerHTML = '<div class="form-group"><select name="money' + row_count_ +'"><cfoutput query="get_money"><option value="#get_money.money#">#get_money.money#</option></cfoutput></select></div>';
        }
        <cfoutput>
            function pencere_ac_company(no)
            {
                openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_pars&select_list=2&field_comp_name=add_opp_rival.rival_name' + no +'&field_comp_id=add_opp_rival.rival_id' + no + '');
            }
            function rival_kontrol()
            {
                staticRow=0;
                for(r=1;r<=row_count_;r++)		
                {
                    if(eval("document.add_opp_rival.row_kontrol_"+r).value == 1)
                    {	
                        staticRow++;
                        deger_rival_id = eval("document.add_opp_rival.rival_id"+r);
                        if(deger_rival_id.value=="")
                        {
                            alert(staticRow+".Satir Rakip Semelisiniz !");
                            return false;
                        }
                    }
                }
                
                for(r=1;r<=row_count_;r++)
                {
                    if(eval("document.add_opp_rival.row_kontrol_"+r).value == 1)
                    {
                        eval("document.add_opp_rival.rival_price"+r).value = filterNum(eval("document.add_opp_rival.rival_price"+r).value);
                    }
                }
                AjaxFormSubmit(add_opp_rival,'show_user_message',0,'&nbsp;Kaydediliyor','&nbsp;Kaydedildi','#request.self#?fuseaction=sales.emptypopup_ajax_opp_rival<cfif isdefined("attributes.opp_id")>&opp_id=#attributes.opp_id#<cfelse>&offer_id=#attributes.offer_id#</cfif>','div_list_rival');return false;
            }
        </cfoutput>
    </script>
</div>
