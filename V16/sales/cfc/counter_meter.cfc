<cfcomponent extends="cfc.queryJSONConverter">
    <cfset dsn = application.SystemParam.SystemParam().dsn>
    <cfset dsn3 = "#dsn#_#session.ep.company_id#">
    <cfset dsn_product = "#dsn#_product">

    <cffunction name = "insert" access = "public" hint = "Insert counter meter">
        <cfset response = structNew()>
        <cfset response.status = true>
        <cftry>
            <cfquery name = "insert_counter_meter" datasource = "#dsn3#" result="result">
                INSERT INTO 
                SUBSCRIPTION_COUNTER_METER(
                    SUBSCRIPTION_ID,
                    COUNTER_ID,
                    PREVIOUS_VALUE,
                    LAST_VALUE,
                    DIFFERENCE,
                    LOADING_EMPLOYEE_ID,
                    LOADING_DATE,
                    RECORD_EMP,
                    RECORD_DATE
                )
                VALUES(
                    <cfqueryparam value = "#arguments.subscription_id#" CFSQLType = "cf_sql_integer">,
                    <cfqueryparam value = "#arguments.counter_id#" CFSQLType = "cf_sql_integer">,
                    <cfqueryparam value = "#arguments.previous_value#" CFSQLType = "cf_sql_float">,
                    <cfqueryparam value = "#arguments.last_value#" CFSQLType = "cf_sql_float">,
                    <cfqueryparam value = "#arguments.difference#" CFSQLType = "cf_sql_float">,
                    #session.ep.userid#,
                    <cfqueryparam value = "#arguments.action_date#" CFSQLType = "cf_sql_date">,
                    #session.ep.userid#,
                    #now()#
                )
            </cfquery>
            <cfset response.result = result>
            <cfcatch type = "any">
                <cfset response.status = false>
            </cfcatch>
        </cftry>
        <cfreturn response>
    </cffunction>

    <cffunction name = "select" access = "public" hint = "Select couunter meter">

        <!--- 20190927 TolgaS abone kategorsine göre yetkilendirme için eklendi kontrol şirket akış parametresi varsa kategori yetkisi kontrol ediliyor--->
        <cfset gsa = createObject("component","V16.objects.cfc.subscriptionNauthority")/>
        <cfset GET_SUBSCRIPTION_AUTHORITY= gsa.SelectAuthority()/>

        <cfquery name = "select_counter_meter" datasource = "#dsn3#">
            SELECT 
                SCM.SCM_ID,
                SCM.PREVIOUS_VALUE,
                SCM.LAST_VALUE,
                SCM.COUNTER_ID,
                SCM.DIFFERENCE,
                SCM.LOADING_EMPLOYEE_ID,
                SCM.LOADING_DATE,
                SCM.UPDATE_EMP,
                SCM.UPDATE_DATE,
                SCM.RECORD_EMP,
                SCM.RECORD_DATE,
                SCM.SUBSCRIPTION_ID,
                ISNULL(SCM.IS_PAYMENT_PLAN,0) AS IS_PAYMENT_PLAN,
                SUBSCONT.SUBSCRIPTION_NO,
                SUBSCONT.SUBSCRIPTION_HEAD,
                SUBSCOUNT.COUNTER_NO,
                SUBSCOUNT.PRODUCT_ID,
                SUBSCOUNT.STOCK_ID,
                SUBSCOUNT.UNIT_ID,
                SUBSCOUNT.UNIT,
                P.PRODUCT_NAME,
                WX.WEX_ID,
                EMP.EMPLOYEE_NAME,
                EMP.EMPLOYEE_SURNAME,
                C.FULLNAME,
                C.TAXNO,
                SCT.COUNTER_TYPE,
                OC.COMPANY_NAME AS OUR_COMP_NAME
            FROM SUBSCRIPTION_COUNTER_METER AS SCM
            JOIN SUBSCRIPTION_CONTRACT AS SUBSCONT ON SCM.SUBSCRIPTION_ID = SUBSCONT.SUBSCRIPTION_ID
            JOIN SUBSCRIPTION_COUNTER AS SUBSCOUNT ON SCM.COUNTER_ID = SUBSCOUNT.COUNTER_ID
            LEFT JOIN PRODUCT AS P ON P.PRODUCT_ID = SUBSCOUNT.PRODUCT_ID
            LEFT JOIN #dsn#.COMPANY AS C ON C.COMPANY_ID = SUBSCOUNT.COMPANY_ID 
            LEFT JOIN SETUP_COUNTER_TYPE AS SCT ON SUBSCOUNT.COUNTER_TYPE_ID = SCT.COUNTER_TYPE_ID
            JOIN #dsn#.EMPLOYEES AS EMP ON SCM.LOADING_EMPLOYEE_ID = EMP.EMPLOYEE_ID
            LEFT JOIN #dsn#.WRK_WEX AS WX ON SUBSCOUNT.WEX_CODE = WX.WEX_ID
            LEFT JOIN #dsn#.OUR_COMPANY AS OC ON SUBSCOUNT.OUR_COMPANY_ID = OC.COMP_ID 
            WHERE
                1 = 1
                <cfif isDefined("arguments.scm_id") and len(arguments.scm_id)>
                    AND SCM.SCM_ID = <cfqueryparam value = "#arguments.scm_id#" CFSQLType = "cf_sql_integer">
                </cfif>
                <cfif IsDefined("arguments.keyword") and len(arguments.keyword)>
                    AND (SUBSCONT.SUBSCRIPTION_NO LIKE <cfqueryparam value = "%#arguments.keyword#%" CFSQLType = "cf_sql_nvarchar">
                            OR SUBSCOUNT.COUNTER_NO LIKE <cfqueryparam value = "%#arguments.keyword#%" CFSQLType = "cf_sql_nvarchar">
                            OR SUBSCOUNT.COUNTER_DETAIL LIKE <cfqueryparam value = "%#arguments.keyword#%" CFSQLType = "cf_sql_nvarchar">
                            OR SUBSCONT.SUBSCRIPTION_HEAD LIKE <cfqueryparam value = "%#arguments.keyword#%" CFSQLType = "cf_sql_nvarchar">
                        )
                </cfif>
                <cfif IsDefined("arguments.subscription_id") and len(arguments.subscription_id) and IsDefined("arguments.subscription_no") and len(arguments.subscription_no)>
                    AND SCM.SUBSCRIPTION_ID = <cfqueryparam value = "#arguments.subscription_id#" CFSQLType = "cf_sql_integer">
                </cfif>
                <cfif isdefined("arguments.wex_id") and len(arguments.wex_id) and isdefined("arguments.wex_name") and len(arguments.wex_name)>
                    AND WEX_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.wex_id#">
                </cfif>
                <cfif isdefined("arguments.payment_plan") and len(arguments.payment_plan)>
                    AND ISNULL(SCM.IS_PAYMENT_PLAN,0) = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.payment_plan#">
                </cfif>
                <cfif isdefined("arguments.our_company_id") and len(arguments.our_company_id) >
                    AND SUBSCOUNT.OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.our_company_id#">
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
                SCM.SCM_ID DESC
        </cfquery>
        <cfreturn select_counter_meter>
    </cffunction>

    <cffunction name="update" returntype="any">
        <cfquery name="update_counter_meter" datasource="#DSN3#" result="result">
            UPDATE 
            SUBSCRIPTION_COUNTER_METER
            SET
                SUBSCRIPTION_ID =<cfqueryparam value = "#arguments.subscription_id#" CFSQLType = "cf_sql_integer">,
                COUNTER_ID = <cfqueryparam value = "#arguments.counter_id#" CFSQLType = "cf_sql_integer">,
                PREVIOUS_VALUE = <cfqueryparam value = "#arguments.previous_value#" CFSQLType = "cf_sql_float">,
                LAST_VALUE = <cfqueryparam value = "#arguments.last_value#" CFSQLType = "cf_sql_float">,
                DIFFERENCE = <cfqueryparam value = "#arguments.difference#" CFSQLType = "cf_sql_float">,
                UPDATE_EMP = <cfqueryparam value = "#session.ep.userid#" CFSQLType = "cf_sql_integer">,
                UPDATE_DATE = <cfqueryparam value = "#now()#" CFSQLType = "cf_sql_date">,
                LOADING_DATE = <cfqueryparam value = "#arguments.action_date#" CFSQLType = "cf_sql_date">
            WHERE
                SCM_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.cm_id#">
        </cfquery>
        <cfreturn 1>
    </cffunction>

    <cffunction name="delete" returntype="any">
        <cfquery name="delete_counter_meter" datasource="#DSN3#">
            DELETE FROM
                SUBSCRIPTION_COUNTER_METER
            WHERE
                SCM_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.cm_id#">
        </cfquery>
        <cfreturn 1>
    </cffunction>

    <cffunction name="get_difference" access="remote" returntype="any" returnformat="json">
        <cfquery name = "get_difference" datasource = "#dsn3#">
            SELECT TOP 1 LAST_VALUE, CONVERT(nvarchar(50), LOADING_DATE, 103) AS LOADING_DATE FROM SUBSCRIPTION_COUNTER_METER
            WHERE
                1 = 1
                <cfif isDefined("arguments.counter_id") and len(arguments.counter_id)>
                    AND COUNTER_ID = <cfqueryparam value = "#arguments.counter_id#" CFSQLType = "cf_sql_integer">
                </cfif>
                <cfif IsDefined("arguments.subscription_id") and len(arguments.subscription_id)>
                    AND SUBSCRIPTION_ID = <cfqueryparam value = "#arguments.subscription_id#" CFSQLType = "cf_sql_integer">
                </cfif>
            ORDER BY 
                SCM_ID DESC
        </cfquery>
        <cfreturn replace(serializeJSON(get_difference),"//","")>
    </cffunction>

    <cffunction name="get_detail_meter" access="remote" returntype="any" returnformat="json">
        <cfargument name="subscription_id" required="true">
    
        <cf_date tarih="arguments.last_date">
        <cfquery name="subsc_data" datasource="#dsn3#">
            SELECT C.TAXNO FROM SUBSCRIPTION_COUNTER SC 
            LEFT JOIN #dsn#.COMPANY AS C ON C.COMPANY_ID = SC.COMPANY_ID
            WHERE SC.SUBSCRIPTION_ID = #arguments.subscription_id#
        </cfquery>
        <cfhttp url="http://wex.workcube.com/wex.cfm/e-government_paper/getCounterRow" charset="utf-8" result="result">
            <cfhttpparam name="subscription_no" type="formfield" value="#arguments.subscription_no#" />
            <cfhttpparam name="company_identifier" type="formfield" value="#subsc_data.TAXNO#" />
            <cfif len(arguments.first_date)>
                <cfhttpparam name="first_date" type="formfield" value="#arguments.first_date#" />
            </cfif>
            <cfhttpparam name="last_date" type="formfield" value="#arguments.last_date#" />
            <cfhttpparam name="wex_type" type="formfield" value="#arguments.counter_id#" />
        </cfhttp>
        <cfreturn result.fileContent>
    </cffunction>

</cfcomponent>