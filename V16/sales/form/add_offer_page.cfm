<cfinclude template="../query/get_offer_head.cfm">
<cfif not isdefined("page_type")>
	<cfset page_type = 11>
</cfif>
<cfquery name="get_page_types" datasource="#dsn#">
	SELECT 
		PAGE_TYPE_ID,
		PAGE_TYPE,
		PAGE_TYPE_DETAIL
	FROM 
		SETUP_PAGE_TYPES 
	WHERE 
		OUR_COMPANY_IDS LIKE '%,#session.ep.company_id#,%'
	ORDER BY
		PAGE_TYPE
</cfquery>
<cfquery name="get_offer_pg" datasource="#dsn3#">
	SELECT * FROM OFFER_PAGES WHERE OFFER_ID=#attributes.offer_id# ORDER BY PAGE_NO
</cfquery>
<cfset tr_topic = "">
<cfif isdefined("attributes.page_type")>
	<cfinclude template="../query/get_setup_pages.cfm">
	<cfset tr_topic = get_setup_page_detail.PAGE_TYPE_DETAIL>			
<cfelse>
	<cfset tr_topic = GET_PAGE_TYPES.PAGE_TYPE_DETAIL>
</cfif>
<cfparam name="attributes.modal_id" default="">

<cf_box title="#getLang('','Ek Sayfalar',40940)# : #get_offer_head.offer_number#" scroll="1" collapsable="1" resize="1" popup_box="#iif(isdefined("attributes.draggable"),1,0)#">
    <cfform name="add_page" method="post" action="#request.self#?fuseaction=sales.emptypopup_add_offer_page">
        <input type="Hidden" name="offer_id" id="offer_id" value="<cfoutput>#offer_id#</cfoutput>">
        <cf_box_elements>
            <div class="col col-3 col-md-3 col-sm-3 col-xs-12" type="column" index="1" sort="true">
                <div class="form-group" id="item-page_no">
                    <cfinput type="text" name="page_no" required="Yes" validate="integer" message="#getLang('','No girmelisiniz',40990)#" placeholder="#getLang('main','No',57487)#">
                </div> 
            </div>
            <div class="col col-3 col-md-3 col-sm-3 col-xs-12" type="column" index="1" sort="true">   
                <div class="form-group" id="item-page_type">
                    <select name="page_type" id="page_type" onChange="set_page_type();">
                        <option value=""><cf_get_lang dictionary_id='57630.Tip'><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                        <cfoutput query="get_page_types">
                            <option value="#PAGE_TYPE_ID#" <cfif isDefined("attributes.page_type") and (attributes.page_type eq PAGE_TYPE_ID)>selected </cfif>>#PAGE_TYPE# </option>	
                        </cfoutput> 
                    </select>
                </div>
            </div>    
            <div class="col col-3 col-md-3 col-sm-3 col-xs-12" type="column" index="1" sort="true">
                <div class="form-group" id="item-page_name">
                    <cfinput type="text" name="page_name" required="Yes" message="#getLang('','Başlık girmelisiniz',58059)#" placeholder="#getLang('main','Konu',57480)#">
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
            <cf_workcube_buttons is_upd='0' add_function="#iif(isdefined("attributes.draggable"),DE("kontrol() && loadPopupBox('add_page' , #attributes.modal_id#)"),DE(""))#">
        </cf_box_footer>
    </cfform>
</cf_box>

<script language="javascript">
    function set_page_type() {
        document.add_page.action='<cfoutput>#request.self#?fuseaction=sales.popup_form_add_page&offer_id=#attributes.offer_id#</cfoutput>';
        <cfif isDefined("attributes.draggable")>
            loadPopupBox("add_page",<cfoutput>#attributes.modal_id#</cfoutput>);
        <cfelse>
            document.add_page.submit();
        </cfif>
    }
	function kontrol()
	{
		if(document.add_page.page_type.value == '')
		{
			alert("<cf_get_lang dictionary_id='36169.Sayfa Tipi Seçiniz!'> !");
			return false;
		}
        return true;
	}
</script>
