<!--- 
Pronete özel yapılmış bir sayfadır..
Sistem ürün planındaki belli toplamlara göre istenilen koşullarda ödeme planı satırları oluşturulur(ve gene pronetin kendi ürün vs id leri ile..)
Aysenur20070918
 --->
<cfquery name="GET_PAYPLAN_CONTROL" datasource="#dsn3#">
	SELECT 
        SUBSCRIPTION_ID, 
        PRODUCT_ID, 
        STOCK_ID, 
        UNIT, 
        QUANTITY, 
        AMOUNT, 
        MONEY_TYPE, 
        PERIOT, 
        START_DATE, 
        UNIT_ID, 
        PAYMETHOD_ID, 
        CARD_PAYMETHOD_ID, 
        PROCESS_STAGE, 
        RECORD_EMP, 
        RECORD_IP, 
        RECORD_DATE, 
        UPDATE_EMP, 
        UPDATE_IP, 
        UPDATE_DATE 
    FROM 
	    SUBSCRIPTION_PAYMENT_PLAN 
    WHERE 
    	SUBSCRIPTION_ID = #attributes.subscription_id#
</cfquery>
<cfset camp_prod_id_list = ''>
<cfset camp_prod_list = ''>
<cfset paym_date = attributes.start_date>
<cf_date tarih='attributes.start_date'>
<!--- Kampanya kuralları çalışsın seçiliyse ve kampanya seçilmişse ilgili kampanyanın operasyon satırlarına göre 
ödeme planı satırı oluşturulacak SM20101202 --->
<cfif isdefined("attributes.is_camp_rules") and len(attributes.camp_id)>
	<cfquery name="get_camp_rows" datasource="#dsn3#">
		SELECT 
	        CAMP_ID, 
            CAMP_OPE_ID, 
            PRODUCT_ID, 
            PRODUCT_NAME, 
            AMOUNT, 
            UNIT_ID, 
            UNIT, 
            PRICE, 
            DISCOUNT, 
            K_DISCOUNT, 
            CURRENCY, 
            PERIOD, 
            REPEAT_NUMBER, 
            FREE_REPEAT_NUMBER, 
            PAYMETHOD_ID, 
            CARD_PAYMETHOD_ID, 
            RECORD_DATE, 
            RECORD_MEMBER, 
            RECORD_IP, 
            UPDATE_IP, 
            UPDATE_DATE, 
            UPDATE_MEMBER 
        FROM 
    	    CAMPAIGN_OPERATION 
        WHERE 
	        CAMP_ID = #attributes.camp_id# 
        ORDER BY 
        	CAMP_OPE_ID
	</cfquery>
	<cfoutput query="get_camp_rows">
		<cfif not len(period)>
			<cfset period_info = attributes.period>
		<cfelse>
			<cfif period eq 1>
				<cfset period_info = 120>
			<cfelseif period eq 2>
				<cfset period_info = 60>
			<cfelseif period eq 3>
				<cfset period_info = 40>
			<cfelseif period eq 6>
				<cfset period_info = 20>
			<cfelseif period eq 12>
				<cfset period_info = 10>
			</cfif>
		</cfif>
		<cfif not len(repeat_number)><cfset repeat_number_ = 0><cfelse><cfset repeat_number_ = repeat_number></cfif>
		<cfif not len(free_repeat_number)><cfset free_repeat_number_ = 0><cfelse><cfset free_repeat_number_ = free_repeat_number></cfif>
		<cfif not len(discount)><cfset discount_ = 0><cfelse><cfset discount_ = discount></cfif>
		<cfif not len(k_discount)><cfset k_discount_ = 0><cfelse><cfset k_discount_ = k_discount></cfif>
		<cfif not len(paymethod_id)><cfset paymethod_id_info = 0><cfelse><cfset paymethod_id_info = paymethod_id></cfif>
		<cfif not len(card_paymethod_id)><cfset card_paymethod_id_info = 0><cfelse><cfset card_paymethod_id_info = card_paymethod_id></cfif>
		<cfset camp_prod_id_list = listappend(camp_prod_id_list,product_id,',')>
		<cfset camp_prod_list = listappend(camp_prod_list,"#product_id#;#price#;#discount_#;#k_discount_#;#currency#;#period_info#;#repeat_number_#;#free_repeat_number_#;#paymethod_id_info#;#card_paymethod_id_info#;0;#amount#",',')>
	</cfoutput>
</cfif>
<cfif not GET_PAYPLAN_CONTROL.recordcount><!--- hiç ödeme planı yoksa,ekleyecek --->
	<cfquery name="GET_PROD" datasource="#dsn3#">
		SELECT PRODUCT_NAME FROM PRODUCT WHERE PRODUCT_ID = 855
	</cfquery>
	<cfif GET_PROD.recordcount>
		<cfquery name="GET_PROD_UNIT" datasource="#dsn3#">
			SELECT 
        	    PRODUCT_UNIT_ID, 
                PRODUCT_UNIT_STATUS, 
                PRODUCT_ID, 
                MAIN_UNIT_ID, 
                MAIN_UNIT, 
                IS_MAIN, 
                RECORD_DATE, 
                RECORD_EMP, 
                UPDATE_DATE, 
                UPDATE_EMP 
            FROM 
    	        PRODUCT_UNIT 
            WHERE 
	            PRODUCT_ID = 855 AND IS_MAIN=1 AND PRODUCT_UNIT_STATUS=1
		</cfquery>
		<cfquery name="ADD_PAYMENT_PLAN" datasource="#dsn3#">
			INSERT INTO
				SUBSCRIPTION_PAYMENT_PLAN
				(
					SUBSCRIPTION_ID,
					PRODUCT_ID,
					STOCK_ID,
					UNIT,
					UNIT_ID,
					QUANTITY,
					AMOUNT,
					MONEY_TYPE,
					PERIOT,
					START_DATE,
					PAYMETHOD_ID,
					CARD_PAYMETHOD_ID,
					PROCESS_STAGE,
					RECORD_DATE,
					RECORD_IP,
					RECORD_EMP
				)
				VALUES
				(
					#attributes.subscription_id#,
					855,
					855,
					'#GET_PROD_UNIT.MAIN_UNIT#',
					#GET_PROD_UNIT.MAIN_UNIT_ID#,
					1,
					#wrk_round(attributes.montaj_total,1)#,
					<cfif len(attributes.money_type)>'#attributes.money_type#',<cfelse>'#session.ep.money2#',</cfif>
					1,
					#attributes.start_date#,
					<cfif listfirst(attributes.pay_method,';') eq 1>#listlast(attributes.pay_method,';')#,<cfelse>NULL,</cfif>
					<cfif listfirst(attributes.pay_method,';') eq 2>#listlast(attributes.pay_method,';')#,<cfelse>NULL,</cfif>
					58,
					#now()#,
					'#cgi.remote_addr#',
					#session.ep.userid#
				)
		</cfquery>
	</cfif>
</cfif>
<!--- ödeme planı history kayıtları --->
<cfquery name="GET_PAYM_PLAN" datasource="#dsn3#">
	SELECT
		SUM(ROW_NET_TOTAL) FIRST_TOTAL,
		SUBSCRIPTION_ID,
		YEAR(PAYMENT_DATE) PAY_YEAR,
		MONEY_TYPE
	FROM
		SUBSCRIPTION_PAYMENT_PLAN_ROW
	WHERE
		SUBSCRIPTION_ID = #attributes.subscription_id#
	GROUP BY
		SUBSCRIPTION_ID,
		YEAR(PAYMENT_DATE),
		MONEY_TYPE
	ORDER BY
		YEAR(PAYMENT_DATE)
</cfquery>
<cfset history_record = GET_PAYM_PLAN.recordcount>
<cfquery name="INSERT_PAYM_PLAN_HISTORY" datasource="#dsn3#">
	INSERT INTO
		SUBSCRIPTION_PAYMENT_PLAN_ROW_HISTORY
	(
		SUBSCRIPTION_ID,
		PAYM_PLAN_YEAR,
		PAYM_PLAN_TOTAL_OLD,
		PAYM_PLAN_MONEY_TYPE,
		CAMPAIGN_ID,
		RECORD_EMP,
		RECORD_IP,
		RECORD_DATE
	)
		SELECT
			SUBSCRIPTION_ID,
			YEAR(PAYMENT_DATE),
			SUM(ROW_NET_TOTAL),
			MONEY_TYPE,
			CAMPAIGN_ID,
			#session.ep.userid#,
			'#cgi.remote_addr#',
			#now()#
		FROM
			SUBSCRIPTION_PAYMENT_PLAN_ROW
		WHERE
			SUBSCRIPTION_ID = #attributes.subscription_id#
		GROUP BY
			SUBSCRIPTION_ID,
			YEAR(PAYMENT_DATE),
			MONEY_TYPE,
			CAMPAIGN_ID
		ORDER BY
			YEAR(PAYMENT_DATE)
</cfquery>
<!--- //ödeme planı history kayıtları --->
<!--- abonelik bedelleri siliniyor --->
<cfquery name="DEL_PAY_PLAN_ROW" datasource="#dsn3#">
	DELETE FROM
		SUBSCRIPTION_PAYMENT_PLAN_ROW
	WHERE
		IS_PAID = 0 AND
		IS_COLLECTED_PROVISION = 0 AND
		IS_BILLED = 0 AND
		PRODUCT_ID IN (787,914,2739,2855) AND
		STOCK_ID IN (787,914,2704,2820) AND
		SUBSCRIPTION_ID = #attributes.subscription_id#
</cfquery>
<cfif len(camp_prod_id_list)>
	<cfquery name="DEL_PAY_PLAN_ROW" datasource="#dsn3#">
		DELETE FROM
			SUBSCRIPTION_PAYMENT_PLAN_ROW
		WHERE
			IS_PAID = 0 AND
			IS_COLLECTED_PROVISION = 0 AND
			IS_BILLED = 0 AND
			PRODUCT_ID IN(#camp_prod_id_list#) AND
			SUBSCRIPTION_ID = #attributes.subscription_id#
	</cfquery>
</cfif>
<cfset tarih_farki = 0>
<cfquery name="GET_SUBS_CONT" datasource="#dsn3#">
	SELECT MONTAGE_DATE FROM SUBSCRIPTION_CONTRACT WHERE SUBSCRIPTION_ID = #attributes.subscription_id#
</cfquery>
<cfif len(GET_SUBS_CONT.MONTAGE_DATE)>
	<cfset tarih_farki = DateDiff("d",GET_SUBS_CONT.MONTAGE_DATE,attributes.start_date)>
</cfif>
<cfif attributes.subscription_type eq 4>
	<cfif paym_date eq attributes.montage_date>
		<cfset prod_id_list = "855"><!--- Alarm Sistemi Montaj Bedeli--->
	<cfelse>
		<cfset prod_id_list = "855,824"><!--- Alarm Sistemi Montaj Bedeli  -  İlk Ay Alarm Abonelik Hizmet Bedeli--->
	</cfif>
<cfelse>
	<cfset prod_id_list = "855,932"><!--- Alarm Sistemi Montaj Bedeli  -  Kablolu veya Kablosuz Alarm Sistemi Satış Bedeli --->
</cfif>
<cfif attributes.kablolama_total gt 0>
	<cfset prod_id_list = ListAppend(prod_id_list,2855,',')><!--- Kablolama Ürünü --->
</cfif>
<cfloop list="#prod_id_list#" index="i">
	<cfquery name="GET_PROD" datasource="#dsn3#">
		SELECT PRODUCT_NAME,STOCK_ID FROM STOCKS WHERE PRODUCT_ID = #i#
	</cfquery>
	<cfquery name="GET_SUBS_INFO" datasource="#dsn3#">
		SELECT AMOUNT FROM SUBSCRIPTION_PAYMENT_PLAN_ROW WHERE SUBSCRIPTION_ID = #attributes.subscription_id# AND PRODUCT_ID = #i# AND STOCK_ID = #GET_PROD.STOCK_ID#
	</cfquery>
	<cfif not GET_SUBS_INFO.recordcount>
		<cfquery name="GET_PROD_UNIT" datasource="#dsn3#">
			SELECT 
        	    PRODUCT_UNIT_ID, 
                PRODUCT_UNIT_STATUS, 
                PRODUCT_ID, 
                MAIN_UNIT_ID, 
                MAIN_UNIT, 
                IS_MAIN, 
                RECORD_DATE, 
                RECORD_EMP, 
                UPDATE_DATE, 
                UPDATE_EMP 
            FROM 
	            PRODUCT_UNIT 
            WHERE 
            	PRODUCT_ID = #i# AND IS_MAIN=1 AND PRODUCT_UNIT_STATUS=1
		</cfquery>
		<cfif i eq 855>
			<cfset paym_total = attributes.montaj_total>
		<cfelseif i eq 2855>
			<cfset paym_total = attributes.kablolama_total>
		<cfelseif i eq 824>
			<cfif tarih_farki gt 0>
				<cfset paym_total = (tarih_farki/30)*(attributes.ahm_total+attributes.urun_total)>
			<cfelse>
				<cfset paym_total = attributes.ahm_total+attributes.urun_total>
			</cfif>
		<cfelse>
			<cfset paym_total = attributes.urun_total>
		</cfif>
		<cfif len(camp_prod_id_list) and listfind(camp_prod_id_list,i)>
			<cfset row_info = listfind(camp_prod_id_list,i)>
			<cfset prod_info = listgetat(camp_prod_list,row_info,',')>
			<cfset price_info = listgetat(prod_info,2,';')>
			<cfset discount_info = listgetat(prod_info,3,';')>
			<cfset k_discount_info = listgetat(prod_info,4,';')>
			<cfset currency_info = listgetat(prod_info,5,';')>
			<cfset period_info = listgetat(prod_info,6,';')>
			<cfset repeat_number_info = listgetat(prod_info,7,';')>
			<cfset free_repeat_number_info = listgetat(prod_info,8,';')>
			<cfset paymethod_id_info = listgetat(prod_info,9,';')>
			<cfset card_paymethod_id_info = listgetat(prod_info,10,';')>
			<cfset usage_count_info = listgetat(prod_info,11,';')>
			<cfif usage_count_info lt free_repeat_number_info>
				<cfif k_discount_info gt 0>
					<cfif i eq 855>
						<cfset paym_total = attributes.montaj_total_gross>
					<cfelseif i eq 2855>
						<cfset paym_total = attributes.kablolama_total_gross>
					<cfelseif i eq 824>
						<cfif tarih_farki gt 0>
							<cfset paym_total = (tarih_farki/30)*(attributes.ahm_total_gross+attributes.urun_total_gross)>
						<cfelse>
							<cfset paym_total = attributes.ahm_total_gross+attributes.urun_total_gross>
						</cfif>
					<cfelse>
						<cfset paym_total = attributes.urun_total_gross>
					</cfif>					
				</cfif>
				<cfif price_info gt 0>
					<cfset paym_total = price_info>
				</cfif>
				<cfset use_discount = k_discount_info>
				<cfset usage_count_info = usage_count_info + 1>
				<cfset new_prod_info = listsetat(prod_info,11,usage_count_info,';')>
				<cfset camp_prod_list = listsetat(camp_prod_list,row_info,new_prod_info,',')>
				<cfset use_camp_id = attributes.camp_id>
				<cfset amount_info = listgetat(prod_info,12,';')>
			<cfelseif usage_count_info lt repeat_number_info>
				<cfif discount_info gt 0>
					<cfif i eq 855>
						<cfset paym_total = attributes.montaj_total_gross>
					<cfelseif i eq 2855>
						<cfset paym_total = attributes.kablolama_total_gross>
					<cfelseif i eq 824>
						<cfif tarih_farki gt 0>
							<cfset paym_total = (tarih_farki/30)*(attributes.ahm_total_gross+attributes.urun_total_gross)>
						<cfelse>
							<cfset paym_total = attributes.ahm_total_gross+attributes.urun_total_gross>
						</cfif>
					<cfelse>
						<cfset paym_total = attributes.urun_total_gross>
					</cfif>					
				</cfif>
				<cfif price_info gt 0>
					<cfset paym_total = price_info>
				</cfif>
				<cfset use_discount = discount_info>
				<cfset usage_count_info = usage_count_info + 1>
				<cfset new_prod_info = listsetat(prod_info,11,usage_count_info,';')>
				<cfset camp_prod_list = listsetat(camp_prod_list,row_info,new_prod_info,',')>
				<cfset use_camp_id = attributes.camp_id>
				<cfset amount_info = listgetat(prod_info,12,';')>
			<cfelse>
				<cfset use_camp_id = ''>
				<cfset use_discount = 0>
				<cfset amount_info = 1>
			</cfif>
		<cfelse>
			<cfset use_discount = 0>
			<cfset amount_info = 1>
			<cfset use_camp_id = ''>
		</cfif>
		<cflock name="#createUUID()#" timeout="60">			
			<cftransaction>
				<cfquery name="ADD_PAYMENT_PLAN_ROW" datasource="#dsn3#">
					INSERT INTO
						SUBSCRIPTION_PAYMENT_PLAN_ROW
						(
							SUBSCRIPTION_ID,
							PRODUCT_ID,
							STOCK_ID,
							PAYMENT_DATE,
							DETAIL,
							UNIT,
							UNIT_ID,
							QUANTITY,
							AMOUNT,
							MONEY_TYPE,
							ROW_TOTAL,
							DISCOUNT,
							ROW_NET_TOTAL,
							IS_COLLECTED_INVOICE,
							IS_GROUP_INVOICE,
							IS_BILLED,
							IS_COLLECTED_PROVISION,
							IS_PAID,
							IS_ACTIVE,
							INVOICE_ID,
							PERIOD_ID,
							PAYMETHOD_ID,
							CARD_PAYMETHOD_ID,
							SUBS_REFERENCE_ID,
							CAMPAIGN_ID,
							RECORD_DATE,
							RECORD_IP,
							RECORD_EMP
						)
					VALUES
						(
							#attributes.subscription_id#,
							#i#,
							#GET_PROD.STOCK_ID#,
							<cfif ListFind("855,932",i) and len(GET_SUBS_CONT.MONTAGE_DATE)>#CreateODBCDateTime(GET_SUBS_CONT.MONTAGE_DATE)#<cfelse>#attributes.start_date#</cfif>,
							'#left(GET_PROD.PRODUCT_NAME,50)#',
							'#GET_PROD_UNIT.MAIN_UNIT#',
							#GET_PROD_UNIT.MAIN_UNIT_ID#,
							#amount_info#,
							#wrk_round(paym_total,1)#,
							<cfif len(attributes.money_type)>'#attributes.money_type#',<cfelse>'#session.ep.money2#',</cfif>
							#wrk_round(paym_total,1)#,
							#use_discount#,
							#wrk_round((paym_total-(paym_total*use_discount/100)),1)#,
							<cfif attributes.bill_type eq 1>1,<cfelse>0,</cfif>
							<cfif attributes.bill_type eq 2>1,<cfelse>0,</cfif>
							0,
							0,
							0,
							1,
							NULL,
							NULL,
							<cfif listfirst(attributes.pay_method,';') eq 1>#listlast(attributes.pay_method,';')#,<cfelse>NULL,</cfif>
							<cfif listfirst(attributes.pay_method,';') eq 2>#listlast(attributes.pay_method,';')#,<cfelse>NULL,</cfif>
							NULL,
							<cfif isdefined("use_camp_id") and len(use_camp_id)>#use_camp_id#<cfelse>NULL</cfif>,
							#now()#,
							'#cgi.remote_addr#',
							#session.ep.userid#
						)
				</cfquery>
			</cftransaction>
		</cflock>
	</cfif>
</cfloop>
<!--- Damga vergisi ürünü  2739--->
<cfquery name="GET_SUBS_INFO" datasource="#dsn3#">
	SELECT AMOUNT FROM SUBSCRIPTION_PAYMENT_PLAN_ROW WHERE SUBSCRIPTION_ID = #attributes.subscription_id# AND PRODUCT_ID = 2739 AND STOCK_ID = 2704
</cfquery>
<cfif not GET_SUBS_INFO.recordcount and attributes.damga_total gt 0>
	<cfquery name="GET_PROD" datasource="#dsn3#">
		SELECT PRODUCT_NAME FROM PRODUCT WHERE PRODUCT_ID = 2739
	</cfquery>
	<cfif GET_PROD.recordcount>
		<cfquery name="GET_PROD_UNIT" datasource="#dsn3#">
			SELECT 
        	    PRODUCT_UNIT_ID, 
                PRODUCT_UNIT_STATUS, 
                PRODUCT_ID, 
                MAIN_UNIT_ID, 
                MAIN_UNIT, 
                IS_MAIN, 
                RECORD_DATE, 
                RECORD_EMP, 
                UPDATE_DATE, 
                UPDATE_EMP 
            FROM 
	            PRODUCT_UNIT 
            WHERE 
            	PRODUCT_ID = 2739 AND IS_MAIN=1 AND PRODUCT_UNIT_STATUS=1
		</cfquery>
		<cfif len(camp_prod_id_list) and listfind(camp_prod_id_list,2739)>
			<cfset row_info = listfind(camp_prod_id_list,2739)>
			<cfset prod_info = listgetat(camp_prod_list,row_info,',')>
			<cfset price_info = listgetat(prod_info,2,';')>
			<cfset discount_info = listgetat(prod_info,3,';')>
			<cfset k_discount_info = listgetat(prod_info,4,';')>
			<cfset currency_info = listgetat(prod_info,5,';')>
			<cfset period_info = listgetat(prod_info,6,';')>
			<cfset repeat_number_info = listgetat(prod_info,7,';')>
			<cfset free_repeat_number_info = listgetat(prod_info,8,';')>
			<cfset paymethod_id_info = listgetat(prod_info,9,';')>
			<cfset card_paymethod_id_info = listgetat(prod_info,10,';')>
			<cfset usage_count_info = listgetat(prod_info,11,';')>
			<cfif usage_count_info lt free_repeat_number_info>
				<cfif k_discount_info gt 0>
					<cfset attributes.damga_total = attributes.damga_total_gross>
				</cfif>
				<cfif price_info gt 0>
					<cfset attributes.damga_total = price_info>
				</cfif>
				<cfset use_discount = k_discount_info>
				<cfset usage_count_info = usage_count_info + 1>
				<cfset new_prod_info = listsetat(prod_info,11,usage_count_info,';')>
				<cfset camp_prod_list = listsetat(camp_prod_list,row_info,new_prod_info,',')>
				<cfset use_camp_id = attributes.camp_id>
				<cfset amount_info = listgetat(prod_info,12,';')>
			<cfelseif usage_count_info lt repeat_number_info>
				<cfif discount_info gt 0>
					<cfset attributes.damga_total = attributes.damga_total_gross>
				</cfif>
				<cfif price_info gt 0>
					<cfset attributes.damga_total = price_info>
				</cfif>
				<cfset use_discount = discount_info>
				<cfset usage_count_info = usage_count_info + 1>
				<cfset new_prod_info = listsetat(prod_info,11,usage_count_info,';')>
				<cfset camp_prod_list = listsetat(camp_prod_list,row_info,new_prod_info,',')>
				<cfset use_camp_id = attributes.camp_id>
				<cfset amount_info = listgetat(prod_info,12,';')>
			<cfelse>
				<cfset use_camp_id = ''>
				<cfset use_discount = 0>
				<cfset amount_info = 1>
			</cfif>
		<cfelse>
			<cfset use_camp_id = ''>
			<cfset use_discount = 0>
			<cfset amount_info = 1>
		</cfif>
		<cflock name="#createUUID()#" timeout="60">			
			<cftransaction>
				<cfquery name="ADD_PAYMENT_PLAN_ROW" datasource="#dsn3#">
					INSERT INTO
						SUBSCRIPTION_PAYMENT_PLAN_ROW
						(
							SUBSCRIPTION_ID,
							PRODUCT_ID,
							STOCK_ID,
							PAYMENT_DATE,
							DETAIL,
							UNIT,
							UNIT_ID,
							QUANTITY,
							AMOUNT,
							MONEY_TYPE,
							ROW_TOTAL,
							DISCOUNT,
							ROW_NET_TOTAL,
							IS_COLLECTED_INVOICE,
							IS_GROUP_INVOICE,
							IS_BILLED,
							IS_COLLECTED_PROVISION,
							IS_PAID,
							IS_ACTIVE,
							INVOICE_ID,
							PERIOD_ID,
							PAYMETHOD_ID,
							CARD_PAYMETHOD_ID,
							SUBS_REFERENCE_ID,
							CAMPAIGN_ID,
							RECORD_DATE,
							RECORD_IP,
							RECORD_EMP
						)
					VALUES
						(
							#attributes.subscription_id#,
							2739,
							2704,
							#attributes.start_date#,
							'Damga Vergisi',
							'#GET_PROD_UNIT.MAIN_UNIT#',
							#GET_PROD_UNIT.MAIN_UNIT_ID#,
							#amount_info#,
							#wrk_round(attributes.damga_total,1)#,
							<cfif len(attributes.money_type)>'#attributes.money_type#',<cfelse>'#session.ep.money2#',</cfif>
							#wrk_round(attributes.damga_total,1)#,
							#use_discount#,
							#wrk_round((attributes.damga_total-(attributes.damga_total*use_discount/100)),1)#,
							<cfif attributes.bill_type eq 1>1,<cfelse>0,</cfif>
							<cfif attributes.bill_type eq 2>1,<cfelse>0,</cfif>
							0,
							0,
							0,
							1,
							NULL,
							NULL,
							<cfif listfirst(attributes.pay_method,';') eq 1>#listlast(attributes.pay_method,';')#,<cfelse>NULL,</cfif>
							<cfif listfirst(attributes.pay_method,';') eq 2>#listlast(attributes.pay_method,';')#,<cfelse>NULL,</cfif>
							NULL,
							<cfif isdefined("use_camp_id") and len(use_camp_id)>#use_camp_id#<cfelse>NULL</cfif>,
							#now()#,
							'#cgi.remote_addr#',
							#session.ep.userid#
						)
				</cfquery>
			</cftransaction>
		</cflock>
	</cfif>
</cfif>
<!--- //Damga vergisi ürünü --->
<cfloop from="1" to="#attributes.period#" index="j">
	<cfif j neq 1>
		<!--- Şubat ayı 28 veya 29 seçilmişse başlangıç olarak diğer aylarda ay sonuna atması gerekiyor --->
		<cfif month(attributes.start_date) eq 2 and day(attributes.start_date) eq 28>
			<cfset day_info = 3>
		<cfelseif month(attributes.start_date) eq 2 and day(attributes.start_date) eq 29>
			<cfset day_info = 2>
		<cfelse>
			<cfset day_info = 0>
		</cfif>
		<cfif attributes.period eq 120>
			<cfset paym_date = dateformat(date_add("m",(j-1)*1,attributes.start_date),dateformat_style)>
			<cfif day_info neq 0>
				<cfset old_month = listgetat(paym_date,2,'/')>
				<cfset paym_date = dateformat(date_add("d",day_info,createodbcdatetime(paym_date)),dateformat_style)>
				<cfset new_month = listgetat(paym_date,2,'/')>
				<cfset new_day =listgetat(paym_date,1,'/')>
				<cfif old_month neq new_month>
					<cfset paym_date = dateformat(date_add("d",-1*new_day,createodbcdatetime(dateformat(paym_date,dateformat_style))),dateformat_style)>
				</cfif>
			</cfif>
		<cfelseif attributes.period eq 40>
			<cfset paym_date = dateformat(date_add("m",(j-1)*3,attributes.start_date),dateformat_style)>
			<cfif day_info neq 0>
				<cfset old_month = listgetat(paym_date,2,'/')>
				<cfset paym_date = dateformat(date_add("d",day_info,createodbcdatetime(paym_date)),dateformat_style)>
				<cfset new_month = listgetat(paym_date,2,'/')>
				<cfset new_day =listgetat(paym_date,1,'/')>
				<cfif old_month neq new_month>
					<cfset paym_date = dateformat(date_add("d",-1*new_day,createodbcdatetime(dateformat(paym_date,dateformat_style))),dateformat_style)>
				</cfif>
			</cfif>
		<cfelse>
			<cfset paym_date = dateformat(date_add("yyyy",(j-1)*1,attributes.start_date),dateformat_style)>
		</cfif>
	</cfif>
	<cf_date tarih='paym_date'>
	<cfquery name="GET_PROD" datasource="#dsn3#">
		SELECT PRODUCT_NAME FROM PRODUCT WHERE PRODUCT_ID = <cfif attributes.subscription_type eq 4>787<cfelse>914</cfif>
	</cfquery>
	<cfif GET_PROD.recordcount>
		<cfquery name="GET_PROD_UNIT" datasource="#dsn3#">
			SELECT 
        	    PRODUCT_UNIT_ID, 
                PRODUCT_UNIT_STATUS, 
                PRODUCT_ID, 
                MAIN_UNIT_ID, 
                MAIN_UNIT, 
                IS_MAIN, 
                RECORD_DATE, 
                RECORD_EMP, 
                UPDATE_DATE, 
                UPDATE_EMP 
            FROM 
	            PRODUCT_UNIT 
            WHERE 
            	PRODUCT_ID = <cfif attributes.subscription_type eq 4>787<cfelse>914</cfif> AND IS_MAIN=1 AND PRODUCT_UNIT_STATUS=1
		</cfquery>
		<cfif attributes.period eq 120>
			<cfif attributes.subscription_type eq 4>
				<cfset tutar_787 = attributes.urun_total + attributes.ahm_total>
			<cfelse>
				<cfif j eq 1><cfset tutar_914 = ((tarih_farki/30)*attributes.ahm_total)+attributes.ahm_total><cfelse><cfset tutar_914 = attributes.ahm_total></cfif>
			</cfif>
		<cfelseif attributes.period eq 40>
			<cfif attributes.subscription_type eq 4>
				<cfset tutar_787 = 3*(attributes.urun_total + attributes.ahm_total)>
			<cfelse>
				<cfif j eq 1><cfset tutar_914 = ((tarih_farki/30)*attributes.ahm_total)+(3*attributes.ahm_total)><cfelse><cfset tutar_914 = 3*attributes.ahm_total></cfif>
			</cfif>
		<cfelse>
			<cfif attributes.subscription_type eq 4>
				<cfset tutar_787 = 12*(attributes.urun_total + attributes.ahm_total)>
			<cfelse>
				<cfif j eq 1><cfset tutar_914 = ((tarih_farki/30)*attributes.ahm_total)+(12*attributes.ahm_total)><cfelse><cfset tutar_914 = 12*attributes.ahm_total></cfif>
			</cfif>
		</cfif>
		<cfif attributes.subscription_type eq 4><cfset prod_id_info =787><cfelse><cfset prod_id_info =914></cfif>
		<cfif len(camp_prod_id_list) and listfind(camp_prod_id_list,prod_id_info)>
			<cfset row_info = listfind(camp_prod_id_list,prod_id_info)>
			<cfset prod_info = listgetat(camp_prod_list,row_info,',')>
			<cfset price_info = listgetat(prod_info,2,';')>
			<cfset discount_info = listgetat(prod_info,3,';')>
			<cfset k_discount_info = listgetat(prod_info,4,';')>
			<cfset currency_info = listgetat(prod_info,5,';')>
			<cfset period_info = listgetat(prod_info,6,';')>
			<cfset repeat_number_info = listgetat(prod_info,7,';')>
			<cfset free_repeat_number_info = listgetat(prod_info,8,';')>
			<cfset paymethod_id_info = listgetat(prod_info,9,';')>
			<cfset card_paymethod_id_info = listgetat(prod_info,10,';')>
			<cfset usage_count_info = listgetat(prod_info,11,';')>
			<cfif usage_count_info lt free_repeat_number_info>
				<cfif k_discount_info gt 0>
					<cfif attributes.period eq 120>
						<cfif attributes.subscription_type eq 4>
							<cfset tutar_787 = attributes.urun_total_gross + attributes.ahm_total_gross>
						<cfelse>
							<cfif j eq 1><cfset tutar_914 = ((tarih_farki/30)*attributes.ahm_total_gross)+attributes.ahm_total_gross><cfelse><cfset tutar_914 = attributes.ahm_total_gross></cfif>
						</cfif>
					<cfelseif attributes.period eq 40>
						<cfif attributes.subscription_type eq 4>
							<cfset tutar_787 = 3*(attributes.urun_total_gross + attributes.ahm_total_gross)>
						<cfelse>
							<cfif j eq 1><cfset tutar_914 = ((tarih_farki/30)*attributes.ahm_total_gross)+(3*attributes.ahm_total_gross)><cfelse><cfset tutar_914 = 3*attributes.ahm_total_gross></cfif>
						</cfif>
					<cfelse>
						<cfif attributes.subscription_type eq 4>
							<cfset tutar_787 = 12*(attributes.urun_total_gross + attributes.ahm_total_gross)>
						<cfelse>
							<cfif j eq 1><cfset tutar_914 = ((tarih_farki/30)*attributes.ahm_total_gross)+(12*attributes.ahm_total_gross)><cfelse><cfset tutar_914 = 12*attributes.ahm_total_gross></cfif>
						</cfif>
					</cfif>			
				</cfif>
				<cfif price_info gt 0>
					<cfset "tutar_#prod_id_info#" = price_info>
				</cfif>
				<cfset use_discount = k_discount_info>
				<cfset usage_count_info = usage_count_info + 1>
				<cfset new_prod_info = listsetat(prod_info,11,usage_count_info,';')>
				<cfset camp_prod_list = listsetat(camp_prod_list,row_info,new_prod_info,',')>
				<cfset use_camp_id = attributes.camp_id>
				<cfset amount_info = listgetat(prod_info,12,';')>
			<cfelseif usage_count_info lt repeat_number_info>
				<cfif discount_info gt 0>
					<cfif attributes.period eq 120>
						<cfif attributes.subscription_type eq 4>
							<cfset tutar_787 = attributes.urun_total_gross + attributes.ahm_total_gross>
						<cfelse>
							<cfif j eq 1><cfset tutar_914 = ((tarih_farki/30)*attributes.ahm_total_gross)+attributes.ahm_total_gross><cfelse><cfset tutar_914 = attributes.ahm_total_gross></cfif>
						</cfif>
					<cfelseif attributes.period eq 40>
						<cfif attributes.subscription_type eq 4>
							<cfset tutar_787 = 3*(attributes.urun_total_gross + attributes.ahm_total_gross)>
						<cfelse>
							<cfif j eq 1><cfset tutar_914 = ((tarih_farki/30)*attributes.ahm_total_gross)+(3*attributes.ahm_total_gross)><cfelse><cfset tutar_914 = 3*attributes.ahm_total_gross></cfif>
						</cfif>
					<cfelse>
						<cfif attributes.subscription_type eq 4>
							<cfset tutar_787 = 12*(attributes.urun_total_gross + attributes.ahm_total_gross)>
						<cfelse>
							<cfif j eq 1><cfset tutar_914 = ((tarih_farki/30)*attributes.ahm_total_gross)+(12*attributes.ahm_total_gross)><cfelse><cfset tutar_914 = 12*attributes.ahm_total_gross></cfif>
						</cfif>
					</cfif>			
				</cfif>
				<cfif price_info gt 0>
					<cfset "tutar_#prod_id_info#" = price_info>
				</cfif>
				<cfset use_discount = discount_info>
				<cfset usage_count_info = usage_count_info + 1>
				<cfset new_prod_info = listsetat(prod_info,11,usage_count_info,';')>
				<cfset camp_prod_list = listsetat(camp_prod_list,row_info,new_prod_info,',')>
				<cfset use_camp_id = attributes.camp_id>
				<cfset amount_info = listgetat(prod_info,12,';')>
			<cfelse>
				<cfset use_camp_id = ''>
				<cfset use_discount = 0>
				<cfset amount_info = 1>
			</cfif>
		<cfelse>
			<cfset use_camp_id = ''>
			<cfset use_discount = 0>
			<cfset amount_info = 1>
		</cfif>
		<cflock name="#createUUID()#" timeout="60">
			<cftransaction>
				<cfquery name="ADD_PAYMENT_PLAN_ROW" datasource="#dsn3#">
					INSERT INTO
						SUBSCRIPTION_PAYMENT_PLAN_ROW
						(
							SUBSCRIPTION_ID,
							PRODUCT_ID,
							STOCK_ID,
							PAYMENT_DATE,
							DETAIL,
							UNIT,
							UNIT_ID,
							QUANTITY,
							AMOUNT,
							MONEY_TYPE,
							ROW_TOTAL,
							DISCOUNT,
							ROW_NET_TOTAL,
							IS_COLLECTED_INVOICE,
							IS_GROUP_INVOICE,
							IS_BILLED,
							IS_COLLECTED_PROVISION,
							IS_PAID,
							IS_ACTIVE,
							INVOICE_ID,
							PERIOD_ID,
							PAYMETHOD_ID,
							CARD_PAYMETHOD_ID,
							SUBS_REFERENCE_ID,
							CAMPAIGN_ID,
							RECORD_DATE,
							RECORD_IP,
							RECORD_EMP
						)
					VALUES
						(
							#attributes.subscription_id#,
							<cfif attributes.subscription_type eq 4>787,<cfelse>914,</cfif>
							<cfif attributes.subscription_type eq 4>787,<cfelse>914,</cfif>
							#paym_date#,
							'#left(GET_PROD.PRODUCT_NAME,50)#',
							'#GET_PROD_UNIT.MAIN_UNIT#',
							#GET_PROD_UNIT.MAIN_UNIT_ID#,
							#amount_info#,
							<cfif attributes.subscription_type eq 4>#wrk_round(tutar_787,1)#,<cfelse>#wrk_round(tutar_914,1)#,</cfif>
							<cfif len(attributes.money_type)>'#attributes.money_type#',<cfelse>'#session.ep.money2#',</cfif>
							<cfif attributes.subscription_type eq 4>#wrk_round(tutar_787,1)#,<cfelse>#wrk_round(tutar_914,1)#,</cfif>
							#use_discount#,
							<cfif attributes.subscription_type eq 4>#wrk_round((tutar_787-(tutar_787*use_discount/100)),1)#,<cfelse>#wrk_round((tutar_914-(tutar_914*use_discount/100)),1)#,</cfif>
							<cfif attributes.bill_type eq 1>1,<cfelse>0,</cfif>
							<cfif attributes.bill_type eq 2>1,<cfelse>0,</cfif>
							0,
							0,
							0,
							1,
							NULL,
							NULL,
							<cfif listfirst(attributes.pay_method,';') eq 1>#listlast(attributes.pay_method,';')#,<cfelse>NULL,</cfif>
							<cfif listfirst(attributes.pay_method,';') eq 2>#listlast(attributes.pay_method,';')#,<cfelse>NULL,</cfif>
							NULL,
							<cfif isdefined("use_camp_id") and len(use_camp_id)>#use_camp_id#<cfelse>NULL</cfif>,
							#now()#,
							'#cgi.remote_addr#',
							#session.ep.userid#
						)
				</cfquery>
			</cftransaction>
		</cflock>		
	</cfif>
</cfloop>
<!--- eğer kampanyadan gelen ürünlerde yukarda kullanılmayan satırlar varsa onları da ekleyecek 
<cfif len(camp_prod_list)>
	<cflock name="#createUUID()#" timeout="60">
		<cftransaction>
			<cfloop list="#camp_prod_id_list#" index="kk_prod">
				<cfset row_info = listfind(camp_prod_id_list,kk_prod)>
				<cfset prod_info = listgetat(camp_prod_list,row_info,',')>
				<cfset price_info = listgetat(prod_info,2,';')>
				<cfset discount_info = listgetat(prod_info,3,';')>
				<cfset k_discount_info = listgetat(prod_info,4,';')>
				<cfset currency_info = listgetat(prod_info,5,';')>
				<cfset period_info = listgetat(prod_info,6,';')>
				<cfset repeat_number_info = listgetat(prod_info,7,';')>
				<cfset free_repeat_number_info = listgetat(prod_info,8,';')>
				<cfset paymethod_id_info = listgetat(prod_info,9,';')>
				<cfset card_paymethod_id_info = listgetat(prod_info,10,';')>
				<cfquery name="get_prod" datasource="#dsn3#">
					SELECT STOCK_ID,PRODUCT_NAME FROM STOCKS WHERE PRODUCT_ID = #kk_prod#
				</cfquery>
				<cfquery name="GET_PROD_UNIT" datasource="#dsn3#">
					SELECT * FROM PRODUCT_UNIT WHERE PRODUCT_ID = #kk_prod# AND IS_MAIN=1 AND PRODUCT_UNIT_STATUS=1
				</cfquery>
				<cfset new_paym_date = attributes.start_date>
				<cfloop from="1" to="#attributes.period#" index="jj">
					<cfset kontrol_usage = 0>
					<cfset usage_count_info = listgetat(listgetat(camp_prod_list,row_info,','),11,';')>
					<cfif usage_count_info lt free_repeat_number_info>
						<cfset tutar_info = price_info>
						<cfset use_discount = k_discount_info>
						<cfset usage_count_info = usage_count_info + 1>
						<cfset new_prod_info = listsetat(prod_info,11,usage_count_info,';')>
						<cfset camp_prod_list = listsetat(camp_prod_list,row_info,new_prod_info,',')>
						<cfset use_camp_id = attributes.camp_id>
						<cfset amount_info = listgetat(prod_info,12,';')>
						<cfset kontrol_usage = 1>
					<cfelseif usage_count_info lt repeat_number_info>
						<cfset tutar_info = price_info>
						<cfset use_discount = discount_info>
						<cfset usage_count_info = usage_count_info + 1>
						<cfset new_prod_info = listsetat(prod_info,11,usage_count_info,';')>
						<cfset camp_prod_list = listsetat(camp_prod_list,row_info,new_prod_info,',')>
						<cfset use_camp_id = attributes.camp_id>
						<cfset amount_info = listgetat(prod_info,12,';')>
						<cfset kontrol_usage = 1>
					</cfif>
					<cfif jj neq 1>
						<cfif period_info eq 120>
							<cfset new_paym_date = dateformat(date_add("m",1,new_paym_date),dateformat_style)>
						<cfelseif period_info eq 60>
							<cfset new_paym_date = dateformat(date_add("m",2,new_paym_date),dateformat_style)>
						<cfelseif period_info eq 40>
							<cfset new_paym_date = dateformat(date_add("m",3,new_paym_date),dateformat_style)>
						<cfelseif period_info eq 20>
							<cfset new_paym_date = dateformat(date_add("m",6,new_paym_date),dateformat_style)>
						<cfelse>
							<cfset new_paym_date = dateformat(date_add("y",1,new_paym_date),dateformat_style)>
						</cfif>
					</cfif>
					<cf_date tarih='new_paym_date'>
					<cfif kontrol_usage eq 1>
						<cfquery name="ADD_PAYMENT_PLAN_ROW" datasource="#dsn3#">
							INSERT INTO
								SUBSCRIPTION_PAYMENT_PLAN_ROW
								(
									SUBSCRIPTION_ID,
									PRODUCT_ID,
									STOCK_ID,
									PAYMENT_DATE,
									DETAIL,
									UNIT,
									UNIT_ID,
									QUANTITY,
									AMOUNT,
									MONEY_TYPE,
									ROW_TOTAL,
									DISCOUNT,
									ROW_NET_TOTAL,
									IS_COLLECTED_INVOICE,
									IS_GROUP_INVOICE,
									IS_BILLED,
									IS_COLLECTED_PROVISION,
									IS_PAID,
									IS_ACTIVE,
									INVOICE_ID,
									PERIOD_ID,
									PAYMETHOD_ID,
									CARD_PAYMETHOD_ID,
									SUBS_REFERENCE_ID,
									CAMPAIGN_ID,
									RECORD_DATE,
									RECORD_IP,
									RECORD_EMP
								)
							VALUES
								(
									#attributes.subscription_id#,
									#kk_prod#,
									#get_prod.stock_id#,
									#new_paym_date#,
									'#left(GET_PROD.PRODUCT_NAME,50)#',
									'#GET_PROD_UNIT.MAIN_UNIT#',
									#GET_PROD_UNIT.MAIN_UNIT_ID#,
									#amount_info#,
									#wrk_round(tutar_info,1)#,
									'#currency_info#',
									#wrk_round(tutar_info,1)#,
									#use_discount#,
									#wrk_round((tutar_info-(tutar_info*use_discount/100)),1)#,
									<cfif attributes.bill_type eq 1>1,<cfelse>0,</cfif>
									<cfif attributes.bill_type eq 2>1,<cfelse>0,</cfif>
									0,
									0,
									0,
									1,
									NULL,
									NULL,
									<cfif len(paymethod_id_info)>#paymethod_id_info#,<cfelse>NULL,</cfif>
									<cfif len(card_paymethod_id_info)>#card_paymethod_id_info#,<cfelse>NULL,</cfif>
									NULL,
									<cfif isdefined("use_camp_id") and len(use_camp_id)>#use_camp_id#<cfelse>NULL</cfif>,
									#now()#,
									'#cgi.remote_addr#',
									#session.ep.userid#
								)
						</cfquery>
					</cfif>
				</cfloop>
			</cfloop>
		</cftransaction>
	</cflock>		
</cfif>--->
<!--- //ödeme planı history kayıtları = yeni durum güncellemesi ve yeni eklenen case lerin tutulması bölümü--->
<cflock name="#createUUID()#" timeout="60">
	<cftransaction>
		<cfif GET_PAYM_PLAN.recordcount>
			<cfquery name="GET_PAYM_PLAN_HISTORY" datasource="#dsn3#" maxrows="#history_record#">
				SELECT TOP #history_record# SUBS_PAYMPLAN_ROW_HISTORY_ID,PAYM_PLAN_YEAR,PAYM_PLAN_MONEY_TYPE FROM SUBSCRIPTION_PAYMENT_PLAN_ROW_HISTORY WHERE SUBSCRIPTION_ID = #attributes.subscription_id# ORDER BY SUBS_PAYMPLAN_ROW_HISTORY_ID DESC
			</cfquery>
			<cfoutput query="GET_PAYM_PLAN_HISTORY">
				<cfquery name="GET_LAST_PAYPLAN" datasource="#dsn3#">
					SELECT
						SUM(ROW_NET_TOTAL) LAST_TOTAL
					FROM
						SUBSCRIPTION_PAYMENT_PLAN_ROW
					WHERE
						SUBSCRIPTION_ID = #attributes.subscription_id# AND
						YEAR(PAYMENT_DATE) = #GET_PAYM_PLAN_HISTORY.PAYM_PLAN_YEAR# AND
						MONEY_TYPE = '#GET_PAYM_PLAN_HISTORY.PAYM_PLAN_MONEY_TYPE#'
					GROUP BY
						YEAR(PAYMENT_DATE),
						MONEY_TYPE
					ORDER BY
						YEAR(PAYMENT_DATE)
				</cfquery>
				<cfif GET_LAST_PAYPLAN.recordcount>
					<cfquery name="UPD_PAYM_PLAN" datasource="#dsn3#">
						UPDATE
							SUBSCRIPTION_PAYMENT_PLAN_ROW_HISTORY
						SET
							PAYM_PLAN_TOTAL_LAST = #GET_LAST_PAYPLAN.LAST_TOTAL#
						WHERE
							SUBS_PAYMPLAN_ROW_HISTORY_ID = #GET_PAYM_PLAN_HISTORY.SUBS_PAYMPLAN_ROW_HISTORY_ID#
					</cfquery>
				</cfif>
			</cfoutput>
		</cfif>
		<cfquery name="INSERT_PAYM_PLAN_HISTORY" datasource="#dsn3#">
			INSERT INTO
				SUBSCRIPTION_PAYMENT_PLAN_ROW_HISTORY
			(
				SUBSCRIPTION_ID,
				PAYM_PLAN_YEAR,
				PAYM_PLAN_TOTAL_LAST,
				PAYM_PLAN_MONEY_TYPE,
				CAMPAIGN_ID,
				RECORD_EMP,
				RECORD_IP,
				RECORD_DATE
			)
				SELECT	
					SUBSCRIPTION_ID,
					YEAR(PAYMENT_DATE),
					SUM(ROW_NET_TOTAL),
					MONEY_TYPE,
					CAMPAIGN_ID,
					#session.ep.userid#,
					'#cgi.remote_addr#',
					#now()#
					
				FROM
					SUBSCRIPTION_PAYMENT_PLAN_ROW
				WHERE
					SUBSCRIPTION_ID = #attributes.subscription_id# AND
					(
						(
							MONEY_TYPE NOT IN 
							(
								SELECT
									PAYM_PLAN_MONEY_TYPE
								FROM
									SUBSCRIPTION_PAYMENT_PLAN_ROW_HISTORY
								WHERE
									SUBSCRIPTION_ID = #attributes.subscription_id#
							)
						)
						OR 
						(
							YEAR(PAYMENT_DATE) NOT IN 
							(
								SELECT
									PAYM_PLAN_YEAR
								FROM
									SUBSCRIPTION_PAYMENT_PLAN_ROW_HISTORY
								WHERE
									SUBSCRIPTION_ID = #attributes.subscription_id#
							)
						)
					)
			GROUP BY
				SUBSCRIPTION_ID,
				YEAR(PAYMENT_DATE),
				MONEY_TYPE,
				CAMPAIGN_ID
		</cfquery>
	</cftransaction>
</cflock>
<script type="text/javascript">
	wrk_opener_reload();
	window.close();
</script>
