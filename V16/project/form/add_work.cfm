<script type="text/javascript">
	$(document).ready(function(e) {
      	$('.area_show .area_head').click(function (e) {
			e.preventDefault();
			$(this).closest('li').find('.area_detail').not(':animated').slideToggle();
		});
		$('.area_show .area_head').click(function (e) {
			e.preventDefault();
			$(this).closest('li').find('area_detail').not(':animated').slideToggle();
		});
    });
</script>
<!---Bu dosya hem popup hemde normal sayfadan çağırıldığı için normal sayfaya göre düzenlenmiştir..--->
<cf_xml_page_edit>
<cfif isdefined("xml_is_work_no") and xml_is_work_no eq 1>
<cf_papers paper_type="WORK">
<cfif len(paper_number)>
	<cfset work_no = paper_code & '-' & paper_number>
<cfelse>
	<cfset work_no = ''>
</cfif>
</cfif>
<cfparam name="liste" default="">
<cfparam name="saat" default="">
<cfparam name="dak" default="">
<cfparam name="attributes.modal_id" default="">
<!--- etkilesimden geliyorsa --->
<cfif isdefined('attributes.cus_help_id') and len(attributes.cus_help_id)>
	<cfquery name="GET_HELP_" datasource="#DSN#">
		SELECT COMPANY_ID, PARTNER_ID, CONSUMER_ID, SUBJECT,SUBSCRIPTION_ID FROM CUSTOMER_HELP WHERE CUS_HELP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.cus_help_id#">
	</cfquery>
	<cfif len(GET_HELP_.SUBSCRIPTION_ID)><!--- etkilesimin iliskili oldugu sistem projesini getirir --->
		<cfquery name="GET_PROJECT_ID" datasource="#DSN3#">
			SELECT PROJECT_ID FROM SUBSCRIPTION_CONTRACT WHERE SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#GET_HELP_.SUBSCRIPTION_ID#">
		</cfquery>
		<cfset attributes.id = get_project_id.project_id>
	</cfif>
	<cfif len(get_help_.consumer_id)>
		<cfset get_project.consumer_id = get_help_.consumer_id>
	</cfif>
	<cfif len(get_help_.partner_id)>
		<cfset get_project.partner_id = get_help_.partner_id>
	</cfif>
	<cfif len(get_help_.subject)>
		<cfset mail_body = get_help_.subject>
	</cfif>
</cfif>
<cfif isdefined("attributes.service_id") and len(attributes.service_id)>
	<cfquery name="GET_SERVICE" datasource="#dsn3#">
		SELECT PROJECT_ID,SERVICE_COMPANY_ID,SERVICE_PARTNER_ID,SERVICE_HEAD FROM SERVICE WHERE SERVICE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.service_id#">
	</cfquery>
	<cfset attributes.work_head_ = get_service.service_head>
	<cfif len(get_service.PROJECT_ID)>
		<cfset attributes.id = get_service.PROJECT_ID>
	</cfif>
	<cfif Len(get_service.service_partner_id)>
		<cfset attributes.company_id = get_service.service_company_id>
		<cfset attributes.partner_id = get_service.service_partner_id>
	</cfif>
</cfif>
<cfif isdefined("attributes.subscription_id") and len(attributes.subscription_id)>
	<cfquery name="GET_SUBSCRIPTION" datasource="#dsn3#">
		SELECT PROJECT_ID FROM SUBSCRIPTION_CONTRACT WHERE SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.subscription_id#">
	</cfquery>
	<cfif len(get_subscription.PROJECT_ID)>
		<cfset attributes.id = get_subscription.PROJECT_ID>
	</cfif>
</cfif>
<cfif isdefined('attributes.id') and len(attributes.id)>
	<cfquery name="GET_PROJECT" datasource="#DSN#">
		SELECT PROJECT_HEAD,COMPANY_ID, CONSUMER_ID, PARTNER_ID,TARGET_START, TARGET_FINISH  FROM PRO_PROJECTS WHERE PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.id#">
	</cfquery>
    <cfset control_project_id = attributes.id>
</cfif>
<cfinclude template="../query/get_pro_work_cat.cfm">
<cfinclude template="../query/get_priority.cfm">
<cfinclude template="../query/get_workgroups.cfm">
<cfquery name="GET_ACTIVITY" datasource="#DSN#">
	SELECT ACTIVITY_ID, #dsn#.Get_Dynamic_Language(SETUP_ACTIVITY.ACTIVITY_ID,'#session.ep.language#','SETUP_ACTIVITY','ACTIVITY_NAME',NULL,NULL,SETUP_ACTIVITY.ACTIVITY_NAME) AS ACTIVITY_NAME FROM SETUP_ACTIVITY WHERE ACTIVITY_STATUS = 1 ORDER BY ACTIVITY_NAME
</cfquery>
<cfset work_company_id = ''>
<cfset work_company_name = ''>
<cfset work_partner_id = ''>
<cfset work_partner_name = ''>
<cfif isdefined('attributes.mail_id')>
	<cfquery name="GET_MAIL_INFO" datasource="#DSN#">
		SELECT SUBJECT, CONTENT_FILE, MAIL_FROM FROM MAILS WHERE MAIL_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.mail_id#">
	</cfquery>
	<cfquery name="CHECK_MAIL_PARTNER" datasource="#DSN#">
		SELECT
			C.NICKNAME,
			CP.COMPANY_ID,
			CP.PARTNER_ID,
			CP.COMPANY_PARTNER_NAME,
			CP.COMPANY_PARTNER_SURNAME
		FROM
			COMPANY_PARTNER CP,
			COMPANY C
		WHERE 
			CP.COMPANY_PARTNER_EMAIL = <cfqueryparam cfsqltype="cf_sql_varchar" value="#get_mail_info.mail_from#"> AND
			CP.COMPANY_ID = C.COMPANY_ID
	</cfquery>
	<cfif check_mail_partner.recordcount>
		<cfset work_company_id = check_mail_partner.company_id>
		<cfset work_company_name = check_mail_partner.nickname>
		<cfset work_partner_id = check_mail_partner.partner_id>
		<cfset work_partner_name = '#check_mail_partner.company_partner_name# #check_mail_partner.company_partner_surname#'>
	<cfelse>
		<cfquery name="CHECK_MAIL_CONSUMER" datasource="#DSN#">
				SELECT CONSUMER_ID, CONSUMER_NAME, CONSUMER_SURNAME, COMPANY FROM CONSUMER WHERE CONSUMER_EMAIL = <cfqueryparam cfsqltype="cf_sql_varchar" value="#get_mail_info.mail_from#">
			</cfquery>
			<cfif check_mail_consumer.recordcount>
				<cfset work_company_id = ''>
				<cfset work_company_name = check_mail_consumer.consumer_id>
				<cfset work_partner_id = check_mail_consumer.partner_id>
				<cfset work_partner_name = '#check_mail_consumer.consumer_name# #check_mail_consumer.consumer_surname#'>
			</cfif>
	</cfif>
  	<cfif FileExists("#upload_folder#mails#dir_seperator#in#dir_seperator##get_mail_info.content_file#")>
    	<cffile action="read" file="#upload_folder#mails#dir_seperator#in#dir_seperator##get_mail_info.content_file#" variable="mail_body" charset ="UTF-8" mode="777">
	</cfif>
</cfif>
<cfparam name="mail_body" default="">
<cfif isdefined('get_project.consumer_id') and len(get_project.consumer_id)>
	<cfquery name="GET_PROJECT_CONSUMER" datasource="#DSN#">
		SELECT CONSUMER_ID, CONSUMER_NAME, CONSUMER_SURNAME, COMPANY FROM CONSUMER WHERE CONSUMER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_project.consumer_id#">
	</cfquery>
  	<cfset work_company_id = ''>
  	<cfset work_company_name = get_project_consumer.company>
  	<cfset work_partner_id = get_project_consumer.consumer_id>
  	<cfset work_partner_name = '#get_project_consumer.consumer_name# #get_project_consumer.consumer_surname#'>
<cfelseif isdefined('get_project.partner_id') and len(get_project.partner_id)>
	<cfquery name="GET_PROJECT_PARTNER" datasource="#DSN#">
		SELECT
			C.NICKNAME,
			CP.COMPANY_ID,
			CP.PARTNER_ID,
			CP.COMPANY_PARTNER_NAME,
			CP.COMPANY_PARTNER_SURNAME
		FROM
			COMPANY_PARTNER CP,
			COMPANY C
		WHERE 
			CP.PARTNER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_project.partner_id#"> AND
			CP.COMPANY_ID = C.COMPANY_ID
	</cfquery>
	<cfset work_company_id = get_project_partner.company_id>
	<cfset work_company_name = get_project_partner.nickname>
	<cfset work_partner_id = get_project_partner.partner_id>
	<cfset work_partner_name = '#get_project_partner.company_partner_name# #get_project_partner.company_partner_surname#'>
</cfif>
<cfif isdefined('attributes.work_id') and len(attributes.work_id)>
	<cfquery name="GET_WORK" datasource="#DSN#">
		SELECT WORK_HEAD,WORK_ID FROM PRO_WORKS WHERE WORK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.work_id#">
	</cfquery>
</cfif>
<cfif isdefined("attributes.company_id") and len(attributes.company_id)>
	<cfset work_company_id = attributes.company_id>
	<cfset work_company_name = get_par_info(attributes.company_id,1,1,0)>
	<cfset work_partner_id = attributes.partner_id>
	<cfset work_partner_name = get_par_info(attributes.partner_id,0,-1,0)>
</cfif>
<cfquery name="GET_SPECIAL_DEFINITION" datasource="#dsn#">
	SELECT SPECIAL_DEFINITION_ID,#dsn#.Get_Dynamic_Language(SETUP_SPECIAL_DEFINITION.SPECIAL_DEFINITION_ID,'#session.ep.language#','SETUP_SPECIAL_DEFINITION','SPECIAL_DEFINITION',NULL,NULL,SETUP_SPECIAL_DEFINITION.SPECIAL_DEFINITION) AS SPECIAL_DEFINITION FROM SETUP_SPECIAL_DEFINITION WHERE SPECIAL_DEFINITION_TYPE = 7
</cfquery>


<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cfsavecontent variable="head"><cf_get_lang dictionary_id='57803.Satış Takımları'></cfsavecontent>
        <cf_box title="#isdefined("attributes.work_id") and len(attributes.work_id)? '#getLang('','Alt İş Ekle',61949)#' : '#getLang('','İşler',58020)# : #getLang('','Yeni Kayıt',45697)#'#" closable="#isdefined("attributes.work_id") and len(attributes.work_id)  or (isdefined("attributes.id")) or (isdefined("attributes.work_detail_id")) ? 1 : 0#" collapsable="0" resize="1" popup_box="#iif(isdefined("attributes.draggable"),1,0)#">
        <cfform name="add_work" id="add_work" method="post" action="#request.self#?fuseaction=project.emptypopup_add_periodic_work">
            <input type="hidden" name="work_detail_id" id="work_detail_id" value="0" />
            <input type="hidden" name="work_id" id="work_id"  value="<cfif isDefined('attributes.work_id') and len(attributes.work_id)><cfoutput>#attributes.work_id#</cfoutput></cfif>">
            <input type="hidden" name="workgroup" id="workgroup" value="0">
            <input type="hidden" name="today" id="today" value="<cfoutput>#DateFormat(now(),dateformat_style)#</cfoutput>">
            <cfif isdefined('attributes.id') and len(attributes.id)>
                <cfoutput><input type="hidden" name="id" id="id" value="#attributes.id#" /></cfoutput>
            </cfif>
            <cfif IsDefined("xml_waste_of_time")><input type="hidden" name="xml_waste_of_time" id="xml_waste_of_time" value="<cfoutput>#xml_waste_of_time#</cfoutput>"></cfif>
            <input type="hidden" name="forum_reply_id" id="forum_reply_id" value="<cfif isdefined("attributes.forum_reply_id")><cfoutput>#attributes.forum_reply_id#</cfoutput></cfif>">
            <input type="hidden" name="g_service_id" id="g_service_id" value="<cfif isdefined("attributes.g_service_id")><cfoutput>#attributes.g_service_id#</cfoutput></cfif>">
            <input type="hidden" name="service_id" id="service_id" value="<cfif isdefined("attributes.service_id")><cfoutput>#attributes.service_id#</cfoutput></cfif>">
            <input type="hidden" name="assetp_id" id="assetp_id" value="<cfif isdefined('attributes.assetp_id')><cfoutput>#attributes.assetp_id#</cfoutput></cfif>">
            <input type="hidden" name="our_company_id" id="our_company_id" value="<cfoutput>#session.ep.company_id#</cfoutput>">
            <cfif isdefined('attributes.cus_help_id') and len(attributes.cus_help_id)><input type="hidden" name="cus_help_id" id="cus_help_id" value="<cfoutput>#attributes.cus_help_id#</cfoutput>"></cfif>
            <cfif isdefined("attributes.opp_id")><input type="hidden" name="opp_id" id="opp_id" value="<cfoutput>#attributes.opp_id#</cfoutput>"></cfif>
            <cfif isdefined("attributes.product_sample_id")><input type="hidden" name="product_sample_id" id="product_sample_id" value="<cfoutput>#attributes.product_sample_id#</cfoutput>"></cfif>
            <cfif isdefined("attributes.subscription_id")><input type="hidden" name="subscription_id" id="subscription_id" value="<cfoutput>#attributes.subscription_id#</cfoutput>"></cfif>
            <cfif isdefined("attributes.our_comp")><input type="hidden" name="our_comp" id="our_comp" value="<cfoutput>#attributes.our_comp#</cfoutput>"></cfif>
            <cfif isdefined("attributes.event_plan_row_id") and len(attributes.event_plan_row_id)>
                <input type="hidden" name="event_plan_row_id" id="event_plan_row_id" value="<cfoutput>#attributes.event_plan_row_id#</cfoutput>"/>
            </cfif>
            <input type="hidden" name="xml_is_work_no" id="xml_is_work_no" value="<cfoutput>#xml_is_work_no#</cfoutput>">
            <cfif IsDefined("xml_link")><input type="hidden" name="is_xml_link" id="is_xml_link" value="#xml_link#"></cfif>
            <cfsavecontent variable="title1"><cf_get_lang dictionary_id='58131.Temel Bilgiler'></cfsavecontent>
            <cfsavecontent variable="title2"><cf_get_lang dictionary_id='30219.Ek Bilgiler'></cfsavecontent>
                <cfsavecontent variable="title3"><cf_get_lang dictionary_id='58773.Bilgi Verilecekler'></cfsavecontent>
                <cf_tab divID = "sayfa_1,sayfa_2,sayfa_3" defaultOpen="sayfa_1" divLang = "#title1#;#title2#;#title3#" tabcolor = "fff">              
                    <div id = "unique_sayfa_1" class = "uniqueBox">
                        <cf_box_elements id="genel_bilgiler" vertical="1">
                            <div class="col col-12 col-md-12 col-sm-12 col-xs-12" type="column" index="4" sort="true">
                                <div class="form-group" id="form_ul_work_head">
                                    <label class="col col-12 col-md-12 col-sm-12 col-xs-12 padding-0"><cf_get_lang dictionary_id='57480.Konu'> *</label>
                                    <div class="col col-12 col-md-12 col-sm-12 col-xs-12 padding-0">
                                        <cfif isdefined("attributes.mail_id")>
                                            <cfset attributes.work_head_ = get_mail_info.subject>
                                    <cfelseif isdefined('attributes.cus_help_id')>
                                            <cfset attributes.work_head_ = "Etkileşim: " & attributes.cus_help_id>
                                    <cfelseif not isDefined("work_head_")>
                                            <cfset attributes.work_head_ = "">
                                    </cfif>
                                    <input type="text" name="work_head" id="work_head" required="yes"  maxlength="250" value="<cfoutput>#attributes.work_head_#</cfoutput>">
                                    </div>
                                </div>
                                <cfif isdefined('attributes.mail_id')>
                                    <cfset mail_body = HTMLCodeFormat(mail_body)>
                                </cfif>
                                <div class="form-group" id="item-editor">
                                    <label style="display:none!important;"><cf_get_lang dictionary_id='57771.Detay'></label>	
                                    <cfmodule
                                        template="/fckeditor/fckeditor.cfm"
                                        toolbarset="Basic"
                                        basepath="/fckeditor/"
                                        instancename="work_detail"
                                        valign="top"
                                        value="#mail_body#"
                                        width="600"
                                        height="180">
                                </div>
                            </div>
                            <div class="col col-4 col-md-4 col-sm-6 col-xs-12 padding-0" type="column" index="1" sort="true">
                                <div class="form-group " id="form_ul_responsable_name">
                                    <label class="col col-12 col-xs-12"><cf_get_lang dictionary_id='57569.Görevli'>*</label>
                                    <div class="col col-12 col-xs-12">
                                        <div class="input-group">
                                            <input type="hidden" name="task_company_id" id="task_company_id" value="">
                                            <input type="hidden" name="task_partner_id" id="task_partner_id" value="">
                                            <cfif isdefined("attributes.project_emp_id")>
                                                <input type="hidden" name="project_emp_id" id="project_emp_id" value="<cfoutput>#attributes.project_emp_id#</cfoutput>">
                                                <cfinput type="text" name="responsable_name" id="responsable_name" value="#get_emp_info(attributes.project_emp_id,0,0)#"  onFocus="AutoComplete_Create('responsable_name','MEMBER_NAME,MEMBER_PARTNER_NAME2','MEMBER_PARTNER_NAME2,MEMBER_NAME2','get_member_autocomplete','\'1,3\',0,0','EMPLOYEE_ID','project_emp_id,task_company_id,task_partner_id','','3','200','get_company()');">
                                            <cfelseif isdefined("attributes.mail_id")>
                                                <input type="hidden" name="project_emp_id" id="project_emp_id" value="<cfoutput>#session.ep.userid#</cfoutput>">
                                                <cfif xml_only_employee eq 1>
                                                    <cfinput type="text" name="responsable_name" id="responsable_name" value="#session.ep.name# #session.ep.surname#"  onFocus="AutoComplete_Create('responsable_name','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','\'3\',0,0','EMPLOYEE_ID','project_emp_id','','3','200','get_company()');">
                                                <cfelse>
                                                    <cfinput type="text" name="responsable_name" id="responsable_name" value="#session.ep.name# #session.ep.surname#"  onFocus="AutoComplete_Create('responsable_name','MEMBER_NAME,MEMBER_PARTNER_NAME2','MEMBER_PARTNER_NAME2,MEMBER_NAME2','get_member_autocomplete','\'1,3\',0,0','EMPLOYEE_ID','project_emp_id,task_company_id,task_partner_id','','3','200','get_company()');">
                                                </cfif>
                                            <cfelse>
                                                <input type="hidden" name="project_emp_id" id="project_emp_id" value="">
                                                <!--- Not : tree_category_id degerleri call_center basvurularindan gonderiliyor FBS 20081201 --->
                                                <cfif xml_only_employee eq 1>																					
                                                    <cfinput type="text" name="responsable_name" id="responsable_name" value=""  onFocus="AutoComplete_Create('responsable_name','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','\'3\',0,0','EMPLOYEE_ID','project_emp_id','','3','200','get_company()');">
                                                <cfelse>
                                                    <cfinput type="text" name="responsable_name" id="responsable_name" value=""  onFocus="AutoComplete_Create('responsable_name','MEMBER_NAME,MEMBER_PARTNER_NAME2','MEMBER_PARTNER_NAME2,MEMBER_NAME2','get_member_autocomplete','\'1,3\',0,0','COMPANY_ID,PARTNER_ID,EMPLOYEE_ID','task_company_id,task_partner_id,project_emp_id','','3','200','get_company()');">
                                                </cfif>
                                            </cfif>
                                            <span class="input-group-addon icon-ellipsis btnPointer" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_list_positions&field_partner=add_work.task_partner_id&field_comp_id=add_work.task_company_id&field_emp_id=add_work.project_emp_id&field_name=add_work.responsable_name<cfif isdefined("url.tree_category_id")>&tree_category_id=#url.tree_category_id#&select_list=1<cfelse>&select_list=1,2</cfif><cfif isdefined("url.process_date")>&process_date=#url.process_date#<cfelse>&process_date=' + document.add_work.startdate_plan.value + '</cfif></cfoutput>');"></span>
                                        </div>
                                    </div>
                                </div>                         
                                <div class="form-group" id="form_ul_process_stage">
                                    <label class="col col-12 col-xs-12"><cf_get_lang dictionary_id="58859.Süreç">*</label>
                                    <div class="col col-12 col-xs-12">
                                        <cfif isdefined("xml_is_stage_cat") and xml_is_stage_cat eq 1>
                                            <div id="stage1" style="display:none;"></div>
                                        <cfelse>
                                            <cf_workcube_process is_upd='0' is_detail="0">
                                        </cfif>
                                    </div>
                                </div> 
                                <div class="form-group" id="form_ul_estimated_time">
                                    <label class="col col-12 col-xs-12"><cf_get_lang dictionary_id='38215.Öngörülen Süre'></label>
                                    <div class="col col-12 col-xs-12">
                                        <div class="input-group">
                                                <cfsavecontent variable="message"><cf_get_lang dictionary_id='38136.Tahmini Süre girmelisiniz'></cfsavecontent>
                                                <cfif isdefined('xml_is_work_finishdate') and xml_is_work_finishdate eq 1>
                                                    <cfinput type="text" name="estimated_time" id="estimated_time" validate="integer" placeHolder="#getLang('','',57491)#" onKeyUp="isNumber(this);" value="#saat#"  onBlur="estimated_finishdate(this.value,'hour')">
                                                <cfelse>
                                                    <cfinput type="text" name="estimated_time" id="estimated_time" validate="integer" placeHolder="#getLang('','',57491)#"  onKeyUp="isNumber(this);" value="#saat#" >
                                                </cfif>
                                                <span class="input-group-addon no-bg "></span>
                                                <cfif isdefined('xml_is_work_finishdate') and xml_is_work_finishdate eq 1>
                                                    <cfsavecontent variable="message"><cf_get_lang dictionary_id='31894.0-59 Arası Giriniz'></cfsavecontent>
                                                    <cfinput type="text" name="estimated_time_minute"  id="estimated_time_minute" value="#dak#" range="0,59" placeHolder="#getLang('','',58827)#" onKeyUp="isNumber(this);" onBlur="estimated_finishdate(this.value,'minute')" message="#message#">							  
                                                <cfelse>
                                                    <cfsavecontent variable="message"><cf_get_lang dictionary_id='31894.0-59 Arası Giriniz'></cfsavecontent>
                                                    <cfinput type="text" name="estimated_time_minute" id="estimated_time_minute" value="#dak#" range="0,59"  placeHolder="#getLang('','',58827)#" onKeyUp="isNumber(this);"  message="#message#">
                                                </cfif>
                                                
                                        </div>
                                    </div>
                                </div>   
                                <div class="form-group" id="form_ul_terminate_date" >
                                    <label class="col col-12 col-xs-12"><cf_get_lang dictionary_id='38146.Termin'></label>
                                    <div class="col col-8 col-xs-12">
                                        <div class="input-group">
                                            <cfinput validate="#validate_style#" maxlength="10" type="text" id="terminate_date" name="terminate_date" value="" >
                                            <span class="input-group-addon"><cf_wrk_date_image date_field="terminate_date" c_position="Tl"></span>
                                        </div>	                           
                                    </div>   
                                    <div class="col col-4 col-xs-12">
                                        <cfoutput>
                                            <cf_wrkTimeFormat name="terminate_hour" value="0">                                      
                                        </cfoutput>
                                    </div>
                                </div>                            
                            </div>
                            <div class="col col-4 col-md-4 col-sm-6 col-xs-12 padding-0" type="column" id="stage2" index="2" sort="true">
                                <div class="form-group " id="form_ul_project_head">
                                    <label class="col col-12 col-xs-12"><cf_get_lang dictionary_id='57416.Proje'><cfif isdefined("xml_project_required") and xml_project_required eq 1>*</cfif></label>
                                    <div class="col col-12 col-xs-12">
                                        <div class="input-group">
                                            <cfif isdefined('attributes.id') and len(attributes.id)>
                                                <cfscript>
                                                    sdate=date_add("h", session.ep.time_zone,len(get_project.target_start) ? get_project.target_start : now());
                                                    fdate=date_add("h", session.ep.time_zone,len(get_project.target_finish)?get_project.target_finish : now());
                                                    shour=datepart("h",sdate);
                                                    fhour=datepart("h",fdate);
                                                </cfscript>
                                            </cfif>
                                            <input type="hidden" name="project_id" id="project_ids" value="<cfif isdefined('attributes.id') and len(attributes.id)><cfoutput>#attributes.id#</cfoutput></cfif>">
                                            <input type="hidden" name="sdate" id="sdate" value="<cfif isdefined('attributes.id') and len(attributes.id)><cfoutput>#dateformat(sdate,dateformat_style)#</cfoutput></cfif>">
                                            <input type="hidden" name="fdate" id="fdate" value="<cfif isdefined('attributes.id') and len(attributes.id)><cfoutput>#dateformat(fdate,dateformat_style)#</cfoutput></cfif>">
                                            <input type="text" name="project_head"  id="addtowork"  onchange="delete_project();" onfocus="AutoComplete_Create('addtowork','PROJECT_HEAD','PROJECT_HEAD,FULLNAME','get_project','','PROJECT_ID,TARGET_START,TARGET_FINISH<cfif isDefined('xml_company_detail_by_project') and xml_company_detail_by_project eq 1>,COMPANY_ID,MEMBER_PARTNER_NAME2,PARTNER_ID</cfif>','project_ids,sdate,fdate<cfif isDefined('xml_company_detail_by_project') and xml_company_detail_by_project eq 1>,company_id,about_company,company_partner_id</cfif>','','3','200','add_milestone();');" value="<cfif isdefined('attributes.id') and len(attributes.id)><cfoutput>#get_project.PROJECT_HEAD#</cfoutput></cfif>" autocomplete="off">
                                            <span class="input-group-addon icon-ellipsis btnPointer" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_list_projects&project_head=add_work.addtowork&project_id=add_work.project_ids&sdate=add_work.sdate&fdate=add_work.fdate<cfif isDefined('xml_company_detail_by_project') and xml_company_detail_by_project eq 1>&company_id=add_work.company_id&company_name2=add_work.about_company&partner_id=add_work.company_partner_id</cfif>&function_name=add_milestone</cfoutput>');"></span>
                                            
                                        </div>
                                    </div>
                                </div>
                                <div class="form-group" id="form_ul_pro_work_cat">
                                    <label class="col col-12 col-xs-12"><cf_get_lang dictionary_id='38177.İş Kategorisi'>*</label>
                                    <div class="col col-12 col-xs-12">
                                        <select name="pro_work_cat" id="pro_work_cat"  onchange="tmplt();">
                                            <option value="" selected="selected"><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                            <cfoutput query="get_work_cat">
                                                <option value="#work_cat_id#"<cfif isDefined('attributes.pro_work_cat') and attributes.pro_work_cat eq work_cat_id>selected</cfif>>#work_cat#</option>
                                            </cfoutput>
                                        </select>
                                    </div>
                                </div>
                                <div class="form-group" id="form_ul_priority_cat">
                                    <label class="col col-12 col-xs-12"><cf_get_lang dictionary_id='57485.Öncelik'>*</label>
                                    <div class="col col-12 col-xs-12">
                                        <select name="priority_cat" id="priority_cat" >
                                        <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                            <cfoutput query="get_cats">
                                                <option value="#priority_id#">#priority#</option>
                                            </cfoutput>
                                        </select>
                                    </div>
                                </div>
                                <div class="form-group" id="form_ul_activity_type">
                                    <label class="col col-12 col-xs-12"><cf_get_lang dictionary_id='38378.Aktivite Tipi'></label>
                                    <div class="col col-12 col-xs-12">
                                        <select name="activity_type" id="activity_type" >
                                        <option value=""><cf_get_lang dictionary_id ='57734.Seçiniz'></option>
                                            <cfoutput query="get_activity">
                                                <option value="#ACTIVITY_ID#">#ACTIVITY_NAME#</option>
                                            </cfoutput>
                                        </select>
                                    </div>
                                </div>
                            </div>
                            <div class="col col-4 col-md-4 col-sm-6 col-xs-12 padding-0" type="column" index="3" sort="true">
                                <div class="form-group" id="form_ul_milestone_work_id">
                                    <label class="col col-12 col-xs-12"><input type="checkbox" value="1" name="is_milestone" id="is_milestone">Milestone</label>
                                    <div class="col col-12 col-xs-12">
                                        <cfif isdefined("attributes.work_id") and len(attributes.work_id) and isdefined('attributes.id') and len(attributes.id)>
                                            <cfquery name="get_milestone_work" datasource="#DSN#">
                                                SELECT WORK_ID,WORK_HEAD,TARGET_FINISH,TARGET_START FROM PRO_WORKS WHERE PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.id#"> AND WORK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.work_id#">
                                            </cfquery>
                                            <cfscript>
                                                milestone_sdate=date_add("h", session.ep.time_zone,len(get_milestone_work.target_start) ? get_milestone_work.target_start : now());
                                                milestone_fdate=date_add("h", session.ep.time_zone,len(get_milestone_work.target_finish) ? get_milestone_work.target_finish : now());
                                            </cfscript>
                                            <input type="hidden" name="milestone_sdate" id="milestone_sdate" value="<cfoutput>#dateformat(milestone_sdate,dateformat_style)#</cfoutput>">
                                            <input type="hidden" name="milestone_fdate" id="milestone_fdate" value="<cfoutput>#dateformat(milestone_fdate,dateformat_style)#</cfoutput>">
                                        </cfif>
                                        <select name="milestone_work_id" id="milestone_work_id" >
                                            <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                            <cfif isdefined('attributes.id') and len(attributes.id)>
                                                <cfquery name="GET_WORK_MILESTONE" datasource="#DSN#">
                                                    SELECT WORK_ID,WORK_HEAD FROM PRO_WORKS WHERE PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.id#"> AND IS_MILESTONE = 1
                                                </cfquery>
                                                <cfoutput query="get_work_milestone">
                                                    <option value="#work_id#" <cfif isdefined("attributes.work_id") and attributes.work_id eq work_id>selected</cfif>>#work_head#</option>
                                                </cfoutput>
                                            </cfif>
                                        </select>
                                    </div>
                                </div>
                                <div class="form-group" id="item-work_fuse">
                                    <label class="col col-12 col-xs-12">Workfuse</label>
                                    <div class="col col-12 col-xs-12">
                                        <div class="input-group">
                                            <input name="work_fuse" type="text" id="work_fuse" value="<cfoutput>#attributes.work_fuse#</cfoutput>">
                                            <span class="input-group-addon btnPointer icon-link" onclick="window.open('<cfoutput>#request.self#?fuseaction=#attributes.work_fuse#</cfoutput>','_blank');"></span>
                                        </div>
                                    </div>
                                </div>
                                <div class="form-group" id="form_ul_work_status">
                                    <label class="col col-12 col-xs-12"><cf_get_lang dictionary_id='57493.Aktif'><input type="checkbox" name="work_status" id="work_status" checked="checked" /></label>
                                    <label class="col col-12 col-xs-12"><cf_get_lang dictionary_id="57475.Mail Gönder"><input type="checkbox" name="is_mail" id="is_mail" value="1"<cfif isdefined("xml_is_send_mail") and xml_is_send_mail eq 1>checked="checked"</cfif>></label>
                                    <label class="col col-12 col-xs-12"><cf_get_lang dictionary_id='38134.Rework'><input type="checkbox" value="1" name="rework" id="rework"></label>
                                </div>
                            </div>                            
                        </cf_box_elements>
                    </div>
                    <div id = "unique_sayfa_2" class = "uniqueBox">
                        <cf_box_elements id="is_plani" vertical="1">              
                            <div class="col col-4 col-md-4 col-sm-6 col-xs-12 padding-0" type="column" index="5" sort="true">  
                                <div class="form-group " id="form_ul_about_company">
                                    <label class="col col-12 col-xs-12"><cf_get_lang dictionary_id='57574.Şirket'> - <cf_get_lang dictionary_id='57578.Yetkili'></label>
                                    <div class="col col-12 col-xs-12">
                                        <div class="input-group">
                                            <input type="text" name="about_company" id="about_company"  value="<cfoutput>#work_company_name#</cfoutput>" onfocus="AutoComplete_Create('about_company','MEMBER_PARTNER_NAME3','MEMBER_PARTNER_NAME3','get_member_autocomplete','\'1,2\',0,0','COMPANY_ID,PARTNER_ID','company_id,company_partner_id','','3','150');">
                                            <span class="input-group-addon icon-ellipsis btnPointer" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_list_pars&field_comp_id=add_work.company_id&field_name=add_work.about_company&field_id=add_work.company_partner_id&par_con=1&select_list=7</cfoutput>')"></span>
                                            <input type="hidden" name="company_partner_id" id="company_partner_id" value="<cfoutput>#work_partner_id#</cfoutput>">
                                            <input type="hidden" name="company_id" id="company_id" value="<cfoutput>#work_company_id#</cfoutput>">
                                        </div>
                                    </div>
                                </div>
                                <div class="form-group" id="form_ul_work_no">
                                    <label class="col col-12 col-xs-12"><cf_get_lang dictionary_id='38472.İş No'></label>
                                    <div class="col col-12 col-xs-12">
                                    <cfif isdefined("xml_is_work_no") and xml_is_work_no eq 1>
                                        <input type="text" name="work_no" id="work_no" value="<cfoutput>#work_no#</cfoutput>" readonly="readonly" maxlength="20">
                                    <cfelse>
                                        <cfinput type="text" name="work_no" id="work_no" maxlength="20" value=""  />
                                    </cfif>
                                    </div>
                                </div>                              
                                <cfif isdefined('upd_work.estimated_time') and len(upd_work.estimated_time)>
                                    <cfset liste = upd_work.estimated_time/60>
                                    <cfset saat = listfirst(liste,'.')>
                                    <cfset dak = upd_work.estimated_time-saat*60>
                                </cfif>
                                <div class="form-group" id="form_ul_startdate_plan" >
                                    <label class="col col-12 col-xs-12"><cf_get_lang dictionary_id='58053.Başlangıç Tarihi'>*</label>
                                    <div class="col col-12 col-xs-12">
                                        <div class="input-group">
                                                <cfif xml_is_today_before eq 1>
                                                    <cfsavecontent variable="message"><cf_get_lang dictionary_id="58194.Zorunlu Alan"> : <cf_get_lang dictionary_id='58053.Başlangıç Tarihi'></cfsavecontent>
                                                    <cfif isdefined('xml_is_work_finishdate') and xml_is_work_finishdate eq 1>
                                                        <cfinput name="startdate_plan" id="startdate_plan" required="Yes" validate="#validate_style#" message="#message#" maxlength="10" type="text"  value="#DateFormat(now(),dateformat_style)#"  onChange="estimated_finishdate(this.value,'hour')">
                                                    <cfelse>
                                                        <cfinput name="startdate_plan" id="startdate_plan" required="Yes" validate="#validate_style#" message="#message#" maxlength="10" type="text" value="#DateFormat(now(),dateformat_style)#" >	
                                                    </cfif>
                                                    <span class="input-group-addon"><cf_wrk_date_image date_field="startdate_plan" c_position="Tl"></span>
                                                <cfelse>
                                                    <cfsavecontent variable="message"><cf_get_lang dictionary_id="58194.Zorunlu Alan"> : <cf_get_lang dictionary_id='58053.Başlangıç Tarihi'></cfsavecontent>
                                                    <cfif isdefined('xml_is_work_finishdate') and xml_is_work_finishdate eq 1>
                                                        <cfinput name="startdate_plan" id="startdate_plan" required="Yes" validate="#validate_style#" message="#message#" maxlength="10" type="text" value="#DateFormat(now(),dateformat_style)#"  onChange="estimated_finishdate(this.value,'hour')" readonly>
                                                    <cfelse>
                                                        <cfinput name="startdate_plan" id="startdate_plan" required="Yes" validate="#validate_style#" message="#message#" maxlength="10" type="text" value="#DateFormat(now(),dateformat_style)#"  readonly>	
                                                    </cfif>
                                                    <span class="input-group-addon"><cf_wrk_date_image date_field="startdate_plan" min_date="#dateformat(now(),'yyyymmdd')#" c_position="Tl"></span>
                                                </cfif>     
                                            <cfif xml_show_planned_hour eq 1>
                                                <cfoutput>
                                                    <span class="input-group-addon no-bg"></span>
                                                    <cfif isdefined('xml_is_work_finishdate') and xml_is_work_finishdate eq 1>
                                                    <cf_wrkTimeFormat name="start_hour" value="0"  onchange="estimated_finishdate(this.value,'hour')">
                                                    <cfelse>
                                                    <cf_wrkTimeFormat name="start_hour" value="0">
                                                    </cfif>                                        
                                                </cfoutput>
                                            <cfelse>
                                                <input type="hidden" name="start_hour" id="start_hour" value="8">
                                            </cfif>
                                        </div>	                           
                                    </div>   
                                </div>
                                <div class="form-group" id="form_ul_finishdate_plan" >
                                    <label class="col col-12 col-xs-12"><cf_get_lang dictionary_id='57700.Bitiş Tarihi'>*</label>
                                    <div class="col col-12 col-xs-12">
                                        <div class="input-group">
                                            <cfif xml_is_today_before eq 1>
                                                <cfsavecontent variable="message"><cf_get_lang dictionary_id="58194.Zorunlu Alan"> : <cf_get_lang dictionary_id='57700.Bitiş Tarihi'></cfsavecontent>
                                                <cfinput required="Yes" validate="#validate_style#" maxlength="10" message="#message#" type="text"  id="finishdate_plan" name="finishdate_plan" value="" >
                                                <span class="input-group-addon"><cf_wrk_date_image date_field="finishdate_plan" c_position="Tl"></span>
                                            <cfelse>
                                                <cfsavecontent variable="message"><cf_get_lang dictionary_id="58194.Zorunlu Alan"> : <cf_get_lang dictionary_id='57700.Bitiş Tarihi'></cfsavecontent>
                                                <cfinput required="Yes" validate="#validate_style#" maxlength="10" message="#message#" type="text"  id="finishdate_plan" name="finishdate_plan" value=""  readonly>
                                                <span class="input-group-addon"><cf_wrk_date_image date_field="finishdate_plan" min_date="#dateformat(now(),'yyyymmdd')#" c_position="Tl"></span>
                                            </cfif>
                                            <cfif xml_show_planned_hour eq 1>
                                                <cfoutput>
                                                    <span class="input-group-addon no-bg"></span>
                                                    <cf_wrkTimeFormat name="finish_hour_plan" value="0">                                         
                                                </cfoutput>
                                            <cfelse>
                                                <input type="hidden" name="finish_hour_plan" id="finish_hour_plan" value="23" >
                                            </cfif>
                                        </div>	                           
                                    </div>   
                                </div>
                                <div class="form-group" id="form_ul_predicted_start" >
                                    <label class="col col-12 col-xs-12"><cf_get_lang dictionary_id='29685.Tahmini'><cf_get_lang dictionary_id='58053.Başlama Tarihi'></label>
                                    <div class="col col-8 col-xs-12">
                                        <div class="input-group">
                                            <cfif isdefined('psdate') and len(psdate)>
                                                <cfinput type="text" name="predicted_start" id="predicted_start" value=""  maxlength="10" validate="#validate_style#" >
                                            <cfelse>
                                                <cfinput type="text" name="predicted_start" id="predicted_start" value=""  maxlength="10" validate="#validate_style#" >
                                            </cfif>
                                            <span class="input-group-addon"><cf_wrk_date_image date_field="predicted_start" c_position="Tl"></span>
                                        </div>
                                    </div>
                                    <div class="col col-4 col-xs-12">
                                        <cf_wrkTimeFormat name="predicted_start_hour" value="0">      
                                    </div>   
                                </div>
                                <div class="form-group" id="form_ul_predicted_finish" >
                                    <label class="col col-12 col-xs-12"><cf_get_lang dictionary_id='29685.Tahmini'><cf_get_lang dictionary_id='57700.Bitiş Tarihi'></label>
                                    <div class="col col-8 col-xs-12">
                                        <div class="input-group">
                                            <cfif isdefined('pfdate') and len(pfdate)>
                                                <cfinput name="predicted_finish" id="predicted_finish" value="" maxlength="10" validate="#validate_style#" type="text" >
                                            <cfelse>
                                                <cfinput name="predicted_finish" id="predicted_finish" value="" maxlength="10" validate="#validate_style#" type="text" >
                                            </cfif>
                                            <span class="input-group-addon"><cf_wrk_date_image date_field="predicted_finish" c_position="Tl"></span>
                                        </div>
                                    </div>
                                    <div class="col col-4 col-xs-12">
                                        <cfoutput>
                                        <cf_wrkTimeFormat name="predicted_finish_hour"  value="0">                                  
                                        </cfoutput>
                                    </div>	   
                                </div>                  
                            </div>
                            <div class="col col-4 col-md-4 col-sm-6 col-xs-12 padding-0" type="column" index="6" sort="true">
                                <cfif session.ep.our_company_info.workcube_sector is 'tersane'>
                                    <div class="form-group " id="form_ul_pbs_code" >
                                        <label class="col col-12 col-xs-12"><cf_get_lang dictionary_id='38131.PBS Kodu'></label>
                                        <div class="col col-12 col-xs-12">
                                            <div class="input-group">
                                                <input type="hidden" name="pbs_id" id="pbs_id" value="">
                                                <input name="pbs_code" id="pbs_code" type="text"  value="" autocomplete="off">
                                                <span class="input-group-addon icon-ellipsis btnPointer" onclick="pencere_ac_pbs_code();"></span>
                                            </div>
                                        </div>
                                    </div>
                                </cfif>
                                <div class="form-group" id="form_ul_total_time_minute">
                                    <label class="col col-12 col-xs-12"><cf_get_lang dictionary_id='38306.Gerçekleşen Süre'></label>
                                    <div class="col col-12 col-xs-12">
                                        <div class="input-group">
                                                <cfsavecontent variable="message">0-59 <cf_get_lang dictionary_id='38295.Arası Giriniz'>!</cfsavecontent>
                                                <input type="text" name="total_time_hour" id="total_time_hour" value="" placeHolder="<cfoutput>#getLang('','',57491)#</cfoutput>" onkeyup="isNumber(this);">
                                                <span class="input-group-addon no-bg"></span>
                                                <cfinput type="text" name="total_time_minute" id="total_time_minute" value=""  placeHolder="#getLang('','',58827)#" range="0,59" onKeyUp="isNumber(this);" message="#message#">
                                        </div>
                                    </div>
                                </div>                            
                                <div class="form-group" id="form_ul_warning">
                                    <label class="col col-12 col-xs-12"><cf_get_lang dictionary_id='38267.İş Tekrarı'></label>
                                    <div class="col col-12 col-xs-12">
                                        <select name="warning" id="warning" onchange="show_warn(this.selectedIndex);" >
                                            <option value="0" selected><cf_get_lang dictionary_id='58546.Yok'></option>
                                            <option value="1"><cf_get_lang dictionary_id='38205.Periodik'></option>
                                        </select>
                                    </div>
                                </div>
                                <div class="form-group" id="form_ul_warning_type">
                                    <div>
                                        <label class="col col-12 col-xs-12"><cf_get_lang dictionary_id='38185.Tekrar'></label>
                                        <label><cf_get_lang dictionary_id='38230.Haftada Bir'><input type="radio" name="warning_type" id="warning_type" value="7"></label>
                                        <label><cf_get_lang dictionary_id='38232.Ayda Bir'><input type="radio" name="warning_type" id="warning_type" value="30"></label>
                                    </div>
                                </div>
                                <div class="form-group" id="form_ul_warning_count">
                                    <label class="col col-12 col-xs-12"><cf_get_lang dictionary_id='38229.Tekrar Sayısı'></label>
                                    <div class="col col-12 col-xs-12">
                                        <div class="input-group">
                                            <cfsavecontent variable="message5"><cf_get_lang dictionary_id='38277.Tekrar Sayısı Tam Sayı Olmalıdır'>!</cfsavecontent>
                                            <cfinput type="text" name="warning_count" id="warning_count" value="" validate="integer" message="#message5#" >
                                            <span class="input-group-addon no-bg"><cf_get_lang dictionary_id='38228.Kez'></span>
                                        </div>
                                    </div>
                                </div>
                                <div class="form-group" id="form_ul_average_amount">
                                    <label class="col col-12 col-xs-12"><cf_get_lang dictionary_id='29685.Tahmini'><cf_get_lang dictionary_id='57635.Miktar'></label>
                                    <div class="col col-8 col-xs-12">
                                            <cfinput type="text" name="average_amount" id="average_amount" value=""  passthrough="onkeyup=""return(formatcurrency(this,event));""" class="moneybox">
                                            <cfquery name="getUnit" datasource="#dsn#">
                                                SELECT UNIT_ID, #dsn#.Get_Dynamic_Language(SETUP_UNIT.UNIT_ID,'#session.ep.language#','SETUP_UNIT','UNIT',NULL,NULL,SETUP_UNIT.UNIT) AS UNIT FROM SETUP_UNIT ORDER BY UNIT
                                            </cfquery>
                                    </div>
                                    <div class="col col-4 col-xs-12">
                                        <select name="amount_unit" id="amount_unit" class="formselect" >
                                            <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                            <cfoutput query="getUnit">
                                                <option value="#unit_id#">#unit#</option>
                                            </cfoutput>
                                        </select>     	
                                    </div>
                                </div>
                                <div class="form-group" id="form_ul_sale_contract_amount">
                                    <label class="col col-12 col-xs-12"><cf_get_lang dictionary_id='57448.Satış'> <cf_get_lang dictionary_id='57638.Birim Fiyat'></label>
                                    <div class="col col-12 col-xs-12">
                                        <cfinput type="text" name="sale_contract_amount" id="sale_contract_amount" value="" passthrough="onkeyup=""return(formatcurrency(this,event));"""  class="moneybox">
                                    </div>
                                </div>
                                <div class="form-group" id="form_ul_expected_budget">
                                    <label class="col col-12 col-xs-12"><cf_get_lang dictionary_id='38175.Tahmini Bütçe'></label>
                                    <div class="col col-8 col-xs-12">
                                        <cfinput type="text" name="expected_budget" id="expected_budget"  value="" passthrough="onkeyup=""return(formatcurrency(this,event));""" class="moneybox">
                                    </div>
                                    <div class="col col-4 col-xs-12">
                                        <select name="expected_budget_money" id="expected_budget_money" class="formselect" >
                                            <cfinclude template="../query/get_money_currency.cfm">
                                            <cfoutput query="get_money">
                                                <option value="#money#"<cfif money eq session.ep.money>selected</cfif>>#money#</option>
                                            </cfoutput>
                                        </select>  	
                                    </div>
                                </div>
                                <div class="form-group" id="item-info_type_id">
                                    <label class="col col-12 col-xs-12"><cf_get_lang dictionary_id='57810.Ek Bilgi'></label>
                                    <div class="col col-12 col-xs-12">
                                        <cf_wrk_add_info info_type_id="-18" upd_page = "0">
                                    </div>
                                </div>
                            </div>
                            <div class="col col-4 col-md-4 col-sm-6 col-xs-12 padding-0" type="column" index="7" sort="true">      
                                <div class="form-group" id="form_ul_workgroup_id">
                                    <label class="col col-12 col-xs-12"><cf_get_lang dictionary_id='58140.İş Grubu'></label>
                                    <div class="col col-12 col-xs-12">
                                        <select name="workgroup_id" id="workgroup_id" >
                                        <option value=""><cf_get_lang dictionary_id='58140.İş Grubu'></option>
                                        <cfoutput query="get_workgroups">
                                            <option value="#workgroup_id#">#workgroup_name#</option>
                                        </cfoutput>
                                        </select>
                                    </div>
                                </div>
                                <div class="form-group " id="form_ul_rel_work">
                                    <label class="col col-12 col-xs-12"><cf_get_lang dictionary_id='38187.İlişkili İş'></label>
                                    <div class="col col-12 col-xs-12">
                                        <div class="input-group">
                                            <input type="hidden" name="rel_work" id="rel_work" value="<cfif isdefined('attributes.work_id') and len(attributes.work_id)><cfoutput>;#get_work.work_id#FS;</cfoutput></cfif>" readonly="readonly" >
                                            <input type="text" name="rel_work_name" id="rel_work_name"  value="<cfif isdefined('attributes.work_id') and len(attributes.work_id)><cfoutput>;#get_work.WORK_HEAD#</cfoutput></cfif>" readonly="readonly" >
                                            <span class="input-group-addon icon-ellipsis btnPointer" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=project.popup_related_works&rel_work='+document.getElementById('rel_work').value+'&project_id='+document.getElementById('project_ids').value</cfoutput>,'medium');"></span>
                                        </div>
                                    </div>
                                </div>
                                <div class="form-group" id="form_ul_duration">
                                    <label class="col col-12 col-xs-12"><cf_get_lang dictionary_id='29513.Süre'></label>
                                    <div class="col col-12 col-xs-12">
                                        <input type="text" name="duration" id="duration" value="" />
                                    </div>
                                </div>
                                <div class="form-group" id="form_ul_purchase_contract_amount">
                                    <label class="col col-12 col-xs-12"><cf_get_lang dictionary_id='58176.Alış'> <cf_get_lang dictionary_id='57638.Birim Fiyat'></label>
                                    <div class="col col-12 col-xs-12">
                                        <cfinput type="text" name="purchase_contract_amount" value="" passthrough="onkeyup=""return(formatcurrency(this,event));"""  class="moneybox">
                                    </div>
                                </div>
                                <div class="form-group" id="form_ul_special_definition">
                                    <label class="col col-12 col-xs-12"><cf_get_lang dictionary_id='38125.Özel Tanım'></label>
                                    <div class="col col-12 col-xs-12">
                                        <select name="special_definition" id="special_definition" >
                                            <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                            <cfoutput query="GET_SPECIAL_DEFINITION">
                                                <option value="#special_definition_id#">#special_definition#</option>
                                            </cfoutput>
                                        </select>
                                    </div>
                                </div>
                            </div>
                        </cf_box_elements>
                    </div>
                    <div id = "unique_sayfa_3" class = "uniqueBox">
                        <div class="ui-info-text" id="bilgi_verilecekler" type="row">
                            <div class="col col-12 col-md-12 col-sm-12 col-xs-12" type="column" sort="true" index="8">
                                <div class="form-group">
                                    <cfsavecontent variable="info"><cf_get_lang dictionary_id='58773.Bilgi Verilecekler'></cfsavecontent>
                                    <label style="display:none!important"><cf_get_lang dictionary_id='58773.Bilgi Verilecekler'></label>
                                    <cf_workcube_to_cc
                                        is_update="0"
                                        cc_dsp_name="#info#"
                                        form_name="add_event"
                                        str_list_param="1,7"
                                        data_type="2">
                                </div>
                            </div>
                        </div>  
                    </div>
                </cf_tab>
                <div class="col col-12 col-md-12 col-sm-12 col-xs-12">
                    <div class="ui-form-list-btn">
                        <cf_workcube_buttons type_format='1' is_upd='0' add_function='#iif(isdefined("attributes.draggable"),DE("chk_field() && loadPopupBox('add_work' , #attributes.modal_id#)"),DE("chk_field()"))#'>
                    </div>
                </div>
        </cfform>
    </cf_box>
</div>
<script type="text/javascript">
    function calculateBudget() {
        var averageAmount = parseFloat(document.getElementById("average_amount").value.replace(',', '.'));
        var saleContractAmount = parseFloat(document.getElementById("sale_contract_amount").value.replace(',', '.'));

        if (!isNaN(averageAmount) && !isNaN(saleContractAmount)) {
            var budget = (averageAmount * saleContractAmount).toFixed(2);
            document.getElementById("expected_budget").value = budget.toString().replace('.', ',');
        } else {
            document.getElementById("expected_budget").value = "";
        }
    }
    document.getElementById("average_amount").addEventListener("keyup", calculateBudget);
    document.getElementById("sale_contract_amount").addEventListener("keyup", calculateBudget);
tmplt();
function tmplt(type)
{	
	var pwc = document.getElementById('pro_work_cat').value;
	if(type == undefined) type = 0;
	if(type == 0)//kategoriye bağlı süreç gelecek
	{
		if(pwc != '')
		{
			var GET_TEMP = wrk_safe_query('get_temp_work_cat','dsn',0,pwc);
            if(GET_TEMP.recordcount && GET_TEMP.TEMPLATE_ID != undefined) AjaxPageLoad('<cfoutput>#request.self#</cfoutput>?fuseaction=project.popup_get_template&pwc='+pwc+'','item-work_detail',1);
		}
		<cfif isdefined("xml_is_stage_cat") and xml_is_stage_cat eq 1>
			if(pwc!='')
			{
				goster(stage1);
				goster(stage2);
				setTimeout(function(){AjaxPageLoad('<cfoutput>#request.self#</cfoutput>?fuseaction=project.popup_list_stage&category_id='+pwc,'stage1')},600);
			}
			else
			{
				goster(stage1);
				goster(stage2);
				setTimeout(function(){AjaxPageLoad('<cfoutput>#request.self#</cfoutput>?fuseaction=project.popup_list_stage&category_id=','stage1')},600);
			}
		</cfif>
	}
	else//kategori ve sürece bağlı template gelecek
	{
		<cfif isdefined("xml_is_stage_cat") and xml_is_stage_cat eq 1>
			var pro_stage = document.getElementById('process_stage').value;
			if(pwc !='' && pro_stage != '')
			{
				goster(stage1);
				goster(stage2);
				setTimeout(function(){AjaxPageLoad('<cfoutput>#request.self#</cfoutput>?fuseaction=project.popup_get_template&pro_stage='+pro_stage+'&pwc='+pwc,'fckedit',1)},600);
			}
		</cfif>
	}
}
function estimated_finishdate(add_time,type)
{
	if(document.getElementById('estimated_time_minute').value >= 60)
	{
        $('.ui-cfmodal__alert .required_list li').remove();
        $('.ui-cfmodal__alert .required_list').append('<li><cf_get_lang dictionary_id='60617.Lütfen 60dan Küçük Bir Değer Giriniz'>!</li>');
        $('.ui-cfmodal__alert').fadeIn();
		return false;
	}
	var startdate_plan = document.getElementById('startdate_plan').value;
	var add_hour = document.getElementById('estimated_time').value;
	var add_minute =document.getElementById('estimated_time_minute').value;
	<cfif isdefined("xml_show_planned_hour") and xml_show_planned_hour eq 1>
		var work_start_hour = document.getElementById('start_hour').value;
		if((startdate_plan != '') && (add_hour != '' || add_minute != ''))
		{
			var send_address = '<cfoutput>#request.self#</cfoutput>?fuseaction=project.emptypopup_add_date&type='+ type +'&work_start_hour='+ work_start_hour +'&startdate_plan='+ startdate_plan +'&add_hour='+add_hour +'&add_minute='+add_minute;
			AjaxPageLoad(send_address,'add_date_div_id',1);
		}
	</cfif>
}
function chk_field()
{	
    <cfif isdefined("xml_project_required") and xml_project_required eq 1>
        if (document.getElementById('project_ids').value== "" )
            {
                $('.ui-cfmodal__alert .required_list li').remove();
                $('.ui-cfmodal__alert .required_list').append('<li><cf_get_lang dictionary_id='58797.Proje Seçiniz'>!</li>');
                $('.ui-cfmodal__alert').fadeIn();
                return false;
            }
    </cfif>	
    <cfif isdefined("xml_dead_line_time") and xml_dead_line_time eq 1>
        
        if ((add_work.today.value.length != 0) && (add_work.terminate_date.value.length != 0))
        {
        
            if(dateformat_style == 'dd/mm/yyyy'){
                date1_control = add_work.terminate_date.value.substr(6,4) + add_work.terminate_date.value.substr(3,2) + add_work.terminate_date.value.substr(0,2);
                date2_control = add_work.today.value.substr(6,4) + add_work.today.value.substr(3,2) + add_work.today.value.substr(0,2);
            }
            else {
                date1_control = add_work.terminate_date.value.substr(6,4) + add_work.terminate_date.value.substr(0,2) +  add_work.terminate_date.value.substr(3,2)
                date2_control = add_work.today.value.substr(6,4) + add_work.today.value.substr(0,2) + add_work.today.value.substr(3,2);
            }
            
            if (date2_control > date1_control) 
            {
            
                $('.ui-cfmodal__alert .required_list li').remove();
                $('.ui-cfmodal__alert .required_list').append('<li><cf_get_lang dictionary_id='65924.Termin tarihi geri tarihli olamaz'>!</li>');
                $('.ui-cfmodal__alert').fadeIn();
                return false;
                
            
            }
        }
    </cfif>

	<cfif isdefined("xml_is_work_no") and xml_is_work_no eq 1>	
	paper_no_control = wrk_safe_query('work_paper_no_control','dsn',0,$('#work_no').val());
        if(paper_no_control.recordcount){
            $('.ui-cfmodal__alert .required_list li').remove();
            $('.ui-cfmodal__alert .required_list').append('<li><cf_get_lang dictionary_id='49009.Girdiğiniz Belge Numarası Kullanılmaktadır'>.<cf_get_lang dictionary_id='59367.Otomatik olarak değişecektir'>.</li>');
            $('.ui-cfmodal__alert').fadeIn();
			var new_query = wrk_safe_query('work_paper_no_control2','dsn',0);
			var new_number = parseFloat(new_query.WORK_NUMBER)+ 1;
			var number_join = '<cfoutput>#paper_code#</cfoutput>'+ '-' +new_number;
			document.getElementById('work_no').value = number_join;
            return false;
        }	
	</cfif>
    <cfif isdefined("xml_time_required") and xml_time_required eq 1>
        if (document.getElementById('total_time_minute').value== "" || document.getElementById('total_time_hour').value== "" )
        {
            $('.ui-cfmodal__alert .required_list li').remove();
            $('.ui-cfmodal__alert .required_list').append('<li><cf_get_lang dictionary_id='31491.Gerçekleşen'> - <cf_get_lang dictionary_id='38148.Harcanan Zaman'> <cf_get_lang dictionary_id='61824.Giriniz'>!</li>');
            $('.ui-cfmodal__alert').fadeIn();
            return false;
          
        }	
    </cfif>	
    if(document.getElementById('startdate_plan') != undefined)
	    fix_date(document.getElementById('startdate_plan'),document.getElementById('startdate_plan').name);
    if(document.getElementById('finishdate_plan') != undefined)
	    fix_date(document.getElementById('finishdate_plan'),document.getElementById('finishdate_plan').name);
    if(document.getElementById('startdate_plan') != undefined && document.getElementById('finishdate_plan') != undefined)
    {
        if(dateformat_style == 'dd/mm/yyyy')
        {
            tarih1_ = document.getElementById('startdate_plan').value.substr(6,4) +document.getElementById('startdate_plan').value.substr(3,2) + document.getElementById('startdate_plan').value.substr(0,2);
            tarih2_ = document.getElementById('sdate').value.substr(6,4) + document.getElementById('sdate').value.substr(3,2) + document.getElementById('sdate').value.substr(0,2);
            tarih3_ = document.getElementById('finishdate_plan').value.substr(6,4) + document.getElementById('finishdate_plan').value.substr(3,2) + document.getElementById('finishdate_plan').value.substr(0,2);
            tarih4_ = document.getElementById('fdate').value.substr(6,4) + document.getElementById('fdate').value.substr(3,2) + document.getElementById('fdate').value.substr(0,2);
            <cfif isdefined("attributes.work_id") and len(attributes.work_id) and isdefined('attributes.id') and len(attributes.id)>
                tarih5_ = document.getElementById('milestone_fdate').value.substr(6,4) + document.getElementById('milestone_fdate').value.substr(3,2) + document.getElementById('milestone_fdate').value.substr(0,2);
                tarih6_ = document.getElementById('milestone_sdate').value.substr(6,4) + document.getElementById('milestone_sdate').value.substr(3,2) + document.getElementById('milestone_sdate').value.substr(0,2);
            </cfif>
        }
        else
        {
            tarih1_ = document.getElementById('startdate_plan').value.substr(6,4) + document.getElementById('startdate_plan').value.substr(0,2)+document.getElementById('startdate_plan').value.substr(3,2) ;
            tarih2_ = document.getElementById('sdate').value.substr(6,4)  + document.getElementById('sdate').value.substr(0,2)+ document.getElementById('sdate').value.substr(3,2);
            tarih3_ = document.getElementById('finishdate_plan').value.substr(6,4)  + document.getElementById('finishdate_plan').value.substr(0,2)+ document.getElementById('finishdate_plan').value.substr(3,2);
            tarih4_ = document.getElementById('fdate').value.substr(6,4)  + document.getElementById('fdate').value.substr(0,2)+ document.getElementById('fdate').value.substr(3,2);
            <cfif isdefined("attributes.work_id") and len(attributes.work_id) and isdefined('attributes.id') and len(attributes.id)>
                tarih5_ = document.getElementById('milestone_fdate').value.substr(6,4)  + document.getElementById('milestone_fdate').value.substr(0,2)+ document.getElementById('milestone_fdate').value.substr(3,2);
                tarih6_ = document.getElementById('milestone_sdate').value.substr(6,4)  + document.getElementById('milestone_sdate').value.substr(0,2)+ document.getElementById('milestone_sdate').value.substr(3,2);
            </cfif>
        }
        <cfif isdefined("attributes.work_id") and len(attributes.work_id) and isdefined('attributes.id') and len(attributes.id)>
            if(tarih1_ < tarih6_)
            {

                $('.ui-cfmodal__alert .required_list li').remove();
                $('.ui-cfmodal__alert .required_list').append('<li><cf_get_lang dictionary_id ='61643.Girdiğiniz Alt İşin Başlangıç Tarihi Bağlı Olduğu Üst İşin Başlangıç Tarihinden Önce Gözüküyor.Lütfen Düzeltiniz'></li>');
                $('.ui-cfmodal__alert').fadeIn();
                return false;
            }
            /* if(tarih3_ > tarih5_)
            {
                alert("<cf_get_lang dictionary_id ='46164.Girdiğiniz Alt İşin Bitiş Tarihi Bağlı Olduğu Üst İşin Bitiş Tarihinden Sonra Gözüküyor.Lütfen Düzeltin'>");
                return false;
            } */
        </cfif>
        <cfif isDefined('xml_pro_work_date') and xml_pro_work_date eq 1>
            if(document.getElementById('project_ids').value != ""  &&  document.getElementById('project_ids').value != -1)   
            {
                if(tarih1_ < tarih2_){
                    $('.ui-cfmodal__alert .required_list li').remove();
                    $('.ui-cfmodal__alert .required_list').append('<li><cf_get_lang dictionary_id ='38314.Girdiğiniz İşin Hedef Başlangıç Tarihi Bağlı Olduğu Projenin Hedef Başlangıç Tarihinden Önce Görünüyor Lütfen Düzeltin'></li>');
                    $('.ui-cfmodal__alert').fadeIn();
                    return false;
           
                }                            
                if(tarih3_ > tarih4_)
                {
                    $('.ui-cfmodal__alert .required_list li').remove();
                    $('.ui-cfmodal__alert .required_list').append('<li><cf_get_lang dictionary_id ='35820.Girdiğiniz İşin Hedef Bitiş Tarihi Bağlı Olduğu Projenin Hedef Bitiş Tarihinden Sonra Gözüküyor Lütfen Düzeltin'></li>');
                    $('.ui-cfmodal__alert').fadeIn();
                    return false;
                }  
            }	
        </cfif>
        if(tarih1_ > tarih3_ || (tarih1_ == tarih3_ && (parseInt(document.add_work.start_hour.value) >= parseInt(document.add_work.finish_hour_plan.value))))
        {	
            $('.ui-cfmodal__alert .required_list li').remove();
            $('.ui-cfmodal__alert .required_list').append('<li><cf_get_lang dictionary_id='38316.Girdiğiniz İşin Başlangıç Tarihi ile Bitiş Tarihi Mantıklı Gözükmüyor Lütfen Düzeltin'></li>');
            $('.ui-cfmodal__alert').fadeIn();
            return false;			
        }
    }
	if ((document.getElementById('project_emp_id').value== ""  || document.getElementById('responsable_name').value == "")  && (document.getElementById('task_partner_id').value== "" || document.getElementById('responsable_name').value== ""))
	{
        $('.ui-cfmodal__alert .required_list li').remove();
        $('.ui-cfmodal__alert .required_list').append('<li><cf_get_lang dictionary_id='58194.Zorunlu Alan'> : <cf_get_lang dictionary_id='57569.Görevli'></li>');
        $('.ui-cfmodal__alert').fadeIn();
		return false;
	}
	//x = document.getElementById('priority_cat').selectedIndex;
	if (document.getElementById('priority_cat').value == "")
	{ 
        $('.ui-cfmodal__alert .required_list li').remove();
        $('.ui-cfmodal__alert .required_list').append('<li><cf_get_lang dictionary_id='58194.Zorunlu Alan'> : <cf_get_lang dictionary_id='57485.Öncelik'></li>');
        $('.ui-cfmodal__alert').fadeIn();
		return false;
	}
	//x = document.getElementById('pro_work_cat').selectedIndex;
	if (document.getElementById('pro_work_cat').value == "")
	{ 
        $('.ui-cfmodal__alert .required_list li').remove();
        $('.ui-cfmodal__alert .required_list').append('<li><cf_get_lang dictionary_id='58194.Zorunlu Alan'> : <cf_get_lang dictionary_id='38177.İş Kategorisi'></li>');
        $('.ui-cfmodal__alert').fadeIn();
		return false;
	}
	//Gunluk 24 saat harcama kontrolu yapiliyor
	if((document.getElementById("total_time_hour") != undefined && document.getElementById("total_time_hour").value != 0) || (document.getElementById("total_time_minute") != undefined && document.getElementById("total_time_minute").value != 0))
	{
		if(document.getElementById("total_time_hour") == undefined || document.getElementById("total_time_hour").value == "") document.getElementById("total_time_hour").value = 0;
		if(document.getElementById("total_time_minute") == undefined || document.getElementById("total_time_minute").value == "") document.getElementById("total_time_minute").value = 0;
		
		var total_minute = (parseInt(document.getElementById("total_time_hour").value)*60)+parseInt(document.getElementById("total_time_minute").value);
		var total_hour = total_minute/60;
        <cfset date1 = dateformat(date_add('d',-1,now()),dateformat_style)>
        <cfset date2 = dateformat(dateformat(now(),dateformat_style),dateformat_style)>
		var get_relation_time_cost = wrk_safe_query("get_relation_time_cost","dsn",0,"<cfoutput>#session.ep.userid#*#date1#*#date2#</cfoutput>");
		if(get_relation_time_cost.recordcount && get_relation_time_cost.TOTAL_TIME != "")
			var total_control = (get_relation_time_cost.TOTAL_TIME/60) + total_hour;
		else
			var total_control = total_hour;
		if(total_control > 24)
		{
            $('.ui-cfmodal__alert .required_list li').remove();
            $('.ui-cfmodal__alert .required_list').append('<li><cf_get_lang dictionary_id ='38446.Bir Gün İçinde 24 Saatten Fazla Zaman Harcaması Girilemez'>!</li>');
            $('.ui-cfmodal__alert').fadeIn();
			return false;
		}
	}
    if(document.getElementById('warning') != undefined)
    {
        x=document.getElementById('warning').selectedIndex;
        if ((document.add_work.warning[x].value==1) && (document.add_work.warning_type[0].checked==false) && (document.add_work.warning_type[1].checked==false))
        {
            $('.ui-cfmodal__alert .required_list li').remove();
            $('.ui-cfmodal__alert .required_list').append('<li><cf_get_lang dictionary_id='38278.Tekrar Periyodu Seçiniz'>!</li>');
            $('.ui-cfmodal__alert').fadeIn();
            return false;
        }
        if((document.add_work.warning[x].value==1) && (document.add_work.warning_count.value==""))
        {
            $('.ui-cfmodal__alert .required_list li').remove();
            $('.ui-cfmodal__alert .required_list').append('<li><cf_get_lang dictionary_id='38135.Tekrar Sayısı Girmelisiniz'>!</li>');
            $('.ui-cfmodal__alert').fadeIn();
            return false;
        }
    }
    if(document.getElementById('work_head') != undefined && trim(document.getElementById('work_head').value) =="")
	{
        $('.ui-cfmodal__alert .required_list li').remove();
        $('.ui-cfmodal__alert .required_list').append('<li><cf_get_lang dictionary_id='58194.Zorunlu Alan'> : <cf_get_lang dictionary_id='58820.Başlık'>!</li>');
        $('.ui-cfmodal__alert').fadeIn();
		return false;
	}
	
	unformat_fields();
    <cfif isdefined('attributes.process_stage') and len(attributes.process_stage)>
        return process_cat_control();
    <cfelse>
        return true;
    </cfif>
	
}
//periyodik kayıt için eklendi
function show_warn(i)
{
	if(i == 0)
	{
		form_ul_warning_type.style.display = 'none';
		form_ul_warning_count.style.display = 'none';
	}	
	else
	{
		form_ul_warning_type.style.display = '';
		form_ul_warning_count.style.display = '';
	}
}
show_warn(0);
function unformat_fields()
{
	document.getElementById('expected_budget').value = filterNum(document.getElementById('expected_budget').value);
	document.getElementById('average_amount').value = filterNum(document.getElementById('average_amount').value);
}
function get_company()
{
	var emp=document.getElementById('project_emp_id').value;
	if(emp != '')
	{
		var GET_COMP=wrk_safe_query('prj_get_comp','dsn',0,emp);
		document.getElementById('task_company_id').value=GET_COMP.COMPANY_ID;
	}
}

//Bilgi Verilecekler
row_count=0;
function add_row()
{
	row_count++;
	var newRow;
	var newCell;

	newRow = document.all.table1.insertRow();
	newRow.setAttribute("name","frm_row" + row_count);
	newRow.setAttribute("id","frm_row" + row_count);
	newRow.className = 'color-row';

	document.all.record_num.value=row_count;
	newCell = newRow.insertCell(newRow.cells.length);
	newCell.innerHTML = '<a style="cursor:pointer" onClick="sil(' + row_count + ');"><img src="/images/delete_list.gif" align="absmiddle" border="0" alt="Sil"></a>&nbsp;&nbsp;&nbsp;<input type="hidden" value="1" name="row_kontrol' + row_count +'"><input type="hidden" name="cc_emp_id'+ row_count +'" id="cc_emp_id'+ row_count +'" value=""><input type="hidden" name="cc_par_id'+ row_count +'" id="cc_par_id'+ row_count +'" value=""><input type="text" name="cc_name'+ row_count +'" id="cc_name'+ row_count +'" value="" style="width:125px;" onFocus="auto_member_cc('+ row_count +');" autocomplete="off"><a href="javascript://" onClick="pencere_ac('+ row_count +');" style="cursor:pointer;"> <img src="/images/plus_thin.gif" align="absbottom" border="0" alt="Ekle"></a>';	
}
function sil(sy)
{
	var my_element=eval("add_work.row_kontrol"+sy);
	my_element.value=0;
	var my_element=eval("frm_row"+sy);
	my_element.style.display="none";
}

function pencere_ac(no)
{
	openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_positions&field_emp_id=add_work.cc_emp_id'+ no +'&field_name=add_work.cc_name'+ no +'&field_partner=add_work.cc_par_id'+ no +'&select_list=1,2');
}
function auto_member_cc(no)
{
	AutoComplete_Create('cc_name'+no,'MEMBER_PARTNER_NAME3,MEMBER_NAME2','MEMBER_PARTNER_NAME3,MEMBER_NAME2','get_member_autocomplete','\'1,3\',0,0,0','PARTNER_ID,EMPLOYEE_ID','cc_par_id'+no+',cc_emp_id'+no+'','','3','250');
}

function pencere_ac_pbs_code()
{

	if(document.getElementById('project_id').value == "" && document.getElementsByName('project_head').value == "")
	{
        $('.ui-cfmodal__alert .required_list li').remove();
        $('.ui-cfmodal__alert .required_list').append('<li><cf_get_lang dictionary_id='58194.Zorunlu Alan'> : <cf_get_lang dictionary_id='57416.Proje'>!</li>');
        $('.ui-cfmodal__alert').fadeIn();
		return false;
	}
	else
		windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=product.popup_list_pbs_code&is_submitted=1&is_single=1&project_id='+document.getElementById('project_ids').value+'&field_id=add_work.pbs_id&field_name=add_work.pbs_code','list','popup_list_pbs_code');
}
function delete_project()
{
	if(document.getElementsByName('project_head').value=='')
	{
		document.getElementById('project_ids').value='';
		document.getElementById('sdate').value='';
		document.getElementById('fdate').value='';
	}
}
function add_milestone()
{
		if(document.getElementById('project_ids').value)
		{
			var GET_MILESTONE = wrk_safe_query('get_add_milestone','dsn',0,document.getElementById('project_ids').value);
			for(j=document.getElementById("milestone_work_id").options.length;j>=0;j--)
				eval('document.getElementById("milestone_work_id")').options[j] = null;	
		
			eval('document.getElementById("milestone_work_id")').options[0] = new Option('<cf_get_lang dictionary_id="57734.Seçiniz">','');
			for(i=0;i<GET_MILESTONE.recordcount;++i)
			{
				document.getElementById("milestone_work_id").options.add(new Option(GET_MILESTONE.WORK_HEAD[i], GET_MILESTONE.WORK_ID[i])); 
			}
		}
	<cfif isdefined("xml_is_project_cat") and xml_is_project_cat eq 1>
		if(document.getElementById('project_ids').value != '')
		{
			var get_project_cat = wrk_safe_query('obj_get_prjct_name','dsn',0,document.getElementById('project_ids').value);
			var get_work_cat_ = wrk_safe_query('get_pro_work_cat','dsn',0,get_project_cat.PROCESS_CAT);
			for(j=document.getElementById("pro_work_cat").options.length;j>=0;j--)
				eval('document.getElementById("pro_work_cat")').options[j] = null;	
		
			eval('document.getElementById("pro_work_cat")').options[0] = new Option('<cf_get_lang dictionary_id="57734.Seçiniz">','');
			for(i=0;i<get_work_cat_.recordcount;++i)
			{
				document.getElementById("pro_work_cat").options.add(new Option(get_work_cat_.WORK_CAT[i], get_work_cat_.WORK_CAT_ID[i])); 
			}
		}
	</cfif>
}
</script>
