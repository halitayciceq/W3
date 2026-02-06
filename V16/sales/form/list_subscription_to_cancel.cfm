<cfinclude template="../query/get_subscription_cancel_type.cfm">
<cfquery name="GET_SUBSCRIPTION_CANCEL" datasource="#DSN3#">
	SELECT
		SUBSCRIPTION_ID,
		CANCEL_TYPE_ID,
		CANCEL_DATE,
		CANCEL_DETAIL,
		CANCEL_UPDATE_DATE,
		CANCEL_UPDATE_IP,
		CANCEL_UPDATE_EMP,		
		CANCEL_RECORD_DATE,
		CANCEL_RECORD_IP,
		CANCEL_RECORD_EMP		
	FROM
		SUBSCRIPTION_CONTRACT
	WHERE
		SUBSCRIPTION_ID = #url.subscription_id#
</cfquery>
<cf_xml_page_edit fuseact ="sales.popup_subscription_to_cancel">
<cf_box title="#getLang('','Sistem İptal',41137)#" scroll="1" collapsable="1" resize="1" popup_box="#iif(isdefined("attributes.draggable"),1,0)#">
	<cfform name="list_cancel" method="post" action="#request.self#?fuseaction=sales.emptypopup_upd_subscription_to_cancel">
		<input type="hidden" name="subscription_id" id="subscription_id" value="<cfoutput>#url.subscription_id#</cfoutput>">
		<cf_box_elements>
			<div class="col col-12 col-md-12 col-sm-12 col-xs-12" type="column" index="1" sort="true">
				<div class="form-group" id="item-cancel_type">
					<label class="col col-4 col-md-4 col-xs-12"><cf_get_lang dictionary_id='58825.İptal Nedeni'> *</label>
					<div class="col col-8 col-md-8 col-sm-8 col-xs-12">
						<select name="cancel_type" id="cancel_type">
							<option selected value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
							<cfoutput query="get_subscription_cancel_type">
								<option value="#subscription_cancel_type_id#" <cfif get_subscription_cancel.cancel_type_id eq subscription_cancel_type_id>selected</cfif>>#subscription_cancel_type#</option>
							</cfoutput>
						</select>
					</div>
				</div>
				<div class="form-group" id="item-cancel_date">
					<label class="col col-4 col-md-4 col-xs-12"><cf_get_lang dictionary_id='57748.İptal Tarihi'> *</label>
					<div class="col col-8 col-md-8 col-sm-8 col-xs-12">
						<div class="input-group">
							<cfsavecontent variable="message"><cf_get_lang dictionary_id='41139.İptal Tarihini Kontrol Ediniz'> !</cfsavecontent>
							<cfif len(get_subscription_cancel.cancel_date)>
								<cfinput type="text" name="cancel_date" value="#dateformat(get_subscription_cancel.cancel_date,dateformat_style)#" required="yes" validate="#validate_style#" message="#message#" maxlength="10">
							<cfelse>
								<cfinput type="text" name="cancel_date" value="#dateformat(now(),dateformat_style)#" required="yes" validate="#validate_style#" message="#message#" maxlength="10">
							</cfif>
							<span class="input-group-addon"><cf_wrk_date_image date_field="cancel_date"></span>	
						</div>
					</div>
				</div>	
				<div class="form-group" id="item-cancel_detail">
					<label class="col col-4 col-md-4 col-xs-12"><cf_get_lang dictionary_id='57629.Açıklama'></label>
					<div class="col col-8 col-md-8 col-sm-8 col-xs-12">
						<textarea name="cancel_detail" id="cancel_detail" style="width:140px;height:65px;"><cfoutput>#get_subscription_cancel.cancel_detail#</cfoutput></textarea>
					</div>
				</div>
			</div>
		</cf_box_elements>
		<cf_box_footer>
			<cf_record_info query_name="get_subscription_cancel" record_emp="CANCEL_RECORD_EMP" record_date="CANCEL_RECORD_DATE" update_emp="CANCEL_UPDATE_EMP" update_date="CANCEL_UPDATE_DATE">

			<cfif len(get_subscription_cancel.cancel_type_id)>
				<cf_workcube_buttons is_upd='1' del_function="#isDefined('attributes.draggable') ? 'deleteFunc()' : ''#" add_function='kontrol()'>
			<cfelse>
				<cf_workcube_buttons is_upd='0' add_function='kontrol()' insert_alert='#getLang('','Sisteminiz İptal Edilecektir ve İşlem Görmemiş Ödeme Planı Satırları Silinecektir',41406)#!'>
			</cfif>
	</cf_box_footer>
	</cfform>
</cf_box>
<script type="text/javascript">
function kontrol()
{
	x = document.list_cancel.cancel_type.selectedIndex;
	if (document.list_cancel.cancel_type[x].value == "")
	{ 
		alert ("<cf_get_lang dictionary_id='41140.İptal Nedeni Seçmediniz'> ! ");
		return false;
	}
	
	y = (100 - document.list_cancel.cancel_detail.value.length);
	if ( y < 0)
	{ 
		alert ("<cf_get_lang dictionary_id='57629.Aciklama'><cf_get_lang dictionary_id='41141.Alanina 100 Karakterden Fazla Girmeyiniz Fazla Krakter Sayisi'>"+ ((-1) * y));
		return false;
	}
	<cfif xml_control_camp eq 1>
		var paper_date_ = js_date( eval('list_cancel.cancel_date.value').toString() );
		var listParam = paper_date_ + "*" + document.all.subscription_id.value;
		get_camp_info=wrk_safe_query("get_subscription_campaigns_2",'dsn3',0,listParam);
		if(get_camp_info.recordcount > 0)
		{
			if(!confirm("<cf_get_lang dictionary_id='62930.Ödeme Planı Satırlarında Kampanya İle İlişkili Faturalanmamış Satırlar Mevcut.'>. <cf_get_lang dictionary_id='62931.Sistemi İptal Etmek İstediğinize Emin misiniz?'> \n\ <cf_get_lang dictionary_id='41427.İlişkili Kampanyalar'> : "+get_camp_info.CAMP_HEAD))
			return false;
		}
	</cfif>
	<cfif isdefined("attributes.draggable")> 
		loadPopupBox('list_cancel' , <cfoutput>#attributes.modal_id#</cfoutput>)
	</cfif>
	return true;
}
<cfif isDefined('attributes.draggable')>
	function deleteFunc() {
		openBoxDraggable('<cfoutput>#request.self#?fuseaction=sales.emptypopup_del_subscription_to_cancel&subscription_id=#attributes.subscription_id#</cfoutput>',<cfoutput>#attributes.modal_id#</cfoutput>);
	}
</cfif>
</script>
