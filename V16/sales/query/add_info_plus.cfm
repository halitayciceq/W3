<cfscript>
STR_COLUMN="";
STR_VALUE="";

for (i=1; i lte 20; i=i+1)
	if (isDefined("attributes.PROPERTY#i#"))
		{
			STR_COLUMN = STR_COLUMN & " PROPERTY#i#,";
			STR_VALUE = STR_VALUE & "'"& evaluate("attributes.PROPERTY#i#")& "',";
		}
</cfscript>

<cfif len(STR_VALUE)>
	<cfif attributes.type_id eq -7>
		<cfquery name="ADD_INFO" datasource="#DSN3#">
			INSERT INTO 
				ORDER_INFO_PLUS
				(
					#PreserveSingleQuotes(STR_COLUMN)#
					ORDER_ID
				)
					VALUES
				(
					#PreserveSingleQuotes(STR_VALUE)#	
					#attributes.ORDER_ID#
				)
		</cfquery>
	<cfelseif attributes.type_id eq -9>
		<cfquery name="ADD_INFO" datasource="#DSN3#">
			INSERT INTO 
				OFFER_INFO_PLUS
				(
					#PreserveSingleQuotes(STR_COLUMN)#
					OFFER_ID
				)
					VALUES
				(
					#PreserveSingleQuotes(STR_VALUE)#	
					#attributes.OFFER_ID#
				)
		</cfquery>
	</cfif>
</cfif>
<script type="text/javascript">
	wrk_opener_reload();
	window.close();
</script>
