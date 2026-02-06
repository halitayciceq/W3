<cfquery name="get_cheque_process_cat" datasource="#dsn2#" maxrows="1">
	SELECT IS_ACCOUNT,IS_CARI FROM #dsn3_alias#.SETUP_PROCESS_CAT WHERE PROCESS_TYPE = 90
</cfquery>
<cfif get_cheque_process_cat.recordcount>
	<cfset is_account_cheque = get_cheque_process_cat.is_account>
	<cfset is_cari_cheque = get_cheque_process_cat.is_cari>
<cfelse>
	<cfset is_account_cheque = 1>
	<cfset is_cari_cheque = 1>
</cfif>
<cfscript>
	for(ind_cari=1; ind_cari lte get_last_cheques.recordcount; ind_cari=ind_cari+1)
	{		
		if(get_last_cheques.CURRENCY_ID[ind_cari] is not session.ep.money)
		{
			other_money =get_last_cheques.CURRENCY_ID[ind_cari];
			other_money_value =get_last_cheques.CHEQUE_VALUE[ind_cari];
		}
		else if(len(get_last_cheques.OTHER_MONEY_VALUE2[ind_cari]) and len(get_last_cheques.OTHER_MONEY2[ind_cari]))
		{
			other_money =get_last_cheques.OTHER_MONEY2[ind_cari];
			other_money_value =get_last_cheques.OTHER_MONEY_VALUE2[ind_cari];
		}
		else
		{
			other_money =get_last_cheques.OTHER_MONEY[ind_cari];
			other_money_value =get_last_cheques.OTHER_MONEY_VALUE[ind_cari];
		}
		if(is_cari_cheque eq 1)
		{
			carici(
				action_id :get_last_cheques.cheque_id[ind_cari],
				workcube_process_type :90,		
				process_cat : 0,
				account_card_type :13,
				action_table :'CHEQUE',
				islem_tarihi :attributes.order_date,
				islem_tutari :get_last_cheques.other_money_value[ind_cari],
				other_money_value : get_last_cheques.other_money_value[ind_cari],
				other_money :get_last_cheques.other_money[ind_cari],
				islem_belge_no : get_last_cheques.cheque_no[ind_cari],
				action_currency :session.ep.money,
				to_cash_id : account_cash_id,
				due_date :createodbcdatetime(get_last_cheques.cheque_duedate[ind_cari]),
				from_cmp_id :attributes.company_id,
				from_consumer_id : attributes.consumer_id,
				currency_multiplier : attributes.currency_multiplier,
				islem_detay : 'ÇEK GİRİŞ BORDROSU(Çek Bazında)',
				payroll_id : attributes.cheque_payroll_id,
				to_branch_id : account_cash_branch_id
				);
		}
	}
	if(is_account_cheque eq 1)
	{
		GET_ACC_CODE=workcube_query(datasource:"#dsn2#", sqlstring:"SELECT A_CHEQUE_ACC_CODE FROM CASH WHERE CASH_ID=#account_cash_id#");
		for(i=1; i lte get_last_cheques.recordcount; i=i+1)
		{
			if(get_last_cheques.CURRENCY_ID[i] neq session.ep.money)
				borc_tutar = get_last_cheques.OTHER_MONEY_VALUE[i];
			else
				borc_tutar = get_last_cheques.CHEQUE_VALUE[i];
			
			muhasebeci (
				action_id:attributes.cheque_payroll_id,
				action_row_id : get_last_cheques.CHEQUE_ID[i],
				due_date : createodbcdatetime(get_last_cheques.CHEQUE_DUEDATE[i]),
				workcube_process_type:90,
				workcube_old_process_type:90,
				account_card_type:13,
				action_table :'PAYROLL',
				islem_tarihi:attributes.order_date,
				company_id : attributes.company_id,
				consumer_id : attributes.consumer_id,
				borc_hesaplar: GET_ACC_CODE.A_CHEQUE_ACC_CODE,
				borc_tutarlar: borc_tutar,
				other_amount_borc : get_last_cheques.OTHER_MONEY_VALUE[i],
				other_currency_borc : get_last_cheques.OTHER_MONEY[i],
				alacak_hesaplar: acc,
				alacak_tutarlar: get_last_cheques.CHEQUE_VALUE[i],
				other_amount_alacak : get_last_cheques.CHEQUE_VALUE[i],
				other_currency_alacak : session.ep.money,
				fis_detay:'ÇEK GİRİŞİ',
				fis_satir_detay:'#dateformat(get_last_cheques.cheque_duedate[ind_cari],dateformat_style)# VADELİ ÇEK GİRİŞ İŞLEMİ',
				currency_multiplier : attributes.currency_multiplier,
				is_account_group = 1,
				belge_no : attributes.payroll_no_cheque,
				to_branch_id : account_cash_branch_id
			);
		}
	}
</cfscript>

