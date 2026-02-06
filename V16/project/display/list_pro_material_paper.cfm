<!--- ****attributes.from_paper**** ibaresi sayfanın hangi belgeden çağırıldığını TABLO ismi ile tutar,örn:fatudan ise INVOICE,siparişten ise OFFER gibi.. --->
<cfsetting showdebugoutput="no">
<cfparam name="attributes.page" default="1">
<cfparam name="attributes.maxrows" default="#session.ep.maxrows#">
<cfparam name="attributes.order_type" default="date_desc">
<cfset attributes.startrow = ((attributes.page-1)*attributes.maxrows) + 1>
<cfparam name="attributes.line_based" default="1"><!--- Satır Bazında--->
<cfparam name="attributes.purchase_sales" default="1">
<cfparam name="rate_round_num" default="4">
<cfscript>
	var_row_check_ = 'row_check_#attributes.purchase_sales#_offer';
	var_price_other_ = 'price_#attributes.purchase_sales#_offer';
	var_marj_ = 'marj_#attributes.purchase_sales#_offer';
	var_row_amount_ = 'row_amount__#attributes.purchase_sales#_offer';
	var_all_select_function = 'allSelect_#attributes.purchase_sales#_offer';
	var_calc_marj_function = 'calc_marj_#attributes.purchase_sales#_offer';
</cfscript>
<!--- proje malzeme listesi --->	 
<cfquery name="GET_PRO_MATERIAL" datasource="#DSN#">
WITH CTE1 AS (
	SELECT
		<cfif attributes.line_based eq 1>
			S.PRODUCT_NAME,
			S.STOCK_CODE,
			S.STOCK_CODE_2,
			S.BARCOD,
			S.IS_INVENTORY,
			S.IS_PRODUCTION, 
			S.MANUFACT_CODE,
			(ISNULL(PMR.COST_PRICE,0)+ISNULL(PMR.EXTRA_COST,0)) COST,
			PMR.COST_PRICE,
			PMR.EXTRA_COST,
			PMR.MARGIN,
			PMR.DISCOUNT_COST,
			PMR.OTV_ORAN,
			PMR.UNIT_ID,
			PMR.SPECT_VAR_NAME,
			PMR.STOCK_ID,
			PMR.AMOUNT AS AMOUNT,
			PMR.AMOUNT2,
			PMR.UNIT,
			PMR.UNIT2,
			PMR.PRICE,
			PMR.PRICE_OTHER,
			PMR.OTHER_MONEY,
			PMR.OTHER_MONEY_VALUE,
			PMR.SPECT_VAR_ID,
			PMR.WRK_ROW_ID,
			PMR.PRO_MATERIAL_ROW_ID,
			PMR.PRODUCT_ID,
			PMR.PRODUCT_NAME2,
			PMR.DISCOUNT1,
			PMR.DISCOUNT2,
			PMR.DISCOUNT3,
			PMR.DISCOUNT4,
			PMR.DISCOUNT5,
			PMR.BASKET_EXTRA_INFO_ID,
			PMR.SELECT_INFO_EXTRA,
			PMR.DETAIL_INFO_EXTRA,
			PMR.DELIVER_DEPT,
			PMR.DELIVER_LOCATION,
			(	SELECT
					D.DEPARTMENT_HEAD + '-' + SL.COMMENT
				FROM
					#dsn_alias#.DEPARTMENT D,
					#dsn_alias#.STOCKS_LOCATION SL
				WHERE
					D.DEPARTMENT_ID = SL.DEPARTMENT_ID AND
					D.DEPARTMENT_ID = PMR.DELIVER_DEPT AND 
					SL.LOCATION_ID = PMR.DELIVER_LOCATION
			) DEPARTMENT_HEAD,
			PMR.DELIVER_DATE,
			PMR.DEPTH_VALUE,
			PMR.WIDTH_VALUE,
			PMR.HEIGHT_VALUE,
			PMR.SHELF_NUMBER,
			PMR.ROW_PROJECT_ID,
			PMR.EXTRA_PRICE_OTHER_TOTAL,
			PMR.EK_TUTAR_PRICE, <!--- Iscilik --->
			0 NUMBER_OF_INSTALLMENT,<!--- Taksit Sayisi --->
			PMR.DUEDATE,<!--- Vade --->
			PMR.PROM_COST,
			PMR.LIST_PRICE,
			'' BASKET_EMPLOYEE_ID,
			ISNULL(PMM.RATE2,1) RATE2,
			ISNULL(PMM.RATE1,1) RATE1,
			<cfif attributes.purchase_sales eq 1>
                S.TAX,
            <cfelse>
               S.TAX_PURCHASE AS TAX,
            </cfif>
		</cfif>
		PM.PRO_MATERIAL_ID,
		PM.PRO_MATERIAL_NO,
		PM.ACTION_DATE,
		PM.COMPANY_ID,
		PM.CONSUMER_ID,
		PM.PLANNER_EMP_ID,
		PM.DETAIL,
		PM.RECORD_EMP,
		PM.UPDATE_EMP
	FROM
		<cfif attributes.line_based eq 1>
			PRO_MATERIAL_ROW PMR
			LEFT JOIN PRO_MATERIAL_MONEY PMM ON PMM.ACTION_ID = PMR.PRO_MATERIAL_ID AND PMM.MONEY_TYPE = PMR.OTHER_MONEY,
			#dsn3_alias#.STOCKS S,
		</cfif>
		PRO_MATERIAL PM
	WHERE
		PM.PROJECT_ID = #attributes.id#
		<cfif attributes.line_based eq 1>
			AND S.STOCK_ID = PMR.STOCK_ID
			AND PMR.PRO_MATERIAL_ID = PM.PRO_MATERIAL_ID
			<!--- Daha önceden belgeye çekilen ürünler bir daha gelmesin! --->
			<cfif isDefined("xml_") and ListGetAt(xml_,1,';') neq 1>
			AND WRK_ROW_ID NOT IN 	(	SELECT 
											A5.FROM_WRK_ROW_ID
										FROM 
											(	SELECT 
													SUM(RELATION_ROW.TO_AMOUNT) AS AMOUNT_OTHER,
													FROM_WRK_ROW_ID 
												FROM 
													#dsn3_alias#.RELATION_ROW as RELATION_ROW
												WHERE
													FROM_ACTION_ID = PM.PRO_MATERIAL_ID AND 
													TO_TABLE ='#attributes.from_paper#'
												GROUP BY FROM_WRK_ROW_ID
												
												UNION ALL
												
												<!--- Ic Talebe Cekilen Malzeme Planlari --->
												SELECT
													SUM(INTERNALDEMAND_ROW.QUANTITY) AS AMOUNT_OTHER,
													WRK_ROW_RELATION_ID FROM_WRK_ROW_ID
												FROM
													#dsn3_alias#.INTERNALDEMAND_ROW
												WHERE
													WRK_ROW_RELATION_ID = PMR.WRK_ROW_ID
													<!--- AND (PMR.AMOUNT - INTERNALDEMAND_ROW.QUANTITY) = 0 --->
												GROUP BY
													WRK_ROW_RELATION_ID
											) AS A5
										WHERE
											A5.FROM_WRK_ROW_ID=PMR.WRK_ROW_ID AND
											(PMR.AMOUNT-A5.AMOUNT_OTHER)<=0
									)
		</cfif>
		<!--- // Daha önceden belgeye çekilen ürünler bir daha gelmesin! --->
	</cfif>
     ),
       CTE2 AS (
            SELECT
                CTE1.*,
                ROW_NUMBER() OVER ( ORDER BY 
				<cfswitch expression = "#attributes.order_type#">
					<cfcase value="date_desc">
						ACTION_DATE DESC
					</cfcase>
					<cfcase value="date_asc">
						ACTION_DATE ASC
					</cfcase>
					<cfcase value="paperno_desc">
						STOCK_CODE DESC
					</cfcase>
					<cfcase value="paperno_asc">
						STOCK_CODE ASC
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
<cfif GET_PRO_MATERIAL.recordcount>
    <cfparam name="attributes.totalrecords" default="#GET_PRO_MATERIAL.query_count#">
<cfelse>
    <cfparam name="attributes.totalrecords" default="0">
</cfif>
<cfif GET_PRO_MATERIAL.recordcount>
	<cfif attributes.line_based eq 1>
		<cfset pro_mat_id_list = listdeleteduplicates(ValueList(GET_PRO_MATERIAL.PRO_MATERIAL_ID,','))>
		<cfif len(pro_mat_id_list)>
			<cfquery name="GET_ALL_USED_AMOUNT" datasource="#DSN3#">
				SELECT
					SUM(AMOUNT) AMOUNT,
					FROM_WRK_ROW_ID
				FROM
					(	SELECT
							SUM(IR.QUANTITY) AMOUNT,
							PMR.WRK_ROW_ID FROM_WRK_ROW_ID
						FROM
							#dsn3_alias#.INTERNALDEMAND_ROW IR,
							#dsn_alias#.PRO_MATERIAL_ROW PMR
						WHERE
							IR.WRK_ROW_RELATION_ID = PMR.WRK_ROW_ID AND
							PMR.PRO_MATERIAL_ID IN (#pro_mat_id_list#)
						GROUP BY
							PMR.WRK_ROW_ID
					UNION ALL
						SELECT 
							SUM(TO_AMOUNT) AMOUNT,
							FROM_WRK_ROW_ID
						FROM 
							RELATION_ROW
						WHERE
							FROM_ACTION_ID IN (#pro_mat_id_list#)
							AND TO_TABLE ='#attributes.from_paper#'
						GROUP BY
							FROM_WRK_ROW_ID
					) T1
				GROUP BY
					FROM_WRK_ROW_ID
			</cfquery>
			<cfif GET_ALL_USED_AMOUNT.recordcount>
				<cfscript>
					for(uai=1;uai lte GET_ALL_USED_AMOUNT.recordcount; uai=uai+1)
						'used_amount_#GET_ALL_USED_AMOUNT.FROM_WRK_ROW_ID[uai]#' = GET_ALL_USED_AMOUNT.AMOUNT[uai];//kullanılan miktarları benzersiz wrk_row_id'ye göre belirledik.
				</cfscript>
			</cfif>
		</cfif>
		<cfset stock_id_list = ValueList(GET_PRO_MATERIAL.STOCK_ID,',')>
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
	<cfelse><!--- BELGE BAZINDA İSE --->
		<cfset company_id_list=''>
		<cfset consumer_id_list=''>
		<cfset emp_id_list=''>
		<cfoutput query="GET_PRO_MATERIAL">
			<cfif len(company_id) and not listFindnocase(company_id_list,company_id)>
				<cfset company_id_list = listappend(company_id_list,company_id)>
			</cfif>
			<cfif len(consumer_id) and not listFindnocase(consumer_id_list,consumer_id)>
				<cfset consumer_id_list = listappend(consumer_id_list,consumer_id)>
			</cfif>
			<cfif len(planner_emp_id) and not listfind(emp_id_list,planner_emp_id)>
				<cfset emp_id_list=listappend(emp_id_list,planner_emp_id)>
			</cfif>
		</cfoutput>
		<cfif listlen(company_id_list)>
			<cfset company_id_list=listsort(company_id_list,"numeric","ASC",",")>
			<cfquery name="COMPANY_NAME" datasource="#dsn#">
				SELECT NICKNAME, COMPANY_ID, FULLNAME FROM COMPANY WHERE COMPANY_ID  IN (#company_id_list#) ORDER BY COMPANY_ID
			</cfquery>
			<cfset company = COMPANY_NAME.fullname>
		</cfif>	
		<cfif listlen(consumer_id_list)>
			<cfset consumer_id_list=listsort(consumer_id_list,"numeric","ASC",",")>
			<cfquery name="CONS_NAME" datasource="#dsn#">
				SELECT CONSUMER_NAME, CONSUMER_SURNAME, COMPANY, CONSUMER_ID FROM CONSUMER WHERE CONSUMER_ID IN (#consumer_id_list#) ORDER BY CONSUMER_ID
			</cfquery>	
		</cfif>
		<cfif len(emp_id_list)>
			<cfset emp_id_list=listsort(emp_id_list,"numeric","ASC",",")>
			<cfquery name="GET_EMP_ID" datasource="#DSN#">
				SELECT EMPLOYEE_NAME, EMPLOYEE_SURNAME, EMPLOYEE_ID FROM EMPLOYEES WHERE EMPLOYEE_ID IN (#emp_id_list#) ORDER BY EMPLOYEE_ID
			</cfquery>
		</cfif>
	</cfif>
</cfif>
<div id="div_pro_material_paper">
<cf_grid_list>
	<thead>
		<tr>
			<th width="25"><cf_get_lang dictionary_id='57487.No'></th>
			<th width="70"><cf_get_lang dictionary_id='57880.Belge No'></th>
			<cfif attributes.line_based neq 1>
				<th><cf_get_lang dictionary_id='57519.cari hesap'></th>
				<th width="70"><cf_get_lang dictionary_id='57742.Tarih'></th>
				<th><cf_get_lang dictionary_id='38281.Planlayan'></th>
				<th width="15">
				<cfif not listfindnocase(denied_pages,'project.project_material')>
					<a href="<cfoutput>#request.self#?fuseaction=project.project_material&event=add&project_id=#attributes.id#</cfoutput>" target="_blank" > <i class="fa fa-plus" title="<cf_get_lang dictionary_id='37330.Malzeme Listesi'> <cf_get_lang dictionary_id='44630.Ekle'>"></i></a>
				</cfif>
				</th>
			<cfelse>
				<th width="70"><cf_get_lang dictionary_id='57518.Stok Kodu'></th>
				<th><cf_get_lang dictionary_id='57657.Ürün'></th>
				<th><cf_get_lang dictionary_id='57647.Spec'></th> 
				<th style="text-align:right;" ><cf_get_lang dictionary_id='57635.Miktar'></th> 
				<th><cf_get_lang dictionary_id='57636.Birim'></th> 
				<cfif session.ep.price_display_valid eq 0>
					<th style="text-align:right;"><cf_get_lang dictionary_id='58123.Planlama'> <cf_get_lang dictionary_id='58084.Fiyat'></th>
	                <th>Para Birimi</th>
				</cfif>
				<cfif session.ep.cost_display_valid eq 0>
					<th style="text-align:right;"><cf_get_lang dictionary_id='58258.Maliyet'></th> 
				</cfif>
				<th style="text-align:right;"><cf_get_lang dictionary_id='58084.Fiyat'></th> 
				<th width="85"><cf_get_lang dictionary_id='57489.Para Br.'></th>
				<th width="75" style="text-align:right;"><cf_get_lang dictionary_id="38194.Fatura Edilen"></th>
				<th width="120" style="text-align:right;"><cf_get_lang dictionary_id='58444.Kalan'></th>
				<th style="text-align:right;"><cf_get_lang dictionary_id="58456.Oran">%<input type="text" name="var_marj_0" id="var_marj_0" value="100" onBlur="hepsi('<cfoutput>#var_marj_#</cfoutput>');"></th>
				<th style="text-align:right;"><cf_get_lang dictionary_id='48183.Satış Fiyatı'></th> 
				<cfif attributes.line_based eq 1 and isdefined("attributes.from_paper") and len(attributes.from_paper)>
					<th><input type="checkbox" name="all_select" id="all_select" onClick="<cfoutput>#var_all_select_function#</cfoutput>('select');"></th>
				</cfif>
			</cfif>
		</tr>
	</thead>
    <tbody>
		<cfif GET_PRO_MATERIAL.recordcount>
			<cfoutput query="GET_PRO_MATERIAL">
            <tr>
                <td>#PRO_MATERIAL_ID#</td>
                <td><cfif not listfindnocase(denied_pages,'project.popup_upd_project_material')>#PRO_MATERIAL_NO#<cfelse>#PRO_MATERIAL_NO#</cfif></td>
                <cfif attributes.line_based neq 1>
                    <td><cfif len(GET_PRO_MATERIAL.company_id)>
                            <a href="javascript://" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_com_det&company_id=#company_id#');">#COMPANY_NAME.nickname[listfind(company_id_list,company_id,',')]#</a>
                        <cfelseif len(GET_PRO_MATERIAL.consumer_id)>
                            <a href="javascript://" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_con_det&con_id=#consumer_id#');"> #CONS_NAME.consumer_name[listfind(consumer_id_list,consumer_id,',')]#</a>
                        </cfif>
                    </td>
                    <td>#dateformat(ACTION_DATE,dateformat_style)#</td>
                    <td><cfif len(PLANNER_EMP_ID)><a href="javascript://" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_emp_det&EMP_ID=#PLANNER_EMP_ID#','medium');">#GET_EMP_ID.EMPLOYEE_NAME[listfind(emp_id_list,PLANNER_EMP_ID,',')]# #GET_EMP_ID.EMPLOYEE_SURNAME[listfind(emp_id_list,PLANNER_EMP_ID,',')]#</cfif></td>
                    <td><cfif not listfindnocase(denied_pages,'project.project_material')>
                            <a href="#request.self#?fuseaction=project.project_material&event=upd&upd_id=#get_pro_material.PRO_MATERIAL_ID#" target="_blank"> <i class="fa fa-pencil" title="<cf_get_lang dictionary_id='37330.Malzeme Listesi'> <cf_get_lang dictionary_id='58718.Düzenle'>"></i></a>
                        </cfif>
                    </td>
                <cfelse>
					<cfif isdefined('used_amount_#WRK_ROW_ID#') and len(Evaluate("used_amount_#WRK_ROW_ID#"))>
						<cfset kalan_miktar = AMOUNT - Evaluate("used_amount_#WRK_ROW_ID#")>
					<cfelse>
						<cfset kalan_miktar = AMOUNT>
						<cfset 'used_amount_#WRK_ROW_ID#' = 0 >
					</cfif>
					<cfif kalan_miktar lt 0><cfset kalan_miktar = 0></cfif>
					<td>#STOCK_CODE#</td>
					<td>#PRODUCT_NAME#</td>
					<td>#SPECT_VAR_ID#</td>
					<td style="text-align:right;">#tlformat(AMOUNT)#</td>
					<td>#UNIT#</td>
					<cfif session.ep.price_display_valid eq 0>
						<td style="text-align:right;"><cfif isdefined('project_plan_price#STOCK_ID#')>#tlformat(Evaluate('project_plan_price#STOCK_ID#'))#</cfif></td>
						<td style="text-align:right;"><cfif isdefined('project_plan_price#STOCK_ID#')>#session.ep.money#</cfif></td>
					</cfif>
					<cfif session.ep.cost_display_valid eq 0>
						<td style="text-align:right;">#tlformat(COST)#</td>
					</cfif>
					<td style="text-align:right;">#tlformat(PRICE_OTHER)#</td>
					<td>#OTHER_MONEY#</td>
					<td style="text-align:right;">#tlformat(Evaluate("used_amount_#WRK_ROW_ID#"))#</td>
					<td>
						<div class="form-group">
							<input type="text"  name="#var_row_amount_##PRO_MATERIAL_ROW_ID#" id="#var_row_amount_##PRO_MATERIAL_ROW_ID#" value="#tlformat(kalan_miktar)#" onKeyup="return(FormatCurrency(this,event,#rate_round_num#));" style="text-align:right;">
						</div>
					</td>
					<td><div class="form-group"><input type="text" name="#var_marj_##PRO_MATERIAL_ROW_ID#" id="#var_marj_##PRO_MATERIAL_ROW_ID#"  style="text-align:right;"  onKeyup="return(FormatCurrency(this,event,#rate_round_num#));" onBlur="#var_calc_marj_function#('marj',#PRO_MATERIAL_ROW_ID#);" value="100"></div></td>
					<td>
						<div class="form-group">
							<input type="hidden" name="rate_diff_#PRO_MATERIAL_ROW_ID#" id="rate_diff_#PRO_MATERIAL_ROW_ID#" value="#rate2/rate1#">
							<input type="hidden" name="hidden_#var_price_other_##PRO_MATERIAL_ROW_ID#" id="hidden_#var_price_other_##PRO_MATERIAL_ROW_ID#" value="#tlformat(PRICE_OTHER,rate_round_num)#" />
							<input type="text" name="#var_price_other_##PRO_MATERIAL_ROW_ID#" id="#var_price_other_##PRO_MATERIAL_ROW_ID#"  style="text-align:right;" value="#tlformat(OTHER_MONEY_VALUE/AMOUNT,rate_round_num)#" onKeyup="return(FormatCurrency(this,event,#rate_round_num#));" onBlur="#var_calc_marj_function#('price_other',#PRO_MATERIAL_ROW_ID#);">
						</div>
					</td>
                    <cfif attributes.line_based eq 1 and isdefined("attributes.from_paper") and len(attributes.from_paper)>
						<td><input type="checkbox" name="#var_row_check_##PRO_MATERIAL_ROW_ID#" id="#var_row_check_##PRO_MATERIAL_ROW_ID#" value="#PRO_MATERIAL_ROW_ID#"></td>
					</cfif>
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
<cfif GET_PRO_MATERIAL.recordcount>
	<cfif attributes.line_based eq 1 and isdefined("attributes.from_paper") and len(attributes.from_paper)>
		<div class="ui-info-bottom flex-end">
			<a href="javascript://" class="ui-btn ui-btn-success" onClick="<cfoutput>#var_all_select_function#</cfoutput>('add_basket');"><cf_get_lang dictionary_id='57582.Ekle'></a>
		</div>
	</cfif>
</cfif>
<cfif isdefined("attributes.from_paper") and len(attributes.from_paper)>
	<cfset from_paper=attributes.from_paper>
<cfelse>
	<cfset from_paper="">
</cfif>
<cfset adres="project.popup_ajax_list_pro_material_paper&id=#attributes.id#&line_based=#attributes.line_based#&from_paper=#from_paper#&maxrows=#attributes.maxrows#&order_type=#attributes.order_type#">
<cfif attributes.totalrecords gt attributes.maxrows>
    <cf_paging
        name="pro_material_paper"
        page="#attributes.page#" 
        maxrows="#attributes.maxrows#" 
        totalrecords="#attributes.totalrecords#" 
        startrow="#attributes.startrow#" 
        adres="#adres#"
        isAjax="1"
        target="div_pro_material_paper"
        is_iframe="1"
        >
</cfif>
</div>
<cfif attributes.line_based eq 1><!--- SATIR BAZINDA İSE --->
	<script type="text/javascript">
		var rate_round_num = "<cfoutput>#rate_round_num#</cfoutput>";
		function hepsi(nesne)
		{
			<cfif get_pro_material.recordcount>
			if(document.getElementById('var_marj_0').value.length!=0)/*değer boşdegilse çalıştır*/
			{
				<cfoutput query="get_pro_material">
					nesne_ = eval('document.getElementById( nesne + #get_pro_material.PRO_MATERIAL_ROW_ID#)');
					nesne_.value=document.getElementById('var_marj_0').value;
					#var_calc_marj_function#('marj','#get_pro_material.PRO_MATERIAL_ROW_ID#');
				</cfoutput>
			}
			</cfif>
		}
		<cfoutput>
		
		function #var_calc_marj_function#(type,id)
		{
			var hidden_price_other = filterNum(document.getElementById('hidden_#var_price_other_#'+id).value,rate_round_num);
			var price_other = filterNum(document.getElementById('hidden_#var_price_other_#'+id).value,rate_round_num);
			var price = price_other*document.getElementById("rate_diff_"+id).value;
			if(document.getElementById('#var_marj_#'+id) != undefined)
				var marj = filterNum(document.getElementById('#var_marj_#'+id).value,rate_round_num);
			else
				var marj = 1;
			
			if(type=='marj')
				document.getElementById('#var_price_other_#'+id).value = commaSplit(parseFloat(marj*hidden_price_other/100),rate_round_num);
			else if(type=='price_other' && document.getElementById('#var_marj_#'+id) != undefined  && hidden_price_other != 0)
				document.getElementById('#var_marj_#'+id).value = commaSplit(parseFloat(price_other*100/hidden_price_other),rate_round_num);
		}
		function #var_all_select_function#(type)</cfoutput>
		{
			<cfoutput query="get_pro_material">
				var row_amount = filterNum(document.getElementById('#var_row_amount_##PRO_MATERIAL_ROW_ID#').value,rate_round_num);
				var price_other = filterNum(document.getElementById('hidden_#var_price_other_##PRO_MATERIAL_ROW_ID#').value,rate_round_num);
				var price = price_other*document.getElementById("rate_diff_#PRO_MATERIAL_ROW_ID#").value;
				var product_name_ = "#Replace(Replace(PRODUCT_NAME,'"','','all'),"'","","all")#";
				var product_name2_ = "#Replace(Replace(PRODUCT_NAME2,'"','','all'),"'","","all")#";
				var my_obj = document.getElementById('#var_row_check_##PRO_MATERIAL_ROW_ID#');
				if(type=='select') my_obj.checked=(my_obj.checked==true)?false:true;
				else if(type=='add_basket')
					if(my_obj.checked==true)
						//satır wrk_row_id olusturulacak belgenin wrk_row_relation_id sine gonderilir
						opener.add_basket_row('#product_id#', '#stock_id#',	'#stock_code#', '#barcod#', '#manufact_code#',product_name_,'#unit_id#','#unit#','#spect_var_id#','#spect_var_name#', price, price_other,'#TAX#','#duedate#','#discount1#','#discount2#','#discount3#','#discount4#','#discount5#',0,0,0,0,0,'#DateFormat(deliver_date,dateformat_style)#','#deliver_location#-#deliver_dept#','#department_head#','','#other_money#',0,row_amount,'','#is_inventory#','#is_production#','#COST_PRICE#','#MARGIN#','#EXTRA_COST#',0,0,'#prom_cost#','#DISCOUNT_COST#',0,0,'#OTV_ORAN#',product_name2_,'#amount2#','#unit2#','#extra_price_other_total#','#shelf_number#','',	'',	1,0,'#basket_extra_info_id#','','','#list_price#','#number_of_installment#',-2,'','','#ek_tutar_price#','#WRK_ROW_ID#','#PRO_MATERIAL_ID#','PRO_MATERIAL','#width_value#','#depth_value#','#height_value#','','#row_project_id#','<cfif Len(row_project_id)>#get_project_name(row_project_id,0)#</cfif>','','','','#stock_code_2#','#basket_employee_id#','#get_emp_info(basket_employee_id,0,0)#','','','','','','','','#select_info_extra#','#detail_info_extra#','');
			</cfoutput>
		}
	</script>
</cfif>
