<h1><cfoutput><cf_get_lang dictionary_id='57416.Proje'><cf_get_lang dictionary_id='57487.NO'>: #project_detail.project_number#</cfoutput></h1>
<cfif project_detail.project_status neq 1>
	<font color="#FF0000">(<cf_get_lang dictionary_id='38233.Gündemde Değil'>)</font>
</cfif>
