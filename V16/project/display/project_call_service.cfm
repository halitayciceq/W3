<cfsetting showdebugoutput="no">
<cfparam name="attributes.page" default="1">
<cfparam name="attributes.maxrows" default="20">
<cfset attributes.startrow = ((attributes.page-1)*attributes.maxrows) + 1>
<cfquery name="GET_G_SERVICE" datasource="#DSN#">
	WITH CTE1 AS (
	SELECT
		G_SERVICE.SERVICE_ID,
		G_SERVICE.RECORD_DATE,
		G_SERVICE.SERVICE_NO,
		G_SERVICE.SERVICE_HEAD,
		G_SERVICE.SERVICE_ACTIVE,
		G_SERVICE.REF_NO,
		G_SERVICE_APPCAT.SERVICECAT,
		PROCESS_TYPE_ROWS.STAGE,
		G_SERVICE.SUBSCRIPTION_ID
	FROM
		G_SERVICE WITH (NOLOCK),
		G_SERVICE_APPCAT WITH (NOLOCK),
		PROCESS_TYPE_ROWS WITH (NOLOCK)
	WHERE 
		G_SERVICE.SERVICECAT_ID = G_SERVICE_APPCAT.SERVICECAT_ID AND
		G_SERVICE.SERVICE_STATUS_ID = PROCESS_TYPE_ROWS.PROCESS_ROW_ID
		<cfif isdefined ("attributes.project_id") and len(attributes.project_id)>
			AND G_SERVICE.PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.project_id#">
		</cfif>	
		<cfif isdefined("attributes.is_from_sales")><!--- abone detayindan geliyorsa ---> 
		    AND G_SERVICE.SUBSCRIPTION_ID =<cfqueryparam cfsqltype="cf_sql_integer" value="#URL.ID#">	
		</cfif>
   	),
   	CTE2 AS (
        SELECT
            CTE1.*,
            ROW_NUMBER() OVER ( ORDER BY 
                        RECORD_DATE DESC
                            ) AS RowNum,(SELECT COUNT(*) FROM CTE1) AS QUERY_COUNT
        FROM
            CTE1
    )
    SELECT
        CTE2.*
    FROM
        CTE2
    WHERE
        RowNum BETWEEN #attributes.startrow# AND #attributes.startrow#+(#attributes.maxrows#-1)	
</cfquery>
<cfquery name="GET_SERVICE_APPCAT_SUB_STATUS_ALL" datasource="#DSN#">
	SELECT SERVICE_SUB_CAT_ID,SERVICE_EXPLAIN, SERVICE_SUB_STATUS_ID, SERVICE_SUB_STATUS FROM G_SERVICE_APPCAT_SUB_STATUS
</cfquery>
<cfif get_g_service.recordcount>
    <cfparam name="attributes.totalrecords" default="#get_g_service.query_count#">
<cfelse>
    <cfparam name="attributes.totalrecords" default="0">
</cfif>
<div id="div_call_center">
<cf_grid_list>
	<thead>
		 <tr>
			<th style="width:30px"><cf_get_lang dictionary_id='57487.No'></th>
			<th><cf_get_lang dictionary_id='55247.Başvuru No'></th>
			<th><cf_get_lang dictionary_id='57742.Tarih'></th>
			<th><cf_get_lang dictionary_id='57480.Konu'></th>
			<th><cf_get_lang dictionary_id='57486.Kategori'></th>
			<th><cf_get_lang dictionary_id='57482.Aşama'></th>
			<th width="20">
				<cfif isdefined ("attributes.project_id") and len(attributes.project_id)>
					<a href="<cfoutput>#request.self#?fuseaction=call.list_service&event=add&project_id=#attributes.project_id#</cfoutput>" target="_blank"><i class="fa fa-plus" alt="<cf_get_lang dictionary_id='57582.Ekle'>" title="<cf_get_lang dictionary_id='57582.Ekle'>"></i></a>
				</cfif>	
				<cfif isdefined("attributes.is_from_sales")>
					<a href="<cfoutput>#request.self#?fuseaction=call.list_service&event=add&subscription=#attributes.subscription_id#</cfoutput>" target="_blank"><i class="fa fa-plus" alt="<cf_get_lang dictionary_id='57582.Ekle'>" title="<cf_get_lang dictionary_id='57582.Ekle'>"></i></a>
				</cfif>
            </th> 
		</tr>
	</thead>
	<tbody>
	<cfif get_g_service.recordcount>
		<cfoutput query="get_g_service">
			<tr>
				<td width="55">#rownum#</td>
				<td width="80"><a href="#request.self#?fuseaction=call.list_service&event=upd&service_id=#get_g_service.service_id#&service_no=#get_g_service.service_no#"  target="_blank" class="tableyazi">#service_no#</a></td>
				<td width="60">#dateformat(record_date,dateformat_style)#</td>
				<td width="200">#service_head#</td>
				<td>#servicecat#</td>
				<td>#stage#</td> 
                <td><a href="#request.self#?fuseaction=call.list_service&event=upd&service_id=#get_g_service.service_id#"  target="_blank"> <i class="fa fa-pencil" alt="<cf_get_lang dictionary_id='58718.Düzenle'>" title="<cf_get_lang dictionary_id='58718.Düzenle'>"></i></a></td>
			</tr>
		</cfoutput>
	<cfelse>
		<tr>
			<td colspan="9"><cf_get_lang dictionary_id='57484.Kayıt Bulunamadı'> !</td>
		</tr>	
	</cfif>
	</tbody>
</cf_grid_list>
<cfif isdefined ("attributes.project_id") and len(attributes.project_id)>
	<cfset adres="project.popupajax_project_call_service&project_id=#attributes.project_id#">
</cfif>	
<cfif isdefined("attributes.is_from_sales")>
	<cfset adres = "sales.list_actions&subscription_id=#attributes.is_from_sales#">
</cfif>
<cfif attributes.totalrecords gt attributes.maxrows>
    <cf_paging
        name="call_center_apps"
        page="#attributes.page#" 
        maxrows="#attributes.maxrows#" 
        totalrecords="#attributes.totalrecords#" 
        startrow="#attributes.startrow#" 
        adres="#adres#"
        isAjax="1"
        target="div_call_center"
        is_iframe="1"
  	>
</cfif>
</div>
