<!--- <div class="row">
	<label class="col col-12 bold padding-0 font-blue border-bottom border-blue padding-bottom-10 padding-top-10"><cf_get_lang_main no ='595.Çek'></label>
</div> --->
<cf_seperator id="cek" header="#getLang('','',58007)#">
<div class="row" id="cek">
	<div class="col col-12">
		<cf_grid_list>
			<input type="hidden" name="record_num_4" id="record_num_4" value="0">
			<thead>
				<tr>
					<th style="width:30px" class="color-row" align="center"><a href="javascript://" onClick="javascript:openBoxDraggable('index.cfm?fuseaction=sales.popup_order_instalment&cheque=1','','ui-draggable-box-medium');"><i class="fa fa-plus"></i></a></th>
						<th><cf_get_lang dictionary_id='57673.Tutar'></th>
						<th style="width:70px"><cf_get_lang dictionary_id='57881.Vade Tarihi'></th>
						<th><cf_get_lang dictionary_id='54490.Çek No'></th>
						<th><cf_get_lang dictionary_id='57521.Banka'></th>
						<th><cf_get_lang dictionary_id='57453.Şube'></th>
						<th><cf_get_lang dictionary_id='58178.Hesap No'></th>
				</tr>
			</thead>
			<tbody name="table1_4" id="table1_4"></tbody>
		</cf_grid_list>
		<div class="ui-form-list flex-list ui-info-bottom">
			<div class="form-group">
				<label class="bold"> <cf_get_lang dictionary_id='40822.Çek Toplam'></label>
				<input type="text" name="total_cheque_value" id="total_cheque_value" value="0" class="moneybox" readonly>
			</div>
			<div class="form-group">
				<label class="bold"> <cf_get_lang dictionary_id='58007.Çek'> <cf_get_lang dictionary_id='57861.Ortalama Vade'></label>
			</div>
			<div class="form-group small">
				<input type="text" name="total_cheque_due_value" id="total_cheque_due_value" value="0" class="moneybox" readonly>
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
	row_count_4=0;
	function sil_4(sy)
	{
		var my_element=eval("form_basket.row_kontrol_4"+sy);
		my_element.value=0;
		var my_element=eval("frm_row_4"+sy);
		my_element.style.display="none";
		toplam_cheque_hesapla();
		vade_hesapla();
	}
	function add_row_4(cheque_value,due_date,cheque_number,bank_name,bank_branch_name,account_no)
	{
		row_count_4++;
		var newRow;
		var newCell;
		newRow = document.getElementById("table1_4").insertRow(document.getElementById("table1_4").rows.length);
		newRow.setAttribute("name","frm_row_4" + row_count_4);
		newRow.setAttribute("id","frm_row_4" + row_count_4);		
		newRow.setAttribute("NAME","frm_row_4" + row_count_4);
		newRow.setAttribute("ID","frm_row_4" + row_count_4);		
		document.getElementById('record_num_4').value=row_count_4;
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<input type="hidden" name="row_kontrol_4'+row_count_4+'" id="row_kontrol_4'+row_count_4+'" value="1"><a href="javascript://" onclick="sil_4(' + row_count_4 + ');"><i class="fa fa-minus"></i></a>';
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<input type="hidden" name="first_cheque_value'+row_count_4+'" id="first_cheque_value'+row_count_4+'"  value="'+cheque_value+'"><input type="text" name="cheque_value'+row_count_4+'" id="cheque_value'+row_count_4+'" value="'+cheque_value+'" style="width:90px;" class="moneybox" onChange="toplam_cheque_hesapla();vade_hesapla();return(FormatCurrency(this,event,4));" onKeyUp="toplam_cheque_hesapla();vade_hesapla();return(FormatCurrency(this,event,4));">';
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.setAttribute("id","cheque_due_date" + row_count_4 + "_td");
		newCell.setAttribute("name","cheque_due_date" + row_count_4 + "_td");
		newCell.innerHTML = '<input type="hidden" name="cheque_first_due_date' + row_count_4 +'" id="cheque_first_due_date' + row_count_4 +'" value="'+due_date+'"><input type="text" name="cheque_due_date' + row_count_4 +'" id="cheque_due_date' + row_count_4 +'" class="text" maxlength="10" value="'+due_date+'" onBlur="vade_hesapla();">';
		wrk_date_image('cheque_due_date' + row_count_4,'vade_hesapla()');
		newCell = newRow.style.textAlign="center";
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<div class="form-group"><input type="text" name="cheque_number' + row_count_4 +'" id="cheque_number' + row_count_4 +'" value="'+cheque_number+'" style="width:90px;"></div>';
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<div class="form-group"><input type="text" name="bank_name' + row_count_4 +'" id="bank_name' + row_count_4 +'" value="'+bank_name+'" style="width:100px;" onFocus="call_auto_complete2(row_count_4);"></div>';
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<div class="form-group"><input type="text" name="bank_branch_name' + row_count_4 +'" id="bank_branch_name' + row_count_4 +'" value="'+bank_branch_name+'" style="width:100px;" onFocus="call_auto_complete(row_count_4);"></div>';
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<div class="form-group"><input type="text" name="account_no' + row_count_4 +'" id="account_no' + row_count_4 +'" value="'+account_no+'" style="width:90px;"></div>';
	}
	function toplam_cheque_hesapla()
	{
		var total_value = 0;
		total_value2 = 0;
		for(j=1;j<=form_basket.record_num_4.value;j++)
		{
			if(eval("document.form_basket.row_kontrol_4"+j).value == 1)
				{
					cheque_value = eval('form_basket.cheque_value'+j).value;
					cheque_value = filterNum(cheque_value,4);
					total_value2 = parseFloat(total_value2)+parseFloat(cheque_value);
				}
		}
		if(form_basket.total_guarantor_limit != undefined)
			total_kefil_limit = filterNum(form_basket.total_guarantor_limit.value);
		else
			total_kefil_limit = 0;
		total_member_limit = filterNum(form_basket.member_use_limit.value);
		total_order_amount = filterNum(form_basket.member_order_value.value);
		total_limit = total_kefil_limit + total_member_limit - total_order_amount;
		if((total_value2+total_value-total_limit) >= 0)
			form_basket.limit_diff_value.value = commaSplit((total_value2+total_value-total_limit),4);
		else
			form_basket.limit_diff_value.value = commaSplit((0),4);			
		form_basket.total_cheque_value.value = commaSplit(total_value2,4);
		form_basket.total_payment_amount.value = commaSplit(parseFloat(filterNum(form_basket.total_voucher_value.value)+filterNum(form_basket.total_cheque_value.value)+filterNum(form_basket.total_cash_amount.value)),4);
	}
</script>
