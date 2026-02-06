<cfsetting showdebugoutput="no"> 
<cfinclude template="../query/get_work_history.cfm">
<cfinclude template="../query/get_work.cfm">
<cfquery name="get_activity" datasource="#dsn#">
	SELECT ACTIVITY_ID, ACTIVITY_NAME FROM SETUP_ACTIVITY WHERE ACTIVITY_STATUS = 1
</cfquery>
<cfset getComponent = createObject('component','V16.project.cfc.get_work')>
<cfset GET_VALUE = getComponent.GET_VALUES(id:attributes.id)>
<cfset upload_folder=application.systemParam.systemParam().upload_folder>
<cfset get_work_history=getComponent.GET_WORK_HISTORY()>
<cfif get_work_history.recordcount>
    <div class="ui-info-text">
        <h1><cfoutput>#URLDecode(URLEncodedFormat(get_work_history.work_head))#</cfoutput></h1>
        <cfoutput query="get_work_history">
            <div class="ui-retweet">
                <cfset work_detail_ = replace(work_detail,'<form','<fform','all')>
                <cfset work_detail_ = replace(work_detail_,'</form','</fform','all')>    
                <cfset work_detail_ = reReplace(work_detail_, 'padding-bottom:\s*[\d\.]+(?:px|%);', 'padding-bottom: 0px;', 'all')>
                <cfset work_detail_ = replace(work_detail_,'<invalidTag','<iframe','all')>
                <cfset work_detail_ = replace(work_detail_,'</invalidTag','</iframe','all')>
                <p>#work_detail_#</p>
                
            </div>
            <div class="ui-customTooltip">
                <ul>
                    <!---  <span class="font-red-mint"><cf_get_lang dictionary_id='479.Güncelleyen'> :</span> --->
                        <cfif len(get_work_history.update_author)>
                            <cfset GET_EMP_LIST = getComponent.GET_EMP_LIST(int_emp_list : get_work_history.update_author)>
                            <cfif GET_EMP_LIST.recordcount eq 0>
                                <cfset GET_EMP_LIST = getComponent.PARTNER_PHOTO(partner_id : get_work_history.update_author)>
                            </cfif>
                            <cfif len(GET_EMP_LIST.PHOTO) and fileExists("#upload_folder#member/#GET_EMP_LIST.PHOTO#")>
                                <cfset emp_photo ='documents/member/#GET_EMP_LIST.PHOTO#'>
                            <cfelseif len(GET_EMP_LIST.PHOTO) and fileExists("#upload_folder#hr/#GET_EMP_LIST.PHOTO#")>
                                <cfset emp_photo ='documents/hr/#GET_EMP_LIST.PHOTO#'>
                            <cfelseif GET_EMP_LIST.sex eq 1>
                                <cfset emp_photo ="images/male.jpg">
                            <cfelse>
                                <cfset emp_photo ="images/female.jpg">
                            </cfif>
                            <li><a href="javascript://" ><img class="img-circle"  title="#GET_EMP_LIST.NAME# #GET_EMP_LIST.SURNAME#"  src='#emp_photo#'>  </a></li>
                          
                        </cfif>
                    <cfif len(get_work_history.update_par)><!--- Güncelleyen partner ise--->
                        <cfset GET_PARTNER_PHOTO = getComponent.PARTNER_PHOTO(partner_id : get_work_history.update_par)>
                       
                        <cfif len(GET_PARTNER_PHOTO.PHOTO) and fileExists("#upload_folder#member/#GET_PARTNER_PHOTO.PHOTO#")>
                            <cfset emp_photo ='documents/member/#GET_PARTNER_PHOTO.PHOTO#'>
                        <cfelseif len(GET_PARTNER_PHOTO.PHOTO) and fileExists("#upload_folder#hr/#GET_PARTNER_PHOTO.PHOTO#")>
                            <cfset emp_photo ='documents/hr/#GET_PARTNER_PHOTO.PHOTO#'>
                        <cfelseif GET_PARTNER_PHOTO.sex eq 1>
                            <cfset emp_photo ="images/male.jpg">
                        <cfelse>
                            <cfset emp_photo ="images/female.jpg">
                        </cfif>
                        <li><a href="javascript://" ><img class="img-circle" title="#GET_PARTNER_PHOTO.NAME# #GET_PARTNER_PHOTO.SURNAME#"  src='#emp_photo#'> </a></li>
                    </cfif>
                    <cfif len(get_work_history.company_partner_id) and not (len(get_work_history.update_par) or len(get_work_history.update_author))><!--- Güncelleyen kurumsal üye yetkilisi ise --->
                        <cfset GET_PARTNER_PHOTO = getComponent.PARTNER_PHOTO(partner_id : get_work_history.company_partner_id)>
                        <cfif len(GET_PARTNER_PHOTO.PHOTO) and fileExists("#upload_folder#member/#GET_PARTNER_PHOTO.PHOTO#")>
                            <cfset emp_photo ='documents/member/#GET_PARTNER_PHOTO.PHOTO#'>
                        <cfelseif len(GET_PARTNER_PHOTO.PHOTO) and fileExists("#upload_folder#hr/#GET_PARTNER_PHOTO.PHOTO#")>
                            <cfset emp_photo ='documents/hr/#GET_PARTNER_PHOTO.PHOTO#'>
                        <cfelseif GET_PARTNER_PHOTO.sex eq 1>
                            <cfset emp_photo ="images/male.jpg">
                        <cfelse>
                            <cfset emp_photo ="images/female.jpg">
                        </cfif>
                        <li><a href="javascript://" ><img class="img-circle" title="#GET_PARTNER_PHOTO.NAME# #GET_PARTNER_PHOTO.SURNAME#"   src='#emp_photo#'></a></li>
                    </cfif>
                    <li><i class="fa fa-angle-right"></i></li>
                    <!--- <span class="font-red-mint"><cf_get_lang dictionary_id='157.Görevli'>:</span> --->
                    <cfif project_emp_id neq 0 and len(project_emp_id)>
                        <cfset GET_EMP_LIST_ = getComponent.GET_EMP_LIST(int_emp_list : project_emp_id)>
                        <cfif len(GET_EMP_LIST_.PHOTO) and fileExists("#upload_folder#member/#GET_EMP_LIST_.PHOTO#")>
                            <cfset emp_photo ='documents/member/#GET_EMP_LIST_.PHOTO#'>
                        <cfelseif len(GET_EMP_LIST_.PHOTO) and fileExists("#upload_folder#hr/#GET_EMP_LIST_.PHOTO#")>
                            <cfset emp_photo ='documents/hr/#GET_EMP_LIST_.PHOTO#'>
                        <cfelseif GET_EMP_LIST_.sex eq 1>
                            <cfset emp_photo ="images/male.jpg">
                        <cfelse>
                            <cfset emp_photo ="images/female.jpg">
                        </cfif>
                        <li><a href="javascript://" ><img class="img-circle" title="#GET_EMP_LIST_.NAME# #GET_EMP_LIST_.SURNAME#" src='#emp_photo#'></a></li>
                    <cfelseif outsrc_partner_id neq 0 and len(outsrc_partner_id)>
                        <cfset GET_PARTNER_PHOTO_ = getComponent.PARTNER_PHOTO(partner_id : outsrc_partner_id)>
                        <cfif len(GET_PARTNER_PHOTO_.photo) and fileExists("#upload_folder#member/#GET_PARTNER_PHOTO_.PHOTO#")>
                            <cfset emp_photo ='documents/member/#GET_PARTNER_PHOTO_.PHOTO#'>
                        <cfelseif len(GET_PARTNER_PHOTO_.photo) and fileExists("#upload_folder#hr/#GET_PARTNER_PHOTO_.PHOTO#")>
                            <cfset emp_photo ='documents/hr/#GET_PARTNER_PHOTO_.PHOTO#'>
                        <cfelseif GET_PARTNER_PHOTO_.sex eq 1>
                            <cfset emp_photo ="images/male.jpg">
                        <cfelse>
                            <cfset emp_photo ="images/female.jpg">
                        </cfif>
                        <li><a href="javascript://" ><img class="img-circle" title="#GET_PARTNER_PHOTO_.NAME# #GET_PARTNER_PHOTO_.SURNAME#" src='#emp_photo#'> </a></li>
                    </cfif>
                    <li><i class="fa fa-angle-right"></i></li>
                    <cfloop query="GET_VALUE">
                        <cfif len(GET_VALUE.CC_EMP)>
                            <cfset int_emp_list = ListSort(ValueList(GET_VALUE.CC_EMP),"numeric","asc")>
                            <cfset GET_EMP_CC_EMP = getComponent.GET_EMP_LIST(int_emp_list : int_emp_list)>
                        <cfelseif len(GET_VALUE.CC_PAR)>
                            <cfset int_emp_list = ListSort(ValueList(GET_VALUE.CC_PAR),"numeric","asc")>
                            <cfset GET_EMP_CC_EMP_ = getComponent.PARTNER_PHOTO(partner_id : int_emp_list)> 
                        </cfif>
                    </cfloop>
                    <cfif isdefined("GET_EMP_CC_EMP") and len(GET_EMP_CC_EMP.recordcount)>
                        <cfloop query = "GET_EMP_CC_EMP">
                            <cfif len(GET_EMP_CC_EMP.photo) and fileExists("#upload_folder#member/#GET_EMP_CC_EMP.PHOTO#")>
                                <cfset emp_photo ='documents/member/#GET_EMP_CC_EMP.PHOTO#'>
                            <cfelseif len(GET_EMP_CC_EMP.photo) and fileExists("#upload_folder#hr/#GET_EMP_CC_EMP.PHOTO#")>
                                <cfset emp_photo ='documents/hr/#GET_EMP_CC_EMP.PHOTO#'>
                            <cfelseif GET_EMP_CC_EMP.sex eq 1>
                                <cfset emp_photo ="images/male.jpg">
                            <cfelse>
                                <cfset emp_photo ="images/female.jpg">
                            </cfif>
                            <li><a href="javascript://" ><img title="#NAME# #SURNAME#" src='#emp_photo#'></a></li>
                        </cfloop>
                    </cfif>
                    <cfif isdefined("GET_EMP_CC_EMP_") and len(GET_EMP_CC_EMP_.recordcount)>
                        <cfloop query = "GET_EMP_CC_EMP_">
                            
                            <cfif len(GET_EMP_CC_EMP_.photo) and fileExists("#upload_folder#member/#GET_EMP_CC_EMP_.PHOTO#")>
                                <cfset emp_photo ='documents/member/#GET_EMP_CC_EMP_.PHOTO#'>
                            <cfelseif len(GET_EMP_CC_EMP_.photo) and fileExists("#upload_folder#hr/#GET_EMP_CC_EMP_.PHOTO#")>
                                <cfset emp_photo ='documents/hr/#GET_EMP_CC_EMP_.PHOTO#'>
                            <cfelseif GET_EMP_CC_EMP_.sex eq 1>
                                <cfset emp_photo ="images/male.jpg">
                            <cfelse>
                                <cfset emp_photo ="images/female.jpg">
                            </cfif>
                            <li><a href="javascript://" ><img title="#NAME# #SURNAME#" src='#emp_photo#'></a></li>
                        </cfloop>
                    </cfif>
                </ul>
            </div>
            <div class="ui-vertical-list">
                <ul>
                    <li>
                        <cfif Len(update_date)>
                            <cfset upd_date = date_add('h',session.ep.time_zone,update_date)>
                            <i class="fa fa-pencil" title="<cf_get_lang dictionary_id='38297.Güncelleme Tarihi'>"></i>#Dateformat(upd_date,dateformat_style)# #Timeformat(upd_date,timeformat_style)#                                
                        </cfif>
                    </li>
                    <li>
                        <cfif len(get_work_history.to_complete)>
                            <cfset upd_date = date_add('h',session.ep.time_zone,update_date)>
                            <i class="fa fa-adjust" title="<cf_get_lang dictionary_id ='38160.Tamamlanma Yüzdesi'>"></i>%#get_work_history.to_complete#                                
                        </cfif>
                    </li>
                    <li>
                        <cfif len(get_work_history.ESTIMATED_TIME)>
                            <cfset sonuc = get_work_history.estimated_time/60>
							<cfset saat = listfirst(sonuc,'.')>
							<cfset dak = get_work_history.estimated_time - (saat*60)>
                            <i class="fa fa-clock-o" title="<cf_get_lang no='95.Öngörülen Süre'>"></i>#saat#h #dak#m                                
                        </cfif>
                    </li>
                    <li>
                        <cfif len(get_work_history.TOTAL_TIME_HOUR) and len(get_work_history.TOTAL_TIME_MINUTE)>
                            <i class="fa fa-clock-o" title="<cf_get_lang dictionary_id='38148.Harcanan Zaman'>"></i>#get_work_history.TOTAL_TIME_HOUR#h #get_work_history.TOTAL_TIME_MINUTE#m                                
                        </cfif>
                    </li>
                    <li>
                        <cfif len(get_work_history.work_currency_id)>
                            <cfquery name="GET_PROCESS" datasource="#dsn#">
                                SELECT STAGE FROM PROCESS_TYPE,PROCESS_TYPE_ROWS WHERE PROCESS_TYPE_ROWS.PROCESS_ID = PROCESS_TYPE.PROCESS_ID AND PROCESS_TYPE_ROWS.PROCESS_ROW_ID = #get_work_history.work_currency_id#
                            </cfquery> 
                                <i class="fa fa-tree" title="<cf_get_lang dictionary_id="58859.Süreç">"></i>#get_process.stage#
                        </cfif> 
                    </li>
                </ul>
            </div>
        </cfoutput>
    </div>   
</cfif>