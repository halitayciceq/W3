<cf_xml_page_edit fuseact="sales.form_add_offer">
<cfif form.active_company neq session.ep.company_id>
	<script type="text/javascript">
		alert("<cf_get_lang no ='588.İşlemin Şirketi İle Aktif Şirketiniz Farklı Çalıştığınız Şirketi Kontrol Ediniz'>!");
		window.location.href='<cfoutput>#request.self#?fuseaction=sales.list_offer</cfoutput>';
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
<cf_date tarih="attributes.offer_date">
<cfif isdefined("attributes.basket_due_value") and len(attributes.basket_due_value)>
	<cfset offer_due_date = date_add("d",attributes.basket_due_value,attributes.offer_date)>
<cfelse>
	<cfset offer_due_date = "">
</cfif> 
<cfif len(attributes.deliverdate)><cf_date tarih="attributes.deliverdate"></cfif>
<cfif len(attributes.ship_date)><cf_date tarih="attributes.ship_date"></cfif>
<cfif len(attributes.finishdate)><cf_date tarih="attributes.finishdate"></cfif>

<cfif isdefined("attributes.company_id") and len(attributes.company_id)>
	<cfquery name="get_country" datasource="#dsn#">
		SELECT 
			COUNTRY COUNTRY_ID,
			SALES_COUNTY SALES_ID
		FROM 
			COMPANY 
		WHERE 
			COMPANY_ID =#attributes.company_id#
	</cfquery>
<cfelseif isdefined("attributes.consumer_id") and len(attributes.consumer_id)>
	<cfquery name="get_country" datasource="#dsn#">
		SELECT 
			SALES_COUNTY SALES_ID,
			TAX_COUNTRY_ID COUNTRY_ID
		FROM 
			CONSUMER 
		WHERE 
			CONSUMER_ID=#attributes.consumer_id#
	</cfquery>   
</cfif>
<cflock name="#CREATEUUID()#" timeout="20">
	<cftransaction>	
		<cfquery name="UPD_OFFER" datasource="#DSN3#">
			UPDATE
				OFFER 
			SET
				OFFER_STATUS = <cfif isDefined("attributes.offer_status")>1<cfelse>0</cfif>,
				PAYMETHOD = <cfif len(attributes.paymethod_id) and len(attributes.pay_method)>#attributes.paymethod_id#<cfelse>NULL</cfif>,
				CARD_PAYMETHOD_ID = <cfif len(attributes.card_paymethod_id) and len(attributes.pay_method)>#attributes.card_paymethod_id#<cfelse>NULL</cfif>,
				CARD_PAYMETHOD_RATE = <cfif len(attributes.commission_rate) and len(attributes.pay_method)>#attributes.commission_rate#<cfelse>NULL</cfif>,
				DELIVERDATE = <cfif len(attributes.deliverdate)>#attributes.deliverdate#<cfelse>NULL</cfif>,
				SHIP_DATE = <cfif len(attributes.ship_date)>#attributes.ship_date#<cfelse>NULL</cfif>,
				FINISHDATE = <cfif len(attributes.finishdate)>#attributes.finishdate#<cfelse>NULL</cfif>,
				OFFER_DATE = #attributes.offer_date#,
				OFFER_STAGE = <cfif isdefined("attributes.process_stage")>#attributes.process_stage#<cfelse>NULL</cfif>,
				<cfif attributes.member_type is "partner">		
					PARTNER_ID = <cfif len(attributes.member_id)>#attributes.member_id#<cfelse>NULL</cfif>,
					COMPANY_ID = <cfif len(attributes.company_id)>#attributes.company_id#<cfelse>NULL</cfif>,
					CONSUMER_ID = NULL,
				<cfelseif attributes.member_type is "consumer">		
					PARTNER_ID = NULL,
					COMPANY_ID = NULL,
					CONSUMER_ID = #attributes.member_id#,
				</cfif>
				<cfif isdefined("attributes.ref_member_type") and attributes.ref_member_type is 'partner'>
					REF_PARTNER_ID = #attributes.ref_member_id#,
					REF_COMPANY_ID = #attributes.ref_company_id#,
					REF_CONSUMER_ID = NULL,
				<cfelseif isdefined("attributes.ref_member_type") and attributes.ref_member_type is 'consumer'>		
					REF_PARTNER_ID = NULL,
					REF_COMPANY_ID = NULL,
					REF_CONSUMER_ID = #attributes.ref_member_id#,
				<cfelse>
					REF_PARTNER_ID = NULL,
					REF_COMPANY_ID = NULL,
					REF_CONSUMER_ID = NULL,		
				</cfif>
				SALES_EMP_ID = <cfif len(attributes.sales_emp_id) and len(attributes.sales_emp)>#attributes.sales_emp_id#<cfelse>NULL</cfif>,
				SALES_PARTNER_ID = <cfif isdefined("attributes.sales_member") and len(attributes.sales_member) and len(attributes.sales_member_id) and len(attributes.sales_member_type) and attributes.sales_member_type eq 'partner'>#attributes.sales_member_id#<cfelse>NULL</cfif>,
				SALES_CONSUMER_ID = <cfif isdefined("attributes.sales_member") and len(attributes.sales_member) and len(attributes.sales_member_id) and len(attributes.sales_member_type) and attributes.sales_member_type eq 'consumer'>#attributes.sales_member_id#<cfelse>NULL</cfif>,
				OFFER_DETAIL = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.offer_detail#">,
				OFFER_HEAD = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.offer_head#">,
				<cfif isdefined('attributes.basket_money') and len(attributes.basket_money)>	
					OTHER_MONEY = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.basket_money#">,
					OTHER_MONEY_VALUE = #((attributes.basket_net_total*attributes.basket_rate1)/attributes.basket_rate2)#,
				</cfif>
                NETTOTAL = <cfif isdefined("attributes.basket_net_total") and len(attributes.basket_net_total)>#attributes.basket_net_total#<cfelse>NULL</cfif>,
				TAX = <cfif isdefined("attributes.basket_tax_total") and len(attributes.basket_tax_total)>#attributes.basket_tax_total#<cfelse>NULL</cfif>,
				OTV_TOTAL = <cfif isdefined("attributes.basket_otv_total") and len(attributes.basket_otv_total)>#attributes.basket_otv_total#<cfelse>NULL</cfif>,
				PRICE = <cfif isdefined('attributes.price') and len(attributes.price)>#attributes.price#<cfelse>NULL</cfif>,
				INCLUDED_KDV = <cfif isdefined("included_kdv") and len(included_kdv)>1<cfelse>0</cfif>,
				SHIP_METHOD = <cfif len(attributes.ship_method_id)>#attributes.ship_method_id#<cfelse>NULL</cfif>,
				IS_PARTNER_ZONE = <cfif isDefined("attributes.is_partner_zone")>1<cfelse>0</cfif>,
				IS_PUBLIC_ZONE = <cfif isDefined("attributes.is_public_zone")>1<cfelse>0</cfif>,
				PROJECT_ID = <cfif len(attributes.project_head) and len(attributes.project_id)>#attributes.project_id#<cfelse>NULL</cfif>,
				WORK_ID = <cfif isdefined("attributes.work_id") and len(attributes.work_id) and len(attributes.work_head)>#attributes.work_id#<cfelse>NULL</cfif>,
				SHIP_ADDRESS=<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.ship_address#">,
				DUE_DATE = <cfif isdefined("offer_due_date") and len(offer_due_date)>#offer_due_date#<cfelse>NULL</cfif>,
				REF_NO = <cfif isdefined("attributes.ref_no") and len(attributes.ref_no)><cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.ref_no#"><cfelse>NULL</cfif>,
				CITY_ID = <cfif isdefined("attributes.city_id") and len(attributes.city_id)>#attributes.city_id#<cfelse>NULL</cfif>,
				COUNTY_ID = <cfif isdefined("attributes.county_id") and len(attributes.county_id)>#attributes.county_id#<cfelse>NULL</cfif>,
				SALES_ADD_OPTION_ID = <cfif len(attributes.sales_add_option)>#attributes.sales_add_option#<cfelse>NULL</cfif>,
				<cfif isdefined("attributes.camp_id")  and isdefined("attributes.camp_name")>	
					<cfif len(attributes.camp_id) and len(attributes.camp_name)>CAMP_ID = #attributes.camp_id#,<cfelse>CAMP_ID = NULL,</cfif>
				</cfif>
				RELATION_OFFER_ID = <cfif (isdefined('attributes.rel_offer_id') and len(attributes.rel_offer_id)) and (isdefined('attributes.rel_offer_head') and len(attributes.rel_offer_head))>#attributes.rel_offer_id#,<cfelse>NULL,</cfif>
				UPDATE_DATE = #now()#,
				UPDATE_IP = <cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.remote_addr#">,
				UPDATE_MEMBER = #session.ep.userid#,
                COUNTRY_ID=<cfif isdefined("attributes.country_id") and len(attributes.country_id)>#attributes.country_id#<cfelseif isdefined("get_country") and len(get_country.country_id)>#get_country.country_id#<cfelse>NULL</cfif>,
                SZ_ID=<cfif isdefined("attributes.sales_zone_id") and len(attributes.sales_zone_id)>#attributes.sales_zone_id#<cfelseif isdefined("get_country") and len(get_country.sales_id)>#get_country.sales_id#<cfelse>NULL</cfif>,
				PROBABILITY = <cfif isdefined("attributes.probability")>#attributes.probability#<cfelse>NULL</cfif>,
                SA_DISCOUNT = <cfif isdefined("form.genel_indirim") and len(form.genel_indirim)>#form.genel_indirim#<cfelse>NULL</cfif>,
				STOPAJ = <cfif isdefined("attributes.stopaj") and len(attributes.stopaj)><cfqueryparam cfsqltype="cf_sql_float" value="#attributes.stopaj#"><cfelse>NULL</cfif>,
				STOPAJ_ORAN = <cfif isdefined("attributes.stopaj_yuzde") and len(attributes.stopaj_yuzde)><cfqueryparam cfsqltype="cf_sql_float" value="#attributes.stopaj_yuzde#"><cfelse>NULL</cfif>,
				STOPAJ_RATE_ID = <cfif isdefined("attributes.stopaj_id") and len(attributes.stopaj_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.stopaj_id#"><cfelse>NULL</cfif>,
				TEVKIFAT = <cfif isdefined("attributes.tevkifat_box") and len(attributes.tevkifat_box) and attributes.tevkifat_box eq 1><cfqueryparam cfsqltype="cf_sql_integer" value="1"><cfelse><cfqueryparam cfsqltype="cf_sql_integer" value="0"></cfif>,
				TEVKIFAT_ORAN = <cfif isdefined("attributes.tevkifat_oran") and len(attributes.tevkifat_oran)><cfqueryparam cfsqltype="cf_sql_float" value="#attributes.tevkifat_oran#"><cfelse>NULL</cfif>,
				TEVKIFAT_ID = <cfif isdefined("attributes.tevkifat_id") and len(attributes.tevkifat_id)><cfqueryparam cfsqltype="cf_sql_float" value="#attributes.tevkifat_id#"><cfelse>NULL</cfif>,
				CONTACT_PERSON = <cfif isdefined("attributes.contact_person") and len(attributes.contact_person)><cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.contact_person#" maxlength="200"><cfelse>NULL</cfif>
                    			
			WHERE
				OFFER_ID = #attributes.offer_id#
		</cfquery>
		
		<!--- revizyon no --->
		<cfif attributes.xml_offer_revision eq 1>
			<cfif (isdefined('attributes.rel_offer_id') and len(attributes.rel_offer_id)) and (isdefined('attributes.rel_offer_head') and len(attributes.rel_offer_head))>
				<cfquery name="getRelOfferNumber" datasource="#dsn3#">
					SELECT OFFER_NUMBER FROM OFFER WHERE OFFER_ID = #attributes.rel_offer_id#
				</cfquery>
				<cfquery name="getOfferCount" datasource="#dsn3#">
					SELECT 
						COUNT(OFFER_ID) AS REVIZE
					FROM
						OFFER
					WHERE
						RELATION_OFFER_ID = #attributes.rel_offer_id#
				</cfquery>
				<cfif getOfferCount.revize neq 0>
					<cfset revize_number = RepeatString("0",2-Len(getOfferCount.revize)) & (getOfferCount.revize)>
				<cfelse>
					<cfset revize_number = 00>
				</cfif>
				<cfset teklif_no = '#getRelOfferNumber.offer_number#-#revize_number#'>
			<cfelse>
				<cfquery name="getOfferNumber" datasource="#dsn3#">
					SELECT OFFER_NUMBER FROM OFFER WHERE OFFER_ID = #attributes.offer_id#
				</cfquery>
				<cfset teklif_no = '#getOfferNumber.offer_number#-00'>
			</cfif>
			<cfquery name="updOfferNumber" datasource="#dsn3#">
				UPDATE OFFER SET OFFER_REVIZE_NO = <cfqueryparam cfsqltype="cf_sql_varchar" value="#teklif_no#"> WHERE OFFER_ID = #attributes.offer_id#
			</cfquery>
		</cfif>
		<!--- revizyon no --->
		
		<!--- urun asortileri siliniyor  --->
		<cfquery name="DEL_OFFER_ASSORT_ROWS" datasource="#DSN3#">
			DELETE FROM
				PRODUCTION_ASSORTMENT
			WHERE
				ACTION_TYPE = 1 AND 
				ASSORTMENT_ID IN (SELECT OFFER_ROW_ID FROM OFFER_ROW WHERE OFFER_ID = #attributes.offer_id#)
		</cfquery>
		<cfscript>
			add_relation_rows(
				action_type:'del',
				action_dsn : '#dsn3#',
				to_table:'OFFER',
				to_action_id : attributes.offer_id
				);
		</cfscript>
		<cfquery name="DEL_OFFER_ROWS" datasource="#DSN3#">
			DELETE FROM OFFER_ROW WHERE OFFER_ID = #attributes.offer_id#
		</cfquery>
		<cfloop from="1" to="#attributes.rows_#" index="i">
			<cf_date tarih="attributes.deliver_date#i#">
			<cfif session.ep.our_company_info.spect_type and isdefined('attributes.is_production#i#') and evaluate('attributes.is_production#i#') eq 1>
				<cfif attributes.member_type is "consumer">
					<cfset attributes.consumer_id=attributes.member_id>
				<cfelse>
					<cfset attributes.consumer_id=''>
				</cfif>
				<cfset specer_spec_id=''>
                <cfset dsn_type=dsn3>
				<cfif not isdefined('attributes.spect_id#i#') or not len(evaluate('attributes.spect_id#i#'))>
					<cfinclude template="../../objects/query/add_basket_spec.cfm">
				<cfelseif attributes.basket_spect_type eq 7 ><!--- satırdada guncellenebilmeli bu spec tipinde--->
					<cfset specer_spec_id=evaluate('attributes.spect_id#i#')>
					<cfinclude template="../../objects/query/add_basket_spec.cfm">
				</cfif>
			</cfif>
			<cfquery name="ADD_OFFER_ROW" datasource="#DSN3#">
				INSERT INTO
					OFFER_ROW
				(
					OFFER_ID,
					PRODUCT_ID,
					STOCK_ID,
					QUANTITY,
					UNIT,
					UNIT_ID,
					PRICE,
					TAX,
					DUEDATE,
					PRODUCT_NAME,
				<cfif isdefined('attributes.deliver_date#i#') and isdate(evaluate("attributes.deliver_date#i#"))>
					DELIVER_DATE,
				</cfif>
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
					PRICE_OTHER,
					NET_MALIYET,
					<!--- COST_ID, --->
					EXTRA_COST,
					MARJ,
					<!--- Yeni Eklenen Alanlar. Promosyon İle İlgili --->
					PROM_COMISSION,
					PROM_COST,
					DISCOUNT_COST,
					PROM_ID,
					IS_PROMOTION,
					PROM_STOCK_ID,
					UNIQUE_RELATION_ID,
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
					DELIVERY_CONDITION,
					LIST_PRICE,
					LOT_NO,
					NUMBER_OF_INSTALLMENT,
					PRICE_CAT,
					CATALOG_ID,
					EK_TUTAR_PRICE,
					OTV_ORAN,
					OTVTOTAL,
                    WRK_ROW_ID,
                    WRK_ROW_RELATION_ID,
                    RELATED_ACTION_ID,
                    RELATED_ACTION_TABLE,
					BASKET_EMPLOYEE_ID,
					WIDTH_VALUE,
					DEPTH_VALUE,
					HEIGHT_VALUE,
					ROW_PROJECT_ID,
					KARMA_PRODUCT_ID,
					PBS_ID,
					ROW_WORK_ID
					<cfif isdefined('attributes.row_exp_center_id#i#') and len(evaluate("attributes.row_exp_center_id#i#")) and isdefined('attributes.row_exp_center_name#i#') and len(evaluate("attributes.row_exp_center_name#i#"))>,EXPENSE_CENTER_ID</cfif>
					<cfif isdefined('attributes.row_exp_item_id#i#') and len(evaluate("attributes.row_exp_item_id#i#")) and isdefined('attributes.row_exp_item_name#i#') and len(evaluate("attributes.row_exp_item_name#i#"))>,EXPENSE_ITEM_ID</cfif>
					<cfif isdefined('attributes.row_activity_id#i#') and len(evaluate("attributes.row_activity_id#i#"))>,ACTIVITY_TYPE_ID</cfif>
					<cfif isdefined('attributes.row_acc_code#i#') and len(evaluate("attributes.row_acc_code#i#"))>,ACC_CODE</cfif>
					<cfif isdefined('attributes.row_bsmv_rate#i#') and len(evaluate("attributes.row_bsmv_rate#i#"))>,BSMV_RATE</cfif>
					<cfif isdefined('attributes.row_bsmv_amount#i#') and len(evaluate("attributes.row_bsmv_amount#i#"))>,BSMV_AMOUNT</cfif>
					<cfif isdefined('attributes.row_bsmv_currency#i#') and len(evaluate("attributes.row_bsmv_currency#i#"))>,BSMV_CURRENCY</cfif>
					<cfif isdefined('attributes.row_oiv_rate#i#') and len(evaluate("attributes.row_oiv_rate#i#"))>,OIV_RATE</cfif>
					<cfif isdefined('attributes.row_oiv_amount#i#') and len(evaluate("attributes.row_oiv_amount#i#"))>,OIV_AMOUNT</cfif>
					<cfif isdefined('attributes.row_tevkifat_rate#i#') and len(evaluate("attributes.row_tevkifat_rate#i#"))>,TEVKIFAT_RATE</cfif>
					<cfif isdefined('attributes.row_tevkifat_amount#i#') and len(evaluate("attributes.row_tevkifat_amount#i#"))>,TEVKIFAT_AMOUNT</cfif>
					<cfif isdefined('attributes.row_weight#i#') and len(evaluate("attributes.row_weight#i#"))>,WEIGHT</cfif>
					<cfif isdefined('attributes.row_specific_weight#i#') and len(evaluate("attributes.row_specific_weight#i#"))>,SPECIFIC_WEIGHT</cfif>
					<cfif isdefined('attributes.row_volume#i#') and len(evaluate("attributes.row_volume#i#"))>,VOLUME</cfif>
					<cfif isdefined('attributes.row_tevkifat_id#i#') and len(evaluate("attributes.row_tevkifat_id#i#"))>
						,TEVKIFAT_ID
					</cfif>
				)
				VALUES
				(
					#attributes.offer_id#,
					#evaluate("attributes.product_id#i#")#,
					#evaluate("attributes.stock_id#i#")#,
					#evaluate("attributes.amount#i#")#,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.unit#i#')#">,
					#evaluate("attributes.unit_id#i#")#,
					#evaluate("attributes.price#i#")#,
					#evaluate("attributes.tax#i#")#,
				<cfif isdefined("attributes.duedate#i#") and len(evaluate("attributes.duedate#i#"))>
					#evaluate("attributes.duedate#i#")#
				<cfelse>
					NULL
				</cfif>,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.product_name#i#')#">,
				<cfif isdefined('attributes.deliver_date#i#') and isdate(evaluate("attributes.deliver_date#i#"))>
					#evaluate('attributes.deliver_date#i#')#,
				</cfif>
				<cfif isdefined("attributes.deliver_dept#i#") and len(trim(evaluate("attributes.deliver_dept#i#"))) and len(listfirst(evaluate("attributes.deliver_dept#i#"),"-"))>
					#listfirst(evaluate("attributes.deliver_dept#i#"),"-")#
				<cfelse>
					NULL
				</cfif>,
				<cfif isdefined("attributes.deliver_dept#i#") and listlen(trim(evaluate("attributes.deliver_dept#i#")),"-") eq 2 and len(listlast(evaluate("attributes.deliver_dept#i#"),"-"))>
					#listlast(evaluate("attributes.deliver_dept#i#"),"-")#
				<cfelse>
					NULL
				</cfif>,
				<cfif isdefined('attributes.indirim1#i#') and len(evaluate('attributes.indirim1#i#'))>#evaluate('attributes.indirim1#i#')#<cfelse>0</cfif>,
				<cfif isdefined('attributes.indirim2#i#') and len(evaluate('attributes.indirim2#i#'))>#evaluate('attributes.indirim2#i#')#<cfelse>0</cfif>,
				<cfif isdefined('attributes.indirim3#i#') and len(evaluate('attributes.indirim3#i#'))>#evaluate('attributes.indirim3#i#')#<cfelse>0</cfif>,
				<cfif isdefined('attributes.indirim4#i#') and len(evaluate('attributes.indirim4#i#'))>#evaluate('attributes.indirim4#i#')#<cfelse>0</cfif>,
				<cfif isdefined('attributes.indirim5#i#') and len(evaluate('attributes.indirim5#i#'))>#evaluate('attributes.indirim5#i#')#<cfelse>0</cfif>,
				<cfif isdefined('attributes.indirim6#i#') and len(evaluate('attributes.indirim6#i#'))>#evaluate('attributes.indirim6#i#')#<cfelse>0</cfif>,
				<cfif isdefined('attributes.indirim7#i#') and len(evaluate('attributes.indirim7#i#'))>#evaluate('attributes.indirim7#i#')#<cfelse>0</cfif>,
				<cfif isdefined('attributes.indirim8#i#') and len(evaluate('attributes.indirim8#i#'))>#evaluate('attributes.indirim8#i#')#<cfelse>0</cfif>,
				<cfif isdefined('attributes.indirim9#i#') and len(evaluate('attributes.indirim9#i#'))>#evaluate('attributes.indirim9#i#')#<cfelse>0</cfif>,
				<cfif isdefined('attributes.indirim10#i#') and len(evaluate('attributes.indirim10#i#'))>#evaluate('attributes.indirim10#i#')#<cfelse>0</cfif>,
				<cfif isdefined('attributes.other_money_#i#')><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.other_money_#i#')#"><cfelse>NULL</cfif>,
				<cfif isdefined('attributes.other_money_value_#i#') and len(evaluate("attributes.other_money_value_#i#"))>#evaluate('attributes.other_money_value_#i#')#<cfelse>NULL</cfif>,
				<cfif isdefined('attributes.spect_id#i#') and len(evaluate('attributes.spect_id#i#'))>
					#evaluate('attributes.spect_id#i#')#,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#left(evaluate('attributes.spect_name#i#'),500)#">,
				</cfif>
				<cfif isdefined('attributes.price_other#i#') and len(evaluate('attributes.price_other#i#'))>#evaluate('attributes.price_other#i#')#<cfelse>NULL</cfif>,
				<cfif isdefined('attributes.net_maliyet#i#') and len(evaluate('attributes.net_maliyet#i#'))>#evaluate('attributes.net_maliyet#i#')#<cfelse>0</cfif>,
				<!--- <cfif isdefined('attributes.cost_id#i#') and len(evaluate('attributes.cost_id#i#'))>#evaluate('attributes.cost_id#i#')#<cfelse>NULL</cfif>, --->
				<cfif isdefined('attributes.extra_cost#i#') and len(evaluate('attributes.extra_cost#i#'))>#evaluate('attributes.extra_cost#i#')#<cfelse>0</cfif>,
				<cfif isdefined('attributes.marj#i#') and len(evaluate('attributes.marj#i#'))>#evaluate('attributes.marj#i#')#,<cfelse>0,</cfif>			
				<cfif isdefined('attributes.promosyon_yuzde#i#') and len(evaluate('attributes.promosyon_yuzde#i#'))>
					#evaluate('attributes.promosyon_yuzde#i#')#,
				<cfelse>
					NULL,
				</cfif>
				<cfif isdefined('attributes.promosyon_maliyet#i#') and len(evaluate('attributes.promosyon_maliyet#i#'))>
					#evaluate('attributes.promosyon_maliyet#i#')#,
				<cfelse>
					0,
				</cfif>
				<cfif isdefined('attributes.iskonto_tutar#i#') and len(evaluate('attributes.iskonto_tutar#i#'))>
					#evaluate('attributes.iskonto_tutar#i#')#,
				<cfelse>
					NULL,
				</cfif>
				<cfif isdefined('attributes.row_promotion_id#i#') and len(evaluate('attributes.row_promotion_id#i#'))>
					#evaluate('attributes.row_promotion_id#i#')#,
				<cfelse>
					NULL,
				</cfif>
				<cfif isdefined('attributes.is_promotion#i#') and len(evaluate('attributes.is_promotion#i#'))>
					#evaluate('attributes.is_promotion#i#')#,
				<cfelse>
					NULL,
				</cfif>
				<cfif isdefined('attributes.prom_stock_id#i#') and len(evaluate('attributes.prom_stock_id#i#'))>
					#evaluate('attributes.prom_stock_id#i#')#,
				<cfelse>
					NULL,
				</cfif>
				<cfif isdefined('attributes.row_unique_relation_id#i#') and len(evaluate('attributes.row_unique_relation_id#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.row_unique_relation_id#i#')#"><cfelse>NULL</cfif>,
				<cfif isdefined('attributes.product_name_other#i#') and len(evaluate('attributes.product_name_other#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.product_name_other#i#')#"><cfelse>NULL</cfif>,
				<cfif isdefined('attributes.amount_other#i#') and len(evaluate('attributes.amount_other#i#'))>#evaluate('attributes.amount_other#i#')#<cfelse>NULL</cfif>,
				<cfif isdefined('attributes.unit_other#i#') and len(evaluate('attributes.unit_other#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.unit_other#i#')#"><cfelse>NULL</cfif>,
				<cfif isdefined('attributes.ek_tutar#i#') and len(evaluate('attributes.ek_tutar#i#'))>#evaluate('attributes.ek_tutar#i#')#<cfelse>NULL</cfif>,
				<cfif isdefined('attributes.ek_tutar_total#i#') and len(evaluate('attributes.ek_tutar_total#i#'))>#evaluate('attributes.ek_tutar_total#i#')#<cfelse>NULL</cfif>,
				<cfif isdefined('attributes.ek_tutar_other_total#i#') and len(evaluate('attributes.ek_tutar_other_total#i#'))>#evaluate('attributes.ek_tutar_other_total#i#')#<cfelse>NULL</cfif>,
				<cfif isdefined('attributes.shelf_number#i#') and len(evaluate('attributes.shelf_number#i#'))>#evaluate('attributes.shelf_number#i#')#<cfelse>NULL</cfif>,
				<cfif isdefined('attributes.manufact_code#i#') and len(evaluate('attributes.manufact_code#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.manufact_code#i#')#"><cfelse>NULL</cfif>,
				<cfif isdefined('attributes.basket_extra_info#i#') and len(evaluate('attributes.basket_extra_info#i#'))><cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('attributes.basket_extra_info#i#')#"><cfelse>NULL</cfif>,
				<cfif isdefined('attributes.select_info_extra#i#') and len(evaluate('attributes.select_info_extra#i#'))><cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('attributes.select_info_extra#i#')#"><cfelse>NULL</cfif>,
				<cfif isdefined('attributes.detail_info_extra#i#') and len(evaluate('attributes.detail_info_extra#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.detail_info_extra#i#')#"><cfelse>NULL</cfif>,
				<cfif isdefined('attributes.delivery_condition#i#') and len(evaluate('attributes.delivery_condition#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.delivery_condition#i#')#"><cfelse>NULL</cfif>,
				<cfif isdefined('attributes.list_price#i#') and len(evaluate('attributes.list_price#i#'))>#evaluate('attributes.list_price#i#')#<cfelse>NULL</cfif>,
				<cfif isdefined('attributes.lot_no#i#') and len(evaluate('attributes.lot_no#i#'))>'#evaluate('attributes.lot_no#i#')#'<cfelse>NULL</cfif>,
				<cfif isdefined('attributes.number_of_installment#i#') and len(evaluate('attributes.number_of_installment#i#'))>#evaluate('attributes.number_of_installment#i#')#<cfelse>NULL</cfif>,
				<cfif isdefined('attributes.price_cat#i#') and len(evaluate('attributes.price_cat#i#'))>#evaluate('attributes.price_cat#i#')#<cfelse>NULL</cfif>,
				<cfif isdefined('attributes.row_catalog_id#i#') and len(evaluate('attributes.row_catalog_id#i#'))>#evaluate('attributes.row_catalog_id#i#')#<cfelse>NULL</cfif>,
				<cfif isdefined('attributes.ek_tutar_price#i#') and len(evaluate('attributes.ek_tutar_price#i#'))>#evaluate('attributes.ek_tutar_price#i#')#<cfelse>NULL</cfif>,
				<cfif isdefined('attributes.otv_oran#i#') and len(evaluate('attributes.otv_oran#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.otv_oran#i#')#"><cfelse>NULL</cfif>,
				<cfif isdefined('attributes.row_otvtotal#i#') and len(evaluate('attributes.row_otvtotal#i#'))>#evaluate('attributes.row_otvtotal#i#')#<cfelse>NULL</cfif>,
				<cfif isdefined('attributes.wrk_row_id#i#') and len(evaluate('attributes.wrk_row_id#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.wrk_row_id#i#')#"><cfelse>NULL</cfif>,
                <cfif isdefined('attributes.wrk_row_relation_id#i#') and len(evaluate('attributes.wrk_row_relation_id#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.wrk_row_relation_id#i#')#"><cfelse>NULL</cfif>,
                <cfif isdefined('attributes.related_action_id#i#') and len(evaluate('attributes.related_action_id#i#'))>#evaluate('attributes.related_action_id#i#')#<cfelse>NULL</cfif>,
                <cfif isdefined('attributes.related_action_table#i#') and len(evaluate('attributes.related_action_table#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.related_action_table#i#')#"><cfelse>NULL</cfif>,
				<cfif isdefined('attributes.basket_employee_id#i#') and len(evaluate('attributes.basket_employee_id#i#')) and isdefined('attributes.basket_employee#i#') and len(evaluate('attributes.basket_employee#i#'))>#evaluate('attributes.basket_employee_id#i#')#<cfelse>NULL</cfif>,
				<cfif isdefined('attributes.row_width#i#') and len(evaluate('attributes.row_width#i#'))>#evaluate('attributes.row_width#i#')#<cfelse>NULL</cfif>,
				<cfif isdefined('attributes.row_depth#i#') and len(evaluate('attributes.row_depth#i#'))>#evaluate('attributes.row_depth#i#')#<cfelse>NULL</cfif>,
				<cfif isdefined('attributes.row_height#i#') and len(evaluate('attributes.row_height#i#'))>#evaluate('attributes.row_height#i#')#<cfelse>NULL</cfif>,
				<cfif isdefined('attributes.row_project_id#i#') and len(evaluate('attributes.row_project_id#i#')) and isdefined('attributes.row_project_name#i#') and len(evaluate('attributes.row_project_name#i#'))>#evaluate('attributes.row_project_id#i#')#<cfelse>NULL</cfif>,
                <cfif isdefined('attributes.karma_product_id#i#') and len(evaluate('attributes.karma_product_id#i#'))>#evaluate('attributes.karma_product_id#i#')#<cfelse>NULL</cfif>,
				<cfif isdefined('attributes.pbs_code#i#') and len(evaluate('attributes.pbs_code#i#')) and isdefined('attributes.pbs_id#i#') and len(evaluate('attributes.pbs_id#i#'))>#evaluate('attributes.pbs_id#i#')#<cfelse>NULL</cfif>,
				<cfif isdefined('attributes.row_work_id#i#') and len(evaluate('attributes.row_work_id#i#')) and isdefined('attributes.row_work_name#i#') and len(evaluate('attributes.row_work_name#i#'))>#evaluate('attributes.row_work_id#i#')#<cfelse>NULL</cfif>
				<cfif isdefined('attributes.row_exp_center_id#i#') and len(evaluate("attributes.row_exp_center_id#i#")) and isdefined('attributes.row_exp_center_name#i#') and len(evaluate("attributes.row_exp_center_name#i#"))>,<cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('attributes.row_exp_center_id#i#')#"></cfif>
				<cfif isdefined('attributes.row_exp_item_id#i#') and len(evaluate("attributes.row_exp_item_id#i#")) and isdefined('attributes.row_exp_item_name#i#') and len(evaluate("attributes.row_exp_item_name#i#"))>,<cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('attributes.row_exp_item_id#i#')#"></cfif>
				<cfif isdefined('attributes.row_activity_id#i#') and len(evaluate("attributes.row_activity_id#i#"))>,<cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('attributes.row_activity_id#i#')#"></cfif>
				<cfif isdefined('attributes.row_acc_code#i#') and len(evaluate("attributes.row_acc_code#i#"))>,<cfqueryparam cfsqltype="cf_sql_nvarchar" value="#evaluate('attributes.row_acc_code#i#')#"></cfif>
				<cfif isdefined('attributes.row_bsmv_rate#i#') and len(evaluate("attributes.row_bsmv_rate#i#"))>,<cfqueryparam cfsqltype="cf_sql_float" value="#evaluate('attributes.row_bsmv_rate#i#')#"></cfif>
				<cfif isdefined('attributes.row_bsmv_amount#i#') and len(evaluate("attributes.row_bsmv_amount#i#"))>,<cfqueryparam cfsqltype="cf_sql_float" value="#evaluate('attributes.row_bsmv_amount#i#')#"></cfif>
				<cfif isdefined('attributes.row_bsmv_currency#i#') and len(evaluate("attributes.row_bsmv_currency#i#"))>,<cfqueryparam cfsqltype="cf_sql_float" value="#evaluate('attributes.row_bsmv_currency#i#')#"></cfif>
				<cfif isdefined('attributes.row_oiv_rate#i#') and len(evaluate("attributes.row_oiv_rate#i#"))>,<cfqueryparam cfsqltype="cf_sql_float" value="#evaluate('attributes.row_oiv_rate#i#')#"></cfif>
				<cfif isdefined('attributes.row_oiv_amount#i#') and len(evaluate("attributes.row_oiv_amount#i#"))>,<cfqueryparam cfsqltype="cf_sql_float" value="#evaluate('attributes.row_oiv_amount#i#')#"></cfif>
				<cfif isdefined('attributes.row_tevkifat_rate#i#') and len(evaluate("attributes.row_tevkifat_rate#i#"))>,<cfqueryparam cfsqltype="cf_sql_float" value="#evaluate('attributes.row_tevkifat_rate#i#')#"></cfif>
				<cfif isdefined('attributes.row_tevkifat_amount#i#') and len(evaluate("attributes.row_tevkifat_amount#i#"))>,<cfqueryparam cfsqltype="cf_sql_float" value="#evaluate('attributes.row_tevkifat_amount#i#')#"></cfif>
				<cfif isdefined('attributes.row_weight#i#') and len(evaluate("attributes.row_weight#i#"))>,<cfqueryparam cfsqltype="cf_sql_float" value="#evaluate('attributes.row_weight#i#')#"></cfif>
				<cfif isdefined('attributes.row_specific_weight#i#') and len(evaluate("attributes.row_specific_weight#i#"))>,<cfqueryparam cfsqltype="cf_sql_float" value="#evaluate('attributes.row_specific_weight#i#')#"></cfif>
				<cfif isdefined('attributes.row_volume#i#') and len(evaluate("attributes.row_volume#i#"))>,<cfqueryparam cfsqltype="cf_sql_float" value="#evaluate('attributes.row_volume#i#')#"></cfif>
				<cfif isdefined('attributes.row_tevkifat_id#i#') and len(evaluate("attributes.row_tevkifat_id#i#"))>
					,<cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('attributes.row_tevkifat_id#i#')#">
				</cfif>
				)
			</cfquery>
			<cfif isdefined('attributes.related_action_id#i#') and Evaluate('attributes.related_action_id#i#') gt 0 and isdefined('attributes.wrk_row_relation_id#i#') and Evaluate('attributes.wrk_row_relation_id#i#') gt 0>
				<cfscript>
                    add_relation_rows(
                        action_type:'add',
                        action_dsn : '#dsn3#',
                        to_table:'OFFER',
                        from_table:'#evaluate("attributes.RELATED_ACTION_TABLE#i#")#',
                        to_wrk_row_id : Evaluate("attributes.wrk_row_id#i#"),
                        from_wrk_row_id :Evaluate("attributes.wrk_row_relation_id#i#"),
                        amount : Evaluate("attributes.amount#i#"),
                        to_action_id : attributes.offer_id,
                        from_action_id :Evaluate("attributes.related_action_id#i#")
                        );
                </cfscript>
            </cfif>
			<!---  urun asortileri --->			
			<cfquery name="GET_MAX_OFFER_ROW" datasource="#DSN3#">
				SELECT MAX(OFFER_ROW_ID) AS OFFER_ROW_ID FROM OFFER_ROW
			</cfquery>
	
			<cfset attributes.ROW_MAIN_ID = get_max_offer_row.offer_row_id>
			<cfset row_id = I>
			<cfset ACTION_TYPE_ID = 1>
			<cfset attributes.product_id = evaluate('attributes.product_id#i#')>
			<cfinclude template="add_assortment_textile_js.cfm">
		</cfloop>
		<!--- Teklife ait cari degistigi an onceki cari ile iliskiyi kesmek gerekli. Analiz sonucu ve sonuc detayları direkt silinir. BK 20090112 --->
		<cfif ((attributes.old_consumer_id neq attributes.consumer_id) or (attributes.old_member_id neq attributes.member_id)) or (attributes.old_member_type neq attributes.member_type)>
			<cfquery name="DEL_ANALYSIS_RESULTS_DETAILS" datasource="#DSN3#">
				DELETE FROM #dsn_alias#.MEMBER_ANALYSIS_RESULTS_DETAILS WHERE RESULT_ID IN (SELECT RESULT_ID FROM #dsn_alias#.MEMBER_ANALYSIS_RESULTS WHERE OFFER_ID = #attributes.offer_id# AND OUR_COMPANY_ID = #session.ep.company_id#)
			</cfquery>
			<cfquery name="DEL_ANALYSIS_RESULTS_DETAILS" datasource="#DSN3#">
				DELETE FROM #dsn_alias#.MEMBER_ANALYSIS_RESULTS WHERE OFFER_ID = #attributes.offer_id# AND OUR_COMPANY_ID = #session.ep.company_id#
			</cfquery>
		</cfif>
		<cfscript>
			basket_kur_ekle(action_id:OFFER_ID,table_type_id:4,process_type:1);
		</cfscript>
        <!---Ek Bilgiler--->
		<cfset attributes.info_id =  attributes.offer_id>
        <cfset attributes.is_upd = 1>
        <cfset attributes.info_type_id = -9>
        <cfinclude template="../../objects/query/add_info_plus2.cfm">
        <!---Ek Bilgiler--->
		
        <!--- History --->
		<cfinclude template="add_offer_history.cfm">

		<cfif isDefined("session.ep") and not isdefined("is_from_import")>
			<cf_workcube_process 
				is_upd='1' 
				data_source='#dsn3#' 
				old_process_line='#attributes.old_process_line#'
				process_stage='#attributes.process_stage#' 
				record_member='#session.ep.userid#'
				record_date='#now()#'
				action_table='OFFER'
				action_column='OFFER_ID' 
				action_id='#form.offer_id#'
				action_page='#request.self#?fuseaction=sales.list_offer&event=upd&offer_id=#form.offer_id#'
				warning_description='#getLang('','Teklif',57545)# : #offer.offer_number#'>
		</cfif>
	</cftransaction>
</cflock>

<cfif not isdefined("is_from_import")>
	<script type="text/javascript">
        window.location.href="<cfoutput>#request.self#?fuseaction=sales.list_offer&event=upd&offer_id=#offer_id#</cfoutput>";
    </script>
</cfif>
