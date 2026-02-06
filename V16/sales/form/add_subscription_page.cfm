<!--- Sistemler Ek Sayfalar FB 20080227 --->
<cfquery name="get_subscription_head" datasource="#dsn3#">
	SELECT 
		SUBSCRIPTION_ID, 
        IS_ACTIVE, 
        SUBSCRIPTION_NO,
        SUBSCRIPTION_HEAD, 
        COMPANY_ID, 
        PARTNER_ID, 
        CONSUMER_ID, 
        PRODUCT_ID, 
        STOCK_ID, 
        CONTRACT_NO, 
        INVOICE_COMPANY_ID,
        INVOICE_CONSUMER_ID, 
        SUBSCRIPTION_TYPE_ID, 
        SUBSCRIPTION_STAGE, 
        SALES_COMPANY_ID, 
        SALES_PARTNER_ID, 
        SALES_CONSUMER_ID, 
        REF_COMPANY_ID, 
        REF_PARTNER_ID, 
        REF_CONSUMER_ID, 
        REF_EMPLOYEE_ID, 
        MONTAGE_EMP_ID, 
        PAYMENT_TYPE_ID, 
        MONTAGE_DATE, 
        START_DATE, 
        FINISH_DATE, 
        SUBSCRIPTION_DETAIL, 
        SHIP_ADDRESS, 
        SHIP_POSTCODE, 
        SHIP_SEMT, 
        SHIP_COUNTY_ID, 
        SHIP_CITY_ID, 
        SHIP_COUNTRY_ID,
        INVOICE_ADDRESS, 
        INVOICE_POSTCODE, 
        INVOICE_SEMT, 
        INVOICE_COUNTY_ID, 
        INVOICE_CITY_ID, 
        INVOICE_COUNTRY_ID, 
        CONTACT_ADDRESS, 
        CONTACT_POSTCODE, 
        CONTACT_SEMT, 
        CONTACT_COUNTY_ID, 
        CONTACT_CITY_ID, 
        CONTACT_COUNTRY_ID, 
        CANCEL_DATE, 
        SALES_EMP_ID, 
        MEMBER_CC_ID, 
        SPECIAL_CODE, 
        PREMIUM_DATE, 
        INVOICE_PARTNER_ID, 
        SALES_ADD_OPTION_ID, 
        SUBSCRIPTION_ADD_OPTION_ID, 
        PROJECT_ID, 
        SALES_MEMBER_COMM_VALUE, 
        SALES_MEMBER_COMM_MONEY, 
        ASSETP_ID, 
        VALID_DAYS, 
        START_CLOCK_1, 
        START_MINUTE_1, 
        FINISH_CLOCK_1, 
        FINISH_MINUTE_1, 
        IS_GENERAL_DATE, 
        START_CLOCK_2, 
        START_MINUTE_2, 
        FINISH_CLOCK_2, 
        FINISH_MINUTE_2, 
        START_CLOCK_3, 
        START_MINUTE_3, 
        FINISH_CLOCK_3, 
        FINISH_MINUTE_3, 
        HOUR1, 
        MINUTE1, 
        RESPONSE_HOUR1,
        RESPONSE_MINUTE1, 
        CAMPAIGN_ID, 
        SHIP_COORDINATE_1, 
        SHIP_COORDINATE_2, 
        INVOICE_COORDINATE_1, 
        INVOICE_COORDINATE_2, 
        CONTACT_COORDINATE_1, 
        CONTACT_COORDINATE_2, 
        RECORD_EMP, 
        RECORD_IP, 
        RECORD_DATE, 
        UPDATE_EMP, 
        UPDATE_IP, 
        UPDATE_DATE, 
        OPP_ID, 
        RECORD_PAR, 
        UPDATE_PAR 
	FROM 
		SUBSCRIPTION_CONTRACT 
	WHERE 
		SUBSCRIPTION_ID = #attributes.subs_id#
</cfquery>
<cfif not isdefined("page_type")><cfset page_type = 11></cfif>
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
<cfquery name="get_subscription_pg" datasource="#dsn3#">
	SELECT 
    	PAGE_ID, 
        SUBSCRIPTION_ID, 
        PAGE_NAME, 
        PAGE_CONTENT, 
        PAGE_TYPE, 
        PAGE_NO, 
        SUBSCRIPTION_ZONE, 
        RECORD_DATE, 
        RECORD_EMP, 
        RECORD_IP,
        UPDATE_DATE, 
        UPDATE_EMP, 
        UPDATE_IP 
    FROM 
    	SUBSCRIPTION_PAGES 
    WHERE 
    	SUBSCRIPTION_ID = #attributes.subs_id# 
    ORDER BY 
	    PAGE_NO
</cfquery>
<cfset tr_topic = "">
<cfif isdefined("page_type")>
	<cfquery name="get_setup_page_detail" datasource="#dsn#">
		SELECT
			PAGE_TYPE_ID, 
            PAGE_TYPE, 
            PAGE_TYPE_DETAIL, 
            OUR_COMPANY_IDS, 
            RECORD_DATE,
            RECORD_IP, 
            RECORD_EMP, 
            UPDATE_DATE, 
            UPDATE_IP, 
            UPDATE_EMP
		FROM
			SETUP_PAGE_TYPES
			<cfif isDefined("attributes.page_type")>		
			WHERE
				PAGE_TYPE_ID = #attributes.page_type#
			</cfif>			
	</cfquery>
	<cfset tr_topic = get_setup_page_detail.page_type_detail>			
<cfelse>
	<cfset tr_topic = get_page_types.page_type_detail>
</cfif>
<cfparam name="attributes.modal_id" default="">
<cf_box title="#getLang('','Ek Sayfa Ekle',40862)#: #get_subscription_head.subscription_no#" scroll="1" collapsable="1" resize="1" popup_box="#iif(isdefined("attributes.draggable"),1,0)#">
    <cfform name="add_subscription_page" id="add_subscription_page"method="post" action="#request.self#?fuseaction=sales.emptypopup_add_subscription_page" add_href="openBoxDraggable('#request.self#?fuseaction=sales.popup_add_subscription_page&subs_id=#attributes.subs_id#')">
        <input type="hidden" name="subscription_id" id="subscription_id" value="<cfoutput>#subs_id#</cfoutput>"> 
        <input type="hidden" name="draggable" id="draggable" value="<cfif isdefined('attributes.draggable')><cfoutput>#attributes.draggable#</cfoutput></cfif>">
        <input type="hidden" name="modal_id" id="modal_id" value="<cfif isdefined('attributes.modal_id')><cfoutput>#attributes.modal_id#</cfoutput></cfif>">
        <cf_box_elements>
            <cfif get_subscription_pg.recordcount> 
                            <table width="99%" align="center">
                                <cfoutput query="get_subscription_pg">
                                    <tr>
                                        <cfquery name="get_types" datasource="#dsn#">
                                            SELECT 
                                                PAGE_TYPE_ID, 
                                                PAGE_TYPE, 
                                                PAGE_TYPE_DETAIL, 
                                                OUR_COMPANY_IDS, 
                                                RECORD_DATE, 
                                                RECORD_IP, 
                                                RECORD_EMP, 
                                                UPDATE_DATE, 
                                                UPDATE_IP, 
                                                UPDATE_EMP 
                                            FROM 
                                                SETUP_PAGE_TYPES 
                                            WHERE 
                                                PAGE_TYPE_ID = #page_type#
                                        </cfquery>
                                        <td align="center" width="20" class="txtboldblue">#page_no#</td>
                                        <td><a href="javascript://" onclick="openBoxDraggable('#request.self#?fuseaction=sales.popup_upd_subscription_page&page_id=#get_subscription_pg.page_id#&subs_id=#attributes.subs_id#')" class="tableyazi">#get_types.page_type# - #page_name#</a></td> 
                                    </tr>
                                </cfoutput>
                            </table>
                        </cfif>
                <div class="form-group" id="item-page_no">
                    <label class="col col-2 col-md-2 col-xs-2"><cf_get_lang dictionary_id='66478.No'></label>
                    <div class="col col-9 col-md-9 col-sm-9 col-xs-9">
                        <cfsavecontent variable="message"><cf_get_lang dictionary_id='51510.No Girmelisiniz'></cfsavecontent>
                        <cfinput type="text" name="page_no" required="Yes" validate="integer" message="#message#">
                    </div>
                </div>    
                <div class="form-group" id="item-page_type">
                    <label class="col col-2 col-md-2 col-xs-2"><cf_get_lang dictionary_id='59088.Tip'></label>
                    <div class="col col-8 col-md-8 col-sm-8 col-xs-9">
                        <select name="page_type" id="page_type" onChange="document.add_subscription_page.action=''; document.add_subscription_page.submit();">
                            <cfoutput query="get_page_types">
                                <option value="#PAGE_TYPE_ID#" <cfif isDefined("attributes.page_type") and (attributes.page_type eq PAGE_TYPE_ID)>selected </cfif>>#PAGE_TYPE# </option>	
                            </cfoutput> 
                        </select>
                    </div>
                </div>
                <div class="form-group" id="item-page_name">
                    <label class="col col-2 col-md-2 col-xs-2"><cf_get_lang dictionary_id='58820.Başlık'></label>
                    <div class="col col-9 col-md-9 col-sm-9 col-xs-9">
                        <cfsavecontent variable="message"><cf_get_lang dictionary_id='58059.Başlık Girmelisiniz'></cfsavecontent>
                        <cfinput type="text" name="page_name" required="Yes" message="#message#">
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
        <cf_box_footer><cf_workcube_buttons is_upd='0' add_function="kontrol()"></cf_box_footer>
    </cfform>
</cf_box>
<script type="text/javascript">
    function kontrol() {
        <cfif isdefined("attributes.draggable")>
            loadPopupBox('add_subscription_page' , <cfoutput>#attributes.modal_id#</cfoutput>);
            return false;
        <cfelse>
            return true;
        </cfif>
    }
</script>
