<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.currency" default="">
<cfparam name="attributes.PRIORITY_CAT" default="">
<cfquery name="GET_WORK" datasource="#DSN#">
	SELECT
		*
	FROM
		PRO_WORKS,
		SETUP_PRIORITY
	WHERE
		PRO_WORKS.WORK_PRIORITY_ID = SETUP_PRIORITY.PRIORITY_ID AND
		PRO_WORKS.WORK_STATUS = 1 AND
		(
			PRO_WORKS.UPDATE_AUTHOR = #session.ep.userid# OR
			PRO_WORKS.PROJECT_EMP_ID = #session.ep.userid# OR
			PRO_WORKS.RECORD_AUTHOR = #session.ep.userid#
		)
	ORDER BY
		PRO_WORKS.TARGET_START DESC
</cfquery>
<cfparam name="attributes.page" default=1>
<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>
<cfparam name="attributes.totalrecords" default="#get_work.recordcount#">
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
<cf_medium_list>
	<thead>
		<tr>
			<th></th>
			<th><cf_get_lang dictionary_id='38213.İş'></th>
			<th width="150"><cf_get_lang dictionary_id='57416.proje'></th>
			<th width="125"><cf_get_lang dictionary_id='56870.Personel'></th>
			<th width="50"><cf_get_lang dictionary_id='57485.Öncelik'></th>
			<th width="90"><cf_get_lang dictionary_id='57501.Başlangıç'></th>
			<th width="50"><cf_get_lang dictionary_id='57482.Aşama'></th>
			<th width="20">%</th>
			<th width="15"></th>
		</tr>
	</thead>
	<tbody>
		<cfif not get_work.recordcount>
			<tr>
				<td colspan="9" height="20"><cf_get_lang dictionary_id='57484.Kayıt Bulunamadı'>!</td>
			</tr>
		<cfelse><!--- Bu kısımda listeleme mantığı ile yapılan query'ler dönüyor. --->
			<cfset proje_name_list = "">
			<cfset emp_name_list = "">
			<cfset project_stage_list = "">
			<cfoutput query="get_work" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
				<cfif len(project_emp_id) and not ListFind(emp_name_list,project_emp_id)>
					<cfset emp_name_list = ListAppend(emp_name_list,project_emp_id)>
				</cfif>
				<cfif len(project_id) and not listfind(proje_name_list,project_id)>
					<cfset proje_name_list = Listappend(proje_name_list,project_id)>
				</cfif>
				<cfif len(work_currency_id) and not listfind(project_stage_list,work_currency_id)>
					<cfset project_stage_list = Listappend(project_stage_list,work_currency_id)>
				</cfif>
			</cfoutput>
			<cfif len(emp_name_list)>
				<cfset emp_name_list = ListSort(emp_name_list,"numeric","ASC",",")>
				<cfquery name="GET_EMPLOOYES" datasource="#DSN#">
					SELECT 
						EMPLOYEE_ID,
						EMPLOYEE_NAME,
						EMPLOYEE_SURNAME
					FROM 
						EMPLOYEES
					WHERE
						EMPLOYEE_ID IN(#emp_name_list#)
					ORDER BY 
						EMPLOYEE_ID	
				</cfquery>
				<cfset emp_name_list = listsort(listdeleteduplicates(valuelist(get_emplooyes.employee_id,',')),'numeric','ASC',',')>					
			</cfif>
			<cfif len(proje_name_list)>
				<cfset proje_name_list = ListSort(proje_name_list,"numeric","ASC",",")>
				<cfquery name="WORKS_PRO" datasource="#DSN#">
					SELECT 
						PROJECT_HEAD,
						PROJECT_ID
					FROM 
						PRO_PROJECTS
					WHERE
						PROJECT_ID IN (#proje_name_list#)
					ORDER BY 
						PROJECT_ID
				</cfquery>
				<cfset proje_name_list = listsort(listdeleteduplicates(valuelist(works_pro.project_id,',')),'numeric','ASC',',')>
			</cfif>
			<cfif len(project_stage_list)>
				<cfset project_stage_list = listsort(project_stage_list,'numeric','ASC',',')>
				<cfquery name="get_currency_name" datasource="#dsn#">
					SELECT PROCESS_ROW_ID,STAGE FROM PROCESS_TYPE_ROWS WHERE PROCESS_ROW_ID IN (#project_stage_list#) ORDER BY PROCESS_ROW_ID
				</cfquery>
				<cfset project_stage_list = listsort(listdeleteduplicates(valuelist(get_currency_name.process_row_id,',')),'numeric','ASC',',')>
			</cfif>
		<cfoutput query="get_work" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
			<tr>
				<td width="1%">
					<a href="javascript://" onclick="gizle_goster_img('listele_down_img#currentrow#','listele_img#currentrow#','works_history#currentrow#');"><img src="/images/listele_down.gif" title="<cf_get_lang dictionary_id ='58628.Gizle'>"  border="0" align="absmiddle" id="listele_down_img#currentrow#" style="display:none;cursor:pointer;"></a>
					<a href="javascript://" onclick="gizle_goster_img('listele_down_img#currentrow#','listele_img#currentrow#','works_history#currentrow#');AjaxPageLoad('#request.self#?fuseaction=project.emptypopup_updwork_ajaxhistory&id=#work_id#','_works_history_#currentrow#',1);"><img src="/images/listele.gif" title="<cf_get_lang dictionary_id ='58596.Göster'>" border="0" align="absmiddle"  id="listele_img#currentrow#" style="display:;cursor:pointer;"></a>
				</td>
				<td><a href="javascript://" class="tableyazi" onClick="windowopen('#request.self#?fuseaction=project.works&event=det&id=#work_id#','project')" ><font color="#get_work.color#">#get_work.work_head#</font></a></td>
				<td>
					<cfif len(get_work.project_id)>
						<a href="#request.self#?fuseaction=project.projects&event=det&id=#get_work.project_id#" class="tableyazi">#WORKS_PRO.PROJECT_HEAD[listfind(proje_name_list,get_work.project_id,',')]#</a>
					<cfelse>
						<cf_get_lang dictionary_id='58459.Projesiz'>
					</cfif>
				</td>
				<td class="label">
					<cfif (get_work.project_emp_id neq 0) and len(get_work.project_emp_id)>
						<a href="javascript://" onClick="windowopen('#request.self#?fuseaction=objects.popup_emp_det&emp_id=#get_emplooyes.employee_id[listfind(emp_name_list,get_work.project_emp_id,',')]#','list');" class="tableyazi">
							#get_emplooyes.employee_name[listfind(emp_name_list,get_work.project_emp_id,',')]# #get_emplooyes.employee_surname[listfind(emp_name_list,get_work.project_emp_id,',')]#
						</a>
					</cfif>
					<cfif (get_work.outsrc_partner_id neq 0) and len(get_work.outsrc_partner_id)>
						#GET_PAR_INFO(get_work.outsrc_partner_id,0,0,1)#
					</cfif>
				</td>
				<td><cfif len(get_work.work_priority_id)><font color="#get_work.color#">#get_work.priority#</font></cfif></td>
				<cfset sdate=date_add("h",session.ep.time_zone,get_work.target_start)>
				<td><font color="#get_work.color#">#dateformat(sdate,dateformat_style)# #timeformat(sdate,timeformat_style)#</font></td>
				<td><font color="#get_work.color#">#get_currency_name.stage[listfind(project_stage_list,work_currency_id,',')]#</font></td>
				<td align="right"><cfif len(get_work.to_complete)>#get_work.to_complete#<cfelse>-</cfif></td>
				<td width="15"><a href="javascript://" onClick="windowopen('#request.self#?fuseaction=project.works&event=det&id=#work_id#','project');"><img src="/images/update_list.gif" border="0" align="absmiddle" title="<cf_get_lang dictionary_id ='57464.Güncelle'>"></a> </td>
			</tr>
			<tr id="works_history#currentrow#" style="display:none;" class="nohover">
				<td colspan="9"><div id="_works_history_#currentrow#" style="overflow:auto;height:200;"></div></td>
			</tr>	
		</cfoutput>
		</cfif>
	</tbody>
</cf_medium_list>
<cfif attributes.totalrecords gt attributes.maxrows>
	<table width="99%" height="35">
		<tr>
			<td>
				<cf_pages page="#attributes.page#"
					maxrows="#attributes.maxrows#"
					totalrecords="#attributes.totalrecords#"
					startrow="#attributes.startrow#"
					adres="project.list_project_work&keyword=#attributes.keyword#&currency=#attributes.currency#&priority_cat=#attributes.priority_cat#">
			</td>
			<!-- sil -->
			<td class="label" style="text-align:right;"><cf_get_lang dictionary_id='57540.Toplam Kayıt'>:<cfoutput>#attributes.totalrecords#&nbsp;-&nbsp;<cf_get_lang dictionary_id='57581.Sayfa'>:#attributes.page#/#lastpage#</cfoutput></td>
			<!-- sil -->
		</tr>
	</table>
</cfif>
