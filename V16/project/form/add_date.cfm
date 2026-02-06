<cfsetting showdebugoutput="no">
<cf_date tarih="attributes.startdate_plan">
<cfscript>
 	yil = dateformat(attributes.startdate_plan,'yyyy');
	ay = dateformat(attributes.startdate_plan,'mm');
	gun = dateformat(attributes.startdate_plan,'dd');
	estimated_work_finish_date = CreateDateTime(yil,ay,gun,work_start_hour,0,0);
	if(len(add_hour))
		{estimated_work_finish_date = date_add('h',add_hour,estimated_work_finish_date);}
	if(len(add_minute)) 
		{estimated_work_finish_date = date_add('n',add_minute,estimated_work_finish_date);}
</cfscript>
<cfoutput>
	<script type="text/javascript">
		var deger = "#dateformat(estimated_work_finish_date,'HH')#";
		if(deger < 10)
			deger = parseFloat(deger);
		document.getElementById('finishdate_plan').value = "#dateformat(estimated_work_finish_date,dateformat_style)#";
		document.getElementById('finish_hour_plan').value = deger;
	</script>
</cfoutput>
