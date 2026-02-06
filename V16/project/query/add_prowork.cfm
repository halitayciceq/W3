<cf_date tarih="attributes.WORK_H_START">
<cf_date tarih="attributes.WORK_H_FINISH">

<cfset attributes.WORK_H_START = date_add("h",START_HOUR - session.ep.TIME_ZONE,attributes.WORK_H_START)>
<cfset attributes.WORK_H_FINISH = date_add("h",FINISH_HOUR - session.ep.TIME_ZONE,attributes.WORK_H_FINISH)>

<cfif attributes.PRO_H_START gt attributes.WORK_H_START>
	<script type="text/javascript">
		alert("<cf_get_lang no='89.Girdiğiniz İşin Hedef Başlangıç Tarihi Projesinin Hedef Başlangıç Tarihinden Önce Gözüküyor ! Lütfen Düzeltin !'>");
		history.back();
	</script>
	<cfabort>
<cfelseif attributes.PRO_H_FINISH lt attributes.WORK_H_FINISH>
	<script type="text/javascript">
		alert("<cf_get_lang no='90.Girdiğiniz İşin Hedef Bitiş Tarihi Projesinin Hedef Bitiş Tarihinden Sonra Gözüküyor  Lütfen Düzeltin !'>");
		history.back();
	</script>
	<cfabort>
<cfelseif attributes.WORK_H_START gt attributes.WORK_H_FINISH>
	<script type="text/javascript">
		alert("<cf_get_lang no='37.Girdiğiniz İşin Hedef Başlangıç Tarihi ile Hedef Bitiş Tarihi Mantıklı Gözükmüyor ! Lütfen Düzeltin !'>");
		history.back();
	</script>
	<cfabort>
<cfelse>
	<cfquery name="GET_CMP" datasource="#dsn#">
		SELECT
			COMPANY_ID,
			PARTNER_ID
		FROM
			PRO_PROJECTS
		WHERE
			PROJECT_ID=#PROJECT_ID#
	</cfquery>
	<cfif len(FORM.REL_WORK_ID)>
		<cfquery name="GET_REL_WORK_PRO" datasource="#dsn#">
			SELECT
				TARGET_START
			FROM
				PRO_WORKS
			WHERE	
				WORK_ID = #FORM.REL_WORK_ID#
		</cfquery>
		<cfif attributes.WORK_H_START lt get_rel_work_pro.TARGET_START>
			<script type="text/javascript">
				alert("<cf_get_lang no='39.İlişkilendirdiğiniz İşin Başlangıç Tarihi, İşin Başlangıç Tarihinden Küçük Gözüküyor !'>");
				history.back();
			</script>
			<cfabort>
		</cfif>
	</cfif>

	<cfif isDefined("URL.ID")>
		<cfset form.PROJECT_ID = URL.ID>
	</cfif>
	
	<cflock name="#CREATEUUID()#" timeout="20">
		<cftransaction>

		<cfif IsDefined ("form.WORK_HEAD") AND IsDate(FORM.WORK_H_START)>
			<cfquery name="ADD_WORK" datasource="#dsn#">
				INSERT INTO
					PRO_WORKS
				(
					WORK_CAT_ID,
					PROJECT_ID,							
				<cfif len(form.rel_work_id)>
					RELATED_WORK_ID,
				</cfif>
				<cfif isDefined("form.estimated_time") and len(form.estimated_time)>
					ESTIMATED_TIME,
				</cfif>
				<cfif isDefined("form.expected_budget") and len(form.expected_budget)>
					EXPECTED_BUDGET,
				</cfif>
				<cfif isDefined("form.expected_budget_money") and len(form.expected_budget_money)>
					EXPECTED_BUDGET_MONEY,
				</cfif>
				<cfif len(FORM.PROJECT_EMP_ID)>
					PROJECT_EMP_ID,
					OUTSRC_CMP_ID,
					OUTSRC_PARTNER_ID,
				<cfelseif len(attributes.TASK_COMPANY_ID)>
					PROJECT_EMP_ID,
					OUTSRC_CMP_ID,
					OUTSRC_PARTNER_ID,
				</cfif>
					COMPANY_ID,
					COMPANY_PARTNER_ID,
					WORK_HEAD,
					WORK_DETAIL,
					TARGET_START,
					TARGET_FINISH,
					RECORD_AUTHOR,
					WORK_CURRENCY_ID,
					WORK_PRIORITY_ID,
					RECORD_DATE,
					RECORD_IP,
					WORK_STATUS
				)
				VALUES
				(
					#attributes.PRO_WORK_CAT#,
					#PROJECT_ID#,
				<cfif len(form.rel_work_id)>
					#form.rel_work_id#,
				</cfif>
				<cfif isDefined("form.estimated_time") and len(form.estimated_time)>
					#ESTIMATED_TIME#,
				</cfif>
				<cfif isDefined("form.expected_budget") and len(form.expected_budget)>
					#EXPECTED_BUDGET#,
				</cfif>
				<cfif isDefined("form.expected_budget_money") and len(form.expected_budget_money)>
					'#EXPECTED_BUDGET_MONEY#',
				</cfif>
				<cfif len(FORM.PROJECT_EMP_ID)>
					#FORM.PROJECT_EMP_ID#,
					NULL,
					NULL,
				<cfelseif len(attributes.TASK_COMPANY_ID)>
					NULL,
					#FORM.TASK_COMPANY_ID#,
					<cfif len(FORM.TASK_PARTNER_ID)>#FORM.TASK_PARTNER_ID#,<cfelse>NULL,</cfif>
				</cfif>
				<cfif len(get_cmp.COMPANY_ID)>
					#get_cmp.COMPANY_ID#,
				<cfelse>
					NULL,
				</cfif>
				<cfif len(get_cmp.PARTNER_ID)>
					#get_cmp.PARTNER_ID#,
				<cfelse>
					NULL,
				</cfif>
					'#FORM.WORK_HEAD#',
					'#FORM.WORK_DETAIL#',
					#attributes.WORK_H_START#,
					#attributes.WORK_H_FINISH#,
					#SESSION.EP.USERID#,
					#attributes.process_stage#,
					#FORM.PRIORITY_CAT#,
					#NOW()#,
					'#CGI.REMOTE_ADDR#',
					1
				)
			</cfquery>
		</cfif>

		<cfquery name="GET_LAST_WORK" datasource="#dsn#">
			SELECT MAX(WORK_ID) AS WORK_ID FROM PRO_WORKS
		</cfquery>
		<cfset work_id= GET_LAST_WORK.WORK_ID>

		<cfif len(form.rel_work_id) and len(attributes.rel_work)>
			<cfquery name="add_relation" datasource="#dsn#">
				INSERT INTO
					PRO_WORK_RELATIONS
				(
					WORK_ID,
					PRE_ID
				)
				VALUES
				(
					#work_id#,
					#REL_WORK_ID#
				)
			</cfquery>
		</cfif>
		<cfif len(FORM.TASK_PARTNER_ID)>
			<cfinclude template="get_work_partner.cfm">
			<cfset task_user_name=GET_WORK_PARTNER.COMPANY_PARTNER_NAME>
			<cfset task_user_surname=GET_WORK_PARTNER.COMPANY_PARTNER_SURNAME>
			<cfset task_user_email=GET_WORK_PARTNER.COMPANY_PARTNER_EMAIL>
		<cfelse>
			<cfset task_user_email=''>
		</cfif>
		<cfquery name="ADD_WORK_HISTORY" datasource="#dsn#">
			INSERT INTO
				PRO_WORKS_HISTORY
				(
					WORK_CAT_ID,
					WORK_ID,
					WORK_HEAD,
					WORK_DETAIL,
				<cfif len(FORM.PROJECT_EMP_ID)>
					PROJECT_EMP_ID,
					OUTSRC_CMP_ID,
					OUTSRC_PARTNER_ID,
				<cfelseif len(attributes.TASK_COMPANY_ID)>
					PROJECT_EMP_ID,
					OUTSRC_CMP_ID,
					OUTSRC_PARTNER_ID,
				</cfif>
					PROJECT_ID,
				<cfif len(form.rel_work_id)>
					RELATED_WORK_ID,
				</cfif>
					COMPANY_ID,
					COMPANY_PARTNER_ID,
					TARGET_START,
					TARGET_FINISH,
					WORK_CURRENCY_ID,
					WORK_PRIORITY_ID,
					UPDATE_DATE,
					UPDATE_AUTHOR
				)
				VALUES
				(
					#attributes.PRO_WORK_CAT#,
					#work_id#,
					'#attributes.work_head#',
					'#attributes.work_detail#',
				<cfif len(FORM.PROJECT_EMP_ID)>
					#FORM.PROJECT_EMP_ID#,
					NULL,
					NULL,
				<cfelseif len(attributes.TASK_COMPANY_ID)>
					NULL,
					#FORM.TASK_COMPANY_ID#,
					<cfif len(FORM.TASK_PARTNER_ID)>#FORM.TASK_PARTNER_ID#,<cfelse>NULL,</cfif>
				</cfif>
					#FORM.PROJECT_ID#,
				<cfif len(form.rel_work_id)>
					#REL_WORK_ID#,
				</cfif>
				<cfif len(get_cmp.COMPANY_ID)>
					#get_cmp.COMPANY_ID#,
				<cfelse>
					NULL,
				</cfif>
				<cfif len(get_cmp.PARTNER_ID)>
					#get_cmp.PARTNER_ID#,
				<cfelse>
					NULL,
				</cfif>
					#attributes.WORK_H_START#,
					#attributes.WORK_H_FINISH#,
					#attributes.process_stage#,
					#FORM.PRIORITY_CAT#,
					#NOW()#,
					#SESSION.EP.USERID#
				)
		</cfquery>
		</cftransaction>
	</cflock>
	<cfif len(task_user_email)>
		<cfsavecontent variable="message"><cf_get_lang no='30.Adınıza Yapılmış Yeni Bir Görevlendirme !'></cfsavecontent>
		<cfmail to="#task_user_email#"
			  from="#session.ep.company#<#session.ep.company_email#>"
			  subject="#message#" type="HTML">
			<cfinclude template="add_work_mail.cfm">
		</cfmail>
	</cfif>

	<cf_workcube_process is_upd='1' 
		old_process_line='0'
		process_stage='#attributes.process_stage#' 
		record_member='#session.ep.userid#' 
		record_date='#now()#' 
		action_table='PRO_WORKS'
		action_column='WORK_ID'
		action_id='#get_last_work.work_id#'
		action_page='#request.self#?fuseaction=project.works&event=det&id=#get_last_work.work_id#' 
		warning_description = '#getLang("","İlgili İş",66816)# : #attributes.work_head#'>	
	
	<script type="text/javascript">
		wrk_opener_reload();
		window.close();
	</script>
</cfif>
