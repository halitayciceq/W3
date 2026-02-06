<cf_box title="#getLang('','Üye Bilgileri',57575)#">
	<cfinclude template="../../objects/display/contact_simple.cfm">
</cf_box>
<cfif xml_iam eq 1>
	<cf_box title="#getLang('','IAM USER',63651)#" id="user_iam_" closable="0" add_href="javascript:addiam()">
		<cf_box_elements>
			<div class="col col-12 col-xs-12">
				<div class="form-group">
					<label class="col col-6 col-xs-12 bold"><cf_get_lang dictionary_id='59913.Kullanıcı Sayısı'>:</label>
					<div class="col col-6 col-xs-12">
						<a href="<cfoutput>#request.self#?fuseaction=plevne.iam&subs_no=#get_subscription.subscription_no#&is_form_submitted=1</cfoutput>" target="_blank"><cfoutput>#GET_COUNT_IAMUSER.recordcount#</cfoutput></a>
					</div>
				</div>
			</div>
		</cf_box_elements>
	</cf_box>
</cfif>
<!--- Sayaçlar --->
<cfif xml_show_counter>
    <cf_box 
        add_href="openBoxDraggable('#request.self#?fuseaction=sales.counter&event=add&subscription_id=#attributes.subscription_id#&subscription_no=#get_subscription.subscription_no#&company_id=#get_subscription.company_id#&partner_id=#get_subscription.partner_id#&member_type=partner','','ui-draggable-box-large')" 
        add_href_size="medium"
        id="get_counter" 
        closable="0"
        collapsed="1"
        box_page="#request.self#?fuseaction=sales.emptypopup_list_subscription_counter&subscription_id=#attributes.subscription_id#"
        info_href="javascript:openBoxDraggable('#request.self#?fuseaction=sales.popup_list_subscription_counter_invoice&subscription_id=#attributes.subscription_id#');"
        title="#getLang('','Sayaçlar',41064)#"> 
    </cf_box>
</cfif>
<!--- Notlar --->
<cf_get_workcube_note action_section='SUBSCRIPTION_ID' module_id='11' action_id='#url.subscription_id#' company_id='#session.ep.company_id#' style='1'>
<!--- Belgeler --->
<cf_get_workcube_asset action_section='SUBSCRIPTION_ID' module_id='11' asset_cat_id="-19" action_id='#url.subscription_id#' company_id='#session.ep.company_id#'>
<!--- Ilıskili Olaylar --->
<cfif xml_show_related_events>
	<cf_get_related_events action_section='SUBSCRIPTION_ID' action_id='#url.subscription_id#' company_id='#session.ep.company_id#'>
</cfif>
<cfif isDefined("http") and ListContains(http.host,"pronet",".")><!--- add_options include function ı yapılana kadar geçici pronete belirli ürünlerle ilgili toplamlar gelsin diye yapıldı..Aysenur20070719 --->
	<cfquery name="GET_SUBSCRIPTION_ROW2" datasource="#DSN3#">
		SELECT
			SCR.NETTOTAL,
			SCR.NETTOTAL+SCR.DISCOUNTTOTAL GROSSTOTAL,
			0 NETTOTAL_IADE,
			0 GROSSTOTAL_IADE,
			(S.RATE1/S.RATE2) RATE,
			PRODUCT_ID,
			STOCK_ID
		FROM 
			SUBSCRIPTION_CONTRACT_ROW SCR,
			SUBSCRIPTION_CONTRACT_MONEY S
		WHERE 
			SCR.SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.subscription_id#"> AND
			SCR.OTHER_MONEY = S.MONEY_TYPE AND
			SCR.SUBSCRIPTION_ID = S.ACTION_ID AND
			SCR.BASKET_EXTRA_INFO_ID <> 3
	UNION ALL
		SELECT
			0 NETTOTAL,
			0 GROSSTOTAL,
			SCR.NETTOTAL NETTOTAL_IADE,
			SCR.NETTOTAL+SCR.DISCOUNTTOTAL GROSSTOTAL_IADE,
			(S.RATE1/S.RATE2) RATE,
			PRODUCT_ID,
			STOCK_ID
		FROM 
			SUBSCRIPTION_CONTRACT_ROW SCR,
			SUBSCRIPTION_CONTRACT_MONEY S
		WHERE 
			SCR.SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.subscription_id#"> AND
			SCR.OTHER_MONEY = S.MONEY_TYPE AND
			SCR.SUBSCRIPTION_ID = S.ACTION_ID AND
			SCR.BASKET_EXTRA_INFO_ID = 3
	</cfquery>
	<cfquery name="GET_SA_DISCOUNT" datasource="#dsn3#">
		SELECT ISNULL(SA_DISCOUNT,0) SA_DISCOUNT FROM SUBSCRIPTION_CONTRACT WHERE SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.subscription_id#">
	</cfquery>
	<cfquery name="GET_MONTAJ" dbtype="query">
		SELECT SUM((NETTOTAL-NETTOTAL_IADE)*RATE) NET_TOTAL,SUM((GROSSTOTAL-GROSSTOTAL_IADE)*RATE) GROSS_TOTAL FROM GET_SUBSCRIPTION_ROW2 WHERE PRODUCT_ID IN(264,855) AND STOCK_ID IN (264,855)
	</cfquery>
	<cfquery name="GET_AHM" dbtype="query">
		SELECT SUM((NETTOTAL-NETTOTAL_IADE)*RATE) NET_TOTAL,SUM((GROSSTOTAL-GROSSTOTAL_IADE)*RATE) GROSS_TOTAL FROM GET_SUBSCRIPTION_ROW2 WHERE PRODUCT_ID IN (914,820,27,847) AND STOCK_ID IN (914,820,27,847)
	</cfquery>
	<cfquery name="GET_OTHER_PRODUCTS" dbtype="query">
		SELECT SUM((NETTOTAL-NETTOTAL_IADE)*RATE) NET_TOTAL,SUM((GROSSTOTAL-GROSSTOTAL_IADE)*RATE) GROSS_TOTAL FROM GET_SUBSCRIPTION_ROW2 WHERE PRODUCT_ID NOT IN (264,855,914,820,27,847,2739,819,2855,2868) AND STOCK_ID NOT IN (264,855,914,820,27,847,2704,819,2820,2833)
	</cfquery>
	<cfquery name="GET_AHM_YEAR" dbtype="query">
		SELECT SUM((NETTOTAL-NETTOTAL_IADE)*RATE) NET_TOTAL,SUM((GROSSTOTAL-GROSSTOTAL_IADE)*RATE) GROSS_TOTAL FROM GET_SUBSCRIPTION_ROW2 WHERE PRODUCT_ID IN (847) AND STOCK_ID IN (847)
	</cfquery>
	<cfquery name="GET_DAMGA" dbtype="query">
		SELECT SUM((NETTOTAL)*RATE) NET_TOTAL,SUM((GROSSTOTAL)*RATE) GROSS_TOTAL FROM GET_SUBSCRIPTION_ROW2 WHERE PRODUCT_ID IN (2739) AND STOCK_ID IN (2704)
	</cfquery>
	<cfquery name="GET_KABLOLAMA" dbtype="query">
		SELECT SUM((NETTOTAL)*RATE) NET_TOTAL,SUM((GROSSTOTAL)*RATE) GROSS_TOTAL FROM GET_SUBSCRIPTION_ROW2 WHERE PRODUCT_ID IN (819,2855,2868) AND STOCK_ID IN (819,2820,2833)
	</cfquery>
	<!---şimdilik kapatıldı
	<cfquery name="GET_TAKIP" dbtype="query">
		SELECT SUM((NETTOTAL)*RATE) NET_TOTAL FROM GET_SUBSCRIPTION_ROW2 WHERE PRODUCT_ID IN (2526) AND STOCK_ID IN (2492)
	</cfquery> --->
	<cf_box id="paying_plan" title="#getLang('','Ödeme Planı Özeti',41280)#" closable="0">
	<cfoutput>
	<cf_ajax_list>
    <thead>
		<tr>
			<th><cf_get_lang dictionary_id ='57657.Ürün'></th>
			<th><cf_get_lang dictionary_id='41440.Brüt'></th>
			<th><cf_get_lang dictionary_id='58083.Net'></th>
		</tr>
    </thead>
    <tbody>
		<tr>
			<td width="140"><cf_get_lang dictionary_id ='57657.Ürün'>:</td>
			<td class="text-right">
				<cfif len(GET_OTHER_PRODUCTS.GROSS_TOTAL)>
					#TLFormat(GET_OTHER_PRODUCTS.GROSS_TOTAL-GET_SA_DISCOUNT.SA_DISCOUNT)#<!--- satır altı indirim döviz türü bakılmadan pronetin istedigi gibi yapılmıştır,düşünmeyiniz --->
					<input type="hidden" name="urun_total_gross" id="urun_total_gross" value="#GET_OTHER_PRODUCTS.GROSS_TOTAL-GET_SA_DISCOUNT.SA_DISCOUNT#">
				<cfelse>
					#TLFormat(0)#
					<input type="hidden" name="urun_total_gross" id="urun_total_gross" value="0">
				</cfif>
			</td>
			<td class="text-right">
				<cfif len(GET_OTHER_PRODUCTS.NET_TOTAL)>
					#TLFormat(GET_OTHER_PRODUCTS.NET_TOTAL-GET_SA_DISCOUNT.SA_DISCOUNT)#<!--- satır altı indirim döviz türü bakılmadan pronetin istedigi gibi yapılmıştır,düşünmeyiniz --->
					<input type="hidden" name="urun_total" id="urun_total" value="#GET_OTHER_PRODUCTS.NET_TOTAL-GET_SA_DISCOUNT.SA_DISCOUNT#">
				<cfelse>
					#TLFormat(0)#
					<input type="hidden" name="urun_total" id="urun_total" value="0">
				</cfif>
			</td>
		</tr>
		<tr>
			<td width="140"><cfif GET_AHM_YEAR.NET_TOTAL gt 0><cf_get_lang dictionary_id='29400.Yıllık'> </cfif>AHM:</td>
			<td class="text-right">
				<cfif len(GET_AHM.GROSS_TOTAL)>
					#TLFormat(GET_AHM.GROSS_TOTAL)#
					<input type="hidden" name="ahm_total_gross" id="ahm_total_gross" value="#GET_AHM.GROSS_TOTAL#">
				<cfelse>
					#TLFormat(0)#
					<input type="hidden" name="ahm_total_gross" id="ahm_total_gross" value="0">
				</cfif>
			</td>
			<td class="text-right">
				<cfif len(GET_AHM.NET_TOTAL)>
					#TLFormat(GET_AHM.NET_TOTAL)#
					<input type="hidden" name="ahm_total" id="ahm_total" value="#GET_AHM.NET_TOTAL#">
				<cfelse>
					#TLFormat(0)#
					<input type="hidden" name="ahm_total" id="ahm_total" value="0">
				</cfif>
			</td>
		</tr>
		<tr>
			<td width="140"><cf_get_lang dictionary_id ='33340.Kurulum'>:</td>
			<td class="text-right">
				<cfif len(GET_MONTAJ.GROSS_TOTAL)>
					#TLFormat(GET_MONTAJ.GROSS_TOTAL)#
					<input type="hidden" name="montaj_total_gross" id="montaj_total_gross" value="#GET_MONTAJ.GROSS_TOTAL#">
				<cfelse>
					#TLFormat(0)#
					<input type="hidden" name="montaj_total_gross" id="montaj_total_gross" value="0">
				</cfif>
			</td>
			<td class="text-right">
				<cfif len(GET_MONTAJ.NET_TOTAL)>
					#TLFormat(GET_MONTAJ.NET_TOTAL)#
					<input type="hidden" name="montaj_total" id="montaj_total" value="#GET_MONTAJ.NET_TOTAL#">
				<cfelse>
					#TLFormat(0)#
					<input type="hidden" name="montaj_total" id="montaj_total" value="0">
				</cfif>
			</td>
		</tr>
		<cfif get_subscription.PROJECT_ID is 7480 and GET_SUBSCRIPTION.SUBSCRIPTION_TYPE_ID eq 4><cfset DVORAN = 12><cfelse><cfset DVORAN = 24></cfif>
		<tr>
			<td width="140"><cf_get_lang dictionary_id='41439.Damga Vergisi'>:</td>
			<td class="text-right">
				<!----<cfoutput>DVORAN:#DVORAN#</cfoutput>----->
				<cfif year(get_subscription.start_date) gte 2010><cfset rate_info = "0.00825"><cfelse><cfset rate_info = "0.0075"></cfif>
				<cfif len(GET_DAMGA.GROSS_TOTAL)>
					<cfif len(GET_MONTAJ.GROSS_TOTAL)><cfset montaj_total_gross = GET_MONTAJ.GROSS_TOTAL><cfelse><cfset montaj_total_gross = 0></cfif>
					<cfif len(GET_AHM.GROSS_TOTAL)><cfset ahm_total_gross = GET_AHM.GROSS_TOTAL><cfelse><cfset ahm_total_gross = 0></cfif>
					<cfif GET_SUBSCRIPTION.SUBSCRIPTION_TYPE_ID eq 4><!--- abonelik sözleşmeleri olanlar için --->
						<cfset damga_tutar_info_gross = ((GET_DAMGA.GROSS_TOTAL*DVORAN) + montaj_total_gross) * rate_info>
					<cfelseif not ListFind('4,6,7,8,11,12',GET_SUBSCRIPTION.SUBSCRIPTION_TYPE_ID)>
						<cfif not len(GET_OTHER_PRODUCTS.GROSS_TOTAL)><cfset ahm_total_gross = 0></cfif><!--- ürünler yoksa ahmyi katmıycaz. --->
						<cfset damga_tutar_info_gross = (GET_DAMGA.GROSS_TOTAL + montaj_total_gross + ahm_total_gross) * rate_info>
					<cfelse>
						<cfset damga_tutar_info_gross = 0>
					</cfif>
					#TLFormat(damga_tutar_info_gross)#
					<input type="hidden" name="damga_total_gross" id="damga_total_gross" value="#damga_tutar_info_gross#">
				<cfelse>
					#TLFormat(0)#
					<input type="hidden" name="damga_total_gross" id="damga_total_gross" value="0">
				</cfif>
			</td>
			<td class="text-right">
				<!----<cfoutput>DVORAN:#DVORAN#</cfoutput>----->
				<cfif year(get_subscription.start_date) gte 2010><cfset rate_info = "0.00825"><cfelse><cfset rate_info = "0.0075"></cfif>
				<cfif len(GET_DAMGA.NET_TOTAL)>
					<cfif len(GET_MONTAJ.NET_TOTAL)><cfset montaj_total = GET_MONTAJ.NET_TOTAL><cfelse><cfset montaj_total = 0></cfif>
					<cfif len(GET_AHM.NET_TOTAL)><cfset ahm_total = GET_AHM.NET_TOTAL><cfelse><cfset ahm_total = 0></cfif>
					<cfif GET_SUBSCRIPTION.SUBSCRIPTION_TYPE_ID eq 4><!--- abonelik sözleşmeleri olanlar için --->
						<cfset damga_tutar_info = ((GET_DAMGA.NET_TOTAL*DVORAN) + montaj_total) * rate_info>
					<cfelseif not ListFind('4,6,7,8,11,12',GET_SUBSCRIPTION.SUBSCRIPTION_TYPE_ID)>
						<cfif not len(GET_OTHER_PRODUCTS.NET_TOTAL)><cfset ahm_total = 0></cfif><!--- ürünler yoksa ahmyi katmıycaz. --->
						<cfset damga_tutar_info = (GET_DAMGA.NET_TOTAL + montaj_total + ahm_total) * rate_info>
					<cfelse>
						<cfset damga_tutar_info = 0>
					</cfif>
					#TLFormat(damga_tutar_info)#
					<input type="hidden" name="damga_total" id="damga_total" value="#damga_tutar_info#">
				<cfelse>
					#TLFormat(0)#
					<input type="hidden" name="damga_total" id="damga_total" value="0">
				</cfif>
			</td>
		</tr>
		<tr>
			<td width="140"><cf_get_lang dictionary_id='41442.Kablolama'>:</td>
			<td class="text-right">
				<cfif len(GET_KABLOLAMA.GROSS_TOTAL)>
					#TLFormat(GET_KABLOLAMA.GROSS_TOTAL)#
					<input type="hidden" name="kablolama_total_gross" id="kablolama_total_gross" value="#GET_KABLOLAMA.GROSS_TOTAL#">
				<cfelse>
					#TLFormat(0)#
					<input type="hidden" name="kablolama_total_gross" id="kablolama_total_gross" value="0">
				</cfif>
			</td>
			<td class="text-right">
				<cfif len(GET_KABLOLAMA.NET_TOTAL)>
					#TLFormat(GET_KABLOLAMA.NET_TOTAL)#
					<input type="hidden" name="kablolama_total" id="kablolama_total" value="#GET_KABLOLAMA.NET_TOTAL#">
				<cfelse>
					#TLFormat(0)#
					<input type="hidden" name="kablolama_total" id="kablolama_total" value="0">
				</cfif>
			</td>
		</tr>
		<tr>
        	<td colspan="3" align="right" >
	            <input type="button" name="make_paym_plan" id="make_paym_plan" value="#getLang('','Ödeme Planı Oluştur',41279)#" onclick="open_pay_plan('#attributes.subscription_id#');">
            </td>
        </tr>
    </tbody>
	</cf_ajax_list>
	</cfoutput>
	</cf_box>
	<script type="text/javascript">
	function open_pay_plan(subs_id)
	{
		windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=sales.popup_open_paym_plan&montaj_total_gross='+document.form_basket.montaj_total_gross.value+'&montaj_total='+document.form_basket.montaj_total.value+'&ahm_total_gross='+document.form_basket.ahm_total_gross.value+'&ahm_total='+document.form_basket.ahm_total.value+'&urun_total_gross='+document.form_basket.urun_total_gross.value+'&urun_total='+document.form_basket.urun_total.value+'&damga_total_gross='+document.form_basket.damga_total_gross.value+'&damga_total='+document.form_basket.damga_total.value+'&kablolama_total_gross='+document.form_basket.kablolama_total_gross.value+'&kablolama_total='+document.form_basket.kablolama_total.value+'&montage_date='+document.form_basket.montage_date.value+'&subscription_type='+document.form_basket.subscription_type.value+'&subscription_id='+subs_id,'small'); 
	}
	</script>
</cfif>
<!-- Finansal Özet -->
<cfif get_module_user(16)>
    <cfif isdefined('x_comp_id') and len(x_comp_id)>
        <cfset comp_id =x_comp_id>
    <cfelse>
        <cfset comp_id=session.ep.company_id>
    </cfif>
	<cf_get_workcube_finance_summary action_id="#comp_id#" style="1">
</cfif>
<cfif isdefined("attributes.subscription_id") and len(attributes.subscription_id)>
	<cfset getComponent = createObject('component','V16.project.cfc.get_project_detail')>
	<cfset GET_ACTION_WORKGROUP = getComponent.GET_ACTION_WORKGROUP(action_field : "subscription", action_id : attributes.subscription_id)>
    <div style="display:none;z-index:999;" id="subs_team"></div>
	<cf_box 
		id="workgroup" 
		title="#getLang('campaign',44)#" 
		widget_load="subscriberTeam&action_id=#attributes.subscription_id#&action_field=subscription"  
		lock_href="openBoxDraggable('#request.self#?fuseaction=objects.popup_denied_pages_lock&pages_id=#GET_ACTION_WORKGROUP.WORKGROUP_ID#&act=#attributes.fuseaction#')"
    	lock_href_title="#getLang('','Sayfa Kilidi',58041)#" 
		add_href="javascript:openBoxDraggable('#request.self#?fuseaction=project.popup_add_workgroup&action_id=#attributes.subscription_id#&action_field=subscription')">
	</cf_box>
</cfif>
<cfset x_subs_comp_id="">
<cfif isdefined('x_subs_comp_id') and len(x_subs_comp_id)>
    <cfset x_subs_comp_id =x_subs_comp_id>
</cfif>

<cfif isdefined("attributes.company_id") and len(attributes.company_id)>
    <cf_box
        id="box_systems"
        closable="0"
        box_page="#request.self#?fuseaction=myhome.popupajax_my_company_systems&cpid=#attributes.company_id#&maxrows=#attributes.maxrows#&service_id=#attributes.service_id#&x_subs_comp_id=#x_subs_comp_id#"
        title="#getLang('','Abone',58832)#">
    </cf_box>
</cfif>
