<!--- ilgili varlıklar db ve hdd den silinir --->
<cfset attributes.action_id=attributes.opp_id>
<cfset attributes.action_section="OPP_ID">
<cflock name="#CREATEUUID()#" timeout="20">
    <cftransaction>
        <cfinclude template="../../objects/query/del_assets.cfm">
    </cftransaction>
</cflock>
<cflock name="#CREATEUUID()#" timeout="20">
	<cftransaction>
    	<cfquery name="getOpp" datasource="#dsn3#">
        	SELECT OPP_NO,OPP_HEAD,OPPORTUNITY_TYPE_ID FROM OPPORTUNITIES WHERE OPP_ID = #attributes.opp_id#
        </cfquery>
    
    
        <cfquery name="DEL_ANALYSIS_RESULTS_DETAILS" datasource="#DSN3#">
            DELETE FROM #dsn_alias#.MEMBER_ANALYSIS_RESULTS_DETAILS WHERE RESULT_ID IN (SELECT RESULT_ID FROM #dsn_alias#.MEMBER_ANALYSIS_RESULTS WHERE OPPORTUNITY_ID = #attributes.opp_id# AND OUR_COMPANY_ID = #session.ep.company_id#)
        </cfquery>
        <cfquery name="DEL_ANALYSIS_RESULTS_DETAILS" datasource="#DSN3#">
            DELETE FROM #dsn_alias#.MEMBER_ANALYSIS_RESULTS WHERE OPPORTUNITY_ID = #attributes.opp_id# AND OUR_COMPANY_ID = #session.ep.company_id#
        </cfquery>
        
		<cfquery name="DEL_WORKGROUP_EMP_PAR" datasource="#DSN3#">
			DELETE FROM #dsn_alias#.WORKGROUP_EMP_PAR WHERE OPP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.opp_id#">
		</cfquery>
		<cfquery name="DEL_WORK_GROUP" datasource="#DSN3#">
			DELETE FROM #dsn_alias#.WORK_GROUP WHERE OPP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.opp_id#">
		</cfquery>
        <!--- Takipler silinir --->
        <cfquery name="DEL_OPPORTUNITIES_PLUS" datasource="#DSN3#">
            DELETE FROM OPPORTUNITIES_PLUS WHERE OPP_ID = #attributes.opp_id#
        </cfquery>
		<!--- İlişkili teklif ile fırsat arasındaki ilişkiyi siliyor --->
        <cfquery name="UPD_OFFER" datasource="#DSN3#">
            UPDATE OFFER SET OPP_ID = NULL WHERE OPP_ID = #attributes.opp_id#
        </cfquery>
        
         <cfquery name="UPD_EVENTS_RELATED" datasource="#DSN3#">
            UPDATE
                #dsn_alias#.EVENTS_RELATED
            SET
                ACTION_ID = NULL
            WHERE
               ACTION_ID = #attributes.opp_id# AND
               COMPANY_ID =#session.ep.company_id#   
        </cfquery>
        <cfquery name="DEL_OPPORTUNITIES" datasource="#DSN3#">
            DELETE FROM OPPORTUNITIES WHERE OPP_ID = #attributes.opp_id#
        </cfquery>
		<cf_add_log employee_id="#session.ep.userid#" log_type="-1" data_source="#dsn3#" action_id="#attributes.opp_id#" action_name="#getOpp.opp_head# " period_id="#session.ep.period_id#" process_cat="#getOpp.opportunity_type_id#" paper_no="#getOpp.opp_no#">
    </cftransaction>
</cflock>
<script type="text/javascript">
	window.location.href = '<cfoutput>#request.self#?fuseaction=sales.list_opportunity</Cfoutput>';
</script>

