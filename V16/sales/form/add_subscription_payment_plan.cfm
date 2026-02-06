<cfset contract_cmp = createObject("component","V16.sales.cfc.subscription_contract")>
<cf_xml_page_edit fuseact ="sales.popup_subscription_payment_plan">
    <cfparam name="attributes.row_start_date" default="#dateformat(session.ep.period_start_date,dateformat_style)#">
    <cfparam name="attributes.row_finish_date" default="">
    <cfparam name="attributes.paymethod" default="">
    <cfparam name="attributes.paymethod_id" default="">
    <cfparam name="attributes.card_paymethod_id" default="">
    <cfparam name="attributes.product_name" default="">
    <cfparam name="attributes.product_id" default="">
    <cfparam name="attributes.stock_id" default="">
    <cfparam name="attributes.count" default="0">
    <cfparam name="attributes.quantity" default="1">
    <cfparam name="attributes.amount" default="">
    <cfparam name="attributes.discount" default="0">
    <cfparam name="attributes.net_amount" default="">
    <cfparam name="attributes.unit" default="">
    <cfparam name="attributes.unit_id" default="">
    <cfparam name="attributes.start_date" default="#dateformat(now(),dateformat_style)#">
    <cfparam name="attributes.period" default="">
    <cfparam name="attributes.money_type" default="">
    <cfparam name="attributes.comp_id" default="">
    <cfparam name="attributes.cons_id" default="">
    <cfparam name="attributes.page" default=1>
    <cfparam name="attributes.row_status" default="1">   
    <cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>
    <cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
    <cfif Len(attributes.comp_id)><cfset attributes.comp_id = listSort(ListDeleteDuplicates(attributes.comp_id),"numeric","asc",",")></cfif>
    <cfif Len(attributes.cons_id)><cfset attributes.cons_id = listSort(ListDeleteDuplicates(attributes.cons_id),"numeric","asc",",")></cfif>
    <cfset GET_SUBSCRIPTION = contract_cmp.GET_SUBSCRIPTION(subscription_id : attributes.subscription_id)>
    <cfset GET_MONEY = contract_cmp.GET_MONEY()>
    <cfset GET_MONEY_MAIN = contract_cmp.GET_MONEY_MAIN()>
    <cfset GET_BASKET_AMOUNT = contract_cmp.GET_BASKET_AMOUNT()>
    <cfif GET_BASKET_AMOUNT.recordcount>
        <cfoutput query="GET_BASKET_AMOUNT">
            <cfset PRICE_ROUND_NUMBER = GET_BASKET_AMOUNT.PRICE_ROUND_NUMBER>
        </cfoutput>
    <cfelse>
        <cfset PRICE_ROUND_NUMBER = session.ep.our_company_info.sales_price_round_num>
    </cfif>
    <cfif isdefined("attributes.row_start_date") and len(attributes.row_start_date)><cf_date tarih="attributes.row_start_date"></cfif>
    <cfif isdefined("attributes.row_finish_date") and len(attributes.row_finish_date)><cf_date tarih="attributes.row_finish_date"></cfif>
    <cfif isdefined("attributes.row_amount") and len(attributes.row_amount)><cfset attributes.row_amount = filternum(attributes.row_amount)></cfif>
    <cfset GET_PAYMENT_ROWS = contract_cmp.GET_PAYMENT_ROWS(
                        subscription_id :  attributes.subscription_id, 
                        row_status : '#IIf(IsDefined("attributes.row_status") and len(attributes.row_status),"attributes.row_status", DE(""))#',
                        xml_filter_row : '#IIF(IsDefined("xml_filter_row") and len(xml_filter_row), "xml_filter_row", DE(""))#',
                        row_start_date : attributes.row_start_date,
                        row_finish_date : attributes.row_finish_date,
                        row_product_id :'#IIF(IsDefined("attributes.row_product_id") and len(attributes.row_product_id), "attributes.row_product_id", DE(""))#',
                        row_product_name :'#IIF(IsDefined("attributes.row_product_name") and len(attributes.row_product_name), "attributes.row_product_name", DE(""))#',
                        row_card_paymethod_id :'#IIF(Isdefined("attributes.row_card_paymethod_id") and len(attributes.row_card_paymethod_id), "attributes.row_card_paymethod_id", DE(""))#',
                        row_paymethod_id : '#IIF(IsDefined("attributes.row_paymethod_id") and len(attributes.row_paymethod_id), "attributes.row_paymethod_id", DE(""))#',
                        row_paymethod :'#IIF(IsDefined("attributes.row_paymethod") and len(attributes.row_paymethod), "attributes.row_paymethod", DE(""))#',
                        row_invoice_type : '#IIF(IsDefined("attributes.row_invoice_type") and len(attributes.row_invoice_type), "attributes.row_invoice_type", DE(""))#',
                        row_bill_type : '#IIF(IsDefined("attributes.row_bill_type") and len(attributes.row_bill_type), "attributes.row_bill_type", DE(""))#',
                        row_prov_type : '#IIF(IsDefined("attributes.row_prov_type") and len(attributes.row_prov_type), "attributes.row_prov_type", DE(""))#',
                        row_camp_id : '#IIF(IsDefined("attributes.row_camp_id") and len(attributes.row_camp_id), "attributes.row_camp_id", DE(""))#',
                        row_camp_name : '#IIF(IsDefined("attributes.row_camp_name") and len(attributes.row_camp_name), "attributes.row_camp_name", DE(""))#',
                        row_subs_ref_id : '#IIF(IsDefined("attributes.row_subs_ref_id") and len(attributes.row_subs_ref_id), "attributes.row_subs_ref_id", DE(""))#',
                        row_subs_ref_name : '#IIF(IsDefined("attributes.row_subs_ref_name") and len(attributes.row_subs_ref_name), "attributes.row_subs_ref_name", DE(""))#',
                        row_service_id : '#IIF(IsDefined("attributes.row_service_id") and len(attributes.row_service_id),"attributes.row_service_id", DE(""))#',
                        row_service_no : '#IIF(IsDefined("attributes.row_service_no") and len(attributes.row_service_no), "attributes.row_service_no", DE(""))#',
                        row_call_id : '#IIF(IsDefined("attributes.row_call_id") and len(attributes.row_call_id), "attributes.row_call_id", DE(""))#',
                        row_call_no : '#IIF(IsDefined("attributes.row_call_no") and len(attributes.row_call_no), "attributes.row_call_no", DE(""))#',
                        row_money_type : '#IIF(IsDefined("attributes.row_money_type") and len(attributes.row_money_type), "attributes.row_money_type", DE(""))#',
                        row_amount : '#IIF(IsDefined("attributes.row_amount") and len(attributes.row_amount), "attributes.row_amount", DE(""))#',                       
                        x_payment_plan_reference: x_payment_plan_reference,
                        x_payment_plan_service : x_payment_plan_service,
                        x_payment_plan_call : x_payment_plan_call,
                        x_payment_plan_campaign : x_payment_plan_campaign,
                        x_payment_plan_record_info : x_payment_plan_record_info,
                        xml_payment_plan_import_id :xml_payment_plan_import_id,
                        row_pay_type : '#IIF(IsDefined("attributes.row_pay_type") and len(attributes.row_pay_type), "attributes.row_pay_type", DE(""))#'
                        )>   
    <cfif xml_control_payment_rows eq 1><!--- xml den ödeme planı satırları kontrol edilsin mi seçeneği seçilmişse --->
        <cfquery name="CONTROL_PROV_ROWS" dbtype="query">
            SELECT SUBSCRIPTION_ID FROM GET_PAYMENT_ROWS WHERE IS_COLLECTED_PROVISION = 1 AND IS_PAID = 0
        </cfquery>
    </cfif>
    <cfset row = GET_PAYMENT_ROWS.recordcount>
    <cfparam name="attributes.totalrecords" default="#row#">
    <cfset endrow=attributes.startrow+attributes.maxrows-1>
    <cfif endrow gt row>
        <cfset endrow=row>
    </cfif>
    <cfset GET_PAYMENT = contract_cmp.GET_PAYMENT(subscription_id: attributes.subscription_id)>
    <cfif len(GET_SUBSCRIPTION.COMPANY_ID)>
        <cfset member_type = 0>
        <cfset member_id = GET_SUBSCRIPTION.INVOICE_COMPANY_ID>
        <cfset member_cc_id = GET_SUBSCRIPTION.MEMBER_CC_ID>
        <cfset attributes.comp_id = GET_SUBSCRIPTION.COMPANY_ID>
    <cfelse>
        <cfset member_type = 1>
        <cfset member_id = GET_SUBSCRIPTION.INVOICE_CONSUMER_ID>
        <cfset member_cc_id = GET_SUBSCRIPTION.MEMBER_CC_ID>
        <cfset attributes.cons_id = GET_SUBSCRIPTION.CONSUMER_ID>
    </cfif>
    <cfset GET_POWER_USER_INFO = contract_cmp.GET_POWER_USER_INFO()>
    <cfif len(GET_POWER_USER_INFO.POWER_USER_LEVEL_ID)>
        <cfset power_user_info = ListGetAt(GET_POWER_USER_INFO.POWER_USER_LEVEL_ID,11)><!--- satış modülü yetkisi --->
    <cfelse>
        <cfset power_user_info = "">
    </cfif>
    <cfset GET_CAMPAIGN = contract_cmp.GET_CAMPAIGN(subscription_id: attributes.subscription_id)>
    <cfif get_payment_rows.recordcount>
        <cfquery name="GET_PAYMENT_ROWS_INVOICE" dbtype="query">
            SELECT * FROM GET_PAYMENT_ROWS WHERE IS_BILLED = 0
        </cfquery>			
    </cfif>
    <cfsavecontent variable="title"> <cf_get_lang dictionary_id='41108.Ödeme Planı'> : <cfoutput>#get_subscription.subscription_no#/<cfif len(get_subscription.company_id)>#get_par_info(get_subscription.company_id,1,0,0)#<cfelse>#get_cons_info(get_subscription.consumer_id,0,0)#</cfif></cfoutput></cfsavecontent>
    <cfset pageHead = "#title#">
    <cf_catalystHeader>
    <div class="col col-12 col-md-12 col-sm-12 col-xs-12">
        <cfform name="payment_plan" method="post" action="#request.self#?fuseaction=sales.subscription_payment_plan">
            <cf_box 
            title="#getLang('','Plan Oluşturma',62269)#"
            edit_href_title='#getLang('main', 1420)#'>
            <input name="subscription_id" id="subscription_id" type="hidden" value="<cfoutput>#attributes.subscription_id#</cfoutput>">
            <input name="record_num" id="record_num" type="hidden" value="<cfoutput>#endrow#</cfoutput>">
            <input name="record" id="record" type="hidden" value="0">
            <input name="count_camp" id="count_camp" type="hidden" value="0">
            <cf_box_elements>
                <div class="col col-3 col-md-4 col-sm-6 col-xs-12">
                    <div class="form-group">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id="58859.Süreç "></label>
                        <div class="col col-8 col-xs-12">
                            <cfif GET_PAYMENT.recordcount>
                                <cf_workcube_process is_upd='0' select_value='#GET_PAYMENT.PROCESS_STAGE#' is_detail='1'>
                            <cfelse>
                                <cf_workcube_process is_upd='0' is_detail='0'>
                            </cfif>
                        </div>
                    </div>
                    <cfif x_payment_plan_campaign>
                        <div class="form-group">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57446.Kampanya'></label>
                            <div class="col col-8 col-xs-12">
                                <select name="camp_id" id="camp_id">
                                    <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                    <cfoutput query="get_campaign">
                                        <option value="#camp_id#">#camp_head#</option>
                                    </cfoutput>
                                </select>
                            </div>
                        </div>
                    </cfif>
                    <div class="form-group">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57657.Ürün'>*</label>
                        <div class="col col-8 col-xs-12">
                            <div class="input-group">
                                <cfoutput>
                                    <cfif len(GET_PAYMENT.STOCK_ID)>
                                        <cfquery name="get_tax" datasource="#dsn3#">
                                            SELECT TAX,OTV FROM STOCKS WHERE STOCK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#GET_PAYMENT.STOCK_ID#">
                                        </cfquery>
                                        <cfset tax_info = get_tax.tax>
                                        <cfset otv_info = get_tax.otv>
                                    <cfelseif len(attributes.stock_id)>
                                        <cfquery name="get_tax" datasource="#dsn3#">
                                            SELECT TAX,OTV FROM STOCKS WHERE STOCK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.stock_id#">
                                        </cfquery>
                                        <cfset tax_info = get_tax.tax>
                                        <cfset otv_info = get_tax.otv>
                                    <cfelse>
                                        <cfset tax_info = ''>
                                        <cfset otv_info = ''>
                                    </cfif>
                                    <cfif not (x_control_camp_product eq 1 and x_payment_plan_campaign eq 1)>
                                        <input type="hidden" name="product_id" id="product_id" value="<cfif len(GET_PAYMENT.PRODUCT_ID)>#GET_PAYMENT.PRODUCT_ID#<cfelse>#attributes.product_id#</cfif>">
                                        <input type="hidden" name="stock_id" id="stock_id" value="<cfif len(GET_PAYMENT.STOCK_ID)>#GET_PAYMENT.STOCK_ID#<cfelse>#attributes.stock_id#</cfif>">
                                        <input type="hidden" name="unit_id" id="unit_id" value="<cfif len(GET_PAYMENT.UNIT_ID)>#GET_PAYMENT.UNIT_ID#<cfelse>#attributes.unit_id#</cfif>">
                                        <input type="hidden" name="tax" id="tax" value="#tax_info#">
                                        <input type="hidden" name="otv" id="otv" value="#otv_info#">
                                        <input type="text" name="product_name" id="product_name" value="<cfif len(GET_PAYMENT.PRODUCT_ID)>#get_product_name(GET_PAYMENT.PRODUCT_ID)#<cfelse>#attributes.product_name#</cfif>" passthrough="readonly=yes">
                                    <cfelse>
                                        <input type="hidden" name="product_id" id="product_id" value="">
                                        <input type="hidden" name="stock_id" id="stock_id" value="">
                                        <input type="hidden" name="unit_id" id="unit_id" value="">
                                        <input type="hidden" name="tax" id="tax" value="">
                                        <input type="hidden" name="otv" id="otv" value="">
                                        <input type="text" name="product_name" id="product_name" value="" passthrough="readonly=yes">
                                    </cfif>
                                    <span class="input-group-addon btnPointer icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_product_price_unit</cfoutput>&field_stock_id=payment_plan.stock_id&field_id=payment_plan.product_id&field_name=payment_plan.product_name&field_otv=payment_plan.otv&field_tax=payment_plan.tax&field_amount=payment_plan.quantity&field_unit_id=payment_plan.unit_id&field_unit=payment_plan.unit<cfif xml_price_amount eq 1>&field_price=payment_plan.amount&field_total_price=payment_plan.net_amount</cfif>&field_money=payment_plan.money_type');"></span>
                                </cfoutput>
                            </div>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57635.Miktar'></label>
                        <div class="col col-8 col-xs-12">
                            <cfsavecontent variable="message"><cf_get_lang dictionary_id ='41303.Miktar Giriniz'></cfsavecontent>
                            <cfif len(GET_PAYMENT.QUANTITY)>
                                <cfinput type="text" name="quantity" id="quantity" class="box" onBlur="is_zero(1)" value="#GET_PAYMENT.QUANTITY#" validate="float" required="yes" message="#message#">
                            <cfelse>
                                <cfinput type="text" name="quantity" id="quantity" class="box" onBlur="is_zero(1)" value="#attributes.quantity#" validate="float" required="yes" message="#message#">
                            </cfif>	
                        </div>
                    </div>
                </div>
                <div class="col col-3 col-md-4 col-sm-6 col-xs-12">
                    <div class="form-group">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57636.Birim'></label>
                        <div class="col col-8 col-xs-12">
                            <cfoutput>
                                <cfsavecontent variable="message"><cf_get_lang dictionary_id ='41304.Birim Giriniz'></cfsavecontent>
                                <input type="text" name="unit" id="unit" value="<cfif len(GET_PAYMENT.UNIT)>#GET_PAYMENT.UNIT#<cfelse>#attributes.unit#</cfif>" required="yes" message="#message#" maxlength="10" readonly="yes">
                            </cfoutput>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57673.Tutar'>*</label>
                        <div class="col col-8 col-xs-12">
                            <cfoutput>
                                <cfsavecontent variable="message"><cf_get_lang dictionary_id='29535.Lutfen Tutar Giriniz'></cfsavecontent>
                                    <input type="text" name="amount" id="amount" class="moneybox" onblur="hesapla_main(0);AmountRnd('amount',<cfoutput>#price_round_number#</cfoutput>);" value="<cfif len(GET_PAYMENT.AMOUNT)>#TLFormat(GET_PAYMENT.AMOUNT,price_round_number)#<cfelse>#TLFormat(attributes.amount,price_round_number)#</cfif>" required="yes" message="#message#">    
                            </cfoutput>
                        </div>
                    </div>
                    <cfif x_show_net_amount>
                        <div class="form-group">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='48991.Net Tutar'></label>
                            <div class="col col-8 col-xs-12">
                                <input type="text" name="net_amount"  id="net_amount" class="moneybox" onblur="hesapla_main(1);AmountRnd('net_amount',<cfoutput>#price_round_number#</cfoutput>);" value="<cfoutput><cfif len(GET_PAYMENT.AMOUNT)>#TLFormat(GET_PAYMENT.AMOUNT,price_round_number)#<cfelse>#TLFormat(attributes.net_amount,price_round_number)#</cfif></cfoutput>" required="yes" message="#message#">
                            </div>
                        </div>
                    <cfelse>
                        <input type="hidden" name="net_amount" id="net_amount" class="moneybox" value="">
                    </cfif>
                    <cfif x_show_disc_rate>      
                        <div class="form-group">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57641.İskonto'>%</label>
                            <div class="col col-8 col-xs-12">
                                <input type="text" name="discount"  id="discount" class="moneybox" onblur="hesapla_main(2);" value="<cfoutput>#TLFormat(attributes.discount)#</cfoutput>" onkeyup="return(FormatCurrency(this,event));"> 
                            </div>                   
                        </div>
                    <cfelse>
                        <input type="hidden" name="discount" id="discount" class="moneybox" value="">
                    </cfif>
                </div>            
                <div class="col col-3 col-md-4 col-sm-6 col-xs-12">
                    <div class="form-group">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57489.Para Br'></label>
                        <div class="col col-8 col-xs-12">
                            <select name="money_type" id="money_type">
                                <cfoutput query="GET_MONEY_MAIN">
                                    <option value="#MONEY#" <cfif GET_MONEY_MAIN.MONEY eq GET_PAYMENT.MONEY_TYPE>selected</cfif>>#MONEY#</option>
                                </cfoutput>
                            </select>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='41109.Periyod'></label>
                        <div class="col col-8 col-xs-12">
                            <select name="period" id="period">
                                <option value="1" <cfif GET_PAYMENT.PERIOT eq 1>selected</cfif>><cf_get_lang dictionary_id='58932.Aylık'></option>
                                <option value="2" <cfif GET_PAYMENT.PERIOT eq 2>selected</cfif>>2 <cf_get_lang dictionary_id='58932.Aylık'></option>
                                <option value="3" <cfif GET_PAYMENT.PERIOT eq 3>selected</cfif>>3 <cf_get_lang dictionary_id='58932.Aylık'></option>
                                <option value="6" <cfif GET_PAYMENT.PERIOT eq 6>selected</cfif>>6 <cf_get_lang dictionary_id='58932.Aylık'></option>
                                <option value="12" <cfif GET_PAYMENT.PERIOT eq 12>selected</cfif>><cf_get_lang dictionary_id='29400.Yıllık'></option>
                            </select>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58516.Ödeme Yöntemi'>*</label>
                        <div class="col col-8 col-xs-12">
                            <div class="input-group">
                                <cfif len(GET_PAYMENT.PAYMETHOD_ID)>
                                    <cfquery name="GET_PAYMETHOD" datasource="#dsn#">
                                        SELECT PAYMETHOD FROM SETUP_PAYMETHOD WHERE PAYMETHOD_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#GET_PAYMENT.PAYMETHOD_ID#">
                                    </cfquery>
                                <cfelseif len(GET_PAYMENT.CARD_PAYMETHOD_ID)>
                                    <cfquery name="GET_CARD_PAYMETHOD" datasource="#dsn3#">
                                        SELECT CARD_NO FROM CREDITCARD_PAYMENT_TYPE WHERE PAYMENT_TYPE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#GET_PAYMENT.CARD_PAYMETHOD_ID#">
                                    </cfquery>
                                </cfif>
                                <cfoutput>
                                    <input type="hidden" name="card_paymethod_id" id="card_paymethod_id" value="<cfif len(GET_PAYMENT.CARD_PAYMETHOD_ID)>#GET_PAYMENT.CARD_PAYMETHOD_ID#<cfelse>#attributes.card_paymethod_id#</cfif>">
                                    <input type="hidden" name="paymethod_id" id="paymethod_id" value="<cfif len(GET_PAYMENT.PAYMETHOD_ID)>#GET_PAYMENT.PAYMETHOD_ID#<cfelse>#attributes.paymethod_id#</cfif>">
                                    <input type="text" name="paymethod" id="paymethod" value="<cfif len(GET_PAYMENT.PAYMETHOD_ID)>#GET_PAYMETHOD.PAYMETHOD#<cfelseif len(GET_PAYMENT.CARD_PAYMETHOD_ID)>#GET_CARD_PAYMETHOD.CARD_NO#<cfelse>#attributes.paymethod#</cfif>" readonly>
                                    <cfset card_link="&field_card_payment_id=payment_plan.card_paymethod_id&field_card_payment_name=payment_plan.paymethod">
                                    <span class="input-group-addon btnPointer icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_paymethods&field_id=payment_plan.paymethod_id&field_name=payment_plan.paymethod#card_link#</cfoutput>');"></span>
                                </cfoutput>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col col-3 col-md-4 col-sm-6 col-xs-12">
                    <div class="form-group">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='40963.Tekrar'>*</label>
                        <div class="col col-8 col-xs-12">
                            <cfinput type="text" name="count" id="count" validate="integer" class="moneybox" value="#attributes.count#" maxlength="3">    
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57655.Başlama'></label>
                        <div class="col col-8 col-xs-12">
                            <div class="input-group">
                                <cfsavecontent variable="message"><cf_get_lang dictionary_id ='57738.Başlangıç Tarihi Girmelisiniz'></cfsavecontent>
                                <input type="text" name="start_date" id="start_date" value="<cfoutput><cfif len(GET_PAYMENT.START_DATE)>#dateformat(GET_PAYMENT.START_DATE,dateformat_style)#<cfelse>#attributes.start_date#</cfif></cfoutput>" required="yes" message="#message#" validate="#validate_style#" readonly>
                                <span class="input-group-addon"> <cf_wrk_date_image date_field="start_date"></span>
                            </div>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col col-9 col-xs-12"><cf_get_lang dictionary_id='41110.Toplu Fatr Dah'>*</label>
                        <div class="col col-3 col-xs-12">
                            <input type="checkbox" name="top_fat_dah" id="top_fat_dah" checked onclick="select_bill_type(1);">
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col col-9 col-xs-12"><cf_get_lang dictionary_id ='41302.Grup Fatura Dah'></label>
                        <div class="col col-3 col-xs-12">
                            <input type="checkbox" name="grup_fat_dah" id="grup_fat_dah" onclick="select_bill_type(2);">
                        </div>
                    </div>
                    <cfif x_payment_plan_campaign>
                        <div class="form-group">
                            <label class="col col-9 col-xs-12"><cf_get_lang dictionary_id='41425.Kampanya Operasyon Kuralları Çalışsın'></label>
                            <div class="col col-3 col-xs-12">
                                <input type="checkbox" name="is_camp_rules" id="is_camp_rules" onclick="" value="1">
                            </div>
                        </div>
                    </cfif>
                </div>
            </cf_box_elements>
            <cf_box_footer>
                <cf_record_info query_name='GET_PAYMENT'>
                <cfsavecontent variable="message"><cf_get_lang dictionary_id ='57934.Temizle'></cfsavecontent>
                    <a href="javascript://" onclick="camp_control();" class="ui-btn ui-btn-delete"><cfoutput>#message#</cfoutput></a>
                
                <cfsavecontent variable="message"><cf_get_lang dictionary_id ='41306.Ödeme Oluştur'></cfsavecontent>
                <input type="button" name="odeme_olustur" id="odeme_olustur" value="<cfoutput>#message#</cfoutput>" onclick="kontrol();" style="float:right;">
            </cf_box_footer>
        </cf_box>
            <cfif xml_filter_row eq 1>
                <cf_box title="#getLang('','Plan Filtreleme',62271)#">
                    <cf_box_elements>
                        <cfoutput>
                            <div class="col col-3 col-md-4 col-sm-6 col-xs-12">
                                <div class="form-group">
                                    <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57657.Ürün'></label>
                                    <div class="col col-8 col-xs-12">
                                        <div class="input-group">
                                            <input type="hidden" name="row_product_id" id="row_product_id" <cfif isdefined("attributes.row_product_id") and len(attributes.row_product_id) and len(attributes.row_product_name)>value="#attributes.row_product_id#"</cfif>>
                                            <input type="text" name="row_product_name" id="row_product_name" onfocus="AutoComplete_Create('row_product_name','PRODUCT_NAME','PRODUCT_NAME','get_product','0','PRODUCT_ID','row_product_id','','2','200');" value="<cfif isdefined("attributes.row_product_id") and len(attributes.row_product_id) and len(attributes.row_product_name)>#attributes.row_product_name#</cfif>" autocomplete="off">
                                            <span class="input-group-addon btnPointer icon-ellipsis" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_product_names&product_id=payment_plan.row_product_id&field_name=payment_plan.row_product_name&keyword='+encodeURIComponent(payment_plan.row_product_name.value));"></span>
                                        </div>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58516.Ödeme Yöntemi'></label>
                                    <div class="col col-8 col-xs-12">
                                        <div class="input-group">
                                            <input type="hidden" name="row_card_paymethod_id" id="row_card_paymethod_id" value="<cfif isdefined("attributes.row_card_paymethod_id") and len(attributes.row_card_paymethod_id)>#attributes.row_card_paymethod_id#</cfif>">
                                            <input type="hidden" name="row_paymethod_id" id="row_paymethod_id" value="<cfif isdefined("attributes.row_paymethod_id") and len(attributes.row_paymethod_id)>#attributes.row_paymethod_id#</cfif>">
                                            <input type="text" name="row_paymethod" id="row_paymethod" class="text" value="<cfif isdefined("attributes.row_paymethod") and len(attributes.row_paymethod)>#attributes.row_paymethod#</cfif>">
                                            <span class="input-group-addon btnPointer icon-ellipsis" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_paymethods&field_id=payment_plan.row_paymethod_id&field_name=payment_plan.row_paymethod&field_card_payment_id=payment_plan.row_card_paymethod_id&field_card_payment_name=payment_plan.row_paymethod');"></span>                           
                                        </div>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57656.Servis'></label>
                                    <div class="col col-8 col-xs-12">
                                        <div class="input-group">
                                            <input type="hidden" name="row_service_id" id="row_service_id"  value="<cfif isdefined("attributes.row_service_id") and len(attributes.row_service_id) and len(attributes.row_service_no)>#attributes.row_service_id#</cfif>">
                                            <input type="text" name="row_service_no" id="row_service_no" class="text" value="<cfif isdefined("attributes.row_service_id") and len(attributes.row_service_id) and len(attributes.row_service_no)>#attributes.row_service_no#</cfif>" maxlength="50" autocomplete="off">
                                            <span class="input-group-addon btnPointer icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_list_service&subscription_id=#attributes.subscription_id#&field_id=payment_plan.row_service_id&field_no=payment_plan.row_service_no</cfoutput>');"></span>                           
                                        </div>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57288.Fatura Tipi'></label>
                                    <div class="col col-8 col-xs-12">
                                        <select name="row_invoice_type" id="row_invoice_type">
                                            <option value="" <cfif not isdefined('attributes.row_invoice_type') or (isdefined('attributes.row_invoice_type') and (attributes.row_invoice_type neq 1) and (attributes.row_invoice_type neq 2))> selected</cfif>><cf_get_lang dictionary_id='57288.Fatura Tipi'></option>
                                            <option value="1" <cfif isdefined("attributes.row_invoice_type") and attributes.row_invoice_type eq 1>selected</cfif>><cf_get_lang dictionary_id="57274.Toplu Fatura"></option>
                                            <option value="2" <cfif isdefined("attributes.row_invoice_type") and attributes.row_invoice_type eq 2>selected</cfif>><cf_get_lang dictionary_id='57172.Grup Fatura'></option>
                                        </select>
                                    </div>
                                </div>
                            </div>
                            <div class="col col-3 col-md-4 col-sm-6 col-xs-12">
                                <div class="form-group">
                                    <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57441.Fatura'><cf_get_lang dictionary_id='30111.Durumu'></label>
                                    <div class="col col-8 col-xs-12">
                                        <select name="row_bill_type" id="row_bill_type">
                                            <option value="" <cfif not isdefined('attributes.row_bill_type') or (isdefined('attributes.row_bill_type') and (attributes.row_bill_type neq 1) and (attributes.row_bill_type neq 2))> selected</cfif>><cf_get_lang dictionary_id='57441.Fatura'><cf_get_lang dictionary_id='30111.Durumu'></option>
                                            <option value="1" <cfif isdefined("attributes.row_bill_type") and attributes.row_bill_type eq 1>selected</cfif>><cf_get_lang dictionary_id='30878.Faturalandı'></option>
                                            <option value="2" <cfif isdefined("attributes.row_bill_type") and attributes.row_bill_type eq 2>selected</cfif>><cf_get_lang dictionary_id='39126.Faturalanmadı'></option>
                                        </select>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58053.Başlangıç Tarihi'></label>
                                    <div class="col col-8 col-xs-12">
                                        <div class="input-group">
                                            <cfsavecontent variable="message"><cf_get_lang dictionary_id ='41039.Lütfen Başlangıç Tarihi Kontrol Ediniz'>!</cfsavecontent>
                                            <cfinput type="text" name="row_start_date" id="row_start_date" value="#dateformat(attributes.row_start_date,dateformat_style)#" validate="#validate_style#" maxlength="10" message="#message#">
                                            <span class="input-group-addon"><cf_wrk_date_image date_field="row_start_date"></span>
                                        </div>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57700.Bitiş Tarihi'></label>
                                    <div class="col col-8 col-xs-12">
                                        <div class="input-group">
                                            <cfsavecontent variable="message"><cf_get_lang dictionary_id ='41040.Lütfen Bitiş Tarihi Kontrol Ediniz'>!</cfsavecontent>
                                            <cfinput type="text" name="row_finish_date" id="row_finish_date" value="#dateformat(attributes.row_finish_date, dateformat_style)#" validate="#validate_style#" maxlength="10" message="#message#">
                                            <span class="input-group-addon"><cf_wrk_date_image date_field="row_finish_date"></span>
                                        </div>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57847.Ödeme'><cf_get_lang dictionary_id='30111.Durumu'></label>
                                    <div class="col col-8 col-xs-12">
                                        <select name="row_pay_type" id="row_pay_type">
                                            <option value="" <cfif not isdefined('attributes.row_pay_type') or (isdefined('attributes.row_pay_type') and (attributes.row_pay_type neq 1) and (attributes.row_pay_type neq 2))> selected</cfif>>Ödeme Durumu</option>
                                            <option value="1" <cfif isdefined("attributes.row_pay_type") and attributes.row_pay_type eq 1>selected</cfif>><cf_get_lang dictionary_id='51353.Ödendi'></option>
                                            <option value="2" <cfif isdefined("attributes.row_pay_type") and attributes.row_pay_type eq 2>selected</cfif>><cf_get_lang dictionary_id='41226.Ödenmedi'></option>
                                        </select>
                                    </div>
                                </div>
                            </div>
                            <div class="col col-3 col-md-4 col-sm-6 col-xs-12">
                                <div class="form-group">
                                    <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57446.Kampanya'></label>
                                    <div class="col col-8 col-xs-12">
                                        <div class="input-group">
                                            <input type="hidden" name="row_camp_id" id="row_camp_id" value="<cfif isdefined("attributes.row_camp_id") and len(attributes.row_camp_id) and len(attributes.row_camp_name)>#attributes.row_camp_id#</cfif>">
                                            <input type="text" name="row_camp_name" id="row_camp_name" class="text" value="<cfif isdefined("attributes.row_camp_id") and len(attributes.row_camp_id) and len(attributes.row_camp_name)>#attributes.row_camp_name#</cfif>">
                                            <span class="input-group-addon btnPointer icon-ellipsis" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_campaigns&subscription_id=#attributes.subscription_id#&field_id=payment_plan.row_camp_id&field_name=payment_plan.row_camp_name');"></span>
                                        </div>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58784.Referans'></label>
                                    <div class="col col-8 col-xs-12">
                                        <div class="input-group">
                                            <input type="hidden" name="row_subs_ref_id" id="row_subs_ref_id" value="<cfif isdefined("attributes.row_subs_ref_id") and len(attributes.row_subs_ref_id) and len(attributes.row_subs_ref_name)>#attributes.row_subs_ref_id#</cfif>">
                                            <input type="text" name="row_subs_ref_name" id="row_subs_ref_name" class="text" value="<cfif isdefined("attributes.row_subs_ref_id") and len(attributes.row_subs_ref_id) and len(attributes.row_subs_ref_name)>#attributes.row_subs_ref_name#</cfif>" maxlength="50" onfocus="AutoComplete_Create('row_subs_ref_name','SUBSCRIPTION_NO,SUBSCRIPTION_HEAD','SUBSCRIPTION_NO,SUBSCRIPTION_HEAD','get_subscription','2','SUBSCRIPTION_ID','row_subs_ref_id','','3','150','');" autocomplete="off">
                                            <span class="input-group-addon btnPointer icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_list_subscription&field_id=payment_plan.row_subs_ref_id&field_no=payment_plan.row_subs_ref_name</cfoutput>');"></span>
                                        </div>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57438.Callcenter'></label>
                                    <div class="col col-8 col-xs-12">
                                        <div class="input-group">
                                            <input type="hidden" name="row_call_id" id="row_call_id"  value="<cfif isdefined("attributes.row_call_id") and len(attributes.row_call_id) and len(attributes.row_call_no)>#attributes.row_call_id#</cfif>">
                                            <input type="text" name="row_call_no" id="row_call_no" class="text" value="<cfif isdefined("attributes.row_call_id") and len(attributes.row_call_id) and len(attributes.row_call_no)>#attributes.row_call_no#</cfif>"  maxlength="50" autocomplete="off">
                                            <span class="input-group-addon btnPointer icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_list_service&subscription_id=#attributes.subscription_id#&field_id=payment_plan.row_call_id&field_no=payment_plan.row_call_no&is_callcenter=1</cfoutput>');"></span>
                                        </div>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='48873.Toplu Provizyon'></label>
                                    <div class="col col-8 col-xs-12">
                                        <select name="row_prov_type" id="row_prov_type">
                                            <option value="" <cfif not isdefined('attributes.row_prov_type') or (isdefined('attributes.row_prov_type') and (attributes.row_prov_type neq 1) and (attributes.row_prov_type neq 2))> selected</cfif>><cf_get_lang dictionary_id='48873.Toplu Provizyon'></option>
                                            <option value="1" <cfif isdefined("attributes.row_prov_type") and attributes.row_prov_type eq 1>selected</cfif>><cf_get_lang dictionary_id='41118.Toplu Provizyon Oluşturuldu'></option>
                                            <option value="2" <cfif isdefined("attributes.row_prov_type") and attributes.row_prov_type eq 2>selected</cfif>><cf_get_lang dictionary_id='48873.Toplu Provizyon'><cf_get_lang dictionary_id='48807.Oluşturulmadı'></option>
                                        </select>
                                    </div>
                                </div>
                            </div>
                            <div class="col col-3 col-md-4 col-sm-6 col-xs-12">
                                <div class="form-group">
                                    <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57673.Tutar'></label>
                                    <div class="col col-8 col-xs-12">
                                        <input type="text" name="row_amount" id="row_amount" class="moneybox" value="<cfif isdefined("attributes.row_amount") and len(attributes.row_amount)><cfoutput>#TLFormat(attributes.row_amount)#</cfoutput></cfif>" onkeyup="return(FormatCurrency(this,event));"> 
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57489.Para Br'></label>
                                    <div class="col col-8 col-xs-12">
                                        <select name="row_money_type" id="row_money_type">
                                            <option value=""><cf_get_lang dictionary_id='57489.Para Br'></option>
                                            <cfloop query="get_money_main">
                                                <option value="#money#" <cfif isdefined('attributes.row_money_type') and money eq attributes.row_money_type>selected</cfif>>#money#</option>
                                            </cfloop>
                                        </select>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57493.Aktif'>/<cf_get_lang dictionary_id='57494.Pasif'></label>
                                    <div class="col col-8 col-xs-12">
                                        <select name="row_status" id="row_status">
                                            <option value="" <cfif isdefined('attributes.row_status') and (attributes.row_status neq 0) and (attributes.row_status neq 1)> selected</cfif>><cf_get_lang dictionary_id='57493.Aktif'>/<cf_get_lang dictionary_id='57494.Pasif'></option>
                                            <option value="1"<cfif isdefined('attributes.row_status') and (attributes.row_status eq 1)> selected</cfif>><cf_get_lang dictionary_id='57493.Aktif'></option>
                                            <option value="0"<cfif isdefined('attributes.row_status') and (attributes.row_status eq 0)> selected</cfif>><cf_get_lang dictionary_id='57494.Pasif'></option>
                                        </select>
                                    </div>
                                </div>
                            </div>
                        </cfoutput>
                    </cf_box_elements>
                    <cf_box_footer>
                        <!--- <cf_basket_form_button><cf_workcube_buttons is_upd='0' is_cancel="0" insert_info="Filtrele" insert_alert="" add_function='year_diff()'></cf_basket_form_button> --->
                            <cfsavecontent variable="message"><cf_get_lang dictionary_id='57537.Sayi_Hatasi_Mesaj'></cfsavecontent>
                                <cfinput type="text" name="maxrows" value="#attributes.maxrows#" required="yes" validate="integer" range="1,999" message="#message#" onKeyUp="isNumber(this)" maxlength="3" style="width:25px;">   
                            <input type="submit" name="filter" id="filter" value="<cf_get_lang dictionary_id='62273.Filtrele'>" onclick="year_diff()">
                    </cf_box_footer>
                </cf_box>
            </cfif>

        </cfform>
        <cf_box title="#getLang('','Plan Satırları',62270)#"
        bill_href="#isdefined("get_payment_rows_invoice.recordcount") and len(get_payment_rows_invoice.recordcount) ? "javascript:fatura_kes()" : ""#" 
        >
            <cfform name="show_pay_plan" action="#request.self#?fuseaction=sales.emptypopup_add_subscription_payment_plan" method="post">
                <input type="hidden" name="list_payment_row_id" id="list_payment_row_id" value=""><!--- fatura kesilecek payment_idler burada --->
                <input type="hidden" name="is_submitted" id="is_submitted" value="1" />
                <input type="hidden" name="xml_change_row" id="xml_change_row" value="<cfoutput>#xml_change_row#</cfoutput>" />
                <input name="count" id="count" type="hidden" value="<cfoutput>#attributes.count#</cfoutput>">
                <input name="subscription_id" id="subscription_id" type="hidden" value="<cfoutput>#attributes.subscription_id#</cfoutput>">
                <input name="record_num" id="record_num" type="hidden" value="<cfoutput>#endrow#</cfoutput>">
                <input name="record" id="record" type="hidden" value="0">
                <input name="unit" id="unit" type="hidden" value="">
                <input name="amount" id="amount" type="hidden" value="">
                <input name="quantity" id="quantity" type="hidden" value="">
                <input name="start_date" id="start_date" type="hidden" value="">
                <input name="product_id" id="product_id" type="hidden" value="">
                <input name="stock_id" id="stock_id" type="hidden" value="">
                <input name="unit_id" id="unit_id" type="hidden" value="">
                <input name="money_type" id="money_type" type="hidden" value="">
                <input name="period" id="period" type="hidden" value="">
                <input name="card_paymethod_id" id="card_paymethod_id" type="hidden" value="">
                <input name="paymethod_id" id="paymethod_id" type="hidden" value="">
                <input name="process_stage" id="process_stage" type="hidden" value="">
                <input name="count_camp" id="count_camp" type="hidden" value="0">
                    <cf_grid_list id="table_1">
                        <thead>
                            <tr>
                                <cfif xml_change_row eq 1>
                                    <th><cf_get_lang dictionary_id='58693.Seç'></th>
                                <cfelse>
                                    <th></th>
                                </cfif>
                                <th width="20" class="text-center"><i class="fa fa-credit-card" title="<cf_get_lang dictionary_id='42352.Sanal POS'>"></i></th>
                                <th width="20" class="text-center"><i class="fa fa-minus"></i></th>
                                <th><cf_get_lang dictionary_id='57493.Aktif'></th>
                                <th style="min-width:100px"><cf_get_lang dictionary_id='57742.Tarih'></th>
                                <cfif xml_payment_finish_date eq 1>
                                    <th ><cf_get_lang dictionary_id='57700.Bitis Tarihi'></th>
                                </cfif>
                                <th style="min-width:100px"><cf_get_lang dictionary_id='57657.Urun'></th>
                                <th style="min-width:100px"><cf_get_lang dictionary_id='58516.Ödeme Yöntemi'></th>
                                <th><cf_get_lang dictionary_id='57636.Birim'></th>
                                <cfif x_payment_plan_kdv>
                                    <th><cf_get_lang dictionary_id='57639.KDV'></th>
                                </cfif>
                                <cfif x_payment_plan_otv>
                                    <th><cf_get_lang dictionary_id='58021.ÖTV'></th>
                                </cfif>
                                <th><cf_get_lang dictionary_id='57635.Miktar'></th>
                                <th><cf_get_lang dictionary_id='57673.Tutar'></th>
                                <th><cf_get_lang dictionary_id='57489.Para Br'></th>
                                <th><cf_get_lang dictionary_id='50923.Seç'> <cf_get_lang dictionary_id='58456'></th>
                                <th style="display:none;"><cf_get_lang dictionary_id='50923.Seç'> <cf_get_lang dictionary_id='57673'></th>
                                <!--- <th style="width:50px">BSMV <cf_get_lang dictionary_id='57677'></th> --->
                                <th>OIV <cf_get_lang dictionary_id='58456'></th>
                                <th style="display:none;">OIV <cf_get_lang dictionary_id='57673'></th>
                                    <cfif xml_tevkifat_rate>
                                <th><cf_get_lang dictionary_id='57391'></th>
                                <th style="display:none;"><cf_get_lang dictionary_id='58022'> <cf_get_lang dictionary_id='57673'></th>
                                </cfif>
                                <cfif xml_payment_rate>
                                    <th><cf_get_lang dictionary_id='57648.Kur'></th>
                                </cfif>
                                <th><cf_get_lang dictionary_id='41113.Satır Toplamı'></th>
                                <cfif x_payment_plan_isk_amount>
                                    <th><cf_get_lang dictionary_id='57641.İSK'> <cf_get_lang dictionary_id='57673.tutar'></th>
                                </cfif>
                                <th><cf_get_lang dictionary_id='57641.İSK'>(%)</th>
                                <th style="min-width:100px"><cf_get_lang dictionary_id='41114.Net Satır Top'></th>
                                <cfif x_payment_plan_kdv_amount>
                                    <th><cf_get_lang dictionary_id='58716.KDVli'> <cf_get_lang dictionary_id='41114.Net Satır Top'></th>
                                </cfif>
                                <th><cf_get_lang dictionary_id='41110.Toplu Fatr Dah'></th>
                                <th><cf_get_lang dictionary_id ='41302.Grup Fatura Dah'></th>
                                <th><cf_get_lang dictionary_id='41115.Faturalandı'></th>
                                <th><cf_get_lang dictionary_id='41116.Fatura ID'></th>
                                <th><cf_get_lang dictionary_id='48873.Toplu Provizyon'></th>
                                <th><cf_get_lang dictionary_id='45459.Ödeme Durumu'></th>
                                <cfif x_payment_plan_revenue_info>
                                    <th><cf_get_lang dictionary_id='57845.Tahsilat'> <cf_get_lang dictionary_id='58527.ID'></th>
                                </cfif>
                                <cfif x_payment_plan_campaign>
                                    <th><cf_get_lang dictionary_id='57446.Kampanya'></th>
                                </cfif>
                                <cfif x_payment_plan_reference>
                                    <th><cf_get_lang dictionary_id='58784.Referans'></th>
                                </cfif>
                                <cfif x_payment_plan_service>
                                    <th><cf_get_lang dictionary_id="30039.Servis Başvuruları"></th>
                                </cfif>
                                <cfif x_payment_plan_call>
                                    <th><cf_get_lang dictionary_id='57438.Callcenter'></th>
                                </cfif>
                                <cfif xml_payment_plan_import_id>
                                    <th><cf_get_lang dictionary_id='52718.Import'> <cf_get_lang dictionary_id='58527.ID'></th>
                                </cfif>
                                <th><cf_get_lang dictionary_id='63976.Sayaç'></th>
                                <th><cf_get_lang dictionary_id='57574.Şirket'></th>
                                <cfif x_payment_plan_record_info>
                                    <th><cf_get_lang dictionary_id='57483.Kayıt'></th>
                                    <th><cf_get_lang dictionary_id='57891.Güncelleyen'></th>
                                </cfif>
                                
                            </tr>
                        </thead>
                        <tbody>
                            <cfif xml_change_row eq 1>
                                <tr class="headerColm">
                                    <td class="text-center"><cfif get_payment_rows.recordcount><input type="checkbox" name="is_change_main" id="is_change_main" checked onclick="wrk_select_change();"></cfif></td>
                                    <td></td>
                                    <td class="text-center"><cfif (not listfindnocase(denied_pages,"sales.emptypopup_del_subs_pay_plan_row"))><a href="javascript://" onclick="camp_control_row('','',1);"><img src="/images/delete_list.gif" border="0"></a></cfif></td>

                                    <td class="text-center">
                                        <input type="checkbox" name="main_status" id="main_status" onclick="apply_row(1);">
                                    </td>
                                    <td width="100" nowrap="nowrap">
                                        <div class="form-group"><div class="input-group"><cfsavecontent variable="message_main"><cf_get_lang dictionary_id ='41039.Lütfen Başlangıç Tarihi Kontrol Ediniz'>!</cfsavecontent>
                                        <cfinput type="text" readonly name="main_start_date" value="" validate="#validate_style#" maxlength="10" message="#message_main#" onBlur="apply_row(2);">
                                        <span class="input-group-addon"><cf_wrk_date_image date_field="main_start_date" call_function="apply_row" call_parameter="2"></span></div></div>
                                    </td>
                                    <cfif xml_payment_finish_date eq 1>
                                        <td width="100" nowrap="nowrap">
                                            <div class="form-group"><div class="input-group"><cfinput type="text" readonly name="main_finish_date" value="" validate="#validate_style#" maxlength="10" onBlur="apply_row(17);">
                                            <span class="input-group-addon"><cf_wrk_date_image date_field="main_finish_date" call_function="apply_row" call_parameter="17"></span></div></div>
                                        </td>
                                    </cfif>
                                    <td width="200" nowrap="nowrap">
                                        <input type="hidden" name="main_stock_id" id="main_stock_id" >
                                        <input type="hidden" name="main_unit" id="main_unit" >
                                        <input type="hidden" name="main_unit_id" id="main_unit_id" >
                                        <input type="hidden" name="main_product_id" id="main_product_id" >
                                        <div class="form-group">
                                            <div class="input-group">
                                                <input name="main_product_name" type="text" id="main_product_name" autocomplete="off">
                                                <span class="input-group-addon icon-ellipsis" href="javascript://" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_product_names&field_id=show_pay_plan.main_stock_id&field_unit_name=show_pay_plan.main_unit&field_main_unit=show_pay_plan.main_unit_id&run_function=apply_row&run_function_param=3&product_id=show_pay_plan.main_product_id&field_name=show_pay_plan.main_product_name');"></span>
                                            </div>
                                        </div>
                                    </td>
                                    <td width="100" nowrap="nowrap">
                                        <input type="hidden" name="main_card_paymethod_id" id="main_card_paymethod_id">
                                        <input type="hidden" name="main_paymethod_id" id="main_paymethod_id">
                                        <div class="form-group">
                                            <div class="input-group">
                                                <input type="text" name="main_paymethod" id="main_paymethod" class="text">
                                                <span class="input-group-addon icon-ellipsis" href="javascript://" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_paymethods&field_id=show_pay_plan.main_paymethod_id&field_name=show_pay_plan.main_paymethod&field_card_payment_id=show_pay_plan.main_card_paymethod_id&FUNCTION_NAME=apply_row&function_parameter=4&field_card_payment_name=show_pay_plan.main_paymethod');"></span>
                                            </div>
                                        </div>
                                    </td>
                                    <td></td>
                                    <cfif x_payment_plan_kdv>
                                        <td></td>
                                    </cfif>
                                    <cfif x_payment_plan_otv>
                                        <td></td>
                                    </cfif>
                                    <td>
                                        <div class="form-group">
                                            <input type="text" name="main_quantity" id="main_quantity" class="moneybox" onblur="apply_row(5);" onkeyup="return(FormatCurrency(this,event));"> 
                                        </div>
                                    </td>
                                    <td>
                                        <div class="form-group" style="width:150px;">
                                            <div class="col col-6">
                                                <select name="main_amount_type" id="main_amount_type">
                                                    <option value=""><cf_get_lang dictionary_id='57630.Tip'></option>
                                                    <option value="3"><cf_get_lang dictionary_id='47334.Değiştir'></option>
                                                    <option value="2"><cf_get_lang dictionary_id='57582.Ekle'></option>
                                                    <option value="1"><cf_get_lang dictionary_id='49798.Çıkar'></option>
                                                </select>
                                            </div>
                                            <div class="col col-6">
                                                <input type="text" name="main_amount" id="main_amount" class="moneybox" onkeyup="return(FormatCurrency(this,event));" onblur="apply_row(6);">
                                            </div>
                                        </div>
                                    </td>
                                    <td>
                                        <div class="form-group" style="width:100px;">
                                            <select name="main_money_type" id="main_money_type" onchange="apply_row(7);">
                                                <option value=""><cf_get_lang dictionary_id='57489.Para Br'></option>
                                                <cfoutput query="get_money_main">
                                                    <option value="#money#">#money#</option>
                                                </cfoutput>
                                            </select>
                                        </div>
                                    </td>
                                    <td><div class="form-group"><input type="text" name="main_bsmv_rate" id="main_bsmv_rate" class="moneybox" onkeyup="return(FormatCurrency(this,event));" onblur="apply_row(21);"></div></td>
                                    <td style="display:none;"><div class="form-group"><input type="text" name="main_bsmv_amount" id="main_bsmv_amount" class="moneybox" onkeyup="return(FormatCurrency(this,event));" onblur="apply_row(22);"></div></td>
                                    <td><div class="form-group"><input type="text" name="main_bsmv_currency" id="main_bsmv_currency" class="moneybox" onkeyup="return(FormatCurrency(this,event));" onblur="apply_row(23);"></div></td>
                                    <td style="display:none;"><div class="form-group"><input type="text" name="main_oiv_rate" id="main_oiv_rate" class="moneybox" onkeyup="return(FormatCurrency(this,event));" onblur="apply_row(24);"></div></td>
                                    <td><div class="form-group"><input type="text" name="main_oiv_amount" id="main_oiv_amount" class="moneybox" onkeyup="return(FormatCurrency(this,event));" onblur="apply_row(25);"></div></td>
                                    <cfif xml_tevkifat_rate>
                                        <td style="display:none;">
                                            <div class="form-group">
                                                <input type="text" name="main_tevkifat_rate" id="main_tevkifat_rate" class="moneybox" onkeyup="return(FormatCurrency(this,event));" onblur="apply_row(26);">
                                            </div>
                                        </td>
                                        <td>
                                            <div class="form-group">
                                                <input type="text" name="main_tevkifat_amount" id="main_tevkifat_amount" class="moneybox" onkeyup="return(FormatCurrency(this,event));" onblur="apply_row(27);">
                                            </div>
                                        </td>
                                    </cfif>
                                    <cfif xml_payment_rate>
                                        <td><div class="form-group"><input type="text" name="main_rate" id="main_rate" class="moneybox" onblur="apply_row(18);" onkeyup="return(FormatCurrency(this,event,4));"></div></td>
                                    </cfif>
                                    <td></td>
                                    <cfif x_payment_plan_isk_amount>
                                        <td><div class="form-group"><input type="text" name="main_discount_amount" id="main_discount_amount" class="moneybox" onblur="apply_row(9);" onkeyup="return(FormatCurrency(this,event));"></div></td>
                                    </cfif>
                                    <td>
                                        <div class="form-group"><input type="text" name="main_discount" id="main_discount" class="moneybox" onblur="apply_row(8);" onkeyup="return(FormatCurrency(this,event));"></div> 
                                    </td>
                                    <cfif x_payment_plan_kdv_amount>
                                        <td></td>
                                    </cfif>
                                    <td class="text-center">
                                        <div class="form-group"><input type="checkbox" name="main_is_collected_inv" id="main_is_collected_inv" onclick="apply_row(10);"></div>
                                    </td>
                                    <td class="text-center"><div class="form-group"><input type="checkbox" name="main_is_group_inv" id="main_is_group_inv" onclick="apply_row(11);"></div></td>
                                    <td></td>
                                    <td></td>
                                    <td class="text-center"><div class="form-group"><input type="checkbox" name="main_is_collected_prov" id="main_is_collected_prov" onclick="apply_row(12);"></div></td>
                                    <td class="text-center"><div class="form-group"><input type="checkbox" name="main_is_paid" id="main_is_paid" onclick="<cfif power_user_info neq 1>cari_kontrol(this,0);<cfelse>apply_row(20);</cfif>"></div></td>
                                    <cfif x_payment_plan_revenue_info>
                                        <td>
                                            <div class="form-group">
                                                <div class="input-group">
                                                    <input type="hidden" name="main_cari_act_type" id="main_cari_act_type" value="">
                                                    <input type="hidden" name="main_cari_act_table" id="main_cari_act_table" value="">
                                                    <input type="hidden" name="main_cari_act_id" id="main_cari_act_id" value="">
                                                    <input type="hidden" name="main_cari_period_id" id="main_cari_period_id" value="">
                                                    <input type="text" name="main_cari_action_id" id="main_cari_action_id" value="" readonly="yes">
                                                    <cfif len(get_subscription.company_id)>
                                                        <span class="input-group-addon icon-ellipsis" href="javascript://" onclick="javascript:windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_list_cari_actions&field_id=show_pay_plan.main_cari_action_id&field_act_id=show_pay_plan.main_cari_act_id&field_act_type=show_pay_plan.main_cari_act_type&field_period_id=show_pay_plan.main_cari_period_id&field_act_table=show_pay_plan.main_cari_act_table&comp_id=#attributes.comp_id#&call_function=apply_row&call_function_param=19</cfoutput>','list');"></span>
                                                    <cfelse>
                                                        <span class="input-group-addon icon-ellipsis" href="javascript://" onclick="javascript:windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_list_cari_actions&field_id=show_pay_plan.main_cari_action_id&field_act_id=show_pay_plan.main_cari_act_id&field_act_type=show_pay_plan.main_cari_act_type&field_period_id=show_pay_plan.main_cari_period_id&field_act_table=show_pay_plan.main_cari_act_table&cons_id=#attributes.cons_id#&call_function=apply_row&call_function_param=19</cfoutput>','list');"></span>
                                                    </cfif>
                                                </div>
                                            </div>
                                        </td>
                                    </cfif>
                                    <cfif x_payment_plan_campaign>
                                        <td>
                                            <div class="form-group">
                                                <div class="input-group">
                                                    <input type="hidden" name="main_camp_id" id="main_camp_id">
                                                    <input type="text" name="main_camp_name" id="main_camp_name">
                                                    <span class="input-group-addon icon-ellipsis" href="javascript://" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_list_campaigns&subscription_id=#attributes.subscription_id#&field_id=show_pay_plan.main_camp_id&field_name=show_pay_plan.main_camp_name&call_function=apply_row&call_function_param=13</cfoutput>');"></span>
                                                </div>
                                            </div>
                                        </td>
                                    </cfif>
                                    <cfif x_payment_plan_reference>
                                        <td>
                                            <div class="form-group">
                                                <div class="input-group">
                                                    <input type="hidden" name="main_subs_ref_id" id="main_subs_ref_id">
                                                    <input type="text" name="main_subs_ref_name" id="main_subs_ref_name" class="text">
                                                    <span class="input-group-addon icon-ellipsis" href="javascript://" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_list_subscription&field_id=show_pay_plan.main_subs_ref_id&field_no=show_pay_plan.main_subs_ref_name&call_function=apply_row&call_function_param=14</cfoutput>');"></span>
                                                </div>
                                            </div>
                                        </td>
                                    </cfif>
                                    <cfif x_payment_plan_service>
                                        <td>
                                            <div class="form-group">
                                                <div class="input-group">
                                                    <input type="hidden" name="main_service_id" id="main_service_id">
                                                    <input type="text" name="main_service_no" id="main_service_no" class="text" autocomplete="off">
                                                    <span class="input-group-addon icon-ellipsis" href="javascript://" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_list_service&subscription_id=#attributes.subscription_id#&field_id=show_pay_plan.main_service_id&field_no=show_pay_plan.main_service_no&call_function=apply_row&call_function_param=15</cfoutput>');"></span>
                                                </div>
                                            </div>
                                        </td>
                                    </cfif>
                                    <cfif x_payment_plan_call>
                                        <td>
                                            <div class="form-group">
                                                <div class="input-group">
                                                    <input type="hidden" name="main_call_id" id="main_call_id">
                                                    <input type="text" name="main_call_no" id="main_call_no" class="text" autocomplete="off">
                                                    <span class="input-group-addon icon-ellipsis" href="javascript://" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_list_service&subscription_id=#attributes.subscription_id#&field_id=show_pay_plan.main_call_id&field_no=show_pay_plan.main_call_no&is_callcenter=1&call_function=apply_row&call_function_param=16</cfoutput>');"></span>
                                                </div>
                                            </div>
                                        </td>
                                    </cfif>
                                    <cfif xml_payment_plan_import_id>
                                        <td></td>
                                    </cfif>
                                    <cfif x_payment_plan_record_info>
                                        <td></td>
                                        <td></td>
                                    </cfif>
                                </tr>
                            </cfif>
                            <cfif get_payment_rows.recordcount>
                                <input name="endrow" id="endrow" type="hidden" value="<cfoutput>#endrow#</cfoutput>">
                                <input name="startrow" id="startrow" type="hidden" value="<cfoutput>#attributes.startrow#</cfoutput>">
                                <cfloop from="#attributes.startrow#" to="#endrow#" index="i">   
                                <cfif GET_PAYMENT_ROWS.IS_PAID[i] eq 1 and (session.ep.admin neq 1 and power_user_info neq 1)> 
                                <cfoutput>
                                <tr>
                                    <td></td>
                                    <td align="center">
                                        <cfif len(GET_PAYMENT_ROWS.INVOICE_ID[i]) and GET_PAYMENT_ROWS.IS_PAID[i] eq 0 and GET_PAYMENT_ROWS.IS_COLLECTED_PROVISION[i] eq 0 and len(GET_PAYMENT_ROWS.CARD_PAYMETHOD_ID[i])>
                                            <cfset donem_db = "#dsn#_#GET_PAYMENT_ROWS.period_year[i]#_#session.ep.company_id#">
                                            <cfquery name="getInvoiceNettotal" datasource="#donem_db#">
                                                SELECT NETTOTAL FROM INVOICE WHERE INVOICE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#GET_PAYMENT_ROWS.INVOICE_ID[i]#">
                                            </cfquery>							
                                            <a href="javascript://" onclick="windowopen('#request.self#?fuseaction=bank.popup_add_online_pos&member_type=#MEMBER_TYPE#&member_id=#MEMBER_ID#&card_id_info=#MEMBER_CC_ID#&action_value=#getInvoiceNettotal.NETTOTAL#&invoice_id=#GET_PAYMENT_ROWS.INVOICE_ID[i]#&period_id=#GET_PAYMENT_ROWS.PERIOD_ID[i]#&paym_id=#GET_PAYMENT_ROWS.CARD_PAYMETHOD_ID[i]#','medium');"><img src="/images/pos_credit_sanal.gif" title="Sanal POS" border="0"></a>
                                        </cfif>
                                        
                                        <cfif len(GET_PAYMENT_ROWS.INVOICE_ID[i])>
                                            <a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_detail_invoice&id=#GET_PAYMENT_ROWS.INVOICE_ID[i]#&period_id=#GET_PAYMENT_ROWS.PERIOD_ID[i]#</cfoutput>','page');" class="tableyazi"><img src="/images/ship_list.gif" border="0" align="absmiddle"></a><cfif len(GET_PAYMENT_ROWS.IS_INVOICE_IPTAL[i])><font color="red" size="+1"><b>*</b></font></cfif>
                                        </cfif>
                                    </td>
                                    <td class="text-center" title="<cf_get_lang dictionary_id='57493.Aktif'>"><div class="form-group"><input type="checkbox" name="is_aktive#i#" id="is_aktive#i#" <cfif GET_PAYMENT_ROWS.IS_ACTIVE[i] eq 1>checked</cfif> disabled></div></td>
                                    <td nowrap title="<cf_get_lang dictionary_id='57742.Tarih'>">
                                        <div class="form-group">
                                            <div class="input-group">
                                                <input type="hidden" name="is_disabled_#i#" id="is_disabled_#i#" value="2">
                                                <input type="hidden" name="payment_row_id#i#" id="payment_row_id#i#" value="#GET_PAYMENT_ROWS.SUBSCRIPTION_PAYMENT_ROW_ID[i]#">
                                                <input type="text" name="payment_date#i#" id="payment_date#i#" class="boxtext" value="#DateFormat(GET_PAYMENT_ROWS.PAYMENT_DATE[i],dateformat_style)#" validate="#validate_style#" maxlength="10" disabled readonly>
                                                <span class="input-group-addon"><cf_wrk_date_image date_field="payment_date#i#"></div>
                                            </div>
                                        </div>
                                    </td>
                                    <cfif xml_payment_finish_date eq 1>
                                        <td nowrap="nowrap">
                                            <div class="form-group">
                                                <div class="input-group">
                                                    <cfinput type="text" name="payment_finish_date#i#" class="boxtext" id="payment_finish_date" value="#DateFormat(GET_PAYMENT_ROWS.PAYMENT_FINISH_DATE[i],dateformat_style)#" validate="#validate_style#" maxlength="10">
                                                    <span class="input-group-addon"><cf_wrk_date_image date_field="payment_finish_date#i#"></div>
                                                </div>
                                            </div>
                                        </td>
                                    </cfif>
                                        <input type="hidden" name="product_id#i#" id="product_id#i#" value="#GET_PAYMENT_ROWS.PRODUCT_ID[i]#">
                                        <input type="hidden" name="stock_id#i#" id="stock_id#i#" value="#GET_PAYMENT_ROWS.STOCK_ID[i]#">
                                        <input type="hidden" name="unit_id#i#" id="unit_id#i#" value="#GET_PAYMENT_ROWS.UNIT_ID[i]#">
                                    <td width="200" nowrap title="<cf_get_lang dictionary_id='57657.Urun'>">
                                        <div class="form-group">
                                            <div class="input-group">
                                                <input type="text" name="detail#i#" id="detail#i#" class="boxtext" value="#GET_PAYMENT_ROWS.DETAIL[i]#" maxlength="50" disabled>
                                                <span class="input-group-addon icon-ellipsis" href="javascript://" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_product_names&product_id=show_pay_plan.product_id#i#&field_id=show_pay_plan.stock_id#i#&field_unit_name=show_pay_plan.unit#i#&field_main_unit=show_pay_plan.unit_id#i#&field_name=show_pay_plan.detail#i#</cfoutput>');"></span>
                                                <span class="input-group-addon icon-ellipsis" href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_detail_product&pid=#GET_PAYMENT_ROWS.PRODUCT_ID[i]#</cfoutput>','medium');"></span>
                                            </div>
                                        </div>
                                    </td>
                                    <td nowrap title="<cf_get_lang dictionary_id='58516.Ödeme Yöntemi'>">
                                        <div class="form-group">
                                            <div class="input-group">
                                                <input type="hidden" name="card_paymethod_id#i#" id="card_paymethod_id#i#" value="#GET_PAYMENT_ROWS.CARD_PAYMETHOD_ID[i]#">
                                                <input type="hidden" name="paymethod_id#i#" id="paymethod_id#i#" value="#GET_PAYMENT_ROWS.PAYMETHOD_ID[i]#">
                                                <input type="text" name="paymethod#i#" id="paymethod#i#" class="boxtext" value="<cfif len(GET_PAYMENT_ROWS.PAYMETHOD[i])>#GET_PAYMENT_ROWS.PAYMETHOD[i]#<cfelseif len(GET_PAYMENT_ROWS.CARD_PAYMETHOD_ID[i])>#GET_PAYMENT_ROWS.CARD_NO[i]#</cfif>" readonly="yes" maxlength="50" disabled>
                                                <span class="input-group-addon icon-ellipsis" href="javascript://" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_paymethods&field_id=show_pay_plan.paymethod_id#i#&field_name=show_pay_plan.paymethod#i#&field_card_payment_id=show_pay_plan.card_paymethod_id#i#&field_card_payment_name=show_pay_plan.paymethod#i#</cfoutput>');"></span>
                                            </div>
                                        </div>
                                    </td>
                                    <td title="<cf_get_lang dictionary_id='57636.Birim'>"><div class="form-group"><input type="text" name="unit#i#" id="unit#i#" maxlength="10" value="#GET_PAYMENT_ROWS.UNIT[i]#" readonly="yes" disabled></div></td>
                                    <cfif x_payment_plan_kdv>
                                        <td title="<cf_get_lang dictionary_id='57639.KDV'>"><div class="form-group"><input type="text" name="kdv_rate#i#" id="kdv_rate#i#" class="moneybox" maxlength="10" value="#get_payment_rows.tax[i]#" readonly="yes"></div></td>
                                    <cfelse>
                                        <input type="hidden" name="kdv_rate#i#" id="kdv_rate#i#" maxlength="10" value="#get_payment_rows.tax[i]#" readonly="yes">
                                    </cfif>
                                    <cfif x_payment_plan_otv>
                                        <td title="<cf_get_lang dictionary_id='58021.ÖTV'>"><div class="form-group"><input type="text" name="otv_rate#i#" id="otv_rate#i#" class="moneybox" maxlength="10" value="#get_payment_rows.otv[i]#" readonly="yes" disabled></div></td>
                                    <cfelse>
                                        <input type="hidden" name="otv_rate#i#" id="otv_rate#i#" maxlength="10" value="#get_payment_rows.otv[i]#" readonly="yes" disabled>
                                    </cfif>
                                    <td title="<cf_get_lang dictionary_id='57635.Miktar'>"><div class="form-group"><cfinput type="text" name="quantity#i#" class="box" value="#GET_PAYMENT_ROWS.QUANTITY[i]#" onChange="is_zero(#i#)" onBlur="return hesapla(#i#);" disabled></div></td>
                                    <td title="<cf_get_lang dictionary_id='57673.Tutar'>"><div class="form-group"><input type="text" name="amount#i#" id="amount#i#" class="moneybox" value="#TLFormat(GET_PAYMENT_ROWS.AMOUNT[i],price_round_number)#" onblur="hesapla(#i#);AmountRnd('amount#i#',<cfoutput>#price_round_number#</cfoutput>);" disabled></div></td>
                                    <td title="<cf_get_lang dictionary_id='57489.Para Br'>">		
                                        <div class="form-group">			
                                            <select name="money_type_row#i#" id="money_type_row#i#" class="boxtext" disabled>
                                                <cfloop query="GET_MONEY">
                                                    <option value="#MONEY#" <cfif GET_MONEY.MONEY eq GET_PAYMENT_ROWS.MONEY_TYPE[i]>selected</cfif>>#MONEY#</option>
                                                </cfloop>
                                            </select>
                                        </div>
                                    </td>
                                    <cfif xml_payment_rate>
                                        <td title="<cf_get_lang dictionary_id='57648.Kur'>"><div class="form-group"><input type="text" name="row_rate#i#" id="row_rate#i#" class="moneybox" onkeyup="return(FormatCurrency(this,event,4));"></div></td>
                                    </cfif>
                                    <td title="<cf_get_lang dictionary_id='41113.Satır Toplamı'>"><div class="form-group"><input type="text" name="row_total#i#" id="row_total#i#" class="moneybox" value="#TLFormat(GET_PAYMENT_ROWS.ROW_TOTAL[i],price_round_number)#" onblur="AmountRnd('row_total#i#',<cfoutput>#price_round_number#</cfoutput>);" onkeyup="return(FormatCurrency(this,event));" disabled readonly="yes"></div></td>
                                    <cfif x_payment_plan_isk_amount>
                                        <td title="<cf_get_lang dictionary_id='57641.İSK'> <cf_get_lang dictionary_id='57673.Tutar'>"><div class="form-group"><input type="text" name="discount_amount#i#" id="discount_amount#i#" class="moneybox" value="#TLFormat(GET_PAYMENT_ROWS.DISCOUNT_AMOUNT[i])#" validate="float" onblur="return indirim_hesapla(#i#);" onkeyup="return(FormatCurrency(this,event));" disabled readonly="yes"></div></td>
                                    <cfelse>
                                        <input type="hidden" name="discount_amount#i#" id="discount_amount#i#" class="moneybox" value="#TLFormat(GET_PAYMENT_ROWS.DISCOUNT_AMOUNT[i])#" validate="float" onblur="return indirim_hesapla(#i#);" onkeyup="return(FormatCurrency(this,event));" disabled readonly="yes">
                                    </cfif>
                                    <td title="<cf_get_lang dictionary_id='57641.İSK'>(%)"><div class="form-group"><input type="text" name="discount#i#" id="discount#i#" class="moneybox" value="#TLFormat(GET_PAYMENT_ROWS.DISCOUNT[i])#" validate="integer" maxlength="3" onblur="return indirim_hesapla(#i#);" onkeyup="return(FormatCurrency(this,event));" disabled readonly="yes"></div></td>
                                    <td title="<cf_get_lang dictionary_id='41114.Net Satır Top'>"><div class="form-group"><input type="text" name="row_net_total#i#" id="row_net_total#i#" class="moneybox" disabled value="#TLFormat(GET_PAYMENT_ROWS.ROW_NET_TOTAL[i],session.ep.our_company_info.rate_round_num)#" onblur="return discount_hesapla(#i#);" onkeyup="return(FormatCurrency(this,event));" readonly="yes"></div></td>
                                    <cfif x_payment_plan_kdv_amount>
                                        <cfset nettotal_kdv = GET_PAYMENT_ROWS.ROW_NET_TOTAL[i]*GET_PAYMENT_ROWS.TAX[i]/100>
                                        <cfset nettotal_otv = GET_PAYMENT_ROWS.ROW_NET_TOTAL[i]*GET_PAYMENT_ROWS.OTV[i]/100>
                                        <td title="KDV'li <cf_get_lang dictionary_id='41114.Net Satır Top'>">
                                            <div class="form-group"><input type="text" name="row_last_net_total#i#" id="row_last_net_total#i#" class="moneybox" disabled value="#TLFormat(GET_PAYMENT_ROWS.ROW_NET_TOTAL[i]+nettotal_kdv+nettotal_otv)#" onblur="return discount_hesapla(#i#);" onkeyup="return(FormatCurrency(this,event));" readonly="yes"></div></td>
                                    </cfif>
                                    <td class="text-center" title="<cf_get_lang dictionary_id='41110.Toplu Fatr Dah'>"><div class="form-group"><input type="checkbox" name="is_collected_inv#i#" id="is_collected_inv#i#" <cfif GET_PAYMENT_ROWS.IS_COLLECTED_INVOICE[i] eq 1>checked</cfif> disabled onclick="select_row_bill_type(1,#i#);"></div></td>
                                    <td class="text-center" title="<cf_get_lang dictionary_id ='41302.Grup Fatura Dah'>"><div class="form-group"><input type="checkbox" name="is_group_inv#i#" id="is_group_inv#i#" <cfif GET_PAYMENT_ROWS.IS_GROUP_INVOICE[i] eq 1>checked</cfif> disabled onclick="select_row_bill_type(2,#i#);"></div></td>
                                    <td class="text-center" title="<cf_get_lang dictionary_id='41115.Faturalandı'>"><div class="form-group"><input type="checkbox" name="is_billed#i#" id="is_billed#i#" <cfif GET_PAYMENT_ROWS.IS_BILLED[i] eq 1>checked</cfif> disabled></div></td>
                                    <input type="hidden" name="period_id#i#" id="period_id#i#" value="#GET_PAYMENT_ROWS.PERIOD_ID[i]#">
                                    <td width="70" nowrap title="<cf_get_lang dictionary_id='41116.Fatura ID'>"><div class="form-group"><input type="text" name="invoice_id#i#" id="invoice_id#i#" value="#GET_PAYMENT_ROWS.INVOICE_ID[i]#" disabled><input type="hidden" name="bill_info#i#" id="bill_info#i#"></div></td>
                                    <td class="text-center" title="<cf_get_lang dictionary_id='41118.Toplu Prov Oluşturuldu'>"><div class="form-group"><input type="checkbox" name="is_collected_prov#i#" id="is_collected_prov#i#" <cfif GET_PAYMENT_ROWS.IS_COLLECTED_PROVISION[i] eq 1>checked</cfif> disabled></div></td>
                                    <td class="text-center" title="<cf_get_lang dictionary_id='41117.Ödendi'>">
                                        <input type="checkbox" name="is_paid#i#" id="is_paid#i#" <cfif GET_PAYMENT_ROWS.IS_PAID[i] eq 1>checked</cfif> disabled>
                                        <cfif x_payment_plan_revenue_info and len(GET_PAYMENT_ROWS.CARI_ACT_TYPE[i]) and GET_PAYMENT_ROWS.IS_PAID[i] eq 1>
                                            <cfswitch expression = "#GET_PAYMENT_ROWS.CARI_ACT_TYPE[i]#">
                                                <cfcase value="24"><cfset type="ch.popup_dsp_gelenh&period_id=#GET_PAYMENT_ROWS.CARI_PERIOD_ID[i]#"></cfcase>
                                                <cfcase value="31"><cfset type="ch.popup_dsp_cash_revenue&period_id=#GET_PAYMENT_ROWS.CARI_PERIOD_ID[i]#"></cfcase>
                                                <cfcase value="42"><cfset type="ch.popup_print_upd_debit_claim_note&period_id=#GET_PAYMENT_ROWS.CARI_PERIOD_ID[i]#"></cfcase>
                                                <cfcase value="43"><cfset type="objects.popup_cari_action&period_id=#GET_PAYMENT_ROWS.CARI_PERIOD_ID[i]#"></cfcase>
                                                <cfcase value="90"><cfset type="ch.popup_dsp_payroll_entry&period_id=#GET_PAYMENT_ROWS.CARI_PERIOD_ID[i]#"></cfcase>
                                                <cfcase value="97"><cfset type="ch.popup_dsp_voucher_payroll_action&period_id=#GET_PAYMENT_ROWS.CARI_PERIOD_ID[i]#"></cfcase>
                                                <cfcase value="241"><cfset type="ch.popup_dsp_credit_card_payment_type"></cfcase>
                                                <cfcase value="251"><cfset type="bank.popup_dsp_assign_order&period_id=#GET_PAYMENT_ROWS.CARI_PERIOD_ID[i]#"></cfcase>
                                            </cfswitch>
                                            <cfif listfind('24,31,32,241,242,251,43',GET_PAYMENT_ROWS.CARI_ACT_TYPE[i],',')>
                                                <cfset page_type = 'small'>
                                            <cfelse>
                                                <cfset page_type = 'page'>
                                            </cfif>
                                            <cfif GET_PAYMENT_ROWS.CARI_ACT_TABLE[i] is 'CHEQUE'> 
                                                <a class="tableyazi" href="javascript://" onclick="windowopen('#request.self#?fuseaction=objects.popup_cheque_det&ID=#GET_PAYMENT_ROWS.CARI_ACT_ID[i]#&period_id=#GET_PAYMENT_ROWS.CARI_PERIOD_ID[i]#','small')">
                                                    <img src="/images/ship_list.gif" border="0" align="absmiddle">
                                                </a>
                                            <cfelseif GET_PAYMENT_ROWS.CARI_ACT_TABLE[i] is 'VOUCHER'> 
                                                <a class="tableyazi" href="javascript://" onclick="windowopen('#request.self#?fuseaction=objects.popup_voucher_det&ID=#GET_PAYMENT_ROWS.CARI_ACT_ID[i]#&period_id=#GET_PAYMENT_ROWS.CARI_PERIOD_ID[i]#','small')">
                                                    <img src="/images/ship_list.gif" border="0" align="absmiddle">
                                                </a>
                                            <cfelseif isdefined("type")>													
                                                <a class="tableyazi" href="javascript://" onclick="windowopen('#request.self#?fuseaction=#type#&id=#GET_PAYMENT_ROWS.CARI_ACT_ID[i]#','#page_type#');" title="İşlem Detayı">
                                                    <img src="/images/ship_list.gif" border="0" align="absmiddle">
                                                </a>
                                            </cfif>
                                        <cfelse>
                                            &nbsp;
                                        </cfif>
                                    </td>
                                    <cfif x_payment_plan_revenue_info>
                                        <td width="70" nowrap title="<cf_get_lang dictionary_id='41117.Ödendi'>">
                                            <div class="form-group">
                                                <input type="hidden" name="cari_act_table#i#" id="cari_act_table#i#" value="#GET_PAYMENT_ROWS.CARI_ACT_TABLE[i]#">
                                                <input type="hidden" name="cari_act_type#i#" id="cari_act_type#i#" value="#GET_PAYMENT_ROWS.CARI_ACT_TYPE[i]#">
                                                <input type="hidden" name="cari_act_id#i#" id="cari_act_id#i#" value="#GET_PAYMENT_ROWS.CARI_ACT_ID[i]#">
                                                <input type="hidden" name="cari_period_id#i#" id="cari_period_id#i#" value="#GET_PAYMENT_ROWS.CARI_PERIOD_ID[i]#">
                                                <input type="text" name="cari_action_id#i#" id="cari_action_id#i#" value="#GET_PAYMENT_ROWS.CARI_ACTION_ID[i]#" readonly="yes" disabled>
                                            </div>
                                        </td>
                                    </cfif>
                                    <cfif x_payment_plan_campaign>
                                        <td nowrap="nowrap" title="<cf_get_lang dictionary_id='57446.Kampanya'>">
                                            <div class="form-group">
                                                <div class="input-group">
                                                    <input type="hidden" name="camp_id#i#" id="camp_id#i#" value="#GET_PAYMENT_ROWS.CAMPAIGN_ID[i]#">
                                                    <input type="text" name="camp_name#i#" id="camp_name#i#" class="boxtext" value="<cfif len(GET_PAYMENT_ROWS.CAMPAIGN_ID[i])>#GET_PAYMENT_ROWS.camp_head[i]#</cfif>">
                                                    <span class="input-group-addon icon-ellipsis" href="javascript://" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_campaigns&subscription_id=#attributes.subscription_id#&field_id=show_pay_plan.camp_id#i#&field_name=show_pay_plan.camp_name#i#');"></span>
                                                </div>
                                            </div>
                                        </td>
                                    </cfif>
                                    <cfif x_payment_plan_reference>
                                        <td nowrap="nowrap" title="<cf_get_lang dictionary_id='58784.Referans'>">
                                            <div class="form-group">
                                                <div class="input-group">
                                                    <input type="hidden" name="subs_ref_id#i#" id="subs_ref_id#i#" value="#get_payment_rows.subs_reference_id[i]#">
                                                    <input type="text" name="subs_ref_name#i#" id="subs_ref_name#i#" class="boxtext" value="<cfif len(get_payment_rows.subscription_no[i])>#get_payment_rows.subscription_no[i]#</cfif>" maxlength="50" onfocus="AutoComplete_Create('subs_ref_name#i#','SUBSCRIPTION_NO,SUBSCRIPTION_HEAD','SUBSCRIPTION_NO,SUBSCRIPTION_HEAD','get_subscription','2','SUBSCRIPTION_ID','subs_ref_id#i#','','3','150','change_money_info(#i#,100)');" autocomplete="off">
                                                    <span class="input-group-addon icon-ellipsis" href="javascript://" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_list_subscription&field_id=show_pay_plan.subs_ref_id#i#&field_no=show_pay_plan.subs_ref_name#i#&call_money_function=change_money_info(#i#,100)</cfoutput>');"></span>
                                                </div>
                                            </div>
                                        </td>
                                    </cfif>
                                    <cfif x_payment_plan_service>
                                        <td nowrap="nowrap" title="<cf_get_lang dictionary_id='57656.Servis'>">
                                            <div class="form-group">
                                                <div class="input-group">
                                                    <input type="hidden" name="service_id#i#" id="service_id#i#"  value="#get_payment_rows.service_id[i]#">
                                                    <input type="text" name="service_no#i#" id="service_no#i#" class="boxtext" value="<cfif len(get_payment_rows.service_no[i])>#get_payment_rows.service_no[i]#</cfif>" maxlength="50" autocomplete="off">
                                                    <span class="input-group-addon icon-ellipsis" href="javascript://" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_list_service&subscription_id=#attributes.subscription_id#&field_id=show_pay_plan.service_id#i#&field_no=show_pay_plan.service_no#i#</cfoutput>');"></span>
                                                </div>
                                            </div>
                                        </td>
                                    </cfif>
                                    <cfif x_payment_plan_call>
                                        <td nowrap="nowrap" title="<cf_get_lang dictionary_id='57438.Callcenter'>">
                                            <div class="form-group">
                                                <div class="input-group">
                                                    <input type="hidden" name="call_id#i#" id="call_id#i#"  value="#get_payment_rows.call_id[i]#">
                                                    <input type="text" name="call_no#i#" id="call_no#i#" class="boxtext" value="<cfif len(get_payment_rows.call_id[i])>#get_payment_rows.call_no[i]#</cfif>" maxlength="50" autocomplete="off">
                                                    <span class="input-group-addon icon-ellipsis" href="javascript://" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_list_service&subscription_id=#attributes.subscription_id#&field_id=show_pay_plan.call_id#i#&field_no=show_pay_plan.call_no#i#&is_callcenter=1</cfoutput>');"></span>
                                                </div>
                                            </div>
                                        </td>
                                    </cfif>
                                    <cfif xml_payment_plan_import_id>
                                        <td nowrap="nowrap">
                                        <cfif isdefined("GET_PAYMENT_ROWS.SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID") and len(GET_PAYMENT_ROWS.SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID[i])>
                                           <a href="#request.self#?fuseaction=sales.list_subscription_payment_plan_import&event=upd&import_id=#GET_PAYMENT_ROWS.SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID[i]#" target="_blank">#GET_PAYMENT_ROWS.SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID[i]#</a>
                                        </cfif>
                                        </td>
                                    </cfif>
                                    <cfif x_payment_plan_record_info>
                                        <td nowrap="nowrap" title="<cf_get_lang dictionary_id='57483.Kayıt'>">
                                        <cfif len(GET_PAYMENT_ROWS.RECORD_EMP_NAME[i])>
                                            #GET_PAYMENT_ROWS.RECORD_EMP_NAME[i]# - <cfif len(GET_PAYMENT_ROWS.RECORD_DATE[i])> #dateformat(dateadd('h',session.ep.time_zone,GET_PAYMENT_ROWS.RECORD_DATE[i]),dateformat_style)# (#timeformat(GET_PAYMENT_ROWS.RECORD_DATE[i],timeformat_style)#)</cfif>
                                        </cfif>
                                        </td>
                                        <td nowrap="nowrap" title="<cf_get_lang dictionary_id='57891.Güncelleyen'>">
                                        <cfif len(GET_PAYMENT_ROWS.UPDATE_EMP_NAME[i])>
                                            #GET_PAYMENT_ROWS.UPDATE_EMP_NAME[i]# - #dateformat(dateadd('h',session.ep.time_zone,GET_PAYMENT_ROWS.UPDATE_DATE[i]),dateformat_style)# (#timeformat(GET_PAYMENT_ROWS.UPDATE_DATE[i],timeformat_style)#)
                                        </cfif>
                                        </td>
                                    </cfif>
                                    </tr>
                                </cfoutput>	
                                <cfelseif GET_PAYMENT_ROWS.IS_BILLED[i] eq 1 and (session.ep.admin neq 1 and power_user_info neq 1)>
                                <cfoutput>
                                <tr onmouseover="this.className='color-light';" onmouseout="this.className='color-row';" class="color-row" height="22">
                                    <cfif xml_change_row eq 1><td></td></cfif>
                                    <td align="center" nowrap="nowrap">
                                        <cfif len(GET_PAYMENT_ROWS.INVOICE_ID[i]) and GET_PAYMENT_ROWS.IS_PAID[i] eq 0 and GET_PAYMENT_ROWS.IS_COLLECTED_PROVISION[i] eq 0 and len(GET_PAYMENT_ROWS.CARD_PAYMETHOD_ID[i])>
                                            <cfset donem_db = "#dsn#_#GET_PAYMENT_ROWS.period_year[i]#_#session.ep.company_id#">
                                            <cfquery name="getInvoiceNettotal" datasource="#donem_db#">
                                                SELECT NETTOTAL FROM INVOICE WHERE INVOICE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#GET_PAYMENT_ROWS.INVOICE_ID[i]#">
                                            </cfquery>	
                                            <a href="javascript://" onclick="windowopen('#request.self#?fuseaction=bank.popup_add_online_pos&member_type=#MEMBER_TYPE#&member_id=#MEMBER_ID#&card_id_info=#MEMBER_CC_ID#&action_value=#getInvoiceNettotal.NETTOTAL#&invoice_id=#GET_PAYMENT_ROWS.INVOICE_ID[i]#&period_id=#GET_PAYMENT_ROWS.PERIOD_ID[i]#&paym_id=#GET_PAYMENT_ROWS.CARD_PAYMETHOD_ID[i]#','medium');"><img src="/images/pos_credit_sanal.gif" title="Sanal POS" border="0"></a>
                                        </cfif>
                                        <cfif len(GET_PAYMENT_ROWS.INVOICE_ID[i])>
                                            <a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_detail_invoice&id=#GET_PAYMENT_ROWS.INVOICE_ID[i]#&period_id=#GET_PAYMENT_ROWS.PERIOD_ID[i]#</cfoutput>','page');" class="tableyazi"><img src="/images/ship_list.gif" border="0" align="absmiddle"></a><cfif len(GET_PAYMENT_ROWS.IS_INVOICE_IPTAL[i])><font color="red" size="+1"><b>*</b></font></cfif>
                                        </cfif>
                                    </td>
                                    <td class="text-center" title="<cf_get_lang dictionary_id='57493.Aktif'>"><div class="form-group"><input type="checkbox" name="is_aktive#i#" id="is_aktive#i#" <cfif GET_PAYMENT_ROWS.IS_ACTIVE[i] eq 1>checked</cfif> disabled></div></td>
                                    <td nowrap title="<cf_get_lang dictionary_id='57742.Tarih'>">
                                        <div class="form-group">
                                            <div class="input-group">
                                                <input type="hidden" name="is_disabled_#i#" id="is_disabled_#i#" value="1">
                                                <input type="hidden" name="payment_row_id#i#" id="payment_row_id#i#" value="#GET_PAYMENT_ROWS.SUBSCRIPTION_PAYMENT_ROW_ID[i]#">
                                                <input type="text" name="payment_date#i#" id="payment_date#i#" class="boxtext" value="#DateFormat(GET_PAYMENT_ROWS.PAYMENT_DATE[i],dateformat_style)#" validate="#validate_style#" maxlength="10" disabled readonly>
                                                <span class="input-group-addon"><cf_wrk_date_image date_field="payment_date#i#"></span>
                                            </div>
                                        </div>
                                    </td>
                                    <cfif xml_payment_finish_date eq 1>
                                        <td nowrap="nowrap">
                                            <div class="form-group">
                                                <div class="input-group">
                                                    <cfinput type="text" name="payment_finish_date#i#" class="boxtext" value="#DateFormat(GET_PAYMENT_ROWS.PAYMENT_FINISH_DATE[i],dateformat_style)#" validate="#validate_style#" maxlength="10" style="width:67px;">
                                                    <span class="input-group-addon"><cf_wrk_date_image date_field="payment_finish_date#i#"></span>
                                                </div>
                                            </div>
                                        </td>
                                    </cfif>
                                        <input type="hidden" name="product_id#i#" id="product_id#i#" value="#GET_PAYMENT_ROWS.PRODUCT_ID[i]#">
                                        <input type="hidden" name="stock_id#i#" id="stock_id#i#" value="#GET_PAYMENT_ROWS.STOCK_ID[i]#">
                                        <input type="hidden" name="unit_id#i#" id="unit_id#i#" value="#GET_PAYMENT_ROWS.UNIT_ID[i]#">
                                    <td width="200" nowrap title="<cf_get_lang dictionary_id='57657.Urun'>">
                                        <div class="form-group">
                                            <div class="input-group">
                                                <input type="text" name="detail#i#" id="detail#i#" class="boxtext" value="#GET_PAYMENT_ROWS.DETAIL[i]#" maxlength="50" disabled>
                                                <span class="input-group-addon icon-ellipsis" href="javascript://" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_product_names&product_id=show_pay_plan.product_id#i#&field_id=show_pay_plan.stock_id#i#&field_unit_name=show_pay_plan.unit#i#&field_main_unit=show_pay_plan.unit_id#i#&field_name=show_pay_plan.detail#i#</cfoutput>');"></span>
                                                <span class="input-group-addon icon-ellipsis" href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_detail_product&pid=#GET_PAYMENT_ROWS.PRODUCT_ID[i]#</cfoutput>','medium');"></span>
                                            </div>
                                        </div>
                                    </td>
                                    <td nowrap title="<cf_get_lang dictionary_id='58516.Ödeme Yöntemi'>">
                                        <div class="form-group">
                                            <div class="input-group">
                                                <input type="hidden" name="card_paymethod_id#i#" id="card_paymethod_id#i#" value="#GET_PAYMENT_ROWS.CARD_PAYMETHOD_ID[i]#">
                                                <input type="hidden" name="paymethod_id#i#" id="paymethod_id#i#" value="#GET_PAYMENT_ROWS.PAYMETHOD_ID[i]#">
                                                <input type="text" name="paymethod#i#" id="paymethod#i#" class="boxtext" value="<cfif len(GET_PAYMENT_ROWS.PAYMETHOD[i])>#GET_PAYMENT_ROWS.PAYMETHOD[i]#<cfelseif len(GET_PAYMENT_ROWS.CARD_PAYMETHOD_ID[i])>#GET_PAYMENT_ROWS.CARD_NO[i]#</cfif>" readonly="yes" maxlength="50" disabled>
                                                <span class="input-group-addon icon-ellipsis" href="javascript://" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_paymethods&field_id=show_pay_plan.paymethod_id#i#&field_name=show_pay_plan.paymethod#i#&field_card_payment_id=show_pay_plan.card_paymethod_id#i#&field_card_payment_name=show_pay_plan.paymethod#i#</cfoutput>');"></span>
                                            </div>
                                        </div>
                                    </td>
                                    <td title="<cf_get_lang dictionary_id='57636.Birim'>"><div class="form-group"><input type="text" name="unit#i#" id="unit#i#" maxlength="10" value="#GET_PAYMENT_ROWS.UNIT[i]#" readonly="yes" disabled></div></td>
                                    <cfif x_payment_plan_kdv>
                                        <td title="<cf_get_lang dictionary_id='57639.KDV'>"><div class="form-group"><input type="text" name="kdv_rate#i#" id="kdv_rate#i#" class="moneybox" maxlength="10" value="#get_payment_rows.tax[i]#" readonly="yes"></div></td>
                                    <cfelse>
                                        <input type="hidden" name="kdv_rate#i#" id="kdv_rate#i#" maxlength="10" value="#get_payment_rows.tax[i]#" readonly="yes">
                                    </cfif>
                                    <cfif x_payment_plan_otv>
                                        <td title="<cf_get_lang dictionary_id='58021.ÖTV'>"><div class="form-group"><input type="text" name="otv_rate#i#" id="otv_rate#i#" class="moneybox" maxlength="10" value="#get_payment_rows.OTV[i]#" readonly="yes" disabled></div></td>
                                    <cfelse>
                                        <input type="hidden" name="otv_rate#i#" id="otv_rate#i#" maxlength="10" value="#get_payment_rows.OTV[i]#" readonly="yes" disabled>
                                    </cfif>
                                    <td title="<cf_get_lang dictionary_id='57635.Miktar'>"><div class="form-group"><cfinput type="text" name="quantity#i#" class="box" value="#GET_PAYMENT_ROWS.QUANTITY[i]#" onChange="is_zero(#i#)" onBlur="return hesapla(#i#);" disabled></div></td>
                                    <td title="<cf_get_lang dictionary_id='57673.Tutar'>"><div class="form-group"><input type="text" name="amount#i#" id="amount#i#" class="moneybox" value="#TLFormat(GET_PAYMENT_ROWS.AMOUNT[i],price_round_number)#" onblur="hesapla(#i#);AmountRnd('amount#i#',<cfoutput>#price_round_number#</cfoutput>);" disabled></div></td>
                                    <td title="<cf_get_lang dictionary_id='57489.Para Br'>">					
                                        <div class="form-group">
                                            <select name="money_type_row#i#" id="money_type_row#i#" class="boxtext" disabled>
                                                <cfloop query="GET_MONEY">
                                                    <option value="#MONEY#" <cfif GET_MONEY.MONEY eq GET_PAYMENT_ROWS.MONEY_TYPE[i]>selected</cfif>>#MONEY#</option>
                                                </cfloop>
                                            </select>			
                                        </div>
                                    </td>
                                    <cfif xml_payment_rate>
                                        <td title="<cf_get_lang dictionary_id='57648.Kur'>"><div class="form-group"><input type="text" name="row_rate#i#" id="row_rate#i#" value="#TLFormat(get_payment_rows.rate[i])#" class="moneybox" onkeyup="return(FormatCurrency(this,event,4));"></div></td>
                                    </cfif>
                                    <td title="<cf_get_lang dictionary_id='41113.Satır Toplamı'>"><div class="form-group"><input type="text" name="row_total#i#" id="row_total#i#" class="moneybox" value="#TLFormat(GET_PAYMENT_ROWS.ROW_TOTAL[i],price_round_number)#" onblur="AmountRnd('ROW_TOTAL#i#',<cfoutput>#price_round_number#</cfoutput>);" onkeyup="return(FormatCurrency(this,event));" disabled readonly="yes"></div></td>
                                    <cfif x_payment_plan_isk_amount>
                                        <td title="<cf_get_lang dictionary_id='57641.İSK'> <cf_get_lang dictionary_id='57673.Tutar'>"><div class="form-group"><input type="text" name="discount_amount#i#" id="discount_amount#i#" class="moneybox" value="#TLFormat(GET_PAYMENT_ROWS.DISCOUNT_AMOUNT[i])#" validate="float" onblur="return indirim_hesapla(#i#);" onkeyup="return(FormatCurrency(this,event));" disabled readonly="yes"></div></td>
                                    <cfelse>
                                        <input type="hidden" name="discount_amount#i#" id="discount_amount#i#" class="moneybox" value="#TLFormat(GET_PAYMENT_ROWS.DISCOUNT_AMOUNT[i])#" validate="float" onblur="return indirim_hesapla(#i#);" onkeyup="return(FormatCurrency(this,event));" disabled readonly="yes">
                                    </cfif>
                                    <td title="<cf_get_lang dictionary_id='57641.İSK'>(%)"><div class="form-group"><input type="text" name="discount#i#" id="discount#i#" class="moneybox" value="#TLFormat(GET_PAYMENT_ROWS.DISCOUNT[i])#" validate="integer" maxlength="3" onblur="return indirim_hesapla(#i#);" onkeyup="return(FormatCurrency(this,event));" disabled readonly="yes"></div></td>
                                    <td title="<cf_get_lang dictionary_id='41114.Net Satır Top'>"><div class="form-group"><input type="text" name="row_net_total#i#" id="row_net_total#i#" class="moneybox" disabled value="#TLFormat(GET_PAYMENT_ROWS.ROW_NET_TOTAL[i],session.ep.our_company_info.rate_round_num)#" onblur="return discount_hesapla(#i#);" onkeyup="return(FormatCurrency(this,event));" readonly="yes"></div></td>
                                    <cfif x_payment_plan_kdv_amount>
                                        <cfset nettotal_kdv = GET_PAYMENT_ROWS.ROW_NET_TOTAL[i]*GET_PAYMENT_ROWS.TAX[i]/100>
                                        <cfset nettotal_otv = GET_PAYMENT_ROWS.ROW_NET_TOTAL[i]*GET_PAYMENT_ROWS.OTV[i]/100>
                                        <td title="KDV'li <cf_get_lang dictionary_id='41114.Net Satır Top'>"><div class="form-group"><input type="text" name="row_last_net_total#i#" id="row_last_net_total#i#" class="moneybox" disabled value="#TLFormat(GET_PAYMENT_ROWS.ROW_NET_TOTAL[i]+nettotal_kdv+nettotal_otv)#" onblur="return discount_hesapla(#i#);" onkeyup="return(FormatCurrency(this,event));" readonly="yes"></div></td>
                                    </cfif>
                                    <td class="text-center" title="<cf_get_lang dictionary_id='41110.Toplu Fatr Dah'>"><div class="form-group"><input type="checkbox" name="is_collected_inv#i#" id="is_collected_inv#i#" <cfif GET_PAYMENT_ROWS.IS_COLLECTED_INVOICE[i] eq 1>checked</cfif> disabled onclick="select_row_bill_type(1,#i#);"></div></td>
                                    <td class="text-center" title="<cf_get_lang dictionary_id ='41302.Grup Fatura Dah'>"><div class="form-group"><input type="checkbox" name="is_group_inv#i#" id="is_group_inv#i#" <cfif GET_PAYMENT_ROWS.IS_GROUP_INVOICE[i] eq 1>checked</cfif> disabled onclick="select_row_bill_type(2,#i#);"></div></td>
                                    <td class="text-center" title="<cf_get_lang dictionary_id='41115.Faturalandı'>"><div class="form-group"><input type="checkbox" name="is_billed#i#" id="is_billed#i#" <cfif GET_PAYMENT_ROWS.IS_BILLED[i] eq 1>checked</cfif> disabled></div></td>
                                    <input type="hidden" name="period_id#i#" id="period_id#i#" value="#GET_PAYMENT_ROWS.PERIOD_ID[i]#">
                                    <td width="70" nowrap title="<cf_get_lang dictionary_id='41116.Fatura ID'>"><div class="form-group"><input type="text" name="invoice_id#i#" id="invoice_id#i#" class="box" value="#GET_PAYMENT_ROWS.INVOICE_ID[i]#" disabled><input type="hidden" name="bill_info#i#" id="bill_info#i#"></div></td>
                                    <td class="text-center" title="<cf_get_lang dictionary_id='41118.Toplu Prov Oluşturuldu'>"><div class="form-group"><input type="checkbox" name="is_collected_prov#i#" id="is_collected_prov#i#" <cfif GET_PAYMENT_ROWS.IS_COLLECTED_PROVISION[i] eq 1>checked</cfif>></div></td>
                                    <td class="text-center" title="<cf_get_lang dictionary_id='41117.Ödendi'>">
                                        <div class="form-group">
                                            <div class="input-group">
                                                <input type="checkbox" name="is_paid#i#" id="is_paid#i#" <cfif GET_PAYMENT_ROWS.IS_PAID[i] eq 1>checked</cfif>>
                                                <cfif x_payment_plan_revenue_info and len(GET_PAYMENT_ROWS.CARI_ACT_TYPE[i]) and GET_PAYMENT_ROWS.IS_PAID[i] eq 1>
                                                    <cfswitch expression = "#GET_PAYMENT_ROWS.CARI_ACT_TYPE[i]#">
                                                        <cfcase value="24"><cfset type="ch.popup_dsp_gelenh&period_id=#GET_PAYMENT_ROWS.CARI_PERIOD_ID[i]#"></cfcase>
                                                        <cfcase value="31"><cfset type="ch.popup_dsp_cash_revenue&period_id=#GET_PAYMENT_ROWS.CARI_PERIOD_ID[i]#"></cfcase>
                                                        <cfcase value="42"><cfset type="ch.popup_print_upd_debit_claim_note&period_id=#GET_PAYMENT_ROWS.CARI_PERIOD_ID[i]#"></cfcase>
                                                        <cfcase value="43"><cfset type="objects.popup_cari_action&period_id=#GET_PAYMENT_ROWS.CARI_PERIOD_ID[i]#"></cfcase>
                                                        <cfcase value="90"><cfset type="ch.popup_dsp_payroll_entry&period_id=#GET_PAYMENT_ROWS.CARI_PERIOD_ID[i]#"></cfcase>
                                                        <cfcase value="97"><cfset type="ch.popup_dsp_voucher_payroll_action&period_id=#GET_PAYMENT_ROWS.CARI_PERIOD_ID[i]#"></cfcase>
                                                        <cfcase value="241"><cfset type="ch.popup_dsp_credit_card_payment_type"></cfcase>
                                                        <cfcase value="251"><cfset type="bank.popup_dsp_assign_order&period_id=#GET_PAYMENT_ROWS.CARI_PERIOD_ID[i]#"></cfcase>
                                                    </cfswitch>
                                                    <cfif listfind('24,31,32,241,242,251,43',GET_PAYMENT_ROWS.CARI_ACT_TYPE[i],',')>
                                                        <cfset page_type = 'small'>
                                                    <cfelse>
                                                        <cfset page_type = 'page'>
                                                    </cfif>
                                                    <cfif GET_PAYMENT_ROWS.CARI_ACT_TABLE[i] is 'CHEQUE'> 
                                                        <span class="input-group-addon icon-ellipsis" href="javascript://" onclick="windowopen('#request.self#?fuseaction=objects.popup_cheque_det&ID=#GET_PAYMENT_ROWS.CARI_ACT_ID[i]#&period_id=#GET_PAYMENT_ROWS.CARI_PERIOD_ID[i]#','small')"></span>
                                                    <cfelseif GET_PAYMENT_ROWS.CARI_ACT_TABLE[i] is 'VOUCHER'> 
                                                        <span class="input-group-addon icon-ellipsis" href="javascript://" onclick="windowopen('#request.self#?fuseaction=objects.popup_voucher_det&ID=#GET_PAYMENT_ROWS.CARI_ACT_ID[i]#&period_id=#GET_PAYMENT_ROWS.CARI_PERIOD_ID[i]#','small')"></span>
                                                    <cfelse>													
                                                        <span class="input-group-addon icon-ellipsis" href="javascript://" onclick="windowopen('#request.self#?fuseaction=#type#&id=#GET_PAYMENT_ROWS.CARI_ACT_ID[i]#','#page_type#');" title="<cf_get_lang dictionary_id='34326.Detaylar'>"></span>
                                                    </cfif>
                                                <cfelse>
                                                    
                                                </cfif>
                                            </div>
                                        </div>
                                    </td>
                                    <cfif x_payment_plan_revenue_info>
                                        <td width="70" nowrap title="<cf_get_lang dictionary_id='41117.Ödendi'>">
                                            <div class="form-group">
                                                <input type="hidden" name="cari_act_table#i#" id="cari_act_table#i#" value="#GET_PAYMENT_ROWS.CARI_ACT_TABLE[i]#">
                                                <input type="hidden" name="cari_act_type#i#" id="cari_act_type#i#" value="#GET_PAYMENT_ROWS.CARI_ACT_TYPE[i]#">
                                                <input type="hidden" name="cari_act_id#i#" id="cari_act_id#i#" value="#GET_PAYMENT_ROWS.CARI_ACT_ID[i]#">
                                                <input type="hidden" name="cari_period_id#i#" id="cari_period_id#i#" value="#GET_PAYMENT_ROWS.CARI_PERIOD_ID[i]#">
                                                <input type="text" name="cari_action_id#i#" id="cari_action_id#i#" value="#GET_PAYMENT_ROWS.CARI_ACTION_ID[i]#" readonly="yes" disabled>
                                            </div>
                                        </td>
                                    </cfif>
                                    <cfif x_payment_plan_campaign>
                                        <td nowrap="nowrap" title="<cf_get_lang dictionary_id='57446.Kampanya'>">
                                            <div class="form-group">
                                                <div class="input-group">
                                                    <input type="hidden" name="camp_id#i#" id="camp_id#i#" value="#GET_PAYMENT_ROWS.CAMPAIGN_ID[i]#">
                                                    <input type="text" name="camp_name#i#" id="camp_name#i#" class="boxtext" value="<cfif len(GET_PAYMENT_ROWS.CAMPAIGN_ID[i])>#GET_PAYMENT_ROWS.CAMP_HEAD[i]#</cfif>">
                                                    <span class="input-group-addon icon-ellipsis" href="javascript://" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_campaigns&subscription_id=#attributes.subscription_id#&field_id=show_pay_plan.camp_id#i#&field_name=show_pay_plan.camp_name#i#');"></span>
                                                </div>
                                            </div>
                                        </td>
                                    </cfif>
                                    <cfif x_payment_plan_reference>
                                        <td nowrap="nowrap" title="<cf_get_lang dictionary_id='58784.Referans'>">
                                            <div class="form-group">
                                                <div class="input-group">
                                                    <input type="hidden" name="subs_ref_id#i#" id="subs_ref_id#i#" value="#get_payment_rows.subs_reference_id[i]#">
                                                    <input type="text" name="subs_ref_name#i#" id="subs_ref_name#i#" class="boxtext" value="<cfif len(get_payment_rows.subscription_no[i])>#get_payment_rows.subscription_no[i]#</cfif>" maxlength="50" onfocus="AutoComplete_Create('subs_ref_name#i#','SUBSCRIPTION_NO,SUBSCRIPTION_HEAD','SUBSCRIPTION_NO,SUBSCRIPTION_HEAD','get_subscription','2','SUBSCRIPTION_ID','subs_ref_id#i#','','3','150','change_money_info(#i#,100)');" autocomplete="off">
                                                    <span class="input-group-addon icon-ellipsis" href="javascript://" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_list_subscription&field_id=show_pay_plan.subs_ref_id#i#&field_no=show_pay_plan.subs_ref_name#i#&call_money_function=change_money_info(#i#,100)</cfoutput>');"></span>
                                                </div>
                                            </div>
                                        </td>
                                    </cfif>
                                    <cfif x_payment_plan_service>
                                        <td nowrap="nowrap" title="<cf_get_lang dictionary_id='57656.Servis'>">
                                            <div class="form-group">
                                                <div class="input-group">
                                                    <input type="hidden" name="service_id#i#" id="service_id#i#"  value="#GET_PAYMENT_ROWS.SERVICE_ID[i]#">
                                                    <input type="text" name="service_no#i#" id="service_no#i#" class="boxtext" value="<cfif len(GET_PAYMENT_ROWS.SERVICE_ID[i])>#GET_PAYMENT_ROWS.SERVICE_NO[i]#</cfif>" maxlength="50" autocomplete="off">
                                                    <span class="input-group-addon icon-ellipsis" href="javascript://" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_list_service&subscription_id=#attributes.subscription_id#&field_id=show_pay_plan.service_id#i#&field_no=show_pay_plan.service_no#i#</cfoutput>');"></span>
                                                </div>
                                            </div>
                                        </td>
                                    </cfif>
                                    <cfif x_payment_plan_call>
                                        <td nowrap="nowrap" title="<cf_get_lang dictionary_id='57438.Callcenter'>">
                                            <div class="form-group">
                                                <div class="input-group">
                                                    <input type="hidden" name="call_id#i#" id="call_id#i#"  value="#GET_PAYMENT_ROWS.CALL_ID[i]#">
                                                    <input type="text" name="call_no#i#" id="call_no#i#" class="boxtext" value="<cfif len(GET_PAYMENT_ROWS.CALL_ID[i])>#GET_PAYMENT_ROWS.G_SERVICE_NO[i]#</cfif>" maxlength="50" autocomplete="off">
                                                    <span class="input-group-addon icon-ellipsis" href="javascript://" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_list_service&subscription_id=#attributes.subscription_id#&field_id=show_pay_plan.call_id#i#&field_no=show_pay_plan.call_no#i#&is_callcenter=1</cfoutput>');"></span>
                                                </div>
                                            </div>
                                        </td>
                                    </cfif>
                                    <cfif xml_payment_plan_import_id>
                                        <td nowrap="nowrap">
                                        <cfif isdefined("GET_PAYMENT_ROWS.SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID") and len(GET_PAYMENT_ROWS.SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID[i])>
                                            <a href="#request.self#?fuseaction=sales.list_subscription_payment_plan_import&event=upd&import_id=#GET_PAYMENT_ROWS.SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID[i]#" target="_blank">#GET_PAYMENT_ROWS.SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID[i]#</a>
                                        </cfif>
                                        </td>
                                    </cfif>
                                    <cfif x_payment_plan_record_info>
                                        <td nowrap="nowrap" title="<cf_get_lang dictionary_id='57483.Kayıt'>">
                                        <cfif len(GET_PAYMENT_ROWS.RECORD_EMP_NAME[i])>
                                            #GET_PAYMENT_ROWS.RECORD_EMP_NAME[i]# - #dateformat(dateadd('h',session.ep.time_zone,GET_PAYMENT_ROWS.RECORD_DATE[i]),dateformat_style)# (#timeformat(GET_PAYMENT_ROWS.RECORD_DATE[i],timeformat_style)#)
                                        </cfif>
                                        </td>
                                        <td nowrap="nowrap" title="<cf_get_lang dictionary_id='57891.Güncelleyen'>">
                                        <cfif len(GET_PAYMENT_ROWS.UPDATE_EMP_NAME[i])>
                                            #GET_PAYMENT_ROWS.UPDATE_EMP_NAME[i]# - #dateformat(dateadd('h',session.ep.time_zone,GET_PAYMENT_ROWS.UPDATE_DATE[i]),dateformat_style)# (#timeformat(GET_PAYMENT_ROWS.UPDATE_DATE[i],timeformat_style)#)
                                        </cfif>
                                        </td>
                                    </cfif>
                                    </tr>
                                </cfoutput>
                                <cfelse>
                                <cfoutput>
                                <tr>
                                    <td class="text-center">
                                        <div class="form-group">
                                            <input type="checkbox" name="is_change#i#" id="is_change#i#" value="<cfif GET_PAYMENT_ROWS.IS_BILLED[i] eq 0 and GET_PAYMENT_ROWS.IS_COLLECTED_PROVISION[i] eq 0 and GET_PAYMENT_ROWS.IS_PAID[i] eq 0>#i#,#GET_PAYMENT_ROWS.SUBSCRIPTION_PAYMENT_ROW_ID[i]#</cfif>" checked><!--- value kismi, toplu silme kontrolleri icin dolduruluyor --->
                                        </div>
                                    </td>
                                    <td class="text-center">
                                        <cfif len(GET_PAYMENT_ROWS.INVOICE_ID[i]) and GET_PAYMENT_ROWS.IS_PAID[i] eq 0 and GET_PAYMENT_ROWS.IS_COLLECTED_PROVISION[i] eq 0 and len(GET_PAYMENT_ROWS.CARD_PAYMETHOD_ID[i])><!---&action_value=#GET_PAYMENT_ROWS.ROW_NET_TOTAL[i]#--->
                                            <cfset donem_db = "#dsn#_#GET_PAYMENT_ROWS.period_year[i]#_#session.ep.company_id#">
                                            <cfquery name="getInvoiceNettotal" datasource="#donem_db#">
                                                SELECT NETTOTAL FROM INVOICE WHERE INVOICE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#GET_PAYMENT_ROWS.INVOICE_ID[i]#">
                                            </cfquery>
                                            <div class="form-group">
                                                <div class="input-group">
                                                    <span class="input-group-addon icon-ellipsis" href="javascript://" onclick="windowopen('#request.self#?fuseaction=bank.popup_add_online_pos&member_type=#MEMBER_TYPE#&member_id=#MEMBER_ID#&card_id_info=#MEMBER_CC_ID#&action_value=#getInvoiceNettotal.NETTOTAL#&invoice_id=#GET_PAYMENT_ROWS.INVOICE_ID[i]#&period_id=#GET_PAYMENT_ROWS.PERIOD_ID[i]#&paym_id=#GET_PAYMENT_ROWS.CARD_PAYMETHOD_ID[i]#','medium');"></span>
                                                </div>
                                            </div>
                                        </cfif>
                                    </td>
                                    <td>
                                        <cfif GET_PAYMENT_ROWS.IS_BILLED[i] eq 0 and GET_PAYMENT_ROWS.IS_COLLECTED_PROVISION[i] eq 0 and GET_PAYMENT_ROWS.IS_PAID[i] eq 0>
                                            <cfif (not listfindnocase(denied_pages,"sales.emptypopup_del_subs_pay_plan_row"))><!--- Butona kisit koyma FBS20140327 --->
                                                <a href="javascript://" onclick="camp_control_row(#i#,#GET_PAYMENT_ROWS.SUBSCRIPTION_PAYMENT_ROW_ID[i]#,'');"><i class="fa fa-minus" title="<cf_get_lang dictionary_id='57463.Sil'>" alt="<cf_get_lang dictionary_id='57463.Sil'>"></i></a>
                                            </cfif>
                                        </cfif>
                                        <cfif len(GET_PAYMENT_ROWS.INVOICE_ID[i])>
                                            <a href="javascript://" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_detail_invoice&id=#GET_PAYMENT_ROWS.INVOICE_ID[i]#&period_id=#GET_PAYMENT_ROWS.PERIOD_ID[i]#</cfoutput>','page');" class="tableyazi"><i class="fa fa-clipboard"></i></i></a><cfif len(GET_PAYMENT_ROWS.IS_INVOICE_IPTAL[i])><font color="red" size="+1"><b>*</b></font></cfif>
                                        </cfif>
                                    </td>
                                    <td class="text-center"><div class="form-group"><input type="checkbox" name="is_active#i#" id="is_active#i#" <cfif GET_PAYMENT_ROWS.IS_ACTIVE[i] eq 1>checked</cfif>></div></td>
                                    <td>
                                        <div class="form-group">
                                            <div class="input-group">
                                                <input type="hidden" name="is_disabled_#i#" id="is_disabled_#i#" value="0">
                                                <input type="hidden" name="payment_row_id#i#" id="payment_row_id#i#" value="#GET_PAYMENT_ROWS.SUBSCRIPTION_PAYMENT_ROW_ID[i]#">
                                                <input type="text" name="payment_date#i#" id="payment_date#i#" value="#DateFormat(GET_PAYMENT_ROWS.PAYMENT_DATE[i],dateformat_style)#" class="boxtext" validate="#validate_style#" maxlength="10" readonly>
                                                <span class="input-group-addon"><cf_wrk_date_image date_field="payment_date#i#"></span>
                                            </div>
                                        </div>
                                    </td>
                                    <cfif xml_payment_finish_date eq 1>
                                        <td>
                                            <div class="form-group">
                                                <div class="input-group">
                                                    <cfinput type="text" name="payment_finish_date#i#" class="boxtext" value="#DateFormat(GET_PAYMENT_ROWS.PAYMENT_FINISH_DATE[i],dateformat_style)#" validate="#validate_style#" maxlength="10">
                                                    <span class="input-group-addon"><cf_wrk_date_image date_field="payment_finish_date#i#"></div>
                                                </div>
                                            </div>
                                        </td>
                                    </cfif>
                                        <input type="hidden" name="product_id#i#" id="product_id#i#" value="#GET_PAYMENT_ROWS.PRODUCT_ID[i]#">
                                        <input type="hidden" name="stock_id#i#" id="stock_id#i#" value="#GET_PAYMENT_ROWS.STOCK_ID[i]#">
                                        <input type="hidden" name="unit_id#i#" id="unit_id#i#" value="#GET_PAYMENT_ROWS.UNIT_ID[i]#">
                                    <td width="200">
                                        <div class="form-group">
                                            <div class="input-group">
                                                <input type="text" name="detail#i#" id="detail#i#" value="#GET_PAYMENT_ROWS.DETAIL[i]#" class="boxtext" maxlength="50">
                                                <span class="input-group-addon icon-ellipsis" href="javascript://" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_product_names&product_id=show_pay_plan.product_id#i#&field_id=show_pay_plan.stock_id#i#&field_unit_name=show_pay_plan.unit#i#&field_main_unit=show_pay_plan.unit_id#i#&field_name=show_pay_plan.detail#i#</cfoutput>');"></span>
                                                <span class="input-group-addon icon-ellipsis" href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_detail_product&pid=#GET_PAYMENT_ROWS.PRODUCT_ID[i]#</cfoutput>','medium');"></span>
                                            </div>
                                        </div>
                                    </td>
                                    <td>
                                        <div class="form-group">
                                            <div class="input-group">
                                                <input type="hidden" name="card_paymethod_id#i#" id="card_paymethod_id#i#" value="#GET_PAYMENT_ROWS.CARD_PAYMETHOD_ID[i]#">
                                                <input type="hidden" name="paymethod_id#i#" id="paymethod_id#i#" value="#GET_PAYMENT_ROWS.PAYMETHOD_ID[i]#">
                                                <input type="text" name="paymethod#i#" id="paymethod#i#" class="boxtext" value="<cfif len(GET_PAYMENT_ROWS.PAYMETHOD[i])>#GET_PAYMENT_ROWS.PAYMETHOD[i]#<cfelseif len(GET_PAYMENT_ROWS.CARD_PAYMETHOD_ID[i])>#GET_PAYMENT_ROWS.CARD_NO[i]#</cfif>" readonly="yes" maxlength="50" disabled>
                                                <span class="input-group-addon icon-ellipsis" href="javascript://" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_paymethods&field_id=show_pay_plan.paymethod_id#i#&field_name=show_pay_plan.paymethod#i#&field_card_payment_id=show_pay_plan.card_paymethod_id#i#&field_card_payment_name=show_pay_plan.paymethod#i#</cfoutput>');"></span>
                                            </div>
                                        </div>
                                    </td>
                                    <td><div class="form-group"><input type="text" name="unit#i#" id="unit#i#" class="box" maxlength="10" value="#GET_PAYMENT_ROWS.UNIT[i]#" readonly="yes"></div></td>
                                    <cfif x_payment_plan_kdv>
                                        <td><div class="form-group"><input type="text" name="kdv_rate#i#" id="kdv_rate#i#" class="moneybox" maxlength="10" value="#GET_PAYMENT_ROWS.TAX[i]#" readonly="yes"></div></td>
                                    <cfelse>
                                        <input type="hidden" name="kdv_rate#i#" id="kdv_rate#i#" maxlength="10" value="#GET_PAYMENT_ROWS.TAX[i]#" readonly="yes">
                                    </cfif>
                                    <cfif x_payment_plan_otv>
                                        <td><div class="form-group"><input type="text" name="otv_rate#i#" id="otv_rate#i#" class="moneybox" maxlength="10" value="#GET_PAYMENT_ROWS.OTV[i]#" readonly="yes" disabled></div></td>
                                    <cfelse>
                                        <input type="hidden" name="otv_rate#i#" id="otv_rate#i#" maxlength="10" value="#GET_PAYMENT_ROWS.OTV[i]#" readonly="yes" disabled>
                                    </cfif>
                                    <td title="<cf_get_lang dictionary_id='57635.Miktar'>"><div class="form-group"><cfinput type="text" name="quantity#i#" class="box" value="#GET_PAYMENT_ROWS.QUANTITY[i]#" onChange="is_zero(#i#)" onBlur="return hesapla(#i#);"></div></td>
                                    <td title="<cf_get_lang dictionary_id='57673.Tutar'>"><div class="form-group"><input type="text" name="amount#i#" id="amount#i#" class="moneybox" value="#TLFormat(GET_PAYMENT_ROWS.AMOUNT[i],price_round_number)#" onblur="hesapla(#i#);AmountRnd('amount#i#',<cfoutput>#price_round_number#</cfoutput>);"></div></td>
                                    <td title="<cf_get_lang dictionary_id='57489.Para Br'>">
                                        <div class="form-group">
                                            <select name="money_type_row#i#" id="money_type_row#i#" class="box">
                                                <cfloop query="GET_MONEY">
                                                    <option value="#MONEY#" <cfif GET_MONEY.MONEY eq GET_PAYMENT_ROWS.MONEY_TYPE[i]> selected </cfif>>#MONEY#</option>
                                                </cfloop>
                                            </select>
                                        </div>
                                    </td>
                                    <td><div class="form-group"><input type="text" name="row_bsmv_rate#i#" id="row_bsmv_rate#i#" class="moneybox" readonly="yes" value="#TLFormat(GET_PAYMENT_ROWS.BSMV_RATE[i],price_round_number)#"></div></td>
                                    <td style="display:none;"><div class="form-group"><input type="text" name="row_bsmv_amount#i#" id="row_bsmv_amount#i#" class="boxtext" readonly="yes" value="#TLFormat(GET_PAYMENT_ROWS.BSMV_AMOUNT[i],price_round_number)#"></div></td>
                                    <td style="display:none;"><div class="form-group"><input type="text" name="row_reason_code#i#" id="row_reason_code#i#" class="boxtext" readonly="yes" value="#GET_PAYMENT_ROWS.REASON_CODE[i]#"></div></td>
                                    <td><div class="form-group"><input type="text" name="row_oiv_rate#i#" id="row_oiv_rate#i#" class="moneybox" readonly="yes" value="#TLFormat(GET_PAYMENT_ROWS.OIV_RATE[i],price_round_number)#"></div></td>
                                    <td style="display:none;"><div class="form-group"><input type="text" name="row_oiv_amount#i#" id="row_oiv_amount#i#" class="boxtext" readonly="yes" value="#TLFormat(GET_PAYMENT_ROWS.OIV_AMOUNT[i],price_round_number)#"></div></td>
                                    <cfif xml_tevkifat_rate>
                                        <td><div class="form-group"><input type="text" name="row_tevkifat_rate#i#" id="row_tevkifat_rate#i#" class="moneybox" readonly="yes" value="#TLFormat(GET_PAYMENT_ROWS.TEVKIFAT_RATE[i],price_round_number)#" onblur="hesapla(#i#,'row_tevkifat_rate');AmountRnd('row_tevkifat_rate#i#',<cfoutput>#price_round_number#</cfoutput>)"></div></td>
                                        <td style="display:none;"><div class="form-group"><input type="text" name="row_tevkifat_amount#i#" id="row_tevkifat_amount#i#" class="boxtext" readonly="yes" value="#TLFormat(GET_PAYMENT_ROWS.TEVKIFAT_AMOUNT[i],price_round_number)#" onblur="hesapla(#i#,'row_tevkifat_amount');AmountRnd('row_tevkifat_amount#i#',<cfoutput>#price_round_number#</cfoutput>)"></div></td>
                                    </cfif>
                                    <cfif xml_payment_rate>
                                        <td title="<cf_get_lang dictionary_id='57648.Kur'>"><div class="form-group"><input type="text" name="row_rate#i#" id="row_rate#i#" value="#TLFormat(get_payment_rows.rate[i])#" class="moneybox" onkeyup="return(FormatCurrency(this,event,4));"></div></td>
                                    </cfif>
                                    <td title="<cf_get_lang dictionary_id='41113.Satır Toplamı'>"><div class="form-group"><input type="text" name="row_total#i#" id="row_total#i#" class="moneybox" value="#TLFormat(GET_PAYMENT_ROWS.ROW_TOTAL[i],price_round_number)#" onblur="AmountRnd('ROW_TOTAL#i#',<cfoutput>#price_round_number#</cfoutput>);" onkeyup="return(FormatCurrency(this,event));" readonly="yes"></div></td>
                                    <cfif x_payment_plan_isk_amount>
                                        <td title="<cf_get_lang dictionary_id='57641.İSK'> <cf_get_lang dictionary_id='57673.Tutar'>"><div class="form-group"><input type="text" name="discount_amount#i#" id="discount_amount#i#" class="moneybox" value="#TLFormat(GET_PAYMENT_ROWS.DISCOUNT_AMOUNT[i])#" validate="float" onblur="return indirim_hesapla(#i#);" onkeyup="return(FormatCurrency(this,event));"></div></td>
                                    <cfelse>
                                        <input type="hidden" name="discount_amount#i#" id="discount_amount#i#" class="moneybox" value="#TLFormat(GET_PAYMENT_ROWS.DISCOUNT_AMOUNT[i])#" validate="float" onblur="return indirim_hesapla(#i#);" onkeyup="return(FormatCurrency(this,event));">
                                    </cfif>
                                    <td title="<cf_get_lang dictionary_id='57641.İSK'>(%)"><div class="form-group"><input type="text" name="discount#i#" id="discount#i#" class="moneybox" value="#TLFormat(GET_PAYMENT_ROWS.DISCOUNT[i])#" onblur="return indirim_hesapla(#i#);" onkeyup="return(FormatCurrency(this,event));"></div></td>
                                    <td title="<cf_get_lang dictionary_id='41114.Net Satır Top'>"><div class="form-group"><input type="text" name="row_net_total#i#" id="row_net_total#i#" class="moneybox" value="#TLFormat(GET_PAYMENT_ROWS.ROW_NET_TOTAL[i],session.ep.our_company_info.rate_round_num)#" onblur="return discount_hesapla(#i#);" onkeyup="return(FormatCurrency(this,event));"></div></td>
                                    <cfif x_payment_plan_kdv_amount>
                                        <cfset nettotal_kdv = GET_PAYMENT_ROWS.ROW_NET_TOTAL[i]*GET_PAYMENT_ROWS.TAX[i]/100>
                                        <cfset nettotal_otv = GET_PAYMENT_ROWS.ROW_NET_TOTAL[i]*GET_PAYMENT_ROWS.OTV[i]/100>
                                        <cfset nettotal_bsmv = GET_PAYMENT_ROWS.BSMV_AMOUNT[i]>
                                        <cfset nettotal_oiv = GET_PAYMENT_ROWS.OIV_AMOUNT[i]>
                                        <cfset nettotal_tevkifat = GET_PAYMENT_ROWS.TEVKIFAT_AMOUNT[i]>
                                        <td title="KDV'li <cf_get_lang dictionary_id='41114.Net Satır Top'>"><div class="form-group"><input type="text" name="row_last_net_total#i#" id="row_last_net_total#i#" class="moneybox" value="#TLFormat(GET_PAYMENT_ROWS.ROW_NET_TOTAL[i]+nettotal_kdv+nettotal_otv+nettotal_bsmv+nettotal_oiv-nettotal_tevkifat)#" onblur="return discount_hesapla(#i#);" onkeyup="return(FormatCurrency(this,event));" readonly="yes"></div></td>
                                    </cfif>
                                    <td class="text-center" title="<cf_get_lang dictionary_id='41110.Toplu Fatr Dah'>"><div class="form-group"><input type="checkbox" name="is_collected_inv#i#" id="is_collected_inv#i#" <cfif GET_PAYMENT_ROWS.IS_COLLECTED_INVOICE[i] eq 1>checked</cfif> onclick="select_row_bill_type(1,#i#);"></div></td>
                                    <td class="text-center" title="<cf_get_lang dictionary_id ='41302.Grup Fatura Dah'>"><div class="form-group"><input type="checkbox" name="is_group_inv#i#" id="is_group_inv#i#" <cfif GET_PAYMENT_ROWS.IS_GROUP_INVOICE[i] eq 1>checked</cfif> onclick="select_row_bill_type(2,#i#);"></div></td>
                                    <td class="text-center" title="<cf_get_lang dictionary_id='41115.Faturalandı'>"><div class="form-group"><input type="checkbox" name="is_billed#i#" id="is_billed#i#" <cfif GET_PAYMENT_ROWS.IS_BILLED[i] eq 1>checked</cfif> onclick="fatura_kontrol(this,#i#);"></div></td>
                                    <td title="<cf_get_lang dictionary_id='41116.Fatura ID'>">
                                        <div class="form-group">
                                            <div class="input-group">
                                                <input type="hidden" name="period_id#i#" id="period_id#i#" value="#GET_PAYMENT_ROWS.PERIOD_ID[i]#">
                                                <input type="text" name="invoice_id#i#" id="invoice_id#i#" value="#GET_PAYMENT_ROWS.INVOICE_ID[i]#" readonly="yes">
                                                <input type="hidden" name="bill_info#i#" id="bill_info#i#">
                                                <cfif len(get_subscription.company_id)>
                                                    <span class="input-group-addon icon-ellipsis" href="javascript://" onclick="javascript:windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_list_bills&field_name=show_pay_plan.bill_info#i#&field_id=show_pay_plan.invoice_id#i#&field_per_id=show_pay_plan.period_id#i#&cat=1&invoice_is_cash=0&comp_id=#attributes.comp_id#&field_is_billed=show_pay_plan.is_billed#i#&subscription_id=#attributes.subscription_id#</cfoutput>','list');"></span>
                                                <cfelse>
                                                    <span class="input-group-addon icon-ellipsis" href="javascript://" onclick="javascript:windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_list_bills&field_name=show_pay_plan.bill_info#i#&field_id=show_pay_plan.invoice_id#i#&field_per_id=show_pay_plan.period_id#i#&cat=1&invoice_is_cash=0&cons_id=#attributes.cons_id#&field_is_billed=show_pay_plan.is_billed#i#&subscription_id=#attributes.subscription_id#</cfoutput>','list');"></span>
                                                </cfif>
                                            </div>
                                        </div>
                                    </td>
                                    <td class="text-center" title="<cf_get_lang dictionary_id='41118.Toplu Prov Oluşturuldu'>"><div class="form-group"><input type="checkbox" name="is_collected_prov#i#" id="is_collected_prov#i#" <cfif GET_PAYMENT_ROWS.IS_COLLECTED_PROVISION[i] eq 1>checked</cfif>></div></td>
                                    <td class="text-center" title="<cf_get_lang dictionary_id='41117.Ödendi'>">
                                        <div class="form-group">
                                            <input type="checkbox" name="is_paid#i#" id="is_paid#i#" onclick="cari_kontrol(this,#i#);" <cfif GET_PAYMENT_ROWS.IS_PAID[i] eq 1>checked</cfif>>
                                            <cfif x_payment_plan_revenue_info and len(GET_PAYMENT_ROWS.CARI_ACT_TYPE[i]) and GET_PAYMENT_ROWS.IS_PAID[i] eq 1>
                                                <cfset type = ''>
                                                <cfswitch expression = "#GET_PAYMENT_ROWS.CARI_ACT_TYPE[i]#">
                                                    <cfcase value="24"><cfset type="ch.popup_dsp_gelenh&period_id=#GET_PAYMENT_ROWS.CARI_PERIOD_ID[i]#"></cfcase>
                                                    <cfcase value="31"><cfset type="ch.popup_dsp_cash_revenue&period_id=#GET_PAYMENT_ROWS.CARI_PERIOD_ID[i]#"></cfcase>
                                                    <cfcase value="42"><cfset type="ch.popup_print_upd_debit_claim_note&period_id=#GET_PAYMENT_ROWS.CARI_PERIOD_ID[i]#"></cfcase>
                                                    <cfcase value="43"><cfset type="objects.popup_cari_action&period_id=#GET_PAYMENT_ROWS.CARI_PERIOD_ID[i]#"></cfcase>
                                                    <cfcase value="90"><cfset type="ch.popup_dsp_payroll_entry&period_id=#GET_PAYMENT_ROWS.CARI_PERIOD_ID[i]#"></cfcase>
                                                    <cfcase value="97"><cfset type="ch.popup_dsp_voucher_payroll_action&period_id=#GET_PAYMENT_ROWS.CARI_PERIOD_ID[i]#"></cfcase>
                                                    <cfcase value="241"><cfset type="ch.popup_dsp_credit_card_payment_type"></cfcase>
                                                    <cfcase value="251"><cfset type="bank.popup_dsp_assign_order&period_id=#GET_PAYMENT_ROWS.CARI_PERIOD_ID[i]#"></cfcase>
                                                </cfswitch>
                                                <cfif listfind('24,31,32,241,242,251,43',GET_PAYMENT_ROWS.CARI_ACT_TYPE[i],',')>
                                                    <cfset page_type = 'small'>
                                                <cfelse>
                                                    <cfset page_type = 'page'>
                                                </cfif>
                                                <cfif GET_PAYMENT_ROWS.CARI_ACT_TABLE[i] is 'CHEQUE'> 
                                                    <a class="tableyazi" href="javascript://" onclick="windowopen('#request.self#?fuseaction=objects.popup_cheque_det&ID=#GET_PAYMENT_ROWS.CARI_ACT_ID[i]#&period_id=#GET_PAYMENT_ROWS.CARI_PERIOD_ID[i]#','small')">
                                                    <img src="/images/ship_list.gif" border="0" align="absmiddle">
                                                    </a>
                                                <cfelseif GET_PAYMENT_ROWS.CARI_ACT_TABLE[i] is 'VOUCHER'> 
                                                    <a class="tableyazi" href="javascript://" onclick="windowopen('#request.self#?fuseaction=objects.popup_voucher_det&ID=#GET_PAYMENT_ROWS.CARI_ACT_ID[i]#&period_id=#GET_PAYMENT_ROWS.CARI_PERIOD_ID[i]#','small')">
                                                    <img src="/images/ship_list.gif" border="0" align="absmiddle">
                                                    </a>
                                                <cfelse>													
                                                    <a class="tableyazi" href="javascript://" onclick="windowopen('#request.self#?fuseaction=#type#&id=#GET_PAYMENT_ROWS.CARI_ACT_ID[i]#','#page_type#');" title="İşlem Detayı">
                                                    <img src="/images/ship_list.gif" border="0" align="absmiddle">
                                                    </a>
                                                </cfif>
                                            <cfelse>
                                            </cfif>
                                        </div>
                                    </td>
                                    <cfif x_payment_plan_revenue_info>
                                    <td title="<cf_get_lang dictionary_id='41117.Ödendi'>">
                                        <div class="form-group">
                                            <div class="input-group">
                                                <input type="hidden" name="cari_act_type#i#" id="cari_act_type#i#" value="#GET_PAYMENT_ROWS.CARI_ACT_TYPE[i]#">
                                                <input type="hidden" name="cari_act_table#i#" id="cari_act_table#i#" value="#GET_PAYMENT_ROWS.CARI_ACT_TABLE[i]#">
                                                <input type="hidden" name="cari_act_id#i#" id="cari_act_id#i#" value="#GET_PAYMENT_ROWS.CARI_ACT_ID[i]#">
                                                <input type="hidden" name="cari_period_id#i#" id="cari_period_id#i#" value="#GET_PAYMENT_ROWS.CARI_PERIOD_ID[i]#">
                                                <input type="text" name="cari_action_id#i#" id="cari_action_id#i#" value="#GET_PAYMENT_ROWS.CARI_ACTION_ID[i]#" readonly="yes">
                                                <cfif len(get_subscription.company_id)>
                                                    <span class="input-group-addon icon-ellipsis" href="javascript://" onclick="javascript:windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_list_cari_actions&is_paid=show_pay_plan.is_paid#i#&field_id=show_pay_plan.cari_action_id#i#&field_act_id=show_pay_plan.cari_act_id#i#&field_act_type=show_pay_plan.cari_act_type#i#&field_period_id=show_pay_plan.cari_period_id#i#&field_act_table=show_pay_plan.cari_act_table#i#&comp_id=#attributes.comp_id#</cfoutput>','list');"></span>
                                                <cfelse>
                                                    <span class="input-group-addon icon-ellipsis" href="javascript://" onclick="javascript:windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_list_cari_actions&is_paid=show_pay_plan.is_paid#i#&field_id=show_pay_plan.cari_action_id#i#&field_act_id=show_pay_plan.cari_act_id#i#&field_act_type=show_pay_plan.cari_act_type#i#&field_period_id=show_pay_plan.cari_period_id#i#&field_act_table=show_pay_plan.cari_act_table#i#&cons_id=#attributes.cons_id#</cfoutput>','list');"></span>
                                                </cfif>
                                            </div>
                                        </div>
                                    </td>
                                    </cfif>
                                    <cfif x_payment_plan_campaign>
                                        <td title="<cf_get_lang dictionary_id='57446.Kampanya'>">
                                            <div class="form-group">
                                                <div class="input-group">
                                                    <input type="hidden" name="camp_id#i#" id="camp_id#i#" value="#GET_PAYMENT_ROWS.CAMPAIGN_ID[i]#">
                                                    <input type="text" name="camp_name#i#" id="camp_name#i#" class="boxtext" value="<cfif len(GET_PAYMENT_ROWS.CAMPAIGN_ID[i])>#GET_PAYMENT_ROWS.CAMP_HEAD[i]#</cfif>">
                                                    <span class="input-group-addon icon-ellipsis" href="javascript://" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_campaigns&subscription_id=#attributes.subscription_id#&field_id=show_pay_plan.camp_id#i#&field_name=show_pay_plan.camp_name#i#');"></span>
                                                </div>
                                            </div>
                                        </td>
                                    </cfif>
                                    <cfif x_payment_plan_reference>
                                        <td title="<cf_get_lang dictionary_id='58784.Referans'>">
                                            <div class="form-group">
                                                <div class="input-group">
                                                    <input type="hidden" name="subs_ref_id#i#" id="subs_ref_id#i#" value="#get_payment_rows.subs_reference_id[i]#">
                                                    <input type="text" name="subs_ref_name#i#" id="subs_ref_name#i#" class="boxtext" value="<cfif len(get_payment_rows.subscription_no[i])>#get_payment_rows.subscription_no[i]#</cfif>"  maxlength="50" onfocus="AutoComplete_Create('subs_ref_name#i#','SUBSCRIPTION_NO,SUBSCRIPTION_HEAD','SUBSCRIPTION_NO,SUBSCRIPTION_HEAD','get_subscription','2','SUBSCRIPTION_ID','subs_ref_id#i#','','3','150','change_money_info(#i#,100)');" autocomplete="off">
                                                    <span class="input-group-addon icon-ellipsis" href="javascript://" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_list_subscription&field_id=show_pay_plan.subs_ref_id#i#&field_no=show_pay_plan.subs_ref_name#i#&call_money_function=change_money_info(#i#,100)</cfoutput>');"></span>
                                                </div>
                                            </div>
                                        </td>
                                    </cfif>
                                    <cfif x_payment_plan_service>
                                        <td title="<cf_get_lang dictionary_id='57656.Servis'>">
                                            <div class="form-group">
                                                <div class="input-group">
                                                    <input type="hidden" name="service_id#i#" id="service_id#i#"  value="#GET_PAYMENT_ROWS.SERVICE_ID[i]#">
                                                    <input type="text" name="service_no#i#" id="service_no#i#" class="boxtext" value="<cfif len(GET_PAYMENT_ROWS.SERVICE_ID[i])>#GET_PAYMENT_ROWS.SERVICE_NO[i]#</cfif>"  maxlength="50" autocomplete="off">
                                                    <span class="input-group-addon icon-ellipsis" onclick="javascript:openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_list_service&subscription_id=#attributes.subscription_id#&field_id=show_pay_plan.service_id#i#&field_no=show_pay_plan.service_no#i#</cfoutput>');"></span>
                                                </div>
                                            </div>
                                        </td>
                                    </cfif>
                                    <cfif x_payment_plan_call>
                                        <td title="<cf_get_lang dictionary_id='57438.Callcenter'>">
                                            <div class="form-group">
                                                <div class="input-group">
                                                    <input type="hidden" name="call_id#i#" id="call_id#i#"  value="#GET_PAYMENT_ROWS.CALL_ID[i]#">
                                                    <input type="text" name="call_no#i#" id="call_no#i#" class="boxtext" value="<cfif len(GET_PAYMENT_ROWS.CALL_ID[i])>#GET_PAYMENT_ROWS.G_SERVICE_NO[i]#</cfif>"  maxlength="50" autocomplete="off">
                                                    <span class="input-group-addon icon-ellipsis" onclick="javascript:openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_list_service&subscription_id=#attributes.subscription_id#&field_id=show_pay_plan.call_id#i#&field_no=show_pay_plan.call_no#i#&is_callcenter=1</cfoutput>');"></span>
                                                </div>
                                            </div>
                                        </td>
                                     </cfif>
                                     <cfif xml_payment_plan_import_id>
                                        <td nowrap="nowrap">
                                            <cfif isdefined("GET_PAYMENT_ROWS.SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID") and len(GET_PAYMENT_ROWS.SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID[i])>
                                                <a href="#request.self#?fuseaction=sales.list_subscription_payment_plan_import&event=upd&import_id=#GET_PAYMENT_ROWS.SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID[i]#" target="_blank">#GET_PAYMENT_ROWS.SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID[i]#</a>
                                            </cfif>
                                        </td>
                                    </cfif>
                                    <td>
                                        <cfif GET_PAYMENT_ROWS.IS_COUNTER eq 1>
                                            <a href="#request.self#?fuseaction=sales.counter_meter&event=upd&cm_id=#GET_PAYMENT_ROWS.CM_ID#" target="_blank"><i class="icon-detail"></i></a>
                                        </cfif>
                                    </td>
                                    <td>
                                        <cfif len(GET_PAYMENT_ROWS.OUR_COMPANY_ID)>
                                            <cfquery name="get_comp_name" datasource="#dsn#">
                                                SELECT COMPANY_NAME FROM OUR_COMPANY WHERE COMP_ID = #GET_PAYMENT_ROWS.OUR_COMPANY_ID#
                                            </cfquery>
                                            #get_comp_name.COMPANY_NAME#
                                        </cfif>
                                    </td>
                                    <cfif x_payment_plan_record_info>
                                        <td title="<cf_get_lang dictionary_id='57483.Kayıt'>">
                                        <cfif len(GET_PAYMENT_ROWS.RECORD_EMP_NAME[i])>
                                            #GET_PAYMENT_ROWS.RECORD_EMP_NAME[i]# -  <cfif len(GET_PAYMENT_ROWS.RECORD_DATE[i])> #dateformat(dateadd('h',session.ep.time_zone,GET_PAYMENT_ROWS.RECORD_DATE[i]),dateformat_style)# (#timeformat(GET_PAYMENT_ROWS.RECORD_DATE[i],timeformat_style)#)</cfif>
                                        </cfif>
                                        </td>
                                        <td title="<cf_get_lang dictionary_id='57891.Güncelleyen'>">
                                        <cfif len(GET_PAYMENT_ROWS.UPDATE_EMP_NAME[i])>
                                            #GET_PAYMENT_ROWS.UPDATE_EMP_NAME[i]# - #dateformat(dateadd('h',session.ep.time_zone,GET_PAYMENT_ROWS.UPDATE_DATE[i]),dateformat_style)# (#timeformat(GET_PAYMENT_ROWS.UPDATE_DATE[i],timeformat_style)#)
                                        </cfif>
                                        </td>
                                    </cfif> 
                                    </tr>
                                    </cfoutput>		
                                </cfif>
                                </cfloop>
                            <cfelse>
                                <tr>
                                    <td colspan="40" id="kayit_yok"><cf_get_lang dictionary_id='57484.Kayıt Yok'></td>
                                </tr>
                            </cfif>
                        </tbody>
                    </cf_grid_list>
                    <cf_box_footer> 
                         <cfif isdefined("get_payment_rows_invoice.recordcount") and len(get_payment_rows_invoice.recordcount)>
                            <div id="workcube_button" class="pull-right">
                                <input type="button" onclick="fatura_kes()" value="<cf_get_lang dictionary_id='41175.Fatura Kes'>">
                            </div>
                        </cfif>
                        <cfif not(xml_control_payment_rows eq 1 and control_prov_rows.recordcount gt 0)>
                            <cf_workcube_buttons is_upd='0' add_function='control_input()'>
                        </cfif> 
                    </cf_box_footer>
            </cfform> 
            <cfif attributes.totalrecords gt attributes.maxrows>
                <cfset adres="sales.subscription_payment_plan&event=add">
                <cfif isdefined("attributes.amount") and len(attributes.amount)>
                    <cfset adres="#adres#&amount=#attributes.amount#">
                </cfif>
                <cfif isdefined("attributes.row_finish_date") and len(attributes.row_finish_date)>
                    <cfset adres = "#adres#&row_finish_date=#attributes.row_finish_date#">
                </cfif>
                <cfif isdefined("attributes.paymethod") and len(attributes.paymethod)>
                    <cfset adres = "#adres#&paymethod=#attributes.paymethod#" >
                </cfif>
                <cfif isdefined("attributes.paymethod_id") and len(attributes.paymethod_id)>
                    <cfset adres = "#adres#&paymethod_id=#attributes.paymethod_id#" >
                </cfif>
                <cfif isdefined("attributes.card_paymethod_id") and len(attributes.card_paymethod_id)>
                    <cfset adres="#adres#&card_paymethod_id=#attributes.card_paymethod_id#">
                </cfif>
                <cfif isdefined("attributes.product_name") and len(attributes.product_name)>
                    <cfset adres="#adres#&product_name=#attributes.product_name#">
                </cfif>
                <cfif isdefined("attributes.product_id") and len(attributes.product_id)>
                    <cfset adres="#adres#&product_id=#attributes.product_id#">
                </cfif>
                <cfif isdefined("attributes.stock_id") and len(attributes.stock_id)>
                    <cfset adres="#adres#&stock_id=#attributes.stock_id#">
                </cfif>
                <cfif isdefined("attributes.count") and len(attributes.count)>
                    <cfset adres="#adres#&count=#attributes.count#">
                </cfif>
                <cfif isdefined("attributes.quantity") and len(attributes.quantity)>
                    <cfset adres="#adres#&quantity=#attributes.quantity#">
                </cfif>
                
                <cfif isdefined("attributes.discount") and len(attributes.discount)>
                    <cfset adres="#adres#&discount=#attributes.discount#">
                </cfif>
                <cfif isdefined("attributes.net_amount") and len(attributes.net_amount)>
                    <cfset adres="#adres#&net_amount=#attributes.net_amount#">
                </cfif>
                <cfif isdefined("attributes.unit") and len(attributes.unit)>
                    <cfset adres="#adres#&unit=#attributes.unit#">
                </cfif>
                <cfif isdefined("attributes.unit_id") and len(attributes.unit_id)>
                    <cfset adres="#adres#&unit_id=#attributes.unit_id#">
                </cfif>
                <cfif isdefined("attributes.start_date") and len(attributes.start_date)>
                    <cfset adres="#adres#&start_date=#attributes.start_date#">
                </cfif>
                <cfif isdefined("attributes.period") and len(attributes.period)>
                    <cfset adres="#adres#&period=#attributes.period#">
                </cfif>
                <cfif isdefined("attributes.money_type") and len(attributes.money_type)>
                    <cfset adres="#adres#&money_type=#attributes.money_type#">
                </cfif>
                <cfif isdefined("attributes.comp_id") and len(attributes.comp_id)>
                    <cfset adres="#adres#&comp_id=#attributes.comp_id#">
                </cfif>
                <cfif isdefined("attributes.cons_id") and len(attributes.cons_id)>
                    <cfset adres="#adres#&cons_id=#attributes.cons_id#">
                </cfif>
                <cfif isdefined("attributes.row_status")>
                    <cfset adres="#adres#&row_status=#attributes.row_status#">
                </cfif>
                <cfif isdefined("attributes.subscription_id") and len(attributes.subscription_id)>
                    <cfset adres="#adres#&subscription_id=#attributes.subscription_id#">
                </cfif>
                <cfif isdefined("attributes.xml_filter_row") and len(attributes.xml_filter_row)>
                    <cfset adres="#adres#&xml_filter_row=#attributes.xml_filter_row#">
                </cfif>
                <cfif isdefined("attributes.row_product_id") and len(attributes.row_product_id)>
                    <cfset adres="#adres#&row_product_id=#attributes.row_product_id#">
                </cfif>
                <cfif isdefined("attributes.row_product_name") and len(attributes.row_product_name)>
                    <cfset adres="#adres#&row_product_name=#attributes.row_product_name#">
                </cfif>
                <cfif isdefined("attributes.row_card_paymethod_id") and len(attributes.row_card_paymethod_id)>
                    <cfset adres="#adres#&row_card_paymethod_id=#attributes.row_card_paymethod_id#">
                </cfif>
                <cfif isdefined("attributes.row_paymethod") and len(attributes.row_paymethod)>
                    <cfset adres="#adres#&row_paymethod=#attributes.row_paymethod#">
                </cfif>
                <cfif isdefined("attributes.row_invoice_type") and len(attributes.row_invoice_type)>
                    <cfset adres="#adres#&row_invoice_type=#attributes.row_invoice_type#">
                </cfif>
                <cfif isdefined("attributes.row_bill_type") and len(attributes.row_bill_type)>
                    <cfset adres="#adres#&row_bill_type=#attributes.row_bill_type#">
                </cfif>
                <cfif isdefined("attributes.row_prov_type") and len(attributes.row_prov_type)>
                    <cfset adres="#adres#&row_prov_type=#attributes.row_prov_type#">
                </cfif>
                <cfif isdefined("attributes.row_camp_id") and len(attributes.row_camp_id)>
                    <cfset adres="#adres#&row_camp_id=#attributes.row_camp_id#">
                </cfif>
                <cfif isdefined("attributes.row_camp_name") and len(attributes.row_camp_name)>
                    <cfset adres="#adres#&row_camp_name=#attributes.row_camp_name#">
                </cfif>
                <cfif isdefined("attributes.row_subs_ref_id") and len(attributes.row_subs_ref_id)>
                    <cfset adres="#adres#&row_subs_ref_id=#attributes.row_subs_ref_id#">
                </cfif>
                <cfif isdefined("attributes.row_subs_ref_name") and len(attributes.row_subs_ref_name)>
                    <cfset adres="#adres#&row_subs_ref_name=#attributes.row_subs_ref_name#">
                </cfif>
                <cfif isdefined("attributes.row_service_id") and len(attributes.row_service_id)>
                    <cfset adres="#adres#&row_service_id=#attributes.row_service_id#">
                </cfif>
                <cfif isdefined("attributes.row_service_no") and len(attributes.row_service_no)>
                    <cfset adres="#adres#&row_service_no=#attributes.row_service_no#">
                </cfif>
                <cfif isdefined("attributes.row_call_id") and len(attributes.row_call_id)>
                    <cfset adres="#adres#&row_call_id=#attributes.row_call_id#">
                </cfif>
                <cfif isdefined("attributes.row_call_no") and len(attributes.row_call_no)>
                    <cfset adres="#adres#&row_call_no=#attributes.row_call_no#">
                </cfif>
                <cfif isdefined("attributes.row_money_type") and len(attributes.row_money_type)>
                    <cfset adres="#adres#&row_money_type=#attributes.row_money_type#">
                </cfif>
                <cfif isdefined("attributes.row_amount") and len(attributes.row_amount)>
                    <cfset adres="#adres#&row_amount=#attributes.row_amount#">
                </cfif>
                <cfif isdefined("attributes.row_pay_type") and len(attributes.row_pay_type)>
                    <cfset adres="#adres#&row_pay_type=#attributes.row_pay_type#">
                </cfif>
                <cfif isdefined("attributes.subs_no") and len(attributes.subs_no)>
                    <cfset adres="#adres#&subs_no=#attributes.subs_no#">
                </cfif>
                <cfif isdefined("attributes.count_camp") and len(attributes.count_camp)>
                    <cfset adres="#adres#&count_camp=#attributes.count_camp#">
                </cfif>
                <cfif isdefined("attributes.record_num") and len(attributes.record_num)>
                    <cfset adres="#adres#&record_num=#attributes.record_num#">
                </cfif>
                <cfif isdefined("attributes.record") and len(attributes.record)>
                    <cfset adres="#adres#&record=#attributes.record#">
                </cfif>
                <cfif isdefined("attributes.xml_change_row") and len(attributes.xml_change_row)>
                    <cfset adres="#adres#&xml_change_row=#attributes.xml_change_row#">
                </cfif>
                <cf_paging page="#attributes.page#" 
                maxrows="#attributes.maxrows#"
                totalrecords="#attributes.totalrecords#"
                startrow="#attributes.startrow#" 
                adres="#adres#">
            </cfif>
        </cf_box>
    </div>
    <!--- Fatura Ekleme icin eklenen form--->
    <form name="add_invoice" method="post" action="<cfoutput>#request.self#</cfoutput>?fuseaction=invoice.form_add_bill">
        <cfif len(get_subscription.invoice_company_id)>
            <input type="hidden" name="company_id" id="company_id" value="<cfoutput>#get_subscription.invoice_company_id#</cfoutput>">
            <input type="hidden" name="partner_id" id="partner_id" value="<cfoutput>#get_subscription.invoice_partner_id#</cfoutput>">
            <input type="hidden" name="comp_name" id="comp_name" value="<cfoutput>#get_par_info(get_subscription.invoice_company_id,1,1,0)#</cfoutput>">
            <input type="hidden" name="consumer_id" id="consumer_id" value="">
            <input type="hidden" name="partner_name" id="partner_name" value="<cfoutput>#get_par_info(get_subscription.invoice_partner_id,0,-1,0)#</cfoutput>">
            <input type="hidden" name="member_account_code" id="member_account_code" value="<cfoutput>#get_company_period(get_subscription.invoice_company_id)#</cfoutput>">
        <cfelse>
            <input type="hidden" name="company_id" id="company_id" value="">
            <input type="hidden" name="partner_id" id="partner_id" value="">
            <input type="hidden" name="comp_name" id="comp_name" value="">
            <input type="hidden" name="consumer_id" id="consumer_id" value="<cfoutput>#get_subscription.invoice_consumer_id#</cfoutput>">
            <input type="hidden" name="partner_name" id="partner_name" value="<cfoutput>#get_cons_info(get_subscription.invoice_consumer_id,0,0)#</cfoutput>">
            <input type="hidden" name="member_account_code" id="member_account_code" value="<cfoutput>#get_consumer_period(get_subscription.invoice_consumer_id)#</cfoutput>">
        </cfif><cfoutput>
        <input type="hidden" name="city_id" id="city_id" value="#get_subscription.invoice_city_id#">
        <input type="hidden" name="county_id" id="county_id" value="#get_subscription.invoice_county_id#">
        <input type="hidden" name="adres" id="adres" value="#get_subscription.invoice_address# #get_subscription.invoice_postcode# #get_subscription.invoice_semt#">
        <input type="hidden" name="subscription_id" id="subscription_id" value="<cfoutput>#get_subscription.subscription_id#</cfoutput>">
        <input type="hidden" name="list_payment_row_id" id="list_payment_row_id" value="">
        </cfoutput>
        <!--- faturalanmamis satirlarin tek tek faturalanması icin --->
    </form>
    <script language="JavaScript">
        var price_round_number = <cfoutput>#price_round_number#</cfoutput>;
              
    function wrk_select_change()
    {
        new_toplam = parseFloat(document.payment_plan.count_camp.value) + parseFloat(document.payment_plan.count.value) + parseFloat(document.payment_plan.record_num.value);
        for(var zz=<cfoutput>#attributes.startrow#</cfoutput>; zz<=new_toplam; zz++)
        {
            if(document.getElementById("is_change"+zz) != undefined)
            {
                if(document.getElementById("is_change_main").checked == true)
                    document.getElementById("is_change"+zz).checked = true;
                else
                    document.getElementById("is_change"+zz).checked = false;
            }
        }
    }
    
    function apply_row(type)
    {
        toplam = parseFloat(document.payment_plan.count_camp.value) + parseFloat(document.payment_plan.count.value) + parseFloat(document.payment_plan.record_num.value);
        for(var zz=<cfoutput>#attributes.startrow#</cfoutput>; zz<=toplam; zz++)
        {
            if(document.getElementById("is_change"+zz) != undefined && document.getElementById("is_change"+zz).checked == true)
            {
                if(type == 1)//aktif pasif
                {
                    if(document.getElementById('main_status').checked == true)
                        document.getElementById('is_active'+zz).checked = true;
                    else
                        document.getElementById('is_active'+zz).checked = false;
                }
                else if(type == 2)//start date
                {
                    
                    if(document.getElementById('main_start_date').value != '')
                        
                        document.getElementById('payment_date'+zz).value = document.getElementById('main_start_date').value;
                        
                }
                else if(type == 3)//ürün
                {
                    if(document.getElementById('main_product_id').value != '' && document.getElementById('main_product_name').value != '')
                    {
                        document.getElementById('product_id'+zz).value = document.getElementById('main_product_id').value;
                        document.getElementById('stock_id'+zz).value = document.getElementById('main_stock_id').value;
                        document.getElementById('unit_id'+zz).value = document.getElementById('main_unit_id').value;
                        document.getElementById('unit'+zz).value = document.getElementById('main_unit').value;
                        document.getElementById('detail'+zz).value = document.getElementById('main_product_name').value;
                    }
                }
                else if(type == 4)//ödeme yöntemi
                {
                    if(document.getElementById('main_paymethod').value != '')
                    {
                        document.getElementById('card_paymethod_id'+zz).value = document.getElementById('main_card_paymethod_id').value;
                        document.getElementById('paymethod_id'+zz).value = document.getElementById('main_paymethod_id').value;
                        document.getElementById('paymethod'+zz).value = document.getElementById('main_paymethod').value;
                    }
                }
                else if(type == 5)//miktar
                {
                    if(document.getElementById('main_quantity').value != '')
                    {
                        document.getElementById('quantity'+zz).value = document.getElementById('main_quantity').value;
                        hesapla(zz);
                    }
                }
                else if(type == 6)//tutar
                {
                    if(document.getElementById('main_amount_type').value == 3)
                        document.getElementById('amount'+zz).value = commaSplit(filterNum(document.getElementById('main_amount').value));
                    else if(document.getElementById('main_amount_type').value == 1)
                        document.getElementById('amount'+zz).value = commaSplit(parseFloat(filterNum(document.getElementById('amount'+zz).value)-filterNum(document.getElementById('main_amount').value)));
                    else if(document.getElementById('main_amount_type').value == 2)
                        document.getElementById('amount'+zz).value = commaSplit(parseFloat(filterNum(document.getElementById('amount'+zz).value))+parseFloat(filterNum(document.getElementById('main_amount').value)));
                    hesapla(zz);
                }
                else if(type == 7)//para birimi
                {
                    if(document.getElementById('main_money_type').value != '')
                        document.getElementById('money_type_row'+zz).value = document.getElementById('main_money_type').value;
                }
                else if(type == 8)//iskonto
                {
                    if(document.getElementById('main_discount').value != '')
                    {
                        document.getElementById('discount'+zz).value = document.getElementById('main_discount').value;
                        hesapla(zz);
                    }
                }
                else if(type == 9)//iskonto tutar
                {
                    if(document.getElementById('main_discount_amount').value != '')
                    {
                        document.getElementById('discount_amount'+zz).value = document.getElementById('main_discount_amount').value;
                        hesapla(zz);
                    }
                }
                else if(type == 10)//toplu fatura
                {
                    if(document.getElementById('main_is_collected_inv').checked == true)
                    {
                        document.getElementById('is_collected_inv'+zz).checked = true;
                        document.getElementById('is_group_inv'+zz).checked = false;
                    }
                    else
                        document.getElementById('is_collected_inv'+zz).checked = false;
                }
                else if(type == 11)//grup fatura
                {
                    if(document.getElementById('main_is_group_inv').checked == true)
                    {
                        document.getElementById('is_group_inv'+zz).checked = true;
                        document.getElementById('is_collected_inv'+zz).checked = false;
                    }
                    else
                        document.getElementById('is_group_inv'+zz).checked = false;
                }
                else if(type == 12)//toplu provizyon
                {
                    if(document.getElementById('main_is_collected_prov').checked == true)
                        document.getElementById('is_collected_prov'+zz).checked = true;
                    else
                        document.getElementById('is_collected_prov'+zz).checked = false;
                }
                else if(type == 13)//kampanya
                {
                    if(document.getElementById('main_camp_id') != undefined && document.getElementById('main_camp_id').value != '' && document.getElementById('main_camp_name').value != '')
                    {
                        if(document.getElementById('camp_id'+zz) != undefined)
                        {
                            document.getElementById('camp_id'+zz).value = document.getElementById('main_camp_id').value;
                            document.getElementById('camp_name'+zz).value = document.getElementById('main_camp_name').value;
                        }
                    }
                }
                else if(type == 14)//referans
                {
                    if(document.getElementById('main_subs_ref_id').value != '' && document.getElementById('main_subs_ref_name').value != '')
                    {
                        document.getElementById('subs_ref_id'+zz).value = document.getElementById('main_subs_ref_id').value;
                        document.getElementById('subs_ref_name'+zz).value = document.getElementById('main_subs_ref_name').value;
                    }
                }
                else if(type == 15)//servis
                {
                    if(document.show_pay_plan.main_service_id.value != '' && document.show_pay_plan.main_service_no.value != '')
                    {
                        document.getElementById('service_id'+zz).value = document.show_pay_plan.main_service_id.value;
                        document.getElementById('service_no'+zz).value = document.show_pay_plan.main_service_no.value;
                    }
                }
                else if(type == 16)//call center
                {
                    if(document.show_pay_plan.main_call_id.value != '' && document.show_pay_plan.main_call_no.value != '')
                    {
                        document.getElementById('call_id'+zz).value = document.show_pay_plan.main_call_id.value;
                        document.getElementById('call_no'+zz).value = document.show_pay_plan.main_call_no.value;
                    }
                }
                else if(type == 17)//finish date
                {
                    if(document.show_pay_plan.main_finish_date.value != '')
                        document.getElementById('payment_finish_date'+zz).value = document.show_pay_plan.main_finish_date.value;
                }
                else if(type == 18)//satirda kur bilgisi
                {
                    if(document.getElementById("main_rate").value != '')
                        document.getElementById("row_rate"+zz).value = document.getElementById("main_rate").value;
                }
                else if(type == 19)//tahsilat bilgisi
                {
                    if(document.getElementById("main_cari_act_type").value != '')
                        document.getElementById("cari_act_type"+zz).value = document.getElementById("main_cari_act_type").value;
                    else
                        document.getElementById("cari_act_type"+zz).value = '';
                    if(document.getElementById("main_cari_act_table").value != '')
                        document.getElementById("cari_act_table"+zz).value = document.getElementById("main_cari_act_table").value;
                    else
                        document.getElementById("cari_act_table"+zz).value = '';
                    if(document.getElementById("main_cari_act_id").value != '')
                        document.getElementById("cari_act_id"+zz).value = document.getElementById("main_cari_act_id").value;
                    else
                        document.getElementById("cari_act_id"+zz).value = '';
                    if(document.getElementById("main_cari_period_id").value != '')
                        document.getElementById("cari_period_id"+zz).value = document.getElementById("main_cari_period_id").value;
                    else
                        document.getElementById("cari_period_id"+zz).value = '';
                    if(document.getElementById("main_cari_action_id").value != '')
                        document.getElementById("cari_action_id"+zz).value = document.getElementById("main_cari_action_id").value;
                    else
                        document.getElementById("cari_action_id"+zz).value = '';
                }
                else if(type == 20)//ödendi
                {
                    if(document.getElementById('main_is_paid').checked == true)
                        document.getElementById('is_paid'+zz).checked = true;
                    else
                        document.getElementById('is_paid'+zz).checked = false;
                }
            }
        }
    }
    function fatura_kontrol(nesne,sayi)
    {
        if(nesne.checked==false){
            var invoice_check=eval('document.show_pay_plan.invoice_id'+sayi);
            invoice_check.value='';
        }else{
            nesne.checked=false;
            <cfif len(get_subscription.company_id)>
                windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_list_bills&subscription_id=#attributes.subscription_id#&field_name=show_pay_plan.bill_info'+sayi+'&field_id=show_pay_plan.invoice_id'+sayi+'&field_per_id=show_pay_plan.period_id'+sayi+'&cat=1&invoice_is_cash=0&comp_id=#attributes.comp_id#&field_is_billed=show_pay_plan.is_billed'+sayi+'</cfoutput>','list');
            <cfelse>
                windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_list_bills&subscription_id=#attributes.subscription_id#&field_name=show_pay_plan.bill_info'+sayi+'&field_id=show_pay_plan.invoice_id'+sayi+'&field_per_id=show_pay_plan.period_id'+sayi+'&cat=1&invoice_is_cash=0&cons_id=#attributes.cons_id#&field_is_billed=show_pay_plan.is_billed'+sayi+'</cfoutput>','list');
            </cfif>
        }
    }
    function cari_kontrol(nesne,sayi)
    {
        <cfif x_payment_plan_revenue_info>
            if(sayi > 0)
            {
                if(nesne.checked==false){
                    var cari_check=eval('document.show_pay_plan.cari_action_id'+sayi);
                    cari_check.value='';
                }else{
                    <cfif power_user_info neq 1>
                        nesne.checked=false;
                        <cfif len(get_subscription.company_id)>
                            windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_list_cari_actions&is_paid=show_pay_plan.is_paid'+sayi+'&field_id=show_pay_plan.cari_action_id'+sayi+'&field_act_type=show_pay_plan.cari_act_type'+sayi+'&field_act_id=show_pay_plan.cari_act_id'+sayi+'&field_period_id=show_pay_plan.cari_period_id'+sayi+'&field_act_table=show_pay_plan.cari_act_table'+sayi+'&comp_id=#attributes.comp_id#</cfoutput>','list');
                        <cfelse>
                            windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_list_cari_actions&is_paid=show_pay_plan.is_paid'+sayi+'&field_id=show_pay_plan.cari_action_id'+sayi+'&field_act_type=show_pay_plan.cari_act_type'+sayi+'&field_act_id=show_pay_plan.cari_act_id'+sayi+'&field_period_id=show_pay_plan.cari_period_id'+sayi+'&field_act_table=show_pay_plan.cari_act_table'+sayi+'&cons_id=#attributes.cons_id#</cfoutput>','list');
                        </cfif>
                    </cfif>
                }
            }
            else
            {
                if(nesne.checked==false)
                {
                    apply_row(20);
                    apply_row(19);
                    var cari_check=eval('document.show_pay_plan.main_cari_action_id');
                    cari_check.value='';
                }else{
                    <cfif power_user_info neq 1>
                        nesne.checked=false;
                        <cfif len(get_subscription.company_id)>
                            windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_list_cari_actions&is_main&is_paid=show_pay_plan.main_is_paid&field_id=show_pay_plan.main_cari_action_id&field_act_type=show_pay_plan.main_cari_act_type&field_act_id=show_pay_plan.main_cari_act_id&field_period_id=show_pay_plan.main_cari_period_id&field_act_table=show_pay_plan.main_cari_act_table&comp_id=#attributes.comp_id#&call_function=apply_row&call_function_param=19</cfoutput>','list');
                        <cfelse>
                            windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_list_cari_actions&is_main&is_paid=show_pay_plan.main_is_paid&field_id=show_pay_plan.main_cari_action_id&field_act_type=show_pay_plan.main_cari_act_type&field_act_id=show_pay_plan.main_cari_act_id&field_period_id=show_pay_plan.main_cari_period_id&field_act_table=show_pay_plan.main_cari_act_table&cons_id=#attributes.cons_id#&call_function=apply_row&call_function_param=19</cfoutput>','list');
                        </cfif>
                    </cfif>
                }
            }
        </cfif>
    }
    function select_bill_type(control_type)
    {
        if(document.payment_plan.top_fat_dah.checked == true && control_type == 1)
        {
            document.payment_plan.grup_fat_dah.checked = false;
        }
        if(document.payment_plan.grup_fat_dah.checked == true && control_type == 2)
        {
            document.payment_plan.top_fat_dah.checked = false;
        }
    }
    function select_row_bill_type(control_type2,row_no_inf)
    {
        if(eval('document.show_pay_plan.is_collected_inv'+row_no_inf).checked == true && control_type2 == 1)
        {
            eval('document.show_pay_plan.is_group_inv'+row_no_inf).checked = false;
        }
        if(eval('document.show_pay_plan.is_group_inv'+row_no_inf).checked == true && control_type2 == 2)
        {
            eval('document.show_pay_plan.is_collected_inv'+row_no_inf).checked = false;
        }
    }
    function kontrol()
    {	
        //Eger kampanya kuralları çalışsın seçilmişse kontrolleri yapmasına gerek yok
        if(!(document.payment_plan.camp_id != undefined && document.payment_plan.is_camp_rules.checked == true))
        {
            if(document.payment_plan.product_id.value == '')
            {
                alert("<cf_get_lang dictionary_id='57725.Ürün Seçiniz'>!");
                return false;
            }
            if(document.payment_plan.count.value == '')
            {
                alert("<cf_get_lang dictionary_id='40968.Tekrar Sayısı Girmelisiniz'>!");
                return false;
            }
            if(document.payment_plan.start_date.value == '')
            {
                alert("<cf_get_lang dictionary_id='58503.Lutfen Tarih Giriniz'>!");
                return false;
            }
            if(document.payment_plan.amount.value == '')
            {
                alert("<cf_get_lang dictionary_id='29535.Tutar Girmelisiniz'>!");
                return false;
            }
            if(document.payment_plan.paymethod.value == '')
            {
                alert("<cf_get_lang dictionary_id ='58027.Ödeme Yöntemi Seçmelisiniz'>!");
                return false;
            }
        }
        
        <cfif xml_save_total_zero eq 0>//FBS
            if(parseFloat(filterNum(document.getElementById("amount").value)) == 0)
            {
                alert("Tutar 0'dan Farklı Olmalıdır!");
                return false;
            }
        </cfif>
            
        <cfif x_control_camp_rules eq 1>
            if(document.payment_plan.camp_id.value != '')
            {
                if(document.payment_plan.is_camp_rules != undefined && document.payment_plan.is_camp_rules.checked == false)
                {
                    alert("Kampanya Operasyon Kuralları Çalışsın Seçeneğini Seçiniz!");
                    return false;
                }
            }
        </cfif>
        if(document.payment_plan.is_camp_rules != undefined && document.payment_plan.is_camp_rules.checked == true)
        {
            if(document.payment_plan.camp_id.value == '')
            {
                alert("Kampanya Seçiniz!");
                return false;
            }
        }
        //Eğer kampanyadan gelmiyorsa standart yukarıdaki bilgileri kullanarak satır eklenir,kampanya seçilmişse kampanya operasyon satırlarına göre eklenir
        if(document.payment_plan.camp_id == undefined || !(document.payment_plan.camp_id.value != '' && document.payment_plan.is_camp_rules.checked == true))
            add_row(document.payment_plan.count.value,document.payment_plan.period[document.payment_plan.period.selectedIndex].value);
        else
        {
            get_camp_info=wrk_safe_query("get_camp_info_for_payment_plan",'dsn3',0,document.all.camp_id.value);
    
            if(get_camp_info.recordcount > 0)
            {
                total_repeat_number = 0;
                for(kk=0;kk<get_camp_info.recordcount;kk++)
                {
                    row_period = get_camp_info.PERIOD[kk];
                    row_product_id = get_camp_info.PRODUCT_ID[kk];
                    row_stock_id = get_camp_info.STOCK_ID[kk];
                    row_product_name = get_camp_info.PRODUCT_NAME[kk];
                    row_unit = get_camp_info.UNIT[kk];
                    row_unit_id = get_camp_info.UNIT_ID[kk];
                    row_tax = get_camp_info.TAX[kk];
                    row_otv = get_camp_info.OTV[kk];
                    row_paymethod = get_camp_info.PAYMETHOD_ID[kk];
                    row_card_paymethod = get_camp_info.CARD_PAYMETHOD_ID[kk];
                    row_currency = get_camp_info.CURRENCY[kk];
                    row_amount = get_camp_info.AMOUNT[kk];
                    row_price = get_camp_info.PRICE[kk];
                    row_discount = get_camp_info.DISCOUNT[kk];
                    row_k_discount = get_camp_info.K_DISCOUNT[kk];
                    row_discount_amount = get_camp_info.DISCOUNT_AMOUNT[kk];
                    row_k_discount_amount = get_camp_info.K_DISCOUNT_AMOUNT[kk];
                    row_repeat_number = get_camp_info.REPEAT_NUMBER[kk];
                    row_free_repeat_number = get_camp_info.FREE_REPEAT_NUMBER[kk];
                    row_camp_id = get_camp_info.CAMP_ID[kk];
                    row_camp_name = get_camp_info.CAMP_HEAD[kk];
                    row_rate = get_camp_info.RATE[kk];
                    period_info = row_period;
                    
                    if(row_paymethod != '')
                    {
                        get_pay_name = wrk_safe_query("get_pay_name_by_paymethod",'dsn',0,row_paymethod);
                        row_paymethod_name = get_pay_name.PAYMETHOD;					
                    }
                    else if(row_card_paymethod != '')
                    {
                        get_pay_name = wrk_safe_query("get_pay_name_by_payment_type",'dsn3',0,row_card_paymethod);
                        row_paymethod_name = get_pay_name.CARD_NO;
                    }
                    else
                    {
                        row_paymethod = document.payment_plan.paymethod_id.value;
                        row_card_paymethod = document.payment_plan.card_paymethod_id.value;
                        row_paymethod_name = document.payment_plan.paymethod.value;
                    }
                    if(period_info == '')period_info = document.payment_plan.period.value;
                    <cfif x_control_camp_product eq 1>
                        if(document.payment_plan.product_id.value != '' && row_product_id == document.payment_plan.product_id.value)
                        {
                            total_repeat_number = parseFloat(total_repeat_number)+parseFloat(row_repeat_number);
                            add_row(row_repeat_number,period_info,row_product_id,row_stock_id,row_product_name,row_unit_id,row_unit,row_paymethod,row_card_paymethod,row_paymethod_name,row_amount,row_price,row_currency,row_camp_id,row_camp_name,row_discount,row_k_discount,row_repeat_number,row_free_repeat_number,kk,row_tax,row_otv,row_discount_amount,row_k_discount_amount,row_rate);
                        }
                        else if(document.payment_plan.product_id.value == '')
                        {
                            total_repeat_number = parseFloat(total_repeat_number)+parseFloat(row_repeat_number);
                            add_row(row_repeat_number,period_info,row_product_id,row_stock_id,row_product_name,row_unit_id,row_unit,row_paymethod,row_card_paymethod,row_paymethod_name,row_amount,row_price,row_currency,row_camp_id,row_camp_name,row_discount,row_k_discount,row_repeat_number,row_free_repeat_number,kk,row_tax,row_otv,row_discount_amount,row_k_discount_amount,row_rate);
                        }
                    <cfelse>	
                        total_repeat_number = parseFloat(total_repeat_number)+parseFloat(row_repeat_number);
                        add_row(row_repeat_number,period_info,row_product_id,row_stock_id,row_product_name,row_unit_id,row_unit,row_paymethod,row_card_paymethod,row_paymethod_name,row_amount,row_price,row_currency,row_camp_id,row_camp_name,row_discount,row_k_discount,row_repeat_number,row_free_repeat_number,kk,row_tax,row_otv,row_discount_amount,row_k_discount_amount,row_rate);
                    </cfif>
                }
                document.payment_plan.count_camp.value = total_repeat_number;
                document.payment_plan.count.value = 0;
            }
        }
        $( "#kayit_yok" ).hide();
        return true;
    }
    
    function add_row(sayi,period,row_product_id,row_stock_id,row_product_name,row_unit_id,row_unit,row_paymethod,row_card_paymethod,row_paymethod_name,row_amount,row_price,row_currency,row_camp_id,row_camp_name,row_discount,row_k_discount,row_repeat_number,row_free_repeat_number,kontrol_row_info,row_tax,row_otv,row_discount_amount,row_k_discount_amount,row_rate,row_bsmv_rate,row_bsmv_amount,row_bsmv_currency,row_oiv_rate,row_oiv_amount,row_tevkifat_rate,row_tevkifat_amount,row_reason_code)
    {
        var yeni_tarih = document.payment_plan.start_date.value;
        var kayit = parseFloat(document.payment_plan.record_num.value);
        var satir = document.payment_plan.record.value;
        if(kontrol_row_info == undefined) kontrol_row_info = 0;
        if(kontrol_row_info == 0)
        {
            if (kayit==0)
                a=parseFloat(satir)+1;
            else
                a=parseFloat(satir)+kayit+1;
            all_count = a + parseFloat(sayi);
        }
        else
        {
            a=parseFloat(satir)+1+kayit;
            all_count = a + parseFloat(sayi);
        }
        var row_count,money_row,newRow,newCell;
        if(kontrol_row_info == 0)
        for(i=1; i<=all_count; i++)
        {
            if(eval("show_pay_plan.row_control"+i) != undefined && document.getElementById("frm_row"+i) != undefined)
            {
                var my_element=eval("show_pay_plan.row_control"+i);
                my_element.value=0;
                var my_element=eval("frm_row"+i);
                my_element.style.display="none";
            }
        }
        if(row_product_id == undefined) row_product_id = document.payment_plan.product_id.value;
        if(row_stock_id == undefined) row_stock_id = document.payment_plan.stock_id.value;
        if(row_product_name == undefined) row_product_name = document.payment_plan.product_name.value;
        if(row_unit_id == undefined) row_unit_id = document.payment_plan.unit_id.value;
        if(row_tax == undefined) row_tax = document.payment_plan.tax.value;
        if(row_otv == undefined) row_otv = document.payment_plan.otv.value;
        if(row_paymethod == undefined) row_paymethod = document.payment_plan.paymethod_id.value;
        if(row_card_paymethod == undefined) row_card_paymethod = document.payment_plan.card_paymethod_id.value;
        if(row_paymethod_name == undefined) row_paymethod_name = document.payment_plan.paymethod.value;
        if(row_unit == undefined) row_unit = document.payment_plan.unit.value;
        if(row_amount == undefined) row_amount = document.payment_plan.quantity.value;
        if(row_price == undefined) row_price = filterNum(document.payment_plan.amount.value,<cfoutput>#price_round_number#</cfoutput>);
        if(row_currency == undefined) row_currency = '';
        if(row_discount == undefined) row_discount = filterNum(document.payment_plan.discount.value);
        if(row_k_discount == undefined) row_k_discount = 0;
        if(row_discount_amount == undefined) row_discount_amount = 0;
        if(row_k_discount_amount == undefined) row_k_discount_amount = 0;
        if(row_repeat_number == undefined) row_repeat_number = 0;
        if(row_free_repeat_number == undefined) row_free_repeat_number = 0;
        if(row_camp_id == undefined) row_camp_id = '';
        if(row_camp_name == undefined) row_camp_name = '';	
        if(row_rate == undefined) row_rate = '';	
        if(row_bsmv_rate == undefined) row_bsmv_rate = 0;
        if(row_bsmv_amount == undefined) row_bsmv_amount = 0;
        if(row_bsmv_currency == undefined) row_bsmv_currency = 0;
        if(row_oiv_rate == undefined) row_oiv_rate = 0;
        if(row_oiv_amount == undefined ) row_oiv_amount = 0;
        if(row_tevkifat_rate == undefined) row_tevkifat_rate = 0;
        if(row_tevkifat_amount == undefined ) row_tevkifat_amount = 0;
        if(row_reason_code == undefined) row_reason_code = 0;
    
        if(document.payment_plan.product_id != undefined && document.payment_plan.product_id.value != ''){
            
            get_prod_info = wrk_safe_query("get_prod_info",'dsn3',0,document.payment_plan.product_id.value);
            row_bsmv_rate = get_prod_info.BSMV;
            row_oiv_rate = get_prod_info.OIV;
            var listParam = document.payment_plan.product_id.value + "*" + "<cfoutput>#session.ep.period_id#</cfoutput>";
			get_prod_reason_code = wrk_safe_query("get_prod_reason_code",'dsn3',0,listParam);
            row_reason_code = get_prod_reason_code.REASON_CODE;
                     
        }
        if(document.payment_plan.camp_id != undefined && document.payment_plan.camp_id.value != '' && document.payment_plan.is_camp_rules.checked == false)
        {
            get_camp_info = wrk_safe_query("get_camp_info",'dsn3',0,document.all.camp_id.value);
            row_camp_id = get_camp_info.CAMP_ID;
            row_camp_name = get_camp_info.CAMP_HEAD;	
        }
        discount_info = 0;
        count_info = 0;
        
        for(row_count=a; row_count<all_count; row_count++)
        {
            kontrol_price = 0;
            var net_satir_toplam = row_price * row_amount;
            var satir_toplam = row_price * row_amount;
            count_info = count_info+1;
            if(document.payment_plan.camp_id != undefined)
                if(count_info > row_repeat_number && document.payment_plan.is_camp_rules.checked == true)
                {
                    row_camp_id = '';
                    row_camp_name = '';
                }
            if(count_info > row_free_repeat_number)
            {
                discount_info = row_discount;
                discount_amount_info = row_discount_amount;
            }
            else
            {
                discount_info = row_k_discount;
                discount_amount_info = row_k_discount_amount;
            }
            var satir_toplam = satir_toplam-(satir_toplam*discount_info/100);
            var satir_toplam = satir_toplam-discount_amount_info;
            if(row_count>a)//İlk Satırda tarih artmasın diye
            {
                if(period == 1)
                    yeni_tarih = date_add('m',+period,yeni_tarih,document.payment_plan.start_date.value);
                else
                    yeni_tarih = date_add('m',+period,yeni_tarih);
            }
            newRow = document.getElementById("table_1").insertRow(document.getElementById("table_1").rows.length);
            newRow.className = 'color-row';
            newRow.setAttribute("name","frm_row" + row_count);
            newRow.setAttribute("id","frm_row" + row_count);		
            newRow.setAttribute("NAME","frm_row" + row_count);
            newRow.setAttribute("ID","frm_row" + row_count);		
            newCell = newRow.insertCell(newRow.cells.length);
            
            <cfif xml_change_row eq 1>
                newCell = newRow.insertCell(newRow.cells.length);
            </cfif>
            newCell = newRow.insertCell(newRow.cells.length);
            newCell = newRow.insertCell(newRow.cells.length);
            newCell.setAttribute("class","text-center");
            newCell.innerHTML = '<div class="form-group"><input type="hidden" name="row_control' + row_count +'" id="row_control' + row_count +'" value="1"><input type="hidden" name="cari_act_table' + row_count +'" id="cari_act_table' + row_count +'" value=""><input type="hidden" name="cari_period_id' + row_count +'" id="cari_period_id' + row_count +'" value=""><input type="hidden" name="cari_act_id' + row_count +'" id="cari_act_id' + row_count +'" value=""><input type="hidden" name="cari_act_type' + row_count +'" id="cari_act_type' + row_count +'" value=""><input type="checkbox" name="is_active' + row_count +'" id="is_active' + row_count +'" checked></div>';
    
            newCell = newRow.insertCell(newRow.cells.length);
            newCell.setAttribute('nowrap','nowrap');
            <cfif x_payment_plan_kdv eq 0>
                newCell.innerHTML = '<div class="form-group"><input type="hidden" name="kdv_rate' + row_count +'" id="kdv_rate' + row_count +'" class=""moneybox"" maxlength="10" value="'+row_tax+'" readonly="yes"></div>';
            </cfif>
            <cfif x_payment_plan_otv eq 0>
                newCell.innerHTML = '<div class="form-group"><input type="hidden" name="otv_rate' + row_count +'" class="moneybox" maxlength="10" value="'+row_otv+'" readonly="yes"></div>';
            </cfif>
            newCell.setAttribute('nowrap','nowrap');
            newCell.innerHTML = '<div class="form-group"><div class="input-group"><input type="text" name="payment_date' + row_count +'" id="payment_date' + row_count +'" class="boxtext" readonly maxlength="10" validate="<cfoutput>#validate_style#</cfoutput>" value="'+yeni_tarih+'"><input type="hidden" name="product_id' + row_count +'" value="'+row_product_id+'"><span class="input-group-addon" id="payment_date'+row_count+'_td"></span></div></div>';
            wrk_date_image('payment_date' + row_count);
    
            <cfif xml_payment_finish_date eq 1>
                newCell = newRow.insertCell(newRow.cells.length);
                newCell.setAttribute('nowrap','nowrap');
                newCell.innerHTML = '<div class="form-group"><div class="input-group"><input type="text" name="payment_finish_date' + row_count +'" id="payment_finish_date' + row_count +'" class="boxtext" maxlength="10" validate="<cfoutput>#validate_style#</cfoutput>" value="'+yeni_tarih+'"><span class="input-group-addon" id="payment_finish_date'+row_count+'_td"></span></div></div>';
                wrk_date_image('payment_finish_date' + row_count);
            </cfif>
            
            newCell = newRow.insertCell(newRow.cells.length);
            newCell.setAttribute('nowrap','nowrap'); 
            newCell.innerHTML = '<div class="form-group"><div class="input-group"><input type="hidden" name="stock_id' + row_count +'" value="'+row_stock_id+'"><input type="hidden" name="unit_id' + row_count +'" value="'+row_unit_id+'"><input type="text" name="detail' + row_count +'" class="moneybox" maxlength="50" value="'+row_product_name+'"><span class="input-group-addon icon-ellipsis" onClick="openBoxDraggable('+"'<cfoutput>#request.self#?fuseaction=objects.popup_product_names</cfoutput>&product_id=show_pay_plan.product_id" + row_count + "&field_id=show_pay_plan.stock_id" + row_count + "&field_unit_name=show_pay_plan.unit" + row_count + "&field_main_unit=show_pay_plan.unit_id" + row_count + "&field_name=show_pay_plan.detail" + row_count + "');"+'"></span><span class="input-group-addon icon-ellipsis" onClick="windowopen('+"'<cfoutput>#request.self#?fuseaction=objects.popup_detail_product</cfoutput>&pid=" + document.payment_plan.product_id.value + "');"+'"></span></div></div>';
    
            newCell = newRow.insertCell(newRow.cells.length);
            newCell.setAttribute('nowrap','nowrap');
            newCell.innerHTML = '<div class="form-group"><div class="input-group"><input type="hidden" name="card_paymethod_id' + row_count +'" value="'+row_card_paymethod+'"><input type="hidden" name="paymethod_id' + row_count +'" value="'+row_paymethod+'"><input type="text" name="paymethod' + row_count +'" readonly="yes" class="moneybox" maxlength="50" value="'+row_paymethod_name+'"><span class="input-group-addon icon-ellipsis" onClick="openBoxDraggable('+"'<cfoutput>#request.self#?fuseaction=objects.popup_paymethods</cfoutput>&field_id=show_pay_plan.paymethod_id" + row_count + "&field_name=show_pay_plan.paymethod" + row_count + "&field_card_payment_id=show_pay_plan.card_paymethod_id" + row_count + "&field_card_payment_name=show_pay_plan.paymethod" + row_count + "');"+'"></span></div></div>';
    
            newCell = newRow.insertCell(newRow.cells.length);
            newCell.innerHTML = '<div class="form-group"><input type="text" name="unit' + row_count +'" class="moneybox" maxlength="10" value="'+row_unit+'" readonly="yes"></div>';
            
            <cfif x_payment_plan_kdv>
                newCell = newRow.insertCell(newRow.cells.length);
                newCell.innerHTML = '<div class="form-group"><input type="text" name="kdv_rate' + row_count +'" id="kdv_rate'+row_count+'" class="moneybox" maxlength="10" value="'+row_tax+'" readonly="yes"></div>';
            </cfif>
            <cfif x_payment_plan_otv>
                newCell = newRow.insertCell(newRow.cells.length);
                newCell.innerHTML = '<div class="form-group"><input type="text" name="otv_rate' + row_count +'" class="moneybox" maxlength="10" value="'+row_otv+'" readonly="yes"></div>';
            </cfif>
        
            newCell = newRow.insertCell(newRow.cells.length);
            newCell.innerHTML = '<div class="form-group"><input type="text" name="quantity' + row_count +'" id="quantity' + row_count +'" onChange="is_zero(' + row_count + ')" class="box" value="'+row_amount+'" onBlur="return hesapla('+row_count+');"></div>';
    
            newCell = newRow.insertCell(newRow.cells.length);
            newCell.innerHTML = '<div class="form-group"><input type="text" name="amount' + row_count +'" id="amount' + row_count +'" class="moneybox" value="'+commaSplit(row_price,<cfoutput>#price_round_number#</cfoutput>)+'" onBlur="hesapla('+row_count+');AmountRnd(\'amount'+row_count+'\',<cfoutput>#price_round_number#</cfoutput>);"></div>';
            
            newCell = newRow.insertCell(newRow.cells.length);
            c = '<div class="form-group"><select name="money_type_row' + row_count  +'" id="money_type_row' + row_count  +'" class="moneybox">';
            <cfoutput query="get_money">
            if('#money#' == row_currency)
                c += '<option value="#money#" selected>#money#</option>';
            else
                c += '<option value="#money#">#money#</option>';
            </cfoutput>
            newCell.innerHTML =c+ '</select></div>';
        
            newCell = newRow.insertCell(newRow.cells.length);
            newCell.innerHTML = '<div class="form-group"><input type="text" name="row_bsmv_rate' + row_count +'" id="row_bsmv_rate' + row_count +'" class="moneybox" readonly="yes" value="'+commaSplit(row_bsmv_rate,<cfoutput>#price_round_number#</cfoutput>)+'"></div>';
            
            newCell = newRow.insertCell(newRow.cells.length);
            newCell.style.display = 'none';
            newCell.innerHTML = '<div class="form-group"><input type="text" name="row_bsmv_amount' + row_count +'" id="row_bsmv_amount' + row_count +'" class="moneybox" readonly="yes" value="'+commaSplit(row_bsmv_amount,<cfoutput>#price_round_number#</cfoutput>)+'"></div>'; 
    
            newCell = newRow.insertCell(newRow.cells.length);
            newCell.style.display = 'none';
            newCell.innerHTML = '<div class="form-group"><input type="text" name="row_reason_code' + row_count +'" id="row_reason_code' + row_count +'" style="display:none;" class="moneybox" readonly="yes" value="'+row_reason_code+'"></div>';
            
            <!--- newCell = newRow.insertCell(newRow.cells.length);
            newCell.innerHTML = '<input type="text" name="row_bsmv_currency' + row_count +'" id="row_bsmv_currency' + row_count +'" class="box" onkeyup="return(FormatCurrency(this,event));" value="'+commaSplit(row_bsmv_currency)+'" onBlur="hesapla('+row_count+',\'row_bsmv_currency\')">'; 
             --->
    
            newCell = newRow.insertCell(newRow.cells.length);
            newCell.innerHTML = '<div class="form-group"><input type="text" name="row_oiv_rate' + row_count +'" id="row_oiv_rate' + row_count +'" class="moneybox" readonly="yes" onkeyup="return(FormatCurrency(this,event));" value="'+commaSplit(row_oiv_rate,<cfoutput>#price_round_number#</cfoutput>)+'" onBlur="hesapla('+row_count+',\'row_oiv_rate\');AmountRnd(\'row_oiv_rate'+row_count+'\',<cfoutput>#price_round_number#</cfoutput>);"></div>';
            
            newCell = newRow.insertCell(newRow.cells.length);
            newCell.style.display = 'none';
            newCell.innerHTML = '<div class="form-group"><input type="text" name="row_oiv_amount' + row_count +'" id="row_oiv_amount' + row_count +'" class="moneybox" readonly="yes" onkeyup="return(FormatCurrency(this,event));" value="'+commaSplit(row_oiv_amount)+'" onBlur="hesapla('+row_count+',\'row_oiv_amount\');AmountRnd(\'row_oiv_amount'+row_count+'\',<cfoutput>#price_round_number#</cfoutput>);"></div>';
            <cfif xml_tevkifat_rate>
            newCell = newRow.insertCell(newRow.cells.length);
            newCell.innerHTML = '<div class="form-group"><input type="text" name="row_tevkifat_rate' + row_count +'" id="row_tevkifat_rate' + row_count +'" class="moneybox" onkeyup="return(FormatCurrency(this,event));" value="'+commaSplit(row_tevkifat_rate)+'" onBlur="hesapla('+row_count+',\'row_tevkifat_rate\');AmountRnd(\'row_tevkifat_rate'+row_count+'\',<cfoutput>#price_round_number#</cfoutput>);"></div>';
            
            newCell = newRow.insertCell(newRow.cells.length);
            newCell.style.display = 'none';
            newCell.innerHTML = '<div class="form-group"><input type="text" name="row_tevkifat_amount' + row_count +'" id="row_tevkifat_amount' + row_count +'" class="moneybox" onkeyup="return(FormatCurrency(this,event));" value="'+commaSplit(row_tevkifat_amount)+'" onBlur="hesapla('+row_count+',\'row_tevkifat_amount\');AmountRnd(\'row_tevkifat_amount'+row_count+'\',<cfoutput>#price_round_number#</cfoutput>);"></div>';
            </cfif>
            <cfif xml_payment_rate>
                newCell = newRow.insertCell(newRow.cells.length);
                newCell.innerHTML = '<div class="form-group"><input type="text" name="row_rate' + row_count +'" id="row_rate' + row_count +'" class="moneybox" onkeyup="return(FormatCurrency(this,event,4));" value="'+commaSplit(row_rate)+'"></div>';
            </cfif>
            newCell = newRow.insertCell(newRow.cells.length);
            newCell.innerHTML = '<div class="form-group"><input type="text" name="row_total' + row_count +'" id="row_total' + row_count +'" class="moneybox" onkeyup="return(FormatCurrency(this,event));" value="'+commaSplit(net_satir_toplam,<cfoutput>#price_round_number#</cfoutput>)+'"  onBlur="indirim_hesapla('+row_count+');AmountRnd(\'row_total'+row_count+'\',<cfoutput>#price_round_number#</cfoutput>);" readonly="yes"></div>';
            
            <cfif x_payment_plan_isk_amount>
                newCell = newRow.insertCell(newRow.cells.length);
                newCell.innerHTML = '<div class="form-group"><input type="text" name="discount_amount' + row_count +'" id="discount_amount' + row_count +'" class="moneybox" onkeyup="return(FormatCurrency(this,event));" value="'+commaSplit(discount_amount_info)+'" onBlur="return indirim_hesapla('+row_count+');"></div>';
            </cfif>
            
            newCell = newRow.insertCell(newRow.cells.length);
            newCell.innerHTML = '<div class="form-group"><input type="text" name="discount' + row_count +'" id="discount' + row_count +'" class="moneybox" onkeyup="return(FormatCurrency(this,event));" value="'+commaSplit(discount_info)+'" onBlur="return indirim_hesapla('+row_count+');"></div>';
            
            newCell = newRow.insertCell(newRow.cells.length);
            newCell.innerHTML = '<div class="form-group"><input type="text" name="row_net_total' + row_count +'" id="row_net_total' + row_count +'" class="moneybox" onBlur="return discount_hesapla('+row_count+');" value="'+commaSplit(satir_toplam,<cfoutput>#price_round_number#</cfoutput>)+'"></div>';
            
            <cfif x_payment_plan_kdv_amount>
                newCell = newRow.insertCell(newRow.cells.length);
                newCell.innerHTML = '<div class="form-group"><input type="text" name="row_last_net_total' + row_count +'" readonly="yes" class="moneybox" onBlur="return discount_hesapla('+row_count+');" onkeyup="return(FormatCurrency(this,event));" value=""></div>';
            </cfif>
            
            if (document.payment_plan.top_fat_dah.checked)
            {
                newCell = newRow.insertCell(newRow.cells.length);
                newCell.setAttribute("class","text-center");
                newCell.innerHTML = '<div class="form-group"><input type="checkbox" name="is_collected_inv' + row_count +'" checked onClick="select_row_bill_type(1,' + row_count +');"></div>';
            }
            else
            {
                newCell = newRow.insertCell(newRow.cells.length);
                newCell.setAttribute("class","text-center");
                newCell.innerHTML = '<div class="form-group"><input type="checkbox" name="is_collected_inv' + row_count +'" onClick="select_row_bill_type(1,' + row_count +');"></div>';
            }
        
            if (document.payment_plan.grup_fat_dah.checked)
            {
                newCell = newRow.insertCell(newRow.cells.length);
                newCell.setAttribute("class","text-center");
                newCell.innerHTML = '<div class="form-group"><input type="checkbox" name="is_group_inv' + row_count +'" checked onClick="select_row_bill_type(2,' + row_count +');"></div>';
            }
            else
            {
                newCell = newRow.insertCell(newRow.cells.length);
                newCell.setAttribute("class","text-center");
                newCell.innerHTML = '<div class="form-group"><input type="checkbox" name="is_group_inv' + row_count +'" onClick="select_row_bill_type(2,' + row_count +');"></div>';
            }
            
            newCell = newRow.insertCell(newRow.cells.length);
            newCell.setAttribute("class","text-center");
            newCell.innerHTML = '<div class="form-group"><input type="checkbox" name="is_billed' + row_count +'" onClick="fatura_kontrol(this,' + row_count +');"></div>';
            
            newCell = newRow.insertCell(newRow.cells.length);
            newCell.setAttribute('nowrap','nowrap'); 
            newCell.innerHTML = '<div class="form-group"><div class="input-group"><input type="hidden" name="period_id' + row_count +'"><input type="hidden" name="bill_info' + row_count +'"><input type="text" name="invoice_id' + row_count +'" readonly="yes">'+'<cfif len(get_subscription.company_id)><span class="input-group-addon icon-ellipsis" href="javascript://" onClick="windowopen('+"'<cfoutput>#request.self#?</cfoutput>fuseaction=objects.popup_list_bills&subscription_id=<cfoutput>#attributes.subscription_id#</cfoutput>&field_id=show_pay_plan.invoice_id" + row_count + "&field_name=show_pay_plan.bill_info" + row_count + "&field_per_id=show_pay_plan.period_id" + row_count + "&cat=1&invoice_is_cash=0&comp_id=<cfoutput>#attributes.comp_id#&field_is_billed=show_pay_plan.is_billed" + row_count + "</cfoutput>','list');"+'"></span><cfelse><span class="input-group-addon icon-ellipsis" href="javascript://" onClick="windowopen('+"'<cfoutput>#request.self#?</cfoutput>fuseaction=objects.popup_list_bills&subscription_id=<cfoutput>#attributes.subscription_id#</cfoutput>&field_id=show_pay_plan.invoice_id" + row_count + "&field_name=show_pay_plan.bill_info" + row_count + "&field_per_id=show_pay_plan.period_id" + row_count + "&cat=1&invoice_is_cash=0&cons_id=<cfoutput>#get_subscription.consumer_id#</cfoutput>','list');"+'"></span></cfif></div></div>';
    
            newCell = newRow.insertCell(newRow.cells.length);
            newCell.setAttribute("class","text-center");
            newCell.innerHTML = '<div class="form-group"><input type="checkbox" name="is_paid' + row_count +'" onClick="cari_kontrol(this,' + row_count +');"></div>';
            
            newCell = newRow.insertCell(newRow.cells.length);
            newCell.setAttribute("class","text-center");
            newCell.innerHTML = '<div class="form-group"><input type="checkbox" name="is_collected_prov' + row_count +'"></div>';
            document.getElementById('quantity'+row_count).focus();
            <cfif x_payment_plan_revenue_info>
                newCell = newRow.insertCell(newRow.cells.length);
                newCell.setAttribute('nowrap','nowrap'); 
                newCell.innerHTML = '<div class="form-group"><div class="input-group"><input type="text" name="cari_action_id' + row_count +'" readonly="yes"><cfif len(get_subscription.company_id)><span class="input-group-addon icon-ellipsis" href="javascript://" onClick="windowopen('+"'<cfoutput>#request.self#?</cfoutput>fuseaction=objects.popup_list_cari_actions&is_paid=show_pay_plan.is_paid" + row_count + "&field_id=show_pay_plan.cari_action_id" + row_count + "&field_period_id=show_pay_plan.cari_period_id" + row_count + "&field_act_type=show_pay_plan.cari_act_type"+row_count+"&field_act_id=show_pay_plan.cari_act_id"+row_count+"&field_act_table=show_pay_plan.cari_act_table"+row_count+"&comp_id=<cfoutput>#attributes.comp_id#</cfoutput>','list');"+'"></span><cfelse><span class="input-group-addon icon-ellipsis" href="javascript://" onClick="windowopen('+"'<cfoutput>#request.self#?</cfoutput>fuseaction=objects.popup_list_cari_actions&is_paid=show_pay_plan.is_paid" + row_count + "&field_id=show_pay_plan.cari_action_id" + row_count + "&field_period_id=show_pay_plan.cari_period_id" + row_count + "&cons_id=<cfoutput>#get_subscription.consumer_id#</cfoutput>','list');"+'"></span></cfif></div></div>';
            </cfif>
            <cfif x_payment_plan_campaign>
                newCell = newRow.insertCell(newRow.cells.length);
                newCell.setAttribute('nowrap','nowrap');  
                newCell.innerHTML = '<div class="form-group"><div class="input-group"><input type="hidden" name="camp_id' + row_count +'" id="camp_id' + row_count +'" value="'+row_camp_id+'"><input type="text" name="camp_name' + row_count +'" id="camp_name' + row_count +'" class="boxtext" value="'+row_camp_name+'"><span class="input-group-addon icon-ellipsis" href="javascript://" onClick="openBoxDraggable('+"'<cfoutput>#request.self#?fuseaction=objects.popup_list_campaigns&subscription_id=#attributes.subscription_id#</cfoutput>&field_id=show_pay_plan.camp_id" + row_count + "&field_name=show_pay_plan.camp_name" + row_count + "');"+'"></span></div></div>';
            </cfif>
            <cfif x_payment_plan_reference>
                newCell = newRow.insertCell(newRow.cells.length);
                newCell.setAttribute('nowrap','nowrap');  
                newCell.innerHTML = '<div class="form-group"><div class="input-group"><input type="hidden" name="subs_ref_id' + row_count +'" id="subs_ref_id' + row_count +'" value=""><input type="text" name="subs_ref_name' + row_count +'" id="subs_ref_name' + row_count +'" class="boxtext" maxlength="50" value=""  onFocus="auto_comp('+row_count+');" autocomplete="off"><span class="input-group-addon icon-ellipsis" href="javascript://" onClick="openBoxDraggable('+"'<cfoutput>#request.self#?fuseaction=objects.popup_list_subscription</cfoutput>&field_id=show_pay_plan.subs_ref_id" + row_count + "&field_no=show_pay_plan.subs_ref_name" + row_count + "&call_money_function=change_money_info(" + row_count + ",100)');"+'"></span></div></div>';
            </cfif>
            <cfif x_payment_plan_service>
                newCell = newRow.insertCell(newRow.cells.length);
                newCell.setAttribute('nowrap','nowrap');  
                newCell.innerHTML = '<div class="form-group"><div class="input-group"><input type="hidden" name="service_id' + row_count +'" id="service_id' + row_count +'" value=""><input type="text" name="service_no' + row_count +'" id="service_no' + row_count +'" class="boxtext" maxlength="50" value="" autocomplete="off"><span class="input-group-addon icon-ellipsis" href="javascript://" onClick="openBoxDraggable('+"'<cfoutput>#request.self#?fuseaction=objects.popup_list_service&subscription_id=#attributes.subscription_id#</cfoutput>&field_id=show_pay_plan.service_id" + row_count + "&field_no=show_pay_plan.service_no" + row_count + "');"+'"></span></div></div>';
            </cfif>
            <cfif x_payment_plan_call>
                newCell = newRow.insertCell(newRow.cells.length);
                newCell.setAttribute('nowrap','nowrap');  
                newCell.innerHTML = '<div class="form-group"><div class="input-group"><input type="hidden" name="call_id' + row_count +'" id="call_id' + row_count +'" value=""><input type="text" name="call_no' + row_count +'" id="call_no' + row_count +'" class="boxtext" maxlength="50" value="" autocomplete="off"><span class="input-group-addon icon-ellipsis" href="javascript://" onClick="openBoxDraggable('+"'<cfoutput>#request.self#?fuseaction=objects.popup_list_service&subscription_id=#attributes.subscription_id#</cfoutput>&is_callcenter=1&field_id=show_pay_plan.call_id" + row_count + "&field_no=show_pay_plan.call_no" + row_count + "');"+'"></span></div></div>';
            </cfif>
            <cfif xml_payment_plan_import_id>
                newCell = newRow.insertCell(newRow.cells.length);
            </cfif>
            <cfif x_payment_plan_record_info>
                newCell = newRow.insertCell(newRow.cells.length);
                newCell = newRow.insertCell(newRow.cells.length);
            </cfif>
            if(!(document.payment_plan.camp_id != undefined && document.payment_plan.is_camp_rules.checked == true))
            {
                money_row = eval('document.show_pay_plan.money_type_row'+row_count);
                for(var j=0; j<money_row.length; j++)
                {
                    if(money_row[j].value == document.payment_plan.money_type[document.payment_plan.money_type.selectedIndex].value)
                    money_row[j].selected = true;
                }
            }
            indirim_hesapla(row_count,kontrol_price);
            hesapla(row_count);
            AmountRnd('row_bsmv_rate'+row_count,<cfoutput>#price_round_number#</cfoutput>);
            AmountRnd('row_oiv_rate'+row_count,<cfoutput>#price_round_number#</cfoutput>);
        }
        document.payment_plan.record.value=parseFloat(sayi)+ parseFloat(satir);
    }
    function auto_comp(no)
    {
        AutoComplete_Create('subs_ref_name'+no,'SUBSCRIPTION_NO,SUBSCRIPTION_HEAD','SUBSCRIPTION_NO,SUBSCRIPTION_HEAD','get_subscription','2','SUBSCRIPTION_ID','subs_ref_id'+no,'','3','150','change_money_info('+no+',100)');
    }
    var is_add_pay_plan = 0;//çok fazla enter tuşuna basınca sorun oluyordu , o yüzden kontrol eklendi
    function control_input()
    {	
        if(is_add_pay_plan == 0)
        {
            is_add_pay_plan = 1;
            document.show_pay_plan.count.value=document.payment_plan.record.value;
            document.show_pay_plan.count_camp.value=document.payment_plan.count_camp.value;
            document.show_pay_plan.unit.value=document.payment_plan.unit.value;
            document.show_pay_plan.amount.value=document.payment_plan.amount.value;
            document.show_pay_plan.quantity.value=document.payment_plan.quantity.value;
            document.show_pay_plan.start_date.value=document.payment_plan.start_date.value;
            document.show_pay_plan.product_id.value=document.payment_plan.product_id.value;
            document.show_pay_plan.stock_id.value=document.payment_plan.stock_id.value;
            document.show_pay_plan.unit_id.value=document.payment_plan.unit_id.value;
            document.show_pay_plan.money_type.value=document.payment_plan.money_type.value;
            document.show_pay_plan.period.value=document.payment_plan.period.value;
            document.show_pay_plan.paymethod_id.value=document.payment_plan.paymethod_id.value;
            document.show_pay_plan.card_paymethod_id.value=document.payment_plan.card_paymethod_id.value;
            var toplam = parseFloat(document.payment_plan.count_camp.value) + parseFloat(document.payment_plan.record.value) + parseFloat(document.payment_plan.record_num.value);
            if(toplam == 0)
            {
                alert("<cf_get_lang dictionary_id ='41345.Lütfen Satır Ekleyiniz'>!");
                is_add_pay_plan = 0;
                return false;
            }
            count_row = 0;
            for(var zz=<cfoutput>#attributes.startrow#</cfoutput>; zz<=toplam; zz++)
            {
                if((eval("show_pay_plan.row_control"+zz) != undefined && eval("show_pay_plan.row_control"+zz).value == 1) || eval("show_pay_plan.row_control"+zz) == undefined)
                {
                    count_row = count_row+1;
                    if($('#payment_date'+zz) != undefined && $('#payment_date'+zz).val() == '')
                    {
                        alert("<cf_get_lang dictionary_id ='41309.Ödeme Tarihi Giriniz'>! <cf_get_lang dictionary_id='58508.Satır'>: "+count_row);
                        is_add_pay_plan = 0;
                        return false;
                    }
                    <cfif xml_save_total_zero eq 0>//FBS
                        if($('#amount'+zz) != undefined && parseFloat(filterNum($('#amount'+zz).val())) == 0)
                        {
                            alert("<cf_get_lang dictionary_id='62272.Tutar 0 dan farklı olmalıdır'>! <cf_get_lang dictionary_id='58508.Satır'>: "+count_row);
                            is_add_pay_plan = 0;
                            return false;
                        }
                    </cfif>
                    if($('#discount'+zz) != undefined && (filterNum($('#discount'+zz).val()) < 0 || filterNum($('#discount'+zz).val()) > 100))
                    {
                        alert("<cf_get_lang dictionary_id ='57727.İndirim Değeri Hatalı'> <cf_get_lang dictionary_id='58508.Satır'>:!"+count_row);
                        is_add_pay_plan = 0;
                        return false;
                    }
                }
            }
            document.show_pay_plan.process_stage.value=document.payment_plan.process_stage.value;
            if(document.payment_plan.process_stage.value == "")
            {
                alert("<cf_get_lang dictionary_id='57976.Lütfen Süreçlerinizi Tanimlayiniz ve/veya Tanimlanan Süreçler Üzerinde Yetkiniz Yok'> !");
                is_add_pay_plan = 0;
                return false;
            }
            else
                return process_cat_dsp_function();
        }
        else
            return false;
    }
    var row_bsmv_amount , row_bsmv_rate , row_oiv_amount , row_oiv_rate, row_tevkifat_amount , row_tevkifat_rate;
    
    function hesapla(satir_no,id)
    {
        
        
        document.getElementById('row_total'+satir_no).value=commaSplit(filterNum(document.getElementById('amount'+satir_no).value,<cfoutput>#price_round_number#</cfoutput>)*parseFloat(document.getElementById('quantity'+satir_no).value),<cfoutput>#price_round_number#</cfoutput>);
        indirim_hesapla(satir_no);
        
      
    }
    function indirim_hesapla(satir_no,kontrol_price)
    {
      //  alert("caller is " + arguments.callee.caller.toString());
       //alert(document.getElementById('row_total'+satir_no).value);
        if(kontrol_price == undefined) kontrol_price = 0;
        var row_quantity = parseFloat(document.getElementById('quantity'+satir_no).value);
        <cfif x_payment_plan_isk_amount>
            var disc_amount = filterNum(document.getElementById('discount_amount'+satir_no).value) * row_quantity;
        <cfelse>
            var disc_amount = 0;
        </cfif>
        
        var indirim = parseFloat(filterNum(document.getElementById('row_total'+satir_no).value,<cfoutput>#price_round_number#</cfoutput>)-disc_amount) * filterNum(document.getElementById('discount'+satir_no).value)/100;
        var indirim_rate = filterNum(document.getElementById('discount'+satir_no).value);
        var tutar = filterNum(document.getElementById('row_total'+satir_no).value,<cfoutput>#price_round_number#</cfoutput>);
        var row_net_total = filterNum(document.getElementById('row_net_total'+satir_no).value,<cfoutput>#price_round_number#</cfoutput>);
        
        if(kontrol_price == 0)
            document.getElementById('row_net_total'+satir_no).value=commaSplit((tutar - indirim - disc_amount),<cfoutput>#price_round_number#</cfoutput>);
        else
        {
            document.getElementById('row_total'+satir_no).value=commaSplit(row_net_total*100/(100-indirim_rate),<cfoutput>#price_round_number#</cfoutput>);
            document.getElementById('amount'+satir_no).value=commaSplit((row_net_total*100/(100-indirim_rate))/row_quantity,<cfoutput>#session.ep.our_company_info.rate_round_num#</cfoutput>);
        }
        if(document.getElementById("kdv_rate"+satir_no) != undefined)
            new_price_kdv = (filterNum(document.getElementById("row_net_total"+satir_no).value,<cfoutput>#session.ep.our_company_info.rate_round_num#</cfoutput>) * filterNum(document.getElementById("kdv_rate"+satir_no).value,<cfoutput>#session.ep.our_company_info.rate_round_num#</cfoutput>) / 100);
        else
            new_price_kdv = 0 ;
        if(document.getElementById("otv_rate"+satir_no) != undefined)
            new_price_otv = (filterNum(document.getElementById("row_net_total"+satir_no).value,<cfoutput>#session.ep.our_company_info.rate_round_num#</cfoutput>) * filterNum(document.getElementById("otv_rate"+satir_no).value,<cfoutput>#session.ep.our_company_info.rate_round_num#</cfoutput>) / 100);
        else
            new_price_otv = 0 ;
        if(document.getElementById("row_bsmv_rate"+satir_no) != undefined)
            {new_bsmv_price = (filterNum(document.getElementById("row_bsmv_amount"+satir_no).value,<cfoutput>#session.ep.our_company_info.rate_round_num#</cfoutput>));
            }
        else
            new_bsmv_price = 0 ;
        if(document.getElementById("row_oiv_rate"+satir_no) != undefined)
        {
            new_oiv_price = (filterNum(document.getElementById("row_oiv_amount"+satir_no).value,<cfoutput>#session.ep.our_company_info.rate_round_num#</cfoutput>));
        }
        else
            new_oiv_price = 0 ;
        if(document.getElementById("row_tevkifat_rate"+satir_no) != undefined)
            new_tevkifat_price = (filterNum(document.getElementById("row_tevkifat_amount"+satir_no).value,<cfoutput>#session.ep.our_company_info.rate_round_num#</cfoutput>));
        else
            new_tevkifat_price = 0 ;
        if(document.getElementById("row_last_net_total"+satir_no) != undefined)
            document.getElementById("row_last_net_total" + satir_no).value = commaSplit(parseFloat(filterNum(document.getElementById("row_net_total"+satir_no).value))+parseFloat(new_price_kdv)+parseFloat(new_price_otv)+parseFloat(new_bsmv_price)+parseFloat(new_oiv_price)-parseFloat(new_tevkifat_price),<cfoutput>#session.ep.our_company_info.rate_round_num#</cfoutput>);
    
        
        if( document.getElementById('row_bsmv_amount'+satir_no) != undefined ){
            var row_net_total__ = filterNum(document.getElementById('row_net_total'+satir_no).value);
            row_bsmv_amount = (row_net_total__ * filterNum( document.getElementById('row_bsmv_rate'+satir_no).value))  / 100;

            document.getElementById('row_bsmv_amount'+satir_no).value = commaSplit(row_bsmv_amount,<cfoutput>#price_round_number#</cfoutput>);

        }
        if(document.getElementById('row_oiv_amount'+satir_no) != undefined){  
            var row_net_total__ = filterNum(document.getElementById('row_net_total'+satir_no).value); 
            row_oiv_amount = (row_net_total__ * filterNum( document.getElementById('row_oiv_rate'+satir_no).value))  / 100;
            
            document.getElementById('row_oiv_amount'+satir_no).value = commaSplit(row_oiv_amount,<cfoutput>#price_round_number#</cfoutput>);
            
        }
        <cfif xml_tevkifat_rate>
        if(document.getElementById('row_tevkifat_amount'+satir_no+'') != undefined) {
            row_tevkifat_amount = filterNum( document.getElementById('row_tevkifat_amount'+satir_no+'').value );
            row_tevkifat_rate = row_tevkifat_amount * 100 / document.getElementById('kdv_rate'+satir_no+'').value;
    
            document.getElementById('row_tevkifat_rate'+satir_no+'').value = ( row_tevkifat_rate > 0 ) ? commaSplit(row_tevkifat_rate,<cfoutput>#price_round_number#</cfoutput>) : commaSplit(0,<cfoutput>#price_round_number#</cfoutput>);
            document.getElementById('row_tevkifat_amount'+satir_no+'').value = ( row_tevkifat_amount > 0 ) ? commaSplit(row_tevkifat_amount,<cfoutput>#price_round_number#</cfoutput>) : commaSplit(0,<cfoutput>#price_round_number#</cfoutput>);
        }
        </cfif>
    }
    
    function discount_hesapla(satir_no)
    {
        var satir_total = filterNum(document.getElementById('row_total'+satir_no).value);
        var row_quantity = filterNum(document.getElementById('quantity'+satir_no).value);
        var satir_net_total = filterNum(document.getElementById('row_net_total'+satir_no).value,<cfoutput>#session.ep.our_company_info.rate_round_num#</cfoutput>);
        if(satir_total == 0)
        {
            var amount_ = satir_net_total/row_quantity;
            document.getElementById('amount'+satir_no).value=commaSplit(amount_);
            hesapla(satir_no);
        }
        else
        {
            var discount_ = (100*(satir_total - satir_net_total)/satir_total);
            document.getElementById('discount'+satir_no).value=commaSplit(discount_);
        }
    }
    
    function change_money_info(satir_no,discount_info)
    {
        if(document.getElementById('subs_ref_id'+satir_no).value != '' && document.getElementById('subs_ref_name'+satir_no).value != '' && document.getElementById('amount'+satir_no).value != '' && discount_info == 100)
        {
            document.getElementById('discount'+satir_no).readOnly=false;
            //document.getElementById('discount'+satir_no).value = discount_info;
            indirim_hesapla(satir_no);
        }
        else if(document.getElementById('subs_ref_name'+satir_no).value == '' && discount_info == 0)
        {
            document.getElementById('discount'+satir_no).value = discount_info;
            indirim_hesapla(satir_no);
        }
    }
    
    
    function is_zero(satir_no)
    {   
        if(isNaN(document.payment_plan.quantity.value) || document.payment_plan.quantity.value == 0 || document.payment_plan.quantity.value < 0)
        {
            document.payment_plan.quantity.value = 1;
            return false;
        }
        if(isNaN(document.getElementById('quantity'+satir_no).value) || document.getElementById('quantity'+satir_no).value == 0 || document.getElementById('quantity'+satir_no).value < 0)  
        {
            document.getElementById('quantity'+satir_no).value = 1;
            return false;
        }
    }
    function camp_control()
    {
        <cfoutput>
            <cfif xml_control_camp eq 1>
                get_camp_info=wrk_safe_query("get_subscription_campaigns",'dsn3',0,#attributes.subscription_id#);
                if(get_camp_info.recordcount > 0)
                {
                    if(!confirm('Kampanya İle İlişkili Faturalanmamış Satırlar Mevcut Satırları Silmek İstediğinizden Emin misiniz ? \n\n İlişkili Kampanyalar:'+get_camp_info.CAMP_HEAD))
                    return false;
                }
                else
                {
                    if(!confirm('<cf_get_lang dictionary_id ="41307.Ödeme Planı Satırlarını Silmek İstediğinizden Emin misiniz">')) 
                    return false;
                }
                openBoxDraggable('#request.self#?fuseaction=sales.popup_form_del_pay_plan_row&xml_del_camp_rows=#xml_del_camp_rows#&xml_del_ref_rows=#xml_del_ref_rows#&del_all=1&subscription_id=#attributes.subscription_id#');
            <cfelse>
                if(confirm('<cf_get_lang dictionary_id ="41307.Ödeme Planı Satırlarını Silmek İstediğinizden Emin misiniz">')) 
                    openBoxDraggable('#request.self#?fuseaction=sales.popup_form_del_pay_plan_row&xml_del_camp_rows=#xml_del_camp_rows#&xml_del_ref_rows=#xml_del_ref_rows#&del_all=1&subscription_id=#attributes.subscription_id#');
            </cfif>
        </cfoutput>
    }
    function camp_control_row(row_no,row_id,all_)
    {
        <cfoutput>
    
            //Toplu Silme İcin FBS20140327
            if(all_ != "" && row_id == "")
            {
            <cfloop from="1" to="#GET_PAYMENT_ROWS.recordcount#" index="xx">
                if(document.getElementById("is_change#xx#") != undefined && document.getElementById("is_change#xx#").checked)
                {
                    if(row_id != '')
                    {
                        var row_no = row_no + ',' + list_getat(document.getElementById("is_change#xx#").value,1);
                        var row_id = row_id + ',' + list_getat(document.getElementById("is_change#xx#").value,2);
                    }
                    else
                    {
                        var row_no = list_getat(document.getElementById("is_change#xx#").value,1);
                        var row_id = list_getat(document.getElementById("is_change#xx#").value,2);
                    }
                }
            </cfloop>
            }
    
            <cfif xml_control_camp eq 1>
                var listParam = "#attributes.subscription_id#" + "*" + row_id;
                get_camp_info=wrk_safe_query("get_subscription_campaigns_1",'dsn3',0,listParam);
                if(get_camp_info.recordcount > 0)
                {
                    if(!confirm('Satırın Kampanya İlişkisi Mevcut Satırı Silmek İstediğinizden Emin misiniz ? <cf_get_lang dictionary_id="58508.Satır">:'+row_no))
                    return false;
                }
                else
                {
                    if(!confirm('<cf_get_lang dictionary_id ="41386.Ödeme Planı Satırını Silmek İstediğinizden Emin misiniz">')) 
                    return false;
                }
                windowopen('#request.self#?fuseaction=sales.emptypopup_del_subs_pay_plan_row&xml_del_camp_rows=#xml_del_camp_rows#&xml_del_ref_rows=#xml_del_ref_rows#&payment_row_id='+row_id+'&subscription_id=#attributes.subscription_id#','small');
            <cfelse>
                if(confirm('<cf_get_lang dictionary_id ="41386.Ödeme Planı Satırını Silmek İstediğinizden Emin misiniz">')) 
                    windowopen('#request.self#?fuseaction=sales.emptypopup_del_subs_pay_plan_row&xml_del_camp_rows=#xml_del_camp_rows#&xml_del_ref_rows=#xml_del_ref_rows#&payment_row_id='+row_id+'&subscription_id=#attributes.subscription_id#','small');
            </cfif>
        </cfoutput>
    }
    function hesapla_main(type)
    {
        if(type == 1)
        {
            var satir_total = filterNum(document.payment_plan.amount.value,<cfoutput>#price_round_number#</cfoutput>);
         
            if(satir_total != 0)
            {
                var satir_net_total = filterNum(document.payment_plan.net_amount.value,<cfoutput>#price_round_number#</cfoutput>);
                var discount_ = -1*(((satir_net_total*100)/satir_total)-100);
                document.payment_plan.discount.value=commaSplit(discount_);
            }
            else
            {
                var satir_net_total = filterNum(document.payment_plan.net_amount.value,<cfoutput>#price_round_number#</cfoutput>);
                document.payment_plan.amount.value=commaSplit(satir_net_total);
            }
        }
        else if(type == 0)
        {
            var satir_total = filterNum(document.payment_plan.amount.value,<cfoutput>#price_round_number#</cfoutput>);
            var satir_discount = filterNum(document.payment_plan.discount.value);
            var discount_ = (satir_total * satir_discount)/100;
            document.payment_plan.net_amount.value=commaSplit(satir_total-discount_,<cfoutput>#price_round_number#</cfoutput>);
            
        }
        else if(type == 2)
        {
            var satir_total = filterNum(document.payment_plan.amount.value,<cfoutput>#price_round_number#</cfoutput>);
            var satir_discount = filterNum(document.payment_plan.discount.value);
            var discount_ = (satir_total * satir_discount)/100;
            document.payment_plan.net_amount.value=commaSplit(satir_total-discount_,<cfoutput>#price_round_number#</cfoutput>);
        }
    }
    function year_diff()
    {
        document.getElementById('discount').value = filterNum(document.getElementById('discount').value);
        document.getElementById('amount').value = filterNum(document.getElementById('amount').value);
        document.getElementById('net_amount').value = filterNum(document.getElementById('net_amount').value,<cfoutput>#price_round_number#</cfoutput>);
    }
    function AmountRnd(money,rnd){
            var element = document.getElementById(money);
            var money = element.value;
            money = money.replace(".","");
            money = money.replace(",",".");
            var tut = commaSplit(money,rnd);
            element.value = tut;
    }
    </script>
    <script type="text/javascript">
        function fatura_kes()
        { var endrow=<cfoutput>#endrow#</cfoutput>;
            var aktif_kontrol =<cfif attributes.row_status eq ""><cfoutput>-1</cfoutput><cfelse><cfoutput>#attributes.row_status#</cfoutput></cfif>;
            var checked_kontrol = 0;
            document.show_pay_plan.list_payment_row_id.value ='';
            if(endrow >1){
                for(var i=<cfoutput>#attributes.startrow#</cfoutput>;i<=endrow;i++){
                    if(eval('document.show_pay_plan.is_change'+i).checked==true)
                    {
                        checked_kontrol = checked_kontrol + 1;
                        if(document.show_pay_plan.list_payment_row_id.value.length==0) ayirac=''; else ayirac=',';
                            document.show_pay_plan.list_payment_row_id.value = document.show_pay_plan.list_payment_row_id.value+ayirac+eval('document.show_pay_plan.payment_row_id'+i).value;
                    }
            }
        }else{
                if(document.show_pay_plan.is_change1.checked==true)
                {
                    checked_kontrol = checked_kontrol +1;
                    document.show_pay_plan.list_payment_row_id.value = document.show_pay_plan.payment_row_id1.value;				
                }
            }
            if(checked_kontrol==0)
            {
                alert("<cf_get_lang dictionary_id='41124.Ödeme Planı Şeçimi Yapınız'> !");
                return false;
            }
            else if(aktif_kontrol!=1){
                alert("<cf_get_lang dictionary_id='63034.Aktif Filtreleme Yapınız'> !");
                return false;
            }
            else
            {
                open_invoice();
            }
        }
        
        function open_invoice()
        {
            document.add_invoice.list_payment_row_id.value = document.show_pay_plan.list_payment_row_id.value;       
            document.add_invoice.submit();

        }
    </script>


    <!---
        <script>
        $(function () {
            $('.fixed_hdr2').fxdHdrCol({
                fixedCols:0,
                width:"100%",
                height:450,
                colModal: [
                       <cfif xml_change_row eq 1>{ width:10 },</cfif>
                       { width: 25 },
                       { width: 25 },
                       { width: 25 },
                       { width: 100 },
                       <cfif xml_payment_finish_date eq 1>{ width: 100 },</cfif>
                       { width: 150 },
                       { width: 135 },
                       { width: 25 },
                       <cfif x_payment_plan_kdv>{width: 10 },</cfif>
                       <cfif x_payment_plan_otv>{ width: 10 },</cfif>
                       { width: 50 },
                       { width: 120 },
                       { width: 80 },
                       <cfif xml_payment_rate>{ width: 80 },</cfif>
                       { width: 80 },
                       { width: 80 },
                       <cfif x_payment_plan_isk_amount>{ width: 80}, </cfif>
                       { width: 75 },
                       <cfif x_payment_plan_kdv_amount>{ width: 120 },</cfif>
                       { width: 30 },
                       { width: 30 },
                       { width: 80 },
                       { width: 70 },
                       { width: 10 },
                       { width: 90 },
                       <cfif x_payment_plan_revenue_info> { width: 70 },</cfif>
                       <cfif x_payment_plan_campaign>{ width: 110 },</cfif>
                       <cfif x_payment_plan_reference>{ width: 90 },</cfif>
                       <cfif x_payment_plan_service>{ width: 90 },</cfif>
                       <cfif x_payment_plan_call> { width: 90},</cfif>
                       <cfif x_payment_plan_record_info>{ width: 300 },</cfif>
                       <cfif x_payment_plan_record_info> { width: 300 }</cfif>
                ],
                sort:false
            });
        });
    </script> --->