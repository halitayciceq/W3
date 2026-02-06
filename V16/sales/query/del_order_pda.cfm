<cfset attributes.action_id=attributes.ORDER_ID>
<cfset attributes.action_section="ORDER_ID">
<cfinclude template="../../objects/query/del_assets.cfm">
<cflock name="#CreateUUID()#" timeout="60">
	<cftransaction>
	<cfquery name="DEL_ORDER_PLUS" datasource="#DSN3#">
		DELETE FROM ORDER_PLUS WHERE ORDER_ID = #attributes.order_id#
	</cfquery>
	<!--- urun asortileri siliniyor --->
	<cfquery name="DEL_OFFER_ASSORT_ROWS" datasource="#DSN3#">
		DELETE FROM
			PRODUCTION_ASSORTMENT
		WHERE
			ACTION_TYPE = 2 AND 
			ASSORTMENT_ID IN (
								SELECT
									ORDER_ROW_ID 
								FROM
									ORDER_ROW
								WHERE
									ORDER_ID = #attributes.order_id#			
							 )
	</cfquery>
	<!---  satır history siliniyor  --->
	<cfquery name="DEL_ORDER_ROW_HISTORY" datasource="#DSN3#">
		DELETE FROM 
			ORDER_ROW_HISTORY 
		WHERE 
			ORDER_HISTORY_ID IN (
									SELECT
										ORDER_HISTORY_ID 
									FROM
										ORDERS_HISTORY
									WHERE	
										ORDERS_HISTORY.ORDER_ID = #attributes.order_id#
								)
	</cfquery>
	<!--- Sisteme ait siparisler --->
	<cfquery name="DEL_CONTRACT_ORDER" datasource="#DSN3#">
		DELETE FROM	SUBSCRIPTION_CONTRACT_ORDER	WHERE ORDER_ID = #attributes.order_id#
	</cfquery>
	<cfquery name="DEL_ORDERS_HISTORY" datasource="#DSN3#">
		DELETE FROM ORDERS_HISTORY WHERE ORDER_ID = #attributes.order_id#
	</cfquery>
	<cfquery name="DEL_ORDER_MONEY" datasource="#DSN3#">
		DELETE FROM ORDER_MONEY WHERE ACTION_ID = #attributes.order_id#
	</cfquery>
	<!--- siparis satır rezerveleri siliniyor --->
	<cfquery name="DEL_ORDER_RESERVE" datasource="#dsn3#">
		DELETE FROM ORDER_ROW_RESERVED WHERE ORDER_ID = #attributes.order_id# AND SHIP_ID IS NULL
	</cfquery>
	<cfquery name="DEL_PAPER_RELATION" datasource="#dsn3#"> <!---proje malzeme planı baglantısı siliniyor  --->
		DELETE 
			FROM #dsn_alias#.PAPER_RELATION
		WHERE
			PAPER_ID = #attributes.order_id#
			AND PAPER_TABLE = 'ORDERS'
			AND PAPER_TYPE_ID = 1
	</cfquery>
	<cfquery name="DEL_ORDER_PRODUCTS" datasource="#DSN3#">
		DELETE FROM ORDER_ROW WHERE	ORDER_ID = #attributes.order_id#
	</cfquery>
	<cfquery name="DEL_ORDER" datasource="#DSN3#">
		DELETE FROM	ORDERS WHERE ORDER_ID = #attributes.order_id#
	</cfquery>
	<cfif not isdefined("add_order_error") or add_order_error eq 0>
		<cfif isDefined("session.pda")>
			<cf_add_log  log_type="-1" action_id="#attributes.order_id#" action_name="#attributes.head#" data_source="#DSN3#">
		<cfelse>
			<cf_add_log  log_type="-1" action_id="#attributes.order_id#" action_name="#attributes.head#" data_source="#DSN3#">
		</cfif>		
	</cfif>
	</cftransaction>
</cflock>

