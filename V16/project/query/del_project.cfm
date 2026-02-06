<cfif isDefined("URL.ID")>
	<cflock name="#CreateUUID()#" timeout="60">
		<cftransaction>
        	<cfquery name="GET_PROJECT" datasource="#DSN#">
            	SELECT PROJECT_HEAD,PRO_CURRENCY_ID,PROJECT_NUMBER FROM PRO_PROJECTS WHERE PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#url.id#">
            </cfquery>
			<cfquery name="DEL_WORK_HISTORY" datasource="#DSN#">
				DELETE FROM PRO_WORKS_HISTORY WHERE WORK_ID IN (SELECT WORK_ID FROM PRO_WORKS WHERE PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#url.id#">)
			</cfquery>
			<cfquery name="DEL_WORK_CC" datasource="#dsn#">
				DELETE FROM PRO_WORKS_CC WHERE WORK_ID IN (SELECT WORK_ID FROM PRO_WORKS WHERE PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#url.id#">)
			</cfquery>
			<cfquery name="DEL_PRO_WORKS" datasource="#DSN#">
				DELETE FROM PRO_WORKS WHERE PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#url.id#">
			</cfquery>
			<cfquery name="DEL_WORKGROUP_EMP_PAR" datasource="#DSN#">
				DELETE FROM WORKGROUP_EMP_PAR WHERE PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#url.id#">
			</cfquery>
			<cfquery name="DEL_WORK_GROUP" datasource="#DSN#">
				DELETE FROM WORK_GROUP WHERE PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#url.id#">
			</cfquery>
			<cfquery name="DEL_PRO_HISTORY" datasource="#DSN#">
				DELETE FROM PRO_HISTORY WHERE PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#url.id#">
			</cfquery>
			<!--- İliskili Butceler Tablosundan İlgili Projeye Ait Kayitlar Siliniyor --->
			<cfquery name="DEL_RELATED_BUDGET" datasource="#DSN#">
				DELETE FROM PRO_RELATED_BUDGET WHERE PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#url.id#">
			</cfquery>
			<!--- Firsata bagli proje silindiginde fırsat kaydındaki proje_id alani guncelleniyor --->
			<cfif isdefined("attributes.opp_id") and len(attributes.opp_id)>
                <cfquery name="upd_opportunities" datasource="#dsn#">
                    UPDATE #dsn3_alias#.OPPORTUNITIES SET PROJECT_ID = NULL WHERE OPP_ID = #attributes.opp_id#
                </cfquery> 
            </cfif>
			<!--- Projenin Muhasebe Tanimlari siliniyor --->
			<cfquery name="get_our_comp" datasource="#dsn#">
				SELECT COMP_ID FROM OUR_COMPANY
			</cfquery>
			<cfloop query="get_our_comp">
				<cfquery name="Del_Project_Period" datasource="#dsn#">
					DELETE FROM #dsn#_#get_our_comp.comp_id#.PROJECT_PERIOD WHERE PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#url.id#">
				</cfquery>
			</cfloop>
			<!--- //Projenin Muhasebe Tanimlari siliniyor --->
			<!--- Proje ile iliskili Analiz sonuclarini sil  --->
			<cfquery name="DEL_ANALYSIS_RESULTS_DETAILS" datasource="#DSN#">
				DELETE FROM MEMBER_ANALYSIS_RESULTS_DETAILS WHERE RESULT_ID IN (SELECT RESULT_ID FROM MEMBER_ANALYSIS_RESULTS WHERE PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#url.id#">)
			</cfquery>
			<cfquery name="DEL_ANALYSIS_RESULTS_DETAILS" datasource="#DSN#">
				DELETE FROM MEMBER_ANALYSIS_RESULTS WHERE PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#url.id#">
			</cfquery>
			<cfquery name="DEL_PRO_PROJECTS" datasource="#DSN#">
				DELETE FROM PRO_PROJECTS WHERE PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#url.id#">
			</cfquery>
			<cfset attributes.action_section="PROJECT_ID">
			<cfset attributes.action_id=url.id>
			<cfinclude template="../../objects/query/del_assets.cfm">
			<cf_add_log log_type="-1" action_id="#attributes.id#" action_name="#get_project.project_head#" paper_no="#get_project.project_number#" process_stage="#get_project.pro_currency_id#">
		</cftransaction>
	</cflock>
</cfif>
<script type="text/javascript">
	window.location.href="<cfoutput>#request.self#</cfoutput>?fuseaction=project.projects";
</script>

