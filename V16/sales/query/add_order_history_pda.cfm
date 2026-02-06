<cfquery name="get_order" datasource="#dsn3#">
	SELECT 
    	ORDER_ID, 
        WRK_ID, 
        ORDER_HEAD, 
        ORDER_DETAIL, 
        ORDER_NUMBER, 
        ORDER_DATE, 
        ORDER_CURRENCY, 
        ORDER_STAGE, 
        COMMETHOD_ID, 
        ORDER_STATUS, 
        ORDER_ZONE, 
        PURCHASE_SALES, 
        COMPANY_ID, 
        PARTNER_ID, 
        EMPLOYEE_ID, 
        CONSUMER_ID, 
        REF_COMPANY_ID, 
        REF_PARTNER_ID, 
        REF_CONSUMER_ID, 
        OFFER_ID, 
        SALES_PARTNER_ID, 
        SALES_CONSUMER_ID, 
        ORDER_EMPLOYEE_ID, 
        PRIORITY_ID, 
        IS_WORK, 
        IS_PROCESSED, 
        INCLUDED_KDV, 
        MEMBER_TYPE, 
        INVISIBLE, 
        SHIP_METHOD, 
        RESERVED, 
        PROJECT_ID, 
        STARTDATE, 
        FINISHDATE, 
        DELIVERDATE, 
        DISCOUNTTOTAL, 
        GROSSTOTAL, 
        TAX, 
        NETTOTAL, 
        OTV_TOTAL, 
        TAXTOTAL, 
        OTHER_MONEY, 
        OTHER_MONEY_VALUE, 
        PAYMETHOD, 
        PAY_FORMUL, 
        PUBLISHDATE, 
        DELIVER_DEPT_ID, 
        LOCATION_ID, 
        CATALOG_ID, 
        SHIP_DATE, 
        SHIP_ADDRESS, 
        CITY_ID, 
        COUNTY_ID, 
        DISTRICT_ID, 
        DUE_DATE, 
        REF_NO, 
        SA_DISCOUNT, 
        GENERAL_PROM_ID, 
        GENERAL_PROM_LIMIT, 
        GENERAL_PROM_DISCOUNT, 
        GENERAL_PROM_AMOUNT, 
        FREE_PROM_ID, 
        FREE_PROM_LIMIT, 
        FREE_PROM_AMOUNT, 
        FREE_PROM_STOCK_ID, 
        FREE_STOCK_PRICE, 
        FREE_STOCK_MONEY, 
        FREE_PROM_COST, 
        CARD_PAYMETHOD_ID, 
        CARD_PAYMETHOD_RATE, 
        ZONE_ID, 
        RESOURCE_ID, 
        IMS_CODE_ID, 
        CUSTOMER_VALUE_ID, 
        SALES_ADD_OPTION_ID, 
        PRINT_COUNT, 
        RECORD_DATE, 
        RECORD_EMP, 
        RECORD_IP, 
        UPDATE_DATE, 
        UPDATE_EMP, 
        UPDATE_IP 
    FROM 
	    ORDERS 
    WHERE 
    	ORDER_ID = #attributes.ORDER_ID#
</cfquery>
<cfquery name="get_order_row" datasource="#dsn3#">
	SELECT 
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
        PRICE_OTHER, 
        UNIT, 
        UNIT_ID, 
        TAX, 
        NETTOTAL, 
        PAY_METHOD, 
        ORDER_ROW_CURRENCY, 
        DELIVER_DATE, 
        DELIVER_DEPT, 
        DELIVER_LOCATION, 
        DISCOUNT_1, 
        DISCOUNT_2, 
        DISCOUNT_3, 
        DISCOUNT_4, 
        DISCOUNT_5, 
        DISCOUNT_6, 
        DISCOUNT_7, 
        DISCOUNT_8, 
        DISCOUNT_9, 
        DISCOUNT_10, 
        SPECT_VAR_ID,
        SPECT_VAR_NAME, 
        OTHER_MONEY, 
        OTHER_MONEY_VALUE, 
        LOT_NO, 
        COST_ID, 
        COST_PRICE, 
        EXTRA_COST, 
        MARJ, 
        PROM_COMISSION, 
        PROM_COST, 
        DISCOUNT_COST, 
        IS_PROMOTION, 
        PROM_ID, 
        PROM_STOCK_ID, 
        IS_COMMISSION, 
        UNIQUE_RELATION_ID, 
        PRODUCT_NAME2, 
        EXTRA_PRICE_OTHER_TOTAL, 
        UNIT2, 
        EXTRA_PRICE, 
        SHELF_NUMBER, 
        PRODUCT_MANUFACT_CODE, 
        EXTRA_PRICE_TOTAL, 
        OTV_ORAN, 
        OTVTOTAL, 
        BASKET_EXTRA_INFO_ID,
		SELECT_INFO_EXTRA,
        DETAIL_INFO_EXTRA,
        PROM_RELATION_ID, 
        RESERVE_TYPE, 
        RESERVE_DATE,
        PRICE_CAT,
        CATALOG_ID,
        LIST_PRICE, 
        NUMBER_OF_INSTALLMENT, 
        BASKET_EMPLOYEE_ID, 
        KARMA_PRODUCT_ID, 
        AMOUNT2, 
        EK_TUTAR_PRICE, 
        ROW_PRO_MATERIAL_ID, 
        WRK_ROW_ID, 
        WRK_ROW_RELATION_ID 
    FROM 
	    ORDER_ROW 
    WHERE 
    	ORDER_ID = #attributes.ORDER_ID#
</cfquery>
<cflock name="#CREATEUUID()#" timeout="20">
	<cftransaction>
	<cfquery name="add_order_history" datasource="#dsn3#" result="MAX_ID">
		INSERT INTO
			ORDERS_HISTORY
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
			ORDER_DATE,
			STARTDATE,
			FINISHDATE,
			DELIVERDATE,
			PRIORITY_ID,
			DISCOUNTTOTAL,
			GROSSTOTAL,
			TAX,
			OTV_TOTAL,
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
			'#get_order.ORDER_HEAD#',
		<cfif len(get_order.ORDER_DETAIL)>'#get_order.ORDER_DETAIL#',<cfelse>NULL,</cfif>	
		<cfif len(get_order.ORDER_NUMBER)>'#get_order.ORDER_NUMBER#',<cfelse>NULL,</cfif>	
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
		<cfif len(get_order.OTV_TOTAL)>#get_order.OTV_TOTAL#,<cfelse>NULL,</cfif>
		<cfif len(get_order.NETTOTAL)>#get_order.NETTOTAL#,<cfelse>NULL,</cfif>
		<cfif len(get_order.TAXTOTAL)>'#get_order.TAXTOTAL#',<cfelse>NULL,</cfif>
		<cfif len(get_order.OTHER_MONEY)>'#get_order.OTHER_MONEY#',<cfelse>NULL,</cfif>
		<cfif len(get_order.PAYMETHOD)>#get_order.PAYMETHOD#,<cfelse>NULL,</cfif>
		<cfif len(get_order.PAY_FORMUL)>'#get_order.PAY_FORMUL#',<cfelse>NULL,</cfif>
		<cfif len(get_order.INCLUDED_KDV)>#get_order.INCLUDED_KDV#,<cfelse>NULL,</cfif>
		<cfif len(get_order.MEMBER_TYPE)>#get_order.MEMBER_TYPE#,<cfelse>NULL,</cfif>
		<cfif len(get_order.INVISIBLE)>#get_order.INVISIBLE#,<cfelse>NULL,</cfif>
		<cfif len(get_order.PUBLISHDATE)>#CreateODBCDateTime(get_order.PUBLISHDATE)#,<cfelse>NULL,</cfif>
			#get_order.IS_WORK#,
			#get_order.IS_PROCESSED#,
		<cfif len(get_order.SHIP_ADDRESS)>'#get_order.SHIP_ADDRESS#',<cfelse>NULL,</cfif>
			#NOW()#,
			<cfif isDefined("session.pda")>#session.pda.userid#<cfelse>#session.ep.userid#</cfif>,
			'#CGI.REMOTE_ADDR#',
		<cfif len(get_order.SHIP_METHOD)>#get_order.SHIP_METHOD#,<cfelse>NULL,</cfif>
		<cfif len(get_order.RESERVED)>#get_order.RESERVED#,<cfelse>NULL,</cfif>
		<cfif len(get_order.PROJECT_ID)>#get_order.PROJECT_ID#<cfelse>NULL</cfif>
			)
	</cfquery>
	</cftransaction>
</cflock>

<cfloop query="get_order_row">
	<cfquery name="ADD_ORDER_HISTORY_ROW" datasource="#dsn3#">
		INSERT INTO
			ORDER_ROW_HISTORY
			(
			ORDER_HISTORY_ID,
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
			EXTRA_PRICE_OTHER_TOTAL,
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
			#STOCK_ID#,
			#PRODUCT_ID#,
			<cfif len(PAYMETHOD_ID)>#PAYMETHOD_ID#,<cfelse>NULL,</cfif>
			<cfif len(PRODUCT_NAME)>'#PRODUCT_NAME#',<cfelse>NULL,</cfif>
			<cfif len(DESCRIPTION)>'#DESCRIPTION#',<cfelse>NULL,</cfif>
			<cfif len(DUEDATE)>#DUEDATE#,<cfelse>NULL,</cfif>
			<cfif len(QUANTITY)>#QUANTITY#,<cfelse>NULL,</cfif>
			<cfif len(PRICE)>#PRICE#,<cfelse>NULL,</cfif>
			<cfif len(UNIT)>'#UNIT#',<cfelse>NULL,</cfif>
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
			<cfif len(SPECT_VAR_NAME)>'#SPECT_VAR_NAME#',<cfelse>NULL,</cfif>
			<cfif len(OTHER_MONEY)>'#OTHER_MONEY#',<cfelse>NULL,</cfif>
			<cfif len(OTHER_MONEY_VALUE)>#OTHER_MONEY_VALUE#,<cfelse>NULL,</cfif>
			<cfif len(PRICE_OTHER)>#PRICE_OTHER#,<cfelse>0,</cfif>
			<cfif len(COST_PRICE)>#COST_PRICE#<cfelse>0</cfif>,
			<cfif len(DISCOUNT_COST)>#DISCOUNT_COST#<cfelse>NULL</cfif>,
			<cfif len(MARJ)>#MARJ#<cfelse>0</cfif>,
			<cfif len(UNIQUE_RELATION_ID)>'#UNIQUE_RELATION_ID#'<cfelse>NULL</cfif>,
			<cfif len(PROM_RELATION_ID)>'#PROM_RELATION_ID#'<cfelse>NULL</cfif>,
			<cfif len(PRODUCT_NAME2)>'#PRODUCT_NAME2#'<cfelse>NULL</cfif>,
			<cfif len(AMOUNT2)>#AMOUNT2#<cfelse>NULL</cfif>,
			<cfif len(UNIT2)>'#UNIT2#'<cfelse>NULL</cfif>,
			<cfif len(EXTRA_PRICE)>#EXTRA_PRICE#<cfelse>NULL</cfif>,
			<cfif len(EXTRA_PRICE_TOTAL)>#EXTRA_PRICE_TOTAL#<cfelse>NULL</cfif>,
			<cfif len(EXTRA_PRICE_OTHER_TOTAL)>#EXTRA_PRICE_OTHER_TOTAL#<cfelse>NULL</cfif>,
			<cfif len(SHELF_NUMBER)>'#SHELF_NUMBER#'<cfelse>NULL</cfif>,
			<cfif len(PRODUCT_MANUFACT_CODE)>'#PRODUCT_MANUFACT_CODE#'<cfelse>NULL</cfif>,
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
	</cfquery>	
</cfloop>
