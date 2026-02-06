<CFTRY>
<cfquery name="get_basket_info" datasource="#dsn3#">
    SELECT PRICE_ROUND_NUMBER,* FROM SETUP_BASKET WHERE BASKET_ID = 6
</cfquery>
<cfif isdefined('attributes.form_varmi') and  isdefined('attributes.order_id') and len('attributes.order_id')>
	<cfquery name="get_order_detail" datasource="#dsn3#">
  		SELECT
        	ORDER_NUMBER,
            ORDER_HEAD,
            ORDER_STAGE
        FROM	
        	ORDERS
        WHERE
        	ORDER_ID = #attributes.order_id#    
    </cfquery>
    <cfquery name="get_order_detail_row" datasource="#dsn3#">
    	SELECT
        	ORW.*,
            (SELECT STOCK_CODE FROM STOCKS S WHERE S.STOCK_ID=ORW.STOCK_ID) STOCK_CODE,
            (SELECT MULTIPLIER FROM PRODUCT_UNIT P WHERE P.PRODUCT_ID=ORW.PRODUCT_ID AND IS_MAIN=1) MULTIPLER
        FROM
        	ORDER_ROW ORW
       WHERE
       		ORW.ORDER_ID=#attributes.order_id# 
      ORDER BY
		ORDER_ROW_ID      
    </cfquery>
	<cfif get_order_detail.recordcount>
        <cfquery name="get_stage" datasource="#dsn#">
            SELECT
                STAGE
            FROM
                PROCESS_TYPE_ROWS PTR
            WHERE
                PROCESS_ROW_ID =#get_order_detail.ORDER_STAGE#
        </cfquery>
        <cfquery name="get_unit_2" datasource="#dsn3#">
            SELECT 
            	PRODUCT_UNIT_ID,
                ADD_UNIT,
                MULTIPLIER,
                PRODUCT_ID,
                IS_MAIN  
           FROM 
           		PRODUCT_UNIT 
           WHERE 
           		PRODUCT_ID IN (#ListDeleteDuplicates(valuelist(get_order_detail_row.product_id,','))#) 
           AND PRODUCT_UNIT_STATUS = 1
        </cfquery>
        <cfquery name="get_money" datasource="#dsn3#">
            SELECT 
                MONEY_TYPE AS MONEY,
                RATE2
            FROM
                ORDER_MONEY
            WHERE
                ACTION_ID = #attributes.order_id#
        </cfquery>
    </cfif>
</cfif>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box>
        <cfform name="get_offer" id="get_offer" method="post" action="#request.self#?fuseaction=report.detail_report&event=det&report_id=#attributes.report_id#">
            <cf_box_search plus="0">
                <input name="form_varmi" id="form_varmi" value="1" type="hidden">
                <cfoutput>
                    <input type="hidden" name="order_id" id="order_id" value="<cfif isdefined("attributes.order_id")>#order_id#</cfif>" />
                    <div class="form-group">
                        <div class="input-group">
                            <input type="text" name="order_name" id="order_name" value="<cfif isdefined("attributes.order_id")>#get_order_detail.order_head#</cfif>" readonly/>
                            <span class="input-group-addon btnPointer icon-ellipsis" onClick="windowopen('#request.self#?fuseaction=objects.popup_orders_list_arnikon&field_id=get_offer.order_id&field_name=get_offer.order_name','list');"></span>
                        </div>
                    </div>
                    <div class="form-group">
                        <input type="submit" name="Ara">
                    </div>
                </cfoutput>
            </cf_box_search>
        </cfform>
    </cf_box>
    <cfif isdefined("attributes.form_varmi") and get_order_detail.recordcount>
        <cf_box>
            <cf_grid_list>
                <cfform name="save_offer" action="#request.self#?fuseaction=objects.emptypopup_update_order_rows" method="post">
                    <cfinput type="hidden" value="#attributes.order_id#" name="order_id">
                    <cfinput type="hidden" value="#attributes.report_id#" name="report_id">
                    <tr>
                        <td align="left">
                            <cf_grid_list>
                                <cfoutput>
                                    <tr class="color-header">
                                        <td class="form-title" style="width:60px">Sipariş</td>
                                        <td style="width:150px">#get_order_detail.ORDER_NUMBER#</td>
                                        <td class="form-title">Başlık</td>
                                        <td colspan="2">#get_order_detail.ORDER_HEAD#</td>
                                        <td class="form-title">Aşama</td>
                                        <td  colspan="5">#get_stage.stage#</td>
                                    </tr>
                                    <tr class="color-header">
                                        <td class="form-title">Stok Kodu</td>
                                        <td class="form-title">Ürün</td>
                                        <td class="form-title" style="text-align:right">Miktar</td>
                                        <td class="form-title" style="text-align:right">Birim</td>
                                        <td class="form-title" style="text-align:right">Çarpan</td>
                                        <td class="form-title" style="text-align:right">Miktar2</td>
                                        <td class="form-title" style="text-align:right">Birim2</td>
                                        <td class="form-title" style="text-align:right">Birim Fiyat</td>
                                        <td class="form-title" style="text-align:right">Birim 2 Fiyat</td>
                                        <td class="form-title" style="text-align:right">Para Birimi</td>
                                        <td class="form-title" style="text-align:right">Toplam</td>
                                    </tr>
                                    <cfset row=0>
                                    <cfif get_order_detail_row.recordcount>
                                        <cfloop query="get_order_detail_row">
                                            <input type="hidden" name="action_row_id#currentrow#" value="#ORDER_ROW_ID#" />
                                           <cfset row=row+1>
                                           <tr class="color-row">
                                               <td>#stock_code#</td>
                                               <td>#product_name#</td>
                                               <td style="text-align:right"><input type="text" class="box" id="miktar1#currentrow#" name="miktar1#currentrow#" style="width:50px" readonly="readonly" value="#tlformat(quantity,get_basket_info.basket_total_ROUND_NUMBER)#" /></td>
                                               <td>#unit#</td>
                                               <cfquery name="get_multipler" datasource="#dsn3#">
                                                   SELECT TOP 1
                                                       PU.PRODUCT_UNIT_ID,
                                                        P.PRODUCT_ID,
                                                        PU.ADD_UNIT,
                                                        PU.MULTIPLIER
                                                   FROM 
                                                        PRODUCT P,
                                                        PRODUCT_UNIT PU 
                                                   WHERE 
                                                        P.PRODUCT_ID = PU.PRODUCT_ID 
                                                        AND PU.PRODUCT_ID=#product_id#
                                                        AND PU.IS_MAIN=0
                                                   ORDER BY  
                                                        PU.PRODUCT_UNIT_ID
                                               </cfquery>
                                               <td style="text-align:right">
                                                   <cfset multi_ = wrk_round(get_multipler.multiplier,8,1)>
                                                   <input type="hidden" name="PRODUCT_UNIT_ID#currentrow#" value="#get_multipler.PRODUCT_UNIT_ID#"/>
                                                   <input type="text" class="box" id="carpan#currentrow#"  name="carpan#currentrow#" value="<cfif get_multipler.recordcount>#tlformat(multi_,8)#<cfelse>#tlformat(multipler,8)#</cfif>" style="width:80px" onchange="carpan(#currentrow#)"/>                                
                                               </td>
                                               <td style="text-align:right"><input type="text" name="miktar2#currentrow#" id="miktar2#currentrow#" value="#tlformat(amount2,5)#"  style="width:100px" class="box" onchange="miktar(#currentrow#)"/></td>
                                               <td style="text-align:right">
                                                    <cfquery name="get_add_unit" dbtype="query">
                                                        SELECT * FROM get_unit_2 WHERE PRODUCT_ID=#product_id#
                                                    </cfquery>
                                                    <select name="main_unit#currentrow#" id="main_unit#currentrow#" onchange="birim(#currentrow#)">
                                                        <cfloop query="get_add_unit">
                                                            <cfif get_multipler.add_unit eq add_unit>
                                                                <option value="#multiplier#;#add_unit#" <cfif get_multipler.add_unit eq add_unit>selected</cfif>>#add_unit#</option>
                                                            </cfif>
                                                        </cfloop>
                                                    </select>
                                                    <input type="hidden" name="add_unit2#currentrow#" id="add_unit2#currentrow#" value="<cfif get_multipler.recordcount>#get_multipler.add_unit#<cfelse>#unit#</cfif>" />
                                               </td>
                                               <td style="text-align:right"><input type="text" class="box" id="brfiyat1#currentrow#" name="brfiyat1#currentrow#" style="width:80px" readonly="readonly" value="#tlformat(price_other,get_basket_info.PRICE_ROUND_NUMBER)#" /><input type="hidden" class="box" id="brfiyattl1#currentrow#" name="brfiyattl1#currentrow#" style="width:80px" readonly="readonly" value="#tlformat(price,4)#" /></td>
                                               <td style="text-align:right"><input type="text" class="box" id="brfiyat2#currentrow#" name="brfiyat2#currentrow#" style="width:80px" value="#tlformat(price_other * quantity / amount2,get_basket_info.PRICE_ROUND_NUMBER)#" onchange="brfiyat2(#currentrow#)" /></td>
                                               <td style="text-align:right">
                                                   <select name="main_money#currentrow#" id="main_money#currentrow#">
                                                       <cfloop query="get_money">
                                                           <cfif money eq get_order_detail_row.other_money>
                                                                <option value="#money#;#rate2#" <cfif money eq get_order_detail_row.other_money>selected</cfif>>#money#</option>
                                                           </cfif>
                                                       </cfloop>
                                                   </select>
                                               </td>
                                               <td style="text-align:right"><input type="text" class="box" style="width:80px" id="toplam#currentrow#" name="toplam#currentrow#" readonly="readonly" value="#tlformat(OTHER_MONEY_VALUE,get_basket_info.basket_total_ROUND_NUMBER)#"/></td>
                                            </tr>
                                        </cfloop>
                                        <input type="hidden" id="type" name="type" value="1" />
                                        <input type="hidden" id="rows" name="rows" value="#row#" />
                                    </cfif>
                                </cfoutput>
                                <tr class="color-row">
                                    <td style="text-align:right" colspan="11">
                                        <input type="submit" name="Kaydet" value="Kaydet" onclick="control2()">
                                    </td>
                                </tr>
                            </cf_grid_list>
                        </td>
                    </tr>
                </cfform>
            </cf_grid_list>
        </cf_box>
    </cfif>
</div>

 <script type="text/javascript">
 ikinci_birim_round = 5;
 row_fiyat_carpan = <cfoutput>#get_basket_info.PRICE_ROUND_NUMBER#</cfoutput>;
 <cfif isdefined('get_order_detail_row')>
	for(i=1;i<=<cfoutput>#get_order_detail_row.recordcount#</cfoutput>;i++)
	{
		//carpan(i);
	}
 </cfif>
 	function birim(row)
	{
		x_birim = list_getat(document.getElementById('main_unit'+row).value,2,';');
		var multipler=list_getat(document.getElementById('main_unit'+row).value,1,';');
		document.getElementById('carpan'+row).value=commaSplit(multipler,4);
		document.getElementById('add_unit2'+row).value=x_birim;
		
		carpan(row);
	}
 	function control()
	{
		if(document.get_offer.order_id.value=="" && document.get_offer.order_name.value=="")
		{
			alert('Bir Sipariş Seçmelisiniz!');
			return false;
		}
	}
	function control2()
	{
		for(k=1;k<=document.getElementById('rows').value;k++)
		{
		
			document.getElementById('brfiyat1'+k).value= filterNum(document.getElementById('brfiyat1'+k).value,row_fiyat_carpan);
			document.getElementById('brfiyattl1'+k).value= filterNum(document.getElementById('brfiyattl1'+k).value,row_fiyat_carpan);
			document.getElementById('brfiyat2'+k).value=filterNum(document.getElementById('brfiyat2'+k).value,row_fiyat_carpan);
			document.getElementById('toplam'+k).value=filterNum(document.getElementById('toplam'+k).value,row_fiyat_carpan);
			document.getElementById('miktar2'+k).value=filterNum(document.getElementById('miktar2'+k).value,8);
			document.getElementById('miktar1'+k).value=filterNum(document.getElementById('miktar1'+k).value,4);
			document.getElementById('carpan'+k).value=filterNum(document.getElementById('carpan'+k).value,8);
		}
		return true;
	}
	function carpan(row)
	{
	
		document.getElementById('miktar2'+row).value=commaSplit(filterNum(document.getElementById('miktar1'+row).value,8)/filterNum(document.getElementById('carpan'+row).value,8),ikinci_birim_round);
		document.getElementById('brfiyat2'+row).value=commaSplit(filterNum(document.getElementById('brfiyat1'+row).value,4)*filterNum(document.getElementById('carpan'+row).value,8),4);
		document.getElementById('toplam'+row).value=commaSplit(filterNum(document.getElementById('miktar2'+row).value,4)*filterNum(document.getElementById('brfiyat2'+row).value,4),4);
	}
	function miktar(row)
	{
		document.getElementById('carpan'+row).value=commaSplit(filterNum(document.getElementById('miktar1'+row).value,4)/filterNum(document.getElementById('miktar2'+row).value,ikinci_birim_round),8);
		document.getElementById('brfiyat1'+row).value=commaSplit(filterNum(document.getElementById('brfiyat2'+row).value,row_fiyat_carpan)/filterNum(document.getElementById('carpan'+row).value,8),4);
		document.getElementById('toplam'+row).value=commaSplit(filterNum(document.getElementById('miktar1'+row).value,4)*filterNum(document.getElementById('brfiyat1'+row).value,row_fiyat_carpan),row_fiyat_carpan);
		rate2 = list_getat(document.getElementById('main_money'+row).value,2,';');
		document.getElementById('brfiyattl1'+row).value=commaSplit(filterNum(document.getElementById('brfiyat1'+row).value,row_fiyat_carpan)*rate2,row_fiyat_carpan);
	}
	function brfiyat2(row)
	{
		document.getElementById('brfiyat1'+row).value=commaSplit(filterNum(document.getElementById('brfiyat2'+row).value,row_fiyat_carpan)/filterNum(document.getElementById('carpan'+row).value,8),row_fiyat_carpan);
		rate2 = list_getat(document.getElementById('main_money'+row).value,2,';');
		document.getElementById('brfiyattl1'+row).value=commaSplit(filterNum(document.getElementById('brfiyat1'+row).value,row_fiyat_carpan)*rate2,row_fiyat_carpan);
		document.getElementById('toplam'+row).value=commaSplit(filterNum(document.getElementById('miktar1'+row).value,4)*filterNum(document.getElementById('brfiyat1'+row).value,row_fiyat_carpan),row_fiyat_carpan);
	}
 </script>
<CFCATCH type="any"><CFDUMP var="#CFCATCH#"></CFCATCH>
</cfTRY>
