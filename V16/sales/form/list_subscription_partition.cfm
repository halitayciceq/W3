<!--- 
Bu sayfanın bir versiyonu da add_options ta vardır,pronet için değişiklik yapılmıştır, 
burda yaptığınız genel değişiklikleri o sayfada da yapmanız rica olunur... Ayşenur20060913
<cfinclude template="../../add_options/form/list_subscription_partition.cfm">
 --->
<cfquery name="GET_PARTITION" datasource="#DSN3#">
	SELECT 
    	PARTITION_ID, 
        SUBSCRIPTION_ID, 
        PARTITION_NUMBER, 
        PARTITION_START_DATE, 
        PARTITION_DETAIL, 
        RECORD_EMP, 
        RECORD_IP, 
        RECORD_DATE, 
        UPDATE_EMP, 
        UPDATE_IP, 
        UPDATE_DATE 
    FROM 
	    SUBSCRIPTION_CONTRACT_PARTITION 
    WHERE 
    	SUBSCRIPTION_ID = #url.subscription_id#
</cfquery>
<cfset partition_row = get_partition.recordcount>
<cfparam name="attributes.modal_id" default="">
<cf_box title="#getLang('','Partition Detay',41132)#" scroll="1" collapsable="1" resize="1" popup_box="#iif(isdefined("attributes.draggable"),1,0)#">
	<cfform name="list_partition" method="post" action="#request.self#?fuseaction=sales.emptypopup_add_partition">
		<input type="hidden" name="subscription_id" id="subscription_id" value="<cfoutput>#url.subscription_id#</cfoutput>">
        <cf_grid_list name="table2" id="table2">
			<thead>
                <tr>
                    <th width="20"><input name="record_num" id="record_num" type="hidden" value="0"><a onClick="add_row();"><i class="fa fa-plus" title="<cf_get_lang dictionary_id='57582.Ekle'>"></i></a></th>
                    <th width="20"></th>
                    <th><cf_get_lang dictionary_id='57487.No'> *</th>
                    <th width="170"><cf_get_lang dictionary_id='41133.Kur Tarihi'> *</th>
                    <th><cf_get_lang dictionary_id='57629.Açıklama'></th>
                </tr>
            </thead>
            <tbody>
				<cfif get_partition.recordcount>
                    <cfoutput query="get_partition">
                        <tr id="frm_row#currentrow#">
                            <td class="text-center">
								<div class="form-group">
									<input type="hidden" value="1" name="row_kontrol#currentrow#" id="row_kontrol#currentrow#">
									<input type="hidden" name="partition_id#currentrow#" id="partition_id#currentrow#" value="#partition_id#">
									<a onClick="sil(#currentrow#);"><i class="fa fa-minus" title="<cf_get_lang dictionary_id='57463.Sil'>" alt="<cf_get_lang dictionary_id='57463.Sil'>"></i></a>
								</div>	
                            </td>
                            <td width="20" class="text-right">A - </td>
                            <td>
								<div class="form-group">
									<input type="text" name="partition_number#currentrow#" id="partition_number#currentrow#" value="#Replace(get_partition.partition_number,"A-","")#" maxlength="28">
								</div>
							</td>
                            <td>
								<div class="form-group">
									<div class="input-group">
										<input type="text" name="partition_start_date#currentrow#" id="partition_start_date#currentrow#" value="#dateformat(get_partition.partition_start_date,dateformat_style)#" maxlength="10">
										<span class="input-group-addon"><cf_wrk_date_image date_field="partition_start_date#currentrow#"></span>
									</div>
								</div>
							</td>
                            <td>
								<div class="form-group">
									<input type="text" name="partition_detail#currentrow#" id="partition_detail#currentrow#" value="#get_partition.partition_detail#" maxlength="50">
								</div>
							</td>
                        </tr>
                    </cfoutput>
                </cfif>
            </tbody>			  
		</cf_grid_list>
		<cf_box_footer>
        	<cf_record_info query_name="get_partition">
			<cfif get_partition.recordcount>
				<cf_workcube_buttons is_upd='1' is_delete='0' add_function="#iif(isdefined("attributes.draggable"),DE("kontrol() && loadPopupBox('list_partition' , #attributes.modal_id#)"),DE(""))#">
			<cfelse>
				<cf_workcube_buttons is_upd='0' add_function="#iif(isdefined("attributes.draggable"),DE("kontrol() && loadPopupBox('list_partition' , #attributes.modal_id#)"),DE(""))#">
			</cfif>
		</cf_box_footer>
	</cfform>
</cf_box>
<script type="text/javascript">
	row_count=<cfoutput>#partition_row#</cfoutput>;
	kontrol_row_count = <cfoutput>#partition_row#</cfoutput>;
	document.list_partition.record_num.value=row_count;
	function add_row()
	{		
		row_count++;
		kontrol_row_count++;
		var newRow;
		var newCell;
	
		newRow = document.getElementById("table2").insertRow(document.getElementById("table2").rows.length);
		newRow.setAttribute("name","frm_row" + row_count);
		newRow.setAttribute("id","frm_row" + row_count);		
	
		document.list_partition.record_num.value=row_count;
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute("style", "text-align: center;");
		newCell.innerHTML = '<div class="form-group"><a onclick="sil(' + row_count + ');"><i class="fa fa-minus" title="<cf_get_lang dictionary_id='57463.Sil'>" alt="<cf_get_lang dictionary_id='57463.Sil'>"></i></a></div>';				
	
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.align = 'right';
		newCell.innerHTML = 'A - ';
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<div class="form-group"><input type="hidden" name="row_kontrol' + row_count +'" value="1" ><input type="hidden" name="partition_id' + row_count +'" value=""> <input type="text" name="partition_number' + row_count +'" maxlength="28"></div>';
		
		newCell = newRow.insertCell(newRow.cells.length);

		newCell.setAttribute("id","partition_start_date" + row_count + "_td");
		newCell.innerHTML = '<div class="form-group"><div class="input-group"><input type="text" name="partition_start_date' + row_count +'"  id="partition_start_date_input_group' + row_count +'" class="text" maxlength="10" value=""></div></div>';
		document.querySelector("#partition_start_date" + row_count + "_td .input-group").setAttribute("id","partition_start_date_input_group" + row_count + "_td");
		wrk_date_image('partition_start_date_input_group' + row_count,'','add_type');
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<div class="form-group"><input type="text" name="partition_detail' + row_count +'" maxlength="50"></div>';
	}
	function sil(sy)
	{
		var my_element=eval("list_partition.row_kontrol"+sy);		
		my_element.value=0;
		
		var my_element=eval("frm_row"+sy);
		my_element.style.display="none";
		
		kontrol_row_count--;
	}
	function kontrol()
	{
		static_row=0;
		for(r=1;r<=row_count;r++)		
		{
			
			if(eval("document.list_partition.row_kontrol"+r).value == 1)			
			{	
				static_row++;
				deger_partition_number = eval("document.list_partition.partition_number"+r);
				deger_partition_start_date = eval("document.list_partition.partition_start_date"+r);
				deger_partition_detail = eval("document.list_partition.partition_detail"+r);
	
				if(deger_partition_number.value=="")
				{
					alert(static_row+"<cf_get_lang dictionary_id ='41300.Satır No Girmelisiniz'>!");
					return false;
				}
			
				if(deger_partition_start_date.value=="")
				{
					alert(static_row+"<cf_get_lang dictionary_id ='41299.Satir Kuruluş Tarihi Girmelisiniz'>!");
					return false;
				}
			
				if(!CheckEurodate(deger_partition_start_date.value,static_row+"<cf_get_lang dictionary_id ='41298.Satir Kuruluş Tarihi'>"))
				{ 
					deger_partition_start_date.focus();
					return false;
				}
			}
		}
		return true;
	}
	function pencere_ac_date(no)
	{
		windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_calender&alan=list_partition.partition_start_date' + no,'date');
	}	
</script>

