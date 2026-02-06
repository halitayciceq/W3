<cfif x_control_ims eq 1 and session.ep.our_company_info.sales_zone_followup eq 1>
	<cfinclude template="../../member/query/get_ims_control.cfm">
</cfif>
<!--- <cfquery name="GET_ORDER_LIST" datasource="#dsn3#"> --->
<cfoutput>
    <cfsavecontent variable="SELECT">
            <cfif (isdefined("attributes.prod_cat") and len(attributes.prod_cat)) or (len(attributes.product_name) and len(attributes.product_id)) or (isDefined("currency_id") and len(currency_id)) or (isdefined("attributes.employee_id") and len(attributes.employee_id) and isdefined("attributes.employee") and len(attributes.employee))>
                DISTINCT
            </cfif>
            <cfif (isdefined('attributes.listing_type') and attributes.listing_type eq 2)><!--- Eğer satır bazında listeleme yapılıyorsa --->
                ORR.ORDER_ROW_CURRENCY,
                ORR.STOCK_ID,
                ORR.PRODUCT_ID,
                ORR.QUANTITY,
                ORR.CANCEL_AMOUNT,
                ORR.UNIT,
                PRODUCT.PRODUCT_NAME,
                PRODUCT.PRODUCT_CODE,
                ORR.NETTOTAL AS NETTOTAL,
                (ORR.NETTOTAL * ORR.TAX /100) AS TAXTOTAL,
                ORR.OTHER_MONEY_VALUE AS OTHER_MONEY_VALUE,
                ORR.OTHER_MONEY AS OTHER_MONEY,
                ORR.DELIVER_DATE AS ROW_DELIVER_DATE,
                ORR.SPECT_VAR_ID,
                ORR.SPECT_VAR_NAME,
                ORR.WRK_ROW_ID,
                ORR.ORDER_ROW_ID,
            <cfelse>
                ORDERS.NETTOTAL,
                ORDERS.TAXTOTAL,
                ORDERS.OTHER_MONEY_VALUE,
                ORDERS.OTHER_MONEY,
            </cfif>
            <cfif x_show_special_definition eq 1>
                ORDERS.SALES_ADD_OPTION_ID,
            </cfif>
            ORDERS.ORDER_ID,
            ORDERS.ORDER_STATUS,
            ORDERS.CONSUMER_ID,
            ORDERS.PARTNER_ID,
            ORDERS.COMPANY_ID,
            ORDERS.ORDER_NUMBER,
            ORDERS.REF_NO,
            ORDERS.ORDER_CURRENCY,
            ORDERS.ORDER_HEAD,
            ORDERS.TAX,
            ORDERS.PRIORITY_ID,
            ORDERS.COMMETHOD_ID,
            ORDERS.GROSSTOTAL, 
            ORDERS.RECORD_DATE, 
            ORDERS.RECORD_EMP, 
            ORDERS.RECORD_PAR,
            ORDERS.RECORD_CON,
            ORDERS.DELIVERDATE, 
            ORDERS.ORDER_ZONE, 
            ORDERS.ORDER_EMPLOYEE_ID,
            ORDERS.SALES_PARTNER_ID,
            ORDERS.SALES_CONSUMER_ID,
            ORDERS.ORDER_DATE,
            ORDERS.ORDER_STAGE,
            ORDERS.IS_INSTALMENT,
            ORDERS.IS_PROCESSED,
            ORDERS.PROJECT_ID,
            ORDERS.FRM_BRANCH_ID,
            (SELECT BRANCH_NAME FROM #dsn_alias#.BRANCH WHERE BRANCH_ID = ORDERS.FRM_BRANCH_ID) AS BRANCH_NAME
    </cfsavecontent>        
    <cfsavecontent variable="FROM">
        <cfif (isdefined('attributes.listing_type') and attributes.listing_type eq 2) OR ((len(attributes.short_code_name) and len(attributes.short_code_id)) or (len(attributes.brand_name) and len(attributes.brand_id)) or (len(attributes.product_name) and len(attributes.product_id)) or (isDefined("currency_id") and len(currency_id)) or (isdefined("attributes.prod_cat") and len(attributes.prod_cat)) or (isdefined("attributes.employee_id") and len(attributes.employee_id) and isdefined("attributes.employee") and len(attributes.employee)))>
            ORDER_ROW ORR,
        </cfif>
        <cfif (isdefined('attributes.listing_type') and attributes.listing_type eq 2) OR ((isdefined("attributes.prod_cat") and len(attributes.prod_cat)) or (isdefined("attributes.employee_id") and len(attributes.employee_id) and isdefined("attributes.employee") and len(attributes.employee)))>
            PRODUCT, 
        </cfif>	
            ORDERS
    </cfsavecontent>
    <cfsavecontent variable="WHERE">
            ( (ORDERS.PURCHASE_SALES = 1 AND ORDERS.ORDER_ZONE = 0) OR (ORDERS.PURCHASE_SALES = 0 AND ORDERS.ORDER_ZONE = 1) )
            <cfif isdefined("attributes.sales_departments") and len(attributes.sales_departments)>
                AND ORDERS.DELIVER_DEPT_ID = #listfirst(attributes.sales_departments,'-')#
                AND ORDERS.LOCATION_ID = #listlast(attributes.sales_departments,'-')#
            </cfif>
            <cfif (isdefined('attributes.listing_type') and attributes.listing_type eq 2) OR ((len(attributes.short_code_name) and len(attributes.short_code_id)) or (len(attributes.brand_name) and len(attributes.brand_id)) or (len(attributes.product_name) and len(attributes.product_id)) or (isDefined("currency_id") and len(currency_id)) or (isdefined("attributes.prod_cat") and len(attributes.prod_cat)) or (isdefined("attributes.employee_id") and len(attributes.employee_id) and isdefined("attributes.employee") and len(attributes.employee)))>
                AND ORR.ORDER_ID = ORDERS.ORDER_ID
            </cfif>
            <cfif len(attributes.product_name) and len(attributes.product_id)>
                 AND ORR.PRODUCT_ID = #attributes.product_id#
            </cfif>
            <cfif len(attributes.short_code_id) and len(attributes.short_code_name)>
                 AND ORR.PRODUCT_ID IN (SELECT PRODUCT_ID FROM PRODUCT WHERE PRODUCT.SHORT_CODE_ID = #attributes.short_code_id#)
            </cfif>	
            <cfif len(attributes.brand_id) and len(brand_name)>
                AND ORR.PRODUCT_ID IN (SELECT PRODUCT_ID FROM PRODUCT WHERE PRODUCT.BRAND_ID = #attributes.brand_id#)
            </cfif>
            <cfif isdefined("attributes.employee_id") and len(attributes.employee_id) and isdefined("attributes.employee") and len(attributes.employee)>
                AND PRODUCT.PRODUCT_MANAGER = #attributes.employee_id#
            </cfif>
            <cfif  (isdefined('attributes.listing_type') and attributes.listing_type eq 2) OR ((isdefined("attributes.prod_cat") and len(attributes.prod_cat)) or (isdefined("attributes.employee_id") and len(attributes.employee_id) and isdefined("attributes.employee") and len(attributes.employee)))>
                AND PRODUCT.PRODUCT_ID = ORR.PRODUCT_ID
            </cfif>
            <cfif isdefined("attributes.prod_cat") and len(attributes.prod_cat)>
                AND PRODUCT.PRODUCT_CODE LIKE '#attributes.prod_cat#.%'
            </cfif>
            <cfif isDefined("status") and len(status)>
                AND ORDERS.ORDER_STATUS = #status#
            </cfif>
            <cfif isdefined("attributes.project_id") and len (attributes.project_id) and isdefined("attributes.project_head") and len (attributes.project_head)>
                AND ORDERS.PROJECT_ID = #attributes.project_id#
            </cfif>
            <cfif isdefined('attributes.subscription_id') and len(attributes.subscription_id) and isdefined('attributes.subscription_no') and len(attributes.subscription_no)>
                AND ORDERS.SUBSCRIPTION_ID = #attributes.subscription_id#
            </cfif>
            <cfif isDefined("attributes.priority") and len(attributes.priority)>
              AND ORDERS.PRIORITY_ID = #attributes.priority#
            </cfif>
            <cfif isDefined("attributes.keyword") and len(attributes.keyword)>
                AND
                (
                    ORDERS.ORDER_HEAD LIKE '%#attributes.keyword#%' OR
                    ORDERS.ORDER_NUMBER LIKE '%#attributes.keyword#%' OR	 
                    ORDERS.REF_NO LIKE '%#attributes.keyword#%'
                )
            </cfif>
            <cfif isDefined("currency_id") and len(currency_id)>
                AND ORR.ORDER_ROW_CURRENCY = #currency_id#
            </cfif>
            <cfif isdefined("attributes.member_type") and (attributes.member_type is 'PARTNER') and len(attributes.member_name) and len(attributes.company_id)>
                AND ORDERS.COMPANY_ID = #attributes.company_id#
            </cfif>
            <cfif isdefined("attributes.member_type") and (attributes.member_type is 'CONSUMER') and len(attributes.member_name) and len(attributes.consumer_id)>
                AND ORDERS.CONSUMER_ID = #attributes.consumer_id#
            </cfif>
            <cfif isdefined("attributes.order_employee_id") and len(attributes.order_employee_id) and len(attributes.order_employee)>
                AND ORDERS.ORDER_EMPLOYEE_ID = #attributes.order_employee_id#
            </cfif>
            <cfif len(attributes.sales_member_type) and (attributes.sales_member_type is 'partner') and len(attributes.sales_member_id) and len(attributes.sales_member_name)>
                AND ORDERS.SALES_PARTNER_ID = #attributes.sales_member_id#
            </cfif>
            <cfif len(attributes.sales_member_type) and (attributes.sales_member_type is 'consumer') and len(attributes.sales_member_id) and len(attributes.sales_member_name)>
                AND ORDERS.SALES_CONSUMER_ID = #attributes.sales_member_id#
            </cfif>
            <cfif isdefined('attributes.start_date') and len(attributes.start_date)>
                AND ORDERS.ORDER_DATE >= #attributes.start_date#
            </cfif>
            <cfif isdefined('attributes.finish_date') and len(attributes.finish_date)>
                AND ORDERS.ORDER_DATE <= #attributes.finish_date#
            </cfif>
            <cfif isdefined('attributes.order_stage') and len(attributes.order_stage)>
                AND ORDERS.ORDER_STAGE = #attributes.order_stage#
            </cfif>
            <cfif isdefined('attributes.sales_county') and len(attributes.sales_county)>
                AND ORDERS.ZONE_ID = #attributes.sales_county#
            </cfif>
            <cfif isdefined('attributes.sale_add_option') and len(attributes.sale_add_option)>
                AND ORDERS.SALES_ADD_OPTION_ID = #attributes.sale_add_option#
            </cfif>
            <cfif isdefined('attributes.branch_id') and len(attributes.branch_id)>
                AND ORDERS.FRM_BRANCH_ID = #attributes.branch_id#
            </cfif>
            <cfif isdefined('attributes.zone_id') and len(attributes.zone_id)>
                AND ORDERS.DELIVER_DEPT_ID IN 
                    (SELECT 
                        D.DEPARTMENT_ID 
                    FROM 
                        #dsn_alias#.DEPARTMENT D,
                        #dsn_alias#.BRANCH B
                    WHERE 
                        D.BRANCH_ID = B.BRANCH_ID AND
                        B.ZONE_ID = #attributes.zone_id#
                    )
            </cfif>
            <cfif session.ep.isBranchAuthorization>
                AND 
                (
                    DELIVER_DEPT_ID IN (SELECT DEPARTMENT_ID FROM #dsn_alias#.DEPARTMENT WHERE BRANCH_ID = #listgetat(session.ep.user_location,2,'-')#)
                    OR ISNULL(ORDERS.FRM_BRANCH_ID,0)= #listgetat(session.ep.user_location,2,'-')#
                )
            </cfif>
            AND ISNULL(IS_INSTALMENT,0)=<cfif isdefined("attributes.is_instalment")> 1<cfelse>0</cfif>
            <cfif x_control_ims eq 1 and session.ep.our_company_info.sales_zone_followup eq 1>
            AND
                (
                    (ORDERS.CONSUMER_ID IS NULL AND ORDERS.COMPANY_ID IS NULL) OR
                    (ORDERS.COMPANY_ID IN (#PreserveSingleQuotes(my_ims_comp_list)#)) OR
                    (ORDERS.CONSUMER_ID IN (#PreserveSingleQuotes(my_ims_cons_list)#))
                )	
            </cfif>
    </cfsavecontent>        
    <cfsavecontent variable="order">
            <cfif attributes.sort_type eq 1>
                ORDERS.DELIVERDATE ASC,
            <cfelseif attributes.sort_type eq 2>
                ORDERS.DELIVERDATE DESC,
            <cfelseif attributes.sort_type eq 3>
                ORDERS.ORDER_DATE ASC,
            <cfelseif attributes.sort_type eq 4>
                ORDERS.ORDER_DATE DESC,
            </cfif>
            ORDERS.ORDER_ID DESC
    </cfsavecontent>
    <cfsavecontent variable="startrow"><cfif isdefined("attributes.page") and len(attributes.page)>#attributes.page#<cfelse>1</cfif></cfsavecontent>
    <cfsavecontent variable="maxrows">#attributes.maxrows#</cfsavecontent>
</cfoutput>
<cfstoredproc procedure="utilPAGE" datasource="#dsn3#">
    <cfprocparam TYPE="IN" cfsqltype="cf_sql_text" value="#select#">
    <cfprocparam TYPE="IN" cfsqltype="cf_sql_text" value="#from#">
    <cfprocparam TYPE="IN" cfsqltype="cf_sql_text" value="#where#">
    <cfprocparam TYPE="IN" cfsqltype="cf_sql_text" value="#order#">
    <cfprocparam TYPE="IN" cfsqltype="cf_sql_integer" value="#startrow#">
    <cfprocparam TYPE="IN" cfsqltype="cf_sql_integer" value="#maxrows#">
    <cfprocresult name="RECORDCOUNT" resultset="1">
    <cfprocresult name="GET_ORDER_LIST" resultset="2">
</cfstoredproc>
