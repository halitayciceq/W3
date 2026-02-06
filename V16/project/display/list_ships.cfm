<cf_xml_page_edit fuseact="#fusebox.circuit#.popup_list_project_actions">
<cfparam name="attributes.page" default="1">
<cfparam name="attributes.maxrows" default="#session.ep.maxrows#">
<cfparam name="attributes.order_type" default="date_desc">
<cfset attributes.startrow = ((attributes.page-1)*attributes.maxrows) + 1>
<cfparam name="attributes.line_based" default="1">
<cfparam name="attributes.purchase_sales" default="1">
<cfparam name="attributes.action_status" default=""><!--- aktif --->
<cfscript>
	var_inv_row_check_ = 'inv_row_check_#attributes.purchase_sales#_ships';
	var_price_ = 'price__#attributes.purchase_sales#_ships';
	var___price_ = '__price__#attributes.purchase_sales#_ships';
	var_marj_ = 'marj__#attributes.purchase_sales#_ships';
	var_row_amount_ = 'row_amount__#attributes.purchase_sales#_ships';
	var_all_select_function = 'allSelect_#attributes.purchase_sales#_ships';
	var_calc_marj_function = 'calc_marj_#attributes.purchase_sales#_ships';
</cfscript>
<cfsetting showdebugoutput="no">
<!--- İrsaliyeler--->	
<cfquery name="get_purchases_ship" datasource="#action_dsn2#">
WITH CTE1 AS (
    SELECT
        SH.PURCHASE_SALES,
        SH.SHIP_ID,
        SH.SHIP_NUMBER,
        SH.SHIP_TYPE,
        SH.SHIP_DATE,
        SH.COMPANY_ID,
        SH.CONSUMER_ID,
        SH.DELIVER_DATE,
        SH.PARTNER_ID,
        SH.DEPARTMENT_IN,
        SH.OTHER_MONEY,
        SH.OTHER_MONEY_VALUE,
        SH.LOCATION_IN,
        SH.DELIVER_STORE_ID,
        SH.LOCATION,
        SH.NETTOTAL TUTAR, 
        SH.RECORD_DATE,
        SH.RECORD_EMP,
        SH.SUBSCRIPTION_ID
        <cfif attributes.line_based eq 1>
			<cfif attributes.purchase_sales eq 1>
                ,S.TAX
            <cfelse>
               , S.TAX_PURCHASE AS TAX
            </cfif>
            ,(SR.COST_PRICE+SR.EXTRA_COST) COST
            ,SR.COST_PRICE
            ,SR.EXTRA_COST
            ,S.PRODUCT_NAME
            ,0 AS MARGIN
            ,S.STOCK_CODE
            ,S.BARCOD
            ,S.IS_INVENTORY
            ,S.IS_PRODUCTION 
            ,S.MANUFACT_CODE
            ,SR.DISCOUNT_COST
            ,SR.OTV_ORAN
            ,SR.UNIT_ID
            ,SR.SPECT_VAR_NAME
            ,SR.STOCK_ID
            ,SR.AMOUNT
            ,SR.UNIT
            ,SR.PRICE_OTHER
            ,SR.OTHER_MONEY ROW_OTHER_MONEY
            ,SR.OTHER_MONEY_VALUE ROW_OTHER_MONEY_VALUE
            ,SR.SPECT_VAR_ID
            ,SR.WRK_ROW_ID
            ,SR.SHIP_ROW_ID
            ,SR.PRODUCT_ID
            ,SR.PRODUCT_NAME2
        </cfif>
    FROM
        SHIP SH
        <cfif attributes.line_based eq 1>
		,#dsn3_alias#.STOCKS S
        ,SHIP_ROW SR
		</cfif> 
    WHERE
    	<cfif attributes.line_based eq 1>
			SR.SHIP_ID = SH.SHIP_ID AND
            SR.STOCK_ID = S.STOCK_ID AND
			<!--- Daha önceden belgeye çekilen ürünler bir daha gelmesin! --->
             WRK_ROW_ID NOT IN (
                SELECT 
                    A5.FROM_WRK_ROW_ID FROM 
                    (SELECT 
                        SUM(RELATION_ROW.TO_AMOUNT) AS AMOUNT_OTHER,
                        FROM_WRK_ROW_ID 
                    FROM 
                       #dsn3_alias#.RELATION_ROW
                    WHERE
                        FROM_ACTION_ID = SR.SHIP_ID AND 
                        TO_TABLE ='#attributes.from_paper#' GROUP BY FROM_WRK_ROW_ID ) AS A5
                WHERE
                    A5.FROM_WRK_ROW_ID=SR.WRK_ROW_ID
                    AND (SR.AMOUNT-A5.AMOUNT_OTHER)<=0
            ) AND
            <!--- // Daha önceden belgeye çekilen ürünler bir daha gelmesin! --->
		</cfif>
        SH.PURCHASE_SALES= #attributes.purchase_sales# AND
		<cfif isdefined("attributes.is_from_product")><!--- urun detayindan geliyorsa --->
			<cfif attributes.line_based eq 1>
			SR.PRODUCT_ID= <cfqueryparam cfsqltype="cf_sql_integer" value="#URL.ID#"> AND
			<cfelse>
			(SELECT TOP 1 SR.PRODUCT_ID FROM  SHIP_ROW SR WHERE SR.SHIP_ID = SH.SHIP_ID AND SR.PRODUCT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.id#">) IS NOT NULL AND
			</cfif>
        <cfelseif isdefined("attributes.is_from_sales")><!--- abone detayindan geliyorsa --->    
			SH.SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#URL.ID#"> AND
		<cfelse>
        	<cfif attributes.line_based eq 1>
            ISNULL(SR.ROW_PROJECT_ID,SH.PROJECT_ID) = <cfqueryparam cfsqltype="cf_sql_integer" value="#URL.ID#"> AND
            <cfelse>
			SH.PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#URL.ID#"> AND
            </cfif>
		</cfif> 
        <cfif isdefined("attributes.action_status") and attributes.action_status eq 1>
             SH.IS_SHIP_IPTAL = 0 AND 
        <cfelseif isdefined("attributes.action_status") and attributes.action_status eq 0>
             SH.IS_SHIP_IPTAL = 1  AND
        </cfif>
        SH.SHIP_TYPE <> 811 
        
	   
         ),
       CTE2 AS (
            SELECT
                CTE1.*,
                ROW_NUMBER() OVER ( ORDER BY 
				<cfswitch expression = "#attributes.order_type#">
					<cfcase value="date_desc">
						SHIP_DATE DESC
					</cfcase>
					<cfcase value="date_asc">
						SHIP_DATE ASC
					</cfcase>
					<cfcase value="paperno_desc">
						SHIP_NUMBER DESC
					</cfcase>
					<cfcase value="paperno_asc">
						SHIP_NUMBER ASC
					</cfcase>
				</cfswitch>
                                ) AS RowNum,(SELECT COUNT(*) FROM CTE1) AS QUERY_COUNT
            FROM
                CTE1
        )
        SELECT
            CTE2.*
        FROM
            CTE2
        WHERE
            RowNum BETWEEN #attributes.startrow# AND #attributes.startrow#+(#attributes.maxrows#-1)
        ORDER BY
            RowNum
</cfquery>
<cfif get_purchases_ship.recordcount>
    <cfparam name="attributes.totalrecords" default="#get_purchases_ship.query_count#">
<cfelse>
    <cfparam name="attributes.totalrecords" default="0">
</cfif>
<cfset company_id_list=''>
<cfset consumer_id_list=''>
<cfif attributes.line_based neq 1>
	<cfif get_purchases_ship.recordcount>
		<cfoutput query="get_purchases_ship">
            <cfif len(company_id) and not listFindnocase(company_id_list,company_id)>
                <cfset company_id_list = listappend(company_id_list,company_id)>
            </cfif>
            <cfif len(consumer_id) and not listFindnocase(consumer_id_list,consumer_id)>
                <cfset consumer_id_list = listappend(consumer_id_list,consumer_id)>
            </cfif>
        </cfoutput>
        <cfif listlen(company_id_list)>
            <cfset company_id_list=listsort(company_id_list,"numeric","ASC",",")>
            <cfquery name="COMPANY_NAME" datasource="#dsn#">
                SELECT
                    NICKNAME,
                    COMPANY_ID,
                    FULLNAME
                FROM
                    COMPANY
                WHERE
                    COMPANY_ID  IN (#company_id_list#)
                ORDER BY 
                    COMPANY_ID	
            </cfquery>
        </cfif>	
        <cfif listlen(consumer_id_list)>
            <cfset consumer_id_list=listsort(consumer_id_list,"numeric","ASC",",")>
            <cfquery name="CONS_NAME" datasource="#dsn#">
              SELECT 
                  CONSUMER_NAME,
                  CONSUMER_SURNAME, 
                  COMPANY,						  
                  CONSUMER_ID 
              FROM 
                  CONSUMER 
              WHERE 
                  CONSUMER_ID IN (#consumer_id_list#)
              ORDER BY
                  CONSUMER_ID	  
            </cfquery>	
        </cfif>
	</cfif>
<cfelse>
	<cfset ship_id_list = listdeleteduplicates(ValueList(get_purchases_ship.SHIP_ID,','))>
    <cfif len(ship_id_list)>
       <cfquery name="GET_ALL_USED_AMOUNT" datasource="#DSN3#">
		SELECT
			SUM(AMOUNT) AMOUNT,
			PRODUCT_ID,
			WRK_ROW_ID
		FROM
		(
			<!--- Fatura / Fatura --->
			SELECT
				SUM(SR.AMOUNT) AMOUNT,
				SR.PRODUCT_ID,
				SR.WRK_ROW_ID
			FROM
				#dsn2_alias#.SHIP_ROW SR
			WHERE
				SR.SHIP_ID IN (SELECT SHIP.SHIP_ID FROM #dsn2_alias#.SHIP SHIP WHERE SHIP.SHIP_ID = SR.SHIP_ID AND SHIP.SHIP_ID IN (#ship_id_list#)) 
			GROUP BY
				SR.PRODUCT_ID,
				SR.WRK_ROW_ID
		
		UNION
			<!--- Fatura / Siparis / Fatura --->
			SELECT
				SUM(SR.AMOUNT) AMOUNT,
				SR.PRODUCT_ID,
				SR.WRK_ROW_ID
			FROM				
				ORDERS_SHIP OI,
				#dsn2_alias#.SHIP_ROW SR
			WHERE
				OI.SHIP_ID = SR.SHIP_ID AND
				SR.SHIP_ID IN (SELECT SHIP.SHIP_ID FROM #dsn2_alias#.SHIP SHIP WHERE SHIP.SHIP_ID = SR.SHIP_ID AND SHIP.SHIP_ID IN (#ship_id_list#))
			GROUP BY
				SR.PRODUCT_ID,
				SR.WRK_ROW_ID
		UNION
			<!--- Fatura / Siparis / SRsaliye / Fatura --->
			SELECT
				SUM(SR.AMOUNT) AMOUNT,
				SR.PRODUCT_ID,
				SR.WRK_ROW_ID
			FROM
				ORDERS_SHIP OSH,
				#dsn2_alias#.SHIP_ROW SHR,
				#dsn2_alias#.INVOICE_SHIPS ISH,
				#dsn2_alias#.SHIP_ROW SR
			WHERE
				OSH.PERIOD_ID = #session.ep.period_id# AND
				OSH.SHIP_ID = SHR.SHIP_ID AND
				OSH.SHIP_ID = ISH.SHIP_ID AND
				ISH.SHIP_ID = SR.SHIP_ID AND
				SHR.WRK_ROW_ID = SR.WRK_ROW_RELATION_ID AND
				SR.SHIP_ID IN (SELECT SHIP.SHIP_ID FROM #dsn2_alias#.SHIP SHIP WHERE SHIP.SHIP_ID = SR.SHIP_ID AND SHIP.SHIP_ID IN (#ship_id_list#))
			GROUP BY
				SR.PRODUCT_ID,
				SR.WRK_ROW_ID
		) MAIN_QUERY
		GROUP BY
			PRODUCT_ID,
			WRK_ROW_ID
			ORDER BY
			WRK_ROW_ID
    </cfquery>
        <cfif GET_ALL_USED_AMOUNT.recordcount>
            <cfscript>
                for(uai=1;uai lte GET_ALL_USED_AMOUNT.recordcount; uai=uai+1)
                    'used_amount_#replace(GET_ALL_USED_AMOUNT.WRK_ROW_ID[uai],"-","_","ALL")#'=GET_ALL_USED_AMOUNT.AMOUNT[uai];//kullanılan miktarları benzersiz wrk_row_id'ye göre belirledik.
            </cfscript>
        </cfif>
    </cfif>
    <cfset stock_id_list = ValueList(get_purchases_ship.STOCK_ID,',')>
    <cfif len(stock_id_list)>
        <cfquery name="get_project_mat_plan" datasource="#dsn#">
             SELECT 
                PMR.PRICE,
                PMR.STOCK_ID
            FROM 
                PRO_MATERIAL PM,
                PRO_MATERIAL_ROW PMR
            WHERE
            PM.PRO_MATERIAL_ID = PMR.PRO_MATERIAL_ID AND
            PM.PROJECT_ID = #url.id#  
        </cfquery>
        <cfif get_project_mat_plan.recordcount>
            <cfscript>
                for(pmi=1;pmi lte get_project_mat_plan.recordcount; pmi = pmi+1)
                    if(not isdefined('project_plan_price#get_project_mat_plan.STOCK_ID[pmi]#'))
                        'project_plan_price#get_project_mat_plan.STOCK_ID[pmi]#' = get_project_mat_plan.PRICE[pmi];
            </cfscript>
        </cfif>
    </cfif>
</cfif>	
<cfif attributes.purchase_sales eq 0>
	<cfset fuse_action_add = "stock.form_add_purchase">
	<cfset fuse_action_upd = "stock.form_add_purchase&event=upd">
<cfelse>
	<cfset fuse_action_add = "stock.form_add_sale">
	<cfset fuse_action_upd = "stock.form_add_sale&event=upd">
</cfif>
<cfif attributes.purchase_sales eq 0><cfset div_id = 'div_purchase_ships'><cfelse><cfset div_id = 'div_sale_ships'></cfif>
<div id="<cfoutput>#div_id#</cfoutput>">
<cf_grid_list>
	<thead>
		<tr>
        	<th width="30"><cf_get_lang dictionary_id='57487.No'></th>
            <th width="70"><cf_get_lang dictionary_id='57880.Belge No'></th>
            <cfif attributes.line_based neq 1>
                <th width="120"><cf_get_lang dictionary_id='58533.Belge Tipi'></th>
                <th width="170"><cf_get_lang dictionary_id='57519.Cari Hesap'></th>
                <th width="100"><cf_get_lang dictionary_id="57627.Kayıt Tarihi"></th>
                <th width="100"><cf_get_lang dictionary_id='38422.Sevk Tarihi'></th>
                <th align="right" width="60"><cf_get_lang dictionary_id='57673.Tutar'></th>
                <th width="15"><cf_get_lang dictionary_id="58864.Para Br"></th>
                <cfif xml_exchange_amount eq 1>
                <th width="75"><cf_get_lang dictionary_id="57677.Dövizli"> <cf_get_lang dictionary_id='57673.Tutar'></th>
                <th width="15"><cf_get_lang dictionary_id="58864.Para Br"></th>
                </cfif>
                <th width="100"><cf_get_lang dictionary_id='29428.Çıkış Depo'></th>
                <th width="100"><cf_get_lang dictionary_id='38450.Giriş Depo'></th>
                <th width="85"><cf_get_lang dictionary_id='57899.Kaydeden'></th>
            <cfelse>
                <th width="70"><cf_get_lang dictionary_id='57518.Stok Kodu'></th>
                <th><cf_get_lang dictionary_id='57657.Ürün'></th>
                <th><cf_get_lang dictionary_id='57647.Spec'></th> 
                <th style="text-align:right;" ><cf_get_lang dictionary_id='57635.Miktar'></th> 
                <th><cf_get_lang dictionary_id='57636.Birim'></th> 
                <th><cf_get_lang dictionary_id='57629.Açıklama'> 2</th> 
                <cfif session.ep.price_display_valid eq 0>
                    <th style="text-align:right;"><cf_get_lang dictionary_id='58123.Planlama'> <cf_get_lang dictionary_id='58084.Fiyat'></th> 
                </cfif>
                <cfif session.ep.cost_display_valid eq 0>
                    <th style="text-align:right;"><cf_get_lang dictionary_id='58258.Maliyet'></th>
                </cfif>
                <cfif session.ep.price_display_valid eq 0>
                    <th style="text-align:right;"><cf_get_lang dictionary_id='58084.Fiyat'></th> 
                    <th width="85"><cf_get_lang dictionary_id='57489.Para Br.'></th>
                </cfif>
                <th width="75" style="text-align:right;"><cf_get_lang dictionary_id="38194.Fatura Edilen"></th>
                <th width="120" style="text-align:right;"><cf_get_lang dictionary_id='58444.Kalan'></th>
                <th><cf_get_lang dictionary_id="38204.Marj"></th> 
                <cfif session.ep.price_display_valid eq 0>
                    <th style="text-align:right;"><cf_get_lang dictionary_id='57448.Satış'> <cf_get_lang dictionary_id='58084.Fiyat'></th> 
                </cfif>
                <cfif attributes.line_based eq 1 and isdefined("attributes.from_paper") and len(attributes.from_paper)>
                <th><input type="checkbox" name="all_select" id="all_select" onClick="<cfoutput>#var_all_select_function#</cfoutput>('select');"></th>
                </cfif>
            </cfif>
            <th width="20"><a href="<cfoutput>#request.self#?fuseaction=#fuse_action_add#&<cfif isdefined("attributes.is_from_sales")>subscription=#url.id#<cfelse>project_id=#url.id#</cfif></cfoutput>" target="_blank"><i class="fa fa-plus" title="<cf_get_lang dictionary_id='57582.Ekle'>"></i></a></th>
        </tr>
    </thead>
    <tbody>
	<cfif get_purchases_ship.recordcount>
		<cfoutput query="get_purchases_ship">
        <tr>
            <td>#rownum#</td>
            <td>
            	<cfif attributes.purchase_sales eq 1>
					<cfif get_module_user(13) and not listfindnocase(denied_pages,'stock.form_upd_sale')>
                         <a href="#request.self#?fuseaction=stock.form_add_sale&event=upd&ship_id=#ship_id#" target="_blank">#Ship_Number#</a>
                    <cfelse>
                         #Ship_Number#
                    </cfif>
                <cfelse>
                    <cfif get_module_user(13) and not listfindnocase(denied_pages,'stock.form_upd_purchase')>
                        <a href="#request.self#?fuseaction=stock.form_add_purchase&event=upd&ship_id=#ship_id#" target="_blank">#Ship_Number#</a>
                    <cfelse>
                        #Ship_Number#
                    </cfif>
                </cfif>
            	<!---<a href="#request.self#?fuseaction=objects.popup_detail_ship&ship_id=#ship_id#" target="_blank">#SHIP_NUMBER#</a>--->
            </td>
            <cfif attributes.line_based neq 1>
                <td>#get_process_name(SHIP_TYPE)#</td>
                <td>
                <cfif len(get_purchases_ship.company_id)>
                    <a href="javascript://" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_com_det&company_id=#company_id#','medium');">#COMPANY_NAME.fullname[listfind(company_id_list,company_id,',')]#</a>
                 <cfelseif len(get_purchases_ship.consumer_id)>
                        <a href="javascript://" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_con_det&con_id=#consumer_id#','medium');"> #CONS_NAME.consumer_name[listfind(consumer_id_list,consumer_id,',')]#</a>
                 </cfif>
                </td>
                <td><cfif len(SHIP_DATE)>#dateformat(SHIP_DATE, "dd/mm/yy")#</cfif></td>
                <td><cfif len(DELIVER_DATE)>#dateformat(DELIVER_DATE, "dd/mm/yy")#</cfif></td>
                <td style="text-align:right;">#TLFormat(TUTAR)#</td>
                <td>#session.ep.money#</td>
                <cfif xml_exchange_amount eq 1>
                <td><cfif len(OTHER_MONEY_VALUE)>#TLFormat(OTHER_MONEY_VALUE)#</cfif></td>
				<td>
                	<cfif len(OTHER_MONEY_VALUE)>
						<cfif session.ep.period_year gte 2009 and len(OTHER_MONEY) and OTHER_MONEY is 'YTL'>#session.ep.money#
                        <cfelseif session.ep.period_year lt 2009 and len(OTHER_MONEY) and OTHER_MONEY is 'TL'>#session.ep.money#
                        <cfelse>#OTHER_MONEY#</cfif>
                    </cfif>
                </td>
                </cfif>
                <td>
                <cfif len(DELIVER_STORE_ID)>
                    <cfset search_dep_id=get_purchases_ship.DELIVER_STORE_ID>
                       <cfquery name="GET_NAME_OF_DEP" datasource="#DSN#">
                            SELECT
                                DEPARTMENT_HEAD,
                                BRANCH_ID
                            FROM
                                DEPARTMENT
                            WHERE
                                DEPARTMENT_ID = #search_dep_id# AND 
                                IS_STORE <> 2
                        </cfquery>
                       <cfset txt_department_name=get_name_of_dep.department_head>
                       <cfset branch_id = get_name_of_dep.BRANCH_ID>
                        <cfif len(search_dep_id) and len(trim(get_purchases_ship.LOCATION))>
                          <cfset search_location_id = get_purchases_ship.LOCATION>
                            <cfquery name="get_location" datasource="#dsn#">
                                SELECT 
                                    COMMENT,
                                    DEPARTMENT_LOCATION 
                                FROM
                                    STOCKS_LOCATION 
                                WHERE 
                                    LOCATION_ID=#search_location_id# AND 
                                    DEPARTMENT_ID=#search_dep_id#
                            </cfquery>
                          <cfset txt_department_name = txt_department_name & "-" & get_location.comment>
                          <cfset txt_department_id = "#get_location.department_location#">
                        <cfelse>
                          <cfset txt_department_id="#search_dep_id#">
                        </cfif>
                        #txt_department_name#
                    <cfelse>&nbsp;</cfif>
                </td>
                <td>
                    <cfif len(DEPARTMENT_IN)>
                    <cfset search_dep_id2=get_purchases_ship.DEPARTMENT_IN>
                        <cfif len(get_purchases_ship.DEPARTMENT_IN) and isnumeric(get_purchases_ship.DEPARTMENT_IN)>
                          <cfquery name="GET_NAME_OF_DEP" datasource="#DSN#">
                                SELECT
                                    DEPARTMENT_HEAD,
                                    BRANCH_ID
                                FROM
                                    DEPARTMENT
                                WHERE
                                    DEPARTMENT_ID = #search_dep_id2#	AND 
                                    IS_STORE <> 2
                            </cfquery>
                          <cfset txt_department_name2=get_name_of_dep.department_head>
                          <cfset branch_id = get_name_of_dep.branch_id>
                          <cfif len(search_dep_id2) and len(trim(get_purchases_ship.LOCATION_IN))>
                            <cfset search_location_id2 = get_purchases_ship.LOCATION_IN>
                                <cfquery name="get_location" datasource="#dsn#">
                                    SELECT 
                                        COMMENT,
                                        DEPARTMENT_LOCATION 
                                    FROM
                                        STOCKS_LOCATION 
                                    WHERE 
                                        LOCATION_ID=#search_location_id2# AND 
                                        DEPARTMENT_ID=#search_dep_id2#
                                </cfquery>
                            <cfset txt_department_name2 = txt_department_name2 & "-" & get_location.comment>
                            <cfset txt_department_id2 = "#get_location.department_location#">
                          <cfelse>   
                            <cfset txt_department_id2="#search_dep_id#">
                          </cfif>		
                        <cfelse>
                          <cfset txt_department_name2 = "">
                          <cfset txt_department_id2 = "">
                        </cfif>
                        #txt_department_name2#
                        <cfelse>&nbsp;</cfif>
                </td>
                <td>#get_emp_info(record_emp,0,0)#</td>
            <cfelse>
                <cfset wrk_id=replace(WRK_ROW_ID,"-","_","ALL")>
                <cfif isdefined('used_amount_#wrk_id#') and len(Evaluate("used_amount_#wrk_id#"))>
                    <cfset kalan_miktar = AMOUNT - Evaluate("used_amount_#wrk_id#")>
                <cfelse>
                    <cfset kalan_miktar = AMOUNT>
                    <cfset 'used_amount_#wrk_id#' = 0 >
                </cfif>
                <cfif kalan_miktar lt 0><cfset kalan_miktar = 0></cfif>
                <td>#STOCK_CODE#</td>
                <td>#PRODUCT_NAME#</td>
                <td>#SPECT_VAR_ID#</td>
                <td style="text-align:right;">#tlformat(AMOUNT)#</td>
                <td>#UNIT#</td>
                <td>#PRODUCT_NAME2#</td>
                <cfif session.ep.price_display_valid eq 0>
                    <td style="text-align:right;"><cfif isdefined('project_plan_price#STOCK_ID#')>#tlformat(Evaluate('project_plan_price#STOCK_ID#'))# #session.ep.money#</cfif></td>
                </cfif>
                <cfif session.ep.cost_display_valid eq 0>
                    <td style="text-align:right;">#tlformat(COST)#</td>
                </cfif>
                <cfif session.ep.price_display_valid eq 0>
                    <td style="text-align:right;">#tlformat(PRICE_OTHER)#</td>
                    <td>#ROW_OTHER_MONEY#</td>
                </cfif>
                <td style="text-align:right;">#tlformat(Evaluate("used_amount_#wrk_id#"))#</td>
                <td><div class="form-group"><input type="text"  name="#var_row_amount_##SHIP_ROW_ID#" id="#var_row_amount_##SHIP_ROW_ID#" value="#tlformat(kalan_miktar)#" onKeyup="return(FormatCurrency(this,event,6));"  style="text-align:right;"></div></td>
                <td><div class="form-group"><input type="text" name="#var_marj_##SHIP_ROW_ID#" id="#var_marj_##SHIP_ROW_ID#"  style="width:35;"  onKeyup="return(FormatCurrency(this,event,6));" onBlur="#var_calc_marj_function#('marj',#SHIP_ROW_ID#);" value="100"  style="text-align:right;"></div></td>
                <cfif session.ep.price_display_valid eq 0>
                    <td>
                        <div class="form-group">
                            <input type="hidden"  name="#var___price_##SHIP_ROW_ID#" id="#var___price_##SHIP_ROW_ID#" value="#tlformat(PRICE_OTHER)#">
                            <input type="text"  name="#var_price_##SHIP_ROW_ID#" id="#var_price_##SHIP_ROW_ID#" value="#tlformat(PRICE_OTHER)#" onKeyup="return(FormatCurrency(this,event,6));" onBlur="#var_calc_marj_function#('price',#SHIP_ROW_ID#);"  style="text-align:right;">#session.ep.money#
                        </div>
                    </td>
                </cfif>
                <cfif attributes.line_based eq 1 and isdefined("attributes.from_paper") and len(attributes.from_paper)>
                <td><input type="checkbox" name="#var_inv_row_check_##SHIP_ROW_ID#" id="#var_inv_row_check_##SHIP_ROW_ID#" value="#SHIP_ROW_ID#"></td>
                </cfif>
            </cfif>
            <td><a href="#request.self#?fuseaction=#fuse_action_upd#&ship_id=#ship_id#" target="_blank"><i class="fa fa-pencil" title="<cf_get_lang dictionary_id='57464.Güncelle'>"></i></a></td>
        </tr>
        </cfoutput>
       
      <cfelse>
      <tr>
        <td colspan="21"><cf_get_lang dictionary_id='57484.Kayıt Bulunamadı'> !</td>
      </tr>
    </cfif>
    </tbody>
</cf_grid_list>
<cfif get_purchases_ship.recordcount>
    <cfif attributes.line_based eq 1 and isdefined("attributes.from_paper") and len(attributes.from_paper)>
        <div class="ui-info-bottom flex-end">
           <a href="javascript://" onClick="<cfoutput>#var_all_select_function#</cfoutput>('add_basket');" class="ui-btn ui-btn-success"><cf_get_lang dictionary_id='57582.Ekle'></a>
        </div>
    </cfif>
</cfif>
<cfset adres="project.popup_ajax_list_ships&action_status=#attributes.action_status#&id=#attributes.id#&line_based=#attributes.line_based#&purchase_sales=#attributes.purchase_sales#&action_dsn2=#attributes.action_dsn2#&maxrows=#attributes.maxrows#&order_type=#attributes.order_type#">
<cfif isdefined("attributes.from_paper")>
	<cfset adres = "#adres#&from_paper=#attributes.from_paper#">
</cfif>
<cfif isdefined("attributes.is_from_product")>
	<cfset adres = "#adres#&is_from_product=#attributes.is_from_product#">
</cfif>
<cfif isdefined("attributes.is_from_sales")>
	<cfset adres = "#adres#&is_from_sales=#attributes.is_from_sales#">
</cfif>
<cfif attributes.totalrecords gt attributes.maxrows>
	<cfif attributes.purchase_sales eq 0>
    <cf_paging
        name="purchase_ships"
        page="#attributes.page#" 
        maxrows="#attributes.maxrows#" 
        totalrecords="#attributes.totalrecords#" 
        startrow="#attributes.startrow#" 
        adres="#adres#"
        isAjax="1"
        target="div_purchase_ships"
        is_iframe="1"
        >
     <cfelse>
     <cf_paging
        name="sale_ships"
        page="#attributes.page#" 
        maxrows="#attributes.maxrows#" 
        totalrecords="#attributes.totalrecords#" 
        startrow="#attributes.startrow#" 
        adres="#adres#"
        isAjax="1"
        target="div_sale_ships"
        is_iframe="1"
        >
     </cfif>
</cfif>
</div> 
<cfif attributes.line_based eq 1><!--- SATIR BAZINDA İSE --->
<script type="text/javascript">
	<cfoutput>
	function #var_calc_marj_function#(type,id){
		var price = filterNum(document.getElementById('#var___price_#'+id).value,4);
		var marj = filterNum(document.getElementById('#var_marj_#'+id).value,4);
		if(type=='marj')
			document.getElementById('#var_price_#'+id).value = commaSplit(parseFloat(marj*price/100),2);
		else if(type=='price')
			document.getElementById('#var_marj_#'+id).value = commaSplit(parseFloat(filterNum(document.getElementById('#var_price_#'+id).value)*100/price),2);
	}
	function #var_all_select_function#(type)</cfoutput>{
		<cfoutput query="get_purchases_ship">
			var row_amount = filterNum(document.getElementById('#var_row_amount_##SHIP_ROW_ID#').value,4);
			var price = filterNum(document.getElementById('#var_price_##SHIP_ROW_ID#').value,4);
			var my_obj = document.getElementById('#var_inv_row_check_##SHIP_ROW_ID#');
			if(type=='select') my_obj.checked=(my_obj.checked==true)?false:true;
			else if(type=='add_basket')
				if(my_obj.checked==true)
					opener.add_basket_row('#product_id#', '#stock_id#', '#stock_code#', '#barcod#', '#manufact_code#', '#Replace(PRODUCT_NAME,"'","","all")#', '#unit_id#', '#unit#', '#spect_var_id#', '#spect_var_name#', price, price, '#TAX#', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', '', '', '', '#session.ep.money#', 0, row_amount, '', '#is_inventory#','#is_production#','#COST_PRICE#','#MARGIN#','#EXTRA_COST#',0,0,0,'#DISCOUNT_COST#',0,0,'#OTV_ORAN#','#Replace(PRODUCT_NAME2,"'","","all")#','','',0,'','','',1,0,'','','',price,0,-2,'','','','#WRK_ROW_ID#','#SHIP_ID#','SHIP');//satırın wrk_row_id si olusturulacak belgenin wrk_row_relation_id sine gonderilir
		</cfoutput>
	}
</script>
</cfif>
