<cf_xml_page_edit fuseact ="sales.list_subscription_contract">
<cfparam name="attributes.start_date" default="">
<cfparam name="attributes.finish_date" default="">
<cfparam name="attributes.process_stage_type" default="">
<cfparam name="attributes.product_name" default="">
<cfparam name="attributes.product_id" default="">
<cfparam name="attributes.subscription_type" default="">
<cfparam name="attributes.sale_add_option" default="">
<cfparam name="attributes.subs_add_option" default="">
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.keyword_no" default="">
<cfparam name="attributes.adress_keyword" default="">
<cfparam name="attributes.semt_keyword" default="">
<cfparam name="attributes.member_cat_type" default="">
<cfparam name="attributes.sort_type" default="4">
<cfparam name="attributes.project_id" default="">
<cfparam name="attributes.project_head" default="">
<cfparam name="attributes.use_efatura" default="">
<cfparam name="attributes.page" default="1">
<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'> 
<cfset attributes.startrow = ((attributes.page-1)*attributes.maxrows) + 1 >

<cfset contract_cmp = createObject("component","V16.sales.cfc.subscription_contract")>

<cfif not isDefined("GET_SUBSCRIPTION_AUTHORITY")> 
    <!--- 20190927 abone kategorsine göre yetkilendirme için include edildiği sayfada çekilmiş olabilir bu nedenle kontrol ekledik Author: Tolga Sütlü, Ahmet Yolcu--->
    <cfset gsa = createObject("component","V16.objects.cfc.subscriptionNauthority")/>
    <cfset GET_SUBSCRIPTION_AUTHORITY= gsa.SelectAuthority()/>
</cfif>
<cfif isDefined('attributes.asset_id') and len(attributes.asset_id)>
    <cfset get_asset_name_ = contract_cmp.get_assetp_name(asset_id : attributes.asset_id)>
    <cfparam name="attributes.asset_id" default="#attributes.asset_id#">
    <cfparam name="attributes.asset_name" default="#get_asset_name_.assetp#">
<cfelse>
    <cfparam name="attributes.asset_id" default="">
    <cfparam name="attributes.asset_name" default="">
</cfif>
<cfif isdefined("attributes.form_submitted")> 
    <cfif isdefined("attributes.start_date") and len(attributes.start_date)><cf_date tarih="attributes.start_date"></cfif>
    <cfif isdefined("attributes.finish_date") and len(attributes.finish_date)><cf_date tarih="attributes.finish_date"></cfif>
    <cfquery name="get_comp_info" datasource="#dsn#">
        SELECT COMMON_SUBSCRIPTION_USAGE FROM OUR_COMPANY_INFO WHERE COMP_ID = #session.ep.company_id#
    </cfquery>
    <cfif len(get_comp_info.COMMON_SUBSCRIPTION_USAGE)>
        <cfset dsn3 = "#dsn#_#get_comp_info.COMMON_SUBSCRIPTION_USAGE#">
    </cfif>
    <cfset GET_SUBSCRIPTIONS = contract_cmp.GET_SUBSCRIPTIONS(
        dsn3:dsn3,
        dsn_alias:dsn_alias,
        process_stage_type:'#iIf(isDefined("attributes.process_stage_type") and len(attributes.process_stage_type),"attributes.process_stage_type",DE(""))#',
        use_efatura:'#iIf(len(attributes.use_efatura),"attributes.use_efatura",DE(""))#',
        subs_add_option:'#iIf(isDefined("attributes.subs_add_option") and len(attributes.subs_add_option),"attributes.subs_add_option",DE(""))#',
        sale_add_option:'#iIf(isDefined("attributes.sale_add_option") and len(attributes.sale_add_option),"attributes.sale_add_option",DE(""))#',
        keyword:'#iIf(isDefined("attributes.keyword") and len(attributes.keyword),"attributes.keyword",DE(""))#',
        keyword_no:'#iIf(isDefined("attributes.keyword_no") and len(attributes.keyword_no),"attributes.keyword_no",DE(""))#',
        start_date:'#iIf(isDefined("attributes.start_date") and len(attributes.start_date),"attributes.start_date",DE(""))#',
        finish_date:'#iIf(isDefined("attributes.finish_date") and len(attributes.finish_date),"attributes.finish_date",DE(""))#',
        status:'#iIf(isDefined("attributes.status") and len(attributes.status),"attributes.status",DE(""))#',
        employee_id:'#iIf(isDefined("attributes.employee_id") and len(attributes.employee_id) and isDefined("attributes.employee_name") and len(attributes.employee_name),"attributes.employee_id",DE(""))#',
        company_id:'#iIf(isdefined("attributes.member_type") and (attributes.member_type is 'partner') and len(attributes.member_name) and len(attributes.company_id),"attributes.company_id",DE(""))#',
        consumer_id:'#iIf(isdefined("attributes.member_type") and (attributes.member_type is 'consumer') and len(attributes.member_name) and len(attributes.consumer_id),"attributes.consumer_id",DE(""))#',
        member_cat_type:'#iIf(isdefined("attributes.member_cat_type") and listlen(attributes.member_cat_type),"attributes.member_cat_type",DE(""))#',
        subscription_type:'#iIf(isDefined("attributes.subscription_type") and len(attributes.subscription_type),"attributes.subscription_type",DE(""))#',
        project_id:'#iIf(isdefined("attributes.project_head") and len(attributes.project_head) and isdefined('attributes.project_id') and len(attributes.project_id),"attributes.project_id",DE(""))#',
        sales_emp_id:'#iIf(isdefined("attributes.sales_emp") and len(attributes.sales_emp) and isdefined("attributes.sales_emp_id") and len(attributes.sales_emp_id),"attributes.sales_emp_id",DE(""))#',
        sales_partner_id:'#iIf(isdefined("attributes.sales_partner") and len(attributes.sales_partner) and isdefined("attributes.sales_partner_id") and len(attributes.sales_partner_id),"attributes.sales_partner_id",DE(""))#',
        product_id:'#iIf(len(attributes.product_id) and len(attributes.product_name),"attributes.product_id",DE(""))#',
        adress_keyword:'#iIf(isDefined("attributes.adress_keyword") and len(attributes.adress_keyword),"attributes.adress_keyword",DE(""))#',
        city_id:'#iIf(isDefined("attributes.city_id") and len(attributes.city_id),"attributes.city_id",DE(""))#',
        county_id:'#iIf(isDefined("attributes.county_id") and len(attributes.county_id),"attributes.county_id",DE(""))#',
        semt_keyword:'#iIf(isDefined("attributes.semt_keyword") and len(attributes.semt_keyword),"attributes.semt_keyword",DE(""))#',
        x_control_ims:'#iIf(isDefined("x_control_ims") and len(x_control_ims),"x_control_ims",DE(""))#',
        sort_type:'#iIf(len(attributes.sort_type),"attributes.sort_type",DE(""))#',
        asset_id:'#iIf(isdefined("attributes.asset_name") and len(attributes.asset_name) and isdefined("attributes.asset_id") and len(attributes.asset_id),"attributes.asset_id",DE(""))#',
        startrow:attributes.startrow,
        maxrows:attributes.maxrows,
        sales_zone_followup:session.ep.our_company_info.sales_zone_followup,
        IS_SUBSCRIPTION_AUTHORITY : get_subscription_authority.IS_SUBSCRIPTION_AUTHORITY
    )>
<cfelse> 
	<cfset get_subscriptions.recordCount = 0>
</cfif> 

<cfset GET_SUBSCRIPTION_TYPE = contract_cmp.GET_SUBSCRIPTION_TYPE(dsn3:dsn3,IS_SUBSCRIPTION_AUTHORITY:get_subscription_authority.IS_SUBSCRIPTION_AUTHORITY)>
<cfset GET_SUBS_ADD_OPTION = contract_cmp.GET_SUBS_ADD_OPTION(dsn3:dsn3)>
<cfset GET_SALE_ADD_OPTION = contract_cmp.GET_SALE_ADD_OPTION(dsn3:dsn3, language:session.ep.language)>
<cfset GET_SERVICE_STAGE = contract_cmp.GET_SERVICE_STAGE(company_id:session.ep.company_id)>
<cfset GET_COMPANY_CAT = contract_cmp.GET_COMPANY_CAT(company_id:session.ep.company_id, userid:session.ep.userid)>
<cfset GET_CONSUMER_CAT = contract_cmp.GET_CONSUMER_CAT(company_id:session.ep.company_id, userid:session.ep.userid)>

<cfif get_subscriptions.recordcount>
    <cfparam name="attributes.totalrecords" default='#get_subscriptions.QUERY_COUNT#'>
<cfelse>
	<cfparam name="attributes.totalrecords" default='0'>
</cfif>

<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box>
        <cfform name="subscription_list" id="subscription_list" method="post" action="#request.self#?fuseaction=sales.list_subscription_contract">
            <input type="hidden" name="form_submitted" id="form_submitted" value="1">
            <cf_box_search>
                <div class="form-group" id="form_ul_keyword">
                    <cfsavecontent variable="place"><cf_get_lang dictionary_id='57460.Filtre'></cfsavecontent>
                    <cfinput type="text" name="keyword" id="keyword" value="#attributes.keyword#" maxlength="50" placeholder="#place#">
                </div>
                <div class="form-group" id="form_ul_keyword_no">
                    <cfsavecontent variable="place"><cf_get_lang dictionary_id='29502.Abone No'></cfsavecontent>
                    <cfinput type="text" name="keyword_no" value="#attributes.keyword_no#" maxlength="50" placeholder="#place#">
                </div>
                <div class="form-group" id="form_ul_start_date">
                    <div class="input-group">
                        <cfsavecontent variable="message"><cf_get_lang dictionary_id ='41039.Lütfen Başlangıç Tarihi Kontrol Ediniz'>!</cfsavecontent>
                        <cfinput type="text" name="start_date" id="start_date" value="#dateformat(attributes.start_date,dateformat_style)#" validate="#validate_style#" maxlength="10" message="#message#">
                        <span class="input-group-addon"><cf_wrk_date_image date_field="start_date"></span>
                    </div>
                </div>
                <div class="form-group" id="form_ul_finish_date">
                    <div class="input-group">
                        <cfsavecontent variable="message"><cf_get_lang dictionary_id ='41040.Lütfen Bitiş Tarihi Kontrol Ediniz'>!</cfsavecontent>
                        <cfinput type="text" name="finish_date" id="finish_date" value="#dateformat(attributes.finish_date, dateformat_style)#" validate="#validate_style#" maxlength="10" message="#message#">
                        <span class="input-group-addon"><cf_wrk_date_image date_field="finish_date"></span>
                    </div>
                </div>
                <div class="form-group" id="form_ul_sort_type">
                    <select name="sort_type" id="sort_type">
                        <option value="0" <cfif attributes.sort_type eq 0>selected</cfif>><cf_get_lang dictionary_id='41430.No ya Göre Azalan'></option>
                        <option value="1" <cfif attributes.sort_type eq 1>selected</cfif>><cf_get_lang dictionary_id='41431.No ya Göre Artan'></option>
                        <option value="2" <cfif attributes.sort_type eq 2>selected</cfif>><cf_get_lang dictionary_id='41432.Kategoriye Göre Azalan'></option>
                        <option value="3" <cfif attributes.sort_type eq 3>selected</cfif>><cf_get_lang dictionary_id='41433.Kategoriye Göre Artan'></option>
                        <option value="4" <cfif attributes.sort_type eq 4>selected</cfif>><cf_get_lang dictionary_id='41434.Sözlesme Tarihine Göre Azalan'></option>
                        <option value="5" <cfif attributes.sort_type eq 5>selected</cfif>><cf_get_lang dictionary_id='41435.Sözlesme Tarihine Göre Artan'></option>
                        <option value="6" <cfif attributes.sort_type eq 6>selected</cfif>><cf_get_lang dictionary_id='41436.Özel Koda Göre Azalan'></option>
                        <option value="7" <cfif attributes.sort_type eq 7>selected</cfif>><cf_get_lang dictionary_id='41437.Özel Koda Göre Artan'></option>
                    </select>
                </div>
                <div class="form-group" id="form_ul_status">
                    <select name="status" id="status">
                        <option value="1"<cfif isdefined('attributes.status') and (attributes.status eq 1)> selected</cfif>><cf_get_lang dictionary_id='57493.Aktif'></option>
                        <option value="0"<cfif isdefined('attributes.status') and (attributes.status eq 0)> selected</cfif>><cf_get_lang dictionary_id='57494.Pasif'></option>
                        <option value="" <cfif isdefined('attributes.status') and (attributes.status neq 0) and (attributes.status neq 1)> selected</cfif>><cf_get_lang dictionary_id='57708.Tumu'></option>
                    </select>
                </div>
                <div class="form-group small" id="form_ul_maxrows">
                    <cfsavecontent variable="message"><cf_get_lang dictionary_id='57537.Sayi_Hatasi_Mesaj'></cfsavecontent>
                    <cfinput type="text" name="maxrows" value="#attributes.maxrows#" maxlength="3" onKeyUp="isNumber(this)" validate="integer" range="1," required="yes" message="#message#">
                </div>
                <div class="form-group">
                    <cf_wrk_search_button button_type="4" search_function="date_check(subscription_list.start_date,subscription_list.finish_date,'#getLang('','Tarih Değerini Kontrol Ediniz',57782)#')">
                </div>
                <div class="form-group">
                    <cfoutput><a class="ui-btn ui-btn-gray2" onclick="openBoxDraggable('#request.self#?fuseaction=sales.popup_add_multi_provision');"><i class="icon-POS" title="<cf_get_lang dictionary_id='48865.Sanal Pos'>"></i></a></cfoutput>
                </div>
                <div class="form-group">
                    <cfoutput><a class="ui-btn ui-btn-gray2" onClick="windowopen('#request.self#?fuseaction=objects.popup_view_map&allmap=1&type=2&<cfif isdefined("attributes.status")>status=#attributes.status#<cfelse>status=1</cfif>','white_board','popup_view_map')"><i class="icn-md fa fa-map-marker" title="<cf_get_lang dictionary_id='58849.Haritada Göster'>"></i></a></cfoutput>
                </div>
                <cf_workcube_file_action pdf='1' mail='1' doc='1' print='1'>
            </cf_box_search>
            <cf_box_search_detail>
                <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
                    <div class="form-group" id="form_ul_use_efatura">
                        <cfif session.ep.our_company_info.is_efatura>
                            <label class="col col-12"><cf_get_lang dictionary_id="29872.E-Fatura"></label>
                            <div class="col col-12">
                                <select name="use_efatura" id="use_efatura">
                                    <option value=""><cf_get_lang dictionary_id="29872.E-Fatura"></option>
                                    <option value="1" <cfif attributes.use_efatura eq 1>selected="selected"</cfif>><cf_get_lang dictionary_id='29492.Kullanıyor'></option>
                                    <option value="0" <cfif attributes.use_efatura eq 0>selected="selected"</cfif>><cf_get_lang dictionary_id='29493.Kullanmıyor'></option>
                                </select>
                            </div>
                        </cfif>
                    </div>
                    <div class="form-group" id="form_ul_suscription_type">
                        <label class="col col-12"><cf_get_lang dictionary_id ='57486.Kategori'></label>
                        <div class="col col-12">
                            <select name="subscription_type" id="subscription_type">
                                <option value=""><cf_get_lang dictionary_id ='57486.Kategori'></option>
                                    <cfoutput query="get_subscription_type">
                                        <option value="#subscription_type_id#" <cfif attributes.subscription_type eq subscription_type_id>selected</cfif>>#subscription_type#</option>
                                    </cfoutput>
                            </select>
                        </div>
                    </div>
                    <div class="form-group" id="form_ul_process_stage_type">
                        <label class="col col-12"><cf_get_lang dictionary_id ='57482.Aşama'></label>
                        <div class="col col-12">
                            <select name="process_stage_type" id="process_stage_type">
                            <option value=""><cf_get_lang dictionary_id ='57482.Aşama'></option>
                                <cfoutput query="get_service_stage">
                                        <option value="#process_row_id#" <cfif attributes.process_stage_type eq process_row_id>selected</cfif>>#stage#</option>
                                </cfoutput>
                            </select>
                        </div>
                    </div>
                    <div class="form-group" id="form_ul_subs_add_option">
                        <label class="col col-12"><cf_get_lang dictionary_id ='40946.Abone Özel Tanım'></label>
                        <div class="col col-12">
                            <select name="subs_add_option" id="subs_add_option">
                                <option value=""><cf_get_lang dictionary_id ='40946.Abone Özel Tanım'></option>
                                    <cfoutput query="get_subs_add_option">
                                        <option value="#subscription_add_option_id#" <cfif attributes.subs_add_option eq subscription_add_option_id>selected</cfif>>#subscription_add_option_name#</option>
                                    </cfoutput>
                            </select>
                        </div>
                    </div>
                    <div class="form-group" id="item-form_ul_asset_name">
                        <label class="col col-12 col-xs-12"><cf_get_lang dictionary_id='58833.Fiziki Varlık'></label>
                        <div class="col col-12 col-xs-12">
                            <cfif isDefined('attributes.asset_id') and len(attributes.asset_id)>
                                <cfset asset_id_ = '#attributes.asset_id#'>
                            <cfelse>
                                <cfset asset_id_ = ''>
                            </cfif>
                            <cf_wrkassetp asset_id="#asset_id_#" fieldid='asset_id' fieldname='asset_name' form_name='subscription_list' is_upd="1">
                        </div>
                    </div>
                </div>
                <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="2" sort="true">
                    <div class="form-group" id="form_ul_sale_add_option">
                        <label class="col col-12"><cf_get_lang dictionary_id ='41142.Satış Özel Tanım'></label>
                    <div class="col col-12">
                        <select name="sale_add_option" id="sale_add_option">
                            <option value=""><cf_get_lang dictionary_id ='41142.Satış Özel Tanım'></option>
                                <cfoutput query="get_sale_add_option">
                                        <option value="#sales_add_option_id#" <cfif attributes.sale_add_option eq sales_add_option_id>selected</cfif>>#sales_add_option_name#</option>
                                </cfoutput>
                        </select>
                    </div>
                    </div>
                    <div class="form-group" id="form_ul_member_cat_type">
                        <label class="col col-12"><cf_get_lang dictionary_id='58609.Üye Kategorisi'></label>
                        <div class="col col-12">
                            <select name="member_cat_type" id="member_cat_type">
                                <option value="" selected><cf_get_lang dictionary_id='58609.Üye Kategorisi'></option>
                                <option value="1" <cfif attributes.member_cat_type eq 1>selected</cfif>><cf_get_lang dictionary_id='58039.Kurumsal Üye Kategorileri'></option>
                                    <cfoutput query="get_company_cat">
                                        <option value="1-#COMPANYCAT_ID#" <cfif attributes.member_cat_type is '1-#COMPANYCAT_ID#'>selected</cfif>>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#COMPANYCAT#</option>
                                    </cfoutput>
                                    <option value="2" <cfif attributes.member_cat_type eq 2>selected</cfif>><cf_get_lang dictionary_id='58040.Bireysel Üye Kategorileri'></option>
                                    <cfoutput query="get_consumer_cat">
                                        <option value="2-#CONSCAT_ID#" <cfif attributes.member_cat_type is '2-#CONSCAT_ID#'>selected</cfif>>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#CONSCAT#</option>
                                    </cfoutput>
                            </select>
                        </div>
                    </div>
                    <div class="form-group" id="form_ul_project_head">
                        <label class="col col-12"><cf_get_lang dictionary_id='57416.Proje'></label>
                        <div class="col col-12">
                            <div class="input-group">
                                <cfoutput>
                                    <input type="hidden" name="project_id" id="project_id" value="#attributes.project_id#">
                                    <input type="text" name="project_head" id="project_head" value="#attributes.project_head#" onFocus="AutoComplete_Create('project_head','PROJECT_ID,PROJECT_HEAD','PROJECT_HEAD','get_project','','PROJECT_ID','project_id','form_basket','3','135')" autocomplete="off">
                                    <span class="input-group-addon icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_projects&project_id=subscription_list.project_id&project_head=subscription_list.project_head');"></span>
                                </cfoutput>
                            </div>
                        </div>
                    </div>
                    <div class="form-group" id="form_ul_member_name">
                        <label class="col col-12"><cf_get_lang dictionary_id='57457.Müşteri'></label>
                        <div class="col col-12">
                            <div class="input-group">
                                <input type="hidden" name="consumer_id" id="consumer_id" value="<cfif isdefined("attributes.consumer_id")><cfoutput>#attributes.consumer_id#</cfoutput></cfif>">
                                <input type="hidden" name="company_id" id="company_id" value="<cfif isdefined("attributes.company_id")><cfoutput>#attributes.company_id#</cfoutput></cfif>">
                                <input type="hidden" name="member_type" id="member_type" value="<cfif isdefined("attributes.member_type")><cfoutput>#attributes.member_type#</cfoutput></cfif>">
                                <input name="member_name" type="text" id="member_name" onFocus="AutoComplete_Create('member_name','MEMBER_NAME,MEMBER_PARTNER_NAME','MEMBER_NAME,MEMBER_PARTNER_NAME','get_member_autocomplete','\'1,2\'','CONSUMER_ID,COMPANY_ID,MEMBER_TYPE','consumer_id,company_id,member_type','','3','250');" value="<cfif isdefined("attributes.member_name") and len(attributes.member_name)><cfoutput>#attributes.member_name#</cfoutput></cfif>" autocomplete="off">
                                <cfset str_linke_ait="&field_consumer=subscription_list.consumer_id&field_comp_id=subscription_list.company_id&field_member_name=subscription_list.member_name&field_type=subscription_list.member_type">
                                <span class="input-group-addon icon-ellipsis" onClick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_all_pars<cfoutput>#str_linke_ait#</cfoutput>&select_list=7,8&keyword='+encodeURIComponent(document.subscription_list.member_name.value));"></span>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="3" sort="true">
                    <div class="form-group" id="form_ul_sales_partner">
                        <label class="col col-12"><cf_get_lang dictionary_id='40904.Satış Ortağı'></label>
                        <div class="col col-12">
                            <div class="input-group">
                                <input type="hidden" name="sales_partner_id" id="sales_partner_id" value="<cfif isdefined("attributes.sales_partner_id")><cfoutput>#attributes.sales_partner_id#</cfoutput></cfif>">
                                <input name="sales_partner" type="text" id="sales_partner" onFocus="AutoComplete_Create('sales_partner','MEMBER_PARTNER_NAME,MEMBER_NAME','MEMBER_PARTNER_NAME2,MEMBER_NAME2','get_member_autocomplete','\'1,2\',0,0,0','PARTNER_ID2','sales_partner_id','','3','125');" value="<cfif isdefined("attributes.sales_partner") and len(attributes.sales_partner)><cfoutput>#attributes.sales_partner#</cfoutput></cfif>" autocomplete="off">
                                <span class="input-group-addon icon-ellipsis" onClick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_pars&field_id=subscription_list.sales_partner_id&field_name=subscription_list.sales_partner&select_list=2,3');"></span>
                            </div>
                        </div>
                    </div>
                    <div class="form-group" id="form_ul_sales_emp">
                        <label class="col col-12"><cf_get_lang dictionary_id='41076.Satış Temsilcisi'></label>
                        <div class="col col-12">
                            <div class="input-group">
                                <input type="hidden" name="sales_emp_id" id="sales_emp_id" value="<cfif isdefined("attributes.sales_emp_id")><cfoutput>#attributes.sales_emp_id#</cfoutput></cfif>">
                                <input name="sales_emp" type="text" id="sales_emp" onFocus="AutoComplete_Create('sales_emp','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','3','EMPLOYEE_ID','sales_emp_id','','3','120');" value="<cfif isdefined("attributes.sales_emp") and len(attributes.sales_emp)><cfoutput>#get_emp_info(attributes.sales_emp_id,0,0)#</cfoutput></cfif>" autocomplete="off">
                                <span class="input-group-addon icon-ellipsis" onClick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_positions&field_emp_id=subscription_list.sales_emp_id&field_name=subscription_list.sales_emp&select_list=1');"></span>
                            </div>
                        </div>
                    </div>
                    <div class="form-group" id="form_ul_product_name">
                        <label class="col col-12"><cf_get_lang dictionary_id='57657.Ürün'></label>
                        <div class="col col-12">
                            <div class="input-group">
                                <input type="hidden" name="product_id" id="product_id" <cfif len(attributes.product_id) and len(attributes.product_name)>value="<cfoutput>#attributes.product_id#</cfoutput>"</cfif>>
                                <input name="product_name" type="text" id="product_name" onFocus="AutoComplete_Create('product_name','PRODUCT_NAME','PRODUCT_NAME','get_product','0','PRODUCT_ID','product_id','','2','200');" value="<cfif len(attributes.product_id) and len(attributes.product_name)><cfoutput>#attributes.product_name#</cfoutput></cfif>" autocomplete="off">
                                <span class="input-group-addon icon-ellipsis" onClick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_product_names&product_id=subscription_list.product_id&field_name=subscription_list.product_name&keyword='+encodeURIComponent(document.subscription_list.product_name.value));"></span>
                            </div>
                        </div>
                    </div>
                    <div class="form-group" id="form_ul_employee_name">
                        <label class="col col-12"><cf_get_lang dictionary_id='57899.Kaydeden'></label>
                        <div class="col col-12">
                            <div class="input-group">
                                <input type="hidden" name="employee_id" id="employee_id" value="<cfif isdefined("attributes.employee_id") and len(attributes.employee_id)><cfoutput>#attributes.employee_id#</cfoutput></cfif>">
                                <input type="text" name="employee_name" id="employee_name" value="<cfif isdefined("attributes.employee_id") and len(attributes.employee_id) and isdefined("attributes.employee_name") and len(attributes.employee_name)><cfoutput>#get_emp_info(attributes.employee_id,0,0)#</cfoutput></cfif>" onfocus="AutoComplete_Create('employee_name','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','3','EMPLOYEE_ID','employee_id','','3','125');" autocomplete="off">
                                <span class="input-group-addon icon-ellipsis" onClick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_positions&field_emp_id=subscription_list.employee_id&field_name=subscription_list.employee_name&select_list=1');"></span>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="4" sort="true">
                    <div class="form-group" id="form_ul_adress_keyword">
                        <label class="col col-12"><cf_get_lang dictionary_id='58723.Adres'></label>
                        <div class="col col-12">
                            <cfinput type="text" name="adress_keyword" value="#attributes.adress_keyword#" maxlength="255">
                        </div>
                    </div>
                    <div class="form-group" id="form_ul_semt_keyword">
                        <label class="col col-12"><cf_get_lang dictionary_id ='58132.Semt'></label>
                        <div class="col col-12">
                            <cfinput type="text" name="semt_keyword" value="#attributes.semt_keyword#" maxlength="50">
                        </div>
                    </div>
                    <div class="form-group" id="form_ul_city">
                        <label class="col col-12"><cf_get_lang dictionary_id ='58608.İl'></label>
                        <div class="col col-12">
                            <div class="input-group">
                                <cf_wrk_places form_name='subscription_list' place_name='city' place_id='city_id' is_type='2'>
                                <input type="hidden" name="city_id" id="city_id" value="<cfif isdefined('attributes.city_id') and len(attributes.city)><cfoutput>#attributes.city_id#</cfoutput></cfif>">
                                <input type="text" name="city" id="city" onChange="city_temizle();" value="<cfif isdefined('attributes.city_id') and len(attributes.city)><cfoutput>#attributes.city#</cfoutput></cfif>" onKeyUp="get_place_1();">
                                <span class="input-group-addon icon-ellipsis" onClick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_dsp_city&field_id=subscription_list.city_id&field_name=subscription_list.city');"></span>
                            </div>
                        </div>
                    </div>
                    <div class="form-group" id="form_ul_">
                        <label class="col col-12"><cf_get_lang dictionary_id='58638.İlçe'></label>
                        <div class="col col-12">
                            <div class="input-group">
                                <cf_wrk_places form_name='subscription_list' place_name='county' place_id='county_id' is_type='3' is_multi_no='2'>
                                <input type="hidden" name="county_id" id="county_id" value="<cfif isdefined('attributes.county_id') and len(attributes.county)><cfoutput>#attributes.county_id#</cfoutput></cfif>">
                                <input type="text" name="county" id="county" onChange="county_temizle();" value="<cfif isdefined('attributes.county_id') and len(attributes.county)><cfoutput>#attributes.county#</cfoutput></cfif>" onKeyUp="get_place_2();">
                                <span class="input-group-addon icon-ellipsis" onClick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_dsp_county&field_id=subscription_list.county_id&field_name=subscription_list.county&city_id=' + document.subscription_list.city_id.value);"></span>
                            </div>
                        </div>
                    </div>
                </div>
            </cf_box_search_detail>
        </cfform>
    </cf_box>
        <cfset colspan_ = 13>
    <cf_box title="#getLang('','Aboneler',30003)#" uidrop="1" hide_table_column="1" >
        <cf_grid_list>
            <thead>
                <tr>
                    <th width="30"><cf_get_lang dictionary_id='58577.Sıra'></th>
                    <th><cf_get_lang dictionary_id='29502.Abone No'></th>
                    <th><cf_get_lang dictionary_id='57789.Ozel Kod'></th>
                    <th><cf_get_lang dictionary_id='58832.Abone'></th>
                    <cfif xml_project eq 1>
                        <th><cf_get_lang dictionary_id='57416.Proje'><cfset colspan_ = colspan_+1></th>
                    </cfif>
                    <th><cf_get_lang dictionary_id='58233.Tanım'></th>
                    <th><cf_get_lang dictionary_id='57486.Kategori'></th>
                    <th><cf_get_lang dictionary_id='60559.Kurulum Tarihi'></th>
                    <th><cf_get_lang dictionary_id='57747.Sözleşme Tarihi'></th>
                    <th><cf_get_lang dictionary_id='57748.İptal Tarihi'></th>
                    <th><cf_get_lang dictionary_id='57482.Aşama'></th>
                    <th><cf_get_lang dictionary_id='41076.Satış Temsilcisi'></th>
                    <th><cf_get_lang dictionary_id='57483.Kayıt'></th>	
                    <!-- sil --><th width="20" class="header_icn_none text-center"><a href="<cfoutput>#request.self#</cfoutput>?fuseaction=sales.list_subscription_contract&event=add"><i class="fa fa-plus" title="<cf_get_lang dictionary_id='57582.Ekle'>" alt="<cf_get_lang dictionary_id='57582.Ekle'>"></i></a></th>	<!-- sil -->
                </tr>
            </thead>
            <tbody>
                <cfif get_subscriptions.recordcount>
                    <cfset consumer_list=''>
                    <cfset partner_list=''>
                    <cfset employee_list=''>
                    <cfset process_list=''>
                    <cfoutput query="get_subscriptions">
                        <cfif len(get_subscriptions.consumer_id) and not listfind(consumer_list,get_subscriptions.consumer_id)>
                            <cfset consumer_list = listappend(consumer_list,get_subscriptions.consumer_id)>
                        </cfif>
                        <cfif len(get_subscriptions.partner_id) and not listfind(partner_list,get_subscriptions.partner_id)>
                            <cfset partner_list = listappend(partner_list,get_subscriptions.partner_id)>
                        </cfif>
                        <cfif len(get_subscriptions.record_emp) and not listfind(employee_list,get_subscriptions.record_emp)>
                            <cfset employee_list = listappend(employee_list,get_subscriptions.record_emp)>
                        </cfif>
                        <cfif len(get_subscriptions.record_cons) and not listfind(consumer_list,get_subscriptions.record_cons)>
                            <cfset consumer_list = listappend(consumer_list,get_subscriptions.record_cons)>
                        </cfif>
                        <cfif len(get_subscriptions.sales_emp_id) and not listfind(employee_list,get_subscriptions.sales_emp_id)>
                            <cfset employee_list = listappend(employee_list,get_subscriptions.sales_emp_id)>
                        </cfif>
                        <cfif len(get_subscriptions.subscription_stage) and not listfind(process_list,get_subscriptions.subscription_stage)>
                            <cfset process_list = listappend(process_list,get_subscriptions.subscription_stage)>
                        </cfif>
                    </cfoutput>
                    <cfif len(partner_list)>
                        <cfset partner_list=listsort(partner_list,"numeric","ASC",",")>
                        <cfset GET_PARTNER = contract_cmp.GET_PARTNER(partner_list:partner_list)>
                        <cfset main_partner_list = listsort(listdeleteduplicates(valuelist(get_partner.partner_id,',')),'numeric','ASC',',')>
                    </cfif>
                    <cfif len(consumer_list)>
                        <cfset consumer_list=listsort(consumer_list,"numeric","ASC",",")>
                        <cfset get_consumer = contract_cmp.GET_CONSUMER(consumer_list:consumer_list)>
                        <cfset main_consumer_list = listsort(listdeleteduplicates(valuelist(get_consumer.consumer_id,',')),'numeric','ASC',',')>
                    </cfif>
                    <cfif len(employee_list)>
                        <cfset employee_list=listsort(employee_list,"numeric","ASC",",")>
                        <cfset GET_EMPLOYEE = contract_cmp.GET_EMPLOYEE(employee_list:employee_list)>
                        <cfset main_employee_list = listsort(listdeleteduplicates(valuelist(get_employee.employee_id,',')),'numeric','ASC',',')>
                    </cfif>	
                    <cfif len(process_list)>
                        <cfset process_list=listsort(process_list,"numeric","ASC",",")>
                        <cfset get_process_type = contract_cmp.GET_PROCESS_TYPE(process_list:process_list)>
                        <cfset main_process_list = listsort(listdeleteduplicates(valuelist(get_process_type.process_row_id,',')),'numeric','ASC',',')>
                    </cfif> 
                    <cfoutput query="get_subscriptions">
                    <tr>
                        <td width="35">#rownum#</td>

                        <td><a href="#request.self#?fuseaction=sales.list_subscription_contract&event=upd&subscription_id=#get_subscriptions.subscription_id#" class="tableyazi">#subscription_no#</a></td>
                        <td>#special_code#</td>
                        <td><cfif len(get_subscriptions.consumer_id)>
                                <a href="javascript://" class="tableyazi" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_con_det&con_id=#get_subscriptions.consumer_id#');">#get_consumer.consumer_name[listfind(main_consumer_list,get_subscriptions.consumer_id,',')]#&nbsp;#get_consumer.consumer_surname[listfind(main_consumer_list,get_subscriptions.consumer_id,',')]#</a>
                            <cfelseif len(get_subscriptions.company_id)>
                                <a href="javascript://" class="tableyazi" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_com_det&company_id=#get_subscriptions.COMPANY_ID#');">#get_partner.nickname[listfind(main_partner_list,get_subscriptions.partner_id,',')]#</a> - 
                                <cfif len(get_subscriptions.partner_id)><a href="javascript://" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_par_det&par_id=#get_subscriptions.partner_id#');" class="tableyazi">#get_partner.company_partner_name[listfind(main_partner_list,get_subscriptions.partner_id,',')]#&nbsp;#get_partner.company_partner_surname[listfind(main_partner_list,get_subscriptions.partner_id,',')]#</a></cfif>
                            </cfif>
                        </td>
                        <cfif xml_project eq 1>
                            <td><cfif len(get_subscriptions.project_id)><a href="#request.self#?fuseaction=project.projects&event=det&id=#get_subscriptions.project_id#">#get_project_name(get_subscriptions.project_id,0)#</a></cfif></td>
                        </cfif>
                        <td>#left(get_subscriptions.subscription_head,50)#</td>
                        <td>#get_subscriptions.subscription_type#</td>
                        <td><cfif len(montage_date)>#dateformat(montage_date,dateformat_style)#</cfif></td>
                        <td><cfif len(start_date)>#dateformat(start_date,dateformat_style)#</cfif></td>
                        <td><cfif len(finish_date)>#dateformat(finish_date,dateformat_style)#</cfif></td>
                        <td><cfif len(get_subscriptions.subscription_stage)>#get_process_type.STAGE[listfind(main_process_list,get_subscriptions.subscription_stage,',')]#</cfif></td> 
                        <td><cfif len(sales_emp_id)>
                                <a href="javascript://" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_emp_det&emp_id=#get_subscriptions.sales_emp_id#');" class="tableyazi">
                                    #get_employee.employee_name[listfind(main_employee_list,get_subscriptions.sales_emp_id,',')]#&nbsp;#get_employee.employee_surname[listfind(main_employee_list,get_subscriptions.sales_emp_id,',')]#
                                </a>
                            </cfif>
                        </td>
                        <td><cfif len(record_emp)>
                                <a href="javascript://" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_emp_det&emp_id=#get_subscriptions.record_emp#');" class="tableyazi">#get_employee.employee_name[listfind(main_employee_list,get_subscriptions.record_emp,',')]#&nbsp;#get_employee.employee_surname[listfind(main_employee_list,get_subscriptions.record_emp,',')]#</a>
                            <cfelseif len(record_cons)>
                                <a href="javascript://" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_con_det&con_id=#get_subscriptions.record_cons#');" class="tableyazi">#get_consumer.consumer_name[listfind(consumer_list,record_cons,',')]# #get_consumer.consumer_surname[listfind(consumer_list,record_cons,',')]#</a>
                            </cfif>
                        </td>
                        <td><a href="#request.self#?fuseaction=sales.list_subscription_contract&event=upd&subscription_id=#get_subscriptions.subscription_id#"><i class="fa fa-pencil" alt="<cf_get_lang dictionary_id='57464.Güncelle'>" title="<cf_get_lang dictionary_id='57464.Güncelle'>"></i></td>
                    </tr> 
                    </cfoutput>
            <cfelse>
                <tr>
                    <td colspan="<cfoutput>#colspan_#</cfoutput>"><cfif isdefined("attributes.form_submitted")><cf_get_lang dictionary_id='57484.Kayıt Bulunamadı'> !<cfelse><cf_get_lang dictionary_id='57701.Filtre Ediniz '> !</cfif></td>
                </tr>
            </cfif>
            </tbody>
        </cf_grid_list>
    
        <cfset adres="sales.list_subscription_contract">
        <cfif isdefined("attributes.keyword") and len(attributes.keyword)>
            <cfset adres = "#adres#&keyword=#attributes.keyword#" >
        </cfif>
        <cfif isdefined("attributes.process_stage_type") and len(attributes.process_stage_type)>
            <cfset adres = "#adres#&process_stage_type=#attributes.process_stage_type#" >
        </cfif>
        <cfif isdefined("attributes.subscription_type") and len(attributes.subscription_type)>
            <cfset adres = "#adres#&subscription_type=#attributes.subscription_type#">
        </cfif>
        <cfif isdefined("attributes.subs_add_option") and len(attributes.subs_add_option)>
            <cfset adres = "#adres#&subs_add_option=#attributes.subs_add_option#">
        </cfif>
        <cfif isdefined("attributes.sale_add_option") and len(attributes.sale_add_option)>
            <cfset adres = "#adres#&sale_add_option=#attributes.sale_add_option#">
        </cfif>		
        <cfif isdefined('attributes.sales_emp') and len(attributes.sales_emp)>
            <cfset adres = "#adres#&sales_emp=#attributes.sales_emp#&sales_emp_id=#attributes.sales_emp_id#">
        </cfif>
        <cfif isdefined('attributes.sales_partner') and len(attributes.sales_partner)>
            <cfset adres = "#adres#&sales_partner=#attributes.sales_partner#&sales_partner_id=#attributes.sales_partner_id#">
        </cfif>
        <cfif isdefined("attributes.employee_name") and len(attributes.employee_name) and isdefined("attributes.employee_id") and  len(attributes.employee_id) >
            <cfset adres = "#adres#&employee_name=#attributes.employee_name#&employee_id=#attributes.employee_id#" >
        </cfif>
        <cfif isdefined("attributes.consumer_id") and len(attributes.consumer_id)>
            <cfset adres = "#adres#&consumer_id=#attributes.consumer_id#" >
        </cfif>
        <cfif isdefined("attributes.member_type") and len(attributes.member_type)>
            <cfset adres  ="#adres#&member_type=#attributes.member_type#&member_name=#attributes.member_name#"> 
        </cfif> 
        <cfif isdefined("attributes.company_id") and len(attributes.company_id)>
            <cfset adres  ="#adres#&company_id=#attributes.company_id#" >
        </cfif>
        <cfif isdefined('attributes.start_date') and len(attributes.start_date)>
            <cfset adres = "#adres#&start_date=#dateformat(attributes.start_date,dateformat_style)#">
        </cfif>
        <cfif isdefined('attributes.finish_date') and len(attributes.finish_date)>
            <cfset adres = "#adres#&finish_date=#dateformat(attributes.finish_date,dateformat_style)#">
        </cfif>
        <cfif isdefined("attributes.status") and len(attributes.status)>
            <cfset adres = "#adres#&status=#attributes.status#">
        </cfif>
        <cfif isdefined('attributes.sort_type') and len(attributes.sort_type)>
            <cfset adres = "#adres#&sort_type=#attributes.sort_type#">
        </cfif>
        <cfif isdefined('attributes.use_efatura') and len(attributes.use_efatura)>
            <cfset adres = "#adres#&use_efatura=#attributes.use_efatura#">
        </cfif>
        <cfif isdefined("attributes.product_id") and len(attributes.product_id) and isdefined("attributes.product_name") and len(attributes.product_name)>
            <cfset adres = "#adres#&product_id=#attributes.product_id#&product_name=#attributes.product_name#">
        </cfif>
        <cfif isdefined("attributes.asset_id") and len(attributes.asset_id) and isdefined("attributes.asset_name") and len(attributes.asset_name)>
            <cfset adres = "#adres#&asset_id=#attributes.asset_id#&asset_name=#attributes.asset_name#">
        </cfif>
        <cfif len(attributes.project_id) and len(attributes.project_head)>
            <cfset adres = "#adres#&project_id=#attributes.project_id#&project_head=#attributes.project_head#">
        </cfif>
        <cfset adres = adres&'&member_cat_type=#attributes.member_cat_type#'>
        <cf_paging 
            page="#attributes.page#" 
            maxrows="#attributes.maxrows#" 
            totalrecords="#attributes.totalrecords#" 
            startrow="#attributes.startrow#" 
            adres="#adres#&form_submitted=1">
    </cf_box>
</div>
<script type="text/javascript">
document.getElementById('keyword').focus();
function county_temizle()
{
	if(subscription_list.county.value.length == 0) subscription_list.county_id.value='';
}

function city_temizle()
{
	if(subscription_list.city.value.length == 0) subscription_list.city_id.value='';
}
</script>
