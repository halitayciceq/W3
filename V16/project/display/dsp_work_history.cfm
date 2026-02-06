<cfinclude template="../query/get_work_history.cfm">
<cfparam name="attributes.page" default=1>
<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>
<cfparam name="attributes.totalrecords" default=#get_work_history.recordcount#>
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>

<table cellspacing="0" cellpadding="0" width="98%" border="0" align="center">
  <tr height="35">
    <td class="headbold"><cf_get_lang dictionary_id='38213.İş'> <cf_get_lang dictionary_id='57473.Tarihçe'>: <cfoutput>#get_work_history.WORK_HEAD# </cfoutput></td>
  </tr>
</table>
<table cellspacing="1" cellpadding="2" width="98%" align="center" border="0" class="color-border">
	<tr class="color-header">
	  <td width="20" height="22" class="form-title"><cf_get_lang dictionary_id='57487.No'></td>
	  <td width="90" class="form-title"><cf_get_lang dictionary_id='57703.Güncelleme '></td>
	  <td width="110" class="form-title"><cf_get_lang dictionary_id='57891.Güncelleyen'></td>
	  <td width="110" class="form-title"><cf_get_lang dictionary_id='57569.Görevli'></td>
	  <td class="form-title"><cf_get_lang dictionary_id='57486.Kategori'></td>
	  <td width="60" class="form-title"><cf_get_lang dictionary_id='57485.Öncelik'></td>
	  <td width="80" class="form-title"><cf_get_lang dictionary_id='57482.Aşama'></td>
	  <td width="100" class="form-title"><cf_get_lang dictionary_id='57501.Başlangıç'></td>
	  <td width="100" class="form-title"><cf_get_lang dictionary_id='57502.Bitiş'></td>
	</tr>
	<cfif not get_work_history.RecordCount>
	<tr class="color-row">
	  <td colspan="9" height="20">
		  <cf_get_lang dictionary_id='57484.Kayıt Bulunamadı'>!
	  </td>
	</tr>
<cfelse>
<cfoutput query="get_work_history" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
 <tr height="20" onMouseOver="this.className='color-light';" onMouseOut="this.className='color-row';" class="color-row">
	<td width="20" height="20" class="label">#get_work_history.CurrentRow#</td>
	<cfset upd_date = date_add('h',session.ep.TIME_ZONE,update_DATE)>
	<td class="label"> #Dateformat(upd_date,dateformat_style)# #Timeformat(upd_date,timeformat_style)# </td>
	<td class="label">
		<cfif len(get_work_history.UPDATE_AUTHOR)>
			#GET_EMP_INFO(get_work_history.UPDATE_AUTHOR,0,1)#
		</cfif>
		<cfif len(get_work_history.UPDATE_PAR)>
			#GET_PAR_INFO(get_work_history.UPDATE_PAR,0,0,1)#
		</cfif>
	</td>
	<td>
		<cfif get_work_history.PROJECT_EMP_ID neq 0 and len(get_work_history.PROJECT_EMP_ID)>
			#GET_EMP_INFO(get_work_history.PROJECT_EMP_ID,0,1)#
		</cfif>
		<cfif get_work_history.OUTSRC_PARTNER_ID neq 0 and len(get_work_history.OUTSRC_PARTNER_ID)>
			#GET_PAR_INFO(get_work_history.OUTSRC_PARTNER_ID,0,1,1)#
		</cfif>
	</td>
	<td>#WORK_CAT#</td>
	<td class="label">#PRIORITY#</td>
	<td class="label">#CURRENCY#</td>
	<cfset sdate=date_add("h",session.ep.TIME_ZONE,TARGET_START)>
	<cfset fdate=date_add("h",session.ep.TIME_ZONE,TARGET_FINISH)>
	<td class="label">#dateformat(sdate,dateformat_style)# #timeformat(sdate,timeformat_style)#</td>
	<td class="label">#dateformat(fdate,dateformat_style)# #timeformat(fdate,timeformat_style)#</td>
  </tr>
</cfoutput>
</cfif>
</table>

<cfif attributes.totalrecords gt attributes.maxrows>
  <table cellpadding="0" cellspacing="0" border="0" align="center" width="98%" height="30">
    <tr>
      <td> <cf_pages page="#attributes.page#"
				  maxrows="#attributes.maxrows#"
				  totalrecords="#attributes.totalrecords#"
				  startrow="#attributes.startrow#"
				  adres="project.popup_work_history&id=#url.id#"> </td>
      <!-- sil --><td align="right" class="label" style="text-align:right;"><cf_get_lang dictionary_id='57540.Toplam Kayıt'>:<cfoutput>#attributes.totalrecords#&nbsp;-&nbsp;<cf_get_lang dictionary_id='57581.Sayfa'>:#attributes.page#/#lastpage#</cfoutput></td><!-- sil -->
    </tr>
  </table>
</cfif>
