<cfquery name="GET_ROW" datasource="#DSN#">
	SELECT 
    	ASSET_ID,
        COMPANY_ID,
        EVENT_PLAN_ROW_ID,
        CONSUMER_ID,
        PARTNER_ID,
        START_DATE,
        FINISH_DATE,
        WARNING_ID,
        EVENT_PLAN_ID,
        RESULT_UPDATE_EMP,
        RESULT_RECORD_EMP,
        PROJECT_ID,
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
<cf_grid_list>
 	<thead>
		<tr>
            <cfoutput>
				<th width="20"></th>
				<th width="200">
					<input type="hidden" value="1" name="row_kontrol" id="row_kontrol">
					<input type="hidden" name="company_id" id="company_id" value="">
					<input type="text" name="company_name" id="company_name"  value="" placeholder="#getLang('','Kurumsal Hesap','61845')# #getLang('','Seçiniz','57734')#">
				</th>
				<th width="200">
					<div class="form-group">
						<div class="input-group">
							<input type="hidden" name="partner_id" id="partner_id" onchange="order_copy('partner_id');" value="">
							<input type="text" name="partner_name" id="partner_name" placeholder="#getLang('','Kontak Kişiler','31385')#" style="width:120px;" onfocus="order_copy('partner_name');"  value="">
							<span class="input-group-addon icon-ellipsis" onClick="windowopen('#request.self#?fuseaction=objects.popup_list_pars&field_id=add_event.partner_id&field_comp_name=add_event.company_name&field_name=add_event.partner_name&field_comp_id=add_event.company_id&select_list=7,8','project');"></span>
						</div>
					</div>
				</th>
				<th width="200">
					<div class="form-group">
						<div class="input-group">
							<input type="text" name="start_date" id="start_date" maxlength="10" placeholder="#getLang('','Tarih Giriniz','61893')#" style="width:60px;" value="" <cfif x_row_result_date_today eq 1>readonly<cfelse> onblur="order_copy('start_date');"</cfif>>
							<cfif x_row_result_date_today eq 1>
								<i class="fa fa-calendar"></i>
							<cfelse>
								<span class="input-group-addon"><cf_wrk_date_image date_field="start_date" call_function="call_order_copy"></span>
							</cfif>
						</div>
					</div>
				</th>
				<th width="200">
					<div class="form-group">
						<div class="col col-6">
							<cf_wrkTimeFormat name="start_clock" value="9" style="width:50px;"  onchange="order_copy('start_clock');">
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
							<cf_wrkTimeFormat name="finish_clock" value="17" style="width:50px;" onchange="order_copy('finish_clock');">
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
							<cfif len(get_row.event_plan_row_id)>
								<cfquery name="get_row_position" datasource="#dsn#">
									SELECT
										EPP.EVENT_POS_ID,
										EP.EMPLOYEE_NAME + ' ' + EP.EMPLOYEE_SURNAME NAME_SURNAME
									FROM
										EVENT_PLAN_ROW_PARTICIPATION_POS EPP,
										EMPLOYEE_POSITIONS EP
									WHERE
										EPP.EVENT_POS_ID = EP.POSITION_CODE AND
										EPP.EVENT_ROW_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_row.event_plan_row_id#">
								</cfquery>
								<input type="hidden" name="pos_emp_id" id="pos_emp_id" onchange="order_copy('pos_emp_id');" value="">
								<input name="pos_emp_name" id="pos_emp_name" type="text" style="width:150px;" placeholder="#getLang('','Tarih Giriniz','41034')#"  onfocus="order_copy('pos_emp_name');" value="#ListSort(ListDeleteDuplicates(Valuelist(get_row_position.name_surname,',')),'text','asc',',')#" autocomplete="off">
								<span class="input-group-addon icon-ellipsis" onfocus="order_copy('pos_emp_name');" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_multi_pars&field_id=add_event.pos_emp_id&field_name=add_event.pos_emp_name&select_list=1,2&is_upd=1');"></span>
							</cfif>
						</div>
					</div>
				</th>
				<cfif is_choose_project eq 1>
					<th width="200">
						<div class="form-group">
							<div class="input-group">
								<input type="hidden" name="relation_asset_id" id="relation_asset_id" onchange="order_copy('relation_asset_id')" value="<cfif isdefined('attributes.relation_asset_id')>#attributes.relation_asset_id#</cfif>">
								<input type="text" name="relation_asset" id="relation_asset" readonly="readonly" value="<cfif isdefined('attributes.relation_asset')>#attributes.relation_asset#</cfif>" style="width:140px" onFocus="order_copy('relation_asset')">
								<span class="input-group-addon icon-ellipsis" onClick="windowopen('#request.self#?fuseaction=assetcare.popup_list_assetps&field_id=add_event.relation_asset_id&field_name=add_event.relation_asset&event_id=0','list');"></span>
							</div>
						</div>
					</th>
					<th width="200">
						<div class="form-group">
							<div class="input-group">
								<input type="hidden" name="project_id" id="project_id"  value="" onchange="order_copy('project_id')">
								<input type="text" name="project_head" id="project_head" style="width:140px;" value=""  onFocus="order_copy('project_head')">
								<span class="input-group-addon icon-ellipsis" onClick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_list_projects&project_head=add_event.project_head&project_id=add_event.project_id</cfoutput>');"></span>
							</div>
						</div>
					</th>
				</cfif>
            	<th width="20"></th>
            </cfoutput>
        </tr>
        <tr>
            <th width="20"><input name="record_num" id="record_num" type="hidden" value="<cfoutput><cfif isdefined("attributes.totalrecord")>#attributes.totalrecord + row_count#<cfelseif isdefined('get_row')>#row_count#<cfelse>0</cfif></cfoutput>"><a href="javascript://" onClick="pencere_ac_company();"><i class="fa fa-plus" title="<cf_get_lang dictionary_id='57582.Ekle'>" alt="<cf_get_lang dictionary_id='57582.Ekle'>"></i></a></th>
            <th width="200" colspan="2"><cf_get_lang dictionary_id='41033.Ziyaret Edilecek'></th>
            <th width="200"><cf_get_lang dictionary_id ='57742.Tarih'> *</th>
            <th width="200"><cf_get_lang dictionary_id ='41221.Başlama Saati'> *</th>
            <th width="200"><cf_get_lang dictionary_id ='41222.Bitiş Saati'> *</th>
            <th width="200"><cf_get_lang dictionary_id ='41035.Ziyaret Nedeni'> *</th>
            <th width="200"><cf_get_lang dictionary_id ='41034.Ziyaret Edecekler'></th>
            <cfif is_choose_project eq 1>
                <th width="200"><cf_get_lang dictionary_id ='30004.Fiziki Varlıklar'></th>
                <th width="200"><cf_get_lang dictionary_id ='57416.Proje'></th>
            </cfif>
            <th width="20"></th>
        </tr>
    </thead>
    <tbody id="table1">
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
				<cfset now_hour_3 = DateFormat(DateAdd('h',session.ep.time_zone,now()),'mm/dd/yyyy')>
				<cfset now_hour_3 = CreateOdbcDateTime(now_hour_3)>
				<cfset date_3 = DateFormat(get_row.start_date,'mm/dd/yyyy')><!--- Formati degistirmeyin!!! FBS 20111031 --->
				<cfset date_3 = CreateOdbcDateTime(date_3)>
				<cfset diff_hour_3 = DateDiff("n",now_hour_3,date_3)>
			<cfelse>
				<cfset diff_hour_3 = 1>
			</cfif>
			<tr id="frm_row#currentrow#">
				<td nowrap>
					<a style="cursor:pointer" onClick="if('#diff_hour_#' < 0) {alert('#x_row_del_hour# \' den Sonra Kaydı Silemezsiniz!'); return false;} else {sil('#currentrow#');}"><i class="fa fa-minus" title="<cf_get_lang dictionary_id='57463.Sil'>" alt="<cf_get_lang dictionary_id='57463.Sil'>"></i></a>
				</td>
				<td>
					<div class="form-group">
						<input type="hidden" name="row_kontrol#currentrow#" id="row_kontrol#currentrow#" value="1">
						<input type="hidden" name="company_id#currentrow#" id="company_id#currentrow#" value="#get_row.company_id#">
						<input type="text" name="company_name#currentrow#" id="company_name#currentrow#" value="#get_par_info(get_row.company_id,1,0,0)#" readonly>
					</div>
				</td>
				<td>
					<div class="form-group">
						<div class="input-group">
							<input type="hidden" name="consumer_id#currentrow#" id="consumer_id#currentrow#" value="#get_row.consumer_id#">
							<input type="hidden" name="partner_id#currentrow#" id="partner_id#currentrow#" value="#get_row.partner_id#">
							<input type="text" name="partner_name#currentrow#" id="partner_name#currentrow#" value="<cfif len(get_row.partner_id)>#get_par_info(get_row.partner_id,0,-1,0)#<cfelse>#get_cons_info(get_row.consumer_id,0,0)#</cfif>" readonly>
							<span class="input-group-addon icon-ellipsis" onClick="pencere_ac('#currentrow#');"></span>
						</div>
					</div>
				</td>
				<td>
					<div class="form-group">
						<div class="input-group">
							<input type="text" name="start_date#currentrow#" id="start_date#currentrow#" value="#dateformat(get_row.start_date,dateformat_style)#" maxlength="10" style="width:60px" <cfif diff_hour_3 lt 0>readonly</cfif>>
							<cfif diff_hour_3 lt 0><i class="fa fa-calendar"></i><cfelse><span class="input-group-addon"><cf_wrk_date_image date_field="start_date#currentrow#"></span></cfif>
						</div>
					</div>
				</td>
				<td>
					<div class="form-group">
						<div class="col col-6 col-md-6 col-sm-6 col-xs-12">
							<cfif len(get_row.start_date)>
								<cf_wrkTimeFormat name="start_clock#currentrow#" value="#hour(get_row.start_date)#">
							<cfelse>
								<cf_wrkTimeFormat name=start_clock value="0">
							</cfif>
						</div>
						<div class="col col-6 col-md-6 col-sm-6 col-xs-12">
							<cfif len(get_row.start_date)><cfset start_minute = minute(get_row.start_date)><cfelse><cfset start_minute = 0></cfif>
							<select name="start_minute#currentrow#" id="start_minute#currentrow#">
								<cfloop from="0" to="55" step="5" index="smc">
									<option value="#NumberFormat(smc,00)#" <cfif smc eq start_minute>selected</cfif>>#NumberFormat(smc,00)#</option>
								</cfloop>
							</select>
						</div>
					</div>
				</td>
				<td>
					<div class="form-group">
						<div class="col col-6 col-md-6 col-sm-6 col-xs-12">
							<cfif len(get_row.finish_date)>
								<cf_wrkTimeFormat name="finish_clock#currentrow#" value="#hour(get_row.finish_date)#">
							<cfelse>
								<cf_wrkTimeFormat name="finish_clock#currentrow#" value="0">
							</cfif>
						</div>
						<div class="col col-6 col-md-6 col-sm-6 col-xs-12">
							<cfif len(get_row.finish_date)><cfset finish_minute = minute(get_row.finish_date)><cfelse><cfset finish_minute = 0></cfif>
							<select name="finish_minute#currentrow#" id="finish_minute#currentrow#" style="width:40px;">
								<cfloop from="0" to="55" step="5" index="fmc">
									<option value="#NumberFormat(fmc,00)#" <cfif fmc eq finish_minute>selected</cfif>>#NumberFormat(fmc,00)#</option>
								</cfloop>
							</select>
						</div>
					</div>
				</td>
				<td>
					<div class="form-group">
						<cfset form_warning_id = get_row.warning_id>
						<select name="warning_id#currentrow#" id="warning_id#currentrow#" style="width:150px;">
							<option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
							<cfloop query="get_visit_types">
								<option value="#visit_type_id#" <cfif form_warning_id eq visit_type_id>selected</cfif>>#visit_type#</option>
							</cfloop>
						</select>
					</div>
				</td>
				<td>
					<cfquery name="get_row_pos" datasource="#dsn#">
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
					<div class="form-group">
						<div class="input-group">
							<input type="hidden" name="pos_emp_id#currentrow#" id="pos_emp_id#currentrow#" value="#ListSort(ListDeleteDuplicates(Valuelist(get_row_pos.event_pos_id,',')),'numeric','asc',',')#"><!--- <cfloop query="get_row_pos">,#event_pos_id#</cfloop> --->
							<input type="text" name="pos_emp_name#currentrow#" id="pos_emp_name#currentrow#" value="#ListSort(ListDeleteDuplicates(Valuelist(get_row_pos.name_surname,',')),'text','asc',',')#" readonly> 
							<span class="input-group-addon icon-ellipsis" onClick="temizlerim('#currentrow#');pencere_ac_pos('#currentrow#');"></span>
						</div>
					</div>
				</td>
				<cfif is_choose_project eq 1>
					<td>
						<cfif len(asset_id)>
							<cfquery name="get_asset_row" datasource="#dsn#">
								SELECT ASSET_P.ASSETP,ASSETP_ID FROM ASSET_P WHERE ASSETP_ID=#asset_id#
							</cfquery>
						</cfif>
						<div class="form-group">
							<div class="input-group">
								<input type="hidden" name="relation_asset_id#currentrow#" id="relation_asset_id#currentrow#" value="<cfif len(asset_id) and isdefined("get_asset_row.ASSETP_ID") and  len(get_asset_row.ASSETP_ID)>#get_asset_row.ASSETP_ID#</cfif>">
								<input type="text" name="relation_asset#currentrow#" id="relation_asset#currentrow#" readonly="readonly" value="<cfif len(asset_id) and isdefined("get_asset_row.ASSETP") and len(get_asset_row.ASSETP)>#get_asset_row.assetp#</cfif>" style="width:140px;">
								<span class="input-group-addon icon-ellipsis" onClick="windowopen('#request.self#?fuseaction=assetcare.popup_list_assetps&field_id=add_event.relation_asset_id#currentrow#&field_name=add_event.relation_asset#currentrow#&event_id=0','list');"></span>
							</div>
						</div>
					</td>
					<td>
						<cfif len(project_id)>
							<cfquery name="get_project" datasource="#dsn#">
								SELECT PROJECT_ID,PROJECT_HEAD FROM PRO_PROJECTS WHERE PROJECT_ID=<cfqueryparam cfsqltype="cf_sql_integer" value="#project_id#">
							</cfquery>
						</cfif>
						<div class="form-group">
							<div class="input-group">
								<input type="hidden" name="project_id#currentrow#" id="project_id#currentrow#" value="<cfif len(project_id) and  isdefined("get_project.project_id") and  len(get_project.project_id)>#get_project.project_id#</cfif>">
								<input type="text" name="project_head#currentrow#" id="project_head#currentrow#" style="width:140px;" readonly="readonly" value="<cfif len(project_id) and isdefined("get_project.project_head") and len(get_project.project_head)>#get_project.project_head#</cfif>">
								<span class="input-group-addon icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_projects&project_head=add_event.project_head#currentrow#&project_id=add_event.project_id#currentrow#');"></span>
							</div>
						</div>
					</td>
				</cfif>
				<td width="20"style="text-align:center" >
					<cfif not len(event_plan_id)><!--- crm --->
						<a href="javascript://" onClick="if('#diff_hour_2#' < 0 && '#ListFind(authority_emp_,session.ep.userid)#' == 0) {alert('#x_row_result_hour# \' den Sonra Sonuç Giremezsiniz!'); return false;} else {windowopen('#request.self#?fuseaction=crm.popup_form_upd_visit&eventid=#event_plan_id#&event_plan_row_id=#event_plan_row_id#&partner_id=#partner_id#&result_id=#get_kontrol.result_id#' ,'print_page');}"><i class="fa fa-smile-o" title="<cf_get_lang dictionary_id ='58437.Ziyaret Sonucu'>"></i></a>
					<cfelse>
						<cfif len(get_event_plan.analyse_id)>
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
						 <cfif len(get_row.result_update_emp)>
							<font color="4AA02C" a href="javascript://" onClick="open_event_result('#event_plan_id#','#event_plan_row_id#','<cfif Len(company_id)>partner<cfelse>consumer</cfif>','#company_id#','#partner_id#','#consumer_id#','#analyse_id_#','#result_id_#','#diff_hour_2#','#authority_emp_#','#update_#');"><i class="fa fa-pencil-square-o title="<cf_get_lang dictionary_id ='58437.Ziyaret Sonucu'>"></i></a>	
						<cfelse> 
							<font color="FF000" a href="javascript://" onClick="open_event_result('#event_plan_id#','#event_plan_row_id#','<cfif Len(company_id)>partner<cfelse>consumer</cfif>','#company_id#','#partner_id#','#consumer_id#','#analyse_id_#','#result_id_#','#diff_hour_2#','#authority_emp_#','#update_#');"><i class="fa fa-pencil-square-o title="<cf_get_lang dictionary_id ='58437.Ziyaret Sonucu'>"></i></a>
						 </cfif>	
					<!--- 	<font color="FF0000" a href="javascript://" onClick="open_event_result('#event_plan_id#','#event_plan_row_id#','<cfif Len(company_id)>partner<cfelse>consumer</cfif>','#company_id#','#partner_id#','#consumer_id#','#analyse_id_#','#result_id_#','#diff_hour_2#','#authority_emp_#','#update_#');"><i class="fa fa-pencil-square-o title="<cf_get_lang dictionary_id ='58437.Ziyaret Sonucu'>"></i></a>
						</cfif> --->
						<!--- </cfif> --->
					</cfif>
				</td>
			</tr>
		</cfoutput>
		<cfif isdefined("attributes.totalrecord") and len(attributes.totalrecord)>
			<cfoutput>
				<cfset currentrow = get_row.recordcount>
				<cfset mm = 1>
				<cfloop list="#attributes.convert_row_count#" index="i">
					<cfloop from="1" to="#i#" index="j">
						<cfset currentrow = currentrow + 1>
						<tr id="frm_row#currentrow#">
							<td nowrap>
								<a style="cursor:pointer" onClick="sil(#currentrow#);"><i class="fa fa-minus" title="<cf_get_lang dictionary_id='57463.Sil'>" alt="<cf_get_lang dictionary_id='57463.Sil'>"></i></a>
							</td>
							<td>
								<div class="form-group">
									<input type="hidden" name="row_kontrol#currentrow#" id="row_kontrol#currentrow#" value="1">
									<input type="hidden" name="company_id#currentrow#" id="company_id#currentrow#" value="#listgetat(attributes.CONVERT_COMPANY_ID,mm)#">
									<input type="text" name="company_name#currentrow#" id="company_name#currentrow#" value="#get_par_info(listgetat(attributes.CONVERT_COMPANY_ID,mm),1,0,0)#" readonly style="width:120px;">
								</div>
							</td>
							<td>
								<div class="form-group">
									<input type="hidden" name="consumer_id#currentrow#" id="consumer_id#currentrow#" value="">
									<input type="hidden" name="partner_id#currentrow#" id="partner_id#currentrow#" value="#listgetat(attributes.CONVERT_PARTNER_ID,mm)#">
									<input type="text" name="partner_name#currentrow#" id="partner_name#currentrow#" value="#get_par_info(listgetat(attributes.CONVERT_PARTNER_ID,mm),0,-1,0)#" readonly style="width:140px;">
									<a href="javascript://" onClick="pencere_ac('#currentrow#');"><i class="fa fa-plus" title="<cf_get_lang dictionary_id='57582.Ekle'>" alt="<cf_get_lang dictionary_id='57582.Ekle'>"></i></a>
								</div>
							</td>
							<td>
								<div class="form-group">
									<div class="input-group">
										<input type="text" name="start_date#currentrow#" id="start_date#currentrow#" value="#DateFormat(DateAdd('h',session.ep.time_zone,now()),dateformat_style)#" style="width:65px">
										<span class="input-group-addon"><cf_wrk_date_image date_field="start_date#currentrow#"></span>
									</div>
								</div>
							</td>
							<td>
								<div class="form-group">
									<select name="start_clock#currentrow#" id="start_clock#currentrow#" style="width:45px;">
										<option value="0"><cf_get_lang dictionary_id='57491.Saat'></option>
										<cfset start_hour = 0>
										<cfloop from="7" to="30" index="k">
											<cfset saat=k mod 24>
											<option value="#saat#" <cfif start_hour eq saat>selected</cfif>>#saat#</option>
										</cfloop>
									</select>
									<cfset start_minute = 0>
									<select name="start_minute#currentrow#" id="start_minute#currentrow#" style="width:40px;">
										<cfloop from="0" to="55" step="5" index="smc">
											<option value="#NumberFormat(smc,00)#" <cfif smc eq start_minute>selected</cfif>>#NumberFormat(smc,00)#</option>
										</cfloop>
									</select>
								</div>
							</td>
							<td>
								<div class="form-group">
									<select name="finish_clock#currentrow#" id="finish_clock#currentrow#" style="width:45px;">
										<option value="0"><cf_get_lang dictionary_id='57491.Saat'></option>
										<cfset finish_hour = 0>
										<cfloop from="7" to="30" index="kk">
											<cfset saat=kk mod 24>
											<option value="#saat#" <cfif finish_hour eq saat>selected</cfif>>#saat#</option>
										</cfloop>
									</select>
									<cfset finish_minute = 0>
									<select name="finish_minute#currentrow#" id="finish_minute#currentrow#" style="width:40px;">
										<cfloop from="0" to="55" step="5" index="fmc">
											<option value="#NumberFormat(fmc,00)#" <cfif fmc eq finish_minute>selected</cfif>>#NumberFormat(fmc,00)#</option>
										</cfloop>
									</select>
								</div>
							</td>
							<td>
								<div class="form-group">
									<select name="warning_id#currentrow#" id="warning_id#currentrow#" style="width:150px;">
										<option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
										<cfloop query="get_visit_types">
											<option value="#visit_type_id#">#visit_type#</option>
										</cfloop>
									</select>
								</div>
							</td>
							<td>
								<div class="form-group">
									<div class="input-group">
										<cfquery name="get_pos_code" datasource="#dsn#">
											SELECT POSITION_CODE FROM EMPLOYEE_POSITIONS WHERE EMPLOYEE_ID = #attributes.employee_id#
										</cfquery>
										<input type="hidden" name="pos_emp_id#currentrow#" id="pos_emp_id#currentrow#" value="#get_pos_code.POSITION_CODE#">
										<input type="text" name="pos_emp_name#currentrow#" id="pos_emp_name#currentrow#" value="#get_emp_info(attributes.employee_id,0,0)#" readonly style="width:170px;">
										<span class="input-group-addon icon-ellipsis" onClick="temizlerim('#currentrow#');pencere_ac_pos('#currentrow#');"></span>
									</div>
								</div>
							</td>
						</tr>
					</cfloop>
					<cfset mm = mm + 1>
				</cfloop>
			</cfoutput>
		</cfif>
   </tbody>
</cf_grid_list>
<script type="text/javascript">
function open_event_result(plan_id,plan_row_id,member_type,comp_id,part_id,cons_id,analyse_id,result_id,diff_h,auth_emp,is_upd)
{
	var session_user_ = "<cfoutput>#session.ep.userid#</cfoutput>";
	if(diff_h < 0 && list_find(auth_emp,session_user_) == 0)
	{
		alert('<cfoutput>#x_row_result_hour#</cfoutput> \' den Sonra Sonuç Giremezsiniz!');
		return false;
	}
	else
	{
		<cfoutput>
		if(is_upd != "")
			link_ = "event_plan_result&event=upd";
		
		else
		link_ = "popup_add_event_plan_result";
			
			openBoxDraggable('#request.self#?fuseaction=objects.'+link_+'&eventid='+plan_id +'&event_plan_row_id=' +plan_row_id+'&partner_id='+part_id );
		if(analyse_id != "")
		{	
			member_links = '&member_type='+member_type+'&company_id='+comp_id+'&partner_id='+part_id+'&consumer_id='+cons_id;
			if(result_id != "")
			openBoxDraggable('#request.self#?fuseaction=member.list_analysis&event=upd-result&action_type=MEMBER&analysis_id='+analyse_id+'&result_id='+result_id+member_links );
			else
				openBoxDraggable('#request.self#?fuseaction=member.popup_add_member_analysis_result&action_type=MEMBER&action_type_id=&analysis_id='+analyse_id+member_links);
		}
		</cfoutput>
		
	}
}
function kontrol_et()
{
	if(row_count ==0)
		return false;
	else
		return true;
}

function pencere_ac(no)
{
	windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_pars&field_id=add_event.partner_id' + no +'&field_comp_name=add_event.company_name' + no +'&field_name=add_event.partner_name' + no +'&field_comp_id=add_event.company_id' + no + '&select_list=2,3,5,6','list');
}
function order_copy(nesne)
{
	var number = document.getElementById('record_num').value;
	for(var i=1;i<=number;i++)
	{
		var temp_nesne = nesne + i;
		if( document.getElementById(nesne).value != '' ) document.getElementById(temp_nesne).value=document.getElementById(nesne).value;
		//eval("document.add_event."+nesne+i).value = eval("document.add_event."+nesne).value;
	}
	if(nesne=='pos_emp_name')
	{
		order_copy('pos_emp_id');
	}
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
</script>
