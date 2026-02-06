<!--- urune spect secilmemis ancak urun agaci varsa veya özellikleri varsa spect olarak onu kaydediyoruz o satir icin--->
<cfscript>
	main_stock_id=evaluate("attributes.stock_id#i#");
	main_product_id=evaluate("attributes.product_id#i#");
	spec_name='#evaluate("attributes.product_name#i#")#';
	stock_id_list="";
	product_id_list="";
	product_name_list="";
	amount_list="";
	diff_price_list="";
	sevk_list="";
	configure_list="";
	is_property_list="";
	property_id_list = "";
	variation_id_list = "";
	total_min_list = "";
	total_max_list = "";
	tolerance_list = "";
	money_list="";
	money_rate1_list="";
	money_rate2_list="";
</cfscript>
<!--- 3 Aya Silinsin 1Nisan2008 M.ER --->
<!--- <cfif session.ep.our_company_info.spect_type eq 3>
	<cfquery name="GET_TREE#i#" datasource="#DSN3#">
		SELECT 
			*
		FROM 
			#dsn1_alias#.PRODUCT_DT_PROPERTIES PRODUCT_DT_PROPERTIES
		WHERE 
			PRODUCT_DT_PROPERTIES.PRODUCT_ID = #evaluate("attributes.product_id#i#")#
	</cfquery>
	<cfscript>
		if(evaluate('GET_TREE#i#.RECORDCOUNT'))
		{
			spec_type=3;//ozellikli oldugu icin 3
			for(ii=1;ii lte evaluate('GET_TREE#i#.RECORDCOUNT');ii=ii+1)
			{
				stock_id_list = listappend(stock_id_list,0,',');
				product_id_list = listappend(product_id_list,0,',');
				amount_list = listappend(amount_list,evaluate('GET_TREE#i#.AMOUNT[#ii#]'),',');
				diff_price_list=listappend(diff_price_list,0,',');
				product_name_list = listappend(product_name_list,'-',',');
				sevk_list = listappend(sevk_list,0,',');
				configure_list = listappend(configure_list,0,',');
				is_property_list=listappend(is_property_list,1,',');
				if(len(evaluate('GET_TREE#i#.PROPERTY_ID[#ii#]')))
					property_id_list = listappend(property_id_list,evaluate('GET_TREE#i#.PROPERTY_ID[#ii#]'),',');
				else
					property_id_list = listappend(property_id_list,0,',');
				if(len(evaluate('GET_TREE#i#.VARIATION_ID[#ii#]')))
					variation_id_list = listappend(variation_id_list,evaluate('GET_TREE#i#.VARIATION_ID[#ii#]'),',');
				else 
					variation_id_list = listappend(variation_id_list,0,',');
				if(len(evaluate('GET_TREE#i#.TOTAL_MIN[#ii#]')))
					total_min_list = listappend(total_min_list,evaluate('GET_TREE#i#.TOTAL_MIN[#ii#]'),',');
				else
					total_min_list = listappend(total_min_list,0,',');
				if(len(evaluate('GET_TREE#i#.TOTAL_MAX[#ii#]')))
					total_max_list = listappend(total_max_list,evaluate('GET_TREE#i#.TOTAL_MAX[#ii#]'),',');
				else
					total_max_list = listappend(total_max_list,0,',');
				tolerance_list = listappend(tolerance_list,'-',',');
			}
		}
	</cfscript>
</cfif> --->
<cfif not isdefined('GET_TREE#i#.RECORDCOUNT') or evaluate('GET_TREE#i#.RECORDCOUNT') eq 0><!--- ozellikli spec degil veya ozellikli spec olsada urun ozelligi yoksa agaci varsa o kaydedilecek --->
	<cfquery name="GET_TREE#i#" datasource="#DSN3#">
		SELECT 
			STOCKS.PRODUCT_ID,
			STOCKS.PRODUCT_NAME,
			STOCKS.PROPERTY,
			PRODUCT_TREE.PRODUCT_TREE_ID,
			PRODUCT_TREE.RELATED_ID,
			PRODUCT_TREE.HIERARCHY,
			PRODUCT_TREE.IS_TREE,
			PRODUCT_TREE.AMOUNT,
			PRODUCT_TREE.UNIT_ID,
			PRODUCT_TREE.STOCK_ID,
			PRODUCT_TREE.IS_CONFIGURE,
			PRODUCT_TREE.IS_SEVK
		FROM 
			PRODUCT_TREE,
			STOCKS
		WHERE 
			PRODUCT_TREE.STOCK_ID=#evaluate("attributes.stock_id#i#")# AND
			PRODUCT_TREE.RELATED_ID=STOCKS.STOCK_ID
	</cfquery>
	<cfscript>
		if(evaluate('GET_TREE#i#.RECORDCOUNT'))
		{
			spec_type=1;//simdikil 1 attik ama bu durumda baska degerlerde gelebilir cunku sessionda 3 olsada ozellik yoksa bu taraga giriiyor
			for(ii=1;ii lte evaluate('GET_TREE#i#.RECORDCOUNT');ii=ii+1)
			{
				if(evaluate('GET_TREE#i#.STOCK_ID[#ii#]') gt 0)
					stock_id_list = listappend(stock_id_list,evaluate('GET_TREE#i#.RELATED_ID[#ii#]'),',');
				else
					stock_id_list = listappend(stock_id_list,0,',');
				if(evaluate('GET_TREE#i#.PRODUCT_ID[#ii#]') gt 0)
					product_id_list = listappend(product_id_list,evaluate('GET_TREE#i#.PRODUCT_ID[#ii#]'),',');
				else
					product_id_list = listappend(product_id_list,0,',');
				amount_list = listappend(amount_list,evaluate('GET_TREE#i#.AMOUNT[#ii#]'),',');
				diff_price_list=listappend(diff_price_list,0,',');
				if(len(evaluate('GET_TREE#i#.PRODUCT_NAME[#ii#]')))
					product_name_list = listappend(product_name_list,'#evaluate('GET_TREE#i#.PRODUCT_NAME[#ii#]')# #evaluate('GET_TREE#i#.PROPERTY[#ii#]')#',',');
				else
					product_name_list = listappend(product_name_list,'-',',');
				if(evaluate('GET_TREE#i#.IS_SEVK[#ii#]') eq 1)
					sevk_list = listappend(sevk_list,1,',');
				else
					sevk_list = listappend(sevk_list,0,',');
				if(evaluate('GET_TREE#i#.IS_CONFIGURE[#ii#]') eq 1)
					configure_list = listappend(configure_list,1,',');
				else
					configure_list = listappend(configure_list,0,',');
				is_property_list=listappend(is_property_list,0,',');
				property_id_list = listappend(property_id_list,0,',');
				variation_id_list = listappend(variation_id_list,0,',');
				total_min_list = listappend(total_min_list,'-',',');
				total_max_list = listappend(total_max_list,'-',',');
				tolerance_list = listappend(tolerance_list,'-',',');
			}
		}
	</cfscript>
</cfif>

<cfscript>
if(evaluate('GET_TREE#i#.RECORDCOUNT'))
{
	row_count=evaluate('GET_TREE#i#.RECORDCOUNT');
	for(qq=1;qq lte attributes.kur_say;qq=qq+1)
	{
		money_list=listappend(money_list,evaluate("attributes.hidden_rd_money_#qq#"),',');
		money_rate1_list=listappend(money_rate1_list,evaluate("attributes.txt_rate1_#qq#"),',');
		money_rate2_list=listappend(money_rate2_list,evaluate("attributes.txt_rate2_#qq#"),',');
		if(evaluate("attributes.hidden_rd_money_#qq#") is attributes.BASKET_MONEY)
			spec_money_select=evaluate("attributes.hidden_rd_money_#qq#");
		else
			spec_money_select=evaluate("attributes.hidden_rd_money_#qq#");
	}

	'spec_info#i#'=specer(
			dsn_type: dsn3,
			spec_type: session.ep.our_company_info.spect_type,
			spec_is_tree: 1,
			company_id: attributes.company_id,
			consumer_id: attributes.consumer_id,
			main_stock_id: main_stock_id,
			main_product_id: main_product_id,
			spec_name: spec_name,
			money_list :money_list,
			money_rate1_list :money_rate1_list,
			money_rate2_list : money_rate2_list,
			spec_money_select : spec_money_select,
			spec_row_count: row_count,
			stock_id_list: stock_id_list,
			product_id_list: product_id_list,
			product_name_list: product_name_list,
			amount_list: amount_list,
			diff_price_list: diff_price_list,
			is_sevk_list: sevk_list,	
			is_configure_list: configure_list,
			is_property_list: is_property_list,
			property_id_list: property_id_list,
			variation_id_list: variation_id_list,
			total_min_list: total_min_list,
			total_max_list : total_max_list,
			tolerance_list : tolerance_list
		);
}
</cfscript>
<cfif isdefined('spec_info#i#') and listlen(evaluate('spec_info#i#'),',')>
	<cfset 'attributes.spect_id#i#'=listgetat(evaluate('spec_info#i#'),2,',')>
	<cfif len(listgetat(evaluate('spec_info#i#'),3,','))>
		<cfset 'attributes.spect_name#i#'=listgetat(evaluate('spec_info#i#'),3,',')>
	<cfelse>
		<cfset 'attributes.spect_name#i#'=evaluate("attributes.product_name#i#")>
	</cfif>
	<cfif len(listgetat(evaluate('spec_info#i#'),3,','))>
		<cfset 'attributes.cost_id#i#'=''>
		<cfset 'attributes.net_maliyet#i#'=listgetat(evaluate('spec_info#i#'),9,',')>
		<cfset 'attributes.extra_cost#i#'=listgetat(evaluate('spec_info#i#'),10,',')>
	</cfif>
</cfif>
<!--- 20061016 TolgaS

<cfset max_spect_id=''>
<cfset attributes.main_spect_id=''>
<cfif isdefined('attributes.spect_id#i#') and not len(evaluate('attributes.spect_id#i#'))>
	<cfquery name="GET_TREE" datasource="#DSN3#">
		SELECT 
			*
		FROM
			PRODUCT_TREE
		WHERE
			STOCK_ID=#evaluate("attributes.stock_id#i#")#
	</cfquery>
	
	<cfif GET_TREE.RECORDCOUNT>
		<cfif not len(evaluate('attributes.#attributes.search_process_date#'))>
			<cfset action_spect_date=#now()#>
		<cfelse>
			<cfset action_spect_date=evaluate('attributes.#attributes.search_process_date#')>
		</cfif>
		<cfif not find('ts',action_spect_date)>
			<cf_date tarih="action_spect_date">
		</cfif>
		<cfset stock_id_list=ValueList(GET_TREE.RELATED_ID,',')>
		<cfset stock_id_list=ListAppend(stock_id_list,GET_TREE.STOCK_ID,',')>
		<cfquery name="GET_PROD_ID_ALL" datasource="#DSN3#">
			SELECT PRODUCT_ID,STOCK_ID,PRODUCT_NAME,PROPERTY FROM STOCKS WHERE STOCK_ID IN (#stock_id_list#)
		</cfquery>
		
		<cfscript>
			satir=0;
			form_stock_id_list="";
			form_amount_list="";
			form_sevk_list="";
			for(n=1;n lte GET_TREE.RECORDCOUNT;n=n+1)
			{
				form_stock_id_list = listappend(form_stock_id_list,GET_TREE.RELATED_ID[n],',');
				form_amount_list = listappend(form_amount_list,GET_TREE.AMOUNT[n],',');
				if(GET_TREE.IS_SEVK[n] eq 1)
					form_sevk_list = listappend(form_sevk_list,1,',');
				else
					form_sevk_list = listappend(form_sevk_list,0,',');
			}
		</cfscript>
		<cfquery name="GET_SPECT_ROW_COUNT" datasource="#DSN3#">
			SELECT 
				COUNT(SPECT_MAIN.STOCK_ID),
				SPECT_MAIN.SPECT_MAIN_ID
			FROM 
				SPECT_MAIN,SPECT_MAIN_ROW
			WHERE
				SPECT_MAIN.SPECT_MAIN_ID=SPECT_MAIN_ROW.SPECT_MAIN_ID
				AND SPECT_MAIN.STOCK_ID=#evaluate("attributes.stock_id#i#")#
			GROUP BY 
				SPECT_MAIN.SPECT_MAIN_ID
			HAVING 
				COUNT(SPECT_MAIN.STOCK_ID)=#GET_TREE.RECORDCOUNT#
		</cfquery>
		<cfset spect_list_id=valuelist(GET_SPECT_ROW_COUNT.SPECT_MAIN_ID,',')>
		<cfif listlen(spect_list_id,',')>
			<cfset st=0>
			<cfquery name="GET_SPECT" datasource="#dsn3#">
				SELECT 
					COUNT(SPECT_MAIN_ROW.SPECT_MAIN_ROW_ID),
					SPECT_MAIN.SPECT_MAIN_ID,
					SPECT_MAIN.SPECT_MAIN_NAME
				FROM 
					SPECT_MAIN_ROW ,
					SPECT_MAIN
				WHERE
					SPECT_MAIN.SPECT_MAIN_ID IN (#spect_list_id#) AND
					SPECT_MAIN_ROW.SPECT_MAIN_ID=SPECT_MAIN.SPECT_MAIN_ID AND
					(
						<cfloop list="#form_stock_id_list#" index="stok">
							<cfset st=st+1>
							(
								SPECT_MAIN_ROW.STOCK_ID=#stok# 
								AND SPECT_MAIN_ROW.AMOUNT=#listgetat(form_amount_list,st,',')#
								AND SPECT_MAIN_ROW.IS_PROPERTY=0
								AND IS_SEVK=#listgetat(form_sevk_list,st,',')#
							) 
							<cfif listlen(form_stock_id_list) gt st>OR</cfif>
						</cfloop>
					)
				GROUP BY SPECT_MAIN.SPECT_MAIN_ID,SPECT_MAIN.SPECT_MAIN_NAME
				HAVING COUNT(SPECT_MAIN_ROW.SPECT_MAIN_ROW_ID)=#GET_TREE.RECORDCOUNT#
			</cfquery>
		</cfif>
		<!--- AGACA UYGUN MASTER SPEC YOKSA MASTER SPEC KAYDI YAPILIYOR--->
		<cfif not isdefined('GET_SPECT.SPECT_MAIN_ID') or not len(GET_SPECT.SPECT_MAIN_ID)>
			<cfquery name="ADD_VAR_SPECT" datasource="#dsn3#">
				INSERT
				INTO
					SPECT_MAIN
					(
						SPECT_MAIN_NAME,
						SPECT_TYPE,
						PRODUCT_ID,
						STOCK_ID,
						IS_TREE,
						RECORD_IP,
						RECORD_EMP,
						RECORD_DATE
					)
					VALUES
					(
						'#wrk_eval("attributes.product_name#i#")#',
						1,
						#evaluate("attributes.product_id#i#")#,
						#evaluate("attributes.stock_id#i#")#,
						1,
						'#cgi.remote_addr#',
						#session.ep.userid#,
						#now()#
					)
			</cfquery>
			<cfquery name="GET_MAX_ID" datasource="#dsn3#">
				SELECT MAX(SPECT_MAIN_ID) AS MAX_ID FROM SPECT_MAIN
			</cfquery>
			<cfset attributes.main_spect_id=get_max_id.max_id>
	
			<cfloop query="GET_TREE">
				<cfquery name="GET_PROD_ID" dbtype="query">
					SELECT PRODUCT_ID,PRODUCT_NAME,PROPERTY FROM GET_PROD_ID_ALL WHERE STOCK_ID=#GET_TREE.RELATED_ID#
				</cfquery>
				<cfquery name="ADD_ROW" datasource="#dsn3#">
					INSERT
					INTO
						SPECT_MAIN_ROW
						(
							SPECT_MAIN_ID,
							PRODUCT_ID,
							STOCK_ID,
							AMOUNT,
							PRODUCT_NAME,
							IS_PROPERTY,
							IS_CONFIGURE,
							IS_SEVK
						)
						VALUES
						(
							#attributes.main_spect_id#,
							<cfif isdefined('GET_PROD_ID.PRODUCT_ID') and len(GET_PROD_ID.PRODUCT_ID)>#GET_PROD_ID.PRODUCT_ID#<cfelse>NULL</cfif>,
							#GET_TREE.RELATED_ID#,
							<cfif len(GET_TREE.AMOUNT)>#GET_TREE.AMOUNT#<cfelse>0</cfif>,
							<cfif len(GET_PROD_ID.PRODUCT_NAME)>'#GET_PROD_ID.PRODUCT_NAME#'<cfelse>NULL</cfif>,
							0,
							<cfif GET_TREE.IS_CONFIGURE eq 1>1<cfelse>0</cfif>,
							<cfif GET_TREE.IS_SEVK eq 1>1<cfelse>0</cfif>
						)
				</cfquery>
			</cfloop>
			<!--- //AGACA UYGUN MASTER SPEC YOKSA MASTER SPEC KAYDI YAPILIYOR--->
		<cfelse>
			<cfset attributes.main_spect_id=GET_SPECT.SPECT_MAIN_ID>
			<cfquery name="GET_PROD_ID_ALL" datasource="#DSN3#">
				SELECT 
					SMR.PRODUCT_ID,
					SMR.STOCK_ID,
					SMR.PRODUCT_NAME
				FROM 
					SPECT_MAIN_ROW SMR
				WHERE 
					SMR.SPECT_MAIN_ID = #attributes.main_spect_id#
			</cfquery>
		</cfif>
		
		<cfset product_id_list=valuelist(GET_PROD_ID_ALL.PRODUCT_ID,',')><!--- AGAC VEYA MASTER SPECTEKI TUM URUNLERIN PRODUCT_ID ALIYORUZ--->
		<cfset product_id_list=ListAppend(product_id_list,evaluate("attributes.product_id#i#"),',')>
		<!--- uyenin fiyat listesini bulmak icin--->
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
		</cfif>
		<cfif isdefined("attributes.consumer_id") and len(attributes.consumer_id)>
			<cfquery name="GET_COMP_CAT" datasource="#DSN3#">
				SELECT CONSUMER_CAT_ID FROM #dsn_alias#.CONSUMER WHERE CONSUMER_ID = #attributes.consumer_id#
			</cfquery>
			<cfquery name="GET_PRICE_CAT" datasource="#DSN3#">
				SELECT PRICE_CATID FROM PRICE_CAT WHERE CONSUMER_CAT LIKE '%,#get_comp_cat.consumer_cat_id#,%'
			</cfquery>
			<cfset attributes.price_catid=get_price_cat.PRICE_CATID>
		</cfif>
		<!--- //uyenin fiyat listesini bulmak icin--->
		
		<cfif isdefined("attributes.price_catid") and len(attributes.price_catid)>
			<cfquery name="GET_PRICE" datasource="#dsn3#">
				SELECT
					PRICE_STANDART.PRODUCT_ID,
					PRICE_STANDART.MONEY,
					PRICE_STANDART.PRICE
				FROM
					PRICE PRICE_STANDART,	
					PRODUCT_UNIT
				WHERE
					PRICE_STANDART.PRICE_CATID=#attributes.price_catid# AND
					PRICE_STANDART.STARTDATE< #action_spect_date# AND 
					(PRICE_STANDART.FINISHDATE >= #action_spect_date# OR PRICE_STANDART.FINISHDATE IS NULL) AND
					PRODUCT_UNIT.PRODUCT_ID = PRICE_STANDART.PRODUCT_ID AND 
					PRICE_STANDART.PRODUCT_ID IN (#product_id_list#) AND 
					PRODUCT_UNIT.IS_MAIN = 1
			</cfquery>
		</cfif>
		<cfquery name="GET_PRICE_STANDART" datasource="#dsn3#">
			SELECT
				PRICE_STANDART.PRODUCT_ID,
				PRICE_STANDART.MONEY,
				PRICE_STANDART.PRICE
			FROM
				PRODUCT,
				PRICE_STANDART
			WHERE
				PRODUCT.PRODUCT_ID = PRICE_STANDART.PRODUCT_ID AND
				PURCHASESALES = 1 AND
				PRICESTANDART_STATUS = 1 AND
				PRODUCT.PRODUCT_ID IN (#product_id_list#)
		</cfquery>
		<!--- //tum sayfadaki urunler icin fiyatları aliyor sonra query of query ile cekecek--->
		
		<cfquery name="GET_MAIN_SPECT" datasource="#DSN3#">
			SELECT 
				SPECT_MAIN.SPECT_MAIN_NAME,
				SPECT_MAIN.SPECT_TYPE,
				SPECT_MAIN.STOCK_ID MAIN_STOCK_ID,
				SPECT_MAIN.PRODUCT_ID MAIN_PRODUCT_ID,
				SPECT_MAIN.IS_TREE,
				SPECT_MAIN_ROW.* 
			FROM 
				SPECT_MAIN,
				SPECT_MAIN_ROW
			WHERE
				SPECT_MAIN.SPECT_MAIN_ID=#attributes.main_spect_id#
				AND SPECT_MAIN.SPECT_MAIN_ID=SPECT_MAIN_ROW.SPECT_MAIN_ID
		</cfquery>
	
			<cfif isdefined("attributes.price_catid") and len(attributes.price_catid)>
				<cfquery name="GET_PRICE_MAIN_PROD" dbtype="query">
					SELECT
						*
					FROM
						GET_PRICE
					WHERE
						PRODUCT_ID=#GET_MAIN_SPECT.MAIN_PRODUCT_ID#
				  </cfquery>
			</cfif>
			<cfif not isdefined("GET_PRICE_MAIN_PROD") or GET_PRICE_MAIN_PROD.RECORDCOUNT eq 0>
				<cfquery name="GET_PRICE_MAIN_PROD" dbtype="query">
	
					SELECT
						*
					FROM
						GET_PRICE_STANDART
					WHERE
						PRODUCT_ID=#GET_MAIN_SPECT.MAIN_PRODUCT_ID#
				</cfquery>
			</cfif>
			<cfquery name="ADD_VAR_SPECT" datasource="#dsn3#">
				INSERT
				INTO
					SPECTS
					(
						SPECT_MAIN_ID,
						SPECT_VAR_NAME,
						SPECT_TYPE,
						PRODUCT_ID,
						STOCK_ID,
						<!---TOTAL_AMOUNT,
						 OTHER_MONEY_CURRENCY,
						OTHER_TOTAL_AMOUNT, --->
						PRODUCT_AMOUNT,
						PRODUCT_AMOUNT_CURRENCY,
						IS_TREE,
						RECORD_IP,
						RECORD_EMP,
						RECORD_DATE
					)
					VALUES
					(
						#attributes.main_spect_id#,
						'#GET_MAIN_SPECT.SPECT_MAIN_NAME#',
						#GET_MAIN_SPECT.SPECT_TYPE#,
						#GET_MAIN_SPECT.MAIN_PRODUCT_ID#,
						#GET_MAIN_SPECT.MAIN_STOCK_ID#,
						<!--- <cfif len(GET_PRICE_MAIN_PROD.PRICE)>#GET_PRICE_MAIN_PROD.PRICE#,<cfelse>0,</cfif>
						'#GET_PRICE_MAIN_PROD.MONEY#', 
						<cfif len(attributes.other_toplam)>#attributes.other_toplam#,<cfelse>0,</cfif>--->
						<cfif len(GET_PRICE_MAIN_PROD.PRICE)>#GET_PRICE_MAIN_PROD.PRICE#,<cfelse>0,</cfif>
						<cfif len(GET_PRICE_MAIN_PROD.MONEY)>'#GET_PRICE_MAIN_PROD.MONEY#',<cfelse>'#session.ep.money#',</cfif>
						<cfif len(GET_MAIN_SPECT.IS_TREE)>#GET_MAIN_SPECT.IS_TREE#<cfelse>0</cfif>,
						'#cgi.remote_addr#',
						#session.ep.userid#,
						#now()#
					)
			</cfquery>
			<cfquery name="GET_MAX_ID" datasource="#dsn3#">
				SELECT MAX(SPECT_VAR_ID) AS MAX_ID FROM SPECTS
			</cfquery>
			<cfset max_spect_id=GET_MAX_ID.MAX_ID>
			<cfloop from="1" to="#attributes.kur_say#" index="fnc_i">
				<cfquery name="add_money_spec" datasource="#dsn3#">
					INSERT INTO SPECT_MONEY
					(
						ACTION_ID,
						MONEY_TYPE,
						RATE2,
						RATE1,
						IS_SELECTED
					)
					VALUES
					(
						#max_spect_id#,
						'#wrk_eval("attributes.hidden_rd_money_#fnc_i#")#',
						#evaluate("attributes.txt_rate2_#fnc_i#")#,
						#evaluate("attributes.txt_rate1_#fnc_i#")#,
					<cfif evaluate("attributes.hidden_rd_money_#fnc_i#") is attributes.BASKET_MONEY>
						1
					<cfelse>
						0
					</cfif>					
					)
				</cfquery>
			</cfloop>
			<cfquery name="GET_MONEY" datasource="#dsn3#">
				SELECT * FROM SPECT_MONEY WHERE ACTION_ID=#max_spect_id#
			</cfquery>
			<cfset toplam_spect_tutar=0>
			<cfset toplam_spect_maliyet=0>
				<cfloop query="GET_MAIN_SPECT">
					<cfif isdefined("attributes.price_catid") and len(attributes.price_catid)>
						<cfquery name="GET_PRICE_PROD" dbtype="query">
							SELECT
								*
							FROM
								GET_PRICE
							WHERE
								PRODUCT_ID=#GET_MAIN_SPECT.PRODUCT_ID#
						  </cfquery>
					</cfif>
					<cfif not isdefined("GET_PRICE_PROD") or GET_PRICE_PROD.RECORDCOUNT eq 0>
						<cfquery name="GET_PRICE_PROD" dbtype="query">
							SELECT
								*
							FROM
								GET_PRICE_STANDART
							WHERE
								PRODUCT_ID=#GET_MAIN_SPECT.PRODUCT_ID#
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
							PRODUCT_ID = #GET_MAIN_SPECT.PRODUCT_ID# AND
							START_DATE <= #action_spect_date#
						ORDER BY
							START_DATE DESC,
							RECORD_DATE DESC
					</cfquery>
					<cfif len(GET_COST.PRODUCT_COST)><cfset satir_maliyet=GET_COST.PRODUCT_COST><cfelse><cfset satir_maliyet=0></cfif>
					<cfquery name="ADD_ROW" datasource="#dsn3#">
						INSERT
						INTO
							SPECTS_ROW
							(
								SPECT_ID,
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
								IS_SEVK
							)
							VALUES
							(
								#max_spect_id#,
								<cfif len(GET_MAIN_SPECT.PRODUCT_ID)>#GET_MAIN_SPECT.PRODUCT_ID#<cfelse>NULL</cfif>,
								<cfif len(GET_MAIN_SPECT.STOCK_ID)>#GET_MAIN_SPECT.STOCK_ID#<cfelse>NULL</cfif>,
								<cfif len(GET_MAIN_SPECT.AMOUNT)>#GET_MAIN_SPECT.AMOUNT#<cfelse>0</cfif>,
								<cfif len(GET_PRICE_PROD.PRICE)>#GET_PRICE_PROD.PRICE#<cfelse>0</cfif>,
								'#GET_PRICE_PROD.MONEY#',
								<cfif len(GET_MAIN_SPECT.PRODUCT_NAME)>'#GET_MAIN_SPECT.PRODUCT_NAME#'<cfelse>NULL</cfif>,
								<cfif GET_MAIN_SPECT.IS_PROPERTY eq 1>1<cfelse>0</cfif>,
								<cfif GET_MAIN_SPECT.IS_CONFIGURE eq 1>1<cfelse>0</cfif>,
								0,
								#satir_maliyet#,
								<cfif len(GET_COST.MONEY)>'#GET_COST.MONEY#'<cfelse>NULL</cfif>,
								<cfif len(GET_COST.PRODUCT_COST_ID)>#GET_COST.PRODUCT_COST_ID#<cfelse>NULL</cfif>,
								<cfif GET_MAIN_SPECT.IS_SEVK eq 1>1<cfelse>0</cfif>
							)
					</cfquery>
					<cfset GET_PRICE_PROD.RECORDCOUNT=0>
					
					<cfif len(GET_COST.MONEY) and GET_PRICE_MAIN_PROD.MONEY neq GET_COST.MONEY>
						<!--- ana urun fiyatla satir maliyet para birimi farkli ise once ana para birimine ordanda ana urun fiyat cinsine cevirir--->
						<cfquery name="GET_ROW_MONEY_COST" dbtype="query">
							SELECT	MONEY_TYPE,RATE2 RATE FROM GET_MONEY WHERE MONEY_TYPE='#GET_COST.MONEY#'
						</cfquery>
						<cfset satir_maliyet=satir_maliyet*GET_ROW_MONEY_COST.RATE>
						<cfif GET_PRICE_MAIN_PROD.MONEY neq session.ep.money>
							<cfquery name="GET_ROW_MONEY_COST_2" dbtype="query">
								SELECT	MONEY_TYPE,RATE2 RATE FROM GET_MONEY WHERE MONEY_TYPE='#GET_PRICE_MAIN_PROD.MONEY#'
							</cfquery>
							<cfif GET_ROW_MONEY_COST_2.RECORDCOUNT>
								<cfset satir_maliyet=satir_maliyet/GET_ROW_MONEY_COST_2.RATE>
							</cfif>
						</cfif>
					</cfif>
					<cfif GET_MAIN_SPECT.AMOUNT gt 1>
						<cfset satir_maliyet=satir_maliyet*GET_MAIN_SPECT.AMOUNT>
					</cfif>
					<cfset toplam_spect_maliyet=toplam_spect_maliyet+satir_maliyet>

					<cfset satir_urun_tutar=0>
					<cfif len(GET_PRICE_PROD.PRICE)>
						<cfset satir_urun_tutar=GET_PRICE_PROD.PRICE>
						<cfif GET_PRICE_MAIN_PROD.MONEY neq GET_PRICE_PROD.MONEY>
						<!--- ana urun fiyatla satir fiyat birimi farkli ise once ana para birimine ordanda ana urun fiyat cinsine cevirir--->
							<cfquery name="GET_ROW_MONEY" dbtype="query">
								SELECT	MONEY_TYPE, RATE2 RATE FROM GET_MONEY WHERE MONEY_TYPE='#GET_PRICE_PROD.MONEY#'
							</cfquery>
							<cfif GET_ROW_MONEY.RECORDCOUNT and len(GET_ROW_MONEY.RATE)>
								<cfset satir_urun_tutar=GET_PRICE_PROD.PRICE*GET_ROW_MONEY.RATE>
							</cfif>
							<cfquery name="GET_ROW_MONEY_2" dbtype="query">
								SELECT	MONEY_TYPE,RATE2 RATE FROM GET_MONEY WHERE MONEY_TYPE='#GET_PRICE_MAIN_PROD.MONEY#'
							</cfquery>
							<cfif GET_ROW_MONEY_2.RECORDCOUNT>
								<cfset satir_urun_tutar=satir_urun_tutar/GET_ROW_MONEY_2.RATE>
							</cfif>
						</cfif>
						<cfif GET_MAIN_SPECT.AMOUNT gt 1>
							<cfset satir_urun_tutar=satir_urun_tutar*GET_MAIN_SPECT.AMOUNT>
						</cfif>
						<cfset toplam_spect_tutar=toplam_spect_tutar+satir_urun_tutar>
					</cfif>
			</cfloop>
			<cfset toplam_spect_tutar_ep_money=0>
			<cfif GET_PRICE_MAIN_PROD.MONEY neq session.ep.money>
				<cfquery name="GET_ROW_MONEY_TOTAL" dbtype="query">
					SELECT	MONEY_TYPE,RATE2 RATE FROM GET_MONEY WHERE MONEY_TYPE='#GET_PRICE_MAIN_PROD.MONEY#'
				</cfquery>
				<cfif GET_ROW_MONEY_TOTAL.RECORDCOUNT>
					<cfset toplam_spect_tutar_ep_money=toplam_spect_tutar*GET_ROW_MONEY_TOTAL.RATE>
				</cfif>
			<cfelse>
				<cfset toplam_spect_tutar_ep_money=toplam_spect_tutar>
			</cfif>
			
			<cfquery name="UPD_SPEC_COST" datasource="#dsn3#">
				UPDATE 
					SPECTS 
				SET 
					SPECT_COST=#toplam_spect_maliyet#,
					SPECT_COST_CURRENCY=<cfif len(GET_PRICE_MAIN_PROD.MONEY)>'#GET_PRICE_MAIN_PROD.MONEY#'<cfelse>'#session.ep.money#'</cfif>,
					OTHER_MONEY_CURRENCY=<cfif len(GET_PRICE_MAIN_PROD.MONEY)>'#GET_PRICE_MAIN_PROD.MONEY#'<cfelse>'#session.ep.money#'</cfif>,
					OTHER_TOTAL_AMOUNT=#toplam_spect_tutar#, 
					TOTAL_AMOUNT=#toplam_spect_tutar_ep_money#
				WHERE 
					SPECT_VAR_ID=#max_spect_id#
			</cfquery>
	</cfif>
	<cfif isdefined('max_spect_id') and len(max_spect_id)>
		<cfset 'attributes.spect_id#i#'=max_spect_id>
		<cfif len(GET_MAIN_SPECT.SPECT_MAIN_NAME)>
			<cfset 'attributes.spect_name#i#'=GET_MAIN_SPECT.SPECT_MAIN_NAME>
		<cfelse>
			<cfset 'attributes.spect_name#i#'=evaluate("attributes.product_name#i#")>
		</cfif>
	</cfif>
</cfif> --->
