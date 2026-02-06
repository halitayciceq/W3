
<cfcomponent>
    <cfset dsn = application.systemParam.systemParam().dsn />
    
    <cffunction name="GET_LIST_FILTERED"  hint="" access="remote">
        <cfargument name="keyword" default="">
        <cfquery name="GET_LIST_FILTERED" datasource="#dsn#">
            SELECT 
                MINDMAP.*,
                PP.PROJECT_HEAD,
                PW.WORK_HEAD,
                E.EVENT_HEAD
            FROM 
                MINDMAP
                LEFT JOIN PRO_PROJECTS AS PP ON MINDMAP.RELATIVE_ID = PP.PROJECT_ID
                LEFT JOIN PRO_WORKS AS PW ON MINDMAP.RELATIVE_ID = PW.WORK_ID
                LEFT JOIN EVENT AS E ON MINDMAP.RELATIVE_ID = E.EVENT_ID
            WHERE
                1 = 1  
                <cfif isdefined("arguments.keyword") and len(arguments.keyword)>AND FILE_NAME LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.keyword#%"></cfif>
        </cfquery>
        <cfreturn GET_LIST_FILTERED>
    </cffunction>

    <cffunction name="GET_LIST"  hint="" access="remote">
        <cfargument name="project_id" default="">
        <cfargument name="type" default="">
        <cfquery name="GET_LIST" datasource="#dsn#">
            SELECT 
                *
            FROM 
                MINDMAP 
            WHERE
                RELATIVE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.project_id#"> 
                AND
                RELATIVE_TYPE = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.type#"> 
        </cfquery>
        <cfreturn GET_LIST>
    </cffunction>

    <cffunction name="GET_MINDMAP"  hint="" access="remote">
        <cfargument name="id" default="">
        <cfquery name="GET_MINDMAP" datasource="#dsn#">
            SELECT 
                *
            FROM 
                MINDMAP 
            WHERE
                MINDMAP_ID =  <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
        </cfquery>
        <cfreturn GET_MINDMAP>
    </cffunction>
    <cffunction name="ADD" access="remote" returntype="any" returnformat="JSON">
        <cfargument name="jsonForm" default="">
        <cfargument name="filename" default="">
        <cfargument name="prj_id" default="">
        <cfargument name="type" default="">
        <cfset responseStruct = structNew()>

        <cftry>
            <cfquery name="ADD_MINDMAP" datasource="#DSN#">
                INSERT INTO 
                    MINDMAP
                    (   
                        RECORD_DATE,
                        RECORD_EMP,
                        RECORD_IP,
                        MINDMAP_JSON,
                        FILE_NAME,
                        RELATIVE_ID,
                        RELATIVE_TYPE
                    )
                    VALUES
                    (
                        #now()#,
                        <cfif isdefined("session.ep.userid")>
                            <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#">
                        </cfif>,
                        <cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.remote_addr#">,
                        <cfqueryparam cfsqltype="cf_sql_nvarchar" value="#Replace(SerializeJSON(arguments.jsonForm),'//','')#">,
                        <cfif isdefined("arguments.filename") and len(arguments.filename)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.filename#"><cfelse><cfqueryparam cfsqltype="cf_sql_varchar" value="Mindmap1"></cfif>,
                        <cfif isdefined("arguments.prj_id") and len(arguments.prj_id)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.prj_id#"><cfelse>NULL</cfif>,
                        <cfif isdefined("arguments.type") and len(arguments.type)><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.type#"><cfelse>NULL</cfif>
                    )
            </cfquery>

            <cfquery name="GET_MINDMAP_ID" datasource="#dsn#" maxrows="1">
                SELECT * FROM MINDMAP   
                ORDER BY 
                MINDMAP_ID DESC
            </cfquery>

            <cfsavecontent variable="success"><cf_get_lang dictionary_id='61210.İşlem Başarılı'></cfsavecontent>
            <cfset responseStruct.message = "#success#">
            <cfset responseStruct.status = true>
            <cfset responseStruct.error = {}>
            <cfset responseStruct.identity =GET_MINDMAP_ID.MINDMAP_ID>

            <cfcatch>
                <cfsavecontent variable="error"><cf_get_lang dictionary_id='65894.İşlem hatalı'></cfsavecontent>
                <cfset responseStruct.message = "#error#">
                <cfset responseStruct.status = false>
                <cfset responseStruct.error = cfcatch>
            </cfcatch>
        </cftry>
        <cfreturn responseStruct>
    </cffunction>

    <cffunction name="UPD" access="remote" returntype="any" returnformat="JSON">
        <cfargument name="jsonForm" default="">
        <cfargument name="filename" default="">
        <cfargument name="prj_id" default="">
        <cfargument name="id" default="">
        <cftry>
            <cfset responseStruct = structNew()>
            <cfquery name="UPD_MINDMAP" datasource="#DSN#">
                UPDATE 
                    MINDMAP
                SET
                    RECORD_DATE = #now()#,
                    
                    RECORD_EMP = <cfif isdefined("session.ep.userid")><cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#"></cfif>,
                    RECORD_IP = <cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.remote_addr#">,
                    MINDMAP_JSON = <cfqueryparam cfsqltype="cf_sql_nvarchar" value="#Replace(SerializeJSON(arguments.jsonForm),'//','')#">,
                    FILE_NAME = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.filename#">,
                    RELATIVE_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.prj_id#">
                WHERE
                    MINDMAP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
            </cfquery>
            <cfsavecontent variable="success"><cf_get_lang dictionary_id='61210.İşlem Başarılı'></cfsavecontent>
            <cfset responseStruct.message = "#success#">
            <cfset responseStruct.status = true>
            <cfset responseStruct.error = {}>
            <cfset responseStruct.identity =arguments.id>

        <cfcatch>
            <cfsavecontent variable="error"><cf_get_lang dictionary_id='65894.İşlem hatalı'></cfsavecontent>
            <cfset responseStruct.message = "#error#">
            <cfset responseStruct.status = false>
            <cfset responseStruct.error = cfcatch>
        </cfcatch>
        </cftry>
        <cfreturn responseStruct>
    </cffunction>
    

    <cffunction name="DEL_MINDMAP" access="remote">
        <cfargument name="mindmap_id" default="">
            <cfset responseStruct = structNew()>
            <cfquery name="DEL_MINDMAP" datasource="#DSN#">
                DELETE FROM 
                    MINDMAP 
                WHERE
                    MINDMAP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.mindmap_id#">
            </cfquery>

        <cfreturn responseStruct>
    </cffunction>    
    
</cfcomponent>