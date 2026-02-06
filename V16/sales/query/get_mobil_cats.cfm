<cfquery name="GET_MOBIL_CATS" datasource="#dsn#">
	SELECT 
		* 
	FROM 
		SETUP_MOBILCAT 
	ORDER BY 
		MOBILCAT
</cfquery>

