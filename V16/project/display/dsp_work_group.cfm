<script type="text/javascript">
	function senit()
	{
		
	}
</script>
<cfquery name="GET_PRO_DATE" datasource="#dsn#">
	SELECT
		TARGET_START,
		TARGET_FINISH
	FROM
		PRO_PROJECTS
	WHERE
		PROJECT_ID = #URL.ID#
</cfquery>
<cfoutput query="get_pro_date">
	<cfset sdate=TARGET_START>
	<cfset fdate=TARGET_FINISH>
</cfoutput>
<cfquery name="GET_RIGHT_WORKS" datasource="#dsn#">
	SELECT
		*
	FROM
		PRO_WORKS
	WHERE
		PROJECT_ID=1
	AND
		TARGET_START > '#SDATE#'
	AND
		TARGET_FINISH < '#FDATE#'
		
</cfquery>
<table width="330" align="center" cellpadding="0" cellspacing="0" border="0">
  <tr> 
    <td height="35" class="headbold"><cf_get_lang dictionary_id='34699.Seçilebilir İşler'></td>
  </tr>
</table>
  <table cellSpacing="0" cellpadding="0" width="330" bgColor="#999999" border="0" align="center">
    <tr class="color-border">
<td> 
  <cfform name="add_works" action="#request.self#?fuseaction=project.add_work_group&ID=#URL.ID#&row=#get_right_works.recordcount#">
 <table cellspacing="1" cellpadding="2" width="100%" border="0">
      <tr class="color-header" height="22"> 
      <td class="form-title">&nbsp;<cf_get_lang dictionary_id='35001.İş Adı'></td>
      <td class="form-title">&nbsp;<cf_get_lang dictionary_id='57501.Başlangıç'></td>
      <td colspan="2" class="form-title">&nbsp;<cf_get_lang dictionary_id='57502.Bitiş'></td>
    </tr>
    <cfset i=0>
    <cfoutput query="get_right_works"> 
      <cfset i=evaluate(i+1)>
      <tr class="color-row"> 
        <td class="label">&nbsp;#WORK_HEAD#</td>
        <input type="hidden" name="work_id#i#" id="work_id#i#" value="#WORK_ID#">
        <td class="label">&nbsp;#dateformat(TARGET_START,dateformat_style)#</td>
        <td class="label">&nbsp;#dateformat(TARGET_FINISH,dateformat_style)#</td>
        <td class="label"> 
          <input type="Checkbox" name="chk#i#" id="chk#i#" value="">
        </td>
      </tr>
    </cfoutput> 
    <tr class="color-list"> 
      <td align="right" colspan="4"> 
	 	 <cf_workcube_buttons is_upd='0'>
      </td>
    </tr>
  </table>

</td>
</tr>
</table>
</cfform>
