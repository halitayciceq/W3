<cfquery name="get_order" datasource="#dsn2#">
	SELECT * FROM #dsn3_alias#.ORDERS WHERE ORDER_ID = #attributes.ORDER_ID#
</cfquery>
<cfquery name="get_order_row" datasource="#dsn2#">
	SELECT * FROM #dsn3_alias#.ORDER_ROW WHERE ORDER_ID = #attributes.ORDER_ID#
</cfquery>
<cfquery name="add_order_history" datasource="#dsn2#" result="MAX_ID">
	INSERT INTO
		#dsn3_alias#.ORDERS_HISTORY
		(
		ORDER_ID,
		ORDER_HEAD,
		ORDER_DETAIL,
		ORDER_NUMBER,
		ORDER_CURRENCY,
		COMMETHOD_ID,
		ORDER_STATUS,
		ORDER_ZONE,
		ORDER_STAGE,
		PURCHASE_SALES,
		COMPANY_ID,
		PARTNER_ID,
		EMPLOYEE_ID,
		CONSUMER_ID,
		OFFER_ID,
		SALES_PARTNER_ID,
		ORDER_EMPLOYEE_ID,
		<!--- SALES_POSITION_CODE, --->
		ORDER_DATE,
		STARTDATE,
		FINISHDATE,
		DELIVERDATE,
		PRIORITY_ID,
		DISCOUNTTOTAL,
		GROSSTOTAL,
		TAX,
		NETTOTAL,
		TAXTOTAL,
		OTHER_MONEY,
		PAYMETHOD,
		PAY_FORMUL,
		INCLUDED_KDV,
		MEMBER_TYPE,
		INVISIBLE,
		PUBLISHDATE,
		IS_WORK,
		IS_PROCESSED,
		SHIP_ADDRESS,
		RECORD_DATE,
		RECORD_EMP,
		RECORD_IP,
		SHIP_METHOD,
		RESERVED,
		PROJECT_ID
		)
	VALUES
		(
		#get_order.ORDER_ID#,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#get_order.ORDER_HEAD#">,
		<cfif len(get_order.ORDER_DETAIL)><cfqueryparam cfsqltype="cf_sql_varchar" value="#get_order.ORDER_DETAIL#">,<cfelse>NULL,</cfif>	
        <cfif len(get_order.ORDER_NUMBER)><cfqueryparam cfsqltype="cf_sql_varchar" value="#get_order.ORDER_NUMBER#">,<cfelse>NULL,</cfif>
        <cfif len(get_order.ORDER_CURRENCY)>#get_order.ORDER_CURRENCY#,<cfelse>NULL,</cfif>	
        <cfif len(get_order.COMMETHOD_ID)>#get_order.COMMETHOD_ID#,<cfelse>NULL,</cfif>
		#get_order.ORDER_STATUS#,
		#get_order.ORDER_ZONE#,
		#get_order.ORDER_STAGE#,
		#get_order.PURCHASE_SALES#,
		<cfif len(get_order.COMPANY_ID)>#get_order.COMPANY_ID#,<cfelse>NULL,</cfif>
        <cfif len(get_order.PARTNER_ID)>#get_order.PARTNER_ID#,<cfelse>NULL,</cfif>
        <cfif len(get_order.EMPLOYEE_ID)>#get_order.EMPLOYEE_ID#,<cfelse>NULL,</cfif>
        <cfif len(get_order.CONSUMER_ID)>#get_order.CONSUMER_ID#,<cfelse>NULL,</cfif>
        <cfif len(get_order.OFFER_ID)>#get_order.OFFER_ID#,<cfelse>NULL,</cfif>
        <cfif len(get_order.SALES_PARTNER_ID)>#get_order.SALES_PARTNER_ID#,<cfelse>NULL,</cfif>
        <cfif len(get_order.ORDER_EMPLOYEE_ID)>#get_order.ORDER_EMPLOYEE_ID#,<cfelse>NULL,</cfif>
        <!--- <cfif len(get_order.SALES_POSITION_CODE)>#get_order.SALES_POSITION_CODE#,<cfelse>NULL,</cfif> --->
        <cfif len(get_order.ORDER_DATE)>#CreateODBCDateTime(get_order.ORDER_DATE)#,<cfelse>NULL,</cfif>
        <cfif len(get_order.STARTDATE)>#CreateODBCDateTime(get_order.STARTDATE)#,<cfelse>NULL,</cfif>
        <cfif len(get_order.FINISHDATE)>#CreateODBCDateTime(get_order.FINISHDATE)#,<cfelse>NULL,</cfif>
        <cfif len(get_order.DELIVERDATE)>#CreateODBCDateTime(get_order.DELIVERDATE)#,<cfelse>NULL,</cfif>	
        <cfif len(get_order.PRIORITY_ID)>#get_order.PRIORITY_ID#,<cfelse>NULL,</cfif>
        <cfif len(get_order.DISCOUNTTOTAL)>#get_order.DISCOUNTTOTAL#,<cfelse>NULL,</cfif>
        <cfif len(get_order.GROSSTOTAL)>#get_order.GROSSTOTAL#,<cfelse>NULL,</cfif>
        <cfif len(get_order.TAX)>#get_order.TAX#,<cfelse>NULL,</cfif>
        <cfif len(get_order.NETTOTAL)>#get_order.NETTOTAL#,<cfelse>NULL,</cfif>
        <cfif len(get_order.TAXTOTAL)><cfqueryparam cfsqltype="cf_sql_varchar" value="#get_order.TAXTOTAL#">,<cfelse>NULL,</cfif>
        <cfif len(get_order.OTHER_MONEY)><cfqueryparam cfsqltype="cf_sql_varchar" value="#get_order.OTHER_MONEY#">,<cfelse>NULL,</cfif>
        <cfif len(get_order.PAYMETHOD)>#get_order.PAYMETHOD#,<cfelse>NULL,</cfif>
        <cfif len(get_order.PAY_FORMUL)><cfqueryparam cfsqltype="cf_sql_varchar" value="#get_order.PAY_FORMUL#">,<cfelse>NULL,</cfif>
        <cfif len(get_order.INCLUDED_KDV)>#get_order.INCLUDED_KDV#,<cfelse>NULL,</cfif>
        <cfif len(get_order.MEMBER_TYPE)>#get_order.MEMBER_TYPE#,<cfelse>NULL,</cfif>
        <cfif len(get_order.INVISIBLE)>#get_order.INVISIBLE#,<cfelse>NULL,</cfif>
        <cfif len(get_order.PUBLISHDATE)>#CreateODBCDateTime(get_order.PUBLISHDATE)#,<cfelse>NULL,</cfif>
		#get_order.IS_WORK#,
		#get_order.IS_PROCESSED#,
		<cfif len(get_order.SHIP_ADDRESS)><cfqueryparam cfsqltype="cf_sql_varchar" value="#get_order.SHIP_ADDRESS#">,<cfelse>NULL,</cfif>
		#NOW()#,
		#SESSION.EP.USERID#,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#CGI.REMOTE_ADDR#">,
		<cfif len(get_order.SHIP_METHOD)>#get_order.SHIP_METHOD#,<cfelse>NULL,</cfif>
        <cfif len(get_order.RESERVED)>#get_order.RESERVED#,<cfelse>NULL,</cfif>
        <cfif len(get_order.PROJECT_ID)>#get_order.PROJECT_ID#<cfelse>NULL</cfif>
		)
</cfquery>
<cfloop query="get_order_row">
	<cfquery name="ADD_ORDER_HISTORY_ROW" datasource="#dsn2#">
		INSERT INTO
			#dsn3_alias#.ORDER_ROW_HISTORY
			(
			ORDER_HISTORY_ID,
            ORDER_ID,
            ORDER_ROW_ID,
			STOCK_ID,
			PRODUCT_ID,
			PAYMETHOD_ID,
			PRODUCT_NAME,
			DESCRIPTION,
			DUEDATE,
			QUANTITY,
			PRICE,
			UNIT,
			UNIT_ID,
			TAX,
			NETTOTAL,
			PAY_METHOD,
			ORDER_ROW_CURRENCY,
			RESERVE_TYPE,
			RESERVE_DATE,
			DELIVER_DATE,
			DELIVER_DEPT,
			DISCOUNT_1,
			DISCOUNT_2,
			DISCOUNT_3,
			DISCOUNT_4,
			DISCOUNT_5,
			SPECT_VAR_ID,
			SPECT_VAR_NAME,
			OTHER_MONEY,
			OTHER_MONEY_VALUE,
			PRICE_OTHER,
			<!--- COST_ID, --->
			COST_PRICE,
			DISCOUNT_COST,
			MARJ,
			UNIQUE_RELATION_ID,
			PROM_RELATION_ID,
			PRODUCT_NAME2,
			AMOUNT2,
			UNIT2,
			EXTRA_PRICE,
			EXTRA_PRICE_TOTAL,
			SHELF_NUMBER,
			PRODUCT_MANUFACT_CODE,
			BASKET_EXTRA_INFO_ID,
			SELECT_INFO_EXTRA,
            DETAIL_INFO_EXTRA,
			BASKET_EMPLOYEE_ID,
			LIST_PRICE,
			NUMBER_OF_INSTALLMENT,
			PRICE_CAT,
			CATALOG_ID,
			KARMA_PRODUCT_ID,
			OTV_ORAN,
			OTVTOTAL
			)
		VALUES
			(
			#MAX_ID.IDENTITYCOL#,
            <cfqueryparam cfsqltype="cf_sql_integer" value="#ORDER_ID#">,
            <cfqueryparam cfsqltype="cf_sql_integer" value="#ORDER_ROW_ID#">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#STOCK_ID#">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#PRODUCT_ID#">,
			<cfif len(PAYMETHOD_ID)>#PAYMETHOD_ID#,<cfelse>NULL,</cfif>
            <cfif len(PRODUCT_NAME)><cfqueryparam cfsqltype="cf_sql_varchar" value="#PRODUCT_NAME#">,<cfelse>NULL,</cfif>
            <cfif len(DESCRIPTION)><cfqueryparam cfsqltype="cf_sql_varchar" value="#DESCRIPTION#">,<cfelse>NULL,</cfif>
            <cfif len(DUEDATE)>#DUEDATE#,<cfelse>NULL,</cfif>
            <cfif len(QUANTITY)>#QUANTITY#,<cfelse>NULL,</cfif>
            <cfif len(PRICE)>#PRICE#,<cfelse>NULL,</cfif>
            <cfif len(UNIT)><cfqueryparam cfsqltype="cf_sql_varchar" value="#UNIT#">,<cfelse>NULL,</cfif>
            <cfif len(UNIT_ID)>#UNIT_ID#,<cfelse>NULL,</cfif>
            <cfif len(TAX)>#TAX#,<cfelse>NULL,</cfif>
            <cfif len(NETTOTAL)>#NETTOTAL#,<cfelse>NULL,</cfif>
            <cfif len(PAY_METHOD)>#PAY_METHOD#,<cfelse>NULL,</cfif>
            <cfif len(ORDER_ROW_CURRENCY)>#ORDER_ROW_CURRENCY#,<cfelse>NULL,</cfif>
            <cfif len(RESERVE_TYPE)>#RESERVE_TYPE#,<cfelse>NULL,</cfif>
            <cfif len(RESERVE_DATE)>#CreateODBCDateTime(get_order_row.RESERVE_DATE)#,<cfelse>NULL,</cfif>
            <cfif len(DELIVER_DATE)>#CreateODBCDateTime(get_order_row.DELIVER_DATE)#,<cfelse>NULL,</cfif>
            <cfif len(DELIVER_DEPT)>#DELIVER_DEPT#,<cfelse>NULL,</cfif>
            <cfif len(DISCOUNT_1)>#DISCOUNT_1#<cfelse>0</cfif>,
            <cfif len(DISCOUNT_2)>#DISCOUNT_2#<cfelse>0</cfif>,
            <cfif len(DISCOUNT_3)>#DISCOUNT_3#<cfelse>0</cfif>,
            <cfif len(DISCOUNT_4)>#DISCOUNT_4#<cfelse>0</cfif>,
            <cfif len(DISCOUNT_5)>#DISCOUNT_5#<cfelse>0</cfif>,
            <cfif len(SPECT_VAR_ID)>#SPECT_VAR_ID#,<cfelse>NULL,</cfif>
            <cfif len(SPECT_VAR_NAME)><cfqueryparam cfsqltype="cf_sql_varchar" value="#SPECT_VAR_NAME#">,<cfelse>NULL,</cfif>
            <cfif len(OTHER_MONEY)><cfqueryparam cfsqltype="cf_sql_varchar" value="#OTHER_MONEY#">,<cfelse>NULL,</cfif>
            <cfif len(OTHER_MONEY_VALUE)>#OTHER_MONEY_VALUE#,<cfelse>NULL,</cfif>
            <cfif len(PRICE_OTHER)>#PRICE_OTHER#,<cfelse>0,</cfif>
            <!--- <cfif len(COST_ID)>#COST_ID#<cfelse>NULL</cfif>, --->
            <cfif len(COST_PRICE)>#COST_PRICE#<cfelse>0</cfif>,
            <cfif len(DISCOUNT_COST)>#DISCOUNT_COST#<cfelse>NULL</cfif>,
            <cfif len(MARJ)>#MARJ#<cfelse>0</cfif>,
            <cfif len(UNIQUE_RELATION_ID)><cfqueryparam cfsqltype="cf_sql_varchar" value="#UNIQUE_RELATION_ID#"><cfelse>NULL</cfif>,
            <cfif len(PROM_RELATION_ID)><cfqueryparam cfsqltype="cf_sql_varchar" value="#PROM_RELATION_ID#"><cfelse>NULL</cfif>,
            <cfif len(PRODUCT_NAME2)><cfqueryparam cfsqltype="cf_sql_varchar" value="#PRODUCT_NAME2#"><cfelse>NULL</cfif>,
            <cfif len(AMOUNT2)>#AMOUNT2#<cfelse>NULL</cfif>,
            <cfif len(UNIT2)><cfqueryparam cfsqltype="cf_sql_varchar" value="#UNIT2#"><cfelse>NULL</cfif>,
            <cfif len(EXTRA_PRICE)>#EXTRA_PRICE#<cfelse>NULL</cfif>,
            <cfif len(EXTRA_PRICE_TOTAL)>#EXTRA_PRICE_TOTAL#<cfelse>NULL</cfif>,
            <cfif len(SHELF_NUMBER)><cfqueryparam cfsqltype="cf_sql_varchar" value="#SHELF_NUMBER#"><cfelse>NULL</cfif>,
            <cfif len(PRODUCT_MANUFACT_CODE)><cfqueryparam cfsqltype="cf_sql_varchar" value="#PRODUCT_MANUFACT_CODE#"><cfelse>NULL</cfif>,
            <cfif len(BASKET_EXTRA_INFO_ID)>#BASKET_EXTRA_INFO_ID#<cfelse>NULL</cfif>,
			<cfif len(SELECT_INFO_EXTRA)>#SELECT_INFO_EXTRA#<cfelse>NULL</cfif>,
			<cfif len(DETAIL_INFO_EXTRA)>'#DETAIL_INFO_EXTRA#'<cfelse>NULL</cfif>,
            <cfif len(BASKET_EMPLOYEE_ID)>#BASKET_EMPLOYEE_ID#<cfelse>NULL</cfif>,
            <cfif len(LIST_PRICE)>#LIST_PRICE#<cfelse>NULL</cfif>,
            <cfif len(NUMBER_OF_INSTALLMENT)>#NUMBER_OF_INSTALLMENT#<cfelse>NULL</cfif>,
            <cfif len(PRICE_CAT)>#PRICE_CAT#<cfelse>NULL</cfif>,
            <cfif len(CATALOG_ID)>#CATALOG_ID#<cfelse>NULL</cfif>,
            <cfif len(KARMA_PRODUCT_ID)>#KARMA_PRODUCT_ID#<cfelse>NULL</cfif>,
            <cfif len(OTV_ORAN)>#OTV_ORAN#<cfelse>NULL</cfif>,
            <cfif len(OTVTOTAL)>#OTVTOTAL#<cfelse>NULL</cfif>
			)
	</CFquery>	
	</cfloop>
