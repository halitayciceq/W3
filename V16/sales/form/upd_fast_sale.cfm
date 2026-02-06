<cf_get_lang_set module_name="sales">
<cf_xml_page_edit fuseact="sales.add_fast_sale">
<cfset is_instalment = 1>
<cfif isnumeric(attributes.order_id)>
	<cfinclude template="../query/get_order_detail.cfm">
<cfelse>
	<cfset get_order_detail.recordcount = 0>
</cfif>
<cfif not (get_order_detail.recordcount) or (isdefined("attributes.active_company") and attributes.active_company neq session.ep.company_id)>
	<cfset hata  = 11>
	<cfsavecontent variable="message"><cf_get_lang_main no='585.Şube Yetkiniz Uygun Değil'> <cf_get_lang_main no='586.Veya'> <cf_get_lang_main no='588.Sirketinizde Böyle Bir Sipariş Bulunamadı'> !</cfsavecontent>
	<cfset hata_mesaj  = message>
	<cfinclude template="../../dsp_hata.cfm">
<cfelse>
	<cfquery name="GET_ORDERS_SHIP" datasource="#DSN3#">
		SELECT ORDER_ID FROM ORDERS_SHIP WHERE ORDER_ID = #get_order_detail.order_id# AND PERIOD_ID = #session.ep.period_id#
	</cfquery>
	<cfquery name="GET_ORDERS_INVOICE" datasource="#DSN3#">
		SELECT ORDER_ID FROM ORDERS_INVOICE WHERE ORDER_ID = #get_order_detail.order_id# AND PERIOD_ID = #session.ep.period_id#
	</cfquery>
	<cfquery name="get_period" datasource="#dsn3#">
		SELECT KASA_PERIOD_ID AS PERIOD_ID FROM ORDER_CASH_POS WHERE ORDER_ID = #get_order_detail.order_id# AND KASA_PERIOD_ID IS NOT NULL AND ORDER_CASH_POS.IS_CANCEL = 0 
	</cfquery>
	<cfif not get_period.recordcount>
		<cfquery name="get_period" datasource="#dsn3#">
			SELECT PERIOD_ID FROM ORDER_VOUCHER_RELATION WHERE ORDER_ID = #get_order_detail.order_id# AND PERIOD_ID IS NOT NULL
		</cfquery>
	</cfif>
	<cfif get_period.recordcount>
		<cfquery name="get_company" datasource="#dsn#">
			SELECT 
    	        PERIOD_ID, 
                PERIOD, 
                PERIOD_YEAR, 
                OUR_COMPANY_ID, 
                OTHER_MONEY, 
                RECORD_DATE, 
                RECORD_IP, 
                RECORD_EMP, 
                UPDATE_DATE, 
                UPDATE_IP, 
                UPDATE_EMP, 
                PROCESS_DATE 
            FROM 
	            SETUP_PERIOD 
            WHERE 
            	PERIOD_ID = #get_period.period_id#
		</cfquery>
		<cfset new_dsn2 = '#dsn#_#get_company.period_year#_#get_company.our_company_id#'>
		<cfquery name="get_new_period" datasource="#dsn#">
			SELECT 
    	        PERIOD_ID, 
                PERIOD, 
                PERIOD_YEAR, 
                OUR_COMPANY_ID, 
                OTHER_MONEY, 
                RECORD_DATE, 
                RECORD_IP, 
                RECORD_EMP, 
                UPDATE_DATE, 
                UPDATE_IP, 
                UPDATE_EMP, 
                PROCESS_DATE 
            FROM 
    	        SETUP_PERIOD 
            WHERE 
	            OUR_COMPANY_ID = #get_company.our_company_id# 
            AND 
            	PERIOD_YEAR = #get_company.period_year+1#
		</cfquery>
		<cfif get_new_period.recordcount>
			<cfset new_dsn2_1 = '#dsn#_#get_company.period_year+1#_#get_company.our_company_id#'>
		</cfif>
	<cfelse>
		<cfset get_new_period.recordcount = 0>
		<cfset new_dsn2 = '#dsn2#'>
	</cfif>
	<cfquery name="control_cashes" datasource="#dsn3#">
		SELECT 
			ORDER_CASH_POS.KASA_ID,
			CASH_ACTIONS.*
		FROM
			ORDERS,
			ORDER_CASH_POS,
			#new_dsn2#.CASH_ACTIONS CASH_ACTIONS
		WHERE
			CASH_ACTIONS.ACTION_ID=ORDER_CASH_POS.CASH_ID
			AND ORDER_CASH_POS.ORDER_ID=ORDERS.ORDER_ID 
			AND ORDERS.ORDER_ID=#attributes.order_id#
			AND (ORDER_CASH_POS.IS_CANCEL = 0 OR ORDER_CASH_POS.IS_CANCEL IS NULL)
	</cfquery>
	<cfquery name="get_sale_vouchers" datasource="#new_dsn2#">
		SELECT 
			VP.PAYROLL_NO,
			VP.ACTION_ID,
			VP.CASH_PAYMENT_VALUE,
			V.VOUCHER_ID,
			V.VOUCHER_VALUE,
			V.VOUCHER_DUEDATE,
			V.IS_PAY_TERM,
			ISNULL(VP.PAYROLL_CASH_ID,0) PAYROLL_CASH_ID,
			<cfif get_new_period.recordcount>
				ISNULL((SELECT VV.VOUCHER_STATUS_ID FROM #new_dsn2_1#.VOUCHER VV,#dsn_alias#.CHEQUE_VOUCHER_COPY_REF VC WHERE VV.VOUCHER_ID = VC.TO_CHEQUE_VOUCHER_ID AND VC.IS_CHEQUE = 0 AND V.VOUCHER_ID = VC.FROM_CHEQUE_VOUCHER_ID AND VC.TO_PERIOD_ID = #get_new_period.period_id#) ,VOUCHER_STATUS_ID)  AS VOUCHER_STATUS_ID
			<cfelse>
				V.VOUCHER_STATUS_ID AS VOUCHER_STATUS_ID
			</cfif>
		FROM 
			VOUCHER V, 
			VOUCHER_PAYROLL VP 
		WHERE 
			V.VOUCHER_PAYROLL_ID = VP.ACTION_ID AND 
			VP.PAYMENT_ORDER_ID = #attributes.order_id#
		ORDER BY
			V.VOUCHER_DUEDATE
	</cfquery>
	<cfquery name="get_sale_cheques" datasource="#new_dsn2#">
		SELECT 
			P.PAYROLL_NO,
			P.ACTION_ID,
			C.CHEQUE_ID,
			C.CHEQUE_VALUE,
			C.CHEQUE_DUEDATE,
			C.BANK_NAME,
			C.BANK_BRANCH_NAME,
			C.CHEQUE_NO,
			C.ACCOUNT_NO,
			ISNULL(P.PAYROLL_CASH_ID,0) PAYROLL_CASH_ID,
			<cfif get_new_period.recordcount>
				ISNULL((SELECT CC.CHEQUE_STATUS_ID FROM #new_dsn2_1#.CHEQUE CC,#dsn_alias#.CHEQUE_VOUCHER_COPY_REF VC WHERE CC.CHEQUE_ID = VC.TO_CHEQUE_VOUCHER_ID AND VC.IS_CHEQUE = 1 AND C.CHEQUE_ID = VC.FROM_CHEQUE_VOUCHER_ID AND VC.TO_PERIOD_ID = #get_new_period.period_id#) ,CHEQUE_STATUS_ID)  AS CHEQUE_STATUS_ID
			<cfelse>
				C.CHEQUE_STATUS_ID AS CHEQUE_STATUS_ID
			</cfif>
		FROM 
			CHEQUE C, 
			PAYROLL P 
		WHERE 
			C.CHEQUE_PAYROLL_ID = P.ACTION_ID AND 
			P.PAYMENT_ORDER_ID = #attributes.order_id#
		ORDER BY
			C.CHEQUE_DUEDATE
	</cfquery>
	<cfquery name="get_cashes" datasource="#dsn3#">
		SELECT 
			CASH_ID,
			CASH_NAME,
			CASH_ACC_CODE,
			CASH_CODE,
			BRANCH_ID,		
			CASH_CURRENCY_ID,		
			CASH_EMP_ID
		FROM
			#new_dsn2#.CASH CASH
		WHERE
			CASH_ACC_CODE IS NOT NULL 
			<cfif session.ep.isBranchAuthorization>
				AND 
				(
				(CASH.BRANCH_ID IN(SELECT EMPLOYEE_POSITION_BRANCHES.BRANCH_ID FROM #dsn_alias#.EMPLOYEE_POSITION_BRANCHES EMPLOYEE_POSITION_BRANCHES WHERE EMPLOYEE_POSITION_BRANCHES.POSITION_CODE = #session.ep.position_code#))
				<cfif control_cashes.recordcount>
					OR
					CASH.CASH_ID IN(#valuelist(control_cashes.kasa_id)#)					
				</cfif>
				<cfif get_sale_vouchers.recordcount>
					OR
					CASH.CASH_ID IN(#valuelist(get_sale_vouchers.payroll_cash_id)#)					
				</cfif>
				<cfif get_sale_cheques.recordcount>
					OR
					CASH.CASH_ID IN(#valuelist(get_sale_cheques.payroll_cash_id)#)					
				</cfif>
				)
			</cfif>
		ORDER BY 
			CASH_NAME
	</cfquery>
	<cfquery name="get_pay_vouchers" dbtype="query">
		SELECT * FROM get_sale_vouchers WHERE VOUCHER_STATUS_ID <> 1
	</cfquery>
	<cfquery name="get_total_vouchers" dbtype="query">
		SELECT SUM(VOUCHER_VALUE) AS TOTAL_VALUE FROM get_sale_vouchers WHERE VOUCHER_STATUS_ID <> 1
	</cfquery>
	<cfquery name="get_pay_cheques" dbtype="query">
		SELECT * FROM get_sale_cheques WHERE CHEQUE_STATUS_ID <> 1
	</cfquery>
	<cfquery name="get_total_cheques" dbtype="query">
		SELECT SUM(CHEQUE_VALUE) AS TOTAL_VALUE FROM get_sale_cheques WHERE CHEQUE_STATUS_ID <> 1
	</cfquery>
	<cfif len(get_order_detail.frm_branch_id)>
		<cfquery name="get_branch" datasource="#dsn#">
			SELECT BRANCH_NAME FROM BRANCH WHERE BRANCH_ID=#get_order_detail.frm_branch_id#
		</cfquery>
	</cfif>
	<cfset variables.pageHead = variables.pageHead &  "&emsp;"  & get_order_detail.order_number>
    <cf_catalystHeader>
	<cf_box>
		<div id="basket_main_div">
			<cfform name="form_basket" method="post" action="#request.self#?fuseaction=#listgetat(attributes.fuseaction,1,'.')#.emptypopup_upd_fast_sale">
				<div class="row">
					<div class="col col-12 uniqueRow">
						<cf_basket_form id="upd_fast_sale" class="row">
							<cfset kontrol_form_update = 0>
							<input type="hidden" name="form_action_address" id="form_action_address" value="<cfoutput>#listgetat(attributes.fuseaction,1,'.')#.emptypopup_upd_fast_sale</cfoutput>">
							<input type="hidden" name="record_date" id="record_date" value="<cfoutput>#DateFormat(get_order_detail.record_date,dateformat_style)#</cfoutput>">
							<input type="hidden" name="x_required_dep" id="x_required_dep" value="<cfoutput>#x_required_dep#</cfoutput>" />
							<input type="hidden" name="x_debtor_name" id="x_debtor_name" value="<cfoutput>#x_debtor_name#</cfoutput>" />
							<input type="hidden" name="del_order_id" id="del_order_id" value="0">
							<input type="hidden" name="is_basket" id="is_basket" value="1">
							<input type="hidden" name="is_run_voucher_function" id="is_run_voucher_function" value="1">
							<cfset attributes.basket_id = 51>
							<div id="tab-container" class="tabStandart margin-top-5">
								<div id="tab-head">
									<ul class="tabNav">
										<li class="active"><a href="#minfo"><cf_get_lang dictionary_id='52125.Müşteri Bilgisi'></a></li>
										<li class=""><a href="#siparis"><cf_get_lang dictionary_id='57611.Sipariş'></a></li>								
										<li class=""><a href="#odeme"><cf_get_lang dictionary_id='57847.Ödeme'></a></li>
										<li class=""><a href="#kefil"><cfoutput>#getLang('main','kefil',58626)# #getLang('main','ve',57989)# #getLang('main','risk',57689)#</cfoutput></a></li>	
									</ul>
								</div>
								
								<div style="clear:both;"></div>
								<div id="tab-content" class="margin-top-10"> 												
										<!--- Üye Bilgileri --->
										<!---<cf_basket_form>--->
											<cfinclude template="../display/upd_fast_sale_member.cfm">
										<!---</cf_basket_form>	--->
											<!--- Basket --->
											<div id="basket_fast" class="content row" data-tab="siparis">
												<cfinclude template="../../objects/display/basket.cfm">				
											</div>							
										<div id="kefil" class="content row">  
											<!--- Risk ve Kefiller --->	
											<cfinclude template="../display/upd_fast_sale_quarantor.cfm"><!--- Kefiller --->
											<cfinclude template="../../objects/display/display_member_risk.cfm"><!--- Risk --->						
										</div>								
										<div id="odeme" class="content row"> 
											<!--- Peşinatlar --->
											<cfinclude template="../display/upd_fast_sale_payment.cfm">
											<!--- Taksitler --->
											<div class="col col-6 col-sm-6 col-xs-12 padding-bottom-10" id="islem" type="column" index="9" sort="false">
												<cfinclude template="../display/upd_fast_sale_voucher.cfm">
												<cfinclude template="../display/upd_fast_sale_cheque.cfm">
											</div>
										</div>
										<div class="col col-12">
											<div class="col col-6 pull-left ui-form-list-btn"><cf_record_info query_name="get_order_detail"></div>
											<div class="col col-6 pull-right ui-form-list-btn " >
												<cfquery name="get_our_comp_inf" datasource="#dsn#">
												SELECT IS_ORDER_UPDATE FROM OUR_COMPANY_INFO WHERE COMP_ID = #session.ep.company_id#
												</cfquery>
												<cfif get_order_detail.is_paid eq 1>
													<font color="#FF0000"><cf_get_lang no ='315.Ödendi'>! - </font>
												<cfelseif get_order_detail.purchase_sales eq 0 and get_order_detail.order_zone eq 1 and len(get_order_detail.card_paymethod_id) and get_order_detail.is_paid eq 0>
													<font color="#FF0000"><cf_get_lang no ='424.Ödenmedi'>! - </font>
												</cfif>
												
												<cfif get_period.recordcount and get_period.period_id neq session.ep.period_id>
													<font color="#FF0000"><cf_get_lang no ='436.İşlem Yaptığınız Dönem Siparişin Döneminden Farklı Olduğu İçin Güncelleme Yapamazsınız'> !</font>
												<cfelseif get_order_detail.is_processed eq 1>
													<cfquery name="control_order_ship" datasource="#dsn3#"> <!--- aktif donemde siparisle ilgili irsaliye kaydı olup olmadığı kontrol edilir --->
														SELECT SHIP_ID FROM ORDERS_SHIP WHERE ORDER_ID=#attributes.order_id# AND PERIOD_ID=#session.ep.period_id#
													</cfquery>
													<cfif control_order_ship.recordcount> <!--- bu irsaliyelerle ilgili sevkiyat ve fatura bilgileri kontrol ediliyor --->
														<font color="#FF0000"><cf_get_lang_main no='481.İrsaliye Kesildi'></font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
														<cfset control_ship_list=valuelist(control_order_ship.SHIP_ID)>
														<!--- bu kontrolle direk siparişten olusturulmus (irsaliyeli) fatura kayıtlarına da ulaşılabiliyor. --->
														<cfquery name="control_invoice_ships" datasource="#dsn2#">
															SELECT SHIP_ID FROM INVOICE_SHIPS WHERE SHIP_ID IN (#control_ship_list#) AND SHIP_PERIOD_ID=#session.ep.period_id#
														</cfquery>
														<cfif control_invoice_ships.recordcount>
															<font color="#FF0000"><cf_get_lang no ='425.Fatura Kesildi'>!</font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
														</cfif>
														<cfquery name="control_ship_result" datasource="#dsn2#"><!--- siparisin baglı oldugu irsaliyelerin sevkiyatları kontrol ediliyor --->
															SELECT 
																SR.SHIP_FIS_NO,
																SR.SHIP_RESULT_ID
															FROM
																SHIP_RESULT SR,
																SHIP_RESULT_ROW SR_ROW 
															WHERE 
																SR.SHIP_RESULT_ID = SR_ROW.SHIP_RESULT_ID AND
																SR.IS_TYPE IS NULL AND
																SR_ROW.SHIP_ID IN (#control_ship_list#)
														</cfquery>
														<cfif control_ship_result.recordcount>
															<font color="#FF0000"><cf_get_lang no ='426.Sevkiyat Yapıldı'>!</font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
														</cfif>
													<cfelse>
														<cfquery name="control_order_invoice" datasource="#dsn3#"> <!--- aktif donemde siparisle ilgili fatura kaydı olup olmadığı kontrol edilir --->
															SELECT INVOICE_ID FROM ORDERS_INVOICE WHERE ORDER_ID=#attributes.order_id# AND PERIOD_ID=#session.ep.period_id#
														</cfquery>
														<cfif control_order_invoice.recordcount>
															<font color="#FF0000"><cf_get_lang no ='425.Fatura Kesildi'>!</font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
														</cfif>
													</cfif>
													<cfif get_pay_vouchers.recordcount neq 0>
														<cfset kontrol_form_update = 1>
														<br/><font color="#FF0000"><cf_get_lang no ='437.Senetler Üzerinde İşlem Yapıldığı İçin Güncelleme Yapamazsınız'> !</font>
													</cfif>
													<cfif get_pay_cheques.recordcount neq 0>
														<cfset kontrol_form_update = 1>
														<br/><font color="#FF0000"><cf_get_lang no ='617.Çekler Üzerinde İşlem Yapıldığı İçin Güncelleme Yapamazsınız'> !</font>
													</cfif>
													<cfif GET_BANK_ACTION_INFO.recordcount neq 0>
														<cfset kontrol_form_update = 1>
														<br/><font color="#FF0000"><cf_get_lang no ='618.Kredi Kartı Tahsilatlarınızın Hesaba Geçişlerini Yaptığınız İçin Hesaba Geçiş İşlemlerinizi Geri Almadan Siparişi Güncelleyemezsiniz'> !</font>
													</cfif>
													<cfif kontrol_form_update eq 1 and get_our_comp_inf.IS_ORDER_UPDATE eq 1>
														<input type="hidden" name="update_order_only" id="update_order_only" value="1">
														<cf_workcube_buttons insert_info = 'Siparişi Güncelle' insert_alert='Tahsilatlarda İşlem Yapıldığı İçin Sadece Sipariş Güncellenecektir.Emin misiniz?' is_upd='1' is_delete='0' add_function='kontrol_form(1)'>
													<cfelseif kontrol_form_update eq 0 and get_our_comp_inf.IS_ORDER_UPDATE eq 1>
														<cf_workcube_buttons is_upd='1' is_delete='0' add_function='kontrol_form()'>
													</cfif>
												<cfelse>
													<cfquery name="KONTROL" datasource="#dsn3#">
														SELECT ORDER_ID FROM PRODUCTION_ORDERS_ROW WHERE ORDER_ID = #attributes.order_id#
													</cfquery>
													<cfif kontrol.recordcount and session.ep.admin neq 1>
														<cf_get_lang no ='427.Üretim Emri Verildi'>!
													<cfelseif len(get_order_detail.cancel_date)>
														<font color="#FF0000"><cf_get_lang no ='438.İptal Edildi'> !</font>
													<cfelseif get_pay_vouchers.recordcount gt 0>
														<cfset kontrol_form_update = 1>
														<font color="#FF0000"><cf_get_lang no ='437.Senetler Üzerinde İşlem Yapıldığı İçin Güncelleme Yapamazsınız'> !</font>
													<cfelseif get_pay_cheques.recordcount gt 0>
														<cfset kontrol_form_update = 1>
														<font color="#FF0000"><cf_get_lang no ='617.Çekler Üzerinde İşlem Yapıldığı İçin Güncelleme Yapamazsınız'> !</font>
													<cfelseif GET_BANK_ACTION_INFO.recordcount neq 0>
														<cfset kontrol_form_update = 1>
														<font color="#FF0000"><cf_get_lang no ='618.Kredi Kartı Tahsilatlarınızın Hesaba Geçişlerini Yaptığınız İçin Hesaba Geçiş İşlemlerinizi Geri Almadan Siparişi Güncelleyemezsiniz'> !</font>
													<cfelse>
														<cf_workcube_buttons is_upd='1' is_delete='1' add_function='kontrol_form()' del_function='kontrol_form2()'>
													</cfif>
													<cfif kontrol_form_update eq 1>
														<input type="hidden" name="update_order_only" id="update_order_only" value="1">
														<cf_workcube_buttons insert_info = 'Siparişi Güncelle' insert_alert='Tahsilatlarda İşlem Yapıldığı İçin Sadece Sipariş Güncellenecektir.Emin misiniz?' is_upd='1' is_delete='0' add_function='kontrol_form(1)'>
													</cfif>
												</cfif> 
											</div>		
										</div>
								</div>
							</div>	
						</cf_basket_form>
					</div>
				</div>
			</cfform>
		</div>
	</cf_box>
</cfif>
<cf_get_lang_set module_name="#lcase(listgetat(attributes.fuseaction,1,'.'))#">
<script type="text/javascript">
	function kontrol_form(type)
	{
		if (form_basket.order_date.value == '')
		{
			alert("Sipariş Tarihi Girmelisiniz!");
			return false;
		}
		if (form_basket.deliverdate.value.length == 0)
		{
			alert("<cf_get_lang no='185.Teslim Tarihi Girmelisiniz'> !");
			return false;
		}	
		if (!date_check(form_basket.order_date,form_basket.deliverdate,"Sipariş Teslim Tarihi, Sipariş Tarihinden Önce Olamaz !"))
			return false;
		
		
		if(document.all.consumer_id.value != '' && form_basket.tc_num.value=="")
		{
			alert("<cf_get_lang no ='441.Bireysel Müşteri İçin TC Kimlik No Bilgisini Giriniz'>!");
			return false;
		}
		if(type == undefined)
		{
			if(form_basket.record_num_3.value > 0 || form_basket.record_num_4.value > 0)
			{
				if(document.all.kontrol_cash.value == 0)
				{
					alert("<cf_get_lang no ='439.Senetler İçin En Az Bir Tane'> <cfoutput>#session.ep.money#</cfoutput><cf_get_lang no ='440.Kasa Ekleyiniz'>  !");
					return false;
				}
			}
			if(form_basket.total_cash_amount.value == '')form_basket.total_cash_amount.value= 0;
			toplam_pesin_tutar = filterNum(form_basket.total_cash_amount.value);
			toplam_fatura_tutar = wrk_round(form_basket.basket_net_total.value,2);
			toplam_senet_tutar = filterNum(form_basket.total_voucher_value.value);
			toplam_h_senet_tutar = filterNum(form_basket.total_voucher_value.value);
			toplam_cek_tutar = filterNum(form_basket.total_cheque_value.value);
			toplam_senet_tutar = wrk_round(toplam_senet_tutar+toplam_pesin_tutar+toplam_cek_tutar,2);
			if (toplam_fatura_tutar != toplam_senet_tutar) 
			{
				alert("<cf_get_lang no='87.Sipariş Tutarı İle Çek , Senet Ve Ödemelerin Toplam Tutarı Eşit Olmalı'> !");
				return false;
			}
			form_due_value = filterNum(form_basket.basket_due_value.value,2);
			payment_due_value = parseFloat((filterNum(form_basket.total_due_value.value,2)*filterNum(form_basket.total_voucher_value.value))+(filterNum(form_basket.total_cheque_due_value.value,2)*toplam_cek_tutar));
			payment_due_value = parseFloat(payment_due_value / toplam_senet_tutar);
			if (payment_due_value != 0 && payment_due_value > form_due_value) 
			{
				alert("<cf_get_lang no='89.Ödeme Ortalama Vadesi Siparişin Ortalama Vadesinden Fazla Olamaz Lütfen Çek ve Senetlerinizi Tekrar Düzenleyiniz'>! ");
				return false;
			}
			for(dd=1;dd<=form_basket.record_num_3.value;dd++)
			{
				if(eval("document.form_basket.row_kontrol_3"+dd).value == 1)
				{
					if(eval('form_basket.due_date'+dd).value == '')
					{
						alert("<cf_get_lang no='90.Lütfen Senetler İçin Vade Tarihi Giriniz'> !");
						return false;
					}
				}
			}
			for(dd=1;dd<=form_basket.record_num_4.value;dd++)
			{
				if(eval("document.form_basket.row_kontrol_4"+dd).value == 1)
				{
					if(eval('form_basket.cheque_due_date'+dd).value == '')
					{
						alert("<cf_get_lang no='616.Lütfen Çekler İçin Vade Tarihi Giriniz'> !");
						return false;
					}
					if(eval('form_basket.cheque_number'+dd).value == '')
					{
						alert("<cf_get_lang no='614.Lütfen Çekler İçin Çek Numarası Giriniz'> !");
						return false;
					}
				}
			}
		}
		else
		{
			toplam_fatura_tutar = wrk_round(form_basket.basket_net_total.value,2);
			if(toplam_fatura_tutar != document.form_basket.old_nettotal.value)
			{
				alert("<cf_get_lang no='615.Sipariş Tutarını Değiştiremezsiniz Lütfen Ürünleri Düzenleyiniz'> !");
				return false;
			}
		}
		//sıfır stok
		//var new_sql = "SELECT IS_SELECTED FROM SETUP_BASKET_ROWS WHERE B_TYPE=1 AND TITLE='zero_stock_status' AND BASKET_ID =  AND B_TYPE=1";
		/*var basket_id_ = '<cfoutput>#attributes.basket_id#</cfoutput>';
		var basket_zero_stock_status = wrk_safe_query('sls_bsk_z_stk_stt','dsn3',0,basket_id_);
		alert(basket_zero_stock_status.IS_SELECTED);
		if(basket_zero_stock_status.IS_SELECTED != 1)
		{
			if(!zero_stock_control('','',0,'',1)) return false;
		}*/
		<cfif isdefined("is_dsp_category") and is_dsp_category eq 1>
			if(((document.getElementById('comp_member_cat') != undefined && document.getElementById('comp_member_cat').value == '') || document.getElementById('comp_member_cat') == undefined) && ((document.getElementById('cons_member_cat') != undefined && document.getElementById('cons_member_cat').value == '') || document.getElementById('cons_member_cat') == undefined))
			{
				alert("Lütfen Üye Kategorisi Giriniz!");	
				return false;
			}
		</cfif>
		<cfif isdefined("xml_upd_row_project") and xml_upd_row_project eq 1>
			project_field_name = 'project_head';
		<cfelse>
			project_field_name = '';
		</cfif>
		<cfif isdefined('x_apply_deliverdate_to_rows') and x_apply_deliverdate_to_rows eq 1>
			date_field_name = 'deliverdate';
		<cfelse>
			date_field_name = '';
		</cfif>
		apply_deliver_date(date_field_name,project_field_name);
		document.all.is_run_voucher_function.value=0;
		return (process_cat_control() && check_cash_pos() && saveForm());
	}
	function kontrol_member_cat(type)
	{
		if (type == 1)
		{
			is_company.style.display = '';
			is_consumer.style.display = 'none';
			document.getElementById('cons_member_cat').value = '';
		}
		if (type == 2)
		{
			is_company.style.display = 'none';
			is_consumer.style.display = '';
			document.getElementById('comp_member_cat').value = '';
		}
	}		
	function kontrol_form2()
	{
		form_basket.del_order_id.value = <cfoutput>#attributes.order_id#</cfoutput>;
		return true;
		//return process_cat_control();
	}
	function pencere_ac(no)
	{
		if (document.form_basket.city[document.form_basket.city.selectedIndex].value == "")
			alert("<cf_get_lang no ='400.İlk Olarak İl Seçiniz'> !");
		else
			windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_dsp_county&field_id=form_basket.county_id&field_name=form_basket.county&city_id=' + document.form_basket.city.value,'small');
	}
	function add_adress()
	{
		if(!(form_basket.company_id.value=="") || !(form_basket.consumer_id.value==""))
		{
			if(form_basket.company_id.value!="")
			{
				str_adrlink = '&field_long_adres=form_basket.ship_address&field_member_id='+document.form_basket.company_id.value+'';
				if(form_basket.ship_address_city_id!=undefined) str_adrlink = str_adrlink+'&field_city=form_basket.ship_address_city_id';
				if(form_basket.ship_address_county_id!=undefined) str_adrlink = str_adrlink+'&field_county=form_basket.ship_address_county_id'<cfif session.ep.isBranchAuthorization>+'&is_store_module='+1</cfif>;
				openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_member_address&is_comp=1&keyword='+encodeURIComponent(form_basket.comp_name.value)+''+ str_adrlink);
				return true;
			}
			else
			{
				str_adrlink = '&field_long_adres=form_basket.ship_address&field_member_id='+document.form_basket.consumer_id.value+''; 
				if(form_basket.ship_address_city_id!=undefined) str_adrlink = str_adrlink+'&field_city=form_basket.ship_address_city_id';
				if(form_basket.ship_address_county_id!=undefined) str_adrlink = str_adrlink+'&field_county=form_basket.ship_address_county_id'<cfif session.ep.isBranchAuthorization>+'&is_store_module='+1</cfif>;
				openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_member_address&is_comp=0&keyword='+encodeURIComponent(form_basket.member_name.value)+' '+form_basket.member_surname.value+''+ str_adrlink);
				return true;
			}
		}
		else
		{
			alert("<cf_get_lang no='254.Cari Hesap Secmelisiniz'>!");
			return false;
		}
	}
	function pencere_ac_paymethod()
	{
		var str_control=0;
		<cfif x_required_paymethod eq 1>
			if(document.form_basket!=undefined && document.form_basket.basket_id!= undefined && document.form_basket.product_id!= undefined)
			{
				if(document.form_basket.product_id.value!=undefined && document.form_basket.product_id.value!='' )
				{
					str_control=1;
				}
				else if(document.form_basket.product_id.length > 1)
				{
					for(var spt_row=0;spt_row < document.form_basket.product_id.length;spt_row++)
					{
						if(document.form_basket.product_id[spt_row].value!='')
						{
							str_control=1;
							break;
						}
					}
				}
				if(str_control==1)
				{
					alert("<cf_get_lang no ='401.Baskette Ürün Varken Ödeme Yöntemini Değiştiremezsiniz'> !");
				}
			}
		</cfif>
		if(str_control == 0)
			windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_paymethods&field_id=form_basket.paymethod_id&field_name=form_basket.paymethod&field_dueday=form_basket.basket_due_value#card_link#</cfoutput>','list');
	}
	function add_adresses()
	{
		if(!(form_basket.company_id.value=="") || !(form_basket.consumer_id.value==""))
		{
			if(form_basket.company_id.value!="")
			{
				str_adrlink = '&field_adres=form_basket.address&field_member_id='+document.form_basket.company_id.value+'';
				if(form_basket.city_id!=undefined) str_adrlink = str_adrlink+'&field_city=form_basket.city';
				if(form_basket.county_id!=undefined) str_adrlink = str_adrlink+'&field_county=form_basket.county_id';
				if(form_basket.county!=undefined) str_adrlink = str_adrlink+'&field_county_name=form_basket.county';
				windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_member_address&is_comp=1&keyword='+encodeURIComponent(form_basket.comp_name.value)+''+ str_adrlink , 'list');
				return true;
			}
			else
			{
				str_adrlink = '&field_adres=form_basket.address&field_member_id='+document.form_basket.consumer_id.value+''; 
				if(form_basket.city!=undefined) str_adrlink = str_adrlink+'&field_city=form_basket.city';
				if(form_basket.county_id!=undefined) str_adrlink = str_adrlink+'&field_county=form_basket.county_id';
				if(form_basket.county!=undefined) str_adrlink = str_adrlink+'&field_county_name=form_basket.county';
				windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_member_address&is_comp=0&keyword='+encodeURIComponent(form_basket.member_name.value)+' '+form_basket.member_surname.value+'&tc_num='+form_basket.tc_num.value+''+ str_adrlink , 'list');
				return true;
			}
		}
		else
		{
			alert("<cf_get_lang_main no ='303.Önce Üye Seçiniz'>!");
			return false;
		}
	}
	function sayfa_getir()
	{
		if(confirm("<cf_get_lang no ='444.Teslim Tarihi Güncellenecek Emin misiniz'> ?") == true)
			{
			form_basket.action='<cfoutput>#request.self#?fuseaction=#fusebox.circuit#.emptypopup_upd_fast_sale_deliverdate&order_id=#attributes.order_id#</cfoutput>&deliver_date='+document.form_basket.deliverdate.value;
			form_basket.submit();
		}
		else {
				return false;
			}
	}
	function sayfa_getir_2()
	{
		if(confirm("<cf_get_lang no ='613.Aşama Güncellenecek Emin misiniz'> ?") == true)
		{
			form_basket.action='<cfoutput>#request.self#?fuseaction=#fusebox.circuit#.emptypopup_upd_fast_sale_deliverdate&order_id=#attributes.order_id#</cfoutput>&deliver_date='+document.form_basket.deliverdate.value+'&process_cat='+document.form_basket.process_stage.value;
			form_basket.submit();
		}
		else {
				return false;
			}
	}
</script>