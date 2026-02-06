<cfquery name="GET_OFFER_PAGES" datasource="#DSN3#">
	SELECT
		PAGE_ID,
		OFFER_ID,
		PAGE_NO,
		PAGE_TYPE,
		PAGE_NAME,
		PAGE_CONTENT
	FROM
		OFFER_PAGES
	WHERE
		OFFER_ID = #attributes.OFFER_ID#
	ORDER BY
		PAGE_NO
</cfquery>
