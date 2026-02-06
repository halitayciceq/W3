<cfif isdefined('attributes.visit_id')>
    <cfquery name="GET_ROW" datasource="#DSN#">
        SELECT 
        	ASSET_ID,
            COMPANY_ID,
            EVENT_PLAN_ROW_ID,
            CONSUMER_ID,
            PROJECT_ID,
            PARTNER_ID,
            START_DATE,
            FINISH_DATE,
            WARNING_ID,
            EVENT_PLAN_ID,
            RESULT_UPDATE_EMP,
            RESULT_RECORD_EMP,
            (SELECT FULLNAME FROM COMPANY WHERE EVENT_PLAN_ROW.COMPANY_ID=COMPANY.COMPANY_ID) AS COMPANY_NAME,
            (SELECT COMPANY_PARTNER_NAME+' '+COMPANY_PARTNER_SURNAME FROM COMPANY_PARTNER WHERE EVENT_PLAN_ROW.COMPANY_ID=COMPANY_PARTNER.COMPANY_ID AND EVENT_PLAN_ROW.PARTNER_ID=COMPANY_PARTNER.PARTNER_ID)  AS PARTNER_NAME, 
            (SELECT EVENTCAT FROM  EVENT_CAT WHERE EVENT_CAT.EVENTCAT_ID=EVENT_PLAN_ROW.WARNING_ID) AS WARNING_NAME
        FROM 
            EVENT_PLAN_ROW 
        WHERE 
            EVENT_PLAN_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.visit_id#">  
        ORDER BY 
			<cfif x_listing_type eq 1>
                COMPANY_NAME
            <cfelseif x_listing_type eq 2>
                PARTNER_NAME
            <cfelseif x_listing_type eq 3>
                START_DATE
            <cfelseif x_listing_type eq 4>
                WARNING_NAME
            <cfelseif x_listing_type eq 5>
                NAME_SURNAME
            </cfif>  
    </cfquery>
	<cfset row_count = get_row.recordcount>
</cfif>
<cf_grid_list>
    <thead>
        <tr>
            <cfoutput>
                <th width="20"></th>
                <th width="200">
                    <input type="hidden" value="1" name="row_kontrol" id="row_kontrol">
                    <input type="hidden" name="company_id" id="company_id" value="">
                    <input name="company_name" id="company_name" type="text" value="" autocomplete="off" placeholder="#getLang('','Kurumsal Hesap','61845')# #getLang('','Seçiniz','57734')#">
                </th>
                <th width="200">
                    <div class="form-group">
                        <div class="input-group">
                            <input type="hidden" name="partner_id" id="partner_id" onchange="order_copy('partner_id');" value="" autocomplete="off">
                            <input type="text" name="partner_name" id="partner_name" style="width:120px;" placeholder="#getLang('','Kontak Kişiler','31385')#"  value="" onfocus="order_copy('partner_name');">
                            <span class="input-group-addon icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_pars&field_id=add_event.partner_id&field_comp_name=add_event.company_name&field_name=add_event.partner_name&field_comp_id=add_event.company_id&select_list=7,8');"></span>
                        </div>
                    </div>
                </th>
                <th width="200">
                    <div class="form-group">
                        <div class="input-group">
                            <input type="text" name="start_date" id="start_date" maxlength="10" style="width:60px;" placeholder="#getLang('','Tarih Giriniz','61893')#" value="" onblur="order_copy('start_date');">
                            <span class="input-group-addon"><cf_wrk_date_image date_field="start_date" call_function="call_order_copy"></span>
                        </div>
                    </div>
                </th>
                <th width="200">
                    <div class="form-group">
                        <div class="col col-6">
                            <cf_wrkTimeFormat name="start_clock" id="start_clock" style="width:50px;" onchange="order_copy('start_clock');" value="9">	
                        </div>
                        <div class="col col-6">
                            <select name="start_minute" id="start_minute" style="width:50px;" onchange="order_copy('start_minute');">
                                <cfloop from="0" to="55" step="5" index="smm">
                                    <option value="#NumberFormat(smm,00)#">#NumberFormat(smm,00)#</option>
                                </cfloop>
                            </select>
                        </div>
                    </div>
                </th>
                <th width="200">
                    <div class="form-group">
                        <div class="col col-6">
                            <cf_wrkTimeFormat name="finish_clock" id="finish_clock" style="width:50px;" onchange="order_copy('finish_clock');" value="17">	
                        </div>
                        <div class="col col-6">
                            <select name="finish_minute" id="finish_minute" style="width:50px;" onchange="order_copy('finish_minute');">
                                <cfloop from="0" to="55" step="5" index="fmm">
                                    <option value="#NumberFormat(fmm,00)#" <cfif fmm eq 30>selected</cfif>>#NumberFormat(fmm,00)#</option>
                                </cfloop>
                            </select>
                        </div>
                    </div>
                </th>
                <th width="200">
                    <div class="form-group">
                        <select name="warning_id" id="warning_id" style="width:150px;"  onchange="order_copy('warning_id');">
                            <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                            <cfloop query="get_visit_types">
                                <option value="#visit_type_id#">#visit_type#</option>
                            </cfloop>
                        </select>
                    </div>
                </th>
                <th width="200">
                    <div class="form-group">
                        <div class="input-group">
                            <input type="hidden" name="pos_emp_id" id="pos_emp_id" value="#session.ep.position_code#">
                            <input name="pos_emp_name" id="pos_emp_name" placeholder="#getLang('','Tarih Giriniz','41034')#" type="text" style="width:150px;" readonly="readonly" onFocus="order_copy('pos_emp_name');" value="" autocomplete="off">
                            <span class="input-group-addon icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_multi_pars&field_id=add_event.pos_emp_id&field_name=add_event.pos_emp_name&select_list=1&is_upd=1');"></span>
                        </div>
                    </div>
                </th>
                <cfif is_choose_project eq 1>
                    <th width="200">
                        <div class="form-group">
                            <div class="input-group">
                                <input type="hidden" name="relation_asset_id" id="relation_asset_id" value="">
                                <input type="text" name="relation_asset" id="relation_asset" readonly="readonly" value="" style="width:140px"  onFocus="order_copy('relation_asset')">
                                <span class="input-group-addon icon-ellipsis" onClick="windowopen('#request.self#?fuseaction=assetcare.popup_list_assetps&field_id=add_event.relation_asset_id&field_name=add_event.relation_asset&event_id=0&only_physical_asset=1&motorized_vehicle=0','list');"></span>
                            </div>
                        </div>
                    </th>
                    <th width="200">
                        <div class="form-group">
                            <div class="input-group">
                                <input type="hidden" name="project_id" id="project_id"  value="">
                                <input type="text" name="project_head" id="project_head" style="width:140px;" value=""  onchange="order_copy('project_head')">
                                <span class="input-group-addon icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_projects&project_head=add_event.project_head&project_id=add_event.project_id');"></span>
                            </div>
                        </div>
                    </th>
                </cfif>
                <th width="20"></th>
            </cfoutput>
        </tr> 
        <tr>
            <th width="20"><input name="record_num" id="record_num" type="hidden" value="<cfoutput><cfif isdefined('get_row')>#row_count#<cfelseif isdefined("attributes.totalrecord")>#attributes.totalrecord#<cfelse>0</cfif></cfoutput>"><a href="javascript://" onClick="pencere_ac_company();"><i class="fa fa-plus" title="<cf_get_lang dictionary_id='57582.Ekle'>" alt="<cf_get_lang dictionary_id='57582.Ekle'>"></i></a></th>
            <th width="200" colspan="2" ><cf_get_lang dictionary_id='41033.Ziyaret Edilecek'></th>
            <th width="200"><cf_get_lang dictionary_id='57742.Tarih'>*</th>
            <th width="200"><cf_get_lang dictionary_id ='41221.Başlama Saati'>*</th>
            <th width="200"><cf_get_lang dictionary_id ='41222.Bitiş Saati'>*</th>
            <th width="200"><cf_get_lang dictionary_id='41035.Ziyaret Nedeni'>*</th>
            <th width="200"><cf_get_lang dictionary_id='41034.Ziyaret Edecekler'></th>
            <cfif is_choose_project eq 1>
                <th width="200"><cf_get_lang dictionary_id='30004.Fiziki Varlıklar'></th>
                <th width="200"><cf_get_lang dictionary_id='57416.Proje'></th>
            </cfif>
            <th width="20"></th>
        </tr>
    </thead>
    <tbody id="table1">
        <cfif isdefined('get_row')>
            <cfoutput query="get_row">
                <input type="hidden" name="event_row_ids#currentrow#" id="event_row_ids#currentrow#" value="#event_plan_row_id#">
                <input type="hidden" name="event_plan_row_id" id="event_plan_row_id" value="#event_plan_row_id#">
                <!--- Belirlenen Saatten Sonra Islemin Silinememesi Ile Ilgili Xml Kontrolu --->
                <cfif ListLen(x_row_del_hour,':') eq 2>
                    <cfset now_hour_ = DateAdd('h',session.ep.time_zone,now())>
                    <cfset date_ = "#DateFormat(get_row.start_date,'mm-dd-yyyy')# #x_row_del_hour#">
                    <cfset modify_hour_ = CreateOdbcDateTime(date_)>
                    <cfset diff_hour_ = DateDiff("n",now_hour_,modify_hour_)>
                <cfelse>
                    <cfset diff_hour_ = 0>
                </cfif>
                <!--- Belirlenen Saatten Sonra Sonucun Girilememesi Ile Ilgili Xml Kontrolu --->
                <cfif ListLen(x_row_result_hour,':') eq 2>
                    <cfset now_hour_2 = DateAdd('h',session.ep.time_zone,now())>
                    <cfset date_2 = "#DateFormat(get_row.start_date,'mm-dd-yyyy')# #x_row_result_hour#">
                    <cfset modify_hour_2 = CreateOdbcDateTime(date_2)>
                    <cfset diff_hour_2 = DateDiff("n",now_hour_2,modify_hour_2)>
                <cfelse>
                    <cfset diff_hour_2 = 0>
                </cfif>
                <!--- Sonucu Xmlde Belirlenen Yetkililer Girmek Istiyorsa Kontrol Olmayacak --->
                <cfif ListLen(x_row_result_authority_emp)>
                    <cfset authority_emp_ = x_row_result_authority_emp>
                <cfelse>
                    <cfset authority_emp_ = 0>
                </cfif>
                <cfif x_row_result_date_today eq 1>
                    <cfset now_hour_3 = DateFormat(DateAdd('h',session.ep.time_zone,now()),dateformat_style)>
                    <cfset now_hour_3 = CreateOdbcDateTime(now_hour_3)>
                    <cfset date_3 = DateFormat(get_row.start_date,dateformat_style)>
                    <cfset date_3 = CreateOdbcDateTime(date_3)>
                    <cfset diff_hour_3 = DateDiff("n",now_hour_3,date_3)>
                <cfelse>
                    <cfset diff_hour_3 = 1>
                </cfif>
                <tr id="frm_row#currentrow#">
                    <td>
                        <a style="cursor:pointer" onClick="if('#diff_hour_#' < 0) {alert('#x_row_del_hour# \' den Sonra Kaydı Silemezsiniz!'); return false;} else {sil('#currentrow#');}"><i class="fa fa-minus" title="<cf_get_lang dictionary_id='57463.Sil'>" alt="<cf_get_lang dictionary_id='57463.Sil'>"></i></a>
                    </td>
                    <td>
                        <input type="hidden" name="row_kontrol#currentrow#" id="row_kontrol#currentrow#" value="1">
                        <input type="hidden" name="company_id#currentrow#" id="company_id#currentrow#" value="#get_row.company_id#">
                        <input type="text" name="company_name#currentrow#" id="company_name#currentrow#" value="#get_par_info(get_row.company_id,1,0,0)#" readonly>
                    </td>
                    <td>
                        <div class="form-group">
                            <div class="input-group">
                                <input type="hidden" name="consumer_id#currentrow#" id="consumer_id#currentrow#" value="#get_row.consumer_id#">
                                <input type="hidden" name="partner_id#currentrow#"  id="partner_id#currentrow#" value="#get_row.partner_id#">
                                <input type="text" name="partner_name#currentrow#" id="partner_name#currentrow#" value="<cfif len(get_row.partner_id)>#get_par_info(get_row.partner_id,0,-1,0)#<cfelse>#get_cons_info(get_row.consumer_id,0,0)#</cfif>" readonly style="width:120px;">
                                <span class="input-group-addon icon-ellipsis" onClick="pencere_ac('#currentrow#');"></span>
                            </div>
                        </div>
                        
                    </td>
                    <td>
                        <input type="text" name="start_date#currentrow#" id="start_date#currentrow#" value="#dateformat(get_row.start_date,dateformat_style)#" <cfif diff_hour_3 lt 0>readonly</cfif>>
                        <cf_wrk_date_image date_field="start_date#currentrow#">
                    </td>
                    <td><select name="start_clock#currentrow#" id="start_clock#currentrow#">
                            <option value="0"><cf_get_lang dictionary_id='57491.Saat'></option>
                            <cfif len(get_row.start_date)><cfset start_hour = hour(get_row.start_date)><cfelse><cfset start_hour = 0></cfif>
                            <cfloop from="7" to="30" index="i">
                                <cfset saat=i mod 24>
                                <option value="#saat#" <cfif start_hour eq saat>selected</cfif>>#saat#</option>
                            </cfloop>
                        </select>
                        <cfif len(get_row.start_date)><cfset start_minute = minute(get_row.start_date)><cfelse><cfset start_minute = 0></cfif>
                        <select name="start_minute#currentrow#" id="start_minute#currentrow#">
                            <cfloop from="0" to="55" step="5" index="smc">
                                <option value="#NumberFormat(smc,00)#" <cfif smc eq start_minute>selected</cfif>>#NumberFormat(smc,00)#</option>
                            </cfloop>
                        </select>
                    </td>
                    <td>
                        <select name="finish_clock#currentrow#" id="finish_clock#currentrow#">
                            <option value="0"><cf_get_lang dictionary_id='57491.Saat'></option>
                            <cfif len(get_row.finish_date)><cfset finish_hour = hour(get_row.finish_date)><cfelse><cfset finish_hour = 0></cfif>
                                <cfloop from="7" to="30" index="i">
                                    <cfset saat=i mod 24>
                                    <option value="#saat#" <cfif finish_hour eq saat>selected</cfif>>#saat#</option>
                                </cfloop>
                            </select>
                        <cfif len(get_row.finish_date)><cfset finish_minute = minute(get_row.finish_date)><cfelse><cfset finish_minute = 0></cfif>
                        <select name="finish_minute#currentrow#" id="finish_minute#currentrow#">
                            <cfloop from="0" to="55" step="5" index="fmc">
                                <option value="#NumberFormat(fmc,00)#" <cfif fmc eq finish_minute>selected</cfif>>#NumberFormat(fmc,00)#</option>
                            </cfloop>
                        </select>
                    </td>
                    <td><cfset form_warning_id = get_row.warning_id>
                        <select name="warning_id#currentrow#" id="warning_id#currentrow#">
                            <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                            <cfloop query="get_visit_types">
                                <option value="#visit_type_id#" <cfif form_warning_id eq visit_type_id>selected</cfif>>#visit_type#</option>
                            </cfloop>
                        </select>
                    </td>
                    <td><cfquery name="get_row_pos" datasource="#dsn#">
                            SELECT
                                EPP.EVENT_POS_ID,
                                EP.EMPLOYEE_NAME + ' ' + EP.EMPLOYEE_SURNAME NAME_SURNAME
                            FROM
                                EVENT_PLAN_ROW_PARTICIPATION_POS EPP,
                                EMPLOYEE_POSITIONS EP
                            WHERE
                                EP.IS_MASTER = 1 AND
                                EPP.EVENT_POS_ID = EP.POSITION_CODE AND
                                EPP.EVENT_ROW_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#event_plan_row_id#">
                        </cfquery>
                        <input type="hidden" name="pos_emp_id#currentrow#" id="pos_emp_id#currentrow#" value="#ListSort(ListDeleteDuplicates(Valuelist(get_row_pos.event_pos_id,',')),'numeric','asc',',')#"><!--- <cfloop query="get_row_pos">,#event_pos_id#</cfloop> --->
                        <input type="text" name="pos_emp_name#currentrow#" id="pos_emp_name#currentrow#" value="#ListSort(ListDeleteDuplicates(Valuelist(get_row_pos.name_surname,',')),'text','asc',',')#" readonly>
                        <a href="javascript://" onClick="temizlerim('#currentrow#');pencere_ac_pos('#currentrow#');"><img src="/images/plus_thin.gif" border="0" align="absbottom"></a>
                    </td>
                    <cfif is_choose_project eq 1>
                        <td>
                            <cfif len(asset_id)>
                                <cfquery name="get_asset_row" datasource="#dsn#">
                                    SELECT ASSET_P.ASSETP FROM ASSET_P WHERE ASSETP_ID=#asset_id#
                                </cfquery>
                            </cfif>
                            <input type="hidden" name="relation_asset_id#currentrow#" id="relation_asset_id#currentrow#" value="<cfif len(asset_id)>#asset_id#</cfif>">
                            <input type="text" name="relation_asset#currentrow#" id="relation_asset#currentrow#" readonly="readonly" value="<cfif isdefined("get_asset_row.ASSETP")>#get_asset_row.assetp#</cfif>">
                            <a href="javascript://" onClick="windowopen('#request.self#?fuseaction=assetcare.popup_list_assetps&field_id=add_event.relation_asset_id#currentrow#&field_name=add_event.relation_asset#currentrow#&event_id=0&only_physical_asset=1&motorized_vehicle=0','list');"><img src="/images/plus_thin.gif" align="absmiddle" border="0"></a>
                        </td>
                    </cfif>
                    <td>
                        <cfif len(project_id)>
                            <cfquery name="get_project" datasource="#dsn#">
                                SELECT PROJECT_ID,PROJECT_HEAD FROM PRO_PROJECTS WHERE PROJECT_ID=<cfqueryparam cfsqltype="cf_sql_integer" value="#project_id#">
                            </cfquery>
                        </cfif>
                        <input type="hidden" name="project_id#currentrow#" id="project_id#currentrow#" value="<cfif len(project_id) and  isdefined("get_project.project_id") and  len(get_project.project_id)>#get_project.project_id#</cfif>">
                        <input type="text" name="project_head#currentrow#" id="project_head#currentrow#" style="width:140px;" readonly="readonly" value="<cfif len(project_id) and isdefined("get_project.project_head") and len(get_project.project_head)>#get_project.project_head#</cfif>">
                        <a href="javascript://" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_projects&project_head=add_event.project_head#currentrow#&project_id=add_event.project_id#currentrow#');"><img src="/images/plus_thin.gif" style="vertical-align:bottom" alt="<cf_get_lang dictionary_id ='58797.Proje Seçiniz'>" title="<cf_get_lang dictionary_id ='58797.Proje Seçiniz'>" align="absbottom" border="0"></a>
                    </td>
                    <td width="19">
                        <cfif not len(event_plan_id)><!--- crm --->
                            <a href="javascript://" onClick="if('#diff_hour_2#' < 0 && '#ListFind(authority_emp_,session.ep.userid)#' == 0) {alert('#x_row_result_hour# \' den Sonra Sonuç Giremezsiniz!'); return false;} else {windowopen('#request.self#?fuseaction=crm.popup_form_upd_visit&eventid=#event_plan_id#&event_plan_row_id=#event_plan_row_id#&partner_id=#partner_id#&result_id=#get_kontrol.result_id#' ,'medium');}"><img src="/images/time.gif" border="0" title="<cf_get_lang dictionary_id ='58437.Ziyaret Sonucu'>" alt="absbottom"></a>
                        <cfelse>
                            <cfif isdefined(get_event_plan.analyse_id) and len(get_event_plan.analyse_id)>
                                <cfquery name="get_analyse_member" datasource="#dsn#">
                                    SELECT
                                        MAR.RESULT_ID,
                                        MA.ANALYSIS_ID,
                                        MA.ANALYSIS_HEAD
                                    FROM
                                        MEMBER_ANALYSIS MA,
                                        MEMBER_ANALYSIS_RESULTS MAR
                                    WHERE
                                        MA.ANALYSIS_ID = MAR.ANALYSIS_ID AND
                                        MA.ANALYSIS_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_event_plan.analyse_id#"> AND
                                        <cfif Len(company_id)>
                                            MAR.COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#company_id#"> AND
                                            MAR.PARTNER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#partner_id#">
                                        <cfelseif Len(consumer_id)>
                                            MAR.CONSUMER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#consumer_id#">
                                        </cfif>
                                </cfquery>
                                <cfset analyse_id_ = get_event_plan.analyse_id>
                                <cfset result_id_ = get_analyse_member.result_id>
                            <cfelse>
                                <cfset analyse_id_ = "">
                                <cfset result_id_ = "">
                            </cfif>
                            <cfif Len(result_update_emp) or Len(result_record_emp)><cfset update_ = 1><cfelse><cfset update_=""></cfif>
                            <a href="javascript://" onClick="open_event_result('#event_plan_id#','#event_plan_row_id#','<cfif Len(company_id)>partner<cfelse>consumer</cfif>','#company_id#','#partner_id#','#consumer_id#','#analyse_id_#','#result_id_#','#diff_hour_2#','#authority_emp_#','#update_#');"><img src="/images/time.gif" border="0" title="<cf_get_lang dictionary_id ='58437.Ziyaret Sonucu'>" align="absbottom"></a>
                        </cfif>
                    </td>
                </tr>
            </cfoutput>
        <cfelse><!---Özel Rapor İçin eklendi. hgul --->
            <cfif isdefined("attributes.totalrecord") and len(attributes.totalrecord)>
                <cfoutput>
                <cfset currentrow = 0>
                <cfset mm = 1>
                <cfloop list="#attributes.convert_row_count#" index="i">
                    <cfloop from="1" to="#i#" index="j">
                    <cfset currentrow = currentrow + 1>
                    <tbody>
                        <tr id="frm_row#currentrow#">
                            <td style="width:20px;">
                                <a style="cursor:pointer" onClick="sil('#currentrow#');"><img  src="images/delete_list.gif" border="0"></a>
                            </td>
                            <td><input type="hidden" name="row_kontrol#currentrow#" id="row_kontrol#currentrow#" value="1">
                                <input type="hidden" name="company_id#currentrow#" id="company_id#currentrow#" value="#listgetat(attributes.CONVERT_COMPANY_ID,mm)#">
                                <input type="text" name="company_name#currentrow#" id="company_name#currentrow#" value="#get_par_info(listgetat(attributes.CONVERT_COMPANY_ID,mm),1,0,0)#" readonly>
                            </td>
                            <td><input type="hidden" name="consumer_id#currentrow#" id="consumer_id#currentrow#" value="">
                                <input type="hidden" name="partner_id#currentrow#" id="partner_id#currentrow#" value="#listgetat(attributes.CONVERT_PARTNER_ID,mm)#">
                                <input type="text" name="partner_name#currentrow#" id="partner_name#currentrow#" value="#get_par_info(listgetat(attributes.CONVERT_PARTNER_ID,mm),0,-1,0)#" readonly>
                                <a href="javascript://" onClick="pencere_ac('#currentrow#');"><img src="/images/plus_thin.gif" border="0" align="absbottom"></a>
                            </td>
                            <td><input type="text" name="start_date#currentrow#" id="start_date#currentrow#" value="#DateFormat(DateAdd('h',session.ep.time_zone,now()),dateformat_style)#">
                                <cf_wrk_date_image date_field="start_date#currentrow#">
                            </td>
                            <td><select name="start_clock#currentrow#" id="start_clock#currentrow#">
                                    <option value="0"><cf_get_lang dictionary_id='57491.Saat'></option>
                                    <cfset start_hour = 0>
                                    <cfloop from="7" to="30" index="k">
                                        <cfset saat=k mod 24>
                                        <option value="#saat#" <cfif start_hour eq saat>selected</cfif>>#saat#</option>
                                    </cfloop>
                                </select>
                                <cfset start_minute = 0>
                                <select name="start_minute#currentrow#" id="start_minute#currentrow#">
                                    <cfloop from="0" to="55" step="5" index="smc">
                                        <option value="#NumberFormat(smc,00)#" <cfif smc eq start_minute>selected</cfif>>#NumberFormat(smc,00)#</option>
                                    </cfloop>
                                </select>
                            </td>
                            <td><select name="finish_clock#currentrow#" id="finish_clock#currentrow#">
                                <option value="0"><cf_get_lang dictionary_id='57491.Saat'></option>
                                <cfset finish_hour = 0>
                                <cfloop from="7" to="30" index="kk">
                                    <cfset saat=kk mod 24>
                                    <option value="#saat#" <cfif finish_hour eq saat>selected</cfif>>#saat#</option>
                                </cfloop>
                                </select>
                                <cfset finish_minute = 0>
                                <select name="finish_minute#currentrow#" id="finish_minute#currentrow#">
                                    <cfloop from="0" to="55" step="5" index="fmc">
                                        <option value="#NumberFormat(fmc,00)#" <cfif fmc eq finish_minute>selected</cfif>>#NumberFormat(fmc,00)#</option>
                                    </cfloop>
                                </select>
                            </td>
                            <td>
                                <select name="warning_id#currentrow#" id="warning_id#currentrow#">
                                    <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                    <cfloop query="get_visit_types">
                                        <option value="#visit_type_id#">#visit_type#</option>
                                    </cfloop>
                                </select>
                            </td>
                            <td>
                                <cfquery name="get_pos_code" datasource="#dsn#">
                                    SELECT POSITION_CODE FROM EMPLOYEE_POSITIONS WHERE EMPLOYEE_ID = #attributes.employee_id#
                                </cfquery>
                                <input type="hidden" name="pos_emp_id#currentrow#" id="pos_emp_id#currentrow#" value="#get_pos_code.POSITION_CODE#">
                                <input type="text" name="pos_emp_name#currentrow#" id="pos_emp_name#currentrow#" value="#get_emp_info(attributes.employee_id,0,0)#" readonly>
                                &nbsp;<a href="javascript://" onClick="temizlerim('#currentrow#');pencere_ac_pos('#currentrow#');"><img src="/images/plus_thin.gif" border="0" align="absbottom"></a>
                            </td>
                            <td width="19">
                            </td>
                        </tr>
                    </cfloop>
                    <cfset mm = mm + 1>
                </cfloop>
                </cfoutput>
            </cfif>
        </cfif>
    </tbody>
</cf_grid_list>
<script type="text/javascript">
function order_copy(nesne)
{
	var number = parseInt(document.getElementById('record_num').value);
	for(var i=1;i<=number;i++)
	{
		var temp_nesne = nesne + i;
		if( document.getElementById(nesne).value != '' ) document.getElementById(temp_nesne).value=document.getElementById(nesne).value;
		//eval("document.add_event."+nesne+i).value = eval("document.add_event."+nesne).value;
	}	
	if(nesne=='pos_emp_name')
		order_copy('pos_emp_id');

	if(nesne=='partner_name')
	{
		order_copy('partner_id');
		order_copy('company_id');
		order_copy('company_name');
	}
	
	if(nesne=='relation_asset')
	{
		order_copy('relation_asset_id');
	}
	if(nesne=='project_head')
	{
		order_copy('project_id');
	}
	
}
function call_order_copy()
{
	order_copy('start_date');
}
function pencere_ac(no)
{
	openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_pars&field_id=add_event.partner_id' + no +'&field_comp_name=add_event.company_name' + no +'&field_name=add_event.partner_name' + no +'&field_comp_id=add_event.company_id' + no + '&select_list=2,3,5,6');
}
</script>
