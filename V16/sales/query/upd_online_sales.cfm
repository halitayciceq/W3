<cfloop from="1" to="#listlen(order_list,',')#" index="i">
	<cfquery name="GET_ORDER_ROWS" datasource="#DSN3#">
		SELECT PRODUCT_ID, STOCK_ID, PRICE, PRICE_KDV FROM ORDER_PRE_ROWS WHERE ORDER_ROW_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#listgetat(order_list,i,',')#">
	</cfquery>
	<!---<cfif (get_order_rows.price neq filterNum(evaluate('attributes.price#listgetat(order_list,i,',')#'))) or (get_order_rows.price_kdv neq filterNum(evaluate('attributes.price_kdv#listgetat(order_list,i,',')#')))>
		<cfquery name="ADD_HISTORY" datasource="calisma">
			INSERT INTO
				ORDER_PRE_ROWS_HISTORY
				(
					PRODUCT_ID,
					STOCK_ID,
					PRICE,
					PRICE_KDV,
					PRICE_KDV_OLD,
					PRICE_OLD,
					RECORD_EMP,
					RECORD_IP,
					RECORD_DATE 
				)
				VALUES
				(
					#get_order_rows.product_id#,
					#get_order_rows.stock_id#,
					#filterNum(evaluate('attributes.price#listgetat(order_list,i,',')#'))#,
					#filterNum(evaluate('attributes.price_kdv#listgetat(order_list,i,',')#'))#,
					#get_order_rows.price_kdv#,
					#get_order_rows.price#,
					#session.ep.userid#,
					'#CGI.REMOTE_ADDR#',
					#now()#
				)
		</cfquery>	
	</cfif>--->
	<cfquery name="UPD_ONLINE_SALES" datasource="#DSN3#">
		UPDATE
			ORDER_PRE_ROWS
		SET
			QUANTITY = #filterNum(evaluate('attributes.quantity#listgetat(order_list,i,',')#'))#,
			PRICE = #filterNum(evaluate('attributes.price#listgetat(order_list,i,',')#'))#,
			PRICE_KDV = #filterNum(evaluate('attributes.price_kdv#listgetat(order_list,i,',')#'))#
		WHERE
			ORDER_ROW_ID = #listgetat(order_list,i,',')#
	</cfquery>
</cfloop>
<cfif attributes.fuseaction contains 'emptypopup_upd_online_sales'>
	<cflocation url="#request.self#?fuseaction=sales.list_online_sales" addtoken="No">
</cfif>

