<cf_xml_page_edit fuseact="#fusebox.circuit#.popup_list_project_actions">
<cfsetting showdebugoutput="no">
<cfparam name="attributes.page" default="1">
<cfparam name="attributes.maxrows" default="#session.ep.maxrows#">
<cfparam name="attributes.order_type" default="date_desc">
<cfset attributes.startrow = ((attributes.page-1)*attributes.maxrows) + 1>
<cfquery name="get_relational_invoice" datasource="#action_dsn2#">
WITH CTE1 AS (
	SELECT 
		INVOICE_ID,
		CONSUMER_ID,
		COMPANY_ID,
		PARTNER_ID,
		INVOICE_NUMBER,
		INVOICE_DATE,
		NETTOTAL,
		PURCHASE_SALES,
		IS_IPTAL,
		INVOICE_CAT,
        OTHER_MONEY,
        OTHER_MONEY_VALUE,
		SUBSCRIPTION_ID
		
	FROM 
		INVOICE
	WHERE
    	PURCHASE_SALES = #listFirst(attributes.purchase_sales,",")# AND
		<cfif isdefined("attributes.is_from_product")><!--- urun detayindan geliyorsa --->
			(SELECT TOP 1 IR.PRODUCT_ID FROM  INVOICE_ROW IR WHERE IR.INVOICE_ID = INVOICE.INVOICE_ID AND IR.PRODUCT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.id#">) IS NOT NULL AND
		<cfelseif isdefined("attributes.is_from_sales")><!--- abone detayindan geliyorsa --->
		    SUBSCRIPTION_ID	=<cfqueryparam cfsqltype="cf_sql_integer" value="#listLast(attributes.purchase_sales,",")#"> AND
		<cfelse>
			PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#URL.ID#"> AND
		</cfif> 
		IS_IPTAL = 0
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
<cfif get_relational_invoice.recordcount>
    <cfparam name="attributes.totalrecords" default="#get_relational_invoice.query_count#">
<cfelse>
    <cfparam name="attributes.totalrecords" default="0">
</cfif>
<cfif ListFirst(attributes.purchase_sales,',') eq 0>
	<cfset fuse_action_add = "invoice.form_add_bill_purchase">
	<cfset fuse_action_upd = "invoice.form_add_bill_purchase&event=upd">
<cfelse>
	<cfset fuse_action_add = "invoice.form_add_bill">
	<cfset fuse_action_upd = "invoice.form_add_bill&event=upd">
</cfif>
<cfif ListFirst(attributes.purchase_sales,',') eq 0><cfset div_id = 'div_purchase_invoices'><cfelse><cfset div_id = 'div_sale_invoices'></cfif>
<div id="<cfoutput>#div_id#</cfoutput>">
<cf_grid_list>
	<input name="form_varmi" id="form_varmi" value="1" type="hidden">
	<thead>
        <tr>
            <th width="30"><cf_get_lang dictionary_id='57487.No'></th>
            <th width="70"><cf_get_lang dictionary_id='57880.Belge No'></th>
            <th width="100"><cf_get_lang dictionary_id='57630.tip'></th>
            <th><cf_get_lang dictionary_id='57519.cari hesap'></th>
            <th width="55"><cf_get_lang dictionary_id='57742.Tarih'></th>
            <th width="100" align="right" style="text-align:right;"><cf_get_lang dictionary_id='57673.Tutar'></th>
            <th width="15"><cf_get_lang dictionary_id="58864.Para Br"></th>
            <cfif xml_exchange_amount eq 1>
            <th width="50"><cf_get_lang dictionary_id="57677.Dövizli"> <cf_get_lang dictionary_id="57673.Tutar"></th>
            <th width="15"><cf_get_lang dictionary_id="58864.Para Br"></th>
            </cfif>
            <cfif session.ep.period_id eq attributes.period_id><th width="20"><a href="<cfoutput>#request.self#?fuseaction=#fuse_action_add#&<cfif isdefined("attributes.is_from_sales")>subscription=#listLast(attributes.purchase_sales,",")#<cfelse>project_id=#url.id#</cfif></cfoutput>" target="_blank" class="tableyazi"><i class="fa fa-plus" title="<cf_get_lang dictionary_id='57582.Ekle'>"></i></a></th></cfif>
        </tr>
    </thead>
    <tbody>
	<cfif get_relational_invoice.recordcount>
		<cfoutput query="get_relational_invoice">
			<tr>
				<td>#rownum#</td>
				<cfif is_iptal eq 1>
				<cfset COLOR = "FF0000">
				<cfelseif is_iptal eq 0>
				<cfset COLOR = "000000">
				</cfif>
				<td>
                	<cfif purchase_sales eq 1>
						<cfif invoice_cat eq 52>
							<cfif get_module_user(20) and not listfindnocase(denied_pages,'invoice.add_bill_retail&event=upd')>
								 <a href="#request.self#?fuseaction=invoice.add_bill_retail&event=upd&iid=#invoice_id#" target="_blank" class="tableyazi">#Invoice_Number#</a>
							<cfelse>
								 #Invoice_Number#
							</cfif>
						<cfelse>
							<cfif get_module_user(20) and not listfindnocase(denied_pages,'invoice.form_add_bill&event=upd')>
								 <a href="#request.self#?fuseaction=invoice.form_add_bill&event=upd&iid=#invoice_id#" target="_blank" class="tableyazi">#Invoice_Number#</a>
							<cfelse>
								 #Invoice_Number#
							</cfif>
						</cfif>
					<cfelse>
						<cfif get_module_user(20) and not listfindnocase(denied_pages,'invoice.form_add_bill_purchase&event=upd')>
							<a href="#request.self#?fuseaction=invoice.form_add_bill_purchase&event=upd&iid=#invoice_id#" target="_blank" class="tableyazi">#Invoice_Number#</a>
						<cfelse>
							#Invoice_Number#
						</cfif>
					</cfif>
                	<!---<a href="#request.self#?fuseaction=objects.popup_detail_invoice&id=#invoice_id#&period_id=#attributes.period_id#" target="_blank" class="tableyazi">#INVOICE_NUMBER#</a>--->
                </td>
				<td><cfif purchase_sales eq 0><cf_get_lang dictionary_id="58176.Alış"><cfelse><cf_get_lang dictionary_id="57448.Satış"></cfif></td>
				<td><cfif len(CONSUMER_ID)>
				#GET_CONS_INFO(CONSUMER_ID,1,1)#
				<cfelseif len(COMPANY_ID) and len(PARTNER_ID)>
				#GET_PAR_INFO(PARTNER_ID,0,1,1)#
				</cfif>
				</td>
				<td>#dateformat(INVOICE_DATE,dateformat_style)#</td>
				<td style="text-align:right;">#TLFormat(NETTOTAL)#</td>
                <td>#SESSION.EP.MONEY#</td>
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
				<cfif session.ep.period_id eq attributes.period_id><td><a href="#request.self#?fuseaction=#fuse_action_upd#&iid=#invoice_id#" target="_blank"><i class="fa fa-pencil" title="<cf_get_lang dictionary_id='57464.Güncelle'>"></i></a></td></cfif>
			</tr>
		</cfoutput>
	<cfelse>
		<tr>
			<td colspan="9"><cf_get_lang dictionary_id='57484.Kayıtlı Bulunamadı'> !</td>
		</tr>
	</cfif>
    </tbody>
</cf_grid_list>
<cfset adres="project.popup_ajax_list_pro_invoice_expense&id=#attributes.id#&line_based=#attributes.line_based#&purchase_sales=#attributes.purchase_sales#&action_dsn2=#attributes.action_dsn2#&period_id=#attributes.period_id#&maxrows=#attributes.maxrows#&order_type=#attributes.order_type#">
<cfif isdefined("attributes.is_from_product")>
	<cfset adres = "#adres#&is_from_product=#attributes.is_from_product#">
</cfif>
<cfif isdefined("attributes.is_from_sales")>
	<cfset adres = "#adres#&is_from_sales=#attributes.is_from_sales#">
</cfif>
<cfif attributes.totalrecords gt attributes.maxrows>
	<cfif ListFirst(attributes.purchase_sales,',') eq 0>
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
