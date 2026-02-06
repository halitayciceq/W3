<cfloop from="1" to="#attributes.last_record#"index="i">
		<cfset 'attributes.work_start#i#' = date_add('h', evaluate('attributes.start_hour#i#') - session.ep.time_zone, evaluate('attributes.work_start#i#'))>
		<cfset 'attributes.work_finish#i#' = date_add('h', evaluate('attributes.finish_hour#i#') - session.ep.time_zone, evaluate('attributes.work_finish#i#'))>

<!--- 		<cf_date tarih='attributes.work_start#i#'>
		<cf_date tarih='attributes.work_finish#i#'>
 --->	<cfif isdefined('attributes.hidden_work_head#i#') and len(evaluate('attributes.hidden_work_head#i#'))>
		<cfquery name="upd_work_gant" datasource="#dsn#">
			UPDATE 
				PRO_WORKS
			SET
					WORK_HEAD = '#wrk_eval('attributes.work_head#i#')#',
 					<!--- PROJECT_ID = <cfif len(id)>#attributes.id#<cfelse>NULL</cfif>, --->
					PROJECT_EMP_ID = <cfif isdefined('attributes.study_emp_id#i#') and len(evaluate('attributes.study_emp_id#i#'))>#evaluate('attributes.study_emp_id#i#')#<cfelse>NULL</cfif>,
					WORK_PRIORITY_ID = #evaluate('attributes.priority_cat#i#')#,
					WORK_CAT_ID = #evaluate('attributes.work_cat#i#')#,
					<!--- RELATED_WORK_ID = <cfif isdefined('attributes.related#i#') and len(evaluate('attributes.related#i#'))>#evaluate('attributes.related#i#')#<cfelse>NULL</cfif>,--->
					TO_COMPLETE = <cfif isdefined('attributes.is_complate#i#') and len(evaluate('attributes.is_complate#i#'))>#evaluate('attributes.is_complate#i#')#<cfelse>NULL</cfif>,
					WORK_CURRENCY_ID = #evaluate('attributes.stage#i#')#,
					TARGET_START = <cfif len(evaluate('attributes.work_start#i#'))>#evaluate('attributes.work_start#i#')#</cfif>,
					TARGET_FINISH = <cfif len(evaluate('attributes.work_finish#i#'))>#evaluate('attributes.work_finish#i#')#</cfif>,
					WORK_STATUS = <cfif isdefined('attributes.active#i#')>1<cfelse>0</cfif>,
					UPDATE_DATE = #now()#,
					UPDATE_IP = '#cgi.remote_addr#'
			WHERE
					WORK_ID = #evaluate('attributes.hidden_work_head#i#')#
		</cfquery>
	<cfelse>
		<cfquery name="add_work_gant" datasource="#dsn#">
			INSERT INTO
				PRO_WORKS
				(
				WORK_HEAD,
				WORK_DETAIL,
				PROJECT_ID,
				PROJECT_EMP_ID,
				WORK_PRIORITY_ID,
				RELATED_WORK_ID,
				WORK_CAT_ID,
				TO_COMPLETE,
				WORK_CURRENCY_ID,
				TARGET_START,
				TARGET_FINISH,
				WORK_STATUS,
				RECORD_DATE,
				RECORD_IP
				)
				VALUES
				(
				'#wrk_eval('attributes.work_head#i#')#',
				'#wrk_eval('attributes.work_head#i#')#',
				#attributes.id#,
				<cfif len(evaluate('attributes.study_emp_id#i#'))>#evaluate('attributes.study_emp_id#i#')#</cfif>,
				#evaluate('attributes.priority_cat#i#')#,
				<cfif isdefined('attributes.related#i#') and len(evaluate('attributes.related#i#'))>#evaluate('attributes.related#i#')#<cfelse>NULL</cfif>,
				#evaluate('attributes.work_cat#i#')#,
				<cfif isdefined('attributes.is_complate#i#') and len(evaluate('attributes.is_complate#i#'))>#evaluate('attributes.is_complate#i#')#<cfelse>NULL</cfif>,
				#evaluate('attributes.stage#i#')#,
				#evaluate('attributes.work_start#i#')#,
				#evaluate('attributes.work_finish#i#')#,
				<cfif isdefined('active#i#')>1<cfelse>0</cfif>,
				#now()#,
				'#cgi.remote_addr#'
				)
		</cfquery>
	</cfif>
</cfloop>
<script language="javascript"s>
	window.location.href='<cfoutput>#request.self#?fuseaction=project.upd_work_gant&id=#attributes.id#</cfoutput>';
</script>
