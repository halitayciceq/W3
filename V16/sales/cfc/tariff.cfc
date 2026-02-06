<cfcomponent>
    <cfset dsn = application.systemParam.systemParam().dsn>
    <cfset DSN3 = "#dsn#_#session.ep.company_id#">
    <cfset LastId = "">
    <cffunction name="addTariffProduct" returntype="any">
        <cfargument name="tariff_name">
        <cfargument name="stock_id" type="numeric">
        <cfargument name="product_id" type="numeric">
        <cfargument name="unit_id" type="numeric">
        <cfargument name="product_unit">
        <cfargument name="price_list">
        <cfargument name="tariff_price" type="numeric">
        <cfargument name="money">
        <cfquery name="addTariff" datasource="#DSN3#" result="result">
            INSERT INTO SUBSCRIPTION_TARIFF 
            (
                TARIFF_NAME,
                STOCK_ID,
                PRODUCT_ID,
                PRODUCT_UNIT_ID,
                PRODUCT_UNIT,
                PRICE_LIST,
                TARIFF_PRICE,
                MONEY_TYPE,
                IS_ACTIVE,
                RECORD_DATE,
                RECORD_EMP,
                RECORD_IP
            )
            VALUES(
                <cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.tariff_name#">,
                <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.stock_id#">,
                <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.product_id#">,
                <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.unit_id#">,
                <cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.product_unit#">,
                <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.price_list#">,
                <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tariff_price#">,
                <cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.money#">,
                1,
                #now()#,
                #session.ep.userid#,
                '#cgi.remote_addr#'
            ) 
        </cfquery>
        <cfset LastId = result.IDENTITYCOL>
        <cfreturn LastId>
    </cffunction>
    <cffunction name="additional_product" returntype="any">
        <cfquery name="additional_product" datasource="#DSN3#">
            INSERT INTO SUBSCRIPTION_ADDITIONAL_PRODUCT
            (
                TARIFF_ID,
                STOCK_ID,
                PRODUCT_ID,
                CAL_METHOD,
                NUMBER,
                PRICE_LIST,
                SPECIAL_PRICE,
                MONEY_TYPE
            )
            VALUES 
            (
                <cfqueryparam cfsqltype="cf_sql_integer" value="#LastId#">,
                <cfif len(arguments.stock_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.stock_id#"><cfelse>NULL</cfif>,
                <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.product_id#">,
                <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.hesaplama#">,
                <cfif len(arguments.urun_rakam)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.urun_rakam#"><cfelse>NULL</cfif>,
                <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.fiyatListesi#">,
                <cfif len(arguments.ozel_fiyat)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.ozel_fiyat#"><cfelse>NULL</cfif>,
                <cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.money#">
            )
        </cfquery>     
    </cffunction>
    <cffunction name="tax_and_fund" returntype="any">
        <cfquery name="tax_and_fund" datasource="#DSN3#">
            INSERT INTO SUBSCRIPTION_TAX_FUNDS
            (
                TARIFF_ID,
                ACCOUNT_CODE,
                CAL_METHOD,
                NUMBER,
                PRICE,
                MONEY_TYPE
            )
            VALUES 
            (
                <cfqueryparam cfsqltype="cf_sql_integer" value="#LastId#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.account_code#">,
                <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.hesaplamaTax#">,
                <cfif len(arguments.rakamTax)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.rakamTax#"><cfelse>NULL</cfif>,
                <cfif len(arguments.tutar)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.tutar#"><cfelse>NULL</cfif>,
                <cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.moneyTax#">
            )
        </cfquery>     
    </cffunction>
    <cffunction name="updTariffProduct" returntype="any">
        <cfargument name="tariff_id" type="numeric">
        <cfargument name="active" type="numeric">
        <cfargument name="tariff_name">
        <cfargument name="stock_id" type="numeric">
        <cfargument name="product_id" type="numeric">
        <cfargument name="unit_id" type="numeric">
        <cfargument name="product_unit">
        <cfargument name="price_list">
        <cfargument name="tariff_price">
        <cfargument name="money">
        <cfquery name="updTariff" datasource="#DSN3#" result="result">
            UPDATE 
                SUBSCRIPTION_TARIFF
            SET
                TARIFF_NAME = <cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.tariff_name#">,
                STOCK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.stock_id#">,
                PRODUCT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.product_id#">,
                PRODUCT_UNIT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.unit_id#">,
                PRODUCT_UNIT = <cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.product_unit#">,
                PRICE_LIST = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.price_list#">,
                TARIFF_PRICE = <cfqueryparam cfsqltype="cf_sql_float" value="#arguments.tariff_price#">,
                MONEY_TYPE = <cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.money#">,
                IS_ACTIVE = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.active#">,
                UPDATE_DATE = #now()#,
                UPDATE_EMP = #session.ep.userid#,
                UPDATE_IP = '#cgi.remote_addr#'
            WHERE
                TARIFF_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tariff_id#">
        </cfquery>
        <cfreturn 1>
    </cffunction>
    <cffunction  name="upd_additional_product" returntype="any">
        <cfif len(arguments.additional_id)>
            <cfquery name="upd_additional_product" datasource="#DSN3#">
                UPDATE 
                    SUBSCRIPTION_ADDITIONAL_PRODUCT
                SET
                    STOCK_ID = <cfif len(arguments.stock_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.stock_id#"><cfelse>NULL</cfif>,
                    PRODUCT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.product_id#">,
                    CAL_METHOD = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.hesaplama#">,
                    NUMBER = <cfif len(arguments.urun_rakam)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.urun_rakam#"><cfelse>NULL</cfif>,
                    PRICE_LIST = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.fiyatListesi#">,
                    SPECIAL_PRICE = <cfif len(arguments.ozel_fiyat)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.ozel_fiyat#"><cfelse>NULL</cfif>,
                    MONEY_TYPE = <cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.money#">
                WHERE
                    ADDITIONAL_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.additional_id#">
            </cfquery> 
        <cfelse>
            <cfquery name="add_additional_product" datasource="#DSN3#">
                INSERT INTO SUBSCRIPTION_ADDITIONAL_PRODUCT
                (
                    TARIFF_ID,
                    STOCK_ID,
                    PRODUCT_ID,
                    CAL_METHOD,
                    NUMBER,
                    PRICE_LIST,
                    SPECIAL_PRICE,
                    MONEY_TYPE
                )
                VALUES 
                (
                    <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tariff_id#">,
                    <cfif len(arguments.stock_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.stock_id#"><cfelse>NULL</cfif>,
                    <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.product_id#">,
                    <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.hesaplama#">,
                    <cfif len(arguments.urun_rakam)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.urun_rakam#"><cfelse>NULL</cfif>,
                    <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.fiyatListesi#">,
                    <cfif len(arguments.ozel_fiyat)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.ozel_fiyat#"><cfelse>NULL</cfif>,
                    <cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.money#">
                )
            </cfquery>
        </cfif>
        <cfreturn 1>
    </cffunction>
    <cffunction name="del_additional_product" returntype="any">
        <cfif len(arguments.additional_id)>
            <cfquery name="del_additional_product" datasource="#DSN3#">
                DELETE FROM
                    SUBSCRIPTION_ADDITIONAL_PRODUCT
                WHERE
                    ADDITIONAL_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.additional_id#">
            </cfquery>
        </cfif>
    </cffunction>
    <cffunction name="upd_tax_fund" returntype="any">
        <cfif len(arguments.tax_funds_id)>
            <cfquery name="upd_tax_funds" datasource="#DSN3#">
                UPDATE 
                    SUBSCRIPTION_TAX_FUNDS
                SET
                    ACCOUNT_CODE = <cfif len(arguments.account_code)><cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.account_code#"><cfelse>NULL</cfif>,
                    CAL_METHOD = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.hesaplamaTax#">,
                    NUMBER = <cfif len(arguments.rakamTax)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.rakamTax#"><cfelse>NULL</cfif>,
                    PRICE = <cfif len(arguments.tutar)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.tutar#"><cfelse>NULL</cfif>,
                    MONEY_TYPE = <cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.moneyTax#">
                WHERE
                    TAX_FUNDS_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tax_funds_id#">
            </cfquery> 
        <cfelse>
            <cfquery name="add_tax_funds" datasource="#DSN3#">
                INSERT INTO SUBSCRIPTION_TAX_FUNDS
                (
                    TARIFF_ID,
                    ACCOUNT_CODE,
                    CAL_METHOD,
                    NUMBER,
                    PRICE,
                    MONEY_TYPE
                )
                VALUES 
                (
                    <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tariff_id#">,
                    <cfif len(arguments.account_code)><cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.account_code#"><cfelse>NULL</cfif>,
                    <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.hesaplamaTax#">,
                    <cfif len(arguments.rakamTax)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.rakamTax#"><cfelse>NULL</cfif>,
                    <cfif len(arguments.tutar)><cfqueryparam cfsqltype="cf_sql_float" value="#arguments.tutar#"><cfelse>NULL</cfif>,
                    <cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.moneyTax#">
                )
            </cfquery>
        </cfif>
        <cfreturn 1>
    </cffunction>
    <cffunction name="del_tax_fund" returntype="any">
        <cfif len(arguments.tax_funds_id)>
            <cfquery name="del_tax_fund" datasource="#DSN3#">
                DELETE FROM
                    SUBSCRIPTION_TAX_FUNDS
                WHERE
                    TAX_FUNDS_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tax_funds_id#">
            </cfquery>
        </cfif>
    </cffunction>
    <cffunction name="delTariffProduct" returntype="any">
        <cfquery name="delTariffProduct" datasource="#DSN3#">
            DELETE FROM
                SUBSCRIPTION_TARIFF
            WHERE
                TARIFF_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tariff_id#">
        </cfquery>
        <cfquery name="del_additional_product" datasource="#DSN3#">
            DELETE FROM
                SUBSCRIPTION_ADDITIONAL_PRODUCT
            WHERE
                TARIFF_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tariff_id#">
        </cfquery>
        <cfquery name="del_tax_funds" datasource="#DSN3#">
            DELETE FROM
                SUBSCRIPTION_TAX_FUNDS
            WHERE
                TARIFF_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tariff_id#">
        </cfquery>
    </cffunction>
    <cffunction name="list_tariff" returntype="query">
        <cfargument name="keyword" default="">
        <cfargument name="main_product" default="">
        <cfargument name="work_status" default="">
        <cfquery name="list_tariff" datasource="#DSN3#">
            SELECT 
                P.PRODUCT_NAME, ST.TARIFF_ID, ST.PRODUCT_ID, ST.TARIFF_NAME, ST.PRICE_LIST, ST.TARIFF_PRICE, ST.IS_ACTIVE, ST.UPDATE_DATE, PC.PRICE_CAT, PC.PRICE_CATID
            FROM 
                SUBSCRIPTION_TARIFF AS ST
            LEFT JOIN PRODUCT AS P
            ON ST.PRODUCT_ID = P.PRODUCT_ID 
            LEFT JOIN PRICE_CAT AS PC
            ON ST.PRICE_LIST = PC.PRICE_CATID
            WHERE
                1=1
                <cfif len(arguments.keyword)> AND TARIFF_NAME LIKE <cfqueryparam cfsqltype='cf_sql_nvarchar' value="%#arguments.keyword#%"></cfif>
                <cfif len(arguments.main_product)> AND P.PRODUCT_ID = <cfqueryparam cfsqltype='cf_sql_integer' value="#arguments.main_product#"></cfif>
                <cfif len(arguments.work_status)> AND IS_ACTIVE = <cfqueryparam cfsqltype='cf_sql_integer' value="#arguments.work_status#"></cfif>
        </cfquery>
        <cfreturn list_tariff>
    </cffunction>
</cfcomponent>