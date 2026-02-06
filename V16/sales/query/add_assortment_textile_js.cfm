<cfif not isdefined("dsn_type_")><cfset dsn_type_ = dsn3></cfif>
<cfif isdefined("form.ASSORTMENT_#row_id#_COUNT")>
	<cfloop from="1" to="#evaluate("form.ASSORTMENT_#row_id#_COUNT")-1#" index="row_counter">
		<cfquery name="add_assortment" datasource="#dsn_type_#">
			INSERT INTO 
				#dsn3_alias#.PRODUCTION_ASSORTMENT	
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
						#evaluate("form.ASSORTMENT_#row_id#_#row_counter#_1")#,
						#evaluate("form.ASSORTMENT_#row_id#_#row_counter#_2")#,
						1,
						1,
						#evaluate("form.ASSORTMENT_#row_id#_#row_counter#_3")#,
						#ACTION_TYPE_ID#
					)
		</cfquery>
	</cfloop>
</cfif>
