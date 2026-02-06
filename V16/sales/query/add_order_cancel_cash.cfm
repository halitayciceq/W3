<cfif attributes.cash_count gt 0>
	<cfquery name="get_cash_process_cat" datasource="#dsn2#" maxrows="1">
		SELECT IS_ACCOUNT,IS_CARI,IS_ACCOUNT_GROUP FROM #dsn3_alias#.SETUP_PROCESS_CAT WHERE PROCESS_TYPE = 32
	</cfquery>
	<cfif get_cash_process_cat.recordcount>
		<cfset is_account_cash = get_cash_process_cat.is_account>
		<cfset is_account_group_cash = get_cash_process_cat.is_account_group>
		<cfset is_cari_cash = get_cash_process_cat.is_cari>
	<cfelse>
		<cfset is_account_cash = 1>
		<cfset is_account_group_cash = 1>
		<cfset is_cari_cash = 1>
	</cfif>
	<cfloop from="1" to="#attributes.cash_count#" index="k">
		<cfquery name="get_cash_code" datasource="#dsn2#">
			SELECT CASH_ACC_CODE,BRANCH_ID FROM CASH WHERE CASH_ID=#listfirst(evaluate("attributes.kasa#k#"),';')#
		</cfquery>
		<cfif len(get_cash_code.BRANCH_ID)>
			<cfset cash_branch_id = get_cash_code.BRANCH_ID>
		<cfelse>
			<cfset cash_branch_id = ''>
		</cfif>
		<cfscript>
			'attributes.cash_amount#k#' = filterNum(evaluate('attributes.cash_amount#k#'));
			'attributes.system_cash_amount#k#' = filterNum(evaluate('attributes.system_cash_amount#k#'));
		</cfscript>
		<cfquery name="add_cash_action" datasource="#dsn2#">
			INSERT INTO CASH_ACTIONS
				(
				CASH_ACTION_FROM_CASH_ID,
				ACTION_TYPE,
				ACTION_TYPE_ID,
				ORDER_ID,
				<cfif isDefined("attributes.company_id") and len(attributes.company_id)>
					CASH_ACTION_TO_COMPANY_ID,
				<cfelse>
					CASH_ACTION_TO_CONSUMER_ID,
				</cfif>
				CASH_ACTION_VALUE,
				CASH_ACTION_CURRENCY_ID,				
				ACTION_DATE,
				ACTION_DETAIL,
				PAPER_NO,
				IS_ACCOUNT,
				IS_ACCOUNT_TYPE,
				RECORD_EMP,
				RECORD_IP,
				RECORD_DATE,
				PROCESS_CAT
				)
			VALUES
				(
				#listfirst(evaluate("kasa#k#"),';')#,
				'ÖDEME',
				32,
				#attributes.order_id#,
				<cfif isDefined("attributes.company_id") and len(attributes.company_id)>
					#attributes.company_id#,
				<cfelse>
					#attributes.consumer_id#,
				</cfif>
				#evaluate('attributes.cash_amount#k#')#,
				'#wrk_eval('currency_type#k#')#',
				#attributes.cancel_date#,
				'#attributes.order_number# (PEŞİNAT iPTAL)',
				'#attributes.order_number#',
				<cfif is_account_cash eq 1>
					1,
					12,
				<cfelse>
					0,
					12,
				</cfif>
				#SESSION.EP.USERID#,
				'#CGI.REMOTE_ADDR#',
				#NOW()#,
				0
				)
		</cfquery>
		<cfquery name="get_act_id" datasource="#dsn2#">
			SELECT MAX(ACTION_ID) AS ACT_ID	FROM CASH_ACTIONS
		</cfquery>
		<cfset act_id=get_act_id.act_id>
		<cfquery name="add_order_cash_pos" datasource="#dsn2#">
			INSERT INTO 
				#dsn3_alias#.ORDER_CASH_POS
				(
				ORDER_ID,
				CASH_ID,
				KASA_ID,
				KASA_PERIOD_ID,
				IS_CANCEL
				)
			VALUES
				(
				#attributes.order_id#,
				#act_id#,
				#listfirst(evaluate("kasa#k#"),';')#,
				#session.ep.period_id#,
				1
				)
		</cfquery>
		<cfscript>
			if(is_cari_cash eq 1)
			{
				carici(
					action_id : ACT_ID,  
					action_table : 'CASH_ACTIONS',
					workcube_process_type : 32,
					account_card_type : 12,
					islem_tarihi : attributes.cancel_date,
					islem_tutari : evaluate("attributes.system_cash_amount#k#"),
					islem_belge_no : attributes.order_number,
					to_cmp_id : attributes.company_id,
					to_consumer_id : attributes.consumer_id,
					islem_detay : 'ÖDEME',
					other_money_value : evaluate("attributes.cash_amount#k#"),
					other_money : evaluate("attributes.currency_type#k#"),
					action_currency : session.ep.money,
					from_cash_id : evaluate("kasa#k#"),
					from_branch_id :iif(len(cash_branch_id),de('#cash_branch_id#'),de('')),
					process_cat : 0
					);
			}
			if(is_account_cash eq 1)
			{
				str_card_detail = '#attributes.order_number# (PEŞİNAT iPTAL)';
				muhasebeci(
					wrk_id='#wrk_id#',
					action_id : ACT_ID,
					workcube_process_type : 32,
					account_card_type : 12, 
					company_id : attributes.company_id,
					consumer_id : attributes.consumer_id,
					islem_tarihi : attributes.cancel_date,
					borc_hesaplar : ACC,
					borc_tutarlar : wrk_round(evaluate("attributes.system_cash_amount#k#")),
					other_amount_borc : evaluate("attributes.cash_amount#k#"),
					other_currency_borc : evaluate("attributes.currency_type#k#"),
					alacak_hesaplar : get_cash_code.cash_acc_code,
					alacak_tutarlar : wrk_round(evaluate("attributes.system_cash_amount#k#")),
					other_amount_alacak : evaluate("attributes.cash_amount#k#"),
					other_currency_alacak : evaluate("attributes.currency_type#k#"),
					to_branch_id :iif(len(cash_branch_id),de('#cash_branch_id#'),de('')),
					fis_detay:'ÖDEME',
					fis_satir_detay:str_card_detail,
					belge_no : attributes.order_number,
					is_account_group : is_account_group_cash
					);
			}
		</cfscript>		
	</cfloop>
</cfif>
