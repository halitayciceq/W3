<cfif not len(attributes.WORKGROUP_ID)>
	<CFLOCK name="#createUUID()#" timeout="20">
		 <CFTRANSACTION>
		   <cfquery name="INSGROUP" datasource="#dsn#" result="max_id">
			   INSERT INTO 
					WORK_GROUP 
						(
						OPP_ID,
						WORKGROUP_NAME,
						STATUS,
						RECORD_EMP,
						RECORD_DATE,
						RECORD_IP
						) 
					VALUES 
						(
						#attributes.opp_id#,
						'#attributes.opp_head#',
						1,
						#session.ep.userid#,
						#NOW()#,
						'#cgi.REMOTE_ADDR#'
					)
			</cfquery>
		 </CFTRANSACTION>
		</CFLOCK>
	<cfset this_workgroup_id = MAX_ID.IDENTITYCOL>
<cfelse>
	<cfset this_workgroup_id = attributes.WORKGROUP_ID>
	<cfquery name="del_work_emp_par" datasource="#dsn#">
		DELETE FROM WORKGROUP_EMP_PAR WHERE WORKGROUP_ID=#this_workgroup_id#
	</cfquery>
</cfif>
<cfquery name="GET_ROLES" datasource="#dsn#">
	SELECT 
    	PROJECT_ROLES_ID, 
        PROJECT_ROLES, 
        DETAIL, 
        RECORD_DATE, 
        RECORD_EMP, 
        RECORD_IP, 
        UPDATE_DATE, 
        UPDATE_EMP, 
        UPDATE_IP 
    FROM 
	    SETUP_PROJECT_ROLES 
    ORDER BY 
    	PROJECT_ROLES_ID
</cfquery>
<cfset role_list = listsort(listdeleteduplicates(valuelist(GET_ROLES.PROJECT_ROLES_ID,',')),'numeric','ASC',',')>

<cfloop from="1" to="#attributes.record#" index="i">
<cfif evaluate("attributes.row_kontrol#i#")>
	<cfset this_role_id_ = evaluate("attributes.role_id#i#")>
	<cfset this_role_name_ = GET_ROLES.PROJECT_ROLES[listfind(role_list,this_role_id_,',')]>
	<cfquery name="add_workgroup_emp_par" datasource="#DSN#">
	  INSERT INTO 
		WORKGROUP_EMP_PAR
		 (
		  WORKGROUP_ID,
		  EMPLOYEE_ID,
		  IS_REAL,
		  IS_CRITICAL,
		  HIERARCHY,
		  ROLE_HEAD,
		  ROLE_ID,
		  IS_ORG_VIEW,
		  CONSUMER_ID,
		  COMPANY_ID,
		  PARTNER_ID,
		  RECORD_EMP,
		  RECORD_IP,
		  RECORD_DATE,
		  OPP_ID
		 )
		 VALUES
		 (
		  #this_workgroup_id#,
		  <cfif isdefined("attributes.employee_id#i#") and len(evaluate("attributes.employee_id#i#"))>#evaluate("attributes.employee_id#i#")#<cfelse>NULL</cfif>,
		  1,
		  0,
		  <cfif isdefined("attributes.code#i#") and len(evaluate("attributes.code#i#"))>'#wrk_eval("attributes.code#i#")#'<cfelse>NULL</cfif>,
		  '#this_role_name_#',
		  <cfif len(this_role_id_)>#this_role_id_#<cfelse>NULL</cfif>,
		  1,
		  <cfif isdefined('attributes.consumer_id#i#') and len(evaluate("attributes.consumer_id#i#"))>#evaluate("attributes.consumer_id#i#")#<cfelse>NULL</cfif>,
		  <cfif isdefined('attributes.company_id#i#') and len(evaluate("attributes.company_id#i#"))>#evaluate("attributes.company_id#i#")#<cfelse>NULL</cfif>,
		  <cfif isdefined('attributes.partner_id#i#') and len(evaluate("attributes.partner_id#i#"))>#evaluate("attributes.partner_id#i#")#<cfelse>NULL</cfif>,
		  #session.ep.userid#,
		  '#cgi.remote_addr#',
		  #now()#,
		  #attributes.opp_id#
		 )
	</cfquery>
  </cfif>
</cfloop>
<cfif isdefined("attributes.modal_id") and len(attributes.modal_id)>
	<script type="text/javascript">	
		closeBoxDraggable( '<cfoutput>#attributes.modal_id#</cfoutput>' );
	</script> 
<cfelse>
	<cflocation url="#request.self#?fuseaction=sales.popup_add_workgroup&opp_id=#attributes.opp_id#" addtoken="no">
</cfif>

