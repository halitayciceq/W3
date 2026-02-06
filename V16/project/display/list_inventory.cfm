<cfsetting showdebugoutput="no">
<cfparam name="attributes.page" default="1">
<cfparam name="attributes.maxrows" default="20">
<cfset attributes.startrow = ((attributes.page-1)*attributes.maxrows) + 1>
<cfquery name="get_actions" datasource="#dsn2#">
	SELECT
		INVOICE.INVOICE_NUMBER AS PAPER_NUMBER,
		(SELECT ISH.SHIP_NUMBER FROM INVOICE_SHIPS ISH WHERE ISH.INVOICE_ID = INVOICE.INVOICE_ID) AS DOC_NUMBER,
		INVOICE_CAT AS PROCESS_TYPE,
		INVOICE_DATE AS PROCESS_DATE,
		INVENTORY.INVENTORY_NUMBER,
		INVENTORY.INVENTORY_NAME DETAIL,
		(SELECT SH2.SHIP_TYPE FROM INVOICE_SHIPS ISH2,SHIP SH2 WHERE ISH2.INVOICE_ID = INVOICE.INVOICE_ID AND ISH2.SHIP_ID = SH2.SHIP_ID) AS ROW_PROCESS_TYPE,
		INVENTORY_ROW.QUANTITY,
		INVENTORY.INVENTORY_ID
	FROM
		INVOICE,
		#dsn3_alias#.INVENTORY_ROW,
		#dsn3_alias#.INVENTORY
	WHERE
		INVOICE_CAT IN (65,66)
		AND INVENTORY_ROW.ACTION_ID = INVOICE.INVOICE_ID
		AND INVENTORY_ROW.PROCESS_TYPE = INVOICE.INVOICE_CAT
		AND INVENTORY_ROW.INVENTORY_ID = INVENTORY.INVENTORY_ID
	
		<cfif isdefined("attributes.is_from_sales")><!--- abone detayindan geliyorsa --->  
		 	AND INVOICE.SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#URL.ID#">
		<cfelse>
			AND INVOICE.PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#URL.ID#">
		</cfif>	
	UNION ALL
			
	SELECT
		SHIP_NUMBER AS PAPER_NUMBER,
		'' AS DOC_NUMBER,
		SHIP_TYPE AS PROCESS_TYPE,
		SHIP_DATE AS PROCESS_DATE,
		INVENTORY.INVENTORY_NUMBER,
		INVENTORY.INVENTORY_NAME DETAIL,
		INVENTORY_ROW.PROCESS_TYPE ROW_PROCESS_TYPE,
		INVENTORY_ROW.QUANTITY,
		INVENTORY.INVENTORY_ID
	FROM
		SHIP,
		#dsn3_alias#.INVENTORY_ROW,
		#dsn3_alias#.INVENTORY
	WHERE
		SHIP_TYPE IN (82,83)
		AND INVENTORY_ROW.ACTION_ID = SHIP.SHIP_ID
		AND INVENTORY_ROW.PROCESS_TYPE = SHIP.SHIP_TYPE
		AND INVENTORY_ROW.INVENTORY_ID = INVENTORY.INVENTORY_ID
	
		<cfif isdefined("attributes.is_from_sales")><!--- abone detayindan geliyorsa --->  
		 	AND SHIP.SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#URL.ID#">
		<cfelse>
			AND SHIP.PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#URL.ID#">
		</cfif>
</cfquery>
<cfquery name="get_ships" datasource="#dsn2#">
	SELECT
		S.FIS_NUMBER AS PAPER_NUMBER,
		'' AS DOC_NUMBER,
		S.FIS_TYPE AS PROCESS_TYPE,
		S.FIS_DATE AS PROCESS_DATE,
		INVENTORY.INVENTORY_NUMBER,
		INVENTORY.INVENTORY_NAME DETAIL,
		NULL ROW_PROCESS_TYPE,
		SR.AMOUNT QUANTITY,
		INVENTORY.INVENTORY_ID
	FROM
		STOCK_FIS S,
		STOCK_FIS_ROW SR,
		STOCK_FIS_MONEY SM,
		#dsn3_alias#.INVENTORY
	WHERE
		INVENTORY.INVENTORY_ID = SR.INVENTORY_ID AND
		S.FIS_TYPE IN (118,1182)
		AND S.FIS_ID = SR.FIS_ID 
		AND S.FIS_ID = SM.ACTION_ID
		AND SM.IS_SELECTED = 1
		
		<cfif isdefined("attributes.is_from_sales")><!--- abone detayindan geliyorsa --->  
		 	AND S.SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#URL.ID#">
		<cfelse>
			AND S.PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#URL.ID#">
		</cfif>
	GROUP BY
		S.FIS_NUMBER,
		S.FIS_TYPE,
		S.FIS_DATE,
		INVENTORY_NUMBER,
		INVENTORY_NAME,
		SR.AMOUNT,
		INVENTORY.INVENTORY_ID
</cfquery>	
<cfquery name="get_all_actions" dbtype="query">
	SELECT  	
		PAPER_NUMBER,
		DOC_NUMBER,
		PROCESS_TYPE,
		PROCESS_DATE,
		INVENTORY_NUMBER,
		DETAIL,
		ROW_PROCESS_TYPE,
		QUANTITY,
		INVENTORY_ID
	FROM  
		GET_ACTIONS 
	GROUP BY 
		PAPER_NUMBER,
		DOC_NUMBER,
		PROCESS_TYPE,
		PROCESS_DATE,
		INVENTORY_NUMBER,
		DETAIL,
		ROW_PROCESS_TYPE,
		QUANTITY,
		INVENTORY_ID
	
	UNION ALL
	
	SELECT  
		PAPER_NUMBER,
		DOC_NUMBER,
		PROCESS_TYPE,
		PROCESS_DATE,
		INVENTORY_NUMBER,
		DETAIL,
		ROW_PROCESS_TYPE,
		QUANTITY,
		INVENTORY_ID
	FROM 
		GET_SHIPS 
	GROUP BY 
		PAPER_NUMBER,
		DOC_NUMBER,
		PROCESS_TYPE,
		PROCESS_DATE,
		INVENTORY_NUMBER,
		DETAIL,
		ROW_PROCESS_TYPE,
		QUANTITY,
		INVENTORY_ID
</cfquery>
<cfif get_all_actions.recordcount>
    <cfparam name="attributes.totalrecords" default="#get_all_actions.recordcount#">
<cfelse>
    <cfparam name="attributes.totalrecords" default="0">
</cfif>
<div id="div_inventory">
<cf_grid_list>
   <thead>
       <tr>
           <th><cf_get_lang dictionary_id="57742.Tarih"></th>
           <th><cf_get_lang dictionary_id="58878.Demirbaş No"></th>
           <th><cf_get_lang dictionary_id="57629.Açıklama"></th>
           <th><cf_get_lang dictionary_id="57800.İşlem Tipi"></th> 
           <th><cf_get_lang dictionary_id="57880.Belge No"></th>
		   <th><cf_get_lang dictionary_id="57773.İrsaliye"> <cf_get_lang dictionary_id="57800.İşlem Tipi"></th>
		   <th><cf_get_lang dictionary_id="58138.İrsaliye No"></th>
		   <th><cf_get_lang dictionary_id="57635.Miktar"></th>
		   <th width="20" style="text-align:right;"><a href="<cfoutput>#request.self#?fuseaction=invent.add_invent_stock_fis&<cfif isdefined("attributes.is_from_sales")>subscription=#url.id#<cfelse>project_id=#URL.ID#</cfif></cfoutput>" target="_blank" class="tableyazi"><i class="fa fa-plus" title="<cf_get_lang dictionary_id='57582.Ekle'>"></i></a></th>
       </tr>
	</thead>
	<tbody>
		<cfif get_all_actions.recordcount>
			<cfoutput query="get_all_actions" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
				<tr>
					<td>#dateFormat(process_date,dateformat_style)#</td>
					<td><a href="javascript://" onClick="windowopen('#request.self#?fuseaction=invent.list_inventory&event=det&inventory_id=#inventory_id#','wwide');"  class="tableyazi">#inventory_number#</a></td>
					<td>#detail#</td>
					<td>#get_process_name(process_type)#</td>
					<td>#paper_number#</td>
					<td>#get_process_name(row_process_type)#</td>
					<td>#doc_number#</td>
					<td>#quantity#</td>
					<td></td>
				</tr>
			</cfoutput>
		<cfelse>
			<tr>
				<td colspan="9"><cf_get_lang dictionary_id='57484.Kayıt Bulunamadı'> !</td>
			</tr>
		</cfif>
    </tbody>
</cf_grid_list>
<cfset adres="project.popup_ajax_list_project_inventory&id=#attributes.id#">
<cfif isdefined("attributes.is_from_product")>
	<cfset adres = "#adres#&is_from_product=#attributes.is_from_product#">
</cfif>
<cfif isdefined("attributes.is_from_sales")>
	<cfset adres = "#adres#&is_from_sales=#attributes.is_from_sales#">
</cfif>
<cfif attributes.totalrecords gt attributes.maxrows>
    <cf_paging
        name="inventory"
        page="#attributes.page#" 
        maxrows="#attributes.maxrows#" 
        totalrecords="#attributes.totalrecords#" 
        startrow="#attributes.startrow#" 
        adres="#adres#"
        isAjax="1"
        target="div_inventory"
        is_iframe="1"
        >
</cfif>
</div> 


