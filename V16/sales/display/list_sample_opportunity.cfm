<cfparam  name="attributes.page" default="1">
<cfif not (isDefined('attributes.maxrows') and isNumeric(attributes.maxrows))>
<cfset attributes.maxrows = session.ep.maxrows />
</cfif>
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1 />
<cfset comp    = createObject("component","V16.product.cfc.product_sample") />
<cfset LIST_PRODUCT_SAMPLE = comp.LIST_PRODUCT_SAMPLE(opp_id : attributes.opp_id )/>
<cfparam name="attributes.product_sample_id" default="#LIST_PRODUCT_SAMPLE.product_sample_id#">
<cfparam name='attributes.totalrecords' default="#LIST_PRODUCT_SAMPLE.recordcount#">
<cfparam name="attributes.id" default="">
<cfform name="setProcessForm" id="setProcessForm" action="" method="post">
<cf_grid_list id="sample">  
    <thead>
        <tr>
            <th width="35"><cf_get_lang dictionary_id='58577.Sıra'></th>
            <th width="70"><cf_get_lang dictionary_id='57482.Aşama'></th>
            <th><cf_get_lang dictionary_id='62603.Numune'></th> 
            <th><cf_get_lang dictionary_id='57457.Müşteri'><cf_get_lang dictionary_id='58800.Ürün Kodu'></th>
            <th><cf_get_lang dictionary_id='62607.Hedef Miktar'></th>
            <th><cf_get_lang dictionary_id='57636.Birim'></th>
            <th><cf_get_lang dictionary_id='62606.Hedef Fiyat'></th>
            <th width="50" ><cf_get_lang dictionary_id='57489.Para Birimi'></th>
            <th width="100" id="qualty"><cf_get_lang dictionary_id='48183.Satış Fiyatı'></th>
            <th width="50"><cf_get_lang dictionary_id='57489.Para Birimi'></th>
            <th><cf_get_lang dictionary_id='32484.Versiyon'>/<cf_get_lang dictionary_id='57452.Stok'></th>
            <th><cf_get_lang dictionary_id='29412.Seri'>-<cf_get_lang dictionary_id='36588.Asorti'></th>
            <th><cf_get_lang dictionary_id='38564.Sipariş Miktarı'></th>
            <th width="20" >
                <input type="checkbox" name="allSelectDemand" id="allSelectDemand" onclick="wrk_select_all('allSelectDemand','opportunity_chech');">
            </th>
          
            
        </tr>
    </thead>
    <cfif LIST_PRODUCT_SAMPLE.opp_id is attributes.opp_id >
        <cfoutput query="LIST_PRODUCT_SAMPLE" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
            <cfset GET_STOCK_DETAIL = comp.GET_STOCK_DETAIL(PRODUCT_SAMPLE_ID : PRODUCT_SAMPLE_ID )/>
            <cfset get_price_exceptions_pid = comp.get_price_exceptions_pid()/>
            <tbody>
                <tr>
                    <td>#currentrow#</td>
                    <td>#stage#</td>
                    <td><a href="#request.self#?fuseaction=product.product_sample&event=upd&product_sample_id=#PRODUCT_SAMPLE_ID#">#product_sample_name#</a></td>
                    <td>#customer_model_no#</td>
                    <td><cfif len(target_amount)>#target_amount#</cfif></td>
                    <td>#UNIT#</td>
                    <td style="text-align:right"><cfif len(target_price)>#TLFormat(LIST_PRODUCT_SAMPLE.target_price)#</cfif></td>
                    <td>#target_price_currency#</td>
                    <td style="text-align:right">#TLFormat(SALES_PRICE)#</td>
                    <td>#SALES_PRICE_CURRENCY#</td>
                    <td>#GET_STOCK_DETAIL.recordcount#</td>
                    <td>#get_price_exceptions_pid.ASSORTMENT#</td>
                    <td></td>
                    <td style="text-align:center">
                        <input type="checkbox"  name="opportunity_chech" id="opportunity_chech" value="#product_sample_id#" >
                    </td>
                  
                </tr>
            </tbody>
        </cfoutput>
    <cfelse>
        <tbody> 
            <tr>
                <td colspan="20"><cfif isdefined("attributes.form_submitted")><cf_get_lang dictionary_id='57484.Kayıt Bulunamadı'></cfif>!</td>
            </tr>
        </tbody> 
    </cfif>
</cf_grid_list>

<cf_box_elements vertical="1">
    <div class="col col-12 col-xs-12">
        <div class="ui-info-bottom">
         
           
                <div class="col col-2 col-md-6 col-xs-12">
                    <label class="col col-12 col-md-12 col-sm-12 col-xs-12" ><cf_get_lang dictionary_id='41129.Süreç/Aşama'></label>
                    <div  class="col col-12 col-md-12 col-sm-12 col-xs-12 ">
                        <div class="form-group" id="item-process_stage">
                            <cf_workcube_process is_upd="0" slct_width="180px;" is_detail="0" process_cat_width='300'>
                        </div>
                    </div>
                </div>
                <div class="col col-2 col-md-6 col-xs-12">
                    <label class="col col-12 col-md-12 col-sm-12 col-xs-12 " ><cf_get_lang dictionary_id='57742.Tarih'></label>
                    <div  class="col col-12 col-md-12 col-sm-12 col-xs-12 ">
                        <div class="form-group" id="item-target_delivery_date">
                            <div class="input-group" >
                                <cfoutput>  
                                    <input type="text" name="target_delivery_date" id="target_delivery_date" value="#Dateformat(now(),dateformat_style)#" validate="#validate_style#" maxlength="10">
                                    <span class="input-group-addon"><cf_wrk_date_image date_field="target_delivery_date"></span>
                                </cfoutput>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col col-2 col-md-6 col-xs-12">
                    <label class="col col-12 col-md-12 col-sm-12 col-xs-12" ><cf_get_lang dictionary_id='65170.Süreç Yetkilisi'></label>
                    <div  class="col col-12 col-md-12 col-sm-12 col-xs-12 ">
                        <div class="form-group" id="item-process_employee">
                            
                                <div class="input-group">
                                    <input type="hidden" name="process_emp_id" id="process_emp_id" value="<cfoutput>#session.ep.userid#</cfoutput>">
                                    <input  type="text" name="process_emp" id="process_emp"   value="<cfoutput>#get_emp_info(session.ep.userid,0,0)#</cfoutput>">
                                    <span class="input-group-addon btnPointer icon-ellipsis" onClick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_list_positions&field_emp_id=setProcessForm.process_emp_id&field_name=setProcessForm.process_emp&select_list=1</cfoutput>')"></span>
                                </div>
                           
                        </div>
                    </div>
                </div>
                <div class="col col-1 col-md-6 col-xs-12">
                    <div class="form-group">
                        <div class="col col-12 col-md-12 col-sm-12 col-xs-12" style="margin: 14px 5px;">
                            <cf_workcube_buttons is_upd='0' add_function="save_process()" next_page="">
                        </div>
                    </div>
                </div>
                <div class="col col-2 col-md-6 col-xs-12">
                    <div class="form-group">
                        <div class="col col-12 col-md-12 col-sm-12 col-xs-12" style="margin: 14px -2px;">
                            <a href="javascript://" id="offer" onclick="kontrol_offer()"class="ui-ripple-btn"><cf_get_lang dictionary_id='40807.Teklif Ver'></a>
                        </div>
                    </div>
                </div>
                <div class="col col-2 col-md-6 col-xs-12" >
                    <div class="form-group">
                        
                        <div class="col col-12 col-md-12 col-sm-12 col-xs-12" style="margin: 14px -60px;">
                            <a href="javascript://" id="order" onclick="kontrol_order()" class="ui-ripple-btn" style="background-color: #e4a114;"><cf_get_lang dictionary_id='32017.Sipariş Al'></a> 
                        
                    </div>
                </div>
                
            </div>
        </div>
    </div>
   
</cf_box_elements>
</cfform>
<script>
    function save_process() {
        var array = [];
        var checked_item_ = document.getElementsByName('opportunity_chech');
        if(checked_item_.length != undefined)
        {
            for(var xx=0; xx < checked_item_.length; xx++)
            {
                if(checked_item_[xx].checked)
                {
                    var is_selected_row = 1;
                    array.push(checked_item_[xx].value);
                    
                }
            }
        }
        else if(checked_item_.checked)
        {
            var is_selected_row = 1;
            array.push(checked_item_.value);    
        }

        if(is_selected_row == undefined)
        {
            alert("<cf_get_lang dictionary_id='65336.Numune Seçiniz'>");
            return false;
        }
        else
        {
            process_stage_ = document.setProcessForm.process_stage.value;
            target_delivery_date_ = document.setProcessForm.target_delivery_date.value;
            process_emp_id = document.setProcessForm.process_emp_id.value;
            product_sample_id_ = array;
            setProcessForm.action = 'V16/product/cfc/product_sample.cfc?method=DET_PRODUCT_SAMPLE_PROCESS&fuseaction=sales.Oppurtinity_samples&process_stage='+process_stage_+'&product_sample_id='+product_sample_id_+'&target_delivery_date='+target_delivery_date_+'&old_process_line=<cfoutput>#LIST_PRODUCT_SAMPLE.process_stage_id#</cfoutput>';
            setProcessForm.submit();
        }

    }
    function kontrol_order(){
        var sample = [] , p_sample_= [];
        
    $('input[name="opportunity_chech"]').each(function(){
        if($(this).is(':checked')){
				
            sample.push( $(this).val() );	
              
            }
           
			});
          
                if(sample.length==''){
                alert("<cf_get_lang dictionary_id='65336.Numune Seçiniz'>");
            return false;
            }

          
            var p_id = [];
            
            for (var i = 0; i < sample.length; i++) {
                
               
                 var get_sales_price = wrk_safe_query("get_sales_price",'dsn3',0,sample[i]);
                
                  
                   
                        if(get_sales_price.SALES_PRICE[0] == '' || get_sales_price.SALES_PRICE[0] == undefined || get_sales_price.P_SAMPLE_ID[0] == 0 || get_sales_price.TARGET_PRICE[0] == '')
                        {
                            if(get_sales_price.SALES_PRICE[0] == '' || get_sales_price.SALES_PRICE[0] == undefined){
                                alert(get_sales_price.PRODUCT_SAMPLE_NAME[0] + ' <cf_get_lang dictionary_id='65328.isimli numuneye ait satış fiyatı bulunmamaktadır.'>');
                                    
                            }
                            if(get_sales_price.TARGET_PRICE[0] == '' || get_sales_price.TARGET_PRICE[0] == undefined){
                                alert(get_sales_price.PRODUCT_SAMPLE_NAME[0] + ' <cf_get_lang dictionary_id='45964.İsimli numuneye ait hedef fiyat bulunmamakta.'>');
                                   
                            }
                            
                            if( get_sales_price.P_SAMPLE_ID[0] == 0 )
                                {
                                    alert(get_sales_price.PRODUCT_SAMPLE_NAME[0] + ' <cf_get_lang dictionary_id='65327.isimli numuneye ait ürün tasalanmamıştır'>');
                                        
                                }
                                return false;
                           
                        }

                       
                       
                  
                        p_id.push(get_sales_price.PRODUCT_ID[0]);	
                    
                        
                    
                }   
               
         
  

                window.location.href= '<cfoutput>#request.self#?fuseaction=sales.list_order&event=add&opp_id=#attributes.opp_id#&product_id=</cfoutput>'+p_id;   
           
           
   
    }
    function kontrol_offer(){
        var sample = [] , p_sample_= [];
        
    $('input[name="opportunity_chech"]').each(function(){
        if($(this).is(':checked')){
				
            sample.push( $(this).val() );	
              
            }
           
			});
          
                if(sample.length==''){
                alert("<cf_get_lang dictionary_id='65336.Numune Seçiniz'>");
            return false;
            }

          
            var p_id = [];
            
            for (var i = 0; i < sample.length; i++) {
                
                var get_sales_price = wrk_safe_query("get_sales_price",'dsn3',0,sample[i]);
                
                  
                   
                 if(get_sales_price.SALES_PRICE[0] == '' || get_sales_price.SALES_PRICE[0] == undefined || get_sales_price.P_SAMPLE_ID[0] == 0 || get_sales_price.TARGET_PRICE[0] == '')
                        {
                            if(get_sales_price.SALES_PRICE[0] == '' || get_sales_price.SALES_PRICE[0] == undefined){
                                alert(get_sales_price.PRODUCT_SAMPLE_NAME[0] + ' <cf_get_lang dictionary_id='65328.isimli numuneye ait satış fiyatı bulunmamaktadır.'>');
                                    
                            }
                            if(get_sales_price.TARGET_PRICE[0] == '' || get_sales_price.TARGET_PRICE[0] == undefined){
                                alert(get_sales_price.PRODUCT_SAMPLE_NAME[0] + ' <cf_get_lang dictionary_id='45964.İsimli numuneye ait hedef fiyat bulunmamakta.'>');
                                   
                            }
                            
                            if( get_sales_price.P_SAMPLE_ID[0] == 0 )
                                {
                                    alert(get_sales_price.PRODUCT_SAMPLE_NAME[0] + ' <cf_get_lang dictionary_id='65327.isimli numuneye ait ürün tasalanmamıştır'>');
                                        
                                }
                                return false;
                           
                        }
                  
                        p_id.push(get_sales_price.PRODUCT_ID[0]);	
                    
                        
                    
                }   
               
           
                window.location.href= '<cfoutput>#request.self#?fuseaction=sales.list_offer&event=add&opp_id=#attributes.opp_id#&product_id=</cfoutput>'+p_id;   
            
           
   
    }
</script>
