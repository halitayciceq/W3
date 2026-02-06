<cfif attributes.type eq 1>
    <cfquery name="UPD_WORK_RELATION" datasource="#dsn#">
        UPDATE 
            PRO_WORKS
        SET
            SERVICE_ID = <cfqueryparam value = "" CFSQLType = "cf_sql_integer" null = "yes">
        WHERE
            WORK_ID = <cfqueryparam value = "#attributes.WORK_ID#" CFSQLType = "cf_sql_integer">
    </cfquery>
<cfelseif attributes.type eq 2>
	<cfquery name="UPD_WORK_RELATION" datasource="#dsn#">
        UPDATE 
            PRO_WORKS
        SET
            ASSETP_ID = <cfqueryparam value = "" CFSQLType = "cf_sql_integer" null = "yes">
        WHERE
            WORK_ID = <cfqueryparam value = "#attributes.WORK_ID#" CFSQLType = "cf_sql_integer">
    </cfquery>  
<cfelseif attributes.type eq 3>
	<cfquery name="UPD_WORK_RELATION" datasource="#dsn#">
        UPDATE 
            PRO_WORKS
        SET
            G_SERVICE_ID = <cfqueryparam value = "" CFSQLType = "cf_sql_integer" null = "yes">
        WHERE
            WORK_ID = <cfqueryparam value = "#attributes.WORK_ID#" CFSQLType = "cf_sql_integer">
    </cfquery> 
<cfelseif attributes.type eq 4> 
	<cfquery name="UPD_WORK_RELATION" datasource="#dsn#">
        UPDATE 
            PRO_WORKS
        SET
            PROJECT_ID = <cfqueryparam value = "" CFSQLType = "cf_sql_integer" null = "yes">
        WHERE
            WORK_ID = <cfqueryparam value = "#attributes.WORK_ID#" CFSQLType = "cf_sql_integer"> 
    </cfquery> 
    <cfquery name="DLT_WORK_RELATION" datasource="#dsn#">
        DELETE PRO_WORK_RELATIONS WHERE WORK_ID = <cfqueryparam value = "#attributes.WORK_ID#" CFSQLType = "cf_sql_integer">
    </cfquery> 
<cfelseif attributes.type eq 5>
	<cfquery name="UPD_WORK_RELATION" datasource="#dsn#">
        UPDATE 
            PRO_WORKS
        SET
            OPPORTUNITY_ID = <cfqueryparam value = "" CFSQLType = "cf_sql_integer" null = "yes">
        WHERE
            WORK_ID = <cfqueryparam value = "#attributes.WORK_ID#" CFSQLType = "cf_sql_integer">
    </cfquery>  
<cfelseif attributes.type eq 6>
	<cfquery name="UPD_WORK_RELATION" datasource="#dsn#">
        UPDATE 
            PRO_WORKS
        SET
            SUBSCRIPTION_ID = <cfqueryparam value = "" CFSQLType = "cf_sql_integer" null = "yes">
        WHERE
            WORK_ID = <cfqueryparam value = "#attributes.WORK_ID#" CFSQLType = "cf_sql_integer">
    </cfquery>                    
<cfelseif attributes.type eq 7>
	<cfquery name="UPD_WORK_RELATION" datasource="#dsn#">
        UPDATE 
            PRO_WORKS
        SET
            PRODUCT_SAMPLE_ID = <cfqueryparam value = "" CFSQLType = "cf_sql_integer" null = "yes">
        WHERE
            WORK_ID = <cfqueryparam value = "#attributes.WORK_ID#" CFSQLType = "cf_sql_integer">
    </cfquery>                    
</cfif>
<script type="text/javascript">
    <cfif isdefined("attributes.draggable") and len(attributes.draggable)>
    closeBoxDraggable( '<cfoutput>#attributes.modal_id#</cfoutput>','box_works_b'); 
        <cfelse>
            wrk_opener_reload(); 
        window.close();
    </cfif>
	
</script>
