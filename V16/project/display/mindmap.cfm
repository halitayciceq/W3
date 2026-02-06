
<cfparam name="attributes.keyword" default="">
<cfset record_count_cf = 0>
    <cfif isDefined("attributes.project_id") and len(attributes.project_id)>
        <cfset getComponent = createObject('component','V16.project.cfc.mindmap')>
        <cfset get_list = getComponent.GET_LIST(project_id: project_id, type: type)>
    <cfelse>
        <cfset getComponent = createObject('component','V16.project.cfc.mindmap')>
        <cfset get_list = getComponent.GET_LIST_FILTERED(keyword : '#iif(isdefined("attributes.keyword"),"attributes.keyword",DE(""))#')>
    </cfif>
<cfif isDefined("attributes.project_id")>
    <cf_flat_list>
        <thead>
            <th width="35">
                <cf_get_lang dictionary_id='58577.sıra'>
            </th>
            <th>
                <cf_get_lang dictionary_id='29800.FILE NAME'>
            </th>
            <th>
                <cf_get_lang dictionary_id='43121.Kayıt Eden'>
            </th>
            <th>
                <cf_get_lang dictionary_id='57627.Kayıt Tarihi'>
            </th>
            <th width="20"><a href="javascript://"><i class="icon-minus" title="<cf_get_lang dictionary_id='57463.Sil'>" alt="<cf_get_lang dictionary_id='57463.Sil'>"></i></a></th>
        </thead>
        <cfif get_list.recordcount>
            <cfset record_count_cf = get_list.recordcount>
            <cfoutput query="get_list">
                <tbody>
                    <tr>
                        <td>
                            #currentRow#
                        </td>
                        <td>
                            <a href="#request.self#?fuseaction=project.mindmap&event=upd&id=#mindmap_id#" target = "_blank">#FILE_NAME#</a>
                        </td>
                        <td>
                            #get_emp_info(RECORD_EMP,0,1)#
                        </td>
                        <td>
                            #dateFormat(record_date,dateformat_style)#
                        </td>
                        <td>
                            <input type="hidden" name="id#currentrow#" id="id#currentrow#" value="#get_list.mindmap_id#">
                            <a href="javascript://" onclick="sil_designer(#currentrow#,#mindmap_id#);">
                            <i class="fa fa-minus" title="<cf_get_lang dictionary_id='57463.Sil'>" alt="<cf_get_lang dictionary_id='57463.Sil'>"></i></a>
                        </td>  
                    </tr>
                </tbody>
            </cfoutput>
        <cfelse>
            <tbody>
                <tr>
                    <td colspan="5"><cf_get_lang dictionary_id ="57484.kayıt yok"></td>   
                </tr>
            </tbody>
        </cfif>
    </cf_flat_list>
<cfelse>
    <cf_box>
        <cfform name="release_notes" method="post" action="">
            <cf_box_search plus="0">
                <div class="form-group">
                    <input type="text" name="keyword" id="keyword"  placeholder="Filtre ediniz!"  value="<cfoutput>#attributes.keyword#</cfoutput>">
                </div>
                <div class="form-group">
                    <cf_wrk_search_button button_type="4">
                </div>
				<div class="form-group">
					<a class="ui-btn ui-btn-gray" target="_blank" href="<cfoutput>#request.self#</cfoutput>?fuseaction=project.mindmap&event=add"><i class="fa fa-plus" title="<cf_get_lang dictionary_id='57582.Ekle'>"></i></a>
				</div> 
            </cf_box_search>
        </cfform>
        <cf_flat_list>
            <thead>
                <th width="35">
                    <cf_get_lang dictionary_id='58577.sıra'>
                </th>
                <th>
                    <cf_get_lang dictionary_id='29800.FILE NAME'>
                </th>
                <th>
                    <cf_get_lang dictionary_id='43121.Kayıt Eden'>
                </th>
                <th>
                    <cf_get_lang dictionary_id='57627.Kayıt Tarihi'>
                </th>
                <th>
                    <cf_get_lang dictionary_id='57416.Proje'>
                </th>
                <th width="20"><a href="javascript://"><i class="icon-minus" title="<cf_get_lang dictionary_id='57463.Sil'>" alt="<cf_get_lang dictionary_id='57463.Sil'>"></i></a></th>
            </thead>
            <cfif get_list.recordcount>

                <cfset record_count_cf = get_list.recordcount>
                <cfoutput query="get_list">
                    <tbody>
                        <tr>
                            <td>
                                #currentRow#
                            </td>
                            <td>
                                <a href="#request.self#?fuseaction=project.mindmap&event=upd&id=#mindmap_id#" target = "_blank">#FILE_NAME#</a>
                            </td>
                            <td>
                                #get_emp_info(RECORD_EMP,0,1)#
                            </td>
                            <td>
                                #dateFormat(record_date,dateformat_style)#
                            </td>
                            <td>
                                <cfset event = "det">
                                <cfset href_id = "id">
                                <cfif RELATIVE_TYPE eq 'project.projects'><cfset project_title = "#PROJECT_HEAD#"><cfelseif RELATIVE_TYPE eq 'project.works'>
                                    <cfset project_title = "#WORK_HEAD#">
                                <cfelseif RELATIVE_TYPE eq 'agenda.view_daily'>
                                    <cfset project_title = "#EVENT_HEAD#">
                                    <cfset event = "upd">
                                    <cfset href_id = "event_id">
                                <cfelse>
                                    <cfset project_title = "">
                                </cfif>
                                <a href="#request.self#?fuseaction=#RELATIVE_TYPE#&event=#event#&#href_id#=#RELATIVE_ID#" target = "_blank">
                                    #project_title#
                                </a>
                            </td>
                            <td>
                                <input type="hidden" name="id#currentrow#" id="id#currentrow#" value="#get_list.mindmap_id#">
                                <a href="javascript://" onclick="sil_designer(#currentrow#,#mindmap_id#);">
                                <i class="fa fa-minus" title="<cf_get_lang dictionary_id='57463.Sil'>" alt="<cf_get_lang dictionary_id='57463.Sil'>"></i></a>
                            </td>  
                        </tr>
                    </tbody>
                </cfoutput>
            <cfelse>
                <tbody>
                    <tr>
                        <td colspan="5"><cf_get_lang dictionary_id ="57484.kayıt yok"></td>   
                    </tr>
                </tbody>
            </cfif>
        </cf_flat_list>
    </cf_box>
</cfif>
<script>
    row_count = '<cfoutput>#record_count_cf#</cfoutput>';
    function sil_designer(row_count,id)
        {
        if(confirm ("<cfoutput>#getLang('','Satırı silmek istediğinize emin misiniz?',36628)#</cfoutput>"))
        {
            if(id != undefined)
            {
                $.ajax({ 
                    type:'POST',  
                    url:'V16/project/cfc/mindmap.cfc?method=DEL_MINDMAP',  
                    data: { 
                        mindmap_id : id
                    },
                    success: function (returnData) {
                        window.location.reload();
                    },
                    error: function () 
                    {
                        console.log('CODE:8 please, try again..');
                        return false; 
                    }
                }); 
            }
        }else return false;
    }
</script>