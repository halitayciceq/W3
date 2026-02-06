<cfparam name="attributes.action_period_year" default="#session.ep.period_year#">
<cfquery name="get_period" datasource="#dsn#">
	SELECT PERIOD_ID,PERIOD_YEAR,OUR_COMPANY_ID FROM SETUP_PERIOD WHERE OUR_COMPANY_ID=#session.ep.company_id# ORDER BY PERIOD_YEAR DESC
</cfquery>
<cfset action_dsn2 = '#dsn#_#attributes.action_period_year#_#get_period.OUR_COMPANY_ID#'>
<script type="text/javascript">
function connectAjax(div_id,data)
{
	if (div_id == 'LIST_BANK_ACTIONS')//banka hareketleri
	var page = '<cfoutput>#request.self#?fuseaction=project.popupajax_list_bank_actions&id=#attributes.id#&action_dsn2=#action_dsn2#</cfoutput>';
	
	if (div_id == 'LIST_CASH_ACTIONS')//kasa hareketleri
	var page = '<cfoutput>#request.self#?fuseaction=project.popupajax_list_cash_actions&id=#attributes.id#&action_dsn2=#action_dsn2#</cfoutput>';
	
	if (div_id == 'LIST_CARI_ACTIONS')//cari virman hareketleri
	var page = '<cfoutput>#request.self#?fuseaction=project.popupajax_list_cari_actions&id=#attributes.id#&action_dsn2=#action_dsn2#</cfoutput>';
	
	if (div_id == 'LIST_CHEQUE_ACTIONS')//çek hareketleri
	var page = '<cfoutput>#request.self#?fuseaction=project.popupajax_list_cheque_actions&id=#attributes.id#&action_dsn2=#action_dsn2#</cfoutput>';
	
	if (div_id == 'LIST_VOUCHER_ACTIONS')//senet hareketleri
	var page = '<cfoutput>#request.self#?fuseaction=project.popupajax_list_voucher_actions&id=#attributes.id#&action_dsn2=#action_dsn2#</cfoutput>';

	if (div_id == 'LIST_BUDGETS')//bütçeler
	var page = '<cfoutput>#request.self#?fuseaction=project.popupajax_list_budgets&id=#attributes.id#</cfoutput>';

	if (div_id == 'LIST_CC_REVENUE_ACTIONS')//kkartı tahsilatları
	var page = '<cfoutput>#request.self#?fuseaction=project.popupajax_list_cc_revenue&id=#attributes.id#</cfoutput>';

	if (div_id == 'LIST_PROJECT_SECUREFUND_DIV')//TEMİNAT
	var page = '<cfoutput>#request.self#?fuseaction=project.popup_ajax_list_project_securefund&id=#attributes.id#</cfoutput>';
	
	if (div_id == 'LIST_PROJECT_ASSIGN_ORDER_DIV')//TALİMAT
	var page = '<cfoutput>#request.self#?fuseaction=project.popup_ajax_list_project_assign_order&id=#attributes.id#</cfoutput>';

	AjaxPageLoad(page,''+div_id+'',1,"<cf_get_lang dictionary_id ='58644.Sayfa Yükleniyor'>");
}
</script>
<cfparam name="attributes.modal_id" default="">
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
<cfform name="action_year_form" method="post" action="#request.self#?fuseaction=project.popup_list_project_financial_actions&id=#URL.ID#">
    <cfsavecontent variable="right_">
        <cf_box_elements>
            <div class="form-group">
                <select name="action_period_year" id="action_period_year" style="width:80px" onChange="action_year_form.submit();">
                    <option value=""><cf_get_lang dictionary_id='30047.Mali Yıl'></option>
                    <cfoutput query="GET_PERIOD">
                        <option value="#PERIOD_YEAR#" <cfif attributes.action_period_year eq period_year>selected</cfif>>#PERIOD_YEAR#
                    </cfoutput>
                </select>
            </div>
        </cf_box_elements>
    </cfsavecontent>
        <cfsavecontent variable="title"><cf_get_lang dictionary_id='38223.Finansal İşlemler'></cfsavecontent>
        <cf_box title="#title#" right_images="#right_#" resize="0" collapsable="0" popup_box="#iif(isdefined("attributes.draggable"),1,0)#">
            <cfsavecontent variable="title"><cf_get_lang dictionary_id='58896.Banka İşlemleri'></cfsavecontent>
            <cf_seperator id="bank_1" title="#title#" onClick_function="connectAjax('LIST_BANK_ACTIONS');" is_closed="1">
            <div id="bank_1" style="display:none;">
               <div align="left" id="LIST_BANK_ACTIONS"></div>
            </div>
            <cfsavecontent variable="title"><cf_get_lang dictionary_id='58897.Kasa İşlemleri'></cfsavecontent>
            <cf_seperator id="cash_1" title="#title#" onClick_function="connectAjax('LIST_CASH_ACTIONS');" is_closed="1">
            <div id="cash_1" style="display:none;">
               <div align="left" id="LIST_CASH_ACTIONS"></div>
            </div>
            <cfsavecontent variable="title"><cf_get_lang dictionary_id='38356.Cari Virman İşlemleri'></cfsavecontent>
            <cf_seperator id="cari_1" title="#title#" onClick_function="connectAjax('LIST_CARI_ACTIONS');" is_closed="1">
            <div id="cari_1" style="display:none">
                <div align="left" id="LIST_CARI_ACTIONS"></div>
            </div>
            <cfsavecontent variable="title"><cf_get_lang dictionary_id='57852.Çek Giriş Bordrosu'></cfsavecontent>
            <cf_seperator id="cheque_1" title="#title#" onClick_function="connectAjax('LIST_CHEQUE_ACTIONS');" is_closed="1">
            <div id="cheque_1" style="display:none;">
                <div align="left" id="LIST_CHEQUE_ACTIONS"></div>
            </div>
            <cfsavecontent variable="title"><cf_get_lang dictionary_id='58010.Senet Giriş Bordrosu'></cfsavecontent>
            <cf_seperator id="voucher_1" title="#title#" onClick_function="connectAjax('LIST_VOUCHER_ACTIONS');" is_closed="1">
            <div id="voucher_1" style="display:none;">
                <div align="left" id="LIST_VOUCHER_ACTIONS"></div>
            </div>
            <cfsavecontent variable="title"><cf_get_lang dictionary_id='30101.Kredi Kartı Tahsilatları'></cfsavecontent>
            <cf_seperator id="cc_revenue_1" title="#title#" onClick_function="connectAjax('LIST_CC_REVENUE_ACTIONS');" is_closed="1">
            <div id="cc_revenue_1" style="display:none;">
                <div align="left" id="LIST_CC_REVENUE_ACTIONS"></div>
            </div>
            <cfsavecontent variable="title"><cf_get_lang dictionary_id='57676.Teminatlar'></cfsavecontent>
            <cf_seperator id="list_project_securefund" title="#title#" onClick_function="connectAjax('LIST_PROJECT_SECUREFUND_DIV');" is_closed="1">
            <div id="list_project_securefund" style="display:none;">
                <div align="left" id="LIST_PROJECT_SECUREFUND_DIV"></div>
            </div>
            <cfsavecontent variable="title"><cf_get_lang dictionary_id='48821.Banka Talimatları'></cfsavecontent>
            <cf_seperator id="list_project_assign_order" title="#title#" onClick_function="connectAjax('LIST_PROJECT_ASSIGN_ORDER_DIV');" is_closed="1">
            <div id="list_project_assign_order" style="display:none;">
                <div align="left" id="LIST_PROJECT_ASSIGN_ORDER_DIV"></div>  
            </div>
            <cfsavecontent variable="title"><cf_get_lang dictionary_id='57524.Bütçeler'></cfsavecontent>
            <cf_seperator id="budget_1" title="#title#" onClick_function="connectAjax('LIST_BUDGETS');" is_closed="1">
            <div id="budget_1" style="display:none;">
                <div align="left" id="LIST_BUDGETS"></div>
            </div>
        </cf_box>
       
</cfform>
</div>