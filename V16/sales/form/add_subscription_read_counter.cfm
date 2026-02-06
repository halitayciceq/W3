<cfparam name="attributes.valid_name" default="#session.ep.name# #session.ep.surname#">
<cfparam name="attributes.valid_id" default="#session.ep.userid#">
<cfparam name="attributes.modal_id" default="">
<!--- sisteme ait kac adet sayac kayitli --->
<cfset dsn_product = "#dsn#_product">
<cfquery name="GET_COUNTER_COUNT" datasource="#DSN3#">
	SELECT
		SC.COUNTER_ID,
		P.PRODUCT_NAME,
		ISNULL(SC.PRICE,0) AS PRICE,
		SC.OTHER_MONEY,
		SC.PRODUCT_ID,
		SC.STOCK_ID,
		ISNULL(SC.INVOICE_PERIOD,1) AS INVOICE_PERIOD,
		SC.OTHER_MONEY,	
		SCT.COUNTER_TYPE		
	FROM
		SUBSCRIPTION_COUNTER SC
		JOIN #dsn_product#.PRODUCT AS P ON P.PRODUCT_ID = SC.PRODUCT_ID,
		SETUP_COUNTER_TYPE SCT
	WHERE	
		SC.SUBSCRIPTION_ID = #url.subscription_id# AND
		SC.COUNTER_TYPE_ID = SCT.COUNTER_TYPE_ID
	ORDER BY
		SC.COUNTER_ID
</cfquery> 
<!--- sisteme ait sayaclarda kac adetinde okuma kaydi var --->
<cfquery name="GET_COUNTER_ROW" datasource="#DSN3#">
	SELECT
		SC.COUNTER_ID COUNTER_ID,
		MAX(SCRR.FINISH_VALUE) START_VALUE
	FROM
		SUBSCRIPTION_COUNTER SC,
		SUBSCRIPTION_COUNTER_RESULT_ROW SCRR
	WHERE
		SC.SUBSCRIPTION_ID = #url.subscription_id# AND
		SC.COUNTER_ID = SCRR.COUNTER_ID
	GROUP BY
		SC.COUNTER_ID
</cfquery>
<cfif get_counter_count.recordcount neq get_counter_row.recordcount>
  	<cfset counter_id_list=''>
  	<cfif get_counter_row.recordcount>	  
	  <cfoutput query="get_counter_row">
	  	<cfset counter_id_list = listappend(counter_id_list,counter_id)>
	  </cfoutput>
  	</cfif>
	<cfquery name="GET_COUNTER_START" datasource="#DSN3#">
		SELECT
			SC.COUNTER_ID COUNTER_ID,
			SC.START_VALUE
		FROM
			SUBSCRIPTION_COUNTER SC
		WHERE
			SC.SUBSCRIPTION_ID = #url.subscription_id#
		<cfif listlen(counter_id_list,',')>
			AND SC.COUNTER_ID NOT IN(#counter_id_list#)
		</cfif>
	</cfquery>
	<cfquery name="GET_COUNTER" dbtype="query">
		SELECT
			*
		FROM
			GET_COUNTER_ROW
		UNION
		
		SELECT
			*
		FROM
			GET_COUNTER_START
		ORDER BY
			COUNTER_ID
	</cfquery>
<cfelse>
	<cfquery name="GET_COUNTER" datasource="#DSN3#">
		SELECT
			SC.COUNTER_ID,
			MAX(SCRR.FINISH_VALUE) START_VALUE
		FROM
			SUBSCRIPTION_COUNTER SC,
			SUBSCRIPTION_COUNTER_RESULT_ROW SCRR
		WHERE
			SC.SUBSCRIPTION_ID = #url.subscription_id# AND
			SC.COUNTER_ID = SCRR.COUNTER_ID
		GROUP BY
			SC.COUNTER_ID 
		ORDER BY 
			SC.COUNTER_ID
	</cfquery>
</cfif>
<cfquery name="GET_MONEY" datasource="#dsn#">
	SELECT
		*
	FROM
		SETUP_MONEY
	WHERE
		PERIOD_ID = #session.ep.period_id# AND
		MONEY_STATUS = 1
</cfquery>
<cfset counter_row = get_counter.recordcount>
<cfsavecontent variable="title_">
	<cf_get_lang dictionary_id ='41271.Sayaç Okuma'>/<cf_get_lang dictionary_id ='29502.Abone No'>: <cfoutput>#url.subscription_no#</cfoutput>
</cfsavecontent>
<cf_box title="#title_#" scroll="1" collapsable="1" resize="1" popup_box="#iif(isdefined("attributes.draggable"),1,0)#">
	<cfform name="add_read_counter" method="post" action="#request.self#?fuseaction=sales.emptypopup_add_subscription_read_counter" onsubmit="return (unformat_fields());">
		<cf_box_search>
			<cfoutput query="GET_MONEY">
				<input type="hidden" name="money_#money#" id="money_#money#" value="#wrk_round(rate2/rate1,session.ep.our_company_info.rate_round_num)#">
			</cfoutput>
			<input type="hidden" name="subscription_id" id="subscription_id" value="<cfoutput>#url.subscription_id#</cfoutput>">
			<input type="hidden" name="subscription_no" id="subscription_no" value="<cfoutput>#url.subscription_no#</cfoutput>">
			<input type="hidden" name="record_num" id="record_num" value="">
			<input type="hidden" name="other_money_value2" id="other_money_value2" value="<cfoutput>#session.ep.money2#</cfoutput>">
			<div class="form-group" id="item-valid_name">
				<div class="input-group">
					<input type="hidden" name="valid_id" id="valid_id" value="<cfoutput>#attributes.valid_id#</cfoutput>">
					<input type="text" name="valid_name" id="valid_name" placeholder="<cfoutput>#getLang('main','Kaydeden',57899)#</cfoutput>"  value="<cfoutput>#attributes.valid_name#</cfoutput>">
					<span class="input-group-addon btn_Pointer icon-ellipsis" href="javascript://" onClick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_positions&field_emp_id=add_read_counter.valid_id&field_name=add_read_counter.valid_name&select_list=1');"></span>
				</div>
			</div>	
			<div class="form-group" id="item-valid_date">
				<div class="input-group">
					<cfinput type="text" name="valid_date" placeholder="#getLang('main','Tarih',57742)#" value="#dateformat(now(),dateformat_style)#" validate="#validate_style#" maxlength="10">
					<span class="input-group-addon"><cf_wrk_date_image date_field="valid_date"></span>
				</div>
			</div>
		</cf_box_search>
       	<cf_grid_list>
            <thead>
                  <tr>
                    <th width="80"><cf_get_lang dictionary_id ='41282.Sayaç Tipi'></th>
                    <th width="250"><cf_get_lang dictionary_id ='57657.Ürün'></th>			
                    <th width="70"><cf_get_lang dictionary_id ='41294.Önceki Deger'></th>
                    <th width="70"><cf_get_lang dictionary_id ='41295.Son Değer'>*</th>
                    <th width="70"><cf_get_lang dictionary_id='58583.Fark'></th>
                    <th width="70"><cf_get_lang dictionary_id ='57638.Birim Fiyat'></th>
                    <th width="75"><cf_get_lang dictionary_id ='57492.Toplam'></th>
                  </tr>	
            </thead>
            <tbody id="table1">		
                <cfif get_counter.recordcount>
					<cfoutput query="get_counter">
						<tr id="frm_row#currentrow#">
							<td><input type="hidden" name="counter_id#currentrow#" id="counter_id#currentrow#" value="#get_counter_count.counter_id[currentrow]#">#get_counter_count.counter_type[currentrow]#</td>
							<td>
							<input type="hidden" name="name_product#currentrow#" id="name_product#currentrow#" value="#get_counter_count.product_name[currentrow]#">
							<input type="hidden" name="product_id#currentrow#" id="product_id#currentrow#" value="#get_counter_count.product_id[currentrow]#">
							<input type="hidden" name="stock_id#currentrow#" id="stock_id#currentrow#" value="#get_counter_count.stock_id[currentrow]#">
							#get_counter_count.product_name[currentrow]#
							</td>
							<td><input type="text" name="start_value#currentrow#" id="start_value#currentrow#" value="#tlformat(start_value,0)#" class="moneybox" readonly></td>
							<td><input type="text" name="finish_value#currentrow#" id="finish_value#currentrow#" value="" onBlur="fiyat_hesapla('#currentrow#');" onkeyup="return(FormatCurrency(this,event,4));" class="moneybox"></td>
							<td><input type="text" name="difference#currentrow#" id="difference#currentrow#" value="" class="moneybox" readonly></td>
							<td>
							<input type="hidden" name="other_money#currentrow#" id="other_money#currentrow#" value="#get_counter_count.other_money[currentrow]#">
							<input type="text" name="price#currentrow#" id="price#currentrow#" value="#tlformat((get_counter_count.price[currentrow]/get_counter_count.invoice_period[currentrow]),4)#" class="moneybox" readonly>
							</td>
							<td nowrap="nowrap"><input type="text" name="total#currentrow#" id="total#currentrow#" value="" class="moneybox" readonly>&nbsp;#get_counter_count.other_money[currentrow]#</td>
						</tr>
					</cfoutput>
                </cfif>
            </tbody>
		</cf_grid_list>
		<cf_box_footer>
			<cf_workcube_buttons is_upd='0' is_delete='0' add_function="#iif(isdefined("attributes.draggable"),DE("kontrol() && loadPopupBox('add_read_counter' , #attributes.modal_id#)"),DE(""))#">
		</cf_box_footer>
		<cfinclude template="detail_subscription_counter_result.cfm">
    </cfform>
</cf_box>
<script type="text/javascript">
row_count = <cfoutput>#counter_row#</cfoutput>;
document.add_read_counter.record_num.value=row_count;

function unformat_fields()
{
	for(var k=1;k<=row_count;k++)
	{
		if(eval("document.add_read_counter.finish_value"+k).value != "")
		{
			fiyat_hesapla(k);
			eval("document.add_read_counter.start_value"+k).value = filterNum(eval("document.add_read_counter.start_value"+k).value);
			eval("document.add_read_counter.finish_value"+k).value = filterNum(eval("document.add_read_counter.finish_value"+k).value);
			eval("document.add_read_counter.difference"+k).value = filterNum(eval("document.add_read_counter.difference"+k).value);
			eval("document.add_read_counter.price"+k).value = filterNum(eval("document.add_read_counter.price"+k).value,4);
			eval("document.add_read_counter.total"+k).value = filterNum(eval("document.add_read_counter.total"+k).value,4);
		}
	}
}

function kontrol()
{
	if (add_read_counter.valid_id.value == "" || add_read_counter.valid_name.value == "")
	{
		alert("<cf_get_lang dictionary_id ='41351.Kaydeden Seçmelisiniz'> !");
		return false;
	}
	
	if(add_read_counter.valid_date.value == "")
	{
		add_read_counter.valid_date.focus();
		alert("<cf_get_lang dictionary_id ='61893.Tarih Giriniz'> !");
		return false;
	}
	else
	{		
		if(!CheckEurodate(add_read_counter.valid_date.value,' Tarih'))
		{ 
		
			add_read_counter.valid_date.focus();
			return false;
		}
	}
	
	kontrol_row=0;
	for(var r=1;r<=row_count;r++)
	{
		if(eval("add_read_counter.finish_value"+r).value.length != 0)
		{
			if(filterNum(eval("document.add_read_counter.finish_value"+r).value) <= filterNum(eval("document.add_read_counter.start_value"+r).value))
			{	
				alert(r+".<cf_get_lang dictionary_id ='41352.Satır Son Okuma Değerini Kontrol Ediniz'> !");
				return false;
			}
		}

		if(eval("document.add_read_counter.finish_value"+r).value != "")
		{	
			kontrol_row++;
		}
	}
	
	if(kontrol_row ==0)
	{
		alert("<cf_get_lang dictionary_id ='41353.En Az Bir Satır Sayaç Kaydı Girmelisiniz'>")
		return false;
	}

	unformat_fields();
	
	return true;
}
function fiyat_hesapla(satir)
{
	if(eval("add_read_counter.finish_value"+satir).value.length != 0 && eval("add_read_counter.finish_value"+satir).value.length != 0)
	{
		eval("add_read_counter.difference" + satir).value = filterNum(eval("add_read_counter.finish_value"+satir).value) - filterNum(eval("add_read_counter.start_value"+satir).value);
		eval("add_read_counter.total" + satir).value = filterNum(eval("add_read_counter.difference"+satir).value) * filterNum(eval("add_read_counter.price"+satir).value,4);
		eval("add_read_counter.difference" + satir).value = commaSplit(eval("add_read_counter.difference" + satir).value,0);
		eval("add_read_counter.total" + satir).value = commaSplit(eval("add_read_counter.total" + satir).value,4);
	}
	else
	{
		eval("add_read_counter.difference" + satir).value = '';
		eval("add_read_counter.total" + satir).value = '';
	}
}
</script>
