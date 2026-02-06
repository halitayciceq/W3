<cfsetting showdebugoutput="no">
<cfquery name="GET_PROJECT_SECUREFUND" datasource="#DSN#">
	SELECT 
		CS.*,
		OC.COMPANY_NAME,
		SS.SECUREFUND_CAT
	FROM 
		COMPANY_SECUREFUND CS,
		OUR_COMPANY OC,
		SETUP_SECUREFUND SS
	WHERE 
		CS.OUR_COMPANY_ID = OC.COMP_ID
		AND SS.SECUREFUND_CAT_ID = CS.SECUREFUND_CAT_ID
		AND	CS.PROJECT_ID = #attributes.id#
		AND SECUREFUND_STATUS = 1
	ORDER BY 
		CS.RECORD_DATE
</cfquery>
<cf_grid_list>
	<thead>
        <tr>
            <th width="10"><cf_get_lang dictionary_id='57487.NO'></th> 
            <th width="150"><cf_get_lang dictionary_id='57658.Üye'></th>
            <th width="90" nowrap><cf_get_lang dictionary_id ='58488.Alınan'>/<cf_get_lang dictionary_id ='58490.Verilen'></th>
            <th width="90"><cf_get_lang dictionary_id ='58689.Teminat'></th>
            <th width="175"><cf_get_lang dictionary_id='58792.Banka Ve Şube'></th>
            <th width="100" align="right" style="text-align:right;"><cf_get_lang dictionary_id='57673.Tutar'></th>
            <th nowrap><cf_get_lang dictionary_id ='57489.Para Br'></th>
            <th width="65"><cf_get_lang dictionary_id='57700.Bitiş Tarihi'></th>				 
            <th width="65"><cf_get_lang dictionary_id='57627.Kayıt Tarihi'></th>
         </tr>
     </thead>
     <tbody>
		<cfif GET_PROJECT_SECUREFUND.recordcount>
            <cfset company_list = ''>
            <cfset cons_list =''>
            <cfset bank_list = ''>
            <cfset branch_list = ''>
            <cfoutput query="GET_PROJECT_SECUREFUND">
                <cfif len(consumer_id) and not listfindnocase(cons_list,consumer_id)>
                    <cfset cons_list = listappend(cons_list,consumer_id,',')>
                </cfif>
                <cfif len(company_id) and not listfindnocase(company_list,company_id)>
                    <cfset company_list = listappend(company_list,company_id,',')>
                </cfif>
                <cfif len(bank_branch_id) and not listfindnocase(branch_list,bank_branch_id)>
                    <cfset branch_list = listappend(branch_list,bank_branch_id,',')>
                </cfif>									
            </cfoutput>
            <cfif len(cons_list)>
                <cfset cons_list = listsort (listdeleteduplicates(cons_list),"numeric","ASC",",")>
                <cfquery name="get_cons" datasource="#DSN#">
                    SELECT CONSUMER_ID,CONSUMER_NAME,CONSUMER_SURNAME FROM CONSUMER WHERE CONSUMER_ID IN (#cons_list#) ORDER BY CONSUMER_ID
                </cfquery>
            </cfif>
            <cfif len(company_list)>
                <cfset company_list = listsort(listdeleteduplicates(company_list),"numeric","ASC",",")>
                <cfquery name="get_comp" datasource="#DSN#">
                    SELECT COMPANY_ID, NICKNAME, FULLNAME FROM COMPANY WHERE COMPANY_ID IN (#company_list#) ORDER BY COMPANY_ID
                </cfquery>
            </cfif>
            <cfif len(bank_list)>
                <cfset bank_list = listsort (listdeleteduplicates(bank_list),"numeric","ASC",",")>
                <cfquery name="get_bank" datasource="#DSN#">
                    SELECT BANK_ID,BANK_NAME FROM SETUP_BANK_TYPES WHERE BANK_ID IN (#bank_list#) ORDER BY BANK_ID
                </cfquery>
            </cfif>
            <cfif len(branch_list)>
                <cfset branch_list = listsort (listdeleteduplicates(branch_list),"numeric","ASC",",")>
                <cfquery name="get_branch" datasource="#DSN3#">
                    SELECT BANK_BRANCH_ID,BANK_BRANCH_NAME,BANK_NAME FROM BANK_BRANCH WHERE BANK_BRANCH_ID IN (#branch_list#) ORDER BY BANK_BRANCH_ID
                </cfquery>
            </cfif>					
            <cfoutput query="GET_PROJECT_SECUREFUND"> 
                <tr>
                    <td>#currentrow#</td>
                    <td width="150">
                        <cfif len(company_id)>
                            <a href="javascript://" class="tableyazi" onclick="windowopen('#request.self#?fuseaction=objects.popup_com_det&company_id=#company_id#','medium');">
                            #get_comp.fullname[listfind(company_list,company_id,',')]#</a>
                        <cfelseif len(consumer_id)>
                            <a href="javascript://" class="tableyazi" onclick="windowopen('#request.self#?fuseaction=objects.popup_con_det&con_id= #consumer_id#','medium');">
                            #get_cons.consumer_name[listfind(cons_list,consumer_id,',')]# #get_cons.consumer_surname[listfind(cons_list,consumer_id,',')]#</a>
                        </cfif>
                    </td>
                    <td>
                        <a href="javascript://" onClick="windowopen('#request.self#?fuseaction=finance.list_securefund&event=upd&securefund_id=#SECUREFUND_ID#','medium');" class="tableyazi">
                            <cfif GIVE_TAKE eq 0><cf_get_lang dictionary_id ='58488.Alınan'><cfelse><cf_get_lang dictionary_id ='58490.Verilen'></cfif>
                        </a>
                    </td>
                    <td>#SECUREFUND_CAT#</td>
                    <td width="150"><cfif len(bank_branch_id)>#get_branch.bank_name[listfind(branch_list,BANK_BRANCH_ID,',')]# &nbsp;-&nbsp; #get_branch.bank_branch_name[listfind(branch_list,BANK_BRANCH_ID,',')]#<cfelse>#BANK# ----- #BANK_BRANCH#</cfif></td>
                    <td style="text-align:right;">#TLFormat(ACTION_VALUE)# </td>
                    <td>&nbsp;#session.ep.money#</td>
                    <td>#dateformat(FINISH_DATE,dateformat_style)#</td>
                    <td>#dateformat(record_date,dateformat_style)#</td>
                </tr>
            </cfoutput>
        <cfelse>
            <tr>
                <td colspan="12"><cfif isdefined('attributes.is_submitted') and len(attributes.is_submitted)><cf_get_lang dictionary_id='57484.Kayıt Bulunamadı'><cfelse><cf_get_lang dictionary_id='57701.Filtre Ediniz'></cfif>!</td>
            </tr>
        </cfif>
     </tbody>
</cf_grid_list> 
