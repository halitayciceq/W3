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
		PAYROLL
		(
			PROCESS_CAT,
			PAYROLL_TYPE,
			COMPANY_ID,
			CONSUMER_ID,
			PAYROLL_TOTAL_VALUE,
			PAYROLL_OTHER_MONEY,
			PAYROLL_OTHER_MONEY_VALUE, 
			NUMBER_OF_CHEQUE,
			CURRENCY_ID,
			PAYROLL_REVENUE_DATE,
			PAYROLL_NO,
			CHEQUE_BASED_ACC_CARI,
			PAYMENT_ORDER_ID,
			PAYROLL_CASH_ID,
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
			90,
			<cfif len(attributes.company_id)>#attributes.company_id#<cfelse>NULL</cfif>,
			<cfif len(attributes.consumer_id)>#attributes.consumer_id#<cfelse>NULL</cfif>,
			#attributes.total_cheque_value#,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.ep.money#">,
			#attributes.total_cheque_value#,
			#row_count_cheque#,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.ep.money#">,
			#attributes.order_date#,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.payroll_no_cheque#">,
			1,
			#get_max_order.max_id#,
			#account_cash_id#,
			<cfif isdefined("attributes.cheque_payroll_due_value_date_") and len(attributes.cheque_payroll_due_value_date_)>#attributes.cheque_payroll_due_value_date_#<cfelse>NULL</cfif>,
			#session.ep.userid#,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#CGI.REMOTE_ADDR#">,
			#NOW()#,
			#account_cash_branch_id#,
			<cfif len(attributes.order_employee_id) and len(attributes.order_employee)>#attributes.order_employee_id#<cfelse>NULL</cfif>
		)
</cfquery>
<cfquery name="get_bordro_id" datasource="#dsn2#">
	SELECT MAX(ACTION_ID) AS P_ID FROM PAYROLL
</cfquery>
<cfset P_ID=get_bordro_id.P_ID>
<cfloop from="1" to="#attributes.kur_say#" index="j">
	<cfquery name="add_money_info" datasource="#dsn2#">
		INSERT INTO PAYROLL_MONEY 
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
<cfset portfoy_no_cheque = get_cheque_no(belge_tipi:'cheque')>
<cfset a_cheque = 1>
<!--- Her satır için bir çek kaydı yapılıyor --->
<cfloop from="1" to="#attributes.record_num_4#" index="kk">
	<cfif len(evaluate("attributes.cheque_value#kk#")) and evaluate("attributes.cheque_value#kk#") gt 0 and evaluate("attributes.row_kontrol_4#kk#") eq 1>
		<cf_date tarih='attributes.cheque_due_date#kk#'>
		<cfscript>
			'attributes.cheque_value#kk#' = filterNum(evaluate('attributes.cheque_value#kk#'),4);
		</cfscript>
		<cfquery name="add_cheque" datasource="#dsn2#">
		  INSERT INTO
			CHEQUE
			(
				CHEQUE_PAYROLL_ID,
				CHEQUE_NO,
				COMPANY_ID,
				CONSUMER_ID,						
				CHEQUE_VALUE,
				CURRENCY_ID,
				OTHER_MONEY_VALUE,
				OTHER_MONEY,
				OTHER_MONEY_VALUE2,
				OTHER_MONEY2,
				CHEQUE_STATUS_ID,
				CHEQUE_PURSE_NO,
				SELF_CHEQUE,
				CHEQUE_DUEDATE,
				BANK_NAME,
				BANK_BRANCH_NAME,
				ACCOUNT_NO,
				RECORD_EMP,
				RECORD_IP,
				RECORD_DATE,
				CASH_ID
				<cfif attributes.x_debtor_name eq 1>,DEBTOR_NAME</cfif>
			)
			VALUES
			(
				#P_ID#,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.cheque_number#kk#')#">,
				<cfif len(attributes.company_id)>#attributes.company_id#<cfelse>NULL</cfif>,
				<cfif len(attributes.consumer_id)>#attributes.consumer_id#<cfelse>NULL</cfif>,
				#evaluate("attributes.cheque_value#kk#")#,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.ep.money#">,
				#evaluate("attributes.cheque_value#kk#")#,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.ep.money#">,
				#wrk_round((evaluate("attributes.cheque_value#kk#")/attributes.currency_multiplier))#,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.ep.money2#">,
				1,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#portfoy_no_cheque#">,
				0,
				#evaluate("attributes.cheque_due_date#kk#")#,
				<cfif len(evaluate("attributes.bank_name#kk#"))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.bank_name#kk#')#"><cfelse>NULL</cfif>,
				<cfif len(evaluate("attributes.bank_branch_name#kk#"))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.bank_branch_name#kk#')#"><cfelse>NULL</cfif>,
				<cfif len(evaluate("attributes.account_no#kk#"))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.account_no#kk#')#"><cfelse>NULL</cfif>,
				#session.ep.userid#,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.remote_addr#">,
				#now()#,
				#account_cash_id#
				<cfif attributes.x_debtor_name eq 1>,<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.comp_name#"></cfif>
			)
		</cfquery>
		<cfquery name="get_last_cheque" datasource="#dsn2#">
			SELECT MAX(CHEQUE_ID) AS MAX_ID FROM CHEQUE WHERE CHEQUE_PAYROLL_ID=#P_ID#
		</cfquery>
		<cfloop from="1" to="#attributes.kur_say#" index="j">
			<cfquery name="ADD_MONEY_INFO" datasource="#dsn2#">
				INSERT INTO 
				CHEQUE_MONEY 
				(
					ACTION_ID,
					MONEY_TYPE,
					RATE2,
					RATE1,
					IS_SELECTED
				)
				VALUES
				(
					#get_last_cheque.max_id#,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#wrk_eval('attributes.hidden_rd_money_#j#')#">,
					#evaluate("attributes.txt_rate2_#j#")#,
					#evaluate("attributes.txt_rate1_#j#")#,
					<cfif evaluate("attributes.hidden_rd_money_#j#") is session.ep.money>1<cfelse>0</cfif>
				)
			</cfquery>
		</cfloop> 
		<cfset portfoy_no_cheque = portfoy_no_cheque+1>
		<cfset a_cheque = a_cheque+1>
		<cfquery name="add_cheque_history" datasource="#dsn2#">
			INSERT INTO
				CHEQUE_HISTORY
				(
					CHEQUE_ID,
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
					#get_last_cheque.max_id#,
					<cfif len(attributes.company_id)>#attributes.company_id#<cfelse>NULL</cfif>,
					<cfif len(attributes.consumer_id)>#attributes.consumer_id#<cfelse>NULL</cfif>,
					#P_ID#,
					#attributes.order_date#,
					1,
					#evaluate("attributes.cheque_value#kk#")#,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.ep.money#">,
					#wrk_round((evaluate("attributes.cheque_value#kk#")/attributes.currency_multiplier))#,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.ep.money2#">,
					#NOW()#
				)
		</cfquery>
		<cfquery name="add_cheque_pos" datasource="#dsn2#">
			INSERT INTO 
				#dsn3_alias#.ORDER_VOUCHER_RELATION
				(
				ORDER_ID,
				CHEQUE_ID,
				PERIOD_ID
				)
			VALUES
				(
				#get_max_order.max_id#,
				#get_last_cheque.max_id#,
				#session.ep.period_id#
				)
		</cfquery>
	</cfif>
</cfloop>
<cfquery name="get_last_cheques" datasource="#dsn2#">
	SELECT * FROM CHEQUE WHERE CHEQUE_PAYROLL_ID=#P_ID#
</cfquery>
<cfset portfoy_no_cheque = get_cheque_no(belge_tipi:'cheque',belge_no:portfoy_no_cheque)>

