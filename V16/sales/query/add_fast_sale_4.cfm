<cfif len(attributes.consumer_id)>
	<!--- Yeni eklenen kefiller kaydediliyor --->
	<cfloop from="1" to="#attributes.record_num_2_q#" index="ii">
		<cfscript>
			'attributes.last_use_risk#ii#' = filterNum(evaluate('attributes.last_use_risk#ii#'));
		</cfscript>
	</cfloop>
	<!--- Kefillerle senetlerin ilişkisi kaydediliyor --->
	<cfoutput query="get_last_vouchers">
		<cfloop from="1" to="#attributes.record_num_2_q#" index="ii">
			<cfif isdefined("attributes.row_kontrol_2_q#ii#") and evaluate("attributes.row_kontrol_2_q#ii#") eq 1 and evaluate("attributes.q_consumer_id#ii#") neq ''>
				<cfquery name="add_cons_voucher" datasource="#dsn2#">
					INSERT INTO 
						VOUCHER_GUARANTORS
						(
							VOUCHER_ID,
							CONSUMER_ID,
							AMOUNT,
							AMOUNT2
						)
						VALUES
						(
							#voucher_id#,
							#evaluate("attributes.q_consumer_id#ii#")#,
							#wrk_round(evaluate("attributes.last_use_risk#ii#")/get_last_vouchers.recordcount)#,
							#wrk_round((evaluate("attributes.last_use_risk#ii#")/get_last_vouchers.recordcount)/attributes.currency_multiplier)#
						)
				</cfquery>
			</cfif>
		</cfloop>
	</cfoutput>
</cfif>
