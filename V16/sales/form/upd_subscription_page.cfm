<cfquery name="get_subscription_head" datasource="#dsn3#">
	SELECT * FROM SUBSCRIPTION_CONTRACT WHERE SUBSCRIPTION_ID = #attributes.subs_id#
</cfquery>
<cfquery name="get_page_types" datasource="#dsn#">
	SELECT PAGE_TYPE_ID,PAGE_TYPE FROM SETUP_PAGE_TYPES WHERE OUR_COMPANY_IDS LIKE '%,#session.ep.company_id#,%'
</cfquery>
<cfquery name="get_subscription_pages" datasource="#dsn3#">
	SELECT * FROM SUBSCRIPTION_PAGES WHERE PAGE_ID = #attributes.page_id# ORDER BY PAGE_NO
</cfquery>
<cfquery name="get_subscription_pg" datasource="#dsn3#">
	SELECT * FROM SUBSCRIPTION_PAGES WHERE SUBSCRIPTION_ID=#attributes.subs_id#  ORDER BY PAGE_NO
</cfquery>
<cfif isdefined("attributes.page_type")>
	<cfquery name="get_setup_page_detail" datasource="#dsn#">
		SELECT
			*
		FROM
			SETUP_PAGE_TYPES
			<cfif isDefined("attributes.page_type")>		
			WHERE
				PAGE_TYPE_ID = #attributes.page_type#
			</cfif>			
	</cfquery>
	<cfset tr_topic = get_setup_page_detail.page_type_detail>			
<cfelse>
	<cfset tr_topic = get_subscription_pages.page_content>
</cfif>
<cfparam name="attributes.modal_id" default="">
<cf_box title="#getLang('','Ek Sayfa Ekle',40862)#: #get_subscription_head.subscription_no#" scroll="1" collapsable="1" resize="1" popup_box="#iif(isdefined("attributes.draggable"),1,0)#" add_href="openBoxDraggable('#request.self#?fuseaction=sales.popup_add_subscription_page&subs_id=#attributes.subs_id#','','ui-draggable-box-medium')">
    <cfform name="upd_page" id="upd_page" method="post" action="#request.self#?fuseaction=sales.emptypopup_upd_subscription_page&subs_id=#subs_id#">
        <input type="Hidden" name="page_id" id="page_id" value="<cfoutput>#page_id#</cfoutput>">
        <input type="hidden" name="draggable" id="draggable" value="<cfif isdefined('attributes.draggable')><cfoutput>#attributes.draggable#</cfoutput></cfif>">
        <input type="hidden" name="modal_id" id="modal_id" value="<cfif isdefined('attributes.modal_id')><cfoutput>#attributes.modal_id#</cfoutput></cfif>">
        <cf_box_elements>
                <div class="form-group" id="item-page_no">
                    <label class="col col-2 col-md-2 col-xs-2"><cf_get_lang dictionary_id='66478.No'></label>
                    <div class="col col-9 col-md-9 col-sm-9 col-xs-9">
                        <cfsavecontent variable="message"><cf_get_lang dictionary_id='51510.No Girmelisiniz'></cfsavecontent>
                        <cfinput type="text" name="page_no" id="page_no"required="Yes" validate="integer" message="#message#" value="#get_subscription_pages.page_no#">
                    </div>
                </div>    
                <div class="form-group" id="item-page_type">
                    <label class="col col-2 col-md-2 col-xs-2"><cf_get_lang dictionary_id='59088.Tip'></label>
                    <div class="col col-8 col-md-8 col-sm-8 col-xs-9">
                        <select name="page_type" id="page_type" onchange="document.upd_page.action=''; document.upd_page.submit();">
                            <cfoutput query="get_page_types">
                                <option value="#PAGE_TYPE_ID#" <cfif (isDefined("attributes.page_type") and attributes.page_type eq PAGE_TYPE_ID) or (not isDefined("attributes.page_type") and get_subscription_pages.page_type eq PAGE_TYPE_ID)>selected</cfif>>#PAGE_TYPE#</option>
                            </cfoutput>
                        </select>
                    </div>
                </div>
                <div class="form-group" id="item-page_name">
                    <label class="col col-2 col-md-2 col-xs-2"><cf_get_lang dictionary_id='58820.Başlık'></label>
                    <div class="col col-9 col-md-9 col-sm-9 col-xs-9">
                        <cfsavecontent variable="message"><cf_get_lang dictionary_id='58059.Başlık Girmelisiniz'></cfsavecontent>
                        <cfinput type="text" name="page_name" id="page_name"value="#get_subscription_pages.page_name#" required="Yes" message="#message#">
                    </div>
                </div>
            <div class="row">   
                <div class="form-group" id="item-page_content">
                    <cfmodule template="/fckeditor/fckeditor.cfm"
                    toolbarSet="WRKContent"
                    basePath="/fckeditor/"
                    instanceName="page_content"
                    value="#tr_topic#"
                    width="700"
                    height="250">
                </div>
            </div>
        </cf_box_elements>
        <cf_box_footer>
            <cf_workcube_buttons is_upd='1' add_function="kontrol()" del_function="#isDefined('attributes.draggable') ? 'deleteFunc()' : ''#">
        </cf_box_footer>  
    </cfform>
</cf_box>
<script type="text/javascript">
    function kontrol() {
        <cfif isdefined("attributes.draggable")>
            loadPopupBox('upd_page' , <cfoutput>#attributes.modal_id#</cfoutput>);
            return false;
        <cfelse>
            return true;
        </cfif>
    }
    <cfif isDefined('attributes.draggable')>
        function deleteFunc() {
            openBoxDraggable('<cfoutput>#request.self#?fuseaction=sales.emptypopup_del_subscription_page&page_id=#attributes.page_id#</cfoutput>',<cfoutput>#attributes.modal_id#</cfoutput>);
        }
    </cfif>

</script>
