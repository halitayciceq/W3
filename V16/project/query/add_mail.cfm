<!---katılımcılar, izleyiciler ve işlerin görevli kişileri alınacak--->
<!---A)EMPLOYEES--->
<!---1)PROJE LİDERİ--->
<!--- WORKGROUP_EMP_PAR --->
<cfset emps = ""> 
<cfset pars = "">
<cfquery name="GET_EMPS1" datasource="#dsn#">
	SELECT
		EMPLOYEE_POSITIONS.EMPLOYEE_ID,
		PRO_PROJECTS.PROJECT_HEAD
	FROM
		PRO_PROJECTS,
		EMPLOYEE_POSITIONS
	WHERE
		PRO_PROJECTS.PROJECT_ID=#URL.ID# AND
		EMPLOYEE_POSITIONS.EMPLOYEE_ID=PRO_PROJECTS.PROJECT_EMP_ID AND
		EMPLOYEE_POSITIONS.IS_MASTER=1
</cfquery>

<cfset project_name = get_emps1.PROJECT_HEAD>
<cfset emps = listappend(emps,valuelist(get_emps1.EMPLOYEE_ID))>

<!---2)PROJE grubunda bulunanlar--->
<cfquery name="GET_EMPS2" datasource="#dsn#">
	SELECT	
		DISTINCT EMPLOYEE_POSITIONS.EMPLOYEE_ID,
		WORKGROUP_EMP_PAR.POSITION_CODE
	FROM
		WORK_GROUP,
		WORKGROUP_EMP_PAR,
		EMPLOYEE_POSITIONS
	WHERE
		WORK_GROUP.WORKGROUP_ID=WORKGROUP_EMP_PAR.WORKGROUP_ID AND
		WORK_GROUP.PROJECT_ID=#URL.ID# AND
		EMPLOYEE_POSITIONS.EMPLOYEE_ID = WORKGROUP_EMP_PAR.EMPLOYEE_ID AND
		EMPLOYEE_POSITIONS.IS_MASTER=1 AND
		WORKGROUP_EMP_PAR.EMPLOYEE_ID IS NOT NULL
</cfquery>
<cfset emps = listappend(emps,valuelist(get_emps2.EMPLOYEE_ID))>

<cfif isdefined("attributes.is_all_users")>
	<!---3)iŞ GÖREVLİLERİ--->
	<cfquery name="GET_EMPS3" datasource="#dsn#">
		SELECT
			DISTINCT EMPLOYEE_POSITIONS.EMPLOYEE_ID AS EMPLOYEE_ID
		FROM
			PRO_WORKS,
			EMPLOYEE_POSITIONS
		WHERE
			PRO_WORKS.PROJECT_ID=#URL.ID# AND
			EMPLOYEE_POSITIONS.EMPLOYEE_ID=PRO_WORKS.PROJECT_EMP_ID AND
			EMPLOYEE_POSITIONS.IS_MASTER=1
	</cfquery>
	<cfset emps=listappend(emps,valuelist(get_emps3.EMPLOYEE_ID))>
</cfif>
<!---A)EMPLOYEES/bitti--->

<!---B)PARTNERS--->

<!---1)PROJE LİDERİ--->
<cfquery name="GET_PARS1" datasource="#dsn#">
	SELECT
		DISTINCT COMPANY_PARTNER.PARTNER_ID
	FROM
		PRO_PROJECTS,
		COMPANY_PARTNER
	WHERE
		PRO_PROJECTS.PROJECT_ID=#URL.ID# AND
		COMPANY_PARTNER.PARTNER_ID=PRO_PROJECTS.OUTSRC_PARTNER_ID AND
		COMPANY_PARTNER.PARTNER_ID IS NOT NULL
</cfquery>
<cfif GET_PARS1.RECORDCOUNT>
	<cfset pars = listappend(pars,valuelist(GET_PARS1.PARTNER_ID))>
</cfif>
<cfquery name="GET_PARS2" datasource="#dsn#">
	SELECT
		WORKGROUP_EMP_PAR.PARTNER_ID
	FROM
		WORKGROUP_EMP_PAR,
		WORK_GROUP
	WHERE
		WORK_GROUP.WORKGROUP_ID=WORKGROUP_EMP_PAR.WORKGROUP_ID AND
		WORK_GROUP.PROJECT_ID=#URL.ID# AND
		WORKGROUP_EMP_PAR.PARTNER_ID IS NOT NULL
</cfquery>
<cfif GET_PARS2.RECORDCOUNT>
	<cfset pars = listappend(pars,valuelist(GET_PARS2.PARTNER_ID))>
</cfif>

<cfif isdefined("attributes.is_all_users")>
	<!---2)iŞ GÖREVLİLERİ--->
	<cfquery name="GET_PARS3" datasource="#dsn#">
		SELECT
			OUTSRC_PARTNER_ID	
		FROM
			PRO_WORKS
		WHERE
			PRO_WORKS.PROJECT_ID=#URL.ID#
	</cfquery>
	<cfset pars=listappend(pars,valuelist(get_pars3.OUTSRC_PARTNER_ID))>
</cfif>

<cfquery name="add_mail" datasource="#dsn#">
	INSERT INTO PROJECT_MAILS
	(
		MAIL_HEAD,
		MAIL_BODY,
		PROJECT_ID,
		TO_EMPS,
		TO_PARS,
		RECORD_DATE,
		RECORD_EMP,
		RECORD_IP	
	)
	VALUES
	(
		'#attributes.mail_subject#',
		'#attributes.mail_body#',
		#attributes.id#,
		'#emps#',
		'#pars#',
		#NOW()#,
		#SESSION.EP.USERID#,
		'#CGI.REMOTE_ADDR#'
	)
</cfquery>


<!---B)PARTNERS/bitti--->
<cfset emps_="">
<cfset pars_="">
<!---emps distinct ediliyor--->
<cfloop list="#emps#" index="i">
	<cfif not listfind(emps_,i)>
		<cfset emps_=listappend(emps_,i)>
	</cfif>
</cfloop>
<!---/emps distinct ediliyor--->
<!---pars distinct ediliyor--->
<cfloop list="#pars#" index="i">
	<cfif not listfind(pars_,i)>
		<cfset pars_=listappend(pars_,i)>
	</cfif>
</cfloop>
<!---/pars distinct ediliyor--->

<cfquery name="GET_SENDER" datasource="#dsn#">
	SELECT 
		EMPLOYEE_EMAIL,
		EMPLOYEE_NAME,
		EMPLOYEE_SURNAME
	FROM
		EMPLOYEES
	WHERE
		EMPLOYEE_ID=#SESSION.EP.USERID#
</cfquery>
<!--- Objects ten logo ve bilgiler --->
<cfsavecontent variable="ust"><cfinclude template="../../objects/display/view_company_logo.cfm"></cfsavecontent>
<cfsavecontent variable="alt"><cfinclude template="../../objects/display/view_company_info.cfm"></cfsavecontent>
<cfset alt = ReplaceList(alt,'#chr(39)#','')>
<cfset alt = ReplaceList(alt,'#chr(10)#','')>
<cfset alt = ReplaceList(alt,'#chr(13)#','')>
<cfset ust = ReplaceList(ust,'#chr(39)#','')>
<cfset ust = ReplaceList(ust,'#chr(10)#','')>
<cfset ust = ReplaceList(ust,'#chr(13)#','')>
<!--- Objects ten logo ve bilgiler --->

<!--- <cfset sender_mail=get_sender.EMPLOYEE_EMAIL> --->	
<cfset sender = get_sender.EMPLOYEE_NAME&' '&get_sender.EMPLOYEE_SURNAME&'<'&get_sender.EMPLOYEE_EMAIL&'>'>
<!---mail to employees--->
<cfloop list="#emps_#" index="i">
	<cfquery name="GET_EMP_MAIL" datasource="#dsn#">
		SELECT 
			EMPLOYEE_EMAIL
		FROM
			EMPLOYEES
		WHERE
			EMPLOYEE_ID=#I#
	</cfquery>
	<cfset tomail=get_emp_mail.EMPLOYEE_EMAIL>
	<cfif len(tomail)>
	<cfmail from="#sender#" to="#tomail#" type="HTML" subject="WorkCube Proje Yöneticisi - #project_name# Projesi İle İlgili Genel Duyuru Yapıldı!">
		<cfinclude template="add_mail_view.cfm">
		<table width="590" align="center">
		<tr>
		<td>
		<a href="#employee_domain##request.self#?fuseaction=project.projects&event=det&ID=#url.ID#" class="tableyazi">#project_name#</a><br/><br/>
		<span class="label"><STRONG>#sender#</STRONG></span><br/>
		</td>
		</tr>
		</table>
		#alt#
		</cfmail>
	</cfif>
</cfloop>
<!---/mail to employees--->

<!---mail to partners--->
<cfloop list="#pars_#" index="i">
	<cfquery name="GET_PAR_MAIL" datasource="#DSN#">
		SELECT 
			COMPANY_PARTNER_EMAIL
		FROM
			COMPANY_PARTNER
		WHERE
			PARTNER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#i#">
	</cfquery>
	<!--- kullanicisi oldugu site --->
	<cfquery name="GET_DOMAINS" datasource="#DSN#" maxrows="1">
		<!---SELECT SITE_DOMAIN FROM COMPANY_CONSUMER_DOMAINS WHERE PARTNER_ID = #I# ORDER BY RECORD_DATE DESC--->
		SELECT 
            CCD.SITE_DOMAIN 
        FROM 
            COMPANY_CONSUMER_DOMAINS CCD,
            MAIN_MENU_SETTINGS MMS
        WHERE 
            CCD.MENU_ID = MMS.MENU_ID AND
            CCD.PARTNER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#i#">
        ORDER BY 
            CCD.RECORD_DATE DESC
	</cfquery>
	<cfset tomail=get_par_mail.company_partner_email>
	<cfif len(tomail)>
        <cfmail from="#sender#" to="#tomail#" type="HTML" subject="#project_name# Projesi ile İlgili Genel Duyuru Yapıldı!">
        <cfinclude template="add_mail_view.cfm">	
            <table width="590" align="center">
                <tr>
                    <td>
                        <a href="http://#get_domains.site_domain#/#request.self#?fuseaction=project.projects&event=det&ID=#url.id#" class="tableyazi">#project_name#</a><br/><br/>
                        <span class="label"><STRONG>#sender#</STRONG></span><br/>
                    </td>
                </tr>
            </table>
            #alt#
        </cfmail>
	</cfif>
</cfloop>
<!---/mail to partners--->

<script type="text/javascript">
	wrk_opener_reload();
	window.close();
</script>
