
<cf_seperator id="cek" header="#getLang('','',58007)#">
<div class="row" id="cek">
	<div class="col col-12">
        <cf_grid_list class="workDevList">
            <cfif get_sale_cheques.recordcount>
                <cfinput type="hidden" name="payroll_no_cheque" value="#get_sale_cheques.payroll_no#">
            <cfelse>
                <cfset belge_no2 = get_cheque_no(belge_tipi:'payroll')>
                <input type="hidden" name="payroll_no_cheque" id="payroll_no_cheque" value="<cfoutput>#belge_no2#</cfoutput>">
                <cfset belge_no2 = get_cheque_no(belge_tipi:'payroll',belge_no2:belge_no2+1)>
            </cfif>
            <cfinput type="hidden" name="cheque_id_list" value="#valuelist(get_sale_cheques.cheque_id,',')#">
            <cfset cheque_id_list_ = valuelist(get_sale_cheques.cheque_id,',')>
            <cfinput type="hidden" name="cheque_payroll_id" value="#get_sale_cheques.action_id#">
            <input type="hidden" name="record_num_4" id="record_num_4" value="<cfoutput>#get_sale_cheques.recordcount#</cfoutput>">
            <thead>
                <tr>
                    <th width="30"><cfif kontrol_form_update eq 0><a style="cursor:pointer" onClick="add_row_4('','',0);" title="<cf_get_lang dictionary_id='57582.Ekle'>"><i class="fa fa-plus" title="<cf_get_lang dictionary_id='57582.Ekle'>"></i></a></cfif></th>
                    <th width="30"> <i class="fa fa-pencil"></i></th>
                    <th width="90"><cf_get_lang dictionary_id='57673.Tutar'></th>
                    <th width="75"><cf_get_lang dictionary_id='57881.Vade Tarihi'></th>
                    <th width="75"><cf_get_lang dictionary_id='54490.Çek No'></th>
                    <th width="75"><cf_get_lang dictionary_id='57521.Banka'></th>
                    <th width="75"><cf_get_lang dictionary_id='57453.Şube'></th>
                    <th width="75"><cf_get_lang dictionary_id='58178.Hesap No'></th>
                </tr>
            </thead>
            <tbody name="table1_4" id="table1_4">
            <cfoutput query="get_sale_cheques">
                <tr id="frm_row_4#currentrow#" onMouseOver="this.className='color-light';" onMouseOut="this.className='color-row';" class="color-row">
                    <td nowrap="nowrap">
                        <input  type="hidden" value="1" width="20" name="row_kontrol_4#currentrow#" id="row_kontrol_4#currentrow#"><cfif cheque_status_id eq 1 and kontrol_form_update eq 0><a href="javascript://" onClick="sil_4('#currentrow#');"><i class="fa fa-minus" title="<cf_get_lang dictionary_id='57463.Sil'>"></i></a></cfif>
                    </td>
                    <td nowrap="nowrap">
                        <cfif kontrol_form_update eq 0>
                            <a href="javascript://" onclick="openBoxDraggable('#request.self#?fuseaction=#listgetat(attributes.fuseaction,1,'.')#.popup_upd_self_cheque&cheque_id=#cheque_id#&is_from_sale=1&self_cheque_info=1&currency_id=#session.ep.money#');">
                                <i class="fa fa-pencil"  title="<cf_get_lang dictionary_id='57464.Güncelle'>"></i>
                            </a>
                        </cfif>
                    </td>
                    <cfif cheque_status_id eq 1>
                        <td class="text-right">
                            <input type="hidden" class="boxtext" name="cheque_id#currentrow#" id="cheque_id#currentrow#" value="#cheque_id#">
                            <input type="hidden" name="first_cheque_value#currentrow#" id="first_cheque_value#currentrow#" value="#tlformat(cheque_value,4)#">
                            <input type="text" class="moneybox" name="cheque_value#currentrow#" id="cheque_value#currentrow#" <cfif kontrol_form_update eq 1>disabled</cfif>  value="#tlformat(cheque_value,4)#" maxlength="50" onChange="toplam_voucher_hesapla();vade_hesapla();return(FormatCurrency(this,event,4));" onKeyUp="toplam_voucher_hesapla();vade_hesapla();return(FormatCurrency(this,event,4));">
                        </td>
                        <td nowrap>
                            <input type="hidden" name="cheque_first_due_date#currentrow#" id="cheque_first_due_date#currentrow#" value="#dateformat(cheque_duedate,dateformat_style)#">
                            <input type="text" name="cheque_due_date#currentrow#" id="cheque_due_date#currentrow#" style="width:70px;" <cfif kontrol_form_update eq 1>disabled</cfif> value="#dateformat(cheque_duedate,dateformat_style)#" onblur="change_due_date_sale(#currentrow#)">
                            <cfif kontrol_form_update eq 0><cf_wrk_date_image date_field="cheque_due_date#currentrow#" call_function="change_due_date_sale" call_parameter="#currentrow#"></cfif>
                        </td>
                        <td nowrap>
                            <input type="text" name="cheque_number#currentrow#" id="cheque_number#currentrow#" value="#cheque_no#" style="width:90px;" <cfif kontrol_form_update eq 1>disabled</cfif>>
                        </td>
                        <td nowrap>
                            <input type="text" name="bank_name#currentrow#" id="bank_name#currentrow#" value="#bank_name#" style="width:100px;" onFocus="call_auto_complete2(#currentrow#);" <cfif kontrol_form_update eq 1>disabled</cfif>>
                        </td>
                        <td nowrap>
                            <input type="text" name="bank_branch_name#currentrow#" id="bank_branch_name#currentrow#" value="#bank_branch_name#" style="width:100px;" onFocus="call_auto_complete(#currentrow#);" <cfif kontrol_form_update eq 1>disabled</cfif>>
                        </td>
                        <td nowrap>
                            <input type="text" name="account_no#currentrow#" id="account_no#currentrow#" value="#account_no#" style="width:90px;" <cfif kontrol_form_update eq 1>disabled</cfif>>
                        </td>
                    <cfelse>
                        <td class="text-right">
                            <input type="hidden" name="first_cheque_value#currentrow#" id="first_cheque_value#currentrow#" value="#tlformat(cheque_value,4)#">
                            <input type="text" class="box " name="cheque_value#currentrow#" id="cheque_value#currentrow#"  value="#tlformat(cheque_value,4)#" readonly <cfif kontrol_form_update eq 1>disabled</cfif>>
                        </td>
                        <td nowrap>
                            <input type="hidden" name="cheque_first_due_date#currentrow#" id="cheque_first_due_date#currentrow#" value="#dateformat(cheque_duedate,dateformat_style)#">
                            <input type="text" name="cheque_due_date#currentrow#" id="cheque_due_date#currentrow#" style="width:70px;" value="#dateformat(cheque_duedate,dateformat_style)#"  <cfif kontrol_form_update eq 1>disabled</cfif>>
                        </td>
                        <td nowrap>
                            <input type="text"  name="cheque_number#currentrow#" id="cheque_number#currentrow#" value="#cheque_no#" style="width:90px;" readonly <cfif kontrol_form_update eq 1>disabled</cfif>>
                        </td>
                        <td nowrap>
                            <input type="text"  name="bank_name#currentrow#" id="bank_name#currentrow#" value="#bank_name#" style="width:100px;" readonly <cfif kontrol_form_update eq 1>disabled</cfif>>
                        </td>
                        <td nowrap>
                            <input type="text"  name="bank_branch_name#currentrow#" id="bank_branch_name#currentrow#" value="#bank_branch_name#" style="width:100px;" readonly <cfif kontrol_form_update eq 1>disabled</cfif>>
                        </td>
                        <td nowrap>
                            <input type="text"  name="account_no#currentrow#" id="account_no#currentrow#" value="#account_no#" style="width:90px;" readonly <cfif kontrol_form_update eq 1>disabled</cfif>>
                        </td>
                    </cfif>
                </tr>
            </cfoutput>
            </tbody>
        </cf_grid_list>
        <div class="ui-form-list flex-list ui-info-bottom">
                    <div class="form-group">
						<label class="col col-12 bold">
                            <cf_get_lang dictionary_id='40822.Çek Toplam'>
                        </label>
                    </div>
                    <div class="form-group">
						<div class="col col-12">
                            <input type="text" name="total_cheque_value" id="total_cheque_value" value="0" style="width:120px;" class="moneybox" readonly>
                        </div>
                    </div>
                    <div class="form-group">
						<label class="col col-12 bold">
                            <cf_get_lang dictionary_id='58007.Çek'> <cf_get_lang dictionary_id='57861.Ortalama Vade'>
                        </label>
                    </div>
                
                    <div class="form-group small">
						<div class="col col-12">
                            <input type="text" name="total_cheque_due_value" id="total_cheque_due_value" value="0" style="width:120px;" class="moneybox" readonly>
                        </div>
                    </div>
                </div>
    </div>
</div>
<script type="text/javascript">
	function call_auto_complete(rows)
	{
		AutoComplete_Create('bank_branch_name'+rows,'BANK_BRANCH_NAME,BRANCH_CODE','BANK_BRANCH_NAME,BRANCH_CODE','get_bankbranch_autocomplete','\''+eval("document.getElementById('bank_name" + rows + "')").value+'\'','','','form_basket','3','100');
	}
	function call_auto_complete2(rows)
	{
		AutoComplete_Create('bank_name'+rows,'BANK_NAME','BANK_NAME','get_bank_autocomplete',0,'','','form_basket','3','100');
	}
	row_count_4=<cfoutput>#get_sale_cheques.recordcount#</cfoutput>;
	function sil_4(sy)
	{
		var my_element=eval("form_basket.row_kontrol_4"+sy);
		my_element.value=0;
		var my_element=eval("frm_row_4"+sy);
		my_element.style.display="none";
		toplam_voucher_hesapla();
		vade_hesapla();
	}
	function add_row_4(cheque_value,due_date,type)
	{
		row_count_4++;
		var newRow;
		var newCell;
		newRow = document.getElementById("table1_4").insertRow(document.getElementById("table1_4").rows.length);
		newRow.setAttribute("name","frm_row_4" + row_count_4);
		newRow.setAttribute("id","frm_row_4" + row_count_4);		
		newRow.setAttribute("NAME","frm_row_4" + row_count_4);
		newRow.setAttribute("ID","frm_row_4" + row_count_4);		
		document.all.record_num_4.value=row_count_4;
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<input type="hidden" name="row_kontrol_4'+row_count_4+'" value="1"><a href="javascript://" onclick="sil_4(' + row_count_4 + ');"><i class="fa fa-minus" title="<cf_get_lang dictionary_id='57463.Sil'>"></i></a>';
        newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '';
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML = '<input type="hidden" name="first_cheque_value'+row_count_4+'" value="'+cheque_value+'"><input type="text" name="cheque_value'+row_count_4+'" value="'+cheque_value+'" style="width:90px;" class="moneybox" onChange="toplam_voucher_hesapla();vade_hesapla();return(FormatCurrency(this,event,4));" onKeyUp="toplam_voucher_hesapla();vade_hesapla();return(FormatCurrency(this,event,4));">';
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.setAttribute("id","cheque_due_date" + row_count_4 + "_td");
		newCell.innerHTML = '<input type="hidden" name="cheque_first_due_date' + row_count_4 +'" value="'+due_date+'"><input type="text" name="cheque_due_date' + row_count_4 +'" id="cheque_due_date' + row_count_4 +'" class="text" maxlength="10" style="width:70px;" value="'+due_date+'" onBlur="vade_hesapla();">';
		wrk_date_image('cheque_due_date' + row_count_4,'vade_hesapla');
		newCell = newRow.style.textAlign="center";
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML = '<input type="text" name="cheque_number' + row_count_4 +'" value="" style="width:90px;">';
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<input type="text" name="bank_name' + row_count_4 +'" id="bank_name' + row_count_4 +'" value="" style="width:100px;" onFocus="call_auto_complete2(row_count_4);">';
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<input type="text" name="bank_branch_name' + row_count_4 +'" id="bank_branch_name' + row_count_4 +'" value="" style="width:100px;" onFocus="call_auto_complete(row_count_4);">';
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<input type="text" name="account_no' + row_count_4 +'" value="" style="width:90px;">';
	}
	 $(document).ready(function(){
        if(window.basket.items.length)
	    {
            rowCount = window.basket.items.length;
		  for(i=0;i<rowCount;i++)
		  {
            hesapla('Price',i,0);
		  }
            toplam_hesapla(0,0,1);
			genel_kontrol();
			find_risk();
        }
			
	 });
</script>
