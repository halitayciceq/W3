<cfquery name="GET_OPP_PLUS" datasource="#dsn3#">
	SELECT 
        OPP_PLUS_ID, 
        PLUS_DATE, 
        COMMETHOD_ID, 
        EMPLOYEE_ID, 
        PLUS_CONTENT, 
        MAIL_SENDER, 
        PLUS_SUBJECT, 
        MAIL_CC 
    FROM 
	    OPPORTUNITIES_PLUS 
    WHERE 
    	OPP_PLUS_ID = #OPP_PLUS_ID#
</cfquery>
