<!--- coklu kayit cogalt --->
<cfif warning eq 1>
	<cfinclude template="../../project/query/add_work.cfm">
	<cfquery name="UPD_PRO_WORKS" datasource="#DSN#">
		UPDATE
			PRO_WORKS
		SET
			PERIODIC_WORK_ID = #get_last_work.work_id#
		WHERE
			WORK_ID = #get_last_work.work_id#
	</cfquery>
	<cfquery name="UPD_PRO_WORKS_HISTORY" datasource="#DSN#">
		UPDATE
			PRO_WORKS_HISTORY
		SET
			PERIODIC_WORK_ID = #get_last_work.work_id#
		WHERE
			WORK_ID = #get_last_work.work_id#
	</cfquery>
	<cfset get_periodic_work_id = get_last_work.work_id> 
	<cfloop from="1" to="#evaluate(form.warning_count-1)#" index="i">
		<cfscript>
			attributes.startdate_plan=date_add('h', session.ep.time_zone, attributes.startdate_plan);
			attributes.finishdate_plan=date_add('h', session.ep.time_zone, attributes.finishdate_plan);
			if(warning_type eq 7)
			{
				attributes.startdate_plan=date_add("ww",1,attributes.startdate_plan);
				attributes.finishdate_plan=date_add("ww",1,attributes.finishdate_plan); 
			}
			else if(warning_type eq 30)
			{
				attributes.startdate_plan = date_add("m",1,attributes.startdate_plan);
				attributes.finishdate_plan = date_add("m",1,attributes.finishdate_plan);
			}
			attributes.startdate_plan=dateformat(attributes.startdate_plan,dateformat_style);
			attributes.finishdate_plan=dateformat(attributes.finishdate_plan,dateformat_style);
		</cfscript>
		<cfinclude template="../../project/query/add_work.cfm">
	</cfloop>
	<cflocation url="#request.self#?fuseaction=project.works" addtoken="no">
<cfelse>
	<cfinclude template="../../project/query/add_work.cfm">
</cfif>
