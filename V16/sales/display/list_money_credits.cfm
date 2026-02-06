<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.startdate" default="">
<cfparam name="attributes.finishdate" default="">
<cfparam name="attributes.act_type" default="1">
<cfif isdefined('attributes.is_submit') and attributes.is_submit eq 1>
	<cfif len(attributes.startdate)><cf_date tarih="attributes.startdate"></cfif>
	<cfif len(attributes.finishdate)><cf_date tarih="attributes.finishdate"></cfif>
    <cfif attributes.act_type eq 1 or attributes.act_type eq 2>
        <cfquery name="GET_MONEY_CREDITS" datasource="#DSN3#">
            SELECT
                OMC.ORDER_CREDIT_ID,
                OMC.ORDER_ID, 
                OMC.CREDIT_RATE,
                OMC.MONEY_CREDIT,
                OMC.VALID_DATE,
                OMC.USE_CREDIT,
                OMC.COMPANY_ID,
                OMC.CONSUMER_ID, 
                OMC.IS_TYPE,
                O.ORDER_NUMBER
            FROM
                ORDER_MONEY_CREDITS OMC,
                ORDERS O
            WHERE
                OMC.ORDER_ID = O.ORDER_ID
                <cfif isdefined('attributes.company_id') and len(attributes.company_id) and isdefined('attributes.member_name') and len(attributes.member_name)>
                    AND OMC.COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.company_id#">
                </cfif>
                <cfif isDefined("attributes.status") and len(attributes.status)>
                    AND OMC.MONEY_CREDIT_STATUS = <cfqueryparam cfsqltype="cf_sql_smallint" value="#attributes.status#">
                </cfif>
                <cfif isdefined('attributes.consumer_id') and len(attributes.consumer_id) and isdefined('attributes.member_name') and len(attributes.member_name)>
                    AND OMC.CONSUMER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.consumer_id#">
                </cfif>
                <cfif len(attributes.startdate)>
                    AND OMC.VALID_DATE >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.startdate#"> 
                </cfif>
                <cfif len(attributes.finishdate)>
                    AND OMC.VALID_DATE <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.finishdate#"> 
                </cfif>
                <cfif attributes.act_type eq 1>
                    AND ISNULL(IS_TYPE,0) = 0
                <cfelseif attributes.act_type eq 2>
                    AND ISNULL(IS_TYPE,0) = 1          	
                </cfif>
        UNION
            SELECT
                OMC.ORDER_CREDIT_ID,
                OMC.ORDER_ID, 
                OMC.CREDIT_RATE,
                OMC.MONEY_CREDIT,
                OMC.VALID_DATE,
                OMC.USE_CREDIT,
                OMC.COMPANY_ID,
                OMC.CONSUMER_ID,
                OMC.IS_TYPE,
                '' AS ORDER_NUMBER
            FROM
                ORDER_MONEY_CREDITS OMC
            WHERE
                OMC.ORDER_ID IS NULL
                <cfif isdefined('attributes.company_id') and len(attributes.company_id) and isdefined('attributes.member_name') and len(attributes.member_name)>
                    AND OMC.COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.company_id#">
                </cfif>
                <cfif isDefined("attributes.status") and len(attributes.status)>
                    AND OMC.MONEY_CREDIT_STATUS = <cfqueryparam cfsqltype="cf_sql_smallint" value="#attributes.status#">
                </cfif>
                <cfif isdefined('attributes.consumer_id') and len(attributes.consumer_id) and isdefined('attributes.member_name') and len(attributes.member_name)>
                    AND OMC.CONSUMER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.consumer_id#">
                </cfif>
                <cfif len(attributes.startdate)>
                    AND OMC.VALID_DATE >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.startdate#"> 
                </cfif>
                <cfif len(attributes.finishdate)>
                    AND OMC.VALID_DATE <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.finishdate#"> 
                </cfif>
                <cfif attributes.act_type eq 1>
                    AND ISNULL(IS_TYPE,0) = 0
                <cfelseif attributes.act_type eq 2>
                    AND ISNULL(IS_TYPE,0) = 1
                </cfif>
        </cfquery>
    <cfelse>
     	<cfif (attributes.act_type eq 3 or attributes.act_type eq 4)>
			<cfif attributes.listing_type eq 2>  
                <cfquery name="GET_MONEY_CREDITS" datasource="#DSN3#">      
                    SELECT
                        OMC.ORDER_CREDIT_ID,
                        OMC.ORDER_ID, 
                        OMC.CREDIT_RATE,
                        OMC.MONEY_CREDIT,
                        OMC.VALID_DATE,
                        OMC.USE_CREDIT,
                        OMC.COMPANY_ID,
                        OMC.CONSUMER_ID, 
                        OMC.IS_TYPE,
                        OMC.TARGET_MARKET_ID,
                        O.ORDER_NUMBER
                    FROM
                        ORDER_MONEY_CREDITS OMC,
                        ORDERS O
                    WHERE
                        OMC.ORDER_ID = O.ORDER_ID
                        <cfif isdefined('attributes.company_id') and len(attributes.company_id) and isdefined('attributes.member_name') and len(attributes.member_name)>
                            AND OMC.COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.company_id#">
                        </cfif>
                        <cfif isDefined("attributes.status") and len(attributes.status)>
                            AND OMC.MONEY_CREDIT_STATUS = <cfqueryparam cfsqltype="cf_sql_smallint" value="#attributes.status#">
                        </cfif>
                        <cfif isdefined('attributes.consumer_id') and len(attributes.consumer_id) and isdefined('attributes.member_name') and len(attributes.member_name)>
                            AND OMC.CONSUMER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.consumer_id#">
                        </cfif>
                        <cfif len(attributes.startdate)>
                            AND OMC.VALID_DATE >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.startdate#"> 
                        </cfif>
                        <cfif len(attributes.finishdate)>
                            AND OMC.VALID_DATE <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.finishdate#"> 
                        </cfif>
                        <cfif isDefined("attributes.record_startdate") and len(attributes.record_startdate)>
                        	AND OMC.RECORD_DATE >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.record_startdate#"> 
                        </cfif> 
                        <cfif isDefined("attributes.record_finishdate") and len(attributes.record_finishdate)>
                        	AND OMC.RECORD_DATE <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.record_finishdate#"> 
                        </cfif> 
                        AND ISNULL(IS_TYPE,0) = 2          	
                UNION
                    SELECT
                        OMC.ORDER_CREDIT_ID,
                        OMC.ORDER_ID, 
                        OMC.CREDIT_RATE,
                        OMC.MONEY_CREDIT,
                        OMC.VALID_DATE,
                        OMC.USE_CREDIT,
                        OMC.COMPANY_ID,
                        OMC.CONSUMER_ID,
                        OMC.IS_TYPE,
                        OMC.TARGET_MARKET_ID,
                        '' AS ORDER_NUMBER
                    FROM
                        ORDER_MONEY_CREDITS OMC
                    WHERE
                        OMC.ORDER_ID IS NULL
                        <cfif isdefined('attributes.company_id') and len(attributes.company_id) and isdefined('attributes.member_name') and len(attributes.member_name)>
                            AND OMC.COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.company_id#">
                        </cfif>
                        <cfif isDefined("attributes.status") and len(attributes.status)>
                            AND OMC.MONEY_CREDIT_STATUS = <cfqueryparam cfsqltype="cf_sql_smallint" value="#attributes.status#">
                        </cfif>
                        <cfif isdefined('attributes.consumer_id') and len(attributes.consumer_id) and isdefined('attributes.member_name') and len(attributes.member_name)>
                            AND OMC.CONSUMER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.consumer_id#">
                        </cfif>
                        <cfif len(attributes.startdate)>
                            AND OMC.VALID_DATE >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.startdate#"> 
                        </cfif>
                        <cfif len(attributes.finishdate)>
                            AND OMC.VALID_DATE <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.finishdate#"> 
                        </cfif>
                        <cfif isDefined("attributes.record_startdate") and len(attributes.record_startdate)>
                        	AND OMC.RECORD_DATE >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.record_startdate#"> 
                        </cfif> 
                        <cfif isDefined("attributes.record_finishdate") and len(attributes.record_finishdate)>
                        	AND OMC.RECORD_DATE <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.record_finishdate#"> 
                        </cfif> 
                        AND ISNULL(IS_TYPE,0) = 2
                    	<cfif attributes.act_type eq 4>
                        UNION
                			 SELECT
                                OMC.ORDER_CREDIT_ID,
                                OMC.ORDER_ID, 
                                OMC.CREDIT_RATE,
                                OMC.MONEY_CREDIT,
                                OMC.VALID_DATE,
                                OMC.USE_CREDIT,
                                OMC.COMPANY_ID,
                                OMC.CONSUMER_ID, 
                                OMC.IS_TYPE,
                                '' TARGET_MARKET_ID,
                                O.ORDER_NUMBER
                            FROM
                                ORDER_MONEY_CREDITS OMC,
                                ORDERS O
                            WHERE
                                OMC.ORDER_ID = O.ORDER_ID
                                <cfif isdefined('attributes.company_id') and len(attributes.company_id) and isdefined('attributes.member_name') and len(attributes.member_name)>
                                    AND OMC.COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.company_id#">
                                </cfif>
                                <cfif isDefined("attributes.status") and len(attributes.status)>
                                    AND OMC.MONEY_CREDIT_STATUS = <cfqueryparam cfsqltype="cf_sql_smallint" value="#attributes.status#">
                                </cfif>
                                <cfif isdefined('attributes.consumer_id') and len(attributes.consumer_id) and isdefined('attributes.member_name') and len(attributes.member_name)>
                                    AND OMC.CONSUMER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.consumer_id#">
                                </cfif>
                                <cfif len(attributes.startdate)>
                                    AND OMC.VALID_DATE >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.startdate#"> 
                                </cfif>
                                <cfif len(attributes.finishdate)>
                                    AND OMC.VALID_DATE <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.finishdate#"> 
                                </cfif>
                                AND ISNULL(IS_TYPE,0) = 1          	
                        UNION
                            SELECT
                                OMC.ORDER_CREDIT_ID,
                                OMC.ORDER_ID, 
                                OMC.CREDIT_RATE,
                                OMC.MONEY_CREDIT,
                                OMC.VALID_DATE,
                                OMC.USE_CREDIT,
                                OMC.COMPANY_ID,
                                OMC.CONSUMER_ID,
                                OMC.IS_TYPE,
                                '' TARGET_MARKET_ID,
                                '' AS ORDER_NUMBER
                            FROM
                                ORDER_MONEY_CREDITS OMC
                            WHERE
                                OMC.ORDER_ID IS NULL
                                <cfif isdefined('attributes.company_id') and len(attributes.company_id) and isdefined('attributes.member_name') and len(attributes.member_name)>
                                    AND OMC.COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.company_id#">
                                </cfif>
                                <cfif isDefined("attributes.status") and len(attributes.status)>
                                    AND OMC.MONEY_CREDIT_STATUS = <cfqueryparam cfsqltype="cf_sql_smallint" value="#attributes.status#">
                                </cfif>
                                <cfif isdefined('attributes.consumer_id') and len(attributes.consumer_id) and isdefined('attributes.member_name') and len(attributes.member_name)>
                                    AND OMC.CONSUMER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.consumer_id#">
                                </cfif>
                                <cfif len(attributes.startdate)>
                                    AND OMC.VALID_DATE >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.startdate#"> 
                                </cfif>
                                <cfif len(attributes.finishdate)>
                                    AND OMC.VALID_DATE <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.finishdate#"> 
                                </cfif>
                                AND ISNULL(IS_TYPE,0) = 1
                		</cfif>
                </cfquery>
            </cfif>   
        </cfif>
    </cfif>
<cfelse>
	<cfset get_money_credits.recordcount= 0>
</cfif>
<cfscript>
	url_str = "keyword=#attributes.keyword#";
</cfscript>
<cfif not((attributes.act_type eq 3 or attributes.act_type eq 4) and attributes.listing_type eq 1)>
    <cfparam name="attributes.page" default="1">
    <cfparam name="attributes.maxrows" default='#session.ep.maxrows#'> 
    <cfparam name="attributes.totalrecords" default="#get_money_credits.recordcount#">
	<cfset attributes.startrow = ((attributes.page-1)*attributes.maxrows) + 1>
</cfif>
<cfif attributes.act_type eq 1>
	<cfsavecontent variable="head"><cf_get_lang dictionary_id='40927.Parapuan'></cfsavecontent>
<cfelseif attributes.act_type eq 2>
	<cfsavecontent variable="head"><cf_get_lang dictionary_id='54885.Hediye Çeki'></cfsavecontent>
<cfelseif attributes.act_type eq 4>
	<cfsavecontent variable="head"><cf_get_lang dictionary_id='61118.Hediye Çeki ve İndirim Kuponu'></cfsavecontent>
<cfelseif attributes.act_type eq 3>
	<cfsavecontent variable="head"><cf_get_lang dictionary_id='40897.İndirim Kuponu'></cfsavecontent>
</cfif>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box>
        <cfform name="order_form" method="post" action="#request.self#?fuseaction=sales.list_money_credits_gift">
            <input type="hidden" name="is_submit" id="is_submit" value="1">
            <cf_box_search more="0">
                <div class="form-group">
                    <div class="input-group">
                        <input type="hidden" name="consumer_id" id="consumer_id" value="<cfif isdefined("attributes.consumer_id")><cfoutput>#attributes.consumer_id#</cfoutput></cfif>">
                        <input type="hidden" name="company_id" id="company_id" value="<cfif isdefined("attributes.company_id")><cfoutput>#attributes.company_id#</cfoutput></cfif>">
                        <input type="hidden" name="member_type" id="member_type" value="<cfif isdefined("attributes.member_type")><cfoutput>#attributes.member_type#</cfoutput></cfif>">
                        <input name="member_name" type="text" id="member_name" style="width:90px;" onFocus="AutoComplete_Create('member_name','MEMBER_NAME,MEMBER_PARTNER_NAME,MEMBER_CODE','MEMBER_NAME,MEMBER_PARTNER_NAME,MEMBER_CODE','get_member_autocomplete','\'1,2\'','CONSUMER_ID,COMPANY_ID,MEMBER_TYPE','consumer_id,company_id,member_type','','3','250');" placeholder="<cf_get_lang dictionary_id='57519.Cari Hesap'>" value="<cfif isdefined("attributes.member_name") and len(attributes.member_name)><cfoutput>#attributes.member_name#</cfoutput></cfif>" autocomplete="off">
                        <cfset str_linke_ait="&field_consumer=order_form.consumer_id&field_comp_id=order_form.company_id&field_member_name=order_form.member_name&field_type=order_form.member_type">
                        <span class="input-group-addon icon-ellipsis"  onClick="windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_list_all_cons#str_linke_ait#</cfoutput><cfif session.ep.isBranchAuthorization>&is_store_module=1</cfif>&select_list=7,8&keyword='+encodeURIComponent(document.order_form.member_name.value),'list');"></span>
                    </div>
                </div>
                <cfif isDefined('attributes.act_type') and (attributes.act_type eq 3 or attributes.act_type eq 4)>
                    <div class="form-group">
                        <cfsavecontent variable="placeholder1"><cf_get_lang dictionary_id='57483.Kayıt'> <cf_get_lang dictionary_id='57501.Başlangıç'></cfsavecontent>
                        <div class="input-group">
                            <cfsavecontent variable="message"><cf_get_lang dictionary_id='58745.Başlama Tarihi Girmelisiniz'></cfsavecontent>
                            <cfif isDefined('attributes.record_startdate') and len(attributes.record_startdate)>
                                <cfinput type="text" name="record_startdate" id="record_startdate" placeholder="#placeholder1#" value="#attributes.record_startdate#" validate="#validate_style#" maxlength="10" message="#message#" style="width:63px;">	
                                <cfelse>
                                <cfinput type="text" name="record_startdate" id="record_startdate" placeholder="#placeholder1#" value="" validate="#validate_style#" maxlength="10" message="#message#" style="width:63px;">	    
                            </cfif>
                            <span class="input-group-addon"><cf_wrk_date_image date_field="record_startdate"></span>
                        </div>
                    </div>
                    <div class="form-group">
                        <cfsavecontent variable="placeholder2"><cf_get_lang dictionary_id='57483.Kayıt'> <cf_get_lang dictionary_id='57502.Bitiş'></cfsavecontent>
                        <div class="input-group">
                            <cfsavecontent variable="message"><cf_get_lang dictionary_id='57739.Bitiş Tarihi Girmelisiniz'></cfsavecontent>
                            <cfif isDefined('attributes.record_finishdate') and len(attributes.record_finishdate)>
                                <cfinput type="text" name="record_finishdate" id="record_finishdate" placeholder="#placeholder2#" value="#attributes.record_finishdate#" validate="#validate_style#" maxlength="10" message="#message#" style="width:63px;">
                                <cfelse>
                                    <cfinput type="text" name="record_finishdate" id="record_finishdate" placeholder="#placeholder2#" value="" validate="#validate_style#" maxlength="10" message="#message#" style="width:63px;">                            
                            </cfif>
                            <span class="input-group-addon"><cf_wrk_date_image date_field="record_finishdate"></span>
                        </div>
                    </div>
                </cfif>
                <div class="form-group">
                    <cfsavecontent variable="placeholder3"><cf_get_lang dictionary_id="33134.Geçerlilik"> <cf_get_lang dictionary_id='57501.Başlangıç'></cfsavecontent>
                    <div class="input-group">
                        <cfsavecontent variable="message"><cf_get_lang dictionary_id='58745.Başlama Tarihi Girmelisiniz'></cfsavecontent>
                        <cfinput validate="#validate_style#" maxlength="10" placeholder="#placeholder3#" message="#message#" type="text" name="startdate" style="width:63px;" value="#dateformat(attributes.startdate,dateformat_style)#">
                        <span class="input-group-addon"><cf_wrk_date_image date_field="startdate"></span>
                    </div>
                </div>
                <div class="form-group">
                    <cfsavecontent variable="placeholder4"><cf_get_lang dictionary_id="33134.Geçerlilik"> <cf_get_lang dictionary_id='57502.Bitiş'></cfsavecontent>
                    <div class="input-group">
                        <cfsavecontent variable="message"><cf_get_lang dictionary_id='57739.Bitiş Tarihi Girmelisiniz'></cfsavecontent>
                        <cfinput validate="#validate_style#" maxlength="10" placeholder="#placeholder4#" message="#message#" type="text" name="finishdate" style="width:63px;" value="#dateformat(attributes.finishdate,dateformat_style)#">
                        <span class="input-group-addon"><cf_wrk_date_image date_field="finishdate"></span>
                    </div>
                </div>
                <cfif isDefined('attributes.act_type') and (attributes.act_type eq 2 or attributes.act_type eq 3 or attributes.act_type eq 4)>
                    <div class="form-group">
                        <select name="listing_type" id="listing_type">
                            <option value="1" <cfif isDefined('attributes.listing_type') and attributes.listing_type eq 1>selected</cfif>><cf_get_lang dictionary_id='29539.Satir Bazinda'></option>
                            <option value="2" <cfif isDefined('attributes.listing_type') and attributes.listing_type eq 2>selected</cfif>><cf_get_lang dictionary_id='57660.Belge Bazinda'></option>
                        </select>
                    </div>
                </cfif>
                <cfif isDefined('attributes.act_type') and (attributes.act_type eq 2 or attributes.act_type eq 3 or attributes.act_type eq 4)>
                    <div class="form-group">
                        <select name="act_type" id="act_type">
                            <option value="2" <cfif isDefined('attributes.act_type') and attributes.act_type eq 2>selected</cfif>><cf_get_lang dictionary_id="41445.Hediye Çeki"></option>
                            <option value="3" <cfif isDefined('attributes.act_type') and attributes.act_type eq 3>selected</cfif>><cf_get_lang dictionary_id="40897.İndirim Kuponu"></option>
                            <option value="4" <cfif isDefined('attributes.act_type') and attributes.act_type eq 4>selected</cfif>><cf_get_lang dictionary_id="57708.Tümü"></option>
                        </select>
                    </div>
                <cfelse>
                    <div class="form-group">
                        <input type="hidden" name="act_type" id="act_type" value="<cfoutput>#attributes.act_type#</cfoutput>">
                    </div>
                </cfif>
                <div class="form-group">
                    <select name="status" id="status">
                        <option value=""><cf_get_lang dictionary_id='57708.Tümü'></option>
                        <option value="0"<cfif isdefined('attributes.status') and (attributes.status eq 0)> selected</cfif>><cf_get_lang dictionary_id='57494.Pasif'></option>
                        <option value="1"<cfif isdefined('attributes.status') and (attributes.status eq 1)> selected</cfif>><cf_get_lang dictionary_id='57493.Aktif'></option>
                    </select>
                </div>
                <div class="form-group small">
                    <cfsavecontent variable="message"><cf_get_lang dictionary_id='57537.Sayi_Hatasi_Mesaj'></cfsavecontent>
                    <cfinput type="text" name="maxrows" value="#attributes.maxrows#" required="yes" validate="integer" range="1,999" message="#message#" maxlength="3" style="width:25px;">
                </div>
                <div class="form-group">
                    <cf_wrk_search_button button_type="4">
                    <cf_workcube_file_action pdf='1' mail='1' doc='1' print='1'>
                </div>
            </cf_box_search>
        </cfform>
    </cf_box>
    

        <cfif attributes.act_type eq 1 or attributes.act_type eq 2>
            <cf_box title="#head#" uidrop="1" hide_table_column="1">
                <cf_grid_list>
                    <thead>
                        <tr>
                            <th style="width:30px;"><cf_get_lang dictionary_id='57487.No'></th>
                            <th><cf_get_lang dictionary_id='57611.Sipariş'></th>
                            <th><cf_get_lang dictionary_id='57519.Cari Hesap'></th>
                            <cfif attributes.act_type eq 1>
                                <th><cf_get_lang dictionary_id="40898.Kazanılan Parapuan"></th>
                                <th><cf_get_lang dictionary_id="40901.Kullanılan Parapuan"></th>
                                <th><cf_get_lang dictionary_id="40902.Parapuan Yüzdesi"> %</th>
                                <th><cf_get_lang dictionary_id="40905.Parapuan Geçerlilik Tarihi"></th>
                            <cfelse>
                                <th><cf_get_lang dictionary_id='41445.Hediye Çeki'></th>
                                <th><cf_get_lang dictionary_id="40907.Kullanılan Tutar"></th>
                                <th><cf_get_lang dictionary_id='58624.Geçerlilik Tarihi'></th>
                            </cfif>
                            <cfif isDefined('attributes.act_type') and attributes.act_type eq 3> 
                                <th width="20" class="header_icn_none">
                                    <a href="javascript://" onclick="<cfoutput>#request.self#</cfoutput>?fuseaction=sales.popup_add_discount_coupon"><i class="fa fa-plus" title="<cf_get_lang dictionary_id='57582.Ekle'>" alt="<cf_get_lang dictionary_id='57582.Ekle'>"></i></a>
                                </th>
                            </cfif>
                        </tr>
                    </thead>
                    <tbody>
                        <cfif attributes.act_type eq 1><cfset colspan_ = 8><cfelse><cfset colspan_ = 7></cfif>
                        <cfif isdefined('attributes.is_submit') and attributes.is_submit eq 1>
                            <cfif get_money_credits.recordcount>
                                <cfscript>
                                    company_id_list='';
                                    consumer_id_list='';
                                </cfscript>
                                <cfoutput query="get_money_credits" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
                                    <cfif len(company_id) and not listfind(company_id_list,company_id)>
                                        <cfset company_id_list=listappend(company_id_list,company_id)>
                                    </cfif>
                                    <cfif len(consumer_id) and not listfind(consumer_id_list,consumer_id)>
                                        <cfset consumer_id_list=listappend(consumer_id_list,consumer_id)>
                                    </cfif>
                                    <cfif len(company_id_list)>
                                        <cfset company_id_list = listsort(company_id_list,"numeric","ASC",",")>
                                        <cfquery name="GET_COMPANY_DETAIL" datasource="#DSN#">
                                            SELECT COMPANY_ID, NICKNAME, FULLNAME FROM COMPANY WHERE COMPANY_ID IN (#company_id_list#) ORDER BY COMPANY_ID
                                        </cfquery>
                                    </cfif>
                                    <cfif len(consumer_id_list)>
                                        <cfset consumer_id_list = listsort(consumer_id_list,"numeric","ASC",",")>
                                        <cfquery name="GET_CONSUMER_DETAIL" datasource="#DSN#">
                                            SELECT CONSUMER_ID,CONSUMER_NAME,CONSUMER_SURNAME FROM CONSUMER WHERE CONSUMER_ID IN (#consumer_id_list#) ORDER BY CONSUMER_ID
                                        </cfquery>
                                    </cfif>
                                    <tr>
                                        <td>#currentrow#</td>
                                        <td>
                                            <cfif len(order_id)>
                                                <a href="javascript://" onclick="AjaxPageLoad('#request.self#?fuseaction=#listgetat(attributes.fuseaction,1,'.')#.list_order&event=upd&order_id=#order_id#','sales',1);" class="tableyazi">#order_number#</a>
                                            <cfelse>
                                                <cf_get_lang dictionary_id="40908.Yüklenen Parapuan">
                                            </cfif>
                                        </td>
                                        <td><cfif len(company_id)>
                                                <a href="javascript://" class="tableyazi" onclick="windowopen('#request.self#?fuseaction=objects.popup_com_det&company_id=#company_id#','medium');">#get_company_detail.nickname[listfind(company_id_list,company_id,',')]#</a>
                                            </cfif>
                                            <cfif len(consumer_id)>
                                                <a href="javascript://" class="tableyazi" onclick="windowopen('#request.self#?fuseaction=objects.popup_con_det&con_id=#consumer_id#','medium');">#get_consumer_detail.consumer_name[listfind(consumer_id_list,consumer_id,',')]# #get_consumer_detail.consumer_surname[listfind(consumer_id_list,consumer_id,',')]#</a>
                                            </cfif>
                                        </td>
                                        <td>#TlFormat(money_credit)#</td>
                                        <td>#TlFormat(use_credit)#</td>
                                            <cfif attributes.act_type eq 1>
                                        <td >#credit_rate#</td>
                                            </cfif>
                                        <td>#DateFormat(valid_date,dateformat_style)#</td>
                                        <td>
                                        <cfif len(is_type) and is_type eq 2> 
                                            <a href="javascript://" onClick="windowopen('#request.self#?fuseaction=sales.popup_upd_discount_coupon&order_credit_id=#order_credit_id#&is_type=#is_type#','small');"><i class="fa fa-pencil" title="<cf_get_lang dictionary_id='57464.Güncelle'>" alt="<cf_get_lang dictionary_id='57464.Güncelle'>"></i></a>   
                                        <cfelse>
                                            <a href="javascript://" onClick="windowopen('#request.self#?fuseaction=sales.popup_detail_money_credit&order_credit_id=#order_credit_id#','small');"><i class="fa fa-pencil" title="<cf_get_lang dictionary_id='57464.Güncelle'>" alt="<cf_get_lang dictionary_id='57464.Güncelle'>"></i></a>
                                        </cfif>
                                        </td>
                                    </tr>
                                </cfoutput>
                            <cfelse>
                                <tr class="color-row" style="height:20px;">
                                    <td colspan="<cfoutput>#colspan_#</cfoutput>"><cf_get_lang dictionary_id="57484.Kayıt Yok">!</td>
                                </tr>
                            </cfif>  
                        <cfelse>
                            <tr>
                                <td colspan="<cfoutput>#colspan_#</cfoutput>"><cf_get_lang dictionary_id="57701.Filtre Ediniz">!</td>
                            </tr>
                        </cfif>  
                    </tbody>
                </cf_grid_list>  
            </cf_box>  
        <cfelse>			
            <cfif (attributes.act_type eq 3 or attributes.act_type eq 4) and attributes.listing_type eq 1>
                <cf_box title="#head#" uidrop="1" hide_table_column="1">
                    <cfset colspan_ = 6>
                    <cf_grid_list>
                        <thead>
                            <tr>
                                <th width="30"><cf_get_lang dictionary_id='57487.No'></th>
                                <th><cf_get_lang dictionary_id='57611.Sipariş'></th>
                                <th><cf_get_lang dictionary_id='41953.Üye Adı'></th>
                                <th><cf_get_lang dictionary_id="57905.Hedef Kitle"></th>
                                <th><cf_get_lang dictionary_id="58624.Geçerlilik Tarihi"></th>
                                <cfif isDefined('attributes.act_type') and attributes.act_type eq 3> 
                                    <th width="20">
                                        <a href="javascript://" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=sales.popup_add_discount_coupon','small');"><i class="fa fa-plus" title="<cf_get_lang dictionary_id='57582.Ekle'>" alt="<cf_get_lang dictionary_id='57582.Ekle'>"></i></a>
                                    </th>
                                </cfif>
                            </tr>
                        </thead>
                        <tbody>
                            <cfif isdefined('attributes.is_submit') and attributes.is_submit eq 1>
                                <cfquery name="GET_MONEY_CREDITS_2" datasource="#DSN3#">
                                    SELECT
                                        OMC.ORDER_CREDIT_ID,
                                        OMC.ORDER_ID, 
                                        OMC.CREDIT_RATE,
                                        OMC.MONEY_CREDIT,
                                        OMC.VALID_DATE,
                                        OMC.USE_CREDIT,
                                        OMC.COMPANY_ID,
                                        OMC.CONSUMER_ID, 
                                        OMC.IS_TYPE,
                                        OMC.TARGET_MARKET_ID,
                                        O.ORDER_NUMBER
                                    FROM
                                        ORDER_MONEY_CREDITS OMC,
                                        ORDERS O
                                    WHERE
                                        OMC.ORDER_ID = O.ORDER_ID
                                        <!---<cfif isdefined('attributes.company_id') and len(attributes.company_id) and isdefined('attributes.member_name') and len(attributes.member_name)>
                                            AND OMC.COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.company_id#">
                                        </cfif>--->
                                        <cfif isDefined("attributes.status") and len(attributes.status)>
                                            AND OMC.MONEY_CREDIT_STATUS = <cfqueryparam cfsqltype="cf_sql_smallint" value="#attributes.status#">
                                        </cfif>
                                    <!--- <cfif isdefined('attributes.consumer_id') and len(attributes.consumer_id) and isdefined('attributes.member_name') and len(attributes.member_name)>
                                            AND OMC.CONSUMER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.consumer_id#">
                                        </cfif>--->
                                        <cfif len(attributes.startdate)>
                                            AND OMC.VALID_DATE >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.startdate#"> 
                                        </cfif>
                                        <cfif len(attributes.finishdate)>
                                            AND OMC.VALID_DATE <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.finishdate#"> 
                                        </cfif>
                                        <cfif isDefined("attributes.record_startdate") and len(attributes.record_startdate)>
                                            AND OMC.RECORD_DATE >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.record_startdate#"> 
                                        </cfif> 
                                        <cfif isDefined("attributes.record_finishdate") and len(attributes.record_finishdate)>
                                            AND OMC.RECORD_DATE <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.record_finishdate#"> 
                                        </cfif> 
                                        AND ISNULL(IS_TYPE,0) = 2          	
                                UNION
                                    SELECT
                                        OMC.ORDER_CREDIT_ID,
                                        OMC.ORDER_ID, 
                                        OMC.CREDIT_RATE,
                                        OMC.MONEY_CREDIT,
                                        OMC.VALID_DATE,
                                        OMC.USE_CREDIT,
                                        OMC.COMPANY_ID,
                                        OMC.CONSUMER_ID,
                                        OMC.IS_TYPE,
                                        OMC.TARGET_MARKET_ID,
                                        '' AS ORDER_NUMBER
                                    FROM
                                        ORDER_MONEY_CREDITS OMC
                                    WHERE
                                        OMC.ORDER_ID IS NULL
                                        <cfif isDefined("attributes.status") and len(attributes.status)>
                                            AND OMC.MONEY_CREDIT_STATUS = <cfqueryparam cfsqltype="cf_sql_smallint" value="#attributes.status#">
                                        </cfif>
                                        <cfif len(attributes.startdate)>
                                            AND OMC.VALID_DATE >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.startdate#"> 
                                        </cfif>
                                        <cfif len(attributes.finishdate)>
                                            AND OMC.VALID_DATE <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.finishdate#"> 
                                        </cfif>
                                        <cfif isDefined("attributes.record_startdate") and len(attributes.record_startdate)>
                                            AND OMC.RECORD_DATE >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.record_startdate#"> 
                                        </cfif> 
                                        <cfif isDefined("attributes.record_finishdate") and len(attributes.record_finishdate)>
                                            AND OMC.RECORD_DATE <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.record_finishdate#"> 
                                        </cfif> 
                                        AND ISNULL(IS_TYPE,0) = 2    
                                        <cfif attributes.act_type eq 4>
                                            UNION
                                            SELECT
                                                OMC.ORDER_CREDIT_ID,
                                                OMC.ORDER_ID, 
                                                OMC.CREDIT_RATE,
                                                OMC.MONEY_CREDIT,
                                                OMC.VALID_DATE,
                                                OMC.USE_CREDIT,
                                                OMC.COMPANY_ID,
                                                OMC.CONSUMER_ID, 
                                                OMC.IS_TYPE,
                                                '' AS TARGET_MARKET_ID,
                                                O.ORDER_NUMBER
                                            FROM
                                                ORDER_MONEY_CREDITS OMC,
                                                ORDERS O
                                            WHERE
                                                OMC.ORDER_ID = O.ORDER_ID
                                                <cfif isdefined('attributes.company_id') and len(attributes.company_id) and isdefined('attributes.member_name') and len(attributes.member_name)>
                                                    AND OMC.COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.company_id#">
                                                </cfif>
                                                <cfif isDefined("attributes.status") and len(attributes.status)>
                                                    AND OMC.MONEY_CREDIT_STATUS = <cfqueryparam cfsqltype="cf_sql_smallint" value="#attributes.status#">
                                                </cfif>
                                                <cfif isdefined('attributes.consumer_id') and len(attributes.consumer_id) and isdefined('attributes.member_name') and len(attributes.member_name)>
                                                    AND OMC.CONSUMER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.consumer_id#">
                                                </cfif>
                                                <cfif len(attributes.startdate)>
                                                    AND OMC.VALID_DATE >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.startdate#"> 
                                                </cfif>
                                                <cfif len(attributes.finishdate)>
                                                    AND OMC.VALID_DATE <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.finishdate#"> 
                                                </cfif>
                                                AND ISNULL(IS_TYPE,0) = 1          	
                                            UNION
                                            SELECT
                                                OMC.ORDER_CREDIT_ID,
                                                OMC.ORDER_ID, 
                                                OMC.CREDIT_RATE,
                                                OMC.MONEY_CREDIT,
                                                OMC.VALID_DATE,
                                                OMC.USE_CREDIT,
                                                OMC.COMPANY_ID,
                                                OMC.CONSUMER_ID,
                                                OMC.IS_TYPE,
                                                '' AS TARGET_MARKET_ID,
                                                '' AS ORDER_NUMBER
                                            FROM
                                                ORDER_MONEY_CREDITS OMC
                                            WHERE
                                                OMC.ORDER_ID IS NULL
                                                <cfif isdefined('attributes.company_id') and len(attributes.company_id) and isdefined('attributes.member_name') and len(attributes.member_name)>
                                                    AND OMC.COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.company_id#">
                                                </cfif>
                                                <cfif isDefined("attributes.status") and len(attributes.status)>
                                                    AND OMC.MONEY_CREDIT_STATUS = <cfqueryparam cfsqltype="cf_sql_smallint" value="#attributes.status#">
                                                </cfif>
                                                <cfif isdefined('attributes.consumer_id') and len(attributes.consumer_id) and isdefined('attributes.member_name') and len(attributes.member_name)>
                                                    AND OMC.CONSUMER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.consumer_id#">
                                                </cfif>
                                                <cfif len(attributes.startdate)>
                                                    AND OMC.VALID_DATE >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.startdate#"> 
                                                </cfif>
                                                <cfif len(attributes.finishdate)>
                                                    AND OMC.VALID_DATE <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.finishdate#"> 
                                                </cfif>
                                                AND ISNULL(IS_TYPE,0) = 1
                                        </cfif>    	
                                </cfquery>
                                <cfscript>
                                    company_id_list='';
                                    consumer_id_list='';
                                    tmarket_list='';
                                </cfscript>
                                <cfloop query="get_money_credits_2">	
                                    <cfif not listfind(tmarket_list,target_market_id) and len(target_market_id)>
                                        <cfset tmarket_list = listappend(tmarket_list,target_market_id,',')>
                                    </cfif>
                                </cfloop>
                                <cfinclude template="../query/get_targetmarket.cfm">
                                <cfinclude template="../query/get_target_list_members.cfm">
                                <cfif get_members.recordcount or get_money_credits_2.recordcount>
                                    <cfquery name="GET_MONEY_CREDITS" dbtype="query">
                                        <cfif GET_MEMBERS.recordcount>
                                            SELECT
                                                TYPE,
                                                MEMBER_TYPE,
                                                MEMBER_NAME,
                                                MEMBER_SURNAME,
                                                TARGET_MARKET,
                                                ORDER_CREDIT_ID,
                                                VALID_DATE,
                                                IS_TYPE
                                            FROM
                                                GET_MEMBERS
                                            WHERE
                                                <Cfif isdefined('attributes.consumer_id') and len(attributes.consumer_id) and isdefined('attributes.member_name') and len(attributes.member_name)>
                                                    MEMBER_TYPE IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.consumer_id#">) AND
                                                    TYPE = 1
                                                <cfelseif isdefined('attributes.company_id') and len(attributes.company_id) and isdefined('attributes.member_name') and len(attributes.member_name)>
                                                    MEMBER_TYPE IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.company_id#">) AND 
                                                    TYPE = 2
                                                <cfelse>
                                                    1 = 1
                                                </cfif> 
                                            UNION ALL  
                                        </cfif> 
                                        SELECT 
                                            1 AS TYPE,
                                            CONSUMER_ID MEMBER_TYPE,
                                            '' MEMBER_NAME,
                                            '' MEMBER_SURNAME,
                                            '' TARGET_MARKET,
                                            ORDER_CREDIT_ID,
                                            '' VALID_DATE,
                                            2 IS_TYPE
                                        FROM 
                                            GET_MONEY_CREDITS_2 
                                        WHERE 
                                            <cfif isdefined('attributes.consumer_id') and len(attributes.consumer_id) and isdefined('attributes.member_name') and len(attributes.member_name)>
                                                CONSUMER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.consumer_id#"> AND
                                            <cfelseif isdefined('attributes.company_id') and len(attributes.company_id) and isdefined('attributes.member_name') and len(attributes.member_name)>
                                                1 = 0 AND
                                            </cfif>
                                            COMPANY_ID IS NULL AND 
                                            TARGET_MARKET_ID IS NULL   	
                                        UNION ALL
                                        SELECT 
                                            2 AS TYPE,
                                            COMPANY_ID MEMBER_TYPE,
                                            '' MEMBER_NAME,
                                            '' MEMBER_SURNAME,
                                            '' TARGET_MARKET,
                                            ORDER_CREDIT_ID,
                                            '' VALID_DATE,
                                            2 IS_TYPE
                                        FROM 
                                            GET_MONEY_CREDITS_2 
                                        WHERE 
                                            <cfif isdefined('attributes.company_id') and len(attributes.company_id) and isdefined('attributes.member_name') and len(attributes.member_name)>
                                                COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.company_id#"> AND
                                            <cfelseif isdefined('attributes.consumer_id') and len(attributes.consumer_id) and isdefined('attributes.member_name') and len(attributes.member_name)>
                                                1 = 0 AND                     
                                            </cfif>
                                            CONSUMER_ID IS NULL AND 
                                            TARGET_MARKET_ID IS NULL 
                                        <cfif attributes.act_type eq 4>
                                            UNION
                                            SELECT 
                                                2 AS TYPE,
                                                COMPANY_ID MEMBER_TYPE,
                                                '' MEMBER_NAME,
                                                '' MEMBER_SURNAME,
                                                '' TARGET_MARKET,
                                                ORDER_CREDIT_ID,
                                                '' VALID_DATE,
                                                IS_TYPE
                                            FROM 
                                                GET_MONEY_CREDITS_2 
                                            WHERE 
                                                <cfif isdefined('attributes.company_id') and len(attributes.company_id) and isdefined('attributes.member_name') and len(attributes.member_name)>
                                                    COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.company_id#"> AND
                                                <cfelseif isdefined('attributes.consumer_id') and len(attributes.consumer_id) and isdefined('attributes.member_name') and len(attributes.member_name)>
                                                    1 = 0 AND                     
                                                </cfif>
                                                IS_TYPE = 1 AND
                                                CONSUMER_ID IS NULL AND 
                                                TARGET_MARKET_ID = 0 
                                            UNION
                                            SELECT 
                                                1 AS TYPE,
                                                CONSUMER_ID MEMBER_TYPE,
                                                '' MEMBER_NAME,
                                                '' MEMBER_SURNAME,
                                                '' TARGET_MARKET,
                                                ORDER_CREDIT_ID,
                                                '' VALID_DATE,
                                                2 IS_TYPE
                                            FROM 
                                                GET_MONEY_CREDITS_2 
                                            WHERE 
                                                <cfif isdefined('attributes.consumer_id') and len(attributes.consumer_id) and isdefined('attributes.member_name') and len(attributes.member_name)>
                                                    CONSUMER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.consumer_id#"> AND
                                                <cfelseif isdefined('attributes.company_id') and len(attributes.company_id) and isdefined('attributes.member_name') and len(attributes.member_name)>
                                                    1 = 0 AND
                                                </cfif>
                                                IS_TYPE = 1 AND
                                                COMPANY_ID IS NULL AND 
                                                TARGET_MARKET_ID = 0                    
                                        </cfif>		
                                    </cfquery>
                                <cfelse>
                                    <cfset get_money_credits.recordcount = 0>
                                </cfif>
                                <cfif get_money_credits.recordcount>
                                    <cfparam name="attributes.page" default="1">
                                    <cfparam name="attributes.maxrows" default='#session.ep.maxrows#'> 
                                    <cfparam name="attributes.totalrecords" default="#get_money_credits.recordcount#">
                                    <cfset attributes.startrow = ((attributes.page-1)*attributes.maxrows) + 1>
                                    <cfoutput query="get_money_credits" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
                                        <tr>
                                            <td>#currentrow#</td>
                                            <td></td>
                                            <cfif type eq 1>
                                                <td><a href="javascript://" class="tableyazi" onclick="windowopen('#request.self#?fuseaction=objects.popup_con_det&con_id=#member_type#','medium');">#get_cons_info(member_type,0,0)#</a></td>
                                            <cfelseif type eq 2>
                                                <td><a href="javascript://" class="tableyazi" onclick="windowopen('#request.self#?fuseaction=objects.popup_par_det&par_id=#member_type#','medium');">#get_par_info(member_type,0,-1,0)#</a></td>                            
                                            </cfif>
                                            <td>#target_market#</td>
                                            <cfif not len(valid_date)>
                                                <cfquery name="GET_VALID_DATE" dbtype="query">
                                                    SELECT VALID_DATE FROM GET_MONEY_CREDITS_2 WHERE ORDER_CREDIT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#order_credit_id#">
                                                </cfquery>
                                                <td>#DateFormat(get_valid_date.valid_date,dateformat_style)#</td>                            
                                            <cfelse>
                                                <td>#DateFormat(valid_date,dateformat_style)#</td>
                                            </cfif>
                                            <td>
                                                <a href="javascript://" onClick="windowopen('#request.self#?fuseaction=sales.popup_upd_discount_coupon&order_credit_id=#order_credit_id#&is_type=#is_type#','small');"><i class="fa fa-pencil" alt="<cf_get_lang dictionary_id='57464.Güncelle'>" title="<cf_get_lang dictionary_id='57464.Güncelle'>"></i></a>   
                                            </td>
                                        </tr>
                                    </cfoutput>
                                <cfelse>
                                    <tr class="color-row" style="height:20px;">
                                        <td colspan="<cfoutput>#colspan_#</cfoutput>"><cf_get_lang dictionary_id="57484.Kayıt Yok">!</td>
                                    </tr>
                                </cfif>  
                            <cfelse>
                                <tr>
                                    <td colspan="<cfoutput>#colspan_#</cfoutput>"><cf_get_lang dictionary_id="57701.Filtre Ediniz">!</td>
                                </tr>
                            </cfif> 
                        </tbody>
                    </cf_grid_list> 
                </cf_box>
            <cfelse>
                <cf_box title="#head#" uidrop="1" hide_table_column="1">
                    <cfset colspan_ = 7>
                    <cf_grid_list>
                        <thead>
                            <tr>
                                <th width="30"><cf_get_lang dictionary_id='57487.No'></th>
                                <th><cf_get_lang dictionary_id='57611.Sipariş'></th>
                                <th><cf_get_lang dictionary_id='57519.Cari Hesap'></th>
                                <cfif attributes.act_type eq 1>
                                    <th><cf_get_lang dictionary_id="40898.Kazanılan Parapuan"></th>
                                    <th><cf_get_lang dictionary_id="40901.Kullanılan Parapuan"></th>
                                    <th><cf_get_lang dictionary_id="40902.Parapuan Yüzdesi"> %</th>
                                    <th><cf_get_lang dictionary_id="40905.Parapuan Geçerlilik Tarihi"></th>
                                <cfelse>
                                    <th><cf_get_lang dictionary_id='41445.Hediye Çeki'></th>
                                    <th><cf_get_lang dictionary_id="40907.Kullanılan Tutar"></th>
                                    <th><cf_get_lang dictionary_id='58624.Geçerlilik Tarihi'></th>
                                </cfif>
                                <cfif isDefined('attributes.act_type') and attributes.act_type eq 3> 
                                    <th width="20">
                                        <a href="javascript://" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=sales.popup_add_discount_coupon','small');"><i class="fa fa-plus" title="<cf_get_lang dictionary_id='57582.Ekle'>" alt="<cf_get_lang dictionary_id='57582.Ekle'>"></i></a>
                                    </th>
                                </cfif>
                            </tr>
                        </thead>
                        <tbody>
                            <cfif isdefined('attributes.is_submit') and attributes.is_submit eq 1>
                                <cfif get_money_credits.recordcount>
                                    <cfscript>
                                        company_id_list='';
                                        consumer_id_list='';
                                    </cfscript>
                                    <cfoutput query="get_money_credits" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
                                        <cfif len(company_id) and not listfind(company_id_list,company_id)>
                                            <cfset company_id_list=listappend(company_id_list,company_id)>
                                        </cfif>
                                        <cfif len(consumer_id) and not listfind(consumer_id_list,consumer_id)>
                                            <cfset consumer_id_list=listappend(consumer_id_list,consumer_id)>
                                        </cfif>
                                        <cfif len(company_id_list)>
                                            <cfset company_id_list = listsort(company_id_list,"numeric","ASC",",")>
                                            <cfquery name="GET_COMPANY_DETAIL" datasource="#DSN#">
                                                SELECT COMPANY_ID, NICKNAME, FULLNAME FROM COMPANY WHERE COMPANY_ID IN (#company_id_list#) ORDER BY COMPANY_ID
                                            </cfquery>
                                        </cfif>
                                        <cfif len(consumer_id_list)>
                                            <cfset consumer_id_list = listsort(consumer_id_list,"numeric","ASC",",")>
                                            <cfquery name="GET_CONSUMER_DETAIL" datasource="#DSN#">
                                                SELECT CONSUMER_ID,CONSUMER_NAME,CONSUMER_SURNAME FROM CONSUMER WHERE CONSUMER_ID IN (#consumer_id_list#) ORDER BY CONSUMER_ID
                                            </cfquery>
                                        </cfif>
                                        <tr>
                                            <td>#currentrow#</td>
                                            <td><a href="javascript://" onclick="AjaxPageLoad('#request.self#?fuseaction=#listgetat(attributes.fuseaction,1,'.')#.list_order&event=upd&order_id=#order_id#','sales',1);" class="tableyazi">#order_number#</a></td>
                                            <td><cfif len(company_id)>
                                                    <a href="javascript://" class="tableyazi" onclick="windowopen('#request.self#?fuseaction=objects.popup_com_det&company_id=#company_id#','medium');">#get_company_detail.nickname[listfind(company_id_list,company_id,',')]#</a>
                                                </cfif>
                                                <cfif len(consumer_id)>
                                                    <a href="javascript://" class="tableyazi" onclick="windowopen('#request.self#?fuseaction=objects.popup_con_det&con_id=#consumer_id#','medium');">#get_consumer_detail.consumer_name[listfind(consumer_id_list,consumer_id,',')]# #get_consumer_detail.consumer_surname[listfind(consumer_id_list,consumer_id,',')]#</a>
                                                </cfif>
                                            </td>
                                            <td>#TlFormat(money_credit)#</td>
                                            <td>#TlFormat(use_credit)#</td>
                                                <cfif attributes.act_type eq 1>
                                            <td >#credit_rate#</td>
                                                </cfif>
                                            <td>#DateFormat(valid_date,dateformat_style)#</td>
                                            <td>
                                                <a href="javascript://" onClick="windowopen('#request.self#?fuseaction=sales.popup_upd_discount_coupon&order_credit_id=#order_credit_id#&is_type=#is_type#','small');"><i class="fa fa-pencil" title="<cf_get_lang dictionary_id='57464.Güncelle'>" alt="<cf_get_lang dictionary_id='57464.Güncelle'>"></i></a>   
                                            </td>
                                        </tr>
                                    </cfoutput> 
                                <cfelse>
                                    <tr class="color-row" style="height:20px;">
                                        <td colspan="<cfoutput>#colspan_#</cfoutput>"><cf_get_lang dictionary_id="57484.Kayıt Yok">!</td>
                                    </tr>
                                </cfif>  
                            <cfelse>
                                <tr>
                                    <td colspan="<cfoutput>#colspan_#</cfoutput>"><cf_get_lang dictionary_id="57701.Filtre Ediniz">!</td>
                                </tr>
                            </cfif>  
                        </tbody>
                    </cf_grid_list>
                </cf_box>
            </cfif> 
        </cfif>

        <cfif get_money_credits.recordcount and (attributes.totalrecords gte attributes.maxrows)>
                <cfset url_str = url_str & "&startrow=#attributes.startrow#">
                <cfif isdefined('attributes.company_id') and len(attributes.company_id)>
                    <cfset url_str = url_str & "&company_id=#attributes.company_id#">
                </cfif>
                <cfif isdefined('attributes.consumer_id') and len(attributes.consumer_id)>
                    <cfset url_str = url_str & "&consumer_id=#attributes.consumer_id#">
                </cfif>
                <cfif isdefined('attributes.member_name') and len(attributes.member_name)>
                    <cfset url_str = url_str & "&member_name=#attributes.member_name#">
                </cfif>
                <cfif isdefined('attributes.record_startdate') and len(attributes.record_startdate)>
                    <cfset url_str = url_str & "&record_startdate=#attributes.record_startdate#">
                </cfif>
                <cfif isdefined('attributes.record_finishdate') and len(attributes.record_finishdate)>
                    <cfset url_str = url_str & "&record_finishdate=#attributes.record_finishdate#">
                </cfif>
                <cfif isdefined('attributes.consumer_id') and len(attributes.consumer_id)>
                    <cfset url_str = url_str & "&consumer_id=#attributes.consumer_id#">
                </cfif>
                <cfif isdefined('attributes.status') and len(attributes.status)>
                    <cfset url_str = url_str & "&status=#attributes.status#">
                </cfif>
                <cfif isdefined('attributes.listing_type') and len(attributes.listing_type)>
                    <cfset url_str = url_str & "&listing_type=#attributes.listing_type#">
                </cfif>
                <cfset url_str = url_str & "&act_type=#attributes.act_type#">
                <cf_paging page="#attributes.page#" page_type="2"
                        maxrows="#attributes.maxrows#" 
                        totalrecords="#attributes.totalrecords#" 
                        startrow="#attributes.startrow#" 
                        adres="#listgetat(attributes.fuseaction,1,'.')#.list_money_credits&#url_str#&is_submit=1&startdate=#dateformat(attributes.startdate,dateformat_style)#&finishdate=#dateformat(attributes.finishdate,dateformat_style)#">
                <cf_get_lang dictionary_id='57540.Toplam Kayıt'>:<cfoutput>#get_money_credits.recordcount#</cfoutput> 
                <cf_paging page="#attributes.page#" page_type="3" 
                    maxrows="#attributes.maxrows#" 
                    totalrecords="#attributes.totalrecords#" 
                    startrow="#attributes.startrow#" 
                    adres="#listgetat(attributes.fuseaction,1,'.')#.list_money_credits&#url_str#&is_submit=1&startdate=#dateformat(attributes.startdate,dateformat_style)#&finishdate=#dateformat(attributes.finishdate,dateformat_style)#">
        </cfif> 
        
<script type="text/javascript">
	document.getElementById('member_name').focus();
</script>
