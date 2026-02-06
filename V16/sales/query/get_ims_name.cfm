<cfquery name="GET_IMS_NAME" datasource="#dsn#">
	SELECT 
		IMS_CODE_NAME,
		IMS_ID
	FROM
		SETUP_IMS_CODE
	WHERE
		IMS_CODE_ID = #attributes.IMS_ID#
</cfquery>
