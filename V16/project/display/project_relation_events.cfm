<cfquery name="GET_RELATED_EVENTS" datasource="#DSN#">
	SELECT
		RE.*,
		E.EVENT_HEAD
	FROM
		EVENTS_RELATED RE,
		EVENT E
	WHERE
		E.EVENT_ID = RE.EVENT_ID AND		
		RE.ACTION_SECTION = 'PROJECT_ID' AND
		RE.ACTION_ID = #attributes.id#
	  <cfif isdefined("attributes.company_id") and len(attributes.company_id)>
		AND RE.COMPANY_ID = #session.ep.company_id#
	  </cfif>	
	ORDER BY 
		E.STARTDATE DESC
</cfquery>
<cfparam name="attributes.design_id" default="1">
<table cellSpacing="0" cellpadding="0" width="98%" border="0">
  <tr class="color-border">
	<td>
		<table cellspacing="1" cellpadding="2" width="100%" border="0">
			<tr class="color-header" height="22">
				<cfoutput>
				<td class="form-title" width="90%"><cf_get_lang dictionary_id='57993.İlişkili Olaylar'></td>
				<td width="10%" align="right" style="text-align:right;">
					<a href="#request.self#?fuseaction=objects2.form_add_event&action_id=#attributes.id#&action_section=PROJECT_ID"><img src="/images/plus_square.gif" title="<cf_get_lang dictionary_id='57993.İlişkili Olay'> <cf_get_lang dictionary_id='57582.Ekle'>" border="0"></a>
				</td>
				</cfoutput>
			</tr>
			<cfoutput query="get_related_events">
				<tr height="20" class="color-row">
					<td width="90%">#Left(event_head,25)#<cfif len(event_head) gt 25>..</cfif> </td>
					<td width="10%" align="right" style="text-align:right;">
					<a href="#request.self#?fuseaction=objects2.form_upd_event&event_id=#event_id#&action_id=#attributes.id#&action_section=PROJECT_ID;"><img src="/images/update_list.gif" border="0"  align="absmiddle"></a>
					</td>
				</tr>
			</cfoutput>
			<cfif not get_related_events.recordcount>
				<tr class="color-row" >
					<td colspan="2" height="22"><cf_get_lang dictionary_id='58486.Kayıt Bulunamadı'>!</td>
				</tr>		
			</cfif>
		</table>
	</td>
  </tr>
</table>
