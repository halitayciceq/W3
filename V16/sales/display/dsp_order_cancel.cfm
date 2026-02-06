<cf_get_lang_set module_name="sales">
<cfquery name="get_cancel_info" datasource="#dsn3#">
	SELECT ORDER_NUMBER,CANCEL_TYPE_ID,CANCEL_DATE,CANCEL_DETAIL FROM ORDERS WHERE ORDER_ID = #attributes.order_id#
</cfquery>
<cfquery name="get_cancel_type" datasource="#dsn3#">
	SELECT
		SUBSCRIPTION_CANCEL_TYPE
	FROM 
		SETUP_SUBSCRIPTION_CANCEL_TYPE
	WHERE
		SUBSCRIPTION_CANCEL_TYPE_ID = #get_cancel_info.cancel_type_id#
</cfquery>
<cf_popup_box title="#getLang('sales',49)#">
	<table width="75%" border="0">
		<cfoutput>
			<tr height="22">
				<td width="75" class="txtbold">Sipariş No</td>
				<td width="150" align="left"> : #get_cancel_info.order_number#</td>
			</tr>
			<tr height="22">
				<td class="txtbold">İptal Tarihi</td>
				<td> : #dateformat(get_cancel_info.cancel_date,dateformat_style)#</td>
			</tr>
			<tr height="22">
				<td class="txtbold">İptal Nedeni</td>
				<td> : #get_cancel_type.subscription_cancel_type#</td>
			</tr>
			<tr height="22">
				<td class="txtbold">Açıklama</td>
				<td> : #get_cancel_info.cancel_detail#</td>
			</tr>
		</cfoutput>
	</table>
</cf_popup_box>
<cf_get_lang_set module_name="#lcase(listgetat(attributes.fuseaction,1,'.'))#">
