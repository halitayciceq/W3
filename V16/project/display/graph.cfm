<cf_xml_page_edit fuseact="project.prodetail">

<!--- <cfoutput>#xml_str#</cfoutput> --->
<div class="color-list" id="color_list" ></div>
<div class="color-border" id="color_border"></div>
<script type="text/javascript">
    function getCSSColors()
    {
		try
		{
			var bg_color = $("#color_list").length != null ? rgbToHex($("#color_list").css("background-color")): "";
			var border_color = $("#color_border").length != null ? rgbToHex($("#color_border").css("background-color")): "";
			var flashObj = document.project_graph ? document.project_graph: document.getElementById("project_graph");
			if (flashObj) flashObj.applyCSS(bg_color, border_color);
		} catch (e) { }
    }
	
	function rgbToHex(value)
	{
		if (value.search("rgb") == -1)
            return value;
        else {
            value = value.match(/^rgb\((\d+),\s*(\d+),\s*(\d+)\)$/);
            function hex(x) {
                return ("0" + parseInt(x).toString(16)).slice(-2);
            }
            return "#" + hex(value[1]) + hex(value[2]) + hex(value[3]);
        }
	}
</script>

<cfif isdefined("session.ep.userid")>
	<cfset user_id = session.ep.userid>
	<cfset is_partner = 0>
<cfelse>
	<cfset display_mode = 1>
	<cfset user_id = session.pp.userid>
	<cfset is_partner = 1>
</cfif>

<!--- Düzenleme kısıtıyla ilgili kod --->
<cfif isDefined("xml_control_change_graph") and xml_control_change_graph eq 0><cfset display_mode = 1></cfif>
<!--- Proje görevlisiyle ilgili kısıta dait kod --->
<cfif not isDefined("display_mode") and is_partner eq 0 and xml_control_project_emp is 1>
	<cfquery name="get_project_emp" datasource="#DSN#">
    	SELECT PROJECT_EMP_ID FROM PRO_PROJECTS WHERE PROJECT_ID = #attributes.project_id#
    </cfquery>
    <cfif get_project_emp.PROJECT_EMP_ID neq user_id><cfset display_mode = 1></cfif>
</cfif>
<!--- Sayfa kısıtına ilişkin kod --->
<cfset page_name = "#url.fuseaction#">
<cfif is_partner eq 0 and (not isDefined("display_mode") or display_mode neq 1)>
    <cfquery name="GET_DEFINED_PAGE" datasource="#DSN#">
        SELECT DISTINCT DENIED_PAGE, DENIED_TYPE FROM EMPLOYEE_POSITIONS_DENIED WHERE DENIED_PAGE = <cfqueryparam cfsqltype="cf_sql_varchar" value="#page_name#">
    </cfquery>
    <cfif get_defined_page.recordcount gt 0>
        <cfif isdefined("user_id")>
            <cfquery name="get_page_access_and_denied" datasource="#dsn#">
                SELECT DISTINCT
                    EP.EMPLOYEE_ID,
                    EPD.DENIED_TYPE,
                    EPD.IS_VIEW,
                    EPD.IS_INSERT,
                    EPD.IS_DELETE
                FROM
                    EMPLOYEE_POSITIONS_DENIED EPD,
                    EMPLOYEE_POSITIONS EP
                WHERE
                    EPD.DENIED_PAGE = '#page_name#' AND
                    EPD.DENIED_TYPE = #get_defined_page.DENIED_TYPE# AND
                    EP.EMPLOYEE_ID = #user_id# AND
                    (
                        EP.POSITION_CAT_ID = EPD.POSITION_CAT_ID OR
                        EP.POSITION_CODE = EPD.POSITION_CODE OR
                        EP.USER_GROUP_ID = EPD.USER_GROUP_ID
                    )
                    <cfif get_defined_page.DENIED_TYPE eq 1>
                        AND (EPD.IS_VIEW = 1 AND EPD.IS_INSERT = 1)
                    <cfelse>
                        AND (EPD.IS_VIEW = 1 OR EPD.IS_INSERT = 1)
                    </cfif>
            </cfquery>
        </cfif>
        <cfif isdefined("get_defined_page") and get_defined_page.denied_type eq 1 and get_page_access_and_denied.recordcount gt 0 or get_defined_page.denied_type eq 0 and get_page_access_and_denied.recordcount eq 0>
            <cfset display_mode = 0>
        <cfelse>
            <cfset display_mode = 1>
        </cfif>
    <cfelse>
        <cfset display_mode = 0>
    </cfif>
</cfif>
<cfif isdefined("session.ep.company_id")>
	<cfset user_comp_id = session.ep.company_id>
<cfelse>
	<cfset user_comp_id = session.pp.our_company_id>
</cfif>
<cfif isdefined("session.ep.language")>
	<cfset user_language = session.ep.language>
<cfelse>
	<cfset user_language = session.pp.language>
</cfif>

<cfset flashvars = "serverAddress=#cgi.HTTP_HOST#&projectID=#attributes.project_id#&employeeID=#user_id#&language=#user_language#&companyID=#user_comp_id#&displayMode=#display_mode#&isPartner=#is_partner#">
<cfif isDefined("xml_work_sort_type") and len(xml_work_sort_type)><cfset flashvars = "#flashvars#&sortingType=#xml_work_sort_type#"></cfif>

<script src="/js/AC_RunActiveContent.js" type="text/javascript"></script>
<!---<div style="position:absolute; top:60px; left:0px; right:0px; bottom:0px;">--->
    <div style="position:absolute; top:80px; left:50px; right:0px; bottom:0px;">
	<script type="text/javascript">
        AC_FL_RunContent( 'codebase','http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=9,0,159,0','width','100%','height','95%','src','V16/com_mx/project_graph','quality','high','wmode','opaque','pluginspage','http://www.adobe.com/shockwave/download/download.cgi?P1_Prod_Version=ShockwaveFlash','movie','V16/com_mx/project_graph','id', 'project_graph','flashvars','<cfoutput>#flashvars#</cfoutput>', 'allowScriptAccess', 'always'); //end AC code
    </script>
    <noscript>
        <object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=9,0,159,0" width="100%" height="95%" id="project_graph">
            <param name="movie" value="V16/com_mx/project_graph.swf" />
            <param name="quality" value="high" />
            <param name="wmode" value="opaque" />
            <param name="flashvars" value="<cfoutput>#flashvars#</cfoutput>"/>
            <param name="allowScriptAccess" value="always"/>
            <embed id="production_plan_graph" src="V16/com_mx/project_graph.swf" quality="high" pluginspage="http://www.adobe.com/shockwave/download/download.cgi?P1_Prod_Version=ShockwaveFlash" type="application/x-shockwave-flash" width="100%" height="95%"></embed>
        </object>
    </noscript>
</div>