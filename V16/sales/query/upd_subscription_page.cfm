<cfquery name="upd_subscription_page" datasource="#dsn3#">
	UPDATE
		SUBSCRIPTION_PAGES
	SET
		PAGE_NAME = '#PAGE_NAME#',
		PAGE_NO = #PAGE_NO#,
		PAGE_TYPE = #attributes.page_type#,
		PAGE_CONTENT = '#PAGE_CONTENT#',
		UPDATE_DATE = #now()#,
		UPDATE_EMP = #SESSION.EP.USERID#,
		UPDATE_IP = '#CGI.REMOTE_ADDR#'
	WHERE
		PAGE_ID = #PAGE_ID#
</cfquery>

<script type="text/javascript">
	<cfif not isdefined("attributes.draggable")><cflocation url="#request.self#?fuseaction=sales.popup_add_subscription_page&subs_id=#attributes.subs_id#" addtoken="No"><cfelse>closeBoxDraggable( '<cfoutput>#attributes.modal_id#</cfoutput>');</cfif>
 </script>