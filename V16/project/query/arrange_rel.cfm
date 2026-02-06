<cfquery name="GET_UST_REL" datasource="#dsn#">
	SELECT
		RELATED_WORK_ID
	FROM
		PRO_WORKS
	WHERE
		WORK_ID=#URL.WORK_ID#
</cfquery>
<cfoutput>
	<cfset ust_rel=get_ust_rel.RELATED_WORK_ID>
</cfoutput>
<cfquery name="GET_ALT_REL" datasource="#dsn#">
	SELECT
		WORK_ID
	FROM
		PRO_WORKS
	WHERE
		RELATED_WORK_ID=#URL.WORK_ID#
</cfquery>
<cfoutput>
	<cfset alt_rel=get_alt_rel.WORK_ID>
</cfoutput>
<cfif len(alt_rel)>
<cfquery name="UPD_REL" datasource="#dsn#">
	UPDATE
		PRO_WORKS
	SET
		RELATED_WORK_ID=#UST_REL#
	WHERE
		WORK_ID=#ALT_REL#
</cfquery>
</cfif>
<script type="text/javascript">
window.close();
</script>
