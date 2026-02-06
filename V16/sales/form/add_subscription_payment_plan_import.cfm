<cf_catalystHeader>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box>
		<cfform name="add_plan_import" method="post" action=""  enctype="multipart/form-data">
			<cfif not isdefined("attributes.import_type_id")>
				<cfinclude template="../../sales/query/get_payment_plan_import_type.cfm">
				<cf_box_elements>
					<div class="col col-4 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
						<div class="form-group" id="item-import_type">
							<label class="col col-4 col-md-4 col-xs-12"><cf_get_lang dictionary_id="36085.Aktarım Tipi"> *</label>
							<div class="col col-8 col-md-8 col-sm-8 col-xs-12">
								<select name="import_type_id" id="import_type_id">
									<cfoutput query="get_payment_plan_import_type">
										<option value="#IMPORT_TYPE_ID#">#IMPORT_TYPE_NAME#</option>
									</cfoutput>
								</select>
							</div>
						</div>
					</div>
				</cf_box_elements>
				<cf_box_footer>
					<cf_workcube_buttons type_format='1' is_upd='0' is_delete='0' add_function='refrehPage()'>
				</cf_box_footer>
			<cfelseif isdefined("attributes.import_type_id") and len(attributes.import_type_id)>
				<cfset gsa = createObject("component","V16.settings.cfc.subscriptionPaymentPlanImportType")/>
				<cfset get_payment_plan_import_type = gsa.GET_BYID(IMPORT_TYPE_ID:attributes.import_type_id)/>
				<cfif get_payment_plan_import_type.recordcount eq 0>
					<cfset hata  = 11>
					<cfsavecontent variable="message"><cf_get_lang dictionary_id='58943.Böyle Bir Kayıt Bulunmamaktadır'>!</cfsavecontent>
						<cfset hata_mesaj  = message>
					<cfinclude template="../../dsp_hata.cfm">
					<cfabort>
				</cfif>
				<cf_box_elements>
					<div class="col col-4 col-md-6 col-sm-12 col-xs-12" type="column" index="1" sort="true">
						<div class="form-group" id="item-process_stage">
							<label class="col col-4 col-md-3 col-xs-12"><cf_get_lang dictionary_id="58859.Süreç"></label>
							<div class="col col-8 col-md-9 col-sm-9 col-xs-12">
								<cf_workcube_process is_upd='0' is_detail='0'>
							</div>
						</div>
						<div class="form-group" id="item-import_name">
							<label class="col col-4 col-md-4 col-xs-12"><cf_get_lang dictionary_id="58233.Tanım"> * </label>
							<div class="col col-8 col-md-8 col-sm-8 col-xs-12">
								<cfinput type="text" name="import_name" id="import_name">
							</div>
						</div>
						<div class="form-group" id="item-import_type">
							<label class="col col-4 col-md-4 col-xs-12"><cf_get_lang dictionary_id="36085.Aktarım Tipi"> *</label>
							<div class="col col-8 col-md-8 col-sm-8 col-xs-12">
								<input type="hidden" name="import_type_id" id="import_type_id" value="<cfoutput>#attributes.IMPORT_TYPE_ID#</cfoutput>">
								<select name="import_type_id_s" id="import_type_id_s" disabled>
									<cfoutput query="get_payment_plan_import_type">
										<option value="#IMPORT_TYPE_ID#">#IMPORT_TYPE_NAME#</option>
									</cfoutput>
								</select>
							</div>
						</div>
						<div class="form-group" id="item_payment_date" <cfif not len(get_payment_plan_import_type.IS_PAYMENT_DATE) or not get_payment_plan_import_type.IS_PAYMENT_DATE>style="display:none"</cfif>>
							<label class="col col-4 col-md-4 col-xs-12"><cf_get_lang dictionary_id="41112.Tahakkuk Tarihi"></label>
							<div class="col col-8 col-md-8 col-sm-8 col-xs-12">
								<div class="input-group">
									<cfinput type="text" name="payment_date" id="payment_date" value="#dateformat(now(),dateformat_style)#" validate="#validate_style#" maxlength="10" message="#getLang('','Tahakkuk Tarihini Kontrol Ediniz',41111)#">
									<span class="input-group-addon"><cf_wrk_date_image date_field="payment_date"></span>
								</div>
							</div>
						</div>
						<div class="form-group" id="item-description">
							<label class="col col-4 col-md-4 col-xs-12"><cf_get_lang dictionary_id="36199.Açıklama"> </label>
							<div class="col col-8 col-md-8 col-sm-8 col-xs-12">
								<cftextarea name="description" id="description" height="20" Width="500"/>
							</div>
						</div>
						<!--- dosya tipinde ise --->
						<div class="form-group" id="item-document" <cfif get_payment_plan_import_type.import_type neq 1>style="display:none"</cfif>>
							<label class="col col-4 col-md-4 col-xs-12"><cf_get_lang dictionary_id="57691.Dosya"></label>
							<div class="col col-8 col-md-8 col-sm-8 col-xs-12">
								<input type="file" name="uploaded_file" id="uploaded_file" style="width:200px;"></span>
							</div>
						</div>
						<!--- //dosya tipinde ise --->
						<!---tarih aralığı tipinde ise --->
						<div class="form-group" id="item_start_date" <cfif get_payment_plan_import_type.import_type neq 2>style="display:none"</cfif>>
							<label class="col col-4 col-md-4 col-xs-12"><cf_get_lang dictionary_id="58053.Başlangıç Tarihi"></label>
							<div class="col col-8 col-md-8 col-sm-8 col-xs-12">
								<div class="input-group">
									<cfinput type="text" name="start_date" id="start_date" value="" validate="#validate_style#" maxlength="10" message="#getLang('','Lütfen Başlangıç Tarihi Kontrol Ediniz',41039)#">
									<span class="input-group-addon"><cf_wrk_date_image date_field="start_date"></span>
								</div>
							</div>
						</div>
						<div class="form-group" id="item_finish_date" <cfif get_payment_plan_import_type.import_type neq 2>style="display:none"</cfif>>
							<label class="col col-4 col-md-4 col-xs-12"><cf_get_lang dictionary_id="57700.Bitiş Tarihi"></label>
							<div class="col col-8 col-md-8 col-sm-8 col-xs-12">
								<div class="input-group">
									<cfinput type="text" name="finish_date" id="finish_date" value="" validate="#validate_style#" maxlength="10" message="#getLang('','Lütfen Bitiş Tarihi Kontrol Ediniz',41040)#">
									<span class="input-group-addon"><cf_wrk_date_image date_field="finish_date"></span>
								</div>
							</div>
						</div>
						<!---//tarih aralığı tipinde ise --->
						<!--- satır açıklaması olsun mu --->
						<div class="form-group" id="item-row_description" <cfif not len(get_payment_plan_import_type.is_row_description) or not get_payment_plan_import_type.is_row_description>style="display:none"</cfif>>
							<label class="col col-4 col-md-4 col-xs-12"><cf_get_lang dictionary_id="39513.Satır Açıklaması"> * </label>
							<div class="col col-8 col-md-8 col-sm-8 col-xs-12">
								<cfinput type="text" name="row_description" id="row_description" maxlength="100">
							</div>
						</div>
						<!--- //satır açıklaması olsun mu --->
					</div>
					<div class="col col-4 col-md-6 col-sm-12 col-xs-12" type="column" index="2" sort="true">
						<span><cfoutput>#DecodeForHTML(get_payment_plan_import_type.type_description)#</cfoutput></span>
					</div>
				</cf_box_elements>
				<cf_box_footer>
					<cf_workcube_buttons add_function='kontrol()'>
					<input type="hidden" value="" id="record_emp" name="record_emp">
					<input type="hidden" value="" id="update_emp" name="update_emp">
				</cf_box_footer>
			</cfif>
		</cfform>
	</cf_box>
</div>
<script type="text/javascript">

function kontrol()
{
	<cfif isdefined("attributes.import_type_id") and len(attributes.import_type_id)>
		if(document.add_plan_import.import_name.value=="")
		{
			alert("<cf_get_lang dictionary_id='54327.Tanım Girmelisiniz'>!");
			return false;
		}
		<cfif len(get_payment_plan_import_type.IS_PAYMENT_DATE) and get_payment_plan_import_type.IS_PAYMENT_DATE>
		if(document.add_plan_import.payment_date.value=="")
		{
			alert("<cf_get_lang dictionary_id='41107.Tahakkuk Tarihini Giriniz'>!");
			return false;
		}
		</cfif>
		<cfif get_payment_plan_import_type.import_type eq 1>
		if(document.add_plan_import.uploaded_file.value=="")
		{
			alert("<cf_get_lang dictionary_id='36935.Dosya Seçmelisiniz'>!");
			return false;
		}
		</cfif>
		<cfif get_payment_plan_import_type.import_type eq 2>
		if(document.add_plan_import.finish_date.value=="" || document.add_plan_import.start_date.value=="")
		{
			alert("<cf_get_lang dictionary_id='36830.Başlangıç ve Bitiş Tarihlerini Giriniz'>!");
			return false;
		}
		</cfif>
		<cfif len(get_payment_plan_import_type.is_row_description) and get_payment_plan_import_type.is_row_description>
		if(document.add_plan_import.row_description.value=="" || document.add_plan_import.row_description.value=="")
		{
			alert("<cf_get_lang dictionary_id='41106.Satırlara Eklenecek Açıklama Alanını Giriniz'>!");
			return false;
		}
		</cfif>
	<cfelse>
		return false;
	</cfif>
	return true;
}
function refrehPage(){
	a = document.add_plan_import.import_type_id.selectedIndex;
	window.location.href='<cfoutput>#request.self#?fuseaction=sales.list_subscription_payment_plan_import&event=add&import_type_id=</cfoutput>'+document.add_plan_import.import_type_id[a].value;
	return false;
}
</script>
