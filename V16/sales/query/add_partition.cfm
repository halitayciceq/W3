<cflock name="#CreateUUID()#" timeout="60">
  <cftransaction>
	<cfif attributes.record_num gt 0>
	  <cfloop from="1" to="#attributes.record_num#" index="i">
		<cfif evaluate("attributes.row_kontrol#i#")>
			<cfset form_partition_id = evaluate("attributes.partition_id#i#")>
			<cfset form_partition_number = "A-" & "#evaluate("attributes.partition_number#i#")#">
			<cfset form_partition_start_date = evaluate("attributes.partition_start_date#i#")>
			<cfset form_partition_detail = evaluate("attributes.partition_detail#i#")>
			<cf_date tarih="form_partition_start_date">
			<cfquery name="GET_NO" datasource="#dsn3#">
				SELECT
					PARTITION_NUMBER
				FROM
					SUBSCRIPTION_CONTRACT_PARTITION
				WHERE
					PARTITION_NUMBER = '#form_partition_number#'
					<cfif len(form_partition_id)>
						AND PARTITION_ID <> #form_partition_id#
					</cfif>
			</cfquery>
			<cfif GET_NO.recordcount>
				<script type="text/javascript">
					alert('<cfoutput>#i#</cfoutput>' + "<cf_get_lang no ='546.Satırda Girdiğiniz Partion Numarası Kullanılıyor'> !");
					history.back();
				</script>
				<cfabort>
			</cfif>
			<cfif not len(form_partition_id)><!--- Bu satir yeni eklendi --->
				<cfquery name="ADD_SUBCRIPTION_PARTITION" datasource="#DSN3#">
					INSERT INTO
						SUBSCRIPTION_CONTRACT_PARTITION
					(
						SUBSCRIPTION_ID,
						PARTITION_NUMBER,
						PARTITION_START_DATE,
						PARTITION_DETAIL,
						RECORD_EMP,
						RECORD_IP, 
						RECORD_DATE						
					)
					VALUES
					(
						#attributes.subscription_id#,
						'#form_partition_number#',
						#form_partition_start_date#,
						'#form_partition_detail#',
						#session.ep.userid#,
						'#cgi.remote_addr#',
						#now()#		
					)
				</cfquery>
			<cfelse><!--- Bu satir vardi guncellendi --->
				<cfquery name="UPD_SUBCRIPTION_PARTITION" datasource="#DSN3#">
					UPDATE
						SUBSCRIPTION_CONTRACT_PARTITION
					SET
						SUBSCRIPTION_ID = #attributes.subscription_id#,
						PARTITION_NUMBER = '#form_partition_number#',
						PARTITION_START_DATE = #form_partition_start_date#,
						PARTITION_DETAIL = '#form_partition_detail#',	
						UPDATE_EMP = #session.ep.userid#,
						UPDATE_IP = '#cgi.remote_addr#',
						UPDATE_DATE = #now()#						
					WHERE
						PARTITION_ID = #form_partition_id#
				</cfquery>		
			</cfif>
		<cfelse>
			<cfscript>
				form_partition_id = evaluate("attributes.partition_id#i#");
			</cfscript>
			<cfif len(form_partition_id)><!--- Bu satir silindi --->
				<cfquery name="DEL_CREDIT_CONTRACT_ROW" datasource="#DSN3#">
					DELETE FROM
						SUBSCRIPTION_CONTRACT_PARTITION
					WHERE
						PARTITION_ID = #form_partition_id#
				</cfquery>
			</cfif>		
		</cfif>
	  </cfloop>
	</cfif>	
  </cftransaction>
</cflock>
<script type="text/javascript">
	<cfif not isdefined("attributes.draggable")>
		window.close();
	<cfelse>
		closeBoxDraggable( '<cfoutput>#attributes.modal_id#</cfoutput>' );
	</cfif>
</script>
