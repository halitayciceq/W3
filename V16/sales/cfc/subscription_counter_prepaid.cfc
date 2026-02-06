<cfcomponent>
    <cfset dsn = application.SystemParam.SystemParam().dsn>
    <cfset dsn3 = "#dsn#_#session.ep.company_id#">
    <cfset dsn_product = "#dsn#_product">
    <cffunction name = "insert" access = "public" hint = "Insert subscription prepaid">
        <cfset response = structNew()>
        <cftry>
            <cfquery name = "insert_subscription_counter_prepaid" datasource = "#dsn3#" result="result">
                INSERT INTO 
                SUBSCRIPTION_COUNTER_PREPAID(
                    PROCESS_ROW_ID,
                    COUNTER_ID,
                    COUNTER_LOADING_PRICE,
                    COUNTER_TOTAL_PRICE,
                    COUNTER_LOADING_DATE,
                    LOADING_EMPLOYEE_ID,
                    RECORD_EMP,
                    RECORD_DATE,
                    RECORD_IP
                )
                VALUES(
                    <cfqueryparam value = "#arguments.process_row_id#" CFSQLType = "cf_sql_integer">,
                    <cfqueryparam value = "#arguments.counter_id#" CFSQLType = "cf_sql_integer">,
                    <cfqueryparam value = "#arguments.counter_loading_price#" CFSQLType = "cf_sql_float">,
                    <cfqueryparam value = "#arguments.counter_total_price#" CFSQLType = "cf_sql_float">,
                    <cfqueryparam value = "#arguments.counter_loading_date#" CFSQLType = "cf_sql_date">,
                    <cfqueryparam value = "#arguments.loading_employee_id#" CFSQLType = "cf_sql_integer">,
                    #session.ep.userid#,
                    #now()#,
                    <cfqueryparam value = "#CGI.REMOTE_ADDR#" CFSQLType = "cf_sql_nvarchar">
                )
            </cfquery>
            <cfset response.status = true>
            <cfset response.result = result>
        <cfcatch type="any">
            <cfset response.status = false>    
        </cfcatch>
        </cftry>    
        <cfreturn response>
    </cffunction>
    
    <cffunction name = "select" access = "public" hint = "Select subscription prepaid">
        <!--- 20190927 TolgaS, Ahmet Yolcu abone kategorsine göre yetkilendirme için eklendi kontrol şirket akış parametresi varsa kategori yetkisi kontrol ediliyor--->
        <cfset gsa = createObject("component","V16.objects.cfc.subscriptionNauthority")/>
        <cfset GET_SUBSCRIPTION_AUTHORITY= gsa.SelectAuthority()/>

        <cfquery name = "select_subscription_counter_prepaid" datasource = "#dsn3#">
            SELECT 
                SCP.SCP_ID,
                SCP.PROCESS_ROW_ID,
                SCP.COUNTER_ID,
                SUBSCOUNT.STOCK_ID,
                SUBSCOUNT.PRODUCT_ID,
                SUBSCOUNT.AMOUNT,
                SUBSCOUNT.UNIT_ID,
                SUBSCOUNT.PRICE,
                SUBSCOUNT.OTHER_MONEY,
                SUBSCOUNT.COUNTER_NO,
                SCP.COUNTER_LOADING_PRICE,
                SCP.COUNTER_TOTAL_PRICE,
                SCP.COUNTER_LOADING_DATE,
                SCP.LOADING_EMPLOYEE_ID,
                SCP.RECORD_EMP,
                SCP.RECORD_DATE,
                SCP.UPDATE_EMP,
                SCP.UPDATE_DATE,
                SUBSCONT.SUBSCRIPTION_ID,
                SUBSCONT.SUBSCRIPTION_NO,
                PR.PRODUCT_NAME,
                PRUT.MAIN_UNIT,
                EMP.EMPLOYEE_NAME,
                EMP.EMPLOYEE_SURNAME
            FROM SUBSCRIPTION_COUNTER_PREPAID AS SCP
            JOIN SUBSCRIPTION_COUNTER AS SUBSCOUNT ON SCP.COUNTER_ID = SUBSCOUNT.COUNTER_ID
            JOIN SUBSCRIPTION_CONTRACT AS SUBSCONT ON SUBSCOUNT.SUBSCRIPTION_ID = SUBSCONT.SUBSCRIPTION_ID
            JOIN #dsn_product#.PRODUCT AS PR ON SUBSCOUNT.PRODUCT_ID = PR.PRODUCT_ID
            JOIN #dsn_product#.PRODUCT_UNIT AS PRUT ON SUBSCOUNT.UNIT_ID = PRUT.PRODUCT_UNIT_ID
            JOIN #dsn#.EMPLOYEES AS EMP ON SCP.LOADING_EMPLOYEE_ID = EMP.EMPLOYEE_ID
            WHERE
                1 = 1
                <cfif IsDefined("arguments.scp_id")>
                    AND SCP.SCP_ID = <cfqueryparam value = "#arguments.scp_id#" CFSQLType = "cf_sql_integer">
                </cfif>
                <cfif IsDefined("arguments.keyword") and len(arguments.keyword)>
                    AND (SUBSCONT.SUBSCRIPTION_NO LIKE <cfqueryparam value = "%#arguments.keyword#%" CFSQLType = "cf_sql_nvarchar">
                        OR SUBSCOUNT.COUNTER_NO LIKE <cfqueryparam value = "%#arguments.keyword#%" CFSQLType = "cf_sql_nvarchar">
                </cfif>
                <cfif IsDefined("arguments.subscription_id") and len(arguments.subscription_id) and IsDefined("arguments.subscription_no") and len(arguments.subscription_no)>
                    AND SCP.SUBSCRIPTION_ID = <cfqueryparam value = "#arguments.subscription_id#" CFSQLType = "cf_sql_integer">
                </cfif>
                <cfif IsDefined("arguments.counter_no") and len(arguments.counter_no) gte 3>
                    AND SUBSCOUNT.COUNTER_NO LIKE <cfqueryparam value = "%#arguments.counter_no#%" CFSQLType = "cf_sql_nvarchar">
                </cfif>
                <cfif IsDefined("arguments.product_id") and len(arguments.product_id)>
                    AND PR.PRODUCT_ID = <cfqueryparam value = "#arguments.product_id#" CFSQLType = "cf_sql_integer">
                </cfif>
                <cfif IsDefined("arguments.record_date") and len(arguments.record_date)>
                    AND SCP.COUNTER_LOADING_DATE >= <cfqueryparam value = "#arguments.record_date#" CFSQLType = "cf_sql_date">
                </cfif>
                <cfif IsDefined("arguments.record_date2") and len(arguments.record_date2)>
                    AND SCP.COUNTER_LOADING_DATE <= <cfqueryparam value = "#arguments.record_date2#" CFSQLType = "cf_sql_date">
                </cfif>
                <cfif get_subscription_authority.IS_SUBSCRIPTION_AUTHORITY eq 1>
                    AND EXISTS 
                        (
                            SELECT
                            SPC.SUBSCRIPTION_TYPE_ID
                            FROM        
                            #dsn#.EMPLOYEE_POSITIONS AS EP,
                            SUBSCRIPTION_GROUP_PERM SPC
                            WHERE
                            EP.POSITION_CODE = #session.ep.position_code# AND
                            (
                                SPC.POSITION_CODE = EP.POSITION_CODE OR
                                SPC.POSITION_CAT = EP.POSITION_CAT_ID
                            )
                                AND SUBSCONT.SUBSCRIPTION_TYPE_ID = SPC.SUBSCRIPTION_TYPE_ID
                        )
                </cfif>
            ORDER BY 
                SCP.SCP_ID DESC
        </cfquery>
        <cfreturn select_subscription_counter_prepaid>
    </cffunction>

    <cffunction name = "update" access = "public" hint = "update subscription prepaid">
        <cfset response = structNew()>
        
        <cftry>
            <cfquery name = "update_subscription_counter_prepaid" datasource = "#dsn3#">
                UPDATE  
                    SUBSCRIPTION_COUNTER_PREPAID
                SET
                    PROCESS_ROW_ID = <cfqueryparam value = "#arguments.process_row_id#" CFSQLType = "cf_sql_integer">,
                    COUNTER_ID = <cfqueryparam value = "#arguments.counter_id#" CFSQLType = "cf_sql_integer">,
                    COUNTER_LOADING_PRICE = <cfqueryparam value = "#arguments.counter_loading_price#" CFSQLType = "cf_sql_float">,
                    COUNTER_TOTAL_PRICE = <cfqueryparam value = "#arguments.counter_total_price#" CFSQLType = "cf_sql_float">,
                    COUNTER_LOADING_DATE = <cfqueryparam value = "#arguments.counter_loading_date#" CFSQLType = "cf_sql_date">,
                    LOADING_EMPLOYEE_ID = <cfqueryparam value = "#arguments.loading_employee_id#" CFSQLType = "cf_sql_integer">,
                    UPDATE_EMP = <cfqueryparam value = "#session.ep.userid#" CFSQLType = "cf_sql_nvarchar">,
                    UPDATE_DATE = <cfqueryparam value = "#now()#" CFSQLType = "cf_sql_date">,
                    UPDATE_IP = <cfqueryparam value = "#CGI.REMOTE_ADDR#" CFSQLType = "cf_sql_nvarchar">
                WHERE SCP_ID = <cfqueryparam value = "#arguments.scp_id#" CFSQLType = "cf_sql_integer">
            </cfquery>
            <cfset response.status = true>
            <cfcatch type = "any">
                <cfset response.status = false>
            </cfcatch>
        </cftry>
        <cfreturn response>
    </cffunction>

    <cffunction name = "delete" access = "public" hint = "Delete subscription prepaid">
        <cfset response = structNew()>
        <cftry>
            <cfquery name = "delete_subscription_counter_prepaid" datasource = "#dsn3#">
                DELETE FROM SUBSCRIPTION_COUNTER_PREPAID WHERE SCP_ID = <cfqueryparam value = "#arguments.scp_id#" CFSQLType = "cf_sql_integer">
            </cfquery>
            <cfset response.status = true>
        <cfcatch type="any">
            <cfset response.status = false>    
        </cfcatch>
        </cftry>    
        <cfreturn response>
    </cffunction>
</cfcomponent>