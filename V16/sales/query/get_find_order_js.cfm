<cfform name="find_order" method="post" action="" onsubmit="return (find_order_f())">
<td style="text-align:right;" valign="bottom">
	<input type="text"  name="find_order_number" id="find_order_number" value="">
	<input type="hidden" name="my_input" id="my_input" value="0">
</td>
<td style="text-align:right;" valign="bottom"><cf_wrk_search_button search_function='find_order_f()' is_excel='0'></td>
</cfform>
<script type="text/javascript">
function find_order_f()
{
	if (find_order.find_order_number.value.length)
	{
		var get_order = wrk_safe_query('sls_get_order','dsn3',0,find_order.find_order_number.value);
		if(get_order.recordcount)
		{
			find_order.action = '<cfoutput>#request.self#?fuseaction=sales.list_order&event=upd&order_id=</cfoutput>'+get_order.ORDER_ID[0];
			find_order.submit();
			return false;
		}
		else
		{
			alert("<cf_get_lang_main no='1074.Kayıt Bulunamadı'>!");
			return false;
		}
	}
	else
	{ 
		alert("<cf_get_lang no='532.Sipariş Nosu Eksik'> !");
		return false;
	}
}
</script>
