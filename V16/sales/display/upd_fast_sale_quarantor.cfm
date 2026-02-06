<cfquery name="get_vouchers" datasource="#dsn2#">
	SELECT V.* FROM VOUCHER V,VOUCHER_PAYROLL VP WHERE V.VOUCHER_PAYROLL_ID = VP.ACTION_ID AND VP.PAYMENT_ORDER_ID = #attributes.order_id#
</cfquery>
<cfset voucher_id_list= valuelist(get_vouchers.voucher_id)>
<cfif listlen(voucher_id_list)>
	<cfquery name="get_guarantors" datasource="#dsn2#">
		SELECT CONSUMER_ID FROM VOUCHER_GUARANTORS WHERE VOUCHER_ID IN (#voucher_id_list#) GROUP BY CONSUMER_ID
	</cfquery>
	<cfquery name="get_consumer_q" datasource="#dsn2#">
		SELECT * FROM VOUCHER_GUARANTORS WHERE VOUCHER_ID IN (#voucher_id_list#)
	</cfquery>
	<cfquery name="get_all_quarantors" datasource="#dsn#">
		SELECT DISTINCT
			CONSUMER.CONSUMER_NAME,
			CONSUMER.CONSUMER_SURNAME,
			CONSUMER.CONSUMER_ID,
			CONSUMER.TC_IDENTY_NO,
			VOUCHER_GUARANTORS.*
		FROM
			CONSUMER,
			#dsn2_alias#.VOUCHER_GUARANTORS VOUCHER_GUARANTORS
		WHERE
			VOUCHER_GUARANTORS.CONSUMER_ID = CONSUMER.CONSUMER_ID
			AND VOUCHER_GUARANTORS.VOUCHER_ID IN (#voucher_id_list#)
		ORDER BY
			VOUCHER_GUARANTORS.CONSUMER_ID
	</cfquery>
	<cfquery name="get_total_guarantor" dbtype="query">
		SELECT SUM(AMOUNT) TOTAL_AMOUNT FROM get_all_quarantors
	</cfquery>
<cfelse>
	<cfset get_guarantors.recordcount = 0>
	<cfset get_all_quarantors.recordcount = 0>
	<cfset get_total_guarantor.recordcount = 0>
</cfif>
<cfif len(get_order_detail.consumer_id)>
	<cfquery name="get_member_risk" datasource="#dsn2#">
		SELECT * FROM CONSUMER_RISK WHERE CONSUMER_ID = #get_order_detail.consumer_id#
	</cfquery>
	<cfquery name="get_ord_det" datasource="#dsn3#">
		SELECT SUM(NETTOTAL) NETTOTAL, CONSUMER_ID FROM ORDERS WHERE ORDER_ID NOT IN(SELECT ORDER_ID FROM ORDERS_INVOICE) AND ORDER_STATUS = 1 AND CONSUMER_ID=#get_order_detail.consumer_id# AND ORDER_ID <> #attributes.order_id# GROUP BY CONSUMER_ID
	</cfquery>
	<cfif get_member_risk.recordcount and len(get_member_risk.TOTAL_RISK_LIMIT)>
		<cfset toplam_risk = get_member_risk.TOTAL_RISK_LIMIT - (get_member_risk.BAKIYE + get_member_risk.SENET_KARSILIKSIZ + get_member_risk.CEK_KARSILIKSIZ + get_member_risk.CEK_ODENMEDI + get_member_risk.SENET_ODENMEDI + get_member_risk.KEFIL_SENET_ODENMEDI + get_member_risk.KEFIL_SENET_KARSILIKSIZ)>
	<cfelse>
		<cfset toplam_risk = 0>
	</cfif>
<cfelseif len(get_order_detail.company_id)>
	<cfquery name="get_member_risk" datasource="#dsn2#">
		SELECT * FROM COMPANY_RISK WHERE COMPANY_ID = #get_order_detail.company_id#
	</cfquery>
	<cfquery name="get_ord_det" datasource="#dsn3#">
		SELECT SUM(NETTOTAL) NETTOTAL, COMPANY_ID FROM ORDERS WHERE ORDER_ID NOT IN(SELECT ORDER_ID FROM ORDERS_INVOICE) AND ORDER_STATUS = 1 AND COMPANY_ID =#get_order_detail.company_id# AND ORDER_ID <> #attributes.order_id# GROUP BY COMPANY_ID
	</cfquery>
	<cfif get_member_risk.recordcount and len(get_member_risk.TOTAL_RISK_LIMIT)>
		<cfset toplam_risk = get_member_risk.TOTAL_RISK_LIMIT - (get_member_risk.BAKIYE + get_member_risk.SENET_KARSILIKSIZ + get_member_risk.CEK_KARSILIKSIZ + get_member_risk.CEK_ODENMEDI + get_member_risk.SENET_ODENMEDI)>
	<cfelse>
		<cfset toplam_risk = 0>
	</cfif>
</cfif>

	<div class="ui-form-list flex-list">
		<div class="form-group">
			<label><cf_get_lang dictionary_id='58625.Kefil Toplam Limit'></label>
			<div class="input-group">
				<input type="text" name="total_guarantor_limit" id="total_guarantor_limit" value="<cfif get_total_guarantor.recordcount><cfoutput>#tlformat(get_total_guarantor.total_amount)#</cfoutput><cfelse>0</cfif>" readonly> 
				<span class="input-group-addon btnPointer"><cfoutput>#session.ep.money#</cfoutput></span>
			</div>
		</div>
	</div>

<div class="col col-3 col-md-3 col-sm-3 col-xs-12" type="column" index="8" sort="false">
	<cf_grid_list class="workDevList">
		<thead>
			<tr>
				<th style="width:30px" align="center"><cfif kontrol_form_update eq 0><a style="cursor:pointer" onClick="add_row_2_q();" title="<cf_get_lang dictionary_id='57582.Ekle'>"><i class="fa fa-plus"></i></cfif></th>
				<th width="130px"><cf_get_lang dictionary_id='58626.Kefil'></th>
				<th><cf_get_lang dictionary_id='58627.Kimlik No'></th>
			</tr>
		</thead>
		<tbody name="table1_2" id="table1_2">
		<input type="hidden" name="record_num_2_q" id="record_num_2_q" value="<cfoutput>#get_guarantors.recordcount#</cfoutput>">
		<cfif get_guarantors.recordcount>
			<cfset consumer_id_list = valuelist(get_guarantors.consumer_id)>
			<cfquery name="get_consumer_risks" datasource="#dsn2#">
			SELECT * FROM CONSUMER_RISK WHERE CONSUMER_ID IN(#consumer_id_list#) ORDER BY CONSUMER_ID
			</cfquery>
			<cfset main_consumer_id_list = valuelist(get_consumer_risks.consumer_id)>
			<cfoutput query="get_guarantors">
				<cfquery name="get_c_total" dbtype="query">
					SELECT SUM(AMOUNT) TOTAL_AMOUNT FROM get_all_quarantors WHERE CONSUMER_ID = #get_guarantors.consumer_id#
				</cfquery>	
				<cfquery name="get_consumer_" dbtype="query">
					SELECT * FROM get_all_quarantors WHERE CONSUMER_ID = #get_guarantors.consumer_id#
				</cfquery>			
				<tr name="frm_row_2_q#currentrow#" id="frm_row_2_q#currentrow#" class="color-row">
					<td>
						<input type="hidden" name="row_kontrol_2_q#currentrow#" id="row_kontrol_2_q#currentrow#" value="1">
						<cfif kontrol_form_update eq 0><a href="javascript://" onclick="sil_2_q(#currentrow#);"><i class="fa fa-minus" title="<cf_get_lang dictionary_id='57463.Sil'>"></i></a></cfif>
					</td>
					<td>
						<input type="hidden" name="relation_id#currentrow#" id="relation_id#currentrow#" value="#get_consumer_.voucher_guarantor_id#">
						<input type="hidden" name="q_consumer_id#currentrow#" id="q_consumer_id#currentrow#" value="#get_consumer_.consumer_id#">
						<input type="hidden" name="q_consumer_name#currentrow#" id="q_consumer_name#currentrow#" value="#get_consumer_.consumer_name# #get_consumer_.consumer_surname#" style="width:110px;" readonly class="boxtext">
						<cfif not listfindnocase(denied_pages,'member.detail_consumer')>
							<a href="#request.self#?fuseaction=member.consumer_list&event=det&cid=#get_consumer_.consumer_id#" class="tableyazi" title="Kefil Detay">#get_consumer_.consumer_name# #get_consumer_.consumer_surname#</a>
						<cfelse>
							#get_consumer_.consumer_name# #get_consumer_.consumer_surname#
						</cfif>
					</td>
					<td>
						<input type="text" name="q_tc_identy#currentrow#" id="q_tc_identy#currentrow#" value="#get_consumer_.tc_identy_no#" style="width:100%;" readonly class="boxtext">
					</td>
				</tr>
				<tr name="frm_row_2_q#currentrow#_2" id="frm_row_2_q#currentrow#_2" class="color-row">
					<td></td>
					<cfif listfind(main_consumer_id_list,consumer_id,',')>
						<td><input type="text" name="last_risk#currentrow#" id="last_risk#currentrow#" value="#Tlformat(get_consumer_risks.TOTAL_RISK_LIMIT[listfind(main_consumer_id_list,consumer_id,',')] - (get_consumer_risks.BAKIYE[listfind(main_consumer_id_list,consumer_id,',')] + get_consumer_risks.SENET_KARSILIKSIZ[listfind(main_consumer_id_list,consumer_id,',')] + get_consumer_risks.CEK_KARSILIKSIZ[listfind(main_consumer_id_list,consumer_id,',')] + get_consumer_risks.CEK_ODENMEDI[listfind(main_consumer_id_list,consumer_id,',')]  + get_consumer_risks.SENET_ODENMEDI[listfind(main_consumer_id_list,consumer_id,',')] + get_consumer_risks.KEFIL_SENET_ODENMEDI[listfind(main_consumer_id_list,consumer_id,',')]+ get_consumer_risks.KEFIL_SENET_KARSILIKSIZ[listfind(main_consumer_id_list,consumer_id,',')]))#" style="width:100px;" class="box" readonly></td>
						<td><input type="text" name="last_use_risk#currentrow#" id="last_use_risk#currentrow#" value="#Tlformat(get_c_total.total_amount)#" <cfif kontrol_form_update eq 1>readonly</cfif> style="width:100%;" class="box" onkeyup="hesapla_satir(#currentrow#,1);return(FormatCurrency(this,event),4);"></td>
					<cfelse>
						<td><input type="text" name="last_risk#currentrow#" id="last_risk#currentrow#" value="#Tlformat(0)#" style="width:100%;" class="box" readonly></td>
						<td><input type="text" name="last_use_risk#currentrow#" id="last_use_risk#currentrow#" value="#Tlformat(0)#" style="width:100%;" <cfif kontrol_form_update eq 1>readonly</cfif> class="box" onkeyup="hesapla_satir(#currentrow#,1);return(FormatCurrency(this,event),4);"></td>
					</cfif>
				</tr> 	
			</cfoutput>
		</cfif>
		</tbody>
	</cf_grid_list>
</div>
<script type="text/javascript">
	row_count_2_q=<cfoutput>#get_guarantors.recordcount#</cfoutput>;
	function sil_2_q(sy)
	{
		var my_element=eval("form_basket.row_kontrol_2_q"+sy);
		my_element.value=0;
		var my_element=eval("frm_row_2_q"+sy);
		var my_element_2=eval("frm_row_2_q"+sy+"_2");
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
		newRow.setAttribute("name","frm_row_2_q" + row_count_2_q);
		newRow.setAttribute("id","frm_row_2_q" + row_count_2_q);		
		newRow.setAttribute("NAME","frm_row_2_q" + row_count_2_q);
		newRow.setAttribute("ID","frm_row_2_q" + row_count_2_q);		
		document.all.record_num_2_q.value=row_count_2_q;
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<input type="hidden" name="row_kontrol_2_q'+row_count_2_q+'" value="1"><a href="javascript://" onclick="sil_2_q(' + row_count_2_q + ');"><i class="fa fa-minus" title="<cf_get_lang dictionary_id='57463.Sil'>"></i></a>';
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<div class="form-group"><div class="input-group"><input type="text" name="q_consumer_name'+row_count_2_q+'" value="" style="width:110px;" class="boxtext"><input type="hidden" name="q_consumer_id'+row_count_2_q+'" value="" readonly><span class="input-group-addon icon-ellipsis btnPointer" onClick="pencr_ac(' + row_count_2_q + ');"></span></div></div>';
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<div class="form-group"><input type="text" name="q_tc_identy'+row_count_2_q+'" value="" class="boxtext"></div>';			
		
		newRow = document.getElementById("table1_2").insertRow(document.getElementById("table1_2").rows.length);
		newRow.className="color-row";
		newRow.setAttribute("name","frm_row_2_q" + row_count_2_q + "_2");
		newRow.setAttribute("id","frm_row_2_q" + row_count_2_q + "_2");		
		newRow.setAttribute("NAME","frm_row_2_q" + row_count_2_q + "_2");
		newRow.setAttribute("ID","frm_row_2_q" + row_count_2_q + "_2");
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '';
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<div class="form-group"><input type="text" name="last_risk'+row_count_2_q+'" value="0" style="width:100%;" readonly class="box"></div>';
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<div class="form-group"><input type="text" name="last_use_risk'+row_count_2_q+'" value="0" style="width:100%;" class="box" onkeyup="hesapla_satir('+row_count_2_q+',1);return(FormatCurrency(this,event));"></div>';
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
			if(eval('document.all.q_consumer_id'+i).value == eval('document.all.q_consumer_id'+no).value && eval('document.all.row_kontrol_2_q'+i).value == 1&& kontrol == 0)
			{
				alert("<cf_get_lang dictionary_id='33990.Aynı Üyeyi 2 Kere Kefil Olarak Ekleyemezsiniz'>!");
				kontrol = 1;
				sil_2(no);
			}
		kontrol_2 = 0;
		for(var j=1;j<=no;j++)
			if(eval('document.all.q_consumer_id'+j).value == document.all.consumer_id.value && eval('document.all.row_kontrol_2_q'+j).value == 1 && kontrol_2 == 0)
			{
				alert("<cf_get_lang dictionary_id='33991.Üyeyi kendisi İçin Kefil Olarak Ekleyemezsiniz'>!");
				kontrol_2 = 1;
				sil_2(no);
			}
		var get_consumer_1 = wrk_safe_query('sls_get_cnsmr_1','dsn',0,eval('document.all.q_consumer_id'+no).value);
		var get_consumer_2 = wrk_safe_query('sls_get_cnsmr_2','dsn2',0,eval('document.all.q_consumer_id'+no).value);
		if(get_consumer_1.recordcount)
			eval('document.all.q_tc_identy'+no).value = get_consumer_1.TC_IDENTY_NO;
		if(get_consumer_2.recordcount)
		{
			toplam_risk = parseFloat(get_consumer_2.BAKIYE) + parseFloat(get_consumer_2.SENET_KARSILIKSIZ) + parseFloat(get_consumer_2.CEK_KARSILIKSIZ) + parseFloat(get_consumer_2.CEK_ODENMEDI) + parseFloat(get_consumer_2.SENET_ODENMEDI) + parseFloat(get_consumer_2.KEFIL_SENET_ODENMEDI) + parseFloat(get_consumer_2.KEFIL_SENET_KARSILIKSIZ);
			eval('document.all.last_risk'+no).value = commaSplit(parseFloat(get_consumer_2.TOTAL_RISK_LIMIT) - toplam_risk);
			eval('document.all.last_use_risk'+no).value = commaSplit(parseFloat(get_consumer_2.TOTAL_RISK_LIMIT) - toplam_risk);
		}
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
			if(satir_risk > satir_risk_first)
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
				alert("<cf_get_lang dictionary_id='34002.Girdiğiniz Limit Tutarı Üyenin Kullanılabilir Limitinden Fazla Olamaz'>!");
				eval('form_basket.last_use_risk'+no).value = 0;
			}
		}
		toplam_limit_hesapla();		
	}
</script>
