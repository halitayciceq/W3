<cfif not isDefined("GET_SUBSCRIPTION_AUTHORITY")>
	<!--- include edildiği sayfada çekilmiş olabilir bu nedenle kontrol ekledik Author: Tolga Sütlü, Ahmet Yolcu--->
   <cfset gsa = createObject("component","V16.objects.cfc.subscriptionNauthority")/>
   <cfset GET_SUBSCRIPTION_AUTHORITY= gsa.SelectAuthority()/>
</cfif>
<cfquery name="GET_SUBSCRIPTION_TYPE" datasource="#DSN3#">
	SELECT
	ST.SUBSCRIPTION_TYPE_ID,
	ST.SUBSCRIPTION_TYPE
	FROM 
		SETUP_SUBSCRIPTION_TYPE ST
	<cfif get_subscription_authority.IS_SUBSCRIPTION_AUTHORITY eq 1>
		<!--- sadece yetkili olunan abone kategorileri gelsin --->
		WHERE EXISTS 
			(
				SELECT
				SPC.SUBSCRIPTION_TYPE_ID
				FROM        
				#dsn#.EMPLOYEE_POSITIONS AS EP,
				SUBSCRIPTION_GROUP_PERM SPC
				WHERE
				EP.POSITION_CODE = #session.ep.position_code# AND
				(
					SPC.POSITION_CODE = EP.POSITION_CODE OR
					SPC.POSITION_CAT = EP.POSITION_CAT_ID
				)
					AND ST.SUBSCRIPTION_TYPE_ID = SPC.SUBSCRIPTION_TYPE_ID
			)
	</cfif>
	ORDER BY
		SUBSCRIPTION_TYPE
</cfquery>


