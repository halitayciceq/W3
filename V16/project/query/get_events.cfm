<cfif isdefined("attributes.start_date") and len(attributes.start_date)><cf_date tarih='attributes.start_date'></cfif>
<cfif isdefined("attributes.finish_date") and len(attributes.finish_date)><cf_date tarih='attributes.finish_date'></cfif>
<cfif isdefined("session.agenda_userid")>
<!--- başkasında --->
	<cfif session.agenda_user_type is "p">
	<!--- par --->
		<cfquery name="GET_GROUPS" datasource="#DSN#">
			SELECT
				GROUP_ID
			FROM
				USERS
			WHERE
				PARTNERS LIKE '%,#SESSION.AGENDA_USERID#,%'
		</cfquery>
		<cfquery name="GET_WORKGROUPS" datasource="#DSN#">
		   SELECT
			   WORKGROUP_ID
			 FROM
			    WORKGROUP_EMP_PAR
			 WHERE
			    PARTNER_ID = #SESSION.AGENDA_USERID#	
		</cfquery>

	<cfelseif session.agenda_user_type is "e">
	<!--- emp --->
		<cfquery name="GET_GROUPS" datasource="#DSN#">
			SELECT
				GROUP_ID
			FROM
				USERS
			WHERE
				POSITIONS LIKE '%,#SESSION.AGENDA_POSITION_CODE#,%'
		</cfquery>
		<cfquery name="GET_WORKGROUPS" datasource="#DSN#">
             SELECT
			   WORKGROUP_ID
			 FROM
			    WORKGROUP_EMP_PAR
			 WHERE
			    POSITION_CODE = #SESSION.AGENDA_POSITION_CODE#		  
		</cfquery>

	</cfif>
<cfelse>
<!--- kendinde --->
	<cfquery name="GET_GROUPS" datasource="#DSN#">
		SELECT
			GROUP_ID
		FROM
			USERS
		WHERE
			POSITIONS LIKE '%,#session.pp.userid#,%'
	</cfquery>
	 <cfquery name="GET_WORKGROUPS" datasource="#DSN#">
         SELECT
			WORKGROUP_ID
		 FROM
	        WORKGROUP_EMP_PAR
		 WHERE
		    POSITION_CODE = #session.pp.userid#		  
		</cfquery>
</cfif>

<cfset groups = valuelist(get_groups.group_id)>
<cfset workgroups = valuelist(get_workgroups.workgroup_id)>

<cfquery name="GET_EVENT" datasource="#DSN#">
	SELECT
		EVENT.EVENT_ID,
		EVENT.EVENT_HEAD,
		EVENT.RECORD_EMP,
		EVENT.EVENT_TO_POS,
		EVENT.EVENT_TO_PAR,
		EVENT.STARTDATE,
		EVENT.FINISHDATE,
		EVENT.EVENTCAT_ID,
		EVENT_CAT.EVENTCAT
	FROM
		EVENT,
		EVENT_CAT
	WHERE 
	    EVENT.EVENTCAT_ID <> 4 AND
		EVENT.EVENTCAT_ID = EVENT_CAT.EVENTCAT_ID AND
		EVENT_HEAD LIKE '%#attributes.keyword#%'
		<cfif isdefined("attributes.event_cat") and len(attributes.event_cat)>AND EVENT.EVENTCAT_ID = #attributes.event_cat#</cfif>
		<cfif isdefined("attributes.start_date") and isdefined("attributes.finish_date") and len(attributes.start_date) and len(attributes.finish_date)>
		AND
		(
			(STARTDATE < #attributes.start_date# AND FINISHDATE >= #attributes.start_date#) OR
			(STARTDATE >= #attributes.start_date# AND STARTDATE <= #attributes.finish_date#)
		)
		</cfif>
				AND 
		(
		<cfif isDefined("SESSION.AGENDA_USERID")>
		<!--- BAŞKASİNDA --->
			<cfif SESSION.AGENDA_USER_TYPE IS "P">
			<!--- PAR --->
			(
				(
				EVENT.RECORD_PAR = #SESSION.AGENDA_USERID#
				OR EVENT.UPDATE_PAR = #SESSION.AGENDA_USERID#
				)
				AND EVENT_CAT.EVENTCAT_ID <> 1
			)
			OR EVENT.EVENT_TO_PAR LIKE '%,#SESSION.AGENDA_USERID#,%'
			OR EVENT.EVENT_CC_PAR LIKE '%,#SESSION.AGENDA_USERID#,%'
			<cfloop LIST="#GRPS#" INDEX="GRP_I">
				OR EVENT.EVENT_TO_GRP LIKE '%,#GRP_I#,%'
			</cfloop>
			<cfloop LIST="#GRPS#" INDEX="GRP_I">
				OR EVENT.EVENT_CC_GRP LIKE '%,#GRP_I#,%'
			</cfloop>
			<cfloop list="#wrkgroups#" index="WRK">
			   OR EVENT.EVENT_TO_WRKGROUP LIKE '%,#WRK#,%'
			</cfloop>
			<cfloop list="#wrkgroups#" index="WRK">
			  OR EVENT.EVENT_CC_WRKGROUP LIKE '%,#WRK#,%'
			</cfloop>

			<cfelseif SESSION.AGENDA_USER_TYPE IS "E">
			<!--- EMP --->
			(
				(
				EVENT.RECORD_EMP = #SESSION.AGENDA_USERID#
				OR EVENT.UPDATE_EMP = #SESSION.AGENDA_USERID#
				)
				AND EVENT_CAT.EVENTCAT_ID <> 1
			)
			OR EVENT.EVENT_TO_POS LIKE '%,#SESSION.AGENDA_POSITION_CODE#,%'
			OR EVENT.EVENT_CC_POS LIKE '%,#SESSION.AGENDA_POSITION_CODE#,%'
			OR EVENT.VALIDATOR_POSITION_CODE = #SESSION.AGENDA_POSITION_CODE#
			<cfloop LIST="#GRPS#" INDEX="GRP_I">
				OR EVENT.EVENT_TO_GRP LIKE '%,#GRP_I#,%'
			</cfloop>
			<cfloop LIST="#GRPS#" INDEX="GRP_I">
				OR EVENT.EVENT_CC_GRP LIKE '%,#GRP_I#,%'
			</cfloop>
			<cfloop list="#wrkgroups#" index="WRK">
			   OR EVENT.EVENT_TO_WRKGROUP LIKE '%,#WRK#,%'
			</cfloop>
			<cfloop list="#wrkgroups#" index="WRK">
			  OR EVENT.EVENT_CC_WRKGROUP LIKE '%,#WRK#,%'
			</cfloop>
			</cfif>
		<cfelse>
		<!--- KENDINDE --->
			EVENT.RECORD_EMP = #session.pp.userid#
			OR EVENT.UPDATE_EMP = #session.pp.userid#
			OR EVENT.EVENT_TO_POS LIKE '%,#session.pp.userid#,%'<!--- SESSION.EP.POSITION_CODE --->
			OR EVENT.EVENT_CC_POS LIKE '%,#session.pp.userid#,%'
			OR EVENT.VALIDATOR_POSITION_CODE = #session.pp.userid#
			<cfloop LIST="#GROUPS#" INDEX="GRP_I">
				OR EVENT.EVENT_TO_GRP LIKE '%,#GRP_I#,%'
			</cfloop>
			<cfloop LIST="#GROUPS#" INDEX="GRP_I">
				OR EVENT.EVENT_CC_GRP LIKE '%,#GRP_I#,%'
			</cfloop>
			<cfloop list="#WORKGROUPS#" index="WRK">
			   OR EVENT.EVENT_TO_WRKGROUP LIKE '%,#WRK#,%'
			</cfloop>
			<cfloop list="#WORKGROUPS#" index="WRK">
			  OR EVENT.EVENT_CC_WRKGROUP LIKE '%,#WRK#,%'
			</cfloop>
		</cfif>
		OR EVENT.VIEW_TO_ALL=1
		)
	ORDER BY
		STARTDATE DESC
</cfquery>
