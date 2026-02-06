<!--- Bu sayfadaki dsn_alias ifadeleri baska sayfalardan da kullanildigi icin eklendi, Lutfen kaldirmayiniz!!! FBS 20110531 --->
<cfif isDefined("attributes.work_head") and isdefined('attributes.startdate_plan') and isDate(attributes.startdate_plan)>
	<cfquery name="ADD_WORK" datasource="#DSN#">
		INSERT INTO
			#dsn_alias#.PRO_WORKS
		(
			G_SERVICE_ID,
			SERVICE_ID,
			OUR_COMPANY_ID,
			COMPANY_ID,
			COMPANY_PARTNER_ID,
			CONSUMER_ID,
			WORK_CAT_ID,
			PROJECT_ID,
			RELATED_WORK_ID,
			ESTIMATED_TIME,
			EXPECTED_BUDGET,
			EXPECTED_BUDGET_MONEY,
			PROJECT_EMP_ID,
			OUTSRC_CMP_ID,
			OUTSRC_PARTNER_ID,
			WORK_STATUS,
			WORK_NO,
			WORK_HEAD,
			WORK_DETAIL,
			WORK_CIRCUIT,
			WORK_FUSEACTION,
			TOTAL_TIME_HOUR,
			TOTAL_TIME_MINUTE,
			TARGET_START,
			TARGET_FINISH,
			TERMINATE_DATE,
			WORK_CURRENCY_ID,
			WORK_PRIORITY_ID,
			PERIODIC_WORK_ID,
			IS_MILESTONE,
			MILESTONE_WORK_ID,
			OPPORTUNITY_ID,
			PRODUCT_SAMPLE_ID,
			SUBSCRIPTION_ID,
            FORUM_REPLY_ID,
			WORKGROUP_ID,
			OPP_OUR_COMPANY_ID,
			TO_COMPLETE,
			RELATION_TYPE,
			CUS_HELP_ID,
			COMPLETED_AMOUNT,
			RECORD_AUTHOR,
			RECORD_DATE,
			RECORD_IP,
			ASSETP_ID,
			ACTIVITY_ID,
			PBS_ID,
			REWORK,
            PREDICTED_START,
            PREDICTED_FINISH,
            DURATION,
            SPECIAL_DEFINITION_ID,
            AVERAGE_AMOUNT,
            AVERAGE_AMOUNT_UNIT,
            SALE_CONTRACT_AMOUNT,
            PURCHASE_CONTRACT_AMOUNT,
            EVENT_PLAN_ROW_ID,
            PURCHASE_CONTRACT_ID,
            SALE_CONTRACT_ID
		)
		VALUES
		(
			<cfif isdefined("attributes.g_service_id") and len(attributes.g_service_id)>#attributes.g_service_id#<cfelse>NULL</cfif>,
			<cfif isdefined("attributes.service_id") and len(attributes.service_id)>#attributes.service_id#<cfelse>NULL</cfif>,
			#attributes.our_company_id#,
			<cfif len(attributes.company_id) and len(attributes.company_partner_id)>
				#attributes.company_id#,
				#attributes.company_partner_id#,
				NULL,
			<cfelseif not len(attributes.company_id) and len(attributes.company_partner_id)>
				NULL,
				NULL,
				#attributes.company_partner_id#,
			<cfelse>
				NULL,
				NULL,
				NULL,
			</cfif>
			#attributes.pro_work_cat#,
			<cfif isdefined("attributes.project_id") and len(attributes.project_id)>#attributes.project_id#<cfelse>NULL</cfif>,
			<cfif isdefined("attributes.rel_work") and len(attributes.rel_work)><cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.rel_work#"><cfelse>NULL</cfif>,
			<cfif isdefined("total_time") and len(total_time)>#total_time#<cfelse>NULL</cfif>,
			<cfif isdefined("attributes.expected_budget") and len(attributes.expected_budget)>#replace(expected_budget,",","","all")#<cfelse>NULL</cfif>,
			<cfif isdefined("attributes.expected_budget_money") and len(attributes.expected_budget_money)><cfqueryparam cfsqltype="cf_sql_varchar" value="#expected_budget_money#"><cfelse>NULL</cfif>,
			<cfif isdefined('attributes.project_emp_id') and len(attributes.project_emp_id)>
				#attributes.project_emp_id#,
				NULL,
				NULL,
			<cfelseif len(attributes.task_company_id)>
				NULL,
				#attributes.task_company_id#,
				<cfif (isdefined("attributes.task_partner_id") and len(attributes.task_partner_id))>#attributes.task_partner_id#<cfelse>NULL</cfif>,
			<cfelse>
				NULL,
				NULL,
				NULL,
			</cfif>
			<cfif isDefined("attributes.work_status")>1<cfelse>0</cfif>,
			<cfif isDefined("attributes.work_no") and len(attributes.work_no)><cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.work_no#"><cfelse>NULL</cfif>,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.work_head#">,
			<cfif isDefined("attributes.work_detail") and len(attributes.work_detail)><cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.work_detail#"><cfelse>NULL</cfif>,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#listfirst(attributes.work_fuse,".")#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#listlast(attributes.work_fuse,".")#">,
			<cfif isDefined("attributes.total_time_hour") and len(attributes.total_time_hour)>#attributes.total_time_hour#<cfelse>NULL</cfif>,
			<cfif isDefined("attributes.total_time_minute") and len(attributes.total_time_minute)>#attributes.total_time_minute#<cfelse>NULL</cfif>,
			#attributes.startdate_plan#,
			#attributes.finishdate_plan#,
			<cfif isdefined('attributes.terminate_date') and len(attributes.terminate_date)>#attributes.terminate_date#<cfelse>NULL</cfif>,
			<cfif isdefined("attributes.work_process_stage")>#attributes.work_process_stage#<cfelse>#attributes.process_stage#</cfif>,
			#attributes.priority_cat#,
			<cfif isDefined("get_periodic_work_id")>#get_periodic_work_id#<cfelse>NULL</cfif>,
			<cfif isdefined('attributes.is_milestone') and len(attributes.is_milestone)>1<cfelse>0</cfif>,
			<cfif isdefined('attributes.milestone_work_id') and len(attributes.milestone_work_id)>#attributes.milestone_work_id#<cfelse>NULL</cfif>,
			<cfif isDefined("attributes.opp_id")>#attributes.opp_id#<cfelse>NULL</cfif>,
			<cfif isDefined("attributes.product_sample_id") and len(attributes.product_sample_id)>#attributes.product_sample_id#<cfelse>NULL</cfif>,
			<cfif isDefined("attributes.subscription_id") and len(attributes.subscription_id)>#attributes.subscription_id#<cfelse>NULL</cfif>,
			<cfif isDefined("attributes.forum_reply_id") and len(attributes.forum_reply_id)>#attributes.forum_reply_id#<cfelse>NULL</cfif>,          
			<cfif isdefined("attributes.workgroup_id") and len(attributes.workgroup_id)>#attributes.workgroup_id#<cfelse>NULL</cfif>,
			<cfif isdefined('attributes.our_comp') and len(attributes.our_comp)>#attributes.our_comp#<cfelse>NULL</cfif>,
			0,
			<cfif isdefined('attributes.work_relation_date') and len(attributes.work_relation_date)>#attributes.work_relation_date#<cfelse>NULL</cfif>,
			<cfif isdefined('attributes.cus_help_id') and len(attributes.cus_help_id)>#attributes.cus_help_id#<cfelse>NULL</cfif>,
			<cfif isdefined('attributes.completed_amount') and len(attributes.completed_amount)>#attributes.completed_amount#<cfelse>NULL</cfif>,
			#session.ep.userid#,
			#now()#,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.remote_addr#">,
			<cfif isdefined('attributes.assetp_id') and len(attributes.assetp_id)>#attributes.assetp_id#<cfelse>NULL</cfif>,
			<cfif isdefined('attributes.activity_type') and len(attributes.activity_type)>#attributes.activity_type#<cfelse>NULL</cfif>,
			<cfif isdefined('attributes.pbs_id') and len(attributes.pbs_id)>#attributes.pbs_id#<cfelse>NULL</cfif>,
			<cfif isDefined("attributes.rework")>1<cfelse>0</cfif>,
            <cfif isDefined("attributes.predicted_start") and len(attributes.predicted_start)>#attributes.predicted_start#<cfelse>NULL</cfif>,
            <cfif isDefined("attributes.predicted_finish") and len(attributes.predicted_finish)>#attributes.predicted_finish#<cfelse>NULL</cfif>,
            <cfif isDefined("attributes.duration") and len(attributes.duration)>#attributes.duration#<cfelse>NULL</cfif>,
            <cfif isdefined("attributes.special_definition") and len(attributes.special_definition)>#attributes.special_definition#<cfelse>NULL</cfif>,
            <cfif isdefined('attributes.average_amount') and len(attributes.average_amount)>#attributes.average_amount#<cfelse>NULL</cfif>,
            <cfif isdefined('attributes.amount_unit') and len(attributes.amount_unit)>#attributes.amount_unit#<cfelse>NULL</cfif>,
            <cfif isdefined('attributes.sale_contract_amount') and len(attributes.sale_contract_amount)>#attributes.sale_contract_amount#<cfelse>NULL</cfif>,
            <cfif isdefined('attributes.purchase_contract_amount') and len(attributes.purchase_contract_amount)>#attributes.purchase_contract_amount#<cfelse>NULL</cfif>,
            <cfif isdefined('attributes.event_plan_row_id') and len(attributes.event_plan_row_id)>#event_plan_row_id#<cfelse>NULL</cfif>,
            <cfif isdefined('attributes.purchase_contract_id') and len(attributes.purchase_contract_id)>#attributes.purchase_contract_id#<cfelse>NULL</cfif>,
            <cfif isdefined('attributes.sale_contract_id') and len(attributes.sale_contract_id)>#attributes.sale_contract_id#<cfelse>NULL</cfif>
		)
		SELECT SCOPE_IDENTITY() AS MAX_WORK_ID
	</cfquery>
	<cfif isdefined("attributes.xml_is_work_no") and attributes.xml_is_work_no eq 1>
		<cfset paper_number = listLast(attributes.work_no,"-")>
		<cfif len(paper_number)>
			<cfquery name="UPD_GEN_PAP" datasource="#DSN#">
				UPDATE 
					GENERAL_PAPERS_MAIN
				SET
					WORK_NUMBER= #paper_number#
				WHERE
					WORK_NUMBER IS NOT NULL
			</cfquery>
		</cfif>
	</cfif>
</cfif>
<!--- <cfif isdefined("attributes.id") and len(attributes.id) and isdefined("attributes.project_id") and len(attributes.project_id) and (attributes.id neq attributes.project_id)>
	<cfquery name="upd_imp_project_id" datasource="#DSN#">
		UPDATE 
			WRK_LICENSE
		SET
			IMPLEMENTATION_PROJECT_ID = <cfqueryparam value = "#attributes.project_id#" CFSQLType = "cf_sql_integer">
		WHERE 
			IMPLEMENTATION_PROJECT_ID = <cfqueryparam value = "#attributes.id#" CFSQLType = "cf_sql_integer"> AND IMPLEMENTATION_PROJECT_DOMAIN LIKE '%#listgetat(cgi.HTTP_REFERER,2,'/')#' 
	</cfquery>
</cfif> --->
<cfset get_last_work.work_id = add_work.max_work_id>
<cfif isDefined("attributes.rel_work")>
	<cfif attributes.rel_work contains(";")>
        <cfset related_work_ids =""><!--- Ilıskili islerin listesi --->
        <cfset related_work_types =""><!--- Ilıskili is tipleri listesi --->
        <cfset related_work_lags =""><!--- Ilıskili is gecikmeleri listesi --->
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
        <cfset related_work_ids = attributes.rel_work>
        <cfset related_work_types=''>
        <cfset related_work_lags=''>
    </cfif>
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
	                <cfqueryparam cfsqltype="cf_sql_integer" value="#get_last_work.work_id#">,
	                <cfqueryparam cfsqltype="cf_sql_integer" value="#listgetat(related_work_ids,k)#">,
					<cfif len(related_work_types)>
	                	<cfqueryparam cfsqltype="cf_sql_varchar" value="#listgetat(related_work_types,k)#">
					<cfelse>
						NULL
					</cfif>,
	                <cfif listlen(related_work_lags) and  k lte listlen(related_work_lags) and len(listgetat(related_work_lags,k))>
	                	<cfqueryparam cfsqltype="cf_sql_integer" value="#listgetat(related_work_lags,k)#">
	                <cfelse>
	                	NULL
	                </cfif>
	            )
	    </cfquery>
	</cfloop>
</cfif>
<!--- modified:Özcan 20120808 İlişiki iş tarih bağlantıları İş Id:45741--->
<cfif isdefined("related_work_ids") and related_work_ids neq 0 and len(related_work_ids) and len(related_work_types)>
	<cfloop from="1" to="#listlen(related_work_ids)#" index="k">
		<cfquery name="getDate" datasource="#dsn#">
			SELECT TARGET_START,TARGET_FINISH FROM PRO_WORKS WHERE WORK_ID=<cfqueryparam cfsqltype="cf_sql_integer" value="#get_last_work.work_id#">
		</cfquery>
		<cfquery name="get_relDate" datasource="#dsn#">
			SELECT TARGET_START,TARGET_FINISH,DATEDIFF("D",TARGET_START,TARGET_FINISH)AS FARK FROM PRO_WORKS WHERE WORK_ID=<cfqueryparam cfsqltype="cf_sql_integer" value="#listgetat(related_work_ids,k)#">
		</cfquery>
		<cfset related_work_types_row = listgetat(related_work_types,k)><!--- iliski sekli : A ana is B iliskili is --->
		<cfif related_work_types_row eq 'FS'><!--- A işi bittikten sonra B işi başlar --->
				<cfset work_start_date = getDate.TARGET_FINISH>
				<cfset work_finish_date = dateadd('d',get_relDate.FARK,get_relDate.TARGET_FINISH)>
		<cfelseif  listgetat(related_work_types,k) eq 'SS'><!--- B işi A başlamadan başlayamaz  --->
				<cfset work_start_date = getDate.TARGET_START>
				<cfset work_finish_date = dateadd('d',get_relDate.FARK,getDate.TARGET_START)>
		<cfelseif  listgetat(related_work_types,k) eq 'FF'><!--- B isi A isi bitmeden bitemez (bitis tarihleri aynı +- bekleme )--->
				<cfset work_start_date = dateadd('d',-get_relDate.FARK,getDate.TARGET_FINISH)>
				<cfset work_finish_date = getDate.TARGET_FINISH>
		<cfelseif listgetat(related_work_types,k) eq 'SF'><!--- B isi A isi bitmeden baslayamaz --->
				<cfset work_start_date = dateadd('d',-get_relDate.FARK,getDate.TARGET_START)>
				<cfset work_finish_date = getDate.TARGET_START>
		</cfif>
		
		<cfset formatted_start_date = createODBCDateTime(work_start_date)>
		
		<cfquery name="setDate" datasource="#DSN#">
			UPDATE PRO_WORKS SET TARGET_START = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#formatted_start_date#">,TARGET_FINISH=<cfqueryparam cfsqltype="cf_sql_timestamp" value="#work_finish_date#"> WHERE WORK_ID=<cfqueryparam cfsqltype="cf_sql_integer" value="#listgetat(related_work_ids,k)#">
		</cfquery>
	</cfloop>
</cfif>
<!--- Mail gonderilecekse --->
<cfif isdefined("attributes.is_mail")>
	<cfif len(attributes.project_emp_id)>
		<cfinclude template="get_work_pos.cfm">
		<cfset task_user_email=get_pos.employee_email>
	</cfif>
</cfif>
<cfquery name="ADD_WORK_HISTORY" datasource="#DSN#">
	INSERT INTO 
		#dsn_alias#.PRO_WORKS_HISTORY
	( 
		G_SERVICE_ID,
		SERVICE_ID,
		OUR_COMPANY_ID,
		WORK_CAT_ID, 
		WORK_STATUS,
		WORK_ID,
		WORK_NO,
		WORK_HEAD,
		WORK_DETAIL,
		ESTIMATED_TIME,
		PROJECT_EMP_ID,
		OUTSRC_CMP_ID,
		OUTSRC_PARTNER_ID,
		PROJECT_ID,
		RELATED_WORK_ID,
		COMPANY_ID,
		COMPANY_PARTNER_ID,
		CONSUMER_ID,
		TOTAL_TIME_HOUR,
		TOTAL_TIME_MINUTE,
		TARGET_START, 
		TARGET_FINISH, 
		WORK_CURRENCY_ID,
		WORK_PRIORITY_ID, 
		UPDATE_DATE, 
		PERIODIC_WORK_ID,
		UPDATE_AUTHOR,
		IS_MILESTONE,
		MILESTONE_WORK_ID,
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
		<cfif isdefined("attributes.g_service_id") and len(attributes.g_service_id)>#attributes.g_service_id#<cfelse>NULL</cfif>,
		<cfif isdefined("attributes.service_id") and len(attributes.service_id)>#attributes.service_id#<cfelse>NULL</cfif>,
		#attributes.our_company_id#,
		#attributes.pro_work_cat#,
		1,
		#get_last_work.work_id#, 
		<cfif isDefined("attributes.work_no") and len(attributes.work_no)><cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.work_no#"><cfelse>NULL</cfif>,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.work_head#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.work_detail#">,
		<cfif isdefined("total_time") and len(total_time)>#total_time#<cfelse>NULL</cfif>,
		<cfif len(attributes.project_emp_id)>
			#attributes.project_emp_id#,
			NULL,
			NULL,
		<cfelseif len(attributes.task_company_id)>
			NULL,
			#attributes.task_company_id#,
			<cfif (isdefined('attributes.task_partner_id') and len(attributes.task_partner_id))>#attributes.task_partner_id#<cfelse>NULL</cfif>,
		<cfelse>
			NULL,
			NULL,
			NULL,
		</cfif>
		<cfif isdefined("attributes.project_id") and len(attributes.project_id)>#attributes.project_id#<cfelse>NULL</cfif>,
		<cfif isdefined("attributes.rel_work_id") and len(attributes.rel_work_id)>#attributes.rel_work_id#<cfelse>NULL</cfif>,
		<cfif len(attributes.company_id) and len(attributes.company_partner_id)>
			#attributes.company_id#,
			#attributes.company_partner_id#,
			NULL,
		<cfelseif not len(attributes.company_id) and len(attributes.company_partner_id)>
			NULL,
			NULL,
			#attributes.company_partner_id#,
		<cfelse>
			NULL,
			NULL,
			NULL,
		</cfif>
		<cfif isDefined("attributes.total_time_hour") and len(attributes.total_time_hour)>#attributes.total_time_hour#<cfelse>NULL</cfif>,
		<cfif isDefined("attributes.total_time_minute") and len(attributes.total_time_minute)>#attributes.total_time_minute#<cfelse>NULL</cfif>,
		<cfif isdefined('attributes.startdate_plan')>#attributes.startdate_plan#<cfelse>NULL</cfif>,
		<cfif isdefined('attributes.finishdate_plan')>#attributes.finishdate_plan#<cfelse>NULL</cfif>,
		<cfif isdefined("attributes.work_process_stage")>#attributes.work_process_stage#<cfelse>#attributes.process_stage#</cfif>,
		#attributes.priority_cat#,
		#now()#,
		<cfif isDefined("get_periodic_work_id")>#get_periodic_work_id#<cfelse>NULL</cfif>,
		#session.ep.userid#,
		<cfif isdefined('attributes.is_milestone') and len(attributes.is_milestone)>1<cfelse>0</cfif>,
		<cfif isdefined('attributes.milestone_work_id') and len(attributes.milestone_work_id)>#attributes.milestone_work_id#<cfelse>NULL</cfif>,
		<cfif isdefined('attributes.work_relation_date') and len(attributes.work_relation_date)>#attributes.work_relation_date#<cfelse>NULL</cfif>,
		<cfif isdefined('attributes.activity_type') and len(attributes.activity_type)>#attributes.activity_type#<cfelse>NULL</cfif>,
		<cfif isdefined('attributes.pbs_id') and len(attributes.pbs_id)>#attributes.pbs_id#<cfelse>NULL</cfif>,
        <cfif isDefined("attributes.predicted_start") and len(attributes.predicted_start)>#attributes.predicted_start#<cfelse>NULL</cfif>,
		<cfif isDefined("attributes.predicted_finish") and len(attributes.predicted_finish)>#attributes.predicted_finish#<cfelse>NULL</cfif>,
		<cfif isDefined("attributes.duration") and len(attributes.duration)>#attributes.duration#<cfelse>NULL</cfif>,
        <cfif isdefined("attributes.special_definition") and len(attributes.special_definition)>#attributes.special_definition#<cfelse>NULL</cfif>,
        <cfif isdefined("attributes.forum_reply_id") and len(attributes.forum_reply_id)>#attributes.forum_reply_id#<cfelse>NULL</cfif>,
        <cfif isdefined('attributes.completed_amount') and len(attributes.completed_amount)>#attributes.completed_amount#<cfelse>NULL</cfif>,
        <cfif isdefined('attributes.average_amount') and len(attributes.average_amount)>#attributes.average_amount#<cfelse>NULL</cfif>,
        <cfif isdefined('attributes.amount_unit') and len(attributes.amount_unit)>#attributes.amount_unit#<cfelse>NULL</cfif>
	)
</cfquery>

<cfif (isDefined("attributes.total_time_hour") and attributes.total_time_hour gt 0) or (isDefined("attributes.total_time_minute") and attributes.total_time_minute gt 0)>
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
    <cfquery name="get_hourly_salary" datasource="#DSN#">
		SELECT ISNULL(ON_MALIYET,0) ON_MALIYET, ISNULL(ON_HOUR,0) ON_HOUR FROM #dsn_alias#.EMPLOYEE_POSITIONS WHERE EMPLOYEE_ID= <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#">
	</cfquery>
	<cfif get_hourly_salary.recordcount and get_hourly_salary.on_maliyet eq 0 or get_hourly_salary.on_hour eq  0>
		<cfif session.ep.time_cost_control eq 1 and ListFind("1,2",session.ep.time_cost_control_type,",")>
			<script type="text/javascript">
				alert("<cf_get_lang dictionary_id='38445.İnsan Kaynakları Bölümü Pozisyon Çalışma Maliyetinizi Belirtilmemiş'>!");
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
			#dsn_alias#.TIME_COST
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
	<cfif xx gt 24>
		<script type="text/javascript">
			alert("<cf_get_lang dictionary_id='38446.Bir Gün İçinde 24 Saatten Fazla Zaman Harcaması Girilemez'>!");
			history.back();
		</script>
		<cfabort>
	</cfif>
	<cfquery name="get_hour" datasource="#DSN#">
		SELECT ON_MALIYET, ON_HOUR FROM #dsn_alias#.EMPLOYEE_POSITIONS WHERE EMPLOYEE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#">
	</cfquery>
	<cfif session.ep.time_cost_control eq 1 and ListFind("1,2",session.ep.time_cost_control_type,",")>
		<cfif not len(get_hour.on_hour)>
			<script type="text/javascript">
				alert("<cf_get_lang dictionary_id='38100.Lütfen SSK aylık iş saatlerini düzenleyin.'>!");
				history.back();
			</script>
			<cfabort>
		</cfif>
	</cfif>
	<cfquery name="GET_MONEY" datasource="#DSN#">
		SELECT
			EP.ON_MALIYET AS SALARY 
		FROM
			#dsn_alias#.EMPLOYEE_POSITIONS EP,
			#dsn_alias#.DEPARTMENT D
		WHERE
			EP.DEPARTMENT_ID = D.DEPARTMENT_ID AND 
			EP.POSITION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#">
	</cfquery>
	<cfset total_min=(attributes.total_time_hour*60)+attributes.total_time_minute>
	<cfset para=round(salary_minute*total_min)>
	<cfif len(attributes.project_id)>
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
			<cfset COST_PRICE_ = get_cost_total.COST_PRICE *total_min / 60 >
		<cfelse>
			<cfif attributes.xml_waste_of_time neq 0>
				<script type="text/javascript">
					alert("<cf_get_lang dictionary_id='65601.Bu projede harcayacağınız zaman 0 çarpanla değerlendirilecektir. Proje Yöneticisine bildirmelisiniz.'>");
				</script>
				<cfset COST_PRICE_ = 0>
			<cfelse>
				<cfset COST_PRICE_ = para>
			</cfif>
		</cfif>
	</cfif>
	<!--- etkilesim sayfasindaki sistem bilgisini getirir --->
	<cfif isdefined('attributes.cus_help_id') and len(attributes.cus_help_id)>
		<cfquery name="get_cus_help_det" datasource="#dsn#">
			SELECT SUBSCRIPTION_ID FROM #dsn_alias#.CUSTOMER_HELP WHERE CUS_HELP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.cus_help_id#">
		</cfquery>
	</cfif>
	
	<cfquery name="ADD_TIME_COST" datasource="#DSN#">
        INSERT INTO
            #dsn_alias#.TIME_COST
        (
            OUR_COMPANY_ID,
            CRM_ID,
            SERVICE_ID,
            WORK_ID,
            COMPANY_ID,
            PROJECT_ID,
            CUS_HELP_ID,
            SUBSCRIPTION_ID,
            FORUM_REPLY_ID,
            PARTNER_ID,
            TOTAL_TIME,
			ESTIMATED_TIME,
            EXPENSED_MONEY,
            EXPENSED_MINUTE,
            EMPLOYEE_ID,
            EVENT_DATE,
            COMMENT,
            ACTIVITY_ID,
            TIME_COST_STAGE,
            RECORD_DATE,
            RECORD_IP,
            RECORD_EMP
        )
        VALUES
        (
            #session.ep.company_id#,
            <cfif isdefined("attributes.g_service_id") and len(attributes.g_service_id)>#attributes.g_service_id#<cfelse>NULL</cfif>,
            <cfif isdefined("attributes.service_id") and len(attributes.service_id)>#attributes.service_id#<cfelse>NULL</cfif>,
            #get_last_work.work_id#,
            <cfif len(attributes.company_id)>#attributes.company_id#<cfelse>NULL</cfif>,
            <cfif len(attributes.project_id)>#attributes.project_id#<cfelse>NULL</cfif>,
            <cfif isdefined('attributes.cus_help_id') and len(attributes.cus_help_id)>#attributes.cus_help_id#<cfelse>NULL</cfif>,
            <cfif isdefined('get_cus_help_det.subscription_id') and len(get_cus_help_det.subscription_id)>#get_cus_help_det.subscription_id#<cfelse>NULL</cfif>,
            <cfif isdefined("attributes.forum_reply_id") and len(attributes.forum_reply_id)>#attributes.forum_reply_id#<cfelse>NULL</cfif>,
            <cfif isdefined('attributes.company_partner_id') and len(attributes.company_partner_id)>#attributes.company_partner_id#<cfelse>NULL</cfif>,
            #topson#,
			<cfif isdefined("total_time") and len(total_time)>#total_time#<cfelse>NULL</cfif>,
		  	<cfif len(attributes.project_id)>#round( COST_PRICE_ )# <cfelse>#PARA#</cfif>,
            #TOTAL_MIN#,
            #session.ep.userid#,
            #now()#,
            <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.work_head#">,
            <cfif len(attributes.activity_type)>#attributes.activity_type#<cfelse>NULL</cfif>,
            <cfif isdefined('get_process_stage.process_row_id') and len(get_process_stage.process_row_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#get_process_stage.process_row_id#"><cfelse>NULL</cfif>,
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
		SELECT PROJECT_NUMBER, PROJECT_HEAD FROM #dsn_alias#.PRO_PROJECTS WHERE PROJECT_ID = #attributes.project_id#
	</cfquery>
	<cfset attributes.project_head='#Get_Project_Head.Project_Head#'>
	<cfset attributes.project_id = attributes.project_id>
</cfif>
<cfset attributes.mail_content_from = isdefined("attributes.project_head") and len(attributes.project_head) ? '#attributes.project_head#<#session.ep.company_email#>' : '#session.ep.company_nick#<#session.ep.company_email#>'><!--- Ortak Mail From --->

<cfset attributes.cc_email_list = ''>
<cfif isDefined("attributes.cc_par_ids") and ListLen(attributes.cc_par_ids)>
	<cfquery name="get_cc_mail" datasource="#dsn#">
		SELECT CP.COMPANY_PARTNER_NAME + ' ' + CP.COMPANY_PARTNER_SURNAME AS NAME_SURNAME FROM COMPANY_PARTNER CP WHERE PARTNER_ID IN (<cfqueryparam cfsqltype="cf_sql_nvarchar" value="#attributes.cc_par_ids#" list="yes">)
	</cfquery>
	<cfset attributes.cc_email_list =listappend(attributes.cc_email_list,valueList(get_cc_mail.NAME_SURNAME))>
</cfif>
<cfif  isDefined("attributes.cc_emp_ids") and ListLen(attributes.cc_emp_ids)>
	<cfquery name="get_cc_mail" datasource="#dsn#">
		SELECT EP.EMPLOYEE_NAME + ' ' + EP.EMPLOYEE_SURNAME AS NAME_SURNAME FROM EMPLOYEES EP WHERE EMPLOYEE_ID IN (<cfqueryparam cfsqltype="cf_sql_nvarchar" value="#attributes.cc_emp_ids#" list="yes">)
	</cfquery>
	<cfset attributes.cc_email_list =listappend(attributes.cc_email_list,valueList(get_cc_mail.NAME_SURNAME))>
</cfif>

<cfif len(task_user_email)>
	<cfset mail_type_id = 1> 
	<cfset mail_emp_id = attributes.project_emp_id>
	<cfsavecontent variable="message">
		<cfoutput>
			<cfif mail_type_id eq 1>
				<cf_get_lang dictionary_id='38482.iş kaydı'>
			<cfelseif mail_type_id eq 2>
				<cf_get_lang dictionary_id='29542.Bilgilendirme'>
			</cfif>
		</cfoutput>
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
			<cf_get_lang dictionary_id='29525.Görevlendirme'>
	    <cfelseif mail_type_id eq 2>
			<cf_get_lang dictionary_id='29542.Bilgilendirme'>
		</cfif>
	</cfsavecontent>
	<cfset attributes.mail_content_to = task_user_email>
	<cfset attributes.mail_content_subject = subject_info & '! - ' & attributes.work_head>
	<cfset attributes.mail_content_additor = additor>
	<cfset attributes.mail_staff = '#form.responsable_name#'>
	<cfset attributes.cc_name_list = '#attributes.cc_email_list#'>
	<cfset attributes.mail_record_emp='#session.ep.name# #session.ep.surname#'>
    <cfset timeformat_style = ( isdefined("session.ep.timeformat_style") and len(session.ep.timeformat_style) ) ? session.ep.timeformat_style : 'HH:MM' />
    <cfset user_domain = application.systemParam.systemParam().user_domain>
	<cfset attributes.mail_record_date=dateformat(dateadd('h',session.ep.time_zone,now()),dateformat_style) & " " & timeformat(dateadd('h',session.ep.time_zone,now()),timeformat_style)>
	<cfset attributes.start_date= dateformat(date_add("h",session.ep.time_zone,attributes.startdate_plan),dateformat_style) & " " & timeformat(date_add("h",session.ep.time_zone,attributes.startdate_plan),timeformat_style) >
	<cfset attributes.finish_date=dateformat(date_add("h",session.ep.time_zone,attributes.finishdate_plan),dateformat_style) & " " & timeformat(date_add("h",session.ep.time_zone,attributes.finishdate_plan),timeformat_style)>
	<cfset attributes.mail_content_info2=attributes.work_detail>
	<cfsavecontent variable="attributes.mail_content_info"><cf_get_lang dictionary_id='38482.iş kaydı'></cfsavecontent>
	<cfif len(mail_emp_id)>
		<cfset attributes.mail_content_link = '#user_domain#/#request.self#?fuseaction=project.works&event=det&id=#get_last_work.work_id#'>
	<cfelse>
		<cfset attributes.mail_content_link = '#partner_domain##request.self#?fuseaction=project.works&event=det&id=#get_last_work.work_id#'>
	</cfif>
	<cfset attributes.mail_content_link_info = '#attributes.work_head#'>
	<cfsavecontent variable="attributes.process_stage_info">
		<cfoutput>
			<cfif isdefined("attributes.work_process_stage")>#attributes.work_process_stage#<cfelse>#attributes.process_stage#</cfif>
		</cfoutput>
	</cfsavecontent>
	<cfinclude template="/design/template/info_mail/mail_content.cfm">
</cfif>

<!--- Bilgi Verilecekler --->
<cfif (isDefined("attributes.cc_par_ids") and ListLen(attributes.cc_par_ids)) or (isDefined("attributes.cc_emp_ids") and ListLen(attributes.cc_emp_ids))>
	<cfset work_id = get_last_work.work_id>
	<cfif isDefined("attributes.cc_emp_ids") and ListLen(attributes.cc_emp_ids)>
		<cfloop list="#attributes.cc_emp_ids#" index="eid">
			<cfquery name="Add_Work_Cc_Emp" datasource="#dsn#">
				INSERT INTO PRO_WORKS_CC (CC_EMP_ID, WORK_ID) VALUES (#eid#, #work_id#)
			</cfquery>
			<cfif isdefined("attributes.is_mail")>
				<cfset mail_type_id = 2>
				<cfset mail_emp_id = eid>
				<cfquery name="get_cc_mail" datasource="#dsn#">
					SELECT EMPLOYEE_ID,EMPLOYEE_NAME,EMPLOYEE_SURNAME, EMPLOYEE_EMAIL FROM EMPLOYEES WHERE EMPLOYEE_ID = #mail_emp_id#
				</cfquery>
				<cfset task_cc_email = get_cc_mail.employee_email>
				<cfif Len(task_cc_email)>
					<cfsavecontent variable="subject_info"><cf_get_lang dictionary_id='29542.Bilgilendirme'></cfsavecontent>
					<cfset attributes.mail_content_to = task_cc_email>
					<cfset attributes.mail_content_subject = subject_info & '! - ' & attributes.work_head>
					<cfset attributes.mail_content_additor = '#get_cc_mail.EMPLOYEE_NAME# #get_cc_mail.EMPLOYEE_SURNAME#'>
					<cfset attributes.mail_staff = '#form.responsable_name#'>
					<cfset attributes.cc_name_list = '#attributes.cc_email_list#'>
					<cfset attributes.mail_record_emp='#session.ep.name# #session.ep.surname#'>
					<cfset attributes.mail_record_date=dateformat(dateadd('h',session.ep.time_zone,now()),dateformat_style) & " " & timeformat(dateadd('h',session.ep.time_zone,now()),timeformat_style)>
					<cfset attributes.start_date= dateformat(date_add("h",session.ep.time_zone,attributes.startdate_plan),dateformat_style) & " " & timeformat(date_add("h",session.ep.time_zone,attributes.startdate_plan),timeformat_style) >
					<cfset attributes.mail_content_info2=attributes.work_detail>
					<cfset attributes.finish_date=dateformat(date_add("h",session.ep.time_zone,attributes.finishdate_plan),dateformat_style) & " " & timeformat(date_add("h",session.ep.time_zone,attributes.finishdate_plan),timeformat_style)>
					<cfsavecontent variable="attributes.mail_content_info"><cf_get_lang dictionary_id='29542.Bilgilendirme'></cfsavecontent>
					<cfif len(mail_emp_id)>
						<cfset attributes.mail_content_link = '#user_domain#/#request.self#?fuseaction=project.works&event=det&id=#work_id#'>
					<cfelse>
						<cfset attributes.mail_content_link = '#partner_domain##request.self#?fuseaction=project.works&event=det&id=#work_id#'>
					</cfif>
					<cfset attributes.mail_content_link_info = attributes.work_head>
						<cfsavecontent variable="attributes.process_stage_info">
						<cfoutput>
							<cfif isdefined("attributes.work_process_stage")>#attributes.work_process_stage#<cfelse>#attributes.process_stage#</cfif>
						</cfoutput>
						</cfsavecontent>
						<cfinclude template="/design/template/info_mail/mail_content.cfm">
				</cfif>
			</cfif>
		</cfloop>
	</cfif>
	<cfif isDefined("attributes.cc_par_ids") and ListLen(attributes.cc_par_ids)>
		<cfloop list="#attributes.cc_par_ids#" index="pid">
			<cfquery name="Add_Work_Cc_Par" datasource="#dsn#">
				INSERT INTO PRO_WORKS_CC (CC_PAR_ID, WORK_ID) VALUES (#pid#, #work_id#)
			</cfquery>
			<cfif isdefined("attributes.is_mail")>
				<cfset mail_type_id = 2>
				<cfset mail_emp_id = pid> 
				<cfquery name="get_cc_mail" datasource="#dsn#">
					SELECT PARTNER_ID,COMPANY_PARTNER_NAME,COMPANY_PARTNER_SURNAME, COMPANY_PARTNER_EMAIL EMPLOYEE_EMAIL FROM COMPANY_PARTNER WHERE PARTNER_ID = #mail_emp_id#
				</cfquery>
				<cfset task_cc_email = get_cc_mail.employee_email>
				<cfif Len(task_cc_email)>
				<cfsavecontent variable="message"><cf_get_lang dictionary_id='38254.Adınıza Yapılmış Yeni Bir Bilgilendirme'>!</cfsavecontent>
					<!--- CC Mail Template Ekliyorum --->
					<cfsavecontent variable="subject_info"><cf_get_lang dictionary_id='29542.Bilgilendirme'></cfsavecontent>
					<cfset attributes.mail_content_to = task_cc_email>
					<cfset attributes.mail_content_subject = subject_info & '! - ' & attributes.work_head>
					<cfset attributes.mail_content_additor ='#get_cc_mail.COMPANY_PARTNER_NAME# #get_cc_mail.COMPANY_PARTNER_SURNAME#'>
					<cfset attributes.mail_staff = '#form.responsable_name#'>
					<cfset attributes.cc_name_list = '#attributes.cc_email_list#'>
					<cfset attributes.mail_record_emp='#session.ep.name# #session.ep.surname#'>
					<cfset attributes.mail_record_date=dateformat(dateadd('h',session.ep.time_zone,now()),dateformat_style) & " " & timeformat(dateadd('h',session.ep.time_zone,now()),timeformat_style)>
					<cfset attributes.start_date= dateformat(date_add("h",session.ep.time_zone,attributes.startdate_plan),dateformat_style) & " " & timeformat(date_add("h",session.ep.time_zone,attributes.startdate_plan),timeformat_style) >
					<cfset attributes.mail_content_info2='#attributes.work_detail#'>
					<cfset attributes.finish_date=dateformat(date_add("h",session.ep.time_zone,attributes.finishdate_plan),dateformat_style) & " " & timeformat(date_add("h",session.ep.time_zone,attributes.finishdate_plan),timeformat_style)>
					<cfsavecontent variable="attributes.mail_content_info"><cf_get_lang dictionary_id='29542.Bilgilendirme'></cfsavecontent>
					<!--- <cfif len(mail_emp_id)>
						<cfset attributes.mail_content_link = '#user_domain#/#request.self#?fuseaction=project.works&event=det&id=#work_id#'>
					<cfelse>
						<cfset attributes.mail_content_link = '#partner_domain##request.self#?fuseaction=project.works&event=det&id=#work_id#'>
					</cfif> --->
					<cfset attributes.is_no_partner = 1>
					<cfset attributes.work_id_krp = contentEncryptingandDecodingAES(isEncode:1,content:attributes.work_id,accountKey:"wrk")>
					<cfset attributes.xml_link = attributes.is_xml_link & attributes.work_id_krp>
					<cfset attributes.mail_content_link_info = '#attributes.work_head#'>
						<cfsavecontent variable="attributes.process_stage_info">
						<cfoutput>
							<cfif isdefined("attributes.work_process_stage")>#attributes.work_process_stage#<cfelse>#attributes.process_stage#</cfif>
						</cfoutput>
						</cfsavecontent>
						<cfinclude template="/design/template/info_mail/mail_content.cfm">
				</cfif>
			</cfif>
		</cfloop>
	</cfif>	
</cfif>
