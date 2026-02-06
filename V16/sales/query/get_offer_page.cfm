<!--- sayfa tanýmlý deðil ise ürün sayfasýný bul --->
<cfif not isdefined("attributes.page_id")>
	<cfquery name="CHECK_PRODUCT_PAGE" datasource="#dsn3#">
		SELECT
			PAGE_ID
		FROM
			OFFER_PAGES
		WHERE
			OFFER_ID = #attributes.OFFER_ID#
			AND
			PAGE_TYPE = 5
	</cfquery>
	<cfif CHECK_PRODUCT_PAGE.RECORDCOUNT>
		<cfset attributes.PAGE_ID = CHECK_PRODUCT_PAGE.PAGE_ID>
	<cfelse>
	<!--- sayfa oluþtur --->

		<CFLOCK NAME="#CREATEUUID()#" TIMEOUT="20">
			<CFTRANSACTION>
				<cfquery name="ADD_PRODUCT_PAGE" datasource="#dsn3#">
					INSERT INTO
						OFFER_PAGES
						(
						OFFER_ID,
						PAGE_NAME,
						PAGE_NO,
						PAGE_TYPE,
						RECORD_DATE,
						RECORD_EMP,
						OFFER_ZONE,
						RECORD_IP
						)
					VALUES
						(
						#OFFER_ID#,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="ÜRÜN VE HIZMET">,
						NULL,
						5,
						#now()#,
						#SESSION.EP.USERID#,
						0,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#CGI.REMOTE_ADDR#">
						)
				</cfquery>
				<cfquery name="GET_MAX_PAGE" datasource="#dsn3#">
					SELECT
						MAX(PAGE_ID) AS MAX_ID
					FROM
						OFFER_PAGES
					WHERE
						OFFER_ID = #attributes.OFFER_ID#
						AND
						PAGE_TYPE = 5
				</cfquery>
			</cftransaction>
		</cflock>
		<cfset attributes.PAGE_ID = get_max_page.max_id>
	</cfif>
</cfif>

<cfquery name="GET_OFFER_PAGE" datasource="#dsn3#">
	SELECT
		*
	FROM
		OFFER_PAGES
	WHERE
		PAGE_ID = #attributes.PAGE_ID#
</cfquery>
