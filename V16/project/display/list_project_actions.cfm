<!--- isbu sayfa objects tarafindan da cagriliyor... dosyayi degistirirken bunu lutfen goz onune aliniz... xml e ekleme yaparsaniz objects teki xml ede ekleme yapiniz 28072010 ---> 
<cf_xml_page_edit fuseact="#fusebox.circuit#.popup_list_project_actions">
<cfif attributes.fuseaction contains 'product'>
    <cf_get_lang_set module_name="product">
    <cfparam name="attributes.from_paper" default="PRODUCT">
<cfelseif attributes.fuseaction contains 'project'>
    <cf_get_lang_set module_name="project">
    <cfparam name="attributes.from_paper" default="">
</cfif>
<cfparam  name="attributes.maxrows" default="20">

<cfparam name="attributes.action_status" default="">
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
			
			if (div_id == 'LIST_PRO_METERIAL')//malzeme ve ihtiyac plani
				var page = '#request.self#?fuseaction=project.popup_ajax_list_pro_material_paper&action_status='+action_status+'&from_paper='+from_paper+'&line_based='+line_based+'&id=#attributes.id#&xml_='+xml_;
             if (div_id == 'list_model_studies')//model calismalai
				var page = '#request.self#?fuseaction=project.list_model_studies&action_status='+action_status+'&from_paper='+from_paper+'&line_based='+line_based+'&id=#attributes.id#&xml_='+xml_;
            if (div_id == 'LIST_SALE_OPPORTUNITIES')//satis firsatlari
				var page = '#request.self#?fuseaction=project.popup_ajax_list_sale_opportunities&action_status='+action_status+'&id=#attributes.id#<cfif isdefined("attributes.is_from_product")>&is_from_product=#attributes.is_from_product#</cfif>';
			if (div_id == 'LIST_SALE_ORDER')//satis siparisleri
				var page = '#request.self#?fuseaction=project.popup_ajax_list_sale_orders&action_status='+action_status+'&from_paper='+from_paper+'&line_based='+line_based+'&id=#attributes.id#<cfif isdefined("attributes.is_from_product")>&is_from_product=#attributes.is_from_product#</cfif>&xml_='+xml_;
			if (div_id == 'LIST_PURCHASE_OFFER' || div_id == 'LIST_SALE_OFFER')	//satinalma teklifleri
			{
				if(div_id =='LIST_PURCHASE_OFFER') var purchase_sales = 0; else var purchase_sales = 1;
				var page = '#request.self#?fuseaction=project.popup_ajax_list_purchase_offers&action_status='+action_status+'&purchase_sales='+purchase_sales+'&from_paper='+from_paper+'&line_based='+line_based+'&id=#attributes.id#<cfif isdefined("attributes.is_from_product")>&is_from_product=#attributes.is_from_product#</cfif>';
			}
			if (div_id == 'LIST_PURCHASE_ORDER')//satinalma siparisleri
				var page = '#request.self#?fuseaction=project.popup_ajax_list_sale_orders&action_status='+action_status+'&from_paper='+from_paper+'&purchase_sales=0&line_based='+line_based+'&id=#attributes.id#<cfif isdefined("attributes.is_from_product")>&is_from_product=#attributes.is_from_product#</cfif>';
			if (div_id == 'LIST_INTERNALDEMANDS')//ic talepler
				var page = '#request.self#?fuseaction=project.popup_ajax_list_internaldemands&action_status='+action_status+'&id=#attributes.id#<cfif isdefined("attributes.is_from_product")>&is_from_product=#attributes.is_from_product#</cfif>&xml_is_show_internaldemands=#xml_is_show_internaldemands#&from_paper='+from_paper+'&line_based='+line_based+'';
			if (div_id == 'LIST_SHIPS' || div_id == 'LIST_SHIPS_PURCHASE')	//irsaliyeler
			{
				if(div_id =='LIST_SHIPS_PURCHASE') var purchase_sales = 0; else var purchase_sales = 1;
				var page = '#request.self#?fuseaction=project.popup_ajax_list_ships&action_status='+action_status+'&from_paper='+from_paper+'&line_based='+line_based+'&purchase_sales='+purchase_sales+'&id=#attributes.id#<cfif isdefined("attributes.is_from_product")>&is_from_product=#attributes.is_from_product#</cfif>&action_dsn2='+ data +'&period_id='+period_id;
			}	
			if (div_id == 'LIST_PURCHASE_IMP')//ithal mal girisi
				var page = '#request.self#?fuseaction=project.popup_ajax_list_purchase_import&action_status='+action_status+'&id=#attributes.id#<cfif isdefined("attributes.is_from_product")>&is_from_product=#attributes.is_from_product#</cfif>';
			if (div_id == 'LIST_INVOICE_EXPENSE_SALES' || div_id == 'LIST_INVOICE_EXPENSE_PURCHASE'){//ilgili alış satış faturalar
				if(div_id =='LIST_INVOICE_EXPENSE_PURCHASE') var purchase_sales = 0; else var purchase_sales = 1;
				if(line_based==1)//satır bazında ise..
					var page = '#request.self#?fuseaction=project.popup_add_sales_invoice_from_project&action_status='+action_status+'&from_paper='+from_paper+'&project_id=#attributes.id#<cfif isdefined("attributes.is_from_product")>&is_from_product=#attributes.is_from_product#</cfif>&purchase_sales='+purchase_sales+'&from_project_page=1&line_based='+line_based+'&action_dsn2='+ data+'&period_id='+period_id+'&xml_='+xml_;
				else
					var page = '#request.self#?fuseaction=project.popup_ajax_list_pro_invoice_expense&action_status='+action_status+'&purchase_sales='+purchase_sales+'&id=#attributes.id#<cfif isdefined("attributes.is_from_product")>&is_from_product=#attributes.is_from_product#</cfif>&action_dsn2='+ data+'&period_id='+period_id +'&line_based='+line_based+'&xml_='+xml_;
			}
			if (div_id == 'LIST_PRODUCTION_ORDERS')//uretim emri
				var page = '#request.self#?fuseaction=project.popup_ajax_list_production_orders&action_status='+action_status+'&from_paper='+from_paper+'&line_based='+line_based+'&id=#attributes.id#<cfif isdefined("attributes.is_from_product")>&is_from_product=#attributes.is_from_product#</cfif>';
			if (div_id == 'LIST_PRODUCTION_ORDERS_RESULT')//uretim sonucu
				var page = '#request.self#?fuseaction=project.popup_ajax_list_production_orders_result&action_status='+action_status+'&from_paper='+from_paper+'&line_based='+line_based+'&id=#attributes.id#<cfif isdefined("attributes.is_from_product")>&is_from_product=#attributes.is_from_product#</cfif>';
			if (div_id == 'LIST_PROJECT_SERVICE')//servis basvurlari//
				var page = '#request.self#?fuseaction=project.popup_ajax_list_project_service&action_status='+action_status+'&line_based='+line_based+'&from_paper='+from_paper+'&id=#attributes.id#<cfif isdefined("attributes.is_from_product")>&is_from_product=#attributes.is_from_product#</cfif>';
			if (div_id == 'LIST_PROJECT_PRODUCTION_OUTPUT_DIV')//üretimden çıkış//
				var page = '#request.self#?fuseaction=project.popup_ajax_list_project_production&action_status='+action_status+'&from_paper='+from_paper+'&line_based='+line_based+'&id=#attributes.id#<cfif isdefined("attributes.is_from_product")>&is_from_product=#attributes.is_from_product#</cfif>';
			if (div_id == 'LIST_PROJECT_SARF_DIV')//sarf//
				var page = '#request.self#?fuseaction=project.popup_ajax_list_project_sarf&action_status='+action_status+'&from_paper='+from_paper+'&line_based='+line_based+'&id=#attributes.id#<cfif isdefined("attributes.is_from_product")>&is_from_product=#attributes.is_from_product#</cfif>';
			if (div_id == 'LIST_PROJECT_EXPENSE_DIV')//mssraf fisi
				var page = '#request.self#?fuseaction=project.popup_ajax_list_project_expense&action_status='+action_status+'<cfif isdefined("attributes.is_from_product")>&is_from_product=#attributes.is_from_product#</cfif>&from_paper='+from_paper+'&action_dsn2='+ data+'&period_id='+period_id+'&line_based='+line_based+'&id=#attributes.id#&xml_='+xml_;
			if (div_id == 'LIST_PROJECT_INVENTORY_DIV')//sabit kiymetler
				var page = '#request.self#?fuseaction=project.popup_ajax_list_project_inventory&action_status='+action_status+'&id=#attributes.id#<cfif isdefined("attributes.is_from_product")>&is_from_product=#attributes.is_from_product#</cfif>';
			if(div_id == 'list_visit_div')//ziyaretler
				var page='#request.self#?fuseaction=project.popup_ajax_list_visit&action_status='+action_status+'&from_paper='+from_paper+'&line_based='+line_based+'&id=#attributes.id#';
			if(div_id == 'call_center_apps_div')//call center başvuruları
				var page='#request.self#?fuseaction=project.popup_ajax_project_call_service&action_status='+action_status+'&project_id=#attributes.id#';

            page = page + '&maxrows=' + $("##maxrows").val() + '&order_type=' + $("##order_type").val();

			AjaxPageLoad(page,''+div_id+'',1);
		}
	</cfoutput>
</script>
<cfparam name="attributes.action_period_year" default="#session.ep.period_id#;#session.ep.period_year#">
<cfquery name="get_period" datasource="#dsn#">
    SELECT PERIOD_ID, PERIOD_YEAR, OUR_COMPANY_ID FROM SETUP_PERIOD WHERE OUR_COMPANY_ID = #session.ep.company_id# ORDER BY PERIOD_YEAR DESC
</cfquery>

<cfif attributes.fuseaction contains 'product'>
	<cfset fuseact_ = 'product.list_product_actions&is_from_product=1'>
<cfelseif attributes.fuseaction contains 'project'>
	<cfset fuseact_ = 'project.popup_list_project_actions'>
</cfif>
<cfsavecontent  variable="head">
    <cfif isdefined("attributes.is_from_product")><!--- urunden geliyorsa --->
      <a href="<cfoutput>#request.self#?fuseaction=product.list_product&event=det&pid=#url.id#</cfoutput>" target="_blank"><cfoutput><cf_get_lang dictionary_id='57657.Ürün'> #get_product_name(attributes.id)#</cfoutput></a> 
    <cfelse>
        <a href="<cfoutput>#request.self#?fuseaction=project.projects&event=det&id=#url.id#</cfoutput>" target="_blank"><cfoutput><cf_get_lang dictionary_id='57416.Proje'>   #get_project_name(attributes.id)#</cfoutput></a> 
    </cfif>
</cfsavecontent>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box title="#head#" collapsable="0" popup_box="#iif(isdefined("attributes.draggable"),1,0)#">
        <cfform name="action_year_form" method="post" action="#request.self#?fuseaction=#fuseact_#&id=#URL.ID#">
            <cf_box_search more="0">
               
                <cfif xml_is_show_company_info>
                    <cfquery name="GET_PARTNER_INFO" datasource="#dsn#">
                        SELECT PARTNER_ID, CONSUMER_ID FROM PRO_PROJECTS WHERE PRO_PROJECTS.PROJECT_ID = #attributes.id#
                    </cfquery>
                    <cfif len(get_partner_info.partner_id)>
                        <div class="form-group"><label><cfoutput>#get_par_info(get_partner_info.partner_id,0,1,1)#</cfoutput></label></div>
                    <cfelseif len(get_partner_info.consumer_id)> 
                        <div class="form-group"><label><cfoutput>#get_cons_info(get_partner_info.consumer_id,0,1)#</cfoutput></label></div>
                    </cfif>
                </cfif>
                <div class="form-group">
                    <select name="order_type" id="order_type">
                        <option value = "date_desc"><cf_get_lang dictionary_id='47983.Tarihe Göre Azalan'></option>
                        <option value = "date_asc"><cf_get_lang dictionary_id='47978.Tarihe Göre Artan'></option>
                        <option value = "paperno_desc"><cf_get_lang dictionary_id='60613.Belge Noya Göre Azalan'></option>
                        <option value = "paperno_asc"><cf_get_lang dictionary_id='60612.Belge Noya Göre Artan'></option>
                    </select>
                </div>
               
                <div class="form-group">
                   <!---  <label> <cf_get_lang dictionary_id='30047.Mali Yıl'></label> --->
                    <select name="action_period_year" id="action_period_year" onchange="action_year_form.submit();">
                        <cfoutput query="GET_PERIOD">
                            <option value="#PERIOD_ID#;#PERIOD_YEAR#" <cfif ListLast(attributes.action_period_year,';') eq period_year>selected</cfif>>#PERIOD_YEAR#</option>
                        </cfoutput>
                    </select>
                </div>
                <div class="form-group">
                    <select name="action_status" id="action_status">
                        <option value="1" <cfif attributes.action_status eq 1>selected</cfif>><cf_get_lang dictionary_id='57493.Aktif'></option>
                        <option value="0" <cfif attributes.action_status eq 0>selected</cfif>><cf_get_lang dictionary_id='57494.Pasif'></option>
                        <option value="2" <cfif attributes.action_status eq 2>selected</cfif>><cf_get_lang dictionary_id='57708.Tümü'></option>
                    </select>
                </div>
                <div class="form-group small">
                    <cfsavecontent variable="message"><cf_get_lang dictionary_id='57537.Sayi_Hatasi_Mesaj'></cfsavecontent>
                    <cfinput type="text" name="maxrows" id="maxrows" maxlength="3" value="#attributes.maxrows#" validate="integer" range="1,250" required="yes" onKeyUp="isNumber(this)" message="#message#">
                </div>
                <div class="form-group">
                    <label> <input type="checkbox" name="line_based" id="line_based" <cfif (isdefined('attributes.from_paper') and len(attributes.from_paper)) or xml_select_line_based eq 1>checked</cfif>><cf_get_lang dictionary_id='29539.Satır Bazında'></label>
                    <!--- <cfelseif not len(attributes.from_paper)>disabled kaldirildi, fat,sip,irs,tekl belgeleri gibi bir yerden çağırılıyorsa.. --->
                </div>
                <cf_get_lang_set module_name="project">
                    <cfif  not listfindnocase(denied_pages,'sales.form_add_order')>
                        <div class="form-group">
                            <a href="<cfoutput>#request.self#?fuseaction=sales.list_order&event=add<cfif not isdefined("attributes.is_from_product")>&from_project_material=#URL.ID#</cfif></cfoutput>" target="_blank"><img src="css/assets/icons/catalyst-icon-svg/ctl-delivery-truck.svg"   title="<cf_get_lang dictionary_id='38170.Sipariş Al'>" border="0" width="20px"></a>
                        </div>
                        <div class="form-group">
                            <a href="<cfoutput>#request.self#?fuseaction=sales.list_offer&event=add<cfif not isdefined("attributes.is_from_product")>&project_id=#URL.ID#</cfif></cfoutput>" target="_blank"><img src="css/assets/icons/catalyst-icon-svg/ctl-contract.svg"  width="20px" title="<cf_get_lang dictionary_id='38171.Teklif Ver'>" border="0"></a>
                        </div>
                    </cfif>
                    <cfif  not listfindnocase(denied_pages,'purchase.form_add_order')>
                        <div class="form-group">
                            <a href="<cfoutput>#request.self#?fuseaction=purchase.list_order&event=add<cfif not isdefined("attributes.is_from_product")>&from_project_material=#URL.ID#</cfif></cfoutput>" target="_blank"><img src="css/assets/icons/catalyst-icon-svg/ctl-007-truck.svg"  title="<cf_get_lang dictionary_id='38168.Sipariş Ver'>" border="0" width="20px"></a> 
                        </div>
                        <div class="form-group">
                            <a href="<cfoutput>#request.self#?fuseaction=purchase.list_offer&event=add<cfif not isdefined("attributes.is_from_product")>&project_id=#url.id#</cfif></cfoutput>" target="_blank"><img src="css/assets/icons/catalyst-icon-svg/ctl-check-mark.svg"  width="20px"  title="<cf_get_lang dictionary_id='38169.Teklif Al'>" border="0"></a>
                        </div>
                    </cfif>
                    <cfif  not listfindnocase(denied_pages,'prod.add_prod_order')>
                        <div class="form-group">
                            <a href="<cfoutput>#request.self#?fuseaction=prod.order&event=add<cfif not isdefined("attributes.is_from_product")>&pj_id=#URL.ID#</cfif></cfoutput>" target="_blank"><img src="css/assets/icons/catalyst-icon-svg/ctl-044-gear.svg"  width="20px" title="<cf_get_lang dictionary_id='49884.Üretim Emri'>" border="0"></a>
                        </div>
                    </cfif>
                <cf_get_lang_set module_name="#lcase(listgetat(attributes.fuseaction,1,'.'))#">
            </cf_box_search>    
                <cfset action_dsn2 = '#dsn#_#ListLast(attributes.action_period_year,";")#_#get_period.OUR_COMPANY_ID#'>
                <cfif not isdefined("attributes.is_from_product")><!--- urunden geliyorsa bu kismi gosterme --->
                    <cfif xml_is_show_material>
                        <cfsavecontent  variable="head_"><cf_get_lang dictionary_id='38293.Malzeme Ve İhtiyaç Planları'></cfsavecontent>
                        <cf_seperator title="#head_#" id="list_correspondence1_menu2" onClick_function="connectAjax('LIST_PRO_METERIAL','','','#xml_show_zero_row#;#xml_use_remaining_amount#');"  is_closed="1">
                        <div id="list_correspondence1_menu2"  style="display:none">
                            <div id="LIST_PRO_METERIAL"></div><!--- malzeme ve ihtiyac plani --->
                        </div>
                    </cfif>
                </cfif>
                <cfif isDefined('xml_is_show_project') And xml_is_show_project>
                    <cfsavecontent  variable="head_"><cf_get_lang dictionary_id='65893.Model Çalışmaları'></cfsavecontent>
                    <cf_seperator title="#head_#" id="list_model_studies_menu" onClick_function="connectAjax('list_model_studies','','','#xml_show_zero_row#;#xml_use_remaining_amount#');"  is_closed="1">
                    <div id="list_model_studies_menu"  style="display:none">
                        <div id="list_model_studies"></div><!--- Model Çalışmaları --->
                    </div>
                </cfif>
                <cfif xml_is_show_sales_offer>
                    <cfsavecontent  variable="head_"><cf_get_lang dictionary_id='58694.Fırsatlar'></cfsavecontent>
                    <cf_seperator title="#head_#" id="list_sale_opportunities1_menu2" onClick_function="connectAjax('LIST_SALE_OPPORTUNITIES');"  is_closed="1">
                    <div id="list_sale_opportunities1_menu2" style="display:none">
                        <div id="LIST_SALE_OPPORTUNITIES"></div><!--- satis firsatlari --->
                    </div>
                   
                </cfif>
                <cfif xml_is_show_internaldemands>
                    <cfsavecontent  variable="head_"><cf_get_lang dictionary_id='58798.İç Talep'></cfsavecontent>
                    <cf_seperator title="#head_#" id="list_internaldemands_menu2" onClick_function="connectAjax('LIST_INTERNALDEMANDS');"  is_closed="1">
                    <div id="list_internaldemands_menu2" style="display:none">
                        <div id="LIST_INTERNALDEMANDS"></div><!--- ic talepler --->
                    </div>
                </cfif>
                <cfif xml_is_show_sales_offer>
                    <cfsavecontent  variable="head_"><cf_get_lang dictionary_id='30007.Satış Teklifleri'></cfsavecontent>
                    <cf_seperator title="#head_#" id="list_sale_offer1_menu2" onClick_function="connectAjax('LIST_SALE_OFFER');"  is_closed="1">
                    <div id="list_sale_offer1_menu2" style="display:none">
                        <div id="LIST_SALE_OFFER"></div><!--- satis teklifleri --->
                    </div>
                </cfif>
                <cfif xml_is_show_purchase_offer>
                    <cfsavecontent  variable="head_"><cf_get_lang dictionary_id='30048.Satınalma Teklifleri'></cfsavecontent>
                    <cf_seperator title="#head_#" id="list_purchase_offers1_menu2" onClick_function="connectAjax('LIST_PURCHASE_OFFER');"  is_closed="1">
                    <div id="list_purchase_offers1_menu2" style="display:none">
                        <div id="LIST_PURCHASE_OFFER"></div><!--- satinalma teklifleri --->
                    </div>
                </cfif>
                <cfif xml_is_show_sales_order>
                    <cfsavecontent  variable="head_"><cf_get_lang dictionary_id='58207.Satış Siparişleri'></cfsavecontent>
                    <cf_seperator title="#head_#" id="list_sale_orders1_menu2" onClick_function="connectAjax('LIST_SALE_ORDER');"  is_closed="1">
                    <div id="list_sale_orders1_menu2" style="display:none">
                        <div id="LIST_SALE_ORDER"></div><!--- satis siparisleri --->
                    </div>
                </cfif>
                <cfif xml_is_show_purchase_order>
                    <cfsavecontent  variable="head_"><cf_get_lang dictionary_id='30008.Satınalma Siparişleri'></cfsavecontent>
                    <cf_seperator title="#head_#" id="list_purchase_orders1_menu2" onClick_function="connectAjax('LIST_PURCHASE_ORDER');"  is_closed="1">
                    <div id="list_purchase_orders1_menu2" style="display:none">
                        <div id="LIST_PURCHASE_ORDER"></div><!--- satinalma siparisleri --->
                    </div>
                </cfif>
                <cfif xml_is_show_ships>
                    <cfsavecontent  variable="head_"><cf_get_lang dictionary_id='57448.Satış'> <cf_get_lang dictionary_id='57773.İrsaliye'></cfsavecontent>
                    <cf_seperator title="#head_#" id="list_ships1_menu2" onClick_function="connectAjax('LIST_SHIPS','#action_dsn2#','#ListFirst(attributes.action_period_year,";")#');"  is_closed="1">
                    <div id="list_ships1_menu2" style="display:none">
                        <div id="LIST_SHIPS"></div><!--- irsaliyeler --->
                    </div>

                    <cfsavecontent  variable="head_"><cf_get_lang dictionary_id='58176.Alış'><cf_get_lang dictionary_id='57773.İrsaliye'></cfsavecontent>
                    <cf_seperator title="#head_#" id="list_ships1_menu2_purchase" onClick_function="connectAjax('LIST_SHIPS_PURCHASE','#action_dsn2#','#ListFirst(attributes.action_period_year,";")#');"  is_closed="1">
                    <div id="list_ships1_menu2_purchase" style="display:none">
                        <div id="LIST_SHIPS_PURCHASE"></div><!--- irsaliyeler --->
                    </div>
                </cfif>
                <cfif xml_is_show_sales_invoice>
                    <cfsavecontent  variable="head_"><cf_get_lang dictionary_id='57448.Satış'><cf_get_lang dictionary_id='57441.Fatura'></cfsavecontent>
                    <cf_seperator title="#head_#" id="list_relational_invoice1_menu2_sales" onClick_function="connectAjax('LIST_INVOICE_EXPENSE_SALES','#action_dsn2#','#ListFirst(attributes.action_period_year,";")#','#xml_show_zero_row#;#xml_use_remaining_amount#');"  is_closed="1">    
                    <div id="list_relational_invoice1_menu2_sales" style="display:none">
                        <div id="LIST_INVOICE_EXPENSE_SALES"></div><!--- ilgili satış faturalar --->
                    </div>
                </cfif>
                <cfif xml_is_show_purchase_invoice>
                    <cfsavecontent  variable="head_"><cf_get_lang dictionary_id='58176.Alış'><cf_get_lang dictionary_id='57441.Fatura'></cfsavecontent>
                    <cf_seperator title="#head_#" id="list_relational_invoice1_menu2_purchase" onClick_function="connectAjax('LIST_INVOICE_EXPENSE_PURCHASE','#action_dsn2#','#ListFirst(attributes.action_period_year,";")#');"  is_closed="1">    
                    <div id="list_relational_invoice1_menu2_purchase" style="display:none">
                        <div id="LIST_INVOICE_EXPENSE_PURCHASE"></div><!--- ilgili alış faturalar --->
                    </div>
                </cfif>
                <cfif xml_is_show_stock_in_from_customs>
                    <cfsavecontent  variable="head_"><cf_get_lang dictionary_id='29588.İthal Mal Girişleri'></cfsavecontent>
                    <cf_seperator title="#head_#" id="list_upd_purchase1_menu2" onClick_function="connectAjax('LIST_PURCHASE_IMP');" is_closed="1">    
                    <div id="list_upd_purchase1_menu2" style="display:none">
                        <div id="LIST_PURCHASE_IMP"></div><!--- ithal mal girisi --->
                    </div>
                </cfif>
                <cfif xml_is_show_production_order>
                    <cfsavecontent  variable="head_"><cf_get_lang dictionary_id='49884.Üretim Emri'></cfsavecontent>
                    <cf_seperator title="#head_#" id="list_production_orders1_menu2" onClick_function="connectAjax('LIST_PRODUCTION_ORDERS');" is_closed="1"> 
                    <div id="list_production_orders1_menu2" style="display:none">
                        <div id="LIST_PRODUCTION_ORDERS"></div><!--- uretim emirleri --->
                    </div>
                </cfif>
                <cfif xml_is_show_production_order>
                    <cfsavecontent  variable="head_"><cf_get_lang dictionary_id='29651.Üretim Sonucu'></cfsavecontent>
                    <cf_seperator title="#head_#" id="list_production_orders_result_1_menu2" onClick_function="connectAjax('LIST_PRODUCTION_ORDERS_RESULT');" is_closed="1"> 
                    <div id="list_production_orders_result_1_menu2" style="display:none">
                        <div id="LIST_PRODUCTION_ORDERS_RESULT"></div><!--- uretim sonuçları --->
                    </div>
                </cfif>
                <cfif xml_is_show_service>
                    <cfsavecontent  variable="head_"><cf_get_lang dictionary_id='30039.Servis Başvuruları'></cfsavecontent>
                    <cf_seperator title="#head_#" id="list_project_service1_menu2" onClick_function="connectAjax('LIST_PROJECT_SERVICE');" is_closed="1"> 
                    <div id="list_project_service1_menu2" style="display:none">
                        <div id="LIST_PROJECT_SERVICE"></div><!--- servis basvurulari --->
                    </div>
                </cfif>
                <cfif xml_is_show_production>
                    <cfsavecontent  variable="head_"><cf_get_lang dictionary_id='36835.Üretimden Çıkış'></cfsavecontent>
                    <cf_seperator title="#head_#" id="list_project_production_output" onClick_function="connectAjax('LIST_PROJECT_PRODUCTION_OUTPUT_DIV');" is_closed="1"> 
                    <div id="list_project_production_output" style="display:none">
                        <div id="LIST_PROJECT_PRODUCTION_OUTPUT_DIV"></div>
                    </div>
                </cfif>
                <cfif xml_is_show_sarf>
                    <cfsavecontent  variable="head_"><cf_get_lang dictionary_id='30009.Sarflar'></cfsavecontent>
                    <cf_seperator title="#head_#" id="list_project_sarf" onClick_function="connectAjax('LIST_PROJECT_SARF_DIV');" is_closed="1"> 
                    <div id="list_project_sarf" style="display:none">
                        <div id="LIST_PROJECT_SARF_DIV"></div><!--- servis basvurulari --->
                    </div>
                </cfif>
                <cfif xml_is_show_expense>
                    <cfsavecontent  variable="head_"><cf_get_lang dictionary_id='58064.Masraf Fişi'></cfsavecontent>
                    <cf_seperator title="#head_#" id="list_project_expense" onClick_function="connectAjax('LIST_PROJECT_EXPENSE_DIV','#action_dsn2#','#ListFirst(attributes.action_period_year,";")#','#xml_show_zero_row#;#xml_use_remaining_amount#');" is_closed="1"> 
                    <div id="list_project_expense" style="display:none">
                        <div id="LIST_PROJECT_EXPENSE_DIV"></div><!--- masraflar --->
                    </div>
                </cfif>
                <cfif isdefined("xml_is_show_inventory") and  xml_is_show_inventory>
                    <cfsavecontent  variable="head_"><cf_get_lang dictionary_id='57531.Sabit Kiymetler'></cfsavecontent>
                    <cf_seperator title="#head_#" id="list_project_inventory" onClick_function="connectAjax('LIST_PROJECT_INVENTORY_DIV');" is_closed="1"> 
                    <div id="list_project_inventory" style="display:none">
                        <div id="LIST_PROJECT_INVENTORY_DIV"></div><!--- sabit kiymetler --->
                    </div>
                </cfif>
                <cfif not isdefined("attributes.is_from_product")><!--- urunden geliyorsa bu kismi gosterme --->
                    <cfsavecontent  variable="head_"><cf_get_lang dictionary_id='57970.Ziyaretler'></cfsavecontent>
                    <cf_seperator title="#head_#" id="list_visit" onClick_function="connectAjax('list_visit_div');" is_closed="1"> 
                    <div id="list_visit" style="display:none">
                        <div id="list_visit_div"></div><!---İlişkili Ziyaretler--->
                    </div>
                    <cfif isdefined('xml_callcenter_apps') and xml_callcenter_apps>
                        <cfsavecontent  variable="head_"><cf_get_lang dictionary_id='58468.Call Center Başvuruları'></cfsavecontent>
                        <cf_seperator title="#head_#" id="list_call_center_apps" onClick_function="connectAjax('call_center_apps_div');" is_closed="1"> 
                        <div id="list_call_center_apps" style="display:none">
                            <div id="call_center_apps_div"></div><!---Call Center Başvuruları--->
                        </div>
                    </cfif>
                </cfif>
        </cfform>
    </cf_box>
</div>

