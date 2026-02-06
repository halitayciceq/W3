<cfif isdefined("x_control_ims") and x_control_ims eq 1 and session.ep.our_company_info.sales_zone_followup eq 1>
	<cfinclude template="../../member/query/get_ims_control.cfm">
</cfif>
<cfquery name="GET_OFFER" datasource="#DSN3#">
	SELECT 
		* 
		,ST.TEVKIFAT_CODE
	FROM 
		OFFER
		LEFT JOIN SETUP_TEVKIFAT ST ON ST.TEVKIFAT_ID = OFFER.TEVKIFAT_ID
	WHERE 
		OFFER_ID IN (#attributes.offer_id#)
		<cfif isdefined("x_control_ims") and x_control_ims eq 1 and session.ep.our_company_info.sales_zone_followup eq 1>
			AND
				(
				(CONSUMER_ID IS NULL AND COMPANY_ID IS NULL) 
				OR (COMPANY_ID IN (#PreserveSingleQuotes(my_ims_comp_list)#))
				OR (CONSUMER_ID IN (#PreserveSingleQuotes(my_ims_cons_list)#))
				)
		</cfif>
</cfquery>
