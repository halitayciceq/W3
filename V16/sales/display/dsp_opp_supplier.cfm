<cfsetting showdebugoutput="no">
<cfscript>
	CreateCompenent = CreateObject("component","/workdata/get_opp_supplier_rival");
	getSupplier = CreateCompenent.getOppSupplier(opp_id:attributes.opp_id);
	get_money = CreateCompenent.getMoney();
</cfscript>
<div id="div_list_supplier">
<cfform name="add_opp_supplier" method="post" action="#request.self#?fuseaction=sales.emptypopup_add_opp_supplier_act">
	<cf_grid_list>
		<cfoutput>
			<input type="hidden" name="opp_id" id="opp_id" value="#attributes.opp_id#">
			<input type="hidden" name="record_num" id="record_num" value="#getSupplier.RECORDCOUNT#">
		</cfoutput>
        <thead>
            <tr>
                <th width="20" class="text-center"><a href="javascript://" onClick="add_row();"><i class="fa fa-plus" title="<cf_get_lang dictionary_id='57582.Ekle'>" alt="<cf_get_lang dictionary_id='57582.Ekle'>"></i></a></th>
                <th><cf_get_lang dictionary_id='29533.Tedarikçi'>*</th>
                <th><cf_get_lang dictionary_id='57657.Ürün'></th>
                <th><cf_get_lang dictionary_id='58847.Marka'></th>
                <th><cf_get_lang dictionary_id='57486.Kategori'></th>
                <th class="text-right"><cf_get_lang dictionary_id='40917.Tahmini Gelir'></th>
                <th class="text-right"><cf_get_lang dictionary_id='41187.Tahmini Maliyet'></th>
                <th class="text-right"><cf_get_lang dictionary_id='40805.Tahmini Kar'></th>
                <th><cf_get_lang dictionary_id='57489.Para Birimi'></th>
            </tr>
        </thead>
        <tbody id="table1">
			<cfoutput query="getSupplier">
				<cfif len(brand_id)>
					<cfquery name="get_brand" datasource="#dsn1#">
						SELECT BRAND_NAME FROM PRODUCT_BRANDS WHERE BRAND_ID = #brand_id#
					</cfquery>
				</cfif>
				<cfif len(product_catid)>
					<cfquery name="get_product_cat" datasource="#dsn1#">
						SELECT PRODUCT_CAT FROM PRODUCT_CAT WHERE PRODUCT_CATID = #product_catid#
					</cfquery>
				</cfif>
				<tr name="frm_row#currentrow#" id="frm_row#currentrow#" class="color-row">
					<td>
						<input type="hidden" name="row_kontrol#currentrow#" id="row_kontrol#currentrow#" value="1">
						<a style="cursor:pointer" onclick="sil_supplier(#currentrow#);"><i class="fa fa-minus" title="<cf_get_lang dictionary_id='57463.Sil'>" alt="<cf_get_lang dictionary_id='57463.Sil'>"></i></a>
					</td>
					<td>
						<div class="form-group">
							<div class="input-group">
								<input type="hidden" name="company_id#currentrow#" id="company_id#currentrow#" value="#company_id#">
								<input type="text" name="company_name#currentrow#" id="company_name#currentrow#" value="#get_par_info(company_id,1,1,0)#" style="width:155px;" readonly>
								<span class="input-group-addon icon-ellipsis" onClick="pencereSupplier('#currentrow#');"></span>
							</div>
						</div>
					</td>
					<td>
						<div class="form-group">
							<div class="input-group">
								<input type="hidden" name="stock_id#currentrow#" id="stock_id#currentrow#" value="#stock_id#">
								<input type="hidden" name="product_id#currentrow#" id="product_id#currentrow#" value="#product_id#">
								<input type="text" name="product#currentrow#" id="product#currentrow#" value="#product_name#" style="width:155px;">
								<span class="input-group-addon icon-ellipsis" onclick="pencere_ac_product('#currentrow#');"></span>
							</div>
						</div>
					</td>
					<td>
						<div class="form-group">
							<div class="input-group">
								<input type="hidden" name="brand_id#currentrow#" id="brand_id#currentrow#" value="#brand_id#">
								<input type="text" name="brand_name#currentrow#" id="brand_name#currentrow#" value="<cfif len(brand_id)>#get_brand.brand_name#</cfif>" style="width:140px;">
								<span class="input-group-addon icon-ellipsis" onclick="pencere_ac_brand('#currentrow#');"></span>
							</div>
						</div>
					</td>
					<td>
						<div class="form-group">
							<div class="input-group">
								<input type="hidden" name="category#currentrow#" id="category#currentrow#" value="#product_catid#">
								<input type="text" name="category_name#currentrow#" id="category_name#currentrow#" value="<cfif len(product_catid)>#get_product_cat.product_cat#</cfif>" style="width:140px;">
								<span class="input-group-addon icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_product_cat_names&field_id=add_opp_supplier.category#currentrow#&field_name=add_opp_supplier.category_name#currentrow#&is_sub_category=1');"></span>
							</div>
						</div>
					</td>
					<td><div class="form-group"><input type="text" name="ESTIMATED_INCOME#currentrow#" id="ESTIMATED_INCOME#currentrow#" class="moneybox" value="#TLFormat(ESTIMATED_INCOME)#" onBlur="fiyat_hesapla(#currentrow#);" onkeyup="return(FormatCurrency(this,event));" style="width:100px;"></div></td>
					<td><div class="form-group"><input type="text" name="ESTIMATED_COST#currentrow#" id="ESTIMATED_COST#currentrow#" class="moneybox" value="#TLFormat(ESTIMATED_COST)#" onBlur="fiyat_hesapla(#currentrow#);" onkeyup="return(FormatCurrency(this,event));" style="width:100px;"></div></td>
					<td><div class="form-group"><input type="text" name="ESTIMATED_PROFIT#currentrow#" id="ESTIMATED_PROFIT#currentrow#" class="moneybox" value="#TLFormat(ESTIMATED_PROFIT)#" onkeyup="return(FormatCurrency(this,event));" style="width:100px;"></div></td>
					<td>
						<div class="form-group">
							<select name="money#currentrow#" id="money#currentrow#" style="width:60px;">
								<cfloop query="get_money">
									<option value="#get_money.money#" <cfif get_money.money is getSupplier.money_type>selected</cfif>>#get_money.money#</option>
								</cfloop>
							</select>
						</div>
					</td>
				</tr>	
			</cfoutput>
        </tbody>
		<tfoot>
        	<tr>
            	<td colspan="9">                    
                    <div style="float:left;"><cf_workcube_buttons is_upd='0' add_function='supplier_kontrol()' type_format="1"></div>
					<div style="float:left;" id="show_user_message1"></div>
                </td>
            </tr>
        </tfoot>
    </cf_grid_list>
</cfform>
</div>
<script type="text/javascript">
row_count=<cfoutput>#getSupplier.RECORDCOUNT#</cfoutput>;
function sil_supplier(sy)
{
	var my_element=eval("add_opp_supplier.row_kontrol"+sy);
	my_element.value=0;
	var my_element=eval("frm_row"+sy);
	my_element.style.display="none";
}
function add_row()
{
	row_count++;
	var newRow;
	var newCell;
	newRow = document.getElementById("table1").insertRow(document.getElementById("table1").rows.length);
	newRow.setAttribute("name","frm_row" + row_count);
	newRow.setAttribute("id","frm_row" + row_count);	
	newRow.setAttribute("NAME","frm_row" + row_count);
	newRow.setAttribute("ID","frm_row" + row_count);				
	document.add_opp_supplier.record_num.value=row_count;
	newCell = newRow.insertCell(newRow.cells.length);
	newCell.innerHTML = '<input type="hidden" name="row_kontrol'+row_count+'" value="1"><a style="cursor:pointer" onclick="sil_supplier(' + row_count + ');"><i class="fa fa-minus" title="<cf_get_lang dictionary_id='57463.Sil'>" alt="<cf_get_lang dictionary_id='57463.Sil'>"></i></a>';
	newCell = newRow.insertCell(newRow.cells.length);
	newCell.setAttribute('nowrap','nowrap');
	newCell.innerHTML = '<div class="form-group"><div class="input-group"><input type="text" name="company_name'+row_count+'" value="" style="width:155px;" readonly><input type="hidden" name="company_id'+row_count+'" value=""><span class="input-group-addon icon-ellipsis" onClick="pencereSupplier('+row_count+');"></span></div></div>';
	newCell = newRow.insertCell(newRow.cells.length);
	newCell.setAttribute('nowrap','nowrap');
	newCell.innerHTML = '<input type="hidden" name="stock_id' + row_count +'"><input type="hidden" name="product_id' + row_count +'"><div class="form-group"><div class="input-group"><input type="text" name="product' + row_count +'" style="width:155px;"><span class="input-group-addon icon-ellipsis" onclick="javascript:pencere_ac_product(' + row_count + ');"></span></div></div>';
	newCell = newRow.insertCell(newRow.cells.length);
	newCell.setAttribute('nowrap','nowrap');
	newCell.innerHTML = '<input type="hidden" name="brand_id' + row_count +'"><div class="form-group"><div class="input-group"><input type="text" name="brand_name' + row_count +'" style="width:140px;"><span class="input-group-addon icon-ellipsis" onclick="pencere_ac_brand('+ row_count +');"></span></div></div>';
	newCell = newRow.insertCell(newRow.cells.length);
	newCell.setAttribute('nowrap','nowrap');
	newCell.innerHTML ='<input type="hidden" name="category'+ row_count +'" id="category'+ row_count +'"><div class="form-group"><div class="input-group"><input type="text" style="width:140px;" readonly name="category_name'+ row_count +'" id="PRODUCT_CAT'+ row_count +'"><span class="input-group-addon icon-ellipsis" onclick="pencere_ac_category('+ row_count +');"></span></div></div>';
	newCell = newRow.insertCell(newRow.cells.length);
	newCell.setAttribute('nowrap','nowrap');
	newCell.innerHTML = '<div class="form-group"><input type="text" name="ESTIMATED_INCOME' + row_count +'" value="0" class="moneybox" onkeyup="return(FormatCurrency(this,event));" onBlur="fiyat_hesapla(' + row_count + ');" style="width:100px;"></div>';
	newCell = newRow.insertCell(newRow.cells.length);
	newCell.setAttribute('nowrap','nowrap');
	newCell.innerHTML = '<div class="form-group"><input type="text" name="ESTIMATED_COST' + row_count +'" value="0" class="moneybox" onkeyup="return(FormatCurrency(this,event));" onBlur="fiyat_hesapla(' + row_count + ');" style="width:100px;"></div>';
	newCell = newRow.insertCell(newRow.cells.length);
	newCell.setAttribute('nowrap','nowrap');
	newCell.innerHTML = '<div class="form-group"><input type="text" name="ESTIMATED_PROFIT' + row_count +'" value="0" class="moneybox" onkeyup="return(FormatCurrency(this,event));" style="width:100px;"></div>';
	newCell = newRow.insertCell(newRow.cells.length);
	newCell.innerHTML = '<div class="form-group"><select name="money' + row_count +'" style="width:60px;"><cfoutput query="get_money"><option value="#get_money.money#">#get_money.money#</option></cfoutput></select></div>';
}
<cfoutput>
function pencere_ac_product(no)
{
	openBoxDraggable('#request.self#?fuseaction=objects.popup_product_price_unit&field_stock_id=add_opp_supplier.stock_id'+ no +'&field_id=add_opp_supplier.product_id'+ no +'&field_name=add_opp_supplier.product'+ no);
}
function pencere_ac_brand(no)
{
	openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_product_brands&brand_id=add_opp_supplier.brand_id' + no +'&brand_name=add_opp_supplier.brand_name' + no +'');
}
function pencereSupplier(no)
{
	openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_pars&select_list=2&field_comp_name=add_opp_supplier.company_name' + no +'&field_comp_id=add_opp_supplier.company_id' + no + '');
}
function pencere_ac_category(no)
{
	openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_product_cat_names&field_id=add_opp_supplier.category' + no + '&field_name=add_opp_supplier.category_name' + no + '&is_sub_category=1');
}
function supplier_kontrol()
{
	static_row=0;
	for(r=1;r<=row_count;r++)		
	{
		if(eval("document.add_opp_supplier.row_kontrol"+r).value == 1)
		{	
			static_row++;
			deger_member_id = eval("document.add_opp_supplier.company_id"+r);
			if(deger_member_id.value=="")
			{
				alert(static_row+".Satır Tedarikçi Seçmelisiniz !");
				return false;
			}			
		}
	}
	
	for(r=1;r<=row_count;r++)
	{
		if(eval("document.add_opp_supplier.row_kontrol"+r).value == 1)
		{
			eval("document.add_opp_supplier.ESTIMATED_INCOME"+r).value = filterNum(eval("document.add_opp_supplier.ESTIMATED_INCOME"+r).value);
			eval("document.add_opp_supplier.ESTIMATED_COST"+r).value = filterNum(eval("document.add_opp_supplier.ESTIMATED_COST"+r).value);
			eval("document.add_opp_supplier.ESTIMATED_PROFIT"+r).value = filterNum(eval("document.add_opp_supplier.ESTIMATED_PROFIT"+r).value);
		}
	}
	AjaxFormSubmit(add_opp_supplier,'show_user_message1',0,'&nbsp;Kaydediliyor','&nbsp;Kaydedildi','#request.self#?fuseaction=sales.emptypopup_ajax_opp_supplier&opp_id=#attributes.opp_id#','div_list_supplier');return false;
}

function fiyat_hesapla(satir)
{
	if(eval("add_opp_supplier.ESTIMATED_INCOME"+satir).value.length != 0 && eval("add_opp_supplier.ESTIMATED_COST"+satir).value.length != 0)
	{
		eval("add_opp_supplier.ESTIMATED_PROFIT" + satir).value =  filterNum(eval("document.add_opp_supplier.ESTIMATED_INCOME"+satir).value) - filterNum(eval("document.add_opp_supplier.ESTIMATED_COST"+satir).value);
		eval("add_opp_supplier.ESTIMATED_PROFIT" + satir).value = commaSplit(eval("add_opp_supplier.ESTIMATED_PROFIT" + satir).value);
	}
	return true;
}
</script>
</cfoutput>