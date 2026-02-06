<cfcomponent>
    <cfscript>
        wrkFunction = createObject("component","WMO.functions");
        dsn = application.SystemParam.SystemParam().dsn;
        dsn3 = "#dsn#_#session.ep.company_id#";
        dsn_alias = dsn;
    </cfscript>
    <cffunction name="add_import" access="public" hint="Insert subscription payment plan import">
        <cftry>    
            <cfquery name = "add_import" datasource = "#dsn3#">
               INSERT INTO SUBSCRIPTION_PAYMENT_PLAN_IMPORT
                    (
                    IMPORT_TYPE_ID,
                    IMPORT_NAME,
                    IMPORT_DESCRIPTION,
                    ROW_DESCRIPTION,
                    CONVERT_SUBSCRIPTION_PAYMENT_PLAN,
                    FILE_PATH,
                    FILE_NAME,
                    PAYMENT_DATE,
                    START_DATE,
                    FINISH_DATE,
                    PAYMETHOD_ID,
                    PROCESS_STAGE,
                    RECORD_EMP,
                    RECORD_IP,
                    RECORD_DATE
                    )
                VALUES
                    (
                    <cfqueryparam value = "#arguments.IMPORT_TYPE_ID#" CFSQLType = "cf_sql_integer">,
                    <cfqueryparam value = "#arguments.import_name#" CFSQLType = "cf_sql_nvarchar">,
                    <cfif isdefined("arguments.description") and len(arguments.description)><cfqueryparam value = "#arguments.description#" CFSQLType = "cf_sql_nvarchar"><cfelse>NULL</cfif>,
                    <cfif isdefined("arguments.row_description") and len(arguments.row_description)><cfqueryparam value = "#arguments.row_description#" CFSQLType = "cf_sql_nvarchar"><cfelse>NULL</cfif>,
                    <cfqueryparam value = "0" CFSQLType = "cf_sql_bit">,
                    <cfif isdefined("arguments.file") and len(arguments.file) and isdefined("arguments.file_path") and len(arguments.file_path)><cfqueryparam value = "#arguments.file_path#" CFSQLType = "cf_sql_nvarchar"><cfelse>NULL</cfif>,
                    <cfif isdefined("arguments.file") and len(arguments.file)><cfqueryparam value = "#arguments.file#" CFSQLType = "cf_sql_nvarchar"><cfelse>NULL</cfif>,
                    <cfif isdefined("arguments.payment_date") and len(arguments.payment_date)>#arguments.payment_date#<cfelse>NULL</cfif>,
                    <cfif isdefined("arguments.start_date") and len(arguments.start_date)>#arguments.start_date#<cfelse>NULL</cfif>,
                    <cfif isdefined("arguments.finish_date") and len(arguments.finish_date)>#arguments.finish_date#<cfelse>NULL</cfif>,
                    <cfif isdefined("arguments.paymethod_id") and len(arguments.paymethod_id)><cfqueryparam value = "#arguments.paymethod_id#" CFSQLType = "cf_sql_integer"><cfelse>NULL</cfif>,
                    <cfqueryparam value = "#arguments.process_stage#" CFSQLType = "cf_sql_integer">,
                    <cfqueryparam value = "#arguments.RECORD_EMP#" cfsqltype = "cf_sql_integer">,
                    <cfqueryparam value = "#CGI.REMOTE_ADDR#" CFSQLType = "cf_sql_nvarchar">,
                    #now()#
                    )
            </cfquery>

            <cfreturn true>
            
            
            <cfcatch type="any">
            <cfreturn false>    
        </cfcatch>
        </cftry>
    </cffunction>

    <cffunction name="get_max_import_id" access="public" hint="">
        <cfquery name="GET_MAX_SUBSCRIPTION" datasource="#dsn3#">
            SELECT MAX(SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID) AS SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID FROM	SUBSCRIPTION_PAYMENT_PLAN_IMPORT WHERE RECORD_EMP = #session.ep.userid#
        </cfquery>
        <cfreturn GET_MAX_SUBSCRIPTION.SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID>
    </cffunction>

    <cffunction name="upd_import" access="public" hint="update subscription payment plan import">
        <cfargument name="SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID" required="true">
        <cfargument name="IMPORT_NAME" required="true">
        <cfargument name="PROCESS_STAGE" required="true">
        <cfargument name="UPDATE_EMP" required="true">
        <cftry>
            <cfquery name = "upd_import" datasource = "#dsn3#">
               UPDATE SUBSCRIPTION_PAYMENT_PLAN_IMPORT SET               
                    IMPORT_NAME = <cfqueryparam value = "#arguments.import_name#" CFSQLType = "cf_sql_nvarchar">,
                    IMPORT_DESCRIPTION = <cfif isdefined("arguments.description") and len(arguments.description)><cfqueryparam value = "#arguments.description#" CFSQLType = "cf_sql_nvarchar"><cfelse>NULL</cfif>,
                    PROCESS_STAGE = <cfqueryparam value = "#arguments.process_stage#" CFSQLType = "cf_sql_integer">,
                    UPDATE_EMP = <cfqueryparam value = "#arguments.UPDATE_EMP#" CFSQLType = "cf_sql_integer">,
                    UPDATE_IP =  <cfqueryparam value = "#CGI.REMOTE_ADDR#" CFSQLType = "cf_sql_nvarchar">,
                    UPDATE_DATE = #now()#
                WHERE 
                    SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID = <cfqueryparam value = "#arguments.SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID#" CFSQLType = "cf_sql_integer">
            </cfquery>
            <cfreturn true>
        <cfcatch type="any">
            <cfreturn false>    
        </cfcatch>
        </cftry>
    </cffunction>
    
    <cffunction name="get_byID" access = "public" hint = "Get one record">
        <cfargument name="SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID" required="true" type="integer" default="0">
        <cfquery name="GET_IMPORT" datasource = "#dsn3#">
            SELECT 
                SPPI.*,
                (
                    SELECT COUNT(R.SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID) AS ROW_COUNT 
                    FROM SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ROW AS R  
                    WHERE R.SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID = SPPI.SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID 
                ) AS IMPORT_ROW_COUNT
            FROM SUBSCRIPTION_PAYMENT_PLAN_IMPORT AS SPPI
            WHERE SPPI.SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID = <cfqueryparam value = "#arguments.SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID#" cfsqltype = "cf_sql_integer">
        </cfquery>
        <cfreturn GET_IMPORT>
    </cffunction>

    <cffunction name="get_import_summary" access = "public" hint = "Select">
        <cfargument name="SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID" required="true" type="integer" default="0">
        <cfquery name="get_import_sum" datasource="#dsn3#">
            SELECT
                count(SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID) AS ROW_COUNT,
                SUM(row_total) AS TOTAL,
                SUM(row_net_total) AS NET_TOTAL,
                SUM(bsmv_amount) AS BSMV_TOTAL,
                SUM(OIV_AMOUNT) AS OIV_TOTAL,
                (SELECT count(SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID) FROM SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ROW WHERE SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID = <cfqueryparam value = "#arguments.SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID#" CFSQLType = "cf_sql_integer"> AND ROW_RESULT=0) AS ERROR_COUNT,
                COUNT(DISTINCT SUBSCRIPTION_ID) UNIQUE_SUBSCRIPTION_COUNT,
                COUNT(DISTINCT PRODUCT_ID) UNIQUE_PRODUCT_COUNT,
                MONEY_TYPE
            FROM SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ROW            
            WHERE 
                SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID = <cfqueryparam value = "#arguments.SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID#" CFSQLType = "cf_sql_integer">          
                AND ROW_RESULT=1
            GROUP BY 
                MONEY_TYPE
        </cfquery>
        <cfreturn get_import_sum>
    </cffunction>

    <cffunction name="get_import" access = "public" hint = "Select">
        <cfargument name="sort_type">
        <cfargument name="startrow">
        <cfargument name="maxrows" default="20">
        <cfset gsa = createObject("component","V16.objects.cfc.subscriptionNauthority")/>
        <cfset GET_SUBSCRIPTION_AUTHORITY= gsa.SelectAuthority()/>
        <cfquery name="GET_IMPORT_LIST" datasource = "#dsn3#">
        WITH CTE1 AS(
            SELECT
                SPPI.SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID,
                SPPI.IMPORT_TYPE_ID,
                S.IMPORT_TYPE_NAME,
                SPPI.IMPORT_NAME,
                SPPI.PROCESS_STAGE,
                SPPI.PAYMENT_DATE,
                SPPI.RECORD_EMP,
                SPPI.RECORD_DATE,
                SPPI.UPDATE_EMP,
                SPPI.CONVERT_SUBSCRIPTION_PAYMENT_PLAN,
				COUNT(SR.SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID) AS ERROR_ROW_COUNT
            FROM 
                SUBSCRIPTION_PAYMENT_PLAN_IMPORT AS SPPI
                INNER JOIN SETUP_PAYMENT_PLAN_IMPORT_TYPE AS S ON S.IMPORT_TYPE_ID = SPPI.IMPORT_TYPE_ID
                LEFT JOIN SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ROW AS SR ON SR.SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID = SPPI.SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID AND SR.ROW_RESULT = 0
            WHERE
                1=1
                <cfif isdefined("arguments.PROCESS_STAGE") and len(arguments.PROCESS_STAGE)>
                    AND SPPI.PROCESS_STAGE = <cfqueryparam value = "#arguments.PROCESS_STAGE#" CFSQLType = "cf_sql_integer">
                </cfif>
                <cfif isdefined("arguments.keyword") and len(arguments.keyword)>
                    AND SPPI.IMPORT_NAME Like <cfqueryparam value = "%#arguments.keyword#%" CFSQLType = "cf_sql_nvarchar">
                </cfif>
                <cfif isdefined("arguments.start_date") and len(arguments.start_date)>
                    AND SPPI.PAYMENT_DATE >= <cfqueryparam value = "#arguments.start_date#" CFSQLType = "cf_sql_timestamp">
                </cfif>
                <cfif isdefined("arguments.finish_date") and len(arguments.finish_date)>
                    AND SPPI.PAYMENT_DATE <= <cfqueryparam value = "#arguments.finish_date#" CFSQLType = "cf_sql_timestamp">
                </cfif>
                <cfif isdefined("arguments.import_type_id") and len(arguments.import_type_id)>
                    AND SPPI.IMPORT_TYPE_ID IN (<cfqueryparam value = "#arguments.import_type_id#" CFSQLType = "cf_sql_integer" list="yes" >)
                </cfif>
                <cfif isdefined("arguments.convert_subscription_payment_plan") and len(arguments.convert_subscription_payment_plan)>
                    AND SPPI.CONVERT_SUBSCRIPTION_PAYMENT_PLAN = <cfqueryparam value = "#arguments.convert_subscription_payment_plan#" CFSQLType = "cf_sql_bit">
                </cfif>
                <cfif get_subscription_authority.IS_SUBSCRIPTION_AUTHORITY eq 1 and session.ep.ADMIN eq 0>
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
                                AND S.SUBSCRIPTION_TYPE_ID = spc.SUBSCRIPTION_TYPE_ID
                		)
                </cfif>
                GROUP BY
                    SPPI.SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID,
                    SPPI.IMPORT_TYPE_ID,
                    S.IMPORT_TYPE_NAME,
                    SPPI.IMPORT_NAME,
                    SPPI.PROCESS_STAGE,
                    SPPI.PAYMENT_DATE,
                    SPPI.RECORD_EMP,
                    SPPI.RECORD_DATE,
                    SPPI.UPDATE_EMP,
                    SPPI.CONVERT_SUBSCRIPTION_PAYMENT_PLAN
            ),
            CTE2 AS (
				SELECT
					CTE1.*,
						ROW_NUMBER() OVER (ORDER BY
									<cfif isdefined("arguments.sort_type") and len(arguments.sort_type) and arguments.sort_type eq 0>
                                        IMPORT_NAME ASC
                                    <cfelseif isdefined("arguments.sort_type") and len(arguments.sort_type) and arguments.sort_type eq 1>
                                        IMPORT_NAME DESC
                                    <cfelseif isdefined("arguments.sort_type") and len(arguments.sort_type) and arguments.sort_type eq 2>
                                        PAYMENT_DATE ASC
                                    <cfelse>
                                        PAYMENT_DATE DESC
                                    </cfif>
					) AS RowNum,(SELECT COUNT(*) FROM CTE1) AS QUERY_COUNT
				FROM
					CTE1
			)
			SELECT
				CTE2.*
			FROM
				CTE2
            <cfif isDefined("arguments.startrow") and arguments.startrow gt 0>
			WHERE
				RowNum BETWEEN #arguments.startrow# and #arguments.startrow#+(#arguments.maxrows#-1)
            </cfif>
        </cfquery>
        <cfreturn GET_IMPORT_LIST>
    </cffunction>

    <cffunction name = "delete" access = "public" hint = "Delete ">
        <cfargument name="SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID" required="true">
        <cftry> 
            <!--- Ödeme planına dönüştürülen değil bir satırı bile faturalanmış olan ödeme planı import silinemez
            <cfif not get_control.CONVERT_SUBSCRIPTION_PAYMENT_PLAN> --->
            <cfset rows = get_billed_row(SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID:arguments.SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID)>
            <cfif rows.recordcount eq 0>
                <cfquery name = "get_control" datasource = "#dsn3#">
                    SELECT CONVERT_SUBSCRIPTION_PAYMENT_PLAN, FILE_PATH, FILE_NAME FROM SUBSCRIPTION_PAYMENT_PLAN_IMPORT WHERE SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID = <cfqueryparam value = "#arguments.SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID#" CFSQLType = "cf_sql_integer">
                </cfquery>
                <cfif len(get_control.FILE_NAME)>
                    <cffile action="delete" file="#get_control.FILE_PATH##get_control.FILE_NAME#" mode="777">
                </cfif>
                <cfquery name = "delete" datasource = "#dsn3#">
                    DELETE FROM SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ROW WHERE SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID = <cfqueryparam value = "#arguments.SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID#" CFSQLType = "cf_sql_integer">
                </cfquery>
                <cfquery name = "delete" datasource = "#dsn3#">
                    DELETE FROM SUBSCRIPTION_PAYMENT_PLAN_IMPORT WHERE SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID = <cfqueryparam value = "#arguments.SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID#" CFSQLType = "cf_sql_integer">
                </cfquery>
                <cfreturn true>
            <cfelse>
                <cfreturn false>
            </cfif>
        <cfcatch type="any">
            <cfreturn false>    
        </cfcatch>
        </cftry>
    </cffunction>

    <cffunction name = "delete_payment_plan" access = "public" hint = "Delete ">
        <cfargument name="SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID" required="true">
        <cfargument name="ACTION_EMP" type="numeric" required="true">
        <cftry>
            <cfquery name = "add_history" datasource = "#dsn3#">
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
                        ,IS_INVOICE_IPTAL     
                    )
                SELECT  
                    SUBSCRIPTION_PAYMENT_ROW_ID
                    ,#NOW()#
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
                    ,<cfqueryparam value = "#CGI.REMOTE_ADDR#" CFSQLType = "cf_sql_nvarchar">
                    ,<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ACTION_EMP#">
                    ,RATE
                    ,0
                    ,IS_INVOICE_IPTAL     
                FROM
                    SUBSCRIPTION_PAYMENT_PLAN_ROW
                WHERE
                    SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ROW_ID IN (
                        SELECT SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ROW_ID FROM SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ROW 
                        WHERE  SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID = <cfqueryparam value = "#arguments.SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID#" cfsqltype = "cf_sql_integer">
                
                    )
            </cfquery>

            <cfquery name = "delete" datasource = "#dsn3#">
                DELETE FROM SUBSCRIPTION_PAYMENT_PLAN_ROW 
                WHERE SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ROW_ID IN (
                    SELECT 
                        SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ROW_ID 
                    FROM SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ROW 
                    WHERE 
                        SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID = <cfqueryparam value = "#arguments.SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID#" CFSQLType = "cf_sql_integer">
                )
                </cfquery>
         
            <cfreturn true>    
        <cfcatch type="any">
            <cfreturn false>    
        </cfcatch>
        </cftry>
    </cffunction>

    <cffunction name="add_import_row" access="private" hint="Insert subscription payment plan import row">
        <cfargument name="rows" required="true" type="query">

        <cfoutput query="arguments.rows">
            <!--- hatalı satır varsa ne yapalım kayıt ediyor listede gösteriyorum???---> 
             <cfquery name="add_import_row" datasource="#dsn3#">
                INSERT INTO SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ROW
                (
                SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID,
                SUBSCRIPTION_ID,
                STOCK_ID,
                PRODUCT_ID,
                PERIOD_ID,
                PAYMENT_DATE,
                PAYMENT_FINISH_DATE,
                DETAIL,
                UNIT,
                AMOUNT,
                MONEY_TYPE,
                ROW_TOTAL,
                DISCOUNT,
                ROW_NET_TOTAL,
                IS_COLLECTED_INVOICE,
                IS_BILLED,
                IS_PAID,
                IS_COLLECTED_PROVISION,
                UNIT_ID,
                PAYMETHOD_ID,
                CARD_PAYMETHOD_ID,
                SUBS_REFERENCE_ID,
                IS_GROUP_INVOICE,
                IS_INVOICE_IPTAL,
                DUE_DIFF_ID,
                SERVICE_ID,
                CALL_ID,
                IS_ACTIVE,
                CAMPAIGN_ID,
                CARI_ACTION_ID,
                CARI_PERIOD_ID,
                CARI_ACT_TYPE,
                CARI_ACT_TABLE,
                CARI_ACT_ID,
                QUANTITY,
                DISCOUNT_AMOUNT,
                CAMP_ID,
                RECORD_EMP,
                RECORD_IP,
                RECORD_DATE,
                INVOICE_DATE,
                DUE_DIFF_INVOICE_ID,
                DUE_DIFF_PERIOD_ID,
                RATE,
                BSMV_RATE,
                BSMV_AMOUNT,
                OIV_RATE,
                OIV_AMOUNT,
                TEVKIFAT_RATE,
                TEVKIFAT_AMOUNT,
                REASON_CODE,
                ROW_DESCRIPTION,
                ROW_RESULT,
                ROW_RESULT_MESSAGE
            )
            VALUES
            (
                <cfqueryparam value = "#subscription_payment_plan_import_id#" cfsqltype = "cf_sql_integer">,
                <cfif subscription_id gt 0><cfqueryparam value = "#subscription_id#" cfsqltype = "cf_sql_integer"><cfelse>NULL</cfif>,
                <cfif stock_id gt 0><cfqueryparam value = "#stock_id#" cfsqltype = "cf_sql_integer"><cfelse>NULL</cfif>,
                <cfif product_id gt 0><cfqueryparam value = "#product_id#" cfsqltype = "cf_sql_integer"><cfelse>NULL</cfif>,
                <cfif len(period_id)><cfqueryparam value = "#period_id#" cfsqltype = "cf_sql_integer"><cfelse>NULL</cfif>,
                '#payment_date#',
                <cfif len(payment_finish_date)>'#payment_finish_date#'<cfelse>NULL</cfif>,
                <cfqueryparam value = "#detail#" cfsqltype = "CF_SQL_NVARCHAR">,
                <cfqueryparam value = "#unit#" cfsqltype = "CF_SQL_NVARCHAR">,
                <cfif len(amount)><cfqueryparam value = "#amount#" cfsqltype = "CF_SQL_FLOAT"><cfelse>0</cfif>,
                <cfqueryparam value = "#money_type#" cfsqltype = "CF_SQL_NVARCHAR">,
                <cfif len(row_total)><cfqueryparam value = "#row_total#" cfsqltype = "CF_SQL_FLOAT"><cfelse>0</cfif>,
                <cfif len(discount)> <cfqueryparam value = "#discount#" cfsqltype = "CF_SQL_FLOAT"><cfelse>0</cfif>,
                <cfif len(row_net_total)><cfqueryparam value = "#row_net_total#" cfsqltype = "CF_SQL_FLOAT"><cfelse>0</cfif>,
                <cfif len(is_collected_invoice)><cfqueryparam value = "#is_collected_invoice#" cfsqltype = "CF_SQL_BIT"><cfelse>0</cfif>,
                <cfif len(is_billed)><cfqueryparam value = "#is_billed#" cfsqltype = "CF_SQL_BIT"><cfelse>0</cfif>,
                <cfif len(is_paid)><cfqueryparam value = "#is_paid#" cfsqltype = "CF_SQL_BIT"><cfelse>0</cfif>,
                <cfif len(is_collected_provision)><cfqueryparam value = "#is_collected_provision#" cfsqltype = "CF_SQL_BIT"><cfelse>0</cfif>,
                <cfif unit_id gt 0><cfqueryparam value = "#unit_id#" cfsqltype = "cf_sql_integer"><cfelse>0</cfif>,
                <cfif paymethod_id gt 0><cfqueryparam value = "#paymethod_id#" cfsqltype = "cf_sql_integer"><cfelse>NULL</cfif>,
                <cfif len(card_paymethod_id)><cfqueryparam value = "#card_paymethod_id#" cfsqltype = "cf_sql_integer"><cfelse>NULL</cfif>,
                <cfif len(subs_reference_id)><cfqueryparam value = "#subs_reference_id#" cfsqltype = "cf_sql_integer"><cfelse>NULL</cfif>,
                <cfif len(is_group_invoice)><cfqueryparam value = "#is_group_invoice#" cfsqltype = "CF_SQL_BIT"><cfelse>0</cfif>,
                <cfif len(is_invoice_iptal)><cfqueryparam value = "#is_invoice_iptal#" cfsqltype = "CF_SQL_BIT"><cfelse>NULL</cfif>,
                <cfif len(due_diff_id)><cfqueryparam value = "#due_diff_id#" cfsqltype = "cf_sql_integer"><cfelse>NULL</cfif>,
                <cfif len(service_id)><cfqueryparam value = "#service_id#" cfsqltype = "cf_sql_integer"><cfelse>NULL</cfif>,
                <cfif len(call_id)><cfqueryparam value = "#call_id#" cfsqltype = "cf_sql_integer"><cfelse>NULL</cfif>,
                <cfif len(is_active)><cfqueryparam value = "#is_active#" cfsqltype = "CF_SQL_BIT"><cfelse>0</cfif>,
                <cfif len(call_id)><cfqueryparam value = "#campaign_id#" cfsqltype = "cf_sql_integer"><cfelse>NULL</cfif>,
                <cfif len(cari_action_id)><cfqueryparam value = "#cari_action_id#" cfsqltype = "cf_sql_integer"><cfelse>NULL</cfif>,
                <cfif len(cari_period_id)><cfqueryparam value = "#cari_period_id#" cfsqltype = "cf_sql_integer"><cfelse>NULL</cfif>,
                <cfif len(cari_act_type)><cfqueryparam value = "#cari_act_type#" cfsqltype = "cf_sql_integer"><cfelse>NULL</cfif>,
                <cfif len(cari_act_table)><cfqueryparam value = "#cari_act_table#" cfsqltype = "cf_sql_integer"><cfelse>NULL</cfif>,
                <cfif len(cari_act_id)><cfqueryparam value = "#cari_act_id#" cfsqltype = "cf_sql_integer"><cfelse>NULL</cfif>,
                <cfif len(quantity)><cfqueryparam value = "#quantity#" cfsqltype = "cf_sql_integer"><cfelse>NULL</cfif>,
                <cfif len(discount_amount)><cfqueryparam value = "#discount_amount#" cfsqltype = "CF_SQL_FLOAT"><cfelse>0</cfif>,
                <cfif len(camp_id)><cfqueryparam value = "#camp_id#" cfsqltype = "cf_sql_integer"><cfelse>NULL</cfif>,
                <cfqueryparam value = "#record_emp#" cfsqltype = "cf_sql_integer">,
                <cfqueryparam value = "#record_ip#" cfsqltype = "CF_SQL_NVARCHAR">,
                #now()#,
                NULL,
                <cfif len(due_diff_invoice_id)><cfqueryparam value = "#due_diff_invoice_id#" cfsqltype = "cf_sql_integer"><cfelse>NULL</cfif>,
                <cfif len(due_diff_period_id)><cfqueryparam value = "#due_diff_period_id#" cfsqltype = "cf_sql_integer"><cfelse>NULL</cfif>,
                <cfif len(rate)><cfqueryparam value = "#rate#" cfsqltype = "CF_SQL_FLOAT"><cfelse>NULL</cfif>,
                <cfif len(bsmv_rate)><cfqueryparam value = "#bsmv_rate#" cfsqltype = "CF_SQL_FLOAT"><cfelse>0</cfif>,
                <cfif len(bsmv_amount)><cfqueryparam value = "#bsmv_amount#" cfsqltype = "CF_SQL_FLOAT"><cfelse>0</cfif>,
                <cfif len(oiv_rate)><cfqueryparam value = "#oiv_rate#" cfsqltype = "CF_SQL_FLOAT"><cfelse>0</cfif>,
                <cfif len(oiv_amount)><cfqueryparam value = "#oiv_amount#" cfsqltype = "CF_SQL_FLOAT"><cfelse>0</cfif>,
                <cfif len(tevkifat_rate)><cfqueryparam value = "#tevkifat_rate#" cfsqltype = "CF_SQL_FLOAT"><cfelse>0</cfif>,
                <cfif len(tevkifat_amount)><cfqueryparam value = "#tevkifat_amount#" cfsqltype = "CF_SQL_FLOAT"><cfelse>0</cfif>,
                <cfqueryparam value = "#reason_code#" cfsqltype = "CF_SQL_NVARCHAR">,
                <cfqueryparam value = "#ROW_DESCRIPTION#" cfsqltype = "CF_SQL_NVARCHAR">,
                <cfif len(ROW_RESULT)><cfqueryparam value = "#ROW_RESULT#" cfsqltype = "CF_SQL_BIT"><cfelse>0</cfif>,
                <cfqueryparam value = "#ROW_RESULT_MESSAGE#" cfsqltype = "CF_SQL_NVARCHAR" maxLength="500">
            )
            </cfquery>
        </cfoutput>

        <cfreturn true>
    </cffunction>

    <cffunction name="get_import_row" access="public" hint="import row daki satırları getirir">
        <cfargument name="SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID" required="true">
        <cfquery name="get_import_row" datasource="#dsn3#">
        WITH CTE1 AS(
            SELECT 
                R.*,
                C.TAXNO,
                C.OZEL_KOD,
                C.OZEL_KOD_1,
                C.FULLNAME,
                SC.SUBSCRIPTION_NO,
                SC.SPECIAL_CODE,
                SC.SUBSCRIPTION_HEAD,
                P.PRODUCT_NAME,
                S.PROPERTY
            FROM 
                SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ROW AS R
                LEFT OUTER JOIN SUBSCRIPTION_CONTRACT AS SC ON R.SUBSCRIPTION_ID = SC.SUBSCRIPTION_ID
                LEFT OUTER JOIN #dsn_alias#.COMPANY AS C ON SC.COMPANY_ID = C.COMPANY_ID
                LEFT OUTER JOIN PRODUCT AS P ON R.PRODUCT_ID = P.PRODUCT_ID
                LEFT OUTER JOIN STOCKS AS S ON R.STOCK_ID = S.STOCK_ID
            WHERE
                R.SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID = <cfqueryparam value = "#arguments.subscription_payment_plan_import_id#" cfsqltype = "cf_sql_integer">
        ),
        CTE2 AS (
				SELECT
					CTE1.*,
						ROW_NUMBER() OVER (ORDER BY
									<cfif isdefined("arguments.sort_type") and len(arguments.sort_type) and arguments.sort_type eq 1>
                                        SUBSCRIPTION_ID
                                    <cfelse>
                                        SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ROW_ID
                                    </cfif>
					) AS RowNum,(SELECT COUNT(*) FROM CTE1) AS QUERY_COUNT
				FROM
					CTE1
			)
			SELECT
				CTE2.*
			FROM
				CTE2
        </cfquery>
        <cfreturn get_import_row>
    </cffunction>

    <cffunction name="convert_payment_plan" access="public" hint="subscription_payment_plan_row daki satırları ödeme planına atar">
        <cfargument name="IMPORT_ID" required="true">
        <cfargument name="ACTION_EMP" type="numeric" required="true">
        <!--- history içinde ekleme yapmak lazım --->
        <cfquery name="payment_plan_check" datasource="#dsn3#">
            SELECT CONVERT_SUBSCRIPTION_PAYMENT_PLAN FROM SUBSCRIPTION_PAYMENT_PLAN_IMPORT 
            WHERE
                SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID = <cfqueryparam value = "#arguments.IMPORT_ID#" cfsqltype = "cf_sql_integer">
        </cfquery>
        <cfif payment_plan_check.CONVERT_SUBSCRIPTION_PAYMENT_PLAN>
            <cfreturn true>
        </cfif>

        <cftransaction>
        <cfquery name="convert_payment_plan" datasource="#dsn3#">
            INSERT INTO SUBSCRIPTION_PAYMENT_PLAN_ROW
            (
            SUBSCRIPTION_ID,
            STOCK_ID,
            PRODUCT_ID,
            PERIOD_ID,
            PAYMENT_DATE,
            PAYMENT_FINISH_DATE,
            DETAIL,
            UNIT,
            AMOUNT,
            MONEY_TYPE,
            ROW_TOTAL,
            DISCOUNT,
            ROW_NET_TOTAL,
            IS_COLLECTED_INVOICE,
            IS_BILLED,
            IS_PAID,
            IS_COLLECTED_PROVISION,
            UNIT_ID,
            PAYMETHOD_ID,
            CARD_PAYMETHOD_ID,
            SUBS_REFERENCE_ID,
            IS_GROUP_INVOICE,
            IS_INVOICE_IPTAL,
            DUE_DIFF_ID,
            SERVICE_ID,
            CALL_ID,
            IS_ACTIVE,
            CAMPAIGN_ID,
            CARI_ACTION_ID,
            CARI_PERIOD_ID,
            CARI_ACT_TYPE,
            CARI_ACT_TABLE,
            CARI_ACT_ID,
            QUANTITY,
            DISCOUNT_AMOUNT,
            CAMP_ID,
            RECORD_EMP,
            RECORD_IP,
            RECORD_DATE,
            INVOICE_DATE,
            DUE_DIFF_INVOICE_ID,
            DUE_DIFF_PERIOD_ID,
            RATE,
            BSMV_RATE,
            BSMV_AMOUNT,
            OIV_RATE,
            OIV_AMOUNT,
            TEVKIFAT_RATE,
            TEVKIFAT_AMOUNT,
            REASON_CODE,
            SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ROW_ID,
            ROW_DESCRIPTION)
        SELECT
            SUBSCRIPTION_ID,
            STOCK_ID,
            PRODUCT_ID,
            PERIOD_ID,
            PAYMENT_DATE,
            PAYMENT_FINISH_DATE,
            DETAIL,
            UNIT,
            AMOUNT,
            MONEY_TYPE,
            ROW_TOTAL,
            DISCOUNT,
            ROW_NET_TOTAL,
            IS_COLLECTED_INVOICE,
            IS_BILLED,
            IS_PAID,
            IS_COLLECTED_PROVISION,
            UNIT_ID,
            PAYMETHOD_ID,
            CARD_PAYMETHOD_ID,
            SUBS_REFERENCE_ID,
            IS_GROUP_INVOICE,
            IS_INVOICE_IPTAL,
            DUE_DIFF_ID,
            SERVICE_ID,
            CALL_ID,
            IS_ACTIVE,
            CAMPAIGN_ID,
            CARI_ACTION_ID,
            CARI_PERIOD_ID,
            CARI_ACT_TYPE,
            CARI_ACT_TABLE,
            CARI_ACT_ID,
            QUANTITY,
            DISCOUNT_AMOUNT,
            CAMP_ID,
            <cfqueryparam value = "#arguments.ACTION_EMP#" cfsqltype = "cf_sql_integer">,
            <cfqueryparam value = "#CGI.REMOTE_ADDR#" CFSQLType = "cf_sql_nvarchar">,
            #NOW()#,
            INVOICE_DATE,
            DUE_DIFF_INVOICE_ID,
            DUE_DIFF_PERIOD_ID,
            RATE,
            BSMV_RATE,
            BSMV_AMOUNT,
            OIV_RATE,
            OIV_AMOUNT,
            TEVKIFAT_RATE,
            TEVKIFAT_AMOUNT,
            REASON_CODE,
            SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ROW_ID,
            ROW_DESCRIPTION
        FROM
            SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ROW 
        WHERE
            SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID = <cfqueryparam value = "#arguments.IMPORT_ID#" cfsqltype = "cf_sql_integer">
        </cfquery>

        <cfquery name="payment_plan_upd" datasource="#dsn3#">
            UPDATE SUBSCRIPTION_PAYMENT_PLAN_IMPORT SET
                CONVERT_SUBSCRIPTION_PAYMENT_PLAN = 1,
                UPDATE_EMP =<cfqueryparam value = "#arguments.ACTION_EMP#" cfsqltype = "cf_sql_integer">,
                UPDATE_IP = <cfqueryparam value = "#CGI.REMOTE_ADDR#" CFSQLType = "cf_sql_nvarchar">,
                UPDATE_DATE = #NOW()#
            WHERE
                SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID = <cfqueryparam value = "#arguments.IMPORT_ID#" cfsqltype = "cf_sql_integer">
        </cfquery>

        <cfquery name = "add_history" datasource = "#dsn3#">
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
                    ,IS_INVOICE_IPTAL     
                )
            SELECT  
                SUBSCRIPTION_PAYMENT_ROW_ID
                ,#NOW()#
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
                ,<cfqueryparam value = "#CGI.REMOTE_ADDR#" CFSQLType = "cf_sql_nvarchar">
                ,<cfqueryparam value = "#arguments.ACTION_EMP#" cfsqltype = "cf_sql_integer">
                ,RATE
                ,1
                ,IS_INVOICE_IPTAL     
            FROM
                SUBSCRIPTION_PAYMENT_PLAN_ROW
            WHERE
                SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ROW_ID IN (
                    SELECT SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ROW_ID FROM SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ROW 
                    WHERE  SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID = <cfqueryparam value = "#arguments.IMPORT_ID#" cfsqltype = "cf_sql_integer">
            
                )
            </cfquery>

        </cftransaction>

        <cfreturn true>
    </cffunction>

    <cffunction name="get_data" access="private" hint="Import tipindeki değerlere göre dosyadan yada servisden datayı alır ve return olarak import_row tablosu formatında data döner">
        <cfargument name="SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID" required="true" type="numeric">
        <!--- type tablosundaki FILE_NAME alanı değerinden componet yaratır ve o dosyada yer alacak read_data  fonksiyonunu çağırı 
            yüklenen cfc dosyasındaki read_data fonksiyonu gönderilen return_data tipinde değer döner
        !--->
        
        <!---DATA YAPISINI ALABİLMEK İÇİN BOŞ SORGU ÇEKİYORUZ --->
        <cfquery name="returnData" datasource="#dsn3#">
            SELECT *, 1 AS ROW_RESULT,'' AS ROW_RESULT_MESSAGE  FROM SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ROW WHERE SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID = 0
        </cfquery>

        <cfscript>
            rowStructure = get_table_structure();
            planImport = get_byID(SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID:arguments.SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID);
            gsa = createObject("component","V16.settings.cfc.subscriptionPaymentPlanImportType");
            get_payment_plan_import_type = gsa.GET_BYID_FOR_BACKEND(IMPORT_TYPE_ID:planImport.IMPORT_TYPE_ID);
        
            comp = createObject("component","documents.sales.import_type.#get_payment_plan_import_type.CFC_FILE#");

            data = comp.read_data(payment_plan_import:planImport,row_structure:rowStructure,return_data:returnData,payment_plan_import_type:get_payment_plan_import_type);
            data = set_row_detail(payment_plan_import:planImport,data:data,payment_plan_import_type:get_payment_plan_import_type);
        </cfscript>
        <cfreturn data>
    </cffunction>

    <cffunction name="get_billed_row" access="public" hint="">
        <cfargument name="SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID" type="integer">
        <!--- import edilen kayıtlardan faturalananları döner --->
        <cfquery name="check_invoice" datasource="#dsn3#">
            SELECT
                S.SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ROW_ID
            FROM 
                SUBSCRIPTION_PAYMENT_PLAN_ROW AS S
                INNER JOIN SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ROW AS I ON S.SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ROW_ID = I.SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ROW_ID
            WHERE
                S.IS_BILLED = 1
                AND I.SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID = <cfqueryparam value = "#arguments.SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID#" cfsqltype = "cf_sql_integer">
        </cfquery>
        <cfreturn check_invoice>
    </cffunction>

    <cffunction name="get_table_structure" access="private" hint="">
        <!--- okunan datanın yazılacağı tablonun kolon yapısını structure olarak döner --->
        <cfdbinfo
            type="columns"
            datasource="#dsn3#"
            table="SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ROW"
            name="dbdata">
         <cfset rowData = StructNew()>
        <cfoutput query="dbdata">
            <cfset rowData["#COLUMN_NAME#"] = "">
        </cfoutput>
        <cfreturn rowData>
    </cffunction>

    <cffunction name="main" access="public" hint="ana fonksiyon tüm işleri düzenler ve yapar">
        <cfargument name="IMPORT_ID" type="integer"><!--- geliyorsa güncellemedir --->
        <cfargument name="IMPORT_TYPE_ID" type="numeric" required="true">
        <cfargument name="IMPORT_NAME" type="string" required="true">
        <cfargument name="FILE_PATH" type="string" default=""><!--- dosya adı hariç yolu --->
        <cfargument name="FILE" type="string" default=""><!--- dosya adı --->
        <cfargument name="DESCRIPTION" type="string" default="">
        <cfargument name="ROW_DESCRIPTION" type="string" default="">
        <cfargument name="CONVERT_SUBSCRIPTION_PAYMENT_PLAN" type="boolean" default="0">
        <cfargument name="PROCESS_STAGE" type="numeric" required="true">
        <cfargument name="PAYMENT_DATE">
        <cfargument name="START_DATE">
        <cfargument name="FINISH_DATE">
        <cfargument name="ACTION_EMP" type="numeric" required="true">
        <cfargument name="CONVERT" type="boolean" default="0">
        <cftry>
            <cftransaction>
                <cfset result = StructNew()>
                <cfif isdefined("arguments.IMPORT_ID") and len(arguments.IMPORT_ID)>   
                    <cfscript>
                        result["importResult"] = upd_import(
                                SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID: arguments.IMPORT_ID,
                                IMPORT_NAME: arguments.IMPORT_NAME,
                                DESCRIPTION: arguments.description,
                                PROCESS_STAGE: arguments.process_stage,
                                UPDATE_EMP: arguments.ACTION_EMP
                            );
                            result["actionid"] =arguments.IMPORT_ID;
                            result["actionResult"] = result["importResult"];
                            if(arguments.CONVERT){
                                result["convert_payment_plan"] = convert_payment_plan(
                                    IMPORT_ID: arguments.IMPORT_ID,
                                    ACTION_EMP: arguments.ACTION_EMP
                                );
                            }
                    </cfscript>
                <cfelse>
                    <cfif isdefined("arguments.start_date") and len(arguments.start_date)><cf_date tarih="arguments.start_date"></cfif>
                    <cfif isdefined("arguments.finish_date") and len(arguments.finish_date)><cf_date tarih="arguments.finish_date"></cfif>
                    <cfif isdefined("arguments.payment_date") and len(arguments.payment_date)>
                        <cf_date tarih="arguments.payment_date">
                    <cfelse>
                        <cfset arguments.payment_date = now()>
                    </cfif>
                    <cfscript>
                        result["importResult"] = add_import(
                                IMPORT_TYPE_ID: arguments.import_type_id,
                                IMPORT_NAME: arguments.IMPORT_NAME,
                                FILE_PATH: arguments.FILE_PATH,
                                FILE: arguments.FILE,
                                DESCRIPTION: arguments.description,
                                ROW_DESCRIPTION:arguments.row_description,
                                CONVERT_SUBSCRIPTION_PAYMENT_PLAN: 0,
                                PROCESS_STAGE: arguments.process_stage,
                                PAYMENT_DATE:arguments.payment_date,
                                START_DATE:arguments.start_date,
                                FINISH_DATE: arguments.finish_date,
                                RECORD_EMP: arguments.ACTION_EMP
                            );
                        if(result["importResult"]){
                            result["actionid"] = get_max_import_id();
                            result["rows"] = get_data(SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID:result["actionid"]);
                           
                            if(!add_import_row(rows:result["rows"])){
                                result["importResult"] =false;
                                result["errorMessage"] = 'satır kaydında hata';
                            }
                        }
                    </cfscript>
                    
                    <cfset result["actionResult"] = result["importResult"]>
                </cfif>
            </cftransaction>
        <cfcatch>
            <cfset result["actionResult"] = false>
            <cfset result["errorMessage"] = cfcatch.message>
        </cfcatch>
        </cftry>
        
        <cfreturn result>
    </cffunction>

    <cffunction name="set_row_detail" access="private" hint="">
        <cfargument name="payment_plan_import" required="true" type="query">
        <cfargument name="data" required="true" type="query">
        <cfargument name="payment_plan_import_type" required="true" type="query">

        <!--- read_data ile cfc dosyasından gelen tüm satırlar dönülerek 
            SETUP_PAYMENT_PLAN_IMPORT_TYPE tablosundaki tanımlara göre satırlardaki alanlar güncellenir
            Ayrıca İmport ekranındaki formdan gelen veriler ile satırlardaki alanlar güncellenir --->

        <!--- yuvarlama degerleri basketten alinir --->
        <cfquery name="get_round_num" datasource="#dsn3#">
            SELECT PRICE_ROUND_NUMBER,BASKET_TOTAL_ROUND_NUMBER FROM SETUP_BASKET WHERE BASKET_ID = 2
        </cfquery>
        <cfif get_round_num.recordcount and len(get_round_num.price_round_number)>
            <cfset round_num = get_round_num.price_round_number>
        <cfelse>
            <cfset round_num = 4>
        </cfif>

        <cfset product_id_list = ListRemoveDuplicates(ValueList(arguments.data.product_id))>
        <cfset stock_id_list = ListRemoveDuplicates(ValueList(arguments.data.stock_id))>
        <!--- Hiç ürün yoksa çık --->
        <cfif not ListLen(product_id_list)>
            <cfreturn arguments.data>
        </cfif>

        <!--- ürün istisna kodlarını al --->
        <cfquery name="get_product_period" datasource="#dsn3#">
            SELECT
                PP.REASON_CODE,
                PP.PRODUCT_ID,
                PP.SALES_PAYMETHOD_ID
            FROM
                PRODUCT_PERIOD AS PP
            WHERE
                PP.PRODUCT_ID IN (#product_id_list#)
                AND PP.PERIOD_ID = <cfqueryparam value = "#session.ep.period_id#" cfsqltype = "cf_sql_integer">
        </cfquery>

        <!--- ürün bilgilerini al --->
        <cfquery name="get_products" datasource="#dsn3#">
            SELECT
                P.PRODUCT_ID,
                S.STOCK_ID,
                P.PRODUCT_NAME,
                S.PROPERTY,
                P.BSMV,
                P.OIV,
                PS.MONEY,
                PS.PRICE
            FROM
                #DSN#_product.PRODUCT AS P
                INNER JOIN #DSN#_product.STOCKS AS S ON P.PRODUCT_ID = S.PRODUCT_ID
                INNER JOIN #DSN#_product.PRICE_STANDART as PS ON P.PRODUCT_ID = PS.PRODUCT_ID  AND S.PRODUCT_UNIT_ID = PS.UNIT_ID
            WHERE
                S.STOCK_ID IN (#stock_id_list#)
                AND PS.PURCHASESALES = 1
                AND PS.PRICESTANDART_STATUS = 1
        </cfquery>

        <cfset delete_row = "">
        <!--- tüm satırları dönüyor--->
        <cfloop query = "arguments.data">
        <!--- <cfoutput query="arguments.data"> --->
            <!--- satıra import id yi yazıyoruz --->
            <cfset arguments.data.SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID[arguments.data.currentRow] = payment_plan_import.SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID>
            
            <!--- dosya okumada hata yoksa başarılı işaretlenmedi ise başarılı olarak yazıldı --->
            <cfif not len(arguments.data.ROW_RESULT[arguments.data.currentRow]) or arguments.data.ROW_RESULT[arguments.data.currentRow] eq "[empty string]">
                <cfset arguments.data.ROW_RESULT[arguments.data.currentRow] = TRUE>
                <cfset arguments.data.ROW_RESULT_MESSAGE[arguments.data.currentRow] = "">
            </cfif>

            <!--- satırda ürün id alanları boş ise ürün bulunamadı mesajı yaz. Eğer daha önce hata mesajı yazıldıysa ilk mesajı ezmiyoruz--->
            <cfif not arguments.data.PRODUCT_ID[arguments.data.currentRow] gt 0  or not arguments.data.STOCK_ID[arguments.data.currentRow] gt 0>
                <cfif arguments.data.ROW_RESULT[arguments.data.currentRow]>
                    <cfset arguments.data.PRODUCT_ID[arguments.data.currentRow] = 0>
                    <cfset arguments.data.STOCK_ID[arguments.data.currentRow] = 0>
                    <cfset arguments.data.ROW_RESULT[arguments.data.currentRow] = false>
                    <cfset arguments.data.ROW_RESULT_MESSAGE[arguments.data.currentRow] = DETAIL & " Ürün Tanımlı Değil. ">
                </cfif>
            </cfif>

            <!--- SETUP_PAYMENT_PLAN_IMPORT_TYPE tablosundaki ürün fiyatı veya vergisi kullanılsın alanları TRUE ise boş gelen satırlara ürün standart fiyatı ve BSMV ve OİV oranları yazılıyor --->         
            <cfif len(arguments.payment_plan_import_type.USE_PRODUCT_PRICE) and arguments.payment_plan_import_type.USE_PRODUCT_PRICE
                OR len(arguments.payment_plan_import_type.USE_PRODUCT_TAX) and arguments.payment_plan_import_type.USE_PRODUCT_TAX>
                <cfif len(arguments.data.PRODUCT_ID[arguments.data.currentRow]) AND arguments.data.PRODUCT_ID[arguments.data.currentRow] GT 0>
                    <cfquery name="get_product" dbtype="query">
                        SELECT 
                            BSMV,
                            OIV,
                            MONEY,
                            PRICE
                        FROM get_products
                        WHERE 
                            PRODUCT_ID = #arguments.data.PRODUCT_ID[arguments.data.currentRow]#
                    </cfquery>
                    <cfif get_product.recordCount>
                        <cfif not len(arguments.data.amount[arguments.data.currentRow]) AND len(arguments.payment_plan_import_type.USE_PRODUCT_PRICE) and arguments.payment_plan_import_type.USE_PRODUCT_PRICE>
                            <cfset arguments.data.amount[arguments.data.currentRow] = get_product.price>
                            <cfset arguments.data.money_type[arguments.data.currentRow] = get_product.MONEY>
                        </cfif>
                        <cfif not len(bsmv_rate) and len(arguments.payment_plan_import_type.USE_PRODUCT_TAX) and arguments.payment_plan_import_type.USE_PRODUCT_TAX>
                            <cfset arguments.data.bsmv_rate[arguments.data.currentRow] = get_product.bsmv>
                            <cfset arguments.data.oiv_rate[arguments.data.currentRow] = get_product.oiv>
                        </cfif>
                    </cfif>
                </cfif>
            </cfif>

            <!--- SETUP_PAYMENT_PLAN_IMPORT_TYPE tablosundaki 0 fiyatlı ürüne izin ver false ise 0 fiyatlıları siliyoruz--->
            <cfif (not len(arguments.data.amount[arguments.data.currentRow]) or arguments.data.amount[arguments.data.currentRow] eq 0)
                AND len(arguments.payment_plan_import_type.IS_ALLOW_ZERO_PRICE) and arguments.payment_plan_import_type.IS_ALLOW_ZERO_PRICE EQ false>
                <cfset delete_row = delete_row & "," & arguments.data.currentRow>
                <!--- <cfset QueryDeleteRow(arguments.data, arguments.data.currentRow)> --->
                <cfcontinue>
            </cfif>

            <!--- SETUP_PAYMENT_PLAN_IMPORT_TYPE tablosundaki istisna kodu alanı true ise ürünün istisna kodu alınır ve ürün istisna kodu yazılmamış satırlar güncellenir --->         
            <cfif not len(arguments.data.REASON_CODE[arguments.data.currentRow]) and len(arguments.payment_plan_import_type.USE_PRODUCT_REASON_CODE) and arguments.payment_plan_import_type.USE_PRODUCT_REASON_CODE
                AND len(arguments.data.PRODUCT_ID[arguments.data.currentRow]) AND arguments.data.PRODUCT_ID[arguments.data.currentRow] gt 0>
                <cfquery name="get_period" dbtype="query">
                    SELECT *
                    FROM get_product_period
                    WHERE 
                        PRODUCT_ID = #arguments.data.PRODUCT_ID[arguments.data.currentRow]#
                </cfquery>
                <cfif get_period.recordCount>
                    <cfset arguments.data.REASON_CODE[arguments.data.currentRow] = get_period.REASON_CODE>
                <cfelse>
                    <cfif arguments.data.ROW_RESULT[arguments.data.currentRow]>
                        <cfset arguments.data.ROW_RESULT[arguments.data.currentRow] = false>
                        <cfset arguments.data.ROW_RESULT_MESSAGE[arguments.data.currentRow] = arguments.data.DETAIL[arguments.data.currentRow] & arguments.data.PRODUCT_ID[arguments.data.currentRow] & " Ürün Muhasebe Kodu Tanımlı Değil. ">
                    </cfif>
                </cfif>
            </cfif>

            <!--- SETUP_PAYMENT_PLAN_IMPORT_TYPE tablosundaki USE_PRODUCT_PAYMETHOD true ise ürünün satış ödeme yöntemi alınır ve satırlardaki boş olanlar güncellenir --->         
            <cfif not len(arguments.data.PAYMETHOD_ID[arguments.data.currentRow]) and len(arguments.payment_plan_import_type.USE_PRODUCT_PAYMETHOD) and arguments.payment_plan_import_type.USE_PRODUCT_PAYMETHOD
                AND len(arguments.data.PRODUCT_ID[arguments.data.currentRow]) AND arguments.data.PRODUCT_ID[arguments.data.currentRow] gt 0>
                <cfquery name="get_period" dbtype="query">
                    SELECT *
                    FROM get_product_period
                    WHERE 
                        PRODUCT_ID = #arguments.data.PRODUCT_ID[arguments.data.currentRow]#
                </cfquery>
                <cfif get_period.recordCount>
                    <cfset arguments.data.PAYMETHOD_ID[arguments.data.currentRow] = get_period.SALES_PAYMETHOD_ID>
                </cfif>
            </cfif>

            <!--- SETUP_PAYMENT_PLAN_IMPORT_TYPE tablosunda ödeme yöntemi varsa ödeme yöntemi olmayan satırlara tablodaki yazılır--->
            <cfif not len(arguments.data.paymethod_id[arguments.data.currentRow]) and len(arguments.payment_plan_import_type.paymethod_id)>
                <cfset arguments.data.paymethod_id[arguments.data.currentRow] = arguments.payment_plan_import_type.paymethod_id>
            </cfif>

            <!--- ödeme yöntemi boş olan satırlarda ödeme yöntemi aboneden alınır --->
            <cfif not len(arguments.data.PAYMETHOD_ID[arguments.data.currentRow])
                AND len(arguments.data.SUBSCRIPTION_ID[arguments.data.currentRow]) AND arguments.data.SUBSCRIPTION_ID[arguments.data.currentRow] gt 0>
                <cfquery name="get_sub_paymethod" datasource="#dsn3#">
                    SELECT 
                        PAYMENT_TYPE_ID
                    FROM 
                        SUBSCRIPTION_CONTRACT
                    WHERE 
                        SUBSCRIPTION_ID = <cfqueryparam value = "#arguments.data.SUBSCRIPTION_ID[arguments.data.currentRow]#" cfsqltype = "cf_sql_integer">
                </cfquery>
                <cfif get_sub_paymethod.recordCount>
                    <cfset arguments.data.PAYMETHOD_ID[arguments.data.currentRow] = get_sub_paymethod.PAYMENT_TYPE_ID>
                </cfif>
            </cfif>

            <!--- ödeme yöntemi tanımlı değilse satır hatası mesajı yaz 
            <cfif not len(arguments.data.paymethod_id[arguments.data.currentRow]) and len(arguments.payment_plan_import_type.paymethod_id)>
                <cfif arguments.data.ROW_RESULT[arguments.data.currentRow]>
                    <cfset arguments.data.ROW_RESULT[arguments.data.currentRow] = false>
                    <cfset arguments.data.ROW_RESULT_MESSAGE[arguments.data.currentRow] = arguments.data.DETAIL[arguments.data.currentRow] & arguments.data.product_id[arguments.data.currentRow] & " Ürün Ödeme Yöntemi Tanımlı Değil. ">
                </cfif>
            </cfif>
            --->

            <!--- fiyat bilgisi güncellendiği için satırlardaki satır toplam ve vergi tutarları hesaplanıyor --->
            <cfif not len(arguments.data.amount[arguments.data.currentRow])>
                <cfset arguments.data.amount[arguments.data.currentRow] = 0>
            </cfif>
            <cfif not len(arguments.data.bsmv_rate[arguments.data.currentRow])>
                <cfset arguments.data.bsmv_rate[arguments.data.currentRow] = 0>
            </cfif>
            <cfif not len(arguments.data.oiv_rate[arguments.data.currentRow])>
                <cfset arguments.data.oiv_rate[arguments.data.currentRow] = 0>
            </cfif>
            <cfif not len(arguments.data.discount[arguments.data.currentRow])>
                <cfset arguments.data.discount[arguments.data.currentRow] = 0>
            </cfif>
            <cfif not len(arguments.data.discount_amount[arguments.data.currentRow])>
                <cfset arguments.data.discount_amount[arguments.data.currentRow] = 0>
            </cfif>
            <cfif not len(arguments.data.quantity[arguments.data.currentRow])>
                <cfset arguments.data.quantity[arguments.data.currentRow] = 1>
            </cfif>

            <cfset arguments.data.row_net_total[arguments.data.currentRow] = ( (arguments.data.amount[arguments.data.currentRow]- arguments.data.discount_amount[arguments.data.currentRow]) - ( (arguments.data.amount[arguments.data.currentRow]- arguments.data.discount_amount[arguments.data.currentRow]) * (arguments.data.discount[arguments.data.currentRow]/100) ) ) * arguments.data.quantity[arguments.data.currentRow]>
            <!---<cfset arguments.data.row_net_total[arguments.data.currentRow] = ( arguments.data.amount[arguments.data.currentRow] - arguments.data.discount_amount[arguments.data.currentRow] ) * arguments.data.quantity[arguments.data.currentRow]>--->
            <cfset arguments.data.row_total[arguments.data.currentRow] = arguments.data.amount[arguments.data.currentRow] * arguments.data.quantity[arguments.data.currentRow]>
            <cfset arguments.data.bsmv_amount[arguments.data.currentRow] = wrkFunction.wrk_round(( arguments.data.row_net_total[arguments.data.currentRow] * arguments.data.bsmv_rate[arguments.data.currentRow] ) / 100, round_num)>
            <cfset arguments.data.oiv_amount[arguments.data.currentRow] = wrkFunction.wrk_round((arguments.data.row_net_total[arguments.data.currentRow] * arguments.data.oiv_rate[arguments.data.currentRow]) / 100, round_num)>
        
            <!--- SETUP_PAYMENT_PLAN_IMPORT_TYPE tablosunda IS_ROW_DESCRIPTION ise import formuna satır açıklama alanı gelir bu alana veri girildi ise boş olan satır açıklamalarını formda girilen yazılıyor--->
            <cfif len(arguments.payment_plan_import.row_description) and arguments.payment_plan_import_type.IS_ROW_DESCRIPTION>
                <cfif not len(arguments.data.ROW_DESCRIPTION[arguments.data.currentRow])>
                    <cfset arguments.data.ROW_DESCRIPTION[arguments.data.currentRow] = arguments.payment_plan_import.row_description>
                </cfif>
            </cfif>

            <!--- read_datadan gelen detail alanı (ürün adı bölümü) boş ise, type tablosundaki detail alanıda boş ise, ürün adını yazıyoruz --->
            <cfif not len(arguments.data.detail[arguments.data.currentRow])>
                <cfif len(arguments.payment_plan_import_type.detail)>
                    <cfset arguments.data.detail[arguments.data.currentRow] = payment_plan_import.detail>
                <cfelse>
                    <cfif len(STOCK_ID) and STOCK_ID GT 0>
                        <cfquery name="get_product_name" dbtype="query">
                            SELECT 
                                PRODUCT_NAME,
                                PROPERTY
                            FROM
                                get_products
                            WHERE 
                                STOCK_ID = #arguments.data.STOCK_ID[arguments.data.currentRow]#
                        </cfquery>
                        <cfif get_product_name.recordCount>
                            <cfset productName_ = get_product_name.PRODUCT_NAME>
                            <cfif len(get_product_name.PROPERTY)>
                                <cfset productName_ = productName_  &' - '& get_product_name.PROPERTY>
                            </cfif>
                            <cfset arguments.data.detail[arguments.data.currentRow] = productName_>
                        </cfif>
                    </cfif>
                </cfif>
            </cfif>


            <!---SETUP_PAYMENT_PLAN_IMPORT_TYPE tablosunda tanımlı değerlere göre satırlar güncelleniyor--->
           <cfif len(arguments.payment_plan_import_type.IS_COLLECTED_INVOICE)>
                <cfset arguments.data.IS_COLLECTED_INVOICE[arguments.data.currentRow] = arguments.payment_plan_import_type.IS_COLLECTED_INVOICE>
            <cfelse>
                <cfset arguments.data.IS_COLLECTED_INVOICE[arguments.data.currentRow] = false>
            </cfif>
            <cfif len(arguments.payment_plan_import_type.is_group_invoice)>
                <cfset arguments.data.is_group_invoice[arguments.data.currentRow] = arguments.payment_plan_import_type.is_group_invoice>
            <cfelse>
                <cfset arguments.data.is_group_invoice[arguments.data.currentRow] = false>
            </cfif>

            <!--- dosyada tahakkuk tarihi yok ama formda var ise satırlara bu tarih tahakkuk tarihi olarak giriliyor.  --->
            <cfif not len(arguments.data.payment_date[arguments.data.currentRow]) and len(payment_plan_import.payment_date)>
                <cfset arguments.data.payment_date[arguments.data.currentRow] = payment_plan_import.payment_date><!---//tahakkuk tarihi formdan kullanıcı giriyor--->
            </cfif>
            <cfif not len(arguments.data.payment_date[arguments.data.currentRow])>
                <cfif arguments.data.ROW_RESULT[arguments.data.currentRow]>
                    <cfset arguments.data.ROW_RESULT[arguments.data.currentRow] =false>
                    <cfset arguments.data.ROW_RESULT_MESSAGE[arguments.data.currentRow] = "Ödeme tarihi girilmemiş">
                </cfif>
            </cfif>

            <cfif not len(arguments.data.paymethod_id[arguments.data.currentRow])>
                <cfif arguments.data.ROW_RESULT[arguments.data.currentRow]>
                    <cfset arguments.data.ROW_RESULT[arguments.data.currentRow] = false>
                    <cfset arguments.data.ROW_RESULT_MESSAGE[arguments.data.currentRow] ="Ödeme Yöntemi Tanımlı Değil">
                </cfif>
            </cfif>

            <cfif not len(arguments.data.is_billed[arguments.data.currentRow])>
                <cfset arguments.data.is_billed[arguments.data.currentRow] = false>
            </cfif>
            <cfif not len(arguments.data.is_paid[arguments.data.currentRow])>
                <cfset arguments.data.is_paid[arguments.data.currentRow] = false>
            </cfif>
            <cfif not len(arguments.data.is_collected_provision[arguments.data.currentRow])>
                <cfset arguments.data.is_collected_provision[arguments.data.currentRow] = false>
            </cfif>
            <cfif not len(arguments.data.is_active[arguments.data.currentRow])>
                <cfset arguments.data.is_active[arguments.data.currentRow] = True>
            </cfif>
            <cfif not len(arguments.data.record_emp[arguments.data.currentRow])>
                <cfset arguments.data.record_emp[arguments.data.currentRow] = payment_plan_import.record_emp>
            </cfif>
            <cfif not len(arguments.data.unit[arguments.data.currentRow])>
                <cfset arguments.data.unit[arguments.data.currentRow] = "Adet">
                <cfset arguments.data.unit_id[arguments.data.currentRow] = 0>
            </cfif>

            <!--- fiyat parabirimi boş ise üründen alıyoruz oda yoksa sabit TL yazıyoruz ---> 
            <cfif not len(arguments.data.money_type[arguments.data.currentRow]) AND
                len(arguments.data.PRODUCT_ID[arguments.data.currentRow]) AND arguments.data.PRODUCT_ID[arguments.data.currentRow] GT 0>
                <cfquery name="get_product" dbtype="query">
                    SELECT 
                        MONEY
                    FROM get_products
                    WHERE 
                        PRODUCT_ID = #arguments.data.PRODUCT_ID[arguments.data.currentRow]#
                </cfquery>
                <cfif get_product.recordCount>
                    <cfset arguments.data.money_type[arguments.data.currentRow] = get_product.MONEY>
                <cfelse>
                    <cfset arguments.data.money_type[arguments.data.currentRow] = "TL">
                </cfif>
            </cfif>

        <!--- </cfoutput> --->
        </cfloop>
        
        <cfset a = 0>
        <cfloop list="#delete_row#" delimiters="," index="row">
            
            <cfset QueryDeleteRow(arguments.data, row-a)>
            <cfset a = a+1>
        </cfloop>
        <cfreturn arguments.data>
    </cffunction>

    <cffunction name="format_currency" access="public" hint="">
        <!--- her formatta gelebilecek para birimini düzenliyor --->
        <cfargument name="amount" required="true" type="string">
        <cfif len(arguments.amount) or arguments.amount gt 0 >
            <cfset nokta = ListLast(arguments.amount,'.')>
            <cfset virgul = ListLast(arguments.amount,',')>
            <cfif find(nokta,virgul) and nokta neq arguments.amount and virgul neq arguments.amount>
                <!--- virgulden gelen noktayı kapsıyor mu --->
                <cfset arguments.amount = replace(arguments.amount,',','','all')>
            <cfelseif find(virgul,nokta) and virgul neq arguments.amount and nokta neq arguments.amount>
                <cfset arguments.amount = replace(arguments.amount,'.','','all')>
            </cfif>
            <cfset arguments.amount = replace(arguments.amount,',','.','all')>
        </cfif>
        <cfreturn arguments.amount>
    </cffunction>

    <cffunction name="get_subscription" access="public" hint="">
        <!--- abone bulmak için kullanılabilir ozel_kod veya vergi numarası ile yapılabilir. Abone kategorisi zorunlu --->
        <cfquery name="get_sub" datasource="#DSN3#">
            SELECT 
                SC.SUBSCRIPTION_ID,
                SC.START_DATE,
                SC.FINISH_DATE
            FROM 
                SUBSCRIPTION_CONTRACT AS SC,
                #dsn#.COMPANY AS C
            WHERE
                SC.COMPANY_ID = C.COMPANY_ID
                <cfif isdefined("ARGUMENTS.FILTER") and len(ARGUMENTS.FILTER) >
                AND (
                        C.OZEL_KOD = <cfqueryparam value = "#ARGUMENTS.FILTER#" cfsqltype = "cf_sql_nvarchar">
                        OR C.OZEL_KOD_1 = <cfqueryparam value = "#ARGUMENTS.FILTER#" cfsqltype = "cf_sql_nvarchar">
                        OR C.OZEL_KOD_2 = <cfqueryparam value = "#ARGUMENTS.FILTER#" cfsqltype = "cf_sql_nvarchar">
                        OR SC.SPECIAL_CODE = <cfqueryparam value = "#ARGUMENTS.FILTER#" cfsqltype = "cf_sql_nvarchar">
                        OR SC.SUBSCRIPTION_NO = <cfqueryparam value = "#ARGUMENTS.FILTER#" cfsqltype = "cf_sql_nvarchar">
                        OR C.TAXNO = <cfqueryparam value = "#ARGUMENTS.FILTER#" cfsqltype = "cf_sql_nvarchar">
                )
                </cfif>
                <cfif isDefined("ARGUMENTS.SUBSCRIPTION_TYPE_ID") and len(ARGUMENTS.SUBSCRIPTION_TYPE_ID)>
                    AND SC.SUBSCRIPTION_TYPE_ID = <cfqueryparam value = "#ARGUMENTS.SUBSCRIPTION_TYPE_ID#" cfsqltype = "cf_sql_integer">
                <cfelseif isDefined("ARGUMENTS.SUBSCRIPTION_TYPE_ID_LIST") and len(ARGUMENTS.SUBSCRIPTION_TYPE_ID_LIST)>
                    AND SC.SUBSCRIPTION_TYPE_ID IN (#ARGUMENTS.SUBSCRIPTION_TYPE_ID_LIST#)
                </cfif>
                <cfif isdefined("ARGUMENTS.SUBSCRIPTION_ADD_OPTION_ID") and len(ARGUMENTS.SUBSCRIPTION_ADD_OPTION_ID)>
                AND SC.SUBSCRIPTION_ADD_OPTION_ID = <cfqueryparam value = "#ARGUMENTS.SUBSCRIPTION_ADD_OPTION_ID#" cfsqltype = "cf_sql_integer">
                </cfif>
                AND SC.IS_ACTIVE = 1
                AND C.IS_BUYER = 1
        </cfquery>
        
        <cfreturn get_sub>
    </cffunction>

    <cffunction name="get_product" access="public" hint="">
        <!--- ürün bulma için kullanılır --->
        <cfquery name="get_product" datasource="#dsn3#">
            SELECT 
                P.PRODUCT_ID,
                P.PRODUCT_NAME,
                S.PROPERTY,
                S.STOCK_ID,
                P.PRODUCT_CATID,
                P.PRODUCT_DETAIL
            FROM 
                #dsn#_product.PRODUCT as P
                INNER JOIN #dsn#_product.STOCKS AS S ON P.PRODUCT_ID = S.PRODUCT_ID 
            WHERE
            1=1
            <cfif isdefined("arguments.FILTER") and len(arguments.FILTER)>
                AND ( P.PRODUCT_NAME = <cfqueryparam value="#arguments.FILTER#" cfsqltype="cf_sql_nvarchar">
                    OR P.PRODUCT_DETAIL = <cfqueryparam value="#arguments.FILTER#" cfsqltype="cf_sql_nvarchar">
                    OR P.PRODUCT_CODE = <cfqueryparam value="#arguments.FILTER#" cfsqltype="cf_sql_nvarchar">
                    OR P.PRODUCT_CODE_2 = <cfqueryparam value="#arguments.FILTER#" cfsqltype="cf_sql_nvarchar">
                    OR S.STOCK_CODE = <cfqueryparam value="#arguments.FILTER#" cfsqltype="cf_sql_nvarchar">
                    OR S.STOCK_CODE_2 = <cfqueryparam value="#arguments.FILTER#" cfsqltype="cf_sql_nvarchar">
                    )
            </cfif>
            <cfif isdefined("arguments.NOMINAL_DEGER") and len(arguments.NOMINAL_DEGER)>
                AND P.MIN_MARGIN <= <cfqueryparam value="#arguments.NOMINAL_DEGER#" cfsqltype="cf_sql_float">
                AND P.MAX_MARGIN >= <cfqueryparam value="#arguments.NOMINAL_DEGER#" cfsqltype="cf_sql_float">
            </cfif>
        </cfquery>
        <cfreturn get_product>
    </cffunction>

    <cffunction name="read_file" access="public">
        <cfargument name="filepath" required="true" type="string">
        <cfif isSpreadsheetFile(filepath)>
            <cfspreadsheet action="read" src="#filepath#" query="fileData">
            <cfset rowCount = fileData.recordCount>
        <cfelse>
            <cffile action="read" file="#filepath#" variable="fileData" mode="777">
            <cfscript>
                ayirac = ';';
                CRLF = Chr(13) & Chr(10);// satır atlama karakteri
                dosya = Replace(fileData,'#ayirac##ayirac#','#ayirac# #ayirac#','all');
                dosya = ListToArray(dosya,CRLF);
            </cfscript>
        </cfif>
        <cfreturn fileData>
    </cffunction>

</cfcomponent>