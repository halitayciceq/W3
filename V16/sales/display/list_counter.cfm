<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.subscription_id" default="">
<cfparam name="attributes.subscription_no" default="">
<cfparam name="attributes.work_status" default="">
<cfparam name="attributes.our_company_id" default="">
<cfparam name="attributes.page" default=1>
<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>

<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>

<cfinclude template="../../settings/query/get_our_companies.cfm">

<cfif IsDefined("attributes.form_submitted")>
    <cfset listCt = createObject("component","V16.sales.cfc.counter")>
    <cfset listCtsel = listCt.select(
        keyword             :   attributes.keyword,
        subscription_id     :   attributes.subscription_id,
        subscription_no     :   attributes.subscription_no
    )>
    <cfparam name="attributes.totalrecords" default='#listCtsel.recordcount#'>
<cfelse>
    <cfparam name="attributes.totalrecords" default='0'>
</cfif>

<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box>
        <cfform name="form_list_counter" id="form_list_counter" method="post" action="">
            <input type="hidden" name="form_submitted" id="form_submitted" value="1">
            <cf_box_search>
                <div class="form-group" id="item-keyword">
                    <cfinput type="text" name="keyword" value="#attributes.keyword#" maxlength="255" placeholder="#getLang('main',48)#">
                </div>
                <div class="form-group" id="item-subscription">
                    <div class="input-group">
                        <input type="hidden" name="subscription_id" id="subscription_id" value="<cfoutput>#attributes.subscription_id#</cfoutput>">
                        <input type="text" name="subscription_no" id="subscription_no" value="<cfoutput>#attributes.subscription_no#</cfoutput>" placeholder="<cfoutput>#getLang('','Abone No',29502)#</cfoutput>">
                        <span class="input-group-addon icon-ellipsis" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_subscription&field_id=form_list_counter.subscription_id&field_no=form_list_counter.subscription_no','list','popup_list_subscription');"></span>
                    </div>
                </div>
                <!---<div class="form-group" id="item-wex">       
                    <div class="input-group">
                        <cfsavecontent  variable="head"><cf_get_lang dictionary_id='47849.WEX'></cfsavecontent>
                        <input type="hidden" name="wex_id" id="wex_id" value="<cfoutput>#attributes.wex_id#</cfoutput>">     
                        <input type="text" name="wex_name" id="wex_name" value="<cfoutput>#attributes.wex_name#</cfoutput>" placeholder="<cfoutput>#head#</cfoutput>">
                        <span class="input-group-addon btn_Pointer icon-ellipsis" href="javascript://" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_wex&fieldId=form_list_counter.wex_id&fieldName=form_list_counter.wex_name','list','popup_list_products_with_price');"></span>                                                               
                    </div>
                </div>--->
                <div class="form-group" id="item-our_company_id">
                    <select name="our_company_id" id="our_company_id" required>
                        <option value=""><cf_get_lang dictionary_id='47851.Şirket Seçiniz'></option>
                        <cfoutput query="our_company">
                            <option value="#COMP_ID#" <cfif comp_id eq attributes.our_company_id>selected</cfif>>#COMPANY_NAME#</option>
                        </cfoutput>
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
    <cf_box title="#getLang('','Sayaçlar',41064)#" uidrop="1" hide_table_column="1">
        <cf_grid_list>
            <thead>
                <tr>
                    <th width="30"><cf_get_lang dictionary_id='58577.Line'></th>
                    <th><cf_get_lang dictionary_id='48871.Counter No'></th>
                    <th><cf_get_lang dictionary_id='29502.Abone No'></th>
                    <th><cf_get_lang dictionary_id='41282.Sayaç Tipi'></th>
                    <th><cf_get_lang dictionary_id='40984.Okuma Tipi'></th>
                    <th><cf_get_lang dictionary_id='41285.Fatura Periodu'></th>
                    <th><cf_get_lang dictionary_id='41283.Başlama Değeri'></th>
                    <th><cf_get_lang dictionary_id='40985.Okuma Periodu'></th>
                    <th><cf_get_lang dictionary_id='40986.İlk Okuma Tarihi'></th>
                    <th><cf_get_lang dictionary_id='40992.Son Hesaplama Tarihi'></th>
                    <th><cf_get_lang dictionary_id='57574.Şirket'></th>
                    <th width="20" class="text-center" class="header_icn_none text-center"><a href="<cfoutput>#request.self#</cfoutput>?fuseaction=sales.counter&event=add"><i class="fa fa-plus" title="<cf_get_lang dictionary_id='57582.Ekle'>" alt="<cf_get_lang dictionary_id='57582.Ekle'>"></i></a></th>
                </tr>       
            </thead>
            <tbody>
                <cfif attributes.totalrecords>
                    <cfoutput query="listCtsel" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
                        <tr>
                            <td>#currentrow#</td>
                            <td>#COUNTER_NO#</td>
                            <td>#SUBSCRIPTION_NO#</td>
                            <td>#COUNTER_TYPE#</td>
                            <td>
                                <cfif #READING_TYPE_ID# eq 1><cf_get_lang dictionary_id='39250.Sistem Bazında'>
                                <cfelseif #READING_TYPE_ID# eq 2><cf_get_lang dictionary_id='62220.Kullanıcı Bazında'>
                                <cfelseif #READING_TYPE_ID# eq 3><cf_get_lang dictionary_id='62221.İşlem Bazında'>
                                <cfelse>#READING_TYPE_ID#
                                </cfif>
                            </td>
                            <td>
                                <cfif #INVOICE_PERIOD# eq 1><cf_get_lang dictionary_id='58724.Ay'>
                                <cfelseif #INVOICE_PERIOD# eq 2>3 <cf_get_lang dictionary_id='58724.Ay'>
                                <cfelseif #INVOICE_PERIOD# eq 3><cf_get_lang dictionary_id='58455.Yıl'>
                                <cfelse>#INVOICE_PERIOD#
                                </cfif>
                            </td>
                            <td>#START_VALUE#</td>
                            <td>
                                <cfif #READING_PERIOD# eq 1><cf_get_lang dictionary_id='57490.Gün'>
                                <cfelseif #READING_PERIOD# eq 2><cf_get_lang dictionary_id='58734.Hafta'>
                                <cfelseif #READING_PERIOD# eq 3><cf_get_lang dictionary_id='58724.Ay'>
                                <cfelseif #READING_PERIOD# eq 4>3 <cf_get_lang dictionary_id='58724.Ay'>
                                <cfelseif #READING_PERIOD# eq 5><cf_get_lang dictionary_id='58455.Yıl'>
                                <cfelse>#READING_PERIOD#
                                </cfif>
                            </td>
                            <td>#dateformat(START_DATE,dateformat_style)#</td>
                            <td>#dateformat(FINISH_DATE, dateformat_style)#</td>
                            <td>#COMPANY_NAME#</td>
                            <td class="text-center"><a href="#request.self#?fuseaction=sales.counter&event=upd&counter_id=#COUNTER_ID#"><i class="fa fa-pencil" title="<cf_get_lang dictionary_id='57464.Güncelle'>" alt="<cf_get_lang dictionary_id='57464.Güncelle'>"></i></a></td>
                        </tr>
                    </cfoutput>
                <cfelse>
                    <tr>
                        <td colspan="13"><cfif isdefined("attributes.is_form_submitted")><cf_get_lang dictionary_id='57484.Kayıt Bulunamadı'> !<cfelse><cf_get_lang dictionary_id='57701.Filtre Ediniz '>!</cfif></td>
                    </tr>
                </cfif>
            </tbody>
        </cf_grid_list>
        <cfset url_str = "">
        <cfif isdefined("attributes.form_submitted")>
            <cfset url_str = "#url_str#&form_submitted=#attributes.form_submitted#">
        </cfif>
        <cfif len(attributes.keyword)>
            <cfset url_str = "#url_str#&keyword=#attributes.keyword#">
        </cfif>
        <cfif len(attributes.subscription_no)>
            <cfset url_str = "#url_str#&subscription_no=#attributes.subscription_no#">
        </cfif>
        <cf_paging page="#attributes.page#" 
            maxrows="#attributes.maxrows#"
            totalrecords="#attributes.totalrecords#"
            startrow="#attributes.startrow#"
            adres="#fusebox.circuit#.counter&#url_str#">
    </cf_box>
</div>