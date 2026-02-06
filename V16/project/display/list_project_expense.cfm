<cfsetting showdebugoutput="no">
<!--- Masraflar--->
<!--- Dikkat : Xml degerleri xml_ parametresi ile bu sayfaya liste halinde gonderiliyor, buna gore alinip kullanilmali!!!
	1.xml_show_zero_row - xml_show_zero_row
	2.xml_use_remaining_amount - xml_use_remaining_amount
 --->
<cfparam name="attributes.page" default="1">
<cfparam name="attributes.maxrows" default="20">
<cfset attributes.startrow = ((attributes.page-1)*attributes.maxrows) + 1>
<cfparam name="attributes.purchase_sales" default="1">
<cfparam name="attributes.line_based" default="1"><!--- Satır Bazında--->
<cfscript>
	var_inv_row_check_ = 'inv_row_check_#attributes.purchase_sales#_expense';
	var_price_ = 'price__#attributes.purchase_sales#_expense';
	var___price_ = '__price__#attributes.purchase_sales#_expense';
	var_marj_ = 'marj__#attributes.purchase_sales#_expense';
	var_row_amount_ = 'row_amount__#attributes.purchase_sales#_expense';
	var_all_select_function = 'allSelect_#attributes.purchase_sales#_expense';
	var_calc_marj_function = 'calc_marj_#attributes.purchase_sales#_expense';
</cfscript>
<cfset dsn2_alias = "#action_dsn2#">
<cfquery name="GET_PROJECT_EXPENSE" datasource="#action_dsn2#">
WITH CTE1 AS (
	SELECT
		S.PRODUCT_ID,
		S.STOCK_ID,
		S.STOCK_CODE,
		S.PRODUCT_NAME,
		S.MANUFACT_CODE,
		S.BARCOD,
		S.TAX,
		S.IS_INVENTORY,
		S.IS_PRODUCTION,
		EIP.EXPENSE_ID,
		EIP.RECORD_EMP,
		EIP.EXPENSE_DATE,
		EIP.PROCESS_CAT,
		EIP.PAPER_NO,
		EIPR.PROJECT_ID,
		EIPR.UNIT_ID,
		EIPR.UNIT,
		EIPR.SUBSCRIPTION_ID,
		ISNULL(EIPR.QUANTITY,1) AS AMOUNT,
		EIPR.AMOUNT PRICE,
		EIPR.TOTAL_AMOUNT,
		EIPR.MONEY_CURRENCY_ID,
		(EIPR.AMOUNT/#dsn_alias#.IS_ZERO(EIPR.QUANTITY,1)) COST,
		(EIPR.AMOUNT/#dsn_alias#.IS_ZERO(EIPR.QUANTITY,1)) COST_PRICE,
		EIPR.OTHER_MONEY_VALUE,
		'' SPECT_VAR_ID,
		EIPR.WRK_ROW_ID,
		EIPR.DETAIL AS PRODUCT_NAME2,
		EIPR.EXP_ITEM_ROWS_ID,
		'' SPECT_VAR_NAME,
		0 EXTRA_COST,
		0 AS MARGIN,
		0 AS DISCOUNT_COST,
		0 AS OTV_ORAN
	FROM
		EXPENSE_ITEM_PLANS EIP,
		EXPENSE_ITEMS_ROWS EIPR
		LEFT JOIN #dsn3_alias#.STOCKS S ON S.STOCK_ID = EIPR.STOCK_ID_2
	WHERE
		EIP.EXPENSE_ID = EIPR.EXPENSE_ID AND
		<cfif isdefined("attributes.is_from_product")><!--- urun detayindan geliyorsa --->
			S.PRODUCT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#URL.ID#"> 
		<cfelseif isdefined("attributes.is_from_sales")><!--- abone detayindan geliyorsa --->    	
		    EIPR.SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#URL.ID#"> 
		<cfelse>
			<cfif line_based eq 1>
                EIPR.PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#URL.ID#"> 
			<cfelse>
				EIP.PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#URL.ID#"> 
			</cfif>	
		</cfif>
		<cfif isDefined("xml_") and ListGetAt(xml_,1,';') neq 1>
			<!--- // Daha önceden belgeye çekilen ürünler bir daha gelmesin! --->
			AND WRK_ROW_ID NOT IN 
			(
				SELECT 
					A5.FROM_WRK_ROW_ID
				FROM 
					(	SELECT 
							SUM(RELATION_ROW.TO_AMOUNT) AS AMOUNT_OTHER,
							FROM_WRK_ROW_ID 
						FROM 
							#dsn3_alias#.RELATION_ROW
						WHERE
							FROM_ACTION_ID = EIP.EXPENSE_ID 
							<cfif isDefined("attributes.from_paper") and len(attributes.from_paper)> AND TO_TABLE = '#attributes.from_paper#'</cfif> 
						GROUP BY FROM_WRK_ROW_ID
					) AS A5
				WHERE
					A5.FROM_WRK_ROW_ID = EIPR.WRK_ROW_ID
					AND (EIPR.QUANTITY-A5.AMOUNT_OTHER) <= 0
			)
			<!--- // Daha önceden belgeye çekilen ürünler bir daha gelmesin! --->
		</cfif>
         ),
       CTE2 AS (
            SELECT
                CTE1.*,
                ROW_NUMBER() OVER ( ORDER BY 
                EXPENSE_ID,
				STOCK_ID
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
<cfif GET_PROJECT_EXPENSE.recordcount>
    <cfparam name="attributes.totalrecords" default="#GET_PROJECT_EXPENSE.query_count#">
<cfelse>
    <cfparam name="attributes.totalrecords" default="0">
</cfif>
<cfset expense_id_list = listdeleteduplicates(ValueList(GET_PROJECT_EXPENSE.EXPENSE_ID,','))>
<cfif len(expense_id_list)>
	<cfquery name="get_all_used_amount" datasource="#dsn3#"><!--- Faturaya donusturulen masraf fisleri icin de iliski saglaniyor FBS 20101204 --->
		SELECT
			SUM(AMOUNT) AMOUNT,
			PRODUCT_ID,
			FROM_WRK_ROW_ID
		FROM
		(
			<!--- Masraf / Fatura --->
			SELECT
				SUM(RR.TO_AMOUNT) AMOUNT,
				IR.PRODUCT_ID,
				RR.FROM_WRK_ROW_ID
			FROM
				RELATION_ROW RR,
				#dsn2_alias#.INVOICE_ROW IR
			WHERE
				RR.TO_ACTION_ID = IR.INVOICE_ID AND
				RR.FROM_TABLE = 'EXPENSE_ITEM_PLANS' AND
				RR.TO_WRK_ROW_ID = IR.WRK_ROW_ID AND
				RR.TO_TABLE = 'INVOICE' AND
				IR.INVOICE_ID IN (SELECT INVOICE_ID FROM #dsn2_alias#.INVOICE WHERE PURCHASE_SALES = 1 AND INVOICE.INVOICE_ID = IR.INVOICE_ID) AND
				RR.FROM_ACTION_ID IN (#expense_id_list#)
			GROUP BY
				IR.PRODUCT_ID,
				RR.FROM_WRK_ROW_ID
		
		UNION
			<!--- Masraf / Siparis / Fatura --->
			SELECT
				SUM(IR.AMOUNT) AMOUNT,
				IR.PRODUCT_ID,
				RR.FROM_WRK_ROW_ID
			FROM
				RELATION_ROW RR,
				ORDERS_INVOICE OI,
				#dsn2_alias#.INVOICE_ROW IR
			WHERE
				RR.TO_ACTION_ID = OI.ORDER_ID AND
				OI.INVOICE_ID = IR.INVOICE_ID AND
				RR.TO_TABLE = 'ORDERS' AND
				IR.INVOICE_ID IN (SELECT INVOICE_ID FROM #dsn2_alias#.INVOICE WHERE PURCHASE_SALES = 1 AND INVOICE.INVOICE_ID = IR.INVOICE_ID) AND
				RR.FROM_TABLE = 'EXPENSE_ITEM_PLANS' AND
				RR.TO_WRK_ROW_ID = IR.WRK_ROW_RELATION_ID AND
				RR.FROM_ACTION_ID IN (#expense_id_list#)
			GROUP BY
				IR.PRODUCT_ID,
				RR.FROM_WRK_ROW_ID
		UNION
			<!--- Masraf / Siparis / Irsaliye / Fatura --->
			SELECT
				SUM(IR.AMOUNT) AMOUNT,
				IR.PRODUCT_ID,
				RR.FROM_WRK_ROW_ID
			FROM
				RELATION_ROW RR,
				ORDERS_SHIP OSH,
				#dsn2_alias#.SHIP_ROW SHR,
				#dsn2_alias#.INVOICE_SHIPS ISH,
				#dsn2_alias#.INVOICE_ROW IR
			WHERE
				RR.TO_TABLE = 'ORDERS' AND
				RR.TO_ACTION_ID = OSH.ORDER_ID AND
				OSH.PERIOD_ID = #session.ep.period_id# AND
				RR.TO_WRK_ROW_ID = SHR.WRK_ROW_RELATION_ID AND
				OSH.SHIP_ID = SHR.SHIP_ID AND
				OSH.SHIP_ID = ISH.SHIP_ID AND
				ISH.INVOICE_ID = IR.INVOICE_ID AND
				SHR.WRK_ROW_ID = IR.WRK_ROW_RELATION_ID AND
				IR.INVOICE_ID IN (SELECT INVOICE_ID FROM #dsn2_alias#.INVOICE WHERE PURCHASE_SALES = 1 AND INVOICE.INVOICE_ID = IR.INVOICE_ID) AND
				RR.FROM_TABLE = 'EXPENSE_ITEM_PLANS' AND
				RR.FROM_ACTION_ID IN (#expense_id_list#)
			GROUP BY
				IR.PRODUCT_ID,
				RR.FROM_WRK_ROW_ID
		) MAIN_QUERY
		GROUP BY
			PRODUCT_ID,
			FROM_WRK_ROW_ID
			ORDER BY
			FROM_WRK_ROW_ID
	</cfquery>
	<cfif GET_ALL_USED_AMOUNT.recordcount>
		<cfscript>
			for(uai=1;uai lte GET_ALL_USED_AMOUNT.recordcount; uai=uai+1)
				'used_amount_#GET_ALL_USED_AMOUNT.FROM_WRK_ROW_ID[uai]#' = GET_ALL_USED_AMOUNT.AMOUNT[uai];//kullanılan miktarları benzersiz wrk_row_id'ye göre belirledik.
		</cfscript>
	</cfif>
</cfif>
<cfset stock_id_list = ValueList(GET_PROJECT_EXPENSE.STOCK_ID,',')>
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
			PM.PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.id#">
	</cfquery>
	<cfif get_project_mat_plan.recordcount>
		<cfscript>
			for(pmi=1;pmi lte get_project_mat_plan.recordcount; pmi = pmi+1)
				if(not isdefined('project_plan_price#get_project_mat_plan.STOCK_ID[pmi]#'))
					'project_plan_price#get_project_mat_plan.STOCK_ID[pmi]#' = get_project_mat_plan.PRICE[pmi];
		</cfscript>
	</cfif>
</cfif>
<div id="div_project_expense">
<cf_grid_list>
	<thead>
        <tr>
            <th width="30"><cf_get_lang dictionary_id='57487.No'></th>
            <th><cf_get_lang dictionary_id='57880.Belge No'></th>
            <th><cf_get_lang dictionary_id='57800.İşlem Tipi'></th>
            <th><cf_get_lang dictionary_id='57518.Stok Kodu'></th>
            <th><cf_get_lang dictionary_id='57657.Ürün'></th>
            <th style="text-align:right;" ><cf_get_lang dictionary_id='57635.Miktar'></th> 
            <th><cf_get_lang dictionary_id='57636.Birim'></th> 
			<cfif session.ep.price_display_valid eq 0>
				<th style="text-align:right;"><cf_get_lang dictionary_id='58123.Planlama'> <cf_get_lang dictionary_id='58084.Fiyat'></th> 
				<th style="text-align:right;"><cf_get_lang dictionary_id='57638.Birim Fiyat'></th> 
				<th><cf_get_lang dictionary_id='57489.Para Br.'></th>
				<th style="text-align:right;"><cf_get_lang dictionary_id='57642.Net Toplam'></th> 
				<th><cf_get_lang dictionary_id='57489.Para Br.'></th> 
			</cfif>
            <th style="text-align:right;"><cf_get_lang dictionary_id="38194.Fatura Edilen"></th>
            <th style="text-align:right;"><cf_get_lang dictionary_id='58444.Kalan'></th>
            <th><cf_get_lang dictionary_id="38204.Marj"></th> 
			<cfif session.ep.price_display_valid eq 0>
				<th style="text-align:right;"><cf_get_lang dictionary_id='48183.Satış Fiyatı'></th> 
	            <th><cf_get_lang dictionary_id='57489.Para Br.'></th> 
			</cfif>
            <cfif attributes.line_based eq 1 and isdefined("attributes.from_paper") and len(attributes.from_paper)> 
                <th><input type="checkbox" name="all_select" id="all_select" onClick="<cfoutput>#var_all_select_function#</cfoutput>('select');"></th>
            </cfif>
        </tr>
    </thead>
    <tbody>
		<cfif GET_PROJECT_EXPENSE.recordcount>
            <cfoutput query="GET_PROJECT_EXPENSE">
            <tr>
                <td>#rownum#</td>
                <td>#PAPER_NO#</td>
                <td>#PROCESS_CAT#</td>
                <cfif isdefined('used_amount_#WRK_ROW_ID#') and len(Evaluate("used_amount_#WRK_ROW_ID#"))>
                    <cfset kalan_miktar = AMOUNT - Evaluate("used_amount_#WRK_ROW_ID#")>
                <cfelse>
                    <cfset kalan_miktar = AMOUNT>
                    <cfset 'used_amount_#WRK_ROW_ID#' = 0>
                </cfif>
                <cfif kalan_miktar lt 0><cfset kalan_miktar = 0></cfif>
                <td>#STOCK_CODE#</td>
                <td>#PRODUCT_NAME#</td>
                <td style="text-align:right;">#TLFormat(AMOUNT)#</td>
                <td>#UNIT#</td>
				<cfif session.ep.price_display_valid eq 0>
					<td style="text-align:right;"><cfif isdefined('project_plan_price#STOCK_ID#')>#tlformat(Evaluate('project_plan_price#STOCK_ID#'))# #session.ep.money#</cfif></td>
					<td style="text-align:right;">#TLFormat(PRICE)#</td>
					<td>#session.ep.money#</td>
					<td style="text-align:right;">#TLFormat(TOTAL_AMOUNT)#</td>
					<td style="text-align:left;">#session.ep.money#</td>
				</cfif>
                <td style="text-align:right;">#TLFormat(Evaluate("used_amount_#WRK_ROW_ID#"))#</td>
                <td style="text-align:right;"><input type="text"  name="#var_row_amount_##EXP_ITEM_ROWS_ID#" id="#var_row_amount_##EXP_ITEM_ROWS_ID#" style="width:80px;"  value="#tlformat(kalan_miktar)#" onKeyup="return(FormatCurrency(this,event,6));"></td>
                <td style="text-align:right;">%<input type="text" name="#var_marj_##EXP_ITEM_ROWS_ID#" id="#var_marj_##EXP_ITEM_ROWS_ID#" style="width:35px;"  onKeyup="return(FormatCurrency(this,event,6));" onBlur="#var_calc_marj_function#('marj',#EXP_ITEM_ROWS_ID#);" value="100"></td>
				<cfif session.ep.price_display_valid eq 0>
					<td style="text-align:right;">
					<input type="hidden"  name="#var___price_##EXP_ITEM_ROWS_ID#" id="#var___price_##EXP_ITEM_ROWS_ID#" value="#tlformat(PRICE)#">
					<input type="text"  name="#var_price_##EXP_ITEM_ROWS_ID#" id="#var_price_##EXP_ITEM_ROWS_ID#" value="#TLFormat(PRICE)#" onKeyup="return(FormatCurrency(this,event,6));" onBlur="#var_calc_marj_function#('price',#EXP_ITEM_ROWS_ID#);"></td>
					<td style="text-align:left">#session.ep.money#</td>
				</cfif>
                <cfif attributes.line_based eq 1 and isdefined("attributes.from_paper") and len(attributes.from_paper)> 
                    <td><cfif Len(stock_id) and stock_id gt 0><input type="checkbox" name="#var_inv_row_check_##EXP_ITEM_ROWS_ID#" id="#var_inv_row_check_##EXP_ITEM_ROWS_ID#" value="#EXP_ITEM_ROWS_ID#"></cfif></td>
                </cfif>
            </tr>
            </cfoutput>
            
        <cfelse>
            <tr>
                <td colspan="20"><cf_get_lang dictionary_id='57484.Kayıt Yok'> !</td>
            </tr>
        </cfif>
    </tbody>
</cf_grid_list>
<cfif GET_PROJECT_EXPENSE.recordcount>
	<cfif attributes.line_based eq 1 and isdefined("attributes.from_paper") and len(attributes.from_paper)> 
		<div class="ui-info-bottom flex-end">
			<a href="javascript://" onClick="<cfoutput>#var_all_select_function#</cfoutput>('add_basket');" class="ui-btn ui-btn-success"><cf_get_lang dictionary_id='57582.Ekle'></a>
		</div>	
	</cfif>
</cfif>
<cfset adres="project.popup_ajax_list_project_expense&id=#attributes.id#&line_based=#attributes.line_based#&action_dsn2=#attributes.action_dsn2#">
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
    <cf_paging
        name="project_expense"
        page="#attributes.page#" 
        maxrows="#attributes.maxrows#" 
        totalrecords="#attributes.totalrecords#" 
        startrow="#attributes.startrow#" 
        adres="#adres#"
        isAjax="1"
        target="div_project_expense"
        is_iframe="1"
        >
</cfif>
</div> 
 
<cfif attributes.line_based eq 1><!--- SATIR BAZINDA İSE --->
	<script type="text/javascript">
		<cfoutput>
		function #var_calc_marj_function#(type,id)
		{
			var price = filterNum(document.getElementById('#var___price_#'+id).value,4);
			var marj = filterNum(document.getElementById('#var_marj_#'+id).value,4);
			if(type=='marj')
				document.getElementById('#var_price_#'+id).value = commaSplit(parseFloat(marj*price/100),2);
			else if(type=='price')
				document.getElementById('#var_marj_#'+id).value = commaSplit(parseFloat(filterNum(document.getElementById('#var_price_#'+id).value)*100/price),2);
		}
		function #var_all_select_function#(type)
		</cfoutput>
		{
			<cfoutput query="GET_PROJECT_EXPENSE">
				<cfif isDefined("xml_") and  listlen(xml_,';') eq 2 and ListGetAt(xml_,2,';') eq 1>//Kalan Miktarlar Aktarılsın
					var row_amount = filterNum(document.getElementById('#var_row_amount_##EXP_ITEM_ROWS_ID#').value,4);
				<cfelse>
					var row_amount = filterNum('#AMOUNT#',4); //Toplam Aktarilsin
				</cfif>
				var price = filterNum(document.getElementById('#var_price_##EXP_ITEM_ROWS_ID#').value,4);
				var my_obj = document.getElementById('#var_inv_row_check_##EXP_ITEM_ROWS_ID#');
				if(type=='select')
				{
					if(my_obj != undefined)
						my_obj.checked=(my_obj != undefined && my_obj.checked==true)?false:true;
				}
				else if(type=='add_basket')
					if(my_obj != undefined && my_obj.checked==true)
					{
						<cfif isDefined("xml_") and listlen(xml_,';') eq 2 and ListGetAt(xml_,2,';') eq 1>//Kalan Miktarlar Aktarılsın evet secilirse 0 oldugunda dusurulmez
						if(row_amount > 0)
						</cfif>
							opener.add_basket_row('#product_id#', '#stock_id#', '#stock_code#', '#barcod#', '#manufact_code#', '#Replace(PRODUCT_NAME,"'","","all")#', '#unit_id#', '#unit#', '#spect_var_id#', '#spect_var_name#', price, price, '#TAX#', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', '', '', '', '#session.ep.money#', 0, row_amount, '', '#is_inventory#','#is_production#','#COST_PRICE#','#MARGIN#','#EXTRA_COST#',0,0,0,'#DISCOUNT_COST#',0,0,'#OTV_ORAN#','#Replace(PRODUCT_NAME2,"'","","all")#','','',0,'','','',1,0,'','','',price,0,-2,'','','','#WRK_ROW_ID#','#EXPENSE_ID#','EXPENSE_ITEM_PLANS');//satırın wrk_row_id si olusturulacak belgenin wrk_row_relation_id sine gonderilir
					}
			</cfoutput>
		}
	</script>
	<!--- ****attributes.from_paper**** ibaresi sayfanın hangi belgeden çağırıldığını TABLO ismi ile tutar,örn:fatudan ise INVOICE,siparişten ise ORDERS gibi.. --->
</cfif>
