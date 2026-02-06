<cfif isdefined("attributes.subscription_id") and len(attributes.subscription_id)>
    <cfquery name="get_subscription" datasource="#dsn3#">
        SELECT SUBSCRIPTION_DETAIL,SALES_ADD_OPTION_ID FROM SUBSCRIPTION_CONTRACT WHERE SUBSCRIPTION_ID=#attributes.subscription_id# 
    </cfquery>
</cfif>

<cfoutput>
	<cf_box_elements>
		<div class="col col-12 col-md-12 col-sm-12 col-xs-12" type="column" index="1" sort="true">
			<div class="form-group col col-1 col-md-1 col-sm-6 col-xs-12" id="item-order_status">
				<label class="col col-12 col-md-12 col-sm-12 col-xs-12"><cf_get_lang dictionary_id='57493.Aktif'>
				<input type="checkbox" name="order_status" id="order_status" value="1" <cfif isdefined("get_order_detail") and get_order_detail.order_status eq 1>checked</cfif>></label>
			</div>
			<div class="form-group col col-2 col-md-2 col-sm-6 col-xs-12" id="item-reserved">
				<label class="col col-12 col-md-12 col-sm-12 col-xs-12"><cf_get_lang dictionary_id ='41185.Stok Rezerve Et'>
				<input type="checkbox" name="reserved" id="reserved" value="1" <cfif (isdefined("attributes.reserved") and attributes.reserved eq 1) or not isdefined('attributes.reserved')>checked</cfif> onClick="check_reserved_rows();"></label>
			</div>
			<cfif isdefined("xml_kdv_yd") and xml_kdv_yd eq 1>
				<div class="form-group col col-2 col-md-2 col-sm-6 col-xs-12" id="item-foreign">		            
					<label class="col col-12 col-md-12 col-sm-12 col-xs-12"><cf_get_lang dictionary_id='29692.Yurtdışı'>
					<input type="checkbox" name="is_foreign" id="is_foreign" value="1" onClick="kontrol_yurtdisi();" <cfif isdefined("attributes.is_foreign") and attributes.is_foreign eq 1> checked</cfif>></label>
				</div>
			</cfif>		
		</div>
		<div class="col col-3 col-md-4 col-sm-12" type="column" index="2" sort="true">
			<div class="form-group require" id="item-order_head">
				<label class="col col-4 col-sm-12"><cf_get_lang dictionary_id='58820.Başlık'></label>
				<div class="col col-8 col-sm-12">
					<input type="text" maxlength="200" name="order_head" id="order_head" value="<cfif isDefined("attributes.order_head") and len(attributes.order_head)>#attributes.order_head#</cfif>" required="yes">
				</div>                
			</div>
			<div class="form-group require" id="item-process_stage">
				<label class="col col-4 col-sm-12"><cf_get_lang dictionary_id="58859.Süreç"></label>
				<div class="col col-8 col-sm-12">
					<cf_workcube_process is_upd='0' process_cat_width='125' is_detail='0'>
				</div>                
			</div> 
			<div class="form-group require" id="item-company">
				<label class="col col-4 col-sm-12"><cf_get_lang dictionary_id='57519.Cari Hesap'></label>
				<div class="col col-8 col-sm-12">
					<div class="input-group">
						<input type="hidden" name="company_id" id="company_id" value="<cfif isdefined('attributes.company_id') and len(attributes.company_id)>#attributes.company_id#</cfif>">
						<input type="hidden" name="consumer_reference_code" id="consumer_reference_code" value="#attributes.consumer_reference_code#">
						<input type="hidden" name="member_type" id="member_type" value="<cfif isdefined("attributes.member_type")><cfoutput>#attributes.member_type#</cfoutput></cfif>">
						<input type="hidden" name="consumer_id" id="consumer_id" value="<cfif isdefined('attributes.consumer_id') and len(attributes.consumer_id)>#attributes.consumer_id#</cfif>">
						<cfset str_linke_ait="&field_paymethod_id=form_basket.paymethod_id&field_paymethod=form_basket.paymethod&field_comp_id=form_basket.company_id&field_partner=form_basket.partner_id&field_consumer=form_basket.consumer_id&field_comp_name=form_basket.company&field_name=form_basket.member_name&field_type=form_basket.member_type&field_revmethod_id=form_basket.paymethod_id&field_revmethod=form_basket.paymethod&field_basket_due_value_rev=form_basket.basket_due_value&field_long_address=form_basket.ship_address&field_city_id=form_basket.ship_address_city_id&field_county_id=form_basket.ship_address_county_id&field_adress_id=form_basket.ship_address_id&ship_method_id=form_basket.ship_method_id&ship_method_name=form_basket.ship_method_name&field_cons_ref_code=form_basket.consumer_reference_code&field_comp_id2=form_basket.deliver_comp_id&field_consumer2=form_basket.deliver_cons_id">
						<cfif isdefined("xml_emp_branch_adress") and xml_emp_branch_adress eq 1><cfset str_linke_ait=str_linke_ait&"&is_partner_address=1"></cfif>
						<input type="text" name="company" id="company" value="<cfif isdefined('attributes.company_id') and len(attributes.company_id)>#get_par_info(attributes.company_id,1,1,0)#</cfif>" readonly>	  
						<span class="input-group-addon btnPointer icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_pars#str_linke_ait#&field_card_payment_id=form_basket.card_paymethod_id&function_name=fill_country<cfif session.ep.isBranchAuthorization>&is_store_module=1</cfif>&select_list=2,3&call_function=add_general_prom()-check_member_price_cat()-show_member_button()-change_paper_duedate()');"></span>
					</div>
				</div>                
			</div>
			<input type="hidden" name="partner_reference_code" id="partner_reference_code" value="#attributes.partner_reference_code#">
			<input type="hidden" name="partner_id" id="partner_id" value="<cfif isdefined('attributes.partner_id') and len(attributes.partner_id)>#attributes.partner_id#<cfelseif isdefined('attributes.consumer_id') and len(attributes.consumer_id)>#attributes.consumer_id#</cfif>">		                
			<div class="form-group require" id="item-member_name">
				<label class="col col-4 col-sm-12"><cf_get_lang dictionary_id='57578.Yetkili'></label>
				<div class="col col-8 col-sm-12">
				<input type="text" name="member_name" id="member_name" value="<cfif isdefined('attributes.partner_id') and len(attributes.partner_id)>#get_par_info(attributes.partner_id,0,-1,0)#<cfelseif isdefined('attributes.consumer_id') and len(attributes.consumer_id)>#get_cons_info(attributes.consumer_id,0,0,0)#</cfif>">
				</div>                
			</div>
			<div class="form-group require" id="item-offer_head">
				<label class="col col-4 col-sm-12"><cf_get_lang dictionary_id='57545.Teklif'></label>
				<div class="col col-8 col-sm-12">
					<div class="input-group">
						<input type="hidden" name="offer_id" id="offer_id" value="<cfif isdefined('attributes.offer_id') and len(attributes.offer_id)>#attributes.offer_id#</cfif>">
						<input type="text" name="offer_head" id="offer_head" value="<cfif isdefined('attributes.offer_head') and len(attributes.offer_head)>#attributes.offer_head#</cfif>">
						<span class="input-group-addon icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=sales.popup_list_offers&field_offer_id=form_basket.offer_id&field_offer_number=form_basket.offer_head&field_member_id=form_basket.partner_id&field_member_name=form_basket.member_name&field_member_company=form_basket.company&field_member_company_id=form_basket.company_id&field_member_consumer_id=form_basket.consumer_id');"></span>
					</div>
				</div>                
			</div>
			<div class="form-group require" id="item-order_employee">
				<label class="col col-4 col-sm-12"><cf_get_lang dictionary_id='41159.Satış Çalışanı'></label>
				<div class="col col-8 col-sm-12">
					<div class="input-group">
						<input type="hidden" name="order_employee_id" id="order_employee_id" value="<cfif Len(attributes.order_employee_id)>#attributes.order_employee_id#</cfif>">
						<input type="text" name="order_employee" id="order_employee" value="<cfif Len(attributes.order_employee_id)>#get_emp_info(attributes.order_employee_id,0,0)#</cfif>" onFocus="AutoComplete_Create('order_employee','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','3','EMPLOYEE_ID','order_employee_id','','3','125');" autocomplete="off">
						<cfif session.ep.isBranchAuthorization>
							<span class="input-group-addon icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_positions&field_emp_id=form_basket.order_employee_id&field_name=form_basket.order_employee&is_store_module=1&select_list=1');"></span>
						<cfelse>
							<span class="input-group-addon icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_positions&field_emp_id=form_basket.order_employee_id&field_name=form_basket.order_employee&select_list=1');"></span>
						</cfif>
					</div>
				</div>                
			</div>
			<div class="form-group require" id="item-sales_member">
				<label class="col col-4 col-sm-12"><cf_get_lang dictionary_id='40904.Satış Ortağı'></label>
				<div class="col col-8 col-sm-12">
					<div class="input-group">
						<input type="hidden" name="sales_member_id" id="sales_member_id" value="<cfif isdefined('attributes.sales_member_id') and len(attributes.sales_member_id)>#attributes.sales_member_id#</cfif>">
						<input type="hidden" name="sales_member_type" id="sales_member_type" value="<cfif isdefined('attributes.sales_member_type') and len(attributes.sales_member_type)>#attributes.sales_member_type#</cfif>">
						<input type="text" name="sales_member" id="sales_member" placeholder="<cfoutput>#getLang(102,'Satış Ortağı',40904)#</cfoutput>" value="<cfif isdefined('attributes.sales_member') and len(attributes.sales_member)>#attributes.sales_member#</cfif>" onFocus="AutoComplete_Create('sales_member','MEMBER_NAME,MEMBER_PARTNER_NAME','MEMBER_PARTNER_NAME2,MEMBER_NAME2','get_member_autocomplete','\'1,2\',0,0,0','PARTNER_CODE,MEMBER_TYPE','sales_member_id,sales_member_type','','3','250');" autocomplete="off">
						<cfif session.ep.isBranchAuthorization>
							<span class="input-group-addon icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_pars&is_rate_select=1&field_id=form_basket.sales_member_id&field_name=form_basket.sales_member&field_type=form_basket.sales_member_type&is_store_module=1&select_list=2,3');"></span>
						<cfelse>
							<span class="input-group-addon icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_pars&is_rate_select=1&field_id=form_basket.sales_member_id&field_name=form_basket.sales_member&field_type=form_basket.sales_member_type&select_list=2,3');"></span>
						</cfif>
					</div>
				</div>                
			</div>
		</div>
		<div class="col col-3 col-md-4 col-sm-12" type="column" index="3" sort="true">
			<div class="form-group require" id="item-order_date">
				<label class="col col-4 col-sm-12"><cf_get_lang dictionary_id='29501.Sipariş Tarihi'></label>
				<div class="col col-8 col-sm-12">
					<div class="input-group">
						<cfsavecontent variable="message"><cf_get_lang dictionary_id='38654.Sipariş Tarihi Girmelisiniz'> !</cfsavecontent>
						<cfinput type="text" name="order_date" id="order_date" required="yes" value="#attributes.order_date#" validate="#validate_style#" message="#message#" maxlength="10" readonly="yes" onblur="add_general_prom();change_money_info('form_basket','order_date','')">
						<span class="input-group-addon"><cf_wrk_date_image date_field="order_date" call_function="add_general_prom&change_money_info"></span>
					</div>
				</div>                
			</div>
			<div class="form-group require" id="item-ship_date">
				<label class="col col-4 col-sm-12"><cf_get_lang dictionary_id='40834.Sevk Tarihi'></label>
				<div class="col col-8 col-sm-12">
					<div class="input-group">
						<cfsavecontent variable="message"><cf_get_lang dictionary_id='40895.Sevk Tarihi Girmelisiniz'>!</cfsavecontent>
						<cfinput type="text" name="ship_date" id="ship_date" value="#attributes.ship_date#" validate="#validate_style#" message="#message#" maxlength="10">
						<span class="input-group-addon"><cf_wrk_date_image date_field="ship_date"></span>
					</div>
				</div>                
			</div>
			<div class="form-group require" id="item-deliverdate">
				<label class="col col-4 col-sm-12"><cf_get_lang dictionary_id='57645.Teslim Tarihi'></label>
				<div class="col col-8 col-sm-12">
					<div class="input-group">
						<cfinput type="text" name="deliverdate" id="deliverdate" value="#attributes.deliverdate#" validate="#validate_style#" maxlength="10" onblur="apply_deliver_date('deliverdate');">
						<span class="input-group-addon"><cf_wrk_date_image date_field="deliverdate" call_function="add_general_prom&apply_deliver_date('deliverdate')"></span>
						<cfif isdefined('is_termin_calc') and is_termin_calc eq 1>
							<span class="input-group-addon btnPointer icon-cogs" onClick="calc_deliver_date();"></span>
							<div style="position:absolute;z-index:9999999" id="deliver_date_info"></div>
						</cfif>
					</div>
				</div>                
			</div>
			<div class="form-group require" id="item-project_head">
				<label class="col col-4 col-sm-12"><cf_get_lang dictionary_id='57416.Proje'></label>
				<div class="col col-8 col-sm-12">
					<div class="input-group">
						<input type="hidden" name="project_id" id="project_id" value="<cfif isdefined('attributes.project_id') and len(attributes.project_id)>#attributes.project_id#</cfif>"> 
						<cfset str_linke_ait_prj="&comp_id='+document.form_basket.company_id.value+'&cons_id='+document.form_basket.consumer_id.value+'&comp_name='+document.form_basket.company.value+'&mem_type='+document.form_basket.member_type.value+'">
						<input type="text" placeholder="<cfoutput>#getLang(4,'Proje',57416)#</cfoutput>" name="project_head" id="project_head" value="<cfif isdefined('attributes.project_id') and len(attributes.project_id)>#get_project_name(attributes.project_id)#</cfif>" onFocus="AutoComplete_Create('project_head','PROJECT_ID,PROJECT_HEAD','PROJECT_HEAD','get_project','','PROJECT_ID','project_id','form_basket','3','200')"autocomplete="off">
						<span class="input-group-addon btnPointer icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_projects#str_linke_ait_prj#&project_id=form_basket.project_id&project_head=form_basket.project_head&paymethod=form_basket.paymethod&paymethod_id=form_basket.paymethod_id&card_paymethod_id=form_basket.card_paymethod_id&dueday=form_basket.basket_due_value&commission_rate=form_basket.commission_rate&paymethod_vehicle=form_basket.paymethod_vehicle&function_name=change_paper_duedate');"></span>
						<span class="input-group-addon btnPointer icon-question" onClick="if(document.getElementById('project_id').value!='')windowopen('#request.self#?fuseaction=project.popup_list_project_actions&from_paper=ORDERS&id='+document.getElementById('project_id').value+'','horizantal');else alert('<cf_get_lang dictionary_id='58797.Proje Seçiniz'> !');"></span>
					</div>
				</div>                
			</div> 
			<div class="form-group require" id="item-work_head">
				<label class="col col-4 col-sm-12"><cf_get_lang dictionary_id='58445.İş'></label>
				<div class="col col-8 col-sm-12">
					<div class="input-group">
						<input type="hidden" name="work_id" id="work_id" value="<cfif isdefined("attributes.work_id") and len(attributes.work_id)>#attributes.work_id#</cfif>">
						<input type="text" name="work_head" id="work_head" value="<cfif isdefined("attributes.work_id") and len(attributes.work_id)>#get_work_name(attributes.work_id)#</cfif>">
						<span class="input-group-addon icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_add_work&field_id=form_basket.work_id&field_name=form_basket.work_head');"></span>
					</div>
				</div>                
			</div> 
			<div class="form-group require" id="item-commethod_id">
				<label class="col col-4 col-sm-12"><cf_get_lang dictionary_id='58143.İletişim'></label>
				<div class="col col-8 col-sm-12">
					<select name="commethod_id" id="commethod_id">
						<option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
						<cfloop query="get_commethod_cats">
							<option value="#commethod_id#" <cfif isdefined('attributes.commethod_id') and attributes.commethod_id eq commethod_id>selected</cfif>>#commethod#</option>
						</cfloop>
					</select>
				</div>                
			</div>
			<cfif session.ep.our_company_info.subscription_contract eq 1>
				<div class="form-group require" id="item-sales_add_option">
					<label class="col col-4 col-sm-12"><cf_get_lang dictionary_id ='41142.Satış Özel Tanım'></label>
					<div class="col col-8 col-sm-12">
						<cfinclude template="../query/get_sale_add_option.cfm">
						<select name="sales_add_option" id="sales_add_option">
							<option value=""><cf_get_lang dictionary_id ='57734.Seçiniz'></option>
							<cfloop query="get_sale_add_option">
								<option value="#sales_add_option_id#" <cfif isdefined('attributes.sales_add_option_id') and attributes.sales_add_option_id eq sales_add_option_id>selected <cfelseif isdefined("get_subscription.sales_add_option_id") and get_subscription.sales_add_option_id eq sales_add_option_id>selected</cfif>>#sales_add_option_name#</option>
							</cfloop>
						</select>
					</div>                
				</div>
			</cfif> 
		</div>  
		<div class="col col-3 col-md-4 col-sm-12" type="column" index="4" sort="true">
			<div class="form-group require" id="item-deliver_dept_name">
				<label class="col col-4 col-sm-12"><cf_get_lang dictionary_id='58763.Depo'></label>
				<div class="col col-8 col-sm-12">
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
						width="140">
				</div>                
			</div>
			<div class="form-group require" id="item-ship_method_name">
				<label class="col col-4 col-sm-12"><cf_get_lang dictionary_id='29500.Sevk Yöntemi'></label>
				<div class="col col-8 col-sm-12">
					<div class="input-group">
						<cfif isdefined("attributes.ship_method_id") and len(attributes.ship_method_id)>
							<cfset attributes.ship_method=attributes.ship_method_id>
							<cfinclude template="../query/get_ship_method.cfm">
							<cfset ship_method = get_ship_method.ship_method>
							<cfset ship_method_id = attributes.ship_method_id>
						</cfif>
						<input type="hidden" name="ship_method_id" id="ship_method_id" value="<cfif isdefined("ship_method_id") and len(ship_method_id)>#ship_method_id#</cfif>">
						<input type="text" name="ship_method_name" placeholder="<cfoutput>#getLang(1703,'Sevk Yöntemi',29500)#</cfoutput>" id="ship_method_name" value="<cfif isdefined("attributes.ship_method_name")><cfoutput>#attributes.ship_method_name#</cfoutput><cfelseif isdefined("ship_method") and len(ship_method)>#ship_method#</cfif>" onFocus="AutoComplete_Create('ship_method_name','SHIP_METHOD','SHIP_METHOD','get_ship_method','','SHIP_METHOD_ID','ship_method_id','','3','125');" autocomplete="off">
						<span class="input-group-addon icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_ship_methods&field_name=ship_method_name&field_id=ship_method_id','','ui-draggable-box-small');"></span>
					</div>
				</div>                
			</div>
			<div class="form-group require" id="item-ship_address">
				<label class="col col-4 col-sm-12"><cf_get_lang dictionary_id='58449.Teslim Yeri'></label>
				<div class="col col-8 col-sm-12">
					<div class="input-group">
					<!--- Uye Bilgilerinden gelindiginde teslim yeri alaninin dolu gelmesi icin eklendi --->
						<cfif isdefined('attributes.company_id') and len(attributes.company_id) and not isdefined("attributes.ship_address")><!--- Siparis kopyalandiginda yanlis adres yaziyordu ship_address yazildi --->
							<cfquery name="get_ship_address" datasource="#dsn#">
								SELECT
									TOP 1 *
								FROM
									(	SELECT 0 AS TYPE,COMPBRANCH_ID,COMPBRANCH_ADDRESS AS ADDRESS,POS_CODE,SEMT,COUNTY_ID AS COUNTY,CITY_ID AS CITY,COUNTRY_ID AS COUNTRY FROM COMPANY_BRANCH WHERE IS_SHIP_ADDRESS = 1 AND COMPANY_ID = #attributes.company_id# 
										UNION
										SELECT 1 AS TYPE,-1 COMPBRANCH_ID,COMPANY_ADDRESS AS ADDRESS,POS_CODE,SEMT,COUNTY,CITY,COUNTRY FROM COMPANY WHERE COMPANY_ID = #attributes.company_id#
									) AS TYPE
								ORDER BY
									TYPE 
							</cfquery>
							<cfset address_ = get_ship_address.address>
							<cfset attributes.ship_address_id_ = get_ship_address.COMPBRANCH_ID>
							<cfif len(get_ship_address.pos_code) and len(get_ship_address.semt)>
								<cfset address_ = "#address_# #get_ship_address.pos_code# #get_ship_address.semt#">
							</cfif>
							<cfif len(get_ship_address.county)>
								<cfquery name="get_county_name" datasource="#dsn#">
									SELECT COUNTY_ID,COUNTY_NAME FROM SETUP_COUNTY WHERE COUNTY_ID = #get_ship_address.county#
								</cfquery>
								<cfset attributes.ship_address_county_id = get_county_name.county_id>
								<cfset address_ = "#address_# #get_county_name.county_name#">
							</cfif>
							<cfif len(get_ship_address.city)>
								<cfquery name="get_city_name" datasource="#dsn#">
									SELECT CITY_ID,CITY_NAME FROM SETUP_CITY WHERE CITY_ID = #get_ship_address.city#
								</cfquery>
								<cfset attributes.ship_city_id = get_city_name.city_id>
								<cfset address_ = "#address_# #get_city_name.city_name#">
							</cfif>
							<cfif len(get_ship_address.country)>
								<cfquery name="get_country_name" datasource="#dsn#">
									SELECT COUNTRY_NAME FROM SETUP_COUNTRY WHERE COUNTRY_ID = #get_ship_address.country#
								</cfquery>
								<cfset address_ = "#address_# #get_country_name.country_name#">
							</cfif>
						<cfelseif isdefined("attributes.ship_address")>
							<cfset address_ = attributes.ship_address>
						</cfif>
						<!--- //Uye Bilgilerinden gelindiginde teslim yeri alaninin dolu gelmesi icin eklendi --->
						<input type="hidden" name="ship_address_city_id" id="ship_address_city_id" value="<cfif isdefined('attributes.ship_city_id') and len(attributes.ship_city_id)>#attributes.ship_city_id#</cfif>">
						<input type="hidden" name="ship_address_county_id" id="ship_address_county_id" value="<cfif isDefined("attributes.ship_address_county_id") and len(attributes.ship_address_county_id)>#attributes.ship_address_county_id#</cfif>">
						<input type="hidden" name="deliver_comp_id" id="deliver_comp_id" value="<cfif isdefined('attributes.deliver_comp_id') and len(attributes.deliver_comp_id)>#attributes.deliver_comp_id#</cfif>">
						<input type="hidden" name="deliver_cons_id" id="deliver_cons_id" value="<cfif isDefined("attributes.deliver_cons_id") and len(attributes.deliver_cons_id)>#attributes.deliver_cons_id#</cfif>">
						<input type="hidden" name="ship_address_id" id="ship_address_id" value="<cfif isdefined('attributes.ship_address_id_') and len(attributes.ship_address_id_)>#attributes.ship_address_id_#</cfif>">
						<input type="text" name="ship_address" id="ship_address" maxlength="500" value="<cfif isdefined('address_') and len(address_)>#address_#</cfif>">
						<span class="input-group-addon icon-ellipsis" onClick="add_adress();"></span>
					</div>
				</div>                
			</div>  
			<div class="form-group require" id="item-paymethod">
				<label class="col col-4 col-sm-12"><cf_get_lang dictionary_id='58516.Ödeme Yontemi'></label>
				<div class="col col-8 col-sm-12">
					<div class="input-group">
						<cfif isdefined("attributes.paymethod_id") and len(attributes.paymethod_id)>
							<cfinclude template="../query/get_paymethod.cfm">
							<cfset paymethod_vehicle = get_paymethod.payment_vehicle>
							<cfset paymethod_id = get_paymethod.paymethod_id>
							<cfset paymethod = get_paymethod.paymethod>
							<cfset card_paymethod_id = ''>
							<cfset commission_rate = ''>
							<cfset attributes.basket_due_value = get_paymethod.due_day>
							<cfif Len(get_paymethod.due_day)>
								<cfif get_paymethod.is_due_endofmonth eq 1><!--- Vade Aysonundan Baslasin Icin Ayin Son Gunu Atanir --->
									<cfif xml_sales_delivery_date_calculated eq 0>
										<cfset attributes.basket_due_value_date_ = CreateDate(Year(attributes.order_date),Month(attributes.order_date),DaysInMonth(attributes.order_date))>
										<cfset attributes.basket_due_value = attributes.basket_due_value + DateDiff('d',attributes.order_date,attributes.basket_due_value_date_)>
									<cfelse>
										<cfset attributes.basket_due_value_date_ = CreateDate(Year(attributes.deliverdate),Month(attributes.deliverdate),DaysInMonth(attributes.deliverdate))>
										<cfset attributes.basket_due_value = attributes.basket_due_value + DateDiff('d',attributes.deliverdate,attributes.basket_due_value_date_)>
									</cfif>
								</cfif>
								<cfset attributes.basket_due_value_date_ = DateFormat(date_add('d',get_paymethod.due_day,attributes.basket_due_value_date_),dateformat_style)>
							</cfif>
						<cfelseif isdefined("attributes.card_paymethod_id") and len(attributes.card_paymethod_id)>
							<cfquery name="get_card_paymethod" datasource="#dsn3#">
								SELECT CARD_NO, COMMISSION_MULTIPLIER, PAYMENT_TYPE_ID FROM CREDITCARD_PAYMENT_TYPE WHERE PAYMENT_TYPE_ID = #attributes.card_paymethod_id#
							</cfquery>
							<cfset paymethod_vehicle = ''>
							<cfset paymethod_id = ''>
							<cfset paymethod = get_card_paymethod.card_no>
							<cfset card_paymethod_id = get_card_paymethod.payment_type_id>
							<cfset commission_rate = get_card_paymethod.commission_multiplier>
						<cfelse>
							<cfset paymethod_vehicle = ''>
							<cfset paymethod_id = ''>
							<cfset paymethod = ''>
							<cfset card_paymethod_id = ''>
							<cfset commission_rate = ''>
							<!--- Odeme Yontemi Yoksa Kurumsal veya Bireysel Oyelerdeki Yontemleri Kontrol Edilir --->
							<cfif (isDefined("attributes.company_id") and Len(attributes.company_id)) or (isDefined("attributes.consumer_id") and Len(attributes.consumer_id))>
								<cfset get_member_payment_method = createObject("component","V16.objects.cfc.getMemberPaymentMethod").getMemberPaymentMethod(dsn:dsn,is_sales_type:1,our_company_id:session.ep.company_id,company_id:iif(isDefined("attributes.company_id"),"attributes.company_id",""),consumer_id:iif(isDefined("attributes.consumer_id"),"attributes.consumer_id",""))>
								<cfif get_member_payment_method.recordcount>
									<cfset paymethod_id = get_member_payment_method.payment_method_id>
									<cfset card_paymethod_id = get_member_payment_method.card_payment_method_id>
									<cfset commission_rate = get_member_payment_method.commission_multiplier>
									<cfset paymethod_vehicle = get_member_payment_method.payment_vehicle>
									<cfset paymethod = get_member_payment_method.payment_method_name>
									<cfset attributes.basket_due_value = get_member_payment_method.due_day>
									<cfif Len(get_member_payment_method.due_day)>
										<cfset attributes.basket_due_value_date_ = DateFormat(DateAdd('d',get_member_payment_method.due_day,attributes.order_date),dateformat_style)>
									</cfif>
								</cfif>
							</cfif>
						</cfif>
						<!--- kredi kartı odeme yontemi bilgileri --->
						<input type="hidden" name="card_paymethod_id" id="card_paymethod_id" value="#card_paymethod_id#">
						<input type="hidden" name="commission_rate" id="commission_rate" value="#commission_rate#">
						<!---//kredi kartı odeme yontemi bilgileri --->
						<input type="hidden" name="paymethod_vehicle" id="paymethod_vehicle" value="#paymethod_vehicle#">
						<input type="hidden" name="paymethod_id" id="paymethod_id" value="#paymethod_id#">
						<cfset card_link="&field_card_payment_id=form_basket.card_paymethod_id&field_card_payment_name=form_basket.paymethod&field_commission_rate=form_basket.commission_rate&field_paymethod_vehicle=form_basket.paymethod_vehicle">
						<input type="text" name="paymethod" id="paymethod" value="#paymethod#" placeholder="<cfoutput>#getLang('main',1104)#</cfoutput>" onFocus="AutoComplete_Create('paymethod','PAYMETHOD','PAYMETHOD','get_paymethod','\'1,2\'','PAYMENT_TYPE_ID,COMMISSION_MULTIPLIER,PAYMETHOD_ID,PAYMENT_VEHICLE','card_paymethod_id,commission_rate,paymethod_id,paymethod_vehicle','','3','200');" autocomplete="off">
						<span class="input-group-addon btnPointer icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_paymethods&function_name=change_paper_duedate&function_parameter=<cfif xml_sales_delivery_date_calculated>deliverdate<cfelse>order_date</cfif>&field_id=form_basket.paymethod_id&field_name=form_basket.paymethod&field_dueday=form_basket.basket_due_value#card_link#');"></span>
					</div>
				</div>                
			</div> 
			<div class="form-group require" id="item-basket_due_value">
				<label class="col col-4 col-sm-12"><cf_get_lang dictionary_id ='57640.Vade'></label>
				<div class="col col-3 col-sm-6">
					<cfif xml_sales_delivery_date_calculated eq 0>
						<input type="text" name="basket_due_value" id="basket_due_value" value="<cfif isdefined("attributes.basket_due_value") and len(attributes.basket_due_value)>#attributes.basket_due_value#</cfif>"  onChange="change_paper_duedate('order_date');" onKeyUp="isNumber(this);">
					<cfelse>
						<input type="text" name="basket_due_value" id="basket_due_value" value="<cfif isdefined("attributes.basket_due_value") and len(attributes.basket_due_value)>#attributes.basket_due_value#</cfif>"  onChange="change_paper_duedate('deliverdate');" onKeyUp="isNumber(this);">
					</cfif>
				</div>    
				<div class="col col-5 col-sm-6"> 
					<div class="input-group">        
						<cfif xml_sales_delivery_date_calculated eq 0>
							<cfinput type="text" name="basket_due_value_date_" id="basket_due_value_date_" value="#DateFormat(attributes.basket_due_value_date_,dateformat_style)#" onChange="change_paper_duedate('order_date',1);" validate="#validate_style#" message="#message#" maxlength="10" readonly>
							<span class="input-group-addon"><cf_wrk_date_image date_field="basket_due_value_date_"></span>
						<cfelse>
							<cfinput type="text" name="basket_due_value_date_" id="basket_due_value_date_" value="#DateFormat(attributes.basket_due_value_date_,dateformat_style)#" onChange="change_paper_duedate('deliverdate',1);" validate="#validate_style#" message="#message#" maxlength="10" readonly>
							<span class="input-group-addon"><cf_wrk_date_image date_field="basket_due_value_date_"></span>
						</cfif>
					</div>                
				</div>
			</div>  
			<div class="form-group require" id="item-country_id1">
				<label class="col col-4 col-sm-12"><cf_get_lang dictionary_id ='58219.Ulke'></label>
				<div class="col col-8 col-sm-12">
					<select name="country_id1" id="country_id1" onchange="auto_sales_zone();">
						<option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
						<cfloop query="get_country_1">
							<option value="#country_id#" <cfif attributes.country_id1 eq country_id> selected </cfif>>#country_name#</option>
						</cfloop>
					</select>
				</div>                
			</div>     
			<div class="form-group require" id="item-sales_zone_id">
				<label class="col col-4 col-sm-12"><cf_get_lang dictionary_id ='57659.Satis bolgesi'></label>
				<div class="col col-8 col-sm-12">
					<select name="sales_zone_id" id="sales_zone_id">
						<option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
						<cfloop query="get_sale_zones">
							<option value="#sz_id#" <cfif attributes.sales_zone_id eq sz_id> selected </cfif>>#sz_name#</option>
						</cfloop>
					</select>
				</div>                
			</div> 
			<cfif session.ep.our_company_info.subscription_contract eq 1>
				<div class="form-group require" id="item-camp_id">
					<label class="col col-4 col-sm-12"><cf_get_lang dictionary_id='29502.Abone No'></label>
					<div class="col col-8 col-sm-12">
						<cfif isDefined("attributes.subscription_id")>
							<cf_wrk_subscriptions subscription_id='#attributes.subscription_id#' width_info='140' fieldId='subscription_id' fieldName='subscription_no' form_name='form_basket' img_info='plus_thin'>
						<cfelseif isDefined("attributes.related_subs_id") and len(attributes.related_subs_id)>
							<cf_wrk_subscriptions subscription_id='#attributes.related_subs_id#' width_info='140' fieldId='subscription_id' fieldName='subscription_no' form_name='form_basket' img_info='plus_thin'>
						<cfelseif isdefined("attributes.subscription") and len(attributes.subscription)>
							<cf_wrk_subscriptions width_info='140' subscription_id='#attributes.subscription#'  fieldid='subscription_id' fieldname='subscription_no' form_name='form_basket' img_info='plus_thin'>
						<cfelse>
							<cf_wrk_subscriptions width_info='140' fieldId='subscription_id' fieldName='subscription_no' form_name='form_basket' img_info='plus_thin'>
						</cfif>
					</div>                
				</div> 
			</cfif>
		</div>
		<div class="col col-3 col-md-4 col-sm-12" type="column" index="5" sort="true">
			<div class="form-group require" id="item-detail">
				<label class="col col-4 col-sm-12"><cf_get_lang dictionary_id='57629.Açıklama'></label>
				<div class="col col-8 col-sm-12">
					<textarea name="detail" id="detail"><cfif isdefined("attributes.order_detail") and len(attributes.order_detail)>#attributes.order_detail#<cfelseif isdefined("get_subscription.subscription_detail") and len(get_subscription.subscription_detail)>#get_subscription.subscription_detail#</cfif></textarea>
				</div>                
			</div> 
			<div class="form-group require" id="item-ref_company">
				<label class="col col-4 col-sm-12"><cf_get_lang dictionary_id='58784.Referans'></label>
				<div class="col col-8 col-sm-12">
					<div class="input-group">
						<input type="hidden" name="ref_company_id" id="ref_company_id" value="<cfif isdefined("attributes.ref_company_id") and len(attributes.ref_company_id)>#attributes.ref_company_id#</cfif>">								  
						<input type="hidden" name="ref_member_type" id="ref_member_type" value="<cfif isdefined("attributes.ref_member_type") and len(attributes.ref_member_type)>#attributes.ref_member_type#</cfif>">
						<input type="text" name="ref_company" placeholder="<cfoutput>#getLang(1372,'Referans',58784)#</cfoutput>" id="ref_company" value="<cfif isdefined('attributes.ref_company') and len(attributes.ref_company)>#attributes.ref_company#</cfif>" onFocus="AutoComplete_Create('ref_company','MEMBER_NAME,MEMBER_PARTNER_NAME','MEMBER_NAME2,MEMBER_PARTNER_NAME2','get_member_autocomplete','\'1,2\'','COMPANY_ID,MEMBER_TYPE,PARTNER_CODE,MEMBER_PARTNER_NAME2','ref_company_id,ref_member_type,ref_member_id,ref_member','','3','250');" autocomplete="off">
						<span class="input-group-addon btnPointer icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_all_pars&is_rate_select=1&field_partner=form_basket.ref_member_id&field_consumer=form_basket.ref_member_id&field_comp_id=form_basket.ref_company_id&field_comp_name=form_basket.ref_company&field_name=form_basket.ref_member&field_type=form_basket.ref_member_type<cfif session.ep.isBranchAuthorization>&is_store_module=1</cfif>&select_list=7,8');"></span>
					</div>
				</div>                
			</div> 
			<div class="form-group require" id="item-ref_no">
				<label class="col col-4 col-sm-12"><cf_get_lang dictionary_id='58794.Referans No'></label>
				<div class="col col-8 col-sm-12">
					<input type="text" name="ref_no" id="ref_no" value="<cfif isdefined('attributes.ref_no') and len(attributes.ref_no)>#attributes.ref_no#</cfif>" maxlength="50">
				</div>                
			</div>
			<div class="form-group require" id="item-ref_member">
				<label class="col col-4 col-sm-12"><cf_get_lang dictionary_id='57578.Yetkili'></label>
				<div class="col col-8 col-sm-12">
					<input type="hidden" name="ref_member_id" id="ref_member_id" value="<cfif isdefined("attributes.ref_member_id") and len(attributes.ref_member_id)>#attributes.ref_member_id#</cfif>">
					<input type="text" name="ref_member" id="ref_member" value="<cfif isdefined('attributes.ref_member') and len(attributes.ref_member)>#attributes.ref_member#</cfif>" readonly>
				</div>                
			</div> 
			<div class="form-group require" id="item-priority_id">
				<label class="col col-4 col-sm-12"><cf_get_lang dictionary_id ='57485.Öncelik'></label>
				<div class="col col-8 col-sm-12">
					<select name="priority_id" id="priority_id">
						<cfloop query="get_priorities">
							<option value="#priority_id#" <cfif (isdefined("attributes.priority_id") and attributes.priority_id eq priority_id) or (not isdefined("attributes.priority_id") and priority_id eq 1)>selected</cfif>>#priority#</option>
						</cfloop>
					</select>
				</div>                
			</div> 
			<div class="form-group require" id="item-camp_name">
				<label class="col col-4 col-sm-12"><cf_get_lang dictionary_id='57446.Kampanya'></label>
				<div class="col col-8 col-sm-12">
					<div class="input-group">
						<cfoutput>
							<input type="hidden" name="camp_id" id="camp_id" value="">
							<input type="text" name="camp_name" id="camp_name" value="">
							<span class="input-group-addon icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_campaigns&field_id=form_basket.camp_id&field_name=form_basket.camp_name');"></span>
						</div>
					</cfoutput>
				</div>                
			</div> 
			<div class="form-group" id="item-cf_wrk_add_info">
				<label class="col col-4 col-xs-12"><cfoutput>#getLang(398,'Ek Bilgi',57810)#</cfoutput></label>
				<div class="col col-8 col-xs-12"> 
				<cfif isdefined("attributes.order_id") and len(attributes.order_id)>
						<cf_wrk_add_info info_type_id="-7" upd_page = "1" info_id = "#attributes.order_id#"> 
				<cfelse>
						<cf_wrk_add_info info_type_id="-7" upd_page = "0"> 
					</cfif>
				</div>
			</div>
		</div>      
	</cf_box_elements>
	<cf_box_footer>
		<cf_basket_form_button>
			<cf_workcube_buttons is_upd='0' add_function='kontrol()' >
		</cf_basket_form_button>
	</cf_box_footer>
</cfoutput>      
<script type="text/javascript">
	function kontrol_yurtdisi()
		{
			if ($('#is_foreign:checked').val() !== undefined)  reset_basket_kdv_rates();
		}
    function calc_deliver_date()
	{
		stock_id_list = '';
		var row_c = window.basket.items.length;
		if(row_c != 0)
		{
			if(row_c >= 1)
			{
			
				for(var ii=0;ii<row_c;ii++)
				{
					var n_stock_id =window.basket.items[ii].STOCK_ID[ii];
					var n_amount = filterNum(window.basket.items[ii].AMOUNT[ii],6);
					var n_spect_id = window.basket.items[ii].SPECT_ID[ii];
					var n_is_production = window.basket.items[ii].IS_PRODUCTION[ii];
					if(n_spect_id == "") n_spect_id =0;
					if(n_stock_id != "" && n_is_production ==1)//ürün silinmemiş ise
						stock_id_list +=n_stock_id+'-'+n_spect_id+'-'+n_amount+'-'+n_is_production+',';
				}
			}
			
			document.getElementById('deliver_date_info').style.display='';
			AjaxPageLoad(<cfoutput>'#request.self#?fuseaction=objects.popup_ajax_deliver_date_calc&stock_id_list='+stock_id_list+''</cfoutput>,'deliver_date_info',1,"<cfoutput>#getLang('','Teslim Tarihi Hesaplanıyor',41164)#</cfoutput>");
		}
		else
			alert("<cfoutput>#getLang('','Ürün Seçmelisiniz',58227)#</cfoutput>");
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
			alert("<cfoutput>#getLang('','Ülke ile İlişkili Birden Fazla Satış Bölgesi Bulunmaktadır',40955)#</cfoutput>!");
			return false;
		}
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
</script>