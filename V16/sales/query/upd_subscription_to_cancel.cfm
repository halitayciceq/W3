<cf_date tarih="attributes.cancel_date">
<cflock name="#CREATEUUID()#" timeout="60">
	<cftransaction>
	<cfquery name="GET_CONTROL" datasource="#DSN3#">
		SELECT
			CANCEL_RECORD_EMP
		FROM
			SUBSCRIPTION_CONTRACT
		WHERE
			SUBSCRIPTION_ID = #attributes.subscription_id#	
	</cfquery>
		<cfquery name="UPD_SUBSCRIPTION_TO_CANCEL" datasource="#DSN3#">
			UPDATE 
				SUBSCRIPTION_CONTRACT		
			SET
				CANCEL_TYPE_ID = #attributes.cancel_type#,
				CANCEL_DATE = #attributes.cancel_date#,
				CANCEL_DETAIL =	'#attributes.cancel_detail#',
				FINISH_DATE = #attributes.cancel_date#,
			  <cfif len(get_control.cancel_record_emp)>
  				CANCEL_UPDATE_DATE = #now()#,
				CANCEL_UPDATE_IP = '#cgi.remote_addr#',
				CANCEL_UPDATE_EMP = #session.ep.userid#	
			 <cfelse> 
				CANCEL_RECORD_DATE = #now()#,
				CANCEL_RECORD_IP = '#cgi.remote_addr#',
				CANCEL_RECORD_EMP = #session.ep.userid#	
			  </cfif>
			WHERE
				SUBSCRIPTION_ID = #attributes.subscription_id#
		</cfquery>
	</cftransaction>
</cflock>
<cfset attributes.del_all = 1>
<cfset attributes.start_date = attributes.cancel_date>
<cfset cancel_subs_info = 1><!--- ödeme planı silme sayfasndaki kontroller için--->
<cfinclude template="del_subs_pay_plan_row.cfm"><!--- işlem görmemiş(faturalanmamış, ödenmemiş vs) ilişkili ödeme planı satırları da temizleniyor --->
<script type="text/javascript">
	<cfif not isdefined("attributes.draggable")>
		wrk_opener_reload();
		window.close();
	<cfelse>
		closeBoxDraggable( '<cfoutput>#attributes.modal_id#</cfoutput>' );
		location.reload();
	</cfif>
</script>
