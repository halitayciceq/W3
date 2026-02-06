<cfcomponent>
    <cfset dsn = application.systemParam.systemParam().dsn>
    <cfset dsn3 = "#dsn#_#session.ep.company_id#">
    <cfset dsn2 = "#dsn#_#session.ep.period_year#_#session.ep.company_id#">
		<cffunction name="get_sales_by_city" returntype="query">
            <cfargument  name="city_code" default="">
            <cfargument  name="date1" default="">
            <cfargument  name="date2" default="">
            <cfquery name="get_sales_by_city" datasource="#dsn2#">
                SELECT
                    C.FULLNAME,
                    SUM(NETTOTAL) TOPLAM
                FROM
                    INVOICE I
                LEFT JOIN #dsn#.COMPANY C ON I.COMPANY_ID = C.COMPANY_ID
                LEFT JOIN #dsn#.SETUP_CITY SC ON C.CITY = SC.CITY_ID
                LEFT JOIN #dsn#.SETUP_COUNTRY SCO ON SC.COUNTRY_ID = SCO.COUNTRY_ID
                WHERE
                    C.COUNTRY IS NOT NULL
                    AND SCO.COUNTRY_CODE IS NOT NULL
                    AND C.CITY IS NOT NULL
                    AND I.NETTOTAL > 0
                    AND PURCHASE_SALES = 1 
                    AND IS_IPTAL = 0
                    AND SC.PLATE_CODE = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.city_code#">
                    <cfif len(arguments.date1)>AND I.INVOICE_DATE >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.date1#"></cfif>
                    <cfif len(arguments.date2)>AND I.INVOICE_DATE < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateAdd('d',1,arguments.date2)#"></cfif> 
                GROUP BY C.FULLNAME
                ORDER BY TOPLAM DESC
            </cfquery>
            <cfreturn get_sales_by_city>
        </cffunction>

        <cffunction name="get_sales_by_product" returntype="query">
            <cfargument  name="city_code" default="">
            <cfargument  name="date1" default="">
            <cfargument  name="date2" default="">
            <cfquery name="get_sales_by_product" datasource="#dsn2#">
                SELECT
                    IR.NAME_PRODUCT,
                    SUM(I.NETTOTAL) TOPLAM
                FROM
                    INVOICE_ROW IR
                    
                LEFT JOIN INVOICE I ON I.INVOICE_ID = IR.INVOICE_ID
                LEFT JOIN #dsn#.COMPANY C ON I.COMPANY_ID = C.COMPANY_ID
                LEFT JOIN #dsn#.SETUP_CITY SC ON C.CITY = SC.CITY_ID
                LEFT JOIN #dsn#.SETUP_COUNTRY SCO ON SC.COUNTRY_ID = SCO.COUNTRY_ID

                WHERE
                    C.COUNTRY IS NOT NULL
                    AND SCO.COUNTRY_CODE IS NOT NULL
                    AND C.CITY IS NOT NULL
                    AND I.NETTOTAL > 0
                    AND I.PURCHASE_SALES = 1 
                    AND I.IS_IPTAL = 0
                    AND SC.PLATE_CODE = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.city_code#">
                    <cfif len(arguments.date1)>AND I.INVOICE_DATE >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.date1#"></cfif>
                    <cfif len(arguments.date2)>AND I.INVOICE_DATE < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateAdd('d',1,arguments.date2)#"></cfif> 
                GROUP BY IR.NAME_PRODUCT
                ORDER BY TOPLAM DESC
            </cfquery>
            <cfreturn get_sales_by_product>
        </cffunction>

        <cffunction name="get_sales_by_product_cat" returntype="query">
            <cfargument  name="city_code" default="">
            <cfargument  name="date1" default="">
            <cfargument  name="date2" default="">
            <cfquery name="get_sales_by_product_cat" datasource="#dsn2#">
                SELECT
                    PC.PRODUCT_CAT,
                    SUM(I.NETTOTAL) TOPLAM
                FROM
                    INVOICE_ROW IR
                    
                LEFT JOIN INVOICE I ON I.INVOICE_ID = IR.INVOICE_ID
                LEFT JOIN #dsn#.COMPANY C ON I.COMPANY_ID = C.COMPANY_ID
                LEFT JOIN #dsn#.SETUP_CITY SC ON C.CITY = SC.CITY_ID
                LEFT JOIN #dsn#.SETUP_COUNTRY SCO ON SC.COUNTRY_ID = SCO.COUNTRY_ID
                JOIN #dsn3#.PRODUCT P ON P.PRODUCT_ID = IR.PRODUCT_ID
                JOIN #dsn3#.PRODUCT_CAT PC ON PC.PRODUCT_CATID = P.PRODUCT_CATID

                WHERE
                    C.COUNTRY IS NOT NULL
                    AND SCO.COUNTRY_CODE IS NOT NULL
                    AND C.CITY IS NOT NULL
                    AND I.NETTOTAL > 0
                    AND I.PURCHASE_SALES = 1 
                    AND I.IS_IPTAL = 0
                    AND SC.PLATE_CODE = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.city_code#">
                    <cfif len(arguments.date1)>AND I.INVOICE_DATE >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.date1#"></cfif>
                    <cfif len(arguments.date2)>AND I.INVOICE_DATE < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateAdd('d',1,arguments.date2)#"></cfif> 
                GROUP BY PC.PRODUCT_CAT
                ORDER BY TOPLAM DESC
            </cfquery>
            <cfreturn get_sales_by_product_cat>
        </cffunction>
</cfcomponent>