<!--- 
	Bu dosyadan orfer_p order_p purchase ve sales de de var orada da  degisiklik yapiniz.
	Arzu BT
 --->
<cfquery name="GET_PRODUCT_PROPERTY" datasource="#DSN1#">
	SELECT 
		* 
	FROM 
		PRODUCT_OPTIONS,
		PRODUCT_PROPERTY 
	WHERE 
		PRODUCT_PROPERTY.PROPERTY_ID = PRODUCT_OPTIONS.PROPERTY_ID AND 
		PRODUCT_ID = #attributes.PRODUCT_ID#
	ORDER BY
		PRODUCT_OPTIONS.PROPERTY_ID
</cfquery>
<cfif get_product_property.recordcount gte 2>
	<cfloop from="1" to="2" index="k">
		<cfquery name="get_property_detail#k#" datasource="#DSN1#">
			SELECT * FROM PRODUCT_PROPERTY_DETAIL 
			WHERE PRPT_ID = #get_product_property.PROPERTY_ID[k]#
			ORDER BY PRPT_ID,PROPERTY_DETAIL_ID
		</cfquery>
	</cfloop>
	<cfloop query="get_property_detail1">
		<cfset counter = get_property_detail1.PROPERTY_DETAIL_ID[currentrow]>
		<cfloop query="get_property_detail2">
				<cfset sub_counter = get_property_detail2.PROPERTY_DETAIL_ID[currentrow]>
				<cftry>
					<cfset my_elem=SESSION[var_][row_id][38][counter][sub_counter]>
					<cfcatch>
						<cfset my_elem=0>
					</cfcatch>
				</cftry>
				<cfif len(my_elem) and my_elem neq 0>
					<cfquery name="add_assortment" datasource="#DSN3#">
						INSERT INTO 
							PRODUCTION_ASSORTMENT	
								(
									ASSORTMENT_ID,
									PARSE1,
									PARSE2,
									PROPERTY_ID1,
									PROPERTY_ID2,									
									AMOUNT,
									ACTION_TYPE
								)
							VALUES
								(
									#attributes.ROW_MAIN_ID#,
									#counter#,
									#sub_counter#,
									1,1,
<!--- 									#evaluate("session.#var_#_assortment_property_id_1")#,
									#evaluate("session.#var_#_assortment_property_id_2")#,
 --->
 									#my_elem#,
									#ACTION_TYPE_ID#
								)
					</cfquery>
				</cfif>			
		</cfloop>
	</cfloop>
</cfif>
