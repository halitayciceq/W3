<cfsetting showdebugoutput="no">
<cftransaction>
<cfset salary_minute = 0>
<cfset topson=0>
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
<cfif (len(attributes.TIME_VALUE1) and attributes.TIME_VALUE1 gt 0) or (len(attributes.TIME_VALUE2) and attributes.TIME_VALUE2 gt 0)>
	<cfquery name="get_hourly_salary" datasource="#DSN#">
		SELECT
			ON_MALIYET,
			ON_HOUR
		FROM
			EMPLOYEE_POSITIONS
		WHERE
			POSITION_CODE = #session.ep.position_code#
	</cfquery>
	<cfif get_hourly_salary.recordcount and len(get_hourly_salary.ON_MALIYET) and len(get_hourly_salary.ON_HOUR) and get_hourly_salary.ON_HOUR gt 0 and get_hourly_salary.ON_MALIYET gt 0>
		<cfset salary_minute = (get_hourly_salary.on_maliyet/get_hourly_salary.on_hour/60)>
	<cfelse>
		<script type="text/javascript">
			alert("<cf_get_lang dictionary_id='38445.İnsan Kaynakları Bölümü Pozisyon Çalışma Maliyetinizi Belirtilmemiş'>! \n <cf_get_lang dictionary_id='47573.Zaman Harcaması kaydı bulunmaktadır'>!");
		</script>
		<cfabort>
	</cfif>
	
	<cfset topson=(attributes.TIME_VALUE1*60)+attributes.TIME_VALUE2>
	<cfset topson=topson/60>
	<cfquery name="time_total" datasource="#DSN#">
		SELECT 
			SUM(TOTAL_TIME) AS TOTAL_TIME
		FROM
			TIME_COST
		WHERE
			WORK_ID = #attributes.work_id# AND
			(EVENT_DATE > #DATEADD('d',-1,now())# AND EVENT_DATE <= #now()#)
	</cfquery>
	
	<cfif time_total.recordcount and len(time_total.total_time)>
		<cfset xx=time_total.total_time + topson>
	<cfelse>
		<cfset xx=topson>
	</cfif>
	<cfif xx gt 24>
		<script type="text/javascript">
			alert("<cf_get_lang dictionary_id ='38446.Bir Gün İçinde 24 Saatten Fazla Zaman Harcaması Girilemez'>!\ <cf_get_lang dictionary_id='47573.Zaman Harcaması kaydı bulunmaktadır'>!");
		</script>
		<cfabort>
	</cfif>

	<cfquery name="get_work_history" datasource="#dsn#">
		SELECT TOP 1 COMPANY_ID,PROJECT_ID,WORK_HEAD FROM PRO_WORKS_HISTORY WHERE WORK_ID = #attributes.WORK_ID# ORDER BY HISTORY_ID DESC
	</cfquery> 
    <cfquery name="ADD_WORK_HISTORY" datasource="#DSN#">
        INSERT INTO
            PRO_WORKS_HISTORY
        (
            SERVICE_ID,
            G_SERVICE_ID,
            OUR_COMPANY_ID,
            WORK_CAT_ID,
            WORK_ID,
            WORK_HEAD,
            WORK_DETAIL,
            ESTIMATED_TIME,
            RELATED_WORK_ID,
            PROJECT_EMP_ID,
            OUTSRC_CMP_ID,
            OUTSRC_PARTNER_ID,
            <!---OUTSRC_CC_PARTNER_ID,--->
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
            TARGET_FINISH
        )
        SELECT TOP 1
        	SERVICE_ID,
            G_SERVICE_ID,
            OUR_COMPANY_ID,
            WORK_CAT_ID,
            WORK_ID,
            WORK_HEAD,
            NULL,
            ESTIMATED_TIME,
            RELATED_WORK_ID,
            PROJECT_EMP_ID,
            OUTSRC_CMP_ID,
            OUTSRC_PARTNER_ID,
            <!---OUTSRC_CC_PARTNER_ID,--->
            PROJECT_ID,
            COMPANY_ID,
            COMPANY_PARTNER_ID,
            CONSUMER_ID,
            REAL_START,
            REAL_FINISH,
            WORK_CURRENCY_ID,
            WORK_PRIORITY_ID,
            <cfif isDefined("attributes.TIME_VALUE1") and len(attributes.TIME_VALUE1)>#attributes.TIME_VALUE1#<cfelse>NULL</cfif>,
            <cfif isDefined("attributes.TIME_VALUE2") and len(attributes.TIME_VALUE2)>#attributes.TIME_VALUE2#<cfelse>NULL</cfif>,
            TO_COMPLETE,
            #now()#,
			#session.ep.userid#,
            IS_MILESTONE,
            TARGET_START,
            TARGET_FINISH
        FROM 
        	PRO_WORKS_HISTORY WHERE WORK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.work_id#">
        ORDER BY 
        	HISTORY_ID DESC
        <!--- VALUES
        (
            <cfif len(get_work_history.SERVICE_ID)>#get_work_history.SERVICE_ID#<cfelse>NULL</cfif>,
            <cfif len(get_work_history.G_SERVICE_ID)>#get_work_history.G_SERVICE_ID#<cfelse>NULL</cfif>,
            <cfif len(get_work_history.OUR_COMPANY_ID)>#get_work_history.OUR_COMPANY_ID#<cfelse>NULL</cfif>,
            <cfif len(get_work_history.WORK_CAT_ID)>#get_work_history.WORK_CAT_ID#<cfelse>NULL</cfif>,
            <cfif len(get_work_history.WORK_ID)>#get_work_history.WORK_ID#<cfelse>NULL</cfif>,
            <cfif len(get_work_history.WORK_HEAD)>'#get_work_history.WORK_HEAD#'<cfelse>NULL</cfif>,
            NULL,
            <cfif len(get_work_history.ESTIMATED_TIME)>#get_work_history.ESTIMATED_TIME#<cfelse>NULL</cfif>,
            <cfif len(get_work_history.RELATED_WORK_ID)>#get_work_history.RELATED_WORK_ID#<cfelse>NULL</cfif>,
			<cfif len(get_work_history.PROJECT_EMP_ID)>#get_work_history.PROJECT_EMP_ID#<cfelse>NULL</cfif>,
            <cfif len(get_work_history.OUTSRC_CMP_ID)>#get_work_history.OUTSRC_CMP_ID#<cfelse>NULL</cfif>,
            <cfif len(get_work_history.OUTSRC_PARTNER_ID)>#get_work_history.OUTSRC_PARTNER_ID#<cfelse>NULL</cfif>,
            <cfif len(get_work_history.OUTSRC_CC_PARTNER_ID)>#get_work_history.OUTSRC_CC_PARTNER_ID#<cfelse>NULL</cfif>,
            <cfif len(get_work_history.PROJECT_ID)>#get_work_history.PROJECT_ID#<cfelse>NULL</cfif>,
            <cfif len(get_work_history.COMPANY_ID)>#get_work_history.COMPANY_ID#<cfelse>NULL</cfif>,
            <cfif len(get_work_history.COMPANY_PARTNER_ID)>#get_work_history.COMPANY_PARTNER_ID#<cfelse>NULL</cfif>,
            <cfif len(get_work_history.CONSUMER_ID)>#get_work_history.CONSUMER_ID#<cfelse>NULL</cfif>,
            <cfif len(get_work_history.REAL_START)>'#get_work_history.REAL_START#'<cfelse>NULL</cfif>,
            <cfif len(get_work_history.REAL_FINISH)>'#get_work_history.REAL_FINISH#'<cfelse>NULL</cfif>,
            <cfif len(get_work_history.WORK_CURRENCY_ID)>#get_work_history.WORK_CURRENCY_ID#<cfelse>NULL</cfif>,
            <cfif len(get_work_history.WORK_PRIORITY_ID)>#get_work_history.WORK_PRIORITY_ID#<cfelse>NULL</cfif>,
            <cfif isDefined("attributes.TIME_VALUE1") and len(attributes.TIME_VALUE1)>#attributes.TIME_VALUE1#<cfelse>NULL</cfif>,
            <cfif isDefined("attributes.TIME_VALUE2") and len(attributes.TIME_VALUE2)>#attributes.TIME_VALUE2#<cfelse>NULL</cfif>,
            <cfif len(get_work_history.TO_COMPLETE)>#get_work_history.TO_COMPLETE#<cfelse>NULL</cfif>,
			#now()#,
			#session.ep.userid#,
            <cfif len(get_work_history.IS_MILESTONE)>#get_work_history.IS_MILESTONE#<cfelse>NULL</cfif>,
            <cfif len(get_work_history.TARGET_START)>'#get_work_history.TARGET_START#'<cfelse>NULL</cfif>,
            <cfif len(get_work_history.TARGET_FINISH)>'#get_work_history.TARGET_FINISH#'<cfelse>NULL</cfif>
        ) --->
    </cfquery>
    <cfquery name="UPD_PRO_WORKS" datasource="#DSN#">
       UPDATE 
            PRO_WORKS 
        SET 
            TOTAL_TIME_HOUR = <cfif len(attributes.time_value1) and attributes.time_value1 gt 0>#attributes.time_value1#<cfelse>NULL</cfif>,
            TOTAL_TIME_MINUTE = <cfif len(attributes.time_value2) and attributes.time_value2 gt 0>#attributes.time_value2#<cfelse>NULL</cfif>			
        WHERE 
            PRO_WORKS.WORK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.work_id#">
    </cfquery>
	
	<cfquery name="GET_MONEY" datasource="#DSN#">
		 SELECT
			ON_MALIYET AS SALARY 
		FROM
			EMPLOYEE_POSITIONS,
			DEPARTMENT
		WHERE
			EMPLOYEE_POSITIONS.DEPARTMENT_ID = DEPARTMENT.DEPARTMENT_ID AND 
			EMPLOYEE_POSITIONS.POSITION_CODE = #session.ep.position_code# 
	</cfquery>
	<cfset total_min=(attributes.TIME_VALUE1*60)+attributes.TIME_VALUE2>
	<cfset para=round(salary_minute*total_min)>		
	<cfquery name="ADD_TIME_COST" datasource="#DSN#">
		INSERT INTO
			TIME_COST
		(
			OUR_COMPANY_ID,
			WORK_ID,
			COMPANY_ID,
			PROJECT_ID,
			TOTAL_TIME,
			EXPENSED_MONEY,
			EXPENSED_MINUTE,
			EMPLOYEE_ID,
			EVENT_DATE,
			COMMENT,
			STATE,
			TIME_COST_STAGE,
			RECORD_DATE,
			RECORD_IP,
			RECORD_EMP
		)
		VALUES
		(
			#session.ep.company_id#,
			#attributes.work_id#,
			<cfif len(get_work_history.COMPANY_ID)>#get_work_history.COMPANY_ID#<cfelse>NULL</cfif>,
			<cfif len(get_work_history.PROJECT_ID)>#get_work_history.PROJECT_ID#<cfelse>NULL</cfif>,
			#TOPSON#,
			#PARA#,
			#TOTAL_MIN#,
			#session.ep.userid#,
			#now()#,
			'#get_work_history.work_head#',
			1,
			<cfif isdefined('get_process_stage.process_row_id') and len(get_process_stage.process_row_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#get_process_stage.process_row_id#"><cfelse>NULL</cfif>,
			#now()#,
			'#cgi.remote_addr#',
			#session.ep.userid#
		)
	</cfquery>
	<cfquery name="get_harcanan_zaman" datasource="#DSN#">
		SELECT
			SUM((ISNULL(TOTAL_TIME_HOUR,0)*60) + ISNULL(TOTAL_TIME_MINUTE,0)) AS HARCANAN_DAKIKA
		FROM
			PRO_WORKS_HISTORY
		WHERE
			WORK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.work_id#">
	</cfquery>
	<cfset harcanan_ = get_harcanan_zaman.HARCANAN_DAKIKA>
	<cfset liste=harcanan_/60>
	<cfset saat=listfirst(liste,'.')>
	<cfset dak=harcanan_-saat*60>
		<script type="text/javascript">
			<cfoutput>
				document.getElementById('hours_#attributes.work_id#').value = '#saat#';
				document.getElementById('minute_#attributes.work_id#').value = '#dak#';
				document.getElementById('keyword').focus();
			</cfoutput>
		</script>
<cfelseif isdefined("attributes.estimated_time") and len (attributes.estimated_time) and isdefined("attributes.estimated_time_minute") and len (attributes.estimated_time_minute)>
	<cfset total_time = (attributes.estimated_time*60)+attributes.estimated_time_minute>
	<cfquery name="UPD_PRO_WORKS" datasource="#DSN#">
		UPDATE 
			PRO_WORKS 
		SET 
		 	ESTIMATED_TIME = <cfqueryparam cfsqltype="cf_sql_integer" value="#total_time#">
		WHERE 
			PRO_WORKS.WORK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.work_id#">
	 </cfquery>
</cfif>
</cftransaction>
