<cfquery name="GET_OPPORTUNITY_PLUSES" datasource="#DSN3#">
    SELECT 
    OP.PLUS_DATE,
    OP.EMPLOYEE_ID,
    OP.RECORD_EMP,
    OP.COMMETHOD_ID,
    OP.MAIL_SENDER,
    OP.MAIL_CC,
    OP.PLUS_CONTENT,
    OP.IS_EMAIL,
    OP.OPP_PLUS_ID,
    OP.PRODUCT_SAMPLE_ID,
    OP.OPP_ID ,
    O.OPP_ID,
    PS.PRODUCT_SAMPLE_ID
    FROM 
    	OPPORTUNITIES_PLUS AS OP 
        LEFT JOIN OPPORTUNITIES AS O  ON OP.OPP_ID = O.OPP_ID
        LEFT JOIN PRODUCT_SAMPLE AS PS ON OP.PRODUCT_SAMPLE_ID= PS.PRODUCT_SAMPLE_ID
    
    WHERE 1=1
        <cfif isdefined("attributes.OPP_ID") and len(attributes.OPP_ID)>
            AND  OP.OPP_ID  = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.OPP_ID#"> 
        </cfif>
        <cfif isdefined("attributes.PRODUCT_SAMPLE_ID") and len(attributes.PRODUCT_SAMPLE_ID)>
            AND OP.PRODUCT_SAMPLE_ID  = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.PRODUCT_SAMPLE_ID#"> 
        </cfif>
    ORDER BY 
        OP.PLUS_DATE DESC,
		OP.RECORD_DATE DESC
</cfquery>

<cfif get_opportunity_pluses.recordcount>	
    <cfoutput query="get_opportunity_pluses">
        <div class="ui-card">
            <div class="ui-card-item">
                <div class="ui-info-text padding-left-10">
                    #plus_content#
                </div>
                <div class="col col-12 col-md-12 col-sm-12 col-xs-12">
                    <cf_box_footer>
                        
                        <div class="col col-10 col-md-10 col-sm-10 col-xs-12">  
                            <p>
                                <cfif len(plus_date)>
                                <b><cf_get_lang dictionary_id='57483.Kayıt'></b>: #dateformat(plus_date,dateformat_style)#
                                </cfif>
                                <cfif len(employee_id)>#get_emp_info(record_emp,0,0)#</cfif>
                                <cfif len(commethod_id)>&nbsp; -
                                    <cfset attributes.commethod_id = commethod_id>
                                    <cfinclude template="../query/get_commethod.cfm">
                                    #get_commethod.commethod#
                                </cfif>
                            </p>
                            <cfif len(MAIL_SENDER)> 
                                <p><b><cf_get_lang dictionary_id='30883.Bildirimler'></b>: #mail_sender#</p>
                            </cfif>
                            <cfif mail_sender neq '' and is_email eq 1><p><b><cf_get_lang no='48.E-posta Gonderilenler'></b> : #mail_sender#</p></cfif>
                            <cfif mail_cc neq ''><p><b><cf_get_lang_main no='1361.Bilgi Verilecekler'></b> : #mail_cc#</p></cfif>
                        </div>
                        <cfif not listfindnocase(denied_pages,'call.popup_upd_service_plus')>
                            <div class="col col-2 col-xs-12">  <a href="javascript://" onclick="openBoxDraggable('#request.self#?fuseaction=sales.popup_form_upd_opp_plus&opp_plus_id=#opp_plus_id#','','ui-draggable-box-medium');"  class="pull-right ui-wrk-btn ui-wrk-btn-success"><cf_get_lang dictionary_id='57464.Güncelle'></a></div>
                        </cfif>
                    </cf_box_footer>
                </div>
            </div>
        </div>
    </cfoutput>
<cfelse>
    <div class="ui-info-text">
        <cf_get_lang_main no='72.Kayit Yok'> !
    </div>
</cfif>
