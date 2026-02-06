<!--- 
	mail_type_id 1 ise görevliye, 2 ise CC deki kisiye mail gider.
	mail_emp_id ise genel degisken olarak kullanılmaktadir.
 --->
<style type="text/css">
	.label {font-size:11px;font-family:Geneva, tahoma, arial, Helvetica, sans-serif;color : ##333333;padding-left: 4px;}
	.css1 {font-size:12px;font-family:arial,verdana;color:000000; background-color:white;}
	.css2 {font-size:9px;font-family:arial,verdana;color:999999; background-color:white;}
</style>
<cfinclude template="../../objects/display/view_company_logo.cfm">
<cfoutput>
<table width="600" class="css1">
	<tr>
		<td colspan="2">
			<cf_get_lang_main no='1368.Sayın'>
			<cfif mail_type_id eq 1>
				<cfif isdefined('attributes.task_partner_id') and len(attributes.task_partner_id)>
					#get_par_info(attributes.task_partner_id,0,0,0)#,
				<cfelseif isdefined('attributes.project_emp_id') and len(attributes.project_emp_id)>
					#get_emp_info(attributes.project_emp_id,0,0)#,
				</cfif><br/>     
				#session.ep.name# #session.ep.surname# 
				<cf_get_lang no='118.tarafından sizin adınıza yeni bir görevlendirme yapıldı'>.
			<cfelseif mail_type_id eq 2>
				<cfif isdefined('attributes.cc_par_id') and len(attributes.cc_par_id)>
					#get_par_info(attributes.cc_par_id,0,0,0)#,
				<cfelseif isdefined('attributes.cc_emp_id') and len(attributes.cc_emp_id)>
					#get_emp_info(attributes.cc_emp_id,0,0)# ,
				</cfif><br/>   
				#session.ep.name# #session.ep.surname# 
				<cf_get_lang no='145.tarafından sizin adınıza yeni bir bilgilendirme yapıldı'>.
			</cfif> 
			<br/><br/><br/>
		</td>
	</tr>
	<tr>
		<td align="left"><b><cf_get_lang no='128.İlgili İş Linki'></b></td>
		<td align="left">
			<cfif len(mail_emp_id)>
				<a href ='#employee_domain##request.self#?fuseaction=project.works&event=det&id=#work_id#'>
				<cfif mail_type_id eq 1><font color="FF0000"><cfelse><font color="0000FF"></cfif>#attributes.work_head#</font></a>
			<cfelse>
				<a href ='#partner_domain##request.self#?fuseaction=project.works&event=det&id=#work_id#'><cfif mail_type_id eq 1><font color="FF0000"><cfelse><font color="0000FF"></cfif>#attributes.work_head#</font></a>
			</cfif>
		</td></font>
	</tr>
	<cfif len(attributes.project_id)>
		<cfquery name="Get_Project_Head" datasource="#dsn#">
			SELECT PROJECT_NUMBER, PROJECT_HEAD FROM PRO_PROJECTS WHERE PROJECT_ID = #attributes.project_id#
		</cfquery>
		<tr>
			<td align="left"><cf_get_lang no='142.İlişkili Proje'></td>
			<td align="left">#Get_Project_Head.Project_Number# - #Get_Project_Head.Project_Head#</td>
		</tr>
	</cfif>
	<tr>
		<td><cf_get_lang_main no='1055.Başlama'></td>
		<td align="left">
			<cfif isdefined('attributes.startdate_plan') and len(attributes.startdate_plan)>
				<cfoutput>#dateformat(date_add("h",session.ep.time_zone,attributes.startdate_plan),dateformat_style)#&nbsp;#attributes.start_hour#:00</cfoutput>
			</cfif>
		</td> 
	</tr>
	<tr>
		<td><cf_get_lang_main no='90.Bitiş'></td>
		<td align="left">
			<cfif isdefined('attributes.finishdate_plan') and len(attributes.finishdate_plan)>
				<cfoutput>#dateformat(date_add("h",session.ep.time_zone,attributes.finishdate_plan),dateformat_style)#&nbsp;#finish_hour_plan#:00</cfoutput>
			</cfif>
		</td>
	</tr>
</table>
<br/>
<table width="100%">
	<tr align="left">
		<td><cfinclude template="../../objects/display/view_company_info.cfm">&nbsp;</td>
	</tr>
	<tr height="50" valign="bottom">
		<td><font class="css2">
				<cf_get_lang_main no='663.Bu mesaj'>
				<cfoutput>#session.ep.company#</cfoutput>
				<cf_get_lang_main no='664.sistemi tarafından otomatik olarak gönderilmiştir'>.<br/>
				<cf_get_lang no='98.Eğer bir sorun olduğunu düşünüyorsanız lütfen maili reply ediniz'>...<br/>
			</font>		
		</td>
	</tr>
</table>
</cfoutput>
