<cfsetting showdebugoutput="no">
<cfinclude template="../query/get_priority.cfm">
<cfquery name="get_pro_work_cat" datasource="#dsn#">
	SELECT 
		WORK_CAT,
		WORK_CAT_ID
	FROM
		PRO_WORK_CAT
	ORDER BY
		WORK_CAT
</cfquery>
<cfif len(process_rowid_list)>
	<cfquery name="GET_STAGE" datasource="#dsn#">
		SELECT 
			STAGE,
			PROCESS_ROW_ID
		FROM
			PROCESS_TYPE_ROWS
		WHERE
			PROCESS_ROW_ID IN (#process_rowid_list#)
	</cfquery>
</cfif>
<cfoutput>
<cfset new_line = new_line + 1>
<table width="100%" cellpadding="2" cellspacing="1" border="0">
<tr id="frm_row#new_line#">
	<td><input type="text" name="work_head#new_line#" id="work_head#new_line#" value="" style="width:200px" title="İş Adı"></td>
	<td>
		<input type="hidden" name="study_emp_id#new_line#" value="" id="study_emp_id#new_line#">
		<input name="study_name#new_line#" type="text" id="study_name#new_line#" style="width:150px;" title="Görevli" onFocus="AutoComplete_Create('study_name#new_line#','FULLNAME','FULLNAME','get_emp_pos','','EMPLOYEE_ID','study_emp_id#new_line#','','3','200')" value="" required="yes" autocomplete="off" >
	</td>
	<td>
		<input type="text" name="work_start#new_line#" id="work_start#new_line#" value="" style="width:65px;" title="<cf_get_lang dictionary_id='58053.Başlangıç Tarihi'>">
		<cf_wrk_date_image date_field="work_start#new_line#" date_form="add_fast_work">
		<select name="start_hour#new_line#" id="start_hour#new_line#" title="<cf_get_lang dictionary_id='30961.Başlangıç Saati'>">
			<cfloop from="0" to="23" index="i">
				<option value="#i#">#i#:00</option>
			</cfloop>
		</select>
	</td>
	<td>
		<input type="text" name="work_finish#new_line#" id="work_finish#new_line#" value="" validate="#validate_style#"  maxlength="10" style="width:70px;"  title="<cf_get_lang dictionary_id='57700.Bitiş Tarihi'>">
		<cf_wrk_date_image date_field="work_finish#new_line#" date_form="add_fast_work">
		<select name="finish_hour#new_line#" id="finish_hour#new_line#"  title="<cf_get_lang dictionary_id='51547.Bitiş Saati'>">
			<cfloop from="0" to="23" index="i">
				<option value="#i#">#i#:00</option>
			</cfloop>
		</select>
	</td>
	<td>
		<select name="priority_cat#new_line#" id="priority_cat#new_line#" style="width:70px;">
			<option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
			<cfloop query="get_cats">
				<option value="#priority_id#">#priority#</option>
			</cfloop>
		</select>
	</td>
	<td>
		<select name="work_cat#new_line#" id="work_cat#new_line#" style="width:100px;">
			<option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
			<cfloop query="get_pro_work_cat">
				<option value="#work_cat_id#">#work_cat#</option>
			</cfloop>
		</select>		
		</td>
		<td colspan="5">
		<select name="stage#new_line#" id="stage#new_line#" style="width:70px;">
			<option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
			<cfloop query="GET_STAGE">
				<option value="#PROCESS_ROW_ID#">#STAGE#</option>
			</cfloop>
		</select>
		<input type="hidden" name="related#new_line#" id="related#new_line#" value="#related_work#">
		</td>
</tr>
</table>
</cfoutput>
<script type="text/javascript">
	document.add_fast_work('last_record').value = <cfoutput>#new_line#</cfoutput>;
</script>

