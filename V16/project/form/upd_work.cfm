<!---
Author :        Melek Kocabey<melekkocabey@workcube.com>
Date :          02.09.2019
Description :   Görevler sayfası detay içeriklerini getirir.
--->
<cf_xml_page_edit>
<cfset getComponent = createObject('component','V16.project.cfc.get_work')>
<cfset get_history_control=getComponent.GET_WORK_DETAIL(id:attributes.id)>
<cfset upd_work=getComponent.DET_WORK(
    id:attributes.id,
    xml_is_detail_filtre:xml_is_detail_filtre,
    xml_is_all_authorization:xml_is_all_authorization,
    xml_is_project_authority:xml_is_project_authority)>
<cfif upd_work.recordcount eq 0>
    <cfset hata  = 11>
    <cfsavecontent variable="message"><cf_get_lang dictionary_id='58943.Böyle Bir Kayit Bulunmamaktadır'>!</cfsavecontent>
    <cfset hata_mesaj  = message>
    <cfinclude template="../../dsp_hata.cfm">
<cfelse>
    <cfif (isdefined("xml_add_fis") and xml_add_fis eq 1 and len(upd_work.project_id))>
        <cfoutput>
            <cfquery name="GET_MATERIAL_LIST" datasource="#DSN#">
                SELECT PRO_MATERIAL_ID FROM PRO_MATERIAL WHERE WORK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.id#"> AND PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#upd_work.project_id#"> 
            </cfquery>
            <cfif GET_MATERIAL_LIST.recordcount>
                <cfquery name="get_pro_material" datasource="#dsn#">
                    SELECT 
                        PR.* 
                    FROM 
                        PRO_MATERIAL P,
                        PRO_MATERIAL_ROW PR
                    WHERE 
                        P.PRO_MATERIAL_ID = PR.PRO_MATERIAL_ID AND
                        PR.PRO_MATERIAL_ID = #GET_MATERIAL_LIST.PRO_MATERIAL_ID#
                </cfquery>
                <cfset s_amount_list = "">
                <cfif get_pro_material.recordcount>                    
                    <cfloop query="get_pro_material">
                        <cfquery name="get_sarf" datasource="#dsn2#">
                            SELECT SUM(SR.AMOUNT) AMOUNT FROM STOCK_FIS S JOIN STOCK_FIS_ROW SR ON S.FIS_ID = SR.FIS_ID WHERE S.WORK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.id#"> AND SR.STOCK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#STOCK_ID#"> 
                        </cfquery>
                        <cfif get_sarf.recordcount and len(get_sarf.amount)>
                            <cfset s_amount = amount-get_sarf.amount>
                        <cfelse>
                            <cfset s_amount = amount>
                        </cfif>
                        <cfset s_amount_list = listappend(s_amount_list,s_amount,',')>
                    </cfloop>
                </cfif>               
                <input type="hidden" name="convert_stocks_id" id="convert_stocks_id" value="#valuelist(get_pro_material.stock_id)#">
                <input type="hidden" name="convert_spect_id" id="convert_spect_id" value="#valuelist(get_pro_material.SPECT_VAR_ID)#">
                <input type="hidden" name="convert_amount_stocks_id" id="convert_amount_stocks_id" value="#s_amount_list#">
                <input type="hidden" name="convert_price" id="convert_price" value="#valuelist(get_pro_material.price)#">
                <input type="hidden" name="convert_price_other" id="convert_price_other" value="#valuelist(get_pro_material.price_other)#">
                <input type="hidden" name="convert_money" id="convert_money" value="#valuelist(get_pro_material.OTHER_MONEY)#">
                <input type="hidden" name="convert_cost_price" id="convert_cost_price" value="#valuelist(get_pro_material.COST_PRICE)#" />
                <input type="hidden" name="convert_extra_cost" id="convert_extra_cost" value="#valuelist(get_pro_material.EXTRA_COST)#" />
                <input type="hidden" name="record_num" id="record_num" value="#get_pro_material.recordcount#">
                <input type="hidden" name="form_submitted" id="form_submitted" value="">
            </cfif>
        </cfoutput>
    </cfif>
    <cf_catalystHeader>
    <cfset index=1>
    <div class="row">
        <div class="col col-8 col-xs-12 uniqueRow"><!---content sağ--->
            <cf_box id="work_detay"
                title="#getLang('project',159,'iş detayı')#"					
                closable="0"
                box_page="#request.self#?fuseaction=project.work_detail&id=#attributes.id#">
            </cf_box>
            <cf_box id="work_steps"
                    title="#getLang('contract',268,'iş adımları')#"					
                    closable="0"
                    box_page="#request.self#?fuseaction=project.workSteps&id=#attributes.id#">
            </cf_box>
            <cf_box id="workUpd"               
                    title="#getLang('main',3905,'Takip Notları')#" 
                    closable="0">	
                    <cfinclude template="upd_work_ajax.cfm">				
            </cf_box>
            
            <cf_box id="box_followup"
                title="#getLang('main',3904,'Akış')#"
                closable="0"
                box_page="#request.self#?fuseaction=project.emptypopup_updwork_ajaxhistory&id=#attributes.id#">
            </cf_box>

            <cfif upd_work.is_milestone neq 1>
                <cf_box id="box_followup5" 
                        closable="0"  
                        title="#getLang('','Üst İşler','64461')#" 
                        box_page="#request.self#?fuseaction=project.emptypopup_ajax_project_top_works&work_id=#upd_work.WORK_ID#"
                        >
                </cf_box>
            </cfif>

            <cf_box id="mission_id" 
                    closable="0"  
                    title="#getLang('project',163,'alt işler')#" 
                    box_page="#request.self#?fuseaction=project.emptypopup_ajax_project_works&xml_is_stage_cat=#xml_is_stage_cat#&xml_is_stage_work_cat=#xml_is_stage_work_cat#&xml_work_sort_type=#xml_work_sort_type#&project_id=#upd_work.project_id#&work_id=#attributes.id#&related_project_info=1&xml_change_complate_ratio=#xml_change_complate_ratio#&xml_show_work_category=#xml_show_work_category#&xml_show_actual_date=#xml_show_actual_date#&project_detail_id=#upd_work.project_id#&work_detail_id=0"
                    add_href="#request.self#?fuseaction=project.works&popup_page=1&event=add&id=#upd_work.project_id#&work_id=#attributes.id#&work_fuse=project.emptypopup_ajax_project_works">
            </cf_box>
            <cf_box id="comments"               
                    title="#getLang('settings',859,'chat')#" 
                    closable="0"
                    add_href_size="wide"
                    box_page="#request.self#?fuseaction=project.emptypopup_work_comment&id=#attributes.id#&action_section=WORK_ID">					
            </cf_box>		
        </div>        
        <div class="col col-4 col-xs-12 uniqueRow"><!--- content sol--->
            <cf_box 
                id="work_summary" 
                box_page="#request.self#?fuseaction=project.dsp_work_summary&id=#attributes.id#">
            </cf_box><!--- İş Özeti --->
            <cf_get_workcube_asset 
                asset_cat_id="-21" 
                module_id='1' 
                document_flow='1'
                action_section='WORK_ID' 
                action_id='#attributes.id#'><!--- Belgeler --->
                <cf_get_related_events company_id="#session.ep.company_id#" 
                    action_section='WORK_ID' 
                    action_id='#attributes.id#' 
                    action_project_id='#upd_work.project_id#'><!--- Ajandaya olay ekle --->
            <cfsavecontent variable="title"><cf_get_lang dictionary_id='57561.Zaman Harcamaları'></cfsavecontent>
            <cf_box
                title="#title#"
                id="box_followup2"
                closable="0"
                box_page="#request.self#?fuseaction=project.work_time_get_add&id=#attributes.id#"
                add_href="openBoxDraggable('#request.self#?fuseaction=project.popup_add_planned_actual_timecost&id=#attributes.id#&history_id=#GET_HISTORY_CONTROL.history_id#')">
            </cf_box>
            <cf_get_workcube_form_generator 
                action_type='11' 
                related_type='11' 
                action_type_id='#attributes.id#' 
                design='3' 
                work_cat_id='#upd_work.work_cat_id#'><!--- değerlendirme formları --->
            <cfif xml_bitbucket_integration eq 1>
            <style>
                .bb-type {
                    font-weight: bold;
                }
                .bb-branch {
                    color: rgb(66, 82, 110);
                    display: inline-block;
                    font-size: 12px;
                    font-weight: 500;
                    line-height: 1;
                    vertical-align: middle;
                    max-width: 180px;
                    text-overflow: ellipsis;
                    white-space: nowrap;
                    background: rgb(244, 245, 247);
                    border-radius: 3px;
                    padding: 4px 8px;
                    overflow: hidden;
                }
                .bb-title {
                    font-size: 1em;
                    line-height: 1.714;
                    font-weight: normal;
                    margin-top: 1.143rem;
                    margin-bottom: 0px;
                    letter-spacing: -0.005em;
                }
                .bb-created {
                    display: block;
                    text-overflow: ellipsis;
                    margin-top: 4px;
                    white-space: nowrap;
                    overflow: hidden;
                }
                .bb-state {
                    background-color: rgb(0, 82, 204);
                    box-sizing: border-box;
                    color: rgb(255, 255, 255);
                    font-size: 11px;
                    font-weight: 700;
                    line-height: 1;
                    text-transform: uppercase;
                    border-radius: 3px;
                    display: inline-block;
                    vertical-align: middle;
                    text-overflow: ellipsis;
                    white-space: nowrap;
                    box-sizing: border-box;
                    max-width: 200px;
                    overflow: hidden;
                    padding: 4px 4px;
                    margin-right: 6px;
                }
                .bb-avatar {
                    width: 32px;
                    height: 32px;
                    border-radius: 50%;
                    display: inline-block;
                }
                .bb-avatars {
                    margin: 6px 0;
                }
                .bb-author-avatar {
                    margin: 0 20px;
                }
                .bb-reviewer {
                    display: inline-block;
                    position: relative;
                }
                .bb-reviewer i {
                    color: white;
                    background-color: blue;
                    font-size: 12px;
                    width: 12px;
                    position: absolute;
                    top: 0;
                    left: 20px;
                    border-radius: 50%;
                }
            </style>
            <cf_box
                title="Bitbucket"
                id="box_bitbucket"
                closable="0"
                unload_body="0">
                <cfobject name="bbdata" type="component" component="WEX.bitbucket.components.data">
                <cfset qbitbucket_hooks = bbdata.listbytask(attributes.id)>
                <cfoutput>
                <cfloop query="qbitbucket_hooks">
                <cfif PROC_TYPE eq "pullrequest">
                    <div>
                        <span class="bb-type">#uCase(qbitbucket_hooks.PROC_TYPE)#</span> - <span class="bb-id">BBID:#qbitbucket_hooks.BBID#</span> - <span class="bb-branch">#qbitbucket_hooks.SOURCE_BRANCH#</span> <i class="fa fa-arrow-right"></i> <span class="bb-branch">#qbitbucket_hooks.DESTINATION_BRANCH#</span> <span class="bb-state">#qbitbucket_hooks.STATE#</span>
                        <cfif qbitbucket_hooks.STATE eq 'MERGED'>
                            <cfif len(qbitbucket_hooks.NOTE_ROW_ID)><i class="fa fa-book fa-1-3x text-success" title="<cf_get_lang dictionary_id = '61189.Release Notu'>" style="position: relative;top: 2px;" onclick="openBoxDraggable('#request.self#?fuseaction=objects.release_notes_row&fuseact=#upd_work.WORK_CIRCUIT#.#upd_work.WORK_FUSEACTION#&note_row_id=#qbitbucket_hooks.NOTE_ROW_ID#','','ui-draggable-box-large')"></i>
                            <cfelse><i class="fa fa-book fa-1-3x text-danger" title="<cf_get_lang dictionary_id = '61189.Release Notu'>" style="position: relative;top: 2px;" onclick="openBoxDraggable('#request.self#?fuseaction=objects.release_notes_row&fuseact=#upd_work.WORK_CIRCUIT#.#upd_work.WORK_FUSEACTION#&task_id=#attributes.id#&hook_id=#qbitbucket_hooks.HOOKID#','','ui-draggable-box-large')"></i></cfif>
                        </cfif>
                        <span class="bb-created"><small>#dateFormat(qbitbucket_hooks.CREATED, dateFormat_style)# #timeFormat(qbitbucket_hooks.CREATED, "HH:mm")#</small></span>
                    </div>
                    <div><h3 class="bb-title">#CharsetEncode(ToBinary(ToBase64(qbitbucket_hooks.TITLE, 'windows-1252')), 'utf-8')# <a href="#qbitbucket_hooks.VIEW_URL#" target="_blank"><i class="fa fa-external-link-square"></i></a></h3></div>
                    <div class="bb-avatars">
                        <cfset author_data_struct = deserializeJSON(qbitbucket_hooks.AUTHOR_DATA)>
                        <img src="#author_data_struct.links.avatar.href#" class="bb-avatar" alt="#CharsetEncode(ToBinary(ToBase64(qbitbucket_hooks.AUTHOR, 'windows-1252')), 'utf-8')#" title="#CharsetEncode(ToBinary(ToBase64(qbitbucket_hooks.AUTHOR, 'windows-1252')), 'utf-8')#">
                        <cfif len(qbitbucket_hooks.PARTICIPANTS)>
                        <cfset participants_list = deserializeJSON(qbitbucket_hooks.PARTICIPANTS)>
                        <i class="fa fa-angle-double-right bb-author-avatar"></i>
                        <cfloop array="#participants_list#" index="participant">
                            <span class="bb-reviewer">
                            <img src="#participant.user.links.avatar.href#" class="bb-avatar" alt="#CharsetEncode(ToBinary(ToBase64(participant.user.display_name, 'windows-1252')), 'utf-8')#" title="#CharsetEncode(ToBinary(ToBase64(participant.user.display_name, 'windows-1252')), 'utf-8')#">
                            <cfif isDefined("participant.approved") and participant.approved eq 1>
                                <i class="fa fa-check-circle-o"></i>
                            </cfif>
                            </span>
                        </cfloop>
                        </cfif>
                    </div>
                </cfif>
                <hr style="border: 0; border-bottom: 1px solid ##DDD;">
                </cfloop>
                </cfoutput>
                <cfset get_release_note_row = createObject('component','V16.objects.cfc.release_note_row').select(task_id:attributes.id) />
                <cfif get_release_note_row.recordcount>
                    <cf_seperator id="release_notes" header="#getLang('','',43887)#">
                    <div id="release_notes">
                        <cfoutput query = "get_release_note_row">
                            <div>
                                 <a href="javascript://" onclick="openBoxDraggable('#request.self#?fuseaction=objects.release_notes_row&fuseact=#upd_work.WORK_CIRCUIT#.#upd_work.WORK_FUSEACTION#&event=upd&note_row_id=#NOTE_ROW_ID#','','ui-draggable-box-large')"><h3>#NOTE_ROW_TITLE#</h3></a>
                                <p>#RELEASE_NO# # len(PATCH_NO) ? ' - ' & PATCH_NO : ''#</p>
                            </div>
                        </cfoutput>
                    </div>
                </cfif>
            </cf_box>
            </cfif>
            <cfif xml_show_mockup><cf_box title="#getLang('Mockups','',63102)#" widget_load = "work_mockups" widget_parameters="work_id=#attributes.id#" add_href="#request.self#?fuseaction=dev.mockup&event=add&work_id=#attributes.id#&from_work=1"></cf_box></cfif>
            <cfsavecontent variable="title"><cf_get_lang dictionary_id='60817.İlişkili İşlemler'></cfsavecontent>
            <cf_box 
                title="#title#"
                id="box_followup3"
                closable="0"
                unload_body = "1"
                >
                <div class="col col-12">
                    <cfif len(upd_work.opportunity_id) and len(upd_work.our_company_id)>
                        <cfset service_dsn = '#dsn#_#upd_work.our_company_id#'>
                        <cfquery name="GET_OPP" datasource="#service_dsn#">
                            SELECT OPP_HEAD FROM OPPORTUNITIES WHERE OPP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#upd_work.opportunity_id#">
                        </cfquery>
                        <div class="form-group">
                            <label class="col col-12 bold"><cf_get_lang dictionary_id ='38161.Iliskili Firsat'> :</label>
                            <cfif session.ep.company_id eq upd_work.our_company_id> 
                                <cfoutput><label class="col col-12"><a href="#request.self#?fuseaction=sales.list_opportunity&event=det&opp_id=#upd_work.opportunity_id#" target="_blank" class="tableyazi">#get_opp.OPP_HEAD#</a></label></cfoutput>
                            <cfelse>
                                <cfoutput><label class="col col-12">#get_opp.opp_head#</label></cfoutput>
                            </cfif>
                        </div>
                    </cfif>
                    <cfif len(upd_work.service_id) and len(upd_work.our_company_id)>
                        <cfset service_dsn = '#dsn#_#upd_work.our_company_id#'>
                        <cfquery name="GET_SERVICE" datasource="#service_dsn#">
                            SELECT SERVICE_HEAD FROM SERVICE WHERE SERVICE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#upd_work.service_id#">
                        </cfquery>
                        <div class="form-group">
                            <label class="col col-4 col-xs-12 bold"><cf_get_lang dictionary_id ='38178.Iliskili Servis'> :</label>
                            <cfif session.ep.company_id eq upd_work.our_company_id>
                                <cfoutput><label class="col col-12"><a href="#request.self#?fuseaction=service.list_service&event=upd&service_id=#upd_work.service_id#" target="_blank" class="tableyazi">#get_service.SERVICE_HEAD#</a></label></cfoutput>
                            <cfelse>
                                <cfoutput><label class="col col-12">#get_service.service_head#</label></cfoutput>
                            </cfif>
                        </div>
                    </cfif>
                    <cfif len(upd_work.g_service_id)>
                        <cfquery name="GET_SERVICE" datasource="#DSN#">
                            SELECT SERVICE_HEAD FROM G_SERVICE WHERE SERVICE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#upd_work.g_service_id#">
                        </cfquery>
                        <div class="form-group">
                            <label class="col col-12 bold"><cf_get_lang dictionary_id ='38217.Iliskili Call Center'> :</label>
                            <cfoutput><label class="col col-12"><a href="#request.self#?fuseaction=call.list_service&event=upd&service_id=#upd_work.g_service_id#" target="_blank" class="tableyazi">#get_service.SERVICE_HEAD#</a></label></cfoutput>
                        </div>
                    </cfif>
                    <cfif len(upd_work.cus_help_id)>
                        <cfquery name="GET_CUSTOMER_HELP" datasource="#DSN#">
                            SELECT CUS_HELP_ID FROM CUSTOMER_HELP WHERE CUS_HELP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#upd_work.cus_help_id#">
                        </cfquery>
                        <div class="form-group">
                            <label class="col col-12 bold"><cf_get_lang dictionary_id ='38462.Iliskili Etkilesimler'> :</label>
                            <cfoutput><label class="col col-12"><a href="#request.self#?fuseaction=call.helpdesk&event=upd&cus_help_id=#upd_work.cus_help_id#" target="_blank" class="tableyazi">#get_customer_help.CUS_HELP_ID#</a></label></cfoutput>
                        </div>
                    </cfif>
                    <cfif len(upd_work.sale_contract_id) or len(upd_work.purchase_contract_id)>
                        <div class="form-group">
                            <label class="col col-12 bold">İlişkili Sözleşme :</label>
                            <cfif len(upd_work.sale_contract_id)>
                                <cfquery name="get_sale_contract" datasource="#dsn3#">
                                    SELECT CONTRACT_NO FROM RELATED_CONTRACT WHERE CONTRACT_ID = #upd_work.sale_contract_id#
                                </cfquery>
                                <cfoutput><label class="col col-12"><cf_get_lang dictionary_id='57448.Satış'> :<a href="javascript://" onclick="windowopen('#request.self#?fuseaction=contract.popup_upd_contract&contract_id=#upd_work.sale_contract_id#','wide2');" class="tableyazi">#get_sale_contract.CONTRACT_NO#</a></label></cfoutput>
                            </cfif>
                            <cfif len(upd_work.purchase_contract_id)>
                                <cfquery name="get_purchase_contract" datasource="#dsn3#">
                                    SELECT CONTRACT_NO FROM RELATED_CONTRACT WHERE CONTRACT_ID = #upd_work.purchase_contract_id#
                                </cfquery>
                                <cfoutput><label class="col col-12"><cf_get_lang dictionary_id='58176.Alış'> :<a href="javascript://" onclick="windowopen('#request.self#?fuseaction=contract.popup_upd_contract&contract_id=#upd_work.purchase_contract_id#','wide2');" class="tableyazi">#get_purchase_contract.CONTRACT_NO#</a></label></cfoutput>
                            </cfif>
                        </div>
                    </cfif>
                    <cfif session.ep.our_company_info.workcube_sector is 'tersane'>
                        <cfquery name="get_dpl_row" datasource="#dsn3#">
                            SELECT
                                DP.DPL_ID,
                                DPR.PRODUCT_ID,
                                P.PRODUCT_NAME
                            FROM
                                DRAWING_PART DP,
                                DRAWING_PART_ROW DPR,
                                PRODUCT P
                            WHERE
                                P.PRODUCT_ID = DPR.PRODUCT_ID AND
                                DP.DPL_ID = DPR.DPL_ID AND
                                DPR.WORK_ID = #upd_work.work_id#
                            ORDER BY
                                DPR.DPL_ROW_ID
                        </cfquery>
                        <cfif get_dpl_row.recordcount>
                            <div class="form-group">
                                <label class="col col-12 bold"><cf_get_lang dictionary_id='36523.Malzeme Ihtiyaç Listesi'> :</label>
                                <cfoutput query="get_dpl_row">
                                    <label class="col col-12"><a href="#request.self#?fuseaction=product.list_product&event=det&pid=#product_id#" target="_blank" class="tableyazi">#product_name#</a><label>
                                </cfoutput>
                            </div> 
                        </cfif>
                    </cfif>
					<cfquery name="get_orders" datasource="#dsn3#">
						SELECT ORDER_ID,ORDER_NUMBER FROM ORDERS WHERE WORK_ID = #attributes.id#
					</cfquery>
					<cfif get_orders.recordcount>
						<div class="form-group">
							<label class="col col-12 bold"><cf_get_lang dictionary_id='32837.İlişkili Siparişler'> :</label>
							<cfoutput query="get_orders">
								<label class="col col-12"><a href="#request.self#?fuseaction=sales.list_order&event=det&order_id=#order_id#" class="tableyazi" target="_blank">#order_number#</a></label>
							</cfoutput>
						</div>
					</cfif>
                    <cfquery name="get_production_orders" datasource="#dsn3#">
                        SELECT P_ORDER_ID,P_ORDER_NO FROM PRODUCTION_ORDERS WHERE WORK_ID = #attributes.id#
                    </cfquery>
                    <cfif get_production_orders.recordcount>
                        <div class="form-group">
                            <label class="col col-12 bold"><cf_get_lang dictionary_id='36652.İlişkili Üretim Emirleri'> :</label>
                            <cfoutput query="get_production_orders">
                                <label class="col col-12"><a href="#request.self#?fuseaction=prod.order&event=upd&upd=#p_order_id#" class="tableyazi" target="_blank">#p_order_no#</a></label>
                            </cfoutput>
                        </div>
                    </cfif>
                    <cfquery name="get_agenda" datasource="#dsn#">
                        SELECT EVENT_ID,EVENT_HEAD FROM EVENT WHERE WORK_ID = #attributes.id#
                    </cfquery>
                    <cfif get_agenda.recordcount>
                        <div class="form-group">
                            <label class="col col-12 bold"><cf_get_lang dictionary_id="57993.İlişkili Olaylar"> :</label>
                            <cfoutput query="get_agenda">
                                <label class="col col-12"><a href="#request.self#?fuseaction=agenda.view_daily&event=upd&event_id=#event_id#" class="tableyazi" target="_blank">#EVENT_HEAD#</a></label>
                            </cfoutput>
                        </div>
                    </cfif>
                </div>
                <cfquery name="OFFER" datasource="#dsn3#">
                    SELECT OFFER_ID,OFFER_NUMBER,OFFER_HEAD FROM OFFER WHERE PURCHASE_SALES= 1 AND WORK_ID =#attributes.id#
                </cfquery>
                <cfquery name="OFFERA" datasource="#dsn3#">
                    SELECT OFFER_ID,OFFER_NUMBER,OFFER_HEAD FROM OFFER WHERE PURCHASE_SALES= 0 AND WORK_ID =#attributes.id#
                </cfquery>
                <cfquery name="get_stock_fis" datasource="#dsn2#">
                    SELECT WORK_ID,FIS_ID,FIS_NUMBER FROM STOCK_FIS WHERE WORK_ID = #attributes.id#
                </cfquery>
                <cfif OFFER.recordcount or OFFERA.recordcount or (fusebox.use_period and get_stock_fis.recordcount)>
                    <div class="col col-12">
                        <cfif OFFER.recordcount>
                            <div class="form-group">
                                <label class="col col-12 bold"><cf_get_lang dictionary_id='60621.İlişkili Satış Teklifi'> :</label>
                                <cfoutput query="offer">
                                    <label class="col col-12"><a href="#request.self#?fuseaction=sales.list_offer&event=upd&offer_id=#offer.offer_id#" class="tableyazi" target="_blank">#OFFER_NUMBER# - #OFFER_HEAD#</a></label>
                                </cfoutput>
                            </div>
                        </cfif>
                        <cfif OFFERA.recordcount>
                            <div class="form-group">
                                <label class="col col-12 bold"><cf_get_lang dictionary_id='60622.İlişkili Alış Teklifi'> :</label>
                                <cfoutput query="offera">
                                    <label class="col col-12"><a href="#request.self#?fuseaction=purchase.list_offer&event=upd&offer_id=#offera.offer_id#" class="tableyazi" target="_blank">#OFFER_NUMBER# - #OFFER_HEAD#</a></label>
                                </cfoutput>
                            </div>
                        </cfif>
                        <cfif fusebox.use_period>
                            <cfif get_stock_fis.recordcount>
                                <div class="form-group">
                                    <label class="col col-12 bold"><cf_get_lang dictionary_id='60623.İlişkili Sarf Fişleri'> :</label>
                                    <cfoutput query="get_stock_fis">
                                        <label class="col col-12"><a href="#request.self#?fuseaction=stock.form_add_fis&event=upd&upd_id=#get_stock_fis.fis_id#" class="tableyazi" target="_blank">#FIS_NUMBER#</a></label>
                                    </cfoutput>
                                </div>
                            </cfif>
                        </cfif>
                    </div>
                </cfif>
            </cf_box>
            <!--- Mindmap --->
            <cfset action_section = "WORK">
            <cf_box id="mindmap_id" closable="0" title="Mindmap Designer" style="box-shadow:none;" widget_load="mindmap&project_id=#attributes.id#&type=#attributes.fuseaction#" add_href="#request.self#?fuseaction=project.mindmap&event=add&prj_id=#attributes.id#&type=#attributes.fuseaction#"></cf_box>
            <!--- İş Akış Tasarımcısı --->
            <cfset relative_id = attributes.id>
            <cfinclude template="../../process/display/list_designer.cfm"> 
        </div>                    
    </div>
</cfif>
