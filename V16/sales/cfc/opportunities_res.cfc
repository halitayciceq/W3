<cfcomponent>
    <cfset dsn = application.SystemParam.SystemParam().dsn>
    <cfif isdefined("session.ep")>
        <cfset dsn3 = "#dsn#_#session.ep.company_id#">
        <cfset userid = "#session.ep.userid#">
    <cfelseif isdefined("session.pp")>
        <cfset dsn3 = "#dsn#_#session.pp.our_company_id#">
    <cfelseif isdefined("session.ww")>
        <cfset dsn3 = "#dsn#_#session.ww.our_company_id#">
    </cfif>
    <cffunction name="GET_OPP" returntype="query" access="remote">
        <cfargument name="opportunity_type_id" default="">
        <cfquery name="GET_OPP" datasource="#dsn3#">
            SELECT * FROM OPPORTUNITIES WHERE OPP_STATUS = 1 <cfif listlen(arguments.opportunity_type_id)>AND OPPORTUNITY_TYPE_ID IN (#arguments.opportunity_type_id#)</cfif>
        </cfquery>
        <cfreturn GET_OPP>
    </cffunction>

    <cffunction name="GET_TOTAL" returntype="query" access="remote">
        <cfquery name="GET_TOTAL" dbtype="query">
            SELECT SUM(INCOME) TOTAL,MONEY FROM GET_OPP  WHERE MONEY IS NOT NULL GROUP BY MONEY
        </cfquery>
        <cfreturn GET_TOTAL>
    </cffunction>

    <cffunction name="GET_ACTIVE" returntype="query" access="remote">
        <cfquery name="GET_ACTIVE" dbtype="query">
            SELECT COUNT(*) AS TOTAL_COUNT FROM GET_OPP
        </cfquery>
        <cfreturn GET_ACTIVE>
    </cffunction>

    <cffunction name="GET_ASSIGNMENT_STATUS" returntype="query" access="remote">
        <cfquery name="GET_ASSIGNMENT_STATUS" dbtype="query">
            SELECT COUNT(*) AS TOTAL_COUNT FROM GET_OPP WHERE ((SALES_EMP_ID IS NULL) OR (SALES_PARTNER_ID IS NULL AND SALES_CONSUMER_ID IS NULL))
        </cfquery>
        <cfreturn GET_ASSIGNMENT_STATUS>
    </cffunction>

    <cffunction name="GET_KUR" returntype="query" access="remote">
        <cfquery name="GET_KUR" datasource="#dsn#">
            SELECT MONEY,RATE1,RATE2 FROM SETUP_MONEY WHERE COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#"> AND PERIOD_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.period_id#"> AND MONEY_STATUS = 1
        </cfquery>
        <cfreturn GET_KUR>
    </cffunction>

    <cffunction name="GET_OPP_COUNT_BY_PARTNER" returntype="query" access="remote">
        <cfquery name="GET_OPP_COUNT_BY_PARTNER" datasource="#dsn3#">
            SELECT
                CP.COMPANY_ID COMPANY_ID,
                COUNT(*) COUNT_OPP
            FROM
                OPPORTUNITIES O
                LEFT JOIN #dsn#.COMPANY_PARTNER CP ON CP.PARTNER_ID = O.SALES_PARTNER_ID

            WHERE
                O.SALES_PARTNER_ID IS NOT NULL
                AND O.INCOME IS NOT NULL
                AND O.MONEY IS NOT NULL
                AND O.OPP_STATUS = 1

            GROUP BY
                CP.COMPANY_ID
                
            UNION ALL

            SELECT
                SALES_CONSUMER_ID COMPANY_ID,
                COUNT(*) COUNT_OPP
            FROM
                OPPORTUNITIES
            WHERE
                SALES_CONSUMER_ID IS NOT NULL
                AND INCOME IS NOT NULL
                AND MONEY IS NOT NULL
                AND OPP_STATUS = 1

            GROUP BY
                SALES_CONSUMER_ID
        </cfquery>
        <cfreturn GET_OPP_COUNT_BY_PARTNER>
    </cffunction>

    <cffunction name="GET_OPP_BY_PARTNER" returntype="query" access="remote">
        <cfquery name="GET_OPP_BY_PARTNER" datasource="#dsn3#">
            SELECT
                CP.COMPANY_ID COMPANY_ID,
                O.MONEY,
                O.INCOME,
                'PARTNER' TYPE
            FROM
                OPPORTUNITIES O
                LEFT JOIN #dsn#.COMPANY_PARTNER CP ON CP.PARTNER_ID = O.SALES_PARTNER_ID
            WHERE
                O.SALES_PARTNER_ID IS NOT NULL
                AND O.INCOME IS NOT NULL
                AND O.MONEY IS NOT NULL
                AND O.OPP_STATUS = 1

            UNION ALL

            SELECT
                SALES_CONSUMER_ID COMPANY_ID,
                MONEY,
                INCOME,
                'CONSUMER' TYPE

            FROM
                OPPORTUNITIES
            WHERE
                SALES_CONSUMER_ID IS NOT NULL
                AND INCOME IS NOT NULL
                AND MONEY IS NOT NULL
                AND OPP_STATUS = 1
        </cfquery>
        <cfreturn GET_OPP_BY_PARTNER>
    </cffunction>

    <cffunction name="GET_OPP_COUNT_BY_EMPLOYEE" returntype="query" access="remote">
        <cfquery name="GET_OPP_COUNT_BY_EMPLOYEE" dbtype="query">
            SELECT
                SALES_EMP_ID,
                COUNT(*) COUNT_OPP
            FROM
                GET_OPP
            WHERE
                SALES_EMP_ID IS NOT NULL
                AND INCOME IS NOT NULL
                AND MONEY IS NOT NULL
            GROUP BY
                SALES_EMP_ID
        </cfquery>
        <cfreturn GET_OPP_COUNT_BY_EMPLOYEE>
    </cffunction>

    <cffunction name="GET_OPP_BY_EMPLOYEE" returntype="query" access="remote">
        <cfquery name="GET_OPP_BY_EMPLOYEE" dbtype="query">
            SELECT
                SALES_EMP_ID,
                INCOME,
                MONEY
            FROM
                GET_OPP
            WHERE
                SALES_EMP_ID IS NOT NULL
                AND INCOME IS NOT NULL
                AND MONEY IS NOT NULL
            GROUP BY
                SALES_EMP_ID,MONEY,INCOME
        </cfquery>
        <cfreturn GET_OPP_BY_EMPLOYEE>
    </cffunction>

    <cffunction name="GET_OPP_COUNT_BY_CITY" returntype="query" access="remote">
        <cfquery name="GET_OPP_COUNT_BY_CITY" datasource="#dsn3#">
            SELECT
                C.CITY,
                COUNT(*) COUNT_OPP
            FROM
                OPPORTUNITIES O
            LEFT JOIN #dsn#.COMPANY C ON C.COMPANY_ID = O.COMPANY_ID 
            WHERE
                O.COMPANY_ID IS NOT NULL
                AND C.CITY IS NOT NULL
                AND O.INCOME IS NOT NULL
                AND O.MONEY IS NOT NULL
                AND O.OPP_STATUS = 1
            GROUP BY C.CITY   
        </cfquery>
        <cfreturn GET_OPP_COUNT_BY_CITY>
    </cffunction>

    <cffunction name="GET_OPP_BY_CITY" returntype="query" access="remote">
        <cfquery name="GET_OPP_BY_CITY" datasource="#dsn3#">
            SELECT
                C.CITY,
                O.INCOME,
                MONEY
            FROM
                OPPORTUNITIES O
            LEFT JOIN #dsn#.COMPANY C ON C.COMPANY_ID = O.COMPANY_ID 
            WHERE
                O.COMPANY_ID IS NOT NULL
                AND C.CITY IS NOT NULL
                AND O.INCOME IS NOT NULL
                AND O.MONEY IS NOT NULL
                AND O.OPP_STATUS = 1
            GROUP BY
                C.CITY,MONEY,INCOME   
        </cfquery>
        <cfreturn GET_OPP_BY_CITY>
    </cffunction>

    <cffunction name="get_other_money" returntype="query" access="remote">
        <cfparam name="money_type">
        <cfquery name="GET_KUR" datasource="#dsn#">
            SELECT 
                MONEY,
                RATE1,
                RATE2
            FROM
                SETUP_MONEY
            WHERE
                COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#">
                AND PERIOD_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.period_id#">
                AND MONEY_STATUS = 1
                AND MONEY = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.money_type#">
        </cfquery>
        <cfreturn GET_KUR>
    </cffunction>
</cfcomponent>