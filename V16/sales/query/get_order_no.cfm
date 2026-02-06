<!--- get_order_no --->
<cfquery name="GET_ORDER_NO" datasource="#dsn3#">
	SELECT 
		ORDER_NUMBER 
	FROM 
		ORDERS
	WHERE 
		ORDER_ID = 
			(
			SELECT MAX(ORDER_ID) FROM 
			ORDERS
			WHERE EMPLOYEE_ID = #SESSION.EP.USERID#)
</cfquery>
