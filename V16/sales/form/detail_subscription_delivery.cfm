<cfsetting showdebugoutput="no">
<cfquery name="get_periods" datasource="#dsn#">
	SELECT 
    	PERIOD_ID, 
        PERIOD, 
        PERIOD_YEAR, 
        PERIOD_DATE, 
        OTHER_MONEY, 
        RECORD_DATE, 
        RECORD_IP, 
        RECORD_EMP, 
        UPDATE_DATE, 
        UPDATE_IP, 
        UPDATE_EMP,
        PROCESS_DATE 
    FROM
    	SETUP_PERIOD
    WHERE 
	    OUR_COMPANY_ID = #session.ep.company_id# 
    ORDER BY 
    	PERIOD_YEAR DESC
</cfquery>

<cfquery name="GET_SHIP_ROW" datasource="#DSN2#">
    SELECT
        SHIP_ID,
        SHIP_NUMBER,
        SHIP_TYPE,
        PURCHASE_SALES,
        NAME_PRODUCT,
        AMOUNT,
        UNIT,
        PROCESS_CAT,
        SHIP_DATE,
        SHIP_PERIOD
    FROM
    (
        <cfset count_ = 0>
        <cfloop query="get_periods">
			<cfset count_ = count_ + 1>
            SELECT
                SHIP.SHIP_ID,
                SHIP.SHIP_NUMBER,
                SHIP.SHIP_TYPE,
                SHIP.PURCHASE_SALES,
                SHIP_ROW.NAME_PRODUCT,
                SHIP_ROW.AMOUNT,
                SHIP_ROW.UNIT,
                PTR.PROCESS_CAT,
                SHIP.SHIP_DATE,
                #get_periods.period_year# SHIP_PERIOD
            FROM
                #dsn#_#get_periods.period_year#_#session.ep.company_id#.SHIP,
                #dsn#_#get_periods.period_year#_#session.ep.company_id#.SHIP_ROW,
                #dsn3_alias#.SETUP_PROCESS_CAT PTR
            WHERE
                SHIP.SUBSCRIPTION_ID = #attributes.subscription_id# AND
                SHIP.SHIP_ID = SHIP_ROW.SHIP_ID AND
                SHIP.PROCESS_CAT = PTR.PROCESS_CAT_ID AND
				SHIP.IS_SHIP_IPTAL= 0
            GROUP BY
                SHIP.SHIP_ID,
                SHIP.SHIP_NUMBER,
                SHIP.SHIP_TYPE,
                SHIP.PURCHASE_SALES,
                SHIP_ROW.NAME_PRODUCT,
                SHIP_ROW.AMOUNT,
                SHIP_ROW.UNIT,
                PTR.PROCESS_CAT,
                SHIP.SHIP_DATE
                <cfif get_periods.recordcount neq count_>
                UNION ALL
                </cfif>
        </cfloop>
    ) AS T1
    ORDER BY
        SHIP_ID
</cfquery>
<cf_flat_list>
	<thead>
        <tr>
            <th><cf_get_lang dictionary_id='57487.No'></th>
            <th width="65"><cf_get_lang dictionary_id='57742.Tarih'></th>
            <th><cf_get_lang dictionary_id='57657.Ürün'></th>
            <th width="70"><cf_get_lang dictionary_id='57635.Miktar'></th>
            <th width="50"><cf_get_lang dictionary_id='57636.Birim'></th>
            <th width="100"><cf_get_lang dictionary_id='57800.İşlem Tipi'></th>
        </tr>
    </thead>
    <tbody>
        <cfif GET_SHIP_ROW.recordcount>
            <cfoutput query="GET_SHIP_ROW">
                <tr>
                    <td>
                        <cfif PURCHASE_SALES>
                            <cfif ship_period eq session.ep.period_year><a href="#request.self#?fuseaction=stock.form_add_sale&event=upd&ship_id=#SHIP_ID#">#SHIP_NUMBER#</a><cfelse>#SHIP_NUMBER#</cfif>
                        <cfelse>
                            <cfif ship_period eq session.ep.period_year><a href="#request.self#?fuseaction=stock.form_add_purchase&event=upd&ship_id=#SHIP_ID#">#SHIP_NUMBER#</a><cfelse>#SHIP_NUMBER#</cfif>
                        </cfif>
                    </td>
                    <td>#dateformat(SHIP_DATE,dateformat_style)#</td>
                    <td>#NAME_PRODUCT#</td>
                    <td>#TLFormat(AMOUNT)#</td>
                    <td>#unit#</td>
                    <td>#PROCESS_CAT#</td>
                </tr>
            </cfoutput>
        <cfelse>
            <tr>
                <td colspan="6"><cf_get_lang dictionary_id='57484.Kayıt Yok'></td>
            </tr>
        </cfif>
    </tbody>
<cf_flat_list>
