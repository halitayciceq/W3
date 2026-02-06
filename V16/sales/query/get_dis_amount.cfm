<!--- 	LOOP index degiskeninin ismi "i"  olmali yoksa burasi calismaz!!!! abt  --->
<cfif isdefined('attributes.row_ship_id#i#')>
	<cfset order_id = evaluate('attributes.row_ship_id#i#')>
<cfelse>
	<cfset order_id = 0>
</cfif><!--- irs coklu siparis cekme. row_ship_id degiskeninde irsaliyeye siparis cekerken order_id'ler tutuluyor--->
<cfif isdefined('attributes.indirim1#i#') and len(evaluate("attributes.indirim1#i#")) ><cfset indirim1 = evaluate('attributes.indirim1#i#')><cfelse><cfset indirim1 = 0></cfif>
<cfif isdefined('attributes.indirim2#i#') and len(evaluate("attributes.indirim2#i#")) ><cfset indirim2 = evaluate('attributes.indirim2#i#')><cfelse><cfset indirim2 = 0></cfif>
<cfif isdefined('attributes.indirim3#i#') and len(evaluate("attributes.indirim3#i#")) ><cfset indirim3 = evaluate('attributes.indirim3#i#')><cfelse><cfset indirim3 = 0></cfif>
<cfif isdefined('attributes.indirim4#i#') and len(evaluate("attributes.indirim4#i#")) ><cfset indirim4 = evaluate('attributes.indirim4#i#')><cfelse><cfset indirim4 = 0></cfif>
<cfif isdefined('attributes.indirim5#i#') and len(evaluate("attributes.indirim5#i#")) ><cfset indirim5 = evaluate('attributes.indirim5#i#')><cfelse><cfset indirim5 = 0></cfif>
<cfif isdefined('attributes.indirim6#i#') and len(evaluate("attributes.indirim6#i#")) ><cfset indirim6 = evaluate('attributes.indirim6#i#')><cfelse><cfset indirim6 = 0></cfif>
<cfif isdefined('attributes.indirim7#i#') and len(evaluate("attributes.indirim7#i#")) ><cfset indirim7 = evaluate('attributes.indirim7#i#')><cfelse><cfset indirim7 = 0></cfif>
<cfif isdefined('attributes.indirim8#i#') and len(evaluate("attributes.indirim8#i#")) ><cfset indirim8 = evaluate('attributes.indirim8#i#')><cfelse><cfset indirim8 = 0></cfif>
<cfif isdefined('attributes.indirim9#i#') and len(evaluate("attributes.indirim9#i#")) ><cfset indirim9 = evaluate('attributes.indirim9#i#')><cfelse><cfset indirim9 = 0></cfif>
<cfif isdefined('attributes.indirim10#i#') and len(evaluate("attributes.indirim10#i#")) ><cfset indirim10 = evaluate('attributes.indirim10#i#')><cfelse><cfset indirim10 = 0></cfif>
<cfset indirim_carpan = 100000000000000000000 - ((100-indirim1) * (100-indirim2) * (100-indirim3) * (100-indirim4) * (100-indirim5)*(100-indirim6) * (100-indirim7) * (100-indirim8) * (100-indirim9) * (100-indirim10)) >
<!--- <cfif isdefined('attributes.row_total#i#') and len(evaluate("attributes.row_total#i#"))>
	<cfset discount_amount = (evaluate("attributes.row_total#i#") * indirim_carpan) / 100000000000000000000>
<cfelse>
	<cfset discount_amount = 0>
</cfif>
 --->
<cfif isdefined('attributes.row_total#i#') and len(evaluate("attributes.row_total#i#"))>
	<cfset discount_amount = evaluate("attributes.row_total#i#")-evaluate("attributes.row_nettotal#i#") >
<cfelse>
	<cfset discount_amount = 0 >
</cfif>
