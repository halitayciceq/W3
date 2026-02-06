<cf_date tarih="attributes.valid_date">
<!---<cfquery name="UPD_MONEY_CREDIT" datasource="#DSN3#">
	UPDATE
		ORDER_MONEY_CREDITS
	SET             
		TARGET_MARKET_ID = #attributes.target_market_id#,
		 <cfif isdefined('attributes.company_id') and len(attributes.company_id)>
			COMPANY_ID = #attributes.company_id#,
		<cfelseif isdefined('attributes.consumer_id') and len(attributes.consumer_id)>
			CONSUMER_ID = #attributes.consumer_id#,
		</cfif>     
		IS_SPECIAL = <cfif isDefined('attributes.is_member_special') and len(attributes.is_member_special)>1,<cfelse>0,</cfif> 
		MONEY_CREDIT = #attributes.total_price#,
		MIN_ORDER_TOTAL = #attributes.min_order_total#,
		VALID_DATE = <cfif len(attributes.valid_date)>#attributes.valid_date#<cfelse>NULL</cfif>,
		COUPON_COUNT = #attributes.coupon_count#,
		IS_TYPE = 2,
		RECORD_DATE = #now()#,
		RECORD_IP = '#CGI.REMOTE_ADDR#'
	WHERE
		ORDER_CREDIT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.order_credit_id#">
</cfquery>--->
<cfif len(attributes.consumer_id) and len(attributes.member_name)>
	<cfquery name="GET_CONSUMER" datasource="#DSN#">
		SELECT
			CONSUMER_EMAIL
		FROM
			CONSUMER
		WHERE
			CONSUMER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.consumer_id#">
	</cfquery>
	<cfset send_email = get_consumer.consumer_email>
</cfif>
<cfif len(attributes.company_id) and len(attributes.member_name)>
	<cfquery name="GET_PARTNER" datasource="#DSN#">
		SELECT
			COMPANY_PARTNER_EMAIL
		FROM
			COMPANY_PARNER
		WHERE
			PARTNER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.partner_id#">
	</cfquery>
	<cfset send_email = get_partner.company_partner_email>    
<cfelseif len(attributes.target_market_id)>
	<cfinclude template="../query/get_targetmarket.cfm">
	<cfinclude template="../query/get_target_list_members.cfm">
	<cfoutput query="get_members"> 
    	<cfif len(user_email)> 
			<!---<cfmail from = "workcube@workcube.com"
				to = "gokhanacun@workcube.com"
				subject = "Mail deneme" type="HTML">
					Deneme maili
			</cfmail>--->
        </cfif> 
	</cfoutput>  	   
</cfif>
<script type="text/javascript">
    wrk_opener_reload();
	window.close();
</script>
