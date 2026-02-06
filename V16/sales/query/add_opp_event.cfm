<cfinclude template="../../agenda/query/upd_dates.cfm">
<cfif warning eq 0>
<!--- tekli kayıt --->
	<cfinclude template="../../agenda/query/add_event.cfm">
<cfelseif warning eq 1>
<!--- çoklu kayıt --->
	<!--- çoğalt --->
<cfinclude template="../../agenda/query/add_event.cfm">
	<cfif warning eq 1>
		<cfquery name="UPD_LINK" datasource="#DSN#">
			UPDATE
				EVENT
			SET
				LINK_ID = #GET_LAST_EVENT_ID.MAX_ID#
			WHERE
				EVENT_ID = #GET_LAST_EVENT_ID.MAX_ID#
		</cfquery>
	</cfif>
	<cfset link_id = get_last_event_id.max_id>
	<cfloop from="1" to="#evaluate(form.warning_count-1)#" index="i">
		<cfif warning_type eq 7>
			<!--- hafta ekle --->
			<cfset form.startdate = date_add("ww",1,form.startdate)>
			<cfset form.finishdate = date_add("ww",1,form.finishdate)>
			<cfset form.SMS_ALERT_DAY = date_add("ww",1,form.SMS_ALERT_DAY)>
			<cfset form.email_ALERT_DAY = date_add("ww",1,form.email_ALERT_DAY)>
			<cfif len(form.warning_start)>
				<cfset form.warning_start = date_add("ww",1,form.warning_start)>
			</cfif>
		<cfelseif warning_type eq 30>
			<!--- ay ekle --->
			<cfset form.startdate = date_add("m",1,form.startdate)>
			<cfset form.finishdate = date_add("m",1,form.finishdate)>
			<cfset form.SMS_ALERT_DAY = date_add("m",1,form.SMS_ALERT_DAY)>
			<cfset form.email_ALERT_DAY = date_add("m",1,form.email_ALERT_DAY)>
			<cfif len(form.warning_start)>
				<cfset form.warning_start = date_add("m",1,form.warning_start)>
			</cfif>
		</cfif>
		<cfinclude template="../../agenda/query/add_event.cfm">
	</cfloop>
	  <script type="text/javascript">
	   wrk_opener_reload();
	   window.close();
	 </script>
</cfif>

