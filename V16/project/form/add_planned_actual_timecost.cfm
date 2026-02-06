<cf_xml_page_edit fuseact="project.popup_add_planned_actual_timecost">
<!--- İşe kayıtlı zaman harcaması kaydı var ise eger defult olarak kayıtlı olan employeeleri getirmek icin eklendi MT --->
<cfif isdefined("attributes.id")>
	<cfquery name="get_history" datasource="#dsn#">
       SELECT 
            SUM(TOTAL_TIME_HOUR1) AS TOTAL_TIME_HOUR1,
            SUM(TOTAL_TIME_MINUTE1)  AS TOTAL_TIME_MINUTE1,
            EMPLOYEE_ID,
            EMPLOYEE_NAME AS EMPLOYEE_NAME,
            FINISH_DATE AS FINISH_DATE,
            COMMENT AS COMMENT,
            OVERTIME_TYPE AS OVERTIME_TYPE,
            DEPARTMENT_ID AS DEPARTMENT_ID,
            BRANCH_ID AS BRANCH_ID,
            PRODUCT_NAME AS PRODUCT_NAME,
            PRODUCT_ID AS PRODUCT_ID
        FROM 
            (
                SELECT  
                        SUM(TOTAL_TIME_HOUR1) AS TOTAL_TIME_HOUR1, 
                        SUM(TOTAL_TIME_MINUTE1) AS TOTAL_TIME_MINUTE1, 
                        TIME_COST_PLANNED.EMPLOYEE_ID AS EMPLOYEE_ID,
                        TIME_COST_PLANNED.EMPLOYEE_NAME AS EMPLOYEE_NAME,
                        TIME_COST_PLANNED.FINISH_DATE AS FINISH_DATE,
                        TIME_COST_PLANNED.COMMENT AS COMMENT,
                        TIME_COST_PLANNED.OVERTIME_TYPE AS OVERTIME_TYPE,
                        EP.DEPARTMENT_ID AS DEPARTMENT_ID,
                        EP.BRANCH_ID AS BRANCH_ID,
                        P.PRODUCT_NAME AS PRODUCT_NAME,
                        P.PRODUCT_ID AS PRODUCT_ID
                FROM 
                        TIME_COST_PLANNED 
                        LEFT JOIN EMPLOYEE_POSITIONS EP ON TIME_COST_PLANNED.EMPLOYEE_ID = EP.EMPLOYEE_ID
                        LEFT JOIN #DSN3_ALIAS#.PRODUCT P ON TIME_COST_PLANNED.PRODUCT_ID = P.PRODUCT_ID
                WHERE 
                        WORK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#url.id#">
                        AND EP.IS_MASTER = 1
                GROUP BY 
                        TIME_COST_PLANNED.EMPLOYEE_ID,
                        TIME_COST_PLANNED.EMPLOYEE_NAME,
                        TIME_COST_PLANNED.FINISH_DATE,
                        TIME_COST_PLANNED.COMMENT,
                        TIME_COST_PLANNED.OVERTIME_TYPE,
                        EP.DEPARTMENT_ID,
                        EP.BRANCH_ID,
                        P.PRODUCT_NAME,
                        P.PRODUCT_ID
            ) AS T1 
        GROUP BY 
            EMPLOYEE_ID,
            EMPLOYEE_NAME,
            FINISH_DATE,
            COMMENT,
            OVERTIME_TYPE,
            DEPARTMENT_ID,
            BRANCH_ID,
            PRODUCT_NAME,
            PRODUCT_ID
		ORDER BY
			FINISH_DATE	ASC	
    </cfquery>
<cfelse>
	<cfset get_history.recordcount = 0>
</cfif>
<!--- İşe kayıtlı zaman harcaması kaydı var ise eger defult olarak kayıtlı olan employeeleri getirmek icin eklendi MT --->
<cfquery name="ALL_BRANCHES" datasource="#DSN#">
	SELECT 
		BRANCH.BRANCH_NAME,
		BRANCH.BRANCH_ID,
		D.DEPARTMENT_HEAD,
		D.DEPARTMENT_ID
	FROM
		BRANCH,
		DEPARTMENT D
	WHERE
		D.BRANCH_ID = BRANCH.BRANCH_ID AND
		BRANCH.SSK_NO IS NOT NULL AND
		BRANCH.SSK_OFFICE IS NOT NULL AND
		BRANCH.SSK_BRANCH IS NOT NULL AND
		BRANCH.SSK_NO IS NOT NULL AND
		BRANCH.SSK_OFFICE IS NOT NULL AND
		BRANCH.SSK_BRANCH IS NOT NULL
		AND BRANCH.BRANCH_ID IN 
		(
            SELECT
                BRANCH_ID
            FROM
                EMPLOYEE_POSITION_BRANCHES
            WHERE
                POSITION_CODE = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.position_code#">
		)
	ORDER BY
		BRANCH.BRANCH_NAME
</cfquery>
<cfparam name="attributes.modal_id" default="">
	<cf_box title="#getLang('','Planlanan Zaman Harcaması Ekle',60364)#" scroll="1" collapsable="1" resize="1" popup_box="#iif(isdefined("attributes.draggable"),1,0)#">
		<cfform name="add_worktime" method="post" action="#request.self#?fuseaction=project.emptypopup_add_planned_actual_timecost">
			<input type="hidden" name="record_num" id="record_num" value="1">
			<input type="hidden" name="work_id" id="work_id" value="<cfoutput>#attributes.id#</cfoutput>">
			<input type="hidden" name="history_id" id="history_id" value="<cfoutput>#attributes.history_id#</cfoutput>">
			<input type="hidden" name="x_timecost_limited" id="x_timecost_limited" value="<cfif isdefined('x_timecost_limited') and x_timecost_limited eq 1>1<cfelse>0</cfif>">
			<cf_basket>
				<cf_box_search>
					<cfloop list="#ListDeleteDuplicates(xml_timecost_rows)#" index="xlr">
						<cfswitch expression="#xlr#">
							<cfcase value="1">
							<div class="form-group">
								<label><cf_get_lang dictionary_id='57453.Şube'>/<cf_get_lang dictionary_id='57572.Departman'></label>
								<div class="input-group">
									<select name="department_id" id="department_id" onchange="if (this.options[this.selectedIndex].value != 'null')">
										<option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
										<cfoutput query="ALL_BRANCHES">
											<option value="#request.self#?fuseaction=myhome.popup_add_timecost_project_all&department_id=#department_id#<cfif isdefined('attributes.id') and len(attributes.id)>&id=#attributes.id#</cfif><cfif isdefined('attributes.finish_date') and len(attributes.finish_date)>&finish_date=#attributes.finish_date#</cfif><cfif isdefined('attributes.result_no') and len(attributes.result_no)>&result_no=#attributes.result_no#</cfif><cfif isdefined('attributes.production_order_no') and len(attributes.production_order_no)>&production_order_no=#attributes.production_order_no#</cfif><cfif isdefined('attributes.comp_id') and len(attributes.comp_id)>&comp_id=#attributes.comp_id#</cfif><cfif isdefined('attributes.cons_id') and len(attributes.cons_id)>&cons_id=#attributes.cons_id#</cfif><cfif isdefined('attributes.partner_id') and len(attributes.partner_id)>&partner_id=#attributes.partner_id#</cfif>"<cfif isdefined("attributes.department_id") and (department_id eq attributes.department_id)>selected</cfif>>
												#branch_name# - #department_head#
											</option>
										</cfoutput>
									</select>
								</div>
							</div>
							</cfcase>
							<cfcase value="2">
								<div class="form-group">
									<label><cf_get_lang dictionary_id ='57657.Ürün'></label>
									<div class="input-group">
										<input name="product_id0" id="product_id0" type="hidden" value="">
										<input name="product_name0" id="product_name0" type="text" value="">
										<span class="input-group-addon btnPointer icon-ellipsis" onClick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_product_names&product_id=add_worktime.product_id0&field_name=add_worktime.product_name0');"></span>
									</div>
								</div>
							</cfcase>
							<cfcase value="3">
								<div class="form-group">
									<label><cf_get_lang dictionary_id='57629.Açıklama'></label>
									<div class="input-group">
										<input type="text" name="comment0" id="comment0" value="<cfif isdefined('attributes.result_no') and len(attributes.result_no)>#attributes.result_no#</cfif>">
									</div>
								</div>
							</cfcase>
							<cfcase value="4">
									<div class="form-group">
										<label><cf_get_lang dictionary_id='57742.Tarih'></label>
										<div class="input-group">
											<input type="hidden" name="row_kontrol_0" id="row_kontrol_0" value="1">						
											<input type="text" name="today0" id="today0" vertical-align:top; value="<cfif isdefined('attributes.finish_date') and len(attributes.finish_date)>#dateformat(attributes.finish_date,dateformat_style)#</cfif>" maxlength="10">
											<span class="input-group-addon btnPointer"><cf_wrk_date_image date_field="today0" call_function="tarih_hepsi"></span>
										</div>
									</div>
							</cfcase>
							<cfcase value="5">
								<div class="form-group small">
									<label><cf_get_lang dictionary_id='57491.Saat'></label>
									<div class="input-group">
										<cfif isdefined('x_timecost_limited') and x_timecost_limited eq 0>
											<cfinput type="text" name="total_time_hour0" id="total_time_hour0" maxlength="2" validate="integer" value="">
										<cfelse>
											<cfinput type="text" name="total_time_hour0" id="total_time_hour0" validate="integer" value="">
										</cfif>
									</div>
								</div>
							</cfcase>
							<cfcase value="6">
								<div class="form-group small">
									<label><cf_get_lang dictionary_id='58827.Dk'>.</label>
									<div class="input-group">
										<cfinput type="text" name="total_time_minute0" id="total_time_minute0" maxlength="2" validate="integer" value="">
									</div>
								</div>
							</cfcase>
							<cfcase value="7">
								<div class="form-group">
									<label><cf_get_lang dictionary_id='58543.Mesai Tipi'></label>
									<div class="input-group">
										<select name="overtime_type0" id="overtime_type0">
											<option value="1"><cf_get_lang dictionary_id="38172.Normal"></option>
											<option value="2"><cf_get_lang dictionary_id="38224.Fazla Mesai"></option>
											<option value="3"><cf_get_lang dictionary_id="38245.Hafta Sonu"></option>
											<option value="4"><cf_get_lang dictionary_id="38246.Resmi Tatil"></option>
										</select>
									</div>
								</div>
							</cfcase>
						</cfswitch>
					</cfloop>
				</cf_box_search>
				<cf_grid_list>
					<thead>
						<tr>
							<th width="20"><a onClick="add_row_exit();"><i class="fa fa-plus" title="<cf_get_lang dictionary_id='57582.Ekle'>" alt="<cf_get_lang dictionary_id='57582.Ekle'>"></i></a></th>
							<!--- Satirlardaki Veriler Degisken Olarak Geliyor --->
							<cfloop list="#ListDeleteDuplicates(xml_timecost_rows)#" index="xlr">
								<cfswitch expression="#xlr#">
									<cfcase value="1">
										<th><cf_get_lang dictionary_id='57576.Çalışan'></th>
										<th><cf_get_lang dictionary_id='57453.Şube'>/<cf_get_lang dictionary_id='57572.Departman'></th>
									</cfcase>
									<cfcase value="2"><th><cf_get_lang dictionary_id='57657.Ürün'></th></cfcase>
									<cfcase value="3"><th><cf_get_lang dictionary_id='57629.Açıklama'></th></cfcase>
									<cfcase value="4"><th><cf_get_lang dictionary_id='57742.Tarih'></th></cfcase>
									<cfcase value="5"><th><cf_get_lang dictionary_id='57491.Saat'></th></cfcase>
									<cfcase value="6"><th><cf_get_lang dictionary_id='58827.Dk'>.</th></cfcase>
									<cfcase value="7"><th><cf_get_lang dictionary_id='58543.Mesai Tipi'></th></cfcase>
								</cfswitch>
							</cfloop>
						</tr>
					</thead>
					<tbody id="link_table">
						<cfif get_history.recordcount>
							<cfoutput query="get_history">
								<tr id="my_row_#currentrow#">
									<td nowrap="nowrap">
										<input type="hidden" value="#currentrow#" name="row_kontrol_#currentrow#" id="row_kontrol_#currentrow#">
										<ul class="ui-icon-list">
											<li><a onclick="sil(#currentrow#);"><i class="fa fa-minus" title="<cf_get_lang dictionary_id='57463.Sil'>"></i></a></li>
											<li><a onclick="copy_row_exit('#currentrow#');" title="<cf_get_lang dictionary_id='58972.Satır Kopyala'>"><i class="fa fa-copy" title="<cf_get_lang dictionary_id="58972.Satır Kopyala">"></i></a></li>
										</ul>
									</td>
									<cfloop list="#ListDeleteDuplicates(xml_timecost_rows)#" index="xlr">
										<cfswitch expression="#xlr#">
											<cfcase value="1">
												<td nowrap="nowrap">
													<div class="form-group"> 
														<div class="input-group">
															<input type="hidden" name="employee_id#currentrow#" id="employee_id#currentrow#" value="#employee_id#">
															<input type="text" name="employee#currentrow#" id="employee#currentrow#" value="#employee_name#" onkeyup="id_to_empty(#currentrow#);" onFocus="AutoComplete_Create('employee#currentrow#','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','\'3\',0,0','EMPLOYEE_ID,BRANCH_DEPT','employee_id#currentrow#,department#currentrow#','add_worktime','3','250');" autocomplete="off">
															<span class="input-group-addon icon-ellipsis btnPointer" href="javascript:openBoxDraggable('#request.self#?fuseaction=objects.popup_list_positions&field_emp_id=add_worktime.employee_id#currentrow#&field_name=add_worktime.employee#currentrow#&field_branch_and_dep=add_worktime.department#currentrow#&select_list=1');"><img border="0" align="absmiddle"></span>
														</div>
													</div>
												</td>
												<cfquery name="GET_DEPARTMENT_" datasource="#DSN#">
													SELECT
														D.DEPARTMENT_HEAD,
														D.DEPARTMENT_ID,
														B.BRANCH_NAME
													FROM
														DEPARTMENT D,
														BRANCH B
													WHERE 
														DEPARTMENT_ID = #DEPARTMENT_ID# 
														AND D.BRANCH_ID = B.BRANCH_ID
												</cfquery>
												<td>
													<div class="form-group">
														<input type="text" name="department#currentrow#" id="department#currentrow#" readonly value="#GET_DEPARTMENT_.branch_name# / #GET_DEPARTMENT_.department_head#">
													</div>
												</td>
											</cfcase>
											<cfcase value="2">
												<td nowrap="nowrap">
													<div class="form-group"> 
														<div class="input-group">
															<input type="hidden" name="product_id#currentrow#" id="product_id#currentrow#" value="#PRODUCT_ID#">
															<input type="text" name="product_name#currentrow#" id="product_name#currentrow#" value="#PRODUCT_NAME#"  onfocus="AutoComplete_Create('product_name#currentrow#','PRODUCT_NAME','PRODUCT_NAME','get_product_autocomplete','0','PRODUCT_ID','product_id#currentrow#','','3','130');" autocomplete="off">
															<span class="input-group-addon icon-ellipsis btnPointer" href="javascript://" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_product_names&product_id=add_worktime.product_id#currentrow#&field_name=add_worktime.product_name#currentrow#&keyword='+encodeURIComponent(document.add_worktime.product_name#currentrow#.value));"></span>
														</div>
													</div>	
												</td>
											</cfcase>
											<cfcase value="3">
												<td><div class="form-group"> <input type="text" name="comment#currentrow#" id="comment#currentrow#" maxlength="300" value="#COMMENT#"></div></td>
											</cfcase>
											<cfcase value="4">
												<td nowrap="nowrap">
													<div class="form-group"> 
														<div class="input-group">						
															<input type="text" name="today#currentrow#" id="today#currentrow#" value="<cfif isdefined('finish_date') and len(finish_date)>#dateformat(finish_date,dateformat_style)#</cfif>" maxlength="10">
															<span class="input-group-addon"><cf_wrk_date_image date_field="today#currentrow#"></span>
														</div>
													</div>
												</td>
											</cfcase>
											<cfcase value="5">
												<td>
													<cfset total_time_1 = get_history.total_time_hour1 * 60>
													<cfset minute_1 = total_time_1 / 60>
													<cfset total_time_2 = get_history.total_time_minute1 * 60>
													<cfset minute_2 = total_time_2 / 60>
													<cfset total_time_end = total_time_1 + total_time_minute1>
													<cfset totaltime_ = total_time_end mod 60>
													<div class="form-group"> 
														<cfif isdefined('x_timecost_limited') and x_timecost_limited eq 0>
															<cfinput type="text" name="total_time_hour#currentrow#" id="total_time_hour#currentrow#" maxlength="2" validate="integer" value="#((total_time_end - totaltime_)/60)#">
														<cfelse>
															<cfinput type="text" name="total_time_hour#currentrow#" id="total_time_hour#currentrow#" validate="integer" value="#((total_time_end - totaltime_)/60)#">
														</cfif>
													</div>
												</td>
											</cfcase>
											<cfcase value="6">
												<td><div class="form-group"><cfinput type="text" name="total_time_minute#currentrow#" id="total_time_minute#currentrow#" maxlength="2" validate="integer" value="#totaltime_#"></div></td>
											</cfcase>
											<cfcase value="7">
												<td>
													<div class="form-group"> 
														<select name="overtime_type#currentrow#" id="overtime_type#currentrow#">
															<option value="1" <cfif overtime_type eq 1>selected</cfif>><cf_get_lang dictionary_id="38172.Normal"></option>
															<option value="2" <cfif overtime_type eq 2>selected</cfif>><cf_get_lang dictionary_id="38224.Fazla Mesai"></option>
															<option value="3" <cfif overtime_type eq 3>selected</cfif>><cf_get_lang dictionary_id="38245.Hafta Sonu"></option>
															<option value="4" <cfif overtime_type eq 4>selected</cfif>><cf_get_lang dictionary_id="38246.Resmi Tatil"></option>
														</select>
													</div>
												</td>
											</cfcase>
										</cfswitch>
									</cfloop>
								</tr>
							</cfoutput>
						</cfif>
					</tbody>
				</cf_grid_list>
			</cf_basket>
			<cf_box_footer>
				<cf_workcube_buttons type_format="1" is_upd='0' add_function="kontrol()">
			</cf_box_footer>
		</cfform>
	</cf_box>
<script type="text/javascript">
	<cfif get_history.recordcount>
		row_count = <cfoutput>#get_history.recordcount#</cfoutput>;
	<cfelse>
		row_count=1;
	</cfif>
	function tarih_hepsi()
	{
		hepsi(row_count,'today');	
	}
	function sil(sy)
	{
		var my_element=eval("add_worktime.row_kontrol_"+sy);
		my_element.value=0;
		var my_element=eval("my_row_"+sy);
		my_element.style.display="none";
	}	
	function add_row_exit(row_kontrol_,employee_id,employee,department,product_id,product_name,comment,today,total_time_hour,total_time_minute,overtime_type)
	{
		if(row_kontrol_ != undefined)
		{
			employee_id_ = employee_id;
			employee_ = employee;
			department_ = department;
			product_id_ = product_id;
			product_name_ = product_name;
			comment_ = comment;
			today_ = today;
			total_time_hour_ = total_time_hour;
			total_time_minute_ = total_time_minute;
			overtime_type_ = overtime_type;
		}
		else
		{
			employee_id_ = '';
			employee_ = '';
			department_ = '';
			product_id_ = '';
			product_name_ = '';
			comment_ = '';
			today_ = '';
			total_time_hour_ = '';
			total_time_minute_ = '';
			overtime_type_ = '';
		}
		row_count++;
		var newRow;
		var newCell;
		
		newRow = document.getElementById("link_table").insertRow(document.getElementById("link_table").rows.length);
		newRow.setAttribute("name","my_row_" + row_count);
		newRow.setAttribute("id","my_row_" + row_count);		
		newRow.setAttribute("NAME","my_row_" + row_count);
		newRow.setAttribute("ID","my_row_" + row_count);		
					
		document.add_worktime.record_num.value=row_count;
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<ul class="ui-icon-list"><li><a onclick="sil(' + row_count + ');"><i class="fa fa-minus" title="<cf_get_lang dictionary_id='57463.Sil'>"></i></a></li><li><a onclick="copy_row_exit('+row_count+');" title="<cf_get_lang dictionary_id="58972.Satır Kopyala">"><i class="fa fa-copy" title="<cf_get_lang dictionary_id="58972.Satır Kopyala">"></i></a></li></ul>';	
		<cfloop list="#ListDeleteDuplicates(xml_timecost_rows)#" index="xlr">
			<cfswitch expression="#xlr#">
				<cfcase value="1">
					newCell = newRow.insertCell(newRow.cells.length);
					newCell.setAttribute("nowrap","nowrap");
					newCell.innerHTML = '<div class="form-group"><div class="input-group"><input type="hidden" value="'+employee_id_+'" name="employee_id' + row_count +'" id="employee_id' + row_count +'"><input type="text" onKeyup="id_to_empty(' + row_count + ');" name="employee' + row_count +'" id="employee' + row_count +'" value="'+employee_+'" onFocus="AutoComplete_Create(\'employee'+ row_count +'\',\'MEMBER_NAME\',\'MEMBER_PARTNER_NAME3\',\'get_member_autocomplete\',\'3\',\'EMPLOYEE_ID,BRANCH_DEPT\',\'employee_id' + row_count +',department' + row_count +'\',\'add_worktime\',3,116);"><span class="input-group-addon icon-ellipsis btnPointer" href="javascript://" onClick="openBoxDraggable(\'<cfoutput>#request.self#?fuseaction=objects.popup_list_positions</cfoutput>&field_name=add_worktime.employee'+ row_count + '&field_emp_id=add_worktime.employee_id'+ row_count + '&field_branch_and_dep=add_worktime.department'+ row_count + '&select_list=1\');"><img border="0" align="absbottom"></span></div></div>';
					newCell = newRow.insertCell(newRow.cells.length);
					newCell.innerHTML = '<div class="form-group"><input name="department'+row_count+'" id="department'+row_count+'" type="text" readonly value="'+department_+'"></div>';
				</cfcase>
				<cfcase value="2">
					newCell = newRow.insertCell(newRow.cells.length);
					newCell.setAttribute('nowrap','nowrap');
					newCell.innerHTML = '<div class="form-group"><div class="input-group"><input name="product_id'+row_count+'" id="product_id'+row_count+'" type="hidden" value="'+product_id_+'"><input name="product_name'+row_count+'" id="product_name'+row_count+'" type="text" value="'+product_name_+'" onFocus="AutoComplete_Create(\'product_name' + row_count +'\',\'PRODUCT_NAME\',\'PRODUCT_NAME\',\'get_product_autocomplete\',\'0\',\'PRODUCT_ID\',\'product_id' + row_count +'\',\'add_worktime\',1);"><span class="input-group-addon icon-ellipsis btnPointer" href="javascript://" onClick="openBoxDraggable(\'<cfoutput>#request.self#?fuseaction=objects.popup_product_names</cfoutput>&product_id=add_worktime.product_id'+ row_count +'&field_name=add_worktime.product_name'+ row_count + '\');"></span></div></div>';
				</cfcase>
				<cfcase value="3">
					newCell = newRow.insertCell(newRow.cells.length);
					newCell.setAttribute('nowrap','nowrap');
					newCell.innerHTML = '<div class="form-group"><input type="text" name="comment' + row_count +'" id="comment' + row_count +'" maxlength="300" value="'+comment_+'"></div>';
				</cfcase>
				<cfcase value="4">
					newCell = newRow.insertCell(newRow.cells.length);
					newCell.setAttribute('nowrap','nowrap');
					newCell.setAttribute("id","today" + row_count + "_td");
					newCell.innerHTML = '<div class="form-group"><div class="input-group"><input  type="hidden" value="1" name="row_kontrol_' + row_count +'" id="row_kontrol_' + row_count +'"><input type="text" name="today' + row_count +'" id="today' + row_count +'" class="text" maxlength="10" value="'+today_+'"><span class="input-group-addon btnPointer" id="edate_'+row_count+'"></span></div></div>';
					wrk_date_image('today' + row_count);
					$('#edate_'+row_count).append($('#today'+row_count+'_image'));
				</cfcase>
				<cfcase value="5">
					newCell = newRow.insertCell(newRow.cells.length);
					newCell.setAttribute('nowrap','nowrap');
					newCell.innerHTML = '<div class="form-group"><input type="text" name="total_time_hour' + row_count +'" id="total_time_hour' + row_count +'" value="'+total_time_hour_+'" <cfif isdefined('x_timecost_limited') and x_timecost_limited eq 0>maxlength="2"</cfif> validate="integer" onKeyup="return(FormatCurrency(this,event,0));"></div>';
				</cfcase>
				<cfcase value="6">
					newCell = newRow.insertCell(newRow.cells.length);
					newCell.setAttribute('nowrap','nowrap');
					newCell.innerHTML = '<div class="form-group"><input type="text" name="total_time_minute' + row_count +'" id="total_time_minute' + row_count +'" value="'+total_time_minute_+'" maxlength="2" validate="integer" range="0,59" onKeyup="return(FormatCurrency(this,event,0));"></div>';
				</cfcase>
				<cfcase value="7">
					newCell = newRow.insertCell(newRow.cells.length);
					newCell.setAttribute('nowrap','nowrap');
					c = '<div class="form-group"><select name="overtime_type' + row_count +'" id="overtime_type' + row_count +'">';
					if(1 == overtime_type_) c += '<option value="1" selected>Normal</option>'; else c += '<option value="1">Normal</option>';
					if(2 == overtime_type_) c += '<option value="2" selected>Fazla Mesai</option>'; else c += '<option value="2">Fazla Mesai</option>';
					if(3 == overtime_type_) c += '<option value="3" selected>Hafta Sonu</option>'; else c += '<option value="3">Hafta Sonu</option>';
					if(4 == overtime_type_) c += '<option value="4" selected>Resmi Tatil</option>'; else c += '<option value="4">Resmi Tatil</option>';
					newCell.innerHTML =c+ '</select></div>';
				</cfcase>
			</cfswitch>
		</cfloop>
	}
	function copy_row_exit(no_info)
	{
		if (document.getElementById("row_kontrol_" + no_info) == undefined) row_kontrol_ =""; else row_kontrol_ = document.getElementById("row_kontrol_" + no_info).value;
		if (document.getElementById("employee_id" + no_info) == undefined) employee_id =""; else employee_id = document.getElementById("employee_id" + no_info).value;
		if (document.getElementById("employee" + no_info) == undefined) employee =""; else employee = document.getElementById("employee" + no_info).value;
		if (document.getElementById("department" + no_info) == undefined) department =""; else department = document.getElementById("department" + no_info).value;
		if (document.getElementById("product_id" + no_info) == undefined) product_id =""; else product_id = document.getElementById("product_id" + no_info).value;
		if (document.getElementById("product_name" + no_info) == undefined) product_name =""; else product_name = document.getElementById("product_name" + no_info).value;
		if (document.getElementById("comment" + no_info) == undefined) comment =""; else comment = document.getElementById("comment" + no_info).value;
		if (document.getElementById("today" + no_info) == undefined) today =""; else today = document.getElementById("today" + no_info).value;
		if (document.getElementById("total_time_hour" + no_info) == undefined) total_time_hour =""; else total_time_hour = document.getElementById("total_time_hour" + no_info).value;
		if (document.getElementById("total_time_minute" + no_info) == undefined) total_time_minute =""; else total_time_minute = document.getElementById("total_time_minute" + no_info).value;
		if (document.getElementById("overtime_type" + no_info) == undefined) overtime_type =""; else overtime_type = document.getElementById("overtime_type" + no_info).value;
		add_row_exit(row_kontrol_,employee_id,employee,department,product_id,product_name,comment,today,total_time_hour,total_time_minute,overtime_type);
 	}

	function id_to_empty(sayac_)	<!--- isme göre kayıt yapılırken employee_id hiddeının boşaltılması amaçlı --->
	{
		if(eval("document.add_worktime.employee"+sayac_).value.length == 0)
		{
			eval("document.add_worktime.employee_id"+sayac_).value = '';
		}
	}
	function kontrol()
	{   
		document.add_worktime.record_num.value=row_count;
		if(row_count == 0)
		{
			alert("<cf_get_lang dictionary_id='31904.Toplu Zaman Harcaması Girişi Yapmadınız'>");
			return false;
		}
		<cfif isdefined("attributes.draggable")>
            loadPopupBox('add_worktime' , <cfoutput>#attributes.modal_id#</cfoutput>);
            return false;
       	<cfelse>
           	return true;
        </cfif>
		if(row_count != 0)
			{
			for(i=1;i<=add_worktime.record_num.value;i++)
			{
				deger_row_kontrol = eval("document.add_worktime.row_kontrol_"+i);
				deger_employee = eval("document.add_worktime.employee_id"+i);
				deger_employee_name = eval("document.add_worktime.employee"+i);
				deger_comment = eval("document.add_worktime.comment"+i);
				deger_total_time_hour = eval("document.add_worktime.total_time_hour"+i);
				deger_total_time_minute = eval("document.add_worktime.total_time_minute"+i);
				deger_today = eval("document.add_worktime.today"+i);
			
				if(eval("document.add_worktime.row_kontrol_"+i).value == 1)
				{
					if (deger_employee.value == "" && deger_employee_name.value=="")
					{
						alert ("<cf_get_lang dictionary_id='46197.Lütfen Çalışan Seçiniz'> !");
						return false;
					}
					
					if (deger_total_time_hour.value == "" && deger_total_time_minute.value == "")
					{ 
						alert ("<cf_get_lang dictionary_id='31630.Lütfen Süre Giriniz'> !");
						return false;
					}
				}
			}
		}
		for(var j=0;j<=row_count;j++)
		{
			tarih_nesne=eval("document.all.today"+j);
			if(!CheckEurodate(tarih_nesne.value,j+'. Tarih'))
			{ 
				tarih_nesne.focus();
				return false;
			}
		}
	}		
</script>
