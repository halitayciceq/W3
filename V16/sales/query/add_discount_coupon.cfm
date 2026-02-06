<cf_date tarih="attributes.valid_date">
<cflock name="#CreateUUID()#" timeout="60">
  	<cftransaction>
		<cfquery name="ADD_MONEY_CREDIT" datasource="#DSN3#" result="MAX_ID">
            INSERT INTO
                ORDER_MONEY_CREDITS
                (
                    TARGET_MARKET_ID,
                     <cfif isdefined('attributes.company_id') and len(attributes.company_id)>
                        COMPANY_ID,
                    <cfelseif isdefined('attributes.consumer_id') and len(attributes.consumer_id)>
                        CONSUMER_ID,
                    </cfif>   
                    IS_SPECIAL,         
                    MONEY_CREDIT,
                    USE_CREDIT,
                    MIN_ORDER_TOTAL,
                    VALID_DATE,
                    COUPON_COUNT,
                    IS_TYPE,
                    RECORD_DATE,
                    RECORD_EMP,
                    RECORD_IP
        
                )
                VALUES
                (
                    <cfif isDefined('attributes.target_market_id') and len(attributes.target_market_id)>#attributes.target_market_id#<cfelse>NULL</cfif>,
                    <cfif isdefined('attributes.company_id') and len(attributes.company_id)>
                        #attributes.company_id#,
                    <cfelseif isdefined('attributes.consumer_id') and len(attributes.consumer_id)>
                        #attributes.consumer_id#,
                    </cfif>  
                    <cfif isDefined('attributes.is_member_special') and len(attributes.is_member_special)>1,<cfelse>0,</cfif>         
                    #attributes.total_price#,
                    0,
                    <cfif len(attributes.min_order_total)>#attributes.min_order_total#<cfelse>NULL</cfif>,
                    <cfif len(attributes.valid_date)>#attributes.valid_date#<cfelse>NULL</cfif>,
                    #attributes.coupon_count#,
                    2,
                    #now()#,
                    #session.ep.userid#,
                    '#CGI.REMOTE_ADDR#'
                )
		</cfquery>
		<cfset letters = "1,2,3,4,5,6,7,8,9,0">
        <cfset dis_cou_no_last = ''>
        <cfset dis_cou_no = '#dateformat(now(),'YYYY')-622##dateformat(now(),'MMDD')##timeformat(now(),'HH')##MAX_ID.IDENTITYCOL#'>
        <cfset dis_cou_no = left(dis_cou_no,11)>
        <cfset remain_len = 16-len(dis_cou_no)>
        <cfloop from="1" to="#remain_len#" index="ind">				     
             <cfset random = RandRange(1, 10)>
             <cfset dis_cou_no_last = "#dis_cou_no_last##ListGetAt(letters,random,',')#">
        </cfloop>
        <cfset dis_cou_no = "#dis_cou_no##dis_cou_no_last#">
        <cfquery name="UPD_DIS_CARD" datasource="#DSN3#">
        	UPDATE
            	ORDER_MONEY_CREDITS
            SET
            	GIFT_CARD_NO = '#dis_cou_no#'
            WHERE
            	ORDER_CREDIT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#MAX_ID.IDENTITYCOL#">
        </cfquery>
    </cftransaction>
</cflock>
<script type="text/javascript">
    wrk_opener_reload();
	window.close();
</script>
