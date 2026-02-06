<cf_xml_page_edit fuseact="sales.list_visit">
<cfparam name="attributes.start_date" default="#dateformat(now(),dateformat_style)#">
<cfparam name="attributes.employee_name" default='#session.ep.name# #session.ep.surname#'>
<cfparam name="attributes.finish_date" default="#dateformat(date_add('d',7,now()),dateformat_style)#">
<cfparam name="attributes.is_active" default='1'>
<cfparam name="attributes.zone_director" default="">
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.search_project_id" default="">
<cfparam name="attributes.project_name" default="">
<cfparam name="attributes.search_emp_id" default='#session.ep.userid#'>
<cfif len(attributes.start_date)><cf_date tarih='attributes.start_date'></cfif>
<cfif len(attributes.finish_date)><cf_date tarih='attributes.finish_date'></cfif>
<cfquery name="GET_BRANCH" datasource="#dsn#">
	SELECT DISTINCT
		B.BRANCH_NAME,
		B.BRANCH_ID
	FROM
		BRANCH B,
		EMPLOYEE_POSITION_BRANCHES EPB
	WHERE
		B.BRANCH_ID = EPB.BRANCH_ID AND
		EPB.POSITION_CODE = #session.ep.position_code#
	ORDER BY
		B.BRANCH_NAME
</cfquery>
<cfquery name="FIND_DEPARTMENT_BRANCH" datasource="#DSN#">
	SELECT
		EMPLOYEE_POSITIONS.EMPLOYEE_ID,
		EMPLOYEE_POSITIONS.POSITION_ID,
		EMPLOYEE_POSITIONS.POSITION_CODE,
		BRANCH.BRANCH_ID,
		BRANCH.BRANCH_NAME,
		DEPARTMENT.DEPARTMENT_ID,
		DEPARTMENT.DEPARTMENT_HEAD
	FROM
		EMPLOYEE_POSITIONS,
		DEPARTMENT,
		BRANCH
	WHERE
		EMPLOYEE_POSITIONS.DEPARTMENT_ID = DEPARTMENT.DEPARTMENT_ID
		AND DEPARTMENT.BRANCH_ID = BRANCH.BRANCH_ID
		AND EMPLOYEE_POSITIONS.POSITION_CODE = #session.ep.position_code#
</cfquery>
<cfif isdefined("attributes.is_submitted")>
	<cfif x_control_ims eq 1 and session.ep.our_company_info.sales_zone_followup eq 1>
		<cfinclude template="../../member/query/get_ims_control.cfm">
	</cfif>
	<cfquery name="GET_EVENT_PLAN" datasource="#dsn#">
		SELECT
        	EVENT_PLAN.EVENT_PLAN_ID,
          	EVENT_PLAN.MAIN_START_DATE,
			EVENT_PLAN.MAIN_FINISH_DATE,
            EVENT_PLAN.SALES_ZONES,
			EVENT_PLAN.EVENT_PLAN_HEAD,
			EVENT_PLAN.EVENT_PLAN_ID,
			EVENT_PLAN.EVENT_STATUS,
			EVENT_PLAN.RECORD_EMP,
			EVENT_PLAN.ANALYSE_ID,
			EVENT_PLAN.CAMPAIGN_ID,
			EVENT_PLAN.SALES_ZONES_ID,
			EVENT_PLAN.EST_LIMIT,
			EVENT_PLAN.IMS_CODE_ID,
			PROCESS_TYPE_ROWS.STAGE,
			EVENT_PLAN.MONEY_CURRENCY,
			EVENT_PLAN.IS_WIEW_DEPARTMENT,
			EVENT_PLAN.IS_WIEW_BRANCH,
			EVENT_PLAN.VIEW_TO_ALL
		FROM
			EVENT_PLAN,
			PROCESS_TYPE_ROWS
		WHERE
			EVENT_PLAN.IS_SALES = 1 AND
			PROCESS_TYPE_ROWS.PROCESS_ROW_ID = EVENT_PLAN.EVENT_STATUS 
			<cfif len(attributes.keyword)>AND EVENT_PLAN.EVENT_PLAN_HEAD LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.keyword#%"> COLLATE SQL_Latin1_General_CP1_CI_AI</cfif>
			<cfif len(attributes.employee_name) and len(attributes.search_emp_id)>AND EVENT_PLAN.RECORD_EMP = #attributes.search_emp_id#</cfif>
			<cfif len(attributes.zone_director)>AND EVENT_PLAN.SALES_ZONES = #attributes.zone_director#</cfif>
            <cfif len(attributes.search_project_id) and len(attributes.project_name) and is_project eq 1>
              AND EVENT_PLAN.EVENT_PLAN_ID IN 
              (SELECT EVENT_PLAN_ID FROM EVENT_PLAN_ROW WHERE EVENT_PLAN_ROW.EVENT_PLAN_ID=EVENT_PLAN.EVENT_PLAN_ID AND PROJECT_ID=#attributes.search_project_id#) 	
			</cfif>
			<cfif len(attributes.start_date)>AND EVENT_PLAN.MAIN_START_DATE >= #attributes.start_date#</cfif>
			<cfif len(attributes.finish_date)>AND EVENT_PLAN.MAIN_FINISH_DATE <= #attributes.finish_date#</cfif>
			<cfif len(attributes.is_active)>AND EVENT_PLAN.IS_ACTIVE = #attributes.is_active#</cfif>
			<cfif x_control_ims eq 1 and session.ep.our_company_info.sales_zone_followup eq 1>
				AND
					(
						(EVENT_PLAN.EVENT_PLAN_ID IN(SELECT EEP.EVENT_PLAN_ID FROM EVENT_PLAN_ROW EEP WHERE EEP.COMPANY_ID IN (#PreserveSingleQuotes(my_ims_comp_list)#))) OR
						(EVENT_PLAN.EVENT_PLAN_ID IN(SELECT EEP.EVENT_PLAN_ID FROM EVENT_PLAN_ROW EEP WHERE EEP.CONSUMER_ID IN (#PreserveSingleQuotes(my_ims_cons_list)#)))
					)	
			</cfif> 
			AND	
			(
				(
					(	
						EVENT_PLAN.IS_WIEW_BRANCH IS NOT NULL AND
						EVENT_PLAN.IS_WIEW_DEPARTMENT IS NOT NULL AND
						EVENT_PLAN.VIEW_TO_ALL IS NOT NULL AND
						EVENT_PLAN.IS_WIEW_DEPARTMENT = #find_department_branch.department_id#
					)
					OR
					(
						EVENT_PLAN.IS_WIEW_BRANCH IS NOT NULL AND
						EVENT_PLAN.IS_WIEW_DEPARTMENT IS NULL AND
						EVENT_PLAN.VIEW_TO_ALL IS NOT NULL AND
						EVENT_PLAN.IS_WIEW_BRANCH = #find_department_branch.branch_id#
					)
					OR
					(
						EVENT_PLAN.IS_WIEW_BRANCH IS NULL AND
						EVENT_PLAN.IS_WIEW_DEPARTMENT IS NULL AND
						EVENT_PLAN.VIEW_TO_ALL IS NOT NULL
					)
				)
				<cfif Get_Branch.RecordCount>
				OR
				(
					EVENT_PLAN.IS_WIEW_BRANCH IS NULL AND
					EVENT_PLAN.IS_WIEW_DEPARTMENT IS NULL AND
					EVENT_PLAN.VIEW_TO_ALL IS NULL AND
					EVENT_PLAN.SALES_ZONES  IN (#ListDeleteDuplicates(ValueList(Get_Branch.Branch_Id,','))#)
				)
				</cfif>
			)
		ORDER BY
			EVENT_PLAN.MAIN_START_DATE DESC
     </cfquery>
<cfelse> 
	<cfset get_event_plan.recordcount = 0>
</cfif> 
<cfparam name='attributes.totalrecords' default='#get_event_plan.recordcount#'>
<cfparam name="attributes.page" default=1>
<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box>
		<cfform name="search_asset" action="#request.self#?fuseaction=sales.list_visit" method="post">
			<input type="hidden" name="is_submitted" id="is_submitted" value="1">
			<cf_box_search>
				<div class="form-group">
					<cfinput type="text" name="keyword" id="keyword" placeholder="#getLang(48,'Filtre',57460)#" style="width:100px;" value="#attributes.keyword#" maxlength="50">
				</div>
				<div class="form-group">
					<div class="input-group">
						<cfsavecontent variable="message"><cf_get_lang dictionary_id="58503.Lütfen Tarih Giriniz">!</cfsavecontent>
						<cfinput type="text" name="start_date" id="start_date" value="#dateformat(attributes.start_date,dateformat_style)#" maxlength="10" validate="#validate_style#" message="#message#" style="width:65px;">               		 
						<span class="input-group-addon"><cf_wrk_date_image date_field="start_date"></span>
					</div>
				</div>
				<div class="form-group">
					<div class="input-group">
						<cfinput type="text" name="finish_date" id="finish_date" value="#dateformat(attributes.finish_date,dateformat_style)#" maxlength="10" validate="#validate_style#" message="#message#" style="width:65px;">
						<span class="input-group-addon"><cf_wrk_date_image date_field="finish_date"></span>
					</div>
				</div>
				<div class="form-group">
					<select name="is_active" id="is_active">
						<option value="0" <cfif attributes.is_active eq 0>selected</cfif>><cf_get_lang dictionary_id='57494.pasif'></option>
						<option value="1" <cfif attributes.is_active eq 1>selected</cfif>><cf_get_lang dictionary_id='57493.aktif'></option>
						<option value="" <cfif attributes.is_active eq "">selected</cfif>><cf_get_lang dictionary_id='57708.Tümü'></option>
					</select>
				</div>
				<div class="form-group small">
					<cfsavecontent variable="message"><cf_get_lang dictionary_id='57537.Sayi_Hatasi_Mesaj'></cfsavecontent>
					<cfinput type="text" name="maxrows" id="maxrows" value="#attributes.maxrows#" required="yes" onKeyUp="isNumber(this)" validate="integer" range="1,999" message="#message#" maxlength="3" style="width:25px;">
				</div>
				<div class="form-group">
					<cf_wrk_search_button button_type="4" search_function="kontrol()">
					<cf_workcube_file_action pdf='1' mail='1' doc='1' print='1'>
				</div>
			</cf_box_search>
			<cf_box_search_detail>
				<div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
					<cfif is_project eq 1>
						<div class="form-group" id="item-">
							<label class="col col-12"><cf_get_lang dictionary_id ='57416.Proje'></label>
							<div class="col col-12">
								<div class="input-group">
									<input type="hidden" name="search_project_id" id="search_project_id" value="<cfif len(attributes.search_project_id)><cfoutput>#attributes.search_project_id#</cfoutput></cfif>">
									<input name="project_name" type="text" id="project_name" style="width:110px;"  value="<cfif len(attributes.search_project_id) and len(attributes.project_name)><cfoutput>#attributes.project_name#</cfoutput></cfif>" autocomplete="off">
									<span class="input-group-addon icon-ellipsis btnPointer"  onClick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_list_projects&project_head=search_asset.project_name&project_id=search_asset.search_project_id</cfoutput>');"></span>
								</div>
							</div>
						</div>
					</cfif>
				</div>
				<div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="2" sort="true">
					<div class="form-group" id="item-">
						<label class="col col-12"><cf_get_lang dictionary_id ='41213.Planlayan'></label>
						<div class="col col-12"> 
							<div class="input-group">
								<input type="hidden" name="search_emp_id" id="search_emp_id" value="<cfif len(attributes.search_emp_id) and len(attributes.employee_name)><cfoutput>#attributes.search_emp_id#</cfoutput></cfif>">
								<input name="employee_name" type="text" id="employee_name" style="width:110px;" onFocus="AutoComplete_Create('employee_name','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','3','EMPLOYEE_ID','search_emp_id','','3','125');" value="<cfif len(attributes.employee_name)><cfoutput>#attributes.employee_name#</cfoutput></cfif>" autocomplete="off">
								<span class="input-group-addon icon-ellipsis btnPointer" onClick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_positions&field_emp_id=search_asset.search_emp_id&field_name=search_asset.employee_name&select_list=1&keyword='+encodeURIComponent(document.search_asset.employee_name.value));"></span>
							</div>
						</div>
					</div>
				</div>
				<div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="3" sort="true">
					<div class="form-group" id="item-">
						<label class="col col-12"><cf_get_lang dictionary_id ='51554.Yetkili Şubeler'></label>
						<div class="col col-12"> 
							<!---<select name="zone_director" id="zone_director" style="width:150px;">
								<option value=""><cfoutput>#getLang('main',322)#</cfoutput></option>
								<cfoutput query="get_branch">
									<option value="#branch_id#" <cfif attributes.zone_director eq branch_id>selected</cfif>>#branch_name#</option>
								</cfoutput>
							</select>--->
							<cf_wrkdepartmentbranch fieldid='zone_director' is_branch='1' width='135' is_default='1' is_deny_control='1' selected_value='#attributes.zone_director#'>
						</div>
					</div>
				</div>
			</cf_box_search_detail>
		</cfform>
	</cf_box>
	<cf_box title="#getLang(558,'Ziyaretler',57970)#" uidrop="1" hide_table_column="1">
		<cf_grid_list>
			<thead>
				<tr>
					<th width="35"><cf_get_lang dictionary_id='58577.Sıra'></th>
					<th><cf_get_lang dictionary_id ='41214.Plan'></th>
					<th><cf_get_lang dictionary_id ='41215.Ziyaret Sayısı'></th>
					<th><cf_get_lang dictionary_id ='57742.Tarih'></th> 
					<th><cf_get_lang dictionary_id='57453.Şube'></th>
					<th><cf_get_lang dictionary_id ='41213.Planlayan'></th>
					<th><cf_get_lang dictionary_id ='40943.Analiz Formu'></th>
					<th width="20" class="header_icn_none"><a href="<cfoutput>#request.self#</cfoutput>?fuseaction=sales.list_visit&event=add"><i class="fa fa-plus" title="<cf_get_lang dictionary_id='57582.Ekle'>" alt="<cf_get_lang dictionary_id='57582.Ekle'>"></i></a></th>
				</tr>
			</thead>
			<tbody>
				<cfif get_event_plan.recordcount>
					<cfoutput query="get_event_plan" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
					<tr>
						<td>#currentrow#</td>
						<td><a href="#request.self#?fuseaction=sales.list_visit&event=upd&visit_id=#event_plan_id#" class="tableyazi">#event_plan_head#</a></td>
						<td>
							<cfquery name="GET_COUNT" datasource="#dsn#">
								SELECT EVENT_PLAN_ROW_ID FROM EVENT_PLAN_ROW WHERE EVENT_PLAN_ID = #event_plan_id#
							</cfquery>
							#get_count.recordcount#
					</td>
						<td>#dateformat(main_start_date,dateformat_style)# - #dateformat(main_finish_date,dateformat_style)#</td>
						<td>
							<cfif len(sales_zones)>
								<cfquery name="GET_BRANCH_ZONE" datasource="#dsn#">
									SELECT BRANCH_NAME FROM BRANCH WHERE BRANCH_ID = #sales_zones#
								</cfquery>
								#get_branch_zone.branch_name#
						</cfif>
						</td>
						<td>#get_emp_info(RECORD_EMP,0,1)#</td>
						<td><cfif len(analyse_id)>
								<cfquery name="GET_ANALYSE" datasource="#dsn#">
									SELECT ANALYSIS_HEAD FROM MEMBER_ANALYSIS WHERE ANALYSIS_ID = #analyse_id# 
								</cfquery>
								<a href="#request.self#?fuseaction=member.analysis&analysis_id=#analyse_id#" class="tableyazi">#get_analyse.analysis_head#</a>
							</cfif>
						</td>
						<td width="15"><a href="#request.self#?fuseaction=sales.list_visit&event=upd&visit_id=#event_plan_id#"><i class="fa fa-pencil" title="<cf_get_lang dictionary_id='57464.Güncelle'>" alt="<cf_get_lang dictionary_id='57464.Güncelle'>"></i></a></td>
					</tr>
					</cfoutput>
				<cfelse>
					<tr>
						<td colspan="8"><cfif isdefined("attributes.is_submitted")><cf_get_lang dictionary_id='57484.Kayıt Bulunamadı'> !<cfelse><cf_get_lang dictionary_id='57701.Filtre Ediniz '> !</cfif></td>
					</tr>
				</cfif>
			</tbody>
		</cf_grid_list>
		<cfif attributes.totalrecords gt attributes.maxrows>
			<cfset url_str = "">
			<cfif len(attributes.start_date)>
				<cfset url_str = "#url_str#&start_date=#dateformat(attributes.start_date,dateformat_style)#">
			</cfif>
			<cfif len(attributes.finish_date)>
				<cfset url_str = "#url_str#&finish_date=#dateformat(attributes.finish_date,dateformat_style)#">
			</cfif>
			<cfif len(attributes.keyword)>
				<cfset url_str = "#url_str#&keyword=#attributes.keyword#">
			</cfif>
			<cfset url_str="#url_str#&search_project_id=#attributes.search_project_id#">
			<cfset url_str="#url_str#&project_name=#attributes.project_name#">
			<cfset url_str = "#url_str#&search_emp_id=#attributes.search_emp_id#">
			<cfset url_str = "#url_str#&employee_name=#attributes.employee_name#">
			<cfif len(attributes.zone_director)>
				<cfset url_str = "#url_str#&zone_director=#attributes.zone_director#">
			</cfif>
			<cfif len(attributes.is_active)>
				<cfset url_str = "#url_str#&is_active=#attributes.is_active#">
			</cfif>
			<cf_paging
				page="#attributes.page#"
				maxrows="#attributes.maxrows#"
				totalrecords="#attributes.totalrecords#"
				startrow="#attributes.startrow#"
				adres="sales.list_visit#url_str#&is_submitted=#attributes.is_submitted#">
		</cfif>
	</cf_box>
</div>
<script type="text/javascript">
	document.getElementById('keyword').focus();
	function kontrol()
		{
			if( !date_check(document.getElementById('start_date'),document.getElementById('finish_date'), "<cfoutput>#getLang('','Başlangıç Tarihi Bitiş Tarihinden Büyük Olamaz','58862')#</cfoutput>!") )
				return false;
			else
				return true;
		}
</script>  
