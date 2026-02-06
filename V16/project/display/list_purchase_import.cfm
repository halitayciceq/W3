<cf_xml_page_edit fuseact="#fusebox.circuit#.popup_list_project_actions">
<cfsetting showdebugoutput="no">
<cfparam name="attributes.page" default="1">
<cfparam name="attributes.maxrows" default="#session.ep.maxrows#">
<cfparam name="attributes.order_type" default="date_desc">
<cfset attributes.startrow = ((attributes.page-1)*attributes.maxrows) + 1>
 <!--- ithal mal grişleri ve devamı --->
 <cfparam name="attributes.action_status" default=""><!--- aktif --->
<cfquery name="get_upd_purchase" datasource="#DSN2#">
WITH CTE1 AS (
	SELECT 
		COMPANY_ID, 
		PARTNER_ID, 
		CONSUMER_ID, 
		SHIP_NUMBER, 
		SHIP_DATE,
		SHIP_ID, 
		NETTOTAL,
		DELIVER_EMP,
        OTHER_MONEY,
        OTHER_MONEY_VALUE,
        SUBSCRIPTION_ID
	FROM 
		SHIP 
	WHERE
		<cfif isdefined("attributes.is_from_product")><!--- urun detayindan geliyorsa --->
			(SELECT TOP 1 SR.PRODUCT_ID FROM  SHIP_ROW SR WHERE SR.SHIP_ID = SHIP.SHIP_ID AND SR.PRODUCT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.id#">) IS NOT NULL AND
        <cfelseif isdefined("attributes.is_from_sales")><!--- abone detayindan geliyorsa --->    
			SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#URL.ID#"> AND
		<cfelse>
			PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#URL.ID#"> AND
		</cfif> 
        <cfif isdefined("attributes.action_status") and attributes.action_status eq 1>
               IS_SHIP_IPTAL = 0 AND
        <cfelseif isdefined("attributes.action_status") and attributes.action_status eq 0>
            	IS_SHIP_IPTAL = 1 AND
        </cfif>
		SHIP_TYPE = 811
		
     ),
       CTE2 AS (
            SELECT
                CTE1.*,
                ROW_NUMBER() OVER ( ORDER BY 
				<cfswitch expression = "#attributes.order_type#">
					<cfcase value="date_desc">
						SHIP_DATE DESC
					</cfcase>
					<cfcase value="date_asc">
						SHIP_DATE ASC
					</cfcase>
					<cfcase value="paperno_desc">
						SHIP_NUMBER DESC
					</cfcase>
					<cfcase value="paperno_asc">
						SHIP_NUMBER ASC
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
<cfif get_upd_purchase.recordcount>
    <cfparam name="attributes.totalrecords" default="#get_upd_purchase.query_count#">
<cfelse>
    <cfparam name="attributes.totalrecords" default="0">
</cfif>
<div id="div_purchase_import">
<cf_grid_list>
	<thead>
        <tr>
            <th width="30"><cf_get_lang dictionary_id='57487.No'></th>
            <th><cf_get_lang dictionary_id='57773.İrsaliye'> <cf_get_lang dictionary_id='57487.No'></th>
            <th><cf_get_lang dictionary_id='57775.Teslim Alan'></th>
            <th><cf_get_lang dictionary_id='57742.Tarih'></th>
            <cfif session.ep.price_display_valid eq 0>
                <th align="right"><cf_get_lang dictionary_id='57673.Tutar'></th>
                <th><cf_get_lang dictionary_id="58864.Para Br"></th>
                <cfif xml_exchange_amount eq 1>
                    <th><cf_get_lang dictionary_id="57677.Dövizli"> <cf_get_lang dictionary_id='57673.Tutar'></th>
                    <th><cf_get_lang dictionary_id="58864.Para Br"></th>
                </cfif>
            </cfif>
        </tr>
    </thead>
	<cfif get_upd_purchase.recordcount EQ 0>
        <tbody>
            <tr>
                <td colspan="8"><cf_get_lang dictionary_id='57484.Kayıt Bulunamadı'>!</td>
            </tr>
        </tbody>
	<cfelse>
		<cfoutput query="get_upd_purchase">
        <tbody>
            <tr>
                <td>#rownum#</td>
                <td><a href="#request.self#?fuseaction=objects.popup_detail_ship&ship_id=#ship_id#" target="_blank">
                #ship_number#</a></td>
                <td>#deliver_emp#</td>
                <td>#dateformat(SHIP_DATE,dateformat_style)#</td>
                <cfif session.ep.price_display_valid eq 0>
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
                </cfif>
            </tr>
        </tbody>
        </cfoutput>
	</cfif>
</cf_grid_list>
<cfset adres="project.popup_ajax_list_purchase_import&id=#attributes.id#&maxrows=#attributes.maxrows#&order_type=#attributes.order_type#">
<cfif isdefined("attributes.is_from_product")>
	<cfset adres = "#adres#&is_from_product=#attributes.is_from_product#">
</cfif>
<cfif isdefined("attributes.is_from_sales")>
	<cfset adres = "#adres#&is_from_sales=#attributes.is_from_sales#">
</cfif>
<cfif attributes.totalrecords gt attributes.maxrows>
    <cf_paging
        name="purchase_import"
        page="#attributes.page#" 
        maxrows="#attributes.maxrows#" 
        totalrecords="#attributes.totalrecords#" 
        startrow="#attributes.startrow#" 
        adres="#adres#"
        isAjax="1"
        target="div_purchase_import"
        is_iframe="1"
        >
</cfif>
</div>
