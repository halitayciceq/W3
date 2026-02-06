<cfparam name="attributes.is_pay_term" default="">
<cfparam name="attributes.voucher_value" default="">
<cfparam name="attributes.due_date" default="">
 
<cf_box title="#(isDefined('attributes.voucher') and attributes.voucher eq 1) ? getLang('','Senet',58008) : getLang('','Çek',58007)#" scroll="1" collapsable="1" resize="1" popup_box="#iif(isdefined("attributes.draggable"),1,0)#">
    <cfform name="cheque_voucher" method="post" action="#(isDefined('attributes.voucher') and attributes.voucher eq 1) ? 'V16/sales/display/add_fast_sale_voucher.cfm' : 'V16/sales/display/add_fast_sale_cheque.cfm'#">
        <cf_box_elements vertical="1">
            <cfif isdefined("attributes.voucher") and len(attributes.voucher) and attributes.voucher eq 1>            
                <div class="form-group">
                    <div class="col col-4 col-md-4 col-sm-4 col-xs-12">
                        <label><cfoutput>#getLang('','tutar',57673)#</cfoutput></label>
                    </div>
                    <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                        <input type="text" class="moneybox" name="voucher_value" id="voucher_value" value=""  onkeyup="return(FormatCurrency(this,event));">
                    </div>
                </div>
                <div class="form-group">
                    <div class="col col-4 col-md-4 col-sm-4 col-xs-12">
                        <label><cfoutput>#getLang('','vade tarihi',57881)#</cfoutput></label>
                    </div>
                    <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                        <div class="input-group">
                            <input type="text" name="due_date" id="due_date" value="">
                            <span class="input-group-addon"><cf_wrk_date_image date_field="due_date"></span>
                        </div>
                    </div>
                </div>            
                <div class="form-group">
                    <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='50492.Eklenecek Senet Sayısı'></label>
                    <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                        <input type="text" name="voucher_count" id="voucher_count" value="1" maxlength="3" class="moneybox">
                    </div>
                </div>               
            <cfelseif isdefined("attributes.cheque") and len(attributes.cheque) and attributes.cheque eq 1>
                <div class="col col-6 col-md-6 col-sm-6 col-xs-12">
                    <div class="form-group">
                        <div class="col col-4 col-md-4 col-sm-4 col-xs-12">
                            <label><cfoutput>#getLang('','tutar',57673)#</cfoutput></label>
                        </div>
                        <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                            <input type="text" class="moneybox" name="cheque_value" id="cheque_value" value=""  onkeyup="return(FormatCurrency(this,event));">
                        </div>
                    </div>
                    <div class="form-group">
                        <div class="col col-4 col-md-4 col-sm-4 col-xs-12">
                            <label><cfoutput>#getLang('','vade tarihi',57881)#</cfoutput></label>
                        </div>
                        <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                            <div class="input-group">
                                <input type="text" name="chequeDate" id="chequeDate" value="">
                                <span class="input-group-addon"><cf_wrk_date_image date_field="chequeDate"></span>
                            </div>
                        </div>
                    </div>  
                    <div class="form-group">
                        <div class="col col-4 col-md-4 col-sm-4 col-xs-12">
                            <label><cf_get_lang dictionary_id='54490.Çek No'></label>
                        </div>
                        <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                            <div class="input-group">
                                <input type="text" name="cheque_no" id="cheque_no" value="">
                            </div>
                        </div>
                    </div>
                    <div class="form-group">
                        <div class="col col-4 col-md-4 col-sm-4 col-xs-12">
                            <label><cf_get_lang dictionary_id='57521.Banka'></label>
                        </div>
                        <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                            <div class="input-group">
                                <input type="text" name="cheque_bank" id="cheque_bank" value="">
                            </div>
                        </div>
                    </div> 
                </div>
                <div class="col col-6 col-md-6 col-sm-6 col-xs-12">
                    <div class="form-group">
                        <div class="col col-4 col-md-4 col-sm-4 col-xs-12">
                            <label><cf_get_lang dictionary_id='57453.Şube'></label>
                        </div>
                        <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                            <div class="input-group">
                                <input type="text" name="cheque_branch" id="cheque_branch" value="">
                            </div>
                        </div>
                    </div>  
                    <div class="form-group">
                        <div class="col col-4 col-md-4 col-sm-4 col-xs-12">
                            <label><cf_get_lang dictionary_id='58178.Hesap No'></label>
                        </div>
                        <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                            <div class="input-group">
                                <input type="text" name="cheque_account" id="cheque_account" value="">
                            </div>
                        </div>
                    </div>              
                    <div class="form-group">
                        <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='50474.Eklenecek Çek Sayısı'></label>
                        <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                            <input type="text" name="cheque_count" id="cheque_count" value="1" maxlength="3" class="moneybox">
                        </div>
                    </div>  
                </div>              
            </cfif>                    
        </cf_box_elements>
        <cf_box_footer>        
            <cf_workcube_buttons is_upd='0' add_function='#(isDefined("attributes.voucher") and attributes.voucher eq 1) ? "AddVoucherRow()" : "AddChequeRow()"#'>
        </cf_box_footer>
    </cfform> 
</cf_box>
<script>
    function AddVoucherRow()
	{	
        var voucher_value = $("input[name=voucher_value").val();
        var due_date = $("input[name=due_date").val();
        var voucher_count = $("input[name=voucher_count").val();                
                add_row_3(commaSplit(voucher_value,4),due_date);            
                if(voucher_count > 1)
                    {
                        for(i=1;i<=voucher_count-1;i++)
                            {		
                                new_due_date = date_add('m',i,due_date);	
                                add_row_3(commaSplit(voucher_value,4),new_due_date);
                                change_due_date(i);
                            }  
                    }
            toplam_voucher_hesapla();
		    vade_hesapla();
			closeBoxDraggable( '<cfoutput>#attributes.modal_id#</cfoutput>' );
	}
    function AddChequeRow()
    {	
        var cheque_value = $("input[name=cheque_value").val();
        var chequeDate = $("input[name=chequeDate").val();
        var cheque_no = $("input[name=cheque_no").val();
        var cheque_branch = $("input[name=cheque_branch").val();  
        var cheque_account = $("input[name=cheque_account").val();
        var cheque_bank = $("input[name=cheque_bank").val();
        var cheque_count = $("input[name=cheque_count").val();

        add_row_4(commaSplit(cheque_value,4),chequeDate,cheque_no,cheque_bank,cheque_branch,cheque_account);

                if(cheque_count > 1)
                    {
                        for(i=1;i<=cheque_count-1;i++)
                            {		
                                new_due_date_c = date_add('m',i,chequeDate);	
                                add_row_4(commaSplit(cheque_value,4),new_due_date_c,cheque_no,cheque_bank,cheque_branch,cheque_account);
                            }  
                    }
                    toplam_cheque_hesapla();
                    vade_hesapla();
			closeBoxDraggable( '<cfoutput>#attributes.modal_id#</cfoutput>' );
	}
</script>