
<cfquery name="GET_DISCOUNT_COUPON" datasource="#DSN3#">
	SELECT
   		CONSUMER_ID,
        COMPANY_ID,
        TARGET_MARKET_ID,
        MONEY_CREDIT,
        MIN_ORDER_TOTAL,
        COUPON_COUNT,
        IS_SPECIAL,
        VALID_DATE
    FROM
    	ORDER_MONEY_CREDITS
    WHERE
    	ORDER_CREDIT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.order_credit_id#">
</cfquery>
<cfquery name="GET_IS_USED" datasource="#DSN3#">
	SELECT ORDER_ID FROM ORDER_MONEY_CREDIT_USED WHERE ORDER_CREDIT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.order_credit_id#">
</cfquery>
<cfsavecontent variable="title_">
	İndirim Kuponu Güncelle
</cfsavecontent>
<cfsavecontent variable="img"><a href="<cfoutput>#request.self#</cfoutput>?fuseaction=sales.popup_add_discount_coupon"><img title="<cf_get_lang_main no='170.Ekle'>" src="/images/plus1.gif"></a></cfsavecontent>
<cf_popup_box title="#title_#" right_images="#img#">
<cfoutput>
	<cfform name="order_form" method="post" action="#request.self#?fuseaction=sales.emptypopup_upd_discount_coupon">
    <input type="hidden" name="order_credit_id" id="order_credit_id" value="<cfoutput>#attributes.order_credit_id#</cfoutput>">
    <table border="0" style="width:98%">
        <tr style="height:22px;">
            <td class="txtbold"><cf_get_lang_main no='107.Cari Hesap'> *</td>
            <td>
				<input type="hidden" name="consumer_id" id="consumer_id" value="<cfif len(get_discount_coupon.consumer_id)><cfoutput>#get_discount_coupon.consumer_id# </cfoutput></cfif>">
				<input type="hidden" name="company_id" id="company_id" value="<cfif len(get_discount_coupon.company_id)><cfoutput>#get_discount_coupon.company_id#</cfoutput></cfif>">
				<!---<input type="hidden" name="member_type" id="member_type" value="<cfif isdefined("attributes.member_type")><cfoutput>#attributes.member_type#</cfoutput></cfif>">--->
				<input type="text" name="member_name" id="member_name" style="width:90px;" onFocus="AutoComplete_Create('member_name','MEMBER_NAME,MEMBER_PARTNER_NAME,MEMBER_CODE','MEMBER_NAME,MEMBER_PARTNER_NAME,MEMBER_CODE','get_member_autocomplete','\'1,2\'','CONSUMER_ID,COMPANY_ID,MEMBER_TYPE','consumer_id,company_id,member_type','','3','250');" value="<cfif len(get_discount_coupon.company_id)>#get_par_info(get_discount_coupon.company_id,1,0,0)#<cfelseif len(get_discount_coupon.consumer_id)>#get_cons_info(get_discount_coupon.consumer_id,0,0)#</cfif>" autocomplete="off">
				<cfset str_linke_ait="&field_consumer=order_form.consumer_id&field_comp_id=order_form.company_id&field_member_name=order_form.member_name&field_type=order_form.member_type">
				<a href="javascript://" onClick="windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_list_all_pars#str_linke_ait#</cfoutput><cfif session.ep.isBranchAuthorization>&is_store_module=1</cfif>&select_list=7,8&keyword='+encodeURIComponent(document.order_form.member_name.value),'list');">
				<img src="/images/plus_thin.gif"></a>
			</td>
        </tr>
        <cfif len(get_discount_coupon.target_market_id)>
            <cfquery name="GET_TARGET_MARKET" datasource="#DSN3#">
                SELECT 
                    TMARKET_ID,
                    TMARKET_NAME
                FROM
                    TARGET_MARKETS
                WHERE
                    TMARKET_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_discount_coupon.target_market_id#">
            </cfquery>
        </cfif>
        <tr style="height:22px;">
            <td class="txtbold">Hedef Kitle *</td>
            <td>
				<input type="hidden" name="target_market_id" id="target_market_id" value="<cfif len(get_discount_coupon.target_market_id)><cfoutput>#get_discount_coupon.target_market_id#</cfoutput></cfif>">
				<input type="text" name="target_market" id="target_market" style="width:150px;" value="<cfif len(get_discount_coupon.target_market_id)><cfoutput>#get_target_market.tmarket_name#</cfoutput></cfif>" autocomplete="off">
                <a href="javascript://" onClick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=campaign.popup_list_target_markets&is_money_credit=1','list');">
				<img src="/images/plus_thin.gif"></a>
             </td>
        </tr>
        <tr>
        	<td class="txtbold">Tutar *</td>
            <td>
            	<cfinput type="text" name="total_price" id="total_price" style="width:63px;" class="moneybox" onkeyup="return(FormatCurrency(this,event,#session.ep.our_company_info.sales_price_round_num#));" value="#TLFormat(get_discount_coupon.money_credit,2)#">
            </td>
        </tr>
        <tr>
        	<td class="txtbold">Minimum Sipariş Tutarı </td>
            <td>
            	<cfinput type="text" name="min_order_total" id="min_order_total" style="width:63px;" class="moneybox" onkeyup="return(FormatCurrency(this,event,#session.ep.our_company_info.sales_price_round_num#));" value="#TLFormat(get_discount_coupon.min_order_total,2)#">
            </td>
        </tr>
		<tr style="height:22px;">
            <td class="txtbold">Geçerlilik Tarihi</td>
            <td>
                <cfsavecontent variable="message">Geçerli bir tarih giriniz!</cfsavecontent>
                <cfinput type="text" name="valid_date" id="valid_date" validate="#validate_style#" maxlength="10" message="#message#" style="width:63px;" value="#dateformat(get_discount_coupon.valid_date,dateformat_style)#">
                <cf_wrk_date_image date_field="valid_date">
            </td>
        </tr>
      	<tr>
        	<td class="txtbold">Eklenecek Kupon Sayısı *</td>
            <td>
            	<input type="text" name="coupon_count" id="coupon_count" onkeyup="isNumber(this);" value="<cfoutput>#get_discount_coupon.coupon_count#</cfoutput>" style="width:30px;">
            </td>
        </tr>
        <tr>
        	<td>
                <input type="checkbox" name="is_member_special" id="is_member_special" <cfif len(get_discount_coupon.is_special) and get_discount_coupon.is_special eq 1>checked</cfif>>&nbsp;&nbsp;Üyeye Özel
            </td>
        </tr>
    </table>
    <cf_popup_box_footer>
    	<cfif get_is_used.recordcount>
    		<cf_workcube_buttons is_upd='1' is_delete='0' add_function='control()' insert_info='Gönder'>
    	<cfelse>
    		<cf_workcube_buttons is_upd='1' is_delete='1' add_function='control()' insert_info='Gönder'	delete_page_url='#request.self#?fuseaction=sales.emptypopup_del_discount_coupon&order_credit_id=#attributes.order_credit_id#'>
>
		</cfif>    
    </cf_popup_box_footer>	
	</cfform>
</cfoutput>
</cf_popup_box>

<script language="javascript">
	function control()
	{
		if(document.getElementById('member_name').value == '' && document.getElementById('target_market').value == '')
		{
			alert('Lütfen hedef kitle ya da cariden birini seçiniz!');
			document.getElementById('target_market').focus();	
			return false;
		}

		if(document.getElementById('total_price').value == '')
		{
			alert('Lütfen tutar giriniz!');
			document.getElementById('total_price').focus();	
			return false;
		}

		if(document.getElementById('coupon_count').value == '')
		{
			alert('Lütfen kupon sayısı giriniz!');
			document.getElementById('coupon_count').focus();	
			return false;
		}
		document.getElementById('total_price').value = filterNum(document.getElementById('total_price').value);
		document.getElementById('min_order_total').value = filterNum(document.getElementById('min_order_total').value);
	}
</script>

