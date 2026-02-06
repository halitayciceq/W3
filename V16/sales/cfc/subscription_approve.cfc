<cfcomponent>
    <cfset dsn = application.systemParam.systemParam().dsn />
    <cffunction name="add_subscription_approve"  access="public" returntype="any">
        <cfargument name="company_id" type="any" required="false" default="" hint="System Company Id">
        <cfargument name="subscription_id" type="any" required="false" default="" hint="Subscription Id">
        <cfargument name="subscription_no" type="any" required="false" default="" hint="Subscription No">
        <cfargument name="app_domain" type="any" required="false" default="" hint="Subscription Domain">
        <cfargument name="app_name_surname" type="any" required="false" default="" hint="Subscription User Name Surname">
        <cfargument name="release_no" type="any" required="false" default="" hint="Subscription System Release No">
        <cfargument name="patch_no" type="any" required="false" default="" hint="Subscription System Patch No">

        <cfset responseStruct = structNew()>
        <cftry>
            <cfif IsDefined("arguments.company_id") and len(arguments.company_id)>
                <cfquery name="get_subscription" datasource="#dsn#_#arguments.company_id#">
                    SELECT SUBSCRIPTION_ID FROM SUBSCRIPTION_CONTRACT WHERE SUBSCRIPTION_NO = <cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.subscription_no#">
                </cfquery>
                <cfif get_subscription.recordcount><cfset arguments.subscription_id = get_subscription.SUBSCRIPTION_ID /></cfif>
            </cfif>

            <cfquery name="add_approve" datasource="#dsn#" result="my_result">
                IF NOT EXISTS(SELECT * FROM SUBSCRIPTION_CONTRACT_APPROVE WHERE SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_id#"> AND APP_DOMAIN = <cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.app_domain#">)
                BEGIN
                    INSERT INTO SUBSCRIPTION_CONTRACT_APPROVE
                    (
                        SUBSCRIPTION_ID
                        ,APP_DOMAIN
                        ,APP_APPROVED_DATE
                        ,APP_APPROVED_NAME_SURNAME
                        ,RELEASE_NO
                        ,PATCH_NO
                    )
                    VALUES
                    (
                        <cfif isdefined("arguments.subscription_id") and len(arguments.subscription_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_id#"><cfelse>NULL</cfif>,
                        <cfif isdefined("arguments.app_domain") and len(arguments.app_domain)><cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.app_domain#"><cfelse>NULL</cfif>,
                        <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
                        <cfif isdefined("arguments.app_name_surname") and len(arguments.app_name_surname)><cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.app_name_surname#"><cfelse>NULL</cfif>,
                        <cfif isdefined("arguments.release_no") and len(arguments.release_no)><cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.release_no#"><cfelse>NULL</cfif>,
                        <cfif isdefined("arguments.patch_no") and len(arguments.patch_no)><cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.patch_no#"><cfelse>NULL</cfif>
                    )
                END
                ELSE
                BEGIN
                    UPDATE SUBSCRIPTION_CONTRACT_APPROVE SET
                        APP_APPROVED_DATE = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
                        APP_APPROVED_NAME_SURNAME = <cfif isdefined("arguments.app_name_surname") and len(arguments.app_name_surname)><cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.app_name_surname#"><cfelse>NULL</cfif>,
                        RELEASE_NO = <cfif isdefined("arguments.release_no") and len(arguments.release_no)><cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.release_no#"><cfelse>NULL</cfif>,
                        PATCH_NO = <cfif isdefined("arguments.patch_no") and len(arguments.patch_no)><cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.patch_no#"><cfelse>NULL</cfif>
                    WHERE 
                        SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_id#"> 
                        AND APP_DOMAIN = <cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.app_domain#">
                END;
            </cfquery>
            <cfset responseStruct.message = "İşlem Başarılı">
            <cfset responseStruct.status = true>
            <cfset responseStruct.error = {}>
            <cfset responseStruct.identity = my_result.identitycol?:''>
            <cfcatch>
                <cfset responseStruct.message = "İşlem Hatalı">
                <cfset responseStruct.status = false>
                <cfset responseStruct.error = cfcatch>
            </cfcatch>
        </cftry>
        <cfreturn responseStruct>
    </cffunction>
    <cffunction name="get_subscription_approve"  access = "public">
        <cfargument name="company_id" type="any" required="false" default="" hint="System Company Id">
        <cfargument name="subscription_id" type="any" required="false" default="" hint="Subscription id">
        <cfargument name="app_domain" type="any" required="false" default="" hint="Subscription Domain">

        <cfquery name="get_approve"  datasource="#DSN#">
            SELECT 
                SCA.*,
                SC.SUBSCRIPTION_NO,
                SC.SUBSCRIPTION_HEAD
            FROM SUBSCRIPTION_CONTRACT_APPROVE AS SCA
            JOIN #dsn#_#arguments.company_id#.SUBSCRIPTION_CONTRACT AS SC ON SCA.SUBSCRIPTION_ID=SC.SUBSCRIPTION_ID
            WHERE 
                1 = 1
                <cfif IsDefined("arguments.subscription_id") and len(arguments.subscription_id)>
                    AND SCA.SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_id#">
                </cfif>
                <cfif IsDefined("arguments.app_domain") and len(arguments.app_domain)>
                    AND SCA.APP_DOMAIN = <cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.app_domain#">
                </cfif>
            ORDER BY
                SCA.APP_APPROVED_DATE DESC
        </cfquery>
        <cfreturn get_approve>
    </cffunction>
    
 <!--- abone id parametresiyle abone numarasını geri döndürür  PY --->
 <cffunction name="get_subscription_no" access = "public" returntype="query">
    <cfargument name="company_id" required="no" type="numeric">
    <cfargument name="subscription_id" required="no" type="numeric">
            <cfquery name="get_subscription_no" datasource="#dsn#_#arguments.company_id#">
                SELECT SUBSCRIPTION_ID,SUBSCRIPTION_NO,FINISH_DATE  FROM SUBSCRIPTION_CONTRACT WHERE SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.subscription_id#">
            </cfquery>
        <cfreturn get_subscription_no>
</cffunction>
</cfcomponent>


