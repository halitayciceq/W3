<cfset price_limit = 100>
<cfset validation_status = 0>
<cfset partial_validation = 0>
<!---
0 : kontrol yok direk gönder
1 : onaya düşür
--->

<cfif isdefined("form.var_")>
	<cfset attributes.price = evaluate("session.#var_#_total")>
</cfif>

<cfif (attributes.price lt price_limit) or (validation_status eq 0)>
<!--- fiyat limit den küçük mü ? --->
	
	<cfset p_flag = 1>
	<cfset less_product_ids = "">
	<!--- sepetdeki her ürün için stokda var mı kontrolü --->
	<cfloop from="1" to="#ArrayLen(session[var_])#" index="i">
		<cfset attributes.product_id = session[var_][i][1]>
		<cfinclude template="get_product_count.cfm">
		<cfif get_product_count.PRODUCT_TOTAL_STOCK  lt session[var_][i][4]>
			<cfset p_flag = 0>
			<cfset less_product_ids = listappend(less_product_ids,attributes.product_id)>
		</cfif>
	</cfloop>
	
	<cfif p_flag>
	<!--- istenen üründen varsa --->
		<cfinclude template="get_credit_limit.cfm">
		<cfif get_credit_limit.TOTAL_RISK_LIMIT GTE attributes.price>
		<!--- müşteri kredisi uygun mu ? --->
			<cfset process_status = 6>
		<cfelse>
			
			<cfif partial_validation>
			<!--- kısmen sevk onay mekanizması aktif mi ? --->
				
				<cfset process_status = 1>
					
			<cfelse>
				
				<cfset process_status = 6>
				
			</cfif>
			
		</cfif>

	<cfelse>
		
		<!--- ürün bilgisi al (tedarik / üretim) --->
		<!--- tüm ürünleri loop et --->
		<cfset product_type = 0>
		<cfloop list="#less_product_ids#" index="i">
			<cfset attributes.product_id = i>
			<cfinclude template="get_product_info.cfm">
			<cfif get_product_info.IS_PRODUCTION>
				<cfif product_type>
					<cfset product_type = 2>
				<cfelse>
					<cfset product_type = 1>
				</cfif>
			</cfif>
		
		</cfloop>

		<cfif product_type eq 0>
			<cfset process_status = 5>
		<cfelseif product_type eq 1>
			<cfset process_status = 4>
		<cfelseif product_type eq 2>
			<cfset process_status = 3>
		</cfif>
		
	</cfif>
	
<cfelseif validation_status eq 1>
<!--- onay yönetim mekanizması aktif mi ? --->
	
	<cfset process_status = 1>

</cfif>

<!--- 
process_status : 
	1 = onay bekle
	2 = acik
	3 = karışık {şimdilik tedarik olarak alınır}
	4 = üretim  {şimdilik tedarik olarak alınır}
	5 = tedarik
	6 = sevk
	7 = red
	8 = krediden yüksek istek
--->
