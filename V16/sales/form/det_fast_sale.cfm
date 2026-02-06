
<cf_get_lang_set module_name="sales">
    <cfset is_instalment = 1>
    <cfif isnumeric(attributes.order_id)>
        <cfinclude template="../query/get_order_detail.cfm">
    <cfelse>
        <cfset get_order_detail.recordcount = 0>
    </cfif>
    <cfif not (get_order_detail.recordcount) or (isdefined("attributes.active_company") and attributes.active_company neq session.ep.company_id)>
        <cfset hata  = 11>
        <cfsavecontent variable="message"><cf_get_lang_main no='585.Şube Yetkiniz Uygun Değil'> <cf_get_lang_main no='586.Veya'> <cf_get_lang_main no='588.Sirketinizde Böyle Bir Sipariş Bulunamadı'> !</cfsavecontent>
        <cfset hata_mesaj  = message>
        <cfinclude template="../../dsp_hata.cfm">
    <cfelse>
        <cfquery name="GET_ORDERS_SHIP" datasource="#DSN3#">
            SELECT ORDER_ID FROM ORDERS_SHIP WHERE ORDER_ID = #get_order_detail.order_id# AND PERIOD_ID = #session.ep.period_id#
        </cfquery>
        <cfquery name="GET_ORDERS_INVOICE" datasource="#DSN3#">
            SELECT ORDER_ID FROM ORDERS_INVOICE WHERE ORDER_ID = #get_order_detail.order_id# AND PERIOD_ID = #session.ep.period_id#
        </cfquery>
        <cfquery name="get_period" datasource="#dsn3#">
            SELECT KASA_PERIOD_ID AS PERIOD_ID FROM ORDER_CASH_POS WHERE ORDER_ID = #get_order_detail.order_id# AND KASA_PERIOD_ID IS NOT NULL AND ORDER_CASH_POS.IS_CANCEL = 0 
        </cfquery>
        <cfif not get_period.recordcount>
            <cfquery name="get_period" datasource="#dsn3#">
                SELECT PERIOD_ID FROM ORDER_VOUCHER_RELATION WHERE ORDER_ID = #get_order_detail.order_id# AND PERIOD_ID IS NOT NULL
            </cfquery>
        </cfif>
        <cfif get_period.recordcount>
            <cfquery name="get_company" datasource="#dsn#">
                SELECT 
                    PERIOD_ID, 
                    PERIOD, 
                    PERIOD_YEAR, 
                    OUR_COMPANY_ID, 
                    OTHER_MONEY, 
                    RECORD_DATE, 
                    RECORD_IP, 
                    RECORD_EMP, 
                    UPDATE_DATE, 
                    UPDATE_IP, 
                    UPDATE_EMP, 
                    PROCESS_DATE 
                FROM 
                    SETUP_PERIOD 
                WHERE 
                    PERIOD_ID = #get_period.period_id#
            </cfquery>
            <cfset new_dsn2 = '#dsn#_#get_company.period_year#_#get_company.our_company_id#'>
            <cfquery name="get_new_period" datasource="#dsn#">
                SELECT 
                    PERIOD_ID, 
                    PERIOD, 
                    PERIOD_YEAR, 
                    OUR_COMPANY_ID, 
                    OTHER_MONEY, 
                    RECORD_DATE, 
                    RECORD_IP, 
                    RECORD_EMP, 
                    UPDATE_DATE, 
                    UPDATE_IP, 
                    UPDATE_EMP, 
                    PROCESS_DATE 
                FROM 
                    SETUP_PERIOD 
                WHERE 
                    OUR_COMPANY_ID = #get_company.our_company_id# 
                AND 
                    PERIOD_YEAR = #get_company.period_year+1#
            </cfquery>
            <cfif get_new_period.recordcount>
                <cfset new_dsn2_1 = '#dsn#_#get_company.period_year+1#_#get_company.our_company_id#'>
            </cfif>
        <cfelse>
            <cfset get_new_period.recordcount = 0>
            <cfset new_dsn2 = '#dsn2#'>
        </cfif>
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
        <cfquery name="get_sale_vouchers" datasource="#new_dsn2#">
            SELECT 
                VP.PAYROLL_NO,
                VP.ACTION_ID,
                VP.CASH_PAYMENT_VALUE,
                V.VOUCHER_ID,
                V.VOUCHER_VALUE,
                V.VOUCHER_DUEDATE,
                V.IS_PAY_TERM,
                ISNULL(VP.PAYROLL_CASH_ID,0) PAYROLL_CASH_ID,
                <cfif get_new_period.recordcount>
                    ISNULL((SELECT VV.VOUCHER_STATUS_ID FROM #new_dsn2_1#.VOUCHER VV,#dsn_alias#.CHEQUE_VOUCHER_COPY_REF VC WHERE VV.VOUCHER_ID = VC.TO_CHEQUE_VOUCHER_ID AND VC.IS_CHEQUE = 0 AND V.VOUCHER_ID = VC.FROM_CHEQUE_VOUCHER_ID AND VC.TO_PERIOD_ID = #get_new_period.period_id#) ,VOUCHER_STATUS_ID)  AS VOUCHER_STATUS_ID
                <cfelse>
                    V.VOUCHER_STATUS_ID AS VOUCHER_STATUS_ID
                </cfif>
            FROM 
                VOUCHER V, 
                VOUCHER_PAYROLL VP 
            WHERE 
                V.VOUCHER_PAYROLL_ID = VP.ACTION_ID AND 
                VP.PAYMENT_ORDER_ID = #attributes.order_id#
            ORDER BY
                V.VOUCHER_DUEDATE
        </cfquery>
        <cfquery name="get_sale_cheques" datasource="#new_dsn2#">
            SELECT 
                P.PAYROLL_NO,
                P.ACTION_ID,
                C.CHEQUE_ID,
                C.CHEQUE_VALUE,
                C.CHEQUE_DUEDATE,
                C.BANK_NAME,
                C.BANK_BRANCH_NAME,
                C.CHEQUE_NO,
                C.ACCOUNT_NO,
                ISNULL(P.PAYROLL_CASH_ID,0) PAYROLL_CASH_ID,
                <cfif get_new_period.recordcount>
                    ISNULL((SELECT CC.CHEQUE_STATUS_ID FROM #new_dsn2_1#.CHEQUE CC,#dsn_alias#.CHEQUE_VOUCHER_COPY_REF VC WHERE CC.CHEQUE_ID = VC.TO_CHEQUE_VOUCHER_ID AND VC.IS_CHEQUE = 1 AND C.CHEQUE_ID = VC.FROM_CHEQUE_VOUCHER_ID AND VC.TO_PERIOD_ID = #get_new_period.period_id#) ,CHEQUE_STATUS_ID)  AS CHEQUE_STATUS_ID
                <cfelse>
                    C.CHEQUE_STATUS_ID AS CHEQUE_STATUS_ID
                </cfif>
            FROM 
                CHEQUE C, 
                PAYROLL P 
            WHERE 
                C.CHEQUE_PAYROLL_ID = P.ACTION_ID AND 
                P.PAYMENT_ORDER_ID = #attributes.order_id#
            ORDER BY
                C.CHEQUE_DUEDATE
        </cfquery>
        <cfquery name="get_cashes" datasource="#dsn3#">
            SELECT 
                CASH_ID,
                CASH_NAME,
                CASH_ACC_CODE,
                CASH_CODE,
                BRANCH_ID,		
                CASH_CURRENCY_ID,		
                CASH_EMP_ID
            FROM
                #new_dsn2#.CASH CASH
            WHERE
                CASH_ACC_CODE IS NOT NULL 
                <cfif session.ep.isBranchAuthorization>
                    AND 
                    (
                    (CASH.BRANCH_ID IN(SELECT EMPLOYEE_POSITION_BRANCHES.BRANCH_ID FROM #dsn_alias#.EMPLOYEE_POSITION_BRANCHES EMPLOYEE_POSITION_BRANCHES WHERE EMPLOYEE_POSITION_BRANCHES.POSITION_CODE = #session.ep.position_code#))
                    <cfif control_cashes.recordcount>
                        OR
                        CASH.CASH_ID IN(#valuelist(control_cashes.kasa_id)#)					
                    </cfif>
                    <cfif get_sale_vouchers.recordcount>
                        OR
                        CASH.CASH_ID IN(#valuelist(get_sale_vouchers.payroll_cash_id)#)					
                    </cfif>
                    <cfif get_sale_cheques.recordcount>
                        OR
                        CASH.CASH_ID IN(#valuelist(get_sale_cheques.payroll_cash_id)#)					
                    </cfif>
                    )
                </cfif>
            ORDER BY 
                CASH_NAME
        </cfquery>
        <cfquery name="get_pay_vouchers" dbtype="query">
            SELECT * FROM get_sale_vouchers WHERE VOUCHER_STATUS_ID <> 1
        </cfquery>
        <cfquery name="get_total_vouchers" dbtype="query">
            SELECT SUM(VOUCHER_VALUE) AS TOTAL_VALUE FROM get_sale_vouchers WHERE VOUCHER_STATUS_ID <> 1
        </cfquery>
        <cfquery name="get_pay_cheques" dbtype="query">
            SELECT * FROM get_sale_cheques WHERE CHEQUE_STATUS_ID <> 1
        </cfquery>
        <cfquery name="get_total_cheques" dbtype="query">
            SELECT SUM(CHEQUE_VALUE) AS TOTAL_VALUE FROM get_sale_cheques WHERE CHEQUE_STATUS_ID <> 1
        </cfquery>
        <cf_catalystHeader>
        <div class="row">
            <div class="col col-9">
                <div id="siparis_karsilama_raporu"></div>
                <script>
                    AjaxPageLoad("<cfoutput>#request.self#?fuseaction=objects.popup_list_order_receive_rate&order_id=#attributes.order_id#&is_sale=1</cfoutput>",'siparis_karsilama_raporu');
                </script>
            </div>
            <div class="col col-3">
                <cfinclude template="../../sales/display/list_pluses_order.cfm">
            </div>
        </div>
</cfif>