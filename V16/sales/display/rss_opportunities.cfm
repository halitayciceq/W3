<cfsetting showdebugoutput="no">
<cfquery name="GET_OPPORTUNITIES" datasource="#DSN3#">
	SELECT 
		OPP_ID AS ID,
		OPP_HEAD AS HEAD,
		OPP_DETAIL AS DETAIL,
		OPP_DATE AS DATE
	FROM 
		OPPORTUNITIES
	ORDER BY
		OPP_DATE DESC	
</cfquery>
<cfinclude template="../../objects/display/get_rss.cfm">
<cfoutput>
	#create_rss("opportunity",GET_OPPORTUNITIES)#
</cfoutput>




