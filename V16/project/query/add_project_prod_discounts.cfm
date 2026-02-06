<cf_date tarih="attributes.start_date">
<cf_date tarih="attributes.finish_date">
<cflock name="#CREATEUUID()#" timeout="20">
	<cftransaction>
		<cfquery name="GET_PRO_DISCOUNTS" datasource="#DSN3#">
			SELECT PRO_DISCOUNT_ID FROM PROJECT_DISCOUNTS WHERE PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.project_id#">
		</cfquery>
		<cfif GET_PRO_DISCOUNTS.recordcount>
			<!--- Tarihce --->
			<cfquery name="ADD_HISTORY" datasource="#DSN3#">
				INSERT INTO
					PROJECT_DISCOUNTS_HISTORY
				SELECT
					*
				FROM
					PROJECT_DISCOUNTS
				WHERE
					PRO_DISCOUNT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_pro_discounts.pro_discount_id#">
			</cfquery>
			<cfquery name="add_prod_cat_condition_history" datasource="#DSN3#">
				INSERT INTO
					PROJECT_DISCOUNT_CONDITIONS_HISTORY
				SELECT
					*
				FROM
					PROJECT_DISCOUNT_CONDITIONS
				WHERE
					PRO_DISCOUNT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_pro_discounts.pro_discount_id#">
			</cfquery>
			<!--- Tarihce --->
			
			<cfquery name="DEL_DISCOUNT_CONDITIONS" datasource="#DSN3#">
				DELETE FROM PROJECT_DISCOUNT_CONDITIONS WHERE PRO_DISCOUNT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_pro_discounts.pro_discount_id#">
			</cfquery>
			<cfquery name="DEL_PRO_DISCOUNTS" datasource="#DSN3#">
				DELETE FROM PROJECT_DISCOUNTS WHERE PRO_DISCOUNT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_pro_discounts.pro_discount_id#">
			</cfquery>
		</cfif>
		<cfset is_prod_condition=0>
		<cfloop from="1" to="#attributes.record_num#" index="i">
			<cfif evaluate("attributes.row_kontrol#i#") neq 0>
				<cfset is_prod_condition=1>
				<cfbreak>
			</cfif>
		</cfloop>
		<cfif (isdefined('attributes.product_cat') and len(attributes.product_cat)) or (isdefined('attributes.product_brands') and len(attributes.product_brands)) or (isdefined('is_prod_condition') and is_prod_condition eq 1)>
			<cfquery name="add_price_list_for_company" datasource="#DSN3#">
				INSERT INTO
					PROJECT_DISCOUNTS
					(
						PROJECT_ID,
						COMPANY_ID,
						CONSUMER_ID,
						PRICE_CATID,
                        PAYMETHOD_ID,
                        CARD_PAYMETHOD_ID,
						START_DATE,
						FINISH_DATE,
						DISCOUNT_1,
						DISCOUNT_2,
						DISCOUNT_3,
						DISCOUNT_4,
						DISCOUNT_5,
						IS_CHECK_RISK,
						IS_CHECK_PRJ_LIMIT,
						IS_CHECK_PRJ_PRODUCT,
						IS_CHECK_PRJ_MEMBER,
						IS_CHECK_PRJ_PRICE_CAT,
						RECORD_EMP,
						RECORD_IP,
						RECORD_DATE
					)
				VALUES
					(
						#attributes.project_id#,
						<cfif isdefined('attributes.prj_company_id') and len(attributes.prj_company_id)>#attributes.prj_company_id#<cfelse>NULL</cfif>,
						<cfif isdefined('attributes.prj_consumer_id') and len(attributes.prj_consumer_id)>#attributes.prj_consumer_id#<cfelse>NULL</cfif>,
						<cfif isdefined('attributes.price_cat') and len(evaluate("attributes.price_cat"))>#evaluate("attributes.price_cat")#<cfelse>NULL</cfif>,
                        <cfif len(attributes.paymethod_name) and len(attributes.paymethod_id)>#attributes.paymethod_id#<cfelse>NULL</cfif>,
                        <cfif len(attributes.paymethod_name) and len(attributes.card_paymethod_id)>#attributes.card_paymethod_id#<cfelse>NULL</cfif>,
						<cfif isdefined('attributes.start_date') and len(attributes.start_date)>#attributes.start_date#<cfelse>NULL</cfif>,
						<cfif isdefined('attributes.finish_date') and len(attributes.finish_date)>#attributes.finish_date#<cfelse>NULL</cfif>,
						<cfif isdefined('attributes.discount1') and len(attributes.discount1)>#filterNum(attributes.discount1)#<cfelse>NULL</cfif>,
						<cfif isdefined('attributes.discount2') and len(attributes.discount2)>#filterNum(attributes.discount2)#<cfelse>NULL</cfif>,
						<cfif isdefined('attributes.discount3') and len(attributes.discount3)>#filterNum(attributes.discount3)#<cfelse>NULL</cfif>,
						<cfif isdefined('attributes.discount4') and len(attributes.discount4)>#filterNum(attributes.discount4)#<cfelse>NULL</cfif>,
						<cfif isdefined('attributes.discount5') and len(attributes.discount5)>#filterNum(attributes.discount5)#<cfelse>NULL</cfif>,
						<cfif isdefined('attributes.check_risk_limit')>#attributes.check_risk_limit#<cfelse>0</cfif>,
						<cfif isdefined('attributes.check_prj_risk_limit')>#attributes.check_prj_risk_limit#<cfelse>0</cfif>,
						<cfif isdefined('attributes.check_prj_proudcts')>#attributes.check_prj_proudcts#<cfelse>0</cfif>,
						<cfif isdefined('attributes.check_prj_member')>#attributes.check_prj_member#<cfelse>0</cfif>,
						<cfif isdefined('attributes.check_prj_price_cat_')>#attributes.check_prj_price_cat_#<cfelse>0</cfif>,
						#session.ep.userid#,
						'#remote_addr#',
						#now()#
					)
			</cfquery>
			<cfquery name="GET_MAX_PRO_DISCOUNT" datasource="#DSN3#">
				SELECT PRO_DISCOUNT_ID FROM PROJECT_DISCOUNTS WHERE PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.project_id#">
			</cfquery>
			<cfif isdefined('attributes.product_cat') and len(attributes.product_cat)> <!--- urun kategorileri --->
				<cfloop list="#attributes.product_cat#" index="prod_c">
					<cfquery name="add_prod_cat_condition" datasource="#DSN3#">
						INSERT INTO
							PROJECT_DISCOUNT_CONDITIONS
							(
								PRO_DISCOUNT_ID,
								PRODUCT_CATID
							)
						VALUES
							(
								#get_max_pro_discount.pro_discount_id#,
								#prod_c#
							)
					</cfquery>
				</cfloop>
			</cfif>
			<cfif isdefined('attributes.product_brands') and len(attributes.product_brands)> <!--- markalar--->
				<cfloop list="#attributes.product_brands#" index="prod_brnd">
					<cfquery name="add_prod_brand_condition" datasource="#DSN3#">
						INSERT INTO
							PROJECT_DISCOUNT_CONDITIONS
							(
								PRO_DISCOUNT_ID,
								BRAND_ID
							)
						VALUES
							(
								#get_max_pro_discount.pro_discount_id#,
								#prod_brnd#
							)
					</cfquery>
				</cfloop>
			</cfif>
			<cfloop from="1" to="#attributes.record_num#" index="i"> <!--- urunler --->
				<cfif evaluate("attributes.row_kontrol#i#") neq 0>
					<cfquery name="add_product_condition" datasource="#DSN3#">
						INSERT INTO
							PROJECT_DISCOUNT_CONDITIONS
							(
								PRO_DISCOUNT_ID,
								PRODUCT_ID
							)
						VALUES
							(
								#get_max_pro_discount.pro_discount_id#,
								<cfif isdefined('attributes.product_id#i#') and len(evaluate('attributes.product_id#i#'))>#evaluate('attributes.product_id#i#')#<cfelse>NULL</cfif>
							)
					</cfquery>
				</cfif>
			</cfloop>
		</cfif>
	</cftransaction>
</cflock>
<script type="text/javascript">
	location.href = document.referrer;
</script>
