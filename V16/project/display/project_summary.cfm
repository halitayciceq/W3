
<cfinclude template="../query/get_prodetail.cfm">
<cfset getComponent = createObject('component','V16.project.cfc.get_project_detail')>
<cfset GET_CAT = getComponent.GET_CAT(process_cat : project_detail.process_cat)>
<cfset get_process = getComponent.GET_PROCESS(pro_currency_id : project_detail.pro_currency_id)>
<cfif isDefined ('session.ep.time_zone')>
    <cfset simdi = dateadd ('h',session.ep.time_zone,now())>
<cfelseif isDefined ('session.pp.time_zone')>
    <cfset simdi = dateadd ('h',session.pp.time_zone,now())>
<cfelse>
    <cfset simdi = now()>
</cfif>
<cfset fark3 = datediff('n',project_detail.target_start,project_detail.target_finish)>
<cfset toplam = fark3>

<cfset fark6 = datediff('n',project_detail.target_start,simdi)>
<cfset fark = fark6>

<cfset per_cent = Round (evaluate( (fark / toplam) * 100))>
<cfif per_cent gt 100>
    <cfset per_cent = 100>
</cfif>
<cfset per_cent = Round (evaluate( (fark / toplam) * 100))>
<cfif per_cent gt 100>
    <cfset per_cent = 100>
</cfif>
<cfform name="form_basket" id="form_basket" method="post" action="#attributes.form_action#">
    <div class="ui-row">
        <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
            <div class="ui-info-text">
                <cfoutput query ="project_detail">
                    <h1>
                        <b>#get_project_name(project_detail.project_id,0)#</b>
                    </h1>
                   
                    <cfif len(project_detail)>                                                            
                        <p>
                            <cf_get_lang dictionary_id='49527.Proje Detayı'>
                            #project_detail#
                        </p>
                    </cfif> 
    
                    <cfif len(project_target)>
                        <p>
                            <cf_get_lang dictionary_id='57951.Hedef'></b>
                            #project_target#
                        </p>
                    </cfif>  
    
                    <p>
                        <cf_get_lang dictionary_id='57574.Şirket'> - <cf_get_lang dictionary_id='57578.Yetkili'>
                        <cfif len(project_detail.partner_id)>
                            <cfoutput>#get_par_info(project_detail.partner_id,0,0,1)#</cfoutput>
                        <cfelseif len(project_detail.consumer_id)>
                            <cfoutput>#get_cons_info(project_detail.consumer_id,0,1)#</cfoutput>
                        </cfif>
                    </p>
                   <p>
                        <cf_get_lang dictionary_id='33285.Proje Lideri'>
                        <cfif  len(PROJECT_EMP_ID)>
                            <a href="javascript://" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_emp_det&emp_id=#PROJECT_EMP_ID#')">#get_emp_info(project_detail.PROJECT_EMP_ID,0,0)# </a>
                        <cfelseif len(outsrc_cmp_id)>
                            <b>#get_par_info(project_detail.outsrc_partner_id,0,2,0)#</b>
                        </cfif>
                   </p>
                </cfoutput>
            </div>
            
        </div>
        <div class="col col-4 col-md-4 col-sm-4 col-xs-12">
            <table class="ajax_list ajax_list_simple">
                <tr>
                    <td><cf_get_lang dictionary_id='57486.Kategori'></td>
                    <td><cfoutput query="GET_CAT">#main_process_cat#</cfoutput></td>
                </tr>
                <tr>
                    <td><cf_get_lang dictionary_id='57482.Aşama'></td>
                    <td><cfoutput query="get_process">#stage#</cfoutput></td>
                </tr>
                <tr>
                    <td><cf_get_lang dictionary_id='57485.Öncelik'></td>
                    <td><cfoutput query="project_detail">#priority#</cfoutput> </td>
                </tr>
                <tr>
                    <td><cf_get_lang dictionary_id='58053.Başlangıç Tarihi'></td>
                    <td><!--- <cfset target_start = date_add('h',session.ep.time_zone,project_detail.target_start)> --->
                    <cfoutput>#Dateformat(project_detail.target_start,dateformat_style)# #Timeformat(project_detail.target_start,timeformat_style)#</cfoutput></td>
                </tr>
                <tr>
                    <td><cf_get_lang dictionary_id='57700.Bitiş Tarihi'></td>
                    <td><!---  <cfset target_finish = date_add('h',session.ep.time_zone,project_detail.target_finish)> --->
                        <cfoutput>#Dateformat(project_detail.target_finish,dateformat_style)# #Timeformat(project_detail.target_finish,timeformat_style)#</cfoutput></td>
                </tr>
                <tr>
                    <td><cf_get_lang dictionary_id='38144.Kalan Zaman'></td>
                    <td><div class="progress col col-11">
                            <div class="progress-bar" role="progressbar" aria-valuemin="0" aria-valuemax="100" style="background-color:#f4a688; width:<cfoutput>#per_cent#</cfoutput>%">
                             <cfif project_detail.complete_rate neq 0><cfoutput>#per_cent#</cfoutput>% <cfelseif len(per_cent)><cfoutput>#per_cent#</cfoutput>% <cfelse>0%</cfif>
                            </div>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td><cf_get_lang dictionary_id='38307.Tamamlanma'></td>
                    <td><div class="progress col col-11" style="background-color:#d5f4e6;">
                        <cfif len(project_detail.complete_rate)>
                            <div class="progress-bar" role="progressbar" aria-valuemin="0" aria-valuemax="100" style="background-color:#80ced6; width:<cfoutput>#DecimalFormat(project_detail.complete_rate)#</cfoutput>%">
                                <cfif project_detail.complete_rate neq 0><cfoutput>#DecimalFormat(project_detail.complete_rate)#</cfoutput>%<cfelse>0%</cfif>
                            </div>
                        <cfelse>
                            <div class="progress-bar" role="progressbar" aria-valuemin="0" aria-valuemax="100" style="background-color:#80ced6; width:0%">
                                <cfif project_detail.complete_rate neq 0><cfoutput>#DecimalFormat(project_detail.complete_rate)#</cfoutput>%<cfelse>0%</cfif>
                            </div>
                        </cfif>
                        </div>
                    </td>
                </tr>
            </table>        
        </div>
    </div>
</cfform>