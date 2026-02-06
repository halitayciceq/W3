<cfif len(GET_OPPORTUNITY.SERVICE_ID)>
	<cfquery name="GET_SERVICE" datasource="#dsn#">
		SELECT SERVICE_ID,SERVICE_NO FROM G_SERVICE WHERE SERVICE_ID = #get_opportunity.service_id#
	</cfquery>
<cfelse>
	<cfset get_service.recordcount = 0>
</cfif>

<cfif len(attributes.opp_id)>
    <cfquery name="get_systems_opp" datasource="#dsn3#">
        SELECT SUBSCRIPTION_ID,SUBSCRIPTION_NO FROM SUBSCRIPTION_CONTRACT WHERE OPP_ID=#attributes.opp_id#
    </cfquery>
<cfelse>
	<cfset get_systems_opp.recordcount=0>
</cfif>
<cfif isdefined("contact_type")><cf_display_member action_id="#member_id#" action_type_id="#contact_type#" dsp_account="#dsp_account#"></cfif>
		

<cfif get_module_user(11)>
    <!--- Satış Teklifler --->
    <cf_box 
        id="opportunity_b" 
        closable="0" 
        unload_body="1"
        info_href="javascript:openBoxDraggable('#request.self#?fuseaction=sales.popup_list_offer&opp_id=#attributes.opp_id#')" 
        add_href="#request.self#?fuseaction=sales.list_offer&event=add&opp_id=#attributes.opp_id#"
        box_page="#request.self#?fuseaction=sales.opportunity_offer&opp_id=#attributes.opp_id#"
        collapsed="1" 
        title="#getLang('','Satış Teklifleri',42069)#">
    </cf_box>
    <!--- satınalma teklifi --->
    <cf_box 
        id="opportunity_purchase" 
        closable="0" 
        unload_body="1"
        add_href="#request.self#?fuseaction=purchase.list_offer&event=add&opportunity_id=#attributes.opp_id#"
        info_href="javascript:openBoxDraggable('#request.self#?fuseaction=sales.popup_list_offer&opp_id=#attributes.opp_id#&purchase_=1')" 
        box_page="#request.self#?fuseaction=purchase.opportunity_offer&opp_id=#attributes.opp_id#"
        collapsed="1" 
        title="#getLang('','satınalma teklifi',49749)#">
    </cf_box>
    <!--- sipariş al --->
        <cf_box 
        id="opp_order" 
        closable="0" 
        unload_body="1"
        add_href="#request.self#?fuseaction=sales.list_order&event=add&opportunity_id=#attributes.opp_id#"
        info_href="javascript:openBoxDraggable('#request.self#?fuseaction=sales.popup_list_orders&opp_id=#attributes.opp_id#')" 
        box_page="#request.self#?fuseaction=sales.ajax_order_opp&opp_id=#attributes.opp_id#"
        collapsed="1" 
        title="#getLang('','Sipariş Al',40809)#">
    </cf_box>
    <!---Sistemler--->
    <cf_box 
        id="get_related_system_b" 
        closable="0" 
        unload_body="1"
        box_page="#request.self#?fuseaction=sales.list_systems_opp&opp_id=#attributes.opp_id#"
        collapsed="1" 
        title="#getLang('main','Aboneler',30003)#">
    </cf_box>
    <!--- Servis Basvurular --->
    <cf_box 
        id="get_related_services_b" 
        closable="0" 
        unload_body="1"
        box_page="#request.self#?fuseaction=sales.list_related_services&opp_id=#attributes.opp_id#"
        collapsed="1" 
        title="#getLang('sales',29)#">
    </cf_box>
<!--- Belgeler --->
    <cf_get_workcube_asset company_id="#session.ep.company_id#" asset_cat_id="-13" module_id='11' action_section='OPP_ID' action_id='#attributes.opp_id#'>
</cfif>
<!--- İliskili Olaylar --->
<cfif get_module_user(47)>
    <cfif xml_is_opportunity_actions eq 1>
        <cf_get_related_events company_id="#session.ep.company_id#" 
            action_section='OPPORTUNITY_ID' 
            action_id='#attributes.opp_id#' 
            action_project_id='#get_opportunity.project_id#'>
    <cfelse>
        <cf_get_related_events company_id="#session.ep.company_id#" action_section='OPPORTUNITY_ID' action_id='#attributes.opp_id#'>
    </cfif>
    <!--- XML de Fırsatta analiz girilsinmi parametresi BK 20090112 --->
	<cf_get_member_analysis action_type='OPPORTUNITY' action_type_id='#attributes.opp_id#' company_id='#get_opportunity.company_id#' partner_id='#get_opportunity.partner_id#' consumer_id='#get_opportunity.consumer_id#'>
</cfif>

