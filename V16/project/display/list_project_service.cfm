<cfsetting showdebugoutput="no">
<cfparam name="attributes.page" default="1">
<cfparam name="attributes.maxrows" default="10">
<cfset attributes.startrow = ((attributes.page-1)*attributes.maxrows) + 1>
<cfparam name="attributes.purchase_sales" default="1">
<cfparam name="attributes.action_status" default=""><!--- aktif --->
<cfscript>
	var_inv_row_check_ = 'inv_row_check_#attributes.purchase_sales#_service';
	var_price_ = 'price__#attributes.purchase_sales#_service';
	var___price_ = '__price__#attributes.purchase_sales#_service';
	var_marj_ = 'marj__#attributes.purchase_sales#_service';
	var_row_amount_ = 'row_amount__#attributes.purchase_sales#_service';
	var_all_select_function = 'allSelect_#attributes.purchase_sales#_service';
	var_calc_marj_function = 'calc_marj_#attributes.purchase_sales#_service';
</cfscript>
<!--- ServiS Başvuruları--->	
<cfquery name="get_project_service" datasource="#DSN3#">
  WITH CTE1 AS (
	SELECT
		SRV.SERVICE_ID,
		SRV.SERVICE_NO,
		SRV.APPLY_DATE,
		SRV.RECORD_MEMBER
        <cfif attributes.line_based eq 1>
            ,S.TAX
            ,0 AS COST
            ,0 AS COST_PRICE
            ,0 AS EXTRA_COST
            ,S.PRODUCT_NAME
            ,0 AS MARGIN
            ,S.STOCK_CODE
            ,S.BARCOD
            ,S.IS_INVENTORY
            ,S.IS_PRODUCTION 
            ,S.MANUFACT_CODE
            ,0 AS DISCOUNT_COST
            ,0 AS OTV_ORAN
            ,SO.UNIT_ID
            ,'' AS SPECT_VAR_NAME
            ,SO.STOCK_ID
            ,SO.AMOUNT
            ,SO.UNIT
            ,SO.PRICE
            ,SO.CURRENCY
            ,'' AS SPECT_VAR_ID
            ,SO.WRK_ROW_ID
            ,SO.SERVICE_OPE_ID
            ,SO.PRODUCT_ID
            ,SRV.SERVICE_DETAIL AS PRODUCT_NAME2
		<cfelse>
        	,SRV.SERVICE_PRODUCT_ID AS PRODUCT_ID
            ,SRV.SUBSCRIPTION_ID
        	,SRV.PRODUCT_NAME
            ,SRVAP.SERVICECAT
            ,PROCESS_TYPE_ROWS.STAGE
		</cfif>
	FROM
		SERVICE SRV
        <cfif attributes.line_based eq 1>
        ,SERVICE_OPERATION SO
        ,STOCKS S
		<cfelse>
            ,SERVICE_APPCAT SRVAP
            ,#dsn_alias#.PROCESS_TYPE_ROWS AS PROCESS_TYPE_ROWS
        </cfif>
	WHERE
    	<cfif attributes.line_based eq 1>
        	SRV.SERVICE_ID = SO.SERVICE_ID AND
            SO.STOCK_ID = S.STOCK_ID AND
			<!--- Daha önceden belgeye çekilen ürünler bir daha gelmesin! --->
            SO.WRK_ROW_ID NOT IN (
                SELECT 
                    A5.FROM_WRK_ROW_ID FROM 
                    (SELECT 
                        SUM(RELATION_ROW.TO_AMOUNT) AS AMOUNT_OTHER,
                        FROM_WRK_ROW_ID 
                    FROM 
                       #dsn3_alias#.RELATION_ROW
                    WHERE
                        FROM_ACTION_ID = SO.SERVICE_ID AND 
                        TO_TABLE ='#attributes.from_paper#' GROUP BY FROM_WRK_ROW_ID ) AS A5
                WHERE
                    A5.FROM_WRK_ROW_ID=SO.WRK_ROW_ID
                    AND (SO.AMOUNT-A5.AMOUNT_OTHER)<=0
            ) AND
            <!--- // Daha önceden belgeye çekilen ürünler bir daha gelmesin! --->
		<cfelse>
            SRV.SERVICECAT_ID=SRVAP.SERVICECAT_ID AND
            SRV.SERVICE_STATUS_ID = PROCESS_TYPE_ROWS.PROCESS_ROW_ID AND
		</cfif>
         <cfif isdefined("attributes.action_status") and attributes.action_status eq 1>
             SRV.SERVICE_ACTIVE = 1 AND 
        <cfelseif isdefined("attributes.action_status") and attributes.action_status eq 0>
             SRV.SERVICE_ACTIVE = 0  AND
        </cfif>
		<cfif isdefined("attributes.is_from_product")><!--- urun detayindan geliyorsa --->
			SRV.SERVICE_PRODUCT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#URL.ID#">
        <cfelseif isdefined("attributes.is_from_sales")><!--- abone detayindan geliyorsa --->   
             SRV.SUBSCRIPTION_ID  = <cfqueryparam cfsqltype="cf_sql_integer" value="#URL.ID#">  
		<cfelse>
			SRV.PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#URL.ID#">
		</cfif> 
		
        ),
        
       CTE2 AS (
            SELECT
                CTE1.*,
                ROW_NUMBER() OVER ( ORDER BY 
                SERVICE_ID ASC
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
<cfif get_project_service.recordcount>
    <cfparam name="attributes.totalrecords" default="#get_project_service.query_count#">
<cfelse>
    <cfparam name="attributes.totalrecords" default="0">
</cfif>
<div id="project_service_div">
<cf_grid_list>
	<thead>
        <tr>
            <th width="30"><cf_get_lang dictionary_id='57487.No'></th>
            <th><cf_get_lang dictionary_id='57880.Belge No'></th>
            <th><cf_get_lang dictionary_id='57742.Tarih'></th>
            <th><cf_get_lang dictionary_id='57657.Ürün'></th>
            <cfif attributes.line_based eq 1>
                <th><cf_get_lang dictionary_id='57518.Stok Kodu'></th>
                <th><cf_get_lang dictionary_id='57657.Ürün'></th>
                <th style="text-align:right;" ><cf_get_lang dictionary_id='57635.Miktar'></th> 
                <th><cf_get_lang dictionary_id='57636.Birim'></th> 
                <cfif session.ep.price_display_valid eq 0>
                    <th style="text-align:right;"><cf_get_lang dictionary_id='58123.Planlama'> <cf_get_lang dictionary_id='58084.Fiyat'></th> 
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
                <th><cf_get_lang dictionary_id='57486.Kategori'></th>
                <th><cf_get_lang dictionary_id='57482.Aşama'></th>
                <th><cf_get_lang dictionary_id='57899.Kaydeden'></th>
            </cfif>
            <th width="20"><a href="<cfoutput>#request.self#?fuseaction=service.list_service&event=add&<cfif isdefined("attributes.is_from_sales")>subscription=#url.id#<cfelse>project_id=#url.id#</cfif></cfoutput>" target="_blank" class="tableyazi"><i class="fa fa-plus" title="<cf_get_lang dictionary_id='57582.Ekle'>"></i></a></th>
        </tr>
    </thead>
    <tbody>
		<cfif get_project_service.recordcount>
            <cfif attributes.line_based neq 1>
                <cfset emp_id_list=''>
                <cfoutput query="get_project_service">
                    <cfif len(RECORD_MEMBER) and not listfind(emp_id_list,RECORD_MEMBER)>
                        <cfset emp_id_list=listappend(emp_id_list,RECORD_MEMBER)>
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
                <cfset service_id_list = listdeleteduplicates(ValueList(get_project_service.SERVICE_ID,','))>
                <cfif len(service_id_list)>
                    <cfquery name="GET_ALL_USED_AMOUNT" datasource="#DSN3#">
                        SELECT 
                            SUM(TO_AMOUNT) AMOUNT,
                            FROM_WRK_ROW_ID
                        FROM 
                            RELATION_ROW
                        WHERE
                            FROM_ACTION_ID IN (#service_id_list#)
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
                <cfset stock_id_list = ValueList(get_project_service.STOCK_ID,',')>
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
            <cfoutput query="get_project_service">
            <tr>
                <td>#rownum#</td>
                <td>
                    <cfif get_module_user(14) and not listfindnocase(denied_pages,'service.upd_service')>
                        <a href="#request.self#?fuseaction=service.list_service&event=upd&service_id=#service_id#" target="_blank" class="tableyazi">#service_no#</a> 
                    <cfelse>
                        #service_no#
                    </cfif>
                </td>
                <td>#dateformat(apply_date,dateformat_style)# #timeformat(date_add('h',session.ep.time_zone,apply_date),timeformat_style)#</td>
                <td><a href="javascript://" onClick="windowopen('#request.self#?fuseaction=objects.popup_dsp_product&pid=#PRODUCT_ID#','medium');" class="tableyazi">#product_name#</a></td>
                <cfif attributes.line_based eq 1>
                    <cfif isdefined('used_amount_#WRK_ROW_ID#') and len(Evaluate("used_amount_#WRK_ROW_ID#"))>
                    <cfset kalan_miktar = AMOUNT - Evaluate("used_amount_#WRK_ROW_ID#")>
                    <cfelse>
                    <cfset kalan_miktar = AMOUNT>
                    <cfset 'used_amount_#WRK_ROW_ID#' = 0 >
                    </cfif>
                    <cfif kalan_miktar lt 0><cfset kalan_miktar = 0></cfif>
                    <td>#STOCK_CODE#</td>
                    <td>#PRODUCT_NAME#</td>
                    <td style="text-align:right;">#tlformat(AMOUNT)#</td>
                    <td>#UNIT#</td>
                    <cfif session.ep.price_display_valid eq 0>
                        <td style="text-align:right;"><cfif isdefined('project_plan_price#STOCK_ID#')>#tlformat(Evaluate('project_plan_price#STOCK_ID#'))# #session.ep.money#</cfif></td>
                        <td style="text-align:right;">#tlformat(PRICE)#</td>
                        <td>#CURRENCY#</td>
                    </cfif>
                    <td style="text-align:right;">#tlformat(Evaluate("used_amount_#WRK_ROW_ID#"))#</td>
                    <td style="text-align:right;"><input type="text"  name="#var_row_amount_##SERVICE_OPE_ID#" id="#var_row_amount_##SERVICE_OPE_ID#"value="#tlformat(kalan_miktar)#" onKeyup="return(FormatCurrency(this,event,6));"></td>
                    <td style="text-align:right;">%<input type="text" name="#var_marj_##SERVICE_OPE_ID#" id="#var_marj_##SERVICE_OPE_ID#" onKeyup="return(FormatCurrency(this,event,6));" onBlur="#var_calc_marj_function#('marj',#SERVICE_OPE_ID#);" value="100"></td>
                    <cfif session.ep.price_display_valid eq 0>
                        <td style="text-align:right;">
                        <input type="hidden"  name="#var___price_##SERVICE_OPE_ID#" id="#var___price_##SERVICE_OPE_ID#" value="#tlformat(PRICE)#">
                        <input type="text"  name="#var_price_##SERVICE_OPE_ID#" id="#var_price_##SERVICE_OPE_ID#"value="#tlformat(PRICE)#" onKeyup="return(FormatCurrency(this,event,6));" onBlur="#var_calc_marj_function#('price',#SERVICE_OPE_ID#);">#session.ep.money#</td>
                    </cfif>
                    <cfif attributes.line_based eq 1 and isdefined("attributes.from_paper") and len(attributes.from_paper)> 
                    <td><input type="checkbox" name="#var_inv_row_check_##SERVICE_OPE_ID#" id="#var_inv_row_check_##SERVICE_OPE_ID#" value="#SERVICE_OPE_ID#"></td>
                    </cfif>
                <cfelse>
                    <td>#servicecat#</td>
                    <td align="center">#stage#</td>
                    <td>#GET_EMP_ID.EMPLOYEE_NAME[listfind(emp_id_list,RECORD_MEMBER,',')]# #GET_EMP_ID.EMPLOYEE_SURNAME[listfind(emp_id_list,RECORD_MEMBER,',')]#</td>
                </cfif>
                <td width="15" style="text-align:right;"><a href="#request.self#?fuseaction=service.list_service&event=upd&service_id=#service_id#" target="_blank" class="tableyazi"><i class="fa fa-pencil" title="<cf_get_lang dictionary_id='57464.Güncelle'>"></i></a></td>
            </tr>
            </cfoutput>
           
        <cfelse>
            <tr>
                <td colspan="17"><cf_get_lang dictionary_id='57484.Kayıt Bulunamadı'> !</td>
            </tr>
        </cfif>
    </tbody>
</cf_grid_list>
<cfif get_project_service.recordcount>
    <cfif attributes.line_based eq 1 and isdefined("attributes.from_paper") and len(attributes.from_paper)> 
        <div class="ui-info-bottom flex-end">
            <a href="javascript://" onClick="<cfoutput>#var_all_select_function#</cfoutput>('add_basket');" class="ui-btn ui-btn-success"><cf_get_lang dictionary_id='57582.Ekle'></a>
        </div>
    </cfif>
</cfif>
<cfset adres="project.popup_ajax_list_project_service&line_based=#attributes.line_based#&id=#attributes.id#">
<cfif isdefined("attributes.from_paper")>
	<cfset adres = "#adres#&from_paper=#attributes.from_paper#">
</cfif>
<cfif attributes.totalrecords gt attributes.maxrows>
    <cf_pages
        name="project_service"
        page="#attributes.page#" 
        maxrows="#attributes.maxrows#" 
        totalrecords="#attributes.totalrecords#" 
        startrow="#attributes.startrow#" 
        adres="#adres#"
        isAjax="1"
        target="project_service_div"
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
            <cfoutput query="get_project_service">
                var row_amount = filterNum(document.getElementById('#var_row_amount_##SERVICE_OPE_ID#').value,4);
                var price = filterNum(document.getElementById('#var_price_##SERVICE_OPE_ID#').value,4);
                var my_obj = document.getElementById('#var_inv_row_check_##SERVICE_OPE_ID#');
                if(type=='select') my_obj.checked=(my_obj.checked==true)?false:true;
                else if(type=='add_basket')
                    if(my_obj.checked==true)
                        opener.add_basket_row('#product_id#', '#stock_id#', '#stock_code#', '#barcod#', '#manufact_code#', '#Replace(PRODUCT_NAME,"'","","all")#', '#unit_id#', '#unit#', '#spect_var_id#', '#spect_var_name#', price, price, '#TAX#', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', '', '', '', '#session.ep.money#', 0, row_amount, '', '#is_inventory#','#is_production#','#COST_PRICE#','#MARGIN#','#EXTRA_COST#',0,0,0,'#DISCOUNT_COST#',0,0,'#OTV_ORAN#','','','',0,'','','',1,0,'','','',price,0,-2,'','','','#WRK_ROW_ID#','#SERVICE_ID#','SERVICE');//satırın wrk_row_id si olusturulacak belgenin wrk_row_relation_id sine gonderilir
            </cfoutput>
        }
    </script>
</cfif>

