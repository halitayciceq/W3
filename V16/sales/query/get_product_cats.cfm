<cfquery name="GET_PRODUCT_CATS" datasource="#DSN3#">
	SELECT 
		PC.PRODUCT_CATID, 
		PC.PRODUCT_CAT,
		PC.HIERARCHY
	FROM 
		PRODUCT_CAT PC,
		#dsn1#.PRODUCT_CAT_OUR_COMPANY PCO
	WHERE
		PC.PRODUCT_CATID = PCO.PRODUCT_CATID AND
		PCO.OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#">
	ORDER BY 
		PC.HIERARCHY
</cfquery>
