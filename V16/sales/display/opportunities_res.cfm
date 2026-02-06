<cf_xml_page_edit>
<cf_catalystHeader>
    
<cfscript>
    get_opportunities = createObject("component","V16.sales.cfc.opportunities_res");
    GET_OPP = get_opportunities.GET_OPP(opportunity_type_id:x_opp_cat_id);
    get_active = get_opportunities.GET_ACTIVE();
    get_total = get_opportunities.GET_TOTAL();
    total_income = 0;
    get_assignment_status = get_opportunities.GET_ASSIGNMENT_STATUS();
    get_opp_by_partner = get_opportunities.GET_OPP_BY_PARTNER();
    get_opp_count_by_partner = get_opportunities.GET_OPP_COUNT_BY_PARTNER();
    get_opp_by_employee = get_opportunities.GET_OPP_BY_EMPLOYEE();
    get_opp_count_by_employee = get_opportunities.GET_OPP_COUNT_BY_EMPLOYEE();
    get_opp_by_city = get_opportunities.GET_OPP_BY_CITY();
    get_opp_count_by_city = get_opportunities.GET_OPP_COUNT_BY_CITY();
    company_ids = listdeleteduplicates(valueList(get_opp_by_partner.COMPANY_ID));
    employee_ids = listdeleteduplicates(valueList(get_opp_by_employee.SALES_EMP_ID));
    city_ids = listdeleteduplicates(valueList(get_opp_by_city.CITY));
</cfscript>
<cfquery name="get_income_by_money_type" dbtype="query">
    SELECT COMPANY_ID,MONEY,SUM(INCOME) SUM_BY_MONEY FROM get_opp_by_partner GROUP BY COMPANY_ID,MONEY ORDER BY SUM_BY_MONEY
</cfquery>

<cfquery name="get_employee_income_by_money_type" dbtype="query">
    SELECT SALES_EMP_ID,MONEY,SUM(INCOME) SUM_BY_MONEY FROM get_opp_by_employee GROUP BY SALES_EMP_ID,MONEY ORDER BY SUM_BY_MONEY
</cfquery>

<cfquery name="get_city_income_by_money_type" dbtype="query">
    SELECT CITY,MONEY,SUM(INCOME) SUM_BY_MONEY FROM get_opp_by_city GROUP BY CITY,MONEY ORDER BY SUM_BY_MONEY
</cfquery>

<cfloop query="get_total">
    <cfset other_money = 0>
    <cfset other_money_to_currency = 0>
    <cfset currency_to_choice = 0>

    <cfset "income_by_#MONEY#" = TOTAL>
    <cfif MONEY eq x_money>
        <cfset total_income = total_income + Evaluate("income_by_#MONEY#")>
    <cfelse>
        <cfset get_currency = get_opportunities.get_other_money(money_type:get_total.MONEY)>
        <cfif session.ep.money eq x_money>
            <cfset other_money = TOTAL * get_currency.RATE2>
            <cfset total_income = total_income + other_money>
        <cfelse>
            <cfset get_other_money = get_opportunities.get_other_money(money_type:x_money)>
            <cfset other_money_to_currency = TOTAL * get_currency.RATE2>
            <cfset currency_to_choice = other_money_to_currency / get_other_money.RATE2>
            <cfset total_income = total_income + currency_to_choice>
        </cfif>
    </cfif>
</cfloop>
<style>
    .red{
        color: #E08283;
        font-weight:600;
    }
</style>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box>
        <cfoutput>
            <div class="ui-info-bottom">
                <div class="col col-3 col-md-3 col-sm-3 col-xs-12">
                    <div class="form-group">
                        <label><cf_get_lang dictionary_id='65781.Toplam Aktif Fırsat'>:</label> 
                        <label class="red">&nbsp#get_active.TOTAL_COUNT#</label> 
                    </div>
                </div>
                <div class="col col-3 col-md-3 col-sm-3 col-xs-12">
                    <div class="form-group">
                        <label><cf_get_lang dictionary_id='40296.Tahmini Gelir'>:</label>
                        <label class="red">&nbsp#TLFormat(total_income)# #x_money#</label>
                    </div>
                </div>
                <div class="col col-3 col-md-3 col-sm-3 col-xs-12">
                    <div class="form-group">
                        <label><cf_get_lang dictionary_id='65782.Ataması Yapılmamış'>:</label>
                        <label class="red">&nbsp#len(get_assignment_status.TOTAL_COUNT) ? get_assignment_status.TOTAL_COUNT : '0'#</label>
                    </div>
                </div>
            </div>
        </cfoutput>
    </cf_box>
</div>

<div class="col col-4 col-md-6 col-sm-12 col-xs-12">
    <cf_box title="#getLang('','İş Ortaklarına Göre Aktif Fırsatlar',65783)#">
        <div class="scrollContent scroll-x5">
            <cf_grid_list>
                <thead>
                    <tr>
                        <th width="30"><cf_get_lang dictionary_id='58577.Sıra'></th>
                        <th><cf_get_lang dictionary_id='49256.İş Ortağı'></th>
                        <th class="text-right"><cf_get_lang dictionary_id='58082.Adet'></th>
                        <th class="text-right"><cf_get_lang dictionary_id='40917.Tahmini Gelir'></th>
                        <th><cf_get_lang dictionary_id='57636.Birim'></th>
                    </tr>
                </thead>
                <tbody>
                    <cfoutput>
                        <cfloop list="#company_ids#" index="i" item="item">
                            <tr>
                                <td>#i#</td>
                                <td>
                                    <cfquery name="get_type" dbtype="query">
                                        SELECT TYPE FROM get_opp_by_partner WHERE COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#item#">
                                    </cfquery>
                                    <cfif get_type.TYPE eq 'PARTNER'>
                                        <cfquery name="get_name" datasource="#dsn#">
                                            SELECT ISNULL(C.NICKNAME,C.FULLNAME) NAME,C.COMPANY_ID CID FROM COMPANY C WHERE C.COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#item#">
                                        </cfquery>
                                    <cfelse>
                                        <cfquery name="get_name" datasource="#dsn#">
                                            SELECT CONSUMER_NAME + ' ' + CONSUMER_SURNAME NAME,CONSUMER_ID CID FROM CONSUMER WHERE CONSUMER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#item#">
                                        </cfquery>
                                    </cfif>
                                    <a href="#request.self#?fuseaction=sales.list_opportunity&sales_member_id=#get_name.CID#&sales_member_name=#get_name.NAME#&opp_status=1&sales_member_type=#get_type.TYPE#&is_filtre=1">#get_name.NAME#</a>
                                </td>
                                <td class="text-right">
                                    <cfquery name="get_count" dbtype="query">
                                        SELECT * FROM get_opp_count_by_partner WHERE COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#item#">
                                    </cfquery>
                                    #get_count.COUNT_OPP#
                                </td>
                                <td class="text-right" nowrap>
                                    <cfquery name="get_income_by_company" dbtype="query">
                                        SELECT * FROM get_income_by_money_type WHERE COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#item#">
                                    </cfquery>
                                    <cfset t_income_by_company = 0>
                                    <cfloop query="get_income_by_company">
                                        <cfif MONEY eq x_money>
                                            <cfset t_income_by_company = t_income_by_company + SUM_BY_MONEY>
                                        <cfelse>
                                            <cfset get_currency = get_opportunities.get_other_money(money_type:MONEY)>
                                            <cfif session.ep.money eq x_money>
                                                <cfset other_money = SUM_BY_MONEY * get_currency.RATE2>
                                                <cfset t_income_by_company = t_income_by_company + other_money>
                                            <cfelse>
                                                <cfset get_other_money = get_opportunities.get_other_money(money_type:x_money)>
                                                <cfset other_money_to_currency = SUM_BY_MONEY * get_currency.RATE2>
                                                <cfset currency_to_choice = other_money_to_currency / get_other_money.RATE2>
                                                <cfset t_income_by_company = t_income_by_company + currency_to_choice>
                                            </cfif>
                                        </cfif>
                                    </cfloop>
                                    #TLFormat(t_income_by_company)#
                                </td>
                                <td>#x_money#</td>
                            </tr>
                        </cfloop>
                </cfoutput>
                </tbody>
            </cf_grid_list>
        </div>
    </cf_box>
</div>

<div class="col col-4 col-md-6 col-sm-12 col-xs-12">
    <cf_box title="#getLang('','Çalışanlara Göre Aktif Fırsatlar',65784)#">
        <div class="scrollContent scroll-x5">
            <cf_grid_list>
                <thead>
                    <tr>
                        <th width="30"><cf_get_lang dictionary_id='58577.Sıra'></th>
                        <th><cf_get_lang dictionary_id='57576.Çalışan'></th>
                        <th class="text-right"><cf_get_lang dictionary_id='58082.Adet'></th>
                        <th id="aa" class="text-right"><cf_get_lang dictionary_id='40917.Tahmini Gelir'></th>
                        <th><cf_get_lang dictionary_id='57636.Birim'></th>
                    </tr>
                </thead>
                <tbody>
                    <cfoutput>
                        <cfloop list="#employee_ids#" index="j" item="empno">
                            <tr>
                                <td>#j#</td>
                                <td><a href="#request.self#?fuseaction=sales.list_opportunity&sales_emp_id=#empno#&sales_emp=#get_emp_info(empno,0,0)#&opp_status=1&is_filtre=1">#get_emp_info(empno,0,0)#</a></td>
                                <td class="text-right">
                                    <cfquery name="get_count" dbtype="query">
                                        SELECT * FROM get_opp_count_by_employee WHERE SALES_EMP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#empno#">
                                    </cfquery>
                                    #get_count.COUNT_OPP#
                                </td>
                                <td class="text-right" nowrap>
                                    <cfquery name="get_income_by_emp" dbtype="query">
                                        SELECT * FROM get_employee_income_by_money_type WHERE SALES_EMP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#empno#">
                                    </cfquery>
                                    <cfset t_income_by_employee = 0>
                                    <cfloop query="get_income_by_emp">
                                        <cfif MONEY eq x_money>
                                            <cfset t_income_by_employee = t_income_by_employee + SUM_BY_MONEY>
                                        <cfelse>
                                            <cfset get_currency = get_opportunities.get_other_money(money_type:MONEY)>
                                            <cfif session.ep.money eq x_money>
                                                <cfset other_money = SUM_BY_MONEY * get_currency.RATE2>
                                                <cfset t_income_by_employee = t_income_by_employee + other_money>
                                            <cfelse>
                                                <cfset get_other_money = get_opportunities.get_other_money(money_type:x_money)>
                                                <cfset other_money_to_currency = SUM_BY_MONEY * get_currency.RATE2>
                                                <cfset currency_to_choice = other_money_to_currency / get_other_money.RATE2>
                                                <cfset t_income_by_employee = t_income_by_employee + currency_to_choice>
                                            </cfif>
                                        </cfif>
                                    </cfloop>
                                    #TLFormat(t_income_by_employee)#
                                </td>
                                <td>#x_money#</td>
                            </tr>
                        </cfloop>
                    </cfoutput>
                </tbody>
            </cf_grid_list>
        </div>
    </cf_box>
</div>

<div class="col col-4 col-md-6 col-sm-12 col-xs-12">
    <cf_box title="#getLang('','Şehirlere Göre Aktif Fırsatlar',65785)#">
        <div class="scrollContent scroll-x5">
            <cf_grid_list>
                <thead>
                    <tr>
                        <th width="30"><cf_get_lang dictionary_id='58577.Sıra'></th>
                        <th><cf_get_lang dictionary_id='58608.İl'></th>
                        <th class="text-right"><cf_get_lang dictionary_id='58082.Adet'></th>
                        <th class="text-right"><cf_get_lang dictionary_id='40917.Tahmini Gelir'></th>
                        <th><cf_get_lang dictionary_id='57636.Birim'></th>
                    </tr>
                </thead>
                <tbody>
                    <cfoutput>
                        <cfloop list="#city_ids#" index="k" item="city_id">
                            <tr>
                                <td>#k#</td>
                                <td>
                                    <cfquery name="get_city" datasource="#dsn#">
                                        SELECT CITY_NAME FROM SETUP_CITY WHERE CITY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#city_id#">
                                    </cfquery>
                                    #get_city.CITY_NAME#
                                </td>
                                <td class="text-right">
                                    <cfquery name="get_count" dbtype="query">
                                        SELECT * FROM get_opp_count_by_city WHERE CITY = <cfqueryparam cfsqltype="cf_sql_integer" value="#city_id#">
                                    </cfquery>
                                    #get_count.COUNT_OPP#
                                </td>
                                <td class="text-right" nowrap>
                                    <cfquery name="get_income_by_city" dbtype="query">
                                        SELECT * FROM get_city_income_by_money_type WHERE CITY = <cfqueryparam cfsqltype="cf_sql_integer" value="#city_id#">
                                    </cfquery>
                                    <cfset t_income_by_city = 0>
                                    <cfloop query="get_income_by_city">
                                        <cfif MONEY eq x_money>
                                            <cfset t_income_by_city = t_income_by_city + SUM_BY_MONEY>
                                        <cfelse>
                                            <cfset get_currency = get_opportunities.get_other_money(money_type:MONEY)>
                                            <cfif session.ep.money eq x_money>
                                                <cfset other_money = SUM_BY_MONEY * get_currency.RATE2>
                                                <cfset t_income_by_city = t_income_by_city + other_money>
                                            <cfelse>
                                                <cfset get_other_money = get_opportunities.get_other_money(money_type:x_money)>
                                                <cfset other_money_to_currency = SUM_BY_MONEY * get_currency.RATE2>
                                                <cfset currency_to_choice = other_money_to_currency / get_other_money.RATE2>
                                                <cfset t_income_by_city = t_income_by_city + currency_to_choice>
                                            </cfif>
                                        </cfif>
                                    </cfloop>
                                    #TLFormat(t_income_by_city)#
                                </td>
                                <td>#x_money#</td>
                            </tr>
                        </cfloop>
                    </cfoutput>
                </tbody>
            </cf_grid_list>
        </div>
    </cf_box>
</div>