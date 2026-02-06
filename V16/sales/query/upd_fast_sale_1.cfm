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
<cfif isdefined("form.cash") and (form.cash eq 1)>
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
		  	<cfif isdefined("cash_action_id_#k#") and len(evaluate("cash_action_id_#k#"))>
				<cfquery name="upd_cash_action" datasource="#dsn2#">
					UPDATE 
						CASH_ACTIONS
					SET					
						CASH_ACTION_TO_CASH_ID=#evaluate("kasa#k#")#,
						ACTION_TYPE_ID=31,
						ORDER_ID=#attributes.order_id#,
						<cfif isDefined("attributes.company_id") and len(attributes.company_id)>
							CASH_ACTION_FROM_COMPANY_ID=#attributes.company_id#,
						<cfelse>
							CASH_ACTION_FROM_CONSUMER_ID=#attributes.consumer_id#,
						</cfif>
						CASH_ACTION_VALUE=#evaluate('cash_amount#k#')#,
						CASH_ACTION_CURRENCY_ID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#wrk_eval('currency_type#k#')#">,
						ACTION_DATE=#attributes.order_date#,
						IS_PROCESSED=#is_account_cash#,
						PAPER_NO=<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.order_number#">,
						IS_ACCOUNT = <cfif is_account_cash>1,<cfelse>0,</cfif>
						IS_ACCOUNT_TYPE = 11,
						PROCESS_CAT=0,
						UPDATE_EMP=#session.ep.userid#,
						UPDATE_IP=<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.remote_addr#">,
						UPDATE_DATE=#now()#,
						ACTION_VALUE = #evaluate('system_cash_amount#k#')#,
						ACTION_CURRENCY_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.ep.money#">
						<cfif len(session.ep.money2)>
							,ACTION_VALUE_2 = #wrk_round(evaluate('system_cash_amount#k#')/attributes.currency_multiplier,4)#
							,ACTION_CURRENCY_ID_2 = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.ep.money2#">
						</cfif>
					WHERE
						ACTION_ID=#evaluate("cash_action_id_#k#")#
				</cfquery>
				<cfquery name="upd_order_cash_pos" datasource="#dsn2#">
					UPDATE 
						#dsn3_alias#.ORDER_CASH_POS
					SET
						KASA_ID=#evaluate("kasa#k#")#
					WHERE
						ORDER_ID=#attributes.order_id#
						AND CASH_ID=#evaluate("cash_action_id_#k#")#
						AND KASA_PERIOD_ID = #session.ep.period_id#
				</cfquery>
				<cfset act_id=evaluate("cash_action_id_#k#")>
			<cfelse>
				<cfquery name="add_cash_action" datasource="#dsn2#">
					INSERT INTO CASH_ACTIONS
						(
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
						#evaluate("kasa#k#")#,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="NAKİT TAHSİLAT">,
						31,
						#attributes.order_id#,
						<cfif isDefined("attributes.company_id") and len(attributes.company_id)>
							#attributes.company_id#,
						<cfelse>
							#attributes.consumer_id#,
						</cfif>
						#evaluate('cash_amount#k#')#,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#wrk_eval('currency_type#k#')#">,
						#attributes.order_date#,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.order_number# (PEŞİNAT)">,
						<cfif is_account_cash>1<cfelse>0</cfif>,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.order_number#">,
						<cfif is_account_cash eq 1>
							1,
							11,
						<cfelse>
							0,
							11,
						</cfif>
						#session.ep.userid#,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.remote_addr#">,
						#now()#,
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
						KASA_PERIOD_ID
						)
					VALUES
						(
						#attributes.order_id#,
						#act_id#,
						#evaluate("kasa#k#")#,
						#session.ep.period_id#
						)
				</cfquery>
			</cfif>
			<cfscript>
				if(is_cari_cash eq 1)
				{
					carici(
						action_id : act_id,  
						action_table : 'CASH_ACTIONS',
						workcube_process_type : 31,
						workcube_old_process_type : 31,
						account_card_type : 11,
						islem_tarihi : attributes.order_date,
						islem_tutari : evaluate("attributes.system_cash_amount#k#"),
						islem_belge_no : attributes.order_number,
						from_cmp_id : attributes.company_id,
						from_consumer_id : attributes.consumer_id,
						islem_detay : 'NAKİT TAHSİLAT',
						other_money_value : wrk_round(evaluate("attributes.system_cash_amount#k#")/cash_currency_multiplier),
						other_money : form.basket_money,
						action_currency : session.ep.money,
						to_cash_id : evaluate("kasa#k#"),
						to_branch_id :iif(len(cash_branch_id),de('#cash_branch_id#'),de('')),
						process_cat : 0,
						currency_multiplier : attributes.currency_multiplier 
						);
				}
				else
					cari_sil(action_id:act_id, process_type:31);
					
				if(is_account_cash eq 1)
				{
					str_card_detail = '#attributes.order_number# (PEŞİNAT)';
					muhasebeci(
						action_id : act_id,
						workcube_process_type : 31,
						workcube_old_process_type : 31,
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
						belge_no : attributes.order_number,
						is_account_group : is_account_group_cash,
						currency_multiplier : attributes.currency_multiplier  
						);
					}
				else
					muhasebe_sil(action_id:act_id, process_type:31);
			</cfscript>		
		<cfelse>
			<cfif isdefined("cash_action_id_#k#") and  len(evaluate('cash_action_id_#k#'))>
				<cfscript>
					cari_sil(action_id:evaluate('cash_action_id_#k#'), process_type:31);
					muhasebe_sil(action_id:evaluate('cash_action_id_#k#'), process_type:31);
				</cfscript>
				<cfquery name="del_cash_actions" datasource="#dsn2#">
					DELETE FROM CASH_ACTIONS WHERE ACTION_ID = #evaluate('cash_action_id_#k#')# AND ACTION_TYPE_ID=31
				</cfquery>
				<cfquery name="del_cash_pos" datasource="#dsn2#">
					DELETE FROM #dsn3_alias#.ORDER_CASH_POS WHERE ORDER_ID=#attributes.order_id# AND CASH_ID = #evaluate('cash_action_id_#k#')# AND KASA_PERIOD_ID = #session.ep.period_id#
				</cfquery>
			</cfif>
		</cfif>
	</cfloop>
<cfelse>
	<cfquery name="control_order_cash" datasource="#dsn2#">
		SELECT CASH_ID,KASA_ID,ORDER_CASH_ID FROM #dsn3_alias#.ORDER_CASH_POS WHERE ORDER_ID=#attributes.order_id# AND CASH_ID IS NOT NULL
	</cfquery>
	<cfif control_order_cash.recordcount>
		<cfscript>
			for(i=1; i lte control_order_cash.recordcount; i=i+1)
				{
					cari_sil(action_id:control_order_cash.cash_id[#i#], process_type:31);
					muhasebe_sil(action_id:control_order_cash.cash_id[#i#], process_type:31);
				}
		</cfscript>
		<cfquery name="del_cash_actions" datasource="#dsn2#">
			DELETE FROM CASH_ACTIONS WHERE ACTION_ID IN (#valuelist(control_order_cash.cash_id)#)
		</cfquery>
		<cfquery name="del_cash_pos" datasource="#dsn2#">
			DELETE FROM #dsn3_alias#.ORDER_CASH_POS WHERE ORDER_ID=#attributes.order_id# AND CASH_ID IN (#valuelist(control_order_cash.cash_id)#)
		</cfquery>
	</cfif>	
</cfif>

