<cfquery name="get_user_analysis_check" DATASOURCE="#DSN#" maxrows="1">
	SELECT 
		RESULT_ID
	FROM 
		MEMBER_ANALYSIS_RESULTS
	WHERE
		ANALYSIS_ID = #attributes.ANALYSIS_ID#
		<cfif isdefined("attributes.partner_id") and len(attributes.partner_id)>
			AND PARTNER_ID = #attributes.partner_id#
		</cfif>
		<cfif isdefined("attributes.consumer_id") and len(attributes.consumer_id)>
			AND CONSUMER_ID = #attributes.consumer_id#
		</cfif>
	ORDER BY
		RESULT_ID DESC
</cfquery>
