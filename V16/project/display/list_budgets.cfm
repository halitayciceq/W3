<!--- Proje İlişkili Bütçeler--->
<cfsetting showdebugoutput="no">	
<cfquery name="GET_ALL_BUDGETS" datasource="#dsn#">
	SELECT 
		BUDGET.*,
		PRD.IS_DELETE,
		PRD.RELATED_ID
	FROM 
		PRO_RELATED_BUDGET PRD,
		BUDGET
	WHERE 
		PRD.BUDGET_ID = BUDGET.BUDGET_ID 
		AND PRD.PROJECT_ID = #URL.ID#
</cfquery>
<cf_grid_list>
	<thead>
        <tr>
            <th><cf_get_lang dictionary_id='57487.No'></th>
            <th><cf_get_lang dictionary_id='57559.Bütçe'></th>
            <th><cf_get_lang dictionary_id='57482.Aşama'></th>
            <th><cf_get_lang dictionary_id='57627.Kayıt Tarihi'></th>
            <!-- sil -->
            <th width="20"><a href="javascript://" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_list_budget&related_project_id=#URL.ID#&draggable=1</cfoutput>');"><i class="fa fa-table" title="<cf_get_lang dictionary_id='38305.Iliskili Butceler'>"></i></a></th>
            <th width="20"><a href="<cfoutput>#request.self#?fuseaction=budget.list_budgets&event=add&project_id=#URL.ID#</cfoutput>" target="_blank"><i class="fa fa-plus" title="<cf_get_lang dictionary_id='57582.Ekle'>"></i></a></th>
            <!-- sil -->
        </tr>
    </thead>
    <tbody>
		<cfif get_all_budgets.recordcount>
            <cfset process_list=''>
            <cfoutput query="get_all_budgets">
                <cfif len(budget_stage) and not listfind(process_list,budget_stage)>
                    <cfset process_list = listappend(process_list,budget_stage)>
                </cfif>
            </cfoutput>
            <cfif len(process_list)>
                <cfset process_list=listsort(process_list,"numeric","ASC",",")>
                <cfquery name="GET_PROCESS_TYPE" datasource="#DSN#">
                    SELECT STAGE,PROCESS_ROW_ID FROM PROCESS_TYPE_ROWS WHERE PROCESS_ROW_ID IN (#process_list#)
                </cfquery>
                <cfset process_list = listsort(listdeleteduplicates(valuelist(get_process_type.process_row_id,',')),'numeric','ASC',',')>
            </cfif> 
            <cfoutput query="get_all_budgets">
                <tr>
                    <td>#currentrow#</td>
                    <td><a href="#request.self#?fuseaction=budget.list_budgets&event=upd&budget_id=#BUDGET_ID#" class="tableyazi" target="_blank">#BUDGET_NAME#</a></td>
                    <td>#get_process_type.stage[listfind(process_list,budget_stage,',')]#</td>
                    <td>#dateformat(RECORD_DATE,dateformat_style)#</td>
                    <!-- sil -->
                    <td><cfif is_delete eq 1><a href="javascript://" onclick="openBoxDraggable('#request.self#?fuseaction=budget.emptypopup_del_budget&relation_id=#related_id#&draggable=1');"><i class="fa fa-minus" title="<cf_get_lang dictionary_id='57463.Sil'>"></i></a></cfif></td>
                    <td><a href="#request.self#?fuseaction=budget.list_budgets&event=upd&budget_id=#BUDGET_ID#" target="_blank"><i class="fa fa-pencil" title="<cf_get_lang dictionary_id='57464.Güncelle'>" alt="<cf_get_lang dictionary_id='57464.Güncelle'>"></i></a></td>
                    <!-- sil -->
                </tr>  
            </cfoutput>
        <cfelse>
            <tr>
                <td colspan="15"><cf_get_lang dictionary_id='57484.Kayıt Bulunamadı'> !</td>
            </tr>
        </cfif>
    </tbody>
</cf_grid_list>
