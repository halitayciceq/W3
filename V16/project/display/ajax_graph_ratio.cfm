<cfsetting showdebugoutput="no">
<cfquery name="upd_work_complate" datasource="#dsn#">
	UPDATE 
		PRO_WORKS
	SET
		TO_COMPLETE = <cfif len(deger)>#deger#<cfelse>NULL</cfif>
	WHERE
		PRO_WORKS.WORK_ID = #attributes.WORK_ID#
</cfquery>
<cfquery name="last_complete" datasource="#dsn#">
	SELECT TO_COMPLETE FROM PRO_WORKS WHERE WORK_ID = #attributes.WORK_ID#
</cfquery>
<cfoutput>
<!--- 				<table width="100" border="0" cellpadding="0" cellspacing="0" id="table#work_id#" name="table#work_id#">
					<tr height="20">
					<cfif isdefined('last_complete.to_complete') and len(last_complete.to_complete)>
						<td bgcolor="66CC33" width="#last_complete.to_complete#">
							<div style="position:absolute;z-index:9998;width:50px;height:18px;">
								<table cellpadding="0" cellspacing="0" width="100"><tr><td><cfif last_complete.to_complete gt 0>%#last_complete.to_complete#</cfif></td><td align="right"><cfif (100-last_complete.to_complete) gt 0>%#evaluate(100-last_complete.to_complete)#</cfif></td></tr></table>
							</div>
						</td>
						<td bgcolor="3399FF" width="#evaluate(100-last_complete.to_complete)#" align="right">&nbsp;</td>
					</cfif>
					</tr>
			   </table>
 --->
	<table width="100" border="0" cellpadding="0" cellspacing="0">
	<cfif isdefined('last_complete.to_complete')>
		<cfif last_complete.to_complete gt 0 and last_complete.to_complete lt 100>
			<td bgcolor="66CC33" width="#last_complete.to_complete#" height="15" class="label">% #last_complete.to_complete#</td>
			<td bgcolor="3399FF" width="#evaluate(100-last_complete.to_complete)#" class="label">%#evaluate(100-last_complete.to_complete)#</td>
		<cfelseif last_complete.to_complete gte 100>
			<td bgcolor="66CC33" width="100" height="15" class="label">%100</td>
		<cfelseif last_complete.to_complete lte 0>
			<td bgcolor="3399FF" width="100" height="15" class="label">%100</td>
		</cfif>
	</cfif>
	</table>
</cfoutput>

