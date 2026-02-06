<cffunction name="get_account_code">
	<cfargument name="id" >
	<cfargument name="period_id" >	
	<cfargument name="type_id" >
	<cfquery name="get_acc_code" datasource="#DSN3#">
			SELECT
				*
			FROM
				PROJECT_PERIOD
			WHERE
				PERIOD_ID=#period_id# AND
				PROJECT_ID=#ID#
	</cfquery>
	<cfif get_acc_code.recordcount>
		<cfswitch expression="#type_id#">
			<cfcase value="1"><cfreturn #get_acc_code.ACCOUNT_CODE#></cfcase>
			<cfcase value="2"><cfreturn #get_acc_code.ACCOUNT_CODE_PUR#></cfcase>
			<cfcase value="3"><cfreturn #get_acc_code.ACCOUNT_DISCOUNT#></cfcase>
			<cfcase value="4"><cfreturn #get_acc_code.ACCOUNT_PRICE#></cfcase>
			<cfcase value="5"><cfreturn #get_acc_code.ACCOUNT_PUR_IADE#></cfcase>
			<cfcase value="6"><cfreturn #get_acc_code.ACCOUNT_IADE#></cfcase>
			<cfcase value="7"><cfreturn #get_acc_code.ACCOUNT_YURTDISI#></cfcase>
			<cfcase value="8"><cfreturn #get_acc_code.ACCOUNT_DISCOUNT_PUR#></cfcase>
			<cfcase value="9"><cfreturn #get_acc_code.ACCOUNT_YURTDISI_PUR#></cfcase>
			<cfcase value="10"><cfreturn #get_acc_code.ACCOUNT_LOSS#></cfcase>
			<cfcase value="11"><cfreturn #get_acc_code.ACCOUNT_EXPENDITURE#></cfcase>
			<cfcase value="12"><cfreturn #get_acc_code.OVER_COUNT#></cfcase>
			<cfcase value="13"><cfreturn #get_acc_code.UNDER_COUNT#></cfcase>
			<cfcase value="14"><cfreturn #get_acc_code.PRODUCTION_COST#></cfcase>
			<cfcase value="15"><cfreturn #get_acc_code.HALF_PRODUCTION_COST#></cfcase>
			<cfcase value="16"><cfreturn #get_acc_code.SALE_PRODUCT_COST#></cfcase>
			<cfcase value="17"><cfreturn #get_acc_code.MATERIAL_CODE#></cfcase>
			<cfcase value="18"><cfreturn #get_acc_code.KONSINYE_PUR_CODE#></cfcase>
			<cfcase value="19"><cfreturn #get_acc_code.KONSINYE_SALE_CODE#></cfcase>
			<cfcase value="20"><cfreturn #get_acc_code.KONSINYE_SALE_NAZ_CODE#></cfcase>
			<cfcase value="21"><cfreturn #get_acc_code.DIMM_CODE#></cfcase>
			<cfcase value="22"><cfreturn #get_acc_code.DIMM_YANS_CODE#></cfcase>
			<cfcase value="23"><cfreturn #get_acc_code.PROMOTION_CODE#></cfcase>
			<cfcase value="24"><cfreturn #get_acc_code.ACCOUNT_PRICE_PUR#></cfcase>
            <cfcase value="25"><cfreturn #get_acc_code.RECEIVED_PROGRESS_CODE#></cfcase>
            <cfcase value="26"><cfreturn #get_acc_code.PROVIDED_PROGRESS_CODE#></cfcase>
            <cfcase value="27"><cfreturn #get_acc_code.INCOME_PROGRESS_CODE#></cfcase>
            <cfcase value="28"><cfreturn #get_acc_code.EXPENSE_PROGRESS_CODE#></cfcase>
			<cfcase value="29"><cfreturn #get_acc_code.SALE_MANUFACTURED_COST#></cfcase>
			<cfcase value="30"><cfreturn #get_acc_code.INVENTORY_CAT_ID#></cfcase>
			<cfcase value="31"><cfreturn #get_acc_code.INVENTORY_CODE#></cfcase>
			<cfcase value="32"><cfreturn #get_acc_code.AMORTIZATION_METHOD_ID#></cfcase>
			<cfcase value="33"><cfreturn #get_acc_code.AMORTIZATION_TYPE_ID#></cfcase>
			<cfcase value="34"><cfreturn #get_acc_code.AMORTIZATION_EXP_CENTER_ID#></cfcase>
			<cfcase value="35"><cfreturn #get_acc_code.AMORTIZATION_EXP_ITEM_ID#></cfcase>
			<cfcase value="36"><cfreturn #get_acc_code.AMORTIZATION_CODE#></cfcase>
			<cfcase value="37"><cfreturn #get_acc_code.SCRAP_CODE#></cfcase>
			<cfcase value="38"><cfreturn #get_acc_code.MATERIAL_CODE_SALE#></cfcase>
			<cfcase value="39"><cfreturn #get_acc_code.PRODUCTION_COST_SALE#></cfcase>
			<cfcase value="40"><cfreturn #get_acc_code.SCRAP_CODE_SALE#></cfcase>
			<cfcase value="41"><cfreturn #get_acc_code.EXE_VAT_SALE_INVOICE#></cfcase>
		</cfswitch>
	<cfelse>	
		<cfreturn "">	
	</cfif>
</cffunction>
