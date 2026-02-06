<cf_xml_page_edit fuseact="sales.form_add_offer">
<cfinclude template="../query/get_offer.cfm">
<cfif not get_offer.recordcount or (isdefined("attributes.active_company") and attributes.active_company neq session.ep.company_id)>
	<cfset hata  = 11>
	<cfsavecontent variable="message"><cf_get_lang dictionary_id='57997.Şube Yetkiniz Uygun Değil'> <cf_get_lang dictionary_id='57998.Veya'> <cf_get_lang dictionary_id='65179.Şirketinizde Böyle Bir Teklif Bulunamadı !'></cfsavecontent>
	<cfset hata_mesaj  = message>
	<cfinclude template="../../dsp_hata.cfm">
	<cfexit method="exittemplate">
</cfif>
<cfset attributes.basket_id = 3> <!--- Update'de tanımlandığı için alındı. --->
<cfset pageHead = "#getlang('main',2210)#: #GET_OFFER.offer_number#">
<cf_catalystHeader>
<div class="row">
    <div class="col col-9"> 
        <cfinclude template="../display/list_pluses.cfm">
        <cf_box title="#getLang('','Ek Sayfa Ekle',40940)#" add_href="javascript:openBoxDraggable('#request.self#?fuseaction=sales.popup_form_add_page&offer_id=#offer_id#','','ui-draggable-box-medium')">
            <cfquery name="get_offer_pg" datasource="#dsn3#">
                SELECT * FROM OFFER_PAGES WHERE OFFER_ID=#attributes.offer_id# ORDER BY PAGE_NO
            </cfquery>
            <cfif get_offer_pg.recordcount> 
                <cf_flat_list>
                    <thead>
                        <tr>
                            <th><cf_get_lang dictionary_id='40940.Ek Sayfalar'></th>
                            <th width="20"><a href="javascript://" onclick="javascript:openBoxDraggable('<cfoutput>#request.self#?fuseaction=sales.popup_form_add_page&offer_id=#offer_id#</cfoutput>','','ui-draggable-box-medium')"><i class="fa fa-plus" title="Ekle"></i></a></th>
                        </tr>
                    </thead>
                    <tbody>
                        <cfoutput query="get_offer_pg">
                            <tr>
                                <cfquery name="get_types" datasource="#dsn#">
                                    SELECT * FROM SETUP_PAGE_TYPES WHERE PAGE_TYPE_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#page_type#">
                                </cfquery>
                                <td><a href="javascript://" onclick="javascript:openBoxDraggable('#request.self#?fuseaction=sales.popup_form_upd_page&page_id=#get_offer_pg.page_id#&offer_id=#attributes.offer_id#&draggable=1','','ui-draggable-box-medium')" class="tableyazi">#get_types.page_type# - #page_name#</a></td> 
                                <td><a href="javascript://" onclick="javascript:openBoxDraggable('#request.self#?fuseaction=sales.popup_form_upd_page&page_id=#get_offer_pg.page_id#&offer_id=#attributes.offer_id#&draggable=1','','ui-draggable-box-medium')"><i class="fa fa-pencil" title="Güncelle"></i></a></td>
                            </tr>
                        </cfoutput>
                    </tbody>
                </cf_flat_list>
            </cfif>
        </cf_box>    
        <cf_get_workcube_form_generator design="3" action_type='12' related_type='12' action_type_id='#offer_id#'>         
        <cf_get_related_rows action_id='#attributes.offer_id#' is_compare='1' action_type="OFFER" is_popup="1">
        <!--- Iliskili Teminatlar --->
        <cf_box
            closable="0"
            box_page="#request.self#?fuseaction=objects.emptypopup_list_sales_guarantee&offer_id=#attributes.offer_id#&give_take=1"
            title="#getLang('','Teminatlar',57676)#">
        </cf_box>
        <cfif xml_is_offer_rival eq 1>
            <cf_box id="list_rival"
                box_page="#request.self#?fuseaction=sales.emptypopup_ajax_opp_rival&offer_id=#attributes.offer_id#"
                title="#getLang('','Rakipler',40818)#"
                style="text-align:center;"
                closable="0">
            </cf_box>
        </cfif>
        <cfinclude template="../display/list_internaldemands.cfm">
    </div>
    <div class="col col-3">
        <cf_get_workcube_asset asset_cat_id="-11" company_id="#session.ep.company_id#" module_id='11' action_section='OFFER_ID' action_id='#attributes.offer_id#'>
        <cfif xml_is_offer_analysis><!--- XML de Teklifte analiz girilsinmi parametresi BK 20090116 --->
            <cf_get_member_analysis action_type='OFFER' action_type_id='#attributes.offer_id#' company_id='#get_offer.company_id#' partner_id='#get_offer.partner_id#' consumer_id='#get_offer.consumer_id#'>
        </cfif>    
    </div>
</div>