<cfquery name="GET_OPPORTUNITY" datasource="#DSN3#">
	SELECT 
    	OPP_ID,
        OPP_STATUS, 
        OPP_CURRENCY_ID, 
        OPP_STAGE, 
        COMPANY_ID, 
        PARTNER_ID, 
        CONSUMER_ID, 
        OPP_HEAD, 
        OPP_DETAIL, 
        COMMETHOD_ID, 
        STOCK_ID,
        PRODUCT_CAT_ID, 
        ACTIVITY_TIME, 
        INCOME, 
        MONEY, 
        PROBABILITY, 
        OPP_DATE, 
        ACTION_DATE, 
        INVOICE_DATE, 
        APPLICATION_LEVEL, 
        SALES_PARTNER_ID, 
        SALES_CONSUMER_ID, 
        CC_POSITIONS, 
        CC_PAR_IDS, 
        CC_CON_IDS, 
        CC_GRP_IDS, 
        CC_WRKGRP_IDS, 
        OPP_ZONE, 
        PROJECT_ID, 
        IS_PROCESSED, 
        OPP_NO, 
        OPPORTUNITY_TYPE_ID, 
        REF_COMPANY_ID, 
        REF_PARTNER_ID, 
        REF_CONSUMER_ID, 
        REF_EMPLOYEE_ID, 
        COST, 
        MONEY2, 
        SALE_ADD_OPTION_ID, 
        SALES_EMP_ID, 
        SALES_TEAM_ID, 
        PREFERENCE_REASON_ID, 
        RIVAL_COMPANY_ID, 
        RIVAL_PARTNER_ID, 
        CAMPAIGN_ID, 
        ADD_RSS, 
        RECORD_EMP, 
        RECORD_PAR, 
        RECORD_DATE, 
        RECORD_IP, 
        UPDATE_EMP, 
        UPDATE_PAR, 
        UPDATE_DATE, 
        UPDATE_IP, 
        COUNTRY_ID, 
        SZ_ID 
    FROM 
	    OPPORTUNITIES 
    WHERE 
    	OPP_ID = #attributes.opp_id#
</cfquery>
<cfquery name="ADD_OPPORTUNITY_HISTORY" datasource="#DSN3#">
	INSERT INTO
		OPPORTUNITY_HISTORY
	(
		OPP_ID,
		OPP_HEAD,
		OPP_STATUS,
		OPP_CURRENCY_ID,
		COMPANY_ID,
		PARTNER_ID,
		CONSUMER_ID,
		OPP_DETAIL,
		COMMETHOD_ID,
		STOCK_ID,
		PRODUCT_CAT_ID,
		ACTIVITY_TIME,
		INCOME,
		MONEY,
		PROBABILITY,
		OPP_DATE,
		APPLICATION_LEVEL,
		SALES_EMP_ID,
		SALES_PARTNER_ID,
		CC_POSITIONS,
		CC_PAR_IDS,
		CC_CON_IDS,
		CC_GRP_IDS,
		CC_WRKGRP_IDS,
		RECORD_EMP,
		RECORD_DATE,
		RECORD_IP,
		OPP_ZONE,
		PROJECT_ID,
		IS_PROCESSED,
		OPP_NO,
		OPP_STAGE
	)
	VALUES
	(
		#get_opportunity.opp_id#,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#get_opportunity.opp_head#">,
		<cfif len(get_opportunity.opp_status)>
			#get_opportunity.opp_status#,
		<cfelse>
		    NULL,
		</cfif>	
		<cfif len(get_opportunity.opp_currency_id)>
			#get_opportunity.opp_currency_id#,
		<cfelse>
		    NULL,
		</cfif>	
		<cfif len(get_opportunity.company_id)>
			#get_opportunity.company_id#,
		<cfelse>
		    NULL,
		</cfif>	
		<cfif len(get_opportunity.partner_id)>
			#get_opportunity.partner_id#,
		<cfelse>
		    NULL,
		</cfif>	
		<cfif len(get_opportunity.consumer_id)>
			#get_opportunity.consumer_id#,
		<cfelse>
		    NULL,
		</cfif>	
		<cfif len(get_opportunity.opp_detail)>
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#get_opportunity.opp_detail#">,
		<cfelse>
		    NULL,
		</cfif>	
		<cfif len(get_opportunity.commethod_id)>
			#get_opportunity.commethod_id#,
		<cfelse>
		    NULL,
		</cfif>	
		<cfif len(get_opportunity.stock_id)>
			#get_opportunity.stock_id#,
		<cfelse>
		    NULL,
		</cfif>	
		<cfif len(get_opportunity.product_cat_id)>
			#get_opportunity.product_cat_id#,
		<cfelse>
		    NULL,
		</cfif>	
		<cfif len(get_opportunity.activity_time)>
			#get_opportunity.activity_time#,
		<cfelse>
		    NULL,
		</cfif>	
		<cfif len(get_opportunity.income)>
			#get_opportunity.income#,
		<cfelse>
		    NULL,
		</cfif>	
		<cfif len(get_opportunity.money)>
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#get_opportunity.money#">,
		<cfelse>
		    NULL,
		</cfif>	
		<cfif len(get_opportunity.probability)>
			#get_opportunity.probability#,
		<cfelse>
		    NULL,
		</cfif>	
		<cfif len(get_opportunity.opp_date)>
			<cfset attributes.opp_date_history = dateformat(get_opportunity.opp_date,dateformat_style)>
			<cf_date tarih="attributes.opp_date_history">
			#attributes.opp_date_history#,
		<cfelse>
		    NULL,
		</cfif>	
		<cfif len(get_opportunity.application_level)>
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#get_opportunity.application_level#">,
		<cfelse>
		    NULL,
		</cfif>	
		<cfif len(get_opportunity.sales_emp_id)>
			#get_opportunity.sales_emp_id#,
		<cfelse>
		    NULL,
		</cfif>	
		<cfif len(get_opportunity.sales_partner_id)>
			#get_opportunity.sales_partner_id#,
		<cfelse>
		    NULL,
		</cfif>	
		<cfif len(listsort(get_opportunity.cc_positions,"NUMERIC"))>
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#get_opportunity.cc_positions#">,
		<cfelse>
		    NULL,
		</cfif>	
		<cfif len(listsort(get_opportunity.cc_par_ids,"NUMERIC"))>
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#get_opportunity.cc_par_ids#">,
		<cfelse>
		    NULL,
		</cfif>	
		<cfif len(listsort(get_opportunity.cc_con_ids,"NUMERIC"))>
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#get_opportunity.cc_con_ids#">,
		<cfelse>
		    NULL,
		</cfif>	
		<cfif len(listsort(get_opportunity.cc_grp_ids,"NUMERIC"))>
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#get_opportunity.cc_grp_ids#">,
		<cfelse>
		    NULL,
		</cfif>	
		<cfif len(listsort(get_opportunity.cc_wrkgrp_ids,"NUMERIC"))>
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#get_opportunity.cc_wrkgrp_ids#">,
		<cfelse>
		    NULL,
		</cfif>	
		#session.ep.userid#,
		#now()#,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.remote_addr#">,
		<cfif len(get_opportunity.opp_zone)>
			#get_opportunity.opp_zone#,
		<cfelse>
		    NULL,
		</cfif>	
		<cfif len(get_opportunity.project_id)>
			#get_opportunity.project_id#,
		<cfelse>
		    NULL,
		</cfif>	
		<cfif len(get_opportunity.is_processed)>
			#get_opportunity.is_processed#,
		<cfelse>
		    NULL,
		</cfif>	
		<cfif len(get_opportunity.opp_no)>
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#get_opportunity.opp_no#">,
		<cfelse>
		   	NULL,
		</cfif>
		<cfif len (get_opportunity.opp_stage)>
		#get_opportunity.opp_stage#
		<cfelse>
		   	NULL
		</cfif>	
		)
</cfquery>
