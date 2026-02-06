<cfquery name="ADD_OFFER_PAGE" datasource="#DSN3#">
	INSERT INTO
		OFFER_PAGES
		(
		OFFER_ID,
		PAGE_NAME,
		PAGE_NO,
		PAGE_TYPE,
		PAGE_CONTENT,
		RECORD_DATE,
		RECORD_EMP,
		OFFER_ZONE,
		RECORD_IP
		)
	VALUES
		(
		<cfif len(attributes.OFFER_ID)>#attributes.OFFER_ID#<cfelse>NULL</cfif>,
		<cfif len(attributes.PAGE_NAME)>'#attributes.PAGE_NAME#'<cfelse>NULL</cfif>,
		<cfif len(attributes.PAGE_NO)>#attributes.PAGE_NO#<cfelse>NULL</cfif>,
		<cfif len(attributes.page_type)>#attributes.page_type#<cfelse>NULL</cfif>,
		<cfif len(attributes.PAGE_CONTENT)>'#attributes.PAGE_CONTENT#'<cfelse>NULL</cfif>,
		#now()#,
		#SESSION.EP.USERID#,
		0,
		'#CGI.REMOTE_ADDR#'
		)
</cfquery>
<script>
	<cfif not isdefined("attributes.draggable")>
		location.href= document.referrer;
	<cfelse>
		closeBoxDraggable( '<cfoutput>#attributes.modal_id#</cfoutput>' );
		location.reload();
	</cfif>
</script>

