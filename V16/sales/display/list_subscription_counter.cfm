<cfsetting showdebugoutput="no">
<cfparam name="attributes.type" default="0"><!--- 0 : html döner, 1 : data döner ---->

<cfinclude template="../query/get_counter_types.cfm">
<cfif attributes.type eq 0>
    <cf_flat_list>
        <tbody>
            <cfif get_counter_types.recordcount>
                <cfoutput query="get_counter_types">
                    <tr>
                        <td>
                            <a href="index.cfm?fuseaction=member.form_list_company&event=upd&cpid=#COMPANY_ID#" class="tableyazi" target="_blank"><span class="text-bold">#FULLNAME#</span></a>  / 
                            <a href="javascript://" onClick="openBoxDraggable('#request.self#?fuseaction=sales.counter&event=upd&counter_id=#counter_id#','','ui-draggable-box-large');"><span class="text-bold text-danger">#counter_type#</span></a><br/>
                        </td>
                        <td class="text-right">
                            <a href="javascript://" onClick="openBoxDraggable('#request.self#?fuseaction=sales.popup_subscription_counter_prepaid&subscription_id=#subscription_id#&counter_id=#counter_id#','','ui-draggable-box-large');" class="wrk-uF0193" title="<cf_get_lang dictionary_id="48868.Yükle">" alt="<cf_get_lang dictionary_id="48868.Yükle">"></a>
                            <a href="javascript://" onClick="openBoxDraggable('#request.self#?fuseaction=sales.popup_counter_meter&subscription_id=#subscription_id#&counter_id=#counter_id#','','ui-draggable-box-large')" class="wrk-uF0205" title="<cf_get_lang dictionary_id="48869.Oku">" alt="<cf_get_lang dictionary_id="48869.Oku">"></a>
                        </td>
                    </tr>
                </cfoutput>
            <cfelse>
                <tr>
                    <cf_get_lang dictionary_id='57484.Kayıt Bulunamadı'>!
                </tr>
            </cfif>
        </tbody>
    </cf_flat_list>
<cfelseif attributes.type eq 1>
    <cfset getCounterTypes = ArrayNew(1)>
    <cfoutput query="get_counter_types">
        <cfset getCounterTypes[currentrow]["COUNTER_ID"] = COUNTER_ID>
        <cfset getCounterTypes[currentrow]["COUNTER_NO"] = COUNTER_NO>
        <cfset getCounterTypes[currentrow]["COUNTER_TYPE_ID"] = COUNTER_TYPE_ID>
        <cfset getCounterTypes[currentrow]["COUNTER_TYPE"] = COUNTER_TYPE>
        <cfset getCounterTypes[currentrow]["COMPANY_ID"] = COMPANY_ID>
        <cfset getCounterTypes[currentrow]["FULLNAME"] = FULLNAME>
    </cfoutput> 
    <cfoutput>#Replace(SerializeJson(getCounterTypes),"//","")#</cfoutput>
<cfelseif attributes.type eq 2>
    <cfset getCounterProduct = ArrayNew(1)>
    <cfoutput query="get_counter_types">
        <cfset getCounterProduct[currentrow]["PRODUCT_ID"] = PRODUCT_ID>
        <cfset getCounterProduct[currentrow]["PRODUCT_NAME"] = PRODUCT_NAME>
        <cfset getCounterProduct[currentrow]["STOCK_ID"] = STOCK_ID>
        <cfset getCounterProduct[currentrow]["UNIT"] = UNIT>
        <cfset getCounterProduct[currentrow]["UNIT_ID"] = UNIT_ID>
        <cfset getCounterProduct[currentrow]["AMOUNT"] = AMOUNT>
        <cfset getCounterProduct[currentrow]["PRICE"] = PRICE>
        <cfset getCounterProduct[currentrow]["MONEY_ID"] = MONEY_ID>
        <cfset getCounterProduct[currentrow]["OTHER_MONEY"] = OTHER_MONEY>
    </cfoutput> 
    <cfoutput>#Replace(SerializeJson(getCounterProduct),"//","")#</cfoutput>
</cfif>
