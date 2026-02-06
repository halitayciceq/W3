<cfquery name="GET_COUNTER_TYPES" datasource="#DSN3#">
	SELECT
		SC.COUNTER_ID,
		SC.COUNTER_NO,
		SC.PRODUCT_ID,
		SC.STOCK_ID,
		SC.UNIT,
		SC.UNIT_ID,
		SC.PRICE,
		SC.OTHER_MONEY,
		SC.AMOUNT,
		SCT.COUNTER_TYPE_ID,
		SCT.COUNTER_TYPE,
		SC.COMPANY_ID,
		P.PRODUCT_NAME,
		C.FULLNAME,
		(SELECT TOP 1 MONEY_ID FROM #dsn#.SETUP_MONEY WHERE SC.OTHER_MONEY = MONEY AND MONEY_STATUS = 1 ORDER BY MONEY_ID DESC) AS MONEY_ID
	FROM 
		SUBSCRIPTION_COUNTER SC
		LEFT JOIN #dsn#.COMPANY AS C ON C.COMPANY_ID = SC.COMPANY_ID
		LEFT JOIN #dsn#_product.PRODUCT AS P ON SC.PRODUCT_ID = P.PRODUCT_ID,
		SETUP_COUNTER_TYPE SCT 
	WHERE
    	<cfif isdefined('attributes.subscription_id') and len(attributes.subscription_id)>
			SC.SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.subscription_id#"> AND
        <cfelseif isdefined('attributes.cpid') and len(attributes.cpid)>
        	SC.COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.cpid#"> AND
		<cfelseif isdefined('attributes.counter_id') and len(attributes.counter_id)>
        	SC.COUNTER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.counter_id#"> AND
        <cfelse>
        	SC.CONSUMER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.cid#"> AND
        </cfif>
		SC.COUNTER_TYPE_ID = SCT.COUNTER_TYPE_ID
	ORDER BY
		SC.COUNTER_ID
</cfquery>
<cfquery name="GET_COUNTER_INVOICE" datasource="#DSN3#">
	SELECT
		SC.COUNTER_ID,
		SC.COUNTER_NO,
		SC.PRODUCT_ID,
		SC.STOCK_ID,
		SC.UNIT,
		SC.UNIT_ID,
		SC.PRICE,
		SC.OTHER_MONEY,
		SC.AMOUNT,
		SM.MONEY_ID,
		SCT.COUNTER_TYPE_ID,
		SCT.COUNTER_TYPE,
		P.PRODUCT_NAME
	FROM 
		SUBSCRIPTION_COUNTER SC
		LEFT JOIN #dsn#_product.PRODUCT AS P ON SC.PRODUCT_ID = P.PRODUCT_ID
		JOIN #dsn#.SETUP_MONEY AS SM ON SC.OTHER_MONEY = SM.MONEY,
		SETUP_COUNTER_TYPE SCT
	WHERE
		<cfif isdefined('attributes.subscription_id') and len(attributes.subscription_id)>
			SC.SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.subscription_id#"> AND
        <cfelseif isdefined('attributes.cpid') and len(attributes.cpid)>
        	SC.COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.cpid#"> AND
		<cfelseif isdefined('attributes.counter_id') and len(attributes.counter_id)>
        	SC.COUNTER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.counter_id#"> AND
        <cfelse>
        	SC.CONSUMER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.cid#"> AND
        </cfif>
		SC.COUNTER_TYPE_ID = SCT.COUNTER_TYPE_ID AND
		SC.IS_INVOICE = 1
	ORDER BY
		SC.COUNTER_ID
</cfquery>

