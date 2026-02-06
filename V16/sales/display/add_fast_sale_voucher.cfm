<input type="hidden" name="net_total_taksit" id="net_total_taksit" value="0">
<input type="hidden" name="net_total_pesin" id="net_total_pesin" value="0">
<input type="hidden" name="h_net_total_pesin" id="h_net_total_pesin" value="0">
<!--- <div class="row">
	<label class="col col-12 bold padding-0 font-blue border-bottom border-blue padding-bottom-10 padding-top-10"><cfoutput>#getLang('main',596,'Senet')#</cfoutput></label>
</div> --->
<cf_seperator id="senet" header="#getLang('','Senet',58008)#">
<div class="row" id="senet">
	<div class="col col-12">
		<cf_grid_list>
			<cfinput type="hidden" name="revenue_start_date" value="#dateformat(now(),dateformat_style)#">
			<cfinput type="hidden" name="upd_status" value="0">
			<input type="hidden" name="record_num_3" id="record_num_3" value="0">
			<thead>
				<tr>
					<th style="width:30px;" align="center"><a style="cursor:pointer" onClick="javascript:openBoxDraggable('index.cfm?fuseaction=sales.popup_order_instalment&voucher=1','','ui-draggable-box-small');" title="<cf_get_lang dictionary_id='57582.Ekle'>"><i class="fa fa-plus"></i></a></th>
					<th><cfoutput>#getLang('','tutar',57673)#</cfoutput></th>
					<th width="70"><cfoutput>#getLang('','vade tarihi',57881)#</cfoutput></th>
					<th width="30"><cfoutput>#getLang('','odeme sozu',29945)#</cfoutput></th>
				</tr>
			</thead>
			<tbody name="table1_3" id="table1_3"></tbody>
		</cf_grid_list>
		<div class="ui-form-list flex-list ui-info-bottom">
			<div class="form-group">
				<label class="bold"><cf_get_lang dictionary_id='50452.Senet Toplam'></label>
				<input type="text" name="total_voucher_value" id="total_voucher_value" value="0" class="moneybox" readonly>
			</div>
			<div class="form-group">
				<label class="bold"><cf_get_lang dictionary_id='58008.Senet'><cf_get_lang dictionary_id='57861.Ortalama Vade'></label>
			</div>
			<div class="form-group small">
				<input type="text" name="total_due_value" id="total_due_value" value="0" class="moneybox" readonly>
			</div>
		</div>
	</div>
</div>
<script type="text/javascript">
	row_count_2 = 5;
	function sil_2(sy)
	{
		var my_element=eval("form_basket.row_kontrol_2"+sy);
		my_element.value=0;
		var my_element=eval("frm_row2"+sy);
		my_element.style.display="none";
		toplam_tahsilat();
	}
	function add_row_2_pay()
	{
		row_count_2++;
		var newRow;
		var newCell;
		newRow = document.getElementById("table2").insertRow(document.getElementById("table2").rows.length);	
		newRow.setAttribute("name","frm_row2" + row_count_2);
		newRow.setAttribute("id","frm_row2" + row_count_2);		
		newRow.setAttribute("NAME","frm_row2" + row_count_2);
		newRow.setAttribute("ID","frm_row2" + row_count_2);		
		newRow.className = 'color-row';
		document.all.record_num2.value=row_count_2;
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<input  type="hidden" value="1" name="row_kontrol_2' + row_count_2 +'" id="row_kontrol_2' + row_count_2 +'"><a href="javascript://" onclick="sil_2(' + row_count_2 + ');"><i class="fa fa-minus" title="<cf_get_lang dictionary_id='57463.Sil'>"></i></a>';
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<div class="form-group"><input type="text" name="pos_amount_' + row_count_2 +'" id="pos_amount_' + row_count_2 +'" style="width:100%;" class="moneybox" maxlength="50" onKeyUp="pos_hesapla(' + row_count_2 + ',0);return(FormatCurrency(this,event));" ><input type="hidden" name="system_pos_amount_' + row_count_2 +'" id="system_pos_amount_' + row_count_2 +'" value=""><input type="hidden" name="pos_action_id_' + row_count_2 +'" id="pos_action_id_' + row_count_2 +'" value=""></div>';
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<div class="form-group"><select name="pos_' + row_count_2  +'" id="pos_' + row_count_2  +'" style="width:220px;" class="text"><cfoutput query="GET_POS_DETAIL"><option value="#ACCOUNT_ID#;#ACCOUNT_CURRENCY_ID#;#PAYMENT_TYPE_ID#">#CARD_NO#</option></cfoutput></select></div>';
	}
	row_count_3=0;
	function kontrol_voucher_row(row_no)
	{
		if(eval('form_basket.is_pay_term'+row_no).checked == true)
			for(kk=1;kk<=row_count_3;kk++)
			{
				if(kk != row_no)
					eval('form_basket.is_pay_term'+kk).checked = false;
			}
	}
	function check_cash_pos()
	{
		<cfoutput query="get_money_bskt">
			if(eval(form_basket.kasa#get_money_bskt.currentrow#)!= undefined && eval(form_basket.cash_amount#get_money_bskt.currentrow#)!= undefined && eval(form_basket.cash_amount#get_money_bskt.currentrow#).value!="")
			{
				eval(form_basket.cash_amount#get_money_bskt.currentrow#).value=filterNum((eval(form_basket.cash_amount#get_money_bskt.currentrow#).value));
				form_basket.cash.value=1;
			}
		</cfoutput>
		for(var a=1; a<=row_count_2; a++)
		{
			if(eval('form_basket.row_kontrol_2'+a)!= undefined && eval('form_basket.row_kontrol_2'+a).value == 1 && eval('form_basket.pos_amount_'+a)!= undefined && eval('form_basket.pos_amount_'+a).value!="")
			{
				eval('form_basket.pos_amount_'+a).value=filterNum((eval('form_basket.pos_amount_'+a).value));
				form_basket.is_pos.value=1;
			}
		}
		return true;
	}
	function sil_3(sy,type)
	{
		form_basket.upd_status.value = 1;
		var my_element=eval("form_basket.row_kontrol_3"+sy);
		my_element.value=0;
		var my_element=eval("frm_row_3"+sy);
		my_element.style.display="none";
		if(type == undefined)
		{
			toplam_voucher_hesapla();
			vade_hesapla();
		}
	}
	function add_row_3(voucher_value,due_date,type)
	{
		if(type != undefined)
			form_basket.upd_status.value = 1;
		row_count_3++;
		var newRow;
		var newCell;
		newRow = document.getElementById("table1_3").insertRow(document.getElementById("table1_3").rows.length);
		newRow.setAttribute("name","frm_row_3" + row_count_3);
		newRow.setAttribute("id","frm_row_3" + row_count_3);		
		newRow.setAttribute("NAME","frm_row_3" + row_count_3);
		newRow.setAttribute("ID","frm_row_3" + row_count_3);		
		document.all.record_num_3.value=row_count_3;
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<input type="hidden" name="row_kontrol_3'+row_count_3+'" id="row_kontrol_3'+row_count_3+'" value="1"><a href="javascript://" onclick="sil_3(' + row_count_3 + ');"><i class="fa fa-minus"></i></a>';
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML = '<input type="hidden" name="first_voucher_value'+row_count_3+'" id="first_voucher_value'+row_count_3+'" value="'+voucher_value+'"><input type="text" name="voucher_value'+row_count_3+'" id="voucher_value'+row_count_3+'" value="'+voucher_value+'" class="moneybox" style="width:350px!important" onChange="toplam_voucher_hesapla();vade_hesapla();return(FormatCurrency(this,event,4));" onKeyUp="toplam_voucher_hesapla();vade_hesapla();return(FormatCurrency(this,event,4));">';
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.setAttribute("id","due_date" + row_count_3 + "_td");
		newCell.innerHTML = '<input type="hidden" name="first_due_date' + row_count_3 +'" id="first_due_date' + row_count_3 +'" value="'+due_date+'"><input type="text" name="due_date' + row_count_3 +'" id="due_date' + row_count_3 +'" class="text" maxlength="10"  value="'+due_date+'" onBlur="change_due_date('+row_count_3+');">';
		wrk_date_image('due_date' + row_count_3,'change_due_date('+row_count_3+')');
		newCell = newRow.style.textAlign="center";
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<div class="form-group"><input type="checkbox" name="is_pay_term' + row_count_3 +'" id="is_pay_term' + row_count_3 +'" value="1" title="Ödeme Sözü" onclick="kontrol_voucher_row(' + row_count_3 + ');"></div>';
	}
	function change_due_date(no)
	{
		if(no == 1)
		{
			var pay_control = wrk_safe_query('sls_pay_control','dsn',0,form_basket.paymethod_id.value);
			gun_farki = datediff(form_basket.order_date.value,eval('form_basket.due_date'+no).value,1);
			if(pay_control.DUE_START_DAY != '' && gun_farki > pay_control.DUE_START_DAY)
			{
				alert("<cf_get_lang dictionary_id='41344.Vade Başlangıcı Seçili Olan Ödeme Yönteminin Vade Başlangıcından Fazla Olamaz'> !");
				eval('form_basket.due_date' + no).value = eval('form_basket.first_due_date' + no).value;
			}
			else
			{
				deger_vade_tarih = eval('form_basket.due_date'+no).value;
				if(deger_vade_tarih != '')
				{
					for(j=no+1;j<=row_count_3;j++)
					{
						if(eval('form_basket.row_kontrol_3' + j).value == 1)
						{
							deger_vade_tarih = date_add('m',+1,deger_vade_tarih);
							eval('form_basket.due_date' + j).value = deger_vade_tarih;
						}
					}
				}
				vade_hesapla();
			}
		}
		else
		{
			deger_vade_tarih = eval('form_basket.due_date'+no).value;
			if(deger_vade_tarih != '')
			{
				for(j=no+1;j<=row_count_3;j++)
				{
					if(eval('form_basket.row_kontrol_3' + j).value == 1)
					{
						deger_vade_tarih = date_add('m',+1,deger_vade_tarih);
						eval('form_basket.due_date' + j).value = deger_vade_tarih;
					}
				}
			}
			vade_hesapla();
		}
	}
	function add_voucher_row()
	{
		<cfif xml_add_voucher eq 1>
			kontrol_voucher = 0;
			if(document.all.is_run_voucher_function.value==0)//son güncellemeden geliyorsa senetleri kontrol etsin
			{
				for(j=1;j<=form_basket.record_num_3.value;j++)
				{
					if(eval("document.form_basket.row_kontrol_3"+j).value == 1)
						if((filterNum(eval('form_basket.voucher_value'+j).value,4) != filterNum(eval('form_basket.first_voucher_value'+j).value,4)) || (eval('form_basket.first_due_date'+j).value != eval('form_basket.due_date'+j).value) || form_basket.upd_status.value == 1)
							kontrol_voucher = 1;
				}
			}
			if ((kontrol_voucher == 1 && confirm("<cf_get_lang dictionary_id='63136.Senetler Manuel Olarak Değiştirilmiş Tekrar Otomatik Olarak Oluşturulsun mu?'>") == true) || kontrol_voucher == 0)
			{
				form_basket.upd_status.value = 0;
				for(dd=1;dd<=form_basket.record_num_3.value;dd++)
				{
					//sil_3(dd,1);
				}
				total_voucher_value = 0;
				total_due_value = 0;
				toplam_taksit = 0;
				net_total_taksit = 0;
				net_total_pesin = 0;
				if(rowCount > 1)
				{
					for(j=0;j<rowCount;j++)
					{
						var number_of_ins = filterNum(eval('form_basket.number_of_installment[j].value'));
						var satir_total = filterNum(eval('form_basket.row_lasttotal[j].value'),2);
						toplam_taksit = parseFloat(toplam_taksit + number_of_ins);
						if(number_of_ins == 0)
							net_total_pesin = parseFloat(net_total_pesin + satir_total);
						else
							net_total_taksit = parseFloat(net_total_taksit + satir_total);
					}
				}
				else if(rowCount == 1)
				{
					var number_of_ins = filterNum(form_basket.number_of_installment.value);
					var satir_total = filterNum(form_basket.row_lasttotal.value,2);
					toplam_taksit = toplam_taksit + number_of_ins;
					if(number_of_ins == 0)
						net_total_pesin = parseFloat(net_total_pesin + satir_total);
					else
						net_total_taksit = parseFloat(net_total_taksit + satir_total);
				}
				form_basket.h_net_total_pesin.value = commaSplit(net_total_pesin,4);
				form_basket.net_total_taksit.value = commaSplit(net_total_taksit,4);
				form_basket.total_payment_amount.value = commaSplit((parseFloat(net_total_taksit+filterNum(form_basket.total_cash_amount.value),4)+filterNum(form_basket.total_cheque_value.value)),4);
				form_basket.net_total_pesin.value = commaSplit(net_total_pesin,4);
				total_amount = filterNum(form_basket.total_cash_amount.value)+filterNum(form_basket.total_cheque_value.value);
				first_total_amount = filterNum(form_basket.total_cash_amount.value);
				all_total_amount = wrk_round(form_basket.basket_net_total.value,2);
				if(total_amount <= net_total_pesin)
				{
					row_taksit = 0;
					net_total_pesin = parseFloat(net_total_pesin - filterNum(form_basket.total_cash_amount.value) - filterNum(form_basket.total_cheque_value.value));
					form_basket.net_total_pesin.value = commaSplit(net_total_pesin,4);
				}
				else
				{
					total_amount = parseFloat(total_amount - filterNum(form_basket.h_net_total_pesin.value));
					row_taksit = parseFloat(total_amount / toplam_taksit);
					net_total_taksit = parseFloat(net_total_taksit - total_amount);
					form_basket.net_total_taksit.value = commaSplit(net_total_taksit,4);
					form_basket.total_payment_amount.value = commaSplit(parseFloat(net_total_taksit+filterNum(form_basket.total_cash_amount.value)+filterNum(form_basket.total_cheque_value.value)),4);
				}
				deger_vade_tarih = date_add('m',+1,form_basket.revenue_start_date.value);
				all_voucher_count = 0;
				if(rowCount > 1 && first_total_amount != all_total_amount)
				{
					for(j=0;j<rowCount;j++)
					{
						kk = row_count_3 - all_voucher_count + 1;
						var last_total = filterNum(eval('form_basket.row_lasttotal[j].value'),4);
						var number_of_ins = filterNum(eval('form_basket.number_of_installment[j].value'));
						last_total = parseFloat(last_total-(row_taksit*number_of_ins));
						taksit_amount = parseFloat(last_total / number_of_ins);
						for(k=1;k<=number_of_ins;k++)	
						{
							if(all_voucher_count >= k && eval('form_basket.row_kontrol_3' + kk).value == 1)
							{
								satir_voucher = filterNum(eval('form_basket.voucher_value' + kk).value,4);
								eval('form_basket.voucher_value' + kk).value = commaSplit(satir_voucher +taksit_amount,4);
								eval('form_basket.first_voucher_value' + kk).value = commaSplit(satir_voucher +taksit_amount,4);
								kk = kk + 1;
							}
							else
							{
								all_voucher_count = all_voucher_count + 1;
								add_row_3(commaSplit(taksit_amount,4),deger_vade_tarih);
								deger_vade_tarih = date_add('m',+1,deger_vade_tarih);
							}
						}
					}
				}
				else if(rowCount == 1 && first_total_amount != all_total_amount)
				{
					var last_total = filterNum(form_basket.row_lasttotal.value,4);
					var number_of_ins = filterNum(form_basket.number_of_installment.value);
					last_total = parseFloat(last_total-(row_taksit*number_of_ins));
					taksit_amount = parseFloat(last_total / number_of_ins);
					for(k=1;k<=number_of_ins;k++)	
					{
						if(document.all.record_num_3.value >= k && eval('form_basket.row_kontrol_3' + k).value == 1)
						{
							satir_voucher = filterNum(form_basket.voucher_value.value,4);
							form_basket.voucher_value.value = commaSplit(satir_voucher +taksit_amount,4);
							form_basket.first_voucher_value.value = commaSplit(satir_voucher +taksit_amount,4);
						}
						else
						{
							add_row_3(commaSplit(taksit_amount,4),deger_vade_tarih);
							deger_vade_tarih = date_add('m',+1,deger_vade_tarih);
						}
					}
				}
			}
		</cfif>
		toplam_voucher_hesapla();
		vade_hesapla();
	}
	function toplam_voucher_hesapla()
	{
		
		var total_value = 0;
		for(j=1;j<=form_basket.record_num_3.value;j++)
		{
			console.log('val'+filterNum(eval('form_basket.voucher_value'+j).value,4));
			console.log('total_value:'+total_value);
			if(eval("document.form_basket.row_kontrol_3"+j).value == 1)
				{
					voucher_value = eval('form_basket.voucher_value'+j).value;
					voucher_value = filterNum(voucher_value,4);
					total_value = parseFloat(total_value)+parseFloat(voucher_value);
				}
						
		}
		total_value2 = 0;
		for(j=1;j<=form_basket.record_num_4.value;j++)
		{
			if(eval("document.form_basket.row_kontrol_4"+j).value == 1)
				{
					cheque_value = eval('form_basket.cheque_value'+j).value;
					cheque_value = filterNum(cheque_value,4);
					total_value2 = parseFloat(total_value2)+parseFloat(voucher_value);
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
		form_basket.total_voucher_value.value = commaSplit(total_value,4);
		form_basket.total_cheque_value.value = commaSplit(total_value2,4);
		form_basket.total_payment_amount.value = commaSplit(parseFloat(filterNum(form_basket.total_voucher_value.value)+filterNum(form_basket.total_cheque_value.value)+filterNum(form_basket.total_cash_amount.value)),4);
	}
	function vade_hesapla()
	{
		deger_total_due_value = 0;
		deger_cheque_total_due_value = 0;
		total_voucher_value = filterNum(form_basket.total_voucher_value.value);
		total_cheque_value = filterNum(form_basket.total_cheque_value.value);
		for(dd=1;dd<=form_basket.record_num_3.value;dd++)
		{
			if(eval("document.form_basket.row_kontrol_3"+dd).value == 1)
			{
				satir_deger = filterNum(eval('form_basket.voucher_value'+dd).value,4);
				if(eval('form_basket.due_date'+dd).value != '')
					gun_farki = datediff(form_basket.order_date.value,eval('form_basket.due_date'+dd).value,1);
				else
					gun_farki = 0;
				deger_total_due_value = deger_total_due_value + satir_deger * gun_farki;
			}
		}
		for(dd=1;dd<=form_basket.record_num_4.value;dd++)
		{
			if(eval("document.form_basket.row_kontrol_4"+dd).value == 1)
			{
				satir_deger = filterNum(eval('form_basket.cheque_value'+dd).value,4);
				if(eval('form_basket.cheque_due_date'+dd).value != '')
					gun_farki = datediff(form_basket.order_date.value,eval('form_basket.cheque_due_date'+dd).value,1);
				else
					gun_farki = 0;
				deger_cheque_total_due_value = deger_cheque_total_due_value + satir_deger * gun_farki;
			}
		}
		if(total_voucher_value > 0)
			form_basket.total_due_value.value = wrk_round(deger_total_due_value/total_voucher_value,0);
		else
			form_basket.total_due_value.value = 0;
		
		if(total_cheque_value > 0)
			form_basket.total_cheque_due_value.value = wrk_round(deger_cheque_total_due_value/total_cheque_value,0);
		else
			form_basket.total_cheque_due_value.value = 0;
	}
	function kasa_dovizi_hesapla(sira_no)
	{	
		kasa_money_rate2 = eval('form_basket.txt_rate2_' + sira_no).value;
		kasa_money_rate1=eval('form_basket.txt_rate1_' + sira_no).value;	
		if (eval('form_basket.cash_amount' + sira_no)!=undefined && eval('form_basket.cash_amount' + sira_no).value!= "")
		{
			sistem_tutar=(filterNum(eval('form_basket.cash_amount' + sira_no).value,4)*(filterNum(kasa_money_rate2,'<cfoutput>#session.ep.our_company_info.rate_round_num#</cfoutput>')/filterNum(kasa_money_rate1,'<cfoutput>#session.ep.our_company_info.rate_round_num#</cfoutput>')));
			eval('form_basket.system_cash_amount'+sira_no).value=wrk_round(sistem_tutar);
		}
		toplam_tahsilat(sira_no,0);
	}
	function pos_hesapla(pos_row)
	{	
		if(eval('form_basket.pos_amount_'+pos_row)!= undefined)
		{
			if(eval('form_basket.pos_amount_'+pos_row).value!="")
			{
				pos_money_list=new Array(1);
				<cfoutput query="get_money_bskt">
					pos_money_list.push('#get_money_bskt.money_type#');
				</cfoutput>
				for(var jxj=1; jxj<=pos_money_list.length-1; jxj++ )
				{
					pos_deger = eval('form_basket.pos_'+pos_row).value.split(';');
					pos_currency=pos_deger[1];
					if(pos_money_list[jxj] == pos_currency)
						{
							temp_pos_amount= eval('form_basket.pos_amount_'+pos_row).value;
							temp_rate2=eval('form_basket.txt_rate2_' + jxj).value;
							temp_rate1=eval('form_basket.txt_rate1_' + jxj).value;
							eval('form_basket.system_pos_amount_'+pos_row).value=wrk_round(filterNum(temp_pos_amount)*(filterNum(temp_rate2,'<cfoutput>#session.ep.our_company_info.rate_round_num#</cfoutput>')/filterNum(temp_rate1,'<cfoutput>#session.ep.our_company_info.rate_round_num#</cfoutput>')));
						}
				}
			}
			else
				eval('form_basket.system_pos_amount_'+pos_row).value=0;
			toplam_tahsilat(pos_row,1);
		}
	}
	function toplam_tahsilat(sira_no,type)
	{	
		tahsilat_tutari=0;
		for(var n=1; n <= form_basket.kur_say.value; n++)
		{
			if(eval('form_basket.cash_amount'+n)!= undefined && eval('form_basket.cash_amount'+n).value!="")
				tahsilat_tutari = tahsilat_tutari+parseFloat(eval('form_basket.system_cash_amount'+n).value);
		}
		for(var m=1; m<=row_count_2; m++)
		{
			if(eval('form_basket.row_kontrol_2'+m)!= undefined && eval('form_basket.row_kontrol_2'+m).value == 1 && eval('form_basket.pos_amount_'+m)!= undefined && eval('form_basket.pos_amount_'+m).value!="")
				tahsilat_tutari = tahsilat_tutari+parseFloat(eval('form_basket.system_pos_amount_'+m).value);
		}
		voucher_net_toplam = wrk_round(form_basket.basket_net_total.value,2);
		if(tahsilat_tutari > voucher_net_toplam)
		{
			alert("<cf_get_lang dictionary_id='41262.Peşinat Tutarı Alışveriş Toplamından Fazla'>!")
			if(type == 0)
			{
				tahsilat_tutari = tahsilat_tutari-parseFloat(eval('form_basket.cash_amount'+sira_no).value);
				eval('form_basket.cash_amount'+sira_no).value= 0;
				eval('form_basket.system_cash_amount'+sira_no).value= 0;
			}
			else
			{
				tahsilat_tutari = tahsilat_tutari-parseFloat(eval('form_basket.pos_amount_'+sira_no).value);
				eval('form_basket.pos_amount_'+sira_no).value= 0;
				eval('form_basket.system_pos_amount_'+sira_no).value= 0;
			}
		}
		if(form_basket.total_cash_amount != undefined) 
			form_basket.total_cash_amount.value=commaSplit(tahsilat_tutari,4);
		add_voucher_row();
	}
</script>
