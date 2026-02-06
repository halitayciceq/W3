<cfsetting showdebugoutput="no">
<cfquery name="project_relation_projects" datasource="#dsn#">
	SELECT 
		PRO_PROJECTS.PROJECT_ID,
		PRO_PROJECTS.PROJECT_NUMBER,
		PRO_PROJECTS.PROJECT_HEAD,
		PRO_PROJECTS.CONSUMER_ID,
		PRO_PROJECTS.COMPANY_ID,
		PRO_PROJECTS.PARTNER_ID,
		PRO_PROJECTS.PROJECT_EMP_ID,
		PRO_PROJECTS.OUTSRC_CMP_ID,
		PRO_PROJECTS.OUTSRC_PARTNER_ID,
		PRO_PROJECTS.TARGET_FINISH,
		PRO_PROJECTS.TARGET_START,
		PRO_PROJECTS.AGREEMENT_NO,
		PRO_PROJECTS.PRO_CURRENCY_ID
	FROM 
		PRO_PROJECTS 
	WHERE 
		RELATED_PROJECT_ID = #attributes.project_id#
		<cfif isdefined("attributes.related_pro_id") and len(attributes.related_pro_id)>
			OR PROJECT_ID = #attributes.related_pro_id#
		</cfif>
      	ORDER BY
        	PRO_PROJECTS.PROJECT_HEAD ASC
</cfquery>
<div id="project_relation_projects_div">
<cf_ajax_list>
    <thead>
        <tr>
            <th width="15"><cf_get_lang dictionary_id='57487.No'></th>
            <th width="35">P.<cf_get_lang dictionary_id='57487.no'></th>
            <th><cf_get_lang dictionary_id='58015.projeler'></th>
            <th width="160"><cf_get_lang dictionary_id='57574.şirket'></th>
            <th width="125"><cf_get_lang dictionary_id='57569.görevli'></th>
            <th width="90"><cf_get_lang dictionary_id='58053.Başlangıç tarihi'></th>
            <th width="65"><cf_get_lang dictionary_id='58767.bitiş tarihi'></th>
            <th width="2%">&nbsp;</th>
        </tr>
    </thead>
    <tbody>
	<cfif project_relation_projects.recordcount>
		<cfset company_id_list="">
		<cfset consumer_id_list="">
		<cfset emp_id_list="">
		<cfset out_partner_id_list="">
		<cfoutput query="project_relation_projects">
			<cfif len(partner_id) and not listfind(company_id_list,partner_id)>
				<cfset company_id_list=listappend(company_id_list,partner_id)>
			<cfelseif len(consumer_id) and not listfind(consumer_id_list,consumer_id)>
				<cfset consumer_id_list=listappend(consumer_id_list,consumer_id)>
			</cfif>
			<cfif len(project_emp_id) and not listfind(emp_id_list,project_emp_id)>
				<cfset emp_id_list=listappend(emp_id_list,project_emp_id)>
			</cfif>
			<cfif len(outsrc_partner_id) and not listfind(company_id_list,outsrc_partner_id)>
				<cfset company_id_list=listappend(company_id_list,outsrc_partner_id)>
			</cfif>
		</cfoutput>
		<cfif len(company_id_list)>
		<cfset company_id_list=listsort(company_id_list,"numeric","ASC",",")>
			<cfquery name="GET_PARTNER_DETAIL" datasource="#DSN#">
				SELECT
					C.NICKNAME,
					CP.COMPANY_PARTNER_NAME,
					CP.COMPANY_PARTNER_SURNAME
				FROM 
				COMPANY_PARTNER CP,
					COMPANY C
				WHERE 
					CP.PARTNER_ID IN (#company_id_list#) 
					AND CP.COMPANY_ID = C.COMPANY_ID
				ORDER BY
					CP.PARTNER_ID
			</cfquery>
		</cfif>
		<cfif len(consumer_id_list)>
		<cfset consumer_id_list=listsort(consumer_id_list,"numeric","ASC",",")>
			<cfquery name="GET_CONSUMER_DETAIL" datasource="#DSN#">
				SELECT CONSUMER_ID,CONSUMER_NAME,CONSUMER_SURNAME FROM CONSUMER WHERE CONSUMER_ID IN (#consumer_id_list#) ORDER BY CONSUMER_ID
			</cfquery>
		</cfif>
		<cfif len(emp_id_list)>
		<cfset emp_id_list=listsort(emp_id_list,"numeric","ASC",",")>
			<cfquery name="GET_EMP_DETAIL" datasource="#DSN#">
				SELECT EMPLOYEE_ID,EMPLOYEE_NAME,EMPLOYEE_SURNAME FROM EMPLOYEES WHERE EMPLOYEE_ID IN (#emp_id_list#) ORDER BY EMPLOYEE_ID
			</cfquery>
		</cfif>
		<cfoutput query="project_relation_projects">
			<tr>
				<td width="20">#currentrow#</td>
				<td>#project_number#</td>
				<td><a href="javascript://" onclick="gizle_goster(relatedProjectTr_#project_id#);proRelationWorks(#project_relation_projects.project_id#);" class="tableyazi">#project_head#</a></td>
				<td><cfif len(company_id) and len(company_id_list)>
						<a href="javascript://" class="tableyazi" onclick="windowopen('#request.self#?fuseaction=objects.popup_com_det&company_id=#company_id#','medium');">#get_partner_detail.nickname[listfind(company_id_list,partner_id,',')]#</a>-
						<a href="javascript://" class="tableyazi" onclick="windowopen('#request.self#?fuseaction=objects.popup_par_det&par_id=#PARTNER_ID#','medium');">#get_partner_detail.company_partner_name[listfind(company_id_list,partner_id,',')]# #get_partner_detail.company_partner_surname[listfind(company_id_list,partner_id,',')]#</a>
					<cfelseif len(consumer_id) and len(consumer_id_list)>
						<a href="javascript://" class="tableyazi" onclick="windowopen('#request.self#?fuseaction=objects.popup_con_det&con_id=#consumer_id#','medium');">#get_consumer_detail.consumer_name[listfind(consumer_id_list,consumer_id,',')]# #get_consumer_detail.consumer_surname[listfind(consumer_id_list,consumer_id,',')]#</a>
					</cfif>
				</td>
				<td><cfif len(project_emp_id) and len(emp_id_list)>
						<a href="javascript://" class="tableyazi" onclick="windowopen('#request.self#?fuseaction=objects.popup_emp_det&emp_id=#project_emp_id#','medium');">#get_emp_detail.employee_name[listfind(emp_id_list,project_emp_id,',')]# #get_emp_detail.employee_surname[listfind(emp_id_list,project_emp_id,',')]#</a>
					</cfif>
					<cfif len(outsrc_partner_id) and len(company_id_list)>
						<a href="javascript://" class="tableyazi" onclick="windowopen('#request.self#?fuseaction=objects.popup_com_det&company_id=#outsrc_cmp_id#','medium');">#get_partner_detail.nickname[listfind(company_id_list,outsrc_partner_id,',')]#</a>-
						<a href="javascript://" class="tableyazi" onclick="windowopen('#request.self#?fuseaction=objects.popup_par_det&par_id=#outsrc_partner_id#','medium');">#get_partner_detail.company_partner_name[listfind(company_id_list,outsrc_partner_id,',')]# #get_partner_detail.company_partner_surname[listfind(company_id_list,outsrc_partner_id,',')]#</a>
					</cfif>
				</td>
				<td>#dateformat(project_relation_projects.target_start,dateformat_style)#</td>
				<td>#dateformat(project_relation_projects.target_finish,dateformat_style)#</td>
				<!-- sil -->
				<td width="2%"><a href="#request.self#?fuseaction=project.projects&event=det&id=#project_id#"><img src="/images/update_list.gif" title="<cf_get_lang dictionary_id ='57464.Güncelle'>" border="0"></a></td>
				<!-- sil -->
			</tr>
			<tr style="display:none;" id="relatedProjectTr_#project_relation_projects.project_id#" class="nohover">
				<td colspan="8"><div id="proRelatedWorks_#project_relation_projects.project_id#" class="nohover_div"></div></td>
			</tr>
		</cfoutput>
	<cfelse>
		<tr>
			<td colspan="8"><cf_get_lang dictionary_id='57484.Kayıt Yok'> !</td>
		</tr>
	</cfif>
    </tbody>
</cf_ajax_list>
</div>
<script type="text/javascript">
function proRelationWorks(proId)
	{
		AjaxPageLoad('<cfoutput>#request.self#?fuseaction=project.emptypopup_ajax_project_works&related_project_info=1&xml_show_actual_date=<cfoutput>#attributes.xml_show_actual_date#</cfoutput>&project_id='+proId+'','proRelatedWorks_'+proId+''</cfoutput>,1);
	}
</script>
