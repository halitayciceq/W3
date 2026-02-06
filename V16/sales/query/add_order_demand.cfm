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
	<cfset hata  = 11>
	<cfsavecontent variable="message"><cf_get_lang_main no='585.Şube Yetkiniz Uygun Değil'> <cf_get_lang_main no='586.Veya'> <cf_get_lang_main no='589.Böyle Bir Üye Bulunamadı'> !</cfsavecontent>
	<cfset hata_mesaj  = message>
	<cfinclude template="../../dsp_hata.cfm">
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
		<cfquery name="ADD_DEMAND" datasource="#DSN3#">
			INSERT INTO
				ORDER_DEMANDS
                (
                    DEMAND_STATUS,
                    STOCK_ID,
                    DEMAND_TYPE,
                    PRICE,<!--- kdv siz --->
                    PRICE_KDV,<!--- kdv li --->
                    PRICE_MONEY,
                    DEMAND_AMOUNT,
                    GIVEN_AMOUNT,
                    DEMAND_UNIT_ID,
                    <!---DOMAIN_NAME,--->
                    MENU_ID,
                    STOCK_ACTION_TYPE,
                    DEMAND_NOTE,
                    RECORD_CON,
                    RECORD_PAR,
                    RECORD_EMP,
                    RECORD_DATE,
                    RECORD_IP,
                    DEMAND_DATE				
                )
                VALUES
                (
                    1,
                    #attributes.stock_id#,
                    #attributes.demand_type#,
                    <cfif attributes.kdvlimi eq 1>
                        <cfif len (get_stock_id.tax) and get_stock_id.tax eq 0>
                            #attributes.price_kdv#,
                        <cfelse>
                            #wrk_round(attributes.price_kdv-((attributes.price_kdv)/(1+(100/get_stock_id.tax))),4)#,
                        </cfif>
                    	#attributes.price_kdv#,
                    <cfelse>
                        #attributes.price_kdv#,
                        #wrk_round((attributes.price_kdv + (attributes.price_kdv*get_stock_id.tax)/100),4)#,
                    </cfif>
                    '#attributes.money_type#',
                    #attributes.demand_amount#,
                    0,
                    #get_stock_id.product_unit_id#,
                    <!---<cfqueryparam cfsqltype="cf_sql_varchar" value="'#cgi.http_host#'">,--->
                    #session.ep.menu_id#,
                    <cfif get_stock_action_type.recordcount and len(get_stock_action_type.stock_action_type)>#get_stock_action_type.stock_action_type#<cfelse>NULL</cfif>,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.demand_note#">,
                    <cfif len(attributes.sales_member_id) and len(attributes.sales_member_name) and attributes.sales_member_type is 'consumer'>#attributes.sales_member_id#,<cfelse>NULL,</cfif>
                    <cfif len(attributes.sales_member_id) and len(attributes.sales_member_name) and attributes.sales_member_type is 'partner'>#attributes.sales_member_id#,<cfelse>NULL,</cfif>
                    #session.ep.userid#,
                    #now()#,
                     <cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.remote_addr#">,
                   <cfif isdefined("attributes.demand_date") and len(attributes.demand_date)>#attributes.demand_date#<cfelse>NULL</cfif>
                )
		</cfquery>
	</cftransaction>
</cflock>
<script type="text/javascript">
	wrk_opener_reload();
	window.close();
</script>
