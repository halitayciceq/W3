<!--- Hızlı satış ekranında kullanılıyor perakende satış faturası mantığında çalıştığı için aynı queryleri kullanıyorum --->
<cf_get_lang_set module_name="sales">
<cflock name="#CreateUUID()#" timeout="60">
	<cftransaction>
		<cfif isdefined("attributes.member_type") and attributes.member_type eq 1>
			<cfinclude template="../../invoice/query/add_company.cfm">
		<cfelseif isdefined("attributes.member_type") and attributes.member_type eq 2>
			<cfinclude template="../../invoice/query/add_consumer.cfm">
			<cfquery name="get_member_code" datasource="#dsn2#">
				SELECT MEMBER_CODE FROM #dsn_alias#.CONSUMER WHERE CONSUMER_ID = #get_max_cons.max_cons#
			</cfquery>
            <cfif isdefined("attributes.vocation_type") and len(attributes.vocation_type)>
                <cfquery name="get_forward_limit" datasource="#dsn2#">
                    SELECT FORWARD_SALE_LIMIT FROM #dsn_alias#.SETUP_VOCATION_TYPE WHERE VOCATION_TYPE_ID = #attributes.vocation_type#
                </cfquery>
                <cfif len(get_forward_limit.forward_sale_limit)>
                    <cfquery name="get_stage" datasource="#dsn2#" maxrows="1">
                        SELECT TOP 1
                            PTR.STAGE,
                            PTR.PROCESS_ROW_ID 
                        FROM
                            #dsn_alias#.PROCESS_TYPE_ROWS PTR,
                            #dsn_alias#.PROCESS_TYPE_OUR_COMPANY PTO,
                            #dsn_alias#.PROCESS_TYPE PT
                        WHERE
                            PT.IS_ACTIVE = 1 AND
                            PT.PROCESS_ID = PTR.PROCESS_ID AND
                            PT.PROCESS_ID = PTO.PROCESS_ID AND
                            PTO.OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#"> AND
                            PT.FACTION LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%contract.detail_contract_company%">
                        ORDER BY
                            PTR.PROCESS_ROW_ID
                    </cfquery>
                    <cfif get_stage.recordcount>
                        <cfquery name="add_credit" datasource="#dsn2#" result="MAX_ID">
                            INSERT INTO
                                #dsn_alias#.COMPANY_CREDIT
                                (
                                    PROCESS_STAGE,
                                    CONSUMER_ID,
                                    FORWARD_SALE_LIMIT,
                                    FORWARD_SALE_LIMIT_OTHER,
                                    TOTAL_RISK_LIMIT,
                                    TOTAL_RISK_LIMIT_OTHER,
                                    MONEY,
                                    OUR_COMPANY_ID,
                                    RECORD_IP,
                                    RECORD_EMP,
                                    RECORD_DATE
                                )
                            VALUES
                                (
                                    #get_stage.process_row_id#,
                                    #get_max_cons.max_cons#,
                                    #get_forward_limit.forward_sale_limit#,
                                    #get_forward_limit.forward_sale_limit#,
                                    #get_forward_limit.forward_sale_limit#,
                                    #get_forward_limit.forward_sale_limit#,
                                    '#session.ep.money#',
                                    #session.ep.company_id#,
                                    '#cgi.remote_addr#',
                                    #session.ep.userid#,
                                    #now()#
                                )
                        </cfquery>
                        <cfquery name="get_money_credit" datasource="#dsn2#">
                            SELECT * FROM SETUP_MONEY
                        </cfquery>
                        <cfoutput query="get_money_credit">
                            <cfquery name="add_credit_money" datasource="#dsn2#">
                                INSERT INTO
                                    #dsn_alias#.COMPANY_CREDIT_MONEY
                                    (
                                        MONEY_TYPE,
                                        ACTION_ID,
                                        RATE2,
                                        RATE1,
                                        IS_SELECTED
                                    )
                                    VALUES
                                    (
                                        '#money#',
                                         #MAX_ID.IDENTITYCOL#,
                                         #rate2#,
                                         #rate1#,
                                         <cfif session.ep.money is money>1<cfelse>0</cfif>
                                    )
                            </cfquery>
                        </cfoutput>
                    </cfif>
                </cfif>
        	</cfif>
		</cfif>
	</cftransaction>
</cflock>
<script type="text/javascript">
	<cfif isdefined("attributes.member_type") and attributes.member_type eq 1>
		window.opener.form_basket.company_id.value = <cfoutput>#get_max.max_company#</cfoutput>;
	<cfelse>
		window.opener.form_basket.member_code.value = '<cfoutput>#get_member_code.member_code#</cfoutput>';
		window.opener.form_basket.consumer_id.value = <cfoutput>#get_max_cons.max_cons#</cfoutput>;
	</cfif>
	if(window.opener.form_basket.is_new_member!=undefined)
		window.opener.form_basket.is_new_member.value=1;
	window.opener.form_basket.action='<cfoutput>#request.self#?fuseaction=#listgetat(attributes.fuseaction,1,'.')#.emptypopup_add_fast_sale</cfoutput>';
	window.opener.form_basket.target='';
	window.opener.find_risk();
	window.close();
</script>
<cf_get_lang_set module_name="#lcase(listgetat(attributes.fuseaction,1,'.'))#">



