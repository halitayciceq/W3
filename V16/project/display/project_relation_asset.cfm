<cfquery name="get_asset" datasource="#DSN#">
	SELECT
		*
	FROM
		ASSET,
		CONTENT_PROPERTY AS CP
	WHERE
		ASSET.ACTION_SECTION = 'PROJECT_ID'
		AND
		ASSET.ACTION_ID = #attributes.id#
		AND
		ASSET.PROPERTY_ID = CP.CONTENT_PROPERTY_ID
	ORDER BY 
		ASSET.ACTION_ID
</cfquery>
<cfif get_asset.recordcount>		
<table border="0" width="100%">
	<cfoutput query="get_asset">
	<tr>
		<td>
		<li><a href="javascript://" onClick="windowopen('#file_web_path#/project/#asset_file_name#','medium');" class="tableyazi">#ASSET_NAME# <font color="red">(#name#)</font></a></li> <br/>
		</td>                 		
	</tr>
	</cfoutput>
</table>
</cfif>
