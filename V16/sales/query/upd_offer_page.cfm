<cfquery name="UPD_OFFER_PAGE" datasource="#dsn3#">
	UPDATE
		OFFER_PAGES
	SET
		PAGE_NAME = <cfif len(PAGE_NAME)><cfqueryparam cfsqltype="cf_sql_varchar" value="#PAGE_NAME#"><cfelse>NULL</cfif>,
		PAGE_NO = <cfif len(PAGE_NO)><cfqueryparam cfsqltype="cf_sql_integer" value="#PAGE_NO#"><cfelse>NULL</cfif>,
		PAGE_TYPE = <cfif len(attributes.page_type)><cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.page_type#"><cfelse>NULL</cfif>,
		PAGE_CONTENT = <cfif len(PAGE_CONTENT)><cfqueryparam cfsqltype="cf_sql_varchar" value="#PAGE_CONTENT#"><cfelse>NULL</cfif>,
		UPDATE_DATE = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
		UPDATE_EMP = <cfqueryparam cfsqltype="cf_sql_integer" value="#SESSION.EP.USERID#">,
		UPDATE_IP = <cfqueryparam cfsqltype="cf_sql_varchar" value="#CGI.REMOTE_ADDR#">
	WHERE
		PAGE_ID = #PAGE_ID#
</cfquery>

<script>
	<cfif not isdefined("attributes.draggable")><cflocation url="#request.self#?fuseaction=sales.popup_form_add_page&offer_id=#attributes.offer_id#" addtoken="No">
	<cfelse>
		closeBoxDraggable( '<cfoutput>#attributes.modal_id#</cfoutput>' );
		location.reload();
	</cfif>
</script>
