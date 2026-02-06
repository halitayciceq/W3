<cfsetting showdebugoutput="no">
<cfif isdefined("attributes.type") and isdefined("attributes.gelen_date")>
<cf_date tarih="attributes.gelen_date">
	<cfif attributes.type is 'pre'>
		<cfset attributes.first_date = date_add('d',-14,attributes.gelen_date)>
		<cfset attributes.last_date = attributes.gelen_date>
	<cfelse>
		<cfset attributes.first_date = attributes.gelen_date>
		<cfset attributes.last_date = date_add('d',14,attributes.gelen_date)>
	</cfif>
<cfelse>
	<cfset attributes.first_date = now()>
	<cfset attributes.last_date = date_add('d',14,attributes.first_date)>
</cfif>
<cfoutput>
<table border="1" cellspacing="0" cellpadding="0" width="400">
		<tr>
			<td width="25"><a href="javascript://" onclick="ajax_gant_load('pre','#dateformat(attributes.first_date,dateformat_style)#');"><img src="/images/previous20.gif" border="0"></a></td>
			<td colspan="7" class="form-title">#dateformat(attributes.first_date,dateformat_style)#</td>
			<td colspan="7" align="right" class="form-title" style="text-align:right;">#dateformat(attributes.last_date,dateformat_style)#</td>
			<td width="25"><a href="javascript://" onclick="ajax_gant_load('next','#dateformat(attributes.last_date,dateformat_style)#');"><img src="/images/next20.gif" border="0"></a></td>
		</tr>
		<tr align="center">
			<td width="25">&nbsp;</td>
			<td width="25" class="form-title" title="<cfoutput>#dateformat(attributes.first_date,dateformat_style)#</cfoutput>">Pz</td>
			<td width="25" class="form-title" title="<cfoutput>#dateformat(date_add('d',1,attributes.first_date),dateformat_style)#</cfoutput>">S</td>
			<td width="25" class="form-title" title="<cfoutput>#dateformat(date_add('d',2,attributes.first_date),dateformat_style)#</cfoutput>">Ç</td>
			<td width="25" class="form-title" title="<cfoutput>#dateformat(date_add('d',3,attributes.first_date),dateformat_style)#</cfoutput>">P</td>
			<td width="25" class="form-title" title="<cfoutput>#dateformat(date_add('d',4,attributes.first_date),dateformat_style)#</cfoutput>">C</td>
			<td width="25" class="form-title" title="<cfoutput>#dateformat(date_add('d',5,attributes.first_date),dateformat_style)#</cfoutput>">Ct</td>
			<td width="25" class="form-title" title="<cfoutput>#dateformat(date_add('d',6,attributes.first_date),dateformat_style)#</cfoutput>">P</td>
			<td width="25" class="form-title" title="<cfoutput>#dateformat(date_add('d',7,attributes.first_date),dateformat_style)#</cfoutput>">Pz</td>
			<td width="25" class="form-title" title="<cfoutput>#dateformat(date_add('d',8,attributes.first_date),dateformat_style)#</cfoutput>">S</td>
			<td width="25" class="form-title" title="<cfoutput>#dateformat(date_add('d',9,attributes.first_date),dateformat_style)#</cfoutput>">Ç</td>
			<td width="25" class="form-title" title="<cfoutput>#dateformat(date_add('d',10,attributes.first_date),dateformat_style)#</cfoutput>">P</td>
			<td width="25" class="form-title" title="<cfoutput>#dateformat(date_add('d',11,attributes.first_date),dateformat_style)#</cfoutput>">C</td>
			<td width="25" class="form-title" title="<cfoutput>#dateformat(date_add('d',12,attributes.first_date),dateformat_style)#</cfoutput>">Ct</td>
			<td width="25" class="form-title" title="<cfoutput>#dateformat(date_add('d',13,attributes.first_date),dateformat_style)#</cfoutput>">P</td>
			<td width="25">&nbsp;</td>
		</tr>
</table>
<cfset attributes.first_date = dateformat(attributes.first_date,dateformat_style)>
<cfset attributes.last_date = dateformat(attributes.last_date,dateformat_style)>
</cfoutput>
<cfloop from="1" to="#gant_sayac_#" index="xx">
 	<script type="text/javascript">
		var page_target_start = document.getElementById('work_start'+<cfoutput>#xx#</cfoutput>).value;
		var page_target_finish = document.getElementById('work_finish'+<cfoutput>#xx#</cfoutput>).value;
		AjaxPageLoad('<cfoutput>#request.self#?fuseaction=project.emptypopup_gant_work_row&page_target_finish='+page_target_finish+'&page_target_start='+page_target_start+'&project_id=#project_id#&first_date=#attributes.first_date#&last_date=#attributes.last_date#','gant_work_row#xx#</cfoutput>','1','Lütfen Bekleyin');
	</script>
</cfloop>
