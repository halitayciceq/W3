<cfquery name="DEL_ORDER_FILE" datasource="#dsn3#">
	DELETE 
		ORDER_FILE 
	WHERE 
		ORDER_FILE_ID = #URL.FID#
</cfquery>
<cflocation url="#cgi.referer#" addtoken="no">
