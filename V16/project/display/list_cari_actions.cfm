<!--- Proje İlişkili Cari Virman İşlemleri FB20071227 --->
<cfsetting showdebugoutput="no">
<cfquery name="get_cari_actions" datasource="#action_dsn2#">
	SELECT * FROM CARI_ACTIONS WHERE PROJECT_ID = #url.id#
</cfquery>
<cfif get_cari_actions.recordcount>
	<cfset company_id_list= "">
	<cfset consumer_id_list= "">
	<cfset employee_id_list= "">
	<cfoutput query="get_cari_actions">
		<cfif len(from_cmp_id) and not listfind(company_id_list,from_cmp_id)>
			<cfset company_id_list=listappend(company_id_list,from_cmp_id)>
		</cfif>
		<cfif len(to_cmp_id) and not listfind(company_id_list,to_cmp_id)>
			<cfset company_id_list=listappend(company_id_list,to_cmp_id)>
		</cfif>
		<cfif len(from_consumer_id) and not listfind(consumer_id_list,from_consumer_id)>
			<cfset consumer_id_list=listappend(consumer_id_list,from_consumer_id)>
		</cfif>
		<cfif len(to_consumer_id) and not listfind(consumer_id_list,to_consumer_id)>
			<cfset consumer_id_list=listappend(consumer_id_list,to_consumer_id)>
		</cfif>
		<cfif len(from_employee_id) and not listfind(employee_id_list,from_employee_id)>
			<cfset employee_id_list=listappend(employee_id_list,from_employee_id)>
		</cfif>
		<cfif len(to_employee_id) and not listfind(employee_id_list,to_employee_id)>
			<cfset employee_id_list=listappend(employee_id_list,to_employee_id)>
		</cfif>
	</cfoutput>
	<cfif len(company_id_list)>
		<cfset company_id_list=listsort(company_id_list,"numeric","ASC",",")>
		<cfquery name="get_company_detail" datasource="#dsn#">
			SELECT FULLNAME FROM COMPANY WHERE COMPANY_ID IN (#company_id_list#) ORDER BY COMPANY_ID
		</cfquery>
	</cfif>
	<cfif len(employee_id_list)>
		<cfset employee_id_list=listsort(employee_id_list,"numeric","ASC",",")>
		<cfquery name="get_employee_detail" datasource="#dsn#">
			SELECT EMPLOYEE_NAME,EMPLOYEE_SURNAME FROM EMPLOYEES WHERE EMPLOYEE_ID IN (#employee_id_list#) ORDER BY EMPLOYEE_ID
		</cfquery>
	</cfif>
	<cfif len(consumer_id_list)>
		<cfset consumer_id_list=listsort(consumer_id_list,"numeric","ASC",",")>
		<cfquery name="get_consumer_detail" datasource="#dsn#">
			SELECT CONSUMER_NAME,CONSUMER_SURNAME FROM CONSUMER WHERE CONSUMER_ID IN (#consumer_id_list#) ORDER BY CONSUMER_ID
		</cfquery>
	</cfif>
</cfif>
<cf_grid_list>
	<thead>
        <tr>
            <th width="25" align="center"><cf_get_lang dictionary_id='57487.No'></th>
            <th width="70" align="center"><cf_get_lang dictionary_id='57879.İşlem Tarihi'></th>
            <th><cf_get_lang dictionary_id='57800.İşlem Tipi'></th>
            <th><cf_get_lang dictionary_id='38366.Borçlu Hesap'></th>
            <th><cf_get_lang dictionary_id='34115.Alacaklı Hesap'></th>
            <th width="130" style="text-align:right;"><cf_get_lang dictionary_id='57673.Tutar'></th>
        </tr>
    </thead>
    <tbody>
		<cfif get_cari_actions.recordcount>
            <cfoutput query="get_cari_actions">
                <cfset type="">
                <cfswitch expression = "#get_cari_actions.action_type_id#">
                    <cfcase value=41><cfset type="#listgetat(attributes.fuseaction,1,'.')#.popup_form_upd_debit_claim_note"></cfcase>
                    <cfcase value=42><cfset type="#listgetat(attributes.fuseaction,1,'.')#.popup_form_upd_debit_claim_note"></cfcase>
                    <cfcase value=43><cfset type="ch.form_add_cari_to_cari&event=upd"></cfcase>
                    <cfcase value=131><cfset type="ch.popup_dsp_collacted_dekont"></cfcase>
                    <cfdefaultcase><cfset type="ch.form_add_cari_to_cari&event=upd"></cfdefaultcase>
                </cfswitch>
                <tr>
                    <td align="center">#get_cari_actions.currentrow#</td>
                    <td align="center">#dateformat(get_cari_actions.action_date,dateformat_style)#</td>
                    <td>
                        <cfif action_type_id eq 43><!--- Su an sadece cari virmanda proje kullanildigi icin 43 alindi FB --->
                            <a class="tableyazi" href="javascript://" onClick="javascript:windowopen('#request.self#?fuseaction=#type#&id=#action_id#','medium');">#action_name#</a>
                        </cfif>
                    </td>
                    <td><cfif len(to_cmp_id)>
                            #get_company_detail.fullname[listfind(company_id_list,to_cmp_id,',')]#
                        <cfelseif len(to_consumer_id)>
                            #get_consumer_detail.consumer_name[listfind(consumer_id_list,to_consumer_id,',')]# #get_consumer_detail.consumer_surname[listfind(consumer_id_list,to_consumer_id,',')]#
                        <cfelseif len(to_employee_id)>
                            #get_employee_detail.employee_name[listfind(employee_id_list,to_employee_id,',')]# #get_employee_detail.employee_surname[listfind(employee_id_list,to_employee_id,',')]#
                        </cfif>
                    </td>
                    <td><cfif len(from_cmp_id)>
                            #get_company_detail.fullname[listfind(company_id_list,from_cmp_id,',')]#
                        <cfelseif len(from_consumer_id)>
                            #get_consumer_detail.consumer_name[listfind(consumer_id_list,from_consumer_id,',')]# #get_consumer_detail.consumer_surname[listfind(consumer_id_list,from_consumer_id,',')]#
                        <cfelseif len(from_employee_id)>
                            #get_employee_detail.employee_name[listfind(employee_id_list,from_employee_id,',')]# #get_employee_detail.employee_surname[listfind(employee_id_list,from_employee_id,',')]#
                        </cfif>
                    </td>
                    <td style="text-align:right;">#TLFormat(get_cari_actions.action_value)# #get_cari_actions.action_currency_id#</td>
                </tr>
            </cfoutput>
        <cfelse>
            <tr>
                <td colspan="10"><cf_get_lang dictionary_id='57484.Kayıtlı Bulunamadı'>!</td>
            </tr>
        </cfif>
    </tbody>
</cf_grid_list>
