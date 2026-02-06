<cfinclude template="../query/get_project_team.cfm">
<table cellspacing="1" cellpadding="2" width="100%" border="0">
<cfif GET_EMPS.recordcount OR GET_PARS.RECORDCOUNT>
  <cfoutput query="GET_EMPS">
	<tr>
	  <td>
		<cfif isdefined("session.pp.userid") AND get_workcube_app_user(GET_EMPS.employee_id, 0).recordcount>
		  <a href="javascript://" onClick="windowopen('#request.self#?fuseaction=objects.popup_message&employee_id=#GET_EMPS.EMPLOYEE_ID#','small');"><img src="/images/onlineuser.gif"  border="0" title="Mesaj At"></a>
		<cfelse>
		  <a href="javascript://" onClick="windowopen('#request.self#?fuseaction=objects2.popup_add_nott&public=1&employee_id=#GET_EMPS.EMPLOYEE_ID#','small');"><img src="/images/visit_note.gif"  border="0" title="<cf_get_lang dictionary_id='46092.Not Bırak'>"></a>
		</cfif>
	 </td>
	  <td><a href="javascript://"  onclick="windowopen('#request.self#?fuseaction=objects2.popup_emp_det&emp_id=#encrypt(employee_id,"WORKCUBE","BLOWFISH","Hex")#','medium');" class="tableyazi">
	  		#EMPLOYEE_NAME# #EMPLOYEE_SURNAME# -</a>
		<cfif len(ROLE_ID)>
		  <cfquery name="GET_ROL_NAME" datasource="#DSN#">
			  SELECT 
				  PROJECT_ROLES 
			  FROM 
				  SETUP_PROJECT_ROLES 
			  WHERE 
				  PROJECT_ROLES_ID = #ROLE_ID#
		  </cfquery>
			  #GET_ROL_NAME.PROJECT_ROLES#
		</cfif>
	  </td>
	</tr>
  </cfoutput> 
  <cfoutput query="GET_PARS">
	<tr>
	   <td>
		<cfif isdefined("session.pp.userid") AND get_workcube_app_user(GET_PARS.partner_id, 0).recordcount>
		  <a href="javascript://" onClick="windowopen('#request.self#?fuseaction=objects.popup_message&partner_id=#GET_PARS.partner_id#','small');"><img src="/images/onlineuser.gif"  border="0" title="Mesaj At"></a>
		<cfelse>
		  <a href="javascript://" onClick="windowopen('#request.self#?fuseaction=objects2.popup_add_nott&public=1&partner_id=#GET_PARS.partner_id#','small');"><img src="/images/visit_note.gif"  border="0" title="<cf_get_lang dictionary_id='46092.Not Bırak'>"></a>
		</cfif>
	  </td>
	  <td><a href="javascript://"  onclick="windowopen('#request.self#?fuseaction=objects2.popup_par_det&par_id=#partner_id#','medium');" class="tableyazi">
	  		#nickname# / #COMPANY_PARTNER_NAME# #COMPANY_PARTNER_SURNAME# -
		  </a>
		<cfif len(ROLE_ID)>
		  <cfquery name="GET_ROL_NAME2" datasource="#DSN#">
			  SELECT 
				  PROJECT_ROLES 
			  FROM 
				  SETUP_PROJECT_ROLES 
			  WHERE 
				  PROJECT_ROLES_ID = #ROLE_ID#
		  </cfquery>
		  #GET_ROL_NAME2.PROJECT_ROLES#
		</cfif>
	  </td>
	</tr>
  </cfoutput>
  <cfelse>
</cfif>
</table>

