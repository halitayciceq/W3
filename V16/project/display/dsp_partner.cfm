<cfinclude template="../query/get_partners.cfm">

<table width="330" align="center" cellpadding="0" cellspacing="0" border="0">
  <tr> 
    <td height="35" class="headbold"> <cf_get_lang dictionary_id='58885.Partner'></td>
  </tr>
</table>

<table cellspacing="0" cellpadding="0" width="330" bgColor="#999999" border="0" align="center">
  <tr class="color-border">
<td>
	    <table cellspacing="1" cellpadding="2" width="100%" border="0">
        <tr class="color-header" height="22"> 
    <td width="175" class="form-title">&nbsp;<cf_get_lang dictionary_id='57570.Ad Soyad'></td>
    <td width="135" class="form-title">&nbsp;<cf_get_lang dictionary_id='58820.Başlık'></td>
    <td width="20">&nbsp;</td>
  </tr>
    <cfset i=0>
  <cfoutput query="get_partners">
	  <cfset i=evaluate(i+1)>
   <tr class="color-row"> 
    <td class="label" style="cursor:pointer;" onclick="sendit(com_id#i#,name#i#,surname#i#,partnerid#i#);">&nbsp;#COMPANY_PARTNER_NAME# #COMPANY_PARTNER_SURNAME#</td>
	<input type="hidden" name="com_id#i#" id="com_id#i#" value="#COMPANY_ID#">
	<input type="hidden" name="name#i#" id="name#i#" value="#COMPANY_PARTNER_NAME#">
	<input type="hidden" name="surname#i#" id="surname#i#" value="#COMPANY_PARTNER_SURNAME#">
	<input type="hidden" name="partnerid#i#" id="partnerid#i#" value="#PARTNER_ID#">
    <td class="label">&nbsp;#TITLE#</td>
    <td><img src="/images/report.gif" width="18" height="21"></td>
  </tr>
  </cfoutput>
</table>
</td>
</tr>
</table>
<script type="text/javascript">
	function sendit(id1,id2,id3,id4){
			name=id2.value+" "+id3.value;
			window.opener.<cfoutput>#URL.form#</cfoutput>.RESPONSABLE_NAME.value=name;
			window.opener.<cfoutput>#URL.form#</cfoutput>.SEL_PARTNER_ID.value=id4.value;
			window.opener.<cfoutput>#URL.form#</cfoutput>.PARTNER_COMPANY_ID.value=id1.value;
			window.opener.<cfoutput>#URL.form#</cfoutput>.EMPLOYEE_ID.value=0;
		window.close();
		}
</script>
