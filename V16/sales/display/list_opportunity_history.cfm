<cfinclude template="../query/get_opp_currencies.cfm">
<cfset opp_currency_list = valuelist(get_opp_currencies.OPP_CURRENCY_ID)>
<cfquery name="get_opp_history" datasource="#dsn3#">
	SELECT
		OPP_HISTORY_ID, 
        OPP_ID, 
        OPP_NO,
        OPP_CURRENCY_ID, 
        COMPANY_ID, 
        PARTNER_ID, 
        CONSUMER_ID,
        ACTIVITY_TIME, 
        INCOME, 
        MONEY, 
        PROBABILITY, 
        OPP_DATE, 
        PROJECT_ID, 
        OPP_NO, 
        SALES_EMP_ID, 
        OPP_STAGE, 
        RECORD_EMP, 
        RECORD_DATE, 
        RECORD_IP
	FROM
		OPPORTUNITY_HISTORY 
	WHERE
		OPP_ID=#attributes.opp_id# 
</cfquery>
<cfset opp_list = listdeleteduplicates(ValueList(get_opp_history.opp_stage,','))>
<cfset opp_pro_list = listdeleteduplicates(ValueList(get_opp_history.probability,','))>
<cfif listlen(opp_list,',')>
	<cfquery name="get_pro_stage" datasource="#dsn#">
		SELECT DISTINCT  PROCESS_ROW_ID, STAGE FROM PROCESS_TYPE_ROWS WHERE PROCESS_ROW_ID IN (#opp_list#)
	</cfquery>
  	<cfif get_pro_stage.recordcount>
		<cfscript>
			for(pind=1;pind lte get_pro_stage.recordcount; pind=pind+1)
				'opp_stage_#get_pro_stage.PROCESS_ROW_ID[pind]#' = get_pro_stage.STAGE[pind];
		</cfscript>
	</cfif>
</cfif>
<cfif listlen(opp_pro_list,',')>
	<cfquery name="get_probability" datasource="#dsn3#">
		SELECT 
    	    PROBABILITY_RATE_ID, 
            PROBABILITY_RATE, 
            PROBABILITY_NAME, 
            RECORD_EMP, 
            RECORD_DATE, 
            RECORD_IP, 
            UPDATE_EMP, 
            UPDATE_DATE, 
            UPDATE_IP 
        FROM 
	        SETUP_PROBABILITY_RATE 
        WHERE 
        	PROBABILITY_RATE_ID IN (#opp_pro_list#)
	</cfquery>
  	<cfif get_probability.recordcount>
		<cfscript>
			for(pind=1;pind lte get_probability.recordcount; pind=pind+1)
				'pro_#get_probability.PROBABILITY_RATE_ID[pind]#' = get_probability.probability_name[pind];
		</cfscript>
	</cfif>
</cfif>
<cfset str=ValueList(get_opp_history.OPP_HISTORY_ID)>
<cf_box title="#getLang('','Tarihçe',57473)#" collapsable="1" resize="1" popup_box="#iif(isdefined("attributes.draggable"),1,0)#">
    <cfset counter = 1>
    <cfif get_opp_history.recordcount>
        <cfset temp_ = 0>
        <cfoutput query="get_opp_history"> 
            <cfset temp_ = temp_ +1>
            <cf_seperator id="history_#temp_#" header="#dateformat(RECORD_DATE,dateformat_style)# (#timeformat(RECORD_DATE,timeformat_style)#) - #get_emp_info(RECORD_EMP,0,0)#" is_closed="1">
            <cf_box_elements>
                <div class="col col-6 col-md-6 col-sm-6 col-xs-12" id="history_#temp_#" style="display:none;">
                    <div class="form-group">
                        <label class="col col-6 col-md-6 col-sm-6 col-xs-12 bold"><cf_get_lang dictionary_id='57487.No'></label>
                        <div class="col col-6 col-md-6 col-sm-6 col-xs-12"> 
                            #get_opp_history.opp_no#
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col col-6 col-md-6 col-sm-6 col-xs-12 bold"><cf_get_lang dictionary_id='57482.Aşama'></label>
                        <div class="col col-6 col-md-6 col-sm-6 col-xs-12"> 
                            <cfset counter = listfindnocase(opp_currency_list,OPP_CURRENCY_ID)>
                            #get_opp_currencies.OPP_CURRENCY[counter]#
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col col-6 col-md-6 col-sm-6 col-xs-12 bold"><cf_get_lang dictionary_id='58859.Süreç'></label>
                        <div class="col col-6 col-md-6 col-sm-6 col-xs-12"> 
                            <cfif isdefined('opp_stage_#OPP_STAGE#')>#Evaluate('opp_stage_#OPP_STAGE#')#</cfif>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col col-6 col-md-6 col-sm-6 col-xs-12 bold"><cf_get_lang dictionary_id='57658.Üye'>/<cf_get_lang dictionary_id='57574.Şirket'></label>
                        <div class="col col-6 col-md-6 col-sm-6 col-xs-12"> 
                            <cfif len(PARTNER_ID)>#get_par_info(PARTNER_ID,0,1,0)#</cfif>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col col-6 col-md-6 col-sm-6 col-xs-12 bold"><cf_get_lang dictionary_id='33313.Satış Çalışanı'></label>
                        <div class="col col-6 col-md-6 col-sm-6 col-xs-12"> 
                            <cfif len(SALES_EMP_ID )>#get_emp_info(SALES_EMP_ID,0,0)#</cfif>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col col-6 col-md-6 col-sm-6 col-xs-12 bold"><cf_get_lang dictionary_id='58652.Olasılık'></label>
                        <div class="col col-6 col-md-6 col-sm-6 col-xs-12"> 
                            <cfif isdefined('pro_#PROBABILITY#')>#Evaluate('pro_#PROBABILITY#')#</cfif>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col col-6 col-md-6 col-sm-6 col-xs-12 bold"><cf_get_lang dictionary_id='34170.Hareket'></label>
                        <div class="col col-6 col-md-6 col-sm-6 col-xs-12"> 
                            <cfif len(ACTIVITY_TIME) and (ACTIVITY_TIME eq 1)><cf_get_lang dictionary_id='34171.Hemen'></cfif>
                            <cfif len(ACTIVITY_TIME) and (ACTIVITY_TIME eq 7)>1<cf_get_lang dictionary_id='58734.Hafta'></cfif>
                            <cfif len(ACTIVITY_TIME) and (ACTIVITY_TIME eq 30)>1<cf_get_lang dictionary_id='58724.Ay'> </cfif>
                            <cfif len(ACTIVITY_TIME) and (ACTIVITY_TIME eq 90)>3<cf_get_lang dictionary_id='58724.Ay'></cfif>
                            <cfif len(ACTIVITY_TIME) and (ACTIVITY_TIME eq 180)>6<cf_get_lang dictionary_id='58724.Ay'></cfif>
                            <cfif len(ACTIVITY_TIME) and (ACTIVITY_TIME eq 181)>6<cf_get_lang dictionary_id='58724.Ay'></cfif> 
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col col-6 col-md-6 col-sm-6 col-xs-12 bold"><cf_get_lang dictionary_id='31362.Başvuru Tarihi'></label>
                        <div class="col col-6 col-md-6 col-sm-6 col-xs-12"> 
                            #dateformat(OPP_DATE,dateformat_style)#
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col col-6 col-md-6 col-sm-6 col-xs-12 bold"><cf_get_lang dictionary_id='57483.Kayıt'></label>
                        <div class="col col-6 col-md-6 col-sm-6 col-xs-12"> 
                            #get_emp_info(RECORD_EMP,0,0)# #dateformat(RECORD_DATE,dateformat_style)#
                        </div>
                    </div>
                </div>
            </cf_box_elements>
        </cfoutput>
    </cfif>
</cf_box>