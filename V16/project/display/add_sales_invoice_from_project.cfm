<cfsetting showdebugoutput="no">
<!--- Dikkat : Xml degerleri xml_ parametresi ile bu sayfaya liste halinde gonderiliyor, buna gore alinip kullanilmali!!!
	1.xml_show_zero_row - xml_show_zero_row
	2.xml_use_remaining_amount - xml_use_remaining_amount
 --->
 <cfparam name="attributes.page" default="1">
<cfparam name="attributes.maxrows" default="#session.ep.maxrows#">
<cfparam name="attributes.order_type" default="date_desc">
<cfset attributes.startrow = ((attributes.page-1)*attributes.maxrows) + 1>
<cfparam name="attributes.line_based" default="1">
<cfparam name="attributes.purchase_sales" default="0">
<cfparam name="attributes.project_id" default="">
<!--- FORM İÇİNDEKİ TÜM İNPUTLARI VE JS FONKSİIYONLARINI BU ŞEKİLDE SET EDİYORUZ,ÇÜNKÜ AYNI SAYFA HEM ALIŞ HEM SATIŞ OLARAK AJAX İLE ÇAĞIRILABİLİR,JS HATASI OLMAMASI İÇİN BU ŞEKİLDE YAPTIM --->
<cfscript>
	var_inv_row_check_ = 'inv_row_check_#attributes.purchase_sales#_invoice';
	var_price_ = 'price__#attributes.purchase_sales#_invoice';
	var___price_ = '__price__#attributes.purchase_sales#_invoice';
	var_marj_ = 'marj__#attributes.purchase_sales#_invoice';
	var_row_amount_ = 'row_amount__#attributes.purchase_sales#_invoice';
	var_all_select_function = 'allSelect_#attributes.purchase_sales#_invoice';
	var_calc_marj_function = 'calc_marj_#attributes.purchase_sales#_invoice';
</cfscript>
<cfquery name="get_purchase_inv_project" datasource="#action_dsn2#">
WITH CTE1 AS (
    SELECT 
		I.INVOICE_NUMBER,
        I.PROCESS_CAT,
        I.COMPANY_ID,
        I.CONSUMER_ID,
		I.INVOICE_CAT,
        I.INVOICE_DATE,
		IR.INVOICE_ROW_ID,
        IR.STOCK_ID,
		IR.INVOICE_ID,
		IR.PRODUCT_ID,
		IR.ROW_PROJECT_ID,
		IR.AMOUNT,
		IR.WRK_ROW_ID,
        IR.WRK_ROW_RELATION_ID,
		IR.NAME_PRODUCT,
		IR.SPECT_VAR_ID,
        IR.SPECT_VAR_NAME,
		IR.UNIT_ID,
		IR.UNIT,
		IR.COST_ID,
		IR.COST_PRICE,
		IR.PRODUCT_NAME2,
		IR.EXTRA_COST,
		IR.PRICE,
		IR.MARGIN,
		IR.DISCOUNT_COST,
		IR.OTV_ORAN,
        S.STOCK_CODE,
        S.BARCOD,
        S.MANUFACT_CODE,
        S.PRODUCT_NAME,
        S.IS_INVENTORY,
        S.IS_PRODUCTION,
        I.SUBSCRIPTION_ID  
    	<cfif attributes.purchase_sales eq 1>
           ,S.TAX S_TAX
		<cfelse>
           ,S.TAX_PURCHASE AS S_TAX 
		</cfif>
    FROM
        INVOICE I,
        INVOICE_ROW IR,
        #dsn3_alias#.STOCKS S
    WHERE
		ISNULL(I.IS_IPTAL,0) = 0 AND
        IR.STOCK_ID = S.STOCK_ID AND
        I.INVOICE_ID = IR.INVOICE_ID AND
        I.INVOICE_CAT NOT IN (67,69)
        <cfif isdefined("attributes.is_from_product")><!--- urun detayindan geliyorsa --->
        AND IR.PRODUCT_ID IN (#attributes.project_id#)
        <cfelseif isdefined("attributes.is_from_sales")><!--- abone detayindan geliyorsa --->
        AND I.SUBSCRIPTION_ID IN (#attributes.subscription_id#)
        <cfelse>
        AND ISNULL(I.PROJECT_ID,IR.ROW_PROJECT_ID) IN (#attributes.project_id#)
        </cfif>
        AND I.PURCHASE_SALES = #attributes.purchase_sales#
		<!--- Daha önceden belgeye çekilen ürünler bir daha gelmesin! --->
        AND WRK_ROW_ID NOT IN (
            SELECT 
                A5.FROM_WRK_ROW_ID FROM 
                (SELECT 
                    SUM(RELATION_ROW.TO_AMOUNT) AS AMOUNT_OTHER,
                    FROM_WRK_ROW_ID 
                FROM 
                   #dsn3_alias#.RELATION_ROW
                WHERE
                    FROM_ACTION_ID = IR.INVOICE_ID AND 
                    TO_TABLE ='#attributes.from_paper#'
				GROUP BY
					FROM_WRK_ROW_ID) AS A5
            WHERE
                A5.FROM_WRK_ROW_ID=IR.WRK_ROW_ID
                AND (IR.AMOUNT-A5.AMOUNT_OTHER)<=0
        )
        <!--- // Daha önceden belgeye çekilen ürünler bir daha gelmesin! --->
	 ),
       CTE2 AS (
            SELECT
                CTE1.*,
                ROW_NUMBER() OVER ( ORDER BY 
				<cfswitch expression = "#attributes.order_type#">
					<cfcase value="date_desc">
						INVOICE_DATE DESC
					</cfcase>
					<cfcase value="date_asc">
						INVOICE_DATE ASC
					</cfcase>
					<cfcase value="paperno_desc">
						INVOICE_NUMBER DESC
					</cfcase>
					<cfcase value="paperno_asc">
						INVOICE_NUMBER ASC
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
<cfif get_purchase_inv_project.recordcount>
    <cfparam name="attributes.totalrecords" default="#get_purchase_inv_project.query_count#">
<cfelse>
    <cfparam name="attributes.totalrecords" default="0">
</cfif>
<cfset company_id_list=''>
<cfset consumer_id_list=''>
<cfif get_purchase_inv_project.recordcount>
	<cfoutput query="get_purchase_inv_project">
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
			SELECT NICKNAME, COMPANY_ID, FULLNAME FROM COMPANY WHERE COMPANY_ID  IN (#company_id_list#) ORDER BY COMPANY_ID	
		</cfquery>
	</cfif>	
	<cfif listlen(consumer_id_list)>
		<cfset consumer_id_list=listsort(consumer_id_list,"numeric","ASC",",")>
		<cfquery name="CONS_NAME" datasource="#dsn#">
			SELECT CONSUMER_NAME,CONSUMER_SURNAME,COMPANY,CONSUMER_ID FROM CONSUMER WHERE CONSUMER_ID IN (#consumer_id_list#) ORDER BY CONSUMER_ID	  
		</cfquery>	
	</cfif>
</cfif>
<cfset inv_id_list = listdeleteduplicates(ValueList(get_purchase_inv_project.INVOICE_ID,','))>
<cfset process_cat_id_list = listdeleteduplicates(ValueList(get_purchase_inv_project.PROCESS_CAT,','))>
<cfif len(inv_id_list)>
    <cfquery name="GET_ALL_USED_AMOUNT" datasource="#DSN3#">
		SELECT
			SUM(AMOUNT) AMOUNT,
			PRODUCT_ID,
			WRK_ROW_ID
		FROM
		(
			<!--- Fatura / Fatura --->
			SELECT
				SUM(IR.AMOUNT) AMOUNT,
				IR.PRODUCT_ID,
				IR.WRK_ROW_ID
			FROM
				#dsn2_alias#.INVOICE_ROW IR
			WHERE
				IR.INVOICE_ID IN (SELECT INVOICE.INVOICE_ID FROM #dsn2_alias#.INVOICE INVOICE WHERE INVOICE.INVOICE_ID = IR.INVOICE_ID AND INVOICE.INVOICE_ID IN (#inv_id_list#)) 
			GROUP BY
				IR.PRODUCT_ID,
				IR.WRK_ROW_ID
		
		UNION
			<!--- Fatura / Siparis / Fatura --->
			SELECT
				SUM(IR.AMOUNT) AMOUNT,
				IR.PRODUCT_ID,
				IR.WRK_ROW_ID
			FROM				
				ORDERS_INVOICE OI,
				#dsn2_alias#.INVOICE_ROW IR
			WHERE
				OI.INVOICE_ID = IR.INVOICE_ID AND
				IR.INVOICE_ID IN (SELECT INVOICE.INVOICE_ID FROM #dsn2_alias#.INVOICE INVOICE WHERE INVOICE.INVOICE_ID = IR.INVOICE_ID AND INVOICE.INVOICE_ID IN (#inv_id_list#))
			GROUP BY
				IR.PRODUCT_ID,
				IR.WRK_ROW_ID
		UNION
			<!--- Fatura / Siparis / Irsaliye / Fatura --->
			SELECT
				SUM(IR.AMOUNT) AMOUNT,
				IR.PRODUCT_ID,
				IR.WRK_ROW_ID
			FROM
				ORDERS_SHIP OSH,
				#dsn2_alias#.SHIP_ROW SHR,
				#dsn2_alias#.INVOICE_SHIPS ISH,
				#dsn2_alias#.INVOICE_ROW IR
			WHERE
				OSH.PERIOD_ID = #session.ep.period_id# AND
				OSH.SHIP_ID = SHR.SHIP_ID AND
				OSH.SHIP_ID = ISH.SHIP_ID AND
				ISH.INVOICE_ID = IR.INVOICE_ID AND
				SHR.WRK_ROW_ID = IR.WRK_ROW_RELATION_ID AND
				IR.INVOICE_ID IN (SELECT INVOICE.INVOICE_ID FROM #dsn2_alias#.INVOICE INVOICE WHERE INVOICE.INVOICE_ID = IR.INVOICE_ID AND INVOICE.INVOICE_ID IN (#inv_id_list#))
			GROUP BY
				IR.PRODUCT_ID,
				IR.WRK_ROW_ID
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
				'used_amount_#GET_ALL_USED_AMOUNT.WRK_ROW_ID[uai]#' = GET_ALL_USED_AMOUNT.AMOUNT[uai];//kullanılan miktarları benzersiz wrk_row_id'ye göre belirledik.
        </cfscript>
	</cfif>
    <cfquery name="GET_PROCESS_CAT" datasource="#DSN3#">
        SELECT PROCESS_CAT,PROCESS_CAT_ID FROM SETUP_PROCESS_CAT where PROCESS_CAT_ID IN (#process_cat_id_list#)
    </cfquery>
    <cfloop query="GET_PROCESS_CAT"><cfset '_process_cat_#PROCESS_CAT_ID#' = PROCESS_CAT></cfloop>
</cfif>
<cfif attributes.purchase_sales eq 0><cfset div_id = 'div_purchase_invoices'><cfelse><cfset div_id = 'div_sale_invoices'></cfif>
<div id="<cfoutput>#div_id#</cfoutput>">
	<cf_grid_list>
		<thead>
			<tr>
				<th width="30"><cf_get_lang dictionary_id='57487.No'></th>
				<th><cf_get_lang dictionary_id="57880.Belge No"></th>
				<th><cf_get_lang dictionary_id='57519.Cari Hesap'></th>
				<th><cf_get_lang dictionary_id="57800.İşlem Tipi"></th>
				<th><cf_get_lang dictionary_id='57518.Stok Kodu'></th>
				<th><cf_get_lang dictionary_id='57657.Ürün'></th>
				<th><cf_get_lang dictionary_id='57647.Spec'></th> 
				<th ><cf_get_lang dictionary_id='57635.Miktar'></th> 
				<th><cf_get_lang dictionary_id='57636.Birim'></th> 
				<th><cf_get_lang dictionary_id='57629.Açıklama'> 2</th> 
				<cfif session.ep.cost_display_valid eq 0>
					<th><cf_get_lang dictionary_id='58258.Maliyet'></th> 
					<th><cf_get_lang dictionary_id='57489.Para Br.'></th>
				</cfif>
				<th><cf_get_lang dictionary_id="38214.Kesilen Fat Mik"></th>
				<th><cf_get_lang dictionary_id="58444.Kalan"> <cf_get_lang dictionary_id="57635.Miktar"></th>
				<th><cf_get_lang dictionary_id="38204.Marj"> %</th>
				<cfif session.ep.price_display_valid eq 0>
					<th><cf_get_lang dictionary_id='58084.Fiyat'></th>
				</cfif>
				<cfif attributes.line_based eq 1 and isdefined("attributes.from_paper") and len(attributes.from_paper)>
				<th><input type="checkbox" name="all_select" id="all_select" onClick="<cfoutput>#var_all_select_function#</cfoutput>('select');"></th>
				</cfif>
			</tr>
		</thead>
		<tbody>
			<cfif get_purchase_inv_project.recordcount>
			<cfoutput query="get_purchase_inv_project">
				<cfif isdefined('used_amount_#WRK_ROW_ID#') and len(Evaluate("used_amount_#WRK_ROW_ID#"))>
					<cfset kalan_miktar = AMOUNT - Evaluate("used_amount_#WRK_ROW_ID#")>
				<cfelse>
					<cfset kalan_miktar = AMOUNT>
					<cfset 'used_amount_#WRK_ROW_ID#' = 0>
				</cfif>
				<cfif purchase_sales eq 1>
					<cfif invoice_cat eq 52>
						<cfset fuse_actions = "add_bill_retail&event=upd">
					<cfelse>
						<cfset fuse_actions = "form_add_bill&event=upd">
					</cfif>
				<cfelse>
					<cfset fuse_actions = "form_add_bill_purchase&event=upd">
				</cfif>
				<cfif kalan_miktar lt 0><cfset kalan_miktar = 0></cfif>
				<tr>
					<td>#rownum#</td>
					<td><cfif session.ep.period_id eq attributes.period_id><a href="#request.self#?fuseaction=invoice.#fuse_actions#&iid=#INVOICE_ID#" target="_blank">#INVOICE_NUMBER#</a><cfelse>#INVOICE_NUMBER#</cfif></td>
					<td>
						<cfif len(company_id)>
							#COMPANY_NAME.nickname[listfind(company_id_list,company_id,',')]#
						<cfelseif len(consumer_id)>
							#CONS_NAME.consumer_name[listfind(consumer_id_list,consumer_id,',')]#
						</cfif> 
					</td>
					<td><cfif isdefined('_process_cat_#PROCESS_CAT#')>#Evaluate('_process_cat_#PROCESS_CAT#')#<cfelse>#PROCESS_CAT#</cfif></td>
					<td>#STOCK_CODE#</td>
					<td>#NAME_PRODUCT#</td>
					<td>#SPECT_VAR_ID#&nbsp;#SPECT_VAR_NAME#</td>
					<td>#AMOUNT#</td>
					<td>#UNIT#</td>
					<td>#PRODUCT_NAME2#</td>
					<cfif session.ep.cost_display_valid eq 0>
						<cfif len(EXTRA_COST) and len(COST_PRICE)>
							<cfset total_ = EXTRA_COST+COST_PRICE >
						<cfelse>
							<cfset total_ = COST_PRICE >
						</cfif>
						<td>#tlformat(total_)#</td>
						<td>#session.ep.money#</td>
					</cfif> 
					<td>#tlformat(Evaluate("used_amount_#WRK_ROW_ID#"))#</td>
					<td><input type="text" name="#var_row_amount_##INVOICE_ROW_ID#" id="#var_row_amount_##INVOICE_ROW_ID#" value="#tlformat(kalan_miktar)#" onKeyup="return(FormatCurrency(this,event,6));"></td>
					<td>%<input type="text" name="#var_marj_##INVOICE_ROW_ID#" id="#var_marj_##INVOICE_ROW_ID#" onKeyup="return(FormatCurrency(this,event,6));" onBlur="#var_calc_marj_function#('marj',#INVOICE_ROW_ID#);" value="100"></td>
					<td>
					<cfif session.ep.price_display_valid eq 0>
						<input type="hidden"  name="#var___price_##INVOICE_ROW_ID#" id="#var___price_##INVOICE_ROW_ID#" value="#tlformat(PRICE)#">
						<input type="text"  name="#var_price_##INVOICE_ROW_ID#" id="#var_price_##INVOICE_ROW_ID#" value="#tlformat(PRICE)#" onKeyup="return(FormatCurrency(this,event,6));" onBlur="#var_calc_marj_function#('price',#INVOICE_ROW_ID#);">#session.ep.money#</td>
					</cfif>
					<cfif attributes.line_based eq 1 and isdefined("attributes.from_paper") and len(attributes.from_paper)>
					<td><input type="checkbox" name="#var_inv_row_check_##INVOICE_ROW_ID#" id="#var_inv_row_check_##INVOICE_ROW_ID#" value="#INVOICE_ROW_ID#"></td>
					</cfif>
				</tr>
			</cfoutput>
		
			<cfelse>
				<tr>
					<td colspan="20"><cf_get_lang dictionary_id='57484.Kayıt Bulunamadı'></td>
				</tr>
			</cfif>
		</tbody>
	</cf_grid_list>  
	<cfif get_purchase_inv_project.recordcount>
		<cfif attributes.line_based eq 1 and isdefined("attributes.from_paper") and len(attributes.from_paper)>
			<div class="ui-info-bottom flex-end">
				<a href="javascript://" onClick="<cfoutput>#var_all_select_function#</cfoutput>('add_basket');" class="ui-btn ui-btn-success"><cf_get_lang dictionary_id='57582.Ekle'></a>
			</div>
		</cfif>
	</cfif>
	<cfif isdefined("attributes.from_paper") and len(attributes.from_paper)>
		<cfset from_paper=attributes.from_paper>
	<cfelse>
		<cfset from_paper="">
	</cfif>
	<cfset adres="project.popup_add_sales_invoice_from_project&project_id=#attributes.project_id#&line_based=#attributes.line_based#&from_paper=#from_paper#&purchase_sales=#attributes.purchase_sales#&action_dsn2=#attributes.action_dsn2#&period_id=#attributes.period_id#&order_type=#attributes.order_type#">
	<cfif isdefined("attributes.is_from_product")>
		<cfset adres = "#adres#&is_from_product=#attributes.is_from_product#">
	<cfelse>
		<cfset adres = "#adres#&maxrows=#attributes.maxrows#">
	</cfif>
	<cfif isdefined("attributes.is_from_sales")>
		<cfset adres = "#adres#&is_from_sales=#attributes.is_from_sales#">
	</cfif>
	<cfif attributes.totalrecords gt attributes.maxrows>
		<cfif attributes.purchase_sales eq 0>
		<cf_paging
			name="purchase_invoices"
			page="#attributes.page#" 
			maxrows="#attributes.maxrows#" 
			totalrecords="#attributes.totalrecords#" 
			startrow="#attributes.startrow#" 
			adres="#adres#"
			isAjax="1"
			target="div_purchase_invoices"
			is_iframe="1"
			>
		<cfelse>
		<cf_paging
			name="sale_invoices"
			page="#attributes.page#" 
			maxrows="#attributes.maxrows#" 
			totalrecords="#attributes.totalrecords#" 
			startrow="#attributes.startrow#" 
			adres="#adres#"
			isAjax="1"
			target="div_sale_invoices"
			is_iframe="1"
			>
		</cfif>
	</cfif>
</div>      	
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
		<cfoutput query="get_purchase_inv_project">
			<cfif isDefined("xml_")  and listlen(xml_,';') eq 2 and ListGetAt(xml_,2,';') eq 1>//Kalan Miktarlar Aktarılsın
				var row_amount = filterNum(document.getElementById('#var_row_amount_##INVOICE_ROW_ID#').value,4);
			<cfelse>
				var row_amount = filterNum('#AMOUNT#',4); //Toplam Aktarilsin
			</cfif>
			//var row_amount = filterNum(document.getElementById('#var_row_amount_##INVOICE_ROW_ID#').value,4);
			var price = filterNum(document.getElementById('#var_price_##INVOICE_ROW_ID#').value,4);
			var my_obj = document.getElementById('#var_inv_row_check_##INVOICE_ROW_ID#');
			if(type=='select') my_obj.checked=(my_obj.checked==true)?false:true;
			else if(type=='add_basket')
				if(my_obj.checked==true)
					<cfif isDefined("xml_") and listlen(xml_,';') eq 2 and ListGetAt(xml_,2,';') eq 1>//Kalan Miktarlar Aktarılsın evet secilirse 0 oldugunda dusurulmez
					if(row_amount > 0)
					</cfif>
					opener.add_basket_row('#product_id#', '#stock_id#', '#stock_code#', '#barcod#', '#manufact_code#', '#Replace(PRODUCT_NAME,"'","","all")#', '#unit_id#', '#unit#', '#spect_var_id#', '#spect_var_name#', price, price, '#S_TAX#', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', '', '', '', '#session.ep.money#', 0, row_amount, '', '#is_inventory#','#is_production#','#COST_PRICE#','#MARGIN#','#EXTRA_COST#',0,0,0,'#DISCOUNT_COST#',0,0,'#OTV_ORAN#','#Replace(PRODUCT_NAME2,"'","","all")#','','',0,'','','',1,0,'','','',price,0,-2,'','','','#WRK_ROW_ID#','#INVOICE_ID#','INVOICE');//satırın wrk_row_id si olusturulacak belgenin wrk_row_relation_id sine gonderilir
		</cfoutput>
	}
</script>
