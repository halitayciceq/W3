<cf_get_lang_set module_name="project"><!--- sayfanin en altinda kapanisi var --->
<cfset task_user_email = ''>
<cfset task_cc_email = ''>
<cfparam  name="attributes.estimated_time" default="">
<cfparam  name="attributes.estimated_time_minute" default="">
<cfif not len(attributes.estimated_time)><cfset attributes.estimated_time=0></cfif>
<cfif not len(attributes.estimated_time_minute)><cfset attributes.estimated_time_minute=0></cfif>
<cfset total_time = (attributes.estimated_time*60)+attributes.estimated_time_minute>
<cfif not isdefined('attributes.total_time_hour') or not attributes.total_time_hour gt 0><cfset attributes.total_time_hour=0></cfif>
<cfif not isdefined('attributes.total_time_minute') or not attributes.total_time_minute gt 0><cfset attributes.total_time_minute=0></cfif>
<cfif isdefined('attributes.work_h_start') and len(attributes.work_h_start)><cf_date tarih="attributes.work_h_start"></cfif>
<cfif isdefined('attributes.work_h_finish') and len(attributes.work_h_finish)><cf_date tarih="attributes.work_h_finish"></cfif>
<cf_date tarih="attributes.startdate_plan">
<cf_date tarih="attributes.finishdate_plan">
<cfif isdefined("attributes.predicted_start") and len(attributes.predicted_start)>
	<cf_date tarih="attributes.predicted_start">
	<cfset attributes.predicted_start = date_add('h',attributes.predicted_start_hour - session.ep.time_zone, attributes.predicted_start)>
</cfif>
<cfif isdefined("attributes.predicted_finish") and len(attributes.predicted_finish)>
	<cf_date tarih="attributes.predicted_finish">
	<cfset attributes.predicted_finish = date_add('h',attributes.predicted_finish_hour - session.ep.time_zone, attributes.predicted_finish)>
</cfif> 
<cfif isdefined('attributes.terminate_date') and len(attributes.terminate_date)>
	<cf_date tarih="attributes.terminate_date">
	<cfset attributes.terminate_date=date_add("h",attributes.terminate_hour - session.ep.time_zone, attributes.terminate_date)>
</cfif>
<cfscript>
	if(isdefined('attributes.work_h_start') and len(attributes.work_h_start))
		attributes.work_h_start = date_add('h', attributes.start_hour - session.ep.time_zone, attributes.work_h_start);
	if(isdefined('attributes.work_h_finish') and len(attributes.work_h_finish))
		attributes.work_h_finish = date_add('h', attributes.finish_hour - session.ep.time_zone, attributes.work_h_finish);
	if(isDefined("attributes.start_hour_plan") and len(attributes.start_hour_plan))
		attributes.startdate_plan = date_add('h', attributes.start_hour_plan - session.ep.time_zone, attributes.startdate_plan);
	if(isDefined("attributes.finish_hour_plan") and len(attributes.finish_hour_plan))
		attributes.finishdate_plan = date_add('h', attributes.finish_hour_plan - session.ep.time_zone, attributes.finishdate_plan);
</cfscript>
		
<cflock name="#CREATEUUID()#" timeout="20">
<cftransaction>
	<cfquery name="GET_WORK_DETAIL" datasource="#DSN#">
		SELECT
			WORK_CURRENCY_ID,
			WORK_PRIORITY_ID,
			TARGET_START,
			TARGET_FINISH,
			WORK_CAT_ID,
			<cfif isDefined('WORK_CAT') and len(WORK_CAT)>
				WORK_CAT,
			</cfif>
			PROJECT_ID,
			OUTSRC_CMP_ID,
			OUTSRC_PARTNER_ID,
			PROJECT_EMP_ID,
			WORK_HEAD,
			TOTAL_TIME_HOUR,
			TOTAL_TIME_MINUTE,
			RECORD_AUTHOR,
			RECORD_DATE,
			RELATED_WORK_ID,
			ESTIMATED_TIME
		FROM
			PRO_WORKS
		WHERE
			WORK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.work_id#">
	</cfquery>
	<cfif isdefined("attributes.xml_time_duration_stage_update") and attributes.xml_time_duration_stage_update neq 1>
		<cfif GET_WORK_DETAIL.estimated_time neq total_time and (IsDefined("attributes.xml_is_all_estimated") and (not ListFind(attributes.xml_is_all_estimated,session.ep.position_code,',')))>
			<script type="text/javascript">
				alert("<cf_get_lang dictionary_id='65552.Veri Güvenliği İhlali Yaptınız'>");
			</script>
			<cfabort>
		</cfif>
	</cfif>
	<cfquery name="DEL_RELATED_WORKS" datasource="#DSN#">
		DELETE FROM PRO_WORK_RELATIONS WHERE WORK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.work_id#">
	</cfquery>
	<cfquery name = "GET_CAT_RD_SSK" datasource = "#dsn#">
		SELECT IS_RD_SSK FROM PRO_WORK_CAT WHERE WORK_CAT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.pro_work_cat#">  
	</cfquery>
	<cfif isdefined("attributes.rel_work") and attributes.rel_work contains(";")>
		<cfset related_work_ids ="">			<!--- Iliskili islerin listesi --->
		<cfset related_work_types ="">			<!--- Iliskili is tipleri listesi --->
		<cfset related_work_lags ="">			<!--- Iliskili is gecikmeleri listesi --->
		<cfloop list="#attributes.rel_work#" delimiters=";" index="i">
			<cfif i contains "days"><!--- gecikme varsa--->
				<cfset i_=listgetat(i,1,'+')>
			<cfelse>
				<cfset i_=i>
			</cfif>
			<cfset work_id = left(i_,len(i_)-2)>
			<cfset work_relation_type = right(i_,2)>
			<cfif i contains "days">
				<cfset lag=left(listgetat(i,2,'+'),find(" ",listgetat(i,2,'+'))-1)> 
			<cfelse>
				<cfset lag = "">
			</cfif>
			<cfset related_work_ids = listappend(related_work_ids,work_id)><!--- is id si --->
			<cfset related_work_types = listappend(related_work_types,work_relation_type)><!--- iliski sekli --->
			<cfif len(lag)>
				<cfset related_work_lags = listappend(related_work_lags,lag)><!--- gecikme --->
			</cfif>
		</cfloop>
	<cfelse>
		<cfset related_work_ids =isdefined("attributes.rel_work") ? attributes.rel_work : "">
		<cfset related_work_types=''>
		<cfset related_work_lags=''>
	</cfif>
	<cfif isdefined("related_work_ids") and len(related_work_ids)>
		<cfloop from="1" to="#listlen(related_work_ids)#" index="k">
			<cfquery name="ADD_PRO_WORK_RELATIONS" datasource="#DSN#">
				INSERT INTO
					PRO_WORK_RELATIONS
					(
						WORK_ID,
						PRE_ID,
						RELATION_TYPE,
						LAG
					)
					VALUES
					(
						<cfqueryparam cfsqltype="cf_sql_integer" value="#form.work_id#">,
						<cfqueryparam cfsqltype="cf_sql_integer" value="#listgetat(related_work_ids,k)#">,
						<cfif len(related_work_types)>
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#listgetat(related_work_types,k)#">
						<cfelse>
							NULL
						</cfif>,
						<cfif len(related_work_lags) and  k lte listlen(related_work_lags) and len(listgetat(related_work_lags,k))>
							<cfqueryparam cfsqltype="cf_sql_integer" value="#listgetat(related_work_lags,k)#">
						<cfelse>
							NULL
						</cfif>
						)
			</cfquery>
		</cfloop>
	</cfif>
	<cfif isdefined("attributes.is_mail") and len(form.project_emp_id)>
		<cfinclude template="get_work_pos.cfm">
		<cfset task_user_email=get_pos.employee_email>
	</cfif>
	<cfif isdefined("attributes.first_work_detail") and len(attributes.first_work_detail)>
		<cfquery name="UPD_PRO_WORKS_DETAİL" datasource="#DSN#">
			UPDATE 
				PRO_WORKS_HISTORY 
			SET
				WORK_DETAIL = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.work_detail#">
			WHERE 
				HISTORY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.first_work_detail#">
		</cfquery>
	<cfelse>
	<cfquery name="ADD_WORK_HISTORY" datasource="#DSN#">
		INSERT INTO
			PRO_WORKS_HISTORY
		(
			SERVICE_ID,
			G_SERVICE_ID,
			OUR_COMPANY_ID,
			WORK_STATUS,
			WORK_CAT_ID,
			WORK_NO,
			WORK_ID,
			WORK_HEAD,
			WORK_DETAIL,
			ESTIMATED_TIME,
			RELATED_WORK_ID,
			PROJECT_EMP_ID,
			OUTSRC_CMP_ID,
			OUTSRC_PARTNER_ID,
			PROJECT_ID,
			COMPANY_ID,
			COMPANY_PARTNER_ID,
			CONSUMER_ID,
			REAL_START,
			REAL_FINISH,
			WORK_CURRENCY_ID,
			WORK_PRIORITY_ID,
			TOTAL_TIME_HOUR,
			TOTAL_TIME_MINUTE,
			TO_COMPLETE,
			UPDATE_DATE,
			UPDATE_AUTHOR,
			IS_MILESTONE,
			TARGET_START,
			TARGET_FINISH,
			RELATION_TYPE,
			ACTIVITY_ID,
			PBS_ID,
			PREDICTED_START,
			PREDICTED_FINISH,
			DURATION,
			SPECIAL_DEFINITION_ID,
			FORUM_REPLY_ID,
			COMPLETED_AMOUNT,
			AVERAGE_AMOUNT,
			AVERAGE_AMOUNT_UNIT
		)
		VALUES
		(
			<cfif len(attributes.service_id)>#attributes.service_id#<cfelse>NULL</cfif>,
			<cfif len(attributes.g_service_id)>#attributes.g_service_id#<cfelse>NULL</cfif>,
			#attributes.our_company_id#,
			<cfif isDefined("form.work_status")>1<cfelse>0</cfif>,
			#attributes.pro_work_cat#,
			<cfif isDefined("attributes.work_no") and len(attributes.work_no)><cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.work_no#"><cfelse>NULL</cfif>,
			#attributes.work_id#,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.work_head#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.work_detail#">,
			<cfif len(total_time)>#total_time#<cfelse>NULL</cfif>,
			<cfif isdefined("form.rel_work") and len(form.rel_work)><cfqueryparam cfsqltype="cf_sql_varchar" value="#form.rel_work#"><cfelse>NULL</cfif>,
			<cfif len(form.project_emp_id)>
				#form.project_emp_id#,
				NULL,
				NULL,
			<cfelseif len(attributes.task_company_id)>
				NULL,
				#attributes.task_company_id#,
				<cfif len(form.task_partner_id)>#form.task_partner_id#<cfelse>NULL</cfif>,
			<cfelse>
				NULL,
				NULL,
				NULL,
			</cfif>
			<cfif len(form.project_id) and len(form.project_head)>#attributes.project_id#<cfelse>NULL</cfif>,
			<cfif len(attributes.company_id) and len(attributes.company_partner_id) and len(form.about_company)>
				#attributes.company_id#,
				#attributes.company_partner_id#,
				NULL,
			<cfelseif not len(attributes.company_id) and len(attributes.company_partner_id) and len(form.about_company)>
				NULL,
				NULL,
				#attributes.company_partner_id#,
			<cfelse>
				NULL,
				NULL,
				NULL,
			</cfif>
			<cfif isdefined("attributes.work_h_start") and len(attributes.work_h_start)>#attributes.work_h_start#,<cfelse>NULL,</cfif>
			<cfif isdefined("attributes.work_h_finish") and len(attributes.work_h_finish)>#attributes.work_h_finish#,<cfelse>NULL,</cfif>
			#attributes.process_stage#,
			#attributes.priority_cat#,
			<cfif isDefined("attributes.total_time_hour") and len(attributes.total_time_hour)>#attributes.total_time_hour#<cfelse>NULL</cfif>,
			<cfif isDefined("attributes.total_time_minute") and len(attributes.total_time_minute)>#attributes.total_time_minute#<cfelse>NULL</cfif>,
			<cfif isdefined("attributes.to_complate") and len(attributes.to_complate)>#attributes.to_complate#<cfelse>NULL</cfif>,
			#now()#,
			#session.ep.userid#,
			<cfif isDefined("form.is_milestone") and len(form.is_milestone)>1<cfelse>0</cfif>,
			#attributes.startdate_plan#,
			#attributes.finishdate_plan#,
			<cfif isdefined('attributes.work_relation_date') and len(attributes.work_relation_date)>#attributes.work_relation_date#<cfelse>NULL</cfif>,
			<cfif len(attributes.activity_type)>#attributes.activity_type#<cfelse>NULL</cfif>,
			<cfif isdefined('attributes.pbs_id') and len(attributes.pbs_id)>#attributes.pbs_id#<cfelse>NULL</cfif>,
			<cfif isDefined("attributes.predicted_start") and len(attributes.predicted_start)>#attributes.predicted_start#<cfelse>NULL</cfif>,
			<cfif isDefined("attributes.predicted_finish") and len(attributes.predicted_finish)>#attributes.predicted_finish#<cfelse>NULL</cfif>,
			<cfif isDefined("attributes.duration") and len(attributes.duration)><cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.duration#"><cfelse>NULL</cfif>,
			<cfif isdefined("attributes.special_definition") and len(attributes.special_definition)>#attributes.special_definition#<cfelse>NULL</cfif>,
			<cfif isdefined("attributes.forum_reply_id") and len(attributes.forum_reply_id)>#attributes.forum_reply_id#<cfelse>NULL</cfif>,
			<cfif isdefined('attributes.completed_amount') and len(attributes.completed_amount)><cfqueryparam cfsqltype="cf_sql_float" value="#attributes.completed_amount#"><cfelse>NULL</cfif>,
			<cfif isdefined('attributes.average_amount') and len(attributes.average_amount)><cfqueryparam cfsqltype="cf_sql_float" value="#attributes.average_amount#"><cfelse>NULL</cfif>,
			<cfif isdefined('attributes.amount_unit') and len(attributes.amount_unit)>#attributes.amount_unit#<cfelse>NULL</cfif>
		)
	</cfquery>
	</cfif>
	<cfquery name="UPD_PRO_WORKS" datasource="#DSN#">
		UPDATE 
			PRO_WORKS 
		SET 
			WORK_NO = <cfif isDefined("attributes.work_no") and len(attributes.work_no)><cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.work_no#"><cfelse>NULL</cfif>,
			WORK_CAT_ID = #attributes.pro_work_cat#,
			RELATED_WORK_ID = <cfif isdefined("form.rel_work") and len(form.rel_work)><cfqueryparam cfsqltype="cf_sql_varchar" value="#form.rel_work#"><cfelse>NULL</cfif>,            
			WORK_STATUS = <cfif isDefined("form.work_status")>1<cfelse>0</cfif>,
			IS_MILESTONE = <cfif isDefined("form.is_milestone") and len(form.is_milestone)>1<cfelse>0</cfif>,
			MILESTONE_WORK_ID = <cfif isDefined("attributes.milestone_work_id") and len(attributes.milestone_work_id)>#attributes.milestone_work_id#<cfelse>NULL</cfif>,
			ESTIMATED_TIME = <cfif len(total_time)>#total_time#,<cfelse>NULL,</cfif>
			TOTAL_TIME_HOUR = <cfif isdefined("attributes.total_time_hour") and len(attributes.total_time_hour)>#attributes.total_time_hour#<cfelse>NULL</cfif>,
			TOTAL_TIME_MINUTE = <cfif isdefined("attributes.total_time_minute") and len(attributes.total_time_minute)>#attributes.total_time_minute#<cfelse>NULL</cfif>,	
			EXPECTED_BUDGET=<cfif isDefined("form.expected_budget") and len(form.expected_budget)><cfqueryparam cfsqltype="cf_sql_float" value="#form.expected_budget#"><cfelse>NULL</cfif>,
			EXPECTED_BUDGET_MONEY = <cfif isDefined("form.expected_budget_money") and len(form.expected_budget_money)><cfqueryparam cfsqltype="cf_sql_varchar" value="#EXPECTED_BUDGET_MONEY#"><cfelse>NULL</cfif>,
			PROJECT_ID = <cfif len(form.project_id) and len(form.project_head)>#form.project_id#<cfelse>NULL</cfif>,
		<cfif len(form.project_emp_id)>
			PROJECT_EMP_ID = #form.project_emp_id#,
			OUTSRC_CMP_ID = NULL,
			OUTSRC_PARTNER_ID = NULL,
		<cfelseif len(form.task_partner_id)>
			OUTSRC_CMP_ID = #form.task_company_id#,
			OUTSRC_PARTNER_ID = #form.task_partner_id#,
			PROJECT_EMP_ID = NULL,
		</cfif>	
			COMPANY_ID = <cfif len(form.company_id)>#form.company_id#<cfelse>NULL</cfif>,
			COMPANY_PARTNER_ID = <cfif len(form.company_id) and len(form.company_partner_id) and len(form.about_company)>#form.company_partner_id#<cfelse>NULL</cfif>,
			CONSUMER_ID = <cfif not len(form.company_id) and len(form.company_partner_id)>#form.company_partner_id#<cfelse>NULL</cfif>,
			WORKGROUP_ID = <cfif len(attributes.workgroup_id)>#attributes.workgroup_id#<cfelse>NULL</cfif>,
			WORK_HEAD = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.work_head#">,
			WORK_DETAIL = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.work_detail#">,
			REAL_START = <cfif isdefined("attributes.work_h_start") and len(attributes.work_h_start)>#attributes.work_h_start#<cfelse>NULL</cfif>,
			REAL_FINISH = <cfif isdefined("attributes.work_h_finish") and len(attributes.work_h_finish)>#attributes.work_h_finish#<cfelse>NULL</cfif>,
			TERMINATE_DATE = <cfif isdefined('attributes.terminate_date') and len(attributes.terminate_date)>#attributes.terminate_date#<cfelse>NULL</cfif>,
			WORK_CURRENCY_ID = #attributes.process_stage#,
			WORK_PRIORITY_ID = #form.priority_cat#,
			COMPLETED_AMOUNT = <cfif isdefined('attributes.completed_amount') and len(attributes.completed_amount)><cfqueryparam cfsqltype="cf_sql_float" value="#attributes.completed_amount#"><cfelse>NULL</cfif>,
			TO_COMPLETE = #attributes.to_complate#,
			UPDATE_AUTHOR = #session.ep.userid#,
			UPDATE_DATE = #now()#,
			UPDATE_IP = <cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.remote_addr#">,
			TARGET_START = #attributes.startdate_plan#,
			TARGET_FINISH = #attributes.finishdate_plan#,
			RELATION_TYPE = <cfif isdefined('attributes.work_relation_date') and len(attributes.work_relation_date)>#attributes.work_relation_date#<cfelse>NULL</cfif>,
			ACTIVITY_ID = <cfif len(attributes.activity_type)>#attributes.activity_type#<cfelse>NULL</cfif>,
			PBS_ID = <cfif isdefined('attributes.pbs_id') and len(attributes.pbs_id)>#attributes.pbs_id#<cfelse>NULL</cfif>,
			REWORK = <cfif isDefined("attributes.rework")>1<cfelse>0</cfif>,
			PREDICTED_START = <cfif isDefined("attributes.predicted_start") and len(attributes.predicted_start)>#attributes.predicted_start#<cfelse>NULL</cfif>,
			PREDICTED_FINISH = <cfif isDefined("attributes.predicted_finish") and len(attributes.predicted_finish)>#attributes.predicted_finish#<cfelse>NULL</cfif>,
			DURATION = <cfif isDefined("attributes.duration") and len(attributes.duration)><cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.duration#"><cfelse>NULL</cfif>,
			<cfif isdefined("attributes.special_definition") and len(attributes.special_definition)>SPECIAL_DEFINITION_ID = #attributes.special_definition#,</cfif>
			AVERAGE_AMOUNT = <cfif isdefined('attributes.average_amount') and len(attributes.average_amount)><cfqueryparam cfsqltype="cf_sql_float" value="#attributes.average_amount#"><cfelse>NULL</cfif>,
			AVERAGE_AMOUNT_UNIT = <cfif isdefined('attributes.amount_unit') and len(attributes.amount_unit)>#attributes.amount_unit#<cfelse>NULL</cfif>,
			SALE_CONTRACT_AMOUNT = <cfif isdefined('attributes.sale_contract_amount') and len(attributes.sale_contract_amount)><cfqueryparam cfsqltype="cf_sql_float" value="#attributes.sale_contract_amount#"><cfelse>NULL</cfif>,
			PURCHASE_CONTRACT_AMOUNT = <cfif isdefined('attributes.purchase_contract_amount') and len(attributes.purchase_contract_amount)><cfqueryparam cfsqltype="cf_sql_float" value="#attributes.purchase_contract_amount#"><cfelse>NULL</cfif>,
			WORK_CIRCUIT = <cfqueryparam cfsqltype="cf_sql_varchar" value="#listfirst(attributes.work_fuse,".")#">,
			WORK_FUSEACTION = <cfqueryparam cfsqltype="cf_sql_varchar" value="#listlast(attributes.work_fuse,".")#">
		WHERE 
			PRO_WORKS.WORK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.work_id#">
	</cfquery>   
	<!--- modified:Özcan 20120808 İlişki iş tarih bağlantıları İş Id:45741--->
	<cfif GET_WORK_DETAIL.RELATED_WORK_ID neq attributes.rel_work>
		<cfif isdefined("related_work_ids") and related_work_ids neq 0 and len(related_work_ids) and len(related_work_types)>
			<cfloop from="1" to="#listlen(related_work_ids)#" index="k">
				<cfquery name="getDate" datasource="#dsn#">
					SELECT TARGET_START,TARGET_FINISH FROM PRO_WORKS WHERE WORK_ID=<cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.work_id#">
				</cfquery>
				<cfquery name="get_relDate" datasource="#dsn#">
					SELECT TARGET_START,TARGET_FINISH,DATEDIFF("D",TARGET_START,TARGET_FINISH)AS FARK FROM PRO_WORKS WHERE WORK_ID=<cfqueryparam cfsqltype="cf_sql_integer" value="#listgetat(related_work_ids,k)#">
				</cfquery>
				<cfset related_work_types_row = listgetat(related_work_types,k)><!--- iliski sekli : A ana is B iliskili is --->
				<cfif related_work_types_row eq 'FS'>							<!--- A işi bittikten sonra B işi başlar --->
						<cfset work_start_date = getDate.TARGET_FINISH>
						<cfset work_finish_date = dateadd('d',get_relDate.FARK,getDate.TARGET_FINISH)>
				<cfelseif  listgetat(related_work_types,k) eq 'SS'>				<!--- B işi A başlamadan başlayamaz  --->
						<cfset work_start_date = getDate.TARGET_START>
						<cfset work_finish_date = dateadd('d',get_relDate.FARK,getDate.TARGET_START)>
				<cfelseif  listgetat(related_work_types,k) eq 'FF'>				<!--- B isi A isi bitmeden bitemez (bitis tarihleri aynı +- bekleme )--->
						<cfset work_start_date = dateadd('d',-get_relDate.FARK,getDate.TARGET_FINISH)>
						<cfset work_finish_date = getDate.TARGET_FINISH>
				<cfelseif listgetat(related_work_types,k) eq 'SF'>				<!--- B isi A isi bitmeden baslayamaz --->
						<cfset work_start_date = dateadd('d',-get_relDate.FARK,getDate.TARGET_START)>
						<cfset work_finish_date = getDate.TARGET_START>
				</cfif>
				
					<cfif listlen(related_work_lags)>
					<cfset lag_ = listgetat(related_work_lags,k)>
						<cfif len(lag_)>
						<cfset work_start_date = dateadd('d',lag_,work_start_date)>
							<cfset work_finish_date = dateadd('d',get_relDate.FARK,work_start_date)>
					</cfif>
				</cfif>
				<cfquery name="setDate" datasource="#DSN#">
					UPDATE PRO_WORKS SET TARGET_START = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#work_start_date#">,TARGET_FINISH=<cfqueryparam cfsqltype="cf_sql_timestamp" value="#work_finish_date#"> WHERE WORK_ID=<cfqueryparam cfsqltype="cf_sql_integer" value="#listgetat(related_work_ids,k)#">
				</cfquery>
				
					<!--- <cfoutput>#setWork(listgetat(related_work_ids,k))#</cfoutput> --->
			</cfloop>
		</cfif>
	</cfif>
	<!--- FA20070226 zaman harcamasi ekleniyor --->
	<cfif (attributes.total_time_hour gt 0 or attributes.total_time_minute gt 0)>
		<cfquery name="get_hourly_salary" datasource="#DSN#">
			SELECT ISNULL(ON_MALIYET,0) ON_MALIYET, ISNULL(ON_HOUR,0) ON_HOUR FROM EMPLOYEE_POSITIONS WHERE POSITION_CODE = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.position_code#">
		</cfquery>
		
		<cfquery name="get_process_stage" datasource="#dsn#" maxrows="1">
			SELECT
				PTR.PROCESS_ROW_ID 
			FROM
				PROCESS_TYPE_ROWS PTR,
				PROCESS_TYPE_OUR_COMPANY PTO,
				PROCESS_TYPE PT
			WHERE
				PT.IS_ACTIVE = 1 AND
				PT.PROCESS_ID = PTR.PROCESS_ID AND
				PT.PROCESS_ID = PTO.PROCESS_ID AND
				PTO.OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#"> AND
				PT.FACTION LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%myhome.time_cost%">
			ORDER BY
				PTR.LINE_NUMBER
		</cfquery>
		<cfif get_hourly_salary.recordcount and get_hourly_salary.on_maliyet eq 0 or get_hourly_salary.on_hour eq  0>
			<cfif session.ep.time_cost_control eq 1 and ListFind("1,2",session.ep.time_cost_control_type,",")>
				<script type="text/javascript">
					alert("<cf_get_lang no ='325.İnsan Kaynakları Bölümü Pozisyon Çalışma Maliyetiniz Belirtilmemiş'> !");
					history.back();
				</script>
				<cfabort>
			<cfelse>
				<cfset salary_minute = 0>	
			</cfif>
		<cfelse>
			<cfset salary_minute = get_hourly_salary.on_maliyet / get_hourly_salary.on_hour / 60>
		</cfif>
		<cfset topson_=(attributes.total_time_hour*60)+attributes.total_time_minute>
		<cfset topson=topson_/60>
		<cfquery name="time_total" datasource="#DSN#">
			SELECT
				SUM(EXPENSED_MINUTE) AS TOTAL_TIME
			FROM
				TIME_COST
			WHERE
				EMPLOYEE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#"> AND
				EVENT_DATE > <cfqueryparam cfsqltype="cf_sql_timestamp" value="#date_add('d',-1,now())#"> AND 
				EVENT_DATE <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
		</cfquery>
		<cfif time_total.recordcount and len(time_total.total_time)>
			<cfset xx=(time_total.total_time/60) + topson>
		<cfelse>
			<cfset xx=topson>
		</cfif>
		<cfif isdefined('x_timecost_limited') and x_timecost_limited eq 0>
			<cfif xx gt 24>
				<script type="text/javascript">
					alert("<cf_get_lang no ='326.Bir Gün İçinde 24 Saatten Fazla Zaman Harcaması Girilemez'>!");
					return false;
				</script>
				<cfabort>
			</cfif>
		</cfif>
		<!--- etkilesim sayfasindaki sistem bilgisini getirir --->
		<cfquery name="get_cus_help_det" datasource="#dsn#">
			SELECT CH.SUBSCRIPTION_ID,CH.CUS_HELP_ID FROM PRO_WORKS PW,CUSTOMER_HELP CH WHERE CH.CUS_HELP_ID = PW.CUS_HELP_ID AND PW.WORK_ID = #attributes.work_id#
		</cfquery>
		<!--- //etkilesim sayfasindaki sistem bilgisini getirir --->
		<cfset total_min=(attributes.total_time_hour*60)+attributes.total_time_minute>
		<cfset para=round(salary_minute*total_min)>		
		<cfif len(form.project_id)>
			<cfquery name="get_cost_total" datasource="#dsn#"  >
				SELECT DISTINCT 
					WG.PROJECT_ID,
					WEP.EMPLOYEE_ID,
					WEP.OUR_COMPANY_ID,
					ISNULL(WEP.COST_PRICE ,0) AS COST_PRICE
				FROM		
					WORK_GROUP AS WG 
					   LEFT JOIN  WORKGROUP_EMP_PAR AS WEP ON  WG.WORKGROUP_ID = WEP.WORKGROUP_ID 
				WHERE
					WEP.PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.project_id#"> AND 
					WEP.EMPLOYEE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#"> AND 
					WEP.OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#">
			</cfquery>
			<cfif  len(get_cost_total.EMPLOYEE_ID) and  get_cost_total.COST_PRICE neq 0>
				<cfset COST_PRICE_ = get_cost_total.COST_PRICE * total_min /60>
			<cfelse>
				<cfif isdefined("attributes.xml_waste_of_time") and  attributes.xml_waste_of_time neq 0>
					<script type="text/javascript">
						alert("<cf_get_lang dictionary_id='65601.Bu projede harcayacağınız zaman 0 çarpanla değerlendirilecektir. Proje Yöneticisine bildirmelisiniz.'>");
					</script>
					<cfset COST_PRICE_ = 0>
				<cfelse>
					<cfset COST_PRICE_ = para>
				</cfif>
			</cfif>
		</cfif>
		<cfquery name="ADD_TIME_COST" datasource="#DSN#">
			INSERT INTO
				TIME_COST
			(
				OUR_COMPANY_ID,
				CRM_ID,
				SERVICE_ID,
				WORK_ID,
				COMPANY_ID,
				PARTNER_ID,
				CUS_HELP_ID,
				SUBSCRIPTION_ID,
				PROJECT_ID,
				TOTAL_TIME,
				ESTIMATED_TIME,
				EXPENSED_MONEY,
				EXPENSED_MINUTE,
				EMPLOYEE_ID,
				EVENT_DATE,
				COMMENT,
				ACTIVITY_ID,
				FORUM_REPLY_ID,
				TIME_COST_STAGE,
				IS_RD_SSK,
				RECORD_DATE,
				RECORD_IP,
				RECORD_EMP
			)
			VALUES
			(
				#session.ep.company_id#,
				<cfif isdefined("attributes.g_service_id") and len(attributes.g_service_id)>#attributes.g_service_id#<cfelse>NULL</cfif>,
				<cfif isdefined("attributes.service_id") and len(attributes.service_id)>#attributes.service_id#<cfelse>NULL</cfif>,
				#attributes.work_id#,
				<cfif len(attributes.company_id)>#attributes.company_id#<cfelse>NULL</cfif>,
				<cfif len(attributes.company_partner_id)>#attributes.company_partner_id#<cfelse>NULL</cfif>,
				<cfif isdefined('get_cus_help_det.cus_help_id') and len(get_cus_help_det.cus_help_id)>#get_cus_help_det.cus_help_id#<cfelse>NULL</cfif>,
				<cfif isdefined('get_cus_help_det.SUBSCRIPTION_ID') and len(get_cus_help_det.SUBSCRIPTION_ID)>#get_cus_help_det.SUBSCRIPTION_ID#<cfelse>NULL</cfif>,
				<cfif len(form.project_id) and len(form.project_head)>#attributes.project_id#<cfelse>NULL</cfif>,
				#topson#,
				<cfif len(total_time)>#total_time#<cfelse>NULL</cfif>,
				<cfif len(attributes.project_id)>#round( COST_PRICE_)# <cfelse>#PARA#</cfif>,
				#TOTAL_MIN#,
				#session.ep.userid#,
				#now()#,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#get_work_detail.work_head#">,
				<cfif len(attributes.activity_type)>#attributes.activity_type#<cfelse>NULL</cfif>,
				<cfif isdefined("attributes.forum_reply_id") and len(attributes.forum_reply_id)>#attributes.forum_reply_id#<cfelse>NULL</cfif>,
				<cfif isdefined('get_process_stage.process_row_id') and len(get_process_stage.process_row_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#get_process_stage.process_row_id#"><cfelse>NULL</cfif>,
				<cfif isdefined("GET_CAT_RD_SSK.IS_RD_SSK") and GET_CAT_RD_SSK.IS_RD_SSK eq 1>1<cfelse>0</cfif>,
				#now()#,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.remote_addr#">,
				#session.ep.userid#
			)
		</cfquery>
	</cfif>

	<!--- <cfif cgi.server_port eq 443>
		<cfset user_domain = "https://#cgi.server_name#">
	<cfelse>
		<cfset user_domain = "http://#cgi.server_name#">
	</cfif> --->
	<cfif len(attributes.project_id)>
		<cfquery name="Get_Project_Head" datasource="#dsn#">
				SELECT PROJECT_NUMBER, PROJECT_HEAD FROM PRO_PROJECTS WHERE PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.project_id#">
		</cfquery>
		<cfset attributes.project_head='#Get_Project_Head.Project_Head#'>
		<cfset attributes.project_id=attributes.project_id>
	</cfif>
	<cfset attributes.mail_content_from = isdefined("attributes.project_head") and len(attributes.project_head) ? '#attributes.project_head#<#session.ep.company_email#>' : '#session.ep.company_nick#<#session.ep.company_email#>'><!--- Ortak Mail From --->

	<cfset attributes.cc_email_list = ''>
	<cfif isDefined("attributes.cc_par_ids") and ListLen(attributes.cc_par_ids)>
		<cfquery name="get_cc_mail" datasource="#dsn#">
			SELECT CP.COMPANY_PARTNER_NAME + ' ' + CP.COMPANY_PARTNER_SURNAME AS NAME_SURNAME FROM COMPANY_PARTNER CP WHERE PARTNER_ID IN (<cfqueryparam cfsqltype="cf_sql_nvarchar" value="#attributes.cc_par_ids#" list="yes">)
		</cfquery>
		<cfset attributes.cc_email_list =listappend(attributes.cc_email_list,valueList(get_cc_mail.NAME_SURNAME))>
	</cfif>
	<cfif isDefined("attributes.cc_emp_ids") and ListLen(attributes.cc_emp_ids)>
		<cfquery name="get_cc_mail" datasource="#dsn#">
			SELECT EP.EMPLOYEE_NAME + ' ' + EP.EMPLOYEE_SURNAME AS NAME_SURNAME FROM EMPLOYEES EP WHERE EMPLOYEE_ID IN (<cfqueryparam cfsqltype="cf_sql_nvarchar" value="#attributes.cc_emp_ids#" list="yes">)
		</cfquery>
		<cfset attributes.cc_email_list =listappend(attributes.cc_email_list,valueList(get_cc_mail.NAME_SURNAME))>
	</cfif>
	
	<cfif len(task_user_email)>
		<cfif get_work_detail.project_emp_id neq attributes.project_emp_id>
			<cfset mail_type_id = 1>
		<cfelse>
			<cfset mail_type_id = 2>
		</cfif>
		
		<cfset mail_emp_id = attributes.project_emp_id>
		<cfsavecontent variable="message">
				<cfif mail_type_id eq 1><cf_get_lang dictionary_id='58445.iş kaydı'><cfelseif mail_type_id eq 2><cf_get_lang dictionary_id='29542.bilgilendirme'></cfif>
		</cfsavecontent>
		<cfsavecontent variable="additor">
			<cfoutput>
				<cfif isdefined('attributes.task_partner_id') and len(attributes.task_partner_id)>
					#get_par_info(attributes.task_partner_id,0,0,0)#
				<cfelseif isdefined('attributes.project_emp_id') and len(attributes.project_emp_id)>
					#get_emp_info(attributes.project_emp_id,0,0)#
				</cfif>
			</cfoutput>
		</cfsavecontent>
		
		<cfsavecontent variable="subject_info">
			<cfif mail_type_id eq 1>
				<cf_get_lang dictionary_id="29525.Görevlendirme">
			<cfelseif mail_type_id eq 2>
				<cf_get_lang dictionary_id='29542.Bilgilendirme'>
			</cfif>
		</cfsavecontent>
		<cfset attributes.mail_content_to = task_user_email>
		<cfset attributes.mail_content_subject = subject_info & '! - ' & attributes.work_head>
		<cfset attributes.mail_content_additor = '#additor#'>
		<cfset attributes.mail_staff = '#form.responsable_name#'>
		<cfset attributes.cc_name_list = '#attributes.cc_email_list#'>
		<cfset attributes.mail_record_emp=GET_WORK_DETAIL.RECORD_AUTHOR>
		<cfset attributes.mail_record_date=dateformat(date_add("h",session.ep.time_zone,GET_WORK_DETAIL.RECORD_DATE),dateformat_style)& " " & TimeFormat(date_add("h",session.ep.time_zone,GET_WORK_DETAIL.RECORD_DATE),timeformat_style)>
		<cfset attributes.mail_update_emp='#session.ep.name# #session.ep.surname#'>
		<cfset attributes.mail_update_date=dateformat(dateadd('h',session.ep.time_zone,now()),dateformat_style) & " " & timeformat(dateadd('h',session.ep.time_zone,now()),timeformat_style)>
		<cfset attributes.start_date=dateformat(date_add("h",session.ep.time_zone,attributes.startdate_plan),dateformat_style)& " " & TimeFormat(date_add("h",session.ep.time_zone,attributes.startdate_plan),timeformat_style)>
		<cfset attributes.finish_date=dateformat(date_add("h",session.ep.time_zone,attributes.finishdate_plan),dateformat_style)& " " & TimeFormat(date_add("h",session.ep.time_zone,attributes.finishdate_plan),timeformat_style)>
		<cfset attributes.mail_content_info2='#attributes.work_detail#'>
		<cfsavecontent variable="attributes.mail_content_info"><cfoutput>#message#</cfoutput></cfsavecontent>
		<cfif len(mail_emp_id)>
			<cfset attributes.mail_content_link = '#user_domain#/#request.self#?fuseaction=project.works&event=det&id=#attributes.work_id#'>
		<cfelse>
			<cfset attributes.mail_content_link = '#partner_domain##request.self#?fuseaction=project.works&event=det&id=#attributes.work_id#'>
		</cfif>
		<cfset attributes.mail_content_link_info = '#attributes.work_head#'>
		<cfset attributes.process_stage_info = attributes.process_stage>
	
		<cfinclude template="/design/template/info_mail/mail_content.cfm">
	</cfif>
	<!--- Bilgi Verilecekler --->
	<cfquery name="Del_Work_CC" datasource="#dsn#">
		DELETE FROM PRO_WORKS_CC WHERE WORK_ID = #attributes.work_id#
	</cfquery>
	<cfif isdefined("attributes.cc_par_ids") or isdefined("attributes.cc_emp_ids")>
		<cfif (isdefined("attributes.cc_par_ids") and ListLen(attributes.cc_par_ids)) or (isdefined("attributes.cc_emp_ids") and ListLen(attributes.cc_emp_ids))>
			<cfif isDefined("attributes.cc_emp_ids") and ListLen(attributes.cc_emp_ids)>
				<cfloop list="#attributes.cc_emp_ids#" index="eid">
					<cfquery name="Add_Work_Cc_Emp" datasource="#dsn#">
						INSERT INTO PRO_WORKS_CC (CC_EMP_ID, WORK_ID) VALUES (#eid#, #attributes.work_id#)
					</cfquery>
					<cfif isdefined("attributes.is_mail")>
						<cfset mail_type_id = 2>
						<cfset mail_emp_id = eid>
						<cfquery name="get_cc_mail" datasource="#dsn#">
							SELECT EMPLOYEE_ID,EMPLOYEE_NAME,EMPLOYEE_SURNAME,EMPLOYEE_EMAIL FROM EMPLOYEES WHERE EMPLOYEE_ID = #mail_emp_id#
						</cfquery>
						<cfset task_cc_email = get_cc_mail.employee_email>
						<cfif Len(task_cc_email)>
							<!---    CC Mail Template Ekliyorum --->
							<cfsavecontent variable="subject_info"><cf_get_lang dictionary_id='29542.bilgilendirme'></cfsavecontent>
							<cfset attributes.mail_content_to = task_cc_email>
							<cfset attributes.mail_content_subject = subject_info & '! - ' & attributes.work_head>
							<cfset attributes.mail_content_additor ='#get_cc_mail.EMPLOYEE_NAME# #get_cc_mail.EMPLOYEE_SURNAME#'>
							<cfset attributes.mail_staff = '#form.responsable_name#'>
							<cfset attributes.cc_name_list = '#attributes.cc_email_list#'>
							<cfset attributes.mail_record_emp=GET_WORK_DETAIL.RECORD_AUTHOR>
							<cfset attributes.mail_record_date=dateformat(dateadd('h',session.ep.time_zone,GET_WORK_DETAIL.RECORD_DATE),dateformat_style) & " " & timeformat(dateadd('h',session.ep.time_zone,GET_WORK_DETAIL.RECORD_DATE),timeformat_style)>
							<cfset attributes.mail_update_emp='#session.ep.name# #session.ep.surname#'>
							<cfset attributes.mail_update_date=dateformat(dateadd('h',session.ep.time_zone,now()),dateformat_style) & " " & timeformat(dateadd('h',session.ep.time_zone,now()),timeformat_style)>
							<cfset attributes.start_date= dateformat(date_add("h",session.ep.time_zone,attributes.startdate_plan),dateformat_style) & " " & timeformat(date_add("h",session.ep.time_zone,attributes.startdate_plan),timeformat_style) >
							<cfset attributes.mail_content_info2='#attributes.work_detail#'>
							<cfset attributes.finish_date=dateformat(date_add("h",session.ep.time_zone,attributes.finishdate_plan),dateformat_style) & " " & timeformat(date_add("h",session.ep.time_zone,attributes.finishdate_plan),timeformat_style)>						
							<cfsavecontent variable="attributes.mail_content_info"><cf_get_lang dictionary_id='29542.bilgilendirme'>
							</cfsavecontent>
							<cfif len(mail_emp_id)>
								<cfset attributes.mail_content_link = '#user_domain#/#request.self#?fuseaction=project.works&event=det&id=#attributes.work_id#'>
							<cfelse>
								<cfset attributes.mail_content_link = '#partner_domain##request.self#?fuseaction=project.works&event=det&id=#attributes.work_id#'>
							</cfif>
							<cfset attributes.mail_content_link_info = '#attributes.work_head#'>
							<cfset attributes.process_stage_info = attributes.process_stage>
							<cfinclude template="/design/template/info_mail/mail_content.cfm">
						</cfif>
					</cfif>
				</cfloop>
			</cfif>
			<cfif isDefined("attributes.cc_par_ids") and ListLen(attributes.cc_par_ids)>
				<cfloop list="#attributes.cc_par_ids#" index="pid">
					<cfquery name="Add_Work_Cc_Par" datasource="#dsn#">
						INSERT INTO PRO_WORKS_CC (CC_PAR_ID, WORK_ID) VALUES (#pid#, #attributes.work_id#)
					</cfquery>
					<cfif isdefined("attributes.is_mail")>
						<cfset mail_type_id = 2>
						<cfset mail_emp_id = pid> 
						<cfquery name="get_cc_mail" datasource="#dsn#">
							SELECT PARTNER_ID,COMPANY_PARTNER_NAME,COMPANY_PARTNER_SURNAME,COMPANY_PARTNER_EMAIL AS EMPLOYEE_EMAIL FROM COMPANY_PARTNER WHERE PARTNER_ID = #mail_emp_id#
						</cfquery>
						<cfset task_cc_email = get_cc_mail.employee_email>
						<cfif Len(task_cc_email)>
						<!---    CC Mail Template Ekliyorum --->
							<cfsavecontent variable="subject_info"><cf_get_lang dictionary_id='29542.Bilgilendirme'></cfsavecontent>
							<cfset attributes.mail_content_to = task_cc_email>
							<cfset attributes.mail_content_subject = subject_info & '! - ' & attributes.work_head>
							<cfset attributes.mail_content_additor ='#get_cc_mail.COMPANY_PARTNER_NAME# #get_cc_mail.COMPANY_PARTNER_SURNAME#'>
							<cfset attributes.mail_staff = '#form.responsable_name#'>
							<cfset attributes.cc_name_list = '#attributes.cc_email_list#'>
							<cfset attributes.mail_record_emp=GET_WORK_DETAIL.RECORD_AUTHOR>
							<cfset attributes.mail_record_date=dateformat(dateadd('h',session.ep.time_zone,GET_WORK_DETAIL.RECORD_DATE),dateformat_style) & " " & timeformat(dateadd('h',session.ep.time_zone,GET_WORK_DETAIL.RECORD_DATE),timeformat_style)>
							<cfset attributes.mail_update_emp='#session.ep.name# #session.ep.surname#'>
							<cfset attributes.mail_update_date=dateformat(dateadd('h',session.ep.time_zone,now()),dateformat_style) & " " & timeformat(dateadd('h',session.ep.time_zone,now()),timeformat_style)>
							<cfset attributes.start_date= dateformat(date_add("h",session.ep.time_zone,attributes.startdate_plan),dateformat_style) & " " & timeformat(date_add("h",session.ep.time_zone,attributes.startdate_plan),timeformat_style) >
							<cfset attributes.mail_content_info2='#attributes.work_detail#'>
							<cfset attributes.finish_date=dateformat(date_add("h",session.ep.time_zone,attributes.finishdate_plan),dateformat_style) & " " & timeformat(date_add("h",session.ep.time_zone,attributes.finishdate_plan),timeformat_style)>
							<cfsavecontent variable="attributes.mail_content_info"><cf_get_lang dictionary_id='29542.bilgilendirme'>
							</cfsavecontent>							
							<!--- Eğer mail gönderdiğimiz kişiler partner ise linkler veremeyiz. --->
							<!--- <cfif len(mail_emp_id)>
								<cfset attributes.mail_content_link = '#user_domain#/#request.self#?fuseaction=project.works&event=det&id=#attributes.work_id#'>
							<cfelse>
								<cfset attributes.mail_content_link = '#partner_domain##request.self#?fuseaction=project.works&event=det&id=#attributes.work_id#'>
							</cfif> --->
							<cfset attributes.is_no_partner = 1>
							<cfset attributes.work_id_krp = contentEncryptingandDecodingAES(isEncode:1,content:attributes.work_id,accountKey:"wrk")>
							<cfset attributes.xml_link = attributes.is_xml_link & attributes.work_id_krp>
							<cfset attributes.mail_content_link_info = '#attributes.work_head#'>
							<cfset attributes.process_stage_info = attributes.process_stage>
							<cfinclude template="/design/template/info_mail/mail_content.cfm">
							</cfif>
					</cfif>
				</cfloop>
			</cfif>			
		</cfif>
	</cfif>
	<!--- //Bilgi Verilecekler --->
	<cfif isdefined("attributes.is_mail")>
		<cfset attributes.is_mail = 1>
	<cfelse>
		<cfset attributes.is_mail = 0>
	</cfif>
	<cfset attributes.old_process_line = 1>
	<cf_workcube_process 
		is_upd='1' 
		data_source='#dsn#'
		old_process_line='#attributes.old_process_line#' 
		process_stage='#attributes.process_stage#'
		record_member='#session.ep.userid#' 
		record_date='#now()#' 
		action_table='PRO_WORKS'
		action_column='WORK_ID'
		action_id='#attributes.work_id#'
		action_page='#request.self#?fuseaction=project.works&event=det&id=#attributes.work_id#&is_mail=#attributes.is_mail#' 
		warning_description = '#getLang("","İlgili İş",66816)# : #attributes.work_head#'>
</cftransaction>
</cflock>
<cfif isdefined("attributes.first_work_detail")>
<!---Ek Bilgiler--->
<cfset attributes.info_id =  attributes.work_id>
<cfset attributes.is_upd = 1>
<cfset attributes.info_type_id = -18>
<cfinclude template="../../objects/query/add_info_plus2.cfm">
<!---Ek Bilgiler--->
</cfif>
<cfset attributes.actionID = attributes.work_id>

<script type="text/javascript">
	<cfif cgi.http_referer contains 'popup'>
		function isDefined(variable)
		{
			return (!(!(variable)));
		}
		if(isDefined(window.opener))
		{
			wrk_opener_reload();
			window.close();
		}
		else 
		{
			window.location.href = '<cfoutput>#request.self#?fuseaction=project.list_project_work</cfoutput>';
		}
	<cfelseif isdefined("attributes.is_det") and attributes.is_det eq 1>		
		refresh_box('workUpd','<cfoutput>#request.self#?fuseaction=project.emptypopup_upd_work_ajax&id=#attributes.work_id#&xml_is_all_estimated=#attributes.xml_is_all_estimated#</cfoutput>','0');
		refresh_box('box_followup','index.cfm?fuseaction=project.emptypopup_updwork_ajaxhistory&id=<cfoutput>#attributes.work_id#</cfoutput>','0');
	<cfelse>
		window.location.href = '<cfoutput>#request.self#?fuseaction=project.works&event=det&id=#attributes.work_id#</cfoutput>';
	</cfif>
</script>
<cf_get_lang_set module_name="#lcase(listgetat(attributes.fuseaction,1,'.'))#"><!--- sayfanin en ustunde acilisi var --->	