<cfif not len(attributes.WORKGROUP_ID)>
	<CFLOCK name="#createUUID()#" timeout="20">
		 <CFTRANSACTION>
		   <cfquery name="INSGROUP" datasource="#dsn#" result="MAX_ID">
			   INSERT INTO 
					WORK_GROUP 
						(
                            <cfif isDefined("attributes.project_id")>
								PROJECT_ID,
								WORKGROUP_NAME,
							<cfelseif isDefined("attributes.action_id")>
								ACTION_FIELD,
								ACTION_ID,
							</cfif>
                            STATUS,
                            RECORD_EMP,
                            RECORD_DATE,
                            RECORD_IP
						) 
					VALUES 
						(
							<cfif isDefined("attributes.project_id")>
								#attributes.project_id#,
								'#attributes.project_head#',
							<cfelseif isDefined("attributes.action_id")>
								'#attributes.action_field#',
								#attributes.action_id#,
							</cfif>
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
		DELETE FROM WORKGROUP_EMP_PAR WHERE WORKGROUP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#this_workgroup_id#"> AND OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#">
	</cfquery>
</cfif>
<cfquery name="GET_ROLES" datasource="#dsn#">
	SELECT * FROM SETUP_PROJECT_ROLES ORDER BY PROJECT_ROLES_ID
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
			PRODUCT_ID,
			PRODUCT_UNIT_PRICE,
			PRODUCT_MONEY,
			PRODUCT_UNIT,
			RECORD_EMP,
			RECORD_IP,
			RECORD_DATE
			<cfif isDefined("attributes.project_id")>,PROJECT_ID</cfif>
			,PER_HOUR_SALARY
		  	,OUR_COMPANY_ID
			,WEEK_AMOUNT
			,COST_PRICE
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
			<cfif isdefined('attributes.product_id#i#') and isdefined('attributes.product#i#') and len(evaluate("attributes.product#i#")) and len(evaluate("attributes.product_id#i#"))>#evaluate("attributes.product_id#i#")#<cfelse>NULL</cfif>,
			<cfif isdefined('attributes.sales_price#i#') and len(evaluate("attributes.sales_price#i#"))>#FilterNum(evaluate("attributes.sales_price#i#"))#<cfelse>NULL</cfif>,
			<cfif isdefined('attributes.money_type#i#') and len(evaluate("attributes.money_type#i#"))>'#wrk_eval("attributes.money_type#i#")#'<cfelse>NULL</cfif>,
			<cfif isdefined('attributes.unit_name#i#') and len(evaluate("attributes.unit_name#i#"))>'#wrk_eval("attributes.unit_name#i#")#'<cfelse>NULL</cfif>,
			#session.ep.userid#,
			'#cgi.remote_addr#',
			#now()#
			<cfif isDefined("attributes.project_id")>,#attributes.project_id#</cfif>
			,<cfif isDefined("attributes.per_hour_salary#i#") and len(evaluate("attributes.per_hour_salary#i#"))>#FilterNum(evaluate("attributes.per_hour_salary#i#"),2)#<cfelse>NULL</cfif>
			,<cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#">
			,<cfif isdefined('attributes.week_amount#i#') and len(evaluate("attributes.week_amount#i#"))>#evaluate("attributes.week_amount#i#")#<cfelse>NULL</cfif>
			,<cfif isdefined('attributes.price#i#') and len(evaluate("attributes.price#i#"))>#FilterNum(evaluate("attributes.price#i#"))#<cfelse>NULL</cfif>
		)
	</cfquery>
  </cfif>
</cfloop>
<script>
	<cfif not isdefined("attributes.draggable")>
		location.href=document.referrer;
	<cfelse>
		closeBoxDraggable( '<cfoutput>#attributes.modal_id#</cfoutput>', 'unique_workgroup');
	</cfif>
	
</script>
<!--- <cfif isDefined("attributes.project_id")>
	<cflocation url="#request.self#?fuseaction=project.popup_add_workgroup&project_id=#attributes.project_id#" addtoken="no">
<cfelseif isDefined("attributes.action_id")>
	<cflocation url="#request.self#?fuseaction=project.popup_add_workgroup&action_field=#attributes.action_field#&action_id=#attributes.action_id#" addtoken="no">
</cfif> --->