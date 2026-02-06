<cfsetting showdebugoutput="no">
<cfparam name="attributes.page" default="1">
<cfparam name="attributes.maxrows" default="20">
<cfset attributes.startrow = ((attributes.page-1)*attributes.maxrows) + 1>
<cfparam name="attributes.line_based" default="1"><!--- Satır Bazında mı?--->
<cfparam name="attributes.purchase_sales" default="1">
<cfscript>
	var_inv_row_check_ = 'inv_row_check_#attributes.purchase_sales#_sarf';
	var_price_ = 'price__#attributes.purchase_sales#_sarf';
	var___price_ = '__price__#attributes.purchase_sales#_sarf';
	var_marj_ = 'marj__#attributes.purchase_sales#_sarf';
	var_row_amount_ = 'row_amount__#attributes.purchase_sales#_sarf';
	var_all_select_function = 'allSelect_#attributes.purchase_sales#_sarf';
	var_calc_marj_function = 'calc_marj_#attributes.purchase_sales#_sarf';
</cfscript>
<!--- Sarflar--->
<cfquery name="GET_PROJECT_SARF" datasource="#DSN2#">
WITH CTE1 AS (
    SELECT
    	SF.FIS_ID,
    	SF.PROJECT_ID,
        SF.FIS_NUMBER,
        (SELECT SPC.PROCESS_CAT FROM #dsn3_alias#.SETUP_PROCESS_CAT SPC WHERE SPC.PROCESS_CAT_ID = SF.PROCESS_CAT) PROCESS_CAT,
        SF.FIS_DATE,
        SF.RECORD_EMP
        <cfif attributes.line_based eq 1>
    	,(SFR.COST_PRICE+SFR.EXTRA_COST) COST
    	,S.PRODUCT_NAME
        ,S.STOCK_CODE
        ,SFR.STOCK_ID
        ,SFR.AMOUNT
        ,SFR.UNIT
        ,SFR.PRICE
        ,SF.FIS_DETAIL AS PRODUCT_NAME2
        ,SFR.SPEC_MAIN_ID
        ,SFR.WRK_ROW_ID
        ,SFR.STOCK_FIS_ROW_ID
        ,SFR.SPECT_VAR_NAME
        ,SFR.SPECT_VAR_ID
        ,SFR.COST_PRICE
        ,SFR.EXTRA_COST
        ,0 AS MARGIN
        ,0 AS DISCOUNT_COST
        ,0 AS OTV_ORAN
        ,S.PRODUCT_ID
        ,S.BARCOD
        ,S.TAX,S.IS_INVENTORY,S.IS_PRODUCTION
        ,S.MANUFACT_CODE
        ,SFR.UNIT_ID
        </cfif>
    FROM
    	STOCK_FIS SF
        <cfif attributes.line_based eq 1>
    	,#dsn3_alias#.STOCKS S
        ,STOCK_FIS_ROW SFR
        </cfif>
    WHERE 
    	SF.FIS_TYPE = 111
		<cfif isdefined("attributes.is_from_product")><!--- urun detayindan geliyorsa --->
        	<cfif attributes.line_based eq 1>
				AND S.PRODUCT_ID= <cfqueryparam cfsqltype="cf_sql_integer" value="#URL.ID#">
			<cfelse>
			 	AND (SELECT TOP 1 S.PRODUCT_ID FROM  #dsn3_alias#.STOCKS S, STOCK_FIS_ROW SFR WHERE S.STOCK_ID = SFR.STOCK_ID AND SFR.FIS_ID = SF.FIS_ID  AND S.PRODUCT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.id#">) IS NOT NULL 
			</cfif>
		<cfelse>
			 AND SF.PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#URL.ID#">
		</cfif> 
        <cfif attributes.line_based eq 1>
            AND S.STOCK_ID = SFR.STOCK_ID
            AND SFR.FIS_ID = SF.FIS_ID
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
                        FROM_ACTION_ID = SF.FIS_ID AND 
                        TO_TABLE ='#attributes.from_paper#' GROUP BY FROM_WRK_ROW_ID ) AS A5
                WHERE
                    A5.FROM_WRK_ROW_ID=SFR.WRK_ROW_ID
                    AND (SFR.AMOUNT-A5.AMOUNT_OTHER)<=0
            )
            <!--- // Daha önceden belgeye çekilen ürünler bir daha gelmesin! --->
        </cfif>
        ),
       CTE2 AS (
            SELECT
                CTE1.*,
                ROW_NUMBER() OVER ( ORDER BY 
                FIS_ID ASC
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
<cfif GET_PROJECT_SARF.recordcount>
    <cfparam name="attributes.totalrecords" default="#GET_PROJECT_SARF.query_count#">
<cfelse>
    <cfparam name="attributes.totalrecords" default="0">
</cfif>
<cfif attributes.line_based eq 1>
	<cfset fis_id_list = listdeleteduplicates(ValueList(GET_PROJECT_SARF.FIS_ID,','))>
	<cfif len(fis_id_list)>
        <cfquery name="GET_ALL_USED_AMOUNT" datasource="#DSN3#">
            SELECT 
                SUM(TO_AMOUNT) AMOUNT,
                FROM_WRK_ROW_ID
            FROM 
                RELATION_ROW
            WHERE
                FROM_ACTION_ID IN (#fis_id_list#)
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
	<cfset stock_id_list = ValueList(GET_PROJECT_SARF.STOCK_ID,',')>
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
<div id="div_project_sarf">
<cf_grid_list>
	<thead>
        <tr>
           <th width="30"><cf_get_lang dictionary_id='57487.No'></th>
           <th><cf_get_lang dictionary_id='57880.Belge No'></th>
           <th><cf_get_lang dictionary_id='57800.İşlem Tipi'></th>
           <cfif attributes.line_based eq 1>
               <th><cf_get_lang dictionary_id='57518.Stok Kodu'></th>
               <th><cf_get_lang dictionary_id='57657.Ürün'></th>
               <th><cf_get_lang dictionary_id='57647.Spec'></th> 
               <th style="text-align:right;" ><cf_get_lang dictionary_id='57635.Miktar'></th> 
               <th><cf_get_lang dictionary_id='57636.Birim'></th> 
               <cfif session.ep.price_display_valid eq 0>
                    <th style="text-align:right;"><cf_get_lang dictionary_id='58123.Planlama'> <cf_get_lang dictionary_id='58084.Fiyat'></th> 
               </cfif>
               <cfif session.ep.cost_display_valid eq 0>
                   <th style="text-align:right;"><cf_get_lang dictionary_id='58258.Maliyet'></th> 
               </cfif>
               <cfif session.ep.price_display_valid eq 0>
                    <th style="text-align:right;"><cf_get_lang dictionary_id='58084.Fiyat'></th> 
                    <th><cf_get_lang dictionary_id='57489.Para Br.'></th>
               </cfif>
               <th style="text-align:right;"><cf_get_lang dictionary_id="38194.Fatura Edilen"></th>
               <th style="text-align:right;"><cf_get_lang dictionary_id='58444.Kalan'></th>
               <th><cf_get_lang dictionary_id="38204.Marj"></th> 
               <cfif session.ep.price_display_valid eq 0>
                   <th style="text-align:right;"><cf_get_lang dictionary_id='57448.Satış'> <cf_get_lang dictionary_id='58084.Fiyat'></th>
               </cfif>
               <cfif attributes.line_based eq 1 and isdefined("attributes.from_paper") and len(attributes.from_paper)> 
               <th><input type="checkbox" name="all_select" id="all_select" onClick="<cfoutput>#var_all_select_function#</cfoutput>('select');"></th>
               </cfif>
           <cfelse>
               <th><cf_get_lang dictionary_id='57742.Tarih'></th>
               <th><cf_get_lang dictionary_id='57899.Kaydeden'></th>
           </cfif>
         </tr>
     </thead>
     <tbody>
	<cfif GET_PROJECT_SARF.recordcount>
		<cfoutput query="GET_PROJECT_SARF">
            <tr>
                <td>#rownum#</td>
                <td><a href="javascript://" onclick="windowopen('#request.self#?fuseaction=stock.form_add_fis&event=upd&upd_id=#FIS_ID#','page')" class="tableyazi">#FIS_NUMBER#</a></td>
                <td>#PROCESS_CAT#</td>
                <cfif attributes.line_based eq 1>
                    <cfset variableName = "used_amount_#WRK_ROW_ID#">
                    <cfif StructKeyExists(variables, variableName)>
                        <cfset dynamicVariable = variables[variableName]>
                        <cfif len(dynamicVariable)>
                            <cfset kalan_miktar = AMOUNT - dynamicVariable>
                        </cfif>
                    <cfelse>
                        <cfset kalan_miktar = AMOUNT>
                        <cfset variables[variableName] = 0>
                    </cfif>
                    <cfif kalan_miktar lt 0><cfset kalan_miktar = 0></cfif>
                    <td>#STOCK_CODE#</td>
                    <td>#PRODUCT_NAME#</td>
                    <td>#SPECT_VAR_ID#</td>
                    <td style="text-align:right;">#tlformat(AMOUNT)#</td>
                    <td>#UNIT#</td>
                    <cfif session.ep.price_display_valid eq 0>
                        <td style="text-align:right;"><cfif isdefined('project_plan_price#STOCK_ID#')>#tlformat(Evaluate('project_plan_price#STOCK_ID#'))# #session.ep.money#</cfif></td>
                    </cfif>
                    <cfif session.ep.cost_display_valid eq 0>
                        <td style="text-align:right;">#tlformat(COST)#</td>
                    </cfif>
                    <cfif session.ep.price_display_valid eq 0>
                        <td style="text-align:right;">#tlformat(PRICE)#</td>
                        <td>#session.ep.money#</td>
                    </cfif>
                    <td style="text-align:right;">#tlformat(variables[variableName])#</td>
                    <td style="text-align:right;"><input type="text"  name="#var_row_amount_##STOCK_FIS_ROW_ID#" id="#var_row_amount_##STOCK_FIS_ROW_ID#" value="#tlformat(kalan_miktar)#" onKeyup="return(FormatCurrency(this,event,6));"></td>
                    <td style="text-align:right;">%<input type="text" name="#var_marj_##STOCK_FIS_ROW_ID#" id="#var_marj_##STOCK_FIS_ROW_ID#" onKeyup="return(FormatCurrency(this,event,6));" onBlur="#var_calc_marj_function#('marj',#STOCK_FIS_ROW_ID#);" value="100"></td>
                    <cfif session.ep.price_display_valid eq 0>
                        <td style="text-align:right;">
                        <input type="hidden"  name="#var___price_##STOCK_FIS_ROW_ID#" id="#var___price_##STOCK_FIS_ROW_ID#" value="#tlformat(PRICE)#">
                        <input type="text"  name="#var_price_##STOCK_FIS_ROW_ID#" id="#var_price_##STOCK_FIS_ROW_ID#" value="#tlformat(PRICE)#" onKeyup="return(FormatCurrency(this,event,6));" onBlur="#var_calc_marj_function#('price',#STOCK_FIS_ROW_ID#);">#session.ep.money#</td>
                    </cfif>
                    <cfif attributes.line_based eq 1 and isdefined("attributes.from_paper") and len(attributes.from_paper)> 
                    <td><input type="checkbox" name="#var_inv_row_check_##STOCK_FIS_ROW_ID#" id="#var_inv_row_check_##STOCK_FIS_ROW_ID#" value="#STOCK_FIS_ROW_ID#"></td>
                    </cfif>
               <cfelse>
                    <td>#DateFormat(FIS_DATE,dateformat_style)#</td>
                    <td>#get_emp_info(RECORD_EMP,0,0)#</td>
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
<cfif GET_PROJECT_SARF.recordcount>
    <cfif attributes.line_based eq 1 and isdefined("attributes.from_paper") and len(attributes.from_paper)> 
        <div class="ui-info-bottom flex-end">
            <a href="javascript://" onClick="<cfoutput>#var_all_select_function#</cfoutput>('add_basket');" class="ui-btn ui-btn-success"><cf_get_lang dictionary_id='57582.Ekle'></a>
        </div>
    </cfif>
</cfif>
<cfset adres="project.popup_ajax_list_project_sarf&id=#attributes.id#&line_based=#attributes.line_based#">
<cfif isdefined("attributes.from_paper")>
	<cfset adres = "#adres#&from_paper=#attributes.from_paper#">
</cfif>
<cfif isdefined("attributes.is_from_product")>
	<cfset adres = "#adres#&is_from_product=#attributes.is_from_product#">
</cfif>
<cfif attributes.totalrecords gt attributes.maxrows>
    <cf_paging
        name="project_sarf"
        page="#attributes.page#" 
        maxrows="#attributes.maxrows#" 
        totalrecords="#attributes.totalrecords#" 
        startrow="#attributes.startrow#" 
        adres="#adres#"
        isAjax="1"
        target="div_project_sarf"
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
            <cfoutput query="GET_PROJECT_SARF">
                var row_amount = filterNum(document.getElementById('#var_row_amount_##STOCK_FIS_ROW_ID#').value,4);
                var price = filterNum(document.getElementById('#var_price_##STOCK_FIS_ROW_ID#').value,4);
                var my_obj = document.getElementById('#var_inv_row_check_##STOCK_FIS_ROW_ID#');
                if(type=='select') my_obj.checked=(my_obj.checked==true)?false:true;
                else if(type=='add_basket')
                    if(my_obj.checked==true)
                        opener.add_basket_row('#product_id#', '#stock_id#', '#stock_code#', '#barcod#', '#manufact_code#', '#Replace(PRODUCT_NAME,"'","","all")#', '#unit_id#', '#unit#', '#spect_var_id#', '#spect_var_name#', price, price, '#TAX#', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', '', '', '', '#session.ep.money#', 0, row_amount, '', '#is_inventory#','#is_production#','#COST_PRICE#','#MARGIN#','#EXTRA_COST#',0,0,0,'#DISCOUNT_COST#',0,0,'#OTV_ORAN#','#Replace(PRODUCT_NAME2,"'","","all")#','','',0,'','','',1,0,'','','',price,0,-2,'','','','#WRK_ROW_ID#','#FIS_ID#','STOCK_FIS');//satırın wrk_row_id si olusturulacak belgenin wrk_row_relation_id sine gonderilir
            </cfoutput>
        }
    </script>
<!--- ****attributes.from_paper**** ibaresi sayfanın hangi belgeden çağırıldığını TABLO ismi ile tutar,örn:fatudan ise INVOICE,siparişten ise ORDERS gibi.. --->
</cfif>
