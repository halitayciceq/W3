<cfcomponent>
    <cfparam name="dsn" default="#application.SystemParam.SystemParam().dsn#">
    <cfparam name="dsn_alias" default="#application.SystemParam.SystemParam().dsn#">

    <cfif isdefined("session.ep")>
        <cfquery name="get_comp_info" datasource="#dsn#">
            SELECT COMMON_SUBSCRIPTION_USAGE FROM OUR_COMPANY_INFO WHERE COMP_ID = #session.ep.company_id#
        </cfquery>
        <cfif len(get_comp_info.COMMON_SUBSCRIPTION_USAGE)>
            <cfset dsn3 = "#dsn#_#get_comp_info.COMMON_SUBSCRIPTION_USAGE#">
            <cfset dsn3_alias = "#dsn#_#get_comp_info.COMMON_SUBSCRIPTION_USAGE#">
        <cfelse>
            <cfset dsn3 = "#dsn#_#session.ep.company_id#">
            <cfset dsn3_alias = "#dsn#_#session.ep.company_id#">
        </cfif>
        <cfset dsn2 = "#dsn#_#session.ep.period_year#_#session.ep.company_id#">
        <cfset session_base.period_year = session.ep.period_year>
    <cfelseif isdefined("session.pp")>
        <cfset dsn3 = "#dsn#_#session.pp.our_company_id#">
        <cfset dsn3_alias = "#dsn#_#session.pp.our_company_id#">
        <cfset dsn2 = "#dsn#_#session.pp.period_year#_#session.pp.our_company_id#">
        <cfset session_base.period_year = session.pp.period_year>
    <cfelseif isdefined("session.ww")>
        <cfset dsn3_alias = "#dsn#_#session.ww.our_company_id#">
        <cfset dsn3 = "#dsn#_#session.ww.our_company_id#">
        <cfset dsn2 = "#dsn#_#session.ww.period_year#_#session.ww.our_company_id#">
        <cfset session_base.period_year = session.ww.period_year>
    <cfelseif isdefined("session.qq")>
        <cfset dsn3_alias = "#dsn#_#session.qq.our_company_id#">
        <cfset dsn3 = "#dsn#_#session.qq.our_company_id#">
        <cfset dsn2 = "#dsn#_#session.qq.period_year#_#session.qq.our_company_id#">
        <cfset session_base.period_year = session.qq.period_year>
    </cfif>
    <cfif isDefined('session.pp.userid')>
        <cfset userid_ = "#session.pp.userid#">  
        <cfset default_is_efatura = session.pp.our_company_info.IS_EFATURA?:0>
        <cfset money_ = "#session.pp.money#">    
     <cfelseif isDefined('session.ep.userid')> 
         <cfset userid_ = "#session.ep.userid#">      
         <cfset default_is_efatura = session.ep.our_company_info.IS_EFATURA?:0>
         <cfset money_ = "#session.ep.money#"> 
     <cfelseif isDefined('session.ww.userid')>    
         <cfset userid_ = "#session.ww.userid#">     
         <cfset default_is_efatura = session.ep.our_company_info.IS_EFATURA?:0>
         <cfset money_ = "#session.ww.money#"> 
    <cfelseif isDefined('session.qq.userid')>    
        <cfset userid_ = "#session.qq.userid#">     
        <cfset default_is_efatura = session.qq.our_company_info.IS_EFATURA?:0>
        <cfset money_ = "#session.qq.money#"> 
     </cfif>
<!--- List Page --->
    <cffunction name="GET_SUBSCRIPTIONS" returntype="query">
        <cfargument name="DSN3" required="no" default="#dsn3#">
        <cfargument name="dsn_alias" default="">
        <cfargument name="process_stage_type" default="">
        <cfargument name="use_efatura" default="">
        <cfargument name="subs_add_option" default="">
        <cfargument name="sale_add_option" default="">
        <cfargument name="keyword" default="">
        <cfargument name="keyword_no" default="">
        <cfargument name="start_date" default="">
        <cfargument name="finish_date" default="">
        <cfargument name="status" default="">
        <cfargument name="employee_id" default="">
        <cfargument name="company_id" default="">
        <cfargument name="consumer_id" default="">
        <cfargument name="member_cat_type" default="">
        <cfargument name="subscription_type" default="">
        <cfargument name="project_id" default="">
        <cfargument name="sales_emp_id" default="">
        <cfargument name="sales_partner_id" default="">
        <cfargument name="sales_partner_id_pp" default="">
        <cfargument name="product_id" default="">
        <cfargument name="adress_keyword" default="">
        <cfargument name="city_id" default="">
        <cfargument name="county_id" default="">
        <cfargument name="semt_keyword" default="">
        <cfargument name="x_control_ims" default="">
        <cfargument name="sales_zone_followup" default="">
        <cfargument name="sort_type" default="">
        <cfargument name="startrow" default="">
        <cfargument name="maxrows" default="">
        <cfargument name="IS_SUBSCRIPTION_AUTHORITY" default="">
        <cfargument name="asset_id" default="">
        <cfif isdefined("arguments.x_control_ims") and arguments.x_control_ims eq 1 and arguments.sales_zone_followup eq 1>
            <cfinclude template="/member/query/get_ims_control.cfm">
        </cfif>

        <cfquery name="GET_SUBSCRIPTIONS" datasource="#arguments.DSN3#">
            WITH CTE1 AS(
            SELECT
                SC.SUBSCRIPTION_ID,
                SC.SUBSCRIPTION_NO,
                SC.SPECIAL_CODE,
                SC.SUBSCRIPTION_HEAD,
                SC.PARTNER_ID,
                SC.CONSUMER_ID,
                SC.COMPANY_ID,
                SC.SALES_EMP_ID,
                SC.SUBSCRIPTION_STAGE,
                SC.MONTAGE_DATE,
                SC.PROJECT_ID,
                SC.START_DATE,
                SC.FINISH_DATE,
                SC.RECORD_EMP,
                SC.RECORD_CONS,
                SC.SUBSCRIPTION_ADD_OPTION_ID,
                SC.SALES_ADD_OPTION_ID,
                #dsn#.Get_Dynamic_Language(SST.SUBSCRIPTION_TYPE_ID,'<cfif isDefined('session.ep.userid')>#session.ep.language#<cfelseif isDefined('session.pp.userid')>#session.pp.language# <cfelseif isDefined('session.pda.userid')>#session.pda.language#</cfif>','SETUP_SUBSCRIPTION_TYPE','SUBSCRIPTION_TYPE',NULL,NULL,SST.SUBSCRIPTION_TYPE) AS SUBSCRIPTION_TYPE,
                SIP.PROPERTY16,
                SC.IS_ACTIVE
            FROM
                SUBSCRIPTION_CONTRACT SC WITH (NOLOCK)
                LEFT JOIN SUBSCRIPTION_INFO_PLUS AS SIP ON SC.SUBSCRIPTION_ID = SIP.SUBSCRIPTION_ID,
                SETUP_SUBSCRIPTION_TYPE AS SST WITH (NOLOCK)
            WHERE
                SC.SUBSCRIPTION_ID IS NOT NULL AND 
                SST.SUBSCRIPTION_TYPE_ID = SC.SUBSCRIPTION_TYPE_ID 
            <cfif isdefined('arguments.process_stage_type') and len(arguments.process_stage_type)> 
                AND SC.SUBSCRIPTION_STAGE = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.process_stage_type#">
            </cfif>
            <cfif len(arguments.use_efatura)>
                AND (SC.INVOICE_COMPANY_ID IN (SELECT COMPANY_ID FROM #arguments.dsn_alias#.COMPANY WHERE USE_EFATURA = #arguments.use_efatura#)
                OR SC.INVOICE_CONSUMER_ID IN (SELECT CONSUMER_ID FROM #arguments.dsn_alias#.CONSUMER WHERE USE_EFATURA = #arguments.use_efatura#)) 
            </cfif>
            <cfif isdefined('arguments.subs_add_option') and len(arguments.subs_add_option)> 
                AND SC.SUBSCRIPTION_ADD_OPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subs_add_option#">
            </cfif>
            <cfif isdefined('arguments.sale_add_option') and len(arguments.sale_add_option)> 
                AND SC.SALES_ADD_OPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.sale_add_option#">
            </cfif>
            <cfif isdefined("arguments.keyword") and len(arguments.keyword)>
                AND (
                        SC.SUBSCRIPTION_NO LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.keyword#%"> OR
                        SC.SUBSCRIPTION_HEAD LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.keyword#%"> COLLATE SQL_Latin1_General_CP1_CI_AI OR
                        SC.SPECIAL_CODE LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.keyword#%"> COLLATE SQL_Latin1_General_CP1_CI_AI OR
                        SC.CONTRACT_NO = <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.keyword#%"> COLLATE SQL_Latin1_General_CP1_CI_AI OR
                        SC.SUBSCRIPTION_ID IN (SELECT SUBSCRIPTION_ID FROM SUBSCRIPTION_CONTRACT_PARTITION WHERE PARTITION_NUMBER = <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.keyword#%"> COLLATE SQL_Latin1_General_CP1_CI_AI)
                    )
            </cfif>
            <cfif isdefined("arguments.keyword_no") and len(arguments.keyword_no)>
                AND (
                        SC.SUBSCRIPTION_NO = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.keyword_no#"> OR
                        SC.SUBSCRIPTION_ID IN (SELECT SUBSCRIPTION_ID FROM SUBSCRIPTION_CONTRACT_PARTITION WHERE PARTITION_NUMBER = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.keyword_no#">)
                    )
            </cfif>
            <cfif isdefined('arguments.start_date') and len(arguments.start_date)>
                AND SC.START_DATE >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.start_date#">
            </cfif>
            <cfif isdefined('arguments.finish_date') and len(arguments.finish_date)>
                AND SC.FINISH_DATE <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.finish_date#">
            </cfif>
            <cfif isdefined("arguments.status") and len(arguments.status)>
                AND SC.IS_ACTIVE = <cfqueryparam cfsqltype="cf_sql_smallint" value="#arguments.status#">
            </cfif>
            <cfif isDefined("arguments.employee_id") and len(arguments.employee_id)>
                AND SC.RECORD_EMP = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.employee_id#">
            </cfif>
            <cfif len(arguments.company_id)>
                <cfif isDefined("session.pp") and isDefined("sales_partner_id_pp") and len(sales_partner_id_pp)>
                    AND (SC.COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.company_id#"> OR SALES_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.company_id#">) 
                <cfelse>
                    AND SC.COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.company_id#">
                </cfif>
            </cfif>
            <cfif len(arguments.consumer_id)>
                <cfif isDefined("session.pp")>
                    AND (SC.CONSUMER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.consumer_id#"> OR SALES_CONSUMER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.company_id#">) 
                <cfelse>
                    AND SC.CONSUMER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.consumer_id#">
                </cfif>
            </cfif>
            <cfif isdefined("arguments.member_cat_type") and listlen(arguments.member_cat_type,'-') eq 2 and listfirst(arguments.member_cat_type,'-') eq '1'>
                AND SC.COMPANY_ID IN (SELECT COMPANY_ID FROM #arguments.dsn_alias#.COMPANY WHERE COMPANYCAT_ID = #listlast(arguments.member_cat_type,'-')#)
            <cfelseif isdefined("arguments.member_cat_type") and arguments.member_cat_type eq 1>
                AND SC.COMPANY_ID IN (SELECT C.COMPANY_ID FROM #arguments.dsn_alias#.COMPANY C,#arguments.dsn_alias#.COMPANY_CAT CAT WHERE C.COMPANYCAT_ID = CAT.COMPANYCAT_ID)
            </cfif>
            <cfif isdefined("arguments.member_cat_type") and listlen(arguments.member_cat_type,'-') eq 2 and listfirst(arguments.member_cat_type,'-') eq '2'>
                AND SC.CONSUMER_ID IN (SELECT CONSUMER_ID FROM #arguments.dsn_alias#.CONSUMER WHERE CONSUMER_CAT_ID = #listlast(arguments.member_cat_type,'-')#)
            <cfelseif isdefined("arguments.member_cat_type") and arguments.member_cat_type eq 2>
                AND SC.CONSUMER_ID IN (SELECT C.CONSUMER_ID FROM #arguments.dsn_alias#.CONSUMER C,#arguments.dsn_alias#.CONSUMER_CAT CAT WHERE C.CONSUMER_CAT_ID = CAT.CONSCAT_ID)
            </cfif>
            <cfif isdefined('arguments.subscription_type') and len(arguments.subscription_type)> 
                AND SC.SUBSCRIPTION_TYPE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_type#">
            </cfif>
            <cfif isdefined('arguments.project_id') and len(arguments.project_id)> 
                AND SC.PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.project_id#">
            </cfif>
            <cfif isdefined("arguments.sales_emp_id") and len(arguments.sales_emp_id)>
                AND SALES_EMP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.sales_emp_id#">
            </cfif>
            <cfif isdefined("arguments.sales_partner_id") and len(arguments.sales_partner_id)>
                AND SALES_PARTNER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.sales_partner_id#">
            </cfif>
            <cfif len(arguments.product_id)>
                AND SC.SUBSCRIPTION_ID IN (SELECT SUBSCRIPTION_ID FROM SUBSCRIPTION_CONTRACT_ROW WHERE PRODUCT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.product_id#">)
            </cfif>	
            <cfif isdefined("arguments.adress_keyword") and len(arguments.adress_keyword)>
                AND (
                        SC.SHIP_ADDRESS LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.adress_keyword#%"> COLLATE SQL_Latin1_General_CP1_CI_AI OR
                        SC.INVOICE_ADDRESS LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.adress_keyword#%"> COLLATE SQL_Latin1_General_CP1_CI_AI OR
                        SC.CONTACT_ADDRESS LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.adress_keyword#%"> COLLATE SQL_Latin1_General_CP1_CI_AI
                    )
            </cfif>
            <cfif isdefined("arguments.city_id") and len(arguments.city_id)>
                AND (
                        SC.SHIP_CITY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.city_id#"> OR
                        SC.INVOICE_CITY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.city_id#"> OR
                        SC.CONTACT_CITY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.city_id#">
                    )
            </cfif>
            <cfif isdefined("arguments.county_id") and len(arguments.county_id)>
                AND (
                        SC.SHIP_COUNTY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.county_id#"> OR
                        SC.INVOICE_COUNTY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.county_id#"> OR
                        SC.CONTACT_COUNTY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.county_id#">
                    )
            </cfif>
            <cfif isdefined("arguments.semt_keyword") and len(arguments.semt_keyword)>
                AND (
                        SC.SHIP_SEMT LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.semt_keyword#%"> COLLATE SQL_Latin1_General_CP1_CI_AI OR
                        SC.INVOICE_SEMT LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.semt_keyword#%"> COLLATE SQL_Latin1_General_CP1_CI_AI OR
                        SC.CONTACT_SEMT LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.semt_keyword#%"> COLLATE SQL_Latin1_General_CP1_CI_AI
                    )
            </cfif>
            <cfif isdefined("arguments.x_control_ims") and arguments.x_control_ims eq 1 and arguments.sales_zone_followup eq 1>
                AND
                    (
                    (SC.CONSUMER_ID IS NULL AND SC.COMPANY_ID IS NULL ) 
                    OR ( SC.COMPANY_ID IN (#PreserveSingleQuotes(my_ims_comp_list)#) )
                    OR ( SC.CONSUMER_ID IN (#PreserveSingleQuotes(my_ims_cons_list)#) )
                    )
            </cfif>
            <cfif isdefined("arguments.asset_id") and len(arguments.asset_id)>
                AND ASSETP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.asset_id#">
            </cfif>
            <cfif arguments.IS_SUBSCRIPTION_AUTHORITY eq 1>
                AND EXISTS  
                    (
                        SELECT
                        SPC.SUBSCRIPTION_TYPE_ID
                        FROM        
                        #dsn#.EMPLOYEE_POSITIONS AS EP,
                        SUBSCRIPTION_GROUP_PERM SPC
                        WHERE
                        <cfif isDefined('session.pp.position_code')>
                            EP.POSITION_CODE = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.pp.position_code#"> AND  
                        <cfelseif isDefined('session.ep.position_code')> 
                            EP.POSITION_CODE = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.position_code#"> AND 
                        <cfelseif isDefined('session.ww.position_code')> 
                            EP.POSITION_CODE  = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ww.position_code#"> AND  
                        </cfif> 
                        (
                            SPC.POSITION_CODE = EP.POSITION_CODE OR
                            SPC.POSITION_CAT = EP.POSITION_CAT_ID
                        )
                            AND SC.SUBSCRIPTION_TYPE_ID = spc.SUBSCRIPTION_TYPE_ID
                    )
            </cfif>
            ),
                 CTE2 AS (
                        SELECT
                            CTE1.*,
                                ROW_NUMBER() OVER (ORDER BY
                                            <cfif Len(arguments.sort_type) and arguments.sort_type eq 1>
                                                SUBSCRIPTION_NO
                                            <cfelseif  Len(arguments.sort_type) and arguments.sort_type eq 2>
                                                SUBSCRIPTION_TYPE DESC
                                            <cfelseif  Len(arguments.sort_type) and arguments.sort_type eq 3>
                                                SUBSCRIPTION_TYPE 
                                            <cfelseif  Len(arguments.sort_type) and arguments.sort_type eq 4>
                                                START_DATE DESC
                                            <cfelseif  Len(arguments.sort_type) and arguments.sort_type eq 5>
                                                START_DATE 
                                            <cfelseif  Len(arguments.sort_type) and arguments.sort_type eq 6>
                                                SPECIAL_CODE DESC
                                            <cfelseif  Len(arguments.sort_type) and arguments.sort_type eq 7>
                                                SPECIAL_CODE
                                            <cfelse>
                                                SUBSCRIPTION_NO DESC
                                            </cfif>
                            ) AS RowNum,(SELECT COUNT(*) FROM CTE1) AS QUERY_COUNT
                        FROM
                            CTE1
                    )
                    SELECT
                        CTE2.*
                    FROM
                        CTE2
                    WHERE
                        RowNum BETWEEN #arguments.startrow# and #arguments.startrow#+(#arguments.maxrows#-1)
        </cfquery>
        <cfreturn GET_SUBSCRIPTIONS>
    </cffunction>

    <cffunction name="GET_SUBSCRIPTION_TYPE" returntype="query">
        <cfargument name="DSN3" required="yes">
        <cfargument name="IS_SUBSCRIPTION_AUTHORITY" default="">
        <cfquery name="GET_SUBSCRIPTION_TYPE" datasource="#arguments.DSN3#">
            SELECT
                SUBSCRIPTION_TYPE_ID,
                SUBSCRIPTION_TYPE
            FROM 
                SETUP_SUBSCRIPTION_TYPE
            <cfif arguments.IS_SUBSCRIPTION_AUTHORITY eq 1>
                WHERE EXISTS  
                    (
                        SELECT
                        SPC.SUBSCRIPTION_TYPE_ID
                        FROM        
                        #dsn#.EMPLOYEE_POSITIONS AS EP,
                        SUBSCRIPTION_GROUP_PERM SPC
                        WHERE
                        <cfif isDefined('session.pp.position_code')>
                            EP.POSITION_CODE = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.pp.position_code#"> AND  
                        <cfelseif isDefined('session.ep.position_code')> 
                            EP.POSITION_CODE = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.position_code#"> AND 
                        <cfelseif isDefined('session.ww.position_code')> 
                            EP.POSITION_CODE  = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ww.position_code#"> AND  
                        </cfif> 
                        (
                            SPC.POSITION_CODE = EP.POSITION_CODE OR
                            SPC.POSITION_CAT = EP.POSITION_CAT_ID
                        )
                            AND SETUP_SUBSCRIPTION_TYPE.SUBSCRIPTION_TYPE_ID = spc.SUBSCRIPTION_TYPE_ID
                    )
            </cfif>
            ORDER BY
                SUBSCRIPTION_TYPE
        </cfquery>
        <cfreturn GET_SUBSCRIPTION_TYPE>
    </cffunction>

    <cffunction name="GET_SUBS_ADD_OPTION" returntype="query">
        <cfargument name="DSN3" required="yes">
        <cfquery name="GET_SUBS_ADD_OPTION" datasource="#arguments.DSN3#">
            SELECT
                SUBSCRIPTION_ADD_OPTION_ID,
                SUBSCRIPTION_ADD_OPTION_NAME
            FROM
                SETUP_SUBSCRIPTION_ADD_OPTIONS
        </cfquery>
        <cfreturn GET_SUBS_ADD_OPTION>
    </cffunction>

    <cffunction name="GET_SALE_ADD_OPTION" returntype="query">
        <cfargument name="DSN3" required="yes">
        <cfargument name="language" default="">
        <cfquery name="GET_SALE_ADD_OPTION" datasource="#arguments.DSN3#">
            SELECT
                CASE
                    WHEN LEN(SLI.ITEM) > 0 THEN SLI.ITEM
                    ELSE SALES_ADD_OPTION_NAME
                END AS SALES_ADD_OPTION_NAME,
                SALES_ADD_OPTION_ID
            FROM
                SETUP_SALES_ADD_OPTIONS
                LEFT JOIN #DSN#.SETUP_LANGUAGE_INFO SLI ON SLI.UNIQUE_COLUMN_ID = SETUP_SALES_ADD_OPTIONS.SALES_ADD_OPTION_ID
                AND SLI.COLUMN_NAME = <cfqueryparam cfsqltype="cf_sql_varchar" value="SALES_ADD_OPTION_NAME">
                AND SLI.TABLE_NAME = <cfqueryparam cfsqltype="cf_sql_varchar" value="SETUP_SALES_ADD_OPTIONS">
                AND SLI.LANGUAGE = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.language#">
            ORDER BY
                SALES_ADD_OPTION_NAME
        </cfquery>
        <cfreturn GET_SALE_ADD_OPTION>
    </cffunction>

    <cffunction name="GET_SERVICE_STAGE" returntype="query">
        <cfargument name="company_id" default="">
        <cfquery name="GET_SERVICE_STAGE" datasource="#DSN#">
            SELECT
                PTR.STAGE,
                PTR.PROCESS_ROW_ID 
            FROM
                PROCESS_TYPE_ROWS PTR,
                PROCESS_TYPE_OUR_COMPANY PTO,
                PROCESS_TYPE PT
            WHERE
                PT.IS_ACTIVE = 1 AND
                PT.PROCESS_ID = PTR.PROCESS_ID AND
                PT.PROCESS_ID = PTO.PROCESS_ID AND
                PTO.OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.company_id#"> AND
                PT.FACTION LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%sales.add_subscription_contract%">
            ORDER BY
                PTR.LINE_NUMBER
        </cfquery>
        <cfreturn GET_SERVICE_STAGE>
    </cffunction>

    <cffunction name="GET_COMPANY_CAT" returntype="query">
        <cfargument name="company_id" default="">
        <cfargument name="userid" default="">
        <cfquery name="GET_COMPANY_CAT" datasource="#DSN#">
            SELECT DISTINCT	
                COMPANYCAT_ID,
                COMPANYCAT
            FROM
                GET_MY_COMPANYCAT
            WHERE
                EMPLOYEE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#"> AND
                OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.company_id#">
            ORDER BY
                COMPANYCAT
        </cfquery>
        <cfreturn GET_COMPANY_CAT>
    </cffunction>

    <cffunction name="GET_CONSUMER_CAT" returntype="query">
        <cfargument name="company_id" default="">
        <cfargument name="userid" default="">
        <cfquery name="GET_CONSUMER_CAT" datasource="#DSN#">
            SELECT DISTINCT	
                CONSCAT_ID,
                CONSCAT,
                HIERARCHY
            FROM
                GET_MY_CONSUMERCAT
            WHERE
            <cfif isDefined('session.pp.userid')>
                EMPLOYEE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.pp.userid#">   
            <cfelseif isDefined('session.ep.userid')> 
                EMPLOYEE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#">  
            <cfelseif isDefined('session.ww.userid')> 
                EMPLOYEE_ID  = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ww.userid#">   
            </cfif> AND
            <cfif isDefined('session.pp.company_id')>
                OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.pp.company_id#">   
            <cfelseif isDefined('session.ep.company_id')> 
                OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#">  
            <cfelseif isDefined('session.ww.company_id')> 
                OUR_COMPANY_ID  = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ww.company_id#">   
            </cfif>
            ORDER BY
                HIERARCHY		
        </cfquery>
        <cfreturn GET_CONSUMER_CAT>
    </cffunction>

    <cffunction name="GET_PARTNER" returntype="query">
        <cfargument name="partner_list" default="">
        <cfargument name="partner_email" default="">
        <cfquery name="GET_PARTNER" datasource="#DSN#">
            SELECT
                COMPANY_PARTNER.COMPANY_PARTNER_NAME,
                COMPANY_PARTNER.COMPANY_PARTNER_SURNAME,
                COMPANY_PARTNER.PARTNER_ID,
                COMPANY_PARTNER.COMPANY_PARTNER_EMAIL,
                COMPANY_PARTNER.MOBIL_CODE,
                COMPANY_PARTNER.MOBILTEL,
                COMPANY.FULLNAME,
                COMPANY.NICKNAME,
                COMPANY.COMPANY_ID
            FROM 
                COMPANY_PARTNER,
                COMPANY
            WHERE 
                COMPANY_PARTNER.COMPANY_ID = COMPANY.COMPANY_ID
                <cfif IsDefined("arguments.partner_list") and len(arguments.partner_list)>
                    AND COMPANY_PARTNER.PARTNER_ID IN (#arguments.partner_list#)
                </cfif>
                <cfif IsDefined("arguments.partner_email") and len(arguments.partner_email)>
                    AND COMPANY_PARTNER.COMPANY_PARTNER_EMAIL = <cfqueryparam value = "#arguments.partner_email#" CFSQLType = "cf_sql_nvarchar">
                </cfif>
            ORDER BY
                COMPANY_PARTNER.PARTNER_ID
        </cfquery>
        <cfreturn GET_PARTNER>
    </cffunction>

    <cffunction name="GET_CONSUMER" returntype="query">
        <cfargument name="consumer_list" default="">
        <cfquery name="get_consumer" datasource="#dsn#">
            SELECT CONSUMER_ID,CONSUMER_NAME,CONSUMER_SURNAME FROM CONSUMER WHERE CONSUMER_ID IN (#arguments.consumer_list#) ORDER BY CONSUMER_ID
        </cfquery>
        <cfreturn get_consumer>
    </cffunction>

    <cffunction name="GET_EMPLOYEE" returntype="query">
        <cfargument name="employee_list" default="">
        <cfquery name="GET_EMPLOYEE" datasource="#DSN#">
            SELECT EMPLOYEE_NAME,EMPLOYEE_SURNAME,EMPLOYEE_ID FROM EMPLOYEES WHERE EMPLOYEE_ID IN (#arguments.employee_list#) ORDER BY EMPLOYEE_ID
        </cfquery>
        <cfreturn GET_EMPLOYEE>
    </cffunction>

    <cffunction name="GET_PROCESS_TYPE" returntype="query">
        <cfargument name="process_list" default="">
        <cfquery name="get_process_type" datasource="#dsn#">
            SELECT #dsn#.Get_Dynamic_Language(PROCESS_ROW_ID,'<cfif isDefined('session.ep.userid')>#session.ep.language#<cfelseif isDefined('session.pp.userid')>#session.pp.language# <cfelseif isDefined('session.pda.userid')>#session.pda.language#</cfif>','PROCESS_TYPE_ROWS','STAGE',NULL,NULL,STAGE) AS STAGE,PROCESS_ROW_ID,LINE_NUMBER FROM PROCESS_TYPE_ROWS WHERE PROCESS_ROW_ID IN (#arguments.process_list#) ORDER BY PROCESS_ROW_ID
        </cfquery>
        <cfreturn get_process_type>
    </cffunction>
<!---  --->

<!--- Add Page --->
    <cffunction name="GET_SALE_ADD_OPTION_F" returntype="query">
        <cfargument name="DSN3" default="">
        <cfquery name="GET_SALE_ADD_OPTION" datasource="#arguments.DSN3#">
            SELECT
                SERVICE_ADD_OPTION_ID,
                SERVICE_ADD_OPTION_NAME
            FROM
                SETUP_SERVICE_ADD_OPTIONS
            ORDER BY
                SERVICE_ADD_OPTION_NAME
        </cfquery>
        <cfreturn GET_SALE_ADD_OPTION>
    </cffunction>

    <cffunction name="GET_SALES_ZONES" returntype="query">
        <cfquery name="GET_SALES_ZONES" datasource="#dsn#">
            SELECT IS_ACTIVE,SZ_ID,SZ_NAME FROM SALES_ZONES
        </cfquery>
        <cfreturn GET_SALES_ZONES>
    </cffunction>

    <cffunction name="get_addres_company" returntype="query">
        <cfargument name="company_id" default="">
        <cfquery name="get_addres" datasource="#DSN#">
            SELECT
                COMPANY_ID MEMBER_ID,
                FULLNAME,
                COMPANY_ADDRESS ADDRESS,
                COMPANY_POSTCODE POSTCODE,
                COUNTY COUNTY,
                CITY CITY,
                COUNTRY COUNTRY,
                COMPANY_TELCODE TELCODE,
                COMPANY_TEL1 TEL,	
                SEMT SEMT,
                COORDINATE_1,
                COORDINATE_2,
                SALES_COUNTY SZ_ID,
                '' IS_INVOICE_ADDRESS
            FROM 
                COMPANY
            WHERE
                COMPANY_STATUS = 1 
                <cfif len(arguments.company_id)>AND COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.company_id#"></cfif>
            UNION ALL 
            SELECT
                C.COMPANY_ID MEMBER_ID,
                C.FULLNAME + ' - ' + CB.COMPBRANCH__NAME FULLNAME,
                CB.COMPBRANCH_ADDRESS ADDRESS,
                CB.COMPBRANCH_POSTCODE POSTCODE,
                CB.COUNTY_ID COUNTY,
                CB.CITY_ID CITY,
                CB.COUNTRY_ID COUNTRY,
                CB.COMPBRANCH_TELCODE TELCODE,
                CB.COMPBRANCH_TEL1 TEL,
                CB.SEMT SEMT,
                CB.COORDINATE_1,
                CB.COORDINATE_2,
                CB.SZ_ID,
                CB.IS_INVOICE_ADDRESS
            FROM	
                COMPANY_BRANCH CB,
                COMPANY C
            WHERE 
                CB.COMPANY_ID = C.COMPANY_ID AND
                CB.COMPBRANCH_STATUS = 1 
                <cfif len(arguments.company_id)> AND C.COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.company_id#"></cfif>
        </cfquery>
        <cfreturn get_addres>
    </cffunction>

    <cffunction name="get_addres_consumer" returntype="query">
        <cfargument name="consumer_id" default="">
        <cfquery name="get_addres" datasource="#DSN#">
            SELECT
                CONSUMER_NAME + ' ' + CONSUMER_SURNAME FULLNAME,
                CONSUMER_ID MEMBER_ID,
                TAX_ADRESS ADDRESS,
                TAX_POSTCODE POSTCODE,
                TAX_COUNTY_ID COUNTY,
                TAX_CITY_ID CITY,
                TAX_COUNTRY_ID COUNTRY,
                '' TELCODE,
                '' TEL,
                TAX_SEMT SEMT,
                COORDINATE_1,
                COORDINATE_2,
                '' SZ_ID,
                '' IS_INVOICE_ADDRESS
            FROM 
                CONSUMER
            WHERE
                CONSUMER_STATUS = 1
                <cfif len(arguments.consumer_id)>AND CONSUMER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.consumer_id#"></cfif>
            UNION ALL
            SELECT 
                C.CONSUMER_NAME + ' ' + C.CONSUMER_SURNAME + ' - ' + CB.CONTACT_NAME FULLNAME,
                C.CONSUMER_ID MEMBER_ID,
                CB.CONTACT_ADDRESS ADDRESS,
                CB.CONTACT_POSTCODE POSTCODE,
                CB.CONTACT_COUNTY_ID COUNTY,
                CB.CONTACT_CITY_ID CITY,
                CB.CONTACT_COUNTRY_ID COUNTRY,
                CB.CONTACT_TELCODE TELCODE,
                CB.CONTACT_TEL1 TEL,
                CB.CONTACT_SEMT SEMT,
                '' COORDINATE_1,
                '' COORDINATE_2,
                '' SZ_ID,
                '' IS_INVOICE_ADDRESS
            FROM
                CONSUMER C,
                CONSUMER_BRANCH CB
            WHERE
                CB.CONSUMER_ID = C.CONSUMER_ID AND
                CB.STATUS = 1
                <cfif len(arguments.consumer_id)> AND C.CONSUMER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.consumer_id#"></cfif>
        </cfquery>
        <cfreturn get_addres>
    </cffunction>

    <cffunction name="get_country_detail" returntype="query">
        <cfargument name="COUNTRY" default="">
        <cfquery name="get_country_detail" datasource="#dsn#">
            SELECT COUNTRY_ID, COUNTRY_NAME FROM SETUP_COUNTRY WHERE 1=1 <cfif len(arguments.COUNTRY)>AND COUNTRY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.COUNTRY#"></cfif>
         </cfquery>
        <cfreturn get_country_detail>
    </cffunction>

    <cffunction name="get_city_detail" returntype="query">
        <cfargument name="CITY" default="">
        <cfargument name="COUNTRY_ID" default="">
        <cfquery name="get_city_detail" datasource="#dsn#">
            SELECT CITY_ID, CITY_NAME FROM SETUP_CITY WHERE 1=1 
            <cfif len(arguments.CITY)>AND CITY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.CITY#"></cfif>
            <cfif len(arguments.COUNTRY_ID)>AND COUNTRY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.COUNTRY_ID#"></cfif>
        </cfquery>
        <cfreturn get_city_detail>
    </cffunction>

    <cffunction name="get_county_detail" returntype="query">
        <cfargument name="CITY" default="">
        <cfargument name="COUNTY" default="">
        <cfquery name="get_county_detail" datasource="#dsn#">
            SELECT COUNTY_ID, COUNTY_NAME FROM SETUP_COUNTY 
            WHERE 1=1 
            <cfif len(arguments.COUNTY)>AND COUNTY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.COUNTY#"></cfif>
            <cfif len(arguments.CITY)>AND CITY = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.CITY#"></cfif>
        </cfquery>
        <cfreturn get_county_detail>
    </cffunction>

    <cffunction name="get_district_detail" returntype="query">
        <cfargument name="COUNTY_ID" default="">
        <cfquery name="get_district_detail" datasource="#dsn#">
            SELECT DISTRICT_ID, DISTRICT_NAME FROM SETUP_DISTRICT 
            WHERE 1=1 
            <cfif len(arguments.COUNTY_ID)>AND COUNTY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.COUNTY_ID#"></cfif>
        </cfquery>
        <cfreturn get_district_detail>
    </cffunction>

    <cffunction name="get_ref_state" returntype="query">
        <cfargument name="dsn3" default="">
        <cfargument name="REFERANCE_STATUS_ID" default="">
        <cfquery name="get_ref_state" datasource="#arguments.dsn3#">
            SELECT REFERANCE_STATUS,REFERANCE_STATUS_ID FROM SETUP_REFERANCE_STATUS WHERE IS_ACTIVE = 1
            <cfif len(arguments.REFERANCE_STATUS_ID)>
            UNION
            SELECT
                REFERANCE_STATUS,
                REFERANCE_STATUS_ID
            FROM
                SETUP_REFERANCE_STATUS
            WHERE
                1=1
                <cfif len(arguments.REFERANCE_STATUS_ID)>AND REFERANCE_STATUS_ID  = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.REFERANCE_STATUS_ID#"></cfif>
            </cfif>
        </cfquery>
        <cfreturn get_ref_state>
    </cffunction>

    <cffunction name="GET_MONEY_INFO" returntype="query">
        <cfargument name="dsn2" default="">
        <cfquery name="GET_MONEY_INFO" datasource="#arguments.dsn2#">
            SELECT * FROM SETUP_MONEY ORDER BY MONEY_ID
        </cfquery>
        <cfreturn GET_MONEY_INFO>
    </cffunction>

    <cffunction name="GET_BRANCH_ALL" returntype="query">
        <cfquery name="GET_BRANCH_ALL" datasource="#DSN#">
            SELECT
                BRANCH.BRANCH_NAME,
                BRANCH.BRANCH_ID,
                BRANCH.COMPANY_ID
            FROM
                BRANCH
        </cfquery>
        <cfreturn GET_BRANCH_ALL>
    </cffunction>

    <cffunction name="GET_SUBSCRIPTION_F" returntype="query">
        <cfargument name="DSN3" default="">
        <cfargument name="dsn_alias" default="">
        <cfargument name="subscription_id" default="">
        <cfquery name="GET_SUBSCRIPTION" datasource="#arguments.DSN3#">
            SELECT
                SC.*,<!--- sistem kopyalamada kullanılan alanlarda var --->
                SST.SUBSCRIPTION_TYPE,
                CB.COMPBRANCH_ALIAS AS ALIAS
            FROM 
                SUBSCRIPTION_CONTRACT SC
                LEFT JOIN #arguments.dsn_alias#.COMPANY_BRANCH CB ON SC.INVOICE_ADDRESS_ID = CB.COMPBRANCH_ID,
                SETUP_SUBSCRIPTION_TYPE	SST
            WHERE
                <cfif len(arguments.subscription_id)>SC.SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_id#"> AND</cfif>
                SC.SUBSCRIPTION_TYPE_ID = SST.SUBSCRIPTION_TYPE_ID		
        </cfquery>
        <cfreturn GET_SUBSCRIPTION>
    </cffunction>

    <cffunction name="UPD_GEN_PAP" returntype="any">
        <cfargument name="DSN3" default="">
        <cfargument name="paper_number" default="">
        <cfquery name="UPD_GEN_PAP" datasource="#arguments.DSN3#">
			UPDATE 
				GENERAL_PAPERS
			SET
				SUBSCRIPTION_NUMBER = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.paper_number#">
			WHERE
				SUBSCRIPTION_NUMBER IS NOT NULL
		</cfquery>
    </cffunction>

    <cffunction name="Check_No" returntype="query">
        <cfargument name="dsn3" default="">
        <cfargument name="paper_code" default="">
        <cfargument name="paper_number" default="">
        <cfargument name="subscription_no" default="">
        <cfquery name="Check_No" datasource="#arguments.dsn3#">
            SELECT SUBSCRIPTION_NO FROM SUBSCRIPTION_CONTRACT WHERE
            <cfif isDefined("arguments.subscription_no") and len(arguments.subscription_no)>
                SUBSCRIPTION_NO = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.subscription_no#">
            <cfelse>
                SUBSCRIPTION_NO = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.paper_code & '-' & arguments.paper_number#">
            </cfif>
        </cfquery>
        <cfreturn Check_No>
    </cffunction>

    <cffunction name="Get_Paper_Number_Code" returntype="query">
        <cfargument name="dsn3" default="#dsn3#">
        <cfquery name="Get_Paper_Number_Code" datasource="#arguments.dsn3#">
            SELECT SUBSCRIPTION_NO, SUBSCRIPTION_NUMBER FROM GENERAL_PAPERS WHERE SUBSCRIPTION_NUMBER IS NOT NULL
        </cfquery>
        <cfreturn Get_Paper_Number_Code>
    </cffunction>

    <cffunction name = "create_subscription_code" returnType = "string" access="public">
    
        <cfset strUpperCaseAlpha = UCase("abcdefghijklmnopqrstuvwxyz") />
        <cfset strNumbers = "0123456789" />

        <cfset strAllValidChars = ( strUpperCaseAlpha & strNumbers ) />

        <cfset code = ArrayNew( 1 ) />
        <cfset code_key = "" />
        <cfset code[ 1 ] = Mid( strNumbers, RandRange( 1, Len( strNumbers ) ), 1 ) />
        <cfset code[ 2 ] = Mid( strUpperCaseAlpha, RandRange( 1, Len( strUpperCaseAlpha ) ), 1 ) />

        <cfloop from="1" to="16" index="intChar">
            <cfset code_key &= (Mid(strAllValidChars, RandRange( 1, Len( strAllValidChars ) ), 1)) & ( (intChar mod 4 eq 0 and intChar neq 16) ? '-' : '' ) />
        </cfloop>
        
        <cfset Check_No = this.Check_No(dsn3: dsn3, subscription_no: code_key) />

        <cfif Check_No.recordcount>
            <cfset this.create_subscription_code() />
        <cfelse>
            <cfreturn code_key />
        </cfif>

    </cffunction>

    <cffunction name="ADD_SUBSCRIPTION_CONTRACT" returntype="any">
        <cfargument name="DSN3" default="#dsn3#">
        <cfargument name="opp_id" default="">
        <cfargument name="member_type" default="">
        <cfargument name="sales_member_type" default="">
        <cfargument name="ref_member_type" default="">
        <cfargument name="IS_EFATURA" default="#default_is_efatura#">
        <cfargument name="wrk_id" default="">
        <cfargument name="invoice_member_name" default="">
        <cfargument name="invoice_company_id" default="">
        <cfargument name="invoice_partner_id" default="">
        <cfargument name="invoice_consumer_id" default="">
        <cfargument name="company_id" default="">
        <cfargument name="partner_id" default="">
        <cfargument name="consumer_id" default="">
        <cfargument name="paper_code" default="">
        <cfargument name="paper_number" default="">
        <cfargument name="subscription_head" default="">
        <cfargument name="subscription_type" default="">
        <cfargument name="sales_emp_id" default="">
        <cfargument name="sales_member_id" default="">
        <cfargument name="sales_company_id" default="">
        <cfargument name="ref_company" default="">
        <cfargument name="ref_company_id" default="">
        <cfargument name="ref_member_id" default="">
        <cfargument name="ref_member" default="">
        <cfargument name="start_date" default="">
        <cfargument name="ship_id" default="">
        <cfargument name="contact_sales_zone_id" default="">
        <cfargument name="premium_value" default="">
        <cfargument name="BASKET_DISCOUNT_TOTAL" default>
        <cfargument name="basket_net_total" default="">
        <cfargument name="basket_gross_total" default="">
        <cfargument name="basket_tax_total" default="">
        <cfargument name="basket_otv_total" default="">
        <cfargument name="basket_money" default="">
        <cfargument name="BASKET_RATE1" default="">
        <cfargument name="BASKET_RATE2" default="">
        <cfargument name="subs_add_option" default="">
        <cfargument name="sales_add_option" default="">
        <cfargument name="valid_days" default="">
        <cfargument name="start_clock_1" default="">
        <cfargument name="start_minute_1" default="">
        <cfargument name="finish_clock_1" default="">
        <cfargument name="finish_minute_1" default="">
        <cfargument name="start_clock_2" default="">
        <cfargument name="start_minute_2" default="">
        <cfargument name="finish_clock_2" default="">
        <cfargument name="finish_minute_2" default="">
        <cfargument name="start_clock_3" default="">
        <cfargument name="start_minute_3" default="">
        <cfargument name="finish_clock_3" default="">
        <cfargument name="finish_minute_3" default="">
        <cfargument name="general_date" default="">
        <cfargument name="hour1" default="">
        <cfargument name="minute1" default="">
        <cfargument name="camp_id" default="">
        <cfargument name="response_hour1" default="">
        <cfargument name="response_minute1" default="">
        <cfargument name="userid" default="#userid_#">
        <cfargument name="remote_addr" default="#cgi.remote_addr#">
        <cfargument name="record_date" default="#now()#">
        <cfargument name="ref_state" default="">
        <cfargument name="comp_branch" default="">
        <cfargument name="subscription_no" default="">
        
        <cftry>
            <cfquery name="ADD_SUBSCRIPTION_CONTRACT" datasource="#arguments.DSN3#" result="my_result">
                INSERT INTO SUBSCRIPTION_CONTRACT
                (
                    WRK_ID,
                    INVOICE_COMPANY_ID,
                    INVOICE_CONSUMER_ID,
                    INVOICE_PARTNER_ID,
                    SUBSCRIPTION_NO,  
                    IS_ACTIVE,
                    SUBSCRIPTION_HEAD,
                    OPP_ID,
                    <cfif isdefined("arguments.member_type") and arguments.member_type is 'partner'>
                    PARTNER_ID,
                    COMPANY_ID,					
                    <cfelseif isdefined("arguments.member_type") and arguments.member_type is 'consumer'>
                    CONSUMER_ID,
                    </cfif>
                    SUBSCRIPTION_TYPE_ID,		  		
                    SUBSCRIPTION_STAGE,
                    SALES_EMP_ID,
                    <cfif isdefined("arguments.sales_member_type") and arguments.sales_member_type is 'partner'>
                    SALES_PARTNER_ID,
                    SALES_COMPANY_ID,
                    <cfelseif isdefined("arguments.sales_member_type") and arguments.sales_member_type is 'consumer'>
                    SALES_CONSUMER_ID,
                    </cfif>
                    SALES_MEMBER_COMM_VALUE,
                    SALES_MEMBER_COMM_MONEY,
                    <cfif isdefined("arguments.ref_member_type") and arguments.ref_member_type is 'partner'>
                    REF_PARTNER_ID,
                    REF_COMPANY_ID,					
                    <cfelseif isdefined("arguments.ref_member_type") and arguments.ref_member_type is 'consumer'>
                    REF_CONSUMER_ID,
                    <cfelseif isdefined("arguments.ref_member_type") and arguments.ref_member_type is 'employee'>
                    REF_EMPLOYEE_ID,
                    </cfif>
                    PRODUCT_ID,  
                    STOCK_ID,
                    CONTRACT_NO,
                    MONTAGE_EMP_ID,
                    PAYMENT_TYPE_ID,
                    PAYMENT_TYPE_CREDITCARD_ID, 
                    MONTAGE_DATE,
                    START_DATE, 
                    FINISH_DATE,
                    SUBSCRIPTION_DETAIL,
                    SUBSCRIPTION_INVOICE_DETAIL,
                    SPECIAL_CODE,
                    SHIP_ADDRESS,
                    SHIP_POSTCODE,
                    SHIP_SEMT,
                    SHIP_COUNTY_ID,
                    SHIP_CITY_ID,
                    SHIP_COUNTRY_ID,
                    SHIP_SZ_ID,
                    INVOICE_ADDRESS,
                    INVOICE_POSTCODE,
                    INVOICE_SEMT,
                    INVOICE_COUNTY_ID,
                    INVOICE_CITY_ID,
                    INVOICE_COUNTRY_ID,	
                    INVOICE_SZ_ID,
                    INVOICE_ADDRESS_ID,					
                    CONTACT_ADDRESS,
                    CONTACT_POSTCODE,
                    CONTACT_SEMT,
                    CONTACT_COUNTY_ID,
                    CONTACT_CITY_ID,
                    CONTACT_COUNTRY_ID,
                    CONTACT_SZ_ID,
                    PREMIUM_VALUE,  
                    DISCOUNTTOTAL,
                    NETTOTAL,
                    GROSSTOTAL,
                    TAXTOTAL,
                    OTV_TOTAL,
                    OTHER_MONEY,
                    OTHER_MONEY_VALUE,
                    SUBSCRIPTION_ADD_OPTION_ID,
                    SALES_ADD_OPTION_ID,
                    PROJECT_ID, 
                    SA_DISCOUNT,
                    ASSETP_ID,
                    VALID_DAYS,
                    START_CLOCK_1,
                    START_MINUTE_1,
                    FINISH_CLOCK_1,
                    FINISH_MINUTE_1,
                    START_CLOCK_2,
                    START_MINUTE_2,
                    FINISH_CLOCK_2,
                    FINISH_MINUTE_2,
                    START_CLOCK_3,
                    START_MINUTE_3,
                    FINISH_CLOCK_3,
                    FINISH_MINUTE_3,
                    IS_GENERAL_DATE,
                    HOUR1,
                    MINUTE1,
                    RESPONSE_HOUR1,
                    RESPONSE_MINUTE1,
                    CAMPAIGN_ID,
                    RECORD_EMP,
                    RECORD_IP,
                    RECORD_DATE,
                    SHIP_COORDINATE_1,
                    SHIP_COORDINATE_2,
                    INVOICE_COORDINATE_1,
                    INVOICE_COORDINATE_2,  
                    CONTACT_COORDINATE_1, 
                    CONTACT_COORDINATE_2,
                    REFERANCE_STATUS_ID,
                    BRANCH_ID,
                    OUR_COMPANY_ID       
                )
                VALUES
                (
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.wrk_id#">,
                    <cfif len(arguments.invoice_member_name) and len(arguments.invoice_company_id)>
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.invoice_company_id#">,
                        NULL,
                        <cfif len(arguments.invoice_partner_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.invoice_partner_id#"><cfelse>NULL</cfif>,
                    <cfelseif len(arguments.invoice_member_name) and len(arguments.invoice_consumer_id)>
                        NULL,
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.invoice_consumer_id#">,
                        NULL,
                    <cfelseif arguments.member_type is 'partner'>
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.company_id#">,
                        NULL,
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.partner_id#">,
                    <cfelseif arguments.member_type is 'consumer'>
                        NULL,
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.consumer_id#">,
                        NULL,
                    </cfif>
                    <cfif IsDefined("arguments.paper_code") and len(arguments.paper_code) and IsDefined("arguments.paper_number") and len(arguments.paper_number)>
                        <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.paper_code & '-' & arguments.paper_number#">,
                    <cfelseif isDefined("arguments.subscription_no") and len(arguments.subscription_no)>
                        <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.subscription_no#">,
                    <cfelse>
                        NULL,
                    </cfif>
                    <cfif isdefined("arguments.is_active") and len(arguments.is_active)>1<cfelse>0</cfif>,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.subscription_head#">,
                    <cfif isdefined("arguments.opp_id") and len(arguments.opp_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.opp_id#"><cfelse>NULL</cfif>,
                    <cfif arguments.member_type is 'partner'>
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.partner_id#">,
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.company_id#">,					
                    <cfelseif arguments.member_type is 'consumer'>
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.consumer_id#">,
                    </cfif>
                    <cfif isdefined("arguments.subscription_type") and len(arguments.subscription_type)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_type#"><cfelse>NULL</cfif>,
                    <cfif isdefined("arguments.process_stage") and len(arguments.process_stage)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.process_stage#"><cfelse>NULL</cfif>,
                    <cfif isdefined("arguments.sales_emp_id") and len(arguments.sales_emp_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.sales_emp_id#"><cfelse>NULL</cfif>,
                    <cfif isdefined("arguments.sales_member_type") and arguments.sales_member_type is 'partner'>
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.sales_member_id#">,
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.sales_company_id#">,
                    <cfelseif isdefined("arguments.sales_member_type") and arguments.sales_member_type is 'consumer'>
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.sales_member_id#">,
                    </cfif>
                    <cfif isdefined("arguments.sales_member_comm_value") and len(arguments.sales_member_comm_value)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.sales_member_comm_value#"><cfelse>NULL</cfif>,
                    <cfif isdefined("arguments.sales_member_comm_money") and len(arguments.sales_member_comm_money)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.sales_member_comm_money#"><cfelse>NULL</cfif>,
                    <cfif isdefined("arguments.ref_member_type") and arguments.ref_member_type is 'partner'>
                        <cfif len(arguments.ref_company)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ref_member_id#"><cfelse>NULL</cfif>,
                        <cfif len(arguments.ref_company)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ref_company_id#"><cfelse>NULL</cfif>,					
                    <cfelseif isdefined("arguments.ref_member_type") and arguments.ref_member_type is 'consumer'>
                        <cfif len(arguments.ref_member)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ref_member_id#"><cfelse>NULL</cfif>,
                    <cfelseif isdefined("arguments.ref_member_type") and arguments.ref_member_type is 'employee'>
                        <cfif len(arguments.ref_member)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ref_member_id#"><cfelse>NULL</cfif>,
                    </cfif>
                    <cfif isdefined("arguments.subscription_product_id") and len(arguments.subscription_product_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_product_id#"><cfelse>NULL</cfif>,
                    <cfif isdefined("arguments.subscription_stock_id") and len(arguments.subscription_stock_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_stock_id#"><cfelse>NULL</cfif>,
                    <cfif isdefined("arguments.contract_no") and len(arguments.contract_no)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.contract_no#"><cfelse>NULL</cfif>,
                    <cfif isdefined("arguments.montage_emp_id") and len(arguments.montage_emp_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.montage_emp_id#"><cfelse>NULL</cfif>,
                    <cfif isdefined("arguments.payment_type_id") and len(arguments.payment_type_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.payment_type_id#"><cfelse>NULL</cfif>,
                    <cfif isdefined("arguments.payment_type_creditcard_id") and len(arguments.payment_type_creditcard_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.payment_type_creditcard_id#"><cfelse>NULL</cfif>,
                    <cfif isdefined("arguments.montage_date") and len(arguments.montage_date)><cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.montage_date#"><cfelse>NULL</cfif>,
                    <cfif isDefined("arguments.start_date") and len(arguments.start_date)><cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.start_date#"><cfelse>NULL</cfif>,
                    <cfif isdefined("arguments.finish_date") and len(arguments.finish_date)><cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.finish_date#"><cfelse>NULL</cfif>,
                    <cfif isdefined("arguments.detail") and len(arguments.detail)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.detail#"><cfelse>NULL</cfif>,
                    <cfif isdefined("arguments.inv_detail") and len(arguments.inv_detail)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.inv_detail#"><cfelse>NULL</cfif>,
                    <cfif isdefined("arguments.main_special_code") and len(arguments.main_special_code)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.main_special_code#"><cfelse>NULL</cfif>,
                    <cfif isDefined("arguments.ship_address") and Len(arguments.ship_address)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.ship_address#"><cfelse>NULL</cfif>,
                    <cfif isDefined("arguments.ship_postcode") and Len(arguments.ship_postcode)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.ship_postcode#"><cfelse>NULL</cfif>,
                    <cfif isDefined("arguments.ship_semt") and Len(arguments.ship_semt)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.ship_semt#"><cfelse>NULL</cfif>,
                    <cfif isdefined("arguments.ship_county_id") and len(arguments.ship_county_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ship_county_id#"><cfelse>NULL</cfif>,
                    <cfif isdefined("arguments.ship_city_id") and len(arguments.ship_city_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ship_city_id#"><cfelse>NULL</cfif>,
                    <cfif isdefined("arguments.ship_country_id") and len(arguments.ship_country_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ship_country_id#"><cfelse>NULL</cfif>,
                    <cfif isdefined("arguments.ship_sales_zone_id") and len(arguments.ship_sales_zone_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ship_sales_zone_id#"><cfelse>NULL</cfif>,
                    <cfif isdefined("arguments.invoice_address") and len(arguments.invoice_address)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.invoice_address#"><cfelse>NULL</cfif>,
                    <cfif isdefined("arguments.invoice_postcode") and len(arguments.invoice_postcode)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.invoice_postcode#"><cfelse>NULL</cfif>,
                    <cfif isdefined("arguments.invoice_semt") and len(arguments.invoice_semt)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.invoice_semt#"><cfelse>NULL</cfif>,
                    <cfif isdefined("arguments.invoice_county_id") and len(arguments.invoice_county_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.invoice_county_id#"><cfelse>NULL</cfif>,
                    <cfif isdefined("arguments.invoice_city_id") and len(arguments.invoice_city_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.invoice_city_id#"><cfelse>NULL</cfif>,
                    <cfif isdefined("arguments.invoice_country_id") and len(arguments.invoice_country_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.invoice_country_id#"><cfelse>NULL</cfif>,				
                    <cfif isdefined("arguments.invoice_sales_zone_id") and len(arguments.invoice_sales_zone_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.invoice_sales_zone_id#"><cfelse>NULL</cfif>,
                    <cfif isdefined("arguments.ship_id") and len(arguments.ship_id) and arguments.IS_EFATURA eq 1><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ship_id#"><cfelse>NULL</cfif>,
                    <cfif isdefined("arguments.contact_address") and len(arguments.contact_address)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.contact_address#"><cfelse>NULL</cfif>,		
                    <cfif isdefined("arguments.contact_postcode") and len(arguments.contact_postcode)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.contact_postcode#"><cfelse>NULL</cfif>,		
                    <cfif isdefined("arguments.contact_semt") and len(arguments.contact_semt)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.contact_semt#"><cfelse>NULL</cfif>,		
                    <cfif isdefined("arguments.contact_county_id") and len(arguments.contact_county_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.contact_county_id#"><cfelse>NULL</cfif>,
                    <cfif isdefined("arguments.contact_city_id") and len(arguments.contact_city_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.contact_city_id#"><cfelse>NULL</cfif>,
                    <cfif isdefined("arguments.contact_country_id") and len(arguments.contact_country_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.contact_country_id#"><cfelse>NULL</cfif>,
                    <cfif isdefined("arguments.contact_sales_zone_id") and len(arguments.contact_sales_zone_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.contact_sales_zone_id#"><cfelse>NULL</cfif>,
                    <cfif isdefined("arguments.premium_value") and len(arguments.premium_value)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.premium_value#"><cfelse>NULL</cfif>,
                    <cfif isdefined("arguments.BASKET_DISCOUNT_TOTAL") and len(arguments.BASKET_DISCOUNT_TOTAL)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.BASKET_DISCOUNT_TOTAL#"><cfelse>0</cfif>,
                    <cfif isdefined("arguments.basket_net_total") and len(arguments.basket_net_total)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.basket_net_total#"><cfelse>0</cfif>,
                    <cfif isdefined("arguments.basket_gross_total") and len(arguments.basket_gross_total)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.basket_gross_total#"><cfelse>0</cfif>,
                    <cfif isdefined("arguments.basket_tax_total") and len(arguments.basket_tax_total)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.basket_tax_total#"><cfelse>0</cfif>,
                    <cfif isdefined("arguments.basket_otv_total") and len(arguments.basket_otv_total)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.basket_otv_total#"><cfelse>0</cfif>,
                    <cfif isDefined("arguments.basket_money") and len(arguments.basket_money)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.basket_money#"><cfelse>NULL</cfif>,
                    <cfif len(arguments.BASKET_NET_TOTAL) and len(arguments.BASKET_RATE1) and len(arguments.BASKET_RATE2)><cfqueryparam cfsqltype="cf_sql_float" value="#((arguments.BASKET_NET_TOTAL*arguments.BASKET_RATE1)/arguments.BASKET_RATE2)#"><cfelse>0</cfif>,
                    <cfif isDefined("arguments.subs_add_option") and len(arguments.subs_add_option)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subs_add_option#"><cfelse>NULL</cfif>,
                    <cfif isDefined("arguments.sales_add_option") and len(arguments.sales_add_option)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.sales_add_option#"><cfelse>NULL</cfif>,
                    <cfif isdefined("arguments.project_id") and len(arguments.project_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.project_id#"><cfelse>NULL</cfif>,
                    <cfif isdefined("arguments.genel_indirim") and len(arguments.genel_indirim)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.genel_indirim#"><cfelse>0</cfif>,
                    <cfif isdefined('arguments.asset_id') and len(arguments.asset_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.asset_id#"><cfelse>NULL</cfif>,
                    <cfif isdefined('arguments.valid_days') and len(arguments.valid_days)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.valid_days#"><cfelse>NULL</cfif>,
                    <cfif isdefined('arguments.start_clock_1') and len(arguments.start_clock_1)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.start_clock_1#"><cfelse>NULL</cfif>,
                    <cfif isdefined('arguments.start_minute_1') and len(arguments.start_minute_1)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.start_minute_1#"><cfelse>NULL</cfif>,
                    <cfif isdefined('arguments.finish_clock_1') and len(arguments.finish_clock_1)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.finish_clock_1#"><cfelse>NULL</cfif>,
                    <cfif isdefined('arguments.finish_minute_1') and len(arguments.finish_minute_1)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.finish_minute_1#"><cfelse>NULL</cfif>,
                    <cfif isdefined('arguments.start_clock_2') and len(arguments.start_clock_2)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.start_clock_2#"><cfelse>NULL</cfif>,
                    <cfif isdefined('arguments.start_minute_2') and len(arguments.start_minute_2)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.start_minute_2#"><cfelse>NULL</cfif>,
                    <cfif isdefined('arguments.finish_clock_2') and len(arguments.finish_clock_2)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.finish_clock_2#"><cfelse>NULL</cfif>,
                    <cfif isdefined('arguments.finish_minute_2') and len(arguments.finish_minute_2)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.finish_minute_2#"><cfelse>NULL</cfif>,
                    <cfif isdefined('arguments.start_clock_3') and len(arguments.start_clock_3)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.start_clock_3#"><cfelse>NULL</cfif>,
                    <cfif isdefined('arguments.start_minute_3') and len(arguments.start_minute_3)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.start_minute_3#"><cfelse>NULL</cfif>,
                    <cfif isdefined('arguments.finish_clock_3') and len(arguments.finish_clock_3)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.finish_clock_3#"><cfelse>NULL</cfif>,
                    <cfif isdefined('arguments.finish_minute_3') and len(arguments.finish_minute_3)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.finish_minute_3#"><cfelse>NULL</cfif>,
                    <cfif isdefined("arguments.general_date") and len(arguments.general_date)>1<cfelse>0</cfif>,
                    <cfif isdefined('arguments.hour1') and len(arguments.hour1)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.hour1#"><cfelse>NULL</cfif>,
                    <cfif isdefined('arguments.minute1') and len(arguments.minute1)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.minute1#"><cfelse>NULL</cfif>,
                    <cfif isdefined('arguments.response_hour1') and len(arguments.response_hour1)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.response_hour1#"><cfelse>NULL</cfif>,
                    <cfif isdefined('arguments.response_minute1') and len(arguments.response_minute1)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.response_minute1#"><cfelse>NULL</cfif>,
                    <cfif isdefined('arguments.camp_id') and Len(arguments.camp_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.camp_id#"><cfelse>NULL</cfif>,
                    <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.remote_addr#">,
                    <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.record_date#">,
                    <cfif isdefined('arguments.ship_coordinate_1') and len(arguments.ship_coordinate_1)><cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.ship_coordinate_1#"><cfelse>NULL</cfif>,
                    <cfif isdefined('arguments.ship_coordinate_2') and len(arguments.ship_coordinate_2)><cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.ship_coordinate_2#"><cfelse>NULL</cfif>,
                    <cfif isdefined('arguments.invoice_coordinate_1') and len(arguments.invoice_coordinate_1)><cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.invoice_coordinate_1#"><cfelse>NULL</cfif>,
                    <cfif isdefined('arguments.invoice_coordinate_2') and len(arguments.invoice_coordinate_2)><cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.invoice_coordinate_2#"><cfelse>NULL</cfif>,
                    <cfif isdefined('arguments.contact_coordinate_1') and len(arguments.contact_coordinate_1)><cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.contact_coordinate_1#"><cfelse>NULL</cfif>,
                    <cfif isdefined('arguments.contact_coordinate_2') and len(arguments.contact_coordinate_2)><cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.contact_coordinate_2#"><cfelse>NULL</cfif>,
                    <cfif isdefined('arguments.ref_state') and len(arguments.ref_state)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ref_state#"><cfelse>NULL</cfif>,
                    <cfif isdefined('arguments.comp_branch') and len(arguments.comp_branch)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.comp_branch#"><cfelse>NULL</cfif>,
                    <cfif isdefined('arguments.our_company_id') and len(arguments.our_company_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.our_company_id#"><cfelse>NULL</cfif>
                )
            </cfquery>
            <cfreturn true>
            <cfcatch type="any">
                <cfreturn false>
            </cfcatch>
        </cftry>
    </cffunction>

    <cffunction name="GET_MAX_SUBSCRIPTION" returntype="query">
        <cfargument name="DSN3" default="">
        <cfargument name="wrk_id" default="">
        <cfquery name="GET_MAX_SUBSCRIPTION" datasource="#arguments.DSN3#">
			SELECT MAX(SUBSCRIPTION_ID) AS SUBSCRIPTION_ID FROM	SUBSCRIPTION_CONTRACT WHERE 1=1 <cfif len(arguments.wrk_id)>AND WRK_ID = <cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.wrk_id#"></cfif>
		</cfquery>
        <cfreturn GET_MAX_SUBSCRIPTION>
    </cffunction>

    <cffunction name="ADD_CONTRACT_ROW" returntype="any">
        <cfargument name="DSN3" default="">
        <cfargument name="price" default="">
        <cfargument name="spect_id" default="">
        <cfargument name="subscription_id" default="">
        <cfargument name="product_name" default="">
        <cfargument name="product_name_other" default="">
        <cfargument name="stock_id" default="">
        <cfargument name="product_id" default="">
        <cfargument name="amount" default="">
        <cfargument name="unit" default="">
        <cfargument name="unit_id" default="">
        <cfargument name="tax" default="">
        <cfargument name="indirim1" default="">
        <cfargument name="indirim2" default="">
        <cfargument name="indirim3" default="">
        <cfargument name="indirim4" default="">
        <cfargument name="indirim5" default="">
        <cfargument name="indirim6" default="">
        <cfargument name="indirim7" default="">
        <cfargument name="indirim8" default="">
        <cfargument name="indirim9" default="">
        <cfargument name="indirim10" default="">
        <cfargument name="DISCOUNT_AMOUNT" default="">
        <cfargument name="row_lasttotal" default="">
        <cfargument name="row_nettotal" default="">
        <cfargument name="row_taxtotal" default="">
        <cfargument name="spect_name" default="">
        <cfargument name="paymethod_id" default="">
        <cfargument name="lot_no" default="">
        <cfargument name="other_money" default="">
        <cfargument name="other_money_value" default="">
        <cfargument name="price_other" default="">
        <cfargument name="other_money_gross_total" default="">
        <cfargument name="iskonto_tutar" default="">
        <cfargument name="basket_extra_info" default="">
        <cfargument name="select_info_extra" default="">
        <cfargument name="detail_info_extra" default="">
        <cfargument name="deliver_date" default="">
        <cfargument name="otv_oran" default="">
        <cfargument name="row_otvtotal" default="">
        <cfargument name="extra_cost" default="">
        <cfargument name="list_price" default="">
        <cfargument name="basket_employee_id" default="">
        <cfargument name="row_bsmv_rate" default="">
        <cfargument name="row_bsmv_amount" default="">
        <cfargument name="row_bsmv_currency" default="">
        <cfargument name="row_oiv_rate" default="">
        <cfargument name="row_oiv_amount" default="">
        <cfargument name="row_tevkifat_rate" default="">
        <cfargument name="row_tevkifat_amount" default="">
        <cfquery name="ADD_CONTRACT_ROW" datasource="#arguments.DSN3#">
            INSERT INTO
                SUBSCRIPTION_CONTRACT_ROW
            (
                SUBSCRIPTION_ID,
                PRODUCT_NAME,
                PRODUCT_NAME2,
                STOCK_ID,
                PRODUCT_ID,
                AMOUNT,
                UNIT,
                UNIT_ID,					
                TAX,
                <cfif len(arguments.price)>PRICE,</cfif>
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
            <cfif isdefined('arguments.spect_id') and len(arguments.spect_id)>					
                SPECT_VAR_ID,
                SPECT_VAR_NAME,
            </cfif>
                PAYMETHOD_ID,
                LOT_NO,
                OTHER_MONEY,
                OTHER_MONEY_VALUE,					
                PRICE_OTHER,
                OTHER_MONEY_GROSS_TOTAL,
                DISCOUNT_COST,
                BASKET_EXTRA_INFO_ID,
                SELECT_INFO_EXTRA,
                DETAIL_INFO_EXTRA,
                DELIVER_DATE,
                OTV_ORAN,
                OTVTOTAL,
                EXTRA_COST,
                LIST_PRICE,
                BASKET_EMPLOYEE_ID
                <cfif isdefined('arguments.row_bsmv_rate') and len(arguments.row_bsmv_rate)>,BSMV_RATE</cfif>
                <cfif isdefined('arguments.row_bsmv_amount') and len(arguments.row_bsmv_amount)>,BSMV_AMOUNT</cfif>
                <cfif isdefined('arguments.row_bsmv_currency') and len(arguments.row_bsmv_currency)>,BSMV_CURRENCY</cfif>
                <cfif isdefined('arguments.row_oiv_rate') and len(arguments.row_oiv_rate)>,OIV_RATE</cfif>
                <cfif isdefined('arguments.row_oiv_amount') and len(arguments.row_oiv_amount)>,OIV_AMOUNT</cfif>
                <cfif isdefined('arguments.row_tevkifat_rate') and len(arguments.row_tevkifat_rate)>,TEVKIFAT_RATE</cfif>
                <cfif isdefined('arguments.row_tevkifat_amount') and len(arguments.row_tevkifat_amount)>,TEVKIFAT_AMOUNT</cfif>
            )
            VALUES
            (
                <cfif len(arguments.subscription_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_id#"><cfelse>NULL</cfif>,
                <cfif len(arguments.product_name)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.product_name#"><cfelse>NULL</cfif>,
                <cfif isdefined('arguments.product_name_other') and len(arguments.product_name_other)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.product_name_other#"><cfelse>NULL</cfif>,			
                <cfif len(arguments.stock_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.stock_id#"><cfelse>NULL</cfif>,
                <cfif len(arguments.product_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.product_id#"><cfelse>NULL</cfif>,
                <cfif len(arguments.amount)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.amount#"><cfelse>NULL</cfif>,
                <cfif len(arguments.unit)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.unit#"><cfelse>NULL</cfif>,
                <cfif len(arguments.unit_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.unit_id#"><cfelse>NULL</cfif>,
                <cfif len(arguments.tax)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.tax#"><cfelse>NULL</cfif>,
                <cfif len(arguments.price)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.price#"><cfelse>NULL</cfif>,
                <cfif len(arguments.indirim1)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.indirim1#"><cfelse>NULL</cfif>,					
                <cfif len(arguments.indirim2)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.indirim2#"><cfelse>NULL</cfif>,
                <cfif len(arguments.indirim3)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.indirim3#"><cfelse>NULL</cfif>,
                <cfif len(arguments.indirim4)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.indirim4#"><cfelse>NULL</cfif>,
                <cfif len(arguments.indirim5)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.indirim5#"><cfelse>NULL</cfif>,
                <cfif len(arguments.indirim6)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.indirim6#"><cfelse>NULL</cfif>,
                <cfif len(arguments.indirim7)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.indirim7#"><cfelse>NULL</cfif>,
                <cfif len(arguments.indirim8)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.indirim8#"><cfelse>NULL</cfif>,
                <cfif len(arguments.indirim9)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.indirim9#"><cfelse>NULL</cfif>,
                <cfif len(arguments.indirim10)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.indirim10#"><cfelse>NULL</cfif>,
                <cfif len(arguments.DISCOUNT_AMOUNT)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.DISCOUNT_AMOUNT#"><cfelse>NULL</cfif>,
                <cfif len(arguments.row_lasttotal)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.row_lasttotal#"><cfelse>NULL</cfif>,
                <cfif len(arguments.row_nettotal)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.row_nettotal#"><cfelse>NULL</cfif>,
                <cfif len(arguments.row_taxtotal)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.row_taxtotal#"><cfelse>NULL</cfif>,
            <cfif isdefined('arguments.spect_id') and len(arguments.spect_id)><!--- Burasi olacak mi ??? --->
                <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.spect_id#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.spect_name#">,
            </cfif>
                <cfif isdefined("arguments.paymethod_id") and len(arguments.paymethod_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.paymethod_id#">,<cfelse>NULL,</cfif>
                <cfif isdefined('arguments.lot_no') and len(arguments.lot_no)><cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.lot_no#"><cfelse>NULL</cfif>,<!--- Burasi olacak mi ??? --->
                <cfif isdefined('arguments.other_money') and len(arguments.other_money)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.other_money#"><cfelse>NULL</cfif>,
                <cfif isdefined("arguments.other_money_value") and len(arguments.other_money_value)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.other_money_value#"><cfelse>NULL</cfif>,					
                <cfif isdefined('arguments.price_other') and len(arguments.price_other)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.price_other#"><cfelse>NULL</cfif>,
                <cfif isdefined("arguments.other_money_gross_total") and len(arguments.other_money_gross_total)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.other_money_gross_total#"><cfelse>0</cfif>,
                <cfif isdefined('arguments.iskonto_tutar') and len(arguments.iskonto_tutar)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.iskonto_tutar#"><cfelse>NULL</cfif>,
                <cfif isdefined('arguments.basket_extra_info') and len(arguments.basket_extra_info)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.basket_extra_info#"><cfelse>NULL</cfif>,
                <cfif isdefined('arguments.select_info_extra') and len(arguments.select_info_extra)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.select_info_extra#"><cfelse>NULL</cfif>,
                <cfif isdefined('arguments.detail_info_extra') and len(arguments.detail_info_extra)><cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.detail_info_extra#"><cfelse>NULL</cfif>,
                <cfif isdefined("arguments.deliver_date") and len(arguments.deliver_date)><cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.deliver_date#"><cfelse>NULL</cfif>,
                <cfif isdefined('arguments.otv_oran') and len(arguments.otv_oran)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.otv_oran#"><cfelse>NULL</cfif>,
                <cfif isdefined('arguments.row_otvtotal') and len(arguments.row_otvtotal)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.row_otvtotal#"><cfelse>NULL</cfif>,
                <cfif isdefined('arguments.extra_cost') and len(arguments.extra_cost)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.extra_cost#"><cfelse>0</cfif>,
                <cfif isdefined('arguments.list_price') and len(arguments.list_price)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.list_price#"><cfelse>NULL</cfif>,
                <cfif isdefined('arguments.basket_employee_id') and len(arguments.basket_employee_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.basket_employee_id#"><cfelse>NULL</cfif>
                <cfif isdefined('arguments.row_bsmv_rate') and len(arguments.row_bsmv_rate)>,<cfqueryparam cfsqltype="cf_sql_float" value="#arguments.row_bsmv_rate#"></cfif>
                <cfif isdefined('arguments.row_bsmv_amount') and len(arguments.row_bsmv_amount)>,<cfqueryparam cfsqltype="cf_sql_float" value="#arguments.row_bsmv_amount#"></cfif>
                <cfif isdefined('arguments.row_bsmv_currency') and len(arguments.row_bsmv_currency)>,<cfqueryparam cfsqltype="cf_sql_float" value="#arguments.row_bsmv_currency#"></cfif>
                <cfif isdefined('arguments.row_oiv_rate') and len(arguments.row_oiv_rate)>,<cfqueryparam cfsqltype="cf_sql_float" value="#arguments.row_oiv_rate#"></cfif>
                <cfif isdefined('arguments.row_oiv_amount') and len(arguments.row_oiv_amount)>,<cfqueryparam cfsqltype="cf_sql_float" value="#arguments.row_oiv_amount#"></cfif>
                <cfif isdefined('arguments.row_tevkifat_rate') and len(arguments.row_tevkifat_rate)>,<cfqueryparam cfsqltype="cf_sql_float" value="#arguments.row_tevkifat_rate#"></cfif>
                <cfif isdefined('arguments.row_tevkifat_amount') and len(arguments.row_tevkifat_amount)>,<cfqueryparam cfsqltype="cf_sql_float" value="#arguments.row_tevkifat_amount#"></cfif>
            )
        </cfquery>
    </cffunction>
<!---  --->

<!--- Del Page --->
    <cffunction name="get_process" returntype="query">
        <cfargument name="dsn3" default="">
        <cfargument name="subscription_id" default="">
        <cfquery name="get_process" datasource="#arguments.dsn3#">
            SELECT SUBSCRIPTION_NO,SUBSCRIPTION_STAGE FROM SUBSCRIPTION_CONTRACT WHERE SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_id#">	
        </cfquery>
        <cfreturn get_process>
    </cffunction>

    <cffunction name="DEL_COUNTER" returntype="any">
        <cfargument name="dsn3" default="">
        <cfargument name="subscription_id" default="">
        <cfquery name="DEL_COUNTER" datasource="#arguments.DSN3#">
            DELETE FROM
                SUBSCRIPTION_PAYMENT_PLAN
            WHERE
                SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_id#">
          </cfquery>
    </cffunction>

    <cffunction name="DEL_COUNTER_SUBS" returntype="any">
        <cfargument name="dsn3" default="">
        <cfargument name="subscription_id" default="">
        <cfquery name="DEL_COUNTER" datasource="#arguments.DSN3#">
            DELETE FROM
                SUBSCRIPTION_COUNTER
            WHERE
                SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_id#">
          </cfquery>
    </cffunction>

    <cffunction name="DEL_CONTRACT_PARTITION" returntype="any">
        <cfargument name="dsn3" default="">
        <cfargument name="subscription_id" default="">
        <cfquery name="DEL_CONTRACT_PARTITION" datasource="#arguments.DSN3#">
            DELETE FROM
                SUBSCRIPTION_CONTRACT_PARTITION
            WHERE
                SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_id#">	
          </cfquery>
    </cffunction>

    <cffunction name="DEL_CONTRACT_MONEY" returntype="any">
        <cfargument name="dsn3" default="">
        <cfargument name="subscription_id" default="">
        <cfquery name="DEL_CONTRACT_MONEY" datasource="#arguments.DSN3#">
            DELETE FROM
                SUBSCRIPTION_CONTRACT_MONEY
            WHERE
                ACTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_id#">	
          </cfquery>
    </cffunction>

    <cffunction name="DEL_CONTRACT_ROW" returntype="any">
        <cfargument name="dsn3" default="">
        <cfargument name="subscription_id" default="">
        <cfquery name="DEL_CONTRACT_ROW" datasource="#arguments.DSN3#">
            DELETE FROM
                SUBSCRIPTION_CONTRACT_ROW
            WHERE
                SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_id#">	
          </cfquery>
    </cffunction>

    <cffunction name="DEL_CONTRACT_RELATIONS" returntype="any">
        <cfargument name="dsn3" default="">
        <cfargument name="subscription_id" default="">
        <cfquery name="DEL_CONTRACT_RELATIONS" datasource="#arguments.DSN3#">
            DELETE FROM
                SUBSCRIPTION_CONTRACT_RELATIONS
            WHERE
                SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_id#">	
          </cfquery>
    </cffunction>

    <cffunction name="DEL_CONTRACT_CAMPAIGN_RELATIONS" returntype="any">
        <cfargument name="dsn3" default="">
        <cfargument name="subscription_id" default="">
        <cfquery name="DEL_CONTRACT_RELATIONS" datasource="#arguments.DSN3#">
            DELETE FROM
                CAMPAIGN_RELATION
            WHERE
                SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_id#">	
          </cfquery>
    </cffunction>

    <cffunction name="DEL_SUBSCRIPTION_CONTRACT" returntype="any">
        <cfargument name="dsn3" default="">
        <cfargument name="subscription_id" default="">
        <cfquery name="DEL_SUBSCRIPTION_CONTRACT" datasource="#arguments.DSN3#">
			DELETE FROM 
				SUBSCRIPTION_CONTRACT
			WHERE		
				SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_id#">	
		</cfquery>
    </cffunction>
<!---  --->

<!--- Upd Page --->
    <cffunction name="CONTROL_PAYMENT_PLAN" returntype="query">
        <cfargument name="dsn3" default="">
        <cfargument name="subscription_id" default="">
        <cfquery name="CONTROL_PAYMENT_PLAN" datasource="#arguments.DSN3#">
            SELECT SUBSCRIPTION_ID,ISNULL(IS_COLLECTED_PROVISION,0) IS_COLLECTED_PROVISION,ISNULL(IS_PAID,0) IS_PAID FROM SUBSCRIPTION_PAYMENT_PLAN_ROW WHERE SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_id#">
        </cfquery>
        <cfreturn CONTROL_PAYMENT_PLAN>
    </cffunction>

    <cffunction name="CONTROL_SERVICE" returntype="query">
        <cfargument name="dsn3" default="">
        <cfargument name="subscription_id" default="">
        <cfquery name="CONTROL_SERVICE" datasource="#arguments.DSN3#">
            SELECT SUBSCRIPTION_ID FROM SERVICE WHERE SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_id#">
        </cfquery>
        <cfreturn CONTROL_SERVICE>
    </cffunction>

    <cffunction name="CONTROL_ORDER" returntype="query">
        <cfargument name="dsn3" default="">
        <cfargument name="subscription_id" default="">
        <cfquery name="CONTROL_ORDER" datasource="#arguments.DSN3#">
            SELECT SUBSCRIPTION_ID FROM SUBSCRIPTION_CONTRACT_ORDER WHERE SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_id#">
        </cfquery>
        <cfreturn CONTROL_ORDER>
    </cffunction>

    <cffunction name="CONTROL_COUNTER_RESULT" returntype="query">
        <cfargument name="dsn3" default="">
        <cfargument name="subscription_id" default="">
        <cfquery name="CONTROL_COUNTER_RESULT" datasource="#arguments.DSN3#">
            SELECT SUBSCRIPTION_ID FROM SUBSCRIPTION_COUNTER_RESULT WHERE SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_id#">
        </cfquery>
        <cfreturn CONTROL_COUNTER_RESULT>
    </cffunction>

    <cffunction name="GET_COUNTY" returntype="query">
        <cfargument name="county_list" default="">
        <cfquery name="GET_COUNTY" datasource="#DSN#">
            SELECT COUNTY_NAME,COUNTY_ID FROM SETUP_COUNTY WHERE COUNTY_ID IN (#arguments.county_list#) ORDER BY COUNTY_ID
        </cfquery>
        <cfreturn GET_COUNTY>
    </cffunction>

    <cffunction name="GET_CITY" returntype="query">
        <cfargument name="city_list" default="">
        <cfquery name="GET_CITY" datasource="#DSN#">
            SELECT CITY_NAME,CITY_ID FROM SETUP_CITY WHERE CITY_ID IN (#arguments.city_list#) ORDER BY CITY_ID
        </cfquery>
        <cfreturn GET_CITY>
    </cffunction>

    <cffunction name="GET_COUNTRY" returntype="query">
        <cfargument name="country_list" default="">
        <cfquery name="GET_COUNTRY" datasource="#DSN#">
            SELECT COUNTRY_NAME,COUNTRY_ID FROM SETUP_COUNTRY <cfif len(country_list)>WHERE COUNTRY_ID IN (#arguments.country_list#) ORDER BY COUNTRY_ID<cfelse>ORDER BY COUNTRY_NAME</cfif>
        </cfquery>
        <cfreturn GET_COUNTRY>
    </cffunction>

    <cffunction name="GET_SUBSCRIPTION_CANCEL_TYPE" returntype="query">
        <cfargument name="dsn3" default="">
        <cfargument name="CANCEL_TYPE_ID" default="">
        <cfquery name="GET_SUBSCRIPTION_CANCEL_TYPE" datasource="#arguments.DSN3#">
            SELECT SUBSCRIPTION_CANCEL_TYPE FROM SETUP_SUBSCRIPTION_CANCEL_TYPE WHERE SUBSCRIPTION_CANCEL_TYPE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.CANCEL_TYPE_ID#">
        </cfquery>
        <cfreturn GET_SUBSCRIPTION_CANCEL_TYPE>
    </cffunction>

    <cffunction name="get_camp_info" returntype="query">
        <cfargument name="dsn3" default="">
        <cfargument name="campaign_id" default="">
        <cfquery name="get_camp_info" datasource="#arguments.dsn3#">
            SELECT CAMP_ID,CAMP_HEAD FROM CAMPAIGNS WHERE CAMP_ID =<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.campaign_id#">
        </cfquery>
        <cfreturn get_camp_info>
    </cffunction>

    <cffunction name="CHECK_NO_UPD" returntype="query">
        <cfargument name="dsn3" default="">
        <cfargument name="subscription_id" default="">
        <cfargument name="subscription_no" default="">
        <cfquery name="CHECK_NO" datasource="#arguments.DSN3#">
            SELECT
                SUBSCRIPTION_ID
            FROM
                SUBSCRIPTION_CONTRACT
            WHERE
                SUBSCRIPTION_ID <> <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_id#"> AND
                SUBSCRIPTION_NO = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.subscription_no#">
        </cfquery>
        <cfreturn CHECK_NO>
    </cffunction>

    <cffunction name="DEL_SUBSCRIPTION_ROWS" returntype="any">
        <cfargument name="dsn3" default="">
        <cfargument name="subscription_id" default="">
        <cfquery name="DEL_SUBSCRIPTION_ROWS" datasource="#arguments.DSN3#">
			DELETE FROM SUBSCRIPTION_CONTRACT_ROW WHERE SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_id#">
		</cfquery>
    </cffunction>

    <cffunction name="UPD_SUBSCRIPTION_CONTRACT" returntype="any">
        <cfargument name="subscription_id" required="yes">
        <cfargument name="DSN" required="yes">
        <cfargument name="record_date" default="#now()#">
        <cfquery name="UPD_SUBSCRIPTION_CONTRACT" datasource="#arguments.DSN#">
			UPDATE
				SUBSCRIPTION_CONTRACT
			SET
                UPDATE_DATE = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.record_date#">
                <cfif isDefined("arguments.invoice_member_name") and len(arguments.invoice_member_name)>
                    <cfif isDefined("arguments.invoice_company_id") and len(arguments.invoice_company_id)>
                        ,INVOICE_COMPANY_ID = <cfif len(arguments.invoice_company_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.invoice_company_id#"><cfelse>NULL</cfif>
                        ,INVOICE_CONSUMER_ID = NULL
                        <cfif isDefined("arguments.invoice_partner_id")>
                            ,INVOICE_PARTNER_ID = <cfif len(arguments.invoice_partner_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.invoice_partner_id#"><cfelse>NULL</cfif>
                        </cfif>
                    <cfelseif isDefined("arguments.invoice_consumer_id")>
                        ,INVOICE_COMPANY_ID = NULL
                        ,INVOICE_CONSUMER_ID = <cfif len(arguments.invoice_consumer_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.invoice_consumer_id#"><cfelse>NULL</cfif>
                        ,INVOICE_PARTNER_ID = NULL
                    </cfif>
                <cfelseif isDefined("arguments.member_type") and len(arguments.member_type)>
                    <cfif arguments.member_type is 'partner'>
                        <cfif isDefined("arguments.company_id")>
                            ,INVOICE_COMPANY_ID = <cfif len(arguments.company_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.company_id#"><cfelse>NULL</cfif>
                        </cfif>
                        ,INVOICE_CONSUMER_ID = NULL
                        <cfif isDefined("arguments.partner_id")>
                            ,INVOICE_PARTNER_ID = <cfif len(arguments.partner_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.partner_id#"><cfelse>NULL</cfif>
                        </cfif>
                    <cfelseif arguments.member_type is 'consumer'>
                        ,INVOICE_COMPANY_ID = NULL
                        <cfif isDefined("arguments.consumer_id")>
                            ,INVOICE_CONSUMER_ID = <cfif len(arguments.consumer_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.consumer_id#"><cfelse>NULL</cfif>
                        </cfif>
                        ,INVOICE_PARTNER_ID = NULL
                    </cfif>
				</cfif>
				<cfif isDefined("arguments.subscription_no")>,SUBSCRIPTION_NO = <cfif len(arguments.subscription_no)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.subscription_no#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.is_active")>,IS_ACTIVE = <cfif len(arguments.is_active)>1<cfelse>0</cfif></cfif>
                <cfif isDefined("arguments.subscription_head")>,SUBSCRIPTION_HEAD = <cfif len(arguments.subscription_head)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.subscription_head#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.member_type") and len(arguments.member_type)>
                    <cfif arguments.member_type is 'partner'>
                        <cfif isDefined("arguments.partner_id")>,PARTNER_ID = <cfif len(arguments.partner_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.partner_id#"><cfelse>NULL</cfif></cfif>
                        <cfif isDefined("arguments.company_id")>,COMPANY_ID = <cfif len(arguments.company_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.company_id#"><cfelse>NULL</cfif></cfif>
                        ,CONSUMER_ID = NULL
                    <cfelseif arguments.member_type is 'consumer'>
                        ,PARTNER_ID = NULL
                        ,COMPANY_ID = NULL
                        <cfif isDefined("arguments.consumer_id")>,CONSUMER_ID = <cfif len(arguments.consumer_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.consumer_id#"><cfelse>NULL</cfif></cfif>
                    </cfif>
                <cfelseif isDefined("arguments.member_type") and not len(arguments.member_type)>
                    ,PARTNER_ID = NULL
                    ,COMPANY_ID = NULL
                    ,CONSUMER_ID = NULL
                </cfif>
                <cfif isdefined("arguments.subscription_type")>,SUBSCRIPTION_TYPE_ID = <cfif len(arguments.subscription_type)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_type#"><cfelse>NULL</cfif></cfif>
                <cfif isdefined("arguments.process_stage")>,SUBSCRIPTION_STAGE = <cfif len(arguments.process_stage)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.process_stage#"><cfelse>NULL</cfif></cfif>
                <cfif isdefined("arguments.sales_emp_id")>,SALES_EMP_ID = <cfif len(arguments.sales_emp_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.sales_emp_id#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.sales_member_type") and len(arguments.sales_member_type)>
                    <cfif arguments.sales_member_type is 'partner'>
                        ,SALES_CONSUMER_ID = NULL
                        <cfif isdefined("arguments.sales_member_id")>,SALES_PARTNER_ID = <cfif len(arguments.sales_member_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.sales_member_id#"><cfelse>NULL</cfif></cfif>
                        <cfif isdefined("arguments.sales_company_id")>,SALES_COMPANY_ID = <cfif len(arguments.sales_company_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.sales_company_id#"><cfelse>NULL</cfif></cfif>
                    <cfelseif arguments.sales_member_type is 'consumer'>
                        <cfif isdefined("arguments.sales_member_id")>,SALES_CONSUMER_ID = <cfif len(arguments.sales_member_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.sales_member_id#"><cfelse>NULL</cfif></cfif>
                        ,SALES_PARTNER_ID = NULL
                        ,SALES_COMPANY_ID = NULL
                    </cfif>
                <cfelseif isDefined("arguments.sales_member_type") and not len(arguments.sales_member_type)>
                    ,SALES_CONSUMER_ID = NULL
                    ,SALES_PARTNER_ID = NULL
                    ,SALES_COMPANY_ID = NULL
                </cfif>
				<cfif isdefined("arguments.sales_member_comm_value")>,SALES_MEMBER_COMM_VALUE = <cfif len(arguments.sales_member_comm_value)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.sales_member_comm_value#"><cfelse>NULL</cfif></cfif>
                <cfif isdefined("arguments.sales_member_comm_money")>,SALES_MEMBER_COMM_MONEY = <cfif len(arguments.sales_member_comm_money)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.sales_member_comm_money#"><cfelse>NULL</cfif></cfif>
                <cfif isdefined("arguments.ref_member_type") and len(arguments.ref_member_type)>
                    <cfif arguments.ref_member_type is 'partner'>
                        ,REF_CONSUMER_ID = NULL
                        ,REF_EMPLOYEE_ID = NULL
                        <cfif isDefined("arguments.ref_member_id")>,REF_PARTNER_ID = <cfif len(arguments.ref_member_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ref_member_id#"><cfelse>NULL</cfif></cfif>
                        <cfif isDefined("arguments.ref_company_id")>,REF_COMPANY_ID = <cfif len(arguments.ref_company_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ref_company_id#"><cfelse>NULL</cfif></cfif>
                    <cfelseif arguments.ref_member_type is 'consumer'>
                        <cfif isDefined("arguments.ref_member_id")>,REF_CONSUMER_ID = <cfif len(arguments.ref_member_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ref_member_id#"><cfelse>NULL</cfif></cfif>
                        ,REF_EMPLOYEE_ID = NULL			
                        ,REF_PARTNER_ID = NULL
                        ,REF_COMPANY_ID = NULL
                    <cfelseif arguments.ref_member_type is 'employee'>
                        ,REF_CONSUMER_ID = NULL
                        <cfif isDefined("arguments.ref_member_id")>,REF_EMPLOYEE_ID = <cfif len(arguments.ref_member_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ref_member_id#"><cfelse>NULL</cfif></cfif>
                        ,REF_PARTNER_ID = NULL
                        ,REF_COMPANY_ID = NULL
                    </cfif>
				<cfelseif isdefined("arguments.ref_member_type") and not len(arguments.ref_member_type)>
					,REF_CONSUMER_ID = NULL
					,REF_EMPLOYEE_ID = NULL
					,REF_PARTNER_ID = NULL
					,REF_COMPANY_ID = NULL
				</cfif>
				<cfif isDefined("arguments.subscription_product_id")>,PRODUCT_ID = <cfif len(arguments.subscription_product_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_product_id#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.subscription_stock_id")>,STOCK_ID = <cfif len(arguments.subscription_stock_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_stock_id#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.contract_no")>,CONTRACT_NO = <cfif len(arguments.contract_no)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.contract_no#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.montage_emp_id")>,MONTAGE_EMP_ID = <cfif len(arguments.montage_emp_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.montage_emp_id#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.payment_type_id")>,PAYMENT_TYPE_ID = <cfif len(arguments.payment_type_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.payment_type_id#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.payment_type_creditcard_id")>,PAYMENT_TYPE_CREDITCARD_ID = <cfif len(arguments.payment_type_creditcard_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.payment_type_creditcard_id#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.montage_date")>,MONTAGE_DATE = <cfif len(arguments.montage_date)><cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.montage_date#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.start_date")>,START_DATE = <cfif len(arguments.start_date)><cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.start_date#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.finish_date")>,FINISH_DATE = <cfif len(arguments.finish_date)><cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.finish_date#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.detail")>,SUBSCRIPTION_DETAIL = <cfif len(arguments.detail)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.detail#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.detail_2")>,SUBSCRIPTION_DETAIL_2 = <cfif len(arguments.detail_2)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.detail_2#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.inv_detail")>,SUBSCRIPTION_INVOICE_DETAIL = <cfif len(arguments.inv_detail)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.inv_detail#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.credit_card_id")>,MEMBER_CC_ID = <cfif len(arguments.credit_card_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.credit_card_id#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.main_special_code")>,SPECIAL_CODE = <cfif len(arguments.main_special_code)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.main_special_code#"><cfelse>NULL</cfif></cfif>
				<cfif isDefined("arguments.ship_address")>,SHIP_ADDRESS = <cfif Len(arguments.ship_address)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.ship_address#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.ship_postcode")>,SHIP_POSTCODE = <cfif Len(arguments.ship_postcode)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.ship_postcode#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.ship_semt")>,SHIP_SEMT =<cfif Len(arguments.ship_semt)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.ship_semt#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.ship_county_id")>,SHIP_COUNTY_ID = <cfif len(arguments.ship_county_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ship_county_id#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.ship_city_id")>,SHIP_CITY_ID = <cfif len(arguments.ship_city_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ship_city_id#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.ship_country_id")>,SHIP_COUNTRY_ID = <cfif len(arguments.ship_country_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ship_country_id#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.ship_coordinate_1")>,SHIP_COORDINATE_1 = <cfif len(arguments.ship_coordinate_1)><cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.ship_coordinate_1#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.ship_coordinate_2")>,SHIP_COORDINATE_2 = <cfif len(arguments.ship_coordinate_2)><cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.ship_coordinate_2#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.ship_sales_zone_id")>,SHIP_SZ_ID =<cfif len(arguments.ship_sales_zone_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ship_sales_zone_id#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.invoice_address")>,INVOICE_ADDRESS = <cfif len(arguments.invoice_address)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.invoice_address#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.invoice_postcode")>,INVOICE_POSTCODE = <cfif len(arguments.invoice_postcode)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.invoice_postcode#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.invoice_semt")>,INVOICE_SEMT = <cfif len(arguments.invoice_semt)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.invoice_semt#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.invoice_county_id")>,INVOICE_COUNTY_ID = <cfif len(arguments.invoice_county_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.invoice_county_id#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.invoice_city_id")>,INVOICE_CITY_ID = <cfif len(arguments.invoice_city_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.invoice_city_id#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.invoice_country_id")>,INVOICE_COUNTRY_ID = <cfif len(arguments.invoice_country_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.invoice_country_id#"><cfelse>NULL</cfif></cfif>	
                <cfif isDefined("arguments.invoice_coordinate_1")>,INVOICE_COORDINATE_1 = <cfif len(arguments.invoice_coordinate_1)><cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.invoice_coordinate_1#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.invoice_coordinate_2")>,INVOICE_COORDINATE_2 = <cfif len(arguments.invoice_coordinate_2)><cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.invoice_coordinate_2#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.invoice_sales_zone_id")>,INVOICE_SZ_ID = <cfif len(arguments.invoice_sales_zone_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.invoice_sales_zone_id#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.ship_id")>,INVOICE_ADDRESS_ID = <cfif len(arguments.ship_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ship_id#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.contact_address")>,CONTACT_ADDRESS = <cfif len(arguments.contact_address)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.contact_address#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.contact_postcode")>,CONTACT_POSTCODE = <cfif len(arguments.contact_postcode)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.contact_postcode#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.contact_semt")>,CONTACT_SEMT = <cfif len(arguments.contact_semt)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.contact_semt#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.contact_county_id")>,CONTACT_COUNTY_ID = <cfif len(arguments.contact_county_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.contact_county_id#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.contact_city_id")>,CONTACT_CITY_ID = <cfif len(arguments.contact_city_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.contact_city_id#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.contact_country_id")>,CONTACT_COUNTRY_ID = <cfif len(arguments.contact_country_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.contact_country_id#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.contact_coordinate_1")>,CONTACT_COORDINATE_1 = <cfif len(arguments.contact_coordinate_1)><cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.contact_coordinate_1#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.contact_coordinate_2")>,CONTACT_COORDINATE_2 = <cfif len(arguments.contact_coordinate_2)><cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.contact_coordinate_2#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.contact_sales_zone_id")>,CONTACT_SZ_ID = <cfif len(arguments.contact_sales_zone_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.contact_sales_zone_id#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.BASKET_DISCOUNT_TOTAL")>,DISCOUNTTOTAL = <cfif len(arguments.BASKET_DISCOUNT_TOTAL)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.BASKET_DISCOUNT_TOTAL#"><cfelse>0</cfif></cfif>
                <cfif isDefined("arguments.basket_net_total")>,NETTOTAL = <cfif len(arguments.basket_net_total)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.basket_net_total#"><cfelse>0</cfif></cfif>
                <cfif isDefined("arguments.basket_gross_total")>,GROSSTOTAL = <cfif len(arguments.basket_gross_total)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.basket_gross_total#"><cfelse>0</cfif></cfif>
                <cfif isDefined("arguments.basket_tax_total")>,TAXTOTAL = <cfif len(arguments.basket_tax_total)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.basket_tax_total#"><cfelse>0</cfif></cfif>
                <cfif isDefined("arguments.basket_otv_total")>,OTV_TOTAL =  <cfif len(arguments.basket_otv_total)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.basket_otv_total#"><cfelse>0</cfif></cfif>
                <cfif isDefined("arguments.BASKET_MONEY")>,OTHER_MONEY = <cfif len(arguments.BASKET_MONEY)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.BASKET_MONEY#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.BASKET_NET_TOTAL") and isDefined("arguments.BASKET_RATE1") and isDefined("arguments.BASKET_RATE2")>,OTHER_MONEY_VALUE = <cfif len(arguments.BASKET_NET_TOTAL) and len(arguments.BASKET_RATE1) and len(arguments.BASKET_RATE2)><cfqueryparam cfsqltype="cf_sql_float" value="#((arguments.BASKET_NET_TOTAL*arguments.BASKET_RATE1)/arguments.BASKET_RATE2)#"><cfelse>0</cfif></cfif>
                <cfif isDefined("arguments.subs_add_option")>,SUBSCRIPTION_ADD_OPTION_ID =<cfif len(arguments.subs_add_option)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subs_add_option#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.sales_add_option")>,SALES_ADD_OPTION_ID = <cfif len(arguments.sales_add_option)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.sales_add_option#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.project_id")>,PROJECT_ID =  <cfif len(arguments.project_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.project_id#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.genel_indirim")>,SA_DISCOUNT = <cfif len(arguments.genel_indirim)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.genel_indirim#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.asset_id")>,ASSETP_ID = <cfif len(arguments.asset_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.asset_id#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.valid_days")>,VALID_DAYS = <cfif len(arguments.valid_days)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.valid_days#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.start_clock_1")>,START_CLOCK_1 = <cfif len(arguments.start_clock_1)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.start_clock_1#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.start_minute_1")>,START_MINUTE_1 = <cfif len(arguments.start_minute_1)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.start_minute_1#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.finish_clock_1")>,FINISH_CLOCK_1 = <cfif len(arguments.finish_clock_1)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.finish_clock_1#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.finish_minute_1")>,FINISH_MINUTE_1 = <cfif len(arguments.finish_minute_1)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.finish_minute_1#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.start_clock_2")>,START_CLOCK_2 = <cfif len(arguments.start_clock_2)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.start_clock_2#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.start_minute_2")>,START_MINUTE_2 = <cfif len(arguments.start_minute_2)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.start_minute_2#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.finish_clock_2")>,FINISH_CLOCK_2 = <cfif len(arguments.finish_clock_2)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.finish_clock_2#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.finish_minute_2")>,FINISH_MINUTE_2 = <cfif len(arguments.finish_minute_2)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.finish_minute_2#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.start_clock_3")>,START_CLOCK_3 = <cfif len(arguments.start_clock_3)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.start_clock_3#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.start_minute_3")>,START_MINUTE_3 = <cfif len(arguments.start_minute_3)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.start_minute_3#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.finish_clock_3")>,FINISH_CLOCK_3 = <cfif len(arguments.finish_clock_3)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.finish_clock_3#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.finish_minute_3")>,FINISH_MINUTE_3 = <cfif len(arguments.finish_minute_3)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.finish_minute_3#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.general_date")>,IS_GENERAL_DATE = <cfif len(arguments.general_date)>1<cfelse>0</cfif></cfif>
                <cfif isDefined("arguments.hour1")>,HOUR1 = <cfif len(arguments.hour1)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.hour1#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.minute1")>,MINUTE1 = <cfif len(arguments.minute1)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.minute1#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.response_hour1")>,RESPONSE_HOUR1 = <cfif len(arguments.response_hour1)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.response_hour1#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.response_minute1")>,RESPONSE_MINUTE1 = <cfif len(arguments.response_minute1)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.response_minute1#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.camp_id")>,CAMPAIGN_ID = <cfif Len(arguments.camp_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.camp_id#"><cfelse>NULL</cfif></cfif>
                <cfif isdefined('arguments.opp_id')>,OPP_ID = <cfif len(arguments.opp_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.opp_id#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.ref_state")>,REFERANCE_STATUS_ID = <cfif len(arguments.ref_state)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ref_state#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.userid")>,UPDATE_EMP = <cfif len(arguments.userid)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.remote_addr")>,UPDATE_IP = <cfif len(arguments.remote_addr)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.remote_addr#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.comp_branch")>,BRANCH_ID = <cfif len(arguments.comp_branch)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.comp_branch#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.product_key")>,PRODUCT_KEY = <cfif len(arguments.product_key)><cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.product_key#"><cfelse>NULL</cfif></cfif>
                <cfif isDefined("arguments.our_company_id")>,OUR_COMPANY_ID = <cfif len(arguments.our_company_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.our_company_id#"><cfelse>NULL</cfif></cfif>
			WHERE	
				SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_id#">
		</cfquery>
    </cffunction>

    <cffunction name="UPD_SUBSCRIPTION_CONTRACT_ROW" returntype="any">
        <cfargument name="subscription_id" required="yes">
        <cfargument name="stock_id" required="yes">
        <cfargument name="amount" required="yes">
        <cfquery name="UPD_SUBSCRIPTION_CONTRACT" datasource="#dsn3_alias#">
			UPDATE
				SUBSCRIPTION_CONTRACT_ROW
			SET
                AMOUNT = <cfqueryparam cfsqltype="cf_sql_integer" value = "#arguments.amount#">
            WHERE 
                SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value = "#arguments.subscription_id#">
                AND STOCK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value = "#arguments.stock_id#">
        </cfquery>
    </cffunction>
<!--- --->
<!---subscription payment plan add page--->
    <cffunction name="GET_SUBSCRIPTION" returntype="query">
        <cfargument name="subscription_id" default="">
        <cfquery name="GET_SUBSCRIPTION" datasource="#DSN3#">
            SELECT 
                SC.*,
                SST.*,
                #dsn#.Get_Dynamic_Language(SST.SUBSCRIPTION_TYPE_ID,'<cfif isDefined('session.ep.userid')>#session.ep.language#<cfelseif isDefined('session.pp.userid')>#session.pp.language# <cfelseif isDefined('session.pda.userid')>#session.pda.language#</cfif>','SETUP_SUBSCRIPTION_TYPE','SUBSCRIPTION_TYPE',NULL,NULL,SST.SUBSCRIPTION_TYPE) AS SUBSCRIPTION_TYPE_,
                #dsn#.Get_Dynamic_Language(PTR.PROCESS_ROW_ID,'<cfif isDefined('session.ep.userid')>#session.ep.language#<cfelseif isDefined('session.pp.userid')>#session.pp.language# <cfelseif isDefined('session.pda.userid')>#session.pda.language#</cfif>','PROCESS_TYPE_ROWS','STAGE',NULL,NULL,PTR.STAGE) AS STAGE,
                SIP.PROPERTY16
            FROM SUBSCRIPTION_CONTRACT SC 
            LEFT JOIN SETUP_SUBSCRIPTION_TYPE SST ON SST.SUBSCRIPTION_TYPE_ID = SC.SUBSCRIPTION_TYPE_ID 
            LEFT JOIN #dsn#.PROCESS_TYPE_ROWS PTR ON SC.SUBSCRIPTION_STAGE = PTR.PROCESS_ROW_ID
            LEFT JOIN SUBSCRIPTION_INFO_PLUS AS SIP ON SC.SUBSCRIPTION_ID = SIP.SUBSCRIPTION_ID
            WHERE SC.SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_id#">
        </cfquery>
        <cfreturn GET_SUBSCRIPTION>
    </cffunction>

    <cffunction name="GET_MONEY" returntype="query">
        <cfargument name="xml_use_money" default="">
        <cfargument name="money" default="#money_#">
        <cfquery name="GET_MONEY" datasource="#DSN2#">
            SELECT MONEY, RATE1,RATE2 FROM SETUP_MONEY WHERE MONEY_STATUS = 1 
            <cfif ListLen(xml_use_money)>AND MONEY IN (#ListQualify(xml_use_money,"'",",")#) </cfif> 
            ORDER BY CASE WHEN 
            <cfif isDefined('session.pp.money')>
                MONEY = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.pp.money#">   
            <cfelseif isDefined('session.ep.money')> 
                MONEY = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.ep.money#">  
            <cfelseif isDefined('session.ww.money')> 
                MONEY  = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.ww.money#">   
            </cfif>  THEN '0' ELSE MONEY_ID END
        </cfquery>
        <cfreturn GET_MONEY>
    </cffunction>

    <cffunction name="GET_BASKET_AMOUNT" returntype="query">
        <cfquery name="GET_BASKET_AMOUNT" datasource="#DSN3#">
            SELECT AMOUNT_ROUND,PRICE_ROUND_NUMBER FROM SETUP_BASKET WHERE BASKET_ID = 46
        </cfquery>
        <cfreturn GET_BASKET_AMOUNT>
    </cffunction>

    <cffunction name="GET_MONEY_MAIN" returntype="query">
        <cfargument name="xml_use_money" default="">
        <cfargument name="money" default="#money_#">
        <cfquery name="GET_MONEY_MAIN" datasource="#DSN2#"><!--- para geçişlerinden sonra money queryleri ayrıldı --->
            SELECT MONEY, RATE1,RATE2 FROM SETUP_MONEY WHERE MONEY_STATUS = 1 
            <cfif ListLen(xml_use_money)>AND MONEY IN (#ListQualify(xml_use_money,"'",",")#) </cfif> 
            ORDER BY CASE WHEN  
            <cfif isDefined('session.pp.money')>
                MONEY = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.pp.money#">   
            <cfelseif isDefined('session.ep.money')> 
                MONEY = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.ep.money#">  
            <cfelseif isDefined('session.ww.money')> 
                MONEY  = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.ww.money#">   
            </cfif> THEN '0' ELSE MONEY_ID END
        </cfquery>
        <cfreturn GET_MONEY_MAIN>
    </cffunction>


    <cffunction name="GET_PAYMENT_ROWS" returntype="query">
        <cfargument name="subscription_id" displayname="" default="">
        <cfargument name="row_status" default="">
        <cfargument name="xml_filter_row" default="">
        <cfargument name="row_start_date" default="">
        <cfargument name="row_finish_date" default="">
        <cfargument name="row_product_name" default="">
        <cfargument name="row_product_id" default="">
        <cfargument name="row_paymethod" default="">
        <cfargument name="row_card_paymethod_id" default="">
        <cfargument name="row_paymethod_id" default="">
        <cfargument name="row_invoice_type" default="">
        <cfargument name="row_bill_type" default="">
        <cfargument name="row_prov_type" default="">
        <cfargument name="row_pay_type" default="">
        <cfargument name="row_camp_id" default="">
        <cfargument name="row_subs_ref_id" default="">
        <cfargument name="row_service_id" default="">
        <cfargument name="row_service_no" default="">
        <cfargument name="row_call_id" default="">
        <cfargument name="row_call_no" default="">
        <cfargument name="row_money_type" default="">
        <cfargument name="row_amount" default="">   
        <cfargument name="x_payment_plan_record_info" default="">
        <cfargument name="x_payment_plan_reference" default="">
        <cfargument name="x_payment_plan_service" default="">
        <cfargument name="x_payment_plan_call" default="">
        <cfargument name="x_payment_plan_campaign" default="">
        <cfargument name="x_payment_plan_import_id" default="">
        <cfquery name="GET_PAYMENT_ROWS" datasource="#DSN3#">
            SELECT 
                SUBSCRIPTION_PAYMENT_ROW_ID,
                SUBSCRIPTION_ID,
                STOCK_ID,
                PRODUCT_ID,
                (SELECT ISNULL(TAX,0) FROM PRODUCT WHERE PRODUCT_ID = SUBSCRIPTION_PAYMENT_PLAN_ROW.PRODUCT_ID) TAX,
                (SELECT ISNULL(OTV,0) FROM PRODUCT WHERE PRODUCT_ID = SUBSCRIPTION_PAYMENT_PLAN_ROW.PRODUCT_ID) OTV,
                PAYMENT_DATE,
                DETAIL,
                UNIT,
                QUANTITY,
                AMOUNT,
                MONEY_TYPE,
                ROW_TOTAL,
                DISCOUNT,
                ROW_NET_TOTAL,
                IS_COLLECTED_INVOICE,
                IS_BILLED,
                IS_PAID,
                IS_COLLECTED_PROVISION,
                INVOICE_ID,
                PERIOD_ID,
                (SELECT PERIOD_YEAR FROM #dsn_alias#.SETUP_PERIOD WHERE PERIOD_ID = SUBSCRIPTION_PAYMENT_PLAN_ROW.PERIOD_ID) AS PERIOD_YEAR,
                <cfif arguments.x_payment_plan_record_info>
                    (SELECT EMPLOYEES.EMPLOYEE_NAME + ' ' + EMPLOYEES.EMPLOYEE_SURNAME FROM #dsn_alias#.EMPLOYEES WHERE EMPLOYEES.EMPLOYEE_ID = SUBSCRIPTION_PAYMENT_PLAN_ROW.RECORD_EMP) RECORD_EMP_NAME,
                    (SELECT EMPLOYEES.EMPLOYEE_NAME + ' ' + EMPLOYEES.EMPLOYEE_SURNAME FROM #dsn_alias#.EMPLOYEES WHERE EMPLOYEES.EMPLOYEE_ID = SUBSCRIPTION_PAYMENT_PLAN_ROW.UPDATE_EMP) UPDATE_EMP_NAME,
                </cfif>
                RECORD_IP,
                RECORD_DATE,
                UPDATE_IP,
                UPDATE_DATE,
                UNIT_ID,
                PAYMETHOD_ID,
                (SELECT SETUP_PAYMETHOD.PAYMETHOD FROM #dsn_alias#.SETUP_PAYMETHOD WHERE SETUP_PAYMETHOD.PAYMETHOD_ID = SUBSCRIPTION_PAYMENT_PLAN_ROW.PAYMETHOD_ID) PAYMETHOD,
                CARD_PAYMETHOD_ID,
                (SELECT CREDITCARD_PAYMENT_TYPE.CARD_NO FROM CREDITCARD_PAYMENT_TYPE WHERE CREDITCARD_PAYMENT_TYPE.PAYMENT_TYPE_ID = SUBSCRIPTION_PAYMENT_PLAN_ROW.CARD_PAYMETHOD_ID) CARD_NO,
                <cfif x_payment_plan_reference>
                    SUBS_REFERENCE_ID,
                    (SELECT SUBSCRIPTION_CONTRACT.SUBSCRIPTION_NO FROM SUBSCRIPTION_CONTRACT WHERE SUBSCRIPTION_CONTRACT.SUBSCRIPTION_ID = SUBSCRIPTION_PAYMENT_PLAN_ROW.SUBS_REFERENCE_ID) SUBSCRIPTION_NO,
                </cfif>
                IS_GROUP_INVOICE,
                IS_INVOICE_IPTAL,
                DUE_DIFF_ID,
                <cfif x_payment_plan_service>
                    SERVICE_ID,
                    (SELECT SERVICE.SERVICE_NO FROM SERVICE WHERE SERVICE.SERVICE_ID = SUBSCRIPTION_PAYMENT_PLAN_ROW.SERVICE_ID) SERVICE_NO,
                </cfif>
                <cfif x_payment_plan_call>
                    CALL_ID,
                    (SELECT G_SERVICE.SERVICE_NO FROM #dsn_alias#.G_SERVICE WHERE G_SERVICE.SERVICE_ID = SUBSCRIPTION_PAYMENT_PLAN_ROW.CALL_ID) G_SERVICE_NO,
                </cfif>
                IS_ACTIVE,
                <cfif x_payment_plan_campaign>
                    CAMPAIGN_ID,
                    (SELECT CAMPAIGNS.CAMP_HEAD FROM CAMPAIGNS WHERE CAMPAIGNS.CAMP_ID = SUBSCRIPTION_PAYMENT_PLAN_ROW.CAMPAIGN_ID) CAMP_HEAD,
                </cfif>
                CARI_ACTION_ID,
                CARI_PERIOD_ID,
                CAMP_ID,
                CARI_ACT_TYPE,
                CARI_ACT_TABLE,
                CARI_ACT_ID,
                DISCOUNT_AMOUNT,
                PAYMENT_FINISH_DATE,
                RATE,
                ISNULL(BSMV_RATE,0) AS BSMV_RATE,
                ISNULL(BSMV_AMOUNT,0) AS BSMV_AMOUNT,
                ISNULL(OIV_RATE,0) AS OIV_RATE,
                ISNULL(OIV_AMOUNT,0) AS OIV_AMOUNT,
                ISNULL(TEVKIFAT_RATE,0) AS TEVKIFAT_RATE,
                ISNULL(TEVKIFAT_AMOUNT,0) AS TEVKIFAT_AMOUNT,
                REASON_CODE,
                IS_COUNTER,
                OUR_COMPANY_ID,
                CM_ID
                <cfif xml_payment_plan_import_id>
                ,(SELECT SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID FROM SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ROW WHERE SUBSCRIPTION_PAYMENT_PLAN_ROW.SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ROW_ID = SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ROW.SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ROW_ID) AS SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID
                </cfif>
            FROM 
                SUBSCRIPTION_PAYMENT_PLAN_ROW                 
            WHERE 
                SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_id#">
                <cfif isdefined("arguments.row_status") and len(arguments.row_status)>
                    AND IS_ACTIVE = <cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.row_status#">
                </cfif>
                <cfif arguments.xml_filter_row eq 1 and isdefined('arguments.row_start_date') and len(arguments.row_start_date)>
                    AND PAYMENT_DATE >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.row_start_date#">
                </cfif>
                <cfif arguments.xml_filter_row eq 1 and isdefined('arguments.row_finish_date') and len(arguments.row_finish_date)>
                    AND PAYMENT_DATE <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.row_finish_date#">
                </cfif>
                <cfif isdefined('arguments.row_product_id') and len(arguments.row_product_id) and len(arguments.row_product_name)>
                    AND PRODUCT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.row_product_id#">
                </cfif>
                <cfif isdefined("arguments.row_card_paymethod_id") and len(arguments.row_card_paymethod_id) and len(arguments.row_paymethod)>
                    AND CARD_PAYMETHOD_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.row_card_paymethod_id#">
                </cfif>
                <cfif isdefined("arguments.row_paymethod_id") and len(arguments.row_paymethod_id) and len(arguments.row_paymethod)>
                    AND PAYMETHOD_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.row_paymethod_id#">
                </cfif>
                <cfif isdefined("arguments.row_invoice_type") and len(arguments.row_invoice_type) and arguments.row_invoice_type eq 1>
                    AND IS_COLLECTED_INVOICE = 1
                <cfelseif isdefined("arguments.row_invoice_type") and len(arguments.row_invoice_type) and arguments.row_invoice_type eq 2>
                    AND IS_GROUP_INVOICE = 1
                </cfif>
                <cfif isdefined("arguments.row_bill_type") and len(arguments.row_bill_type) and arguments.row_bill_type eq 1>
                    AND IS_BILLED = 1
                <cfelseif isdefined("arguments.row_bill_type") and len(arguments.row_bill_type) and arguments.row_bill_type eq 2>
                    AND IS_BILLED = 0
                </cfif>
                <cfif isdefined("arguments.row_prov_type") and len(arguments.row_prov_type) and arguments.row_prov_type eq 1>
                    AND IS_COLLECTED_PROVISION = 1
                <cfelseif isdefined("arguments.row_prov_type") and len(arguments.row_prov_type) and arguments.row_prov_type eq 2>
                    AND IS_COLLECTED_PROVISION = 0
                </cfif>
                <cfif isdefined("arguments.row_pay_type") and len(arguments.row_pay_type) and arguments.row_pay_type eq 1>
                    AND IS_PAID = 1
                <cfelseif isdefined("arguments.row_pay_type") and len(arguments.row_pay_type) and arguments.row_pay_type eq 2>
                    AND IS_PAID = 0
                </cfif>
                <cfif isdefined("arguments.row_camp_id") and len(arguments.row_camp_id) and len(arguments.row_camp_name)>
                    AND CAMPAIGN_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.row_camp_id#">
                </cfif>
                <cfif isdefined("arguments.row_subs_ref_id") and len(arguments.row_subs_ref_id) and len(arguments.row_subs_ref_name)>
                    AND SUBS_REFERENCE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.row_subs_ref_id#">
                </cfif>
                <cfif isdefined("arguments.row_service_id") and len(arguments.row_service_id) and len(arguments.row_service_no)>
                    AND SERVICE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.row_service_id#">
                </cfif>
                <cfif isdefined("arguments.row_call_id") and len(arguments.row_call_id) and len(arguments.row_call_no)>
                    AND CALL_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.row_call_id#">
                </cfif>
                <cfif isdefined("arguments.row_money_type") and len(arguments.row_money_type)>
                    AND MONEY_TYPE = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.row_money_type#">
                </cfif>
                <cfif isdefined("arguments.row_amount") and len(arguments.row_amount)>
                    AND AMOUNT = <cfqueryparam cfsqltype="cf_sql_float" value="#arguments.row_amount#">
                </cfif>
            ORDER BY 
                PAYMENT_DATE
        </cfquery>
        <cfreturn GET_PAYMENT_ROWS>
    </cffunction>

    <cffunction name="GET_PAYMENT" returntype="query">
        <cfargument name="subscription_id" default="">
        <cfquery name="GET_PAYMENT" datasource="#dsn3#">
            SELECT 
                SUBSCRIPTION_PAYMENT_PLAN_ID, 
                SUBSCRIPTION_ID, 
                PRODUCT_ID, 
                STOCK_ID, 
                UNIT, 
                QUANTITY, 
                AMOUNT, 
                MONEY_TYPE, 
                PERIOT, 
                START_DATE, 
                UNIT_ID, 
                PAYMETHOD_ID, 
                CARD_PAYMETHOD_ID, 
                PROCESS_STAGE, 
                RECORD_EMP, 
                RECORD_IP, 
                RECORD_DATE, 
                UPDATE_EMP, 
                UPDATE_IP, 
                UPDATE_DATE 
            FROM 
                SUBSCRIPTION_PAYMENT_PLAN 
            WHERE 
                SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_id#">
        </cfquery>
        <cfreturn GET_PAYMENT>
    </cffunction>

    <cffunction name="GET_POWER_USER_INFO" returntype="query">
        <cfargument name="EMPLOYEE_ID" default="#userid_#">
        <cfquery name="GET_POWER_USER_INFO" datasource="#DSN#"><!--- burdaki admine bağlı yetkiler(ödendi checkboxlarnın falan disable olması) poweruser a çevrildi --->
            SELECT POWER_USER_LEVEL_ID FROM EMPLOYEE_POSITIONS 
            WHERE
            <cfif isDefined('session.pp.userid')>
                EMPLOYEE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.pp.userid#">   
            <cfelseif isDefined('session.ep.userid')> 
                EMPLOYEE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#">  
            <cfelseif isDefined('session.ww.userid')> 
                EMPLOYEE_ID  = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ww.userid#">   
            </cfif> 
        </cfquery>
        <cfreturn GET_POWER_USER_INFO>
    </cffunction>

    <cffunction name="GET_CAMPAIGN" returntype="query">
        <cfargument name="subscription_id" default="">
        <cfquery name="GET_CAMPAIGN" datasource="#DSN3#">
            SELECT C.CAMP_ID,C.CAMP_HEAD FROM CAMPAIGN_RELATION CR,CAMPAIGNS C WHERE C.CAMP_ID = CR.CAMP_ID AND CR.SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_id#">
        </cfquery>
        <cfreturn GET_CAMPAIGN>
    </cffunction>

    <cffunction name="GET_PAYM_PLAN" returntype="query">
        <cfargument name="subscription_id" default="">
        <cfquery name="GET_PAYM_PLAN" datasource="#dsn3#">
            SELECT
                SUM(ROW_NET_TOTAL) FIRST_TOTAL,
                SUBSCRIPTION_ID,
                YEAR(PAYMENT_DATE) PAY_YEAR,
                MONEY_TYPE,
                CM_ID
            FROM
                SUBSCRIPTION_PAYMENT_PLAN_ROW
            WHERE
                SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_id#">
            GROUP BY
                SUBSCRIPTION_ID,
                YEAR(PAYMENT_DATE),
                MONEY_TYPE,
                CM_ID
            ORDER BY
                YEAR(PAYMENT_DATE)
        </cfquery>
        <cfreturn GET_PAYM_PLAN>
    </cffunction>

    <cffunction name="INSERT_PAYM_PLAN_HISTORY" returntype="any">
        <cfargument name="subscription_id" default="">
        <cfargument name="RECORD_EMP" default="#userid_#">
        <cfargument name="RECORD_IP" default="#cgi.remote_addr#">
        <cfargument name="UPDATE_DATE" default="#now()#">
        <cfquery name="INSERT_PAYM_PLAN_HISTORY" datasource="#dsn3#">
            INSERT INTO
                SUBSCRIPTION_PAYMENT_PLAN_ROW_HISTORY
            (
                SUBSCRIPTION_ID,
                PAYM_PLAN_YEAR,
                PAYM_PLAN_TOTAL_OLD,
                PAYM_PLAN_MONEY_TYPE,
                CAMPAIGN_ID,
                RECORD_EMP,
                RECORD_IP,
                RECORD_DATE
            )
                SELECT
                    SUBSCRIPTION_ID,
                    YEAR(PAYMENT_DATE),
                    SUM(ROW_NET_TOTAL),
                    MONEY_TYPE,
                    CAMPAIGN_ID,
                    <cfif isDefined('session.pp.userid')>
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#session.pp.userid#">   
                    <cfelseif isDefined('session.ep.userid')> 
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#">  
                    <cfelseif isDefined('session.ww.userid')> 
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ww.userid#">   
                    </cfif> ,
                    <cfqueryparam cfsqltype="cf_sql_nvarchar" value="#cgi.remote_addr#">,
                    <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
                FROM
                    SUBSCRIPTION_PAYMENT_PLAN_ROW
                WHERE
                    SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_id#">
                GROUP BY
                    SUBSCRIPTION_ID,
                    YEAR(PAYMENT_DATE),
                    MONEY_TYPE,
                    CAMPAIGN_ID
                ORDER BY
                    YEAR(PAYMENT_DATE)
        </cfquery>
    </cffunction>

    <cffunction name="UPD_PAYMENT_PLAN" returntype="any">  
        <cfargument name="SUBSCRIPTION_ID" required="yes" default="">
        <cfargument name="UPDATE_DATE" default="#now()#">
        <cfquery name="UPD_PAYMENT_PLAN" datasource="#dsn3#">
            UPDATE 
                SUBSCRIPTION_PAYMENT_PLAN 
            SET
                UPDATE_DATE = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
            <cfif isDefined("arguments.product_id")>
                ,PRODUCT_ID = <cfif isDefined("arguments.product_id") and len(arguments.product_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.product_id#"><cfelse>NULL</cfif>
            </cfif>
            <cfif isDefined("arguments.stock_id")>
                ,STOCK_ID = <cfif isDefined("arguments.stock_id") and len(arguments.stock_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.stock_id#"><cfelse>NULL</cfif>
            </cfif>    
            <cfif isDefined("arguments.unit")>
                ,UNIT = <cfif isDefined("arguments.unit") and len(arguments.unit)><cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.unit#"><cfelse>NULL</cfif>
            </cfif>  
            <cfif isDefined("arguments.unit_id")>  
                ,UNIT_ID = <cfif isDefined("arguments.unit_id") and len(arguments.unit_id)> <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.unit_id#"><cfelse>NULL</cfif>
            </cfif>
            <cfif isDefined("arguments.quantity")>
                ,QUANTITY = <cfif len(arguments.quantity)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.quantity#"><cfelse>NULL</cfif>
            </cfif>    
            <cfif isDefined("arguments.amount")>
                ,AMOUNT = <cfif isDefined("arguments.amount") and len(arguments.amount)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.amount#"><cfelse>0</cfif>
            </cfif> 
            <cfif isDefined("arguments.money_type")>   
                ,MONEY_TYPE =<cfif len(arguments.money_type)><cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.money_type#"><cfelse>NULL</cfif>
            </cfif>    
            <cfif isDefined("arguments.period")>
                ,PERIOT =<cfif len(arguments.period)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.period#"><cfelse>NULL</cfif>
            </cfif>  
            <cfif isDefined("arguments.start_date")>  
                ,START_DATE = <cfif len(arguments.start_date)><cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.start_date#"><cfelse>NULL</cfif>
            </cfif>    
            <cfif isDefined("arguments.process_stage")>
                ,PROCESS_STAGE = <cfif len(arguments.process_stage)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.process_stage#"><cfelse>NULL</cfif>
            </cfif>    
            <cfif isDefined("arguments.paymethod_id") and len(arguments.paymethod_id)><!--- aslında bos olmamsı lazım ama eski kayıtlarda proble olabilir diye AE--->
                ,PAYMETHOD_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.paymethod_id#">
            <cfelse>
                ,PAYMETHOD_ID = NULL
            </cfif>
            <cfif isDefined("arguments.card_paymethod_id") and len(arguments.card_paymethod_id)>
                ,CARD_PAYMETHOD_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.card_paymethod_id#">
            <cfelse>
                ,CARD_PAYMETHOD_ID = NULL
            </cfif>
            <cfif isDefined("cgi.remote_addr")>
                ,UPDATE_IP = <cfqueryparam cfsqltype="cf_sql_nvarchar" value="#cgi.remote_addr#">
            <cfelse>
                ,UPDATE_IP = NULL
            </cfif>  
            <cfif isDefined('session.pp.userid')>
                ,UPDATE_EMP = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.pp.userid#">   
            <cfelseif isDefined('session.ep.userid')> 
                ,UPDATE_EMP = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#">  
            <cfelseif isDefined('session.ww.userid')> 
                ,UPDATE_EMP = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ww.userid#">
            <cfelse>
                ,UPDATE_EMP = NULL
            </cfif>
            WHERE 
                SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_id#">
        </cfquery> 
    </cffunction>

    <cffunction name="ADD_PAYMENT_PLAN" returntype="any">
        <cfargument name="subscription_id"  required="yes" default="">
        <cfargument name="product_id" required="yes" default="">
        <cfargument name="stock_id" required="yes"  default="">
        <cfargument name="unit" default="">
        <cfargument name="unit_id" required="yes" default="">
        <cfargument name="quantity" default="">
        <cfargument name="amount" required="yes" default="">
        <cfargument name="money_type" required="yes" default="">
        <cfargument name="period" required="yes" default="">
        <cfargument name="start_date" default="">
        <cfargument name="paymethod_id" default="">
        <cfargument name="card_paymethod_id" default="">
        <cfargument name="RECORD_DATE" default="#now()#">
        <cfargument name="process_stage" required="yes" default="">
        <cfquery name="ADD_PAYMENT_PLAN" datasource="#dsn3#">
            INSERT INTO
                SUBSCRIPTION_PAYMENT_PLAN
                (
                    SUBSCRIPTION_ID,
                    PRODUCT_ID,
                    STOCK_ID,
                    UNIT,
                    UNIT_ID,
                    QUANTITY,
                    AMOUNT,
                    MONEY_TYPE,
                    PERIOT,
                    START_DATE,
                    PAYMETHOD_ID,
                    CARD_PAYMETHOD_ID,
                    PROCESS_STAGE,
                    RECORD_DATE,
                    RECORD_IP,
                    RECORD_EMP
                )
                VALUES
                (
                    <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_id#">,
                    <cfif isDefined("arguments.product_id") and len(arguments.product_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.product_id#">,<cfelse>NULL,</cfif>
                    <cfif isDefined("arguments.stock_id") and len(arguments.stock_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.stock_id#">,<cfelse>NULL,</cfif>
                    <cfif isDefined("arguments.unit") and len(arguments.unit)><cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.unit#">,<cfelse>NULL,</cfif>
                    <cfif isDefined("arguments.unit_id") and len(arguments.unit_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.unit_id#">,<cfelse>NULL,</cfif>
                    <cfqueryparam cfsqltype="cf_sql_float" value="#arguments.quantity#">,
                    <cfif isDefined("arguments.amount") and len(arguments.amount)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.amount#">,<cfelse>0,</cfif>
                    <cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.money_type#">,
                    <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.period#">,
                    <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.start_date#">,
                <cfif isDefined("arguments.paymethod_id") and len(arguments.paymethod_id)>
                    <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.paymethod_id#">,
                <cfelse>
                    NULL,
                </cfif>
                <cfif isDefined("arguments.card_paymethod_id") and len(arguments.card_paymethod_id)>
                    <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.card_paymethod_id#">,
                <cfelse>
                    NULL,
                </cfif>
                    <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.process_stage#">,
                    <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
                <cfif isDefined("cgi.remote_addr")>
                    <cfqueryparam cfsqltype="cf_sql_nvarchar" value="#cgi.remote_addr#">,
                <cfelse>
                    NULL,
                </cfif>    
                <cfif isDefined('session.pp.userid')>
                    <cfqueryparam cfsqltype="cf_sql_integer" value="#session.pp.userid#">   
                <cfelseif isDefined('session.ep.userid')> 
                    <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#">  
                <cfelseif isDefined('session.ww.userid')> 
                    <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ww.userid#"> 
                <cfelse>
                    NULL
                </cfif>    
                )
        </cfquery>
    </cffunction> 

    <cffunction name="UPD_PREMIUM_DATE" returntype="any">
        <cfargument name="start_date" default="">
        <cfargument name="subscription_id" required="yes" default="">
        <cfquery name="UPD_PREMIUM_DATE" datasource="#dsn3#">
            UPDATE 
                SUBSCRIPTION_CONTRACT
            SET
                PREMIUM_DATE = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.start_date#">
            WHERE
                SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_id#">
        </cfquery>
    </cffunction> 

    <cffunction name="UPD_PAYMENT_PLAN_ROW" returntype="any">
        <cfargument name="product_id" required="yes" default="">
        <cfargument name="stock_id" required="yes" default="">
        <cfargument name="payment_date" required="yes" default="">
        <cfargument name="unit" required="yes" default="">
        <cfargument name="unit_id" required="yes" default="">
        <cfargument name="quantity" required="yes" default="">
        <cfargument name="amount" required="yes" default="">
        <cfargument name="paymethod_id" required="yes" default="">
        <cfargument name="is_active" default="">
        <cfargument name="row_rate" default="">
        <cfargument name="UPDATE_DATE" default="#now()#">
        <cfargument name="payment_row_id" required="yes" default="">
        <cfargument name="row_reason_code" default="">
        <cfargument name="row_bsmv_rate" default="">
        <cfargument name="row_bsmv_amount" default="">
        <cfargument name="row_oiv_rate" default="">
        <cfargument name="row_oiv_amount" default="">
        <cfargument name="row_tevkifat_rate" default="">
        <cfargument name="row_tevkifat_amount" default="">
        <cfargument name="SUBSCRIPTION_ID" required="yes" default="">
        <cfargument name="HISTORY_ACTION_TYPE" default="2">
        <cfargument name="xml_payment_finish_date" default="">
        <cfquery name="UPD_PAYMENT_PLAN_ROW" datasource="#dsn3#">
            UPDATE 
                SUBSCRIPTION_PAYMENT_PLAN_ROW 
            SET
                UPDATE_DATE = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
                PRODUCT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.product_id#">,
                STOCK_ID =  <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.stock_id#">,   
                PAYMENT_DATE = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.payment_date#">,
                IS_ACTIVE = <cfif isDefined("arguments.is_active") and arguments.is_active eq 1>1<cfelse>0</cfif>, 
                DETAIL = <cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.detail#">, 
                UNIT = <cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.unit#">,
                UNIT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.unit_id#">,
                QUANTITY = <cfqueryparam cfsqltype="cf_sql_float" value="#arguments.quantity#">,    
                SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_id#">,
                AMOUNT = <cfif len(arguments.amount)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.amount#"><cfelse>0</cfif>,
                RATE = <cfif isDefined("arguments.row_rate") and len(arguments.row_rate)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.row_rate#"><cfelse>NULL</cfif>,
                REASON_CODE = <cfif isDefined("arguments.row_reason_code") and len(arguments.row_reason_code)><cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.row_reason_code#"><cfelse>NULL</cfif>
                <cfif isdefined("arguments.bill_info") and len(arguments.bill_info)>
                    ,IS_INVOICE_IPTAL = NULL
                </cfif>
                <cfif isdefined("arguments.payment_finish_date") and len(arguments.payment_finish_date) and isdefined("arguments.xml_payment_finish_date")>  
                    ,PAYMENT_FINISH_DATE = <cfif len(arguments.payment_finish_date) and len(arguments.xml_payment_finish_date)><cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.payment_finish_date#"><cfelse>NULL</cfif>
                </cfif>    
                <cfif isdefined("arguments.money_type_row")>   
                    ,MONEY_TYPE = <cfif len(arguments.money_type_row)><cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.money_type_row#"><cfelse>NULL</cfif>
                </cfif>   
                <cfif isdefined("arguments.row_total")>  
                    ,ROW_TOTAL = <cfif len(arguments.row_total)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.row_total#"><cfelse>0</cfif>
                </cfif>   
                <cfif isdefined("arguments.discount")> 
                    ,DISCOUNT = <cfif len(arguments.discount)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.discount#"><cfelse>0</cfif>
                </cfif>  
                <cfif isdefined("arguments.discount_amount")>   
                    ,DISCOUNT_AMOUNT = <cfif len(arguments.discount_amount)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.discount_amount#"><cfelse>0</cfif>
                </cfif>
                <cfif isdefined("arguments.row_net_total")>      
                    ,ROW_NET_TOTAL = <cfif len(arguments.row_net_total)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.row_net_total#"><cfelse>0</cfif>
                </cfif>   
                <cfif isdefined("arguments.is_collected_inv")> 
                    ,IS_COLLECTED_INVOICE = <cfif isDefined("arguments.is_collected_inv") and arguments.is_collected_inv eq 1>1<cfelse>0</cfif>
                </cfif>  
                <cfif isdefined("arguments.is_group_inv")>  
                    ,IS_GROUP_INVOICE = <cfif isDefined("arguments.is_group_inv") and arguments.is_group_inv eq 1>1<cfelse>0</cfif>
                </cfif>   
                <cfif isdefined("arguments.is_billed") and len(arguments.is_billed)> 
                    ,IS_BILLED = <cfif isDefined("arguments.is_billed") and arguments.is_billed eq 1>1<cfelse>0</cfif>
                </cfif>  
                <cfif isdefined("arguments.is_collected_prov") and len(arguments.is_collected_prov)>   
                    ,IS_COLLECTED_PROVISION = <cfif isDefined("arguments.is_collected_prov") and arguments.is_collected_prov eq 1>1<cfelse>0</cfif>
                </cfif>
                <cfif isdefined("arguments.is_paid") and len(arguments.is_paid)>
                    ,IS_PAID = <cfif isDefined("arguments.is_paid") and arguments.is_paid eq 1>1<cfelse>0</cfif>
                </cfif> 
                <cfif isdefined("arguments.invoice_id")>   
                    ,INVOICE_ID = <cfif isdefined("arguments.invoice_id") and len(arguments.invoice_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.invoice_id#"><cfelse>NULL</cfif>
                </cfif>    
                <cfif isdefined("arguments.period_id")>
                    ,PERIOD_ID = <cfif isdefined("arguments.period_id") and len(arguments.period_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.period_id#"><cfelse>NULL</cfif>
                </cfif>
                <cfif isDefined("arguments.paymethod_id") and len(arguments.paymethod_id)>    
                    ,PAYMETHOD_ID = <cfif isDefined("arguments.paymethod_id") and len(arguments.paymethod_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.paymethod_id#"><cfelse>NULL</cfif>
                </cfif>  
                <cfif isDefined("arguments.card_paymethod_id")> 
                    ,CARD_PAYMETHOD_ID = <cfif isDefined("arguments.card_paymethod_id") and len(arguments.card_paymethod_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.card_paymethod_id#"><cfelse>NULL</cfif>
                </cfif>
                <cfif isdefined("arguments.subs_ref_id")>
                    ,SUBS_REFERENCE_ID = <cfif isdefined("arguments.subs_ref_id") and len(arguments.subs_ref_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subs_ref_id#"><cfelse>NULL</cfif>
                </cfif>
                <cfif isdefined("arguments.service_id")>
                    ,SERVICE_ID = <cfif isdefined("arguments.service_id") and len(arguments.service_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.service_id#"><cfelse>NULL</cfif>
                </cfif>    
                <cfif isdefined("arguments.call_id")>
                    ,CALL_ID = <cfif isdefined("arguments.call_id") and len(arguments.call_id) and isdefined("arguments.call_no") and len(arguments.call_no)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.call_id#"><cfelse>NULL</cfif>
                </cfif>
                <cfif isdefined('arguments.camp_id')>
                    ,CAMPAIGN_ID = <cfif isdefined('arguments.camp_id') and len(arguments.camp_id) and isdefined("arguments.camp_name") and len(arguments.camp_name)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.camp_id#"><cfelse>NULL</cfif>
                </cfif>
                <cfif isdefined("arguments.cari_action_id")>
                    ,CARI_ACTION_ID = <cfif isDefined("arguments.is_paid") and isdefined("arguments.cari_action_id") and len(arguments.cari_action_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.cari_action_id#"><cfelse>NULL</cfif>
                </cfif>
                <cfif isdefined("arguments.cari_period_id")>
                    ,CARI_PERIOD_ID = <cfif isDefined("arguments.is_paid") and isdefined("arguments.cari_period_id") and len(arguments.cari_period_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.cari_period_id#"><cfelse>NULL</cfif>
                </cfif>
                <cfif isdefined("arguments.cari_act_type")>
                    ,CARI_ACT_TYPE = <cfif isDefined("arguments.is_paid") and isdefined("arguments.cari_act_type") and len(arguments.cari_act_type)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.cari_act_type#"><cfelse>NULL</cfif>
                </cfif>
                <cfif isdefined("arguments.cari_act_id")>    
                    ,CARI_ACT_ID = <cfif isDefined("arguments.is_paid") and isdefined("arguments.cari_act_id") and len(arguments.cari_act_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.cari_act_id#"><cfelse>NULL</cfif>
                </cfif>
                <cfif isdefined("arguments.cari_act_table")>
                    ,CARI_ACT_TABLE = <cfif isDefined("arguments.is_paid") and isdefined("arguments.cari_act_table") and len(arguments.cari_act_table)><cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.cari_act_table#"><cfelse>NULL</cfif>
                </cfif>
                <cfif isDefined("cgi.remote_addr")>    
                    ,UPDATE_IP =<cfqueryparam cfsqltype="cf_sql_nvarchar" value="#cgi.remote_addr#">
                <cfelse>
                    ,UPDATE_IP = NULL
                </cfif>
                <cfif isDefined('session.pp.userid')>
                    ,UPDATE_EMP = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.pp.userid#">   
                <cfelseif isDefined('session.ep.userid')> 
                    ,UPDATE_EMP = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#">  
                <cfelseif isDefined('session.ww.userid')> 
                    ,UPDATE_EMP = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ww.userid#">
                <cfelse>
                    ,UPDATE_EMP = NULL
                </cfif>    
                <cfif isdefined('arguments.row_bsmv_rate') and len(arguments.row_bsmv_rate)>, BSMV_RATE = <cfqueryparam cfsqltype="cf_sql_float" value="#arguments.row_bsmv_rate#"></cfif>
                <cfif isdefined('arguments.row_bsmv_amount') and len(arguments.row_bsmv_amount)>, BSMV_AMOUNT = <cfqueryparam cfsqltype="cf_sql_float" value="#arguments.row_bsmv_amount#"></cfif>
                <cfif isdefined('arguments.row_oiv_rate') and len(arguments.row_oiv_rate)>, OIV_RATE = <cfqueryparam cfsqltype="cf_sql_float" value="#arguments.row_oiv_rate#"></cfif>
                <cfif isdefined('arguments.row_oiv_amount') and len(arguments.row_oiv_amount)>, OIV_AMOUNT = <cfqueryparam cfsqltype="cf_sql_float" value="#arguments.row_oiv_amount#"></cfif>
                <cfif isdefined('arguments.row_tevkifat_rate') and len(arguments.row_tevkifat_rate)>, TEVKIFAT_RATE = <cfqueryparam cfsqltype="cf_sql_float" value="#arguments.row_tevkifat_rate#"></cfif>
                <cfif isdefined('arguments.row_tevkifat_amount') and len(arguments.row_tevkifat_amount)>, TEVKIFAT_AMOUNT = <cfqueryparam cfsqltype="cf_sql_float" value="#arguments.row_tevkifat_amount#"></cfif>
            WHERE
                SUBSCRIPTION_PAYMENT_ROW_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.payment_row_id#">
        </cfquery>
        <cfquery name="SUBSCRIPTION_PAYMENT_PLAN_ROW_HISTORY_DETAIL" datasource="#dsn3#">
            INSERT INTO
                SUBSCRIPTION_PAYMENT_PLAN_ROW_HISTORY_DETAIL 
                (
                    SUBSCRIPTION_PAYMENT_ROW_ID,
                    UPDATE_DATE
                <cfif isdefined("arguments.bill_info") and len(arguments.bill_info)>
                    ,IS_INVOICE_IPTAL
                </cfif> 
                <cfif isdefined("arguments.subscription_id")>     
                    ,SUBSCRIPTION_ID
                </cfif>    
                <cfif isdefined("arguments.product_id")>    
                    ,PRODUCT_ID
                </cfif>    
                <cfif isdefined("arguments.stock_id")>    
                    ,STOCK_ID
                </cfif>    
                <cfif isdefined("arguments.payment_date")>
                   ,PAYMENT_DATE
                </cfif>    
                <cfif isdefined("arguments.payment_finish_date") and len(arguments.payment_finish_date) and isdefined("arguments.xml_payment_finish_date")>
                    ,PAYMENT_FINISH_DATE
                </cfif>
                <cfif isdefined("arguments.detail")>
                    ,DETAIL
                </cfif>
                <cfif isdefined("arguments.UNIT")>
                    ,UNIT 
                </cfif>    
                <cfif isdefined("arguments.UNIT_ID")>  
                    ,UNIT_ID 
                </cfif>    
                <cfif isdefined("arguments.quantity")>  
                    ,QUANTITY
                </cfif>    
                <cfif isdefined("arguments.amount")>
                    ,AMOUNT
                </cfif>       
                <cfif isdefined("arguments.money_type_row")>
                    ,MONEY_TYPE
                </cfif>    
                <cfif isdefined("arguments.row_total")>  
                    ,ROW_TOTAL
                </cfif> 
                <cfif isdefined("arguments.discount")>     
                    ,DISCOUNT
                </cfif>
                <cfif isdefined("arguments.discount_amount")>     
                    ,DISCOUNT_AMOUNT
                </cfif> 
                <cfif isdefined("arguments.row_net_total")>   
                    ,ROW_NET_TOTAL
                </cfif> 
                <cfif isdefined("arguments.is_collected_inv")>   
                    ,IS_COLLECTED_INVOICE
                </cfif>    
                <cfif isdefined("arguments.is_group_inv")>
                    ,IS_GROUP_INVOICE
                </cfif>    
                <cfif isDefined("arguments.is_billed")> 
                    ,IS_BILLED
                </cfif>
                <cfif isDefined("arguments.is_collected_prov")>
                    ,IS_COLLECTED_PROVISION
                </cfif> 
                <cfif isDefined("arguments.is_paid")>   
                    ,IS_PAID
                </cfif>  
                <cfif isdefined("arguments.invoice_id")>   
                    ,INVOICE_ID
                </cfif>    
                <cfif isdefined("arguments.period_id")>   
                    ,PERIOD_ID
                </cfif>
                <cfif isDefined("arguments.PAYMETHOD_ID")>      
                    ,PAYMETHOD_ID
                </cfif>    
                <cfif isDefined("arguments.card_paymethod_id")>   
                    ,CARD_PAYMETHOD_ID
                </cfif>    
                <cfif isdefined('arguments.subs_ref_id') and isdefined('arguments.subs_ref_name')>
                    ,SUBS_REFERENCE_ID
                </cfif>   
                <cfif isdefined('arguments.service_id') and isdefined('arguments.service_no')> 
                    ,SERVICE_ID
                </cfif>    
                <cfif isdefined('arguments.camp_id') and isdefined('arguments.camp_name')>
                    ,CAMPAIGN_ID
                </cfif>
                <cfif isdefined('arguments.call_id') and isdefined('arguments.call_no')>    
                    ,CALL_ID
                </cfif>  
                <cfif isdefined('arguments.cari_action_id')>  
                    ,CARI_ACTION_ID
                </cfif>   
                <cfif isdefined('arguments.cari_period_id')> 
                    ,CARI_PERIOD_ID
                </cfif>  
                <cfif isdefined('arguments.cari_act_type')>  
                    ,CARI_ACT_TYPE
                </cfif>   
                <cfif isdefined('arguments.cari_act_id')> 
                    ,CARI_ACT_ID
                </cfif>   
                <cfif isdefined('arguments.cari_act_table')> 
                    ,CARI_ACT_TABLE
                </cfif> 
                <cfif isDefined("arguments.is_active")>   
                    ,IS_ACTIVE
                </cfif>    
                <cfif isDefined("cgi.remote_addr")>  
                    ,UPDATE_IP
                </cfif> 
                <cfif isDefined('session.pp.userid')>
                    ,UPDATE_EMP   
                <cfelseif isDefined('session.ep.userid')> 
                    ,UPDATE_EMP 
                <cfelseif isDefined('session.ww.userid')> 
                    ,UPDATE_EMP 
                </cfif> 
                <cfif isDefined("arguments.row_rate")>   
                    ,RATE
                </cfif>  
                    ,HISTORY_ACTION_TYPE      
                )
            VALUES
                (
                <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.payment_row_id#">,
                <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
                <cfif isdefined("arguments.bill_info") and len(arguments.bill_info)>
                    ,NULL   
                </cfif> 
                <cfif isdefined("arguments.subscription_id")> 
                    ,<cfif len(arguments.subscription_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_id#"><cfelse>NULL</cfif>
                </cfif>
                <cfif isdefined("arguments.product_id")>
                    ,<cfif len(arguments.product_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.product_id#"><cfelse>NULL</cfif>
                </cfif>
                <cfif isdefined("arguments.stock_id")>
                    ,<cfif len(arguments.stock_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.stock_id#"><cfelse>NULL</cfif>
                </cfif>
                <cfif isdefined("arguments.payment_date")>
                    ,<cfif len(arguments.payment_date)><cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.payment_date#"><cfelse>NULL</cfif>
                </cfif>    
                <cfif isdefined("arguments.payment_finish_date") and len(arguments.payment_finish_date) and isdefined("arguments.xml_payment_finish_date")>
                    ,<cfif len(arguments.payment_finish_date) and len(arguments.xml_payment_finish_date)><cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.payment_finish_date#"><cfelse>NULL</cfif>   
                </cfif>
                <cfif isdefined("arguments.detail")>
                    ,<cfif len(arguments.detail)><cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.detail#"><cfelse>NULL</cfif>
                </cfif>  
                <cfif isdefined("arguments.UNIT")> 
                    ,<cfif len(arguments.unit)><cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.unit#"><cfelse>NULL</cfif>
                </cfif>    
                <cfif isdefined("arguments.UNIT_ID")> 
                    ,<cfif len(arguments.unit_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.unit_id#"><cfelse>NULL</cfif>
                </cfif>    
                <cfif isdefined("arguments.quantity")>
                    ,<cfif len(arguments.quantity)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.quantity#"><cfelse>NULL</cfif>
                </cfif>
                <cfif isdefined("arguments.amount")>
                    ,<cfif len(arguments.amount)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.amount#"><cfelse>0</cfif>
                </cfif>    
                <cfif isdefined("arguments.money_type_row")>
                    ,<cfif len(arguments.money_type_row)><cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.money_type_row#"><cfelse>NULL</cfif>
                </cfif>    
                <cfif isdefined("arguments.row_total")> 
                    ,<cfif len(arguments.row_total)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.row_total#"><cfelse>0</cfif>
                </cfif>
                <cfif isdefined("arguments.discount")>    
                    ,<cfif len(arguments.discount)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.discount#"><cfelse>0</cfif>
                </cfif> 
                <cfif isdefined("arguments.discount_amount")>   
                    ,<cfif len(arguments.discount_amount)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.discount_amount#"><cfelse>0</cfif>
                </cfif>  
                <cfif isdefined("arguments.row_net_total")>  
                    ,<cfif len(arguments.row_net_total)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.row_net_total#"><cfelse>0</cfif>
                </cfif>    
                <cfif isdefined("arguments.is_collected_inv")>
                    ,<cfif isDefined("arguments.is_collected_inv") and arguments.is_collected_inv eq 1>1<cfelse>0</cfif>
                </cfif>    
                <cfif isdefined("arguments.is_group_inv")>
                    ,<cfif isDefined("arguments.is_group_inv") and arguments.is_group_inv eq 1>1<cfelse>0</cfif>
                </cfif>  
                <cfif isDefined("arguments.is_billed")>  
                    ,<cfif isDefined("arguments.is_billed") and arguments.is_billed eq 1>1<cfelse>0</cfif>
                </cfif> 
                <cfif isDefined("arguments.is_collected_prov")>
                    ,<cfif isDefined("arguments.is_collected_prov") and arguments.is_collected_prov eq 1>1<cfelse>0</cfif>
                </cfif>  
                <cfif isDefined("arguments.is_paid")>    
                    ,<cfif isDefined("arguments.is_paid") and arguments.is_paid eq 1>1<cfelse>0</cfif>
                </cfif> 
                <cfif isdefined("arguments.invoice_id")>   
                    ,<cfif len(arguments.invoice_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.invoice_id#"><cfelse>NULL</cfif>
                </cfif>    
                <cfif isdefined("arguments.period_id")>
                    ,<cfif isdefined("arguments.period_id") and len(arguments.period_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.period_id#"><cfelse>NULL</cfif>
                </cfif>    
                <cfif isDefined("arguments.paymethod_id")>
                    ,<cfif len(arguments.paymethod_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.paymethod_id#"><cfelse>NULL</cfif>
                </cfif>
                <cfif isDefined("arguments.card_paymethod_id")>
                    ,<cfif len(arguments.card_paymethod_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.card_paymethod_id#"><cfelse>NULL</cfif>
                </cfif>
                <cfif isdefined("arguments.subs_ref_id") and isdefined("arguments.subs_ref_name")>
                    ,<cfif len(arguments.subs_ref_id) and len(arguments.subs_ref_name)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subs_ref_id#"><cfelse>NULL</cfif>
                </cfif>
                <cfif isdefined("arguments.service_id") and isdefined("arguments.service_no")>
                    ,<cfif len(arguments.service_id) and len(arguments.service_no)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.service_id#"><cfelse>NULL</cfif>
                </cfif>
                <cfif isdefined("arguments.camp_id") and isdefined("arguments.camp_name")>
                    ,<cfif len(arguments.camp_id)  and len(arguments.camp_name)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.camp_id#"><cfelse>NULL</cfif>
                </cfif>
                <cfif isdefined("arguments.call_id") and  isdefined("arguments.call_no")>
                    ,<cfif len(arguments.call_id) and len(arguments.call_no)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.call_id#"><cfelse>NULL</cfif>
                </cfif>
                <cfif isdefined("arguments.cari_action_id")>
                    ,<cfif len(arguments.cari_action_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.cari_action_id#"><cfelse>NULL</cfif>
                </cfif>   
                <cfif isdefined("arguments.cari_period_id")> 
                    ,<cfif len(arguments.cari_period_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.cari_period_id#"><cfelse>NULL</cfif>
                </cfif>
                <cfif isdefined("arguments.cari_act_type")>
                    ,<cfif len(arguments.cari_act_type)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.cari_act_type#"><cfelse>NULL</cfif>
                </cfif>
                <cfif isdefined("arguments.cari_act_id")>
                    ,<cfif len(arguments.cari_act_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.cari_act_id#"><cfelse>NULL</cfif>
                </cfif>
                <cfif isdefined("arguments.cari_act_table")>
                    ,<cfif len(arguments.cari_act_table)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.cari_act_table#"><cfelse>NULL</cfif>
                </cfif>
                <cfif isDefined("arguments.is_active")>
                    ,<cfif len(arguments.is_active) and arguments.is_active>1<cfelse>0</cfif>
                </cfif>   
                <cfif isDefined("cgi.remote_addr")>
                    ,<cfqueryparam cfsqltype="cf_sql_nvarchar" value="#cgi.remote_addr#">
                <cfelse>
                    ,NULL
                </cfif>
                <cfif isDefined('session.pp.userid')>
                    ,<cfqueryparam cfsqltype="cf_sql_integer" value="#session.pp.userid#">   
                <cfelseif isDefined('session.ep.userid')> 
                    ,<cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#">  
                <cfelseif isDefined('session.ww.userid')> 
                    ,<cfqueryparam cfsqltype="cf_sql_integer" value="#session.ww.userid#"> 
                <cfelse>
                    ,NULL
                </cfif> 
                <cfif isDefined("arguments.row_rate")>    
                    ,<cfif len(arguments.row_rate)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.row_rate#"><cfelse>NULL</cfif>
                </cfif> 
                ,<cfif len(arguments.HISTORY_ACTION_TYPE)> <cfqueryparam cfsqltype="cf_sql_integer" value="2"><cfelse>NULL</cfif>
                )
        </cfquery>   
    </cffunction> 

    <cffunction name="IS_PAID" returntype="any">
        <cfargument name="is_collected_prov" default="">
        <cfargument name="is_paid" default="">
        <cfargument name="UPDATE_DATE" default="#now()#">
        <cfargument name="payment_row_id" required="yes" default="">
        <cfquery name="IS_PAID" datasource="#dsn3#">
            UPDATE
                SUBSCRIPTION_PAYMENT_PLAN_ROW 
            SET
                IS_COLLECTED_PROVISION = <cfif isDefined("arguments.is_collected_prov") and arguments.is_collected_prov eq 1>1,<cfelse>0,</cfif>
                IS_PAID = <cfif isDefined("arguments.is_paid") and arguments.is_paid eq 1>1,<cfelse>0,</cfif>
                UPDATE_DATE = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
                UPDATE_IP = <cfqueryparam cfsqltype="cf_sql_nvarchar" value="#cgi.remote_addr#">,
                <cfif isDefined('session.pp.userid')>
                    UPDATE_EMP = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.pp.userid#">   
                <cfelseif isDefined('session.ep.userid')> 
                    UPDATE_EMP = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#">  
                <cfelseif isDefined('session.ww.userid')> 
                    UPDATE_EMP = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ww.userid#">
                </cfif>
            WHERE
                SUBSCRIPTION_PAYMENT_ROW_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.payment_row_id#">
        </cfquery>
    </cffunction>
    <cffunction name="ADD_PAYMENT_PLAN_ROW" returntype="any">
        <cfargument name="bill_info" default="">
        <cfargument name="row_bsmv_rate" default="">
        <cfargument name="row_bsmv_amount" default="">
        <cfargument name="row_oiv_rate" default="">
        <cfargument name="row_oiv_amount" default="">
        <cfargument name="row_tevkifat_rate" default="">
        <cfargument name="row_tevkifat_amount" default="">
        <cfargument name="subscription_id" required="yes" default="">
        <cfargument name="product_id" required="yes" default="">
        <cfargument name="stock_id" required="yes" default="">
        <cfargument name="payment_date" required="yes" default="">
        <cfargument name="unit" required="yes" default="">
        <cfargument name="unit_id" required="yes" default="">
        <cfargument name="quantity" required="yes" default="">
        <cfargument name="amount" required="yes" default="">
        <cfargument name="money_type_row" default="">
        <cfargument name="paymethod_id" required="yes" default="">
        <cfargument name="row_reason_code" default="">  
        <cfargument name="UPDATE_DATE" default="#now()#">
        <cfargument name="HISTORY_ACTION_TYPE" default="1">
            <cfquery name="ADD_PAYMENT_PLAN_ROW" datasource="#dsn3#" RESULT="MAX">
                INSERT INTO
                    SUBSCRIPTION_PAYMENT_PLAN_ROW
                    (
                        SUBSCRIPTION_ID,
                        RECORD_DATE,
                        PRODUCT_ID,
                        STOCK_ID,
                        PAYMENT_DATE,
                        UNIT,  
                        MONEY_TYPE,  
                        QUANTITY,
                        AMOUNT,  
                        UNIT_ID,   
                        PAYMETHOD_ID,
                        REASON_CODE
                    <cfif isdefined("arguments.bill_info") and len(arguments.bill_info)>,IS_INVOICE_IPTAL</cfif> 
                    <cfif isdefined("arguments.payment_finish_date")>
                        ,PAYMENT_FINISH_DATE
                    </cfif>
                    <cfif isdefined("arguments.detail")>
                        ,DETAIL
                    </cfif>
                    <cfif isdefined("arguments.row_total")>  
                        ,ROW_TOTAL
                    </cfif> 
                    <cfif isdefined("arguments.discount")>     
                        ,DISCOUNT
                    </cfif>
                    <cfif isdefined("arguments.discount_amount")>     
                        ,DISCOUNT_AMOUNT
                    </cfif> 
                    <cfif isdefined("arguments.row_net_total")>   
                        ,ROW_NET_TOTAL
                    </cfif> 
                    <cfif isdefined("arguments.is_collected_inv")>   
                        ,IS_COLLECTED_INVOICE
                    </cfif>    
                    <cfif isdefined("arguments.is_group_inv")>
                        ,IS_GROUP_INVOICE
                    </cfif>    
                    <cfif isDefined("arguments.is_billed") and isdefined("arguments.invoice_id")> 
                        ,IS_BILLED
                    </cfif>
                    <cfif isDefined("arguments.is_collected_prov")>
                        ,IS_COLLECTED_PROVISION
                    </cfif> 
                    <cfif isDefined("arguments.is_paid")>   
                        ,IS_PAID
                    </cfif>  
                    <cfif isdefined("arguments.invoice_id")>   
                        ,INVOICE_ID
                    </cfif>    
                    <cfif isdefined("arguments.period_id")>   
                        ,PERIOD_ID
                    </cfif>    
                    <cfif isDefined("arguments.card_paymethod_id")>   
                        ,CARD_PAYMETHOD_ID
                    </cfif>    
                    <cfif isdefined('arguments.subs_ref_id') and isdefined('arguments.subs_ref_name')>
                        ,SUBS_REFERENCE_ID
                    </cfif>   
                    <cfif isdefined('arguments.service_id') and isdefined('arguments.service_no')> 
                        ,SERVICE_ID
                    </cfif>    
                    <cfif isdefined('arguments.camp_id') and isdefined('arguments.camp_name')>
                        ,CAMPAIGN_ID
                    </cfif>
                    <cfif isdefined('arguments.call_id') and isdefined('arguments.call_no')>    
                        ,CALL_ID
                    </cfif>  
                    <cfif isdefined('arguments.cari_action_id')>  
                        ,CARI_ACTION_ID
                    </cfif>   
                    <cfif isdefined('arguments.cari_period_id')> 
                        ,CARI_PERIOD_ID
                    </cfif>  
                    <cfif isdefined('arguments.cari_act_type')>  
                        ,CARI_ACT_TYPE
                    </cfif>   
                    <cfif isdefined('arguments.cari_act_id')> 
                        ,CARI_ACT_ID
                    </cfif>   
                    <cfif isdefined('arguments.cari_act_table')> 
                        ,CARI_ACT_TABLE
                    </cfif> 
                    <cfif isDefined("arguments.is_active")>   
                        ,IS_ACTIVE
                    </cfif> 
                    <cfif isDefined("arguments.row_rate")>   
                        ,RATE
                    </cfif>  
                        ,RECORD_IP
                        ,RECORD_EMP
                        <cfif isdefined('arguments.row_bsmv_rate') and len(arguments.row_bsmv_rate)>,BSMV_RATE</cfif>
                        <cfif isdefined('arguments.row_bsmv_amount') and len(arguments.row_bsmv_amount)>,BSMV_AMOUNT</cfif>
                        <cfif isdefined('arguments.row_oiv_rate') and len(arguments.row_oiv_rate)>,OIV_RATE</cfif>
                        <cfif isdefined('arguments.row_oiv_amount') and len(arguments.row_oiv_amount)>,OIV_AMOUNT</cfif>
                        <cfif isdefined('arguments.row_tevkifat_rate') and len(arguments.row_tevkifat_rate)>,TEVKIFAT_RATE</cfif>
                        <cfif isdefined('arguments.row_tevkifat_amount') and len(arguments.row_tevkifat_amount)>,TEVKIFAT_AMOUNT</cfif> 
                        <cfif isdefined('arguments.row_is_counter') and len(arguments.row_is_counter)>,IS_COUNTER</cfif>
                        <cfif isdefined('arguments.row_our_company_id') and len(arguments.row_our_company_id)>,OUR_COMPANY_ID</cfif>
                        <cfif isdefined('arguments.scm_id') and len(arguments.scm_id)>,CM_ID</cfif>
                    )
                VALUES
                    (
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_id#">,
                        <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.product_id#">,
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.stock_id#">,
                        <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.payment_date#">,
                        <cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.unit#">, 
                        <cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.money_type_row#">,
                        <cfqueryparam cfsqltype="cf_sql_float" value="#arguments.quantity#">
                        <cfif len(arguments.amount)>,<cfqueryparam cfsqltype="cf_sql_float" value="#arguments.amount#"><cfelse>,0</cfif>
                        <cfif isdefined("arguments.UNIT_ID") and len(arguments.UNIT_ID)>,<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.unit_id#"><cfelse>,0</cfif>    
                        <cfif isDefined("arguments.paymethod_id") and len(arguments.paymethod_id)>,<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.paymethod_id#"><cfelse>,NULL</cfif>
                        <cfif isDefined("arguments.row_reason_code") and len(arguments.row_reason_code)>,<cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.row_reason_code#"><cfelse>,NULL</cfif>
                        <cfif isdefined("arguments.bill_info") and len(arguments.bill_info)>,NULL</cfif> 
                        <cfif isdefined("arguments.payment_finish_date")>
                            ,<cfif len(arguments.payment_finish_date)><cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.payment_finish_date#"><cfelse>NULL</cfif>
                        </cfif>    
                        <cfif isdefined("arguments.detail")>
                            ,<cfif len(arguments.detail)><cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.detail#"><cfelse>NULL</cfif>
                        </cfif>  
                        <cfif isdefined("arguments.row_total")> 
                            ,<cfif len(arguments.row_total)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.row_total#"><cfelse>0</cfif>
                        </cfif>
                        <cfif isdefined("arguments.discount")>    
                            ,<cfif len(arguments.discount)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.discount#"><cfelse>0</cfif>
                        </cfif> 
                        <cfif isdefined("arguments.discount_amount")>   
                            ,<cfif len(arguments.discount_amount)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.discount_amount#"><cfelse>0</cfif>
                        </cfif>  
                        <cfif isdefined("arguments.row_net_total")>  
                            ,<cfif len(arguments.row_net_total)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.row_net_total#"><cfelse>0</cfif>
                        </cfif>    
                        <cfif isdefined("arguments.is_collected_inv")>
                            ,<cfif isDefined("arguments.is_collected_inv") and arguments.is_collected_inv eq 1>1<cfelse>0</cfif>
                        </cfif>    
                        <cfif isdefined("arguments.is_group_inv")>
                            ,<cfif isDefined("arguments.is_group_inv") and arguments.is_group_inv eq 1>1<cfelse>0</cfif>
                        </cfif>  
                        <cfif isDefined("arguments.is_billed")>  
                            ,<cfif (isDefined("arguments.is_billed") or isdefined("arguments.invoice_id")) and  arguments.is_billed eq 1>1<cfelse>0</cfif>
                        </cfif>
                        <cfif isDefined("arguments.is_collected_prov")>
                            ,<cfif isDefined("arguments.is_collected_prov") and arguments.is_collected_prov eq 1>1<cfelse>0</cfif>
                        </cfif>  
                        <cfif isDefined("arguments.is_paid")>    
                            ,<cfif isDefined("arguments.is_paid")  and arguments.is_paid eq 1>1<cfelse>0</cfif>
                        </cfif> 
                        <cfif isdefined("arguments.invoice_id")>   
                            ,<cfif isdefined("arguments.invoice_id") and len(arguments.invoice_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.invoice_id#"><cfelse>NULL</cfif>
                        </cfif>   
                        <cfif isdefined("arguments.period_id")>
                            ,<cfif isdefined("arguments.period_id") and len(arguments.period_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.period_id#"><cfelse>NULL</cfif>
                        </cfif>    
                        <cfif isDefined("arguments.card_paymethod_id")>
                            ,<cfif isDefined("arguments.card_paymethod_id") and len(arguments.card_paymethod_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.card_paymethod_id#"><cfelse>NULL</cfif>
                        </cfif>
                        <cfif isdefined('arguments.subs_ref_id') and isdefined('arguments.subs_ref_name')>
                            ,<cfif isdefined('arguments.subs_ref_id') and len(arguments.subs_ref_id) and isdefined('arguments.subs_ref_name') and len(arguments.subs_ref_name)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subs_ref_id#"><cfelse>NULL</cfif>
                        </cfif>
                        <cfif isdefined('arguments.service_id') and isdefined('arguments.service_no')>
                            ,<cfif isdefined('arguments.service_id') and len(arguments.service_id) and isdefined('arguments.service_no') and len(arguments.service_no)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.service_id#"><cfelse>NULL</cfif>
                        </cfif>
                        <cfif isdefined('arguments.camp_id') and isdefined('arguments.camp_name')>
                            ,<cfif isdefined('arguments.camp_id') and len(arguments.camp_id) and isdefined('arguments.camp_name') and len(arguments.camp_name)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.camp_id#"><cfelse>NULL</cfif>
                        </cfif>
                        <cfif isdefined('arguments.call_id') and  isdefined('arguments.call_no')>
                            ,<cfif isdefined('arguments.call_id') and len(arguments.call_id) and isdefined('arguments.call_no') and len(arguments.call_no)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.call_id#"><cfelse>NULL</cfif>
                        </cfif>
                        <cfif isdefined('arguments.cari_action_id')>
                            ,<cfif isdefined('arguments.cari_action_id') and len(arguments.cari_action_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.cari_action_id#"><cfelse>NULL</cfif>
                        </cfif>   
                        <cfif isdefined('arguments.cari_period_id')> 
                            ,<cfif isdefined('arguments.cari_period_id') and len(arguments.cari_period_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.cari_period_id#"><cfelse>NULL</cfif>
                        </cfif>
                        <cfif isdefined('arguments.cari_act_type')>
                            ,<cfif isdefined('arguments.cari_act_type') and len(arguments.cari_act_type)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.cari_act_type#"><cfelse>NULL</cfif>
                        </cfif>
                        <cfif isdefined('arguments.cari_act_id')>
                           ,<cfif isdefined('arguments.cari_act_id') and len(arguments.cari_act_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.cari_act_id#"><cfelse>NULL</cfif>
                        </cfif>
                        <cfif isdefined('arguments.cari_act_table')>
                            ,<cfif isdefined('arguments.cari_act_table') and len(arguments.cari_act_table)><cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.cari_act_table#"><cfelse>NULL</cfif>
                        </cfif>
                        <cfif isDefined("arguments.is_active")>
                            ,<cfif isDefined("arguments.is_active")>1<cfelse>0</cfif>
                        </cfif>  
                        <cfif isDefined("arguments.row_rate")>    
                            ,<cfif isDefined("arguments.row_rate") and len(arguments.row_rate)>#arguments.row_rate#<cfelse>NULL</cfif>
                        </cfif> 
                        <cfif isDefined("cgi.remote_addr")>
                            ,<cfqueryparam cfsqltype="cf_sql_nvarchar" value="#cgi.remote_addr#">
                        <cfelse>
                            ,NULL
                        </cfif>
                        <cfif isDefined('session.pp.userid')>
                            ,<cfqueryparam cfsqltype="cf_sql_integer" value="#session.pp.userid#">   
                        <cfelseif isDefined('session.ep.userid')> 
                            ,<cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#">  
                        <cfelseif isDefined('session.ww.userid')> 
                            ,<cfqueryparam cfsqltype="cf_sql_integer" value="#session.ww.userid#"> 
                        <cfelse>
                            ,NULL
                        </cfif> 
                        <cfif isdefined('arguments.row_bsmv_rate') and len(arguments.row_bsmv_rate)>,<cfqueryparam cfsqltype="cf_sql_float" value="#arguments.row_bsmv_rate#"></cfif>
                        <cfif isdefined('arguments.row_bsmv_amount') and len(arguments.row_bsmv_amount)>,<cfqueryparam cfsqltype="cf_sql_float" value="#arguments.row_bsmv_amount#"></cfif>
                        <cfif isdefined('arguments.row_oiv_rate') and len(arguments.row_oiv_rate)>,<cfqueryparam cfsqltype="cf_sql_float" value="#arguments.row_oiv_rate#"></cfif>
                        <cfif isdefined('arguments.row_oiv_amount') and len(arguments.row_oiv_amount)>,<cfqueryparam cfsqltype="cf_sql_float" value="#arguments.row_oiv_amount#"></cfif>
                        <cfif isdefined('arguments.row_tevkifat_rate') and len(arguments.row_tevkifat_rate)>,<cfqueryparam cfsqltype="cf_sql_float" value="#arguments.row_tevkifat_rate#"></cfif>
                        <cfif isdefined('arguments.row_tevkifat_amount') and len(arguments.row_tevkifat_amount)>,<cfqueryparam cfsqltype="cf_sql_float" value="#arguments.row_tevkifat_amount#"></cfif> 
                        <cfif isdefined('arguments.row_is_counter') and len(arguments.row_is_counter)>,<cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.row_is_counter#"></cfif>
                        <cfif isdefined('arguments.row_our_company_id') and len(arguments.row_our_company_id)>,<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.row_our_company_id#"></cfif>
                        <cfif isdefined('arguments.scm_id') and len(arguments.scm_id)>,<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.scm_id#"></cfif>
                    )
            </cfquery>     
            <cfquery name="SUBSCRIPTION_PAYMENT_PLAN_ROW_HISTORY_DETAIL" datasource="#dsn3#">
                INSERT INTO
                    SUBSCRIPTION_PAYMENT_PLAN_ROW_HISTORY_DETAIL 
                    (
                        SUBSCRIPTION_PAYMENT_ROW_ID,
                        SUBSCRIPTION_ID,
                        HISTORY_ACTION_DATE,
                        PRODUCT_ID,
                        STOCK_ID,
                        PAYMENT_DATE,
                        UNIT,  
                        MONEY_TYPE,  
                        QUANTITY,
                        AMOUNT, 
                        UNIT_ID,    
                        PAYMETHOD_ID
                    <cfif isdefined("arguments.bill_info") and len(arguments.bill_info)>,IS_INVOICE_IPTAL</cfif> 
                    <cfif isdefined("arguments.payment_finish_date")>
                        ,PAYMENT_FINISH_DATE
                    </cfif>
                    <cfif isdefined("arguments.detail")>
                        ,DETAIL
                    </cfif>
                    <cfif isdefined("arguments.row_total")>  
                        ,ROW_TOTAL
                    </cfif> 
                    <cfif isdefined("arguments.discount")>     
                        ,DISCOUNT
                    </cfif>
                    <cfif isdefined("arguments.discount_amount")>     
                        ,DISCOUNT_AMOUNT
                    </cfif> 
                    <cfif isdefined("arguments.row_net_total")>   
                        ,ROW_NET_TOTAL
                    </cfif> 
                    <cfif isdefined("arguments.is_collected_inv")>   
                        ,IS_COLLECTED_INVOICE
                    </cfif>    
                    <cfif isdefined("arguments.is_group_inv")>
                        ,IS_GROUP_INVOICE
                    </cfif>    
                    <cfif isDefined("arguments.is_billed")> 
                        ,IS_BILLED
                    </cfif>
                    <cfif isDefined("arguments.is_collected_prov")>
                        ,IS_COLLECTED_PROVISION
                    </cfif> 
                    <cfif isDefined("arguments.is_paid")>   
                        ,IS_PAID
                    </cfif>  
                    <cfif isdefined("arguments.invoice_id")>   
                        ,INVOICE_ID
                    </cfif>    
                    <cfif isdefined("arguments.period_id")>   
                        ,PERIOD_ID
                    </cfif>   
                    <cfif isDefined("arguments.card_paymethod_id")>   
                        ,CARD_PAYMETHOD_ID
                    </cfif>    
                    <cfif isdefined('arguments.subs_ref_id') and isdefined('arguments.subs_ref_name')>
                        ,SUBS_REFERENCE_ID
                    </cfif>   
                    <cfif isdefined('arguments.service_id') and isdefined('arguments.service_no')> 
                        ,SERVICE_ID
                    </cfif>    
                    <cfif isdefined('arguments.camp_id') and isdefined('arguments.camp_name')>
                        ,CAMPAIGN_ID
                    </cfif>
                    <cfif isdefined('arguments.call_id') and isdefined('arguments.call_no')>    
                        ,CALL_ID
                    </cfif>  
                    <cfif isdefined('arguments.cari_action_id')>  
                        ,CARI_ACTION_ID
                    </cfif>   
                    <cfif isdefined('arguments.cari_period_id')> 
                        ,CARI_PERIOD_ID
                    </cfif>  
                    <cfif isdefined('arguments.cari_act_type')>  
                        ,CARI_ACT_TYPE
                    </cfif>   
                    <cfif isdefined('arguments.cari_act_id')> 
                        ,CARI_ACT_ID
                    </cfif>   
                    <cfif isdefined('arguments.cari_act_table')> 
                        ,CARI_ACT_TABLE
                    </cfif> 
                    <cfif isDefined("arguments.is_active")>   
                        ,IS_ACTIVE
                    </cfif>    
                    <cfif isDefined("arguments.row_rate")>   
                        ,RATE
                    </cfif>
                        ,RECORD_IP
                        ,HISTORY_ACTION_EMP
                        ,HISTORY_ACTION_TYPE 
                    )
                VALUES
                    (
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#MAX.IDENTITYCOL#">,
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_id#">,
                        <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.product_id#">,
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.stock_id#">,
                        <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.payment_date#">,
                        <cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.unit#">, 
                        <cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.money_type_row#">,
                        <cfqueryparam cfsqltype="cf_sql_float" value="#arguments.quantity#">,
                        <cfif len(arguments.amount)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.amount#"><cfelse>0</cfif>
                        <cfif isdefined("arguments.UNIT_ID") and len(arguments.UNIT_ID)>,<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.unit_id#"><cfelse>,0</cfif>  
                        <cfif isDefined("arguments.paymethod_id") and len(arguments.paymethod_id)>,<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.paymethod_id#"><cfelse>,NULL</cfif>
                        <cfif isdefined("arguments.bill_info") and len(arguments.bill_info)>
                            ,NULL
                        </cfif> 
                        <cfif isdefined("arguments.payment_finish_date")>
                            ,<cfif len(arguments.payment_finish_date)><cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.payment_finish_date#"><cfelse>NULL</cfif>  
                        </cfif>     
                        <cfif isdefined("arguments.detail")>
                            ,<cfif len(arguments.detail)><cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.detail#"><cfelse>NULL</cfif>
                        </cfif>  
                        <cfif isdefined("arguments.row_total")> 
                            ,<cfif len(arguments.row_total)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.row_total#"><cfelse>0</cfif>
                        </cfif>
                        <cfif isdefined("arguments.discount")>    
                            ,<cfif len(arguments.discount)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.discount#"><cfelse>0</cfif>
                        </cfif> 
                        <cfif isdefined("arguments.discount_amount")>   
                            ,<cfif len(arguments.discount_amount)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.discount_amount#"><cfelse>0</cfif>
                        </cfif>  
                        <cfif isdefined("arguments.row_net_total")>  
                            ,<cfif len(arguments.row_net_total)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.row_net_total#"><cfelse>0</cfif>
                        </cfif>    
                        <cfif isdefined("arguments.is_collected_inv")>
                            ,<cfif isDefined("arguments.is_collected_inv") and arguments.is_collected_inv eq 1>1<cfelse>0</cfif>
                        </cfif>    
                        <cfif isdefined("arguments.is_group_inv")>
                            ,<cfif isDefined("arguments.is_group_inv") and arguments.is_group_inv eq 1>1<cfelse>0</cfif>
                        </cfif>  
                        <cfif isDefined("arguments.is_billed")>  
                            ,<cfif isDefined("arguments.is_billed") and arguments.is_billed eq 1>1<cfelse>0</cfif>
                        </cfif>
                        <cfif isDefined("arguments.is_collected_prov")>
                            ,<cfif isDefined("arguments.is_collected_prov") and arguments.is_collected_prov eq 1>1<cfelse>0</cfif>
                        </cfif>  
                        <cfif isDefined("arguments.is_paid")>    
                            ,<cfif isDefined("arguments.is_paid")  and arguments.is_paid eq 1>1<cfelse>0</cfif>
                        </cfif> 
                        <cfif isdefined("arguments.invoice_id")>   
                            ,<cfif isdefined("arguments.invoice_id") and len(arguments.invoice_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.invoice_id#"><cfelse>NULL</cfif>
                        </cfif>    
                        <cfif isdefined("arguments.period_id")>
                            ,<cfif isdefined("arguments.period_id") and len(arguments.period_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.period_id#"><cfelse>NULL</cfif>
                        </cfif>    
                        <cfif isDefined("arguments.card_paymethod_id")>
                            ,<cfif isDefined("arguments.card_paymethod_id") and len(arguments.card_paymethod_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.card_paymethod_id#"><cfelse>NULL</cfif>
                        </cfif>
                        <cfif isdefined('arguments.subs_ref_id') and isdefined('arguments.subs_ref_name')>
                            ,<cfif isdefined('arguments.subs_ref_id') and len(arguments.subs_ref_id) and isdefined('arguments.subs_ref_name') and len(arguments.subs_ref_name)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subs_ref_id#"><cfelse>NULL</cfif>
                        </cfif>
                        <cfif isdefined('arguments.service_id') and isdefined('arguments.service_no')>
                            ,<cfif isdefined('arguments.service_id') and len(arguments.service_id) and isdefined('arguments.service_no') and len(arguments.service_no)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.service_id#"><cfelse>NULL</cfif>
                        </cfif>
                        <cfif isdefined('arguments.camp_id') and isdefined('arguments.camp_name')>
                            ,<cfif isdefined('arguments.camp_id') and len(arguments.camp_id) and isdefined('arguments.camp_name') and len(arguments.camp_name)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.camp_id#"><cfelse>NULL</cfif>
                        </cfif>
                        <cfif isdefined('arguments.call_id') and  isdefined('arguments.call_no')>
                            ,<cfif isdefined('arguments.call_id') and len(arguments.call_id) and isdefined('arguments.call_no') and len(arguments.call_no)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.call_id#"><cfelse>NULL</cfif>
                        </cfif>
                        <cfif isdefined('arguments.cari_action_id')>
                            ,<cfif isdefined('arguments.cari_action_id') and len(arguments.cari_action_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.cari_action_id#"><cfelse>NULL</cfif>
                        </cfif>   
                        <cfif isdefined('arguments.cari_period_id')> 
                            ,<cfif isdefined('arguments.cari_period_id') and len(arguments.cari_period_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.cari_period_id#"><cfelse>NULL</cfif>
                        </cfif>
                        <cfif isdefined('arguments.cari_act_type')>
                            ,<cfif isdefined('arguments.cari_act_type') and len(arguments.cari_act_type)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.cari_act_type#"><cfelse>NULL</cfif>
                        </cfif>
                        <cfif isdefined('arguments.cari_act_id')>
                            ,<cfif isdefined('arguments.cari_act_id') and len(arguments.cari_act_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.cari_act_id#"><cfelse>NULL</cfif>
                        </cfif>
                        <cfif isdefined('arguments.cari_act_table')>
                            ,<cfif isdefined('arguments.cari_act_table') and len(arguments.cari_act_table)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.cari_act_table#"><cfelse>NULL</cfif>
                        </cfif>
                        <cfif isDefined("arguments.is_active")>
                            ,<cfif isDefined("arguments.is_active")>1<cfelse>0</cfif>
                        </cfif> 
                        <cfif isDefined("arguments.row_rate")>    
                            ,<cfif len(arguments.row_rate)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.row_rate#"><cfelse>NULL</cfif>
                        </cfif>   
                        <cfif isDefined("cgi.remote_addr")>
                            ,<cfqueryparam cfsqltype="cf_sql_nvarchar" value="#cgi.remote_addr#">
                        <cfelse>
                            ,NULL   
                        </cfif>
                        <cfif isDefined('session.pp.userid')>
                            ,<cfqueryparam cfsqltype="cf_sql_integer" value="#session.pp.userid#">   
                        <cfelseif isDefined('session.ep.userid')> 
                            ,<cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#">  
                        <cfelseif isDefined('session.ww.userid')> 
                            ,<cfqueryparam cfsqltype="cf_sql_integer" value="#session.ww.userid#"> 
                        <cfelse>
                            ,NULL
                        </cfif> 
                        ,<cfif len(arguments.HISTORY_ACTION_TYPE)><cfqueryparam cfsqltype="cf_sql_integer" value="1"><cfelse>NULL</cfif>
                    )
            </cfquery>  
    </cffunction>
  
    <cffunction name="GET_PAYM_PLAN_HISTORY" returntype="query">
        <cfargument name ="subscription_id" default="">
        <cfargument name ="history_record" default="">
        <cfquery name="GET_PAYM_PLAN_HISTORY" datasource="#dsn3#" maxrows="#arguments.history_record#">
            SELECT TOP #history_record# SUBS_PAYMPLAN_ROW_HISTORY_ID,PAYM_PLAN_YEAR,PAYM_PLAN_MONEY_TYPE 
            FROM SUBSCRIPTION_PAYMENT_PLAN_ROW_HISTORY WHERE SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_id#">  
            ORDER BY SUBS_PAYMPLAN_ROW_HISTORY_ID DESC
        </cfquery>
        <cfreturn GET_PAYM_PLAN_HISTORY>
    </cffunction>

    <cffunction name="GET_LAST_PAYPLAN" returntype="query">
        <cfargument name="subscription_id" default="">
        <cfargument name="PAYM_PLAN_YEAR" default="">
        <cfargument name="PAYM_PLAN_MONEY_TYPE" default="">
        <cfquery name="GET_LAST_PAYPLAN" datasource="#dsn3#">
            SELECT
                SUM(ROW_NET_TOTAL) LAST_TOTAL
            FROM
                SUBSCRIPTION_PAYMENT_PLAN_ROW
            WHERE
                SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_id#"> AND
                <cfif len(arguments.PAYM_PLAN_YEAR)>
                    YEAR(PAYMENT_DATE) = #arguments.PAYM_PLAN_YEAR# AND
                </cfif>
                MONEY_TYPE = <cfif isDefined("arguments.PAYM_PLAN_MONEY_TYPE")><cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.PAYM_PLAN_MONEY_TYPE#"><cfelse> NULL </cfif>
            GROUP BY
                YEAR(PAYMENT_DATE),
                MONEY_TYPE
            ORDER BY
                YEAR(PAYMENT_DATE)
        </cfquery>
        <cfreturn GET_LAST_PAYPLAN>
    </cffunction>

    <cffunction name="UPD_PAYM_PLAN" returntype="any">
        <cfargument name="LAST_TOTAL" required="yes" default="">
        <cfargument name="SUBS_PAYMPLAN_ROW_HISTORY_ID" required="yes" default="">
        <cfquery name="UPD_PAYM_PLAN" datasource="#dsn3#">
            UPDATE
                SUBSCRIPTION_PAYMENT_PLAN_ROW_HISTORY
            SET
                PAYM_PLAN_TOTAL_LAST = <cfqueryparam cfsqltype="cf_sql_float" value="#arguments.LAST_TOTAL#">
            WHERE
                SUBS_PAYMPLAN_ROW_HISTORY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.SUBS_PAYMPLAN_ROW_HISTORY_ID#">
        </cfquery>
    </cffunction>

    <cffunction name="INSERT_PAYM_PLAN_HISTORY2" returntype="any">
        <cfargument name="subscription_id" required="yes" default="">
        <cfquery name="INSERT_PAYM_PLAN_HISTORY" datasource="#dsn3#">
            INSERT INTO
                SUBSCRIPTION_PAYMENT_PLAN_ROW_HISTORY
            (
                SUBSCRIPTION_ID,
                PAYM_PLAN_YEAR,
                PAYM_PLAN_TOTAL_LAST,
                PAYM_PLAN_MONEY_TYPE,
                CAMPAIGN_ID,
                RECORD_EMP,
                RECORD_IP,
                RECORD_DATE
            )
                SELECT	
                    SUBSCRIPTION_ID,
                    YEAR(PAYMENT_DATE),
                    SUM(ROW_NET_TOTAL),
                    MONEY_TYPE,
                    CAMPAIGN_ID,
                    <cfif isDefined('session.pp.userid')>
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#session.pp.userid#">   
                    <cfelseif isDefined('session.ep.userid')> 
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#">  
                    <cfelseif isDefined('session.ww.userid')> 
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ww.userid#"> 
                    </cfif> ,
                    <cfqueryparam cfsqltype="cf_sql_nvarchar" value="#cgi.remote_addr#">,
                    <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
                FROM
                    SUBSCRIPTION_PAYMENT_PLAN_ROW
                WHERE
                    SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_id#"> AND
                    (
                        (
                            MONEY_TYPE NOT IN 
                            (
                                SELECT
                                    PAYM_PLAN_MONEY_TYPE
                                FROM
                                    SUBSCRIPTION_PAYMENT_PLAN_ROW_HISTORY
                                WHERE
                                    SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_id#">
                            )
                        )
                        OR 
                        (
                            YEAR(PAYMENT_DATE) NOT IN 
                            (
                                SELECT
                                    PAYM_PLAN_YEAR
                                FROM
                                    SUBSCRIPTION_PAYMENT_PLAN_ROW_HISTORY
                                WHERE
                                    SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_id#">
                            )
                        )
                    )
            GROUP BY
                SUBSCRIPTION_ID,
                YEAR(PAYMENT_DATE),
                MONEY_TYPE,
                CAMPAIGN_ID
        </cfquery>
    </cffunction>

<!--- --->

<!--- payment history page --->
    <cffunction name="GET_SUBS_PAYPLAN_HISTORY" returntype="query">
        <cfargument name="subscription_id" default="">
        <cfquery name="GET_SUBS_PAYPLAN_HISTORY" datasource="#dsn3#">
            SELECT
                *
            FROM
                SUBSCRIPTION_PAYMENT_PLAN_ROW_HISTORY
            WHERE
                SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_id#">
            <cfif isDefined("arguments.show_difference")>
                AND 
                (
                    (PAYM_PLAN_TOTAL_LAST - PAYM_PLAN_TOTAL_OLD) <> 0 OR
                    PAYM_PLAN_TOTAL_LAST IS NULL OR
                    PAYM_PLAN_TOTAL_OLD IS NULL
                )
            </cfif>
            ORDER BY
                RECORD_DATE DESC
        </cfquery>
        <cfreturn GET_SUBS_PAYPLAN_HISTORY>
    </cffunction> 

  
    <cffunction name="GET_SUBS_PAYPLAN_ROW_HISTORY_DETAIL" returntype="query">
        <cfargument name="subscription_id" default="">
        <cfargument name="startdate" default="">
        <cfquery name="GET_SUBS_PAYPLAN_ROW_HISTORY_DETAIL" datasource="#dsn3#">
            select
                (SELECT PAYMETHOD FROM #DSN#.SETUP_PAYMETHOD WHERE PAYMETHOD_ID =  SP.PAYMETHOD_ID) AS PAYMETHOD
                , SP.*
            from 
                SUBSCRIPTION_PAYMENT_PLAN_ROW_HISTORY_DETAIL SP
            where
            <cfif isdefined("arguments.list_detail")>   
                SP.SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_id#">
                <cfif len(arguments.startdate) and isdate(arguments.startdate)>
                    AND  SP.PAYMENT_DATE = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.startdate#">
                </cfif>    
            </cfif>    
            ORDER BY
                HISTORY_ACTION_DATE DESC,
                 HISTORY_ACTION_TYPE DESC
        </cfquery>
        <cfreturn GET_SUBS_PAYPLAN_ROW_HISTORY_DETAIL>
    </cffunction>

    <cffunction name="GET_SUBS_INFO" returntype="query">
        <cfargument name="subscription_id" default="">
        <cfquery name="GET_SUBS_INFO" datasource="#dsn3#">
            SELECT SUBSCRIPTION_NO FROM SUBSCRIPTION_CONTRACT WHERE SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_id#">
        </cfquery>
        <cfreturn GET_SUBS_INFO>
    </cffunction>

    <cffunction name="get_emp_detail" returntype="query">
        <cfargument name="emp_id_list" default="">
        <cfquery name="get_emp_detail" datasource="#dsn#">
            SELECT EMPLOYEE_NAME,EMPLOYEE_SURNAME FROM EMPLOYEES WHERE EMPLOYEE_ID IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.emp_id_list#" list = "yes">) ORDER BY EMPLOYEE_ID
        </cfquery>
        <cfreturn get_emp_detail>
    </cffunction> 

    <cffunction name="get_camp_detail">
        <cfquery name="get_camp_detail" datasource="#dsn3#">
            SELECT CAMP_ID,CAMP_HEAD FROM CAMPAIGNS WHERE CAMP_ID IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#camp_id_list#" list="yes">) ORDER BY CAMP_ID
        </cfquery>
        <cfreturn get_camp_detail>
    </cffunction>

    <cffunction name="get_pay_detail" returntype="query">
        <cfargument name="pay_id_list" default="">
        <cfquery name="get_pay_detail" datasource="#dsn#">
          SELECT PAYMETHOD FROM SETUP_PAYMETHOD WHERE PAYMETHOD_ID IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pay_id_list#" list = "yes">) ORDER BY PAYMETHOD_ID
        </cfquery>
        <cfreturn get_pay_detail>
    </cffunction>

  
<!--- --->
    <cffunction name="GET_PAYMENT_ROWS_DISPLAY" returntype="query">
        <cfargument name="subscription_id" default="">
        <cfquery name="GET_PAYMENT_ROWS" datasource="#dsn3#">
            SELECT 
                SUBSCRIPTION_PAYMENT_ROW_ID,
                DETAIL,
                YEAR(PAYMENT_DATE) PAYMENT_YEAR
            FROM 
                SUBSCRIPTION_PAYMENT_PLAN_ROW 
            WHERE 
                SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_id#">
            ORDER BY 
                PAYMENT_DATE
        </cfquery>
        <cfreturn GET_PAYMENT_ROWS>
    </cffunction>
    <!--- ödeme planı silme sayfası--->
    <cffunction name="DEL_PAY_PLAN_ROW" returntype="any">
        <cfargument name="start_date" default="">
        <cfargument name="xml_del_ref_rows" default="">
        <cfargument name="xml_del_camp_rows" default="">
        <cfargument name="subscription_id" default="">  
        <cfquery name="DEL_PAY_PLAN_ROW" datasource="#dsn3#">
            DELETE FROM
                SUBSCRIPTION_PAYMENT_PLAN_ROW
            WHERE
                IS_PAID = 0 AND
                IS_COLLECTED_PROVISION = 0 AND
                IS_BILLED = 0 AND
                PAYMENT_DATE >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.start_date#"> AND
                <cfif isdefined("arguments.xml_del_ref_rows") and arguments.xml_del_ref_rows eq 1>
                    SUBS_REFERENCE_ID IS NULL AND
                </cfif>
                <cfif isdefined("arguments.xml_del_camp_rows") and arguments.xml_del_camp_rows eq 1>
                    CAMPAIGN_ID IS NULL AND
                </cfif>
                SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_id#">
        </cfquery>
    </cffunction>

    <cffunction name="control_row" returntype="query">
        <cfargument name="payment_row_id" default="">
        <cfquery name="control_row" datasource="#dsn3#">
            SELECT 
              IS_PAID,
              IS_COLLECTED_PROVISION,
              IS_BILLED 
            FROM 
              SUBSCRIPTION_PAYMENT_PLAN_ROW 
            WHERE 
              SUBSCRIPTION_PAYMENT_ROW_ID IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.payment_row_id#" list="yes">)
        </cfquery>
        <cfreturn control_row>
    </cffunction>


     <cffunction name="DEL_PAY_PLAN_ROW2" returntype="any">
        <cfargument name="HISTORY_ACTION_TYPE" default="0">
        <cfargument name="payment_row_id" default="">
        <cfquery name="SUBSCRIPTION_PAYMENT_PLAN_ROW_HISTORY_DETAIL" datasource="#dsn3#">
            INSERT INTO
                SUBSCRIPTION_PAYMENT_PLAN_ROW_HISTORY_DETAIL 
                (
                    SUBSCRIPTION_PAYMENT_ROW_ID
                    ,HISTORY_ACTION_DATE
                    ,SUBSCRIPTION_ID
                    ,PRODUCT_ID
                    ,STOCK_ID
                    ,PAYMENT_DATE
                    ,PAYMENT_FINISH_DATE
                    ,DETAIL
                    ,UNIT  
                    ,UNIT_ID  
                    ,QUANTITY
                    ,AMOUNT
                    ,MONEY_TYPE
                    ,ROW_TOTAL 
                    ,DISCOUNT  
                    ,DISCOUNT_AMOUNT
                    ,ROW_NET_TOTAL 
                    ,IS_COLLECTED_INVOICE
                    ,IS_GROUP_INVOICE
                    ,IS_BILLED
                    ,IS_COLLECTED_PROVISION
                    ,IS_PAID
                    ,INVOICE_ID
                    ,PERIOD_ID   
                    ,PAYMETHOD_ID 
                    ,CARD_PAYMETHOD_ID
                    ,SUBS_REFERENCE_ID 
                    ,SERVICE_ID
                    ,CAMPAIGN_ID
                    ,CALL_ID
                    ,CARI_ACTION_ID
                    ,CARI_PERIOD_ID 
                    ,CARI_ACT_TYPE
                    ,CARI_ACT_ID
                    ,CARI_ACT_TABLE 
                    ,IS_ACTIVE 
                    ,RECORD_IP
                    ,HISTORY_ACTION_EMP   
                    ,RATE
                    ,HISTORY_ACTION_TYPE  
                    <cfif isdefined("arguments.bill_info") and len(arguments.bill_info)>,IS_INVOICE_IPTAL</cfif>     
                )
            SELECT  
                    SUBSCRIPTION_PAYMENT_ROW_ID
                    ,RECORD_DATE
                    ,SUBSCRIPTION_ID
                    ,PRODUCT_ID
                    ,STOCK_ID
                    ,PAYMENT_DATE
                    ,PAYMENT_FINISH_DATE
                    ,DETAIL
                    ,UNIT  
                    ,UNIT_ID  
                    ,QUANTITY
                    ,AMOUNT
                    ,MONEY_TYPE
                    ,ROW_TOTAL 
                    ,DISCOUNT  
                    ,DISCOUNT_AMOUNT
                    ,ROW_NET_TOTAL 
                    ,IS_COLLECTED_INVOICE
                    ,IS_GROUP_INVOICE
                    ,IS_BILLED
                    ,IS_COLLECTED_PROVISION
                    ,IS_PAID
                    ,INVOICE_ID
                    ,PERIOD_ID   
                    ,PAYMETHOD_ID 
                    ,CARD_PAYMETHOD_ID
                    ,SUBS_REFERENCE_ID 
                    ,SERVICE_ID
                    ,CAMPAIGN_ID
                    ,CALL_ID
                    ,CARI_ACTION_ID
                    ,CARI_PERIOD_ID 
                    ,CARI_ACT_TYPE
                    ,CARI_ACT_ID
                    ,CARI_ACT_TABLE 
                    ,IS_ACTIVE 
                    ,RECORD_IP
                    ,<cfif isDefined('session.pp.userid')>
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#session.pp.userid#">   
                    <cfelseif isDefined('session.ep.userid')> 
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#">  
                    <cfelseif isDefined('session.ww.userid')> 
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ww.userid#"> 
                    </cfif> 
                    ,RATE
                    ,#HISTORY_ACTION_TYPE#
                    <cfif isdefined("arguments.bill_info") and len(arguments.bill_info)>,IS_INVOICE_IPTAL</cfif>       
                FROM
                    SUBSCRIPTION_PAYMENT_PLAN_ROW
                WHERE
                    SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_id#">
                    AND SUBSCRIPTION_PAYMENT_ROW_ID IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.payment_row_id#" list="yes">)

        </cfquery> 
        <cfquery name="DEL_PAY_PLAN_ROW" datasource="#dsn3#">
            DELETE FROM 
                SUBSCRIPTION_PAYMENT_PLAN_ROW
            WHERE 
                SUBSCRIPTION_PAYMENT_ROW_ID IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.payment_row_id#" list="yes">)
        </cfquery>
    </cffunction>
    <!--- --->
    <!---Abone Ürün Planı get_basket_46.cfm--->
    <cffunction name="GET_SUBSCRIPTION_ROW" access="remote" returntype="query">
        <cfargument name="subscription_id" default="">
        <cfargument name="service_id" default="">
        <cfargument name="service_operation_id" default="">
        <cfquery name="GET_SUBSCRIPTION_ROW" datasource="#DSN3#">
            SELECT
            *
            FROM
            (
                SELECT
                    SCR.SUBSCRIPTION_ROW_ID,
                    SCR.AMOUNT,
                    SCR.PRICE,
                    #dsn#.Get_Dynamic_Language(SCR.UNIT_ID,'<cfif isDefined('session.ep.userid')>#session.ep.language#<cfelseif isDefined('session.pp.userid')>#session.pp.language# <cfelseif isDefined('session.pda.userid')>#session.pda.language#</cfif>','SUBSCRIPTION_CONTRACT_ROW','UNIT',NULL,NULL,SCR.UNIT) AS UNIT,
                    SCR.UNIT_ID,
                    SCR.PRODUCT_ID,
                    SCR.STOCK_ID,
                    SCR.OTHER_MONEY AS CURRENCY,
                    SCR.ROW_ORDER_ID,
                    SCR.BASKET_EXTRA_INFO_ID,
                    SCR.SELECT_INFO_EXTRA,
                    SCR.DETAIL_INFO_EXTRA,
                    '' AS WRK_ROW_ID,
                    #dsn#.Get_Dynamic_Language(SCR.SUBSCRIPTION_ROW_ID,'<cfif isDefined('session.ep.userid')>#session.ep.language#<cfelseif isDefined('session.pp.userid')>#session.pp.language# <cfelseif isDefined('session.pda.userid')>#session.pda.language#</cfif>','SUBSCRIPTION_CONTRACT_ROW','PRODUCT_NAME',NULL,NULL,SCR.PRODUCT_NAME) AS PRODUCT_NAME,
                    SCR.PRODUCT_NAME2 AS PRODUCT_NAME2,
                    SCR.DISCOUNT1 AS DISCOUNT1,
                    SCR.DISCOUNT2 AS DISCOUNT2,
                    SCR.DISCOUNT3 AS DISCOUNT3,
                    SCR.DISCOUNT4 AS DISCOUNT4,
                    SCR.DISCOUNT5 AS DISCOUNT5,
                    SCR.DISCOUNT6 AS DISCOUNT6,
                    SCR.DISCOUNT7 AS DISCOUNT7,
                    SCR.DISCOUNT8 AS DISCOUNT8,
                    SCR.DISCOUNT9 AS DISCOUNT9,
                    SCR.DISCOUNT10 AS DISCOUNT10,
                    SCR.DISCOUNT_COST AS DISCOUNT_COST,
                    SCR.TAX AS TAX,
                    SCR.OTV_ORAN AS OTV_ORAN,
                    SCR.PAYMETHOD_ID AS PAYMETHOD_ID,
                    SCR.EXTRA_COST AS EXTRA_COST,
                    '' AS NETTOTAL,
                    SCR.DISCOUNTTOTAL AS DISCOUNTTOTAL,
                    SCR.TAXTOTAL AS TAXTOTAL,
                    SCR.OTVTOTAL AS OTVTOTAL,
                    SCR.OTHER_MONEY AS OTHER_MONEY,
                    SCR.OTHER_MONEY_VALUE AS OTHER_MONEY_VALUE,
                    SCR.OTHER_MONEY_GROSS_TOTAL AS OTHER_MONEY_GROSS_TOTAL,
                    SCR.DELIVER_DATE AS DELIVER_DATE,
                    SCR.SPECT_VAR_ID AS SPECT_VAR_ID,
                    SCR.SPECT_VAR_NAME AS SPECT_VAR_NAME,
                    SCR.LOT_NO AS LOT_NO,
                    SCR.PRICE_OTHER AS PRICE_OTHER,
                    SCR.BSMV_RATE,
                    SCR.BSMV_AMOUNT,
                    SCR.BSMV_CURRENCY,
                    SCR.OIV_RATE,
                    SCR.OIV_AMOUNT,
                    SCR.TEVKIFAT_RATE,
                    SCR.TEVKIFAT_AMOUNT,
                    S.IS_INVENTORY,
                    S.IS_PRODUCTION,
                    S.STOCK_CODE,
                    S.BARCOD,
                    S.IS_SERIAL_NO,
                    S.MANUFACT_CODE,
                    S.STOCK_CODE_2,
                    SCR.BASKET_EMPLOYEE_ID,
                    SCR.LIST_PRICE,
                    SCR.NETTOTAL AS NET_AMOUNT,
                    SCR.GROSSTOTAL
                FROM 
                    SUBSCRIPTION_CONTRACT_ROW SCR,
                    #dsn3_alias#.STOCKS S
                WHERE 
                    SCR.SUBSCRIPTION_ID = #arguments.subscription_id# AND
                    SCR.STOCK_ID = S.STOCK_ID
                <cfif isdefined('arguments.service_id') and len(arguments.service_id) and isdefined('arguments.service_operation_id') and len(arguments.service_operation_id)>
                UNION ALL
                    SELECT 
                        '' SUBSCRIPTION_ROW_ID,
                        SO.AMOUNT,
                        ISNULL(SO.PRICE,0) PRICE,
                        SO.UNIT,
                        SO.UNIT_ID,
                        SO.PRODUCT_ID,
                        SO.STOCK_ID,
                        SO.CURRENCY AS CURRENCY,
                        '' AS ROW_ORDER_ID,
                        '' AS BASKET_EXTRA_INFO_ID,
                        '' SELECT_INFO_EXTRA,
                        '' DETAIL_INFO_EXTRA,
                        SO.WRK_ROW_ID,
                        SO.PRODUCT_NAME AS PRODUCT_NAME,
                        '' AS PRODUCT_NAME2,
                        0 AS DISCOUNT1,
                        0 AS DISCOUNT2,
                        0 AS DISCOUNT3,
                        0 AS DISCOUNT4,
                        0 AS DISCOUNT5,
                        0 AS DISCOUNT6,
                        0 AS DISCOUNT7,
                        0 AS DISCOUNT8,
                        0 AS DISCOUNT9,
                        0 AS DISCOUNT10,
                        0 AS DISCOUNT_COST,
                        STOCKS.TAX AS TAX,
                        0 AS OTV_ORAN,
                        '' AS PAYMETHOD_ID,
                        0 AS EXTRA_COST,
                        '' AS NETTOTAL,
                        '' AS DISCOUNTTOTAL,
                        '' AS TAXTOTAL,
                        '' AS OTVTOTAL,
                        SO.CURRENCY AS OTHER_MONEY,
                        ISNULL(SO.PRICE,0) AS OTHER_MONEY_VALUE,
                        SO.TOTAL_PRICE AS OTHER_MONEY_GROSS_TOTAL,
                        '' AS DELIVER_DATE,
                        '' AS SPECT_VAR_ID,
                        '' AS SPECT_VAR_NAME,
                        '' AS LOT_NO,
                        SO.PRICE AS PRICE_OTHER,
                        STOCKS.IS_INVENTORY,
                        STOCKS.IS_PRODUCTION,
                        STOCKS.STOCK_CODE,
                        STOCKS.BARCOD,
                        STOCKS.IS_SERIAL_NO,
                        STOCKS.MANUFACT_CODE,
                        STOCKS.STOCK_CODE_2,
                        '' BASKET_EMPLOYEE_ID,
                        0 LIST_PRICE
                    FROM 
                        SERVICE_OPERATION SO,
                        #dsn3_alias#.STOCKS AS STOCKS
                    WHERE
                        SO.SERVICE_ID = #arguments.service_id# AND
                        SO.SERVICE_OPE_ID IN (#arguments.service_operation_id#) AND
                        SO.STOCK_ID = STOCKS.STOCK_ID AND
                        SO.STOCK_ID IS NOT NULL
                </cfif>
            )T1
            ORDER BY
                SUBSCRIPTION_ROW_ID
        </cfquery>
        <cfreturn GET_SUBSCRIPTION_ROW>
    </cffunction>

    <cffunction name="get_subscription_counter" returntype="query" access="public">
        <cfargument name="subscription_id" type="numeric">
        <cfargument name="our_cmp_id" type="numeric">
        <cfset new_dsn2 = (isdefined("arguments.our_cmp_id") and len(arguments.our_cmp_id))?'#dsn#_#session_base.period_year#_#arguments.our_cmp_id#':dsn2>
        <cfquery name="get_subscription_counter_query" datasource="#new_dsn2#">
            SELECT 
                P.PRODUCT_NAME,
                PU.MAIN_UNIT,
                SUM(ISNULL(IR.AMOUNT,0) - ISNULL(SCM.DIFFERENCE,0)) AS TOTAL_COUNT
            FROM #dsn3#.SUBSCRIPTION_COUNTER AS SC
            JOIN #dsn#_product.PRODUCT AS P ON SC.PRODUCT_ID = P.PRODUCT_ID
            JOIN #dsn#_product.PRODUCT_UNIT AS PU ON P.PRODUCT_ID = PU.PRODUCT_ID
            LEFT JOIN #dsn3#.[SUBSCRIPTION_COUNTER_METER] AS SCM ON SC.COUNTER_ID = SCM.COUNTER_ID
            LEFT JOIN INVOICE_ROW AS IR ON SC.PRODUCT_ID = IR.PRODUCT_ID
            LEFT JOIN INVOICE AS I ON IR.INVOICE_ID = I.INVOICE_ID
            WHERE 
                (I.PURCHASE_SALES IS NULL OR I.PURCHASE_SALES = 1)
                AND I.SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_id#">
                AND SC.SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_id#">
            GROUP BY 
                P.PRODUCT_NAME,
                PU.MAIN_UNIT
        </cfquery>

        <cfreturn get_subscription_counter_query />

    </cffunction>

    <cffunction name="get_extre" returntype="query" access="public">
        <cfargument name="subscription_id" type="numeric" default="">
        <cfargument name="our_cmp_id" type="numeric">
        <cfset new_dsn2 = (isdefined("arguments.our_cmp_id") and len(arguments.our_cmp_id))?'#dsn#_#session_base.period_year#_#arguments.our_cmp_id#':dsn2>
        <cfquery name="get_extre_query" datasource="#new_dsn2#">
            SELECT
                CARI_RECORDS.ACTION_CURRENCY_ID,
                CARI_RECORDS.OTHER_MONEY,
                SUM(CARI_RECORDS.BORC_VALUE) AS TOTAL_BORC_VALUE,
                SUM(CARI_RECORDS.ALACAK_VALUE) AS TOTAL_ALACAK_VALUE,
                SUM(CARI_RECORDS.BORC_OTHER) AS TOTAL_BORC_OTHER,
                SUM(CARI_RECORDS.ALACAK_OTHER) AS TOTAL_ALACAK_OTHER
            FROM(
                    SELECT
                        CR.ACTION_CURRENCY_ID,
                        CR.OTHER_MONEY,
                        0 AS BORC_VALUE,
                        0 AS BORC_OTHER,
                        ISNULL(SUM(CR.ACTION_VALUE),0) AS ALACAK_VALUE,
                        ISNULL(SUM(CR.OTHER_CASH_ACT_VALUE),0) AS ALACAK_OTHER
                    FROM CARI_ROWS AS CR
                    WHERE 
                        (CR.FROM_CMP_ID IS NOT NULL OR CR.FROM_CONSUMER_ID IS NOT NULL OR CR.FROM_EMPLOYEE_ID IS NOT NULL)
                        AND CR.SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_id#">
                        AND CR.OTHER_MONEY IS NOT NULL
                        GROUP BY CR.ACTION_CURRENCY_ID, CR.OTHER_MONEY

                    UNION

                    SELECT
                        CR.ACTION_CURRENCY_ID,
                        CR.OTHER_MONEY,
                        ISNULL(SUM(CR.ACTION_VALUE),0) AS BORC_VALUE,
                        ISNULL(SUM(CR.OTHER_CASH_ACT_VALUE),0) AS BORC_OTHER,
                        0 AS ALACAK_VALUE,
                        0 AS ALACAK_OTHER
                    FROM CARI_ROWS AS CR
                    WHERE
                    (CR.TO_CMP_ID IS NOT NULL OR CR.TO_CONSUMER_ID IS NOT NULL OR CR.TO_EMPLOYEE_ID IS NOT NULL)
                    AND CR.SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_id#">
                    AND CR.OTHER_MONEY IS NOT NULL
                    GROUP BY CR.ACTION_CURRENCY_ID, CR.OTHER_MONEY
                ) AS CARI_RECORDS
            GROUP BY CARI_RECORDS.ACTION_CURRENCY_ID, CARI_RECORDS.OTHER_MONEY
        </cfquery>
        <cfreturn get_extre_query />
    </cffunction>

    <cffunction name="get_total" returntype="query" access="remote">
        <cfargument name="tax" default="">
        <cfquery name="get_total" dbtype="query">
            SELECT TAXTOTAL FROM GET_SUBSCRIPTION_ROW WHERE TAX = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tax#">
          </cfquery>
          <cfreturn get_total>
    </cffunction>

    <cffunction name="get_assetp_name" returntype="query" access="remote"> 
        <cfargument name="asset_id" default="">
        <cfquery name="GET_ASSETP_NAME" datasource="#dsn#">
            SELECT ASSETP_ID,ASSETP FROM ASSET_P WHERE ASSETP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.asset_id#">
        </cfquery>
        <cfreturn get_assetp_name>
    </cffunction>

    <cffunction name="GET_OUR_COMPANIES" returntype="query" access="remote"> 
        <cfquery name="GET_OUR_COMPANIES" datasource="#dsn#">
            SELECT 
                COMP_ID,
                COMPANY_NAME 
            FROM 
                OUR_COMPANY
            WHERE 
                COMP_STATUS = 1
            ORDER BY 
                COMPANY_NAME
        </cfquery>
        <cfreturn GET_OUR_COMPANIES>
    </cffunction>

    <cffunction name="add_payment_plan_from_counter" returntype="any" returnformat="JSON" access="remote">
        <cfargument name="row_id" required="true">
           <!---  <cftry> --->
                <cfset response = structNew()>
                <cfset c_meter = createObject("component","V16.sales.cfc.counter_meter")/>

                <cfloop from="1" to="#listlen(arguments.row_id)#" index="i">
                    <cfset get_counter_meter = c_meter.select(scm_id: i)>

                    <cfset "attributes.amount#i#" = get_counter_meter.difference>
                    <cfset "attributes.row_total#i#" = 100>
                    <cfset "attributes.discount#i#" = 0>
                    <cfset "attributes.row_bsmv_amount#i#" = 0>
                    <cfset "attributes.row_bsmv_rate#i#" = 0>
                    <cfset "attributes.row_oiv_amount#i#" = 0>
                    <cfset "attributes.row_oiv_rate#i#" = 0>
                    <cfset "attributes.row_tevkifat_rate#i#" = 0>
                    <cfset "attributes.row_tevkifat_amount#i#" = 0>
                    <cfset "attributes.discount_amount#i#" = 0>
                    <cfset "attributes.row_net_total#i#" = 100>
                    <cfset "attributes.money_type_row#i#" = 'TL'>
                    <cfset "attributes.is_collected_inv#i#" = 1>
                    <cfset "attributes.is_active#i#" = 1>
                    <cfset "attributes.paymethod_id#i#" = arguments.paymethod_id>
                    <cfset "attributes.payment_date#i#" = arguments.action_date_finish>
                    <cfset "attributes.detail#i#" = get_counter_meter.PRODUCT_NAME>
                    <cf_date tarih='attributes.payment_date#i#'>
                    <cf_date tarih='attributes.payment_finish_date#i#'>

                    <cfset  ADD_PAYMENT_PLAN_ROW = this.ADD_PAYMENT_PLAN_ROW(
                        subscription_id : get_counter_meter.subscription_id,
                        product_id : "#isdefined("get_counter_meter.product_id") and len(evaluate("get_counter_meter.product_id")) ? "#evaluate("get_counter_meter.product_id")#" : "" #",  
                        stock_id : "#isdefined("get_counter_meter.stock_id") and len(evaluate("get_counter_meter.stock_id")) ? "#evaluate("get_counter_meter.stock_id")#" : "" #",
                        payment_date : "#isdefined("attributes.payment_date#i#") and len(evaluate("attributes.payment_date#i#")) ? "#evaluate("attributes.payment_date#i#")#" : "" #", 
                        payment_finish_date : "#isdefined("attributes.payment_finish_date#i#") and len(evaluate("attributes.payment_finish_date#i#")) ? "#evaluate("attributes.payment_finish_date#i#")#" : "" #",
                        detail :"#isdefined("attributes.detail#i#") and len("attributes.detail#i#") ? "#evaluate("attributes.detail#i#")#" : "" #", 
                        unit : "#get_counter_meter.unit#",  
                        unit_id : "#isdefined(evaluate("get_counter_meter.unit_id")) and len(evaluate("get_counter_meter.unit_id")) ? "#evaluate("get_counter_meter.unit_id")#" : 0 #", 
                        quantity : "#evaluate("attributes.amount#i#")#", 
                        amount : "#isDefined("attributes.amount#i#") ? "#evaluate("attributes.amount#i#")#" : "" #",
                        money_type_row :"#evaluate("attributes.money_type_row#i#")#", 
                        row_total : "#len(evaluate("attributes.row_total#i#")) ? "#evaluate("attributes.row_total#i#")#" : 0 #",
                        discount : "#len(evaluate("attributes.discount#i#")) ? "#evaluate("attributes.discount#i#")#" : 0 #",
                        discount_amount : "#len(evaluate("attributes.discount_amount#i#")) ? "#evaluate("attributes.discount_amount#i#")#" : 0 #",
                        row_net_total : "#len(evaluate("attributes.row_net_total#i#")) ? "#evaluate("attributes.row_net_total#i#")#" : 0 #",
                        is_collected_inv : "#isDefined("attributes.is_collected_inv#i#") ? 1 : 0 #",
                        is_group_inv : "#isDefined("attributes.is_group_inv#i#") ? 1 : 0 #",
                        is_billed : "#isDefined("attributes.is_billed#i#")  or isdefined("arguments.invoice_id#i#") ? 1 : 0 #",
                        is_collected_prov : "#isDefined("attributes.is_collected_prov#i#") ? 1 : 0 #",
                        is_paid : "#isDefined("attributes.is_paid#i#") ? 1 : 0 #",
                        invoice_id : "#isdefined("attributes.invoice_id#i#") and len(evaluate("attributes.invoice_id#i#")) ? "#evaluate("attributes.invoice_id#i#")#" : "" #",
                        bill_info : "#isdefined("attributes.bill_info#i#") and len(evaluate("attributes.bill_info#i#")) ? "" : "" #",  
                        period_id : "#isdefined("attributes.period_id#i#") and len(evaluate("attributes.period_id#i#")) ? "#evaluate("attributes.period_id#i#")#" : "" #",
                        paymethod_id :"#isdefined("attributes.paymethod_id#i#") and len(evaluate("attributes.paymethod_id#i#")) ? "#evaluate("attributes.paymethod_id#i#")#" : "" #", 
                        card_paymethod_id :"#isdefined("attributes.card_paymethod_id#i#") and len(evaluate("attributes.card_paymethod_id#i#")) ? "#evaluate("attributes.card_paymethod_id#i#")#" : "" #",  
                        subs_ref_id : "#isdefined('attributes.subs_ref_id#i#') and len(evaluate("attributes.subs_ref_id#i#")) and isdefined('attributes.subs_ref_name#i#') and len(evaluate("attributes.subs_ref_name#i#")) ? "#evaluate("attributes.subs_ref_id#i#")#" : "" #",
                        service_id : "#isdefined('attributes.service_id#i#') and len(evaluate("attributes.service_id#i#")) and isdefined('attributes.service_no#i#') and len(evaluate("attributes.service_no#i#")) ? "#evaluate("attributes.service_id#i#")#" : "" #",
                        camp_id : "#isdefined('attributes.camp_id#i#') and len(evaluate("attributes.camp_id#i#")) and isdefined('attributes.camp_name#i#') and len(evaluate("attributes.camp_name#i#")) ? "#evaluate("attributes.camp_id#i#")#" : "" #",
                        call_id :  "#isdefined('attributes.call_id#i#') and len(evaluate("attributes.call_id#i#")) and isdefined('attributes.call_no#i#') and len(evaluate("attributes.call_no#i#")) ? "#evaluate("attributes.call_id#i#")#" : "" #",
                        cari_action_id : "#isdefined('attributes.cari_action_id#i#') and len(evaluate("attributes.cari_action_id#i#")) ? "#evaluate("attributes.cari_action_id#i#")#" : "" #",
                        cari_period_id : "#isdefined('attributes.cari_period_id#i#') and len(evaluate("attributes.cari_period_id#i#")) ? "#evaluate("attributes.cari_period_id#i#")#" : "" #",
                        cari_act_type :	"#isdefined('attributes.cari_act_type#i#') and len(evaluate("attributes.cari_act_type#i#")) ? "#evaluate("attributes.cari_act_type#i#")#" : "" #",
                        cari_act_id : "#isdefined('attributes.cari_act_id#i#') and len(evaluate("attributes.cari_act_id#i#")) ? "#evaluate("attributes.cari_act_id#i#")#" : "" #",
                        cari_act_table : "#isdefined('attributes.cari_act_table#i#') and len(evaluate("attributes.cari_act_table#i#")) ? "#evaluate("attributes.cari_act_table#i#")#" : "" #",
                        is_active : "#isDefined("attributes.is_active#i#") ? 1 : 0 #",
                        row_rate : "#isDefined("attributes.row_rate#i#") and len(evaluate("attributes.row_rate#i#")) ? "#evaluate("attributes.row_rate#i#")#" : "" #",
                        row_reason_code : "#isDefined("attributes.row_reason_code#i#") and len(evaluate("attributes.row_reason_code#i#")) ? "#evaluate("attributes.row_reason_code#i#")#" : "" #",			
                        row_bsmv_rate : "#isdefined('attributes.row_bsmv_rate#i#') and len(evaluate("attributes.row_bsmv_rate#i#")) ? "#evaluate('attributes.row_bsmv_rate#i#')#" : "" #", 
                        row_bsmv_amount : "#isdefined('attributes.row_bsmv_amount#i#') and len(evaluate("attributes.row_bsmv_amount#i#")) ? "#evaluate('attributes.row_bsmv_amount#i#')#" : "" #",
                        row_oiv_rate : "#isdefined('attributes.row_oiv_rate#i#') and len(evaluate("attributes.row_oiv_rate#i#")) ? "#evaluate('attributes.row_oiv_rate#i#')#" : "" #",	
                        row_oiv_amount : "#isdefined('attributes.row_oiv_amount#i#') and len(evaluate("attributes.row_oiv_amount#i#")) ? "#evaluate('attributes.row_oiv_amount#i#')#" : "" #",
                        row_tevkifat_rate : "#isdefined('attributes.row_tevkifat_rate#i#') and len(evaluate("attributes.row_tevkifat_rate#i#")) ? "#evaluate('attributes.row_tevkifat_rate#i#')#" : "" #",
                        row_tevkifat_amount : "#isdefined('attributes.row_tevkifat_amount#i#') and len(evaluate("attributes.row_tevkifat_amount#i#")) ? "#evaluate('attributes.row_tevkifat_amount#i#')#" : "" #",
                        row_is_counter: 1,
                        row_our_company_id: arguments.our_company_id,
                        scm_id: i
                    )>

                    <cfquery name="upd_scm_row" datasource="#dsn3#">
                        UPDATE SUBSCRIPTION_COUNTER_METER SET IS_PAYMENT_PLAN = 1 WHERE SCM_ID = #i#
                    </cfquery>

                </cfloop>
                <cfset response.status = 1>
                <cfset response.message = "Ödeme Planı Başarıyla Oluştu">
                    <!--- <cfcatch>
                        <cfset response.status = 0>
                        <cfset response.message = "Ödeme Planı Oluşturulurken Bir Sorun Oluştu">
                    </cfcatch>
            </cftry> --->
        <cfreturn replace(serializeJSON(response),"//","")>
    </cffunction>
</cfcomponent>