<cfquery name="GET_PROBABILITY_RATE" datasource="#dsn3#">
	SELECT 
    	PROBABILITY_RATE_ID, 
        PROBABILITY_RATE, 
        PROBABILITY_NAME, 
        RECORD_EMP, 
        RECORD_DATE, 
        RECORD_IP, 
        UPDATE_EMP, 
        UPDATE_DATE, 
        UPDATE_IP 
    FROM 
    	SETUP_PROBABILITY_RATE 
    ORDER BY 
	    PROBABILITY_RATE ASC
</cfquery>
