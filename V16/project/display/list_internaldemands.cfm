<cfsetting showdebugoutput="no">
<cfparam name="attributes.page" default="1">
<cfparam name="attributes.maxrows" default="#session.ep.maxrows#">
<cfparam name="attributes.order_type" default="date_desc">
<cfset attributes.startrow = ((attributes.page-1)*attributes.maxrows) + 1>
<cfparam name="rate_round_num" default="#session.ep.our_company_info.rate_round_num#">
<cfparam name="attributes.purchase_sales" default="1">
<cfparam name="attributes.line_based" default="0"><!--- Satır Bazındamı?--->
<cfparam name="attributes.action_status" default=""><!--- aktif --->

<cfscript>
	var_inv_row_check_ = 'inv_row_check_#attributes.purchase_sales#_internaldemands';
	var_price_ = 'price__#attributes.purchase_sales#_internaldemands';
	var___price_ = '__price__#attributes.purchase_sales#_internaldemands';
	var_marj_ = 'marj__#attributes.purchase_sales#_internaldemands';
	var_row_amount_ = 'row_amount__#attributes.purchase_sales#_internaldemands';
	var_all_select_function = 'allSelect_#attributes.purchase_sales#_internaldemands';
	var_calc_marj_function = 'calc_marj_#attributes.purchase_sales#_internaldemands';
</cfscript>
<!--- İç Talepler --->
<cfif attributes.line_based eq 0><!--- BELGE BAZINDA İSE --->
    <cfquery name="get_list_internaldemand" datasource="#DSN3#">
    WITH CTE1 AS (
        SELECT 
			*
		FROM
			 INTERNALDEMAND 
		WHERE 
			<cfif isdefined("attributes.is_from_product")><!--- urun detayindan geliyorsa --->
				(SELECT TOP 1 IRR.PRODUCT_ID FROM  INTERNALDEMAND_ROW IRR WHERE IRR.I_ID = INTERNALDEMAND.INTERNAL_ID AND IRR.PRODUCT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.id#">) IS NOT NULL
			<cfelse>
				PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#URL.ID#">
			</cfif> 
            <cfif isdefined("attributes.action_status") and attributes.action_status eq 1>
                AND IS_ACTIVE = 1
            <cfelseif isdefined("attributes.action_status") and attributes.action_status eq 0>
             	AND IS_ACTIVE = 0
            </cfif>
         ),
       CTE2 AS (
            SELECT
                CTE1.*,
                ROW_NUMBER() OVER ( ORDER BY 
				<cfswitch expression = "#attributes.order_type#">
					<cfcase value="date_desc">
						RECORD_DATE DESC
					</cfcase>
					<cfcase value="date_asc">
						RECORD_DATE ASC
					</cfcase>
					<cfcase value="paperno_desc">
						INTERNAL_NUMBER DESC
					</cfcase>
					<cfcase value="paperno_asc">
						INTERNAL_NUMBER ASC
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
<cfelse><!--- SATIR BAZINDA İSE.. --->
    <cfquery name="get_list_internaldemand" datasource="#DSN3#">
    WITH CTE1 AS (
    SELECT
        I.*,
        S.TAX
        ,(IRR.COST_PRICE+IRR.EXTRA_COST) COST
        ,IRR.COST_PRICE
        ,IRR.EXTRA_COST
        ,S.PRODUCT_NAME
        ,0 AS MARGIN
        ,S.STOCK_CODE
        ,S.BARCOD
        ,S.IS_INVENTORY
        ,S.IS_PRODUCTION 
        ,S.MANUFACT_CODE
        ,IRR.DISCOUNT_COST
        ,IRR.OTV_ORAN
        ,IRR.UNIT_ID
        ,IRR.SPECT_VAR_NAME
        ,IRR.STOCK_ID
        ,IRR.QUANTITY AS AMOUNT
        ,IRR.UNIT
        ,IRR.PRICE_OTHER
        ,IRR.OTHER_MONEY ROW_OTHER_MONEY
        ,IRR.SPECT_VAR_ID
        ,IRR.WRK_ROW_ID
        ,IRR.PRODUCT_ID
        ,IRR.PRODUCT_NAME2
    FROM
        INTERNALDEMAND I,
        STOCKS S,
        INTERNALDEMAND_ROW IRR
    WHERE
        IRR.STOCK_ID = S.STOCK_ID AND
        IRR.I_ID = I.INTERNAL_ID AND
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
                    FROM_ACTION_ID = I.INTERNAL_ID AND 
                    TO_TABLE ='#attributes.from_paper#' GROUP BY FROM_WRK_ROW_ID ) AS A5
            WHERE
                A5.FROM_WRK_ROW_ID=IRR.WRK_ROW_ID
                AND (IRR.QUANTITY-A5.AMOUNT_OTHER)<=0
        ) AND
        <!--- // Daha önceden belgeye çekilen ürünler bir daha gelmesin! --->
        <cfif isdefined("attributes.is_from_product")><!--- urun detayindan geliyorsa --->
        IRR.PRODUCT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#URL.ID#">
        <cfelse>
      	IRR.ROW_PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#URL.ID#">
        </cfif>
        <cfif isdefined("attributes.action_status") and attributes.action_status eq 1>
                AND IS_ACTIVE = 1
            <cfelseif isdefined("attributes.action_status") and attributes.action_status eq 0>
             	AND IS_ACTIVE = 0
            </cfif>
        ),
       CTE2 AS (
            SELECT
                CTE1.*,
                ROW_NUMBER() OVER ( ORDER BY 
				<cfswitch expression = "#attributes.order_type#">
					<cfcase value="date_desc">
						RECORD_DATE DESC
					</cfcase>
					<cfcase value="date_asc">
						RECORD_DATE ASC
					</cfcase>
					<cfcase value="paperno_desc">
						INTERNAL_NUMBER DESC
					</cfcase>
					<cfcase value="paperno_asc">
						INTERNAL_NUMBER ASC
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
</cfif>
<cfif get_list_internaldemand.recordcount>
    <cfparam name="attributes.totalrecords" default="#get_list_internaldemand.query_count#">
<cfelse>
    <cfparam name="attributes.totalrecords" default="0">
</cfif>
<div id="div_internaldemands">
<cf_grid_list>
	<thead>
        <tr>
            <th style="width:30px;"><cf_get_lang dictionary_id='57487.No'></th>
            <th><cf_get_lang dictionary_id='58820.Başlık'></th>
            <th><cf_get_lang dictionary_id="57880.Belge No"></th>
            <cfif attributes.line_based neq 1>
            <th><cf_get_lang dictionary_id="57742.Tarih"></th>
            <th><cf_get_lang dictionary_id="57485.Öncelik"></th>
            <th><cf_get_lang dictionary_id="38206.Talep Eden"></th>
            <th><cf_get_lang dictionary_id="38207.Talep Edilen"></th>
            <th><cf_get_lang dictionary_id="57482.Aşama"></th>
            <cfelse>
            <th><cf_get_lang dictionary_id='57518.Stok Kodu'></th>
            <th><cf_get_lang dictionary_id='57657.Ürün'></th>
            <th><cf_get_lang dictionary_id='57647.Spec'></th> 
            <th style="text-align:right;" ><cf_get_lang dictionary_id='57635.Miktar'></th> 
            <th><cf_get_lang dictionary_id='57636.Birim'></th>
            <th><cf_get_lang dictionary_id='57629.Açıklama'> 2</th> 
			</cfif>
            <th width="20"><a href="<cfoutput>#request.self#?fuseaction=purchase.list_internaldemand&event=add&project_id=#URL.ID#</cfoutput>" target="_blank" ><i class="fa fa-plus" title="<cf_get_lang dictionary_id='57582.Ekle'>"></i></a></th>
        </tr>
    </thead>
    <tbody>
		<cfif GET_LIST_INTERNALDEMAND.recordcount>
        <cfset from_position_list=''>
        <cfset to_position_list=''>
        <cfset priority_list=''>
        <cfoutput query="GET_LIST_INTERNALDEMAND">
            <cfif len(from_position_code) and not listfind(from_position_list,from_position_code)>
                <cfset from_position_list = listappend(from_position_list,from_position_code)>
            </cfif>
            <cfif len(to_position_code) and not listfind(to_position_list,to_position_code)>
                <cfset to_position_list=listappend(to_position_list,to_position_code)>
            </cfif>
            <cfif len(priority) and not listfind(priority_list,priority)>
                <cfset priority_list=listappend(priority_list,priority)>
            </cfif>
        </cfoutput>
        <cfif len(from_position_list)>
            <cfset from_position_list=listsort(from_position_list,"numeric","ASC",",")>
            <cfquery name="get_from_detail" datasource="#dsn#">
                SELECT 
                    EMPLOYEE_ID,
                    EMPLOYEE_NAME,
                    EMPLOYEE_SURNAME
                FROM 
                    EMPLOYEES 
                WHERE 
                    EMPLOYEE_ID IN (#from_position_list#) 
                ORDER BY 
                    EMPLOYEE_ID
            </cfquery>
            <cfset main_from_position_list = listsort(listdeleteduplicates(valuelist(get_from_detail.EMPLOYEE_ID,',')),'numeric','ASC',',')>
        </cfif>
        <cfif len(to_position_list)>
            <cfset to_position_list=listsort(to_position_list,"numeric","ASC",",")>
            <cfquery name="get_to_detail" datasource="#dsn#">
                SELECT 
                    EMPLOYEE_ID,
                    EMPLOYEE_NAME,
                    EMPLOYEE_SURNAME,
                    POSITION_CODE
                FROM 
                    EMPLOYEE_POSITIONS 
                WHERE 
                    POSITION_CODE IN (#to_position_list#) 
                ORDER BY 
                    POSITION_CODE
            </cfquery>
            <cfset main_to_position_list = listsort(listdeleteduplicates(valuelist(get_to_detail.POSITION_CODE,',')),'numeric','ASC',',')>
        </cfif>
        <cfif len(priority_list)>
            <cfset priority_list=listsort(priority_list,"numeric","ASC",",")>
            <cfquery name="get_priority_detail" datasource="#DSN#">
                SELECT PRIORITY,PRIORITY_ID FROM SETUP_PRIORITY WHERE PRIORITY_ID IN (#priority_list#)
            </cfquery>
            <cfset main_priority_list = listsort(listdeleteduplicates(valuelist(get_priority_detail.PRIORITY_ID,',')),'numeric','ASC',',')>
        </cfif>
        <cfoutput query="get_list_internaldemand">
            <tr>
                <td width="10">#rownum#</td>
                <td>#subject#</td>
                <td><cfif get_module_user(12) and not listfindnocase(denied_pages,'purchase.upd_internaldemand')>
						<cfif demand_type eq 1>
                      	    <a href="#request.self#?fuseaction=purchase.list_purchasedemand&event=upd&id=#internal_id#" target="_blank" >#internal_number#</a>
						<cfelse>
							<a href="#request.self#?fuseaction=purchase.list_internaldemand&event=upd&id=#internal_id#" target="_blank" >#internal_number#</a>
						</cfif>
                    <cfelse>
                        #internal_number#
                    </cfif>
                </td>
                <cfif attributes.line_based neq 1>
                <td>#dateformat(date_add('h',session.ep.time_zone,get_list_internaldemand.record_date),dateformat_style)#</td>
                <td><cfif len(priority)>#get_priority_detail.priority[listfind(main_priority_list,get_list_internaldemand.priority,',')]#</cfif></td>
                <td>
                <cfif len(from_position_code)>
                    <cfset emp_id1= get_from_detail.employee_id[listfind(main_from_position_list,get_list_internaldemand.from_position_code,',')]>
                        <a href="javascript://"  onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_emp_det&emp_id=#emp_id1#','medium');" >  
                        #get_from_detail.employee_name[listfind(main_from_position_list,get_list_internaldemand.from_position_code,',')]#&nbsp;
                        #get_from_detail.employee_surname[listfind(main_from_position_list,get_list_internaldemand.from_position_code,',')]#</a>
                </cfif>
                </td>
                <td>
                    <cfif len(to_position_code)>
                        <cfset emp_id2= get_to_detail.employee_id[listfind(main_to_position_list,get_list_internaldemand.to_position_code,',')]>
                        <a href="javascript://"  onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_emp_det&emp_id=#emp_id2#','medium');" > 
                        #get_to_detail.employee_name[listfind(main_to_position_list,get_list_internaldemand.to_position_code,',')]#&nbsp;
                        #get_to_detail.employee_surname[listfind(main_to_position_list,get_list_internaldemand.to_position_code,',')]#</a>
                    </cfif>
                </td>
                <td>
                    <cfif get_list_internaldemand.internaldemand_status is 0><cf_get_lang dictionary_id='29727.İşlem Bekleniyor'>
                    <cfelseif get_list_internaldemand.internaldemand_status is 1><cf_get_lang dictionary_id='46838.Teklifte'>
                    <cfelseif get_list_internaldemand.internaldemand_status is 2><cf_get_lang dictionary_id='38491.Siparişte'>
                    </cfif>
                </td>
                <cfelse>
                <td>#STOCK_CODE#</td>
                <td>#PRODUCT_NAME#</td>
                <td>#SPECT_VAR_ID#</td>
                <td style="text-align:right;">#tlformat(AMOUNT)#</td>
                <td>#UNIT#</td>
                <td>#PRODUCT_NAME2#</td>
                </cfif>
                <td>
                    <cfif demand_type eq 1>
                        <a href="#request.self#?fuseaction=purchase.list_purchasedemand&event=upd&id=#internal_id#" target="_blank" ><i class="fa fa-pencil" title="<cf_get_lang dictionary_id='57464.Güncelle'>"></i></a>
                    <cfelse>
                        <a href="#request.self#?fuseaction=purchase.list_internaldemand&event=upd&id=#internal_id#" target="_blank" ><i class="fa fa-pencil" title="<cf_get_lang dictionary_id='57464.Güncelle'>"></i></a>
                    </cfif>
                </td>
            </tr>
            </cfoutput>
        <cfelse>
          <tr>
            <td colspan="20"><cf_get_lang dictionary_id='57484.Kayıt Yok'> !</td>
          </tr>
        </cfif>
    </tbody>
</cf_grid_list>
<cfif isdefined("attributes.from_paper") and len(attributes.from_paper)>
	<cfset from_paper=attributes.from_paper>
<cfelse>
	<cfset from_paper="">
</cfif>
<cfset adres="project.popup_ajax_list_internaldemands&id=#attributes.id#&line_based=#attributes.line_based#&from_paper=#from_paper#&maxrows=#attributes.maxrows#&order_type=#attributes.order_type#">
<cfif isdefined("attributes.is_from_product")>
	<cfset adres = "#adres#&is_from_product=#attributes.is_from_product#">
</cfif>
<cfif attributes.totalrecords gt attributes.maxrows>
    <cf_paging
        name="internaldemands"
        page="#attributes.page#" 
        maxrows="#attributes.maxrows#" 
        totalrecords="#attributes.totalrecords#" 
        startrow="#attributes.startrow#" 
        adres="#adres#"
        isAjax="1"
        target="div_internaldemands"
        is_iframe="1"
        >
</cfif>
</div> 


