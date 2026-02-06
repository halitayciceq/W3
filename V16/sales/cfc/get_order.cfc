<cfcomponent>
    <cfset dsn = application.systemParam.systemParam().dsn>
    <cfset dsn3_alias = "#dsn#_#session.ep.company_id#">
    <cffunction name="Get_Order" returntype="any">
        <cfargument name="Order_id" type="numeric">
        <cfquery name="Get_Order" datasource="#dsn#">
            SELECT 
                O.DELIVERDATE,
                O.SHIP_METHOD,
                O.ORDER_NUMBER,
                O.ORDER_DATE,
                O.ORDER_EMPLOYEE_ID,
                O.SHIP_ADDRESS,
                O.PAYMETHOD,
                O.ORDER_DETAIL,
                O.ORDER_ID,
                O.OTHER_MONEY,
                C.FULLNAME,            
                C.COMPANY_TEL1,
                C.COMPANY_TELCODE,             
                CP.COMPANY_PARTNER_NAME,
                CP.COMPANY_PARTNER_SURNAME,
                SHIP_METHOD.SHIP_METHOD AS SHIP_METHOD_
               FROM 
                #dsn3_alias#.ORDERS O 
                LEFT JOIN COMPANY C ON C.COMPANY_ID = O.COMPANY_ID
                LEFT JOIN COMPANY_PARTNER CP ON CP.COMPANY_ID = C.COMPANY_ID AND CP.PARTNER_ID = O.PARTNER_ID
                LEFT JOIN SHIP_METHOD ON SHIP_METHOD_ID =  O.SHIP_METHOD
            WHERE ORDER_ID IN (  <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.order_id#">)
        </cfquery>
        <cfreturn Get_Order>
    </cffunction>
    <cffunction name="Our_Company" returntype="any">
        <cfquery name="Our_Company" datasource="#dsn#">
            SELECT 
                ASSET_FILE_NAME3,
                ASSET_FILE_NAME3_SERVER_ID,
                COMPANY_NAME,
                TEL_CODE,
                TEL,TEL2,
                TEL3,
                TEL4,
                FAX,
                TAX_OFFICE,
                TAX_NO,
                ADDRESS,
                WEB,
                EMAIL
            FROM 
               OUR_COMPANY 
            WHERE 
            <cfif isDefined("session.ep.company_id") and len(session.ep.company_id)>
                COMP_ID = #session.ep.company_id#
            <cfelseif isDefined("session.pp.company") and len(session.pp.company)>	
                COMP_ID = #session.pp.company#
            <cfelseif isDefined("session.ww.our_company_id") and len(session.ww.our_company_id)>
				COMP_ID = #session.ww.our_company_id#
			<cfelseif isDefined("session.cp.our_company_id") and len(session.cp.our_company_id)>
				COMP_ID = #session.cp.our_company_id#
            </cfif>
        </cfquery>
        <cfreturn Our_Company>
    </cffunction>
    <cffunction name="GetPaymethod" returntype="any">
        <cfargument name="Paymethod" default="">
        <cfquery name="GetPaymethod" datasource="#dsn#">
            SELECT 
                PAYMETHOD 
            FROM 
                SETUP_PAYMETHOD 
            WHERE 
                PAYMETHOD_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Paymethod#">
        </cfquery>
        <cfreturn GetPaymethod>
    </cffunction>
    <cffunction name="GetMoney" returntype="any">
        <cfargument name="action_id" default="">
        <cfargument name="other_money" default="">
        <cfquery name="GetMoney" datasource="#dsn#">
            SELECT 
                RATE1,
                RATE2,
                MONEY_TYPE,
                IS_SELECTED
            FROM 
            #dsn3_alias#.ORDER_MONEY 
            WHERE 
                ACTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.action_id#"> AND
                MONEY_TYPE = <cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.other_money#">
        </cfquery>
        <cfreturn GetMoney>
    </cffunction>
    <cffunction name="GetOrderRow" returntype="any">
        <cfargument name="order_id" default="">
        <cfquery name="GetOrderRow" datasource="#dsn#">
            SELECT
                ORR.*,
                S.PROPERTY,
                S.STOCK_CODE,
                S.BARCOD,
                S.MANUFACT_CODE,
                S.IS_INVENTORY,
                S.IS_PRODUCTION
            FROM
                #dsn3_alias#.ORDER_ROW ORR,
                #dsn3_alias#.STOCKS S
            WHERE
                ORR.ORDER_ID IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.order_id#">)
                AND
                ORR.STOCK_ID = S.STOCK_ID
            ORDER BY
                ORR.ORDER_ROW_ID
        </cfquery>
        <cfreturn GetOrderRow>
    </cffunction>
    <cffunction name="GetUpperPosition" returntype="any">
        <cfquery name="GetUpperPosition" datasource="#dsn#">
            SELECT UPPER_POSITION_CODE FROM EMPLOYEE_POSITIONS WHERE EMPLOYEE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#SESSION.EP.USERID#">
        </cfquery>
        <cfreturn GetUpperPosition>
    </cffunction>
    <cffunction name="GetChiefName" returntype="any">
        <cfargument name="upper_position_code" default="">
        <cfquery name="GetChiefName" datasource="#dsn#">
            SELECT EMPLOYEE_NAME,EMPLOYEE_SURNAME FROM EMPLOYEE_POSITIONS WHERE POSITION_CODE = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.upper_position_code#">
        </cfquery>
        <cfreturn GetChiefName>
    </cffunction>
</cfcomponent>