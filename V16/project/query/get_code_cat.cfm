<cfquery name="get_code_cat" datasource="#dsn3#">
	SELECT
		*
	FROM
		SETUP_PRODUCT_PERIOD_CAT
	<cfif isdefined('attributes.active_cat')>
	WHERE
		IS_ACTIVE = 1
	</cfif>
	ORDER BY
		PRO_CODE_CAT_NAME
</cfquery>

