<cfif isdefined("attributes.finish_date") and isdate(attributes.finish_date)>
	<cf_date tarih = "attributes.finish_date">
<cfelse>
	<cfset attributes.start_date = now()>
</cfif>
<cfparam name="attributes.finish_date" default="#now()#">
<cfinclude template="../query/get_money.cfm">
<cfquery name="GET_PAYMENT_ROW_INVOICE" datasource="#DSN3#">
	SELECT
		*
	FROM
		SUBSCRIPTION_PAYMENT_PLAN_ROW
	WHERE
		SUBSCRIPTION_ID = #attributes.subscription_id# AND
		IS_BILLED = 0 AND
		IS_ACTIVE = 1 AND<!--- aktif satırlar --->
		PAYMENT_DATE <= #attributes.finish_date#
	ORDER BY
		PAYMENT_DATE
</cfquery>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cfsavecontent variable="title"><cf_get_lang dictionary_id='38689.Fatura Kes'></cfsavecontent>
    <cf_box title="#title#" collapsable="0" resize="0">
		<cfform name="list_payment_invoice" action="#request.self#?fuseaction=sales.popup_list_subscription_payment_plan&subscription_id=#attributes.subscription_id#" method="post">
			<input type="hidden" name="subscription_id" id="subscription_id" value="<cfoutput>#attributes.subscription_id#</cfoutput>">
			<input type="hidden" name="list_payment_row_id" id="list_payment_row_id" value=""><!--- fatura kesilecek payment_idler burada --->
			<cf_box_search more="0">
				<div class="form-group" id="form_ul_start_date">
					<div class="input-group">
						<cfsavecontent variable="message_1"><cf_get_lang dictionary_id='57742.Tarih'></cfsavecontent>
						<cfsavecontent variable="message"><cf_get_lang dictionary_id='57782.Lütfen Tarih Değerini Kontrol Ediniz'> !</cfsavecontent>
						<cfinput type="text" name="finish_date" value="#dateformat(attributes.finish_date, dateformat_style)#" validate="#validate_style#" maxlength="10" message="#message#" required="yes">
						<span class="input-group-addon"><cf_wrk_date_image date_field="finish_date"></span>
					</div>       
				</div>
				<div class="form-group">
					<cf_wrk_search_button button_type="4">
				</div>				
			</cf_box_search>
			<cf_grid_list sort="0">
				<thead>
					<tr>
						<th><cf_get_lang_main no='330.Tarih'></th>
						<th><cf_get_lang_main no='217.Açıklama'></th>
						<th><cf_get_lang_main no='224.Birim'></th>
						<th><cf_get_lang_main no='223.Miktar'></th>
						<th><cf_get_lang_main no='261.Tutar'></th>
						<th><cf_get_lang_main no='77.Para Br'></th>
						<th><cf_get_lang no='311.Satır Toplamı'></th>
						<th>İsk.(%)</th>
						<th><cf_get_lang no='312.Net Satır Top'></th>
						<th><cf_get_lang no='321.Faturaya Dahil'></th>
					</tr>
				</thead>
				<tbody>
					<cfoutput query="get_payment_row_invoice">
						<tr>
							<td>
								<div class="form-group">
									<div class="input-group">	
										<input type="hidden" name="payment_row_id#currentrow#" id="payment_row_id#currentrow#" value="#get_payment_row_invoice.subscription_payment_row_id#">
										<input type="text" name="payment_date#currentrow#" id="payment_date#currentrow#" class="boxtext" value="#DateFormat(get_payment_row_invoice.payment_date,dateformat_style)#" validate="#validate_style#" maxlength="10" disabled>
										<span class="input-group-addon"><cf_wrk_date_image date_field="payment_date#currentrow#"></span>
										<input type="hidden" name="product_id#currentrow#" id="product_id#currentrow#" value="#get_payment_row_invoice.product_id#">
										<input type="hidden" name="stock_id#currentrow#" id="stock_id#currentrow#" value="#get_payment_row_invoice.stock_id#">
									</div>	
								</div>
							</td>
							<td>
								<div class="form-group">
									<input type="text" name="detail#currentrow#" id="detail#currentrow#" class="boxtext" value="#get_payment_row_invoice.detail#" maxlength="50" disabled>
								</div>
							</td>
							<td>
								<div class="form-group">
									<input type="text" name="unit#currentrow#" id="unit#currentrow#" maxlength="10" value="#get_payment_row_invoice.unit#" readonly disabled>
								</div>
							</td>
							<td>
								<div class="form-group">
									<input type="text" name="quantity#currentrow#" id="quantity#currentrow#" validate="integer" class="box" value="#get_payment_row_invoice.quantity#" onBlur="return hesapla(#currentrow#);" disabled>
								</div>
							</td>
							<td>
								<div class="form-group">
									<input type="text" name="amount#currentrow#" id="amount#currentrow#" class="moneybox" value="#TLFormat(get_payment_row_invoice.amount)#" onkeyup="return(FormatCurrency(this,event));" onBlur="return hesapla(#currentrow#);" disabled>
								</div>
							</td>
							<td>
								<div class="form-group">			
									<select name="money_type_row#currentrow#" id="money_type_row#currentrow#" class="boxtext" disabled>
										<cfset money_type_=  get_payment_row_invoice.money_type>
										<cfloop query="get_money">
											<option value="#money#" <cfif get_money.money eq money_type_>selected</cfif>>#money#</option>
										</cfloop>
									</select>	
								</div>			
							</td>
							<td>
								<div class="form-group">
									<input type="text" name="row_total#currentrow#" id="row_total#currentrow#" value="#TLFormat(get_payment_row_invoice.ROW_TOTAL)#" onkeyup="return(FormatCurrency(this,event));" disabled class="box">
								</div>
							</td>
							<td>
								<div class="form-group">
									<input type="text" name="discount#currentrow#" id="discount#currentrow#" value="#TLFormat(get_payment_row_invoice.DISCOUNT)#" validate="integer" maxlength="3" onBlur="return indirim_hesapla(#currentrow#);" disabled class="box">
								</div>
							</td>
							<td>
								<div class="form-group">
									<input type="text" name="row_net_total#currentrow#" id="row_net_total#currentrow#" value="#TLFormat(get_payment_row_invoice.ROW_NET_TOTAL)#" onkeyup="return(FormatCurrency(this,event));" class="box">
								</div>
							</td>
							<td>
								<div class="form-group">
									<input type="checkbox" name="is_only_invoice#currentrow#" id="is_only_invoice#currentrow#">
								</div>
							</td>
						</tr>
					</cfoutput>
				</tbody>
			</cf_grid_list>
			<div class="ui-info-bottom flex-end">
				<cf_workcube_buttons is_upd='0' add_function='kontrol()'>
			</div>
		</cfform>
	</cf_box>
</div>
<script type="text/javascript">
	function kontrol()
	{
		var checked_kontrol = 0;
		document.list_payment_invoice.list_payment_row_id.value ='';
		<cfif get_payment_row_invoice.recordcount gt 1>
			for(var i=1;i<=<cfoutput>#get_payment_row_invoice.recordcount#</cfoutput>;i++)
				if(eval('document.list_payment_invoice.is_only_invoice'+i).checked==true)
				{
					checked_kontrol = checked_kontrol + 1;
					if(document.list_payment_invoice.list_payment_row_id.value.length==0) ayirac=''; else ayirac=',';
						document.list_payment_invoice.list_payment_row_id.value = document.list_payment_invoice.list_payment_row_id.value+ayirac+eval('document.list_payment_invoice.payment_row_id'+i).value;
				}
		<cfelse>
			if(document.list_payment_invoice.is_only_invoice1.checked==true)
			{
				checked_kontrol = checked_kontrol +1;
				document.list_payment_invoice.list_payment_row_id.value = document.list_payment_invoice.payment_row_id1.value;				
			}
		</cfif>
		if(checked_kontrol==0)
		{
			alert("<cf_get_lang no='322.Ödeme Planı Şeçimi Yapınız'> !");
			return false;
		}
		else
		{
			open_invoice();
		}
	}
	
	function open_invoice()
	{
		window.opener.add_invoice.list_payment_row_id.value = document.list_payment_invoice.list_payment_row_id.value;
		if(window.opener.form_basket.invoice_city_id != undefined)
			window.opener.add_invoice.city_id.value = window.opener.form_basket.invoice_city_id.value;
		if(window.opener.form_basket.invoice_county_id != undefined)
			window.opener.add_invoice.county_id.value = window.opener.form_basket.invoice_county_id.value;
	
		if(window.opener.form_basket.invoice_address != undefined)
			adres_= window.opener.form_basket.invoice_address.value;
		else
			adres_ = '';
		if(window.opener.form_basket.invoice_postcode != undefined && window.opener.form_basket.invoice_postcode.value!='')
			adres_ = adres_+' '+window.opener.form_basket.invoice_postcode.value;
		if(window.opener.form_basket.invoice_semt != undefined && window.opener.form_basket.invoice_semt.value!='')
			adres_ = adres_+' '+window.opener.form_basket.invoice_semt.value;
		if(window.opener.form_basket.invoice_county != undefined && window.opener.form_basket.invoice_county.value!='')
			adres_ = adres_+' '+window.opener.form_basket.invoice_county.value;
		if(window.opener.form_basket.invoice_city != undefined && window.opener.form_basket.invoice_city.value!='')
			adres_ = adres_+' '+window.opener.form_basket.invoice_city.value;
		if(window.opener.form_basket.invoice_country != undefined && window.opener.form_basket.invoice_country.value!='')
			adres_ = adres_+' '+window.opener.form_basket.invoice_country.value;		
		window.opener.add_invoice.adres.value = adres_;
	
		window.opener.add_invoice.submit();
		window.close();
	}
</script>

