<cf_xml_page_edit fuseact="#fusebox.circuit#.popup_list_project_actions">
<cfsetting showdebugoutput="no">
<cfparam name="attributes.page" default="1">
<cfparam name="attributes.maxrows" default="#session.ep.maxrows#">
<cfparam name="attributes.order_type" default="date_desc">
<cfset attributes.startrow = ((attributes.page-1)*attributes.maxrows) + 1>
<cfparam name="attributes.line_based" default="1"><!--- Satır Bazındamı?--->
<cfparam name="attributes.purchase_sales" default="1"><!--- default olarak satış siparişleri --->
<cfparam name="attributes.action_status" default=""><!--- aktif --->
<cfscript>
	var_inv_row_check_ = 'inv_row_check_#attributes.purchase_sales#_order';
	var_price_ = 'price__#attributes.purchase_sales#_order';
	var___price_ = '__price__#attributes.purchase_sales#_order';
	var_marj_ = 'marj__#attributes.purchase_sales#_order';
	var_row_amount_ = 'row_amount__#attributes.purchase_sales#_order';
	var_all_select_function = 'allSelect_#attributes.purchase_sales#_order';
	var_calc_marj_function = 'calc_marj_#attributes.purchase_sales#_order';
</cfscript>
<!---Siparişler--->	
<cfquery name="get_sale_orders" datasource="#DSN3#">
WITH CTE1 AS (
    SELECT
    	O.ORDER_ID,
        O.ORDER_HEAD,
        O.ORDER_NUMBER,
        O.ORDER_DATE,
        O.SHIP_DATE,
        O.DELIVERDATE,
        O.COMPANY_ID,
        O.CONSUMER_ID,
        O.RECORD_EMP,
        O.OTHER_MONEY_VALUE,
        O.OTHER_MONEY,
        O.NETTOTAL,
        O.ORDER_ZONE,
        O.PURCHASE_SALES,
        O.SUBSCRIPTION_ID
        <cfif attributes.line_based eq 1>
			<cfif attributes.purchase_sales eq 1>
                ,S.TAX
            <cfelse>
               , S.TAX_PURCHASE AS TAX
            </cfif>
        ,(ORR.COST_PRICE+ORR.EXTRA_COST) COST
        ,ORR.COST_PRICE
        ,ORR.EXTRA_COST
        ,S.PRODUCT_NAME
        ,0 AS MARGIN
        ,S.STOCK_CODE
        ,S.BARCOD
        ,S.IS_INVENTORY
        ,S.IS_PRODUCTION 
        ,S.MANUFACT_CODE
        ,ORR.DISCOUNT_COST
        ,ORR.OTV_ORAN
        ,ORR.UNIT_ID
        ,ORR.SPECT_VAR_NAME
        ,ORR.STOCK_ID
        ,ORR.QUANTITY AS AMOUNT
        ,ORR.UNIT
        ,ORR.PRICE_OTHER
        ,ORR.PRICE
        ,ORR.OTHER_MONEY ROW_OTHER_MONEY
        ,ORR.SPECT_VAR_ID
        ,ORR.WRK_ROW_ID
        ,ORR.ORDER_ROW_ID
        ,ORR.PRODUCT_ID
        ,ORR.PRODUCT_NAME2
        ,ORR.NETTOTAL NETTOTAL2
        ,ORR.DISCOUNT_1
        </cfif>
    FROM
        ORDERS O
        <cfif attributes.line_based eq 1>
        ,STOCKS S
        ,ORDER_ROW ORR
        </cfif>
    WHERE
        <cfif attributes.line_based eq 1>
        ORR.STOCK_ID = S.STOCK_ID AND
        ORR.ORDER_ID = O.ORDER_ID AND
        <!--- Daha önceden belgeye çekilen ürünler bir daha gelmesin! --->
        WRK_ROW_ID NOT IN (
            SELECT 
                A5.FROM_WRK_ROW_ID FROM 
                (SELECT 
                    SUM(RELATION_ROW.TO_AMOUNT) AS AMOUNT_OTHER,
                    FROM_WRK_ROW_ID 
                FROM 
                    RELATION_ROW 
                WHERE
                    FROM_ACTION_ID = O.ORDER_ID AND 
                    TO_TABLE ='#attributes.from_paper#' GROUP BY FROM_WRK_ROW_ID ) AS A5
            WHERE
                A5.FROM_WRK_ROW_ID=ORR.WRK_ROW_ID
                AND (ORR.QUANTITY-A5.AMOUNT_OTHER)<=0
        ) AND
        <!---  Daha önceden belgeye çekilen ürünler bir daha gelmesin! --->
        </cfif>
		<cfif isdefined("attributes.is_from_product")><!--- urun detayindan geliyorsa --->
			<cfif attributes.line_based eq 1>
			ORR.PRODUCT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#URL.ID#"> AND
			<cfelse>
			(SELECT TOP 1 ORR.PRODUCT_ID FROM  ORDER_ROW ORR WHERE  ORR.ORDER_ID = O.ORDER_ID AND ORR.PRODUCT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.id#">) IS NOT NULL AND
			</cfif>
        <cfelseif isdefined("attributes.is_from_sales")><!--- abone detayindan geliyorsa --->  
            O.SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#URL.ID#"> AND
		<cfelse> 
        	<cfif attributes.line_based eq 1>
            ORR.ROW_PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#URL.ID#"> AND
            <cfelse>
			O.PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#URL.ID#"> AND
            </cfif>
		</cfif> 
        O.ORDER_STATUS = 1 AND
        <cfif attributes.purchase_sales eq 1>
        (( O.PURCHASE_SALES = 1 AND O.ORDER_ZONE = 0 )  OR	( O.PURCHASE_SALES = 0 AND O.ORDER_ZONE = 1 ))
        <cfelse><!--- SATIN ALMA ISE.. --->
       	 ORDER_ZONE=0 AND PURCHASE_SALES=0 
        </cfif>
         ),
       CTE2 AS (
            SELECT
                CTE1.*,
                ROW_NUMBER() OVER ( ORDER BY 
				<cfswitch expression = "#attributes.order_type#">
					<cfcase value="date_desc">
						ORDER_DATE DESC
					</cfcase>
					<cfcase value="date_asc">
						ORDER_DATE ASC
					</cfcase>
					<cfcase value="paperno_desc">
						ORDER_NUMBER DESC
					</cfcase>
					<cfcase value="paperno_asc">
						ORDER_NUMBER ASC
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
<cfif get_sale_orders.recordcount>
    <cfparam name="attributes.totalrecords" default="#get_sale_orders.query_count#">
<cfelse>
    <cfparam name="attributes.totalrecords" default="0">
</cfif>
<cfset company_id_list=''>
<cfset consumer_id_list=''>
<cfset emp_id_list=''>

<cfif get_sale_orders.recordcount>
	<cfoutput query="get_sale_orders">
		<cfif len(company_id) and not listFindnocase(company_id_list,company_id)>
			<cfset company_id_list = listappend(company_id_list,company_id)>
		</cfif>
		<cfif len(consumer_id) and not listFindnocase(consumer_id_list,consumer_id)>
			<cfset consumer_id_list = listappend(consumer_id_list,consumer_id)>
		</cfif>
		<cfif len(RECORD_EMP) and not listfind(emp_id_list,RECORD_EMP)>
			<cfset emp_id_list=listappend(emp_id_list,RECORD_EMP)>
		</cfif>
	</cfoutput>
	<cfif listlen(company_id_list)>
		<cfset company_id_list=listsort(company_id_list,"numeric","ASC",",")>
		<cfquery name="COMPANY_NAME" datasource="#dsn#">
			SELECT NICKNAME, COMPANY_ID, FULLNAME FROM COMPANY WHERE COMPANY_ID  IN (#company_id_list#) ORDER BY COMPANY_ID	
		</cfquery>
	</cfif>	
	<cfif listlen(consumer_id_list)>
		<cfset consumer_id_list=listsort(consumer_id_list,"numeric","ASC",",")>
		<cfquery name="CONS_NAME" datasource="#dsn#">
			SELECT CONSUMER_NAME,CONSUMER_SURNAME,COMPANY,CONSUMER_ID FROM CONSUMER WHERE CONSUMER_ID IN (#consumer_id_list#) ORDER BY CONSUMER_ID	  
		</cfquery>	
	</cfif>
	<cfif len(emp_id_list)>
		<cfset emp_id_list=listsort(emp_id_list,"numeric","ASC",",")>
		<cfquery name="GET_EMP_ID" datasource="#DSN#">
			SELECT EMPLOYEE_NAME,EMPLOYEE_SURNAME,EMPLOYEE_ID FROM EMPLOYEES WHERE EMPLOYEE_ID IN (#emp_id_list#) ORDER BY EMPLOYEE_ID
		</cfquery>
	</cfif>
</cfif>

<cfif attributes.line_based eq 1>
	<cfset order_id_list = listdeleteduplicates(ValueList(get_sale_orders.ORDER_ID,','))>
    <cfif len(order_id_list)>
        <cfquery name="GET_ALL_USED_AMOUNT" datasource="#DSN2#">			
            SELECT
                I.INVOICE_ID AS IDD,
                SUM(AMOUNT) AS IRS_AMOUNT,
                IR.WRK_ROW_RELATION_ID
            FROM
                INVOICE I,
                INVOICE_ROW IR
            WHERE
                IR.INVOICE_ID = I.INVOICE_ID AND
                IR.INVOICE_ID IN(SELECT INVOICE_ID FROM #dsn3#.ORDERS_INVOICE WHERE ORDER_ID IN(<cfqueryparam cfsqltype="cf_sql_integer" value="#order_id_list#" list="yes">))
            GROUP BY
                I.INVOICE_ID,
                IR.WRK_ROW_RELATION_ID
            UNION ALL 
            SELECT
                I.SHIP_ID AS IDD,
                SUM(AMOUNT) AS IRS_AMOUNT,
                IR.WRK_ROW_RELATION_ID
            FROM
                SHIP I,
                SHIP_ROW IR
            WHERE
                IR.SHIP_ID = I.SHIP_ID AND
                IR.SHIP_ID IN(SELECT SHIP_ID FROM #dsn3#.ORDERS_SHIP WHERE ORDER_ID IN(<cfqueryparam cfsqltype="cf_sql_integer" value="#order_id_list#" list="yes">))
            GROUP BY
                I.SHIP_ID,
                IR.WRK_ROW_RELATION_ID						
        </cfquery>
        <cfif GET_ALL_USED_AMOUNT.recordcount>
            <cfscript>
                for(uai=1;uai lte GET_ALL_USED_AMOUNT.recordcount; uai=uai+1)
                    'used_amount_#GET_ALL_USED_AMOUNT.WRK_ROW_RELATION_ID[uai]#' = GET_ALL_USED_AMOUNT.IRS_AMOUNT[uai];//kullanılan miktarları benzersiz wrk_row_id'ye göre belirledik.
            </cfscript>
        </cfif>
    </cfif>
	<cfset stock_id_list = ValueList(get_sale_orders.STOCK_ID,',')>
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
	<cfset fuse_action_add = "purchase.list_order&event=add">
	<cfset fuse_action_upd = "purchase.list_order&event=upd">
<cfelse>
	<cfset fuse_action_add = "sales.list_order&event=add">
	<cfset fuse_action_upd = "sales.list_order&event=upd">
</cfif>
<cfif attributes.purchase_sales eq 0><cfset div_id = 'div_purchase_orders'><cfelse><cfset div_id = 'div_sale_orders'></cfif>
<div id="<cfoutput>#div_id#</cfoutput>">
<cf_grid_list>
	<thead>
        <tr>
            <th width="25"><cf_get_lang dictionary_id='57487.No'></th>
            <th width="140"><cf_get_lang dictionary_id='38133.Sipariş Başlığı'></th>
            <th width="70"><cf_get_lang dictionary_id='57880.Belge No'></th>
            <cfif attributes.line_based neq 1>
            <th><cf_get_lang dictionary_id='57519.Cari Hesap'></th>
            <th width="75"><cf_get_lang dictionary_id='29501.Sipariş Tarihi'></th>
            <th width="75"><cf_get_lang dictionary_id='38422.Sevk Tarihi'></th>
            <th width="75"><cf_get_lang dictionary_id='57645.Teslim Tarihi'></th>
            <th width="60"><cf_get_lang dictionary_id='57673.Tutar'></th>
            <th width="15"><cf_get_lang dictionary_id="58864.Para Br"></th>
            <cfif xml_exchange_amount eq 1>
            <th width="75"><cf_get_lang dictionary_id="57677.Dövizli"> <cf_get_lang dictionary_id='57673.Tutar'></th>
            <th width="15"><cf_get_lang dictionary_id="58864.Para Br"></th>
            </cfif>
            <th width="120"><cf_get_lang dictionary_id='57899.Kaydeden'></th>
            <cfelse>
	            <th><cf_get_lang dictionary_id='57519.Cari Hesap'></th>				
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
                    <th style="text-align:right;"><cf_get_lang dictionary_id='57636.Birim'><cf_get_lang dictionary_id='58084.Fiyat'></th> <th width="75"><cf_get_lang dictionary_id='38528.İskontolu'><cf_get_lang dictionary_id="57677.Dövizli"> <cf_get_lang dictionary_id='57673.Tutar'></th>
                    <th width="85"><cf_get_lang dictionary_id='57489.Para Br.'></th>
                </cfif>
               <th width="75" style="text-align:right;"><cf_get_lang dictionary_id="38194.Fatura Edilen"></th>
               <th style="text-align:right;width:80px;"><cf_get_lang dictionary_id='58444.Kalan'></th>
               <th style="width:50px;"><cf_get_lang dictionary_id="38204.Marj"></th> 
               <cfif session.ep.price_display_valid eq 0>
                    <th style="text-align:right;width:90px;;"><cf_get_lang dictionary_id='57448.Satış'> <cf_get_lang dictionary_id='58084.Fiyat'></th> 
                    <cfif attributes.line_based eq 1 and isdefined("attributes.from_paper") and len(attributes.from_paper)>
                </cfif>
               <th><input type="checkbox" name="all_select" id="all_select" onClick="<cfoutput>#var_all_select_function#</cfoutput>('select');"></th>
               </cfif>
            </cfif> 
            <th width="20"><a href="<cfoutput>#request.self#?fuseaction=#fuse_action_add#&<cfif isdefined("attributes.is_from_sales")>subscription=#url.id#<cfelse>project_id=#url.id#</cfif></cfoutput>" target="_blank"><i class="fa fa-plus" title="<cf_get_lang dictionary_id='57582.Ekle'>"></i></a></th>
        </tr>
    </thead>
    <tbody>
		<cfif get_sale_orders.recordcount>
            <cfoutput query="get_sale_orders">
                <tr>
                    <td>#rownum#</td>
                    <td>#ORDER_HEAD#</td>
                    <td>
                        <cfif (PURCHASE_SALES eq 1 and ORDER_ZONE eq 0) or (PURCHASE_SALES eq 0 and ORDER_ZONE eq 1)>
                            <cfif get_module_user(11) and not listfindnocase(denied_pages,'sales.detail_order')>
                                <a href="#request.self#?fuseaction=sales.list_order&event=upd&order_id=#ORDER_ID#" target="_blank">#ORDER_NUMBER#</a>
                            <cfelse>
                                #ORDER_NUMBER#
                            </cfif>
                        <cfelseif PURCHASE_SALES eq 0 AND ORDER_ZONE eq 0>
                            <cfif get_module_user(12) and not listfindnocase(denied_pages,'purchase.detail_order')>
                                <a href="#request.self#?fuseaction=purchase.list_order&event=upd&order_id=#ORDER_ID#" target="_blank">#ORDER_NUMBER#</a>
                            <cfelse>
                                #ORDER_NUMBER#
                            </cfif>
                        </cfif>
                    </td>
                    <cfif attributes.line_based neq 1>
                        <td>
                            <cfif len(get_sale_orders.company_id)>
                                <a href="javascript://" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_com_det&company_id=#company_id#');">#COMPANY_NAME.nickname[listfind(company_id_list,company_id,',')]#</a>
                            <cfelseif len(get_sale_orders.consumer_id)>
                                <a href="javascript://" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_con_det&con_id=#consumer_id#','medium');"> #CONS_NAME.consumer_name[listfind(consumer_id_list,consumer_id,',')]#</a>
                            </cfif>
                        </td>
                        <td>#dateformat(order_date,dateformat_style)#</td>
                        <td>#dateformat(ship_date,dateformat_style)#</td>
                        <td>#dateformat(deliverdate,dateformat_style)#</td>
                        <td style="text-align:right;">#TLFormat(NETTOTAL)#</td>
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
                        <td><cfif len(emp_id_list)>#GET_EMP_ID.EMPLOYEE_NAME[listfind(emp_id_list,RECORD_EMP,',')]# #GET_EMP_ID.EMPLOYEE_SURNAME[listfind(emp_id_list,RECORD_EMP,',')]#</cfif></td>
                    <cfelse>
                        <td>
                            <cfif len(get_sale_orders.company_id)>
                                <!---<a href="javascript://" onclick="windowopen('#request.self#?fuseaction=objects.popup_com_det&company_id=#company_id#','medium');">--->#COMPANY_NAME.nickname[listfind(company_id_list,company_id,',')]#<!---</a>--->
                            <cfelseif len(get_sale_orders.consumer_id)>
                                <!---<a href="javascript://" onclick="windowopen('#request.self#?fuseaction=objects.popup_con_det&con_id=#consumer_id#','medium');">--->#CONS_NAME.consumer_name[listfind(consumer_id_list,consumer_id,',')]#<!---</a>--->
                            </cfif>
                        </td>                     
                        <cfif isdefined('used_amount_#GET_ALL_USED_AMOUNT.WRK_ROW_RELATION_ID[currentRow]#') and len(Evaluate("used_amount_#GET_ALL_USED_AMOUNT.WRK_ROW_RELATION_ID[currentRow]#"))>
                            <cfset kalan_miktar = AMOUNT - (Evaluate("used_amount_#GET_ALL_USED_AMOUNT.WRK_ROW_RELATION_ID[currentRow]#"))>
                        <cfelse>
                            <cfset kalan_miktar = AMOUNT>
                            <cfset 'used_amount_#GET_ALL_USED_AMOUNT.WRK_ROW_RELATION_ID[currentRow]#' = 0 >
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
                            <td style="text-align:right;">
                                <cfif len(price_other) and len(discount_1)>
                                    #TLFormat(price_other * ((100 - discount_1)/100))#
                                </cfif>
                            </td> 
                            <td>#ROW_OTHER_MONEY#</td>
                        </cfif>
                        <td style="text-align:right;">#tlformat(Evaluate("used_amount_#GET_ALL_USED_AMOUNT.WRK_ROW_RELATION_ID[currentRow]#"))#</td>
                        <td style="text-align:right;"><input type="text"  name="#var_row_amount_##ORDER_ROW_ID#" id="#var_row_amount_##ORDER_ROW_ID#" style="width:80px;"  value="#tlformat(kalan_miktar)#" onKeyup="return(FormatCurrency(this,event,6));"></td>
                        <td style="text-align:right;">%<input type="text" name="#var_marj_##ORDER_ROW_ID#" id="#var_marj_##ORDER_ROW_ID#"  style="width:35px;"  onKeyup="return(FormatCurrency(this,event,6));" onBlur="#var_calc_marj_function#('marj',#ORDER_ROW_ID#);" value="100"></td>
                        <cfif session.ep.price_display_valid eq 0>
                            <td style="text-align:right;">
                            <input type="hidden"  name="#var___price_##ORDER_ROW_ID#" id="#var___price_##ORDER_ROW_ID#" value="#tlformat(price)#">
                            <input type="text"  name="#var_price_##ORDER_ROW_ID#" id="#var_price_##ORDER_ROW_ID#" style="width:70px;"  value="#tlformat(price)#" onKeyup="return(FormatCurrency(this,event,6));" onBlur="#var_calc_marj_function#('price',#ORDER_ROW_ID#);">&nbsp;#session.ep.money#</td>
                        </cfif>
                        <cfif attributes.line_based eq 1 and isdefined("attributes.from_paper") and len(attributes.from_paper)>
                        <td><input type="checkbox" name="#var_inv_row_check_##ORDER_ROW_ID#" id="#var_inv_row_check_##ORDER_ROW_ID#" value="#ORDER_ROW_ID#"></td>
                        </cfif>
                    </cfif>
                    <td><a href="#request.self#?fuseaction=#fuse_action_upd#&order_id=#order_id#" target="_blank"><i class="fa fa-pencil" title="<cf_get_lang dictionary_id='57464.Güncelle'>"></a></td>
                </tr>
            </cfoutput>
        <cfelse>
            <tr>
                <td colspan="21"><cf_get_lang dictionary_id='57484.Kayıtlı Bulunamadı'> !</td>
            </tr>
        </cfif>
    </tbody>
</cf_grid_list>
<cfif get_sale_orders.recordcount>
    <cfif attributes.line_based eq 1 and isdefined("attributes.from_paper") and len(attributes.from_paper)>
        <div class="ui-info-bottom flex-end">
            <a href="javascript://" onClick="<cfoutput>#var_all_select_function#</cfoutput>('add_basket');" class="ui-btn ui-btn-success"><cf_get_lang dictionary_id='57582.Ekle'>!</a>
        </div>
    </cfif>
</cfif>
<cfset adres="project.popup_ajax_list_sale_orders&id=#attributes.id#&line_based=#attributes.line_based#&purchase_sales=#attributes.purchase_sales#&maxrows=#attributes.maxrows#&order_type=#attributes.order_type#">
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
        name="purchase_orders"
        page="#attributes.page#" 
        maxrows="#attributes.maxrows#" 
        totalrecords="#attributes.totalrecords#" 
        startrow="#attributes.startrow#" 
        adres="#adres#"
        isAjax="1"
        target="div_purchase_orders"
        is_iframe="1"
        >
     <cfelse>
     <cf_paging
        name="sale_orders"
        page="#attributes.page#" 
        maxrows="#attributes.maxrows#" 
        totalrecords="#attributes.totalrecords#" 
        startrow="#attributes.startrow#" 
        adres="#adres#"
        isAjax="1"
        target="div_sale_orders"
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
            <cfoutput query="get_sale_orders">
                var row_amount = filterNum(document.getElementById('#var_row_amount_##ORDER_ROW_ID#').value,4);
                var price = filterNum(document.getElementById('#var_price_##ORDER_ROW_ID#').value,4);
                var my_obj = document.getElementById('#var_inv_row_check_##ORDER_ROW_ID#');
                if(type=='select') my_obj.checked=(my_obj.checked==true)?false:true;
                else if(type=='add_basket')
                    if(my_obj.checked==true)
                        opener.add_basket_row('#product_id#', '#stock_id#', '#stock_code#', '#barcod#', '#manufact_code#', '#Replace(PRODUCT_NAME,"'","","all")#', '#unit_id#', '#unit#', '#spect_var_id#', '#spect_var_name#', price, price, '#TAX#', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', '', '', '', '#session.ep.money#', 0, row_amount, '', '#is_inventory#','#is_production#','#COST_PRICE#','#MARGIN#','#EXTRA_COST#',0,0,0,'#DISCOUNT_COST#',0,0,'#OTV_ORAN#','#Replace(PRODUCT_NAME2,"'","","all")#','','',0,'','','',1,0,'','','',price,0,-2,'','','','#WRK_ROW_ID#','#ORDER_ID#','ORDERS');//satırın wrk_row_id si olusturulacak belgenin wrk_row_relation_id sine gonderilir
            </cfoutput>
        }
    </script>
<!--- ****attributes.from_paper**** ibaresi sayfanın hangi belgeden çağırıldığını TABLO ismi ile tutar,örn:fatudan ise INVOICE,siparişten ise ORDERS gibi.. --->
</cfif>