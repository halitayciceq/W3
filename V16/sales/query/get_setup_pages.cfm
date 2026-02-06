<cfquery name="get_setup_page_detail" datasource="#dsn#">
	SELECT 
	    PAGE_TYPE_ID, 
        PAGE_TYPE, 
        PAGE_TYPE_DETAIL, 
        OUR_COMPANY_IDS
    FROM 
    	SETUP_PAGE_TYPES
	<cfif isDefined("attributes.page_type")>		
	WHERE
		PAGE_TYPE_ID = #attributes.page_type#
	</cfif>			
</cfquery>
