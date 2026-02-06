<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.subscription_id" default="">
<cfparam name="attributes.subscription_no" default="">
<cfparam name="attributes.counter_no" default="">
<cfparam name="attributes.stock_id" default="">
<cfparam name="attributes.product_id" default="">
<cfparam name="attributes.product" default="">
<cfparam name="attributes.record_date" default="">
<cfparam name="attributes.record_date2" default="">
<cfparam name="attributes.page" default=1>
<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>

<cfif IsDefined("attributes.form_submitted")>
    <cfset subsCounterPre = createObject("component","V16.sales.cfc.subscription_counter_prepaid")>
    <cfset subsCounterPrepaids = subsCounterPre.select(
        keyword             :   attributes.keyword,
        subscription_id     :   attributes.subscription_id,
        subscription_no     :   attributes.subscription_no,
        counter_no          :   '#iif(Len(attributes.counter_no),attributes.counter_no,DE(''))#',
        product_id          :   '#iif(Len(attributes.product_id) and Len(attributes.product),attributes.product_id,DE(''))#',
        record_date         :   attributes.record_date,
        record_date2        :   attributes.record_date2
    )>
    <cfparam name="attributes.totalrecords" default='#subsCounterPrepaids.recordcount#'>
<cfelse>
    <cfset subsCounterPrepaids.recordCount = 0>
    <cfparam name="attributes.totalrecords" default='0'>
</cfif>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box>
        <cfform name="list_counter_prepaid" method="post" action="#request.self#?fuseaction=sales.subscription_counter_prepaid">
            <input type="hidden" name="form_submitted" id="form_submitted" value="1">
            <cf_box_search>
                <div class="form-group">
                    <cfinput name="keyword" id="keyword" value="#attributes.keyword#" placeholder="#getLang('main','Filtre',57460)#">
                </div>
                <div class="form-group">
                    <div class="input-group">
                        <cfinput type="hidden" name="subscription_id" id="subscription_id" value="#attributes.subscription_id#">
                        <cfinput type="text" name="subscription_no" id="subscription_no" value="#attributes.subscription_no#" placeholder="#getLang('main','Abone',58832)#">
                        <span class="input-group-addon btn_Pointer icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_subscription&field_id=list_counter_prepaid.subscription_id&field_no=list_counter_prepaid.subscription_no');"></span>
                    </div>
                </div>
                <div class="form-group">
                    <cfinput name="counter_no" id="counter_no" value="#attributes.counter_no#" placeholder="#getLang('bank','Sayaç No',48871)#">
                </div>
                <div class="form-group">
                    <div class="input-group">
                        <cfsavecontent variable = "placeHolder"><cf_get_lang dictionary_id='57657.Ürün'></cfsavecontent>
                        <cfinput type="hidden" name="stock_id" id="stock_id" value="#attributes.stock_id#">
                        <cfinput type="hidden" name="product_id" id="product_id" value="#attributes.product_id#">
                        <cfinput type="text" name="product" id="product" value="#attributes.product#" placeholder="#placeHolder#">
                        <span class="input-group-addon btn_Pointer icon-ellipsis" href="javascript://" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_product_price_unit&field_stock_id=list_counter_prepaid.stock_id&field_id=list_counter_prepaid.product_id&field_name=list_counter_prepaid.product');"></span>
                    </div>
                </div>
                <div class="form-group">
                    <div class="input-group">
                        <cfsavecontent variable="record_date"><cf_get_lang dictionary_id='57782.Tarih Değerlerini Kontrol ediniz'></cfsavecontent>
                        <cfinput type="text" maxlength="10" name="record_date" value="#dateformat(attributes.record_date,dateformat_style)#" validate="#validate_style#" message="#record_date#">
                        <span class="input-group-addon"><cf_wrk_date_image date_field="record_date"></span>
                    </div>
                </div>
                <div class="form-group">
                    <div class="input-group">
                        <cfinput type="text" maxlength="10" name="record_date2" value="#dateformat(attributes.record_date2,dateformat_style)#" validate="#validate_style#" message="#record_date#">
                        <span class="input-group-addon"><cf_wrk_date_image date_field="record_date2"></span>
                    </div>
                </div>
                <div class="form-group small">
                    <cfinput type="text" name="maxrows" value="#attributes.maxrows#" required="yes" validate="integer" range="1,999" message="#getLang('','Kayıt Sayısı Hatalı',57537)#" maxlength="3">
                </div>
                <div class="form-group">
                    <cf_wrk_search_button button_type="4">
                    <cf_workcube_file_action pdf='1' mail='1' doc='1' print='1'>
                </div>
            </cf_box_search>
        </cfform>
    </cf_box>
    <cf_box title="#getLang('bank','Sayaç Yükleme İşlemleri',48878)#" uidrop="1" hide_table_column="1">
        <cf_grid_list>
            <thead>
                <th width="30"><cf_get_lang dictionary_id='57487.No'></th>
                <th><cf_get_lang dictionary_id='29502.Abone No'></th>
                <th><cf_get_lang dictionary_id='48871.Sayaç No'></th>
                <th><cf_get_lang dictionary_id='48888.Paket Miktar'></th>
                <th><cf_get_lang dictionary_id='57638.Birim Fiyat'></th>
                <th><cf_get_lang dictionary_id='48879.Yükleme Miktarı'></th>
                <th><cf_get_lang dictionary_id='33932.Toplam Fiyat'></th>
                <th width="20" class="header_icn_none text-center"><a href="index.cfm?fuseaction=sales.subscription_counter_prepaid&event=add"><i class="fa fa-plus" title="<cf_get_lang dictionary_id='57582.Ekle'>" alt="<cf_get_lang dictionary_id='57582.Ekle'>"></i></a></th>
            </thead>
            <tbody>
                <cfif subsCounterPrepaids.recordCount>
                    <cfoutput query="subsCounterPrepaids" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
                        <tr>
                            <td>#currentrow#</td>
                            <td>#SUBSCRIPTION_NO#</td>
                            <td>#COUNTER_NO#</td>
                            <td>#TLFORMAT(AMOUNT)# - #MAIN_UNIT#</td>
                            <td>#TLFORMAT(PRICE)##ListLast(OTHER_MONEY,';')#</td>
                            <td>#TLFORMAT(COUNTER_LOADING_PRICE)#</td>
                            <td>#TLFORMAT(COUNTER_TOTAL_PRICE)##ListLast(OTHER_MONEY,';')#</td>
                            <td class="text-center"><a href="#request.self#?fuseaction=sales.subscription_counter_prepaid&event=upd&scp_id=#SCP_ID#" class="tableyazi"><i class="fa fa-pencil" title="<cf_get_lang dictionary_id='57464.Güncelle'>" alt="<cf_get_lang dictionary_id='57464.Güncelle'>"></i></a></td>
                        </tr>
                    </cfoutput>
                <cfelse>
                    <tr>
                        <td colspan="9"><cfif isdefined("attributes.form_submitted")><cf_get_lang dictionary_id='57484.Kayıt Bulunamadı'> !<cfelse><cf_get_lang dictionary_id='57701.Filtre Ediniz '>!</cfif></td>
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
            <cfif len(attributes.counter_no)>
                <cfset url_str = "#url_str#&counter_no=#attributes.counter_no#">
            </cfif>
            <cfif len(attributes.product)>
                <cfset url_str = "#url_str#&product=#attributes.product#">
            </cfif>
            <cfif len(attributes.record_date)>
                <cfset url_str = "#url_str#&record_date=#attributes.record_date#">
            </cfif>
            <cfif len(attributes.record_date2)>
                <cfset url_str = "#url_str#&record_date2=#attributes.record_date2#">
            </cfif>
            <cf_paging page="#attributes.page#" 
                maxrows="#attributes.maxrows#"
                totalrecords="#attributes.totalrecords#"
                startrow="#attributes.startrow#"
                adres="#fusebox.circuit#.subscription_counter_prepaid&#url_str#">
    </cf_box>
</div>