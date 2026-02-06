<cfquery name="GET_COMPANY" datasource="#DSN#">
	SELECT
		COMPANY_ID,
		PARTNER_ID
	FROM
		PRO_PROJECTS
	WHERE
		PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.main_project_id#">
</cfquery>

<cfset with_related_work = ''>
<cfset milestone_work_id_list = ''>
<cflock timeout="60">
	<cftransaction>
    	<cfquery name="GET_TEMP_TABLE" datasource="#DSN#">
            IF object_id('tempdb..#chr(35)#WORK_ID_HISTORY') IS NOT NULL
               BEGIN
                DROP TABLE #chr(35)#WORK_ID_HISTORY 
               END
        </cfquery>
        <cfquery name="CRT_TEMP_TABLE" datasource="#DSN#">
            CREATE TABLE #chr(35)#WORK_ID_HISTORY 
            ( 
                PREVIOUS_WORK_ID	int,
                AFTER_WORK_ID	int
            )
        </cfquery>
		<cfloop from="1" to="#attributes.record_num#" index="i">
			<cfif IsDefined("attributes.work_select#i#")>
				<cfif not (isdefined("attributes.is_milestone#i#") and len('attributes.is_milestone#i#'))>
					<cfset "attributes.is_milestone#i#" = 0>
				</cfif>
                <cfif isdefined("attributes.copy_cc#i#")>
                    <cfset form_copy_cc = evaluate("attributes.copy_cc#i#")>
                <cfelse>
                    <cfset form_copy_cc = 0>
                </cfif>
				<cfscript>
					form_pro_work_cat = evaluate("attributes.pro_work_cat#i#");
					form_project_emp_id = evaluate("attributes.project_emp_id#i#");
					form_task_company_id = evaluate("attributes.task_company_id#i#");
					form_task_partner_id = evaluate("attributes.task_partner_id#i#");
					form_work_head = evaluate("attributes.work_head#i#");
					form_work_id = evaluate("attributes.work_id#i#");
					form_related_work_id = evaluate("attributes.related_work_id#i#");
					form_work_currency_id=evaluate("attributes.work_currency_id#i#");
					form_work_h_start = evaluate("attributes.work_h_start#i#");
					form_work_h_finish = evaluate("attributes.work_h_finish#i#");
					form_start_hour = evaluate("attributes.start_hour#i#");
					form_finish_hour = evaluate("attributes.finish_hour#i#");	
					form_priority_cat = evaluate("attributes.priority_cat#i#");	
					form_is_milestone = evaluate("attributes.is_milestone#i#");
					form_our_company_id = evaluate("attributes.our_company_id#i#");
					form_milestone_work_id = evaluate("attributes.milestone_work_id#i#");
					form_purchase_contract_amount = evaluate("attributes.purchase_contract_amount#i#");
					form_sale_contract_amount = evaluate("attributes.sale_contract_amount#i#");
				</cfscript>
                
				<cfif len(form_related_work_id)>
                    <cfset with_related_work = listappend(with_related_work,form_work_id,',')>
				</cfif> 
				<cfif len(form_milestone_work_id)>
                	<cfset milestone_work_id_list = listappend(milestone_work_id_list,form_milestone_work_id,',')>
                </cfif>
				<cf_date tarih="form_work_h_start">
				<cf_date tarih="form_work_h_finish"> 
				<cfset form_work_h_start=date_add("h", form_start_hour - session.ep.time_zone, form_work_h_start)>
				<cfset form_work_h_finish=date_add("h", form_finish_hour - session.ep.time_zone, form_work_h_finish)>
				
				<cfquery name="GET_LAST_HISTORY" datasource="#DSN#" maxrows="1">
					SELECT
						WORK_DETAIL
					FROM
						PRO_WORKS_HISTORY
					WHERE
						WORK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#form_work_id#">
					ORDER BY 
						HISTORY_ID		
				</cfquery>		
				<cfquery name="ADD_WORK" datasource="#DSN#">
					INSERT INTO
						PRO_WORKS
                        (
                            WORK_CAT_ID,
                            PROJECT_ID,
                            RELATED_WORK_ID,					
                            <cfif len(form_project_emp_id)>
                                PROJECT_EMP_ID,
                                OUTSRC_CMP_ID,
                                OUTSRC_PARTNER_ID,
                            <cfelseif len(form_task_company_id)>
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
                            WORK_STATUS,
                            IS_MILESTONE,
                            MILESTONE_WORK_ID,
                            OUR_COMPANY_ID,
                            PURCHASE_CONTRACT_AMOUNT,
                            SALE_CONTRACT_AMOUNT
                        )
                        VALUES
                        (
                            #form_pro_work_cat#,
                            #attributes.main_project_id#,
                            NULL,
							<cfif len(form_project_emp_id)>
                                #form_project_emp_id#,
                                NULL,
                                NULL,
                            <cfelseif len(form_task_company_id)>
                                NULL,
                                #form_task_company_id#,
                                <cfif len(form_task_partner_id)>#form_task_partner_id#<cfelse>NULL</cfif>,
                            </cfif>
                            <cfif len(get_company.company_id)>#get_company.company_id#<cfelse>NULL</cfif>,
                            <cfif len(get_company.partner_id)>#get_company.partner_id#<cfelse>NULL</cfif>,
                            '#form_work_head#',
                            '#get_last_history.work_detail#',
                            #form_work_h_start#,
                            #form_work_h_finish#,
                            #session.ep.userid#,
                            <cfif len(form_work_currency_id)>#form_work_currency_id#<cfelse>NULL</cfif>,<!--- #get_process_type.process_row_id#, --->
                            #form_priority_cat#,
                            #now()#,
                            '#cgi.remote_addr#',
                            1,
                            #form_is_milestone#,
                            <cfif len(form_milestone_work_id)>#form_milestone_work_id#<cfelse>NULL</cfif>,
                            <cfif len(form_our_company_id)>#form_our_company_id#<cfelse>NULL</cfif>,
                            <cfif len(form_purchase_contract_amount)>#form_purchase_contract_amount#<cfelse>NULL</cfif>,
                            <cfif len(form_sale_contract_amount)>#form_sale_contract_amount#<cfelse>NULL</cfif>
                        )
                        SELECT SCOPE_IDENTITY() AS MAX_WORK_ID
				</cfquery>
				<cfquery name="CRT_TEMP_TABLE" datasource="#DSN#">
                    INSERT INTO #chr(35)#WORK_ID_HISTORY (PREVIOUS_WORK_ID,AFTER_WORK_ID) VALUES (#form_work_id#,#add_work.max_work_id#)
                </cfquery>
				<cfset new_work_id = add_work.max_work_id>		
				<cfset task_user_email=''>
				
				<cfif len(form_project_emp_id)>
					<cfset attributes.project_emp_id = form_project_emp_id>
					<cfinclude template="get_work_pos.cfm">
					<cfset task_user_email=get_pos.employee_email>				
				<cfelseif len(form_task_partner_id)>
					<cfset form.task_partner_id = form_task_partner_id>
					<cfinclude template="get_work_partner.cfm">
					<cfset task_user_email=get_work_partner.company_partner_email>
				</cfif>
				<cfquery name="ADD_WORK_HISTORY" datasource="#DSN#">
					INSERT INTO
						PRO_WORKS_HISTORY
                        (
                            WORK_CAT_ID,
                            WORK_ID,
                            WORK_HEAD,
                            WORK_DETAIL,
                            <cfif len(form_project_emp_id)>
                                PROJECT_EMP_ID,
                                OUTSRC_CMP_ID,
                                OUTSRC_PARTNER_ID,
                            <cfelseif len(form_task_company_id)>
                                PROJECT_EMP_ID,
                                OUTSRC_CMP_ID,
                                OUTSRC_PARTNER_ID,
                            </cfif>				
                            PROJECT_ID,
                            COMPANY_ID,
                            COMPANY_PARTNER_ID,
                            TARGET_START,
                            TARGET_FINISH,
                            WORK_CURRENCY_ID,
                            WORK_PRIORITY_ID,
                            IS_MILESTONE,
                            UPDATE_DATE,
                            UPDATE_AUTHOR
                        )
                        VALUES
                        (
                            #form_pro_work_cat#,
                            #add_work.max_work_id#,
                            '#form_work_head#',
                            '#get_last_history.work_detail#',
							<cfif len(form_project_emp_id)>
                                #form_project_emp_id#,
                                NULL,
                                NULL,
                            <cfelseif len(form_task_company_id)>
                                NULL,
                                #form_task_company_id#,
                                <cfif len(form_task_partner_id)>#form_task_partner_id#<cfelse>NULL</cfif>,
                            </cfif>
                                #attributes.main_project_id#,
                            <cfif len(get_company.company_id)>#get_company.company_id#<cfelse>NULL</cfif>,
                            <cfif len(get_company.partner_id)>#get_company.partner_id#<cfelse>NULL</cfif>,					
                            #form_work_h_start#,
                            #form_work_h_finish#,
                            <cfif len(form_work_currency_id)>#form_work_currency_id#<cfelse>NULL</cfif>,
                            #form_priority_cat#,
                            #form_is_milestone#,
                            #now()#,
                            #session.ep.userid#
                        )
				</cfquery>
                
                <cfif form_copy_cc neq 0>
                    <cfquery name="GET_WORK_CC" datasource="#DSN#">
                        SELECT * FROM PRO_WORKS_CC WHERE WORK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#form_work_id#">
                    </cfquery>
					<cfif get_work_cc.recordcount>
                        <cfquery name="INS_WORK_CC" datasource="#DSN#">
                            <cfloop query="get_work_cc">
                                INSERT INTO 
                                    PRO_WORKS_CC
                                (
                                    WORK_ID,
                                    CC_EMP_ID,
                                    CC_PAR_ID
                                )
                                VALUES
                                (
                                    #add_work.max_work_id#,
                                    <cfif len(get_work_cc.cc_emp_id)>#get_work_cc.cc_emp_id#<cfelse>NULL</cfif>,
                                    <cfif len(get_work_cc.cc_par_id)>#get_work_cc.cc_par_id#<cfelse>NULL</cfif>
                                )
                            </cfloop>
                        </cfquery>
                    </cfif>
                </cfif>
                <cfset attributes.work_head = form_work_head>
				<cfif len(task_user_email) and isdefined("attributes.mail#i#")>
					<cfset mail_type_id = 1> 
                    <cfset form.work_id = form_work_id>
					<cfset attributes.work_head = form_work_head>
					<cfset attributes.work_h_start = form_work_h_start>
					<cfset attributes.work_h_finish = form_work_h_finish>
					<cfset mail_emp_id = form_project_emp_id>
                    <cfset attributes.mail_content_from = '#session.ep.company#<#session.ep.company_email#>'>
                    <cfsavecontent variable="message">
                        <cfoutput><cf_get_lang no='362.iş kaydı'></cfoutput>
                    </cfsavecontent>
                    <cfsavecontent variable="additor">
                        <cfoutput>
                            <cfif isdefined('mail_emp_id') and len(mail_emp_id)>
                                #get_emp_info(mail_emp_id,0,0)#
                            </cfif>
                        </cfoutput>
                    </cfsavecontent>
                    <cfsavecontent variable="subject_info"><cf_get_lang_main no="1728.Görevlendirme"></cfsavecontent>
                    <cfset attributes.mail_content_to = task_user_email>
                    <cfset attributes.mail_content_subject = subject_info & '! - ' & attributes.work_head>
                    <cfset attributes.mail_content_additor = additor>
                    <cfset attributes.mail_record_emp='#session.ep.name# #session.ep.surname#'>
                    <cfset attributes.mail_record_date=dateformat(dateadd('h',session.ep.time_zone,now()),dateformat_style) & " " & timeformat(dateadd('h',session.ep.time_zone,now()),timeformat_style)>
                    <cfset attributes.start_date= dateformat(date_add("h",session.ep.time_zone,attributes.work_h_start),dateformat_style) & " " & timeformat(date_add("h",session.ep.time_zone,attributes.work_h_start),timeformat_style) >
                    <cfset attributes.finish_date=dateformat(date_add("h",session.ep.time_zone,attributes.work_h_finish),dateformat_style) & " " & timeformat(date_add("h",session.ep.time_zone,attributes.work_h_finish),timeformat_style)>
                    <cfset attributes.mail_content_info2=get_last_history.work_detail>
                    <cfif len(attributes.project_id)>
                        <cfquery name="Get_Project_Head" datasource="#dsn#">
                            SELECT PROJECT_NUMBER, PROJECT_HEAD FROM #dsn_alias#.PRO_PROJECTS WHERE PROJECT_ID = #attributes.project_id#
                        </cfquery>
                        <cfset attributes.project_head='#Get_Project_Head.Project_Head#'>
                        <cfset attributes.project_id = attributes.project_id>
                    </cfif>
                    <cfsavecontent variable="attributes.mail_content_info"><cf_get_lang no='362.iş kaydı'></cfsavecontent>
                    <cfif len(mail_emp_id)>
                        <cfif cgi.server_port eq 443>
                            <cfset user_domain = "https://#cgi.server_name#">
                        <cfelse>
                            <cfset user_domain = "http://#cgi.server_name#">
                        </cfif>
                        <cfset attributes.mail_content_link = '#user_domain#/#request.self#?fuseaction=project.works&event=det&id=#form_work_id#'>
                    <cfelse>
                        <cfset attributes.mail_content_link = '#partner_domain##request.self#?fuseaction=project.works&event=det&id=#form_work_id#'>
                    </cfif>
                    <cfset attributes.mail_content_link_info = '#attributes.work_head#'>
                    <cfsavecontent variable="attributes.process_stage_info">
                        <cfoutput>
                            <cfif isdefined("attributes.work_process_stage")>#attributes.work_process_stage#<cfelseif isdefined("form_work_currency_id")>#form_work_currency_id#<cfelse>#attributes.process_stage#</cfif>
                        </cfoutput>
                    </cfsavecontent>
                    <cfinclude template="/design/template/info_mail/mail_content.cfm">
                
                
					<!---<cfset form.work_id = form_work_id>
					<cfset attributes.work_head = form_work_head>
					<cfset attributes.work_h_start = form_work_h_start>
					<cfset attributes.work_h_finish = form_work_h_finish>
					<cfset mail_type_id = 1> 
					<cfset mail_emp_id = form_project_emp_id>
					<cfset attributes.mail_content_from = '#session.ep.company#<#session.ep.company_email#>'>
					<cfsavecontent variable="message"><cf_get_lang no='30.Adınıza Yapılmış Yeni Bir Görevlendirme !'></cfsavecontent>
                    <cfif isdefined("session.ep.company_email")>
                        <cfmail to="#task_user_email#" from="#attributes.mail_content_from#" subject="#message#" type="HTML">
                            <cfinclude template="add_work_mail.cfm">
                        </cfmail>
                    </cfif>--->
				</cfif>
                <cf_workcube_process
                is_upd='1' 
                old_process_line='0'
                process_stage='#form_work_currency_id#' 
                record_member='#session.ep.userid#' 
                record_date='#now()#' 
                action_table='PRO_WORKS'
                action_column='WORK_ID'
                action_id='#add_work.max_work_id#'
                action_page='#request.self#?fuseaction=project.works&event=det&id=#add_work.max_work_id#' 
                warning_description = '#getLang("","İlgili İş",66816)# : #attributes.work_head#'>
			</cfif>
		</cfloop>

        <cfif listlen(with_related_work)><!--- İliskili islen varsa bunlar yeni iliskileri ile kaydediliyor --->
        	<cfloop list="#with_related_work#" index="k">
            	<cfquery name="GET_WORKS_RELATED" datasource="#DSN#">
                	SELECT 
                        PRE_ID,
                        WORK_ID,
                        LAG,
                        RELATION_TYPE
                    FROM
	                    PRO_WORK_RELATIONS
                    WHERE
                    	WORK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#k#">
                </cfquery>
                <cfif get_works_related.recordcount>
					<cfoutput query="get_works_related">
                    	<cfquery name="GET_NEW_RELATED_WORK_ID" datasource="#DSN#">			<!--- İliskili isin yeni ID si bulunuyor --->
                        	SELECT AFTER_WORK_ID FROM ##WORK_ID_HISTORY WHERE PREVIOUS_WORK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_works_related.pre_id#">
                        </cfquery>
                        <cfquery name="GET_NEW_WORK_ID" datasource="#DSN#">					<!--- İsin yeni ID si bulunuyor--->
                        	SELECT AFTER_WORK_ID FROM ##WORK_ID_HISTORY WHERE PREVIOUS_WORK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_works_related.work_id#">
                        </cfquery>
                        <cfif get_new_related_work_id.recordcount and get_new_work_id.recordcount>
	                        <cfquery name="INS_PRO_WORK_RELATIONS" datasource="#DSN#">
                                INSERT INTO
                                    PRO_WORK_RELATIONS
                                    (
                                        PRE_ID,
                                        WORK_ID,
                                        LAG,
                                        RELATION_TYPE
                                    )
                                VALUES
                                    (
                                        #get_new_related_work_id.after_work_id#,
                                        #get_new_work_id.after_work_id#,
                                        <cfif len(get_works_related.lag)>#get_works_related.lag#<cfelse>NULL</cfif>,
                                        <cfif len(get_works_related.relation_type)>'#get_works_related.relation_type#'<cfelse>NULL</cfif>
                                    )
                            </cfquery>
                        </cfif>
                    </cfoutput>
                    
                                              
                    <!--- En son iliski sekli Pro_Works tablosuna kaydediliyor --->
                    <cfset new_relation = "">
                    <cfquery name="GET_WORKS" datasource="#DSN#">
                    	SELECT 
                        	PRE_ID,
                            WORK_ID,
                            LAG,
                            RELATION_TYPE
                        FROM 
                        	PRO_WORK_RELATIONS 
                        WHERE 
                        	WORK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_new_work_id.after_work_id#">
                    </cfquery>
                    <cfoutput query="get_works">
						<cfset new_relation = "#new_relation#;#get_works.pre_id##get_works.relation_type#">
                        <cfif len(get_works.lag)>
                            <cfset new_relation = "#new_relation#+#get_works.lag# days">
                        </cfif>
                    </cfoutput>
					<cfif len(new_relation)>
                        <cfquery name="UPD_WORK_RELATED" datasource="#DSN#" result="xxx">
                            UPDATE 
                                PRO_WORKS 
                            SET
                                RELATED_WORK_ID = '#new_relation#;' <!--- ; hem basta hem sonda olsun diye eklendi --->
                            WHERE 
                                WORK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_new_work_id.after_work_id#">
                        </cfquery>
                    </cfif>
                 </cfif>
            </cfloop>
        </cfif>
        <cfif listlen(milestone_work_id_list)>
        	<cfloop list="#milestone_work_id_list#" index="z">
            	<cfquery name="GET_MILESTONE_NEW_ID" datasource="#DSN#">
                	SELECT AFTER_WORK_ID FROM ##WORK_ID_HISTORY WHERE PREVIOUS_WORK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#z#">
                </cfquery>
                <cfif get_milestone_new_id.recordcount>
                    <cfquery name="UPD_MILESTONE" datasource="#DSN#">
                        UPDATE 
                        	PRO_WORKS 
                        SET 
                        	MILESTONE_WORK_ID = #get_milestone_new_id.AFTER_WORK_ID# 
                        WHERE 
                        	MILESTONE_WORK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#z#"> AND
                            WORK_ID IN (SELECT WORK_ID FROM PRO_WORKS WHERE	PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.main_project_id#">)
                    </cfquery>
                </cfif>
            </cfloop>
        </cfif>
	</cftransaction>
</cflock>
<script type="text/javascript">
    <cfif  isdefined("attributes.modal_id") and len(attributes.modal_id)>
        location.href = document.referrer;
    <cfelse>
        wrk_opener_reload();
        window.close();
    </cfif>
</script>
