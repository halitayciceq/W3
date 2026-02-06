<cfform name="form_git_basvuru" method="post" action="#request.self#?fuseaction=#listgetat(attributes.fuseaction,1,'.')#.emptypopup_git_basvuru">
	<cfsavecontent variable="message">Başvuru Nosu Eksik!</cfsavecontent>
	<cfinput type="text" name="basvuru_no" required="yes" message="#message#">
	<cf_wrk_search_button>
</cfform>
