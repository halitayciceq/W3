<cfparam name="attributes.start_date" default="">
<cfparam name="attributes.finish_date" default="">
<cfparam name="attributes.process_stage_type" default="">
<cfparam name="attributes.import_type_id" default="">
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.convert_payment_plan" default="">
<cfparam name="attributes.sort_type" default="3">
<cfparam name="attributes.page" default="1">
<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'> 

<cfset attributes.startrow = ((attributes.page-1)*attributes.maxrows) + 1 >
<cfif isdefined("attributes.start_date") and len(attributes.start_date)><cf_date tarih="attributes.start_date"></cfif>
<cfif isdefined("attributes.finish_date") and len(attributes.finish_date)><cf_date tarih="attributes.finish_date"></cfif>
    
<cfinclude template="../query/get_payment_plan_import_type.cfm">
<cfif isdefined("attributes.form_submitted")> 
    <cfscript>
        list_comp = createObject("component","V16.sales.cfc.subscription_payment_plan_import");
        listData = list_comp.get_import(
                                        sort_type:attributes.sort_type,
                                        startrow:attributes.startrow,
                                        maxrows:attributes.maxrows,
                                        keyword:attributes.keyword,
                                        start_date:attributes.start_date,
                                        finish_date:attributes.finish_date,
                                        PROCESS_STAGE:attributes.process_stage_type,
                                        import_type_id:attributes.import_type_id,
                                        convert_subscription_payment_plan:attributes.convert_payment_plan
                                );
    </cfscript>
<cfelse> 
    <cfset listData.recordCount = 0>
</cfif> 

<cfquery name="GET_SERVICE_STAGE" datasource="#DSN#">
	SELECT
		PTR.STAGE,
		PTR.PROCESS_ROW_ID 
	FROM
		PROCESS_TYPE_ROWS PTR,
		PROCESS_TYPE_OUR_COMPANY PTO,
		PROCESS_TYPE PT
	WHERE
		PT.IS_ACTIVE = 1 AND
		PT.PROCESS_ID = PTR.PROCESS_ID AND
		PT.PROCESS_ID = PTO.PROCESS_ID AND
		PTO.OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#"> AND
		PT.FACTION LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%sales.list_subscription_payment_plan_import%">
	ORDER BY
		PTR.LINE_NUMBER
</cfquery>

<cfif listData.recordcount>
    <cfparam name="attributes.totalrecords" default='#listData.QUERY_COUNT#'>
    <cfset process_list=''>
    <cfset employee_list=''>
    
    <cfoutput query="listData">
        <cfif len(listData.record_emp) and not listfind(employee_list,listData.record_emp)>
            <cfset employee_list = listappend(employee_list,listData.record_emp)>
        </cfif>
        <cfif len(listData.process_stage) and not listfind(process_list,listData.process_stage)>
            <cfset process_list = listappend(process_list,listData.process_stage)>
        </cfif>
    </cfoutput>
    <cfif len(employee_list)>
        <cfset employee_list=listsort(employee_list,"numeric","ASC",",")>
        <cfquery name="GET_EMPLOYEE" datasource="#DSN#">
            SELECT EMPLOYEE_NAME,EMPLOYEE_SURNAME,EMPLOYEE_ID FROM EMPLOYEES WHERE EMPLOYEE_ID IN (#employee_list#) ORDER BY EMPLOYEE_ID
        </cfquery>
        <cfset main_employee_list = listsort(listdeleteduplicates(valuelist(get_employee.employee_id,',')),'numeric','ASC',',')>
    </cfif>	
<cfelse>
    <cfparam name="attributes.totalrecords" default='0'>
</cfif>

<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box>
        <cfform name="subscription_list" id="subscription_list" method="post" action="#request.self#?fuseaction=sales.list_subscription_payment_plan_import">
            <input type="hidden" name="form_submitted" id="form_submitted" value="1">
            <cf_box_search>
                <div class="form-group" id="item-keyword">
                    <cfinput type="text" name="keyword" id="keyword" value="#attributes.keyword#" maxlength="50" placeholder="#getLang('main','Filtre',57460)#">
                </div>
                <div class="form-group" id="item-start_date">
                    <div class="input-group">
                        <cfinput type="text" name="start_date" value="#dateformat(attributes.start_date,dateformat_style)#" validate="#validate_style#" maxlength="10" message="#getLang('','Lütfen Başlangıç Tarihi Giriniz',41039)#">
                        <span class="input-group-addon"><cf_wrk_date_image date_field="start_date"></span>
                    </div>
                </div>
                <div class="form-group" id="item-finish_date">
                    <div class="input-group">
                        <cfinput type="text" name="finish_date" value="#dateformat(attributes.finish_date, dateformat_style)#" validate="#validate_style#" maxlength="10" message="#getLang('','Lütfen Bitiş Tarihi Giriniz',41040)#">
                        <span class="input-group-addon"><cf_wrk_date_image date_field="finish_date"></span>
                    </div>
                </div>
                <div class="form-group" id="item-sort_type">
                    <select name="sort_type" id="sort_type">
                        <option value="0" <cfif attributes.sort_type eq 0>selected</cfif>><cf_get_lang dictionary_id="41125.Tanıma Göre Artan"></option>
                        <option value="1" <cfif attributes.sort_type eq 1>selected</cfif>><cf_get_lang dictionary_id="41121.Tanıma Göre Azalan"></option>
                        <option value="2" <cfif attributes.sort_type eq 2>selected</cfif>><cf_get_lang dictionary_id="47978.Tarihe Göre Artan"></option>
                        <option value="3" <cfif attributes.sort_type eq 3>selected</cfif>><cf_get_lang dictionary_id="47983.Tarihe Göre Azalan"></option>
                    </select>
                </div>
                <div class="form-group small" id="item-maxrows">
                    <cfinput type="text" name="maxrows" value="#attributes.maxrows#" maxlength="3" onKeyUp="isNumber(this)" validate="integer" range="1," required="yes" message="#getLang('','Kayıt Sayısı Hatalı',57537)#">
                </div>
                <div class="form-group" id="item-search_button">
                    <cf_wrk_search_button button_type="4" search_function="date_check(subscription_list.start_date,subscription_list.finish_date,'#getLang('','Tarih Değerini Kontrol Ediniz',57782)#')">
                    <cf_workcube_file_action pdf='1' mail='1' doc='1' print='1'>
                </div>
            </cf_box_search>
            <cf_box_search_detail>
                <div class="col col-3 col-md-4 col-sm-12 col-xs-12" type="column" index="1" sort="true">
                    <div class="form-group" id="item-convert_payment_plan">
                        <label class="col col-12"><cf_get_lang dictionary_id='41108.Ödeme Planı'></label>
                        <div class="col col-12">
                            <select name="convert_payment_plan" id="convert_payment_plan">
                                <option value=""><cf_get_lang dictionary_id="57708.Tümü"></option>                                  
                                <option value="1" <cfif attributes.convert_payment_plan eq 1>selected</cfif>><cf_get_lang dictionary_id="57495.Evet"></option>
                                <option value="0" <cfif attributes.convert_payment_plan eq 0>selected</cfif>><cf_get_lang dictionary_id="57496.Evet"></option>
                            </select>
                        </div>
                    </div>
                    <div class="form-group" id="item-process_stage_type">
                        <label class="col col-12"><cf_get_lang dictionary_id ='57482.Aşama'></label>
                        <div class="col col-12">
                            <select name="process_stage_type" id="process_stage_type">
                            <option value=""><cf_get_lang dictionary_id ='57482.Aşama'></option>
                                <cfoutput query="get_service_stage">
                                        <option value="#process_row_id#" <cfif attributes.process_stage_type eq process_row_id>selected</cfif>>#stage#</option>
                                </cfoutput>
                            </select>
                        </div>
                    </div>
                </div>
                <div class="col col-3 col-md-4 col-sm-12 col-xs-12" type="column" index="2" sort="true">
                    <div class="form-group" id="item-import_type">
                        <label class="col col-12"><cf_get_lang dictionary_id="36068.İmport Tipi"></label>
                        <div class="col col-12">
                            <select name="import_type_id" id="import_type_id" multiple>
                                <!---<option value=""><cf_get_lang dictionary_id="36068.İmport Tipi"></option>--->
                                <cfoutput query="get_payment_plan_import_type">
                                    <option value="#import_type_id#" <cfif listFind(attributes.import_type_id,import_type_id)>selected</cfif>>#IMPORT_TYPE_NAME#</option>
                                </cfoutput>
                            </select>
                        </div>
                    </div>
                </div>
            </cf_box_search_detail>
        </cfform>
    </cf_box>
    <cfset colspan_ = 10>
    <cf_box title="#getLang('','Ödeme Planı Aktarım',45168)#" uidrop="1" hide_table_column="1">
        <cf_grid_list>
            <thead>
                <tr>
                    <th width="35"><cf_get_lang dictionary_id='58577.Sıra'></th>
                    <th><cf_get_lang dictionary_id='58233.Tanım'></th>
                    <th><cf_get_lang dictionary_id="36068.İmport Tipi"></th>
                    <th><cf_get_lang dictionary_id="41112.Tahakkuk Tarihi"></th>
                    <th><cf_get_lang dictionary_id='57482.Aşama'></th>
                    <th><cf_get_lang dictionary_id='41108.Ödeme Planı'></th>
                    <th><cf_get_lang dictionary_id='41097.Hatalı Satır Sayısı'></th>
                    <th><cf_get_lang dictionary_id="57627.Kayıt Tarihi"></th>
                    <th><cf_get_lang dictionary_id='57483.Kayıt'></th>	
                    <!-- sil --><th width="20" class="header_icn_none text-center"><a href="<cfoutput>#request.self#</cfoutput>?fuseaction=sales.list_subscription_payment_plan_import&event=add"><i class="fa fa-plus" title="<cf_get_lang dictionary_id='57582.Ekle'>" alt="<cf_get_lang dictionary_id='57582.Ekle'>"></i></a></th><!-- sil -->
                </tr>
            </thead>
            <tbody>
                <cfif listData.recordcount>
                    <cfoutput query="listData">
                        <cfif len(listData.PROCESS_STAGE) and not listfind(process_list,listData.process_stage)>
                            <cfset process_list = listappend(process_list,listData.process_stage)>
                        </cfif>
                    </cfoutput>
                    
                    <cfif len(process_list)>
                        <cfset process_list=listsort(process_list,"numeric","ASC",",")>
                        <cfquery name="get_process_type" datasource="#dsn#">
                            SELECT STAGE,PROCESS_ROW_ID FROM PROCESS_TYPE_ROWS WHERE PROCESS_ROW_ID IN (#process_list#) ORDER BY PROCESS_ROW_ID
                        </cfquery>
                        <cfset main_process_list = listsort(listdeleteduplicates(valuelist(get_process_type.process_row_id,',')),'numeric','ASC',',')>
                    </cfif> 
                    <cfoutput query="listData">
                    <tr>
                        <td>#rownum#</td>
                        <td>#left(listData.IMPORT_NAME,50)#</td>
                        <td>#listData.IMPORT_TYPE_NAME#</td>
                        <td><cfif len(payment_date)>#dateformat(payment_date,dateformat_style)#</cfif></td>
                        <td><cfif len(listData.process_stage)>#get_process_type.STAGE[listfind(main_process_list,listData.process_stage,',')]#</cfif></td> 
                        <td><cfif CONVERT_SUBSCRIPTION_PAYMENT_PLAN EQ 1><cf_get_lang dictionary_id="57495.Evet"><cfelse><cf_get_lang dictionary_id="57496.Hayır"></cfif></td>
                        <td><cfif len(ERROR_ROW_COUNT)>#ERROR_ROW_COUNT#</cfif></td>
                        <td><cfif len(record_date)>#dateformat(record_date,dateformat_style)#</cfif></td>
                        <td>
                            <a href="javascript://" onclick="windowopen('#request.self#?fuseaction=objects.popup_emp_det&emp_id=#listData.record_emp#','medium');" class="tableyazi">#get_employee.employee_name[listfind(main_employee_list,listData.record_emp,',')]#&nbsp;#get_employee.employee_surname[listfind(main_employee_list,listData.record_emp,',')]#</a>
                        </td>
                        <!-- sil --><td><a href="#request.self#?fuseaction=sales.list_subscription_payment_plan_import&event=upd&import_id=#listData.SUBSCRIPTION_PAYMENT_PLAN_IMPORT_ID#"><i class="fa fa-pencil" title="<cf_get_lang dictionary_id='57464.Güncelle'>" alt="<cf_get_lang dictionary_id='57464.Güncelle'>"></i></a></td><!-- sil -->
                    </tr> 
                    </cfoutput>
                <cfelse>
                <tr>
                    <td colspan="<cfoutput>#colspan_#</cfoutput>"><cfif isdefined("attributes.form_submitted")><cf_get_lang dictionary_id='57484.Kayıt Bulunamadı'> !<cfelse><cf_get_lang dictionary_id='57701.Filtre Ediniz '> !</cfif></td>
                </tr>
                </cfif>
            </tbody>
        </cf_grid_list>

        <cfset adres="sales.list_subscription_payment_plan_import">
        <cfif isdefined("attributes.keyword") and len(attributes.keyword)>
            <cfset adres = "#adres#&keyword=#attributes.keyword#" >
        </cfif>
        <cfif isdefined("attributes.process_stage_type") and len(attributes.process_stage_type)>
            <cfset adres = "#adres#&process_stage_type=#attributes.process_stage_type#" >
        </cfif>
        <cfif isdefined("attributes.import_type_id") and len(attributes.import_type_id)>
            <cfset adres = "#adres#&import_type_id=#attributes.import_type_id#">
        </cfif>
        <cfif isdefined('attributes.start_date') and len(attributes.start_date)>
            <cfset adres = "#adres#&start_date=#dateformat(attributes.start_date,dateformat_style)#">
        </cfif>
        <cfif isdefined('attributes.finish_date') and len(attributes.finish_date)>
            <cfset adres = "#adres#&finish_date=#dateformat(attributes.finish_date,dateformat_style)#">
        </cfif>
        <cfif isdefined('attributes.sort_type') and len(attributes.sort_type)>
            <cfset adres = "#adres#&sort_type=#attributes.sort_type#">
        </cfif>
        <cfif isdefined('attributes.convert_payment_plan') and len(attributes.convert_payment_plan)>
            <cfset adres = "#adres#&convert_payment_plan=#attributes.convert_payment_plan#">
        </cfif>
        <cf_paging 
            page="#attributes.page#" 
            maxrows="#attributes.maxrows#" 
            totalrecords="#attributes.totalrecords#" 
            startrow="#attributes.startrow#" 
            adres="#adres#&form_submitted=1">
    </cf_box>
</div>
<script type="text/javascript">
document.getElementById('keyword').focus();
</script>
    