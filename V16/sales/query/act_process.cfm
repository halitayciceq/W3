<cfset price_limit = null>
<cfset validation_status = 0>
<cfset partial_validation = 0>
<cfif isdefined('form.var_')>
<cfset attributes.price = evaluate('session.#var_#_total')>
</cfif>

