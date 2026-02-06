<cfparam name="attributes.consumer_id" default="">
<cfparam name="attributes.company_id" default="">
<cfparam name="attributes.company" default="">
<cfparam name="attributes.employee_id" default="">
<cfparam name="attributes.product_id" default="">
<cfparam name="attributes.product_name" default="">
<cfparam name="attributes.is_ship" default="1">
<cfparam name="attributes.date1" default="#dateformat(now(),'dd/mm/yyyy')#">
<cfparam name="attributes.date2" default="#dateformat(now(),'dd/mm/yyyy')#">
<cf_date tarih='attributes.date1'>
<cf_date tarih='attributes.date2'>
<cfset the_last_quantity = 0/>
<cfset the_last_amount_total = 0/>
<cfset total_late = 0/>
<cfset total_early = 0/>
<cfset total_real_time = 0/>
<cfset total_late_quantity = 0/>
<cfset total_early_quantity = 0/>
<cfset total_real_time_quantity = 0/>


<cfform name="rapor" method="post" action="">
    <cf_basket_form id="detail_order">
        <input type="hidden" name="is_form_submitted" id="is_form_submitted" value="1">
        <table>
            <tr>
                <td><cf_get_lang_main no='107.Cari Hesap'></td>
                <td><input type="hidden" name="consumer_id" id="consumer_id" <cfif len(attributes.company)>value="<cfoutput>#attributes.consumer_id#</cfoutput>"</cfif>>			
                    <input type="hidden" name="company_id" id="company_id" <cfif len(attributes.company)> value="<cfoutput>#attributes.company_id#</cfoutput>"</cfif>>
                    <input type="hidden" name="employee_id" id="employee_id" <cfif len(attributes.company)> value="<cfoutput>#attributes.employee_id#</cfoutput>"</cfif>>
                    <input type="text" name="company" id="company" onFocus="AutoComplete_Create('company','MEMBER_NAME,MEMBER_PARTNER_NAME','MEMBER_NAME,MEMBER_PARTNER_NAME','get_member_autocomplete','\'1,2,3\',\'<cfif fusebox.circuit is 'store'>1<cfelse>0</cfif>\',\'0\',\'0\',\'2\',\'0\',\'0\',\'1\'','COMPANY_ID,CONSUMER_ID,EMPLOYEE_ID,MEMBER_TYPE','company_id,consumer_id,employee_id,member_type','','3','250');" style="width:175px;" value="<cfif len(attributes.company) ><cfoutput>#attributes.company#</cfoutput></cfif>">
                    <a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_list_pars&select_list=1,2,3,9&field_comp_name=rapor.company&field_comp_id=rapor.company_id&field_consumer=rapor.consumer_id&field_member_name=rapor.company&field_emp_id=rapor.employee_id&field_name=rapor.company<cfif fusebox.circuit is 'store'>&is_store_module=1</cfif></cfoutput>&keyword='+encodeURIComponent(document.rapor.company.value),'list')"><img src="/images/plus_thin.gif" title="<cf_get_lang no='168.seçiniz'>" border="0" align="absmiddle"></a>
                </td>
                <td><cf_get_lang_main no='245.Ürün'></td>
                <td>
                    <input type="hidden" name="product_id" id="product_id" <cfif len(attributes.product_name)>value="<cfoutput>#attributes.product_id#</cfoutput>"</cfif>>
                    <input type="text" name="product_name" id="product_name" style="width:175px;" onFocus="AutoComplete_Create('product_name','PRODUCT_NAME','PRODUCT_NAME','get_product_autocomplete','0','PRODUCT_ID','product_id','','3','200');" autocomplete="off" value="<cfoutput>#attributes.product_name#</cfoutput>">
                    <a href="javascript://" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_product_names&product_id=rapor.product_id&field_name=rapor.product_name<cfif fusebox.circuit is 'store'>&is_store_module=1</cfif>','list');"><img src="/images/plus_thin.gif" align="absmiddle" border="0"></a>
                </td>
                <td><cf_get_lang_main no='1278.Tarih Aralığı'></td>
                <td>
                    <cfsavecontent variable="message"><cf_get_lang_main no ='370.Tarih Değerinizi Kontrol Ediniz'></cfsavecontent>
                    <cfinput value="#dateformat(attributes.date1,'dd/mm/yyyy')#" type="text" maxlength="10" name="date1" id="date1" style="width:65px;" required="yes" message="#message#" validate="eurodate">
                    <cf_wrk_date_image date_field="date1"> /
                    <cfinput value="#dateformat(attributes.date2,'dd/mm/yyyy')#"  type="text" maxlength="10" name="date2" id="date2" style="width:65px;" required="yes" message="#message#" validate="eurodate">
                    <cf_wrk_date_image date_field="date2">
                </td>
                <td>
                    <select name="is_ship" id="is_ship" onchange="ayarla_gizle_goster(this.value);">
                        <option value="1" <cfif isDefined("attributes.is_ship") and attributes.is_ship eq 1>selected</cfif>><cf_get_lang no="1570.İrsaliyelenmiş"></option>
                        <option value="2" <cfif isDefined("attributes.is_ship") and attributes.is_ship eq 2>selected</cfif>><cf_get_lang no="1571.İrsaliyelenmemiş"></option>
                    </select>
                </td>
                <td>
                    <select name="is_stage" id="is_stage" style="width:90px">
                        <option value=""><cf_get_lang_main no="296.Tümü"></option>
                        <option value="0" <cfif isDefined("attributes.is_stage") and attributes.is_stage eq 0>selected</cfif>><cf_get_lang_main no="2028.Aşama"></option>
                        <option value="-1" <cfif isDefined("attributes.is_stage") and attributes.is_stage eq -1>selected</cfif>><cf_get_lang_main no="1305.Açık"></option>
                        <option value="-2" <cfif isDefined("attributes.is_stage") and attributes.is_stage eq -2>selected</cfif>><cf_get_lang_main no="1948.Tedarik"></option>
                        <option value="-3" <cfif isDefined("attributes.is_stage") and attributes.is_stage eq -3>selected</cfif>><cf_get_lang_main no="1949.Kapatıldı"></option>
                        <option value="-4" <cfif isDefined("attributes.is_stage") and attributes.is_stage eq -4>selected</cfif>><cf_get_lang_main no="1950.Kısmi Üretim"></option>
                        <option value="-5" <cfif isDefined("attributes.is_stage") and attributes.is_stage eq -5>selected</cfif>><cf_get_lang_main no="44.Kısmi Üretim"></option>
                        <option value="-6" <cfif isDefined("attributes.is_stage") and attributes.is_stage eq -6>selected</cfif>><cf_get_lang_main no="1349.Sevk"></option>
                        <option value="-7" <cfif isDefined("attributes.is_stage") and attributes.is_stage eq -7>selected</cfif>><cf_get_lang_main no="1951.Eksik Teslimat"></option>
                        <option value="-8" <cfif isDefined("attributes.is_stage") and attributes.is_stage eq -8>selected</cfif>><cf_get_lang_main no="1952.Fazla Teslimat"></option>
                        <option value="-9" <cfif isDefined("attributes.is_stage") and attributes.is_stage eq -9>selected</cfif>><cf_get_lang_main no="1094.İptal"></option>
                        <option value="-10" <cfif isDefined("attributes.is_stage") and attributes.is_stage eq -10>selected</cfif>><cf_get_lang_main no="1211.Manuel"></option>
                    </select>
                </td>
                <cfif isDefined("attributes.is_ship") and attributes.is_ship neq 2>
                    <td id="remaining_area">
                        <select name="is_remaining" id="is_reamaining">
                            <option value="1" <cfif isDefined("is_remaining") and attributes.is_remaining eq 1>selected</cfif>><cf_get_lang no="1549.Kalan Miktar"></option>
                            <option value="2" <cfif isDefined("is_remaining") and attributes.is_remaining eq 2>selected</cfif>><cf_get_lang no="1549.Kalan Miktar"> (+)</option>
                            <option value="3" <cfif isDefined("is_remaining") and attributes.is_remaining eq 3>selected</cfif>><cf_get_lang no="1549.Kalan Miktar"> (-)</option>
                        </select>
                    </td>
                </cfif>
                <td><cf_wrk_search_button search_function='input_control()'></td>
            </tr>
        </table>
    </cf_basket_form>
</cfform>
<cf_wrk_html_table width="100%" class="detail_basket_list">
    <cf_wrk_html_thead>
        <cf_wrk_html_tr>
            <cf_wrk_html_th>#</cf_wrk_html_th>
            <cf_wrk_html_th><cf_get_lang_main no='107.Cari Hesap'></cf_wrk_html_th>
            <cf_wrk_html_th><cf_get_lang_main no='245.Ürün'></cf_wrk_html_th>
            <cf_wrk_html_th><cf_get_lang_main no='799.Sipariş No'></cf_wrk_html_th>
            <cf_wrk_html_th><cf_get_lang_main no='1704.Sipariş Tarihi'></cf_wrk_html_th>
            <cf_wrk_html_th><cf_get_lang_main no='233.Teslim Tarihi'></cf_wrk_html_th>
            <cf_wrk_html_th><cf_get_lang_main no='199.Sipariş'><cf_get_lang_main no='223.Miktar'></cf_wrk_html_th>
            <cf_wrk_html_th><cf_get_lang_main no='361.İrsaliye'><cf_get_lang_main no='223.Miktar'></cf_wrk_html_th>
			<cf_wrk_html_th><cf_get_lang_main no='361.İrsaliye'><cf_get_lang_main no='75.No'></cf_wrk_html_th>
			<cf_wrk_html_th><cf_get_lang no='325.Fiili Sevk Tarihi'></cf_wrk_html_th>
            <cf_wrk_html_th><cf_get_lang_main no='1032.Kalan'></cf_wrk_html_th>
        </cf_wrk_html_tr>
    </cf_wrk_html_thead>
    <cfif isDefined("is_form_submitted")>
        <cfquery name="get_order" datasource="#dsn3#">
            SELECT ORR.STOCK_ID
                ,SUM(ORR.QUANTITY) QUANTITY
                ,ORD.ORDER_HEAD
                ,ORD.ORDER_NUMBER
                ,ORR.SPECT_VAR_ID
                ,ORR.SPECT_VAR_NAME
                ,ORR.WRK_ROW_ID
                ,S.PRODUCT_NAME
                ,S.STOCK_CODE
                ,S.STOCK_CODE_2
                ,ORD.ORDER_ID
                ,C.FULLNAME
                ,ORD.ORDER_DATE
                ,ORD.DELIVERDATE
                ,ORR.ORDER_ROW_ID
                ,ORR.ORDER_ROW_CURRENCY
				,ORR.RESERVE_DATE

            FROM ORDER_ROW ORR
                ,ORDERS ORD
                ,STOCKS S
                ,#DSN#.COMPANY C
            WHERE 
                ORD.PURCHASE_SALES = <cfqueryparam cfsqltype="cf_sql_integer" value="0">
                <!--- AND ORD.ORDER_NUMBER NOT LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="PSA%"> --->
                AND ORD.ORDER_ZONE = <cfqueryparam cfsqltype="cf_sql_integer" value="0">
                AND ORD.ORDER_ID = ORR.ORDER_ID
                AND ORR.STOCK_ID = S.STOCK_ID
                <cfif len(attributes.COMPANY_ID)>
                    AND ORD.COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value = "#attributes.COMPANY_ID#">
                <cfelseif len(attributes.consumer_id)>
                    AND ORD.CONSUMER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value = "#attributes.consumer_id#">
                <cfelseif len(attributes.consumer_id)>
                    AND ORD.EMPLOYEE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value = "#attributes.employee_id#">
                </cfif>
                <cfif len(attributes.date1) and isdate(attributes.date1)>
                    AND ORD.ORDER_DATE >= <cfqueryparam cfsqltype='CF_SQL_DATE' value='#attributes.date1#'>
                </cfif>
                <cfif len(attributes.date2) and isdate(attributes.date2)>
                    AND ORD.ORDER_DATE < <cfqueryparam cfsqltype='CF_SQL_DATE' value='#DATEADD("d",1,attributes.date2)#'>
                </cfif>
                <cfif len(attributes.product_id)>
                    AND ORR.PRODUCT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value = "#attributes.product_id#">
                </cfif>
                <cfif isDefined("attributes.is_ship") and attributes.is_ship eq 1>
                    AND ORD.IS_PROCESSED = <cfqueryparam cfsqltype="cf_sql_integer" value="1">
                </cfif>
                AND C.COMPANY_ID = ORD.COMPANY_ID
                <cfif isDefined("attributes.is_stage") and attributes.is_stage neq ''>
                    <cfif isDefined("attributes.is_stage") and attributes.is_stage eq 0>
                        AND ORR.ORDER_ROW_CURRENCY NOT IN (-10,-3)
                    <cfelseif isDefined("attributes.is_stage") and attributes.is_stage neq 0>
                        AND ORR.ORDER_ROW_CURRENCY = <cfqueryparam cfsqltype="cf_sql_integer" value = "#attributes.is_stage#">
                    </cfif>
                </cfif>
            GROUP BY S.PRODUCT_NAME
                ,ORR.STOCK_ID
                ,ORD.ORDER_HEAD
                ,ORR.WRK_ROW_ID
                ,ORD.ORDER_NUMBER
                ,ORR.SPECT_VAR_ID
                ,ORR.SPECT_VAR_NAME
                ,S.STOCK_CODE
                ,S.STOCK_CODE_2
                ,ORD.ORDER_ID
                ,C.FULLNAME
                ,ORD.ORDER_DATE
                ,ORD.DELIVERDATE
                ,ORR.ORDER_ROW_ID
                ,ORR.ORDER_ROW_CURRENCY
				,ORR.RESERVE_DATE
            ORDER BY
                ORD.ORDER_DATE
                DESC
        </cfquery>
        <cf_wrk_html_tbody>
            <cfset n = 0/>
            <cfloop from="1" to="#get_order.recordCount#" index="i">
                <cfquery name="get_ship_det" datasource="#DSN2#">
                    SELECT
                        DISTINCT
                        STOCK_ID
                       ,S.SHIP_ID
                        ,S.SHIP_DATE
                        ,SR.SPECT_VAR_ID
                        
                        ,SUM(AMOUNT) AS IRS_AMOUNT
                        ,S.SHIP_NUMBER
                        ,S.SHIP_DATE
                        ,ISNULL(WRK_ROW_RELATION_ID,0) AS WRK_ROW_RELATION_ID
                        ,S.DELIVER_DATE
                        ,DATEDIFF(day, '#get_order.DELIVERDATE[i]#', S.DELIVER_DATE) AS DATEDIFF
                    FROM
                        SHIP S
                        ,SHIP_ROW SR
                    WHERE
                        SR.SHIP_ID=S.SHIP_ID AND
                        S.IS_WITH_SHIP = <cfqueryparam cfsqltype="cf_sql_integer" value = "0">  <!--- faturaya cekilmis siparislerden olusan siparisleri tekrar burda çekmemesi icin --->
                        AND SR.ROW_ORDER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value = "#get_order.order_id[i]#"> 
                        AND SR.STOCK_ID=<cfqueryparam cfsqltype="cf_sql_integer" value = "#get_order.stock_id[i]#">
                        AND WRK_ROW_RELATION_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value = "#get_order.WRK_ROW_ID[i]#">
                    GROUP BY
                        S.SHIP_ID,SR.SPECT_VAR_ID,STOCK_ID,S.SHIP_NUMBER,S.SHIP_DATE
                        ,ISNULL(WRK_ROW_RELATION_ID,0),S.DELIVER_DATE
                </cfquery>
                <!--- <cfdump var = "#get_ship_det#"/> --->
                <cfoutput>
                    <!--- <cf_wrk_html_tbody> --->
                        <cfif isDefined("attributes.is_ship") and attributes.is_ship eq 1>
                            <cfquery name = "get_total" dbtype="query">
                                SELECT SUM(IRS_AMOUNT) AS TOTAL FROM GET_SHIP_DET
                            </cfquery>
                            <cfif isDefined("attributes.is_remaining") and attributes.is_remaining eq 1>
                                <cfif get_ship_det.recordcount>
                                    <cfset n = n + 1>
                                    <cf_wrk_html_tr style="border: 2px solid black;">
                                        <cf_wrk_html_td>#n#</cf_wrk_html_td>
                                        <cf_wrk_html_td title="#get_order.FULLNAME[i]#">#left(get_order.FULLNAME[i],41)# <cfif len(get_order.FULLNAME[i]) gt 41>...</cfif></cf_wrk_html_td>
                                        <cf_wrk_html_td>
                                            #get_order.PRODUCT_NAME[i]#
                                        </cf_wrk_html_td>
                                        <cf_wrk_html_td>
                                            <a target="_blank" href="#request.self#?fuseaction=purchase.detail_order&order_id=#get_order.ORDER_ID[i]#">#get_order.ORDER_NUMBER[i]#
                                        </cf_wrk_html_td>
                                        <cf_wrk_html_td>
                                            #dateformat(get_order.ORDER_DATE[i],'dd/mm/yyyy')#
                                        </cf_wrk_html_td>
                                        <cf_wrk_html_td>
                                            #dateformat(get_order.DELIVERDATE[i],'dd/mm/yyyy')#
                                        </cf_wrk_html_td>
                                        <cf_wrk_html_td format="numeric">
                                            #tlformat(get_order.QUANTITY[i],0)#
                                            <cfif len(attributes.company_id) or len(attributes.consumer_id) or len(attributes.employee_id) or len(attributes.product_id)>
                                                <cfset the_last_quantity = the_last_quantity + get_order.QUANTITY[i]/>
                                            </cfif>
                                        </cf_wrk_html_td>
                                        <cf_wrk_html_td format="numeric">
                                            <cfset "IRS_AMOUNT_TOTAL_#i#" = 0>
                                            <cfloop from="1" to="#get_ship_det.recordcount#" index="j">
                                                <cfset "IRS_AMOUNT_TOTAL_#i#" = evaluate("IRS_AMOUNT_TOTAL_#i#") + get_ship_det.IRS_AMOUNT[j]/>
                                                #get_ship_det.IRS_AMOUNT[j]#
                                                <cfif get_ship_det.recordcount gt 1 and j neq get_ship_det.recordcount>
                                                    <hr/>
                                                </cfif>
                                            </cfloop><hr/><hr/>
                                            #tlformat(evaluate("IRS_AMOUNT_TOTAL_#i#"),0)#&nbsp;(<cf_get_lang_main no='1096.Satır'><cf_get_lang_main no='80.Toplam'>)
                                            <cfif len(attributes.company_id) or len(attributes.consumer_id) or len(attributes.employee_id) or len(attributes.product_id)>
                                                <cfset the_last_amount_total = the_last_amount_total + evaluate("IRS_AMOUNT_TOTAL_#i#")/>
                                            </cfif>
                                        </cf_wrk_html_td>
                                        <cf_wrk_html_td format="numeric">
                                            <cfloop from="1" to="#get_ship_det.recordcount#" index="j">
                                            <a target="_blank" href="#request.self#?fuseaction=stock.form_upd_purchase&ship_id=#get_ship_det.SHIP_ID[j]#">#get_ship_det.SHIP_NUMBER[j]#</a>
                                            <cfif get_ship_det.recordcount gt 1 and j neq get_ship_det.recordcount>
                                                    <hr/>
                                                </cfif>                                   
                                            </cfloop><b><hr/><hr/>
                                            &nbsp;
                                        </cf_wrk_html_td>
                                        <cf_wrk_html_td>
                                            <cfloop from="1" to="#get_ship_det.recordcount#" index="j">
                                                #dateformat(get_ship_det.DELIVER_DATE[j],'dd/mm/yyyy')# 
                                                (
                                                    <cfif GET_SHIP_DET.DATEDIFF[j] gt 0>
                                                        #GET_SHIP_DET.DATEDIFF[j]# Gün Gecikme
                                                        <cfset total_late = total_late + GET_SHIP_DET.DATEDIFF[j]/>
                                                        <cfset total_late_quantity = total_late_quantity + get_ship_det.IRS_AMOUNT[j]/>
                                                    <cfelseif GET_SHIP_DET.DATEDIFF[j] lt 0>
                                                        #(-1*GET_SHIP_DET.DATEDIFF[j])# Gün Erken
                                                        <cfset total_early = total_early + (-1*GET_SHIP_DET.DATEDIFF[j])/>
                                                        <cfset total_early_quantity = total_early_quantity + get_ship_det.IRS_AMOUNT[j]/>
                                                    <cfelseif GET_SHIP_DET.DATEDIFF[j] eq 0>
                                                        Zamanında
                                                        <cfset total_real_time = total_real_time + 1/>
                                                       <cfset total_real_time_quantity = total_real_time_quantity + get_ship_det.IRS_AMOUNT[j]/>
                                                    </cfif>
                                                )
                                                    <cfif get_ship_det.recordcount gt 1 and j neq get_ship_det.recordcount>
                                                        <hr/>
                                                    </cfif>                                    
                                            </cfloop><hr/><hr/>
                                            &nbsp;
                                        </cf_wrk_html_td>
                                        <cf_wrk_html_td format="numeric">
                                            #tlformat(get_order.QUANTITY[i]-evaluate("IRS_AMOUNT_TOTAL_#i#"),0)#
                                        </cf_wrk_html_td>
                                    </cf_wrk_html_tr>
                                </cfif>
                            <cfelseif isDefined("attributes.is_remaining") and attributes.is_remaining eq 2>
                                <cfif get_ship_det.recordcount and get_order.QUANTITY[i]-get_total.TOTAL gt 0>
                                    <cfset n = n + 1>
                                    <cf_wrk_html_tr style="border: 2px solid black;">
                                        <cf_wrk_html_td>#n#</cf_wrk_html_td>
                                        <cf_wrk_html_td title="#get_order.FULLNAME[i]#">#left(get_order.FULLNAME[i],41)# <cfif len(get_order.FULLNAME[i]) gt 41>...</cfif></cf_wrk_html_td>
                                        <cf_wrk_html_td>
                                            #get_order.PRODUCT_NAME[i]#
                                        </cf_wrk_html_td>
                                        <cf_wrk_html_td>
                                            <a target="_blank" href="#request.self#?fuseaction=purchase.detail_order&order_id=#get_order.ORDER_ID[i]#">#get_order.ORDER_NUMBER[i]#
                                        </cf_wrk_html_td>
                                        <cf_wrk_html_td>
                                            #dateformat(get_order.ORDER_DATE[i],'dd/mm/yyyy')#
                                        </cf_wrk_html_td>
                                        <cf_wrk_html_td>
                                            #dateformat(get_order.DELIVERDATE[i],'dd/mm/yyyy')#
                                        </cf_wrk_html_td>
                                        <cf_wrk_html_td format="numeric">
                                            #tlformat(get_order.QUANTITY[i],0)#
                                            <cfif len(attributes.company_id) or len(attributes.consumer_id) or len(attributes.employee_id) or len(attributes.product_id)>
                                                <cfset the_last_quantity = the_last_quantity + get_order.QUANTITY[i]/>
                                            </cfif>
                                        </cf_wrk_html_td>
                                        <cf_wrk_html_td format="numeric">
                                            <cfset "IRS_AMOUNT_TOTAL_#i#" = 0>
                                            <cfloop from="1" to="#get_ship_det.recordcount#" index="j">
                                                <cfset "IRS_AMOUNT_TOTAL_#i#" = evaluate("IRS_AMOUNT_TOTAL_#i#") + get_ship_det.IRS_AMOUNT[j]/>
                                                #get_ship_det.IRS_AMOUNT[j]#
                                                <cfif get_ship_det.recordcount gt 1 and j neq get_ship_det.recordcount>
                                                    <hr/>
                                                </cfif>
                                            </cfloop><hr/><hr/>
                                            #tlformat(evaluate("IRS_AMOUNT_TOTAL_#i#"),0)#&nbsp;(<cf_get_lang_main no='1096.Satır'><cf_get_lang_main no='80.Toplam'>)
                                            <cfif len(attributes.company_id) or len(attributes.consumer_id) or len(attributes.employee_id) or len(attributes.product_id)>
                                                <cfset the_last_amount_total = the_last_amount_total + evaluate("IRS_AMOUNT_TOTAL_#i#")/>
                                            </cfif>
                                        </cf_wrk_html_td>
                                        <cf_wrk_html_td format="numeric">
                                            <cfloop from="1" to="#get_ship_det.recordcount#" index="j">
                                            <a target="_blank" href="#request.self#?fuseaction=stock.form_upd_purchase&ship_id=#get_ship_det.SHIP_ID[j]#">#get_ship_det.SHIP_NUMBER[j]#</a>
                                            <cfif get_ship_det.recordcount gt 1 and j neq get_ship_det.recordcount>
                                                    <hr/>
                                                </cfif>                                   
                                            </cfloop><b><hr/><hr/>
                                            &nbsp;
                                        </cf_wrk_html_td>
                                        <cf_wrk_html_td>
                                            <cfloop from="1" to="#get_ship_det.recordcount#" index="j">
                                                #dateformat(get_ship_det.DELIVER_DATE[j],'dd/mm/yyyy')# 
                                                (
                                                    <cfif GET_SHIP_DET.DATEDIFF[j] gt 0>
                                                        #GET_SHIP_DET.DATEDIFF[j]# Gün Gecikme
                                                        <cfset total_late = total_late + GET_SHIP_DET.DATEDIFF[j]/>
                                                        <cfset total_late_quantity = total_late_quantity + get_ship_det.IRS_AMOUNT[j]/>
                                                    <cfelseif GET_SHIP_DET.DATEDIFF[j] lt 0>
                                                        #(-1*GET_SHIP_DET.DATEDIFF[j])# Gün Erken
                                                        <cfset total_early = total_early + (-1*GET_SHIP_DET.DATEDIFF[j])/>
                                                        <cfset total_early_quantity = total_early_quantity + get_ship_det.IRS_AMOUNT[j]/>
                                                    <cfelseif GET_SHIP_DET.DATEDIFF[j] eq 0>
                                                        Zamanında
                                                        <cfset total_real_time = total_real_time + 1/>
                                                       <cfset total_real_time_quantity = total_real_time_quantity + get_ship_det.IRS_AMOUNT[j]/>
                                                    </cfif>
                                                )
                                                    <cfif get_ship_det.recordcount gt 1 and j neq get_ship_det.recordcount>
                                                        <hr/>
                                                    </cfif>                                    
                                            </cfloop><hr/><hr/>
                                            &nbsp;
                                        </cf_wrk_html_td>
                                        <cf_wrk_html_td format="numeric">
                                            #tlformat(get_order.QUANTITY[i]-evaluate("IRS_AMOUNT_TOTAL_#i#"),0)#
                                        </cf_wrk_html_td>
                                    </cf_wrk_html_tr>
                                </cfif>
                            <cfelse>
                                <cfif get_ship_det.recordcount and get_order.QUANTITY[i]-get_total.TOTAL lt 0>
                                    <cfset n = n + 1>
                                    <cf_wrk_html_tr  style="border: 2px solid black;">
                                        <cf_wrk_html_td>#n#</cf_wrk_html_td>
                                        <cf_wrk_html_td title="#get_order.FULLNAME[i]#">#left(get_order.FULLNAME[i],41)# <cfif len(get_order.FULLNAME[i]) gt 41>...</cfif></cf_wrk_html_td>
                                        <cf_wrk_html_td>
                                            #get_order.PRODUCT_NAME[i]#
                                        </cf_wrk_html_td>
                                        <cf_wrk_html_td>
                                            <a target="_blank" href="#request.self#?fuseaction=purchase.detail_order&order_id=#get_order.ORDER_ID[i]#">#get_order.ORDER_NUMBER[i]#
                                        </cf_wrk_html_td>
                                        <cf_wrk_html_td>
                                            #dateformat(get_order.ORDER_DATE[i],'dd/mm/yyyy')#
                                        </cf_wrk_html_td>
                                        <cf_wrk_html_td>
                                            #dateformat(get_order.DELIVERDATE[i],'dd/mm/yyyy')#
                                        </cf_wrk_html_td>
                                        <cf_wrk_html_td format="numeric">
                                            #tlformat(get_order.QUANTITY[i],0)#
                                            <cfif len(attributes.company_id) or len(attributes.consumer_id) or len(attributes.employee_id) or len(attributes.product_id)>
                                                <cfset the_last_quantity = the_last_quantity + get_order.QUANTITY[i]/>
                                            </cfif>
                                        </cf_wrk_html_td>
                                        <cf_wrk_html_td>
                                            <cfset "IRS_AMOUNT_TOTAL_#i#" = 0>
                                            <cfloop from="1" to="#get_ship_det.recordcount#" index="j">
                                                <cfset "IRS_AMOUNT_TOTAL_#i#" = evaluate("IRS_AMOUNT_TOTAL_#i#") + get_ship_det.IRS_AMOUNT[j]/>
                                                #get_ship_det.IRS_AMOUNT[j]#
                                                <cfif get_ship_det.recordcount gt 1 and j neq get_ship_det.recordcount>
                                                    <hr/>
                                                </cfif>
                                            </cfloop><hr/><hr/>
                                            #tlformat(evaluate("IRS_AMOUNT_TOTAL_#i#"),0)#&nbsp;(<cf_get_lang_main no='1096.Satır'><cf_get_lang_main no='80.Toplam'>)
                                            <cfif len(attributes.company_id) or len(attributes.consumer_id) or len(attributes.employee_id) or len(attributes.product_id)>
                                                <cfset the_last_amount_total = the_last_amount_total + evaluate("IRS_AMOUNT_TOTAL_#i#")/>
                                            </cfif>
                                        </cf_wrk_html_td>
                                        <cf_wrk_html_td format="numeric">
                                            <cfloop from="1" to="#get_ship_det.recordcount#" index="j">
                                            <a target="_blank" href="#request.self#?fuseaction=stock.form_upd_purchase&ship_id=#get_ship_det.SHIP_ID[j]#">#get_ship_det.SHIP_NUMBER[j]#</a>
                                            <cfif get_ship_det.recordcount gt 1 and j neq get_ship_det.recordcount>
                                                    <hr/>
                                                </cfif>                                   
                                            </cfloop><b><hr/><hr/>
                                            &nbsp;
                                        </cf_wrk_html_td>
                                        <cf_wrk_html_td>
                                            <cfloop from="1" to="#get_ship_det.recordcount#" index="j">
                                                #dateformat(get_ship_det.DELIVER_DATE[j],'dd/mm/yyyy')# 
                                                (
                                                    <cfif GET_SHIP_DET.DATEDIFF[j] gt 0>
                                                        #GET_SHIP_DET.DATEDIFF[j]# Gün Gecikme
                                                        <cfset total_late = total_late + GET_SHIP_DET.DATEDIFF[j]/>
                                                        <cfset total_late_quantity = total_late_quantity + get_ship_det.IRS_AMOUNT[j]/>
                                                    <cfelseif GET_SHIP_DET.DATEDIFF[j] lt 0>
                                                        #(-1*GET_SHIP_DET.DATEDIFF[j])# Gün Erken
                                                        <cfset total_early = total_early + (-1*GET_SHIP_DET.DATEDIFF[j])/>
                                                        <cfset total_early_quantity = total_early_quantity + get_ship_det.IRS_AMOUNT[j]/>
                                                    <cfelseif GET_SHIP_DET.DATEDIFF[j] eq 0>
                                                        Zamanında
                                                        <cfset total_real_time = total_real_time + 1/>
                                                       <cfset total_real_time_quantity = total_real_time_quantity + get_ship_det.IRS_AMOUNT[j]/>
                                                    </cfif>
                                                )
                                                    <cfif get_ship_det.recordcount gt 1 and j neq get_ship_det.recordcount>
                                                        <hr/>
                                                    </cfif>                                    
                                            </cfloop><hr/><hr/>
                                            &nbsp;
                                        </cf_wrk_html_td>
                                        <cf_wrk_html_td format="numeric">
                                            #tlformat(get_order.QUANTITY[i]-evaluate("IRS_AMOUNT_TOTAL_#i#"),0)#
                                        </cf_wrk_html_td>
                                    </cf_wrk_html_tr>
                                </cfif>
                            </cfif>
                        <cfelseif isDefined("attributes.is_ship") and attributes.is_ship eq 2>
                            <cfif !get_ship_det.recordcount>
                                <cf_wrk_html_tr>
                                    <cfset n = n + 1>
                                    <cf_wrk_html_td>#n#</cf_wrk_html_td>
                                    <cf_wrk_html_td title="#get_order.FULLNAME[i]#">#left(get_order.FULLNAME[i],41)# <cfif len(get_order.FULLNAME[i]) gt 41>...</cfif></cf_wrk_html_td>
                                    <cf_wrk_html_td>
                                        #get_order.PRODUCT_NAME[i]#
                                    </cf_wrk_html_td>
                                    <cf_wrk_html_td>
                                        <a target="_blank" href="#request.self#?fuseaction=purchase.detail_order&order_id=#get_order.ORDER_ID[i]#">#get_order.ORDER_NUMBER[i]#
                                    </cf_wrk_html_td>
                                    <cf_wrk_html_td>
                                        #dateformat(get_order.ORDER_DATE[i],'dd/mm/yyyy')#
                                    </cf_wrk_html_td>
                                    <cf_wrk_html_td>
                                        #dateformat(get_order.DELIVERDATE[i],'dd/mm/yyyy')#
                                    </cf_wrk_html_td>
                                    <cf_wrk_html_td format="numeric">
                                        #tlformat(get_order.QUANTITY[i],0)#
                                        <cfif len(attributes.company_id) or len(attributes.consumer_id) or len(attributes.employee_id) or len(attributes.product_id)>
                                            <cfset the_last_quantity = the_last_quantity + get_order.QUANTITY[i]/>
                                        </cfif>
                                    </cf_wrk_html_td>
                                    <cf_wrk_html_td format="numeric">-
                                    </cf_wrk_html_td>
                                    <cf_wrk_html_td format="numeric">-
                                    </cf_wrk_html_td>
                                    <cf_wrk_html_td format="numeric">-
                                    </cf_wrk_html_td>
                                    <cf_wrk_html_td format="numeric">-
                                    </cf_wrk_html_td>
                                </cf_wrk_html_tr>
                            </cfif>
                        </cfif>
                    <!--- </cf_wrk_html_tbody> --->
                    
                </cfoutput>
            </cfloop>
            <cfif the_last_quantity neq 0>
                <cfoutput>
                    <cf_wrk_html_tr style="border: 2px solid black;">
                        <cf_wrk_html_td colspan="6" style="text-align:right;"> <b><cf_get_lang_main no='1601.Son'><cf_get_lang_main no='80.Toplam'></b></cf_wrk_html_td>
                        <cf_wrk_html_td>#tlformat(the_last_quantity,0)#</cf_wrk_html_td>
                        <cf_wrk_html_td><cfif attributes.is_ship eq 1>#tlformat(the_last_amount_total,0)#<cfelse>-</cfif></cf_wrk_html_td>
                        <cf_wrk_html_td style="text-align:right;">
                            <cfif len(attributes.company) and attributes.is_ship eq 1><b><cf_get_lang_main no='591.Performans'>:</b></cfif>
                        </cf_wrk_html_td>
                        <cf_wrk_html_td>
                            <cfif len(attributes.company) and attributes.is_ship eq 1>
                                #total_late#  <cf_get_lang_main no='78.Gün'><cf_get_lang no='936.Gecikme'> (%#tlformat((total_late_quantity*100)/the_last_amount_total,2)#)
                                <hr/>
                                #total_early# <cf_get_lang_main no='78.Gün'>Erken (%#tlformat((total_early_quantity*100)/the_last_amount_total,2)#)
                                <hr/>
                                #total_real_time# <cf_get_lang_main no='78.Gün'>Zamanında (%#tlformat((total_real_time_quantity*100)/the_last_amount_total,2)#)
                            <cfelse>
                                -
                            </cfif>
                        </cf_wrk_html_td>
                        <cf_wrk_html_td><cfif attributes.is_ship eq 1>#tlformat(the_last_quantity-the_last_amount_total,0)#<cfelse>-</cfif></cf_wrk_html_td>
                    </cf_wrk_html_tr>
                </cfoutput>
            </cfif>
        </cf_wrk_html_tbody>
    <cfelse>
        <cf_wrk_html_tbody>
            <cf_wrk_html_tr>
                <cf_wrk_html_td colspan="11"><cf_get_lang_main no = '289.Filtre Ediniz'></cf_wrk_html_td>
            </cf_wrk_html_tr>
        </cf_wrk_html_tbody>
    </cfif>
</cf_wrk_html_table>
<script>
    function input_control()
    {
        return true;
    }
    function ayarla_gizle_goster(id)
    {
        if(id==2)
        {
            document.getElementById('remaining_area').style.display='none';
        }
        else
        {
            document.getElementById('remaining_area').style.display='';
        }
    }
</script>