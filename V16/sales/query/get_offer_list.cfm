<cfif isdefined("x_control_ims") and x_control_ims eq 1 and session.ep.our_company_info.sales_zone_followup eq 1>
	<cfinclude template="/member/query/get_ims_control.cfm">
</cfif>

<cfparam name="attributes.keyword" default="">
<cfif isdefined('attributes.start_date') and len(attributes.start_date)><CF_DATE TARIH="attributes.start_date"></cfif>
<cfif isdefined('attributes.finish_date') and len(attributes.finish_date)><CF_DATE TARIH="attributes.finish_date"></cfif>
<cfquery name="GET_OFFER_LIST" datasource="#DSN3#">
	SELECT 
		<cfif (isdefined("attributes.product_name") and len(attributes.product_name) and len(attributes.product_id)) or (isDefined("attributes.listing_type") and attributes.listing_type eq 2)>
		DISTINCT
			OFR.UNIT,
			OFR.PRICE,
			OFR.PRODUCT_ID,
			OFR.PRODUCT_NAME,
			OFR.OTHER_MONEY,
			OFR.QUANTITY,
			OFR.OTHER_MONEY,
			OFR.WRK_ROW_ID,
			OFR.STOCK_ID,
			OFR.PRODUCT_ID,
			OFR.DISCOUNT_1,
			OFR.DISCOUNT_2,
			OFR.DISCOUNT_3,
			OFR.DISCOUNT_4,
			OFR.DISCOUNT_5,
			OFR.DISCOUNT_6,
			OFR.DISCOUNT_7,
			OFR.DISCOUNT_8,
			OFR.DISCOUNT_9,
			OFR.DISCOUNT_10,
			OFR.EXTRA_PRICE_TOTAL,
			ISNULL(OFR.DISCOUNT_COST,0) ROW_DISC_COST,
			OFR.OTHER_MONEY_VALUE,
			ISNULL((SELECT TOP 1 RATE2 FROM OFFER_MONEY WHERE ACTION_ID = OFR.OFFER_ID AND MONEY_TYPE = OFR.OTHER_MONEY),1) RATE2,
		</cfif>	
		OFFER.OFFER_ID,
		OFFER.CONSUMER_ID,
		OFFER.PARTNER_ID,
		OFFER.COMPANY_ID,		
		OFFER.OFFER_TO,
		OFFER.OFFER_TO_PARTNER,
		OFFER.SALES_EMP_ID,
		OFFER.SALES_PARTNER_ID,
		OFFER.OFFER_NUMBER,
		OFFER.RECORD_DATE,
		OFFER.OFFER_HEAD,
		OFFER.PRICE,
		OFFER.OTHER_MONEY,
		OFFER.OTHER_MONEY_VALUE,
		OFFER.OFFER_STATUS,
		OFFER.COMMETHOD_ID,
		OFFER.RECORD_MEMBER,
		OFFER.OFFER_CURRENCY,
		OFFER.OFFER_ZONE,
		OFFER.OFFER_DATE,
		OFFER.OFFER_STAGE,
        OFFER.PROJECT_ID,
		OFFER.OFFER_REVIZE_NO,
		OFFER.OPP_ID
	FROM 
		OFFER
	  <cfif (isdefined("attributes.product_name") and len(attributes.product_name) and len(attributes.product_id)) or (isDefined("attributes.listing_type") and attributes.listing_type eq 2)>
		,OFFER_ROW OFR
	  </cfif>		
	WHERE 
		<cfif isdefined("form.offer_zone")>
			<cfif not len(form.offer_zone)>
				( (OFFER.PURCHASE_SALES = 1 AND OFFER.OFFER_ZONE = 0)	OR (OFFER.PURCHASE_SALES = 0 AND OFFER.OFFER_ZONE = 1) )
			<cfelseif not form.offer_zone>
				(OFFER.PURCHASE_SALES = 1 AND OFFER.OFFER_ZONE = 0)
			<cfelseif form.offer_zone>
				(OFFER.PURCHASE_SALES = 0 AND OFFER.OFFER_ZONE = 1)
			</cfif>
		<cfelseif isdefined("attributes.purchase_") AND len(attributes.purchase_)>
			(  (OFFER.PURCHASE_SALES = 0 AND OFFER.OFFER_ZONE = 0) )
			<cfelse>
			( (OFFER.PURCHASE_SALES = 1 AND OFFER.OFFER_ZONE = 0) OR (OFFER.PURCHASE_SALES = 0 AND OFFER.OFFER_ZONE = 1) )
		</cfif>
		<cfif (isdefined("attributes.product_name") and len(attributes.product_name) and len(attributes.product_id)) or (isDefined("attributes.listing_type") and attributes.listing_type eq 2)>
			AND OFR.OFFER_ID = OFFER.OFFER_ID
			<cfif isdefined("attributes.product_name") and len(attributes.product_name) and len(attributes.product_id)>
				AND OFR.PRODUCT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.product_id#">
			</cfif>
		</cfif>
		  <cfif len(attributes.keyword)> 
			AND (OFFER.OFFER_HEAD LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.keyword#%"> OR 
				OFFER.OFFER_NUMBER LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.keyword#%">
				<cfif isdefined('xml_offer_revision') and xml_offer_revision eq 1>
					OR OFFER.OFFER_REVIZE_NO LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.keyword#%">
				</cfif>
				)
		  </cfif>
		
		<!--- Iliskili Teklif Ekleme Popupina ait filtreler --->  
		<cfif isdefined("attributes.offer_status_cat_id") and len(attributes.offer_status_cat_id)>
			AND OFFER.OFFER_CURRENCY = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.offer_status_cat_id#">
		</cfif>
		<cfif isDefined("attributes.filter_cat") and Len(attributes.filter_cat)>
			<cfif ListFind("1,3",attributes.filter_cat)>
				<cfif attributes.filter_cat eq 1>
					AND OFFER.CONSUMER_ID IS NOT NULL
				<cfelse>
					AND OFFER.CONSUMER_ID IN (SELECT CONSUMER_ID FROM #dsn_alias#.CONSUMER WHERE ISPOTANTIAL = 1)
				</cfif>
			<cfelse>
				<cfif attributes.filter_cat eq 2>
					AND OFFER.COMPANY_ID IS NOT NULL
				<cfelse>
					AND OFFER.COMPANY_ID IN (SELECT COMPANY_ID FROM #dsn_alias#.COMPANY WHERE ISPOTANTIAL = 1)
				</cfif>
			</cfif>
		</cfif>
		<!--- //Iliskili Teklif Ekleme Popupina ait filtreler --->  
		
		<cfif isdefined("attributes.status") and len(attributes.status)>
			AND OFFER_STATUS = <cfqueryparam cfsqltype="cf_sql_smallint" value="#attributes.status#">
		</cfif>
		<cfif isdefined("attributes.member_type") and len(attributes.member_type) and (attributes.member_type is 'partner') and len(attributes.member_name) and len(attributes.company_id)>
			AND OFFER.COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.company_id#">
		</cfif>
		<cfif isdefined("attributes.member_type") and len(attributes.member_type) and (attributes.member_type is 'consumer') and len(attributes.member_name) and len(attributes.consumer_id)>
			AND OFFER.CONSUMER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.consumer_id#">
		</cfif>
		 <cfif isdefined("attributes.sales_emp_id") and len(attributes.sales_emp_id) and len(attributes.sales_emp)>
			AND OFFER.SALES_EMP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.sales_emp_id#">
		</cfif>
		<cfif isdefined("attributes.sales_partner_id") and len(attributes.sales_partner_id) and len(attributes.sales_partner)>
			AND OFFER.SALES_PARTNER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.sales_partner_id#">
		</cfif>
		<cfif isdefined('attributes.start_date') and len(attributes.start_date)>
			AND OFFER.OFFER_DATE >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.start_date#">
		</cfif>
		<cfif isdefined('attributes.finish_date') and len(attributes.finish_date)>
			AND OFFER.OFFER_DATE <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.finish_date#">
		</cfif>
		<cfif isdefined('attributes.sale_add_option') and len(attributes.sale_add_option)> 
			AND SALES_ADD_OPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.sale_add_option#">
		</cfif>
		<cfif isdefined('attributes.offer_stage') and len(attributes.offer_stage)> 
			AND OFFER.OFFER_STAGE = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.offer_stage#">
		</cfif>
		<cfif isdefined("attributes.project_id") and len (attributes.project_id) and isdefined("attributes.project_head") and len (attributes.project_head)>
			AND OFFER.PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.project_id#">
		</cfif>
		<cfif isdefined("x_control_ims") and x_control_ims eq 1 and session.ep.our_company_info.sales_zone_followup eq 1>
			AND
				(
				(OFFER.CONSUMER_ID IS NULL AND OFFER.COMPANY_ID IS NULL ) 
				OR ( OFFER.COMPANY_ID IN (#PreserveSingleQuotes(my_ims_comp_list)#) )
				OR ( OFFER.CONSUMER_ID IN (#PreserveSingleQuotes(my_ims_cons_list)#) )
				)
		</cfif>
	ORDER BY 
		OFFER.OFFER_ID DESC
</cfquery>

