<cfquery name="GET_MONEY_CREDIT" datasource="#DSN3#">
	SELECT
		OMC.ORDER_CREDIT_ID,
		OMC.ORDER_ID, 
		OMC.CREDIT_RATE,
		OMC.MONEY_CREDIT,
		OMC.VALID_DATE,
		OMC.USE_CREDIT,
		OMC.COMPANY_ID,
		OMC.CONSUMER_ID, 
		OMC.MONEY_CREDIT_STATUS,
        OMC.RECORD_EMP,
        OMC.RECORD_DATE,
        OMC.RECORD_IP,
        OMC.RECORD_CONS,
       	OMC.UPDATE_EMP,
        OMC.UPDATE_DATE,
        OMC.UPDATE_IP,
        OMC.UPDATE_CONS,
        <cfif isDefined('attributes.order_id') and len(attributes.order_id)>
			O.ORDER_NUMBER,
		</cfif>
		ISNULL(IS_TYPE,0) IS_GIFT_CARD
	FROM
		ORDER_MONEY_CREDITS OMC
        <cfif isDefined('attributes.order_id') and len(attributes.order_id)>
			,ORDERS O
        </cfif>
	WHERE
        <cfif isDefined('attributes.order_id') and len(attributes.order_id)>
			OMC.ORDER_ID = O.ORDER_ID AND
		</cfif>
		OMC.ORDER_CREDIT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.order_credit_id#">
</cfquery>
<cfsavecontent variable="title_">
	<cfif get_money_credit.is_gift_card eq 1>Hediye Çeki<cfelse>Parapuan</cfif> : <cfif isDefined('get_money_credit.order_number') and len(get_money_credit.order_number)><cfoutput>#get_money_credit.order_number#</cfoutput></cfif>
</cfsavecontent>
<cf_popup_box title="#title_#">
<cfoutput>
    <cfform name="order_form" method="post" action="#request.self#?fuseaction=sales.emptypopup_upd_money_credit">
    <input type="hidden" name="order_credit_id" id="order_credit_id" value="#attributes.order_credit_id#">
    <table style="width:98%;">
        <tr>
            <td></td>
            <td>
                <input type="checkbox" name="money_credit_status" id="money_credit_status"<cfif len(get_money_credit.money_credit_status) and get_money_credit.money_credit_status eq 1>checked</cfif> <cfif get_money_credit.money_credit eq get_money_credit.use_credit>disabled</cfif>>&nbsp;&nbsp;Aktif
            </td>
        </tr>
        <tr style="height:22px;">
            <td class="txtbold" style="width:120px;">Cari Hesap</td>
            <td>
                <cfif len(get_money_credit.company_id)>
                    <cfquery name="GET_COMPANY" datasource="#DSN#">
                        SELECT COMPANY_ID, NICKNAME, FULLNAME FROM COMPANY WHERE COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_money_credit.company_id#">
                    </cfquery>
                    #get_company.nickname#
                <cfelseif len(get_money_credit.consumer_id)>
                    <cfquery name="GET_CONSUMER" datasource="#DSN#">
                        SELECT CONSUMER_ID, CONSUMER_NAME, CONSUMER_SURNAME FROM CONSUMER WHERE CONSUMER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_money_credit.consumer_id#">
                    </cfquery>
                    #get_consumer.consumer_name# #get_consumer.consumer_surname#
                </cfif>
            </td>
        </tr>
        <cfif get_money_credit.is_gift_card eq 1>
            <tr style="height:22px;">
                <td class="txtbold">Hediye Çeki</td>
                <td>#TlFormat(get_money_credit.money_credit)#</td>
            </tr>
            <tr style="height:22px;">
                <td class="txtbold">Kullanılan Tutar</td>
                <td>#TlFormat(get_money_credit.use_credit)#</td>
            </tr>
        <cfelse>	
            <tr style="height:22px;">
                <td class="txtbold">Kazanılan Parapuan</td>
                <td>#TlFormat(get_money_credit.money_credit)#</td>
            </tr>
            <tr style="height:22px;">
                <td class="txtbold">Kullanılan Parapuan</td>
                <td>#TlFormat(get_money_credit.use_credit)#</td>
            </tr>
            <tr style="height:22px;">
                <td class="txtbold">Parapuan Yüzdesi</td>
                <td>#get_money_credit.credit_rate#</td>
            </tr>
        </cfif>
        <tr style="height:22px;">
            <td class="txtbold">Geçerlilik Tarihi</td>
            <td>
                <cfsavecontent variable="message">Geçerlilik Tarihi Giriniz!</cfsavecontent>
                <cfinput type="text" name="valid_date" id="valid_date" required="Yes" validate="#validate_style#" maxlength="10" message="#message#" style="width:63px;" value="#dateformat(get_money_credit.valid_date,dateformat_style)#">
                <cf_wrk_date_image date_field="valid_date">
            </td>
        </tr>
        <cfquery name="GET_ORDER_USED" datasource="#DSN3#">
            SELECT
                O.ORDER_ID,
                O.ORDER_NUMBER,
                USED_VALUE
            FROM
                ORDERS O
                LEFT JOIN ORDER_MONEY_CREDIT_USED OU ON O.ORDER_ID = OU.ORDER_ID
            WHERE
                OU.ORDER_CREDIT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.order_credit_id#">
        </cfquery>
        <cfif get_order_used.recordcount>
            <tr style="height:40px;">
                <td class="txtbold">Kullanılan Siparişler</td>
            </tr>
            <tr>
                <td class="txtbold">Sipariş No</td>
                <td class="txtbold">Kullanılan Tutar</td>
            </tr>
            <cfloop query="get_order_used">
                <tr>
                    <td><a href="javascript://" onClick="windowopen('#request.self#?fuseaction=sales.list_order&event=upd&order_id=#order_id#','wide');" class="tableyazi">#order_number#</a></td>
                    <td>#tlformat(used_value)#</td>
                </tr>
            </cfloop>
        </cfif>
         <tr>
            <td colspan="2">                
				 <cfif len(get_money_credit.record_emp)>
                 	<cf_get_lang_main no='71.Kayit'>:
                    <cf_record_info query_name="get_money_credit" record_emp="RECORD_EMP">
                <cfelseif len(get_money_credit.record_cons)>
                	<cf_get_lang_main no='71.Kayit'>:
                    <cf_record_info query_name="get_money_credit" record_cons="RECORD_CONS">
                </cfif>
                <cfif len(get_money_credit.update_emp)>
                    &nbsp;&nbsp;&nbsp;<cf_get_lang no='133.Güncelleme'>
                    <cf_record_info query_name="get_money_credit" record_cons="UPDATE_EMP">
                <cfelseif len(get_money_credit.update_cons)>
                    &nbsp;&nbsp;&nbsp;<cf_get_lang no='133.Güncelleme'>
                    <cf_record_info query_name="get_money_credit" record_cons="UPDATE_CONS">
                </cfif>
            </td>
        </tr>
    </table>
    <cf_popup_box_footer>
        <cf_workcube_buttons is_upd='1' is_delete='0'>
    </cf_popup_box_footer>	
    </cfform>
</cfoutput>
</cf_popup_box>

