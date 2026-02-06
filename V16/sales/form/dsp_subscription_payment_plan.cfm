<cfsetting showdebugoutput="no">
<cfset contract_cmp = createObject("component","V16.sales.cfc.subscription_contract")>
<cf_xml_page_edit fuseact ="sales.popup_dsp_subscription_payment_plan">
<cfset colspan_info = 18>
<cfif x_payment_plan_kdv>
	<cfset colspan_info = colspan_info + 1>
</cfif>
<cfif x_payment_plan_otv>
	<cfset colspan_info = colspan_info + 1>
</cfif>
<cfif x_payment_plan_isk_amount>
	<cfset colspan_info = colspan_info + 1>
</cfif>
<cfif x_payment_plan_kdv_amount>
	<cfset colspan_info = colspan_info + 1>
</cfif>
<cfif x_payment_plan_revenue_info>
	<cfset colspan_info = colspan_info + 1>
</cfif>
<cfif x_payment_plan_campaign>
	<cfset colspan_info = colspan_info + 1>
</cfif>
<cfif x_payment_plan_reference>
	<cfset colspan_info = colspan_info + 1>
</cfif>
<cfif x_payment_plan_service>
	<cfset colspan_info = colspan_info + 1>
</cfif>
<cfif x_payment_plan_call>
	<cfset colspan_info = colspan_info + 1>
</cfif>
<cfif x_payment_plan_record_info>
	<cfset colspan_info = colspan_info +2>
</cfif>
<script>
	function open_year(div_id,payment_year)
	{
		<cfoutput>AjaxPageLoad('#request.self#?fuseaction=sales.emptypopup_dsp_subscription_payment_plan_ic&colspan_info=#colspan_info#&#xml_str#&subscription_id=#attributes.subscription_id#&payment_year='+payment_year,div_id,1);</cfoutput>
	}
</script>
<cfparam name="attributes.paymethod" default="">
<cfparam name="attributes.paymethod_id" default="">
<cfparam name="attributes.card_paymethod_id" default="">
<cfparam name="attributes.product_name" default="">
<cfparam name="attributes.product_id" default="">
<cfparam name="attributes.stock_id" default="">
<cfparam name="attributes.count" default="0">
<cfparam name="attributes.quantity" default="1">
<cfparam name="attributes.amount" default="">
<cfparam name="attributes.discount" default="0">
<cfparam name="attributes.net_amount" default="">
<cfparam name="attributes.unit" default="">
<cfparam name="attributes.unit_id" default="">
<cfparam name="attributes.start_date" default="#dateformat(now(),dateformat_style)#">
<cfparam name="attributes.period" default="">
<cfparam name="attributes.money_type" default="">
<cfparam name="attributes.comp_id" default="">
<cfparam name="attributes.cons_id" default="">
<cfif Len(attributes.comp_id)><cfset attributes.comp_id = listSort(ListDeleteDuplicates(attributes.comp_id),"numeric","asc",",")></cfif>
<cfif Len(attributes.cons_id)><cfset attributes.cons_id = listSort(ListDeleteDuplicates(attributes.cons_id),"numeric","asc",",")></cfif>
<cfset GET_SUBSCRIPTION = contract_cmp.GET_SUBSCRIPTION(subscription_id : attributes.subscription_id)>
<cfset GET_PAYMENT_ROWS = contract_cmp.GET_PAYMENT_ROWS_DISPLAY(subscription_id : attributes.subscription_id)>
<cfif xml_year_group eq 1>
	<cfquery name="get_year" dbtype="query">
		SELECT DISTINCT PAYMENT_YEAR FROM get_payment_rows
	</cfquery>
</cfif>
<cf_box title="#getLang('','Ödeme Planı',59657)#" scroll="1" collapsable="1" resize="1" popup_box="#iif(isdefined("attributes.draggable"),1,0)#">
<table class="dph">
    <tr>
        <td class="dpht">
            <cf_get_lang dictionary_id='59657.Ödeme Planı'> :
            <cfoutput>#get_subscription.subscription_no# /
            <cfif len(get_subscription.company_id)>
                #get_par_info(get_subscription.company_id,1,0,0)#
            <cfelse>
                #get_cons_info(get_subscription.consumer_id,0,0)#
            </cfif>
            </cfoutput>
        </td>
    </tr>
</table>
<cf_basket>
	<cfif get_payment_rows.recordcount>
        <cfif xml_year_group eq 1>
            <cfoutput query="get_year">
                <table class="color-list" width="100%" align="center" height="25">
                    <tr>
                        <td width="50" valign="top">
                            <a href="javascript://" onClick="gizle_goster(year_div_tr_#payment_year#);open_year('year_div_#payment_year#',#payment_year#);"><b>&raquo;#payment_year#</b></a>
                        </td>
                        <cfquery name="get_rows" dbtype="query">
                            SELECT DETAIL,COUNT(SUBSCRIPTION_PAYMENT_ROW_ID) ROW_COUNT FROM get_payment_rows WHERE PAYMENT_YEAR = #payment_year# GROUP BY DETAIL
                        </cfquery>
						<td>
							<table>
								<cfloop query="get_rows">
									<tr>
										<td>#detail# : #row_count#</td>
									</tr>
								</cfloop>
							</table>
						</td>
                    </tr>
                </table>
                <table>
                    <tr style="display:none;" id="year_div_tr_#payment_year#">
                        <td>
                            <div id="year_div_#payment_year#"></div>
                        </td>
                    </tr>
                </table>
                <br /><br />
                <cfif payment_year eq session.ep.period_year>
                    <script language="javascript">
                        gizle_goster(year_div_tr_#payment_year#);
                        open_year('year_div_#payment_year#','#payment_year#');
                    </script>
                </cfif>
            </cfoutput>
        <cfelse>
        	<table>
                <tr>
                    <td>
                        <div id="year_div"></div>
                    </td>
                </tr>
            </table>
            <script language="javascript">
                open_year('year_div','');
            </script>
        </cfif>
    <cfelse>
    	<table>
            <tr>
                <td colspan="25"><cf_get_lang dictionary_id="58486.Kayıt Bulunamadı"> !</td>
            </tr>
        </table>
    </cfif>
</cf_basket>
</cf_box>