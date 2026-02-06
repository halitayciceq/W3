<cftransaction>
	<cfif isdefined("attributes.opp_id")>
		<cfif listlen(attributes.opp_id) gt 1><cfset attributes.opp_id = listfirst(attributes.opp_id)></cfif>
        <cfquery name="get_related_offer" datasource="#dsn3#">
        	SELECT OFFER_ID FROM OFFER WHERE OPP_ID=#opp_id#
        </cfquery>
     	<cfif get_related_offer.recordcount>
			<cfoutput query="get_related_offer">
                <cfquery name="del_offer_related" datasource="#dsn3#">
                    DELETE FROM OFFER_RIVALS WHERE OFFER_ID = #offer_id#
                </cfquery>
			</cfoutput>
		</cfif>
        <cfquery name="del_opp_rival" datasource="#dsn3#">
            DELETE FROM OPPORTUNITY_RIVALS WHERE OPP_ID = #attributes.opp_id#
        </cfquery>
    <cfelse>
    	<cfif listlen(attributes.offer_id) gt 1><cfset attributes.offer_id = listfirst(attributes.offer_id)></cfif>
        <cfquery name="del_off_rival" datasource="#dsn3#">
            DELETE FROM OFFER_RIVALS WHERE OFFER_ID = #attributes.offer_id#
        </cfquery>
    </cfif>
 	<cfif isdefined("attributes.offer_id")>
        <cfset list_offer_id=attributes.offer_id>
    <cfelseif isdefined("get_related_offer") and get_related_offer.recordcount>
        <cfset list_offer_id=valuelist(get_related_offer.offer_id,',')>
    </cfif>
 	<cfloop from="1" to="#attributes.record_num_rival#" index="i">
		<cfif evaluate("attributes.row_kontrol_#i#")>
			<cfset form_company_id = evaluate("attributes.rival_id#i#")>
			<cfset form_reason_id = evaluate("attributes.rival_preference_reason#i#")>
			<cfset form_rival_price = evaluate("attributes.rival_price#i#")>
			<cfset form_money = evaluate("attributes.money#i#")>
            <cfset form_rival_cause=evaluate("attributes.rival_cause#i#")>
            	<cfif isdefined("attributes.opp_id")>
                	<cfquery name="add_opp_rival" datasource="#dsn3#">
                        INSERT INTO
                            OPPORTUNITY_RIVALS
                            (
                                OPP_ID,
                                COMPANY_ID,
                                PREFERENCE_REASON_ID,
                                RIVAL_PRICE,
                                RIVAL_CAUSE,
                                MONEY_TYPE				
                            )
                            VALUES
                            (
                                #attributes.opp_id#,
                                #form_company_id#,
                                <cfif len(form_reason_id)>#form_reason_id#<cfelse>NULL</cfif>,
                                <cfif len(form_rival_price)>#form_rival_price#<cfelse>0</cfif>,
                                <cfif len(form_rival_cause)>'#form_rival_cause#'<cfelse>NULL</cfif>, 
                                '#form_money#'
                            )
                     </cfquery>
                 </cfif>
                <cfif isdefined("attributes.offer_id") or (isdefined("get_related_offer") and get_related_offer.recordcount)>
       				<cfloop from="1" to="#listlen(list_offer_id)#" index="x">
                        <cfquery name="add_opp_rival" datasource="#dsn3#">
                            INSERT INTO
                                OFFER_RIVALS
                                (
                                    OFFER_ID,
                                    COMPANY_ID,
                                    PREFERENCE_REASON_ID,
                                    RIVAL_PRICE,
                                    RIVAL_CAUSE,
                                    MONEY_TYPE				
                                )
                                VALUES
                                (
                                    #listgetat(list_offer_id,x,',')#,
                                    #form_company_id#,
                                    <cfif len(form_reason_id)>#form_reason_id#<cfelse>NULL</cfif>,
                                    <cfif len(form_rival_price)>#form_rival_price#<cfelse>0</cfif>,
                                    <cfif len(form_rival_cause)>'#form_rival_cause#'<cfelse>NULL</cfif>, 
                                    '#form_money#'
                                )
                        </cfquery>
                     </cfloop>
               </cfif>
        </cfif>
	</cfloop>
</cftransaction>
