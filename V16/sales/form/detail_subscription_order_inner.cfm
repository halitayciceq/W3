<cfsetting showdebugoutput="no">
<cfquery name="get_periods" datasource="#dsn#">
	SELECT * FROM SETUP_PERIOD WHERE OUR_COMPANY_ID = #session.ep.company_id# ORDER BY PERIOD_YEAR DESC
</cfquery>
<cfset period_id_list = valuelist(get_periods.period_id)>
<cfquery name="get_system_inventory" datasource="#dsn2#">
            SELECT
                1 AS ACT_TYPE,
                I.INVENTORY_ID,
                I.ENTRY_DATE,
                I.INVENTORY_NUMBER,
                I.INVENTORY_NAME,
                case when IR.PROCESS_TYPE = 1182 THEN 'Demirbaş Stok İade Fişi' ELSE PTR.PROCESS_CAT    END AS PROCESS_CAT,
                IR.ACTION_ID AS FIS_ID,
               CASE 	 
                 <cfloop query="get_periods">
                  		WHEN SF_#period_id#.FIS_ID IS NOT NULL 
                     	THEN '#get_periods.PERIOD_ID#'
                  </cfloop>      
                  end AS  RELATED_PERIOD_ID,       
                          
                  CASE
                  	 <cfloop query="get_periods"> 		
                  		WHEN SF_#period_id#.FIS_ID IS NOT NULL 
                     	THEN SFR_#period_id#.AMOUNT 
                     </cfloop>
                  END AS AMOUNT,  
                         
				  CASE
                  	<cfloop query="get_periods"> 		
                  		WHEN SF_#period_id#.FIS_ID IS NOT NULL 
                     	THEN SF_#period_id#.FIS_TYPE 
					</cfloop>
                  END AS FIS_TYPE,
                    
					 CASE 	
                     	<cfloop query="get_periods"> 	
                  		WHEN SF_#period_id#.FIS_ID IS NOT NULL 
                     	THEN SF_#period_id#.FIS_DATE 
                        </cfloop>END AS FIS_DATE,
					 CASE 
                     	<cfloop query="get_periods"> 		
                  		WHEN SF_#period_id#.FIS_ID IS NOT NULL 
                     	THEN SF_#period_id#.FIS_NUMBER        
                        </cfloop>END AS FIS_NUMBER, 
                    CASE  
                 <cfloop query="get_periods">
                   		
                  		WHEN SF_#period_id#.FIS_ID IS NOT NULL 
                     	THEN SF_#period_id#.RELATED_SHIP_ID 
                  </cfloop>END AS RELATED_SHIP_ID,           
               	
		CASE
		  <cfloop query="get_periods">
                   WHEN SF_#period_id#.FIS_ID IS NOT NULL 
                   THEN SHIP_#period_id#.SHIP_NUMBER
                  </cfloop>END AS RELATED_SHIP_NUMBER,      
		CASE
		  <cfloop query="get_periods">
                   WHEN SF_#period_id#.FIS_ID IS NOT NULL 
                   THEN (SELECT TOP 1 PROCESS_CAT FROM #DSN3_ALIAS#.SETUP_PROCESS_CAT  PTR2 WHERE  PTR2.PROCESS_CAT_ID = SHIP_#PERIOD_ID#.PROCESS_CAT  )
                  </cfloop>END AS RELATED_PROCESS_CAT
			

                
            FROM
                #dsn3_alias#.INVENTORY I 
			JOIN
                #dsn3_alias#.INVENTORY_ROW IR
            ON
            	I.INVENTORY_ID = IR.INVENTORY_ID    
            JOIN    
            	#dsn3_alias#.STOCKS S
            ON
				IR.STOCK_ID = S.STOCK_ID and S.STOCK_ID = #attributes.stock_id# 
            LEFT JOIN
            	#dsn3_alias#.SETUP_PROCESS_CAT PTR
            ON
            	PTR.PROCESS_CAT_ID =  IR.PROCESS_TYPE
                	   
            <cfloop query="get_periods">
             LEFT JOIN
                #dsn#_#get_periods.period_year#_#session.ep.company_id#.STOCK_FIS SF_#period_id#
			 ON
              	SF_#period_id#.FIS_ID = IR.ACTION_ID  AND SF_#period_id#.FIS_TYPE IN(118,1182) AND SF_#period_id#.SUBSCRIPTION_ID = IR.SUBSCRIPTION_ID
             LEFT JOIN   
                #dsn#_#get_periods.period_year#_#session.ep.company_id#.STOCK_FIS_ROW SFR_#period_id# 
			 ON
            	SFR_#period_id#.FIS_ID = SF_#period_id#.FIS_ID AND 
                SFR_#period_id#.STOCK_ID = S.STOCK_ID AND 
                SFR_#period_id#.INVENTORY_ID = I.INVENTORY_ID
	    LEFT JOIN
		#dsn#_#get_periods.period_year#_#session.ep.company_id#.SHIP AS SHIP_#period_id#
	    ON
		SHIP_#period_id#.SHIP_ID = SF_#period_id#.RELATED_SHIP_ID 	
            </cfloop>
             
             	
                
            WHERE
                IR.PERIOD_ID in (<cfqueryparam cfsqltype="cf_sql_integer" value="#period_id_list#" list="yes">)
                AND
                IR.SUBSCRIPTION_ID = #attributes.subscription_id#
		UNION ALL
        <cfset count_ = 0>
        <cfloop query="get_periods">
            <cfset count_ = count_ + 1>
        SELECT
			2 AS ACT_TYPE,
			I.INVENTORY_ID,
			I.ENTRY_DATE,
			I.INVENTORY_NUMBER,
			I.INVENTORY_NAME,
			PTR.PROCESS_CAT,
            SF.INVOICE_ID FIS_ID,
            '#get_periods.PERIOD_ID#' AS RELATED_PERIOD_ID,
			SFR.AMOUNT,
			1182 FIS_TYPE,
			SF.INVOICE_DATE FIS_DATE,
			SF.INVOICE_NUMBER FIS_NUMBER,
			'' RELATED_SHIP_ID,
			'' AS RELATED_SHIP_NUMBER,
			'' AS RELATED_PROCESS_CAT
		FROM
			#dsn3_alias#.INVENTORY I,
			#dsn3_alias#.INVENTORY_ROW IR,
			#dsn3_alias#.INVENTORY_ROW IR2,
			#dsn3_alias#.STOCKS S,
			#dsn3_alias#.SETUP_PROCESS_CAT PTR,
			#dsn#_#get_periods.period_year#_#session.ep.company_id#.INVOICE SF,
			#dsn#_#get_periods.period_year#_#session.ep.company_id#.INVOICE_ROW SFR
		WHERE
			PTR.PROCESS_CAT_ID = SF.PROCESS_CAT AND
			S.STOCK_ID = #attributes.stock_id# AND
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
		<cfif get_periods.recordcount neq count_>UNION ALL</cfif>
	</cfloop>         
 </cfquery>
<table width="85%">
	<tr class="txtboldblue" height="22">
		<td nowrap><cf_get_lang_main no='330.Tarih'></td>
		<td nowrap><cf_get_lang_main no='1466.Demirbaş No'></td>
		<td nowrap><cf_get_lang_main no='217.Açıklama'></td>
		<td nowrap><cf_get_lang_main no='388.İşlem Tipi'></td>
		<td nowrap><cf_get_lang_main no='468.Belge No'></td>
		<td nowrap><cf_get_lang_main no='361.İrsaliye'> <cf_get_lang_main no='388.İşlem Tipi'></td>
		<td nowrap><cf_get_lang_main no='361.İrsaliye'> <cf_get_lang_main no='75.No'></td>
		<td align="right" nowrap style="text-align:right;"><cf_get_lang_main no='223.Miktar'></td>
	</tr>
	<cfoutput query="get_system_inventory">
		<tr>
			<td <cfif FIS_TYPE eq 1182>style="color:red;"</cfif> nowrap>#dateformat(FIS_DATE,dateformat_style)#</td>
			<td <cfif FIS_TYPE eq 1182>style="color:red;"</cfif> nowrap><a href="#request.self#?fuseaction=invent.detail_invent&inventory_id=#INVENTORY_ID#" class="tableyazi">#INVENTORY_NUMBER#</a></td>
			<td <cfif FIS_TYPE eq 1182>style="color:red;"</cfif> nowrap>#INVENTORY_NAME#</td>
			<td <cfif FIS_TYPE eq 1182>style="color:red;"</cfif> nowrap>#PROCESS_CAT#</td>
			<td <cfif FIS_TYPE eq 1182>style="color:red;"</cfif> nowrap>
				<cfif act_type eq 1>
					<cfif session.ep.period_id eq RELATED_PERIOD_ID><a href="#request.self#?fuseaction=invent.upd_invent_stock_fis<cfif FIS_TYPE eq 1182>_return</cfif>&fis_id=#FIS_ID#" class="tableyazi">#FIS_NUMBER#</a></cfif>
				<cfelse>
					<cfif session.ep.period_id eq RELATED_PERIOD_ID><a href="#request.self#?fuseaction=invent.upd_invent_sale&invoice_id=#FIS_ID#" class="tableyazi">#FIS_NUMBER#</a></cfif>
				</cfif>
			</td>
			<td <cfif FIS_TYPE eq 1182>style="color:red;"</cfif> nowrap>#RELATED_PROCESS_CAT#</td>
			<td <cfif FIS_TYPE eq 1182>style="color:red;"</cfif> nowrap><cfif len(RELATED_SHIP_ID) and session.ep.period_id eq RELATED_PERIOD_ID><a href="#request.self#?fuseaction=stock.form_upd_<cfif FIS_TYPE eq 1182>purchase<cfelse>sale</cfif>&ship_id=#RELATED_SHIP_ID#" class="tableyazi">#RELATED_SHIP_NUMBER#</a><cfelse>#RELATED_SHIP_NUMBER#</cfif></td>
			<td <cfif FIS_TYPE eq 1182>style="color:red;"</cfif> align="right" nowrap style="text-align:right;">#AMOUNT#</td>
		</tr>
	</cfoutput>
</table>
