<cfquery name="get_cash_process_cat" datasource="#dsn2#" maxrows="1">
	SELECT IS_ACCOUNT,IS_CARI,IS_ACCOUNT_GROUP FROM #dsn3_alias#.SETUP_PROCESS_CAT WHERE PROCESS_TYPE = 31
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
<cfset cash_currency_multiplier = ''>
<cfif isDefined('attributes.kur_say') and len(attributes.kur_say)>
	<cfloop from="1" to="#attributes.kur_say#" index="mon">
		<cfif evaluate("attributes.hidden_rd_money_#mon#") is form.basket_money>
			<cfset cash_currency_multiplier = evaluate('attributes.txt_rate2_#mon#/attributes.txt_rate1_#mon#')>
		</cfif>
	</cfloop>	
</cfif>

<cfif isdefined("attributes.cash") and (attributes.cash eq 1)>
	<cfloop from="1" to="#kur_say#" index="k">
	  <cfif isdefined("kasa#k#") and isdefined("cash_amount#k#") and (evaluate('cash_amount#k#') gt 0)>
		<cfquery name="get_cash_code" datasource="#dsn2#">
			SELECT CASH_ACC_CODE,BRANCH_ID FROM CASH WHERE CASH_ID=#evaluate("kasa#k#")#
		</cfquery>
		<cfif len(get_cash_code.BRANCH_ID)>
			<cfset cash_branch_id = get_cash_code.BRANCH_ID>
		<cfelse>
			<cfset cash_branch_id = ''>
		</cfif>
		<cfset wrk_id_1 = dateformat(now(),'YYYYMMDD')&timeformat(now(),'HHmmss')&'_#session.ep.userid#_'&round(rand()*100)>
		<cfquery name="add_cash_action" datasource="#dsn2#">
			INSERT INTO CASH_ACTIONS
				(
					WRK_ID,
					CASH_ACTION_TO_CASH_ID,
					ACTION_TYPE,
					ACTION_TYPE_ID,
					ORDER_ID,
					<cfif isDefined("attributes.company_id") and len(attributes.company_id)>
						CASH_ACTION_FROM_COMPANY_ID,
					<cfelse>
						CASH_ACTION_FROM_CONSUMER_ID,
					</cfif>
					CASH_ACTION_VALUE,
					CASH_ACTION_CURRENCY_ID,				
					ACTION_DATE,
					ACTION_DETAIL,
					IS_PROCESSED,
					PAPER_NO,
					IS_ACCOUNT,
					IS_ACCOUNT_TYPE,
					RECORD_EMP,
					RECORD_IP,
					RECORD_DATE,
					PROCESS_CAT,
					ACTION_VALUE,
					ACTION_CURRENCY_ID
					<cfif len(session.ep.money2)>
						,ACTION_VALUE_2
						,ACTION_CURRENCY_ID_2
					</cfif>
				)
			VALUES
				(
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#wrk_id_1#">,
					#evaluate("kasa#k#")#,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="NAKİT TAHSİLAT">,
					31,
					#get_max_order.max_id#,
					<cfif isDefined("attributes.company_id") and len(attributes.company_id)>
						#attributes.company_id#,
					<cfelse>
						#attributes.consumer_id#,
					</cfif>
					#evaluate('cash_amount#k#')#,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#wrk_eval('currency_type#k#')#">,
					#attributes.order_date#,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#get_last_order.order_number# (PEŞİNAT)">,
					<cfif is_account_cash>1<cfelse>0</cfif>,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#get_last_order.order_number#">,
					<cfif is_account_cash eq 1>
						1,
						11,
					<cfelse>
						0,
						11,
					</cfif>
					#SESSION.EP.USERID#,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#CGI.REMOTE_ADDR#">,
					#NOW()#,
					0,
					#evaluate('system_cash_amount#k#')#,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.ep.money#">
					<cfif len(session.ep.money2)>
						,#wrk_round(evaluate('system_cash_amount#k#')/attributes.currency_multiplier,4)#
						,<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.ep.money2#">
					</cfif>
				)
		</cfquery>
		<cfquery name="get_act_id" datasource="#dsn2#">
			SELECT MAX(ACTION_ID) AS ACT_ID	FROM CASH_ACTIONS WHERE	WRK_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#wrk_id_1#">
		</cfquery>
		<cfset act_id=get_act_id.act_id>
		<cfquery name="add_order_cash_pos" datasource="#dsn2#">
			INSERT INTO 
				#dsn3_alias#.ORDER_CASH_POS
				(
				ORDER_ID,
				CASH_ID,
				KASA_ID,
				KASA_PERIOD_ID
				)
			VALUES
				(
				#get_max_order.max_id#,
				#act_id#,
				#evaluate("kasa#k#")#,
				#session.ep.period_id#
				)
		</cfquery>
		<cfscript>
			if(is_cari_cash eq 1)
			{
				carici(
					action_id : ACT_ID,  
					action_table : 'CASH_ACTIONS',
					workcube_process_type : 31,
					account_card_type : 11,
					islem_tarihi : attributes.order_date,
					islem_tutari : evaluate("attributes.system_cash_amount#k#"),
					islem_belge_no : get_last_order.order_number,
					from_cmp_id : attributes.company_id,
					from_consumer_id : attributes.consumer_id,
					islem_detay : 'NAKİT TAHSİLAT',
					other_money_value : wrk_round(evaluate("attributes.system_cash_amount#k#")/cash_currency_multiplier),
					other_money : form.basket_money,
					action_currency : SESSION.EP.MONEY,
					to_cash_id : evaluate("kasa#k#"),
					to_branch_id :iif(len(cash_branch_id),de('#cash_branch_id#'),de('')),
					process_cat : 0,
					currency_multiplier : attributes.currency_multiplier
					);
			}
			if(is_account_cash eq 1)
			{
				str_card_detail = '#get_last_order.order_number# (PEŞİNAT)';
				muhasebeci(
					wrk_id='#wrk_id#',
					action_id : ACT_ID,
					workcube_process_type : 31,
					account_card_type : 11, 
					company_id : attributes.company_id,
					consumer_id : attributes.consumer_id,
					islem_tarihi : attributes.order_date,
					borc_hesaplar : get_cash_code.cash_acc_code,
					borc_tutarlar : wrk_round(evaluate("attributes.system_cash_amount#k#")),
					other_amount_borc : wrk_round(evaluate("attributes.cash_amount#k#")),
					other_currency_borc :  wrk_eval('currency_type#k#'),
					alacak_hesaplar : ACC,
					alacak_tutarlar : wrk_round(evaluate("attributes.system_cash_amount#k#")),
					other_amount_alacak : wrk_round(evaluate("attributes.system_cash_amount#k#")/cash_currency_multiplier),
					other_currency_alacak : form.basket_money,
					to_branch_id :iif(len(cash_branch_id),de('#cash_branch_id#'),de('')),
					fis_detay:'NAKİT TAHSİLAT İŞLEMİ',
					fis_satir_detay:str_card_detail,
					belge_no : get_last_order.order_number,
					is_account_group : is_account_group_cash,
					currency_multiplier : attributes.currency_multiplier 
					);
			}
		</cfscript>		
	 </cfif>
	</cfloop>
</cfif>

