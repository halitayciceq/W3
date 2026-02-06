<cfset get_queries = createObject("component", "V16/add_options/Mobius/Teklif/cfc/teklif")>
<style>
	.button {
		display: flex;
		justify-content: center;
		align-items: center;
		padding: 8px 12px 8px 16px;
		gap: 8px;
		height: 40px;
		width: 128px;
		border: none;
		background: #056bfa27;
		border-radius: 20px;
		cursor: pointer;
		float:right;
		}

		.lable {
		margin-top: 1px;
		font-size: 19px;
		line-height: 22px;
		color: #056dfa;
		letter-spacing: 1px;
		}
</style>
<cfparam name="attributes.stock_id" default="">
<cfparam name="attributes.product_id" default="">
<cfparam name="attributes.product_name" default="">
<cfparam name="attributes.spect_main_id" default="">
<cfparam name="attributes.spect_name" default="">
<cfparam name="attributes.is_submitted" default="">
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
		<cf_box>
			<cfform name="search_list" action="#request.self#?fuseaction=report.detail_report&event=det&report_id=6" method="post">
				<cf_box_search plus="0">
				<input type="hidden" name="is_submitted" id="is_submitted" value="1">
						<div class="form-group" id="item-product_name">
							<label><cf_get_lang dictionary_id='57657.Ürün'></label>
								<div class="input-group">
									<input type="hidden" name="stock_id" id="stock_id" value="<cfoutput>#attributes.stock_id#</cfoutput>">
									<input type="hidden" name="product_id" id="product_id" value="<cfoutput>#attributes.product_id#</cfoutput>">
									<input type="text"   name="product_name"  id="product_name"   value="<cfoutput>#attributes.product_name#</cfoutput>" passthrough="readonly=yes" onfocus="AutoComplete_Create('product_name','PRODUCT_NAME','PRODUCT_NAME,STOCK_CODE,','get_product_autocomplete','0','PRODUCT_ID,STOCK_ID','product_id,stock_id','','3','225');" autocomplete="off">
									<span class="input-group-addon icon-ellipsis btnPointer" title="" onClick="spect_remove();windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_product_names&field_id=search_list.stock_id&product_id=search_list.product_id&field_name=search_list.product_name&keyword='+encodeURIComponent(document.search_list.product_name.value),'list');"></span>
								</div>
						</div>
					
						<div class="form-group" id="item-spect_name">
							<label ><cf_get_lang dictionary_id='57647.Spec'></label>
								<div class="input-group">
									<input type="hidden" name="spect_main_id" id="spect_main_id" value="<cfoutput>#attributes.spect_main_id#</cfoutput>">
									<input type="text" readonly name="spect_name" id="spect_name" value="<cfoutput>#attributes.spect_name#</cfoutput>" style="width:110px;">
									<span class="input-group-addon icon-ellipsis btnPointer" title="" onClick="product_control();"></span>
								</div>
						</div>
						<div class="form-group">
							<cf_wrk_search_button button_type="4">
						</div>
				</cf_box_search>
			</cfform>
		</cf_box>
	</div>
<cfif attributes.is_submitted eq 1>
	<cfset get_bom = get_queries.get_bom_fnc(
		stock_id: attributes.stock_id, 
		spect_main_id: attributes.spect_main_id, 
		seviye:0)>
		<cfform name="rows" action="documents/report/mbs_spect_guncelle.cfm" method="post">
			<cf_grid_list>
				<thead>
					<tr>
						<th></th>
						<th>Seviye</th>
						<th>Ürün Kodu</th>
						<th>Ürün Adı / Operasyon</th>
						<th style="text-align:right;">Miktar</th>
						<th>Birim</th>
						<th></th>
					</tr>
				</thead>
				<tbody>
					<cfoutput query="get_bom">
						<tr>
							<td>#currentrow#</td>
							<td style="padding-left:#(SEVIYE*2)+1#em;">#SEVIYE#</td>
							<td style="padding-left:#(SEVIYE*2)+1#em;">#PRODUCT_CODE#</td>
							<td style="padding-left:#(SEVIYE*2)+1#em; <cfif len(OPERATION_TYPE)>color:##4900ff;</cfif>"><cfif len(PRODUCT_NAME)><input style="width:100%" type="text" readonly name="product_name_#currentrow#" id="product_name_#currentrow#" value="#PRODUCT_NAME#"><cfelse>#OPERATION_TYPE#</cfif></td>
							<!--- <td style="text-align:right;">#TLFORMAT(MIKTAR*USTTEN)#</td> --->
							<td style="text-align:right;">#TLFORMAT(MIKTAR)#</td>
							<td>#MAIN_UNIT#</td>
							<td>
								<cfif left(PRODUCT_CODE, 3) eq 150>
									<i onClick="windowopen('#request.self#?fuseaction=objects.popup_product_names&field_id=rows.degisti_#currentrow#&product_id=rows.product_id_#currentrow#&field_name=rows.product_name_#currentrow#&keyword='+encodeURIComponent(document.rows.product_name_#currentrow#.value),'list');" class="fa fa-pencil" title="Spec Güncelle "></i>
									<i onClick="sil(this,#currentrow#)" class="fa fa-minus" title="Sil "></i>
								</cfif>
							</td>
						</tr>
						<input type="hidden" name="d_product_id_#currentrow#" id="d_product_id_#currentrow#" value="#PRODUCT_ID#" >
						<input type="hidden" name="product_id_#currentrow#" id="product_id_#currentrow#" value="#PRODUCT_ID#" >
						<input type="hidden" name="degisti_#currentrow#" id="degisti_#currentrow#" value="0">
						<input type="hidden" name="spect_main_id_#currentrow#" id="spect_main_id_#currentrow#" value="#SPECT_MAIN_ID#">
					</cfoutput>
					<cfoutput>
						<input type="hidden" name="sayac" id="sayac" value="#get_bom.recordcount#">
						<input type="hidden" name="filtre_p" id="filtre_p" value="#attributes.product_id#">
						<input type="hidden" name="filtre_s" id="filtre_s" value="#attributes.spect_main_id#">
					</cfoutput>
				</tbody>
			</cf_grid_list>
		</cfform>
		<div class="row">
			<button onclick="kaydet()" class="button"> <span class="lable">Kaydet</span></button>
		</div>
	
</cfif>
<script>
	function spect_remove()/*Eğer ürün seçildikten sonra spect seçilmişse yeniden ürün seçerse ilgili spect'i kaldır.*/
	{
		document.search_list.spect_main_id.value = "";
		document.search_list.spect_name.value = "";	
	}
	function product_control()/*Ürün seçmeden spect seçemesin.*/
	{
		if(document.search_list.stock_id.value=="" || document.search_list.product_name.value=="" )
		{
		alert("<cf_get_lang dictionary_id ='36828.Spect Seçmek için öncelikle ürün seçmeniz gerekmektedir'>");
		return false;
		}
		else
		windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_spect_main&field_main_id=search_list.spect_main_id&field_name=search_list.spect_name&is_display=1&stock_id='+document.search_list.stock_id.value,'list');
	}
	function kaydet(){
		document.rows.submit();
	}
	function sil(a,row){
		var degisti = document.getElementById("degisti_"+row);
		if(degisti.value == 0){
			let tr = a.closest("tr");
			let tds = tr.querySelectorAll("td");
			let targetTd = tds[3];
			let input = targetTd.querySelector("input");
			input.style.textDecoration = "line-through";
			input.style.textDecorationColor = "red";
			degisti.value = -1;
		}
		else{
			let tr = a.closest("tr");
			let tds = tr.querySelectorAll("td");
			let targetTd = tds[3];
			let input = targetTd.querySelector("input");
			input.style.textDecoration = "none";
			input.style.textDecorationColor = "red";
			degisti.value = 0;
		}
	}
</script>