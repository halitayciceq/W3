<cfif not isdefined("attributes.import_id") or not len(attributes.import_id)>
	<cfset attributes.import_id = 0>
</cfif>
<cfscript>
	comp = createObject("component","V16.sales.cfc.subscription_payment_plan_import");
	getImport = comp.get_byID(SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID:attributes.import_id);
	getImportRow = comp.get_import_row(SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID:attributes.import_id);
	get_sum = comp.get_import_summary(SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID:attributes.import_id);
	get_billed_row = comp.get_billed_row(SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID:attributes.import_id);

	satir_sayisi = 0;
	hata_sayisi = 0;
	abone_sayisi = 0;
	urun_sayisi = 0;
</cfscript>
<cfif not getImport.recordcount>
	<cfset hata  = 11>
    <cfsavecontent variable="message"><cf_get_lang dictionary_id='58943.Böyle Bir Kayıt Bulunmamaktadır'>!</cfsavecontent>
    <cfset hata_mesaj  = message>
    <cfinclude template="../../dsp_hata.cfm">
    <cfabort>
</cfif>
<cfset gsa = createObject("component","V16.settings.cfc.subscriptionPaymentPlanImportType")/>
<cfset get_payment_plan_import_type = gsa.GET_BYID(IMPORT_TYPE_ID:getImport.import_type_id)/>
<cfif get_payment_plan_import_type.recordcount eq 0>
	<cfset hata  = 11>
    <cfsavecontent variable="message"><cf_get_lang dictionary_id='58943.Böyle Bir Kayıt Bulunmamaktadır'>!</cfsavecontent>
    <cfset hata_mesaj  = message>
    <cfinclude template="../../dsp_hata.cfm">
	<cfabort>
</cfif>
<cfquery name="GET_PAYMETHOD" datasource="#dsn#">
	SELECT PAYMETHOD_ID, PAYMETHOD FROM SETUP_PAYMETHOD
</cfquery>
 <!--- yuvarlama degerleri basketten alinir --->
<cfquery name="get_round_num" datasource="#dsn3#">
	SELECT PRICE_ROUND_NUMBER,BASKET_TOTAL_ROUND_NUMBER FROM SETUP_BASKET WHERE BASKET_ID = 2
</cfquery>
<cfif get_round_num.recordcount and len(get_round_num.price_round_number)>
	<cfset round_num = get_round_num.price_round_number>
<cfelse>
	<cfset round_num = 4>
</cfif>
<!-- sil -->
<cf_catalystHeader>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cfform name="upd_plan_import" method="post" action=""  enctype="multipart/form-data">
		<cf_box>
			<input type="hidden" value="<cfoutput>#attributes.import_id#</cfoutput>" name="import_id" id="import_id">
			<cf_box_elements>
				<div class="col col-6 col-md-6 col-sm-12 col-xs-12">
					<div class="form-group" id="item-process_stage">
						<label class="col col-4 col-md-4 col-xs-12"><cf_get_lang dictionary_id='58859.Süreç'></label>
						<div class="col col-8 col-md-8 col-sm-8 col-xs-12">
							<cf_workcube_process is_upd='0' select_value="#getImport.process_stage#" is_detail='1'>
						</div>
					</div>
					<div class="form-group" id="item-import_name">
						<label class="col col-4 col-md-4 col-xs-12"><cf_get_lang dictionary_id="58233.Tanım"> * </label>
							<div class="col col-8 col-md-8 col-sm-8 col-xs-12">
							<cfinput type="text" name="import_name" id="import_name" value="#getImport.import_name#">
						</div>
					</div>
					<div class="form-group" id="item-import_type">
						<label class="col col-4 col-md-4 col-xs-12"><cf_get_lang dictionary_id="36085.Aktarım Tipi"> *</label>
						<div class="col col-8 col-md-8 col-sm-8 col-xs-12">
							<input type="hidden" name="import_type_id" id="import_type_id" value="<cfoutput>#getImport.IMPORT_TYPE_ID#</cfoutput>">
							<select name="import_type_id_s" id="import_type_id_s" disabled>
								<cfoutput query="get_payment_plan_import_type">
									<option value="#IMPORT_TYPE_ID#">#IMPORT_TYPE_NAME#</option>
								</cfoutput>
							</select>
						</div>
					</div>
					<div class="form-group" id="item_payment_date">
						<label class="col col-4 col-md-4 col-xs-12"><cf_get_lang dictionary_id="41112.Tahakkuk Tarihi"></label>
						<div class="col col-8 col-md-8 col-sm-8 col-xs-12">
							<div class="input-group">
								<cfoutput>#dateformat(getImport.payment_date, dateformat_style)#</cfoutput>
								<cfinput type="hidden" name="payment_date" id="payment_date" value="#dateformat(getImport.payment_date, dateformat_style)#">
							</div>
						</div>
					</div>
					<div class="form-group" id="item-description">
						<label class="col col-4 col-md-4 col-xs-12"><cf_get_lang dictionary_id="36199.Açıklama"> </label>
							<div class="col col-8 col-md-8 col-sm-8 col-xs-12">
							<cftextarea name="description" id="description" height="20" Width="500" value="#getImport.import_description#"></cftextarea>
						</div>
					</div>
					<!--- dosya tipinde ise --->
					<div class="form-group" id="item-document" <cfif get_payment_plan_import_type.import_type neq 1>style="display:none"</cfif>>
						<label class="col col-4 col-md-4 col-xs-12"><cf_get_lang dictionary_id="57691.Dosya"></label>
						<div class="col col-8 col-md-8 col-sm-8 col-xs-12">
							<a href="<cfoutput>/documents/sales/payment_plan_import/#getImport.File_name#</cfoutput>"><cfoutput>#getImport.File_name#</cfoutput></a>
						</div>
					</div>
					<!--- //dosya tipinde ise --->
					<!---tarih aralığı tipinde ise --->
					<div class="form-group" id="item_start_date" <cfif get_payment_plan_import_type.import_type neq 2>style="display:none"</cfif>>
						<label class="col col-4 col-md-4 col-xs-12"><cf_get_lang dictionary_id="58053.Başlangıç Tarihi"></label>
						<div class="col col-8 col-md-8 col-sm-8 col-xs-12">
							<div class="input-group">
								<cfoutput>#dateformat(getImport.start_date, dateformat_style)#</cfoutput>
								<cfinput type="hidden" name="start_date" id="start_date" value="#dateformat(getImport.start_date, dateformat_style)#">
							</div>
						</div>
					</div>
					<div class="form-group" id="item_finish_date" <cfif get_payment_plan_import_type.import_type neq 2>style="display:none"</cfif>>
						<label class="col col-4 col-md-4 col-xs-12"><cf_get_lang dictionary_id="57700.Bitiş Tarihi"></label>
						<div class="col col-8 col-md-8 col-sm-8 col-xs-12">
							<div class="input-group">
								<cfoutput>#dateformat(getImport.finish_date, dateformat_style)#</cfoutput>
								<cfinput type="hidden" name="finish_date" id="finish_date" value="#dateformat(getImport.finish_date, dateformat_style)#">
							</div>
						</div>
					</div>
					<!---//tarih aralığı tipinde ise --->
					<!--- satır açıklaması olsun mu --->
					<div class="form-group" id="item-row_description" <cfif not len(get_payment_plan_import_type.is_row_description) or not get_payment_plan_import_type.is_row_description>style="display:none"</cfif>>
						<label class="col col-4 col-md-4 col-xs-12"><cf_get_lang dictionary_id="59201.Satır Açıklaması"> * </label>
						<div class="col col-8 col-md-8 col-sm-8 col-xs-12">
							<cfoutput>#getImport.row_description#</cfoutput>
						</div>
					</div>
					<!--- //satır açıklaması olsun mu --->
				</div>
				<div class="col col-6 col-md-6 col-sm-12 col-xs-12">
					<cfoutput query="get_sum">
					<div class="form-group" id="item_total">
						<label class="col col-4 col-md-4 col-xs-12">#get_sum.money_type# <cf_get_lang dictionary_id="57492.Toplam"> :</label>
						<div class="col col-8 col-md-8 col-sm-8 col-xs-12">
							<div class="input-group">
								#TLFormat(get_sum.total,round_num)# #get_sum.money_type#
							</div>
						</div>
					</div>
					<div class="form-group" id="item_net_total">
						<label class="col col-4 col-md-4 col-xs-12">#get_sum.money_type# <cf_get_lang dictionary_id="57642.Net Toplam"> :</label>
						<div class="col col-8 col-md-8 col-sm-8 col-xs-12">
							<div class="input-group">
								<input type="hidden" name="net_total" id="net_total" value="<cfoutput>#get_sum.net_total#</cfoutput>">
								#TLFormat(get_sum.net_total,round_num)# #get_sum.money_type#
							</div>
						</div>
					</div>
					<cfif get_sum.BSMV_TOTAL gt 0>
						<div class="form-group" id="item_bsmv_total">
							<label class="col col-4 col-md-4 col-xs-12">#get_sum.money_type# <cf_get_lang dictionary_id="41101.BSMV Toplam"> :</label>
							<div class="col col-8 col-md-8 col-sm-8 col-xs-12">
								<div class="input-group">
									#TLFormat(get_sum.BSMV_TOTAL,round_num)# #get_sum.money_type#
								</div>
							</div>
						</div>
					</cfif>
					<cfif get_sum.OIV_TOTAL gt 0>
						<div class="form-group" id="item_bsmv_total">
							<label class="col col-4 col-md-4 col-xs-12">#get_sum.money_type# <cf_get_lang dictionary_id="50982.ÖİV"> :</label>
							<div class="col col-8 col-md-8 col-sm-8 col-xs-12">
								<div class="input-group">
									#TLFormat(get_sum.OIV_TOTAL,round_num)# #get_sum.money_type#
								</div>
							</div>
						</div>
					</cfif>
					<cfset satir_sayisi = satir_sayisi + get_sum.row_count>
					<cfset hata_sayisi = hata_sayisi + get_sum.error_count>
					<cfset abone_sayisi = abone_sayisi + get_sum.UNIQUE_SUBSCRIPTION_COUNT>
					<cfset urun_sayisi = urun_sayisi + get_sum.UNIQUE_PRODUCT_COUNT>
					</cfoutput>
					<div class="form-group" id="item_success_total">
						<label class="col col-4 col-md-4 col-xs-12"><cf_get_lang dictionary_id="41098.Başarılı Satır Sayısı"> :</label>
						<div class="col col-8 col-md-8 col-sm-8 col-xs-12">
							<div class="input-group">
								<cfoutput>#satir_sayisi#</cfoutput>
							</div>
						</div>
					</div>
					<cfif hata_sayisi gt 0>
						<div class="form-group" id="item_error_total">
							<label class="col col-4 col-md-4 col-xs-12"><cf_get_lang dictionary_id="41097.Hatalı Satır Sayısı"> :</label>
							<div class="col col-8 col-md-8 col-sm-8 col-xs-12">
								<div class="input-group">
									<cfoutput>#hata_sayisi#</cfoutput>
								</div>
							</div>
						</div>
					</cfif>
					<div class="form-group" id="item_total">
						<label class="col col-4 col-md-4 col-xs-12"><cf_get_lang dictionary_id="41091.Farklı Abone Sayısı"> :</label>
						<div class="col col-8 col-md-8 col-sm-8 col-xs-12">
							<div class="input-group">
								<cfoutput>#abone_sayisi#</cfoutput>
							</div>
						</div>
					</div>
					<div class="form-group" id="item_total">
						<label class="col col-4 col-md-4 col-xs-12"><cf_get_lang dictionary_id="41090.Farklı Ürün Sayısı"> :</label>
						<div class="col col-8 col-md-8 col-sm-8 col-xs-12">
							<div class="input-group">
								<cfoutput>#urun_sayisi#</cfoutput>
							</div>
						</div>
					</div>
				</div>
			</cf_box_elements>
			<cf_box_footer>
				<div class="col col-6">
					<cf_record_info query_name="getImport">
					<input type="hidden" value="<cfoutput>#getImport.record_emp#</cfoutput>" id="record_emp" name="record_emp">
					<input type="hidden" value="<cfoutput>#getImport.update_emp#</cfoutput>" id="update_emp" name="update_emp">
				</div>
				<div class="col col-6">
					<cfif not getImport.CONVERT_SUBSCRIPTION_PAYMENT_PLAN>
						<cf_workcube_buttons is_upd='1' delete_page_url='#request.self#?fuseaction=sales.list_subscription_payment_plan_import&event=del&import_id=#attributes.import_id#' add_function='kontrol()'>
					<cfelse>
						<font color="FF0000"><cf_get_lang dictionary_id="41089.Ödeme Planına Dönüştürülmüştür">!!</font>
						<cfif get_billed_row.recordcount>
							<cf_get_lang dictionary_id="41088.Faturalanan satır">: <cfoutput>#get_billed_row.recordcount#</cfoutput>
						<cfelse>
							<cf_workcube_buttons is_upd='0' is_insert="0" insert_info="#getLang('main',52)#" is_del="1" delete_page_url='#request.self#?fuseaction=sales.list_subscription_payment_plan_import&event=del&import_id=#attributes.import_id#&del_plan=1' add_function='kontrol()'>	
						</cfif>
					</cfif>
				</div>
			</cf_box_footer>
		</cf_box>
			<!-- sil -->					
			<input type="hidden" name="convert_submit" id="convert_submit" value="0">
			<!-- sil -->
		<cf_box title="#getLang('','Tahakkuk Satırları',62508)#">
			<cf_box_search>
				<div style="display:none" class="form-group">
					<cf_wrk_search_button button_type="4">
					<cf_workcube_file_action pdf='0' mail='0' doc='1' print='1'>
				</div>
			</cf_box_search>
			<cfset colspan_ = 18>
			<!-- sil -->
			<cf_grid_list>
				<thead>
					<tr>
						<th width="35"><cf_get_lang dictionary_id='58577.Sıra'></th>
						<th><cf_get_lang dictionary_id="29502.Abone No"></th>
						<th><cf_get_lang dictionary_id="57789.Özel Kod"></th>
						<th><cf_get_lang dictionary_id="57752.Vergi No"></th>
						<th><cf_get_lang dictionary_id="30707.Üye Kodu"></th>
						<th><cf_get_lang dictionary_id="30339.Üye Adı"></th>
						<th><cf_get_lang dictionary_id="58832.Abone"></th>
						<th><cf_get_lang dictionary_id="44019.Ürün"></th>
						<th><cf_get_lang dictionary_id="52750.Detail"></th>
						<th><cf_get_lang dictionary_id="47408.Satır Açıklama"></th>
						<th><cf_get_lang dictionary_id="41112.Tahakkuk Tarihi"></th>
						<th><cf_get_lang dictionary_id="58516.Ödeme Yöntemi"></th>
						<th><cf_get_lang dictionary_id="57635.Miktar"></th>
						<th><cf_get_lang dictionary_id="57638.Birim Fiyat"></th>
						<th><cf_get_lang dictionary_id="57489.Para Birimi"></th>
						<th><cf_get_lang dictionary_id="29534.Toplam Tutar"></th>
						<th><cf_get_lang dictionary_id="57638.Birim Fiyat"> <cf_get_lang dictionary_id="58560.İndirim"></th>
						<th><cf_get_lang dictionary_id="41087.Toplam Net Tutar"></th>
					</tr>
				</thead>
				<tbody>
					<cfif getImportRow.recordcount>
						<cfoutput query="getImportRow">
							<cfquery name="GET_PAYMETHOD_QoQ" dbtype="query">
								SELECT PAYMETHOD_ID, PAYMETHOD FROM GET_PAYMETHOD WHERE PAYMETHOD_ID =<cfif len(getImportRow.paymethod_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#getImportRow.paymethod_id#"><cfelse>0</cfif>
							</cfquery>
						<tr>
							<td width="35">#rownum#</td>
							<cfif getImportRow.ROW_RESULT>
								<td>#getImportRow.SUBSCRIPTION_NO#</td>
								<td>#getImportRow.SPECIAL_CODE#</td>
								<td>#getImportRow.TAXNO#</td>
								<td><cfif len(getImportRow.OZEL_KOD)>#getImportRow.OZEL_KOD#</cfif><cfif len(getImportRow.OZEL_KOD_1)> <cfif len(getImportRow.OZEL_KOD)>/</cfif> #getImportRow.OZEL_KOD_1#</cfif></td>
								<td>#getImportRow.FULLNAME#</td>
								<td>#getImportRow.SUBSCRIPTION_HEAD#</td>
								<td>#getImportRow.PRODUCT_NAME# #getImportRow.PROPERTY#</td>
								<td>#getImportRow.DETAIL#</td>
								<td>#getImportRow.row_description#</td>
								<td>#dateformat(getImportRow.payment_date, dateformat_style)#</td>
								<td>#GET_PAYMETHOD_QoQ.PAYMETHOD#</td>
								<td>#getImportRow.quantity#</td>
								<td>#TLFormat(getImportRow.amount,round_num)#</td>
								<td>#getImportRow.money_type#</td>
								<td>#TLFormat(getImportRow.row_total,round_num)#</td>
								<td>#TLFormat(getImportRow.discount_amount,round_num)#</td>
								<td>#TLFormat(getImportRow.ROW_NET_TOTAL,round_num)#</td>
							<cfelse>
								<cfset isError = true>
								<td colspan="17" bgcolor="red">#getImportRow.ROW_RESULT_MESSAGE#</td>
							</cfif>
						</tr> 
						</cfoutput>
					<cfelse>
					<tr>
						<td colspan="<cfoutput>#colspan_#</cfoutput>"><cf_get_lang dictionary_id='57484.Kayıt Yok'> !</td>
					</tr>
					</cfif>
				</tbody>
				<!-- sil -->
				<tfoot>
					<tr>
						<td colspan="<cfoutput>#colspan_#</cfoutput>">
							<cfif isdefined("isError") and isError>
								<!--- tekrar güncelle eklensin mi --->
							<cfelse>
								<cfif not getImport.CONVERT_SUBSCRIPTION_PAYMENT_PLAN>
									<cf_workcube_buttons is_upd='0' is_delete="0" insert_info="#getLang('','Ödeme Planına Dönüştürülmüştür',41089)#" add_function="kontrol2()">
								</cfif>
							</cfif>
						</td>
					</tr>
				</tfoot>
				<!-- sil -->
			</cf_grid_list>
		</cfform>
	</cf_box>
</div>

<script type="text/javascript">
function kontrol()
{

	if(document.upd_plan_import.import_name.value=="")
	{
		alert("<cf_get_lang dictionary_id="54327.Tanım Girmelisiniz">");
		return false;
	}
	
	return true;
}

function kontrol2()
{
	document.upd_plan_import.convert_submit.value=1
	return true;
}
</script>
