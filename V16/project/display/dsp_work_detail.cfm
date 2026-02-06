
<cfset getComponent = createObject('component','V16.project.cfc.get_work')>
<cfset work_detail_summary = getComponent.DET_WORK(id : attributes.id)>
<cfset work_detail_first = getComponent.GET_WORK_FIRST_DETAIL(id : attributes.id)>
<cfset GET_VALUE = getComponent.GET_VALUES(id:attributes.id)>
<cfset upload_folder=application.systemParam.systemParam().upload_folder>
<div class="ui-info-text">
    <cfoutput>
        <h1>#URLDecode(URLEncodedFormat(work_detail_summary.work_head))#</h1>
        <cfset work_detail_ = replace(work_detail_first.work_detail,'<form','<fform','all')>
        <cfset work_detail_ = replace(work_detail_,'</form','</fform','all')>    
        <cfset work_detail_ = reReplace(work_detail_, 'padding-bottom:\s*[\d\.]+(?:px|%);', 'padding-bottom: 0px;', 'all')>
        <cfset work_detail_ = replace(work_detail_,'<invalidTag','<iframe','all')>
        <cfset work_detail_ = replace(work_detail_,'</invalidTag','</iframe','all')>
        <p>#work_detail_#</p>
        <cfif len(work_detail_summary.milestone_work_id)>
            <cfset work_detail_milestone = getComponent.DET_WORK(id : work_detail_summary.milestone_work_id)>
            <h1><i class="fa fa-sitemap"></i>   <a href="index.cfm?fuseaction=project.works&event=det&id=#work_detail_summary.milestone_work_id#" target="blank_">#work_detail_milestone.work_head#</a></h1>
        </cfif>
        <div class="ui-customTooltip">
            <ul>
                <li>
                    <cfif len(work_detail_first.update_author)>
                        <cfset GET_EMP_LIST = getComponent.GET_EMP_LIST(int_emp_list : work_detail_first.update_author)>
                        <cfif len(GET_EMP_LIST.photo) and fileExists("#upload_folder#member/#GET_EMP_LIST.PHOTO#")>
                            <cfset emp_photo ='../documents/member/#GET_EMP_LIST.PHOTO#'>
                        <cfelseif len(GET_EMP_LIST.photo) and fileExists("#upload_folder#hr/#GET_EMP_LIST.PHOTO#")>
                            <cfset emp_photo ='../documents/hr/#GET_EMP_LIST.PHOTO#'>
                        <cfelseif GET_EMP_LIST.sex eq 1>
                            <cfset emp_photo ="images/male.jpg">
                        <cfelse>
                            <cfset emp_photo ="images/female.jpg">
                        </cfif>
                        <a href="javascript://" title="#get_emp_info(work_detail_first.update_author,0,0)#"><img src='#emp_photo#' /></a>
                    </cfif>
                    <cfif len(work_detail_first.update_par)>
                        <cfset PARTNER_PHOTO = getComponent.PARTNER_PHOTO(partner_id : work_detail_first.update_par)>
                        
                        <cfif len(PARTNER_PHOTO.photo) and fileExists("#upload_folder#member/#PARTNER_PHOTO.PHOTO#")>
                            <cfset emp_photo ='../documents/member/#PARTNER_PHOTO.PHOTO#'>
                        <cfelseif len(PARTNER_PHOTO.photo) and fileExists("#upload_folder#hr/#PARTNER_PHOTO.PHOTO#")>
                            <cfset emp_photo ='../documents/hr/#PARTNER_PHOTO.PHOTO#'>
                        <cfelseif PARTNER_PHOTO.sex eq 1>
                            <cfset emp_photo ="images/male.jpg">
                        <cfelse>
                            <cfset emp_photo ="images/female.jpg">
                        </cfif>
                        <a href="javascript://" title="#get_par_info(work_detail_first.update_par,0,0,1)#"><img src='#emp_photo#' /></a>  
                    </cfif>
                </li>
                <li><i class="fa fa-angle-right"></i></li>
                <li>
                    <cfif work_detail_summary.project_emp_id neq 0 and len(work_detail_summary.project_emp_id)>
                        <cfset GET_EMP_LIST = getComponent.GET_EMP_LIST(int_emp_list : work_detail_summary.project_emp_id)>
                        
                        <cfif len(GET_EMP_LIST.photo) and fileExists("#upload_folder#member/#GET_EMP_LIST.PHOTO#")>
                            <cfset emp_photo ='../documents/member/#GET_EMP_LIST.PHOTO#'>
                        <cfelseif len(GET_EMP_LIST.photo) and  fileExists("#upload_folder#hr/#GET_EMP_LIST.PHOTO#")>
                            <cfset emp_photo ='../documents/hr/#GET_EMP_LIST.PHOTO#'>
                        <cfelseif GET_EMP_LIST.sex eq 1>
                            <cfset emp_photo ="images/male.jpg">
                        <cfelse>
                            <cfset emp_photo ="images/female.jpg">
                        </cfif>
                        <a href="javascript://" title="#get_emp_info(work_detail_summary.project_emp_id,0,0)#"><img src='#emp_photo#'/></a>
                    <cfelseif work_detail_summary.outsrc_partner_id neq 0 and len(work_detail_summary.outsrc_partner_id)>
                        <cfset PARTNER_PHOTO = getComponent.PARTNER_PHOTO(partner_id : work_detail_summary.outsrc_partner_id)>
                        <cfif len(PARTNER_PHOTO.photo) and  fileExists("#upload_folder#member/#PARTNER_PHOTO.PHOTO#")>
                            <cfset emp_photo ='../documents/member/#PARTNER_PHOTO.PHOTO#'>
                        <cfelseif len(PARTNER_PHOTO.photo) and  fileExists("#upload_folder#hr/#PARTNER_PHOTO.PHOTO#")>
                            <cfset emp_photo ='../documents/hr/#PARTNER_PHOTO.PHOTO#'>
                        <cfelseif PARTNER_PHOTO.sex eq 1>
                            <cfset emp_photo ="images/male.jpg">
                        <cfelse>
                            <cfset emp_photo ="images/female.jpg">
                        </cfif>
                        <a href="javascript://" title="#get_par_info(work_detail_summary.outsrc_partner_id,0,0,0)#"><img src='#emp_photo#' /></a>
                    </cfif>
                </li>
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
                    <li><i class="fa fa-angle-right"></i></li>
                    <cfloop query = "GET_EMP_CC_EMP">
                        <cfif GET_EMP_CC_EMP.recordcount and  fileExists("#upload_folder#member/#GET_EMP_CC_EMP.PHOTO#")>
                            <cfset emp_photo ='../documents/member/#GET_EMP_CC_EMP.PHOTO#'>
                        <cfelseif GET_EMP_CC_EMP.recordcount and  fileExists("#upload_folder#hr/#GET_EMP_CC_EMP.PHOTO#")>
                            <cfset emp_photo ='../documents/hr/#GET_EMP_CC_EMP.PHOTO#'>
                        <cfelseif GET_EMP_CC_EMP.sex eq 1>
                            <cfset emp_photo ="images/male.jpg">
                        <cfelse>
                            <cfset emp_photo ="images/female.jpg">
                        </cfif>
                        <li><a href="javascript://" title="#NAME# #SURNAME#"><img title="#NAME# #SURNAME#"  src='#emp_photo#'></a></li>
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
                        <li><a href="javascript://" title="#NAME# #SURNAME#"><img  title="#NAME# #SURNAME#" src='#emp_photo#'/></a></li>
                    </cfloop>
                </cfif>         
            </ul>
        </div>    
    </cfoutput>
</div>

