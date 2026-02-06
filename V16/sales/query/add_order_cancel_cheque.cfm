<cfif attributes.cheque_count gt 0>
	<cfquery name="get_cheque_process_cat" datasource="#dsn2#" maxrows="1">
		SELECT IS_ACCOUNT,IS_CARI FROM #dsn3_alias#.SETUP_PROCESS_CAT WHERE PROCESS_TYPE = 94
	</cfquery>
	<cfif get_cheque_process_cat.recordcount>
		<cfset is_account_cheque = get_cheque_process_cat.is_account>
		<cfset is_cari_cheque = get_cheque_process_cat.is_cari>
	</cfif>
	<cfscript>
		attributes.total_cheque_value = filterNum(attributes.total_cheque_value);
	</cfscript>
	<cfset belge_no2 = get_cheque_no(belge_tipi:'payroll')>	
	<cfset my_payroll_no2 = belge_no2>
	<cfset belge_no2 = get_cheque_no(belge_tipi:'payroll',belge_no2:belge_no2+1)>
	<cfquery name="ADD_REVENUE_TO_PAYROLL" datasource="#dsn2#">
		INSERT INTO
			PAYROLL
			(
				PROCESS_CAT,
				PAYROLL_TYPE,
				PAYROLL_TOTAL_VALUE,
				PAYROLL_OTHER_MONEY,
				PAYROLL_OTHER_MONEY_VALUE,
				NUMBER_OF_CHEQUE,
				COMPANY_ID,
				CONSUMER_ID,
				CURRENCY_ID,
				PAYROLL_REVENUE_DATE,
				PAYROLL_NO,
				RECORD_EMP,
				RECORD_IP,
				RECORD_DATE,
				CHEQUE_BASED_ACC_CARI,
				PAYMENT_ORDER_ID
			)
			VALUES
			(
				0,
				94,
				#attributes.total_cheque_value#,
				'#session.ep.money#',
				#attributes.total_cheque_value#,
				#attributes.record_num_4#,
				<cfif len(attributes.company_id)>#attributes.company_id#<cfelse>NULL</cfif>,
				<cfif len(attributes.consumer_id)>#attributes.consumer_id#<cfelse>NULL</cfif>,
				'#session.ep.money#',
				#attributes.cancel_date#,
				'#my_payroll_no2#',
				#session.ep.userid#,
				'#CGI.REMOTE_ADDR#',
				#NOW()#,
				1,
				#attributes.order_id#
			)
	</cfquery>
	<cfquery name="GET_BORDRO_ID" datasource="#dsn2#">
		SELECT MAX(ACTION_ID) AS P_ID FROM PAYROLL
	</cfquery>
	<cfquery name="get_moneys" datasource="#dsn2#">
		SELECT 
            MONEY_ID,
            MONEY, 
            RATE1,
            RATE2,
            MONEY_STATUS,
            PERIOD_ID, 
            COMPANY_ID, 
            ACCOUNT_950,
            PER_ACCOUNT,
            RATE3, 
            RATEPP2,
            RATEPP3, 
            RATEWW2, RATEWW3, 
            CURRENCY_CODE,
            DSP_RATE_SALE, 
            DSP_RATE_PUR,
            DSP_UPDATE_DATE, 
            EFFECTIVE_SALE, 
            EFFECTIVE_PUR,
            MONEY_NAME, 
            MONEY_SYMBOL 
        FROM 
        	SETUP_MONEY
	</cfquery>
	<cfset p_id=get_bordro_id.P_ID> 
	<cfoutput query="get_moneys">
		<cfquery name="add_money_obj_bskt" datasource="#dsn2#">
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
				'#get_moneys.money#',
				#get_moneys.rate2#,
				#get_moneys.rate1#,
			<cfif get_moneys.money is session.ep.money>
				1
			<cfelse>
				0
			</cfif>					
			)
		</cfquery>
	</cfoutput>	
	<cfquery name="get_cheques_all_" datasource="#dsn2#">
		SELECT 
        	CHEQUE_ID, 
            CHEQUE_PAYROLL_ID, 
            CHEQUE_CODE, 
            CHEQUE_DUEDATE, 
            CHEQUE_NO, 
            CHEQUE_VALUE,
            CURRENCY_ID, 
            DEBTOR_NAME, 
            CHEQUE_STATUS_ID, 
            BANK_NAME, 
            BANK_BRANCH_NAME, 
            ACCOUNT_NO, 
            CHEQUE_CITY, 
            TAX_NO, 
            TAX_PLACE, 
            CHEQUE_PURSE_NO, 
            ACCOUNT_ID, 
            COMPANY_ID, 
            RESULT_ID, 
            SELF_CHEQUE, 
            OTHER_MONEY_VALUE, 
            OTHER_MONEY, 
            OTHER_MONEY_VALUE2, 
            OTHER_MONEY2, 
            CONSUMER_ID, 
            EMPLOYEE_ID, 
            CASH_ID, 
            ENDORSEMENT_MEMBER, 
            OWNER_COMPANY_ID, 
            OWNER_CONSUMER_ID, 
            OWNER_EMPLOYEE_ID,
            CH_OTHER_MONEY_VALUE, 
            CH_OTHER_MONEY, 
            RECORD_DATE, 
            RECORD_IP, 
            RECORD_EMP, 
            UPDATE_DATE, 
            UPDATE_IP, 
            UPDATE_EMP, 
            OLD_STATUS 
        FROM 
    	    CHEQUE 
        WHERE 
	        CHEQUE_PAYROLL_ID = #attributes.cheque_payroll_id#				
	</cfquery>
	<cfoutput query="get_cheques_all_">
		<cfquery name="UPD_CHEQUE" datasource="#dsn2#">
			UPDATE CHEQUE SET CHEQUE_STATUS_ID=9 WHERE CHEQUE_ID= #get_cheques_all_.cheque_id#
		</cfquery>
		<cfquery name="ADD_CHEQUE_HISTORY" datasource="#dsn2#">
			INSERT INTO
				CHEQUE_HISTORY
				(
					CHEQUE_ID,
					PAYROLL_ID,
					STATUS,
					ACT_DATE,
					OTHER_MONEY_VALUE,
					OTHER_MONEY,
					OTHER_MONEY_VALUE2,
					OTHER_MONEY2,
					RECORD_DATE
				)
				VALUES
				(
					#get_cheques_all_.cheque_id#,
					#p_id#,
					9,
					#attributes.cancel_date#,
					#get_cheques_all_.OTHER_MONEY_VALUE#,
					'#get_cheques_all_.OTHER_MONEY#',
					#get_cheques_all_.OTHER_MONEY_VALUE2#,
					'#get_cheques_all_.OTHER_MONEY2#',
					#now()#
				)
		</cfquery>
	</cfoutput>
	<cfquery name="get_cash" datasource="#dsn2#">
		SELECT
			C.A_CHEQUE_ACC_CODE
		FROM
			PAYROLL AS P,
			CASH AS C
		WHERE
			P.PAYROLL_CASH_ID = C.CASH_ID AND
			P.ACTION_ID= #attributes.cheque_payroll_id#
	</cfquery>
	<cfscript>
		if(is_cari_cheque eq 1)
		{
			for(ind_cari=1; ind_cari lte get_cheques_all_.recordcount; ind_cari=ind_cari+1)
			{
				if(get_cheques_all_.currency_id[ind_cari] is not session.ep.money)
				{
					other_money =get_cheques_all_.currency_id[ind_cari];
					other_money_value =get_cheques_all_.cheque_value[ind_cari];
				}
				else
				{
					other_money = get_cheques_all_.other_money[ind_cari];
					other_money_value = get_cheques_all_.other_money_value[ind_cari];
				}
				carici(
					action_id :get_cheques_all_.cheque_id[ind_cari],
					workcube_process_type :94,		
					process_cat : 0,
					account_card_type :13,
					action_table :'CHEQUE',
					islem_tarihi :attributes.cancel_date,
					islem_tutari :get_cheques_all_.other_money_value[ind_cari],
					other_money_value : other_money_value,
					other_money : other_money,
					islem_belge_no : get_cheques_all_.cheque_no[ind_cari],
					action_currency : session.ep.money,
					to_cmp_id :attributes.company_id,
					to_consumer_id:attributes.consumer_id,
					due_date : createodbcdatetime(get_cheques_all_.cheque_duedate[ind_cari]),
					islem_detay : 'ÇEK İADE ÇIKIŞ BORDROSU(Çek Bazında)',
					payroll_id : p_id,
					to_branch_id : ListGetAt(session.ep.user_location,2,"-")
					);
				}
		}
		if(is_account_cheque eq 1)
		{
			muhasebeci (
				action_id:p_id,
				workcube_process_type:94,
				account_card_type:13,
				action_table :'PAYROLL',
				islem_tarihi:attributes.cancel_date,
				company_id : attributes.company_id,
				consumer_id : attributes.consumer_id,
				borc_hesaplar: acc,
				borc_tutarlar: attributes.total_cheque_value,
				other_amount_borc : attributes.total_cheque_value,
				other_currency_borc : session.ep.money,
				alacak_hesaplar: get_cash.a_cheque_acc_code,
				alacak_tutarlar: attributes.total_cheque_value,
				other_amount_alacak : attributes.total_cheque_value,
				other_currency_alacak : session.ep.money,
				fis_detay:'ÇEK İADE ÇIKIŞ İŞLEMİ',
				fis_satir_detay:'ÇEK İADE ÇIKIŞ İŞLEMİ',
				belge_no : my_payroll_no2,
				from_branch_id : ListGetAt(session.ep.user_location,2,"-")
				);
		}
	</cfscript>
</cfif>

