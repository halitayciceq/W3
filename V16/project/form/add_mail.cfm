<table cellspacing="1" cellpadding="2" border="0" width="100%" height="100%" class="color-border">
    <tr class="color-list"> 
    	<td height="35" class="headbold"><cf_get_lang dictionary_id='35706.Proje Ekibine Mail Gönder'></td>
    </tr>
    <tr class="color-row" valign="top"> 
        <td> 
            <table>
                <cfform name="form_add_mail" method="post" action="#request.self#?fuseaction=project.emptypopup_add_mail&id=#url.id#" >
                <input type="Hidden" value="<cfoutput>#URL.ID#</cfoutput>" name="project_id" id="project_id">
                    <tr>   
                    	<td>&nbsp;<cf_get_lang dictionary_id='57480.Başlık'></td>
                    </tr>
                    <tr> 
                        <td>&nbsp;
                            <cfsavecontent variable="message"><cf_get_lang dictionary_id='46011.Başlık girmelisiniz'></cfsavecontent>
                            <cfinput required="Yes" message="#message#" type="text" name="mail_subject" style="width:500px;" value="" maxlength="75"  >
                        </td>
                    </tr>
                    <tr> 
                        <td>
                            <cfmodule
                                template="/fckeditor/fckeditor.cfm"
                                toolbarSet="WRKContent"
                                basePath="/fckeditor/"
                                instanceName="mail_body"
                                valign="top"
                                value=""
                                width="540"
                                height="300">
                        </td>
                    </tr>
                    <tr>
                        <td>&nbsp;<input type="checkbox" name="is_all_users" id="is_all_users" value="1">&nbsp;<cf_get_lang dictionary_id='60616.Projeye Bağlı İş Görevlilerine de Mail Gönder'></td>
                    </tr>
                    <tr align="center"> 
                        <td height="35" colspan="3" align="right" style="text-align:right;"> 
                        	<cf_workcube_buttons is_upd='0' add_function='kontrol()'>
                        </td>
                    </tr>
                </cfform>
            </table>				            
        </td>
    </tr>
</table>
<script type="text/javascript">
function kontrol()
{
x = document.form_add_mail.mail_subject.value;

if (x=="")
{
alert("<cf_get_lang dictionary_id='38347.Maile Başlık Girmediniz'>...!");
return false;		
}	
//return OnFormSubmit();
}
</script>
