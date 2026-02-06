<cfquery name="get_card_paymethod" datasource="#dsn3#">
	SELECT
		*
	FROM
		CREDITCARD_PAYMENT_TYPE
	WHERE
		<cfif isdefined("card_pay_id") and len(card_pay_id)>
			PAYMENT_TYPE_ID = #card_pay_id#
		<cfelse>
			IS_ACTIVE = 1
		</cfif>
</cfquery>
