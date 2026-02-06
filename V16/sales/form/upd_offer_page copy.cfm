<cfinclude template="../query/get_offer_head.cfm">
<cfinclude template="../query/get_offer.cfm">
<cfinclude template="../query/get_offer_page.cfm">

<cfquery name="get_page_types" datasource="#dsn#">
  SELECT PAGE_TYPE_ID,PAGE_TYPE FROM SETUP_PAGE_TYPES WHERE OUR_COMPANY_IDS LIKE '%,#session.ep.company_id#,%'
</cfquery>

<cfquery name="get_offer_pages" datasource="#dsn3#">
	SELECT 
	    OFFER_ID, 
        PAGE_ID, 
        PAGE_NAME, 
        PAGE_CONTENT, 
        PAGE_TYPE, 
        PAGE_NO, 
        OFFER_ZONE, 
        RECORD_DATE, 
        RECORD_EMP, 
        RECORD_IP, 
        UPDATE_DATE, 
        UPDATE_EMP, 
        UPDATE_IP 
    FROM 
    	OFFER_PAGES 
    WHERE 
    	PAGE_ID=<cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.page_id#">
    ORDER BY 
    	PAGE_NO
</cfquery>
<cfquery name="get_offer_pg" datasource="#dsn3#">
	SELECT 
	    OFFER_ID, 
        PAGE_ID, 
        PAGE_NAME, 
        PAGE_CONTENT, 
        PAGE_TYPE, 
        PAGE_NO, 
        OFFER_ZONE, 
        RECORD_DATE, 
        RECORD_EMP, 
        RECORD_IP, 
        UPDATE_DATE, 
        UPDATE_EMP, 
        UPDATE_IP 
    FROM 
    	OFFER_PAGES 
    WHERE 
	    OFFER_ID=<cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.offer_id#">
    ORDER BY 
    	PAGE_NO
</cfquery>
<cfif isdefined("attributes.page_type")>
	<cfinclude template="../query/get_setup_pages.cfm">
	<cfset tr_topic = get_setup_page_detail.PAGE_TYPE_DETAIL>			
<cfelse>
	<cfset tr_topic = get_offer_pages.page_content>
    <cfset attributes.page_type = get_offer_pages.page_type>
</cfif>

<!--- Teklif Tarihi ve Teslim Tarihi arasındaki iş günü farkını hesapla --->
<cfset teslimat_gun_sayisi = "">
<cfif isDefined("get_offer.offer_date") and isDefined("get_offer.deliverdate") and isDate(get_offer.offer_date) and isDate(get_offer.deliverdate)>
	<cfset offer_date_val = get_offer.offer_date>
	<cfset deliver_date_val = get_offer.deliverdate>
	<cfset is_gunu_sayaci = 0>
	<cfset current_date = offer_date_val>
	<cfloop condition="current_date LT deliver_date_val">
		<cfset current_date = DateAdd("d", 1, current_date)>
		<cfset gun_no = DayOfWeek(current_date)>
		<!--- Hafta sonu değilse (1=Pazar, 7=Cumartesi) --->
		<cfif gun_no NEQ 1 AND gun_no NEQ 7>
			<cfset is_gunu_sayaci = is_gunu_sayaci + 1>
		</cfif>
	</cfloop>
	<cfset teslimat_gun_sayisi = is_gunu_sayaci>
</cfif>

<!--- Ödeme Yöntemi bilgisini al --->
<cfset odeme_yontemi = "">
<cfif isDefined("get_offer.paymethod") and len(get_offer.paymethod)>
	<cfquery name="get_paymethod_info" datasource="#dsn#">
		SELECT PAYMETHOD FROM SETUP_PAYMETHODS WHERE PAYMETHOD_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_offer.paymethod#">
	</cfquery>
	<cfif get_paymethod_info.recordcount>
		<cfset odeme_yontemi = get_paymethod_info.paymethod>
	</cfif>
</cfif>

<!--- tr_topic içindeki placeholder'ları dinamik değerlerle değiştir --->
<cfif len(teslimat_gun_sayisi)>
	<cfset tr_topic = ReplaceNoCase(tr_topic, "7-10 iş günüdür", "#teslimat_gun_sayisi# iş günüdür", "ALL")>
	<cfset tr_topic = ReplaceNoCase(tr_topic, "10 iş günüdür", "#teslimat_gun_sayisi# iş günüdür", "ALL")>
</cfif>
<cfif len(odeme_yontemi)>
	<cfset tr_topic = ReplaceNoCase(tr_topic, "nakit ödemelidir", "#odeme_yontemi#", "ALL")>
</cfif>

<cfsavecontent variable="right_">
    <cfif not isdefined("attributes.draggable")><li><a href="javascript://" onClick="windowopen('<cfoutput>#request.self#?fuseaction=sales.popup_form_add_page&offer_id=#attributes.offer_id#</cfoutput>','page');" class="font-red-pink"><i class="fa fa-plus" title="<cf_get_lang dictionary_id='57582.Ekle'>"></i></a></li></cfif>
    <li><cfoutput><a href="javascript://" onclick="windowopen('#request.self#?fuseaction=objects.popup_print_files&action_id=#attributes.offer_id#&print_type=76','page');" class="font-red-pink"></cfoutput><i class="fa fa-print" alt="<cf_get_lang dictionary_id='57474.Yazdır'>" title="<cf_get_lang dictionary_id='57474.Yazdır'>"></i></a></li><!--- ISBAK SATIS TEKLIF 20121001 ST --->
</cfsavecontent>
<cfparam name="attributes.modal_id" default="">
<cf_box title="#getLang('','Ek Sayfalar',40940)# : #get_offer_head.offer_number#" scroll="1" collapsable="1" resize="1" popup_box="#iif(isdefined("attributes.draggable"),1,0)#" right_images="#right_#">
    <cfform name="upd_page" method="POST" action="#request.self#?fuseaction=sales.emptypopup_upd_offer_page&offer_id=#offer_id#" >
    <input type="Hidden" name="page_id" id="page_id" value="<cfoutput>#page_id#</cfoutput>">
        <cf_box_elements>
            <div class="col col-3 col-md-3 col-sm-3 col-xs-12" type="column" index="1" sort="true">
                <div class="form-group" id="item-page_no">
                    <cfinput type="text" name="page_no" value="#get_offer_pages.PAGE_NO#" required="Yes" validate="integer" message="#getLang('','No girmelisiniz',40990)#" placeholder="#getLang('main','No',57487)#">
                </div> 
            </div>
            <div class="col col-3 col-md-3 col-sm-3 col-xs-12" type="column" index="1" sort="true">   
                <div class="form-group" id="item-page_type">
                    <select name="page_type" id="page_type" onChange="set_page_type();">
                        <option value=""><cf_get_lang dictionary_id='57630.Tip'><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                        <cfoutput query="get_page_types">
                            <option value="#PAGE_TYPE_ID#" <cfif (isDefined("attributes.page_type") and (attributes.page_type eq PAGE_TYPE_ID))> selected </cfif>>#PAGE_TYPE# </option>	
                        </cfoutput> 
                    </select>
                </div>
            </div>    
            <div class="col col-3 col-md-3 col-sm-3 col-xs-12" type="column" index="1" sort="true">
                <div class="form-group" id="item-page_name">
                    <cfinput type="text" name="page_name" value="#get_offer_pages.PAGE_NAME#" required="Yes" message="#getLang('','Başlık girmelisiniz',58059)#" placeholder="#getLang('main','Konu',57480)#">
                </div>
            </div>
            <div class="col col-12 col-md-12 col-sm-12 col-xs-12" type="column" index="2" sort="true">
                <div class="form-group" id="item-page_content">
                        <cfmodule template="/fckeditor/fckeditor.cfm"
                        toolbarSet="WRKContent"
                        basePath="/fckeditor/"
                        instanceName="page_content"
                        value="#tr_topic#"
                        width="700"
                        height="300">
                </div>
            </div>
        </cf_box_elements>
        <cf_box_footer>
            <cf_workcube_buttons is_upd='1' add_function="#iif(isdefined("attributes.draggable"),DE("kontrol() && loadPopupBox('upd_page' , #attributes.modal_id#)"),DE(""))#" del_function="#isDefined('attributes.draggable') ? 'deleteFunc()' : ''#">
        </cf_box_footer>
    </cfform>
</cf_box>
<script language="javascript">
    function kontrol() {
        if(document.upd_page.page_type.value == '')
            {
                alert("<cf_get_lang dictionary_id='36169.Sayfa Tipi Seçiniz!'> !");
                return false;
            }
            return true;
    }
    function set_page_type() {
        document.upd_page.action='<cfoutput>#request.self#?fuseaction=sales.popup_form_upd_page&page_id=#get_offer_pg.page_id#&offer_id=#attributes.offer_id#</cfoutput>';
        <cfif isDefined("attributes.draggable")>
            loadPopupBox("upd_page",<cfoutput>#attributes.modal_id#</cfoutput>);
        <cfelse>
            document.upd_page.submit();
        </cfif>
    }
    <cfif isDefined('attributes.draggable')>
        function deleteFunc() {
            openBoxDraggable('<cfoutput>#request.self#?fuseaction=sales.popup_del_offer_page&PAGE_ID=#page_id#&offer_id=#offer_id#</cfoutput>',<cfoutput>#attributes.modal_id#</cfoutput>);
        }
    </cfif>
</script>