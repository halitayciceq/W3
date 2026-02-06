<!--- 
Pronete özel yapılmış bir sayfadır..
Sistem ürün planındaki belli toplamlara göre istenilen koşullarda ödeme planı satırları oluşturulur(ve gene pronetin kendi ürün vs id leri ile..)
Aysenur20070918
 --->
<cfquery name="GET_PAYMETHOD" datasource="#dsn#">
	SELECT PAYMETHOD,PAYMETHOD_ID FROM SETUP_PAYMETHOD WHERE PAYMETHOD_ID IN (1,10,11) ORDER BY PAYMETHOD
</cfquery>
<cfquery name="GET_CARD_PAYMETHOD" datasource="#dsn3#">
	SELECT CARD_NO,PAYMENT_TYPE_ID FROM CREDITCARD_PAYMENT_TYPE WHERE PAYMENT_TYPE_ID IN (3,25) ORDER BY CARD_NO
</cfquery>
<cfquery name="GET_SUBS_INFO" datasource="#dsn3#">
	SELECT AMOUNT FROM SUBSCRIPTION_PAYMENT_PLAN_ROW WHERE SUBSCRIPTION_ID = #attributes.subscription_id# AND PRODUCT_ID IN (787,914) AND STOCK_ID IN (787,914)
</cfquery>
<cfquery name="GET_MONEY_INFO" datasource="#dsn2#">
	SELECT MONEY FROM SETUP_MONEY ORDER BY MONEY_ID
</cfquery>
<cfquery name="GET_CAMPAIGN" datasource="#dsn3#">
	SELECT C.CAMP_ID,C.CAMP_HEAD FROM CAMPAIGN_RELATION CR,CAMPAIGNS C WHERE C.CAMP_ID = CR.CAMP_ID AND CR.SUBSCRIPTION_ID = #attributes.subscription_id#
</cfquery>
<cf_popup_box title="#getLang('sales',477)#">
	<cfform name="open_paym_plan" method="post" action="#request.self#?fuseaction=sales.emptypopup_open_paym_plan">
		<input type="hidden" name="subscription_id" id="subscription_id" value="<cfoutput>#attributes.subscription_id#</cfoutput>">
		<input type="hidden" name="subscription_type" id="subscription_type" value="<cfoutput>#attributes.subscription_type#</cfoutput>">
		<input type="hidden" name="montaj_total" id="montaj_total" value="<cfoutput>#wrk_round(attributes.montaj_total)#</cfoutput>">
		<input type="hidden" name="montaj_total_gross" id="montaj_total_gross" value="<cfoutput>#wrk_round(attributes.montaj_total_gross)#</cfoutput>">
		<input type="hidden" name="ahm_total" id="ahm_total" value="<cfoutput>#wrk_round(attributes.ahm_total)#</cfoutput>">
		<input type="hidden" name="ahm_total_gross" id="ahm_total_gross" value="<cfoutput>#wrk_round(attributes.ahm_total_gross)#</cfoutput>">
		<input type="hidden" name="urun_total" id="urun_total" value="<cfoutput>#wrk_round(attributes.urun_total)#</cfoutput>">
		<input type="hidden" name="urun_total_gross" id="urun_total_gross" value="<cfoutput>#wrk_round(attributes.urun_total_gross)#</cfoutput>">
		<input type="hidden" name="damga_total" id="damga_total" value="<cfoutput>#wrk_round(attributes.damga_total)#</cfoutput>">
		<input type="hidden" name="damga_total_gross" id="damga_total_gross" value="<cfoutput>#wrk_round(attributes.damga_total_gross)#</cfoutput>">
		<input type="hidden" name="kablolama_total" id="kablolama_total" value="<cfoutput>#wrk_round(attributes.kablolama_total)#</cfoutput>">
		<input type="hidden" name="kablolama_total_gross" id="kablolama_total_gross" value="<cfoutput>#wrk_round(attributes.kablolama_total_gross)#</cfoutput>">
		<input type="hidden" name="subs_records" id="subs_records" value="<cfoutput>#GET_SUBS_INFO.recordcount#</cfoutput>">
		<input type="hidden" name="montage_date" id="montage_date" value="<cfoutput>#attributes.montage_date#</cfoutput>">
		<table>
			<tr>
				<td colspan="2">
					<input type="checkbox" name="is_camp_rules" id="is_camp_rules" value="1" onclick="show_camp();">
					Kampanya Operasyon Kuralları Çalışsın
				</td>
			</tr>
			<tr id="camp_info" style="display:none;">
				<td><cf_get_lang_main no='34.Kampanya'></td>
				<td>
					<select name="camp_id" id="camp_id" style="width:140px;" onchange="change_rules();">
						<option value="">Seçiniz</option>
						<cfoutput query="get_campaign">
							<option value="#camp_id#">#camp_head#</option>
						</cfoutput>
					</select>
				</td>
			</tr>
			<tr>
				<td><cf_get_lang no ='570.Periyot Başlangıç'></td>
				<td>
					<cfsavecontent variable="alert"><cf_get_lang no ='571.Periyot Tarihi Girmelisiniz '></cfsavecontent>
					<cfif isDefined("attributes.montage_date") and len(attributes.montage_date)>
						<cfset m_date_info = attributes.montage_date>
					<cfelse>
						<cfset m_date_info = "01/#dateformat(date_add('m',1,now()),'mm/yyyy')#">
					</cfif>
					<cfinput type="text" name="start_date" value="#m_date_info#" required="yes" message="#alert#"style="width:120px;" validate="#validate_style#">
					<cf_wrk_date_image date_field="start_date">
				</td>
			</tr>
			<tr>
				<td><cf_get_lang no ='572.Periyot'></td>
				<td>
					<select name="period" id="period" style="width:140px;">
						<option value="120"><cf_get_lang_main no='1520.Aylık'></option>
						<option value="40">3 <cf_get_lang_main no='1520.Aylık'></option>
						<option value="10"><cf_get_lang_main no='1603.Yıllık'></option>
					</select>
				</td>
			</tr>
			<tr>
				<td><cf_get_lang_main no ='77.Para Birimi'></td>
				<td>
					<select name="money_type" id="money_type" style="width:140px;">
						<cfoutput query="GET_MONEY_INFO">
							<option value="#MONEY#" <cfif MONEY eq session.ep.money2>selected</cfif>>#MONEY#</option>
						</cfoutput>
					</select>
				</td>
			</tr>
			<tr>
				<td><cf_get_lang_main no='1104.Ödeme Yöntemi'></td>
				<td>
					<select name="pay_method" id="pay_method" style="width:140px;">
						<cfoutput query="GET_PAYMETHOD">
							<option value="1;#PAYMETHOD_ID#">#PAYMETHOD#</option>
						</cfoutput>
						<cfoutput query="GET_CARD_PAYMETHOD">
							<option value="2;#PAYMENT_TYPE_ID#">#CARD_NO#</option>
						</cfoutput>
					</select>
				</td>
			</tr>
			<tr>
				<td><cf_get_lang no ='573.Fatura Şekli'></td>
				<td>
					<select name="bill_type" id="bill_type" style="width:140px;">
						<option value="1"><cf_get_lang no ='574.Toplu Faturalama'></option>
						<option value="2"><cf_get_lang no ='575.Grup Faturalama'></option>
						<option value="3"><cf_get_lang no ='576.Manuel Fatura'></option>
					</select>
				</td>
			</tr>
		</table>
		<cf_popup_box_footer><cf_workcube_buttons is_upd='0' add_function='kontrol()'></cf_popup_box_footer>
	</cfform>
</cf_popup_box>
<script type="text/javascript">
	function show_camp()
	{
		if(document.all.is_camp_rules.checked == false)
			camp_info.style.display = 'none';
		else
			camp_info.style.display = '';
	}
	function change_rules()
	{
		if(document.all.camp_id.value != '')
		{
			get_camp_info=wrk_safe_query("get_campaign_operation",'dsn3',0,document.all.camp_id.value);
			if(get_camp_info.PAYMETHOD_ID != '')
			{
				paymethod_info = 1+';'+get_camp_info.PAYMETHOD_ID;
				document.all.pay_method.value = paymethod_info;
			}
			else if(get_camp_info.CARDPAYMETHOD_ID != '')
			{
				paymethod_info = 2+';'+get_camp_info.CARD_PAYMETHOD_ID;
				document.all.pay_method.value = paymethod_info;
			}
		}
	}
	function kontrol()
	{
		if(document.open_paym_plan.is_camp_rules.checked == true)
		{
			if(document.open_paym_plan.camp_id.value == '')
			{
				alert("Kampanya Seçiniz!");
				return false;
			}
		}		
		if(document.open_paym_plan.pay_method.value == '')
		{
			alert("Lütfen Ödeme Yöntemi Seçiniz !");
			return false;
		}
		<cfif isDefined("attributes.montage_date") and len(attributes.montage_date)>
			if (!date_check_hiddens(document.all.montage_date, document.all.start_date , "Başlangıç Tarihini Kontrol Ediniz !"))
				return false;
		</cfif>
		if (document.open_paym_plan.subs_records.value != 0)
		{
			if (!confirm("<cf_get_lang no ='577.Abonelik Bedelleri Silinsin Mi'>?"))
			return false;
		}
		return true;
	}
</script>
