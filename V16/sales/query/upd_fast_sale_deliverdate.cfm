<!--- Taksitli satışların teslim tarihlerini güncelliyor SM20080703 --->
<cfsetting showdebugoutput="no">
<cf_date tarih = "attributes.deliver_date">
<cfquery name="get_order" datasource="#dsn3#">
	SELECT ORDER_STAGE,ORDER_NUMBER FROM ORDERS WHERE ORDER_ID = #attributes.order_id#
</cfquery>
<cfquery name="upd_order" datasource="#dsn3#">
	UPDATE 
		ORDERS 
	SET 
		DELIVERDATE = #attributes.deliver_date#,
		<cfif isdefined("attributes.process_cat")>
		ORDER_STAGE = #attributes.process_cat#,
		</cfif>
		UPDATE_DATE = #now()#,
		UPDATE_IP = '#cgi.remote_addr#',
		UPDATE_EMP = #session.ep.userid#				
	WHERE 
		ORDER_ID = #attributes.order_id#
</cfquery>
<cfif isdefined("attributes.process_cat")>
	<cf_workcube_process
		is_upd='1' 
		data_source='#dsn3#' 
		old_process_line='#attributes.old_process_line#'
		process_stage='#attributes.process_cat#' 
		record_member='#session.ep.userid#'
		record_date='#now()#' 
		action_table='ORDERS'
		action_column='ORDER_ID'
		action_id='#attributes.order_id#' 
		action_page='#request.self#?fuseaction=#listgetat(attributes.fuseaction,1,'.')#.upd_fast_sale&order_id=#attributes.order_id#' 
		warning_description='#getLang('','Taksitli Satış',43571)# : #get_order.ORDER_NUMBER#'>	
</cfif>
<script type="text/javascript">
	<cfif isdefined("attributes.process_cat")>
		alert("Aşama Güncellendi !");
	<cfelse>
		alert("<cf_get_lang no ='590.Teslim Tarihi Güncellendi'> !");
	</cfif>
	window.location.href = "<cfoutput>#request.self#?fuseaction=sales.list_order_instalment&event=upd&order_id=#attributes.order_id#</cfoutput>";
</script>
