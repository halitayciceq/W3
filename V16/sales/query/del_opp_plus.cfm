<cfquery name="DEL_OPP_PLUS" datasource="#dsn3#">
	DELETE
	FROM
		OPPORTUNITIES_PLUS
	WHERE
		OPP_PLUS_ID = #OPP_PLUS_ID#
</cfquery>
<script type="text/javascript">
	location.href = document.referrer;
	wrk_opener_reload();
	window.close();
</script>
