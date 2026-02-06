<cfsetting showdebugoutput="no">
<cfquery name="get_periods" datasource="#dsn#">
	SELECT 
    	PERIOD_ID, 
        PERIOD, 
        PERIOD_YEAR, 
        OUR_COMPANY_ID, 
        RECORD_DATE, 
        RECORD_IP, 
        RECORD_EMP,
        UPDATE_DATE, 
        UPDATE_IP, 
        UPDATE_EMP, 
        IS_LOCKED, 
        PROCESS_DATE 
    FROM 
    	SETUP_PERIOD 
    WHERE
	    OUR_COMPANY_ID = #session.ep.company_id# 
    ORDER BY 
    	PERIOD_YEAR DESC
</cfquery>
<!---<cfquery name="get_system_inventory" datasource="#dsn2#">
    SELECT
        SUM(STOCK_ROW_SPE_TOTAL) AS TOTAL,
        PRODUCT_NAME,
        STOCK_ID
    FROM
        (
        <cfset count_ = 0>
        <cfloop query="get_periods">
            <cfset count_ = count_ + 1>
            SELECT
                S.PRODUCT_NAME,
                SFR.STOCK_ID,
                SUM(SFR.AMOUNT) AS STOCK_ROW_SPE_TOTAL
            FROM
                #dsn3_alias#.INVENTORY I,
                #dsn3_alias#.INVENTORY_ROW IR,
                #dsn3_alias#.STOCKS S,
                #dsn#_#get_periods.period_year#_#session.ep.company_id#.STOCK_FIS SF,
                #dsn#_#get_periods.period_year#_#session.ep.company_id#.STOCK_FIS_ROW SFR
            WHERE
                I.INVENTORY_ID = IR.INVENTORY_ID AND
                IR.ACTION_ID =  SF.FIS_ID AND
                SFR.FIS_ID =  SF.FIS_ID AND
                SFR.STOCK_ID = S.STOCK_ID AND
                SFR.INVENTORY_ID = I.INVENTORY_ID AND
                IR.PERIOD_ID = #get_periods.period_id# AND
                I.SUBSCRIPTION_ID = #attributes.subscription_id# AND
                SF.FIS_TYPE = 118
            GROUP BY
                S.PRODUCT_NAME,
                SFR.STOCK_ID
            <cfif get_periods.recordcount neq count_>UNION ALL</cfif>
        </cfloop>
        ) AS SATIRLAR
    GROUP BY
        PRODUCT_NAME,
        STOCK_ID
</cfquery>--->

<cfset period_id_list = valuelist(get_periods.period_id)>
<cfquery name="get_system_inventory1" datasource="#dsn2#">
    SELECT
        S.PRODUCT_NAME,
        S.STOCK_ID,
        IR.PROCESS_TYPE,
        SUM(
        <cfloop query="get_periods">
            <cfif currentrow neq  1>
                +   
            </cfif>
            ISNULL(SFR_#period_id#.AMOUNT,0)
        </cfloop>
        ) AS TOTAL
    FROM
        #dsn3_alias#.INVENTORY I
        JOIN
        #dsn3_alias#.INVENTORY_ROW IR 
        ON I.INVENTORY_ID = IR.INVENTORY_ID    
        JOIN    
        #dsn3_alias#.STOCKS S
        ON
        IR.STOCK_ID = S.STOCK_ID
    <cfloop query="get_periods">
         LEFT JOIN #dsn#_#get_periods.period_year#_#session.ep.company_id#.STOCK_FIS SF_#period_id# ON SF_#period_id#.FIS_ID = IR.ACTION_ID  AND SF_#period_id#.FIS_TYPE IN(118,1182)
         LEFT JOIN #dsn#_#get_periods.period_year#_#session.ep.company_id#.STOCK_FIS_ROW SFR_#period_id# ON SFR_#period_id#.FIS_ID = SF_#period_id#.FIS_ID AND SFR_#period_id#.STOCK_ID = S.STOCK_ID AND SFR_#period_id#.INVENTORY_ID = I.INVENTORY_ID
    </cfloop>
    WHERE
       IR.PERIOD_ID IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#period_id_list#" list="yes">) AND
       I.SUBSCRIPTION_ID = #attributes.subscription_id#
    GROUP BY
        S.PRODUCT_NAME,
        S.STOCK_ID,
        IR.PROCESS_TYPE
</cfquery>

<cfquery name="get_system_inventory" DBTYPE="QUERY">
  	SELECT * FROM get_system_inventory1 where PROCESS_TYPE = 118
</cfquery>

<cfquery name="get_system_inventory_return" DBTYPE="QUERY">
	SELECT * FROM get_system_inventory1 where PROCESS_TYPE = 1182
</cfquery>

<cfquery name="get_system_inventory_sale" datasource="#dsn2#">
    SELECT
        SUM(STOCK_ROW_SPE_TOTAL) AS TOTAL,
        PRODUCT_NAME,
        STOCK_ID
    FROM
        (
        <cfset count_ = 0>
        <cfloop query="get_periods">
            <cfset count_ = count_ + 1>
            SELECT
                S.PRODUCT_NAME,
                IR2.STOCK_ID,
                SUM(SFR.AMOUNT) AS STOCK_ROW_SPE_TOTAL
            FROM
                #dsn3_alias#.INVENTORY I,
                #dsn3_alias#.INVENTORY_ROW IR,
                #dsn3_alias#.INVENTORY_ROW IR2,
                #dsn3_alias#.STOCKS S,
                #dsn#_#get_periods.period_year#_#session.ep.company_id#.INVOICE SF,
                #dsn#_#get_periods.period_year#_#session.ep.company_id#.INVOICE_ROW SFR
            WHERE
                I.INVENTORY_ID = IR.INVENTORY_ID AND
                I.INVENTORY_ID = IR2.INVENTORY_ID AND
				IR2.PROCESS_TYPE = 118 AND
                IR.ACTION_ID =  SF.INVOICE_ID AND
                SFR.INVOICE_ID =  SF.INVOICE_ID AND
                IR2.STOCK_ID = S.STOCK_ID AND
                SFR.INVENTORY_ID = I.INVENTORY_ID AND
                IR.PERIOD_ID = #get_periods.period_id# AND
                I.SUBSCRIPTION_ID = #attributes.subscription_id# AND
                SF.INVOICE_CAT = 66
            GROUP BY
                S.PRODUCT_NAME,
                IR2.STOCK_ID
            <cfif get_periods.recordcount neq count_>UNION ALL</cfif>
        </cfloop>
        ) AS SATIRLAR
    GROUP BY
        PRODUCT_NAME,
        STOCK_ID
</cfquery>

<cfoutput query="get_system_inventory_return">
    <cfset 'return_stock_amount_#STOCK_ID#' = TOTAL>
</cfoutput>
<cfoutput query="get_system_inventory_sale">
    <cfset 'sale_stock_aount_#STOCK_ID#' = TOTAL>
</cfoutput>
<cf_flat_list>
	<thead>
        <tr>
            <th><cf_get_lang dictionary_id='57657.Ürün'></th>
            <th><cf_get_lang dictionary_id='57492.Toplam'></th>
            <th><cf_get_lang dictionary_id='29418.İade'></th>
            <th><cf_get_lang dictionary_id='57448.Satış'></th>
            <th><cf_get_lang dictionary_id='58444.Kalan'></th>
        </tr>
    </thead>
    <tbody>
		<cfif get_system_inventory.recordcount>
            <cfoutput query="get_system_inventory">
                <cfset asil_ = total>
                <cfif isdefined("return_stock_amount_#STOCK_ID#")>
                    <cfset iade_ = evaluate("return_stock_amount_#STOCK_ID#")>
                <cfelse>
                    <cfset iade_ = 0>
                </cfif> 
                <cfif isdefined("sale_stock_aount_#STOCK_ID#")>
                    <cfset sale_ = evaluate("sale_stock_aount_#STOCK_ID#")>
                <cfelse>
                    <cfset sale_ = 0>
                </cfif>
                <cfset deger_ = total - iade_ - sale_>
                <tr>
                    <td><a href="javascript://" onClick="gizle_goster(fis_detail_#STOCK_ID#);AjaxPageLoad('#request.self#?fuseaction=sales.emptypopup_ajax_detail_subscription_order_inner&subscription_id=#attributes.subscription_id#&stock_id=#stock_id#','fis_detail_div_#STOCK_ID#',1,'<cf_get_lang dictionary_id="58891.Yükleniyor">!');">#PRODUCT_NAME#</a></td>
                    <td align="right" class="txtbold" style="text-align:right;">#total#</td>
                    <td align="right" class="txtbold" style="text-align:right;">#iade_#</td>
                    <td align="right" class="txtbold" style="text-align:right;">#sale_#</td>
                    <td align="right" class="txtbold" style="text-align:right;">#deger_#</td>
                </tr>
                <tr id="fis_detail_#STOCK_ID#" style="display:none;">
                    <td colspan="5">
                        <div id="fis_detail_div_#STOCK_ID#"></div>
                    </td>
                </tr>
            </cfoutput>	
        <cfelse>
        <tr>
            <td colspan="5"><cf_get_lang dictionary_id='57484.Kayıt Yok'>!</td>
        </tr>
        </cfif>
     </tbody>
</cf_flat_list>



