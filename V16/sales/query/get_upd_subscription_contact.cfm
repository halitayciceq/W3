<cfif not isDefined("GET_SUBSCRIPTION_AUTHORITY")>
	<!--- include edildiği sayfada çekilmiş olabilir bu nedenle kontrol ekledik Author: Tolga Sütlü, Ahmet Yolcu--->
   <cfset gsa = createObject("component","V16.objects.cfc.subscriptionNauthority")/>
   <cfset GET_SUBSCRIPTION_AUTHORITY= gsa.SelectAuthority()/>
</cfif>
<cfquery name="get_comp_info" datasource="#dsn#">
    SELECT COMMON_SUBSCRIPTION_USAGE FROM OUR_COMPANY_INFO WHERE COMP_ID = #session.ep.company_id#
</cfquery>
<cfif len(get_comp_info.COMMON_SUBSCRIPTION_USAGE)>
    <cfset dsn3 = "#dsn#_#get_comp_info.COMMON_SUBSCRIPTION_USAGE#">
</cfif>
<cfquery name="GET_SUBSCRIPTION" datasource="#DSN3#">
	SELECT 
    	SC.SUBSCRIPTION_ID, 
        SC.IS_ACTIVE, 
        SC.SUBSCRIPTION_NO, 
        SC.SUBSCRIPTION_HEAD, 
        SC.COMPANY_ID, 
        SC.PARTNER_ID, 
        SC.CONSUMER_ID, 
        SC.PRODUCT_ID, 
        SC.STOCK_ID, 
        SC.CONTRACT_NO, 
        SC.INVOICE_COMPANY_ID, 
        SC.INVOICE_CONSUMER_ID, 
        SC.SUBSCRIPTION_TYPE_ID, 
        SC.SUBSCRIPTION_STAGE, 
        SC.SALES_COMPANY_ID, 
        SC.SALES_PARTNER_ID, 
        SC.SALES_CONSUMER_ID, 
        SC.REF_COMPANY_ID, 
        SC.REF_PARTNER_ID, 
        SC.REF_CONSUMER_ID, 
        SC.REF_EMPLOYEE_ID, 
        SC.MONTAGE_EMP_ID, 
        SC.PAYMENT_TYPE_ID, 
        SC.MONTAGE_DATE, 
        SC.START_DATE, 
        SC.FINISH_DATE, 
        SC.SUBSCRIPTION_DETAIL, 
        SC.SHIP_ADDRESS, 
        SC.SHIP_POSTCODE, 
        SC.SHIP_SEMT, 
        SC.SHIP_COUNTY_ID, 
        SC.SHIP_CITY_ID,
        SC.SHIP_COUNTRY_ID, 
        SC.INVOICE_ADDRESS, 
        SC.INVOICE_POSTCODE, 
        SC.INVOICE_SEMT, 
        SC.INVOICE_COUNTY_ID, 
        SC.INVOICE_CITY_ID, 
        SC.INVOICE_COUNTRY_ID,
        CB.COMPBRANCH_ALIAS AS ALIAS, 
        SC.CONTACT_ADDRESS, 
        SC.CONTACT_POSTCODE, 
        SC.CONTACT_SEMT, 
        SC.CONTACT_COUNTY_ID, 
        SC.CONTACT_CITY_ID, 
        SC.CONTACT_COUNTRY_ID, 
        SC.CANCEL_TYPE_ID, 
        SC.CANCEL_DATE, 
        SC.SALES_EMP_ID, 
        SC.MEMBER_CC_ID, 
        SC.SPECIAL_CODE, 
        SC.INVOICE_PARTNER_ID, 
        SC.SALES_ADD_OPTION_ID, 
        SC.SUBSCRIPTION_ADD_OPTION_ID, 
        SC.SUBSCRIPTION_INVOICE_DETAIL, 
        SC.PROJECT_ID, 
        SC.SALES_MEMBER_COMM_VALUE, 
        SC.SALES_MEMBER_COMM_MONEY, 
        SC.ASSETP_ID, 
        SC.VALID_DAYS, 
        SC.START_CLOCK_1, 
        SC.START_MINUTE_1, 
        SC.FINISH_CLOCK_1, 
        SC.FINISH_MINUTE_1, 
        SC.IS_GENERAL_DATE, 
        SC.START_CLOCK_2, 
        SC.START_MINUTE_2, 
        SC.FINISH_CLOCK_2, 
        SC.FINISH_MINUTE_2, 
        SC.START_CLOCK_3, 
        SC.START_MINUTE_3,
        SC.FINISH_CLOCK_3, 
        SC.FINISH_MINUTE_3, 
        SC.HOUR1, 
        SC.MINUTE1, 
        SC.RESPONSE_HOUR1, 
        SC.RESPONSE_MINUTE1, 
        SC.CAMPAIGN_ID, 
        SC.SHIP_COORDINATE_1, 
        SC.SHIP_COORDINATE_2, 
        SC.INVOICE_COORDINATE_1, 
        SC.INVOICE_COORDINATE_2, 
        SC.CONTACT_COORDINATE_1, 
        SC.CONTACT_COORDINATE_2, 
        SC.RECORD_EMP, 
        SC.RECORD_IP, 
        SC.RECORD_DATE, 
        SC.UPDATE_EMP, 
        SC.UPDATE_IP, 
        SC.UPDATE_DATE, 
        SC.OPP_ID,
		SC.OTHER_MONEY,
		SC.SA_DISCOUNT,
		SC.SUBSCRIPTION_DETAIL_2,
        SC.REFERANCE_STATUS_ID,
        SC.SHIP_SZ_ID,
        SC.INVOICE_SZ_ID,
        SC.CONTACT_SZ_ID,
        SC.BRANCH_ID,
        SC.PRODUCT_KEY,
        C.NICKNAME,
        C.FULLNAME,
        SC.OUR_COMPANY_ID,
        SIP.PROPERTY16 <!---DOMAIN BILGISI--->
        
    FROM 
	    SUBSCRIPTION_CONTRACT SC
        LEFT JOIN #dsn_alias#.COMPANY_BRANCH CB ON SC.INVOICE_ADDRESS_ID = CB.COMPBRANCH_ID
        LEFT JOIN #dsn_alias#.COMPANY C ON SC.COMPANY_ID = C.COMPANY_ID
        LEFT JOIN SUBSCRIPTION_INFO_PLUS SIP ON SIP.SUBSCRIPTION_ID = SC.SUBSCRIPTION_ID
        LEFT JOIN #dsn_alias#.BRANCH B ON B.BRANCH_ID = SC.BRANCH_ID
    WHERE 
        SC.SUBSCRIPTION_ID = #attributes.subscription_id#
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
                        AND SC.SUBSCRIPTION_TYPE_ID = SPC.SUBSCRIPTION_TYPE_ID
                )
        </cfif>
</cfquery>
<cfif get_subscription.recordcount>
	<cfquery name="GET_ORDER" datasource="#DSN3#">
		SELECT
			ORDER_ID
		FROM
			SUBSCRIPTION_CONTRACT_ORDER
		WHERE
			SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_subscription.subscription_id#">
	</cfquery>
	<cfquery name="GET_ORDER_NUM" datasource="#DSN3#">
		SELECT 
			ORDER_NUMBER 
		FROM 
			ORDERS 
		WHERE 
		<cfif get_order.recordcount>
			ORDER_ID IN (#listsort(valuelist(get_order.order_id),"numeric","asc",",")#)
		<cfelse>
			ORDER_ID IS NULL
		</cfif>
	</cfquery>
    <cfquery name="GET_COUNT_IAMUSER" datasource="#DSN#">
		SELECT  
            IAM_USER_NAME
		FROM 
            SUBSCRIPTION_IAM 
		WHERE 
		    SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_subscription.subscription_id#">
            AND IAM_ACTIVE = 1
        GROUP BY IAM_USER_NAME
	</cfquery>
</cfif>
