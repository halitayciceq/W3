<!--- get_commethod.cfm --->
<cfquery name="GET_COMMETHOD" datasource="#DSN#">
	SELECT 
		* 
	FROM
		SETUP_COMMETHOD
	<cfif isDefined("attributes.COMMETHOD_ID")>
	WHERE
		COMMETHOD_ID = #attributes.COMMETHOD_ID#
	</cfif>
</cfquery>
