<cfquery name="GET_PROJECT" datasource="#DSN#">
	SELECT PROJECT_ID,TARGET_START, TARGET_FINISH FROM PRO_PROJECTS WHERE PROJECT_ID = #url.id#
</cfquery>
<cfquery name="GET_ASSET_PRO" datasource="#DSN#">
	SELECT STARTDATE, FINISHDATE, PROJECT_ID, ASSETP_ID, ASSETP_RESID FROM ASSET_P_RESERVE WHERE PROJECT_ID =#url.id#
</cfquery>
<cfsavecontent variable="title"><cf_get_lang dictionary_id='30004.Fiziki Varlıklar'></cfsavecontent>
<cf_popup_box title="#title#">
	<cf_medium_list>
		<thead>
			<tr>
				<th><cf_get_lang dictionary_id='57420.Varlıklar'></th>
				<th><cf_get_lang dictionary_id='38183.Rezervasyon'></th>
				<th></th>
				<th width="35" style="text-align:center;"><a href="javascript://" onClick="windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_list_pro_assets&project_id=#get_project.project_id#&startdate_temp=#get_project.target_start#&finishdate_temp=#get_project.target_finish#</cfoutput>','list');"><img src="/images/plus_list.gif" title="<cf_get_lang dictionary_id='57582.Olay Ekle'>"></a></th>
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
						<td width="1%"><a href="javascript:windowopen('#request.self#?fuseaction=objects.popup_form_upd_assetp_reserve&assetp_resid=#assetp_resid#&assetp_id=#assetp_id#&project_id=#attributes.id#','small');"><img src="/images/update_list.gif" title="<cf_get_lang dictionary_id='57464.Güncelle'>"></a></td>
							<cfsavecontent variable="message"><cf_get_lang dictionary_id ='38349.Varlık Rezervasyonunu Siliyorsunuz Emin misiniz'></cfsavecontent>
						<td width="1%"><a href="##" onClick="javascript:if (confirm('#message#')) windowopen('#request.self#?fuseaction=project.emptypopup_del_asset_project&id=#url.id#&assetp_id=#get_assetp_name.assetp_id #','small'); else return;"><img src="/images/delete_list.gif"  border="0" title="<cf_get_lang dictionary_id='38180.Notu Sil'>"></a></td>
					</tr>
				</cfoutput>
			<cfelse>
				<tr>
					<td colspan="4"><cf_get_lang dictionary_id ='57484.Kayıt Yok'>!</td>
				</tr>
			</cfif>
		</tbody>
	</cf_medium_list>

</cf_popup_box>
