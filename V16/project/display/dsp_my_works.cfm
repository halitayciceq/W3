<table cellspacing="0" cellpadding="0" width="100%" border="0">
	<cfquery name="GET_WORKS" datasource="#dsn#">
		SELECT 
			PW.WORK_HEAD,
			PW.WORK_ID,		
			PW.TARGET_FINISH,
			PW.WORK_PRIORITY_ID,
			SP.COLOR,
			SP.PRIORITY
		FROM 
			PRO_WORKS PW,
			SETUP_PRIORITY SP
		WHERE 
			PW.WORK_STATUS=1 AND
			PW.OUTSRC_PARTNER_ID = #session.pp.userid# AND
			PW.WORK_PRIORITY_ID=SP.PRIORITY_ID
		ORDER BY 
			PW.RECORD_DATE	DESC		
	</cfquery>
	<cfif GET_WORKS.recordcount>
	<cfset project_stage_list = "">
	<cfoutput query="GET_WORKS">
		<cfif len(work_currency_id) and not listfind(project_stage_list,work_currency_id)>
			<cfset project_stage_list=listappend(project_stage_list,work_currency_id)>
		</cfif>
	</cfoutput>
	<cfif len(project_stage_list)>
		<cfset project_stage_list = listsort(project_stage_list,'numeric','ASC',',')>
		<cfquery name="get_currency_name" datasource="#dsn#">
			SELECT PROCESS_ROW_ID,STAGE FROM PROCESS_TYPE_ROWS WHERE PROCESS_ROW_ID IN (#project_stage_list#) ORDER BY PROCESS_ROW_ID
		</cfquery>
	</cfif>
	<cfoutput query="GET_WORKS">
		<tr height="20" onMouseOver="this.className='color-light';" onMouseOut="this.className='color-row';" class="color-row">
			<td align="left" width="3%">*&nbsp;</td>
			<td align="left" width="57%"><a href="#request.self#?fuseaction=objects2.works&event=upd&work_id=#" class="tableyazi">#GET_WORKS.WORK_HEAD#</a></td>
			<td width="20%">#get_currency_name.stage[listfind(project_stage_list,work_currency_id,',')]#</td>
			<td width="20%"><font color="#GET_WORKS.COLOR#">#GET_WORKS.PRIORITY#</font></td>	
			<td width="20%" align="right" style="text-align:right;"><b><cf_get_lang dictionary_id ='57502.Bitiş'> </b>:#dateformat(GET_WORKS.TARGET_FINISH,dateformat_style)#</td>														
		</tr>
	</cfoutput>
	<cfelse>
		<tr><td><cf_get_lang dictionary_id ='57484.Kayıt Bulunamadı'>!</td></tr>
	</cfif>
</table>
