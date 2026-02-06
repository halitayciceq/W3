<cfquery name="GET_STOCK_ID" datasource="#DSN3#">
    SELECT
        PRODUCT_UNIT_ID,
        TAX
    FROM
        STOCKS
    WHERE
        STOCK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.stock_id#">
</cfquery>

<cfif get_stock_id.recordcount and not len(get_stock_id.product_unit_id)>
    <script language="javascript">
        alert('Seçtiğiniz ürünün birim tanımı yapılmamıştır !');
        history.back();
    </script>
    <cfabort>
</cfif>

<cflock name="#CREATEUUID()#" timeout="20">
	<cftransaction>
		<cfquery name="GET_STOCK_ACTION_TYPE" datasource="#DSN3#">
			SELECT
				STOCK_ACTION_TYPE
			FROM
				STOCK_STRATEGY,
				SETUP_SALEABLE_STOCK_ACTION
			WHERE				
				STOCK_STRATEGY.STOCK_ACTION_ID = SETUP_SALEABLE_STOCK_ACTION.STOCK_ACTION_ID AND
				STOCK_STRATEGY.STOCK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.stock_id#">
		</cfquery>
        <cfif isdefined("attributes.demand_date") and len(attributes.demand_date)>
        	<cf_date tarih="attributes.demand_date">
        </cfif>
		<cf_wrk_get_history datasource="#dsn3#" source_table="ORDER_DEMANDS" target_table="ORDER_DEMANDS_HISTORY" record_id="#attributes.demand_id#" record_name="DEMAND_ID">
	 	<!---<cfoutput>#attributes.price_kdv#--#get_stock_id.tax#</cfoutput><cfabort>--->
        	<cfif get_stock_id.tax eq 0>
        	<cfset temp_tax=1>
        <cfelse>
        	 <cfset temp_tax=get_stock_id.tax>
        </cfif>
        <cfquery name="UPD_DEMAND" datasource="#DSN3#">
			UPDATE 
				ORDER_DEMANDS
			SET
				DEMAND_STATUS = <cfif isdefined("attributes.demand_status")>1<cfelse>0</cfif>,
				STOCK_ID = #attributes.stock_id#,
				DEMAND_TYPE = #attributes.demand_type#,
                <cfif attributes.kdvlimi eq 1>
					PRICE =#attributes.price_kdv# - #wrk_round((attributes.price_kdv)/(1+(100/temp_tax)),4)#,
					PRICE_KDV = #attributes.price_kdv#,
                <cfelse>
					PRICE =<cfif len(#attributes.price_kdv#)>#attributes.price_kdv#<cfelse>0</cfif>,
                  	<cfif len (get_stock_id.tax) and get_stock_id.tax eq 0>
                    	PRICE_KDV=#attributes.price_kdv#,
                    <cfelse>
                    	PRICE_KDV= #wrk_round((attributes.price_kdv + (attributes.price_kdv*temp_tax)/100),4)#,
                    </cfif>
                </cfif>
				PRICE_MONEY = '#attributes.money_type#',
				DEMAND_AMOUNT = #attributes.demand_amount#,
				DEMAND_UNIT_ID = #get_stock_id.product_unit_id#,
                DEMAND_DATE= <cfif isdefined("attributes.demand_date") and len(attributes.demand_date)>#attributes.demand_date#<cfelse>NULL</cfif>,
				<!--- DOMAIN_NAME =<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.http_host#"> , --->
				MENU_ID = #session.ep.menu_id#,
				STOCK_ACTION_TYPE = <cfif get_stock_action_type.recordcount and len(get_stock_action_type.stock_action_type)>#get_stock_action_type.stock_action_type#<cfelse>NULL</cfif>,
				DEMAND_NOTE = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.demand_note#">,
				RECORD_CON = <cfif len(attributes.sales_member_id) and len(attributes.sales_member_name) and attributes.sales_member_type is 'consumer'>#attributes.sales_member_id#,<cfelse>NULL,</cfif>
				RECORD_PAR = <cfif len(attributes.sales_member_id) and len(attributes.sales_member_name) and attributes.sales_member_type is 'partner'>#attributes.sales_member_id#,<cfelse>NULL,</cfif>
				UPDATE_EMP = #session.ep.userid#,
				UPDATE_DATE = #now()#,
				UPDATE_IP =<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.remote_addr#">
			WHERE
				DEMAND_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.demand_id#">		
		</cfquery>
	</cftransaction>
</cflock>

<script type="text/javascript">
	wrk_opener_reload();
	window.close();
</script>

