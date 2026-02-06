<cfif not isdefined('SESSION.#var_#_kdvlist')>
	<cfset "SESSION.#var_#_kdvlist"="">
</cfif>
<cfif not isdefined('SESSION.#var_#_total')>
	<cfset "SESSION.#var_#_total"=0>
</cfif>
<cfif not isdefined('SESSION.#var_#_discount')>
	<cfset "SESSION.#var_#_discount"=0>
</cfif>
<cfif not isdefined('SESSION.#var_#_total_tax')>
	<cfset "SESSION.#var_#_total_tax"=0>
</cfif>
<cfif not isdefined('SESSION.#var_#_discount_new')>
	<cfset "SESSION.#var_#_discount_new"=0>
</cfif>
<cfif not isdefined('SESSION.#var_#_prom_list')>
	<cfset "SESSION.#var_#_prom_list" = "">
</cfif>
<cfif not isdefined('SESSION.#var_#_net_total')>
	<cfset "SESSION.#var_#_net_total"=0>
</cfif>
<cfif not isdefined('SESSION.#var_#_kdvpricelist')>
	<cfset "SESSION.#var_#_kdvpricelist"="">
</cfif>
<!--- <cfif not isdefined('SESSION.RATE1')>
	<cfset "SESSION.RATE1"=1>
</cfif>
<cfif not isdefined('SESSION.RATE2')>
	<cfset "SESSION.RATE2"=1>
</cfif>
 --->
<cfscript>
	if (not isdefined('SESSION.RATE2'))
		SESSION.RATE2=1;
	if (not isdefined('SESSION.RATE1'))
		SESSION.RATE1=1;		
</cfscript>
