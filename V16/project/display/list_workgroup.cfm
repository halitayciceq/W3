<cfset getComponent = createObject('component','V16.project.cfc.get_project_detail')>
<cfset gdpr_comp = createObject("component","AddOns.Devonomy.GDPR.cfc.data_officer")>
<cfif isdefined("attributes.PROJECT_ID")>
    <cfset GET_PROJECT_HEAD = getComponent.GET_PROJECT_HEAD(project_id : attributes.project_id)>
    <cfset GET_PROJECT_WORKGROUP = getComponent.GET_PROJECT_WORKGROUP(project_id : attributes.project_id)>
<cfelseif isDefined("attributes.action_id") and isDefined("attributes.action_field")>
    <cfset GET_ACTION_WORKGROUP = getComponent.GET_ACTION_WORKGROUP(action_field : attributes.action_field, action_id : attributes.action_id)>
</cfif>
<cfif isdefined("attributes.PROJECT_ID") and get_project_workgroup.recordcount>
    <cfset GET_EMPS = getComponent.GET_EMPS(WORKGROUP_ID : GET_PROJECT_WORKGROUP.WORKGROUP_ID)>
    <cfset work_group_row = GET_EMPS.recordcount>
<cfelseif isDefined("attributes.action_id") and isDefined("attributes.action_field") and get_action_workgroup.recordcount>
    <cfset GET_EMPS = getComponent.GET_EMPS(WORKGROUP_ID : GET_ACTION_WORKGROUP.WORKGROUP_ID)>
    <cfset work_group_row = GET_EMPS.recordcount>
<cfelseif isDefined("attributes.committee_id")>
    <cfset GET_EMPS = gdpr_comp.get_committee(data_officer_id : committee_id)>
    <cfset work_group_row = GET_EMPS.recordcount>
<cfelse>
	<cfset work_group_row = 0>
</cfif>
<cfif work_group_row neq 0> 
    <ul class="ui-list_type2">
    <cfoutput query="GET_EMPS">
        <li>
            <cfset this_role_id = role_id>
            <cfif len(this_role_id)>
                <cfset GET_ROLES = getComponent.GET_ROLES(PROJECT_ROLES_ID:this_role_id)>
            </cfif>
            <cfif len(EMPLOYEE_ID)>
                <div class="ui-list-img">                        
                    <cfset employee_photo = getComponent.EMPLOYEE_PHOTO(employee_id:EMPLOYEE_ID)>
                    <cfif len(employee_photo.photo)>
                        <cfset emp_photo ="../../documents/hr/#employee_photo.PHOTO#">
                    <cfelseif employee_photo.sex eq 1>
                        <cfset emp_photo ="images/male.jpg">
                    <cfelse>
                        <cfset emp_photo ="images/female.jpg">
                    </cfif>
                    <img src='#emp_photo#' />
                </div>
                <div class="ui-list-text">                                                
                    <span class="name">#get_emp_info(EMPLOYEE_ID,0,0)#</span>
                    <cfif len(this_role_id)><span class="title">#get_roles.PROJECT_ROLES#</span></cfif>
                    <ul class="contact-list">
                        <cfif len(employee_photo.employee_email)><li><a href="mailto:#employee_photo.employee_email#"><i class="fa fa-envelope-open-o" title="#employee_photo.employee_email#"></i></a></li></cfif>
                        <!--- <i class="fa fa-phone-square workgroup_span" title="<cfif len(employee_photo.MOBILCODE) or len(employee_photo.MOBILTEL)>#employee_photo.MOBILCODE# #employee_photo.MOBILTEL#<cfelseif len(employee_photo.MOBILCODE_SPC) and len(employee_photo.MOBILTEL_SPC)>#employee_photo.MOBILCODE_SPC# #employee_photo.MOBILTEL_SPC#<cfelse>-</cfif>"></i> --->
                        <li>
                            <a href="javascript://" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_emp_det&emp_id=#EMPLOYEE_ID#');"><i class="fa fa-user-o"></i></a>
                        </li>
                        <li>
                            <a href="#request.self#?fuseaction=objects.workflowpages&tab=1&subtab=2&employee_id=#EMPLOYEE_ID#" target="_blank"><i class="fa fa-comment-o"></i></a>
                        </li>
                    </ul>
                </div>
            <cfelseif len(CONSUMER_ID)>
                <div class="ui-list-img">   
                    <cfset employee_photo = getComponent.CONSUMER_PHOTO(consumer_id:CONSUMER_ID)>
                    <cfif len(employee_photo.picture)>
                        <cfset emp_photo ="../../documents/member/consumer/#employee_photo.picture#">
                    <cfelseif employee_photo.sex eq 1>
                        <cfset emp_photo ="images/male.jpg">
                    <cfelse>
                        <cfset emp_photo ="images/female.jpg">
                    </cfif>
                    <img src='#emp_photo#' />                    
                </div>
                <div class="ui-list-text">                                                                        
                    <span class="name">#get_cons_info(CONSUMER_ID,1,0)#</span>
                    <cfif len(this_role_id)><span class="title">#get_roles.PROJECT_ROLES#</span></cfif>
                    <ul class="contact-list">
                        <cfif len(employee_photo.consumer_email)><li><a href="mailto:#employee_photo.consumer_email#"><i class="fa fa-envelope-open-o" title="#employee_photo.consumer_email#"></i></a></li></cfif>
                        <!--- <i class="fa fa-phone-square workgroup_span" title="<cfif len(employee_photo.MOBIL_CODE) or len(employee_photo.MOBILTEL)>#employee_photo.MOBIL_CODE# #employee_photo.MOBILTEL#<cfelseif len(employee_photo.CONSUMER_WORKTELCODE) and len(employee_photo.CONSUMER_WORKTEL)>#employee_photo.CONSUMER_WORKTELCODE# #employee_photo.CONSEUMER_WORKTEL#<cfelse>-</cfif>"></i> --->
                        <li>
                            <a href="javascript://" onclick="openBoxDraggable('#request.self#?fuseaction=objects.widget_loader&widget_load=ConsumerDetail&draggable=1&con_id=#CONSUMER_ID#');"><i class="fa fa-user-o"></i></a>
                        </li>
                      <!---   <li>
                            <a href="#request.self#?fuseaction=objects.workflowpages&tab=1&subtab=2&consumer_id=#CONSUMER_ID#" target="_blank"><i class="fa fa-comment-o"></i></a>
                        </li> --->
                    </ul>
                </div>
            <cfelseif len(PARTNER_ID)>
                <div class="ui-list-img">                                            
                    <cfset employee_photo = getComponent.PARTNER_PHOTO(partner_id:PARTNER_ID)>
                    <cfif len(employee_photo.photo)>
                        <cfset emp_photo ="../../documents/hr/#employee_photo.PHOTO#">
                    <cfelseif employee_photo.sex eq 1>
                        <cfset emp_photo ="images/male.jpg">
                    <cfelse>
                        <cfset emp_photo ="images/female.jpg">
                    </cfif>
                    <img src='#emp_photo#' />                    
                    <cfset GET_COMPANY_PARTNER = getComponent.GET_COMPANY_PARTNER(PARTNER_ID :PARTNER_ID)>       
                    <cfset member_name_ = '#GET_COMPANY_PARTNER.COMPANY_PARTNER_NAME# #GET_COMPANY_PARTNER.COMPANY_PARTNER_SURNAME#-#GET_COMPANY_PARTNER.NICKNAME#'>                   
                </div>
                <div class="ui-list-text">                                                
                    <span class="name">#member_name_#</span>
                    <cfif len(this_role_id)><span class="title">#get_roles.PROJECT_ROLES#</span></cfif>
                    <ul class="contact-list">
                        <cfif len(employee_photo.COMPANY_PARTNER_EMAIL)><li><a href="mailto:#employee_photo.COMPANY_PARTNER_EMAIL#"><i class="fa fa-envelope-open-o" title="#employee_photo.COMPANY_PARTNER_EMAIL#"></i></a></li></cfif>
                       <!--- <i class="fa fa-phone-square workgroup_span" title="<cfif len(employee_photo.MOBIL_CODE) or len(employee_photo.MOBILTEL)>#employee_photo.MOBIL_CODE# #employee_photo.MOBILTEL#<cfelseif len(employee_photo.COMPANY_PARTNER_TELCODE) and len(employee_photo.COMPANY_PARTNER_TEL)>#employee_photo.COMPANY_PARTNER_TELCODE# #employee_photo.COMPANY_PARTNER_TEL#<cfelse>-</cfif>"></i> --->
                        <li>
                            <a href="javascript://" onclick="openBoxDraggable('#request.self#?fuseaction=objects.widget_loader&widget_load=PartnerDetail&draggable=1&par_id=#PARTNER_ID#');"><i class="fa fa-user-o"></i></a>
                        </li>
                        <!--- <li>
                            <a href="#request.self#?fuseaction=objects.workflowpages&tab=1&subtab=2&partner_id=#PARTNER_ID#" target="_blank"><i class="fa fa-comment-o"></i></a>
                        </li> --->
                    </ul>
                </div>
            </cfif>
        </li>
    </cfoutput>
    </ul>
<cfelse>
    <p><cf_get_lang dictionary_id='57484.Kayıt Yok'></p>
</cfif>