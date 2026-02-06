<cfquery name="add_subscription_page" datasource="#dsn3#">
	INSERT INTO
		SUBSCRIPTION_PAGES
		(
			SUBSCRIPTION_ID,
			PAGE_NAME,
			PAGE_NO,
			PAGE_TYPE,
			PAGE_CONTENT,
			RECORD_DATE,
			RECORD_EMP,
			RECORD_IP,
			SUBSCRIPTION_ZONE
		)
	VALUES
		(
			#attributes.SUBSCRIPTION_ID#,
			'#attributes.PAGE_NAME#',
			#attributes.PAGE_NO#,
			#attributes.PAGE_TYPE#,
			'#attributes.PAGE_CONTENT#',
			#now()#,
			#SESSION.EP.USERID#,
			'#CGI.REMOTE_ADDR#',
			0
		)
</cfquery>
<script type="text/javascript">
   <cfif not isdefined("attributes.draggable")><cflocation url="#request.self#?fuseaction=sales.popup_add_subscription_page&subs_id=#attributes.subscription_id#" addtoken="No"><cfelse>closeBoxDraggable( '<cfoutput>#attributes.modal_id#</cfoutput>');</cfif>
</script>

