<cfcomponent>
    <cfset dsn = application.SystemParam.SystemParam().dsn>
    <cffunction name="PROJECT_REPORT" returntype="query" access="remote">
        <cfquery name="PROJECT_REPORT" datasource="#dsn#">
        SELECT  * FROM PRO_PROJECTS  
         LEFT JOIN SETUP_MAIN_PROCESS_CAT SMPC ON SMPC.MAIN_PROCESS_CAT_ID = PRO_PROJECTS.PROCESS_CAT
         LEFT JOIN PROCESS_TYPE_ROWS PTR ON  PTR.PROCESS_ROW_ID =  PRO_PROJECTS.PRO_CURRENCY_ID 
          WHERE PROJECT_STATUS = 1 AND PRO_PROJECTS.PROCESS_CAT IN
				(
					SELECT  
						SMC.MAIN_PROCESS_CAT_ID
					FROM 
						SETUP_MAIN_PROCESS_CAT SMC,
						SETUP_MAIN_PROCESS_CAT_ROWS SMR,
						EMPLOYEE_POSITIONS
					WHERE
						SMC.MAIN_PROCESS_CAT_ID = SMR.MAIN_PROCESS_CAT_ID AND
						EMPLOYEE_POSITIONS.POSITION_CODE = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.position_code#"> AND 
						(EMPLOYEE_POSITIONS.POSITION_CAT_ID=SMR.MAIN_POSITION_CAT_ID OR EMPLOYEE_POSITIONS.POSITION_CODE = SMR.MAIN_POSITION_CODE)
				)
        </cfquery>
        <cfreturn PROJECT_REPORT>
    </cffunction>
    <cffunction name="GET_PROJECT_STATUS" returntype="query" access="remote">
        <cfquery name="GET_PROJECT_STATUS" dbtype="query">
            SELECT COUNT(PROJECT_ID) AS TOTAL_STATUS FROM PROJECT_REPORT WHERE PROJECT_STATUS = 1
        </cfquery>
        <cfreturn GET_PROJECT_STATUS>
    </cffunction>
    <cffunction name="GET_PROJECT_CATEGORI" returntype="query" access="remote">
       
        <cfquery name="GET_PROJECT_CATEGORI" dbtype="query">
            SELECT COUNT(PROJECT_ID) AS TOTAL_CATEGORI , MAIN_PROCESS_CAT,PROCESS_CAT  
					
			FROM 
		        PROJECT_REPORT
                WHERE PROJECT_STATUS = 1
            GROUP BY PROCESS_CAT,MAIN_PROCESS_CAT
        </cfquery>
        
        <cfreturn GET_PROJECT_CATEGORI>
    </cffunction>

    <cffunction name="GET_PROJECT_STAGE" returntype="query" access="remote">
       
        <cfquery name="GET_PROJECT_STAGE" dbtype="query">
            SELECT COUNT(PROJECT_ID) AS TOTAL_STAGE , STAGE,PRO_CURRENCY_ID  
					
					 FROM 
			PROJECT_REPORT
            WHERE PROJECT_STATUS = 1
            GROUP BY PRO_CURRENCY_ID,STAGE
        </cfquery>
        
        <cfreturn GET_PROJECT_STAGE>
    </cffunction>

    <cffunction name="GET_PROJECT_WORKS" returntype="query" access="remote">
       
        <cfquery name="GET_PROJECT_WORKS" datasource="#dsn#">
            SELECT COUNT(*) AS TOTAL_WROKS FROM PRO_PROJECTS 
            left join PRO_WORKS AS PW ON PW.PROJECT_ID=PRO_PROJECTS.PROJECT_ID WHERE PROJECT_STATUS = 1 AND WORK_STATUS=1
            AND PRO_PROJECTS.PROCESS_CAT IN
				(
					SELECT  
						SMC.MAIN_PROCESS_CAT_ID
					FROM 
						SETUP_MAIN_PROCESS_CAT SMC,
						SETUP_MAIN_PROCESS_CAT_ROWS SMR,
						EMPLOYEE_POSITIONS
					WHERE
						SMC.MAIN_PROCESS_CAT_ID = SMR.MAIN_PROCESS_CAT_ID AND
						EMPLOYEE_POSITIONS.POSITION_CODE = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.position_code#"> AND 
						(EMPLOYEE_POSITIONS.POSITION_CAT_ID=SMR.MAIN_POSITION_CAT_ID OR EMPLOYEE_POSITIONS.POSITION_CODE = SMR.MAIN_POSITION_CODE)
				)
        </cfquery>
        <cfreturn GET_PROJECT_WORKS>
    </cffunction>

    <cffunction name="GET_PROJECT_BY_PARTNER" returntype="query" access="remote">
        <cfquery name="GET_PROJECT_BY_PARTNER" datasource="#dsn#">
            SELECT DISTINCT
            PROJECT_EMP_ID,
           
            count(*) as PROJECT_COUNT
            FROM
                PRO_PROJECTS 
             
            WHERE PROJECT_STATUS = 1 and (PROJECT_EMP_ID IS not null ) AND
            PRO_PROJECTS.PROCESS_CAT IN
				(
					SELECT  
						SMC.MAIN_PROCESS_CAT_ID
					FROM 
						SETUP_MAIN_PROCESS_CAT SMC,
						SETUP_MAIN_PROCESS_CAT_ROWS SMR,
						EMPLOYEE_POSITIONS
					WHERE
						SMC.MAIN_PROCESS_CAT_ID = SMR.MAIN_PROCESS_CAT_ID AND
						EMPLOYEE_POSITIONS.POSITION_CODE = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.position_code#"> AND 
						(EMPLOYEE_POSITIONS.POSITION_CAT_ID=SMR.MAIN_POSITION_CAT_ID OR EMPLOYEE_POSITIONS.POSITION_CODE = SMR.MAIN_POSITION_CODE)
				)
            GROUP BY
            PROJECT_EMP_ID
        </cfquery>
        
        <cfreturn GET_PROJECT_BY_PARTNER>
    </cffunction>
   
    <cffunction name="GET_PARTNER_WORK" returntype="query" access="remote">
        <cfquery name="GET_PARTNER_WORK" datasource="#dsn#">
            SELECT  COUNT(*) AS WORK_ID FROM 
			 PRO_WORKS
                LEFT JOIN PRO_PROJECTS ON PRO_WORKS.PROJECT_ID=PRO_PROJECTS.PROJECT_ID 
            WHERE PRO_PROJECTS.PROJECT_EMP_ID=<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.project_emp_id#"> AND WORK_STATUS=1 AND PROJECT_STATUS = 1 AND
            PRO_PROJECTS.PROCESS_CAT IN
				(
					SELECT  
						SMC.MAIN_PROCESS_CAT_ID
					FROM 
						SETUP_MAIN_PROCESS_CAT SMC,
						SETUP_MAIN_PROCESS_CAT_ROWS SMR,
						EMPLOYEE_POSITIONS
					WHERE
						SMC.MAIN_PROCESS_CAT_ID = SMR.MAIN_PROCESS_CAT_ID AND
						EMPLOYEE_POSITIONS.POSITION_CODE = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.position_code#"> AND 
						(EMPLOYEE_POSITIONS.POSITION_CAT_ID=SMR.MAIN_POSITION_CAT_ID OR EMPLOYEE_POSITIONS.POSITION_CODE = SMR.MAIN_POSITION_CODE)
				)
        </cfquery>
        <cfreturn GET_PARTNER_WORK>
    </cffunction>
    <cffunction name="GET_PROJECT_WORKGROUP" access="remote" returntype="query">
        <cfargument name="project_emp_id" default="">        
        <cfquery name="GET_PROJECT_WORKGROUP" datasource="#dsn#" >
            SELECT  COUNT(*) AS WORKGROUP_COUNT  FROM  WORKGROUP_EMP_PAR
            LEFT JOIN WORK_GROUP ON WORKGROUP_EMP_PAR.WORKGROUP_ID=WORK_GROUP.WORKGROUP_ID   
            LEFT JOIN PRO_PROJECTS ON WORK_GROUP.PROJECT_ID=PRO_PROJECTS.PROJECT_ID   
            WHERE PRO_PROJECTS.PROJECT_EMP_ID=<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.project_emp_id#"> AND PROJECT_STATUS = 1 
            AND WORKGROUP_EMP_PAR.OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#"> and
            PRO_PROJECTS.PROCESS_CAT IN
				(
					SELECT  
						SMC.MAIN_PROCESS_CAT_ID
					FROM 
						SETUP_MAIN_PROCESS_CAT SMC,
						SETUP_MAIN_PROCESS_CAT_ROWS SMR,
						EMPLOYEE_POSITIONS
					WHERE
						SMC.MAIN_PROCESS_CAT_ID = SMR.MAIN_PROCESS_CAT_ID AND
						EMPLOYEE_POSITIONS.POSITION_CODE = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.position_code#"> AND 
						(EMPLOYEE_POSITIONS.POSITION_CAT_ID=SMR.MAIN_POSITION_CAT_ID OR EMPLOYEE_POSITIONS.POSITION_CODE = SMR.MAIN_POSITION_CODE)
				)
        </cfquery>
        <cfreturn GET_PROJECT_WORKGROUP>        
    </cffunction>
    <cffunction name="GET_PROJECT_WORKGROUP_" access="remote" returntype="query">
        <cfargument name="project_emp_id" default="">        
        <cfquery name="GET_PROJECT_WORKGROUP_" datasource="#dsn#" >
            SELECT COUNT(DISTINCT  PRO_WORKS_HISTORY.PROJECT_EMP_ID) AS WORKGROUP_EMP  FROM  PRO_WORKS_HISTORY
            LEFT JOIN PRO_PROJECTS ON PRO_WORKS_HISTORY.PROJECT_ID=PRO_PROJECTS.PROJECT_ID 
            WHERE PRO_PROJECTS.PROJECT_EMP_ID=<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.project_emp_id#">  AND PROJECT_STATUS = 1  AND
            PRO_PROJECTS.PROCESS_CAT IN
				(
					SELECT  
						SMC.MAIN_PROCESS_CAT_ID
					FROM 
						SETUP_MAIN_PROCESS_CAT SMC,
						SETUP_MAIN_PROCESS_CAT_ROWS SMR,
						EMPLOYEE_POSITIONS
					WHERE
						SMC.MAIN_PROCESS_CAT_ID = SMR.MAIN_PROCESS_CAT_ID AND
						EMPLOYEE_POSITIONS.POSITION_CODE = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.position_code#"> AND 
						(EMPLOYEE_POSITIONS.POSITION_CAT_ID=SMR.MAIN_POSITION_CAT_ID OR EMPLOYEE_POSITIONS.POSITION_CODE = SMR.MAIN_POSITION_CODE)
				)
        </cfquery>
        <cfreturn GET_PROJECT_WORKGROUP_>        
    </cffunction>
   
    <cffunction name="GET_PROJECT_WORKGROUP_TIME" access="remote" returntype="query">
        <cfargument name="project_emp_id" default="">        
        <cfquery name="GET_PROJECT_WORKGROUP_TIME" datasource="#dsn#" >
              SELECT sum(ESTIMATED_TIME) AS ESTIMATED_TIME   FROM  PRO_WORKS AS PW
            left join PRO_PROJECTS  ON PW.PROJECT_ID=PRO_PROJECTS.PROJECT_ID  
            WHERE PRO_PROJECTS.PROJECT_EMP_ID=<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.project_emp_id#">  AND WORK_STATUS=1 
        </cfquery>
        <cfreturn GET_PROJECT_WORKGROUP_TIME>        
    </cffunction>
    <cffunction name="GET_PROJECT_WORKGROUP_LEADER" access="remote" returntype="query">
        <cfargument name="project_emp_id" default="">        
        <cfquery name="GET_PROJECT_WORKGROUP_LEADER" datasource="#dsn#" >
           SELECT sum(ESTIMATED_TIME) AS ESTIMATED_TIME   FROM  WORKGROUP_EMP_PAR
            LEFT JOIN WORK_GROUP ON WORKGROUP_EMP_PAR.WORKGROUP_ID=WORK_GROUP.WORKGROUP_ID   
        
            left join PRO_WORKS AS PW ON PW.PROJECT_ID=WORKGROUP_EMP_PAR.PROJECT_ID  
            WHERE PW.PROJECT_EMP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.project_emp_id#"> AND WORKGROUP_EMP_PAR.EMPLOYEE_ID=PW.PROJECT_EMP_ID AND 
            WORKGROUP_EMP_PAR.EMPLOYEE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.project_emp_id#"> AND WORK_STATUS=1  AND WORKGROUP_EMP_PAR.OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#"> 
        </cfquery>
        <cfreturn GET_PROJECT_WORKGROUP_LEADER>        
    </cffunction>
    <cffunction name="GET_PROJECT_WORKGROUP_AGENDA" access="remote" returntype="query">
        <cfargument name="project_emp_id" default="">        
        <cfquery name="GET_PROJECT_WORKGROUP_AGENDA" datasource="#DSN#">
            SELECT EVENT_ID, EVENT_HEAD, PROJECT_ID, STARTDATE,EVENT_TO_POS, FINISHDATE, DATEDIFF(minute, STARTDATE, FINISHDATE) AS DIFFDATE FROM EVENT WHERE FINISHDATE >= <cfqueryparam cfsqltype="cf_sql_date" value="#now()#"> AND EVENT_TO_POS LIKE  <cfqueryparam cfsqltype="cf_sql_varchar" value="%,#arguments.project_emp_id#,%">
        </cfquery>
        <cfreturn GET_PROJECT_WORKGROUP_AGENDA>        
    </cffunction>
    <cffunction name="GET_PROJECT_COUNT_AGENDA" access="remote" returntype="query">
        <cfquery name="GET_PROJECT_COUNT_AGENDA" dbtype="query">
            SELECT count(*) as EVENT_COUNT , sum(DIFFDATE) as DIFFDATE FROM GET_PROJECT_WORKGROUP_AGENDA 
        </cfquery>
        <cfreturn GET_PROJECT_COUNT_AGENDA>        
    </cffunction>
</cfcomponent>