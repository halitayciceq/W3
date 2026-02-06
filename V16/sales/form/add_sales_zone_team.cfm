<table cellspacing="0" cellpadding="0" border="0" width="100%" height="100%">
  <tr class="color-border">
    <td valign="top">
      <table cellspacing="1" cellpadding="2" border="0" width="100%" height="100%">
        <tr class="color-list" valign="middle">
          <td height="35">
		  	<table width="98%" align="center">
              <tr>
                <td width="48%" valign="bottom" class="headbold">Satış Takımı Ekle</td>
              </tr>
            </table>
          </td>
        </tr>
        <tr class="color-row" valign="top">
          <td>
            <table align="center" width="98%" cellpadding="0" cellspacing="0" border="0">
              <tr>
                <td colspan="2">
                  <table>
              <cfform action="#request.self#?fuseaction=settings.emptypopup_add_sales_team" method="post" name="company_cat">
                      <tr>
                        <td>Takım Adı*</td>
                        <td><cfsavecontent variable="message1">Takım Adı Girmelisiniz!</cfsavecontent>
                          <cfinput type="Text" name="team_name" style="width:200px;" maxlength="50" required="Yes" message="#message1#"></td>
                      </tr>
					  <tr>
                        <td>Satış Bölgesi*</td>
                        <td><cfsavecontent variable="message2">Satış Bölgesi Girmelisiniz!</cfsavecontent>
                          <cfinput type="Text" name="sales_zone" style="width:200px;" maxlength="50" required="Yes" message="#message2#"></td>
                      </tr>
                      <tr height="35">
                        <td>&nbsp;</td>
                        <td><cf_workcube_buttons is_upd='0'></td>
                      </tr>
                    </cfform>
                  </table>
                </td>
              </tr>
            </table>
          </td>
        </tr>
      </table>
    </td>
  </tr>
</table>
