<cfif isdefined("STARTDATE") and len(STARTDATE)>
	<CF_DATE TARIH="STARTDATE">
</cfif>

<cfif isdefined("FINISHDATE") and len(FINISHDATE)>
	<CF_DATE TARIH="FINISHDATE">
</cfif>

<cfquery name="GET_EVENT_SEARCH" datasource="#dsn#">
	SELECT 
		EVENT_ID,
		STARTDATE,
		FINISHDATE,
		EVENTCAT,
		EVENT_HEAD
	FROM 
		EVENT,
		EVENT_CAT
	WHERE
		EVENT.EVENTCAT_ID = EVENT_CAT.EVENTCAT_ID
		<cfif isDefined("attributes.eventcat_id") and len(attributes.eventcat_id)>
			AND 
			EVENT.EVENTCAT_ID = #attributes.EVENTCAT_ID#
		</cfif>		
		<cfif isDefined('attributes.keyword') and len(attributes.keyword)>
			AND EVENT.EVENT_HEAD LIKE '%#attributes.keyword#%'
		</cfif>
		<cfif isdefined("STARTDATE") and len(STARTDATE) and isdefined("FINISHDATE") and len(FINISHDATE)>
		AND
		(
			(
			STARTDATE < #STARTDATE#
			AND
			FINISHDATE >= #STARTDATE#
			)
			OR
			(
			STARTDATE >= #STARTDATE#
			AND
			STARTDATE <= #FINISHDATE#
			)
		)
			
			<cfif len(STARTDATE) and len(FINISHDATE)>
				AND STARTDATE <= #FINISHDATE#
			</cfif>
		
			<cfif len(STARTDATE) and len(FINISHDATE)>
				AND FINISHDATE >= #STARTDATE#
			</cfif>
		</cfif>
		AND 
		(
			EVENT_TO_CON LIKE '%,#attributes.consumer_id#,%'
			OR
			EVENT_CC_CON LIKE '%,#attributes.consumer_id#,%'
			<!--- OR
			VIEW_TO_ALL=1 --->
		)
</cfquery>
