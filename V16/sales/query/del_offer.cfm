<!--- ilgili varlıklar db ve hdd den silinir --->
<cfset attributes.action_id=attributes.offer_id>
<cfset attributes.action_section="OFFER_ID">
<cfinclude template="../../objects/query/del_assets.cfm">
<cfquery name="get_process" datasource="#dsn3#">
	SELECT OFFER_STAGE,OFFER_NUMBER,OPP_ID FROM OFFER WHERE OFFER_ID=#attributes.OFFER_ID#
</cfquery>
<cflock name="#CREATEUUID()#" timeout="20">
	<cftransaction>	
    	<cfscript>
			add_relation_rows(
				action_type:'del',
				action_dsn : '#dsn3#',
				to_table:'OFFER',
				to_action_id : attributes.offer_id
				);
		</cfscript>
		
		<cfif Len(get_process.opp_id)>
			<!--- Iliskili Firsat ile Baglantisi Koparilir --->
			<cfquery name="get_relation_opp" datasource="#dsn3#">
				SELECT OPP_ID FROM OFFER WHERE OPP_ID = #get_process.opp_id# AND OFFER_ID != #attributes.offer_id#
			</cfquery>
			<cfif not get_relation_opp.recordcount>
				<cfquery name="upd_opp_relation_process" datasource="#dsn3#">
					UPDATE OPPORTUNITIES SET IS_PROCESSED = 0 WHERE OPP_ID = #get_process.opp_id#
				</cfquery>
			</cfif>
		</cfif>
		
		<!--- takipler db den silinir --->
		<cfquery name="DEL_OFFER_PLUS" datasource="#DSN3#">
			DELETE FROM OFFER_PLUS WHERE OFFER_ID = #attributes.offer_id#
		</cfquery>
		<cfquery name="DEL_OFFER_PAGES" datasource="#DSN3#">
			DELETE FROM OFFER_PAGES WHERE OFFER_ID = #attributes.offer_id#
		</cfquery>
		
		<!---  urun asortileri siliniyor  ---> 
		<cfquery name="DEL_OFFER_ASSORT_ROWS" datasource="#DSN3#">
			DELETE FROM
				PRODUCTION_ASSORTMENT
			WHERE
				ACTION_TYPE = 1 AND 
				ASSORTMENT_ID IN
								(
									SELECT
										 OFFER_ROW_ID 
									FROM
										OFFER_ROW
									WHERE
										OFFER_ID = #attributes.offer_id#			
								)
		</cfquery>
		<cfquery name="DEL_OFFER_PRODUCTS" datasource="#DSN3#">
			DELETE FROM OFFER_ROW WHERE OFFER_ID = #attributes.offer_id#
		</cfquery>
		<cfquery name="DEL_OFFER" datasource="#DSN3#">
			DELETE FROM OFFER WHERE OFFER_ID = #attributes.offer_id#
		</cfquery>
		<cfquery name="DEL_ANALYSIS_RESULTS_DETAILS" datasource="#DSN3#">
			DELETE FROM #dsn_alias#.MEMBER_ANALYSIS_RESULTS_DETAILS WHERE RESULT_ID IN (SELECT RESULT_ID FROM #dsn_alias#.MEMBER_ANALYSIS_RESULTS WHERE OFFER_ID = #attributes.offer_id# AND OUR_COMPANY_ID = #session.ep.company_id#)
		</cfquery>
		<cfquery name="DEL_ANALYSIS_RESULTS_DETAILS" datasource="#DSN3#">
			DELETE FROM #dsn_alias#.MEMBER_ANALYSIS_RESULTS WHERE OFFER_ID = #attributes.offer_id# AND OUR_COMPANY_ID = #session.ep.company_id#
		</cfquery>
		
		<!--- History Kayitlari Silinir --->
		<cfquery name="Del_History_Row" datasource="#dsn3#">
			DELETE FROM OFFER_ROW_HISTORY WHERE OFFER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.offer_id#">
		</cfquery>
		<cfquery name="Del_History" datasource="#dsn3#">
			DELETE FROM OFFER_HISTORY WHERE OFFER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.offer_id#">
		</cfquery>
		<!--- Belge Silindiginde Bagli Uyari/Onaylar Da Silinir --->
		<cfquery name="Del_Relation_Warnings" datasource="#dsn3#">
			DELETE FROM #dsn_alias#.PAGE_WARNINGS WHERE ACTION_TABLE = 'OFFER' AND ACTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.offer_id#"> AND OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#">
		</cfquery>
		<cf_add_log data_source="#dsn3#" log_type="-1" action_id="#attributes.offer_id#" action_name="#attributes.pageHead#" paper_no="#get_process.offer_number#" process_stage="#get_process.offer_stage#">
        </cftransaction>
</cflock>
<script type="text/javascript">
	window.location.href="<cfoutput>#request.self#?fuseaction=sales.list_offer</cfoutput>";
</script>
