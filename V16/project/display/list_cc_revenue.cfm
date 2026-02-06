<cfsetting showdebugoutput="no">
<!--- Proje İlişkili KrediKartı Tahsilatları--->	
<cfquery name="GET_BANK_ACTIONS" datasource="#dsn3#">
	SELECT
		CREDITCARD_PAYMENT_TYPE.CARD_NO,
		CREDIT_CARD_BANK_PAYMENTS.*
	FROM
		CREDIT_CARD_BANK_PAYMENTS,
		CREDITCARD_PAYMENT_TYPE
	WHERE
		CREDIT_CARD_BANK_PAYMENTS.PAYMENT_TYPE_ID = CREDITCARD_PAYMENT_TYPE.PAYMENT_TYPE_ID AND
		CREDIT_CARD_BANK_PAYMENTS.PROJECT_ID = #URL.ID#
	ORDER BY
		CREDIT_CARD_BANK_PAYMENTS.STORE_REPORT_DATE
</cfquery>
<cfif GET_BANK_ACTIONS.recordcount>
	<cfset company_id_list=''>
	<cfset consumer_id_list=''>
	<cfoutput query="GET_BANK_ACTIONS">
		<cfif len(ACTION_FROM_COMPANY_ID) and not listfind(company_id_list,ACTION_FROM_COMPANY_ID)>
			<cfset company_id_list=listappend(company_id_list,ACTION_FROM_COMPANY_ID)>
		</cfif>
		<cfif len(CONSUMER_ID) and not listfind(consumer_id_list,CONSUMER_ID)>
			<cfset consumer_id_list=listappend(consumer_id_list,CONSUMER_ID)>
		</cfif>
	</cfoutput>
	<cfif len(company_id_list)>
		<cfset company_id_list=listsort(company_id_list,"numeric","ASC",",")>
		<cfquery name="get_company_detail" datasource="#dsn#">
			SELECT FULLNAME FROM COMPANY WHERE COMPANY_ID IN (#company_id_list#) ORDER BY COMPANY_ID
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
            <th><cf_get_lang dictionary_id='57487.No'></th>
            <th><cf_get_lang dictionary_id='58516.Ödeme Yöntemi'></th>
            <th><cf_get_lang dictionary_id='57630.Tip'></th>
            <th><cf_get_lang dictionary_id='57742.Tarih'></th>
            <th><cf_get_lang dictionary_id='57658.Üye'></th>
            <th><cf_get_lang dictionary_id='57673.Tutar'></th>
            <th><cf_get_lang dictionary_id='58056.Dövizli Tutar'></th>
        </tr>
    </thead>
    <tbody>
		<cfif GET_BANK_ACTIONS.recordcount>
            <cfoutput query="GET_BANK_ACTIONS">
                <tr>
                    <td>#currentrow#</td>
                    <td>#CARD_NO#</td>
                    <td><a class="tableyazi" href="javascript://" onclick="windowopen('#request.self#?fuseaction=bank.list_creditcard_revenue&event=upd&id=#CREDITCARD_PAYMENT_ID#','medium');">#ACTION_TYPE#</a></td>
                    <td>#dateformat(STORE_REPORT_DATE,dateformat_style)#</td>
                    <td>
                        <cfif len(ACTION_FROM_COMPANY_ID)>
                            <a class="tableyazi" href="javascript://" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_com_det&company_id=#ACTION_FROM_COMPANY_ID#');">#get_company_detail.FULLNAME[listfind(company_id_list,ACTION_FROM_COMPANY_ID,',')]#</a>
                        <cfelseif len(CONSUMER_ID)>
                            <a class="tableyazi" href="javascript://" onclick="windowopen('#request.self#?fuseaction=objects.popup_con_det&con_id=#CONSUMER_ID#','medium');">#get_cons_detail.CONSUMER_NAME[listfind(consumer_id_list,CONSUMER_ID,',')]#	#get_cons_detail.CONSUMER_SURNAME[listfind(consumer_id_list,CONSUMER_ID,',')]#</a>
                        </cfif>
                    </td>
                    <td style="text-align:right;">#TLFormat(SALES_CREDIT)# #ACTION_CURRENCY_ID#</td>
                    <td style="text-align:right;">#TLFormat(OTHER_CASH_ACT_VALUE)# #OTHER_MONEY#</td>
                </tr>
            </cfoutput>
        <cfelse>
            <tr>
                <td colspan="10"><cf_get_lang dictionary_id='57484.Kayıtlı Bulunamadı'> !</td>
            </tr>
        </cfif>
    </tbody>
</cf_grid_list>

