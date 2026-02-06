<cfsetting showdebugoutput="no">
<!--- Proje İlişkili senet İşlemleri--->	
<cfquery name="GET_V_PAYROLL" datasource="#action_dsn2#">
	SELECT * FROM VOUCHER_PAYROLL WHERE PROJECT_ID = #URL.ID#
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
<cfif GET_V_PAYROLL.recordcount>
	<cfset company_id_list=''>
	<cfset consumer_id_list=''>
	<cfset account_id_list=''>
	<cfset cash_id_list=''>
	<cfoutput query="GET_V_PAYROLL">
		<cfif len(COMPANY_ID) and not listfind(company_id_list,COMPANY_ID)>
			<cfset company_id_list=listappend(company_id_list,COMPANY_ID)>
		</cfif>
		<cfif len(CONSUMER_ID) and not listfind(consumer_id_list,CONSUMER_ID)>
			<cfset consumer_id_list=listappend(consumer_id_list,CONSUMER_ID)>
		</cfif>
		<cfif len(PAYROLL_CASH_ID) and not listfind(cash_id_list,PAYROLL_CASH_ID)>
			<cfset cash_id_list=listappend(cash_id_list,PAYROLL_CASH_ID)>
		</cfif>
		<cfif len(PAYROLL_ACCOUNT_ID) and not listfind(account_id_list,PAYROLL_ACCOUNT_ID)>
			<cfset account_id_list=listappend(account_id_list,PAYROLL_ACCOUNT_ID)>
		</cfif>
	</cfoutput>
	<cfif len(company_id_list)>
		<cfset company_id_list=listsort(company_id_list,"numeric","ASC",",")>
		<cfquery name="get_company" datasource="#dsn#">
			SELECT FULLNAME	FROM COMPANY WHERE COMPANY_ID IN (#company_id_list#) ORDER BY COMPANY_ID
		</cfquery>
	</cfif>
	<cfif len(consumer_id_list)>
		<cfset consumer_id_list=listsort(consumer_id_list,"numeric","ASC",",")>
		<cfquery name="get_consumer" datasource="#dsn#">
			SELECT CONSUMER_NAME,CONSUMER_SURNAME FROM CONSUMER WHERE CONSUMER_ID IN (#consumer_id_list#) ORDER BY CONSUMER_ID
		</cfquery>
	</cfif>
	<cfif len(cash_id_list)>
		<cfset cash_id_list=listsort(cash_id_list,"numeric","ASC",",")>
		<cfquery name="get_cash" datasource="#dsn2#">
			SELECT CASH_NAME FROM CASH WHERE CASH_ID IN (#cash_id_list#) ORDER BY CASH_ID
		</cfquery>
	</cfif>
	<cfif len(account_id_list)>
		<cfset account_id_list=listsort(account_id_list,"numeric","ASC",",")>
		<cfquery name="get_account" datasource="#dsn3#">
			SELECT ACCOUNT_NAME FROM ACCOUNTS WHERE ACCOUNT_ID IN (#account_id_list#) ORDER BY ACCOUNT_ID
		</cfquery>
	</cfif>
</cfif>
<cf_grid_list>
	<thead>
        <tr>
            <th width="30"><cf_get_lang dictionary_id ='57487.No'></th>
            <th width="30"><cf_get_lang dictionary_id ='38368.Bordro No'></th>
            <th><cf_get_lang dictionary_id ='57800.İşlem Tipi'></th>
            <th width="63"><cf_get_lang dictionary_id ='57879.İşlem Tarihi'></th>
            <th><cf_get_lang dictionary_id='57519.Cari Hesap'></th>
            <th><cf_get_lang dictionary_id='57520.Kasa'></th>
            <th><cf_get_lang dictionary_id='57652.Hesap'></th>
            <th width="63"><cf_get_lang dictionary_id ='57861.Ort Vade'></th>
            <th style="text-align:right;"><cf_get_lang dictionary_id='57673.Tutar'></th>
            <!-- sil --><th width="20"><a href="javascript://"><i class="fa fa-print"></i></a></th><!-- sil -->
        </tr> 
    </thead>
    <tbody>
		<cfif GET_V_PAYROLL.recordcount>
            <cfoutput query="GET_V_PAYROLL">
                <tr>
                    <td>#GET_V_PAYROLL.currentrow#&nbsp;</td>
                    <td>#GET_V_PAYROLL.PAYROLL_NO#</td>
                    <td>
                    <cfset type=GET_V_PAYROLL.PAYROLL_TYPE>
                        <cfswitch expression="#type#">
                            <cfcase value="97">
                                <cfset act="Senet Giriş Bordrosu">
                                <cfset Xurl="form_add_voucher_payroll_entry&event=upd">
                            </cfcase>
                            <cfcase value="98">
                                <cfset act="Senet Çıkış Bordrosu">
                                <cfset Xurl="form_upd_payroll_voucher_endorsement">
                            </cfcase>
                            <cfcase value="99">
                                <cfset act="Senet Çıkış Bordrosu-Banka">
                                <cfset Xurl="form_upd_voucher_payroll_bank_tah">
                            </cfcase>
                            <cfcase value="100">
                                <cfset act="Senet Çıkış Bordrosu-Banka Teminat">
                                <cfset Xurl="form_upd_voucher_payroll_bank_tem">
                            </cfcase>
                            <cfcase value="107">
                                <cfset act="">
                                <cfset Xurl="">
                            </cfcase>
                            <cfcase value="104">
                                <cfset act="Senet Çıkış Bordrosu-Tahsil">
                                <cfset Xurl="form_upd_payroll_voucher_revenue">
                            </cfcase>
                            <cfcase value="101">
                                <cfset act="Senet İade Çikis Bordrosu">
                                <cfset Xurl="upd_voucher_payroll_endor_return">
                            </cfcase>
                            <cfcase value="108">
                                <cfset act="Senet İade Giriş Bordrosu">
                                <cfset Xurl="upd_voucher_payroll_entry_return">
                            </cfcase>
                            <cfcase value="109">
                                <cfset act="Senet İade Giriş Bordrosu-Banka">
                                <cfset Xurl="form_upd_voucher_bank_guaranty_return">
                            </cfcase>
                        </cfswitch>
                        <a href="#request.self#?fuseaction=cheque.#Xurl#&ID=#GET_V_PAYROLL.ACTION_ID#" class="tableyazi">#act#</a>
                    </td>
                    <td>#dateformat(GET_V_PAYROLL.PAYROLL_REVENUE_DATE,dateformat_style)#&nbsp;</td>
                    <td>
                    <cfif len(GET_V_PAYROLL.COMPANY_ID)>
                        #get_company.FULLNAME[listfind(company_id_list,COMPANY_ID,',')]#
                    <cfelseif len(GET_V_PAYROLL.CONSUMER_ID)>
                        #get_consumer.CONSUMER_NAME[listfind(consumer_id_list,CONSUMER_ID,',')]# #get_consumer.CONSUMER_SURNAME[listfind(consumer_id_list,CONSUMER_ID,',')]#
                    </cfif></td>
                    <td><cfif len(PAYROLL_CASH_ID)>#get_cash.CASH_NAME[listfind(cash_id_list,PAYROLL_CASH_ID,',')]#</cfif></td>
                    <td><cfif len(PAYROLL_ACCOUNT_ID)>#get_account.ACCOUNT_NAME[listfind(account_id_list,PAYROLL_ACCOUNT_ID,',')]#</cfif></td>
                    <td>#dateformat(GET_V_PAYROLL.PAYROLL_AVG_DUEDATE,dateformat_style)#</td>
                    <td style="text-align:right;">#TLFormat(GET_V_PAYROLL.PAYROLL_TOTAL_VALUE)# #GET_V_PAYROLL.CURRENCY_ID# </td>
                    <!-- sil -->
                    <td>
                        <cfset my_flag=0>
                        <cfswitch expression="#type#">
                            <cfcase value="91">
                                <cfset my_flag=1>
                                <cfset str_len="#request.self#?fuseaction=objects.popup_print_files&action_id=#action_id#&print_type=112">
                            </cfcase>	
                            <cfcase value="92">
                                <cfset my_flag=1>
                                <cfset str_len="#request.self#?fuseaction=objects.popup_print_files&action_id=#action_id#&print_type=112">
                            </cfcase>			
                            <cfcase value="93">
                                <cfset my_flag=1>
                                <cfset str_len="#request.self#?fuseaction=objects.popup_print_files&action_id=#action_id#&print_type=112">
                            </cfcase>	
                            <cfcase value="94">
                                <cfset my_flag=1>
                                <cfset str_len="#request.self#?fuseaction=objects.popup_print_files&action_id=#action_id#&print_type=112">
                            </cfcase>	
                            <cfcase value="95">
                                <cfset my_flag=1>
                                <cfset str_len="#request.self#?fuseaction=objects.popup_print_files&action_id=#action_id#&print_type=111">
                            </cfcase>	
                            <cfdefaultcase><!--- 90 --->
                                <cfset my_flag=1>
                                <cfset str_len="#request.self#?fuseaction=objects.popup_print_files&action_id=#action_id#&print_type=111">
                            </cfdefaultcase>
                        </cfswitch>
                        <cfif my_flag eq 1>
                            <a href="javascript://" onclick="windowopen('#str_len#','print_page');"><i class="fa fa-print"title="<cf_get_lang dictionary_id='57474.Print'>"></i></a>				
                        </cfif>
                    </td>
                </tr>
            </cfoutput>
        <cfelse>
            <tr>
                <td colspan="10"><cf_get_lang dictionary_id='57484.Kayıtlı Bulunamadı'> !</td>
            </tr>
        </cfif>
     </tbody>
</cf_grid_list>
