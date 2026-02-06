<cfif attributes.voucher_count gt 0>
	<cfquery name="get_voucher_process_cat" datasource="#dsn2#" maxrows="1">
		SELECT IS_ACCOUNT,IS_CARI FROM #dsn3_alias#.SETUP_PROCESS_CAT WHERE PROCESS_TYPE = 101
	</cfquery>
	<cfif get_voucher_process_cat.recordcount>
		<cfset is_account_voucher = get_voucher_process_cat.is_account>
		<cfset is_cari_voucher = get_voucher_process_cat.is_cari>
	</cfif>
	<cfscript>
		attributes.total_voucher_value = filterNum(attributes.total_voucher_value);
	</cfscript>
	<cfset belge_no = get_cheque_no(belge_tipi:'voucher_payroll')>	
	<cfset my_payroll_no = belge_no>
	<cfset belge_no = get_cheque_no(belge_tipi:'voucher_payroll',belge_no:belge_no+1)>
	<cfquery name="ADD_REVENUE_TO_PAYROLL" datasource="#dsn2#">
		INSERT INTO
			VOUCHER_PAYROLL
			(
				PROCESS_CAT,
				PAYROLL_TYPE,
				PAYROLL_TOTAL_VALUE,
				PAYROLL_OTHER_MONEY,
				PAYROLL_OTHER_MONEY_VALUE,
				NUMBER_OF_VOUCHER,
				COMPANY_ID,
				CONSUMER_ID,
				CURRENCY_ID,
				PAYROLL_REVENUE_DATE,
				PAYROLL_NO,
				RECORD_EMP,
				RECORD_IP,
				RECORD_DATE,
				VOUCHER_BASED_ACC_CARI,
				PAYMENT_ORDER_ID
			)
			VALUES
			(
				0,
				101,
				#attributes.total_voucher_value#,
				'#session.ep.money#',
				#attributes.total_voucher_value#,
				#attributes.record_num_3#,
				<cfif len(attributes.company_id)>#attributes.company_id#<cfelse>NULL</cfif>,
				<cfif len(attributes.consumer_id)>#attributes.consumer_id#<cfelse>NULL</cfif>,
				'#session.ep.money#',
				#attributes.cancel_date#,
				'#my_payroll_no#',
				#session.ep.userid#,
				'#CGI.REMOTE_ADDR#',
				#NOW()#,
				1,
				#attributes.order_id#
			)
	</cfquery>
	<cfquery name="GET_BORDRO_ID" datasource="#dsn2#">
		SELECT MAX(ACTION_ID) AS P_ID FROM VOUCHER_PAYROLL
	</cfquery>
	<cfquery name="get_moneys" datasource="#dsn2#">
		SELECT 
	        MONEY_ID, 
            MONEY, 
            RATE1, 
            RATE2, 
            COMPANY_ID, 
            RATE3 
        FROM 
        	SETUP_MONEY
	</cfquery>
	<cfset p_id=get_bordro_id.P_ID> 
	<cfoutput query="get_moneys">
		<cfquery name="add_money_obj_bskt" datasource="#dsn2#">
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
	<cfquery name="get_vouchers_all_" datasource="#dsn2#">
		SELECT 
        	VOUCHER_ID, 
            VOUCHER_PAYROLL_ID, 
            VOUCHER_CODE, 
            VOUCHER_DUEDATE, 
            VOUCHER_NO, 
            VOUCHER_VALUE, 
            CURRENCY_ID, 
            VOUCHER_STATUS_ID,
            OTHER_MONEY, 
            OTHER_MONEY_VALUE, 
            COMPANY_ID, 
            OTHER_MONEY2, 
            OTHER_MONEY_VALUE2, 
            CONSUMER_ID, 
            CASH_ID, 
            RECORD_DATE, 
            RECORD_EMP, 
            RECORD_IP 
        FROM 
    	    VOUCHER 
        WHERE 
	        VOUCHER_PAYROLL_ID = #attributes.payroll_id#				
	</cfquery>
	<cfoutput query="get_vouchers_all_">
		<cfquery name="UPD_VOUCHERS" datasource="#dsn2#">
			UPDATE VOUCHER SET VOUCHER_STATUS_ID=9 WHERE VOUCHER_ID= #get_vouchers_all_.voucher_id#
		</cfquery>
		<cfquery name="ADD_VOUCHER_HISTORY" datasource="#dsn2#">
			INSERT INTO
				VOUCHER_HISTORY
				(
					VOUCHER_ID,
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
					#get_vouchers_all_.voucher_id#,
					#p_id#,
					9,
					#attributes.cancel_date#,
					#get_vouchers_all_.OTHER_MONEY_VALUE#,
					'#get_vouchers_all_.OTHER_MONEY#',
					#get_vouchers_all_.OTHER_MONEY_VALUE2#,
					'#get_vouchers_all_.OTHER_MONEY2#',
					#now()#
				)
		</cfquery>
		<cfquery name="del_quarantor" datasource="#dsn2#">
			DELETE FROM VOUCHER_GUARANTORS WHERE VOUCHER_ID = #get_vouchers_all_.voucher_id#
		</cfquery>
	</cfoutput>
	<cfquery name="get_cash" datasource="#dsn2#">
		SELECT
			C.A_VOUCHER_ACC_CODE
		FROM
			VOUCHER_PAYROLL AS P,
			CASH AS C
		WHERE
			P.PAYROLL_CASH_ID = C.CASH_ID AND
			P.ACTION_ID= #attributes.payroll_id#
	</cfquery>
	<cfscript>
		if(is_cari_voucher eq 1)
		{
			for(ind_cari=1; ind_cari lte get_vouchers_all_.recordcount; ind_cari=ind_cari+1)
			{
				if(get_vouchers_all_.currency_id[ind_cari] is not session.ep.money)
				{
					other_money =get_vouchers_all_.currency_id[ind_cari];
					other_money_value =get_vouchers_all_.voucher_value[ind_cari];
				}
				else
				{
					other_money = get_vouchers_all_.other_money[ind_cari];
					other_money_value = get_vouchers_all_.other_money_value[ind_cari];
				}
				carici(
					action_id :get_vouchers_all_.voucher_id[ind_cari],
					workcube_process_type :101,		
					process_cat : 0,
					account_card_type :13,
					action_table :'VOUCHER',
					islem_tarihi :attributes.cancel_date,
					islem_tutari :get_vouchers_all_.other_money_value[ind_cari],
					other_money_value : other_money_value,
					other_money : other_money,
					islem_belge_no : get_vouchers_all_.voucher_no[ind_cari],
					action_currency : session.ep.money,
					to_cmp_id :attributes.company_id,
					to_consumer_id:attributes.consumer_id,
					payroll_id : p_id,
					due_date : createodbcdatetime(get_vouchers_all_.voucher_duedate[ind_cari]),
					islem_detay : 'SENET İADE ÇIKIŞ BORDROSU(Senet Bazında)',
					to_branch_id : ListGetAt(session.ep.user_location,2,"-")
					);
				}
		}
		if(is_account_voucher eq 1)
		{
			muhasebeci (
				action_id:p_id,
				workcube_process_type:101,
				account_card_type:13,
				action_table :'VOUCHER_PAYROLL',
				islem_tarihi:attributes.cancel_date,
				company_id : attributes.company_id,
				consumer_id : attributes.consumer_id,
				borc_hesaplar: acc,
				borc_tutarlar: attributes.total_voucher_value,
				other_amount_borc : attributes.total_voucher_value,
				other_currency_borc : session.ep.money,
				alacak_hesaplar: get_cash.a_voucher_acc_code,
				alacak_tutarlar: attributes.total_voucher_value,
				other_amount_alacak : attributes.total_voucher_value,
				other_currency_alacak : session.ep.money,
				fis_detay:'SENET İADE ÇIKIŞ İŞLEMİ',
				fis_satir_detay:'SENET İADE ÇIKIŞ İŞLEMİ',
				belge_no : my_payroll_no,
				from_branch_id : ListGetAt(session.ep.user_location,2,"-")
				);
		}
	</cfscript>
</cfif>
