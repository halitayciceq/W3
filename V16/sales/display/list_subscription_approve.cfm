<cfset subscription_approve = createObject("component","V16.sales.cfc.subscription_approve") />
<cfif isDefined('url.subscription_id') and len(url.subscription_id)>
<cfset get_subscription_no = subscription_approve.get_subscription_no(company_id : session.ep.company_id,subscription_id : url.subscription_id)>
    <cfparam name="attributes.subscription_id" default="#url.subscription_id#">
    <cfparam name="attributes.subscription_no" default="#get_subscription_no.SUBSCRIPTION_NO#">
<cfelse>
    <cfparam name="attributes.subscription_id" default="">
    <cfparam name="attributes.subscription_no" default="">
</cfif>
<cfparam name="attributes.app_domain" default="">
<cfparam name="attributes.form_submitted" default="#len(attributes.subscription_id) ? 1 : 0#">

<cfif attributes.form_submitted eq 1>
    <cfset subscription_approve = createObject("component","V16.sales.cfc.subscription_approve") />
    <cfset get_subscription_approve = subscription_approve.get_subscription_approve(
        company_id: session.ep.company_id,
        subscription_id: (len(attributes.subscription_id) and len(attributes.subscription_no)) ? attributes.subscription_id : '',
        app_domain: attributes.app_domain
    ) />
<cfelse>
    <cfset get_subscription_approve = {recordcount: 0} />
</cfif>

<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box>
        <cfform name="subscription_approve" id="subscription_approve" method="post">
            <input type="hidden" name="form_submitted" id="form_submitted" value="1">
            <cf_box_search>
                <div class="form-group">
                    <div class="input-group">
                        <cfinput type="hidden" name="subscription_id" id="subscription_id" value="#len(attributes.subscription_id) ? attributes.subscription_id : ''#">
                        <cfinput type="text" name="subscription_no" id="subscription_no" readonly value="#len(attributes.subscription_no) ? attributes.subscription_no : ''#" placeholder="#getLang('','Abone No',29502)#">
                        <span class="input-group-addon btn_Pointer icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_subscription&field_id=subscription_approve.subscription_id&field_no=subscription_approve.subscription_no');"></span>
                    </div>
                </div>
                <div class="form-group" id="item-app_domain">
                    <div class="input-group">
                        <cfinput type="text" name="app_domain" id="app_domain" value="#len(attributes.app_domain) ? attributes.app_domain : ''#" placeholder="#getLang('','Domain',57892)#">
                        <span class="input-group-addon btn_Pointer icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_subscription&field_id=subscription_approve.subscription_id&field_no=subscription_approve.subscription_no');"></span>
                    </div>
                </div>
                <div class="form-group">
                    <cf_wrk_search_button button_type="4">
                </div>
            </cf_box_search>
        </cfform>
    </cf_box>
    <cf_box title="#getLang('','Sözleşme Elektronik Onayları',64849)#" uidrop="1" hide_table_column="1">
        <cf_grid_list>
            <thead>
                <tr>
                    <th width="30"><cf_get_lang dictionary_id='58577.Sıra'></th>
                    <th width="20"><i class="fa fa-check-circle-o" title="<cf_get_lang dictionary_id='57500.Onay'>" alt="<cf_get_lang dictionary_id='57500.Onay'>"></i></th>
                    <th><cf_get_lang dictionary_id='29502.Abone No'></th>
                    <th><cf_get_lang dictionary_id='58832.Abone'></th>
                    <th><cf_get_lang dictionary_id='57892.Domain'></th>
                    <th><cf_get_lang dictionary_id='32655.Onay Tarihi'></th>
                    <th><cf_get_lang dictionary_id='30982.Onaylayan'></th>
                    <th>Release No</th>
                    <th>Patch No</th>
                </tr>
            </thead>
            <tbody>
                <cfif attributes.form_submitted eq 1>
                    <cfif get_subscription_approve.recordcount>
                        <cfoutput query = "get_subscription_approve">
                            <tr>
                                <td>#currentrow#</td>
                                <td>
                                    <cfset subscription_control = subscription_approve.get_subscription_no(
                                        company_id: session.ep.company_id,
                                        subscription_id: get_subscription_approve.SUBSCRIPTION_ID
                                    )/>
                                    <cfif subscription_control.recordcount>
                                        <cfif dateCompare(subscription_control.FINISH_DATE, get_subscription_approve.APP_APPROVED_DATE) eq -1>
                                            <i class="fa fa-times-circle-o" style="color: red;"></i>
                                        <cfelse>
                                            <i class="fa fa-check-circle-o" style="color: green;"></i>
                                        </cfif>
                                    <cfelse>
                                        <a href="#request.self#?fuseaction=project.works&event=add&work_fuse=#attributes.fuseaction#"><i class="fa fa-question-circle-o" style="color: blue;"></i></a>
                                    </cfif>
                                </td>
                                <td>#SUBSCRIPTION_NO#</td>
                                <td>#SUBSCRIPTION_HEAD#</td>
                                <td>#APP_DOMAIN#</td>
                                <td>#dateformat(APP_APPROVED_DATE,dateformat_style)#</td>
                                <td>#APP_APPROVED_NAME_SURNAME#</td>
                                <td>#RELEASE_NO#</td>
                                <td>#PATCH_NO#</td>
                            </tr>
                        </cfoutput>
                    <cfelse>
                        <tr><td colspan="9"><cf_get_lang dictionary_id='57484.Kayıt Yok'></td></tr>
                    </cfif>
                <cfelse>
                    <tr><td colspan="9"><cf_get_lang dictionary_id='57701.Filtre Ediniz'></td></tr>
                </cfif>
            </tbody>
        </cf_grid_list>
    </cf_box>
</div>