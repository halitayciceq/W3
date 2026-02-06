
<!---
    Author : Fatma Zehra Dere
    Create Date : 23/03/2024
--->
<cfcomponent extends="cfc.sdFunctions">
    <cfset dsn = dsn = application.systemParam.systemParam().dsn>
    <cfset dsn1 = dsn_product = dsn1_alias = '#dsn#_product' />
    <cfset dsn2 = dsn2_alias = '#dsn#_#session.ep.period_year#_#session.ep.company_id#' />
    <cfset dsn3 = dsn3_alias = '#dsn#_#session.ep.company_id#' />
    <cffunction name="get_opportunity_orders" access="remote"  output="false">
        <cfargument name="opp_id" type="numeric" required="true">
        <cfquery name="get_opportunity_orders" datasource="#DSN3#">
            SELECT
                *
            FROM
                ORDERS
            WHERE
            OPP_ID = <cfqueryparam value="#arguments.opp_id#" cfsqltype="cf_sql_integer"> 
        </cfquery>
     <cfreturn get_opportunity_orders/>
    </cffunction>
    <cffunction name="upd_orders_opp" access="remote"  output="false">
        <cfargument name="ORDER_ID" type="numeric" required="true">
        <cfquery name="del_orders_opp_query" datasource="#dsn3#">
            UPDATE ORDERS
            SET OPP_ID = NULL
            WHERE ORDER_ID = <cfqueryparam value="#arguments.ORDER_ID#" cfsqltype="cf_sql_integer">
        </cfquery>
    </cffunction>
    <cffunction name="del_orders_opp" access="remote"  output="false">
        <cfargument name="ORDER_ID" type="numeric" required="true">
        <cfargument name="opp_id" type="numeric" required="true">
        <cfquery name="UPD_order" datasource="#DSN3#">
            UPDATE
                ORDERS
            SET
                OPP_ID  = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.opp_id#">
            WHERE
                ORDER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.order_id#">
        </cfquery>
        <cfquery name="select_opp_off" datasource="#DSN3#">
            select WRK_ROW_ID,WRK_ROW_RELATION_ID,QUANTITY from ORDERS O, ORDER_ROW OP WHERE O.ORDER_ID = OP.ORDER_ID AND OP.ORDER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.order_id#"> GROUP BY WRK_ROW_ID,WRK_ROW_RELATION_ID,QUANTITY
        </cfquery>
        <cfscript>
            add_relation_rows(
                action_type:'add',
                action_dsn : '#dsn3#',
                to_table:'OPPORTUNITIES',
                to_action_id : attributes.opp_id,
                to_wrk_row_id : select_opp_off.wrk_row_id,
                from_table : 'ORDERS',
                from_action_id : attributes.order_id,
                from_wrk_row_id : select_opp_off.wrk_row_relation_id,
                amount : select_opp_off.quantity
                );
        </cfscript>
    </cffunction>
    <cffunction name="get_order_list_fnc"  access="remote"  output="false">
        <cfargument name="currency_id" default=""/>
        <cfargument name="order_employee_id" default=""/>
        <cfargument name="order_employee" default=""/>
        <cfargument name="status" default=""/>
        <cfargument name="keyword" default=""/>
        <cfargument name="keyword_orderno" default=""/> 
        <cfargument name="order_stage" default=""/>
        <cfargument name="zone_id" default=""/>
        <cfargument name="startrow" default="">
        <cfargument name="maxrows" default="">
        <cfquery name="GET_ORDER_LIST" datasource="#dsn3#">
            SELECT DISTINCT
                ORDERS.NETTOTAL,
                ORDERS.TAXTOTAL,
                ORDERS.OTHER_MONEY_VALUE,
                ORDERS.OTHER_MONEY,
                ORDERS.SALES_ADD_OPTION_ID,
                ORDERS.CITY_ID,
                ORDERS.OFFER_ID,
                ORDERS.ORDER_ID,
                COM.NICKNAME COMPANY_NAME,
                ORDERS.ORDER_NUMBER,
                ORDERS.REF_NO,
                ORDERS.ORDER_CURRENCY,
                ORDERS.ORDER_HEAD,
                ORDERS.TAX,
                ORDERS.PRIORITY_ID,
                ORDERS.COMMETHOD_ID,
                ORDERS.GROSSTOTAL, 
                ORDERS.DELIVERDATE, 
                ORDERS.ORDER_ZONE, 
                (SELECT EMPLOYEE_NAME FROM #dsn#.EMPLOYEES WHERE EMPLOYEES.EMPLOYEE_ID = ORDERS.ORDER_EMPLOYEE_ID) AS ORDER_EMPLOYEE_NAME,
                (SELECT EMPLOYEE_SURNAME FROM #dsn#.EMPLOYEES WHERE EMPLOYEES.EMPLOYEE_ID = ORDERS.ORDER_EMPLOYEE_ID) AS ORDER_EMPLOYEE_SURNAME,
                ORDERS.ORDER_EMPLOYEE_ID,
                ORDERS.ORDER_DATE,
                ORDERS.ORDER_STAGE
         FROM 			
            
             ORDERS WITH (NOLOCK)
           
             LEFT JOIN 
                 (#dsn#.COMPANY_PARTNER CP INNER JOIN #dsn#.COMPANY COM ON CP.COMPANY_ID = COM.COMPANY_ID)
                 ON CP.PARTNER_ID = ORDERS.PARTNER_ID
             LEFT JOIN #dsn#.CONSUMER C ON C.CONSUMER_ID = ORDERS.CONSUMER_ID	
             LEFT JOIN #dsn#.EMPLOYEES E ON E.EMPLOYEE_ID = ORDERS.RECORD_EMP
             LEFT JOIN CREDITCARD_PAYMENT_TYPE CPT ON ORDERS.CARD_PAYMETHOD_ID = CPT.PAYMENT_TYPE_ID
             LEFT JOIN #dsn#.SETUP_PAYMETHOD SP ON ORDERS.PAYMETHOD = SP.PAYMETHOD_ID
         WHERE 
             ((ORDERS.PURCHASE_SALES = 1 AND ORDERS.ORDER_ZONE = 0) OR (ORDERS.PURCHASE_SALES = 0 AND ORDERS.ORDER_ZONE = 1) )
             <cfif isDefined("arguments.keyword") and len(arguments.keyword)>
                AND
				(
					ORDERS.ORDER_HEAD LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#trim(arguments.keyword)#%"> COLLATE SQL_Latin1_General_CP1_CI_AI OR
					ORDERS.ORDER_NUMBER LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#trim(arguments.keyword)#%">OR	
					ORDERS.REF_NO LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#trim(arguments.keyword)#%">
				)
			</cfif>
            <cfif isdefined('arguments.order_stage') and len(arguments.order_stage)>
				AND ORDERS.ORDER_STAGE = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.order_stage#">
			</cfif>
            <cfif isDefined("arguments.keyword_orderno") and len(arguments.keyword_orderno)>
			     AND ORDERS.ORDER_NUMBER LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#trim(arguments.keyword_orderno)#%">
			</cfif>
            <cfif isDefined("status") and len(status)>
				AND ORDERS.ORDER_STATUS = <cfqueryparam cfsqltype="cf_sql_smallint" value="#status#">
			</cfif>
            ORDER BY ORDER_ID DESC
        </cfquery>
        <cfreturn GET_ORDER_LIST/>
    </cffunction>
    <cffunction name="get_process_type"  access="remote"  output="false">
        <cfquery name="get_process_type" datasource="#DSN#">
            SELECT
                PTR.STAGE,
                PTR.PROCESS_ROW_ID,
                PT.PROCESS_NAME,
                PT.PROCESS_ID
            FROM
                PROCESS_TYPE_ROWS PTR,
                PROCESS_TYPE_OUR_COMPANY PTO,
                PROCESS_TYPE PT
            WHERE
                PT.IS_ACTIVE = 1 AND
                PT.PROCESS_ID = PTR.PROCESS_ID AND
                PT.PROCESS_ID = PTO.PROCESS_ID AND
                PTO.OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#"> AND
                PT.FACTION LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%sales.list_order%">
                AND PT.FACTION NOT LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%sales.list_order_instalment%">
            
            ORDER BY
                PT.PROCESS_NAME,
                PTR.LINE_NUMBER
        </cfquery>
        <cfreturn get_process_type/>
    </cffunction>
</cfcomponent>