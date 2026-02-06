<cfif (xml_member_info_from_project eq 1 or not isdefined("attributes.offer_id")) and isdefined("attributes.project_id") and len(attributes.project_id)>
    <!--- FBS proje aksiyonlardan eklendiginde standart proje ve uye bilgilerin gelmesi icin eklendi --->
        <cfquery name="get_project_info" datasource="#dsn#">
            SELECT COMPANY_ID,PARTNER_ID,CONSUMER_ID,PROJECT_ID FROM PRO_PROJECTS WHERE PROJECT_ID = #attributes.project_id#
        </cfquery>
        <cfif len(get_project_info.company_id)>
            <cfset attributes.company_id = get_project_info.company_id>
            <cfset attributes.partner_id = get_project_info.partner_id>
        <cfelseif len(get_project_info.consumer_id)>
            <cfset attributes.consumer_id = get_project_info.consumer_id>
        </cfif>
    </cfif>
    <cfoutput>
            <cf_box_elements>
                <div class="col col-3 col-md-4 col-sm-6 col-sm-12" type="column" index="1" sort="true">
                    <div class="form-group" id="item-offer_head">
                        <label class="col col-4 col-sm-12"><cf_get_lang dictionary_id='58820.Başlık'></label>
                        <div class="col col-8 col-sm-12">
                            <cfinput type="text" name="offer_head" value="#attributes.subject#" maxlength="200" required="yes" message="#getLang('','Başlık Girmelisiniz',58059)# !">
                        </div>
                    </div>
                    <div class="form-group" id="item-process_stage">
                        <label class="col col-4 col-sm-12"><cf_get_lang dictionary_id="58859.Süreç"></label>
                        <div class="col col-8 col-sm-12">
                            <cf_workcube_process is_upd='0' process_cat_width='130' is_detail='0'>
                        </div>
                    </div>
                    <div class="form-group" id="item-member_name">
                        <label class="col col-4 col-sm-12"><cf_get_lang dictionary_id='57457.Müşteri'> *</label>
                        <div class="col col-8 col-sm-12">
                            <div class="input-group">
                                <cfset str_linkeait="&field_revmethod_id=form_basket.paymethod_id&field_revmethod=form_basket.pay_method&ship_method_id=form_basket.ship_method_id&ship_method_name=form_basket.ship_method_name">
                                <input type="hidden" name="partner_id" id="partner_id" value="<cfif isdefined("attributes.partner_id") and len(attributes.partner_id)>#attributes.partner_id#</cfif>">
                                <input type="hidden" name="company_id" id="company_id" value="<cfif isdefined("attributes.company_id") and len(attributes.company_id)>#attributes.company_id#</cfif>">
                                <input type="hidden" name="consumer_id" id="consumer_id" value="<cfif isdefined("attributes.consumer_id") and len(attributes.consumer_id)>#attributes.consumer_id#</cfif>">
                                <input type="text" name="member_name" id="member_name" readonly onfocus="fill_country()" value="<cfif isdefined("attributes.company_id") and len(attributes.company_id)>#get_par_info(attributes.company_id,1,1,0)#</cfif>">
                                <span class="input-group-addon btnPointer icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_all_pars&is_period_kontrol=0&field_comp_name=form_basket.member_name&field_comp_id=form_basket.company_id&field_partner=form_basket.partner_id&field_name=form_basket.partner_name&field_consumer=form_basket.consumer_id&field_long_address=form_basket.ship_address&function_name=fill_country&field_adress_id=form_basket.ship_address_id&field_city_id=form_basket.city_id&field_county_id=form_basket.county_id&select_list=7,8#str_linkeait#');"></span>
                            </div>
                        </div>
                    </div>
                    <div class="form-group" id="item-partner_name">
                        <label class="col col-4 col-sm-12"><cf_get_lang dictionary_id='57578.Yetkili'></label>
                        <div class="col col-8 col-sm-12">
                            <input type="text" name="partner_name" id="partner_name" value="<cfif isdefined("attributes.partner_id") and len(attributes.partner_id)>#get_par_info(attributes.partner_id,0,-1,0)#<cfelseif isdefined("attributes.consumer_id") and Len(attributes.consumer_id)>#get_cons_info(attributes.consumer_id,0,0)#</cfif>" readonly>
                        </div>
                    </div>
                    <div class="form-group" id="item-ref_no">
                        <label class="col col-4 col-sm-12"><cf_get_lang dictionary_id='58794.Referans No'></label>
                        <div class="col col-8 col-sm-12">
                            <input type="text" name="ref_no" id="ref_no" value="<cfif isdefined('attributes.ref_no') and len(attributes.ref_no)>#attributes.ref_no#</cfif>" maxlength="50">
                        </div>
                    </div>
                    <div class="form-group" id="item-sales_emp">
                        <label class="col col-4 col-sm-12"><cf_get_lang dictionary_id='40903.Satış Yapan'></label>
                        <div class="col col-8 col-sm-12">
                            <div class="input-group">
                                <input type="hidden" name="sales_emp_id" id="sales_emp_id" value="<cfif isdefined("attributes.sales_emp_id") and len(attributes.sales_emp_id)>#attributes.sales_emp_id#<cfelseif xml_show_sales_emp eq 1>#session.ep.userid#</cfif>">
                                <input type="text" name="sales_emp" id="sales_emp" value="<cfif isdefined("attributes.sales_emp_id") and len(attributes.sales_emp_id)>#get_emp_info(attributes.sales_emp_id,0,0)#<cfelseif xml_show_sales_emp eq 1>#get_emp_info(session.ep.userid,0,0)#</cfif>" onFocus="AutoComplete_Create('sales_emp','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','3','EMPLOYEE_ID','sales_emp_id','','3','125');" autocomplete="off">
                                <span class="input-group-addon btnPointer icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_positions&field_emp_id=form_basket.sales_emp_id&field_name=form_basket.sales_emp&select_list=1');"></span>
                            </div>
                        </div>
                    </div>
                    <div class="form-group" id="item-sales_member">
                        <label class="col col-4 col-sm-12"><cf_get_lang dictionary_id='49283.satış Ortağı'></label>
                        <div class="col col-8 col-sm-12">
                            <input type="hidden" name="sales_member_id" id="sales_member_id" value="">
                            <input type="hidden" name="sales_member_type"  id="sales_member_type" value="">
                            <div class="input-group">
                                <input type="text" name="sales_member" id="sales_member" value=""  onFocus="AutoComplete_Create('sales_member','MEMBER_NAME,MEMBER_PARTNER_NAME','MEMBER_PARTNER_NAME2,MEMBER_NAME2','get_member_autocomplete','\'1,2\'','PARTNER_ID,MEMBER_TYPE','sales_member_id,sales_member_type','','3','250');" autocomplete="off">
                                <span class="input-group-addon btnPointer icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_pars&is_rate_select=1&field_id=form_basket.sales_member_id&field_name=form_basket.sales_member&field_type=form_basket.sales_member_type<cfif session.ep.isBranchAuthorization>&is_store_module=1</cfif>&select_list=7,8');"></span>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col col-3 col-md-4 col-sm-6 col-sm-12" type="column" index="2" sort="true">
                    <div class="form-group" id="item-offer_date">
                        <label class="col col-4 col-sm-12"><cf_get_lang dictionary_id='46831.Teklif Tarihi'>*</label>
                        <div class="col col-8 col-sm-12">
                            <div class="input-group">
                                <cfsavecontent variable="message"><cf_get_lang dictionary_id='38656.Teklif Tarihi Girmelisiniz'>!</cfsavecontent>
                                <cfinput type="text" name="offer_date" value="#dateformat(now(),dateformat_style)#" validate="#validate_style#" required="yes" message="#message#" maxlength="10" onblur="change_money_info('form_basket','offer_date');">
                                <span class="input-group-addon"><cf_wrk_date_image date_field="offer_date" call_function="change_money_info"></span>
                            </div>
                        </div>
                    </div>
                    <div class="form-group" id="item-ship_date">
                        <label class="col col-4 col-sm-12"><cf_get_lang dictionary_id='40834.Sevk Tarihi'></label>
                        <div class="col col-8 col-sm-12">
                            <div class="input-group">
                                <cfsavecontent variable="message"><cf_get_lang dictionary_id='40895.Sevk Tarihi Girmelisiniz'>!</cfsavecontent>
                                <cfinput type="text" name="ship_date" id="ship_date" value="#DateFormat(attributes.ship_date,dateformat_style)#" validate="#validate_style#" message="#message#" maxlength="10">
                                <span class="input-group-addon"><cf_wrk_date_image date_field="ship_date"></span>
                            </div>
                        </div>
                    </div>
                    <div class="form-group" id="item-deliverdate">
                        <label class="col col-4 col-sm-12"><cf_get_lang dictionary_id='57645.Teslim Tarihi'>*</label>
                        <div class="col col-8 col-sm-12">
                            <div class="input-group">
                                <cfsavecontent variable="message"><cf_get_lang dictionary_id='40987.Teslim Tarihi Girmelisiniz'></cfsavecontent>
                                <cfinput type="text" name="deliverdate" id="deliverdate" value="#DateFormat(attributes.deliverdate,dateformat_style)#" validate="#validate_style#" message="#message#">
                                <span class="input-group-addon"><cf_wrk_date_image date_field="deliverdate"></span>
                                <cfif isdefined('is_termin_calc') and is_termin_calc eq 1>
                                    <span class="input-group-addon btnPointer icon-cogs" onClick="calc_deliver_date();"></span>
                                </cfif>
                            </div>
                        </div>
                    </div>
                    <div class="form-group" id="item-finishdate">
                        <label class="col col-4 col-sm-12"><cf_get_lang dictionary_id='40906.Geçerlilik'></label>
                        <div class="col col-8 col-sm-12">
                            <div class="input-group">
                                <cfsavecontent variable="message"><cf_get_lang dictionary_id='40988.Gecerlilik Tarihi Girmelisiniz'></cfsavecontent>
                                <cfinput type="text" name="finishdate" id="finishdate" value="#DateFormat(attributes.finishdate,dateformat_style)#" validate="#validate_style#" message="#message#">
                                <span class="input-group-addon"><cf_wrk_date_image date_field="finishdate"></span>
                            </div>
                        </div>
                    </div>
                    <div class="form-group" id="item-paymethod_vehicle">
                        <label class="col col-4 col-sm-12"><cf_get_lang dictionary_id='58516.Ödeme Yöntemi'></label>
                        <div class="col col-8 col-sm-12">
                            <cfif isdefined("attributes.paymethod_id") and len(attributes.paymethod_id)>
                                <cfinclude template="../query/get_paymethod.cfm">
                                <cfset paymethod_id_ = get_paymethod.paymethod_id>
                                <cfset card_paymethod_id_ = "">
                                <cfset commission_rate_ = "">
                                <cfset paymethod_vehicle_ = get_paymethod.payment_vehicle>
                                <cfset pay_method_ = get_paymethod.paymethod>
                            <cfelseif isdefined("attributes.card_paymethod_id") and len(attributes.card_paymethod_id)>
                                <cfset card_pay_id = attributes.card_paymethod_id>
                                <cfinclude template="../query/get_card_paymethod.cfm">
                                <cfset paymethod_id_ = "">
                                <cfset card_paymethod_id_ = get_card_paymethod.payment_type_id>
                                <cfset commission_rate_ = get_card_paymethod.commission_multiplier>
                                <cfset paymethod_vehicle_ = "-1">
                                <cfset pay_method_ = get_card_paymethod.card_no>
                            <cfelse>
                                <cfset paymethod_id_ = "">
                                <cfset card_paymethod_id_ = "">
                                <cfset commission_rate_ = "">
                                <cfset paymethod_vehicle_ = "">
                                <cfset pay_method_ = "">
                                <!--- Odeme Yontemi Yoksa Kurumsal veya Bireysel Oyelerdeki Yontemleri Kontrol Edilir --->
                                <cfif (isDefined("attributes.company_id") and Len(attributes.company_id)) or (isDefined("attributes.consumer_id") and Len(attributes.consumer_id))>
                                    <cfset get_member_payment_method = createObject("component","V16.objects.cfc.getMemberPaymentMethod").getMemberPaymentMethod(dsn:dsn,is_sales_type:1,our_company_id:session.ep.company_id,company_id:iif(isDefined("attributes.company_id"),"attributes.company_id",""),consumer_id:iif(isDefined("attributes.consumer_id"),"attributes.consumer_id",""))>
                                    <cfif get_member_payment_method.recordcount>
                                        <cfset paymethod_id_ = get_member_payment_method.payment_method_id>
                                        <cfset card_paymethod_id_ = get_member_payment_method.card_payment_method_id>
                                        <cfset commission_rate_ = get_member_payment_method.commission_multiplier>
                                        <cfset paymethod_vehicle_ = get_member_payment_method.payment_vehicle>
                                        <cfset pay_method_ = get_member_payment_method.payment_method_name>
                                    </cfif>
                                </cfif>
                            </cfif>
                            <input type="hidden" name="paymethod_vehicle" id="paymethod_vehicle" value="#paymethod_vehicle_#">
                            <input type="hidden" name="card_paymethod_id" id="card_paymethod_id" value="#card_paymethod_id_#">
                            <input type="hidden" name="commission_rate" id="commission_rate" value="#commission_rate_#">
                            <input type="hidden" name="paymethod_id" id="paymethod_id" value="#paymethod_id_#">
                            <div class="input-group">
                                <input type="text" name="pay_method" id="pay_method" value="#pay_method_#"  onFocus="AutoComplete_Create('pay_method','PAYMETHOD','PAYMETHOD','get_paymethod','\'1,2\'','PAYMENT_TYPE_ID,COMMISSION_MULTIPLIER,PAYMETHOD_ID,PAYMENT_VEHICLE','card_paymethod_id,commission_rate,paymethod_id,paymethod_vehicle','','3','200');" autocomplete="off">
                                <cfset card_link="&field_card_payment_id=form_basket.card_paymethod_id&field_card_payment_name=form_basket.pay_method&field_commission_rate=form_basket.commission_rate&field_paymethod_vehicle=form_basket.paymethod_vehicle">
                                <span class="input-group-addon btnPointer icon-ellipsis" onClick="windowopen('#request.self#?fuseaction=objects.popup_paymethods&field_id=form_basket.paymethod_id&field_name=form_basket.pay_method#card_link#','list');"></span>
                            </div>
                        </div>
                    </div>
                    <div class="form-group" id="item-ship_method_id">
                        <label class="col col-4 col-sm-12"><cf_get_lang dictionary_id='29500.Sevk Yöntemi'></label>
                        <div class="col col-8 col-sm-12">
                            <cfif isdefined("attributes.ship_method") and len(attributes.ship_method)>
                                <cfinclude template="../query/get_ship_method.cfm">
                                <input type="hidden" name="ship_method_id" id="ship_method_id" value="#attributes.ship_method#">
                                <div class="input-group">
                                    <input type="text" name="ship_method_name" id="ship_method_name" value="#get_ship_method.ship_method#" onFocus="AutoComplete_Create('ship_method_name','SHIP_METHOD','SHIP_METHOD','get_ship_method','','SHIP_METHOD_ID','ship_method_id','','3','125');" autocomplete="off">
                                    <span class="input-group-addon btnPointer icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_ship_methods&field_name=ship_method_name&field_id=ship_method_id','','ui-draggable-box-small');"></span>
                                </div>
                            <cfelse>
                                <input type="hidden" name="ship_method_id" id="ship_method_id" value="">
                                <div class="input-group">
                                    <input type="text" name="ship_method_name" id="ship_method_name"  value="" onFocus="AutoComplete_Create('ship_method_name','SHIP_METHOD','SHIP_METHOD','get_ship_method','','SHIP_METHOD_ID','ship_method_id','','3','125');"  autocomplete="off">
                                    <span class="input-group-addon btnPointer icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_ship_methods&field_name=ship_method_name&field_id=ship_method_id','','ui-draggable-box-small');"></span>
                                </div>
                            </cfif>
                        </div>
                    </div>
                    <div class="form-group" id="item-city_id">
                        <label class="col col-4 col-sm-12"><cf_get_lang dictionary_id='58449.Teslim Yeri'></label>
                        <div class="col col-8 col-sm-12">
                            <!--- Uye Bilgilerinden gelindiginde teslim yeri alaninin dolu gelmesi icin eklendi --->
                            <cfif isdefined('attributes.company_id') and len(attributes.company_id)>
                                <cfquery name="get_ship_address" datasource="#dsn#">
                                    SELECT TOP 1
                                        *
                                    FROM
                                        (SELECT 0 AS TYPE,COMPBRANCH_ID,COMPBRANCH_ADDRESS AS ADDRESS,POS_CODE,SEMT,COUNTY_ID AS COUNTY,CITY_ID AS CITY,COUNTRY_ID AS COUNTRY FROM COMPANY_BRANCH WHERE IS_SHIP_ADDRESS = 1 AND COMPANY_ID = #attributes.company_id#
                                        UNION
                                        SELECT 1 AS TYPE,-1 COMPBRANCH_ID,COMPANY_ADDRESS AS ADDRESS,POS_CODE,SEMT,COUNTY,CITY,COUNTRY FROM COMPANY WHERE COMPANY_ID = #attributes.company_id#
                                    ) AS TYPE
                                    ORDER BY
                                        TYPE
                                </cfquery>
                                <cfset attributes.ship_address_id_ = get_ship_address.COMPBRANCH_ID>
                                <cfset address_ = get_ship_address.address>
                                <cfif len(get_ship_address.pos_code) and len(get_ship_address.semt)>
                                    <cfset address_ = "#address_# #get_ship_address.pos_code# #get_ship_address.semt#">
                                </cfif>
                                <cfif len(get_ship_address.county)>
                                    <cfquery name="get_county_name" datasource="#dsn#">
                                        SELECT COUNTY_ID,COUNTY_NAME FROM SETUP_COUNTY WHERE COUNTY_ID = #get_ship_address.county#
                                    </cfquery>
                                    <cfset attributes.county_id = get_county_name.county_id>
                                    <cfset address_ = "#address_# #get_county_name.county_name#">
                                </cfif>
                                <cfif len(get_ship_address.city)>
                                    <cfquery name="get_city_name" datasource="#dsn#">
                                        SELECT CITY_ID,CITY_NAME FROM SETUP_CITY WHERE CITY_ID = #get_ship_address.city#
                                    </cfquery>
                                    <cfset attributes.city_id = get_city_name.city_id>
                                    <cfset address_ = "#address_# #get_city_name.city_name#">
                                </cfif>
                                <cfif len(get_ship_address.country)>
                                    <cfquery name="get_country_name" datasource="#dsn#">
                                        SELECT COUNTRY_NAME FROM SETUP_COUNTRY WHERE COUNTRY_ID = #get_ship_address.country#
                                    </cfquery>
                                    <cfset address_ = "#address_# #get_country_name.country_name#">
                                </cfif>
                            </cfif>
                            <!--- //Uye Bilgilerinden gelindiginde teslim yeri alaninin dolu gelmesi icin eklendi --->
                            <input type="hidden" name="city_id" id="city_id" value="<cfif isdefined('attributes.city_id') and len(attributes.city_id)>#attributes.city_id#</cfif>">
                            <input type="hidden" name="county_id" id="county_id" value="<cfif isdefined('attributes.county_id') and len(attributes.county_id)>#attributes.county_id#</cfif>">
                            <input type="hidden" name="ship_address_id" id="ship_address_id" value="<cfif isdefined('attributes.ship_address_id_') and len(attributes.ship_address_id_)>#attributes.ship_address_id_#</cfif>">
                            <div class="input-group">
                                <textarea name="ship_address" id="ship_address" onChange="kontrol(this,200)"><cfif isdefined('address_') and len(address_)>#address_#</cfif></textarea>
                                <span class="input-group-addon btnPointer icon-ellipsis" onClick="add_adress();"></span>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col col-3 col-md-4 col-sm-6 col-sm-12" type="column" index="3" sort="true">
                    <div class="form-group" id="item-project_id">
                        <label class="col col-4 col-sm-12"><cf_get_lang dictionary_id='57416.Proje'></label>
                        <div class="col col-8 col-sm-12">
                            <input type="hidden" name="project_id" id="project_id" value="<cfif isdefined("attributes.project_id") and len(attributes.project_id)>#attributes.project_id#</cfif>">
                            <div class="input-group">
                                <input type="text" name="project_head" id="project_head" value="<cfif isdefined("attributes.project_id") and len(attributes.project_id)>#get_project_name(attributes.project_id)#</cfif>" onFocus="AutoComplete_Create('project_head','PROJECT_ID,PROJECT_HEAD','PROJECT_HEAD','get_project','','PROJECT_ID','project_id','form_basket','3','140')" autocomplete="off">
                                <cfset str_linke_ait_prj="&comp_id='+document.form_basket.company_id.value+'&cons_id='+document.form_basket.consumer_id.value+'&comp_name='+document.form_basket.member_name.value+'">
                                <span class="input-group-addon btnPointer icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_projects#str_linke_ait_prj#&project_id=form_basket.project_id&project_head=form_basket.project_head');"></span>
                                <span class="input-group-addon btnPointer icon-question" onClick="if(document.getElementById('project_id').value!='')windowopen('#request.self#?fuseaction=project.popup_list_project_actions&from_paper=OFFER&id='+document.getElementById('project_id').value+'','page_display');else alert('Proje Seçiniz');"></span>
                            </div>
                        </div>
                    </div>
                    <div class="form-group" id="item-work_id">
                        <label class="col col-4 col-sm-12"><cf_get_lang dictionary_id='58445.İş'></label>
                        <div class="col col-8 col-sm-12">
                            <input type="hidden" name="work_id" id="work_id" value="<cfif isdefined("attributes.work_id") and len(attributes.work_id)>#attributes.work_id#</cfif>">
                            <div class="input-group">
                                <input type="text" name="work_head" id="work_head" value="<cfif isdefined("attributes.work_id") and len(attributes.work_id)>#get_work_name(attributes.work_id)#</cfif>">
                                <span class="input-group-addon btnPointer icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_add_work&field_id=form_basket.work_id&field_name=form_basket.work_head&project_id='+document.getElementById('project_id').value+'&project_head='+document.getElementById('project_head').value+'');"></span>
                            </div>
                        </div>
                    </div>
                    <div class="form-group" id="item-camp_id">
                        <label class="col col-4 col-sm-12"><cf_get_lang dictionary_id='57446.Kampanya'></label>
                        <div class="col col-8 col-sm-12">
                            <cfoutput>
                                <input type="hidden" name="camp_id" id="camp_id" value="">
                                <div class="input-group">
                                    <input type="text" name="camp_name" id="camp_name" value="" >
                                    <span class="input-group-addon btnPointer icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_campaigns&field_id=form_basket.camp_id&field_name=form_basket.camp_name');"></span>
                                </div>
                            </cfoutput>
                        </div>
                    </div>
                    <div class="form-group" id="item-sales_zone_id">
                        <label class="col col-4 col-sm-12"><cf_get_lang dictionary_id ='57659.Satis bolgesi'></label>
                        <div class="col col-8 col-sm-12">
                            <select name="sales_zone_id" id="sales_zone_id">
                                <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                <cfloop query="get_sale_zones">
                                    <option value="#sz_id#" <cfif isdefined("attributes.sz_id") and attributes.sz_id eq sz_id>selected</cfif>>#sz_name#</option>
                                </cfloop>
                            </select>
                        </div>
                    </div>
                    <div class="form-group" id="item-country_id">
                        <label class="col col-4 col-sm-12"><cf_get_lang dictionary_id ='58219.Ülke'></label>
                        <div class="col col-8 col-sm-12">
                            <select name="country_id" id="country_id" onchange="auto_sales_zone();">
                                <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                <cfloop query="get_country">
                                    <option value="#country_id#" <cfif isdefined("attributes.country_id") and  attributes.country_id eq country_id>selected</cfif>>#country_name#</option>
                                </cfloop>
                            </select>
                        </div>
                    </div>
                    <div class="form-group" id="item-sales_add_option">
                        <label class="col col-4 col-sm-12"><cf_get_lang dictionary_id ='41142.Satış Özel Tanım'></label>
                        <div class="col col-8 col-sm-12">
                            <cfinclude template="../query/get_sale_add_option.cfm">
                            <select name="sales_add_option"  id="sales_add_option">
                                <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                <cfloop query="get_sale_add_option">
                                    <option value="#sales_add_option_id#" <cfif isdefined('attributes.sales_add_option_id') and len(attributes.sales_add_option_id) and attributes.sales_add_option_id eq get_sale_add_option.sales_add_option_id>selected</cfif>>#sales_add_option_name#</option>
                                </cfloop>
                            </select>
                        </div>
                    </div>
                    <div class="form-group" id="item-probability">
                        <label class="col col-4 col-sm-12"><cf_get_lang dictionary_id='58652.Olasılık'> %</label>
                        <div class="col col-8 col-sm-12">
                            <select name="probability" id="probability">
                                <cfloop from="0" to="100" index="i" step="5">
                                    <option value="#i#" >#i#</option>
                                </cfloop>
                            </select>
                        </div>
                    </div>
                </div>
                <div class="col col-3 col-md-4 col-sm-6 col-sm-12" type="column" index="4" sort="true">
                    <div class="form-group" id="item-offer_status">
                        <label><cf_get_lang dictionary_id='57493.Aktif'><input type="checkbox" name="offer_status" id="offer_status" value="1" checked></label>&nbsp;&nbsp;&nbsp;
                        <label><cf_get_lang dictionary_id='40847.public'><input type="checkbox" name="is_public_zone" id="is_public_zone" value="1" <cfif isdefined("attributes.is_public_zone") and attributes.is_public_zone eq 1>checked</cfif>></label>&nbsp;&nbsp;&nbsp;
                        <label><cf_get_lang dictionary_id='58885.Partner'><input type="checkbox" name="is_partner_zone" id="is_partner_zone" value="1" <cfif isdefined("attributes.is_partner_zone") and attributes.is_partner_zone eq 1>checked</cfif>></label>
                    </div>
                    <cfif isdefined("attributes.rel_offer_id") and len(attributes.rel_offer_id)>
                        <cfquery name="GET_OFFER_HEAD" datasource="#dsn3#">
                            SELECT OFFER_HEAD,OFFER_NUMBER FROM OFFER WHERE OFFER_ID = #attributes.rel_offer_id#
                        </cfquery>
                        <cfset rel_offer_head = get_offer_head.offer_number>
                    </cfif>
                    <div class="form-group" id="item-rel_offer_id">
                        <label class="col col-4 col-sm-12"><cf_get_lang dictionary_id='40880.İlişkili Teklif'></label>
                        <div class="col col-8 col-sm-12">
                            <cfoutput>
                                <div class="input-group">
                                    <input type="hidden" name="rel_offer_id" id="rel_offer_id" value="<cfif isdefined('attributes.rel_offer_id') and len(attributes.rel_offer_id)>#attributes.rel_offer_id#</cfif>">
                                    <input type="text" name="rel_offer_head" id="rel_offer_head" value="<cfif isdefined('rel_offer_head') and len(rel_offer_head)>#rel_offer_head#</cfif>">
                                    <span class="input-group-addon btnPointer icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=sales.popup_list_offers&field_offer_id=form_basket.rel_offer_id&field_offer_number=form_basket.rel_offer_head');"></span>
                                </div>
                            </cfoutput>
                        </div>
                    </div>
                    <div class="form-group" id="item-offer_detail">
                        <label class="col col-4 col-sm-12"><cf_get_lang dictionary_id='57629.Açıklama'></label>
                        <div class="col col-8 col-sm-12">
                            <textarea name="offer_detail" id="offer_detail">&nbsp;</textarea>
                        </div>
                    </div>
                    <div class="form-group" id="item-ref_company_id">
                        <label class="col col-4 col-sm-12"><cf_get_lang dictionary_id='58784.Referans'></label>
                        <div class="col col-8 col-sm-12">
                            <cfif isdefined("attributes.ref_partner_id") and len(attributes.ref_partner_id)>
                                <input type="hidden" name="ref_company_id" id="ref_company_id" value="#attributes.ref_company_id#">
                                <input type="hidden" name="ref_member_type" id="ref_member_type" value="partner">
                                <input type="hidden" name="ref_member_id" id="ref_member_id" value="#attributes.ref_partner_id#">
                                <div class="input-group">
                                    <input type="text" name="ref_company" id="ref_company" value="#get_par_info(attributes.ref_company_id,1,0,0)#" onfocus="AutoComplete_Create('ref_company','MEMBER_NAME,MEMBER_PARTNER_NAME','MEMBER_NAME2,MEMBER_PARTNER_NAME2','get_member_autocomplete','\'1,2\'','COMPANY_ID,MEMBER_TYPE,PARTNER_CODE,MEMBER_PARTNER_NAME2','ref_company_id,ref_member_type,ref_member_id,ref_member','','3','250');" autocomplete="off">
                                    <span class="input-group-addon btnPointer icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_all_pars&field_partner=form_basket.ref_member_id&field_consumer=form_basket.ref_member_id&field_comp_id=form_basket.ref_company_id&field_comp_name=form_basket.ref_company&field_name=form_basket.ref_member&field_type=form_basket.ref_member_type&select_list=7,8');"></span>
                                </div>
                            <cfelseif isdefined("attributes.ref_consumer_id") and len(attributes.ref_consumer_id)>
                                <input type="hidden" name="ref_company_id" id="ref_company_id" value="#attributes.ref_company_id#">
                                <input type="hidden" name="ref_member_type" id="ref_member_type" value="consumer">
                                <input type="hidden" name="ref_member_id" id="ref_member_id" value="#attributes.ref_consumer_id#">
                                <div class="input-group">
                                    <input type="text" name="ref_company" id="ref_company" value="" onfocus="AutoComplete_Create('ref_company','MEMBER_NAME,MEMBER_PARTNER_NAME','MEMBER_NAME2,MEMBER_PARTNER_NAME2','get_member_autocomplete','\'1,2\'','COMPANY_ID,MEMBER_TYPE,PARTNER_CODE,MEMBER_PARTNER_NAME2','ref_company_id,ref_member_type,ref_member_id,ref_member','','3','250');" autocomplete="off">
                                    <span class="input-group-addon btnPointer icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_all_pars&field_partner=form_basket.ref_member_id&field_consumer=form_basket.ref_member_id&field_comp_id=form_basket.ref_company_id&field_comp_name=form_basket.ref_company&field_name=form_basket.ref_member&field_type=form_basket.ref_member_type&select_list=7,8');"></span>
                                </div>
                            <cfelse>
                                <input type="hidden" name="ref_company_id" id="ref_company_id" value="">
                                <input type="hidden" name="ref_member_type" id="ref_member_type" value="">
                                <input type="hidden" name="ref_member_id" id="ref_member_id" value="">
                                <div class="input-group">
                                    <input type="text" name="ref_company" id="ref_company" value="" onfocus="AutoComplete_Create('ref_company','MEMBER_NAME,MEMBER_PARTNER_NAME','MEMBER_NAME2,MEMBER_PARTNER_NAME2','get_member_autocomplete','\'1,2\'','COMPANY_ID,MEMBER_TYPE,PARTNER_CODE,MEMBER_PARTNER_NAME2','ref_company_id,ref_member_type,ref_member_id,ref_member','','3','250');" autocomplete="off">
                                    <span class="input-group-addon btnPointer icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_all_pars&field_partner=form_basket.ref_member_id&field_consumer=form_basket.ref_member_id&field_comp_id=form_basket.ref_company_id&field_comp_name=form_basket.ref_company&field_name=form_basket.ref_member&field_type=form_basket.ref_member_type&select_list=7,8');"></span>
                                </div>
                            </cfif>
                        </div>
                    </div>
                    <div class="form-group" id="item-ref_member">
                        <label class="col col-4 col-sm-12"><cf_get_lang dictionary_id='57578.Yetkili'></label>
                        <div class="col col-8 col-sm-12">
                            <cfif isdefined("attributes.ref_partner_id") and len(attributes.ref_partner_id)>
                                <input type="text" name="ref_member" id="ref_member" value="#get_par_info(attributes.ref_partner_id,0,-1,0)#" readonly>
                            <cfelseif isdefined("attributes.ref_consumer_id") and len(attributes.ref_consumer_id)>
                                <input type="text" name="ref_member" id="ref_member" value="#get_cons_info(attributes.ref_consumer_id,0,0,0)#" readonly>
                            <cfelse>
                                <input type="text" name="ref_member" id="ref_member" readonly>
                            </cfif>
                        </div>
                    </div>
                    <div class="form-group" id="item-wrk_add_info">
                        <label class="col col-4 col-sm-12"><cfoutput>#getLang('main',398)#</cfoutput></label>
                        <div class="col col-8 col-sm-12">
                            <cf_wrk_add_info info_type_id="-9" upd_page = "0" colspan="3">
                        </div>
                    </div>
                </div>
            </cf_box_elements>
            <cf_box_footer>
                <cf_workcube_buttons is_upd='0' add_function='check()'>
            </cf_box_footer>
    </cfoutput>
    <script type="text/javascript">
    function calc_deliver_date()
    {
        stock_id_list = '';
        var row_c = document.getElementsByName('stock_id').length;
        if(row_c != 0)
        {
            if(row_c > 1)
            {//1den fazla satır varsa
                for(var ii=0;ii<row_c;ii++)
                {
                    var n_stock_id =document.all.stock_id[ii].value;
                    var n_amount = filterNum(document.all.amount[ii].value,6);
                    var n_spect_id = document.all.spect_id[ii].value;
                    var n_is_production = document.all.is_production[ii].value;
                    if(n_spect_id == "") n_spect_id =0;
                    if(n_stock_id != "")//ürün silinmemiş ise
                        stock_id_list +=n_stock_id+'-'+n_spect_id+'-'+n_amount+'-'+n_is_production+',';
                }
            }
            else if(row_c == 1){
                var n_stock_id =document.all.stock_id.value;
                var n_amount = filterNum(document.all.amount.value,6);
                var n_spect_id = document.all.spect_id.value;
                var n_is_production = document.all.is_production.value;
                if(n_spect_id == "") n_spect_id =0;
                if(n_stock_id != "")
                stock_id_list +=n_stock_id+'-'+n_spect_id+'-'+n_amount+'-'+n_is_production+',';
            }
            document.getElementById('deliver_date_info').style.display='';
            AjaxPageLoad('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_ajax_deliver_date_calc&offer_date='+document.getElementById('offer_date').value+'&stock_id_list='+stock_id_list+'','deliver_date_info',1,"<cfoutput>#getLang('','Teslim Tarihi Hesaplanıyor','41164')#</cfoutput>!");
        }
        else
        alert("<cfoutput>#getLang('','Ürün Seçmelisiniz','58227')#</cfoutput>!");
    }
    function fill_country(member_id,type)
    {
        document.getElementById('country_id').value='';
        document.getElementById('sales_zone_id').value='';
        if(type==1)
        {
            get_country = wrk_safe_query("get_country",'dsn',0,member_id);
            if(get_country.COUNTRY!='' && get_country.COUNTRY!='undefined')
                document.getElementById('country_id').value=get_country.COUNTRY;
            if(get_country.SALES_COUNTY!='' && get_country.SALES_COUNTY!='undefined')
                document.getElementById('sales_zone_id').value=get_country.SALES_COUNTY;
        }
        else if(type==2)
        {
            get_country = wrk_safe_query("get_country_consumer",'dsn',0,member_id);
            if(get_country.TAX_COUNTRY_ID!='' && get_country.TAX_COUNTRY_ID!='undefined')
                document.getElementById('country_id').value=get_country.TAX_COUNTRY_ID;
            if(get_country.SALES_COUNTY!='' && get_country.TAX_COUNTRY_ID!='undefined')
                document.getElementById('sales_zone_id').value=get_country.SALES_COUNTY;
        }
    }
    function auto_sales_zone()
    {
        get_sales_zone_id = wrk_safe_query("get_sales_zone_id",'dsn',0,document.getElementById('country_id').value);
        if(get_sales_zone_id.recordcount == 1)
        {
            document.getElementById('sales_zone_id').value = get_sales_zone_id.SZ_ID;
            return false;
        }
        else if(get_sales_zone_id.recordcount == 0)
        {
            alert("<cfoutput>#getLang('','Ülke ile İlişkili Satış Bölgesi Bulunamadı','40952')#</cfoutput>");
            return false;
        }
        else if(get_sales_zone_id.recordcount > 1)
        {
            alert("<cfoutput>#getLang('','Ülke ile İlişkili Birden Fazla Satış Bölgesi Bulunmaktadır','40955')#</cfoutput>");
            return false;
        }
    }
    </script>
    