<cfquery name="GET_PROJECT" datasource="#DSN#">
	SELECT PROJECT_ID,TARGET_START, TARGET_FINISH FROM PRO_PROJECTS WHERE PROJECT_ID = #url.id#
</cfquery>
<cfquery name="GET_ASSET_PRO" datasource="#DSN#">
	SELECT STARTDATE, FINISHDATE, PROJECT_ID, ASSETP_ID, ASSETP_RESID FROM ASSET_P_RESERVE WHERE PROJECT_ID =#url.id#
</cfquery>
<cfparam name="attributes.modal_id" default="">
<cfsavecontent variable="title"><cf_get_lang dictionary_id='30004.Fiziki Varlıklar'></cfsavecontent>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
<cf_box title="#title#" popup_box="#iif(isdefined("attributes.draggable"),1,0)#">
	<cf_grid_list>
		<thead>
			<tr>
				<th><cf_get_lang dictionary_id='57420.Varlıklar'></th>
				<th><cf_get_lang dictionary_id='38183.Rezervasyon'></th>
				<th width="20"><a href="javascript://"><i class="fa fa-pencil"></i></a></th>
				<th width="20"><a href="javascript://" onClick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_list_pro_assets&project_id=#get_project.project_id#&startdate_temp=#get_project.target_start#&finishdate_temp=#get_project.target_finish#</cfoutput>');"><i class="fa fa-plus" title="<cf_get_lang dictionary_id='58496.Olay Ekle'>"></i></a></th>
			</tr>
		</thead>
		<tbody>
			<cfif get_asset_pro.recordcount>
				<cfoutput query="get_asset_pro">
					<tr>
						<cfif len(get_asset_pro.project_id)>
							<cfquery name="get_assetp_name" datasource="#dsn#">
								SELECT ASSETP_ID, ASSETP FROM ASSET_P WHERE ASSETP_ID = #get_asset_pro.assetp_id#
							</cfquery>
						</cfif>
						<td>
						<cfif len(get_asset_pro.project_id)>#get_assetp_name.assetp#</cfif>
						</td>
						<td>
							<!--- #dateformat(startdate,dateformat_style)#&nbsp;(#timeformat(startdate,timeformat_style)#) - #dateformat(finishdate,dateformat_style)#&nbsp;(#timeformat(finishdate,timeformat_style)#) --->
							#dateformat(date_add('h',session.ep.time_zone,startdate),dateformat_style)#&nbsp;(#Timeformat(date_add('h',session.ep.time_zone,startdate),timeformat_style)#) - #dateformat(date_add('h',session.ep.time_zone,finishdate),dateformat_style)#&nbsp;(#Timeformat(date_add('h',session.ep.time_zone,finishdate),timeformat_style)#) 
						</td>
						<td><a href="javascript:openBoxDraggable('#request.self#?fuseaction=objects.popup_form_upd_assetp_reserve&assetp_resid=#assetp_resid#&assetp_id=#assetp_id#&project_id=#attributes.id#');"><i class="fa fa-pencil" title="<cf_get_lang dictionary_id='57464.Güncelle'>"></i></a></td>
							<cfsavecontent variable="message"><cf_get_lang dictionary_id ='38349.Varlık Rezervasyonunu Siliyorsunuz Emin misiniz'></cfsavecontent>
						<td><a href="javascript://" onClick="if (confirm('#message#')) openBoxDraggable('#request.self#?fuseaction=project.emptypopup_del_asset_project&id=#url.id#&assetp_id=#get_assetp_name.assetp_id #'); else return;"><i class="fa fa-minus" title="<cf_get_lang dictionary_id='58833.Fiziki Varlık'><cf_get_lang dictionary_id='57463.Sil'>"></i></a></td>
					</tr>
				</cfoutput>
			<cfelse>
				<tr>
					<td colspan="4"><cf_get_lang dictionary_id ='57484.Kayıt Yok'>!</td>
				</tr>
			</cfif>
		</tbody>
	</cf_grid_list>
</cf_box>
</div>
