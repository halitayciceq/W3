<input type="hidden" name="project_id" id="project_id" value="<cfoutput>#attributes.project_id#</cfoutput>">
<cfinclude template="../query/get_emp_par.cfm">
<table cellSpacing="0" cellpadding="0" width="98%" border="0">
  <tr class="color-border">
    <td>
      <table cellspacing="1" cellpadding="2" width="100%" border="0">
        <tr class="color-header">
          <td height="22" class="form-title"><cf_get_lang dictionary_id='41438.Proje Grubu'></td>
        </tr>
        <cfif GET_EMPS.recordcount OR GET_PARS.RECORDCOUNT>
          <cfoutput query="GET_EMPS">
            <tr class="color-row">
              <td><a href="javascript://" onClick="windowopen('#request.self#?fuseaction=objects.popup_emp_det&emp_id=#EMPLOYEE_ID#','medium');" class="tableyazi">#EMPLOYEE_NAME# #EMPLOYEE_SURNAME#</a> -
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
          </cfoutput> <cfoutput query="GET_PARS">
            <tr class="color-row">
              <td><a href="javascript://" onClick="windowopen('#request.self#?fuseaction=objects.popup_par_det&par_id=#partner_id#','medium');" class="tableyazi">#COMPANY_PARTNER_NAME# #COMPANY_PARTNER_SURNAME#</a>/#nickname# -
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
          <tr class="color-row">
            <td><cf_get_lang dictionary_id='57484.Kayıt Bulunamadı'>!</td>
          </tr>
        </cfif>
      </table>
    </td>
  </tr>
</table>
