<cfquery name="GET_COUNTER_RESULT" datasource="#DSN3#">
	SELECT
		SCR.VALID_EMP,
		SCR.VALID_DATE,
		SCR.OTHER_MONEY,
		SCR.IS_INVOICE,
		SC.SUBSCRIPTION_NO
	FROM
		SUBSCRIPTION_COUNTER_RESULT SCR,
		SUBSCRIPTION_CONTRACT SC
	WHERE
		SCR.COUNTER_RESULT_ID = #url.result_id# AND
		SCR.SUBSCRIPTION_ID = SC.SUBSCRIPTION_ID		
</cfquery>
<cfquery name="GET_COUNTER_RESULT_ROW" datasource="#DSN3#">
	SELECT
		SUBSCRIPTION_COUNTER_RESULT_ROW.*,
		SETUP_COUNTER_TYPE.COUNTER_TYPE,
		SUBSCRIPTION_COUNTER.IS_INVOICE AS C_IS_INVOICE

	FROM
		SUBSCRIPTION_COUNTER_RESULT_ROW,
		SUBSCRIPTION_COUNTER,
		SETUP_COUNTER_TYPE
		
	WHERE
		COUNTER_RESULT_ID =#url.result_id# AND
		SUBSCRIPTION_COUNTER_RESULT_ROW.COUNTER_ID = SUBSCRIPTION_COUNTER.COUNTER_ID AND
		SUBSCRIPTION_COUNTER.COUNTER_TYPE_ID = SETUP_COUNTER_TYPE.COUNTER_TYPE_ID		
</cfquery>
<cfset counter_row = get_counter_result_row.recordcount>
<!--- <cfsavecontent variable="right_">
	<a href="javascript://" onClick="windowopen('<cfoutput>#request.self#?fuseaction=sales.popup_add_subscription_read_counter&result_id=#attributes.result_id#&subscription_id=#attributes.subscription_id#&subscription_no=#get_counter_result.subscription_no#</cfoutput>','page');"><img src="/images/plus1.gif" title="<cf_get_lang_main no='170.Ekle'>"></a>
</cfsavecontent> --->
<cfparam name="attributes.modal_id" default="">
<cf_box title="#getLang('sales',469)# / #getLang('main',1705)# : #get_counter_result.subscription_no#" scroll="1" collapsable="1" resize="1" popup_box="#iif(isdefined("attributes.draggable"),1,0)#">
	<cfform name="upd_read_counter" method="post" action="#request.self#?fuseaction=sales.emptypopup_upd_subscription_read_counter" onsubmit="return (unformat_fields());">
		<cf_box_search more="0">
			<input type="hidden" name="result_id" id="result_id" value="<cfoutput>#url.result_id#</cfoutput>">
			<input type="hidden" name="subscription_id" id="subscription_id" value="<cfoutput>#url.subscription_id#</cfoutput>">
			<input type="hidden" name="record_num" id="record_num" value="<cfoutput>#get_counter_result_row.recordcount#</cfoutput>">
			<div class="form-group">
				<label><cf_get_lang_main no='487.Kaydeden'></label>
				<div class="input-group">
					<input type="hidden" name="valid_id" id="valid_id" value="<cfoutput>#get_counter_result.valid_emp#</cfoutput>">
					<input type="text" name="valid_name" id="valid_name" value="<cfoutput>#get_emp_info(get_counter_result.valid_emp,0,0)#</cfoutput>">
					<span class="input-group-addon icon-ellipsis" href="javascript://" onClick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_positions&field_emp_id=upd_read_counter.valid_id&field_name=upd_read_counter.valid_name&select_list=1');"></span>
				</div>
			</div>
			<div class="form-group">
				<label><cf_get_lang_main no ='330.Tarih'></label>
				<div class="input-group">
					<cfinput type="text" name="valid_date_upd" value="#dateformat(get_counter_result.valid_date,dateformat_style)#" validate="#validate_style#" maxlength="10">
					<span class="input-group-addon"><cf_wrk_date_image date_field="valid_date_upd"></span>
				</div>
			</div>
		</cf_box_search>
		<cf_grid_list id="table1">
			<thead>
				<tr>
					<th width="200"><cf_get_lang no ='480.Sayaç Tipi'></th>
					<th width="200"><cf_get_lang_main no ='245.Ürün'></th>			
					<th><cf_get_lang no ='492.Ön Deger'></th>
					<th><cf_get_lang no ='493.Son Değer'>*</th>
					<th><cf_get_lang_main no='1171.Fark'></th>
					<th><cf_get_lang_main no ='226.Birim Fiyat'></th>
					<th><cf_get_lang_main no ='80.Toplam'></th>
				</tr>		
			</thead>	
			<cfoutput query="get_counter_result_row">
				<cfquery name="CONTROL_ROW_INVOICE" datasource="#DSN3#"><!--- Satır faturalanmis mi --->
					SELECT
						COUNT(SUBSCRIPTION_INVOICE_ID) AS INVOICE_COUNT
					FROM
						SUBSCRIPTION_CONTRACT_INVOICE
					WHERE
						SUBSCRIPTION_ID = #url.subscription_id# AND
						RESULT_ROW_ID IS NOT NULL AND 
						RESULT_ROW_ID = #get_counter_result_row.counter_result_row_id[currentrow]#
				</cfquery>	
				<tbody>	
					<tr id="frm_row#currentrow#">
						<td>
							<input type="hidden" name="result_row_id#currentrow#" id="result_row_id#currentrow#" value="#get_counter_result_row.counter_result_row_id#">
							<input type="hidden" name="counter_id#currentrow#" id="counter_id#currentrow#" value="#get_counter_result_row.counter_id#">#get_counter_result_row.counter_type#
						</td>
						<td>
							<input type="hidden" name="name_product#currentrow#" id="name_product#currentrow#" value="#name_product#">
							<input type="hidden" name="product_id#currentrow#" id="product_id#currentrow#" value="#product_id#">
							<input type="hidden" name="stock_id#currentrow#" id="stock_id#currentrow#" value="#stock_id#">
							#name_product#			
						</td>
						<td><input type="text" name="start_value#currentrow#" id="start_value#currentrow#" value="#tlformat(start_value,0)#" onkeyup="return(FormatCurrency(this,event,0));" class="moneybox" readonly></td>
						<td>
							<cfif control_row_invoice.invoice_count gt 0><!--- Faturalanmis mi satir --->
								<input type="text" name="finish_value#currentrow#" id="finish_value#currentrow#" value="#tlformat(finish_value,0)#" onBlur="fiyat_hesapla('#currentrow#');" onkeyup="return(FormatCurrency(this,event,0));" class="moneybox" readonly>
							<cfelse>
								<input type="text" name="finish_value#currentrow#" id="finish_value#currentrow#" value="#tlformat(finish_value,0)#" onBlur="fiyat_hesapla('#currentrow#');" onkeyup="return(FormatCurrency(this,event,0));" class="moneybox" >
							</cfif>
						</td>
						<td><input type="text" name="difference#currentrow#" id="difference#currentrow#" value="#tlformat(counter_difference,0)#" class="moneybox" readonly></td>
						<td>
							<input type="hidden" name="other_money#currentrow#" id="other_money#currentrow#" value="#other_money#">
							<input type="text" name="price#currentrow#" id="price#currentrow#" value="#tlformat(price,4)#" class="moneybox" readonly>
						</td>
						<td nowrap="nowrap"><input type="text" name="total#currentrow#" id="total#currentrow#" value="#tlformat(total,4)#" class="moneybox" readonly>&nbsp; #other_money#</td>
					</tr>
				</tbody>
			</cfoutput>
		</cf_grid_list>
		<cf_box_footer>
			<cfquery name="GET_LAST_RESULT" datasource="#DSN3#" maxrows="1">
				SELECT
					COUNTER_RESULT_ID
				FROM
					SUBSCRIPTION_COUNTER_RESULT
				WHERE
					SUBSCRIPTION_ID = #url.subscription_id#
				ORDER BY
					COUNTER_RESULT_ID DESC
			</cfquery>
			<cfif (get_last_result.counter_result_id eq result_id) and get_counter_result.is_invoice eq 0>
				<cf_workcube_buttons is_upd='1' is_delete='0' add_function="#iif(isdefined("attributes.draggable"),DE("kontrol() && loadPopupBox('upd_read_counter' , #attributes.modal_id#)"),DE(""))#">
			</cfif>
		</cf_box_footer>
	</cfform>
</cf_box>
<script type="text/javascript">
	row_count = <cfoutput>#counter_row#</cfoutput>;
	function unformat_fields()
	{
		for(var k=1;k<=row_count;k++)
		{
			if(eval("document.upd_read_counter.finish_value"+k).value != "")
			{
				fiyat_hesapla(k);
				eval("document.upd_read_counter.start_value"+k).value = filterNum(eval("document.upd_read_counter.start_value"+k).value);
				eval("document.upd_read_counter.finish_value"+k).value = filterNum(eval("document.upd_read_counter.finish_value"+k).value);
				eval("document.upd_read_counter.difference"+k).value = filterNum(eval("document.upd_read_counter.difference"+k).value);
				eval("document.upd_read_counter.price"+k).value = filterNum(eval("document.upd_read_counter.price"+k).value,4);
				eval("document.upd_read_counter.total"+k).value = filterNum(eval("document.upd_read_counter.total"+k).value);
			}
		}
	}
	function kontrol()
	{
		if (upd_read_counter.valid_id.value == "" || upd_read_counter.valid_name.value == "")
		{
			alert("<cf_get_lang no ='549.Kaydeden Seçmelisiniz'> !");
			return false;
		}
		
		if(upd_read_counter.valid_date_upd.value == "")
		{
			upd_read_counter.valid_date_upd.focus();
			alert("<cf_get_lang_main no ='1091.Tarih Giriniz'> !");
			return false;
		}
		else
		{		
			if(!CheckEurodate(upd_read_counter.valid_date_upd.value,' <cf_get_lang_main no ="330.Tarih">'))
			{ 
			
				upd_read_counter.valid_date_upd.focus();
				return false;
			}
		}
		
		for(var r=1;r<=row_count;r++)
		{
			if(eval("upd_read_counter.finish_value"+r).value.length != 0)
			{
				if(filterNum(eval("document.upd_read_counter.finish_value"+r).value) <= filterNum(eval("document.upd_read_counter.start_value"+r).value))
				{	
					alert(r+".<cf_get_lang no ='550.Satır Son Okuma Değerini Kontrol Ediniz'> !");
					return false;
				}
			}
			else
			{
				alert(r+".<cf_get_lang no ='581.Satır Son Okuma Değerini Giriniz'> !");
				return false;
			}		
	
		}
		unformat_fields()
		return true;
	}
	function fiyat_hesapla(satir)
	{
		if(eval("upd_read_counter.finish_value"+satir).value.length != 0 && eval("upd_read_counter.finish_value"+satir).value.length != 0)
		{
			eval("upd_read_counter.difference" + satir).value = filterNum(eval("upd_read_counter.finish_value"+satir).value) - filterNum(eval("upd_read_counter.start_value"+satir).value);
			eval("upd_read_counter.total" + satir).value = filterNum(eval("upd_read_counter.difference"+satir).value,4) * filterNum(eval("upd_read_counter.price"+satir).value,4);
			eval("upd_read_counter.difference" + satir).value = commaSplit(eval("upd_read_counter.difference" + satir).value,0);
			eval("upd_read_counter.total" + satir).value = commaSplit(eval("upd_read_counter.total" + satir).value,4);
		}
		else
		{
			eval("upd_read_counter.difference" + satir).value = '';
			eval("upd_read_counter.total" + satir).value = '';
		}
	}
</script>
