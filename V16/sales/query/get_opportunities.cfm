<cfif x_control_ims eq 1 and session.ep.our_company_info.sales_zone_followup eq 1>
	<cfinclude template="../../member/query/get_ims_control.cfm">
</cfif>
<cfif isdefined("attributes.start_date") and len(attributes.start_date)><cf_date tarih="attributes.start_date"></cfif>
<cfif isdefined("attributes.finish_date") and len(attributes.finish_date)><cf_date tarih="attributes.finish_date"></cfif>
<cfquery name="GET_OPPORTUNITIES" datasource="#DSN3#">
	SELECT
		<cfif attributes.ordertype eq 4>
			(SELECT TOP 1 OPPORTUNITIES_PLUS.RECORD_DATE FROM OPPORTUNITIES_PLUS WITH (NOLOCK) WHERE OPPORTUNITIES_PLUS.OPP_ID = OPPORTUNITIES.OPP_ID ORDER BY OPPORTUNITIES_PLUS.RECORD_DATE DESC) PLUS_DATE,
		</cfif>
		OPPORTUNITIES.OPP_NO,
		OPPORTUNITIES.PROJECT_ID,
		OPPORTUNITIES.OPP_CURRENCY_ID,
		OPPORTUNITIES.CONSUMER_ID,
		OPPORTUNITIES.PARTNER_ID,
		OPPORTUNITIES.OPP_HEAD,
		OPPORTUNITIES.OPP_DATE,
		OPPORTUNITIES.PROBABILITY,
		OPPORTUNITIES.INCOME,
		OPPORTUNITIES.MONEY,
		OPPORTUNITIES.SALES_EMP_ID,
		OPPORTUNITIES.SALES_PARTNER_ID,
		OPPORTUNITIES.SALES_CONSUMER_ID,
		OPPORTUNITIES.RECORD_DATE,
		OPPORTUNITIES.OPP_ID,
		OPPORTUNITIES.STOCK_ID,
		OPPORTUNITIES.PRODUCT_CAT_ID,
		OPPORTUNITIES.COMPANY_ID,
		OPPORTUNITIES.OPPORTUNITY_TYPE_ID,
		OPPORTUNITIES.ACTIVITY_TIME,
		OPPORTUNITIES.COST,
		OPPORTUNITIES.MONEY2,
		OPPORTUNITIES.SALE_ADD_OPTION_ID,
		OPPORTUNITIES.UPDATE_DATE,
        OPPORTUNITIES.OPP_STAGE,
		<cfif (database_type is 'MSSQL')>
            CP.COMPANY_PARTNER_NAME + ' ' + CP.COMPANY_PARTNER_SURNAME PARTNER_NAME_SURNAME,
        <cfelseif (database_type is 'DB2')>
            CP.COMPANY_PARTNER_NAME || ' ' || CP.COMPANY_PARTNER_SURNAME PARTNER_NAME_SURNAME,
        </cfif>        
        CP.TITLE,
        C.FULLNAME,
        CON.CONSUMER_NAME + ' ' + CON.CONSUMER_SURNAME CONSUMER_NAME,
        E.EMPLOYEE_NAME + ' ' + E.EMPLOYEE_SURNAME EMPLOYEES_NAME,
        PP.PROJECT_HEAD,
        SOT.OPPORTUNITY_TYPE,
        SOT.OPPORTUNITY_TYPE_ID,
        SSAO.SALES_ADD_OPTION_NAME,
        C2.NICKNAME NICKNAME,
        CON2.CONSUMER_NAME + ' ' + CON2.CONSUMER_SURNAME SATIS_ORTAGI,
        SPR.PROBABILITY_NAME,
        PTR.STAGE,
        OC.OPP_CURRENCY
	FROM
        OPPORTUNITIES WITH (NOLOCK) 
        LEFT JOIN #dsn_alias#.PRO_PROJECTS PP ON PP.PROJECT_ID = OPPORTUNITIES.PROJECT_ID
        LEFT JOIN #dsn_alias#.EMPLOYEES E ON E.EMPLOYEE_ID = OPPORTUNITIES.SALES_EMP_ID
        LEFT JOIN #dsn_alias#.EMPLOYEES ON EMPLOYEES.EMPLOYEE_ID = OPPORTUNITIES.SALES_EMP_ID
        LEFT JOIN #dsn_alias#.COMPANY_PARTNER CP ON OPPORTUNITIES.PARTNER_ID = CP.PARTNER_ID
        LEFT JOIN #dsn_alias#.COMPANY C ON CP.COMPANY_ID = C.COMPANY_ID
        LEFT JOIN #dsn_alias#.CONSUMER CON ON OPPORTUNITIES.CONSUMER_ID = CON.CONSUMER_ID
        LEFT JOIN SETUP_OPPORTUNITY_TYPE SOT ON OPPORTUNITIES.OPPORTUNITY_TYPE_ID = SOT.OPPORTUNITY_TYPE_ID
        LEFT JOIN SETUP_SALES_ADD_OPTIONS SSAO ON OPPORTUNITIES.SALE_ADD_OPTION_ID = SSAO.SALES_ADD_OPTION_ID
        LEFT JOIN #dsn_alias#.COMPANY_PARTNER CP2 ON OPPORTUNITIES.SALES_PARTNER_ID = CP2.PARTNER_ID
        LEFT JOIN #dsn_alias#.COMPANY C2 ON CP2.COMPANY_ID = C2.COMPANY_ID	
        LEFT JOIN #dsn_alias#.CONSUMER CON2 ON OPPORTUNITIES.SALES_CONSUMER_ID = CON2.CONSUMER_ID
        LEFT JOIN SETUP_PROBABILITY_RATE SPR ON OPPORTUNITIES.PROBABILITY = SPR.PROBABILITY_RATE_ID
        LEFT JOIN #dsn_alias#.PROCESS_TYPE_ROWS PTR ON OPPORTUNITIES.OPP_STAGE = PTR.PROCESS_ROW_ID
        LEFT JOIN OPPORTUNITY_CURRENCY OC ON OPPORTUNITIES.OPP_CURRENCY_ID = OC.OPP_CURRENCY_ID	
     WHERE
		OPPORTUNITIES.OPP_ID IS NOT NULL
		<cfif len(attributes.keyword)>
			AND OPPORTUNITIES.OPP_HEAD LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#trim(attributes.keyword)#%"> COLLATE SQL_Latin1_General_CP1_CI_AI
		</cfif>
        <cfif len(attributes.keyword_detail)>
			AND OPPORTUNITIES.OPP_DETAIL LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#trim(attributes.keyword_detail)#%"> COLLATE SQL_Latin1_General_CP1_CI_AI
		</cfif>
        <cfif len(attributes.keyword_oppno)>
			AND OPPORTUNITIES.OPP_NO = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(attributes.keyword_oppno)#"> COLLATE SQL_Latin1_General_CP1_CI_AI
		</cfif>
		<cfif len(attributes.start_date)>AND OPPORTUNITIES.OPP_DATE >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.start_date#"></cfif>
		<cfif len(attributes.finish_date)>AND OPPORTUNITIES.OPP_DATE <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.finish_date#"></cfif>
		<cfif isdefined("attributes.opp_status") and len(attributes.opp_status)>AND OPPORTUNITIES.OPP_STATUS = <cfqueryparam cfsqltype="cf_sql_smallint" value="#attributes.opp_status#"></cfif>
		<cfif len(attributes.ordertype) and attributes.ordertype eq 4> <!--- Takip Kaydına Göre --->
			AND OPPORTUNITIES.OPP_ID IN (SELECT OPPORTUNITIES_PLUS.OPP_ID FROM OPPORTUNITIES_PLUS,OPPORTUNITIES WHERE OPPORTUNITIES.OPP_ID = OPPORTUNITIES_PLUS.OPP_ID)
		</cfif> 
		<cfif len(attributes.member_type) and (attributes.member_type is 'partner') and len(attributes.member_name) and len(attributes.company_id)>
			AND OPPORTUNITIES.COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.company_id#">
		</cfif>
		<cfif len(attributes.member_type) and (attributes.member_type is 'consumer') and len(attributes.member_name) and len(attributes.consumer_id)>
			AND OPPORTUNITIES.CONSUMER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.consumer_id#">
		</cfif>
		<cfif len(attributes.sales_emp_id) and len(attributes.sales_emp)>
			AND OPPORTUNITIES.SALES_EMP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.sales_emp_id#">
		</cfif>
		<cfif len(attributes.sales_member_type) and (attributes.sales_member_type is 'partner') and len(attributes.sales_member_id) and len(attributes.sales_member_name)>
			AND OPPORTUNITIES.SALES_PARTNER_ID IN (SELECT PARTNER_ID FROM #dsn_alias#.COMPANY_PARTNER WHERE COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.sales_member_id#">)
		</cfif>
		<cfif len(attributes.sales_member_type) and (attributes.sales_member_type is 'consumer') and len(attributes.sales_member_id) and len(attributes.sales_member_name)>
			AND OPPORTUNITIES.SALES_CONSUMER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.sales_member_id#">
		</cfif>
		<cfif len(attributes.record_employee_id) and len(attributes.record_employee)>
			AND OPPORTUNITIES.RECORD_EMP = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.record_employee_id#">
		</cfif>
		<cfif listlen(attributes.process_stage)>
			AND OPPORTUNITIES.OPP_STAGE IN (#attributes.process_stage#)
		</cfif>
		<cfif listlen(attributes.opportunity_type_id)>
			AND OPPORTUNITIES.OPPORTUNITY_TYPE_ID IN (#attributes.opportunity_type_id#)
		</cfif>
		<cfif len(attributes.product_cat_id) and len(attributes.product_cat)>
			AND OPPORTUNITIES.PRODUCT_CAT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.product_cat_id#">
		</cfif>
		<cfif len(attributes.stock_name) and len(attributes.stock_id)>
			AND OPPORTUNITIES.STOCK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.stock_id#">
		</cfif>
		<cfif len(attributes.sale_add_option)> 
			AND OPPORTUNITIES.SALE_ADD_OPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.sale_add_option#">
		</cfif>
		<cfif len(attributes.probability)>
			AND OPPORTUNITIES.PROBABILITY = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.probability#">
		</cfif>
		<cfif len(attributes.opp_currency_id)>
			AND OPPORTUNITIES.OPP_CURRENCY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.opp_currency_id#">
		</cfif>
		<cfif isdefined("attributes.project_head") and len(attributes.project_head) and isdefined("attributes.project_id") and len(attributes.project_id)>
			AND OPPORTUNITIES.PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.project_id#">
		</cfif>
		<cfif x_control_ims eq 1 and session.ep.our_company_info.sales_zone_followup eq 1>
			AND
				(
				( OPPORTUNITIES.CONSUMER_ID IS NULL AND OPPORTUNITIES.COMPANY_ID IS NULL ) 
				OR (OPPORTUNITIES.COMPANY_ID IN (#PreserveSingleQuotes(my_ims_comp_list)#) )
				OR (OPPORTUNITIES.CONSUMER_ID IN (#PreserveSingleQuotes(my_ims_cons_list)#) )
				)
		</cfif>
		<cfif isdefined('attributes.rival_preference_reasons') and len(attributes.rival_preference_reasons)>
			AND(
			<cfloop list="#attributes.rival_preference_reasons#" index="aa" delimiters=",">
				OPPORTUNITIES.PREFERENCE_REASON_ID LIKE '%,#aa#,%' <cfif aa neq listlast(attributes.rival_preference_reasons,',') and listlen(attributes.rival_preference_reasons,',') gte 1> OR</cfif>
			</cfloop>)
		</cfif> <!--- SevimÇelik 31102018 --->
		<cfif len(attributes.assignment_status)>
			<cfif attributes.assignment_status eq 1>
				AND OPPORTUNITIES.SALES_EMP_ID IS NULL
			<cfelseif attributes.assignment_status eq 2>
				AND OPPORTUNITIES.SALES_PARTNER_ID IS NULL AND OPPORTUNITIES.SALES_CONSUMER_ID IS NULL
			</cfif>

		</cfif>

	<cfif len(attributes.ordertype)>
	ORDER BY	
		<cfif attributes.ordertype eq 1>
			OPPORTUNITIES.OPP_DATE 
		<cfelseif attributes.ordertype eq 2>
			OPPORTUNITIES.OPP_DATE DESC
		<cfelseif attributes.ordertype eq 3>
			OPPORTUNITIES.UPDATE_DATE DESC
		<cfelseif attributes.ordertype eq 4>
			PLUS_DATE DESC
		<cfelseif attributes.ordertype eq 5>
			EMPLOYEES.EMPLOYEE_NAME +' '+ EMPLOYEES.EMPLOYEE_SURNAME ASC
		<cfelseif attributes.ordertype eq 6>
			EMPLOYEES.EMPLOYEE_NAME +' '+ EMPLOYEES.EMPLOYEE_SURNAME DESC
		<cfelseif attributes.ordertype eq 7>
			PP.PROJECT_HEAD ASC
		<cfelseif attributes.ordertype eq 8>
			PP.PROJECT_HEAD DESC
		<cfelseif attributes.ordertype eq 9>
			OPPORTUNITIES.OPP_NO 
		<cfelseif attributes.ordertype eq 10>
			OPPORTUNITIES.OPP_NO DESC
		<cfelseif attributes.ordertype eq 11>
			E.EMPLOYEE_NAME +' '+ E.EMPLOYEE_SURNAME ASC
		<cfelseif attributes.ordertype eq 12>
			E.EMPLOYEE_NAME +' '+ E.EMPLOYEE_SURNAME DESC
		<cfelse>
			OPPORTUNITIES.OPP_ID DESC
		</cfif>
	</cfif>
</cfquery>