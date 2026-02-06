<cfparam name="attributes.page" default=1>
<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>
<cfparam name="attributes.history_action_type" default="">
<cfparam name="attributes.startdate" default="">
<cfset contract_cmp = createObject("component","V16.sales.cfc.subscription_contract")>
<cfif isDefined("attributes.show_difference")>
    <cfset GET_SUBS_PAYPLAN_HISTORY = contract_cmp.GET_SUBS_PAYPLAN_HISTORY(
                                        subscription_id : attributes.subscription_id ,
                                        show_difference : attributes.show_difference ? : ""  )>
    <cfparam name="attributes.totalrecords" default='#GET_SUBS_PAYPLAN_HISTORY.recordcount#'> 
</cfif>
<cfif isDefined("attributes.list_detail")>
    <cf_date tarih="attributes.startdate">
    <cfset GET_SUBS_PAYPLAN_ROW_HISTORY_DETAIL = contract_cmp.GET_SUBS_PAYPLAN_ROW_HISTORY_DETAIL(
                                                    subscription_id : attributes.subscription_id ? : "",
                                                    startdate : attributes.startdate ? : "",      
                                                    list_detail : attributes.list_detail ? : "")>  
        <cfparam name="attributes.totalrecords" default='#GET_SUBS_PAYPLAN_ROW_HISTORY_DETAIL.recordcount#'> 
        <cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1> 
<cfelse>  
    <cfparam name="attributes.totalrecords" default="0"> 
    <cfset GET_SUBS_PAYPLAN_HISTORY.recordcount = 0>    
    <cfset GET_SUBS_PAYPLAN_ROW_HISTORY_DETAIL.recordcount = 0>                                                                     
</cfif>                                                                               
<cfset GET_SUBS_INFO = contract_cmp.GET_SUBS_INFO(subscription_id : attributes.subscription_id)>  
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box title="#getLang('sales','Ödeme Planı Tarihçe',41301)# : #GET_SUBS_INFO.SUBSCRIPTION_NO#" scroll="1" collapsable="1" resize="1" popup_box="#iif(isdefined("attributes.draggable"),1,0)#">
        <cfform name="list_paym_plan_history" method="post" action="#request.self#?fuseaction=sales.popup_list_subs_payment_plan_history&subscription_id=#attributes.subscription_id#">
            <cf_box_search>
                <div class="form-group" id="show_difference_name" <cfif isdefined("attributes.list_detail")>style="display:none;"</cfif>>
                    <label class="col col-12">
                        <input type="checkbox" name="show_difference" id="show_difference" onclick="select_filter();" <cfif isdefined("attributes.show_difference")>checked="checked"</cfif>><cfoutput>#getLang('','Değişenleri Göster',41355)#</cfoutput>
                    </label>
                </div>
                <div class="form-group" id="list_detail_name" <cfif isdefined("attributes.show_difference") and len(attributes.show_difference)> style= "display: none;"</cfif>>
                    <label class="col col-12">
                        <input type="checkbox" name="list_detail" id="list_detail" <cfif isdefined("attributes.list_detail")>checked="checked"</cfif> onclick="select_filter();"><cf_get_lang dictionary_id='58785.detaylı'> <cf_get_lang dictionary_id='58715.Listele'>
                    </label>
                </div>
                <div class="form-group" id="startdate_name" <cfif isdefined("attributes.show_difference") and len(attributes.show_difference)> style= "display: none;"</cfif>>
                    <div class="input-group">
                        <cfinput  type="text" name="startdate" id="startdate" value="">
                        <span class="input-group-addon"><cf_wrk_date_image date_field="startdate"> </span>
                    </div>
                </div>
                <div class="form-group small">
                    <cfinput type="text" name="maxrows" value="#attributes.maxrows#" required="yes" validate="integer" range="1,999" message="#getLang('','Kayıt sayısı hatalı',57537)#" maxlength="3">
                </div>
                <div class="form-group">
                    <cf_wrk_search_button button_type="4" search_function='kontrol()' >
                </div>
            </cf_box_search>
        </cfform>
        <cf_grid_list>
            <cfif isdefined("show_difference")>
                <thead>
                    <tr>
                        <th width="30"><cf_get_lang dictionary_id ='57487.No'></th>
                        <th><cf_get_lang dictionary_id ='41356.Ödeme Planı Yılı'></th>
                        <th><cf_get_lang dictionary_id ='41357.Önceki Tutar'></th>
                        <th><cf_get_lang dictionary_id ='41358.Sonraki Tutar'></th>
                        <th><cf_get_lang dictionary_id ='57489.Para Birimi'></th>
                        <th><cf_get_lang dictionary_id ='57574.Kampanya'></th>
                        <th><cf_get_lang dictionary_id ='57483.Kayıt'></th>
                        <th><cf_get_lang dictionary_id ='57627.Kayıt Tarihi'></th>
                    </tr>
                </thead>
                <tbody>
                    <cfif GET_SUBS_PAYPLAN_HISTORY.recordcount>
                        <cfset emp_id_list = ''>
                        <cfset camp_id_list = ''>
                        <cfoutput query="GET_SUBS_PAYPLAN_HISTORY" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
                            <cfif len(RECORD_EMP) and not listfind(emp_id_list,RECORD_EMP)>
                                <cfset emp_id_list = listappend(emp_id_list,RECORD_EMP)>
                            </cfif>
                            <cfif len(campaign_id) and not listfind(camp_id_list,campaign_id)>
                                <cfset camp_id_list = listappend(camp_id_list,campaign_id)>
                            </cfif>
                        </cfoutput> 
                        <cfif len(emp_id_list)>
                            <cfset emp_id_list = listsort(emp_id_list,"numeric","ASC",",")>
                            <cfset get_emp_detail = contract_cmp.get_emp_detail(emp_id_list : emp_id_list)> 
                        </cfif>
                        <cfif len(camp_id_list)>
                            <cfset camp_id_list = listsort(camp_id_list,"numeric","ASC",",")>
                            <cfset get_camp_detail = contract_cmp.get_camp_detail(camp_id_list : camp_id_list)> 
                        </cfif> 
                        <cfoutput query="GET_SUBS_PAYPLAN_HISTORY" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
                            <tr height="20" onMouseOver="this.className='color-light';" onMouseOut="this.className='color-row';" class="color-row">
                                <td>#currentrow#</td>
                                <td>#PAYM_PLAN_YEAR#</td>
                                <td>#TLFormat(PAYM_PLAN_TOTAL_OLD)#</td>
                                <td>#TLFormat(PAYM_PLAN_TOTAL_LAST)#</td>
                                <td>#PAYM_PLAN_MONEY_TYPE#</td>
                                <td><cfif listlen(camp_id_list)>#get_camp_detail.CAMP_HEAD[listfind(camp_id_list,campaign_id,',')]#</cfif></td>
                                <td>#get_emp_detail.EMPLOYEE_NAME[listfind(emp_id_list,RECORD_EMP,',')]# #get_emp_detail.EMPLOYEE_SURNAME[listfind(emp_id_list,RECORD_EMP,',')]#</td>
                                <td>#dateformat(RECORD_DATE,"dd\mm\yyyy")# #timeformat(RECORD_DATE,"HH:MM:SS")#</td>
                            </tr>
                        </cfoutput>
                    <cfelse>
                        <tr class="color-row" height="20">
                            <td colspan="10"><cf_get_lang dictionary_id ='57484.Kayıt Yok'></td>
                        </tr>
                    </cfif>
                </tbody>
            </cfif>
            <cfif isdefined("attributes.list_detail")><!---  detaylı listele check box seçildiğinde çalışır , degerleri satır bazlı getirir.--->
                <thead>
                    <tr>
                        <th width="30"><cf_get_lang dictionary_id ='57487.No'></th>
                        <th><cf_get_lang dictionary_id='57630.tip'></th>
                        <th><cf_get_lang dictionary_id='57899.kaydeden'></th>
                        <th><cf_get_lang dictionary_id='57627.Kayıt Tarihi'></th>
                        <th><cf_get_lang dictionary_id='57493.Aktif'></th>
                        <th><cf_get_lang dictionary_id ='57564.ürün'></th>
                        <th><cf_get_lang dictionary_id ='57673.tutar'></th>
                        <th><cf_get_lang dictionary_id ='58516.ödeme yöntemi'></th>
                        <th><cf_get_lang dictionary_id ='57635.miktar'></th>
                        <th><cf_get_lang dictionary_id ='57489.para birimi'></th>
                        <th><cf_get_lang dictionary_id ='39432.Net Tutar'></th>
                        <th><cf_get_lang dictionary_id ='58851.Ödeme Tarihi'></th>
                        <th><cf_get_lang dictionary_id ='41376.Toplu Faturalama'></th>
                        <th><cf_get_lang dictionary_id ='57295.Grup Faturalama'></th>
                    </tr>
                </thead>
                <tbody>
                    <cfif GET_SUBS_PAYPLAN_ROW_HISTORY_DETAIL.recordcount>
                        <cfoutput query="GET_SUBS_PAYPLAN_ROW_HISTORY_DETAIL" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
                            <tr>
                            <td>#currentrow#</td>
                            <cfif isdefined("HISTORY_ACTION_TYPE") and HISTORY_ACTION_TYPE eq 1><!---  kaydın eklendi bilgisini verir --->
                            <td><cf_get_lang dictionary_id ='33728.Eklendi'></td>
                            <cfelseif isdefined("HISTORY_ACTION_TYPE") and HISTORY_ACTION_TYPE eq 2> <!---  kaydın güncellendi bilgisini verir --->
                                <td><cf_get_lang dictionary_id ='29724.guncellendi'></td>
                            <cfelseif isdefined("HISTORY_ACTION_TYPE") and HISTORY_ACTION_TYPE eq 0> 
                                <td><cf_get_lang dictionary_id ='29721.silindi'></td> <!---  kaydın silindi bilgisini verir --->
                            </cfif>   
                            <cfif isdefined("HISTORY_ACTION_TYPE") and HISTORY_ACTION_TYPE eq 1 ><!--- kaydı ekleyen kişi bilgisini verir --->
                                <td>#get_emp_info(HISTORY_ACTION_EMP,0,1)#</td>
                            <cfelseif isdefined("HISTORY_ACTION_TYPE") and HISTORY_ACTION_TYPE eq 2><!--- kaydı güncelleyen kişi  bilgisini verir --->
                                <td>#get_emp_info(UPDATE_EMP,0,1)#</td>
                            <cfelseif isdefined("HISTORY_ACTION_TYPE") and HISTORY_ACTION_TYPE eq 0><!--- kaydı silen kişi  bilgisini verir --->
                                <td>#get_emp_info(HISTORY_ACTION_EMP,0,1)#</td> 
                            </cfif> 
                            <cfif isdefined("HISTORY_ACTION_TYPE") and HISTORY_ACTION_TYPE eq 1><!--- kaydın eklenen tarih bilgisini verir --->
                                <td>#dateformat(HISTORY_ACTION_DATE,"dd\mm\yyyy")#</td> 
                            <cfelseif isdefined("HISTORY_ACTION_TYPE") and HISTORY_ACTION_TYPE eq 2><!--- kaydın güncellenen tarih bilgisini verir --->
                                <td>#dateformat(UPDATE_DATE,"dd\mm\yyyy")#</td> 
                            <cfelseif isdefined("HISTORY_ACTION_TYPE") and HISTORY_ACTION_TYPE eq 0><!--- kaydın silinen tarih bilgisini verir --->
                                <td>#dateformat(HISTORY_ACTION_DATE,"dd\mm\yyyy")#</td>
                            </cfif>
                            <td><cfif len(IS_ACTIVE) and IS_ACTIVE><cf_get_lang dictionary_id ='57495.Evet'><cfelse><cf_get_lang dictionary_id ='57496.Hayır'></cfif></td>
                            <td>#get_product_name(PRODUCT_ID,0,1)#</td>
                            <td>#TLFormat(ROW_TOTAL)#</td>
                            <td>#PAYMETHOD#</td>
                            <td>#QUANTITY#</td>
                            <td>#MONEY_TYPE#</td>
                            <td>#TLFormat(ROW_NET_TOTAL)#</td>
                            <td>#dateformat(PAYMENT_DATE,"dd\mm\yyyy")#</td>
                            <td><cfif len(IS_COLLECTED_INVOICE) and IS_COLLECTED_INVOICE><cf_get_lang dictionary_id ='57495.Evet'><cfelse><cf_get_lang dictionary_id ='57496.Hayır'></cfif></td>
                            <td><cfif len(IS_GROUP_INVOICE) and IS_GROUP_INVOICE><cf_get_lang dictionary_id ='57495.Evet'><cfelse><cf_get_lang dictionary_id ='57496.Hayır'></cfif></td>
                        </tr>
                        </cfoutput>
                    <cfelse>
                        <tr height="20">
                            <td colspan="10"><cf_get_lang dictionary_id ='57484.Kayıt Yok'></td>
                        </tr>
                    </cfif>
                </tbody>
            </cfif>    
        </cf_grid_list>
        <cfif attributes.totalrecords and (attributes.totalrecords gt attributes.maxrows)>
            <cfset url_string = 'sales.popup_list_subs_payment_plan_history&subscription_id=#attributes.subscription_id#'>
            <cfif isDefined("attributes.show_difference")>
                <cfset url_string = "#url_string#&show_difference=#attributes.show_difference#">
            </cfif>
            <cfif len(attributes.startdate)>
                <cfset url_string = "#url_string#&startdate=#attributes.startdate#">
            </cfif>
            <cfif isDefined("attributes.list_detail")>
                <cfset url_string = "#url_string#&list_detail=#attributes.list_detail#">
            </cfif> 
            <cf_paging page="#attributes.page#" 
                maxrows="#attributes.maxrows#"
                totalrecords="#attributes.totalrecords#"
                startrow="#attributes.startrow#"
                adres="#url_string#">
        </cfif>
    </cf_box>
</div> 
<script language="JavaScript">
    function select_filter()
    {
        if(document.list_paym_plan_history.list_detail.checked == true)
        {
            gizle(show_difference_name);
        }
        else
        {
            goster(show_difference_name);
        }

        if(document.list_paym_plan_history.show_difference.checked == true)
        {
            gizle(list_detail_name);
            gizle(startdate_name);
        }
        else
        {
            goster(list_detail_name);
            goster(startdate_name);
        }        
    }
    function kontrol()
	{
if(document.list_paym_plan_history.show_difference.checked == false && document.list_paym_plan_history.list_detail.checked == false)
            {
                alert('<cf_get_lang dictionary_id="57526.En az bir alanda filtre ediniz">');
            return false;
            }
            else{list_paym_plan_history.submit();}
	}
</script>