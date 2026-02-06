<cfsetting showdebugoutput="no">
<cfquery name="get_assign_orders" datasource="#dsn2#">
	SELECT 
		BON.*,
		A.ACCOUNT_NAME,
		A.ACCOUNT_NO
	FROM 
		BANK_ORDERS BON,
		#dsn3_alias#.ACCOUNTS AS A
	WHERE 		
		A.ACCOUNT_ID = BON.ACCOUNT_ID
		AND	BON.PROJECT_ID = #attributes.id#
</cfquery>
<cf_grid_list>
	<thead>
        <tr>
            <th width="35"><cf_get_lang dictionary_id='57487.No'></th>
            <th width="65"><cf_get_lang dictionary_id='57880.Belge No'></th>
            <th width="65"><cf_get_lang dictionary_id ='57742.Tarih'></th>
            <th width="100"><cf_get_lang dictionary_id ='38360.İşlem Adı'></th>
            <th width="100"><cf_get_lang dictionary_id ='38361.Hesaptan'></th>
            <th><cf_get_lang dictionary_id ='38362.Hesaba'></th> 
            <th style="text-align:right;"><cf_get_lang dictionary_id ='57673.Tutar'></th>
            <th width="20"></th>
        </tr>
    </thead>
    <tbody>
		<cfif get_assign_orders.recordcount>
            <cfset company_id_list=''>
            <cfset consumer_id_list=''>
            <cfoutput query="get_assign_orders">
                <cfif len(company_id) and not listfind(company_id_list,company_id)>
                    <cfset company_id_list=listappend(company_id_list,company_id)>
                </cfif>
                <cfif len(consumer_id) and not listfind(consumer_id_list,consumer_id)>
                    <cfset consumer_id_list=listappend(consumer_id_list,consumer_id)>
                </cfif>
            </cfoutput>
            <cfif len(company_id_list)>
                <cfset company_id_list = listsort(listdeleteduplicates(company_id_list),"numeric","ASC",",")>
                <cfquery name="get_company" datasource="#DSN#">
                    SELECT COMPANY_ID, NICKNAME, FULLNAME FROM COMPANY WHERE COMPANY_ID IN (#company_id_list#) ORDER BY COMPANY_ID
                </cfquery>
            </cfif>
            <cfif len(consumer_id_list)>
                <cfset consumer_id_list = listsort (listdeleteduplicates(consumer_id_list),"numeric","ASC",",")>
                <cfquery name="get_consumer" datasource="#DSN#">
                    SELECT CONSUMER_ID,CONSUMER_NAME,CONSUMER_SURNAME FROM CONSUMER WHERE CONSUMER_ID IN (#consumer_id_list#) ORDER BY CONSUMER_ID
                </cfquery>
            </cfif>
            <cfoutput query="get_assign_orders">
                <tr>
                    <td>#currentrow#</td>
                    <td>#seri_no#</td>
                    <td>#DATEFORMAT(PAYMENT_DATE,dateformat_style)#</td>
                    <td width="65">
                        <cfif bank_order_type eq 260>
                            <a href="javascript://" onClick="windowopen('#request.self#?fuseaction=bank.popup_upd_assign_order&bank_order_id=#bank_order_id#','list');" class="tableyazi"><cf_get_lang dictionary_id='58167.Giden Banka Talimatı'></a>
                        <cfelseif bank_order_type eq 251>
                            <a href="javascript://" onClick="windowopen('#request.self#?fuseaction=bank.list_assign_order&event=upd_incoming&bank_order_id=#bank_order_id#','list');" class="tableyazi"><cf_get_lang dictionary_id='58165.Gelen Banka Talimatı'></a>
                        </cfif>
                    </td>
                    <td>
                    <cfif len(company_id)>
                        #get_company.fullname[listfind(company_id_list,company_id,',')]#
                    <cfelseif len(consumer_id)>
                        #get_consumer.consumer_name[listfind(consumer_id_list,consumer_id,',')]# #get_consumer.consumer_surname[listfind(consumer_id_list,consumer_id,',')]#
                    </cfif>
                    </td>
                    <td>#account_name#</td> 
                    <td style="text-align:right;">#TLFormat(action_value)# #action_money#</td>
                    <td align="center">
                    <cfif get_module_user(19) and  not listfindnocase(denied_pages,'bank.popup_incoming_bank_order')>
                        <cfif IS_PAID neq 1 and bank_order_type eq 260>
                            <a href="javascript://" onClick="windowopen('#request.self#?fuseaction=bank.popup_form_add_gidenh&bank_order_id=#bank_order_id#&from_assign_order=1<cfif len(project_id)>&project_id=#project_id#</cfif><cfif len(company_id)>&is_company=1</cfif>','medium');"><i class="fa fa-plus" title="<cf_get_lang dictionary_id='48759.Giden Havale Ekle'>"></i></a>
                        <cfelseif IS_PAID neq 1 and bank_order_type eq 251>
                            <a href="javascript://" onClick="windowopen('#request.self#?fuseaction=bank.popup_add_gelenh&bank_order_id=#bank_order_id#&from_bank_order=1<cfif len(project_id)>&project_id=#project_id#</cfif><cfif len(company_id)>&is_company=1</cfif>','medium');"><i class="fa fa-plus" title="<cf_get_lang dictionary_id='48722.Gelen Havale Ekle'>"></i></a>
                        </cfif>
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

