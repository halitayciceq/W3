<cfsetting showdebugoutput="no">
<!--- Proje İlişkili Banka İşlemleri--->	
<cfquery name="GET_BANK_ACTIONS" datasource="#action_dsn2#">
	SELECT * FROM BANK_ACTIONS WHERE PROJECT_ID = #URL.ID#
</cfquery>
<cfquery name="GET_ACCOUNTS" datasource="#dsn3#">
	SELECT
		ACCOUNT_ID,
		<cfif session.ep.period_year lt 2009>
			CASE WHEN(ACCOUNTS.ACCOUNT_CURRENCY_ID = 'TL') THEN 'YTL' ELSE ACCOUNTS.ACCOUNT_CURRENCY_ID END AS  ACCOUNT_CURRENCY_ID,
		<cfelse>
			ACCOUNTS.ACCOUNT_CURRENCY_ID,
		</cfif>
		ACCOUNT_NAME
	FROM
		ACCOUNTS
	<cfif session.ep.isBranchAuthorization>
	WHERE
		ACCOUNT_ID IN(SELECT AB.ACCOUNT_ID FROM ACCOUNTS_BRANCH AB WHERE AB.BRANCH_ID = #ListGetAt(session.ep.user_location,2,"-")#)
	</cfif>
	ORDER BY
		ACCOUNT_NAME
</cfquery>
<cfif GET_BANK_ACTIONS.recordcount>
	<cfset company_id_list=''>
	<cfset account_id_list=''>
	<cfset cash_id_list=''>
	<cfset employee_id_list=''>
	<cfset consumer_id_list=''>
	<cfoutput query="GET_BANK_ACTIONS">
		<cfif len(ACTION_FROM_COMPANY_ID) and not listfind(company_id_list,ACTION_FROM_COMPANY_ID)>
			<cfset company_id_list=listappend(company_id_list,ACTION_FROM_COMPANY_ID)>
		</cfif>
		<cfif len(ACTION_TO_COMPANY_ID) and not listfind(company_id_list,ACTION_TO_COMPANY_ID)>
			<cfset company_id_list=listappend(company_id_list,ACTION_TO_COMPANY_ID)>
		</cfif>
		<cfif len(ACTION_FROM_ACCOUNT_ID) and not listfind(account_id_list,ACTION_FROM_ACCOUNT_ID)>
			<cfset account_id_list=listappend(account_id_list,ACTION_FROM_ACCOUNT_ID)>
		</cfif>
		<cfif len(ACTION_TO_ACCOUNT_ID) and not listfind(account_id_list,ACTION_TO_ACCOUNT_ID)>
			<cfset account_id_list=listappend(account_id_list,ACTION_TO_ACCOUNT_ID)>
		</cfif>
		<cfif len(ACTION_FROM_CASH_ID) and not listfind(cash_id_list,ACTION_FROM_CASH_ID)>
			<cfset cash_id_list=listappend(cash_id_list,ACTION_FROM_CASH_ID)>
		</cfif>
		<cfif len(ACTION_TO_CASH_ID) and not listfind(cash_id_list,ACTION_TO_CASH_ID)>
			<cfset cash_id_list=listappend(cash_id_list,ACTION_TO_CASH_ID)>
		</cfif>
		<cfif len(ACTION_TO_EMPLOYEE_ID) and not listfind(employee_id_list,ACTION_TO_EMPLOYEE_ID)>
			<cfset employee_id_list=listappend(employee_id_list,ACTION_TO_EMPLOYEE_ID)>
		</cfif>
		<cfif len(ACTION_TO_CONSUMER_ID) and not listfind(consumer_id_list,ACTION_TO_CONSUMER_ID)>
			<cfset consumer_id_list=listappend(consumer_id_list,ACTION_TO_CONSUMER_ID)>
		</cfif>
		<cfif len(ACTION_FROM_CONSUMER_ID) and not listfind(consumer_id_list,ACTION_FROM_CONSUMER_ID)>
			<cfset consumer_id_list=listappend(consumer_id_list,ACTION_FROM_CONSUMER_ID)>
		</cfif>
	</cfoutput>
	<cfif len(company_id_list)>
		<cfset company_id_list=listsort(company_id_list,"numeric","ASC",",")>
		<cfquery name="get_company_detail" datasource="#dsn#">
			SELECT FULLNAME FROM COMPANY WHERE COMPANY_ID IN (#company_id_list#) ORDER BY COMPANY_ID
		</cfquery>
	</cfif>
	<cfif len(account_id_list)>
		<cfset account_id_list=listsort(account_id_list,"numeric","ASC",",")>
		<cfquery name="get_account_detail" dbtype="query">
			SELECT ACCOUNT_NAME FROM get_accounts WHERE ACCOUNT_ID IN (#account_id_list#) ORDER BY ACCOUNT_ID
		</cfquery>
	</cfif>
	<cfif len(cash_id_list)>
		<cfset cash_id_list=listsort(cash_id_list,"numeric","ASC",",")>
		<cfquery name="get_cash_detail" datasource="#dsn2#">
			SELECT CASH_ID,CASH_NAME FROM CASH WHERE CASH_ID IN (#cash_id_list#) ORDER BY CASH_ID
		</cfquery>
	</cfif>
	<cfif len(employee_id_list)>
		<cfset employee_id_list=listsort(employee_id_list,"numeric","ASC",",")>
		<cfquery name="get_emp_detail" datasource="#dsn#">
			SELECT EMPLOYEE_NAME,EMPLOYEE_SURNAME FROM EMPLOYEES WHERE EMPLOYEE_ID IN (#employee_id_list#) ORDER BY EMPLOYEE_ID
		</cfquery>
	</cfif>
	<cfif len(consumer_id_list)>
		<cfset consumer_id_list=listsort(consumer_id_list,"numeric","ASC",",")>
		<cfquery name="get_cons_detail" datasource="#dsn#">
			SELECT CONSUMER_NAME,CONSUMER_SURNAME FROM CONSUMER WHERE CONSUMER_ID IN (#consumer_id_list#) ORDER BY CONSUMER_ID
		</cfquery>
	</cfif>
</cfif>
<cf_grid_list>
	<thead>
        <tr>
            <th width="35"><cf_get_lang dictionary_id='57487.No'></th>
            <th width="65"><cf_get_lang dictionary_id='57880.Belge No'></th>
            <th width="65"><cf_get_lang dictionary_id ='57742.Tarih'></th>
            <th><cf_get_lang dictionary_id ='38360.İşlem Adı'></th>
            <th><cf_get_lang dictionary_id ='38361.Hesaptan'></th>
            <th><cf_get_lang dictionary_id ='38362.Hesaba'></th>
            <th nowrap><cf_get_lang dictionary_id ='30060.Masraf Tutarı'></th>
            <th><cf_get_lang dictionary_id ='57673.Tutar'></th>
        </tr>
    </thead>
    <tbody>
		<cfif GET_BANK_ACTIONS.recordcount>
            <cfoutput query="GET_BANK_ACTIONS">
                <cfset type="">
                <cfswitch expression = "#GET_BANK_ACTIONS.ACTION_TYPE_ID#">
                    <cfcase value=20><cfset type="bank.form_add_bank_account_open&event=upd"></cfcase>
                    <cfcase value=21><cfset type="bank.form_add_invest_money&event=upd"></cfcase>
                    <cfcase value=22><cfset type="bank.form_add_get_money&event=upd"></cfcase>
                    <cfcase value=23><cfset type="bank.form_add_virman&event=upd"></cfcase>
                    <cfcase value=24><cfset type="bank.form_add_gelenh&event=upd"></cfcase>
                    <cfcase value=25><cfset type="bank.form_add_gidenh&event=upd"></cfcase>
                    <cfcase value="29"><cfset type="bank.popup_upd_bank_gider_pusula"></cfcase>
                    <cfcase value="241"><cfset type="bank.list_creditcard_revenue&event=upd"></cfcase>
                    <cfcase value="1040,1043,1044,1045"><cfset type="ch.popup_check_preview"></cfcase>
                    <cfcase value="1052,1053,1054"><cfset type="ch.popup_voucher_preview"></cfcase><!--- senet gelecek --->
                    <cfcase value="243"><cfset type="bank.popup_upd_bank_cc_payment"></cfcase><!---banka hesaba geçiş --->
                    <cfcase value="244"><cfset type="bank.list_credit_card_expense&event=updDebit"></cfcase><!---banka kredikartı borcu ödeme--->
                    <cfcase value="291,292"><cfset type="finance.list_credit_payment_types&event=upd"></cfcase><!--- Kredi Odeme, Kredi Tahsilat --->
                    <cfcase value="293,294"><cfset type="credit.add_stockbond_purchase&event=upd"></cfcase><!--- Menkul Kıymet Alımı, Menkul Kıymet Satışı --->
                </cfswitch>
                <tr>
                    <td>#GET_BANK_ACTIONS.currentrow#&nbsp;</td>
                    <td>#GET_BANK_ACTIONS.paper_no#</td>
                    <td>#dateformat(GET_BANK_ACTIONS.ACTION_DATE,dateformat_style)#</td>
                    <td>
                        <cfif action_type_id eq 120>
                            <a class="tableyazi" href="#request.self#?fuseaction=cost.form_add_expense_cost&event=upd&expense_id=#expense_id#">#GET_BANK_ACTIONS.ACTION_TYPE#</a>
                        <cfelseif action_type_id eq 121>
                            <a class="tableyazi" href="#request.self#?fuseaction=cost.upd_income_cost&expense_id=#expense_id#">#GET_BANK_ACTIONS.ACTION_TYPE#</a>
                        <cfelseif len(GET_BANK_ACTIONS.multi_action_id)><!--- toplu gelen havale --->
                            <a href="#request.self#?fuseaction=bank.upd_collacted_gelenh&multi_id=#GET_BANK_ACTIONS.MULTI_ACTION_ID#" class="tableyazi">#GET_BANK_ACTIONS.ACTION_TYPE#</a>
                        <cfelseif listfind("291,292",GET_BANK_ACTIONS.action_type_id)><!--- Kredi Odemesi ,Kredi Tahsilat --->
                            <a class="tableyazi" href="javascript://" onclick="windowopen('#request.self#?fuseaction=credit.popup_dsp_credit_payment&action_id=#GET_BANK_ACTIONS.action_id#&period_id=#session.ep.period_id#&our_company_id=#session.ep.company_id#','page');">#GET_BANK_ACTIONS.ACTION_TYPE#</a>
                        <cfelseif listfind("293,294",GET_BANK_ACTIONS.action_type_id)><!--- Menkul Kıymet Alış, Menkul Kıymet Satış --->
                            <a class="tableyazi" href="javascript://" onclick="windowopen('#request.self#?fuseaction=credit.popup_dsp_stockbond_purchase&action_id=#GET_BANK_ACTIONS.action_id#','page');">#GET_BANK_ACTIONS.ACTION_TYPE#</a>
                        <cfelseif listfind("23,26,27",action_type_id,",")><!--- doviz alıs-satıs islemleri --->
                            <cfif GET_BANK_ACTIONS.with_next_row eq 0>
                                <cfquery name="first_action_id" datasource="#dsn2#" maxrows="1">
                                    SELECT ACTION_ID FROM BANK_ACTIONS WHERE ACTION_ID < #GET_BANK_ACTIONS.ACTION_ID# ORDER BY ACTION_ID DESC
                                </cfquery>
                            </cfif>		
                            <a class="tableyazi" href="javascript://" onclick="windowopen('#request.self#?fuseaction=#type#&ID=<cfif GET_BANK_ACTIONS.with_next_row eq 1>#GET_BANK_ACTIONS.ACTION_ID#<cfelse>#first_action_id.ACTION_ID#</cfif>','medium');">#GET_BANK_ACTIONS.ACTION_TYPE#</a>
                        <cfelseif not len(type)><!--- display sayfası olmayan tipler için --->
                            #GET_BANK_ACTIONS.ACTION_TYPE#
                        <cfelse>
                            <a class="tableyazi" href="javascript://" onclick="windowopen('#request.self#?fuseaction=#type#&ID=#GET_BANK_ACTIONS.ACTION_ID#',<cfif action_type_id eq 243 or action_type_id eq 244>'small'<cfelse>'medium'</cfif>);">#GET_BANK_ACTIONS.ACTION_TYPE#</a>
                        </cfif>
                    </td>
                    <td>
                    <cfif len(ACTION_FROM_ACCOUNT_ID)>#get_account_detail.ACCOUNT_NAME[listfind(account_id_list,ACTION_FROM_ACCOUNT_ID,',')]#</cfif>
                    <cfif len(ACTION_FROM_COMPANY_ID)>#get_company_detail.FULLNAME[listfind(company_id_list,ACTION_FROM_COMPANY_ID,',')]# (<cf_get_lang dictionary_id='58061.cari'>)</cfif>
                    <cfif len(ACTION_FROM_CASH_ID)>#get_cash_detail.CASH_NAME[listfind(cash_id_list,ACTION_FROM_CASH_ID,',')]#</cfif>
                    <cfif len(ACTION_FROM_CONSUMER_ID)>#get_cons_detail.CONSUMER_NAME[listfind(consumer_id_list,ACTION_FROM_CONSUMER_ID,',')]#	#get_cons_detail.CONSUMER_SURNAME[listfind(consumer_id_list,ACTION_FROM_CONSUMER_ID,',')]#</cfif>
                    </td>
                    <td>
                    <cfif len(ACTION_TO_ACCOUNT_ID)>#get_account_detail.ACCOUNT_NAME[listfind(account_id_list,ACTION_TO_ACCOUNT_ID,',')]#</cfif>
                    <cfif len(ACTION_TO_COMPANY_ID)>#get_company_detail.FULLNAME[listfind(company_id_list,ACTION_TO_COMPANY_ID,',')]# (<cf_get_lang dictionary_id='58061.cari'>)</cfif>
                    <cfif len(ACTION_TO_CASH_ID)>#get_cash_detail.CASH_NAME[listfind(cash_id_list,ACTION_TO_CASH_ID,',')]#</cfif>
                    <cfif len(ACTION_TO_EMPLOYEE_ID)>#get_emp_detail.EMPLOYEE_NAME[listfind(employee_id_list,ACTION_TO_EMPLOYEE_ID,',')]#	#get_emp_detail.EMPLOYEE_SURNAME[listfind(employee_id_list,ACTION_TO_EMPLOYEE_ID,',')]#</cfif>
                    <cfif len(ACTION_TO_CONSUMER_ID)>#get_cons_detail.CONSUMER_NAME[listfind(consumer_id_list,ACTION_TO_CONSUMER_ID,',')]#	#get_cons_detail.CONSUMER_SURNAME[listfind(consumer_id_list,ACTION_TO_CONSUMER_ID,',')]#</cfif>
                    </td>
                    <td style="text-align:right;"><cfif MASRAF gt 0>#TLFormat(MASRAF)#&nbsp;#ACTION_CURRENCY_ID#</cfif></td>
                    <td style="text-align:right;"><cfif action_type_id eq 243>#TLFormat(ACTION_VALUE)#&nbsp;#ACTION_CURRENCY_ID#<cfelse>#TLFormat(ACTION_VALUE - MASRAF)#&nbsp;#ACTION_CURRENCY_ID#</cfif></td>
                </tr>
            </cfoutput>
        <cfelse>
            <tr>
                <td colspan="10"><cf_get_lang dictionary_id='57484.Kayıtlı Bulunamadı'> !</td>
            </tr>
        </cfif>
     </tbody>
</cf_grid_list>

