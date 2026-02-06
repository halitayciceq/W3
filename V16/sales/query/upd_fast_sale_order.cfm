<cfif form.active_company neq session.ep.company_id>
	<script type="text/javascript">
		alert("<cf_get_lang no ='588.İşlemin Şirketi İle Aktif Şirketiniz Farklı Çalıştığınız Şirketi Kontrol Ediniz'>!");
		window.location.href='<cfoutput>#request.self#?fuseaction=#listgetat(attributes.fuseaction,1,'.')#.list_order</cfoutput>';
	</script>
	<cfabort>
</cfif>
<cfquery name="CONTROL_ORDER_PROCESS" datasource="#dsn2#">
	SELECT IS_PROCESSED FROM #dsn3_alias#.ORDERS WHERE ORDER_ID = #attributes.order_id#
</cfquery>
<cfif CONTROL_ORDER_PROCESS.IS_PROCESSED neq 1>
	<cfquery name="KONTROL" datasource="#dsn2#">
		SELECT ORDER_ID FROM #dsn3_alias#.PRODUCTION_ORDERS_ROW WHERE ORDER_ID = #attributes.order_id#
	</cfquery>
	<cfif kontrol.recordcount and session.ep.admin neq 1>
	<script type="text/javascript">
		alert("<cf_get_lang no ='591.Bu sipariş için üretim emri verilmiştir Güncelleme Yapılamaz'>!!!");
		window.location.href='<cfoutput>#cgi.referer#</cfoutput>';
	</script>
	<cfabort>
	</cfif>
</cfif>
<cfif not isdefined('attributes.price') or not len(attributes.price)>
	<cfif isDefined("attributes.basket_net_total") and len(attributes.basket_net_total)>
		<cfset attributes.price = attributes.basket_net_total>
	<cfelse>
		<cfset attributes.price = 0>
	</cfif>
</cfif>
<cfset transaction_dsn = dsn2>
<!--- History --->
<cfinclude template="add_fast_sale_order_history.cfm">
<!--- History --->

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
<cfif len(attributes.deliverdate)><cf_date tarih="attributes.deliverdate"></cfif>
<cfif len(attributes.ship_date)><cf_date tarih="attributes.ship_date"></cfif>
<cfquery name="UPD_ORDER" datasource="#dsn2#">
	UPDATE
		#dsn3_alias#.ORDERS
	SET			
	<cfif isdefined("attributes.company_id") and len(attributes.company_id)>
		PARTNER_ID = <cfif isDefined("attributes.member_id") and len(attributes.member_id)>#attributes.member_id#<cfelse>NULL</cfif>,
		COMPANY_ID = #attributes.company_id#,
		CONSUMER_ID = NULL,
	<cfelseif attributes.member_type is 'consumer'>
		PARTNER_ID = NULL,
		COMPANY_ID = NULL,
		CONSUMER_ID = #attributes.member_id#,
	</cfif>
	<cfif attributes.ref_member_type is 'partner'>
		REF_PARTNER_ID = #attributes.ref_member_id#,
		REF_COMPANY_ID = #attributes.ref_company_id#,
		REF_CONSUMER_ID = NULL,
	<cfelseif attributes.ref_member_type is 'consumer'>		
		REF_PARTNER_ID = NULL,
		REF_COMPANY_ID = NULL,
		REF_CONSUMER_ID = #attributes.ref_member_id#,
	<cfelse>
		REF_PARTNER_ID = NULL,
		REF_COMPANY_ID = NULL,
		REF_CONSUMER_ID = NULL,
	</cfif>			
		ORDER_STAGE = <cfif isdefined("attributes.process_stage")>#attributes.process_stage#<cfelse>NULL</cfif>,
		ORDER_DATE = <cfif len(attributes.order_date)>#attributes.order_date#<cfelse>NULL</cfif>,
		COMMETHOD_ID = <cfif isdefined("attributes.commethod_id") and len(attributes.commethod_id)>#attributes.commethod_id#<cfelse>NULL</cfif>,
		OFFER_ID = <cfif len(attributes.offer_id) and len(attributes.offer_head)>#attributes.offer_id#<cfelse>NULL</cfif>,
		OTHER_MONEY = <cfif isdefined("form.basket_money")><cfqueryparam cfsqltype="cf_sql_varchar" value="#form.basket_money#"><cfelse>NULL</cfif>,
		OTHER_MONEY_VALUE = #((form.BASKET_NET_TOTAL*form.BASKET_RATE1)/form.BASKET_RATE2)#,
		GROSSTOTAL = <cfif isDefined('attributes.basket_gross_total') and len(attributes.basket_gross_total)>#basket_gross_total#<cfelse>NULL</cfif>,
		NETTOTAL = <cfif isdefined("form.basket_net_total") and len(form.basket_net_total)>#form.basket_net_total#<cfelse>NULL</cfif>,
		TAXTOTAL = <cfif isdefined("form.basket_tax_total") and len(form.basket_tax_total)>#form.basket_tax_total#<cfelse>NULL</cfif>,
		DISCOUNTTOTAL = <cfif isdefined("form.basket_discount_total") and len(form.basket_discount_total)> #form.basket_discount_total#<cfelse>NULL</cfif>,
		PAYMETHOD = <cfif len(attributes.paymethod) and len(attributes.paymethod_id)>#attributes.paymethod_id#<cfelse>NULL</cfif>,
		ORDER_EMPLOYEE_ID = <cfif len(attributes.order_employee_id)>#attributes.order_employee_id#<cfelse>NULL</cfif>,
		SALES_PARTNER_ID = <cfif len(attributes.sales_member) and (attributes.sales_member_type is "partner")>#attributes.sales_member_id#<cfelse>NULL</cfif>,
		SALES_CONSUMER_ID = <cfif len(attributes.sales_member) and (attributes.sales_member_type is "consumer")>#attributes.sales_member_id#<cfelse>NULL</cfif>,
		<cfif isdefined("attributes.ship_method_id") and len(attributes.ship_method_id) and len(trim(attributes.ship_method_name))>
			SHIP_METHOD = #attributes.ship_method_id#,
		<cfelse>
			SHIP_METHOD = NULL,
		</cfif>
		SHIP_DATE = <cfif len(attributes.ship_date)>#attributes.ship_date#<cfelse>NULL</cfif>,
		DELIVERDATE = <cfif len(attributes.deliverdate)>#attributes.deliverdate#<cfelse>NULL</cfif>,
		<cfif isdefined("attributes.deliver_dept_id") and len(attributes.deliver_dept_id) and len(attributes.deliver_dept_name)>
			DELIVER_DEPT_ID = #attributes.deliver_dept_id#,
		<cfelse>
			DELIVER_DEPT_ID = NULL,
		</cfif>
		<cfif isdefined("attributes.deliver_loc_id") and len(attributes.deliver_loc_id) and len(attributes.deliver_dept_name)>
			LOCATION_ID = #attributes.deliver_loc_id#,
		<cfelse>
			LOCATION_ID = NULL,
		</cfif>	
		INCLUDED_KDV = 0,
		RESERVED = <cfif isdefined('attributes.reserved')>1<cfelse>0</cfif>,
		ORDER_DETAIL = <cfif isdefined('attributes.order_detail') and len(attributes.order_detail)><cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.order_detail#"><cfelse>NULL</cfif>,
		SHIP_ADDRESS = <cfif isdefined("attributes.address") and len(attributes.address)><cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.address#"><cfelse>NULL</cfif>,
		COUNTRY_ID = <cfif isdefined("attributes.country") and len(attributes.country)>#attributes.country#<cfelse>NULL</cfif>,
        CITY_ID = <cfif isdefined("attributes.city") and len(attributes.city)>#attributes.city#<cfelse>NULL</cfif>,
		COUNTY_ID = <cfif isdefined("attributes.county_id") and len(attributes.county_id)>#attributes.county_id#<cfelse>NULL</cfif>,
		PRIORITY_ID = <cfif isdefined("attributes.priority_id") and len(attributes.priority_id)>#attributes.priority_id#<cfelse>NULL</cfif>,
		ORDER_HEAD = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.order_head#">,
		PROJECT_ID = <cfif isdefined("attributes.project_id") and len(attributes.project_id) and len(attributes.project_head)>#attributes.project_id#<cfelse>NULL</cfif>,
		<cfif isDefined("attributes.action_id") and len(attributes.action_id) and len(attributes.action_name)>
			CATALOG_ID = #attributes.action_id#,
		</cfif>
		DUE_DATE = <cfif isdefined("attributes.basket_due_value_date_") and len(attributes.basket_due_value_date_)>#attributes.basket_due_value_date_#<cfelse>NULL</cfif>,
		REF_NO = <cfif isdefined("attributes.ref_no") and len(attributes.ref_no)><cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.ref_no#"><cfelse>NULL</cfif>,
		SA_DISCOUNT = #form.genel_indirim#,
		GENERAL_PROM_ID = <cfif isdefined("attributes.general_prom_id") and len(attributes.general_prom_id)>#attributes.general_prom_id#<cfelse>NULL</cfif>,
		GENERAL_PROM_LIMIT = <cfif isdefined("attributes.general_prom_limit") and len(attributes.general_prom_limit)>#attributes.general_prom_limit#<cfelse>NULL</cfif>,
		GENERAL_PROM_AMOUNT = <cfif isdefined("attributes.general_prom_amount") and len(attributes.general_prom_amount)>#attributes.general_prom_amount#<cfelse>NULL</cfif>,
		GENERAL_PROM_DISCOUNT = <cfif isdefined("attributes.general_prom_discount") and len(attributes.general_prom_discount)>#attributes.general_prom_discount#<cfelse>NULL</cfif>,
		FREE_PROM_ID = <cfif isdefined("attributes.free_prom_id") and len(attributes.free_prom_id)>#attributes.free_prom_id#<cfelse>NULL</cfif>,
		FREE_PROM_LIMIT = <cfif isdefined("attributes.free_prom_limit") and len(attributes.free_prom_limit)>#attributes.free_prom_limit#<cfelse>NULL</cfif>,
		FREE_PROM_AMOUNT = <cfif isdefined("attributes.free_prom_amount") and len(attributes.free_prom_amount)>#attributes.free_prom_amount#<cfelse>NULL</cfif>,
		FREE_PROM_COST = <cfif isdefined("attributes.free_prom_cost") and len(attributes.free_prom_cost)>#attributes.free_prom_cost#<cfelse>NULL</cfif>,
		FREE_PROM_STOCK_ID = <cfif isdefined("attributes.free_prom_stock_id") and len(attributes.free_prom_stock_id)>#attributes.free_prom_stock_id#<cfelse>NULL</cfif>,
		FREE_STOCK_PRICE = <cfif isdefined("attributes.free_stock_price") and len(attributes.free_stock_price)>#attributes.free_stock_price#<cfelse>NULL</cfif>,
		FREE_STOCK_MONEY = <cfif isdefined("attributes.free_stock_money") and len(attributes.free_stock_money)><cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.free_stock_money#"><cfelse>NULL</cfif>,
		<cfif isdefined("attributes.card_paymethod_id") and len(attributes.card_paymethod_id)>
			CARD_PAYMETHOD_ID = #attributes.card_paymethod_id#,
			CARD_PAYMETHOD_RATE = <cfif isdefined("attributes.commission_rate") and len(attributes.commission_rate)>#attributes.commission_rate#,<cfelse>NULL,</cfif>
		<cfelse>
			CARD_PAYMETHOD_ID = NULL,
			CARD_PAYMETHOD_RATE = NULL,
		</cfif>
		ZONE_ID=<cfif isDefined("get_customer_info.SALES_COUNTY") and len(get_customer_info.SALES_COUNTY)>#get_customer_info.SALES_COUNTY#<cfelse>NULL</cfif>,
		RESOURCE_ID = <cfif isDefined("get_customer_info.RESOURCE_ID") and len(get_customer_info.RESOURCE_ID)>#get_customer_info.RESOURCE_ID#<cfelse>NULL</cfif>,
		IMS_CODE_ID = <cfif isDefined("get_customer_info.IMS_CODE_ID") and len(get_customer_info.IMS_CODE_ID)>#get_customer_info.IMS_CODE_ID#<cfelse>NULL</cfif>,
		CUSTOMER_VALUE_ID = <cfif isDefined("get_customer_info.CUSTOMER_VALUE_ID") and len(get_customer_info.CUSTOMER_VALUE_ID)>#get_customer_info.CUSTOMER_VALUE_ID#<cfelse>NULL</cfif>,
		SALES_ADD_OPTION_ID = <cfif isDefined("attributes.sales_add_option") and len(attributes.sales_add_option)>#attributes.sales_add_option#<cfelse>NULL</cfif>,
        POSTCODE = <cfif isDefined("attributes.postcode") and len(attributes.postcode)>'#attributes.postcode#'<cfelse>NULL</cfif>,
        EMAIL = <cfif isDefined("attributes.email") and len(attributes.email)>'#attributes.email#'<cfelse>NULL</cfif>,
		UPDATE_DATE = #now()#,
		UPDATE_IP = <cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.remote_addr#">,
		UPDATE_EMP = #session.ep.userid#				
	WHERE
		ORDER_ID = #attributes.order_id#
</cfquery>

<!---  urun asortileri siliniyor bknz: add_assortment.cfm --->
<cfquery name="DEL_OFFER_ASSORT_ROWS" datasource="#dsn2#">
	DELETE FROM
		#dsn3_alias#.PRODUCTION_ASSORTMENT
	WHERE
		ACTION_TYPE=2 AND 
		ASSORTMENT_ID IN ( SELECT ORDER_ROW_ID FROM #dsn3_alias#.ORDER_ROW WHERE ORDER_ID = #attributes.order_id#)
</cfquery>
<!--- urun asortileri --->

<cfquery name="DEL_STOCK_RESERVED" datasource="#dsn2#">
	DELETE FROM STOCKS_ROW_RESERVED WHERE ORDER_ID = #ORDER_ID#			
</cfquery>
<cfset order_row_id_list_ =''>
<cfif attributes.rows_ gte 1>
	<cfloop from="1" to="#attributes.rows_#" index="i">
		<cf_date tarih="attributes.deliver_date#i#">
		<cf_date tarih="attributes.reserve_date#i#">
		<cfif session.ep.our_company_info.spect_type and isdefined('attributes.is_production#i#') and evaluate('attributes.is_production#i#') eq 1>
			<cfset dsn_type=dsn2>
			<cfset specer_spec_id=''>
			<cfif not isdefined('attributes.spect_id#i#') or not len(evaluate('attributes.spect_id#i#'))>
				<cfinclude template="../../objects/query/add_basket_spec.cfm">
			<cfelseif attributes.basket_spect_type eq 7 ><!--- satırdada guncellenebilmeli bu spec tipinde--->
				<cfset specer_spec_id=evaluate('attributes.spect_id#i#')>
				<cfinclude template="../../objects/query/add_basket_spec.cfm">
			</cfif>
		</cfif>
		<cfif session.ep.our_company_info.spect_type eq 5 and isdefined('attributes.spect_id#i#') and len(evaluate('attributes.spect_id#i#'))>
			<!--- metal sektöründeki spec popupı kullanıldıgında STOCKS_ROW_RESERVED tablosuna kayıt atıyor --->
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
						<cfif len(ORDER_ID)>#ORDER_ID#<cfelse>NULL</cfif>,
						<cfif len(get_spect.PRODUCT_MANUFACT_CODE)>#get_spect.PRODUCT_MANUFACT_CODE#<cfelse>NULL</cfif>,
						<cfif len(get_spect.SHELF_NUMBER)>#get_spect.SHELF_NUMBER#<cfelse>NULL</cfif>
					)
			</cfquery>
		</cfif>
		<cfif len(evaluate('attributes.action_row_id#i#')) and evaluate('attributes.action_row_id#i#') neq 0><!--- yeni eklenmis bir satır degilse --->
			<cfquery name="UPD_ORDER_ROW" datasource="#dsn2#"><!--- eski satır update --->
				UPDATE
					#dsn3_alias#.ORDER_ROW
				SET
					PRODUCT_ID=#evaluate('attributes.product_id#i#')#,
					STOCK_ID=#evaluate('attributes.stock_id#i#')#,
					QUANTITY=#evaluate('attributes.amount#i#')#,
					UNIT=<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.unit#i#')#">,
					UNIT_ID=#evaluate('attributes.unit_id#i#')#,
					PRICE=#evaluate('attributes.price#i#')#,
					TAX=<cfif isdefined('attributes.tax#i#')>#evaluate('attributes.tax#i#')#<cfelse>NULL</cfif>,
					DUEDATE=<cfif isdefined("attributes.duedate#i#") and len(evaluate("attributes.duedate#i#"))>#evaluate('attributes.duedate#i#')#<cfelse>0</cfif>,
					PRODUCT_NAME=<cfif isdefined('attributes.product_name#i#')><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.product_name#i#')#"><cfelse>NULL</cfif>,
					DELIVER_DATE=<cfif isdefined("attributes.deliver_date#i#") and isdate(evaluate('attributes.deliver_date#i#'))>#evaluate('attributes.deliver_date#i#')#<cfelse>NULL</cfif>,
					<cfif isdefined("attributes.deliver_dept#i#") and len(trim(evaluate("attributes.deliver_dept#i#"))) and len(listfirst(evaluate("attributes.deliver_dept#i#"),"-"))>
						DELIVER_DEPT=#listfirst(evaluate("attributes.deliver_dept#i#"),"-")#,
					<cfelseif isdefined('attributes.deliver_dept_id') and len(attributes.deliver_dept_id)>
						DELIVER_DEPT=#attributes.deliver_dept_id#,
					<cfelse>
						DELIVER_DEPT=NULL,
					</cfif>
					<cfif isdefined("attributes.deliver_dept#i#") and listlen(trim(evaluate("attributes.deliver_dept#i#")),"-") eq 2 and len(listlast(evaluate("attributes.deliver_dept#i#"),"-"))>
						DELIVER_LOCATION=#listlast(evaluate("attributes.deliver_dept#i#"),"-")#,
					<cfelseif isdefined('attributes.deliver_loc_id') and len(attributes.deliver_loc_id)>
						DELIVER_LOCATION=#attributes.deliver_loc_id#,
					<cfelse>
						DELIVER_LOCATION=NULL,
					</cfif>
					DISCOUNT_1=<cfif isdefined('attributes.indirim1#i#')>#evaluate('attributes.indirim1#i#')#<cfelse>NULL</cfif>,
					DISCOUNT_2=<cfif isdefined('attributes.indirim2#i#')>#evaluate('attributes.indirim2#i#')#<cfelse>NULL</cfif>,
					DISCOUNT_3=<cfif isdefined('attributes.indirim3#i#')>#evaluate('attributes.indirim3#i#')#<cfelse>NULL</cfif>,
					DISCOUNT_4=<cfif isdefined('attributes.indirim4#i#')>#evaluate('attributes.indirim4#i#')#<cfelse>NULL</cfif>,
					DISCOUNT_5=<cfif isdefined('attributes.indirim5#i#')>#evaluate('attributes.indirim5#i#')#<cfelse>NULL</cfif>,
					DISCOUNT_6=<cfif isdefined('attributes.indirim6#i#')>#evaluate('attributes.indirim6#i#')#<cfelse>NULL</cfif>,
					DISCOUNT_7=<cfif isdefined('attributes.indirim7#i#')>#evaluate('attributes.indirim7#i#')#<cfelse>NULL</cfif>,
					DISCOUNT_8=<cfif isdefined('attributes.indirim8#i#')>#evaluate('attributes.indirim8#i#')#<cfelse>NULL</cfif>,
					DISCOUNT_9=<cfif isdefined('attributes.indirim9#i#')>#evaluate('attributes.indirim9#i#')#<cfelse>NULL</cfif>,
					DISCOUNT_10=<cfif isdefined('attributes.indirim10#i#')>#evaluate('attributes.indirim10#i#')#<cfelse>NULL</cfif>,
					ORDER_ROW_CURRENCY=<cfif isdefined("attributes.order_currency#i#") and len(evaluate("attributes.order_currency#i#"))>#evaluate("attributes.order_currency#i#")#<cfelse>NULL</cfif>,
					RESERVE_TYPE=<cfif isdefined("attributes.reserve_type#i#") and len(evaluate("attributes.reserve_type#i#"))>#evaluate("attributes.reserve_type#i#")#<cfelse>NULL</cfif>,
					RESERVE_DATE=<cfif isdefined("attributes.reserve_date#i#") and isdate(evaluate('attributes.reserve_date#i#'))>#evaluate('attributes.reserve_date#i#')#<cfelse>NULL</cfif>,
					OTHER_MONEY=<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.other_money_#i#')#">,
					OTHER_MONEY_VALUE=<cfif isdefined('attributes.other_money_value_#i#') and len(evaluate("attributes.other_money_value_#i#"))>#evaluate('attributes.other_money_value_#i#')#<cfelse>NULL</cfif>,
				<cfif isdefined('attributes.spect_id#i#') and len(evaluate('attributes.spect_id#i#'))>
					SPECT_VAR_ID=#evaluate('attributes.spect_id#i#')#,
					SPECT_VAR_NAME=<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.spect_name#i#')#">,
				</cfif>
					LOT_NO=<cfif isdefined('attributes.lot_no#i#')><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.lot_no#i#')#"><cfelse>NULL</cfif>,
					PRICE_OTHER=<cfif isdefined('attributes.price_other#i#')>#evaluate('attributes.price_other#i#')#<cfelse>NULL</cfif>,
					COST_PRICE=<cfif isdefined('attributes.net_maliyet#i#') and len(evaluate('attributes.net_maliyet#i#'))>#evaluate('attributes.net_maliyet#i#')#<cfelse>0</cfif>,
					EXTRA_COST=<cfif isdefined('attributes.extra_cost#i#') and len(evaluate('attributes.extra_cost#i#'))>#evaluate('attributes.extra_cost#i#')#<cfelse>0</cfif>,
					MARJ=<cfif isdefined('attributes.marj#i#') and len(evaluate('attributes.marj#i#'))>#evaluate('attributes.marj#i#')#,<cfelse>0,</cfif>
					PROM_COMISSION=<cfif isdefined('attributes.promosyon_yuzde#i#') and len(evaluate('attributes.promosyon_yuzde#i#'))>#evaluate('attributes.promosyon_yuzde#i#')#,<cfelse>NULL,</cfif>
					PROM_COST=<cfif isdefined('attributes.promosyon_maliyet#i#') and len(evaluate('attributes.promosyon_maliyet#i#'))>#evaluate('attributes.promosyon_maliyet#i#')#,<cfelse>0,</cfif>
					DISCOUNT_COST=<cfif isdefined('attributes.iskonto_tutar#i#') and len(evaluate('attributes.iskonto_tutar#i#'))>#evaluate('attributes.iskonto_tutar#i#')#<cfelse>NULL</cfif>,
					PROM_ID=<cfif isdefined('attributes.row_promotion_id#i#') and len(evaluate('attributes.row_promotion_id#i#'))>	#evaluate('attributes.row_promotion_id#i#')#<cfelse>NULL</cfif>,
					IS_PROMOTION=<cfif isdefined('attributes.is_promotion#i#') and len(evaluate('attributes.is_promotion#i#'))>#evaluate('attributes.is_promotion#i#')#<cfelse>0</cfif>,
					PROM_STOCK_ID=<cfif isdefined('attributes.prom_stock_id#i#') and len(evaluate('attributes.prom_stock_id#i#'))>#evaluate('attributes.prom_stock_id#i#')#<cfelse>NULL</cfif>,
					NETTOTAL=<cfif isdefined("attributes.row_nettotal#i#") and len(evaluate("attributes.row_nettotal#i#"))>#evaluate("attributes.row_nettotal#i#")#<cfelse>NULL</cfif>,
					IS_COMMISSION=<cfif isdefined('attributes.is_commission#i#') and len(evaluate('attributes.is_commission#i#'))>#evaluate('attributes.is_commission#i#')#<cfelse>0</cfif>,
					UNIQUE_RELATION_ID=<cfif isdefined('attributes.row_unique_relation_id#i#') and len(evaluate('attributes.row_unique_relation_id#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.row_unique_relation_id#i#')#"><cfelse>NULL</cfif>,
					PROM_RELATION_ID=<cfif isdefined('attributes.prom_relation_id#i#') and len(evaluate('attributes.prom_relation_id#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.prom_relation_id#i#')#"><cfelse>NULL</cfif>,
					PRODUCT_NAME2=<cfif isdefined('attributes.product_name_other#i#') and len(evaluate('attributes.product_name_other#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.product_name_other#i#')#"><cfelse>NULL</cfif>,
					AMOUNT2=<cfif isdefined('attributes.amount_other#i#') and len(evaluate('attributes.amount_other#i#'))>#evaluate('attributes.amount_other#i#')#<cfelse>NULL</cfif>,
					UNIT2=<cfif isdefined('attributes.unit_other#i#') and len(evaluate('attributes.unit_other#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.unit_other#i#')#"><cfelse>NULL</cfif>,
					EXTRA_PRICE=<cfif isdefined('attributes.ek_tutar#i#') and len(evaluate('attributes.ek_tutar#i#'))>#evaluate('attributes.ek_tutar#i#')#<cfelse>NULL</cfif>,
					EK_TUTAR_PRICE=<cfif isdefined('attributes.ek_tutar_price#i#') and len(evaluate('attributes.ek_tutar_price#i#'))>#evaluate('attributes.ek_tutar_price#i#')#<cfelse>NULL</cfif>,
					EXTRA_PRICE_TOTAL=<cfif isdefined('attributes.ek_tutar_total#i#') and len(evaluate('attributes.ek_tutar_total#i#'))>#evaluate('attributes.ek_tutar_total#i#')#<cfelse>NULL</cfif>,
					EXTRA_PRICE_OTHER_TOTAL=<cfif isdefined('attributes.ek_tutar_other_total#i#') and len(evaluate('attributes.ek_tutar_other_total#i#'))>#evaluate('attributes.ek_tutar_other_total#i#')#<cfelse>NULL</cfif>,
					SHELF_NUMBER=<cfif isdefined('attributes.shelf_number#i#') and len(evaluate('attributes.shelf_number#i#'))>#evaluate('attributes.shelf_number#i#')#<cfelse>NULL</cfif>,
					PRODUCT_MANUFACT_CODE=<cfif isdefined('attributes.manufact_code#i#') and len(evaluate('attributes.manufact_code#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.manufact_code#i#')#"><cfelse>NULL</cfif>,
					BASKET_EXTRA_INFO_ID=<cfif isdefined('attributes.basket_extra_info#i#') and len(evaluate('attributes.basket_extra_info#i#'))><cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('attributes.basket_extra_info#i#')#"><cfelse>NULL</cfif>,
					SELECT_INFO_EXTRA=<cfif isdefined('attributes.select_info_extra#i#') and len(evaluate('attributes.select_info_extra#i#'))><cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('attributes.select_info_extra#i#')#"><cfelse>NULL</cfif>,
					DETAIL_INFO_EXTRA=<cfif isdefined('attributes.detail_info_extra#i#') and len(evaluate('attributes.detail_info_extra#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.detail_info_extra#i#')#"><cfelse>NULL</cfif>,
					PRICE_CAT=<cfif isdefined('attributes.price_cat#i#') and len(evaluate('attributes.price_cat#i#'))>#evaluate('attributes.price_cat#i#')#<cfelse>NULL</cfif>,
					CATALOG_ID = <cfif isdefined('attributes.row_catalog_id#i#') and len(evaluate('attributes.row_catalog_id#i#'))>#evaluate('attributes.row_catalog_id#i#')#<cfelse>NULL</cfif>,
					LIST_PRICE=<cfif isdefined('attributes.list_price#i#') and len(evaluate('attributes.list_price#i#'))>#evaluate('attributes.list_price#i#')#<cfelse>NULL</cfif>,
					NUMBER_OF_INSTALLMENT=<cfif isdefined('attributes.number_of_installment#i#') and len(evaluate('attributes.number_of_installment#i#'))>#evaluate('attributes.number_of_installment#i#')#<cfelse>NULL</cfif>,
					BASKET_EMPLOYEE_ID=<cfif isdefined('attributes.basket_employee_id#i#') and len(evaluate('attributes.basket_employee_id#i#')) and isdefined('attributes.basket_employee#i#') and len(evaluate('attributes.basket_employee#i#'))>#evaluate('attributes.basket_employee_id#i#')#<cfelse>NULL</cfif>,
					KARMA_PRODUCT_ID=<cfif isdefined('attributes.karma_product_id#i#') and len(evaluate('attributes.karma_product_id#i#'))>#evaluate('attributes.karma_product_id#i#')#<cfelse>NULL</cfif>,
					ROW_PRO_MATERIAL_ID =<cfif isdefined('attributes.pro_material_id_list') and len(attributes.pro_material_id_list) and isdefined("attributes.row_ship_id#i#") and len(evaluate('attributes.row_ship_id#i#')) and evaluate('attributes.row_ship_id#i#') neq 0>#evaluate('attributes.row_ship_id#i#')#<cfelse>NULL</cfif>,
					OTV_ORAN=<cfif isdefined('attributes.otv_oran#i#') and len(evaluate('attributes.otv_oran#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.otv_oran#i#')#"><cfelse>NULL</cfif>,
					OTVTOTAL=<cfif isdefined('attributes.row_otvtotal#i#') and len(evaluate('attributes.row_otvtotal#i#'))>#evaluate('attributes.row_otvtotal#i#')#<cfelse>NULL</cfif>,
					WRK_ROW_ID=<cfif isdefined('attributes.wrk_row_id#i#') and len(evaluate('attributes.wrk_row_id#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.wrk_row_id#i#')#"><cfelse>NULL</cfif>,
					WRK_ROW_RELATION_ID=<cfif isdefined('attributes.wrk_row_relation_id#i#') and len(evaluate('attributes.wrk_row_relation_id#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.wrk_row_relation_id#i#')#"><cfelse>NULL</cfif>,
					RELATED_ACTION_ID=<cfif isdefined('attributes.related_action_id#i#') and len(evaluate('attributes.related_action_id#i#'))>#evaluate('attributes.related_action_id#i#')#<cfelse>NULL</cfif>,
					RELATED_ACTION_TABLE=<cfif isdefined('attributes.related_action_table#i#') and len(evaluate('attributes.related_action_table#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.related_action_table#i#')#"><cfelse>NULL</cfif>,
					WIDTH_VALUE=<cfif isdefined('attributes.row_width#i#') and len(evaluate('attributes.row_width#i#'))>#evaluate('attributes.row_width#i#')#<cfelse>NULL</cfif>,
					DEPTH_VALUE=<cfif isdefined('attributes.row_depth#i#') and len(evaluate('attributes.row_depth#i#'))>#evaluate('attributes.row_depth#i#')#<cfelse>NULL</cfif>,
					HEIGHT_VALUE=<cfif isdefined('attributes.row_height#i#') and len(evaluate('attributes.row_height#i#'))>#evaluate('attributes.row_height#i#')#<cfelse>NULL</cfif>
					<cfif isdefined('attributes.row_exp_center_id#i#') and len(evaluate("attributes.row_exp_center_id#i#")) and isdefined('attributes.row_exp_center_name#i#') and len(evaluate("attributes.row_exp_center_name#i#"))>
					,EXPENSE_CENTER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('attributes.row_exp_center_id#i#')#">
					</cfif>
					<cfif isdefined('attributes.row_exp_item_id#i#') and len(evaluate("attributes.row_exp_item_id#i#")) and isdefined('attributes.row_exp_item_name#i#') and len(evaluate("attributes.row_exp_item_name#i#"))>
					,EXPENSE_ITEM_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('attributes.row_exp_item_id#i#')#">
					</cfif>
					<cfif isdefined('attributes.row_activity_id#i#') and len(evaluate("attributes.row_activity_id#i#"))>
					,ACTIVITY_TYPE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('attributes.row_activity_id#i#')#">
					</cfif>
					<cfif isdefined('attributes.row_acc_code#i#') and len(evaluate("attributes.row_acc_code#i#"))>
					,ACC_CODE = <cfqueryparam cfsqltype="cf_sql_nvarchar" value="#evaluate('attributes.row_acc_code#i#')#">
					</cfif>	
				WHERE
					ORDER_ID=#attributes.order_id#
					AND ORDER_ROW_ID=#evaluate('attributes.action_row_id#i#')#
			</cfquery>
			<cfset attributes.ROW_MAIN_ID = evaluate('attributes.action_row_id#i#')>
		<cfelse>
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
					PRICE,
					TAX,
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
					ORDER_ROW_CURRENCY,
					RESERVE_TYPE,
					RESERVE_DATE,
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
					<!--- Yeni Eklenen Alanlar --->
					PROM_COMISSION,
					PROM_COST,
					DISCOUNT_COST,
					PROM_ID,
					IS_PROMOTION,
					PROM_STOCK_ID,
					NETTOTAL,
					IS_COMMISSION,
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
				)
				VALUES
				(
					#attributes.order_id#,
					#evaluate('attributes.product_id#i#')#,
					#evaluate('attributes.stock_id#i#')#,
					#evaluate('attributes.amount#i#')#,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.unit#i#')#">,
					#evaluate('attributes.unit_id#i#')#,
					#evaluate('attributes.price#i#')#,
					<cfif isdefined('attributes.tax#i#')>#evaluate('attributes.tax#i#')#<cfelse>NULL</cfif>,
                    <cfif isdefined("attributes.duedate#i#") and len(evaluate("attributes.duedate#i#"))>#evaluate('attributes.duedate#i#')#<cfelse>0</cfif>,
                    <cfif isdefined('attributes.product_name#i#')><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.product_name#i#')#"><cfelse>NULL</cfif>,
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
					<cfif isdefined("attributes.order_currency#i#") and len(evaluate("attributes.order_currency#i#"))>#evaluate("attributes.order_currency#i#")#<cfelse>NULL</cfif>,
					<cfif isdefined("attributes.reserve_type#i#") and len(evaluate("attributes.reserve_type#i#"))>#evaluate("attributes.reserve_type#i#")#<cfelse>NULL</cfif>,
					<cfif isdefined("attributes.reserve_date#i#") and isdate(evaluate('attributes.reserve_date#i#'))>#evaluate('attributes.reserve_date#i#')#<cfelse>NULL</cfif>,
					<cfif isdefined('attributes.other_money_#i#')><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.other_money_#i#')#"><cfelse>NULL</cfif>,
					<cfif isdefined('attributes.other_money_value_#i#') and len(evaluate("attributes.other_money_value_#i#"))>#evaluate('attributes.other_money_value_#i#')#<cfelse>NULL</cfif>,
					<cfif isdefined('attributes.spect_id#i#') and len(evaluate('attributes.spect_id#i#'))>
					#evaluate('attributes.spect_id#i#')#,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.spect_name#i#')#">,
                    </cfif>
                    <cfif isdefined('attributes.lot_no#i#')><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.lot_no#i#')#"><cfelse>NULL</cfif>,
                    <cfif isdefined('attributes.price_other#i#')>#evaluate('attributes.price_other#i#')#<cfelse>NULL</cfif>,
                    <!--- <cfif isdefined('attributes.cost_id#i#') and len(evaluate('attributes.cost_id#i#'))>#evaluate('attributes.cost_id#i#')#<cfelse>NULL</cfif>, --->
                    <cfif isdefined('attributes.net_maliyet#i#') and len(evaluate('attributes.net_maliyet#i#'))>#evaluate('attributes.net_maliyet#i#')#<cfelse>0</cfif>,
                    <cfif isdefined('attributes.extra_cost#i#') and len(evaluate('attributes.extra_cost#i#'))>#evaluate('attributes.extra_cost#i#')#<cfelse>0</cfif>,
                    <cfif isdefined('attributes.marj#i#') and len(evaluate('attributes.marj#i#'))>#evaluate('attributes.marj#i#')#,<cfelse>0,</cfif>			
                    <cfif isdefined('attributes.promosyon_yuzde#i#') and len(evaluate('attributes.promosyon_yuzde#i#'))>#evaluate('attributes.promosyon_yuzde#i#')#,<cfelse>NULL,</cfif>
                    <cfif isdefined('attributes.promosyon_maliyet#i#') and len(evaluate('attributes.promosyon_maliyet#i#'))>#evaluate('attributes.promosyon_maliyet#i#')#,<cfelse>0,	</cfif>
                    <cfif isdefined('attributes.iskonto_tutar#i#') and len(evaluate('attributes.iskonto_tutar#i#'))>#evaluate('attributes.iskonto_tutar#i#')#,<cfelse>NULL,</cfif>
                    <cfif isdefined('attributes.row_promotion_id#i#') and len(evaluate('attributes.row_promotion_id#i#'))>	#evaluate('attributes.row_promotion_id#i#')#,<cfelse>NULL,</cfif>
                    <cfif isdefined('attributes.is_promotion#i#') and len(evaluate('attributes.is_promotion#i#'))>#evaluate('attributes.is_promotion#i#')#,	<cfelse>0,</cfif>
                    <cfif isdefined('attributes.prom_stock_id#i#') and len(evaluate('attributes.prom_stock_id#i#'))>#evaluate('attributes.prom_stock_id#i#')#<cfelse>NULL</cfif>,
                    <cfif isdefined("attributes.row_nettotal#i#") and len(evaluate("attributes.row_nettotal#i#"))>#evaluate("attributes.row_nettotal#i#")#<cfelse>NULL</cfif>,
                    <cfif isdefined('attributes.is_commission#i#') and len(evaluate('attributes.is_commission#i#'))>#evaluate('attributes.is_commission#i#')#<cfelse>0</cfif>,
                    <cfif isdefined('attributes.row_unique_relation_id#i#') and len(evaluate('attributes.row_unique_relation_id#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.row_unique_relation_id#i#')#"><cfelse>NULL</cfif>,
                    <cfif isdefined('attributes.prom_relation_id#i#') and len(evaluate('attributes.prom_relation_id#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.prom_relation_id#i#')#"><cfelse>NULL</cfif>,
                    <cfif isdefined('attributes.product_name_other#i#') and len(evaluate('attributes.product_name_other#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.product_name_other#i#')#"><cfelse>NULL</cfif>,
                    <cfif isdefined('attributes.amount_other#i#') and len(evaluate('attributes.amount_other#i#'))>#evaluate('attributes.amount_other#i#')#<cfelse>NULL</cfif>,
                    <cfif isdefined('attributes.unit_other#i#') and len(evaluate('attributes.unit_other#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.unit_other#i#')#"><cfelse>NULL</cfif>,
                    <cfif isdefined('attributes.ek_tutar#i#') and len(evaluate('attributes.ek_tutar#i#'))>#evaluate('attributes.ek_tutar#i#')#<cfelse>NULL</cfif>,
                    <cfif isdefined('attributes.ek_tutar_total#i#') and len(evaluate('attributes.ek_tutar_total#i#'))>#evaluate('attributes.ek_tutar_total#i#')#<cfelse>NULL</cfif>,
                    <cfif isdefined('attributes.shelf_number#i#') and len(evaluate('attributes.shelf_number#i#'))>#evaluate('attributes.shelf_number#i#')#<cfelse>NULL</cfif>,
                    <cfif isdefined('attributes.manufact_code#i#') and len(evaluate('attributes.manufact_code#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.manufact_code#i#')#"><cfelse>NULL</cfif>,
                    <cfif isdefined('attributes.basket_extra_info#i#') and len(evaluate('attributes.basket_extra_info#i#'))>#evaluate('attributes.basket_extra_info#i#')#<cfelse>NULL</cfif>,
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
				)
			</cfquery>
			<cfquery name="GET_MAX_ORDER_ROW" datasource="#dsn2#">
				SELECT
					MAX(ORDER_ROW_ID) AS ORDER_ROW_ID
				FROM
					#dsn3_alias#.ORDER_ROW
			</cfquery>
			<cfset attributes.ROW_MAIN_ID = get_max_order_row.order_row_id>
		</cfif>
		<cfset order_row_id_list_ =listappend(order_row_id_list_,attributes.ROW_MAIN_ID)> <!--- order_row_id_list olusturuluyor, bu liste haricindeki order_row satırları silinir --->
		<cfset row_id = I>
		<cfset ACTION_TYPE_ID = 2>
		<cfset dsn_type_= dsn2>
		<!--- //  urun asortileri --->
		<cfinclude template="add_assortment_textile_js.cfm">
	</cfloop>
	<cfif len(order_row_id_list_)>
		<cfquery name="DEL_ORDER_ROW_" datasource="#dsn2#"> <!--- basketten cıkarılan satırlar ORDER_ROW dan siliniyor --->
			DELETE FROM #dsn3_alias#.ORDER_ROW WHERE ORDER_ID =#attributes.order_id# AND ORDER_ROW_ID NOT IN (#order_row_id_list_#)
		</cfquery>
	</cfif>
	<cfscript>
		basket_kur_ekle(action_id:ORDER_ID,table_type_id:3,process_type:1,transaction_dsn:dsn2);
		add_reserve_row(
			reserve_order_id:attributes.order_id,
			reserve_action_type:1,
			is_order_process:0,
			is_purchase_sales:1,
			process_db :dsn2
			);
	</cfscript>
</cfif>


