<cfsetting showdebugoutput="no">
<!--- Proje İlişkili Kasa İşlemleri--->	
<cfquery name="GET_CASH_ACTIONS" datasource="#action_dsn2#">
	SELECT * FROM CASH_ACTIONS WHERE PROJECT_ID = #URL.ID#
</cfquery>
<cfquery name="GET_CASHS" datasource="#dsn2#">
	SELECT 
		CASH_ID,
		CASH_NAME 
	FROM 
		CASH 
		<cfif session.ep.isBranchAuthorization>
			WHERE
				BRANCH_ID = #ListGetAt(session.ep.user_location,2,"-")#
		</cfif>
	ORDER BY 
		CASH_NAME
</cfquery>
<cfif GET_CASH_ACTIONS.recordcount>
	<cfset company_id_list= ''>
	<cfset employee_id_list= ''>
	<cfset account_id_list= ''>
	<cfset cash_id_list= ''>
	<cfset expense_id_list= ''>
	<cfset consumer_id_list= ''>
	<cfoutput query="GET_CASH_ACTIONS">
		<cfif len(CASH_ACTION_FROM_COMPANY_ID) and not listfind(company_id_list,CASH_ACTION_FROM_COMPANY_ID)>
			<cfset company_id_list=listappend(company_id_list,CASH_ACTION_FROM_COMPANY_ID)>
		</cfif>
		<cfif len(CASH_ACTION_TO_COMPANY_ID) and not listfind(company_id_list,CASH_ACTION_TO_COMPANY_ID)>
			<cfset company_id_list=listappend(company_id_list,CASH_ACTION_TO_COMPANY_ID)>
		</cfif>
		<cfif len(CASH_ACTION_TO_CONSUMER_ID) and not listfind(consumer_id_list,CASH_ACTION_TO_CONSUMER_ID)>
			<cfset consumer_id_list=listappend(consumer_id_list,CASH_ACTION_TO_CONSUMER_ID)>
		</cfif>
		<cfif len(CASH_ACTION_FROM_CONSUMER_ID) and not listfind(consumer_id_list,CASH_ACTION_FROM_CONSUMER_ID)>
			<cfset consumer_id_list=listappend(consumer_id_list,CASH_ACTION_FROM_CONSUMER_ID)>
		</cfif>
		<cfif len(CASH_ACTION_FROM_EMPLOYEE_ID) and not listfind(employee_id_list,CASH_ACTION_FROM_EMPLOYEE_ID)>
			<cfset employee_id_list=listappend(employee_id_list,CASH_ACTION_FROM_EMPLOYEE_ID)>
		</cfif>
		<cfif len(CASH_ACTION_TO_EMPLOYEE_ID) and not listfind(employee_id_list,CASH_ACTION_TO_EMPLOYEE_ID)>
			<cfset employee_id_list=listappend(employee_id_list,CASH_ACTION_TO_EMPLOYEE_ID)>
		</cfif>
		<cfif len(CASH_ACTION_FROM_ACCOUNT_ID) and not listfind(account_id_list,CASH_ACTION_FROM_ACCOUNT_ID)>
			<cfset account_id_list=listappend(account_id_list,CASH_ACTION_FROM_ACCOUNT_ID)>
		</cfif>
		<cfif len(CASH_ACTION_TO_ACCOUNT_ID) and not listfind(account_id_list,CASH_ACTION_TO_ACCOUNT_ID)>
			<cfset account_id_list=listappend(account_id_list,CASH_ACTION_TO_ACCOUNT_ID)>
		</cfif>
		<cfif len(CASH_ACTION_FROM_CASH_ID) and not listfind(cash_id_list,CASH_ACTION_FROM_CASH_ID)>
			<cfset cash_id_list=listappend(cash_id_list,CASH_ACTION_FROM_CASH_ID)>
		</cfif>
		<cfif len(CASH_ACTION_TO_CASH_ID) and not listfind(cash_id_list,CASH_ACTION_TO_CASH_ID)>
			<cfset cash_id_list=listappend(cash_id_list,CASH_ACTION_TO_CASH_ID)>
		</cfif>
		<cfif len(EXPENSE_ITEM_ID) and not listfind(expense_id_list,EXPENSE_ITEM_ID)>
			<cfset expense_id_list=listappend(expense_id_list,EXPENSE_ITEM_ID)>
		</cfif>
	</cfoutput>
	<cfif len(employee_id_list)>
		<cfset employee_id_list=listsort(employee_id_list,"numeric","ASC",",")>
		<cfquery name="get_employee_detail" datasource="#dsn#">
			SELECT EMPLOYEE_NAME,EMPLOYEE_SURNAME FROM EMPLOYEES WHERE EMPLOYEE_ID IN (#employee_id_list#) ORDER BY EMPLOYEE_ID
		</cfquery>
	</cfif>
	<cfif len(company_id_list)>
		<cfset company_id_list=listsort(company_id_list,"numeric","ASC",",")>
		<cfquery name="get_company_detail" datasource="#dsn#">
			SELECT FULLNAME FROM COMPANY WHERE COMPANY_ID IN (#company_id_list#) ORDER BY COMPANY_ID
		</cfquery>
	</cfif>
	<cfif len(consumer_id_list)>
		<cfset consumer_id_list=listsort(consumer_id_list,"numeric","ASC",",")>
		<cfquery name="get_consumer_detail" datasource="#dsn#">
			SELECT CONSUMER_NAME,CONSUMER_SURNAME FROM CONSUMER WHERE CONSUMER_ID IN (#consumer_id_list#) ORDER BY CONSUMER_ID
		</cfquery>
	</cfif>
	<cfif len(account_id_list)>
		<cfset account_id_list=listsort(account_id_list,"numeric","ASC",",")>
		<cfquery name="get_account_detail" datasource="#dsn3#">
			SELECT ACCOUNT_NAME FROM ACCOUNTS WHERE ACCOUNT_ID IN (#account_id_list#) ORDER BY ACCOUNT_ID
		</cfquery>
	</cfif>
	<cfif len(cash_id_list)>
		<cfset cash_id_list=listsort(cash_id_list,"numeric","ASC",",")>
		<cfquery name="get_cash_detail" datasource="#dsn2#">
			SELECT CASH_NAME FROM CASH WHERE CASH_ID IN (#cash_id_list#) ORDER BY CASH_ID
		</cfquery>
	</cfif>
	<cfif len(expense_id_list)>
		<cfset expense_id_list=listsort(expense_id_list,"numeric","ASC",",")>
		<cfquery name="get_expense_name" datasource="#dsn2#">
			SELECT EXPENSE_ITEM_NAME FROM EXPENSE_ITEMS WHERE EXPENSE_ITEM_ID IN (#expense_id_list#) ORDER BY EXPENSE_ITEM_ID
		</cfquery>
	</cfif>
</cfif>
<cf_grid_list>
	<thead>
        <tr>
            <th width="25"><cf_get_lang dictionary_id='57487.No'></th>
            <th width="65"><cf_get_lang dictionary_id='57880.Belge No'></th>
            <th width="60"><cf_get_lang dictionary_id='57742.Tarih'></th>
            <th><cf_get_lang dictionary_id='57800.İşlem Tipi'></th>
            <th width="100"><cf_get_lang dictionary_id='57520.Kasa'></th>
            <th width="120"><cf_get_lang dictionary_id='57519.cari Hesap'></th>
            <th width="125" style="text-align:right;"><cf_get_lang dictionary_id='57673.Tutar'></th>
        </tr>
    </thead>
    <tbody>
		<cfif GET_CASH_ACTIONS.recordcount>
            <cfoutput query="GET_CASH_ACTIONS">
                <cfswitch expression = "#get_cash_actions.action_type_id#">
                    <cfcase value=21><cfset type="cash.popup_dsp_invest_money"></cfcase>
                    <cfcase value=22><cfset type="cash.popup_dsp_get_money"></cfcase>
                    <cfcase value=30><cfset type="cash.form_add_cash_open&event=upd"></cfcase>
                    <cfcase value=31><cfset type="cash.form_add_cash_revenue&event=upd"></cfcase>
                    <cfcase value=32><cfset type="cash.form_add_cash_payment&event=upd"></cfcase>
                    <cfcase value=33><cfset type="cash.form_add_cash_to_cash&event=upd"></cfcase>
                    <cfcase value="37"><cfset type="cash.popup_upd_gider_pusula"></cfcase>
                    <cfcase value="38"><cfset type="cash.popup_upd_purchase_doviz"></cfcase>
                    <cfcase value="39"><cfset type="cash.popup_upd_sale_doviz"></cfcase>
                    <cfcase value="1040"><cfset type="cash.popup_dsp_payroll_bank_revenue"></cfcase>
                    <cfcase value="1050"><cfset type="cash.popup_dsp_voucher_payroll_bank_revenue"></cfcase>
                    <cfdefaultcase><cfset type="cash.list_cash_actions"></cfdefaultcase>
                </cfswitch>
                <cfswitch expression="#get_cash_actions.action_type_id#">
                    <cfcase value="21,22">
                        <cfset table_name="CASH_ACTIONS">
                        <cfset VAL_ID = GET_CASH_ACTIONS.BANK_ACTION_ID>
                    </cfcase>
                    <cfcase value="92">
                        <cfset table_name="PAYROLL">
                        <cfset VAL_ID = GET_CASH_ACTIONS.PAYROLL_ID>
                    </cfcase>
                    <cfcase value="104">
                        <cfset table_name="VOUCHER_PAYROLL">
                        <cfset VAL_ID = GET_CASH_ACTIONS.PAYROLL_ID>
                    </cfcase>
                    <cfdefaultcase>
                        <cfset table_name="CASH_ACTIONS">
                        <cfset VAL_ID = GET_CASH_ACTIONS.ACTION_ID>
                    </cfdefaultcase>
                </cfswitch>
                <tr>
                    <td>#get_cash_actions.currentrow#</td>
                    <td>#get_cash_actions.PAPER_NO#</td>
                    <td>#dateformat(get_cash_actions.ACTION_DATE,dateformat_style)#</td>
                    <td>
                    <cfif with_next_row eq 0>
                        <cfquery name="temp" datasource="#dsn2#" maxrows="1">
                            SELECT ACTION_ID FROM CASH_ACTIONS WHERE ACTION_ID < #VAL_ID# ORDER BY ACTION_ID DESC
                        </cfquery>
                        <cfset VAL_ID = temp.ACTION_ID>
                    </cfif>
                    <cfif listfind('34,35',action_type_id) and process_cat eq 0><!--- fatura detaydan yapılan kapama işlemleri bu ekrandan degil, yine aynı faturadan guncellenmelidir --->
                    <cfsavecontent variable="message"><cf_get_lang dictionary_id ='38364.Bu İşlemi İlgili Olduğu'></cfsavecontent>
                    <cfsavecontent variable="message2"><cf_get_lang dictionary_id ='38365.Nolu Faturadan Güncelleyebilirsiniz'></cfsavecontent>
                        <a class="tableyazi" href="javascript://" onClick="alert('#message# #paper_no# #message2#');">#ACTION_TYPE#</a>
                    <cfelseif action_type_id eq 120>
                        <a class="tableyazi" href="#request.self#?fuseaction=cost.form_add_expense_cost&event=upd&expense_id=#expense_id#">#action_type#</a>
                    <cfelse>
                        <cfif not (type is 'cash.list_cash_actions')>
                            <a class="tableyazi" href="javascript://" onClick="javascript:windowopen('#request.self#?fuseaction=#type#<cfif type is 'cash.popup_upd_cash_open'>&CID=#CASH_ACTION_TO_CASH_ID#</cfif>&ID=#VAL_ID#','<cfif table_name is 'PAYROLL'>list<cfelseif (type is 'cash.popup_upd_cash_payment') or (type is 'cash.form_add_cash_revenue&event=upd') or (type is 'cash.popup_dsp_payroll_bank_revenue') or (type is 'cash.popup_upd_cash_to_cash') or (type is 'cash.popup_upd_purchase_doviz') or (type is 'cash.popup_upd_sale_doviz') or (type is 'cash.popup_dsp_voucher_payroll_bank_revenue')>medium<cfelse>small</cfif>');">
                        </cfif>
                        #ACTION_TYPE#
                        <cfif not (type is 'cash.list_cash_actions')>
                            </a> 
                        </cfif>
                    </cfif>
                    </td>
                    <td>
                    <cfif len(CASH_ACTION_FROM_CASH_ID)>#get_cash_detail.CASH_NAME[listfind(cash_id_list,CASH_ACTION_FROM_CASH_ID,',')]#</cfif>
                    <cfif len(CASH_ACTION_FROM_CASH_ID) and len(CASH_ACTION_TO_CASH_ID)>-</cfif>
                    <cfif len(CASH_ACTION_TO_CASH_ID)>#get_cash_detail.CASH_NAME[listfind(cash_id_list,CASH_ACTION_TO_CASH_ID,',')]#</cfif>
                    </td>
                    <td>
                    <cfif len(CASH_ACTION_FROM_COMPANY_ID)>
                        #get_company_detail.FULLNAME[listfind(company_id_list,CASH_ACTION_FROM_COMPANY_ID,',')]#
                    <cfelseif len(CASH_ACTION_TO_COMPANY_ID)>
                        #get_company_detail.FULLNAME[listfind(company_id_list,CASH_ACTION_TO_COMPANY_ID,',')]#
                    </cfif>
                    <cfif len(CASH_ACTION_FROM_EMPLOYEE_ID)>
                        #get_employee_detail.EMPLOYEE_NAME[listfind(employee_id_list,CASH_ACTION_FROM_EMPLOYEE_ID,',')]#&nbsp;
                        #get_employee_detail.EMPLOYEE_SURNAME[listfind(employee_id_list,CASH_ACTION_FROM_EMPLOYEE_ID,',')]#
                    <cfelseif len(CASH_ACTION_TO_EMPLOYEE_ID)>
                        #get_employee_detail.EMPLOYEE_NAME[listfind(employee_id_list,CASH_ACTION_TO_EMPLOYEE_ID,',')]#&nbsp;
                        #get_employee_detail.EMPLOYEE_SURNAME[listfind(employee_id_list,CASH_ACTION_TO_EMPLOYEE_ID,',')]#
                    </cfif>
                    <cfif len(CASH_ACTION_TO_CONSUMER_ID)>
                        #get_consumer_detail.CONSUMER_NAME[listfind(consumer_id_list,CASH_ACTION_TO_CONSUMER_ID,',')]#
                        #get_consumer_detail.CONSUMER_SURNAME[listfind(consumer_id_list,CASH_ACTION_TO_CONSUMER_ID,',')]#
                    <cfelseif len(CASH_ACTION_FROM_CONSUMER_ID)>
                        #get_consumer_detail.CONSUMER_NAME[listfind(consumer_id_list,CASH_ACTION_FROM_CONSUMER_ID,',')]#
                        #get_consumer_detail.CONSUMER_SURNAME[listfind(consumer_id_list,CASH_ACTION_FROM_CONSUMER_ID,',')]#
                    </cfif>
                    <cfif len(CASH_ACTION_FROM_ACCOUNT_ID)>
                        #get_account_detail.ACCOUNT_NAME[listfind(account_id_list,CASH_ACTION_FROM_ACCOUNT_ID,',')]#
                    <cfelseif len(CASH_ACTION_TO_ACCOUNT_ID)>
                        #get_account_detail.ACCOUNT_NAME[listfind(account_id_list,CASH_ACTION_TO_ACCOUNT_ID,',')]#
                    </cfif>
                    <cfif len(EXPENSE_ITEM_ID)>
                        #get_expense_name.EXPENSE_ITEM_NAME[listfind(expense_id_list,EXPENSE_ITEM_ID,',')]#
                    </cfif>
                    </td>
                    <td style="text-align:right;">#TLFormat(get_cash_actions.CASH_ACTION_VALUE)#&nbsp;#get_cash_actions.CASH_ACTION_CURRENCY_ID#</td>
                    <cfif isdefined("attributes.cash") and len(attributes.cash) and attributes.oby eq 2>
                        <cfif len(get_cash_actions.CASH_ACTION_FROM_CASH_ID) and (get_cash_actions.CASH_ACTION_FROM_CASH_ID eq attributes.cash)>
                            <cfset toplam_bakiye = toplam_bakiye -get_cash_actions.CASH_ACTION_VALUE> 
                        <cfelseif len(get_cash_actions.CASH_ACTION_TO_CASH_ID) and (get_cash_actions.CASH_ACTION_TO_CASH_ID eq attributes.cash)>
                            <cfset toplam_bakiye = toplam_bakiye +get_cash_actions.CASH_ACTION_VALUE> 
                        </cfif>
                        <td style="text-align:right;">#TLFormat(toplam_bakiye)#<cfif toplam_bakiye gt 0>(B)<cfelse>(A)</cfif></td>
                    </cfif>
                </tr>
            </cfoutput>
        <cfelse>
            <tr>
                <td colspan="10"><cf_get_lang dictionary_id='57484.Kayıtlı Bulunamadı'> !</td>
            </tr>
        </cfif>
    </tbody>
</cf_grid_list>

