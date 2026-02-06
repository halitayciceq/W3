<cfset listCM = createObject("component","V16.sales.cfc.counter_meter")>
<cfset listCMsel = listCM.select(
    scm_id             :   attributes.cm_id
)>


<cfset dateformatQ = dateformat(listCMsel.LOADING_DATE, dateformat_style)>
<cfset dateFormatPart = dateformatQ.split("/")>
<cfset first_date = "01/"&dateFormatPart[2]&"/"&dateFormatPart[3]>
<cf_date tarih ='first_date'>
<cfparam name="attributes.page" default=1>
<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>

<cfhttp url="http://wex.workcube.com/wex.cfm/e-government_paper/getCounter" charset="utf-8" result="result" method="post">
    <cfhttpparam name="subscription_no" type="url" value="#listCMsel.SUBSCRIPTION_NO#" />
    <cfhttpparam name="company_identifier" type="url" value="#listCMsel.TAXNO#" />
    <cfhttpparam name="wex_type" type="url" value="#listCMsel.COUNTER_ID#" />
    <cfhttpparam name="first_date" type="url" value="#first_date#" />
    <cfhttpparam name="last_date" type="url" value="#listCMsel.LOADING_DATE#" />
</cfhttp>
<cfset responseService = result.FileContent>
<cfset responseWex = deserializeJson(responseService) />

<cfparam name="attributes.totalrecords" default='#arraylen(responseWex.DATA)#'>
<cf_box title="#getLang('','Sayaç Okuma',41271)#" closable="1" popup_box="1">
   
    <cfset dataQ ="#ArrayOfStructuresToQuery(responseWex.DATA)#">

    <div class="ui-info-text">
        <ul>
            <li><b><cf_get_lang dictionary_id='29502.Abone No'> / <cf_get_lang dictionary_id='58233.Tanım'>: <cfoutput>#listCMsel.SUBSCRIPTION_NO# / #listCMsel.SUBSCRIPTION_HEAD#</cfoutput></b></li>
            <li><b><cf_get_lang dictionary_id='48871.Sayaç No'>: <cfoutput>#listCMsel.COUNTER_NO#</cfoutput></b></li>
            <li><b><cf_get_lang dictionary_id='41282.Sayaç Tipi'>: <cfoutput>#listCMsel.COUNTER_TYPE#</cfoutput></b></li>
            <li><b><cf_get_lang dictionary_id='57457.Müşteri'>: <cfoutput>#listCMsel.FULLNAME#</cfoutput></b></li>
        </ul>   
    </div>
    <cf_grid_list>
        <thead>
            <tr>
                <th width="30"><cf_get_lang dictionary_id='57487.No'></th>
                <th><cf_get_lang dictionary_id='57892.Domain'></th>
                <th><cf_get_lang dictionary_id='58616.Belge Numarası'></th>
                <th><cf_get_lang dictionary_id='33203.Belge Tarihi'></th>
                <th><cf_get_lang dictionary_id='30371.Entegratör'></th>
            </tr>       
        </thead>
        <tbody>
            <cfif responseWex.STATUS >
                <cfoutput query="dataQ" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
                    <tr>
                        <td>#currentrow#</td>
                        <td>#DOMAIN#</td>
                        <td>#PROCESS_DOC_NO#</td>
                        <td>#dateformat(PROCESS_DATE,dateformat_style)#</td>
                        <td>
                            <cfswitch expression="#WEX_INTEGRATOR#">
                                <cfcase value="spr">Süper Entegratör</cfcase>
                                <cfcase value="dp">Doğan E-Dönüşüm</cfcase>
                                <cfcase value="dgn">Digital Planet</cfcase>
                            </cfswitch>
                        </td>
                    </tr>
                </cfoutput>
            <cfelse>
                <tr>
                    <td colspan="5"><cfoutput>#responseWex.MESSAGE#</cfoutput></td>
                </tr>
            </cfif>
        </tbody>
    </cf_grid_list>
    <cfset url_str = "">
    <cfif isdefined("attributes.cm_id")>
        <cfset url_str = "#url_str#&cm_id=#attributes.cm_id#">
    </cfif>
    <cf_paging page="#attributes.page#" 
        maxrows="#attributes.maxrows#"
        totalrecords="#attributes.totalrecords#"
        startrow="#attributes.startrow#"
        isAjax= "true"
        adres="#fusebox.circuit#.counter_meter_detail&#url_str#">
</cf_box>

<cffunction name="ArrayOfStructuresToQuery" access="public" returntype="query" output="false">
    <cfargument name="StructArray" type="any" required="true" />
        <cfscript>
            KeyList=StructKeyList(arguments.StructArray[1]);
            qbook = QueryNew(KeyList);
            
            for(i=1; i <= ArrayLen(arguments.StructArray); i=i+1){
                 QueryAddRow(qbook);
                 for(y=1;y lte ListLen(KeyList);y=y+1){
                     QuerySetCell(qbook, ListGetAt(KeyList,y), arguments.StructArray[i][ListGetAt(KeyList,y)]);
                 }
            }
            return qbook;
        </cfscript>
    </cffunction>