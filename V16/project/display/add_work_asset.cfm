<cfquery name="Get_Work" datasource="#dsn#">
	SELECT WORK_ID,TARGET_START,TARGET_FINISH FROM PRO_WORKS WHERE WORK_ID = #attributes.work_id#
</cfquery>
<cfquery name="Get_Asset_Work" datasource="#dsn#">
	SELECT STARTDATE,FINISHDATE,WORK_ID,ASSETP_ID,ASSETP_RESID FROM ASSET_P_RESERVE WHERE WORK_ID = #attributes.work_id#
</cfquery>
<cfsavecontent variable="title"><cf_get_lang dictionary_id='30004.Fiziki Varlıklar'></cfsavecontent>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
<cf_box title="#title#">
	<cf_grid_list>
		<thead>
			<tr>
				<th><cf_get_lang dictionary_id='57420.Varlıklar'></th>
				<th><cf_get_lang dictionary_id='38183.Rezervasyon'></th>
				<th width="20"><a href="javascript://"><i class="fa fa-pencil"></i></a></th>
				<th width="20"><a href="javascript://" onClick="windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_list_pro_assets&work_id=#get_work.work_id#&startdate_temp=#get_work.target_start#&finishdate_temp=#get_work.target_finish#</cfoutput>','list');"><i class="fa fa-plus" title="<cf_get_lang dictionary_id='58496.Olay Ekle'>"></i></a></th>
			</tr>
		</thead>
		<tbody>
			<cfif Get_Asset_Work.RecordCount>
				<cfoutput query="Get_Asset_Work">
					<tr>
						<cfif len(Work_Id)>
							<cfquery name="get_assetp_name" datasource="#dsn#">
								SELECT ASSETP_ID, ASSETP FROM ASSET_P WHERE ASSETP_ID = #Assetp_Id#
							</cfquery>
						</cfif>
						<td>
						<cfif len(Work_Id)>#get_assetp_name.assetp#</cfif>
						</td>
						<td>
							#dateformat(date_add('h',session.ep.time_zone,startdate),dateformat_style)#&nbsp;(#Timeformat(date_add('h',session.ep.time_zone,startdate),timeformat_style)#) - #dateformat(date_add('h',session.ep.time_zone,finishdate),dateformat_style)#&nbsp;(#Timeformat(date_add('h',session.ep.time_zone,finishdate),timeformat_style)#) 
						</td>
						<td><a href="javascript:windowopen('#request.self#?fuseaction=objects.popup_form_upd_assetp_reserve&assetp_resid=#assetp_resid#&assetp_id=#assetp_id#&work_id=#attributes.work_id#','small');"><i class="fa fa-pencil" title="<cf_get_lang dictionary_id='57464.Güncelle'>"></i></a></td>
							<cfsavecontent variable="message"><cf_get_lang dictionary_id ='38349.Varlık Rezervasyonunu Siliyorsunuz Emin misiniz'></cfsavecontent>
						<td><a href="##" onClick="javascript:if (confirm('#message#')) windowopen('#request.self#?fuseaction=work.emptypopup_del_asset_work&work_id=#attributes.work_id#&assetp_id=#get_assetp_name.assetp_id #','small'); else return;"><i class="fa fa-minus" title="<cf_get_lang dictionary_id='38180.Notu Sil'>"></i></a></td>
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
