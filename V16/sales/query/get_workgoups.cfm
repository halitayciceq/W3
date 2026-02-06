<cfquery name="get_wrkgroups" datasource="#dsn#">
  SELECT 
    WORKGROUP_ID,
	WORKGROUP_NAME
  FROM 
    WORK_GROUP
  WHERE
    WORKGROUP_ID IN (#attributes.wrk_group_ids#)
</cfquery>
