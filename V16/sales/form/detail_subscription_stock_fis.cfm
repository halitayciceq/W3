<cfsetting showdebugoutput="no">
<cfquery name="get_periods" datasource="#dsn#">
	SELECT 
        PERIOD_YEAR
    FROM
    	SETUP_PERIOD
    WHERE 
	    OUR_COMPANY_ID = #session.ep.company_id# 
    ORDER BY 
    	PERIOD_YEAR DESC
</cfquery>
<cfquery name="GET_STOCK_FIS_ROW" datasource="#DSN2#">
    SELECT
        FIS_ID,
        FIS_NUMBER,
        FIS_TYPE,
        STOCK_ID,
        AMOUNT,
        UNIT,
        PROCESS_CAT,
        FIS_DATE,
        FIS_PERIOD,
        LOCATION_OUT
    FROM
    (
        <cfset count_ = 0>
        <cfloop query="get_periods">
			<cfset count_ = count_ + 1>
            SELECT
                STOCK_FIS.FIS_ID,
                STOCK_FIS.FIS_NUMBER,
                STOCK_FIS.FIS_TYPE,
                STOCK_FIS_ROW.STOCK_ID,
                STOCK_FIS_ROW.AMOUNT,
                STOCK_FIS_ROW.UNIT,
                PTR.PROCESS_CAT,
                STOCK_FIS.FIS_DATE,
                #get_periods.period_year# FIS_PERIOD,
                STOCK_FIS.LOCATION_OUT
            FROM
                #dsn#_#get_periods.period_year#_#session.ep.company_id#.STOCK_FIS,
                #dsn#_#get_periods.period_year#_#session.ep.company_id#.STOCK_FIS_ROW,
                #dsn3_alias#.SETUP_PROCESS_CAT PTR
            WHERE
                STOCK_FIS.SUBSCRIPTION_ID = #attributes.subscription_id# AND
                STOCK_FIS.FIS_ID = STOCK_FIS_ROW.FIS_ID AND
                STOCK_FIS.PROCESS_CAT = PTR.PROCESS_CAT_ID
               -- AND STOCK_FIS.FIS_TYPE NOT IN (118,1182)
            GROUP BY
                STOCK_FIS.FIS_ID,
                STOCK_FIS.FIS_NUMBER,
                STOCK_FIS.FIS_TYPE,
                STOCK_FIS_ROW.STOCK_ID,
                STOCK_FIS_ROW.AMOUNT,
                STOCK_FIS_ROW.UNIT,
                PTR.PROCESS_CAT,
                STOCK_FIS.FIS_DATE,
                 STOCK_FIS.LOCATION_OUT
                <cfif get_periods.recordcount neq count_>
                UNION ALL
                </cfif>
        </cfloop>
    ) AS T1
    ORDER BY
        FIS_ID
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
    <cfif GET_STOCK_FIS_ROW.recordcount>
        <cfoutput query="GET_STOCK_FIS_ROW">
            <tr>
                <td>
                	 <cfswitch expression="#process_cat#">
                        <cfcase value="114">
                            <cfset url_param="#request.self#?fuseaction=stock.form_add_open_fis&event=upd&upd_id=">
                        </cfcase>
                        <cfcase value="118">
                            <cfset url_param="#request.self#?fuseaction=invent.upd_invent_stock_fis&fis_id=">
                        </cfcase>
                        <cfcase value="1182">
                            <cfset url_param="#request.self#?fuseaction=invent.upd_invent_stock_fis_return&fis_id=">
                        </cfcase>
                        <cfdefaultcase>
                            <cfset url_param="#request.self#?fuseaction=stock.form_add_fis&event=upd&upd_id=">
                        </cfdefaultcase>
                    </cfswitch>
                     <cfif FIS_PERIOD eq session.ep.period_year><a href="#url_param##FIS_ID#"  <cfif len(location_out)>style="color:##F00"<cfelse>class="tableyazi"</cfif>>#FIS_NUMBER#</a><cfelse><cfif len(location_out)><font  color="##FF0000">#FIS_NUMBER#</font><cfelse>#FIS_NUMBER#</cfif></cfif>
                </td>
                <td>#dateformat(FIS_DATE,dateformat_style)#</td>
                <td>
					<cfquery name="get_product_name" datasource="#dsn3#">
                    	SELECT PRODUCT_NAME FROM STOCKS WHERE STOCK_ID = #STOCK_ID#
                    </cfquery>
                    <cfif get_product_name.recordcount>#get_product_name.PRODUCT_NAME#</cfif> 
                </td>
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
