<cfquery name="get_voucher_process_cat" datasource="#dsn2#" maxrows="1">
	SELECT IS_ACCOUNT,IS_CARI FROM #dsn3_alias#.SETUP_PROCESS_CAT WHERE PROCESS_TYPE = 97
</cfquery>
<cfif get_voucher_process_cat.recordcount>
	<cfset is_account_voucher = get_voucher_process_cat.is_account>
	<cfset is_cari_voucher = get_voucher_process_cat.is_cari>
<cfelse>
	<cfset is_account_voucher = 1>
	<cfset is_cari_voucher = 1>
</cfif>
<cfscript>
	for(ind_cari=1; ind_cari lte get_last_vouchers.recordcount; ind_cari=ind_cari+1)
	{
		if(get_last_vouchers.IS_PAY_TERM[ind_cari] == 0)
		{
			if(get_last_vouchers.CURRENCY_ID[ind_cari] is not session.ep.money)
			{
				other_money =get_last_vouchers.CURRENCY_ID[ind_cari];
				other_money_value =get_last_vouchers.VOUCHER_VALUE[ind_cari];
			}
			else if(len(get_last_vouchers.OTHER_MONEY_VALUE2[ind_cari]) and len(get_last_vouchers.OTHER_MONEY2[ind_cari]))
			{
				other_money =get_last_vouchers.OTHER_MONEY2[ind_cari];
				other_money_value =get_last_vouchers.OTHER_MONEY_VALUE2[ind_cari];
			}
			else
			{
				other_money =get_last_vouchers.OTHER_MONEY[ind_cari];
				other_money_value =get_last_vouchers.OTHER_MONEY_VALUE[ind_cari];
			}
			if(is_cari_voucher eq 1)
			{
				carici(
					action_id :get_last_vouchers.voucher_id[ind_cari],
					workcube_process_type :97,		
					process_cat : 0,
					account_card_type :13,
					action_table :'VOUCHER',
					islem_tarihi :attributes.order_date,
					islem_tutari :get_last_vouchers.other_money_value[ind_cari],
					other_money_value : get_last_vouchers.other_money_value[ind_cari],
					other_money :get_last_vouchers.other_money[ind_cari],
					islem_belge_no : get_last_vouchers.voucher_no[ind_cari],
					action_currency :session.ep.money,
					to_cash_id : account_cash_id,
					due_date :createodbcdatetime(get_last_vouchers.voucher_duedate[ind_cari]),
					from_cmp_id :attributes.company_id,
					from_consumer_id : attributes.consumer_id,
					currency_multiplier : attributes.currency_multiplier,
					islem_detay : 'SENET GİRİŞ BORDROSU(Senet Bazında)',
					payroll_id : P_ID,
					to_branch_id : account_cash_branch_id
					);
			}
		}
	}
	if(is_account_voucher eq 1)
	{
		GET_ACC_CODE=workcube_query(datasource:"#dsn2#", sqlstring:"SELECT A_VOUCHER_ACC_CODE FROM CASH WHERE CASH_ID=#account_cash_id#");
		for(i=1; i lte get_last_vouchers.recordcount; i=i+1)
		{
			if(get_last_vouchers.IS_PAY_TERM[i] == 0)
			{
				if(get_last_vouchers.CURRENCY_ID[i] neq session.ep.money)
					borc_tutar = get_last_vouchers.OTHER_MONEY_VALUE[i];
				else
					borc_tutar = get_last_vouchers.VOUCHER_VALUE[i];
				
				muhasebeci (
					action_id:P_ID,
					action_row_id : get_last_vouchers.VOUCHER_ID[i],
					due_date : createodbcdatetime(get_last_vouchers.VOUCHER_DUEDATE[i]),
					workcube_process_type:97,
					account_card_type:13,
					action_table :'VOUCHER_PAYROLL',
					islem_tarihi:attributes.order_date,
					company_id : attributes.company_id,
					consumer_id : attributes.consumer_id,
					borc_hesaplar: GET_ACC_CODE.A_VOUCHER_ACC_CODE,
					borc_tutarlar: borc_tutar,
					other_amount_borc : get_last_vouchers.OTHER_MONEY_VALUE[i],
					other_currency_borc :get_last_vouchers.OTHER_MONEY[i],
					alacak_hesaplar: acc,
					alacak_tutarlar: get_last_vouchers.VOUCHER_VALUE[i],
					other_amount_alacak : get_last_vouchers.VOUCHER_VALUE[i],
					other_currency_alacak : session.ep.money,
					fis_detay:'SENET GİRİŞİ',
					fis_satir_detay:'#dateformat(get_last_vouchers.voucher_duedate[ind_cari],dateformat_style)# VADELİ SENET GİRİŞ İŞLEMİ',
					currency_multiplier : attributes.currency_multiplier,
					is_account_group = 1,
					belge_no : attributes.payroll_no,
					to_branch_id : account_cash_branch_id
				);
			}
		}
	}
</cfscript>

