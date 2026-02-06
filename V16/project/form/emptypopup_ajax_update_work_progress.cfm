<cfsetting showdebugoutput="no">
<!--- AJAX endpoint for updating task progress and stage --->
<cfparam name="attributes.work_id" default="">
<cfparam name="attributes.to_complete" default="">
<cfparam name="attributes.stage_id" default="">

<cfset response = {success: false, message: ""}>

<cftry>
    <cfif len(attributes.work_id) AND isNumeric(attributes.work_id)>
        
        <!--- TO_COMPLETE guncelle --->
        <cfif len(attributes.to_complete) AND isNumeric(attributes.to_complete)>
            <cfset toComplete = min(100, max(0, int(attributes.to_complete)))>
            <cfquery name="UPDATE_WORK_PERCENT" datasource="#DSN#">
                UPDATE PRO_WORKS 
                SET TO_COMPLETE = <cfqueryparam cfsqltype="cf_sql_integer" value="#toComplete#">,
                    UPDATE_DATE = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
                    UPDATE_AUTHOR = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#">
                WHERE WORK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.work_id#">
            </cfquery>
            <cfset response.to_complete = toComplete>
        </cfif>
        
        <!--- WORK_CURRENCY_ID (stage) guncelle --->
        <cfif len(attributes.stage_id) AND isNumeric(attributes.stage_id)>
            <!--- Secilen surecin adini kontrol et --->
            <cfquery name="GET_STAGE_NAME" datasource="#DSN#">
                SELECT STAGE FROM PROCESS_TYPE_ROWS WHERE PROCESS_ROW_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.stage_id#">
            </cfquery>
            <cfset stageName = GET_STAGE_NAME.recordcount ? trim(GET_STAGE_NAME.STAGE) : "">
            
            <!--- Tamamlandi secilirse otomatik %100 yap, digerleri %0 --->
            <cfif stageName eq "Tamamlandı" OR stageName eq "Tamamlandi">
                <cfquery name="UPDATE_WORK_STAGE" datasource="#DSN#">
                    UPDATE PRO_WORKS 
                    SET WORK_CURRENCY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.stage_id#">,
                        TO_COMPLETE = 100,
                        UPDATE_DATE = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
                        UPDATE_AUTHOR = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#">
                    WHERE WORK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.work_id#">
                </cfquery>
                <cfset response.to_complete = 100>
            <cfelse>
                <!--- Diger asamalarda TO_COMPLETE = 0 yap --->
                <cfquery name="UPDATE_WORK_STAGE" datasource="#DSN#">
                    UPDATE PRO_WORKS 
                    SET WORK_CURRENCY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.stage_id#">,
                        TO_COMPLETE = 0,
                        UPDATE_DATE = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
                        UPDATE_AUTHOR = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#">
                    WHERE WORK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.work_id#">
                </cfquery>
                <cfset response.to_complete = 0>
            </cfif>
            <cfset response.stage_id = attributes.stage_id>
        </cfif>
        
        <!--- Proje tamamlanma yuzdesini hesapla --->
        <cfquery name="GET_PROJECT_PROGRESS" datasource="#DSN#">
            SELECT 
                PW.PROJECT_ID,
                CASE 
                    WHEN COUNT(*) > 0 
                    THEN CAST(AVG(CAST(ISNULL(PW2.TO_COMPLETE, 0) AS FLOAT)) AS INT)
                    ELSE 0 
                END AS PROJECT_COMPLETION
            FROM PRO_WORKS PW
            INNER JOIN PRO_WORKS PW2 ON PW2.PROJECT_ID = PW.PROJECT_ID AND PW2.WORK_STATUS = 1
            WHERE PW.WORK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.work_id#">
            GROUP BY PW.PROJECT_ID
        </cfquery>
        <cfif GET_PROJECT_PROGRESS.recordcount>
            <cfset response.project_id = GET_PROJECT_PROGRESS.PROJECT_ID>
            <cfset response.project_completion = GET_PROJECT_PROGRESS.PROJECT_COMPLETION>
        </cfif>
        
        <cfset response.success = true>
        <cfset response.message = "Guncellendi">
        <cfset response.work_id = attributes.work_id>
    <cfelse>
        <cfset response.message = "Gecersiz work_id">
    </cfif>
    
<cfcatch>
    <cfset response.success = false>
    <cfset response.message = cfcatch.message>
</cfcatch>
</cftry>
<cfoutput>#serializeJSON(response)#</cfoutput>
