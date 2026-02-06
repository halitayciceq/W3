<cfquery name="ORDER_TO_WORK" datasource="#dsn3#">
	UPDATE 
		ORDERS 
	SET 
		IS_WORK = 1
	WHERE 
		ORDER_ID = #URL.order_id#
</cfquery>

<cflocation url="index.cfm?fuseaction=project.popup_order_to_work&order_id=#url.order_id#" addtoken="no">
