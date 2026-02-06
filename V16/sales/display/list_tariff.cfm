<!----17042019 Tarifeler listeleme İlker Altındal ----->
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.main_product" default="">
<cfparam name="attributes.work_status" default="">
<cfparam name="attributes.product_id" default="">
<cfparam name="attributes.product_name" default="">
<cfparam name="attributes.page" default=1>
<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>

<cfif isdefined("attributes.is_form_submitted")>
    <cfscript>
        get_tariff = createObject("component","V16.sales.cfc.tariff");
        get_tariff = get_tariff.list_tariff(
            keyword : '#iif(isdefined("attributes.keyword"),"attributes.keyword",DE(""))#',
            main_product : '#iif(isdefined("attributes.main_product"),"attributes.main_product",DE(""))#',
            work_status : '#iif(isdefined("attributes.work_status"),"attributes.work_status",DE(""))#'
        );
    </cfscript>
    <cfparam name="attributes.totalrecords" default='#get_tariff.recordcount#'>
<cfelse>
    <cfparam name="attributes.totalrecords" default='0'>
</cfif>

<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>

<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box>
        <cfform name="form" method="post" action="">
            <input type="hidden" name="is_form_submitted" id="is_form_submitted" value="1">
            <cf_box_search>
                <div class="form-group" id="form_ul_keyword">
                    <cfinput type="text" name="keyword" value="#attributes.keyword#" maxlength="255" placeholder="#getLang('main','Filtre',57460)#">
                </div>
                <div class="form-group" id="form_ul_main_product">
                    <div class="input-group">
                        <input type="hidden" name="main_product" value="">
                        <input type="text" name="product_name" id="product_name" value="<cfoutput>#attributes.product_name#</cfoutput>" placeholder="<cfoutput>#getLang('','Ana Ürün',37164)#</cfoutput>">
                        <span class="input-group-addon icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_product_price_unit&field_id=form.main_product&field_name=form.product_name');"></span>
                    </div>
                </div>
                <div class="form-group" id="form_ul_work_status">       
                    <select name="work_status" id="work_status">
                        <option value="1" <cfif attributes.work_status eq 1>selected="selected"</cfif>><cf_get_lang dictionary_id='57493.Aktif'></option>
                        <option value="-1" <cfif attributes.work_status eq -1>selected="selected"</cfif>><cf_get_lang dictionary_id='57494.Pasif'></option>
                        <option value="0" <cfif attributes.work_status eq 0>selected="selected"</cfif>><cf_get_lang dictionary_id='57708.Tümü'></option>
                    </select>
                </div>
                <div class="form-group small">
                    <cfinput type="text" name="maxrows" id="maxrows" value="#attributes.maxrows#" required="yes" validate="integer" range="1,999" message="#getLang('','Kayıt Sayısı Hatalı',57537)#" maxlength="3" onKeyUp="isNumber(this)">
                </div>
                <div class="form-group">
                    <cf_wrk_search_button button_type="4">
                </div>
            </cf_box_search>
        </cfform>
    </cf_box>
    <cf_box title="#getLang('','Tarifeler',40983)#" uidrop="1" hide_table_column="1">
        <cf_grid_list>
            <thead>
                <tr>
                    <th width="30"><cf_get_lang dictionary_id='57487.No'></th>
                    <th><cf_get_lang dictionary_id='40977.Tarife Adı'></th>
                    <th><cf_get_lang dictionary_id='37164.Ana Ürün'></th>
                    <th><cf_get_lang dictionary_id='58964.Fiyat Listesi'></th>
                    <th><cf_get_lang dictionary_id='40978.Tarife Fiyatı'></th>
                    <th><cf_get_lang dictionary_id='58050.Son Güncelleme'></th>
                    <th width="20" class="header_icn_none text-center"><a href="<cfoutput>#request.self#</cfoutput>?fuseaction=sales.tariff&event=add"><i class="fa fa-plus" title="<cf_get_lang dictionary_id='57582.Ekle'>" alt="<cf_get_lang dictionary_id='57582.Ekle'>"></i></a></th>
                </tr>       
            </thead>
            <tbody>
                <cfif isdefined("get_tariff.recordcount") and get_tariff.recordcount>
                    <cfoutput query="get_tariff" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
                        <tr>
                            <td>#currentrow#</td>
                            <td>#TARIFF_NAME#</td>
                            <td>#PRODUCT_NAME#</td>
                            <td><cfif PRICE_LIST eq -1><cf_get_lang dictionary_id='58722.Standart Alış'><cfelseif PRICE_LIST eq -2><cf_get_lang dictionary_id='58721.Standart Satış'><cfelse>#PRICE_CAT#</cfif></td>
                            <td>#tlFormat(TARIFF_PRICE)#</td>
                            <td>#dateformat(UPDATE_DATE,dateformat_style)#</td>
                            <td class="text-center"><a href="#request.self#?fuseaction=sales.tariff&event=upd&tariff_id=#tariff_id#"><i class="fa fa-pencil" title="<cf_get_lang dictionary_id='57464.Güncelle'>" alt="<cf_get_lang dictionary_id='57464.Güncelle'>"></i></a></td>
                        </tr>
                    </cfoutput>
                <cfelse>
                    <tr>
                        <td colspan="7"><cfif isdefined("attributes.is_form_submitted")><cf_get_lang dictionary_id='57484.Kayıt Bulunamadı'>!<cfelse><cf_get_lang dictionary_id='57701.Filtre Ediniz'>!</cfif></td>
                    </tr>
                </cfif>
            </tbody>
        </cf_grid_list>

        <cfset url_str = "">
        <cfif isdefined("attributes.is_form_submitted")>
            <cfset url_str = "#url_str#&is_form_submitted=#attributes.is_form_submitted#">
        </cfif>
        <cfif len(attributes.keyword)>
            <cfset url_str = "#url_str#&keyword=#attributes.keyword#">
        </cfif>
        <cfif len(attributes.main_product)>
            <cfset url_str = "#url_str#&main_product=#attributes.main_product#">
        </cfif>
        <cfif isdefined("attributes.work_status")>
            <cfset url_str = "#url_str#&work_status=#attributes.work_status#">
        </cfif>
        <cf_paging page="#attributes.page#" 
            maxrows="#attributes.maxrows#"
            totalrecords="#attributes.totalrecords#"
            startrow="#attributes.startrow#"
            adres="#fusebox.circuit#.tariff&#url_str#">
    </cf_box>
</div>

        