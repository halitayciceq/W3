<cfinclude template="../query/get_sale_pos.cfm">
<cfquery name="get_pos_detail" datasource="#dsn3#">
	SELECT
		ACCOUNTS.ACCOUNT_ID,
		ACCOUNTS.ACCOUNT_NAME,
		<cfif session.ep.period_year lt 2009>
			CASE WHEN(ACCOUNTS.ACCOUNT_CURRENCY_ID = 'TL') THEN 'YTL' ELSE ACCOUNTS.ACCOUNT_CURRENCY_ID END AS ACCOUNT_CURRENCY_ID,
		<cfelse>
			ACCOUNTS.ACCOUNT_CURRENCY_ID,
		</cfif>
		CPT.PAYMENT_TYPE_ID,
		CPT.CARD_NO,
		ISNULL(CPT.PAYMENT_RATE,0) PAYMENT_RATE
	FROM
		ACCOUNTS ACCOUNTS,
		CREDITCARD_PAYMENT_TYPE CPT
	WHERE
		CPT.IS_ACTIVE = 1
		<cfif session.ep.period_year lt 2009>
			AND (ACCOUNTS.ACCOUNT_CURRENCY_ID IN (SELECT MONEY FROM #dsn2_alias#.SETUP_MONEY) OR ACCOUNTS.ACCOUNT_CURRENCY_ID = 'TL')  
		<cfelse>
			AND ACCOUNTS.ACCOUNT_CURRENCY_ID IN (SELECT MONEY FROM #dsn2_alias#.SETUP_MONEY) 
		</cfif>
		AND ACCOUNTS.ACCOUNT_ID = CPT.BANK_ACCOUNT 
		<cfif isdefined("account_status")>
			AND ACCOUNTS.ACCOUNT_STATUS = 1 
		</cfif>
		<cfif session.ep.isBranchAuthorization>
			AND 
			(
				ACCOUNTS.ACCOUNT_ID IN(SELECT AB.ACCOUNT_ID FROM ACCOUNTS_BRANCH AB WHERE AB.BRANCH_ID IN(SELECT EMPLOYEE_POSITION_BRANCHES.BRANCH_ID FROM #dsn_alias#.EMPLOYEE_POSITION_BRANCHES EMPLOYEE_POSITION_BRANCHES WHERE EMPLOYEE_POSITION_BRANCHES.POSITION_CODE = #session.ep.position_code#))
				<cfif control_pos_payment.recordcount>
					OR ACCOUNTS.ACCOUNT_ID IN(#valuelist(control_pos_payment.action_to_account_id)#)
				</cfif>
			)
		</cfif>
	ORDER BY
		CPT.CARD_NO
</cfquery>
<cfquery name="control_cashes_all" dbtype="query">
	SELECT KASA_ID FROM control_cashes
	UNION
	SELECT PAYROLL_CASH_ID KASA_ID FROM get_sale_vouchers
	UNION
	SELECT PAYROLL_CASH_ID KASA_ID FROM get_sale_cheques
</cfquery>
<cfset kasa_listesi=listsort(valuelist(control_cashes_all.KASA_ID,','),'numeric','desc',',')>

<div class="col col-4 col-md-5 col-sm-6 col-xs-12 padding-bottom-10" type="column" index="8" sort="false">
    <cf_seperator id="nakit" header="#getLang('','Nakit',58645)#">
    <div class="row" id="nakit">
        <div class="col col-12">
            <cf_grid_list class="workDevList">
                <cfif get_cashes.recordcount>
                    <cfquery name="get_session_cash" dbtype="query">
                        SELECT * FROM get_cashes WHERE CASH_CURRENCY_ID = '#session.ep.money#'
                    </cfquery>
                    <input type="hidden" name="kontrol_cash" id="kontrol_cash" value="<cfoutput>#get_session_cash.recordcount#</cfoutput>">
                    <thead>
                        <tr>
                            <th style="width:45px;"><cf_get_lang dictionary_id='57847.Ödeme'></th>
                            <th><cf_get_lang dictionary_id='57520.Kasa'></th>
                        </tr>
                    </thead>
                    <tbody>
                    <cfoutput query="get_money_bskt">
                        <cfquery name="get_money_cashes" dbtype="query">
                            SELECT
                                CASH_ID, 
                                CASH_NAME,
                                CASH_CURRENCY_ID
                            FROM 
                                get_cashes
                            WHERE 
                                <cfif money_type is 'TL'>
                                    CASH_CURRENCY_ID='#money_type#' OR CASH_CURRENCY_ID= 'YTL'
                                <cfelse>
                                    CASH_CURRENCY_ID='#money_type#'	
                                </cfif>
                        </cfquery>
                        <cfif get_money_cashes.recordcount>
                        <tr>
                            <cfif control_cashes.recordcount>
                                <cfquery name="get_cash_amount" dbtype="query">
                                    SELECT CASH_ACTION_VALUE,ACTION_ID FROM control_cashes WHERE 
                                    <cfif money_type is 'TL'>
                                        CASH_ACTION_CURRENCY_ID='#money_type#' OR CASH_ACTION_CURRENCY_ID= 'YTL'
                                    <cfelse>
                                        CASH_ACTION_CURRENCY_ID='#money_type#'	
                                    </cfif>
                                </cfquery>
                            </cfif>
                            <td nowrap>
                                <input type="text" name="cash_amount#currentrow#" id="cash_amount#currentrow#" <cfif kontrol_form_update eq 1>disabled</cfif> value="<cfif control_cashes.recordcount>#TLFormat(get_cash_amount.CASH_ACTION_VALUE)#</cfif>" style="width:160px;" class="moneybox" onChange="kasa_dovizi_hesapla(#currentrow#,0);return(FormatCurrency(this,event));" onKeyUp="kasa_dovizi_hesapla(#currentrow#,0);return(FormatCurrency(this,event));">
                            </td>
                            <td>
                                <input type="hidden" name="cash_action_id_#currentrow#" id="cash_action_id_#currentrow#" value="<cfif control_cashes.recordcount>#get_cash_amount.ACTION_ID#</cfif>">
                                <div class="form-group">
                                    <select name="kasa#currentrow#" id="kasa#currentrow#" style="width:160px;" <cfif kontrol_form_update eq 1>disabled</cfif>>
                                        <cfloop query="get_money_cashes">
                                            <option value="#get_money_cashes.cash_id#" <cfif listfind(kasa_listesi,get_money_cashes.CASH_ID,',')>selected</cfif>>#get_money_cashes.cash_name#-#get_money_cashes.cash_currency_id#</option>
                                        </cfloop>
                                    </select>
                                </div>
                                <input type="hidden" name="system_cash_amount#currentrow#" id="system_cash_amount#currentrow#" value="">
                                <input type="hidden" name="currency_type#currentrow#" id="currency_type#currentrow#" value="#money_type#">
                            </td>
                        </tr>
                        </cfif>
                    </cfoutput>
                </tbody>
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
            <cfif get_pos_detail.recordcount>
                <cf_grid_list class="workDevList">
                    <thead>
                        <tr>
                            <th width="20"><cfif kontrol_form_update eq 0><a href="javascript://" onClick="add_row_2_pay();"><i class="fa fa-plus" title="<cf_get_lang dictionary_id='57582.Ekle'>"></i></a></cfif></th>
                            <th width="25"><cf_get_lang dictionary_id='57847.Ödeme'></th>
                            <th><cf_get_lang dictionary_id='58516.Ödeme Yöntemi'></th>					
                        </tr>
                    </thead>
                    <tbody  id="table2" name="table2">
                        <cfoutput>
                            <cfif control_pos_payment.recordcount eq 0>
                                <cfset new_count = 1>
                            <cfelse>
                                <cfset new_count = control_pos_payment.recordcount>
                            </cfif>
                            <input name="record_num2" id="record_num2" type="hidden" value="<cfoutput>#new_count#</cfoutput>">
                            <cfloop from="1" to="#new_count#" index="kkm">
                                <tr id="frm_row2#kkm#">
                                    <td><input type="hidden" style="width:35px;" name="row_kontrol_2#kkm#" id="row_kontrol_2#kkm#" value="1"><cfif kontrol_form_update eq 0><a href="javascript://" onClick="sil_2('#kkm#');"><i class="fa fa-minus" title="<cf_get_lang dictionary_id='57463.Sil'>"></i></a></cfif></td>
                                        <td>
                                            <input type="text" name="pos_amount_#kkm#" id="pos_amount_#kkm#" <cfif kontrol_form_update eq 1>disabled</cfif> value="<cfif CONTROL_POS_PAYMENT.recordcount and len(CONTROL_POS_PAYMENT.SALES_CREDIT[#kkm#])>#TLFormat(CONTROL_POS_PAYMENT.SALES_CREDIT[kkm],4)#</cfif>" class="moneybox" onChange="pos_hesapla(#kkm#,0);return(FormatCurrency(this,event,4));" onKeyUp="pos_hesapla(#kkm#,0);return(FormatCurrency(this,event,4));">
                                            <input type="hidden" name="pos_action_id_#kkm#" id="pos_action_id_#kkm#" value="<cfif CONTROL_POS_PAYMENT.recordcount and len(CONTROL_POS_PAYMENT.CREDITCARD_PAYMENT_ID[#kkm#])>#CONTROL_POS_PAYMENT.CREDITCARD_PAYMENT_ID[kkm]#</cfif>">
                                        <input type="hidden" name="system_pos_amount_#kkm#" id="system_pos_amount_#kkm#" value="">
                                    </td>
                                    <td align="left" nowrap>
                                    <div class="form-group">
                                        <select name="pos_#kkm#" id="pos_#kkm#" onChange="pos_hesapla(#kkm#);" <cfif kontrol_form_update eq 1>disabled</cfif>>
                                            <cfloop query="GET_POS_DETAIL">
                                                <option value="#account_id#;#account_currency_id#;#payment_type_id#" <cfif CONTROL_POS_PAYMENT.recordcount and (GET_POS_DETAIL.PAYMENT_TYPE_ID eq CONTROL_POS_PAYMENT.PAYMENT_TYPE_ID[#kkm#])>selected</cfif>>#card_no#</option>
                                            </cfloop>
                                        </select>
                                    </div>
                                    </td>				
                            </tr>
                            </cfloop>
                        </cfoutput>
                    </tbody>
                </cf_grid_list>
                <cfelse>
                    <br/><strong><cf_get_lang dictionary_id='58740.Pos Tanımları Eksik'>!</strong>
                </cfif>
        </div>
    </div>
    <cf_seperator id="toplam" header="#getLang('','Toplam Ödeme',39895)#">
    <div class="row" id="toplam">
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
                        <div class="form-group">
                            <input type="text" name="total_cash_amount" id="total_cash_amount" value="" class="moneybox" readonly="yes">
                        </div>
                    </td>
                    <td class="text-right">
                        <div class="form-group">
                            <input type="text" name="total_payment_amount" id="total_payment_amount" value="" class="moneybox" readonly="yes">
                        </div>
                    </td>
                </tr>
            </tbody>
        </cf_grid_list>
    </div>
</div>