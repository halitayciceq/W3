<cf_object_main_table>
    <cfif isdefined("xml_show_ship_adress") and xml_show_ship_adress eq 1>
        <!--- montaj adresi --->
        <cf_object_table column_width_list="100,150">
            <cfsavecontent variable="header_"><cf_get_lang dictionary_id='60563.Kurulum Adresi'></cfsavecontent>
            <cf_object_tr id="form_ul_ship_address" Title="#header_#" height="50">
                <cf_object_td type="text"><cf_get_lang dictionary_id='60563.Kurulum Adresi'></cf_object_td>
                <cf_object_td>
                    <textarea name="ship_address" id="ship_address" style="width:120px;height:40px;"><cfoutput><cfif isdefined("attributes.address")>#attributes.address#<cfelseif isdefined("get_addres")>#get_addres.address#</cfif></cfoutput></textarea> 
                    <a href="javascript://" onClick="add_adress(1);"><img border="0" name="imageField2" src="/images/plus_thin.gif" align="top" style="vertical-align:top;"></a>
                </cf_object_td>
            </cf_object_tr>
            <cfsavecontent variable="header_"><cf_get_lang dictionary_id='33340.Kurulum'>-<cf_get_lang_main no='60.Posta Kodu'></cfsavecontent>
            <cf_object_tr id="form_ul_ship_postcode" Title="#header_#">
                <cf_object_td type="text"><cf_get_lang_main no='60.Posta Kodu'></cf_object_td>
                <cf_object_td><input type="text" name="ship_postcode" id="ship_postcode" value="<cfoutput><cfif isdefined("attributes.postcode")>#attributes.postcode#<cfelseif isdefined("get_addres")>#get_addres.POSTCODE#</cfif></cfoutput>" maxlength="5" style="width:120px"></cf_object_td>
            </cf_object_tr>
            <cfsavecontent variable="header_"><cf_get_lang dictionary_id='33340.Kurulum'>-<cf_get_lang_main no='720.Semt'></cfsavecontent>
            <cf_object_tr id="form_ul_ship_semt" Title="#header_#">
                <cf_object_td type="text"><cf_get_lang_main no='720.Semt'></cf_object_td>
                <cf_object_td><input type="text" name="ship_semt" id="ship_semt" value="<cfoutput><cfif isdefined("attributes.semt")>#attributes.semt#<cfelseif isdefined("get_addres")>#get_addres.SEMT#</cfif></cfoutput>" maxlength="30" style="width:120px;"></cf_object_td>
            </cf_object_tr>
            <cfsavecontent variable="header_"><cf_get_lang dictionary_id='33340.Kurulum'>-<cf_get_lang_main no='1226.Ilçe'></cfsavecontent>
            <cf_object_tr id="form_ul_ship_county" Title="#header_#">
                <cf_object_td type="text"><cf_get_lang_main no='1226.Ilçe'></cf_object_td>
                <cf_object_td>
                    <input type="hidden" name="ship_county_id" id="ship_county_id" value="<cfoutput><cfif isdefined("attributes.county_id")>#attributes.county_id#<cfelseif isdefined("get_addres")>#get_addres.COUNTY#</cfif></cfoutput>">
                    <input type="text" name="ship_county" id="ship_county" value="<cfoutput><cfif isdefined("attributes.county")>#attributes.county#<cfelseif isdefined("get_addres")><cfif isdefined('get_county_detail')>#get_county_detail.COUNTY_NAME#</cfif></cfif></cfoutput>" style="width:120px;">					  
                </cf_object_td>
            </cf_object_tr>
            <cfsavecontent variable="header_"><cf_get_lang dictionary_id='33340.Kurulum'>-<cf_get_lang_main no='559.Şehir'></cfsavecontent>
            <cf_object_tr id="form_ul_ship_city" Title="#header_#">
                <cf_object_td type="text"><cf_get_lang_main no='559.Şehir'></cf_object_td>
                <cf_object_td>
                    <input type="hidden" name="ship_city_id" id="ship_city_id" value="<cfoutput><cfif isdefined("attributes.city_id")>#attributes.city_id#<cfelseif isdefined("get_addres")>#get_addres.CITY#</cfif></cfoutput>">          
                    <input type="text" name="ship_city" id="ship_city" value="<cfoutput><cfif isdefined("attributes.city")>#attributes.city#<cfelseif isdefined("get_addres")><cfif isdefined('get_city_detail')>#get_city_detail.CITY_NAME#</cfif></cfif></cfoutput>" style="width:120px;">                     
                </cf_object_td>
            </cf_object_tr>
            <cfsavecontent variable="header_"><cf_get_lang dictionary_id='33340.Kurulum'>-<cf_get_lang_main no='807.Ülke'></cfsavecontent>
            <cf_object_tr id="form_ul_ship_country" Title="#header_#">
                <cf_object_td type="text"><cf_get_lang_main no='807.Ülke'></cf_object_td>
                <cf_object_td>
                    <input type="hidden" name="ship_country_id" id="ship_country_id" value="<cfoutput><cfif isdefined("attributes.country_id")>#attributes.country_id#<cfelseif isdefined("get_addres")>#get_addres.COUNTRY#</cfif></cfoutput>">          
                    <input type="text" name="ship_country" id="ship_country" value="<cfoutput><cfif isdefined("attributes.country")>#attributes.country#<cfelseif isdefined("get_addres")><cfif isdefined('get_country_detail')>#get_country_detail.COUNTRY_NAME#</cfif></cfif></cfoutput>" style="width:120px;">
                </cf_object_td>
            </cf_object_tr>
            <cfsavecontent variable="header_"><cf_get_lang_main no='247.Satış Bölgesi'></cfsavecontent>
            <cf_object_tr id="form_ul_ship_sales_zones" Title="#header_#">
                <cf_object_td type="text"><cf_get_lang_main no='247.Satış Bölgesi'></cf_object_td>
                <cf_object_td>
                    <select name="ship_sales_zone_id" id="ship_sales_zone_id" style="width:120px;">
                        <option value=""><cf_get_lang_main no='322.Seçiniz'></option>
                        <cfoutput query="GET_SALES_ZONES">
                            <option value="#SZ_ID#" <cfif isdefined("get_addres") and len(get_addres.SZ_ID) and get_addres.SZ_ID eq sz_id>selected<cfelseif isdefined("attributes.ship_sz_id") and attributes.ship_sz_id eq sz_id>selected<cfelseif isdefined("attributes.sz_id") and attributes.sz_id eq sz_id>selected</cfif>>#SZ_NAME# <cfif is_active eq 0>(Pasif)</cfif></option>
                        </cfoutput>
                    </select>                                            
                </cf_object_td>
            </cf_object_tr>
            <cfsavecontent variable="header_"><cf_get_lang dictionary_id='33340.Kurulum'>-<cf_get_lang_main no='1137.Koordinatlar'></cfsavecontent>
            <cf_object_tr id="form_ul_ship_coordinate_1" Title="#header_#">
                <cf_object_td type="text"><cf_get_lang_main no='1137.Koordinatlar'></cf_object_td>
                <cf_object_td>
                    <cf_get_lang_main no='1141.E'><input type="text" name="ship_coordinate_1" id="ship_coordinate_1" value="<cfoutput><cfif isdefined("attributes.coordinate_1")>#attributes.coordinate_1#<cfelseif isdefined("get_addres") and len(get_addres.coordinate_1)>#get_addres.coordinate_1#</cfif></cfoutput>" maxlength="10" style="width:48px; text-align:right">
                    <cf_get_lang_main no='1179.B'><input type="text" name="ship_coordinate_2" id="ship_coordinate_2" value="<cfoutput><cfif isdefined("attributes.coordinate_2")>#attributes.coordinate_2#<cfelseif isdefined("get_addres") and len(get_addres.coordinate_2)>#get_addres.coordinate_2#</cfif></cfoutput>" maxlength="10" style="width:48px; text-align:right">
                </cf_object_td>
            </cf_object_tr>
        </cf_object_table>
    <cfelse>
        <input type="hidden" name="ship_address" id="ship_address" style="width:120px;height:40px;" value="<cfoutput><cfif isdefined("attributes.address")>#attributes.address#<cfelseif isdefined("get_addres")>#get_addres.address#</cfif></cfoutput> ">
        <input type="hidden" name="ship_postcode" id="ship_postcode" value="<cfoutput><cfif isdefined("attributes.postcode")>#attributes.postcode#<cfelseif isdefined("get_addres")>#get_addres.POSTCODE#</cfif></cfoutput>" maxlength="5" style="width:120px">
        <input type="hidden" name="ship_semt" id="ship_semt" value="<cfoutput><cfif isdefined("attributes.semt")>#attributes.semt#<cfelseif isdefined("get_addres")>#get_addres.SEMT#</cfif></cfoutput>" maxlength="30" style="width:120px;">
        <input type="hidden" name="ship_county_id" id="ship_county_id" value="<cfoutput><cfif isdefined("attributes.county_id")>#attributes.county_id#<cfelseif isdefined("get_addres")>#get_addres.COUNTY#</cfif></cfoutput>">
        <input type="hidden" name="ship_county" id="ship_county" value="<cfoutput><cfif isdefined("attributes.county")>#attributes.county#<cfelseif isdefined("get_addres")><cfif isdefined('get_county_detail')>#get_county_detail.COUNTY_NAME#</cfif></cfif></cfoutput>" style="width:120px;">					  
        <input type="hidden" name="ship_city_id" id="ship_city_id" value="<cfoutput><cfif isdefined("attributes.city_id")>#attributes.city_id#<cfelseif isdefined("get_addres")>#get_addres.CITY#</cfif></cfoutput>">          
        <input type="hidden" name="ship_city" id="ship_city" value="<cfoutput><cfif isdefined("attributes.city")>#attributes.city#<cfelseif isdefined("get_addres")><cfif isdefined('get_city_detail')>#get_city_detail.CITY_NAME#</cfif></cfif></cfoutput>" style="width:120px;">                     
        <input type="hidden" name="ship_country_id" id="ship_country_id" value="<cfoutput><cfif isdefined("attributes.country_id")>#attributes.country_id#<cfelseif isdefined("get_addres")>#get_addres.COUNTRY#</cfif></cfoutput>">          
        <input type="hidden" name="ship_country" id="ship_country" value="<cfoutput><cfif isdefined("attributes.country")>#attributes.country#<cfelseif isdefined("get_addres")><cfif isdefined('get_country_detail')>#get_country_detail.COUNTRY_NAME#</cfif></cfif></cfoutput>" style="width:120px;">
        <input type="hidden" name="ship_sales_zone_id" id="ship_sales_zone_id" value="<cfoutput><cfif isdefined("attributes.ship_sales_zone_id")>#attributes.ship_sales_zone_id#<cfelseif isdefined("get_addres") and len(get_addres.sz_id)>#get_addres.sz_id#</cfif></cfoutput>">
        <input type="hidden" name="ship_coordinate_1" id="ship_coordinate_1" value="<cfoutput><cfif isdefined("attributes.coordinate_1")>#attributes.coordinate_1#<cfelseif isdefined("get_addres") and len(get_addres.coordinate_1)>#get_addres.coordinate_1#</cfif></cfoutput>">
        <input type="hidden" name="ship_coordinate_2" id="ship_coordinate_2" value="<cfoutput><cfif isdefined("attributes.coordinate_2")>#attributes.coordinate_2#<cfelseif isdefined("get_addres") and len(get_addres.coordinate_2)>#get_addres.coordinate_2#</cfif></cfoutput>">
    </cfif>
    <cfif isdefined("xml_show_invoice_adress") and xml_show_invoice_adress eq 1>
        <!--- fatura adresi --->
        <!--- Üye tarafında Fatura adresi işaretli şube adresini getirsin diye--->
        <cfif isdefined("get_addres")>
        <cfoutput query="get_addres">
            <cfif is_invoice_address eq 1>
                <cfset invoice_address = ADDRESS>
                <cfset invoice_postcode = POSTCODE>
                <cfset invoice_semt = semt>
                <cfset invoice_county = county>
                <cfset invoice_city = city>
                <cfset invoice_country = country>
                <cfset invoice_sz_id = sz_id>
                <cfset invoice_coordinate_1 = coordinate_1>
                <cfset invoice_coordinate_2 = coordinate_2>
            </cfif>
        </cfoutput>
        </cfif>
        <cf_object_table column_width_list="100,150">
            <cfsavecontent variable="header_"><cf_get_lang no='283.Fatura Adresi'></cfsavecontent>
            <cf_object_tr id="form_ul_invoice_address" Title="#header_#" height="50">
                <cf_object_td type="text"><cf_get_lang no='283.Fatura Adresi'></cf_object_td>
                <cf_object_td>
                    <textarea name="invoice_address" id="invoice_address" readonly style="width:120px;height:40px;"><cfoutput><cfif isdefined("invoice_address")>#invoice_address#<cfelseif isdefined("attributes.address")>#attributes.address#</cfif></cfoutput></textarea>
                    <a href="javascript://" onClick="add_adress(2);"><img src="/images/plus_thin.gif" border="0" align="top" style="vertical-align:top;"></a>
                </cf_object_td>
            </cf_object_tr>
            <cfsavecontent variable="header_"><cf_get_lang_main no='29.Fatura'>-<cf_get_lang_main no='60.Posta Kodu'></cfsavecontent>
            <cf_object_tr id="form_ul_invoice_postcode" Title="#header_#">
                <cf_object_td type="text"><cf_get_lang_main no='60.Posta Kodu'></cf_object_td>
                <cf_object_td><input type="text" name="invoice_postcode" id="invoice_postcode" value="<cfoutput><cfif isdefined("invoice_postcode")>#invoice_postcode#<cfelseif isdefined("attributes.postcode")>#attributes.postcode#</cfif></cfoutput>" maxlength="5" readonly style="width:120px"></cf_object_td>
            </cf_object_tr>
            <cfsavecontent variable="header_"><cf_get_lang_main no='29.Fatura'>-<cf_get_lang_main no='720.Semt'></cfsavecontent>
            <cf_object_tr id="form_ul_invoice_semt" Title="#header_#">
                <cf_object_td type="text"><cf_get_lang_main no='720.Semt'></cf_object_td>
                <cf_object_td><input type="text" name="invoice_semt" id="invoice_semt" value="<cfoutput><cfif isdefined("invoice_semt")>#invoice_semt#<cfelseif isdefined("attributes.semt")>#attributes.semt#</cfif></cfoutput>" maxlength="30" readonly style="width:120px;"></cf_object_td>
            </cf_object_tr>
            <cfsavecontent variable="header_"><cf_get_lang_main no='29.Fatura'>-<cf_get_lang_main no='1226.Ilçe'></cfsavecontent>
            <cf_object_tr id="form_ul_invoice_county" Title="#header_#">
                <cf_object_td type="text"><cf_get_lang_main no='1226.Ilçe'></cf_object_td>
                <cf_object_td>
                    <input type="hidden" name="invoice_county_id" id="invoice_county_id" value="<cfoutput><cfif isdefined("invoice_county")>#invoice_county#<cfelseif isdefined("attributes.county_id")>#attributes.county_id#</cfif></cfoutput>">
                    <input type="text" name="invoice_county" id="invoice_county" value="<cfoutput><cfif isdefined("invoice_county_name")>#invoice_county_name#<cfelseif isdefined("attributes.county")>#attributes.county#</cfif></cfoutput>" readonly style="width:120px;">
                </cf_object_td>
            </cf_object_tr>
            <cfsavecontent variable="header_"><cf_get_lang_main no='29.Fatura'>-<cf_get_lang_main no='559.Şehir'></cfsavecontent>
            <cf_object_tr id="form_ul_invoice_city" Title="#header_#">
                <cf_object_td type="text"><cf_get_lang_main no='559.Şehir'></cf_object_td>
                <cf_object_td>
                    <input type="hidden" name="invoice_city_id" id="invoice_city_id" value="<cfoutput><cfif isdefined("invoice_city")>#invoice_city#<cfelseif isdefined("attributes.city_id")>#attributes.city_id#</cfif></cfoutput>">          
                    <input type="text" name="invoice_city" id="invoice_city" value="<cfoutput><cfif isdefined("invoice_city_name")>#invoice_city_name#<cfelseif isdefined("attributes.city")>#attributes.city#</cfif></cfoutput>" readonly style="width:120px;"> 
                </cf_object_td>
            </cf_object_tr>
            <cfsavecontent variable="header_"><cf_get_lang_main no='29.Fatura'>-<cf_get_lang_main no='807.Ülke'></cfsavecontent>
            <cf_object_tr id="form_ul_invoice_country" Title="#header_#">
                <cf_object_td type="text"><cf_get_lang_main no='807.Ülke'></cf_object_td>
                <cf_object_td>
                    <input type="hidden" name="invoice_country_id" id="invoice_country_id" value="<cfoutput><cfif isdefined("invoice_country")>#invoice_country#<cfelseif isdefined("attributes.country_id")>#attributes.country_id#</cfif></cfoutput>">        
                    <input type="text" name="invoice_country" id="invoice_country" value="<cfoutput><cfif isdefined("invoice_country_name")>#invoice_country_name#<cfelseif isdefined("attributes.country")>#attributes.country#</cfif></cfoutput>" readonly style="width:120px;">					
                </cf_object_td>
            </cf_object_tr>
            <cfsavecontent variable="header_"><cf_get_lang_main no='247.Satış Bölgesi'></cfsavecontent>
            <cf_object_tr id="form_ul_invoice_sales_zones" Title="#header_#">
                <cf_object_td type="text"><cf_get_lang_main no='247.Satış Bölgesi'></cf_object_td>
                <cf_object_td>
                    <select name="invoice_sales_zone_id" id="invoice_sales_zone_id" style="width:120px;">
                        <option value=""><cf_get_lang_main no='322.Seçiniz'></option>
                        <cfoutput query="GET_SALES_ZONES">
                            <option value="#SZ_ID#" <cfif isdefined("invoice_sz_id") and len(invoice_sz_id) and invoice_sz_id eq sz_id>selected<cfelseif isdefined("attributes.invoice_sz_id") and attributes.invoice_sz_id eq sz_id>selected<cfelseif isdefined("attributes.sz_id") and attributes.sz_id eq sz_id>selected</cfif>>#SZ_NAME# <cfif is_active eq 0>(Pasif)</cfif></option>
                        </cfoutput>
                    </select>                                            
                </cf_object_td>
            </cf_object_tr>
            <cfsavecontent variable="header_"><cf_get_lang_main no='29.Fatura'>-<cf_get_lang_main no='1137.Koordinatlar'></cfsavecontent>
            <cf_object_tr id="form_ul_invoice_coordinate_1" Title="#header_#">
                <cf_object_td type="text"><cf_get_lang_main no='1137.Koordinatlar'></cf_object_td>
                <cf_object_td>
                    <cf_get_lang_main no='1141.E'><input type="text" name="invoice_coordinate_1" id="invoice_coordinate_1" value="<cfoutput><cfif isdefined("invoice_coordinate_1")>#invoice_coordinate_1#<cfelseif isdefined("attributes.coordinate_1")>#attributes.coordinate_1#</cfif></cfoutput>" maxlength="10" style="width:48px;text-align:right">
                    <cf_get_lang_main no='1179.B'><input type="text" name="invoice_coordinate_2" id="invoice_coordinate_2" value="<cfoutput><cfif isdefined("invoice_coordinate_2")>#invoice_coordinate_2#<cfelseif isdefined("attributes.coordinate_2")>#attributes.coordinate_2#</cfif></cfoutput>" maxlength="10" style="width:48px;text-align:right">
                </cf_object_td>
            </cf_object_tr>
        </cf_object_table>
    <cfelse>
        <input type="hidden" name="invoice_address" id="invoice_address" readonly style="width:120px;height:40px;" value="<cfoutput><cfif isdefined("invoice_address")>#invoice_address#<cfelseif isdefined("attributes.address")>#attributes.address#</cfif></cfoutput>">
        <input type="hidden" name="invoice_postcode" id="invoice_postcode" value="<cfoutput><cfif isdefined("invoice_postcode")>#invoice_postcode#<cfelseif isdefined("attributes.postcode")>#attributes.postcode#</cfif></cfoutput>" maxlength="5" readonly style="width:120px">
        <input type="hidden" name="invoice_semt" id="invoice_semt" value="<cfoutput><cfif isdefined("invoice_semt")>#invoice_semt#<cfelseif isdefined("attributes.semt")>#attributes.semt#</cfif></cfoutput>" maxlength="30" readonly style="width:120px;">
        <input type="hidden" name="invoice_county_id" id="invoice_county_id" value="<cfoutput><cfif isdefined("invoice_county")>#invoice_county#<cfelseif isdefined("attributes.county_id")>#attributes.county_id#</cfif></cfoutput>">
        <input type="hidden" name="invoice_county" id="invoice_county" value="<cfoutput><cfif isdefined("invoice_county_name")>#invoice_county_name#<cfelseif isdefined("attributes.county")>#attributes.county#</cfif></cfoutput>" readonly style="width:120px;">
        <input type="hidden" name="invoice_city_id" id="invoice_city_id" value="<cfoutput><cfif isdefined("invoice_city")>#invoice_city#<cfelseif isdefined("attributes.city_id")>#attributes.city_id#</cfif></cfoutput>">          
        <input type="hidden" name="invoice_city" id="invoice_city" value="<cfoutput><cfif isdefined("invoice_city_name")>#invoice_city_name#<cfelseif isdefined("attributes.city")>#attributes.city#</cfif></cfoutput>" readonly style="width:120px;"> 
        <input type="hidden" name="invoice_country_id" id="invoice_country_id" value="<cfoutput><cfif isdefined("invoice_country")>#invoice_country#<cfelseif isdefined("attributes.country_id")>#attributes.country_id#</cfif></cfoutput>">        
        <input type="hidden" name="invoice_country" id="invoice_country" value="<cfoutput><cfif isdefined("invoice_country_name")>#invoice_country_name#<cfelseif isdefined("attributes.country")>#attributes.country#</cfif></cfoutput>" readonly style="width:120px;">					
        <input type="hidden" name="invoice_sales_zone_id" id="invoice_sales_zone_id" value="<cfoutput><cfif isdefined("invoice_sz_id")>#invoice_sz_id#<cfelseif isdefined("attributes.invoice_sales_zone_id")>#attributes.invoice_sales_zone_id#</cfif></cfoutput>">
        <input type="hidden" name="invoice_coordinate_1" id="invoice_coordinate_1" value="<cfoutput><cfif isdefined("invoice_coordinate_1")>#invoice_coordinate_1#<cfelseif isdefined("attributes.coordinate_1")>#attributes.coordinate_1#</cfif></cfoutput>">
        <input type="hidden" name="invoice_coordinate_2" id="invoice_coordinate_2" value="<cfoutput><cfif isdefined("invoice_coordinate_2")>#invoice_coordinate_2#<cfelseif isdefined("attributes.coordinate_2")>#attributes.coordinate_2#</cfif></cfoutput>">
    </cfif>
    <cfif isdefined("xml_show_contact_adress") and xml_show_contact_adress eq 1>
        <!--- irtibat adresi --->
        <cf_object_table column_width_list="100,150">
            <cfsavecontent variable="header_"><cf_get_lang no='284.Irtibat Adresi'></cfsavecontent>
            <cf_object_tr id="form_ul_contact_address" Title="#header_#" height="50">
                <cf_object_td type="text"><cf_get_lang no='284.Irtibat Adresi'></cf_object_td>
                <cf_object_td>
                    <textarea name="contact_address" id="contact_address" readonly style="width:120px;height:40px;"><cfoutput><cfif isdefined("attributes.address")>#attributes.address#<cfelseif isdefined("get_addres")>#get_addres.address#</cfif></cfoutput></textarea>
                    <a href="javascript://" onClick="add_adress(3);"><img src="/images/plus_thin.gif" border="0" align="top" style="vertical-align:top;"></a>
                </cf_object_td>
            </cf_object_tr>
            <cfsavecontent variable="header_"><cf_get_lang_main no='1959.Irtibat'>-<cf_get_lang_main no='60.Posta Kodu'></cfsavecontent>
            <cf_object_tr id="form_ul_contact_postcode" Title="#header_#">
                <cf_object_td type="text"><cf_get_lang_main no='60.Posta Kodu'></cf_object_td>
                <cf_object_td><input type="text" name="contact_postcode" id="contact_postcode" value="<cfoutput><cfif isdefined("attributes.postcode")>#attributes.postcode#<cfelseif isdefined("get_addres")>#get_addres.POSTCODE#</cfif></cfoutput>" maxlength="5" readonly style="width:120px"></cf_object_td>
            </cf_object_tr>
            <cfsavecontent variable="header_"><cf_get_lang_main no='1959.Irtibat'>-<cf_get_lang_main no='720.Semt'></cfsavecontent>
            <cf_object_tr id="form_ul_contact_semt" Title="#header_#">
                <cf_object_td type="text"><cf_get_lang_main no='720.Semt'></cf_object_td>
                <cf_object_td><input type="text" name="contact_semt" id="contact_semt" value="<cfoutput><cfif isdefined("attributes.semt")>#attributes.semt#<cfelseif isdefined("get_addres")>#get_addres.SEMT#</cfif></cfoutput>" maxlength="30" readonly style="width:120px;"></cf_object_td>
            </cf_object_tr>
            <cfsavecontent variable="header_"><cf_get_lang_main no='1959.Irtibat'>-<cf_get_lang_main no='1226.Ilçe'></cfsavecontent>
            <cf_object_tr id="form_ul_contact_county" Title="#header_#">
                <cf_object_td type="text"><cf_get_lang_main no='1226.Ilçe'></cf_object_td>
                <cf_object_td>
                    <input type="hidden" name="contact_county_id" id="contact_county_id" value="<cfoutput><cfif isdefined("attributes.county_id")>#attributes.county_id#<cfelseif isdefined("get_addres")>#get_addres.COUNTY#</cfif></cfoutput>">
                    <input type="text" name="contact_county" id="contact_county" value="<cfoutput><cfif isdefined("attributes.county")>#attributes.county#<cfelseif isdefined("get_addres")><cfif isdefined('get_county_detail')>#get_county_detail.COUNTY_NAME#</cfif></cfif></cfoutput>" readonly style="width:120px;">					  
                </cf_object_td>
            </cf_object_tr>
            <cfsavecontent variable="header_"><cf_get_lang_main no='1959.Irtibat'>-<cf_get_lang_main no='559.Şehir'></cfsavecontent>
            <cf_object_tr id="form_ul_contact_city" Title="#header_#">
                <cf_object_td type="text"><cf_get_lang_main no='559.Şehir'></cf_object_td>
                <cf_object_td>
                    <input type="hidden" name="contact_city_id" id="contact_city_id" value="<cfoutput><cfif isdefined("attributes.city_id")>#attributes.city_id#<cfelseif isdefined("get_addres")>#get_addres.CITY#</cfif></cfoutput>">         
                    <input type="text" name="contact_city" id="contact_city" value="<cfoutput><cfif isdefined("attributes.city")>#attributes.city#<cfelseif isdefined("get_addres")><cfif isdefined('get_city_detail')>#get_city_detail.CITY_NAME#</cfif></cfif></cfoutput>" readonly style="width:120px;"> 					  
                </cf_object_td>
            </cf_object_tr>
            <cfsavecontent variable="header_"><cf_get_lang_main no='1959.Irtibat'>-<cf_get_lang_main no='807.Ülke'></cfsavecontent>
            <cf_object_tr id="form_ul_contact_country" Title="#header_#">
                <cf_object_td type="text"><cf_get_lang_main no='807.Ülke'></cf_object_td>
                <cf_object_td>
                    <input type="hidden" name="contact_country_id" id="contact_country_id" value="<cfoutput><cfif isdefined("attributes.country_id")>#attributes.country_id#<cfelseif isdefined("get_addres")>#get_addres.COUNTRY#</cfif></cfoutput>">        
                    <input type="text" name="contact_country" id="contact_country" value="<cfoutput><cfif isdefined("attributes.country")>#attributes.country#<cfelseif isdefined("get_addres")><cfif isdefined('get_country_detail')>#get_country_detail.COUNTRY_NAME#</cfif></cfif></cfoutput>" readonly style="width:120px;">				
                </cf_object_td>
            </cf_object_tr>
            <cfsavecontent variable="header_"><cf_get_lang_main no='247.Satış Bölgesi'></cfsavecontent>
            <cf_object_tr id="form_ul_contact_sales_zones" Title="#header_#">
                <cf_object_td type="text"><cf_get_lang_main no='247.Satış Bölgesi'></cf_object_td>
                <cf_object_td>
                    <select name="contact_sales_zone_id" id="contact_sales_zone_id" style="width:120px;">
                        <option value=""><cf_get_lang_main no='322.Seçiniz'></option>
                        <cfoutput query="GET_SALES_ZONES">
                            <option value="#SZ_ID#" <cfif isdefined("get_addres") and len(get_addres.SZ_ID) and get_addres.SZ_ID eq sz_id>selected<cfelseif isdefined("attributes.contact_sz_id") and attributes.contact_sz_id eq sz_id>selected<cfelseif isdefined("attributes.sz_id") and attributes.sz_id eq sz_id>selected</cfif>>#SZ_NAME# <cfif is_active eq 0>(Pasif)</cfif></option>
                        </cfoutput>
                    </select>                                            
                </cf_object_td>
            </cf_object_tr>
            <cfsavecontent variable="header_"><cf_get_lang_main no='1959.Irtibat'>-<cf_get_lang_main no='1137.Koordinatlar'></cfsavecontent>
            <cf_object_tr id="form_ul_contact_coordinate_1" Title="#header_#">
                <cf_object_td type="text"><cf_get_lang_main no='1137.Koordinatlar'></cf_object_td>
                <cf_object_td>
                    <cf_get_lang_main no='1141.E'><input type="text" name="contact_coordinate_1" id="contact_coordinate_1" value="<cfoutput><cfif isdefined("attributes.coordinate_1")>#attributes.coordinate_1#<cfelseif isdefined("get_addres") and len(get_addres.coordinate_1)>#get_addres.coordinate_1#</cfif></cfoutput>" maxlength="10" style="width:48px;text-align:right">
                    <cf_get_lang_main no='1179.B'><input type="text" name="contact_coordinate_2" id="contact_coordinate_2" value="<cfoutput><cfif isdefined("attributes.coordinate_2")>#attributes.coordinate_2#<cfelseif isdefined("get_addres") and len(get_addres.coordinate_2)>#get_addres.coordinate_2#</cfif></cfoutput>" maxlength="10" style="width:48px;text-align:right">
                </cf_object_td>
            </cf_object_tr>
        </cf_object_table>
    <cfelse>
        <input type="hidden" name="contact_address" id="contact_address" readonly style="width:120px;height:40px;" value="<cfoutput><cfif isdefined("attributes.address")>#attributes.address#<cfelseif isdefined("get_addres")>#get_addres.address#</cfif></cfoutput>">
        <input type="hidden" name="contact_postcode" id="contact_postcode" value="<cfoutput><cfif isdefined("attributes.postcode")>#attributes.postcode#<cfelseif isdefined("get_addres")>#get_addres.POSTCODE#</cfif></cfoutput>" maxlength="5" readonly style="width:120px">
        <input type="hidden" name="contact_semt" id="contact_semt" value="<cfoutput><cfif isdefined("attributes.semt")>#attributes.semt#<cfelseif isdefined("get_addres")>#get_addres.SEMT#</cfif></cfoutput>" maxlength="30" readonly style="width:120px;">	
        <input type="hidden" name="contact_county_id" id="contact_county_id" value="<cfoutput><cfif isdefined("attributes.county_id")>#attributes.county_id#<cfelseif isdefined("get_addres")>#get_addres.COUNTY#</cfif></cfoutput>">
        <input type="hidden" name="contact_county" id="contact_county" value="<cfoutput><cfif isdefined("attributes.county")>#attributes.county#<cfelseif isdefined("get_addres")><cfif isdefined('get_county_detail')>#get_county_detail.COUNTY_NAME#</cfif></cfif></cfoutput>" readonly style="width:120px;">					  
        <input type="hidden" name="contact_city_id" id="contact_city_id" value="<cfoutput><cfif isdefined("attributes.city_id")>#attributes.city_id#<cfelseif isdefined("get_addres")>#get_addres.CITY#</cfif></cfoutput>">         
        <input type="hidden" name="contact_city" id="contact_city" value="<cfoutput><cfif isdefined("attributes.city")>#attributes.city#<cfelseif isdefined("get_addres")><cfif isdefined('get_city_detail')>#get_city_detail.CITY_NAME#</cfif></cfif></cfoutput>" readonly style="width:120px;"> 					  
        <input type="hidden" name="contact_country_id" id="contact_country_id" value="<cfoutput><cfif isdefined("attributes.country_id")>#attributes.country_id#<cfelseif isdefined("get_addres")>#get_addres.COUNTRY#</cfif></cfoutput>">        
        <input type="hidden" name="contact_country" id="contact_country" value="<cfoutput><cfif isdefined("attributes.country")>#attributes.country#<cfelseif isdefined("get_addres")><cfif isdefined('get_country_detail')>#get_country_detail.COUNTRY_NAME#</cfif></cfif></cfoutput>" readonly style="width:120px;">				
        <input type="hidden" name="contact_sales_zone_id" id="contact_sales_zone_id" value="<cfoutput><cfif isdefined("attributes.contact_sales_zone_id")>#attributes.contact_sales_zone_id#<cfelseif isdefined("get_addres") and len(get_addres.sz_id)>#get_addres.sz_id#</cfif></cfoutput>">
        <input type="hidden" name="contact_coordinate_1" id="contact_coordinate_1" value="<cfoutput><cfif isdefined("attributes.coordinate_1")>#attributes.coordinate_1#<cfelseif isdefined("get_addres") and len(get_addres.coordinate_1)>#get_addres.coordinate_1#</cfif></cfoutput>">
        <input type="hidden" name="contact_coordinate_2" id="contact_coordinate_2" value="<cfoutput><cfif isdefined("attributes.coordinate_2")>#attributes.coordinate_2#<cfelseif isdefined("get_addres") and len(get_addres.coordinate_2)>#get_addres.coordinate_2#</cfif></cfoutput>">
    </cfif>
</cf_object_main_table>
