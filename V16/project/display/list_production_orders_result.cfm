<cfparam name="attributes.page" default="1">
<cfparam name="attributes.maxrows" default="20">
<cfset attributes.startrow = ((attributes.page-1)*attributes.maxrows) + 1>
<cfparam name="attributes.line_based" default="1"><!--- Satır Bazındamı?--->
<cfparam name="attributes.purchase_sales" default="1">
<cfparam name="attributes.action_status" default=""><!--- aktif --->
<cfscript>
	var_inv_row_check_ = 'inv_row_check_#attributes.purchase_sales#_production_order_result';
	var_price_ = 'price__#attributes.purchase_sales#_production_order_result';
	var___price_ = '__price__#attributes.purchase_sales#_production_order_result';
	var_marj_ = 'marj__#attributes.purchase_sales#_production_order_result';
	var_row_amount_ = 'row_amount__#attributes.purchase_sales#_production_order_result';
	var_all_select_function = 'allSelect_#attributes.purchase_sales#_production_order_result';
	var_calc_marj_function = 'calc_marj_#attributes.purchase_sales#_production_order_result';
</cfscript>
<cfsetting showdebugoutput="no">
<!--- Üretim Emirleri--->	
<cfquery name="get_production_orders" datasource="#DSN3#">
WITH CTE1 AS (
	SELECT
		POR.PR_ORDER_ID,
        POR.P_ORDER_ID,
		POR.RESULT_NO,
		POR.START_DATE,
		POR.FINISH_DATE,
		POR.RECORD_EMP,
		PORR.STOCK_ID,
		PORR.AMOUNT,
        PORR.SPECT_ID AS SPECT_VAR_ID
        <cfif attributes.line_based eq 1>
        ,PORR.PURCHASE_NET_MONEY MONEY
    	,S.PRODUCT_NAME
        ,S.STOCK_CODE
        ,PORR.UNIT_NAME AS UNIT
        ,PS.PRICE
        ,POR.WRK_ROW_ID
        ,POR.REFERENCE_NO AS PRODUCT_NAME2
        ,PORR.SPECT_NAME AS SPECT_VAR_NAME
        ,PORR.PURCHASE_NET COST
        ,(PORR.PURCHASE_EXTRA_COST+PORR.PURCHASE_NET) AS COST_PRICE
        ,PORR.PURCHASE_EXTRA_COST EXTRA_COST
        ,0 AS MARGIN
        ,0 AS DISCOUNT_COST
        ,0 AS OTV_ORAN
        ,S.PRODUCT_ID
        ,S.BARCOD
        ,S.TAX,S.IS_INVENTORY,S.IS_PRODUCTION
        ,S.MANUFACT_CODE
        ,PORR.UNIT_ID
        </cfif>
	FROM
		PRODUCTION_ORDERS PO,
        PRODUCTION_ORDER_RESULTS POR,
        PRODUCTION_ORDER_RESULTS_ROW PORR,
		STOCKS S
        <cfif attributes.line_based eq 1>
        ,PRICE_STANDART PS
        </cfif>
	WHERE
    	<cfif attributes.line_based eq 1>
            PS.PRODUCT_ID = S.PRODUCT_ID AND
            PS.PRICESTANDART_STATUS = 1 AND 
            PS.PURCHASESALES = 1 AND
			<!--- Daha önceden belgeye çekilen ürünler bir daha gelmesin! --->
            POR.WRK_ROW_ID NOT IN (
                SELECT 
                    A5.FROM_WRK_ROW_ID FROM 
                    (SELECT 
                        SUM(RELATION_ROW.TO_AMOUNT) AS AMOUNT_OTHER,
                        FROM_WRK_ROW_ID 
                    FROM 
                       #dsn3_alias#.RELATION_ROW
                    WHERE
                        FROM_ACTION_ID = POR.PR_ORDER_ID AND 
                        TO_TABLE ='#attributes.from_paper#' GROUP BY FROM_WRK_ROW_ID ) AS A5
                WHERE
                    A5.FROM_WRK_ROW_ID=POR.WRK_ROW_ID
                    AND (PORR.AMOUNT-A5.AMOUNT_OTHER)<=0
            ) AND
            <!--- // Daha önceden belgeye çekilen ürünler bir daha gelmesin! --->
        </cfif>
        PORR.TYPE= 1 AND
        PORR.PR_ORDER_ID = POR.PR_ORDER_ID AND
        POR.P_ORDER_ID = PO.P_ORDER_ID AND
		S.STOCK_ID = PORR.STOCK_ID 
        <cfif isdefined("attributes.action_status") and attributes.action_status eq 1>
            AND PO.STATUS = 1
        <cfelseif isdefined("attributes.action_status") and attributes.action_status eq 0>
            AND PO.STATUS = 0
        </cfif>
		AND PO.DP_ORDER_ID IS NULL AND 
		<cfif isdefined("attributes.is_from_product")><!--- urun detayindan geliyorsa --->
			S.PRODUCT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#URL.ID#">
		<cfelse>
			PO.PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#URL.ID#"> 
		</cfif> 
        
		
		),
       CTE2 AS (
            SELECT
                CTE1.*,
                ROW_NUMBER() OVER ( ORDER BY 
                START_DATE
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
</cfquery>
<cfif get_production_orders.recordcount>
    <cfparam name="attributes.totalrecords" default="#get_production_orders.query_count#">
<cfelse>
    <cfparam name="attributes.totalrecords" default="0">
</cfif>
<div id="div_production_orders_result">
<cf_grid_list>
	<thead>
       <tr>
           <th width="30"><cf_get_lang dictionary_id='57487.No'></th>
           <th><cf_get_lang dictionary_id='57880.Belge No'></th>
           <cfif attributes.line_based eq 1>
               <th><cf_get_lang dictionary_id='57657.Ürün'></th>
           </cfif>
           <th><cf_get_lang dictionary_id='57647.Spec'></th> 
           <th style="text-align:right;"><cf_get_lang dictionary_id='57635.Miktar'></th>
           <cfif attributes.line_based eq 1>
           <th><cf_get_lang dictionary_id='57518.Stok Kodu'></th>
           <th><cf_get_lang dictionary_id='57636.Birim'></th> 
           <th style="text-align:right;"><cf_get_lang dictionary_id='58123.Planlama'> <cf_get_lang dictionary_id='58084.Fiyat'></th> 
           <th style="text-align:right;"><cf_get_lang dictionary_id='58258.Maliyet'></th> 
           <th style="text-align:right;"><cf_get_lang dictionary_id='58084.Fiyat'></th> 
           <th><cf_get_lang dictionary_id='57489.Para Br.'></th>
           <th style="text-align:right;"><cf_get_lang dictionary_id="38194.Fatura Edilen"></th>
           <th style="text-align:right;"><cf_get_lang dictionary_id='58444.Kalan'></th>
           <th><cf_get_lang dictionary_id="38204.Marj"></th> 
           <th style="text-align:right;"><cf_get_lang dictionary_id='57448.Satış'> <cf_get_lang dictionary_id='58084.Fiyat'></th>
           <cfif attributes.line_based eq 1 and isdefined("attributes.from_paper") and len(attributes.from_paper)>
           <th><input type="checkbox" name="all_select" id="all_select" onClick="<cfoutput>#var_all_select_function#</cfoutput>('select');"></th>
           </cfif>
           <cfelse>
           <th><cf_get_lang dictionary_id='57501.Başlangıç'></th>
           <th><cf_get_lang dictionary_id='57502.Bitiş'></th>
           <th><cf_get_lang dictionary_id='57899.Kaydeden'></th>
           </cfif>
       </tr>
   </thead>
   <tbody>
	<cfif get_production_orders.recordcount>
		<cfif attributes.line_based neq 1>
			<cfset emp_id_list=''>
            <cfoutput query="get_production_orders">
                <cfif len(RECORD_EMP) and not listfind(emp_id_list,RECORD_EMP)>
                    <cfset emp_id_list=listappend(emp_id_list,RECORD_EMP)>
                </cfif>
            </cfoutput>
            <cfif len(emp_id_list)>
                <cfset emp_id_list=listsort(emp_id_list,"numeric","ASC",",")>
                <cfquery name="GET_EMP_ID" datasource="#DSN#">
                    SELECT
                        EMPLOYEE_NAME,
                        EMPLOYEE_SURNAME,
                        EMPLOYEE_ID
                    FROM 
                        EMPLOYEES
                    WHERE
                        EMPLOYEE_ID IN (#emp_id_list#)
                    ORDER BY
                        EMPLOYEE_ID
                </cfquery>
            </cfif>
		<cfelse>
			<cfset pr_order_id_list = listdeleteduplicates(ValueList(get_production_orders.PR_ORDER_ID,','))>
            <cfif len(pr_order_id_list)>
                <cfquery name="GET_ALL_USED_AMOUNT" datasource="#DSN3#">
                    SELECT 
                        SUM(TO_AMOUNT) AMOUNT,
                        FROM_WRK_ROW_ID
                    FROM 
                        RELATION_ROW
                    WHERE
                        FROM_ACTION_ID IN (#pr_order_id_list#)
                        AND TO_TABLE ='#attributes.from_paper#'
                    GROUP BY FROM_WRK_ROW_ID
                </cfquery>
                <cfif GET_ALL_USED_AMOUNT.recordcount>
                    <cfscript>
                        for(uai=1;uai lte GET_ALL_USED_AMOUNT.recordcount; uai=uai+1)
                            'used_amount_#GET_ALL_USED_AMOUNT.FROM_WRK_ROW_ID[uai]#' = GET_ALL_USED_AMOUNT.AMOUNT[uai];//kullanılan miktarları benzersiz wrk_row_id'ye göre belirledik.
                    </cfscript>
                </cfif>
            </cfif>
            <cfset stock_id_list = ValueList(get_production_orders.STOCK_ID,',')>
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
                    PM.PROJECT_ID = #attributes.id#  
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
	<cfoutput query="get_production_orders">
	<tr>
		<td>#rownum#</td>
		<td>
			<cfif get_module_user(26) and not listfindnocase(denied_pages,'prod.form_upd_prod_order')>
				<a href="#request.self#?fuseaction=prod.list_results&event=upd&p_order_id=#p_order_id#&pr_order_id=#pr_order_id#" target="_blank" class="tableyazi">#RESULT_NO#</a>
			<cfelse>
				#RESULT_NO#
			</cfif>
		</td>
        <cfif attributes.line_based eq 1>
            <td>
                <a href="javascript://" onClick="windowopen('#request.self#?fuseaction=objects.popup_detail_product&pid=#product_id#','large');" class="tableyazi">#get_product_name(stock_id:stock_id)#</a>
            </td>
        </cfif>
        <td>#SPECT_VAR_ID#</td>
		<td style="text-align:right;">#AMOUNT#</td>
        <cfif attributes.line_based eq 1>
			<cfif isdefined('used_amount_#WRK_ROW_ID#') and len(Evaluate("used_amount_#WRK_ROW_ID#"))>
                <cfset kalan_miktar = AMOUNT - Evaluate("used_amount_#WRK_ROW_ID#")>
            <cfelse>
                <cfset kalan_miktar = AMOUNT>
                <cfset 'used_amount_#WRK_ROW_ID#' = 0 >
            </cfif>
            <cfif kalan_miktar lt 0><cfset kalan_miktar = 0></cfif>
            <td>#STOCK_CODE#</td>
            <td>#UNIT#</td>
            <td style="text-align:right;"><cfif isdefined('project_plan_price#STOCK_ID#')>#tlformat(Evaluate('project_plan_price#STOCK_ID#'))# #session.ep.money#</cfif></td>
            <td style="text-align:right;">#tlformat(COST)#</td>
            <td style="text-align:right;">#tlformat(PRICE)#</td>
            <td>#session.ep.money#</td>
            <td style="text-align:right;">#tlformat(Evaluate("used_amount_#WRK_ROW_ID#"))#</td>
            <td style="text-align:right;"><input type="text"  name="#var_row_amount_##PR_ORDER_ID#" id="#var_row_amount_##PR_ORDER_ID#"value="#tlformat(kalan_miktar)#" onKeyup="return(FormatCurrency(this,event,6));"></td>
            <td style="text-align:right;">%<input type="text" name="#var_marj_##PR_ORDER_ID#" id="#var_marj_##PR_ORDER_ID#" onKeyup="return(FormatCurrency(this,event,6));" onBlur="#var_calc_marj_function#('marj',#PR_ORDER_ID#);" value="100"></td>
            <td style="text-align:right;">
            <input type="hidden"  name="#var___price_##PR_ORDER_ID#" id="#var___price_##PR_ORDER_ID#" value="#tlformat(PRICE)#">
            <input type="text"  name="#var_price_##PR_ORDER_ID#" id="#var_price_##PR_ORDER_ID#" value="#tlformat(PRICE)#" onKeyup="return(FormatCurrency(this,event,6));" onBlur="#var_calc_marj_function#('price',#PR_ORDER_ID#);">#session.ep.money#</td>
            <cfif attributes.line_based eq 1 and isdefined("attributes.from_paper") and len(attributes.from_paper)>
            <td><input type="checkbox" name="#var_inv_row_check_##PR_ORDER_ID#" id="#var_inv_row_check_##PR_ORDER_ID#" value="#PR_ORDER_ID#"></td>
            </cfif>
		<cfelse>
            <td> 	  
                <cfif len(START_DATE) >
                    <cfset sdate=date_add("h",session.ep.TIME_ZONE,START_DATE)>
                </cfif>
                <cfif len(FINISH_DATE) >
                    <cfset fdate=date_add("h",session.ep.TIME_ZONE,FINISH_DATE)>
                </cfif>
                #dateformat(sdate,dateformat_style)#
            </td>
            <td style="text-align:right;">#dateformat(fdate,dateformat_style)#</td>
            <td>#GET_EMP_ID.EMPLOYEE_NAME[listfind(emp_id_list,RECORD_EMP,',')]# #GET_EMP_ID.EMPLOYEE_SURNAME[listfind(emp_id_list,RECORD_EMP,',')]#</td>
		</cfif>
	 </tr>
	 </cfoutput>
     
	 <cfelse>
	  <tr>
		<td colspan="20"><cf_get_lang dictionary_id='57484.Kayıt Bulunamadı'> !</td>
	  </tr>
	</cfif>
    </tbody>
</cf_grid_list>
<cfif get_production_orders.recordcount>
    <cfif attributes.line_based eq 1 and isdefined("attributes.from_paper") and len(attributes.from_paper)> 
        <div class="ui-info-bottom flex-end">
            <a href="javascript://" onClick="<cfoutput>#var_all_select_function#</cfoutput>('add_basket');" class="ui-btn ui-btn-success"><cf_get_lang dictionary_id='57582.Ekle'></a>
        </div>
    </cfif>
</cfif>
<cfset adres="project.popup_ajax_list_production_orders_result&id=#attributes.id#&line_based=#attributes.line_based#">
<cfif isdefined("attributes.from_paper")>
	<cfset adres = "#adres#&from_paper=#attributes.from_paper#">
</cfif>
<cfif isdefined("attributes.is_from_product")>
	<cfset adres = "#adres#&is_from_product=#attributes.is_from_product#">
</cfif>
<cfif attributes.totalrecords gt attributes.maxrows>
    <cf_paging
        name="production_orders_result"
        page="#attributes.page#" 
        maxrows="#attributes.maxrows#" 
        totalrecords="#attributes.totalrecords#" 
        startrow="#attributes.startrow#" 
        adres="#adres#"
        isAjax="1"
        target="div_production_orders_result"
        is_iframe="1"
        >
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
            <cfoutput query="get_production_orders">
                var row_amount = filterNum(document.getElementById('#var_row_amount_##PR_ORDER_ID#').value,4);
                var price = filterNum(document.getElementById('#var_price_##PR_ORDER_ID#').value,4);
                var my_obj = document.getElementById('#var_inv_row_check_##PR_ORDER_ID#');
                if(type=='select') my_obj.checked=(my_obj.checked==true)?false:true;
                else if(type=='add_basket')
                    if(my_obj.checked==true)
                        opener.add_basket_row('#product_id#', '#stock_id#', '#stock_code#', '#barcod#', '#manufact_code#', '#Replace(PRODUCT_NAME,"'","","all")#', '#unit_id#', '#unit#', '#spect_var_id#', '#spect_var_name#', price, price, '#TAX#', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', '', '', '', '#session.ep.money#', 0, row_amount, '', '#is_inventory#','#is_production#','#COST_PRICE#','#MARGIN#','#EXTRA_COST#',0,0,0,'#DISCOUNT_COST#',0,0,'#OTV_ORAN#','#Replace(PRODUCT_NAME2,"'","","all")#','','',0,'','','',1,0,'','','',price,0,-2,'','','','#WRK_ROW_ID#','#PR_ORDER_ID#','PRODUCTION_ORDER_RESULTS');//satırın wrk_row_id si olusturulacak belgenin wrk_row_relation_id sine gonderilir
			</cfoutput>
        }
    </script>
<!--- ****attributes.from_paper**** ibaresi sayfanın hangi belgeden çağırıldığını TABLO ismi ile tutar,örn:fatudan ise INVOICE,siparişten ise ORDERS gibi.. --->
</cfif>
