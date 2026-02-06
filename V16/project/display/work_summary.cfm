<!---
Author :        Melek Kocabey<melekkocabey@workcube.com>
Date :          02.09.2019
Description :   Görevler event=det sayfası sol menü kısmın daki bir işin başlangıç-bitiş,görevli vs iş detaylarını getirir.
--->
<cfset getComponent = createObject('component','V16.project.cfc.get_work')>
<cfset workcube_license = createObject("V16.settings.cfc.workcube_license").get_license_information() />
<cfset work_detail = getComponent.DET_WORK(id : attributes.id)>
<cfset get_pro_cat = getComponent.GET_WORK_CAT(control_project_id:work_detail.project_id)>
<cfset get_work_cat = getComponent.GET_WORK_CAT(work_cat_id:work_detail.work_cat_id,proces_cat:iif(isdefined("get_pro_cat.process_cat") and len(get_pro_cat.process_cat),"get_pro_cat.process_cat",DE("")))>
<cfset get_activity = getComponent.GET_ACTIVITY(activity_id: work_detail.activity_id)>
<cfset get_work_priority = getComponent.get_cats(work_priority_id:work_detail.work_priority_id)>
<cfset get_work_currency = getComponent.GET_PROCESS(work_currency_id:work_detail.work_currency_id)>
<cfset get_work_groups = getComponent.GET_WORKGROUPS(workgroup_id:work_detail.workgroup_id)>
<cfset get_work_project = getComponent.GET_PROJECT(project_id:iif(isdefined("work_detail.project_id") and len(work_detail.project_id),"work_detail.project_id",DE("")))>
<cfset work_history = getComponent.GET_WORK_HISTORY()>
<cfset GET_VALUE = getComponent.GET_VALUES(id:attributes.id)><!--- bilgi verilecekler  --->
<cfif isdefined('work_detail.project_emp_id') and len(work_detail.project_emp_id)>
    <cfset employee_photo = getComponent.EMPLOYEE_PHOTO(employee_id:work_detail.project_emp_id)>
</cfif>
<cfset work_h_list = ''>
<cfif isDefined ('session.ep.time_zone')>
    <cfset simdi = dateadd ('h',session.ep.time_zone,now())>
<cfelseif isDefined ('session.pp.time_zone')>
    <cfset simdi = dateadd ('h',session.pp.time_zone,now())>
<cfelse>
    <cfset simdi = now()>
</cfif>
<cfif len(work_detail.target_start) and len(work_detail.target_start) lt 11>
    <cf_date tarih = 'work_detail.target_start' >
    <cf_date tarih = 'work_detail.terminate_date' >
</cfif>
<cfset fark3 = datediff('n',len(work_detail.target_start) ? work_detail.target_start : now(),len(work_detail.terminate_date) ? work_detail.terminate_date : work_detail.target_finish)>
<cfset toplam = fark3>
<cfset fark6 = datediff('n',(len(work_detail.target_start) ? work_detail.target_start : now()),simdi)>
<cfset fark = fark6>
<cfif toplam neq 0>
    <cfset work_cent = Round (evaluate( (fark / toplam) * 100))>
<cfelse>
    <cfset work_cent = Round (evaluate( (fark) * 100))>
</cfif>
<cfif work_cent gt 100>
    <cfset work_cent = 100>
<cfelseif work_cent lte 0>
    <cfset work_cent = 100>
</cfif>
<cfform name="work_summary" id="work_summary" method="post" action="">
    <div class="col col-12 col-md-12 col-sm-12 col-xs-12">
        <cfoutput query="work_detail">						  
            <div class="form-group">
                <div class="col col-5 col-md-7 col-xs-7 bold font-green">
                    <label><i class="fa fa-clock-o"></i> <cf_get_lang dictionary_id='60609.Termin Tarihi'></label>
                </div>
                <div class="col col-7 col-md-5 col-xs-5" id="terminate_ajx">
                    <cfif len(terminate_date)>
                        <cfset fdate_plan=dateAdd("h",session.ep.time_zone,terminate_date)>
                    <cfelse>
                        <cfset fdate_plan=''>
                    </cfif>
                    <cfif isdefined('fdate_plan') and len(fdate_plan)>
                        #dateformat(fdate_plan,dateformat_style)# #timeformat(fdate_plan,timeformat_style)#
                    </cfif>
                </div>
            </div>
            <div class="form-group">
                <div class="col col-5 col-md-7 col-xs-7 bold font-red-pink">
                    <label><i class="fa fa-clock-o"></i> <cf_get_lang dictionary_id='38144.Kalan Zaman'></label>                                    
                </div>
                <div class="col col-6 col-md-4 col-xs-4 progress" style="background:##93a6a28c; padding-right:0px; padding-left: 0px; margin-bottom: 0px;">
                    <div class="project-bar" role="progressbar" aria-valuemin="0" aria-valuemax="100"  
                    style="background-color:##ef4836;height:101%;width:#work_cent + 4#%">
                        <cfif len(work_history.to_complete) and work_history.to_complete neq 0>#(work_cent)#%<cfelseif len(work_cent)>#work_cent#
                        %<cfelse>0%</cfif>
                    </div>
                </div>
            </div>
            <div class="form-group">
                <div class="col col-5 col-md-7 col-xs-7 bold font-green-meadow">
                    <label><i class="fa fa-clock-o"></i> <cf_get_lang dictionary_id='38307.Tamamlanma'></label>
                </div>
                <div class="col col-6 col-md-4 col-xs-4 progress" style="background:##93a6a28c;margin-bottom: 0px;">
                    <div class="project-bar" role="progressbar" aria-valuemin="0" aria-valuemax="100" 
                    style="width:#work_history.to_complete#%">
                        <cfif len(work_history.to_complete) and work_history.to_complete neq 0>#(work_history.to_complete)#%<cfelse>%0 </cfif>
                    </div>
                </div>
            </div>
            <div class="form-group">
                <div class="col col-5 col-md-7 col-xs-7 bold font-blue">
                    <label><i class="fa fa-clock-o"></i> <cf_get_lang dictionary_id='57655.Başlama Tarihi'></label>
                </div>
                <div class="col col-7 col-md-5 col-xs-5">
                    <cfif len(target_start)>
                        <cfset sdate=dateAdd("h",session.ep.time_zone,TARGET_START)>
                        #dateformat(sdate,dateformat_style)# #timeformat(sdate,timeformat_style)#
                    </cfif>
                </div>
            </div>
            <div class="form-group">
                <div class="col col-5 col-md-7 col-xs-7 bold font-yellow">
                    <label><i class="fa fa-clock-o"></i> <cf_get_lang dictionary_id='57700.Bitiş Tarihi'></label>
                </div>
                <div class="col col-7 col-md-5 col-xs-5">
                    <cfif len(target_finish)>
                        <cfset fdate=dateAdd("h",session.ep.time_zone,TARGET_FINISH)>
                        <label>#dateformat(fdate,dateformat_style)# #timeformat(fdate,timeformat_style)#</label>
                    </cfif>  
                </div>
            </div>
            <div class="form-group">
                <div class="col col-5 col-md-7 col-xs-7 bold font-yellow">
                    <label><i class="fa fa-handshake-o"></i> <cf_get_lang dictionary_id='48183.Satış Fiyatı'></label>
                </div>
                <div class="col col-7 col-md-5 col-xs-5">
                    <label>#tlformat(AVERAGE_AMOUNT)# #UNIT# x #tlformat(SALE_CONTRACT_AMOUNT)# #EXPECTED_BUDGET_MONEY#</label>
                </div>
            </div>
            <div class="form-group">
                <div class="col col-5 col-md-7 col-xs-7 bold font-yellow">
                    <label><i class="fa fa-money"></i> <cf_get_lang dictionary_id='57492.Toplam'><cf_get_lang dictionary_id='57559.Bütçe'></label>
                </div>
                <div class="col col-7 col-md-5 col-xs-5">
                    <label>#tlformat(EXPECTED_BUDGET)# #EXPECTED_BUDGET_MONEY#</label>
                </div>
            </div>
            <div class="form-group">
                <div class="col col-5 col-md-7 col-xs-7 bold font-purple">
                    <label><i class="fa fa-clock-o"></i> <cf_get_lang dictionary_id='38148.Harcanan Zaman'></label>                
                </div>
                <div class="col col-7 col-md-5 col-xs-5">
                    <cfif len(work_detail.harcanan_dakika)>
                            <cfset harcanan_ = work_detail.HARCANAN_DAKIKA>
                            <cfset liste=harcanan_/60>
                            <cfset saat=listfirst(liste,'.')>
                            <cfset dak=harcanan_-saat*60>
                            <label>#saat# saat #dak# dk</label>
                        <cfelse>
                        <label> 0 saat 0 dk </label>                 	
                    </cfif>
                </div>
            </div>
            <div class="form-group">
                <cfif project_emp_id neq 0 and len(project_emp_id)>
                    <cfset person="#get_emp_info(project_emp_id,0,0)#">
                <cfelseif outsrc_partner_id neq 0 and len(outsrc_partner_id)>
                    <cfset person="#get_par_info(outsrc_partner_id,0,2,0)#">
                <cfelse>
                    <cfset person="">
                </cfif>
                <div class="col col-5 col-md-7 col-xs-7 bold font-red">
                    <label><i class="fa fa-user"></i> <a href="javascript://" onclick="nModal({head: 'Profil',page:'index.cfm?fuseaction=objects.popup_emp_det&emp_id=#project_emp_id#'});" class="bold font-red"> <cf_get_lang dictionary_id='57569.Görevli'></a></label>
                </div>
                <div class="col col-7 col-md-5 col-xs-5" id="emp_ajx">
                    #person#
                </div>
            </div>
            <cfif isDefined("employee_photo.POSITION") and len(employee_photo.POSITION)>
                <div class="form-group">
                    <div class="col col-5 col-md-7 col-xs-7 bold font-blue">
                        <label><i class="fa fa-star"></i> <cf_get_lang dictionary_id='58497.Pozisyon'></label>
                    </div>
                    <div class="col col-7 col-md-5 col-xs-5">
                        #employee_photo.POSITION#							
                    </div>
                </div>
            </cfif>
            <cfif len(work_cat_id)>
                <div class="form-group">                        
                    <div class="col col-5 col-md-7 col-xs-7 font-yellow-gold bold">
                        <label><i class="fa fa-briefcase"> </i> <cf_get_lang dictionary_id='38177.İş Kategorisi'>
                    </div>
                    <div class="col col-7 col-md-5 col-xs-5">
                        #get_work_cat.work_cat#</label>						
                    </div>
                </div>
            </cfif>
            <cfif len(ACTIVITY_ID)>
                <div class="form-group">
                    <div class="col col-5 col-md-7 col-xs-7 font-green-meadow bold">
                        <label><i class="fa fa-cubes"> </i> <cf_get_lang dictionary_id='38378.Aktivite Tipi'>
                    </div>
                    <div class="col col-7 col-md-5 col-xs-5">
                        <cfoutput>#get_activity.ACTIVITY_NAME#</cfoutput></label>
                    </div>
                </div>
            </cfif>
            <cfif isDefined("get_work_priority.PRIORITY") and len(get_work_priority.PRIORITY)>
                <div class="form-group">
                    <div class="col col-5 col-md-7 col-xs-7 font-red-pink bold">
                        <label><i class="fa fa-sort-amount-asc "> </i> <cf_get_lang dictionary_id='57485.Öncelik'></label>
                    </div>
                    <div class="col col-7 col-md-5 col-xs-5">
                        #get_work_priority.PRIORITY#				
                    </div>
                </div>
            </cfif>
            <cfif isdefined("get_work_currency.stage") and len(get_work_currency.stage)>
                <div class="form-group">
                    <div class="col col-5 col-md-7 col-xs-7 font-yellow bold">
                        <label><i class="fa fa-tree"> </i> <cf_get_lang dictionary_id="58859.Süreç"></label>                              
                    </div>
                    <div class="col col-7 col-md-5 col-xs-5" id="stage_ajx">
                        #get_work_currency.stage#						
                    </div>
                </div>
            </cfif>
            <cfif len(workgroup_id)>
                <div class="form-group">
                    <div class="col col-5 col-md-7 col-xs-7 bold font-blue">
                        <label><i class="fa fa-group"> </i> <cf_get_lang dictionary_id='58140.İş Grubu'></label>
                    </div>
                    <div class="col col-7 col-md-5 col-xs-5">
                        #get_work_groups.workgroup_name#							
                    </div>
                </div>
            </cfif>
            <div class="form-group">
                <div class="col col-5 col-md-7 col-xs-7 desc bold font-purple">
                    <label><i class="icons8-organization"> </i><cf_get_lang dictionary_id='57416.Proje'></label>
                </div>
                <div class="col col-7 col-md-5 col-xs-5">
                    <cfif isDefined("project_id") and len(project_id)>
                        <a href="#request.self#?fuseaction=project.projects&event=det&id=#project_id#" target="_blank" class="desc bold font-purple">#get_work_project.project_head#</a>
                    <cfelse>
                        <cf_get_lang dictionary_id='58459.projesiz'>
                    </cfif>
                </div>
            </div>
            <cfif len(company_id) and len(company_partner_id) or (not len(company_id) and len(consumer_id))>
                <div class="form-group">
                    <div class="col col-5 col-md-7 col-xs-7 font-green-meadow bold">
                        <label><i class="fa fa-address-book-o"> </i> <cf_get_lang dictionary_id='57574.Şirket'> - <cf_get_lang dictionary_id='57578.Yetkili'></label>
                    </div>
                    <div class="col col-7 col-md-5 col-xs-5">
                        <input type="hidden" name="company_partner_id" id="company_partner_id" value="<cfif len(company_partner_id)>#company_partner_id#<cfelseif len(consumer_id)>#consumer_id#</cfif>">
                        <input type="hidden" name="company_id" id="company_id" value="<cfif len(company_id)>#company_id#</cfif>">
                        <cfif len(company_id) and len(company_partner_id)>
                            <cfset attributes.partner_id = company_partner_id>
                            <cfinclude template="../query/get_partner_name.cfm">#get_par_info(company_partner_id,0,0,0)#
                        <cfelseif not len(company_id) and len(consumer_id)>
                            <cfset attributes.consumer_id = consumer_id>
                            <cfinclude template="../query/get_consumer_name.cfm">#get_consumer_name.company#
                        </cfif>
                    </div>
                </div> 
            </cfif>   
            <cfif  (WORK_FUSEACTION DOES NOT CONTAIN 'emptypopup')> 
                <div class="form-group">
                    <div class="col col-5 col-md-7 col-xs-7 desc bold font-purple">
                        <label><i class="catalyst-link"> </i>Workfuse</label>
                    </div>
                    <div class="col col-7 col-md-5 col-xs-5">
                        <cfquery name="get_woid" datasource="#dsn#">
                            SELECT WRK_OBJECTS_ID FROM WRK_OBJECTS WHERE FULL_FUSEACTION LIKE  <cfqueryparam cfsqltype="cf_sql_varchar" value="#WORK_CIRCUIT#.#WORK_FUSEACTION#">
                        </cfquery>
                        <cfif len(workcube_license.implementation_project_domain)>
                            <cfoutput><a href="#workcube_license.implementation_project_domain#/index.cfm?fuseaction=dev.wo&event=upd&fuseact=#WORK_CIRCUIT#.#WORK_FUSEACTION#&woid=#get_woid.WRK_OBJECTS_ID#&Works" target="_blank">#WORK_CIRCUIT#.#WORK_FUSEACTION#</a></cfoutput>
                        <cfelse>
                            <cfoutput><a href="#request.self#?fuseaction=dev.wo&event=upd&fuseact=#WORK_CIRCUIT#.#WORK_FUSEACTION#&woid=#get_woid.WRK_OBJECTS_ID#&Works" target="_blank">#WORK_CIRCUIT#.#WORK_FUSEACTION#</a></cfoutput>
                        </cfif>
                        
                    </div>
                </div> 
            </cfif>         
        </cfoutput>
    </div>
</cfform>