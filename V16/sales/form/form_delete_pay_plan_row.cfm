<cfparam name="attributes.modal_id" default="0">
<cf_box title="#getLang('sales',568)#" popup_box="#iif(isdefined("attributes.draggable"),1,0)#">
	<cfform name="pay_plan" method="post" action="#request.self#?fuseaction=sales.emptypopup_del_subs_pay_plan_row">
		<input type="hidden" name="modal_id" id="modal_id" value="<cfoutput>#attributes.modal_id#</cfoutput>">
		<input type="hidden" name="xml_del_ref_rows" id="xml_del_ref_rows" value="<cfif isdefined("attributes.xml_del_ref_rows")><cfoutput>#attributes.xml_del_ref_rows#</cfoutput></cfif>">
		<input type="hidden" name="xml_del_camp_rows" id="xml_del_camp_rows" value="<cfif isdefined("attributes.xml_del_ref_rows")><cfoutput>#attributes.xml_del_camp_rows#</cfoutput></cfif>">
		<cf_box_elements>
			<cf_duxi name="start_date" type="text" data_control="date"    hint="Başlangıç Tarihi *" label="58053" value="#dateformat(now(),dateformat_style)#" required="yes" >
			<input type="hidden" name="subscription_id" id="subscription_id" value="<cfoutput>#attributes.subscription_id#</cfoutput>">
			<input type="hidden" name="del_all" id="del_all" value="1">
		</cf_box_elements>
		<cf_box_footer><cf_workcube_buttons is_upd='0'  add_function='control()'></cf_box_footer>
	</cfform>
</cf_box>
<script>
	function control(){
		if((document.getElementById("start_date").value == '') )
            {
                alert("<cf_get_lang dictionary_id='57471.Eksik Veri'> : <cf_get_lang dictionary_id='58053.Başlangıç Tarihi'>");
                return false;
            }

	}
</script>

