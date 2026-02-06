<cfquery name="INS_OFFER_PLUS" datasource="#dsn#">
	INSERT INTO
		EVENTS_RELATED
		(
		ACTION_ID,
		ACTION_SECTION,
		EVENT_ID,
		COMPANY_ID		
		)		
	VALUES
	 	(
		#ATTRIBUTES.ACTION_ID#,
		'#ATTRIBUTES.ACTION_SECTION#',
		#ATTRIBUTES.EVENT_ID#,
		<cfif isdefined("session.ep.company_id")>
		#session.ep.company_id#
		<cfelse>
		#session.pp.our_company_id#
		</cfif>		
		)
	
</cfquery>
<script type="text/javascript">
	wrk_opener_reload();
	window.close();
</script>
