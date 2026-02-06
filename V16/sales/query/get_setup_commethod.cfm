<!--- get_setup_commethod.cfm --->
<cfquery name="GET_SETUP_COMMETHOD" datasource="#dsn#">
SELECT COMMETHOD_ID, COMMETHOD FROM SETUP_COMMETHOD
</cfquery>
