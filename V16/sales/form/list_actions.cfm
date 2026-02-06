
<!--- File: list_actions.cfm
Author:Canan Ebret <cananebret@workcube.com>
Date: 27.08.2019
Controller: -
Description: Abone detay sayfasinda diger tab menusu nun icinde operasyonlar ile ilgili liste  oluşturuldu.​ --->
<cfset cfc= createObject("component","V16.sales.cfc.get_actions")>
<cf_xml_page_edit fuseact="sales.popup_list_actions"> 
<cfparam name="attributes.from_paper" default="">
<cfparam name="attributes.action_status" default="">
<cfparam name="attributes.is_form_sales" default="1">
<cfparam name="attributes.subscription_id" default="1">
<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>
<script type="text/javascript">
	<cfoutput>
		var from_paper = '#attributes.from_paper#';
		function connectAjax(div_id,data,period_id,xml_)
		{
			if(document.getElementById('line_based').checked == true) 
			var line_based = 1;else line_based = 0;
			
			if(document.getElementById('action_status').value == 1) 
				var action_status = 1;
			else if(document.getElementById('action_status').value == 0)
				action_status = 0;
			else
				action_status = 2;
			
			if (div_id == 'LIST_SALE_ORDER')//satis siparisleri
				var page = '#request.self#?fuseaction=project.popup_ajax_list_sale_orders&action_status='+action_status+'&from_paper='+from_paper+'&line_based='+line_based+'&subscription_id=#attributes.subscription_id#&id=#attributes.subscription_id#&is_from_sales=1&xml_='+xml_;
			if (div_id == 'LIST_SHIPS' || div_id == 'LIST_SHIPS_PURCHASE')	//irsaliyeler
			{
				if(div_id =='LIST_SHIPS_PURCHASE') var purchase_sales = 0; else var purchase_sales = 1;
				var page = '#request.self#?fuseaction=project.popup_ajax_list_ships&action_status='+action_status+'&from_paper='+from_paper+'&line_based='+line_based+'&purchase_sales='+purchase_sales+'&subscription_id=#attributes.subscription_id#&id=#attributes.subscription_id#&is_from_sales=1&action_dsn2='+ data +'&period_id='+period_id;
			}	
			if (div_id == 'LIST_PURCHASE_IMP')//ithal mal girisi
				var page = '#request.self#?fuseaction=project.popup_ajax_list_purchase_import&action_status='+action_status+'&subscription_id=#attributes.subscription_id#&id=#attributes.subscription_id#&is_from_sales=1'; 
			if (div_id == 'LIST_INVOICE_EXPENSE_SALES' || div_id == 'LIST_INVOICE_EXPENSE_PURCHASE'){//ilgili alış satış faturalar
				if(div_id =='LIST_INVOICE_EXPENSE_PURCHASE') var purchase_sales = 0; else var purchase_sales = 1;
				if(line_based==1)//satır bazında ise..
                    var page = '#request.self#?fuseaction=project.popup_add_sales_invoice_from_project&action_status='+action_status+'&from_paper='+from_paper+'&subscription_id=#attributes.subscription_id#&id=#attributes.subscription_id#&is_from_sales=1&purchase_sales='+purchase_sales+'&is_from_sales=1&line_based='+line_based+'&action_dsn2='+ data+'&period_id='+period_id+'&xml_='+xml_;
				else
					var page = '#request.self#?fuseaction=project.popup_ajax_list_pro_invoice_expense&action_status='+action_status+'&purchase_sales='+purchase_sales+'&purchase_sales=#attributes.subscription_id#&id=#attributes.subscription_id#&is_from_sales=1&action_dsn2='+ data+'&period_id='+period_id +'&line_based='+line_based+'&xml_='+xml_;
			}
			if (div_id == 'LIST_PROJECT_SERVICE')//servis basvurlari//
				var page = '#request.self#?fuseaction=project.popup_ajax_list_project_service&action_status='+action_status+'&line_based='+line_based+'&from_paper='+from_paper+'&subscription_id=#attributes.subscription_id#&id=#attributes.subscription_id#&is_from_sales=1';
			if (div_id == 'LIST_PROJECT_EXPENSE_DIV')//mssraf fisi
				var page = '#request.self#?fuseaction=project.popup_ajax_list_project_expense&action_status='+action_status+'&is_from_sales=1&from_paper='+from_paper+'&action_dsn2='+ data+'&period_id='+period_id+'&line_based='+line_based+'&subscription_id=#attributes.subscription_id#&id=#attributes.subscription_id#&xml_='+xml_;
			if (div_id == 'LIST_PROJECT_INVENTORY_DIV')//sabit kiymetler
				var page = '#request.self#?fuseaction=project.popup_ajax_list_project_inventory&action_status='+action_status+'&subscription_id=#attributes.subscription_id#&id=#attributes.subscription_id#&is_from_sales=1';
			if(div_id == 'call_center_apps_div')//call center başvuruları
				var page='#request.self#?fuseaction=project.popup_ajax_project_call_service&action_status='+action_status+'&subscription_id=#attributes.subscription_id#&id=#attributes.subscription_id#&is_from_sales=1';  

            page = page + '&maxrows=' + $("##maxrows").val() + '&order_type=' + $("##order_type").val();

			AjaxPageLoad(page,''+div_id+'',1);
		}
	</cfoutput>
</script>
<cfparam name="attributes.action_period_year" default="#session.ep.period_id#;#session.ep.period_year#">
<cfset get_period=cfc.GetPeriod()>
<cfset URL.ID = url.subscription_id>
<cfsavecontent variable="sub_no">
    <cfset get_subscription=cfc.GetSubscription(subscription_id:attributes.subscription_id)>
    <cf_get_lang dictionary_id='29502.Abone No'>:
        <cfoutput>#get_subscription.subscription_no# /
        <cfif len(get_subscription.company_id)>
            #get_par_info(get_subscription.company_id,1,0,0)#
        <cfelse>
            #get_cons_info(get_subscription.consumer_id,0,0)#
        </cfif>
    </cfoutput>   
</cfsavecontent>
<cf_box title="#sub_no#" scroll="1" collapsable="1" resize="1" popup_box="#iif(isdefined("attributes.draggable"),1,0)#">
    <cfform name="action_year_form" method="post" action="#request.self#?fuseaction=sales.popup_list_actions&subscription_id=#URL.ID#">
        <cf_box_search>
            <div class="form-group">
                <select name="order_type" id="order_type">
                    <option value = "date_desc"><cf_get_lang dictionary_id='47983.Tarihe Göre Azalan'></option>
                    <option value = "date_asc"><cf_get_lang dictionary_id='47978.Tarihe Göre Artan'></option>
                    <option value = "paperno_desc"><cf_get_lang dictionary_id='63024.Belge Noya Göre Azalan'></option>
                    <option value = "paperno_asc"><cf_get_lang dictionary_id='63024.Belge Noya Göre Azalan'></option>
                </select>
            </div>
            <div class="form-group small">
                <cfinput type="text" name="maxrows" id="maxrows"  maxlength="3" value="#attributes.maxrows#" validate="integer" range="1,250" required="yes" onKeyUp="isNumber(this)" message="#getLang('','Kayıt Sayısı Hatalı',57537)#">
            </div>
            <div class="form-group">
                <label><cf_get_lang dictionary_id='29539.Satır Bazında'></label>
                <input type="checkbox" name="line_based" id="line_based" <cfif (isdefined('attributes.from_paper') and len(attributes.from_paper)) or xml_select_line_based eq 1>checked</cfif>><!--- <cfelseif not len(attributes.from_paper)>disabled kaldirildi, fat,sip,irs,tekl belgeleri gibi bir yerden çağırılıyorsa.. --->
            </div>
            <div class="form-group">
                <label><cf_get_lang dictionary_id='30047.Mali Yıl'></label>
                <select name="action_period_year" id="action_period_year"  onchange="action_year_form.submit();">
                    <cfoutput query="GET_PERIOD">
                        <option value="#PERIOD_ID#;#PERIOD_YEAR#" <cfif ListLast(attributes.action_period_year,';') eq period_year>selected</cfif>>#PERIOD_YEAR#</option>
                    </cfoutput>
                </select>
            </div>
            <div class="form-group">
                <select name="action_status" id="action_status" >
                    <option value="1" <cfif attributes.action_status eq 1>selected</cfif>><cf_get_lang dictionary_id='57493.Aktif'></option>
                    <option value="0" <cfif attributes.action_status eq 0>selected</cfif>><cf_get_lang dictionary_id='57494.Pasif'></option>
                    <option value="2" <cfif attributes.action_status eq 2>selected</cfif>><cf_get_lang dictionary_id='57708.Tümü'></option>
                </select>
            </div>
                <cf_get_lang_set module_name="project">
                    <cfif  not listfindnocase(denied_pages,'sales.form_add_order')>
                        <div class="form-group">
                            <a class="ui-btn ui-btn-gray2" href="<cfoutput>#request.self#?fuseaction=sales.list_order&event=add<cfif not isdefined("attributes.is_from_product")>&from_project_material=#attributes.subscription_id#</cfif></cfoutput>" target="_blank"><i class="fa fa-shopping-basket" title="<cf_get_lang dictionary_id='40809.Sipariş Al'>"></i></a>
                        </div>
                        <div class="form-group">
                            <a class="ui-btn ui-btn-gray2" href="<cfoutput>#request.self#?fuseaction=sales.list_offer&event=add<cfif not isdefined("attributes.is_from_product")>&project_id=#attributes.subscription_id#</cfif></cfoutput>" target="_blank" class="form-title"><i class="fa fa-sticky-note" title="<cf_get_lang dictionary_id='46853.Teklif Ver'>"></i></a>
                        </div>
                    </cfif>
                    <cfif not listfindnocase(denied_pages,'purchase.form_add_order')>
                        <div class="form-group">
                            <a class="ui-btn ui-btn-gray2" href="<cfoutput>#request.self#?fuseaction=purchase.list_order&event=add<cfif not isdefined("attributes.is_from_product")>&from_project_material=#attributes.subscription_id#</cfif></cfoutput>" target="_blank"><i class="fa fa-credit-card" title="<cf_get_lang dictionary_id='45318.Sipariş Ver'>"></i></a> 
                        </div>
                        <div class="form-group">
                            <a class="ui-btn ui-btn-gray2" href="<cfoutput>#request.self#?fuseaction=purchase.list_offer&event=add<cfif not isdefined("attributes.is_from_product")>&project_id=#attributes.subscription_id#</cfif></cfoutput>" target="_blank"><i class="fa fa-plus-square-o" title="<cf_get_lang dictionary_id='38490.Teklif Al'>"></i></a>
                        </div>
                    </cfif>
                    <cfif not listfindnocase(denied_pages,'prod.add_prod_order')>
                        <div class="form-group">
                            <a class="ui-btn ui-btn-gray2" href="<cfoutput>#request.self#?fuseaction=prod.order&event=add<cfif not isdefined("attributes.is_from_product")>&pj_id=#attributes.subscription_id#</cfif></cfoutput>" target="_blank"><i class="catalyst-action-redo" title="<cf_get_lang dictionary_id='49884.Üretim Emri'>"></i></a>
                        </div>
                    </cfif>
                <cf_get_lang_set module_name="#lcase(listgetat(attributes.fuseaction,1,'.'))#">
        </cf_box_search> 
        <table class="workDevList" cellpadding="2" cellspacing="1" width="98%" align="center">    
            <cfset action_dsn2 = '#dsn#_#ListLast(attributes.action_period_year,";")#_#get_period.OUR_COMPANY_ID#'>	    
            <cfif xml_is_show_sales_order>
                <tr>
                <cf_seperator title="#getLang('','Satış Siparişleri','58207')#" id="list_sale_orders1_menu2"onClick_function="connectAjax('LIST_SALE_ORDER');"  is_closed="1">
                    <div id="list_sale_orders1_menu2" class="color-row" style="display:none">
                        <div align="left" id="LIST_SALE_ORDER" ></div><!--- satis siparisleri --->
                    </div>
                </tr>
               
            </cfif>
            <cfif xml_is_show_ships>
                <tr>
                    <cf_seperator title="#getLang('','Satış','57448')# #getLang('','İrsaliye','57773')#"id="list_ships1_menu2" onClick_function="connectAjax('LIST_SHIPS','#action_dsn2#','#ListFirst(attributes.action_period_year,";")#');"  is_closed="1">
                    <div id="list_ships1_menu2" class="color-row" style="display:none">
                        <div align="left" id="LIST_SHIPS"></div><!--- irsaliyeler --->
                    </div>   
                </tr>
                <tr>
                    <cf_seperator title="#getLang('','Alış','58176')# #getLang('','İrsaliye','57773')#"id="list_ships1_menu2_purchase" onClick_function="connectAjax('LIST_SHIPS_PURCHASE','#action_dsn2#','#ListFirst(attributes.action_period_year,";")#')"  is_closed="1">
                    <div id="list_ships1_menu2_purchase" class="color-row" style="display:none">
                        <div align="left" id="LIST_SHIPS_PURCHASE"></div><!--- irsaliyeler --->
                    </div>
                </tr>
            </cfif>
            <cfif xml_is_show_sales_invoice>
                <tr>
                    <cf_seperator title="#getLang('','Satış','57448')# #getLang('','Fatura','57441')#"id="list_relational_invoice1_menu2_sales" onClick_function=" connectAjax('LIST_INVOICE_EXPENSE_SALES','#action_dsn2#','#ListFirst(attributes.action_period_year,";")#','');"  is_closed="1">
                   
               
                    <div id="list_relational_invoice1_menu2_sales" class="color-row" style="display:none">
                        <div align="left" id="LIST_INVOICE_EXPENSE_SALES"></div><!--- ilgili satış faturalar --->
                    </div>
                </tr>
            </cfif>
            <cfif xml_is_show_purchase_invoice>
                <tr>
                    <cf_seperator title="#getLang('','Alış','58176')# #getLang('','Fatura','57441')#"id="list_relational_invoice1_menu2_purchase" onClick_function=" connectAjax('LIST_INVOICE_EXPENSE_PURCHASE','#action_dsn2#','#ListFirst(attributes.action_period_year,";")#');"  is_closed="1">
               
                    <div id="list_relational_invoice1_menu2_purchase" class="color-row" style="display:none">
                        <div align="left" id="LIST_INVOICE_EXPENSE_PURCHASE"></div><!--- ilgili alış faturalar --->
                    </div>
                </tr>
            </cfif>
            <cfif xml_is_show_stock_in_from_customs>
                <tr>
                    <cf_seperator title="#getLang('','İthal Mal Girişleri','47132')# "id="list_upd_purchase1_menu2" onClick_function=" connectAjax('LIST_PURCHASE_IMP');"  is_closed="1">
                   
                
                        <div id="list_upd_purchase1_menu2" class="color-row" style="display:none">
                            <div align="left" id="LIST_PURCHASE_IMP"></div><!--- ithal mal girisi --->
                        </div>
                    </tr>

                   
            </cfif>
            <cfif xml_is_show_service>
                <tr>
                    <cf_seperator title="#getLang('','Servis Başvuruları','30039')# "id="list_project_service1_menu2" onClick_function="connectAjax('LIST_PROJECT_SERVICE');"  is_closed="1">
                   
                    <div id="list_project_service1_menu2" class="color-row" style="display:none">
                        <div align="left" id="LIST_PROJECT_SERVICE"></div><!--- servis basvurulari --->
                    </div>
                </tr>
            </cfif>
            <cfif xml_is_show_expense>
                <tr>
                    <cf_seperator title="#getLang('','Masraf Fişi','58064')# "id="list_project_expense" onClick_function="connectAjax('LIST_PROJECT_EXPENSE_DIV','#action_dsn2#','#ListFirst(attributes.action_period_year,";")#');"  is_closed="1">
                 
                    <div id="list_project_expense" class="color-row" style="display:none">
                        <div align="left" id="LIST_PROJECT_EXPENSE_DIV"></div><!--- masraflar --->
                    </div>
                </tr>
            </cfif>
                <tr>
                    <cf_seperator title="#getLang('','Sabit Kiymetler','58478')# "id="list_project_inventory" onClick_function="connectAjax('LIST_PROJECT_INVENTORY_DIV');"  is_closed="1">
                    <div id="list_project_inventory" class="color-row" style="display:none">
                        <div align="left" id="LIST_PROJECT_INVENTORY_DIV"></div><!--- sabit kiymetler --->
                    </div>
                </tr>
                <tr>  
                    <cf_seperator title="#getLang('','Call Center Başvuruları','58468')# "id="list_call_center_apps" onClick_function="connectAjax('call_center_apps_div');"  is_closed="1">
                    <div id="list_call_center_apps" class="color-row" style="display:none">
                        <div align="left" id="call_center_apps_div"></div><!---Call Center Başvuruları--->
                    </div>
                </tr>
        </table>
    </cfform>
</cf_box>