<cfset stage = 0>
<cffunction name="getWorkTree" returntype="string" output="false">
	<cfargument name="main_works" type="string" required="yes">
	<cfargument name="work_id" type="numeric" required="yes">
    <!--- <cfargument name="start" type="numeric" required="no">
	<cfargument name="end" type="numeric" required="no"> --->
	<cfquery name="GET_WORK_TREE#arguments.work_id#" dbtype="query">
        SELECT
            WORK_ID
        FROM
            #arguments.main_works#
        WHERE
        <cfif arguments.work_id eq 0>
            MILESTONE_WORK_ID = #arguments.work_id# OR
            MILESTONE_WORK_ID IS NULL
        <cfelse>
            MILESTONE_WORK_ID = #arguments.work_id#
        </cfif>
        <!--- <cfif isdefined("arguments.start")>
            AND ROW >= #arguments.start#
        </cfif>
        <cfif isdefined("arguments.end")>
            AND ROW < #arguments.end#
        </cfif> --->
	</cfquery>
	<cfscript>
		sublist = "";
		tmp = "";
		'i#arguments.work_id#' = 1;
		while(Evaluate("i#arguments.work_id#") lte Evaluate("GET_WORK_TREE#arguments.work_id#.RecordCount"))
		{
			tmp_int = Evaluate("i#arguments.work_id#");
			if(arguments.work_id eq 0)
			{
				sublist = sublist & "0," & Evaluate("GET_WORK_TREE#arguments.work_id#.WORK_ID[#tmp_int#]");
				stage = stage + 1;
				'stage#stage#' = "0";
			}
			else
			{
				'stage#stage#' = Evaluate("stage#stage#") & "," & arguments.work_id;
				sublist = sublist & "," & Evaluate("GET_WORK_TREE#arguments.work_id#.WORK_ID[#tmp_int#]");
			}
			sublist = sublist & "," & getWorkTree('#arguments.main_works#', Evaluate("GET_WORK_TREE#arguments.work_id#.WORK_ID[#tmp_int#]"));
			'i#arguments.work_id#' = Evaluate("i#arguments.work_id#") + 1;
		}
	</cfscript>
	<cfreturn sublist>
</cffunction>
<cffunction name="getWork" returntype="query" output="false">
	<cfargument name="main_works" type="string" required="true">
	<cfargument name="work_id" type="numeric" required="yes">
    <!--- <cfargument name="startrow" type="numeric" required="no">
	<cfargument name="endrow" type="numeric" required="no"> --->
	<cfquery  name="GET_WORK" dbtype="query">
		SELECT
			*
		FROM
			#arguments.main_works#
		WHERE
            WORK_ID = #arguments.work_id#
           <!--- AND  ROW >= #arguments.startrow# AND
            ROW < #arguments.endrow# --->
	</cfquery>
	<cfreturn GET_WORK>
</cffunction>
