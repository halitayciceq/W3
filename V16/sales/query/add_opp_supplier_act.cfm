<cfsetting showdebugoutput="no">
<cftransaction>
	<cfif listlen(attributes.opp_id) gt 1><cfset attributes.opp_id = listfirst(attributes.opp_id)></cfif>
	<cfquery name="del_opp_supplier" datasource="#dsn3#">
		DELETE FROM OPPORTUNITY_SUPPLIERS WHERE OPP_ID = #attributes.opp_id#
	</cfquery>
	<cfloop from="1" to="#attributes.record_num#" index="i">
		<cfif evaluate("attributes.row_kontrol#i#")>
			<cfset form_company_id = evaluate("attributes.company_id#i#")>
			<cfset form_stock_id = evaluate("attributes.stock_id#i#")>
			<cfset form_product_id = evaluate("attributes.product_id#i#")>
			<cfset form_product = evaluate("attributes.product#i#")>
			<cfset form_brand_id = evaluate("attributes.brand_id#i#")>
			<cfset form_brand_name = evaluate("attributes.brand_name#i#")>
			<cfset form_product_catid = evaluate("attributes.category#i#")>
			<cfset form_product_cat = evaluate("attributes.category_name#i#")>
			<cfset form_estimated_income = evaluate("attributes.estimated_income#i#")>
			<cfset form_estimated_cost = evaluate("attributes.estimated_cost#i#")>
			<cfset form_estimated_profit = evaluate("attributes.estimated_profit#i#")>
			<cfset form_money = evaluate("attributes.money#i#")>
			<cfquery name="add_opp_supplier" datasource="#dsn3#">
				INSERT INTO
					OPPORTUNITY_SUPPLIERS
					(
						OPP_ID,
						COMPANY_ID,
						BRAND_ID,
						PRODUCT_CATID,
						PRODUCT_ID,
						STOCK_ID,
						PRODUCT_NAME,
						ESTIMATED_INCOME,
						ESTIMATED_COST,
						ESTIMATED_PROFIT,
						MONEY_TYPE				
					)
					VALUES
					(
						#attributes.opp_id#,
						#form_company_id#,
						<cfif len(form_brand_id) and len(form_brand_name)>#form_brand_id#<cfelse>NULL</cfif>,
						<cfif len(form_product_catid) and len(form_product_cat)>#form_product_catid#<cfelse>NULL</cfif>,
						<cfif len(form_product_id) and len(form_product)>#form_product_id#<cfelse>NULL</cfif>,
						<cfif len(form_stock_id) and len(form_product)>#form_stock_id#<cfelse>NULL</cfif>,
						<cfif len(form_product)>'#form_product#'<cfelse>NULL</cfif>,
						<cfif len(form_estimated_income)>#form_estimated_income#<cfelse>0</cfif>,
						<cfif len(form_estimated_cost)>#form_estimated_cost#<cfelse>0</cfif>,
						<cfif len(form_estimated_profit)>#form_estimated_profit#<cfelse>0</cfif>,
						'#form_money#'
					)
			</cfquery>
		</cfif>
	</cfloop>
</cftransaction>
<cfabort>
