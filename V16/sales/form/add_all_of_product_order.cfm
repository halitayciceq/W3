<cfif isdefined("attributes.comp_id")>
	<cfset attributes.company_id = attributes.comp_id>
<cfelse>
	<cfset attributes.company_id = "">
</cfif>
<cfif isdefined("attributes.stock_id") and len(attributes.stock_id)>
	<cfinclude template="../../purchase/query/get_pro_comp_info.cfm">
</cfif>
<cfif isdefined("attributes.PARTNER_ID")>
	<cfset attributes.partner_id = attributes.PARTNER_ID>
<cfelse>
	<cfset attributes.partner_id = "">
</cfif>
<cfif isdefined("attributes.deliver_dept_name")>
	<cfset attributes.deliver_dept_name = attributes.deliver_dept_name>
<cfelse>
	<cfset attributes.deliver_dept_name = "">
</cfif>
<cfif isdefined("attributes.deliver_dept_id")>
	<cfset attributes.deliver_dept_id = attributes.deliver_dept_id>
<cfelse>
	<cfset attributes.deliver_dept_id = "">
</cfif>
<cfif isdefined("attributes.deliver_loc_id")>
	<cfset attributes.deliver_loc_id = attributes.deliver_loc_id>
<cfelse>
	<cfset attributes.deliver_loc_id = "">
</cfif>
<cfif isdefined("attributes.branch_id")>
	<cfset attributes.branch_id = attributes.branch_id>
<cfelse>
	<cfset attributes.branch_id = "">
</cfif>
<cfif isdefined("attributes.project_id")>
	<cfset attributes.pj_id = attributes.project_id>
<cfelse>
	<cfset attributes.pj_id = "">
</cfif>
<cfif len(attributes.company_id)>
	<cfquery name="GET_CREDIT_LIMIT" datasource="#DSN#">
		SELECT
			REVMETHOD_ID
		FROM
			COMPANY_CREDIT
		WHERE
			COMPANY_ID = #attributes.company_id#
	</cfquery>
	<cfif GET_CREDIT_LIMIT.recordcount and len(GET_CREDIT_LIMIT.REVMETHOD_ID)>
		<cfset attributes.paymethod_id = GET_CREDIT_LIMIT.REVMETHOD_ID>
	</cfif>
</cfif>
<cfif isdefined('attributes.order_base') and attributes.order_base eq 2><!--- stok detaydan satınalma siparişi veriliyorsa --->
	<cfset attributes.deliverdate=dateformat(now(),dateformat_style)>
	<cfif isdefined('attributes.stock_dept_id') and len(attributes.stock_dept_id)>
		<cfquery name="GET_LOCATION_INFO_" datasource="#dsn#">
			SELECT
				D.DEPARTMENT_HEAD,
				SL.DEPARTMENT_ID,
				SL.LOCATION_ID,
				SL.COMMENT,
				SL.PRIORITY
			FROM
				STOCKS_LOCATION SL,
				DEPARTMENT D
			WHERE
				D.DEPARTMENT_ID=SL.DEPARTMENT_ID
				AND D.DEPARTMENT_ID=#attributes.stock_dept_id#
				AND D.IS_STORE <> 2
		</cfquery>
		<cfif get_location_info_.recordcount eq 1>
			<cfset attributes.deliver_loc_id =get_location_info_.location_id>
			<cfset attributes.deliver_dept_id =get_location_info_.department_id>
			<cfset attributes.deliver_dept_name = "#get_location_info_.department_head#-#get_location_info_.comment#">
		<cfelseif get_location_info_.recordcount gt 1>
			<cfquery name="GET_LOCATION_" dbtype="query">
				SELECT
					DEPARTMENT_ID,
					LOCATION_ID,
					DEPARTMENT_HEAD,
					COMMENT
				FROM
					GET_LOCATION_INFO_
				WHERE
					DEPARTMENT_ID=#attributes.stock_dept_id#
					AND PRIORITY=1
			</cfquery>
			<cfif get_location_.recordcount>
				<cfset attributes.deliver_loc_id = get_location_.location_id>
				<cfset attributes.deliver_dept_id = get_location_.department_id>
				<cfset attributes.deliver_dept_name = "#get_location_.department_head#-#get_location_.comment#">
			</cfif>
		</cfif>
	</cfif>
</cfif>
