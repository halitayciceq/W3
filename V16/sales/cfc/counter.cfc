<cfcomponent>
    
    <cfset dsn = application.SystemParam.SystemParam().dsn>
    <cfset dsn_product = "#dsn#_product">
    <cfset userid = "">

    <cfif isdefined("session.ep")>
        <cfset dsn3 = "#dsn#_#session.ep.company_id#">
        <cfset userid = "#session.ep.userid#">
    <cfelseif isdefined("session.pp")>
        <cfset dsn3 = "#dsn#_#session.pp.our_company_id#">
    <cfelseif isdefined("session.ww")>
        <cfset dsn3 = "#dsn#_#session.ww.our_company_id#">
    </cfif>

    <cffunction name="sel_GetCM" access="public" hint="Sayaç için yapılan okuma işlemleri">
        <cfquery name="GET_SUBSCRIPTION_COUNTER_METER" datasource="#DSN#">
            SELECT * FROM #dsn3#.SUBSCRIPTION_COUNTER_METER WHERE COUNTER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.counter_id#">
        </cfquery>
        <cfreturn GET_SUBSCRIPTION_COUNTER_METER>
    </cffunction>
    
    <cffunction name="sel_GetCI" access="public" hint="GET COUNTER INVOICE ROW">
        <cfquery name="GET_COUNTER_INVOICE_ROW" datasource="#DSN#">
            SELECT
                SCI.RESULT_ROW_ID,
                SUM(SCI.INVOICE_VALUE) AS TOTAL_INVOICE_VALUE
            FROM
                #dsn3#.SUBSCRIPTION_CONTRACT_INVOICE SCI,
                #dsn3#.SUBSCRIPTION_COUNTER_RESULT_ROW SCRR,
                #dsn3#.SUBSCRIPTION_COUNTER SC
            WHERE
                SCI.RESULT_ROW_ID IS NOT NULL AND
                SCI.RESULT_ROW_ID = SCRR.COUNTER_RESULT_ID AND
                SCRR.COUNTER_ID = SC.COUNTER_ID AND
                SC.COUNTER_ID = #arguments.counter_id# 
            GROUP BY
                SCI.RESULT_ROW_ID
        </cfquery>
        <cfreturn GET_COUNTER_INVOICE_ROW>
    </cffunction>

    <cffunction name="sel_GetCN" access="public" hint="Get Counter Number">
        <cfquery name="GET_COUNTER_NUMBER" datasource="#DSN#">
            SELECT COUNT(COUNTER_ID) AS COUNTER_COUNT FROM #dsn3#.SUBSCRIPTION_COUNTER_RESULT_ROW WHERE COUNTER_ID = #arguments.counter_id# 
        </cfquery>
        <cfreturn GET_COUNTER_NUMBER>
    </cffunction>

    <cffunction name = "select" access = "public" hint = "Select couunter">

        <!--- 20190927 TolgaS abone kategorsine göre yetkilendirme için eklendi kontrol şirket akış parametresi varsa kategori yetkisi kontrol ediliyor--->
        <cfset gsa = createObject("component","V16.objects.cfc.subscriptionNauthority")/>
        <cfset GET_SUBSCRIPTION_AUTHORITY= gsa.SelectAuthority()/>

        <cfquery name = "select_counter" datasource = "#dsn3#">
            SELECT 
                SC.COUNTER_ID,
                SC.COUNTER_NO,
                SC.SUBSCRIPTION_ID,
                SC.COUNTER_STAGE_ID,
                SUBSCONT.SUBSCRIPTION_NO,
                SC.COUNTER_TYPE_ID,
                SCT.COUNTER_TYPE,
                SC.READING_TYPE_ID,
                SC.INVOICE_PERIOD,
                SC.START_VALUE,
                SC.READING_PERIOD,
                SC.START_DATE,
                SC.FINISH_DATE,
                SC.FREE_PERIOD,
                SC.WEX_CODE,
                WX.HEAD,
                SC.STOCK_ID,
                SC.PRODUCT_ID,
                PR.PRODUCT_NAME,
                SC.AMOUNT,
                SC.UNIT,
                SC.UNIT_ID,
                SC.PRICE,
                SC.OTHER_MONEY,
                SC.COUNTER_DETAIL,
                TARIFF.TARIFF_NAME,
                SC.TARIFF,
                SC.PRICE_CATID,
                SC.DOCUMENTS,
                SC.COMPANY_ID,
                SC.CONSUMER_ID,
                SC.RECORD_DATE,
                SC.RECORD_EMP,
                SC.RECORD_IP,
                SC.UPDATE_DATE,
                SC.UPDATE_EMP,
                SC.UPDATE_IP,
                SC.OUR_COMPANY_ID,
                SC.PARTNER_ID,
                OC.COMPANY_NAME
            FROM SUBSCRIPTION_COUNTER AS SC
            JOIN SUBSCRIPTION_CONTRACT AS SUBSCONT ON SC.SUBSCRIPTION_ID = SUBSCONT.SUBSCRIPTION_ID
            JOIN SETUP_COUNTER_TYPE AS SCT ON SC.COUNTER_TYPE_ID = SCT.COUNTER_TYPE_ID
            LEFT JOIN #dsn#.WRK_WEX AS WX ON SC.WEX_CODE = WX.WEX_ID
            LEFT JOIN #dsn_product#.PRODUCT AS PR ON SC.PRODUCT_ID = PR.PRODUCT_ID
            LEFT JOIN SUBSCRIPTION_TARIFF AS TARIFF ON SC.TARIFF = TARIFF.TARIFF_ID
            LEFT JOIN #dsn#.OUR_COMPANY AS OC ON SC.OUR_COMPANY_ID = OC.COMP_ID
            WHERE
                1 = 1
                <cfif IsDefined("arguments.counter_id") and len(arguments.counter_id)>
                    AND SC.COUNTER_ID = <cfqueryparam value = "#arguments.counter_id#" CFSQLType = "cf_sql_nvarchar">
                </cfif>
                <cfif IsDefined("arguments.keyword") and len(arguments.keyword)>
                    AND SC.COUNTER_NO LIKE <cfqueryparam value = "%#arguments.keyword#%" CFSQLType = "cf_sql_nvarchar">
                </cfif>
                <cfif IsDefined("arguments.subscription_id") and len(arguments.subscription_id) and IsDefined("arguments.subscription_no") and len(arguments.subscription_no)>
                    AND SC.SUBSCRIPTION_ID = <cfqueryparam value = "#arguments.subscription_id#" CFSQLType = "cf_sql_integer">
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
                SC.COUNTER_ID DESC
        </cfquery>
        <cfreturn select_counter>
    </cffunction>

    <cffunction name = "insert" access = "public" hint = "Insert counter">
        <cfset response = structNew()>
        <cftry>
            <cfquery name = "insert_counter" datasource = "#dsn#" result="result">
                INSERT INTO
                #dsn3#.SUBSCRIPTION_COUNTER
                (
                    SUBSCRIPTION_ID,
                    COUNTER_STAGE_ID,
                    COUNTER_NO,
                    COUNTER_TYPE_ID,
                    PRODUCT_ID,
                    STOCK_ID,
                    AMOUNT,
                    UNIT_ID,
                    UNIT,
                    PRICE_CATID,
                    PRICE,
                    OTHER_MONEY,
                    START_VALUE,
                    START_DATE,
                    FINISH_DATE,
                    DOCUMENTS,
                    UPLOADED_FILE,
                    COUNTER_DETAIL,
                    RECORD_EMP,
                    RECORD_IP,
                    RECORD_DATE,
                    OUR_COMPANY_ID,
                    PARTNER_ID,
                    COMPANY_ID,
                    CONSUMER_ID
                )
                VALUES
                (
                    <cfif len(arguments.subscription_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_id#"><cfelse>NULL</cfif>,
                    <cfif isDefined("arguments.process_stage") and len(arguments.process_stage)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.process_stage#"><cfelse>NULL</cfif>,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.counter_number#">,
                    <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.counter_type#">,
                    <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.product_id#">,
                    <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.stock_id#">,
                    <cfif isDefined("arguments.amount") and len(arguments.amount)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.amount#"><cfelse>NULL</cfif>,
                    <cfif isDefined("arguments.unit_id") and len(arguments.unit_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.unit_id#"><cfelse>NULL</cfif>,
                    <cfif isDefined("arguments.unit_name") and len(arguments.unit_name)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.unit_name#"><cfelse>NULL</cfif>,
                    <cfif isDefined("arguments.price_catid") and len(arguments.price_catid)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.price_catid#"><cfelse>NULL</cfif>,
                    <cfif isDefined("arguments.price") and len(arguments.price)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.price#"><cfelse>NULL</cfif>,
                    <cfif isDefined("arguments.money") and len(arguments.money)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.money#"><cfelse>NULL</cfif>,
                    <cfif isDefined("arguments.start_value") and len(arguments.start_value)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.start_value#"><cfelse>NULL</cfif>,
                    <cfif isDefined("arguments.start_date") and len(arguments.start_date)><cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.start_date#"><cfelse>NULL</cfif>,
                    <cfif isDefined("arguments.finish_date") and len(arguments.finish_date)><cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.finish_date#"><cfelse>NULL</cfif>,
                    <cfif isDefined("arguments.document") and len(arguments.document)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.document#"><cfelse>NULL</cfif>,
                    <cfif isDefined("arguments.uploaded_file") and len(arguments.uploaded_file)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.uploaded_file#"><cfelse>NULL</cfif>,
                    <cfif isDefined("arguments.counter_detail") and len(arguments.counter_detail)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.counter_detail#"><cfelse>NULL</cfif>,
                    <cfif len(userid)><cfqueryparam cfsqltype="cf_sql_integer" value="#userid#"><cfelse>NULL</cfif>,
                    <cfqueryparam value = "#CGI.REMOTE_ADDR#" CFSQLType = "cf_sql_nvarchar">,
                    <cfqueryparam value = "#now()#" CFSQLType = "cf_sql_date">,
                    <cfif isDefined("arguments.our_company_id") and len(arguments.our_company_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.our_company_id#"><cfelse>NULL</cfif>
                    <cfif isdefined("arguments.member_type") and arguments.member_type is 'partner'>
                        ,<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.partner_id#">
					    ,<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.company_id#">
					    ,NULL
                    <cfelseif isdefined("arguments.member_type") and arguments.member_type is 'consumer'>
                        ,NULL
                        ,NULL
                        ,<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.consumer_id#">
                    <cfelse>
                        ,NULL
                        ,NULL
                        ,NULL
                    </cfif>
                )
            </cfquery>
            <cfset response.status = true>
            <cfset response.result = result>
            <cfcatch type = "any">
                <cfset response.status = false>
            </cfcatch>
        </cftry>
        <cfreturn response>
    </cffunction>

    <cffunction name="update" returntype="any">
        <cfset response = true />
        
            <cfquery name="update_counter" datasource="#DSN#" result="result">
                UPDATE 
                    #dsn3#.SUBSCRIPTION_COUNTER
                SET
                    SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_id#">,
                    COUNTER_STAGE_ID = <cfif isDefined("arguments.process_stage") and len(arguments.process_stage)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.process_stage#"><cfelse>NULL</cfif>,
                    COUNTER_NO = <cfif IsDefined("arguments.counter_number") and len(arguments.counter_number)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.counter_number#"><cfelse>NULL</cfif>,
                    COUNTER_TYPE_ID = <cfif IsDefined("arguments.counter_type") and len(arguments.counter_type)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.counter_type#"><cfelse>NULL</cfif>,
                    PRODUCT_ID = <cfif IsDefined("arguments.product_id") and len(arguments.product_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.product_id#"><cfelse>NULL</cfif>,
                    STOCK_ID = <cfif IsDefined("arguments.stock_id") and len(arguments.stock_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.stock_id#"><cfelse>NULL</cfif>,
                    AMOUNT = <cfif IsDefined("arguments.amount") and len(arguments.amount)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.amount#"><cfelse>NULL</cfif>,
                    UNIT_ID = <cfif IsDefined("arguments.unit_id") and len(arguments.unit_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.unit_id#"><cfelse>NULL</cfif>,
                    UNIT = <cfif IsDefined("arguments.unit_name") and len(arguments.unit_name)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.unit_name#"><cfelse>NULL</cfif>,
                    PRICE_CATID = <cfif IsDefined("arguments.price_catid") and len(arguments.price_catid)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.price_catid#"><cfelse>NULL</cfif>,
                    PRICE = <cfif IsDefined("arguments.price") and len(arguments.price)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.price#"><cfelse>NULL</cfif>,
                    OTHER_MONEY = <cfif IsDefined("arguments.money") and len(arguments.money)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.money#"><cfelse>NULL</cfif>,
                    START_VALUE = <cfif IsDefined("arguments.start_value") and len(arguments.start_value)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.start_value#"><cfelse>NULL</cfif>,
                    START_DATE = <cfif IsDefined("arguments.start_date") and len(arguments.start_date)><cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.start_date#"><cfelse>NULL</cfif>,
                    FINISH_DATE = <cfif IsDefined("arguments.finish_date") and len(arguments.finish_date)><cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.finish_date#"><cfelse>NULL</cfif>,
                    DOCUMENTS = <cfif IsDefined("arguments.document") and len(arguments.document)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.document#"><cfelse>NULL</cfif>,
                    UPLOADED_FILE = <cfif IsDefined("arguments.uploaded_file") and len(arguments.uploaded_file)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.uploaded_file#"><cfelse>NULL</cfif>,
                    COUNTER_DETAIL = <cfif IsDefined("arguments.counter_detail") and len(arguments.counter_detail)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.counter_detail#"><cfelse>NULL</cfif>,
                    UPDATE_EMP = <cfif len(userid)><cfqueryparam cfsqltype="cf_sql_integer" value="#userid#"><cfelse>NULL</cfif>,
                    UPDATE_DATE = <cfqueryparam value = "#now()#" CFSQLType = "cf_sql_date">,
                    UPDATE_IP = <cfqueryparam value = "#CGI.REMOTE_ADDR#" CFSQLType = "cf_sql_nvarchar">,
                    OUR_COMPANY_ID = <cfif isDefined("arguments.our_company_id") and len(arguments.our_company_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.our_company_id#"><cfelse>NULL</cfif>,
                    PARTNER_ID = <cfif isDefined("arguments.company_name") and len(arguments.company_name) and len(arguments.partner_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.partner_id#"><cfelse>NULL</cfif>,
                    COMPANY_ID = <cfif isDefined("arguments.company_name") and len(arguments.company_name) and len(arguments.company_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.company_id#"><cfelse>NULL</cfif>,
                    CONSUMER_ID = <cfif isDefined("arguments.company_name") and len(arguments.company_name) and len(arguments.consumer_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.consumer_id#"><cfelse>NULL</cfif>
                WHERE
                    COUNTER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.counter_id#">
            </cfquery>
        <cfreturn response>
    </cffunction>

    <cffunction name="delete" returntype="any">
        <cfquery name="delete_counter" datasource="#DSN#">
            DELETE FROM #dsn3#.SUBSCRIPTION_COUNTER WHERE COUNTER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.counter_id#">
        </cfquery>
    </cffunction>

</cfcomponent>