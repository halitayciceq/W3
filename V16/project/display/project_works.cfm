<!--- <cf_xml_page_edit fuseact="project.prodetail"> Kullanildigi sayfalardaki xmli engellediginden kapatildi, bu sekilde kullanilmamali, nerede kullanildigi belirtilirse duzenleme yapilir FBS 20120319 --->
<!--- bu sayfa firsat,service,callcenter,service ,proje ve fiziki varlık,sistem(basvuru) detaydan cagirilir... bu dosyaya bagli olarak copy_work.cfm ve del_work.cfm duzenlenmelidir --->
<cfsetting showdebugoutput="no">
<cfparam name="attributes.project_detail_id" default="">
<cfparam name="attributes.WorkdevList" default="">
<cfparam name="attributes.work_detail_id" default="">

<cfif isDefined('attributes.workgroup_id') And len(attributes.workgroup_id)>
	<cfquery name="get_workgroup" datasource="#dsn#">
		SELECT EMPLOYEE_ID FROM WORKGROUP_EMP_PAR WHERE WORKGROUP_ID = #attributes.workgroup_id#
	</cfquery>
</cfif>

<cfif isdefined('attributes.project_detail_id') and len(attributes.project_detail_id) or isdefined('attributes.work_detail_id') and len(attributes.work_detail_id) >
	<cfset getComponent = createObject('component','V16.project.cfc.get_project_detail')>
	<cfset module_name="#get_module_id(module_name)#">
	<cfset fuseaction = "#attributes.fuseaction#">
	<cfset position_id = "#session.ep.position_code#">
	<cfset user_id = "#session.ep.userid#">
	<cfset object_name = "project.works">
	<cfset emp_del_buttons = getComponent.GET_EMP_DEL_BUTTONS(module_name : module_name, fuseaction : fuseaction, position_id : position_id, user_id : user_id,object_name : object_name)>
	<cfset employee_denied = getComponent.EMPLOYEE_DENIED(fuseaction : fuseaction, position_id : position_id, user_id : user_id)>
	<cf_get_lang_set module_name="project"><!--- sayfanin en altinda kapanisi var --->
	<cfparam name="attributes.priority_cat_" default="">
	<cfparam name="attributes.activity_id" default="">
	<cfparam name="attributes.project_id" default="">
	<cfparam name="attributes.currency" default="">
	<cfparam name="attributes.keywords" default="">
	<cfparam name="attributes.workgroup_id" default="">
	<cfif  isDefined("attributes.service_id")>
		<cfparam name="attributes.work_status" default="0">
	<cfelse>
		<cfparam name="attributes.work_status" default="1">
	</cfif>
	<cfparam name="attributes.page" default="1">
	<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>
	<cfparam name="attributes.startrow" default="1">
	<cfparam name="attributes.work_milestones" default="1">
	<cfparam name="attributes.xml_is_stage_cat" default="0">
	<cfparam name="attributes.xml_is_stage_work_cat" default="0">
	<cfparam name="attributes.xml_work_sort_type" default="0">
	<cfparam name="attributes.xml_change_complate_ratio" default="1">
	<cfparam name="attributes.xml_show_actual_date" default="1">
	<cfparam name="attributes.xml_show_work_category" default="1">
	<cfset xml_list = '&xml_is_stage_cat=#attributes.xml_is_stage_cat#&xml_is_stage_work_cat=#attributes.xml_is_stage_work_cat#&xml_work_sort_type=#attributes.xml_work_sort_type#&xml_change_complate_ratio=#attributes.xml_change_complate_ratio#&xml_show_actual_date=#attributes.xml_show_actual_date#&xml_show_work_category=#attributes.xml_show_work_category#'>
	<cfif attributes.xml_show_work_category eq 1>
		<cfparam name="attributes.work_cat" default="">
	</cfif>
	<cfif isdefined('attributes.xml_work_sort_type') and len(attributes.xml_work_sort_type)>
		<cfparam name="attributes.ordertype" default="#attributes.xml_work_sort_type#">
	</cfif>
	<cfif isdefined("attributes.work_id") and len(attributes.work_id)>
	<cfset work_id_list = "">
		<cfquery name="GET_RELATED_WORK" datasource="#DSN#">
			SELECT
					PRO_WORK_RELATIONS.WORK_ID
				FROM
					PRO_WORK_RELATIONS,
					PRO_WORKS PRE,
					PRO_WORKS ORIGINAL
				WHERE
					PRE.WORK_ID = PRO_WORK_RELATIONS.PRE_ID AND
					ORIGINAL.WORK_ID = PRO_WORK_RELATIONS.WORK_ID AND
					PRO_WORK_RELATIONS.PRE_ID	 = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.work_id#">
		</cfquery>
		<cfset work_id_list = valuelist(GET_RELATED_WORK.work_id)>
	</cfif>
	<cfquery name="GET_PRO_WORK" datasource="#DSN#">
		SELECT
			*
		FROM
		(
			SELECT
				CASE 
					WHEN IS_MILESTONE = 1 THEN WORK_ID
					WHEN IS_MILESTONE <> 1 THEN ISNULL(MILESTONE_WORK_ID,0)
				END AS NEW_WORK_ID,
				CASE 
					WHEN IS_MILESTONE = 1 THEN 0
					WHEN IS_MILESTONE <> 1 THEN 1
				END AS TYPE,
				PW.IS_MILESTONE,
				PW.MILESTONE_WORK_ID,
				PW.WORK_ID,
				PW.WORK_HEAD,
				PW.ESTIMATED_TIME,
				(SELECT PTR.STAGE FROM PROCESS_TYPE_ROWS PTR WHERE PTR.PROCESS_ROW_ID= PW.WORK_CURRENCY_ID) STAGE,
				(SELECT PWC.WORK_CAT FROM PRO_WORK_CAT PWC WHERE PWC.WORK_CAT_ID= PW.WORK_CAT_ID) WORK_CAT,
				PW.WORK_PRIORITY_ID,
				CASE 
					WHEN PW.PROJECT_EMP_ID IS NOT NULL THEN (SELECT E.EMPLOYEE_NAME +' '+ E.EMPLOYEE_SURNAME FROM EMPLOYEES E WHERE E.EMPLOYEE_ID = PW.PROJECT_EMP_ID)
					WHEN PW.OUTSRC_PARTNER_ID IS NOT NULL THEN (SELECT C2.NICKNAME+' - '+ CP2.COMPANY_PARTNER_NAME + ' ' + CP2.COMPANY_PARTNER_SURNAME NAME FROM COMPANY_PARTNER CP2,COMPANY C2 WHERE C2.COMPANY_ID = CP2.COMPANY_ID AND CP2.PARTNER_ID = PW.OUTSRC_PARTNER_ID)
				END AS EMPLOYEE,
				PW.OUTSRC_PARTNER_ID,
				PW.TARGET_FINISH,
				PW.TARGET_START,
				PW.REAL_FINISH,
				PW.REAL_START,
				PW.TO_COMPLETE,
				PW.UPDATE_DATE,
				PW.RECORD_DATE,
				SP.PRIORITY,
				PW.TERMINATE_DATE,
				SP.COLOR,
				SA.ACTIVITY_NAME,
				(SELECT TOP 1 PRO_MATERIAL.PRO_MATERIAL_ID FROM PRO_MATERIAL WHERE PRO_MATERIAL.WORK_ID = PW.WORK_ID) PRO_MATERIAL_ID,
				(SELECT E.EMPLOYEE_ID FROM EMPLOYEES E WHERE E.EMPLOYEE_ID = PW.PROJECT_EMP_ID) EMPLOYEE_ID
			FROM
			PRO_WORKS PW
			LEFT JOIN SETUP_PRIORITY SP ON PW.WORK_PRIORITY_ID = SP.PRIORITY_ID
			LEFT JOIN SETUP_ACTIVITY SA ON PW.ACTIVITY_ID = SA.ACTIVITY_ID
			WHERE
				<cfif isDefined("attributes.g_service_id")> <!--- callcenter başvuruları için eklendi  --->
					PW.G_SERVICE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.g_service_id#">
				<cfelseif isDefined("attributes.service_id")> <!--- servis başvuruları  --->
					(PW.OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#"> OR PW.OUR_COMPANY_ID IS NULL) AND
					PW.SERVICE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.service_id#">
				<cfelseif isDefined("attributes.opp_id")> <!--- fırsatlar  --->
					(PW.OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#"> OR PW.OUR_COMPANY_ID IS NULL) AND
					PW.OPPORTUNITY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.opp_id#">
				<cfelseif isDefined("attributes.product_sample_id")> <!--- numune --->
					PW.PRODUCT_SAMPLE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.product_sample_id#">
				<cfelseif isdefined("attributes.assetp_id")> <!--- fiziki varlık  --->
					PW.ASSETP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.assetp_id#">
				<cfelseif isdefined("attributes.subscription_id")> <!---sistem basvurulari  --->
					PW.SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.subscription_id#">
				<cfelseif isdefined("attributes.forum_reply_id")> <!---sistem basvurulari  --->
					PW.FORUM_REPLY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.forum_reply_id#">
				<cfelseif isdefined("attributes.work_id") and len(attributes.work_id)>
				(
					PW.MILESTONE_WORK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.work_id#">
					<cfif len(work_id_list)>
					OR
					PW.WORK_ID IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#work_id_list#" list="yes">)
					</cfif>
				)
				<cfelseif isDefined("attributes.project_id") and len(attributes.project_id)>
					PW.PROJECT_ID =<cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.project_id#">
				<cfelse>
					1=1
				</cfif>
				<cfif len(attributes.keywords)>
					AND PW.WORK_HEAD LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.keywords#%">
				</cfif>
				<cfif len(attributes.priority_cat_)>
					AND PW.WORK_PRIORITY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.priority_cat_#">
				</cfif>
				<cfif len(attributes.activity_id)>
					AND PW.ACTIVITY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.activity_id#">
				</cfif> 
				<cfif len(attributes.workgroup_id)>
					AND (PW.WORKGROUP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.workgroup_id#"><cfif get_workgroup.recordCount> OR PW.PROJECT_EMP_ID IN(#valueList(get_workgroup.EMPLOYEE_ID)#)</cfif>)
				</cfif>
				<cfif isdefined("attributes.work_cat") and len(attributes.work_cat)>
					AND PW.WORK_CAT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.work_cat#">
				</cfif>
				<cfif len(attributes.currency)>
					AND PW.WORK_CURRENCY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.currency#">
				</cfif>
				<cfif isDefined("attributes.Workfuse") and len(attributes.Workfuse)>
					AND PW.WORK_CIRCUIT = <cfqueryparam cfsqltype="cf_sql_varchar" value="#listfirst(attributes.Workfuse,".")#"> 
					AND PW.WORK_FUSEACTION = <cfqueryparam cfsqltype="cf_sql_varchar" value="#listlast(attributes.Workfuse,".")#">
				</cfif>
				<cfif attributes.work_status eq -1>
					AND PW.WORK_STATUS = 0 <!--- (PW.WORK_STATUS = 0 OR PW.IS_MILESTONE = 1) pasif olmayan üst işlerin gelmesine neden oluyordu FA --->
				<cfelseif attributes.work_status eq 1>
					AND PW.WORK_STATUS = 1 <!--- (PW.WORK_STATUS = 1 OR PW.IS_MILESTONE = 1) aktif olmayan üst işlerin gelmesine neden oluyordu GA --->
				</cfif>
				)T1
			WHERE
				1=1 
				<cfif attributes.work_milestones eq 0>
					AND IS_MILESTONE <> 1
					<cfif attributes.work_milestones eq 1>
						ORDER BY NEW_WORK_ID		
					</cfif>			
				</cfif>
				<cfif isdefined("attributes.ordertype") and attributes.ordertype eq 1><!--- İş ve ID ye Göre Azalan --->
					ORDER BY NEW_WORK_ID,TYPE,WORK_ID DESC
				<cfelseif isdefined("attributes.ordertype") and attributes.ordertype eq 2><!--- Güncellemeye Göre Azalan --->
					ORDER BY NEW_WORK_ID,TYPE,ISNULL(UPDATE_DATE,RECORD_DATE) DESC
				<cfelseif isdefined("attributes.ordertype") and attributes.ordertype eq 3><!--- Başlangıç Tarihine Göre Azalan --->
					ORDER BY NEW_WORK_ID,TYPE,TARGET_START DESC
				<cfelseif isdefined("attributes.ordertype") and attributes.ordertype eq 4><!--- Başlangıç Tarihine Göre Artan --->
					ORDER BY NEW_WORK_ID,TYPE,TARGET_START
				<cfelseif isdefined("attributes.ordertype") and attributes.ordertype eq 5><!--- Bitiş Tarihine Göre Azalan --->
					ORDER BY TARGET_FINISH DESC
				<cfelseif isdefined("attributes.ordertype") and attributes.ordertype eq 6><!--- Bitiş Tarihine Göre Artan --->
					ORDER BY TARGET_FINISH
				<cfelseif isdefined("attributes.ordertype") and attributes.ordertype eq 7><!--- İş Başlığına Göre Alfabetik --->
					ORDER BY NEW_WORK_ID,TYPE,WORK_HEAD
				</cfif>
	</cfquery>
	<cfquery name="GET_ACTIVITY" datasource="#DSN#">
		SELECT ACTIVITY_ID, ACTIVITY_NAME FROM SETUP_ACTIVITY WHERE ACTIVITY_STATUS = 1 ORDER BY ACTIVITY_NAME
	</cfquery>
	<cfif (not len(attributes.maxrows) or attributes.maxrows eq 0) and isdefined('session.ep.maxrows') and len(session.ep.maxrows)>
		<cfset attributes.maxrows = '#session.ep.maxrows#'>
	</cfif>
	<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
	<cfparam name="attributes.totalrecords" default='#get_pro_work.recordcount#'>
	<cfparam name="attributes.page" default=1>
	<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>
	<cfset work_h_list = ''>
	<cfif get_pro_work.recordcount>
		<cfset work_h_list = valuelist(get_pro_work.work_id)>
		<cfquery name="GET_HARCANAN_ZAMAN" datasource="#DSN#">
			SELECT 
				SUM(EXPENSED_MINUTE) AS HARCANAN_DAKIKA,
				WORK_ID 
			FROM 
				TIME_COST 
			WHERE 
				WORK_ID IN (#work_h_list#)
			GROUP BY
				WORK_ID
			ORDER BY
				WORK_ID
		</cfquery>
		<cfset work_h_list = listsort(listdeleteduplicates(valuelist(get_harcanan_zaman.work_id,',')),'numeric','ASC',',')>
	</cfif>
	<cfif attributes.xml_is_stage_cat eq 1 and isdefined("attributes.project_id")>
		<cfquery name="GET_PRO_CAT" datasource="#DSN#">
			SELECT PROCESS_CAT FROM PRO_PROJECTS WHERE PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.project_id#">
		</cfquery>
		<cfquery name="GET_WORK_CURRENCY" datasource="#DSN#">
			SELECT PROCESS_ID FROM PRO_WORK_CAT WHERE PROCESS_ID IS NOT NULL AND ','+MAIN_PROCESS_ID+',' LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%,#get_pro_cat.process_cat#,%">
		</cfquery>
	</cfif>
	<cfquery name="GET_PROCURRENCY" datasource="#DSN#">
		SELECT
			PTR.STAGE,
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
			PT.FACTION LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%project.works%">
			<cfif attributes.xml_is_stage_cat eq 1 and isdefined("attributes.project_id") and get_work_currency.recordcount>
				AND PTR.PROCESS_ROW_ID IN ( #valuelist(get_work_currency.process_id)# )
			</cfif>
			<cfif attributes.xml_is_stage_work_cat eq 1 and attributes.xml_show_work_category eq 1>
				<cfif len(attributes.work_cat)>
					AND ','+(SELECT PROCESS_ID FROM PRO_WORK_CAT WHERE WORK_CAT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.work_cat#">)+',' LIKE '%,'+CAST(PTR.PROCESS_ROW_ID AS NVARCHAR)+',%'
				<cfelse>
					AND 1 = 0
				</cfif>
			</cfif>
		ORDER BY
			PTR.LINE_NUMBER
	</cfquery>
	<cfquery name="GET_WORKGROUPS" datasource="#DSN#">
		SELECT 
			WORKGROUP_ID,
			WORKGROUP_NAME
		FROM 
			WORK_GROUP
		WHERE
			STATUS = 1
			AND HIERARCHY IS NOT NULL
		ORDER BY 
			HIERARCHY
	</cfquery>
	<cfinclude template="../query/get_priority.cfm">
	<cfinclude template="../query/get_pro_work_cat.cfm">
	<cfif isDefined("attributes.related_project_info")>
		<cfset this_div_id_ = attributes.project_id>
	<cfelseif isDefined("attributes.g_service_id")>
		<cfset this_div_id_ = attributes.g_service_id>
	<cfelseif isDefined("attributes.service_id")>
		<cfset this_div_id_ = attributes.service_id>
	<cfelseif isDefined("attributes.opp_id")>
		<cfset this_div_id_ = attributes.opp_id>
	<cfelseif isDefined("attributes.product_sample_id")>
		<cfset this_div_id_ = attributes.product_sample_id>
	<cfelseif isDefined("attributes.project_id")>
		<cfset this_div_id_ = attributes.project_id>
	<cfelseif isDefined("attributes.assetp_id")>
		<cfset this_div_id_ = attributes.assetp_id>
	<cfelseif isDefined("attributes.subscription_id")>
		<cfset this_div_id_ = attributes.subscription_id>
	<cfelseif isDefined("attributes.forum_reply_id")>
		<cfset this_div_id_ = attributes.forum_reply_id>
	</cfif>
	<cfif isDefined('this_div_id_') and this_div_id_ eq -1>
		<cfset this_div_id_ = 0>
	</cfif>
	<div <cfif isDefined("attributes.WorkdevList") and len(attributes.WorkdevList)> class="col col-12 col-md-12 col-sm-12 col-xs-12 boxRow uniqueBox portBoxBodyStandart  scrollContent" </cfif> id="project_works_div_<cfoutput>#this_div_id_#</cfoutput>">
		<cfsavecontent variable="head"><cf_get_lang dictionary_id='57964.Hedefler'></cfsavecontent>
			<cfform name="works_#this_div_id_#" method="post" action="">
				<cf_box_search more="0">							
					<cfif not (isdefined("attributes.work_detail_id") and len(attributes.work_detail_id))>
						<input type="hidden" name="is_submitted" id="is_submitted" value="1" />
						<input type="hidden" name="xml_work_sort_type" id="xml_work_sort_type" value="<cfif isdefined('attributes.xml_work_sort_type') and len(attributes.xml_work_sort_type)><cfoutput>#attributes.xml_work_sort_type#</cfoutput></cfif>" />
						<input type="hidden" name="xml_is_stage_cat" id="xml_is_stage_cat" value="<cfif isdefined('attributes.xml_is_stage_cat') and len(attributes.xml_is_stage_cat)><cfoutput>#attributes.xml_is_stage_cat#</cfoutput></cfif>" />
						<input type="hidden" name="xml_is_stage_work_cat" id="xml_is_stage_work_cat" value="<cfif isdefined('attributes.xml_is_stage_work_cat') and len(attributes.xml_is_stage_work_cat)><cfoutput>#attributes.xml_is_stage_work_cat#</cfoutput></cfif>" />
						<input type="hidden" name="xml_change_complate_ratio" id="xml_change_complate_ratio" value="<cfif isdefined('attributes.xml_change_complate_ratio') and len(attributes.xml_change_complate_ratio)><cfoutput>#attributes.xml_change_complate_ratio#</cfoutput></cfif>" />
						<input type="hidden" name="xml_show_actual_date" id="xml_show_actual_date" value="<cfif isdefined('attributes.xml_show_actual_date') and len(attributes.xml_show_actual_date)><cfoutput>#attributes.xml_show_actual_date#</cfoutput></cfif>" />
						<input type="hidden" name="xml_show_work_category" id="xml_show_work_category" value="<cfif isdefined('attributes.xml_show_work_category') and len(attributes.xml_show_work_category)><cfoutput>#attributes.xml_show_work_category#</cfoutput></cfif>" />							
						<div class="form-group">
							<cfif isDefined("attributes.related_project_info")>
								<cfsavecontent variable="message"><cf_get_lang dictionary_id='57701.Filtre Ediniz'></cfsavecontent>
								<cfinput type="text" name="keywords" placeholder="#message#" value="#attributes.keywords#" id="keywords" onKeyPress="if(event.keyCode==13 ) {loader_page(#attributes.project_id#); return false;}">
								<input type="hidden" name="related_project_info" id="related_project_info" value="<cfoutput>#attributes.related_project_info#</cfoutput>" />
							<cfelse>
								<cfsavecontent variable="message"><cf_get_lang dictionary_id='57701.Filtre Ediniz'></cfsavecontent>
								<cfinput type="text" name="keywords" placeholder="#message#" value="#attributes.keywords#" id="keywords" onKeyPress="if(event.keyCode==13 ) {loader_page(#this_div_id_#); return false;}">
								<input type="hidden" name="related_project_info" id="related_project_info" value="" />
							</cfif>
						</div>
						<div class="form-group">
							<cfif attributes.xml_show_work_category eq 1>
								<select name="work_cat" id="work_cat"  <cfif attributes.xml_is_stage_work_cat eq 1 and isdefined("attributes.project_id")>onChange="get_work_currency();"</cfif>>>
									<option value=""><cf_get_lang dictionary_id='57486.Kategori'></option>
									<cfoutput query="get_work_cat">
										<option value="#get_work_cat.work_cat_id#" <cfif attributes.work_cat eq get_work_cat.work_cat_id>selected</cfif>>#get_work_cat.work_cat#</option>
									</cfoutput>
								</select>
							</cfif>
						</div>			
						<div class="form-group">
							<select name="workgroup_id" id="workgroup_id">				  
								<option value=""><cf_get_lang dictionary_id='58140.İş Grubu'></option>
								<cfoutput query="get_workgroups">
									<option value="#workgroup_id#" <cfif isdefined("attributes.workgroup_id") and workgroup_id eq attributes.workgroup_id>selected</cfif>>#workgroup_name#</option>
								</cfoutput>
							</select>
						</div>
						<div class="form-group">
							<select name="ordertype" id="ordertype">
								<option value="1" <cfif isdefined("attributes.ordertype") and attributes.ordertype eq 1>selected</cfif>><cf_get_lang dictionary_id='38256.İş ve Id ye Göre Azalan'></option>
								<option value="2" <cfif isdefined("attributes.ordertype") and attributes.ordertype eq 2>selected</cfif>><cf_get_lang dictionary_id='38328.Güncellemeye Göre Azalan'></option>
								<option value="3" <cfif isdefined("attributes.ordertype") and attributes.ordertype eq 3>selected</cfif>><cf_get_lang dictionary_id='38330.Başlangıç Tarihine Göre Azalan'></option>
								<option value="4" <cfif isdefined("attributes.ordertype") and attributes.ordertype eq 4>selected</cfif>><cf_get_lang dictionary_id='38331.Başlangıç Tarihine Göre Artan'></option>
								<option value="5" <cfif isdefined("attributes.ordertype") and attributes.ordertype eq 5>selected</cfif>><cf_get_lang dictionary_id='38332.Bitiş Tarihine Göre Azalan'></option>
								<option value="6" <cfif isdefined("attributes.ordertype") and attributes.ordertype eq 6>selected</cfif>><cf_get_lang dictionary_id='38260.Bitiş Tarihine Göre Artan'></option>
								<option value="7" <cfif isdefined("attributes.ordertype") and attributes.ordertype eq 7>selected</cfif>><cf_get_lang dictionary_id='38270.İş Başlığına göre Alfabetik'></option>
							</select>
						</div>
						<div class="form-group">
							<select name="currency" id="currency" >
								<option value=""><cf_get_lang dictionary_id='57482.Asama'></option>
								<cfoutput query="get_procurrency">
									<option value="#process_row_id#" <cfif attributes.currency eq process_row_id>selected</cfif>>#stage#</option>
								</cfoutput>
							</select>
						</div>
						<div class="form-group">			
							<select name="priority_cat_" id="priority_cat_">
								<option value=""><cf_get_lang dictionary_id='57485.Öncelik'></option>
								<cfoutput query="get_cats">
									<option value="#priority_id#" <cfif attributes.priority_cat_ eq priority_id>selected</cfif>>#priority#</option>
								</cfoutput>
							</select>
						</div>	
						<div class="form-group">
							<select name="work_milestones" id="work_milestones">
								<option value="1" <cfif attributes.work_milestones eq 1>selected="selected"</cfif>><cf_get_lang dictionary_id='30781.Üst İşler Dahil'></option>
								<option value="0" <cfif attributes.work_milestones eq 0>selected="selected"</cfif>><cf_get_lang dictionary_id='30784.Milestonlar Haric'></option>
							</select>
						</div>		
						<div class="form-group">
							<select name="work_status" id="work_status">
								<option value="1" <cfif attributes.work_status eq 1>selected="selected"</cfif>><cf_get_lang dictionary_id='57493.Aktif'></option>
								<option value="-1" <cfif attributes.work_status eq -1>selected="selected"</cfif>><cf_get_lang dictionary_id='57494.Pasif'></option>
								<option value="0" <cfif attributes.work_status eq 0>selected="selected"</cfif>><cf_get_lang dictionary_id='57708.Tümü'></option>
							</select>
						</div>		
						<div class="form-group small">
							<cfsavecontent variable="message"><cf_get_lang dictionary_id='57537.Sayi_Hatasi_Mesaj'></cfsavecontent>
							<cfinput type="text" name="maxrows" id="maxrows" value="#attributes.maxrows#" required="yes" validate="integer" range="1,999" message="#message#" maxlength="3" onKeyUp="isNumber(this)">
							<cfsavecontent variable="search"><cf_get_lang dictionary_id ='57565.Ara'></cfsavecontent>
						</div>
						<div class="form-group">
							<cfset send_ = "">
							<cfif isdefined("attributes.work_id")><cfset send_ = "#send_#&work_id=#attributes.work_id#"></cfif>
							<cfif isdefined("attributes.project_id")><cfset send_ = "#send_#&project_id=#attributes.project_id#"></cfif>
							<cfif isdefined("attributes.opp_id")><cfset send_ = "#send_#&opp_id=#attributes.opp_id#"></cfif>
							<cfif isdefined("attributes.product_sample_id")><cfset send_ = "#send_#&product_sample_id=#attributes.product_sample_id#"></cfif>
							<cfif isdefined("attributes.service_id")><cfset send_ = "#send_#&service_id=#attributes.service_id#"></cfif>
							<cfif isdefined("attributes.assetp_id")><cfset send_ = "#send_#&assetp_id=#attributes.assetp_id#"></cfif>
							<cfif isdefined("attributes.g_service_id")><cfset send_ = "#send_#&g_service_id=#attributes.g_service_id#"></cfif>
							<cfif isdefined("attributes.subscription_id")><cfset send_ = "#send_#&subscription_id=#attributes.subscription_id#"></cfif>
							<cfif isdefined("attributes.is_submited")><cfset send_ = "#send_#&is_submited=#attributes.is_submited#"></cfif>
							<cfif isdefined("attributes.Workfuse")><cfset send_ = "#send_#&Workfuse=#attributes.Workfuse#"></cfif>
							<cfif isdefined("attributes.WorkdevList")><cfset send_ = "#send_#&WorkdevList=#attributes.WorkdevList#"></cfif>
							<cf_wrk_search_button button_type="4" search_function="loader_page2('#send_#&project_detail_id=#attributes.project_detail_id#')">
						</div>
						<div class="form-group">
							<a href="javascript://" onclick="openBoxDraggable('index.cfm?fuseaction=project.works&event=add&id=<cfoutput>#attributes.project_detail_id#&work_fuse=<cfif isdefined("attributes.work_fuse")>#attributes.work_fuse#</cfif></cfoutput>')" class="ui-btn ui-btn-gray"><i class="fa fa-plus"></i></a>
						</div>
					</cfif>
				</cf_box_search>
			</cfform>
		<cf_grid_list>
			<thead>
				<tr>
					<cfoutput>
						<th width="20">M</th>
						<th width="20">#Left(getLang('main',73,'Oncelik'),1)#</th>
						<th width="20">#Left(getLang('main',157,'Görevli'),1)#</th>
						<th><cf_get_lang dictionary_id='58820.Başlık'></th>
						<th><cf_get_lang dictionary_id='57482.Aşama'></th>
						<th><cf_get_lang dictionary_id='38146.Termin'></th>
						<th><cf_get_lang dictionary_id='38143.Öngörülen'></th>
						<th><cf_get_lang dictionary_id='38128.Harcanan'></th>
						<th width="20">%</th>
						<th width="20"><a href="javascript:void(0)"  title="<cf_get_lang dictionary_id ='38326.Malzeme'>"><i class="fa fa-file-text-o"></i></a></th>
						<th width="20"><a href="javascript:void(0)"  title="<cf_get_lang dictionary_id ='57476.Kopyala'>"><i class="fa fa-copy"></i></a></th>
						<th width="20"><a href="javascript:void(0)"  title="<cf_get_lang dictionary_id ='60364.Planlanan Zaman Harcaması Ekle'>"><i class="fa fa-calendar-plus-o"></i></a></th>
						<th width="20"><a href="javascript:void(0)"  title="<cf_get_lang dictionary_id ='57582.Ekle'>"><i class="fa fa-plus"></i></a></th>
						<th width="20"><a href="javascript:void(0)"  title="<cf_get_lang dictionary_id ='57463.Sil'>"><i class="fa fa-minus"></i></a></th>
						<cfif isdefined("xml_milestone_transfer") and xml_milestone_transfer eq 1><th width="20"></th></cfif>
					</cfoutput>
				</tr>
			</thead>
			<tbody>
				<cfif get_pro_work.recordcount>
					<cfoutput query="GET_PRO_WORK" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#"> 
						<tr class="tr_a" id="#milestone_work_id#"> 	
							<cfif isdefined('employee_id') and len(employee_id)>
								<cfset employee_photo = getComponent.EMPLOYEE_PHOTO(employee_id:employee_id)>
								<cfif isdefined('employee_photo.photo') and len(employee_photo.photo)>
									<cfset emp_photo ="../../documents/hr/#employee_photo.PHOTO#">
								
								<cfelseif isdefined('employee_photo.sex') and employee_photo.sex eq 1>
									<cfset emp_photo ="images/male.jpg">
								<cfelse>
									<cfset emp_photo ="images/female.jpg">
								</cfif>
							<cfelseif isdefined('outsrc_partner_id') and  outsrc_partner_id neq 0 and len(outsrc_partner_id)>
								<cfset GET_PARTNER_PHOTO_ = getComponent.PARTNER_PHOTO(partner_id : outsrc_partner_id)>
								<cfif isdefined('GET_PARTNER_PHOTO_.photo') and len(GET_PARTNER_PHOTO_.photo)>
									<cfif fileExists("#upload_folder#member/#GET_PARTNER_PHOTO_.PHOTO#")>
										<cfset emp_photo ='documents/member/#GET_PARTNER_PHOTO_.PHOTO#'>
									<cfelseif fileExists("#upload_folder#hr/#GET_PARTNER_PHOTO_.PHOTO#")>
										<cfset emp_photo ='documents/hr/#GET_PARTNER_PHOTO_.PHOTO#'>
									</cfif>
								<cfelseif GET_PARTNER_PHOTO_.sex eq 1>
									<cfset emp_photo ="images/male.jpg">
								<cfelse>
									<cfset emp_photo ="images/female.jpg">
								</cfif>
							<cfelse>
								<cfset emp_photo = ''>
							</cfif>
							
							<td>								
								<cfif type eq 0>
								<div class='iconBox' style='align: center; background-color:grey'><a href="javascript://" onclick="show_hide_works('#work_id#')" style="color:white">M</a></div>
								<cfelse>&nbsp;&nbsp;</cfif>
							</td>
							<td>
								<div class='iconBox ' style='align: center; background-color:###color#'>#left(priority,1)# </div>
							</td>
							<td title="#get_emp_info(employee_id,0,0)#">
								<img class='img-circle' title="#EMPLOYEE#"  style='width : 30px; height:30px;'src='#emp_photo#' />
							</td>
							<td>
								<a id="stage_" href="#request.self#?fuseaction=project.works&event=det&id=#work_id#" target="_blank" >#URLDecode(work_head)#</a>
							</td>
							<td>
								#stage#
							</td>
							<td>
								<cfif len(terminate_date)>
									<cfset fdate_plan=date_add("h",session.ep.time_zone,terminate_date)>
								<cfelse>
									<cfset fdate_plan=''>
								</cfif>
								<cfif isdefined('fdate_plan') and len(fdate_plan)>
									#dateformat(fdate_plan,dateformat_style)#
								</cfif>
							</td>
							<td>
								<cfif isdefined('estimated_time') and len(estimated_time)>
									<cfset liste=estimated_time/60>
									<cfset saat=listfirst(liste,'.')>
									<cfset dak=estimated_time-saat*60>
									#saat# <cf_get_lang dictionary_id='57491.Saat'> #dak# <cf_get_lang dictionary_id='58827.Dk'>
								</cfif>
							</td>
							<td>
								<cfif listfindnocase(work_h_list,work_id)>
									<cfset harcanan_ = get_harcanan_zaman.harcanan_dakika[listfind(work_h_list,work_id,',')]>
									<cfset liste=harcanan_/60>
									<cfset saat=listfirst(liste,'.')>
									<cfset dak=harcanan_-saat*60>
									#saat# <cf_get_lang dictionary_id='57491.Saat'> #dak# <cf_get_lang dictionary_id='58827.Dk'>
								<cfelse>
									0 <cf_get_lang dictionary_id='57491.Saat'> 0 <cf_get_lang dictionary_id='58827.Dk'>                   	
								</cfif>
							</td>
							<td>
								#to_complete#
							</td>
							<td>
								<!--- Malzeme --->
								<cfif not listfindnocase(denied_pages,'project.project_material') and isDefined("attributes.related_project_info")>
									<cfif len(pro_material_id)>
										<a href='#request.self#?fuseaction=project.project_material&event=upd&upd_id=#pro_material_id#'><i class="fa fa-file-text-o" style="color:grey;" title="<cf_get_lang dictionary_id ='38326.Malzeme'>"></i></a>
									<cfelse>
										<a href='#request.self#?fuseaction=project.project_material&event=add<cfif isdefined("attributes.project_id") and len(attributes.project_id)>&project_id=#attributes.project_id#</cfif>&work_id=#work_id#'  target="_blank"> <i class="fa fa-file-text-o" style="color:grey;" title="<cf_get_lang dictionary_id ='38326.Malzeme'>"></i></a>
									</cfif>
								</cfif>
							</td>
							<td>
								<!--- Kopyalama --->
								<a href="javascript://" onclick="copy_work(#work_id#);"><i class="fa fa-copy" style="color:grey;" title="<cf_get_lang dictionary_id ='57476.Kopyala'>"></i></a>
							</td>
							<td>
								<cfif isdefined("attributes.project_id") and len(attributes.project_id) or isdefined("attributes.work_id") and len(attributes.work_id)>
									<!---Güncelleme ekranı Planlanan zaman harcaması ekleyebilmek için eklendi--->
									<cfquery name="GET_HISTORY_CONTROL" datasource="#DSN#">
										SELECT
											PWH.HISTORY_ID,
											PWH.WORK_ID,
											TMP.HISTORY_ID 
										FROM
											PRO_WORKS_HISTORY PWH
											LEFT JOIN TIME_COST_PLANNED TMP ON PWH.HISTORY_ID = TMP.HISTORY_ID
										WHERE 
											PWH.WORK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#GET_PRO_WORK.work_id#">
									</cfquery>
									<a href="javascript://" onclick="openBoxDraggable('#request.self#?fuseaction=project.popup_add_planned_actual_timecost&id=#GET_PRO_WORK.work_id#&history_id=#GET_HISTORY_CONTROL.HISTORY_ID#','','ui-draggable-box-large');"><i class="fa fa-calendar-plus-o" title="<cf_get_lang dictionary_id='60364.Planlanan Zaman Harcaması Ekle'>"></i></a>
								</cfif>
							</td>
							<td style="text-align:center">
								<!--- Ekleme---> 
								<cfif isdefined("x_is_related_tree_cat") and x_is_related_tree_cat eq 1>
									<a href="javascript://"  onclick="tree_gonder(3,'#work_id#');"><i class="fa fa-plus" title="<cf_get_lang dictionary_id='57933.İş Ekle'>" style="text-aling:center color:grey;"></i></a>
								<cfelse>
									<a onclick="openBoxDraggable('#request.self#?fuseaction=project.works&event=add<cfif isdefined("attributes.work_detail_id") and attributes.work_detail_id eq 0>&work_detail_id=0</cfif><cfif isDefined("attributes.project_id") and Len(attributes.project_id)>&id=#attributes.project_id#</cfif>&work_id=#work_id#&work_fuse=<cfif isdefined("url.work_fuse") and len(url.work_fuse)>#url.work_fuse#<cfelse>#attributes.fuseaction#</cfif><cfif isDefined("attributes.forum_reply_id")>&forum_reply_id=#attributes.forum_reply_id#</cfif><cfif isDefined("attributes.g_service_id")>&g_service_id=#attributes.g_service_id#<cfelseif isDefined("attributes.service_id")>&service_id=#attributes.service_id#<cfelseif isDefined("attributes.opp_id")>&opp_id=#attributes.opp_id#<cfelseif isDefined("attributes.product_sample_id")>&product_sample_id=#attributes.product_sample_id#</cfif>');"><i class="fa fa-plus" style="color:grey;" title="<cf_get_lang dictionary_id='57933.İş Ekle'>"></i></a>
								</cfif>
							</td>
							<td>								
								<cfif not len(emp_del_buttons.is_delete) and emp_del_buttons.is_delete neq 1>
									<cfif  not len(employee_denied.is_delete) and employee_denied.is_delete neq 1>
										<cfif isdefined("attributes.service_id") and len(attributes.service_id)>
												<input type="hidden" name="work_id#currentrow#" id="work_id#currentrow#" value="#GET_PRO_WORK.work_id#">
												<a href="javascript://" onclick="javascript:if (confirm('<cf_get_lang dictionary_id='33896.İş İlişkisini Silmek İstediğinizden Emin Misiniz?'>')) windowopen('#request.self#?fuseaction=project.emptypopup_del_work_relation&work_id=#GET_PRO_WORK.work_id#&service_id=#attributes.service_id#&type=1','small'); else return false;" >
												<i class="fa fa-minus" title="<cf_get_lang dictionary_id='57463.Sil'>" style="color:grey;"></i></a>
										<cfelseif isdefined("attributes.assetp_id") and len(attributes.assetp_id)>
												<input type="hidden" name="work_id#currentrow#" id="work_id#currentrow#" value="#GET_PRO_WORK.work_id#">
												<a href="javascript://" onclick="javascript:if (confirm('<cf_get_lang dictionary_id='33896.İş İlişkisini Silmek İstediğinizden Emin Misiniz?'>')) windowopen('#request.self#?fuseaction=project.emptypopup_del_work_relation&work_id=#GET_PRO_WORK.work_id#&assetp_id=#attributes.assetp_id#&type=2','small'); else return false;" >
												<i class="fa fa-minus" title="<cf_get_lang dictionary_id='57463.Sil'>" style="color:grey"></i></a>
										<cfelseif  isdefined("attributes.g_service_id") and len(attributes.g_service_id)>
												<input type="hidden" name="work_id#currentrow#" id="work_id#currentrow#" value="#GET_PRO_WORK.work_id#">
												<a href="javascript://" onclick="javascript:if (confirm('<cf_get_lang dictionary_id='33896.İş İlişkisini Silmek İstediğinizden Emin Misiniz?'>')) windowopen('#request.self#?fuseaction=project.emptypopup_del_work_relation&work_id=#GET_PRO_WORK.work_id#&g_service_id=#attributes.g_service_id#&type=3','small'); else return false;" >
												<i class="fa fa-minus" title="<cf_get_lang dictionary_id='57463.Sil'>" style="color:grey"></i></a>
										<cfelseif isdefined("attributes.project_id") and len(attributes.project_id) or isdefined("attributes.work_id") and len(attributes.work_id)>
												<input type="hidden" name="work_id#currentrow#" id="work_id#currentrow#" value="#GET_PRO_WORK.work_id#">
												<a href="javascript://" onclick="javascript:if (confirm('<cf_get_lang dictionary_id='33896.İş İlişkisini Silmek İstediğinizden Emin Misiniz?'>')) windowopen('#request.self#?fuseaction=project.emptypopup_del_work_relation&work_id=#GET_PRO_WORK.work_id#&project_id=#attributes.project_id#&type=4','small'); else return false;" >
												<i class="fa fa-minus" title="<cf_get_lang dictionary_id='57463.Sil'>" style="color:grey"></i></a>
										<cfelseif isdefined("attributes.opp_id") and len(attributes.opp_id)>
												<input type="hidden" name="work_id#currentrow#" id="work_id#currentrow#" value="#GET_PRO_WORK.work_id#">
												<a href="javascript://" onclick="javascript:if (confirm('<cf_get_lang dictionary_id='33896.İş İlişkisini Silmek İstediğinizden Emin Misiniz?'>')) openBoxDraggable('#request.self#?fuseaction=project.emptypopup_del_work_relation&work_id=#GET_PRO_WORK.work_id#&opp_id=#attributes.opp_id#&type=5'); else return false;" >
												<i class="fa fa-minus" title="<cf_get_lang dictionary_id='57463.Sil'>" style="color:grey"></i></a>
										<cfelseif isdefined("attributes.product_sample_id") and len(attributes.product_sample_id)>
											<input type="hidden" name="work_id#currentrow#" id="work_id#currentrow#" value="#GET_PRO_WORK.work_id#">
											<a href="javascript://" onclick="javascript:if (confirm('<cf_get_lang dictionary_id='33896.İş İlişkisini Silmek İstediğinizden Emin Misiniz?'>')) windowopen('#request.self#?fuseaction=project.emptypopup_del_work_relation&work_id=#GET_PRO_WORK.work_id#&product_sample_id=#attributes.product_sample_id#&type=7','small'); else return false;" >
											<i class="fa fa-minus" title="<cf_get_lang dictionary_id='57463.Sil'>" style="color:grey"></i></a>
										<cfelseif isdefined("attributes.subscription_id") and len(attributes.subscription_id)>
												<input type="hidden" name="work_id#currentrow#" id="work_id#currentrow#" value="#GET_PRO_WORK.work_id#">
												<a href="javascript://" onclick="javascript:if (confirm('<cf_get_lang dictionary_id='33896.İş İlişkisini Silmek İstediğinizden Emin Misiniz?'>')) windowopen('#request.self#?fuseaction=project.emptypopup_del_work_relation&work_id=#GET_PRO_WORK.work_id#&subscription_id=#attributes.subscription_id#&type=6','small'); else return false;" >
												<i class="fa fa-minus" title="<cf_get_lang dictionary_id='57463.Sil'>" style="color:grey"></i></a>
										</cfif>
									</cfif>
								</cfif>
							</td>
							<cfif isdefined("xml_milestone_transfer") and xml_milestone_transfer eq 1>
								<td class="text-center">
									<cfif type neq 0>
										<input type="checkbox" name="milestoneSendCheck" id="milestoneSendCheck" class="milestoneCheckControl" value="#work_id#" onclick="milestoneCheckControlFunction()"/>
									</cfif>
								</td>
							</cfif>
						</tr>
					</cfoutput>
				<cfelse>
					<tr>
						<td colspan="16"><cf_get_lang dictionary_id='57484.Kayıt Yok'> !</td>
					</tr>
				</cfif>
			</tbody>
		</cf_grid_list>
		
		<cfif isdefined("attributes.project_id") and len(attributes.project_id) and isdefined("xml_milestone_transfer") and xml_milestone_transfer eq 1>
			<div class="ui-form-list-btn" style="display: block;">
				<div class="ui-form-list flex-list">
					<cfquery name="GET_MILESTONE" datasource="#dsn#">
						SELECT WORK_ID,WORK_HEAD FROM PRO_WORKS WHERE PROJECT_ID = #attributes.project_id# AND IS_MILESTONE = 1 AND WORK_STATUS = 1 ORDER BY RECORD_DATE DESC
					</cfquery>
					<div class="form-group">
						<label><b><cf_get_lang dictionary_id='61707.İşleri farklı bir milestone altında toplamak istiyorsanız işleri seçerek aktarın'></b></label>
					</div>
					<div class="form-group medium">
						<select name="newMilestone" id="newMilestone">
							<cfoutput query="GET_MILESTONE">
								<option value="#WORK_ID#">#WORK_HEAD#</option>
							</cfoutput>
						</select>
					</div>	
					<div class="form-group">
						<button class="ui-wrk-btn ui-wrk-btn-success" id="transferButton" disabled="true" onclick="sendMilestone()"/><cf_get_lang dictionary_id='58676.Aktar'></button>
					</div>
				</div>
			</div>
		</cfif>
		<cfif attributes.totalrecords gt attributes.maxrows> 	
			<cfset adres = "">
			<cfset x_id="">
			<cfif isdefined("attributes.id") and len(attributes.id)>
				<cfset adres = "#adres#&id=#attributes.id#">
			</cfif>
			<cfif isdefined("attributes.service_id") and len(attributes.service_id)>
				<cfset adres = "#adres#&service_id=#attributes.service_id#">
				<cfset x_id=attributes.service_id>
			</cfif>
			<cfif isdefined("attributes.project_id") and len(attributes.project_id)>
				<cfset adres = "#adres#&project_id=#attributes.project_id#">
				<cfset x_id=attributes.project_id>
			</cfif>
			<cfif isdefined('attributes.is_submitted')>
				<cfset adres = "#adres#&is_submitted=1">
			</cfif>
			<cfif len(attributes.keywords)>
				<cfset adres = "#adres#&keywords=#attributes.keywords#"> 
			</cfif>
			<cfif len(attributes.currency)>
				<cfset adres = "#adres#&currency=#attributes.currency#"> 
			</cfif>
			<cfif len(attributes.priority_cat_)>
				<cfset adres = "#adres#&priority_cat_=#attributes.priority_cat_#">
			</cfif>
			<cfif len(attributes.activity_id)>
				<cfset adres = "#adres#&activity_id=#attributes.activity_id#">
			</cfif>
			<cfif isdefined('attributes.ordertype') and len(attributes.ordertype)>
				<cfset adres = "#adres#&ordertype=#attributes.ordertype#">
			</cfif>
			<cfif len(attributes.work_status)>
				<cfset adres = "#adres#&work_status=#attributes.work_status#">
			</cfif>
			<cfif isdefined("attributes.process_stage") and len(attributes.process_stage)>
				<cfset adres = "#adres#&process_stage=#attributes.process_stage#">
			</cfif>
			<cfif isdefined("attributes.status") and len(attributes.status)>
				<cfset adres = "#adres#&status=#attributes.status#">
			</cfif>
			<cfif isdefined("attributes.work_milestones") and len(attributes.work_milestones)>
				<cfset adres = "#adres#&work_milestones=#attributes.work_milestones#">
			</cfif>
			<cfif isdefined("attributes.xml_work_sort_type") and len(attributes.xml_work_sort_type)>
				<cfset adres = "#adres#&xml_work_sort_type=#attributes.xml_work_sort_type#">
			</cfif>
			<cfif isdefined("attributes.work_cat") and len(attributes.work_cat)>
				<cfset adres = "#adres#&work_cat=#attributes.work_cat#">
			</cfif>
			<cfif isdefined("attributes.work_detail_id") and len(attributes.work_detail_id)>
				<cfset adres = "#adres#&work_detail_id=#attributes.work_detail_id#">
			</cfif>
			<cfif isdefined("attributes.work_id") and len(attributes.work_id)>
				<cfset adres = "#adres#&work_id=#attributes.work_id#">
			</cfif>
			<cfif isdefined("attributes.related_project_info") and len(attributes.related_project_info)>
				<cfset adres = "#adres#&related_project_info=#attributes.related_project_info#">
			</cfif>
			<cf_paging page="#attributes.page#" 
				maxrows="#attributes.maxrows#"
				totalrecords="#get_pro_work.recordcount#"
				startrow="#attributes.startrow#"
				isAjax=true
				target="project_works_div_#x_id#"
				adres="project.emptypopup_ajax_project_works#adres#&project_detail_id=#attributes.project_detail_id#">
		</cfif>
		
	</div>
	<script type="text/javascript">
		function get_work_currency()
		{
			var currency_len = document.getElementById("currency").options.length;
			for(kk=currency_len;kk>=0;kk--)
				document.getElementById("currency").options[kk] = null;	
			document.getElementById("currency").options[0] = new Option('<cf_get_lang dictionary_id="57482.Asama">','');
			if(document.getElementById("work_cat").value != '')
			{
				var get_work_stage=wrk_safe_query('get_pro_works_currency','dsn',0,document.getElementById("work_cat").value);
					
				for(var jj=0;jj < get_work_stage.recordcount;jj++)
					document.getElementById("currency").options[jj+1]=new Option(get_work_stage.STAGE[jj],get_work_stage.PROCESS_ROW_ID[jj]);
			}
		}
		function copy_work(work_id)
		{
			if(confirm("<cf_get_lang dictionary_id='60614.İş kopyalanacaktır'>. <cf_get_lang dictionary_id='48488.Emin misiniz'>?"))
			{
				div_id ='project_works_div_<cfoutput>#this_div_id_#</cfoutput>'
				var send_address = '<cfoutput>#request.self#?fuseaction=project.emptypopup_copy_work<cfif isDefined("attributes.related_project_info")>&related_project_info=1</cfif><cfif isdefined("attributes.project_id")>&project_id=#attributes.project_id#</cfif><cfif isdefined("attributes.opp_id")>&opp_id=#attributes.opp_id#</cfif><cfif isdefined("attributes.product_sample_id")>&product_sample_id=#attributes.product_sample_id#</cfif><cfif isdefined("attributes.service_id")>&service_id=#attributes.service_id#</cfif><cfif isdefined("attributes.g_service_id")>&g_service_id=#attributes.g_service_id#</cfif><cfif isdefined("attributes.assetp_id")>&assetp_id=#attributes.assetp_id#</cfif><cfif isdefined("attributes.subscription_id")>&subscription_id=#attributes.subscription_id#</cfif>&main_mission_id=main_mission_id&main_mission_id=main_mission_id&project_detail_id=#attributes.project_detail_id#&work_id=</cfoutput>'+ work_id;
				AjaxPageLoad(send_address,div_id,1);
				return false;
			}
		}
		
		function swaping(deger,work_id)
		{
			if (deger <= 100)
			{
				div_id = 'complate_ratio_div'+work_id;
				if(document.getElementById('complate_ratio'+work_id) != undefined && document.getElementById('complate_ratio'+work_id).value.lenght != '')
				{	
					var send_address = '<cfoutput>#request.self#</cfoutput>?fuseaction=project.emptypopup_ajax_work_ratio&work_id='+ work_id +'&deger='+deger;
					AjaxPageLoad(send_address,div_id,1);
				}
			}
			else if (deger > 100)
			{
				alert("<cf_get_lang dictionary_id ='38338.Tamamlanma Orani 100 den kucük bir rakam olmalidir'>");
				return false;
			}
		}
		function loader_page2(_x_)
		{    
			//adress_ = '<cfoutput>#request.self#</cfoutput>?fuseaction=project.emptypopup_ajax_project_works'+_x_+'&currency='+document.getElementById('currency').value+'&xml_work_sort_type='+document.getElementById('xml_work_sort_type').value+'&priority_cat_='+document.getElementById('priority_cat_').value+'&activity_id='+document.getElementById('activity_id').value+'&workgroup_id='+document.getElementById('workgroup_id').value+'<cfif attributes.xml_show_work_category eq 1>&work_cat='+document.getElementById('work_cat').value+'</cfif>&ordertype='+document.getElementById('ordertype').value+'&work_status='+document.getElementById('work_status').value+'&xml_show_actual_date=<cfoutput>#attributes.xml_show_actual_date#</cfoutput><&work_milestones='+document.getElementById('work_milestones').value+'&maxrows='+document.getElementById('maxrows').value+'&xml_show_work_category='+document.getElementById('xml_show_work_category').value+'&xml_is_stage_cat='+document.getElementById('xml_is_stage_cat').value+'&xml_is_stage_work_cat='+document.getElementById('xml_is_stage_work_cat').value+'&xml_change_complate_ratio='+document.getElementById('xml_change_complate_ratio').value;
			adress_ = '<cfoutput>#request.self#</cfoutput>?fuseaction=project.emptypopup_ajax_project_works'+_x_+'&keywords='+document.getElementById('keywords').value+'<cfif attributes.xml_show_work_category eq 1>&work_cat='+document.getElementById('work_cat').value+'</cfif>&currency='+document.getElementById('currency').value+'&workgroup_id='+document.getElementById('workgroup_id').value+'&priority_cat_='+document.getElementById('priority_cat_').value+'&ordertype='+document.getElementById('ordertype').value+'&work_milestones='+document.getElementById('work_milestones').value+'&work_status='+document.getElementById('work_status').value+'&maxrows='+document.getElementById('maxrows').value+'&related_project_info='+document.getElementById('related_project_info').value+'<cfif isdefined("xml_milestone_transfer")>&xml_milestone_transfer=<cfoutput>#xml_milestone_transfer#</cfoutput></cfif>';
			AjaxPageLoad(adress_,'project_works_div_<cfoutput>#this_div_id_#</cfoutput>',1);
			return false;
		}
		function loader_page()
		{
			document.getElementById('project_submit_button').click();
		}
		function show_hide_works(id){
			$('[id="'+id+'"]').toggle();
		}
		        function milestoneCheckControlFunction(){
            if($(".milestoneCheckControl:checked").length == 0)
                $("#transferButton").attr('disabled',true);
            else
                $("#transferButton").attr('disabled',false);
        }
        
        function sendMilestone(){
            div_id ='project_works_div_<cfoutput>#this_div_id_#</cfoutput>';
            workIdList = '';
            $(".milestoneCheckControl").each(function(index,element){
                if($(element).is(":checked")){
                    if(!workIdList.length)
                        workIdList = $(element).val();
                    else
                        workIdList = workIdList+','+$(element).val();
                }
            })
            var send_address = '<cfoutput>#request.self#?fuseaction=project.emptypopup_copy_work&project_id=#attributes.project_id#&xml_milestone_transfer=#xml_milestone_transfer?:""#&main_mission_id=main_mission_id&work_id='+workIdList+'&project_detail_id=#attributes.project_detail_id#&from_milestone=1&order_type=#attributes.ordertype#&work_milestones=#attributes.work_milestones#&newMilestone=</cfoutput>'+$("#newMilestone").val();
            AjaxPageLoad(send_address,div_id,1);
            return false;
        }
	</script>
<cfelse>
	<!--- <cf_xml_page_edit fuseact="project.prodetail"> Kullanildigi sayfalardaki xmli engellediginden kapatildi, bu sekilde kullanilmamali, nerede kullanildigi belirtilirse duzenleme yapilir FBS 20120319 --->
	<!--- bu sayfa firsat,service,callcenter,service ,proje ve fiziki varlık,sistem(basvuru) detaydan cagirilir... bu dosyaya bagli olarak copy_work.cfm ve del_work.cfm duzenlenmelidir --->
	<cfsetting showdebugoutput="no">
	<cf_get_lang_set module_name="project"><!--- sayfanin en altinda kapanisi var --->
	<cfparam name="attributes.priority_cat_" default="">
	<cfparam name="attributes.activity_id" default="">
	<cfparam name="attributes.project_id" default="">
	<cfparam name="attributes.currency" default="">
	<cfparam name="attributes.keywords" default="">
	<cfparam name="attributes.workgroup_id" default="">
	<cfif  isDefined("attributes.service_id")>
		<cfparam name="attributes.work_status" default="0">
	<cfelse>
		<cfparam name="attributes.work_status" default="1">
	</cfif>
	<cfparam name="attributes.page" default="1">
	<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>
	<cfparam name="attributes.startrow" default="1">
	<cfparam name="attributes.work_milestones" default="1">
	<cfparam name="attributes.xml_is_stage_cat" default="0">
	<cfparam name="attributes.xml_is_stage_work_cat" default="0">
	<cfparam name="attributes.xml_work_sort_type" default="0">
	<cfparam name="attributes.xml_change_complate_ratio" default="1">
	<cfparam name="attributes.xml_show_actual_date" default="1">
	<cfparam name="attributes.xml_show_work_category" default="1">
	<cfset xml_list = '&xml_is_stage_cat=#attributes.xml_is_stage_cat#&xml_is_stage_work_cat=#attributes.xml_is_stage_work_cat#&xml_work_sort_type=#attributes.xml_work_sort_type#&xml_change_complate_ratio=#attributes.xml_change_complate_ratio#&xml_show_actual_date=#attributes.xml_show_actual_date#&xml_show_work_category=#attributes.xml_show_work_category#'>
	<cfif attributes.xml_show_work_category eq 1>
		<cfparam name="attributes.work_cat" default="">
	</cfif>
	<cfif isdefined('attributes.xml_work_sort_type') and len(attributes.xml_work_sort_type)>
		<cfparam name="attributes.ordertype" default="#attributes.xml_work_sort_type#">
	</cfif>
	<cfif isdefined("attributes.work_id") and len(attributes.work_id)>
	<cfset work_id_list = "">
		<cfquery name="GET_RELATED_WORK" datasource="#DSN#">
			SELECT
					PRO_WORK_RELATIONS.WORK_ID
				FROM
					PRO_WORK_RELATIONS,
					PRO_WORKS PRE,
					PRO_WORKS ORIGINAL
				WHERE
					PRE.WORK_ID = PRO_WORK_RELATIONS.PRE_ID AND
					ORIGINAL.WORK_ID = PRO_WORK_RELATIONS.WORK_ID AND
					PRO_WORK_RELATIONS.PRE_ID	 = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.work_id#">
		</cfquery>
		<cfset work_id_list = valuelist(GET_RELATED_WORK.work_id)>
	</cfif>
	<cfquery name="GET_PRO_WORK" datasource="#DSN#">
		SELECT
			*
		FROM
		(
			SELECT
				CASE 
					WHEN IS_MILESTONE = 1 THEN WORK_ID
					WHEN IS_MILESTONE <> 1 THEN ISNULL(MILESTONE_WORK_ID,0)
				END AS NEW_WORK_ID,
				CASE 
					WHEN IS_MILESTONE = 1 THEN 0
					WHEN IS_MILESTONE <> 1 THEN 1
				END AS TYPE,
				PW.IS_MILESTONE,
				PW.MILESTONE_WORK_ID,
				PW.RELATED_WORK_ID,
				PW.WORK_ID,
				PW.WORK_HEAD,
				PW.ESTIMATED_TIME,
				(SELECT PTR.STAGE FROM PROCESS_TYPE_ROWS PTR WHERE PTR.PROCESS_ROW_ID= PW.WORK_CURRENCY_ID) STAGE,
				(SELECT PWC.WORK_CAT FROM PRO_WORK_CAT PWC WHERE PWC.WORK_CAT_ID= PW.WORK_CAT_ID) WORK_CAT,
				PW.WORK_PRIORITY_ID,
				CASE 
					WHEN PW.PROJECT_EMP_ID IS NOT NULL THEN (SELECT E.EMPLOYEE_NAME +' '+ E.EMPLOYEE_SURNAME FROM EMPLOYEES E WHERE E.EMPLOYEE_ID = PW.PROJECT_EMP_ID)
					WHEN PW.OUTSRC_PARTNER_ID IS NOT NULL THEN (SELECT C2.NICKNAME+' - '+ CP2.COMPANY_PARTNER_NAME + ' ' + CP2.COMPANY_PARTNER_SURNAME NAME FROM COMPANY_PARTNER CP2,COMPANY C2 WHERE C2.COMPANY_ID = CP2.COMPANY_ID AND CP2.PARTNER_ID = PW.OUTSRC_PARTNER_ID)
				END AS EMPLOYEE,
				PW.TARGET_FINISH,
				PW.TARGET_START,
				PW.REAL_FINISH,
				PW.REAL_START,
				PW.TO_COMPLETE,
				PW.UPDATE_DATE,
				PW.RECORD_DATE,
				SP.PRIORITY,
				SP.COLOR,
				SA.ACTIVITY_NAME,
				(SELECT TOP 1 PRO_MATERIAL.PRO_MATERIAL_ID FROM PRO_MATERIAL WHERE PRO_MATERIAL.WORK_ID = PW.WORK_ID) PRO_MATERIAL_ID
			FROM
			PRO_WORKS PW
			LEFT JOIN SETUP_PRIORITY SP ON PW.WORK_PRIORITY_ID = SP.PRIORITY_ID
			LEFT JOIN SETUP_ACTIVITY SA ON PW.ACTIVITY_ID = SA.ACTIVITY_ID
			WHERE
				<cfif isDefined("attributes.g_service_id")> <!--- callcenter başvuruları için eklendi  --->
					PW.G_SERVICE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.g_service_id#">
				<cfelseif isDefined("attributes.service_id")> <!--- servis başvuruları  --->
					(PW.OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#"> OR PW.OUR_COMPANY_ID IS NULL) AND
					PW.SERVICE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.service_id#">
				<cfelseif isDefined("attributes.opp_id")> <!--- fırsatlar  --->
					(PW.OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#"> OR PW.OUR_COMPANY_ID IS NULL) AND
					PW.OPPORTUNITY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.opp_id#">
				<cfelseif isdefined("attributes.assetp_id")> <!--- fiziki varlık  --->
					PW.ASSETP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.assetp_id#">
				<cfelseif isdefined("attributes.product_sample_id")> <!--- NUMUNE  --->
					PW.PRODUCT_SAMPLE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.product_sample_id#">
				<cfelseif isdefined("attributes.subscription_id")> <!---sistem basvurulari  --->
					PW.SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.subscription_id#">
				<cfelseif isdefined("attributes.forum_reply_id")> <!---sistem basvurulari  --->
					PW.FORUM_REPLY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.forum_reply_id#">
				<cfelseif isdefined("attributes.work_id") and len(attributes.work_id)>
				(
					PW.MILESTONE_WORK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.work_id#">
					<cfif len(work_id_list)>
					OR
					PW.WORK_ID IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#work_id_list#" list="yes">)
					</cfif>
				)
				<cfelse>
					PW.PROJECT_ID =<cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.project_id#">
				</cfif>
				<cfif len(attributes.keywords)>
					AND PW.WORK_HEAD LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.keywords#%">
				</cfif>
				<cfif len(attributes.priority_cat_)>
					AND PW.WORK_PRIORITY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.priority_cat_#">
				</cfif>
				<cfif len(attributes.activity_id)>
					AND PW.ACTIVITY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.activity_id#">
				</cfif> 
				<cfif len(attributes.workgroup_id)>
					AND (PW.WORKGROUP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.workgroup_id#"><cfif get_workgroup.recordCount> OR PW.PROJECT_EMP_ID IN(#valueList(get_workgroup.EMPLOYEE_ID)#)</cfif>)
				</cfif>
				<cfif isdefined("attributes.work_cat") and len(attributes.work_cat)>
					AND PW.WORK_CAT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.work_cat#">
				</cfif>
				<cfif len(attributes.currency)>
					AND PW.WORK_CURRENCY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.currency#">
				</cfif>
				<cfif attributes.work_status eq -1>
					AND PW.WORK_STATUS = 0 <!--- (PW.WORK_STATUS = 0 OR PW.IS_MILESTONE = 1) pasif olmayan üst işlerin gelmesine neden oluyordu FA --->
				<cfelseif attributes.work_status eq 1>
					AND PW.WORK_STATUS = 1 <!--- (PW.WORK_STATUS = 1 OR PW.IS_MILESTONE = 1) aktif olmayan üst işlerin gelmesine neden oluyordu GA --->
				</cfif>
				)T1
			WHERE
				1=1 
				<cfif attributes.work_milestones eq 0>
					AND IS_MILESTONE <> 1
					ORDER BY NEW_WORK_ID
				<cfelse>
					ORDER BY NEW_WORK_ID,TYPE
				</cfif>       
					
			<cfif isdefined("attributes.ordertype") and attributes.ordertype eq 1>
					,WORK_ID DESC
			<cfelseif isdefined("attributes.ordertype") and attributes.ordertype eq 2>
					,ISNULL(UPDATE_DATE,RECORD_DATE) DESC
				<cfelseif isdefined("attributes.ordertype") and attributes.ordertype eq 3>
				,TARGET_START DESC
				<cfelseif isdefined("attributes.ordertype") and attributes.ordertype eq 4>
				,TARGET_START
				<cfelseif isdefined("attributes.ordertype") and attributes.ordertype eq 5>
				,TARGET_FINISH DESC
				<cfelseif isdefined("attributes.ordertype") and attributes.ordertype eq 6>
				,TARGET_FINISH
				<cfelseif isdefined("attributes.ordertype") and attributes.ordertype eq 7>
				,WORK_HEAD
				</cfif>
				
	</cfquery>
	<cfquery name="GET_ACTIVITY" datasource="#DSN#">
		SELECT ACTIVITY_ID, ACTIVITY_NAME FROM SETUP_ACTIVITY WHERE ACTIVITY_STATUS = 1 ORDER BY ACTIVITY_NAME
	</cfquery>
	<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
	<cfparam name="attributes.totalrecords" default='#get_pro_work.recordcount#'>
	<cfparam name="attributes.page" default=1>
	<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>
	<cfset work_h_list = ''>
	<cfif get_pro_work.recordcount>
		<cfset work_h_list = valuelist(get_pro_work.work_id)>
		<cfquery name="GET_HARCANAN_ZAMAN" datasource="#DSN#">
			SELECT 
				SUM(EXPENSED_MINUTE) AS HARCANAN_DAKIKA,
				WORK_ID 
			FROM 
				TIME_COST 
			WHERE 
				WORK_ID IN (#work_h_list#)
			GROUP BY
				WORK_ID
			ORDER BY
				WORK_ID
		</cfquery>
		<cfset work_h_list = listsort(listdeleteduplicates(valuelist(get_harcanan_zaman.work_id,',')),'numeric','ASC',',')>
	</cfif>
	<cfif attributes.xml_is_stage_cat eq 1 and isdefined("attributes.project_id")>
		<cfquery name="GET_PRO_CAT" datasource="#DSN#">
			SELECT PROCESS_CAT FROM PRO_PROJECTS WHERE PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.project_id#">
		</cfquery>
		<cfquery name="GET_WORK_CURRENCY" datasource="#DSN#">
			SELECT PROCESS_ID FROM PRO_WORK_CAT WHERE PROCESS_ID IS NOT NULL AND ','+MAIN_PROCESS_ID+',' LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%,#get_pro_cat.process_cat#,%">
		</cfquery>
	</cfif>
	<cfquery name="GET_PROCURRENCY" datasource="#DSN#">
		SELECT
			PTR.STAGE,
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
			PT.FACTION LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%project.works%">
			<cfif attributes.xml_is_stage_cat eq 1 and isdefined("attributes.project_id") and get_work_currency.recordcount>
				AND PTR.PROCESS_ROW_ID IN ( #valuelist(get_work_currency.process_id)# )
			</cfif>
			<cfif attributes.xml_is_stage_work_cat eq 1 and attributes.xml_show_work_category eq 1>
				<cfif len(attributes.work_cat)>
					AND ','+(SELECT PROCESS_ID FROM PRO_WORK_CAT WHERE WORK_CAT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.work_cat#">)+',' LIKE '%,'+CAST(PTR.PROCESS_ROW_ID AS NVARCHAR)+',%'
				<cfelse>
					AND 1 = 0
				</cfif>
			</cfif>
		ORDER BY
			PTR.LINE_NUMBER
	</cfquery>
	<cfquery name="GET_WORKGROUPS" datasource="#DSN#">
		SELECT 
			WORKGROUP_ID,
			WORKGROUP_NAME
		FROM 
			WORK_GROUP
		WHERE
			STATUS = 1
			AND HIERARCHY IS NOT NULL
		ORDER BY 
			HIERARCHY
	</cfquery>
	<cfinclude template="../query/get_priority.cfm">
	<cfinclude template="../query/get_pro_work_cat.cfm">
	<cfif isDefined("attributes.related_project_info")>
		<cfset this_div_id_ = attributes.project_id>
	<cfelseif isDefined("attributes.g_service_id")>
		<cfset this_div_id_ = attributes.g_service_id>
	<cfelseif isDefined("attributes.service_id")>
		<cfset this_div_id_ = attributes.service_id>
	<cfelseif isDefined("attributes.opp_id")>
		<cfset this_div_id_ = attributes.opp_id>
	<cfelseif isDefined("attributes.product_sample_id")>
		<cfset this_div_id_ = attributes.product_sample_id>
	<cfelseif isDefined("attributes.project_id")>
		<cfset this_div_id_ = attributes.project_id>
	<cfelseif isDefined("attributes.assetp_id")>
		<cfset this_div_id_ = attributes.assetp_id>
	<cfelseif isDefined("attributes.subscription_id")>
		<cfset this_div_id_ = attributes.subscription_id>
	<cfelseif isDefined("attributes.forum_reply_id")>
		<cfset this_div_id_ = attributes.forum_reply_id>
	</cfif>
	<cfif isDefined('this_div_id_') and this_div_id_ eq -1>
		<cfset this_div_id_ = 0>
	</cfif>
	<div id="project_works_div_<cfoutput>#this_div_id_#</cfoutput>">
	<cfform name="works_#this_div_id_#" method="post" action="">
		<cf_box_search more="0">
			<input type="hidden" name="is_submitted" id="is_submitted" value="1" />
			<input type="hidden" name="xml_work_sort_type" id="xml_work_sort_type" value="<cfif isdefined('attributes.xml_work_sort_type') and len(attributes.xml_work_sort_type)><cfoutput>#attributes.xml_work_sort_type#</cfoutput></cfif>" />
			<input type="hidden" name="xml_is_stage_cat" id="xml_is_stage_cat" value="<cfif isdefined('attributes.xml_is_stage_cat') and len(attributes.xml_is_stage_cat)><cfoutput>#attributes.xml_is_stage_cat#</cfoutput></cfif>" />
			<input type="hidden" name="xml_is_stage_work_cat" id="xml_is_stage_work_cat" value="<cfif isdefined('attributes.xml_is_stage_work_cat') and len(attributes.xml_is_stage_work_cat)><cfoutput>#attributes.xml_is_stage_work_cat#</cfoutput></cfif>" />
			<input type="hidden" name="xml_change_complate_ratio" id="xml_change_complate_ratio" value="<cfif isdefined('attributes.xml_change_complate_ratio') and len(attributes.xml_change_complate_ratio)><cfoutput>#attributes.xml_change_complate_ratio#</cfoutput></cfif>" />
			<input type="hidden" name="xml_show_actual_date" id="xml_show_actual_date" value="<cfif isdefined('attributes.xml_show_actual_date') and len(attributes.xml_show_actual_date)><cfoutput>#attributes.xml_show_actual_date#</cfoutput></cfif>" />
			<input type="hidden" name="xml_show_work_category" id="xml_show_work_category" value="<cfif isdefined('attributes.xml_show_work_category') and len(attributes.xml_show_work_category)><cfoutput>#attributes.xml_show_work_category#</cfoutput></cfif>" />
			<cfif isDefined("attributes.related_project_info")>
				<div class="form-group large">
					<cfinput type="text" name="keywords" value="#attributes.keywords#" id="keywords" style="width:100px;color:999999;" onFocus="if(this.value=='Filtre'){this.value='';this.style.color =''}" onKeyPress="if(event.keyCode==13 ) {loader_page(#attributes.project_id#); return false;}">
				</div>
			<cfelse>
				<div class="form-group large">
					<cfinput type="text" name="keywords" value="#attributes.keywords#" id="keywords" style="width:100px;color:999999;" onFocus="if(this.value=='Filtre'){this.value='';this.style.color =''}" onKeyPress="if(event.keyCode==13 ) {loader_page(#this_div_id_#); return false;}">
				</div>
			</cfif>
			<cfif attributes.xml_show_work_category eq 1>
				<div class="form-group medium">
					<select name="work_cat" id="work_cat" style="width:100px;" <cfif attributes.xml_is_stage_work_cat eq 1 and isdefined("attributes.project_id")>onChange="get_work_currency();"</cfif>>
						<option value=""><cf_get_lang dictionary_id='57486.Kategori'></option>
						<cfoutput query="get_work_cat">
							<option value="#get_work_cat.work_cat_id#" <cfif attributes.work_cat eq get_work_cat.work_cat_id>selected</cfif>>#get_work_cat.work_cat#</option>
						</cfoutput>
					</select>
				</div>
			</cfif>
			<div class="form-group medium">
				<select name="currency" id="currency" style="width:70px; height:17px;">
					<option value=""><cf_get_lang dictionary_id='57482.Asama'></option>
					<cfoutput query="get_procurrency">
						<option value="#process_row_id#" <cfif attributes.currency eq process_row_id>selected</cfif>>#stage#</option>
					</cfoutput>
				</select>
			</div>
			<div class="form-group medium">
				<select name="workgroup_id" id="workgroup_id" style="width:150px;">				  
					<option value=""><cf_get_lang dictionary_id='58140.İş Grubu'></option>
					<cfoutput query="get_workgroups">
						<option value="#workgroup_id#" <cfif isdefined("attributes.workgroup_id") and workgroup_id eq attributes.workgroup_id>selected</cfif>>#workgroup_name#</option>
					</cfoutput>
				</select>
			</div>
			<div class="form-group medium">
				<select name="priority_cat_" id="priority_cat_" style="width:100px;">
					<option value=""><cf_get_lang dictionary_id='57485.Öncelik'></option>
					<cfoutput query="get_cats">
						<option value="#priority_id#" <cfif attributes.priority_cat_ eq priority_id>selected</cfif>>#priority#</option>
					</cfoutput>
				</select>
			</div>
			<div class="form-group medium">
				<select name="activity_id" id="activity_id" style="width:100px;">
					<option value=""><cf_get_lang dictionary_id='38378.Aktivite Tipi'></option>
					<cfoutput query="get_activity">
						<option value="#activity_id#" <cfif attributes.activity_id eq activity_id>selected</cfif> >#activity_name#</option>
					</cfoutput>
				</select>
			</div>
			<div class="form-group large">
				<select name="ordertype" id="ordertype" style="width:150px;">
					<option value="1" <cfif isdefined("attributes.ordertype") and attributes.ordertype eq 1>selected</cfif>><cf_get_lang dictionary_id='38256.İş ve Id ye Göre Azalan'></option>
					<option value="2" <cfif isdefined("attributes.ordertype") and attributes.ordertype eq 2>selected</cfif>><cf_get_lang dictionary_id='38328.Güncellemeye Göre Azalan'></option>
					<option value="3" <cfif isdefined("attributes.ordertype") and attributes.ordertype eq 3>selected</cfif>><cf_get_lang dictionary_id='38330.Başlangıç Tarihine Göre Azalan'></option>
					<option value="4" <cfif isdefined("attributes.ordertype") and attributes.ordertype eq 4>selected</cfif>><cf_get_lang dictionary_id='38331.Başlangıç Tarihine Göre Artan'></option>
					<option value="5" <cfif isdefined("attributes.ordertype") and attributes.ordertype eq 5>selected</cfif>><cf_get_lang dictionary_id='38332.Bitiş Tarihine Göre Azalan'></option>
					<option value="6" <cfif isdefined("attributes.ordertype") and attributes.ordertype eq 6>selected</cfif>><cf_get_lang dictionary_id='38260.Bitiş Tarihine Göre Artan'></option>
					<option value="7" <cfif isdefined("attributes.ordertype") and attributes.ordertype eq 7>selected</cfif>><cf_get_lang dictionary_id='38270.İş Başlığına göre Alfabetik'></option>
				</select>
			</div>
			<div class="form-group medium">
				<select name="work_milestones" id="work_milestones" style="width:120px;">
					<option value="1" <cfif attributes.work_milestones eq 1>selected="selected"</cfif>><cf_get_lang dictionary_id='30781.Üst İşler Dahil'></option>
					<option value="0" <cfif attributes.work_milestones eq 0>selected="selected"</cfif>><cf_get_lang dictionary_id='30784.Milestonlar Haric'></option>
				</select>
			</div>
			<div class="form-group medium">
				<select name="work_status" id="work_status">
					<option value="1" <cfif attributes.work_status eq 1>selected="selected"</cfif>><cf_get_lang dictionary_id='57493.Aktif'></option>
					<option value="-1" <cfif attributes.work_status eq -1>selected="selected"</cfif>><cf_get_lang dictionary_id='57494.Pasif'></option>
					<option value="0" <cfif attributes.work_status eq 0>selected="selected"</cfif>><cf_get_lang dictionary_id='57708.Tümü'></option>
				</select>
			</div>
			<div class="form-group small">
				<cfsavecontent variable="message"><cf_get_lang dictionary_id='57537.Sayi_Hatasi_Mesaj'></cfsavecontent>
				<cfinput type="text" name="maxrows" id="maxrows" value="#attributes.maxrows#" required="yes" validate="integer" range="1,999" message="#message#" maxlength="3" style="width:25px;text-align:right;">
			</div>
			<cfsavecontent variable="search"><cf_get_lang dictionary_id ='57565.Ara'></cfsavecontent>
			
			<cfset send_ = "">
			<cfif isdefined("attributes.work_id")><cfset send_ = "#send_#&work_id=#attributes.work_id#"></cfif>
			<cfif isdefined("attributes.project_id")><cfset send_ = "#send_#&project_id=#attributes.project_id#"></cfif>
			<cfif isdefined("attributes.opp_id")><cfset send_ = "#send_#&opp_id=#attributes.opp_id#"></cfif>
			<cfif isdefined("attributes.product_sample_id")><cfset send_ = "#send_#&product_sample_id=#attributes.product_sample_id#"></cfif>
			<cfif isdefined("attributes.service_id")><cfset send_ = "#send_#&service_id=#attributes.service_id#"></cfif>
			<cfif isdefined("attributes.assetp_id")><cfset send_ = "#send_#&assetp_id=#attributes.assetp_id#"></cfif>
			<cfif isdefined("attributes.g_service_id")><cfset send_ = "#send_#&g_service_id=#attributes.g_service_id#"></cfif>
			<cfif isdefined("attributes.subscription_id")><cfset send_ = "#send_#&subscription_id=#attributes.subscription_id#"></cfif>
			<div class="form-group">
				<a href="javascript://" onclick="loader_page2('<cfoutput>#send_#</cfoutput>');" id="project_submit_button" class="ui-btn ui-btn-green"><i class="fa fa-search"></i></a>
			</div>
			<div class="form-group">
				<a class="ui-btn ui-btn-gray" href="javascript://" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=project.works&event=add<cfif isdefined("attributes.work_detail_id") and attributes.work_detail_id eq 0>&work_detail_id=0</cfif><cfif isDefined("attributes.project_id")>&id=#attributes.project_id#</cfif><cfif isDefined("attributes.forum_reply_id")>&forum_reply_id=#attributes.forum_reply_id#</cfif>&work_fuse=<cfif isdefined("url.work_fuse") and len(url.work_fuse)>#url.work_fuse#<cfelse>#attributes.fuseaction#</cfif><cfif isDefined("attributes.g_service_id")>&g_service_id=#attributes.g_service_id#<cfelseif isDefined("attributes.service_id")>&service_id=#attributes.service_id#<cfelseif isDefined("attributes.opp_id")>&opp_id=#attributes.opp_id#<cfelseif isDefined("attributes.product_sample_id")>&product_sample_id=#attributes.product_sample_id#<cfelseif isDefined("attributes.assetp_id")>&assetp_id=#attributes.assetp_id#<cfelseif isDefined("attributes.subscription_id")>&subscription_id=#attributes.subscription_id#</cfif></cfoutput>','','ui-draggable-box-large');"> <i class="fa fa-plus"  title="<cf_get_lang dictionary_id='57933.İş Ekle'>"></i></a>
			</div>
		</cf_box_search>
	</cfform>
	<cf_grid_list>
		<thead>
			<tr>
				<th width="30"><cf_get_lang dictionary_id='57487.No'></th>
				<th><cf_get_lang dictionary_id='38213.İş'></th>
				<th><cf_get_lang dictionary_id='57569.Görevli'></th>
				<th><cf_get_lang dictionary_id='57485.Öncelik'></th>            
				<th><cf_get_lang dictionary_id='58869.Planlanan'></th>
				<cfif attributes.xml_show_actual_date eq 1>
					<th><cf_get_lang dictionary_id='38454.Gerçekleşen'> </th>
				</cfif>
				<th><cf_get_lang dictionary_id='57482.Aşama'></th>
				<cfif attributes.xml_show_work_category eq 1>
					<th><cf_get_lang dictionary_id='57486.Kategori'></th>
				</cfif>
				<th><cf_get_lang dictionary_id='38378.Aktivite Tipi'></th>
				<th><cf_get_lang dictionary_id='38215.Ongorulen süre'></th>
				<th><cf_get_lang dictionary_id='38128.harcanan süre'></th>
				<th width="20">%<!--- Yuzde ---></th>
				<cfif not listfindnocase(denied_pages,'project.project_material') and isDefined("attributes.related_project_info")><th style="width:15px;"><!--- Malzeme ---></th></cfif>
				<cfif isdefined("attributes.ajax")>
					<!--- <th style="width:15px;"><!--- Silme ---></th> --->
					<th width="20">
						<!--- Kopyalama --->
						<cfif isDefined("attributes.service_id")>
							<cfif isDefined("attributes.related_project_info")>
								<a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_add_related_work&rel_work_id=works_#this_div_id_#.work_rela_id&relat_pro=works_#this_div_id_#.project_rela_id&related_service_id=#service_id#&call_function=loader_page(#attributes.project_id#</cfoutput>','work');"><i class="fa fa-sitemap"  title="<cf_get_lang dictionary_id='54987.İlişkili İş'>"></i></a>
							<cfelse>
								<a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_add_related_work&rel_work_id=works_#this_div_id_#.work_rela_id&relat_pro=works_#this_div_id_#.project_rela_id&related_service_id=#service_id#&call_function=loader_page(#this_div_id_#)</cfoutput>','work');"><i class="fa fa-sitemap"  title="<cf_get_lang dictionary_id='54987.İlişkili İş'>"></i></a>
							</cfif>
						<cfelseif isDefined("attributes.assetp_id")>
							<a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_add_related_work&rel_work_id=works_#this_div_id_#.work_rela_id&relat_pro=works_#this_div_id_#.project_rela_id&related_assetp_id=#assetp_id#&call_function=loader_page(#this_div_id_#)</cfoutput>','work');"><i class="fa fa-sitemap"  title="<cf_get_lang dictionary_id='54987.İlişkili İş'>"></i></a>
						<cfelseif isDefined("attributes.g_service_id")>
							<a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_add_related_work&rel_work_id=works_#this_div_id_#.work_rela_id&relat_pro=works_#this_div_id_#.project_rela_id&related_g_service_id=#g_service_id#&call_function=loader_page(#this_div_id_#)</cfoutput>','work');"><i class="fa fa-sitemap" title="<cf_get_lang dictionary_id='54987.İlişkili İş'>"></i></a>                        
						<cfelseif isDefined("attributes.opp_id")>
							<a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_add_related_work&rel_work_id=works_#this_div_id_#.work_rela_id&relat_pro=works_#this_div_id_#.project_rela_id&related_opp_id=#opp_id#&call_function=loader_page(#this_div_id_#)</cfoutput>','work');"><i class="fa fa-sitemap"  title="<cf_get_lang dictionary_id='54987.İlişkili İş'>"></i></a> 
							<cfelseif isDefined("attributes.product_sample_id")>
								<a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_add_related_work&rel_work_id=works_#this_div_id_#.work_rela_id&relat_pro=works_#this_div_id_#.project_rela_id&related_product_sample_id=#product_sample_id#&call_function=loader_page(#this_div_id_#)</cfoutput>','work');"><i class="fa fa-sitemap"  title="<cf_get_lang dictionary_id='54987.İlişkili İş'>"></i></a>                        
						<cfelseif isDefined("attributes.subscription_id")>
							<a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_add_related_work&rel_work_id=works_#this_div_id_#.work_rela_id&relat_pro=works_#this_div_id_#.project_rela_id&related_subscription_id=#subscription_id#&call_function=loader_page(#this_div_id_#)</cfoutput>','work');"><i class="fa fa-sitemap"  title="<cf_get_lang dictionary_id='54987.İlişkili İş'>"></i></a>                        
						<cfelseif isDefined("attributes.forum_reply_id")>
							<a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_add_related_work&rel_work_id=works_#this_div_id_#.work_rela_id&relat_pro=works_#this_div_id_#.project_rela_id&related_reply_id=#attributes.forum_reply_id#&call_function=loader_page(#this_div_id_#)</cfoutput>','work');"><i class="fa fa-sitemap"  title="<cf_get_lang dictionary_id='54987.İlişkili İş'>"></i></a>
						</cfif>
					</th>
				</cfif>
				<cfif isdefined("attributes.project_id") and len(attributes.project_id)>
					<th><a href="javascript://"><i class="fa fa-calendar-check-o"></i></a></th>
				</cfif>
				<th width="20">
					<!--- Ekleme --->
					<cfif not listfindnocase(denied_pages,'project.popup_add_work')>
						<cfif isdefined("x_is_related_tree_cat") and x_is_related_tree_cat eq 1>
							<a href="javascript://"  onclick="tree_gonder(1,'');"><i class="fa fa-plus" title="<cf_get_lang dictionary_id='57933.İş Ekle'>" /></i></a>
						<cfelse><!--- FBS 20120222 project_id olarak degistirdim, sorun oluyordu, bu sekilde de sorun olursa bildirin duzeltelim <cfif isDefined("attributes.related_project_info")>&id=#attributes.project_id#<cfelseif isdefined("attributes.action_project_id") and len(attributes.action_project_id)>&id=#attributes.action_project_id#</cfif> --->
							<a onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=project.works&event=add<cfif isdefined("attributes.work_detail_id") and attributes.work_detail_id eq 0>&work_detail_id=0</cfif><cfif isDefined("attributes.project_id")>&id=#attributes.project_id#</cfif><cfif isDefined("attributes.forum_reply_id")>&forum_reply_id=#attributes.forum_reply_id#</cfif>&work_fuse=<cfif isdefined("url.work_fuse") and len(url.work_fuse)>#url.work_fuse#<cfelse>#attributes.fuseaction#</cfif><cfif isDefined("attributes.g_service_id")>&g_service_id=#attributes.g_service_id#<cfelseif isDefined("attributes.service_id")>&service_id=#attributes.service_id#<cfelseif isDefined("attributes.opp_id")>&opp_id=#attributes.opp_id#<cfelseif isDefined("attributes.product_sample_id")>&product_sample_id=#attributes.product_sample_id#<cfelseif isDefined("attributes.assetp_id")>&assetp_id=#attributes.assetp_id#<cfelseif isDefined("attributes.subscription_id")>&subscription_id=#attributes.subscription_id#</cfif></cfoutput>','','ui-draggable-box-large');"> <i class="fa fa-plus"  title="<cf_get_lang dictionary_id='57933.İş Ekle'>"></i></a>
						</cfif>
					</cfif>
				</th>
				<th width="20"><a href="javascript://"><i class="fa fa-minus"></i></a></th>
			</tr>
		</thead>
		<tbody>
		<cfif get_pro_work.recordcount>
			<cfoutput query="GET_PRO_WORK" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#"> 
				<tr>
					<td>#currentrow#</td>
					<td>
						<a href="#request.self#?fuseaction=project.works&event=det&id=#work_id#" target="_blank" >
							<cfif type eq 0>
								<b>(M) #URLDecode(work_head)#</b>
							<cfelse>
								<cfif len(milestone_work_id) and attributes.work_milestones neq 0>&nbsp;&nbsp;&nbsp;&nbsp;</cfif>
								#URLDecode(work_head)#
							</cfif>
						</a>
					</td>
					<td>#employee#</td>
					<cfif len(work_priority_id)>
						<td><font color="#COLOR#">#priority#</font></td>
					</cfif>                
					<cfif isdefined('target_finish') and len(target_finish)>
						<cfset fdate_plan=date_add("h",session.ep.time_zone,target_finish)>
					<cfelse>
						<cfset fdate_plan=''>
					</cfif>
					<cfif isdefined('target_start') and len(target_start)>
						<cfset sdate_plan=date_add("h",session.ep.time_zone,target_start)>
					<cfelse>
						<cfset sdate_plan = ''>
					</cfif>
					<td>
					<cfif isdefined('sdate_plan') and len(sdate_plan)>
						#dateformat(sdate_plan,dateformat_style)#<cfif attributes.xml_show_actual_date eq 1>,#timeformat(sdate_plan,timeformat_style)#</cfif>
					</cfif>
					<cfif isdefined('fdate_plan') and len(fdate_plan)>
						#dateformat(fdate_plan,dateformat_style)#<cfif attributes.xml_show_actual_date eq 1>,#timeformat(fdate_plan,timeformat_style)#</cfif></font>
					</cfif>
					</td>
					<cfif attributes.xml_show_actual_date eq 1>
						<cfif isdefined('REAL_FINISH') and len(REAL_FINISH)>
							<cfset fdate=date_add("h",session.ep.time_zone,REAL_FINISH)>
						<cfelse>
							<cfset fdate=''>
						</cfif>
						<cfif isdefined('REAL_START') and len(REAL_START)>
							<cfset sdate=date_add("h",session.ep.time_zone,REAL_START)>
						<cfelse>
							<cfset sdate = ''>
						</cfif>
						<td>
							<cfif isdefined('sdate') and len(sdate)>
								#dateformat(sdate,'dd/mm/yyyy')#,#timeformat(sdate,'HH:mm')#
							</cfif>
							<cfif isdefined('fdate') and len(fdate)>
								#dateformat(fdate,'dd/mm/yyyy')#,#timeformat(fdate,'HH:mm')#
							</cfif>
						</td>
					</cfif>
					<td>#stage#</td>
					<cfif attributes.xml_show_work_category eq 1>
						<td>#work_cat#</td>
					</cfif>
					<td>#activity_name#</td>
					<td>
						<cfif isdefined('estimated_time') and len(estimated_time)>
							<cfset liste=estimated_time/60>
							<cfset saat=listfirst(liste,'.')>
							<cfset dak=estimated_time-saat*60>
							#saat# saat #dak# dk
						</cfif>
					</td>
					<td>
						<cfif listfindnocase(work_h_list,work_id)>
							<cfset harcanan_ = get_harcanan_zaman.harcanan_dakika[listfind(work_h_list,work_id,',')]>
							<cfset liste=harcanan_/60>
							<cfset saat=listfirst(liste,'.')>
							<cfset dak=harcanan_-saat*60>
							#saat# saat #dak# dk
						<cfelse>
							0 saat 0 dk                    	
						</cfif>
					</td>
					<td>
					<!--- Yuzde --->
						<div id="complate_ratio_div#WORK_ID#" ></div>
						<div class="form-group"><input type="text" name="is_complate#work_id#" onkeyup="isNumber(this);" id="complate_ratio#WORK_ID#" class="moneybox" style="width:100%" maxlength="3" value="<cfif len(to_complete)>#to_complete#<cfelse>-</cfif>" <cfif attributes.xml_change_complate_ratio eq 1>onBlur="swaping(this.value,#WORK_ID#,is_complate#work_id#)"</cfif>></div>
					</td>
					<cfif not listfindnocase(denied_pages,'project.project_material') and isDefined("attributes.related_project_info")>
						<td><!--- Malzeme --->
							<cfif len(pro_material_id)>
								<a href='#request.self#?fuseaction=project.project_material&event=upd&upd_id=#pro_material_id#' target="_blank"> <img src="/images/list_ship.gif" border="0" title="<cf_get_lang dictionary_id ='38326.Malzeme'>"></a>
							<cfelse>
								<a href='#request.self#?fuseaction=project.project_material&event=add&project_id=#attributes.project_id#&work_id=#work_id#' target="_blank"> <img src="/images/list_ship.gif" border="0" title="<cf_get_lang dictionary_id ='38326.Malzeme'>"></a>
							</cfif>
						</td>
					</cfif>
					<cfif isdefined("attributes.ajax")>
					<td><!--- Kopyalama ---><a href="javascript://" onclick="copy_work(#work_id#);"><i class="fa fa-copy" title="<cf_get_lang dictionary_id ='57476.Kopyala'>"></i></a></td>
					</cfif>
					<cfif isdefined("attributes.project_id") and len(attributes.project_id)>
						<!---Güncelleme ekranı Planlanan zaman harcaması ekleyebilmek için eklendi--->
						<cfquery name="GET_HISTORY_CONTROL" datasource="#DSN#">
							SELECT
								PWH.HISTORY_ID,
								PWH.WORK_ID,
								TMP.HISTORY_ID 
							FROM
								PRO_WORKS_HISTORY PWH
								LEFT JOIN TIME_COST_PLANNED TMP ON PWH.HISTORY_ID = TMP.HISTORY_ID
							WHERE 
								PWH.WORK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#GET_PRO_WORK.work_id#">
						</cfquery>
						<td>
							<a href="javascript://" onclick="windowopen('#request.self#?fuseaction=project.popup_add_planned_actual_timecost&id=#GET_PRO_WORK.work_id#&history_id=#GET_HISTORY_CONTROL.HISTORY_ID#','wwide1');"><i class="fa fa-calendar-check-o" title="<cf_get_lang dictionary_id='60364.Planlanan Zaman Harcaması Ekle'>"></i></a>
						</td>
					</cfif>
					<td><!--- Ekleme---> 
						<cfif isdefined("x_is_related_tree_cat") and x_is_related_tree_cat eq 1>
							<a href="javascript://"  onclick="tree_gonder(3,'#work_id#');"><i class="fa af-plus" title="<cf_get_lang dictionary_id='521.İş Ekle'>"></i></a>
						<cfelse>
							<a onclick="openBoxDraggable('#request.self#?fuseaction=project.works&event=add<cfif isdefined("attributes.work_detail_id") and attributes.work_detail_id eq 0>&work_detail_id=0</cfif><cfif isDefined("attributes.project_id") and Len(attributes.project_id)>&id=#attributes.project_id#</cfif>&work_id=#work_id#&work_fuse=<cfif isdefined("url.work_fuse") and len(url.work_fuse)>#url.work_fuse#<cfelse>#attributes.fuseaction#</cfif><cfif isDefined("attributes.forum_reply_id")>&forum_reply_id=#attributes.forum_reply_id#</cfif><cfif isDefined("attributes.g_service_id")>&g_service_id=#attributes.g_service_id#<cfelseif isDefined("attributes.service_id")>&service_id=#attributes.service_id#<cfelseif isDefined("attributes.opp_id")>&opp_id=#attributes.opp_id#<cfelseif isDefined("attributes.product_sample_id")>&product_sample_id=#attributes.product_sample_id#</cfif>','','ui-draggable-box-large');"><i class="fa fa-plus" title="<cf_get_lang dictionary_id='57933.İş Ekle'>"></i></a>
						</cfif>
					</td>
					<cfif isdefined("attributes.service_id") and len(attributes.service_id)>
						<td>
							<input type="hidden" name="work_id#currentrow#" id="work_id#currentrow#" value="#GET_PRO_WORK.work_id#">
							<a href="javascript://" onclick="javascript:if (confirm('<cf_get_lang dictionary_id='33896.İş İlişkisini Silmek İstediğinizden Emin Misiniz?'>')) windowopen('#request.self#?fuseaction=project.emptypopup_del_work_relation&work_id=#GET_PRO_WORK.work_id#&service_id=#attributes.service_id#&type=1','small'); else return false;" >
							<i class="fa fa-minus" title="<cf_get_lang dictionary_id='57463.Sil'>"></i></a>
						</td>
					<cfelseif isdefined("attributes.assetp_id") and len(attributes.assetp_id)>
						<td>
							<input type="hidden" name="work_id#currentrow#" id="work_id#currentrow#" value="#GET_PRO_WORK.work_id#">
							<a href="javascript://" onclick="javascript:if (confirm('<cf_get_lang dictionary_id='33896.İş İlişkisini Silmek İstediğinizden Emin Misiniz?'>')) windowopen('#request.self#?fuseaction=project.emptypopup_del_work_relation&work_id=#GET_PRO_WORK.work_id#&assetp_id=#attributes.assetp_id#&type=2','small'); else return false;" >
							<i class="fa fa-minus" title="<cf_get_lang dictionary_id='57463.Sil'>"></i></a>
						</td> 
					<cfelseif  isdefined("attributes.g_service_id") and len(attributes.g_service_id)>
						<td>
							<input type="hidden" name="work_id#currentrow#" id="work_id#currentrow#" value="#GET_PRO_WORK.work_id#">
							<a href="javascript://" onclick="javascript:if (confirm('<cf_get_lang dictionary_id='33896.İş İlişkisini Silmek İstediğinizden Emin Misiniz?'>')) windowopen('#request.self#?fuseaction=project.emptypopup_del_work_relation&work_id=#GET_PRO_WORK.work_id#&g_service_id=#attributes.g_service_id#&type=3','small'); else return false;" >
							<i class="fa fa-minus" title="<cf_get_lang dictionary_id='57463.Sil'>"></i></a>
						</td>  
					<cfelseif isdefined("attributes.project_id") and len(attributes.project_id)>
						<td>
							<input type="hidden" name="work_id#currentrow#" id="work_id#currentrow#" value="#GET_PRO_WORK.work_id#">
							<a href="javascript://" onclick="javascript:if (confirm('<cf_get_lang dictionary_id='33896.İş İlişkisini Silmek İstediğinizden Emin Misiniz?'>')) windowopen('#request.self#?fuseaction=project.emptypopup_del_work_relation&work_id=#GET_PRO_WORK.work_id#&project_id=#attributes.project_id#&type=4','small'); else return false;" >
							<i class="fa fa-minus" title="<cf_get_lang dictionary_id='57463.Sil'>"></i></a>
						</td> 
					<cfelseif isdefined("attributes.opp_id") and len(attributes.opp_id)>
						<td>
							<input type="hidden" name="work_id#currentrow#" id="work_id#currentrow#" value="#GET_PRO_WORK.work_id#">
							<a href="javascript://" onclick="javascript:if (confirm('<cf_get_lang dictionary_id='33896.İş İlişkisini Silmek İstediğinizden Emin Misiniz?'>')) openBoxDraggable('#request.self#?fuseaction=project.emptypopup_del_work_relation&work_id=#GET_PRO_WORK.work_id#&opp_id=#attributes.opp_id#&type=5'); else return false;" >
							<i class="fa fa-minus" title="<cf_get_lang dictionary_id='57463.Sil'>"></i></a>
						</td> 
					<cfelseif isdefined("attributes.product_sample_id") and len(attributes.product_sample_id)>
						<td>
							<input type="hidden" name="work_id#currentrow#" id="work_id#currentrow#" value="#GET_PRO_WORK.work_id#">
							<a href="javascript://" onclick="javascript:if (confirm('<cf_get_lang dictionary_id='33896.İş İlişkisini Silmek İstediğinizden Emin Misiniz?'>')) windowopen('#request.self#?fuseaction=project.emptypopup_del_work_relation&work_id=#GET_PRO_WORK.work_id#&product_sample_id=#attributes.product_sample_id#&type=5','small'); else return false;" >
							<i class="fa fa-minus" title="<cf_get_lang dictionary_id='57463.Sil'>"></i></a>
						</td>                                                         
					<cfelseif isdefined("attributes.subscription_id") and len(attributes.subscription_id)>
						<td>
							<input type="hidden" name="work_id#currentrow#" id="work_id#currentrow#" value="#GET_PRO_WORK.work_id#">
							<a href="javascript://" onclick="javascript:if (confirm('<cf_get_lang dictionary_id='33896.İş İlişkisini Silmek İstediğinizden Emin Misiniz?'>')) windowopen('#request.self#?fuseaction=project.emptypopup_del_work_relation&work_id=#GET_PRO_WORK.work_id#&subscription_id=#attributes.subscription_id#&type=6','small'); else return false;" >
							<i class="fa fa-minus" title="<cf_get_lang dictionary_id='57463.Sil'>"></i></a>
						</td>                     
					</cfif>
				</tr>
			</cfoutput>
		<cfelse>
			<tr>
				<td colspan="17"><cf_get_lang dictionary_id='57484.Kayıt Yok'> !</td>
			</tr>
		</cfif>
		</tbody>
	</cf_grid_list>
	<cfif attributes.totalrecords gt attributes.maxrows> 
		<cfset adres = "">
		<cfset x_id="">
		<cfif isdefined("attributes.id") and len(attributes.id)>
			<cfset adres = "#adres#&id=#attributes.id#">
		</cfif>
		<cfif isdefined("attributes.service_id") and len(attributes.service_id)>
			<cfset adres = "#adres#&service_id=#attributes.service_id#">
			<cfset x_id=attributes.service_id>
		</cfif>
		<cfif isdefined("attributes.project_id") and len(attributes.project_id)>
			<cfset adres = "#adres#&project_id=#attributes.project_id#">
			<cfset x_id=attributes.project_id>
		</cfif>
		<cfif isdefined('attributes.is_submitted')>
			<cfset adres = "#adres#&is_submitted=1">
		</cfif>
		<cfif len(attributes.keywords)>
			<cfset adres = "#adres#&keywords=#attributes.keywords#"> 
		</cfif>
		<cfif len(attributes.currency)>
			<cfset adres = "#adres#&currency=#attributes.currency#"> 
		</cfif>
		<cfif len(attributes.priority_cat_)>
			<cfset adres = "#adres#&priority_cat_=#attributes.priority_cat_#">
		</cfif>
		<cfif len(attributes.activity_id)>
			<cfset adres = "#adres#&activity_id=#attributes.activity_id#">
		</cfif>
		<cfif len(attributes.startrow)>
			<cfset adres = "#adres#&startrow=#attributes.startrow#">
		</cfif>
		<cfif len(attributes.maxrows)>
			<cfset adres = "#adres#&maxrows=#attributes.maxrows#">
		</cfif>
		<cfif isdefined('attributes.ordertype') and len(attributes.ordertype)>
			<cfset adres = "#adres#&ordertype=#attributes.ordertype#">
		</cfif>
		<cfif len(attributes.work_status)>
			<cfset adres = "#adres#&work_status=#attributes.work_status#">
		</cfif>
		<cfif isdefined("attributes.process_stage") and len(attributes.process_stage)>
			<cfset adres = "#adres#&process_stage=#attributes.process_stage#">
		</cfif>
		<cfif isdefined("attributes.status") and len(attributes.status)>
			<cfset adres = "#adres#&status=#attributes.status#">
		</cfif>
		<cfif isdefined("attributes.work_milestones") and len(attributes.work_milestones)>
			<cfset adres = "#adres#&work_milestones=#attributes.work_milestones#">
		</cfif>
		<cfif isdefined("attributes.xml_work_sort_type") and len(attributes.xml_work_sort_type)>
			<cfset adres = "#adres#&xml_work_sort_type=#attributes.xml_work_sort_type#">
		</cfif>
		<cfif isdefined("attributes.work_cat") and len(attributes.work_cat)>
			<cfset adres = "#adres#&work_cat=#attributes.work_cat#">
		</cfif>
		<cf_paging page="#attributes.page#" 
			maxrows="#attributes.maxrows#"
			totalrecords="#get_pro_work.recordcount#"
			startrow="#attributes.startrow#"
			isAjax=true
			target="project_works_div_#x_id#"
			adres="project.emptypopup_ajax_project_works#adres#">
	</cfif> 
	</div>
	<script type="text/javascript">
		function get_work_currency()
		{
			var currency_len = document.getElementById("currency").options.length;
			for(kk=currency_len;kk>=0;kk--)
				document.getElementById("currency").options[kk] = null;	
			document.getElementById("currency").options[0] = new Option('<cf_get_lang dictionary_id="57482.Asama">','');
			if(document.getElementById("work_cat").value != '')
			{
				var get_work_stage=wrk_safe_query('get_pro_works_currency','dsn',0,document.getElementById("work_cat").value);
					
				for(var jj=0;jj < get_work_stage.recordcount;jj++)
					document.getElementById("currency").options[jj+1]=new Option(get_work_stage.STAGE[jj],get_work_stage.PROCESS_ROW_ID[jj]);
			}
		}
		function copy_work(work_id)
		{
			if(confirm("<cf_get_lang dictionary_id='60614.İş kopyalanacaktır'>. <cf_get_lang dictionary_id='48488.Emin misiniz'>?"))
			{
				div_id ='project_works_div_<cfoutput>#this_div_id_#</cfoutput>'
				var send_address = '<cfoutput>#request.self#?fuseaction=project.emptypopup_copy_work<cfif isDefined("attributes.related_project_info")>&related_project_info=1</cfif><cfif isdefined("attributes.project_id")>&project_id=#attributes.project_id#</cfif><cfif isdefined("attributes.opp_id")>&opp_id=#attributes.opp_id#</cfif><cfif isdefined("attributes.product_sample_id")>&product_sample_id=#attributes.product_sample_id#</cfif><cfif isdefined("attributes.service_id")>&service_id=#attributes.service_id#</cfif><cfif isdefined("attributes.g_service_id")>&g_service_id=#attributes.g_service_id#</cfif><cfif isdefined("attributes.assetp_id")>&assetp_id=#attributes.assetp_id#</cfif><cfif isdefined("attributes.subscription_id")>&subscription_id=#attributes.subscription_id#</cfif>&work_id=</cfoutput>'+ work_id;
				AjaxPageLoad(send_address,div_id,1);
				return false;
			}
		}		
		function swaping(deger,work_id)
		{
			if (deger <= 100)
			{
				div_id = 'complate_ratio_div'+work_id;
				if(document.getElementById('complate_ratio'+work_id) != undefined && document.getElementById('complate_ratio'+work_id).value.lenght != '')
				{	
					var send_address = '<cfoutput>#request.self#</cfoutput>?fuseaction=project.emptypopup_ajax_work_ratio&work_id='+ work_id +'&deger='+deger;
					AjaxPageLoad(send_address,div_id,1);
				}
			}
			else if (deger > 100)
			{
				alert("<cf_get_lang dictionary_id ='38338.Tamamlanma Orani 100 den kucük bir rakam olmalidir'>");
				return false;
			}
		}
		function loader_page2(_x_)
		{    
			adress_ = '<cfoutput>#request.self#</cfoutput>?fuseaction=project.emptypopup_ajax_project_works'+_x_+'&currency='+document.getElementById('currency').value+'&xml_work_sort_type='+document.getElementById('xml_work_sort_type').value+'&keywords='+document.getElementById('keywords').value+'&priority_cat_='+document.getElementById('priority_cat_').value+'&activity_id='+document.getElementById('activity_id').value+'&workgroup_id='+document.getElementById('workgroup_id').value+'<cfif attributes.xml_show_work_category eq 1>&work_cat='+document.getElementById('work_cat').value+'</cfif>&ordertype='+document.getElementById('ordertype').value+'&work_status='+document.getElementById('work_status').value+'&xml_show_actual_date=<cfoutput>#attributes.xml_show_actual_date#</cfoutput>&work_milestones='+document.getElementById('work_milestones').value+'&maxrows='+document.getElementById('maxrows').value+'&xml_show_work_category='+document.getElementById('xml_show_work_category').value+'&xml_is_stage_cat='+document.getElementById('xml_is_stage_cat').value+'&xml_is_stage_work_cat='+document.getElementById('xml_is_stage_work_cat').value+'&xml_change_complate_ratio='+document.getElementById('xml_change_complate_ratio').value;

			AjaxPageLoad(adress_,'project_works_div_<cfoutput>#this_div_id_#</cfoutput>',1);
			return false;
		}
		function loader_page()
		{
			document.getElementById('project_submit_button').click();
		}
	</script>
	<cf_get_lang_set module_name="#lcase(listgetat(attributes.fuseaction,1,'.'))#"><!--- sayfanin en ustunde acilisi var --->
</cfif>