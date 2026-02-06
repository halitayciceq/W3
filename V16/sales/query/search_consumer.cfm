<cfquery name="SEARCH_CONSUMER" datasource="#dsn#">
	SELECT
		CONSUMER_ID,
		CONSUMER_NAME,
		CONSUMER_SURNAME,
		COMPANY,
		WORKADDRESS,
		CONSUMER_WORKTELCODE,
		CONSUMER_WORKTEL
	FROM
		CONSUMER
	WHERE
		CONSUMER_ID <> 0
	<cfif len(MEMBER_ID)>
		AND
		CONSUMER_ID = #MEMBER_ID#
	<cfelse>
		<cfif len(MEMBER_EMAIL)>
		AND
		CONSUMER_EMAIL = '#MEMBER_EMAIL#'
		</cfif>
		<cfif len(MEMBER_NAME)>
		AND
		CONSUMER_NAME LIKE '%#MEMBER_NAME#%'
		</cfif>
		<cfif len(MEMBER_SURNAME)>
		AND
		CONSUMER_SURNAME LIKE '%#MEMBER_SURNAME#%'
		</cfif>
		<cfif len(MEMBER_COMPANY)>
		AND
		COMPANY LIKE  '%#MEMBER_COMPANY#%'
		</cfif>
	</cfif>
		
</cfquery>
