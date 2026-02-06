<cfif session.nettotal_ lte 123122>

<cfset gidenyer=#ListGetAt(ListGetAt(process1,1,','),3,'-')#>

<cfelse>

<cfset gidenyer=#ListGetAt(ListGetAt(process1,1,','),4,'-')#>

</cfif>
