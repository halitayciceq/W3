
	<div class="ui-form-list flex-list">
		<div class="form-group">
			<label><cf_get_lang dictionary_id='58625.Kefil Toplam Limit'></label>
			<div class="input-group">
				<input type="text" name="total_guarantor_limit" id="total_guarantor_limit" value="0" class="box" readonly>
				<span class="input-group-addon btnPointer"><cfoutput>#session.ep.money#</cfoutput></span>
			</div>
		</div>
	</div>
<div class="col col-3 col-xs-12">
	<cf_grid_list>
		<thead>
			<input type="hidden" name="record_num_2_q" id="record_num_2_q" value="0">
			<tr>
				<th style="width:30px" align="center"><a onClick="add_row_2_q();" href="javascript://" title="<cf_get_lang dictionary_id='57582.Ekle'>"><i class="fa fa-plus"></i></a></th>
				<th style="width:130px"><cf_get_lang dictionary_id='58626.Kefil'></th>
				<th><cf_get_lang dictionary_id='58627.Kimlik No'></th>
			</tr>
		</thead>
		<tbody name="table1_2" id="table1_2"></tbody>
	</cf_grid_list>
</div>
<script type="text/javascript">
row_count_2_q=0;
function sil_2_q(sy)
{
	var my_element=eval("form_basket.row_kontrol_2_q"+sy);
	my_element.value=0;
	var my_element=eval("frm_row_2"+sy);
	var my_element_2=eval("frm_row_2"+sy+"_2");
	my_element.style.display="none";
	my_element_2.style.display="none";
	toplam_limit_hesapla();	
}
function add_row_2_q()
{
	row_count_2_q++;
	var newRow;
	var newCell;
	newRow = document.getElementById("table1_2").insertRow(document.getElementById("table1_2").rows.length);
	newRow.className="color-row";
	newRow.setAttribute("name","frm_row_2" + row_count_2_q);
	newRow.setAttribute("id","frm_row_2" + row_count_2_q);		
	newRow.setAttribute("NAME","frm_row_2" + row_count_2_q);
	newRow.setAttribute("ID","frm_row_2" + row_count_2_q);		
	document.getElementById('record_num_2_q').value=row_count_2_q;
	newCell = newRow.insertCell(newRow.cells.length);
	newCell.innerHTML = '<input type="hidden" name="row_kontrol_2_q'+row_count_2_q+'" id="row_kontrol_2_q'+row_count_2_q+'" value="1"><a href="javascript://" onclick="sil_2_q(' + row_count_2_q + ');"><i class="fa fa-minus"></i></a>';
	newCell = newRow.insertCell(newRow.cells.length);
	newCell.setAttribute('nowrap','nowrap');
	newCell.innerHTML = '<div class="form-group"><div class="input-group"><input type="text" name="q_consumer_name'+row_count_2_q+'" value="" class="boxtext"><input type="hidden" name="q_consumer_id'+row_count_2_q+'" id="q_consumer_id'+row_count_2_q+'" value="" readonly><span class="input-group-addon icon-ellipsis btnPointer" onClick="pencr_ac(' + row_count_2_q + ');"></span></div></div>';
	newCell = newRow.insertCell(newRow.cells.length);
	newCell.innerHTML = '<div class="form-group"><input type="text" name="q_tc_identy'+row_count_2_q+'" id="q_tc_identy'+row_count_2_q+'" value="" class="boxtext"></div>';			
	
	newRow = document.getElementById("table1_2").insertRow(document.getElementById("table1_2").rows.length);
	newRow.className="color-row";
	newRow.setAttribute("name","frm_row_2" + row_count_2_q + "_2");
	newRow.setAttribute("id","frm_row_2" + row_count_2_q + "_2");		
	newRow.setAttribute("NAME","frm_row_2" + row_count_2_q + "_2");
	newRow.setAttribute("ID","frm_row_2" + row_count_2_q + "_2");
	newCell = newRow.insertCell(newRow.cells.length);
	newCell.innerHTML = '';
	newCell = newRow.insertCell(newRow.cells.length);
	newCell.innerHTML = '<div class="form-group"><input type="text" name="last_risk'+row_count_2_q+'" id="last_risk'+row_count_2_q+'" value="0" style="width:100%;" readonly class="box"></div>';
	newCell = newRow.insertCell(newRow.cells.length);
	newCell.innerHTML = '<div class="form-group"><input type="text" name="last_use_risk'+row_count_2_q+'" value="0" class="box" onkeyup="hesapla_satir('+row_count_2_q+',1);return(FormatCurrency(this,event));"></div>';
	pencr_ac(row_count_2_q);
}
function pencr_ac(no)
{
	windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_cons&select_list=3,5&field_id=form_basket.q_consumer_id' + no + '&field_name=form_basket.q_consumer_name' + no+ '&call_function=find_bakiye('+no+')' ,'list');
}
function find_bakiye(no)
{
	kontrol = 0;
	for(var i=1;i<=no-1;i++)
		if(eval("document.getElementById('q_consumer_id" + i + "')").value == eval("document.getElementById('q_consumer_id" + no + "')").value && eval("document.getElementById('row_kontrol_2_q" + i + "')").value == 1&& kontrol == 0)
		{
			alert("<cf_get_lang dictionary_id='33990.Aynı Üyeyi 2 Kere Kefil Olarak Ekleyemezsiniz'>!");
			kontrol = 1;
			sil_2(no);
		}
	kontrol_2 = 0;
	for(var j=1;j<=no;j++)
		if(eval("document.getElementById('q_consumer_id" + j + "')").value == document.all.consumer_id.value && eval("document.getElementById('row_kontrol_2_q" + j + "')").value == 1 && kontrol_2 == 0)
		{
			alert("<cf_get_lang dictionary_id='33991.Üyeyi kendisi İçin Kefil Olarak Ekleyemezsiniz'>!");
			kontrol_2 = 1;
			sil_2(no);
		}
	var get_consumer_1 = wrk_safe_query('sls_get_consumer_1','dsn',0,eval("document.getElementById('q_consumer_id" + no + "')").value);
	var get_consumer_2 = wrk_safe_query('sls_get_cnsmr_2','dsn2',0,eval("document.getElementById('q_consumer_id" + no + "')").value);
	if(get_consumer_1.recordcount)
		eval("document.getElementById('q_tc_identy" + no + "')").value = get_consumer_1.TC_IDENTY_NO;
	if(get_consumer_2.recordcount)
	{
		toplam_risk = parseFloat(get_consumer_2.BAKIYE) + parseFloat(get_consumer_2.SENET_KARSILIKSIZ) + parseFloat(get_consumer_2.CEK_KARSILIKSIZ) + parseFloat(get_consumer_2.CEK_ODENMEDI) + parseFloat(get_consumer_2.SENET_ODENMEDI) + parseFloat(get_consumer_2.KEFIL_SENET_ODENMEDI) + parseFloat(get_consumer_2.KEFIL_SENET_KARSILIKSIZ);
		eval('document.all.last_risk'+no).value = commaSplit(parseFloat(get_consumer_2.TOTAL_RISK_LIMIT) - toplam_risk);
		eval('document.all.last_use_risk'+no).value = commaSplit(parseFloat(get_consumer_2.TOTAL_RISK_LIMIT) - toplam_risk);
	}
	hesapla_satir(no,0);
}
function hesapla_satir(no,type)
{
	if(type == 0)
	{
		toplam_kefil_limit = filterNum(form_basket.total_guarantor_limit.value);
		toplam_member_limit = filterNum(form_basket.member_use_limit.value);
		total_limit = toplam_kefil_limit + toplam_member_limit;
		net_total =  wrk_round(form_basket.basket_net_total.value,2);
		satir_risk_first = filterNum(eval('form_basket.last_risk' + no).value);
		satir_risk = filterNum(eval('form_basket.last_use_risk' + no).value);
		if(satir_risk_first <= 0)
		{
			alert("<cf_get_lang dictionary_id='41343.Seçilen Üyenin Kullanılabilir Limiti Sıfırdan Büyük Olmalıdır'> !");
			sil_2_q(no);
		}
		else if(satir_risk > satir_risk_first)
		{
			alert("<cf_get_lang dictionary_id='34002.Girdiğiniz Limit Tutarı Üyenin Kullanılabilir Limitinden Fazla Olamaz'>!");
			eval('form_basket.last_use_risk'+no).value = 0;
		}
	}
	else
	{
		satir_risk_first = filterNum(eval('form_basket.last_risk' + no).value);
		satir_risk = filterNum(eval('form_basket.last_use_risk' + no).value);
		if(satir_risk > satir_risk_first)
		{
			alert("<cf_get_lang dictionary_id='34002.Girdiğiniz Limit Tutarı Üyenin Kullanılabilir Limitinden Fazla Olamaz'> !");
			eval('form_basket.last_use_risk'+no).value = 0;
		}
	}
	toplam_limit_hesapla();		
}
</script>
