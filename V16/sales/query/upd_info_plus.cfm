<cfscript>
	STR_VALUE="";
	for (i=1; i lte 20; i=i+1)
		if (isDefined("attributes.PROPERTY#i#") )
			STR_VALUE = STR_VALUE & "PROPERTY#i#='" & evaluate("attributes.PROPERTY#i#")& "', ";
</cfscript>

<cfif len(STR_VALUE)>
	<cfif attributes.type_id eq -7>
		<cfquery name="UPD_INFO" datasource="#DSN3#">
			UPDATE
				ORDER_INFO_PLUS
			SET	
				#PreserveSingleQuotes(STR_VALUE)#
				ORDER_ID=#attributes.ORDER_ID#
			WHERE
				ORDER_ID=#attributes.ORDER_ID#
		</cfquery>
	<cfelseif attributes.type_id eq -9>
		<cfquery name="UPD_INFO" datasource="#DSN3#">
			UPDATE
				OFFER_INFO_PLUS
			SET	
				#PreserveSingleQuotes(STR_VALUE)#
				OFFER_ID=#attributes.OFFER_ID#
			WHERE
				OFFER_ID=#attributes.OFFER_ID#
		</cfquery>
	</cfif>
</cfif>

<script type="text/javascript">
	wrk_opener_reload();
	window.close();
</script>
