<!--- Satis Firsatlari --->	
<cfsetting showdebugoutput="no">
<cfparam name="attributes.action_status" default=""><!--- aktif --->
<cfparam name="attributes.page" default="1">
<cfparam name="attributes.maxrows" default="#session.ep.maxrows#">
<cfparam name="attributes.order_type" default="date_desc">
<cfset attributes.startrow = ((attributes.page-1)*attributes.maxrows) + 1>
<cfquery name="get_sale_opportunities" datasource="#dsn3#">
	WITH CTE1 AS (
	SELECT
		OPP_ID,
		COMPANY_ID,
		PARTNER_ID,
		CONSUMER_ID,
		OPP_DATE,
		OPP_NO,
		OPP_HEAD,
		OPP_DETAIL,
		SALES_EMP_ID
	FROM
		OPPORTUNITIES
	WHERE
    	<cfif isdefined("attributes.is_from_product")><!--- urun detayindan geliyorsa --->
			STOCK_ID = (SELECT STOCKS.STOCK_ID FROM #dsn1_alias#.STOCKS WHERE STOCKS.STOCK_ID = OPPORTUNITIES.STOCK_ID AND STOCKS.PRODUCT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#URL.ID#">)
		<cfelse>
			PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#URL.ID#"> 
		</cfif> 
         <cfif isdefined("attributes.action_status") and attributes.action_status eq 1>
            AND OPP_STATUS = 1  
        <cfelseif isdefined("attributes.action_status") and attributes.action_status eq 0>
             AND OPP_STATUS = 0
        </cfif>
    ),
       CTE2 AS (
            SELECT
                CTE1.*,
                ROW_NUMBER() OVER ( ORDER BY 
				<cfswitch expression = "#attributes.order_type#">
					<cfcase value="date_desc">
						OPP_DATE DESC
					</cfcase>
					<cfcase value="date_asc">
						OPP_DATE ASC
					</cfcase>
					<cfcase value="paperno_desc">
						OPP_NO DESC
					</cfcase>
					<cfcase value="paperno_asc">
						OPP_NO ASC
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
<cfif get_sale_opportunities.recordcount>
    <cfparam name="attributes.totalrecords" default="#get_sale_opportunities.query_count#">
<cfelse>
    <cfparam name="attributes.totalrecords" default="0">
</cfif>
<cfset company_id_list=''>
<cfset consumer_id_list=''>
<cfset emp_id_list=''>
<cfif get_sale_opportunities.recordcount>
	<cfoutput query="get_sale_opportunities">
		<cfif len(company_id) and not listFindnocase(company_id_list,company_id)>
			<cfset company_id_list = listappend(company_id_list,company_id)>
		</cfif>
		<cfif len(consumer_id) and not listFindnocase(consumer_id_list,consumer_id)>
			<cfset consumer_id_list = listappend(consumer_id_list,consumer_id)>
		</cfif>
		<cfif len(sales_emp_id) and not listfind(emp_id_list,sales_emp_id)>
			<cfset emp_id_list=listappend(emp_id_list,sales_emp_id)>
		</cfif>
	</cfoutput>
	<cfif listlen(company_id_list)>
		<cfset company_id_list=listsort(company_id_list,"numeric","ASC",",")>
		<cfquery name="company_name" datasource="#dsn#">
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
		<cfset company = company_name.fullname>
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
</cfif>
<div id="div_sale_opportunities">
<cf_grid_list>
	<thead>
		<tr>
			<th width="30"><cf_get_lang dictionary_id='57487.No'></th>
			<th><cf_get_lang dictionary_id='57880.Belge No'></th>
			<th><cf_get_lang dictionary_id='57519.cari hesap'></th>
			<th><cf_get_lang dictionary_id='57742.Tarih'></th>
			<th><cf_get_lang dictionary_id='38281.Planlayan'></th>
			<th width="20">
				<cfif not listfindnocase(denied_pages,'sales.form_add_opportunity')><a href="<cfoutput>#request.self#?fuseaction=sales.list_opportunity&event=add&project_id=#url.id#</cfoutput>" target="_blank" ><i class="fa fa-plus" title="<cf_get_lang dictionary_id='44630.Ekle'>"></i></a></cfif>
			</th>
		 </tr>
	 </thead>
	 <tbody>
	 <cfif get_sale_opportunities.recordcount>
          <cfoutput query="get_sale_opportunities">
           <tr>
              <td>#rownum#</td>
              <td><cfif not listfindnocase(denied_pages,'sales.form_upd_opportunity')><a href="#request.self#?fuseaction=sales.list_opportunity&event=det&opp_id=#opp_id#" target="_blank" >#opp_no#</a><cfelse>#opp_no#</cfif></td>
              <td><cfif len(get_sale_opportunities.company_id)>
                    <a href="javascript://" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_com_det&company_id=#company_id#','medium');" >#company_name.nickname[listfind(company_id_list,company_id,',')]#</a>
                    <cfif len(get_sale_opportunities.partner_id)> - #get_par_info(partner_id,0,-1,1)#</cfif>
                  <cfelseif len(get_sale_opportunities.consumer_id)>
                    <a href="javascript://" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_con_det&con_id=#consumer_id#','medium');" > #cons_name.consumer_name[listfind(consumer_id_list,consumer_id,',')]#</a>
                  </cfif>
              </td>
              <td>#dateformat(opp_date,dateformat_style)#</td>
              <td><cfif len(sales_emp_id)><a href="javascript://"  onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_emp_det&emp_id=#sales_emp_id#','medium');">#get_emp_id.employee_name[listfind(emp_id_list,sales_emp_id,',')]# #get_emp_id.employee_surname[listfind(emp_id_list,sales_emp_id,',')]#</cfif></td>
              <td width="20"><cfif not listfindnocase(denied_pages,'sales.form_upd_opportunity')><a href="#request.self#?fuseaction=sales.list_opportunity&event=det&opp_id=#opp_id#" target="_blank"><i class="fa fa-pencil" title="<cf_get_lang dictionary_id='57464.Güncelle'>"></a></cfif></td>
          </tr>
          </cfoutput>
      <cfelse>
          <tr>
              <td colspan="6"> <cf_get_lang dictionary_id='57484.Kayıt Yok'>!</td>
          </tr>						
      </cfif>
   </tbody>
</cf_grid_list>
<cfset adres="project.popup_ajax_list_sale_opportunities&id=#attributes.id#&maxrows=#attributes.maxrows#&order_type=#attributes.order_type#">
<cfif isdefined("attributes.is_from_product")>
<cfset adres = "#adres#&is_from_product=#attributes.is_from_product#">
</cfif>
<cfif attributes.totalrecords gt attributes.maxrows>
    <cf_paging
        name="sale_opportunities"
        page="#attributes.page#" 
        maxrows="#attributes.maxrows#" 
        totalrecords="#attributes.totalrecords#" 
        startrow="#attributes.startrow#" 
        adres="#adres#"
        isAjax="1"
        target="div_sale_opportunities"
        is_iframe="1"
        >
</cfif>
</div> 
