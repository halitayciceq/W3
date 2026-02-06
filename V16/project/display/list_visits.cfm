<cfparam name="attributes.page" default="1">
<cfparam name="attributes.maxrows" default="20">
<cfset attributes.startrow = ((attributes.page-1)*attributes.maxrows) + 1>
<cfset list_value=''>
<cfquery name="get_visit_row" datasource="#dsn#">
	SELECT  EVENT_PLAN_ID FROM EVENT_PLAN_ROW WHERE PROJECT_ID= #attributes.id#
</cfquery>
<cfset list_value=listdeleteduplicates(valuelist(get_visit_row.event_plan_id,','))>
<cfif get_visit_row.recordcount and listlen(list_value)>
    <cfquery name="get_visits" datasource="#dsn#">
    WITH CTE1 AS (
        SELECT
            EVENT_PLAN.EVENT_PLAN_ID,
            EVENT_PLAN.MAIN_START_DATE,
            EVENT_PLAN.MAIN_FINISH_DATE,
            EVENT_PLAN.EVENT_PLAN_HEAD,
            EVENT_PLAN.EVENT_STATUS,
            PROCESS_TYPE_ROWS.STAGE
        FROM
            EVENT_PLAN,
            PROCESS_TYPE_ROWS
        WHERE
            EVENT_PLAN.IS_SALES = 1 
            AND PROCESS_TYPE_ROWS.PROCESS_ROW_ID = EVENT_PLAN.EVENT_STATUS
            AND EVENT_PLAN_ID IN (#list_value#)
      ),
       CTE2 AS (
            SELECT
                CTE1.*,
                ROW_NUMBER() OVER ( ORDER BY 
                            EVENT_PLAN_ID ASC
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
<cfelse>
	<cfset get_visits.recordcount=0>
</cfif>
<cfif get_visits.recordcount>
    <cfparam name="attributes.totalrecords" default="#get_visits.query_count#">
<cfelse>
    <cfparam name="attributes.totalrecords" default="0">
</cfif>
<div id="div_visits">
<cf_grid_list>
	<thead>
        <tr>
            <th style="width:30px"><cf_get_lang dictionary_id='57487.No'></th>
            <th><cf_get_lang dictionary_id='38126.Plan adı'></th>
            <th><cf_get_lang dictionary_id='58859.Süreç'></th>
            <th><cf_get_lang dictionary_id='58053.Başlangıç Tarihi'></th>
            <th><cf_get_lang dictionary_id='57700.Bitiş Tarihi'></th>
            <th width="30">
                <a href="<cfoutput>#request.self#?fuseaction=sales.list_visit&event=add&project_id=#attributes.id#</cfoutput>" target="_blank"> <i class="fa fa-plus" alt="<cf_get_lang dictionary_id='57582.Ekle'>" title="<cf_get_lang dictionary_id='57582.Ekle'>"></i></a>
            </th>
        </tr>
    </thead>
    <tbody>
		<cfif get_visits.recordcount>
            <cfoutput query="get_visits">
                <tr>
                    <td>#EVENT_PLAN_ID#</td>
                    <td>#EVENT_PLAN_HEAD#</td>
                    <td>#STAGE#</td>
                    <td>#dateformat(MAIN_START_DATE,dateformat_style)#</td>
                    <td>#dateformat(MAIN_FINISH_DATE,dateformat_style)#</td>
                    <td><a href="#request.self#?fuseaction=sales.list_visit&event=upd&visit_id=#EVENT_PLAN_ID#" target="_blank"> <i class="fa fa-pencil" alt="<cf_get_lang dictionary_id='58718.Düzenle'>" title="<cf_get_lang dictionary_id='58718.Düzenle'>"></i></a></td>
                </tr>
            </cfoutput>
        <cfelse>
            <tr>
                <td colspan="7"><cf_get_lang dictionary_id='57484.Kayıt Yok'>!</td>
            </tr>
        </cfif>
    </tbody>
</cf_grid_list>
<cfset adres="project.popup_ajax_list_visit&id=#attributes.id#&line_based=#attributes.line_based#">
<cfif isdefined("attributes.is_from_product")>
	<cfset adres = "#adres#&is_from_product=#attributes.is_from_product#">
</cfif>
<cfif attributes.totalrecords gt attributes.maxrows>
    <cf_paging
        name="visits"
        page="#attributes.page#" 
        maxrows="#attributes.maxrows#" 
        totalrecords="#attributes.totalrecords#" 
        startrow="#attributes.startrow#" 
        adres="#adres#"
        isAjax="1"
        target="div_visits"
        is_iframe="1"
        >
</cfif>
</div> 

