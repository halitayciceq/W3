<cfoutput>

        <div class="col col-9 col-md-9 col-sm-9 col-xs-12 uniqueRow">
            <cf_box title="#getLang('main','Fırsat',57612)# #getLang('main','Detay',57771)#" closable="0" id="box_followup_firsat">
                <cfform name="upd_opp" id="upd_opp" method="post" action="">
                    <cfset member_name_="">
                    <input type="hidden" name="active_company" id="active_company" value="<cfoutput>#session.ep.company_id#</cfoutput>">
                    <input type="hidden" name="opp_id" id="opp_id" value="<cfoutput>#opp_id#</cfoutput>">
                    <input type="hidden" name="old_process_stage" id="old_process_stage" value="<cfoutput>#get_opportunity.opp_stage#</cfoutput>">
                        <cf_box_elements vertical="1">
                            <div class="col col-4 col-md-4 col-sm-12 col-xs-12" type="column" index="1" sort="true">
                                <div class="form-group" id="item-opp_date">
                                    <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='40923.Basvuru tarihi'></label>
                                    <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                                        <div class="input-group">
                                            <cfsavecontent variable="message"><cf_get_lang dictionary_id='58769.Basvuru Tarihi Girmelisiniz'></cfsavecontent>
                                            <cfinput type="text" name="opp_date" id="opp_date" value="#dateformat(get_opportunity.opp_date,dateformat_style)#" validate="#validate_style#" maxlength="10" message="#message#">
                                            <span class="input-group-addon"><cf_wrk_date_image date_field="opp_date"></span>
                                        </div>
                                    </div>
                                </div>
                                <div class="form-group" id="item-opp_process_cat">
                                    <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='61806.İşlem Tipi'> *</label>
                                    <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                                        <cf_workcube_process_cat process_cat="#get_opportunity.process_cat#">
                                    </div>
                                </div>
                                <div class="form-group" id="item-opp_stage">
                                    <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='58859.Süreç'> *</label>
                                    <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                                        <cf_workcube_process is_upd='0' select_value='#get_opportunity.opp_stage#' process_cat_width='140' is_detail='1'>
                                    </div>
                                </div>
                                <div class="form-group" id="item-opp_no">
                                    <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='57487.No'></label>
                                    <div class="col col-8 col-md-8 col-sm-8 col-xs-12" extra_checkbox="opp_status">
                                        <input type="hidden" name="opp_id2" id="opp_id2" value="<cfoutput>#get_opportunity.opp_id#</cfoutput>" readonly>
                                        <input type="text" name="opportunity_no" id="opportunity_no" value="<cfoutput>#get_opportunity.opp_no#</cfoutput>" readonly>
                                    </div>
                                </div>
                                <div class="form-group" id="item-opp_head">
                                    <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='57480.Konu'> *</label>
                                    <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                                        <input type="text" name="opp_head" id="opp_head" value="#get_opportunity.opp_head#">
                                    </div>
                                </div>
                                <div class="form-group" id="item-opportunity_type_id">
                                    <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='57486.Kategori'></label>
                                    <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                                        <select name="opportunity_type_id" id="opportunity_type_id">
                                            <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                            <cfloop query="get_opportunity_type">
                                                <option value="#opportunity_type_id#" <cfif opportunity_type_id eq get_opportunity.opportunity_type_id>selected</cfif>>#opportunity_type#</option>
                                            </cfloop>
                                        </select>
                                    </div>
                                </div>
                                <div class="form-group" id="item-company">
                                    <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='57457.Müşteri'> *</label>
                                    <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                                        <input type="hidden" name="old_company_id" id="old_company_id" value="#get_opportunity.company_id#">
                                        <cfif len(get_opportunity.partner_id)>
                                            <input type="hidden" name="company_id" id="company_id" value="#get_opportunity.company_id#">
                                            <input type="hidden" name="member_type" id="member_type" value="partner">
                                            <input type="hidden" name="member_id" id="member_id" value="#get_opportunity.partner_id#">
                                            <input type="hidden" name="old_member_id" id="old_member_id" value="#get_opportunity.partner_id#">
                                            <div class="input-group">
                                                <input type="text" name="company" id="company" value="#get_par_info(get_opportunity.company_id,1,0,0)#" onFocus="AutoComplete_Create('company','MEMBER_NAME,MEMBER_PARTNER_NAME','MEMBER_NAME2,MEMBER_PARTNER_NAME2','get_member_autocomplete','\'1,2\'','COMPANY_ID,MEMBER_TYPE,PARTNER_CODE,MEMBER_PARTNER_NAME2','company_id,member_type,member_id,member','','3','250',true,'fill_country(0,0)');" autocomplete="off">
                                                <span class="input-group-addon btnPointer icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_all_pars&is_period_kontrol=0&field_partner=upd_opp.member_id&field_consumer=upd_opp.member_id&field_comp_id=upd_opp.company_id&field_comp_name=upd_opp.company&function_name=fill_country&field_name=upd_opp.member&field_type=upd_opp.member_type&select_list=7,8');"></span>
                                            </div>
                                        <cfelseif len(get_opportunity.consumer_id)>
                                            <input type="hidden" name="company_id" id="company_id" value="#get_opportunity.company_id#">
                                            <input type="hidden" name="member_type" id="member_type" value="consumer">
                                            <input type="hidden" name="member_id" id="member_id"  value="#get_opportunity.consumer_id#">
                                            <input type="hidden" name="old_member_id" id="old_member_id" value="#get_opportunity.consumer_id#">
                                            <div class="input-group">
                                                <input type="text" name="company" id="company"  value="#get_cons_info(get_opportunity.consumer_id,0,0,0)#" readonly onFocus="AutoComplete_Create('company','MEMBER_NAME,MEMBER_PARTNER_NAME','MEMBER_NAME2,MEMBER_PARTNER_NAME2','get_member_autocomplete','\'1,2\'','COMPANY_ID,MEMBER_TYPE,PARTNER_CODE,MEMBER_PARTNER_NAME2','company_id,member_type,member_id,member','','3','250',true,'fill_country(0,0)');" autocomplete="off">
                                                <span class="input-group-addon btnPointer icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_all_pars&is_period_kontrol=0&field_partner=upd_opp.member_id&field_consumer=upd_opp.member_id&field_comp_id=upd_opp.company_id&field_comp_name=upd_opp.company&function_name=fill_country&field_name=upd_opp.member&field_type=upd_opp.member_type&select_list=7,8');"></span>
                                            </div>
                                        <cfelse>
                                            <input type="hidden" name="company_id" id="company_id" value="">
                                            <input type="hidden" name="member_type" id="member_type" value="">
                                            <input type="hidden" name="member_id" id="member_id" value="">
                                            <input type="hidden" name="old_member_id" id="old_member_id"  value="">
                                            <div class="input-group">
                                                <input type="text" name="company" id="company"  value="" onFocus="AutoComplete_Create('company','MEMBER_NAME,MEMBER_PARTNER_NAME','MEMBER_NAME2,MEMBER_PARTNER_NAME2','get_member_autocomplete','\'1,2\'','COMPANY_ID,MEMBER_TYPE,PARTNER_CODE,MEMBER_PARTNER_NAME2','company_id,member_type,member_id,member','','3','250',true,'fill_country(0,0)');" autocomplete="off">
                                                <span class="input-group-addon btnPointer icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_all_pars&is_period_kontrol=0&field_partner=upd_opp.member_id&field_consumer=upd_opp.member_id&field_comp_id=upd_opp.company_id&field_comp_name=upd_opp.company&function_name=fill_country&field_name=upd_opp.member&field_type=upd_opp.member_type&select_list=7,8');"></span>
                                            </div>
                                        </cfif>
                                    </div>
                                </div>
                                <div class="form-group" id="item-member">
                                    <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='57578.Yetkili'></label>
                                    <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                                        <cfif len(get_opportunity.partner_id)>
                                            <input type="text" name="member" id="member" value="#get_par_info(get_opportunity.partner_id,0,-1,0)#" readonly>
                                        <cfelseif len(get_opportunity.consumer_id)>
                                            <input type="text" name="member" id="member" value="#get_cons_info(get_opportunity.consumer_id,0,0,0)#" readonly>
                                        <cfelse>
                                            <input type="text" name="member" id="member" value="" readonly>
                                        </cfif>
                                    </div>
                                </div>
                                <div class="form-group" id="item-sales_emp_id">
                                    <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='57457.Müşteri'><cf_get_lang dictionary_id='57908.Temsilci'></label>
                                    <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                                        <input type="hidden" name="sales_emp_id" id="sales_emp_id" value="#get_opportunity.sales_emp_id#">
                                        <div class="input-group">
                                            <input type="text" name="sales_emp" id="sales_emp" value="<cfif len(get_opportunity.sales_emp_id)>#get_emp_info(get_opportunity.sales_emp_id,0,0)#</cfif>" onFocus="AutoComplete_Create('sales_emp','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','3','EMPLOYEE_ID','sales_emp_id','','3','140');" autocomplete="off">
                                            <span class="input-group-addon btnPointer icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_positions&field_emp_id=upd_opp.sales_emp_id&field_name=upd_opp.sales_emp&select_list=1');"></span>
                                        </div>
                                    </div>
                                </div>
                                <div class="form-group" id="item-ref_company_id">
                                    <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='58784.Referans'></label>
                                    <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                                        <cfset member_name_ = "">
                                        <cfif len(get_opportunity.ref_partner_id)>
                                            <cfset member_name_= get_par_info(get_opportunity.ref_partner_id,0,-1,0)>
                                        <cfelseif len(get_opportunity.ref_consumer_id)>
                                            <cfset member_name_= get_cons_info(get_opportunity.ref_consumer_id,0,0)>
                                        <cfelseif len(get_opportunity.ref_employee_id)>
                                            <cfset member_name_= get_emp_info(get_opportunity.ref_employee_id,0,0)>
                                        </cfif>
                                        <input type="hidden" name="ref_company_id" id="ref_company_id" value="<cfif len(get_opportunity.ref_company_id)>#get_opportunity.ref_company_id#</cfif>">
                                        <input type="hidden" name="ref_partner_id" id="ref_partner_id" value="<cfif len(get_opportunity.ref_partner_id)>#get_opportunity.ref_partner_id#</cfif>">
                                        <input type="hidden" name="ref_consumer_id" id="ref_consumer_id" value="<cfif len(get_opportunity.ref_consumer_id)>#get_opportunity.ref_consumer_id#</cfif>">
                                        <input type="hidden" name="ref_employee_id" id="ref_employee_id" value="<cfif len(get_opportunity.ref_employee_id)>#get_opportunity.ref_employee_id#</cfif>">
                                        <input type="hidden" name="ref_member_type" id="ref_member_type" value="<cfif len(get_opportunity.ref_partner_id)>partner<cfelseif len(get_opportunity.ref_consumer_id)>consumer<cfelseif len(get_opportunity.ref_employee_id)>employee</cfif>">
                                        <div class="input-group">
                                            <input type="text" name="ref_member_name" id="ref_member_name" value="<cfif len(get_opportunity.ref_company_id)>#get_par_info(get_opportunity.ref_company_id,1,1,0)#</cfif>"  onFocus="AutoComplete_Create('ref_member_name','MEMBER_NAME,MEMBER_PARTNER_NAME','MEMBER_NAME2,MEMBER_PARTNER_NAME2','get_member_autocomplete','\'1,2,3\'','COMPANY_ID,PARTNER_ID,CONSUMER_ID,EMPLOYEE_ID,MEMBER_TYPE,MEMBER_PARTNER_NAME2','ref_company_id,ref_partner_id,ref_consumer_id,ref_employee_id,ref_member_type,ref_member','','3','250','return_company()');">
                                            <span class="input-group-addon btnPointer icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_all_pars&field_partner=upd_opp.ref_partner_id&field_consumer=upd_opp.ref_consumer_id&field_comp_id=upd_opp.ref_company_id&field_comp_name=upd_opp.ref_member_name&field_emp_id=upd_opp.ref_employee_id&field_name=upd_opp.ref_member&field_type=upd_opp.ref_member_type&select_list=1,7,8');"></span>
                                        </div>
                                    </div>
                                </div>
                                <div class="form-group" id="item-ref_member">
                                    <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='58784.Referans'><cf_get_lang dictionary_id='57578.Yetkili'></label>
                                    <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                                        <input type="text" id="ref_member" name="ref_member" onKeyup="javascript:if(document.upd_opp.ref_member.value=='')document.upd_opp.ref_member_name.value='';" value="#member_name_#">
                                    </div>
                                </div>
                            </div>
                            <div class="col col-4 col-md-4 col-sm-12 col-xs-12" type="column" index="2" sort="true">
                                <div class="form-group" id="item-project_id">
                                    <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='57416.Proje'></label>
                                    <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                                        <input type="hidden" name="project_id" id="project_id" value="#get_opportunity.project_id#">
                                        <div class="input-group">
                                            <input type="text" name="project_head" id="project_head" value="<cfif len(get_opportunity.project_id)>#GET_PROJECT_NAME(get_opportunity.project_id)#</cfif>" onFocus="AutoComplete_Create('project_head','PROJECT_HEAD','PROJECT_HEAD','get_project','','PROJECT_ID','project_id','','3','200');" autocomplete="off">
                                            <span class="input-group-addon btnPointer icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_projects&project_id=upd_opp.project_id&project_head=upd_opp.project_head');"></span>
                                        </div>
                                    </div>
                                </div>
                                <div class="form-group" id="item-product_cat_id">
                                    <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='29401.Ürün Kategorisi'></label>
                                    <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                                        <cfif len(get_opportunity.product_cat_id)>
                                            <cfset attributes.id = get_opportunity.product_cat_id>
                                            <cfinclude template="../../product/query/get_product_cat.cfm">
                                            <input type="hidden" name="product_cat_id" id="product_cat_id" value="#get_opportunity.product_cat_id#">
                                            <div class="input-group">
                                                <input type="text" name="product_cat" id="product_cat" value="#get_product_cat.hierarchy# #get_product_cat.product_cat#" onFocus="AutoComplete_Create('product_cat','HIERARCHY,PRODUCT_CAT','PRODUCT_CAT_NAME','get_product_cat','','PRODUCT_CATID','product_cat_id','','3','175');" autocomplete="off">
                                                <span class="input-group-addon btnPointer icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_product_cat_names&field_id=upd_opp.product_cat_id&field_name=upd_opp.product_cat');"></span>
                                            </div>
                                        <cfelse>
                                            <input type="hidden" name="product_cat_id" id="product_cat_id" value="">
                                            <div class="input-group">
                                                <input type="text" name="product_cat" id="product_cat" value="" onFocus="AutoComplete_Create('product_cat','HIERARCHY,PRODUCT_CAT','PRODUCT_CAT_NAME','get_product_cat','','PRODUCT_CATID','product_cat_id','','3','175');" autocomplete="off">
                                                <span class="input-group-addon btnPointer icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_product_cat_names&field_id=upd_opp.product_cat_id&field_name=upd_opp.product_cat');"></span>
                                            </div>
                                        </cfif>
                                    </div>
                                </div>
                                <div class="form-group" id="item-stock_id">
                                    <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='57657.Ürün'></label>
                                    <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                                        <input type="hidden" name="stock_id" id="stock_id" value="#get_opportunity.stock_id#">
                                        <cfif len(get_opportunity.stock_id)>
                                            <cfset attributes.stock_id = get_opportunity.stock_id>
                                            <cfinclude template="../query/get_stock_name.cfm">
                                        </cfif>
                                        <div class="input-group">
                                            <input type="text" name="stock_name" id="stock_name" value="<cfif len(get_opportunity.stock_id)>#get_stock_name.product_name#</cfif>" onFocus="AutoComplete_Create('stock_name','PRODUCT_NAME','PRODUCT_NAME','get_product_autocomplete','0','STOCK_ID','stock_id','','3','200');" autocomplete="off">
                                            <span class="input-group-addon btnPointer icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_product_names&field_id=upd_opp.stock_id&field_name=upd_opp.stock_name');"></span>
                                        </div>
                                    </div>
                                </div>
                                <div class="form-group" id="item-camp_id">
                                    <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='57446.Kampanya'></label>
                                    <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                                        <cfif len(get_opportunity.campaign_id)>
                                            <cfquery name="get_camp_info" datasource="#dsn3#">
                                                SELECT CAMP_ID,CAMP_HEAD FROM CAMPAIGNS WHERE CAMP_ID = #get_opportunity.campaign_id#
                                            </cfquery>
                                        <cfelse>
                                            <cfset get_camp_info.camp_head = ''>
                                        </cfif>
                                        <input type="hidden" name="camp_id" id="camp_id" value="#get_opportunity.campaign_id#">
                                        <div class="input-group">
                                            <input type="text" name="camp_name" id="camp_name" value="#get_camp_info.camp_head#">
                                            <span class="input-group-addon btnPointer icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_campaigns&field_id=upd_opp.camp_id&field_name=upd_opp.camp_name');"></span>
                                        </div>
                                    </div>
                                </div>
                                <div class="form-group" id="item-sales_member_id">
                                    <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='40904.Satış Ortağı'></label>
                                    <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                                        <cfif len(get_opportunity.sales_partner_id)>
                                            <input type="hidden" name="sales_member_id" id="sales_member_id" value="#get_opportunity.sales_partner_id#">
                                            <input type="hidden" name="sales_member_type" id="sales_member_type" value="partner">
                                            <div class="input-group">
                                                <input type="text" name="sales_member" id="sales_member" value="#get_par_info(get_opportunity.sales_partner_id,0,1,0)#" onFocus="AutoComplete_Create('sales_member','MEMBER_NAME,MEMBER_PARTNER_NAME','MEMBER_PARTNER_NAME2,MEMBER_NAME2','get_member_autocomplete','\'1,2\'','PARTNER_ID,MEMBER_TYPE','sales_member_id,sales_member_type','','3','250');" autocomplete="off">
                                                <span class="input-group-addon btnPointer icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_pars&is_period_kontrol=0&field_id=upd_opp.sales_member_id&field_name=upd_opp.sales_member_person&field_comp_name=upd_opp.sales_member&field_type=upd_opp.sales_member_type<cfif session.ep.isBranchAuthorization>&is_store_module=1</cfif>&select_list=7,8');"></span>
                                            </div>
                                        <cfelseif len(get_opportunity.sales_consumer_id)>
                                            <input type="hidden" name="sales_member_id" id="sales_member_id" value="#get_opportunity.sales_consumer_id#">
                                            <input type="hidden" name="sales_member_type" id="sales_member_type"  value="consumer">
                                            <div class="input-group">
                                                <input type="text" name="sales_member" id="sales_member" value="#get_cons_info(get_opportunity.sales_consumer_id,0,0)#" onFocus="AutoComplete_Create('sales_member','MEMBER_NAME,MEMBER_PARTNER_NAME','MEMBER_PARTNER_NAME2,MEMBER_NAME2','get_member_autocomplete','\'1,2\'','PARTNER_ID,MEMBER_TYPE','sales_member_id,sales_member_type','','3','250');" autocomplete="off">
                                                <span class="input-group-addon btnPointer icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_pars&is_period_kontrol=0&field_id=upd_opp.sales_member_id&field_name=upd_opp.sales_member_person&field_comp_name=upd_opp.sales_member&field_type=upd_opp.sales_member_type<cfif session.ep.isBranchAuthorization>&is_store_module=1</cfif>&select_list=7,8');"></span>
                                            </div>
                                        <cfelse>
                                            <input type="hidden" name="sales_member_id" id="sales_member_id" value="">
                                            <input type="hidden" name="sales_member_type" id="sales_member_type" value="">
                                            <div class="input-group">
                                                <input type="text" name="sales_member" id="sales_member"  value="" onFocus="AutoComplete_Create('sales_member','MEMBER_NAME,MEMBER_PARTNER_NAME','MEMBER_PARTNER_NAME2,MEMBER_NAME2','get_member_autocomplete','\'1,2\'','PARTNER_ID,MEMBER_TYPE','sales_member_id,sales_member_type','','3','250');" autocomplete="off">
                                                <span class="input-group-addon btnPointer icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_pars&is_period_kontrol=0&field_id=upd_opp.sales_member_id&field_name=upd_opp.sales_member_person&field_comp_name=upd_opp.sales_member&field_type=upd_opp.sales_member_type<cfif session.ep.isBranchAuthorization>&is_store_module=1</cfif>&select_list=7,8');"></span>
                                            </div>
                                        </cfif>
                                    </div>
                                </div>
                                <div class="form-group" id="item-sales_person">
                                    <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='40904.Satış Ortağı'><cf_get_lang dictionary_id='57578.Yetkili'></label>
                                    <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                                        <cfif len(get_opportunity.sales_partner_id)>
                                            
                                            <input type="text" name="sales_member_person" id="sales_member_person" value="#get_par_info(get_opportunity.sales_partner_id,0,-1,0)#" readonly>
                                        <cfelseif len(get_opportunity.sales_consumer_id)>
                                            <input type="text" name="sales_member_person" id="sales_member_person" value="#get_cons_info(get_opportunity.sales_consumer_id,0,0)#" readonly>
                                        <cfelse>
                                            <input type="text" name="sales_member_person" id="sales_member_person" readonly>
                                        </cfif>
                                    </div>
                                </div>
                                <div class="form-group" id="item-activity_time">
                                    <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='40919.Aksiyon'></label>
                                    <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                                        <select name="activity_time" id="activity_time">
                                            <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                            <option value="1" <cfif get_opportunity.activity_time eq 1> selected</cfif>><cf_get_lang dictionary_id='40884.Hemen'></option>
                                            <option value="7" <cfif get_opportunity.activity_time eq 7> selected</cfif>>1 <cf_get_lang dictionary_id='58734.Hafta'></option>
                                            <option value="30" <cfif get_opportunity.activity_time eq 30> selected</cfif>>1 <cf_get_lang dictionary_id='58724.Ay'></option>
                                            <option value="90" <cfif get_opportunity.activity_time eq 90> selected</cfif>>3 <cf_get_lang dictionary_id='58724.Ay'></option>
                                            <option value="180" <cfif get_opportunity.activity_time eq 180> selected</cfif>>6 <cf_get_lang dictionary_id='58724.Ay'></option>
                                            <option value="181" <cfif get_opportunity.activity_time eq 181> selected</cfif>>6 <cf_get_lang dictionary_id='40882.Aydan Fazla'></option>
                                        </select>
                                    </div>
                                </div>
                                <div class="form-group" id="item-probability">
                                    <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='58652.Olasılık'></label>
                                    <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                                        <select name="probability" id="probability">
                                            <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                            <cfloop query="get_probability_rate">
                                                <option value="#probability_rate_id#" <cfif  get_opportunity.probability eq probability_rate_id>selected</cfif>><!--- #get_probability_rate.probability_name# ---> #get_probability_rate.probability_name#</option>
                                            </cfloop>
                                        </select>
                                    </div>
                                </div>
                                <div class="form-group" id="item-sales_add_option">
                                    <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='41142.Özel Tanım'></label>
                                    <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                                        <select name="sales_add_option" id="sales_add_option">
                                            <option value=""><cf_get_lang dictionary_id ='57734.Seiniz'></option>
                                            <cfloop query="get_sale_add_option">
                                                <option value="#sales_add_option_id#" <cfif sales_add_option_id eq get_opportunity.sale_add_option_id>selected</cfif>>#sales_add_option_name#</option>
                                            </cfloop>
                                        </select>
                                    </div>
                                </div>
                                <div class="form-group" id="item-income">
                                    <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='40917.Tahmini Gelir'></label>
                                        <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                                            <div class="input-group">
                                                <input type="text" name="income" id="income" class="moneybox" value="#TLFormat(get_opportunity.income)#" onkeyup="return(FormatCurrency(this,event));">
                                                <span class="input-group-addon width">
                                                <select name="money" id="money">
                                                    <cfloop query="get_moneys">
                                                        <option value="#money#" <cfif money is get_opportunity.money>selected</cfif>>#money#</option>
                                                    </cfloop>
                                                </select>
                                            </span>
                                        </div>
                                    </div>
                                </div>
                                <div class="form-group" id="item-cost">
                                    <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id ='41187.Tahmini Maliyet'></label>
                                     <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                                        <div class="input-group">
                                            <input type="text" name="cost" id="cost" class="moneybox" value="#TLFormat(get_opportunity.cost)#" onkeyup="return(FormatCurrency(this,event));">
                                            <span class="input-group-addon width">
                                                <select name="money2" id="money2">
                                                    <cfloop query="get_moneys">
                                                        <option value="#money#" <cfif money is get_opportunity.money2>selected</cfif>>#money#</option>
                                                    </cfloop>
                                                </select>
                                            </span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="col col-4 col-md-4 col-sm-12 col-xs-12" type="column" index="3" sort="true">
                                <div class="form-group">
                                    <label class="col col-4 col-md-4 col-sm-4 col-xs-12" extra_checkbox="opp_status"><cf_get_lang dictionary_id='57493.Aktif'></label>
                                    <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                                        <input type="checkbox" name="opp_status" id="opp_status" value="1" <cfif get_opportunity.opp_status>checked</cfif>>
                                    </div>
                                </div>
                                <div class="form-group" id="item-action_date">
                                    <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='40824.Kazanılma Tarihi'></label>
                                    <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                                        <div class="input-group">
                                            <input type="text" name="action_date" id="action_date" value="#dateformat(get_opportunity.action_date,dateformat_style)#" validate="#validate_style#" maxlength="10">
                                            <span class="input-group-addon"><cf_wrk_date_image date_field="action_date"></span>
                                        </div>
                                    </div>
                                </div>
                                <div class="form-group" id="item-opp_invoice_date">
                                    <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='58759.Fatura Tarihi'></label>
                                    <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                                        <div class="input-group">
                                            <input type="text" name="opp_invoice_date" id="opp_invoice_date" value="#dateformat(get_opportunity.invoice_date,dateformat_style)#" validate="#validate_style#" maxlength="10">
                                            <span class="input-group-addon"><cf_wrk_date_image date_field="opp_invoice_date"></span>
                                        </div>
                                    </div>
                                </div>
                                <div class="form-group" id="item-opp_currency_id">
                                    <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='57482.Aşama'></label>
                                    <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                                        <select name="opp_currency_id" id="opp_currency_id">
                                            <option value=""><cf_get_lang dictionary_id ='57734.Seciniz'></option>
                                            <cfloop query="get_opp_currencies">
                                                <option value="#opp_currency_id#" <cfif opp_currency_id eq get_opportunity.opp_currency_id>selected</cfif>>#opp_currency#</option>
                                            </cfloop>
                                        </select>
                                    </div>
                                </div>
                                <div class="form-group" id="item-sales_zone_id">
                                    <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id ='57659.Satis bolgesi'></label>
                                    <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                                        <cfsavecontent variable="text"><cf_get_lang dictionary_id='57734.Seciniz'></cfsavecontent>
                                        <cf_wrk_saleszone 
                                        width="120"
                                        name="sales_zone_id"
                                        option_text="#text#"
                                        value="#get_opportunity.sz_id#">
                                    </div>
                                </div>
                                <div class="form-group" id="item-country_id">
                                    <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id ='58219.Ulke'></label>
                                    <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                                        <select name="country_id1" id="country_id1" onchange="auto_sales_zone();">
                                            <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                            <cfloop query="get_country_1">
                                                <option value="#country_id#" <cfif get_opportunity.country_id eq country_id> selected </cfif>>#country_name#</option>
                                            </cfloop>
                                        </select>
                                    </div>
                                </div>
                                <div class="form-group" id="item-commethod_id">
                                    <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='58143.İletişim'></label>
                                    <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                                        <cf_wrkComMethod width="140" ComMethod_Id="#iif(len(get_opportunity.commethod_id),get_opportunity.commethod_id,DE('commethod_id'))#">
                                    </div>
                                </div>
                                <div class="form-group" id="item-rival_company_id">
                                    <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='58779.Rakip'></label>
                                    <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                                        <input type="hidden" name="rival_company_id" id="rival_company_id" value="#get_opportunity.rival_company_id#">
                                        <input type="hidden" name="rival_partner_id" id="rival_partner_id" value="#get_opportunity.rival_partner_id#">
                                        <div class="input-group">
                                            <input name="rival_company" type="text" id="rival_company" onFocus="AutoComplete_Create('rival_company','MEMBER_NAME,MEMBER_PARTNER_NAME','MEMBER_NAME,MEMBER_PARTNER_NAME','get_member_autocomplete','1','COMPANY_ID,PARTNER_ID','rival_company_id,rival_partner_id','','3','250');" value="#get_par_info(get_opportunity.rival_partner_id,0,1,0)#" autocomplete="off">
                                            <span class="input-group-addon btnPointer icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_all_pars&field_partner=upd_opp.rival_partner_id&field_comp_id=upd_opp.rival_company_id&field_comp_name=upd_opp.rival_company&&select_list=7');"></span>
                                        </div>
                                    </div>
                                </div>
                                <div class="form-group" id="item-rival_preference_reason">
                                    <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='41387.Rakip Tercih Nedeni'></label>
                                    <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                                    <cf_multiselect_check
                                        name="rival_preference_reason"
                                        query_name="GET_RIVAL_PREFERENCE_REASONS"
                                        option_name="PREFERENCE_REASON"
                                        option_value="PREFERENCE_REASON_ID"
                                        value="#get_opportunity.preference_reason_id#">
                                    </div>
                                </div>
                                <div class="form-group" id="item-wrk_add_info">
                                    <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='57810.Ek Bilgi'></label>
                                    <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                                        <cf_wrk_add_info info_type_id="-16" info_id="#attributes.opp_id#" upd_page = "1" colspan="9">
                                    </div>
                                </div>
                                <div class="form-group" id="item-add_rss">
                                    <label class="col col-4 col-md-4 col-sm-4 col-xs-12">
                                        <cf_get_lang dictionary_id='40819.RSS de Gorunsun'>
                                        <input type="checkbox" name="add_rss" id="add_rss" <cfif len(get_opportunity.add_rss) and get_opportunity.add_rss eq 1>checked</cfif>/>
                                    </label>
                                </div>
                            </div>
                            <div class="col col-12 col-xs-12 col-sm-12 col-xs-12" type="column" index="4" sort="true">
                                <div class="form-group" id="item-subject">
                                    <label class="col col-12 col-xs-12"><span class="hide"><cf_get_lang dictionary_id='30637.Editör'></span></label>
                                    <div class="col col-12 col-xs-12" id="fckedit">
                                        <cfmodule
                                            template="../../../fckeditor/fckeditor.cfm"
                                            toolbarSet="WRKContent"
                                            basePath="/fckeditor/"
                                            instanceName="opp_detail"
                                            valign="top"
                                            value="#get_opportunity.opp_detail#"
                                            width="800"
                                            height="200">
                                    </div>
                                </div>
                            </div>
                        </cf_box_elements>
                        <cf_box_footer>
                            <div class="col col-6"><cf_record_info query_name="get_opportunity" is_partner='1'></div>
                            <div class="col col-6">
                                <cfif xml_process_update_opportunity neq 1 and get_opportunity.is_processed eq 1>
                                    <div style="padding:3px; float:right;"><font color="red"><strong><cf_get_lang dictionary_id='40941.Islendi'></strong></font></div>
                                <cfelse>
                                    <cf_workcube_buttons is_upd='1' is_delete=1  add_function='kontrol()'>
                                </cfif>
                            </div>
                        </cf_box_footer>
                    
                </cfform>
            </cf_box>
            <cfif isdefined("get_contact_simple")>
                <cfset str= '&contact_mail=#get_contact_simple.email#&contact_person=#get_contact_simple.name# #get_contact_simple.surname#&contact_id=#get_contact_simple.id#'>
            <cfelse>
                <cfset str= ''>
            </cfif>
            <cfif get_module_user(11)>
                <cf_box
                    title="#getLang('','Takipler',40864)#"
                    id="box_followup_b"
                    closable="0"
                    box_page="#request.self#?fuseaction=sales.list_opportunity_plus&opp_id=#attributes.opp_id#"
                    add_href="openBoxDraggable('#request.self#?fuseaction=sales.popup_form_add_opp_plus&opp_id=#get_opportunity.opp_id#&header=upd_opp.opp_head#str#&draggable=1','','ui-draggable-box-medium')"
                    unload_body = "1"
                    add_href_size="project">
                </cf_box>
            </cfif>
            <cfif xml_sample_list eq 1 >
                <cf_box
                title="#getlang('','numune','62603')#"
                id="box_sample_b"
                closable="0"
                widget_load="sampleopportunity"
                widget_parameters="opp_id=#attributes.opp_id#"
                add_href="openBoxDraggable('#request.self#?fuseaction=product.product_sample&event=add&opp_id=#attributes.opp_id#')"
                unload_body = "1"
                add_href_size="sample">
                </cf_box>
            </cfif>
            <cfif get_module_user(1)>
                <cfsavecontent variable="message"><cf_get_lang dictionary_id='58020.İşler'></cfsavecontent>
                <cfset adres_ = "#request.self#?fuseaction=project.emptypopup_ajax_project_works&opp_id=#attributes.opp_id#">
                <cfif xml_is_opportunity_actions eq 1>
                    <cfset adres_ = "#adres_#&action_project_id=#get_opportunity.project_id#">
                </cfif>
                <cfif listFindNoCase(session.ep.user_level,1)>
                    <cf_box title="#message#" box_page="#adres_#" closable="0" id="box_works_b"></cf_box>
                </cfif>
            </cfif>
            <cfif get_module_user(11)>
                <cfsavecontent variable="message1"><cf_get_lang dictionary_id="29528.Tedarikçiler"></cfsavecontent>
                <cf_box id="list_supplier_b"
                    box_page="#request.self#?fuseaction=sales.emptypopup_ajax_opp_supplier&opp_id=#attributes.opp_id#"
                    title="#message1#"
                    closable="0">
                </cf_box>
            </cfif>
            <cfif get_module_user(11)>
                <cfsavecontent variable="message2"><cf_get_lang dictionary_id='40818.Rakipler'></cfsavecontent>
                <cf_box id="list_rival_b" box_page="#request.self#?fuseaction=sales.emptypopup_ajax_opp_rival&opp_id=#attributes.opp_id#"title="#message2#" closable="0"></cf_box>
            </cfif>
        </div>
        <div class="col col-3 col-md-3 col-sm-3 col-xs-12 uniqueRow">
            <cfinclude template="../form/upd_opportunity_sag.cfm">
        </div>
</cfoutput>
<script type="text/javascript">
	function return_company()
	{
		if(document.getElementById('ref_member_type').value=='employee')
		{
			var emp_id=document.getElementById('ref_employee_id').value;
			var GET_COMPANY=wrk_safe_query('sls_get_cmpny','dsn',0,emp_id);
				document.getElementById('ref_company_id').value=GET_COMPANY.COMP_ID;
		}
		else
			return false;
	}
function fill_country(member_id,type)
{
	if(document.getElementById('country_id1') != undefined)
	{
		if(member_id==0)
		{
			if(document.getElementById('member_type').value=='partner')
			{
				member_id=document.getElementById('company_id1').value;
				type=1;
			}
			else if(document.getElementById('member_type').value=='consumer')
			{
				member_id=document.getElementById('member_id').value;
				type=2;
			}
		}
		document.getElementById('country_id1').value='';
		document.getElementById('sales_zone_id').value='';
		if(type == 1)
		{
			get_country = wrk_safe_query("get_country",'dsn',0,member_id);
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
		alert("<cf_get_lang dictionary_id ='40952.Ülke ile İlişkili Satış Bölgesi Bulunamadı'> !");
		return false;
	}
	else if(get_sales_zone_id.recordcount > 1)
	{
		alert("<cf_get_lang dictionary_id ='40955.Ülke ile İlişkili Birden Fazla Satış Bölgesi Bulunmaktadır'> !");
		return false;
	}
}
</script>
