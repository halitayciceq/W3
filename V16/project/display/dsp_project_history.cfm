<!---<cfinclude template="../query/get_pro_history.cfm">--->
<cfquery name="GET_PRO_HISTORY" datasource="#dsn#">
	SELECT
		PRO_HISTORY.*,
        ISNULL(PRO_HISTORY.UPDATE_EMP,UPDATE_AUTHOR) UPDATE_EMP1,
		SETUP_PRIORITY.PRIORITY_ID,
		SETUP_PRIORITY.PRIORITY,
		SETUP_PRIORITY.COLOR,
		PRO_PROJECTS.PROJECT_HEAD
	FROM
		PRO_HISTORY,
		SETUP_PRIORITY,
		PRO_PROJECTS
	WHERE
    	PRO_PROJECTS.PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.id#"> AND
        PRO_PROJECTS.PROJECT_ID = PRO_HISTORY.PROJECT_ID AND 
		PRO_HISTORY.PRO_PRIORITY_ID = SETUP_PRIORITY.PRIORITY_ID
	ORDER BY
		PRO_HISTORY.HISTORY_ID
</cfquery>
<cfparam name="attributes.page" default=1>
<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>
<cfparam name="attributes.totalrecords" default="#get_pro_history.recordcount#">
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
<cfsavecontent variable="title"><cf_get_lang dictionary_id='57473.Tarihçe'></cfsavecontent>
<cf_box title="#title#" collapsable="1" resize="1" popup_box="#iif(isdefined("attributes.draggable"),1,0)#">
	<cfset counter = 1>
        <cfif get_pro_history.recordcount>
        <cfset temp_ = 0>
            <cfoutput query="get_pro_history" > 
             <cfset temp_ = temp_ +1>
             <cfset project_stage_list = "">
		<cfset update_emp_list = "">
		<cfset update_par_list = "">
		<cfset company_partner_list = "">
		<cfset consumer_list = "">
		<cfset project_emp_list = "">
		<cfset oursrc_partner_list = "">
	<!---	<cfoutput query="get_pro_history" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">--->
			<cfif len(pro_currency_id) and not listfind(project_stage_list,pro_currency_id)>
				<cfset project_stage_list=listappend(project_stage_list,pro_currency_id)>
			</cfif>
			<cfif len(UPDATE_EMP1) and not listfind(update_emp_list,UPDATE_EMP1)>
				<cfset update_emp_list=listappend(update_emp_list,UPDATE_EMP1)>
			</cfif>
			<cfif len(update_par) and not listfind(update_par_list,update_par)>
				<cfset update_par_list=listappend(update_par_list,update_par)>
			</cfif>
			<cfif len(partner_id) and not listfind(company_partner_list,partner_id)>
				<cfset company_partner_list=listappend(company_partner_list,partner_id)>
			</cfif>
			<cfif len(consumer_id) and not listfind(consumer_list,consumer_id)>
				<cfset consumer_list=listappend(consumer_list,consumer_id)>
			</cfif>
			<cfif len(project_emp_id) and not listfind(project_emp_list,project_emp_id)>
				<cfset project_emp_list=listappend(project_emp_list,project_emp_id)>
			</cfif>
			<cfif len(outsrc_partner_id) and not listfind(oursrc_partner_list,outsrc_partner_id)>
				<cfset oursrc_partner_list=listappend(oursrc_partner_list,outsrc_partner_id)>
			</cfif>
	<!---	</cfoutput>--->
		<cfif len(project_stage_list)>
			<cfquery name="get_currency_name" datasource="#dsn#">
				SELECT PROCESS_ROW_ID,STAGE FROM PROCESS_TYPE_ROWS WHERE PROCESS_ROW_ID IN (#project_stage_list#) ORDER BY PROCESS_ROW_ID
			</cfquery>
			<cfset project_stage_list = ListSort(ListDeleteDuplicates(ValueList(get_currency_name.process_row_id,',')),'numeric','asc',',')>
		</cfif>
		<cfif len(update_emp_list)>
			<cfquery name="get_update_name" datasource="#dsn#">
				SELECT EMPLOYEE_ID,EMPLOYEE_NAME + ' ' + EMPLOYEE_SURNAME NAME_SURNAME FROM EMPLOYEES WHERE EMPLOYEE_ID IN (#update_emp_list#) ORDER BY EMPLOYEE_ID
			</cfquery>
			<cfset update_emp_list = ListSort(ListDeleteDuplicates(ValueList(get_update_name.employee_id,',')),'numeric','asc',',')>
		</cfif>
		<cfif len(update_par_list)>
			<cfquery name="get_update_par_name" datasource="#dsn#">
				SELECT PARTNER_ID,COMPANY_PARTNER_NAME + ' ' + COMPANY_PARTNER_SURNAME NAME_SURNAME FROM COMPANY_PARTNER WHERE PARTNER_ID IN (#update_par_list#) ORDER BY PARTNER_ID
			</cfquery>
			<cfset update_par_list = ListSort(ListDeleteDuplicates(ValueList(get_update_par_name.partner_id,',')),'numeric','asc',',')>
		</cfif>
		<cfif len(company_partner_list)>
			<cfquery name="get_company_partner_name" datasource="#dsn#">
				SELECT PARTNER_ID,COMPANY_PARTNER_NAME + ' ' + COMPANY_PARTNER_SURNAME NAME_SURNAME FROM COMPANY_PARTNER WHERE PARTNER_ID IN (#company_partner_list#) ORDER BY PARTNER_ID
			</cfquery>
			<cfset company_partner_list = ListSort(ListDeleteDuplicates(ValueList(get_company_partner_name.partner_id,',')),'numeric','asc',',')>
		</cfif>
		<cfif len(consumer_list)>
			<cfquery name="get_consumer_name" datasource="#dsn#">
				SELECT CONSUMER_ID,CONSUMER_NAME + ' ' + CONSUMER_SURNAME NAME_SURNAME FROM CONSUMER WHERE CONSUMER_ID IN (#consumer_list#) ORDER BY CONSUMER_ID
			</cfquery>
			<cfset consumer_list = ListSort(ListDeleteDuplicates(ValueList(get_consumer_name.consumer_id,',')),'numeric','asc',',')>
		</cfif>
		<cfif len(project_emp_list)>
			<cfquery name="get_project_emp_name" datasource="#dsn#">
				SELECT EMPLOYEE_ID,EMPLOYEE_NAME + ' ' + EMPLOYEE_SURNAME NAME_SURNAME FROM EMPLOYEES WHERE EMPLOYEE_ID IN (#project_emp_list#) ORDER BY EMPLOYEE_ID
			</cfquery>
			<cfset project_emp_list = ListSort(ListDeleteDuplicates(ValueList(get_project_emp_name.employee_id,',')),'numeric','asc',',')>
		</cfif>
		<cfif len(oursrc_partner_list)>
			<cfquery name="get_outsrc_partner_name" datasource="#dsn#">
				SELECT PARTNER_ID,COMPANY_PARTNER_NAME + ' ' + COMPANY_PARTNER_SURNAME NAME_SURNAME FROM COMPANY_PARTNER WHERE PARTNER_ID IN (#oursrc_partner_list#) ORDER BY PARTNER_ID
			</cfquery>
			<cfset oursrc_partner_list = ListSort(ListDeleteDuplicates(ValueList(get_outsrc_partner_name.partner_id,',')),'numeric','asc',',')>
		</cfif>
        <cf_seperator id="history_#temp_#" header="#dateformat(UPDATE_DATE,dateformat_style)# (#timeformat(UPDATE_DATE,timeformat_style)#) -  <cfif len(get_pro_history.UPDATE_EMP1)>#get_update_name.name_surname[ListFind(update_emp_list,UPDATE_EMP1,',')]#</cfif>" is_closed="1">
        <table id="history_#temp_#" style="display:none;">
            <tr>
                <td class="txtbold"><cf_get_lang dictionary_id ='57487.No'></td>
                <td colspan="5">#get_pro_history.CurrentRow#</td>
            </tr>
            <tr>
                <td class="txtbold"><cf_get_lang dictionary_id='57703.Güncelleme'></td>
                <td>
						<cfset UPD_DATE = date_add("h",session.ep.time_zone,get_pro_history.UPDATE_DATE)>
				#dateformat(UPD_DATE,dateformat_style)# #timeformat(UPD_DATE,timeformat_style)#
                </td>
                <td class="txtbold"><cf_get_lang dictionary_id='57891.Güncelleyen'></td>
                <td>
						<cfif len(get_pro_history.UPDATE_EMP1)>#get_update_name.name_surname[ListFind(update_emp_list,UPDATE_EMP1,',')]# <cfelse>#get_update_par_name.name_surname[ListFind(update_par_list,update_par,',')]# </cfif>
				<cfif len(get_pro_history.UPDATE_PAR)><a href="javascript://" class="tableyazi" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_par_det&par_id=#get_update_par_name.partner_id[ListFind(update_par_list,update_par,',')]#','medium');">#get_update_par_name.name_surname[ListFind(update_par_list,update_par,',')]#</a></cfif>
			</td>
                <td class="txtbold"><cf_get_lang dictionary_id='57574.Şirket'></td>
              <td>
			  			<cfif len(get_pro_history.PARTNER_ID)>
					<a href="javascript://" class="tableyazi" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_par_det&par_id=#get_company_partner_name.partner_id[ListFind(company_partner_list,partner_id,',')]#','medium');">#get_company_partner_name.name_surname[ListFind(company_partner_list,partner_id,',')]#</a>
				<cfelseif len(get_pro_history.CONSUMER_ID)>
					<a href="javascript://" class="tableyazi" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_con_det&con_id=#get_consumer_name.consumer_id[ListFind(consumer_list,consumer_id,',')]#','medium');">#get_consumer_name.name_surname[ListFind(consumer_list,consumer_id,',')]#</a>
				</cfif>
               </td>
            </tr>
            <tr>
                <td class="txtbold"><cf_get_lang dictionary_id='57569.Görevli'></td>
                <td>
                		<cfif get_pro_history.PROJECT_EMP_ID neq 0 and len(get_pro_history.PROJECT_EMP_ID)>
					<a href="javascript://" class="tableyazi" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_emp_det&emp_id=#get_project_emp_name.employee_id[ListFind(project_emp_list,project_emp_id,',')]#','medium');">#get_project_emp_name.name_surname[ListFind(project_emp_list,project_emp_id,',')]#</a>
				</cfif>
				<cfif (get_pro_history.OUTSRC_PARTNER_ID NEQ 0) and len(get_pro_history.OUTSRC_PARTNER_ID)>
					<a href="javascript://" class="tableyazi" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_par_det&par_id=#get_outsrc_partner_name.partner_id[ListFind(oursrc_partner_list,partner_id,',')]#','medium');">#get_outsrc_partner_name.name_surname[ListFind(oursrc_partner_list,partner_id,',')]#</a>
				</cfif>
                </td>
                <td class="txtbold"><cf_get_lang dictionary_id='57485.Öncelik'></td>
                <td>
                		<cfif Len(PRO_PRIORITY_ID)>#priority#</cfif>
                </td>
                <td class="txtbold"><cf_get_lang dictionary_id='57482.Aşama'></td>
                <td>
                		#get_currency_name.stage[listfind(project_stage_list,pro_currency_id,',')]# (#pro_currency_id#)
                </td>
            </tr>
            <tr>
                <td class="txtbold"><cf_get_lang dictionary_id='30111.Durumu'></td>
                <td>
                <cfif get_pro_history.PROJECT_STATUS eq 1>
                    <cf_get_lang dictionary_id='57493.Aktif'>
                <cfelseif get_pro_history.PROJECT_STATUS eq 0>
                    <cf_get_lang dictionary_id='57494.Pasif'>
                </cfif>
                </td>
                <td class="txtbold"><cf_get_lang dictionary_id='57655.Başlama Tarihi'></td>
                <cfset sdate = date_add("h",session.ep.time_zone,get_pro_history.TARGET_START)>
			<td>#dateformat(sdate,dateformat_style)# #timeformat(sdate,timeformat_style)#</td>
            <td class="txtbold"><cf_get_lang dictionary_id='57700.Bitiş Tarihi'></td>
			<cfset fdate = date_add("h",session.ep.time_zone,get_pro_history.TARGET_FINISH)>
            <td>#dateformat(fdate,dateformat_style)# #timeformat(fdate,timeformat_style)#</td>
            </tr>
         </table>	
    </cfoutput>
    </cfif>
 </cf_box>
