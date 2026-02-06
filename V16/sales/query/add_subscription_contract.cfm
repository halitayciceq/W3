<cfif len(attributes.montage_date)><cf_date tarih="attributes.montage_date"></cfif>
<cfif len(attributes.start_date)><cf_date tarih="attributes.start_date"></cfif>
<cfif len(attributes.finish_date)><cf_date tarih="attributes.finish_date"></cfif>
<cfif isdefined("attributes.sales_member_comm_value")>
	<cfset attributes.sales_member_comm_value = filterNum(attributes.sales_member_comm_value)>
</cfif>
<cfset wrk_id = dateformat(now(),'YYYYMMDD')&timeformat(now(),'HHmmss')&'_#session.ep.userid#_'&round(rand()*100)>
<cflock name="#CREATEUUID()#" timeout="60">
	<cftransaction>
		<cf_papers paper_type="subscription">
		<!--- Belge numarasi update ediliyor. --->
		<cfquery name="UPD_GEN_PAP" datasource="#DSN3#">
			UPDATE 
				GENERAL_PAPERS
			SET
				SUBSCRIPTION_NUMBER = #paper_number#
			WHERE
				SUBSCRIPTION_NUMBER IS NOT NULL
		</cfquery>
	</cftransaction>
</cflock>
<cfquery name="Check_No" datasource="#dsn3#">
	SELECT SUBSCRIPTION_NO FROM SUBSCRIPTION_CONTRACT WHERE SUBSCRIPTION_NO = <cfqueryparam cfsqltype="cf_sql_varchar" value="#paper_code & '-' & paper_number#">
</cfquery>
<cfif Check_No.RecordCount>
	<cfquery name="Get_Paper_Number_Code" datasource="#dsn3#">
        SELECT SUBSCRIPTION_NUMBER FROM GENERAL_PAPERS WHERE SUBSCRIPTION_NUMBER IS NOT NULL
    </cfquery>
	<cfset End_No = listlast(Get_Paper_Number_Code.Subscription_Number,'-')>
	<cfset paper_number = End_No + 1>  
    <cflock name="#CREATEUUID()#" timeout="60">
        <cftransaction>
            <cf_papers paper_type="subscription">
            <!--- Belge numarasi update ediliyor. --->
            <cfquery name="UPD_GEN_PAP" datasource="#DSN3#">
                UPDATE 
                    GENERAL_PAPERS
                SET
                    SUBSCRIPTION_NUMBER = #paper_number#
                WHERE
                    SUBSCRIPTION_NUMBER IS NOT NULL
            </cfquery>
        </cftransaction>
    </cflock> 
</cfif>
<cflock name="#CREATEUUID()#" timeout="60">
	<cftransaction>
		<cfquery name="ADD_SUBSCRIPTION_CONTRACT" datasource="#DSN3#" result="my_result">
       		INSERT INTO 
				SUBSCRIPTION_CONTRACT
			(
				WRK_ID,
				INVOICE_COMPANY_ID,
				INVOICE_CONSUMER_ID,
				INVOICE_PARTNER_ID,
				SUBSCRIPTION_NO,
				IS_ACTIVE,
				SUBSCRIPTION_HEAD,
            <cfif isdefined("attributes.opp_id") and len(attributes.opp_id)>
				OPP_ID,
			</cfif>
			<cfif isdefined("attributes.member_type") and attributes.member_type is 'partner'>
				PARTNER_ID,
				COMPANY_ID,					
			<cfelseif isdefined("attributes.member_type") and attributes.member_type is 'consumer'>
				CONSUMER_ID,
			</cfif>
				SUBSCRIPTION_TYPE_ID,				
				SUBSCRIPTION_STAGE,
				SALES_EMP_ID,
			<cfif isdefined("attributes.sales_member_type") and attributes.sales_member_type is 'partner'>
				SALES_PARTNER_ID,
				SALES_COMPANY_ID,
			<cfelseif isdefined("attributes.sales_member_type") and attributes.sales_member_type is 'consumer'>
				SALES_CONSUMER_ID,
			</cfif>
				SALES_MEMBER_COMM_VALUE,
				SALES_MEMBER_COMM_MONEY,
			<cfif isdefined("attributes.ref_member_type") and attributes.ref_member_type is 'partner'>
				REF_PARTNER_ID,
				REF_COMPANY_ID,					
			<cfelseif isdefined("attributes.ref_member_type") and attributes.ref_member_type is 'consumer'>
				REF_CONSUMER_ID,
			<cfelseif isdefined("attributes.ref_member_type") and attributes.ref_member_type is 'employee'>
				REF_EMPLOYEE_ID,
			</cfif>
				PRODUCT_ID,
				STOCK_ID,
				CONTRACT_NO,
				MONTAGE_EMP_ID,
				PAYMENT_TYPE_ID,
				PAYMENT_TYPE_CREDITCARD_ID,
				MONTAGE_DATE,
				START_DATE,
				FINISH_DATE,
				SUBSCRIPTION_DETAIL,
				SUBSCRIPTION_INVOICE_DETAIL,
				SPECIAL_CODE,
				SHIP_ADDRESS,
				SHIP_POSTCODE,
				SHIP_SEMT,
				SHIP_COUNTY_ID,
				SHIP_CITY_ID,
				SHIP_COUNTRY_ID,
                SHIP_SZ_ID,
				INVOICE_ADDRESS,
				INVOICE_POSTCODE,
				INVOICE_SEMT,
				INVOICE_COUNTY_ID,
				INVOICE_CITY_ID,
				INVOICE_COUNTRY_ID,		
                INVOICE_SZ_ID,
                <cfif session.ep.our_company_info.IS_EFATURA eq 1 >
                INVOICE_ADDRESS_ID,	
                </cfif>					
				CONTACT_ADDRESS,
				CONTACT_POSTCODE,
				CONTACT_SEMT,
				CONTACT_COUNTY_ID,
				CONTACT_CITY_ID,
				CONTACT_COUNTRY_ID,
                CONTACT_SZ_ID,
				PREMIUM_VALUE,
				DISCOUNTTOTAL,
				NETTOTAL,
				GROSSTOTAL,
				TAXTOTAL,
				OTV_TOTAL,
				OTHER_MONEY,
				OTHER_MONEY_VALUE,
				SUBSCRIPTION_ADD_OPTION_ID,
				SALES_ADD_OPTION_ID,
				PROJECT_ID,
				SA_DISCOUNT,
                ASSETP_ID,
                VALID_DAYS,
                START_CLOCK_1,
                START_MINUTE_1,
                FINISH_CLOCK_1,
                FINISH_MINUTE_1,
                START_CLOCK_2,
                START_MINUTE_2,
                FINISH_CLOCK_2,
                FINISH_MINUTE_2,
                START_CLOCK_3,
                START_MINUTE_3,
                FINISH_CLOCK_3,
                FINISH_MINUTE_3,
                IS_GENERAL_DATE,
                HOUR1,
                MINUTE1,
				RESPONSE_HOUR1,
                RESPONSE_MINUTE1,
				CAMPAIGN_ID,
				RECORD_EMP,
				RECORD_IP,
				RECORD_DATE,
                SHIP_COORDINATE_1,
                SHIP_COORDINATE_2,
                INVOICE_COORDINATE_1,
                INVOICE_COORDINATE_2,
                CONTACT_COORDINATE_1,
                CONTACT_COORDINATE_2,
                REFERANCE_STATUS_ID,
                BRANCH_ID,
				PRODUCT_KEY,
				OUR_COMPANY_ID      
			)
			VALUES
			(
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#wrk_id#">,
				<cfif len(attributes.invoice_member_name) and len(attributes.invoice_company_id)>
					#attributes.invoice_company_id#,
					NULL,
					<cfif len(attributes.invoice_partner_id)>#attributes.invoice_partner_id#<cfelse>NULL</cfif>,
				<cfelseif len(attributes.invoice_member_name) and len(attributes.invoice_consumer_id)>
					NULL,
					#attributes.invoice_consumer_id#,
					NULL,
				<cfelseif attributes.member_type is 'partner'>
					#attributes.company_id#,
					NULL,
					#attributes.partner_id#,
				<cfelseif attributes.member_type is 'consumer'>
					NULL,
					#attributes.consumer_id#,
					NULL,
				</cfif>
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#paper_code & '-' & paper_number#">,
				<cfif isdefined("attributes.is_active")>1<cfelse>0</cfif>,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.subscription_head#">,
				<cfif isdefined("attributes.opp_id") and len(attributes.opp_id)>
                 	#attributes.opp_id#,
                </cfif>
				<cfif attributes.member_type is 'partner'>
					#attributes.partner_id#,
					#attributes.company_id#,					
				<cfelseif attributes.member_type is 'consumer'>
					#attributes.consumer_id#,
				</cfif>
				<cfif isdefined("attributes.subscription_type") and len(attributes.subscription_type)>#attributes.subscription_type#<cfelse>NULL</cfif>,
					#attributes.process_stage#,
				<cfif isdefined("attributes.sales_emp_id") and len(attributes.sales_emp_id)>#attributes.sales_emp_id#<cfelse>NULL</cfif>,
				<cfif isdefined("attributes.sales_member_type") and attributes.sales_member_type is 'partner'>
					#attributes.sales_member_id#,
					#attributes.sales_company_id#,
				<cfelseif isdefined("attributes.sales_member_type") and attributes.sales_member_type is 'consumer'>
					#attributes.sales_member_id#,
				</cfif>
				<cfif isdefined("attributes.sales_member_comm_value") and len(attributes.sales_member_comm_value)>#attributes.sales_member_comm_value#<cfelse>NULL</cfif>,
				<cfif isdefined("attributes.sales_member_comm_money") and len(attributes.sales_member_comm_money)><cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.sales_member_comm_money#"><cfelse>NULL</cfif>,
				<cfif isdefined("attributes.ref_member_type") and attributes.ref_member_type is 'partner'>
					<cfif len(attributes.ref_company)>#attributes.ref_member_id#<cfelse>NULL</cfif>,
					<cfif len(attributes.ref_company)>#attributes.ref_company_id#<cfelse>NULL</cfif>,					
				<cfelseif isdefined("attributes.ref_member_type") and attributes.ref_member_type is 'consumer'>
					<cfif len(attributes.ref_member)>#attributes.ref_member_id#<cfelse>NULL</cfif>,
				<cfelseif isdefined("attributes.ref_member_type") and attributes.ref_member_type is 'employee'>
					<cfif len(attributes.ref_member)>#attributes.ref_member_id#<cfelse>NULL</cfif>,
				</cfif>
				<cfif len(attributes.subscription_product_id) and len(attributes.subscription_product_name)>#attributes.subscription_product_id#<cfelse>NULL</cfif>,
				<cfif len(attributes.subscription_stock_id) and len(attributes.subscription_product_name)>#attributes.subscription_stock_id#<cfelse>NULL</cfif>,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(attributes.contract_no)#">,
				<cfif len(attributes.montage_emp_id)>#attributes.montage_emp_id#<cfelse>NULL</cfif>,
				<cfif len(attributes.payment_type_id)>#attributes.payment_type_id#<cfelse>NULL</cfif>,
				<cfif len(attributes.payment_type_creditcard_id)>#attributes.payment_type_creditcard_id#<cfelse>NULL</cfif>,
				<cfif len(attributes.montage_date)>#attributes.montage_date#<cfelse>NULL</cfif>,
				<cfif len(attributes.start_date)>#attributes.start_date#<cfelse>NULL</cfif>,
				<cfif len(attributes.finish_date)>#attributes.finish_date#<cfelse>NULL</cfif>,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(attributes.detail)#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#left(attributes.inv_detail,500)#">,
                <cfif isdefined("attributes.main_special_code") and len(attributes.main_special_code)>
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(attributes.main_special_code)#">
                <cfelse>
                    NULL    
                </cfif>,
                <cfif isDefined("attributes.ship_address") and Len(attributes.ship_address)><cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(attributes.ship_address)#"><cfelse>NULL</cfif>,
                <cfif isDefined("attributes.ship_postcode") and Len(attributes.ship_postcode)><cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(attributes.ship_postcode)#"><cfelse>NULL</cfif>,
                <cfif isDefined("attributes.ship_semt") and Len(attributes.ship_semt)><cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(attributes.ship_semt)#"><cfelse>NULL</cfif>,
				<cfif isdefined("attributes.ship_county_id") and len(attributes.ship_county_id)>#attributes.ship_county_id#<cfelse>NULL</cfif>,
				<cfif isdefined("attributes.ship_city_id") and len(attributes.ship_city_id)>#attributes.ship_city_id#<cfelse>NULL</cfif>,
				<cfif isdefined("attributes.ship_country_id") and len(attributes.ship_country_id)>#attributes.ship_country_id#<cfelse>NULL</cfif>,
				<cfif isdefined("attributes.ship_sales_zone_id") and len(attributes.ship_sales_zone_id)>#attributes.ship_sales_zone_id#<cfelse>NULL</cfif>,
				<cfif isdefined("attributes.invoice_address") and len(attributes.invoice_address)><cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(attributes.invoice_address)#"><cfelse>NULL</cfif>,
				<cfif isdefined("attributes.invoice_postcode") and len(attributes.invoice_postcode)><cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(attributes.invoice_postcode)#"><cfelse>NULL</cfif>,
				<cfif isdefined("attributes.invoice_semt") and len(attributes.invoice_semt)><cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(attributes.invoice_semt)#"><cfelse>NULL</cfif>,
				<cfif isdefined("attributes.invoice_county_id") and len(attributes.invoice_county_id)>#attributes.invoice_county_id#<cfelse>NULL</cfif>,
				<cfif isdefined("attributes.invoice_city_id") and len(attributes.invoice_city_id)>#attributes.invoice_city_id#<cfelse>NULL</cfif>,
				<cfif isdefined("attributes.invoice_country_id") and len(attributes.invoice_country_id)>#attributes.invoice_country_id#<cfelse>NULL</cfif>,				
				<cfif isdefined("attributes.invoice_sales_zone_id") and len(attributes.invoice_sales_zone_id)>#attributes.invoice_sales_zone_id#<cfelse>NULL</cfif>,
				<cfif session.ep.our_company_info.IS_EFATURA eq 1 >
					<cfif isdefined("attributes.ship_id") and len(attributes.ship_id)>#attributes.ship_id#<cfelse>NULL</cfif>,
				</cfif>
				<cfif isdefined("attributes.contact_address") and len(attributes.contact_address)><cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(attributes.contact_address)#"><cfelse>NULL</cfif>,		
				<cfif isdefined("attributes.contact_postcode") and len(attributes.contact_postcode)><cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(attributes.contact_postcode)#"><cfelse>NULL</cfif>,		
				<cfif isdefined("attributes.contact_semt") and len(attributes.contact_semt)><cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(attributes.contact_semt)#"><cfelse>NULL</cfif>,		
				<cfif isdefined("attributes.contact_county_id") and len(attributes.contact_county_id)>#attributes.contact_county_id#<cfelse>NULL</cfif>,
				<cfif isdefined("attributes.contact_city_id") and len(attributes.contact_city_id)>#attributes.contact_city_id#<cfelse>NULL</cfif>,
				<cfif isdefined("attributes.contact_country_id") and len(attributes.contact_country_id)>#attributes.contact_country_id#<cfelse>NULL</cfif>,
				<cfif isdefined("attributes.contact_sales_zone_id") and len(attributes.contact_sales_zone_id)>#attributes.contact_sales_zone_id#<cfelse>NULL</cfif>,
				<cfif isdefined("attributes.premium_value") and len(attributes.premium_value)>#attributes.premium_value#<cfelse>NULL</cfif>,
				<cfif isdefined("attributes.BASKET_DISCOUNT_TOTAL")>#attributes.BASKET_DISCOUNT_TOTAL#<cfelse>0</cfif>,
				<cfif isdefined("attributes.basket_net_total")>#attributes.basket_net_total#<cfelse>0</cfif>,
				<cfif isdefined("attributes.basket_gross_total")>#attributes.basket_gross_total#<cfelse>0</cfif>,
				<cfif isdefined("attributes.basket_tax_total")>#attributes.basket_tax_total#<cfelse>0</cfif>,
				<cfif isdefined("attributes.basket_otv_total") and len(attributes.basket_otv_total)>#attributes.basket_otv_total#<cfelse>0</cfif>,
				<cfif isdefined("attributes.basket_money") and len(attributes.basket_money)><cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.basket_money#"><cfelse><cfqueryparam cfsqltype="cf_sql_varchar" value="#session.ep.money#"></cfif>,
				<cfif isdefined("attributes.BASKET_NET_TOTAL") and len(attributes.BASKET_NET_TOTAL)>#((attributes.BASKET_NET_TOTAL*attributes.BASKET_RATE1)/attributes.BASKET_RATE2)#<cfelse>0</cfif>,				
				<cfif len(attributes.subs_add_option)>#attributes.subs_add_option#<cfelse>NULL</cfif>,
				<cfif len(attributes.sales_add_option)>#attributes.sales_add_option#<cfelse>NULL</cfif>,
				<cfif isdefined("attributes.project_id") and len(attributes.project_id) and isdefined("attributes.project_head") and len(attributes.project_head)>#attributes.project_id#<cfelse>NULL</cfif>,
				<cfif isdefined("form.genel_indirim") and len(form.genel_indirim)>#form.genel_indirim#<cfelse>0</cfif>,
				<cfif isdefined('attributes.asset_id') and len(attributes.asset_id)>#attributes.asset_id#<cfelse>NULL</cfif>,
                <cfif isdefined('attributes.valid_days') and len(attributes.valid_days)>#attributes.valid_days#<cfelse>NULL</cfif>,
                <cfif isdefined('attributes.start_clock_1') and len(attributes.start_clock_1)>#attributes.start_clock_1#<cfelse>NULL</cfif>,
                <cfif isdefined('attributes.start_minute_1') and len(attributes.start_minute_1)>#attributes.start_minute_1#<cfelse>NULL</cfif>,
				<cfif isdefined('attributes.finish_clock_1') and len(attributes.finish_clock_1)>#attributes.finish_clock_1#<cfelse>NULL</cfif>,
				<cfif isdefined('attributes.finish_minute_1') and len(attributes.finish_minute_1)>#attributes.finish_minute_1#<cfelse>NULL</cfif>,
                <cfif isdefined('attributes.start_clock_2') and len(attributes.start_clock_2)>#attributes.start_clock_2#<cfelse>NULL</cfif>,
                <cfif isdefined('attributes.start_minute_2') and len(attributes.start_minute_2)>#attributes.start_minute_2#<cfelse>NULL</cfif>,
				<cfif isdefined('attributes.finish_clock_2') and len(attributes.finish_clock_2)>#attributes.finish_clock_2#<cfelse>NULL</cfif>,
				<cfif isdefined('attributes.finish_minute_2') and len(attributes.finish_minute_2)>#attributes.finish_minute_2#<cfelse>NULL</cfif>,
                <cfif isdefined('attributes.start_clock_3') and len(attributes.start_clock_3)>#attributes.start_clock_3#<cfelse>NULL</cfif>,
                <cfif isdefined('attributes.start_minute_3') and len(attributes.start_minute_3)>#attributes.start_minute_3#<cfelse>NULL</cfif>,
				<cfif isdefined('attributes.finish_clock_3') and len(attributes.finish_clock_3)>#attributes.finish_clock_3#<cfelse>NULL</cfif>,
				<cfif isdefined('attributes.finish_minute_3') and len(attributes.finish_minute_3)>#attributes.finish_minute_3#<cfelse>NULL</cfif>,
                <cfif isdefined("attributes.general_date")>1<cfelse>0</cfif>,
                <cfif isdefined('attributes.hour1') and len(attributes.hour1)>#attributes.hour1#<cfelse>NULL</cfif>,
                <cfif isdefined('attributes.minute1') and len(attributes.minute1)>#attributes.minute1#<cfelse>NULL</cfif>,
				<cfif isdefined('attributes.response_hour1') and len(attributes.response_hour1)>#attributes.response_hour1#<cfelse>NULL</cfif>,
                <cfif isdefined('attributes.response_minute1') and len(attributes.response_minute1)>#attributes.response_minute1#<cfelse>NULL</cfif>,
                <cfif isdefined('attributes.camp_name') and len(attributes.camp_name) and isdefined('attributes.camp_id') and Len(attributes.camp_id)>#attributes.camp_id#<cfelse>NULL</cfif>,
				#session.ep.userid#,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.remote_addr#">,
				#now()#,
                <cfif isdefined('attributes.ship_coordinate_1') and len(attributes.ship_coordinate_1)>#attributes.ship_coordinate_1#<cfelse>NULL</cfif>,
                <cfif isdefined('attributes.ship_coordinate_2') and len(attributes.ship_coordinate_2)>#attributes.ship_coordinate_2#<cfelse>NULL</cfif>,
                <cfif isdefined('attributes.invoice_coordinate_1') and len(attributes.invoice_coordinate_1)>#attributes.invoice_coordinate_1#<cfelse>NULL</cfif>,
                <cfif isdefined('attributes.invoice_coordinate_2') and len(attributes.invoice_coordinate_2)>#attributes.invoice_coordinate_2#<cfelse>NULL</cfif>,
                <cfif isdefined('attributes.contact_coordinate_1') and len(attributes.contact_coordinate_1)>#attributes.contact_coordinate_1#<cfelse>NULL</cfif>,
                <cfif isdefined('attributes.contact_coordinate_2') and len(attributes.contact_coordinate_2)>#attributes.contact_coordinate_2#<cfelse>NULL</cfif>,
                <cfif isdefined('attributes.ref_state') and len(attributes.ref_state)>#attributes.ref_state#<cfelse>NULL</cfif>,
                <cfif isdefined('attributes.comp_branch') and len(attributes.comp_branch)>#attributes.comp_branch#<cfelse>NULL</cfif>,
				<cfif isdefined('attributes.product_key') and len(attributes.product_key)><cfqueryparam value="#attributes.product_key#" cfsqltype="cf_sql_nvarchar"><cfelse>NULL</cfif>,
				<cfif isdefined('attributes.our_company_id') and len(attributes.our_company_id)><cfqueryparam value="#attributes.our_company_id#" cfsqltype="cf_sql_integer"><cfelse>NULL</cfif>
			)
        </cfquery>
		<cfquery name="GET_MAX_SUBSCRIPTION" datasource="#DSN3#">
			SELECT MAX(SUBSCRIPTION_ID) AS SUBSCRIPTION_ID FROM	SUBSCRIPTION_CONTRACT WHERE WRK_ID = '#wrk_id#'
		</cfquery>
		<!--- Satirlarin kaydi --->
		<cfif isdefined("attributes.rows_") and len(attributes.rows_)>
			<cfloop from="1" to="#attributes.rows_#" index="i">
				<cf_date tarih="attributes.deliver_date#i#">
				<cfinclude template="get_dis_amount.cfm">
				<cfif isdefined("attributes.product_id#i#") and len(evaluate("attributes.product_id#i#"))>
					<cfquery name="ADD_CONTRACT_ROW" datasource="#DSN3#">
						INSERT INTO
							SUBSCRIPTION_CONTRACT_ROW
						(
							SUBSCRIPTION_ID,
							PRODUCT_NAME,
							PRODUCT_NAME2,
							STOCK_ID,
							PRODUCT_ID,
							AMOUNT,
							UNIT,
							UNIT_ID,					
							TAX,
							<cfif len(evaluate("attributes.price#i#"))>PRICE,</cfif>
							DISCOUNT1,					
							DISCOUNT2,
							DISCOUNT3,
							DISCOUNT4,
							DISCOUNT5,
							DISCOUNT6,
							DISCOUNT7,
							DISCOUNT8,
							DISCOUNT9,
							DISCOUNT10,
							DISCOUNTTOTAL,
							GROSSTOTAL,
							NETTOTAL,
							TAXTOTAL,
						<cfif isdefined('attributes.spect_id#i#') and len(evaluate('attributes.spect_id#i#'))>					
							SPECT_VAR_ID,
							SPECT_VAR_NAME,
						</cfif>
							PAYMETHOD_ID,
							LOT_NO,
							OTHER_MONEY,
							OTHER_MONEY_VALUE,					
							PRICE_OTHER,
							OTHER_MONEY_GROSS_TOTAL,
							DISCOUNT_COST,
							BASKET_EXTRA_INFO_ID,
							SELECT_INFO_EXTRA,
							DETAIL_INFO_EXTRA,
							DELIVER_DATE,
							OTV_ORAN,
							OTVTOTAL,
							EXTRA_COST,
							LIST_PRICE,
							BASKET_EMPLOYEE_ID
							<cfif isdefined('attributes.row_bsmv_rate#i#') and len(evaluate("attributes.row_bsmv_rate#i#"))>,BSMV_RATE</cfif>
							<cfif isdefined('attributes.row_bsmv_amount#i#') and len(evaluate("attributes.row_bsmv_amount#i#"))>,BSMV_AMOUNT</cfif>
							<cfif isdefined('attributes.row_bsmv_currency#i#') and len(evaluate("attributes.row_bsmv_currency#i#"))>,BSMV_CURRENCY</cfif>
							<cfif isdefined('attributes.row_oiv_rate#i#') and len(evaluate("attributes.row_oiv_rate#i#"))>,OIV_RATE</cfif>
							<cfif isdefined('attributes.row_oiv_amount#i#') and len(evaluate("attributes.row_oiv_amount#i#"))>,OIV_AMOUNT</cfif>
							<cfif isdefined('attributes.row_tevkifat_rate#i#') and len(evaluate("attributes.row_tevkifat_rate#i#"))>,TEVKIFAT_RATE</cfif>
							<cfif isdefined('attributes.row_tevkifat_amount#i#') and len(evaluate("attributes.row_tevkifat_amount#i#"))>,TEVKIFAT_AMOUNT</cfif>
						)
						VALUES
						(
							#get_max_subscription.subscription_id#,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#left(evaluate('attributes.product_name#i#'),500)#">,					
							<cfif isdefined('attributes.product_name_other#i#') and len(evaluate('attributes.product_name_other#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#wrk_eval('attributes.product_name_other#i#')#"><cfelse>NULL</cfif>,			
							#evaluate("attributes.stock_id#i#")#,
							#evaluate("attributes.product_id#i#")#,
							#evaluate("attributes.amount#i#")#,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#wrk_eval('attributes.unit#i#')#">,
							#evaluate("attributes.unit_id#i#")#,
							#evaluate("attributes.tax#i#")#,
							<cfif len(evaluate("attributes.price#i#"))>#evaluate("attributes.price#i#")#,</cfif>
							#indirim1#,					
							#indirim2#,
							#indirim3#,
							#indirim4#,
							#indirim5#,
							#indirim6#,
							#indirim7#,
							#indirim8#,
							#indirim9#,
							#indirim10#,
							#DISCOUNT_AMOUNT#,
							#evaluate("attributes.row_lasttotal#i#")#,
							#evaluate("attributes.row_nettotal#i#")#,
							#evaluate("attributes.row_taxtotal#i#")#,
						<cfif isdefined('attributes.spect_id#i#') and len(evaluate('attributes.spect_id#i#'))><!--- Burasi olacak mi ??? --->
							#evaluate('attributes.spect_id#i#')#,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#wrk_eval('attributes.spect_name#i#')#">,
						</cfif>
							<cfif isdefined("attributes.paymethod_id#i#") and len(evaluate("attributes.paymethod_id#i#"))>#evaluate("attributes.paymethod_id#i#")#,<cfelse>NULL,</cfif>
							<cfif isdefined('attributes.lot_no#i#') and len(evaluate('attributes.lot_no#i#'))>#evaluate('attributes.lot_no#i#')#<cfelse>NULL</cfif>,<!--- Burasi olacak mi ??? --->
							<cfif isdefined('attributes.other_money_#i#')><cfqueryparam cfsqltype="cf_sql_varchar" value="#wrk_eval('attributes.other_money_#i#')#"><cfelse>NULL</cfif>,
							<cfif isdefined("attributes.other_money_value_#i#") and len(evaluate("attributes.other_money_value_#i#"))>#evaluate("attributes.other_money_value_#i#")#<cfelse>NULL</cfif>,					
							<cfif isdefined('attributes.price_other#i#') and len(evaluate('attributes.price_other#i#'))>#evaluate("attributes.price_other#i#")#<cfelse>NULL</cfif>,
							<cfif isdefined("attributes.other_money_gross_total#i#") and len(evaluate("attributes.other_money_gross_total#i#"))>#evaluate("attributes.other_money_gross_total#i#")#<cfelse>0</cfif>,
							<cfif isdefined('attributes.iskonto_tutar#i#') and len(evaluate('attributes.iskonto_tutar#i#'))>#evaluate('attributes.iskonto_tutar#i#')#<cfelse>NULL</cfif>,
							<cfif isdefined('attributes.basket_extra_info#i#') and len(evaluate('attributes.basket_extra_info#i#'))>#evaluate('attributes.basket_extra_info#i#')#<cfelse>NULL</cfif>,
							<cfif isdefined('attributes.select_info_extra#i#') and len(evaluate('attributes.select_info_extra#i#'))>#evaluate('attributes.select_info_extra#i#')#<cfelse>NULL</cfif>,
							<cfif isdefined('attributes.detail_info_extra#i#') and len(evaluate('attributes.detail_info_extra#i#'))>'#evaluate('attributes.detail_info_extra#i#')#'<cfelse>NULL</cfif>,
							<cfif isdefined("attributes.deliver_date#i#") and isdate(evaluate('attributes.deliver_date#i#'))>#evaluate('attributes.deliver_date#i#')#<cfelse>NULL</cfif>,
							<cfif isdefined('attributes.otv_oran#i#') and len(evaluate('attributes.otv_oran#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#wrk_eval('attributes.otv_oran#i#')#"><cfelse>NULL</cfif>,
							<cfif isdefined('attributes.row_otvtotal#i#') and len(evaluate('attributes.row_otvtotal#i#'))>#evaluate('attributes.row_otvtotal#i#')#<cfelse>NULL</cfif>,
							<cfif isdefined('attributes.extra_cost#i#') and len(evaluate('attributes.extra_cost#i#'))>#evaluate('attributes.extra_cost#i#')#<cfelse>0</cfif>,
							<cfif isdefined('attributes.list_price#i#') and len(evaluate('attributes.list_price#i#'))>#evaluate('attributes.list_price#i#')#<cfelse>NULL</cfif>,
							<cfif isdefined('attributes.basket_employee_id#i#') and len(evaluate('attributes.basket_employee_id#i#')) and isdefined('attributes.basket_employee#i#') and len(evaluate('attributes.basket_employee#i#'))>#evaluate('attributes.basket_employee_id#i#')#<cfelse>NULL</cfif>
							<cfif isdefined('attributes.row_bsmv_rate#i#') and len(evaluate("attributes.row_bsmv_rate#i#"))>,<cfqueryparam cfsqltype="cf_sql_float" value="#evaluate('attributes.row_bsmv_rate#i#')#"></cfif>
							<cfif isdefined('attributes.row_bsmv_amount#i#') and len(evaluate("attributes.row_bsmv_amount#i#"))>,<cfqueryparam cfsqltype="cf_sql_float" value="#evaluate('attributes.row_bsmv_amount#i#')#"></cfif>
							<cfif isdefined('attributes.row_bsmv_currency#i#') and len(evaluate("attributes.row_bsmv_currency#i#"))>,<cfqueryparam cfsqltype="cf_sql_float" value="#evaluate('attributes.row_bsmv_currency#i#')#"></cfif>
							<cfif isdefined('attributes.row_oiv_rate#i#') and len(evaluate("attributes.row_oiv_rate#i#"))>,<cfqueryparam cfsqltype="cf_sql_float" value="#evaluate('attributes.row_oiv_rate#i#')#"></cfif>
							<cfif isdefined('attributes.row_oiv_amount#i#') and len(evaluate("attributes.row_oiv_amount#i#"))>,<cfqueryparam cfsqltype="cf_sql_float" value="#evaluate('attributes.row_oiv_amount#i#')#"></cfif>
							<cfif isdefined('attributes.row_tevkifat_rate#i#') and len(evaluate("attributes.row_tevkifat_rate#i#"))>,<cfqueryparam cfsqltype="cf_sql_float" value="#evaluate('attributes.row_tevkifat_rate#i#')#"></cfif>
							<cfif isdefined('attributes.row_tevkifat_amount#i#') and len(evaluate("attributes.row_tevkifat_amount#i#"))>,<cfqueryparam cfsqltype="cf_sql_float" value="#evaluate('attributes.row_tevkifat_amount#i#')#"></cfif>
						)
					</cfquery>
				</cfif>
			</cfloop>
		
			<cfscript>
				basket_kur_ekle(action_id:get_max_subscription.subscription_id,table_type_id:13,process_type:0);
			</cfscript>
		</cfif>
	</cftransaction>
</cflock>
<cf_workcube_process 
	is_upd='1'
	data_source='#dsn3#'
	old_process_line='0'
	process_stage='#attributes.process_stage#' 
	record_member='#session.ep.userid#' 
	record_date='#now()#'
	action_table='SUBSCRIPTION_CONTRACT'
	action_column='SUBSCRIPTION_ID'
	action_id='#get_max_subscription.subscription_id#'
	action_page='#request.self#?fuseaction=sales.list_subscription_contract&event=upd&subscription_id=#get_max_subscription.subscription_id#'
	warning_description = '#getLang("","Abonelik",29754)# : #attributes.subscription_head#'>
<script type="text/javascript">
	window.location.href="<cfoutput>#request.self#?fuseaction=sales.list_subscription_contract&event=upd&subscription_id=#get_max_subscription.subscription_id#</cfoutput>";
</script>
