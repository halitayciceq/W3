<cf_xml_page_edit fuseact="sales.add_fast_sale">
<cfinclude template="../../invoice/query/control_bill_no.cfm">
<cf_get_lang_set module_name="sales">
	
<cfscript>
	if (isdefined("url.company_id") and len(url.company_id)){
		attributes.comp_id = url.company_id;
	}
	else if(isdefined("url.consumer_id") and len(url.consumer_id)){
		attributes.cons_id = url.consumer_id;
	}
	session_basket_kur_ekle(process_type:0);
</cfscript>
<cfparam name="attributes.deliver_dept_name" default="">
<cfparam name="attributes.deliver_dept_id" default="">
<cfparam name="attributes.deliver_loc_id" default="">
<cfparam name="attributes.branch_id" default="">
<cfif isDefined("attributes.offer_id") and Len(attributes.offer_id)>
	<!--- Satis Tekliften donusturulen sipariste, carinin tekliften alinmasi icin eklendi FS 20110120 --->
	
	<cfinclude template="../query/get_offer.cfm">
	<cfset attributes.consumer_id = GET_OFFER.consumer_id>
	<cfset attributes.company_id = GET_OFFER.company_id>
	<cfset attributes.partner_id = GET_OFFER.partner_id>
	<cfset attributes.project_id = GET_OFFER.project_id>
	<cfset attributes.ship_method_id = GET_OFFER.ship_method>
	<cfset attributes.card_paymethod_id = GET_OFFER.card_paymethod_id>
	<cfset attributes.paymethod_id = GET_OFFER.paymethod>
	<cfset attributes.deliverdate = GET_OFFER.deliverdate>
	<cfset attributes.ship_address_city_id = GET_OFFER.city_id>
	<cfset attributes.ship_address_county_id = GET_OFFER.county_id>
	<cfset attributes.ship_address = GET_OFFER.ship_address>
</cfif>
<cf_catalystHeader>
<cf_box>
	<div id="basket_main_div">
		<cfform name="form_basket" method="post" action="#request.self#?fuseaction=#listgetat(attributes.fuseaction,1,'.')#.emptypopup_add_fast_sale">
			<div basket_header class="row">
				<div class="col col-12 uniqueRow">
					<cf_basket_form id="add_fast_sale">
						<input type="hidden" name="form_action_address" id="form_action_address" value="<cfoutput>#listgetat(attributes.fuseaction,1,'.')#.emptypopup_add_fast_sale</cfoutput>">
						<input type="hidden" name="x_required_dep" id="x_required_dep" value="<cfoutput>#x_required_dep#</cfoutput>" />
						<input type="hidden" name="x_debtor_name" id="x_debtor_name" value="<cfoutput>#x_debtor_name#</cfoutput>" />
						<input type="hidden" name="is_run_voucher_function" id="is_run_voucher_function" value="1">
						<cfset attributes.basket_id = 51>
						<div id="tab-container" class="tabStandart margin-top-5">
							<div id="tab-head">
								<ul class="tabNav">
									<li class="active"><a href="#minfo"><cf_get_lang dictionary_id='52125.Müşteri Bilgisi'></a></li>
									<li class=""><a href="#siparis"><cf_get_lang dictionary_id='57611.Sipariş'></a></li>								
									<li class=""><a href="#odeme"><cf_get_lang dictionary_id='57847.Ödeme'></a></li>
									<li class=""><a href="#kefil"><cfoutput>#getLang('main','kefil',58626)# #getLang('main','ve',57989)# #getLang('main','risk',57689)#</cfoutput></a></li>	
								</ul>
							</div>
							
							<div style="clear:both;"></div>
							<div id="tab-content" class="margin-top-10"> 
									<div id="minfo" class="content row">												
										<!--- Üye Bilgileri --->
										<!---<cf_basket_form>--->
											<cfinclude template="../display/add_fast_sale_member.cfm">
										<!---</cf_basket_form>	--->			
									</div>				
									<div id="kefil" class="content row">  
										<!--- Risk ve Kefiller --->	
										<cfinclude template="../display/add_fast_sale_quarantor.cfm"><!--- Kefiller --->
										<cfinclude template="../../objects/display/display_member_risk.cfm"><!--- Risk --->
										<div class="col col-12 ui-form-list-btn padding-0">
											<div>
												<cf_workcube_buttons is_upd='0' is_cancel='0' insert_info='#getLang('','Sipariş Kaydet',41199)#' add_function='kontrol_form()'>
											</div>
										</div>  						
									</div>								
									<div id="odeme" class="content row"> 
										<!--- Peşinatlar --->
										<div>
											<cfinclude template="../display/add_fast_sale_payment.cfm">
											<!--- Taksitler --->
											<div class="col col-6">
												<cfinclude template="../display/add_fast_sale_voucher.cfm">
												<cfinclude template="../display/add_fast_sale_cheque.cfm">
											</div>    
											<div class="col col-12 ui-form-list-btn padding-0">
												<div>
													<cf_workcube_buttons is_upd='0' is_cancel='0' insert_info='#getLang('','Sipariş Kaydet',41199)#' add_function='kontrol_form()'>
												</div>
											</div>                
										</div>
									</div>
									<!--- Basket --->
									<div id="siparis" class="content row" style="display:none;">
										<cf_box_elements>
											<div class="col col-4 col-md-4 col-sm-6 col-xs-12" type="column" index="4" sort="true">
												<div class="form-group" id="item-reserved">
													<label class="col col-12">
														<input type="checkbox" name="reserved" id="reserved" value="1" tabindex="27" <cfif (isdefined("attributes.reserved") and attributes.reserved eq 1) or not isdefined('attributes.reserved')>checked</cfif> onclick="check_reserved_rows();"><cf_get_lang dictionary_id ='41185.Stok Rezerve Et'>
													</label>
												</div>
												<div class="form-group" id="item-process">
													<label for="" class="col col-4 col-xs-12"><cf_get_lang dictionary_id ='58859.Süreç'></label>
													<div class="col col-8 col-xs-12">
														<cf_workcube_process is_upd='0' process_cat_width='120' is_detail='0'>
													</div>
												</div>
												<div class="form-group" id="item-order_date">
													<label for="" class="col col-4 col-xs-12"><cf_get_lang dictionary_id='29501.Sipariş Tarihi'></label>
													<div class="col col-8 col-xs-12">
														<cfif isdefined("is_readonly_orderdate") and is_readonly_orderdate neq 1><div class="input-group"></cfif>
															<input type="text" name="order_date" id="order_date" <cfif isdefined("is_readonly_orderdate") and is_readonly_orderdate eq 1>readonly</cfif> tabindex="24" value="<cfoutput>#dateformat(now(),dateformat_style)#</cfoutput>" validate="#validate_style#" maxlength="10">
															<cfif isdefined("is_readonly_orderdate") and is_readonly_orderdate neq 1><span class="input-group-addon btnPointer"><cf_wrk_date_image date_field="order_date" call_function="change_money_info"></span></cfif>
														<cfif isdefined("is_readonly_orderdate") and is_readonly_orderdate neq 1></div></cfif>
													</div>
												</div>
												<div class="form-group" id="item-order_employee">
													<label for="" class="col col-4 col-xs-12"><cf_get_lang dictionary_id ='40903.Satış Yapan'></label>
													<div class="col col-8 col-xs-12">
														<div class="input-group">
															<input type="hidden" name="order_employee_id" id="order_employee_id" value="<cfoutput>#session.ep.userid#</cfoutput>">
															<input type="text" name="order_employee" id="order_employee" value="<cfoutput>#get_emp_info(session.ep.userid,0,0)#</cfoutput>" onfocus="AutoComplete_Create('order_employee','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','3','EMPLOYEE_ID','order_employee_id','','3','120');" tabindex="22">
															<span class="input-group-addon icon-ellipsis btnPointer" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_list_positions&field_name=form_basket.order_employee&field_emp_id=form_basket.order_employee_id<cfif session.ep.isBranchAuthorization>&is_store_module=1</cfif>&select_list=1</cfoutput>');"></span>
														</div>
													</div>
												</div>	
												<div class="form-group" id="item-project_head">
													<labe class="col col-4 col-xs-12"><cf_get_lang dictionary_id ='57416.Proje'></labe>
													<div class="col col-8 col-xs-12">
														<div class="input-group">
															<input type="hidden" name="project_id" id="project_id" value="<cfif isDefined("attributes.project_id") and Len(attributes.project_id)><cfoutput>#attributes.project_id#</cfoutput></cfif>">
															<input type="text" name="project_head" id="project_head" value="<cfif isDefined("attributes.project_id") and Len(attributes.project_id)><cfoutput>#get_project_name(attributes.project_id)#</cfoutput></cfif>" readonly tabindex="26">
															<span class="input-group-addon icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_projects&project_id=form_basket.project_id&project_head=form_basket.project_head');"></span>
														</div>
													</div>
												</div>
											</div>		
											<div class="col col-4 col-md-4 col-sm-6 col-xs-12" type="column" index="5" sort="true">
												<div class="form-group" id="item-deliver_dept_name_sale">
													<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='41184.Depo- Lokasyon'></label>
													<div class="col col-8 col-xs-12">
														<cf_wrkdepartmentlocation 
															returnInputValue="deliver_loc_id,deliver_dept_name,deliver_dept_id,branch_id"
															returnQueryValue="LOCATION_ID,LOCATION_NAME,DEPARTMENT_ID,BRANCH_ID"
															fieldName="deliver_dept_name"
															fieldid="deliver_loc_id"
															department_fldId="deliver_dept_id"
															branch_fldId="branch_id"
															branch_id="#attributes.branch_id#"
															department_id="#attributes.deliver_dept_id#"
															location_id="#attributes.deliver_loc_id#"
															location_name="#attributes.deliver_dept_name#"
															user_level_control="#session.ep.OUR_COMPANY_INFO.IS_LOCATION_FOLLOW#"
															xml_all_depo = "#IIf(isDefined("x_dsp_all_departmants") and x_dsp_all_departmants eq 1,'1',de('0'))#"
															width="135"
															is_branch=1>
													</div>
												</div>
												<div class="form-group" id="item-ship_method_name">
													<label for="" class="col col-4 col-xs-12"><cf_get_lang dictionary_id='29500.Sevk Yontemi'></label>
													<div class="col col-8 col-xs-12">
														<cfif isDefined("attributes.ship_method_id") and Len(attributes.ship_method_id)>
															<cfset attributes.ship_method=attributes.ship_method_id>
															<cfinclude template="../query/get_ship_method.cfm">
														</cfif>
														<div class="input-group">
															<input type="hidden" name="ship_method_id" id="ship_method_id" value="<cfif isDefined("attributes.ship_method_id") and Len(attributes.ship_method_id)><cfoutput>#attributes.ship_method_id#</cfoutput></cfif>">
															<input type="text" name="ship_method_name" id="ship_method_name" value="<cfif isDefined("attributes.ship_method_id") and Len(attributes.ship_method_id)><cfoutput>#get_ship_method.ship_method#</cfoutput></cfif>" tabindex="21">
															<span class="input-group-addon icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_ship_methods&field_name=ship_method_name&field_id=ship_method_id','','ui-draggable-box-small');"></span>
														</div>
													</div>
												</div>
												<div class="form-group" id="item-deliverdate">
													<label for="" class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57645.Teslim Tarihi'>*</label>
													<div class="col col-8 col-xs-12">
														<div class="input-group">
															<cfif not isDefined("attributes.deliverdate")><cfset attributes.deliverdate = now()></cfif>
															<cfinput type="text" name="deliverdate" value="#dateformat(attributes.deliverdate,dateformat_style)#" validate="#validate_style#" maxlength="10" tabindex="23">
															<span class="input-group-addon btnPointer"><cf_wrk_date_image date_field="deliverdate"></span>
														</div>
													</div>
												</div>		
												<div class="form-group" id="item-ship_address">
													<label for="" class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58449.Teslim Yeri'></label>
													<div class="col col-8 col-xs-12">
														<cfoutput>
															<div class="input-group">
																<input type="hidden" name="ship_address_city_id" id="ship_address_city_id" value="<cfif isDefined('attributes.ship_address_city_id') and Len(attributes.ship_address_city_id)>#attributes.ship_address_city_id#</cfif>">
																<input type="hidden" name="ship_address_county_id" id="ship_address_county_id" value="<cfif isDefined('attributes.ship_address_county_id') and Len(attributes.ship_address_county_id)>#attributes.ship_address_county_id#</cfif>">
																<input type="text" name="ship_address" id="ship_address" maxlength="200" value="<cfif isDefined('attributes.ship_address') and Len(attributes.ship_address)>#attributes.ship_address#</cfif>" tabindex="25">
																<span class="input-group-addon icon-ellipsis" onclick="add_adress();"></span>	
															</div>
														</cfoutput>
													</div>
												</div>
												<div class="form-group" id="item-paymethod">
													<label for="" class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58516.Ödeme Yöntemi'>/<cf_get_lang dictionary_id ='57640.Vade'></label>
													<div class="col col-4 col-xs-12">			
														<cfif isDefined("attributes.paymethod_id") and Len(attributes.paymethod_id)>
															<cfinclude template="../query/get_paymethod.cfm">
															<cfset card_paymethod_id = "">
															<cfset commission_rate = "">
															<cfset paymethod_id = attributes.paymethod_id>
															<cfset paymethod_vehicle = get_paymethod.payment_vehicle>
															<cfset paymethod = get_paymethod.paymethod>
															<cfset basket_due_value = get_paymethod.due_day>
														<cfelseif isDefined("attributes.card_paymethod_id") and Len(attributes.card_paymethod_id)>
															<cfset card_pay_id = attributes.card_paymethod_id>
															<cfinclude template="../query/get_card_paymethod.cfm">
															<cfset card_paymethod_id = attributes.card_paymethod_id>
															<cfset commission_rate = get_card_paymethod.commission_multiplier>
															<cfset paymethod_id = "">
															<cfset paymethod_vehicle = -1>
															<cfset paymethod = get_card_paymethod.card_no>
															<cfset basket_due_value = "">
														<cfelse>
															<cfset card_paymethod_id = "">
															<cfset commission_rate = "">
															<cfset paymethod_id = "">
															<cfset paymethod_vehicle = "">
															<cfset paymethod = "">
															<cfset basket_due_value = "">
														</cfif>
														<cfoutput>
															<input type="hidden" name="paymethod_vehicle" id="paymethod_vehicle" value="#paymethod_vehicle#">
															<input type="hidden" name="card_paymethod_id" id="card_paymethod_id" value="#card_paymethod_id#">
															<input type="hidden" name="commission_rate" id="commission_rate" value="#commission_rate#">
															<input type="hidden" name="paymethod_id" id="paymethod_id" value="#paymethod_id#">
															<input type="text" name="paymethod" id="paymethod" value="#paymethod#" readonly tabindex="19">
														</cfoutput>		
													</div>
													<div class="col col-4 col-xs-12">
														<div class="input-group">
															<cfoutput>
																<input name="basket_due_value" id="basket_due_value" type="text" value="#basket_due_value#" readonly tabindex="20">
																<cfset card_link="&field_card_payment_id=form_basket.card_paymethod_id&field_card_payment_name=form_basket.paymethod&field_commission_rate=form_basket.commission_rate&field_paymethod_vehicle=form_basket.paymethod_vehicle">
																<span class="input-group-addon icon-ellipsis" onclick="pencere_ac_paymethod();"></span>
															</cfoutput>	
														</div>
													</div>
												</div>			
											</div>
											<div class="col col-4 col-md-4 col-sm-6 col-xs-12" type="column" index="6" sort="true">
												<div class="form-group" id="item-order_detail">
													<label for="" class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57629.Açıklama'></label>
													<div class="col col-8 col-xs-12">
														<textarea style="width:140px;height:45px;" name="order_detail" id="order_detail" rows="3"></textarea>
													</div>
												</div>
												<cfif is_ims_code eq 1>
													<div class="form-group" id="item-ims_code_name">
														<label for="" class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58134.Mikro Bölge Kodu'></label>
														<div class="col col-8 col-xs-12">
															<cfif len(member_ims_code_id)>
																<cfquery name="get_ims" datasource="#dsn#">
																	SELECT 
																		IMS_CODE_ID, 
																		IMS_CODE, 
																		IMS_CODE_NAME, 
																		IMS_CODE_DESC, 
																		RECORD_DATE, 
																		RECORD_EMP, 
																		RECORD_IP, 
																		UPDATE_DATE, 
																		UPDATE_EMP, 
																		UPDATE_IP 
																	FROM 
																		SETUP_IMS_CODE 
																	WHERE 
																		IMS_CODE_ID = #member_ims_code_id#
																</cfquery>
															</cfif>
															<div class="input-group">
																<input type="hidden" name="ims_code_id" id ="ims_code_id" value="<cfif len(member_ims_code_id)><cfoutput>#member_ims_code_id#</cfoutput></cfif>">
																<input type="text" name="ims_code_name" id="ims_code_name" value="<cfif len(member_ims_code_id)><cfoutput>#get_ims.ims_code_name#</cfoutput></cfif>" tabindex="44" onfocus="AutoComplete_Create('ims_code_name','IMS_CODE,IMS_CODE_NAME','IMS_NAME','get_ims_code','\'1,2\'','IMS_CODE_ID','ims_code_id','form_basket','1');" autocomplete="off">
																<span class="input-group-addon icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_ims_code&field_name=form_basket.ims_code_name&field_id=form_basket.ims_code_id&select_list=1','','ui-draggable-box-small');return false"></span>
															</div>					 
														</div>
													</div>
												</cfif>
											</div>
										</cf_box_elements>	
										<div id="basket_fast" class="content" data-tab="siparis">
											<cfif not isDefined("attributes.offer_id")>
												<cfset attributes.form_add = 1>
											</cfif>
											<div class="col col-12 ui-form-list-btn padding-0">
												<div>
													<cf_workcube_buttons is_upd='0' is_cancel='0' insert_info='#getLang('','Sipariş Kaydet',41199)#' add_function='kontrol_form()'>
												</div>
											</div>  
											<cfinclude template="../../objects/display/basket.cfm">				
										</div>			
									</div>
							</div>
						</div>	
					</cf_basket_form>
				</div>
			</div> 
		</cfform>
	</div>
</cf_box>
<script type="text/javascript">
	function kontrol_form()
	{
		if (form_basket.order_date.value == '')
		{
			alert("Sipariş Tarihi Girmelisiniz!");
			return false;
		}
		<cfif is_required_project eq 1>
			if (form_basket.project_head.value.length ==0)
			{
				alert("<cf_get_lang dictionary_id ='57471.Eksik Veri'> : <cf_get_lang dictionary_id ='57416.proje'> ");
				return false;
			}
		</cfif>
		if (form_basket.deliverdate.value.length == 0)
		{
			alert("<cf_get_lang dictionary_id='40987.Teslim Tarihi Girmelisiniz'> !");
			return false;
		}	
		if (!date_check(form_basket.order_date,form_basket.deliverdate,"Sipariş Teslim Tarihi, Sipariş Tarihinden Önce Olamaz !"))
			return false;
			
		if(document.getElementById('consumer_id').value != '' && form_basket.tc_num.value=="")
		{
			alert("<cf_get_lang dictionary_id ='41243.Bireysel Müşteri İçin TC Kimlik No Bilgisini Giriniz'>!");
			return false;
		}
		if(form_basket.record_num_3.value > 0 || form_basket.record_num_4.value > 0)
		{
			if(document.all.kontrol_cash.value == 0)
			{
				alert("<cf_get_lang dictionary_id ='57471.Eksik Veri'>: <cf_get_lang dictionary_id ='57520.Kasa'> <cfoutput>#session.ep.money#</cfoutput> !");
				return false;
			}
		}
		if(form_basket.total_cash_amount.value == '')form_basket.total_cash_amount.value= 0;
		toplam_pesin_tutar = parseFloat(filterNum(form_basket.total_cash_amount.value));
		toplam_fatura_tutar = wrk_round(form_basket.basket_net_total.value,2);
		toplam_senet_tutar = parseFloat(filterNum(form_basket.total_voucher_value.value));
		toplam_h_senet_tutar = filterNum(form_basket.total_voucher_value.value);
		toplam_cek_tutar = parseFloat(filterNum(form_basket.total_cheque_value.value));
		toplam_senet_tutar = wrk_round(toplam_senet_tutar+toplam_pesin_tutar+toplam_cek_tutar,2);

		  if (parseFloat(toplam_fatura_tutar) != parseFloat(toplam_senet_tutar)) 
		{
			/* alert(toplam_pesin_tutar +"--"+ parseFloat(toplam_fatura_tutar) +"--"+ toplam_senet_tutar+"--"+ toplam_h_senet_tutar +"--"+ toplam_cek_tutar); */
			alert("<cf_get_lang dictionary_id ='40889.Sipariş Tutarı İle Çek , Senet Ve Ödemelerin Toplam Tutarı Eşit Olmalı'> !");
			return false;
		} 
		form_due_value = filterNum(form_basket.basket_due_value.value,2);
		payment_due_value = parseFloat((filterNum(form_basket.total_due_value.value,2)*filterNum(form_basket.total_voucher_value.value))+(filterNum(form_basket.total_cheque_due_value.value,2)*toplam_cek_tutar));
		payment_due_value = parseFloat(payment_due_value / toplam_senet_tutar);
		if (payment_due_value != 0 && payment_due_value > form_due_value) 
		{
			alert("<cf_get_lang dictionary_id ='40891.Ödeme Ortalama Vadesi Siparişin Ortalama Vadesinden Fazla Olamaz Lütfen Çek ve Senetlerinizi Tekrar Düzenleyiniz'>! ");
			return false;
		}
		for(dd=1;dd<=form_basket.record_num_3.value;dd++)
		{
			if(eval("document.form_basket.row_kontrol_3"+dd).value == 1)
			{
				if(eval('form_basket.due_date'+dd).value == '')
				{
					alert("<cf_get_lang dictionary_id ='40892.Lütfen Senetler İçin Vade Tarihi Giriniz'> !");
					return false;
				}
			}
		}
		for(dd=1;dd<=form_basket.record_num_4.value;dd++)
		{
			if(eval("document.form_basket.row_kontrol_4"+dd).value == 1)
			{
				if(eval('form_basket.cheque_due_date'+dd).value == '')
				{
					alert("<cf_get_lang dictionary_id ='57471.Eksik Veri'>: <cf_get_lang dictionary_id='57881.Vade Tarihi'>");
					return false;
				}
				if(eval('form_basket.cheque_number'+dd).value == '')
				{
					alert("<cf_get_lang dictionary_id ='57471.Eksik Veri'>: <cf_get_lang dictionary_id ='40893.Çek Numarası'>");
					return false;
				}
			}
		}
		//sıfır stok
		/*var basket_zero_stock_status = wrk_safe_query('sls_bsk_z_stk_stt','dsn3',0,<cfoutput>#attributes.basket_id#</cfoutput>);
		if(basket_zero_stock_status.IS_SELECTED != 1)//<!--- basket sablonlarında sıfır stok ile calıs secilmemisse zero_stock kontrolu yapılıyor --->
		{
			if(!zero_stock_control('','',0,'',1)) return false;
		}*/
		<cfif isdefined("xml_upd_row_project") and xml_upd_row_project eq 1>
			project_field_name = 'project_head';
		<cfelse>
			project_field_name = '';
		</cfif>
		<cfif isdefined('x_apply_deliverdate_to_rows') and x_apply_deliverdate_to_rows eq 1>
			date_field_name = 'deliverdate';
		<cfelse>
			date_field_name = '';
		</cfif>
		apply_deliver_date(date_field_name,project_field_name);
		document.all.is_run_voucher_function.value=0;
		return (process_cat_control() && check_cash_pos() && saveForm());
	}
	function pencere_ac(no)
	{
		if (document.form_basket.city[document.form_basket.city.selectedIndex].value == "")
			alert("<cf_get_lang dictionary_id ='41202.İlk Olarak İl Seçiniz'> !");
		else
			windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_dsp_county&field_id=form_basket.county_id&field_name=form_basket.county&city_id=' + document.form_basket.city.value,'small');
	}
	function add_adress()
	{
		if(!(form_basket.company_id.value=="") || !(form_basket.consumer_id.value==""))
		{
			if(form_basket.company_id.value!="")
			{
				str_adrlink = '&field_long_adres=form_basket.ship_address&field_member_id='+document.form_basket.company_id.value+'';
				if(form_basket.ship_address_city_id!=undefined) str_adrlink = str_adrlink+'&field_city=form_basket.ship_address_city_id';
				if(form_basket.ship_address_county_id!=undefined) str_adrlink = str_adrlink+'&field_county=form_basket.ship_address_county_id'<cfif session.ep.isBranchAuthorization>+'&is_store_module='+1</cfif>;
				openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_member_address&is_comp=1&keyword='+encodeURIComponent(form_basket.comp_name.value)+''+ str_adrlink);
				return true;
			}
			else
			{
				str_adrlink = '&field_long_adres=form_basket.ship_address&field_member_id='+document.form_basket.consumer_id.value+''; 
				if(form_basket.ship_address_city_id!=undefined) str_adrlink = str_adrlink+'&field_city=form_basket.ship_address_city_id';
				if(form_basket.ship_address_county_id!=undefined) str_adrlink = str_adrlink+'&field_county=form_basket.ship_address_county_id'<cfif session.ep.isBranchAuthorization>+'&is_store_module='+1</cfif>;
				openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_member_address&is_comp=0&keyword='+encodeURIComponent(form_basket.member_name.value)+' '+encodeURIComponent(form_basket.member_surname.value)+''+ str_adrlink);
				return true;
			}
		}
		else
		{
			alert("<cf_get_lang dictionary_id='41056.Cari Hesap Secmelisiniz'>!");
			return false;
		}
	}
	function pencere_ac_paymethod()
	{
		var str_control=0;
		<cfif x_required_paymethod eq 1>
			if(document.form_basket!=undefined && document.form_basket.basket_id!= undefined && document.form_basket.product_id!= undefined)
			{
				if(document.form_basket.product_id.value!=undefined && document.form_basket.product_id.value!='' )
				{
					str_control=1;
				}
				else if(document.form_basket.product_id.length > 1)
				{
					for(var spt_row=0;spt_row < document.form_basket.product_id.length;spt_row++)
					{
						if(document.form_basket.product_id[spt_row].value!='')
						{
							str_control=1;
							break;
						}
					}
				}
				if(str_control==1)
				{
					alert("<cf_get_lang dictionary_id ='41203.Baskette Ürün Varken Ödeme Yöntemini Değiştiremezsiniz'> !");
				}
			}
		</cfif>
		if(str_control == 0)
			openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_paymethods&field_id=form_basket.paymethod_id&field_name=form_basket.paymethod&field_dueday=form_basket.basket_due_value#card_link#</cfoutput>');
	}
	str_cons_link="&field_member_code=form_basket.member_code&field_ozel_kod=form_basket.ozel_kod&field_comp_name=form_basket.comp_name&field_address=form_basket.address&field_mobil_code_2=form_basket.mobil_code_2&field_mobil_tel_2=form_basket.mobil_tel_2&field_mobil_code=form_basket.mobil_code&field_mobil_tel=form_basket.mobil_tel&field_tel_code=form_basket.tel_code&field_tel_number=form_basket.tel_number&field_ims_code=form_basket.tel_number<cfif is_ims_code eq 1>&field_ims_code_id=form_basket.ims_code_id&field_ims_code_name=form_basket.ims_code_name</cfif>";
	str_cons_link=str_cons_link+"&field_tax_office=form_basket.tax_office&field_tax_num=form_basket.tax_num&field_county=form_basket.county&field_county_id=form_basket.county_id&field_city=form_basket.city&field_faxcode=form_basket.faxcode&field_fax_number=form_basket.fax_number&field_tc_no=form_basket.tc_num";
	str_cons_link=str_cons_link+"&field_member_name=form_basket.member_name&field_member_surname=form_basket.member_surname&field_adres_type=form_basket.adres_type";
	str_cons_link=str_cons_link+"&field_company_id=form_basket.company_id&field_partner_id=form_basket.partner_id&field_consumer_id=form_basket.consumer_id";
	str_cons_link = str_cons_link+'&field_vocation=form_basket.vocation_type';

	function cons_pre_records()
	{	
		if(((form_basket.member_name.value!="" && form_basket.member_surname.value!="") || form_basket.tc_num.value != "") && form_basket.comp_name.value=="")
			windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_check_consumer_prerecords&call_function=find_risk()&is_from_sale=1<cfif session.ep.isBranchAuthorization>&is_store_module=1</cfif>&tc_num=' + form_basket.tc_num.value + '&consumer_name=' + encodeURIComponent(form_basket.member_name.value) + '&consumer_surname=' + encodeURIComponent(form_basket.member_surname.value) + '&tax_no=' + form_basket.tax_num.value +str_cons_link,'project','popup_check_consumer_prerecords');
	}
	function tax_num_pre_records()
	{	
		if(form_basket.tax_num.value!="")
		windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_check_company_prerecords&is_from_sale=1<cfif session.ep.isBranchAuthorization>&is_store_module=1</cfif>&tax_num='+ encodeURIComponent(form_basket.tax_num.value) +'&fullname='+ encodeURIComponent(form_basket.comp_name.value) +'&nickname=' + encodeURIComponent(form_basket.comp_name.value) +'&name='+''+'&surname='+''+'&tel_code='+''+'&telefon='+''+str_cons_link,'project','popup_check_company_prerecords');
	}
	function comp_pre_records()
	{
		if(form_basket.comp_name.value!="" && form_basket.member_name.value=="" && form_basket.member_surname.value=="")
			windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_check_company_prerecords&call_function=find_risk()&is_from_sale=1<cfif session.ep.isBranchAuthorization>&is_store_module=1</cfif>&tax_no='+ encodeURIComponent(form_basket.member_tax_no.value) +'&fullname='+ encodeURIComponent(form_basket.comp_name.value) +'&nickname=' + encodeURIComponent(form_basket.comp_name.value) +'&name='+''+'&surname='+''+'&tel_code='+''+'&telefon='+''+str_cons_link,'project','popup_check_company_prerecords');
	}
	function kontrol_member_cat(type)
	{
		if (type == 1)
		{
			is_company.style.display = '';
			is_consumer.style.display = 'none';
			document.getElementById('cons_member_cat').value = '';
		}
		if (type == 2)
		{
			is_company.style.display = 'none';
			is_consumer.style.display = '';
			document.getElementById('comp_member_cat').value = '';
		}
	}
	function kontrol_member()
	{
		if (form_basket.order_date.value == '')
		{
			alert("Sipariş Tarihi Girmelisiniz!");
			return false;
		}
		if(form_basket.member_type[0].checked)
		{
			if(form_basket.comp_name.value=="" || form_basket.tax_office.value=="" || form_basket.tax_num.value=="" || form_basket.address.value=="")
			{
				alert("<cf_get_lang dictionary_id ='41204.Kurumsal Müşteri İçin Firma, Vergi Dairesi, Vergi Numarası ve Adres Bilgilerini Giriniz'>!");
				return false;
			}					
			if(form_basket.company_stage.value=="" && form_basket.company_id.value == "")
			{
				alert("<cf_get_lang dictionary_id ='41205.Kurumsal Üye Süreçlerinizi Kontrol Ediniz'>!");
				return false;
			}
		}
		else if(form_basket.member_type[1].checked)
		{
			if(form_basket.member_name.value=="" || form_basket.member_surname.value=="" || form_basket.address.value=="")
			{
				alert("<cf_get_lang dictionary_id ='41206.Bireysel Müşteri İçin Ad Soyad ve Adres Bilgilerini Giriniz'>!");
				return false;
			}
			<cfif xml_kontrol_tcnumber eq 1>
				if(form_basket.tc_num.value=="")
				{
					alert("<cf_get_lang dictionary_id ='58194.Zorunlu Alan'>:<cf_get_lang dictionary_id ='58025.TC Kimlik No'>");
					return false;	
				}
			</cfif>
			<cfif is_required_vocation eq 1>
				if(form_basket.vocation_type.value=="")
				{
					alert("<cf_get_lang dictionary_id ='58194.Zorunlu Alan'>:<cf_get_lang dictionary_id ='41195.Meslek Tipi'>");
					return false;		
				}
			</cfif>
			if(form_basket.consumer_stage.value=="" && form_basket.consumer_id.value == "")
			{
				alert("<cf_get_lang dictionary_id ='41207.Bireysel Üye Süreçlerinizi Kontrol Ediniz'>!");
				return false;
			}
			<cfif xml_kontrol_tcnumber eq 1>
				var consumer_control = wrk_safe_query('ext_cnsr_ctrl','dsn',0,form_basket.tc_num.value);
				if(consumer_control.recordcount > 0)
				{
					alert("<cf_get_lang dictionary_id ='41335.Aynı TC Kimlik Numarası İle Kayıtlı Üye Var Lütfen Bilgilerinizi Kontrol Ediniz'> !");
					return false;
				}
			</cfif>
		}
		<cfif isdefined("is_dsp_category") and is_dsp_category eq 1>
			if(((document.getElementById('comp_member_cat') != undefined && document.getElementById('comp_member_cat').value == '') || document.getElementById('comp_member_cat') == undefined) && ((document.getElementById('cons_member_cat') != undefined && document.getElementById('cons_member_cat').value == '') || document.getElementById('cons_member_cat') == undefined))
			{
				alert("Lütfen Üye Kategorisi Giriniz!");	
				return false;
			}
		</cfif>
		windowopen('','small','cc_member');
		form_basket.action='<cfoutput>#request.self#?fuseaction=#listgetat(attributes.fuseaction,1,'.')#.emptypopup_add_sale_member</cfoutput>';
		form_basket.target='cc_member';
		form_basket.submit();
		return false;
	}
	function add_adresses()
	{
		if(!(form_basket.company_id.value=="") || !(form_basket.consumer_id.value==""))
		{
			if(form_basket.company_id.value!="")
			{
				str_adrlink = '&field_adres=form_basket.address&field_member_id='+document.form_basket.company_id.value+'';
				if(form_basket.city!=undefined) str_adrlink = str_adrlink+'&field_city=form_basket.city';
				if(form_basket.county_id!=undefined) str_adrlink = str_adrlink+'&field_county=form_basket.county_id';
				if(form_basket.county!=undefined) str_adrlink = str_adrlink+'&field_county_name=form_basket.county';
				openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_member_address&is_comp=1&keyword='+encodeURIComponent(form_basket.comp_name.value)+''+ str_adrlink);
				return true;
			}
			else
			{
				str_adrlink = '&field_adres=form_basket.address&field_member_id='+document.form_basket.consumer_id.value+''; 
				if(form_basket.city!=undefined) str_adrlink = str_adrlink+'&field_city=form_basket.city';
				if(form_basket.county_id!=undefined) str_adrlink = str_adrlink+'&field_county=form_basket.county_id';
				if(form_basket.county!=undefined) str_adrlink = str_adrlink+'&field_county_name=form_basket.county';
				openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_member_address&is_comp=0&keyword='+encodeURIComponent(form_basket.member_name.value)+' '+form_basket.member_surname.value+'&tc_num='+form_basket.tc_num.value+''+ str_adrlink);
				return true;
			}
		}
		else
		{
			alert("<cf_get_lang dictionary_id ='57715.Önce Üye Seçiniz'>!");
			return false;
		}
	}
</script>
<script type="text/javascript">
	$(document).ready(function(){
		try{
			rowCount =  window.basket.items.length;
		}
		catch(e)
		{}	
		document.form_basket.member_name.focus();
		LoadCity($("#country").val(),'city','county_id',0);
		
	 });
</script>
<cf_get_lang_set module_name="#lcase(listgetat(attributes.fuseaction,1,'.'))#">
