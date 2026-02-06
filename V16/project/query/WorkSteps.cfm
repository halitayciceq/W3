<cfscript>
	cfc = createObject("component","V16.project.cfc.get_work");
	//del_workSteps = cfc.delWorkSteps(WORK_ID:attributes.work_id);
</cfscript>
<cfif isDefined("attributes.issort") and attributes.issort eq 1>
    <cfset data = deserializeJSON(attributes.contents) />
    <cfloop array="#data#" item="i">
        <cfset upd_order = cfc.upd_work_step_order(
            work_step_id: i.work_step_id,
            work_id: i.work_id,
            content_rank: i.content_rank
        ) />
    </cfloop>
<cfelse>
    <cfscript>
        del_workSteps = cfc.delWorkSteps(WORK_ID:attributes.work_id);
    </cfscript>
    <cfloop from="1" to="#attributes.record_num#" index="i">
        <cfscript>
            if(evaluate('attributes.step_kontrol#i#') == 1) {
                addWorkSteps = cfc.addWorkSteps(
                WORK_ID : attributes.work_id,
                WORK_STEP_DETAIL : attributes["WORK_STEP_DETAIL#i#"],
                work_step_hour: evaluate(attributes["work_step_hour#i#"]),
                work_step_minute : evaluate(attributes["work_step_minute#i#"]),
                rank_order : "#i#",
                completion : iif(isdefined("attributes.completion#i#"),'val(attributes["completion#i#"])',DE("0"))
                ); 
            }
        </cfscript>
    </cfloop>
    <script>
            refresh_box('work_steps','index.cfm?fuseaction=project.workSteps&id=<cfoutput>#attributes.work_id#</cfoutput>','0');
    </script>
</cfif>