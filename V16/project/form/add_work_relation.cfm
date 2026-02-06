<cfquery name="GET_PRO_WORKS" datasource="#DSN#">
	SELECT
		WORK_HEAD,
		WORK_ID,
		TARGET_START,
		STARTDATE_PLAN,
		FINISHDATE_PLAN
	FROM
		PRO_WORKS
	WHERE
		<cfif isdefined("attributes.pro_id") and len(attributes.pro_id)>
		PROJECT_ID = #attributes.pro_id#

		<cfelse>
		1=0
		</cfif>
		<cfif isdefined("attributes.work_id") and len(attributes.work_id)>
		AND WORK_ID <> #attributes.work_id#
		</cfif>
</cfquery>

<table cellspacing="0" cellpadding="0" border="0" width="98%" align="center">
	<tr>
		<td height="35" class="headbold" colspan="2"><cf_get_lang dictionary_id='38226.İş İlişkisi Belirle'></td>
	</tr>
</table>
	  
<table width="98%" cellpadding="2" cellspacing="1" border="0" class="color-border" align="center">
<form name="relation">		
	<tr class="color-header" height="22">
		<td class="form-title"><cf_get_lang dictionary_id='57480.Başlık'></td>
		<td width="75" class="form-title"><cf_get_lang dictionary_id='58053.Başlama'></td>
	</tr>
  <cfoutput query="get_pro_works">
  	<cfset my_work_head = replace(work_head,"'","","all")>
    <cfset my_work_head = replace(my_work_head,'"','',"all")>
	<cfset startDate =  dateformat(startdate_plan,dateformat_style)>
	<cfset finishDate =  dateformat(finishdate_plan,dateformat_style)>
	<tr class="color-row">
		<td><a href="javascript://" class="tableyazi" onclick="sendit('#work_id#','#my_work_head#','#startDate#','#finishDate#');">#work_head#</a></td>
		<td>#dateformat(date_add('h',session.ep.time_zone,target_start),dateformat_style)# #timeformat(date_add('h',session.ep.time_zone,target_start),timeformat_style)#</td>
	</tr>
  </cfoutput>
	<tr class="color-row">
		<td height="30" colspan="2" align="right" style="text-align:right;">
	  		<input type="button" name="<cf_get_lang dictionary_id='57553.Kapat'>" id="<cf_get_lang dictionary_id='57553.Kapat'>" value="Kapat" onClick="window.close();" style="width:65px;">
		</td>
	</tr>
</form>
</table>
<script type="text/javascript">
function sendit(work_id,work_name,start_date,finish_date)
{
	opener.<cfoutput>#w_id#</cfoutput>.value = work_id;
	opener.<cfoutput>#w_name#</cfoutput>.value = work_name;
	if(start_date != undefined)
		opener.<cfoutput>#start_date#</cfoutput>.value = start_date;
	if(finish_date != undefined)
		opener.<cfoutput>#finish_date#</cfoutput>.value = finish_date;
	window.close();
}
</script>

