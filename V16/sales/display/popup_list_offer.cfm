<cf_xml_page_edit fuseact="sales.popup_list_offer">
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.filter_cat" default="">
<cfparam name="attributes.offer_status_cat_id" default="">
<script type="text/javascript">
function gonder(offer_id,offer_head,member_id,member_type,member_name,member_company,offer_number,member_company_id)
{
	<cfif isdefined("field_offer_id")>
		<cfif isdefined("attributes.draggable")>document<cfelse>window.opener</cfif>.<cfoutput>#field_offer_id#</cfoutput>.value = offer_id;
	</cfif>
	<cfif isdefined("field_offer_head")>
		<cfif isdefined("attributes.draggable")>document<cfelse>window.opener</cfif>.<cfoutput>#field_offer_head#</cfoutput>.value = offer_head;
	</cfif>
	<cfif isdefined("field_offer_number")>
		<cfif isdefined("attributes.draggable")>document<cfelse>window.opener</cfif>.<cfoutput>#field_offer_number#</cfoutput>.value = offer_number;
	</cfif>
	<cfif isdefined("field_member_id")>
		<cfif isdefined("attributes.draggable")>document<cfelse>window.opener</cfif>.<cfoutput>#field_member_id#</cfoutput>.value = member_id;
	</cfif>
	<cfif isdefined("field_member_name")>
		<cfif isdefined("attributes.draggable")>document<cfelse>window.opener</cfif>.<cfoutput>#field_member_name#</cfoutput>.value = member_name;
	</cfif>
	<cfif isdefined("field_member_type")>
		<cfif isdefined("attributes.draggable")>document<cfelse>window.opener</cfif>.<cfoutput>#field_member_type#</cfoutput>.value = member_type;
	</cfif>
	<cfif isdefined("field_member_company")>
		<cfif isdefined("attributes.draggable")>document<cfelse>window.opener</cfif>.<cfoutput>#field_member_company#</cfoutput>.value = member_company;
	</cfif>
	<cfif isdefined("field_member_company_id")>
		<cfif isdefined("attributes.draggable")>document<cfelse>window.opener</cfif>.<cfoutput>#field_member_company_id#</cfoutput>.value = member_company_id;
	</cfif>
	<cfif isdefined("field_member_consumer_id")>
		<cfif isdefined("attributes.draggable")>document<cfelse>window.opener</cfif>.<cfoutput>#field_member_consumer_id#</cfoutput>.value = member_id;
	</cfif>
	<cfif not isdefined("attributes.draggable")>window.close();<cfelse>closeBoxDraggable( '<cfoutput>#attributes.modal_id#</cfoutput>' );</cfif>
}
</script>
<cfinclude template="../query/get_offer_list.cfm">
<cfinclude template="../query/get_commethod.cfm">
<cfinclude template="../query/get_offer_currencies.cfm">
<cfparam name="attributes.page" default=1>
<cfparam name="attributes.modal_id" default="">
<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>
<cfparam name="attributes.totalrecords" default="#get_offer_list.recordcount#">
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
<cfset url_string = "">
<cfif isdefined("attributes.field_offer_id")>
	<cfset url_string = "#url_string#&field_offer_id=#attributes.field_offer_id#">
</cfif>
<cfif isdefined("attributes.field_offer_number")>
	<cfset url_string = "#url_string#&field_offer_number=#attributes.field_offer_number#">
</cfif>
<cfif isdefined("attributes.field_offer_head")>
	<cfset url_string = "#url_string#&field_offer_head=#attributes.field_offer_head#">
</cfif>
<cfif isdefined("attributes.field_member_id")>
	<cfset url_string = "#url_string#&field_member_id=#attributes.field_member_id#">
</cfif>
<cfif isdefined("attributes.field_member_type")>
	<cfset url_string = "#url_string#&field_member_type=#attributes.field_member_type#">
</cfif>
<cfif isdefined("attributes.field_member_name")>
	<cfset url_string = "#url_string#&field_member_name=#attributes.field_member_name#">
</cfif>
<cfif isdefined("attributes.field_member_company")>
	<cfset url_string = "#url_string#&field_member_company=#attributes.field_member_company#">
</cfif>
<cfif isdefined("attributes.field_member_consumer_id")>
	<cfset url_string = "#url_string#&field_member_consumer_id=#attributes.field_member_consumer_id#">
</cfif>
	<cf_box title="#getLang('','Teklifler',40806)#" scroll="1" collapsable="1" resize="1" popup_box="#iif(isdefined("attributes.draggable"),1,0)#">
		<cfform name="form_list_offer" action="#request.self#?fuseaction=sales.popup_list_offers#url_string#" method="post">
			<cf_box_search more="0">
				<div class="form-group" id="item-keyword">
					<cfinput type="text" name="keyword" id="keyword" placeholder="#getLang('main','Filtre',57460)#" value="#attributes.keyword#" maxlength="255">
				</div>
				<div class="form-group" id="filter_cat">
					<select name="filter_cat" id="filter_cat">
						<option value=""><cf_get_lang dictionary_id='57486.Kategori'></option>
						<option value="1" <cfif attributes.filter_cat eq 1>selected</cfif>><cf_get_lang dictionary_id='29406.Bireysel Üyeler'></option>
						<option value="2" <cfif attributes.filter_cat eq 2>selected</cfif>><cf_get_lang dictionary_id='29408.Kurumsal Üyeler'></option>
						<option value="3" <cfif attributes.filter_cat eq 3>selected</cfif>><cf_get_lang dictionary_id='40899.Potansiyel Bireysel Üyeler'></option>
						<option value="4" <cfif attributes.filter_cat eq 4>selected</cfif>><cf_get_lang dictionary_id='30417.pot kurumsal'></option>
					</select>
				</div>
				<div class="form-group" id="offer_status_cat_id">
					<select name="offer_status_cat_id" id="offer_status_cat_id">
						<option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
						<cfoutput query="get_offer_currencies">
						<option value="#offer_currency_id#" <cfif attributes.offer_status_cat_id eq get_offer_currencies.offer_currency_id>selected</cfif>>#OFFER_CURRENCY#</option>
						</cfoutput>
					</select>	
				</div>
				<div class="form-group small">
					<cfinput type="text" name="maxrows" value="#attributes.maxrows#" required="yes" validate="integer" range="1,999" message="#getLang('','Kayıt Sayısı Hatalı',57537)#" maxlength="3">
				</div>
				<div class="form-group">
					<cf_wrk_search_button button_type="4" search_function="#iif(isdefined("attributes.draggable"),DE("loadPopupBox('form_list_offer' , #attributes.modal_id#)"),DE(""))#">
				</div>
			</cf_box_search>
		</cfform>

		<cf_grid_list>
			<thead>
				<tr>
					<th><cf_get_lang dictionary_id='57487.No'></th>
					<cfif xml_dsp_offer_revision eq 1>
						<th class="form-title" width="100"><cf_get_lang dictionary_id='40935.Revize'> <cf_get_lang dictionary_id='57487.No'></th>
					</cfif>
					<th><cf_get_lang dictionary_id='57742.Tarih'></th>
					<th><cf_get_lang dictionary_id='57480.Başlık'></th>
					<th><cf_get_lang dictionary_id='57574.şirket'> - <cf_get_lang dictionary_id='57578.yetkili'></th>
					<th><cf_get_lang dictionary_id='57673.tutar'></th>
					<th><cf_get_lang dictionary_id='57482.Aşama'></th>
					<th><cf_get_lang dictionary_id='40842.satis ekibi'></th>	
				</tr>
			</thead>
			<tbody>
					<cfif get_offer_list.recordcount>
					<cfoutput query="get_offer_list" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
						<cfif len(consumer_id)>
							<cfset attributes.consumer_id = consumer_id>
							<cfinclude template="../query/get_consumer_name.cfm">
							<cfset member_id = consumer_id>
							<cfset member_type = "CONSUMER">
							<cfset member_name = "#get_consumer_name.consumer_NAME# #get_consumer_name.consumer_SURNAME#">
							<cfset member_company = get_consumer_name.COMPANY>
							<cfset member_company_id = "">
							<cfset member_extra = " - (#getLang('','Bireysel Üye',57586)#)">
						<cfelseif listlen(partner_id)>
							<cfset attributes.partner_id = listsort(partner_id,'Numeric')>
							<cfinclude template="../query/get_partner_name.cfm">
							<cfset member_id = get_partner_name.partner_id>
							<cfset member_type = "PARTNER">
							<cfset member_name = "#get_partner_name.COMPANY_PARTNER_NAME# #get_partner_name.COMPANY_PARTNER_SURNAME#">
							<cfset member_company = get_partner_name.nickname>
							<cfset member_company_id = get_partner_name.company_id>
							<cfset member_extra = "">
						<cfelse>
							<cfset member_id = "">
							<cfset member_type = "">
							<cfset member_name = "">
							<cfset member_company = "">
							<cfset member_company_id = "">
							<cfset member_extra = "">
						</cfif>
						<tr onclick="gonder('#offer_id#','#offer_head#','#member_id#','#member_type#','#member_name#','#member_company#','#OFFER_NUMBER#', '#member_company_id#');" style="cursor:pointer;">
							<td>#offer_number#</td>
							<cfif xml_dsp_offer_revision eq 1>
								<td>#offer_revize_no#</td>
							</cfif>
							<td>#dateformat(date_add('h',session.ep.time_zone,record_date),dateformat_style)#</td>
							<td>#offer_head#</td>
							<td>#member_company# - #MEMBER_NAME# #member_extra#</td>
							<td class="text-right">#TLFormat(price)#</td>
							<td><cfif offer_status is 1><cf_get_lang dictionary_id='57493.aktif'><cfelse><cf_get_lang dictionary_id='57494.pasif'></cfif></td>
							<td><cfif offer_zone eq 0>#get_emp_info(record_member,0,0)#<cfelseif offer_zone eq 1>#get_par_info(record_member,0,-1,0)#</cfif></td>
						</tr>
					</cfoutput>
					<cfelse>
						<tr>
							<td colspan="8"><cf_get_lang dictionary_id='57484.Kayıt Yok'>!</td>
						</tr>
					</cfif>
			</tbody>
		</cf_grid_list>

		<cfif get_offer_list.recordcount and (attributes.totalrecords gte attributes.maxrows)>
			<cfif Len(attributes.keyword)>
				<cfset url_string = "#url_string#&keyword=#attributes.keyword#">
			</cfif>
			<cfif Len(attributes.filter_cat)>
				<cfset url_string = "#url_string#&filter_cat=#attributes.filter_cat#">
			</cfif>
			<cfif Len(attributes.offer_status_cat_id)>
				<cfset url_string = "#url_string#&offer_status_cat_id=#attributes.offer_status_cat_id#">
			</cfif>
			<cf_paging 
				page="#attributes.page#"
				maxrows="#attributes.maxrows#"
				totalrecords="#attributes.totalrecords#"
				startrow="#attributes.startrow#"
				adres="sales.popup_list_offers#url_string#"
				isAjax="#iif(isdefined("attributes.draggable"),1,0)#">
		</cfif>
	</cf_box>
<script type="text/javascript">
	$(document).ready(() => {
		$("form[name=form_list_offer] #keyword").focus();
	});
</script>
