<!---
    File : work_step.cfm
    Author : Melek KOCABEY <melekkocabey@workcube.com>
    Date : 12.09.2019
    Description : İş adımları için oluşturuldu
    Notes :      
--->
<cfscript>
    cfc = createObject("component","V16.project.cfc.get_work");
	getWorkSteps = cfc.getWorkSteps(WORK_ID:attributes.id);
</cfscript>
<cfform name="work_steps" method="post" action="#request.self#?fuseaction=project.emptypopup_work_steps">
  <input name="record_num" id="record_num" type="hidden" value="<cfoutput>#getWorkSteps.recordcount#</cfoutput>">
  <input type="hidden" name="work_id" id="work_id" value="<cfoutput>#attributes.id#</cfoutput>">
    <table class="ajax_list ui-form">
        <thead>
            <tr>
                <th width="15"><cf_get_lang dictionary_id='31872.Sırala'></th>
                <th><cf_get_lang dictionary_id ="57629.Açıklama "></th>
                <th><cf_get_lang dictionary_id ="57491.Saat"></th>
                <th><cf_get_lang dictionary_id ="58827.Dk"></th>
                <th title="<cf_get_lang dictionary_id ='34413.Tamamlanma'>" style="cursor: pointer;">T</th>
                <th><a href="javascript:void(0)"  title="<cf_get_lang dictionary_id ="57582.Ekle">" onClick="add_row();"><i class="fa fa-plus"></i></a></th>
            </tr>
        </thead>
        <tbody id="BodyIcerik1">
            <cfoutput query="getWorkSteps">                                                       
                <tr id="step_row#currentrow#">
                    <cfinput type="hidden" name="cRow#currentrow#" value="#work_step_id#*#work_id#" class="cRow">
                    <input type="hidden" id="step_kontrol#currentrow#" name="step_kontrol#currentrow#" value="1">
                    <td width="15px"><a style="padding:0!important;width:30px;background-color:##56F1E6" href="javascript://" class="ui-btn ui-btn-success" id="handleSolution"><i class="fa fa-sort"></i></a></td>
                    <td style="width:65%;"> 
                        <div class="form-group">
                            <cfinput type="text" name="WORK_STEP_DETAIL#currentrow#" id="WORK_STEP_DETAIL#currentrow#" value="#URLDecode(WORK_STEP_DETAIL)#">
                        </div>
                    </td>
                    <td>
                        <div class="form-group">
                            <select name="work_step_hour#currentrow#" id="work_step_hour#currentrow#">
                                <option value="0"><cf_get_lang dictionary_id="57491.Saat"></option>
                                <cfloop from="0" to="24" index="i">
                                    <option value="#i#" <cfif len(COMPLETED_HOUR) and (COMPLETED_HOUR eq i)>selected</cfif>>#i#</option>
                                </cfloop>
                            </select>
                        </div>
                    </td>
                    <td>
                        <div class="form-group">
                            <select name="work_step_minute#currentrow#" id="work_step_minute#currentrow#">
                                <option value="0"><cf_get_lang dictionary_id = "58827.Dk"></option>
                                    <cfloop from="0" to="60" index="i" step="5">
                                <option value="#i#" <cfif len(COMPLETED_MINUTE) and (COMPLETED_MINUTE eq i)>selected</cfif> >#i#</option></cfloop>
                            </select>
                        </div>
                    </td>
                    <td>
                        <div class="form-group">
                            <div class="checkbox checbox-switch">
                                <label>
                                    <input type="checkbox" name="completion#currentrow#" id="customSwitch1#currentrow#" value="1" <cfif WORK_STEP_COMPLETE_PERCENT eq 1>checked</cfif>/>
                                    <span></span>
                                </label>
                            </div>
                        </div>
                    </td>
                    <td><a href="javascript:void(0)" onClick="sil(#currentrow#);"><i class="icon-minus" title="sil"></i></a></td>
                </tr>
            </cfoutput>
        </tbody>
    </table>
    <div class="row formContentFooter text-right">
        <div class="col col-12">
            <cfsavecontent  variable="title"><cf_get_lang dictionary_id='57461.Kaydet'></cfsavecontent>
            <cfsavecontent  variable="message"><cf_get_lang dictionary_id='57535.Kaydetmek İstediğinizden Emin misiniz?'></cfsavecontent>
            <label id="SHOW_INFO"></label>
            <cf_workcube_buttons update_status="0" extraButton="1" extraButtonText="#title#" extraAlert="#message#" extraFunction='gelen()'>
        </div>
    </div>
</cfform>
<script type="text/javascript">
	row_count_=<cfoutput>#getWorkSteps.recordcount#</cfoutput>;
	function sil(st)
	{
		var my_element=document.getElementById('step_kontrol'+st);
		my_element.value=0;
		var my_element=eval("step_row"+st);
		my_element.style.display="none";
    }
    function add_row()
	{
		row_count_++;
		var newRow;
		var newCell;
		newRow = document.getElementById("BodyIcerik1").insertRow(document.getElementById("BodyIcerik1").rows.length);
		newRow.setAttribute("name","step_row" + row_count_);
		newRow.setAttribute("id","step_row" + row_count_);
		document.getElementById('record_num').value=row_count_;
		
        newCell = newRow.insertCell(newRow.cells.length);
        newCell.innerHTML = '<td width="15px"><a name="sorter' + row_count_ +'" id="sorter' + row_count_ +'" style="padding:0!important;width:30px;background-color:##56F1E6" href="javascript://" class="ui-btn ui-btn-success" id="handleSolution"><i class="fa fa-sort"></i></a></td>';

        newCell = newRow.insertCell(newRow.cells.length);
        newCell.setAttribute("required", true);
        newCell.setAttribute("style", 'width:65%');
        newCell.innerHTML = '<div class="form-group" ><input type="text" name="WORK_STEP_DETAIL' + row_count_ +'" id="WORK_STEP_DETAIL' + row_count_ +'" placeHolder="Açıklama Yazınız..." value=""></div>';

        newCell = newRow.insertCell(newRow.cells.length);
        newCell.innerHTML = '<div class="form-group"><select name="work_step_hour' + row_count_ +'"><option value="0"><cf_get_lang dictionary_id="57491.Saat"></option><cfoutput><cfloop from="0" to="24" index="i"><option value="#i#">#i#</option></cfloop></cfoutput></select></div>';
               
        newCell = newRow.insertCell(newRow.cells.length);
        newCell.innerHTML = '<div class="form-group"><select name="work_step_minute'+ row_count_ +'"><option value="0"><cf_get_lang dictionary_id = "58827.Dk" ></option><cfoutput><cfloop from="0" to="60" index="i" step="5"><option value="#i#">#i#</option></cfloop></cfoutput></select></div>';
        newCell = newRow.insertCell(newRow.cells.length);
        newCell.innerHTML = '<div class="form-group"><div class="checkbox checbox-switch"><label><input type="checkbox" value="1" name="completion' + row_count_ +'" id="customSwitch1' + row_count_ +'"><span></span></label></div></div></div>';

        newCell = newRow.insertCell(newRow.cells.length);
        newCell.innerHTML = '<input type="hidden" value="" id="acc_id' + row_count_ +'" name="acc_id' + row_count_ +'"><input type="hidden" value="1" id="step_kontrol' + row_count_ +'" name="step_kontrol' + row_count_ +'"><a href="javascript://" onclick="sil(' + row_count_ + ');"><i class="icon-minus" title="<cf_get_lang dictionary_id='57463.sil'>"></i></a>';
        
    }
    
    function gelen()
    {
        for (i=1; i<=row_count_; i++)
        {
            if(document.getElementById("step_kontrol"+i).value==1)
                {               
                    document.getElementById("WORK_STEP_DETAIL"+i).value = encodeURI(document.getElementById("WORK_STEP_DETAIL"+i).value);
                    if (document.getElementById("WORK_STEP_DETAIL"+i).value == "")
                    { 
                        alert ("<cf_get_lang dictionary_id='56660.Lütfen Açıklama Giriniz'>");
                        document.getElementById("WORK_STEP_DETAIL"+i).focus();	
                        return false;
                    }                              
                        
                }
        }
            AjaxFormSubmit('work_steps','SHOW_INFO',1,'','','','','true');
    }

    var finelContentSortList = [];
    $( "#BodyIcerik1" ).sortable( {
        update: function( event, ui ) {
            $(this).children().each(function(index) {
                $(this).find('td').last().html(index + 1);
            });
        },
        stop: function( event, ui ){
            finalContentSortList = [];
            $(this).find('tr').each(function(i){
                $(this).find('td:last').text(i+1);
            });
            var contentSortList = document.querySelectorAll('.cRow');
            contentSortList.forEach((s,i) => {
                var work_id = s.value.split("*")[1];
                var work_step_id = s.value.split("*")[0];
                finalContentSortList.push({'work_step_id': work_step_id, 'work_id': work_id, 'content_rank' : i+1});
            });
            console.log(finalContentSortList);
            sorterSave('s', finalContentSortList);
        }
    });

    function sorterSave(type,list){
        switch(type) {
            case 's':
                var data = {'contents' : JSON.stringify(list)};
                var work_id = <cfoutput>#attributes.id#</cfoutput>;
                $.ajax({
                    url 	: "<cfoutput>#request.self#</cfoutput>?fuseaction=project.emptypopup_work_steps&issort=1&work_id="+work_id,
                    type	: "POST",
                    data	:	data,
                    success: function(data, textStatus, jqXHR)
                    {
                        //console.log(data);
                        $("#work_steps .catalyst-refresh").click();
                    },
                    error: function (jqXHR, textStatus, errorThrown)
                    {}
                });
            break;
            default:
                console.log('Sorter Save Default');
        }
    };
    
    
</script>