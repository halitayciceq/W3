

<cfinclude template="../query/get_offer_list.cfm">
<cfinclude template="../query/get_commethod.cfm">
<cfinclude template="../query/get_offer_currencies.cfm">
<cfparam name="attributes.page" default=1>
<cfparam name="attributes.modal_id" default="">
<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.totalrecords" default=#get_offer_list.recordcount#>
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>

<cfset url_string = "">
<cfif isdefined("attributes.opp_id")>
	<cfset url_string = "#url_string#&opp_id=#attributes.opp_id#">
</cfif>
<cfif isdefined("attributes.offer_status_cat_id") and len(attributes.offer_status_cat_id)>
	<cfset url_string = "#url_string#&offer_status_cat_id=#attributes.offer_status_cat_id#">
</cfif>

<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box title="#getLang('','Teklifler',40806)#" scroll="1" closable="1" collapsable="1" resize="0" popup_box="#iif(isdefined("attributes.draggable"),1,0)#">
        <cfform name="offers" id="offers" action="#request.self#?fuseaction=sales.popup_list_offer&opp_id=#attributes.opp_id#" method="post">
            <input type="hidden" name="purchase_" id="purchase" value="<cfif isdefined("attributes.purchase_")><cfoutput>#attributes.purchase_#</cfoutput></cfif>" >
            <cf_box_search>
                <div class="form-group" id="item-keyword">
                    <cfinput type="text" name="keyword" style="width:100px;" placeholder="#getLang('','Filtre',57460)#" value="#attributes.keyword#" maxlength="255">
                </div>
                <div class="form-group" id="item-keyword">
                    <select name="filter_cat" id="filter_cat">
                        <option value="" selected><cf_get_lang dictionary_id='57486.kategori'></option>
                        <option value="1"><cf_get_lang dictionary_id='29406.bireysel üyeler'></option>
                        <option value="2"><cf_get_lang dictionary_id='29408.kurumsal üyeler'></option>
                        <option value="3"><cf_get_lang dictionary_id='40899.pot bireysel'></option>
                        <option value="4"><cf_get_lang dictionary_id='40900.pot kurumsal'></option>
                    </select>
                </div>
                <div class="form-group" id="item-keyword">
                    <select name="offer_status_cat_id" id="offer_status_cat_id" style="width:130px;">
                        <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                        <option value="-1" <cfif isDefined('attributes.offer_status_cat_id') and attributes.offer_status_cat_id eq -1>selected</cfif>><cf_get_lang dictionary_id='57673.acik'></option>
                        <option value="-2" <cfif isDefined('attributes.offer_status_cat_id') and attributes.offer_status_cat_id eq -2>selected</cfif>><cf_get_lang dictionary_id='40836.tamam'></option>
                        <option value="-3" <cfif isDefined('attributes.offer_status_cat_id') and attributes.offer_status_cat_id eq -3>selected</cfif>><cf_get_lang dictionary_id='29537.red'></option>
                        <option value="-4" <cfif isDefined('attributes.offer_status_cat_id') and attributes.offer_status_cat_id eq -4>selected</cfif>><cf_get_lang dictionary_id='57615.onay bekliyor'></option>
                        <cfoutput query="get_offer_currencies"> 
                            <option value="#offer_currency_id#" <cfif isDefined('attributes.offer_status_cat_id') and attributes.offer_status_cat_id eq offer_currency_id>selected</cfif>>#OFFER_CURRENCY#</option>
                        </cfoutput> 
                    </select>
                </div>
                <div class="form-group small" id="item-keyword">
                    <cfinput type="text" name="maxrows" value="#attributes.maxrows#" required="yes" validate="integer" range="1,999" message="#getLang('','Kayıt Sayısı Hatalı',57537)#" maxlength="3" style="width:25px;">
                </div>
                <div class="form-group" id="item-keyword">
                    <cf_wrk_search_button button_type="4" search_function="#iif(isdefined("attributes.draggable"),DE("loadPopupBox('offers' , #attributes.modal_id#)"),DE(""))#">
                </div>
            </cf_box_search>
        </cfform>
        <cf_grid_list>
            <thead>        
                <tr>
                    <th width="30"><cf_get_lang dictionary_id='57487.no'></th>
                    <th width="60"><cf_get_lang dictionary_id='57742.tarih'></th>
                    <th><cf_get_lang dictionary_id='57480.Başlık'></th>
                    <th width="120"><cf_get_lang dictionary_id='57574.şirket'>-<cf_get_lang dictionary_id='57578.yetkili'></th>
                    <th width="100"><cf_get_lang dictionary_id='57673.tutar'></th>
                    <th width="60"><cf_get_lang dictionary_id='57482.Aşama'></th>
                    <th width="60"><cf_get_lang dictionary_id='29472.yontem'></th>
                    <th width="100"><cf_get_lang dictionary_id='40842.satis ekibi'></th>
                </tr>
            </thead>
            <tbody>
                <cfif get_offer_list.recordcount>
                    <cfoutput query="get_offer_list" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#"> 
                    <tr onclick="gonder('#offer_id#');" style="cursor:pointer;">
                        <td>#offer_number#</td>
                        <td>#dateformat(offer_date,dateformat_style)#<!--- #dateformat(date_add('h',session.ep.time_zone,record_date),dateformat_style)# ---></td>
                        <td>#offer_head#</td>
                        <td>
                            <cfif len(consumer_id)>
                                #get_cons_info(consumer_id,1,0)#
                            <cfelseif len(listsort(offer_to_partner,'numeric'))>
                                <cfset attributes.partner_id = listsort(offer_to_partner,'numeric')>
                                #get_par_info(attributes.partner_id ,0,0,0)#
                            </cfif></td>
                        <td style="text-align:right;">#TLFormat(price)#</td>
                        <td> 
                        <cfif OFFER_STATUS is 1>
                        <cf_get_lang dictionary_id='57493.aktif'> 
                        <cfelse>
                        <cf_get_lang dictionary_id='57494.pasif'> 
                        </cfif>
                        </td>
                        <td> 
                        <cfloop from="1" to="#get_commethod.recordcount#" index="i">
                            <cfif COMMETHOD_ID is get_commethod.commethod_id[i]>
                            #get_commethod.COMMETHOD# 
                            </cfif>
                        </cfloop></td>
                        <td> 
                            <cfif offer_zone eq 0>
                                <cfset attributes.employee_id = record_member>#get_emp_info(record_member,0,0)#
                            <cfelseif offer_zone eq 1>#get_par_info(record_member,0,-1,0)#
                            </cfif>
                        </td>
                    </tr>
                    </cfoutput> 
                <cfelse>
                    <tr> 
                    <td colspan="8"><cf_get_lang dictionary_id='57484.Kayıt Yok'> !</td>
                    </tr>
                </cfif>
            </tbody>
        </cf_grid_list>
        <cfif attributes.totalrecords gte attributes.maxrows>
            <cf_paging page="#attributes.page#"
                maxrows="#attributes.maxrows#"
                totalrecords="#attributes.totalrecords#"
                startrow="#attributes.startrow#"
                adres="sales.popup_list_offer#url_string#"
                isAjax="#iif(isdefined("attributes.draggable"),1,0)#"> 
        </cfif>
    </cf_box>
</div>
<script type="text/javascript">
	function gonder(offer_id)
	{
        var purchase_ = document.getElementById("purchase").value
		openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=sales.emptypopup_add_offer_opp&opp_id=<cfoutput>#attributes.opp_id#</cfoutput>&purchase_='+purchase_+'&offer_id=' + offer_id, <cfoutput>#attributes.modal_id#</cfoutput>) ;
	}
</script>
