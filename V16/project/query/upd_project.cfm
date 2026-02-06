

    <cf_date TARIH="attributes.start">
    <cf_date TARIH="attributes.finish">
    <cf_date TARIH="attributes.term_date">
    <cf_date TARIH="attributes.estimated_out_date">
    <cf_date TARIH="attributes.estimated_arrive_date">
        <cfset attributes.pro_h_start = createdatetime(year(attributes.start),month(attributes.start),day(attributes.start),attributes.start_hour,attributes.start_minute,0)>
        <cfset attributes.pro_h_finish = createdatetime(year(attributes.finish),month(attributes.finish),day(attributes.finish),attributes.finish_hour,attributes.finish_minute,0)>
    <cfif isDefined("attributes.project_number") and len(attributes.project_number)>
        <cfquery name="GET_PROJECT_NUMBER" datasource="#dsn#">
            SELECT PROJECT_ID FROM PRO_PROJECTS WHERE PROJECT_ID <><cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.id#"> AND PROJECT_NUMBER = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(attributes.project_number)#">
        </cfquery>
        <cfif get_project_number.recordcount gte 1>
            <script type="text/javascript">
                alert("<cf_get_lang_main no='13.uyarı'>:Proje No <cf_get_lang_main no='781.tekrarı'>!");
                history.back();
            </script>
            <cfabort>
        </cfif>
    </cfif>
    
    <cfif isDefined('attributes.xml_pro_work_date') and attributes.xml_pro_work_date eq 1>
        <cfquery name="GET_PRO_WORKS" datasource="#DSN#">
            SELECT
                WORK_ID
            FROM
                PRO_WORKS
            WHERE
                PROJECT_ID = #form.id# AND
                (TARGET_START < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.pro_h_start#"> OR TARGET_FINISH >  <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.pro_h_finish#">)
        </cfquery>
        <cfif get_pro_works.recordcount>
            <script type="text/javascript">
                alert("<cf_get_lang no ='320.Proje Başlangıç Tarihi ile Bitiş Tarihi Dışında Kalan İş Kayıtları Var ! Ancak Güncelleme İşlemi Gerçekleştirilecektir'> ! ");
                history.back();
            </script>
        </cfif>
    </cfif>
    
    <!--- durum, oncelik, lider ,bas. tarihi, bit. tarihi degisim oldumu history e yazılacak--->
    <cfquery name="GET_PRO_DETAIL" datasource="#DSN#">
        SELECT * FROM PRO_PROJECTS WHERE PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.id#">
    </cfquery>
    <cflock name="#CREATEUUID()#" timeout="20">
        <cftransaction>
            <cfquery name="UPDS_PROJECT" datasource="#dsn#">
                UPDATE 
                    PRO_PROJECTS
                SET 
                    COMPANY_ID = <cfif isdefined("attributes.COMPANY_ID") and len(attributes.COMPANY_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.COMPANY_ID#"><cfelse>NULL</cfif>,
                    PARTNER_ID = <cfif isdefined("attributes.PARTNER_ID") and len(attributes.PARTNER_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.PARTNER_ID#"><cfelse>NULL</cfif>,
                    PROJECT_NUMBER= <cfif isdefined("attributes.PROJECT_NUMBER") and len(attributes.PROJECT_NUMBER)><cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.PROJECT_NUMBER#"><cfelse>NULL</cfif>,
                    CONSUMER_ID = <cfif isdefined("attributes.CONSUMER_ID") and len(attributes.CONSUMER_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.CONSUMER_ID#"><cfelse>NULL</cfif>,
                    PROJECT_FOLDER= <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.PROJECT_FOLDER#">,
                    PROJECT_STATUS = <cfif isDefined("attributes.PROJECT_STATUS")>1<cfelse>0</cfif>,
                    PROJECT_EMP_ID=<cfif isdefined("attributes.PROJECT_EMP_ID") and len(attributes.PROJECT_EMP_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.PROJECT_EMP_ID#"><cfelse>NULL</cfif>,
                    PROJECT_POS_CODE=<cfif isdefined("attributes.PROJECT_POS_CODE") and len(attributes.PROJECT_POS_CODE)><cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.PROJECT_POS_CODE#"><cfelse>NULL</cfif>,
                    OUTSRC_CMP_ID=<cfif isdefined("attributes.OUTSRC_CMP_ID") and len(attributes.OUTSRC_CMP_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.OUTSRC_CMP_ID#"><cfelse>NULL</cfif>,
                    OUTSRC_PARTNER_ID=<cfif isdefined("attributes.OUTSRC_PARTNER_ID") and len(attributes.OUTSRC_PARTNER_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.OUTSRC_PARTNER_ID#"><cfelse>NULL</cfif>,
                    PROJECT_TARGET= <cfif len(attributes.PROJECT_TARGET)><cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.PROJECT_TARGET#"><cfelse>NULL</cfif>,
                    RELATED_PROJECT_ID =<cfif len(attributes.RELATED_PROJECT_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.RELATED_PROJECT_ID#"><cfelse>NULL</cfif>,
                    PROJECT_HEAD=<cfif len(attributes.PROJECT_HEAD)><cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.PROJECT_HEAD#"><cfelse>NULL</cfif>,
                    PROJECT_DETAIL=<cfif len(attributes.PROJECT_DETAIL)><cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.PROJECT_DETAIL#"><cfelse>NULL</cfif>,
                    TARGET_START=<cfif len(attributes.PRO_H_START)><cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.pro_h_start#"><cfelse>NULL</cfif>,
                    TARGET_FINISH=<cfif len(attributes.PRO_H_FINISH)><cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.pro_h_finish#"><cfelse>NULL</cfif>,
                    PRO_CURRENCY_ID=<cfif len(attributes.process_stage)><cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.process_stage#"><cfelse>NULL</cfif>,
                    PRO_PRIORITY_ID=<cfif len(attributes.priority_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.priority_id#"><cfelse>NULL</cfif>,
                    UPDATE_DATE= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,    
                    UPDATE_EMP= <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#">,
                    UPDATE_IP=<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.remote_addr#">,
                    PROCESS_CAT = <cfif isdefined("attributes.main_process_cat") and len(attributes.main_process_cat)><cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.main_process_cat#"><cfelse>NULL</cfif>,
                    EXPENSE_CODE =<cfif isdefined("attributes.EXPENSE_CODE") and len(attributes.EXPENSE_CODE) ><cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.EXPENSE_CODE#"><cfelse>NULL</cfif>,
                    EXPECTED_BUDGET = <cfif isdefined("attributes.EXPECTED_BUDGET") and len(attributes.EXPECTED_BUDGET)><cfqueryparam cfsqltype="cf_sql_float"  value ="#filterNum(attributes.EXPECTED_BUDGET,4)#"><cfelse>NULL</cfif>,
                    EXPECTED_COST = <cfif isdefined("attributes.EXPECTED_COST") and len(attributes.EXPECTED_COST)><cfqueryparam cfsqltype="cf_sql_float"  value ="#filterNum(attributes.EXPECTED_COST,4)#"><cfelse>NULL</cfif>,
                    BUDGET_CURRENCY = <cfif isdefined("attributes.BUDGET_CURRENCY") and len(attributes.BUDGET_CURRENCY)><cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.BUDGET_CURRENCY#"><cfelse>NULL</cfif>,
                    COST_CURRENCY = <cfif isdefined("attributes.COST_CURRENCY") and len(attributes.COST_CURRENCY)><cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.COST_CURRENCY#"><cfelse>NULL</cfif>,
                    AGREEMENT_NO = <cfif isdefined("attributes.agreement_no") and len(attributes.agreement_no)><cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.agreement_no#"><cfelse>NULL</cfif>,
                    WORKGROUP_ID = <cfif isdefined("attributes.workgroup_id") and len(attributes.workgroup_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.workgroup_id#"><cfelse>NULL</cfif>,
                    PRODUCT_ID = <cfif isdefined('attributes.product_id') and len(attributes.product_id) and isdefined('attributes.product_name') and len(attributes.product_name)><cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.product_id#"><cfelse>NULL</cfif>,
                    BRANCH_ID = <cfif isdefined("attributes.branch_id") and len(attributes.branch_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.branch_id#"><cfelse>NULL</cfif>,
                    DEPARTMENT_ID = <cfif len(attributes.location_id) and  len(attributes.department_id)>#listfirst(attributes.department_id,'-')#<cfelse>NULL</cfif>,
                    LOCATION_ID = <cfif len(attributes.department_id) and len(attributes.location_id)>#listlast(attributes.location_id,'-')#<cfelse>NULL</cfif>,
                    COUNTRY_ID = <cfif isdefined("attributes.country_id") and len(attributes.country_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.country_id#"><cfelse>NULL</cfif>,
                    SALES_ZONE_ID = <cfif isdefined("attributes.sales_zone_id") and len(attributes.sales_zone_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.sales_zone_id#"><cfelse>NULL</cfif>,
                    SPECIAL_DEFINITION_ID = <cfif isdefined("attributes.special_definition") and len(attributes.special_definition)><cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.special_definition#"><cfelse>NULL</cfif>,
                    CARGO_COMPANY_ID = <cfif isdefined("attributes.CARGO_COMPANY_ID") and len(attributes.CARGO_COMPANY)><cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.CARGO_COMPANY_id#"><cfelse>NULL</cfif>,
                    DUTY_COMPANY_ID = <cfif isdefined("attributes.DUTY_COMPANY_ID") and len(attributes.DUTY_COMPANY)><cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.DUTY_COMPANY_id#"><cfelse>NULL</cfif>,
                    INSURANCE_COMPANY_ID = <cfif isdefined("attributes.INSURANCE_COMPANY_ID") and len(attributes.INSURANCE_COMPANY)><cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.INSURANCE_COMPANY_id#"><cfelse>NULL</cfif>,
                    TERM_DATE = <cfif isdefined("attributes.TERM_DATE") and len(attributes.TERM_DATE)><cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.TERM_DATE#"><cfelse>NULL</cfif>,
                    ESTIMATED_OUT_DATE = <cfif isdefined("attributes.ESTIMATED_OUT_DATE") and len(attributes.ESTIMATED_OUT_DATE)><cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.ESTIMATED_OUT_DATE#"><cfelse>NULL</cfif>,
                    ESTIMATED_ARRIVE_DATE = <cfif isdefined("attributes.ESTIMATED_ARRIVE_DATE") and len(attributes.ESTIMATED_ARRIVE_DATE)><cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.ESTIMATED_ARRIVE_DATE#"><cfelse>NULL</cfif>,
                    CITY_ID = <cfif isdefined("attributes.city_id") and len(attributes.city_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.city_id#"><cfelse>NULL</cfif>,
                    COUNTY_ID = <cfif isdefined("attributes.county_id") and len(attributes.county_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.county_id#"><cfelse>NULL</cfif>,
                    COORDINATE_1 = <cfif isdefined("attributes.coordinate_1") and len(attributes.coordinate_1)><cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.coordinate_1#"><cfelse>NULL</cfif>,
                    COORDINATE_2 = <cfif isdefined("attributes.coordinate_2") and len(attributes.coordinate_2)><cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.coordinate_2#"><cfelse>NULL</cfif>,
                    LANGUAGE_ID = <cfif isdefined("attributes.dictionary_id") and len(attributes.dictionary_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.dictionary_id#"><cfelse>NULL</cfif>,
                    GOOGLE_PROJECT_FOLDER_ID = <cfif isdefined("attributes.projectFolderId") and len(attributes.projectFolderId)><cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.projectFolderId#"><cfelse>NULL</cfif>
                WHERE 
                    PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.id#">
                </cfquery>
                <cf_wrk_get_history  datasource='#DSN#' source_table= 'PRO_PROJECTS' target_table= 'PRO_HISTORY' record_id= '#attributes.id#' record_name='PROJECT_ID'>
            <!--- Projeye ait cari degistigi an onceki cari ile iliskiyi kesmek gerekli. Analiz sonucu ve sonuc detayları direkt silinir. BK 20090112 --->
        
                <cfquery name="DEL_ANALYSIS_RESULTS_DETAILS" datasource="#DSN#">
                    DELETE FROM MEMBER_ANALYSIS_RESULTS_DETAILS WHERE RESULT_ID IN (SELECT RESULT_ID FROM MEMBER_ANALYSIS_RESULTS WHERE PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.id#">)
                </cfquery>
                <cfquery name="DEL_ANALYSIS_RESULTS_DETAILS" datasource="#DSN#">
                    DELETE FROM MEMBER_ANALYSIS_RESULTS WHERE PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.id#">
                </cfquery>
            
            
            <!---Ek Bilgiler--->
            <cfset attributes.info_id =  attributes.id>
            <cfset attributes.is_upd = 1>
            <cfset attributes.info_type_id = -10>
            <cfinclude template="../../objects/query/add_info_plus2.cfm">
            <cfset attributes.project_id = form.id>
            <!---Ek Bilgiler--->
            <cf_workcube_process 
                is_upd='1' 
                old_process_line='#attributes.old_process_line#'
                process_stage='#attributes.process_stage#' 
                record_member='#session.ep.userid#' 
                record_date='#now()#' 
                action_table='PRO_PROJECTS'
                action_column='PROJECT_ID'
                action_id='#attributes.id#'
                action_page='#request.self#?fuseaction=project.projects&event=upd&id=#attributes.id#'
                warning_description = '#getLang('','Proje No',30886)# : #attributes.project_number#'>
            
         </cftransaction>
    </cflock>  
    
    <cfset attributes.actionId = attributes.id>
    <script type="text/javascript">
        window.location.href = "<cfoutput>#request.self#?fuseaction=project.projects&event=upd&id=#attributes.id#</cfoutput>";
    </script> 
    