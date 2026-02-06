<cfquery name="GET_SPECT_ROW" dbtype="query">
	SELECT
		*
	FROM
		GET_SPECT_ROW_ALL
	WHERE
		<cfif isdefined('attributes.spect_id#i#') and len(evaluate('attributes.spect_id#i#'))>
			SPECT_ID=#evaluate('attributes.spect_id#i#')# 
		<cfelse>
			SPECT_ID IS NULL
		</cfif>
		AND ORDER_ID=#attributes.order_id#
		AND MAIN_STOCK_ID=#evaluate("attributes.stock_id#i#")#
	ORDER BY
		ORDER_ROW_ID
</cfquery>
<cfif not GET_SPECT_ROW.recordcount>
	<cfif isdefined('attributes.spect_id#i#') and len(evaluate('attributes.spect_id#i#'))>
		<cfquery name="GET_SPECT_ROW" datasource="#dsn3#">
			SELECT
				*
			FROM
				SPECTS_ROW
			WHERE
				SPECT_ID=#evaluate('attributes.spect_id#i#')#
		</cfquery>
	<cfelseif isdefined("attributes.stock_id#i#") and len(evaluate("attributes.stock_id#i#"))>
		<cfquery name="GET_SPECT_ROW" datasource="#dsn3#">
			SELECT 
				STOCKS.STOCK_ID,
				STOCKS.PRODUCT_ID,
				STOCKS.PRODUCT_NAME,
				STOCKS.PROPERTY,
				PRODUCT_TREE.IS_CONFIGURE,
				PRODUCT_TREE.IS_SEVK,
				PRODUCT_TREE.AMOUNT AMOUNT_VALUE,
				0 IS_PROPERTY
			FROM
				STOCKS,
				PRODUCT_TREE,
				PRODUCT_UNIT
			WHERE
				PRODUCT_UNIT.PRODUCT_UNIT_ID = PRODUCT_TREE.UNIT_ID AND
				PRODUCT_TREE.RELATED_ID = STOCKS.STOCK_ID AND
				PRODUCT_TREE.STOCK_ID = #evaluate("attributes.stock_id#i#")#
		</cfquery>
	</cfif>
</cfif>
<cfif isdefined('GET_SPECT_ROW') and GET_SPECT_ROW.RECORDCOUNT>
	<cfif isdefined("attributes.company_id") and len(attributes.company_id)>
		<cfquery name="GET_PRICE_CAT_CREDIT" datasource="#dsn3#">
			SELECT
				PRICE_CAT
			FROM
				#dsn_alias#.COMPANY_CREDIT
			WHERE
				COMPANY_ID = #attributes.company_id#  AND
				OUR_COMPANY_ID = #session.ep.company_id#
		</cfquery>
		<cfif GET_PRICE_CAT_CREDIT.RECORDCOUNT and len(GET_PRICE_CAT_CREDIT.PRICE_CAT)>
			<cfset attributes.price_catid=GET_PRICE_CAT_CREDIT.PRICE_CAT>
		<cfelse>
			<cfquery name="GET_COMP_CAT" datasource="#dsn3#">
				SELECT COMPANYCAT_ID FROM #dsn_alias#.COMPANY WHERE COMPANY_ID = #attributes.company_id#
			</cfquery>
			<cfquery name="GET_PRICE_CAT_COMP" datasource="#dsn3#">
				SELECT 
					PRICE_CATID
				FROM
					PRICE_CAT
				WHERE
					COMPANY_CAT LIKE '%,#GET_COMP_CAT.COMPANYCAT_ID#,%'
			</cfquery>
			<cfset attributes.price_catid=GET_PRICE_CAT_COMP.PRICE_CATID>
		</cfif>
	<cfelseif isdefined("attributes.consumer_id") and len(attributes.consumer_id)>
		<cfquery name="GET_COMP_CAT" datasource="#DSN3#">
			SELECT CONSUMER_CAT_ID FROM #dsn_alias#.CONSUMER WHERE CONSUMER_ID = #attributes.consumer_id#
		</cfquery>
		<cfquery name="GET_PRICE_CAT" datasource="#DSN3#">
			SELECT PRICE_CATID FROM PRICE_CAT WHERE CONSUMER_CAT LIKE '%,#get_comp_cat.consumer_cat_id#,%'
		</cfquery>
		<cfset attributes.price_catid=get_price_cat.PRICE_CATID>
	</cfif>
	
	<cfset product_id_list=valuelist(GET_SPECT_ROW.PRODUCT_ID,',')>
	<cfset product_id_list=ListDeleteDuplicates(product_id_list)>
	<cfif listlen(product_id_list,',')>
		<!--- tum sayfadaki urunler icin fiyatları aliyor sonra query of query ile cekecek--->
		<cfif isdefined("attributes.price_catid") and len(attributes.price_catid)>
			<cfquery name="GET_PRICE" datasource="#dsn3#">
				SELECT
					PRICE_STANDART.PRODUCT_ID,
					SM.MONEY,
					PRICE_STANDART.PRICE,
					(PRICE_STANDART.PRICE*(SM.RATE2/SM.RATE1)) AS PRICE_STDMONEY,
					(PRICE_STANDART.PRICE_KDV*(SM.RATE2/SM.RATE1)) AS PRICE_KDV_STDMONEY,
					SM.RATE2,
					SM.RATE1
				FROM
					PRICE PRICE_STANDART,	
					PRODUCT_UNIT,
					#dsn_alias#.SETUP_MONEY AS SM
				WHERE
					PRICE_STANDART.PRICE_CATID=#attributes.price_catid# AND
					ISNULL(PRICE_STANDART.STOCK_ID,0)=0 AND
					ISNULL(PRICE_STANDART.SPECT_VAR_ID,0)=0 AND
					PRICE_STANDART.STARTDATE< #attributes.order_date# AND 
					(PRICE_STANDART.FINISHDATE >= #attributes.order_date# OR PRICE_STANDART.FINISHDATE IS NULL) AND
					PRODUCT_UNIT.PRODUCT_ID = PRICE_STANDART.PRODUCT_ID AND 
					PRICE_STANDART.PRODUCT_ID IN (#product_id_list#) AND 
					PRODUCT_UNIT.IS_MAIN = 1 AND
					SM.MONEY = PRICE_STANDART.MONEY AND
					SM.PERIOD_ID = #session.ep.period_id#
			</cfquery>
		</cfif>
		<cfquery name="GET_PRICE_STANDART" datasource="#dsn3#">
			SELECT
				PRICE_STANDART.PRODUCT_ID,
				SM.MONEY,
				PRICE_STANDART.PRICE,
				(PRICE_STANDART.PRICE*(SM.RATE2/SM.RATE1)) AS PRICE_STDMONEY,
				(PRICE_STANDART.PRICE_KDV*(SM.RATE2/SM.RATE1)) AS PRICE_KDV_STDMONEY,
				SM.RATE2,
				SM.RATE1,
				PRICE_STANDART.START_DATE
			FROM
				PRODUCT,
				PRICE_STANDART,
				#dsn_alias#.SETUP_MONEY AS SM
			WHERE
				PRODUCT.PRODUCT_ID = PRICE_STANDART.PRODUCT_ID AND
				PURCHASESALES = 1 AND
				<!--- PRICESTANDART_STATUS = 1 AND --->
				START_DATE<=#attributes.order_date# AND
				SM.MONEY = PRICE_STANDART.MONEY AND
				SM.PERIOD_ID = #session.ep.period_id# AND
				PRODUCT.PRODUCT_ID IN (#product_id_list#)
		</cfquery>
		<!--- //tum sayfadaki urunler icin fiyatları aliyor sonra query of query ile cekecek--->
	</cfif>
	<cfset ilk_satir=''>
	<cfoutput query="GET_SPECT_ROW">
	<cfif isdefined('ORDER_ROW_ID') and not len(ilk_satir)>
	<!--- bir sipariste aynı urunden birden fazla oldugu zaman katlanarak yazmasını engelemek icin--->
		<cfset ilk_satir=ORDER_ROW_ID>
	</cfif>
	<cfif not len(ilk_satir) or ilk_satir eq ORDER_ROW_ID>
		<cfset satir_maliyet=0>
		<cfset GET_COST.MONEY="">
		<cfset GET_COST.PRODUCT_COST_ID="">
		<cfif listlen(product_id_list,',')>
			<cfif isdefined("GET_PRICE")>
				 <cfquery name="GET_PRICE_MAIN" dbtype="query">
					SELECT
						*
					FROM
						GET_PRICE
					WHERE
						PRODUCT_ID=#PRODUCT_ID#
				  </cfquery>
			  </cfif>
			  <cfif not isdefined("GET_PRICE_MAIN") or  GET_PRICE_MAIN.RECORDCOUNT eq 0>
				<cfquery name="GET_PRICE_MAIN" dbtype="query" maxrows="1">
					SELECT
						*
					FROM
						GET_PRICE_STANDART
					WHERE
						PRODUCT_ID=#PRODUCT_ID#
					ORDER BY
						START_DATE DESC
				</cfquery>
			  </cfif>
	
			<cfquery name="GET_COST" datasource="#dsn3#" maxrows="1">
				SELECT  
					PRODUCT_COST,
					PRODUCT_COST_ID,
					MONEY
				FROM
					#dsn1_alias#.PRODUCT_COST
				WHERE    
					PRODUCT_ID = #PRODUCT_ID# AND
					START_DATE <= #attributes.order_date#
				ORDER BY
					START_DATE DESC,
					RECORD_DATE DESC
			</cfquery>
			<cfif len(GET_COST.PRODUCT_COST)><cfset satir_maliyet=GET_COST.PRODUCT_COST></cfif>
		</cfif>
		<cfquery name="ADD_ROW" datasource="#dsn3#">
			INSERT
			INTO
				ORDER_ROW_SPECT
				(
					SPECT_ID,
					ORDER_ID,
					ORDER_ROW_ID,
					PRODUCT_ID,
					STOCK_ID,
					AMOUNT_VALUE,
					TOTAL_VALUE,
					MONEY_CURRENCY,
					PRODUCT_NAME,
					IS_PROPERTY,
					IS_CONFIGURE,
					DIFF_PRICE,
					PRODUCT_COST,
					PRODUCT_COST_MONEY,
					PRODUCT_COST_ID,
					IS_SEVK,
					PROPERTY_ID,
					VARIATION_ID,
					TOTAL_MIN,
					TOTAL_MAX
				)
				VALUES
				(
					<cfif isdefined('attributes.spect_id#i#') and len(evaluate('attributes.spect_id#i#'))>#evaluate('attributes.spect_id#i#')#<cfelse>NULL</cfif>,
					#attributes.order_id#,
					#GET_MAX_ORDER_ROW.ORDER_ROW_ID#,
					<cfif len(PRODUCT_ID)>#PRODUCT_ID#<cfelse>NULL</cfif>,
					<cfif len(STOCK_ID)>#STOCK_ID#<cfelse>NULL</cfif>,
					<cfif len(GET_SPECT_ROW.AMOUNT_VALUE)>#GET_SPECT_ROW.AMOUNT_VALUE#<cfelse>0</cfif>,
					<cfif isdefined("GET_PRICE_MAIN.PRICE") and listlen(product_id_list,',')>
						<cfif len(GET_PRICE_MAIN.PRICE)>#GET_PRICE_MAIN.PRICE#<cfelse>0</cfif>,
						'#GET_PRICE_MAIN.MONEY#',
					<cfelseif isdefined('GET_SPECT_ROW.TOTAL_VALUE')>
						<cfif len(GET_SPECT_ROW.TOTAL_VALUE)>#GET_SPECT_ROW.TOTAL_VALUE#<cfelse>0</cfif>,
						'#GET_SPECT_ROW.MONEY_CURRENCY#',
					<cfelse>
							0,
							#session.ep.money#,
					</cfif>
					<cfif len(GET_SPECT_ROW.PRODUCT_NAME)>'#GET_SPECT_ROW.PRODUCT_NAME#'<cfelse>NULL</cfif>,
					<cfif GET_SPECT_ROW.IS_PROPERTY eq 1>1<cfelse>0</cfif>,
					<cfif GET_SPECT_ROW.IS_CONFIGURE eq 1>1<cfelse>0</cfif>,
					<cfif isdefined('GET_SPECT_ROW.DIFF_PRICE') and len(GET_SPECT_ROW.DIFF_PRICE)>#GET_SPECT_ROW.DIFF_PRICE#<cfelse>0</cfif>,
					#satir_maliyet#,
					<cfif len(GET_COST.MONEY)>'#GET_COST.MONEY#'<cfelse>NULL</cfif>,
					<cfif len(GET_COST.PRODUCT_COST_ID)>#GET_COST.PRODUCT_COST_ID#<cfelse>NULL</cfif>,
					<cfif IS_SEVK eq 1>#IS_SEVK#<cfelse>0</cfif>,
					<cfif isdefined('GET_SPECT_ROW.PROPERTY_ID') and len(GET_SPECT_ROW.PROPERTY_ID)>#GET_SPECT_ROW.PROPERTY_ID#<cfelse>NULL</cfif>,
					<cfif isdefined('GET_SPECT_ROW.VARIATION_ID') and len(GET_SPECT_ROW.VARIATION_ID)>#GET_SPECT_ROW.VARIATION_ID#<cfelse>NULL</cfif>,
					<cfif isdefined('GET_SPECT_ROW.TOTAL_MIN') and len(GET_SPECT_ROW.TOTAL_MIN)>#GET_SPECT_ROW.TOTAL_MIN#<cfelse>NULL</cfif>,
					<cfif isdefined('GET_SPECT_ROW.TOTAL_MAX') and len(GET_SPECT_ROW.TOTAL_MAX)>#GET_SPECT_ROW.TOTAL_MAX#<cfelse>NULL</cfif>
				)
		</cfquery>
	</cfif>
	</cfoutput>
</cfif>
