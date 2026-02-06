<cfparam name="attributes.modal_id" default="">
<cfparam name="attributes.project_id" default="-1">

<cfset data_cmp = createObject("component","WDO.ImplementationSteps")/>

<cfset get_imp_data_service = data_cmp.getImpDataService()>
<cfset get_project_details = data_cmp.getProjectImported(project_id: attributes.project_id)>

<cf_box title="#getLang("","Data Service",66882)#: #getLang("","Adım Adım İmplementasyon",44149)#" scroll="1" collapsable="1" resize="1" popup_box="#iif(isdefined("attributes.draggable"),1,0)#">
    <cf_box_elements>
        <div class="col col-12">
            <cfoutput>
                <input type="hidden" name="start_date" id="start_date" value="">
                <input type="hidden" name="finish_date" id="finish_date" value="#now()#">
                <input type="hidden" name="dataservice_#get_imp_data_service.REST_NAME#" id="dataservice_#get_imp_data_service.REST_NAME#" value="#get_imp_data_service.REST_NAME#">
                <input type="hidden" name="dataservice_id_#get_imp_data_service.REST_NAME#" id="dataservice_id_#get_imp_data_service.REST_NAME#" value="#get_imp_data_service.WRK_DATA_SERVICE_ID#">
            </cfoutput>
            <div class="form-group" style="padding-bottom: 5px;">
                <label class="col col-1 col-md-4 col-sm-4 col-xs-12"><b><cf_get_lang dictionary_id='63052.Proje ID'></b></label>
                <div class="col col-11 col-md-8 col-sm-8 col-xs-12">
                    <label><cfoutput>#attributes.project_id#</cfoutput></label>
                </div>
            </div>
            <div class="form-group" style="padding-bottom: 5px;">
                <label class="col col-1 col-md-4 col-sm-4 col-xs-12"><b><cf_get_lang dictionary_id='57416.Proje'></b></label>
                <div class="col col-11 col-md-8 col-sm-8 col-xs-12">
                    <label><cfoutput>#get_project_name(attributes.project_id, 0)#</cfoutput></label>
                </div>
            </div>

            
            <cf_box_footer>
                <cfoutput>
                    <cfif get_project_details.IMPLEMENTATION_STEP_IMPORTED eq 1>
                        <input class="ui-wrk-btn ui-wrk-btn-red" type="button" value="<cf_get_lang dictionary_id='66889.Sil ve Yeniden Oluştur'>" onclick="deleteStepsData(#attributes.project_id#)">
                    <cfelse>
                        <input class="ui-wrk-btn ui-wrk-btn-success" type="button" value="<cf_get_lang dictionary_id='66690.Verileri Al'>" onclick="getStepsData(#attributes.project_id#)">
                    </cfif>
                </cfoutput>
            </cf_box_footer>
        </div>
    </cf_box_elements>
</cf_box>

<script>
    function getStepsData(id) {
        var dataservice_name = $("#dataservice_stepByStepimp").val();
        var start_date = $("#start_date").val();
        var finish_date = $("#finish_date").val();
        var extra_param = "";

        if (id != -1) {
            extra_param = "PROJECT_ID," + id;
        }

        $("#working_div_main").css({"z-index":"99999999"}).show();
        $.ajax({
            url: "V16/settings/cfc/dataservice_control.cfc?method=runWexService",
            method: "post",
            dataType: "json",
            data: {
                functionName: dataservice_name, 
                start_date : start_date, 
                finish_date : finish_date,
                extra_param: extra_param,
            },
            success: function( response ){                
                var row_dataservice_id = $("#dataservice_id_"+dataservice_name).val(); // Data Service ID
                if( response.STATUS == true ){
                    $.ajax({
                        url: "WEX/dataservices/cfc/data_services.cfc?method=set_returnTrue",
                        method: "post",
                        data: {row_id : row_dataservice_id},
                        success: function(rtrn_val){
                            var data = new FormData();
                            data.append('project_id', id );
                            AjaxControlPostDataJson('WDO/ImplementationSteps.cfc?method=updProjectImported', data, function(returnData)
                            {
                                $("#working_div_main").css({"z-index":"9999999"}).hide();
                                closeBoxDraggable( '<cfoutput>#attributes.modal_id#</cfoutput>', 'unique_stepbystep_imp' );

                                if (returnData.STATUS)
                                {
                                    Swal.fire({
                                        title: '<cf_get_lang dictionary_id='47470.İşlem Tamamlandı'>!',
                                        type: 'success',
                                        confirmButtonColor: '#1fbb39',
                                        confirmButtonText: '<cf_get_lang dictionary_id='44097.Devam Et'>'
                                    });
                                }
                                else
                                {
                                    const errorMessage = returnData.ERROR.DETAIL || returnData.ERROR.Message;

                                    Swal.fire({
                                        title: '<cf_get_lang dictionary_id='57541.Hata'>!',
                                        type: 'error',
                                        text: '<cf_get_lang dictionary_id='57541.Hata'>' + ': ' + errorMessage,
                                        confirmButtonColor: '#1fbb39',
                                        confirmButtonText: '<cf_get_lang dictionary_id='44097.Devam Et'>'
                                    });
                                }
                            });
                        },
                        error: function( objResponse ){
                            console.log(objResponse);
                            if(objResponse.ERRORMESSAGE != undefined)
                            {
                                return_error = objResponse.ERRORMESSAGE;
                            }
                            else
                                return_error = 'Error Executing Database Query!';

                            $("#working_div_main").css({"z-index":"9999999"}).hide();
                            closeBoxDraggable( '<cfoutput>#attributes.modal_id#</cfoutput>', 'unique_stepbystep_imp' );

                            Swal.fire({
                                title: '<cf_get_lang dictionary_id='57541.Hata'>!',
                                type: 'error',
                                text: '<cf_get_lang dictionary_id='57541.Hata'>' + ': ' + return_error,
                                confirmButtonColor: '#1fbb39',
                                confirmButtonText: '<cf_get_lang dictionary_id='44097.Devam Et'>'
                            });
                        }
                    });
                } 
                else
                {
                    if(response.ERRORMESSAGE != undefined && response.ERRORMESSAGE.LocalizedMessage != undefined)
                        return_error = response.ERRORMESSAGE.LocalizedMessage;
                    else if(response.ERRORMESSAGE != undefined )
                        return_error = response.ERRORMESSAGE;
                    else
                        return_error = 'Error Executing Database Query!';

                    $("#working_div_main").css({"z-index":"9999999"}).hide();
                    closeBoxDraggable( '<cfoutput>#attributes.modal_id#</cfoutput>', 'unique_stepbystep_imp' );
                
                    Swal.fire({
                        title: '<cf_get_lang dictionary_id='57541.Hata'>!',
                        type: 'error',
                        text: '<cf_get_lang dictionary_id='57541.Hata'>' + ': ' + return_error,
                        confirmButtonColor: '#1fbb39',
                        confirmButtonText: '<cf_get_lang dictionary_id='44097.Devam Et'>'
                    });
                }

            },
            error: function( objResponse ){
                console.log(objResponse);
                if(objResponse.ERRORMESSAGE != undefined)
                {
                    return_error = objResponse.ERRORMESSAGE;
                }
                else
                    return_error = 'Error Executing Database Query!';

                $("#working_div_main").css({"z-index":"9999999"}).hide();
                closeBoxDraggable( '<cfoutput>#attributes.modal_id#</cfoutput>', 'unique_stepbystep_imp' );

                Swal.fire({
                    title: '<cf_get_lang dictionary_id='57541.Hata'>!',
                    type: 'error',
                    text: '<cf_get_lang dictionary_id='57541.Hata'>' + ': ' + return_error,
                    confirmButtonColor: '#1fbb39',
                    confirmButtonText: '<cf_get_lang dictionary_id='44097.Devam Et'>'
                });
            }
        });
    }

    function deleteStepsData(id) {
        var data = new FormData();
        data.append('project_id', id );
        $("#working_div_main").css({"z-index":"9999999"}).show();
        AjaxControlPostDataJson('WDO/ImplementationSteps.cfc?method=delProjectImported', data, function(returnData)
        {
            if (returnData.STATUS)
            {
                getStepsData(id);
            }
            else
            {
                const errorMessage = returnData.ERROR.DETAIL || returnData.ERROR.Message;

                Swal.fire({
                    title: '<cf_get_lang dictionary_id='57541.Hata'>!',
                    type: 'error',
                    text: '<cf_get_lang dictionary_id='57541.Hata'>' + ': ' + errorMessage,
                    confirmButtonColor: '#1fbb39',
                    confirmButtonText: '<cf_get_lang dictionary_id='44097.Devam Et'>'
                });
            }
        });
    }
</script>