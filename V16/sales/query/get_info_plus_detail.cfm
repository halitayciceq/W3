<cfif attributes.type_id eq -7>
	<cfset tablo_adi = "ORDER_INFO_PLUS">
<cfelse>
	<cfset tablo_adi = "OFFER_INFO_PLUS">
</cfif>
<cfquery name="GET_VALUES" datasource="#DSN3#">
	SELECT
		*
	FROM
		#tablo_adi#
	WHERE
		<cfif attributes.type_id eq -7>
			ORDER_ID = #attributes.order_id#
		<cfelse>
			OFFER_ID = #attributes.offer_id#
		</cfif>
</cfquery>
<cfquery name="GET_LABELS" datasource="#DSN3#">
	SELECT
		*
	FROM
		SETUP_PRO_INFO_PLUS_NAMES
	WHERE	
		OWNER_TYPE_ID = #attributes.type_id#
</cfquery>
