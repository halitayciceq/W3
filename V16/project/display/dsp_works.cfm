<cf_xml_page_edit>
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.process_stage_work" default="">
<cfparam name="attributes.priority_cat" default="">
<cfparam name="attributes.work_cat" default="">
<cfparam name="attributes.comp_name" default="">
<cfparam name="attributes.comp_id" default="">
<cfparam name="attributes.startdate" default="">
<cfparam name="attributes.finishdate" default="">
<cfparam name="attributes.work_status" default="1">
<cfparam name="attributes.project_id" default="">
<cfparam name="attributes.recorder_id" default="">
<cfparam name="attributes.recorder_name" default="">
<cfparam name="attributes.upd_by_id" default="">
<cfparam name="attributes.upd_by_name" default="">
<cfparam name="attributes.task_company_id" default="">
<cfparam name="attributes.outsrc_partner_id" default="">
<cfparam name="attributes.workgroup_id" default="">
<cfparam name="attributes.cc_emp_id" default="">
<cfparam name="attributes.cc_par_id" default="">
<cfparam name="attributes.cc_name" default="">
<cfparam name="attributes.show_milestone" default="1">
<cfparam name="attributes.special_definition" default="">
<cfparam name="attributes.to_complete" default="">
<cfparam name="attributes.activity_id" default="">
<cfparam name="attributes.box_submitted" default="" />
<cfparam name="attributes.work_emp_cc"  default="1"/>
<cfparam name="attributes.pro_emp_name" default="">
<cfparam name="attributes.pro_emp_id" default="">
<cfparam name="attributes.branch_id" default="">
<cfparam name="attributes.department" default="">
<cfparam name="attributes.activity_id" default="">
<cfparam name="attributes.project_emp_id" default="#session.ep.userid#">
<cfparam name="attributes.emp_name" default="#get_emp_info(session.ep.userid,0,0)#">
<cfparam name="attributes.expense_code" default="">
<cfparam name="attributes.expense_code_name" default="">
<cfparam name="attributes.contract_id" default="">
<cfparam name="attributes.contract_no" default="">
<cfparam name="attributes.record_id" default="">
<cfparam name="attributes.record_name" default="">
<cfparam name="attributes.ordertype" default="#xml_work_sort_type#">

<cfif session.ep.our_company_info.workcube_sector is 'tersane'>
	<cfparam name="attributes.pbs_id" default="">
	<cfparam name="attributes.pbs_code" default="">
</cfif>
<cfif len(attributes.startdate)><cf_date tarih="attributes.startdate"></cfif>
<cfif len(attributes.finishdate)><cf_date tarih="attributes.finishdate"></cfif>

<cfset cmp_process = createObject('component','V16.workdata.get_process')>
<cfset getComponent = createObject('component','V16.project.cfc.get_work')>
<cfset get_projects = getComponent.get_projects()>

<cfset GET_WORKGROUPS = getComponent.GET_WORKGROUPS()>
<cfset GET_ACTIVITY = getComponent.GET_ACTIVITY()>
<cfset GET_SPECIAL_DEFINITION = getComponent.GET_SPECIAL_DEFINITION()>
<cfset get_cats = getComponent.get_cats()>

<cfscript>
	cmp_branch = createObject("component","V16.hr.cfc.get_branch_comp");
	get_branches = cmp_branch.get_branch(ehesap_control:1,branch_status:1);
	if (isdefined('attributes.branch_id') and isnumeric(attributes.branch_id))
	{
		cmp_department = createObject("component","V16.hr.cfc.get_departments");
		cmp_department.dsn = dsn;
		get_departmant = cmp_department.get_department(branch_id:attributes.branch_id);
	}
</cfscript>

<cfif isdefined("attributes.is_form_submitted") and len(attributes.is_form_submitted)>
	<cfset get_works = getComponent.getWorks(workgroup_id: attributes.workgroup_id,
											xml_is_project_authority:xml_is_project_authority,
											recorder_name:attributes.recorder_name,
											keyword:attributes.keyword,
											work_cat : attributes.work_cat,
											work_status:attributes.work_status,
											pro_emp_id : attributes.pro_emp_id,
											priority_cat : attributes.priority_cat,
											comp_id:attributes.comp_id,
											comp_name : attributes.comp_name,
											outsrc_partner_id : attributes.outsrc_partner_id,
											currency : attributes.process_stage_work,
											startdate : attributes.startdate,
											finishdate : attributes.finishdate,
											project_id : attributes.project_id,
											upd_by_id : attributes.upd_by_id,
											upd_by_name: attributes.upd_by_name,
											expense_code : attributes.expense_code,
											expense_code_name : attributes.expense_code_name,
											branch_id: attributes.branch_id,
											contract_id : attributes.contract_id,
											contract_no:attributes.contract_no,
											work_emp_cc:attributes.work_emp_cc,
											cc_emp_id: attributes.cc_emp_id,
											cc_par_id : attributes.cc_par_id,
											cc_name : attributes.cc_name,
											to_complete : attributes.to_complete,
											activity_id: attributes.activity_id,
											department:attributes.department,
											special_definition : attributes.special_definition,
											show_milestone :attributes.show_milestone,
											project_emp_id:attributes.project_emp_id,
											emp_name:attributes.emp_name,
											pro_emp_name :attributes.pro_emp_name,
											maxrows : attributes.maxrows,
											record_id : attributes.record_id,
											record_name : attributes.record_name,
											ordertype : attributes.ordertype
	)>
<cfelse>
	<cfset get_works.recordcount=1>
</cfif>

<cfparam name="attributes.page" default=1>
<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>
<cfparam name="attributes.totalrecords" default="#get_works.recordcount#">
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box>
		<cfform name="list_works" action="#request.self#?fuseaction=project.works" method="post">
			<input type="hidden" name="is_form_submitted" id="is_form_submitted" value="1">
			<cf_box_search>
				<cfif isdefined('attributes.onfuseaction') and len(attributes.onfuseaction)>
					<input type="hidden" name="onfuseaction" id="onfuseaction" value="<cfoutput>#attributes.onfuseaction#</cfoutput>">
				</cfif>
				<cfif isdefined('attributes.onmodule') and len(attributes.onmodule)>
					<input type="hidden" name="onmodule" id="onmodule" value="<cfoutput>#attributes.onmodule#</cfoutput>">
				</cfif>
				<cfinclude template="../query/get_pro_work_cat.cfm">
				<div class="form-group">
					<cfsavecontent variable="message"><cf_get_lang dictionary_id='57460.Filtre'></cfsavecontent>
					<cfinput type="text" placeholder="#message#" name="keyword" id="keyword" value="#attributes.keyword#" >
				</div>
				<div class="form-group">
					<select name="work_cat" id="work_cat"  <cfif isdefined("xml_is_stage_cat") and xml_is_stage_cat eq 1>onChange="get_work_currency();"</cfif>>
						<option value=""><cf_get_lang dictionary_id='57486.kategori'></option>
						<cfoutput query="get_work_cat">
							<option value="#get_work_cat.work_cat_id#" <cfif attributes.work_cat eq get_work_cat.work_cat_id>selected</cfif>>#get_work_cat.work_cat#</option>
						</cfoutput>
					</select>
				</div>
				<div class="form-group">
					<cf_workcube_process is_upd='0' is_detail="0" is_select_text="1" select_name="process_stage_work">
				</div>
				<div class="form-group" >
					<select name="work_status" id="work_status" >
						<option value="1" <cfif attributes.work_status eq 1>selected</cfif>><cf_get_lang dictionary_id='57493.Aktif'></option>
						<option value="-1" <cfif attributes.work_status eq -1>selected</cfif>><cf_get_lang dictionary_id='57494.Pasif'></option>
						<option value="0" <cfif attributes.work_status eq 0>selected</cfif>><cf_get_lang dictionary_id='57708.Tümü'></option>
					</select>
				</div>
				<div class="form-group small">
					<cfsavecontent variable="message"><cf_get_lang dictionary_id='57537.Sayi_Hatasi_Mesaj'></cfsavecontent>
					<cfinput type="text" name="maxrows" onKeyUp="isNumber(this)" id="maxrows" value="#attributes.maxrows#" required="yes" validate="integer" range="1,999" message="#message#" maxlength="3" >
				</div>
				<div class="form-group">
					<cf_wrk_search_button search_function='' button_type="4">
					<!--- <cf_workcube_file_action pdf='1' mail='1' doc='1' print='1'> --->
				</div>
			</cf_box_search>
			<cf_box_search_detail>
				<div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
					<div class="form-group" id="item-emp_name">
						<label><cf_get_lang dictionary_id='57569.Görevli'></label>
							<div class="input-group">
								<cfif isdefined("xml_only_employee") and xml_only_employee eq 0>
								<cfinput type="hidden" name="outsrc_partner_id" id="outsrc_partner_id" value="#attributes.outsrc_partner_id#">
								</cfif>
								<cfinput type="hidden" name="project_emp_id" id="project_emp_id"  value="#attributes.project_emp_id#">
								<cfif isdefined("xml_only_employee") and xml_only_employee eq 1>
									<cfinput type="text" name="emp_name" id="emp_name" value="#attributes.emp_name#"  onblur="selectSec();" onFocus="AutoComplete_Create('emp_name','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','\'3\',0,0,0,2,1,0,0,1',',EMPLOYEE_ID','project_emp_id','list_works','3','250');" >	
								<cfelse>
									<cfinput type="text" name="emp_name" id="emp_name" value="#attributes.emp_name#"  onblur="selectSec();" onFocus="AutoComplete_Create('emp_name','MEMBER_NAME,MEMBER_PARTNER_NAME','MEMBER_PARTNER_NAME2,MEMBER_NAME2','get_member_autocomplete','\'1,3\',0,0,0','PARTNER_ID,EMPLOYEE_ID','outsrc_partner_id,project_emp_id','list_works','3','250');" >	
								</cfif>
								<span class="input-group-addon icon-ellipsis btnPointer" onclick="javascript:gonder2('list_works.emp_name');"></span>
							</div>
					</div>
					<div class="form-group" id="item-recorder_id" >
						<label><cf_get_lang dictionary_id='38274.Delege Eden'></label>
						<div class="input-group">
							<input type="hidden" name="recorder_id" id="recorder_id"  value='<cfoutput>#attributes.recorder_id#</cfoutput>'>
							<cfinput type="text" name="recorder_name" id="recorder_name"  value="#attributes.recorder_name#"  onFocus="AutoComplete_Create('recorder_name','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','3,0,0,0,2,1,0,0,1','EMPLOYEE_ID','recorder_id','list_works','3','135');" >
							<span class="input-group-addon icon-ellipsis btnPointer" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_positions&field_emp_id=list_works.recorder_id&field_name=list_works.recorder_name&select_list=1&is_form_submitted=1&keyword='+encodeURIComponent(document.list_works.recorder_name.value));"></span>
						</div>
					</div>
					<div class="form-group" id="item-startdate">
						<label><cf_get_lang dictionary_id='57655.Başlama Tarihi'></label>
						<div class="input-group">
							<cfsavecontent variable="message"><cf_get_lang dictionary_id='57738.baslama girmelisiniz'></cfsavecontent>
							<cfinput type="text" name="startdate" id="startdate"  value="#dateformat(attributes.startdate,dateformat_style)#" validate="#validate_style#" message="#message#" maxlength="10">
							<span class="input-group-addon"><cf_wrk_date_image date_field="startdate"></span>
						</div>
					</div>
					<div class="form-group" id="item-finishdate">
						<label><cf_get_lang dictionary_id='57700.Bitiş Tarihi'></label>
						<div class="input-group">
							<cfsavecontent variable="message"><cf_get_lang dictionary_id='57739.bitis girmelisiniz'></cfsavecontent>
							<cfinput type="text" name="finishdate" id="finishdate" value="#dateformat(attributes.finishdate,dateformat_style)#" validate="#validate_style#" message="#message#" maxlength="10">
							<span class="input-group-addon"><cf_wrk_date_image date_field="finishdate"></span>
						</div>
					</div>
					<div class="form-group" id="item-priority_cat">
						<label><cf_get_lang dictionary_id='57485.Öncelik'></label>
						<select name="priority_cat" id="priority_cat" >
							<option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
							<cfoutput query="get_cats">
								<option value="#priority_id#" <cfif attributes.priority_cat eq priority_id>selected</cfif>>#priority#</option>
							</cfoutput>
						</select>
					</div>
				</div>
				<div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="2" sort="true">
					<div class="form-group" id="item-project_id" >
						<label><cf_get_lang dictionary_id='57416.Proje'></label>
							<cf_multiselect_check
							option_text=#getLang('main','',57416,'Proje')#
							filter=1
							query_name="get_projects"
							name="project_id"
							option_value="PROJECT_ID"
							option_name="PROJECT_HEAD" value="#attributes.project_id#">
					</div>
					<div class="form-group" id="item-pro-leader">
						<label><cf_get_lang dictionary_id='33285.Proje Lideri'></label>
							<div class="input-group">
								<cfinput type="hidden" name="pro_emp_id" id="pro_emp_id"  value="#attributes.pro_emp_id#">
								<cfinput type="text" name="pro_emp_name" id="pro_emp_name" value="#attributes.pro_emp_name#"  onblur="selectSec();" onFocus="AutoComplete_Create('pro_emp_name','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','\'3\',0,0,0,2,1,0,0,1',',EMPLOYEE_ID','pro_emp_id','list_works','3','250');" >	
								<span class="input-group-addon icon-ellipsis btnPointer" onclick="javascript:gonder3('list_works.pro_emp_name','list_works.pro_emp_id');"></span>
							</div>
					</div>
					<div class="form-group" id="item-workgroup_id">
						<label><cf_get_lang dictionary_id='58140.İş Grubu'></label>
						<select name="workgroup_id" id="workgroup_id" >
							<option value=""><cf_get_lang dictionary_id='58140.İş Grubu'></option>
							<cfoutput query="get_workgroups">
								<option value="#get_workgroups.workgroup_id#"<cfif attributes.workgroup_id eq workgroup_id>selected</cfif>>#get_workgroups.workgroup_name#</option>
							</cfoutput>
						</select>
					</div>
					<div class="form-group" id="item-cc_name">
						<label>CC&nbsp;</label>
						<div class="input-group">
							<cfif Len(attributes.cc_name) and Len(attributes.cc_emp_id)>
							<cfset cc_name_ = get_emp_info(attributes.cc_emp_id,0,0)>
							<cfelseif Len(attributes.cc_name) and Len(attributes.cc_par_id)>
								<cfset cc_name_ = get_par_info(attributes.cc_par_id,0,0,0)>
							<cfelse>
								<cfset cc_name_ = "">
							</cfif>
							<cfoutput>
							<input type="hidden" name="cc_emp_id" id="cc_emp_id"  value="<cfif Len(attributes.cc_name) and Len(attributes.cc_emp_id)>#attributes.cc_emp_id#</cfif>">
							<input type="hidden" name="cc_par_id" id="cc_par_id"  value="<cfif Len(attributes.cc_name) and Len(attributes.cc_par_id)>#attributes.cc_par_id#</cfif>">
							</cfoutput>
							<cfinput type="text" name="cc_name" id="cc_name" value="#cc_name_#"   onFocus="AutoComplete_Create('cc_name','MEMBER_NAME,MEMBER_PARTNER_NAME','MEMBER_PARTNER_NAME2,MEMBER_NAME2','get_member_autocomplete','\'1,3\',0,0,0,2,1,0,0,1','PARTNER_ID,EMPLOYEE_ID','cc_par_id,cc_emp_id','list_works','3','250');" >
							<span class="input-group-addon icon-ellipsis btnPointer" onclick="javascript:gonder3('list_works.cc_name','list_works.cc_emp_id');"></span>
						</div>
					</div>
					<div class="form-group" id="item-upd_by_id">
						<label><cf_get_lang dictionary_id='57891.Güncelleyen'></label>
						<div class="input-group">
							<input type="hidden" name="upd_by_id" id="upd_by_id"  value='<cfoutput>#attributes.upd_by_id#</cfoutput>'>
							<cfinput type="text" name="upd_by_name" id="upd_by_name"  value="#attributes.upd_by_name#"  onFocus="AutoComplete_Create('upd_by_name','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','3,0,0,0,2,1,0,0,1','EMPLOYEE_ID','upd_by_id','list_works','3','135');" >
							<span class="input-group-addon icon-ellipsis btnPointer" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_positions&field_emp_id=list_works.upd_by_id&field_name=list_works.upd_by_name&select_list=1&is_form_submitted=1&keyword='+encodeURIComponent(document.list_works.upd_by_name.value));"></span>
						</div>
					</div>
				</div>
				<div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="3" sort="true">
					<div class="form-group" id="item-comp_id" >
						<label><cf_get_lang dictionary_id='57574.Şirket'></label>
						<div class="input-group">
							<input name="comp_id" id="comp_id" value='<cfoutput>#attributes.comp_id#</cfoutput>' type="hidden">
							<cfinput type="text" name="comp_name" id="comp_name"  value="#attributes.comp_name#"  onFocus="AutoComplete_Create('comp_name','MEMBER_NAME,MEMBER_PARTNER_NAME','MEMBER_NAME,MEMBER_PARTNER_NAME','get_member_autocomplete','\'1\',0,0,0','COMPANY_ID','comp_id','list_works','3','250',true);" >
							<span class="input-group-addon icon-ellipsis btnPointer" onclick="javascript:gonder('list_works.comp_name');"></span>
						</div>
					</div>
					<div class="form-group" id="item-branch_id">
						<label><cf_get_lang dictionary_id="57453.Şube"></label>
						<select name="branch_id" id="branch_id" onchange="showDepartment(this.value)" >
							<option value=""><cf_get_lang dictionary_id="57453.Şube"></option>
							<cfoutput query="get_branches" group="NICK_NAME">
								<optgroup label="#NICK_NAME#"></optgroup>
								<cfoutput>
									<option value="#BRANCH_ID#"<cfif isdefined("attributes.branch_id") and (attributes.branch_id eq branch_id)> selected</cfif>>&nbsp;&nbsp;&nbsp;#BRANCH_NAME#</option>
								</cfoutput>
							</cfoutput>
						</select>   
					</div>
					<div class="form-group" id="item-department">
						<label><cf_get_lang dictionary_id="57572.Departman"></label>
						<select name="department" id="department">
							<option value=""><cf_get_lang dictionary_id="57572.Departman"></option>
							<cfif isdefined('attributes.branch_id') and isnumeric(attributes.branch_id)>
								<cfoutput query="get_departmant">
									<option value="#department_id#"<cfif isdefined('attributes.department') and (attributes.department eq get_departmant.department_id)>selected</cfif>>#department_head#</option>
								</cfoutput>
							</cfif>
						</select>
					</div>
					<div class="form-group" id="item-to_complete" >
						<label><cf_get_lang dictionary_id='38174.Yüzde'> - <cf_get_lang dictionary_id='38125.Özel Tanım'></label>
						<div class="input-group">
							<select name="to_complete" id="to_complete" >
								<option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
								<cfoutput>
									<cfloop from="0" to="100" index="i" step="5">
										<option value="#i#" <cfif attributes.to_complete eq i>selected</cfif>>#i#</option>
									</cfloop>
								</cfoutput>
							</select>            
							<span class="input-group-addon no-bg"></span>
							<select name="special_definition" id="special_definition" >
								<option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
									<cfoutput query="GET_SPECIAL_DEFINITION">
										<option value="#special_definition_id#" <cfif attributes.special_definition eq special_definition_id>selected="selected"</cfif>>#special_definition#</option>
									</cfoutput>
							</select>          
						</div>
					</div>
					<div class="form-group" id="item-show_milestone">
						<label><cf_get_lang dictionary_id='57985.Üst'> <cf_get_lang dictionary_id='58020.İşler'></label>
						<select name="show_milestone" id="show_milestone" >
							<option value="1" <cfif attributes.show_milestone eq 1>selected</cfif>><cf_get_lang dictionary_id='30781.Üst İşler Dahil'></option>
							<option value="0" <cfif attributes.show_milestone eq 0>selected</cfif>><cf_get_lang dictionary_id='30784.Üst İşler Hariç'></option>
						</select>               
					</div>
				</div>
				<div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="4" sort="true">
					<div class="form-group" id="item-expense_code" >
						<label><cf_get_lang dictionary_id='58235.Masraf Merkezi'></label>
						<div class="input-group">
							<input type="hidden" name="expense_code" id="expense_code"  value="<cfif len(attributes.expense_code_name)><cfoutput>#attributes.expense_code#</cfoutput></cfif>">
							<input type="text" name="expense_code_name" id="expense_code_name"  value="<cfif len(attributes.expense_code_name)><cfoutput>#attributes.expense_code_name#</cfoutput></cfif>" onfocus="AutoComplete_Create('expense_code_name','EXPENSE,EXPENSE_CODE','EXPENSE,EXPENSE_CODE','get_expense_center','','EXPENSE_CODE','expense_code','','3','150');" >
							<span class="input-group-addon icon-ellipsis btnPointer" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_expense_center&field_id=list_works.expense_code&field_name=list_works.expense_code_name</cfoutput>');"></span>
						</div>
					</div>
					<div class="form-group" id="item-activity_id">
						<label><cf_get_lang dictionary_id='38378.Aktivite Tipi'></label>
						<select name="activity_id" id="activity_id" >
							<option value=""><cf_get_lang dictionary_id='38378.Aktivite Tipi'></option>
							<cfoutput query="get_activity">
								<option value="#activity_id#" <cfif attributes.activity_id eq activity_id>selected</cfif> >#activity_name#</option>
							</cfoutput>
						</select>      
					</div>
					<div class="form-group" id="item-ordertype">
						<label><cf_get_lang dictionary_id='58924.Sıralama'></label>
						<select name="ordertype" id="ordertype" >
							<option value="1" <cfif isdefined("attributes.ordertype") and attributes.ordertype eq 1>selected</cfif>><cf_get_lang dictionary_id ='38329.İş ID ye Göre Azalan'></option>                     
							<option value="2" <cfif isdefined("attributes.ordertype") and attributes.ordertype eq 2>selected</cfif>><cf_get_lang dictionary_id ='38328.Güncellemeye Göre Azalan'></option>
							<option value="3" <cfif isdefined("attributes.ordertype") and attributes.ordertype eq 3>selected</cfif>><cf_get_lang dictionary_id ='38330.Baslangiç Tarihine Gre Azalan'></option>
							<option value="4" <cfif isdefined("attributes.ordertype") and attributes.ordertype eq 4>selected</cfif>><cf_get_lang dictionary_id ='38331.Baslangiç Tarihine Gre Artan'></option>
							<option value="5" <cfif isdefined("attributes.ordertype") and attributes.ordertype eq 5>selected</cfif>><cf_get_lang dictionary_id ='38332.Bitis Tarihine Göre Azalan'></option>
							<option value="6" <cfif isdefined("attributes.ordertype") and attributes.ordertype eq 6>selected</cfif>><cf_get_lang dictionary_id ='38333.Bitis Tarihine Göre Artan'></option>
							<option value="7" <cfif isdefined("attributes.ordertype") and attributes.ordertype eq 7>selected</cfif>><cf_get_lang dictionary_id ='38270.İş Başlığına Göre Alfabetik'></option>
						</select>                
					</div>
					<div class="form-group" id="item-contract_id">
						<label><cf_get_lang dictionary_id='29522.Sözleşme'></label>
						<div class="input-group">
							<input type="hidden" name="contract_id" id="contract_id" value="<cfoutput>#attributes.contract_id#</cfoutput>"> 
							<input type="text" name="contract_no" id="contract_no" value="<cfoutput>#attributes.contract_no#</cfoutput>" >
							<span class="input-group-addon icon-ellipsis btnPointer" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_list_contract&field_id=list_works.contract_id&field_name=list_works.contract_no'</cfoutput>);"></span>
						</div>
					</div>
					<div class="form-group" id="item-emp-works">
						<label><cf_get_lang dictionary_id='57569.Görevli'> - <cf_get_lang dictionary_id='38184.İlişkili İşler'></label>
						<select name="work_emp_cc" id="work_emp_cc">
							<option value="0" <cfif attributes.work_emp_cc eq 0>selected</cfif>><cf_get_lang dictionary_id="57734.Seçiniz"></option>
							<option value="1" <cfif attributes.work_emp_cc eq 1>selected</cfif>><cf_get_lang dictionary_id='62869.Görevlisi Olduğum ve CC de Olduğum İşler'></option>
							<option value="2" <cfif attributes.work_emp_cc eq 2>selected</cfif>><cf_get_lang dictionary_id='62867.Görevli Olduğum İşler'></option>
							<option value="3" <cfif attributes.work_emp_cc eq 3>selected</cfif>><cf_get_lang dictionary_id='62868.CC de Geçtiğim işler'></option>
						</select>
					</div>
				</div>
			</cf_box_search_detail>
		</cfform>
	</cf_box>
	<cfform name="setProcessForm" id="setProcessForm" method="post" action="">
		<cfif not isDefined("attributes.wrkflow")>
			<input type="hidden" name="box_submitted" id="box_submitted" value="1">
		</cfif>
		<cfsavecontent variable="title"><cf_get_lang dictionary_id='58020.İşler'></cfsavecontent>
		<cf_box uidrop="1" hide_table_column="1" title="#title#">
			<cf_grid_list>
				<cfset colspan_info = 11>
				<thead>
					<tr>
						<th width="30"><cf_get_lang dictionary_id='58577.Sıra'></th>
						<th><cf_get_lang dictionary_id='38472.İş No'></th>
						<th><cf_get_lang dictionary_id='58527.ID'></th>
						<th><cf_get_lang dictionary_id='58020.isler'></th>
						<th><cf_get_lang dictionary_id='57416.proje'></th>
						<th><cf_get_lang dictionary_id='57574.sirket'>-<cf_get_lang dictionary_id='57569.görevli'></th>
						<th><cf_get_lang dictionary_id='58140.İş Grubu'></th>
						<th><cf_get_lang dictionary_id='57569.Gorevli'></th>
						<th><cf_get_lang dictionary_id='57486.Kategori'></th>
						<th><cf_get_lang dictionary_id='57485.Oncelik'></th>
						<th width="100"><cf_get_lang dictionary_id='57482.Asama'></th>
						<th width="30">%</th>
							<cfset colspan_info = colspan_info+2>
							<th width="100"><cf_get_lang dictionary_id ='38143.Öngörülen'></th>
							<th width="100"><cf_get_lang dictionary_id ='38128.Harcanan'></th>
						<th><cf_get_lang dictionary_id='38274.Delege Eden'></thd>
						<cfif session.ep.our_company_info.workcube_sector is 'tersane'>
							<cfset colspan_info = colspan_info+1>
							<th>PBS</th>
						</cfif>
						<th><cf_get_lang dictionary_id='57655.Başlama Tarihi'></th>
						<th><cf_get_lang dictionary_id='57700.Bitiş Tarihi'></th>
						<th><cf_get_lang dictionary_id ='60609.Termin Tarihi'></th>
						<!-- sil -->
						<th class="header_icn_none" width="20">
							<cfif not listfindnocase(denied_pages,'project.addwork')>
								<cfoutput><a href="#request.self#?fuseaction=project.works&event=add&work_fuse=#attributes.fuseaction#"><i class="fa fa-plus" alt="<cf_get_lang dictionary_id='57933.is ekle'>" title="<cf_get_lang dictionary_id='57933.is ekle'>"></i></a></cfoutput>

							</cfif>
						</th>
						<th><input class="checkControl" type="checkbox" id="checkAll" name="checkAll" onclick="wrk_select_all('checkAll','action_list_id');" value="0" spent_hour="0" spent_minute="0" estimated_time="0" estimated_time_minute="0" total_hour="0" total_minute="0"/></th>
						<!-- sil -->
					</tr>
				</thead>
				<tbody>
					<cfif isdefined("attributes.is_form_submitted") and get_works.recordcount>
						<cfoutput query="get_works" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
							<cfif isdefined("attributes.project_emp_id") and len(attributes.project_emp_id) and attributes.project_emp_id neq project_emp_id><cfset _row_font_color_ ='FF6633'><cfelse><cfset _row_font_color_ =''></cfif>
								<tr>
									<td><font color="#_row_font_color_#">#currentrow#</font></td>
									<td><font color="#get_works.color#">#work_no#</font></td>
									<td>#work_id#</td>
									<td><a href="#request.self#?fuseaction=project.works&event=det&id=#work_id#">
											<cfif is_milestone eq 1><font color="CC0000"><b>(M) #URLDecode(work_head)#</b></font><cfelse><font color="#_row_font_color_#">#URLDecode(work_head)#</font></cfif>
										</a>
									</td>
									<td><cfif len(get_works.project_id)>
											<a href="#request.self#?fuseaction=project.projects&event=det&id=#project_id#"><font color="#_row_font_color_#">#project_head#</font></a>
										<cfelse>
											<font color="#_row_font_color_#"><cf_get_lang dictionary_id='58459.projesiz'></font>
										</cfif>
									</td>
									<td><cfif len(company_id) and len(company_partner_id)>
											<a href="javascript://" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_par_det&par_id=#company_partner_id#','medium');"><font color="#_row_font_color_#">#company_partner#</font></a>                    
										<cfelseif len(consumer_id)>
											<a href="javascript://" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_con_det&con_id=#consumer_id#','medium');"><font color="#_row_font_color_#">#company_partner#</font></a>                    
										</cfif>
									</td>
									<td><font color="#_row_font_color_#">#workgroup_name#</font></td>
									<td><font color="#_row_font_color_#">
											<a href="javascript://" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_emp_det&emp_id=#project_emp_id#','medium');"><font color="#_row_font_color_#">#project_emp#</font></a>
										</font>
									</td>
									<td>#get_works.work_cat#</td>
									<td><font color="#get_works.color#">#get_works.priority#</font></td>
									<td>
										<cfif len(WORK_CURRENCY_ID)><cf_workcube_process type="color-status" process_stage="#WORK_CURRENCY_ID#"><cfelse><cf_get_lang dictionary_id="29815.Aşamasız"></cfif>
									</td>                
									<td align="right" style="text-align:right;">
										<div id="complate_ratio_div#WORK_ID#" style="display:none"></div> 
										<div class="form-group">
											<input type="text" name="is_complate#work_id#" id="complate_ratio#WORK_ID#" value="<cfif len(get_works.to_complete)>#get_works.to_complete#<cfelse>-</cfif>" <cfif xml_is_change_complate_ratio eq 0>readonly="readonly"</cfif> onkeyup="isNumber(this);" onblur="swaping(this.value,#WORK_ID#,'is_complate#work_id#')" maxlength="3" style="width:90%;color:#_row_font_color_#">
										</div>
									</td>
									<cfset saat_=0>
									<cfset dak_=0>
										<td> 
											<cfif isdefined('estimated_time') and len(estimated_time)>
												<cfset liste=estimated_time/60>
												<cfset saat_=listfirst(liste,'.')>
												<cfset dak_=estimated_time-saat_*60>
												<div id="addtimecost_div_#WORK_ID#" style="display:"></div> 
												<cfif not attributes.fuseaction contains 'autoexcelpopup'>
													<div class="form-group">
														<div class="col col-5 col-md-9 col-sm-9 col-xs-9">
															<input type="text" style="text-align:right;" name="estimated_hours_#work_id#" value="#saat_#" <cfif xml_change_time_cost eq 0>readonly="readonly"</cfif> onkeyup="isNumber(this);" maxlength="2" id="estimated_hours_#work_id#"  onkeypress="javascript:if(event.keyCode==13)addtimecost_ajax(this.value,#WORK_ID#,'hours',1);"  onblur="addtimecost_ajax(this.value,#WORK_ID#,'hours',1);">
														</div>
														<div class="col col-1 col-md-9 col-sm-9 col-xs-5 text-center">
															<label>:</label>
														</div>
														<div class="col col-5 col-md-9 col-sm-9 col-xs-9">
															<input type="text" name="estimated_minute_#work_id#" value="#dak_#" <cfif xml_change_time_cost eq 0>readonly="readonly"</cfif> onkeyup="isNumber(this);" maxlength="2" id="estimated_minute_#work_id#" onkeypress="javascript:if(event.keyCode==13)addtimecost_ajax(this.value,#WORK_ID#,'minute',1);"  onblur="addtimecost_ajax(this.value,#WORK_ID#,'minute',1);">
														</div>
													</div>
												<cfelse>
													#saat_# : #dak_#
												</cfif>
											</cfif>
										</td>
										<cfset saat=0>
										<cfset dak=0>
										<td><cfif len(harcanan_dakika)>
												<cfset harcanan_ = HARCANAN_DAKIKA>
												<cfset liste=harcanan_/60>
												<cfset saat=listfirst(liste,'.')>
												<cfset dak=harcanan_-saat*60>
												<div id="addtimecost_div#WORK_ID#" style="display:"></div> 
												<cfif not attributes.fuseaction contains 'autoexcelpopup'>
													<div class="form-group">
														<div class="col col-5 col-md-9 col-sm-9 col-xs-9">
															<input type="text" style="text-align:right;" name="hours_#work_id#" value="#saat#" <cfif xml_change_time_cost eq 0>readonly="readonly"</cfif> onclick="empty(#WORK_ID#,'hours_');" onkeyup="isNumber(this);" maxlength="2" id="hours_#work_id#"  onkeypress="javascript:if(event.keyCode==13)addtimecost_ajax(this.value,#WORK_ID#,'hours',0);"  onblur="addtimecost_ajax(this.value,#WORK_ID#,'hours',0);">
														</div>
														<div class="col col-1 col-md-9 col-sm-9 col-xs-5 text-center">
															<label>:</label>
														</div>
														<div class="col col-5 col-md-9 col-sm-9 col-xs-9">
															<input type="text" name="minute_#work_id#" value="#dak#" <cfif xml_change_time_cost eq 0>readonly="readonly"</cfif> onclick="empty(#WORK_ID#,'minute_');" onkeyup="isNumber(this);" maxlength="2" id="minute_#work_id#" onkeypress="javascript:if(event.keyCode==13)addtimecost_ajax(this.value,#WORK_ID#,'minute',0);"  onblur="addtimecost_ajax(this.value,#WORK_ID#,'minute',0);">
														</div>
													</div>
												<cfelse>
													#saat# : #dak#
												</cfif>
											</cfif>
										</td>
									<td><font color="#_row_font_color_#"><cfif len(RECORD_AUTHOR_NAME)>#record_author_name#</cfif></font></td>
									<cfif session.ep.our_company_info.workcube_sector is 'tersane'><td><font color="#get_works.color#">#pbs_code#</font></td></cfif>
									<td>#dateformat(TARGET_START,dateformat_style)#</td>
									<td>#dateformat(TARGET_FINISH,dateformat_style)#</td>
									<td>#dateformat(TERMINATE_DATE,dateformat_style)#</td>
									<!-- sil -->
									<td><a href="#request.self#?fuseaction=project.works&event=upd&id=#work_id#"><i class="fa fa-pencil" title="<cf_get_lang dictionary_id='55061.İş Detayı'>"></i></a></td>
									<td>
										<input class="checkControl" type="checkbox" name="action_list_id" id="action_list_id" value="#work_id#" spent_hour="#saat#" spent_minute="#dak#" estimated_time="#saat_#" estimated_time_minute="#dak_#" total_hour="#(saat_-saat)#" total_minute="#(dak_-dak)#"/>
									</td>
									<!-- sil -->
								</tr>
						</cfoutput>
					<cfelse>
						<tr>
							<td colspan="20"><cfif not isdefined("attributes.is_form_submitted")><cf_get_lang dictionary_id='57701.Filtre Ediniz'>!<cfelse><cf_get_lang dictionary_id='57484.Kayit Bulunamadi'>!</cfif></td>
						</tr>
					</cfif>
				</tbody>
			</cf_grid_list>

			<cfset url_str = "&is_form_submitted=1">
			<cfif isdefined("attributes.keyword") and len(attributes.keyword)>
				<cfset url_str = "#url_str#&keyword=#attributes.keyword#">
			</cfif>
			<cfif isdefined("attributes.process_stage_work") and len(attributes.process_stage_work)>
				<cfset url_str = "#url_str#&process_stage_work=#attributes.process_stage_work#">
			</cfif>
			<cfif isdefined("attributes.priority_cat") and len(attributes.priority_cat)>
				<cfset url_str = "#url_str#&priority_cat=#attributes.priority_cat#">
			</cfif>
			<cfif isdefined("attributes.work_cat") and len(attributes.work_cat)>
				<cfset url_str = "#url_str#&work_cat=#attributes.work_cat#">
			</cfif>
			<cfif isdefined("attributes.work_status") and len(attributes.work_status)>
				<cfset url_str = "#url_str#&work_status=#attributes.work_status#">
			</cfif>
			<cfif isdefined("attributes.contract_id") and len(attributes.contract_id) and isdefined("attributes.contract_no") and len(attributes.contract_no)>
				<cfset url_str = "#url_str#&contract_no=#attributes.contract_no#&contract_id=#attributes.contract_id#">
			</cfif>
			<cfif isdefined("attributes.expense_code_name") and len(attributes.expense_code_name)>
				<cfset url_str = "#url_str#&expense_code_name=#attributes.expense_code_name#">
			</cfif>
			<cfif session.ep.our_company_info.workcube_sector is 'tersane' and isdefined("attributes.pbs_id") and len(attributes.pbs_id)>
				<cfset url_str = "#url_str#&pbs_id=#attributes.pbs_id#&pbs_code=#attributes.pbs_code#">
			</cfif>
			<cfif isdefined("attributes.project_emp_id")>
				<cfset url_str = "#url_str#&project_emp_id=#attributes.project_emp_id#">
			</cfif>
			<cfif isdefined("attributes.emp_name")>
				<cfset url_str = "#url_str#&emp_name=#attributes.emp_name#">
			</cfif>
			<cfif len(attributes.emp_name) and len(attributes.outsrc_partner_id)>
				<cfset url_str = "#url_str#&outsrc_partner_id=#attributes.outsrc_partner_id#">
			</cfif>
			<cfif len(attributes.cc_name) and Len(attributes.cc_emp_id)>
				<cfset url_str = "#url_str#&cc_name=#attributes.cc_name#&cc_emp_id=#attributes.cc_emp_id#">
			</cfif>
			<cfif len(attributes.cc_name) and Len(attributes.cc_par_id)>
				<cfset url_str = "#url_str#&cc_name=#attributes.cc_name#&cc_par_id=#attributes.cc_par_id#">
			</cfif>
			<cfif len(attributes.comp_id)>
				<cfset url_str = "#url_str#&comp_id=#attributes.comp_id#">
			</cfif>
			<cfif len(attributes.comp_name)>
				<cfset url_str = "#url_str#&comp_name=#attributes.comp_name#">
			</cfif>
			<cfif len(attributes.startdate)>
				<cfset url_str = "#url_str#&startdate=#dateformat(attributes.startdate,dateformat_style)#">
			</cfif>
			<cfif len(attributes.finishdate)>
				<cfset url_str = "#url_str#&finishdate=#dateformat(attributes.finishdate,dateformat_style)#">
			</cfif>
			<cfif len(attributes.project_id)>
				<cfset url_str = "#url_str#&project_id=#attributes.project_id#">
			</cfif>
			<cfif isdefined("attributes.ordertype") and len(attributes.ordertype)>
				<cfset url_str = "#url_str#&ordertype=#attributes.ordertype#">
			</cfif>
			<cfif isDefined("attributes.recorder_id") and len(attributes.recorder_id)>
				<cfset url_str = "#url_str#&recorder_id=#attributes.recorder_id#">
			</cfif>
			<cfif isDefined("attributes.recorder_name") and len(attributes.recorder_name)>
				<cfset url_str = "#url_str#&recorder_name=#attributes.recorder_name#">
			</cfif>
			<cfif isDefined("attributes.upd_by_id") and len(attributes.upd_by_id)>
				<cfset url_str = "#url_str#&upd_by_id=#attributes.upd_by_id#">
			</cfif>
			<cfif isDefined("attributes.upd_by_name") and len(attributes.upd_by_name)>
				<cfset url_str = "#url_str#&upd_by_name=#attributes.upd_by_name#">
			</cfif>
			<cfif isDefined("attributes.workgroup_id") and len(attributes.workgroup_id)>
				<cfset url_str = "#url_str#&workgroup_id=#attributes.workgroup_id#">
			</cfif>
			<cfif isDefined("attributes.show_milestone") and len(attributes.show_milestone)>
				<cfset url_str = "#url_str#&show_milestone=#attributes.show_milestone#">
			</cfif>
			<cfif len(attributes.special_definition)>
				<cfset url_str="#url_str#&special_definition=#attributes.special_definition#">
			</cfif>   
			<cfif len(attributes.to_complete)>
				<cfset url_str="#url_str#&to_complete=#attributes.to_complete#">
			</cfif>
			<cfif isdefined("attributes.onfuseaction") and  len(attributes.onfuseaction)>
				<cfset url_str="#url_str#&onfuseaction=#attributes.onfuseaction#">
			</cfif>
			<cfif isdefined("attributes.onmodule") and  len(attributes.onmodule)>
				<cfset url_str="#url_str#&onmodule=#attributes.onmodule#">
			</cfif>
			<cfif isdefined("attributes.department") and  len(attributes.department)>
				<cfset url_str="#url_str#&department=#attributes.department#">
			</cfif>
			<cfif isdefined("attributes.branch_id") and  len(attributes.branch_id)>
				<cfset url_str="#url_str#&branch_id=#attributes.branch_id#">
			</cfif>
			<cfif len(attributes.activity_id)>
				<cfset url_str = "#url_str#&activity_id=#attributes.activity_id#">
			</cfif>
			<cfif len(attributes.work_emp_cc)>
				<cfset url_str = "#url_str#&work_emp_cc=#attributes.work_emp_cc#">
			</cfif>
			
			<cfif len(attributes.pro_emp_name)>
				<cfset url_str = "#url_str#&pro_emp_name=#attributes.pro_emp_name#">
			</cfif>
			<cfif len(attributes.pro_emp_id)>
				<cfset url_str = "#url_str#&pro_emp_id=#attributes.pro_emp_id#">
			</cfif>
			<cf_paging 
				name="setProcessForm"
				page="#attributes.page#"
				maxrows="#attributes.maxrows#"
				totalrecords="#attributes.totalrecords#"
				startrow="#attributes.startrow#"
				adres="project.works#url_str#"
				is_form="1">
		</cf_box>
		<cfinclude template="GeneralPaperWork.cfm">
	</cfform>
</div>
<script type="text/javascript">
	document.getElementById('keyword').focus();
	function collactive(type){
		spent_hour_ = 0;
		spent_minute_ = 0;
		estimated_time_ = 0;			
		estimated_time_minute_ = 0;
		total_hour_ = 0;
		total_minute_ = 0;

		spent_hour = 0;
		spent_minute = 0;
		estimated_time = 0;			
		estimated_time_minute = 0;
		total_hour= 0;
		total_minute = 0;
		$('.checkControl').each(function() {
			if(this.checked){
				estimated_time_minute_ += (type==1) ? parseInt($(this).attr("estimated_time_minute")) : parseInt($('#estimated_minute_'+$(this).val()).val());
				estimated_time_ += (type==1) ? parseInt($(this).attr("estimated_time")) : parseInt($('#estimated_hours_'+$(this).val()).val());
				sonuc = (estimated_time_* 60) + estimated_time_minute_;
				estimated_time = parseInt(sonuc / 60);
				estimated_time_minute = sonuc -(estimated_time*60);

				spent_hour_ +=  (type==1) ? parseInt($(this).attr("spent_hour")) : parseInt($('#hours_'+$(this).val()).val());
				spent_minute_ +=  (type==1) ? parseInt($(this).attr("spent_minute")) : parseInt($('#minute_'+$(this).val()).val());
				sonuc_spend = (spent_hour_* 60) + spent_minute_;
				spent_hour = parseInt(sonuc_spend / 60);
				spent_minute = sonuc_spend -(spent_hour*60);

				total_hour_ += (type==1) ? parseInt($(this).attr("total_hour")) : (estimated_time_ - spent_hour_);
				total_minute_ += (type==1) ? parseInt($(this).attr("total_minute")) : (estimated_time_minute_ - spent_minute_) ;
				sonuc_total = (total_hour_* 60) + total_minute_;
				total_hour = parseInt(sonuc_total / 60);
				total_minute = sonuc_total -(total_hour*60)	;
			}
		});
		
		$('#total_time_hour').val(spent_hour);
		$('#total_time_minute').val(spent_minute);
		$('#estimated_time').val(estimated_time);
		$('#estimated_time_minute').val(estimated_time_minute);
		$('#total_estimated_time').val(total_hour);
		$('#total_estimated_time_minute').val(total_minute);
	}
	$(function(){
		$('.checkControl').click(function(){
			collactive(1);
		});
	});
	function setGeneralPaperWork(){
		var controlChc = 0;
		$('.checkControl').each(function(){
			if(this.checked){
				controlChc += 1;
			}
		});
		if(controlChc == 0){
			alert("<cf_get_lang dictionary_id='61354.İşlem için satır seçiniz.'>");
			return false;
		}
		if( $.trim($('#general_paper_no').val()) == '' ){
			alert("<cf_get_lang dictionary_id='33367.Lütfen Belge No Giriniz'>");
			return false;
		}else{
			paper_no_control = wrk_safe_query('general_paper_control','dsn',0,$('#general_paper_no').val());
			if(paper_no_control.recordcount > 0)
			{
				alert("<cf_get_lang dictionary_id='49009.Girdiğiniz Belge Numarası Kullanılmaktadır'>.<cf_get_lang dictionary_id='59367.Otomatik olarak değişecektir'>.");
				paper_no_val = $('#general_paper_no').val();
				paper_no_split = paper_no_val.split("-");
				if(paper_no_split.length == 1)
					paper_no = paper_no_split[0];
				else
					paper_no = paper_no_split[1];
				paper_no = parseInt(paper_no);
				paper_no++;
				if(paper_no_split.length == 1)
					$('#general_paper_no').val(paper_no);
				else
					$('#general_paper_no').val(paper_no_split[0]+"-"+paper_no);
				return false;
			}
		}
		if( $.trim($('#general_paper_date').val()) == '' ){
			alert("Lütfen Belge Tarihi Giriniz!");
			return false;
		}
		if( $.trim($('#general_paper_notice').val()) == '' ){
			alert("Lütfen Ek Açıklama Giriniz!");
			return false;
		}
		if( $.trim($('#total_estimated_time').val()) < 0 || $.trim($('#total_estimated_time_minute').val()) < 0) {
			alert("<cf_get_lang dictionary_id='62962.Dikkat: İşlerinizin zaman planlamasını kontrol ediniz. Öngörülen süreleri yeniden planlayınız.'>");
			return false;
		}
		<cfif isDefined("attributes.wrkflow") and attributes.wrkflow eq 1>
			$('#setProcessForm').attr('action', '<cfoutput>#request.self#?fuseaction=project.works#url_str#&box_submitted=1</cfoutput>');
		</cfif>
		document.getElementById("total_estimated_time").value = document.getElementById("total_estimated_time").value;
		document.getElementById("total_time_hour").value = document.getElementById("total_time_hour").value;
		document.getElementById("total_time_minute").value = document.getElementById("total_time_minute").value;
		document.getElementById("estimated_time").value = document.getElementById("estimated_time").value;
		document.getElementById("estimated_time_minute").value = document.getElementById("estimated_time_minute").value;
		return true;
	}
	function showDepartment(branch_id)	
	{
		var branch_id = document.getElementById('branch_id').value;
		if (branch_id != "")
		{
			var send_address = "<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popupajax_list_departments&branch_id="+branch_id;
			AjaxPageLoad(send_address,'item-department',1,'İlişkili Departmanlar');
		}
		else
		{
			var myList = document.getElementById("department");
			myList.options.length = 0;
			var txtFld = document.createElement("option");
			txtFld.value='';
			txtFld.appendChild(document.createTextNode('<cf_get_lang dictionary_id="57734.Seçiniz">'));
			myList.appendChild(txtFld);
		}
	}
	function get_work_currency()
	{
		var currency_len = document.getElementById("process_stage_work").options.length;
		for(kk=currency_len;kk>=0;kk--)
			document.getElementById("process_stage_work").options[kk] = null;	
		document.getElementById("process_stage_work").options[0] = new Option('<cf_get_lang dictionary_id="57482.Asama">','');
		if(document.getElementById("work_cat").value != '')
		{
			var get_work_stage=wrk_safe_query('get_pro_works_currency','dsn',0,document.getElementById("work_cat").value);
				
			for(var jj=0;jj < get_work_stage.recordcount;jj++)
				document.getElementById("process_stage_work").options[jj+1]=new Option(get_work_stage.STAGE[jj],get_work_stage.PROCESS_ROW_ID[jj]);
		}
	}
	function kontrol()
	{
		if( !date_check(document.getElementById('startdate'),document.getElementById('finishdate'), "<cf_get_lang dictionary_id='58862.Başlangıç Tarihi Bitiş Tarihinden Büyük Olamaz'>!") )
			return false;
		else
			return true;
	}
	function reset_comp_id()
	{
		document.getElementById('comp_id').value='';
	}
	function gonder(str_alan_1)
	{
		openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_pars&field_comp_id=list_works.comp_id&field_comp_name=list_works.comp_name&select_list=2&keyword='+encodeURIComponent(list_works.comp_name.value));
	}
	function gonder2(str_alan_1)
	{
		str_list = '';
			str_list = str_list+'branch_id='+document.getElementById("branch_id").value;
			str_list = str_list+'&department_id='+document.getElementById("department").value;
			openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_positions&field_emp_id=list_works.project_emp_id&'+str_list+'&field_name=list_works.emp_name <cfif isdefined("xml_only_employee") and xml_only_employee eq 0>&field_partner=list_works.outsrc_partner_id</cfif>&select_list=1,2&is_form_submitted=1&keyword='+encodeURIComponent(list_works.emp_name.value));
	}

	function selectSec()
	{
		if($("#emp_name").val() == "") $("#work_emp_cc").val(0); else $("#work_emp_cc").val(1); 

	}
	function gonder3(str_alan_1,str_alan_2)
	{
			openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_positions&field_emp_id='+str_alan_2+'&field_name='+str_alan_1+'&select_list=1,2&is_form_submitted=1');
	}/*(this.value,#WORK_ID#,is_complate#work_id#)*/
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
			alert("<cf_get_lang dictionary_id ='38338.Tamamlanma Orani 100 den kucük bir rakam olmalidir'>!");
			return false;
		}
	}
	function addtimecost_ajax(time_value,work_id,type,estimate)
	{
		if(type=='minute')
			{
				var time_value1 = 0;
				var time_value2 = document.getElementById('minute_'+work_id).value;
			}
		else
			{
				var time_value1 = document.getElementById('hours_'+work_id).value;
				var time_value2 = 0;
			}
		if(estimate == 1)
			{

				var estimated_time = document.getElementById('estimated_hours_'+work_id).value;
				var estimated_time_minute =  document.getElementById('estimated_minute_'+work_id).value;
				if(document.getElementById('estimated_hours_'+work_id) != undefined && document.getElementById('estimated_hours_'+work_id).value != '' && document.getElementById('estimated_minute_'+work_id) != undefined && document.getElementById('estimated_minute_'+work_id).value != '')
					{	
						timecostdiv_id = 'addtimecost_div_'+work_id;
						var send_address = '<cfoutput>#request.self#</cfoutput>?fuseaction=project.emptypopup_ajax_timecost&time_value1=0&time_value2=0&work_id='+ work_id +'&estimated_time='+estimated_time+'&estimated_time_minute='+estimated_time_minute;
						AjaxPageLoad(send_address,timecostdiv_id ,1);
					}
				collactive(2);
	
			}
		else
			{
				if(time_value1 <=24 && time_value2 < 60)
					{
						timecostdiv_id = 'addtimecost_div'+work_id;
						if(document.getElementById('hours_'+work_id) != undefined && document.getElementById('hours_'+work_id).value != '' && document.getElementById('minute_'+work_id) != undefined && document.getElementById('minute_'+work_id).value != '')
							{	
								var send_address = '<cfoutput>#request.self#</cfoutput>?fuseaction=project.emptypopup_ajax_timecost&work_id='+ work_id +'&time_value1='+time_value1+'&time_value2='+time_value2;
								AjaxPageLoad(send_address,timecostdiv_id ,1);
							}
					}
				else
				{
					alert("<cf_get_lang dictionary_id='38455.Saat için 1-24, Dakika 1-59 içim Arası Değer Girilmelidir'>");
					return false;
				}
			}
	}
	function empty(id,type_)
	{
		if(type_ == 'hours_'){
			document.getElementById('hours_'+id).value = '';
		}		
		else if(type_ == 'minute_')
		{
			document.getElementById('minute_'+id).value = '';
		}
		
	}
</script>
