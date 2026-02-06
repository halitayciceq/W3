<cfif isdefined("attributes.opp_id")>
	<cfquery name="get_opp_workgroup" datasource="#dsn#" maxrows="1">
		SELECT WORKGROUP_ID,WORKGROUP_NAME FROM WORK_GROUP WHERE OPP_ID = #attributes.opp_id#
	</cfquery>
	<cfquery name="get_opp_head" datasource="#dsn3#" maxrows="1">
		SELECT OPP_HEAD FROM OPPORTUNITIES WHERE OPP_ID = #attributes.opp_id#
	</cfquery>
</cfif>
<cfif isdefined("attributes.opp_id") and get_opp_workgroup.recordcount>
	<cfquery name="GET_EMPS" datasource="#dsn#">
		SELECT * FROM WORKGROUP_EMP_PAR WHERE WORKGROUP_ID = #get_opp_workgroup.WORKGROUP_ID# ORDER BY HIERARCHY
	</cfquery>
	<cfset work_group_row = GET_EMPS.recordcount>
<cfelse>
	<cfset work_group_row = 0>
</cfif>
<cfquery name="GET_ROLES" datasource="#dsn#">
	SELECT * FROM SETUP_PROJECT_ROLES ORDER BY PROJECT_ROLES
</cfquery>
<cfparam  name="attributes.modal_id" default="">
<cfparam  name="attributes.draggable" default="">
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box  title="#getlang('','','41438')#" popup_box="#iif(isdefined("attributes.draggable"),1,0)#">
		<cfform name="add_workgroup" action="#request.self#?fuseaction=sales.emptypopup_add_workgroup" method="post">
			<input type="hidden" name="WORKGROUP_ID" id="WORKGROUP_ID" value="<cfif get_opp_workgroup.recordcount><cfoutput>#get_opp_workgroup.workgroup_id#</cfoutput></cfif>">
			<input type="hidden" name="opp_head" id="opp_head" value="<cfoutput>#get_opp_head.opp_head#</cfoutput>">
			<input type="hidden" name="opp_id" id="opp_id" value="<cfif isdefined("attributes.opp_id")><cfoutput>#attributes.opp_id#</cfoutput></cfif>">
			<input type="hidden" name="modal_id" id="modal_id" value="<cfoutput>#attributes.modal_id#</cfoutput>">
			<input type="hidden" name="draggable" id="draggable" value="<cfoutput>#attributes.draggable#</cfoutput>">
				<cf_grid_list>
					<thead>
						<tr>
							<th width="20"><a onClick="add_row();"><i class="fa fa-plus" title="<cf_get_lang dictionary_id ='57582.Ekle'>" alt="<cf_get_lang dictionary_id ='57582.Ekle'>"></i></a></th>
							<th width="120" class="test center"><cf_get_lang dictionary_id ='58585.Kod'></th>
							<th  class="test center"><cf_get_lang dictionary_id ='57569.Görevli'></th>
							<th  class="test center"><cf_get_lang dictionary_id='41476.Rol'></th>
						</tr>
					</thead>
					<tbody id="workgroup_table1">
						<cfif get_opp_workgroup.recordcount and GET_EMPS.recordcount>
							<cfoutput query="GET_EMPS">
							<cfset this_role_id = role_id>
								<tr id="frm_row#currentrow#">
									<td><input type="hidden" value="1" name="row_kontrol#currentrow#" id="row_kontrol#currentrow#"><a style="cursor:pointer" onclick="sil(#currentrow#);"><i class="fa fa-minus" title="<cf_get_lang dictionary_id ='57463.Sil'>" alt="<cf_get_lang dictionary_id ='57463.Sil'>"></i></a></td>
									<td>
										<div class="form-group">
											<input type="text" name="code#currentrow#" id="code#currentrow#" value="#hierarchy#">
										</div>
									</td>
									<td>
										<div class="form-group">
											<div class="input-group">
												<cfif len(EMPLOYEE_ID)>
													<input type="text" name="member_name#currentrow#" id="member_name#currentrow#" value="#get_emp_info(EMPLOYEE_ID,0,0)#">
													<input type="hidden" name="member_type#currentrow#" id="member_type#currentrow#" value="employee">
												<cfelseif len(CONSUMER_ID)>
													<input type="text" name="member_name#currentrow#" id="member_name#currentrow#" value="#get_cons_info(CONSUMER_ID,1,0)#">
													<input type="hidden" name="member_type#currentrow#" id="member_type#currentrow#" value="consumer">
												<cfelseif len(PARTNER_ID)>
													<cfquery name="get_comp_partner" datasource="#dsn#">
														SELECT 
															COMPANY_PARTNER_NAME,
															COMPANY_PARTNER_SURNAME,
															NICKNAME
														FROM
															COMPANY,
															COMPANY_PARTNER
														WHERE
															COMPANY.COMPANY_ID = COMPANY_PARTNER.COMPANY_ID AND
															COMPANY_PARTNER.PARTNER_ID = #PARTNER_ID#
													</cfquery>
													<cfset member_name_ = '#get_comp_partner.COMPANY_PARTNER_NAME# #get_comp_partner.COMPANY_PARTNER_SURNAME#-#get_comp_partner.NICKNAME#'>
													<input type="text" name="member_name#currentrow#" id="member_name#currentrow#" value="#member_name_#">
													<input type="hidden" name="member_type#currentrow#" id="member_type#currentrow#" value="partner">
												<cfelse>
													<input type="text" name="member_name#currentrow#" id="member_name#currentrow#" value="">
													<input type="hidden" name="member_type#currentrow#" id="member_type#currentrow#" value="">
												</cfif>
												<input type="hidden" name="employee_id#currentrow#" id="employee_id#currentrow#" value="#employee_id#">
												<input type="hidden" name="consumer_id#currentrow#" id="consumer_id#currentrow#" value="#consumer_id#">
												<input type="hidden" name="company_id#currentrow#" id="company_id#currentrow#" value="#company_id#">
												<input type="hidden" name="partner_id#currentrow#" id="partner_id#currentrow#" value="#partner_id#"><span class="input-group-addon icon-ellipsis" onClick="pencere_ac1(#currentrow#);"></span>
											</div>
										</div>
									</td>
									<td>
										<div class="form-group">
											<select name="role_id#currentrow#" id="role_id#currentrow#" style="width:125px;">
												<option value=""><cf_get_lang dictionary_id ='57734.Seçiniz'></option>
												<cfif get_roles.recordcount>
													<cfloop query="get_roles">
														<option value="#get_roles.PROJECT_ROLES_ID#" <cfif this_role_id eq get_roles.PROJECT_ROLES_ID>selected</cfif>>#get_roles.PROJECT_ROLES#</option>
													</cfloop>
												</cfif>
											</select>
										</div>
									</td>
								</tr>
							</cfoutput>
						</cfif>
					</tbody>
				</cf_grid_list>
			
			<cf_box_footer>
				<input type="hidden" name="record" id="record" value="<cfoutput>#work_group_row#</cfoutput>">
				<cfif get_opp_workgroup.recordcount> 
					<cf_workcube_buttons is_upd='1' is_delete='0' add_function='workgroup_kontrol()&&#iif(isdefined("attributes.draggable"),DE("loadPopupBox('add_workgroup' , #attributes.modal_id#)"),DE(""))#'>
				<cfelse>
					<cf_workcube_buttons is_upd='0' is_delete='0' add_function='workgroup_kontrol()&&#iif(isdefined("attributes.draggable"),DE("loadPopupBox('add_workgroup' , #attributes.modal_id#)"),DE(""))#'>
				</cfif>	
			</cf_box_footer>
		</cfform>
	</cf_box>
</div>
<script type="text/javascript">
	row_count=<cfoutput>#work_group_row#</cfoutput>;
	function add_row(code)
	{
		if(code == undefined)code ="";
		row_count++;
		var newRow;
		var newCell;
		
		document.add_workgroup.record.value=row_count;

		newRow = document.getElementById("workgroup_table1").insertRow(document.getElementById("workgroup_table1").rows.length);
		newRow.setAttribute("name","frm_row" + row_count);
		newRow.setAttribute("id","frm_row" + row_count);
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<input type="hidden" value="1" name="row_kontrol' + row_count + '"><a style="cursor:pointer" onclick="sil(' + row_count + ');"><i class="fa fa-minus" alt="<cf_get_lang dictionary_id ='57463.Sil'>" title="<cf_get_lang dictionary_id ='57463.Sil'>"></i></a>';
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<div class="form-group"><input type="text" name="code'+ row_count +'" value="'+code+'"></div>';
				
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<div class="form-group"><div class="input-group"><input type="text" name="member_name'+ row_count +'" value="" readonly="yes"><input type="hidden" name="consumer_id'+ row_count +'" value=""><input type="hidden" name="company_id'+ row_count +'" value=""><input type="hidden" name="partner_id'+ row_count +'" value=""><input type="hidden" name="member_type'+ row_count +'" value=""><input type="hidden" name="employee_id'+ row_count +'" value=""><span class="input-group-addon icon-ellipsis" onClick="pencere_ac1('+ row_count +');"></span></div></div>';
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<div class="form-group"><select name="role_id'+ row_count +'"><option value=""><cf_get_lang dictionary_id ="57734.Seçiniz"></option><cfoutput query="get_roles"><option value="#get_roles.PROJECT_ROLES_ID#">#PROJECT_ROLES#</option></cfoutput></select>';
		
	}
	function pencere_ac1(no)
	{
		openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_positions&field_consumer=add_workgroup.consumer_id'+no+'&field_comp_id=add_workgroup.company_id'+no+'&field_partner=add_workgroup.partner_id'+no+'&field_name=add_workgroup.member_name'+no+'&field_emp_id=add_workgroup.employee_id'+no+'&select_list=1,2,3&field_type=add_workgroup.member_type'+no);
	}

	function sil(no)
	{
		var my_element=eval("add_workgroup.row_kontrol"+no);		
		my_element.value=0;
		
		var my_element=eval("frm_row"+no);
		my_element.style.display="none";
	}

	function workgroup_kontrol()
	{
	if(row_count==0)
		{
			alert("En Az Bir Grup Çalışan Kaydı Giriniz!");
			return false;
		}
		for(row_=1;row_<=row_count;row_++)
		{
			if(eval("document.add_workgroup.row_kontrol"+row_).value == 1)
			{
				_member_name=eval("document.add_workgroup.member_name"+row_);
				_role_id=eval("document.add_workgroup.role_id"+row_);
				if(_member_name.value=="")
				{
					alert("<cf_get_lang dictionary_id ='61950.Görevli Seçiniz'>");
					return false;
				}
			}
		}
		return true;
	}
</script>
