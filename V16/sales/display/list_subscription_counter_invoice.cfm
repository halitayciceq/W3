<cfquery name="GET_SUBSCRIPTION" datasource="#DSN3#">
	SELECT 
    	SUBSCRIPTION_ID, 
        COMPANY_ID, 
        PARTNER_ID, 
        CONSUMER_ID, 
        PRODUCT_ID, 
        STOCK_ID, 
        OTHER_MONEY, 
        INVOICE_COMPANY_ID, 
        INVOICE_CONSUMER_ID, 
        SUBSCRIPTION_TYPE_ID, 
        MONTAGE_DATE, 
        START_DATE, 
        DISCOUNTTOTAL, 
        GROSSTOTAL, 
        NETTOTAL, 
        SUBSCRIPTION_DETAIL_2, 
        PROJECT_ID, 
        SA_DISCOUNT
    FROM 
    	SUBSCRIPTION_CONTRACT 
    WHERE 
	    SUBSCRIPTION_ID = #attributes.subscription_id#
</cfquery>
<cfquery name="GET_SUBSCRIPTION_COUNTER_START" datasource="#DSN3#">
	SELECT COUNTER_ID FROM SUBSCRIPTION_COUNTER WHERE SUBSCRIPTION_ID = #attributes.subscription_id# AND IS_INVOICE= 1
</cfquery>

<cfif GET_SUBSCRIPTION_COUNTER_START.recordcount>
	<cfset counter_id_list = valuelist(get_subscription_counter_start.counter_id)>
    <cfquery name="GET_COUNTER_RESULT" datasource="#DSN3#">
        SELECT
            SUBSCRIPTION_COUNTER_RESULT_ROW.COUNTER_RESULT_ROW_ID, 
            SUBSCRIPTION_COUNTER_RESULT_ROW.COUNTER_RESULT_ID, 
            SUBSCRIPTION_COUNTER_RESULT_ROW.COUNTER_ID, 
            SUBSCRIPTION_COUNTER_RESULT_ROW.NAME_PRODUCT, 
            SUBSCRIPTION_COUNTER_RESULT_ROW.PRODUCT_ID, 
            SUBSCRIPTION_COUNTER_RESULT_ROW.STOCK_ID, 
            SUBSCRIPTION_COUNTER_RESULT_ROW.START_VALUE, 
            SUBSCRIPTION_COUNTER_RESULT_ROW.FINISH_VALUE, 
            SUBSCRIPTION_COUNTER_RESULT_ROW.COUNTER_DIFFERENCE, 
            SUBSCRIPTION_COUNTER_RESULT_ROW.PRICE, 
            SUBSCRIPTION_COUNTER_RESULT_ROW.TOTAL, 
            SUBSCRIPTION_COUNTER_RESULT_ROW.OTHER_MONEY,
            SETUP_COUNTER_TYPE.COUNTER_TYPE,
            SUBSCRIPTION_COUNTER.IS_INVOICE AS C_IS_INVOICE
        FROM
            SUBSCRIPTION_COUNTER_RESULT_ROW,
            SUBSCRIPTION_COUNTER,
            SETUP_COUNTER_TYPE		
        WHERE
            SUBSCRIPTION_COUNTER_RESULT_ROW.COUNTER_ID IN (#counter_id_list#) AND
            SUBSCRIPTION_COUNTER_RESULT_ROW.COUNTER_ID = SUBSCRIPTION_COUNTER.COUNTER_ID AND
            SUBSCRIPTION_COUNTER.COUNTER_TYPE_ID = SETUP_COUNTER_TYPE.COUNTER_TYPE_ID		
        ORDER BY
            SUBSCRIPTION_COUNTER_RESULT_ROW.COUNTER_RESULT_ID,
            SUBSCRIPTION_COUNTER_RESULT_ROW.COUNTER_RESULT_ROW_ID
    </cfquery>
    <cfset counter_id_list = ListDeleteDuplicates(valuelist(get_counter_result.counter_id))>
    
    <!--- Bunun yapilma amaci sayaca ait okuma yoksa listeye gelmesin --->
    <cfif listlen(counter_id_list)>
        <cfquery name="GET_SUBSCRIPTION_COUNTER" datasource="#DSN3#">
            SELECT COUNTER_ID FROM SUBSCRIPTION_COUNTER WHERE COUNTER_ID IN (#counter_id_list#)
        </cfquery>
    <cfelse>
        <cfset GET_SUBSCRIPTION_COUNTER.recordcount = 0>
    </cfif>
<cfquery name="GET_CONTRACT_INVOICE" datasource="#DSN3#">
	SELECT
		RESULT_ROW_ID,
		SUM(INVOICE_VALUE) AS TOTAL_INVOICE_VALUE
	FROM
		SUBSCRIPTION_CONTRACT_INVOICE
	WHERE
		RESULT_ROW_ID IS NOT NULL
	GROUP BY
		RESULT_ROW_ID
	ORDER BY
		RESULT_ROW_ID		
</cfquery>
</cfif>
<cf_box title="#getLang('sales',63)#" scroll="1" collapsable="1" resize="1" popup_box="#iif(isdefined("attributes.draggable"),1,0)#"><!---Toplu Sayaç Faturalandırma--->
    <cfform name="list_counter_invoice" action="#request.self#?fuseaction=invoice.form_add_bill" target="_blank" method="post"><!--- #request.self#?fuseaction=sales.emptypopup_add_subscription_payment_plan --->
        <cfif len(get_subscription.invoice_company_id)>
            <input type="hidden" name="company_id" id="company_id" value="<cfoutput>#get_subscription.invoice_company_id#</cfoutput>">
            <input type="hidden" name="partner_id" id="partner_id" value="">
            <input type="hidden" name="comp_name" id="comp_name" value="<cfoutput>#get_par_info(get_subscription.invoice_company_id,1,1,0)#</cfoutput>"><!--- #get_par_info(get_subscription.partner_id,0,1,0)# --->
            <input type="hidden" name="consumer_id" id="consumer_id" value="">
            <input type="hidden" name="partner_name" id="partner_name" value="">
            <input type="hidden" name="member_account_code" id="member_account_code" value="<cfoutput>#get_company_period(get_subscription.invoice_company_id)#</cfoutput>">
        <cfelse>
            <input type="hidden" name="company_id" id="company_id" value="">
            <input type="hidden" name="partner_id" id="partner_id" value="">
            <input type="hidden" name="comp_name" id="comp_name" value="">
            <input type="hidden" name="consumer_id" id="consumer_id" value="<cfoutput>#get_subscription.invoice_consumer_id#</cfoutput>">
            <input type="hidden" name="partner_name" id="partner_name" value="<cfoutput>#get_cons_info(get_subscription.invoice_consumer_id,0,0)#</cfoutput>">
            <input type="hidden" name="member_account_code" id="member_account_code" value="<cfoutput>#get_consumer_period(get_subscription.invoice_consumer_id)#</cfoutput>">
        </cfif>

        <input type="hidden" name="subscription_id" id="subscription_id" value="<cfoutput>#attributes.subscription_id#</cfoutput>">
        <input type="hidden" name="list_payment_row_id" id="list_payment_row_id" value=""><!--- fatura kesilecek payment_idler burada ---> 
        <cfif GET_SUBSCRIPTION_COUNTER_START.recordcount>
            <input type="hidden" name="invoice_counter_number" id="invoice_counter_number" value="<cfoutput>#Listlen(counter_id_list,',')#</cfoutput>"><!--- fatura kesilecek sayac sayisi --->
        </cfif>
        <cf_grid_list>
            <thead>
                <tr>
                    <th width="80"><cf_get_lang dictionary_id="41282.Sayaç Tipi"></th>
                    <th width="250"><cf_get_lang dictionary_id="57657.Ürün"></th>
                    <th width="70">Ön.<cf_get_lang dictionary_id='35704.Değer'></th>
                    <th width="70"><cf_get_lang dictionary_id="41295.Son Değer"></th>
                    <th width="70"><cf_get_lang dictionary_id="58583.Fark"></th>
                    <th width="70"><cf_get_lang dictionary_id="58084.Fiyat"></th>
                    <th width="90"><cf_get_lang dictionary_id="57492.Toplam"></th>
                    <th><cf_get_lang dictionary_id='40603.Fatura Miktarı'></th>
                    <th><cf_get_lang dictionary_id="58693.Seç"></th>
                </tr>
            </thead>
            <tbody>
            <cfset my_sira = 0>
            <cfif GET_SUBSCRIPTION_COUNTER_START.recordcount>
                <cfif listlen(counter_id_list)>	
                    <cfloop query="GET_SUBSCRIPTION_COUNTER">
                        <cfset my_sira = my_sira + 1>
                        <cfset 'toplam_#my_sira#' = 0><!--- Toplam sayac count'u icin --->
                        <cfquery name="GET_COUNTER_RESULT_ROW" datasource="#DSN3#">
                            SELECT
                                SCRR.COUNTER_RESULT_ROW_ID, 
                                SCRR.COUNTER_RESULT_ID, 
                                SCRR.COUNTER_ID, 
                                SCRR.NAME_PRODUCT, 
                                SCRR.PRODUCT_ID, 
                                SCRR.STOCK_ID, 
                                SCRR.START_VALUE, 
                                SCRR.FINISH_VALUE, 
                                SCRR.COUNTER_DIFFERENCE, 
                                SCRR.PRICE, 
                                SCRR.TOTAL, 
                                SCRR.OTHER_MONEY,
                                SCT.COUNTER_TYPE,
                                SC.UNIT,
                                SC.UNIT_ID,
                                SC.IS_INVOICE AS C_IS_INVOICE,
                                SC.INVOICE_PERIOD,
                                SC.START_VALUE,
                                SC.FREE,
                                STOCKS.STOCK_CODE,
                                STOCKS.BARCOD AS BARCOD,			
                                STOCKS.MANUFACT_CODE,	
                                PRODUCT.TAX,
                                PRODUCT.IS_INVENTORY
                            FROM
                                SUBSCRIPTION_COUNTER_RESULT_ROW SCRR,
                                SUBSCRIPTION_COUNTER SC,
                                SETUP_COUNTER_TYPE SCT,
                                STOCKS,
                                PRODUCT
                            WHERE
                                SCRR.COUNTER_ID = #get_subscription_counter.counter_id# AND
                                SCRR.COUNTER_ID = SC.COUNTER_ID AND
                                SC.COUNTER_TYPE_ID = SCT.COUNTER_TYPE_ID AND
                                SCRR.STOCK_ID = STOCKS.STOCK_ID AND	
                                PRODUCT.PRODUCT_ID = STOCKS.PRODUCT_ID
                            
                            ORDER BY
                                SCRR.COUNTER_RESULT_ID,
                                SCRR.COUNTER_RESULT_ROW_ID
                        </cfquery>
                        <cfif get_counter_result_row.recordcount>
                            <cfset 'start_counter_#my_sira#' = get_counter_result_row.start_value[1] + get_counter_result_row.free[1]>
                            <cfinput type="hidden" name="start_counter_#my_sira#" value="#get_counter_result_row.start_value[1]+get_counter_result_row.free[1]#">
                            <cfinput type="hidden" name="invoice_period_#my_sira#" value="#get_counter_result_row.invoice_period[get_counter_result_row.recordcount]#">
                            <!--- <cfinput type="text" name="counter_row_#my_sira#" value=""> ---><!--- #get_counter_result_row.recordcount# --->
                        <cfelse>
                            <cfset 'start_counter_#my_sira#' = 0>
                            <cfinput type="hidden" name="start_counter_#my_sira#" value="">
                            <cfinput type="hidden" name="invoice_period_#my_sira#" value="">
                            <!--- <cfinput type="text" name="counter_row_#my_sira#" value=""> --->
                        </cfif>
                        <cfset result_row_count = 0>
                        <cfoutput query="get_counter_result_row">
                            <cfquery name="GET_CONTRACT_INVOICE_DETAIL" dbtype="query">
                                SELECT * FROM GET_CONTRACT_INVOICE WHERE RESULT_ROW_ID = #get_counter_result_row.counter_result_row_id[currentrow]#
                            </cfquery>
                            <!--- Bu bölüm hepsi faturalanan satırlarin ekrana gelmemesi icin yapildi --->
                            <cfset kontrol =0>
                            <cfif not get_contract_invoice_detail.recordcount or (get_contract_invoice_detail.recordcount and get_contract_invoice_detail.total_invoice_value lt get_counter_result_row.finish_value-evaluate('start_counter_#my_sira#'))>
                                <cfif get_counter_result_row.finish_value gt evaluate("start_counter_#my_sira#")>
                                <cfif start_value lt evaluate("start_counter_#my_sira#")>
                                    <cfif get_contract_invoice_detail.recordcount>
                                        <cfset kontrol = evaluate("toplam_#my_sira#") + finish_value-get_contract_invoice_detail.total_invoice_value-evaluate("start_counter_#my_sira#")>
                                    <cfelse>
                                        <cfset kontrol = evaluate("toplam_#my_sira#") + finish_value-evaluate("start_counter_#my_sira#")>
                                    </cfif>
                                <cfelse>
                                <cfif get_contract_invoice_detail.recordcount>
                                    <cfset kontrol = evaluate("toplam_#my_sira#") + counter_difference-get_contract_invoice_detail.total_invoice_value>
                                <cfelse>
                                    <cfset kontrol = evaluate("toplam_#my_sira#") + counter_difference>
                                </cfif>  
                            </cfif>
                                <cfelse>
                                <cfset kontrol =1>
                                </cfif>
                            </cfif>
                        
                        <cfif kontrol gt 0>
                            <cfset result_row_count = result_row_count + 1>
                            <cfif not get_contract_invoice_detail.recordcount or (get_contract_invoice_detail.recordcount and get_contract_invoice_detail.total_invoice_value lt get_counter_result_row.finish_value-evaluate('start_counter_#my_sira#'))>
                            <cfif get_counter_result_row.finish_value gt evaluate("start_counter_#my_sira#")><!--- Son degeri (sayac baslangic+ucretsiz i) asmissa  --->
                            <tr>
                            <input type="hidden" name="result_row_id_#my_sira#_#result_row_count#" id="result_row_id_#my_sira#_#result_row_count#" value="#counter_result_row_id#">		
                            <input type="hidden" name="product_name_#my_sira#_#result_row_count#" id="product_name_#my_sira#_#result_row_count#" value="#name_product#">
                            <input type="hidden" name="stock_id_#my_sira#_#result_row_count#" id="stock_id_#my_sira#_#result_row_count#" value="#stock_id#">
                            <input type="hidden" name="product_id_#my_sira#_#result_row_count#" id="product_id_#my_sira#_#result_row_count#" value="#product_id#">
                            <input type="hidden" name="amount_#my_sira#_#result_row_count#" id="amount_#my_sira#_#result_row_count#" value="#counter_difference#">
                            <input type="hidden" name="price_#my_sira#_#result_row_count#" id="price_#my_sira#_#result_row_count#" value="#price#">
                            <input type="hidden" name="other_money_#my_sira#_#result_row_count#" id="other_money_#my_sira#_#result_row_count#" value="#other_money#">			
                            <input type="hidden" name="unit_#my_sira#_#result_row_count#" id="unit_#my_sira#_#result_row_count#" value="#unit#">
                            <input type="hidden" name="unit_id_#my_sira#_#result_row_count#" id="unit_id_#my_sira#_#result_row_count#" value="#unit_id#">			
                            <input type="hidden" name="stock_code_#my_sira#_#result_row_count#" id="stock_code_#my_sira#_#result_row_count#" value="#stock_code#">
                            <input type="hidden" name="barcod_#my_sira#_#result_row_count#" id="barcod_#my_sira#_#result_row_count#" value="#barcod#">
                            <input type="hidden" name="tax_#my_sira#_#result_row_count#" id="tax_#my_sira#_#result_row_count#" value="#tax#">
                            <input type="hidden" name="is_inventory_#my_sira#_#result_row_count#" id="is_inventory_#my_sira#_#result_row_count#" value="#is_inventory#">
                            <input type="hidden" name="manufact_code_#my_sira#_#result_row_count#" id="manufact_code_#my_sira#_#result_row_count#" value="#manufact_code#">				
                            <td nowrap>#get_counter_result_row.counter_type#</td>
                            <td nowrap>#name_product#</td>
                            <td align="right" style="text-align:right;">#tlformat(start_value,0)#</td>
                            <td align="right" style="text-align:right;">#tlformat(finish_value,0)#</td>
                            <td align="right" style="text-align:right;">#tlformat(counter_difference,0)#</td>
                            <td align="right" style="text-align:right;"><input type="hidden" name="other_money#result_row_count#" id="other_money#result_row_count#" value="#other_money#">#tlformat(price,4)#</td>
                            <td align="right" style="text-align:right;">#tlformat(total,4)#</td>
                            <cfif start_value lt evaluate("start_counter_#my_sira#")><!--- baslangic degeri (sayac baslangici+ucretsiz den) kucukse  --->
                            <td>
                            <cfif get_contract_invoice_detail.recordcount><!--- daha once faturalanan deget toplama dahil edilmez --->
                            <cfset 'toplam_#my_sira#' = evaluate("toplam_#my_sira#") + finish_value-get_contract_invoice_detail.total_invoice_value-evaluate("start_counter_#my_sira#")>
                            <input type="text" name="invoice_difference_#my_sira#_#result_row_count#" id="invoice_difference_#my_sira#_#result_row_count#" value="#tlformat(finish_value-get_contract_invoice_detail.total_invoice_value-evaluate('start_counter_#my_sira#'),0)#" onchange="hesapla(#my_sira#);" onblur="hesapla(#my_sira#);" onkeyup="return(FormatCurrency(this,event,0));" class="moneybox" style="width:60px">
                            <input type="hidden" name="h_invoice_difference_#my_sira#_#result_row_count#" id="h_invoice_difference_#my_sira#_#result_row_count#" value="#finish_value-get_contract_invoice_detail.total_invoice_value-evaluate('start_counter_#my_sira#')#">
                            <cfelse>
                            <cfset 'toplam_#my_sira#' = evaluate("toplam_#my_sira#") + finish_value-evaluate("start_counter_#my_sira#")>
                            <input type="text" name="invoice_difference_#my_sira#_#result_row_count#" id="invoice_difference_#my_sira#_#result_row_count#" value="#tlformat(finish_value-evaluate('start_counter_#my_sira#'),0)#" onchange="hesapla(#my_sira#);" onblur="hesapla(#my_sira#);" onkeyup="return(FormatCurrency(this,event,0));" class="moneybox" style="width:60px">
                            <input type="hidden" name="h_invoice_difference_#my_sira#_#result_row_count#" id="h_invoice_difference_#my_sira#_#result_row_count#" value="#finish_value-evaluate('start_counter_#my_sira#')#">
                            </cfif>
                            </td>
                            <cfelse><!--- baslangic degeri (sayac baslangici+ucretsiz den) büyükse  --->
                            <td>
                            <cfif get_contract_invoice_detail.recordcount>
                            <cfset 'toplam_#my_sira#' = evaluate("toplam_#my_sira#") + counter_difference-get_contract_invoice_detail.total_invoice_value>
                            <input type="text" name="invoice_difference_#my_sira#_#result_row_count#" id="invoice_difference_#my_sira#_#result_row_count#" value="#tlformat(counter_difference-get_contract_invoice_detail.total_invoice_value,0)#" onchange="hesapla(#my_sira#);" onblur="hesapla(#my_sira#);" onkeyup="return(FormatCurrency(this,event,0));" class="moneybox" style="width:60px">
                            <input type="hidden" name="h_invoice_difference_#my_sira#_#result_row_count#" id="h_invoice_difference_#my_sira#_#result_row_count#" value="#counter_difference-get_contract_invoice_detail.total_invoice_value#">
                            <cfelse>
                            <cfset 'toplam_#my_sira#' = evaluate("toplam_#my_sira#") + counter_difference>
                            <input type="text" name="invoice_difference_#my_sira#_#result_row_count#" id="invoice_difference_#my_sira#_#result_row_count#" value="#tlformat(counter_difference,0)#" onchange="hesapla(#my_sira#);" onblur="hesapla(#my_sira#);" onkeyup="return(FormatCurrency(this,event,0));" class="moneybox" style="width:60px">
                            <input type="hidden" name="h_invoice_difference_#my_sira#_#result_row_count#" id="h_invoice_difference_#my_sira#_#result_row_count#" value="#counter_difference#">
                            </cfif>  
                            </td>
                            </cfif>
                            <td><input type="checkbox" name="is_invoice_#my_sira#_#result_row_count#" id="is_invoice_#my_sira#_#result_row_count#" value="1" onclick="hesapla(#my_sira#);" checked></td>	
                            </tr>
                            <cfelse><!--- Son degeri (sayac baslangic+ucretsiz i) asmamissa yani faturalanmayacak--->
                            <tr>
                            <td nowrap>#get_counter_result_row.counter_type#</td>
                            <td nowrap>#name_product#</td>
                            <td align="right" style="text-align:right;">#tlformat(start_value,0)#</td>
                            <td align="right" style="text-align:right;">#tlformat(finish_value,0)#</td>
                            <td align="right" style="text-align:right;">#tlformat(counter_difference,0)#</td>
                            <td align="right" style="text-align:right;"><input type="hidden" name="other_money#result_row_count#" id="other_money#result_row_count#" value="#other_money#">#tlformat(price,4)#</td>
                            <td align="right" style="text-align:right;">#tlformat(total,4)#</td>
                            <td>
                            <input type="text" name="invoice_difference_#my_sira#_#result_row_count#" id="invoice_difference_#my_sira#_#result_row_count#" value="0" onchange="hesapla(#my_sira#);" onblur="hesapla(#my_sira#);" onkeyup="return(FormatCurrency(this,event,0));" class="moneybox" disabled style="width:60px">
                            <input type="hidden" name="h_invoice_difference_#my_sira#_#result_row_count#" id="h_invoice_difference_#my_sira#_#result_row_count#" value="0">
                            </td>
                            <td><input type="checkbox" name="is_invoice_#my_sira#_#result_row_count#" id="is_invoice_#my_sira#_#result_row_count#" value="" onclick="hesapla(#my_sira#);" disabled></td>
                            </tr>
                            </cfif>
                            </cfif>
                            </cfif>
                            </cfoutput>
                            <input type="hidden" name="counter_row_<cfoutput>#my_sira#</cfoutput>" id="counter_row_<cfoutput>#my_sira#</cfoutput>" value="<cfoutput>#result_row_count#</cfoutput>">
                            <input type="hidden" name="invoice_product_name_<cfoutput>#my_sira#</cfoutput>" id="invoice_product_name_<cfoutput>#my_sira#</cfoutput>" value="">
                            <input type="hidden" name="invoice_stock_id_<cfoutput>#my_sira#</cfoutput>" id="invoice_stock_id_<cfoutput>#my_sira#</cfoutput>" value="">
                            <input type="hidden" name="invoice_product_id_<cfoutput>#my_sira#</cfoutput>" id="invoice_product_id_<cfoutput>#my_sira#</cfoutput>" value="">
                            <input type="hidden" name="invoice_amount_<cfoutput>#my_sira#</cfoutput>" id="invoice_amount_<cfoutput>#my_sira#</cfoutput>" value="">
                            <input type="hidden" name="invoice_price_<cfoutput>#my_sira#</cfoutput>" id="invoice_price_<cfoutput>#my_sira#</cfoutput>" value="">
                            <input type="hidden" name="invoice_total_<cfoutput>#my_sira#</cfoutput>" id="invoice_total_<cfoutput>#my_sira#</cfoutput>" value="">
                            <input type="hidden" name="invoice_other_money_<cfoutput>#my_sira#</cfoutput>" id="invoice_other_money_<cfoutput>#my_sira#</cfoutput>" value="">
                            <input type="hidden" name="invoice_unit_<cfoutput>#my_sira#</cfoutput>" id="invoice_unit_<cfoutput>#my_sira#</cfoutput>" value="">
                            <input type="hidden" name="invoice_unit_id_<cfoutput>#my_sira#</cfoutput>" id="invoice_unit_id_<cfoutput>#my_sira#</cfoutput>" value="">
                            <!--- <input type="hidden" name="invoice_result_count_<cfoutput>#my_sira#</cfoutput>" value="<cfoutput>#get_counter_result_row.recordcount#</cfoutput>"> --->
                            <input type="hidden" name="invoice_result_count_<cfoutput>#my_sira#</cfoutput>" id="invoice_result_count_<cfoutput>#my_sira#</cfoutput>" value="<cfoutput>#result_row_count#</cfoutput>">
                            <input type="hidden" name="invoice_stock_code_<cfoutput>#my_sira#</cfoutput>" id="invoice_stock_code_<cfoutput>#my_sira#</cfoutput>" value="">
                            <input type="hidden" name="invoice_barcod_<cfoutput>#my_sira#</cfoutput>" id="invoice_barcod_<cfoutput>#my_sira#</cfoutput>" value="">
                            <input type="hidden" name="invoice_tax_<cfoutput>#my_sira#</cfoutput>" id="invoice_tax_<cfoutput>#my_sira#</cfoutput>" value="">
                            <input type="hidden" name="invoice_is_inventory_<cfoutput>#my_sira#</cfoutput>" id="invoice_is_inventory_<cfoutput>#my_sira#</cfoutput>" value="">
                            <input type="hidden" name="invoice_manufact_code_<cfoutput>#my_sira#</cfoutput>" id="invoice_manufact_code_<cfoutput>#my_sira#</cfoutput>" value="">		
                            <tr>
                                <td colspan="7">
                                    <cfoutput>
                                    <b>
                                    #get_counter_result_row.counter_type[get_counter_result_row.recordcount]# - 
                                    <cf_get_lang dictionary_id='41283.Başlama Değeri'> : #tlformat(get_counter_result_row.start_value[1],0)# - 
                                    <cf_get_lang dictionary_id='41286.Ücretsiz'> : #tlformat(get_counter_result_row.free[1],0)# - 
                                    <cf_get_lang dictionary_id='63043.Faturalama Periyodu'> : #tlformat(get_counter_result_row.invoice_period[get_counter_result_row.recordcount],0)#
                                    </b>
                                    </cfoutput>
                                </td>
                                <td><input type="text" name="total_counter_difference_<cfoutput>#my_sira#</cfoutput>" id="total_counter_difference_<cfoutput>#my_sira#</cfoutput>" value="<cfoutput>#tlformat(evaluate('toplam_#my_sira#'),0)#</cfoutput>" class="moneybox" readonly></td>
                            </tr>
                </cfloop>
            </cfif>
            <cfelse>
                <tr>
                    <td colspan="9" height="20"><cf_get_lang dictionary_id='58486.Kayıt Bulunamadı'>!</td>
                </tr>
            </cfif>
            </tbody>
        </cf_grid_list>
        <cfif GET_SUBSCRIPTION_COUNTER_START.recordcount>
            <cf_box_footer>
                <cf_workcube_buttons is_upd='0' add_function="#iif(isdefined("attributes.draggable"),DE("kontrol() && loadPopupBox('list_counter_invoice' , #attributes.modal_id#)"),DE(""))#">
            </cf_box_footer>
        </cfif>
    </cfform>
</cf_box>
<cfif GET_SUBSCRIPTION_COUNTER_START.recordcount>
    <script type="text/javascript">
        function hesapla(sira_deger)
        {
            var dongu_deger = eval('list_counter_invoice.invoice_result_count_'+sira_deger);
            var toplam_deger = 0;
            for (var j=1; j <= dongu_deger.value; j++)
            {
                if(eval('list_counter_invoice.is_invoice_'+sira_deger+'_'+j).checked==true)
                if(eval('list_counter_invoice.invoice_difference_'+sira_deger+'_'+j).value.length != 0)
                    toplam_deger += parseInt(filterNum(eval('list_counter_invoice.invoice_difference_'+sira_deger+'_'+j).value));
            }
            eval('list_counter_invoice.total_counter_difference_'+sira_deger).value = commaSplit(toplam_deger,0);
        }
        function kontrol()
        {
            var kontrol_general = <cfoutput>#get_subscription_counter.recordcount#</cfoutput>;

            //1. Kontrol : Girilen fatura degeri buyuk olamaz

            for(var h=1; h <= <cfoutput>#get_subscription_counter.recordcount#</cfoutput>; h++)
            {
                var loop_number = eval('list_counter_invoice.counter_row_'+h).value;		
                for(var h1=1; h1 <= loop_number; h1++)
                {
                    
                    //alert('h h1 loop_number : '+h+'__'+h1+'__'+loop_number);
                    if(eval("list_counter_invoice.is_invoice_"+h+"_"+h1).checked)
                    {
                        fatura_degeri = parseInt(eval('list_counter_invoice.h_invoice_difference_'+h+'_'+h1).value);
                        change_fatura_degeri = parseInt(filterNum(eval('list_counter_invoice.invoice_difference_'+h+'_'+h1).value));		
                    
                        if(fatura_degeri<change_fatura_degeri)
                        {
                            alert(h+". <cf_get_lang dictionary_id='63045.Sayaç İçin Fatura Değerlerini Kontrol Ediniz'> !");
                            return false;
                        }
                    }
                }
            }
            
            //2. Kontrol : Faturalanacak sayac var mi?
            for(var j=1; j <= <cfoutput>#get_subscription_counter.recordcount#</cfoutput>; j++)
            {
                var kontrol_1 = parseInt(eval('list_counter_invoice.invoice_period_'+j).value);//Fatura periyodu
                var kontrol_2 = parseInt(filterNum(eval('list_counter_invoice.total_counter_difference_'+j).value));//Fatura Sayac Adeti
                var kontrol_3 = parseInt(parseInt(filterNum(eval('list_counter_invoice.total_counter_difference_'+j).value)) % parseInt(filterNum(eval('list_counter_invoice.invoice_period_'+j).value)));//Sayac Tutarı Uygunmu

                //alert('kontrol_1 : '+kontrol_1);
                

                if(kontrol_1<=kontrol_2)
                {
                    //alert('kontrol3: '+kontrol_3);
                    if(kontrol_3!=0)//Faturanacak Tutar Fatura Periyoduna Uygun mu?
                    {
                        alert(j+". <cf_get_lang dictionary_id='41290.Fatura Periyodunu Kontrol Ediniz'> !");
                        return false;				
                    }
                    else
                    {	
                        var dongu_deger = eval('list_counter_invoice.counter_row_'+j).value;
                        //alert('Dongü deger : '+dongu_deger);			

                        for(var k=dongu_deger; k>=0 ; k--)
                        {
                            //alert('Counter : '+ k);
                            if(eval("list_counter_invoice.is_invoice_"+j+"_"+k).checked)
                            {
                                eval('list_counter_invoice.invoice_product_name_'+j).value = eval('list_counter_invoice.product_name_'+j+'_'+k).value;
                                eval('list_counter_invoice.invoice_stock_id_'+j).value = eval('list_counter_invoice.stock_id_'+j+'_'+k).value;
                                eval('list_counter_invoice.invoice_product_id_'+j).value = eval('list_counter_invoice.product_id_'+j+'_'+k).value;
                                eval('list_counter_invoice.invoice_amount_'+j).value = filterNum(eval('list_counter_invoice.total_counter_difference_'+j).value,0);
                                eval('list_counter_invoice.invoice_price_'+j).value = eval('list_counter_invoice.price_'+j+'_'+k).value;
                                eval('list_counter_invoice.invoice_total_'+j).value = eval('list_counter_invoice.invoice_price_'+j).value *eval('list_counter_invoice.invoice_amount_'+j).value;
                                eval('list_counter_invoice.invoice_other_money_'+j).value = eval('list_counter_invoice.other_money_'+j+'_'+k).value;
                                eval('list_counter_invoice.invoice_stock_code_'+j).value = eval('list_counter_invoice.stock_code_'+j+'_'+k).value;
                                eval('list_counter_invoice.invoice_barcod_'+j).value = eval('list_counter_invoice.barcod_'+j+'_'+k).value;
                                eval('list_counter_invoice.invoice_tax_'+j).value = eval('list_counter_invoice.tax_'+j+'_'+k).value;
                                eval('list_counter_invoice.invoice_is_inventory_'+j).value = eval('list_counter_invoice.is_inventory_'+j+'_'+k).value;
                                eval('list_counter_invoice.invoice_manufact_code_'+j).value = eval('list_counter_invoice.manufact_code_'+j+'_'+k).value;
                                eval('list_counter_invoice.invoice_unit_'+j).value = eval('list_counter_invoice.unit_'+j+'_'+k).value;
                                eval('list_counter_invoice.invoice_unit_id_'+j).value = eval('list_counter_invoice.unit_id_'+j+'_'+k).value;
                                break;
                            }
                        }
                    }
                }
                else//fatura edilecek sayac var mi?
                {
                    kontrol_general --;
                }
            }
            
            //list_counter_invoice.invoice_counter_number.value = kontrol_general;
            
            if(kontrol_general==0)
            {
                alert("<cf_get_lang dictionary_id='63044.Bu Sistemde Fatura Kesilemez'> !");
                return false;
            }
            
            //En son islem burasi filternumdan gecirilir
            for(var count_value=1; count_value <= <cfoutput>#get_subscription_counter.recordcount#</cfoutput>; count_value++)
            {
                var loop_number = eval('list_counter_invoice.counter_row_'+count_value).value;
                for(var count_value2=1; count_value2 <= loop_number; count_value2++)
                {
                    eval("list_counter_invoice.is_invoice_"+count_value+"_"+count_value2).disabled = false;
                    eval("list_counter_invoice.invoice_difference_"+count_value+"_"+count_value2).disabled = false;
                    //eval("list_counter_invoice.h_invoice_difference_"+count_value+"_"+count_value2).disabled = false;
                    if(eval("list_counter_invoice.is_invoice_"+count_value+"_"+count_value2).checked)
                    {
                        eval('list_counter_invoice.invoice_difference_'+count_value+'_'+count_value2).value = filterNum(eval('list_counter_invoice.invoice_difference_'+count_value+'_'+count_value2).value);
                        eval('list_counter_invoice.h_invoice_difference_'+count_value+'_'+count_value2).value = filterNum(eval('list_counter_invoice.h_invoice_difference_'+count_value+'_'+count_value2).value);
                    }
                    /*else
                    {
                        eval('list_counter_invoice.invoice_difference_'+count_value+'_'+count_value2).value = 0;
                        eval('list_counter_invoice.h_invoice_difference_'+count_value+'_'+count_value2).value = 0;
                    }*/
                    eval('list_counter_invoice.total_counter_difference_'+count_value).value = filterNum(eval('list_counter_invoice.total_counter_difference_'+count_value).value);
                }
            }
            self.close();
            //return false;
        }
    </script>
</cfif>
