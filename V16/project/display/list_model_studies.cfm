
<!---
    Author: Fatma zehra Dere
    Date: 2022-10-21
    Description:
    Projeler det eventi>Operasyonlar Modalı>Model Çalışmaları Seperatörü ile projeye ait mode listesi gelir. Listeden yapılan add ve upd işlemleri proje ile ilşkilendirildi.
--->
<cfset comp    = createObject("component","V16.product.cfc.product_sample") />
<cfset LIST_PRODUCT_SAMPLE = comp.LIST_PRODUCT_SAMPLE(project_id : attributes.id )/>
<cfparam name="attributes.product_sample_id" default="#LIST_PRODUCT_SAMPLE.product_sample_id#">
<cf_grid_list>  
    <thead>
        <tr>
            <th width="35"><cf_get_lang dictionary_id='58577.Sıra'></th>
            <th><cf_get_lang dictionary_id='62603.numune'><cf_get_lang dictionary_id='57897.Adı'></th>
            <th><cf_get_lang dictionary_id='62569.Müşteri Model No'></th>
            <th><cf_get_lang dictionary_id='62603.numune'><cf_get_lang dictionary_id='57486.Kategori'></th>
            <th><cf_get_lang dictionary_id='29401.Ürün Kategorisi'></th>
            <th><cf_get_lang dictionary_id='58847.Marka'></th>
            <th><cf_get_lang dictionary_id='58784.Referans'><cf_get_lang dictionary_id='57657.Ürün'></th>
            <th><cf_get_lang dictionary_id='61924.Tasarımcı'></th>
            <th><cfoutput>#getLang('','Müşteri','57457')#</cfoutput></th>
            <th><cf_get_lang dictionary_id='57457.Müşteri'><cf_get_lang dictionary_id='57908.Temsilci'></th>
            <th><cf_get_lang dictionary_id='62606.Hedef Fiyat'></th>
            <th><cf_get_lang dictionary_id='62607.Hedef Miktar'></th>
            <th><cf_get_lang dictionary_id='57951.Hedef'><cf_get_lang dictionary_id='57645.Teslim Tarihi'></th>
            <th><cf_get_lang dictionary_id='58859.Süreç'></th>
            <th width="20"><a href="<cfoutput>#request.self#?fuseaction=product.product_sample&event=add&project_id=#attributes.id#</cfoutput>" target="_blank"><i class="fa fa-plus" alt="<cf_get_lang no='503.Formu Doldur'>" title="<cf_get_lang_main no='170.Ekle'>" ></i></a></th>
        </tr>
    </thead>
    <cfif LIST_PRODUCT_SAMPLE.recordcount>
        <cfoutput query="LIST_PRODUCT_SAMPLE">
            <tbody>
                <tr>
                    <td>#currentrow#</td>
                    <td>#PRODUCT_SAMPLE_NAME#</td>
                    <td>#customer_model_no#</td>
                    <td><cfif len(product_sample_cat_id)>#PRODUCT_SAMPLE_CAT#</cfif></td>
                    <td><cfif len(product_cat_id)>#PRODUCT_CAT#</cfif></td>
                    <td><cfif len(brand_id)>#BRAND_NAME#</cfif></td>
                    <td><cfif len(reference_product_id)>#PRODUCT_NAME#</cfif></td>
                    <td><cfif len(designer_emp_id)>#get_emp_info(LIST_PRODUCT_SAMPLE.designer_emp_id,0,0)#</cfif></td>
                    <td>
                        <cfif len(LIST_PRODUCT_SAMPLE.consumer_id)> 
                            #get_cons_info(LIST_PRODUCT_SAMPLE.consumer_id,0,0)#
                        <cfelseif len(LIST_PRODUCT_SAMPLE.company_id)> 
                            #get_par_info(LIST_PRODUCT_SAMPLE.company_id,1,1,0)# 
                        </cfif>
                    </td>
                    <td>      
                        <cfif len(LIST_PRODUCT_SAMPLE.consumer_id)> 
                            #get_cons_info(LIST_PRODUCT_SAMPLE.CONSUMER_ID,0,0,0)#
                        <cfelseif len(LIST_PRODUCT_SAMPLE.company_id)> 
                            #get_par_info(LIST_PRODUCT_SAMPLE.partner_id,0,-1,0)# 
                        </cfif>
                    </td>
                    <td class="text-right"><cfif len(target_price)>#TlFormat(wrk_round(LIST_PRODUCT_SAMPLE.target_price))##target_price_currency#</cfif></td>
                    <td class="text-right"><cfif len(target_amount)>#TlFormat(wrk_round(target_amount))# #UNIT#</cfif></td><td height="20">
                        <cfif len(target_delivery_date)>
                            #dateformat(date_add('h',session.ep.time_zone,target_delivery_date),dateformat_style)#
                        </cfif>
                    </td>
                    <td><cf_workcube_process type="color-status" select_name="PROCESS_STAGE" process_stage="#PROCESS_STAGE_ID#"  fuseaction="product.product_sample"></td>
                    <td class="text-center"><a href="#request.self#?fuseaction=product.product_sample&event=upd&product_sample_id=#PRODUCT_SAMPLE_ID#" target="_blank"><i class="fa fa-pencil" title="<cf_get_lang dictionary_id='57464.Güncelle'>"></i></a></td>
                </tr>
            </tbody>
        </cfoutput>
    <cfelse>
        <tbody> 
            <tr>
                <td colspan="20"><cf_get_lang dictionary_id='57484.Kayıt Bulunamadı'>!</td>
            </tr>
        </tbody> 
    </cfif>
</cf_grid_list>

