	<cf_box_elements>
		<cfoutput>
			<div class="col col-12 col-md-12 col-sm-12 col-xs-12" type="column" index="1" sort="true">
				<div class="form-group col col-1 col-md-1 col-sm-6 col-xs-12 require" id="item-order_status">
					<label class="col col-12 col-md-12 col-sm-12 col-xs-12">
						<cf_get_lang dictionary_id='57493.Aktif'>
						<cfif get_order_detail.order_currency neq 2>
							<input type="checkbox" name="order_status" id="order_status" value="1"  required="yes" <cfif get_order_detail.order_status eq 1>checked</cfif>>
							<input type="hidden" name="order_status_old" id="order_status_old" value="<cfoutput>#get_order_detail.order_status#</cfoutput>" />
						</cfif>
					</label>
				</div>
				<div class="form-group col col-1 col-md-1 col-sm-6 col-xs-12" id="item-reserved">
					<label class="col col-12 col-md-12 col-sm-12 col-xs-12">
						<cf_get_lang dictionary_id='57452.Stok'><cf_get_lang dictionary_id='40866.Rezerve Et'>
						<input type="checkbox" name="reserved" id="reserved" value="1" onClick="check_reserved_rows();" <cfif get_order_detail.reserved eq 1>checked</cfif>>
					</label>
				</div>
				<cfif isdefined("xml_kdv_yd") and xml_kdv_yd eq 1>
					<div class="form-group col col-1 col-md-1 col-sm-6 col-xs-12 require" id="item-abroad">					
						<label class="col col-12 col-md-12 col-sm-12 col-xs-12"><cf_get_lang dictionary_id='29692.Yurtdışı'>
							<input type="checkbox" name="is_foreign" id="is_foreign" value="1" onClick="kontrol_yurtdisi();" <cfif get_order_detail.is_foreign eq 1> checked </cfif>>
						</label>					
					</div>
				</cfif>
			</div>
			<div class="col col-3 col-md-4 col-sm-12" type="column" index="2" sort="true">
				<div class="form-group require" id="item-order_head">
					<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58820.Başlık'></label>
					<div class="col col-8 col-sm-12">
						<cfinput type="text" name="order_head" value="#get_order_detail.order_head#" required="yes" message="#getLang('','Başlık Girmelisiniz',58059)#" maxlength="200">
					</div>
				</div>
				<div class="form-group require" id="item-process_stage">
					<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id="58859.Süreç"></label>
					<div class="col col-8 col-sm-12">
						<cf_workcube_process is_upd='0' select_value='#get_order_detail.order_stage#' process_cat_width='125' is_detail='1'>
					</div>
				</div>
				<div class="form-group require" id="item-company">
					<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57457.Müşteri'></label>
					<div class="col col-8 col-sm-12">
						<div class="input-group">
							<cfset str_linkeait="&field_paymethod_id=form_basket.paymethod_id&field_paymethod=form_basket.paymethod&field_revmethod_id=form_basket.paymethod_id&field_cons_ref_code=form_basket.consumer_reference_code&field_revmethod=form_basket.paymethod&field_basket_due_value_rev=form_basket.basket_due_value&ship_method_id=form_basket.ship_method_id&ship_method_name=form_basket.ship_method_name&field_card_payment_id=form_basket.card_paymethod_id&field_comp_id2=form_basket.deliver_comp_id&field_consumer2=form_basket.deliver_cons_id">
							<cfif isdefined("xml_emp_branch_adress") and xml_emp_branch_adress eq 1><cfset str_linkeait=str_linkeait&"&is_partner_address=1"></cfif>
							<input type="text" name="company" id="company" value="#company_name#" readonly>
							<span class="input-group-addon btnPointer icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_pars&is_period_kontrol=0&is_buyer_seller=0&field_adress_id=form_basket.ship_address_id&field_consumer=form_basket.consumer_id&field_id=form_basket.member_id&field_comp_name=form_basket.company&field_comp_id=form_basket.company_id&field_name=form_basket.partner_name&field_type=form_basket.member_type&field_address=form_basket.ship_address&field_city_id=form_basket.ship_address_city_id&field_county_id=form_basket.ship_address_county_id#str_linkeait#<cfif session.ep.isBranchAuthorization>&is_store_module=1</cfif>&select_list=7,8&function_name=fill_country&call_function=add_general_prom()-check_member_price_cat()-change_paper_duedate()');"></span>
						</div>
					</div>
				</div>
				<div class="form-group require" id="item-member_name">
					<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57578.Yetkili'></label>
					<div class="col col-8 col-sm-12">
						<cfinput type="text" name="partner_name" id="partner_name" value="#member_name#">
					</div>
				</div>
				<div class="form-group require" id="item-offer_head">
					<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57545.Teklif'></label>
					<div class="col col-8 col-sm-12">
						<div class="input-group">
							<cfif len(get_order_detail.offer_id)>
								<cfset attributes.offer_id = get_order_detail.offer_id>
								<cfinclude template="../query/get_offer_head.cfm">
								<input type="hidden" name="offer_id" id="offer_id" value="#get_order_detail.offer_id#">
								<input type="text" name="offer_head" id="offer_head" value="#get_offer_head.offer_head#">
								<span class="input-group-addon btnPointer icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=sales.popup_list_offers&field_offer_id=form_basket.offer_id&field_offer_head=form_basket.offer_head');"></span>
							<cfelse>
								<input type="hidden" name="offer_id" id="offer_id" value="">
								<input type="text" name="offer_head" id="offer_head" value="">
								<span class="input-group-addon btnPointer icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=sales.popup_list_offers&field_offer_id=form_basket.offer_id&field_offer_head=form_basket.offer_head');"></span>
							</cfif>
						</div>
					</div>
				</div>
				<div class="form-group require" id="item-order_employee">
					<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='41159.Satış Çalışanı'></label>
					<div class="col col-8 col-sm-12">
						<div class="input-group">
							<cfif len(get_order_detail.order_employee_id)>
								<input type="hidden" name="order_employee_id" id="order_employee_id" value="#get_order_detail.order_employee_id#">
								<input type="text" name="order_employee" id="order_employee" value="#get_emp_info(get_order_detail.order_employee_id,0,0)#" onFocus="AutoComplete_Create('order_employee','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','3','EMPLOYEE_ID','order_employee_id','','3','125');" autocomplete="off">
								<span class="input-group-addon btnPointer icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_positions&field_emp_id=form_basket.order_employee_id&field_name=form_basket.order_employee&select_list=1');"></span>
							<cfelse>
								<input type="hidden" name="order_employee_id" id="order_employee_id" value="">
								<input type="text" name="order_employee" id="order_employee" value="" onFocus="AutoComplete_Create('order_employee','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','3','EMPLOYEE_ID','order_employee_id','','3','125');" autocomplete="off">
								<span class="input-group-addon btnPointer icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_positions&field_emp_id=form_basket.order_employee_id&field_name=form_basket.order_employee&select_list=1');"></span>
							</cfif>
						</div>
					</div>
				</div>
				<div class="form-group require" id="item-sales_member">
					<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='40904.Satış Ortağı'></label>
					<div class="col col-8 col-sm-12">
						<div class="input-group">
							<cfif len(get_order_detail.sales_partner_id)>
								<input type="hidden" name="sales_member_id" id="sales_member_id" value="#get_order_detail.sales_partner_id#">
								<input type="hidden" name="sales_member_type" id="sales_member_type" value="partner">
								<input type="text" name="sales_member" id="sales_member" placeholder="<cfoutput>#getLang(102,'Satış Ortağı',40904)#</cfoutput>" value="#get_par_info(get_order_detail.sales_partner_id,0,-1,0)#" onFocus="AutoComplete_Create('sales_member','MEMBER_NAME,MEMBER_PARTNER_NAME','MEMBER_PARTNER_NAME2,MEMBER_NAME2','get_member_autocomplete','\'1,2\',0,0,0','PARTNER_CODE,MEMBER_TYPE','sales_member_id,sales_member_type','','3','250');" autocomplete="off">
								<cfif session.ep.isBranchAuthorization>
									<span class="input-group-addon btnPointer icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_pars&is_rate_select=1&field_id=form_basket.sales_member_id&field_name=form_basket.sales_member&field_type=form_basket.sales_member_type&is_store_module=1&select_list=2,3');"></span>
								<cfelse>
									<span class="input-group-addon btnPointer icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_pars&is_rate_select=1&field_id=form_basket.sales_member_id&field_name=form_basket.sales_member&field_type=form_basket.sales_member_type&select_list=2,3');"></span>
								</cfif>
							<cfelseif len(get_order_detail.sales_consumer_id)>
								<input type="hidden" name="sales_member_id" id="sales_member_id" value="#get_order_detail.sales_consumer_id#">
								<input type="hidden" name="sales_member_type" id="sales_member_type" value="consumer">
								<input type="text" name="sales_member" id="sales_member" placeholder="<cfoutput>#getLang(102,'Satış Ortağı',40904)#</cfoutput>" value="#get_cons_info(get_order_detail.sales_consumer_id,0,0)#"  onFocus="AutoComplete_Create('sales_member','MEMBER_NAME,MEMBER_PARTNER_NAME','MEMBER_PARTNER_NAME2,MEMBER_NAME2','get_member_autocomplete','\'1,2\',0,0,0','PARTNER_CODE,MEMBER_TYPE','sales_member_id,sales_member_type','','3','250');" autocomplete="off">
								<cfif session.ep.isBranchAuthorization>
									<span class="input-group-addon btnPointer icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_pars&is_rate_select=1&field_id=form_basket.sales_member_id&field_name=form_basket.sales_member&field_type=form_basket.sales_member_type&is_store_module=1&select_list=2,3');"></span>
								<cfelse>
									<span class="input-group-addon btnPointer icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_pars&is_rate_select=1&field_id=form_basket.sales_member_id&field_name=form_basket.sales_member&field_type=form_basket.sales_member_type&select_list=2,3');"></span>
								</cfif>
							<cfelse>
								<input type="hidden" name="sales_member_id" id="sales_member_id" value="">
								<input type="hidden" name="sales_member_type" id="sales_member_type" value="">
								<input type="text" name="sales_member" id="sales_member" value="" placeholder="<cfoutput>#getLang(102,'Satış Ortağı',40904)#</cfoutput>" onFocus="AutoComplete_Create('sales_member','MEMBER_NAME,MEMBER_PARTNER_NAME','MEMBER_PARTNER_NAME2,MEMBER_NAME2','get_member_autocomplete','\'1,2\',0,0,0','PARTNER_CODE,MEMBER_TYPE','sales_member_id,sales_member_type','','3','250');" autocomplete="off">
								<cfif session.ep.isBranchAuthorization>
									<span class="input-group-addon btnPointer icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_pars&is_rate_select=1&field_id=form_basket.sales_member_id&field_name=form_basket.sales_member&field_type=form_basket.sales_member_type&is_store_module=1&select_list=2,3');"></span>
								<cfelse>
									<span class="input-group-addon btnPointer icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_pars&is_rate_select=1&field_id=form_basket.sales_member_id&field_name=form_basket.sales_member&field_type=form_basket.sales_member_type&select_list=2,3');"></span>
								</cfif>
							</cfif>
						</div>
					</div>
				</div>
			</div>
			<div class="col col-3 col-md-4 col-sm-12" type="column" index="3" sort="true">
				<div class="form-group require" id="item-order_date">
					<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='29501.Sipariş Tarihi'></label>
					<div class="col col-8 col-sm-12">
						<div class="input-group">
							<cfinput type="text" name="order_date" id="order_date" value="#dateformat(get_order_detail.order_date,dateformat_style)#" validate="#validate_style#" required="yes" message="#getLang('','Sipariş Tarihi Girmelisiniz',38654)# !" maxlength="10">
							<span class="input-group-addon"><cf_wrk_date_image date_field="order_date" call_function="add_general_prom&change_money_info"></span>
						</div>
					</div>
				</div>
				<div class="form-group require" id="item-ship_date">
					<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='40834.Sevk Tarihi'></label>
					<div class="col col-8 col-sm-12">
						<div class="input-group">
							<cfinput type="text" name="ship_date" id="ship_date" value="#dateformat(get_order_detail.ship_date,dateformat_style)#" validate="#validate_style#" message="#getLang('','Sevk Tarihi Girmelisiniz',40895)# !" maxlength="10">
							<span class="input-group-addon"><cf_wrk_date_image date_field="ship_date"></span>
						</div>
					</div>
				</div>
				<div class="form-group require" id="item-deliverdate">
					<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57645.Teslim Tarihi'></label>
					<div class="col col-8 col-sm-12">
						<div class="input-group">
							<cfinput type="text" name="deliverdate" id="deliverdate" value="#dateformat(get_order_detail.deliverdate,dateformat_style)#" validate="#validate_style#" maxlength="10" onblur="apply_deliver_date('deliverdate');">
							<span class="input-group-addon"><cf_wrk_date_image date_field="deliverdate" call_function="add_general_prom&apply_deliver_date('deliverdate')"></span>
							<cfif isdefined('is_termin_calc') and is_termin_calc eq 1>
								<cfsavecontent variable="lang_message"><cf_get_lang dictionary_id='41333.Teslim Tarihini Hesapla'></cfsavecontent>
								<span class="input-group-addon btnPointer icon-cogs" onClick="calc_deliver_date();"></span>
								<div style="position:absolute;z-index:9999999" id="deliver_date_info"></div>
							</cfif>
						</div>
					</div>
				</div>
				<div class="form-group require" id="item-project_head">
					<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57416.Proje'></label>
					<div class="col col-8 col-sm-12">
						<div class="input-group">
							<input type="hidden" name="project_id" id="project_id" value="#get_order_detail.project_id#">
							<cfset str_linke_ait_prj="&comp_id='+document.form_basket.company_id.value+'&cons_id='+document.form_basket.consumer_id.value+'&comp_name='+document.form_basket.company.value+'&mem_type='+document.form_basket.member_type.value+'">
							<input type="text" name="project_head" id="project_head" placeholder="<cfoutput>#getLang('main',4)#</cfoutput>" value="<cfif len(get_order_detail.project_id)>#GET_PROJECT_NAME(get_order_detail.project_id)#</cfif>"  onFocus="AutoComplete_Create('project_head','PROJECT_HEAD,PROJECT_ID','PROJECT_HEAD','get_project','','PROJECT_ID','project_id','form_basket','3','200')"autocomplete="off">
							<span class="input-group-addon btnPointer icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_projects#str_linke_ait_prj#&project_id=form_basket.project_id&project_head=form_basket.project_head&paymethod=form_basket.paymethod&paymethod_id=form_basket.paymethod_id&card_paymethod_id=form_basket.card_paymethod_id&dueday=form_basket.basket_due_value&commission_rate=form_basket.commission_rate&paymethod_vehicle=form_basket.paymethod_vehicle&function_name=change_paper_duedate');"></span>
							<span class="input-group-addon btnPointer icon-question" onClick="if(document.getElementById('project_id').value!='')windowopen('#request.self#?fuseaction=project.popup_list_project_actions&from_paper=ORDERS&id='+document.getElementById('project_id').value+'','horizantal');else alert('<cf_get_lang dictionary_id='1385.Proje Seçiniz'>!');"></span>
						</div>
					</div>
				</div>
				<div class="form-group require" id="item-work_head">
					<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58445.İş'></label>
					<div class="col col-8 col-sm-12">
						<div class="input-group">
							<input type="hidden" name="work_id" id="work_id" value="<cfif len(get_order_detail.work_id)>#get_order_detail.work_id#</cfif>">
							<input type="text" name="work_head" id="work_head" value="<cfif len(get_order_detail.work_id)>#get_work_name(get_order_detail.work_id)#</cfif>">
							<span class="input-group-addon btnPointer icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_add_work&field_id=form_basket.work_id&field_name=form_basket.work_head');"></span>
						</div>
					</div>
				</div>
				<div class="form-group require" id="item-commethod_id">
					<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58143.İletişim'></label>
					<div class="col col-8 col-sm-12">
						<select name="commethod_id" id="commethod_id">
							<option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
							<cfloop query="get_commethod_cats">
								<option value="#commethod_id#" <cfif get_order_detail.commethod_id eq commethod_id>selected</cfif>>#commethod#</option>
							</cfloop>
						</select>
					</div>
				</div>
				<cfif session.ep.our_company_info.subscription_contract eq 1>
					<div class="form-group require" id="item-sales_add_option">
						<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id ='41142.Satış Özel Tanım'></label>
						<div class="col col-8 col-sm-12">
							<cfinclude template="../query/get_sale_add_option.cfm">
							<select name="sales_add_option" id="sales_add_option">
								<option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
								<cfloop query="get_sale_add_option">
									<option value="#sales_add_option_id#"<cfif sales_add_option_id eq get_order_detail.sales_add_option_id>selected</cfif>>#sales_add_option_name#</option>
								</cfloop>
							</select>
						</div>
					</div>
				</cfif>
			</div>
			<div class="col col-3 col-md-4 col-sm-12" type="column" index="4" sort="true">
				<div class="form-group require" id="item-deliver_dept_name">
					<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58763.Depo'></label>
					<div class="col col-8 col-sm-12">
						<cfset location_info_ = get_location_info(get_order_detail.deliver_dept_id,get_order_detail.location_id,1,1)>
						<cfif session.ep.isBranchAuthorization and isdefined("x_dsp_all_departmants") and x_dsp_all_departmants eq 0>
							<cfset user_b_control = 1>
						<cfelse>
							<cfset user_b_control = session.ep.OUR_COMPANY_INFO.IS_LOCATION_FOLLOW>
						</cfif>
						<cfif len(get_order_detail.deliver_dept_id) and len(get_order_detail.location_id)>
							<cf_wrkdepartmentlocation
								returnInputValue="deliver_loc_id,deliver_dept_name,deliver_dept_id,branch_id"
								returnQueryValue="LOCATION_ID,LOCATION_NAME,DEPARTMENT_ID,BRANCH_ID"
								fieldName="deliver_dept_name"
								fieldid="deliver_loc_id"
								department_fldId="deliver_dept_id"
								branch_fldId="branch_id"
								branch_id="#listlast(location_info_,',')#"
								department_id="#get_order_detail.deliver_dept_id#"
								location_id="#get_order_detail.location_id#"
								location_name="#listfirst(location_info_,',')#"
								user_level_control="#user_b_control#"
								xml_all_depo = "#IIf(isDefined("x_dsp_all_departmants") and x_dsp_all_departmants eq 1,'1',de('0'))#"
								width="140">
						<cfelse>
							<cf_wrkdepartmentlocation
								returnInputValue="deliver_loc_id,deliver_dept_name,deliver_dept_id,branch_id"
								returnQueryValue="LOCATION_ID,LOCATION_NAME,DEPARTMENT_ID,BRANCH_ID"
								fieldName="deliver_dept_name"
								fieldid="deliver_loc_id"
								department_fldId="deliver_dept_id"
								branch_fldId="branch_id"
								department_id="#get_order_detail.deliver_dept_id#"
								location_id="#get_order_detail.location_id#"
								user_level_control="#user_b_control#"
								width="140">
						</cfif>
					</div>
				</div>
				<div class="form-group require" id="item-ship_method_name">
					<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='29500.Sevk Yontemi'></label>
					<div class="col col-8 col-sm-12">
						<div class="input-group">
							<input type="hidden" name="ship_method_id" id="ship_method_id" value="#get_order_detail.SHIP_METHOD#">
							<cfif len(get_order_detail.SHIP_METHOD)>
								<cfset attributes.ship_method=get_order_detail.SHIP_METHOD>
								<cfinclude template="../query/get_ship_method.cfm">
								<cfset ship_method = GET_SHIP_METHOD.SHIP_METHOD>
							<cfelse>
								<cfset ship_method = "">
							</cfif>
							<input type="text" name="ship_method_name" placeholder="<cfoutput>#getLang(1703,'Sevk Yöntemi',29500)#</cfoutput>" id="ship_method_name" value="#SHIP_METHOD#"  onFocus="AutoComplete_Create('ship_method_name','SHIP_METHOD','SHIP_METHOD','get_ship_method','','SHIP_METHOD_ID','ship_method_id','','3','125');"  autocomplete="off">
							<span class="input-group-addon btnPointer icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_ship_methods&field_name=ship_method_name&field_id=ship_method_id','','ui-draggable-box-small');"></span>
						</div>
					</div>
				</div>
				<div class="form-group require" id="item-ship_address">
					<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58449.Teslim Yeri'></label>
					<div class="col col-8 col-sm-12">
						<div class="input-group">
							<input type="hidden" name="ship_address_city_id" id="ship_address_city_id" value="#get_order_detail.city_id#">
							<input type="hidden" name="ship_address_county_id" id="ship_address_county_id" value="#get_order_detail.county_id#">
							<input type="hidden" name="deliver_comp_id" id="deliver_comp_id" value="#get_order_detail.deliver_comp_id#">
							<input type="hidden" name="deliver_cons_id" id="deliver_cons_id" value="#get_order_detail.deliver_cons_id#">
							<input type="hidden" name="ship_address_id" id="ship_address_id" value="#get_order_detail.ship_address_id#">
							<input type="text" name="ship_address" id="ship_address" value="#get_order_detail.ship_address#">
							<span class="input-group-addon btnPointer icon-ellipsis" onClick="add_adress();"></span>
						</div>
					</div>
				</div>
				<div class="form-group require" id="item-paymethod">
					<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58516.Ödeme Yontemi'></label>
					<div class="col col-8 col-sm-12">
						<div class="input-group">
							<cfset card_link="&field_card_payment_id=form_basket.card_paymethod_id&field_card_payment_name=form_basket.paymethod&field_commission_rate=form_basket.commission_rate&field_paymethod_vehicle=form_basket.paymethod_vehicle">
							<cfif len(get_order_detail.paymethod)>
								<cfset attributes.paymethod_id = get_order_detail.paymethod>
								<cfinclude template="../query/get_paymethod.cfm">
								<input type="hidden" name="card_paymethod_id" id="card_paymethod_id" value="">
								<input type="hidden" name="commission_rate" id="commission_rate" value="">
								<input type="hidden" name="paymethod_vehicle" id="paymethod_vehicle" value="#get_paymethod.payment_vehicle#"> <!--- sadece taksitli fiatı hesaplarken kullanılıyor, order_row'da tutulmuyor --->
								<input type="hidden" name="paymethod_id" id="paymethod_id" value="#get_order_detail.paymethod#">
								<input type="text" name="paymethod" id="paymethod" value="#get_paymethod.paymethod#">
							<cfelseif len(get_order_detail.card_paymethod_id)>
								<cfquery name="get_card_paymethod" datasource="#dsn3#">
									SELECT
										CARD_NO
										<cfif get_order_detail.commethod_id eq 6><!--- WW den gelen siparişlerin guncellemesi --->
											,PUBLIC_COMMISSION_MULTIPLIER AS COMMISSION_MULTIPLIER
										<cfelse><!--- EP VE PP den gelen siparişlerin guncellemesi --->
											,COMMISSION_MULTIPLIER
										</cfif>
									FROM
										CREDITCARD_PAYMENT_TYPE
									WHERE
										PAYMENT_TYPE_ID = #get_order_detail.card_paymethod_id#
								</cfquery>
								<input type="hidden" name="paymethod_vehicle" id="paymethod_vehicle" value="-1"><!--- kredi kartı icin set edilen bu deger dsp_basket_js_scripts.cfm sayfasındaki taksit_hesapla() fonskiyonunda kullanılıyor. burda bi degisiklik yapılırsa orası da degistirilmelidir. 	OZDEN20071218 --->
								<input type="hidden" name="card_paymethod_id" id="card_paymethod_id" value="#get_order_detail.card_paymethod_id#">
								<input type="hidden" name="commission_rate" id="commission_rate" value="#get_card_paymethod.commission_multiplier#">
								<input type="hidden" name="paymethod_id" id="paymethod_id" value="">
								<input type="text" name="paymethod" id="paymethod" value="#get_card_paymethod.card_no#" readonly="readonly">
						<cfelse>
							<input type="hidden" name="paymethod_vehicle" id="paymethod_vehicle" value="">
							<input type="hidden" name="card_paymethod_id" id="card_paymethod_id" value="">
							<input type="hidden" name="commission_rate" id="commission_rate" value="">
							<input type="hidden" name="paymethod_id" id="paymethod_id" value="">
							<input type="text" name="paymethod" id="paymethod" value="">
						</cfif>
						<cfif get_order_detail.is_paid neq 1>
							<cfif xml_sales_delivery_date_calculated>
								<span class="input-group-addon btnPointer icon-ellipsis" onClick="windowopen('#request.self#?fuseaction=objects.popup_paymethods&function_name=change_paper_duedate&function_parameter=deliverdate&field_id=form_basket.paymethod_id&field_name=form_basket.paymethod&field_dueday=form_basket.basket_due_value#card_link#','list');"></span>
							<cfelse>
								<span class="input-group-addon btnPointer icon-ellipsis" onClick="windowopen('#request.self#?fuseaction=objects.popup_paymethods&function_name=change_paper_duedate&function_parameter=order_date&field_id=form_basket.paymethod_id&field_name=form_basket.paymethod&field_dueday=form_basket.basket_due_value#card_link#','list');"></span>
							</cfif>
						</cfif>
						</div>
					</div>
				</div>
				<div class="form-group require" id="item-basket_due_value">
					<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id ='57640.Vade'></label>
					<div class="col col-3 col-sm-6 col-xs-12">
						<cfif xml_sales_delivery_date_calculated eq 0>
							<input type="text" name="basket_due_value" id="basket_due_value"  value="<cfif len(get_order_detail.due_date) and len(get_order_detail.order_date)>#datediff('d',get_order_detail.order_date,get_order_detail.due_date)#</cfif>"  onChange="change_paper_duedate('order_date');" onKeyUp="isNumber(this);">
						<cfelse>
							<input type="text" name="basket_due_value" id="basket_due_value" value="<cfif len(get_order_detail.due_date) and len(get_order_detail.deliverdate)>#datediff('d',get_order_detail.deliverdate,get_order_detail.due_date)#</cfif>"  onChange="change_paper_duedate('deliverdate');" onKeyUp="isNumber(this);">
						</cfif>
					</div>
					<div class="col col-5 col-sm-6 col-xs-12">
						<div class="input-group">
							<cfif xml_sales_delivery_date_calculated eq 0>
								<cfinput type="text" name="basket_due_value_date_" id="basket_due_value_date_" value="#dateformat(get_order_detail.due_date,dateformat_style)#" onChange="change_paper_duedate('order_date',1);" validate="#validate_style#" message="#getLang('','Vade Tarihi Girmelisiniz',33993)#" maxlength="10" readonly>
								<span class="input-group-addon"><cf_wrk_date_image date_field="basket_due_value_date_"></span>
							<cfelse>
								<cfinput type="text" name="basket_due_value_date_" id="basket_due_value_date_"value="#dateformat(get_order_detail.due_date,dateformat_style)#" onChange="change_paper_duedate('deliverdate',1);" validate="#validate_style#" message="#getLang('','Vade Tarihi Girmelisiniz',33993)#" maxlength="10" readonly>
								<span class="input-group-addon"><cf_wrk_date_image date_field="basket_due_value_date_" ></span>
							</cfif>
						</div>
					</div>
				</div>
				<div class="form-group require" id="item-country_id1">
					<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id ='58219.Ulke'></label>
					<div class="col col-8 col-sm-12">
						<select name="country_id1" id="country_id1" onchange="auto_sales_zone();">
							<option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
							<cfloop query="get_country_1">
								<option value="#country_id#" <cfif GET_ORDER_DETAIL.country_id eq country_id> selected </cfif>>#country_name#</option>
							</cfloop>
						</select>
					</div>
				</div>
				<div class="form-group require" id="item-sales_zone_id">
					<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id ='57659.Satış bolgesi'></label>
					<div class="col col-8 col-sm-12">
						<select name="sales_zone_id" id="sales_zone_id">
							<option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
							<cfloop query="get_sale_zones">
								<option value="#sz_id#" <cfif get_order_detail.zone_id eq sz_id> selected </cfif>>#sz_name#</option>
							</cfloop>
						</select>
					</div>
				</div>
				<div class="form-group require" id="item-camp_id">
					<cfif session.ep.our_company_info.subscription_contract eq 1>
						<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='29502.Abone No'></label>
						<div class="col col-8 col-sm-12">
							<cf_wrk_subscriptions subscription_id='#get_order_detail.subscription_id#' fieldId='subscription_id' fieldName='subscription_no' form_name='form_basket' img_info='plus_thin'>
						</div>
					<cfelse>
						<label class="col col-4 col-xs-12"></label>
						<div class="col col-8 col-sm-12">

						</div>
					</cfif>
				</div>
			</div>
			<div class="col col-3 col-md-4 col-sm-12" type="column" index="5" sort="true">
				<div class="form-group require" id="item-detail">
					<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57629.Açıklama'></label>
					<div class="col col-8 col-sm-12">
						<textarea name="order_detail" id="order_detail">#get_order_detail.order_detail#</textarea>
					</div>
				</div>
				<div class="form-group require" id="item-ref_company">
					<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58784.Referans'></label>
					<div class="col col-8 col-sm-12">
						<div class="input-group">
							<cfif len(get_order_detail.ref_partner_id)>
								<input type="hidden" name="ref_company_id" id="ref_company_id" value="#get_order_detail.ref_company_id#">
								<input type="hidden" name="ref_member_type" id="ref_member_type" value="partner">
								<input type="hidden" name="ref_member_id" id="ref_member_id" value="#get_order_detail.ref_partner_id#">
								<input type="text" name="ref_company" id="ref_company" placeholder="<cfoutput>#getLang('main',1372)#</cfoutput>" value="#get_par_info(get_order_detail.ref_company_id,1,0,0)#" onFocus="AutoComplete_Create('ref_company','MEMBER_NAME,MEMBER_PARTNER_NAME','MEMBER_NAME2,MEMBER_PARTNER_NAME2','get_member_autocomplete','\'1,2\'','COMPANY_ID,MEMBER_TYPE,PARTNER_CODE,MEMBER_PARTNER_NAME2','ref_company_id,ref_member_type,ref_member_id,ref_member','','3','250');" autocomplete="off">
								<span class="input-group-addon btnPointer icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_all_pars&is_rate_select=1&field_partner=form_basket.ref_member_id&field_consumer=form_basket.ref_member_id&field_comp_id=form_basket.ref_company_id&field_comp_name=form_basket.ref_company&field_name=form_basket.ref_member&field_type=form_basket.ref_member_type<cfif session.ep.isBranchAuthorization>&is_store_module=1</cfif>&select_list=7,8');"></span>
							<cfelseif len(get_order_detail.ref_consumer_id)>
								<input type="hidden" name="ref_company_id" id="ref_company_id" value="#get_order_detail.ref_company_id#">
								<input type="hidden" name="ref_member_type" id="ref_member_type" value="consumer">
								<input type="hidden" name="ref_member_id" id="ref_member_id" value="#get_order_detail.ref_consumer_id#">
								<input type="text" name="ref_company" id="ref_company" value="" placeholder="<cfoutput>#getLang('main',1372)#</cfoutput>" onFocus="AutoComplete_Create('ref_company','MEMBER_NAME,MEMBER_PARTNER_NAME','MEMBER_NAME2,MEMBER_PARTNER_NAME2','get_member_autocomplete','\'1,2\'','COMPANY_ID,MEMBER_TYPE,PARTNER_CODE,MEMBER_PARTNER_NAME2','ref_company_id,ref_member_type,ref_member_id,ref_member','','3','250');" autocomplete="off">
								<span class="input-group-addon btnPointer icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_all_pars&is_rate_select=1&field_partner=form_basket.ref_member_id&field_consumer=form_basket.ref_member_id&field_comp_id=form_basket.ref_company_id&field_comp_name=form_basket.ref_company&field_name=form_basket.ref_member&field_type=form_basket.ref_member_type<cfif session.ep.isBranchAuthorization>&is_store_module=1</cfif>&select_list=7,8');"></span>
							<cfelse>
								<input type="hidden" name="ref_company_id" id="ref_company_id" value="">
								<input type="hidden" name="ref_member_type" id="ref_member_type" value="">
								<input type="hidden" name="ref_member_id" id="ref_member_id" value="">
								<input type="text" name="ref_company" id="ref_company" value="" placeholder="<cfoutput>#getLang('main',1372)#</cfoutput>" onFocus="AutoComplete_Create('ref_company','MEMBER_NAME,MEMBER_PARTNER_NAME','MEMBER_NAME2,MEMBER_PARTNER_NAME2','get_member_autocomplete','\'1,2\'','COMPANY_ID,MEMBER_TYPE,PARTNER_CODE,MEMBER_PARTNER_NAME2','ref_company_id,ref_member_type,ref_member_id,ref_member','','3','250');" autocomplete="off">
								<span class="input-group-addon btnPointer icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_all_pars&is_rate_select=1&field_partner=form_basket.ref_member_id&field_consumer=form_basket.ref_member_id&field_comp_id=form_basket.ref_company_id&field_comp_name=form_basket.ref_company&field_name=form_basket.ref_member&field_type=form_basket.ref_member_type<cfif session.ep.isBranchAuthorization>&is_store_module=1</cfif>&select_list=7,8');"></span>
							</cfif>
						</div>
					</div>
				</div>
				<div class="form-group require" id="item-ref_no">
					<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58794.Referans No'></label>
					<div class="col col-8 col-sm-12">
						<input type="text"  name="ref_no" id="ref_no" value="<cfif len(get_order_detail.ref_no)>#get_order_detail.ref_no#</cfif>" maxlength="50">
					</div>
				</div>
				<div class="form-group require" id="item-ref_member">
					<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57578.Yetkili'></label>
					<div class="col col-8 col-sm-12">
						<input type="text" name="ref_member" id="ref_member" value="<cfif len(get_order_detail.ref_partner_id)>#get_par_info(get_order_detail.ref_partner_id,0,-1,0)#<cfelseif len(get_order_detail.ref_consumer_id)>#get_cons_info(get_order_detail.ref_consumer_id,0,0,0)#</cfif>" readonly>
					</div>
				</div>
				<div class="form-group require" id="item-priority_id">
					<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57485.Öncelik'></label>
					<div class="col col-8 col-sm-12">
						<select name="priority_id" id="priority_id">
							<cfloop query="get_priorities">
								<option value="#priority_id#" <cfif priority_id eq get_order_detail.priority_id>selected</cfif>>#priority#</option>
							</cfloop>
						</select>
					</div>
				</div>
				<div class="form-group require" id="item-camp_name">
					<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57446.Kampanya'></label>
					<div class="col col-8 col-sm-12">
						<div class="input-group">
							<cfif len(get_order_detail.camp_id)>
								<cfquery name="get_camp_info" datasource="#dsn3#">
									SELECT CAMP_ID,CAMP_HEAD FROM CAMPAIGNS WHERE CAMP_ID = #get_order_detail.camp_id#
								</cfquery>
							<cfelse>
								<cfset get_camp_info.camp_head = ''>
							</cfif>
							<cfoutput>
								<input type="hidden" name="camp_id" id="camp_id" value="#get_order_detail.camp_id#">
								<input type="text" name="camp_name" id="camp_name" value="#get_camp_info.camp_head#">
								<span class="input-group-addon btnPointer icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_campaigns&field_id=form_basket.camp_id&field_name=form_basket.camp_name');"></span>
							</cfoutput>
						</div>
					</div>
				</div>
				<div class="form-group require" id="item-cf_wrk_add_info">
					<label class="col col-4 col-xs-12"><cfoutput>#getLang(398,'Ek Bilgi',57810)#</cfoutput></label>
					<div class="col col-8 col-xs-12"> 
						<cf_wrk_add_info info_type_id="-7" info_id="#attributes.order_id#" upd_page = "1">
					</div>
				</div>
			</div>
		</cfoutput>
	</cf_box_elements>
	<cf_box_footer>
		<div class="col col-8 col-xs-12">
			<cfoutput>
				<cfif get_order_detail.order_zone eq 0>
					<cf_record_info query_name="get_order_detail" record_emp="RECORD_EMP">
				<cfelseif get_order_detail.order_zone eq 1 and len(get_order_detail.record_par)>
					<cf_record_info query_name="get_order_detail" record_par="RECORD_PAR" is_partner='1'>
				<cfelseif get_order_detail.order_zone eq 1 and len(get_order_detail.record_con)>
					<cf_record_info query_name="get_order_detail" record_cons="RECORD_CON" is_consumer='1'>
				</cfif>
			</cfoutput>
		</div>
		<div class="col col-4 col-xs-12">
					<cfif get_order_detail.is_paid eq 1>
						<span class="basketFooterInfo"><font color="red"><cf_get_lang dictionary_id ='41117.Ödendi'>! - </font></span>
					<cfelseif get_order_detail.purchase_sales eq 0 and get_order_detail.order_zone eq 1 and len(get_order_detail.card_paymethod_id) and get_order_detail.is_paid eq 0>
						<span class="basketFooterInfo"><font color="red"><cf_get_lang dictionary_id ='41226.Ödenmedi'>! - </font></span>
					</cfif>
					<cfquery name="get_our_comp_inf" datasource="#dsn#">
						SELECT IS_ORDER_UPDATE FROM OUR_COMPANY_INFO WHERE COMP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#">
					</cfquery>
					<cfif get_order_detail.is_processed eq 1>
						<cfquery name="control_order_ship" datasource="#dsn3#"> <!--- aktif donemde siparisle ilgili irsaliye kaydı olup olmadığı kontrol edilir --->
							SELECT SHIP_ID,PERIOD_ID FROM ORDERS_SHIP WHERE ORDER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.order_id#">
						</cfquery>
						<cfquery name="control_order_invoice" datasource="#dsn3#"> 
							SELECT INVOICE_ID,PERIOD_ID FROM ORDERS_INVOICE WHERE ORDER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.order_id#">
						</cfquery>
						<cfif control_order_ship.recordcount><!--- bu irsaliyelerle ilgili sevkiyat ve fatura bilgileri kontrol ediliyor --->
							<font color="red"><cf_get_lang dictionary_id='57893.İrsaliye Kesildi'>!</font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<cfset ship_period_list=listdeleteduplicates(valuelist(control_order_ship.PERIOD_ID))>
							<cfif listlen(ship_period_list) eq 1 and ship_period_list eq session.ep.period_id>
								<cfset control_ship_list=valuelist(control_order_ship.SHIP_ID)>
								<!--- bu kontrolle direk siparişten olusturulmus (irsaliyeli) fatura kayıtlarına da ulaşılabiliyor. --->
								<cfquery name="control_invoice_ships" datasource="#dsn2#">
									SELECT SHIP_ID, INVOICE_ID FROM INVOICE_SHIPS WHERE SHIP_ID IN (#control_ship_list#) AND SHIP_PERIOD_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.period_id#">
								</cfquery>
								<cfif control_invoice_ships.recordcount>
									<cfset control_is_iptal_list=valuelist(control_invoice_ships.INVOICE_ID)>
									<cfquery name="control_is_iptal" datasource="#dsn2#">
										SELECT IS_IPTAL FROM INVOICE WHERE INVOICE_ID IN (#control_is_iptal_list#)
									</cfquery>
									<cfset is_iptal_count = 0>
									<cfoutput query="control_is_iptal">
										<cfif control_is_iptal.is_iptal eq 1>
											<cfset is_iptal_count = 1>
										</cfif>
									</cfoutput>
									<cfif is_iptal_count neq 1>
										<span class="basketFooterInfo"><font color="red"><cf_get_lang dictionary_id ='41227.Fatura Kesildi'>!</font></span>
									<cfelseif is_iptal_count eq 1>
										<span class="basketFooterInfo"><font color="red"><cf_get_lang dictionary_id= "58750.Fatura iptal"></font></span>
									</cfif>
								</cfif>
								<cfquery name="control_ship_result" datasource="#dsn2#"><!--- siparisin baglı oldugu irsaliyelerin sevkiyatları kontrol ediliyor --->
									SELECT
										SR.SHIP_FIS_NO,
										SR.SHIP_RESULT_ID
									FROM
										SHIP_RESULT SR,
										SHIP_RESULT_ROW SR_ROW
									WHERE
										SR.SHIP_RESULT_ID = SR_ROW.SHIP_RESULT_ID AND
										SR.IS_TYPE IS NULL AND
										SR_ROW.SHIP_ID IN (#control_ship_list#)
								</cfquery>
								<cfif control_ship_result.recordcount>
									<font color="red"><cf_get_lang dictionary_id ='41228.Sevkiyat Yapıldı'>!</font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
								</cfif>
							<cfelse>
								<cfquery name="get_ship_periods_" datasource="#dsn#">
									SELECT
										PERIOD_ID,
										PERIOD,
										PERIOD_YEAR,
										OUR_COMPANY_ID,
										PERIOD_DATE,
										OTHER_MONEY,
										RECORD_DATE,
										RECORD_IP,
										RECORD_EMP,
										UPDATE_DATE,
										UPDATE_IP,
										UPDATE_EMP,
										IS_LOCKED,
										PROCESS_DATE
									FROM
										SETUP_PERIOD
									WHERE
										PERIOD_ID
									IN
										(#ship_period_list#)
								</cfquery>
								<cfoutput query="control_order_ship">
									<cfif isdefined('control_ship_list_#period_id#')>
										<cfset 'control_ship_list_#period_id#'=listappend(evaluate('control_ship_list_#period_id#'),control_order_ship.SHIP_ID)>
									<cfelse>
										<cfset 'control_ship_list_#period_id#'=control_order_ship.SHIP_ID>
									</cfif>
								</cfoutput>
								<cfloop query="get_ship_periods_">
									<cfset new_dsn2 = '#dsn#_#get_ship_periods_.PERIOD_YEAR#_#get_ship_periods_.OUR_COMPANY_ID#'>
									<cfset control_ship_list=valuelist(control_order_ship.SHIP_ID)>
									<cfquery name="control_invoice_ships" datasource="#new_dsn2#">
										SELECT SHIP_ID FROM INVOICE_SHIPS WHERE SHIP_ID IN (#evaluate('control_ship_list_#get_ship_periods_.period_id#')#) AND SHIP_PERIOD_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_ship_periods_.period_id#">
									</cfquery>
									<cfif control_invoice_ships.recordcount>
										<span class="basketFooterInfo"><font color="red"><cf_get_lang dictionary_id ='41227.Fatura Kesildi'>!</font></span>
										<cfset is_inv=1>
									</cfif>
									<cfquery name="control_ship_result" datasource="#new_dsn2#"><!--- siparisin baglı oldugu irsaliyelerin sevkiyatları kontrol ediliyor --->
										SELECT
											SR.SHIP_FIS_NO,
											SR.SHIP_RESULT_ID
										FROM
											SHIP_RESULT SR,
											SHIP_RESULT_ROW SR_ROW
										WHERE
											SR.SHIP_RESULT_ID = SR_ROW.SHIP_RESULT_ID AND
											SR.IS_TYPE IS NULL AND
											SR_ROW.SHIP_ID IN (#evaluate('control_ship_list_#get_ship_periods_.period_id#')#)
									</cfquery>
									<cfif control_ship_result.recordcount>
										<span class="basketFooterInfo"><font color="red"><cf_get_lang dictionary_id ='41228.Sevkiyat Yapıldı'>!</font></span>
									</cfif>
									<cfif isdefined('is_inv') and is_inv eq 1>
										<cfbreak>
									</cfif>
								</cfloop>
							</cfif>
						<cfelseif control_order_invoice.recordcount>
							<span class="basketFooterInfo"><font color="red"><cf_get_lang dictionary_id ='41227.Fatura Kesildi'>!</font></span>
						</cfif>
					</cfif>
					<cfquery name="KONTROL" datasource="#dsn3#">
						SELECT PRODUCTION_ORDERS_ROW.ORDER_ID FROM PRODUCTION_ORDERS_ROW JOIN PRODUCTION_ORDERS PO ON PO.P_ORDER_ID = PRODUCTION_ORDERS_ROW.PRODUCTION_ORDER_ID WHERE PRODUCTION_ORDERS_ROW.ORDER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.order_id#">
					</cfquery>
					<cfif kontrol.recordcount>
						<span class="basketFooterInfo"><font color="red"><cf_get_lang dictionary_id ='41229.Üretim Emri Verildi'>!</font></span>
						<cfset is_basket_readonly = 1><!--- Eğer Üretim emri verilmiş ise basket satırının readonly hale gelmesi için eklendi. --->
					</cfif>
					<!--- FBS 20090610 xmle baglandi, belirtilen asamalarda butonlar gorunmeyecek --->
					<cfif len(x_showing_buttons_for_process) and ListFind(ListDeleteDuplicates(x_showing_buttons_for_process),get_order_detail.order_stage,',')>
						Bu Aşamada Butonları Göremezsiniz!
					<cfelseif get_order_detail.is_processed eq 1 or kontrol.recordcount>
						<cfif get_our_comp_inf.IS_ORDER_UPDATE eq 1 or (isdefined('is_iptal_count') and is_iptal_count eq 1)><!--- Islenmis Siparisler Guncellenebilsin --->
							<cf_workcube_buttons is_upd='1' is_delete='0' add_function='kontrol()'>
						</cfif>
					<cfelse>
						<cf_workcube_buttons is_upd = '1' add_function = 'kontrol()'>
					</cfif>
		</div>
	</cf_box_footer>
<script type="text/javascript">
	function kontrol_yurtdisi()
	{
		if(document.form_basket.is_foreign != undefined && document.form_basket.is_foreign.checked == true)
		{
			reset_basket_kdv_rates(); //kdv oranları sıfırlanıyor dsp_basket_js_scripts te tanımlı
		}	
	}
	function calc_deliver_date()
	{
		stock_id_list = '';
		var row_c = window.basket.items.length;
		if(row_c != 0)
		{
			if(row_c >= 1)
			{//1den fazla satır varsa
			
				for(var ii=0;ii<row_c;ii++)
				{
					var n_stock_id =window.basket.items[ii].STOCK_ID;
					var n_amount = filterNum(window.basket.items[ii].AMOUNT,6);
					var n_spect_id = window.basket.items[ii].SPECT_ID;
					var n_is_production = window.basket.items[ii].IS_PRODUCTION;
					if(n_spect_id == "") n_spect_id = 0;
					if(n_stock_id != "" && n_is_production ==1)//ürün silinmemiş ise
						stock_id_list +=n_stock_id+'-'+n_spect_id+'-'+n_amount+'-'+n_is_production+',';
				}
			}
			document.getElementById('deliver_date_info').style.display='';
			AjaxPageLoad(<cfoutput>'#request.self#?fuseaction=objects.popup_ajax_deliver_date_calc&stock_id_list='+stock_id_list+''</cfoutput>,'deliver_date_info',1,"<cfoutput>#getLang('','Teslim Tarihi Hesaplanyor',41164)#</cfoutput>");
		}
		else
			alert("<cfoutput>#getLang('','Ürün Seçmelisiniz',58227)#</cfoutput>");
	}
	function fill_country(member_id,type)
	{
			document.getElementById('country_id1').value='';
			document.getElementById('sales_zone_id').value='';
			if(type == 1)
			{
				<cfif isdefined("xml_emp_branch_adress") and xml_emp_branch_adress eq 1>
					get_country = wrk_safe_query("get_country_partner",'dsn',0,member_id);
				<cfelse>	
					get_country = wrk_safe_query("get_country",'dsn',0,member_id);
				</cfif>
				if(get_country.COUNTRY!='' && get_country.COUNTRY!='undefined')
					document.getElementById('country_id1').value=get_country.COUNTRY;
				if(get_country.SALES_COUNTY!='' && get_country.SALES_COUNTY!='undefined')
					document.getElementById('sales_zone_id').value=get_country.SALES_COUNTY;
			}
			else if(type == 2)
			{
				get_country = wrk_safe_query("get_country_consumer",'dsn',0,member_id);
				if(get_country.TAX_COUNTRY_ID!='' && get_country.TAX_COUNTRY_ID!='undefined')
					document.getElementById('country_id1').value=get_country.TAX_COUNTRY_ID;
				if(get_country.SALES_COUNTY!='' && get_country.TAX_COUNTRY_ID!='undefined')
					document.getElementById('sales_zone_id').value=get_country.SALES_COUNTY;

			}
	}
	function auto_sales_zone()
	{
		get_sales_zone_id = wrk_safe_query("get_sales_zone_id",'dsn',0,document.getElementById('country_id1').value);
		if(get_sales_zone_id.recordcount == 1)
		{
			document.getElementById('sales_zone_id').value = get_sales_zone_id.SZ_ID;
			return false;
		}
		else if(get_sales_zone_id.recordcount == 0)
		{
			alert("<cfoutput>#getLang('','Ülke ile İlişkili Satış Bölgesi Bulunamadı',40952)#</cfoutput>!");
			return false;
		}
		else if(get_sales_zone_id.recordcount > 1)
		{
			alert("<cfoutput>#getLang('','Ülke ile İlişkili Birden Fazla Satış Bölgesi Bulunmaktadır',40955)#</cfoutput> !");
			return false;
		}
	}
</script>