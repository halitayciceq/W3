<cfinclude template="../../agenda/query/upd_dates.cfm">
<cfif (link_id is "") and (warning eq 0)>
<!--- tek olayı tek olarak güncelle --->
	<cfinclude template="../../agenda/query/upd_event.cfm">
<cfelseif (link_id is "") and (warning eq 1)>
<!--- tek olayı çoðalt --->
	<cfset link_id = event_id>
	<!--- kaydı güncelle --->
	<cfinclude template="../../agenda/query/upd_event.cfm">
	<!--- çoğalt --->
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
<cfelseif len(link_id) and (warning eq 1)>
<!--- çokluyu çoklu olarak güncelle --->
	<cfset link_id = event_id>
	<!--- kaydı güncelle --->
	<cfinclude template="../../agenda/query/upd_event.cfm">
	<!--- çoğalt --->
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
<cfelseif len(link_id) and (warning eq 0)>
<!--- çokluyu tekli yap --->
	<cfset link_id = "">
	<!--- kaydı güncelle --->
	<cfinclude template="../../agenda/query/upd_event.cfm">
</cfif>
  <script type="text/javascript">
	wrk_opener_reload();
	window.close();
 </script>

