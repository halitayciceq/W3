<cfif isdefined("x_control_ims") and x_control_ims eq 1 and session.ep.our_company_info.sales_zone_followup eq 1>
	<cfinclude template="/member/query/get_ims_control.cfm">
</cfif>
<cfif isdefined("attributes.start_date") and len(attributes.start_date)><cf_date tarih="attributes.start_date"></cfif>
<cfif isdefined("attributes.finish_date") and len(attributes.finish_date)><cf_date tarih="attributes.finish_date"></cfif>
<cfif not isDefined("GET_SUBSCRIPTION_AUTHORITY")>
	<!--- 20190927 abone kategorsine göre yetkilendirme için include edildiği sayfada çekilmiş olabilir bu nedenle kontrol ekledik Author: Tolga Sütlü, Ahmet Yolcu--->
	<cfset gsa = createObject("component","V16.objects.cfc.subscriptionNauthority")/>
	<cfset GET_SUBSCRIPTION_AUTHORITY= gsa.SelectAuthority()/>
</cfif>
<cfquery name="GET_SUBSCRIPTIONS" datasource="#DSN3#">
	WITH CTE1 AS(
    SELECT
		SC.SUBSCRIPTION_ID,
		SC.SUBSCRIPTION_NO,
		SC.SPECIAL_CODE,
		SC.SUBSCRIPTION_HEAD,
		SC.PARTNER_ID,
		SC.CONSUMER_ID,
		SC.COMPANY_ID,
		SC.SALES_EMP_ID,
		SC.SUBSCRIPTION_STAGE,
		SC.MONTAGE_DATE,
        SC.PROJECT_ID,
		SC.START_DATE,
		SC.FINISH_DATE,
		SC.RECORD_EMP,
		SC.RECORD_CONS,
		SC.SUBSCRIPTION_ADD_OPTION_ID,
		SC.SALES_ADD_OPTION_ID,
		SST.SUBSCRIPTION_TYPE
	FROM
		SUBSCRIPTION_CONTRACT SC WITH (NOLOCK),
		SETUP_SUBSCRIPTION_TYPE AS SST WITH (NOLOCK)
	WHERE
		SUBSCRIPTION_ID IS NOT NULL AND 
		SST.SUBSCRIPTION_TYPE_ID = SC.SUBSCRIPTION_TYPE_ID 
	<cfif isdefined('attributes.process_stage_type') and len(attributes.process_stage_type)> 
		AND SC.SUBSCRIPTION_STAGE = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.process_stage_type#">
	</cfif>
	<cfif len(attributes.use_efatura)>
    	AND (SC.INVOICE_COMPANY_ID IN (SELECT COMPANY_ID FROM #dsn_alias#.COMPANY WHERE USE_EFATURA = #attributes.use_efatura#)
        OR SC.INVOICE_CONSUMER_ID IN (SELECT CONSUMER_ID FROM #dsn_alias#.CONSUMER WHERE USE_EFATURA = #attributes.use_efatura#)) 
	</cfif>
	<cfif isdefined('attributes.subs_add_option') and len(attributes.subs_add_option)> 
		AND SC.SUBSCRIPTION_ADD_OPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.subs_add_option#">
	</cfif>
	<cfif isdefined('attributes.sale_add_option') and len(attributes.sale_add_option)> 
		AND SC.SALES_ADD_OPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.sale_add_option#">
	</cfif>
	<cfif isdefined("attributes.keyword") and len(attributes.keyword)>
		AND (
				SC.SUBSCRIPTION_NO LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.keyword#%"> OR
				SC.SUBSCRIPTION_HEAD LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.keyword#%"> COLLATE SQL_Latin1_General_CP1_CI_AI OR
				SC.SPECIAL_CODE LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.keyword#%"> COLLATE SQL_Latin1_General_CP1_CI_AI OR
                SC.CONTRACT_NO = <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.keyword#%"> COLLATE SQL_Latin1_General_CP1_CI_AI OR
				SC.SUBSCRIPTION_ID IN (SELECT SUBSCRIPTION_ID FROM SUBSCRIPTION_CONTRACT_PARTITION WHERE PARTITION_NUMBER = <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.keyword#%"> COLLATE SQL_Latin1_General_CP1_CI_AI)
			)
	</cfif>
	<cfif isdefined("attributes.keyword_no") and len(attributes.keyword_no)>
		AND (
				SC.SUBSCRIPTION_NO = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.keyword_no#"> OR
				SC.SUBSCRIPTION_ID IN (SELECT SUBSCRIPTION_ID FROM SUBSCRIPTION_CONTRACT_PARTITION WHERE PARTITION_NUMBER = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.keyword_no#">)
			)
	</cfif>
	<cfif isdefined('attributes.start_date') and len(attributes.start_date)>
		AND SC.START_DATE >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.start_date#">
	</cfif>
	<cfif isdefined('attributes.finish_date') and len(attributes.finish_date)>
		AND SC.START_DATE <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.finish_date#">
	</cfif>
	<cfif isdefined("attributes.status") and len(attributes.status)>
		AND SC.IS_ACTIVE = <cfqueryparam cfsqltype="cf_sql_smallint" value="#attributes.status#">
	</cfif>
	<cfif isDefined("attributes.employee_id") and len(attributes.employee_id) and isDefined("attributes.employee_name") and len(attributes.employee_name)>
		AND SC.RECORD_EMP = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.employee_id#">
	</cfif>
	<cfif isdefined("attributes.member_type") and (attributes.member_type is 'partner') and len(attributes.member_name) and len(attributes.company_id)>
		AND SC.COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.company_id#">
	</cfif>
	<cfif isdefined("attributes.member_type") and (attributes.member_type is 'consumer') and len(attributes.member_name) and len(attributes.consumer_id)>
		AND SC.CONSUMER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.consumer_id#">
	</cfif>
	<cfif isdefined("attributes.member_cat_type") and listlen(attributes.member_cat_type,'-') eq 2 and listfirst(attributes.member_cat_type,'-') eq '1'>
		AND SC.COMPANY_ID IN (SELECT COMPANY_ID FROM #dsn_alias#.COMPANY WHERE COMPANYCAT_ID = #listlast(attributes.member_cat_type,'-')#)
	<cfelseif isdefined("attributes.member_cat_type") and attributes.member_cat_type eq 1>
		AND SC.COMPANY_ID IN (SELECT C.COMPANY_ID FROM #dsn_alias#.COMPANY C,#dsn_alias#.COMPANY_CAT CAT WHERE C.COMPANYCAT_ID = CAT.COMPANYCAT_ID)
	</cfif>
	<cfif isdefined("attributes.member_cat_type") and listlen(attributes.member_cat_type,'-') eq 2 and listfirst(attributes.member_cat_type,'-') eq '2'>
		AND SC.CONSUMER_ID IN (SELECT CONSUMER_ID FROM #dsn_alias#.CONSUMER WHERE CONSUMER_CAT_ID = #listlast(attributes.member_cat_type,'-')#)
	<cfelseif isdefined("attributes.member_cat_type") and attributes.member_cat_type eq 2>
		AND SC.CONSUMER_ID IN (SELECT C.CONSUMER_ID FROM #dsn_alias#.CONSUMER C,#dsn_alias#.CONSUMER_CAT CAT WHERE C.CONSUMER_CAT_ID = CAT.CONSCAT_ID)
	</cfif>
	<cfif isdefined('attributes.subscription_type') and len(attributes.subscription_type)> 
		AND SC.SUBSCRIPTION_TYPE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.subscription_type#">
	</cfif>
    <cfif isdefined("attributes.project_head") and len(attributes.project_head) and isdefined('attributes.project_id') and len(attributes.project_id)> 
		AND SC.PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.project_id#">
	</cfif>
	<cfif isdefined("attributes.sales_emp") and len(attributes.sales_emp) and isdefined("attributes.sales_emp_id") and len(attributes.sales_emp_id)>
		AND SALES_EMP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.sales_emp_id#">
	</cfif>
	<cfif isdefined("attributes.sales_partner") and len(attributes.sales_partner) and isdefined("attributes.sales_partner_id") and len(attributes.sales_partner_id)>
		AND SALES_PARTNER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.sales_partner_id#">
	</cfif>
	<cfif len(attributes.product_id) and len(attributes.product_name)>
		AND SUBSCRIPTION_ID IN (SELECT SUBSCRIPTION_ID FROM SUBSCRIPTION_CONTRACT_ROW WHERE PRODUCT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.product_id#">)
	</cfif>	
	<cfif isdefined("attributes.adress_keyword") and len(attributes.adress_keyword)>
		AND (
				SC.SHIP_ADDRESS LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.adress_keyword#%"> COLLATE SQL_Latin1_General_CP1_CI_AI OR
				SC.INVOICE_ADDRESS LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.adress_keyword#%"> COLLATE SQL_Latin1_General_CP1_CI_AI OR
				SC.CONTACT_ADDRESS LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.adress_keyword#%"> COLLATE SQL_Latin1_General_CP1_CI_AI
			)
	</cfif>
	<cfif isdefined("attributes.city_id") and len(attributes.city_id)>
		AND (
				SC.SHIP_CITY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.city_id#"> OR
				SC.INVOICE_CITY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.city_id#"> OR
				SC.CONTACT_CITY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.city_id#">
			)
	</cfif>
	<cfif isdefined("attributes.county_id") and len(attributes.county_id)>
		AND (
				SC.SHIP_COUNTY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.county_id#"> OR
				SC.INVOICE_COUNTY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.county_id#"> OR
				SC.CONTACT_COUNTY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.county_id#">
			)
	</cfif>
	<cfif isdefined("attributes.semt_keyword") and len(attributes.semt_keyword)>
		AND (
				SC.SHIP_SEMT LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.semt_keyword#%"> COLLATE SQL_Latin1_General_CP1_CI_AI OR
				SC.INVOICE_SEMT LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.semt_keyword#%"> COLLATE SQL_Latin1_General_CP1_CI_AI OR
				SC.CONTACT_SEMT LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.semt_keyword#%"> COLLATE SQL_Latin1_General_CP1_CI_AI
			)
	</cfif>
	<cfif isdefined("x_control_ims") and x_control_ims eq 1 and session.ep.our_company_info.sales_zone_followup eq 1>
		AND
			(
			(SC.CONSUMER_ID IS NULL AND SC.COMPANY_ID IS NULL ) 
			OR ( SC.COMPANY_ID IN (#PreserveSingleQuotes(my_ims_comp_list)#) )
			OR ( SC.CONSUMER_ID IN (#PreserveSingleQuotes(my_ims_cons_list)#) )
			)
	</cfif>
	<cfif get_subscription_authority.IS_SUBSCRIPTION_AUTHORITY eq 1>
		AND EXISTS 
			(
				SELECT
				SPC.SUBSCRIPTION_TYPE_ID
				FROM        
				#dsn#.EMPLOYEE_POSITIONS AS EP,
				SUBSCRIPTION_GROUP_PERM SPC
				WHERE
				EP.POSITION_CODE = #session.ep.position_code# AND
				(
					SPC.POSITION_CODE = EP.POSITION_CODE OR
					SPC.POSITION_CAT = EP.POSITION_CAT_ID
				)
					AND SC.SUBSCRIPTION_TYPE_ID = spc.SUBSCRIPTION_TYPE_ID
			)
	</cfif>
	),
         CTE2 AS (
				SELECT
					CTE1.*,
						ROW_NUMBER() OVER (ORDER BY
									<cfif Len(attributes.sort_type) and attributes.sort_type eq 1>
                                        SUBSCRIPTION_NO
                                    <cfelseif  Len(attributes.sort_type) and attributes.sort_type eq 2>
                                        SUBSCRIPTION_TYPE DESC
                                    <cfelseif  Len(attributes.sort_type) and attributes.sort_type eq 3>
                                        SUBSCRIPTION_TYPE 
                                    <cfelseif  Len(attributes.sort_type) and attributes.sort_type eq 4>
                                        START_DATE DESC
                                    <cfelseif  Len(attributes.sort_type) and attributes.sort_type eq 5>
                                        START_DATE 
                                    <cfelseif  Len(attributes.sort_type) and attributes.sort_type eq 6>
                                        SPECIAL_CODE DESC
                                    <cfelseif  Len(attributes.sort_type) and attributes.sort_type eq 7>
                                        SPECIAL_CODE
                                    <cfelse>
                                        SUBSCRIPTION_NO DESC
                                    </cfif>
					) AS RowNum,(SELECT COUNT(*) FROM CTE1) AS QUERY_COUNT
				FROM
					CTE1
			)
			SELECT
				CTE2.*
			FROM
				CTE2
			WHERE
				RowNum BETWEEN #attributes.startrow# and #attributes.startrow#+(#attributes.maxrows#-1)
</cfquery>