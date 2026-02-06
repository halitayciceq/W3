<cfcomponent>

    <cfset dsn = dsn_alias = application.systemParam.systemParam().dsn />
    <cfset dsn1 = dsn_product = dsn1_alias = '#dsn#_product' />
    <cfset dsn2 = dsn2_alias = '#dsn#_#session.ep.period_year#_#session.ep.company_id#' />
	<cfset dsn3 = dsn3_alias = '#dsn#_#session.ep.company_id#' />
    <cfset functions = createObject("component","WMO.functions") />
    <cfset wrk_round = functions.wrk_round>

    <cffunction name="PreOrderAction" access="remote" returntype="any" returnformat="json">
        <cfargument name="order_pre_id">
        <cfset result = structNew()>
        <!--- <cftry> --->
            <cfquery name="get_order_pre" datasource="#dsn3#">
                SELECT RECORD_PAR, RECORD_CONS FROM ORDER_PRE WHERE ORDER_PRE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.order_pre_id#">
            </cfquery>

            <cfset get_rows = this.get_pre_order_products(consumer_id:'#get_order_pre.RECORD_CONS#', partner_id:'#get_order_pre.RECORD_PAR#')>

            <cfif len(get_rows.ACCOUNT_ID)>
                <cfquery name="get_bank_account" datasource="#DSN#">
                    SELECT 
                        ACCOUNT_ID,
                        ACCOUNT_NAME,
                        ACCOUNT_NO,
                        ACCOUNT_OWNER_CUSTOMER_NO,
                        BANK_CODE,
                        BRANCH_CODE,
                        (SELECT BANK_IMAGE_PATH FROM SETUP_BANK_TYPES SB WHERE SB.BANK_CODE = AC.BANK_CODE) AS BANK_IMAGE
                    FROM  
                        #dsn3#.ACCOUNTS AC
                    WHERE 
                        IS_PUBLIC = 1 AND 
                        IS_INTERNET = 1 AND
                        ACCOUNT_ID = #get_rows.ACCOUNT_ID#
                </cfquery>
                <cfset attributes.account_name = get_bank_account.account_name>
            <cfelse>
                <cfset attributes.account_name = "">
            </cfif>

            <cfquery name="get_total" dbtype="query">
                SELECT SUM(PRICE_KDV_TL) AS T_TL_PRICE,SUM(PRICE_TL) AS T_TL_PRICE_KDVSIZ FROM get_rows
            </cfquery>

            <cfset attributes.consumer_id=''>
            <cfset attributes.partner_id=''>
            <cfset attributes.company_id=''>

            <cfif isdefined("get_rows.RECORD_PAR") and len(get_rows.RECORD_PAR)>
                <cfquery name="get_comp_id" datasource="#dsn#">
                    SELECT COMPANY_ID FROM COMPANY_PARTNER WHERE PARTNER_ID = #get_rows.RECORD_PAR#
                </cfquery>
                <cfset attributes.partner_id= get_rows.RECORD_PAR>
                <cfset attributes.company_id= get_comp_id.COMPANY_ID>
            <cfelseif isdefined("get_rows.RECORD_CONS") and len(get_rows.RECORD_CONS)>
                <cfset attributes.consumer_id=session.ww.userid>
            </cfif>

            <cfset wrk_id = dateformat(now(),'YYYYMMDD')&timeformat(now(),'HHmmssL')&'_#iif(isdefined("session_base.userid"),"session_base.userid",0)#_'&round(rand()*100)>
            <cfset attributes.SHIP_ADDRESS_ROW = "">
            <cfif not len(get_rows.DELIVER_ID)>
                <cfset attributes.ship_address_id = -1>
            <cfelse>
                <cfset attributes.ship_address_id = get_rows.DELIVER_ID>
            </cfif>
            <cfset attributes.havale_banka = get_rows.havale_banka>
            <cfset attributes.havale_tarih = get_rows.havale_tarih>
            <cfset attributes.havale_no = get_rows.havale_no>
            <cfset attributes.order_detail = get_rows.order_detail>

            <cfif isdefined("get_rows.RECORD_CONS") and len(get_rows.RECORD_CONS)>
                <cfquery name="GET_CONSUMER_BRANCH" datasource="#DSN#">
                    SELECT 
                        SC.CITY_NAME,SC.CITY_ID,SCO.COUNTY_NAME,SCO.COUNTY_ID,CB.CONTACT_ADDRESS,CB.CONTACT_NAME,CB.CONTACT_ID,CB.CONTACT_POSTCODE
                    FROM 
                        CONSUMER_BRANCH CB
                        LEFT JOIN SETUP_CITY SC ON CB.CONTACT_CITY_ID=SC.CITY_ID
                        LEFT JOIN SETUP_COUNTY SCO ON CB.CONTACT_COUNTY_ID=SCO.COUNTY_ID
                    WHERE 
                        CONSUMER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_rows.RECORD_CONS#">
                        AND
                        CONTACT_ID = #attributes.ship_address_id#
                </cfquery>
            <cfelse>
                <cfquery name="GET_CONSUMER_BRANCH" datasource="#DSN#">
                    SELECT 
                        SC.CITY_NAME,SC.CITY_ID,SCO.COUNTY_NAME,SCO.COUNTY_ID,CB.COMPBRANCH_ADDRESS AS CONTACT_ADDRESS,CB.COMPBRANCH__NAME AS CONTACT_NAME,CB.COMPBRANCH_ID AS CONTACT_ID,CB.COMPBRANCH_POSTCODE AS CONTACT_POSTCODE
                    FROM 
                        COMPANY_BRANCH CB
                        LEFT JOIN SETUP_CITY SC ON CB.CITY_ID=SC.CITY_ID
                        LEFT JOIN SETUP_COUNTY SCO ON CB.COUNTY_ID=SCO.COUNTY_ID
                    WHERE 
                        COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_rows.RECORD_PAR#"> AND
                        COMPBRANCH_ID = #attributes.ship_address_id#
                </cfquery>
            </cfif>
            <cfset attributes.ship_address = GET_CONSUMER_BRANCH.CONTACT_ADDRESS & '/' & GET_CONSUMER_BRANCH.COUNTY_NAME & '/'& GET_CONSUMER_BRANCH.CITY_NAME>
            <cfset attributes.city_id = GET_CONSUMER_BRANCH.CITY_ID>
            <cfset attributes.county_id = GET_CONSUMER_BRANCH.COUNTY_ID>
            <cfif not len(get_rows.INVOICE_DELIVER_ID)>
                <cfset attributes.tax_address_id = -1>
            <cfelse>
                <cfset attributes.tax_address_id = get_rows.INVOICE_DELIVER_ID>
            </cfif>
            <cfif get_rows.INVOICE_DELIVER_ID eq '-1'>
                <cfset attributes.tax_address = GET_CONSUMER.WORKADDRESS>
            <cfelseif get_rows.INVOICE_DELIVER_ID eq '-2'>
                <cfset attributes.tax_address = GET_CONSUMER.HOMEADDRESS>
            <cfelse>
                <cfif isdefined("get_rows.RECORD_CONS") and len(get_rows.RECORD_CONS)>
                    <cfquery name="GET_CONSUMER_BRANCH" datasource="#DSN#">
                        SELECT 
                            SC.CITY_NAME,SC.CITY_ID,SCO.COUNTY_NAME,SCO.COUNTY_ID,CB.CONTACT_ADDRESS,CB.CONTACT_NAME,CB.CONTACT_ID,CB.CONTACT_POSTCODE
                        FROM 
                            CONSUMER_BRANCH CB
                            LEFT JOIN SETUP_CITY SC ON CB.CONTACT_CITY_ID=SC.CITY_ID
                            LEFT JOIN SETUP_COUNTY SCO ON CB.CONTACT_COUNTY_ID=SCO.COUNTY_ID
                        WHERE 
                            CONSUMER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_rows.RECORD_CONS#">
                            AND
                            CONTACT_ID = #attributes.tax_address_id#
                    </cfquery>
                <cfelse>
                    <cfquery name="GET_CONSUMER_BRANCH" datasource="#DSN#">
                        SELECT 
                            SC.CITY_NAME,SC.CITY_ID,SCO.COUNTY_NAME,SCO.COUNTY_ID,CB.COMPBRANCH_ADDRESS AS CONTACT_ADDRESS,CB.COMPBRANCH__NAME AS CONTACT_NAME,CB.COMPBRANCH_ID AS CONTACT_ID,CB.COMPBRANCH_POSTCODE AS CONTACT_POSTCODE
                            FROM 
                                COMPANY_BRANCH CB
                                LEFT JOIN SETUP_CITY SC ON CB.CITY_ID=SC.CITY_ID
                                LEFT JOIN SETUP_COUNTY SCO ON CB.COUNTY_ID=SCO.COUNTY_ID
                            WHERE 
                                COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.company_id#">
                                AND
                                COMPBRANCH_ID = #attributes.tax_address_id#
                    </cfquery>
                </cfif>
                <cfset attributes.tax_address= GET_CONSUMER_BRANCH.CONTACT_ADDRESS>
                <cfset attributes.city_id = GET_CONSUMER_BRANCH.CITY_ID>
                <cfset attributes.county_id = GET_CONSUMER_BRANCH.COUNTY_ID>
            </cfif>

            <cfset attributes.shipment_id = get_rows.SHIPMENT_ID>
            <cfset attributes.payment_id = get_rows.PAYMENT_ID>
            <cfset gross_total_ = len(get_total.T_TL_PRICE_KDVSIZ)?get_total.T_TL_PRICE_KDVSIZ:0>
            <cfset discount_total_ = 0>
            <cfset net_total_ = len(get_total.T_TL_PRICE)?get_total.T_TL_PRICE:0>
            <cfset tax_total_ = net_total_ - gross_total_>
            <cfset new_date = now()>
            <cfset indirim_total_ = 0>
            <cfset attributes.ship_method_id = 1>
            <!--- <cfset attributes.PROCESS_STAGE = session_base.PROCESS_STAGE> --->
            <cfif isdefined("attributes.order_detail") and len(attributes.order_detail)>
                <cfset attributes.order_detail = attributes.order_detail>
            </cfif>
            <cfif isdefined("attributes.payment_id") and attributes.payment_id eq 3>
                <cfset attributes.order_detail = attributes.order_detail&' - '&attributes.account_name>
            </cfif>

            <cflock name="#CreateUUID()#" timeout="20">
                <cftransaction>
                   
                    <cfquery name="SET_GENERAL_PAPERS" datasource="#DSN#">
                        UPDATE
                            #dsn3#.GENERAL_PAPERS
                        SET
                            ORDER_NUMBER = ORDER_NUMBER+1
                        WHERE
                            PAPER_TYPE = 0 AND
                            ZONE_TYPE = 1
                    </cfquery>
                    <cfquery name="GET_GENERAL_PAPERS"  datasource="#DSN#">
                        SELECT 
                            ORDER_NO,
                            ORDER_NUMBER 
                        FROM 
                            #dsn3#.GENERAL_PAPERS 
                        WHERE 
                            PAPER_TYPE = 0 AND
                            ZONE_TYPE = 1
                    </cfquery>
                    <cfset temp_order_number = '#get_general_papers.order_no#-#get_general_papers.order_number#'>
                    <cfquery name="ADD_ORDER" datasource="#DSN#" result="GET_MAX_ORDER">
                        INSERT INTO
                            #dsn3#.ORDERS
                            (
                                WRK_ID,
                                ORDER_NUMBER,
                                ORDER_CURRENCY,
                                ORDER_STATUS,
                                PRIORITY_ID, 
                                COMMETHOD_ID,
                                <cfif isdefined("attributes.deliverdate") and len(attributes.deliverdate)>
                                    DELIVERDATE,
                                </cfif>
                                <cfif isdefined("get_rows.RECORD_PAR") and len(get_rows.RECORD_PAR)>
                                    PARTNER_ID,
                                    COMPANY_ID,
                                <cfelseif isdefined("get_rows.RECORD_CONS") and len(get_rows.RECORD_CONS)>
                                    CONSUMER_ID,
                                <cfelseif isdefined("arguments.watalogy_partner") and  isdefined("arguments.company_id")>
                                    PARTNER_ID,
                                    COMPANY_ID,
                                </cfif>
                                <cfif isdefined("attributes.payment_id") and len(attributes.payment_id)>
                                    PAYMETHOD,
                                <cfelseif isdefined("card_paymethod_id") and len(card_paymethod_id)>
                                    CARD_PAYMETHOD_ID,
                                    CARD_PAYMETHOD_RATE,
                                </cfif>
                                SHIP_ADDRESS,
                                SHIP_ADDRESS_ID,
                                TAX_ADDRESS,
                                TAX_ADDRESS_ID,
                                COUNTY_ID,
                                CITY_ID,
                                ORDER_HEAD,
                                ORDER_DETAIL,
                                GROSSTOTAL,
                                TAXTOTAL,
                                OTV_TOTAL,
                                DISCOUNTTOTAL,
                                NETTOTAL,
                                INCLUDED_KDV,
                                OTHER_MONEY,
                                OTHER_MONEY_VALUE,
                                PURCHASE_SALES,
                                RECORD_DATE,
                                RECORD_IP,
                                RECORD_CON,
                                RECORD_PAR,
                                RECORD_EMP,
                                ORDER_ZONE
                                ,SHIP_METHOD
                                ,RESERVED
                                ,PROJECT_ID
                                ,ORDER_DATE
                                ,ORDER_STAGE
                                ,ORDER_EMPLOYEE_ID,
                                DUE_DATE,
                                REF_NO,
                                SA_DISCOUNT,
                                GENERAL_PROM_ID,
                                GENERAL_PROM_LIMIT,
                                GENERAL_PROM_AMOUNT,
                                GENERAL_PROM_DISCOUNT, 
                                FREE_PROM_ID,
                                FREE_PROM_LIMIT,
                                FREE_PROM_AMOUNT,
                                FREE_PROM_STOCK_ID,
                                FREE_STOCK_PRICE,
                                FREE_STOCK_MONEY,
                                FREE_PROM_COST,
                                IS_ENDUSER_PRICE,
                                IS_MEMBER_RISK,
                                DELIVER_DEPT_ID,
                                REF_COMPANY_ID,
                                REF_PARTNER_ID,
                                LOCATION_ID,
                                ORDER_PAYMENT_VALUE 
                            )
                        VALUES
                            (
                                '#wrk_id#',
                                '#temp_order_number#',
                                -1,
                                1,
                                1, 
                                '',
                                <cfif isdefined("attributes.deliverdate") and len(attributes.deliverdate)>#attributes.deliverdate#,</cfif>
                                <cfif isdefined("get_rows.RECORD_PAR") and len(get_rows.RECORD_PAR)>
                                    #attributes.partner_id#,
                                    #attributes.company_id#,
                                <cfelseif isdefined("get_rows.RECORD_CONS") and len(get_rows.RECORD_CONS)>
                                    #session.ww.userid#,
                                <cfelseif isdefined("arguments.partner_id") and  isdefined("arguments.company_id")>
                                    #arguments.partner_id#,
                                    #arguments.company_id#,
                                </cfif>
                                <cfif isdefined("attributes.payment_id") and len(attributes.payment_id)>
                                    #attributes.payment_id#,
                                <cfelseif isdefined("card_paymethod_id") and len(card_paymethod_id)>
                                    #listfirst(card_paymethod_id)#,
                                    <cfif listlen(card_paymethod_id) gt 1>#listgetat(card_paymethod_id,2,',')#<cfelse>NULL</cfif>,
                                </cfif>
                                '#attributes.ship_address#',
                                #attributes.ship_address_id#,
                                '#attributes.tax_address#',
                                #attributes.tax_address_id#,
                                <cfif isdefined("attributes.county_id") and len(attributes.county_id)>#attributes.county_id#<cfelse>NULL</cfif>,
                                <cfif isdefined("attributes.city_id") and len(attributes.city_id)>#attributes.city_id#<cfelse>NULL</cfif>,
                                <cfif isdefined('attributes.order_head_') and len(attributes.order_head_)>'#attributes.order_head_#'<cfelseif isdefined("session.ep")>'Portal Sipariş'<cfelse>'Portal Sipariş'</cfif>,
                                <cfif isdefined("attributes.order_detail")>'#attributes.order_detail#'<cfelse>NULL</cfif>,
                                #gross_total_#,
                                #tax_total_#,
                                0,
                                #discount_total_#,
                                #net_total_#,
                                1,
                                'TL',
                                NULL,
                                1,
                                #now()#,
                                '#CGI.REMOTE_ADDR#',
                                <cfif isdefined("Get_rows.RECORD_CONS") and len(Get_rows.RECORD_CONS)>#Get_rows.RECORD_CONS#<cfelse>NULL</cfif>,
                                <cfif isdefined("Get_rows.RECORD_PAR") and len(Get_rows.RECORD_PAR)>#Get_rows.RECORD_PAR#<cfelse>NULL</cfif>,
                                <cfif isdefined("session.ep.userid")>#session.ep.userid#<cfelse>NULL</cfif>,
                                0
                                <cfif isdefined("attributes.shipment_id") and len(attributes.shipment_id)>,#attributes.shipment_id#<cfelse>,NULL</cfif>
                                ,1
                                ,NULL
                                ,#new_date#
                                ,''
                                ,<cfif isdefined("GET_WORK_POS") and GET_WORK_POS.recordcount and len(GET_WORK_POS.EMPLOYEE_ID)>#GET_WORK_POS.employee_id#<cfelse>NULL</cfif>,
                                <cfif isdefined("order_due_date") and len(order_due_date)>#order_due_date#<cfelse>NULL</cfif>,
                                <cfif isdefined("attributes.ref_no") and len(attributes.ref_no)>'#attributes.ref_no#'<cfelse>NULL</cfif>,
                                #indirim_total_#,
                                <cfif isdefined("attributes.general_prom_id") and len(attributes.general_prom_id)>#attributes.general_prom_id#<cfelse>NULL</cfif>,
                                <cfif isdefined("attributes.general_prom_limit") and len(attributes.general_prom_limit)>#attributes.general_prom_limit#<cfelse>NULL</cfif>,
                                <cfif isdefined("attributes.general_prom_amount") and len(attributes.general_prom_amount)>#attributes.general_prom_amount#<cfelse>NULL</cfif>,
                                <cfif isdefined("attributes.general_prom_discount") and len(attributes.general_prom_discount)>#attributes.general_prom_discount#<cfelse>NULL</cfif>,
                                <cfif isdefined("attributes.free_prom_id") and len(attributes.free_prom_id)>#attributes.free_prom_id#<cfelse>NULL</cfif>,
                                <cfif isdefined("attributes.free_prom_limit") and len(attributes.free_prom_limit)>#attributes.free_prom_limit#<cfelse>NULL</cfif>,
                                <cfif isdefined("attributes.free_prom_amount") and len(attributes.free_prom_amount)>#attributes.free_prom_amount#<cfelse>NULL</cfif>,
                                <cfif isdefined("attributes.free_prom_stock_id") and len(attributes.free_prom_stock_id)>#attributes.free_prom_stock_id#<cfelse>NULL</cfif>,
                                <cfif isdefined("attributes.free_stock_price") and len(attributes.free_stock_price)>#attributes.free_stock_price#<cfelse>NULL</cfif>,
                                <cfif isdefined("attributes.free_stock_money") and len(attributes.free_stock_money)>'#attributes.free_stock_money#'<cfelse>NULL</cfif>,
                                <cfif isdefined("attributes.free_prom_cost") and len(attributes.free_prom_cost)>#attributes.free_prom_cost#<cfelse>NULL</cfif>,
                                <cfif isDefined("attributes.is_price_standart")>1<cfelse>0</cfif>,<!--- son kullanıcı fiyatı bilgisi --->
                                1,
                                <cfif isdefined("attributes.sale_department_id") and len(attributes.sale_department_id)>#attributes.sale_department_id#<cfelse>NULL</cfif>,
                                <cfif isdefined("attributes.ref_company_id") and len(attributes.ref_company_id)>#attributes.ref_company_id#<cfelse>NULL</cfif>,
                                <cfif isdefined("attributes.ref_partner_id") and len(attributes.ref_partner_id)>#attributes.ref_partner_id#<cfelse>NULL</cfif>,
                                <cfif isdefined("attributes.sale_location_id") and len(attributes.sale_location_id)>#attributes.sale_location_id#<cfelse>NULL</cfif>,
                                <cfif isdefined("attributes.paymethod_type") and listfind("2,4",attributes.paymethod_type) and isdefined("cc_paym_id_info")><!--- kredi kartı ile ödemişse ödeyeceği tutar 0'dır --->
                                    0
                                <cfelse>
                                    <cfif isdefined('attributes.order_payment_value') and len(attributes.order_payment_value)>#attributes.order_payment_value#<cfelse>NULL</cfif>
                                </cfif> 
                            )
                    </cfquery> 
                    <cfset get_max_order.max_id = get_max_order.identitycol>
                    
                    <cfquery name="get_setup_money" datasource="#DSN#">
                        SELECT * FROM #dsn2#.SETUP_MONEY
                    </cfquery>
                    <cfif get_setup_money.recordcount>
                        <cfoutput query="get_setup_money">
                            <cfquery name="ADD_MONEY_CREDIT_USED" datasource="#DSN#">
                                INSERT INTO
                                    #dsn3#.ORDER_MONEY
                                    (
                                        MONEY_TYPE,
                                        ACTION_ID,
                                        RATE1,
                                        RATE2,
                                        IS_SELECTED
                                    )
                                    VALUES
                                    (
                                        '#get_setup_money.money#',
                                        #get_max_order.max_id#,
                                        #get_setup_money.rate1#,
                                        #get_setup_money.rate2#,
                                        <cfif get_setup_money.money is 'TL'>1<cfelse>0</cfif>
                                    )
                            </cfquery>				
                        </cfoutput>
                    </cfif>

                    <cfoutput query="get_rows">
                        <cf_date tarih="attributes.deliver_date">
                        
                        <cfset satir_fiyati = PRICE_TL / (quantity*prom_stock_amount)>
                        <cfset oth_m_val = PRICE_TL / (quantity*prom_stock_amount)>
                        <cfset 'net_maliyet#currentrow#' = ''>
                        <cfset 'extra_cost#currentrow#' = ''>
                        <cfset 'row_spect_id#currentrow#' = ''>
                        <cfquery name="GET_PRODUCTION" datasource="#DSN#">
                            SELECT IS_PRODUCTION,MANUFACT_CODE,ISNULL(IS_GIFT_CARD,0) IS_GIFT_CARD,GIFT_VALID_DAY FROM #dsn3#.PRODUCT WHERE PRODUCT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#product_id#">
                        </cfquery>
                        <cfif (not isdefined('row_spect_id#currentrow#') or not len(evaluate('row_spect_id#currentrow#')))>				
                            <cfquery name="GET_PRODUCT_COST" datasource="#DSN#" maxrows="1">
                                SELECT 
                                    PC.PURCHASE_NET_SYSTEM,
                                    PC.PURCHASE_EXTRA_COST_SYSTEM
                                FROM 
                                    #dsn3#.PRODUCT_COST PC,
                                    #dsn3#.PRODUCT P
                                WHERE 
                                    P.PRODUCT_ID = PC.PRODUCT_ID AND
                                    PC.PRODUCT_COST IS NOT NULL AND
                                    PC.START_DATE < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#dateadd('d',1,now())#"> AND 
                                    PC.PRODUCT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#product_id#"> AND
                                    P.IS_COST = 1
                                ORDER BY 
                                    PC.START_DATE DESC,
                                    PC.RECORD_DATE DESC
                            </cfquery>
                            <cfif get_product_cost.recordcount>
                                <cfset 'net_maliyet#currentrow#' = get_product_cost.purchase_net_system>
                                <!--- <cfset 'cost_id#currentrow#' = get_product_cost.product_cost_id> --->
                                <cfset 'extra_cost#currentrow#' = get_product_cost.purchase_extra_cost_system>
                            </cfif>
                        </cfif>
                        <cfscript>
                            if(len(discount1)) row_disc1=discount1; else row_disc1=0;
                            if(len(discount2)) row_disc2=discount2; else row_disc2=0;
                            if(len(discount3)) row_disc3=discount3; else row_disc3=0;
                            if(len(discount4)) row_disc4=discount4; else row_disc4=0;
                            if(len(discount5)) row_disc5=discount5; else row_disc5=0;
                            order_disc_rate_=((100-row_disc1) * (100-row_disc2) * (100-row_disc3) * (100-row_disc4) * (100-row_disc5));
                            satir_indirimli_fiyat=((satir_fiyati*order_disc_rate_)/10000000000);
                            row_nettotal = satir_indirimli_fiyat * quantity * prom_stock_amount;
                            if (isDefined("attributes.is_price_standart") and isDefined("attributes.consumer_info"))
                            {
                                if(len(prom_amount_discount))
                                    for(k=1;k lte attributes.kur_say;k=k+1)
                                        if(price_standard_money eq evaluate("hidden_rd_money_#k#"))
                                            row_nettotal = row_nettotal - (prom_amount_discount * evaluate("txt_rate2_#k#")/evaluate("txt_rate1_#k#") * quantity * prom_stock_amount);
                                if(len(prom_discount))
                                    row_nettotal = row_nettotal * (100-prom_discount) /100;
                                
                                row_taxtotal = wrk_round(row_nettotal * (tax/100));
                                row_lasttotal = row_nettotal + row_taxtotal;
                                other_money_value = row_nettotal;
                                for(k=1;k lte attributes.kur_say;k=k+1)
                                    if(price_standard_money eq evaluate("hidden_rd_money_#k#"))
                                        other_money_value = other_money_value / evaluate("txt_rate2_#k#");
                            }
                            else
                            {
                                if(len(prom_amount_discount))
                                    for(k=1;k lte attributes.kur_say;k=k+1)
                                        if(price_money eq evaluate("hidden_rd_money_#k#"))
                                            row_nettotal = row_nettotal - (prom_amount_discount * evaluate("txt_rate2_#k#")/evaluate("txt_rate1_#k#") * quantity * prom_stock_amount);
                                if(len(prom_discount))
                                    row_nettotal = row_nettotal * (100-prom_discount) /100;
                                row_taxtotal = wrk_round(row_nettotal * (tax/100));
                                row_lasttotal = row_nettotal + row_taxtotal;
                                other_money_value = row_nettotal;
                            }
                        </cfscript>              
                        <cfquery name="ADD_ORDER_ROW" datasource="#DSN#" result="GET_MAX_ROW">
                            INSERT INTO
                                #dsn3#.ORDER_ROW
                                (
                                    WRK_ROW_ID,
                                    CATALOG_ID,
                                    UNIQUE_RELATION_ID,
                                    ORDER_ROW_CURRENCY,
                                    ORDER_ID,
                                    PRODUCT_ID,
                                    STOCK_ID,
                                    QUANTITY,
                                    UNIT,
                                    UNIT_ID,
                                    PRICE,
                                    LIST_PRICE,
                                    TAX,
                                    DUEDATE,
                                    PRODUCT_NAME,
                                    PRODUCT_NAME2,
                                    BASKET_EXTRA_INFO_ID,
                                    DELIVER_DATE,
                                    DELIVER_DEPT,
                                    DELIVER_LOCATION,
                                    DISCOUNT_1,
                                    DISCOUNT_2,
                                    DISCOUNT_3,
                                    DISCOUNT_4,
                                    DISCOUNT_5,	
                                    DISCOUNT_6,
                                    DISCOUNT_7,
                                    DISCOUNT_8,
                                    DISCOUNT_9,
                                    DISCOUNT_10,
                                    OTHER_MONEY,
                                    OTHER_MONEY_VALUE,
                                    <cfif len(get_rows.spec_var_id) and len(get_rows.spec_var_name)>
                                        SPECT_VAR_ID,
                                        SPECT_VAR_NAME,
                                    <cfelseif isdefined('row_spect_id#currentrow#') and len(evaluate('row_spect_id#currentrow#'))>
                                        SPECT_VAR_ID,
                                        SPECT_VAR_NAME,
                                    </cfif>
                                    PRICE_OTHER,
                                    COST_PRICE,
                                    EXTRA_COST,
                                    MARJ,
                                    NETTOTAL,
                                    PROM_COMISSION,
                                    PROM_COST,
                                    DISCOUNT_COST,
                                    PROM_ID,
                                    IS_PROMOTION,
                                    IS_COMMISSION,
                                    PRODUCT_MANUFACT_CODE,
                                    RESERVE_TYPE,
                                    OTV_ORAN,
                                    OTVTOTAL,
                                    IS_PRODUCT_PROMOTION_NONEFFECT,
                                    IS_GENERAL_PROM,
                                    PROM_STOCK_ID,
                                    PRICE_CAT,
                                    LOT_NO
                                    <cfif isdefined("get_rows.version_no")>,VERSION_NO</cfif>
                                )
                            VALUES
                                (
                                    <cfif isdefined("session.pp.userid")>
                                        'WRK#round(rand()*65)##dateformat(now(),'YYYYMMDD')##timeformat(now(),'HHmmssL')##session.pp.userid##round(rand()*100)##currentrow#',
                                    <cfelseif isdefined("session.ww.userid")>
                                        'WRK#round(rand()*65)##dateformat(now(),'YYYYMMDD')##timeformat(now(),'HHmmssL')##session.ww.userid##round(rand()*100)##currentrow#',
                                    <cfelseif isdefined("session.ep.userid")>
                                        'WRK#round(rand()*65)##dateformat(now(),'YYYYMMDD')##timeformat(now(),'HHmmssL')##session.ep.userid##round(rand()*100)##currentrow#',
                                    <cfelse>
                                        'WRK#round(rand()*65)##dateformat(now(),'YYYYMMDD')##timeformat(now(),'HHmmssL')#0#round(rand()*100)##currentrow#',
                                    </cfif>
                                    NULL,
                                    NULL,
                                    -1,
                                    #get_max_order.max_id#,
                                    #product_id#,
                                    #stock_id#,
                                    #quantity*prom_stock_amount#,
                                    '#main_unit#',
                                    #product_unit_id#,
                                    #satir_fiyati#,
                                    #satir_fiyati#,
                                    #tax#,
                                    <cfif isdefined("attributes.duedate#currentrow#") and len(evaluate("attributes.duedate#currentrow#"))>
                                        #evaluate("attributes.duedate#currentrow#")#,
                                    <cfelseif isdefined("order_row_due_date") and len(order_row_due_date)>
                                        #order_row_due_date#,
                                    <cfelse>
                                        0,
                                    </cfif>
                                    '#product_name#',
                                    <cfif isdefined('attributes.order_row_detail_#currentrow#') and len(evaluate("attributes.order_row_detail_#currentrow#"))>
                                        '#wrk_eval("attributes.order_row_detail_#currentrow#")#',
                                    <cfelse>
                                        <cfif isdefined("attributes.serial_no_#currentrow#")>
                                            '#wrk_eval("attributes.serial_no_#currentrow#")#',
                                        <cfelse>
                                            NULL,
                                        </cfif>
                                    </cfif>
                                    <cfif isdefined('attributes.basket_info_type_id_#currentrow#') and len(evaluate("attributes.basket_info_type_id_#currentrow#"))>
                                        #evaluate("attributes.basket_info_type_id_#currentrow#")#,
                                    <cfelse>
                                        NULL,
                                    </cfif>
                                    <cfif isdefined("attributes.deliver_date") and isdate(evaluate('attributes.deliver_date'))>#attributes.deliver_date#<cfelse>NULL</cfif>,
                                    <cfif isdefined("attributes.deliver_dept#currentrow#") and len(trim(evaluate("attributes.deliver_dept#currentrow#"))) and len(listfirst(evaluate("attributes.deliver_dept#currentrow#"),"-"))>
                                        #listfirst(evaluate("attributes.deliver_dept#currentrow#"),"-")#,
                                    <cfelse>
                                        NULL,
                                    </cfif>
                                    <cfif isdefined("attributes.deliver_dept#currentrow#") and listlen(trim(evaluate("attributes.deliver_dept#currentrow#")),"-") eq 2 and len(listlast(evaluate("attributes.deliver_dept#currentrow#"),"-"))>
                                        #listlast(evaluate("attributes.deliver_dept#currentrow#"),"-")#,
                                    <cfelse>
                                        NULL,
                                    </cfif>
                                    <cfif len(discount1)>#discount1#<cfelse>0</cfif>,
                                    <cfif len(discount2)>#discount2#<cfelse>0</cfif>,
                                    <cfif len(discount3)>#discount3#<cfelse>0</cfif>,
                                    <cfif len(discount4)>#discount4#<cfelse>0</cfif>,
                                    <cfif len(discount5)>#discount5#<cfelse>0</cfif>,
                                    0,
                                    0,
                                    0,
                                    0,
                                    0,
                                    'TL',
                                    #other_money_value#,
                                    <cfif len(get_rows.spec_var_id) and len(get_rows.spec_var_name)>
                                        #get_rows.spec_var_id#,
                                        '#get_rows.spec_var_name#',
                                    <cfelseif isdefined('row_spect_id#currentrow#') and len(evaluate('row_spect_id#currentrow#'))>
                                        #evaluate('row_spect_id#currentrow#')#,
                                        '#product_name#',
                                    </cfif>
                                    #satir_fiyati#,
                                    <cfif len(evaluate('net_maliyet#currentrow#'))>#evaluate('net_maliyet#currentrow#')#<cfelse>0</cfif>,
                                    <cfif len(evaluate('extra_cost#currentrow#'))>#evaluate('extra_cost#currentrow#')#<cfelse>0</cfif>,
                                    <cfif isdefined('attributes.marj#currentrow#') and len(evaluate('attributes.marj#currentrow#'))>#evaluate('attributes.marj#currentrow#')#<cfelse>0</cfif>,
                                    #row_nettotal#,
                                    <cfif len(prom_discount)>#prom_discount#,<cfelse>NULL,</cfif>
                                    <cfif len(prom_cost)>#prom_cost#,<cfelse>0,</cfif>
                                    <cfif len(prom_amount_discount)>#prom_amount_discount#,<cfelse>0,</cfif>
                                    <cfif len(prom_id)>#prom_id#,<cfelse>null,</cfif>
                                    <cfif len(is_prom_asil_hediye)>#is_prom_asil_hediye#,<cfelse>NULL,</cfif>				
                                    <cfif len(is_commission) and is_commission eq 1>1,<cfelse>0,</cfif>
                                    '#get_production.manufact_code#',
                                    -1,
                                    0,
                                    0,
                                    <cfif len(is_product_promotion_noneffect)>#is_product_promotion_noneffect#<cfelse>NULL</cfif>,
                                    <cfif len(is_general_prom)>#is_general_prom#<cfelse>NULL</cfif>,
                                    <cfif len(is_prom_asil_hediye) and is_prom_asil_hediye and len(prom_main_stock_id)>#prom_main_stock_id#<cfelse>NULL</cfif>,
                                    <cfif isdefined('attributes.prj_discount_price_cat') and len(attributes.prj_discount_price_cat)>#attributes.prj_discount_price_cat#<cfelse>NULL</cfif>,
                                    <cfif len(lot_no)>'#lot_no#'<cfelse>NULL</cfif>
                                    <cfif isdefined("get_rows.version_no")>,'#get_rows.version_no#'</cfif>
                                )
                        </cfquery>
                        <cfif IsDefined("arguments.subscription_id") and len(arguments.subscription_id)>
                            <cfquery name="ADD_CONTRACT_ROW" datasource="#DSN#">
                                INSERT INTO
                                    #DSN3#.SUBSCRIPTION_CONTRACT_ROW
                                (
                                    SUBSCRIPTION_ID,
                                    PRODUCT_NAME,
                                    STOCK_ID,
                                    PRODUCT_ID,
                                    AMOUNT,
                                    UNIT,
                                    UNIT_ID,					
                                    TAX,
                                    PRICE,
                                    DISCOUNT1,					
                                    DISCOUNT2,
                                    DISCOUNT3,
                                    DISCOUNT4,
                                    DISCOUNT5,
                                    DISCOUNT6,
                                    DISCOUNT7,
                                    DISCOUNT8,
                                    DISCOUNT9,
                                    DISCOUNT10,
                                    DISCOUNTTOTAL,
                                    GROSSTOTAL,
                                    NETTOTAL,
                                    TAXTOTAL,
                                    SPECT_VAR_ID,
                                    SPECT_VAR_NAME,
                                    LOT_NO,
                                    OTHER_MONEY,
                                    OTHER_MONEY_VALUE,					
                                    PRICE_OTHER,
                                    DISCOUNT_COST,
                                    DELIVER_DATE,
                                    OTV_ORAN,
                                    OTVTOTAL,
                                    EXTRA_COST,
                                    LIST_PRICE
                                )
                                VALUES
                                (
                                    <cfif len(arguments.subscription_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_id#"><cfelse>NULL</cfif>,
                                    <cfif len(product_name)><cfqueryparam cfsqltype="cf_sql_varchar" value="#product_name#"><cfelse>NULL</cfif>,
                                    <cfif len(stock_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#stock_id#"><cfelse>NULL</cfif>,
                                    <cfif len(product_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#product_id#"><cfelse>NULL</cfif>,
                                    <cfqueryparam cfsqltype="cf_sql_float" value="#quantity*prom_stock_amount#">,
                                    <cfif len(main_unit)><cfqueryparam cfsqltype="cf_sql_varchar" value="#main_unit#"><cfelse>NULL</cfif>,
                                    <cfif len(product_unit_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#product_unit_id#"><cfelse>NULL</cfif>,
                                    <cfif len(tax)><cfqueryparam cfsqltype="cf_sql_float" value="#tax#"><cfelse>NULL</cfif>,
                                    <cfif len(satir_fiyati)><cfqueryparam cfsqltype="cf_sql_float" value="#satir_fiyati#"><cfelse>NULL</cfif>,
                                    <cfif len(discount1)><cfqueryparam cfsqltype="cf_sql_float" value="#discount1#"><cfelse>NULL</cfif>,					
                                    <cfif len(discount2)><cfqueryparam cfsqltype="cf_sql_float" value="#discount2#"><cfelse>NULL</cfif>,
                                    <cfif len(discount3)><cfqueryparam cfsqltype="cf_sql_float" value="#discount3#"><cfelse>NULL</cfif>,
                                    <cfif len(discount4)><cfqueryparam cfsqltype="cf_sql_float" value="#discount4#"><cfelse>NULL</cfif>,
                                    <cfif len(discount5)><cfqueryparam cfsqltype="cf_sql_float" value="#discount5#"><cfelse>NULL</cfif>,
                                    0,
                                    0,
                                    0,
                                    0,
                                    0,
                                    <cfif len(satir_indirimli_fiyat)><cfqueryparam cfsqltype="cf_sql_float" value="#satir_indirimli_fiyat#"><cfelse>NULL</cfif>,
                                    <cfif len(row_lasttotal)><cfqueryparam cfsqltype="cf_sql_float" value="#row_lasttotal#"><cfelse>NULL</cfif>,
                                    <cfif len(row_nettotal)><cfqueryparam cfsqltype="cf_sql_float" value="#row_nettotal#"><cfelse>NULL</cfif>,
                                    <cfif len(row_taxtotal)><cfqueryparam cfsqltype="cf_sql_float" value="#row_taxtotal#"><cfelse>NULL</cfif>,
                                    <cfif len(get_rows.spec_var_id) and len(get_rows.spec_var_name)>
                                        <cfqueryparam cfsqltype="cf_sql_integer" value="#get_rows.spec_var_id#">,
                                        <cfqueryparam cfsqltype="cf_sql_varchar" value="#get_rows.spec_var_name#">,
                                    <cfelseif isdefined('row_spect_id#currentrow#') and len(evaluate('row_spect_id#currentrow#'))>
                                        <cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('row_spect_id#currentrow#')#">,
                                        <cfqueryparam cfsqltype="cf_sql_varchar" value="#product_name#">,
                                    <cfelse>
                                        NULL,
                                        NULL,
                                    </cfif>
                                    <cfif isdefined('lot_no') and len(lot_no)><cfqueryparam cfsqltype="cf_sql_nvarchar" value="#lot_no#"><cfelse>NULL</cfif>,
                                    'TL',
                                    <cfif isdefined("other_money_value") and len(other_money_value)><cfqueryparam cfsqltype="cf_sql_float" value="#other_money_value#"><cfelse>NULL</cfif>,					
                                    <cfif isdefined('satir_fiyati') and len(satir_fiyati)><cfqueryparam cfsqltype="cf_sql_float" value="#satir_fiyati#"><cfelse>NULL</cfif>,
                                    <cfif isdefined('prom_amount_discount') and len(prom_amount_discount)><cfqueryparam cfsqltype="cf_sql_float" value="#prom_amount_discount#"><cfelse>NULL</cfif>,
                                    <cfif isdefined("attributes.deliver_date") and isdate('attributes.deliver_date')><cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.deliver_date#"><cfelse>NULL</cfif>,
                                    0,
                                    0,
                                    <cfif len(evaluate('extra_cost#currentrow#'))><cfqueryparam cfsqltype="cf_sql_float" value="#evaluate('extra_cost#currentrow#')#"><cfelse>0</cfif>,
                                    <cfif isdefined('satir_fiyati') and len(satir_fiyati)><cfqueryparam cfsqltype="cf_sql_float" value="#satir_fiyati#"><cfelse>NULL</cfif>
                                )
                            </cfquery>

                            <cfif len( COUNTER_TYPE_ID )> <!--- Sayaç tipi tanımlanmış bir ürün satın alınmışsa aboneye sayaç tanımlanır --->
                                <cfset counter_number = "#randRange(1000, 9999, 'CFMX_COMPAT')#_#randRange(1000, 9999, 'CFMX_COMPAT')#_#randRange(1000, 9999, 'CFMX_COMPAT')#"  />
                                
                                <cfset counter = createObject("component", "V16.sales.cfc.counter") />
                                <cfset counter.insert(
                                    subscription_id: arguments.subscription_id,
                                    counter_number: counter_number,
                                    counter_type: COUNTER_TYPE_ID,
                                    product_id: product_id,
                                    stock_id: stock_id,
                                    amount: quantity*prom_stock_amount,
                                    unit_id: product_unit_id,
                                    unit_name: main_unit,
                                    price_catid: ( isdefined('attributes.prj_discount_price_cat') and len(attributes.prj_discount_price_cat) ) ? attributes.prj_discount_price_cat : '',
                                    price: satir_fiyati,
                                    money: other_money_value
                                ) />
                            </cfif>

                        </cfif>

                        <cfset get_max_row.max_id = get_max_row.identitycol>
                        <cfset attributes.basket_money = 'TL'>
                       
                        <cfquery name="DEL_ROWS" datasource="#DSN#">
                            DELETE FROM
                                #dsn3#.ORDER_PRE_ROWS
                            WHERE
                                <cfif isdefined("get_rows.RECORD_PAR") and len(get_rows.RECORD_PAR)>
                                    RECORD_PAR = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_rows.RECORD_PAR#"> AND
                                <cfelseif isdefined("get_rows.RECORD_CONS") and len(get_rows.RECORD_CONS)>
                                    RECORD_CONS = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_rows.RECORD_CONS#"> AND
                                </cfif>
                                PRODUCT_ID IS NOT NULL
                        </cfquery>
                    </cfoutput>
                </cftransaction>
            </cflock>
            <cfset result.status = true>
            <cfset result.message = "Sipariş Başarıyla Oluşturuldu." >
        <!--- <cfcatch type="any">
            <cfset result.status = false>
            <cfset result.message = "Sipariş Oluşturulurken Bir Hata Oluştu!" >
        </cfcatch>
        </cftry> --->
        
        <cfreturn Replace(serializeJSON(result),'//','')>
    </cffunction>

    <cffunction name="get_pre_order_products" access="remote" returntype="any">
		<cfargument name="consumer_id" default="">
		<cfargument name="partner_id" default="">
        <cfset attributes.price_cat_id = 0>

        <cfquery name="get_products" datasource="#DSN#">
            SELECT
                --(SELECT TOP 1 CM.NICKNAME FROM SHIP_METHOD_PRICE SMP, SHIP_METHOD_PRICE_ROW SMPR, COMPANY CM WHERE SMP.SHIP_METHOD_PRICE_ID = SMPR.SHIP_METHOD_PRICE_ID AND SMP.COMPANY_ID = CM.COMPANY_ID AND SMPR.SHIP_METHOD_ID = OPR.SHIPMENT_ID ) AS SHIPMENT_COMP,
                (SELECT C.CONSUMER_EMAIL FROM CONSUMER C WHERE C.CONSUMER_ID = OPR.RECORD_CONS) AS CONSUMER_EMAIL,
                OPR.QUANTITY,
                OPR.PRODUCT_ID,
                OPR.STOCK_ID,
                CASE 
                    WHEN (PRC.PRICE_KDV IS NOT NULL AND PRC.PRICE_KDV > 0) THEN
                        OPR.QUANTITY * PRC.PRICE_KDV * (SELECT SM.RATE2/SM.RATE1 FROM SETUP_MONEY SM WHERE SM.MONEY_STATUS = 1 AND SM.MONEY = PRC.MONEY AND SM.PERIOD_ID = #session.ep.period_id#)
                    ELSE
                        OPR.QUANTITY * PS.PRICE_KDV * (SELECT SM.RATE2/SM.RATE1 FROM SETUP_MONEY SM WHERE SM.MONEY_STATUS = 1 AND SM.MONEY = PS.MONEY AND SM.PERIOD_ID = #session.ep.period_id#)
                END AS PRICE_KDV_TL,
                CASE 
                    WHEN (PRC.PRICE_KDV IS NOT NULL AND PRC.PRICE_KDV > 0) THEN
                        OPR.QUANTITY * PRC.PRICE * (SELECT SM.RATE2/SM.RATE1 FROM SETUP_MONEY SM WHERE SM.MONEY_STATUS = 1 AND SM.MONEY = PRC.MONEY AND SM.PERIOD_ID = #session.ep.period_id#)
                    ELSE
                        OPR.QUANTITY * PS.PRICE * (SELECT SM.RATE2/SM.RATE1 FROM SETUP_MONEY SM WHERE SM.MONEY_STATUS = 1 AND SM.MONEY = PS.MONEY AND SM.PERIOD_ID = #session.ep.period_id#)
                END AS PRICE_TL,
                CASE WHEN (PRC.PRICE_KDV IS NOT NULL AND PRC.PRICE_KDV > 0) THEN PRC.PRICE_KDV ELSE PS.PRICE_KDV END AS PRICE_KDV,
                CASE WHEN (PRC.PRICE_KDV IS NOT NULL AND PRC.PRICE_KDV > 0) THEN PRC.PRICE ELSE PS.PRICE END AS PRICE,
                CASE WHEN (PRC.PRICE_KDV IS NOT NULL AND PRC.PRICE_KDV > 0) THEN PRC.MONEY ELSE PS.MONEY END AS MONEY,
                '' DELIVER_ID,
                '' INVOICE_DELIVER_ID,
                '' PAYMENT_ID,
                '' SHIPMENT_ID,
                '' ACCOUNT_ID,
                OPR.IS_CARGO,
                OPR.ORDER_ROW_ID,
                '' HAVALE_BANKA,
                '' HAVALE_TARIH,
                '' HAVALE_NO,
                '' ORDER_DETAIL,
                OPR.PRICE AS PRICE_CARGO,
                OPR.RECORD_CONS,
                OPR.RECORD_PAR,
                OPR.SPEC_VAR_ID,
                OPR.IS_SPEC,
                OPR.DISCOUNT1,
                OPR.DISCOUNT2,
                OPR.DISCOUNT3,
                OPR.DISCOUNT4,
                OPR.DISCOUNT5,					
                S.PRODUCT_NAME,
                S.PROPERTY,
                S.TAX,
                S.COUNTER_TYPE_ID,
                PU.MAIN_UNIT,
                PU.PRODUCT_UNIT_ID,
                NULL AS SPEC_VAR_ID,
                ISNULL(OPR.PROM_STOCK_AMOUNT,1) AS PROM_STOCK_AMOUNT,
                OPR.PROM_AMOUNT_DISCOUNT,
                OPR.PROM_DISCOUNT,
                0 AS PRICE_OLD,
                0 AS PROM_COST,
                OPR.PROM_ID,
                OPR.IS_PROM_ASIL_HEDIYE,
                OPR.IS_COMMISSION,
                OPR.IS_PRODUCT_PROMOTION_NONEFFECT,
                OPR.IS_GENERAL_PROM,
                OPR.LOT_NO,
                OPR.DEMAND_ID,
                (SELECT TOP 1 PI.PATH FROM #dsn1#.PRODUCT_IMAGES PI WHERE PI.PRODUCT_ID = OPR.PRODUCT_ID AND PI.IMAGE_SIZE = 2 ORDER BY  PI.PRODUCT_IMAGEID ASC) AS URUN_RESMI,
                ISNULL((SELECT SALEABLE_STOCK FROM  #dsn2#.GET_STOCK_LAST GSL WHERE OPR.STOCK_ID=GSL.STOCK_ID),0) AS STOK_DURUMU
                --,(SELECT DIMENTION FROM #dsn3#.PRODUCT_UNIT PU WHERE PU.PRODUCT_ID = OPR.PRODUCT_ID) AS DESI
            FROM 
                #dsn3#.ORDER_PRE_ROWS OPR
                    LEFT JOIN #dsn1#.PRICE_STANDART PS ON PS.PRODUCT_ID=OPR.PRODUCT_ID
                    LEFT JOIN #dsn3#.STOCKS S ON S.PRODUCT_ID=OPR.PRODUCT_ID
                    LEFT JOIN #dsn3#.PRODUCT_UNIT PU ON S.PRODUCT_ID=PU.PRODUCT_ID
                    LEFT JOIN #dsn3#.PRICE PRC ON 
                            (
                            PRC.PRODUCT_ID = OPR.PRODUCT_ID AND 
                            PRC.PRICE_CATID = #attributes.price_cat_id# AND
                            (PRC.FINISHDATE IS NULL OR PRC.FINISHDATE > #NOW()#)
                            ) 
            WHERE
                PU.IS_MAIN = 1 AND
                PS.PURCHASESALES=1 AND
                PS.PRICESTANDART_STATUS=1
                <cfif len(arguments.consumer_id)>
                    AND RECORD_CONS = #arguments.consumer_id#
                <cfelseif len(arguments.partner_id)>
                    AND RECORD_PAR = #arguments.partner_id#
                <cfelseif isDefined("arguments.cookie_name")>
                    AND COOKIE_NAME = '#arguments.cookie_name#'
                </cfif>
            ORDER BY 
                OPR.IS_CARGO ASC
        </cfquery>
		<cfreturn get_products>
	</cffunction>
</cfcomponent>