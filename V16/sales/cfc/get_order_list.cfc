<cfcomponent>
<cffunction name="get_order_list_fnc" returntype="query">
   	<cfargument name="listing_type" default=""/>
   	<cfargument name="dsn2_alias" default=""/>
	<cfargument name="sort_type" default="4"/>
	<cfargument name="x_control_ims" default="0"/>
	<cfargument name="prod_cat" default=""/>
	<cfargument name="product_name" default=""/>
	<cfargument name="product_id" default=""/>
	<cfargument name="currency_id" default=""/>
	<cfargument name="employee_id" default=""/>
	<cfargument name="employee" default=""/>
	<cfargument name="order_employee_id" default=""/>
	<cfargument name="order_employee" default=""/>
	<cfargument name="brand_name" default=""/>
	<cfargument name="brand_id" default=""/>
	<cfargument name="short_code_name" default=""/>
	<cfargument name="short_code_id" default=""/>
	<cfargument name="sales_departments" default=""/>
	<cfargument name="status" default=""/>
	<cfargument name="project_head" default=""/>
	<cfargument name="project_id" default=""/>
	<cfargument name="subscription_no" default=""/>
	<cfargument name="subscription_id" default=""/>
	<cfargument name="priority" default=""/>
	<cfargument name="keyword" default=""/>
    <cfargument name="keyword_orderno" default=""/>    
	<cfargument name="member_type" default=""/>
	<cfargument name="member_name" default=""/>
	<cfargument name="company_id" default=""/>
	<cfargument name="consumer_id" default=""/>
	<cfargument name="sales_member_type" default=""/>
	<cfargument name="sales_member_name" default=""/>
	<cfargument name="sales_member_id" default=""/>
	<cfargument name="start_date" default=""/>
	<cfargument name="finish_date" default=""/>
	<cfargument name="order_stage" default=""/>
	<cfargument name="sales_county" default=""/>
	<cfargument name="sale_add_option" default=""/>
	<cfargument name="filter_branch_id" default=""/>
	<cfargument name="zone_id" default=""/>
	<cfargument name="record_emp_id" default=""/>
	<cfargument name="record_cons_id" default=""/>
	<cfargument name="record_part_id" default=""/>
	<cfargument name="record_name" default=""/>
	<cfargument name="module_name" default=""/>
	<cfargument name="is_instalment" default=""/>
	<cfargument name="startrow" default="">
	<cfargument name="maxrows" default="">
   	<cfargument name="card_paymethod_id" default="">
    <cfargument name="paymethod_id" default="">
    <cfargument name="paymethod" default="">
	<cfargument name="irsaliye_fatura" default="" />
    <cfargument name="related_orders" default="" />
    <cfargument name="use_efatura" default="" />

	<cfset dsn_alias = this.dsn_alias>
	<cfset dsn2_alias = arguments.dsn2_alias>
	<cfif x_control_ims eq 1 and session.ep.our_company_info.sales_zone_followup eq 1>
		<cfinclude template="../../member/query/get_ims_control.cfm">
	</cfif>

	<cfif listlen(arguments.sort_type)>
		<cfset arguments.sort_type = listFirst(arguments.sort_type)/>
	</cfif>

	<cfquery name="GET_ORDER_LIST" datasource="#this.dsn3#">
		WITH CTE1 AS(
        SELECT
			<cfif (isdefined("arguments.prod_cat") and len(arguments.prod_cat)) or (len(arguments.product_name) and len(arguments.product_id)) or (isDefined("currency_id") and len(currency_id)) or (isdefined("arguments.employee_id") and len(arguments.employee_id) and isdefined("arguments.employee") and len(arguments.employee))>
				DISTINCT
			</cfif>
			<cfif (isdefined('arguments.listing_type') and arguments.listing_type eq 2)><!--- Eğer satır bazında listeleme yapılıyorsa --->
				ORR.ORDER_ROW_CURRENCY,
				ORR.STOCK_ID,
				ORR.PRODUCT_ID,
				ORR.QUANTITY,
				ORR.CANCEL_AMOUNT,
				ORR.UNIT,
				PRODUCT.PRODUCT_NAME,
				PRODUCT.PRODUCT_CODE,
                PRODUCT.PRODUCT_MANAGER,
				((ORR.NETTOTAL+ORR.OTVTOTAL) + ((ORR.NETTOTAL + ORR.OTVTOTAL) * ORR.TAX / 100)) AS NETTOTAL,
				((ORR.NETTOTAL+ORR.OTVTOTAL) * ORR.TAX /100) AS TAXTOTAL,
				((ORR.OTHER_MONEY_VALUE+ORR.OTVTOTAL) + (((ORR.NETTOTAL+ORR.OTVTOTAL) * ORR.TAX /100)/ISNULL((ORDER_MONEY.RATE2/ORDER_MONEY.RATE1),1))) AS OTHER_MONEY_VALUE,
				ORR.OTHER_MONEY AS OTHER_MONEY,
				ORR.DELIVER_DATE AS ROW_DELIVER_DATE,
				ORR.SPECT_VAR_ID,
				ORR.SPECT_VAR_NAME,
				ORR.WRK_ROW_ID,
				ORR.ORDER_ROW_ID,
			<cfelse>
				ORDERS.NETTOTAL,
				ORDERS.TAXTOTAL,
				ORDERS.OTHER_MONEY_VALUE,
				ORDERS.OTHER_MONEY,
			</cfif>
			ORDERS.SALES_ADD_OPTION_ID,
            ORDERS.CITY_ID,
            ORDERS.OFFER_ID,
            CAST(ORDERS.ORDER_DETAIL AS NVARCHAR) ORDER_DETAIL,
			ORDERS.ORDER_ID,
			ORDERS.ORDER_STATUS,
			ORDERS.CONSUMER_ID,
			ORDERS.PARTNER_ID,
			ORDERS.COMPANY_ID,
			C.CONSUMER_NAME + ' ' + C.CONSUMER_SURNAME CONSUMER_NAME,
			CP.COMPANY_PARTNER_NAME+' '+CP.COMPANY_PARTNER_SURNAME PARTNER_NAME,
			COM.NICKNAME COMPANY_NAME,
			ORDERS.ORDER_NUMBER,
			ORDERS.REF_NO,
			ORDERS.ORDER_CURRENCY,
			ORDERS.ORDER_HEAD,
			ORDERS.TAX,
			ORDERS.PRIORITY_ID,
			ORDERS.COMMETHOD_ID,
			ORDERS.GROSSTOTAL, 
			ORDERS.RECORD_DATE, 
			ORDERS.RECORD_EMP, 
			ORDERS.RECORD_PAR,
			ORDERS.RECORD_CON,
			ORDERS.DELIVERDATE, 
			ORDERS.ORDER_ZONE, 
            (SELECT EMPLOYEE_NAME FROM #dsn_alias#.EMPLOYEES WHERE EMPLOYEES.EMPLOYEE_ID = ORDERS.ORDER_EMPLOYEE_ID) AS ORDER_EMPLOYEE_NAME,
            (SELECT EMPLOYEE_SURNAME FROM #dsn_alias#.EMPLOYEES WHERE EMPLOYEES.EMPLOYEE_ID = ORDERS.ORDER_EMPLOYEE_ID) AS ORDER_EMPLOYEE_SURNAME,
			ORDERS.ORDER_EMPLOYEE_ID,
			ORDERS.SALES_PARTNER_ID,
			ORDERS.SALES_CONSUMER_ID,
			ORDERS.ORDER_DATE,
			ORDERS.ORDER_STAGE,
			ORDERS.IS_INSTALMENT,
			ORDERS.IS_PROCESSED,
			<cfif (isdefined('arguments.listing_type') and arguments.listing_type eq 2)><!--- Eğer satır bazında listeleme yapılıyorsa --->
				ORR.ROW_PROJECT_ID PROJECT_ID,
				(SELECT PROJECT_HEAD FROM #dsn_alias#.PRO_PROJECTS WHERE PRO_PROJECTS.PROJECT_ID = ORR.ROW_PROJECT_ID) AS PROJECT_HEAD,
			<cfelse>
				ORDERS.PROJECT_ID,
				(SELECT PROJECT_HEAD FROM #dsn_alias#.PRO_PROJECTS WHERE PRO_PROJECTS.PROJECT_ID = ORDERS.PROJECT_ID) AS PROJECT_HEAD,
			</cfif>
			ORDERS.FRM_BRANCH_ID,
            (SELECT BRANCH_NAME FROM #this.dsn_alias#.BRANCH WHERE BRANCH_ID = ORDERS.FRM_BRANCH_ID) AS BRANCH_NAME,
			ISNULL((ORDER_MONEY.RATE2/ORDER_MONEY.RATE1),1) MONEY_RATE,
			ORDERS.DELIVER_DEPT_ID,
			ORDERS.LOCATION_ID,
            CASE 
            	WHEN ORDERS.CARD_PAYMETHOD_ID IS NOT NULL 
                THEN CPT.CARD_NO
                WHEN ORDERS.PAYMETHOD IS NOT NULL 
                THEN SP.PAYMETHOD
             END AS
             	ORDER_PAYMETHOD
		FROM 			
			<cfif (isdefined('arguments.listing_type') and arguments.listing_type eq 2) OR ((isdefined("arguments.prod_cat") and len(arguments.prod_cat)) or (isdefined("arguments.employee_id") and len(arguments.employee_id) and isdefined("arguments.employee") and len(arguments.employee)))>
				PRODUCT WITH (NOLOCK), 
			</cfif>	
			ORDERS WITH (NOLOCK)
			<cfif isdefined('arguments.listing_type') and arguments.listing_type eq 1 and isdefined("arguments.irsaliye_fatura") and arguments.irsaliye_fatura eq 2>
			<!---Performans İçin Where Bloğındaki in koşulu kaldırılıp buraya eklendi E.A 2014.03.02 --->
				JOIN
				(
					SELECT DISTINCT
						ORD_R.ORDER_ID
					FROM 
						ORDER_ROW ORD_R
					LEFT JOIN 
						GET_ALL_SHIP_ROW GS
					ON
						GS.WRK_ROW_RELATION_ID=ORD_R.WRK_ROW_ID
					LEFT JOIN 
						GET_ALL_INVOICE_ROW GI
					ON 
						GI.WRK_ROW_RELATION_ID=ORD_R.WRK_ROW_ID	
					WHERE
						( GI.WRK_ROW_RELATION_ID IS NOT NULL )
					UNION 
					SELECT DISTINCT
						ORD_R.ORDER_ID
					FROM 
						ORDER_ROW ORD_R
					LEFT JOIN 
						GET_ALL_SHIP_ROW GS
					ON
						GS.WRK_ROW_RELATION_ID=ORD_R.WRK_ROW_ID
					LEFT JOIN 
						GET_ALL_INVOICE_ROW GI
					ON 
						GI.WRK_ROW_RELATION_ID=GS.WRK_ROW_ID	
					WHERE
						( GI.WRK_ROW_RELATION_ID IS NOT NULL )		
				) AS order_irsaliye_fatura ON
				  ORDERS.ORDER_ID = order_irsaliye_fatura.ORDER_ID
			</cfif>
			LEFT JOIN 
				(#this.dsn_alias#.COMPANY_PARTNER CP INNER JOIN #this.dsn_alias#.COMPANY COM ON CP.COMPANY_ID = COM.COMPANY_ID)
				ON CP.PARTNER_ID = ORDERS.PARTNER_ID
			LEFT JOIN #this.dsn_alias#.CONSUMER C ON C.CONSUMER_ID = ORDERS.CONSUMER_ID	
			LEFT JOIN #this.dsn_alias#.EMPLOYEES E ON E.EMPLOYEE_ID = ORDERS.RECORD_EMP
			LEFT JOIN CREDITCARD_PAYMENT_TYPE CPT ON ORDERS.CARD_PAYMETHOD_ID = CPT.PAYMENT_TYPE_ID
			LEFT JOIN #dsn_alias#.SETUP_PAYMETHOD SP ON ORDERS.PAYMETHOD = SP.PAYMETHOD_ID
			<cfif (isdefined('arguments.listing_type') and arguments.listing_type eq 2) OR ((len(arguments.short_code_name) and len(arguments.short_code_id)) or (len(arguments.brand_name) and len(arguments.brand_id)) or (len(arguments.product_name) and len(arguments.product_id)) or (isdefined("arguments.prod_cat") and len(arguments.prod_cat)) or (isdefined("arguments.employee_id") and len(arguments.employee_id) and isdefined("arguments.employee") and len(arguments.employee)))>
			<cfelse>
			LEFT JOIN ORDER_MONEY	ON ORDER_MONEY.ACTION_ID = ORDERS.ORDER_ID AND ORDER_MONEY.MONEY_TYPE = ORDERS.OTHER_MONEY
			</cfif>
			<cfif (isdefined('arguments.listing_type') and arguments.listing_type eq 2) OR ((len(arguments.short_code_name) and len(arguments.short_code_id)) or (len(arguments.brand_name) and len(arguments.brand_id)) or (len(arguments.product_name) and len(arguments.product_id)) or (isDefined("currency_id") and len(currency_id)) or (isdefined("arguments.prod_cat") and len(arguments.prod_cat)) or (isdefined("arguments.employee_id") and len(arguments.employee_id) and isdefined("arguments.employee") and len(arguments.employee)))>
				,ORDER_ROW ORR WITH (NOLOCK)
			</cfif>
				
				<cfif (isdefined('arguments.listing_type') and arguments.listing_type eq 2) OR ((len(arguments.short_code_name) and len(arguments.short_code_id)) or (len(arguments.brand_name) and len(arguments.brand_id)) or (len(arguments.product_name) and len(arguments.product_id)) or (isdefined("arguments.prod_cat") and len(arguments.prod_cat)) or (isdefined("arguments.employee_id") and len(arguments.employee_id) and isdefined("arguments.employee") and len(arguments.employee)))>
				LEFT JOIN ORDER_MONEY	 ON ORDER_MONEY.ACTION_ID = ORR.ORDER_ID AND ORDER_MONEY.MONEY_TYPE = ORR.OTHER_MONEY
				<cfelse>
				</cfif>
		WHERE 
        	((ORDERS.PURCHASE_SALES = 1 AND ORDERS.ORDER_ZONE = 0) OR (ORDERS.PURCHASE_SALES = 0 AND ORDERS.ORDER_ZONE = 1) )
			<cfif isdefined("arguments.sales_departments") and len(arguments.sales_departments)>
				AND ORDERS.DELIVER_DEPT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#listfirst(arguments.sales_departments,'-')#">
				AND ORDERS.LOCATION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#listlast(arguments.sales_departments,'-')#">
			</cfif>
			<cfif (isdefined('arguments.listing_type') and arguments.listing_type eq 2) OR ((len(arguments.short_code_name) and len(arguments.short_code_id)) or (len(arguments.brand_name) and len(arguments.brand_id)) or (len(arguments.product_name) and len(arguments.product_id)) or (isDefined("currency_id") and len(currency_id)) or (isdefined("arguments.prod_cat") and len(arguments.prod_cat)) or (isdefined("arguments.employee_id") and len(arguments.employee_id) and isdefined("arguments.employee") and len(arguments.employee)))>
				AND ORR.ORDER_ID = ORDERS.ORDER_ID
			</cfif>
            <cfif (isdefined('arguments.listing_type') and arguments.listing_type eq 2)>
				<cfif arguments.related_orders eq 1>
            		AND WRK_ROW_ID IN (SELECT ORR2.WRK_ROW_RELATION_ID FROM ORDER_ROW ORR2 WHERE ORR2.WRK_ROW_RELATION_ID = ORR.WRK_ROW_ID)
                <cfelseif arguments.related_orders eq 2>
                 	AND WRK_ROW_ID NOT IN (SELECT ORR2.WRK_ROW_RELATION_ID FROM ORDER_ROW ORR2 WHERE ORR2.WRK_ROW_RELATION_ID = ORR.WRK_ROW_ID)
                </cfif>            	
            <cfelse>
				<cfif arguments.related_orders eq 1>
            		AND ORDER_NUMBER IN (SELECT O2.REF_NO FROM ORDERS O2 WHERE O2.REF_NO = ORDERS.ORDER_NUMBER)
                <cfelseif arguments.related_orders eq 2>
                	AND ORDER_NUMBER NOT IN (SELECT O2.REF_NO FROM ORDERS O2 WHERE O2.REF_NO = ORDERS.ORDER_NUMBER)
                </cfif>            	
            </cfif>
			<!--- satir irsaliyelesen/faturalasan --->
			<cfif isdefined('arguments.listing_type') and arguments.listing_type eq 2 and isdefined("arguments.irsaliye_fatura") and arguments.irsaliye_fatura eq 1>
				AND ORR.WRK_ROW_ID IN(SELECT GI.WRK_ROW_RELATION_ID FROM GET_ALL_SHIP_ROW GI WHERE GI.WRK_ROW_RELATION_ID = ORR.WRK_ROW_ID)
			<cfelseif isdefined('arguments.listing_type') and arguments.listing_type eq 2 and isdefined("arguments.irsaliye_fatura") and arguments.irsaliye_fatura eq 3>
				AND ORR.WRK_ROW_ID NOT IN(SELECT GI.WRK_ROW_RELATION_ID FROM GET_ALL_SHIP_ROW GI WHERE GI.WRK_ROW_RELATION_ID = ORR.WRK_ROW_ID)
			<cfelseif isdefined('arguments.listing_type') and arguments.listing_type eq 2 and isdefined("arguments.irsaliye_fatura") and arguments.irsaliye_fatura eq 2>
				AND (ORR.WRK_ROW_ID IN(SELECT GI.WRK_ROW_RELATION_ID FROM GET_ALL_INVOICE_ROW GI WHERE GI.WRK_ROW_RELATION_ID = ORR.WRK_ROW_ID) OR ORR.WRK_ROW_ID IN(SELECT GS.WRK_ROW_RELATION_ID FROM GET_ALL_INVOICE_ROW GI,GET_ALL_SHIP_ROW GS WHERE GS.WRK_ROW_RELATION_ID = ORR.WRK_ROW_ID AND GS.WRK_ROW_ID = GI.WRK_ROW_RELATION_ID))
			</cfif>
			<!--- belge irsaliyelesen/faturalasan --->
			<cfif isdefined('arguments.listing_type') and arguments.listing_type eq 1 and isdefined("arguments.irsaliye_fatura") and arguments.irsaliye_fatura eq 1>
				AND ORDERS.ORDER_ID  IN (SELECT ORDER_ID FROM ORDERS_SHIP WHERE ORDER_ID = ORDERS.ORDER_ID)
			</cfif>
			<cfif isdefined('arguments.listing_type') and arguments.listing_type eq 1 and isdefined("arguments.irsaliye_fatura") and arguments.irsaliye_fatura eq 3>
				AND ORDERS.ORDER_ID NOT IN (SELECT ORDER_ID FROM ORDERS_SHIP WHERE ORDER_ID = ORDERS.ORDER_ID)
			</cfif>
			<cfif len(arguments.product_name) and len(arguments.product_id)>
				 AND ORR.PRODUCT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.product_id#">
			</cfif>
			<cfif len(arguments.short_code_id) and len(arguments.short_code_name)>
				 AND ORR.PRODUCT_ID IN (SELECT PRODUCT_ID FROM PRODUCT WHERE PRODUCT.SHORT_CODE_ID = #arguments.short_code_id#)
			</cfif>	
			<cfif len(arguments.brand_id) and len(brand_name)>
				AND ORR.PRODUCT_ID IN (SELECT PRODUCT_ID FROM PRODUCT WHERE PRODUCT.BRAND_ID = #arguments.brand_id#)
			</cfif>
			<cfif isdefined("arguments.employee_id") and len(arguments.employee_id) and isdefined("arguments.employee") and len(arguments.employee)>
				AND PRODUCT.PRODUCT_MANAGER = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.employee_id#">
			</cfif>
			<cfif  (isdefined("arguments.listing_type") and arguments.listing_type eq 2) OR ((isdefined("arguments.prod_cat") and len(arguments.prod_cat)) or (isdefined("arguments.employee_id") and len(arguments.employee_id) and isdefined("arguments.employee") and len(arguments.employee)))>
				AND PRODUCT.PRODUCT_ID = ORR.PRODUCT_ID
			</cfif>
			<cfif isdefined("arguments.prod_cat") and len(arguments.prod_cat)>
				AND PRODUCT.PRODUCT_CODE LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.prod_cat#.%">
			</cfif>
			<cfif isDefined("status") and len(status)>
				AND ORDERS.ORDER_STATUS = <cfqueryparam cfsqltype="cf_sql_smallint" value="#status#">
			</cfif>
			<cfif isdefined("arguments.project_id") and len (arguments.project_id) and isdefined("arguments.project_head") and len (arguments.project_head)>
            	<cfif arguments.project_id eq -1>
                    AND ORDERS.PROJECT_ID IS NULL
                <cfelse>
                    AND ORDERS.PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.project_id#">
                </cfif>
			</cfif>
			<cfif isdefined("arguments.subscription_id") and len(arguments.subscription_id) and isdefined("arguments.subscription_no") and len(arguments.subscription_no)>
				AND ORDERS.SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_id#">
			</cfif>
			<cfif isDefined("arguments.priority") and len(arguments.priority)>
			  	AND ORDERS.PRIORITY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.priority#"> 
			</cfif>
			<cfif isDefined("arguments.keyword") and len(arguments.keyword)>
                AND
				(
					ORDERS.ORDER_HEAD LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#trim(arguments.keyword)#%"> COLLATE SQL_Latin1_General_CP1_CI_AI OR
					ORDERS.ORDER_NUMBER LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#trim(arguments.keyword)#%">OR	
					ORDERS.REF_NO LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#trim(arguments.keyword)#%">
				)
			</cfif>
            <cfif isDefined("arguments.keyword_orderno") and len(arguments.keyword_orderno)>
			     AND ORDERS.ORDER_NUMBER LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#trim(arguments.keyword_orderno)#%">
			</cfif>
			<cfif isDefined("currency_id") and len(currency_id)>
				AND ORR.ORDER_ROW_CURRENCY = <cfqueryparam cfsqltype="cf_sql_integer" value="#currency_id#">
			</cfif>
			<cfif isdefined("arguments.member_type") and (arguments.member_type is 'PARTNER') and len(arguments.member_name) and len(arguments.company_id)>
				AND ORDERS.COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.company_id#">
			</cfif>
			<cfif isdefined("arguments.member_type") and (arguments.member_type is 'CONSUMER') and len(arguments.member_name) and len(arguments.consumer_id)>
				AND ORDERS.CONSUMER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.consumer_id#">
			</cfif>
			<cfif isdefined("arguments.order_employee_id") and len(arguments.order_employee_id) and len(arguments.order_employee)>
				AND ORDERS.ORDER_EMPLOYEE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.order_employee_id#">
			</cfif>
			<cfif len(arguments.sales_member_type) and (arguments.sales_member_type is 'partner') and len(arguments.sales_member_id) and len(arguments.sales_member_name)>
				AND ORDERS.SALES_PARTNER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.sales_member_id#">
			</cfif>
			<cfif len(arguments.sales_member_type) and (arguments.sales_member_type is 'consumer') and len(arguments.sales_member_id) and len(arguments.sales_member_name)>
				AND ORDERS.SALES_CONSUMER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.sales_member_id#">
			</cfif>
			<cfif isdefined('arguments.start_date') and len(arguments.start_date)>
				AND ORDERS.ORDER_DATE >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.start_date#">
			</cfif>
			<cfif isdefined('arguments.finish_date') and len(arguments.finish_date)>
				AND ORDERS.ORDER_DATE <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.finish_date#">
			</cfif>
			<cfif isdefined('arguments.order_stage') and len(arguments.order_stage)>
				AND ORDERS.ORDER_STAGE = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.order_stage#">
			</cfif>
			<cfif isdefined('arguments.sales_county') and len(arguments.sales_county)>
				AND ORDERS.ZONE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.sales_county#">
			</cfif>
			<cfif isdefined('arguments.sale_add_option') and len(arguments.sale_add_option)>
				AND ORDERS.SALES_ADD_OPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.sale_add_option#">
			</cfif>
			<cfif isdefined('arguments.filter_branch_id') and len(arguments.filter_branch_id)>
				AND ORDERS.FRM_BRANCH_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.filter_branch_id#">
			</cfif>
			<cfif isdefined('arguments.record_emp_id') and len(arguments.record_emp_id) and len(arguments.record_name)>
				AND ORDERS.RECORD_EMP=<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.record_emp_id#">
			<cfelseif isdefined('arguments.record_cons_id') and len(arguments.record_cons_id) and len(arguments.record_name)>
				AND ORDERS.RECORD_CON=<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.record_cons_id#">
			<cfelseif isdefined('arguments.record_part_id') and len(arguments.record_part_id) and len(arguments.record_name)>
				AND ORDERS.RECORD_PAR=<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.record_part_id#">
			</cfif>
			<cfif isdefined('arguments.zone_id') and len(arguments.zone_id)>
				AND ORDERS.DELIVER_DEPT_ID IN 
					(SELECT 
						D.DEPARTMENT_ID 
					FROM 
						#dsn_alias#.DEPARTMENT D,
						#dsn_alias#.BRANCH B
					WHERE 
						D.BRANCH_ID = B.BRANCH_ID AND
						B.ZONE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.zone_id#">
					)
			</cfif>
			<!---  115093 id li iş kapsamında kapatılmıştır.
			<cfif session.ep.isBranchAuthorization>
				AND 
				(
					DELIVER_DEPT_ID IN (SELECT DEPARTMENT_ID FROM #this.dsn_alias#.DEPARTMENT WHERE BRANCH_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#listgetat(session.ep.user_location,2,'-')#">)
					OR ISNULL(ORDERS.FRM_BRANCH_ID,0)=<cfqueryparam cfsqltype="cf_sql_integer" value="#listgetat(session.ep.user_location,2,'-')#">
				)
			</cfif> --->
			<cfif session.ep.isBranchAuthorization>
				AND FRM_BRANCH_ID IN (SELECT BRANCH_ID FROM #dsn_alias#.EMPLOYEE_POSITION_BRANCHES WHERE POSITION_CODE = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.position_code#">) 
			</cfif>
			AND ISNULL(ORDERS.IS_INSTALMENT,0)=<cfif arguments.is_instalment eq 1>1<cfelse>0</cfif>
			<cfif x_control_ims eq 1 and session.ep.our_company_info.sales_zone_followup eq 1>
			AND
				(
					(ORDERS.CONSUMER_ID IS NULL AND ORDERS.COMPANY_ID IS NULL) OR
					(ORDERS.COMPANY_ID IN (#PreserveSingleQuotes(my_ims_comp_list)#)) OR
					(ORDERS.CONSUMER_ID IN (#PreserveSingleQuotes(my_ims_cons_list)#))
				)	
			</cfif>
            <cfif len(arguments.card_paymethod_id) and len(arguments.paymethod)>
            	AND ORDERS.CARD_PAYMETHOD_ID = #arguments.card_paymethod_id#
            </cfif>
            <cfif len(arguments.paymethod_id) and len(arguments.paymethod)>
            	AND ORDERS.PAYMETHOD = #arguments.paymethod_id#
            </cfif>
			<cfif len(arguments.use_efatura)>
				AND (ORDERS.COMPANY_ID IN (SELECT COMPANY_ID FROM #dsn_alias#.COMPANY WHERE USE_EFATURA = #arguments.use_efatura#)
				OR ORDERS.CONSUMER_ID IN (SELECT CONSUMER_ID FROM #dsn_alias#.CONSUMER WHERE USE_EFATURA = #arguments.use_efatura#)) 
			</cfif>
         ),
         CTE2 AS (
				SELECT
					CTE1.*,
						ROW_NUMBER() OVER (ORDER BY
													<cfif arguments.sort_type eq 1>
                                                        DELIVERDATE ASC,ORDER_ID
                                                    <cfelseif arguments.sort_type eq 2>
                                                        DELIVERDATE DESC,ORDER_ID DESC
                                                    <cfelseif arguments.sort_type eq 3>
                                                        ORDER_DATE ASC,ORDER_ID
                                                    <cfelseif arguments.sort_type eq 4>
                                                        ORDER_DATE DESC,ORDER_ID DESC
                                                    <cfelseif arguments.sort_type eq 5>
                                                        ORDER_EMPLOYEE_NAME +' '+ORDER_EMPLOYEE_SURNAME ASC,ORDER_ID
                                                    <cfelseif arguments.sort_type eq 6>
                                                        ORDER_EMPLOYEE_NAME +' '+ ORDER_EMPLOYEE_SURNAME DESC,ORDER_ID DESC
                                                    <cfelseif arguments.sort_type eq 7>
                                                        PROJECT_HEAD ASC,ORDER_ID
                                                    <cfelseif arguments.sort_type eq 8>
                                                        PROJECT_HEAD DESC,ORDER_ID DESC
                                                    <cfelseif arguments.sort_type eq 9>
                                                        LEFT(ORDER_NUMBER,2) ASC,ORDER_ID
                                                    <cfelseif arguments.sort_type eq 10>
                                                        LEFT(ORDER_NUMBER,2) DESC,ORDER_ID DESC
                                                    <cfelseif arguments.sort_type eq 11>
                                                        ORDER_EMPLOYEE_NAME +' '+ ORDER_EMPLOYEE_SURNAME ASC,ORDER_ID
                                                    <cfelseif arguments.sort_type eq 12>
                                                        ORDER_EMPLOYEE_NAME +' '+ ORDER_EMPLOYEE_SURNAME DESC,ORDER_ID DESC
                                                    <cfelseif arguments.sort_type eq 13>
                                                        NETTOTAL ASC,ORDER_ID
                                                    <cfelseif arguments.sort_type eq 14>
                                                        NETTOTAL DESC,ORDER_ID DESC
                                                    <cfelse>
                                                        ORDER_ID DESC
                                                    </cfif>
												) AS RowNum,(SELECT COUNT(*) FROM CTE1) AS QUERY_COUNT
				FROM
					CTE1
			)
			SELECT
				CTE2.*
			FROM
				CTE2
			WHERE
				RowNum BETWEEN #arguments.startrow# and #arguments.startrow#+(#arguments.maxrows#-1)   
	 </cfquery>
    <cfreturn GET_ORDER_LIST/>
</cffunction>
</cfcomponent>