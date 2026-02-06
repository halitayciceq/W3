<cfquery name="GET_CATS" datasource="#DSN#"><!--- project\cfc\get_work.cfc dosyasına taşındı--->
	SELECT
	#dsn#.Get_Dynamic_Language(SETUP_PRIORITY.PRIORITY_ID,'#session.ep.language#','SETUP_PRIORITY','PRIORITY',NULL,NULL,SETUP_PRIORITY.PRIORITY) AS priority,
	PRIORITY_ID
	FROM 
		SETUP_PRIORITY 
	ORDER BY
		PRIORITY
</cfquery>
