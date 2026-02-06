<cf_get_lang_set module_name="sales">
<cfinclude template="../query/get_subscription_cancel_type.cfm">
<cfquery name="get_order_detail" datasource="#dsn3#">
	SELECT ORDER_NUMBER,CONSUMER_ID,COMPANY_ID,ORDER_STATUS FROM ORDERS WHERE ORDER_ID = #attributes.order_id#
</cfquery>
<cfquery name="get_period" datasource="#dsn3#">
	SELECT KASA_PERIOD_ID AS PERIOD_ID FROM ORDER_CASH_POS WHERE ORDER_CASH_POS.IS_CANCEL = 0 AND ORDER_ID = #attributes.order_id# AND KASA_PERIOD_ID IS NOT NULL
</cfquery>
<cfif not get_period.recordcount>
	<cfquery name="get_period" datasource="#dsn3#">
		SELECT PERIOD_ID FROM ORDER_VOUCHER_RELATION WHERE ORDER_ID = #attributes.order_id# AND PERIOD_ID IS NOT NULL
	</cfquery>
</cfif>
<cfif get_period.recordcount>
	<cfquery name="get_company" datasource="#dsn#">
		SELECT * FROM SETUP_PERIOD WHERE PERIOD_ID = #get_period.period_id#
	</cfquery>
	<cfset new_dsn2 = '#dsn#_#get_company.period_year#_#get_company.our_company_id#'>
	<cfquery name="get_new_period" datasource="#dsn#">
		SELECT * FROM SETUP_PERIOD WHERE OUR_COMPANY_ID = #get_company.our_company_id# AND PERIOD_YEAR = #get_company.period_year+1#
	</cfquery>
	<cfif get_new_period.recordcount>
		<cfset new_dsn2_1 = '#dsn#_#get_company.period_year+1#_#get_company.our_company_id#'>
	</cfif>
<cfelse>
	<cfset get_new_period.recordcount = 0>
	<cfset new_dsn2 = '#dsn2#'>
</cfif>
<cfquery name="get_sale_vouchers" datasource="#new_dsn2#">
	SELECT 
		V.VOUCHER_ID
	FROM 
		VOUCHER V, 
		VOUCHER_PAYROLL VP 
	WHERE 
		V.VOUCHER_PAYROLL_ID = VP.ACTION_ID AND 
		VP.PAYMENT_ORDER_ID = #attributes.order_id#
		AND V.VOUCHER_STATUS_ID <> 1
</cfquery>
<cfquery name="get_sale_cheques" datasource="#new_dsn2#">
	SELECT 
		C.CHEQUE_ID
	FROM 
		CHEQUE C, 
		PAYROLL P 
	WHERE 
		C.CHEQUE_PAYROLL_ID = P.ACTION_ID AND 
		P.PAYMENT_ORDER_ID = #attributes.order_id#
		AND C.CHEQUE_STATUS_ID <> 1
</cfquery>
<cfif get_sale_vouchers.recordcount gt 0>
	<script type="text/javascript">
		alert("Siparişe Bağlı Senetlerde Tahsilat Yapıldığı İçin Siparişi İptal Edemezsiniz !");
		window.close();
		wrk_opener_reload();
	</script>
</cfif>
<cfif get_sale_cheques.recordcount gt 0>
	<script type="text/javascript">
		alert("Siparişe Bağlı Çeklerde Tahsilat Yapıldığı İçin Siparişi İptal Edemezsiniz !");
		window.close();
		wrk_opener_reload();
	</script>
</cfif>
<cfquery name="get_money_bskt" datasource="#dsn3#">
	SELECT 
		<cfif session.ep.period_year gte 2009>
			CASE WHEN MONEY_TYPE ='YTL' THEN 'TL' ELSE MONEY_TYPE END AS MONEY_TYPE
		<cfelse>
			MONEY_TYPE
		</cfif>,
		IS_SELECTED,
		RATE2,
		RATE1
	FROM 
		ORDER_MONEY 
	WHERE 
		ACTION_ID = #attributes.order_id#
</cfquery>
<cfquery name="get_sale_vouchers" datasource="#dsn2#">
	SELECT 
		VP.PAYROLL_NO,
		VP.ACTION_ID,
		V.VOUCHER_ID,
		V.VOUCHER_VALUE,
		V.VOUCHER_DUEDATE 
	FROM 
		VOUCHER V, 
		VOUCHER_PAYROLL VP 
	WHERE 
		V.VOUCHER_PAYROLL_ID = VP.ACTION_ID AND 
		VP.PAYMENT_ORDER_ID = #attributes.order_id#
</cfquery>
<cfquery name="get_sale_cheques" datasource="#new_dsn2#">
	SELECT 
		P.PAYROLL_NO,
		P.ACTION_ID,
		C.CHEQUE_ID,
		C.CHEQUE_VALUE,
		C.CHEQUE_DUEDATE 
	FROM 
		CHEQUE C, 
		PAYROLL P 
	WHERE 
		C.CHEQUE_PAYROLL_ID = P.ACTION_ID AND 
		P.PAYMENT_ORDER_ID = #attributes.order_id#
</cfquery>
<cfquery name="control_cashes" datasource="#dsn3#">
	SELECT 
		ORDER_CASH_POS.KASA_ID,
		CASH_ACTIONS.*
	FROM
		ORDERS,
		ORDER_CASH_POS,
		#new_dsn2#.CASH_ACTIONS CASH_ACTIONS
	WHERE
		CASH_ACTIONS.ACTION_ID=ORDER_CASH_POS.CASH_ID
		AND ORDER_CASH_POS.ORDER_ID=ORDERS.ORDER_ID 
		AND ORDERS.ORDER_ID=#attributes.order_id#
		AND ORDER_CASH_POS.IS_CANCEL = 0 
</cfquery>
<cfif len(get_order_detail.company_id)>
	<cfquery name="get_remainder" datasource="#dsn2#">
		SELECT * FROM COMPANY_REMAINDER WHERE COMPANY_ID = #get_order_detail.company_id#
	</cfquery>
<cfelseif len(get_order_detail.consumer_id)>
	<cfquery name="get_remainder" datasource="#dsn2#">
		SELECT * FROM CONSUMER_REMAINDER WHERE CONSUMER_ID = #get_order_detail.consumer_id#
	</cfquery>
<cfelse>
	<cfset get_remainder.recordcount = 0>
</cfif>
<cfif get_remainder.recordcount>
  <cfset borc = get_remainder.borc>
  <cfset alacak = get_remainder.alacak>
  <cfset bakiye = get_remainder.bakiye>
<cfelse>
  <cfset borc = 0>
  <cfset alacak = 0>
  <cfset bakiye = 0>
</cfif>
<cfinclude template="../query/get_cashes.cfm">
<cfinclude template="../query/get_pos_detail.cfm">
<cfset kasa_listesi=listsort(valuelist(control_cashes.KASA_ID,','),'numeric','desc',',')>
<cfinclude template="../query/get_sale_pos.cfm">
<cfsavecontent variable="txt">
    <cf_get_lang dictionary_id='41232.Satış İptal'> : <cfoutput>#get_order_detail.order_number#</cfoutput>
</cfsavecontent>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box title="#txt#" popup_box="1">
        <cfform name="form_basket" action="#request.self#?fuseaction=#listgetat(attributes.fuseaction,1,'.')#.emptypopup_add_order_cancel">
            <cfquery name="get_order_money" dbtype="query">
                SELECT * FROM get_money_bskt WHERE IS_SELECTED = 1
            </cfquery>
            <input type="hidden" name="order_money" id="order_money" value="<cfoutput>#get_order_money.money_type#</cfoutput>">
            <input type="hidden" name="company_id" id="company_id" value="<cfoutput>#get_order_detail.company_id#</cfoutput>">
            <input type="hidden" name="consumer_id" id="consumer_id" value="<cfoutput>#get_order_detail.consumer_id#</cfoutput>">
            <input type="hidden" name="order_id" id="order_id" value="<cfoutput>#attributes.order_id#</cfoutput>">
            <input type="hidden" name="order_number" id="order_number" value="<cfoutput>#get_order_detail.order_number#</cfoutput>">
                <cf_box_elements>
                    <div class="col col-6 col-md-6 col-sm-6 col-xs-12" type="column" index="1" sort="true">             
                        <div class="form-group">
                            <label class="col col-4 col-md-4 col-xs-4 col-sm-12"><cf_get_lang dictionary_id='57748.İptal Tarihi'> *</label>
                            <div class="col col-8 col-md-8 col-xs-8 col-sm-12">
                                <cfoutput>#dateformat(now(),dateformat_style)#</cfoutput>
                                <cfinput type="hidden" name="cancel_date" value="#dateformat(now(),dateformat_style)#" validate="#validate_style#" maxlength="10" style="width:140px">
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col col-4 col-md-4 col-xs-4 col-sm-12"><cf_get_lang dictionary_id='58825.İptal Nedeni'> *</label>
                            <div class="col col-8 col-md-8 col-xs-8 col-sm-12">
                                <select name="cancel_type" id="cancel_type">
                                    <option selected value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                    <cfoutput query="get_subscription_cancel_type">
                                        <option value="#subscription_cancel_type_id#">#subscription_cancel_type#</option>
                                    </cfoutput>
                                </select>
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col col-4 col-md-4 col-xs-4 col-sm-12"><cf_get_lang dictionary_id='57629.Açıklama'></label>
                                <div class="col col-8 col-md-8 col-xs-8 col-sm-12"><textarea name="cancel_detail" id="cancel_detail" style="width:140px;height:65px;"></textarea>
                            </div>
                        </div>
                    </div>
                    <div class="col col-6 col-md-6 col-sm-6 col-xs-12" type="column" index="2" sort="true">             
                        <div class="form-group">
                            <label class="col col-12 col-md-12 col-xs-12 col-sm-12 bold"><cf_get_lang dictionary_id='41368.Üye Finansal Özet'></label>
                        </div>
                        <cfoutput>
                            <div class="form-group">
                                <label class="col col-4 col-md-4 col-xs-4 col-sm-12"><cf_get_lang dictionary_id='57587.Borç'></label>
                                <div class="col col-8 col-md-8 col-xs-8 col-sm-12">#TLFormat(ABS(borc))#&nbsp;#session.ep.money#</div>
                            </div>
                            <div class="form-group">
                                <label class="col col-4 col-md-4 col-xs-4 col-sm-12"><cf_get_lang dictionary_id='57588.Alacak'></label>
                                <div class="col col-8 col-md-8 col-xs-8 col-sm-12">#TLFormat(ABS(alacak))#&nbsp;#session.ep.money#</div>
                            </div>
                            <div class="form-group">
                                <label class="col col-4 col-md-4 col-xs-4 col-sm-12"><cf_get_lang dictionary_id='57589.Bakiye'></label>
                                <div class="col col-8 col-md-8 col-xs-8 col-sm-12"> #TLFormat(abs(bakiye))#&nbsp;#session.ep.money# <cfif borc gte alacak>(B)<cfelse>(A)</cfif></div>
                            </div>
                        </cfoutput>
                    </div>
                </cf_box_elements>
                    <!--- Varsa Peşinatlar getiriliyor --->
                    <input type="hidden" name="cash_count" id="cash_count" value="<cfoutput>#control_cashes.recordcount#</cfoutput>">
                    <input type="hidden" name="pos_count" id="pos_count" value="<cfoutput>#control_pos_payment.recordcount#</cfoutput>">
                    <input type="hidden" name="voucher_count" id="voucher_count" value="<cfoutput>#get_sale_vouchers.recordcount#</cfoutput>">
                    <input type="hidden" name="cheque_count" id="cheque_count" value="<cfoutput>#get_sale_cheques.recordcount#</cfoutput>">
                    <cfif control_cashes.recordcount or control_pos_payment.recordcount>
                        <cf_seperator id="peşinat" header="#getLang('','Peşinat','57150')#" is_closed="1">
                        <div id="peşinat">
                            <cf_grid_list>
                                <cfif control_cashes.recordcount>
                                    <thead>
                                        <tr>
                                            <th><cf_get_lang dictionary_id='57847.Ödeme'></th>
                                            <th><cf_get_lang dictionary_id='57520.Kasa'></td>
                                            <th colspan="4">&nbsp;</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <cfoutput query="control_cashes">
                                            <tr>
                                                <td colspan="2" nowrap>
                                                    <input type="text" name="cash_amount#currentrow#" id="cash_amount#currentrow#" value="#TLFormat(cash_action_value)#" style="width:100px;" class="moneybox" readonly>
                                                    <input type="hidden" name="cash_action_id_#currentrow#" id="cash_action_id_#currentrow#" value="#action_id#">
                                                    <select name="kasa#currentrow#" id="kasa#currentrow#" style="width:140px;">
                                                        <cfloop query="get_cashes">
                                                            <option value="#get_cashes.cash_id#;#cash_currency_id#" <cfif control_cashes.kasa_id eq get_cashes.cash_id>selected</cfif>>#get_cashes.cash_name#-#get_cashes.cash_currency_id#</option>
                                                        </cfloop>
                                                    </select>
                                                    <cfquery name="get_row_money" dbtype="query">
                                                        SELECT 
                                                            RATE2,RATE1 
                                                        FROM 
                                                            get_money_bskt 
                                                        WHERE 
                                                            <cfif session.ep.period_year gte 2009>
                                                                <cfif cash_action_currency_id is 'YTL'>
                                                                    MONEY_TYPE = 'TL'
                                                                <cfelse>
                                                                    MONEY_TYPE = '#cash_action_currency_id#'
                                                                </cfif>
                                                            <cfelse>
                                                                MONEY_TYPE = '#cash_action_currency_id#'
                                                            </cfif>
                                                    </cfquery>
                                                    <cfset total_cash = cash_action_value*(get_row_money.rate2/get_row_money.rate1)>
                                                    <input type="hidden" name="system_cash_amount#currentrow#" id="system_cash_amount#currentrow#" value="#TLFormat(total_cash)#">
                                                    <input type="hidden" name="currency_type#currentrow#" id="currency_type#currentrow#" value="#cash_action_currency_id#">
                                                </td>
                                                <td></td>
                                            </tr>
                                        </cfoutput>
                                    </tbody>
                                </cfif>
                                <cfif control_pos_payment.recordcount>
                                    <thead>
                                        <tr>
                                            <th><cf_get_lang dictionary_id='57847.Ödeme'></th>
                                            <th><cf_get_lang dictionary_id='57520.Kasa'></td>
                                            <th colspan="4">&nbsp;</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <cfoutput query="control_pos_payment">
                                            <tr>
                                                <td nowrap>
                                                    <input type="text" name="pos_amount_#currentrow#" id="pos_amount_#currentrow#" value="#TLFormat(sales_credit)#" style="width:100px;" class="moneybox" readonly>
                                                    <input type="hidden" name="pos_action_id_#currentrow#" id="pos_action_id_#currentrow#" value="#creditcard_payment_id#">
                                                    <cfquery name="get_row_money_" dbtype="query">
                                                        SELECT 
                                                            RATE2,RATE1 
                                                        FROM 
                                                            get_money_bskt 
                                                        WHERE 
                                                            <cfif session.ep.period_year gte 2009>
                                                                <cfif action_currency_id is 'YTL'>
                                                                    MONEY_TYPE = 'TL'
                                                                <cfelse>
                                                                    MONEY_TYPE = '#action_currency_id#'
                                                                </cfif>
                                                            <cfelse>
                                                                MONEY_TYPE = '#action_currency_id#'
                                                            </cfif>
                                                    </cfquery>
                                                    <cfset total_credit = sales_credit*(get_row_money_.rate2/get_row_money_.rate1)>
                                                    <input type="hidden" name="system_pos_amount_#currentrow#" id="system_pos_amount_#currentrow#" value="#TLFormat(total_credit)#">
                                                </td>
                                                <td align="left" nowrap>
                                                    <select name="pos_#currentrow#" id="pos_#currentrow#" style="width:220px;">
                                                        <cfloop query="get_pos_detail">
                                                            <option value="#account_id#;#account_currency_id#;#payment_type_id#" <cfif get_pos_detail.payment_type_id eq control_pos_payment.payment_type_id>selected</cfif>>#account_name# / #card_no#</option>
                                                        </cfloop>
                                                    </select>
                                                </td>
                                            </tr>
                                        </cfoutput>
                                    </tbody>
                                </cfif>
                            </cf_grid_list>
                        </div> 
                    </cfif>
                    <!--- Varsa Seneler Getiriliyor --->
                    <cfif get_sale_vouchers.recordcount>
                        <cf_seperator id="senetler" header="#getLang('','Senetler','50333')#" is_closed="1">
                        <div id="senetler">
                            <cf_grid_list name="table1_3" id="table1_3" >
                                <cfinput type="hidden" name="payroll_no" value="#get_sale_vouchers.payroll_no#">
                                <cfinput type="hidden" name="voucher_id_list" value="#valuelist(get_sale_vouchers.voucher_id,',')#">
                                <cfinput type="hidden" name="payroll_id" value="#get_sale_vouchers.action_id#">
                                <input type="hidden" name="record_num_3" id="record_num_3" value="<cfoutput>#get_sale_vouchers.recordcount#</cfoutput>">
                                <thead>
                                    <tr>
                                        <th><cf_get_lang dictionary_id='57673.Tutar'></th>
                                        <th><cf_get_lang dictionary_id='57881.Vade Tarihi'></th>
                                    </tr>
                                </thead> 
                                <cfset senet_toplam = 0>
                                <tbody>
                                    <cfoutput query="get_sale_vouchers">
                                        <cfset senet_toplam = senet_toplam + voucher_value>
                                        <tr>
                                            <td>
                                                <input type="hidden" class="boxtext" name="voucher_id#currentrow#" id="voucher_id#currentrow#" value="#voucher_id#">
                                                <input type="hidden" name="first_voucher_value#currentrow#" id="first_voucher_value#currentrow#" value="#tlformat(voucher_value,4)#">
                                                <input type="text" class="moneybox" name="voucher_value#currentrow#" id="voucher_value#currentrow#" style="width:90px;"  value="#tlformat(voucher_value,4)#" maxlength="50" readonly>
                                            </td>
                                            <td nowrap="nowrap">
                                                <input type="hidden" name="first_due_date#currentrow#" id="first_due_date#currentrow#" value="#dateformat(voucher_duedate,dateformat_style)#">
                                                <input type="text" name="due_date#currentrow#" id="due_date#currentrow#" style="width:70px;" value="#dateformat(voucher_duedate,dateformat_style)#" readonly>
                                            </td>
                                        </tr>
                                    </cfoutput>
                                
                                <tr>
                                    <td><input type="text" name="total_voucher_value" id="total_voucher_value" value="<cfoutput>#tlformat(senet_toplam,4)#</cfoutput>" style="width:90px;" class="moneybox" readonly></td>
                                    <td class="txtbold"><cf_get_lang dictionary_id='50452.Senet Toplam'></td>
                                </tr>
                            </tbody>
                        </cf_grid_list>
                    </div>
                    <cfelse>
                        <input type="hidden" name="total_voucher_value" id="total_voucher_value" value="0">
                    </cfif>
                    <!--- Varsa çekler Getiriliyor --->
                    <cfif get_sale_cheques.recordcount>
                        <cf_seperator id="çekler" header="#getLang('','Çekler','63206')#" is_closed="1">
                        <div id="çekler">
                            <cf_grid_list name="table1_3" id="table1_3" cellspacing="1" cellpadding="2" border="0">
                                <cfinput type="hidden" name="cheque_payroll_no" value="#get_sale_cheques.payroll_no#">
                                <cfinput type="hidden" name="cheque_id_list" value="#valuelist(get_sale_cheques.cheque_id,',')#">
                                <cfinput type="hidden" name="cheque_payroll_id" value="#get_sale_cheques.action_id#">
                                <input type="hidden" name="record_num_4" id="record_num_4" value="<cfoutput>#get_sale_cheques.recordcount#</cfoutput>">
                               <thead>
                                    <tr>
                                        <td width="80"><cf_get_lang dictionary_id='57673.Tutar'></td>
                                        <td width="65"><cf_get_lang dictionary_id='57881.Vade Tarihi'></td>
                                    </tr>
                                </thead>
                                <cfset cek_toplam = 0>
                                <tbody>
                                    <cfoutput query="get_sale_cheques">
                                        <cfset cek_toplam = cek_toplam + cheque_value>
                                        <tr>
                                            <td>
                                                <input type="hidden" class="boxtext" name="cheque_id#currentrow#" id="cheque_id#currentrow#" value="#cheque_id#">
                                                <input type="hidden" name="first_cheque_value#currentrow#" id="first_cheque_value#currentrow#" value="#tlformat(cheque_value,4)#">
                                                <input type="text" class="moneybox" name="cheque_value#currentrow#" id="cheque_value#currentrow#" style="width:90px;" value="#tlformat(cheque_value,4)#" maxlength="50" readonly>
                                            </td>
                                            <td nowrap="nowrap">
                                                <input type="hidden" name="first_cheque_due_date#currentrow#" id="first_cheque_due_date#currentrow#" value="#dateformat(cheque_duedate,dateformat_style)#">
                                                <input type="text" name="cheque_due_date#currentrow#" id="cheque_due_date#currentrow#" style="width:70px;" value="#dateformat(cheque_duedate,dateformat_style)#" readonly>
                                            </td>
                                        </tr>
                                    </cfoutput>
                                    <tr>
                                        <td><input type="text" name="total_cheque_value" id="total_cheque_value" value="<cfoutput>#tlformat(cek_toplam,4)#</cfoutput>" style="width:90px;" class="moneybox" readonly></td>
                                        <td class="txtbold"><cf_get_lang dictionary_id='40822.Çek Toplam'></td>
                                    </tr>
                                </tbody>
                            </cf_grid_list>
                        </div>
                    <cfelse>
                        <input type="hidden" name="total_cheque_value" id="total_cheque_value" value="0">
                    </cfif>
            <cf_box_footer>
                <div class="col col-12"><cf_workcube_buttons is_upd='0' is_cancel='1' add_function='kontrol()'></div>
            </cf_box_footer>
        </cfform>
    </cf_box>
</div>
<script type="text/javascript">
	function kontrol()
	{
		x = document.form_basket.cancel_type.selectedIndex;
		if (document.form_basket.cancel_type[x].value == "")
		{ 
			alert ("<cf_get_lang dictionary_id='41140.İptal Nedeni Seçmediniz'> ! ");
			return false;
		}
		
		y = (100 - document.form_basket.cancel_detail.value.length);
		if ( y < 0)
		{ 
			alert ("<cf_get_lang dictionary_id='57629.Açıklama'><cf_get_lang dictionary_id='41141.Alanına 100 Karakterden Fazla Girmeyiniz. Fazla Karakter Sayısı:'>"+ ((-1) * y));
			return false;
		}
		return true;
	}
</script>
<cf_get_lang_set module_name="#lcase(listgetat(attributes.fuseaction,1,'.'))#">
