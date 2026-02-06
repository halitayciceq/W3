<cfinclude template="../query/get_pro_works.cfm">
<table width="330" align="center" cellpadding="0" cellspacing="0" border="0">
    <tr> 
        <td height="35" class="headbold"><cf_get_lang dictionary_id='34987.Projeye Bağlı İşler'></td>
    </tr>
</table>   
<table cellSpacing="0" cellpadding="0" width="330" bgColor="#999999" border="0" align="center">
    <tr class="color-border">
        <td> 	
            <table cellspacing="1" cellpadding="2" width="100%" border="0">
                <tr class="color-header" height="22"> 
                    <td class="form-title">&nbsp;<cf_get_lang dictionary_id='58445.İş'></td>
                    <td class="form-title">&nbsp;<cf_get_lang dictionary_id='57569.Görevli'></td>
                </tr>
                <cfoutput query="get_pro_works"> 
                    <tr class="color-row"> 
                        <td class="label">&nbsp;#get_pro_works.WORK_HEAD#</td>
                        <td class="label">
                        <cfif get_pro_works.POSITION_CODE neq 0 and len(get_pro_works.POSITION_CODE)>
                            &nbsp;#GET_EMP_INFO(get_pro_works.POSITION_CODE,1,0)#
                        </cfif>
                        <cfif get_pro_works.OUTSRC_PARTNER_ID neq 0 and len(get_pro_works.OUTSRC_PARTNER_ID)>
                            &nbsp;#GET_PAR_INFO(get_pro_works.OUTSRC_PARTNER_ID,0,0,0)#
                        </cfif>
                        </td>
                    </tr>
                </cfoutput> 
                <tr class="color-list"> 
                    <td colspan="2" class="label">&nbsp;<font color=red><cf_get_lang dictionary_id='34988.Sil seçtiğinizde bağlı tüm işler silinecektir'>.</font></td>
                </tr>
                <tr class="color-list"> 
                    <td colspan="2" align="right" style="text-align:right;">
                    <cf_workcube_buttons is_upd='1' delete_page_url='#request.self#?fuseaction=project.delpro_act&ID=#URL.ID#'></td>
                </tr>
            </table>
        </td>
    </tr>
</table>
