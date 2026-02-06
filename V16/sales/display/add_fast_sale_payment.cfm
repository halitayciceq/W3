<cfset account_status = 1>
<cfset cash_status = 1>
<cfinclude template="../query/get_cashes.cfm">
<cfinclude template="../query/get_pos_detail.cfm">
    <div class="col col-4 col-md-5 col-sm-6 col-xs-12 padding-bottom-10" type="column" index="8" sort="false">
        <cf_seperator id="pesinat" header="#getLang('','Peşinat',57150)#">
        <div class="row" id="pesinat">
            <div class="col col-12 col-xs-12">
                <cf_grid_list>
                    <cfif get_cashes.recordcount>
                        <cfquery name="get_session_cash" dbtype="query">
                            SELECT 
                                * 
                            FROM 
                                get_cashes 
                            WHERE 
                                CASH_CURRENCY_ID = '#session.ep.money#'
                        </cfquery>
                        <input type="hidden" name="kontrol_cash" id="kontrol_cash" value="<cfoutput>#get_session_cash.recordcount#</cfoutput>">
                        <thead>
                            <tr>
                                <th style="width:45px;"><cf_get_lang dictionary_id='57847.Ödeme'></th>
                                <th><cf_get_lang dictionary_id='57520.Kasa'></th>
                            </tr>
                        </thead>
                        <cfoutput query="get_money_bskt">
                            <cfquery name="get_money_cashes" dbtype="query">
                                SELECT
                                    CASH_ID, 
                                    CASH_NAME,
                                    CASH_CURRENCY_ID,
                                    BRANCH_ID
                                FROM 
                                    get_cashes
                                WHERE 
                                    CASH_CURRENCY_ID='#money_type#'
                            </cfquery>
                            <cfif get_money_cashes.recordcount>
                            <tbody>
                                <tr>
                                    <td nowrap>
                                        <input type="text" name="cash_amount#currentrow#" id="cash_amount#currentrow#" value="" style="width:100px;" class="moneybox" onChange="kasa_dovizi_hesapla(#currentrow#);return(FormatCurrency(this,event));" onKeyUp="kasa_dovizi_hesapla(#currentrow#);return(FormatCurrency(this,event));">
                                    </td>
                                    <td>
                                        <input type="hidden" name="cash_action_id_#currentrow#" id="cash_action_id_#currentrow#" value="">
                                        <div class="form-group">
                                            <select name="kasa#currentrow#" id="kasa#currentrow#">
                                                <cfloop query="get_money_cashes">
                                                    <option value="#get_money_cashes.cash_id#" <cfif session.ep.isBranchAuthorization and branch_id eq ListGetAt(session.ep.user_location,2,"-")>selected</cfif>>#get_money_cashes.cash_name#-#get_money_cashes.cash_currency_id#</option>
                                                </cfloop>
                                            </select>
                                        </div>
                                        <input type="hidden" name="system_cash_amount#currentrow#" id="system_cash_amount#currentrow#" value="">
                                        <input type="hidden" name="currency_type#currentrow#" id="currency_type#currentrow#" value="#money_type#">
                                    </td>
                                </tr>
                            </tbody>
                            </cfif>
                        </cfoutput>
                    <cfelse>
                        <strong><cf_get_lang dictionary_id='58739.Kasa Tanımları Eksik'>!</strong>
                        <input type="hidden" name="kontrol_cash" id="kontrol_cash" value="0">
                    </cfif>
                </cf_grid_list>
            </div>
        </div>
    <cf_seperator id="kredi" header="#getLang('','KrediKartı',58199)#">
    <div class="row" id="kredi">
        <div class="col col-12">
            <div class="col col-12 col-xs-12">
                <div class="ui-scroll">
                    <table id="table2" class="ui-table-list ui-form">
                        <cfif get_pos_detail.recordcount>
                            <thead>
                                <tr>
                                    <th style="width:30px;"><a href="javascript://" onClick="add_row_2_pay();"><i class="fa fa-plus"></i></a></th>
                                    <th class="txtbold"><cf_get_lang dictionary_id='57847.Ödeme'></th>
                                    <th class="txtbold"><cf_get_lang dictionary_id='58516.Ödeme Yöntemi'></th>	
                                </tr>
                            </thead>
                            <tbody>
                                <cfoutput>
                                    <input name="record_num2" id="record_num2" type="hidden" value="1">
                                    <tr id="frm_row21">
                                        <td><input type="hidden" name="row_kontrol_21" id="row_kontrol_21" value="1"><a href="javascript://" onClick="sil_2('1');"><i class="fa fa-delete"></i></a></td>
                                        <td>
                                            <div class="form-group">
                                                <input type="text" name="pos_amount_1" id="pos_amount_1" value="" class="moneybox" onChange="pos_hesapla(1);return(FormatCurrency(this,event,4));" onKeyUp="pos_hesapla(1);return(FormatCurrency(this,event,4));">
                                            </div>
                                            <input type="hidden" name="pos_action_id_1" id="pos_action_id_1" value="">
                                            <input type="hidden" name="system_pos_amount_1" id="system_pos_amount_1" value="">
                                        </td>
                                        <td>
                                            <div class="form-group">
                                                <select name="pos_1" id="pos_1" onChange="pos_hesapla(1);">
                                                    <cfloop query="GET_POS_DETAIL">
                                                        <option value="#account_id#;#account_currency_id#;#payment_type_id#">#card_no#</option>
                                                    </cfloop>
                                                </select>
                                            </div>
                                        </td>				
                                    </tr>
                                </cfoutput>
                            </tbody>
                        <cfelse>
                            <strong><cf_get_lang dictionary_id='58740.Pos Tanımları Eksik'>!</strong>
                        </cfif>
                    </table>
                </div>
            </div>
        </div>
    </div>
    <cf_seperator id="toplam" header="#getLang('','Toplam Ödeme',39895)#">
        <div class="row" id="toplam">
            <div class="col col-12 col-xs-12">
                <cf_grid_list>
                    <thead>
                        <tr>
                            <th > <cf_get_lang dictionary_id='34701.Peşin'>+<cf_get_lang dictionary_id='41258.Kart Ödeme'></th>
                            <th><cf_get_lang dictionary_id='39895.Toplam Ödeme'></th>         
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td class="text-right">
                                <input type="text" name="total_cash_amount" id="total_cash_amount" value=""  class="moneybox" readonly="yes">
                            </td>
                            <td class="text-right">
                                <input type="text" name="total_payment_amount" id="total_payment_amount" value=""  class="moneybox" readonly="yes">  
                            </td>
                        </tr>
                    </tbody>
                </cf_grid_list>
            </div>
        </div>
    </div>
</div>
