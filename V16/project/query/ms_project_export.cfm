<cfsetting showdebugoutput="no">
<cfquery name="GET_PRO_WORKS" datasource="#DSN#">
	SELECT
		MS_UNIQUE_ID,
		WORK_CAT_ID,
		WORK_CURRENCY_ID,
		WORK_PRIORITY_ID,
		PROJECT_EMP_ID,
		WORK_NO,
		WORK_HEAD,
		(SELECT PBS_CODE FROM #dsn3_alias#.SETUP_PBS_CODE WHERE SETUP_PBS_CODE.PBS_ID = PRO_WORKS.PBS_ID) PBS_CODE,
		WORK_DETAIL,
		ESTIMATED_TIME,
		AVERAGE_AMOUNT,
		TOTAL_TIME_HOUR,
		IS_MILESTONE,
		REAL_START,
		REAL_FINISH,
		TARGET_START,
		TARGET_FINISH,
		TO_COMPLETE,
		COMPLETED_AMOUNT,
		DURATION,
		PREDICTED_START,
		PREDICTED_FINISH,
		WORK_STATUS,
		WORKGROUP_ID
	FROM 
		PRO_WORKS 
	WHERE 
		PROJECT_ID = #attributes.id# AND
		MS_UNIQUE_ID IS NOT NULL
</cfquery>

<cfquery name="GET_PROJECT_NAME" datasource="#DSN#">
	SELECT PROJECT_HEAD FROM PRO_PROJECTS WHERE PROJECT_ID = #attributes.id#
</cfquery>

<!--- MS Project Export Kayıtları Workcube\\Documents\\MS_Project altında task.csvdosyası içine yazar --->
<cfif FileExists("#upload_folder#MS_Project#dir_seperator##get_project_name.project_head#_task.csv")>
	<cffile action="rename" source="#upload_folder#MS_Project#dir_seperator##get_project_name.project_head#_task.csv" destination="#upload_folder#MS_Project#dir_seperator##dateformat(now(),'ddmmyyyyhhmm')#_#get_project_name.project_head#_task.csv" mode="777">
</cfif>

<cfheader name="Expires" value="#Now()#">
<cfcontent type="application/octet-stream">
<cfheader name="Content-Disposition" value="attachment; filename=#get_project_name.project_head#_task.csv">Unique ID;İş Kategorisi*;Aşama*;Öncelik*;Görevli*;İş No;Konu;PBS Kodu;Açıklama;Öngörülen Süre;Süre;Başlama Tarihi;Bitiş Tarihi;Tahmini Miktar;Milestone;İş Gurubu;Aktiflik Durumu
<cfloop query="GET_PRO_WORKS"><cfoutput>#MS_UNIQUE_ID#;#WORK_CAT_ID#;#WORK_CURRENCY_ID#;#WORK_PRIORITY_ID#;#PROJECT_EMP_ID#;#WORK_NO#;#WORK_HEAD#;<cfif len(PBS_CODE)>#PBS_CODE#<cfelse>0</cfif>;<cfif len(WORK_DETAIL)>#WORK_DETAIL#<cfelse>YOK</cfif>;<cfif len(ESTIMATED_TIME)>#replace(wrk_round(ESTIMATED_TIME/60),'.',',')#<cfelse>0</cfif>;<cfif len(DURATION)>#DURATION#<cfelse>0</cfif>;<cfif len(TARGET_START)>#dateformat(date_add("h",session.ep.time_zone,TARGET_START),'dd.mm.yyyy')#<cfelse>YOK</cfif>;<cfif len(TARGET_FINISH)>#dateformat(date_add("h",session.ep.time_zone,TARGET_FINISH),'dd.mm.yyyy')#<cfelse>YOK</cfif>;<cfif len(AVERAGE_AMOUNT)>#AVERAGE_AMOUNT#<cfelse>0</cfif>;<cfif IS_MILESTONE eq 'HAYIR' or  IS_MILESTONE eq '0' or IS_MILESTONE eq ''>0<cfelse>1</cfif>;<cfif len(workgroup_id)>#workgroup_id#<cfelse>YOK</cfif>;<cfif work_status eq 0>2<cfelse>#work_status#</cfif>;;#Chr(13)#</cfoutput></cfloop>

	


