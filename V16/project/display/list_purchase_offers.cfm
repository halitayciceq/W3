<!--- ****attributes.from_paper**** ibaresi sayfanın hangi belgeden çağırıldığını TABLO ismi ile tutar,örn:fatudan ise INVOICE,siparişten ise OFFER gibi.. --->
<cf_xml_page_edit fuseact="#fusebox.circuit#.popup_list_project_actions">
<cfsetting showdebugoutput="no">
<cfparam name="attributes.page" default="1">
<cfparam name="attributes.maxrows" default="#session.ep.maxrows#">
<cfparam name="attributes.order_type" default="date_desc">
<cfset attributes.startrow = ((attributes.page-1)*attributes.maxrows) + 1>
<cfparam name="attributes.line_based" default="1"><!--- Satır Bazında--->
<cfparam name="attributes.purchase_sales" default="0"><!--- default olarak satinalma teklifleri --->
<cfparam name="attributes.action_status" default=""><!--- aktif --->
<cfparam name="rate_round_num" default="#session.ep.our_company_info.rate_round_num#">
<cfscript>
	var_row_check_ = 'row_check_#attributes.purchase_sales#_offer';
	var_price_other_ = 'price_#attributes.purchase_sales#_offer';
	var_marj_ = 'marj_#attributes.purchase_sales#_offer';
	var_row_amount_ = 'row_amount__#attributes.purchase_sales#_offer';
	var_all_select_function = 'allSelect_#attributes.purchase_sales#_offer';
	var_calc_marj_function = 'calc_marj_#attributes.purchase_sales#_offer';
</cfscript>
<!---Teklifler--->	
<cfquery name="get_purchase_OFFER" datasource="#dsn3#">
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
			(ISNULL(ORR.NET_MALIYET,0)+ISNULL(ORR.EXTRA_COST,0)) COST,
			ORR.NET_MALIYET AS COST_PRICE,
			ORR.EXTRA_COST,
			ORR.MARJ MARGIN,
			ORR.DISCOUNT_COST,
			ORR.OTV_ORAN,
			ORR.UNIT_ID,
			ORR.SPECT_VAR_NAME,
			ORR.STOCK_ID,
			ORR.QUANTITY AS AMOUNT,
			ORR.AMOUNT2,
			ORR.UNIT,
			ORR.UNIT2,
			ORR.PRICE,
			ISNULL(ORR.PRICE_OTHER,0) AS PRICE_OTHER,
			ORR.OTHER_MONEY ROW_OTHER_MONEY,
			ISNULL(ORR.OTHER_MONEY_VALUE,0) ROW_OTHER_MONEY_VALUE,
			ORR.SPECT_VAR_ID,
			ORR.WRK_ROW_ID,
			ORR.OFFER_ROW_ID,
			ORR.PRODUCT_ID,
			ORR.PRODUCT_NAME2,
			ORR.DISCOUNT_1,
			ORR.DISCOUNT_2,
			ORR.DISCOUNT_3,
			ORR.DISCOUNT_4,
			ORR.DISCOUNT_5,
			ORR.DISCOUNT_6,
			ORR.DISCOUNT_7,
			ORR.DISCOUNT_8,
			ORR.DISCOUNT_9,
			ORR.DISCOUNT_10,
			ORR.BASKET_EXTRA_INFO_ID,
			ORR.SELECT_INFO_EXTRA,
			ORR.DETAIL_INFO_EXTRA,
			ORR.DELIVER_DEPT,
			ORR.DELIVER_LOCATION,
			(	SELECT
					D.DEPARTMENT_HEAD + '-' + SL.COMMENT
				FROM
					#dsn_alias#.DEPARTMENT D,
					#dsn_alias#.STOCKS_LOCATION SL
				WHERE
					D.DEPARTMENT_ID = SL.DEPARTMENT_ID AND
					D.DEPARTMENT_ID = ORR.DELIVER_DEPT AND 
					SL.LOCATION_ID = ORR.DELIVER_LOCATION
			) DEPARTMENT_HEAD,
			ORR.DELIVER_DATE,
			ORR.DEPTH_VALUE,
			ORR.WIDTH_VALUE,
			ORR.HEIGHT_VALUE,
			ORR.SHELF_NUMBER,
			ORR.ROW_PROJECT_ID,
			ORR.EXTRA_PRICE_OTHER_TOTAL,
			ORR.EK_TUTAR_PRICE, <!--- Iscilik --->
			ORR.NUMBER_OF_INSTALLMENT,<!--- Taksit Sayisi --->
			ORR.DUEDATE,<!--- Vade --->
			ORR.PROM_COST,
			ORR.LIST_PRICE,
			ORR.BASKET_EMPLOYEE_ID,
			ISNULL(OFM.RATE2,1) RATE2,
			ISNULL(OFM.RATE1,1) RATE1,
			ISNULL(SM.RATE2,1) TODAY_RATE2,
			ISNULL(SM.RATE1,1) TODAY_RATE1,
			<cfif attributes.purchase_sales eq 1>
                S.TAX,
            <cfelse>
               S.TAX_PURCHASE AS TAX,
            </cfif>
        </cfif>
        O.OFFER_HEAD,
        O.OFFER_ID,
        O.OFFER_NUMBER,
        O.OFFER_DATE,
        O.SHIP_DATE,
        O.DELIVERDATE,
        O.COMPANY_ID,
        O.CONSUMER_ID,
		O.OFFER_TO,
		O.OFFER_TO_CONSUMER,
        O.RECORD_MEMBER,
        O.PRICE NETTOTAL,
        O.OFFER_ZONE,
        O.PURCHASE_SALES,
        O.OTHER_MONEY,
        O.OTHER_MONEY_VALUE
    FROM
        OFFER O
        <cfif attributes.line_based eq 1>
        ,STOCKS S
        ,OFFER_ROW ORR
		LEFT JOIN OFFER_MONEY OFM ON OFM.ACTION_ID = ORR.OFFER_ID AND OFM.MONEY_TYPE = ORR.OTHER_MONEY
		LEFT JOIN #dsn2_alias#.SETUP_MONEY SM ON SM.MONEY = ORR.OTHER_MONEY
        </cfif>
    WHERE
        <cfif attributes.line_based eq 1>
        ORR.STOCK_ID = S.STOCK_ID AND
        ORR.OFFER_ID = O.OFFER_ID AND
        <!--- Daha önceden belgeye çekilen ürünler bir daha gelmesin! --->
		<cfif isDefined("xml_") and ListGetAt(xml_,1,';') neq 1>
			WRK_ROW_ID NOT IN (
				SELECT 
					A5.FROM_WRK_ROW_ID FROM 
					(SELECT 
						SUM(RELATION_ROW.TO_AMOUNT) AS AMOUNT_OTHER,
						FROM_WRK_ROW_ID 
					FROM 
					   RELATION_ROW
					WHERE
						FROM_ACTION_ID = O.OFFER_ID AND 
						TO_TABLE ='#attributes.from_paper#' GROUP BY FROM_WRK_ROW_ID ) AS A5
				WHERE
					A5.FROM_WRK_ROW_ID=ORR.WRK_ROW_ID
					AND (ORR.QUANTITY-A5.AMOUNT_OTHER)<=0
			) AND
		</cfif>
        <!--- // Daha önceden belgeye çekilen ürünler bir daha gelmesin! --->
        </cfif>
		<cfif isdefined("attributes.is_from_product")><!--- urun detayindan geliyorsa --->
        	<cfif attributes.line_based eq 1>
			ORR.PRODUCT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#URL.ID#"> AND
			<cfelse>
			(SELECT TOP 1 ORR.PRODUCT_ID FROM  OFFER_ROW ORR WHERE ORR.OFFER_ID = O.OFFER_ID AND ORR.PRODUCT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.id#">) IS NOT NULL AND
			</cfif>
		<cfelse>
        	<cfif attributes.line_based eq 1>
            ORR.ROW_PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#URL.ID#"> AND
            <cfelse>
			O.PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#URL.ID#"> AND
            </cfif>
		</cfif> 
        <!---O.OFFER_STATUS = 1 AND--->
        <cfif attributes.purchase_sales eq 1>
        	(( O.PURCHASE_SALES = 1 AND O.OFFER_ZONE = 0 )  OR	( O.PURCHASE_SALES = 0 AND O.OFFER_ZONE = 1 )) 
        <cfelse><!--- SATIN ALMA ISE.. --->
       	 OFFER_ZONE = 0 AND PURCHASE_SALES=0 
        </cfif>
        <cfif isdefined("attributes.action_status") and attributes.action_status eq 1>
               AND OFFER_STATUS = 1
        <cfelseif isdefined("attributes.action_status") and attributes.action_status eq 0>
            AND  OFFER_STATUS = 0       
        </cfif>
          ),
       CTE2 AS (
            SELECT
                CTE1.*,
                ROW_NUMBER() OVER ( ORDER BY 
				<cfswitch expression = "#attributes.order_type#">
					<cfcase value="date_desc">
						OFFER_DATE DESC
					</cfcase>
					<cfcase value="date_asc">
						OFFER_DATE ASC
					</cfcase>
					<cfcase value="paperno_desc">
						OFFER_NUMBER DESC
					</cfcase>
					<cfcase value="paperno_asc">
						OFFER_NUMBER ASC
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
<cfif get_purchase_offer.recordcount>
    <cfparam name="attributes.totalrecords" default="#get_purchase_offer.query_count#">
<cfelse>
    <cfparam name="attributes.totalrecords" default="0">
</cfif>
<cfset company_id_list=''>
<cfset consumer_id_list=''>
<cfset emp_id_list=''>
<cfif get_purchase_OFFER.recordcount>
	<cfoutput query="get_purchase_OFFER">
		<cfif len(company_id) and not listFindnocase(company_id_list,company_id)>
			<cfset company_id_list = listappend(company_id_list,company_id)>
		<cfelseif len(listdeleteduplicates(offer_to)) and not listfind(company_id_list,listdeleteduplicates(offer_to))>
			<cfset company_id_list=listappend(company_id_list,listdeleteduplicates(offer_to))>
		</cfif>
		<cfif len(consumer_id) and not listFindnocase(consumer_id_list,consumer_id)>
			<cfset consumer_id_list = listappend(consumer_id_list,consumer_id)>
		<cfelseif len(listdeleteduplicates(offer_to_consumer)) and not listfind(consumer_id_list,listdeleteduplicates(offer_to_consumer))>
			<cfset consumer_id_list=listappend(consumer_id_list,listdeleteduplicates(offer_to_consumer))>
		</cfif>
		<cfif len(RECORD_MEMBER) and not listfind(emp_id_list,RECORD_MEMBER)>
			<cfset emp_id_list=listappend(emp_id_list,RECORD_MEMBER)>
		</cfif>
	</cfoutput>
	<cfif listlen(company_id_list)>
		<cfquery name="COMPANY_NAME" datasource="#dsn#">
			SELECT NICKNAME, COMPANY_ID, FULLNAME FROM COMPANY WHERE COMPANY_ID  IN (#company_id_list#) ORDER BY COMPANY_ID	
		</cfquery>
		<cfset company_id_list = listsort(listdeleteduplicates(valuelist(COMPANY_NAME.COMPANY_ID,',')),'numeric','ASC',',')>
	</cfif>	
	<cfif listlen(consumer_id_list)>
		<cfquery name="CONS_NAME" datasource="#dsn#">
		  SELECT  CONSUMER_NAME,  CONSUMER_SURNAME, COMPANY, CONSUMER_ID  FROM  CONSUMER  WHERE  CONSUMER_ID IN (#consumer_id_list#) ORDER BY CONSUMER_ID	  
		</cfquery>
		<cfset consumer_id_list = listsort(listdeleteduplicates(valuelist(CONS_NAME.CONSUMER_ID,',')),'numeric','ASC',',')>
	</cfif>
	<cfif len(emp_id_list)>
		<cfset emp_id_list=listsort(emp_id_list,"numeric","ASC",",")>
		<cfquery name="GET_EMP_ID" datasource="#DSN#">
			SELECT EMPLOYEE_NAME, EMPLOYEE_SURNAME, EMPLOYEE_ID FROM  EMPLOYEES WHERE EMPLOYEE_ID IN (#emp_id_list#) ORDER BY EMPLOYEE_ID
		</cfquery>
		<cfset emp_id_list = listsort(listdeleteduplicates(valuelist(GET_EMP_ID.EMPLOYEE_ID,',')),'numeric','ASC',',')>
	</cfif>
</cfif>
<cfif attributes.line_based eq 1>
<cfset OFFER_ID_list = listdeleteduplicates(ValueList(get_purchase_OFFER.OFFER_ID,','))>
<cfif len(OFFER_ID_list)>
	<cfquery name="GET_ALL_USED_AMOUNT" datasource="#DSN3#">
		SELECT 
			SUM(TO_AMOUNT) AMOUNT,
			FROM_WRK_ROW_ID
		FROM 
			RELATION_ROW
		WHERE
			FROM_ACTION_ID IN (#OFFER_ID_list#)
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
<cfset stock_id_list = ValueList(get_purchase_OFFER.STOCK_ID,',')>
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
	<cfset fuse_action_add = "purchase.list_offer&event=add">
	<cfset fuse_action_upd = "purchase.list_offer&event=upd">
<cfelse>
	<cfset fuse_action_add = "sales.list_offer&event=add">
	<cfset fuse_action_upd = "sales.list_offer&event=upd">
</cfif>
<cfif attributes.purchase_sales eq 0><cfset div_id = 'div_purchase_offers'><cfelse><cfset div_id = 'div_sale_offers'></cfif>
<div id="<cfoutput>#div_id#</cfoutput>">
<cf_grid_list>
	<thead>
		<tr>
			<th width="30"><cf_get_lang dictionary_id='57487.No'></th>
			<th><cf_get_lang dictionary_id='58820.Başlık'></th>
			<th><cf_get_lang dictionary_id='57880.Belge No'></th>
			<cfif attributes.line_based neq 1>
				<th><cf_get_lang dictionary_id='57519.Cari Hesap'></th>
				<th width="75"><cf_get_lang dictionary_id ='29501.Sipariş Tarihi'></th>
				<th width="75"><cf_get_lang dictionary_id ='38422.Sevk Tarihi'></th>
				<th width="75"><cf_get_lang dictionary_id ='57645.Teslim Tarihi'></th>
                <th align="right" width="60"><cf_get_lang dictionary_id='57673.Tutar'></th>
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
					<th style="text-align:right;"><cf_get_lang dictionary_id='58084.Fiyat'></th> 
					<th width="75"><cf_get_lang dictionary_id='38528.İskontolu'> <cf_get_lang dictionary_id="57677.Dövizli"> <cf_get_lang dictionary_id='57673.Tutar'></th>
					<th><cf_get_lang dictionary_id='58474.P Birimi'></th>
				</cfif>
				<th width="75" style="text-align:right;"><cf_get_lang dictionary_id="38194.Fatura Edilen"></th>
				<th style="text-align:right;"><cf_get_lang dictionary_id='58444.Kalan'></th>
				<th style="text-align:right;" nowrap><cf_get_lang dictionary_id="58456.Oran">%<input type="text" name="var_marj_0" id="var_marj_0" value="100"  onBlur="hepsi('<cfoutput>#var_marj_#</cfoutput>');"></th>
				<cfif session.ep.price_display_valid eq 0>
					<th style="text-align:right;"><cf_get_lang dictionary_id='57448.Satış'> <cf_get_lang dictionary_id='58084.Fiyat'></th>
				</cfif>
				<cfif attributes.line_based eq 1 and isdefined("attributes.from_paper") and len(attributes.from_paper)>
					<th><input type="checkbox" name="all_select" id="all_select" onClick="<cfoutput>#var_all_select_function#</cfoutput>('select');"></th>
				</cfif>
			</cfif>
			<th width="20"><a href="<cfoutput>#request.self#?fuseaction=#fuse_action_add#&project_id=#url.id#</cfoutput>" target="_blank" ><i class="fa fa-plus" title="<cf_get_lang dictionary_id='57582.Ekle'>"></i></a></th>
		</tr>
	</thead>
    <tbody>
	<cfif get_purchase_OFFER.recordcount>
		<cfoutput query="get_purchase_OFFER">
            <tr height="20" onmouseover="this.className='color-light';" onmouseout="this.className='color-row';" class="color-row">
                <td>#rownum#</td>
                <td>#OFFER_HEAD#</td>
                <td><cfif attributes.purchase_sales eq 1>
						<cfif get_module_user(11) and not listfindnocase(denied_pages,'sales.detail_offer_tv')>
							 <a href="#request.self#?fuseaction=sales.list_offer&event=upd&offer_id=#OFFER_ID#" target="_blank" >#offer_number#</a>
						<cfelse>
							 #offer_number#
						</cfif>
					<cfelse>
						<cfif get_module_user(12) and not listfindnocase(denied_pages,'purchase.detail_offer_ta')>
							<a href="#request.self#?fuseaction=purchase.list_offer&event=upd&offer_id=#OFFER_ID#" target="_blank" >#OFFER_NUMBER#</a>
						<cfelse>
							#offer_number#
						</cfif>
					</cfif>
                </td>
                <cfif attributes.line_based neq 1>
                    <td><cfif attributes.purchase_sales eq 1>
							<!--- Satis Teklifleri --->
							<cfif len(get_purchase_OFFER.company_id)>
								<a href="javascript://" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_com_det&company_id=#company_id#','medium');" >#COMPANY_NAME.nickname[listfind(company_id_list,company_id,',')]#</a>
							<cfelseif len(get_purchase_OFFER.consumer_id)>
								<a href="javascript://" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_con_det&con_id=#consumer_id#','medium');" >#CONS_NAME.consumer_name[listfind(consumer_id_list,consumer_id,',')]# #CONS_NAME.consumer_surname[listfind(consumer_id_list,consumer_id,',')]#</a>
							</cfif>
						<cfelse>
							<!--- Satinalma Teklifleri --->
							<cfif listlen(offer_to)>
								<cfloop list="#offer_to#" index="oc">
									<a href="javascript://" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_com_det&company_id=#oc#','medium');" >#company_name.nickname[listfind(company_id_list,oc,',')]#</a>
									<cfif listlast(offer_to) neq oc>,<br/></cfif>
								</cfloop>
							</cfif>
							<cfif listlen(offer_to)>,<br /></cfif>
							<cfif ListLen(offer_to_consumer)>
								<cfloop list="#offer_to_consumer#" index="oc">
									<a href="javascript://" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_con_det&con_id=#oc#','medium');" >#cons_name.consumer_name[listfind(consumer_id_list,oc,',')]# #cons_name.consumer_surname[listfind(consumer_id_list,oc,',')]#</a>
									<cfif listlast(offer_to_consumer) neq oc>,<br/></cfif>
								</cfloop>
							</cfif>
						</cfif>
                    </td>
                    <td>#dateformat(OFFER_DATE,dateformat_style)#</td>
                    <td>#dateformat(ship_date,dateformat_style)#</td>
                    <td>#dateformat(deliverdate,dateformat_style)#</td>
                    <td style="text-align:right;">#TLFormat(NETTOTAL,rate_round_num)#</td>
                    <td>#session.ep.money#</td>
                    <cfif xml_exchange_amount eq 1>
                        <td><cfif len(OTHER_MONEY_VALUE)>#TLFormat(OTHER_MONEY_VALUE)#</cfif></td>
                        <td>
                            <cfif len(OTHER_MONEY_VALUE)>
                                <cfif session.ep.period_year gte 2009 and len(OTHER_MONEY) and OTHER_MONEY is 'YTL'>#session.ep.money#
                                <cfelseif session.ep.period_year lt 2009 and len(OTHER_MONEY) and OTHER_MONEY is 'TL'>
                                <cfelse>#OTHER_MONEY#</cfif>
                            </cfif>
                        </td>
                    </cfif>
                    <td>
						<cfif len(record_member)>
							#GET_EMP_ID.EMPLOYEE_NAME[listfind(emp_id_list,RECORD_MEMBER,',')]# #GET_EMP_ID.EMPLOYEE_SURNAME[listfind(emp_id_list,RECORD_MEMBER,',')]#
						</cfif>
					</td>
                <cfelse>
					<td><cfif attributes.purchase_sales eq 1>
							<!--- Satis Teklifleri --->
							<cfif len(get_purchase_OFFER.company_id)>
								<!---<a href="javascript://" onclick="windowopen('#request.self#?fuseaction=objects.popup_com_det&company_id=#company_id#','medium');" >--->#COMPANY_NAME.nickname[listfind(company_id_list,company_id,',')]#<!---</a> --->
							<cfelseif len(get_purchase_OFFER.consumer_id)>
								<!---<a href="javascript://" onclick="windowopen('#request.self#?fuseaction=objects.popup_con_det&con_id=#consumer_id#','medium');" >--->#CONS_NAME.consumer_name[listfind(consumer_id_list,consumer_id,',')]# #CONS_NAME.consumer_surname[listfind(consumer_id_list,consumer_id,',')]#<!---</a>--->
							</cfif>
						<cfelse>
							<!--- Satinalma Teklifleri --->
							<cfif listlen(offer_to)>
								<cfloop list="#offer_to#" index="oc">
									<!---<a href="javascript://" onclick="windowopen('#request.self#?fuseaction=objects.popup_com_det&company_id=#oc#','medium');" >--->#company_name.nickname[listfind(company_id_list,oc,',')]#<!---</a>--->
									<cfif listlast(offer_to) neq oc>,<br/></cfif>
								</cfloop>
							</cfif>
							<cfif listlen(offer_to)>,<br /></cfif>
							<cfif ListLen(offer_to_consumer)>
								<cfloop list="#offer_to_consumer#" index="oc">
									<!---<a href="javascript://" onclick="windowopen('#request.self#?fuseaction=objects.popup_con_det&con_id=#oc#','medium');" >--->#cons_name.consumer_name[listfind(consumer_id_list,oc,',')]# #cons_name.consumer_surname[listfind(consumer_id_list,oc,',')]#<!---</a>--->
									<cfif listlast(offer_to_consumer) neq oc>,<br/></cfif>
								</cfloop>
							</cfif>
						</cfif>
                    </td>
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
					<td>#PRODUCT_NAME2#</td>
					<cfif session.ep.price_display_valid eq 0>
						<td style="text-align:right;"><cfif isdefined('project_plan_price#STOCK_ID#')>#tlformat(Evaluate('project_plan_price#STOCK_ID#'),rate_round_num)# #session.ep.money#</cfif></td>
					</cfif>
					<cfif session.ep.cost_display_valid eq 0>
						<td style="text-align:right;">#tlformat(COST,rate_round_num)#</td>
					</cfif>
					<cfif session.ep.price_display_valid eq 0>
						<td style="text-align:right;">#tlformat(PRICE_OTHER,rate_round_num)#</td>
						<td style="text-align:right;">
							<cfif len(row_other_money_value) and len(discount_1)>
								#TLFormat(price_other * ((100 - discount_1)/100))#
							</cfif>
						</td>
						<td>#ROW_OTHER_MONEY#</td>
					</cfif>
					<td style="text-align:right;">#tlformat(Evaluate("used_amount_#WRK_ROW_ID#"))#</td>
					<td><div class="form-group"><input type="text"  name="#var_row_amount_##OFFER_ROW_ID#" id="#var_row_amount_##OFFER_ROW_ID#" value="#tlformat(kalan_miktar)#" onKeyup="return(FormatCurrency(this,event,#rate_round_num#));"  style="text-align:right;"></div></td>
					<td><div class="form-group"><input type="text" name="#var_marj_##OFFER_ROW_ID#" id="#var_marj_##OFFER_ROW_ID#" onKeyup="return(FormatCurrency(this,event,#rate_round_num#));" onBlur="#var_calc_marj_function#('marj',#OFFER_ROW_ID#);" style="text-align:right;" value="100"></div></td>
					<cfif session.ep.price_display_valid eq 0>
						<td>
							<div class="form-group">
								<input type="hidden" name="rate_diff_#OFFER_ROW_ID#" id="rate_diff_#OFFER_ROW_ID#" value="#rate2/rate1#">
								<input type="hidden" name="rate_diff_today_#OFFER_ROW_ID#" id="rate_diff_today_#OFFER_ROW_ID#" value="#wrk_round(today_rate2/today_rate1,rate_round_num)#">
								<input type="hidden" name="hidden_sabit_price_other_#OFFER_ROW_ID#" id="hidden_sabit_price_other_#OFFER_ROW_ID#" value="#tlformat(PRICE_OTHER,rate_round_num)#" />
								<input type="hidden" name="hidden_#var_price_other_##OFFER_ROW_ID#" id="hidden_#var_price_other_##OFFER_ROW_ID#" value="#tlformat(PRICE_OTHER,rate_round_num)#" />
								<input type="hidden" name="hidden_other_money_value_#OFFER_ROW_ID#" id="hidden_other_money_value_#OFFER_ROW_ID#" value="#tlformat(ROW_OTHER_MONEY_VALUE/AMOUNT,rate_round_num)#">
								<input type="text" name="#var_price_other_##OFFER_ROW_ID#" id="#var_price_other_##OFFER_ROW_ID#" value="#tlformat(ROW_OTHER_MONEY_VALUE/AMOUNT,rate_round_num)#" onKeyup="return(FormatCurrency(this,event,#rate_round_num#));" style="text-align:right;" onBlur="#var_calc_marj_function#('price_other',#OFFER_ROW_ID#);">
							</div>
						</td>
					</cfif>
					<cfif attributes.line_based eq 1 and isdefined("attributes.from_paper") and len(attributes.from_paper)>
						<td><input type="checkbox" name="#var_row_check_##OFFER_ROW_ID#" id="#var_row_check_##OFFER_ROW_ID#" value="#OFFER_ROW_ID#"></td>
					</cfif>
				</cfif>
				<td><a href="#request.self#?fuseaction=#fuse_action_upd#&offer_id=#offer_id#" target="_blank" ><i class="fa fa-pencil" title="<cf_get_lang dictionary_id='57464.Güncelle'>"></i></a></td>
            </tr>
        </cfoutput>
		
	<cfelse>
        <tr>
            <td colspan="22"><cf_get_lang dictionary_id='57484.Kayıt Yok'> !</td>
        </tr>
	</cfif>
    </tbody>
</cf_grid_list>
<cfif get_purchase_OFFER.recordcount>
	<cfif attributes.line_based eq 1 and isdefined("attributes.from_paper") and len(attributes.from_paper)>
		<div class="ui-info-bottom flex-end">
			<cfoutput>#session.ep.money#</cfoutput><a href="javascript://" onClick="<cfoutput>#var_all_select_function#</cfoutput>('add_basket');" class="ui-btn ui-btn-success"><cf_get_lang dictionary_id='57582.Ekle'></a>
		</div>
	</cfif>
</cfif>
<cfset adres="project.popup_ajax_list_purchase_offers&id=#attributes.id#&line_based=#attributes.line_based#&purchase_sales=#attributes.purchase_sales#&maxrows=#attributes.maxrows#&order_type=#attributes.order_type#">
<cfif isdefined("attributes.from_paper")>
	<cfset adres = "#adres#&from_paper=#attributes.from_paper#">
</cfif>
<cfif isdefined("attributes.is_from_product")>
	<cfset adres = "#adres#&is_from_product=#attributes.is_from_product#">
</cfif>
<cfif attributes.totalrecords gt attributes.maxrows>
	<cfif attributes.purchase_sales eq 0>
    <cf_paging
        name="purchase_offers"
        page="#attributes.page#" 
        maxrows="#attributes.maxrows#" 
        totalrecords="#attributes.totalrecords#" 
        startrow="#attributes.startrow#" 
        adres="#adres#"
        isAjax="1"
        target="div_purchase_offers"
        is_iframe="1"
        >
	<cfelse>
    <cf_paging
        name="sale_offers"
        page="#attributes.page#" 
        maxrows="#attributes.maxrows#" 
        totalrecords="#attributes.totalrecords#" 
        startrow="#attributes.startrow#" 
        adres="#adres#"
        isAjax="1"
        target="div_sale_offers"
        is_iframe="1"
        >
	</cfif>
</cfif>
</div> 
<!--- SATIR BAZINDA İSE --->
<cfif attributes.line_based eq 1>
	<script type="text/javascript">
		var rate_round_num = "<cfoutput>#rate_round_num#</cfoutput>";
		function hepsi(nesne)
		{
			<cfif get_purchase_OFFER.recordcount>
			if(document.getElementById('var_marj_0').value.length!=0)/*değer boşdegilse çalıştır*/
			{
				<cfoutput query="get_purchase_OFFER">
					nesne_ = eval('document.getElementById( nesne + #get_purchase_OFFER.OFFER_ROW_ID#)');
					nesne_.value=document.getElementById('var_marj_0').value;
					#var_calc_marj_function#('marj','#get_purchase_OFFER.OFFER_ROW_ID#');
				</cfoutput>
			}
			</cfif>
		}
        <cfoutput>
		
        function #var_calc_marj_function#(type,id)
		{
			var price_other = filterNum(document.getElementById('hidden_other_money_value_'+id).value,rate_round_num);
			var hidden_price_other = filterNum(document.getElementById('hidden_#var_price_other_#'+id).value,rate_round_num);
			var hidden_sabit_price_other = filterNum(document.getElementById('hidden_sabit_price_other_'+id).value,rate_round_num);
			if(document.getElementById('#var_marj_#'+id) != undefined)
           		var marj = filterNum(document.getElementById('#var_marj_#'+id).value,rate_round_num);
			else
				var marj = 1;
            
			if(type=='marj')
			{
                document.getElementById('hidden_#var_price_other_#'+id).value = commaSplit(parseFloat(marj*hidden_sabit_price_other/100),rate_round_num);
				document.getElementById('#var_price_other_#'+id).value = commaSplit(parseFloat(marj*price_other/100),rate_round_num);
			}
            else if(type=='price_other' && document.getElementById('#var_marj_#'+id) != undefined  && price_other != 0)
			{
			    document.getElementById('#var_marj_#'+id).value = commaSplit(parseFloat(filterNum(document.getElementById('#var_price_other_#'+id).value)*100/price_other),rate_round_num);
				document.getElementById('hidden_#var_price_other_#'+id).value = commaSplit(parseFloat((document.getElementById('#var_price_other_#'+id).value)/parseFloat(document.getElementById('hidden_other_money_value_'+id).value))*parseFloat(hidden_sabit_price_other),rate_round_num);
			}
		}
		
        function #var_all_select_function#(type)</cfoutput>
		{
            <cfoutput query="get_purchase_OFFER">
                var row_amount = filterNum(document.getElementById('#var_row_amount_##OFFER_ROW_ID#').value,rate_round_num);
                var price_other = filterNum(document.getElementById('hidden_#var_price_other_##OFFER_ROW_ID#').value,rate_round_num);
				var price = price_other*document.getElementById("rate_diff_today_#OFFER_ROW_ID#").value;
				var product_name_ = "#Replace(Replace(PRODUCT_NAME,'"','','all'),"'","","all")#";
				var product_name2_ = "#Replace(Replace(PRODUCT_NAME2,'"','','all'),"'","","all")#";
                var my_obj = document.getElementById('#var_row_check_##OFFER_ROW_ID#');
                if(type=='select') my_obj.checked=(my_obj.checked==true)?false:true;
                else if(type=='add_basket')
                    if(my_obj.checked==true)
 						//satır wrk_row_id olusturulacak belgenin wrk_row_relation_id sine gonderilir
						opener.add_basket_row('#product_id#', '#stock_id#',	'#stock_code#', '#barcod#', '#manufact_code#',product_name_,'#unit_id#','#unit#','#spect_var_id#','#spect_var_name#', price, price_other,'#TAX#','#duedate#','#discount_1#','#discount_2#','#discount_3#','#discount_4#','#discount_5#','#discount_6#','#discount_7#','#discount_8#','#discount_9#','#discount_10#','#DateFormat(deliver_date,dateformat_style)#','#deliver_location#-#deliver_dept#','#department_head#','','#other_money#',0,row_amount,'','#is_inventory#','#is_production#','#COST_PRICE#','#MARGIN#','#EXTRA_COST#',0,0,'#prom_cost#','#DISCOUNT_COST#',0,0,'#OTV_ORAN#',product_name2_,'#amount2#','#unit2#','#extra_price_other_total#','#shelf_number#','',	'',	1,0,'#basket_extra_info_id#','#select_info_extra#','#detail_info_extra#','','','#list_price#','#number_of_installment#',-2,'','','#ek_tutar_price#','#WRK_ROW_ID#','#OFFER_ID#','OFFER','#width_value#','#depth_value#','#height_value#','','#row_project_id#','<cfif Len(row_project_id)>#get_project_name(row_project_id,0)#</cfif>','','','','#stock_code_2#','#basket_employee_id#','#get_emp_info(basket_employee_id,0,0)#');
            </cfoutput>
        }
    </script>
</cfif>
