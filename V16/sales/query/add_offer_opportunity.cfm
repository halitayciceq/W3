<cfquery name="UPD_OFFER" datasource="#DSN3#">
	UPDATE
		OFFER
	SET
	<cfif  isdefined("attributes.purchase_") and len(attributes.purchase_) and isdefined("attributes.draggable")>
		OPPORTUNITY_ID  = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.opp_id#">
	<cfelse>
		OPP_ID  = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.opp_id#">
	</cfif>
	WHERE
		OFFER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.offer_id#">
</cfquery>
<cfquery name="select_opp_off" datasource="#DSN3#">
	select WRK_ROW_ID,WRK_ROW_RELATION_ID,QUANTITY from OFFER O, OFFER_ROW OP WHERE O.OFFER_ID = OP.OFFER_ID AND OP.OFFER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.offer_id#"> GROUP BY WRK_ROW_ID,WRK_ROW_RELATION_ID,QUANTITY
</cfquery>
<cfscript>
                    add_relation_rows(
                        action_type:'add',
                        action_dsn : '#dsn3#',
                        to_table:'OPPORTUNITIES',
                        to_action_id : attributes.opp_id,
						to_wrk_row_id : select_opp_off.wrk_row_id,
						from_table : 'OFFER',
						from_action_id : attributes.offer_id,
						from_wrk_row_id : select_opp_off.wrk_row_relation_id,
						amount : select_opp_off.quantity

                        );
                </cfscript>			
<script type="text/javascript">

	<cfif  isdefined("attributes.purchase_") and len(attributes.purchase_) and isdefined("attributes.draggable")>
		
		closeBoxDraggable( '<cfoutput>#attributes.modal_id#</cfoutput>', 'unique_opportunity_purchase' );
	<cfelseif isdefined("attributes.draggable")>
		closeBoxDraggable( '<cfoutput>#attributes.modal_id#</cfoutput>', 'unique_opportunity_b' );
	<cfelse>
		window.close();
		wrk_opener_reload();
	</cfif>
	
</script>
