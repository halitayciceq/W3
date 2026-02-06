<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.page" default=1>
<cfparam name="attributes.modal_id" default="">
<cfparam name="attributes.maxrow" default='#session.ep.maxrows#'>
<cfparam name="attributes.formName" default="">
<cfparam name="attributes.fieldId" default="">
<cfparam name="attributes.fieldName" default="">
<cfparam name="attributes.status" default="">
<cfparam name="attributes.tariff_name" default="">
<cfparam name="attributes.main_product" default="">
<cfparam name="attributes.product_name" default="">
<cfparam name="attributes.url_str" default="">

<cfif isdefined("attributes.is_submitted")>
    <cfquery name="get_tariff" datasource="#dsn3#">
        SELECT ST.TARIFF_ID, ST.TARIFF_NAME, P.PRODUCT_NAME, ST.TARIFF_PRICE, ST.TARIFF_PRICE FROM SUBSCRIPTION_TARIFF AS ST LEFT JOIN PRODUCT AS P ON ST.PRODUCT_ID = P.PRODUCT_ID 
        WHERE
            1 = 1
            <cfif len(attributes.keyword)>AND TARIFF_NAME LIKE <cfqueryparam cfsqltype="cf_sql_nvarchar" value="%#attributes.keyword#%"></cfif>
            <cfif len(attributes.tariff_name)>AND TARIFF_NAME LIKE <cfqueryparam cfsqltype="cf_sql_nvarchar" value="%#attributes.tariff_name#%"></cfif>
            <cfif len(attributes.status)>AND IS_ACTIVE LIKE <cfqueryparam cfsqltype="cf_sql_nvarchar" value="%#attributes.status#%"></cfif>
            <cfif len(attributes.main_product)>AND P.PRODUCT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.main_product#"></cfif>
    </cfquery>
<cfelse>
	<cfset get_tariff.recordcount=0>
</cfif>

<cfparam name="attributes.totalrecords" default="#get_tariff.recordcount#">
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrow)+1>

<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box title="#getLang('','',40983)#" scroll="1" collapsable="1" resize="1" popup_box="#iif(isdefined("attributes.draggable"),1,0)#">
        <cfform name="search_accident" method="post" action="#request.self#?fuseaction=#attributes.fuseaction#">
            <input type="hidden" name="is_submitted" id="is_submitted" value="1" />
            <input type="hidden" name="fieldId" id="fieldId" value="<cfoutput>#attributes.fieldId#</cfoutput>" />
            <input type="hidden" name="fieldName" id="fieldName" value="<cfoutput>#attributes.fieldName#</cfoutput>" />
            <cf_box_search more="0">
                <div class="form-group">
                    <input type="text" name="keyword" id="keyword" value="<cfoutput>#attributes.keyword#</cfoutput>" placeholder="<cfoutput>#getLang('','Filtre',57460)#</cfoutput>" maxlength="255" onKeyDown="if(event.keyCode == 13) {searchButtonFunc()}">
                </div>
                <div class="form-group">
                    <div class="input-group">
                        <input type="hidden" name="main_product" value="">
                        <input type="text" name="product_name" id="product_name" value="<cfoutput>#attributes.product_name#</cfoutput>" placeholder="<cfoutput>#getLang('','Ana Ürün',37164)#</cfoutput>">
                        <span class="input-group-addon icon-ellipsis" href="javascript://" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_product_price_unit&field_id=search_accident.main_product&field_name=search_accident.product_name','');return false;"></span>
                    </div>
                </div>
                <div class="form-group">
                    <select id="status" name="status">
                        <option value="1"><cf_get_lang dictionary_id='57493.Aktif'></option>
                        <option value="0"><cf_get_lang dictionary_id='57494.Pasif'></option>
                        <option value=""><cf_get_lang dictionary_id='57708.Tümü'></option>
                    </select>
                </div>
                <div class="form-group small">
                    <cfinput type="text" name="maxrow" value="#attributes.maxrow#" required="yes" validate="integer" range="1,999" message="#getLang('','Kayıt Sayısı Hatalı!',57537)#" maxlength="3">
                </div>
                <div class="form-group">
                    <cf_wrk_search_button button_type="4" search_function="#iif(isdefined("attributes.draggable"),DE("loadPopupBox('search_accident' , #attributes.modal_id#)"),DE(""))#">
                </div>
            </cf_box_search>
        </cfform>

        <cf_grid_list>
            <thead>
                <tr>
                    <th width="20"></th>
                    <th><cf_get_lang dictionary_id='40977.Tarife Adı'></th>
                    <th><cf_get_lang dictionary_id='37164.Ana Ürün'></th>
                    <th><cf_get_lang dictionary_id='40978.Tarife Fiyatı'></th>
                </tr>
            </thead>
            <tbody>
                <cfif get_tariff.recordcount>
                    <cfoutput query="get_tariff" startrow="#attributes.startrow#" maxrows="#attributes.maxrow#">
                        <tbody>
                            <tr>
                                <td>#currentrow#</td>
                                <td><a href="javascript://" class="tableyazi" onclick="addForm(#TARIFF_ID#,'#TARIFF_NAME#');">#TARIFF_NAME#</a></td>
                                <td>#PRODUCT_NAME#</td>
                                <td>#TARIFF_PRICE#</td>
                            </tr>
                        </tbody>
                    </cfoutput>
                <cfelse>
                    <td colspan="4" class="color-row"><cfif isdefined("attributes.is_submitted")><cf_get_lang dictionary_id='57484.Kayıt Yok'> !<cfelse><cf_get_lang dictionary_id='57701.Filtre Ediniz'> !</cfif></td>
                </cfif>
            </tbody>
        </cf_grid_list>    

        <cfif attributes.totalrecords gt attributes.maxrow>    
            <cfset url_str="objects.popup_list_tariff&is_submitted=1">
            <cfif isDefined('attributes.keyword') and len(attributes.keyword)>
                <cfset url_str = "#url_str#&keyword=#attributes.keyword#">
            </cfif>
            <cfif len(attributes.maxrow)>
                <cfset url_str = "#url_str#&maxrow=#attributes.maxrow#">
            </cfif>
            <cfif len(attributes.fieldId)>
                <cfset url_str = "#url_str#&fieldId=#attributes.fieldId#">
            </cfif>
            <cfif len(attributes.fieldName)>
                <cfset url_str = "#url_str#&fieldName=#attributes.fieldName#">
            </cfif>
            <cf_paging 
                page="#attributes.page#" 
                maxrows="#attributes.maxrow#" 
                totalrecords="#attributes.totalrecords#" 
                startrow="#attributes.startrow#" 
                adres="#url_str#"
                isAjax="#iif(isdefined("attributes.draggable"),1,0)#">
        </cfif>
    </cf_box>
</div>
<script type="text/javascript">
    function addForm(tariffId,tariffName){
        <cfif isdefined("attributes.draggable")>document<cfelse>window.opener</cfif>.<cfoutput>#attributes.fieldId#</cfoutput>.value = tariffId;
        <cfif isdefined("attributes.draggable")>document<cfelse>window.opener</cfif>.<cfoutput>#attributes.fieldName#</cfoutput>.value = tariffName;
        <cfif not isdefined("attributes.draggable")>window.close();<cfelse>closeBoxDraggable( '<cfoutput>#attributes.modal_id#</cfoutput>' );</cfif>
    }
</script>

