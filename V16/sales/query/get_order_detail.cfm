<cfif isdefined("x_control_ims") and x_control_ims eq 1 and session.ep.our_company_info.sales_zone_followup eq 1>
	<cfinclude template="../../member/query/get_ims_control.cfm">
</cfif>
<cfquery name="GET_ORDER_DETAIL" datasource="#dsn3#" blockfactor="1">
	SELECT 
		ORDERS.*,
		ORDER_ROW.ROW_PRO_MATERIAL_ID,
		ST.TEVKIFAT_CODE
	FROM 
		ORDERS
		LEFT JOIN SETUP_TEVKIFAT ST ON ST.TEVKIFAT_ID = ORDERS.TEVKIFAT_ID
		,ORDER_ROW
	WHERE 
		ORDERS.ORDER_ID = ORDER_ROW.ORDER_ID AND
	<cfif isdefined("is_instalment")>
		ORDERS.IS_INSTALMENT = 1 AND
	<cfelse>
		(ORDERS.IS_INSTALMENT IS NULL OR ORDERS.IS_INSTALMENT = 0) AND
	</cfif>
		ORDERS.ORDER_ID = #attributes.order_id# AND
		(	
			(ORDERS.PURCHASE_SALES = 1 AND ORDERS.ORDER_ZONE = 0) OR
			(ORDERS.PURCHASE_SALES = 0 AND ORDERS.ORDER_ZONE = 1)
		)
		<cfif listgetat(attributes.fuseaction,2,'.') is not 'upd_fast_sale'>
			<!--- 115093 id li iş kapsamında kapatılmıştır.
			<cfif session.ep.isBranchAuthorization>
				AND
				(
					ORDERS.DELIVER_DEPT_ID IN (SELECT DEPARTMENT_ID FROM #dsn_alias#.DEPARTMENT WHERE BRANCH_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#listgetat(session.ep.user_location,2,'-')#">)
					OR ISNULL(ORDERS.FRM_BRANCH_ID,0)=<cfqueryparam cfsqltype="cf_sql_integer" value="#listgetat(session.ep.user_location,2,'-')#">
				)
			</cfif> --->
			<cfif session.ep.isBranchAuthorization>
				AND FRM_BRANCH_ID IN (SELECT BRANCH_ID FROM #dsn_alias#.EMPLOYEE_POSITION_BRANCHES WHERE POSITION_CODE = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.position_code#">) 
			</cfif>	
		</cfif>	
		<cfif isdefined("x_control_ims") and x_control_ims eq 1 and session.ep.our_company_info.sales_zone_followup eq 1>
			AND
				(
					(ORDERS.CONSUMER_ID IS NULL AND ORDERS.COMPANY_ID IS NULL) OR
					(ORDERS.COMPANY_ID IN (#PreserveSingleQuotes(my_ims_comp_list)#)) OR
					(ORDERS.CONSUMER_ID IN (#PreserveSingleQuotes(my_ims_cons_list)#))
				)
				
		</cfif>	
</cfquery>
