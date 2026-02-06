<cfset xml_page_control_list = 'is_project_team_price'>
<cf_xml_page_edit page_control_list="#xml_page_control_list#" default_value="1">
<cfif isdefined("attributes.PROJECT_ID")>
	<cfquery name="get_project_xml" datasource="#dsn#">
		SELECT 
			PROPERTY_VALUE,
			PROPERTY_NAME
		FROM
			FUSEACTION_PROPERTY
		WHERE
			OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session_base.company_id#"> AND
			FUSEACTION_NAME = <cfqueryparam cfsqltype="cf_sql_varchar" value="project.projects"> AND
			PROPERTY_NAME = <cfqueryparam cfsqltype="cf_sql_varchar" value="xml_is_all_role">
	</cfquery>
	<cfquery name="get_project_workgroup" datasource="#dsn#" maxrows="1">
		SELECT * FROM WORK_GROUP WHERE PROJECT_ID = #attributes.project_id#
	</cfquery>
	<cfquery name="get_project_head" datasource="#dsn#" maxrows="1">
		SELECT PROJECT_EMP_ID,PROJECT_HEAD FROM PRO_PROJECTS WHERE PROJECT_ID = #attributes.project_id#
	</cfquery>
<cfelseif isDefined("attributes.action_id") and isDefined("attributes.action_field")>
	<cfquery name="GET_ACTION_WORKGROUP" datasource="#dsn#" maxrows="1">
		SELECT * FROM WORK_GROUP WHERE ACTION_FIELD = <cfqueryparam cfsqltype="cf_sql_nvarchar" value="#attributes.action_field#"> AND ACTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.action_id#">
	</cfquery>
</cfif>
<cfif isdefined("attributes.PROJECT_ID") and get_project_workgroup.recordcount>
	<cfquery name="GET_EMPS" datasource="#dsn#">
		SELECT * FROM WORKGROUP_EMP_PAR WHERE WORKGROUP_ID = #get_project_workgroup.WORKGROUP_ID# AND OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#"> ORDER BY HIERARCHY
	</cfquery>
	<cfquery name="GET_EMPS_ROLE" datasource="#dsn#">
		SELECT EMPLOYEE_ID,ROLE_ID FROM WORKGROUP_EMP_PAR WHERE WORKGROUP_ID = #get_project_workgroup.WORKGROUP_ID# AND OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#"> and EMPLOYEE_ID IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#">)
	</cfquery>
	<cfset work_group_row = GET_EMPS.recordcount>
<cfelseif isDefined("attributes.action_id") and isDefined("attributes.action_field") and get_action_workgroup.recordcount>
	<cfquery name="GET_EMPS" datasource="#dsn#">
		SELECT * FROM WORKGROUP_EMP_PAR WHERE WORKGROUP_ID = #get_action_workgroup.WORKGROUP_ID# AND OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#"> ORDER BY HIERARCHY
	</cfquery>
    <cfset work_group_row = GET_EMPS.recordcount>
<cfelse>
	<cfset work_group_row = 0>
</cfif>
<cfif isdefined("attributes.PROJECT_ID")  and  (get_project_head.PROJECT_EMP_ID neq session.ep.userid) and not ListFind(get_project_xml.PROPERTY_VALUE,session.ep.POSITION_CODE,',')    >
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='57532.Yetkiniz Yok'>");
			location.href = document.referrer;
	</script>
	<cfabort>
</cfif>
<cfquery name="GET_ROLES" datasource="#dsn#">
	SELECT * FROM SETUP_PROJECT_ROLES ORDER BY PROJECT_ROLES
</cfquery>
<cfquery name="GET_MONEY" datasource="#DSN#">
	SELECT
		MONEY
	FROM
		SETUP_MONEY
	WHERE
		PERIOD_ID = #session.ep.period_id# AND
		MONEY_STATUS = 1
	ORDER BY
		MONEY DESC
</cfquery>
<cfif isdefined("attributes.PROJECT_ID")>
	<cfsavecontent variable="header_"><cf_get_lang dictionary_id ='38227.Proje Grubu'>: <cfoutput>#get_project_head.PROJECT_HEAD#</cfoutput></cfsavecontent>
<cfelseif isDefined("attributes.action_id") and isDefined("attributes.action_field")>
	<cfsavecontent variable="header_"><cfif attributes.action_field eq 'subscription'><cf_get_lang dictionary_id='61356.Abone Ekibi'><cfelseif attributes.action_field eq 'training_management'><cf_get_lang dictionary_id='46049.Müfredat'><cf_get_lang dictionary_id='41499.Ekibi'><cfelseif attributes.action_field eq 'campaing'><cf_get_lang dictionary_id='57446.Kampanya'><cf_get_lang dictionary_id='41499.Ekibi'><cfelse><cf_get_lang dictionary_id ='30048.Satınalma Teklifleri'></cfif>: <cfoutput>#attributes.action_id#</cfoutput></cfsavecontent>
</cfif>
<cfparam name="attributes.modal_id" default="">
<!--- calisanlar --->
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box id="form_add_group_id" title="#header_#" scroll="1" collapsable="1" resize="1" popup_box="#iif(isdefined("attributes.draggable"),1,0)#">
		<cfform name="add_workgroup" action="#request.self#?fuseaction=project.emptypopup_add_workgroup" method="post">
			<cfif isdefined("attributes.PROJECT_ID")>
				<input type="hidden" name="WORKGROUP_ID" id="WORKGROUP_ID" value="<cfif get_project_workgroup.recordcount><cfoutput>#get_project_workgroup.workgroup_id#</cfoutput></cfif>">
				<input type="hidden" name="project_head" id="project_head" value="<cfoutput>#get_project_head.PROJECT_HEAD#</cfoutput>">
				<input type="hidden" name="project_id" id="project_id" value="<cfif isdefined("attributes.PROJECT_ID")><cfoutput>#attributes.PROJECT_ID#</cfoutput></cfif>">
				<input type="hidden" name="is_project_team_price" id="is_project_team_price" value="<cfif isdefined("is_project_team_price")><cfoutput>#is_project_team_price#</cfoutput></cfif>">
			<cfelseif isDefined("attributes.action_id") and isDefined("attributes.action_field")>
				<input type="hidden" name="WORKGROUP_ID" id="WORKGROUP_ID" value="<cfif get_action_workgroup.recordcount><cfoutput>#get_action_workgroup.workgroup_id#</cfoutput></cfif>">
				<input type="hidden" name="action_field" id="action_field" value="<cfoutput>#attributes.action_field#</cfoutput>">
				<input type="hidden" name="action_id" id="action_id" value="<cfoutput>#attributes.action_id#</cfoutput>">
			</cfif>
			<cf_grid_list>
				<thead>
					<tr>
						<th width="20"><a onClick="add_row_team();"><i class="fa fa-plus" title="<cf_get_lang dictionary_id ='57582.Ekle'>"></i></a></th>
						<th><cf_get_lang dictionary_id ='58585.Kod'>*</th>
						<th><cf_get_lang dictionary_id ='57569.Görevli'> </th>
						<th><cf_get_lang dictionary_id ='38182.Rol'></th>
						<cfif isdefined('is_project_team_price') and (is_project_team_price eq 1)>
							<th><cf_get_lang dictionary_id ='38408.Hizmet/Ürün'> </th>
							<th><cf_get_lang dictionary_id ='57636.Birim'></th>
							<th><cf_get_lang dictionary_id='58734.Hafta'>-<cf_get_lang dictionary_id='29513.Süre'>-<cf_get_lang dictionary_id='57635.Miktar'></th>
							<th><cf_get_lang dictionary_id='46798.Alış Fiyatı'></th>
							<th><cf_get_lang dictionary_id='48183.Satış Fiyatı'></th>
							<th><cf_get_lang dictionary_id ='57489.Para Birimi'></th>
						</cfif>
					</tr>
				</thead>
				<tbody name="table1_workgroup" id="table1_workgroup">
					<cfif ((isDefined("get_project_workgroup") and get_project_workgroup.recordcount) OR (isDefined("get_action_workgroup") AND get_action_workgroup.recordcount)) and GET_EMPS.recordcount>
						<cfoutput query="GET_EMPS">
							<cfset this_role_id = role_id>
							<tr id="workgroup_row#currentrow#">
								<td><input type="hidden" value="1" name="row_kontrol#currentrow#" id="row_kontrol#currentrow#">
									<a onclick="remove_workgroup(#currentrow#);"><i class="fa fa-minus" title="<cf_get_lang dictionary_id ='57463.Sil'>"></i></a>
								</td>
								<td>
									<div class="form-group"> 
										<input type="text" name="code#currentrow#" id="code#currentrow#" value="#hierarchy#">
									</div>
								</td>
								<td nowrap="nowrap">
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
												<input type="hidden" name="partner_id#currentrow#" id="partner_id#currentrow#" value="#partner_id#">
											<span class="input-group-addon icon-ellipsis btnPointer" href="javascript://" onClick="pencere_ac1(#currentrow#);"></span>
										</div>
									</div>	
								</td>
								<td>
									<div class="form-group"> 
										<select name="role_id#currentrow#" id="role_id#currentrow#" >
										<option value=""><cf_get_lang dictionary_id ='38216.Rol Seçiniz'></option>
											<cfif get_roles.recordcount>
											<cfloop query="get_roles">
												<option value="#get_roles.PROJECT_ROLES_ID#" <cfif this_role_id eq get_roles.PROJECT_ROLES_ID>selected</cfif>>#get_roles.PROJECT_ROLES#</option>
											</cfloop>
											</cfif>
										</select>
									</div>
								</td>
								<cfif isdefined('is_project_team_price') and  is_project_team_price eq 1>
									<td>
										<cfif len(product_id)>
											<div class="form-group"> 
												<div class="input-group">
													<input type="text" value="#get_product_name(product_id)#" name="product#currentrow#" id="product#currentrow#" >
													<input type="hidden" name="stock_id#currentrow#" id="stock_id#currentrow#">
													<input type="hidden" name="product_id#currentrow#" id="product_id#currentrow#" value="#product_id#">&nbsp;<span class="input-group-addon icon-ellipsis btnPointer" href="javascript://" onClick="pencere_ac_product(#currentrow#);"></span>
												</div>
											</div>
										<cfelse>
											<div class="form-group"> 
												<div class="input-group">
													<input type="text" value="" name="product#currentrow#" id="product#currentrow#" >
													<input type="hidden" name="stock_id#currentrow#" id="stock_id#currentrow#">
													<input type="hidden" name="product_id#currentrow#" id="product_id#currentrow#" value="#product_id#">&nbsp;<span class="input-group-addon icon-ellipsis btnPointer" href="javascript://" onClick="pencere_ac_product(#currentrow#);"></span>
												</div>
											</div>
										</cfif>
									</td>
									<td><input type="text" name="unit_name#currentrow#" id="unit_name#currentrow#" value="#PRODUCT_UNIT#" readonly></td>
									<td><input type="text" class="moneybox" name="week_amount#currentrow#" id="week_amount#currentrow#" value="#WEEK_AMOUNT#" onKeyUp="isNumber(this)" validate="integer"></td>
									<td><input type="text" name="price#currentrow#" id="price#currentrow#" value="#TLFormat(cost_price)#"  onkeyup="return(FormatCurrency(this,event));" class="moneybox"></td>
									<td><input type="text" name="sales_price#currentrow#" id="sales_price#currentrow#" value="#TLFormat(product_unit_price)#"  onkeyup="return(FormatCurrency(this,event));" class="moneybox"></td>
									<td><select name="money_type#currentrow#" id="money_type#currentrow#">
											<cfloop query="get_money">
												<option value="#get_money.money#" <cfif get_money.money eq GET_EMPS.PRODUCT_MONEY>selected</cfif>>#get_money.money#</option>
											</cfloop>
										</select>
									</td>
								<cfelse>
									<cfif len(product_id)>
										<input type="hidden" name="stock_id#currentrow#" id="stock_id#currentrow#">
										<input type="hidden" name="product_id#currentrow#" id="product_id#currentrow#" value="#product_id#">
									<cfelse>
										<input type="hidden" name="stock_id#currentrow#" id="stock_id#currentrow#">
										<input type="hidden" name="product_id#currentrow#" id="product_id#currentrow#" value="#product_id#">
									</cfif>
									<input type="hidden" name="unit_name#currentrow#" id="unit_name#currentrow#" value="#PRODUCT_UNIT#" readonly>
									<input type="hidden" name="price#currentrow#" id="price#currentrow#" value="#TLFormat(product_unit_price)#"  onkeyup="return(FormatCurrency(this,event));" class="moneybox">
									<td><input type="text" name="sales_price#currentrow#" id="sales_price#currentrow#" value="#TLFormat(cost_price)#"  onkeyup="return(FormatCurrency(this,event));" class="moneybox"></td>
									<input type="hidden" name="money_type#currentrow#" id="money_type#currentrow#" value="#GET_EMPS.PRODUCT_MONEY#">
								</cfif>
							</tr>
						</cfoutput>
					</cfif>
				<tbody>
			</cf_grid_list>
			<input type="hidden" name="record" id="record" value="<cfoutput>#work_group_row#</cfoutput>">
			<cf_box_footer>
				<div class="col col-6 col-md-6 col-sm-6 col-xs-12">
					<cfif isdefined("get_emps")>
						<cf_record_info query_name="GET_EMPS">
					</cfif>
				</div>
				<div class="col col-6 col-md-6 col-sm-6 col-xs-12">
					<cfif ((isDefined("get_project_workgroup") and get_project_workgroup.recordcount) OR (isDefined("get_action_workgroup") AND get_action_workgroup.recordcount))>
						<cf_workcube_buttons is_upd='1' is_delete='0' add_function="kontrol()">
					<cfelse>
						<cf_workcube_buttons is_upd='0' is_delete='0' add_function="kontrol()">
					</cfif>	
				</div>
			</cf_box_footer>
		</cfform>
	</cf_box>	
</div>
<!--- calisanlar --->
<script type="text/javascript">
	row_count=<cfoutput>#work_group_row#</cfoutput>;
	function add_row_team(code)
	{
		if(code == undefined) code ="";
		row_count++;
		var newRow;
		var newCell;
		
		document.add_workgroup.record.value=row_count;

		newRow = document.getElementById("table1_workgroup").insertRow(document.getElementById("table1_workgroup").rows.length);
		newRow.setAttribute("name","workgroup_row" + row_count);
		newRow.setAttribute("id","workgroup_row" + row_count);
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<input type="hidden" value="1" name="row_kontrol' + row_count + '"><a onclick="remove_workgroup(' + row_count + ');"><i class="fa fa-minus" alt="<cf_get_lang dictionary_id ="57463.Sil">" title="<cf_get_lang dictionary_id ="57463.Sil">"></i></a>';
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<div class="form-group"> <input type="text" name="code'+ row_count +'" value="'+code+'"></div>';
				
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<div class="form-group"><div class="input-group"><input type="text" name="member_name'+ row_count +'" value="" readonly="yes" ><input type="hidden" name="consumer_id'+ row_count +'" value=""><input type="hidden" name="company_id'+ row_count +'" value=""><input type="hidden" name="partner_id'+ row_count +'" value=""><input type="hidden" name="member_type'+ row_count +'" value=""><input type="hidden" name="employee_id'+ row_count +'" value=""><span class="input-group-addon icon-ellipsis btnPointer" href="javascript://" onClick="pencere_ac1('+ row_count +');"></span></div></div>';
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<div class="form-group"> <select name="role_id'+ row_count +'" ><option value=""><cf_get_lang dictionary_id ="38216.Rol Seçiniz"></option><cfoutput query="get_roles"><option value="#get_roles.PROJECT_ROLES_ID#">#PROJECT_ROLES#</option></cfoutput></select></div>';
		
		<cfif isdefined('is_project_team_price') and is_project_team_price eq 1>
			
			newCell = newRow.insertCell(newRow.cells.length);
			newCell.innerHTML = '<div class="form-group"><div class="input-group"><input type="text" value="" name="product' + row_count +'" ><input type="hidden" name="stock_id' + row_count +'"><input type="hidden" name="product_id' + row_count +'">&nbsp;<span class="input-group-addon icon-ellipsis btnPointer" href="javascript://" onClick="pencere_ac_product(' + row_count + ');"></span></div></div>';

			newCell = newRow.insertCell(newRow.cells.length);
			newCell.innerHTML = '<input type="text" name="unit_name' + row_count +'" value="" readonly>';

			newCell = newRow.insertCell(newRow.cells.length);
			newCell.innerHTML = '<input type="text" name="week_amount' + row_count +'" id="week_amount' + row_count +'" value="" >';
			
			
			newCell = newRow.insertCell(newRow.cells.length);
			newCell.innerHTML = '<input type="text" class="moneybox" name="price' + row_count +'" value="" onkeyup="return(FormatCurrency(this,event));" >';

			newCell = newRow.insertCell(newRow.cells.length);
			newCell.innerHTML = '<input type="text" class="moneybox" name="sales_price' + row_count +'" value="" onkeyup="return(FormatCurrency(this,event));" >';

					
			newCell = newRow.insertCell(newRow.cells.length);
			newCell.innerHTML = '<select name="money_type' + row_count +'"><cfoutput query="get_money"><option value="#get_money.money#">#get_money.money#</option></cfoutput></select>';
		
		</cfif>
	}
	function pencere_ac1(no)
	{
		openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_list_positions&is_period_kontrol=0&field_consumer=add_workgroup.consumer_id'+no+'&field_comp_id=add_workgroup.company_id'+no+'&field_partner=add_workgroup.partner_id'+no+'&field_name=add_workgroup.member_name'+no+'&field_emp_id=add_workgroup.employee_id'+no+'&field_type=add_workgroup.member_type'+no+'&select_list=1,2,3'</cfoutput>);
	}
	function pencere_ac2(no)
	{
		openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_list_position_names&is_period_kontrol=0&field_name=add_workgroup.role_head'+no+'</cfoutput>','List');
	}
	function pencere_ac_product(no)
	{
		openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_product_price_unit&field_stock_id=add_workgroup.stock_id'+ no +'&field_id=add_workgroup.product_id'+ no +'&field_name=add_workgroup.product'+ no +'&field_unit=add_workgroup.unit_name'+ no+'&field_price=add_workgroup.price'+ no+'&field_money=add_workgroup.money_type'+ no +''</cfoutput>);
	}
		function remove_workgroup(no)
		{
			var my_element=eval("add_workgroup.row_kontrol"+no);		
			my_element.value=0;
			
			var my_element=document.getElementById("workgroup_row"+no);
			my_element.style.display="none";
		}

	function kontrol()
	{
	if(row_count==0)
		{
			alert("<cf_get_lang dictionary_id ='38410.En Az Bir Grup Çalışan Kaydı Giriniz'>!");
			return false;
		}
		for(row_=1;row_<=row_count;row_++)
		{
			if(eval("document.add_workgroup.row_kontrol"+row_).value == 1)
			{
				_member_name=eval("document.add_workgroup.member_name"+row_);
				_code_ = eval("document.add_workgroup.code"+row_);
				<cfif isdefined('is_project_team_price') and is_project_team_price eq 1>
					_product=eval("document.add_workgroup.product"+row_);
				</cfif>
				
				_role_id=eval("document.add_workgroup.role_id"+row_);
					
				if(_member_name.value=="")
				{
					alert("<cf_get_lang dictionary_id='58194.Zorunlu Alan'> : <cf_get_lang dictionary_id ='57569.Görevli'>");
					return false;
				}
				if(_code_.value == ""){
					alert("<cf_get_lang dictionary_id='58194.Zorunlu Alan'> : <cf_get_lang dictionary_id ='58585.Kod'>	");
					return false;
				}
				<cfif isdefined('is_required_project_roles') and is_required_project_roles eq 1>
					if(_role_id.value == "")
					{
						alert("<cf_get_lang dictionary_id='58194.Zorunlu Alan'> : <cf_get_lang dictionary_id ='38182.Rol'>");
						return false;
					}
				</cfif>
				<cfif isdefined('is_project_team_price') and (is_project_team_price eq 1) and (is_required_product eq 1)>
					if(_product.value=="" && eval("document.add_workgroup.member_type"+row_).value == 'employee')
					{
						alert("<cf_get_lang dictionary_id='58194.Zorunlu Alan'> : <cf_get_lang dictionary_id ='38408.Hizmet Ürün'>");
						return false;
					}
				</cfif>
			}
			for(ic_row_=1;ic_row_<=row_count;ic_row_++)
			{
				if(row_ != ic_row_){	
					if(eval("document.add_workgroup.code"+row_).value == eval("document.add_workgroup.code"+ic_row_).value){
						alert(eval("document.add_workgroup.code"+row_).value+' - '+eval("document.add_workgroup.code"+ic_row_).value+" <cf_get_lang dictionary_id = '58585.Kod'> <cf_get_lang dictionary_id = '58564.Var'>!");
						return false;
					}
				}
			}
		}
		<cfif isdefined("attributes.draggable")>
			loadPopupBox('add_workgroup' , <cfoutput>#attributes.modal_id#</cfoutput>);
			return false;
		</cfif>
	}
</script>
