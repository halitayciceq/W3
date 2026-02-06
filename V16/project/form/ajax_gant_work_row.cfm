<cfsetting showdebugoutput="no">
<cfif isdefined('type1') and len(type1)>
	<cfset attributes.first_date = now()>
	<cfset attributes.last_date = date_add('d',14,attributes.first_date)>
	<cfset attributes.first_date = dateformat(attributes.first_date,dateformat_style)>
	<cfset attributes.last_date = dateformat(attributes.last_date,dateformat_style)>
</cfif>
	<cf_date tarih= 'attributes.page_target_finish'><!--- y --->
	<cf_date tarih= 'attributes.first_date'>		<!--- a --->
	<cf_date tarih= 'attributes.page_target_start'> <!--- x --->
	<cf_date tarih= 'attributes.last_date'>			<!---b --->
<table border="0" cellspacing="0" cellpadding="0" width="400">
	<tr>
	<td width="25">&nbsp;</td>
	<cfif attributes.page_target_finish lte attributes.first_date or attributes.page_target_start gte attributes.last_date>
		<td width="25" bgcolor="D1D1D1" colspan="14">&nbsp;</td>	
	<cfelseif attributes.page_target_finish gte attributes.first_date and attributes.page_target_finish lte attributes.last_date and attributes.page_target_start lt attributes.first_date>
		<cfset deger_2 = datediff('d',attributes.first_date,attributes.page_target_finish)>
			<cfloop from="1" to="#deger_2+1#" index="i">
				<td width="25" bgcolor="00CCFF" title="<cfoutput><cf_get_lang dictionary_id ='58053.Başlama Tarihi'> :#dateformat(attributes.page_target_start,dateformat_style)#  <cf_get_lang dictionary_id ='57700.Bitiş Tarihi'> :#dateformat(attributes.page_target_finish,dateformat_style)#</cfoutput>">&nbsp;</td>
			</cfloop>
			<cfset deger_2 = deger_2 + 2>
			<cfloop from="#deger_2#" to="14" index="ii">
				<td width="25" bgcolor="D1D1D1">&nbsp;</td>	
			</cfloop>
	<cfelseif attributes.page_target_finish lt attributes.last_date and attributes.page_target_finish gt attributes.first_date	and attributes.page_target_start gt attributes.first_date and attributes.page_target_start lt attributes.last_date>
				<cfset deger_3 = datediff('d',attributes.first_date,attributes.page_target_start)>
				<cfset deger_4 = datediff('d',attributes.page_target_start,attributes.page_target_finish)>
			<cfloop from="1" to="#deger_3#" index="deger_3">
				<td width="25" bgcolor="D1D1D1">&nbsp;</td>	
			</cfloop>
			<cfloop from="0" to="#deger_4#" index="n">
				<td width="25" bgcolor="00CCFF" title="<cfoutput><cf_get_lang dictionary_id ='58053.Başlama Tarihi'> :#dateformat(attributes.page_target_start,dateformat_style)#  <cf_get_lang dictionary_id ='57700.Bitiş Tarihi'> :#dateformat(attributes.page_target_finish,dateformat_style)#</cfoutput>">&nbsp;</td>	
			</cfloop>
			<cfloop from="#deger_4+deger_3+1#" to="14" index="m">
				<td width="25" bgcolor="D1D1D1">&nbsp;</td>	
			</cfloop>
	<cfelseif attributes.page_target_finish gte attributes.last_date and attributes.page_target_start lte attributes.first_date>
			<cfloop from="1" to="14" index="m">
				<td width="25" bgcolor="00CCFF" title="<cfoutput><cf_get_lang dictionary_id ='58053.Başlama Tarihi'> :#dateformat(attributes.page_target_start,dateformat_style)#  <cf_get_lang dictionary_id ='57700.Bitiş Tarihi'> :#dateformat(attributes.page_target_finish,dateformat_style)#</cfoutput>">&nbsp;</td>	
			</cfloop>
	<cfelseif attributes.page_target_finish gt attributes.last_date and attributes.page_target_start gt attributes.first_date and attributes.page_target_start lt attributes.last_date>
				<cfset deger_6 = datediff('d',attributes.first_date,attributes.page_target_start)>
				<cfset deger_7 = datediff('d',attributes.first_date,attributes.page_target_start)>
			<cfloop from="1" to="#deger_6#" index="k">
				<td width="25" bgcolor="D1D1D1">&nbsp;</td>	
			</cfloop>
			<cfset deger_6 = deger_6 + 1>
			<cfloop from="#deger_6#" to="14" index="p">
				<td width="25" bgcolor="00CCFF"  title="<cfoutput><cf_get_lang dictionary_id ='58053.Başlama Tarihi'> :#dateformat(attributes.page_target_start,dateformat_style)#  <cf_get_lang dictionary_id ='57700.Bitiş Tarihi'> :#dateformat(attributes.page_target_finish,dateformat_style)#</cfoutput>">&nbsp;</td>	
			</cfloop>
	<cfelseif attributes.page_target_start eq attributes.first_date and attributes.page_target_finish lt attributes.last_date>
			<cfset deger_8 = datediff('d',attributes.first_date,attributes.page_target_finish)>
			<cfloop from="0" to="#deger_8#" index="w">
				<td width="25" bgcolor="00CCFF" title="<cfoutput><cf_get_lang dictionary_id ='58053.Başlama Tarihi'> :#dateformat(attributes.page_target_start,dateformat_style)# <cf_get_lang dictionary_id ='57700.Bitiş Tarihi'> :#dateformat(attributes.page_target_finish,dateformat_style)#</cfoutput>">&nbsp;</td>
			</cfloop>
				<cfset deger_8 = deger_8 + 1>
			<cfloop from="#deger_8#" to="13" index="q">
					<td width="25" bgcolor="D1D1D1">&nbsp;</td>	
			</cfloop>
	<cfelseif attributes.page_target_start gt attributes.first_date and attributes.page_target_finish eq attributes.last_date and attributes.page_target_start lt attributes.last_date>
		<cfset deger_9 = datediff('d',attributes.page_target_start,attributes.page_target_finish)>
		<cfloop from="0" to="#13-deger_9#" index="w">
			<td width="25" bgcolor="D1D1D1">&nbsp;</td>
		</cfloop>
		<cfloop from="#13-deger_9#" to="13" index="q">
				<td width="25" bgcolor="00CCFF"  title="<cfoutput><cf_get_lang dictionary_id ='58053.Başlama Tarihi'> :#dateformat(attributes.page_target_start,dateformat_style)#  <cf_get_lang dictionary_id ='57700.Bitiş Tarihi'> :#dateformat(attributes.page_target_finish,dateformat_style)#</cfoutput>">&nbsp;</td>	
		</cfloop>
	</cfif>
	<td width="25" >&nbsp;</td>
	</tr>
</table>
