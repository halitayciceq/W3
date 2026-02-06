<cfquery name="GET_PAYMETHOD" datasource="#DSN#">
	SELECT 
		PAYMETHOD_ID,
        PAYMETHOD ,
		PAYMENT_VEHICLE,
		IS_DUE_ENDOFMONTH,
		ISNULL(DUE_START_DAY,ISNULL(DUE_START_MONTH*30,0)) + ISNULL(DUE_DAY,0) DUE_DAY <!--- fbs 20140902 Ortalama Vadeye, Vade Baslangici Da Ekleniyor --->
	FROM 
		SETUP_PAYMETHOD
	WHERE
		PAYMETHOD_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.paymethod_id#">
</cfquery>
