<!--- File: get_actions.cfm
Author:Canan Ebret <cananebret@workcube.com>
Date: 27.08.2019
Controller: -
Description: Abone detay sayfasinda diger tab menusu nun icinde operasyonlar ile ilgili query icin olusturulmustur.​ --->
<cfcomponent>
    <cfset dsn = application.systemParam.systemParam().dsn>
    <cfset dsn3 = "#dsn#_#session.ep.company_id#">
    <cffunction name="GetPeriod" access="public" returntype="query">
        <cfquery name="get_period" datasource="#dsn#">
            SELECT 
                PERIOD_ID, 
                PERIOD_YEAR, 
                OUR_COMPANY_ID
            FROM 
                SETUP_PERIOD 
            WHERE 
               OUR_COMPANY_ID = #session.ep.company_id# 
            ORDER BY PERIOD_YEAR DESC
        </cfquery> 
        <cfreturn get_period>
    </cffunction> 
    <cffunction name="GetSubscription" access="public" returntype="query">
        <cfargument name="subscription_id" default="">
        <cfquery name="get_subscription" datasource="#dsn3#">
            SELECT 
               COMPANY_ID,
               CONSUMER_ID,
               INVOICE_COMPANY_ID,
               INVOICE_CONSUMER_ID,
               SUBSCRIPTION_NO,
               PARTNER_ID
            FROM 
               SUBSCRIPTION_CONTRACT 
            WHERE 
               SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_id#">
        </cfquery>
        <cfreturn get_subscription>
    </cffunction>
</cfcomponent>


