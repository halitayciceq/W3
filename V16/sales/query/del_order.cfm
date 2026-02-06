<cfset attributes.action_id=attributes.order_id>
<cfset attributes.action_section="ORDER_ID">
<cfif not isdefined("add_relation_rows")>
    <cfinclude template="../../objects/functions/add_relation_rows.cfm"><!--- sip,irs,fat satırlarının birbiri ile ilişkileri.. --->
</cfif>
<cfinclude template="../../objects/query/del_assets.cfm">
<cftransaction isolation="repeatable_read" action="begin">
	<cftry>
		<cfif not isdefined("new_dsn3")><cfset new_dsn3 = dsn3></cfif>
		<!---sipariş silindiğinde parçalı cari ödeme planı sablonu silinir --->
		<cfquery name="DEL_PAYMENT_PLANS" datasource="#new_dsn3#">
			DELETE FROM ORDER_PAYMENT_PLAN_ROWS WHERE PAYMENT_PLAN_ID IN (ISNULL((SELECT PAYMENT_PLAN_ID FROM ORDER_PAYMENT_PLAN WHERE ACTION_ID = #attributes.order_id#),0))
		</cfquery>
		<cfquery name="DEL_PAYMENT_PLANS" datasource="#new_dsn3#">
			DELETE FROM ORDER_PAYMENT_PLAN WHERE ACTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.order_id#">
		</cfquery>
	
		<!--- satis takipleri update ediliyor --->
		<cfquery name="UPD_ORDER_DEMANDS" datasource="#new_dsn3#">
			UPDATE ORDER_DEMANDS SET DEMAND_STATUS = 0 WHERE ORDER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.order_id#">
		</cfquery>	
		<cfquery name="GET_ORDER_ROW_DEMAND" datasource="#new_dsn3#">
			SELECT QUANTITY,ORDER_ROW_ID FROM ORDER_ROW WHERE ORDER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.order_id#">
		</cfquery>
		<cfoutput query="get_order_row_demand">
			<cfquery name="GET_DEMAND" datasource="#new_dsn3#">
				SELECT * FROM ORDER_DEMANDS_ROW WHERE ORDER_ROW_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_order_row_demand.order_row_id#">
			</cfquery>
			<cfif get_demand.recordcount>
				<cfquery name="UPD_DEMAND" datasource="#new_dsn3#">
					UPDATE ORDER_DEMANDS SET GIVEN_AMOUNT = GIVEN_AMOUNT - #get_order_row_demand.quantity# WHERE DEMAND_ID = #get_demand.demand_id#
				</cfquery>
				<cfquery name="DEL_DEMAND_ROW" datasource="#new_dsn3#">
					DELETE FROM ORDER_DEMANDS_ROW WHERE ORDER_ROW_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_order_row_demand.order_row_id#">
				</cfquery>
			</cfif>
		</cfoutput>
		<cfquery name="GET_ORD_DET_" datasource="#new_dsn3#">
			SELECT ORDER_ID,ORDER_HEAD,ORDER_NUMBER,ORDER_STAGE FROM ORDERS WHERE ORDER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.order_id#">
		</cfquery>
		<cfquery name="DEL_ORDER_PLUS" datasource="#new_dsn3#">
			DELETE FROM ORDER_PLUS WHERE ORDER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.order_id#">
		</cfquery>
		
		<!--- urun asortileri siliniyor --->
		<cfquery name="DEL_OFFER_ASSORT_ROWS" datasource="#new_dsn3#">
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
										ORDER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.order_id#">	
								 )
		</cfquery>
		<!--- Sisteme ait siparisler --->
		<cfquery name="DEL_CONTRACT_ORDER" datasource="#new_dsn3#">
			DELETE FROM	SUBSCRIPTION_CONTRACT_ORDER	WHERE ORDER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.order_id#">
		</cfquery>
		<cfquery name="DEL_ORDER_MONEY" datasource="#new_dsn3#">
			DELETE FROM ORDER_MONEY WHERE ACTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.order_id#">
		</cfquery>
		<!--- siparis satır rezerveleri siliniyor --->
		<cfquery name="DEL_ORDER_RESERVE" datasource="#new_dsn3#">
			DECLARE @RetryCounter INT
			SET @RetryCounter = 1
			RETRY:
			BEGIN TRY
				DELETE 
					FROM 
						ORDER_ROW_RESERVED 
					WHERE 
						ORDER_ID = #attributes.order_id# AND SHIP_ID IS NULL
			END TRY
			BEGIN CATCH
				DECLARE @DoRetry bit; 
				DECLARE @ErrorMessage varchar(500)
				SET @doRetry = 0;
				SET @ErrorMessage = ERROR_MESSAGE()
				IF ERROR_NUMBER() = 1205 
				BEGIN
					SET @doRetry = 1; 
				END
				IF @DoRetry = 1
				BEGIN
					SET @RetryCounter = @RetryCounter + 1
					IF (@RetryCounter > 3)
					BEGIN
						RAISERROR(@ErrorMessage, 18, 1) -- Raise Error Message if 
					END
					ELSE
					BEGIN
						WAITFOR DELAY '00:00:00.05' 
						GOTO RETRY	
					END
				END
				ELSE
				BEGIN
					RAISERROR(@ErrorMessage, 18, 1)
				END
			END CATCH	
		</cfquery>
		<cfquery name="DEL_PAPER_RELATION" datasource="#new_dsn3#"><!---proje malzeme plani baglantisi siliniyor  --->
			DELETE 
				FROM #dsn_alias#.PAPER_RELATION
			WHERE
				PAPER_ID = #attributes.order_id# AND
				PAPER_TABLE = 'ORDERS' AND
				PAPER_TYPE_ID = 1
		</cfquery>
		<cfscript>
			add_relation_rows(
				action_type:'del',
				action_dsn : '#new_dsn3#',
				to_table:'ORDERS',
				to_action_id : attributes.order_id
				);
		</cfscript>
		<cfquery name="DEL_ORDER_PRODUCTS" datasource="#new_dsn3#">
			DELETE FROM ORDER_ROW WHERE	ORDER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.order_id#">
		</cfquery>
		<cfquery name="DEL_ORDER" datasource="#new_dsn3#">
			DELETE FROM	ORDERS WHERE ORDER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.order_id#">
		</cfquery>
		<cfquery name="DEL_MONEY_CREDIT" datasource="#new_dsn3#">
			DELETE FROM ORDER_MONEY_CREDITS WHERE ORDER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.order_id#"> AND USE_CREDIT = 0 AND IS_TYPE = 0
		</cfquery>
		
		<!--- History Kayitlari Silinir --->
		<cfquery name="Del_History_Row" datasource="#new_dsn3#">
			DELETE FROM ORDER_ROW_HISTORY WHERE ORDER_HISTORY_ID IN (SELECT ORDER_HISTORY_ID FROM ORDERS_HISTORY WHERE ORDERS_HISTORY.ORDER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.order_id#">)
		</cfquery>
		<cfquery name="Del_History" datasource="#new_dsn3#">
			DELETE FROM ORDERS_HISTORY WHERE ORDER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.order_id#">
		</cfquery>
		<!--- Belge Silindiginde Bagli Uyari/Onaylar Da Silinir --->
		<cfquery name="Del_Relation_Warnings" datasource="#new_dsn3#">
			DELETE FROM #dsn_alias#.PAGE_WARNINGS WHERE ACTION_TABLE = 'ORDERS' AND ACTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.order_id#"> AND OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#">
		</cfquery>
		<cfif not isdefined("add_order_error") or add_order_error eq 0>
			<cfif isDefined("session.pda")>
				<cf_add_log  log_type="-1" action_id="#attributes.order_id#" action_name="#GET_ORD_DET_.ORDER_HEAD#-#GET_ORD_DET_.ORDER_NUMBER#" paper_no="#GET_ORD_DET_.ORDER_NUMBER#" process_stage="#GET_ORD_DET_.ORDER_STAGE#" data_source="#new_dsn3#">
			<cfelse>
				<cf_add_log  log_type="-1" action_id="#attributes.order_id#" action_name="#GET_ORD_DET_.ORDER_HEAD#-#GET_ORD_DET_.ORDER_NUMBER#" paper_no="#GET_ORD_DET_.ORDER_NUMBER#" process_stage="#GET_ORD_DET_.ORDER_STAGE#" data_source="#new_dsn3#">
			</cfif>		
		</cfif>
		<cfcatch type="database">
			<cftransaction action="rollback">
		</cfcatch>
	</cftry>
</cftransaction>
<cfif not isdefined("attributes.is_web_service")><!--- Web Servisden gelen Sipariş Silme işleminden sonra Yönlendirme Sayfasına gönderilmemesi için yazıldı. --->
	<script type="text/javascript">
		window.location.href="<cfoutput>#request.self#?fuseaction=#listgetat(attributes.fuseaction,1,'.')#</cfoutput>.list_order";
	</script>
</cfif>

