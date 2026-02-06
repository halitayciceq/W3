<cfif form.active_company neq session.ep.company_id>
	<script type="text/javascript">
		alert("<cf_get_lang no ='588.İşlemin Şirketi İle Aktif Şirketiniz Farklı Çalıştığınız Şirketi Kontrol Ediniz'>!");
		window.location.href='<cfoutput>#request.self#?fuseaction=#listgetat(attributes.fuseaction,1,'.')#.list_order</cfoutput>';
	</script>
	<cfabort>
</cfif>
<cfif not isdefined('attributes.price') or not len(attributes.price)>
	<cfif isDefined("attributes.basket_net_total") and len(attributes.basket_net_total)>
		<cfset attributes.price = attributes.basket_net_total>
	<cfelse>
		<cfset attributes.price = 0>
	</cfif>
</cfif>

<cfif len(attributes.deliverdate)><cf_date tarih="attributes.deliverdate"></cfif>
<cfif len(attributes.ship_date)><cf_date tarih="attributes.ship_date"></cfif>

<cfif isDefined("attributes.company_id") and len(attributes.company_id)>
	<cfquery name="get_customer_info" datasource="#dsn2#">
		SELECT
			SALES_COUNTY,
			COMPANY_VALUE_ID AS CUSTOMER_VALUE_ID,
			RESOURCE_ID,
			IMS_CODE_ID
		FROM
			#dsn_alias#.COMPANY
		WHERE
			COMPANY_ID=#attributes.company_id#
	</cfquery>
<cfelseif isdefined("attributes.consumer_id") and len(attributes.consumer_id)>
	<cfquery name="get_customer_info" datasource="#dsn2#">
		SELECT
			SALES_COUNTY,
			CUSTOMER_VALUE_ID,
			RESOURCE_ID,
			IMS_CODE_ID
		FROM
			#dsn_alias#.CONSUMER
		WHERE
			CONSUMER_ID=#attributes.consumer_id#
	</cfquery>
</cfif>

<cfquery name="get_gen_paper" datasource="#dsn2#">
	SELECT 
		*
	FROM
		#dsn3_alias#.GENERAL_PAPERS 
	WHERE 
		ZONE_TYPE = 0 AND
		PAPER_TYPE = 0
</cfquery>
<cfset paper_code = evaluate('get_gen_paper.ORDER_NO')>
<cfset paper_number = evaluate('get_gen_paper.ORDER_NUMBER') +1>
<cfset paper_full = '#paper_code#-#paper_number#'>
<cfquery name="SET_MAX_PAPER" datasource="#dsn2#">
	UPDATE
		#dsn3_alias#.GENERAL_PAPERS
	SET
		ORDER_NUMBER = ORDER_NUMBER+1
	WHERE
		PAPER_TYPE = 0 AND
		ZONE_TYPE = 0
</cfquery>
<cfset wrk_id = dateformat(now(),'YYYYMMDD')&timeformat(now(),'HHmmss')&'_#session.ep.userid#_'&round(rand()*100)>
<cfquery name="ADD_ORDER" datasource="#dsn2#">
	INSERT INTO
		#dsn3_alias#.ORDERS
	(
		WRK_ID,
		ZONE_ID,
		RESOURCE_ID,
		IMS_CODE_ID,
		CUSTOMER_VALUE_ID,
		COMPANY_ID,
		PARTNER_ID,
		CONSUMER_ID,
	<cfif attributes.ref_member_type is 'partner'>
		REF_PARTNER_ID,
		REF_COMPANY_ID,				
	<cfelseif attributes.ref_member_type is 'consumer'>
		REF_CONSUMER_ID,
	<cfelse>
		REF_PARTNER_ID,
		REF_COMPANY_ID,
		REF_CONSUMER_ID,
	</cfif>			
		ORDER_NUMBER,
		ORDER_STAGE,
		ORDER_DATE,
		ORDER_STATUS,
		PRIORITY_ID, 
		COMMETHOD_ID,			
		DELIVERDATE,
		SHIP_DATE,
		DELIVER_DEPT_ID,
		LOCATION_ID,
		PAYMETHOD,
		OFFER_ID,
		ORDER_EMPLOYEE_ID,
	<cfif len(attributes.sales_member) and (attributes.sales_member_type eq "partner")>
		SALES_PARTNER_ID,
	</cfif>
	<cfif len(attributes.sales_member) and (attributes.sales_member_type eq "consumer")>
		SALES_CONSUMER_ID,
	</cfif>
		SHIP_ADDRESS,
        COUNTRY_ID,
		CITY_ID,
		COUNTY_ID,
		ORDER_HEAD,
		ORDER_DETAIL,
		GROSSTOTAL,
		TAXTOTAL,
		DISCOUNTTOTAL,
		NETTOTAL,
		INCLUDED_KDV,
	<cfif isdefined("form.basket_money")>
		OTHER_MONEY,
		OTHER_MONEY_VALUE,
	</cfif>
		PURCHASE_SALES,
		ORDER_ZONE,
		SHIP_METHOD,
		RESERVED,
		PROJECT_ID,
		DUE_DATE,
		REF_NO,
		SA_DISCOUNT,
		GENERAL_PROM_ID,
		GENERAL_PROM_LIMIT,
		GENERAL_PROM_AMOUNT,
		GENERAL_PROM_DISCOUNT, 
		FREE_PROM_ID,
		FREE_PROM_LIMIT,
		FREE_PROM_AMOUNT,
		FREE_PROM_COST,
		FREE_PROM_STOCK_ID,
		FREE_STOCK_PRICE,
		FREE_STOCK_MONEY,
		CARD_PAYMETHOD_ID,
		CARD_PAYMETHOD_RATE,
		SALES_ADD_OPTION_ID,
		IS_INSTALMENT,
		FRM_BRANCH_ID,
		RECORD_DATE,
		RECORD_IP,
		RECORD_EMP
	)
	VALUES
	(
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#wrk_id#">,
		<cfif isdefined("get_customer_info.SALES_COUNTY") and len(get_customer_info.SALES_COUNTY)>#get_customer_info.SALES_COUNTY#<cfelse>NULL</cfif>,
		<cfif isdefined("get_customer_info.RESOURCE_ID") and len(get_customer_info.RESOURCE_ID)>#get_customer_info.RESOURCE_ID#<cfelse>NULL</cfif>,
		<cfif isdefined("get_customer_info.IMS_CODE_ID") and len(get_customer_info.IMS_CODE_ID)>#get_customer_info.IMS_CODE_ID#<cfelse>NULL</cfif>,
		<cfif isdefined("get_customer_info.CUSTOMER_VALUE_ID") and len(get_customer_info.CUSTOMER_VALUE_ID)>#get_customer_info.CUSTOMER_VALUE_ID#<cfelse>NULL</cfif>,
		<cfif isDefined("attributes.company_id") and len(attributes.company_id)>
		#attributes.company_id#,
		<cfif isDefined("attributes.partner_id") and len(attributes.partner_id)>#attributes.partner_id#<cfelse>NULL</cfif>,
		NULL,
		<cfelse>
		NULL,
		NULL,
		#attributes.consumer_id#,
		</cfif>
		<cfif attributes.ref_member_type is 'partner'>
		#attributes.ref_member_id#,
		#attributes.ref_company_id#,					
		<cfelseif attributes.ref_member_type is 'consumer'>
		#attributes.ref_member_id#,
		<cfelse>
		NULL,
		NULL,
		NULL,				
		</cfif>			
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#paper_full#">,				
		#attributes.process_stage#,
		<cfif len(attributes.order_date)>#attributes.order_date#<cfelse>NULL</cfif>,
		1,
		<cfif isdefined("attributes.priority_id")>#attributes.priority_id#<cfelse>NULL</cfif>, 
        <cfif isdefined("attributes.commethod_id") and len(attributes.commethod_id)>#attributes.commethod_id#<cfelse>NULL</cfif>,
        <cfif len(attributes.deliverdate)>#attributes.deliverdate#<cfelse>NULL</cfif>,
        <cfif len(attributes.ship_date)>#attributes.ship_date#<cfelse>NULL</cfif>,
        <cfif isdefined("attributes.deliver_dept_id") and len(attributes.deliver_dept_id) and len(attributes.deliver_dept_name)>
		#attributes.deliver_dept_id#,
		<cfelse>
		NULL,
		</cfif>
		<cfif isdefined("attributes.deliver_loc_id") and len(attributes.deliver_loc_id) and len(attributes.deliver_dept_name)>
		#attributes.deliver_loc_id#,
		<cfelse>
		NULL,
        </cfif>
        <cfif len(attributes.paymethod_id) and len(attributes.paymethod)>#attributes.paymethod_id#<cfelse>NULL</cfif>,
        <cfif isdefined("attributes.offer_id") and len(attributes.offer_id) and len(attributes.offer_head)>#attributes.offer_id#<cfelse>NULL</cfif>,
        <cfif len(attributes.order_employee_id) and len(attributes.order_employee)>#attributes.order_employee_id#<cfelse>NULL</cfif>, 
        <cfif isdefined("attributes.sales_member") and len(attributes.sales_member) and isdefined("attributes.sales_member_type") and(attributes.sales_member_type eq "PARTNER")>
		#attributes.sales_member_id#,
		</cfif>
		<cfif isdefined("attributes.sales_member") and len(attributes.sales_member) and isdefined("attributes.sales_member_type") and (attributes.sales_member_type eq "CONSUMER")>
		#attributes.sales_member_id#,
		</cfif>
		<cfif isdefined("attributes.ship_address") and len(attributes.ship_address)><cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.ship_address#"><cfelse>NULL</cfif>,
		<cfif isdefined("attributes.country") and len(attributes.country)>#attributes.country#<cfelse>NULL</cfif>,
		<cfif isdefined("attributes.city") and len(attributes.city)>#attributes.city#<cfelse>NULL</cfif>,
        <cfif isdefined("attributes.county_id") and len(attributes.county_id)>#attributes.county_id#<cfelse>NULL</cfif>,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.order_head#">,
		<cfif isdefined('attributes.order_detail') and len(attributes.order_detail)><cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.order_detail#"><cfelse>NULL</cfif>,
        <cfif isdefined("form.basket_gross_total") and len(form.basket_gross_total)>#form.basket_gross_total#<cfelse>NULL</cfif>,
        <cfif isdefined("form.basket_tax_total") and len(form.basket_tax_total)>#form.basket_tax_total#<cfelse>NULL</cfif>,
        <cfif isdefined("form.basket_discount_total") and len(form.basket_discount_total)>#form.basket_discount_total#<cfelse>NULL</cfif>,
        <cfif isdefined("form.basket_net_total") and len(form.basket_net_total)>#form.basket_net_total#<cfelse>NULL</cfif>,
        <cfif isdefined('included_kdv')>1<cfelse>0</cfif>,
        <cfif isdefined("form.basket_money")>
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.basket_money#">,
		#((form.basket_net_total*form.basket_rate1)/form.basket_rate2)#,
		</cfif>
		1,
		0,
		<cfif isdefined("attributes.ship_method_id") and len(attributes.ship_method_id)>#attributes.ship_method_id#<cfelse>NULL</cfif>,				
        <cfif isdefined('attributes.reserved')>1<cfelse>0</cfif>,
        <cfif isdefined("attributes.project_id") and len(attributes.project_id)>#attributes.project_id#<cfelse>NULL</cfif>,
        <cfif isdefined("attributes.basket_due_value_date_") and len(attributes.basket_due_value_date_)>#attributes.basket_due_value_date_#<cfelse>NULL</cfif>,
        <cfif isdefined("attributes.ref_no") and len(attributes.ref_no)><cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.ref_no#"><cfelse>NULL</cfif>,
    	<cfif isdefined("form.genel_indirim") and len(form.genel_indirim)><cfqueryparam cfsqltype="cf_sql_varchar" value="#form.genel_indirim#"><cfelse>NULL</cfif>,
        <cfif isdefined("attributes.general_prom_id") and len(attributes.general_prom_id)>#attributes.general_prom_id#<cfelse>NULL</cfif>,
        <cfif isdefined("attributes.general_prom_limit") and len(attributes.general_prom_limit)>#attributes.general_prom_limit#<cfelse>NULL</cfif>,
        <cfif isdefined("attributes.general_prom_amount") and len(attributes.general_prom_amount)>#attributes.general_prom_amount#<cfelse>NULL</cfif>,
        <cfif isdefined("attributes.general_prom_discount") and len(attributes.general_prom_discount)>#attributes.general_prom_discount#<cfelse>NULL</cfif>,
        <cfif isdefined("attributes.free_prom_id") and len(attributes.free_prom_id)>#attributes.free_prom_id#<cfelse>NULL</cfif>,
        <cfif isdefined("attributes.free_prom_limit") and len(attributes.free_prom_limit)>#attributes.free_prom_limit#<cfelse>NULL</cfif>,
        <cfif isdefined("attributes.free_prom_amount") and len(attributes.free_prom_amount)>#attributes.free_prom_amount#<cfelse>NULL</cfif>,
        <cfif isdefined("attributes.free_prom_cost") and len(attributes.free_prom_cost)>#attributes.free_prom_cost#<cfelse>NULL</cfif>,
        <cfif isdefined("attributes.free_prom_stock_id") and len(attributes.free_prom_stock_id)>#attributes.free_prom_stock_id#<cfelse>NULL</cfif>,
        <cfif isdefined("attributes.free_stock_price") and len(attributes.free_stock_price)>#attributes.free_stock_price#<cfelse>NULL</cfif>,
        <cfif isdefined("attributes.free_stock_money") and len(attributes.free_stock_money)><cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.free_stock_money#"><cfelse>NULL</cfif>,
        <cfif isdefined("attributes.card_paymethod_id") and len(attributes.card_paymethod_id)>
		#attributes.card_paymethod_id#,
		<cfif isdefined("attributes.commission_rate") and len(attributes.commission_rate)>
			#attributes.commission_rate#,
		<cfelse>
			NULL,
		</cfif>
		<cfelse>
		NULL,
		NULL,
        </cfif>
        <cfif isDefined('attributes.sales_add_option') and len(attributes.sales_add_option)>#attributes.sales_add_option#<cfelse>NULL</cfif>,	
        <cfif isDefined("is_from_instalment") and is_from_instalment eq 1>1<cfelse>NULL</cfif>,	
        <cfif len(ListGetAt(session.ep.user_location,2,"-"))>#ListGetAt(session.ep.user_location,2,"-")#<cfelse>NULL</cfif>,
        #now()#,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.remote_addr#">,
		#session.ep.userid#
	)
</cfquery>
<cfquery name="GET_MAX_ORDER" datasource="#dsn2#">
	SELECT
		MAX(ORDER_ID) AS MAX_ID
	FROM
		#dsn3_alias#.ORDERS
	WHERE
	 	WRK_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#wrk_id#">
</cfquery>
<cfloop from="1" to="#attributes.rows_#" index="i">
	<cf_date tarih="attributes.deliver_date#i#">
	<cf_date tarih="attributes.reserve_date#i#">
	<cfif session.ep.our_company_info.spect_type  and isdefined('attributes.is_production#i#') and evaluate('attributes.is_production#i#') eq 1 and not isdefined('attributes.spect_id#i#') or not len(evaluate('attributes.spect_id#i#'))>
		<cfset dsn_type=dsn2>
		<cfinclude template="../../objects/query/add_basket_spec.cfm">
	</cfif>
	<cfif session.ep.our_company_info.spect_type eq 5 and isdefined('attributes.is_production#i#') and evaluate('attributes.is_production#i#') eq 1 and isdefined('attributes.spect_id#i#') and len(evaluate('attributes.spect_id#i#'))>
	<!--- metal icin yapilan spec icin secilen stock_row satirlarini  STOCKS_ROW_RESERVED tablosuna kaydedecek... --->
		<cfquery name="get_spect" datasource="#dsn2#">
			SELECT
				SPECTS_ROW.RELATED_SPECT_ID,
				SPECTS_ROW.AMOUNT_VALUE,
				SPECTS_ROW.PRODUCT_ID,
				SPECTS_ROW.STOCK_ID,
				SPECTS_ROW.PRODUCT_MANUFACT_CODE,
				SPECTS_ROW.SHELF_NUMBER
			FROM
				#dsn3_alias#.SPECTS,
				#dsn3_alias#.SPECTS_ROW
			WHERE
				SPECTS.SPECT_VAR_ID=#evaluate('attributes.spect_id#i#')# AND
				SPECTS.SPECT_VAR_ID=SPECTS_ROW.SPECT_ID AND
				SPECTS_ROW.AMOUNT_VALUE >0
		</cfquery>
		<!--- rezerve edilecek stok --->
		<cfquery name="ADD_STOCK_RESERVED" datasource="#dsn2#">
			INSERT INTO
				STOCKS_ROW_RESERVED
				(
					PRODUCT_ID,
					STOCK_ID,
					STOCK_OUT_RESERVED,
					<!--- STORE,
					STORE_LOCATION, --->
					SPECT_VAR_ID,
					ORDER_ID,
					PRODUCT_MANUFACT_CODE,
					SHELF_NUMBER
				)
				VALUES
				(
					<cfif len(get_spect.PRODUCT_ID)>#get_spect.PRODUCT_ID#<cfelse>NULL</cfif>,
					<cfif len(get_spect.STOCK_ID)>#get_spect.STOCK_ID#<cfelse>NULL</cfif>,
					<cfif len(get_spect.AMOUNT_VALUE)>#get_spect.AMOUNT_VALUE#<cfelse>0</cfif>,
					<!---<cfif len(form_store)>#form_store#<cfelse>NULL</cfif>,
					<cfif len(form_store_location)>#form_store_location#<cfelse>NULL</cfif>, --->
					<cfif len(get_spect.RELATED_SPECT_ID)>#get_spect.RELATED_SPECT_ID#<cfelse>NULL</cfif>,
					<cfif len(get_max_order.max_id)>#get_max_order.max_id#<cfelse>NULL</cfif>,
					<cfif len(get_spect.PRODUCT_MANUFACT_CODE)>#get_spect.PRODUCT_MANUFACT_CODE#<cfelse>NULL</cfif>,
					<cfif len(get_spect.SHELF_NUMBER)>#get_spect.SHELF_NUMBER#<cfelse>NULL</cfif>
					
				)
		</cfquery>
	</cfif>
	
	<cfquery name="ADD_ORDER_ROW" datasource="#dsn2#">
		INSERT INTO
			#dsn3_alias#.ORDER_ROW
		(
			ORDER_ID,
			PRODUCT_ID,
			STOCK_ID,
			QUANTITY,
			UNIT,
			UNIT_ID,
			<cfif len(evaluate("attributes.price#i#"))>PRICE,</cfif>
			TAX,
			NETTOTAL,
			DUEDATE,
			PRODUCT_NAME,
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
			OTHER_MONEY,
			OTHER_MONEY_VALUE,
		<cfif isdefined('attributes.spect_id#i#') and len(evaluate('attributes.spect_id#i#'))>
			SPECT_VAR_ID,
			SPECT_VAR_NAME,
		</cfif>
			LOT_NO,
			PRICE_OTHER,
			<!--- COST_ID, --->
			COST_PRICE,
			EXTRA_COST,
			MARJ,
			<!--- Yeni Eklenen Alanlar. Promosyon İle İlgili --->
			PROM_COMISSION,
			PROM_COST,
			DISCOUNT_COST,
			PROM_ID,
			IS_PROMOTION,
			PROM_STOCK_ID,
			IS_COMMISSION,
			ORDER_ROW_CURRENCY,
			RESERVE_TYPE,
			RESERVE_DATE,
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
			ROW_PRO_MATERIAL_ID,
			PRICE_CAT,
			CATALOG_ID,
			LIST_PRICE,
			NUMBER_OF_INSTALLMENT,
			BASKET_EMPLOYEE_ID,
			KARMA_PRODUCT_ID,
			OTV_ORAN,
			OTVTOTAL,
			WRK_ROW_ID,
			WRK_ROW_RELATION_ID,
			ROW_PROJECT_ID,
			WIDTH_VALUE,
			DEPTH_VALUE,
			HEIGHT_VALUE
			<cfif isdefined('attributes.row_exp_center_id#i#') and len(evaluate("attributes.row_exp_center_id#i#")) and isdefined('attributes.row_exp_center_name#i#') and len(evaluate("attributes.row_exp_center_name#i#"))>,EXPENSE_CENTER_ID</cfif>
			<cfif isdefined('attributes.row_exp_item_id#i#') and len(evaluate("attributes.row_exp_item_id#i#")) and isdefined('attributes.row_exp_item_name#i#') and len(evaluate("attributes.row_exp_item_name#i#"))>,EXPENSE_ITEM_ID</cfif>
			<cfif isdefined('attributes.row_activity_id#i#') and len(evaluate("attributes.row_activity_id#i#"))>,ACTIVITY_TYPE_ID</cfif>
			<cfif isdefined('attributes.row_acc_code#i#') and len(evaluate("attributes.row_acc_code#i#"))>,ACC_CODE</cfif>   
		)
		VALUES
		(
			#get_max_order.max_id#,
			#evaluate("attributes.product_id#i#")#,
			#evaluate("attributes.stock_id#i#")#,
			#evaluate("attributes.amount#i#")#,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.unit#i#')#">,
			#evaluate("attributes.unit_id#i#")#,
			<cfif len(evaluate("attributes.price#i#"))>
			#evaluate("attributes.price#i#")#,
			</cfif>
			#evaluate("attributes.tax#i#")#,
			<cfif isdefined("attributes.row_nettotal#i#") and len(evaluate("attributes.row_nettotal#i#"))>#evaluate("attributes.row_nettotal#i#")#<cfelse>NULL</cfif>,
            <cfif isdefined("attributes.duedate#i#") and len(evaluate("attributes.duedate#i#"))>#evaluate("attributes.duedate#i#")#,<cfelse>0,</cfif>
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.product_name#i#')#">,
			<cfif isdefined("attributes.deliver_date#i#") and isdate(evaluate('attributes.deliver_date#i#'))>#evaluate('attributes.deliver_date#i#')#<cfelse>NULL</cfif>,
            <cfif isdefined("attributes.deliver_dept#i#") and len(trim(evaluate("attributes.deliver_dept#i#"))) and len(listfirst(evaluate("attributes.deliver_dept#i#"),"-"))>
				#listfirst(evaluate("attributes.deliver_dept#i#"),"-")#,
			<cfelseif isdefined('attributes.deliver_dept_id') and len(attributes.deliver_dept_id)>
				#attributes.deliver_dept_id#,
			<cfelse>
				NULL,
			</cfif>
			<cfif isdefined("attributes.deliver_dept#i#") and listlen(trim(evaluate("attributes.deliver_dept#i#")),"-") eq 2 and len(listlast(evaluate("attributes.deliver_dept#i#"),"-"))>
				#listlast(evaluate("attributes.deliver_dept#i#"),"-")#,
			<cfelseif isdefined('attributes.deliver_loc_id') and len(attributes.deliver_loc_id)>
				#attributes.deliver_loc_id#,
			<cfelse>
				NULL,
			</cfif>
            <cfif isdefined('attributes.indirim1#i#')>#evaluate('attributes.indirim1#i#')#<cfelse>NULL</cfif>,
            <cfif isdefined('attributes.indirim2#i#')>#evaluate('attributes.indirim2#i#')#<cfelse>NULL</cfif>,
            <cfif isdefined('attributes.indirim3#i#')>#evaluate('attributes.indirim3#i#')#<cfelse>NULL</cfif>,
            <cfif isdefined('attributes.indirim4#i#')>#evaluate('attributes.indirim4#i#')#<cfelse>NULL</cfif>,
            <cfif isdefined('attributes.indirim5#i#')>#evaluate('attributes.indirim5#i#')#<cfelse>NULL</cfif>,
            <cfif isdefined('attributes.indirim6#i#')>#evaluate('attributes.indirim6#i#')#<cfelse>NULL</cfif>,
            <cfif isdefined('attributes.indirim7#i#')>#evaluate('attributes.indirim7#i#')#<cfelse>NULL</cfif>,
            <cfif isdefined('attributes.indirim8#i#')>#evaluate('attributes.indirim8#i#')#<cfelse>NULL</cfif>,
            <cfif isdefined('attributes.indirim9#i#')>#evaluate('attributes.indirim9#i#')#<cfelse>NULL</cfif>,
            <cfif isdefined('attributes.indirim10#i#')>#evaluate('attributes.indirim10#i#')#<cfelse>NULL</cfif>,
            <cfif isdefined('attributes.other_money_#i#')><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.other_money_#i#')#"><cfelse>NULL</cfif>,
            <cfif isdefined("attributes.other_money_value_#i#") and len(evaluate("attributes.other_money_value_#i#"))>#evaluate("attributes.other_money_value_#i#")#<cfelse>1</cfif>,
            <cfif isdefined('attributes.spect_id#i#') and len(evaluate('attributes.spect_id#i#'))>
			#evaluate('attributes.spect_id#i#')#,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.spect_name#i#')#">,
            </cfif>
            <cfif isdefined('attributes.lot_no#i#') and len(evaluate('attributes.lot_no#i#'))>#evaluate('attributes.lot_no#i#')#<cfelse>NULL</cfif>,
            <cfif isdefined('attributes.price_other#i#') and len(evaluate('attributes.price_other#i#'))>#evaluate("attributes.price_other#i#")#<cfelse>NULL</cfif>,
            <!--- <cfif isdefined('attributes.cost_id#i#') and len(evaluate('attributes.cost_id#i#'))>#evaluate('attributes.cost_id#i#')#<cfelse>NULL</cfif>, --->
            <cfif isdefined('attributes.net_maliyet#i#') and len(evaluate('attributes.net_maliyet#i#'))>#evaluate('attributes.net_maliyet#i#')#<cfelse>0</cfif>,
            <cfif isdefined('attributes.extra_cost#i#') and len(evaluate('attributes.extra_cost#i#'))>#evaluate('attributes.extra_cost#i#')#<cfelse>0</cfif>,
            <cfif isdefined('attributes.marj#i#') and len(evaluate('attributes.marj#i#'))>#evaluate('attributes.marj#i#')#<cfelse>0</cfif>,
            <cfif isdefined('attributes.promosyon_yuzde#i#') and len(evaluate('attributes.promosyon_yuzde#i#'))>#evaluate('attributes.promosyon_yuzde#i#')#<cfelse>NULL</cfif>,
            <cfif isdefined('attributes.promosyon_maliyet#i#') and len(evaluate('attributes.promosyon_maliyet#i#'))>#evaluate('attributes.promosyon_maliyet#i#')#<cfelse>0</cfif>,
            <cfif isdefined('attributes.iskonto_tutar#i#') and len(evaluate('attributes.iskonto_tutar#i#'))>#evaluate('attributes.iskonto_tutar#i#')#<cfelse>NULL</cfif>,
            <cfif isdefined('attributes.row_promotion_id#i#') and len(evaluate('attributes.row_promotion_id#i#'))>#evaluate('attributes.row_promotion_id#i#')#<cfelse>NULL</cfif>,
            <cfif isdefined('attributes.is_promotion#i#') and len(evaluate('attributes.is_promotion#i#'))>#evaluate('attributes.is_promotion#i#')#<cfelse>0</cfif>,
            <cfif isdefined('attributes.prom_stock_id#i#') and len(evaluate('attributes.prom_stock_id#i#'))>#evaluate('attributes.prom_stock_id#i#')#<cfelse>NULL</cfif>,
            <cfif isdefined('attributes.is_commission#i#') and len(evaluate('attributes.is_commission#i#'))>#evaluate('attributes.is_commission#i#')#<cfelse>0</cfif>,
            <cfif isdefined("attributes.order_currency#i#") and len(evaluate("attributes.order_currency#i#"))>#evaluate("attributes.order_currency#i#")#<cfelse>NULL</cfif>,
            <cfif isdefined("attributes.reserve_type#i#") and len(evaluate("attributes.reserve_type#i#"))>#evaluate("attributes.reserve_type#i#")#<cfelse>NULL</cfif>,
            <cfif isdefined("attributes.reserve_date#i#") and isdate(evaluate('attributes.reserve_date#i#'))>#evaluate('attributes.reserve_date#i#')#<cfelse>NULL</cfif>,
            <cfif isdefined('attributes.row_unique_relation_id#i#') and len(evaluate('attributes.row_unique_relation_id#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.row_unique_relation_id#i#')#"><cfelse>NULL</cfif>,
            <cfif isdefined('attributes.prom_relation_id#i#') and len(evaluate('attributes.prom_relation_id#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.prom_relation_id#i#')#"><cfelse>NULL</cfif>,
            <cfif isdefined('attributes.product_name_other#i#') and len(evaluate('attributes.product_name_other#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.product_name_other#i#')#"><cfelse>NULL</cfif>,
            <cfif isdefined('attributes.amount_other#i#') and len(evaluate('attributes.amount_other#i#'))>#evaluate('attributes.amount_other#i#')#<cfelse>NULL</cfif>,
            <cfif isdefined('attributes.unit_other#i#') and len(evaluate('attributes.unit_other#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.unit_other#i#')#"><cfelse>NULL</cfif>,
            <cfif isdefined('attributes.ek_tutar#i#') and len(evaluate('attributes.ek_tutar#i#'))>#evaluate('attributes.ek_tutar#i#')#<cfelse>NULL</cfif>,
            <cfif isdefined('attributes.ek_tutar_total#i#') and len(evaluate('attributes.ek_tutar_total#i#'))>#evaluate('attributes.ek_tutar_total#i#')#<cfelse>NULL</cfif>,
            <cfif isdefined('attributes.shelf_number#i#') and len(evaluate('attributes.shelf_number#i#'))>#evaluate('attributes.shelf_number#i#')#<cfelse>NULL</cfif>,
            <cfif isdefined('attributes.manufact_code#i#') and len(evaluate('attributes.manufact_code#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.manufact_code#i#')#"><cfelse>NULL</cfif>,
			<cfif isdefined('attributes.basket_extra_info#i#') and len(evaluate('attributes.basket_extra_info#i#'))><cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('attributes.basket_extra_info#i#')#"><cfelse>NULL</cfif>,
			<cfif isdefined('attributes.select_info_extra#i#') and len(evaluate('attributes.select_info_extra#i#'))><cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('attributes.select_info_extra#i#')#"><cfelse>NULL</cfif>,
			<cfif isdefined('attributes.detail_info_extra#i#') and len(evaluate('attributes.detail_info_extra#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.detail_info_extra#i#')#"><cfelse>NULL</cfif>,
            <cfif isdefined('attributes.row_ship_id#i#') and len(evaluate('attributes.row_ship_id#i#'))>#listfirst(evaluate("attributes.row_ship_id#i#"),';')#<cfelse>NULL</cfif>,
            <cfif isdefined('attributes.price_cat#i#') and len(evaluate('attributes.price_cat#i#'))>#evaluate('attributes.price_cat#i#')#<cfelse>NULL</cfif>,
            <cfif isdefined('attributes.row_catalog_id#i#') and len(evaluate('attributes.row_catalog_id#i#'))>#evaluate('attributes.row_catalog_id#i#')#<cfelse>NULL</cfif>,
            <cfif isdefined('attributes.list_price#i#') and len(evaluate('attributes.list_price#i#'))>#evaluate('attributes.list_price#i#')#<cfelse>NULL</cfif>,
            <cfif isdefined('attributes.number_of_installment#i#') and len(evaluate('attributes.number_of_installment#i#'))>#evaluate('attributes.number_of_installment#i#')#<cfelse>NULL</cfif>,
            <cfif isdefined('attributes.basket_employee_id#i#') and len(evaluate('attributes.basket_employee_id#i#')) and isdefined('attributes.basket_employee#i#') and len(evaluate('attributes.basket_employee#i#'))>#evaluate('attributes.basket_employee_id#i#')#<cfelse>NULL</cfif>,
            <cfif isdefined('attributes.karma_product_id#i#') and len(evaluate('attributes.karma_product_id#i#'))>#evaluate('attributes.karma_product_id#i#')#<cfelse>NULL</cfif>,
            <cfif isdefined('attributes.otv_oran#i#') and len(evaluate('attributes.otv_oran#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.otv_oran#i#')#"><cfelse>NULL</cfif>,
            <cfif isdefined('attributes.row_otvtotal#i#') and len(evaluate('attributes.row_otvtotal#i#'))>#evaluate('attributes.row_otvtotal#i#')#<cfelse>NULL</cfif>,				
            <cfif isdefined('attributes.wrk_row_id#i#') and len(evaluate('attributes.wrk_row_id#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.wrk_row_id#i#')#"><cfelse>NULL</cfif>,
            <cfif isdefined('attributes.wrk_row_relation_id#i#') and len(evaluate('attributes.wrk_row_relation_id#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.wrk_row_relation_id#i#')#"><cfelse>NULL</cfif>,
            <cfif isdefined('attributes.row_project_id#i#') and len(evaluate('attributes.row_project_id#i#')) and isdefined('attributes.row_project_name#i#') and len(evaluate('attributes.row_project_name#i#'))>#evaluate('attributes.row_project_id#i#')#<cfelse>NULL</cfif>,
            <cfif isdefined('attributes.row_width#i#') and len(evaluate('attributes.row_width#i#'))>#evaluate('attributes.row_width#i#')#<cfelse>NULL</cfif>,
            <cfif isdefined('attributes.row_depth#i#') and len(evaluate('attributes.row_depth#i#'))>#evaluate('attributes.row_depth#i#')#<cfelse>NULL</cfif>,
			<cfif isdefined('attributes.row_height#i#') and len(evaluate('attributes.row_height#i#'))>#evaluate('attributes.row_height#i#')#<cfelse>NULL</cfif>
			<cfif isdefined('attributes.row_exp_center_id#i#') and len(evaluate("attributes.row_exp_center_id#i#")) and isdefined('attributes.row_exp_center_name#i#') and len(evaluate("attributes.row_exp_center_name#i#"))>,<cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('attributes.row_exp_center_id#i#')#"></cfif>
			<cfif isdefined('attributes.row_exp_item_id#i#') and len(evaluate("attributes.row_exp_item_id#i#")) and isdefined('attributes.row_exp_item_name#i#') and len(evaluate("attributes.row_exp_item_name#i#"))>,<cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('attributes.row_exp_item_id#i#')#"></cfif>
			<cfif isdefined('attributes.row_activity_id#i#') and len(evaluate("attributes.row_activity_id#i#"))>,<cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('attributes.row_activity_id#i#')#"></cfif>
			<cfif isdefined('attributes.row_acc_code#i#') and len(evaluate("attributes.row_acc_code#i#"))>,<cfqueryparam cfsqltype="cf_sql_nvarchar" value="#evaluate('attributes.row_acc_code#i#')#"></cfif>
		)
	</cfquery>
	<!---  urun asortileri --->			
	<cfquery name="GET_MAX_ORDER_ROW" datasource="#dsn2#">
		SELECT
			MAX(ORDER_ROW_ID) AS ORDER_ROW_ID
		FROM
			#dsn3_alias#.ORDER_ROW
	</cfquery>			
	<cfset attributes.ROW_MAIN_ID = get_max_order_row.order_row_id>
	<cfset row_id = I>
	<cfset ACTION_TYPE_ID = 2>
	<cfset attributes.product_id = evaluate("attributes.product_id#i#")>
	<cfset dsn_type_= dsn2>
	<cfinclude template="add_assortment_textile_js.cfm">
	<!--- //  urun asortileri --->
</cfloop>
<cfif isDefined("attributes.subscription_id")><!--- sistemden sipariş ekleme --->
	<cfquery name="ADD_SUBSCRIPTION_ORDER" datasource="#dsn2#">
		INSERT INTO
			#dsn3_alias#.SUBSCRIPTION_CONTRACT_ORDER
		(						
			SUBSCRIPTION_ID,
			ORDER_ID
		)
		VALUES
		(
			#attributes.subscription_id#,
			#get_max_order.max_id#
		)
	</cfquery>
</cfif>
<cfscript>
basket_kur_ekle(action_id:GET_MAX_ORDER.MAX_ID,table_type_id:3,process_type:0,transaction_dsn:dsn2);
add_reserve_row(
	reserve_order_id:GET_MAX_ORDER.MAX_ID,
	reserve_action_type:0,
	is_order_process:0,
	is_purchase_sales:1,
	process_db :dsn2
	);
</cfscript>
