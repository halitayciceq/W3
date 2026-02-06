<cfquery name="GET_COUNTER_RESULT" datasource="#DSN3#">
	SELECT
		SCT.*,
		E.EMPLOYEE_NAME,
		E.EMPLOYEE_SURNAME
	FROM
		SUBSCRIPTION_COUNTER_RESULT SCT,
		#DSN_ALIAS#.EMPLOYEES E
	WHERE
		SCT.SUBSCRIPTION_ID = #attributes.subscription_id# AND
		SCT.VALID_EMP = E.EMPLOYEE_ID
	ORDER BY
		SCT.COUNTER_RESULT_ID DESC
</cfquery>
<!--- <cfset result_id_list=listsort(ListDeleteDuplicates(valuelist(GET_COUNTER_RESULT.COUNTER_RESULT_ID)),'numeric','asc',',')>
<cfif listlen(result_id_list,',')>
	<cfquery name="GET_COUNTER_INVOICE" datasource="#DSN3#">
		SELECT
			INVOICE_NUMBER
		FROM
			SUBSCRIPTION_CONTRACT_INVOICE
		WHERE
			RESULT_ID IN (#result_id_list#)
		ORDER BY
			RESULT_ID
	</cfquery>
</cfif> --->
<cf_grid_list>
	<thead>
	  <tr>
		<th colspan="7"><cf_get_lang no ='494.Önceki Okumalar'></th>
	  </tr>
	  <tr>
		<th class="form-title" width="50"><cf_get_lang_main no ='468.Belge No'></th>
		<th class="form-title" width="65"><cf_get_lang_main no='330.Tarih'></th>
		<!--- <th class="form-title" width="115"><cfoutput>#session.ep.money#</cfoutput> Tutarı</th>
		<th class="form-title" width="115"><cfoutput>#session.ep.money2#</cfoutput> Tutarı</th> --->
		<th class="form-title" width="100"><cf_get_lang_main no ='1932.İşlem Durumu'></th>
		<th class="form-title"><cf_get_lang_main no='487.Kaydeden'></th>
		<th class="form-title" width="15"></th>
	  </tr>
    </thead>
    <tbody>
		<cfif get_counter_result.recordcount>
        <cfoutput query="get_counter_result" maxrows="10">
          <tr>
            <td>#counter_result_id#</td>
            <td>#dateformat(valid_date,dateformat_style)#</td>
            <!--- <td align="right">#tlformat(other_money_value,4)#</td>
            <td align="right">#tlformat(other_money_value_2,4)#</td> --->
            <td><!--- <cfif get_counter_result.is_invoice eq 1>Fatura No: #get_counter_invoice.invoice_number[listfind(result_id_list,counter_result_id,',')]#<cfelse>Faturalanmadı.</cfif> ---></td>
            <td>#employee_name# #employee_surname#</td>
            <!--- <td><a href="javascript://" onclick="windowopen('#request.self#?fuseaction=sales.popup_upd_subscription_read_counter&subscription_id=#subscription_id#&result_id=#counter_result_id#','horizantal','popup_upd_subscription_read_counter');"><img src="/images/update_list.gif" border="0" align="absmiddle"></a></td> --->
            <td><a href="javascript:openBoxDraggable('#request.self#?fuseaction=sales.popup_upd_subscription_read_counter&subscription_id=#subscription_id#&result_id=#counter_result_id#');"><i class="fa fa-pencil"></i></a></td>
          </tr>
        </cfoutput>
        <cfelse>
          <tr>
            <td colspan="7"><cf_get_lang_main no ='72.Sayaç Kaydı Yoktur'></td>
          </tr>
        </cfif>
	</tbody>
</cf_grid_list>
