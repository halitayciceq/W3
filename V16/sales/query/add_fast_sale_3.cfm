<cfloop from="1" to="#kur_say#" index="k">
	 <cfif isdefined("kasa#k#") and evaluate("currency_type#k#") is session.ep.money>
	 	<cfset account_cash_id = evaluate("kasa#k#")>
	 </cfif>
</cfloop>
<cfquery name="get_cash_branch" datasource="#dsn2#">
	SELECT BRANCH_ID FROM CASH WHERE CASH_ID = #account_cash_id#
</cfquery>
<cfset account_cash_branch_id = get_cash_branch.branch_id>
<cfquery name="add_payroll" datasource="#dsn2#">
	 INSERT INTO
		VOUCHER_PAYROLL
		(
			PROCESS_CAT,
			PAYROLL_TYPE,
			COMPANY_ID,
			CONSUMER_ID,
			PAYROLL_TOTAL_VALUE,
			PAYROLL_OTHER_MONEY,
			PAYROLL_OTHER_MONEY_VALUE, 
			NUMBER_OF_VOUCHER,
			CURRENCY_ID,
			PAYROLL_REVENUE_DATE,
			PAYROLL_NO,
			VOUCHER_BASED_ACC_CARI,
			PAYMENT_ORDER_ID,
			PAYROLL_CASH_ID,
			CASH_PAYMENT_VALUE,
			PAYMETHOD_ID,
			PAYROLL_AVG_DUEDATE,
			RECORD_EMP,
			RECORD_IP,
			RECORD_DATE,
			BRANCH_ID,
			REVENUE_COLLECTOR_ID
		)
		VALUES
		(
			0,
			97,
			<cfif len(attributes.company_id)>#attributes.company_id#<cfelse>NULL</cfif>,
			<cfif len(attributes.consumer_id)>#attributes.consumer_id#<cfelse>NULL</cfif>,
			#attributes.total_voucher_value#,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.ep.money#">,
			#attributes.total_voucher_value#,
			#row_count_voucher#,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.ep.money#">,
			#attributes.order_date#,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.payroll_no#">,
			1,
			#get_max_order.max_id#,
			#account_cash_id#,
			<cfif len(attributes.total_cash_amount)>#attributes.total_cash_amount#<cfelse>0</cfif>,
			<cfif len(attributes.paymethod_id)>#attributes.paymethod_id#<cfelse>NULL</cfif>,
			<cfif isdefined("attributes.payroll_due_value_date_") and len(attributes.payroll_due_value_date_)>#attributes.payroll_due_value_date_#<cfelse>NULL</cfif>,
			#session.ep.userid#,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#CGI.REMOTE_ADDR#">,
			#NOW()#,
			#account_cash_branch_id#,
			<cfif len(attributes.order_employee_id) and len(attributes.order_employee)>#attributes.order_employee_id#<cfelse>NULL</cfif>
		)
</cfquery>
<cfquery name="get_bordro_id" datasource="#dsn2#">
	SELECT MAX(ACTION_ID) AS P_ID FROM VOUCHER_PAYROLL
</cfquery>
<cfset P_ID=get_bordro_id.P_ID>
<cfloop from="1" to="#attributes.kur_say#" index="j">
	<cfquery name="add_money_info" datasource="#dsn2#">
		INSERT INTO VOUCHER_PAYROLL_MONEY 
		(
			ACTION_ID,
			MONEY_TYPE,
			RATE2,
			RATE1,
			IS_SELECTED
		)
		VALUES
		(
			#P_ID#,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#wrk_eval('attributes.hidden_rd_money_#j#')#">,
			#evaluate("attributes.txt_rate2_#j#")#,
			#evaluate("attributes.txt_rate1_#j#")#,
			<cfif evaluate("attributes.hidden_rd_money_#j#") is session.ep.money>1<cfelse>0</cfif>
		)
	</cfquery>
</cfloop>
<cfset portfoy_no = get_cheque_no(belge_tipi:'voucher')>
<cfset a_voucher = 1>
<!--- Her satır için bir senet kaydı yapılıyor --->
<cfloop from="1" to="#attributes.record_num_3#" index="kk">
	<cfif len(evaluate("attributes.voucher_value#kk#")) and evaluate("attributes.voucher_value#kk#") gt 0 and evaluate("attributes.row_kontrol_3#kk#") eq 1>
		<cf_date tarih='attributes.due_date#kk#'>
		<cfscript>
			'attributes.voucher_value#kk#' = filterNum(evaluate('attributes.voucher_value#kk#'),4);
		</cfscript>
		<cfquery name="add_voucher" datasource="#dsn2#">
		  INSERT INTO
			VOUCHER
			(
				VOUCHER_PAYROLL_ID,
				VOUCHER_NO,
				COMPANY_ID,
				CONSUMER_ID,						
				VOUCHER_VALUE,
				CURRENCY_ID,
				OTHER_MONEY_VALUE,
				OTHER_MONEY,
				OTHER_MONEY_VALUE2,
				OTHER_MONEY2,
				VOUCHER_STATUS_ID,
				VOUCHER_PURSE_NO,
				SELF_VOUCHER,
				VOUCHER_DUEDATE,
				RECORD_EMP,
				RECORD_IP,
				RECORD_DATE,
				IS_PAY_TERM,
				CASH_ID
				<cfif attributes.x_debtor_name eq 1>,DEBTOR_NAME</cfif>
			)
			VALUES
			(
				#P_ID#,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.payroll_no##a_voucher#">,
				<cfif len(attributes.company_id)>#attributes.company_id#<cfelse>NULL</cfif>,
				<cfif len(attributes.consumer_id)>#attributes.consumer_id#<cfelse>NULL</cfif>,
				#evaluate("attributes.voucher_value#kk#")#,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.ep.money#">,
				#evaluate("attributes.voucher_value#kk#")#,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.ep.money#">,
				#wrk_round((evaluate("attributes.voucher_value#kk#")/attributes.currency_multiplier))#,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.ep.money2#">,
				1,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#portfoy_no#">,
				0,
				#evaluate("attributes.due_date#kk#")#,
				#session.ep.userid#,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.remote_addr#">,
				#now()#,
				<cfif isdefined("is_pay_term#kk#")>1<cfelse>0</cfif>,
				#account_cash_id#
				<cfif attributes.x_debtor_name eq 1>,<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.comp_name#"></cfif>
				)
		</cfquery>
		<cfquery name="get_last_voucher" datasource="#dsn2#">
			SELECT MAX(VOUCHER_ID) AS MAX_ID FROM VOUCHER WHERE VOUCHER_PAYROLL_ID=#P_ID#
		</cfquery>
		<cfloop from="1" to="#attributes.kur_say#" index="j">
			<cfquery name="ADD_MONEY_INFO" datasource="#dsn2#">
				INSERT INTO VOUCHER_MONEY 
				(
					ACTION_ID,
					MONEY_TYPE,
					RATE2,
					RATE1,
					IS_SELECTED
				)
				VALUES
				(
					#get_last_voucher.max_id#,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#wrk_eval('attributes.hidden_rd_money_#j#')#">,
					#evaluate("attributes.txt_rate2_#j#")#,
					#evaluate("attributes.txt_rate1_#j#")#,
					<cfif evaluate("attributes.hidden_rd_money_#j#") is session.ep.money>1<cfelse>0</cfif>
				)
			</cfquery>
		</cfloop> 
		<cfset portfoy_no = portfoy_no+1>
		<cfset a_voucher = a_voucher+1>
		<cfquery name="add_voucher_history" datasource="#dsn2#">
			INSERT INTO
				VOUCHER_HISTORY
				(
					VOUCHER_ID,
					COMPANY_ID,
					CONSUMER_ID,
					PAYROLL_ID,
					ACT_DATE,
					STATUS,
					OTHER_MONEY_VALUE,
					OTHER_MONEY,
					OTHER_MONEY_VALUE2,
					OTHER_MONEY2,
					RECORD_DATE
				)
				VALUES
				(
					#get_last_voucher.max_id#,
					<cfif len(attributes.company_id)>#attributes.company_id#<cfelse>NULL</cfif>,
					<cfif len(attributes.consumer_id)>#attributes.consumer_id#<cfelse>NULL</cfif>,
					#P_ID#,
					#attributes.order_date#,
					1,
					#evaluate("attributes.voucher_value#kk#")#,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.ep.money#">,
					#wrk_round((evaluate("attributes.voucher_value#kk#")/attributes.currency_multiplier))#,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.ep.money2#">,
					#NOW()#
				)
		</cfquery>
		<cfquery name="add_voucher_pos" datasource="#dsn2#">
			INSERT INTO 
				#dsn3_alias#.ORDER_VOUCHER_RELATION
				(
				ORDER_ID,
				VOUCHER_ID,
				PERIOD_ID
				)
			VALUES
				(
				#get_max_order.max_id#,
				#get_last_voucher.max_id#,
				#session.ep.period_id#
				)
		</cfquery>
	</cfif>
</cfloop>
<cfquery name="get_last_vouchers" datasource="#dsn2#">
	SELECT * FROM VOUCHER WHERE VOUCHER_PAYROLL_ID=#P_ID#
</cfquery>
<cfset portfoy_no = get_cheque_no(belge_tipi:'voucher',belge_no:portfoy_no)>

